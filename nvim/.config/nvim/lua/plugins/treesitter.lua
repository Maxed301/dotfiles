local max_filesize = 100 * 1024 -- 100 KB

local function is_large_file(buf)
	local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
	return ok and stats and stats.size > max_filesize
end

local languages = {
	"bash",
	"c",
	"cpp",
	"cuda",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"vim",
	"vimdoc",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = function()
		require("nvim-treesitter").install(languages):wait(300000)
	end,
	config = function()
		local treesitter = require("nvim-treesitter")

		treesitter.setup()

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ctx)
				if is_large_file(ctx.buf) then
					vim.cmd.syntax("on")
					vim.opt_local.foldmethod = "manual"
					return
				end

				local ok = pcall(vim.treesitter.start, ctx.buf)
				if ok then
					vim.bo[ctx.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- fallback to regex on large files
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(ctx)
				if is_large_file(ctx.buf) then
					vim.cmd.syntax("on")
					vim.opt_local.foldmethod = "manual"
				end
			end,
		})
	end,
}
