-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = "\\"
vim.opt.expandtab = true
-- vim.opt.tabstop = 4 -- [Neo]vim devs recommend leaving this as is, i.e. 8

--[[ These two lines are good, but I need to figure out how to leave the existing set-up alone
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
--]]

vim.opt.colorcolumn = "80"
vim.opt.relativenumber = false
