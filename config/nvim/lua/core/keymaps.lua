local keymap = vim.keymap.set

-- leader key
vim.g.mapleader = " "
keymap("n", "<Space>", "<Nop>")

-- dick flattening
-- keymap({ "n", "i", "v" }, "<Up>", "<Nop>")
-- keymap({ "n", "i", "v" }, "<Down>", "<Nop>")
-- keymap({ "n", "i", "v" }, "<Left>", "<Nop>")
-- keymap({ "n", "i", "v" }, "<Right>", "<Nop>")

-- exit insert mode
keymap("i", "jk", "<Esc>")
keymap("i", "<C-c>", "<Esc>")
keymap("n", "<C-c>", "<silent><C-c>")

-- prevent from going into background mode
keymap("", "<C-z>", "<Nop>")

-- paste without replacing clipboard
keymap("v", "p", "\"_dP")

-- preserve selection after indent
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- move line selection up and down
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- re-center after a page jump
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- re-center after search
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- split window
keymap("n", "<Leader>-", "<cmd>sp<CR>")
keymap("n", "<Leader>=", "<cmd>vs<CR>")

-- window movement (disabled, handled via vim-tmux-navigator)
-- keymap("n", "<Leader>h", "<C-w>h")
-- keymap("n", "<Leader>j", "<C-w>j")
-- keymap("n", "<Leader>k", "<C-w>k")
-- keymap("n", "<Leader>l", "<C-w>l")

-- LSP Commands
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function()
        keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
        keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
        keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
        keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
        keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
        -- keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
        keymap("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        keymap("n", "<Leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
    end
})

-- LEADER Commands

-- select all
keymap("n", "<Leader>a", "ggvG")

-- save
keymap("n", "<Leader>s", "<cmd>w<CR>")

-- save and quit
keymap("n", "<Leader>w", "<cmd>wq<CR>")

-- quit without saving
keymap("n", "<Leader>q", function()
    if not vim.bo.modified then
        vim.cmd("q")
    end

    local r = vim.fn.input("Quit without saving? [y/N]: ")

    if r == "y" then
        vim.cmd("q!")
    end
end)

-- replace word under cursor
keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- delete without replacing clipboard
keymap({"n", "v"}, "<Leader>d", "\"_dd")

-- format the buffer
keymap("n", "<leader>f", vim.lsp.buf.format)

-- find a search term in the working directory using telescope
keymap("n", "<Leader>F", "<cmd>Telescope live_grep<CR>")

-- quickly open git file using telescope
keymap("n", "<Leader>o", "<cmd>Telescope git_files<CR>")

-- quickly open file using telescope
keymap("n", "<Leader>p", "<cmd>Telescope find_files<CR>")


-- togge undo tree
keymap("n", "<Leader>u", "<cmd>UndotreeToggle<CR>")

-- open fugitive, git status
keymap("n", "<Leader>g", "<cmd>Git<CR>")

-- open trouble
keymap("n", "<Leader>e", "<cmd>Trouble diagnostics<CR>")

-- run the current file
keymap("n", "<Leader>r", "<cmd>VimuxRunCommand('clear;' . expand('%:p'))<CR>")

-- prompt for a command to run
keymap("n", "<Leader>R", "<cmd>VimuxPromptCommand<CR>")

-- run last command executed by VimuxRunCommand
keymap("n", "<Leader><CR>", "<cmd>VimuxRunLastCommand<CR>")

