local paths = require("paths")
local mirrors = require("mirrors")

local read_file = function(path)
    local file = assert(io.open(path, "r"))
    local data = file:read("*a")
    file:close()
    return data
end

local capture_define = function(capture)
    return string.format(
        "#define CAPTURE vec4(%.1f, %.1f, %.1f, %.1f)\n",
        capture.x,
        capture.y,
        capture.w,
        capture.h
    )
end

local fill_define = function(color)
    return string.format(
        "#define FILL vec4(%.1f / 255.0, %.1f / 255.0, %.1f / 255.0, %.1f / 255.0)\n",
        color.r,
        color.g,
        color.b,
        color.a
    )
end

local outline = function(capture)
    return {
        fragment = capture_define(capture) .. read_file(paths.shaders .. "/outline.frag")
    }
end

local fill = function(color)
    return {
        fragment = fill_define(color) .. read_file(paths.shaders .. "/fill.frag")
    }
end

local dot = function(capture, color)
    return {
        fragment = capture_define(capture) .. fill_define(color) .. read_file(paths.shaders .. "/dot.frag")
    }
end

return {
    entity_counter = outline(mirrors.entity_counter.capture),
    -- The ninbot line's background.
    f3_backdrop = fill({ r = 90, g = 90, b = 90, a = 102 }),
    -- The colours of the X and Z axes in F3's crosshair.
    x_axis_marker = dot(mirrors.f3_open.capture, { r = 255, g = 0, b = 0, a = 255 }),
    z_axis_marker = dot(mirrors.f3_open.capture, { r = 0, g = 0, b = 255, a = 255 }),
    pie_chart = {
        fragment = read_file(paths.shaders .. "/pie_chart.frag")
    },
    pie_percentage = {
        fragment = read_file(paths.shaders .. "/pie_percentage.frag")
    }
}
