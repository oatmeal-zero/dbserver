local log = require "log"
local skynet = require "skynet"

skynet.start(function()
	log.info("login Server start")
    local port = tonumber(skynet.getenv("listenPort"))
    local maxClient = tonumber(skynet.getenv("maxConnections"))
    assert(port > 1000 and port < 65535)
	--skynet.uniqueservice("pbloaderd")
    skynet.newservice("debug_console",8000)
    skynet.newservice("mongodb")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = port,
		maxclient = maxClient,
		nodelay = true,
	})
	log.info("Watchdog listen on ", port)
	skynet.exit()
end)
