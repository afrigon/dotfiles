local paths = require("paths")
local mirrors = require("mirrors")

local read_file = function(path)
    local file = assert(io.open(path, "r"))
    local data = file:read("*a")
    file:close()
    return data
end

local outline = function(capture)
    local define = string.format(
        "#define CAPTURE vec4(%.1f, %.1f, %.1f, %.1f)\n",
        capture.x,
        capture.y,
        capture.w,
        capture.h
    )

    return {
        fragment = define .. read_file(paths.shaders .. "/outline.frag")
    }
end

local fill = function(color)
    local define = string.format(
        "#define FILL vec4(%.1f / 255.0, %.1f / 255.0, %.1f / 255.0, %.1f / 255.0)\n",
        color.r,
        color.g,
        color.b,
        color.a
    )

    return {
        fragment = define .. read_file(paths.shaders .. "/fill.frag")
    }
end

return {
    entity_counter = outline(mirrors.entity_counter.capture),
    -- The ninbot line's background.
    f3_backdrop = fill({ r = 90, g = 90, b = 90, a = 102 }),
    pie_chart = {
        fragment = read_file(paths.shaders .. "/pie_chart.frag")
    },
    pie_percentage = {
        fragment = read_file(paths.shaders .. "/pie_percentage.frag")
    }
}
