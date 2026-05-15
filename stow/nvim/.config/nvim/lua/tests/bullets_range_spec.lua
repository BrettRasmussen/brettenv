describe("bullets.lua get_current_bullet_range function fixes", function()
  local bufnr
  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    -- Reset the module to ensure a clean config state for these tests
    package.loaded["utils.bullets"] = nil
    bullets = require("utils.bullets")
  end)

  it("should return nil if cursor is on a plain text line BELOW a bullet list", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* Multi-line bullet",
      "  continuation line",
      "  another continuation line",
      "",
      "",
      "Plain text paragraph",
    })

    -- Cursor is on line 6 (the plain text paragraph)
    vim.api.nvim_win_set_cursor(0, { 6, 0 })

    local range = bullets.get_current_bullet_range()
    assert.is_nil(range)
  end)

  it("should return nil if cursor is on an EMPTY line between two bullet lists", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "* List 1 item",
      "",
      "* List 2 item",
    })

    -- Cursor is on line 2 (the empty line)
    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    local range = bullets.get_current_bullet_range()
    assert.is_nil(range)
  end)
end)
