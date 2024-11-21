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
    end,
    keys = {
      { "<Leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true } }
    },
  },
}
