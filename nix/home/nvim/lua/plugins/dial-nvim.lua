return {
  {
    "monaqa/dial.nvim",
    enabled = false, -- Disable due to Neovim 0.11 compatibility issues
    lazy = true,
    event = "VeryLazy",
    config = function()
      local ok_aug, aug = pcall(require, "dial.augend")
      local ok_config, config = pcall(require, "dial.config")
      local ok_map, map_module = pcall(require, "dial.map")
      
      if not ok_aug or not ok_config or not ok_map then
        vim.notify("Failed to load dial.nvim modules", vim.log.levels.ERROR)
        return
      end
      
      -- Configure augends with error handling
      local success, _ = pcall(function()
        config.augends:register_group({
          default = {
            aug.integer.alias.decimal,
            aug.integer.alias.hex,
            aug.date.alias["%Y/%m/%d"],
            aug.constant.alias.bool,
            aug.semver.alias.semver,
          },
        })
      end)
      
      if not success then
        vim.notify("Failed to configure dial.nvim augends", vim.log.levels.WARN)
      end
      
      -- Set up keymaps
      local map = vim.keymap.set
      map("n", "<C-a>", map_module.inc_normal(), { noremap = true, desc = "Increment" })
      map("n", "<C-x>", map_module.dec_normal(), { noremap = true, desc = "Decrement" })
      map("v", "<C-a>", map_module.inc_visual(), { noremap = true, desc = "Increment" })
      map("v", "<C-x>", map_module.dec_visual(), { noremap = true, desc = "Decrement" })
      map("v", "g<C-a>", map_module.inc_gvisual(), { noremap = true, desc = "Increment (sequential)" })
      map("v", "g<C-x>", map_module.dec_gvisual(), { noremap = true, desc = "Decrement (sequential)" })
    end,
  },
}
