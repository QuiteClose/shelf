vim.api.nvim_create_augroup("setFiletypeTab", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeTab",
  pattern = "Dockerfile,go,Makefile,zig",
  callback = function()
    vim.schedule(function()
      print("setFiletypeTab called")
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
vim.api.nvim_create_augroup("setFiletypeSpace", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeSpace",
  pattern = "md,py,txt",
  callback = function()
    vim.schedule(function()
      print("setFiletypeSpace called")
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.expandtab = true
      vim.opt.listchars = {
        lead = " ",
        nbsp = "~",
        tab = "··",
        trail = "·",
      }
    end)
  end
})
vim.api.nvim_create_augroup("setFiletypeWebdev", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  group = "setFiletypeWebdev",
  pattern = "html,css,scss,js,ts,jsx,tsx",
  callback = function()
    vim.schedule(function()
      print("setFiletypeWebdev called")
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.expandtab = true
      vim.opt.listchars = {
        lead = " ",
        nbsp = "~",
        tab = "··",
        trail = "·",
      }
    end)
  end
})
