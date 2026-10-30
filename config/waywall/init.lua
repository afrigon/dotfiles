local helpers = require("waywall.helpers")
local shaders = require("shaders")
local modes = require("modes")
local events = require("events")
local overlay = require("overlay")

local sensitivity = 5.74146011

local config = {
    input = {
        layout = "us",
        repeat_rate = 40,
        repeat_delay = 300,
        sensitivity = sensitivity,
        raw_sensitivity = sensitivity,
        confine_pointer = false,
    },
    theme = {
        background = "#303030ff",
        ninb_anchor = "right",
        ninb_opacity = 0.75
    },
    shaders = shaders,
    actions = {
        ["Ctrl-N"] = helpers.toggle_floating
    }
}

events.register()
overlay.register()
modes.register(config)

return config
