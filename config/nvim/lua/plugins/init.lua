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

-- lazy packages setup
lazy.setup({
    {
        'nvim-telescope/telescope.nvim',                -- Fuzzy finder
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    {
        "nvim-treesitter/nvim-treesitter",              -- Treesitter 
        config = function(_, opts)
            vim.cmd("TSUpdate")

            require('nvim-treesitter.configs').setup(opts)
        end,
        opts = {
            auto_install = true,
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            },
            incremental_selection = {
                enable = true
            }
        }
    },

    {
        "nvim-tree/nvim-tree.lua",                                    -- File Explorer
        config = function()
            require("nvim-tree").setup {
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                }
            }
        end
    },

    "nvim-treesitter/nvim-treesitter-context",         -- Sticky Context

    {
        "mason-org/mason-lspconfig.nvim",              -- Language Server Manager
        opts = {
            ensure_installed = {
                "clangd",                              -- c/c++
                "gopls",                               -- go
                "kotlin_language_server",              -- kotlin
                "lua_ls",                              -- lua
                "pyright",                             -- python
                "rust_analyzer",                       -- rust
                "sqlls",                               -- sql
            }
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },

    {
        "hrsh7th/nvim-cmp",                             -- Completion
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip"
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    {name = "nvim_lsp"},
                    {name = "path"},
                    -- {name = "buffer", keyword_length = 3},
                    {name = "luasnip", keyword_length = 2},
                })
            })
        end
    },

    "tpope/vim-fugitive",                               -- Git integration

    {
        "mbbill/undotree",                              -- Undo Tree
        config = function()
            vim.g.undotree_SplitWidth = 40
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_DiffpanelHeight = 12
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_HelpLine = 0
        end
    },

    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            use_diagnostic_signs = true
        }
    },

    {
        "nvim-lualine/lualine.nvim",                     -- Status Line
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                icons_enabled = true,
                component_separators = "",
                section_separators = { left = "", right = "" },
                disabled_filetypes = { "undotree", "Trouble", "fugitive" },
            },
            sections = {
                lualine_a = {{
                    "mode",
                    fmt = function(str)
                        return str:sub(1,1)
                    end
                }},
                lualine_b = { "branch", "diagnostics" },
                lualine_c = {{
                    "filename",
                    file_status = false,
                    path = 4
                }},
                lualine_x = { "filetype" },
                lualine_y = { "selectioncount", "searchcount", "location" },
                lualine_z = {}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        file_status = false,
                        path = 4
                    }
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            }
        }
    },

    {
        "ThePrimeagen/harpoon",                         -- Fast File Navigation
        config = function()
            require("harpoon").setup()

            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<Leader>h", ui.toggle_quick_menu)

            vim.keymap.set("n", "<Leader>1", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<Leader>2", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<Leader>3", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<Leader>4", function() ui.nav_file(4) end)
        end
    },

    "norcalli/nvim-colorizer.lua",                      -- Colorizer

    "github/copilot.vim",                               -- Github Copilot

    "xiyaowong/transparent.nvim",                       -- Transparent Background

    {
        "rose-pine/neovim",                             -- Rose Pine Theme
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        opts = {
            variant = "moon",
            dark_variant = "moon",

            groups = {
                background = "#191724"
            }
        }
    }
})

-- setup signs for diagnostics
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.cmd("colorscheme rose-pine")
vim.cmd("TransparentEnable")

-- vim.lsp.enable('sourcekit')

