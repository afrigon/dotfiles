local status, theme = pcall(require, "rose-pine")

if not status then
  return
end

theme.setup({
  variant = "moon",
  dark_variant = "moon",

  groups = {
    background = "#191724"
  }
})

