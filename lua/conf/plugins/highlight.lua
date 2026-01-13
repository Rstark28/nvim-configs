return {
  "nvim-lua/plenary.nvim", 
  config = function()
    vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight on yank",
      group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
      callback = function()
        vim.highlight.on_yank({
          higroup = "IncSearch",
          timeout = 200,
        })
      end,
    })
  end,
}

