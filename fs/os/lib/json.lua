--------------------------------------------------------------------------------
-- json.lua — pure-Lua JSON encoder / decoder for Node9
--
-- Supports the full JSON specification (RFC 8259):
--   encode(value)         → JSON string
--   decode(str)           → Lua value
--   encode_pretty(value)  → indented JSON string
--
-- Type mapping:
--   Lua nil        ↔  JSON null
--   Lua boolean    ↔  JSON true / false
--   Lua number     ↔  JSON number (integers and floats)
--   Lua string     ↔  JSON string (UTF-8; surrogate pairs preserved)
--   Lua table      ↔  JSON array  (1-based integer keys, no gaps)
--                  ↔  JSON object (all other tables)
--
-- LuaJIT-compatible (Lua 5.1 semantics, no 5.2+ features).
--------------------------------------------------------------------------------

local M = {}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local type      = type
local tostring  = tostring
local tonumber  = tonumber
local pairs     = pairs
local ipairs    = ipairs
local floor     = math.floor
local huge      = math.huge
local concat    = table.concat
local insert    = table.insert
local format    = string.format
local byte      = string.byte
local char      = string.char
local sub       = string.sub
local find      = string.find
local match     = string.match
local gmatch    = string.gmatch
local gsub      = string.gsub

-- ── Encode ────────────────────────────────────────────────────────────────────

-- Characters that must be escaped inside JSON strings.
local ESCAPE = {
    ['"']  = '\\"',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t',
}

local function escape_string(s)
    -- Escape control characters and the two mandatory characters.
    return (gsub(s, '[%c"\\]', function(c)
        return ESCAPE[c] or format('\\u%04x', byte(c))
    end))
end

-- Detect whether a table should be serialised as an array.
-- A table is an array iff its only keys are 1 .. #t (no gaps, no other keys).
local function is_array(t)
    local max = 0
    local count = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k ~= floor(k) or k < 1 then
            return false
        end
        if k > max then max = k end
        count = count + 1
    end
    return max == count  -- no gaps
end

local function encode_value(val, indent, level, seen)
    local vt = type(val)

    if val == nil or vt == "nil" then
        return "null"

    elseif vt == "boolean" then
        return val and "true" or "false"

    elseif vt == "number" then
        if val ~= val then          -- NaN
            error("cannot encode NaN as JSON")
        elseif val == huge or val == -huge then
            error("cannot encode Infinity as JSON")
        end
        -- Emit integers without a decimal point for clean output.
        if val == floor(val) and val >= -1e15 and val <= 1e15 then
            return format("%.0f", val)
        end
        -- 14 significant digits gives accurate round-trip for doubles while
        -- keeping output human-readable (avoids trailing noise like 3.1400...01).
        return format("%.14g", val)

    elseif vt == "string" then
        return '"' .. escape_string(val) .. '"'

    elseif vt == "table" then
        if seen[val] then
            error("cannot encode circular table reference")
        end
        seen[val] = true

        local result
        if is_array(val) then
            local items = {}
            if indent then
                local inner = indent:rep(level + 1)
                local outer = indent:rep(level)
                for i = 1, #val do
                    items[i] = inner .. encode_value(val[i], indent, level + 1, seen)
                end
                if #items == 0 then
                    result = "[]"
                else
                    result = "[\n" .. concat(items, ",\n") .. "\n" .. outer .. "]"
                end
            else
                for i = 1, #val do
                    items[i] = encode_value(val[i], indent, level + 1, seen)
                end
                result = "[" .. concat(items, ",") .. "]"
            end
        else
            local items = {}
            if indent then
                local inner = indent:rep(level + 1)
                local outer = indent:rep(level)
                for k, v in pairs(val) do
                    if type(k) ~= "string" then
                        error("JSON object keys must be strings, got " .. type(k))
                    end
                    insert(items, inner .. '"' .. escape_string(k) .. '": '
                                .. encode_value(v, indent, level + 1, seen))
                end
                table.sort(items)   -- deterministic key order
                if #items == 0 then
                    result = "{}"
                else
                    result = "{\n" .. concat(items, ",\n") .. "\n" .. outer .. "}"
                end
            else
                for k, v in pairs(val) do
                    if type(k) ~= "string" then
                        error("JSON object keys must be strings, got " .. type(k))
                    end
                    insert(items, '"' .. escape_string(k) .. '":' ..
                                  encode_value(v, indent, level + 1, seen))
                end
                result = "{" .. concat(items, ",") .. "}"
            end
        end

        seen[val] = nil
        return result

    else
        error("cannot encode value of type '" .. vt .. "'")
    end
end

--- Encode a Lua value as a compact JSON string.
-- @param value  any encodable Lua value
-- @return       JSON string
function M.encode(value)
    return encode_value(value, nil, 0, {})
end

--- Encode a Lua value as a pretty-printed (indented) JSON string.
-- @param value   any encodable Lua value
-- @param indent  indent string (default: two spaces)
-- @return        JSON string
function M.encode_pretty(value, indent)
    indent = indent or "  "
    return encode_value(value, indent, 0, {})
end

-- ── Decode ────────────────────────────────────────────────────────────────────

local function decode_error(str, pos, msg)
    local line = 1
    for i = 1, pos - 1 do
        if sub(str, i, i) == "\n" then line = line + 1 end
    end
    error(format("JSON decode error at line %d, position %d: %s", line, pos, msg))
end

-- Skip whitespace; return next non-ws position.
local function skip_ws(str, pos)
    while pos <= #str do
        local c = sub(str, pos, pos)
        if c == " " or c == "\t" or c == "\n" or c == "\r" then
            pos = pos + 1
        else
            break
        end
    end
    return pos
end

-- Forward declarations for mutual recursion.
local decode_value

-- Decode a JSON string starting at pos (which should point at the opening '"').
local function decode_string(str, pos)
    -- pos points at the opening '"'
    pos = pos + 1   -- skip '"'
    local parts = {}
    while true do
        local i, j = find(str, '["\\]', pos)
        if not i then
            decode_error(str, pos, "unterminated string")
        end
        if i > pos then
            insert(parts, sub(str, pos, i - 1))
        end
        local c = sub(str, i, i)
        if c == '"' then
            return concat(parts), i + 1
        end
        -- backslash escape
        local e = sub(str, i + 1, i + 1)
        if e == '"'  then insert(parts, '"');  pos = i + 2
        elseif e == '\\' then insert(parts, '\\'); pos = i + 2
        elseif e == '/'  then insert(parts, '/');  pos = i + 2
        elseif e == 'b'  then insert(parts, '\b'); pos = i + 2
        elseif e == 'f'  then insert(parts, '\f'); pos = i + 2
        elseif e == 'n'  then insert(parts, '\n'); pos = i + 2
        elseif e == 'r'  then insert(parts, '\r'); pos = i + 2
        elseif e == 't'  then insert(parts, '\t'); pos = i + 2
        elseif e == 'u'  then
            local hex = sub(str, i + 2, i + 5)
            if not match(hex, '^%x%x%x%x$') then
                decode_error(str, i, "invalid \\u escape: " .. hex)
            end
            local cp = tonumber(hex, 16)
            -- Encode code-point as UTF-8.
            if cp < 0x80 then
                insert(parts, char(cp))
            elseif cp < 0x800 then
                insert(parts, char(0xC0 + floor(cp / 64),
                                   0x80 + cp % 64))
            else
                insert(parts, char(0xE0 + floor(cp / 4096),
                                   0x80 + floor(cp / 64) % 64,
                                   0x80 + cp % 64))
            end
            pos = i + 6
        else
            decode_error(str, i, "invalid escape '\\" .. e .. "'")
        end
    end
end

local function decode_array(str, pos)
    pos = pos + 1   -- skip '['
    local arr = {}
    local n = 0
    pos = skip_ws(str, pos)
    if sub(str, pos, pos) == ']' then
        return arr, pos + 1
    end
    while true do
        local val
        val, pos = decode_value(str, pos)
        n = n + 1
        arr[n] = val
        pos = skip_ws(str, pos)
        local c = sub(str, pos, pos)
        if c == ']' then return arr, pos + 1 end
        if c ~= ',' then decode_error(str, pos, "expected ',' or ']'") end
        pos = skip_ws(str, pos + 1)
    end
end

local function decode_object(str, pos)
    pos = pos + 1   -- skip '{'
    local obj = {}
    pos = skip_ws(str, pos)
    if sub(str, pos, pos) == '}' then
        return obj, pos + 1
    end
    while true do
        pos = skip_ws(str, pos)
        if sub(str, pos, pos) ~= '"' then
            decode_error(str, pos, "expected string key")
        end
        local key
        key, pos = decode_string(str, pos)
        pos = skip_ws(str, pos)
        if sub(str, pos, pos) ~= ':' then
            decode_error(str, pos, "expected ':' after key")
        end
        pos = skip_ws(str, pos + 1)
        local val
        val, pos = decode_value(str, pos)
        obj[key] = val
        pos = skip_ws(str, pos)
        local c = sub(str, pos, pos)
        if c == '}' then return obj, pos + 1 end
        if c ~= ',' then decode_error(str, pos, "expected ',' or '}'") end
        pos = pos + 1
    end
end

local function decode_number(str, pos)
    local s, e = find(str, '^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
    if not s then
        decode_error(str, pos, "invalid number")
    end
    local n = tonumber(sub(str, s, e))
    if not n then decode_error(str, pos, "invalid number") end
    return n, e + 1
end

decode_value = function(str, pos)
    pos = skip_ws(str, pos)
    if pos > #str then
        decode_error(str, pos, "unexpected end of input")
    end
    local c = sub(str, pos, pos)

    if c == '"' then
        return decode_string(str, pos)
    elseif c == '[' then
        return decode_array(str, pos)
    elseif c == '{' then
        return decode_object(str, pos)
    elseif c == 't' then
        if sub(str, pos, pos + 3) == 'true' then return true, pos + 4 end
        decode_error(str, pos, "invalid token")
    elseif c == 'f' then
        if sub(str, pos, pos + 4) == 'false' then return false, pos + 5 end
        decode_error(str, pos, "invalid token")
    elseif c == 'n' then
        if sub(str, pos, pos + 3) == 'null' then return nil, pos + 4 end
        decode_error(str, pos, "invalid token")
    elseif c == '-' or (c >= '0' and c <= '9') then
        return decode_number(str, pos)
    else
        decode_error(str, pos, "unexpected character '" .. c .. "'")
    end
end

--- Decode a JSON string into a Lua value.
-- @param str  JSON-encoded string
-- @return     decoded Lua value
function M.decode(str)
    if type(str) ~= "string" then
        error("json.decode: expected string, got " .. type(str))
    end
    local val, pos = decode_value(str, 1)
    pos = skip_ws(str, pos)
    if pos <= #str then
        decode_error(str, pos, "trailing garbage")
    end
    return val
end

-- ── Convenience ───────────────────────────────────────────────────────────────

--- Attempt to decode; return nil + error message on failure.
-- @param str  JSON-encoded string
-- @return     value, nil  on success
--             nil, errmsg on failure
function M.try_decode(str)
    local ok, val = pcall(M.decode, str)
    if ok then return val, nil end
    return nil, val
end

--- Return true if str is valid JSON.
function M.is_valid(str)
    local ok = pcall(M.decode, str)
    return ok
end

return M
