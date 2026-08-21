import os
import shutil
import subprocess
import threading

import obspython as obs

destination = "/mnt/data/obs-output"


def script_description():
    return "Remuxes finished recordings to mp4 in " + destination


def script_load(settings):
    obs.obs_frontend_add_event_callback(on_event)


def on_event(event):
    if event == obs.OBS_FRONTEND_EVENT_RECORDING_STOPPED:
        path = obs.obs_frontend_get_last_recording()
        threading.Thread(target=archive, args=(path,), daemon=True).start()


def notify(summary, body, urgency="normal"):
    subprocess.run(["notify-send", "--urgency", urgency,
                    "--app-name", "OBS", summary, body])


def archive(path):
    if not path or not os.path.isfile(path):
        return
    name = os.path.splitext(os.path.basename(path))[0]
    target = os.path.join(destination, name + ".mp4")
    notify("Archiving recording", "Remuxing " + os.path.basename(path))
    # hvc1 tag: QuickTime and some players refuse HEVC in mp4 without it
    result = subprocess.run(
        ["ffmpeg", "-nostdin", "-y", "-i", path,
         "-map", "0", "-c", "copy", "-tag:v", "hvc1", target],
        capture_output=True,
    )
    if result.returncode == 0:
        os.remove(path)
        notify("Recording archived", target)
    else:
        if os.path.exists(target):
            os.remove(target)
        shutil.move(path, os.path.join(destination, os.path.basename(path)))
        notify("Remux failed", "MKV moved unconverted to " + destination,
               urgency="critical")
