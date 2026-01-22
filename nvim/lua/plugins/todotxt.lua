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
    todotxt = os.getenv("HOME") .. "/workspaces/daisy.000000/tasks/todo.txt",
    donetxt = os.getenv("HOME") .. "/workspaces/daisy.000000/tasks/done.txt",
    ghost_text = {
      enable = true,
      mappings = {
        ["(A)"] = "Now",
        ["(B)"] = "Next",
        ["(C)"] = "Soon",
        ["(D)"] = "Someday",
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
