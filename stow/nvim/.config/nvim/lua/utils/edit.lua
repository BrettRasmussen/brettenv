local M = {}

---Strips trailing whitespace from the current buffer.
function M.strip_trailing_whitespace()
  local save = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(save)
end

---Toggles paste mode and displays a status message.
function M.toggle_paste()
  if vim.opt.paste:get() then
    vim.opt.paste = false
    print(" --- PASTE OFF --- ")
  else
    vim.opt.paste = true
    print(" --- PASTE ON  --- ")
  end
end

return M