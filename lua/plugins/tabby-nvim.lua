return {
    'nanozuki/tabby.nvim',
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    ---@type TabbyConfig
    opts = {
        -- configs...
        preset = 'tab_only',
        option = {
            lualine_theme = "tokyonight"
        }
    },
}
