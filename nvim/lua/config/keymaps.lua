-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("t", "<C-h>", "<C-w>h", { desc = "Move to left window", remap = true })
vim.keymap.set("t", "<C-j>", "<C-w>j", { desc = "Move to bottom window", remap = true })
vim.keymap.set("t", "<C-k>", "<C-w>k", { desc = "Move to top window", remap = true })
vim.keymap.set("t", "<C-l>", "<C-w>l", { desc = "Move to right window", remap = true })
