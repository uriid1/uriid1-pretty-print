-- ####--------------------------------####
-- #--# Author:   by uriid1            #--#
-- #--# License:  GNU GPLv3            #--#
-- #--# Telegram: @main_moderator      #--#
-- #--# E-mail:   appdurov@gmail.com   #--#
-- ####--------------------------------####

local M = {}

local success, uv = pcall(require, 'uv')
if not success then
  success, uv = pcall(require, 'luv')
end
assert(success, uv)

local getenv = require('os').getenv
local stdout

-- Tabs Setup
M.tabs_count = 2
M.tabs_symbol = ' '

-- Theme Setup
M.colorize = true
local current_theme = 16

-- Debug
M.escape_format = true
M.show_comments = false
M.debug = false

local themes = {
    -- color theme using 16 ansi colors
    [16] = {
        ["nil"]      = "1;30", -- bright-black
        boolean      = "0;94", -- yellow
        number       = "1;95", -- bright-yellow
        string       = "0;93", -- green
        ["function"] = "0;91", -- purple
        thread       = "1;91", -- bright-purple

        table        = "1;90", -- bright blue
        userdata     = "1;34", -- bright cyan
        cdata        = "0;35", -- cyan

        comment      = "0;30",
        tabs         = "0;90",
    },

    -- color theme using ansi 256-mode colors
    [256] = {
        ["nil"]      = "38;5;244",
        boolean      = "38;5;177",
        number       = "38;5;213",
        string       = "38;5;221",
        ["function"] = "38;5;204",
        thread       = "38;5;199",

        table        = "38;5;99",  -- blue
        userdata     = "38;5;39",  -- blue2
        cdata        = "38;5;69",  -- teal

        comment      = "38;5;8",
        tabs         = "38;5;233",
    },
}

local special = {
    [7]  = 'a';
    [8]  = 'b';
    [9]  = 't';
    [10] = 'n';
    [11] = 'v';
    [12] = 'f';
    [13] = 'r';
}

local controls = {}
for i = 0, 31 do
    local c = special[i]
    if not c then
        if i < 10 then
            c = "00" .. tostring(i)
        else
            c = "0" .. tostring(i)
        end
    end

    controls[i] = tostring('\\' .. c)
end

controls[92] = tostring('\\\\')
controls[34] = tostring('\\"')
controls[39] = tostring("\\'")

for i = 128, 255 do
    local c
    if i < 100 then
        c = "0" .. tostring(i)
    else
        c = tostring(i)
    end

    controls[i] = tostring('\\' .. c)
end

local function stringEscape(c)
    return controls[string.byte(c, 1)]
end

local function efmt(str, is_key)

    local type_check = type(str)
    if (type_check ~= 'string') and (type_check ~= 'number') then
        return str
    end

    if not M.escape_format then
        if is_key then
            if tonumber(str) then
                return "["..str.."]"
            end

            return str
        end
    end

    local fmt = string.gsub(str, '[%c\\\128-\255]', stringEscape)
    if is_key then
        if not (fmt == str) then
            if tonumber(str) then
                return "["..fmt.."]"
            end

            return "['"..fmt.."']"
        end

        if tonumber(str) then
            return "["..fmt.."]"
        end
    end

    return fmt
end

local function tocolor(str, val_type)
    if not themes[current_theme] then
        return str
    end

    if M.colorize then
        return ('\27[%sm%s\27[0m')
            :format(themes[current_theme][val_type], str)
    end

    return str
end

local function type_format(val)

    local val_type = type(val)

    if val_type == 'string' then
        local str = "'" .. val .. "'"
        return tocolor(str, val_type)
    elseif val_type == 'number' then
        return tocolor(tostring(val), val_type)
    elseif val_type == 'function' then
        return tocolor(tostring(val), val_type)
    elseif val_type == 'boolean' then
        return tocolor(tostring(val), val_type)
    elseif val_type == 'userdata' then
        return tocolor(tostring(val), val_type)
    elseif val_type == 'cdata' then
        return tocolor(tostring(val), val_type)
    elseif val_type == 'thread' then
        return tocolor(tostring(val), val_type)
    end

    return tostring(val)
end

local table2string
function table2string(t, tabs_count, recurse, comment)
    local tabs = string.rep(M.tabs_symbol, M.tabs_count)
    tabs_count = tabs_count or 1
    local res = '{\n'

    local next_key
    if recurse then
        next_key = next(t)
        if not next_key then
            res = '{'
        end
    end

    -- Parse
    comment = comment or {}
    for key, val in next, t do
        
        --
        key = efmt(key, true)
        val = efmt(val, false)

        if type(val) == 'table' then
           
            -- Overflow handle
            local val_dump = ''
            if not (t == val) then
                -- Add comment
                table.insert(comment, tonumber(key) and '['..key..']' or key)
                --
                val_dump = table2string(val, tabs_count + 1, true, comment)
            else
                val_dump = tostring(t)..';'
            end

            local rep_tabs = tocolor(string.rep(tabs, tabs_count), 'tabs')

            -- Debug
            local str_debug = ''
            if M.debug then
                str_debug = (' %s'):format(tostring(t[key]))
            end

            res = res .. rep_tabs..tocolor(key, 'table')..str_debug..' = '..val_dump
            res = res .. '\n'
        else
            val = type_format(val)
            local rep_tabs = tocolor(string.rep(tabs, tabs_count), 'tabs')

            res = res .. rep_tabs..tocolor(key, 'string')..' = '..val
            res = res .. ',\n'
        end
    end

    local rep_tabs = ''
    if next_key then
        rep_tabs = tocolor(string.rep(tabs, tabs_count - 1), 'tabs')
    end

    local str_comment = ''
    if next(comment) and M.show_comments and next_key then
        str_comment = tocolor(' -- '..table.concat(comment, '.'), 'comment')
    else
        str_comment = ''
    end
    comment[#comment] = nil

    return res .. ("%s%s"):format(rep_tabs, '};' .. str_comment)
end

local function console_write(fs, s)
    s = s .. '\n'
    if uv.guess_handle(uv.fileno(fs)) == 'tty' then
        repeat
            local n, e = uv.try_write(fs, s)
            if n then
                s = s:sub(n + 1)
                n = 0
            else
                if e:match('^EAGAIN') then
                    n = 0
                else
                    assert(n, e)
                end
            end
        until n == #s
    else
        uv.write(fs, s)
    end
end

-- pp
M.prettyPrint = function(...)
    local arguments = {...}
    for i = 1, select('#', ...) do
        local arg_type = type(arguments[i])
        if arg_type == 'table' then
            arguments[i] = table2string(arguments[i])
        else
            arguments[i] = type_format(arguments[i])
        end
    end

    console_write(stdout, table.concat(arguments, ",\t"))
end

if uv.guess_handle(1) == 'tty' then
    -- TTY handles represent a stream for the console.
    stdout = assert(uv.new_tty(1, false))

    -- auto-detect when 16 color mode should be used
    local term = getenv("TERM")
    if term and (term == 'xterm' or term:find'-256color$') then
        current_theme = 256
    else
        current_theme = 16
    end
else
    stdout = uv.new_pipe(false)
    uv.pipe_open(stdout, 1)
end

return M