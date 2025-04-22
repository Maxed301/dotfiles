return {
	{
		"L3MON4D3/LuaSnip",
		build = (function()
			if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				return
			end
			return "make install_jsregexp"
		end)(),
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			fuzzy = {
				implementation = "prefer_rust_with_warning",
				prebuilt_binaries = {},
			},

			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
			},

			completion = {
				accept = { auto_brackets = { enabled = true } },
				menu = { draw = { treesitter = { "lsp" } }, border = "rounded" },
				documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
				ghost_text = { enabled = false },
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			appearance = {
				nerd_font_variant = "mono",
				use_nvim_cmp_as_default = false,
			},

			signature = { enabled = true, window = { border = "single" } },

			cmdline = { enabled = false },

			keymap = {
				preset = "enter",
				["<C-n>"] = { "select_next", "fallback_to_mappings" },
				["<C-p>"] = { "select_prev", "fallback_to_mappings" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-y>"] = { "select_and_accept", "fallback" },
				["<C-Space>"] = { "show", "fallback" },
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
			},
		},
		config = function(_, opts)
			require("blink.cmp").setup(opts)
		end,
	},
}
