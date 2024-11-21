return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    install = true,
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup()

      -- Map <Leader>E to toggle nvim-tree
      vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  },
}
