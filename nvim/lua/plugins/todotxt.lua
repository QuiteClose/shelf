return {
  "phrmendes/todotxt.nvim",
  cmd = { "TodoTxt", "DoneTxt" },
  ft = "todotxt",
  init = function()
    vim.filetype.add({
      pattern = {
        ["todo%.txt"] = "todotxt",
        ["done%.txt"] = "todotxt",
      },
    })
  end,
  opts = {
    todotxt = os.getenv("HOME") .. "/workspaces/core.000000/daisy/todo.txt",
    donetxt = os.getenv("HOME") .. "/workspaces/core.000000/daisy/done.txt",
    ghost_text = {
      enable = true,
      mappings = {
        ["(A)"] = "now",
        ["(B)"] = "next",
        ["(C)"] = "someday",
        ["(D)"] = "deferred",
      },
      prefix = "~",
      highlight = "Comment",
    },
  },
  config = function(_, opts)
    require("todotxt").setup(opts)
    require('quiteclose/keymap').after_plugin_todotxt()
  end,
}
