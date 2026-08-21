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
            height = height,
            mirrors = {
                ecounter = {
                    src = { x = 1, y = 37, w = 49, h = 9 },
                    dst = { x = 1530, y = 618, w = 8 * 49, h = 8 * 9 },
                    color_key = {
                        input = "#DDDDDD",
                        output = "#FFFFFF",
                    }
                }
            }
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
            command = config_path .. "/calc/scripts/start-calc.sh",
        },
        calc_display = {
            pattern = "[e]ww --config " .. config_path .. "/calc daemon",
            command = config_path .. "/calc/scripts/start-display.sh",
        },
        obs_state = {
            pattern = "[o]bs-state.sh",
            command = config_path .. "/calc/scripts/obs-state.sh",
        },
        obs_server = {
            pattern = "[h]ttp.server 52534",
            command = "python3 -m http.server 52534 --bind 127.0.0.1 --directory " .. config_path .. "/calc/obs",
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

