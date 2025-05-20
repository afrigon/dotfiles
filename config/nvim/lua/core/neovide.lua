-- Helper function for transparency formatting
local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
end

-- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
vim.g.neovide_transparency = 0.0
vim.g.transparency = 0.8
vim.g.neovide_background_color = "#0f1117" .. alpha()
vim.g.neovide_window_blurred = true

vim.g.neovide_padding_top    = 16
vim.g.neovide_padding_bottom = 16
vim.g.neovide_padding_right  = 16
vim.g.neovide_padding_left   = 16

vim.g.neovide_floating_corner_radius = 1.0

vim.o.guifont = "Monaspace Neon Var:h14"
