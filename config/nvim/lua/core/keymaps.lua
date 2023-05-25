local keymap = vim.keymap.set

-- leader key
vim.g.mapleader = " "
keymap("n", "<Space>", "<Nop>")

-- exit insert mode
keymap("i", "jk", "<Esc>")
keymap("i", "<C-c>", "<Esc>")


-- paste without replacing clipboard
keymap("v", "p", '"_dP')

-- preserve selection after indent
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- move line selection up and down
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- re-center after a page jump
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")


-- LEADER Commands

-- select all
keymap("n", "<Leader>a", "ggvG")

-- save
keymap("n", "<Leader>s", "<cmd>w<CR>")

-- save and quit
keymap("n", "<Leader>w", "<cmd>wq<CR>")
