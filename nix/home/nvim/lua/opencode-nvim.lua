return {
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            "folke/snacks.nvim", -- Required for better prompt input and embedded terminal
        },
        opts = {
            -- Configuration options can be added here
        },
        keys = {
            -- Recommended keymaps from the documentation
            { "<leader>oA", function() require("opencode").ask() end, desc = "Ask opencode" },
            { "<leader>oa", function() require("opencode").ask("@cursor: ") end, desc = "Ask opencode about this", mode = "n" },
            { "<leader>oa", function() require("opencode").ask("@selection: ") end, desc = "Ask opencode about selection", mode = "v" },
            { "<leader>ot", function() require("opencode").toggle() end, desc = "Toggle embedded opencode" },
            { "<leader>on", function() require("opencode").command("session_new") end, desc = "New session" },
            { "<leader>oy", function() require("opencode").command("messages_copy") end, desc = "Copy last message" },
            { "<S-C-u>", function() require("opencode").command("messages_half_page_up") end, desc = "Scroll messages up" },
            { "<S-C-d>", function() require("opencode").command("messages_half_page_down") end, desc = "Scroll messages down" },
            { "<leader>op", function() require("opencode").select_prompt() end, desc = "Select prompt", mode = { "n", "v" } },
            
            -- Example: keymap for custom prompt
            { "<leader>oe", function() require("opencode").prompt("Explain @cursor and its context") end, desc = "Explain code near cursor" },
        },
        config = function(_, opts)
            local opencode = require("opencode")
            
            -- Setup with options
            opencode.setup(opts)
        end,
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup which-key descriptions
                    local wk_ok, wk = pcall(require, "which-key")
                    if wk_ok then
                        wk.add({
                            { "<leader>o", group = "opencode" },
                        })
                    end
                end,
            })
        end,
    }
}