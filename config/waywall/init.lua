local waywall = require("waywall")
local helpers = require("waywall.helpers")
local options = require("options")

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
}

local ensure_started = function(app)
    local handle = io.popen("pgrep -f '" .. app.pattern .. "'")
    local running = handle:read("*l") ~= nil
    handle:close()

    if not running then
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
    end
end

local function on_state_changed()
    on_state(waywall.state())
end

waywall.listen("load", on_load)
waywall.listen("state", on_state_changed)

config.actions = {}

config.actions[options.floating_key] = helpers.toggle_floating

for _, mode in pairs(options.modes) do
    config.actions[mode.key] = function()
        if waywall.get_key("F3") then
            return false
        end

        local state = waywall.state()
        if state.screen ~= "inworld" or state.inworld == "menu" then
            return false
        end

        local active_width, active_height = waywall.active_res()

        if active_width == mode.width and active_height == mode.height then
            waywall.set_resolution(0, 0)
            waywall.set_sensitivity(0)
        else
            waywall.set_resolution(mode.width, mode.height)
            waywall.set_sensitivity(mode.sensitivity or 0)
        end
    end
end

return config
