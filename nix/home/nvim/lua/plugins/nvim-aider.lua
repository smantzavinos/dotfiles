return {
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    keys = {
      { "<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
      { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
      { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
      { "<leader>a+", "<cmd>Aider add<cr>", desc = "Add File" },
      { "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
      { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
      { "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
    },
    dependencies = {
      "folke/snacks.nvim",
      -- Optional dependencies
      "nvim-tree/nvim-tree.lua",
    },
    config = function()
      require("nvim_aider").setup({
        -- Command that executes Aider
        aider_cmd = "aider",
        -- Command line arguments passed to aider
        args = {
          "--no-auto-commits",
          "--pretty",
          "--stream",
        },
        -- Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
        auto_reload = true,
      })
    end
  }
}
