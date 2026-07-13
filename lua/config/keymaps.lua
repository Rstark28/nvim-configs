local keymap = vim.keymap.set

local opts = { noremap = true, silent = true }

-- Window Navigation 
keymap("n", "<C-h>", "<C-w>h", opts)                         -- Move to left window
keymap("n", "<C-j>", "<C-w>j", opts)                         -- Move to bottom window
keymap("n", "<C-k>", "<C-w>k", opts)                         -- Move to top window
keymap("n", "<C-l>", "<C-w>l", opts)                         -- Move to right window

-- Better scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)                        -- Scroll down and center
keymap("n", "<C-u>", "<C-u>zz", opts)                        -- Scroll up and center

-- Window Resizing
keymap("n", "<A-Up>", ":resize +2<CR>", opts)                -- Increase window height
keymap("n", "<A-Down>", ":resize -2<CR>", opts)              -- Decrease window height
keymap("n", "<A-Right>", ":vertical resize -2<CR>", opts)    -- Decrease window width
keymap("n", "<A-Left>", ":vertical resize +2<CR>", opts)     -- Increase window width

-- Buffer Navigation
keymap("n", "<S-l>", ":bnext<CR>", opts)                     -- Move to next buffer
keymap("n", "<S-h>", ":bprevious<CR>", opts)                 -- Move to previous buffer
keymap("n", "Q", "<nop>", opts)

-- Move selected lines up/down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)               -- Move selection down
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)               -- Move selection up

-- Paste config (don't override the default register)
keymap("v", "p", '"_dP', opts)

-- Move selected block up/down
keymap("x", "J", ":move '>+1<CR>gv=gv", opts)                -- Move selection down
keymap("x", "K", ":move '<-2<CR>gv=gv", opts)                -- Move selection up


-- Terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { silent = true }) -- Move to left window
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { silent = true }) -- Move to bottom window
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { silent = true }) -- Move to top window
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { silent = true }) -- Move to right window

-- <leader>e  - Toggle file tree
-- <leader>ff - Find files
-- <leader>fg - Find git files
-- <leader>fr - Live grep (search in files)
-- <leader>fb - Find buffers
-- <leader>fh - Find hidden files
