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

--获取玩家真实信息
function Handler.getRealInfo(playerId)
    local doc = playerDb.playerset:findOne({_id = playerId})
    if not doc then 
        return {rtCode = 1, rtMsg = '不存在此角色'} 
    end

    local accountId = doc.base.accountId
    if not accountId then 
        return {rtCode = 2, rtMsg = '角色帐号ID丢失'} 
    end

    local doc = playerDb.account:findOne({_id = accountId})
    if not doc then 
        return {rtCode = 3, rtMsg = '不存在此角色对应的帐号'} 
    end

    return {rtCode = 0, sex = doc.sex, age = doc.age, city = doc.city, signature = doc.signature}
end

--获取奖励物品
function Handler.get_rewards(rewardId)
    local doc = playerDb.rewards_info:findOne({_id = rewardId})
    if not doc then 
        --没有该奖励
        return {result = 2} 
    end

    if doc.flag == 1 then 
        --该奖励已领取
        return {result = 1} 
    end 

    --成功
    --doc.flag = 1
    --playerDb.rewards_info:save(doc)
    --no save
    playerDb.rewards_info:update({_id = rewardId}, {flag = 1})
    local playerId = doc.role_id
    local count = playerDb.rewards_info.count({role_id = playerId, flag = 0})
    return {result = 0, remain_rewards = count, items = doc.items}
end

return Handler
