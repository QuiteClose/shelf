vim.api.nvim_create_augroup("setFiletypeGo", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeGo",
  pattern = "go",
  callback = function()
    vim.schedule(function()
      print("setFiletypeGo called")
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.expandtab = false
      vim.opt.listchars = {
        nbsp = "~",
        trail = "·",
        lead = "·",
        tab = "  ",
      }
    end)
  end
})
