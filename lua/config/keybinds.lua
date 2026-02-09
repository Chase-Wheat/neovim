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
