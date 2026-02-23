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
  opts = function()
    local daisy = os.getenv("DAISY_ROOT") or (os.getenv("HOME") .. "/.daisy")
    return {
      todotxt = daisy .. "/tasks/todo.txt",
      donetxt = daisy .. "/tasks/done.txt",
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
    }
  end,
  config = function(_, opts)
    require("todotxt").setup(opts)
    require('quiteclose/keymap').after_plugin_todotxt()
  end,
}
