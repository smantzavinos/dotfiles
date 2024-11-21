return {
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<Leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true } }
    },
    config = function()
      require("nvim-tree").setup()
    end,
  },
}
