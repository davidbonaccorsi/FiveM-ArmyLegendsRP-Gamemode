local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

-- vRP = Proxy.getInterface("vRP")
vRP = exports['vrp']:link()
vRPclient = Tunnel.getInterface("vRP", "chat")

RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

local mutedPlayers, closedBeta = {}, false

RegisterServerEvent('chat:kickSpammer')
AddEventHandler('chat:kickSpammer', function()
    DropPlayer(source, 'ArmyLegends: Ai facut prea mult spam si ai primit kick!')
end)

RegisterCommand("resetvw", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 2 then

        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                SetPlayerRoutingBucket(target_src, 0)
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai resetat lui ^1" .. GetPlayerName(target_src) .." ^7virtual-world-ul"})
                vRPclient.sendInfo(target_src, {"^1" .. GetPlayerName(player) .. " ^7ti-a resetat virtual-world-ul"})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/resetvw <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("setvw", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 2 then
        local target_id = tonumber(args[1])
        local vw = tonumber(args[2])
        if target_id and vw then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                SetPlayerRoutingBucket(target_src, vw)
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai setat lui ^1" .. GetPlayerName(target_src) .." ^7virtual-world in ^1" .. vw})
                vRPclient.sendInfo(target_src,{"^1" .. GetPlayerName(player) .. " ^7ti-a setat virtual-world-ul in ^1" .. vw})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/setvw <user_id> <world>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("freeze", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 1 then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.setFreeze(target_src, {true, true})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat freeze lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat freeze."})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/freeze <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("unfreeze", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 1 then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.setFreeze(target_src, {false, true})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat unfreeze lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat unfreeze."})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/unfreeze <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("freezearea", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) < 2 then
        return vRPclient.noAccess(player)
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.sendSyntax(player, {"/freezearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then

        vRPclient.getNearestPlayers(player, {radius}, function(users)
            local msg = "^5ArmyLegends: ^1" .. GetPlayerName(player) .. " ^7ti-a dat freeze"
            local amm = 0

            for src, dst in pairs(users) do
                amm = amm + 1

                vRPclient.setFreeze(src, {true, true})
                vRPclient.sendInfo(src, {msg})
            end

            vRPclient.sendInfo(player, {"^2Succes: ^7Ai dat freeze la ^1" .. amm .. "^7 jucatori"})
        end)

    else
        vRPclient.sendError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("unfreezearea", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) < 2 then
        return vRPclient.noAccess(player)
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.sendSyntax(player, {"/unfreezearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then
        vRPclient.getNearestPlayers(player, {radius}, function(users)
            local msg = "^5ArmyLegends: ^7^1" .. GetPlayerName(player) .. " ^7ti-a dat unfreeze."
            local amm = 0
            for src, dst in pairs(users) do
                amm = amm + 1

                vRPclient.setFreeze(src, {false, true})
                vRPclient.sendInfo(src, {msg})
            end
            vRPclient.sendInfo(player, {"^2Succes: ^7Ai dat unfreeze la ^1" .. amm .. "^7 jucatori."})
        end)
    else
        vRPclient.sendError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("papabun", function(player, args)
    local user_id = vRP.getUserId(player)

    if vRP.getUserAdminLevel(user_id) > 3 then
        vRP.setHunger(user_id, 100)
        vRP.setThirst(user_id, 100)
    end
end)

RegisterCommand("drop", function(player, args)
    if player == 0 then
        local src = tonumber(args[1])
        if src then
            local kickmsg = "[Kick]"
            for i = 2, #args do
                kickmsg = kickmsg .. " " .. args[i]
            end

            DropPlayer(src, kickmsg)
        else
            print("/drop <src>")
        end
    else

        local user_id = vRP.getUserId(player)
        if vRP.getUserAdminLevel(user_id) >= 3 then
            if args[1] and args[2] then

                local src = tonumber(args[1])
                local kickmsg = ""
                for i = 2, #args do
                    kickmsg = kickmsg .. " " .. args[i]
                end

                DropPlayer(src, kickmsg)

                vRP.sendStaffMessage("^1Drop^7: "..GetPlayerName(player).."[" .. user_id .. "] i-a dat kick lui " .. GetPlayerName(src) .. ". reason: " ..kickmsg, 9)
            else
                vRPclient.sendSyntax(player, {"/drop <src> <kick-msg>"})
            end
        else
            vRPclient.noAccess(player)
        end
    end
end)

RegisterCommand("eject", function(player)
    vRPclient.getNearestPlayer(player, {10}, function(nplayer)
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
            vRPclient.isHandcuffed(nplayer, {true}, function(handcuffed) -- check handcuffed
                if handcuffed then
                    vRPclient.ejectVehicle(nplayer)
                else
                    vRPclient.sendError(player, {"Utilizatorul selectat treuie sa fie incatusat."})
                end
            end)
        else
            vRPclient.sendError(player, {"Nu este nici un jucator langa tine."})
        end
    end)
end)

RegisterCommand("aa2", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 1 then
        SetEntityCoords(GetPlayerPed(player), -774.65155029297, 335.42440795898, 159.00144958496)
    end
end, false)

RegisterCommand("clearinv", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 4 then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRP.clearInventory(target_id)
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai sters inventarul lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a sters inventar-ul."})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/clearinv <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)


RegisterCommand("clearweapons", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 2 then
        local target_id = tonumber(args[1])
        if not target_id then
            return vRPclient.sendSyntax(player, {"/clearweapons <user_id>"})
        end

        local target_src = vRP.getUserSource(target_id)
        if not target_src then
            return vRPclient.sendOffline(player)
        end
        
        vRP.removeItemByCategory(user_id, 'weapons')
        vRPclient.sendInfo(player, {"^2Succes: ^7I-ai sters armele lui ^1" .. GetPlayerName(target_src)})
        vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a sters armele."})
    else
        vRPclient.noAcces(player)
    end
end)

RegisterCommand("uncuff", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 1 then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.setHandcuff(target_src, {false})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat uncuff lui^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat uncuff"})
            else
                vRPclient.sendOffline(player)
            end
        else
            vRPclient.sendSyntax(player, {"/uncuff <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("unban", function(src, args)
    local target_id = tonumber(args[1])
    if src == 0 then
        if not target_id then return print("^5Sintaxa: ^7/unban <id>") end
        
        vRP.isUserBanned(target_id, function(banned, _)
            if not banned then return print("^1Failed: ^7Jucatorul nu este banat.") end

            vRP.setBanned(target_id, false)
            print("^2Success: ^7Jucatorul a fost debanat.")
        end)
        return
    end

    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) < 4 then return vRPclient.noAccess(src) end

    if not target_id then
        return vRPclient.sendSyntax(src, {"/unban <user_id>"})
    end

    exports.mongodb:findOne({collection = "users", query = {id = target_id}, options = {
        projection = {_id = 0, username = 1}
    }}, function(success, result)
        if (#result > 0) and result[1].username then
            vRP.isUserBanned(target_id, function(banned, banDocument)
                if banned then
                    vRP.request(src, ("Esti sigur ca vrei sa-l debanezi pe %s?<br><br>Motiv ban: <span style='color: #a1c9ff'>%s</span>"):format(result[1].username, banDocument.banReason), false, function(_, ok)
                        if ok then
                            vRP.setBanned(target_id, false)
                            vRPclient.sendInfo(-1, {"^5"..GetPlayerName(src).."^7 i-a dat unban lui id ^5"..target_id})
                        end
                    end)
                else
                    vRPclient.sendError(src, {"Jucatorul nu este banat."})
                end
            end)
        end
    end)
end)

local webhookRMONEY = "https://discord.com/api/webhooks/1250124569596002304/pNsKFESH82O77CmSTzGGoMD-Ri-aDF9KUZhld4j128rZQ2iciVojSj7Y66OjS9_XtUdU"
RegisterCommand("rmoney", function(player, args)
    local acc = (player == 0)
    if not acc then
        acc = (vRP.getUserAdminLevel(vRP.getUserId(player)) >= 5)
    end
    if acc then
        if args[1] then
            local user_id = tonumber(args[1])
            if user_id then
                local src = vRP.getUserSource(user_id)
                if src then
                    vRP.setMoney(user_id, 0)
                    vRP.setBankMoney(user_id, 0)
                    if player == 0 then
                        print("Toti banii au fost confiscati de la " .. user_id .. " (online)")
                    else
                        TriggerClientEvent("__cfx_internal:serverPrint", player,"Toti banii au fost confiscati de la " .. user_id .. " (online)")
                    end
                else
                    exports.mongodb:updateOne({
                        collection = "users",
                        query = {
                            id = user_id
                        },
                        update = {
                            ['$set'] = {
                                ['userMoney.wallet'] = 0,
                                ['userMoney.bank'] = 0
                            }
                        }
                    })
                    if player == 0 then
                        print("Toti banii au fost confiscati de la " .. user_id .. " (offline)")
                    else
                        TriggerClientEvent("__cfx_internal:serverPrint", player, "Toti banii au fost confiscati de la " .. user_id .. " (offline)")
                    end

                    PerformHttpRequest(webhookRMONEY,
                    function(err, text, headers)
                    end, 'POST', json.encode({
                        embeds = {{
                            description = (GetPlayerName(player) or 'Consola').." Ia confiscat bani lui "..user_id,
                            color = 0xB3FFAE,
                            author = {
                                name = "RMONEY",
                            },
                            footer = {
                                text = os.date("%d/%m/%y %H:%M")
                            }
                        }}

                        }), {
                            ['Content-Type'] = 'application/json'
                    })
                    vRP.createLog(vRP.getUserId(player), {target = user_id, author = (GetPlayerName(player) or 'Consola')}, "RMONEY")
                end
            end
        else
            print("rmoney <user_id>")
        end
    end
end)

RegisterCommand("facetitickete", function(player)
    if (player == 0) or vRP.getUserAdminLevel(vRP.getUserId(player)) >= 4 then
        vRP.doStaffFunction(1, function(src)
            vRPclient.sendInfo(src,{"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})
            vRPclient.sendInfo(src,{"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})
            vRPclient.sendInfo(src,{"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})

            TriggerClientEvent("sound:play", src, "alarmstaff")
        end)
    else
        vRPclient.noAccess(player)
    end
end)

local disLogs = {}
local lastDisc = {}
RegisterCommand("dislogs", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 1 then
        if disLogs[player] then
            disLogs[player] = nil
            vRPclient.sendInfo(player, {"^1Succes: ^7Logurile au fost dezactivate."})
        else
            disLogs[player] = true
            vRPclient.sendInfo(player, {"^2Succes: ^7Logurile au fost activate."})
        end
    else
        vRPclient.noAccess(player)
    end
end, false)

RegisterCommand("disarea", function(player, args)
    local pedCds = GetEntityCoords(GetPlayerPed(player))
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 1 then
	    local radius = tonumber(args[1])
	    if radius and radius > 0 and radius <= 1000 then

            local totalLeft = 0
            local msg = "^7-------- Ultimele deconectari ^7 --------"

            for indx, data in pairs(lastDisc) do
                if data.expire >= os.time() then

                    local dist = #(data.pos - pedCds)
                    if dist <= radius then
                        local years, months, days, hours, minutes, seconds = passedTime(data.time, os.time())

                        msg = msg .. "\n^1" .. data.name .. " ["..data.user_id.."]:^7 "..math.floor(dist).." metri - "..os.date("%H:%M", data.time).." ^1(acum "..minutes.." minute, "..seconds.." secunde)^7"
                        totalLeft += 1
                    end
                else
                    lastDisc[indx] = nil
                end
            end

            msg = msg .. "\n\n^uPe o raza de "..radius.." de metri sunt in total: "..totalLeft.." (de) deconectari\n^7------------------------------------"
            vRPclient.msg(player, {msg})

	    else
		    vRPclient.sendSyntax(player, {"/disarea <raza (1-1000)>"})
	    end
	else
	  vRPclient.noAccess(player)
	end
end)

RegisterServerEvent("chat:sendLogs")
AddEventHandler("chat:sendLogs", function(logmsg)
    if not string.find(logmsg, "Type: 13") then
        for v, state in pairs(disLogs) do
            TriggerClientEvent('chatMessage', v, logmsg)
        end
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, spawned, reason)
    if reason and not string.find(reason:lower(), "restart") and spawned then
        local pos = GetEntityCoords(GetPlayerPed(player))
        if user_id then
            
            local alive = ""
            if GetEntityHealth(GetPlayerPed(player)) < 105+1 then
                alive = "- 🪦"
            end

            table.insert(lastDisc, {user_id = user_id, name = GetPlayerName(player), pos = pos, time = os.time(), expire = os.time() + 1800})
            TriggerEvent("chat:sendLogs", "["..os.date("%d/%m/%Y %H:%M").."] "..GetPlayerName(player).." ["..user_id.."] - ^1"..reason)
            PerformHttpRequest("https://discord.com/api/webhooks/1245816414506451057/WyRyRz4hgzgcYGDDoyz9JFStJl4gv_k6ZfEIKbPM_lovqKoD4XO1cj224qOhmUGYH2mK",function(err, text, headers)
                end, 'POST', json.encode({
                    embeds = {{
                        description = reason,
                        color = 0xFF6464,
                        author = {
                            name = (GetPlayerName(player) or 'Unknown') .. " [" .. user_id .. "]",
                            icon_url = "https://cdn.armylegends.ro/connLogs/iesirelog.png"
                        },
                        footer = {
                            text = os.date("%d/%m/%y %H:%M").." ("..pos.x..", "..pos.y..", "..pos.z..") "..alive
                        }
                    }}

                }), {
                    ['Content-Type'] = 'application/json'
                })
        end
        disLogs[player] = nil
    end
end)

local forReply = {}
RegisterCommand("cancelpm", function(player, args)
    local user_id = vRP.getUserId(player)

    if user_id then
        for target_id, replyId in pairs(forReply) do
            if replyId == user_id then
                replyId = nil
                forReply[target_id] = nil
            end
        end

        vRPclient.sendInfo(player, {"Ai oprit toate PM-urile active."})
    end
end)

RegisterCommand("pm", function(player, args)
    local user_id = vRP.getUserId(player)

    if vRP.getUserAdminLevel(user_id) < 1 then
        return vRPclient.noAccess(player)
    end

    local target_id = tonumber(args[1])
    if not target_id or not args[2] then
        return vRPclient.sendSyntax(player, {"/pm <id> <mesaj>"})
    end

    if target_id == user_id then
        return vRPclient.sendError(player, {"Trebuie sa dai PM altui jucator, nu poti vorbii cu tine"})
    end

    local target_src = vRP.getUserSource(target_id)
    if not target_src then
        return vRPclient.sendOffline(player)
    end

    local msg = table.concat(args, " ", 2)

    if msg ~= " " and msg ~= "" then
        TriggerClientEvent("chatMessage", player, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("chatMessage", target_src, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("sound:play", target_src, "pmSound", 1.0)

        if not forReply[target_id] or forReply[target_id] ~= user_id then
            forReply[target_id] = user_id

            TriggerClientEvent('chatMessage', target_src, "^zPM-Reply: ^7Pentru a raspunde la PM foloseste comanda ^z/r <mesaj>")
        end
    end
end)

RegisterCommand("r", function(player, args)
    local user_id = vRP.getUserId(player)
    local target_id = forReply[user_id]

    if not target_id then
        return vRPclient.sendError(player, {"Nici un membru staff nu ti-a dat mesaj."})
    end

    local target_src = vRP.getUserSource(target_id)
    if not target_src then
        return vRPclient.sendOffline(player)
    end

    if not args[1] then
        return vRPclient.sendSyntax(player, {"/r <mesaj>"})
    end

    local msg = table.concat(args, " ", 1)

    forReply[target_id] = user_id

    if msg ~= "" and msg ~= " " then
        TriggerClientEvent("chatMessage", player, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("chatMessage", target_src, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("sound:play", target_src, "pmSound", 1.0)
    end
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, dbdata)
    if first_spawn then

        if dbdata.chatMute then
            mutedPlayers[user_id] = dbdata.chatMute
        end

        PerformHttpRequest("https://discord.com/api/webhooks/1245816174718222429/fj8mHpRKkESDwO_R_HvMFDTDeHh10LfinbsQi1z4CVVgTxA2gKMIvaMoP62_2K6HbiAd",
            function(err, text, headers)
            end, 'POST', json.encode({
                embeds = {{
                    description = "Connected to the server.",
                    color = 0xB3FFAE,
                    author = {
                        name = (GetPlayerName(player) or 'Unknown') .. " [" .. user_id .. "]",
                        icon_url = "https://cdn.armylegends.ro/connLogs/intrarelog.png"
                    },
                    footer = {
                        text = os.date("%d/%m/%y %H:%M")
                    }
                }}

            }), {
                ['Content-Type'] = 'application/json'
            })

        if not vRP.isUserVip(user_id) then
            local author = GetPlayerName(player)
            local prevName = author
    
            author = sanitizeString(author, "^", false)
            if author ~= prevName then
                for i = 1, 10 do
                    Citizen.Wait(500)
                    TriggerClientEvent("chatMessage", player, "ArmyLegends: Doar membrii cu Prime au voie sa detina culori in nume. Scoate litera \"^\" din nume.")
                end
                Citizen.Wait(1000)
                DropPlayer(player, "ArmyLegends: Doar membrii cu Prime au voie sa detina culori in nume. Scoate litera \"^\" din nume.")
            end
        end
    end
end)

RegisterCommand("fonline", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 4 then
        local userFaction = vRP.getUserFaction(user_id)
        if args[1] then
            userFaction = table.concat(args, " ", 1)
        end

        local fType = vRP.getFactionType(userFaction)

        if fType == "Gang" or fType == "Mafie" or userFaction == "Smurd" or userFaction == "Politie" then
            local msg = "^7---- Membrii Online: ^5" .. userFaction .. "^7 ----"

            local users = vRP.getUsersByFaction(userFaction)
            local online = 0

            for k, v in pairs(users) do
                local src = vRP.getUserSource(v.id)
                if src then
                    msg = msg .. "\n" .. v.username .. " [" .. v.id .. "]"
                    online = online + 1
                end
            end
            msg = msg .. "\nTotal membrii conectati in factiune: "..online.." (de) jucatori\n^7-------------------"
            vRPclient.msg(player, {msg})
        else
            vRPclient.sendError(player, {"Factiunea selectata este una invalida."})
        end
    else
        vRPclient.noAccess(player)
    end
end)

local adminsOnly = false
RegisterCommand("chatoff", function(player)
    local user_id = vRP.getUserId(player)
    if user_id then
        if vRP.getUserAdminLevel(user_id) >= 4 then
            vRPclient.msg(-1, {"^1Chat^7: " .. GetPlayerName(player) .. " a oprit chat-ul global!"})
            adminsOnly = true
        else
            vRPclient.noAccess(player)
        end
    end
end)

RegisterCommand("chaton", function(player)
    local user_id = vRP.getUserId(player)
    if user_id then
        if vRP.getUserAdminLevel(user_id) >= 4 then
            vRPclient.msg(-1, {"^1Chat^7: " .. GetPlayerName(player) .. " a pornit chat-ul global!"})
            adminsOnly = false
        else
            vRPclient.noAccess(player)
        end
    end
end)

local lastMessage = {}
AddEventHandler('_chat:messageEntered', function(author, message)
    local user_id = vRP.getUserId(source)
    
    if user_id then
        if message and author then

            local adminLvl = vRP.getUserAdminLevel(user_id)
            
            if (adminLvl > 0) or (lastMessage[user_id] or 0) < os.time() then
                local colorData = {
                    color = "",
                    prefix = "Jucator",
                }
    
                if adminLvl == 1 then
                    colorData.color = "808080"
                    colorData.prefix = "Trial Helper"
                elseif adminLvl == 2 then
                    colorData.color = "b700ff"
                    colorData.prefix = "Helper"
                elseif adminLvl == 3 then
                    colorData.color = "0027ff"
                    colorData.prefix = "Moderator"
                elseif adminLvl == 4 then
                    colorData.color = "008000"
                    colorData.prefix = "Administrator"
                elseif adminLvl == 5 then
                    colorData.color = "ffff00"
                    colorData.prefix = "Supervizor"
                elseif adminLvl == 6 then
                    colorData.color = "ffa500"
                    colorData.prefix = "Manager"
                elseif adminLvl == 7 then
                    colorData.color = "c25050"
                    colorData.prefix = "Fondator"
                elseif vRP.getUserVipRank(user_id) == 1 then
                    colorData.color = "fddc2a"
                    colorData.prefix = "[Prime]"
                elseif vRP.getUserVipRank(user_id) == 2 then
                    colorData.color = "499cab"
                    colorData.prefix = "[Prime Platinum]"
                elseif vRP.hasGroup({user_id, "sponsors"}) then
                    colorData.color = "d8d820"
                    colorData.prefix = vRP.getSponsorTag(source) or "Sponsor"
                end
        
                if not WasEventCanceled() then
                    if message:len() > 300 then
                        return vRPclient.sendError(source, {"Mesajul tau depaseste limita de 300 de caractere!"})
                    end
        
                    if adminsOnly and adminLvl < 3 then
                        return vRPclient.sendError(source, {"Chat: ^7 Chat-ul este oprit momentan de catre un admin."})
                    end
        
                    if (mutedPlayers[user_id] or 0) < os.time() then
                        local theColor = "#{"..colorData.color.."}"

                        local allPrefix = ""
                        if theColor:len() > 3 then
                            allPrefix = theColor..colorData.prefix
                        end

                        TriggerClientEvent('chatMessage', -1, "#{ffffff99}["..os.date("%H:%M").."] "..allPrefix.." #{fff}" .. author .. "("..user_id .."): #{ffffff99}"..message)
                        print("["..os.date("%H:%M").."] ^7["..user_id..'] '..author..': ' .. message .. '^7')
                        lastMessage[user_id] = os.time() + 5
                    else
                        local totalsec = mutedPlayers[user_id] - os.time()
                        vRPclient.sendError(source, {"Ai mute inca ^1" .. totalsec .. "^7 (de) secunde!"})
                    end
                end
            else
                vRPclient.sendError(source, {"Asteapta inca ^1"..(lastMessage[user_id] - os.time()).." (de) secunde^7 inainte de a scrie un mesaj pe chat!"})
            end
        end
    else
        DropPlayer(source, "Conexiunea cu serverul a fost intrerupta.")
    end
end)

RegisterCommand("say", function(src, args)
    if src == 0 then
        if not args[1] then return print("^5Sintaxa: ^7/say <mesaj>") end
        TriggerClientEvent("chatMessage", -1, "^e(Consola): ^7"..table.concat(args, " "))
    else
        local user_id = vRP.getUserId(src)
        local allowed = (user_id >= 1 and user_id < 4)
        
        if not allowed then
            return vRPclient.noAccess(src)
        end

        if not args[1] then
            return vRPclient.sendSyntax(src, {"/say <mesaj>"})
        end

        TriggerClientEvent("chatMessage", -1, "^3(Say) "..(GetPlayerName(src) or "Necunoscut").. " ["..user_id.."]: ^7"..table.concat(args, " "))
    end
end)

RegisterCommand("clear", function(src)
    if src == 0 then
        return TriggerClientEvent("chat:clear", -1)
    end
    
    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) >= 3 then
        TriggerClientEvent("chat:clear", -1)
        TriggerClientEvent("chatMessage", -1, {"Clear", "Chatul a fost curatat pentru toti jucatorii.", "Admin: "..GetPlayerName(src).."("..user_id..")"}, "info")
    else
        vRPclient.noAccess(src)
    end
end)

RegisterCommand("tpto", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) < 1 then return vRPclient.noAccess(src) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.sendSyntax(src, {"/tpto <id>"}) end
    local target_src = vRP.getUserSource(target_id)
    if not target_src then return vRPclient.sendOffline(src) end

    vRPclient.getPosition(target_src, {}, function(tX, tY, tZ)
        vRPclient.teleport(src, {tX, tY, tZ})
        vRPclient.notify(src, {"Te-ai teleportat la "..GetPlayerName(target_src), "success"})
    end)
    
    if not args[2] then
        vRPclient.notify(target_src, {"Adminul "..GetPlayerName(src).." s-a teleportat la tine"})
    end
end)

RegisterCommand("taketk", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) < 4 then return vRPclient.noAccess(player) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.sendSyntax(player, {"/taketk <id>"}) end
    local target_src = vRP.getUserSource(target_id)
    if not target_src then return vRPclient.sendOffline(player) end
    vRPclient.executeCommand(target_src, {"tk"})
    vRPclient.sendInfo(player, {"L-ai trimis pe "..GetPlayerName(target_src).." la tickete"})
end)

RegisterCommand("tptome", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) < 1 then return vRPclient.noAccess(src) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.sendSyntax(src, {"/tptome <id>"}) end
    local target_src = vRP.getUserSource(target_id)
    if not target_src then return vRPclient.sendOffline(src) end

    vRPclient.getPosition(src, {}, function(pX, pY, pZ)
        vRPclient.teleport(target_src, {pX, pY, pZ})
        vRPclient.notify(target_src, {"Adminul "..GetPlayerName(src).." te-a teleportat la el", "warning"})
        vRPclient.notify(source, {"L-ai teleportat la tine pe jucatorul "..GetPlayerName(target_src).." ("..target_id..")", "success"})
    end)
end)

RegisterCommand("tptow", function(src)
    local user_id = vRP.getUserId(src)
    if closedBeta or vRP.getUserAdminLevel(user_id) >= 1 then
        vRPclient.gotoWaypoint(src)
    else
        vRPclient.noAccess(src)
    end
end)

RegisterCommand("revive", function(player, args)

    local granted = false
    if player == 0 then
        granted = true
    end

    if not granted then
        local user_id = vRP.getUserId(player)
        granted = vRP.getUserAdminLevel(user_id) > 0
    end

    if granted then

        local target_id = tonumber(args[1])
        if target_id then

            local target_src = vRP.getUserSource(target_id)

            if target_src then
                vRPclient.varyHealth(target_src, {100})
                SetTimeout(500, function()
                    vRPclient.varyHealth(target_src, {100})
                end)
                if player ~= 0 then
                    vRP.sendStaffMessage("^5Arevive: ^7".. GetPlayerName(player) .. " -> ".. GetPlayerName(target_src))
                else
                    print("DONE")
                end
            else
                vRPclient.sendOffline(player)
            end

        else
            vRPclient.sendSyntax(player, {"/revive <id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("arevive", function(player, args)
    if not args[1] then return vRPclient.sendSyntax(player, {"/arevive <id>"}) end
    vRPclient.executeCommand(player, {"revive "..table.unpack(args)})
end)

RegisterCommand("respawn", function(player, args)
    local user_id = vRP.getUserId(player)

    if vRP.getUserAdminLevel(user_id) >= 1 then
        local target_id = tonumber(args[1])
        local target_src = vRP.getUserSource(target_id)
        if target_src then
            local possibleSpawns = {
                {-1058.2651367188,-2778.0551757813,21.361682891846},
                {-1027.4068603516,-2808.8942871094,27.192668914795},
                {-1083.7718505859,-2763.5466308594,27.192668914795}
            }

            SetEntityCoords(GetPlayerPed(target_src), table.unpack(possibleSpawns[math.random(1, #possibleSpawns)]))
            vRPclient.varyHealth(target_src, {200})
            SetPlayerRoutingBucket(target_src, 0)
            if args[2] then
                TriggerEvent("vRP:playerSpawn", target_id, target_src, false)
            end
            vRPclient.sendInfo(-1, {"" .. GetPlayerName(player) .. " i-a dat respawn lui " ..GetPlayerName(target_src)})
        else
            vRPclient.sendSyntax(player, {"/respawn <id> <-1 = dead>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("revivearea", function(player, args)
    local user_id = vRP.getUserId(player)

    if vRP.getUserAdminLevel(user_id) < 2 then
        return vRPclient.noAccess(player)
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.sendSyntax(player, {"/revivearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then
        vRPclient.getNearestPlayers(player, {radius}, function(users)
            users[player] = 1

            for nearestSrc, _ in pairs(users) do
                vRPclient.varyHealth(nearestSrc, {100})

                SetTimeout(500, function()
                    vRPclient.varyHealth(nearestSrc, {100})
                end)
            end

            vRPclient.sendInfo(-1, {"Adminul "..GetPlayerName(player).." a dat revive pe o raza de "..radius.." metri"})
        end)
    else
        vRPclient.sendError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("arevivearea", function(player, args)
    if not args[1] then return vRPclient.sendSyntax(player, {"/arevivearea <radius (max 50)>"}) end
    
    vRPclient.executeCommand(player, {"revivearea "..table.unpack(args)})
end)

RegisterCommand("reviveall", function(source)
    local player = source
    if source == 0 then
        vRPclient.varyHealth(-1, {100})
        SetTimeout(500, function()
            vRPclient.varyHealth(-1, {100})
        end)

        vRPclient.sendInfo(-1, {"Server-ul a dat ^5revive^7 la toti jucatorii conectati."})
    end

    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) < 5 then
        return vRPclient.noAccess(player)
    end

    vRPclient.varyHealth(-1, {100})
    SetTimeout(500, function()
        vRPclient.varyHealth(-1, {100})
    end)
    vRPclient.sendInfo(-1, {"Adminul " .. GetPlayerName(player) .. " a dat revive la tot server-ul."})
end)

local webhookSETADMIN = "https://discord.com/api/webhooks/1250124569596002304/pNsKFESH82O77CmSTzGGoMD-Ri-aDF9KUZhld4j128rZQ2iciVojSj7Y66OjS9_XtUdU"
RegisterCommand("setadmin", function(player, args)
    local granted = false
    if player == 0 then
        granted = true
    else
        local user_id = vRP.getUserId(player)
        if vRP.getUserAdminLevel(user_id) > 6 then -- sa fie manager+ ( admin 6 )
            granted = true
        end 
    end

    if not granted then
        return vRPclient.noAccess(player)
    end

    local targetid = tonumber(args[1])
    local adminLvl = tonumber(args[2])

    if targetid and adminLvl then
        local targetSrc = vRP.getUserSource(targetid)

        local name = ""
        if targetSrc then
            print("Done online")
            vRP.setUserAdminLevel(targetid, adminLvl)

            if player ~= 0 then
                name = "de la " .. GetPlayerName(player)
            end

            if adminLvl == 0 then
                vRPclient.notify(targetSrc, {"Ai primit remove din staff.", "error", "Staff"})
            else
                vRPclient.notify(targetSrc, {"Ai primit Admin Level: "..adminLvl, "info", "Staff"})
            end

            PerformHttpRequest(webhookSETADMIN,
            function(err, text, headers)
            end, 'POST', json.encode({
            embeds = {{
                description = GetPlayerName(player).." Ia setat admin level "..adminLvl.." lui "..targetid,
                color = 0xB3FFAE,
                author = {
                    name = "Set Admin",
                },
                footer = {
                    text = os.date("%d/%m/%y %H:%M")
                }
            }}

            }), {
                ['Content-Type'] = 'application/json'
            })
            vRP.createLog(user_id, {target = targetid, author = user_id, adminLevel = adminLvl}, "Set Admin")
        else
            print("Done offline")
            exports.mongodb:updateOne({
                collection = "users",
                query = {
                    id = targetid
                },
                update = {
                    ['$set'] = {
                        adminLvl = adminLvl
                    }
                }
            })
        end
    else
        print("Syntax: /setadmin <user_id> <adminLvl>")
    end
end)

RegisterCommand("getcoins", function(player, args)
    local acc = (player == 0)
    if not acc then
        acc = (vRP.getUserAdminLevel(vRP.getUserId(player)) >= 5)
    end
    if acc then
        if args[1] and tonumber(args[2]) then
            local user_id = tonumber(args[1])
            if user_id then
                local src = vRP.getUserSource(user_id)
                if src then
                    if vRP.tryCoinsPayment(user_id, tonumber(args[2]), "Admin GET") then
                        vRPclient.notify(src, {"Ti-au fost retrase " .. tonumber(args[2]) .." (de) coinuri de la consola"})
                        print("Coinsi au fost retrase (online)")
                    else
                        print("Jucatorul " .. user_id .. " nu are " .. args[2] .. " coinsi")
                    end

                    PerformHttpRequest(webhookSETADMIN,
                    function(err, text, headers)
                    end, 'POST', json.encode({
                    embeds = {{
                        description = GetPlayerName(player).." ia retras "..args[2].." coins lui "..user_id,
                        color = 0xB3FFAE,
                        author = {
                            name = "Get Coins",
                        },
                        footer = {
                            text = os.date("%d/%m/%y %H:%M")
                        }
                    }}

                    }), {
                        ['Content-Type'] = 'application/json'
                    })
                    vRP.createLog(vRP.getUserId(player), {target = user_id, author = vRP.getUserId(player), coinsRetrase = tonumber(args[2])}, "Get Coins")
                else
                    print("Coinsi au fost retrase (offline)")
                    exports.mongodb:updateOne({
                        collection = "users",
                        query = {
                            id = user_id
                        },
                        update = {
                            ['$inc'] = {
                                ['userMoney.coins'] = -tonumber(args[2])
                            }
                        }
                    })
                end
            end
        else
            print("getcoins <user_id> <amount>")
        end
    end
end)

RegisterCommand("givecoins", function(player, args)
    local acc = (player == 0)
    if not acc then
        acc = (vRP.getUserAdminLevel(vRP.getUserId(player)) >= 6)
    end
	if acc then
		if args[1] and tonumber(args[2]) then
			local user_id = tonumber(args[1])
			if user_id then
				local src = vRP.getUserSource(user_id)
	
				local dmdAmm = tonumber(args[2])
	
				if src then
	
					vRPclient.msg(-1, {{"V I P", GetPlayerName(src) .. " si-a achizitionat Legend Coins!", "Store: shop.armylegends.ro"}, "info"})
					print("^7ArmyLegends (online): I-ai oferit lui ID " .. args[1] .. " coinsi: " .. args[2])
	
					vRP.giveCoins(user_id, dmdAmm, false, "Donation")

                    PerformHttpRequest(webhookSETADMIN,
                    function(err, text, headers)
                    end, 'POST', json.encode({
                    embeds = {{
                        description = GetPlayerName(player).." ia dat "..args[2].." coins lui "..user_id,
                        color = 0xB3FFAE,
                        author = {
                            name = "Give Coins",
                        },
                        footer = {
                            text = os.date("%d/%m/%y %H:%M")
                        }
                    }}

                    }), {
                        ['Content-Type'] = 'application/json'
                    })
                    vRP.createLog(vRP.getUserId(player), {target = user_id, author = vRP.getUserId(player), coinsPrimite = tonumber(args[2])}, "Give Coins")
				else
					print("^7ArmyLegends (offline): I-ai oferit lui ID " .. args[1] .. " coinsi: " .. args[2])
					exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
						['$inc'] = {['userMoney.coins'] = dmdAmm}
					}})
				end
	
                exports.mongodb:insertOne({
                    collection = "tebexDonations",
                    document = {
                        coins = dmdAmm,
                        user_id = user_id,
                        transaction = args[3] or "error",
                        status = "succeeded",
                        date = os.date("%d/%m/%y %H:%S"),
                        time = os.time()
                    }
                })
			end
		end
	end
end)

RegisterCommand("givemoney", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local money = parseInt(args[2])

        local player = vRP.getUserSource(target)
        if player then
            vRP.giveMoney(target, money, "Admin")
        else
            exports.mongodb:updateOne({collection = "users", query = {id = target}, update = {
                ["$inc"] = {["userMoney.wallet"] = money}
            }})
        end
    else
        local user_id = vRP.getUserId(player)
        local target_id = parseInt(args[1])
        local amount = parseInt(args[2])

        if vRP.getUserAdminLevel(user_id) >= 6 then
            if target_id then
                local target = vRP.getUserSource(target_id)


                PerformHttpRequest(webhookSETADMIN,
                function(err, text, headers)
                end, 'POST', json.encode({
                embeds = {{
                    description = GetPlayerName(player).." ia dat "..amount.." cash lui "..target_id,
                    color = 0xB3FFAE,
                    author = {
                        name = "Give Money",
                    },
                    footer = {
                        text = os.date("%d/%m/%y %H:%M")
                    }
                }}

                }), {
                    ['Content-Type'] = 'application/json'
                })
                vRP.createLog(user_id, {target = target_id, author = user_id, cashPrimit = amount}, "Give Money")

                if target then
                    vRP.giveMoney(target_id, amount, "Admin")
                    -- vRPclient.notify(player, {"Ai dat " .. amount .. "$ jucatorului cu id-ul " .. target_id.." [ONLINE]", "info"})
                    vRPclient.notify(target, {"Ai primit " .. amount .. "$ de la " .. (GetPlayerName(player) or ("ID "..target_id)), "success"})
                else   
                    exports.mongodb:updateOne({collection = "users", query = {id = target}, update = {
                        ["$inc"] = {["userMoney.wallet"] = amount}
                    }})
                    vRPclient.notify(player, {"Ai dat " .. amount .. "$ jucatorului cu id-ul " .. target_id.." [OFFLINE]", "info"})
                end
            end
        else
            vRPclient.notify(player, {"Nu ai acces la aceasta comanda.", "error"})
        end
    end
end)

RegisterCommand("veh", function(src, args)
    local user_id = vRP.getUserId(src)

    if vRP.getUserAdminLevel(user_id) >= 5 then
        
        local carModel = tostring(args[1])

        if not args[1] then
            return vRPclient.sendSyntax(src, {"/veh <car_model>"})
        end

        local vehicle = CreateVehicle(GetHashKey(carModel), GetEntityCoords(GetPlayerPed(src)), GetEntityHeading(GetPlayerPed(src)), true, false)
        
        SetPedIntoVehicle(GetPlayerPed(src), vehicle, -1)
        SetVehicleNumberPlateText(vehicle, "ADMIN")
        
        SetTimeout(200, function()
            if DoesEntityExist(vehicle) then
                SetEntityRoutingBucket(vehicle, tonumber(GetPlayerRoutingBucket(src)))
                vRPclient.notify(src, {"Ai spawnat un vehicul cu modelul: "..carModel, "success"})
            end
        end)
    else
        vRPclient.noAccess(src)
    end
end)

RegisterCommand("faggio", function(src)
    if source == 0 then return end
    local user_id = vRP.getUserId(src)

    if vRP.getUserAdminLevel(user_id) < 1 then
        return vRPclient.noAccess(src)
    end

    local carModel = "faggio"

    local vehicle = CreateVehicle(GetHashKey(carModel), GetEntityCoords(GetPlayerPed(src)), GetEntityHeading(GetPlayerPed(src)), true, false)
    
    SetPedIntoVehicle(GetPlayerPed(src), vehicle, -1)
    SetVehicleNumberPlateText(vehicle, "ADMIN")

    SetTimeout(200, function()
        if DoesEntityExist(vehicle) then
            SetEntityRoutingBucket(vehicle, tonumber(GetPlayerRoutingBucket(src)))
            vRPclient.notify(src, {"Ai spawnat un Faggio!", "success"})
        end
    end)
end)


RegisterCommand("a", function(src, args)
    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) >= 1 then
    
        if args[1] then
            local theMessage = table.concat(args, " ")
            
            local author = GetPlayerName(src) or "Necunoscut"
			vRP.sendStaffMessage("^5[^9Staff ^7Chat^5]^7 "..author.." (^5"..user_id.."^7): "..theMessage)
        
            print("["..os.date("%d/%m/%Y %H:%M").."] ^7[Staff]["..user_id..'] '..author..': ' .. theMessage .. '^7')

        else
            vRPclient.sendSyntax(src, {"/a <staff_message>"})
        end
    else
        vRPclient.noAccess(src)
    end
end)



RegisterCommand("f", function(player, args, raw)
    local user_id = vRP.getUserId(player)
    if vRP.hasUserFaction(user_id) then
        local userFaction = vRP.getUserFaction(user_id)

        local msg = raw:sub(3)

        if msg:len() >= 1 then

            msg = "^5[" .. userFaction .. "] ^7| " .. GetPlayerName(player) .. "^7: " .. msg

            local users = vRP.getUsersByFaction(userFaction)
            for k, v in pairs(users) do
                local src = vRP.getUserSource(v.id)
                if src then
                    TriggerClientEvent("chatMessage", src, msg)
                end
            end

        else
            vRPclient.sendSyntax(player, {"/f [mesaj]"})
        end

    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand('d', function(source, args)
    local user_id = vRP.getUserId(source)
    local faction = vRP.getUserFaction(user_id)

    print(faction)

    if not (faction == 'Politie' or faction == 'Smurd') then
        return vRPclient.noAccess(source)
    end

    local message = table.concat(args, ' ')
    
    if not (message:len() > 0) then
        return vRPclient.sendSyntax(source, {"/d <mesaj> | Chat Departamente"})
    end

    vRP.doFactionTypeFunction('Lege', function(member)
        TriggerClientEvent('chatMessage', member, '^5[Departamente] ^7| [' ..faction.. '] ' ..GetPlayerName(source).. ': ' ..message)
    end)
end)

RegisterCommand("ch", function(player, args)
    if args[1] and args[2] then
        vRPclient.getPosition(player, {}, function(x, y, z)
            local dd = "nice"

            if args[1] == "1" then
                dd = "nice"
            elseif args[1] == "2" then
                dd = "trevor"
            elseif args[1] == "3" then
                dd = "lester"
            elseif args[1] == "4" then
                dd = "mansion"
            else
                dd = "kinda_nice"
            end

            vRPclient.msg(player, {dd})

            local theMsg = [[
            -- house
            {
            		Entry   = vector4(]] .. x .. [[, ]] .. y .. [[, ]] .. z .. [[, 200.00),
            		Class   = "]] .. dd .. [[",
            		Price   = ]] .. args[2] .. [[
            },
            -- end house

            ]]

            TriggerClientEvent("printInClient", player, theMsg)
        end)
    end
end)

RegisterCommand("ban", function(src, args)
    local target_id = tonumber(args[1])
    local time = tonumber(args[2])
    local dreptPlata = ((tonumber(args[3]) or 0) == 0) and true or false

    if not target_id or not time or not tonumber(args[3]) or not args[4] then
        local syntax = "/ban <user_id> <time (-1 = permanent)> <plata (0 = da, 1 = nu)> <motiv>"
        if src == 0 then
            print("^5Sintaxa: ^7"..syntax)
        else
            vRPclient.sendSyntax(src, {syntax})
        end

        return
    end

    if src == 0 then
        local theReason = table.concat(args, " ", 4)
        vRP.ban(target_id,theReason,false,(time or 0),dreptPlata)
        return
    end

    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) < 2 then return vRPclient.noAccess(src) end

    local theReason = table.concat(args, " ", 4)
    vRP.ban(target_id,theReason,src,(time or 0),dreptPlata)
    
	local target_src = vRP.getUserSource(target_id)
	local name = "ID "..target_id
	
	if target_src then
		name = GetPlayerName(target_src)
	end
	
	vRPclient.sendInfo(-1, {"^5"..GetPlayerName(src).."^7 i-a dat ban ^5"..((time or 0) > 0 and ""..time.." zile" or "permanent").."^7 lui ^5"..name.." ^7("..(not dreptPlata and "fara" or "cu").." drept de plata)"})
	vRPclient.msg(-1, {"^5Motiv^7: "..theReason})
    vRP.createLog(user_id, {target = target_id, reason = theReason}, "AdminBan")
end)

RegisterCommand("kick", function(player, args)
    if player == 0 then
        local usr = parseInt(args[1])
        if usr ~= nil and usr then
            local src = vRP.getUserSource(usr)
            if src ~= nil and usr then
                vRP.kick(src, "Admin Bot: Ai primit kick de la Consola!")
            else
                print("Jucator-ul este offline!")
            end
        else
            print("/kick <user_id>")
        end
    else
        local user_id = vRP.getUserId(player)
        if vRP.getUserAdminLevel(user_id) >= 2 then
            if args and args[1] and args[2] then
                local target_id = parseInt(args[1])
                local reason = args[2]
                for i = 3, #args do
                    reason = reason .. " " .. args[i]
                end
                if target_id and reason then
                    local target_src = vRP.getUserSource(target_id)
                    if target_id ~= 3 and target_id ~= 2 and target_id ~= 1 then
                        if target_src then

                            vRP.request(user_id, ("Esti sigur ca vrei sa ii dai kick lui ID: "..target_id), false, function(_, ok)
                                if ok then
                                    local adminName = GetPlayerName(player) or "Necunoscut"

                                    vRPclient.msg(-1, {"^1Kick^7: Adminul "..adminName.." ("..user_id..") l-a dat afara pe "..(GetPlayerName(target_src) or "Necunoscut").." ("..target_id..")\n^1Motiv^7: "..reason})
                                    vRP.kick(target_src, "Adminul "..adminName.." ti-a dat kick!\nMotiv: "..reason)

                                    vRP.createLog(user_id, {username = GetPlayerName(target_src), target = target_id, reason = reason}, "AdminKick")
                                end
                            end)
                        else
                            vRPclient.sendOffline(player)
                        end
                    else
                        TriggerClientEvent("chatMessage", -1, "^1[SYSTEM] ^7" .. GetPlayerName(player) .." a incercat sa-i dea kick lui ^1" .. GetPlayerName(target_src))
                        vRP.kick(player, "Ti-ai dat muie singur")
                    end
                end
            else
                vRPclient.sendSyntax(player, {"/kick <user_id> <motiv>"})
            end
        else
            vRPclient.noAccess(player)
        end
    end
end)

RegisterCommand("id", function(player, args)
    if args[1] then
        local strToFind = args[1]
        if strToFind:len() >= 2 then

            local users = vRP.getUsers({})

            if player ~= 0 then
                local user_id = vRP.getUserId(player)
                if vRP.getUserAdminLevel(user_id) < 1 then
                    return vRPclient.noAccess(player)
                end
                for k, v in pairs(users) do
                    if GetPlayerName(v) then
                        if string.find(GetPlayerName(v):upper(), strToFind:upper()) or string.find(k, strToFind) then
                            local fct = vRP.getUserFaction(k) or "user"
                            local job = "Somer"
                            if fct == "user" then
                                fct = "Civil"
                            end

                            vRP.getWarnsNum(k, function(warnsNr)

                                local usrr = "^5" .. GetPlayerName(v) .. "^7(^5" .. k .. "^7) | Ore: ^5" .. vRP.getUserHoursPlayed(k) .. "^7 | Ore ^5(last 7 days): ^7"..vRP.getUserLastHours(k).." ^5|^7 Warns: ^5" .. warnsNr .. "^7/3".. " ^7| Factiune: ^5" .. fct .. "^7 | Src: ^5" ..(v < 60000 and v or 'Loading Screen') .. " ^7| V-World: ^5" ..GetPlayerRoutingBucket(v)                        

                                TriggerClientEvent("chatMessage", player, usrr)
                            end)
                        end
                    elseif tostring(k) ~= "0" and k then
                        Citizen.CreateThread(function()
                            vRP.deleteOnlineUser(k)
                        end)
                    end
                end
            else
                print("^7----------------------------------------------------------------------------------------------------------------------------------------------------\n# Rezultatele cautarii dupa cheia: ^3" .. args[1].."^7")
                for k, v in pairs(users) do
                    if GetPlayerName(v) then
                        if string.find(GetPlayerName(v):upper(), strToFind:upper()) or string.find(k, strToFind) then
                            local fct = vRP.getUserFaction(k) or "user"
                            local job = "Somer"
                            if fct == "user" then
                                fct = "Civil"
                            end
                            vRP.getWarnsNum(k, function(warnsNr)
                                local usrr = "^5" .. GetPlayerName(v) .. "^7[^5" .. k .. "^7] Job: ^5" .. job .."^7 Ore: ^5" .. vRP.getUserHoursPlayed(k) .. "^7 Ore ^5(last 7 days): ^7"..vRP.getUserLastHours(k).."^5 |^7 Warns: ^5" .. warnsNr .. "^7/3 ^7| Factiune: ^5" .. fct .. "^7 Src: ^5" ..(v < 60000 and v or 'Loading Screen') .. "^7 V-World: ^5" ..GetPlayerRoutingBucket(v).." ^7Bank: ^5$"..vRP.formatMoney(vRP.getBankMoney(k)).."^7 Wallet: ^5$"..vRP.formatMoney(vRP.getMoney(k)).."^7 Coins: ^5"..vRP.getCoins(k)
                                print(usrr)
                            end)
                        end
                    elseif tostring(k) ~= "0" and k then
                        vRP.deleteOnlineUser({k})
                    end
                end
                print("^7----------------------------------------------------------------------------------------------------------------------------------------------------")
            end
        else
            if player ~= 0 then
                vRPclient.sendSyntax(player, {"/id <parte din nume (min. 2 litere) / id>"})
            else
                print("/id <parte din nume>")
            end
        end
    else
        if player ~= 0 then
            vRPclient.sendSyntax(player, {"/id <parte din nume (min. 2 litere) / id>"})
        else
            print("/id <parte din nume>")
        end
    end
end)

RegisterCommand("mute", function(source, args)
    local target_id = tonumber(args[1])
    local mutedTime = tonumber(args[2])
    local mutedReason = table.concat(args, " ", 3)

    local user_id = vRP.getUserId(source)
    if vRP.getUserAdminLevel(user_id) < 1 then
        return vRPclient.noAccess(source)
    end

    if not target_id or not mutedTime or not args[3] then
        return vRPclient.sendSyntax(source, {"/mute <id> <minute> <motiv>"})
    end

    local targetSrc = vRP.getUserSource(target_id)
    if not targetSrc then
        return vRPclient.sendOffline(source)
    end

    if mutedTime < 1 then
        return vRPclient.sendSyntax(source, {"/mute <id> <minute> <motiv>"})
    end

    mutedPlayers[target_id] = os.time() + (mutedTime * 60) -- n * 1 minut
    vRPclient.msg(-1, {"^4Mute: Adminul "..GetPlayerName(source).." ("..user_id..") i-a dat mute "..mutedTime.." minute lui "..GetPlayerName(targetSrc).." ("..target_id.."), motiv: "..mutedReason})

    vRP.createLog(user_id, {username = GetPlayerName(targetSrc), target = target_id, time = mutedTime, reason = mutedReason}, "AdminMute")

    vRP.addRaport(user_id, "mute")
    exports.mongodb:insertOne({collection = "punishLogs", document = {
        user_id = target_id,
        time = os.time(),
        text = "Mute de la "..GetPlayerName(source)..": "..mutedReason
    }})
end)

RegisterCommand("unmute", function(source, args)
    local target_id = tonumber(args[1])

    local user_id = vRP.getUserId(source)
    if vRP.getUserAdminLevel(user_id) < 1 then
        return vRPclient.noAccess(source)
    end

    if not target_id then
        return vRPclient.sendSyntax(source, {"/unmute <id>"})
    end

    local targetSrc = vRP.getUserSource(target_id)
    if not targetSrc then
        return vRPclient.sendOffline(source)
    end

    mutedPlayers[target_id] = nil
    vRPclient.msg(-1, {"^4Unmute: Adminul "..GetPlayerName(source).." ("..user_id..") i-a dat unmute lui "..GetPlayerName(targetSrc).." ("..target_id..")"})
end)


RegisterCommand("staffactivity", function(src)
    if src ~= 0 then
        local user_id = vRP.getUserId(src)
        if vRP.getUserAdminLevel(user_id) < 4 then
            return vRPclient.noAccess(src)
        end
    end

    exports.mongodb:find({collection = "users", query = {adminLvl = {["$gte"] = 1}}, options = {
        projection = {_id = 0, id = 1, userRaport = 1, username = 1},
        sort = {["userRaport.tickets"] = -1},
    }}, function(success, result)
        if not success then
            print("Error message: "..tostring(result))
            return
        end

        local cDate = os.date("%d/%m/%Y %H:%M")
        local msg = "---------------------- ^5Staff Activity results ^7----------------------\n^3# Results for Top Tickets at "..cDate..":^7\n\n"
        local topCount = 0

        for _, aData in pairs(result) do
            topCount = topCount + 1

            if aData.userRaport then
                msg = msg..topCount..". ^5"..aData.username.." ^7[^5"..aData.id.."^7] ◈ ^5"..aData.userRaport.tickets.." ^7tickete\n"
            else
                msg = msg..topCount..". ^5"..aData.username.." ^7[^5"..aData.id.."^7] ◈ ^50 ^7tickete\n"
            end
        end

        msg = msg.."\n^7-------------- ^5-------------- ^7-------------- ^5-------------- ^7--------------"
    
        if src == 0 then
            print(msg)
        else
            vRPclient.msg(src, {msg})
        end
    end)
end)

RegisterCommand("cleanup", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 3 then
        TriggerClientEvent("vrp-cleanup:delAllVehs", -1, tonumber(args[1]) or 60)
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("cancelcleanup", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 3 then
        TriggerClientEvent("vrp-cleanup:cancelDellAllVehs", -1, 60)
        vRPclient.sendInfo(-1, {"Adminul " .. GetPlayerName(player) .. " ("..user_id..") a anulat stergerea masinilor"})
    else
        vRPclient.noAccess(player)
    end
end)

local function giveAllBankMoney(amount)
    local users = vRP.getUsers({})
    for user_id, source in pairs(users) do
        vRP.giveBankMoney(user_id, tonumber(amount), "Bonus Owner")
        print("Bonus (money) dat pentru ID: "..user_id)
    end
end

RegisterCommand("giveallmoney", function(player, args)
    if player == 0 then
        local theMoney = parseInt(args[1]) or 0
        if theMoney < 1 then
            return print("/giveallmoney <amount>")
        end

        giveAllBankMoney(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: Server-ul a oferit tuturor jucatorilor $" ..vRP.formatMoney(theMoney) .. ".")
    else
        local user_id = vRP.getUserId(player)
        if vRP.getUserAdminLevel(user_id) < 6 then
            return vRPclient.noAccess(player)
        end

        local theMoney = parseInt(args[1]) or 0

        if theMoney < 1 then
            return vRPclient.sendSyntax(player, {"/giveallmoney <amount>"})
        end

        if theMoney > 51000 then
            return vRPclient.sendSyntax(player, {"/giveallmoney max: 50.000$"})
        end

        giveAllBankMoney(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: " .. vRP.getPlayerName(player) .. " a oferit tuturor jucatorilor $" ..vRP.formatMoney(theMoney) .. ".")
    end
end)


local function giveAllDiamonds(amount)
    local users = vRP.getUsers({})
    for user_id, source in pairs(users) do
        vRP.giveCoins(user_id, tonumber(amount), false, "Bonus Owner")
        print("Bonus (dmd) dat pentru ID: "..user_id)
    end
end

RegisterCommand("givealldmd", function(player, args)
    if player == 0 then
        local theMoney = parseInt(args[1]) or 0
        if theMoney < 1 then
            return print("/givealldmd <amount>")
        end

        giveAllDiamonds(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: Server-ul a oferit tuturor jucatorilor " ..vRP.formatMoney(theMoney) .. " Legend Coins.")
    else
        local user_id = vRP.getUserId(player)
        if vRP.getUserAdminLevel(user_id) < 6 then
            return vRPclient.noAccess(player)
        end

        local theMoney = parseInt(args[1]) or 0

        if theMoney < 1 then
            return vRPclient.sendSyntax(player, {"/givealldmd <amount>"})
        end

        if theMoney > 6 then
            return vRPclient.sendSyntax(player, {"/givealldmd max: 50dmd"})
        end

        giveAllDiamonds(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: " .. vRP.getPlayerName(player) .. " a oferit tuturor jucatorilor " ..vRP.formatMoney(theMoney) .. " Legend Coins.")
    end
end)

RegisterCommand("resetvwall", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) < 4 then
        return vRPclient.noAccess(player)
    end

    local users = vRP.getUsers()
    for uid, src in pairs(users) do
        SetPlayerRoutingBucket(src, 0)
    end

    vRPclient.sendInfo(-1, {"Adminul "..GetPlayerName(player) .. " a resetat virtual world-ul pentru tot server-ul"})
end)

RegisterCommand("plateid", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 2 then
        local plate = table.concat(args, " ", 1)
        
        if tostring(args[1]) then
            exports.mongodb:findOne({collection = "userVehicles", query = {carPlate = plate},
                options = {
                    projection = {
                        _id = 0,
                        user_id = 1
                    }
                }
            }, function(success, result)

                if #result > 0 then
                    vRPclient.msg(player, {"^1Plate Check: ^7Numarul de inmatriculare ^3"..plate.."^7 apartine ID-ului ^3"..result[1].user_id})
                else
                    vRPclient.sendError(player, {"Nu a fost gasita nici o masina cu acest numar de inmatriculare."})
                end

            end)
        else
            vRPclient.sendSyntax(player, {"/plateid <carPlate>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("swapid", function(player, args)
    local granted = (player == 0)
    if not granted then
        local user_id = vRP.getUserId(player)
        granted = (vRP.getUserAdminLevel(user_id) >= 5 )
    end

    if granted then

        local newId = tonumber(args[1])
        local oldId = tonumber(args[2])

        if oldId and newId then

            exports.mongodb:findOne({
                collection = "users",
                query = {
                    id = oldId
                },
                options = {
                    projection = {
                        _id = 0,
                        username = 1
                    }
                }
            }, function(success, result)
                if result[1] then

                    local target_src = vRP.getUserSource(newId)
                    if target_src then

                        local ids = GetPlayerIdentifiers(target_src)

                        local license = nil
                        for k, v in pairs(ids) do
                            if string.sub(v, 1, string.len("license:")) == "license:" then
                                license = v
                                break
                            end
                        end

                        if license ~= nil then

                            if player ~= 0 then
                                vRPclient.msg(player, {"^1Minunat ! ^7Licenta lui " .. GetPlayerName(target_src) .." a fost mutata pe id-ul " .. oldId})
                            else
                                print("^1Minunat ! ^7Licenta lui " .. GetPlayerName(target_src) .." a fost mutata pe id-ul " .. oldId)
                            end

                            DropPlayer(target_src, "Ti-a fost mutata licenta pe ID-ul " .. oldId)

                            exports.mongodb:deleteOne({
                                collection = "users",
                                query = {
                                    gtaLicense = license
                                }
                            }, function(success)
                                exports.mongodb:updateOne({
                                    collection = "users",
                                    query = {
                                        id = oldId
                                    },
                                    update = {
                                        ['$set'] = {
                                            gtaLicense = license
                                        }
                                    }
                                })
                            end)
                        else
                            if player ~= 0 then
                                vRPclient.notify(player, {"Nu s-a gasit licenta jucatorului, cere un relog.","error"})
                            else
                                print("Nu s-a gasit licenta jucatorului, cere un relog")
                            end
                        end
                    else
                        if player ~= 0 then
                            vRPclient.notify(player, {"Jucatorul trebuie sa fie conectat.", "error"})
                        else
                            print("Jucatorul trebuie sa fie conectat")
                        end
                    end
                else
                    if player ~= 0 then
                        vRPclient.notify(player, {"ID-ul " .. oldId .. " nu a fost gasit in baza de date.", "error"})
                    else
                        print("ID-ul "..oldId.." nu a fost gasit in baza de date!")
                    end
                end
            end)

        else
            if player ~= 0 then
                vRPclient.notify(player, {"/swapid [actualId] [oldId] | Ii schimba id-ul pe care ar trebuii sa-l bage", "info"})
            else
                print("^5Sintaxa: ^7/swapid [actualId] [oldId] | Ii schimba id-ul pe care ar trebuii sa-l bage")
            end
        end
    else
        vRPclient.notify(player, {"Nu ai acces la aceasta comanda.", "error"})
    end
end)

local changeIdWebHook = "https://discord.com/api/webhooks/1250124380143489074/AdnCJ_vgI9xHeMbaYtOS45lDv5wSqzQ5qH-IcOkf-5HIRuaYcaQ8UVWJ6hV-sYuicZ5w"
RegisterCommand("changeid", function(player, args)
    local granted = (player == 0 or vRP.getUserId(player) == 1 or vRP.getUserId(player) == 2 or vRP.getUserAdminLevel(user_id) >= 6)
    if player ~= 0 then
        local user_id = vRP.getUserId(player)
    end
    if granted then

        local oldId = tonumber(args[1])
        local newId = tonumber(args[2])

        if oldId and newId then
            exports.mongodb:findOne({
                collection = "users",
                query = {
                    id = newId
                },
                options = {
                    projection = {
                        _id = 0,
                        hoursPlayed = 1
                    }
                }
            }, function(success, result)
                local disponible = true
                if result[1] then
                    if (result[1]['hoursPlayed'] or 0) > 30 then
                        disponible = false
                    end
                end

                if disponible then
                    local src = vRP.getUserSource(oldId)
                    if src then
                        DropPlayer(src, "Ai primit kick deoarece ti s-a schimbat id-ul in " .. newId)
                    end

                    exports.mongodb:delete({
                        collection = "sData",
                        query = {
                            dkey = {
                                ['$regex'] = "u" .. newId .. "veh"
                            }
                        }
                    }, function(success)

                        exports.mongodb:find({
                            collection = "sData",
                            query = {
                                dkey = {
                                    ['$regex'] = "u" .. oldId .. "veh"
                                }
                            }
                        }, function(success, result)
                            for _, v in pairs(result) do
                                local car = splitString(v.dkey, "_")[2]
                                local newKeyName = "gb:u"..newId.."veh_"..car

                                if startsWith(v.dkey, "tr:u") then
                                    newKeyName = "tr:u"..newId.."veh_"..car
                                end


                                exports.mongodb:updateOne({
                                    collection = "sData",
                                    query = {
                                        dkey = v.dkey
                                    },
                                    update = {
                                        ['$set'] = {
                                            dkey = newKeyName
                                        }
                                    }
                                })
                            end
                        end)
                    end)

                    exports.mongodb:delete({
                        collection = "userTokens",
                        query = {
                            user_id = newId
                        }
                    }, function(success)
                        exports.mongodb:update({
                            collection = "userTokens",
                            query = {
                                user_id = oldId
                            },
                            update = {
                                ['$set'] = {
                                    user_id = newId
                                }
                            }
                        })
                    end)

                    exports.mongodb:delete({
                        collection = "users",
                        query = {
                            id = newId
                        }
                    }, function(success)
                        exports.mongodb:update({
                            collection = "users",
                            query = {
                                id = oldId
                            },
                            update = {
                                ['$set'] = {
                                    id = newId
                                }
                            }
                        })
                    end)

                    exports.mongodb:delete({
                        collection = "userVehicles",
                        query = {
                            user_id = newId
                        }
                    }, function(success)
                        exports.mongodb:update({collection = "userVehicles", query = {user_id = oldId}, update = {
                            ["$set"] = {user_id = newId}
                        }})
                    end)

                    if player == 0 then
                        print("Done !")
                        vRP.createLog(newId, {from = "Consola", target = oldId, newId = newId, oldId = oldId}, "Change ID")
                        PerformHttpRequest(changeIdWebHook, function(err, text, headers) end, 'POST', json.encode({
                            username = "Change ID", 
                            content = oldId.." a fost schimbat in id "..newId.." de catre consola."
                        }), { ['Content-Type'] = 'application/json' })
                    else
                        vRPclient.msg(player, {"^1Minunat ! ^7ID-ul a fost schimbat cu succes"})
                        vRP.createLog(newId, {from = GetPlayerName(player).."["..user_id.."]", target = oldId, newId = newId, oldId = oldId}, "Change ID")
                        PerformHttpRequest(changeIdWebHook, function(err, text, headers) end, 'POST', json.encode({
                            username = "Change ID", 
                            content = oldId.." a fost schimbat in id "..newId.." de catre "..GetPlayerName(player)
                        }), { ['Content-Type'] = 'application/json' })
                    end
                else
                    vRPclient.notify(player, {"ID-ul " .. newId .. " nu este disponibil deoarece are prea multe ore jucate", "error"})
                end
            end)

        else
            vRPclient.notify(player, {"/changeid [actualId] [newId] | Schimba id-ul jucatorului", "info"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

local moneyCfg = module('vrp', 'cfg/money')
RegisterCommand("ck", function(player, args)
    local granted = false
    if player == 0 then
        granted = true
    elseif IsPlayerAceAllowed(player, "command") then
        granted = true
    end

    if not granted then
        granted = vRP.getUserAdminLevel(vRP.getUserId(player)) >= 6
    end

    if not granted then
        return vRPclient.noAccess(player)
    end

    local adminck = "Consola"
    if not player == 0 then
        local user_id = vRP.getUserId(player)
        adminck = GetPlayerName(player).."["..user_id.."]"
    end
    local targetid = tonumber(args[1])

    if targetid then
        local targetSrc = vRP.getUserSource(targetid)

        local name = ""
        local jucator = targetid
        if targetSrc then
            print("Done online")
            jucator = GetPlayerName(targetSrc).."["..targetid.."]"
            DropPlayer(targetSrc, "Ai primit CK de la "..adminck)
        else
            print("Done offline")
        end
        Citizen.Wait(1000)

        exports.mongodb:update({collection = "houses", query = {owner = targetid}, update = {
            ["$unset"] = {owner = 1, ownerName = 1}
        }})
        print('Houses done')

        exports.mongodb:delete({collection = "phone_contacts", query = {user_id = targetid}})
        exports.mongodb:update({collection = "gas_business", query = {owner = targetid}, update = {
            ["$unset"] = {owner = 1}
        }})
        print('Gas business done')

        exports.mongodb:update({collection = "markets", query = {owner = targetid}, update = {
            ["$unset"] = {owner = 1}
        }})
        print('Markets done')

        exports.mongodb:updateOne({collection = "users", query = {id = targetid}, update = {
            ["$unset"] = {
                inventory = 1,
                uData = 1,
                userCoords = 1,
                userIdentity = 1,
                messagesFront = 1,
                userRaport = 1,
                jobSkill = 1,
                userFaction = 1,
                dmvTest = 1,
                health = 1,
                armour = 1,
                userWeapons = 1,
                userLevel = 1,
                job = 1,
                survival = 1,
                dailyData = 1,
                playerWanted = 1,
                metroTickets = 1,
                lastJob = 1,
                nextInvest = 1,
                investment = 1,
                cardFlips = 1,
                investedTimes = 1,
                userInventorySLots = 1,
                quickInventory = 1,
            },
            ["$set"] = {
                hoursPlayed = 0,
                lastHours = 0,
                ['userMoney.bank'] = moneyCfg and moneyCfg.open_bank or 0,
                ['userMoney.wallet'] = moneyCfg and moneyCfg.open_wallet or 0,
            }
        }})
        print('Account done')


        exports.mongodb:find({collection = "userVehicles", query = {user_id = targetid}}, function(success, result)
            if not success then
                print("Error message: "..tostring(result))
                return
            end

            for k, veh in pairs(result) do
                if not veh.premium then
                    exports.mongodb:deleteOne({collection = "userVehicles", query = {user_id = targetid, vehicle = veh.vehicle}})
                end
            end
        end)
        print('Cars done')
        vRP.createLog(targetid, {from = adminck, target = jucator}, "CK LOGS")
    else
        print("Syntax: /ck <user_id>")
    end
end)

RegisterCommand("ss", function(player, args)
    local user_id = vRP.getUserId(player)

    if vRP.getUserAdminLevel(user_id) >= 2 then
        local target_id = tonumber(args[1])

        if target_id then
            local target_src = vRP.getUserSource(target_id)

            if target_src then
                TriggerClientEvent("AC:requestScreenshot", target_src, player)
                vRP.sendStaffMessage("#{A0D8B3}[AC] " .. GetPlayerName(player) .. " just made a screenshot to " ..GetPlayerName(target_src).. " ["..target_id.."]", 4)
                vRPclient.msg(player, {"#{A0D8B3}Minunat! ^7I-ai facut o captura de ecran jucatorului "..GetPlayerName(target_src)})
            else
                vRPclient.sendOffline(player)
            end

        else
            vRPclient.sendSyntax(player, {"/ss <user_id>"})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterServerEvent("AC:sendScreenshot")
AddEventHandler("AC:sendScreenshot", function(player, image)
    TriggerClientEvent("vrp:sendNuiMessage", player, {
        interface = "screenshot",
        name = GetPlayerName(source).. '[' .. vRP.getUserId(source) ..']',
        image = image
    })
    PerformHttpRequest("https://discord.com/api/webhooks/1245816564976979988/K-0dvlOcemwBjw8e8WvCGknI5TxWHtWgL37IGtTzH844d7HzqPkY5pI7r6DOG9L904kf",function(err, text, headers)
    end, 'POST', json.encode({
        embeds = {{
            description = image,
            color = 0xFF6464,
            author = {
                name = (GetPlayerName(player) or 'Unknown') .. " [" .. vRP.getUserId(player) .. "]",
            },
            footer = {
                text = os.date("%d/%m/%y %H:%M")
            }
        }}

    }), {
        ['Content-Type'] = 'application/json'
    })
end)


local lastHit = nil
AddEventHandler("weaponDamageEvent", function(sender, data)
    local user_id = vRP.getUserId(sender)
    if data.damageType ~= 0 then
        lastHit = {
            sender = sender,
            dmg = data.weaponDamage,
            kill = data.willKill,
            user_id = user_id
        }
    end
end)

AddEventHandler("weaponDamageReply", function(sender, data)
    local user_id = vRP.getUserId(sender)
    if lastHit ~= nil and lastHit.user_id and user_id then
        TriggerClientEvent("printInClient", sender, "DMG Taken: " .. GetPlayerName(lastHit.sender) .. " [ID: " ..
            lastHit.user_id .. "] - " .. lastHit.dmg .. " HP")
        TriggerClientEvent("printInClient", lastHit.sender, "DMG Dealt: " .. GetPlayerName(sender) .. " [ID: " ..user_id .. "] - " .. lastHit.dmg .. " HP")
        TriggerClientEvent("vl:checkForWeapon", source, sender)
        -- vRP.insertLog(user_id, {killer = GetPlayerName(targetSource), weaponHash = }, "Kill Logs")
    end
end)

local WeaponNames = {
	[tostring(GetHashKey('WEAPON_UNARMED'))] = 'Unarmed',
	[tostring(GetHashKey('GADGET_PARACHUTE'))] = 'Parachute',
	[tostring(GetHashKey('WEAPON_KNIFE'))] = 'Knife',
	[tostring(GetHashKey('WEAPON_NIGHTSTICK'))] = 'Nightstick',
	[tostring(GetHashKey('WEAPON_HAMMER'))] = 'Hammer',
	[tostring(GetHashKey('WEAPON_BAT'))] = 'Baseball Bat',
	[tostring(GetHashKey('WEAPON_CROWBAR'))] = 'Crowbar',
	[tostring(GetHashKey('WEAPON_GOLFCLUB'))] = 'Golf Club',
	[tostring(GetHashKey('WEAPON_BOTTLE'))] = 'Bottle',
	[tostring(GetHashKey('WEAPON_DAGGER'))] = 'Antique Cavalry Dagger',
	[tostring(GetHashKey('WEAPON_HATCHET'))] = 'Hatchet',
	[tostring(GetHashKey('WEAPON_KNUCKLE'))] = 'Knuckle Duster',
	[tostring(GetHashKey('WEAPON_MACHETE'))] = 'Machete',
	[tostring(GetHashKey('WEAPON_FLASHLIGHT'))] = 'Flashlight',
	[tostring(GetHashKey('WEAPON_SWITCHBLADE'))] = 'Switchblade',
	[tostring(GetHashKey('WEAPON_BATTLEAXE'))] = 'Battleaxe',
	[tostring(GetHashKey('WEAPON_POOLCUE'))] = 'Poolcue',
	[tostring(GetHashKey('WEAPON_PIPEWRENCH'))] = 'Wrench',
	[tostring(GetHashKey('WEAPON_STONE_HATCHET'))] = 'Stone Hatchet',

	[tostring(GetHashKey('WEAPON_PISTOL'))] = 'Pistol',
	[tostring(GetHashKey('WEAPON_PISTOL_MK2'))] = 'Pistol Mk2',
	[tostring(GetHashKey('WEAPON_COMBATPISTOL'))] = 'Combat Pistol',
	[tostring(GetHashKey('WEAPON_PISTOL50'))] = 'Pistol .50	',
	[tostring(GetHashKey('WEAPON_SNSPISTOL'))] = 'SNS Pistol',
	[tostring(GetHashKey('WEAPON_SNSPISTOL_MK2'))] = 'SNS Pistol Mk2',
	[tostring(GetHashKey('WEAPON_HEAVYPISTOL'))] = 'Heavy Pistol',
	[tostring(GetHashKey('WEAPON_VINTAGEPISTOL'))] = 'Vintage Pistol',
	[tostring(GetHashKey('WEAPON_MARKSMANPISTOL'))] = 'Marksman Pistol',
	[tostring(GetHashKey('WEAPON_REVOLVER'))] = 'Heavy Revolver',
	[tostring(GetHashKey('WEAPON_REVOLVER_MK2'))] = 'Heavy Revolver Mk2',
	[tostring(GetHashKey('WEAPON_DOUBLEACTION'))] = 'Double-Action Revolver',
	[tostring(GetHashKey('WEAPON_APPISTOL'))] = 'AP Pistol',
	[tostring(GetHashKey('WEAPON_STUNGUN'))] = 'Stun Gun',
	[tostring(GetHashKey('WEAPON_FLAREGUN'))] = 'Flare Gun',
	[tostring(GetHashKey('WEAPON_RAYPISTOL'))] = 'Up-n-Atomizer',

	[tostring(GetHashKey('WEAPON_MICROSMG'))] = 'Micro SMG',
	[tostring(GetHashKey('WEAPON_MACHINEPISTOL'))] = 'Machine Pistol',
	[tostring(GetHashKey('WEAPON_MINISMG'))] = 'Mini SMG',
	[tostring(GetHashKey('WEAPON_SMG'))] = 'SMG',
	[tostring(GetHashKey('WEAPON_SMG_MK2'))] = 'SMG Mk2	',
	[tostring(GetHashKey('WEAPON_ASSAULTSMG'))] = 'Assault SMG',
	[tostring(GetHashKey('WEAPON_COMBATPDW'))] = 'Combat PDW',
	[tostring(GetHashKey('WEAPON_MG'))] = 'MG',
	[tostring(GetHashKey('WEAPON_COMBATMG'))] = 'Combat MG	',
	[tostring(GetHashKey('WEAPON_COMBATMG_MK2'))] = 'Combat MG Mk2',
	[tostring(GetHashKey('WEAPON_GUSENBERG'))] = 'Gusenberg Sweeper',
	[tostring(GetHashKey('WEAPON_RAYCARBINE'))] = 'Unholy Deathbringer',

	[tostring(GetHashKey('WEAPON_ASSAULTRIFLE'))] = 'Assault Rifle',
	[tostring(GetHashKey('WEAPON_ASSAULTRIFLE_MK2'))] = 'Assault Rifle Mk2',
	[tostring(GetHashKey('WEAPON_CARBINERIFLE'))] = 'Carbine Rifle',
	[tostring(GetHashKey('WEAPON_CARBINERIFLE_MK2'))] = 'Carbine Rifle Mk2',
	[tostring(GetHashKey('WEAPON_ADVANCEDRIFLE'))] = 'Advanced Rifle',
	[tostring(GetHashKey('WEAPON_SPECIALCARBINE'))] = 'Special Carbine',
	[tostring(GetHashKey('WEAPON_SPECIALCARBINE_MK2'))] = 'Special Carbine Mk2',
	[tostring(GetHashKey('WEAPON_BULLPUPRIFLE'))] = 'Bullpup Rifle',
	[tostring(GetHashKey('WEAPON_BULLPUPRIFLE_MK2'))] = 'Bullpup Rifle Mk2',
	[tostring(GetHashKey('WEAPON_COMPACTRIFLE'))] = 'Compact Rifle',

	[tostring(GetHashKey('WEAPON_SNIPERRIFLE'))] = 'Sniper Rifle',
	[tostring(GetHashKey('WEAPON_HEAVYSNIPER'))] = 'Heavy Sniper',
	[tostring(GetHashKey('WEAPON_HEAVYSNIPER_MK2'))] = 'Heavy Sniper Mk2',
	[tostring(GetHashKey('WEAPON_MARKSMANRIFLE'))] = 'Marksman Rifle',
	[tostring(GetHashKey('WEAPON_MARKSMANRIFLE_MK2'))] = 'Marksman Rifle Mk2',

	[tostring(GetHashKey('WEAPON_GRENADE'))] = 'Grenade',
	[tostring(GetHashKey('WEAPON_STICKYBOMB'))] = 'Sticky Bomb',
	[tostring(GetHashKey('WEAPON_PROXMINE'))] = 'Proximity Mine',
    [tostring(GetHashKey('WEAPON_PIPEBOMB'))] = 'Pipe Bomb',
	[tostring(GetHashKey('WEAPON_SMOKEGRENADE'))] = 'Tear Gas',
	[tostring(GetHashKey('WEAPON_BZGAS'))] = 'BZ Gas',
	[tostring(GetHashKey('WEAPON_MOLOTOV'))] = 'Molotov',
	[tostring(GetHashKey('WEAPON_FIREEXTINGUISHER'))] = 'Fire Extinguisher',
	[tostring(GetHashKey('WEAPON_PETROLCAN'))] = 'Jerry Can',
	[tostring(GetHashKey('WEAPON_BALL'))] = 'Ball',
	[tostring(GetHashKey('WEAPON_SNOWBALL'))] = 'Snowball',
	[tostring(GetHashKey('WEAPON_FLARE'))] = 'Flare',

	[tostring(GetHashKey('WEAPON_GRENADELAUNCHER'))] = 'Grenade Launcher',
	[tostring(GetHashKey('WEAPON_RPG'))] = 'RPG',
	[tostring(GetHashKey('WEAPON_MINIGUN'))] = 'Minigun',
	[tostring(GetHashKey('WEAPON_FIREWORK'))] = 'Firework Launcher',
	[tostring(GetHashKey('WEAPON_RAILGUN'))] = 'Railgun',
	[tostring(GetHashKey('WEAPON_HOMINGLAUNCHER'))] = 'Homing Launcher',
	[tostring(GetHashKey('WEAPON_COMPACTLAUNCHER'))] = 'Compact Grenade Launcher',
	[tostring(GetHashKey('WEAPON_RAYMINIGUN'))] = 'Widowmaker',

	[tostring(GetHashKey('WEAPON_PUMPSHOTGUN'))] = 'Pump Shotgun',
	[tostring(GetHashKey('WEAPON_PUMPSHOTGUN_MK2'))] = 'Pump Shotgun Mk2',
	[tostring(GetHashKey('WEAPON_SAWNOFFSHOTGUN'))] = 'Sawed-off Shotgun',
	[tostring(GetHashKey('WEAPON_BULLPUPSHOTGUN'))] = 'Bullpup Shotgun',
	[tostring(GetHashKey('WEAPON_ASSAULTSHOTGUN'))] = 'Assault Shotgun',
	[tostring(GetHashKey('WEAPON_MUSKET'))] = 'Musket',
	[tostring(GetHashKey('WEAPON_HEAVYSHOTGUN'))] = 'Heavy Shotgun',
	[tostring(GetHashKey('WEAPON_DBSHOTGUN'))] = 'Double Barrel Shotgun',
	[tostring(GetHashKey('WEAPON_AUTOSHOTGUN'))] = 'Sweeper Shotgun',

	[tostring(GetHashKey('WEAPON_REMOTESNIPER'))] = 'Remote Sniper',
	[tostring(GetHashKey('WEAPON_GRENADELAUNCHER_SMOKE'))] = 'Smoke Grenade Launcher',
	[tostring(GetHashKey('WEAPON_PASSENGER_ROCKET'))] = 'Passenger Rocket',
	[tostring(GetHashKey('WEAPON_AIRSTRIKE_ROCKET'))] = 'Airstrike Rocket',
	[tostring(GetHashKey('VEHICLE_WEAPON_SPACE_ROCKET'))] = 'Orbital Canon',
	[tostring(GetHashKey('VEHICLE_WEAPON_PLANE_ROCKET'))] = 'Plane Rocket',
	[tostring(GetHashKey('WEAPON_STINGER'))] = 'Stinger [Vehicle]',
	[tostring(GetHashKey('VEHICLE_WEAPON_TANK'))] = 'Tank Cannon',
	[tostring(GetHashKey('VEHICLE_WEAPON_SPACE_ROCKET'))] = 'Rockets',
	[tostring(GetHashKey('VEHICLE_WEAPON_PLAYER_LASER'))] = 'Laser',
	[tostring(GetHashKey('VEHICLE_WEAPON_PLAYER_LAZER'))] = 'Lazer',
	[tostring(GetHashKey('VEHICLE_WEAPON_PLAYER_BUZZARD'))] = 'Buzzard',
	[tostring(GetHashKey('VEHICLE_WEAPON_PLAYER_HUNTER'))] = 'Hunter',
	[tostring(GetHashKey('VEHICLE_WEAPON_WATER_CANNON'))] = 'Water Cannon',

	[tostring(GetHashKey('AMMO_RPG'))] = 'Rocket',
	[tostring(GetHashKey('AMMO_TANK'))] = 'Tank',
	[tostring(GetHashKey('AMMO_SPACE_ROCKET'))] = 'Rocket',
	[tostring(GetHashKey('AMMO_PLAYER_LASER'))] = 'Laser',
	[tostring(GetHashKey('AMMO_ENEMY_LASER'))] = 'Laser',
	[tostring(GetHashKey('WEAPON_RAMMED_BY_CAR'))] = 'Rammed by Car',
	[tostring(GetHashKey('WEAPON_FIRE'))] = 'Fire',
	[tostring(GetHashKey('WEAPON_HELI_CRASH'))] = 'Heli Crash',
	[tostring(GetHashKey('WEAPON_RUN_OVER_BY_CAR'))] = 'Run over by Car',
	[tostring(GetHashKey('WEAPON_HIT_BY_WATER_CANNON'))] = 'Hit by Water Cannon',
	[tostring(GetHashKey('WEAPON_EXHAUSTION'))] = 'Exhaustion',
	[tostring(GetHashKey('WEAPON_EXPLOSION'))] = 'Explosion',
	[tostring(GetHashKey('WEAPON_ELECTRIC_FENCE'))] = 'Electric Fence',
	[tostring(GetHashKey('WEAPON_BLEEDING'))] = 'Bleeding',
	[tostring(GetHashKey('WEAPON_DROWNING_IN_VEHICLE'))] = 'Drowning in Vehicle',
	[tostring(GetHashKey('WEAPON_DROWNING'))] = 'Drowning',
	[tostring(GetHashKey('WEAPON_BARBED_WIRE'))] = 'Barbed Wire',
	[tostring(GetHashKey('WEAPON_VEHICLE_ROCKET'))] = 'Vehicle Rocket',
	[tostring(GetHashKey('VEHICLE_WEAPON_ROTORS'))] = 'Rotors',
	[tostring(GetHashKey('WEAPON_AIR_DEFENCE_GUN'))] = 'Air Defence Gun',
	[tostring(GetHashKey('WEAPON_ANIMAL'))] = 'Animal',
	[tostring(GetHashKey('WEAPON_COUGAR'))] = 'Cougar',

    [tostring(GetHashKey("weapon_ak47"))] = "AK 47",
    [tostring(GetHashKey("weapon_de"))] = "Deaser Eagle",
    [tostring(GetHashKey("weapon_fnx45"))] = "Arma FNX-45,",
    [tostring(GetHashKey("weapon_glock17"))] = "PD Glock 17",
    [tostring(GetHashKey("weapon_m4"))] = "PD M4A1",
    [tostring(GetHashKey("weapon_hk416"))] = "HK416",
    [tostring(GetHashKey("weapon_mk14"))] = "PD MK14",
    [tostring(GetHashKey("weapon_m110"))] = "M110",
    [tostring(GetHashKey("weapon_ar15"))] = "PD AR-15",
    [tostring(GetHashKey("weapon_m9"))] = "PD Beretta M9A3",
    [tostring(GetHashKey("weapon_m70"))] = "M70",
    [tostring(GetHashKey("weapon_m1911"))] = "M1911",
    [tostring(GetHashKey("weapon_mac10"))] = "MAC 10",
    [tostring(GetHashKey("weapon_uzi"))] = "Uzi",
    [tostring(GetHashKey("weapon_mp9"))] = "MP9",
    [tostring(GetHashKey("weapon_mossberg"))] = "Mossberg",
    [tostring(GetHashKey("weapon_remington"))] = "Remington",
    [tostring(GetHashKey("weapon_scarh"))] = "SCAR-H",
}

RegisterServerEvent("vl:sendDataAboutWeapon", function(sender, weapon)
    local user_id = vRP.getUserId(sender)
    if lastHit ~= nil and lastHit.user_id and user_id then
        -- vRP.insertLog(user_id, {killer = GetPlayerName(lastHit.sender), weaponHash = weapon, damage = lastHit.dmg}, "Kill Logs")
        local weaponName = ""
        for k,v in pairs(WeaponNames) do
            if k == tostring(weapon) then
                weaponName = v
                print(v)
            end
        end
        exports.mongodb:insertOne({collection = "serverLogs", document = {
            user_id = user_id,
            details = {killer = GetPlayerName(sender), weaponHash = weaponName, damage = lastHit.dmg},
            time = os.time(),
            type = "Kill Logs"
        }})
        weaponName = nil
        lastHit = nil
    end
end)


RegisterCommand('createped', function (player, args)
    local user_id = vRP.getUserId(player)
    local ped = args[1]
    local heading = parseInt(args[2])
    if not ped or not heading then
        return vRPclient.sendSyntax(player, {"/createped <model> <heading>"})
    end
    if vRP.getUserAdminLevel(user_id) > 1 then
        vRPclient.getPosition(player,{},function(x,y,z)
            vRP.prompt(player,"Copy coords", "Pentru a copia coordonatele foloseste tastele CTRL-A pentru a selecta textul apoi apasa CTRL-C pentru a-l copia", (x..","..y..","..z), function()
                TriggerClientEvent('vrp-drugs:createTestPed', player, {pos = vector3(x, y, z), model = ped, h = heading})
             end)
        end)
    else
        vRPclient.noAccess(player)
    end
end)

local eventOn = false
local evCoords = {}

local theLimit = 0
local virtualWorld = 0
local inEvent, inEvCount = {}, 0

RegisterCommand("event", function(player, args)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 4 or vRP.hasGroup(user_id, "event") then
        if not eventOn then

            local pos = GetEntityCoords(GetPlayerPed(player))
            evCoords = {pos.x, pos.y, pos.z + 0.5}

            local vw = tonumber(args[1])
            if vw then
                eventOn = true
                virtualWorld = vw
                SetPlayerRoutingBucket(player, virtualWorld)
                theLimit = tonumber(args[2]) or 100
                inEvent, inEvCount = {}, 0

                vRP.setTmpTableVar(user_id, "makingEvent", true)

                vRP.sendStaffMessage("\n^5Event^7: " .. GetPlayerName(player) .. " [" .. user_id .."] a inceput sa organizeze un event\n")

                TriggerClientEvent("chatMessage", player,"Foloseste ^1/annoevent ^7pentru a anunta pe chat jucatorii ca trebuie sa dea /gotoevent !")
            else
                vRPclient.sendSyntax(player, {"/event <virtual-world> <limita>"})
            end
        else
            vRPclient.sendError(player, {"Exista deja un event in desfasurare ! \nFoloseste ^1/startevent^7 daca doresti sa pornesti evenimentul !"})
        end
    else
        vRPclient.noAccess(player)
    end
end)


RegisterCommand("annoevent", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 4 or vRP.hasGroup(user_id, "event") then
        if eventOn then
            TriggerClientEvent("chatMessage", player,"Foloseste ^1/startevent ^7pentru a pornii evenimentul, toti jucatorii aflati la eveniment o sa primeasca unfreeze !")
            TriggerClientEvent("chatMessage", -1, "^5Event^7: " .. vRP.getPlayerName(player) .." a creeat un event! \nFoloseste comanda ^1/gotoevent^7 pentru a ajunge la eveniment !")
        else
            vRPclient.sendError(player, {"Nu exista un eveniment activ."})
        end
    else
        vRPclient.noAccess(player)
    end
end)


local baniParticipare = 2000

RegisterCommand("startevent", function(player)
    local user_id = vRP.getUserId(player)
    if vRP.getUserAdminLevel(user_id) >= 4 or vRP.hasGroup(user_id, "event") then
        if eventOn then
            vRPclient.getPlayersInCoords(player, {evCoords[1], evCoords[2], evCoords[3], 10}, function(evPlayers)

                for src, _ in pairs(evPlayers) do
                    local usr_id = vRP.getUserId(src)
                    vRP.giveBankMoney(usr_id, baniParticipare, "Event Money")
                    vRPclient.notify(src, {"Ai primit " .. vRP.formatMoney(baniParticipare) .."$ pentru participare la event"})
                end
                vRP.setTmpTableVar(user_id, "makingEvent", false)

                evCoords = {}
                eventOn = false

                TriggerClientEvent("vrp:setFreeze", -1, false)
                TriggerClientEvent("afk-kick:passAutoKick", -1, false)
                TriggerClientEvent("chatMessage", -1,"^5Event^7: Toti jucatorii au primit unfreeze si eventul a inceput !")
            end)
        else
            vRPclient.sendError(player, {"Nu exista un eveniment activ."})
        end
    else
        vRPclient.noAccess(player)
    end
end)

RegisterCommand("gotoevent", function(player)
    if eventOn then
        if theLimit > 0 then
            theLimit = theLimit - 1
            if theLimit == 0 then
                TriggerClientEvent("chatMessage", -1, "^5Event^7: Evenimentul a atins ^1limita^7 de participanti")
            end

            local ped = GetPlayerPed(player)

            if GetEntityHealth(ped) > 105 then

                SetEntityCoords(ped, evCoords[1], evCoords[2], evCoords[3])
                TriggerClientEvent("vrp:setFreeze", player, true)
                TriggerClientEvent("afk-kick:passAutoKick", player, true)
                SetPlayerRoutingBucket(player, virtualWorld)

            else
                vRPclient.sendError(player, {"Nu poti participa mort la eveniment."})
            end
        else
            vRPclient.sendError(player, {"Nu mai sunt locuri disponibile la eveniment."})
        end
    else
        vRPclient.sendError(player, {"Nu exista un eveniment activ."})
    end
end)

local removeVehs = {
    ["760ig70"] = {"BMW 760i xDrive 2024", 300000, "clasa_a"},
    ["zondacinque"] = {"Pagani Zonda Cinque", 13000000, "clasa_a"},
    ["ie1"] = {"Gumpert Apollo Intesa 2019", 5000000, "clasa_a"},
    ["DL_G700"] = { "Mercedes Benz G63 G700 Brabus Topcar 2018", 935000, "clasa_a"},
    ["ikx3devel22"] = {"Devel Sixteen", 22500000, "clasa_a"},
    ["ikx3ep9"] = {"NIO EP9 2016", 3000000, "clasa_a"},
    ["ikx391814"] = {"PORSCHE 918 SPYDER", 1300000, "clasa_a"},
    ["purosangue22"] = {"Ferrari Purosangue 2023", 550000, "clasa_a"},
    ["giulia"] = {"Alfa Romeo Giulia", 175000, "Clasa_b"},
    ["dbx"] = {"Aston Martin DBX", 400000, "clasa_b"},
    ["r820"] = {"Audi R8", 300000, "clasa_b"},
    ["rs7c8"] = {"Audi RS7", 175000, "clasa_b"},
    ["5"] = {"BMW X6M", 172500, "clasa_b"},
    ["m2"] = {"BMW M2", 145000, "clasa_b"},
    ["c7"] = {"Chevrolet Corvette C7", 180000, "clasa_b"},
    ["stingray"] = {"Chevrolet Corvette Stingray", 205000, "clasa_b"},
    ["vip8"] = {"Dodge Viper", 135000, "clasa_b"},
    ["gtc4"] = {"Ferrari Lusso", 335000, "clasa_b"},
    ["430s"] = {"Ferrari Scuderia 430", 300000, "clasa_b"},
    ["s63amg"] = {"Mercedes-AMG S63 Sedan", 175000, "clasa_b"},
    ["17mansorypnmr"] = {"Porsche Panamera Mansory", 317500, "clasa_b"},
    ["taycants21m"] = {"Porsche Taycan Turbo S Mansory 2021", 525000, "clasa_b"},
    ["1500ghoul"] = {"Dodge Ram 2022", 430000, "clasa_b"},
    -- ["gcmm5sb"] = {"BMW 530d Touring", 47500, "clasa_c"},
    ["mmtmercani"] = {"Mercedes Benz AMG Hammer Pandem 1987", 70000, "clasa_c"},
    ["21rav4"] = {"Toyota RAV4", 27500, "clasa_c"},
    ["ikx3machegt21"] = {"Ford Mustang Mach-E GT 2021", 85000, "clasa_c"},
    ["austminlhd"] = {"Mini Cooper Austin", 3000, "clasa_d"},
    ["m140i"] = {"BMW M140i 2018", 36000, "clasa_d"},
    ["ap2"] = {"Honda S2000", 8750, "clasa_d"},
    ["gcmsportage2022"] = { "Kia Sportage", 18500, "clasa_d"},
    ["gcmcascada2018"] = {"Cascada 2018", 2200, "clasa_d"},
    ["lwgtr"] = {"Nissan gtr r35", 750000, "wanted"},
    ["rre46wide"] = {"BMW E46 WB", 280000, "wanted"},
    ["22b"] = {"Subaru Impreza 22b", 850000, "wanted"},
    ["nis13"] = { "Nissan Silvia S13", 550000, "wanted"},
    ["r33ptnc"] = {"Nissan Skyline GT-R R33 1993", 450000, "wanted"},
    ["gtr"] = {"Nissan GTR R35", 1200000, "wanted"},
    ["180sx"] = { "Nissan 180SX", 235000, "wanted"},
    ["skyline"] = {"Nissan Skyline R34", 400000, "wanted"},
    ["toy86"] = {"Toyota GT86", 475000, "wanted"},
    ["sunrise1"] = {"Toyota Camry", 365000, "wanted"},
    ["f10m5"] = {"BMW M5 F10", 1250000, "wanted"},
    ["man"] = { "Man TGX V8", 725000, "camioane"},
    ["gsxr19"] = { "Suzuki GSX-R1000R", 34500, "motoare"},
    ["zh2"] = {"Kawasaki ZH2", 43500, "motoare"},
    ["GODzNINJAH2"] = {"KAWASAKI NINJA H2 2023", 55000, "motoare"},
}

RegisterCommand('removevehs', function(player)
   if not player == 0 then
       return
   end

   for vehicle, data in pairs(removeVehs) do
       exports.mongodb:find({collection  = 'userVehicles', query = {vehicle = vehicle}}, function(succes, result)
           if #result >= 1 then
               for _, userData in pairs(result) do
                   if userData.vehicle and userData.user_id then
                       local user_id = parseInt(userData.user_id)
                       local target = vRP.getUserSource(user_id)

                       print('Removed vehicle '..vehicle..' from '..user_id..' and gave him '..data[2]..' for it')

                       if target then
                           vRP.removeCacheVehicle(user_id, vehicle)
                           vRP.giveMoney(user_id, data[2], 'Removed Vehicle '..vehicle)

                           vRPclient.notify(target, {"Vehiculul tau "..data[1].." a fost sters de catre un admin. Ai primit bani inapoi", 'error'})
                       else
                           exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                               ["$inc"] = {["userMoney.wallet"] = data[2]}
                           }})
                       end

                       exports.mongodb:deleteOne({collection = 'userVehicles', query = {user_id = user_id, vehicle = vehicle}})
                   end
               end
           end
       end)
   end
end)

local premiumVehs = {
    ["hycadeurus"] = {name = "Lamborghini Urus V.I.P.", price = 30}, -- mirror faruri
    ["21charscat"] = {name = "Dodge Charger V.I.P.", price = 5}, -- replace fara srt
    ["rmodcharger"] = {name = "Dodge Charger SRT V.I.P.", price = 5}, -- perf
    ["392scat"] = {name = "Dodge Challenger SRT V.I.P.", price = 5}, -- replace
    ["x6hamann"] = {name = "BMW X6 Hamann V.I.P.", price = 15}, -- extra faruri oglinzi dials
    ["taycan"] = {name = "Porsche Taycan V.I.P.", price = 15}, -- replace
    ["rrst"] = {name = "Range Rover Startech V.I.P.", price = 5}, -- faruri plate spate
    ["rmodsvj"] = {name = "Lamborghini Aventador SVJ V.I.P.", price = 30}, -- perf
    ["osiris"] = {name = "Pagani Huayra Roadster V.I.P.", price = 25}, -- replace
    ["sianr"] = {name = "Lamborghini Sian Roadster V.I.P.", price = 25}, -- replace
    ["lp610"] = {name = "Lamborghini Huracan Evo Spyder V.I.P.", price = 25}, -- replace
    ["amggtsmansory"] = {name = "Mercedes AMG GT S Mansory V.I.P.", price = 15}, -- faruri done
    ["bmwx7kahn"] = {name = "BMW X7 Khann V.I.P.", price = 10}, -- faruri done
    ["m516"] = {name = "BMW M5 F10 V.I.P.", price = 5}, -- replace
    ["aperta"] = {name = "Ferrari LaFerrari V.I.P.", price = 25}, -- replace
    ["mclp1"] = {name = "McLaren P1 V.I.P.", price = 25}, -- replace
    ["amgone"] = {name = "Mercedes-Benz AMG ONE V.I.P.", price = 30}, -- nu ma bag
    ["rmodveneno"] = {name = "Lamborghini Veneno V.I.P.", price = 30}, -- perf
    ["agerars"] = {name = "Koenigsegg Agera RS V.I.P.", price = 30}, -- faruri verify extra
    ["fm488"] = {name = "Ferrari 4XX Mansory V.I.P.", price = 15}, -- ogliunzi faruri
    ["chiron17"] = {name = "Bugatti Chiron V.I.P.", price = 30}, -- replace
    ["GODz95GSX"] = {name = "Eclipse GSX WB 1995 V.I.P.", price = 30}, --- handling
    ["718gt4rs"] = {name = "Porsche Cayman 718 GT4 RS 2023 V.I.P.", price = 30}, --- handling
    ["oycklnk"] = {name = "Rolls Royce Cullinan Keyvany 2022 V.I.P.", price = 30}, --- handling
    ["Mansoryphantom8"] = {name = "Rolls Royce Mansory Phantom VIII 2017 V.I.P.", price = 30}, --- handling
    ["GODzLBWKM4GTS"] = {name = "BMW M4 GTS V.I.P.", price = 15}, --- handling
    ["ikx3machegt21"] = {name = "Ford Mustang MACH E-GT 2021 V.I.P.", price = 10}, --- handling
    ["rmod911gt3"] = {name = "Porsche 911 GT3 V.I.P.", price = 10}, --- handling
    ["rs7c821"] = {name = "Audi RS7 C8 ABT V.I.P.", price = 10}, --- handling
    ["911turbos"] = {name = "Porsche 911 Turbo S V.I.P.", price = 15}, --- handling
    ['2018s650'] = {price = 10},
    ['2018s650p'] = {price = 10},
    ['bmwm4'] = {price = 10},
    ['rmodm8c'] = {price = 5},
    ['rs5mans'] = {price = 10},
    ['r8v10abt'] = {price = 5},
    ['windsor2'] = {price = 20},
    ['dawnonyx'] = {price = 5},
    ['mvisiongt'] = {price = 60},
    ['terzo'] = {price = 60},
    ['gcmetronsportback2021'] = {price = 3},
    ['gcmmodelsplaid2021'] = {price = 3},
    ['xplaid24'] = {price = 4},
    ['swift2'] = {price = 15},
    ['luxor2'] = {price = 15},
}

RegisterCommand('takecoins', function(player)
    local user_id = vRP.getUserId(player)
    local ids = GetPlayerIdentifiers(player)

    if #ids > 0 then
        local found = false
        for _, identify in pairs(ids) do
            if string.find(identify, "license:") or string.find(identify, "license2:") then
                exports.mongodb:findOne({collection = "premiumShop", query = {accountLicense = identify}}, function(success, result)
                    if result[1] and not found then
                        found = true;

                        if not result[1].collected then
                            local coins = 0

                            for _, data in pairs(result[1].premiumVehicles or {}) do
                                if data.vehicle and premiumVehs[data.vehicle] then

                                    local price = premiumVehs[data.vehicle].price
                                    coins += price
                                end
                            end

                            local walletCoins = result[1].userMoney and result[1].userMoney.premiumCoins or 0
                            coins += walletCoins

                            if coins > 0 then
                                vRP.giveCoins(user_id, coins, true, 'Coins from old account - ID: '..result[1].id)
                            else
                                vRPclient.notify(player, {'Nu ai coins de primit de pe vechiul cont!', 'error'})
                            end

                            print('[AL] Gave '..coins..' coins to '..user_id..' from old account '..result[1].id)

                            exports.mongodb:updateOne({collection = "premiumShop", query = {accountLicense = identify}, update = {
                                ["$set"] = {collected = true}
                            }})
                        else
                            local id = result[1] and result[1].id or false;

                            if not id then
                                vRPclient.msg(player, {"Nu a fost gasit un id pentru licenta ta! Licenta: "..identify})

                                print('ERROR: No id found for license '..json.encode(result[1])..'!')
                                return 
                            end

                            vRPclient.notify(player, {"Ai deja toate monedele colectate de pe vechiul cont! Id-ul tau vechi este: "..id, 'error'})
                        end
                    end
                end)
            end
        end
    else
        vRPclient.notify(player, {'A aparut o eroare, te rugam sa te reconectezi pe server!', 'error'})
    end
end)