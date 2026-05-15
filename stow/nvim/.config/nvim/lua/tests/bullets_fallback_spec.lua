describe("bullets.lua fallback tests", function()
  local bufnr
  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    -- Reset the module to ensure a clean config state for these tests
    package.loaded["utils.bullets"] = nil
    bullets = require("utils.bullets")
  end)

  it("should handle insert mode fallback for non-bullet lines", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Plain text line" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })

    -- These should complete without error and return nil (fallback)
    bullets.indent('i')
    bullets.unindent('i')

    -- Line should remain unchanged by the bullet logic itself
    assert.are.same({ "Plain text line" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)
end)
