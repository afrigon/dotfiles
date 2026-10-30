local paths = {}

paths.home = os.getenv("HOME")
paths.config = os.getenv("XDG_CONFIG_HOME") or (paths.home .. "/.config")
paths.waywall = paths.config .. "/waywall"
paths.assets = paths.waywall .. "/assets"
paths.textures = paths.assets .. "/textures"
paths.shaders = paths.assets .. "/shaders"
paths.ninbot = paths.home .. "/mcsr/Ninjabrain-Bot-1.5.2.jar"

return paths
