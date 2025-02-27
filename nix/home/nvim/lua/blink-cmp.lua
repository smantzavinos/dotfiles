return {
  {
    "saghen/blink.cmp",
    lazy = true,
    event = { "InsertEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
          ['<Tab>'] = {
            function(cmp)
              local luasnip = require("luasnip")
              if luasnip.jumpable and luasnip.jumpable(1) then
                return luasnip.jump(1)
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
