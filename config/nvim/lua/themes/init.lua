require("themes.rosepine")

local colorscheme = "rose-pine"

local status, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status then
  return
end
