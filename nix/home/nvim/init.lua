-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Load core Neovim configuration first
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings  
require("config.autocmds")   -- Autocommands

-- Setup nixCats utilities for compatibility with non-nixCats environments
local nixCatsUtils = require('nixCatsUtils')
nixCatsUtils.setup({
  non_nix_value = true  -- Default value when not using nixCats
})

-- Use nixCats lazy wrapper for proper Nix integration
local lazyCat = require('nixCatsUtils.lazyCat')

-- Find lazy.nvim path in Nix store
local function find_lazy_path()
  for _, path in ipairs(vim.opt.rtp:get()) do
    if path:match("lazy%-nvim") then
      return path
    end
  end
  return nil
end

-- Setup lazy.nvim with nixCats integration
lazyCat.setup(find_lazy_path(), {
  spec = {
    { import = "plugins" },
  },
  
  -- UI settings
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    backdrop = 60,
  },
  
  -- Performance settings (nixCats handles the Nix-specific parts)
  performance = {
    cache = {
      enabled = true,
    },
  },
})