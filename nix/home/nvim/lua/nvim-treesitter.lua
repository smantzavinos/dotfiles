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
      })
    end,
  },
}

