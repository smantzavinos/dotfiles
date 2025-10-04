return {
    {
        "jedrzejboczar/possession.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("possession").setup({
                session_dir = vim.fn.stdpath("data") .. "/possession",
                silent = false,
                load_silent = true,
                debug = false,
                prompt_no_cr = false,
                autosave = {
                    current = false,
                    cwd = true, -- Auto-save session for current working directory
                    tmp = false,
                    tmp_name = "tmp",
                    on_load = true,
                    on_quit = true,
                },
                autoload = "auto_cwd", -- Auto-load session based on current working directory
                commands = {
                    save = "PossessionSave",
                    load = "PossessionLoad",
                    save_cwd = "PossessionSaveCwd",
                    load_cwd = "PossessionLoadCwd",
                    rename = "PossessionRename",
                    close = "PossessionClose",
                    delete = "PossessionDelete",
                    show = "PossessionShow",
                    pick = "PossessionPick",
                    list = "PossessionList",
                    list_cwd = "PossessionListCwd",
                    migrate = "PossessionMigrate",
                },
                hooks = {
                    before_save = function(name)
                        return {}
                    end,
                    after_save = function(name, user_data, aborted)
                        if not aborted then
                            vim.notify("Session '" .. name .. "' saved", vim.log.levels.INFO)
                        end
                    end,
                    before_load = function(name, user_data)
                        return user_data
                    end,
                    after_load = function(name, user_data)
                        vim.notify("Session '" .. name .. "' loaded", vim.log.levels.INFO)
                    end,
                },
                plugins = {
                    close_windows = {
                        hooks = { "before_save", "before_load" },
                        preserve_layout = true,
                        match = {
                            floating = true,
                            buftype = {},
                            filetype = {},
                            custom = false,
                        },
                    },
                    delete_hidden_buffers = {
                        hooks = {
                            "before_load",
                            vim.o.sessionoptions:match("buffer") and "before_save",
                        },
                        force = false,
                    },
                    nvim_tree = true,
                    neo_tree = true,
                    symbols_outline = true,
                    outline = true,
                    tabby = true,
                    dap = true,
                    dapui = true,
                    neotest = true,
                    kulala = true,
                    delete_buffers = false,
                    stop_lsp_clients = false,
                },
                telescope = {
                    previewer = {
                        enabled = true,
                        previewer = "pretty",
                        wrap_lines = true,
                        include_empty_plugin_data = false,
                        cwd_colors = {
                            cwd = "Comment",
                            tab_cwd = { "#cc241d", "#b16286", "#d79921", "#689d6a", "#d65d0e", "#458588" }
                        }
                    },
                    list = {
                        default_action = "load",
                        mappings = {
                            save = { n = "<c-x>", i = "<c-x>" },
                            load = { n = "<c-v>", i = "<c-v>" },
                            delete = { n = "<c-t>", i = "<c-t>" },
                            rename = { n = "<c-r>", i = "<c-r>" },
                            grep = { n = "<c-g>", i = "<c-g>" },
                            find = { n = "<c-f>", i = "<c-f>" },
                        },
                    },
                },
            })

            -- Keybindings for session management
            vim.keymap.set("n", "<leader>ss", ":PossessionSave<CR>", { 
                desc = "Save session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sl", ":PossessionLoad<CR>", { 
                desc = "Load session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sc", ":PossessionClose<CR>", { 
                desc = "Close session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sd", ":PossessionDelete<CR>", { 
                desc = "Delete session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sp", ":PossessionPick<CR>", { 
                desc = "Pick session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sL", ":PossessionList<CR>", { 
                desc = "List sessions", 
                noremap = true, 
                silent = true 
            })

            -- CWD-specific session commands
            vim.keymap.set("n", "<leader>sS", ":PossessionSaveCwd<CR>", { 
                desc = "Save CWD session", 
                noremap = true, 
                silent = true 
            })
            vim.keymap.set("n", "<leader>sC", ":PossessionLoadCwd<CR>", { 
                desc = "Load CWD session", 
                noremap = true, 
                silent = true 
            })
        end,
    },
}