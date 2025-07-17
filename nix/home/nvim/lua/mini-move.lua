return {
  {
    "echasnovski/mini.move",
    version = false,
    config = function()
      require("mini.move").setup()
      local map = vim.keymap.set
      map({ "n", "v" }, "<M-j>", "<Plug>(MiniMoveLineDown)")
      map({ "n", "v" }, "<M-k>", "<Plug>(MiniMoveLineUp)")
    end,
  },
}
