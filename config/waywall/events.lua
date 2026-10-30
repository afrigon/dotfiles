local waywall = require("waywall")
local binds = require("binds")

local function on_state(state)
    if state.screen == "inworld" and state.inworld == "unpaused" then
        binds.configure_gameplay()
    else
        binds.configure_menu()
    end
end

local function on_load()
    local ok, state = pcall(waywall.state)

    if ok then
        on_state(state)
    else
        binds.configure_menu()
    end
end

local function on_state_changed()
    on_state(waywall.state())
end

local function register()
    waywall.listen("load", on_load)
    waywall.listen("state", on_state_changed)
end

return { 
    register = register
}
