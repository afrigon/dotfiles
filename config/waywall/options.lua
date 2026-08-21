local width = 2560
local height = 1440

local home_path = os.getenv("HOME")
local xdg_config_home_path = os.getenv("XDG_CONFIG_HOME") or (home_path .. "/.config")
local config_path = xdg_config_home_path .. "/waywall"
local calc_path = home_path .. "/mcsr/Ninjabrain-Bot-1.5.2.jar"

return {
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
            width = math.floor(340 * width / 1920),
            height = height
        },
        wide = {
            key = "X",
            width = width,
            height = math.floor(340 * height / 1080)
        },
        tall = {
            key = "C",
            width = 340,
            height = 16384,
            sensitivity = 0.38731546
        },
    },
    apps = {
        calc = {
            pattern = "[N]injabrain.*jar",
            command = "java -jar " .. calc_path,
        },
        calc_display = {
            pattern = "[e]ww.*daemon",
            command = config_path .. "/calc/scripts/start-display.sh",
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

