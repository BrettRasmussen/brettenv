local M = {}

---Returns the path to the session file based on the current git branch.
---@return string
function M.get_session_file()
  local branch = vim.fn.trim(vim.fn.system("git branch --show-current"))
  if vim.v.shell_error ~= 0 then
    return "./.session.vim"
  end
  return "./.session." .. branch .. ".vim"
end

return M