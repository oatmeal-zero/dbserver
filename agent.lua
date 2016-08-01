local log = require "log"
local skynet = require "skynet"
local cmsgpack = require "cmsgpack"
local netpack = require "netpack"
local socket = require "socket"

local WATCHDOG
local host
local send_request
local handler

local CMD = {}
local client_fd

local function request(name, ...)
    return cmsgpack.pack(skynet.call("MONGODB", "lua", name, ...))
end

local function send_package(pack)
    local package = "SYS"..string.pack("<s4", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return cmsgpack.unpack(skynet.tostring(msg, sz))
	end,
	dispatch = function (_,_, ...)
        local ok, result  = pcall(request, ...)
        if ok then
            if result then
                send_package(result)
            end
        else
            skynet.error(result)
        end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
