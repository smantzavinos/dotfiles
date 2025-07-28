return {
  {
    "monaqa/dial.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      local aug = require("dial.augend")
      local dconf = require("dial.config")
      dconf.augends:register_group({
        default = {
          aug.date.alias["%Y-%m-%d"],
        },
      })
      local map = vim.keymap.set
      local dm = require("dial.map")
      map("n", "<C-.>", dm.inc_normal(), { noremap = true })
      map("n", "<C-,>", dm.dec_normal(), { noremap = true })
      map("v", "<C-.>", dm.inc_visual(), { noremap = true })
      map("v", "<C-,>", dm.dec_visual(), { noremap = true })
    end,
  },
}
