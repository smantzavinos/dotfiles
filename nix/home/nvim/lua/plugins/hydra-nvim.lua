return {
    {
        "nvimtools/hydra.nvim",
        keys = {
            { "<leader>ww", desc = "Window width hydra" },
            { "<leader>wh", desc = "Window height hydra" },
        },
        config = function()
            local Hydra = require('hydra')

            -- Window width hydra
            Hydra({
                name = 'Window Width',
                mode = 'n',
                body = '<leader>ww',
                config = {
                    color = 'pink',
                    invoke_on_body = true,
                    hint = {
                        border = 'rounded',
                        position = 'middle',
                    },
                },
                heads = {
                    -- Shrink window width by 5
                    { '<', '<C-w>5<', { desc = 'shrink width' } },
                    -- Grow window width by 5
                    { '>', '<C-w>5>', { desc = 'grow width' } },
                    -- Exit hydra
                    { 'q', nil, { exit = true, desc = 'quit' } },
                    { '<Esc>', nil, { exit = true, desc = 'quit' } },
                },
                hint = [[
 Window Width
 ^^^^^^^^^^^^
 _<_: shrink width  _>_: grow width
 ^
 _q_, _<Esc>_: quit
]]
            })

            -- Window height hydra
            Hydra({
                name = 'Window Height',
                mode = 'n',
                body = '<leader>wh',
                config = {
                    color = 'pink',
                    invoke_on_body = true,
                    hint = {
                        border = 'rounded',
                        position = 'middle',
                    },
                },
                heads = {
                    -- Shrink window height by 5
                    { '<', '<C-w>5-', { desc = 'shrink height' } },
                    -- Grow window height by 5
                    { '>', '<C-w>5+', { desc = 'grow height' } },
                    -- Exit hydra
                    { 'q', nil, { exit = true, desc = 'quit' } },
                    { '<Esc>', nil, { exit = true, desc = 'quit' } },
                },
                hint = [[
 Window Height
 ^^^^^^^^^^^^^
 _<_: shrink height  _>_: grow height
 ^
 _q_, _<Esc>_: quit
]]
            })

            -- Optional: Additional window management hydra
            Hydra({
                name = 'Window Management',
                mode = 'n',
                body = '<leader>w',
                config = {
                    color = 'pink',
                    invoke_on_body = false,
                    hint = {
                        border = 'rounded',
                        position = 'middle',
                    },
                },
                heads = {
                    -- Window width (enters the width-specific hydra)
                    { 'w', '<leader>ww', { desc = 'width hydra', exit = true } },
                    -- Window height (enters the height-specific hydra)
                    { 'h', '<leader>wh', { desc = 'height hydra', exit = true } },
                    -- Window navigation
                    { 'j', '<C-w>j', { desc = 'down' } },
                    { 'k', '<C-w>k', { desc = 'up' } },
                    { 'l', '<C-w>l', { desc = 'right' } },
                    -- Window splits
                    { 's', '<C-w>s', { desc = 'split horizontal', exit = true } },
                    { 'v', '<C-w>v', { desc = 'split vertical', exit = true } },
                    -- Close window
                    { 'c', '<C-w>c', { desc = 'close', exit = true } },
                    -- Exit
                    { 'q', nil, { exit = true, desc = 'quit' } },
                    { '<Esc>', nil, { exit = true, desc = 'quit' } },
                },
                hint = [[
 Window Management
 ^^^^^^^^^^^^^^^^^
 _w_: width hydra    _h_: height hydra
 ^
 Navigation: _j_/_k_/_l_
 Split: _s_ horizontal  _v_ vertical
 _c_: close window
 ^
 _q_, _<Esc>_: quit
]]
            })
        end,
    }
}