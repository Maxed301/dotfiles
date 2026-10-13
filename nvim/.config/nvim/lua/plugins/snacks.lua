-- snacks.nvim, used only for its image module: fff.nvim draws PNG/JPG previews
-- through it (kitty graphics protocol). Every other snacks module is off.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = { enabled = true },
		bigfile = { enabled = false },
		dashboard = { enabled = false },
		explorer = { enabled = false },
		indent = { enabled = false },
		input = { enabled = false },
		notifier = { enabled = false },
		picker = { enabled = false },
		quickfile = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
	},
}
