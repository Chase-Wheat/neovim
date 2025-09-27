return {
    "xiyaowong/transparent.nvim",
    lazy = false, -- This is important for the plugin to work correctly
    config = function()
        require("transparent").setup({
            -- You can specify groups you want to make transparent here
            extra_groups = {
                "NvimTreeNormal",
                "NormalFloat",
            },
        })
    end,
}
