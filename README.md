![Screenshot](https://github.com/uriid1/scrfmp/blob/main/uriid1-pretty-print/pp.png) <br>

# Features
<b>Customization:</b> 0, 8, 255 color scheme, its own tab character, the number of tab characters is also configurable.<br>
<b>Debug:</b> In debug mode, links to tables are displayed.<br>
<b>Comments:</b> Support for comments for long tables.<br>
<b>Escape-format:</b> In string_to_dec mode, all characters are converted to decimal values.<br>
<b>Structuring:</b> Tables are printed first, then everything else.<br>
<b>Portable:</b> Works in lua 5.1, lua 5.2, lua5.3, lua5.4, LuaJIT and in Luvit!<br>

# Use
```lua
-- local m_pp = require("luvit-pretty-print")  -- For luvit
local m_pp = require("lua-pretty-print")  -- For lua, luajit, luau

-- Setup
-- Only for lua version
-- in luvit, the color scheme is set automatically
m_pp.current_theme = 256

-- Turn off colors
-- m_pp.colorize = false

m_pp.tabs_count    = 2
m_pp.tabs_symbol   = '->'
m_pp.show_comments = true 
m_pp.string_to_dec = true -- Converting a string to a decimal value
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

    ['hello'] = {
        1, 2, 3
    }
}

-- Recusrse test 1
tbl.recurse1 = tbl
tbl.recurse2 = tbl.recurse1
tbl.recurse2.hello = 'hello'

-- Recusrse test 2
tbl.recurse3 = tbl.recurse1.recurse1
tbl.recurse4 = tbl.recurse1.recurse1.message

-- Pretty print
pp(tbl)

-- Dump
-- pp( dump(tbl) )
```