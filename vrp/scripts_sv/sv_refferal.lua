local cfg = module('cfg/refferal')

function vRP.openRefferal(player)
    vRP.prompt(player, "REFERAL CODE", "Introdu in caseta de mai jos <span style='color: var(--prompt-yellow);'>referal code-ul</span> prietenului care te-a adus pe server apoi apasa pe butonul de CONFIRMARE. Daca nu ai un referal code, poti lasa caseta libera", false, function(referal)
        if referal ~= nil and referal ~= "" and tonumber(referal) then
            referal = tonumber(referal)

            if referal > 0 then
                local target_src = vRP.getUserSource(referal)
                local user_id = vRP.getUserId(player)

                if (referal == user_id) then
                    return vRP.openRefferal(player)
                end

                if target_src then
                    vRP.usersData[referal].referalInvites = (vRP.usersData[referal].referalInvites or 0) + 1
                    local invites = vRP.usersData[referal].referalInvites
                    
                    if cfg.referalRewards[invites] then
                        cfg.referalRewards[invites].rewardPlayer(referal)
                    end

                    vRP.giveMoney(user_id, 5000, "Refferal Reward")
                    exports.mongodb:updateOne({collection = 'users', query = {id = referal}, update = {['$set'] = {referalInvites = invites}}})
                else
                    exports.mongodb:findOne({collection = "users", query = {id = referal}, options = { projection = {_id = 0, referalInvites = 1, id = 1} }}, function(success, rows)
                        if rows[1] and rows[1].id then
                            local referalInvites = tonumber(rows[1].referalInvites) or 0
                            referalInvites += 1

                            if cfg.referalRewards[referalInvites] then
                                cfg.referalRewards[referalInvites].rewardPlayer(referal)
                            end

                            exports.mongodb:updateOne({collection = 'users', query = {id =  referal}, update = {['$set'] = {referalInvites = referalInvites}}})
                            vRP.giveMoney(user_id, 25000, "Refferal Reward")
                        end
                    end)
                end
            end
        end  
    end)
end

registerCallback('openRefferal', function(player)
    local user_id = vRP.getUserId(player)

    return  {
        invitesData = cfg.referalRewards,
        lastHours = vRP.getUserLastHours(user_id),
        referalInvites = vRP.usersData[user_id].referalInvites or 0,
        refferalCode = user_id,
    }
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, data)
    if not first_spawn then
        return
    end

    if data.lastHours and data.lastHours >= 80 then
        if not data.hoursReward then
            vRP.updateUser(user_id, "hoursReward", true)
            vRP.giveMoney(user_id, 100000, "Reward Ore Jucate")
        end
    end
end)