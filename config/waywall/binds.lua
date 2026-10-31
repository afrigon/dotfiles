local waywall = require("waywall")

local gameplay = {
    ["CapsLock"] = "F3",
    ["F3"] = "F24",
    ["G"] = "D",
    ["D"] = "G",
    ["B"] = "A",
    ["A"] = "B",
    ["Tab"] = "F23",
    ["F1"] = "Tab",
    ["F10"] = "F1"
}

local menu = {
    ["CapsLock"] = "F3",
    ["F3"] = "F24",
    ["Tab"] = "F23",
    ["F1"] = "Tab",
    ["F10"] = "F1"
}

local active_remaps = {}

local function apply(remaps)
    local merged = {}

    for source, output in pairs(remaps) do
        merged[source] = output
    end

    for source, output in pairs(active_remaps) do
        if remaps[source] ~= output and waywall.get_key(output) then
            merged[source] = output
        end
    end

    for source, output in pairs(remaps) do
        if active_remaps[source] ~= output and waywall.get_key(source) then
            merged[source] = active_remaps[source]
        end
    end

    active_remaps = merged
    waywall.set_remaps(merged)
end

local function configure_gameplay()
    apply(gameplay)
end

local function configure_menu()
    apply(menu)
end

return {
    configure_gameplay = configure_gameplay,
    configure_menu = configure_menu
}
