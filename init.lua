-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install lazy.nvim if it is not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Install and configure plugins
require("lazy").setup({
    spec = {
        { "folke/LazyVim", import = "lazyvim.plugins" },
        -- add any additional plugins here
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.json" },
    },
    defaults = {
        lazy = true, -- most plugins should be lazy-loaded
        version = "*", -- install the latest stable version
    },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = true }, -- automatically check for plugin updates
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- 自动命令组
vim.api.nvim_create_augroup("CppTemplate", { clear = true })

-- 自动命令：在新建 .cpp 文件时插入模板
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.cpp",
    callback = function()
        local template_path = vim.fn.expand("~/.config/nvim/templates/cpp_template.cpp")
        local lines = vim.fn.readfile(template_path)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end,
    group = "CppTemplate",
})



-- 创建一个命令来编译并运行当前的 C++ 文件
vim.api.nvim_create_user_command(
    'RunCpp',
    function()
        -- 获取当前文件名
        local file = vim.fn.expand('%:p')
        -- 获取文件名（无扩展名）和目录
        local filename = vim.fn.expand('%:t:r')
        local dir = vim.fn.expand('%:p:h')

        -- 编译命令
        local compile_cmd = string.format('g++ %s -o %s/%s', file, dir, filename)
        -- 运行命令
        local run_cmd = string.format('%s/%s', dir, filename)

        -- 打开一个新的终端窗口并运行编译和执行命令
        vim.cmd('split | terminal')
        vim.fn.chansend(vim.b.terminal_job_id, compile_cmd .. ' && ' .. run_cmd .. '\n')
    end,
    { nargs = 0 }
)

-- 绑定 F5 键来调用 RunCpp 命令
vim.api.nvim_set_keymap('n', '<F5>', ':RunCpp<CR>', { noremap = true, silent = true })

