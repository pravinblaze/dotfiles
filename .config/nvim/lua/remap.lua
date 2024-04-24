vim.g.mapleader = " "

-- Save and quit
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>s", ":w<CR>")
vim.keymap.set("n", "<leader>Q", ":q!<CR>")

-- Cycle buffers
vim.keymap.set("n", "<leader>b", ":bn<CR>")

-- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("v", "<leader>p", [["+p]])

-- Delete without replacing default clipboard
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

