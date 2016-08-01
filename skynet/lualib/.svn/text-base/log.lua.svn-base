--[[
--file: log.lua
--auth: linwx
--date: 2013/11/26
--desc: 打印Lua日志，支持动态调整日志级别
--change log:
--2014/02/17 优化日志模块
--2016/03/22 为skynet定制
--]]
local lualog = {}

--日志级别：默认打印所有级别的消息
local logLevel = 1

--日志级别枚举：配置文件设置填写
local eLogLevel =
{
    DEBUG = 1,  -- 调试级别
    INFO  = 2,  -- 信息级别
    WARN  = 3,  -- 警告级别
    ERROR = 4,  -- 错误级别
    FATAL = 5,  -- 致命级别
    NONE  = 6,  -- 不输出日志
}

--控制台调试请设置变量__LOG_CONSOLE__MODE__的值为true
if not __LOG_CONSOLE__MODE__ then
    local skynet = require "skynet"
    local sLogLevel = skynet.getenv("logLevel") or "DEBUG"
    logLevel = eLogLevel[sLogLevel] or 1
    lualog = require "skynet.core"
end

local t = require("table")
local m = require("math")
local d = require("debug")
local s = require("string")

local type = type
local print = print
local pairs = pairs
local ipairs = ipairs
local select = select
local tostring = tostring

local log = {}

--内部属性定义
local level = 3 --调试栈层次(不要随便修改)

--内部函数定义
local dump_obj
local log_base
--debug.getinfo的开关函数，考虑到执行效率问题可以关掉
local getinfo = d.getinfo
--local getinfo = nil

local log_fatal = lualog.error or print
local log_error = lualog.error or print
local log_warn  = lualog.error or print
local log_info  = lualog.error or print
local log_debug = lualog.error or print

--------------供外部调用的函数---------------
function log.fatal(...)
    if logLevel <= eLogLevel.FATAL then
        local msg = log_base(...)
        return log_fatal("[F]"..msg .. "\n" .. d.traceback())
    end
end

function log.error(...)
    if logLevel <= eLogLevel.ERROR then
        local msg = log_base(...)
        return log_error("[E]"..msg .. "\n" .. d.traceback())
    end
end

function log.warn(...)
    if logLevel <= eLogLevel.WARN then
        local msg = log_base(...)
        return log_warn("[W]"..msg)
    end
end

function log.info(...)
    if logLevel <= eLogLevel.INFO then
        local msg = log_base(...)
        return log_info("[I]"..msg)
    end
end

function log.debug(...)
    if logLevel <= eLogLevel.DEBUG then
        local msg = log_base(...)
        return log_debug("[D]"..msg)
    end
end

--打印table，供调试用
function log.table(t)
    if type(t) == "table" then
        return log.debug(tostring(t) .. "\n" .. dump_obj(t, "base"))
    end 
    return log.debug("object is not a table, the type is " .. type(t) .. " value is " .. tostring(t))
end

-------------------内部使用的函数----------------------
--[[
    dump_obj(obj [, key ][, sp ][, lv ][, st])
    obj: object to dump
    key: a string identifying the name of the obj, optional.
    sp: space string used for indention, optional(default:'  ').
    lv: for internal use, leave it alone! levels of nested dump.
    st: for internal use, leave it alone! map of saved-table.
 
    it returns a string, which is simply formed just by calling
    'tostring' with any value or sub values of object obj, exc-
    -ept table!.
--]]
function dump_obj(obj, key, sp, lv, st)
    sp = sp or '  '
 
    if type(obj) ~= 'table' then
        return sp..(key or '')..' = '..tostring(obj)..'\n'
    end
 
    local ks, vs, s= { mxl = 0 }, {}
    lv, st =  lv or 1, st or {}
 
    st[obj] = key or '.' -- map it!
    key = key or ''
    for k, v in pairs(obj) do
        if type(v)=='table' then
            if st[v] then -- a dumped table?
                t.insert(vs,'['.. st[v]..']')
                s = sp:rep(lv)..tostring(k)
                t.insert(ks, s)
                ks.mxl = m.max(#s, ks.mxl)
            else
                st[v] =key..'.'..k -- map it!
                t.insert(vs,
                    dump_obj(v, st[v], sp, lv+1, st)
                )
                s = sp:rep(lv)..tostring(k)
                t.insert(ks, s)
                ks.mxl = m.max(#s, ks.mxl)
            end
        else
            if type(v)=='string' then
                t.insert(vs,
                    (('%q'):format(v)
                        :gsub('\\\10','\\n')
                        :gsub('\\r\\n', '\\n')
                    )
                )
            else
                t.insert(vs, tostring(v))
            end
            s = sp:rep(lv)..tostring(k)
            t.insert(ks, s)
            ks.mxl = m.max(#s, ks.mxl);
        end
    end
 
    s = ks.mxl
    for i, v in ipairs(ks) do
        vs[i] = v..(' '):rep(s-#v)..' = '..vs[i]..'\n'
    end
 
    return '{\n'..t.concat(vs)..sp:rep(lv-1)..'}'
end

function log_base(...)
    local info = getinfo and getinfo(level, "Sl")
    local file = info and info.short_src or "unknown"
    local line = info and info.currentline or 0
    local t = {...}
    for i = 1, select('#', ...) do
        t[i] = tostring(select(i, ...))
    end
    return string.format("[%s:%d] %s", file, line, table.concat(t, "\t"))
end

return log
