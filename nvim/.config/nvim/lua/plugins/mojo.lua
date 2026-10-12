return {
	"Sarctiann/mojo.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	main = "mojo",
	opts = {
		terminal = { enabled = false },
		format = { enabled = false },
		completion = { enabled = false },
		statusline = { enabled = false },
		keymaps = { enabled = false },
		commands = { master = false },
		debug = { enabled = false },
	},
}
