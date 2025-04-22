return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim" },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		do
			local orig_util_open = vim.lsp.util.open_floating_preview
			vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				return orig_util_open(contents, syntax, opts, ...)
			end
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()

		local servers = {
			clangd = { cmd = { "clangd", "--offset-encoding=utf-16" } },
			pyright = {},
			rust_analyzer = {},
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
		}

		require("mason").setup({
			ui = {
				border = "rounded",
			},
		})

		require("mason-tool-installer").setup({ ensure_installed = vim.tbl_keys(servers) })
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local opts = servers[server_name] or {}
					opts.capabilities = capabilities
					require("lspconfig")[server_name].setup(opts)
				end,
			},
		})

		require("fidget").setup()
	end,
}
