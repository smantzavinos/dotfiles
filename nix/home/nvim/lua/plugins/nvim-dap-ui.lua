return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      local ok_dapui, dapui = pcall(require, "dapui")
      
      if not ok_dap or not ok_dapui then
        vim.notify("Failed to load DAP or DAP UI", vim.log.levels.ERROR)
        return
      end
      
      dapui.setup({
        -- Add basic configuration to avoid errors
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
      })
      
      -- Initialize dapui when dap events occur
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  }
}
