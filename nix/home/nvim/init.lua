-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Setup nixCats utilities (provides compatibility layer)
require('nixCatsUtils').setup {
  non_nix_value = true,
}

-- Create a compatibility layer for Nix-managed plugins
local function setup_nix_plugin_compatibility()
  -- Get the path to Nix-managed plugins
  local nix_pack_path = nil
  for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    if path:match("vim%-pack%-dir") then
      nix_pack_path = path .. "/pack/myNeovimPackages/start"
      break
    end
  end
  
  if not nix_pack_path then
    vim.notify("Could not find Nix plugin directory", vim.log.levels.WARN)
    return
  end
  
  -- Create symlinks in lazy.nvim directory to make plugins appear "installed"
  local lazy_plugins_dir = vim.fn.stdpath("data") .. "/lazy"
  vim.fn.mkdir(lazy_plugins_dir, "p")
  
  -- Get list of Nix-managed plugins
  local handle = io.popen("ls " .. nix_pack_path)
  if handle then
    for plugin_name in handle:lines() do
      local nix_plugin_path = nix_pack_path .. "/" .. plugin_name
      local lazy_plugin_path = lazy_plugins_dir .. "/" .. plugin_name
      
      -- Create symlink if it doesn't exist
      if vim.fn.isdirectory(nix_plugin_path) == 1 and vim.fn.isdirectory(lazy_plugin_path) == 0 then
        vim.fn.system("ln -sf " .. nix_plugin_path .. " " .. lazy_plugin_path)
      end
    end
    handle:close()
  end
end

-- Setup the compatibility layer
setup_nix_plugin_compatibility()

-- Setup lazy.nvim with Nix-friendly configuration
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  
  -- Critical: Tell lazy.nvim not to manage plugin installation
  install = { 
    missing = false,  -- Never try to install missing plugins
  },
  
  -- Disable features that conflict with Nix
  checker = { enabled = false },    -- No update checking
  change_detection = { enabled = false }, -- No file watching
  
  -- Performance settings for Nix integration
  performance = {
    reset_packpath = false,  -- Don't reset packpath (preserve Nix paths)
    rtp = { 
      reset = false,  -- Don't reset runtime path
    },
  },
  
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