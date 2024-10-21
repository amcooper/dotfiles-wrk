return {
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
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        options = { theme = 'dracula' },
        tabline = {
            lualine_a = {
                {
                    'buffers',
                    mode = 4, -- Displays buffer numbers on tabs at top of window
                }
            },
        },
    },
    "nvim-tree/nvim-web-devicons",
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    "neovim/nvim-lspconfig",
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        opts = {},
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        -- init = function()
        --     vim.o.timeout = true
        --     -- N.B. Setting `timeoutlen` to 0 seems to break the plugin
        --     vim.o.timeoutlen = 300 -- 0? 500? 300?
        -- end,
        opts = {
            win = {
                border = "single",
            },
        },
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        -- requires = "mfussenegger/nvim-dap",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
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
                desc = "DAP: Step Out",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_over()
                end,
                desc = "DAP: Step Over",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "DAP: Step Into",
            },
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "DAP: Toggle breakpoint",
            },
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "DAP: Continue",
            },
            {
                "<leader>da",
                function()
                    local js_based_languages = { "javascript", "typescript" }
                    if vim.fn.filereadable(".vscode/launch.json") then
                        local dap_vscode = require("dap.ext.vscode")
                        dap_vscode.load_launchjs(nil, {
                            ["pwa-node"] = js_based_languages,
                            ["node"] = js_based_languages,
                            ["chrome"] = js_based_languages,
                            ["pwa-chrome"] = js_based_languages,
                        })
                    end
                    require("dap").continue()
                end,
                desc = "DAP: Run with Args",
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
    { "williamboman/mason.nvim", opts = {}, event = "VeryLazy" },
    { "williamboman/mason-lspconfig.nvim", opts = {}, event = "VeryLazy" },
    {
        "nvimdev/lspsaga.nvim",
        event = "VeryLazy",
        opts = {
            beacon = {
                enable = true,
                frequency = 7,
            }
        },
        keys = {
            { "<leader>si", require("lspsaga").incoming_calls, desc = "LSPSaga: Incoming calls" },
            { "<leader>so", require("lspsaga").outgoing_calls, desc = "LSPSaga: outgoing calls" },
            { "<leader>ca", require("lspsaga").code_action, desc = "LSPSaga: code action" },
            { "<leader>sd", require("lspsaga").peek_definition, desc = "LSPSaga: peek definition" },
            { "<leader>sp", require("lspsaga").peek_type_definition, desc = "LSPSaga: peek type definition" },
            { "<leader>sx", require("lspsaga").goto_definition, desc = "LSPSaga: goto definition" },
            { "<leader>sg", require("lspsaga").goto_type_definition, desc = "LSPSaga: goto type definition" },
            { "[e", require("lspsaga").diagnostic_jump_prev, desc = "LSPSaga: diagnostic jump prev" },
            { "]e", require("lspsaga").diagnostic_jump_next, desc = "LSPSaga: diagnostic jump next" },
            { "<leader>sK", require("lspsaga").hover_doc, desc = "LSPSaga: hover doc" },
            { "<leader>sm", require("lspsaga").finder_imp, desc = "LSPSaga: finder imp" },
            { "<leader>sf", require("lspsaga").finder, desc = "LSPSaga: finder" },
            { "<leader>sl", require("lspsaga").outline, desc = "LSPSaga: outline" },
            { "<leader>rn", require("lspsaga").rename, desc = "LSPSaga: rename" },
            { "<leader>st", require("lspsaga").term_toggle, desc = "LSPSaga: term toggle" },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
        },
        keys = {
            { "<leader>ff", require("telescope.builtin").find_files, desc = "Telescope: find files" },
            { "<leader>fg", require("telescope.builtin").live_grep,  desc = "Telescope: live grep" },
            { "<leader>fb", require("telescope.builtin").buffers,  desc = "Telescope: buffers" },
            { "<leader>fh", require("telescope.builtin").help_tags,  desc = "Telescope: help tags" },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        opts = function()
            local cmp = require'cmp'
            return {
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'vsnip' }, -- For vsnip users.
                    { name = 'nvim_lsp_signature_help' },
                }, {
                    { name = 'buffer' },
                }),
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
                cmdline = function() -- Not sure if this is correct.
                    return {
                        { '/', '?' },
                        {
                            mapping = cmp.mapping.preset.cmdline(),
                            sources = {
                                { name = 'buffer' },
                            },
                        },
                    }
                end,
--[[
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
--]]
            }
        end,
    },
    { "tpope/vim-fugitive", event = "VeryLazy" },
    { "lewis6991/gitsigns.nvim", event = "VeryLazy" },
    { "famiu/bufdelete.nvim", event = "VeryLazy" },
    { "jparise/vim-graphql", event = "VeryLazy" },
}

