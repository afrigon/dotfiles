local shaders = require("shaders")
local modes = require("modes")
local events = require("events")

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
    actions = {}
}

events.register()
modes.register(config)

return config
