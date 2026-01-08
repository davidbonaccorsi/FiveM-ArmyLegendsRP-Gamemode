
local inExamination = {}

registerCallback("vrp-dmv:openExaminationMenu", function(player)
    local user_id = vRP.getUserId(player)
	local data = vRP.usersData[user_id] or {}

    if data.dmvTest then
        return false, "Deja ai permisul auto."
    end

	if vRP.tryBankPayment(user_id, 100) or vRP.tryPayment(user_id, 100) then
		inExamination[user_id] = "test"

        return true
	end

    return false, "Nu ai destui bani pentru a putea incepe testul teoretic."
end)


local schoolCoords = {-1108.6447753906,-2770.2277832031,21.361354827881}

RegisterServerEvent("vrp-dmv:updateExamination", function(state)
    local player = source
    local ped = GetPlayerPed(player)

    local user_id = vRP.getUserId(player)

    if state and inExamination[user_id] then

        if type(inExamination[user_id]) == "string" then
            inExamination[user_id] = os.time()            
            TriggerClientEvent("vrp-dmv:startDriving", player)
        end
    else
        vRPclient.notify(player, {"Din pacate nu ai reusit sa treci testul teoretic.", "error"})
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if inExamination[user_id] then
        inExamination[user_id] = nil
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, connect)
    if connect then
        Citizen.Wait(500)

		local data = vRP.usersData[user_id] or {}

        if not vRP.hasItem(user_id, "auto_doc") and data.dmvTest then
			vRP.giveItem(user_id, "auto_doc", 1)
        end
    end
end)

RegisterServerEvent("vrp-dmv:finishExamination", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if type(inExamination[user_id]) == "number" then
        if vRP.usersData[user_id] then
            vRP.updateUser(user_id, "dmvTest", true)
        end
        
		vRP.giveItem(user_id, "auto_doc", 1)

        if not exports.vrp:hasCompletedBegginerQuest(user_id, 2) then
            exports.vrp:completeBegginerQuest(user_id, 2)
        end

        exports.vrp:achieve(user_id, 'drivingschoolEasy', 1)

		vRPclient.notify(player, {"Felicitari, ai obtinut permisul de conducere!", "info"})
        vRPclient.teleport(player, schoolCoords)
        
        inExamination[user_id] = nil
    end
end)