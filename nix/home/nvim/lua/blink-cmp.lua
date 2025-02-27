return {
  {
    "saghen/blink.cmp",
    lazy = true,
    event = { "InsertEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
          ['<Tab>'] = {
            function(cmp)
              if cmp.snippet_active() then
                return cmp.accept()
              else
                return cmp.select_and_accept()
              end
            end,
            'fallback',
          },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
      })
    end,
  },
}
