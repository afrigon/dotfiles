local waywall = require("waywall")
local paths = require("paths")
local mirrors = require("mirrors")
local window_size = require("window")

local POLL_INTERVAL_MS = 100
local PNG_WIDTH_OFFSET = 16
local PNG_HEIGHT_OFFSET = 20
local LINE_PADDING_LEFT = 3

local image = nil
local shown = nil
local visible = true
local line_height = 0
local fullscreen = true
local coordinates = nil

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

local function place_coordinates()
    if coordinates then
        coordinates:close()
        coordinates = nil
    end

    if not fullscreen then
        return
    end

    local mirror = mirrors.block_coordinates
    local margin = mirror.margin * mirror.scale
    local top = window_size.height - line_height - mirror.capture.h * mirror.scale

    coordinates = waywall.mirror({
        src = {
            x = mirror.capture.x - mirror.margin,
            y = mirror.capture.y - mirror.margin,
            w = mirror.capture.w + 2 * mirror.margin,
            h = mirror.capture.h + 2 * mirror.margin
        },
        dst = {
            x = LINE_PADDING_LEFT - margin,
            y = top - margin,
            w = (mirror.capture.w + 2 * mirror.margin) * mirror.scale,
            h = (mirror.capture.h + 2 * mirror.margin) * mirror.scale
        },
        shader = "block_coordinates",
        color_key = { input = "#DDDDDD", output = "#DDDDDD" }
    })
end

local function set_line_height(height)
    if height ~= line_height then
        line_height = height
        place_coordinates()
    end
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
    set_line_height(height)
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
    set_line_height(0)
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

local function on_resolution()
    local width, height = waywall.active_res()
    fullscreen = width == 0 and height == 0
    place_coordinates()
end

local function on_load()
    place_coordinates()
    start_after_minecraft()
    follow()
end

local function register()
    waywall.listen("load", on_load)
    waywall.listen("resolution", on_resolution)
end

return {
    register = register,
    toggle = toggle
}
