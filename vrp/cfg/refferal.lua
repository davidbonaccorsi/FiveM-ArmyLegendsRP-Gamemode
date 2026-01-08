return {
    referalRewards = {
        [1] = {
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 5.000$ pentru ca ai adus un prieten pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 5000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 5000}
                    }})
                end
            end,
        },
        [2] = {
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 10.000$ pentru ca ai adus 2 prietenii pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 10000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 10000}
                    }})
                end
            end,
        },
        [3] ={
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 15.000$ pentru ca ai adus 3 prietenii pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 15000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 15000}
                    }})
                end
            end,
        },
        [4] = {
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 25.000$ pentru ca ai adus 4 prietenii pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 25000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 25000}
                    }})
                end
            end,
        },
        [6] = {
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 40.000$ pentru ca ai adus 6 prietenii pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 40000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 40000}
                    }})
                end
            end,
        },
        [10] = {
            name  = 'Prime Status',
            img = 'https://cdn.armylegends.ro/elements/prime.webp',
            text = 'Recompensa ta pentru ca ai adus 10 prietenii pe server. Prime Status pentru 30 de zile.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                local expireTime = os.time() + daysToSeconds(30)
                local vipLvl = 1
                local grade = {
                    expireTime = expireTime,
                    vip = tonumber(vipLvl),
                }
    
                if player then
                    if (vRP.usersData[user_id] and vRP.usersData[user_id]['userVip']) then
                        return vRPclient.notify(player, {'Nu ti-am putut oferi Prime Account-ul deoarece detii deja unul!', 'error'})
                    end
    
                    vRP.setUserVip(user_id, tonumber(vipLvl))
                    if tonumber(vipLvl) > 1 then
                        TriggerClientEvent("afk-kick:setPrime", player, 3600)
                    end
    
                    vRP.updateUser(user_id, 'userVip', grade)
                    vRP.giveBankMoney(user_id, 25000, "VIP Bonus")
                    exports["vrp_phone"]:sendMessage(user_id, {
                        message = [[
                            Salutare, ]]..GetPlayerName(player)..[[!
                            <br>Tocmai ai achizitionat gradul ]]..'Prime Account'..[[.<br>
                            Data expirarii: ]]..os.date("%d/%m/%Y", expireTime)..[[<br>
                            Ai primit bonus +$]]..vRP.formatMoney(25000)..[[ in contul bancar.
                            <br><br>Iti multumim pentru sustinere.<br>
                            - ArmyLegends Romania
                        ]],
                        sender = "0101-0101",
                        type = "message"
                    })
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$set"] = {["userVip"] = grade}
                    }})
    
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 25000}
                    }})
                end
            end,
        },
        [15] = {
            name  = 'Castiga Bani',
            img = 'https://cdn.armylegends.ro/elements/money.webp',
            text = 'Recompensa ta de 200.000$ pentru ca ai adus 15 prietenii pe server.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveMoney(user_id, 200000, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.wallet"] = 200000}
                    }})
                end
            end,
        },
        [20] = {
            name  = 'Lamborghini Huracan',
            img = 'https://cdn.armylegends.ro/vehicles/18performante.webp',
            text = 'Recompensa ta pentru ca ai adus 20 de prietenii pe server. Un Lamborghini Huracan.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                local model = '18performante'
    
                local carPlate = "LS 69RMP"
                local function searchOne()
                    carPlate = vRP.generatePlateNumber()
                
                    getIdentifierByPlateNumber(carPlate, function(onePlate)
                        if not onePlate or onePlate ~= 0 then
                            searchOne()
                        end
                    end)
                end
                searchOne()
                
                local newVehicle = {
                    user_id = user_id,
                    vehicle = model,
                    vtype = 'ds',
                    name = 'Lamborghini Huracan',
                    carPlate = carPlate,
                    state = 1,
                    premium = true
                }
                exports.vrp:count({collection = 'userVehicles', query = {user_id = user_id, vehicle = model }, options = {}, function(count)
                    if count > 0 then
                        if player then
                            vRPclient.notify(player, {'Trebuia sa primesti un Lamborghini Huracan, dar ai deja unul!', 'error'})
                        end
                    else
                        exports.vrp:insertOne({collection = "userVehicles", document = newVehicle})
                        if player then
                            vRP.addCacheVehicle(user_id, newVehicle)
                        end
                    end
                end})
            end,
        },
        [25] = {
            name  = 'Legend Coins',
            img = 'https://cdn.armylegends.ro/shop/rpc.png',
            text = 'Recompensa ta pentru ca ai adus 25 de prietenii pe server. 15 Legend Coins.',
            rewardPlayer = function(user_id)
                local player = vRP.getUserSource(user_id)
                if player then
                    vRP.giveCoins(user_id, 15, false, "Refferal Reward")
                else
                    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                        ["$inc"] = {["userMoney.coins"] = 15}
                    }})
                end
            end,
        },
    }
}