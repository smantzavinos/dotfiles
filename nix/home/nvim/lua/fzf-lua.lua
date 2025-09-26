return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
    },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
}
