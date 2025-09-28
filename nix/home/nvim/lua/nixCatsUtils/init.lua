-- nixCatsUtils/init.lua
-- Minimal nixCats utilities for lazy.nvim integration

local M = {}

-- Check if we're running under nixCats
M.isNixCats = false

-- Setup function (compatible with nixCats)
function M.setup(opts)
  opts = opts or {}
  -- Set global nixCats function if not already set
  if not _G.nixCats then
    _G.nixCats = function(path)
      -- Return false for all category checks when not using nixCats
      return false
    end
  end
  return M
end

-- Lazy wrapper function for conditional loading
function M.lazyAdd(nixValue, nonNixValue)
  if M.isNixCats then
    return nixValue
  else
    return nonNixValue ~= nil and nonNixValue or nixValue
  end
end

return M