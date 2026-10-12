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
			c = { "clang-format" },
			cpp = { "clang-format" },
			cuda = { "clang-format" },
			python = { "yapf" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}
