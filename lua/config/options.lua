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
  number = true, 
  termguicolors = true,
  cursorline = false,
  wrap = false,
  scrolloff = 4,
  sidescrolloff = 4,
  signcolumn = "yes",
  
  -- Search settings
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  
  -- Indentation
  expandtab = true,
  shiftwidth = 4,
  tabstop = 4,
  smartindent = true,
  
  -- Window behavior
  splitbelow = true,
  splitright = true,
  
  -- Completion
  completeopt = { "menuone", "noselect" }, 
  pumheight = 10,
  
  -- Interface
  showmode = false,
  cmdheight = 2,
  timeoutlen = 1000,
  updatetime = 300,
  mouse = "a",
  clipboard = "unnamedplus",
}

for option, value in pairs(options) do
  vim.opt[option] = value
end

-- Disable auto-commenting on new lines
local format_group = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = format_group,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Metal shading language
vim.filetype.add({ extension = { metal = "metal" } })
vim.treesitter.language.register("cpp", "metal")

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
