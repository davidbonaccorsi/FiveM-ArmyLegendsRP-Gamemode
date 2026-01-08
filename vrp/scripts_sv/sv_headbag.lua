local headBags = {}
local mouthGag = {}

AddEventHandler("vrp-headbag:useMouthGag", function(player, state)
    local user_id = vRP.getUserId(player)

    if user_id then
        mouthGag[user_id] = state
    end
end)

RegisterServerEvent('vrp-headbag:useHeadBag')
AddEventHandler("vrp-headbag:useHeadBag", function(thePlayer, state)
    local user_id = vRP.getUserId(thePlayer)

    vRPclient.getNearestPlayer(thePlayer, {10}, function(target)
        local userID = vRP.getUserId(target)

        if userID then
            if headBags[userID] then
                vRPclient.notify(thePlayer, {"Acest jucator are deja o punga pe cap.", "error"})
            else
                if vRP.removeItem(user_id, 'head_bag') then
                    vRPclient.notify(thePlayer, {"I-ai pus o punga pe cap lui "..GetPlayerName(target).."."})
                    vRPclient.notify(target, {GetPlayerName(thePlayer).." ti-a pus o punga pe cap!"})

                    Citizen.Wait(2000)

                    headBags[userID] = true
                    TriggerClientEvent("vrp-headbag:useHeadBag", target)
                end
            end
        end
    end)
end)

RegisterServerEvent('vrp-headbag:coverTheMouth')
AddEventHandler("vrp-headbag:coverTheMouth", function(thePlayer)
    local user_id = vRP.getUserId(thePlayer)
    vRPclient.getNearestPlayer(thePlayer, {10}, function(target)
        local userID = vRP.getUserId(target)

        if userID then
			if(mouthGag[userID] ~= nil)then
				vRPclient.notify(thePlayer, {"Acest jucator are deja o bila in gura!"})
			else
                if vRP.removeItem(user_id, 'mouthgag') then
                    mouthGag[userID] = true
					vRPclient.notify(target, {GetPlayerName(thePlayer).." ti-a bagat o bila in gura!"})
					vRPclient.notify(thePlayer, {"I-ai bagat o bila in gura lui "..GetPlayerName(target)})
                end
			end
		end
	end)
end)

local function ch_takeBag(player, choice)
	local user_id = vRP.getUserId(player)
	vRPclient.isHandcuffed(player, {true}, function(isHandcuffed)
		if(isHandcuffed)then
			vRPclient.notify(player, {"Esti legat la maini!", "error"})
		else
            vRPclient.getNearestPlayer(player,{10},function(target)
                local userID = vRP.getUserId(target)

                if userID then
                    if(headBags[userID] == true)then
                        headBags[userID] = nil
                        TriggerClientEvent("vrp-headbag:takeOffBag", target)
                        vRPclient.notify(player, {"I-ai dat punga jos de pe cap lui "..GetPlayerName(target).."."})
                        vRPclient.notify(target, {GetPlayerName(player).." ti-a dat punga jos de pe cap!"})
                        vRP.giveItem(user_id, "head_bag", 1)
                    else
                        vRPclient.notify(player, {"Jucatorul nu are nici o punga pe cap!", "error"})
                    end
                end
            end)
		end
	end)
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if not first_spawn then
        if(headBags[user_id] == true)then
            headBags[user_id] = nil
            TriggerClientEvent("vrp-headbag:takeOffBag", player)
        end
    end
end)

local function ch_takeMouthGag(player, choice)
	local user_id = vRP.getUserId(player)
	vRPclient.isHandcuffed(player, {}, function(isHandcuffed)
		if(isHandcuffed)then
			vRPclient.notify(player, {"Esti legat la maini!", "error"})
		else
            vRPclient.getNearestPlayer(player,{10},function(target)
                local userID = vRP.getUserId(target)

                if userID then
					if(mouthGag[userID] == true)then
						mouthGag[userID] = nil
						vRPclient.notify(player, {"I-ai scos bila din gura lui "..GetPlayerName(target).."."})
						vRPclient.notify(target, {GetPlayerName(player).." ti-a scos bila din gura!"})
						vRP.giveItem(user_id, "mouthgag", 1)
					else
						vRPclient.notify(player, {"Jucatorul nu are nimic in gura!", "error"})
					end
				end
			end)
		end
	end)
end


vRP.registerActionsMenuBuilder("nearply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)

	if user_id ~= nil then
	  	-- add bag entry
	  	local choices = {}
        local needToAdd = promise.new()

        vRPclient.getNearestPlayer(player,{10},function(nplayer)
            local userID = vRP.getUserId(nplayer)
    
            needToAdd:resolve(userID and (mouthGag[userID] or headBags[userID]))
        end)

        if Citizen.Await(needToAdd) then
            choices["Scoate punga"] = {ch_takeBag, "head_bag.png"}

            choices["Scoate bila din gura"] = {ch_takeMouthGag, "remove_gag.svg"}
        end

        add(choices)
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn) 
	mouthGag[user_id] = nil
	headBags[user_id] = nil
end)

AddEventHandler("vRP:playerLeave",function(user_id, source)
	if(headBags[user_id] ~= nil)then
		headBags[user_id] = nil
	end
	if(mouthGag[user_id] ~= nil)then
		mouthGag[user_id] = nil
	end
end)