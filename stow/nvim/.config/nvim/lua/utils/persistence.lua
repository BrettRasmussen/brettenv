local M = {}

-- Store views in a buffer-local table: [window_id] = view_state
function M.save_view()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  
  -- Initialize the storage table for this buffer if it doesn't exist
  if not vim.b[buf].views then
    vim.b[buf].views = {}
  end
  
  -- Save the current view for this specific window
  local views = vim.b[buf].views
  views[tostring(win)] = vim.fn.winsaveview()
  vim.b[buf].views = views
end

function M.restore_view()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  
  -- Restore if a view was previously saved for this specific buffer in this window
  if vim.b[buf].views and vim.b[buf].views[tostring(win)] then
    vim.fn.winrestview(vim.b[buf].views[tostring(win)])
  end
end

return M