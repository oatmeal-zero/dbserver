local log = require "log"
local playerDb 
Handler = {
}

function Handler.init(pdb)
    playerDb = pdb
end

function Handler.verify(user, passwd)
    log.info("function verify be called.", user, passwd)
	local account = playerDb.account:findOne({name = user})
    if account and account.pw == passwd then
        return account
    else
        return { ok = 1, msg = "account or password error.", }
    end
end

return Handler
