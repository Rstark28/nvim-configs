local keymap = vim.keymap.set

-- Helper for mapping options
local opts = { noremap = true, silent = true }

-- Window Navigation 
keymap("n", "<C-h>", "<C-w>h", opts)  -- Move to left window
keymap("n", "<C-j>", "<C-w>j", opts)  -- Move to bottom window
keymap("n", "<C-k>", "<C-w>k", opts)  -- Move to top window
keymap("n", "<C-l>", "<C-w>l", opts)  -- Move to right window

-- Better scrolling (keep cursor centered)
keymap("n", "<C-d>", "<C-d>zz", opts)  -- Scroll down and center
keymap("n", "<C-u>", "<C-u>zz", opts)  -- Scroll up and center

-- Window Resizing
keymap("n", "<A-Up>", ":resize +2<CR>", opts)
keymap("n", "<A-Down>", ":resize -2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize -2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize +2<CR>", opts)

-- Buffer Navigation
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Disable Q (ex mode)
keymap("n", "Q", "<nop>", opts)

-- Move selected lines up/down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)  -- Move selection down
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)  -- Move selection up

-- Better paste (don't overwrite register)
keymap("v", "p", '"_dP', opts)


-- Move selected block up/down
keymap("x", "J", ":move '>+1<CR>gv=gv", opts)
keymap("x", "K", ":move '<-2<CR>gv=gv", opts)

-- Better paste in visual block mode
keymap("x", "p", '"_dP', opts)

-- Easy terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { silent = true })
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { silent = true })
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { silent = true })
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { silent = true })

-- <leader>e  - Toggle file tree
-- <leader>ff - Find files
-- <leader>fg - Find git files
-- <leader>fr - Live grep (search in files)
-- <leader>fb - Find buffers
-- <leader>fh - Find hidden files
