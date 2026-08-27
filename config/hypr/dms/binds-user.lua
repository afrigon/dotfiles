-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + P")
hl.bind("SUPER + P", hl.dsp.exec_cmd("dms ipc call color-picker open"), { description = "Color Picker: Open" })

hl.unbind("Pause")
hl.bind("Pause", hl.dsp.exec_cmd("sh -c \"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0\""), { locked = true, description = "Unset Mute" })

hl.unbind("SUPER + Print")
hl.bind("SUPER + Print", hl.dsp.exec_cmd("obs-cmd --websocket \"obsws://localhost:4455/$(op read \"op://Personal/OBS Websocket Service/password\")\" recording toggle"))

hl.unbind("SUPER + W")
hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.group.toggle(), { description = "togglegroup" })

hl.unbind("SUPER + SHIFT + S")
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot region edit"), { description = "Region Screenshot" })
