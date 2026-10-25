return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", 
  build = ":TSUpdate",
  -- Use 'opts' instead of a manual config function
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    -- If you want autotag, make sure nvim-ts-autotag is installed
    autotag = { enable = true }, 
    ensure_installed = {
      "lua",
      "cpp",
      "python",
      "java",
      "asm",
      "c",
      "go",
      "markdown",        -- Add these two for Shift-K
      "markdown_inline", -- to look pretty
    },
    auto_install = false,
  },
  -- Lazy.nvim will automatically call the new internal setup with the opts above
}
