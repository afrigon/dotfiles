local waywall = require("waywall")
local paths = require("paths")
local window_size = require("window")

local width = window_size.width
local height = window_size.height

local thin = { w = math.floor(340 * width / 1920), h = height }
local tall = { w = 340, h = 16384 }

local blockentities_percentage_dst = { x = 1659, y = 811, w = 88, h = 56 }
local unspecified_percentage_dst = { x = 1659, y = 875, w = 88, h = 56 }

-- The capture must match the entity_counter shader; the margin leaves room for its outline.
local ecounter_capture = { x = 14, y = 38, w = 23, h = 7 }
local ecounter_margin = 1
local ecounter_scale = 8
local ecounter_position = { x = 1530, y = 626 }

local ecounter_mirror = function(depth)
    return {
        src = {
            x = ecounter_capture.x - ecounter_margin,
            y = ecounter_capture.y - ecounter_margin,
            w = ecounter_capture.w + 2 * ecounter_margin,
            h = ecounter_capture.h + 2 * ecounter_margin
        },
        dst = {
            x = ecounter_position.x - ecounter_margin * ecounter_scale,
            y = ecounter_position.y - ecounter_margin * ecounter_scale,
            w = (ecounter_capture.w + 2 * ecounter_margin) * ecounter_scale,
            h = (ecounter_capture.h + 2 * ecounter_margin) * ecounter_scale
        },
        depth = depth,
        shader = "entity_counter",
        color_key = { input = "#DDDDDD", output = "#FFFFFF" },
    }
end

local pie_mirror = function(window, depth)
    return {
        src = { x = window.w - 330, y = window.h - 400, w = 319, h = 169 },
        dst = { x = 1530, y = 750, w = 242, h = 254 },
        depth = depth,
        shader = "pie_chart",
    }
end

local pie_percentage_mirror = function(window, input, output, dst, depth)
    return {
        src = { x = window.w - 93, y = window.h - 221, w = 13, h = 9 },
        dst = { x = dst.x - 8, y = dst.y - 8, w = dst.w + 16, h = dst.h + 16 },
        depth = depth,
        shader = "outline",
        color_key = { input = input, output = output },
    }
end

local modes = {
    thin = {
        key = "Z",
        width = thin.w,
        height = thin.h,
        mirrors = {
            ecounter_mirror(nil),
            pie_mirror(thin, nil),
            pie_percentage_mirror(thin, "#E96D4D", "#F3A94E", blockentities_percentage_dst, 1),
            pie_percentage_mirror(thin, "#45CC65", "#45CC65", unspecified_percentage_dst, 1),
        }
    },
    wide = {
        key = "X",
        width = width,
        height = math.floor(340 * height / 1080)
    },
    tall = {
        key = "C",
        width = tall.w,
        height = tall.h,
        sensitivity = 0.38731546,
        mirrors = {
            eye_zoom = {
                src = { x = 140, y = 7902, w = 60, h = 580 },
                dst = { x = 0, y = 0, w = 1080, h = 1440 },
            },
            ecounter_mirror(nil),
            pie_mirror(tall, nil),
            pie_percentage_mirror(tall, "#E96D4D", "#F3A94E", blockentities_percentage_dst, 1),
            pie_percentage_mirror(tall, "#45CC65", "#45CC65", unspecified_percentage_dst, 1)
        },
        overlays = {
            measurement = {
                path = paths.textures .. "/measurement_overlay.png",
                dst = { x = 0, y = 416, w = 1080, h = 608 },
                depth = 1
            }
        }
    }
}

local make_mirror = function(options)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.mirror(options)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local make_image = function(path, dst)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.image(path, dst)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local mode_mirrors_and_overlays = {}

for name, mode in pairs(modes) do
    local toggles = {}

    for _, mirror in pairs(mode.mirrors or {}) do
        table.insert(toggles, make_mirror(mirror))
    end

    for _, image in pairs(mode.overlays or {}) do
        table.insert(toggles, make_image(image.path, { dst = image.dst, depth = image.depth }))
    end

    mode_mirrors_and_overlays[name] = toggles
end

local active_mirrors_and_overlays = nil

local function set_mirrors_and_overlays(name)
    if active_mirrors_and_overlays == name then
        return
    end

    if active_mirrors_and_overlays then
        for _, toggle in ipairs(mode_mirrors_and_overlays[active_mirrors_and_overlays]) do
            toggle(false)
        end
    end

    active_mirrors_and_overlays = name

    if name then
        for _, toggle in ipairs(mode_mirrors_and_overlays[name]) do
            toggle(true)
        end
    end
end

local function register(config)
    for name, mode in pairs(modes) do
        config.actions[mode.key] = function()
            if waywall.get_key("F3") then
                return false
            end

            local ok, state = pcall(waywall.state)
            if ok and (state.screen ~= "inworld" or state.inworld == "menu") then
                return false
            end

            local active_width, active_height = waywall.active_res()

            if active_width == mode.width and active_height == mode.height then
                waywall.set_resolution(0, 0)
                waywall.set_sensitivity(0)
                waywall.set_raw_sensitivity(0)
                set_mirrors_and_overlays(nil)
            else
                waywall.set_resolution(mode.width, mode.height)
                waywall.set_sensitivity(mode.sensitivity or 0)
                waywall.set_raw_sensitivity(mode.sensitivity or 0)
                set_mirrors_and_overlays(name)
            end
        end
    end
end

return {
    register = register
}
