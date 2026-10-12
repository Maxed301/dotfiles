return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"j-hui/fidget.nvim",
		"saghen/blink.cmp",
	},
	config = function()
		-- Neovim >= 0.11 already maps grn (rename), gra (code action), grr
		-- (references), gri (implementation), gO (symbols) and K (hover).
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
			callback = function(ev)
				local bufopts = { buffer = ev.buf }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
			end,
		})

		local servers = {
			clangd = {
				cmd = {
					"clangd",
					"--offset-encoding=utf-16",
					"--query-driver=/usr/bin/nvcc,/usr/local/cuda/bin/nvcc,/usr/bin/c++,/usr/bin/g++,/usr/bin/g++-12",
				},
			},
			glsl_analyzer = {},
			pyright = {},
			rust_analyzer = {},
			taplo = {},
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
		}

		local formatters = {
			"prettier",
			"prettierd",
			"stylua",
			"yapf",
		}

		vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
		for name, opts in pairs(servers) do
			vim.lsp.config(name, opts)
		end

		require("mason-tool-installer").setup({ ensure_installed = vim.list_extend(vim.tbl_keys(servers), formatters) })
		-- mason-lspconfig calls vim.lsp.enable() for every installed server
		require("mason-lspconfig").setup({ automatic_enable = { exclude = { "stylua" } } })

		require("fidget").setup({
			progress = {
				ignore = { "mojo" },
			},
		})
	end,
}
