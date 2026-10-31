local waywall = require("waywall")
local paths = require("paths")
local window_size = require("window")

local POLL_INTERVAL_MS = 100
local PNG_WIDTH_OFFSET = 16
local PNG_HEIGHT_OFFSET = 20

local image = nil
local shown = nil
local visible = true

local function read(path)
    local file = io.open(path, "rb")

    if not file then
        return nil
    end

    local bytes = file:read("*a")
    file:close()

    return bytes
end

local function big_endian_u32(bytes, offset)
    local a, b, c, d = bytes:byte(offset + 1, offset + 4)

    return ((a * 256 + b) * 256 + c) * 256 + d
end

local function show(bytes)
    local width = big_endian_u32(bytes, PNG_WIDTH_OFFSET)
    local height = big_endian_u32(bytes, PNG_HEIGHT_OFFSET)
    local replacement = waywall.image(paths.overlay, {
        dst = { x = 0, y = window_size.height - height, w = width, h = height }
    })

    if image then
        image:close()
    end

    image = replacement
    shown = bytes
end

-- waywall loads an image once and cannot reload it, so changes are picked up by polling.
local function follow()
    while true do
        local bytes = read(paths.overlay)

        if visible and bytes and bytes ~= shown then
            show(bytes)
        end

        waywall.sleep(POLL_INTERVAL_MS)
    end
end

local function toggle()
    visible = not visible

    if image then
        image:close()
        image = nil
    end

    shown = nil
end

local function start()
    waywall.exec(paths.ninbot .. " " .. paths.overlay .. " " .. paths.state_output)
end

-- waywall takes the first window it sees for Minecraft, so Ninjabrain Bot must open after it.
local function start_after_minecraft()
    if pcall(waywall.state) then
        start()
        return
    end

    local cancel
    cancel = waywall.listen("state", function()
        cancel()
        start()
    end)
end

local function on_load()
    start_after_minecraft()
    follow()
end

local function register()
    waywall.listen("load", on_load)
end

return {
    register = register,
    toggle = toggle
}
