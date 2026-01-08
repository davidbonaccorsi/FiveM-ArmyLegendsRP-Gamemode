local takingHostage = {}
local takenHostage = {}

RegisterServerEvent("takeHostage:sync")
AddEventHandler("takeHostage:sync", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	TriggerClientEvent("takeHostage:syncTarget", targetSrc, source)
	takingHostage[source] = targetSrc
	takenHostage[targetSrc] = source
end)

RegisterServerEvent("takeHostage:releaseHostage")
AddEventHandler("takeHostage:releaseHostage", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takenHostage[targetSrc] then 
		TriggerClientEvent("takeHostage:releaseHostage", targetSrc, source)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	end
end)

RegisterServerEvent("takeHostage:killHostage")
AddEventHandler("takeHostage:killHostage", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takenHostage[targetSrc] then 
		TriggerClientEvent("takeHostage:killHostage", targetSrc, source)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	end
end)

RegisterServerEvent("takeHostage:stop")
AddEventHandler("takeHostage:stop", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takingHostage[source] then
		TriggerClientEvent("takeHostage:cl_stop", targetSrc)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	elseif takenHostage[source] then
		TriggerClientEvent("takeHostage:cl_stop", targetSrc)
		takenHostage[source] = nil
		takingHostage[targetSrc] = nil
	end
end)

AddEventHandler('vRP:playerLeave', function()
	if takingHostage[source] then
		TriggerClientEvent("takeHostage:cl_stop", takingHostage[source])

		takenHostage[takingHostage[source]] = nil
		takingHostage[source] = nil
	end

	if takenHostage[source] then
		TriggerClientEvent("takeHostage:cl_stop", takenHostage[source])
		
		takingHostage[takenHostage[source]] = nil
		takenHostage[source] = nil
	end
end)

vRP.registerActionsMenuBuilder("basicply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  	local choices = {}

	  	choices["Take hostage"] = {function()
			vRPclient.executeCommand(player, {"th"})
		end, "hostage.png"}
  
		add(choices)
	end
end)

-- carry

local piggybacking = {}
local beingPiggybacked = {}
local carrying = {}
local carried = {}

RegisterServerEvent("Piggyback:sync")
AddEventHandler("Piggyback:sync", function(targetSrc)
    if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][piggyBack]")
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    if #(sourceCoords - targetCoords) <= 3.0 then 
        TriggerClientEvent("Piggyback:syncTarget", targetSrc, source)
        piggybacking[source] = targetSrc
        beingPiggybacked[targetSrc] = source
    end
end)

RegisterServerEvent("Piggyback:stop")
AddEventHandler("Piggyback:stop", function(targetSrc)
    if piggybacking[source] then
        TriggerClientEvent("Piggyback:cl_stop", targetSrc)
        piggybacking[source] = nil
        beingPiggybacked[targetSrc] = nil
    elseif beingPiggybacked[source] then
        TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
        piggybacking[beingPiggybacked[source]] = nil
        beingPiggybacked[source] = nil
    end
end)

RegisterServerEvent("CarryPeople:sync")
AddEventHandler("CarryPeople:sync", function(targetSrc)
    if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][carryPeople]")
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    
    if #(sourceCoords - targetCoords) <= 3.0 then 
        TriggerClientEvent("CarryPeople:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

RegisterServerEvent("CarryPeople:stop")
AddEventHandler("CarryPeople:stop", function(targetSrc)
    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])          
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

AddEventHandler('vRP:playerLeave', function()    
    if piggybacking[source] then
        TriggerClientEvent("Piggyback:cl_stop", piggybacking[source])
        beingPiggybacked[piggybacking[source]] = nil
        piggybacking[source] = nil
    end

    if beingPiggybacked[source] then
        TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
        piggybacking[beingPiggybacked[source]] = nil
        beingPiggybacked[source] = nil
    end

    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

vRP.registerActionsMenuBuilder("basicply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  	local choices = {}

	  	choices["Carry"] = {function()
			vRPclient.executeCommand(player, {"cara"})
		end, "carry.png"}

        choices["Piggyback"] = {function()
			vRPclient.executeCommand(player, {"caraprieten"})
		end, "carrypig.svg"}
  
		add(choices)
	end
end)
