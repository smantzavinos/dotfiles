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
      { "<leader>gdc", ":DiffviewClose<CR>", desc = "Close git diff view" },
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
      -- Create submodule popup using Neogit's popup builder
      local function create_submodule_popup()
        local popup = require("neogit.lib.popup")
        
        local function execute_and_refresh(cmd, description)
          vim.notify("Executing: " .. cmd, vim.log.levels.INFO)
          local result = vim.fn.system(cmd)
          local exit_code = vim.v.shell_error
          
          if exit_code == 0 then
            vim.notify(description .. " completed successfully", vim.log.levels.INFO)
            -- Refresh Neogit buffer
            require("neogit").refresh()
          else
            vim.notify(description .. " failed: " .. result, vim.log.levels.ERROR)
          end
        end
        
        local function add_submodule()
          local url = vim.fn.input("Submodule URL: ")
          if url ~= "" then
            local path = vim.fn.input("Submodule path: ")
            if path ~= "" then
              execute_and_refresh("git submodule add " .. vim.fn.shellescape(url) .. " " .. vim.fn.shellescape(path), "Add submodule")
            end
          end
        end
        
        return popup.builder()
          :name("NeogitSubmodulePopup")
          :new_action_group("Submodule Operations")
          :action("u", "Update submodules", function()
            execute_and_refresh("git submodule update --recursive", "Update submodules")
          end)
          :action("p", "Populate submodules", function()
            execute_and_refresh("git submodule update --init --recursive", "Populate submodules")
          end)
          :action("f", "Fetch submodules", function()
            execute_and_refresh("git submodule foreach git fetch", "Fetch submodules")
          end)
          :action("s", "Sync submodule URLs", function()
            execute_and_refresh("git submodule sync --recursive", "Sync submodule URLs")
          end)
          :action("l", "List submodules", function()
            vim.cmd("!git submodule status")
          end)
          :action("a", "Add submodule", add_submodule)
          :build()
      end

      -- Create a named function for the submodule popup that can be referenced in help
      local function submodule_popup()
        create_submodule_popup():show()
      end

      require("neogit").setup({
        integrations = {
          telescope = false,
          fzf_lua = true,
          diffview = true
        },
        kind = "tab",  -- Open in a new tab by default
        graph_style = "unicode",
        git_services = {
          ["github.com"] = {
            pull_request = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
            commit = "https://github.com/${owner}/${repository}/commit/${commit_hash}",
            tree = "https://github.com/${owner}/${repository}/tree/${branch_name}",
          },
          ["bitbucket.org"] = {
            pull_request = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
            commit = "https://bitbucket.org/${owner}/${repository}/commits/${commit_hash}",
            tree = "https://bitbucket.org/${owner}/${repository}/src/${branch_name}",
          },
          ["gitlab.com"] = {
            pull_request = "https://gitlab.com/${owner}/${repository}/-/merge_requests/new?merge_request[source_branch]=${branch_name}",
            commit = "https://gitlab.com/${owner}/${repository}/-/commit/${commit_hash}",
            tree = "https://gitlab.com/${owner}/${repository}/-/tree/${branch_name}",
          },
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
        -- Add submodule popup mapping to status buffer
        mappings = {
          status = {
            ["o"] = submodule_popup,
          },
        },
      })
      
      -- Register our submodule command in the help system's popups section
      -- We need to wait for Neogit to be fully loaded before modifying the help system
      vim.schedule(function()
        pcall(function()
          local help_actions = require("neogit.popups.help.actions")
          if help_actions and help_actions.popups then
            local original_popups = help_actions.popups
            help_actions.popups = function(env)
              local items = original_popups(env)
              -- Add our submodule popup to the commands section
              table.insert(items, {
                name = "Submodule",
                keys = {"o"},
                cmp = "o",
                fn = submodule_popup
              })
              -- Sort to maintain alphabetical order
              table.sort(items, function(a, b)
                return a.cmp < b.cmp
              end)
              return items
            end
          end
        end)
      end)
    end,
  }
}
