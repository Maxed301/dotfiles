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
		local on_attach = function(client, bufnr)
			local bufopts = { buffer = bufnr, remap = false }
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
		end

		do
			local orig = vim.lsp.util.open_floating_preview
			vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				return orig(contents, syntax, opts, ...)
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

		require("mason").setup({ ui = { border = "rounded" } })
		require("mason-tool-installer").setup({ ensure_installed = vim.tbl_keys(servers) })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name) -- default handler
					local opts = servers[server_name] or {}
					opts.capabilities = capabilities
					opts.on_attach = on_attach -- ← add this
					require("lspconfig")[server_name].setup(opts)
				end,
			},
		})

		require("fidget").setup()
	end,
}
