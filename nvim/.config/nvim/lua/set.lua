vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.opt.nu = true
vim.opt.relativenumber = true

-- Let the terminal supply the editor background.
for _, name in ipairs({ "Normal", "NormalNC" }) do
  local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
  if highlight.bg then
    highlight.bg = nil
    vim.api.nvim_set_hl(0, name, highlight)
  end
end
