
local Tunnel = module("vrp", "lib/Tunnel")

local vRP = exports.vrp:link()
local vRPclient = Tunnel.getInterface("vRP", "vRP_phone")

local vRPphone = {}
Tunnel.bindInterface("vRP_phone", vRPphone)

local phoneNumbers = {}
local phoneOwners = {}
local phoneIdentities = {}
local phoneAds = {}
local ibanHolders = {}
local inCallPlayers = {}

local webhook = "https://discord.com/api/webhooks/1245816564976979988/K-0dvlOcemwBjw8e8WvCGknI5TxWHtWgL37IGtTzH844d7HzqPkY5pI7r6DOG9L904kf"
function vRPphone.getWebhook()
    return webhook
end


function vRPphone.hasPhone()
    local player = source
    local user_id = vRP.getUserId(player)

    return vRP.getInventoryItemAmount(user_id, "phone") >= 1
end

local shareFeed = {}
local playerShareLikes = {}

local lastCalls = {}
local phoneMessages = {}

local function initPlayer(user_id, player)
    vRP.getUserIdentity(user_id, function(identity)

        if identity.phone == 0 or identity.phone == "0" then
            Citizen.Wait(5000)
            return initPlayer(user_id, player)
        end

        phoneNumbers[user_id] = identity.phone
        phoneOwners[identity.phone] = user_id
        ibanHolders[identity.iban] = user_id
        phoneIdentities[user_id] = {firstname = identity.firstname, name = identity.name, iban = identity.iban}

        if inCallPlayers[user_id] then
            inCallPlayers[user_id] = nil
        end

        local phoneData = {
            number = phoneNumbers[user_id],
            identity = phoneIdentities[user_id],
            ads = phoneAds,
            shareFeed = shareFeed,
            shareLiked = playerShareLikes[user_id] or {},
            lastCalls = lastCalls[user_id] or {}
        }

        local ready = 0

        ready = ready + 1
        phoneData.contacts = {}
        exports.mongodb:find({collection = "phone_contacts", query = {user_id = user_id}}, function(success, result)
            local theContacts = {}
            for k, v in pairs(result) do
                theContacts[v.number] = {name = v.name, status = phoneOwners[v.number]}
            end

            phoneData.contacts = theContacts
            ready = ready - 1
        end)

        ready = ready + 1
        phoneData.messagesFront = {}
        exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {_id = 0, messagesFront = 1}}}, function(success, res)
            local messagesFront = res[1].messagesFront or {}

            for i, number in pairs(messagesFront) do
                ready = ready + 1
                exports.mongodb:findOne({collection = "phone_messages", query = {involved = {
                    ["$all"] = {number, identity.phone}
                }},
                    options = {
                        sort = {
                            _id = -1
                        },
                        projection = {
                            _id = 0, involved = 1, messages = 1
                        }
                    }
                }, function(success, result)
                    
                    if result[1] then
                        
                        local messages = result[1].messages
                        local lastObj = messages[#messages]

                        local theMsg = lastObj.msg

                        local otherPhone = false

                        for _, number in pairs(result[1].involved) do
                            if number ~= identity.phone then
                                otherPhone = number
                                break
                            end
                        end

                        if otherPhone then
                            if lastObj.type == "location" then
                                theMsg = "Shared location"
                            end

                            phoneData.messagesFront[i] = {
                                number = otherPhone,
                                msg = theMsg,
                                time = lastObj.time,
                            }
                        end

                    else
                        phoneData.messagesFront[i] = nil
                    end

                    ready = ready - 1
                end)
            end
            ready = ready - 1
        end)

        local i = 0
        while ready > 0 or i < 50 do
            Citizen.Wait(50)
            i = i + 1
        end

        Citizen.Wait(1500)
        TriggerClientEvent("vrp-phone:loadPhone", player, phoneData)

        Citizen.Wait(2000)
        TriggerClientEvent("vrp-phone:updateContactStatus", -1, identity.phone, true)

    end)
end
local resName = GetCurrentResourceName()
function registerCallback(cbName, cb)
    RegisterServerEvent(resName..":s_callback:"..cbName, function(...)
        local player = source
        if cb and player then
            local result = table.pack(cb(player, ...))
            TriggerClientEvent(resName..":c_callback:"..cbName, player, table.unpack(result))
        end
    end)
end

local handcuffed = false
registerCallback("vl:isPlayerHandcuffed", function(player)
    vRPclient.isHandcuffed(player, {}, function(isHandcuffed)
        handcuffed = isHandcuffed
    end)

    print(handcuffed)
    return handcuffed
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)

    if first_spawn then
        initPlayer(user_id, player)
    end

    if dbdata and dbdata.clearPhone then
        vRP.updateUser(user_id, "clearPhone", false, 1)
        TriggerClientEvent("vrp-phone:clearCache", player)
    end

end)

AddEventHandler("vRP:updateIdentity", function(user_id, identity)
    phoneIdentities[user_id] = {firstname = identity.firstname, name = identity.name, iban = identity.iban}
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, spawned)
    if spawned then
        local phone = phoneNumbers[user_id]

        if phoneOwners[phone] then
            phoneOwners[phone] = nil
        end

        TriggerClientEvent("vrp-phone:updateContactStatus", -1, phone, false)
    end
end)

AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        local users = vRP.getUsers()
        for uid, src in pairs(users) do
            initPlayer(uid, src)
        end

        exports.mongodb:find({collection = "phone_messages", query = {}}, function(success, result)
            
            for _, data in pairs(result) do
                phoneMessages[data.id] = data.messages
            end

        end)
    end
end)

AddEventHandler("onDatabaseConnect", function(db)    
    exports.mongodb:find({collection = "phone_messages", query = {}}, function(success, result)
            
        for _, data in pairs(result) do
            phoneMessages[data.id] = data.messages
        end

    end)
end)

exports("getPhoneNumber", function(user_id)
    return phoneNumbers[user_id] or false
end)

exports("getUserByIban", function(iban)
    return ibanHolders[iban] or false
end)


AddEventHandler("vrp-phone:newAd", function(theAd)
    table.insert(phoneAds, theAd)

    TriggerClientEvent("vrp-phone:newAd", -1, theAd)
end)

function vRPphone.getMarketStockOrders()
    local orderList = exports["vrp"]:getMarketStockOrders()
    
    if orderList then
        return orderList
    end
    return {}
end

function vRPphone.getVignetteModels()
    local player = source
    local user_id = vRP.getUserId(player)
    
    local vehicles, total, out = exports["vrp"]:getUserVehiclesByGarage(user_id, "Personal")
    local models = {}
    for k, v in pairs(vehicles) do
        models[k] = v.name
    end
    return models
end

function vRPphone.getActiveAuction()
    local auction = exports["vrp"]:getActiveAuction()
    if auction then
        return auction
    end
    return false
end

function vRPphone.donateToCharity(amount)
    local player = source
    local user_id = vRP.getUserId(player)
    
    return vRP.tryBankPayment(user_id, amount, false, "Charity")
end

function vRPphone.transferToIban(amount, iban)
    local player = source
    local user_id = vRP.getUserId(player)
    
    local holder = ibanHolders[iban]

    if holder then
        local holder_src = vRP.getUserSource(holder)

        if holder_src then

            if vRP.tryBankPayment(user_id, amount, false, "Bank Transfer (iban: "..iban..")") then
                vRP.giveBankMoney(holder, amount, "Bank Transfer (from: "..user_id..")")

                TriggerClientEvent("vrp-phone:notify", holder_src, "Ti-au fost transferati $"..vRP.formatMoney(amount))
                
                return "Ai transferat $"..vRP.formatMoney(amount)
            
            else
                return "Nu ai destui bani pentru a transfera."
            end
        else
            return "Destinatarul nu a fost gasit."
        end
    else
        return "Destinatarul nu a fost gasit."
    end
end

function vRPphone.getBankMoney()
    local player = source
    local user_id = vRP.getUserId(player)
    local money = vRP.getBankMoney(user_id)

    return math.floor(money)
end

RegisterServerEvent("vrp-phone:shareImage", function(shareTbl)
    local player = source
    local user_id = vRP.getUserId(player)
    local identity = phoneIdentities[user_id]

    local newShare = {
        name = {firstname = identity.firstname, secondname = identity.name},
        image = shareTbl[2],
        description = shareTbl[1],
        likes = 0,
    }

    table.insert(shareFeed, newShare)

    TriggerClientEvent("vrp-phone:notify", player, "Imaginea a fost distribuita!")

    TriggerClientEvent("vrp-phone:refreshShareFeed", -1, "newShare", newShare)

end)

RegisterServerEvent("vrp-phone:likeShare", function(key)
    local player = source
    local user_id = vRP.getUserId(player)

    if shareFeed[key] then
        if not playerShareLikes[user_id] then
            playerShareLikes = {}
        end

        playerShareLikes[key] = true
        shareFeed[key].likes += 1

        TriggerClientEvent("vrp-phone:refreshShareFeed", -1, "like", key)
    end
end)

RegisterServerEvent("vrp-phone:unlikeShare", function(key)
    local player = source
    local user_id = vRP.getUserId(player)

    if shareFeed[key] then
        if not playerShareLikes[user_id] then
            playerShareLikes = {}
        end

        playerShareLikes[key] = false
        shareFeed[key].likes -= 1

        TriggerClientEvent("vrp-phone:refreshShareFeed", -1, "unlike", key)
    end
end)

function vRPphone.suggestContact()
    local player = source
    local user_id = vRP.getUserId(player)
    local identity = phoneIdentities[user_id]

    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
        if nplayer then
            local name = identity.firstname.." "..identity.name
        
            TriggerClientEvent("vrp-phone:getSuggested", nplayer, phoneNumbers[user_id], name)
            TriggerClientEvent("vrp-phone:notify", nplayer, "Ai o sugestie de contact noua!")
            TriggerClientEvent("vrp-phone:notify", player, "Ai sugerat un contact nou!")
        
        else
            TriggerClientEvent("vrp-phone:notify", player, "Nici o persoana in jurul tau!")
        end
    end)

end

RegisterServerEvent("vrp-phone:addContact", function(contactData)
    local player = source
    local user_id = vRP.getUserId(player)

    exports.mongodb:insertOne({collection = "phone_contacts", document = {
        user_id = user_id,
        name = contactData[1],
        number = contactData[2]
    }})
end)

RegisterServerEvent("vrp-phone:editContact", function(lastNumber, newNumber, newName)
    local player = source
    local user_id = vRP.getUserId(player)

    exports.mongodb:updateOne({collection = "phone_contacts", query = {user_id = user_id, number = lastNumber}, update = {
        ["$set"] = {
            number = newNumber,
            name = newName,
        }
    }})
end)

RegisterServerEvent("vrp-phone:deleteContact", function(number)
    local player = source
    local user_id = vRP.getUserId(player)

    exports.mongodb:deleteOne({collection = "phone_contacts", query = {user_id = user_id, number = number}})
end)

function vRPphone.getCallState(number)
    local player = source
    local user_id = vRP.getUserId(player)

    local result = {
        available = phoneOwners[number]
    }

    if result.available then
        result.available = not inCallPlayers[phoneOwners[number]]
    end

    return result
end

RegisterServerEvent("vrp-phone:callNumber", function(number)
    local player = source
    local user_id = vRP.getUserId(player)
    local myNumber = phoneNumbers[user_id]
    local target_id = phoneOwners[number]

    if target_id then
        local target_src = vRP.getUserSource(target_id)

        if target_src then
            inCallPlayers[user_id] = number
            inCallPlayers[target_id] = myNumber

            TriggerClientEvent("vrp-phone:getCalled", target_src, myNumber)
            
            if not lastCalls[user_id] then
                lastCalls[user_id] = {}
            end
            
            if not lastCalls[target_id] then
                lastCalls[target_id] = {}
            end

            table.insert(lastCalls[user_id], number)
            table.insert(lastCalls[target_id], myNumber)

            TriggerClientEvent("vrp-phone:addLastCall", player, number)
            TriggerClientEvent("vrp-phone:addLastCall", target_src, myNumber)

            return true
        end
    end

    TriggerClientEvent("vrp-phone:cancelCall", player)
end)

RegisterServerEvent("vrp-phone:acceptCall", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if inCallPlayers[user_id] then
        local target_id = phoneOwners[inCallPlayers[user_id]]
        
        if target_id then
            local target_src = vRP.getUserSource(target_id)

            if target_src then
                TriggerClientEvent("vrp-phone:setCallAsAnswered", target_src)
                TriggerClientEvent("vrp-phone:setCallAsAnswered", player)
            end
        end
    end
end)

RegisterServerEvent("vrp-phone:endCall", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if inCallPlayers[user_id] then
        local target_id = phoneOwners[inCallPlayers[user_id]]
        
        if target_id then
            local target_src = vRP.getUserSource(target_id)

            if target_src then
                TriggerClientEvent("vrp-phone:cancelCall", target_src)
            end

            inCallPlayers[target_id] = nil
        end

        inCallPlayers[user_id] = nil
        TriggerClientEvent("vrp-phone:cancelCall", player)

    end
end)

exports("sendMessage", function(user_id, msgData)
    -- msgData: {message: ..., sender: ..., type: ...}

    if phoneNumbers[user_id] then
    
        local senderAddition = msgData.sender:gsub("-", "")
        local targetAddition = phoneNumbers[user_id]:gsub("-", "")
        local chat = tonumber(senderAddition) + tonumber(targetAddition)

        local newMsg = {
            msg = msgData.message,
            sender = msgData.sender,
            time = os.time(),
            type = msgData.type
        }

        if newMsg.type == "location" then
            newMsg.coords = {msgData.coords[1], msgData.coords[2]}
        end
    
        if not phoneMessages[chat] then
            phoneMessages[chat] = {}
        end
        
        table.insert(phoneMessages[chat], newMsg)
        
        exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
            ['$pull'] = {
                messagesFront = msgData.sender
            }
        }}, function(success)
            exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                ['$push'] = {
                    messagesFront = {
                        ['$each'] = {msgData.sender},
                        ['$position'] = 0
                    }
                }
            }})
        end)
    
        local player = vRP.getUserSource(user_id)
        TriggerClientEvent("vrp-phone:refreshFrontMessages", player, {
            msg = msgData.message,
            sender = msgData.sender,
            time = os.time(),
            type = msgData.type
        })

    end

end)

RegisterServerEvent("vrp-phone:sendMessage", function(msgData)
    local player = msgData.source or source
    local user_id = vRP.getUserId(player)
    local myNumber = phoneNumbers[user_id]
    local targetNumber = msgData[1]

    if myNumber then
        local senderAddition = myNumber:gsub("-", "")
        local targetAddition = targetNumber:gsub("-", "")
        local chat = tonumber(senderAddition) + tonumber(targetAddition)

        local newMsg = {
            msg = msgData[2],
            sender = myNumber,
            time = os.time(),
            type = msgData[3]
        }

        if newMsg.type == "location" then
            newMsg.coords = {msgData[4][1], msgData[4][2]}
        end
    
        if phoneMessages[chat] then
            table.insert(phoneMessages[chat], newMsg)
            exports.mongodb:updateOne({collection = "phone_messages", query = {id = chat}, update = {
                ["$push"] = {messages = newMsg}
            }})

        else
            exports.mongodb:insertOne({collection = "phone_messages", document = {
                id = chat,
                involved = {myNumber, targetNumber},
                messages = {newMsg}
            }})

            phoneMessages[chat] = {newMsg}
        end

        exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
            ['$pull'] = {
                messagesFront = targetNumber
            }
        }}, function(success)
            exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                ['$push'] = {
                    messagesFront = {
                        ['$each'] = {targetNumber},
                        ['$position'] = 0
                    }
                }
            }})
        end)
        
        exports.mongodb:updateOne({collection = "users", query = {['userIdentity.phone'] = targetNumber}, update = {
            ['$pull'] = {
                messagesFront = myNumber
            }
        }}, function(success)
            exports.mongodb:updateOne({collection = "users", query = {['userIdentity.phone'] = targetNumber}, update = {
                ['$push'] = {
                    messagesFront = {
                        ['$each'] = {myNumber},
                        ['$position'] = 0
                    }
                }
            }})
        end)
    
        local target_id = phoneOwners[targetNumber]
        if target_id then
            
            local target_src = vRP.getUserSource(target_id)
            TriggerClientEvent("vrp-phone:refreshFrontMessages", target_src, {
                msg = msgData[2],
                sender = myNumber,
                time = os.time(),
                type = msgData[3]
            })

        end

        Citizen.Wait(500)
        TriggerClientEvent("vrp-phone:refreshFrontMessages", player, {
            msg = msgData[2],
            sender = targetNumber,
            time = os.time(),
            type = msgData[3],
            skipRefresh = true
        })

    end
end)

function vRPphone.hasAnyMsgWithContact(number)
    local player = source
    local user_id = vRP.getUserId(player)
    local myNumber = tostring(phoneNumbers[user_id])

    number = tostring(number)

    if myNumber then
        local senderAddition = myNumber:gsub("-", "")
        local targetAddition = number:gsub("-", "")
        local chat = tonumber(senderAddition) + tonumber(targetAddition)

        if phoneMessages[chat] then
            return true
        end
    end

    return false
end

function vRPphone.getConversationMessages(number)
    local player = source
    local user_id = vRP.getUserId(player)
    local myNumber = tostring(phoneNumbers[user_id])
    
    number = tostring(number)

    if myNumber then
        local senderAddition = myNumber:gsub("-", "")
        local targetAddition = number:gsub("-", "")
        local chat = tonumber(senderAddition) + tonumber(targetAddition)
        
        if phoneMessages[chat] then
            return phoneMessages[chat]
        end

        local result, ready = {}, false
        exports.mongodb:findOne({collection = "phone_messages", 
            query = {id = chat}, options = {
                sort = {
                    _id = -1
                },
                projection = {
                    _id = 0, involved = 1, messages = 1
                },
                limit = 15,
            }
        }, function(success, res)
            for _, data in pairs(res[1].messages or {}) do
                local msg = {msg = data.msg, time = data.time, sender = data.sender, type = data.type}

                if msg.type == "location" then
                    msg.coords = data.coords
                end

                table.insert(result, msg)
            end
            ready = true
        end)

        local i = 0
        while not ready do
            Citizen.Wait(50)
            i = i + 1
            if i >= 50 then break end
        end

        return result

    end

    return {}
end