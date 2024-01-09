HOME = os.getenv("HOME")

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
vim.opt.foldlevel = 3
vim.opt.foldcolumn = "auto:9" -- Flexible width of fold indicators on window's left side

-- Enable 24-bit RGB color in the TUI
vim.opt.termguicolors = true

-- Minimal number of lines kept above and below the cursor
vim.opt.scrolloff = 5

-- netrw
-- This is the workspace file explorer
vim.g.netrw_winsize = 25 -- width of the file explorer
vim.g.netrw_liststyle = 3 -- tree style listing

-- Escape exits terminal mode
-- vim.keymap.set("t", "<Esc>", "<c-\\><c-n>", { noremap = true })

-- Sane vim split naviagation (via Gaslight blog)
vim.keymap.set("n", "<c-j>", "<c-w>j", { noremap = true, desc = 'Go to window below' })
vim.keymap.set("n", "<c-k>", "<c-w>k", { noremap = true, desc = 'Go to window above' })
vim.keymap.set("n", "<c-h>", "<c-w>h", { noremap = true, desc = 'Go to window to the left' })

-- N.B. This conflicts with the NetRW directory refresh command as Neovim's own CTRL-L
-- vim.keymap.set("n", "<c-l>", "<c-w>l", { noremap = true, desc = 'Go to window to the right' })
vim.keymap.set("t", "<c-j>", "<c-\\><c-n><c-w>j", { noremap = true, desc = 'Go to window below' })
vim.keymap.set("t", "<c-k>", "<c-\\><c-n><c-w>k", { noremap = true, desc = 'Go to window above' })
vim.keymap.set("t", "<c-h>", "<c-\\><c-n><c-w>h", { noremap = true, desc = 'Go to window to the left' })
-- vim.keymap.set("t", "<c-l>", "<c-\\><c-n><c-w>l", { noremap = true, desc = 'Go to window to the right' })

-- TODO(amcooper): Delete this mapping, as CTRL-L natively clears search match highlighting
--[[
vim.keymap.set(
  {"i", "n", "t", "v"},
  "<F10>",
  function ()
    vim.cmd("nohlsearch")
  end,
  { desc = ":nohlsearch" }
)
]]

vim.keymap.set(
  {"n", "t"},
  "<leader>z",
  function ()
    -- This restores the UI to the saved layout 'idelayout' (if saved on command line)
    -- TODO: Wrap the function body in an if statement to verify existence of idelayout
    vim.cmd("exec idelayout")
  end,
  { desc = "Revert window layout" }
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

local js_based_languages = { "javascript", "typescript" }

require("lazy").setup({
  {
    url = "https://git.theadamcooper.com/adam/dracula-vim.git",
    branch = "adamc-main",
    name = "dracula",
    lazy = false,
    priority = 1000,
    config = function ()
      vim.cmd.colorscheme("dracula")
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
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
    { "rcarriga/nvim-dap-ui", requires = "mfussenegger/nvim-dap" },
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            -- local Config = require("lazyvim.config")
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            --[[
            for name, sign in pairs(Config.icons.dap) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define(
            "Dap" .. name,
            { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
            )
            end
            --]]

            for _, language in ipairs({ "javascript", "typescript" }) do
                dap.configurations[language] = {
                    -- Debug single nodejs files
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = vim.fn.getcwd(),
                        sourceMaps = true,
                    },
                    -- Debug nodejs processes (make sure to add --inspect when you run the process)
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach",
                        processId = require("dap.utils").pick_process,
                        cwd = vim.fn.getcwd(),
                        sourceMaps = true,
                        resolveSourceMapLocations = {"${workspaceFolder}/**", "!**/node_modules/**"},
                    },
                    -- Debug web applications (client side)
                    {
                        type = "pwa-chrome",
                        request = "launch",
                        name = "Launch & Debug Chrome",
                        url = function()
                            local co = coroutine.running()
                            return coroutine.create(function()
                                vim.ui.input({
                                    prompt = "Enter URL: ",
                                    default = "http://localhost:3000",
                                }, function(url)
                                    if url == nil or url == "" then
                                        return
                                    else
                                        coroutine.resume(co, url)
                                    end
                                end)
                            end)
                        end,
                        webRoot = vim.fn.getcwd(),
                        protocol = "inspector",
                        sourceMaps = true,
                        userDataDir = false,
                    },
                    -- Divider for the launch.json derived configs
                    {
                        name = "----- ↓ launch.json configs ↓ -----",
                        type = "",
                        request = "launch",
                    },
                }
            end
        end,
        keys = {
            {
                "<leader>dO",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>da",
                function()
                    if vim.fn.filereadable(".vscode/launch.json") then
                        local dap_vscode = require("dap.ext.vscode")
                        dap_vscode.load_launchjs(nil, {
                            ["pwa-node"] = js_based_languages,
                            ["chrome"] = js_based_languages,
                            ["pwa-chrome"] = js_based_languages,
                        })
                    end
                    require("dap").continue()
                end,
                desc = "Run with Args",
            },
        },
        dependencies = {
            -- Install the vscode-js-debug adapter
            {
                "microsoft/vscode-js-debug",
                -- After install, build it and rename the dist directory to out
                build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
                version = "1.*",
            },
            {
                "mxsdev/nvim-dap-vscode-js",
                config = function()
                    ---@diagnostic disable-next-line: missing-fields
                    require("dap-vscode-js").setup({
                        -- Path of node executable. Defaults to $NODE_PATH, and then "node"
                        -- node_path = "node",

                        -- Path to vscode-js-debug installation.
                        debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

                        -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
                        -- debugger_cmd = { "js-debug-adapter" },

                        -- which adapters to register in nvim-dap
                        adapters = {
                            "chrome",
                            "pwa-node",
                            "pwa-chrome",
                            "pwa-msedge",
                            "pwa-extensionHost",
                            "node-terminal",
                        },

                        -- Path for file logging
                        -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

                        -- Logging level for output to file. Set to false to disable logging.
                        -- log_file_level = false,

                        -- Logging level for output to console. Set to false to disable console output.
                        -- log_console_level = vim.log.levels.ERROR,
                    })
                end,
            },
            {
                "Joakker/lua-json5",
                build = "./install.sh",
            },
        },
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
    "famiu/bufdelete.nvim",
})

--[[ mason
Mason manages external editor plugins such as LSP servers, DAP servers,
linters, and formatters. There are further recommended plugins for better
integration.
--]]
require('mason').setup()
require('mason-lspconfig').setup()

--[[ lualine
Lualine provides the status bar as well as the tabline. Not sure whether
it also provides the buffer breadcrumbs.
--]]
require('lualine').setup {
    options = { theme = 'dracula' },
    tabline = {
        lualine_a = {
            {
                'buffers',
                mode = 4, -- Displays buffer numbers on tabs at top of window
            }
        },
    }
}

--[[ Telescope
Telescope provides lists, pickers, etc. This section includes just the
functions bound to keymaps.
--]]
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: help tags' })

-------------------
-- lsp_signature --
-------------------
require("lsp_signature").setup()


--[[ nvim-cmp
nvim-cmp is a text completion engine.
]]

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

--[[ nvim-lspconfig
--]]

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
window. To kill the winbar (the top line where the breadcrumbs and this 
blame title live), enter `:set winbar&`. 
--]]
local group = vim.api.nvim_create_augroup("fugitiveSagaConflict", { clear = true })
vim.api.nvim_create_autocmd(
    'FileType',
    {
        group = group,
        pattern = 'fugitiveblame',
        callback = function()
            vim.api.nvim_set_option_value('winbar', 'fugitive: :Git blame', { scope = 'local' })
        end,
    }
)

-- Switch syntax highlighting on
vim.cmd("syntax enable")

-- Temporary file locations
vim.opt.backupdir = ".backup/," .. HOME .. "/.backup/,/tmp//"
vim.opt.directory = ".swp/," .. HOME .. "/.swp/,/tmp//"
