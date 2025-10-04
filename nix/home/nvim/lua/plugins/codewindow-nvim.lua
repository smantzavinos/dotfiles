return {
    {
        "gorbit99/codewindow.nvim",
        event = "VeryLazy",
        config = function()
            local codewindow = require('codewindow')
            
            -- Setup codewindow with custom configuration
            codewindow.setup({
                active_in_terminals = false,        -- Don't show minimap in terminal buffers
                auto_enable = false,                -- Don't auto-open (use manual toggle)
                exclude_filetypes = {               -- Filetypes to exclude
                    'help',
                    'neo-tree',
                    'alpha',
                    'dashboard',
                    'lazy',
                    'mason',
                    'notify',
                    'toggleterm',
                    'lazyterm',
                },
                max_minimap_height = nil,           -- No height limit
                max_lines = nil,                    -- No line limit for auto-enable
                minimap_width = 20,                 -- Width of the minimap text area
                use_lsp = true,                     -- Show LSP diagnostics (errors/warnings)
                use_treesitter = true,              -- Use treesitter for syntax highlighting
                use_git = true,                     -- Show git additions/deletions
                width_multiplier = 4,               -- Characters per dot
                z_index = 1,                        -- Floating window z-index
                show_cursor = true,                 -- Show cursor position in minimap
                screen_bounds = 'lines',            -- Display mode: 'lines' or 'background'
                window_border = 'single',           -- Border style
                relative = 'win',                   -- Relative to current window
                events = {                          -- Events that trigger minimap update
                    'TextChanged',
                    'InsertLeave',
                    'DiagnosticChanged',
                    'FileWritePost'
                },
            })
            
            -- Keybindings for codewindow
            vim.keymap.set('n', '<leader>mo', function()
                codewindow.open_minimap()
            end, { 
                desc = "Minimap: Open",
                noremap = true, 
                silent = true 
            })
            
            vim.keymap.set('n', '<leader>mc', function()
                codewindow.close_minimap()
            end, { 
                desc = "Minimap: Close",
                noremap = true, 
                silent = true 
            })
            
            vim.keymap.set('n', '<leader>mm', function()
                codewindow.toggle_minimap()
            end, { 
                desc = "Minimap: Toggle",
                noremap = true, 
                silent = true 
            })
            
            vim.keymap.set('n', '<leader>mf', function()
                codewindow.toggle_focus()
            end, { 
                desc = "Minimap: Toggle focus",
                noremap = true, 
                silent = true 
            })
            
            -- Custom highlight groups for better integration with your theme
            -- These can be customized to match your color scheme
            vim.api.nvim_set_hl(0, 'CodewindowBorder', { link = 'FloatBorder' })
            vim.api.nvim_set_hl(0, 'CodewindowBackground', { link = 'NormalFloat' })
            vim.api.nvim_set_hl(0, 'CodewindowWarn', { fg = '#fab387' })  -- Catppuccin orange
            vim.api.nvim_set_hl(0, 'CodewindowError', { fg = '#f38ba8' }) -- Catppuccin red
            vim.api.nvim_set_hl(0, 'CodewindowAddition', { fg = '#a6e3a1' }) -- Catppuccin green
            vim.api.nvim_set_hl(0, 'CodewindowDeletion', { fg = '#f38ba8' }) -- Catppuccin red
        end,
    },
}
