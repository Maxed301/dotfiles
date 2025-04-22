return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = false, lsp_fallback = false })
			end,
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = true,
		formatters_by_ft = {
			lua = { "stylua" },
			cpp = { "clang" },
			python = { "yapf" },
			javascript = { { "prettierd", "prettier" } },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}
