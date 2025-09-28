-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Lazy.nvim setup with Nix integration
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  
  -- Nix integration settings
  performance = {
    reset_packpath = false,  -- Don't interfere with Nix paths
    rtp = { reset = false }, -- Preserve runtime path
  },
  
  -- Disable installation features (Nix handles this)
  install = { missing = false },    -- Never install plugins
  checker = { enabled = false },    -- No update checking
  change_detection = { enabled = false }, -- No file watching
  
  -- UI settings
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    backdrop = 60,
  },
})

-- Load core Neovim configuration
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings
require("config.autocmds")   -- Autocommands