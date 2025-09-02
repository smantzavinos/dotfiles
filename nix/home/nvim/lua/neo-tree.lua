return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            -- Main toggles
            { "<Leader>e", ":Neotree toggle filesystem left<CR>", desc = "Toggle Neo-tree filesystem", noremap = true, silent = true },
            { "<Leader>bf", ":Neotree toggle buffers left<CR>", desc = "Toggle Neo-tree buffers", noremap = true, silent = true },
            { "<Leader>gs", ":Neotree toggle git_status left<CR>", desc = "Toggle Neo-tree git status", noremap = true, silent = true },
            
            -- Quick navigation
            { "<Leader>gf", ":Neotree reveal filesystem left<CR>", desc = "Reveal current file in Neo-tree", noremap = true, silent = true },
        },
        config = function()
            -- Disable netrw for better Neo-tree integration
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("neo-tree").setup({
                close_if_last_window = true, -- Close Neo-tree if it's the last window
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                enable_normal_mode_for_inputs = false,
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
                sort_case_insensitive = false,
                
                -- Default component configs
                default_component_configs = {
                    container = {
                        enable_character_fade = true
                    },
                    indent = {
                        indent_size = 2,
                        padding = 1,
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        highlight = "NeoTreeIndentMarker",
                        with_expanders = nil,
                        expander_collapsed = "",
                        expander_expanded = "",
                        expander_highlight = "NeoTreeExpander",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "󰜌",
                        default = "*",
                        highlight = "NeoTreeFileIcon"
                    },
                    modified = {
                        symbol = "[+]",
                        highlight = "NeoTreeModified",
                    },
                    name = {
                        trailing_slash = false,
                        use_git_status_colors = true,
                        highlight = "NeoTreeFileName",
                    },
                    git_status = {
                        symbols = {
                            added     = "✚",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "󰁕",
                            untracked = "",
                            ignored   = "",
                            unstaged  = "󰄱",
                            staged    = "",
                            conflict  = "",
                        }
                    },
                    file_size = {
                        enabled = true,
                        required_width = 64,
                    },
                    type = {
                        enabled = true,
                        required_width = 122,
                    },
                    last_modified = {
                        enabled = true,
                        required_width = 88,
                    },
                    created = {
                        enabled = true,
                        required_width = 110,
                    },
                    symlink_target = {
                        enabled = false,
                    },
                },
                
                -- Commands for custom actions
                commands = {
                    -- Custom command to copy file path to clipboard
                    copy_path = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        vim.fn.setreg('+', path, 'c')
                        print("Copied path: " .. path)
                    end,
                    
                    -- Custom command to copy relative path to clipboard
                    copy_relative_path = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        local relative_path = vim.fn.fnamemodify(path, ":.")
                        vim.fn.setreg('+', relative_path, 'c')
                        print("Copied relative path: " .. relative_path)
                    end,
                    
                    -- Custom command to copy filename to clipboard
                    copy_filename = function(state)
                        local node = state.tree:get_node()
                        local filename = node.name
                        vim.fn.setreg('+', filename, 'c')
                        print("Copied filename: " .. filename)
                    end,
                },
                
                -- Window configuration
                window = {
                    position = "left",
                    width = 40,
                    mapping_options = {
                        noremap = true,
                        nowait = true,
                    },
                    mappings = {
                        -- Navigation
                        ["<space>"] = { 
                            "toggle_node", 
                            nowait = false,
                        },
                        ["<2-LeftMouse>"] = "open",
                        ["<cr>"] = "open",
                        ["<esc>"] = "cancel",
                        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
                        ["l"] = "focus_preview",
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        ["t"] = "open_tabnew",
                        ["w"] = "open_with_window_picker",
                        ["C"] = "close_node",
                        ["z"] = "close_all_nodes",
                        ["Z"] = "expand_all_nodes",
                        
                        -- File operations
                        ["a"] = { 
                            "add",
                            config = {
                                show_path = "none"
                            }
                        },
                        ["A"] = "add_directory",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy",
                        ["m"] = "move",
                        
                        -- Navigation and view
                        ["q"] = "close_window",
                        ["R"] = "refresh",
                        ["?"] = "show_help",
                        ["<"] = "prev_source",
                        [">"] = "next_source",
                        ["i"] = "show_file_details",
                        
                        -- Custom path operations
                        ["Y"] = "copy_path",
                        ["gy"] = "copy_relative_path",
                        ["gY"] = "copy_filename",
                        
                        -- Git operations (when in git_status view)
                        ["gu"] = "git_unstage_file",
                        ["ga"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",
                        
                        -- Advanced navigation
                        ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["og"] = { "order_by_git_status", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                        
                        -- Toggle hidden files
                        ["H"] = "toggle_hidden",
                        ["."] = "set_root",
                        ["[g"] = "prev_git_modified",
                        ["]g"] = "next_git_modified",
                        
                        -- Focus parent
                        ["<bs>"] = "navigate_up",
                        ["/"] = "fuzzy_finder",
                        ["D"] = "fuzzy_finder_directory",
                        ["#"] = "fuzzy_sorter",
                        ["f"] = "filter_on_submit",
                        ["<c-x>"] = "clear_filter",
                        ["[c"] = "prev_git_modified",
                        ["]c"] = "next_git_modified",
                    }
                },
                
                -- Filesystem specific settings
                filesystem = {
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        hide_hidden = true,
                        hide_by_name = {
                            ".DS_Store",
                            "thumbs.db",
                            "node_modules"
                        },
                        hide_by_pattern = {
                            "*.meta",
                            "*/src/*/tsconfig.json",
                        },
                        always_show = {
                            ".gitignored",
                        },
                        never_show = {
                            ".DS_Store",
                            "thumbs.db",
                        },
                        never_show_by_pattern = {
                            ".null-ls_*",
                        },
                    },
                    follow_current_file = {
                        enabled = false,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = false,
                    hijack_netrw_behavior = "open_default",
                    use_libuv_file_watcher = false,
                    window = {
                        mappings = {
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["H"] = "toggle_hidden",
                            ["/"] = "fuzzy_finder",
                            ["D"] = "fuzzy_finder_directory",
                            ["#"] = "fuzzy_sorter",
                            ["f"] = "filter_on_submit",
                            ["<c-x>"] = "clear_filter",
                            ["[g"] = "prev_git_modified",
                            ["]g"] = "next_git_modified",
                            ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["og"] = { "order_by_git_status", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        },
                        fuzzy_finder_mappings = {
                            ["<down>"] = "move_cursor_down",
                            ["<C-n>"] = "move_cursor_down",
                            ["<up>"] = "move_cursor_up",
                            ["<C-p>"] = "move_cursor_up",
                        },
                    },
                    
                    commands = {}
                },
                
                -- Buffers specific settings
                buffers = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = true,
                    show_unloaded = true,
                    window = {
                        mappings = {
                            ["bd"] = "buffer_delete",
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        }
                    },
                },
                
                -- Git status specific settings
                git_status = {
                    window = {
                        position = "float",
                        mappings = {
                            ["A"]  = "git_add_all",
                            ["gu"] = "git_unstage_file",
                            ["ga"] = "git_add_file",
                            ["gr"] = "git_revert_file",
                            ["gc"] = "git_commit",
                            ["gp"] = "git_push",
                            ["gg"] = "git_commit_and_push",
                            ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        }
                    }
                },
                
                -- Event handlers
                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function(file_path)
                            -- Auto close Neo-tree when opening a file
                            require("neo-tree.command").execute({ action = "close" })
                        end
                    },
                    {
                        event = "file_open_requested",
                        handler = function()
                            -- Auto close Neo-tree when opening a file
                            require("neo-tree.command").execute({ action = "close" })
                        end
                    },
                }
            })
            
            -- Additional keybindings for enhanced workflow
            vim.keymap.set('n', '<Leader>tf', ':Neotree focus filesystem left<CR>', { 
                desc = "Focus Neo-tree filesystem", 
                noremap = true, 
                silent = true 
            })
            
            vim.keymap.set('n', '<Leader>tb', ':Neotree focus buffers left<CR>', { 
                desc = "Focus Neo-tree buffers", 
                noremap = true, 
                silent = true 
            })
            
            vim.keymap.set('n', '<Leader>tg', ':Neotree focus git_status left<CR>', { 
                desc = "Focus Neo-tree git status", 
                noremap = true, 
                silent = true 
            })
            
            -- Quick reveal current file
            vim.keymap.set('n', '<Leader>tr', ':Neotree reveal<CR>', { 
                desc = "Reveal current file in Neo-tree", 
                noremap = true, 
                silent = true 
            })
            
            -- Close all Neo-tree windows
            vim.keymap.set('n', '<Leader>tc', ':Neotree close<CR>', { 
                desc = "Close all Neo-tree windows", 
                noremap = true, 
                silent = true 
            })
        end,
    },
}