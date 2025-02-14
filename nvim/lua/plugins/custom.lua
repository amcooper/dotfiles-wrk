-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

-- N.B. I could restore neo-tree and/or mini-starter

return {
    "kovisoft/paredit",
    {
        "monkoose/nvlime",
        event = "VeryLazy",
        dependencies = {
            "monkoose/parsley",
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shellcheck",
                "shfmt",
                "flake8",
            },
        },
    },
}
