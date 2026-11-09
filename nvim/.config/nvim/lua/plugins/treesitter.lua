return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")
    treesitter.setup()
    treesitter.install({ "lua", "python", "c", "rust", "javascript", "cpp", "bash" })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("DotfilesTreesitter", { clear = true }),
      pattern = { "lua", "python", "c", "rust", "javascript", "cpp", "sh", "bash" },
      callback = function(event)
        local lang = event.match == "sh" and "bash" or event.match
        -- On first startup, the asynchronous install may still be running.
        if vim.treesitter.language.add(lang) then
          vim.treesitter.start(event.buf, lang)
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
