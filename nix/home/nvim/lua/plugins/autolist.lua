return {
  {
    "gaoDean/autolist.nvim",
    ft = { "markdown" },
    config = function()
      require("autolist").setup()
      local map = vim.keymap.set
      -- list-aware tab / shift-tab
      map({ "i", "n" }, "<Tab>", "<cmd>AutolistTab<CR>")
      map({ "i", "n" }, "<S-Tab>", "<cmd>AutolistShiftTab<CR>")
      -- NEW list item on Alt-Enter
      map("i", "<A-CR>", "<CR><cmd>AutolistNewBullet<CR>", { desc = "New list item (autolist)" })
      -- normal-mode convenience
      map("n", "o", "o<cmd>AutolistNewBullet<CR>")
      map("n", "O", "O<cmd>AutolistNewBulletBefore<CR>")
    end,
  },
}
