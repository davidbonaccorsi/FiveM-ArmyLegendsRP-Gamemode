

function tvRP.getUserHours(target)
    local target_id = vRP.getUserId(target)
    local hours = vRP.getUserHoursPlayed(target_id)
    return hours
end

RegisterCommand("spawnmasiv", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 4 or vRP.hasGroup(user_id, "event") then

		local tmp = vRP.getUserTmpTable(user_id)
		if tmp.makingEvent then

			if args[1] then
				vRP.sendStaffMessage("^5Event: ^7 "..GetPlayerName(player).." a spawnat masiv modelul ^1"..args[1], 4)
			end

			TriggerClientEvent("event:spawnMasiv", player, args)

		else
			vRPclient.sendError(player, {"Trebuie sa pornesti un eveniment pentru a folosii aceasta comanda"})
		end
	else
		vRPclient.noAccess(player)
	end
end)


RegisterServerEvent("vrp:setRoutingBucket", function(bucket)
    local player = source
    if type(bucket) == "string" then
        local user_id = vRP.getUserId(player)
        bucket = user_id
    end
    SetPlayerRoutingBucket(player, bucket or 0)
end)

-- ropes
local tiedPlayers = {}

function tvRP.isTiedWithRope(target)
    if not target then
        target = source
    end
	return (tiedPlayers[target] or false)
end

function tvRP.cutRope(target)
	if tiedPlayers[target] then
		vRPclient.playAnim(source, {false, {{"mp_arresting", "a_uncuff"}}, false})
		vRPclient.playAnim(target, {false, {{"mp_arresting", "b_uncuff"}}, false})
		Citizen.Wait(4000)
		vRPclient.togHandcuffs(target, {})
		tiedPlayers[target] = nil
	end
end

vRP.defInventoryItem("rope", "Sfoara", "Folosita pentru a lega persoane sau pentru jafuri", function(player)
	local user_id = vRP.getUserId(player)
	
	vRPclient.getNearestPlayer(player, {10}, function(nplayer)
		local nuser_id = vRP.getUserId(nplayer)
		if nuser_id then
			vRPclient.isHandcuffed(nplayer, {}, function(handcuffed)
				if not handcuffed then

					if vRP.removeItem(user_id, 'rope') then
						TriggerClientEvent('police:animBeingArrest', nplayer, player)
						TriggerClientEvent('police:animArresting', player)
						Citizen.Wait(5000)
						vRPclient.togHandcuffs(nplayer, {})

						tiedPlayers[nplayer] = true
					end
				else
					vRPclient.notify(player, {"Este deja legat la maini.", "error"})
				end
			end)
		else
			vRPclient.notify(player, {"Nici un jucator nu este langa tine.", "error"})
		end
	end)
end, 0.3, 'others')

-- /me

RegisterServerEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text, backgroundEnabled, activePlayers)
	local player = source
	
	for _, src in pairs(activePlayers) do
		TriggerClientEvent('3dme:triggerDisplay', src, player, text, backgroundEnabled or false)
	end
end)


-- metro

local metroTickets, metro = {}, module("cfg/metro")
RegisterServerEvent("vrp-metro:tryBuyTicket", function()
    local player = source
    local user_id = vRP.getUserId(player)

    vRP.request(player, "Esti sigur ca vrei sa cumperi un bilet?<br><br>Pret per bilet: <span style='color: #ffde2a'>$"..vRP.formatMoney(metro.ticketPrice).."</span>", false, function(_, ok)
        
        if ok and vRP.tryPayment(user_id, metro.ticketPrice, true, "Metro") then
            metroTickets[user_id] += 1
            vRPclient.notify(player, {"Acum ai in total "..metroTickets[user_id].." bilete de calatorie."})

            TriggerClientEvent("vrp-metro:boughtTicket", player, metroTickets[user_id] > 0)
        end
    end)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
    if first_spawn and dbdata then
        metroTickets[user_id] = dbdata.metroTickets or 0

        TriggerClientEvent("vrp-metro:boughtTicket", player, metroTickets[user_id] > 0)
    end
end)

RegisterServerEvent("vrp-metro:checkPlayerTickets", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if metroTickets[user_id] > 0 then
        metroTickets[user_id] -= 1
        vRPclient.notify(player, {"Ai folosit un bilet de calatorie."})
    end

    TriggerClientEvent("vrp-metro:boughtTicket", player, metroTickets[user_id] > 0)
end)

RegisterServerEvent('vrp-anticheat:kickPlayer', function(reason)
	local player = source
	local user_id = vRP.getUserId(player)

	if user_id > 5 then
		DropPlayer(player, reason)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if metroTickets[user_id] then
        vRP.updateUser(user_id, "metroTickets", metroTickets[user_id] > 0 and metroTickets[user_id] or false)
    end
end)

-- ---

registerCallback("rent:checkMoney", function(player, pos, skip)
    local user_id = vRP.getUserId(player)

	local paid = skip or vRP.tryPayment(user_id, 100, false, "Rent")

    if paid then
        TriggerEvent("ac:getSpawnPoint", player)
    end

    return paid
end)