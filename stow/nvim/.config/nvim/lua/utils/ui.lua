local M = {}

-- Custom Tabline logic
function M.tabline()
  local s = ""
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()

  for i, tab in ipairs(tabs) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    -- Select highlighting
    if tab == current_tab then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    -- Tab number and filename
    s = s .. " " .. i .. "-"
    if name == "" then
      s = s .. "[No Name]"
    else
      s = s .. vim.fn.fnamemodify(name, ":t")
    end
    s = s .. " "
  end

  s = s .. "%#TabLineFill#%T%="
  return s
end

-- Apply highlights and set up UI
function M.setup()
  -- Set tabline and statusline globally
  vim.opt.tabline = "%!v:lua.require('utils.ui').tabline()"
  vim.opt.statusline = "%F %m%r%y buf:%n%=line:%l/%L (%p%%) col:%c"
  
  -- Ensure highlights are set after colorscheme loads
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      -- Tabline Highlights
      vim.api.nvim_set_hl(0, "TabLineFill", { fg = "#000000", bg = "#000000" })
      vim.api.nvim_set_hl(0, "TabLine", { fg = "#859289", bg = "#000000" })
      vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#ffffff", bg = "#3d424d" })
      
      -- Whitespace Highlights (for listchars)
      -- Explicitly set bg = "NONE" to prevent the reddish block effect
      vim.api.nvim_set_hl(0, "Whitespace", { fg = "#e67e80", bg = "NONE" }) 
    end,
  })
end

return M