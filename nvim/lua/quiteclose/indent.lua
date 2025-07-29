-- Indentation settings by Filetype
local PER_TAB = 'per-tab'
local SPACES = 'spaces'
local DEFAULT = { width = 2, fill = SPACES }

local STYLE_FILETYPES = {
  {2, SPACES,  'css,javascript,html,scss'},
  {4, SPACES,  'markdown,python,text' },
  {2, PER_TAB, 'zig' },
  {4, PER_TAB, 'Dockerfile,sh,go,Makefile' },
}

-- Filetypes to exclude from default indentation
local IGNORED_FILETYPES = {
  'netrw',
}

local INDENT = {
  [SPACES] = {
    expandtab = true,
    listchars = { lead = ' ', nbsp = '~', tab = '··', trail = '·' },
  },
  [PER_TAB] = {
    expandtab = false,
    listchars = { lead = '·', nbsp = '~', tab = '  ', trail = '·' },
  },
}

-- List any styled (or ignored) filetypes
local STYLED = {}
for _, style in ipairs(STYLE_FILETYPES) do
  local filetype_csv = style[3]
  for filetype in filetype_csv:gmatch('[^,]+') do
    STYLED[filetype] = true
  end
end
for _, filetype in ipairs(IGNORED_FILETYPES) do
  STYLED[filetype] = false
end

-- Cache results of relative_path to avoid recomputing
local relative_path_cache = {}

-- Compute relative path from the current working directory
local function relative_path(target)
  local cwd = vim.fn.getcwd()
  if relative_path_cache[cwd] == nil then relative_path_cache[cwd] = {} end
  local compute = function()
    local absolute = vim.fn.fnamemodify(target, ':p')
    local child = vim.fn.fnamemodify(absolute, ':.')
    if child ~= absolute then return child end
    local function split(path)
      local parts = {}
      for part in path:gmatch("[^/]+") do
        table.insert(parts, part)
      end
      return parts
    end
    local origin = split(cwd)
    local toward = split(absolute)
    local relative = {}
    local i = 1
    while i <= math.min(#origin, #toward) and origin[i] == toward[i] do
      i = i + 1
    end
    for _ = i, #origin do table.insert(relative, '..') end
    for j = i, #toward do table.insert(relative, toward[j]) end
    return #relative == 0 and '.' or table.concat(relative, '/')
  end
  if relative_path_cache[cwd][target] == nil then
    relative_path_cache[cwd][target] = compute()
  end
  return relative_path_cache[cwd][target]
end

-- Post a message with the indentation details
local function post(width, fill)
  local buffer = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local relative = function() return relative_path(buffer) end
  local filename = vim.fn.fnamemodify(buffer, ':t')
  -- Gradually try evermore informative (longer) messages
  local proposals = {
    function() return 'Indent ' .. width .. ' ' .. fill .. '.' end,
    function() return 'Indent ' .. width .. ' ' .. fill .. ', ft: ' .. vim.bo.filetype end,
    function() return 'Indent ' .. width .. ' ' .. fill .. ', filetype: ' .. vim.bo.filetype end,
    function() return '"' .. filename .. '" Indent ' .. width .. ' ' .. fill .. '.' end,
    function() return '"' .. filename .. '" Indent ' .. width .. ' ' .. fill .. ', ft: ' .. vim.bo.filetype end,
    function() return '"' .. filename .. '" Indent ' .. width .. ' ' .. fill .. ', filetype: ' .. vim.bo.filetype end,
    function() return '"' .. relative() .. '" Indent ' .. width .. ' ' .. fill .. '.' end,
    function() return '"' .. relative() .. '" Indent ' .. width .. ' ' .. fill .. ', ft: ' .. vim.bo.filetype end,
    function() return '"' .. relative() .. '" Indent ' .. width .. ' ' .. fill .. ', filetype: ' .. vim.bo.filetype end,
  }
  local columns = vim.api.nvim_get_option('columns')
  local margin = 12 -- trial and errort 
  local viewport = columns - margin
  local breaking = function(str) return vim.fn.strdisplaywidth(str) > viewport end
  local message = ""
  for _, proposal in ipairs(proposals) do
    local candidate = proposal()
    if breaking(candidate) then break end
    message = candidate
  end
  if message ~= "" then
    -- Print the longest message possible and then clear it
    print(message)
    vim.defer_fn(print, 2500)
  end
end

-- Set indentation for a given scope (vim.opt or vim.opt_local)
local function set_indent(width, fill, scope)
  scope = scope or vim.opt_local
  scope.shiftwidth = width
  scope.tabstop    = width
  scope.expandtab  = INDENT[fill].expandtab
  scope.listchars  = INDENT[fill].listchars
end

-- Return a callback that sets indent and prints a status message
local function deferred_indent(width, fill)
  return function()
    vim.schedule(function()
      set_indent(width, fill)
      post(width, fill)
    end)
  end
end

-- Apply default indentation globally
vim.filetype.plugin = true
set_indent(DEFAULT.width, DEFAULT.fill, vim.opt)

-- Setup autocommands
vim.api.nvim_create_augroup('FiletypeIndent', { clear = true })

-- Filetype-specific rules
for _, style in ipairs(STYLE_FILETYPES) do
  local width, fill, pattern = style[1], style[2], style[3]
  vim.api.nvim_create_autocmd('Filetype', {
    group = 'FiletypeIndent',
    pattern = pattern,
    callback = deferred_indent(width, fill),
  })
end

-- Catch-all for unconfigured filetypes
vim.api.nvim_create_autocmd('Filetype', {
  group = 'FiletypeIndent',
  pattern = '*',
  callback = function()
    if STYLED[vim.bo.filetype] == nil then
      vim.schedule(deferred_indent(DEFAULT.width, DEFAULT.fill))
    end
  end,
})
