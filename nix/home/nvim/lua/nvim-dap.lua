return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require('dap')
      -- Keybindings for nvim-dap
      vim.api.nvim_set_keymap('n', '<F5>', ':lua require"dap".continue()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F10>', ':lua require"dap".step_over()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F11>', ':lua require"dap".step_into()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F12>', ':lua require"dap".step_out()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>b', ':lua require"dap".toggle_breakpoint()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>B', ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>lp', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>dr', ':lua require"dap".repl.open()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>dl', ':lua require"dap".run_last()<CR>', { noremap = true, silent = true })

      -- Uncomment and adjust these configurations as needed
      -- dap.adapters.lldb = {
      --   type = 'executable',
      --   command = '/usr/bin/lldb-vscode', -- adjust as needed
      --   name = "lldb"
      -- }
      -- dap.configurations.cpp = {
      --   {
      --     name = "Launch",
      --     type = "lldb",
      --     request = "launch",
      --     program = function()
      --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      --     end,
      --     cwd = '${workspaceFolder}',
      --     stopOnEntry = false,
      --     args = {},
      --   },
      -- }
      -- dap.configurations.c = dap.configurations.cpp
      -- dap.configurations.rust = dap.configurations.cpp
    end
  }
}
