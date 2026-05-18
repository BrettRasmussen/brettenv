-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load themes from modular config
local themes = require("config.themes")

local plugins = {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    config = function()
      local status, ts = pcall(require, "nvim-treesitter.configs")
      if status then
        ts.setup({
          highlight = { enable = true },
          indent = { enable = true },
          matchup = { enable = true },
        })
      end
    end,
  },

  -- LSP & Completion Stack (Updated for Neovim 0.11+ API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-vsnip",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "html", "cssls", "emmet_ls", "solargraph", "elixirls" },
      })

      -- Using the new Neovim 0.11+ API for LSP configuration
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Helper to find the latest rbenv Ruby version
      local function get_latest_rbenv_ruby()
        local handle = io.popen("rbenv versions --bare | grep -v 'system' | sort -V | tail -n 1")
        if handle then
          local result = handle:read("*a")
          handle:close()
          return result:gsub("%s+", "") -- Remove whitespace/newlines
        end
        return nil
      end

      local latest_ruby = get_latest_rbenv_ruby()
      local servers = { "html", "cssls", "emmet_ls", "solargraph", "elixirls" }

      for _, server_name in ipairs(servers) do
        local config = { capabilities = capabilities }

        -- Custom configurations per server
        if server_name == "solargraph" then
          config.filetypes = { "ruby", "rake" }
          if latest_ruby and latest_ruby ~= "" then
             -- Force solargraph to run using the latest installed Ruby
            config.cmd = { "env", "RBENV_VERSION=" .. latest_ruby, "solargraph", "stdio" }
          end
        end

        if vim.lsp.config then
          vim.lsp.enable(server_name, config)
        else
          require("lspconfig")[server_name].setup(config)
        end
      end

      -- Completion Engine Setup
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- AI Companion with Quota Optimization, Token Counter, & Ollama Fallback
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "gemini" },
          inline = { adapter = "gemini" },
        },
        display = {
          chat = {
            show_token_count = true, -- Enable the Token Counter in the sidebar
            window = {
              layout = "vertical",
              width = 0.45, -- Increased from 0.3 for better legibility
            },
          },
        },
        adapters = {
          -- OPTIMIZED GEMINI ADAPTER
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-2.0-flash" },
                max_tokens = { default = 2048 },
              },
              env = { api_key = "GEMINI_API_KEY" },
            })
          end,
          -- LOCAL OLLAMA FALLBACK (Recommended: qwen2.5-coder)
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                model = { default = "qwen2.5-coder" },
              },
            })
          end,
        },
        -- Context Exclusions and Custom Slash Commands
        opts = {
          ignore_patterns = {
            "node_modules/",
            "vendor/bundle/",
            "log/",
            "logs/",
            "tmp/",
            "%.git/",
            "%.bakpas/",
          },
          slash_commands = {
            ["local"] = {
              description = "Send the current buffer to local Ollama (qwen2.5-coder)",
              callback = function(chat)
                local handle = require("codecompanion.utils.slash_commands").get_active_buffer()
                chat:add_message({
                  role = "user",
                  content = "Analyze this file locally: " .. handle.content,
                }, { adapter = "ollama" })
              end,
            },
          },
        },
      })
    end,
  },

  -- FZF-Lua with Exclusions
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        winopts = { preview = { layout = "vertical" } },
        file_ignore_patterns = {
          "node_modules/", "%.git/", "%.DS_Store", "%.bakpas/", "%.devinfo/backups/",
          "target/", "dist/", "build/", "%.o", "%.pyc",
          "vendor/bundle/", "%.gemini_work/", "tmp/", "public/assets/", "public/ckeditor/",
        },
        files = {
          fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude node_modules",
        },
        buffers = {
          file_ignore_patterns = false,
        },
      })
    end,
  },
  { "pbogut/fzf-mru.vim" },

  -- Snippets (vsnip)
  {
    "hrsh7th/vim-vsnip",
    dependencies = { "hrsh7th/vim-vsnip-integ" },
    init = function()
      vim.g.vsnip_snippet_dir = vim.fn.expand("~/.config/nvim/snippets")
      vim.g.vsnip_filetypes = {
        javascriptreact = { "javascript" },
        typescriptreact = { "typescript" },
        vue = { "vue", "javascript", "html" },
      }
    end,
  },

  -- Modern Outline (Aerial)
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      layout = {
        default_direction = "float",
        max_width = { 80, 0.4 },
        min_width = 30,
        height = 0.8,
      },
      close_on_select = true, -- Close when you jump
      -- Keymaps specifically for the Aerial buffer
      keymaps = {
        ["<esc>"] = "actions.close",
        ["q"] = "actions.close",
      },
    },
  },

  -- Modernized File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { side = "left", width = 30 },
        actions = { open_file = { quit_on_open = true } },
      })
    end,
  },

  -- Modernized Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Helpers
  { "tpope/vim-repeat" },
  { "easymotion/vim-easymotion" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "echasnovski/mini.indentscope",
    version = "*",
    config = function()
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
      })
    end,
  },
  { "AndrewRadev/splitjoin.vim" },
  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_enabled = 0
    end,
  },
}

-- Combine standard plugins with the theme list
for _, theme in ipairs(themes) do
  table.insert(plugins, theme)
end

require("lazy").setup(plugins)
