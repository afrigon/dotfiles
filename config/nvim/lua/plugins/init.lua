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
        tag = '0.1.0',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    {
        "nvim-treesitter/nvim-treesitter",              -- Treesitter 
        config = function(_, opts)
            vim.cmd("TSUpdate")
            require('nvim-treesitter.configs').setup(opts)
        end,
        opts={
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

    "nvim-treesitter/nvim-treesitter-context",         -- Sticky Context

    {
        "williamboman/mason.nvim",                     -- Language Server Manager
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end
    },

    {
        "williamboman/mason-lspconfig.nvim",           -- Mason LSP Bridge
        opts = {
            ensure_installed = {
                "bashls",                              -- bash
                "clangd",                              -- c/c++
                "cssls",                               -- css
                "dockerls",                            -- docker
                "docker_compose_language_service",     -- docker-compose
                "gopls",                               -- go
                "html",                                -- html
                -- "hls",                                 -- haskell
                "kotlin_language_server",              -- kotlin
                "lua_ls",                              -- lua
                "intelephense",                        -- php
                "pyright",                             -- python
                -- "solargraph",                          -- ruby
                "rust_analyzer",                       -- rust
                "sqlls",                               -- sql
                "tsserver",                            -- typescript
                "zls",                                 -- zig
            }
        }
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

    {
        "neovim/nvim-lspconfig",                        -- LSP Configuration
        config = function()
            local lspconfig = require("lspconfig")
            local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

            require('mason-lspconfig').setup_handlers({
                function(server_name)
                    lspconfig[server_name].setup({
                        capabilities = lsp_capabilities,
                    })
                end,
            })

            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {
                                'vim',
                                'require'
                            },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                        }
                    }
                }
            }

            lspconfig.sourcekit.setup {
                cmd = { "sourcekit-lsp" },
                filetypes = { "swift", "objective-c" },
                root_dir = lspconfig.util.root_pattern("Package.swift", ".git"),
                settings = {
                    sourcekit = {
                        enableSyntaxMap = true,
                        enableKiteCompletions = true,
                        completion = {
                            autoimportThreshold = 100,
                            enableSnippets = true
                        }
                    }
                }
            }
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

    "github/copilot.vim",                               -- Github Copilot

    "christoomey/vim-tmux-navigator",                   -- Tmux Navigation

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
