local M = {}

local function project_root()
	return vim.fs.root(0, { ".git" }) or vim.uv.cwd()
end

local function build_dir()
	return project_root() .. "/build"
end

local function quickfix_has_entries()
	return #vim.fn.getqflist() > 0
end

function M.build()
	local dir = build_dir()

	if vim.fn.isdirectory(dir) == 0 then
		vim.notify("Build directory not found: " .. dir, vim.log.levels.ERROR)
		return
	end

	vim.notify("Building in " .. dir, vim.log.levels.INFO)

	vim.system({ "bash", "-lc", "make -C " .. vim.fn.shellescape(dir) .. " 2>&1" }, { text = true }, function(result)
		vim.schedule(function()
			local output = result.stdout or ""
			local lines = vim.split(output, "\n", { trimempty = true })

			vim.fn.setqflist({}, " ", {
				title = "make -C " .. dir,
				lines = lines,
				efm = vim.o.errorformat,
			})

			if result.code == 0 then
				vim.notify("Build succeeded", vim.log.levels.INFO)
				if quickfix_has_entries() then
					vim.cmd.copen()
				else
					vim.cmd.cclose()
				end
				return
			end

			vim.notify("Build failed with exit code " .. result.code, vim.log.levels.ERROR)
			vim.cmd.copen()
			if quickfix_has_entries() then
				vim.cmd.cc()
			end
		end)
	end)
end

vim.api.nvim_create_user_command("BuildProject", function()
	M.build()
end, { desc = "Build project in build and load errors into quickfix" })

return M
