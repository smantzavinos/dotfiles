return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<Leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<Leader>B", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
      { "<Leader>lp", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Logpoint" },
      { "<Leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<Leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    },
    config = function()
      local dap = require("dap")
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
    end,
  }
}
