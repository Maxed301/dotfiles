local max_filesize = 100 * 1024 -- 100 KB

local function is_large_file(buf)
	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
	return ok and stats and stats.size > max_filesize
end

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPost",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"cpp",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"python",
			"rust",
			"vim",
			"vimdoc",
		},
		auto_install = true,
		highlight = {
			enable = true,
			disable = function(_, buf)
				return is_large_file(buf)
			end,
			additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
			disable = function(_, buf)
				return is_large_file(buf)
			end,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		-- fallback to regex on large files
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(ctx)
				if is_large_file(vim.api.nvim_get_current_buf()) then
					vim.cmd.syntax("on")
					vim.opt_local.foldmethod = "manual"
				end
			end,
		})
	end,
}
