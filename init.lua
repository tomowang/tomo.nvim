require("config.lazy")

local function open_nvim_tree(data)
  local api = require("nvim-tree.api")
  local path = data.file

  -- 1. If data.file is empty (none), use the current working directory
  if path == "" then
    api.tree.open()
    return
  end

  -- 2. Check if the path is a directory or a file
  local is_dir = vim.fn.isdirectory(path) == 1

  if is_dir then
    -- If it's a directory, change to it and open
    vim.cmd.cd(path)
    api.tree.open()
  else
    -- 3. If it's a file, get the parent folder (base folder), cd there, and open
    local base_folder = vim.fn.fnamemodify(path, ":h")
    vim.cmd.cd(base_folder)
    api.tree.open()
  end
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})
-- vim.keymap.set('', 't', function()
--   hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
-- end, {remap=true})
-- vim.keymap.set('', 'T', function()
--   hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
-- end, {remap=true})

-- esc to exit terminal
vim.keymap.set('t', '<esc><esc>', [[<C-\><C-n>]], {noremap = true})
-- new vertical terminal
vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>TermNew dir=%:p:h direction=vertical<CR>", {})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.wo.number = true

vim.opt.clipboard = "unnamedplus"

vim.keymap.set('n', '<leader>md', ':vertical botright terminal leaf -w %<CR>', { 
    desc = 'Preview Markdown with Leaf',
    silent = true 
})
