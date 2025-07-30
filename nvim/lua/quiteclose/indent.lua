-- indentation settings by Filetype
local PER_TAB = 'per-tab'
local SPACES = 'spaces'
local CONFIG = {
  default = {
    width = 2, fill = SPACES,
  },
  filetype = {
    {2, SPACES,  'cmake,css,fish,handlebars,html,javascript,javascriptreact,' ..
                 'json,less,lua,proto,scheme,scss,sh,sql,svelte,terraform' ..
                 'toml,typescript,typescriptreact,vue,xml,yaml,zsh'},
    {4, SPACES,  'ada,ansible,clojure,cs,csharp,elixir,erlang,fortran,' ..
                 'groovy,haskell,java,kotlin,latex,markdown,ocaml,perl,php,' ..
                 'python,rego,ruby,rust,scala,swift,tex,text,zig' },
    {4, PER_TAB, 'asm,dockerfile,go,makefile,nasm,verilog,vhdl' },
    {8, PER_TAB, 'c,cpp,objc,objcpp' },
  },
  ignore = {
    'checkhealth',
    'dashboard',
    'diffviewfiles',
    'fugitive',
    'gitcommit',
    'gitrebase',
    'help',
    'lspinfo',
    'make',
    'neotree',
    'netrw',
    'nvimtree',
    'outline',
    'packer',
    'qf',
    'startify',
    'telescopeprompt',
    'telescoperesults',
    'toggleterm',
    'undotree',
  },
  style = {
    [SPACES] = {
      expandtab = true,
      listchars = { lead = ' ', nbsp = '~', tab = '··', trail = '·' },
    },
    [PER_TAB] = {
      expandtab = false,
      listchars = { lead = '·', nbsp = '~', tab = '  ', trail = '·' },
    },
  },
}

-- List any styled (true) or ignored (false) filetypes
local STYLED = {}
for _, style in ipairs(CONFIG.filetype) do
  local filetype_csv = style[3]
  for filetype in filetype_csv:gmatch('[^,]+') do
    STYLED[filetype] = true
  end
end

-- List any ignored (true) filetypes
local IGNORED = {}
for _, filetype in ipairs(CONFIG.ignore) do
  STYLED[filetype] = false
  IGNORED[filetype] = true
end

-- Set indentation for a given scope (vim.opt or vim.opt_local)
local function set_indent(width, fill, scope)
  if IGNORED[vim.bo.filetype] then return end
  scope = scope or vim.opt_local
  scope.shiftwidth = width
  scope.tabstop    = width
  scope.expandtab  = CONFIG.style[fill].expandtab
  scope.listchars  = CONFIG.style[fill].listchars
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
      for part in path:gmatch('[^/]+') do
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
  local buffer   = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local columns  = vim.api.nvim_get_option('columns')
  local margin   = 12 -- trial and error
  local viewport = columns - margin
  local filetype = vim.bo.filetype
  local indent   = 'Indent ' .. width .. ' ' .. fill
  local relative = function() return '"' .. relative_path(buffer) .. '" ' end
  local breaking = function(str) return vim.fn.strdisplaywidth(str) > viewport end
  local filename = '"' .. vim.fn.fnamemodify(buffer, ':t') .. '" '
  -- Gradually try evermore informative (longer) messages
  local proposals = {
    function() return indent .. '.' end,
    function() return indent .. ', ft: ' .. filetype end,
    function() return indent .. ', filetype: ' .. filetype end,
    function() return filename .. indent .. '.' end,
    function() return filename .. indent .. ', ft: ' .. filetype end,
    function() return filename .. indent .. ', filetype: ' .. filetype end,
    function() return relative() .. indent .. '.' end,
    function() return relative() .. indent .. ', ft: ' .. filetype end,
    function() return relative() .. indent .. ', filetype: ' .. filetype end,
  }
  local message  = ""
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

-- Return a callback to set_indent (and post about it)
local function deferred_indent(width, fill)
  return function()
    vim.schedule(function()
      set_indent(width, fill)
      post(width, fill)
    end)
  end
end

-- Apply default indentation globally
set_indent(CONFIG.default.width, CONFIG.default.fill, vim.opt)

-- Setup autocommands
vim.filetype.plugin = true
vim.api.nvim_create_augroup('FiletypeIndent', { clear = true })

-- Filetype-specific rules
for _, style in ipairs(CONFIG.filetype) do
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
      vim.schedule(deferred_indent(CONFIG.default.width, CONFIG.default.fill))
    end
  end,
})

return CONFIG
