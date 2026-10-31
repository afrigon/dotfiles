local waywall = require("waywall")
local mirrors = require("mirrors")

-- F3 draws a font pixel as 4 screen pixels at GUI scale 4; the ninbot line draws one as 3.
local SCALE = 3 / 4
local PADDING_TOP = 3
local PADDING_RIGHT = 3
local PADDING_LEFT = 3
local CONTENT_HEIGHT = 24
local SEGMENT_GAP = 12
-- The ninbot line opens with the boat dot in a square, so its coordinates start one slot later.
local BOAT_SLOT = CONTENT_HEIGHT
local SEPARATOR_WIDTH = 3
local SEPARATOR_ADVANCE = 6
local BACKDROP_DEPTH = 0
local CONTENT_DEPTH = 1
local F3_TEXT = "#DDDDDD"
local SEPARATOR_COLOR = "#E0E0E0"

local sections = { mirrors.block_coordinates, mirrors.entity_count, mirrors.surface_height }

local opened = {}

local function open(options)
    table.insert(opened, waywall.mirror(options))
end

local function close()
    for _, mirror in ipairs(opened) do
        mirror:close()
    end

    opened = {}
end

local function separator(x, y)
    open({
        src = mirrors.f3_open.capture,
        dst = { x = x, y = y, w = SEPARATOR_WIDTH, h = CONTENT_HEIGHT },
        depth = CONTENT_DEPTH,
        color_key = { input = F3_TEXT, output = SEPARATOR_COLOR }
    })
end

local function section(mirror, x, y)
    open({
        src = mirror.capture,
        dst = { x = x, y = y, w = mirror.capture.w * SCALE, h = mirror.capture.h * SCALE },
        depth = CONTENT_DEPTH,
        color_key = { input = F3_TEXT, output = F3_TEXT }
    })
end

local function place(bottom)
    close()

    local top = bottom - PADDING_TOP - CONTENT_HEIGHT
    local y = top + PADDING_TOP
    local x = PADDING_LEFT + BOAT_SLOT + SEGMENT_GAP

    for index, mirror in ipairs(sections) do
        if index > 1 then
            x = x + SEGMENT_GAP
            separator(x, y)
            x = x + SEPARATOR_ADVANCE + SEGMENT_GAP
        end

        section(mirror, x, y)
        x = x + mirror.capture.w * SCALE
    end

    open({
        src = mirrors.f3_open.capture,
        dst = { x = 0, y = top, w = x + PADDING_RIGHT, h = PADDING_TOP + CONTENT_HEIGHT },
        depth = BACKDROP_DEPTH,
        shader = "f3_backdrop",
        color_key = { input = F3_TEXT, output = F3_TEXT }
    })
end

return {
    place = place,
    close = close
}
