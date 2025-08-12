-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- This may be throwing an error
-- vim.api.nvim_create_autocmd("BufEnter,BufWritePost", {
--     callback = function(args)
--         vim.diagnostic.enable(vim.bo[args.buf].filetype ~= "markdown" and true or false)
--     end,
-- })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufLeave" }, {
    pattern = { "*.md", "*.markdown" },
    callback = function()
        vim.diagnostic.enable(false, { bufnr = 0 })
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    -- pattern = { "*.md", "*.markdown" },
    pattern = { "markdown" },
    callback = function()
        vim.b.autoformat = false
    end,
})
