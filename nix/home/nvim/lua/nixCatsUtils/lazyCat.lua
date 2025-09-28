-- nixCatsUtils/lazyCat.lua
-- Lazy.nvim wrapper for nixCats integration

local M = {}

-- Setup function that wraps lazy.nvim
function M.setup(nixCatsPath, specs, opts)
  -- If nixCatsPath is provided and valid, we're in nixCats mode
  if nixCatsPath then
    -- In nixCats mode, use the provided path
    require("lazy").setup(specs, opts)
  else
    -- Fallback to standard lazy.nvim setup
    require("lazy").setup(specs, opts)
  end
end

return M