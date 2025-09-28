-- config/keymaps.lua
-- Core keymaps (non-plugin specific)

-- Tab navigation shortcuts
vim.keymap.set('n', '<C-m>', ':tabnext<CR>', { noremap = true, silent = true, desc = "Next tab" })
vim.keymap.set('n', '<C-n>', ':tabprevious<CR>', { noremap = true, silent = true, desc = "Previous tab" })

-- Alternative tab navigation
vim.keymap.set('n', '<M-m>', ':tabnext<CR>', { desc = "Next tab", noremap = true, silent = true })
vim.keymap.set('n', '<M-n>', ':tabprevious<CR>', { desc = "Previous tab", noremap = true, silent = true })

-- Tab management shortcuts
vim.keymap.set('n', '<leader>Tn', ':tabnew<CR>', { desc = "New tab", noremap = true, silent = true })
vim.keymap.set('n', '<leader>Tc', ':tabclose<CR>', { desc = "Close tab", noremap = true, silent = true })

-- Tab movement shortcuts
vim.keymap.set('n', '<M-S-m>', ':tabmove +1<CR>', { desc = "Move tab right", noremap = true, silent = true })
vim.keymap.set('n', '<M-S-n>', ':tabmove -1<CR>', { desc = "Move tab left", noremap = true, silent = true })

-- Yank line with Y
vim.keymap.set('n', 'Y', 'yy', { noremap = true, silent = true, desc = "Yank line" })

-- Diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show diagnostics" })
vim.keymap.set('n', '<leader>D', function()
  local diagnostics = vim.diagnostic.get(0)
  local lines = {}
  for _, d in ipairs(diagnostics) do
    table.insert(lines, string.format("[%s] %s (line %d)", d.severity, d.message, d.lnum + 1))
  end
  local text = table.concat(lines, '\n')
  vim.fn.setreg('+', text) -- Copy to system clipboard
  print("Diagnostics copied to clipboard")
end, { noremap = true, silent = true, desc = "Copy diagnostics to clipboard" })

-- Insert date
vim.keymap.set("n", "<leader>id", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
end, { desc = "Insert date" })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Go to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Go to lower window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Go to upper window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Go to right window" })

-- Resize windows with arrows
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = "Increase window height" })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = "Decrease window height" })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = "Decrease window width" })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = "Increase window width" })

-- Move text up and down
vim.keymap.set('v', '<A-j>', ':m .+1<CR>==', { desc = "Move text down" })
vim.keymap.set('v', '<A-k>', ':m .-2<CR>==', { desc = "Move text up" })
vim.keymap.set('x', '<A-j>', ":move '>+1<CR>gv-gv", { desc = "Move text down" })
vim.keymap.set('x', '<A-k>', ":move '<-2<CR>gv-gv", { desc = "Move text up" })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', { desc = "Indent left" })
vim.keymap.set('v', '>', '>gv', { desc = "Indent right" })

-- Clear search highlighting
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { desc = "Clear search highlighting" })

-- Better paste
vim.keymap.set('v', 'p', '"_dP', { desc = "Paste without yanking" })