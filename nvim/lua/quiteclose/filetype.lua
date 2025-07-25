
local SPACES  = 0
local PER_TAB = 1

function setWhitespace(width, fill)
  function callback()
    vim.schedule(function()
      vim.opt.shiftwidth = width
      vim.opt.tabstop = width
      if fill == SPACES then
        vim.opt.expandtab = true
        vim.opt.listchars = {
          lead = " ",
          nbsp = "~",
          tab = "··",
          trail = "·",
        }
      else
        vim.opt.expandtab = false
        vim.opt.listchars = {
          lead = "·",
          nbsp = "~",
          tab = "  ",
          trail = "·",
        }
      end
    end)
  end
  return callback
end

vim.api.nvim_create_augroup("setFiletypeWhitespace", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeWhitespace",
  pattern = "Dockerfile,shell,go,Makefile",
  callback = setWhitespace(4, PER_TAB)
})
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeWhitespace",
  pattern = "zig",
  callback = setWhitespace(2, PER_TAB)
})
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeWhitespace",
  pattern = "markdown,python,txt",
  callback = setWhitespace(4, SPACES)
})
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeWhitespace",
  pattern = "lua,html,css,scss,javascript",
  callback = setWhitespace(2, SPACES)
})
