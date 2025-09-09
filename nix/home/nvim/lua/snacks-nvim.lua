return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            input = { enabled = true },      -- Required for opencode.nvim embedded terminal
            terminal = { enabled = true },   -- Enable terminal functionality
            notifier = { enabled = true },   -- Enable notifications
            quickfile = { enabled = true },  -- Enable quick file operations
            bigfile = { enabled = true },    -- Handle big files better
            bufdelete = { enabled = true },  -- Better buffer deletion
            git = { enabled = true },        -- Git integration
            gitbrowse = { enabled = true },  -- Browse git repositories
            lazygit = { enabled = true },    -- LazyGit integration
            rename = { enabled = true },     -- Better file renaming
            scratch = { enabled = true },    -- Scratch buffers
            toggle = { enabled = true },     -- Toggle various options
            words = { enabled = true },      -- Word highlighting
            zen = { enabled = true },        -- Zen mode
        },
        keys = {
            -- Terminal keymaps
            { "<leader>st", function() require("snacks").terminal() end, desc = "Open terminal" },
            { "<leader>sg", function() require("snacks").lazygit() end, desc = "Open LazyGit" },
            
            -- Git browse keymaps
            { "<leader>gB", function() require("snacks").gitbrowse() end, desc = "Git browse" },
            
            -- Scratch buffer keymaps
            { "<leader>ss", function() require("snacks").scratch() end, desc = "Open scratch buffer" },
            { "<leader>sS", function() require("snacks").scratch.select() end, desc = "Select scratch buffer" },
            
            -- Zen mode keymaps
            { "<leader>sz", function() require("snacks").zen() end, desc = "Toggle zen mode" },
            
            -- Rename keymap
            { "<leader>sr", function() require("snacks").rename.rename_file() end, desc = "Rename file" },
            
            -- Toggle keymaps
            { "<leader>sw", function() require("snacks").words.toggle() end, desc = "Toggle word highlighting" },
            
            -- Notification keymap
            { "<leader>sn", function() require("snacks").notifier.show_history() end, desc = "Show notification history" },
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup which-key descriptions (optional)
                    local wk_ok, wk = pcall(require, "which-key")
                    if wk_ok then
                        wk.add({
                            { "<leader>k", group = "snacks" },
                        })
                    end
                end,
            })
        end,
    }
}
