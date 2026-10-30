local paths = require("paths")

local read_file = function(path)
    local file = assert(io.open(path, "r"))
    local data = file:read("*a")
    file:close()
    return data
end

return {
    entity_counter = {
        fragment = read_file(paths.shaders .. "/entity_counter.frag")
    },
    pie_chart = {
        fragment = read_file(paths.shaders .. "/pie_chart.frag")
    },
    outline = {
        fragment = read_file(paths.shaders .. "/outline.frag")
    }
}
