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

-- 安装和配置插件
require("lazy").setup({
	-- LazyVim 的核心插件
	{ "folke/LazyVim", import = "lazyvim.plugins" },
	-- 在这里添加任何其他插件
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.prettier, -- 你可以根据需要添加更多的格式化工具
					null_ls.builtins.formatting.clang_format,
				},
			})
			--为格式化设置快捷键
			--TODO
			--并没有成功设置快捷键，所以我删了，以后再来设置
		end,
	},
	{
		-- 这个是光标平滑移动的插件
		-- TODO
		-- 好吧，还是没有配成功
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				-- 设置动画时间为 100 毫秒
				mappings = { "<C-u>", "<C-d>" },
				hide_cursor = true, -- 在滚动动画期间隐藏光标
				stop_eof = true, -- 在到达文件结尾时停止滚动
				use_local_scrolloff = false, -- 使用局部 scrolloff 而不是全局
				respect_scrolloff = false, -- 如果 scrolloff 和文件开头/结尾冲突，忽略 scrolloff
				cursor_scrolls_alone = true, -- 光标的水平移动是否单独滚动
				easing_function = nil, -- 默认的缓和函数
				pre_hook = nil, -- 滚动动画开始前执行的钩子函数
				post_hook = nil, -- 滚动动画结束后执行的钩子函数
			})

			local t = require("neoscroll.config").t
			require("neoscroll.config").set_mappings({
				["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100", [['sine']] } },
				["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100", [['sine']] } },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lspconfig").clangd.setup({})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "L3MON4D3/LuaSnip" },
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				highlight = {
					enable = true,
				},
			})
		end,
	},
	-- 其他插件导入
	{ import = "lazyvim.plugins.extras.lang.typescript" },
	{ import = "lazyvim.plugins.extras.lang.json" },
}, {
	defaults = {
		lazy = true, -- 大多数插件应为懒加载
		version = "*", -- 安装最新的稳定版本
	},
	install = {
		colorscheme = { "tokyonight", "habamax" },
	},
	checker = { enabled = true }, -- 自动检查插件更新
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
vim.api.nvim_create_user_command("RunCpp", function()
	-- 获取当前文件名
	local file = vim.fn.expand("%:p")
	-- 获取文件名（无扩展名）和目录
	local filename = vim.fn.expand("%:t:r")
	local dir = vim.fn.expand("%:p:h")

	-- 编译命令
	local compile_cmd = string.format("g++ %s -o %s/%s", file, dir, filename)
	-- 运行命令
	local run_cmd = string.format("%s/%s", dir, filename)

	-- 打开一个新的终端窗口并运行编译和执行命令
	vim.cmd("split | terminal")
	vim.fn.chansend(vim.b.terminal_job_id, compile_cmd .. " && " .. run_cmd .. "\n")
end, { nargs = 0 })

-- 绑定 F5 键来调用 RunCpp 命令
vim.api.nvim_set_keymap("n", "<F5>", ":RunCpp<CR>", { noremap = true, silent = true })
