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
          "lua_ls",     -- Lua
          "pyright",    -- Python
          "clangd",     -- C/C++
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
      "javascript", "typescript", 
      "c", "cpp", 
      "html", "css", 
      "json", "yaml" 
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
}
}, {
  -- Lazy.nvim configuration
  install = { colorscheme = { "tokyonight-night" } },
  checker = { enabled = true }, -- Check for plugin updates
})
