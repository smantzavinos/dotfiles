return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<c-p>", function() require('fzf-lua').files() end, { noremap = true, silent = true } },
      { "<c-b>", function() require('fzf-lua').buffers() end, { noremap = true, silent = true } },
      { "<c-g>", function() require('fzf-lua').live_grep_native() end, { noremap = true, silent = true } },
    },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
}
