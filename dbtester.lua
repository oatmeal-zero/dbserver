package.cpath = "script/3rd/skynet/luaclib/?.so"
package.path = "script/3rd/skynet/lualib/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

__LOG_CONSOLE__MODE__ = true
local cmsgpack = require "cmsgpack"
local socket = require "clientsocket"
local log = require "log"

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
    return cmsgpack.unpack(string.unpack("<s4", text, 4))
end

local function recv_package()
	local r = socket.recv(fd)
	if not r then
		return nil
	end
    return unpack_package(r)
end

local session = 0

local function send_request(...)
	session = session + 1
	local str = cmsgpack.pack(...)
	send_package(fd, str)
	log.debug("Request:", session)
end

local last = ""

local function dispatch_package()
	while true do
		local v
		v = recv_package()
		if not v then
			break
        else
            log.info("recv", v)
            log.table(v)
		end
	end
end

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			break
		else
            if #cmd > 0 then
                send_request("verify", cmd, "9bf5c0c1a7a95da6f8010d5e321e3e7b")
            end
		end
	else
		socket.usleep(100)
	end
end
