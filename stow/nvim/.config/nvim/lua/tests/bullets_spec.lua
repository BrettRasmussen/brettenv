-- nvim/lua/tests/bullets_spec.lua

-- Note: We will require the module under test for each test case
-- to ensure a clean state, as the config is stored internally.

describe("bullets.lua configuration", function()
  it("should load default settings correctly", function()
    local bullets = require("utils.bullets")
    local cfg = bullets.get_config()

    assert.are.same({ "*", "+", "-" }, cfg.unordered_cycle)
    assert.are.same({ "1.", "a.", "i." }, cfg.ordered_cycle)
    assert.are.equal(4, cfg.sub_indent)
    assert.are.equal(2, cfg.wrap_indent)
  end)

  it("should merge user options with defaults", function()
    -- We need a fresh require to reset the internal state
    package.loaded["utils.bullets"] = nil
    local bullets = require("utils.bullets")

    -- Simulate user configuration
    bullets.setup({
      unordered_cycle = { ">" },
      sub_indent = 8,
    })

    local cfg = bullets.get_config()

    -- Check that the user's values were applied
    assert.are.same({ ">" }, cfg.unordered_cycle)
    assert.are.equal(8, cfg.sub_indent)

    -- Check that the unspecified values remain the default
    assert.are.same({ "1.", "a.", "i." }, cfg.ordered_cycle)
    assert.are.equal(2, cfg.wrap_indent)
  end)
end)

describe("bullets.lua core logic", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")

  it("should calculate nesting level correctly", function()
    -- Default sub_indent is 4
    assert.are.equal(0, bullets.get_nesting_level("No indent"))
    assert.are.equal(0, bullets.get_nesting_level("  Slightly indented")) -- less than sub_indent
    assert.are.equal(1, bullets.get_nesting_level("    One level"))
    assert.are.equal(1, bullets.get_nesting_level("      One level and a bit"))
    assert.are.equal(2, bullets.get_nesting_level("        Two levels"))
  end)

  it("should calculate nesting level correctly with custom sub_indent", function()
    package.loaded["utils.bullets"] = nil
    local custom_bullets = require("utils.bullets")
    custom_bullets.setup({ sub_indent = 2 })

    assert.are.equal(0, custom_bullets.get_nesting_level("No indent"))
    assert.are.equal(1, custom_bullets.get_nesting_level("  One level"))
    assert.are.equal(2, custom_bullets.get_nesting_level("    Two levels"))
  end)
end)

describe("bullets.lua utility functions", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")

  it("should correctly identify empty bullet points", function()
    assert.is_true(bullets.is_empty_bullet("* "))
    assert.is_true(bullets.is_empty_bullet("  - "))
    assert.is_true(bullets.is_empty_bullet("    + "))
    assert.is_true(bullets.is_empty_bullet("1. "))
    assert.is_false(bullets.is_empty_bullet("* My bullet"))
    assert.is_false(bullets.is_empty_bullet("  - not empty"))
    assert.is_false(bullets.is_empty_bullet("Some text"))
    assert.is_false(bullets.is_empty_bullet(""))
  end)

  it("should correctly parse bullet lines", function()
    local components

    components = bullets.parse_bullet_line("    - My bullet point")
    assert.are.equal("    ", components.indent_str)
    assert.are.equal("-", components.bullet_str)
    assert.are.equal(" My bullet point", components.rest_of_line)

    components = bullets.parse_bullet_line("* Top level bullet")
    assert.are.equal("", components.indent_str)
    assert.are.equal("*", components.bullet_str)
    assert.are.equal(" Top level bullet", components.rest_of_line)

    components = bullets.parse_bullet_line("  1. Ordered item")
    assert.are.equal("  ", components.indent_str)
    assert.are.equal("1.", components.bullet_str)
    assert.are.equal(" Ordered item", components.rest_of_line)

    components = bullets.parse_bullet_line("   a. Sub-item")
    assert.are.equal("   ", components.indent_str)
    assert.are.equal("a.", components.bullet_str)
    assert.are.equal(" Sub-item", components.rest_of_line)

    -- Should return nil for non-bullet lines
    assert.is_nil(bullets.parse_bullet_line("Just some text"))
    assert.is_nil(bullets.parse_bullet_line(""))
    assert.is_nil(bullets.parse_bullet_line("  No bullet here"))
  end)
end)

describe("bullets.lua handle_enter function", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")
  local bufnr

  before_each(function()
    -- Create a new buffer for each test to ensure isolation
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })

    vim.cmd("startinsert!")
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.cmd("stopinsert")
  end)

  it("should dedent a nested empty bullet point and return true", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "    - " })
    vim.api.nvim_win_set_cursor(0, { 1, 6 }) -- Cursor after the space
    local handled = bullets.handle_enter()
    assert.is_true(handled)
    assert.are.same({ "* " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(2, vim.api.nvim_win_get_cursor(0)[2]) -- Check cursor position after dedent
  end)

  it("should delete a top-level empty bullet point and return true", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* " })
    vim.api.nvim_win_set_cursor(0, { 1, 2 }) -- Cursor after the space
    local handled = bullets.handle_enter()
    assert.is_true(handled)
    assert.are.same({ "" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(0, vim.api.nvim_win_get_cursor(0)[2]) -- Check cursor position after delete
  end)

  it("should create a new bullet line on Enter at the end of a non-empty bullet line and return true", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* My bullet point" })
    vim.api.nvim_win_set_cursor(0, { 1, 17 })
    local handled = bullets.handle_enter()
    assert.is_true(handled)
    assert.are.same({ "* My bullet point", "* " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should not modify a non-bullet line and return false", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Some text" })
    vim.api.nvim_win_set_cursor(0, { 1, 9 })
    local handled = bullets.handle_enter()
    assert.is_false(handled)
    assert.are.same({ "Some text" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    -- Cursor position should remain where it was before the function call
    assert.are.equal(9, vim.api.nvim_win_get_cursor(0)[2])
  end)

  it("should not modify an empty line and return false", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local handled = bullets.handle_enter()
    assert.is_false(handled)
    assert.are.same({ "" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(0, vim.api.nvim_win_get_cursor(0)[2])
  end)

  it("should not modify an empty bullet line if cursor is not at the end", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* " })
    vim.api.nvim_win_set_cursor(0, { 1, 1 }) -- Cursor before the space
    local handled = bullets.handle_enter()
    assert.is_false(handled)
    assert.are.same({ "* " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(1, vim.api.nvim_win_get_cursor(0)[2])
  end)

  it("should create a new deeper nested bullet on Enter with trailing colon", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "    - Parent bullet:" })
    vim.api.nvim_win_set_cursor(0, { 1, #("    - Parent bullet:") }) -- Cursor after the colon
    local handled = bullets.handle_enter()
    assert.is_true(handled)
    assert.are.same({
      "    - Parent bullet:",
      "        - " -- 4 (parent indent) + 4 (sub_indent) = 8 spaces, then next bullet char
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(#("        - "), vim.api.nvim_win_get_cursor(0)[2])
  end)
end)

describe("bullets.lua handle_autowrap function", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
    vim.cmd("startinsert!")

    -- Ensure a fixed textwidth for predictable wrapping in tests
    vim.opt.textwidth = 20
    vim.opt.wrap = true
    vim.opt.breakindent = false -- Disable default breakindent for easier testing
    vim.opt.autoindent = true
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.cmd("stopinsert")
    -- Reset textwidth and wrap to default (or whatever they were before)
    vim.opt.textwidth = 0
    vim.opt.wrap = false
    vim.opt.breakindent = true
    vim.opt.autoindent = true
  end)

  it("should correctly indent a wrapped line for a bullet point", function()
    -- Reset the module to ensure a clean config state for these tests
    package.loaded["utils.bullets"] = nil
    local bullets = require("utils.bullets")

    -- Simulate typing a long line that wraps
    local initial_line = "    - This is a very long bullet point that should wrap around."
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { initial_line })
    -- Simulate Neovim's auto-wrap. The cursor would be on the new line.
    -- Neovim would insert a newline and the wrapped text, likely with autoindent
    -- which might match the previous line's indent, or be 0 depending on other settings.
    -- Here, we manually create the wrapped line as if Neovim just did it.
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "    - This is a very long",
      "    bullet point that should wrap around."
    })
    vim.api.nvim_win_set_cursor(0, { 2, 4 }) -- Cursor on the wrapped line

    bullets.handle_autowrap()

    local expected_second_line = "        bullet point that should wrap around."
    assert.are.same({
      "    - This is a very long",
      expected_second_line,
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    -- The cursor should ideally stay at the same relative position
    assert.are.equal(8, vim.api.nvim_win_get_cursor(0)[2])
  end)

  it("should not indent a wrapped line if the previous line is not a bullet", function()
    local initial_line = "This is a very long non-bullet line that should wrap around."
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { initial_line })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "This is a very long non-bullet",
      "line that should wrap around."
    })
    vim.api.nvim_win_set_cursor(0, { 2, 0 }) -- Cursor on the wrapped line

    bullets.handle_autowrap()

    assert.are.same({
      "This is a very long non-bullet",
      "line that should wrap around."
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(0, vim.api.nvim_win_get_cursor(0)[2])
  end)

  it("should not modify an already correctly indented wrapped line", function()
    -- Already correctly indented: base_indent (4) + bullet_char_len (2) + space_after_bullet (1) + wrap_indent (2) = 9 spaces
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "    - This is a very long",
      "        bullet point that should wrap around."
    })
    vim.api.nvim_win_set_cursor(0, { 2, 8 }) -- Cursor on the wrapped line

    bullets.handle_autowrap()

    assert.are.same({
      "    - This is a very long",
      "        bullet point that should wrap around."
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.are.equal(8, vim.api.nvim_win_get_cursor(0)[2])
  end)
end)

describe("bullets.lua get_current_bullet_range function", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Bullet one",
      "  wrapped line 1",
      "  wrapped line 2",
      "* Bullet two",
      "Some other text",
      "",
      "    - Nested bullet",
      "      wrapped nested line",
    })
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("should return the correct range for a multi-line bullet (cursor on first line)", function()
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    local range = bullets.get_current_bullet_range()
    assert.are.same({ start_line = 1, end_line = 3 }, range)
  end)

  it("should return the correct range for a multi-line bullet (cursor on wrapped line)", function()
    vim.api.nvim_win_set_cursor(0, { 2, 1 })
    local range = bullets.get_current_bullet_range()
    assert.are.same({ start_line = 1, end_line = 3 }, range)
  end)

  it("should return the correct range for a single-line bullet", function()
    vim.api.nvim_win_set_cursor(0, { 4, 1 })
    local range = bullets.get_current_bullet_range()
    assert.are.same({ start_line = 4, end_line = 4 }, range)
  end)

  it("should return nil for a non-bullet line", function()
    vim.api.nvim_win_set_cursor(0, { 5, 1 })
    local range = bullets.get_current_bullet_range()
    assert.is_nil(range)
  end)

  it("should return nil for an empty line", function()
    vim.api.nvim_win_set_cursor(0, { 6, 0 })
    local range = bullets.get_current_bullet_range()
    assert.is_nil(range)
  end)

  it("should return the correct range for a nested multi-line bullet", function()
    vim.api.nvim_win_set_cursor(0, { 7, 5 })
    local range = bullets.get_current_bullet_range()
    assert.are.same({ start_line = 7, end_line = 8 }, range)
  end)
end)

describe("bullets.lua indent/unindent functions", function()
  -- Reset the module to ensure a clean config state for these tests
  package.loaded["utils.bullets"] = nil
  local bullets = require("utils.bullets")
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  end)

  after_each(function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("should indent a single-line bullet in normal mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* Bullet one" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    bullets.indent('n')
    assert.are.same({ "    + Bullet one" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should indent a multi-line bullet in normal mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Bullet one",
      "  wrapped line",
    })
    vim.api.nvim_win_set_cursor(0, { 2, 1 })
    bullets.indent('n')
    assert.are.same({
      "    + Bullet one",
      "      wrapped line",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should fallback to default behavior for non-bullet lines", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Some text" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    -- Mock the vim.cmd function to check if it's called
    local vim_cmd_called = false
    local original_vim_cmd = vim.cmd
    vim.cmd = function(cmd)
      if cmd == "normal! >>" then
        vim_cmd_called = true
      end
    end
    bullets.indent('n')
    assert.is_true(vim_cmd_called)
    vim.cmd = original_vim_cmd -- Restore original function
  end)

  it("should unindent a single-line bullet in normal mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "    + Bullet one" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    bullets.unindent('n')
    assert.are.same({ "* Bullet one" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should not unindent a top-level bullet", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* Bullet one" })
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    bullets.unindent('n')
    assert.are.same({ "* Bullet one" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should unindent a multi-line bullet in normal mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "    + Bullet one",
      "      wrapped line",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    bullets.unindent('n')
    assert.are.same({
      "* Bullet one",
      "  wrapped line",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should preserve visual selection after indenting", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Bullet one",
      "* Bullet two",
    })
    -- Visually select the two lines
    vim.cmd("normal! V")
    vim.cmd("normal! j")

    -- Call the indent function in visual mode
    bullets.indent('v')

    -- Check that the lines were indented
    assert.are.same({
      "    + Bullet one",
      "    + Bullet two",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

    -- Check that the visual selection is still active
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    assert.are.equal(1, start_pos[2])
    assert.are.equal(2, end_pos[2])
  end)
end)

describe("bullets.lua handle_o and handle_O functions", function()
  local bufnr
  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    -- Reset the module to ensure a clean config state for these tests
    package.loaded["utils.bullets"] = nil
    bullets = require("utils.bullets")
  end)

  it("handle_o should create a new bullet below a single-line bullet", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* First bullet" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    local handled = bullets.handle_o()
    assert.is_true(handled)
    assert.are.same({ "* First bullet", "* " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("handle_o should create a new bullet below a multi-line bullet", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* Multi-line", "    continuation" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    local handled = bullets.handle_o()
    assert.is_true(handled)
    assert.are.same({ "* Multi-line", "    continuation", "* " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("handle_o should nest deeper if the bullet ends in a colon", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* Parent:" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    local handled = bullets.handle_o()
    assert.is_true(handled)
    assert.are.same({ "* Parent:", "    + " }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("handle_O should create a new bullet above a bullet block", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "* First bullet" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    local handled = bullets.handle_O()
    assert.is_true(handled)
    assert.are.same({ "* ", "* First bullet" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("handle_o and handle_O should return false if not in a bullet", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Plain text" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    assert.is_false(bullets.handle_o())
    assert.is_false(bullets.handle_O())
  end)
end)
