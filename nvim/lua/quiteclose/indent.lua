-- Indentation mode constants
local SPACES  = 'spaces'
local PER_TAB = 'per-tab'
local DEFAULT = { width = 2, fill = SPACES }

-- Filetype-specific indentation rules
local INDENT_FILETYPES = {
  { width = 2, fill = SPACES,  pattern = 'lua,html,css,scss,javascript' },
  { width = 4, fill = SPACES,  pattern = 'markdown,python,text' },
  { width = 2, fill = PER_TAB, pattern = 'zig' },
  { width = 4, fill = PER_TAB, pattern = 'Dockerfile,sh,go,Makefile' },
}

local IGNORE_FILETYPES = { 'netrw' }

-- Collect all configured filetypes
local CONFIGURED = {}
for _, style in ipairs(INDENT_FILETYPES) do
  for ft in style.pattern:gmatch('[^,]+') do
    CONFIGURED[ft] = true
  end
end
for _, ft in ipairs(IGNORE_FILETYPES) do
  CONFIGURED[ft] = true
end

-- Compute relative path from one file to another
local function relative_path(from, to)
  local function split(path)
    local parts = {}
    for part in path:gmatch("[^/]+") do
      table.insert(parts, part)
    end
    return parts
  end
  local from_parts = split(vim.fn.fnamemodify(from, ':p'))
  local to_parts   = split(vim.fn.fnamemodify(to, ':p'))
  local i = 1
  while i <= math.min(#from_parts, #to_parts) and from_parts[i] == to_parts[i] do
    i = i + 1
  end
  local rel = {}
  for _ = i, #from_parts do table.insert(rel, '..') end
  for j = i, #to_parts do table.insert(rel, to_parts[j]) end
  return #rel == 0 and '.' or table.concat(rel, '/')
end

-- Set indentation for a given scope (vim.opt or vim.opt_local)
local function set_indent(width, fill, scope)
  scope             = scope or vim.opt_local
  scope.shiftwidth  = width
  scope.tabstop     = width
  if fill == SPACES then
    scope.expandtab = true
    scope.listchars = { lead = ' ', nbsp = '~', tab = '··', trail = '·' }
  else
    scope.expandtab = false
    scope.listchars = { lead = '·', nbsp = '~', tab = '  ', trail = '·' }
  end
end

-- Return a callback that sets indent and prints a status message
local function deferred_indent(width, fill)
  -- Post without exceeding window width
  local function post(name, ...)
    local view_width = vim.api.nvim_get_option('columns')
    local margin = view_width / 4
    local msg = table.concat({ name, ... }, ' ')
    if view_width < 25 then
      return
    end
    if view_width < 52 then
      -- Keep it simple for narrow windows
      msg = vim.bo.filetype .. ' indent: ' .. width .. ' ' .. fill
    elseif #msg > view_width - margin then
      -- Truncate name to filename only
      name = vim.fn.fnamemodify(name, ':t')
      msg = table.concat({ name, ... }, ' ')
    end
    if #msg > view_width - margin then
      -- Truncate end of message too
      msg = msg:sub(1, view_width - margin - 3) .. '...'
    end
    print(msg)
    vim.defer_fn(print, 2500)
  end
  return function()
    local buf = vim.api.nvim_get_current_buf()
    local name = relative_path(vim.fn.getcwd(), vim.api.nvim_buf_get_name(buf))
    vim.schedule(function()
      set_indent(width, fill)
      post(name, 'Indent', width, fill .. ',', 'filetype:', vim.bo.filetype)
    end)
  end
end

-- Apply default indentation globally
vim.filetype.plugin = true
set_indent(DEFAULT.width, DEFAULT.fill, vim.opt)

-- Setup autocommands
vim.api.nvim_create_augroup('FiletypeIndent', { clear = true })

-- Filetype-specific rules
for _, style in ipairs(INDENT_FILETYPES) do
  vim.api.nvim_create_autocmd('Filetype', {
    group = 'FiletypeIndent',
    pattern = style.pattern,
    callback = deferred_indent(style.width, style.fill),
  })
end

-- Catch-all for unconfigured filetypes
vim.api.nvim_create_autocmd('Filetype', {
  group = 'FiletypeIndent',
  pattern = '*',
  callback = function()
    if not CONFIGURED[vim.bo.filetype] then
      vim.schedule(deferred_indent(DEFAULT.width, DEFAULT.fill))
    end
  end,
})
