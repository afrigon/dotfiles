local paths = {}

paths.home = os.getenv("HOME")
paths.config = os.getenv("XDG_CONFIG_HOME") or (paths.home .. "/.config")
paths.waywall = paths.config .. "/waywall"
paths.assets = paths.waywall .. "/assets"
paths.textures = paths.assets .. "/textures"
paths.shaders = paths.assets .. "/shaders"
paths.ninbot = "ninbot-wrapper"
paths.overlay = os.getenv("XDG_RUNTIME_DIR") .. "/ninbot-wrapper/overlay.png"
paths.state_output = paths.home .. "/.local/share/PrismLauncher/instances/mcsr/minecraft/wpstateout.txt"

return paths
