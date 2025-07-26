return {
  'maxmx03/solarized.nvim',
  lazy = false,
  config = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme('solarized')
  end,
}
