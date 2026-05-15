-- .devinfo/test_init.lua
-- This file provides a minimal configuration to run plenary tests.

-- Explicitly set runtimepath to avoid conflicts with user config
vim.opt.runtimepath = ""

-- Add plenary to the runtime path
local plenary_path = vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")
vim.opt.runtimepath:append(plenary_path)

-- Add the current project's nvim directory to the runtime path for our plugin
local project_nvim_path = vim.fn.getcwd() .. "/nvim"
vim.opt.runtimepath:append(project_nvim_path)

-- Now, run the tests
require('plenary.busted').run('nvim/lua/tests/bullets_spec.lua')
require('plenary.busted').run('nvim/lua/tests/bullets_visual_spec.lua')
require('plenary.busted').run('nvim/lua/tests/bullets_fallback_spec.lua')
require('plenary.busted').run('nvim/lua/tests/bullets_range_spec.lua')
