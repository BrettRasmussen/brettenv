local M = {}

---Redirects the output of a command to a new scratch buffer.
---@param args table The command arguments provided by nvim_create_user_command
function M.redir(args)
  local cmd = args.args
  local output = {}

  if cmd:match("^!") then
    -- Handle shell commands
    local shell_cmd = cmd:sub(2)
    output = vim.fn.systemlist(shell_cmd)
  else
    -- Handle Vim commands
    -- Fix: nvim_exec2 uses 'output' to determine if output should be captured
    local success, res = pcall(vim.api.nvim_exec2, cmd, { output = true })
    if success then
      output = vim.split(res.output, "\n")
    else
      -- If success is false, 'res' is the error message string
      vim.api.nvim_err_writeln("Redir Error: " .. tostring(res))
      return
    end
  end

  -- Create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Use modern set_option_value API
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  
  -- Set the captured lines in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  -- Open in vertical split and focus
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

return M