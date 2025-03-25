return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      vim.opt.termguicolors = true
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          nvimtree = true,
          treesitter = true,
          dap = {
            enabled = true,
            enable_ui = true,
          },
          native_lsp = {
            enabled = true,
          },
          neogit = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end
  }
}