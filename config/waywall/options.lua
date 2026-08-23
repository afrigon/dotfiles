local width = 2560
local height = 1440

local home_path = os.getenv("HOME")
local xdg_config_home_path = os.getenv("XDG_CONFIG_HOME") or (home_path .. "/.config")
local config_path = xdg_config_home_path .. "/waywall"
local calc_path = home_path .. "/mcsr/Ninjabrain-Bot-1.5.2.jar"

local thin_window = { w = math.floor(340 * width / 1920), h = height }
local tall_window = { w = 340, h = 16384 }

local ecounter_mirror = function(depth)
    return {
        src = { x = 14, y = 37, w = 48, h = 9 },
        dst = { x = 1530, y = 618, w = 8 * 48, h = 8 * 9 },
        depth = depth,
        shader = "ecounter",
        color_key = { input = "#DDDDDD", output = "#FFFFFF" },
    }
end

local pie_mirror = function(window, depth)
    return {
        src = { x = window.w - 330, y = window.h - 400, w = 319, h = 169 },
        dst = { x = 1530, y = 750, w = 242, h = 254 },
        depth = depth,
        shader = "pie",
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

local blockentities_percentage_dst = { x = 1659, y = 811, w = 88, h = 56 }
local unspecified_percentage_dst = { x = 1659, y = 875, w = 88, h = 56 }

return {
    config_path = config_path,
    layout = "us",
    repeat_rate = 40,
    repeat_delay = 300,
    confine_pointer = false,
    background_color = "#303030ff",
    width = width,
    height = height,
    sensitivity = 5.74146011,
    floating_key = "Ctrl-N",
    modes = {
        thin = {
            key = "Z",
            width = thin_window.w,
            height = thin_window.h,
            mirrors = {
                ecounter_mirror(nil),
                pie_mirror(thin_window, nil),
                pie_percentage_mirror(thin_window, "#E96D4D", "#F3A94E", blockentities_percentage_dst, 1),
                pie_percentage_mirror(thin_window, "#45CC65", "#45CC65", unspecified_percentage_dst, 1),
            }
        },
        wide = {
            key = "X",
            width = width,
            height = math.floor(340 * height / 1080)
        },
        tall = {
            key = "C",
            width = tall_window.w,
            height = tall_window.h,
            sensitivity = 0.38731546,
            mirrors = {
                eye_zoom = {
                    src = { x = 140, y = 7902, w = 60, h = 580 },
                    dst = { x = 0, y = 0, w = 1080, h = 1440 },
                },
                ecounter_mirror(nil),
                pie_mirror(tall_window, nil),
                pie_percentage_mirror(tall_window, "#E96D4D", "#F3A94E", blockentities_percentage_dst, 1),
                pie_percentage_mirror(tall_window, "#45CC65", "#45CC65", unspecified_percentage_dst, 1),
            },
            overlays = {
                measurement = {
                    path = config_path .. "/measurement_overlay.png",
                    dst = { x = 0, y = 416, w = 1080, h = 608 },
                    depth = 1,
                },
            },
        },
    },
    apps = {
        calc = {
            pattern = "[N]injabrain.*jar",
            command = config_path .. "/calc/scripts/start-calc.sh",
        },
        calc_display = {
            pattern = "[e]ww --config " .. config_path .. "/calc daemon",
            command = config_path .. "/calc/scripts/start-display.sh",
        },
        obs_state = {
            pattern = "[o]bs-state.sh",
            command = config_path .. "/calc/scripts/obs-state.sh",
        },
        obs_server = {
            pattern = "[h]ttp.server 52534",
            command = "python3 -m http.server 52534 --bind 127.0.0.1 --directory " .. config_path .. "/calc/obs",
        },
    },
    remaps = {
        ["CapsLock"] = "F3",
        ["F3"] = "F24",
        ["G"] = "D",
        ["D"] = "G",
        ["B"] = "A",
        ["A"] = "B",
        ["Tab"] = "F23",
        ["F1"] = "Tab",
        ["F10"] = "F1"
    },
    menus_remaps = {
        ["CapsLock"] = "F3",
        ["F3"] = "F24",
        ["Tab"] = "F23",
        ["F1"] = "Tab",
        ["F10"] = "F1"
    }
}

