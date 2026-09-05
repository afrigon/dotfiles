local waywall = require("waywall")
local helpers = require("waywall.helpers")
local options = require("options")

local read_file = function(path)
    local file = assert(io.open(path, "r"))
    local data = file:read("*a")
    file:close()
    return data
end

local config = {
    input = {
        layout = options.layout,
        repeat_rate = options.repeat_rate,
        repeat_delay = options.repeat_delay,
        sensitivity = options.sensitivity,
        confine_pointer = options.confine_pointer,
    },
    theme = {
        background = options.background_color,
        ninb_anchor = "right",
        ninb_opacity = 0.75
    },
    shaders = {
        pie = {
            fragment = read_file(options.config_path .. "/pie.frag"),
        },
        outline = {
            fragment = read_file(options.config_path .. "/outline.frag"),
        },
        ecounter = {
            fragment = read_file(options.config_path .. "/ecounter.frag"),
        },
    },
}

local ensure_started = function(app)
    local handle = io.popen("pgrep -P $PPID -f '" .. app.pattern .. "'")
    local running = handle:read("*l") ~= nil
    handle:close()

    print("ensure_started: " .. app.pattern .. " -> " .. (running and "already running" or "starting"))

    if not running then
        io.popen("pgrep -f '" .. app.pattern .. "' | while read p;" ..
            " do [ \"$(awk '{print $4}' /proc/$p/stat)\" = 1 ] && kill -9 $p; done"):close()
        waywall.exec(app.command)
    end
end

local active_remaps = {}

local function apply_remaps(remaps)
    local merged = {}

    for source, output in pairs(remaps) do
        merged[source] = output
    end

    for source, output in pairs(active_remaps) do
        if remaps[source] ~= output and waywall.get_key(output) then
            merged[source] = output
        end
    end

    for source, output in pairs(remaps) do
        if active_remaps[source] ~= output and waywall.get_key(source) then
            merged[source] = active_remaps[source]
        end
    end

    active_remaps = merged
    waywall.set_remaps(merged)
end

local function set_remaps(state)
    if state.screen == "inworld" and state.inworld == "unpaused" then
        apply_remaps(options.remaps)
    else
        apply_remaps(options.menus_remaps)
    end
end

local function on_state(state)
    set_remaps(state)

    for _, app in pairs(options.apps) do
        if app.on_update then
            local command = app.on_update(state)
            if command then
                waywall.exec(command)
            end
        end
    end
end

local function on_load()
    for _, app in pairs(options.apps) do
        ensure_started(app)
    end

    local ok, state = pcall(waywall.state)
    if ok then
        on_state(state)
    else
        apply_remaps(options.remaps)
    end

end

local function on_state_changed()
    on_state(waywall.state())
end

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

for name, mode in pairs(options.modes) do
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

waywall.listen("load", on_load)
waywall.listen("state", on_state_changed)

config.actions = {}

config.actions[options.floating_key] = function()
    ensure_started(options.apps.calc)
    helpers.toggle_floating()
end

for name, mode in pairs(options.modes) do
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
            set_mirrors_and_overlays(nil)
        else
            waywall.set_resolution(mode.width, mode.height)
            waywall.set_sensitivity(mode.sensitivity or 0)
            set_mirrors_and_overlays(name)
        end
    end
end

return config
