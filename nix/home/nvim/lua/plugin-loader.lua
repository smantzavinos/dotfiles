-- plugin-loader.lua
-- Simple plugin configuration loader for Nix-managed plugins

local M = {}

-- Load all plugin configurations from the plugins directory
function M.load_plugins()
  local plugins_dir = vim.fn.stdpath('config') .. '/lua/plugins'
  local plugin_files = vim.fn.glob(plugins_dir .. '/*.lua', false, true)
  
  for _, file in ipairs(plugin_files) do
    local plugin_name = vim.fn.fnamemodify(file, ':t:r')
    local ok, plugin_config = pcall(require, 'plugins.' .. plugin_name)
    
    if ok and type(plugin_config) == 'table' then
      -- Process each plugin spec in the file
      for _, spec in ipairs(plugin_config) do
        if spec.config and type(spec.config) == 'function' then
          -- Execute the plugin configuration
          local config_ok, err = pcall(spec.config)
          if not config_ok then
            vim.notify('Error configuring plugin ' .. (spec[1] or plugin_name) .. ': ' .. err, vim.log.levels.ERROR)
          end
        end
        
        -- Set up keymaps if they exist
        if spec.keys then
          for _, keymap in ipairs(spec.keys) do
            if type(keymap) == 'table' and keymap[1] and keymap[2] then
              local opts = { desc = keymap.desc or '' }
              if keymap.mode then
                opts.mode = keymap.mode
              end
              vim.keymap.set(keymap.mode or 'n', keymap[1], keymap[2], opts)
            end
          end
        end
      end
    elseif not ok then
      vim.notify('Error loading plugin config ' .. plugin_name .. ': ' .. plugin_config, vim.log.levels.WARN)
    end
  end
end

return M