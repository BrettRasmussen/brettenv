describe("bullets.lua visual mode tests", function()
  local bufnr
  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    -- Reset the module to ensure a clean config state for these tests
    package.loaded["utils.bullets"] = nil
    bullets = require("utils.bullets")
  end)

  it("should correctly indent the CURRENT visual selection and not the PREVIOUS one", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Line 1",
      "* Line 2",
      "* Line 3",
      "* Line 4",
    })

    -- First, simulate a selection on lines 3 and 4 to set the initial '< and '> marks
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    vim.cmd("normal! V")
    vim.cmd("normal! j")
    vim.cmd("normal! \27") -- \27 is the escape character

    -- Verify the marks are on lines 3 and 4
    assert.are.equal(3, vim.fn.line("'<"))
    assert.are.equal(4, vim.fn.line("'>"))

    -- Now, simulate a NEW visual selection on lines 1 and 2
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("normal! V")
    vim.cmd("normal! j")

    -- Call the indent function while STILL in visual mode (mode 'V')
    bullets.indent('V')

    -- Check that ONLY lines 1 and 2 were indented
    assert.are.same({
      "    + Line 1",
      "    + Line 2",
      "* Line 3",
      "* Line 4",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

    -- Verify the marks are now correctly updated to lines 1 and 2
    assert.are.equal(1, vim.fn.line("'<"))
    assert.are.equal(2, vim.fn.line("'>"))
  end)

  it("should fallback to feedkeys and not modify non-bullet lines in visual mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "  Plain line 1",
      "  Plain line 2",
    })

    -- Select both lines
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("normal! V")
    vim.cmd("normal! j")

    -- Call unindent
    bullets.unindent('V')

    -- Verify bullets.lua didn't manually strip 4 spaces (since it uses feedkeys instead)
    -- In a real vim session, feedkeys would execute '<', but in headless test without
    -- event loops, the lines should remain unchanged here.
    assert.are.same({
      "  Plain line 1",
      "  Plain line 2",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)

  it("should correctly handle mixed bullet and plain text in visual mode", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Bullet point",
      "  Plain text below",
    })

    -- Select both lines
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("normal! V")
    vim.cmd("normal! j")

    -- Call indent
    bullets.indent('V')

    -- Both should be shifted by config.sub_indent (4 spaces)
    -- The bullet should cycle to '+'
    assert.are.same({
      "    + Bullet point",
      "      Plain text below",
    }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)
end)
