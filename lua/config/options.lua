-- ============================================================================
-- Editor Options - Basic Neovim settings
-- ============================================================================

-- Set leader key to space (must be set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General editor settings
local options = {
  -- File handling
  backup = false,        -- Don't create backup files
  writebackup = false,   -- Don't create backup before overwriting
  swapfile = false,      -- Don't create swap files
  undofile = true,       -- Enable persistent undo
  
  -- Visual settings
  number = true,         -- Show line numbers
  termguicolors = true,  -- Enable 24-bit colors
  cursorline = false,    -- Don't highlight current line
  wrap = false,          -- Don't wrap long lines
  scrolloff = 4,         -- Keep 4 lines above/below cursor
  sidescrolloff = 4,     -- Keep 4 columns left/right of cursor
  signcolumn = "yes",    -- Always show sign column
  
  -- Search settings
  hlsearch = true,       -- Highlight search results
  incsearch = true,      -- Show search matches as you type
  ignorecase = true,     -- Ignore case in search
  smartcase = true,      -- Use case-sensitive if capital letters
  
  -- Indentation
  expandtab = true,      -- Use spaces instead of tabs
  shiftwidth = 4,        -- Number of spaces for indentation
  tabstop = 4,          -- Number of spaces for tab character
  smartindent = true,    -- Smart auto-indenting
  
  -- Window behavior
  splitbelow = true,     -- Open horizontal splits below
  splitright = true,     -- Open vertical splits to the right
  
  -- Completion
  completeopt = { "menuone", "noselect" },  -- Better completion
  pumheight = 10,        -- Limit completion menu height
  
  -- Interface
  showmode = false,      -- Don't show mode (we have statusline)
  cmdheight = 2,         -- Command line height
  timeoutlen = 1000,     -- Time to wait for key sequences
  updatetime = 300,      -- Faster completion
  mouse = "a",           -- Enable mouse support
  clipboard = "unnamedplus", -- Use system clipboard
}

-- Apply all options
for option, value in pairs(options) do
  vim.opt[option] = value
end

-- File-specific settings
vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

-- Use 2 spaces for web development files
vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "html", "css", "javascript", "typescript", "lua", "json", "yaml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Disable auto-commenting on new lines
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})
