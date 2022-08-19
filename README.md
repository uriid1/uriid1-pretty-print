# Use
![Screenshot](https://github.com/uriid1/scrfmp/blob/main/uriid1-pretty-print/pp.png) <br>

```lua
local pretty_print = require("uriid1-pretty-print")

-- setup
pretty_print.tabs_count    = 4
pretty_print.tabs_symbol   = ' '
pretty_print.colorize      = true
pretty_print.show_comments = true

--
local pp = pretty_print.prettyPrint

local tbl = {
    message = {
        chat = {
            cool     = true,
            type     = 'supergroup',
            username = '@pp_is_simple',
            id       = -1234567890,
            title    = 'Колобок повесился.',
        };

        get = function() end,
        set = nil,
        cdata = '',
        thread = '',
        empty_table = {},
    };
}

--
pp(tbl)
```