return {
	"folke/tokyonight.nvim",
	priority = 1000,
	opts = {
		style = "night",
		transparent = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
		on_highlights = function(hl, c)
			hl.LineNr = { bg = "NONE" }
			hl.CursorLineNr = { bg = "NONE" }
			hl.StatusLine = { bg = "NONE" }
			hl.StatusLineNC = { bg = "NONE" }
			hl.WinSeparator = { fg = c.border }
			hl.VertSplit = { fg = c.border, bg = "NONE" }

			for _, grp in ipairs({
				"SignColumn",
				"FoldColumn",
				"EndOfBuffer",
				"DiagnosticVirtualTextError",
				"DiagnosticVirtualTextWarn",
				"DiagnosticVirtualTextInfo",
				"DiagnosticVirtualTextHint",
			}) do
				hl[grp] = { bg = "NONE" }
			end
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd.colorscheme("tokyonight")
	end,
}
