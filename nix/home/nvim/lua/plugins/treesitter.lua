return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = false,
      ensure_installed = {},
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        fold = {
          enable = true,
        },
      })

      -- Tree-sitter-based folding for programming languages
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "lua", "python", "rust", "go", "java", "c", "cpp", "nix", "json", "yaml" },
        callback = function()
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
          vim.opt_local.foldlevel = 99 -- open all folds by default
        end,
      })

      -- Tree-sitter-based folding for Markdown
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
          vim.opt_local.foldlevel = 99 -- open all folds by default
        end,
      })
    end,
  },
}

