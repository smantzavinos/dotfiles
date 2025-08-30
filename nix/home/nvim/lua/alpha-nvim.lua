return {
    {
        "goolord/alpha-nvim",
        dependencies = { 
            "nvim-tree/nvim-web-devicons",
            "jedrzejboczar/possession.nvim"
        },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Set header
            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
            }

            -- Set menu
            dashboard.section.buttons.val = {
                dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("f", "  > Find file", ":FzfLua files<CR>"),
                dashboard.button("r", "  > Recent files", ":FzfLua oldfiles<CR>"),
                dashboard.button("g", "  > Find text", ":FzfLua live_grep<CR>"),
                dashboard.button("c", "  > Configuration", ":e ~/.config/nvim/init.lua<CR>"),
                dashboard.button("s", "  > Sessions", ":PossessionList<CR>"),
                dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
            }

            -- Function to get session info
            local function get_session_info()
                local possession = require("possession.session")
                local current_session = possession.get_session_name()
                
                if current_session then
                    return "Current session: " .. current_session
                else
                    return "No active session"
                end
            end

            -- Function to get recent sessions
            local function get_recent_sessions()
                local query = require("possession.query")
                local sessions = query.as_list()
                
                if #sessions == 0 then
                    return { "No sessions found" }
                end
                
                local recent_sessions = {}
                for i = 1, math.min(5, #sessions) do
                    local session = sessions[i]
                    table.insert(recent_sessions, "  " .. session.name)
                end
                
                return recent_sessions
            end

            -- Custom footer with session info
            local function footer()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                local session_info = get_session_info()
                
                return {
                    "",
                    session_info,
                    "",
                    "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
                }
            end

            dashboard.section.footer.val = footer()

            -- Session buttons section
            local function session_buttons()
                local buttons = {}
                local query = require("possession.query")
                local sessions = query.as_list()
                
                if #sessions > 0 then
                    table.insert(buttons, { type = "text", val = "Recent Sessions", opts = { hl = "SpecialComment", position = "center" } })
                    table.insert(buttons, { type = "padding", val = 1 })
                    
                    for i = 1, math.min(5, #sessions) do
                        local session = sessions[i]
                        local shortcut = tostring(i)
                        local button = dashboard.button(
                            shortcut, 
                            "  " .. session.name, 
                            ":PossessionLoad " .. session.name .. "<CR>"
                        )
                        table.insert(buttons, button)
                    end
                    
                    table.insert(buttons, { type = "padding", val = 1 })
                end
                
                return buttons
            end

            -- Layout
            local config = {
                layout = {
                    { type = "padding", val = 2 },
                    dashboard.section.header,
                    { type = "padding", val = 2 },
                    dashboard.section.buttons,
                    { type = "padding", val = 1 },
                    {
                        type = "group",
                        val = function()
                            return session_buttons()
                        end,
                    },
                    { type = "padding", val = 1 },
                    dashboard.section.footer,
                },
                opts = {
                    margin = 5,
                },
            }

            -- Send config to alpha
            alpha.setup(config)

            -- Disable folding on alpha buffer
            vim.cmd([[
                autocmd FileType alpha setlocal nofoldenable
            ]])

            -- Auto-refresh alpha when sessions change
            local group = vim.api.nvim_create_augroup("AlphaRefresh", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "PossessionSavePost",
                callback = function()
                    if vim.bo.filetype == "alpha" then
                        require("alpha").redraw()
                    end
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "PossessionLoadPost",
                callback = function()
                    if vim.bo.filetype == "alpha" then
                        require("alpha").redraw()
                    end
                end,
            })
        end,
    },
}