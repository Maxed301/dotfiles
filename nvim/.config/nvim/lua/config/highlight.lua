local M = {}
local colors = require("config.palette")
local clear_bg_groups = {
	"NormalFloat",
	"FloatBorder",
	"Pmenu",
	"PmenuSel",
	"PmenuSbar",
	"PmenuThumb",
}

local border_groups = {
	"FloatBorder",
	"WinSeparator",
	"VertSplit",
	-- telescope borders
	"TelescopePromptBorder",
	"TelescopeResultsBorder",
	"TelescopePreviewBorder",
	-- Blink-specific popup borders
	"BlinkCmpMenuBorder",
	"BlinkCmpDocBorder",
	"BlinkCmpSignatureHelpBorder",
}

function M.setup()
	for _, grp in ipairs(clear_bg_groups) do
		vim.api.nvim_set_hl(0, grp, { bg = "NONE" })
	end
	for _, grp in ipairs(border_groups) do
		vim.api.nvim_set_hl(0, grp, { fg = colors.magenta })
	end
	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", {
		fg = "#ffffff",
		bg = require("config.palette").magenta,
		bold = true,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			for _, grp in ipairs(clear_bg_groups) do
				vim.api.nvim_set_hl(0, grp, { bg = "NONE" })
			end
			for _, grp in ipairs(border_groups) do
				vim.api.nvim_set_hl(0, grp, { fg = colors.magenta2 })
			end
		end,
	})
end

return M
