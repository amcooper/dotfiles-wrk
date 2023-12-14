--[[ TODO: Look into how to get VSCode hooked in with Neovim again. The
extension documentation is not clear.

if vim.g.vscode then
    -- VSCode extensions
else
    -- Regular extensions
end
]]

HOME = os.getenv("HOME")

-- Configure the clipboard to access the "+ and "* registers
-- N.B. JavaScript copy buttons on the web do not necessarily work as expected
vim.opt.clipboard = "unnamedplus,unnamed"

-- Spaces indentation
vim.opt.expandtab = true -- converts tabs to spaces
vim.opt.tabstop = 4 -- tab equals 2 spaces
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
vim.opt.foldlevel = 3
vim.opt.foldcolumn = "auto:9"

-- Terminal colors
vim.opt.termguicolors = true

-- Cursor line context
vim.opt.scrolloff = 5

-- netrw
-- This is the workspace file explorer
vim.g.netrw_winsize = 25 -- width of the file explorer
vim.g.netrw_liststyle = 3 -- tree style listing

-- <leader>n exits terminal mode
-- vim.keymap.set("t", "<leader>n", "<c-\\><c-n>", { noremap = true })

-- Sane vim split naviagation (via Gaslight blog)
vim.keymap.set("n", "<c-j>", "<c-w>j", { noremap = true })
vim.keymap.set("n", "<c-k>", "<c-w>k", { noremap = true })
vim.keymap.set("n", "<c-h>", "<c-w>h", { noremap = true })

-- This keybind interferes with <c-l> (refresh listing) in NetRW.
-- Substitute the standard chord `<c-w>l`.
-- vim.keymap.set("n", "<c-l>", "<c-w>l", { noremap = true })
vim.keymap.set("t", "<c-j>", "<c-\\><c-n><c-w>j", { noremap = true })
vim.keymap.set("t", "<c-k>", "<c-\\><c-n><c-w>k", { noremap = true })
vim.keymap.set("t", "<c-h>", "<c-\\><c-n><c-w>h", { noremap = true })
vim.keymap.set("t", "<c-l>", "<c-\\><c-n><c-w>l", { noremap = true })

vim.keymap.set(
    {"i", "n", "t", "v"},
    "<F10>",
    function () vim.cmd("nohlsearch") end,
    { desc = "Clear search match highlight" }
)

vim.keymap.set(
    {"n", "t"},
    "<leader>z",
    function () vim.cmd("execute idelayout") end,
    { desc = "Restore IDE layout" }
)

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

require("lazy").setup({
    {
        "dracula/vim",
        name = "dracula",
        lazy = false,
        priority = 1000,
        config = function ()
        vim.cmd.colorscheme("dracula")
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
        end,
        opts = {
            window = { border = "single" },
        },
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {},
      config = function(_, opts) require'lsp_signature'.setup(opts) end
    },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "nvimdev/lspsaga.nvim",
    "nvim-lualine/lualine.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "tpope/vim-fugitive",
    "lewis6991/gitsigns.nvim",
    "tpope/vim-surround",
})

require('mason').setup()
require('mason-lspconfig').setup()

require('lualine').setup {
    options = { theme = 'dracula' },
    tabline = {
        lualine_a = {
            {
                'buffers',
                mode = 4,
            }
        },
    }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: help tags' })

require("lsp_signature").setup()

--------------------
-- nvim-lspconfig --
--------------------

-- Setup language servers.
local lua_ls_setup = {
  settings = {
    Lua = {
      runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
      },
      diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
      },
      workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
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
lspconfig.lua_ls.setup(lua_ls_setup)
lspconfig.pyright.setup {capabilities = capabilities}
lspconfig.tsserver.setup {capabilities = capabilities}
lspconfig.rust_analyzer.setup {
-- Server-specific settings. See `:help lspconfig-setup`
capabilities = capabilities,
    settings = {
        ['rust-analyzer'] = {},
    },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Diagnostic: open float' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostic: go to previous' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostic: go to next' })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'Diagnostic: set loclist' })

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

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    sources = {
      { name = 'nvim_lsp_signature_help' }
    }
})

cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
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
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
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
    yadm = {
      enable = false
    },
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
      end, {expr=true, desc='GitSigns: next hunk'})

      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true, desc='GitSigns: previous hunk'})

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

require('lspsaga').setup()

-- Tweak GitSigns blame color
vim.cmd("highlight GitSignsCurrentLineBlame gui=bold guifg=#339944")
vim.cmd("highlight NonText gui=bold guifg=#999999")

-- Switch syntax highlighting on
vim.cmd("syntax enable")

-- Temporary file locations
vim.opt.backupdir = ".backup/," .. HOME .. "/.backup/,/tmp//"
vim.opt.directory = ".swp/," .. HOME .. "/.swp/,/tmp//"
