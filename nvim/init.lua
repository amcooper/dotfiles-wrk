HOME = os.getenv("HOME")

if vim.g.vscode then
    local nop = true
else
    -- Configure the clipboard to access the "+ and "* registers
    -- N.B. JavaScript copy buttons on the web do not necessarily work as expected
    vim.opt.clipboard = "unnamedplus,unnamed"

    -- Spaces indentation
    vim.opt.expandtab = true -- converts tabs to spaces
    vim.opt.tabstop = 4 -- tab equals 4 spaces
    vim.opt.shiftwidth = 4 -- indent size in characters

    -- Show whitespace (:list)
    vim.opt.listchars = "eol:¬,tab:>-,trail:~,extends:>,precedes:<,space:·"

    -- Show line numbers
    vim.opt.number = true

    -- Vertically splitting a window (:vsplit) places new window to the right
    vim.opt.splitright = true

    -- Highlight cursor line
    vim.opt.cursorline = true

    -- Enable folding
    vim.opt.foldmethod = "syntax"
    vim.opt.foldlevel = 5
    vim.opt.foldcolumn = "auto:9" -- Flexible width of fold indicators on window's left side

    -- Enable 24-bit RGB color in the TUI
    vim.opt.termguicolors = true

    -- Minimal number of lines kept above and below the cursor
    vim.opt.scrolloff = 5

    -- Turn off highlight search
    vim.opt.hlsearch = false

    -- Temporary file locations
    vim.opt.backupdir = ".backup/," .. HOME .. "/.backup/,/tmp//"
    vim.opt.directory = ".swp/," .. HOME .. "/.swp/,/tmp//"

    -- netrw
    -- This is the workspace file explorer
    vim.g.netrw_winsize = 25 -- width of the file explorer
    vim.g.netrw_liststyle = 3 -- tree style listing

    -- Sane vim split naviagation (via Gaslight blog)
    vim.keymap.set("n", "<c-j>", "<c-w>j", { noremap = true, desc = 'Go to window below' })
    vim.keymap.set("n", "<c-k>", "<c-w>k", { noremap = true, desc = 'Go to window above' })
    vim.keymap.set("n", "<c-h>", "<c-w>h", { noremap = true, desc = 'Go to window to the left' })
    -- N.B. This conflicts with the NetRW directory refresh command. Use the alternative `:e .`.
    vim.keymap.set("n", "<c-l>", "<c-w>l", { noremap = true, desc = 'Go to window to the right' })

    vim.keymap.set("t", "<c-j>", "<c-\\><c-n><c-w>j", { noremap = true, desc = 'Go to window below' })
    vim.keymap.set("t", "<c-k>", "<c-\\><c-n><c-w>k", { noremap = true, desc = 'Go to window above' })
    vim.keymap.set("t", "<c-h>", "<c-\\><c-n><c-w>h", { noremap = true, desc = 'Go to window to the left' })
    vim.keymap.set("t", "<c-l>", "<c-\\><c-n><c-w>l", { noremap = true, desc = 'Go to window to the right' })

    vim.keymap.set(
        {"n", "t"},
        "<leader>z",
        function ()
            -- This restores the UI to the saved layout 'idelayout' (if it exists)
            if vim.fn.exists("idelayout") ~= 0 then
                vim.cmd("exec idelayout")
            end
        end,
        { desc = "Revert window layout" }
    )
end

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local js_based_languages = { "javascript", "typescript" }

require("lazy").setup({
    { import = "plugins.always",     cond = true },
    { import = "plugins.not_vscode", cond = (function() return not vim.g.vscode end) },
})

-- Fix for lua-json5 on macOS
table.insert(vim._so_trails, "/?.dylib")

require"lsp_signature".setup()


--[[ nvim-lspconfig
--]]

-- Setup language servers.
local lua_ls_setup = {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    vim.env.VIMRUNTIME
                },
                -- Slower, but pulls in all of runtime path
                -- library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
                ignoreDir = { "~/.config/local", ".vscode" },
            },
        })
    end,

    settings = {
        Lua = {
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require('lspconfig')
lspconfig.gopls.setup {capabilities = capabilities}
lspconfig.graphql.setup{}
lspconfig.lua_ls.setup(lua_ls_setup)
lspconfig.pyright.setup {capabilities = capabilities}
lspconfig.ts_ls.setup {capabilities = capabilities}
lspconfig.rust_analyzer.setup {
    -- Server-specific settings. See `:help lspconfig-setup`
    capabilities = capabilities,
    settings = {
        ['rust-analyzer'] = {},
    },
}

-- Global mappings : Diagnostics
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Diagnostic: open float' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostic: go to previous' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostic: go to next' })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'Diagnostic: set loclist' })

-- Add a border to LSP windows
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

-- TODO: Is this necessary? Or is signature help being handled with LSPSaga?
--[[
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)
--]]

vim.diagnostic.config{
    float = { border = _border, max_width = 120 }
}
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = function(desc)
            return { buffer = ev.buf, desc = desc }
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('LSP: go to declaration'))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('LSP: go to definition'))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('LSP: hover'))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts('LSP: go to implementation'))
        -- This setting steps on my split navigation setting, so I changed it
        -- to the probably harmless F9.
        -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts(''))
        vim.keymap.set('n', '<F9>', vim.lsp.buf.signature_help, opts('LSP: signature help'))
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts('LSP: add workspace folder'))
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts('LSP: remove workspace folder'))
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts('LSP: list workspace folder'))
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts('LSP: go to type definition'))
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts('LSP: rename token'))
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts('LSP: code action'))
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts('LSP: go to references'))
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts('LSP: format'))
    end,
})

require('gitsigns').setup({
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signcolumn   = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl        = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
        follow_files = true
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
    -- yadm = { enable = false },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, {expr=true, desc='GitSigns: go to next hunk'})

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, {expr=true, desc='GitSigns: go to previous hunk'})

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'GitSigns: stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'GitSigns: reset hunk' })
        map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'GitSigns: stage hunk' })
        map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'GitSigns: reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'GitSigns: stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'GitSigns: undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'GitSigns: reset_buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'GitSigns: preview hunk' })
        map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = 'GitSigns: blame line' })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'GitSigns: toggle current line blame' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'GitSigns: diff this' })
        map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'GitSigns: diff this' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'GitSigns: toggle deleted' })

    end
})

--[[
-- LSPSaga : provides a diverse basket of utilities
--]]
require('lspsaga').setup({
    beacon = {
        enable = true,
        frequency = 7,
    }
})
vim.keymap.set('n', '<leader>si', '<cmd>Lspsaga incoming_calls<CR>')
vim.keymap.set('n', '<leader>so', '<cmd>Lspsaga outgoing_calls<CR>')
vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>')
vim.keymap.set('n', '<leader>sd', '<cmd>Lspsaga peek_definition<CR>')
vim.keymap.set('n', '<leader>sp', '<cmd>Lspsaga peek_type_definition<CR>')
vim.keymap.set('n', '<leader>sx', '<cmd>Lspsaga goto_definition<CR>')
vim.keymap.set('n', '<leader>sg', '<cmd>Lspsaga goto_type_definition<CR>')
vim.keymap.set('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>')
vim.keymap.set('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>')
vim.keymap.set('n', '<leader>sK', '<cmd>Lspsaga hover_doc<CR>')
vim.keymap.set('n', '<leader>sm', '<cmd>Lspsaga finder imp<CR>')
vim.keymap.set('n', '<leader>sf', '<cmd>Lspsaga finder<CR>')
vim.keymap.set('n', '<leader>sl', '<cmd>Lspsaga outline<CR>')
vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<CR>')
vim.keymap.set('n', '<leader>st', '<cmd>Lspsaga term_toggle<CR>')

-- DAP
local dap, dapui = require("dap"), require("dapui")
dapui.setup()

vim.keymap.set('n', '<leader>dt', function() dapui.toggle() end, { desc = 'DAP-UI toggle' })
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Tweak GitSigns blame color
-- This differentiates the cursorline from the git blame text
vim.cmd("highlight GitSignsCurrentLineBlame gui=bold guifg=#339944")
vim.cmd("highlight NonText gui=bold guifg=#999999")

--[[
Resolve conflict between fugitive and LSPSaga, wherein the latter's
breadcrumbs cause a mismatch between the buffer and fugitive's :Git blame
window and :Gvdiffsplit window(s). To kill the winbar (the top line where
the breadcrumbs and this blame title live), enter `:set winbar&`. 
--]]
local blamegroup = vim.api.nvim_create_augroup("fugitiveSagaBlameConflict", { clear = true })
vim.api.nvim_create_autocmd(
    'FileType',
    {
        group = blamegroup,
        pattern = 'fugitiveblame',
        callback = function()
            vim.api.nvim_set_option_value('winbar', 'fugitive', { scope = 'local' })
        end,
    }
)

local diffgroup = vim.api.nvim_create_augroup("fugitiveSagaDiffConflict", { clear = true })
vim.api.nvim_create_autocmd(
    'BufReadCmd',
    {
        group = diffgroup,
        pattern = "fugitive://*",
        callback = function()
            vim.api.nvim_set_option_value('winbar', 'fugitive', { scope = 'local' })
        end,
    }
)

-- Switch syntax highlighting on
vim.cmd("syntax enable")
