
local str = {}

RegisterNetEvent("ARPF-EMS:server:stretcherSync")
AddEventHandler("ARPF-EMS:server:stretcherSync", function(state,tableID,obj,towhat)
	
	if state == 1 then -- add
		if tableID < 0 then 
			str[#str + 1] = { ['obj'] = obj, ['to'] = towhat}
			TriggerClientEvent("ARPF-EMS:stretcherSync", -1,str)
		end 
	elseif state == 2 then -- change
		if tableID > 0 then 
			str[tableID] = { ['obj'] = obj, ['to'] = towhat}
			TriggerClientEvent("ARPF-EMS:stretcherSync", -1,str)
		end
	elseif state == 3 then -- remove 
		if tableID > 0 then
			table.remove(str,tableID)
			TriggerClientEvent("ARPF-EMS:stretcherSync", -1,str)
		end
	end
	
end)


vRP.registerActionsMenuBuilder("emergencyply", function(add, data)
	local player = data.player
	local user_id = data.user_id
	local near = data.near
	if user_id ~= nil then
	  	local menu = {}
	
		menu["Pune pe targa"] = {function(player)
			
			local nplayer = near
			local nuser_id = vRP.getUserId(nplayer)
			if nuser_id ~= nil then
				TriggerClientEvent("ARPF-EMS:getintostretcher", nplayer)
				vRPclient.notify(nplayer,{"Ai fost urcat pe targa! Apasa tasta X pentru a te da jos."})
				vRPclient.notify(player,{"Du pacientul la spital pentru ingrijiri medicale!"})
			end

		end, "punepetarga.svg"}

		add(menu)
	end
end)

vRP.registerActionsMenuBuilder("emergency", function(add, data)
	local player = data.player
	local user_id = data.user_id
	if user_id ~= nil then
	  	local menu = {}
		
		menu["Spawn Targa"] = {function(player)
			TriggerClientEvent("ARPF-EMS:spawnstretcher", player)
		end, "stretcher.svg"}

		menu["Impinge targa"] = {function(player)
			TriggerClientEvent("ARPF-EMS:pushstreacherss", player)
			vRPclient.notify(player, {"Apasa tasta X pentru a te oprii."})
		end, "pushtarga.svg"}

		menu["Deschide/Inchide Usi"] = {function(player)
			TriggerClientEvent("ARPF-EMS:opendoors", player)
		end, "ambulance.svg"}

		menu["Pune/Scoate in Masina"] = {function(player)
			TriggerClientEvent("ARPF-EMS:togglestrincar", player)
		end, "ambulance.svg"}

		add(menu)
	end
end)
