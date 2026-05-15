-- nvim/lua/utils/bullets.lua

local M = {}

-- Default configuration, as per the spec
local config = {
  unordered_cycle = { "*", "+", "-" },
  ordered_cycle = { "1.", "a.", "i." },
  sub_indent = 4,
  wrap_indent = 2,
}

--- Merges user-provided options with the default configuration.
-- @param opts A table of user options to override defaults.
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

--- Returns the current configuration table.
-- Primarily for testing purposes.
function M.get_config()
  return config
end

--- Calculates the nesting level of a line based on its indentation.
-- @param line The string content of the line.
-- @return The calculated nesting level (integer, 0-based).
function M.get_nesting_level(line)
  local indent_str = line:match("^(%s*)")
  local indent_width = #indent_str
  return math.floor(indent_width / config.sub_indent)
end

--- Checks if a line is an empty bullet point.
-- @param line The string content of the line.
-- @return True if the line is an empty bullet, false otherwise.
function M.is_empty_bullet(line)
  local components = M.parse_bullet_line(line)
  if components then
    return components.rest_of_line:match("^%s*$") ~= nil
  end
  return false
end

--- Handles the Enter key press in insert mode.
-- @return True if the bullet logic handled the Enter press and a default newline should be prevented,
--         false if default newline behavior should proceed.
function M.handle_enter()
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2]

  local range = M.get_current_bullet_range()
  if not range then return false end

  local start_line_content = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.start_line, false)[1]
  local start_components = M.parse_bullet_line(start_line_content)
  if not start_components then return false end

  -- 1. Check for trailing colon for deeper nesting
  if current_line_num == range.end_line and current_line:match(":%s*$") and cursor_col == #current_line then
    if range.start_line == range.end_line and M.is_empty_bullet(current_line) then
      -- Skip to empty bullet logic if it's just "  - :"
    else
      local current_level = M.get_nesting_level(start_line_content)
      local new_level = current_level + 1
      local new_indent_width = new_level * config.sub_indent
      local new_indent_str = string.rep(" ", new_indent_width)
      local new_bullet_char = config.unordered_cycle[(new_level % #config.unordered_cycle) + 1]
      local new_line = new_indent_str .. new_bullet_char .. " "

      vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, false, { new_line })
      vim.api.nvim_win_set_cursor(0, { current_line_num + 1, #new_line })
      return true
    end
  end

  -- 2. Existing logic for empty bullet points
  if range.start_line == range.end_line and M.is_empty_bullet(current_line) and cursor_col == #current_line then
    local current_level = M.get_nesting_level(current_line)

    if current_level > 0 then
      -- Nested empty bullet: dedent
      local new_level = current_level - 1
      local new_indent_width = new_level * config.sub_indent
      local new_indent_str = string.rep(" ", new_indent_width)
      local new_bullet_char = config.unordered_cycle[(new_level % #config.unordered_cycle) + 1]
      local new_line = new_indent_str .. new_bullet_char .. " "

      vim.api.nvim_set_current_line(new_line)
      vim.api.nvim_win_set_cursor(0, { current_line_num, #new_line })
      return true
    else
      -- Top-level empty bullet: delete
      vim.api.nvim_set_current_line("")
      vim.api.nvim_win_set_cursor(0, { current_line_num, 0 })
      return true
    end
  end

  -- 3. Hitting enter at the end of the bullet point creates a new bullet
  if current_line_num == range.end_line and cursor_col == #current_line then
    local new_line = start_components.indent_str .. start_components.bullet_str .. " "
    vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { current_line_num + 1, #new_line })
    return true
  end

  return false
end

function M.handle_o()
  local range = M.get_current_bullet_range()
  if not range then return false end

  local start_line_content = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.start_line, false)[1]
  local start_components = M.parse_bullet_line(start_line_content)
  if not start_components then return false end

  local last_line_content = vim.api.nvim_buf_get_lines(0, range.end_line - 1, range.end_line, false)[1]

  local new_line
  if last_line_content:match(":%s*$") then
    local current_level = M.get_nesting_level(start_line_content)
    local new_level = current_level + 1
    local new_indent_width = new_level * config.sub_indent
    local new_indent_str = string.rep(" ", new_indent_width)
    local new_bullet_char = config.unordered_cycle[(new_level % #config.unordered_cycle) + 1]
    new_line = new_indent_str .. new_bullet_char .. " "
  else
    new_line = start_components.indent_str .. start_components.bullet_str .. " "
  end

  vim.api.nvim_buf_set_lines(0, range.end_line, range.end_line, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { range.end_line + 1, #new_line })
  return true
end

function M.handle_O()
  local range = M.get_current_bullet_range()
  if not range then return false end

  local start_line_content = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.start_line, false)[1]
  local start_components = M.parse_bullet_line(start_line_content)
  if not start_components then return false end

  local new_line = start_components.indent_str .. start_components.bullet_str .. " "
  vim.api.nvim_buf_set_lines(0, range.start_line - 1, range.start_line - 1, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { range.start_line, #new_line })
  return true
end

--- Parses a line to extract its bullet components if it's a valid bullet point.
-- @param line The string content of the line.
-- @return A table { indent_str, bullet_str, rest_of_line } if it's a bullet, otherwise nil.
function M.parse_bullet_line(line)
  local leading_whitespace = line:match("^(%s*)")
  local trimmed_line = line:sub(#leading_whitespace + 1)

  -- Check unordered bullets
  for _, bullet_char in ipairs(config.unordered_cycle) do
    local escaped_char = bullet_char:gsub("([%+%-%*%?%^%$%.%(%)%[%]%{%}%%])", "%%%1")
    local pattern = "^" .. escaped_char .. "(%s*.*)$"
    local rest = trimmed_line:match(pattern)
    if rest then
      return { indent_str = leading_whitespace, bullet_str = bullet_char, rest_of_line = rest }
    end
  end

  -- Check ordered bullets
  for _, ordered_pattern in ipairs(config.ordered_cycle) do
    local num_prefix, suffix = ordered_pattern:match("^(%d+)(.*)$")
    local alpha_prefix, suffix_alpha = ordered_pattern:match("^(%a)(.*)$")
    local roman_prefix, suffix_roman = ordered_pattern:match("^([ivxIVX]+)(.*)$")

    local regex_prefix
    local literal_suffix

    if num_prefix then
      regex_prefix = "%d+"
      literal_suffix = suffix
    elseif alpha_prefix then
      regex_prefix = "%a"
      literal_suffix = suffix_alpha
    elseif roman_prefix then
      regex_prefix = "[ivxIVX]+"
      literal_suffix = suffix_roman
    else
      goto continue
    end

    local escaped_literal_suffix = literal_suffix:gsub("([%+%-%*%?%^%$%.%(%)%[%]%{%}%%])", "%%%1")
    local full_regex_pattern = "^" .. regex_prefix .. escaped_literal_suffix .. "(%s*.*)$"
    local rest = trimmed_line:match(full_regex_pattern)

    if rest then
      local bullet_str_part = trimmed_line:match("^" .. regex_prefix .. escaped_literal_suffix)
      return { indent_str = leading_whitespace, bullet_str = bullet_str_part, rest_of_line = rest }
    end
    ::continue::
  end

  return nil
end

local function _contains_bullet(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  for _, line in ipairs(lines) do
    if M.parse_bullet_line(line) then
      return true
    end
  end
  return false
end

--- Indents the current bullet point.
-- @param mode The current editor mode (e.g., 'n', 'v', 'x').
local function _perform_indentation(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local new_lines = {}
  local sub_indent_str = string.rep(" ", config.sub_indent)

  for i, line in ipairs(lines) do
    local first_line_components = M.parse_bullet_line(line)
    if first_line_components then
      local new_indent_width = #first_line_components.indent_str + config.sub_indent
      local new_level = M.get_nesting_level(string.rep(" ", new_indent_width))
      local new_bullet_char = config.unordered_cycle[(new_level % #config.unordered_cycle) + 1]
      new_lines[i] = string.rep(" ", new_indent_width) .. new_bullet_char .. first_line_components.rest_of_line
    else
      new_lines[i] = sub_indent_str .. line
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

function M.indent(mode)
  local start_line, end_line
  if mode == 'v' or mode == 'V' or mode == '\22' then -- \22 is ^V
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")

    -- Ensure they are ordered correctly
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    if start_line == 0 or end_line == 0 then
      return -- Still no valid selection
    end

    if not _contains_bullet(start_line, end_line) then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gv>gv", true, false, true), "n", false)
      return
    end

    _perform_indentation(start_line, end_line)
    vim.api.nvim_buf_set_mark(0, '<', start_line, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', end_line, 0, {})
    -- Exit visual mode and re-select the lines to preserve visual selection
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gv", true, false, true), "n", false)
    return
  end

  local range = M.get_current_bullet_range()
  if not range then
    if mode == 'n' then
      vim.cmd("normal! >>")
    elseif mode == 'i' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
    end
    return
  end

  _perform_indentation(range.start_line, range.end_line)
end

--- Unindents the current bullet point.
-- @param mode The current editor mode (e.g., 'n', 'v', 'x').
local function _perform_unindentation(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local new_lines = {}

  for i, line in ipairs(lines) do
    local first_line_components = M.parse_bullet_line(line)
    if first_line_components and #first_line_components.indent_str >= config.sub_indent then
      local new_indent_width = #first_line_components.indent_str - config.sub_indent
      local new_level = M.get_nesting_level(string.rep(" ", new_indent_width))
      local new_bullet_char = config.unordered_cycle[(new_level % #config.unordered_cycle) + 1]
      new_lines[i] = string.rep(" ", new_indent_width) .. new_bullet_char .. first_line_components.rest_of_line
    else
      local sub_indent_str = string.rep(" ", config.sub_indent)
      if line:sub(1, config.sub_indent) == sub_indent_str then
        new_lines[i] = line:sub(config.sub_indent + 1)
      else
        new_lines[i] = line
      end
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

function M.unindent(mode)
  local start_line, end_line
  if mode == 'v' or mode == 'V' or mode == '\22' then -- \22 is ^V
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")

    -- Ensure they are ordered correctly
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    if start_line == 0 or end_line == 0 then
      return -- Still no valid selection
    end

    if not _contains_bullet(start_line, end_line) then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gv<gv", true, false, true), "n", false)
      return
    end

    _perform_unindentation(start_line, end_line)
    vim.api.nvim_buf_set_mark(0, '<', start_line, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', end_line, 0, {})
    -- Exit visual mode and re-select the lines to preserve visual selection
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gv", true, false, true), "n", false)
    return
  end

  local range = M.get_current_bullet_range()
  if not range then
    if mode == 'n' then
      vim.cmd("normal! <<")
    elseif mode == 'i' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
    end
    return
  end

  _perform_unindentation(range.start_line, range.end_line)
end

--- Identifies the start and end line numbers of the logical bullet point the cursor is currently on.
-- This helper is crucial for multi-line indentation.
-- @return A table { start_line, end_line } if a bullet is found, otherwise nil.
function M.get_current_bullet_range()
  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = -1

  -- Find the start of the bullet by searching upwards from the cursor.
  for i = cursor_line_num, 1, -1 do
    local line_content_tbl = vim.api.nvim_buf_get_lines(0, i - 1, i, false)
    if #line_content_tbl > 0 then
      local line_content = line_content_tbl[1]
      if M.parse_bullet_line(line_content) then
        start_line = i
        break
      end
    end
  end

  if start_line == -1 then
    return nil -- No bullet found at or above the cursor.
  end

  -- From the identified start, search downwards for the end of the bullet.
  local end_line = start_line
  local total_lines = vim.api.nvim_buf_line_count(0)
  local start_line_content = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
  local start_line_indent_str = start_line_content:match("^(%s*)") or ""
  local start_line_indent = #start_line_indent_str

  for i = start_line + 1, total_lines do
    local line_content_tbl = vim.api.nvim_buf_get_lines(0, i - 1, i, false)
    if #line_content_tbl == 0 then break end
    local line_content = line_content_tbl[1]
    local line_indent = #(line_content:match("^(%s*)") or "")

    -- The bullet ends if we hit a new bullet, a non-empty line with less/equal indent, or an empty line.
    local is_empty = line_content:match("^%s*$") ~= nil
    if M.parse_bullet_line(line_content) or line_indent <= start_line_indent or is_empty then
      break
    end
    end_line = i
  end

  -- Validate that the cursor line is actually within the start and end bounds of the found bullet.
  if cursor_line_num > end_line then
    return nil
  end

  return { start_line = start_line, end_line = end_line }
end

--- Handles automatic line wrapping in insert mode for bullet points.
-- Ensures wrapped lines are correctly indented.
function M.handle_autowrap()
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  if current_line_num == 1 then return end -- Cannot wrap if it's the first line

  local current_line = vim.api.nvim_get_current_line()
  local prev_line = vim.api.nvim_buf_get_lines(0, current_line_num - 2, current_line_num - 1, false)[1]

  local prev_components = M.parse_bullet_line(prev_line)

  -- If previous line was a bullet and current line is not itself a new bullet or empty
  if prev_components and not M.parse_bullet_line(current_line) and current_line:match("^%s*$") == nil then
    local prev_indent_str = prev_components.indent_str
    local prev_bullet_str = prev_components.bullet_str
    local prev_rest_of_line = prev_components.rest_of_line

    -- Calculate the effective indentation of the text *after* the bullet
    local base_indent_width = #prev_indent_str + #prev_bullet_str + #prev_rest_of_line:match("^(%s*)")
    local desired_indent_width = base_indent_width + config.wrap_indent

    local current_indent_str = current_line:match("^(%s*)")
    local current_indent_width = #current_indent_str

    if current_indent_width ~= desired_indent_width then
      local new_indent_str = string.rep(" ", desired_indent_width)
      local new_line = new_indent_str .. current_line:sub(current_indent_width + 1)
      vim.api.nvim_set_current_line(new_line)
      -- Preserve cursor position relative to the start of the text content
      local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
      vim.api.nvim_win_set_cursor(0, { current_line_num, cursor_col - current_indent_width + desired_indent_width })
    end
  end
end

return M
