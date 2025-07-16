return {
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    -- require("codecompanion").setup({
    --   display = {
    --     action_palette = {
    --       width = 95,
    --       height = 10,
    --       prompt = "Prompt ", -- Prompt used for interactive LLM calls
    --       provider = "default", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
    --       opts = {
    --         show_default_actions = true, -- Show the default actions in the action palette?
    --         show_default_prompt_library = true, -- Show the default prompt library in the action palette?
    --       },
    --     },
    --   },
    -- }),
    --
    --

    config = function()
      require("codecompanion").setup({
        adapters = {
          anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY")
          }
        },
        default_adapter = "anthropic",
        size = {
          width = "40%",
          height = "60%"
        },
      })

      -- Key mappings for CodeCompanion
      vim.keymap.set('n', '<leader>cc', ':CodeCompanion<CR>', { noremap = true, silent = true })
      vim.keymap.set('v', '<leader>cc', ':CodeCompanion<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>cs', ':CodeCompanionToggle<CR>', { noremap = true, silent = true })
    end,
  },
}
