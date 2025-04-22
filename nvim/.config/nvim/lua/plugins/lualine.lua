return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local custom = require("lualine.themes.palenight")
		local colors = require("config.palette")

		for _, mode in pairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
			if custom[mode] and custom[mode].c then
				custom[mode].c.bg = "NONE"
				custom[mode].c.fg = "#ef5939"
			end
		end

		local lsp_component = {
			function()
				local msg = "No Active Lsp"
				local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
				local clients = vim.lsp.get_clients()
				if next(clients) == nil then
					return msg
				end
				for _, client in ipairs(clients) do
					local filetypes = client.config.filetypes
					if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
						return " LSP: " .. client.name
					end
				end
				return msg
			end,
			color = { fg = colors.magenta2, gui = "bold" },
		}

		require("lualine").setup({
			options = {
				theme = custom,
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { "filename" },
				lualine_x = { lsp_component, "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
