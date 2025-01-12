return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("blink.cmp").setup({
        keymap = { preset = 'default' },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
      })
    end
  }
}
