return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    keys = {
      { "<leader>gs", ":Neogit<CR>", desc = "Open Neogit" },
      { "<leader>gdd", ":DiffviewOpen<CR>", desc = "Git diff (unstaged changes)" },
      { "<leader>gdD", ":DiffviewClose<CR>", desc = "Close git diff view" },
      { "<leader>gdh", ":DiffviewFileHistory<CR>", desc = "Git diff file history" },
      { "<leader>gdH", ":DiffviewFileHistory %<CR>", desc = "Git diff current file history" },
      { "<leader>gdr", ":DiffviewRefresh<CR>", desc = "Git diff refresh" },
      { "<leader>gdm", ":DiffviewOpen main..HEAD<CR>", desc = "Git diff main" },
      { "<leader>gdo", ":DiffviewOpen origin/main..HEAD<CR>", desc = "Git diff origin/main" },
      { "<leader>gdb", function()
          local branch = vim.fn.input("Compare against branch: ", "main")
          if branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch .. "..HEAD")
          end
        end, desc = "Git diff branch (custom)" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          telescope = false,
          fzf_lua = true,
          diffview = true
        },
        kind = "tab",  -- Open in a new tab by default
        graph_style = "unicode",
        git_services = {
          ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
          ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
          ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/-/merge_requests/new?merge_request[source_branch]=${branch_name}",
        },
        -- Ensure diffs are shown with syntax highlighting
        sections = {
          untracked = {
            folded = false
          },
          unstaged = {
            folded = false
          },
          staged = {
            folded = false
          },
        },
      })
    end,
  }
}
