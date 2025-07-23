return {
  {
    "monaqa/dial.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      vim._update_package_paths()
      local dial = require("dial")
      local aug = require("dial.augend")
      dial.config.augends:register_group({
        default = {
          aug.date.alias["%Y-%m-%d"],
        },
      })
      local map = vim.keymap.set
      local dm = require("dial.map")
      map("n", "<C-a>", dm.inc_normal(), { noremap = true })
      map("n", "<C-x>", dm.dec_normal(), { noremap = true })
      map("v", "<C-a>", dm.inc_visual(), { noremap = true })
      map("v", "<C-x>", dm.dec_visual(), { noremap = true })
    end,
  },
}
