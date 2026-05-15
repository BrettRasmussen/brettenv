-- Initialize the environment
local mode = os.getenv("NV_MODE")

-- Set leader before anything else
vim.g.mapleader = ","

-- Load modular configs
-- IMPORTANT: Load plugins FIRST so Lazy.nvim can set up the runtime path for keymaps
require("config.plugins")
require("config.options")
require("config.keymaps")

-- Window View Persistence
local persistence = require("utils.persistence")
local view_group = vim.api.nvim_create_augroup("ViewPersistence", { clear = true })

vim.api.nvim_create_autocmd("BufLeave", {
  group = view_group,
  pattern = "*",
  callback = persistence.save_view,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = view_group,
  pattern = "*",
  callback = persistence.restore_view,
})

-- Track last tab for Meta-5
vim.api.nvim_create_autocmd("TabLeave", {
  group = view_group,
  callback = function()
    vim.g.lasttab = vim.api.nvim_get_current_tabpage()
  end,
})

-- Apply Mode-specific overrides
if mode == "reader" then
  vim.opt.confirm = false
  vim.keymap.set("n", "<leader>q", ":qa!<CR>", { desc = "Quick quit (no prompt)" })
elseif mode == "notes" then
  vim.opt.filetype = "markdown"

  -- Auto-save logic
  vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    command = "write",
  })
  vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    command = "update",
  })

  -- Start in notes directory (adjust path as needed)
  local notes_dir = vim.fn.expand("~/Documents/notes")
  if vim.fn.isdirectory(notes_dir) == 1 then
    vim.api.nvim_set_current_dir(notes_dir)
  end
end