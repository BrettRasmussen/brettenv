local keymap = vim.keymap.set
local bullets = require("utils.bullets")
local sessions = require("utils.sessions")
local redir = require("utils.redir")

-- Essentials
keymap("n", "<del>", "<esc>")

-- Navigation
keymap({ "n", "v", "o" }, "<m-u>", "<c-o>", { desc = "Jump to previous line" })
keymap("n", "j", "gj")
keymap("n", "k", "gk")
keymap("n", "-", "$")
keymap({ "n", "v" }, "<m-j>", "25j")
keymap({ "n", "v" }, "<m-k>", "25k")
keymap("i", "<m-j>", "<esc>25j")
keymap("i", "<m-k>", "<esc>25k")

-- Scrolling
keymap({ "n", "v" }, "<s-m-j>", "<c-e>")
keymap({ "n", "v" }, "<s-m-k>", "<c-y>")

-- Custom Bullet Indentation (from utils)
keymap({ "n", "i", "v" }, "<m-l>", function()
  bullets.indent(vim.api.nvim_get_mode().mode)
end, { desc = "Bullet/Normal Indent" })
keymap({ "n", "i", "v" }, "<m-h>", function()
  bullets.unindent(vim.api.nvim_get_mode().mode)
end, { desc = "Bullet/Normal Unindent" })

-- buffer & tab switching
keymap("n", "<m-y>", ":tabp<cr>", { desc = "Previous tab" })
keymap("n", "<m-o>", ":tabn<cr>", { desc = "Next tab" })
keymap("v", "<m-y>", "<esc>:tabp<cr>", { desc = "Previous tab" })
keymap("v", "<m-o>", "<esc>:tabn<cr>", { desc = "Next tab" })
keymap("i", "<m-y>", "<c-o>:tabp<cr>", { desc = "Previous tab" })
keymap("i", "<m-o>", "<c-o>:tabn<cr>", { desc = "Next tab" })
keymap("n", "<m-6>", "<c-6>")
keymap("n", "<m-5>", function()
  if vim.g.lasttab then
    vim.cmd("tabn " .. vim.g.lasttab)
  end
end, { desc = "Jump to last tab" })

-- closing tabs & windows
keymap("n", "<leader>w", ":q<cr>")
keymap("n", "<leader>q", ":qa<cr>")

-- EasyMotion
keymap("n", "<leader>f", "<Plug>(easymotion-bd-f)", { desc = "EasyMotion: Find char" })
keymap("n", "<leader>F", "<Plug>(easymotion-overwin-f)", { desc = "EasyMotion: Find char overwin" })

-- Search & Selection (FZF-Lua)
keymap("n", "<leader>e", ":FzfLua files<cr>", { desc = "Find files" })
keymap("n", "<leader>be", ":FzfLua buffers<cr>", { desc = "Find buffers" })
keymap("n", "<leader>A", ":FzfLua live_grep<cr>", { desc = "Live grep" })
keymap("n", "<leader>o", ":FzfLua lsp_document_symbols<cr>", { desc = "Fuzzy Document Symbols" })
keymap("n", "<leader>O", ":FzfLua lsp_workspace_symbols<cr>", { desc = "Fuzzy Workspace Symbols" })
keymap("n", "<leader>/", ":noh<cr>")
keymap("n", "<leader>sa", "1GVG", { desc = "Select All" })
keymap("n", "<leader>u", "ct_")

-- Native Commenting
keymap("n", "<leader>cc", "gcc", { remap = true, desc = "Toggle comment line" })
keymap("v", "<leader>c", "gc", { remap = true, desc = "Toggle comment selection" })
keymap("n", "<leader>c", "gc", { remap = true, desc = "Toggle comment operator" })

-- AI Intelligence (cc / codecomp)
-- All consolidated under <leader>a for left-hand rolling
keymap({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle AI Chat" })
keymap({ "n", "v" }, "<leader>at", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions (AI + LSP)" })
keymap("v", "<leader>as", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to AI Chat" })
keymap("n", "<leader>ae", "I<cmd>CodeCompanion ", { desc = "AI Inline Prompt (Editing)" })
keymap({ "n", "v" }, "<leader>ax", "<cmd>CodeCompanionChat /explain<cr>", { desc = "AI Explain" })
keymap({ "n", "v" }, "<leader>af", "<cmd>CodeCompanionChat /fix<cr>", { desc = "AI Fix Diagnostics" })
keymap("n", "<leader>ar", "<cmd>CodeCompanionChat<cr>", { desc = "AI Reset/Clear Chat Context" })

-- Meta-n: Jump snippet placeholder OR search for 'xxx'
local function jump_or_xxx()
  if vim.fn['vsnip#jumpable'](1) == 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-jump-next)', true, true, true), '', true)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>/xxx<cr>', true, true, true), 'n', true)
  end
end

local function jump_prev_or_xxx()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-jump-prev)', true, true, true), '', true)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>?xxx<cr>', true, true, true), 'n', true)
  end
end

keymap({'n', 'i', 'v'}, '<m-n>', jump_or_xxx, { desc = "Jump snippet or find 'xxx'" })
keymap({'n', 'i', 'v'}, '<m-N>', jump_prev_or_xxx, { desc = "Jump snippet (prev) or find 'xxx' (prev)" })

-- Re-select last pasted text
keymap("n", "gV", '`[v`]', { desc = "Select last pasted text" })

-- MRU Search
keymap("n", "<leader>E", ":FZFMru<cr>", { desc = "Find recently used files" })

-- File Explorer
keymap("n", "<leader>R", ":Lexplore<cr>", { desc = "Open Netrw" })

-- LSP Keymaps
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gr", ":FzfLua lsp_references<cr>", { desc = "Fuzzy References" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Text Width Shortcuts
keymap("n", "<leader>1", ":set tw=0<cr>")
keymap("n", "<leader>2", ":set tw=80<cr>")
keymap("n", "<leader>3", ":set tw=100<cr>")
keymap("n", "<leader>4", ":set tw=120<cr>")

-- Editing Helpers
keymap("n", "<leader>d", ":lua require('utils.edit').strip_trailing_whitespace()<cr>", { desc = "Strip whitespace" })
keymap("n", "<leader>p", "gqap", { desc = "Format paragraph" })

-- Backtick Wrapping (Powered by nvim-surround)
keymap("n", "<leader>`", "ysiW`", { remap = true, desc = "Wrap WORD with backticks" })
keymap("v", "<leader>`", "S`", { remap = true, desc = "Wrap selection with backticks" })

-- Session Management
keymap("n", "<leader>ss", function()
  local file = sessions.get_session_file()
  vim.cmd("mksession! " .. file)
  print("Session saved to " .. file)
end)

keymap("n", "<leader>sr", function()
  local file = sessions.get_session_file()
  vim.cmd("source " .. file)
  print("Session loaded from " .. file)
end)

-- Redir Command Registration
vim.api.nvim_create_user_command("Redir", redir.redir, {
  nargs = 1,
  complete = "command",
  desc = "Redirect command output to a vertical scratch buffer"
})

-- Aerial Keymaps (formerly Tagbar)
keymap("n", "<leader>t", "<cmd>AerialToggle<cr>", { desc = "Toggle Code Outline" })

-- nvim-tree Keymaps
keymap("n", "<leader>r", ":NvimTreeFindFile<cr>", { desc = "Find file in tree" })

-- Custom Bullet Mappings (Filetype specific)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "tex", "plaintex", "norg", "gitcommit", "mail", "rst", "rmd", "scratch" },
  callback = function()
    -- List Continuation with Enter
    keymap("i", "<CR>", function()
      if not bullets.handle_enter() then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      end
    end, { buffer = true, desc = "Bullet continuation with Enter" })

    -- List Continuation with o and O
    keymap("n", "o", function()
      if bullets.handle_o() then
        vim.cmd("startinsert!")
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("o", true, false, true), "n", false)
      end
    end, { buffer = true, desc = "Bullet continuation below" })

    keymap("n", "O", function()
      if bullets.handle_O() then
        vim.cmd("startinsert!")
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("O", true, false, true), "n", false)
      end
    end, { buffer = true, desc = "Bullet continuation above" })
  end
})
