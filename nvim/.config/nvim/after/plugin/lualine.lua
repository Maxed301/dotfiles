local custom_palenight = require('lualine.themes.palenight')
-- custom_palenight.normal.a.bg = 'none'
custom_palenight.normal.c.bg = 'none'
-- custom_palenight.normal.c.bg = '#232526'
custom_palenight.normal.c.fg = '#ef5939'

require('lualine').setup {
    options = { theme = custom_palenight },
}
