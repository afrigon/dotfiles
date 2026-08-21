import glob
import subprocess

import obspython as obs

SCENE_NAME = "Elgato HD60 X"
ADAPTER_NAME = "NVIDIA i2c adapter 4 at 1:00.0"
INPUT_HDMI = "0x11"
INPUT_DISPLAY_PORT = "0x0f"

elgato_active = False


def find_bus():
    for path in glob.glob("/sys/bus/i2c/devices/i2c-*/name"):
        with open(path) as file:
            if ADAPTER_NAME in file.read():
                return path.removeprefix("/sys/bus/i2c/devices/i2c-").removesuffix("/name")
    return None


def set_input(value):
    bus = find_bus()
    if bus is None:
        return
    subprocess.Popen(["ddcutil", "--bus", bus, "setvcp", "60", value])


def on_event(event):
    global elgato_active
    if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED:
        scene = obs.obs_frontend_get_current_scene()
        name = obs.obs_source_get_name(scene)
        obs.obs_source_release(scene)
        if name == SCENE_NAME and not elgato_active:
            elgato_active = True
            set_input(INPUT_HDMI)
        elif name != SCENE_NAME and elgato_active:
            elgato_active = False
            set_input(INPUT_DISPLAY_PORT)
    elif event == obs.OBS_FRONTEND_EVENT_EXIT and elgato_active:
        elgato_active = False
        set_input(INPUT_DISPLAY_PORT)


def script_description():
    return "Switches the monitor input to HDMI while the Elgato scene is active, back to DisplayPort otherwise."


def script_load(settings):
    obs.obs_frontend_add_event_callback(on_event)
