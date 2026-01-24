----------------------------------------------------------------------
-- sys - a package that provides simple system (unix) tools
-- Adapted for Node9 from torch/sys
----------------------------------------------------------------------

local sys = {}

--------------------------------------------------------------------------------
-- tic/toc (matlab-like) timers
--------------------------------------------------------------------------------
local __t__
function sys.tic()
   __t__ = os.clock()
end

function sys.toc(verbose)
   local __dt__ = os.clock() - __t__
   if verbose then print(__dt__) end
   return __dt__
end

--------------------------------------------------------------------------------
-- high precision clock (using FFI)
--------------------------------------------------------------------------------
local ffi = require 'ffi'

-- Define clock_gettime for high precision timing
ffi.cdef[[
   typedef long time_t;
   typedef struct timespec {
      time_t tv_sec;
      long   tv_nsec;
   } timespec;
   
   int clock_gettime(int clk_id, struct timespec *tp);
]]

-- CLOCK_MONOTONIC value varies by platform
-- Linux: 1, macOS: 6, FreeBSD: 4, Windows: not available
local CLOCK_MONOTONIC
if ffi.os == "OSX" then
   CLOCK_MONOTONIC = 6
elseif ffi.os:find("BSD") then
   CLOCK_MONOTONIC = 4
else
   CLOCK_MONOTONIC = 1  -- Linux and most other systems
end

function sys.clock()
   local ts = ffi.new("struct timespec")
   ffi.C.clock_gettime(CLOCK_MONOTONIC, ts)
   return tonumber(ts.tv_sec) + tonumber(ts.tv_nsec) / 1e9
end

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
--------------------------------------------------------------------------------
local function execute(cmd)
   local cmd = cmd .. ' 2>&1'
   local f = io.popen(cmd)
   local s = f:read('*all')
   f:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   return s
end
sys.execute = execute

--------------------------------------------------------------------------------
-- execute an OS command, but retrieves the result in a string
-- side effect: file in /tmp
-- this call is typically more robust than the one above (on some systems)
--------------------------------------------------------------------------------
function sys.fexecute(cmd, readwhat)
   readwhat = readwhat or '*all'
   local tmpfile = os.tmpname()
   local cmd = cmd .. ' >'.. tmpfile..' 2>&1'
   os.execute(cmd)
   local file = assert(io.open(tmpfile))
   local s = file:read(readwhat)
   file:close()
   s = s:gsub('^%s*',''):gsub('%s*$','')
   os.remove(tmpfile)
   return s
end

--------------------------------------------------------------------------------
-- returns the name of the OS in use
--------------------------------------------------------------------------------
function sys.uname()
   local os = ffi.os
   if os:find('Linux') then
      return 'linux'
   elseif os:find('OSX') then
      return 'macos'
   elseif os:find('BSD') then
      return 'bsd'
   elseif os:find('Windows') then
      return 'windows'
   else
      return 'unknown'
   end
end
sys.OS = sys.uname()

--------------------------------------------------------------------------------
-- ls (list dir) - only on Unix systems
--------------------------------------------------------------------------------
if sys.OS ~= 'windows' then
   sys.ls  = function(d) d = d or '.' return execute('ls '    ..d) end
   sys.ll  = function(d) d = d or '.' return execute('ls -l ' ..d) end
   sys.la  = function(d) d = d or '.' return execute('ls -a ' ..d) end
   sys.lla = function(d) d = d or '.' return execute('ls -la '..d) end
end

--------------------------------------------------------------------------------
-- always returns the path of the file running
--------------------------------------------------------------------------------
function sys.fpath()
   local fpath = debug.getinfo(2).source:gsub('@','')
   local sep = package.config:sub(1,1) -- get path separator
   
   -- Make absolute if relative
   if not fpath:match('^'..sep) and not fpath:match('^%a:') then
      fpath = sys.execute('pwd') .. sep .. fpath
   end
   
   -- Split into directory and basename
   local dir, file = fpath:match('(.+)'..sep..'([^'..sep..']+)$')
   if not dir then
      dir, file = '.', fpath
   end
   
   return dir, file
end

--------------------------------------------------------------------------------
-- split string based on pattern pat
--------------------------------------------------------------------------------
function sys.split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, last_end)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e + 1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--------------------------------------------------------------------------------
-- check if a number is NaN
--------------------------------------------------------------------------------
function sys.isNaN(number)
   -- We rely on the property that NaN is the only value that doesn't equal itself.
   return (number ~= number)
end

--------------------------------------------------------------------------------
-- sleep
--------------------------------------------------------------------------------
ffi.cdef[[
   unsigned int sleep(unsigned int seconds);
   int usleep(unsigned int usec);
]]

function sys.sleep(seconds)
   ffi.C.sleep(math.floor(seconds))
   if seconds % 1 > 0 then
      ffi.C.usleep((seconds % 1) * 1000000)
   end
end

function sys.usleep(usec)
   ffi.C.usleep(usec)
end

--------------------------------------------------------------------------------
-- colors, can be used to print things in color
--------------------------------------------------------------------------------
sys.COLORS = {
   none = '\27[0m',
   black = '\27[0;30m',
   red = '\27[0;31m',
   green = '\27[0;32m',
   yellow = '\27[0;33m',
   blue = '\27[0;34m',
   magenta = '\27[0;35m',
   cyan = '\27[0;36m',
   white = '\27[0;37m',
   Black = '\27[1;30m',
   Red = '\27[1;31m',
   Green = '\27[1;32m',
   Yellow = '\27[1;33m',
   Blue = '\27[1;34m',
   Magenta = '\27[1;35m',
   Cyan = '\27[1;36m',
   White = '\27[1;37m',
   _black = '\27[40m',
   _red = '\27[41m',
   _green = '\27[42m',
   _yellow = '\27[43m',
   _blue = '\27[44m',
   _magenta = '\27[45m',
   _cyan = '\27[46m',
   _white = '\27[47m'
}

return sys
