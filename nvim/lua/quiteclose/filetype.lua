-- Filetype-specific indentation settings
local SPACES  = 'spaces'
local PER_TAB = 'per-tab'
local DEFAULT = {width = 2, fill = SPACES}

local INDENT_FILETYPES = {
  {2, SPACES,  'lua,html,css,scss,javascript'},
  {4, SPACES,  'markdown,python,txt'},
  {2, PER_TAB, 'zig'},
  {4, PER_TAB, 'Dockerfile,shell,go,Makefile'},
}

local function set_whitespace(width, fill)
  vim.opt.shiftwidth = width
  vim.opt.tabstop = width
  if fill == SPACES then
    vim.opt.expandtab = true
    vim.opt.listchars = {
      lead = ' ',
      nbsp = '~',
      tab = '··',
      trail = '·',
    }
  else
    vim.opt.expandtab = false
    vim.opt.listchars = {
      lead = '·',
      nbsp = '~',
      tab = '  ',
      trail = '·',
    }
  end
end

local function defer_whitespace(width, fill)
  function callback()
    print('Filetype trigger: ' .. vim.bo.filetype .. ' | Indent: ' .. width .. ' ' .. fill)
    vim.schedule(function()
      set_whitespace(width, fill)
    end)
  end
  return callback
end


-- Apply indentation settings
set_whitespace(DEFAULT.width, DEFAULT.fill)
vim.api.nvim_create_augroup('setFiletypeWhitespace', { clear = true })
for _, style in pairs(INDENT_FILETYPES) do
  local width, fill, pattern = style[1], style[2], style[3]
  vim.api.nvim_create_autocmd('Filetype', {
    group = 'setFiletypeWhitespace',
    pattern = pattern,
    callback = defer_whitespace(width, fill)
  })
end
