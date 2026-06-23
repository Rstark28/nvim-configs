local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "storm",
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                },
            })
            vim.cmd.colorscheme("tokyonight-storm")
        end,
    },

    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({ view = { width = 30 } })
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true })
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({})
            local b = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", b.find_files)
            vim.keymap.set("n", "<leader>fg", b.git_files)
            vim.keymap.set("n", "<leader>fr", b.live_grep)
            vim.keymap.set("n", "<leader>fb", b.buffers)
            vim.keymap.set("n", "<leader>fh", function() b.find_files({ hidden = true }) end)
        end,
    },

    -- Auto pairs
    { "altermo/ultimate-autopair.nvim", event = "InsertEnter", config = true },

    -- GitHub Copilot
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
                    keymap = { accept = "<C-l>", next = "<C-]>", prev = "<M-[>" },
                },
                panel = { enabled = false },
            })
        end,
    },

    -- LSP + completion
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local o = { buffer = event.buf }
                    vim.keymap.set("n", "K",          vim.lsp.buf.hover,        o)
                    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,   o)
                    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,  o)
                    vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, o)
                    vim.keymap.set("n", "go",         vim.lsp.buf.type_definition, o)
                    vim.keymap.set("n", "gr",         vim.lsp.buf.references,   o)
                    vim.keymap.set("n", "<leader>k",  vim.diagnostic.open_float, o)
                    vim.keymap.set("n", "<F2>",       vim.lsp.buf.rename,       o)
                    vim.keymap.set("n", "<F4>",       vim.lsp.buf.code_action,  o)
                end,
            })

            require("mason").setup()

            local caps = require("cmp_nvim_lsp").default_capabilities()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "clangd", "rust_analyzer" },
                automatic_installation = true,
                handlers = {
                    function(server)
                        require("lspconfig")[server].setup({ capabilities = caps })
                    end,
                    lua_ls = function()
                        require("lspconfig").lua_ls.setup({
                            capabilities = caps,
                            settings = { Lua = { diagnostics = { globals = { "vim" } } } },
                        })
                    end,
                    rust_analyzer = function()
                        require("lspconfig").rust_analyzer.setup({
                            capabilities = caps,
                            settings = {
                                ["rust-analyzer"] = {
                                    cargo = { allFeatures = true },
                                    check = { command = "clippy" },
                                },
                            },
                        })
                    end,
                },
            })

            local cmp = require("cmp")
            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"]     = cmp.mapping.select_prev_item(),
                    ["<C-j>"]     = cmp.mapping.select_next_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item() else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item() else fallback() end
                    end, { "i", "s" }),
                }),
            })
        end,
    },

    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc",
                    "python", "c", "cpp", "rust",
                    "html", "css", "json", "yaml",
                },
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection    = "<C-space>",
                        node_incremental  = "<C-space>",
                        node_decremental  = "<bs>",
                    },
                },
            })

        end,
    },

    -- Smear cursor
    {
        "sphamba/smear-cursor.nvim",
        opts = {
            smear_between_buffers = true,
            smear_between_neighbor_lines = true,
            legacy_computing_symbols_support = false,
        },
    },

    -- LaTeX
    {
        "lervag/vimtex",
        ft = "tex",
        config = function()
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_view_method = "skim"
            vim.g.vimtex_compiler_latexmk = {
                options = { "-pdf", "-pvc", "-interaction=nonstopmode", "-synctex=1" }
            }
            vim.g.vimtex_view_skim_sync     = 1
            vim.g.vimtex_view_skim_activate = 1
            vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "Compile" })
            vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>",    { desc = "View PDF" })
            vim.keymap.set("n", "<leader>lk", "<cmd>VimtexStop<CR>",    { desc = "Stop compile" })
        end,
    },

    -- DAP debugger (LLDB via codelldb)
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            local codelldb = (function()
                for _, p in ipairs({
                    vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
                    "/opt/homebrew/bin/codelldb",
                    "/usr/local/bin/codelldb",
                    "codelldb",
                }) do
                    if vim.uv.fs_stat(p) or vim.fn.executable(p) == 1 then return p end
                end
            end)()

            dap.adapters.lldb = {
                type = "server",
                port = "${port}",
                executable = { command = codelldb or "codelldb", args = { "--port", "${port}" } },
            }

            dap.configurations.cpp = {{
                name    = "Launch",
                type    = "lldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/")
                end,
                cwd  = "${workspaceFolder}",
                args = {},
            }}
            dap.configurations.c    = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue,          { desc = "Start/Continue" })
            vim.keymap.set("n", "<leader>do", dap.step_over,         { desc = "Step over" })
            vim.keymap.set("n", "<leader>di", dap.step_into,         { desc = "Step into" })
        end,
    },

    -- DAP UI
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"]     = dapui.close
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
        end,
    },

}, {
    install = { colorscheme = { "tokyonight-storm" } },
    checker  = { enabled = true },
})
