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
      { "<c-g>", function() require('telescope.builtin').live_grep() end, { noremap = true, silent = true } },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "❯ ",
          selection_caret = "❯ ",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist,
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = { "node_modules", ".git", "target" },
          sorting_strategy = "descending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "bottom",
              preview_width = 0.55,
            },
          },
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
