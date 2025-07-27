local Deferred = {}

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Move selected line / block of text in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Do not move the cursor when joining lines
vim.keymap.set('n', 'J', 'mzJ`z')

-- Center cursor after scrolling with <C-d> and <C-u>
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Center search results after scrolling with n and N
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Deletes selection (to blackhole) and puts previously yanked text
vim.keymap.set('x', '<leader>p', [['_dP]])

-- Delete without yanking (to blackhole)
vim.keymap.set({'n', 'v'}, '<leader>d', [['_d]])

-- Yank to system clipboard (Y for the whole line)
vim.keymap.set({'n', 'v'}, '<leader>y', [['+y]])
vim.keymap.set('n', '<leader>Y', [['+Y]])

-- Begin search/replace with the word under the cursor
vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set('x', '<leader>s', [[:<C-u>%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Disable legacy Ex mode
vim.keymap.set('n', 'Q', '<nop>')

-- Exit insert mode with <C-c>
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Called from ../plugins/fugitive.lua
function Deferred.after_plugin_fugitive()
  -- Open git status
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
end

-- Called from ../plugins/harpoon.lua
function Deferred.after_plugin_harpoon()
  local mark = require('harpoon.mark')
  local ui = require('harpoon.ui')

  vim.keymap.set('n', '<leader>a', mark.add_file)
  vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)
  vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
  vim.keymap.set('n', '<C-j>', function() ui.nav_prev() end)
  vim.keymap.set('n', '<C-k>', function() ui.nav_next() end)
  vim.keymap.set('n', '<C-l>', function() ui.nav_file(2) end)
end

-- Called from ../plugins/telescope.lua
function Deferred.after_plugin_telescope()
  local builtin = require('telescope.builtin')
  -- Find files in project
  vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
  -- Find git files
  vim.keymap.set('n', '<C-p>', builtin.git_files, {})
  -- Grep string interactively
  vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input('Grep > ') })
  end)
  -- Show help tags
  vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
end

-- Called from ../plugins/fugitive.lua
function Deferred.after_plugin_undotree()
  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
end

-- Called from ../plugins/cmp.lua
function Deferred.cmp_mapping()
  local cmp = require('cmp')
  return cmp.mapping.preset.insert {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }
end

-- Called when an LSP server attaches to a buffer
function Deferred.on_lsp_attach(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  -- Go to definition
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  -- Hover info
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  -- Workspace symbol search
  vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
  -- Show diagnostics in floating window
  vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
  -- Go to next diagnostic
  vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
  -- Go to previous diagnostic
  vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
  -- Code actions
  vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
  -- List references
  vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
  -- Rename symbol
  vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
  -- Signature help in insert mode
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
  -- Reformat the buffer using the LSP
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
end

return Deferred
