-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

-- N.B. I could restore neo-tree and/or mini-starter

return {
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "wildcharm",
        },
    },
    {
        "asiryk/auto-hlsearch.nvim",
        opts = {},
    },
    "kovisoft/paredit",
    {
        "hedyhli/outline.nvim",
        config = function()
            require("outline").setup({
                outline_window = {
                    width = 30, -- This is a percentage by default
                },
            })
        end,
    },
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>su",
                function()
                    Snacks.picker.undo()
                end,
                desc = "Undo History",
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            heading = {
                enabled = true,
                render_modes = false,
                atx = true,
                setext = true,
                sign = true,
                icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
                position = "overlay",
                signs = { "󰫎 " },
                width = "full",
                left_margin = 0,
                left_pad = 0,
                right_pad = 0,
                min_width = 0,
                border = false,
                border_virtual = false,
                border_prefix = false,
                above = "▄",
                below = "▀",
                backgrounds = {
                    "RenderMarkdownH1Bg",
                    "RenderMarkdownH2Bg",
                    "RenderMarkdownH3Bg",
                    "RenderMarkdownH4Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH6Bg",
                },
                foregrounds = {
                    "RenderMarkdownH1",
                    "RenderMarkdownH2",
                    "RenderMarkdownH3",
                    "RenderMarkdownH4",
                    "RenderMarkdownH5",
                    "RenderMarkdownH6",
                },
                custom = {},
            },
            pipe_table = {
                enabled = true,
                render_modes = false,
                preset = "none",
                style = "full",
                cell = "padded",
                padding = 1,
                min_width = 0,
                border = {
                    "┌",
                    "┬",
                    "┐",
                    "├",
                    "┼",
                    "┤",
                    "└",
                    "┴",
                    "┘",
                    "│",
                    "─",
                },
                alignment_indicator = "━",
                head = "RenderMarkdownTableHead",
                row = "RenderMarkdownTableRow",
                filler = "RenderMarkdownTableFill",
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "everforest",
            },
        },
    },
    {
        url = "https://git.sr.ht/~hedy/markdown-toc.nvim",
        ft = "markdown",
        cmd = { "Mtoc" },
        opts = {},
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            open_files_do_not_replace_types = { "edgy" },
        },
    },
}
