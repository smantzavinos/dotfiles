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
      { "<leader>gm", ":DiffviewOpen main..HEAD<CR>", desc = "Diff against main branch" },
      { "<leader>go", ":DiffviewOpen origin/main..HEAD<CR>", desc = "Diff against origin/main" },
      { "<leader>gb", function()
          local branch = vim.fn.input("Compare against branch: ", "main")
          if branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch .. "..HEAD")
          end
        end, desc = "Diff against custom branch" },
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
