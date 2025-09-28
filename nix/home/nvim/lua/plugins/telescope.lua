return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    keys = {
      { "<c-p>", function() require('telescope.builtin').find_files() end, { noremap = true, silent = true } },
      { "<c-b>", function() require('telescope.builtin').buffers() end, { noremap = true, silent = true } },
      { "<c-g>", function() 
          require('telescope.builtin').live_grep()
        end, { noremap = true, silent = true } },
      -- Project root alternatives
      { "<c-m-p>", function() 
          local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
          local cwd = (git_root ~= "" and vim.v.shell_error == 0) and git_root or vim.fn.getcwd()
          require('telescope.builtin').find_files({
            cwd = cwd,
          })
        end, { noremap = true, silent = true } },
      { "<c-m-g>", function() 
          local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
          local cwd = (git_root ~= "" and vim.v.shell_error == 0) and git_root or vim.fn.getcwd()
          require('telescope.builtin').live_grep({
            cwd = cwd,
          })
        end, { noremap = true, silent = true } },
    },
    config = function()
      local telescope = require("telescope")
      
      telescope.setup({
        defaults = {
          prompt_prefix = "❯ ",
          selection_caret = "❯ ",
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },
}
