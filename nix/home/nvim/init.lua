-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Load core Neovim configuration first
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings  
require("config.autocmds")   -- Autocommands

-- Find the Nix plugin directory
local function find_nix_plugin_dir()
  for _, path in ipairs(vim.opt.rtp:get()) do
    if path:match("vim%-pack%-dir") then
      local pack_dir = path .. "/pack/myNeovimPackages"
      if vim.fn.isdirectory(pack_dir .. "/start") == 1 then
        return pack_dir
      end
    end
  end
  return nil
end

local nix_pack_dir = find_nix_plugin_dir()

-- Configure lazy.nvim to work with Nix-managed plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  
  -- Configure lazy.nvim to recognize Nix plugins as dev plugins
  dev = {
    path = function(plugin)
      if nix_pack_dir then
        local start_path = nix_pack_dir .. "/start/" .. plugin.name
        local opt_path = nix_pack_dir .. "/opt/" .. plugin.name
        
        if vim.fn.isdirectory(start_path) == 1 then
          return start_path
        elseif vim.fn.isdirectory(opt_path) == 1 then
          return opt_path
        end
      end
      -- Return a default path for plugins not found in Nix
      return "~/projects/" .. plugin.name
    end,
    patterns = { "" }, -- Match all plugins to check if they're in Nix
    fallback = true,   -- Fall back to normal lazy.nvim behavior if not found
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