# Use
![Screenshot](https://github.com/uriid1/scrfmp/blob/main/uriid1-pretty-print/pp.png) <br>

```lua
-- load module pp
local m_pp = require("luvit-pretty-print")  -- For luvit
-- local m_pp = require("lua-pretty-print")  -- For lua, luajit, luau

-- setup
-- m_pp.current_theme = 256 -- Only for lua version pp
m_pp.tabs_count    = 4
m_pp.tabs_symbol   = ' '
m_pp.colorize      = true
m_pp.show_comments = true
m_pp.escape_format = true
m_pp.debug         = true

--
local pp = m_pp.prettyPrint
local dump = m_pp.dump

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
tbl.tbl = tbl -- Recurse

--
pp(tbl)
pp(dump(tbl))
```