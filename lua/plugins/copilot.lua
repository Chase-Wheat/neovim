return {
    "zbirenbaum/copilot.lua",
    --enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = { enabled = false }, -- Disable ghost text so it doesn't overlap nvim-cmp
            panel = { enabled = false },
        })
    end,
    dependencies = {
        {
            "zbirenbaum/copilot-cmp",
            config = function()
                require("copilot_cmp").setup()
            end,
        },
    },
}
