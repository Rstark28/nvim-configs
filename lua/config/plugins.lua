-- ============================================================================
-- Plugin Manager Setup - Using lazy.nvim
-- ============================================================================

-- Bootstrap lazy.nvim (install if not present)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ 
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath 
    })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    -- ============================================================================
    -- COLORSCHEME
    -- ============================================================================
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000, 
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,

                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = {},
                    variables = {},
                },

                dim_inactive = false,

                -- Custom color overrides
                on_colors = function(colors)
                    colors.error = "#FF6A00" -- Custom orange instead of red
                end,
            })
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },

    -- ============================================================================
    -- FILE TREE
    -- ============================================================================
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,
                },
            })
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
        end,
    },

    -- ============================================================================
    -- FUZZY FINDER
    -- ============================================================================
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('telescope').setup({})

            local builtin = require('telescope.builtin')

            -- File finder keymaps
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
            vim.keymap.set("n", "<leader>fr", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader>fh", function()
                builtin.find_files({ hidden = true })
            end)
        end,
    },

    -- ============================================================================
    -- AUTO PAIRS
    -- ============================================================================
    {
        "altermo/ultimate-autopair.nvim",
        event = { "InsertEnter" },
        config = true,
    },

    -- ============================================================================
    -- GITHUB COPILOT 
    -- ============================================================================
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = "<M-l>", -- Press Alt + L to accept ghost text
                        next = "<M-]>",   -- Alt + ] for next suggestion
                        prev = "<M-[>",   -- Alt + [ for previous suggestion
                        dismiss = "<C-]>",-- Ctrl + ] to clear suggestion
                    },
                },
                panel = { enabled = false },
            })
        end,
    },

    -- ============================================================================
    -- LSP & AUTOCOMPLETION
    -- ============================================================================
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",           -- LSP installer
            "williamboman/mason-lspconfig.nvim", -- Bridge between mason and lspconfig
            "hrsh7th/nvim-cmp",                 -- Completion engine
            "hrsh7th/cmp-nvim-lsp",             -- LSP completion source
            "hrsh7th/cmp-buffer",               -- Buffer completion source
            "hrsh7th/cmp-path",                 -- Path completion source
        },

        config = function()
            -- LSP keymaps (activated when LSP attaches to buffer)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(event)
                    local opts = { buffer = event.buf }

                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<leader>k', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
                end,
            })

            -- Setup Mason (LSP installer)
            require("mason").setup()

            -- Setup Mason-LSPConfig (manages LSP servers)
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "pyright",       -- Python
                    "clangd",        -- C/C++
                    "rust_analyzer", -- Rust
                },
                automatic_installation = true,

                handlers = {
                    -- Default handler for all servers
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        })
                    end,

                    -- Special configuration for Lua LSP
          lua_ls = function()
              require("lspconfig").lua_ls.setup({
                  capabilities = require("cmp_nvim_lsp").default_capabilities(),
                  settings = {
                      Lua = {
                          diagnostics = {
                              globals = { "vim" }, -- Recognize vim global
                          },
                      },
                  },
              })
          end,
          rust_analyzer = function()
              require("lspconfig").rust_analyzer.setup({
                  capabilities = require("cmp_nvim_lsp").default_capabilities(),
                  settings = {
                      ["rust-analyzer"] = {
                          cargo = {
                              allFeatures = true,
                          },
                          check = {
                              command = "clippy",
                          },
                      },
                  },
              })
          end,
      },
  })

  -- Setup completion
  local cmp = require("cmp")

  cmp.setup({
      sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
      },

      mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                  cmp.select_next_item()
              else
                  fallback()
              end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                  cmp.select_prev_item()
              else
                  fallback()
              end
          end, { "i", "s" }),
      }),
  })
    end,
},

-- ============================================================================
-- SYNTAX HIGHLIGHTING
-- ============================================================================
{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },

    opts = {
        ensure_installed = { 
            "lua", "vim", "vimdoc",
            "python", 
            "c", "cpp", 
            "html", "css", 
            "json", "yaml",
            "rust"
        },

        auto_install = true,
        sync_install = false,

        highlight = { 
            enable = true,
            additional_vim_regex_highlighting = false,
        },

        indent = { 
            enable = true 
        },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<C-space>",
                node_incremental = "<C-space>",
                node_decremental = "<bs>",
            },
        },
    },
},

-- ============================================================================
-- SMEAR CURSOR
-- ============================================================================
{
    "sphamba/smear-cursor.nvim",
    opts = {
        smear_between_buffers = true,
        smear_between_neighbor_lines = true,
        legacy_computing_symbols_support = false,
    },
},


-- ============================================================================
-- LATEX
-- ============================================================================
{
    "lervag/vimtex",
    ft = "tex",
    config = function()

        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_view_method = "skim"

        vim.g.vimtex_compiler_latexmk = {
            options = { "-pdf", "-pvc", "-interaction=nonstopmode", "-synctex=1" }
        }

        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1

        vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "Compile" })
        vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "View PDF" })
        vim.keymap.set("n", "<leader>lk", "<cmd>VimtexStop<CR>", { desc = "Stop compile" })

    end,
},

-- ============================================================================
-- DAP (LLDB)
-- ============================================================================
{
    "mfussenegger/nvim-dap",
    config = function()
        local dap = require("dap")

        -- Configure LLDB debugger
        local function find_codelldb()
            local candidates = {
                -- mason path
                vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
                -- common Homebrew paths
                "/opt/homebrew/bin/codelldb",
                "/usr/local/bin/codelldb",
                "/usr/bin/codelldb",
                -- fallback to PATH name
                "codelldb",
            }
            for _, p in ipairs(candidates) do
                if vim.loop.fs_stat(p) then
                    return p
                end
                if vim.fn.executable(p) == 1 then
                    return p
                end
            end
            return nil
        end

        local codelldb_cmd = find_codelldb()
        if codelldb_cmd then
            dap.adapters.lldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_cmd,
                    args = { "--port", "${port}" },
                },
            }
        else
            -- Fallback to lldb-vscode if available, otherwise try lldb-vscode in PATH
            local fallback = nil
            if vim.fn.executable("lldb-vscode") == 1 then
                fallback = "lldb-vscode"
            elseif vim.fn.executable("lldb") == 1 then
                fallback = "lldb"
            end

            if fallback then
                dap.adapters.lldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = fallback,
                        args = { "--port", "${port}" },
                    },
                }
            else
                -- Last resort: use codelldb name and hope user installs it
                dap.adapters.lldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = "codelldb",
                        args = { "--port", "${port}" },
                    },
                }
            end
        end

        -- Debug config for C/C++/Rust
        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "lldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/")
                end,
                cwd = "${workspaceFolder}",
                args = {}, 
            },
        }

        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        -- Quick keymaps
        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/Continue" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
    end,
},

-- Debug UI (shows variables, stack, etc.)
{
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()

        -- Auto-open UI when debugging starts, close when done
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        -- Manual toggle with <leader>du
        vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
    end,
},

}, {
    -- Lazy.nvim configuration
    install = { colorscheme = { "tokyonight-night" } },
    checker = { enabled = true }, -- Check for plugin updates
})
