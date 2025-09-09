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
      { "<leader>gd", ":DiffviewOpen<CR>", desc = "Open git diff view" },
      { "<leader>gD", ":DiffviewClose<CR>", desc = "Close git diff view" },
      { "<leader>gh", ":DiffviewFileHistory<CR>", desc = "Git file history" },
      { "<leader>gH", ":DiffviewFileHistory %<CR>", desc = "Current file history" },
      { "<leader>gr", ":DiffviewRefresh<CR>", desc = "Refresh diff view" },
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
