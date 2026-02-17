vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("t", "Esc", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle %:h<cr>")
vim.keymap.set("n", "<leader>E", vim.cmd.NvimTreeFocus)
vim.keymap.set("n", "<leader>t", "<cmd>tabnew %:h<cr>")
vim.keymap.set("n", "<leader>q", vim.cmd.tabclose)
vim.keymap.set("n", "<leader>b", vim.cmd.ToggleTerm)
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Variable" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.keymap.set("n", "<leader>r",
            ":w <Bar> execute 'cd %:p:h' <bar> TermExec cmd='g++ -o %< % && ./%<' go_back=0 <CR>",
            { buffer = true, silent = true })
    end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.keymap.set("n", "<leader>c", ":w <Bar> execute 'cd %:p:h' <bar> !g++ -o %< % <CR>",
            { buffer = true, silent = true })
    end
})
vim.api.nvim_create_autocmd("Filetype", {
    pattern = "python",
    callback = function()
        vim.keymap.set("n", "<leader>r", ":w <Bar> TermExec cmd='python3 %' go_back=0 <CR>",
            { buffer = true, silent = true })
    end
})

vim.api.nvim_create_autocmd("Filetype", {
    pattern = "java",
    callback = function()
        vim.keymap.set("n", "<leader>r", ":DapContinue <CR>")
    end
})

local placeholder_name = "FLOAT_RESTORE_PLACEHOLDER"

local function toggle_float_center()
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_get_current_buf()

    -- 1. If we are ALREADY in a floating window, "Unfloat" it
    if vim.api.nvim_win_get_config(current_win).relative ~= "" then
        local target_win = nil
        -- Find the window holding our placeholder
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_get_name(buf):match(placeholder_name) then
                target_win = win
                break
            end
        end

        if target_win then
            vim.api.nvim_win_set_buf(target_win, current_buf)
            vim.api.nvim_win_close(current_win, false)
            vim.api.nvim_set_current_win(target_win)
        else
            -- Fallback: If layout changed and placeholder is gone, just close float
            vim.api.nvim_win_close(current_win, false)
        end
        return
    end

    -- 2. "Float" the window
    -- Check if placeholder buffer already exists to avoid naming conflicts
    local placeholder_buf = nil
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(b):match(placeholder_name) then
            placeholder_buf = b
            break
        end
    end

    -- Create it if it doesn't exist
    if not placeholder_buf then
        placeholder_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(placeholder_buf, placeholder_name)
        -- Make it look clean: no numbers, no swap file
        vim.api.nvim_buf_set_option(placeholder_buf, 'buftype', 'nofile')
    end

    -- Calculate dimensions
    local width = math.ceil(vim.o.columns * 0.8)
    local height = math.ceil(vim.o.lines * 0.8)
    local row = math.ceil((vim.o.lines - height) / 2)
    local col = math.ceil((vim.o.columns - width) / 2)

    -- Open the float
    local win = vim.api.nvim_open_win(current_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    })

    -- Put the placeholder in the original tiled window
    vim.api.nvim_win_set_buf(current_win, placeholder_buf)
end

vim.keymap.set('n', '<leader>mf', toggle_float_center, { desc = "Toggle Center Float" })
vim.keymap.set('t', '<leader>mf', toggle_float_center, { desc = "Toggle Center Float" })
