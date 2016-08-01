local log = require "log"
local mongo = require "mongo"
local skynet = require "skynet"
require "skynet.manager"    -- import skynet.register
local handler = require "handler"

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        local f = handler[cmd]
            if f then
            skynet.ret(skynet.pack(f(...)))
        else
            error(string.format("Unknown command %s", tostring(cmd)))
        end
    end)
    local dbHost = skynet.getenv("dbHost")
    local dbPort = tonumber(skynet.getenv("dbPort"))
	local mongoClient = mongo.client({host = dbHost, port = dbPort})
    local playerDb = mongoClient.player
    handler.init(playerDb)
    skynet.register "MONGODB"
end)
