-- initialize lazy package manager
local lazy_dir = vim.fn.stdpath("data") .. "/lazy"
local lazy_path = lazy_dir .. "/lazy.nvim"

if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazy_path
  })
end

vim.opt.rtp:prepend(lazy_path)

local status, lazy = pcall(require, "lazy")

if not status then
  return
end

-- lazy setup
lazy.setup({
  "nvim-treesitter/nvim-treesitter",
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
	require("themes")
    end
  }
})

