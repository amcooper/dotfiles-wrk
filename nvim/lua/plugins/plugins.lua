-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 20000,
        },
    },
    {
        "folke/noice.nvim",
        event = "VimEnter",
        dependencies = { "rcarriga/nvim-notify" }, -- merge with LazyVim spec
    },
    -- From various Internet sources: an attempt to get GraphQL LSP working
    -- TODO: Currently not working. `LspLog` shows wrong cmd ?
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                graphql = {},
            },
            cmd = { "~/builds/graphiql/packages/graphql-language-service-cli/bin/graphql.js", "server", "-m", "stream" },
            filetypes = { "graphql" },
            root_dir = require("lspconfig").util.root_pattern(
                ".git",
                ".graphqlrc*",
                ".graphql.config.*",
                "graphql.config.*"
            ),
        },
    },

    -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
    -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
    { import = "lazyvim.plugins.extras.lang.typescript" },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            vim.list_extend(opts.ensure_installed, {
                "tsx",
                "typescript",
                "javascript",
                "go",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "tsx",
                "typescript",
                "vim",
                "yaml",
            })
        end,
    },

    -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
    { import = "lazyvim.plugins.extras.lang.json" },

    -- add any tools you want to have installed below
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shellcheck",
                "shfmt",
            },
        },
    },
}
