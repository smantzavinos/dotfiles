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
          require('telescope.builtin').live_grep({
            cwd = vim.fn.getcwd(),
          })
        end, { noremap = true, silent = true } },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      -- Clone the default Telescope configuration for vimgrep_arguments
      local telescopeConfig = require("telescope.config")
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- Add hidden file search arguments
      table.insert(vimgrep_arguments, "--hidden")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")

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
          -- Use the enhanced vimgrep_arguments with hidden file support
          vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
          find_files = {
            -- Enable hidden file search for find_files too
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
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
