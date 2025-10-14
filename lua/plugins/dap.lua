return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "williamboman/mason.nvim",
        "rcarriga/nvim-dap-ui",
    },
    config = function()
        local dap = require("dap")

        -- Toggle breakpoint
        vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })

        -- DAP UI setup
        local dapui_ok, dapui = pcall(require, "dapui")
        if dapui_ok then
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
            vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = "Toggle DAP UI" })
        end

        ----------------------------------------------------------------------
        -- 🧭 Contextual Arrow Key Bindings (active only during debugging)
        ----------------------------------------------------------------------
        local function set_dap_keymaps()
            local opts = { noremap = true, silent = true, desc = "DAP" }
            vim.keymap.set('n', '<Up>', dap.restart_frame, vim.tbl_extend("force", opts, { desc = "Restart Frame" }))
            vim.keymap.set('n', '<Down>', dap.step_over, vim.tbl_extend("force", opts, { desc = "Step Over" }))
            vim.keymap.set('n', '<Left>', dap.step_out, vim.tbl_extend("force", opts, { desc = "Step Out" }))
            vim.keymap.set('n', '<Right>', dap.step_into, vim.tbl_extend("force", opts, { desc = "Step Into" }))
        end

        local function clear_dap_keymaps()
            pcall(vim.keymap.del, 'n', '<Up>')
            pcall(vim.keymap.del, 'n', '<Down>')
            pcall(vim.keymap.del, 'n', '<Left>')
            pcall(vim.keymap.del, 'n', '<Right>')
        end

        -- When debugging starts, set keymaps
        dap.listeners.after.event_initialized["dap_keymaps"] = function()
            set_dap_keymaps()
        end

        -- When debugging ends, clear them
        dap.listeners.before.event_terminated["dap_keymaps"] = function()
            clear_dap_keymaps()
        end
        dap.listeners.before.event_exited["dap_keymaps"] = function()
            clear_dap_keymaps()
        end
    end
}
