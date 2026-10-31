return {
    entity_counter = {
        capture = { x = 14, y = 38, w = 23, h = 7 },
        -- Room around the capture for the outline, in source pixels.
        margin = 1,
        scale = 8,
        position = { x = 1530, y = 626 }
    },
    block_coordinates = {
        capture = { x = 136, y = 404, w = 480, h = 28 },
        -- A multiple of F3's 4 px font pixel, so the 0.75 scale keeps every glyph pixel 3 px wide.
        margin = 4,
        scale = 0.75
    }
}
