local colors = require("config.palette")

return {
	"lukas-reineke/virt-column.nvim",
	opts = {
		char = "X",
		highlight = "VirtColHighlight",
	},
	config = function(_, opts)
		require("virt-column").setup(opts)
		vim.api.nvim_set_hl(0, "VirtColHighlight", { bg = colors.black, fg = colors.magenta })
	end,
}
