require('nvim-treesitter.configs').setup {
    ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'python', 'rust', 'vim', 'vimdoc' },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },

}
