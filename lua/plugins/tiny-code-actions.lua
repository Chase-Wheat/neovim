return {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },

        -- optional picker via telescope
        { "nvim-telescope/telescope.nvim" },
    },

    event = "LspAttach",
    opts = {},
    vim.keymap.set({ "n", "x" }, "<leader>xk", function()
        require("tiny-code-action").code_action()
    end, { noremap = true, silent = true, desc = "Code Actions" })
}
