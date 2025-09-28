-- config/autocmds.lua
-- Autocommands for file types and behaviors

-- Enable autoread and set up autocommand for auto-reloading buffers
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  command = "checktime",
  desc = "Check for file changes and reload"
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
  desc = "Highlight yanked text"
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace on save"
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto-resize splits when window is resized"
})

-- Close certain filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  desc = "Close certain filetypes with <q>"
})

-- Keymaps and settings for Markdown / Obsidian
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = true
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Function to cycle bullet points
    local function cycle_bullet()
      local line = vim.api.nvim_get_current_line()
      local bullets = { "-", "*", "+" }
      local new_line, found = line:gsub(
        "^%s*([%-%*%+])", -- Match leading whitespace and one of the bullet characters
        function(bullet)
          for i, b in ipairs(bullets) do
            if b == bullet then
              -- Cycle to the next bullet
              local next_bullet_index = (i % #bullets) + 1
              return bullets[next_bullet_index]
            end
          end
        end,
        1 -- Only replace the first occurrence
      )
      if found > 0 then
        vim.api.nvim_set_current_line(new_line)
      end
    end

    -- Cycle checkbox states for obsidian.nvim
    map("n", "<leader>x", "<cmd>ObsidianCycleCheckbox<CR>", { silent = true, desc = "Cycle Checkbox" })

    -- Create new list items
    map("n", "<S-CR>", "o[ ] <Esc>", { silent = true, desc = "New TODO Item" })

    -- Cycle bullet type
    map("n", "<C-t>", cycle_bullet, { silent = true, desc = "Cycle Bullet Type" })
    
    -- keep indentation but turn off automatic list / comment continuation
    vim.opt_local.autoindent = true
    vim.opt_local.formatoptions:remove({ "r", "o", "n" })
    
    -- Enable line wrapping for markdown files
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
  desc = "Markdown-specific settings and keymaps"
})