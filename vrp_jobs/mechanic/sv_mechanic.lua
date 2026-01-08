local activeCalls = {}

RegisterServerEvent("vrp-phone:callService")
AddEventHandler("vrp-phone:callService", function(service)
    local player = source
    local user_id = vRP.getUserId(player)

    if service == "mechanic" then

        if not activeCalls[user_id] then

            activeCalls[user_id] = {
                user_id = user_id,
                player = player,
                name = exports.vrp:getRoleplayName(user_id, true),
                position = GetEntityCoords(GetPlayerPed(player)),
            }

            Citizen.Wait(100)
            if activeCalls[user_id] then
                doInJobPlayersFunction("Mecanic", function(member)
                    TriggerClientEvent("vrp:sendNuiMessage", member, {interface = "emsCallsAlert"})
                end)
            end
        else
            vRPclient.notify(player, {"Ai deja un apel in asteptare.", "error"})
        end
    end
end)

RegisterServerEvent("ems:takeCall", function(target_id)
    local player = source
    local user_id = vRP.getUserId(player)

    if exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
        if activeCalls[target_id] then
            TriggerClientEvent("ems:startCall", player, activeCalls[target_id].player, activeCalls[target_id].position, 380, 31)
            
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.notify(target_src, {"Un mecanic se indreapta catre tine.", "error"})

                vRPclient.notify(player, {"Te indrepti catre un apel.\n\nSolicitant: "..exports.vrp:getRoleplayName(target_id), "info", "Apel preluat", 10000})
            end

            exports.vrp:achieve(user_id, "MechanicEasy", 1)

            activeCalls[target_id] = nil
        else
            vRPclient.notify(player, {"Solicitare invalida.", "error"})
        end
    end
end)

AddEventHandler("ems:openCallsMenu", function(player)
    local user_id = vRP.getUserId(player)
    -- --

    if exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
        TriggerClientEvent("ems:showCallsMenu", player, {
            interface = "emsCalls",
            calls = activeCalls,
        })
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if activeCalls[user_id] then
        activeCalls[user_id] = nil
    end
end)

RegisterServerEvent("mechanic:getGasCan")
AddEventHandler("mechanic:getGasCan", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
		TriggerClientEvent("ples-weap:canHave", player)
		vRPclient.giveWeapons(player, {{["WEAPON_PETROLCAN"] = {ammo = 5000}}, false})
		vRPclient.notify(player, {"Ai primit 10L de combustibil"})
	else
		vRPclient.notify(player, {"Nu esti mecanic"})
	end
end)

RegisterServerEvent("mechanic:getRepairKit")
AddEventHandler("mechanic:getRepairKit", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
        if vRP.canCarryItem(user_id, "repairkit", 1) then
            vRP.giveItem(user_id, "repairkit", 1, false, false, false, 'Magazin Mecanic')
        end
    else
		vRPclient.notify(player, {"Nu esti mecanic"})
	end
end)

vRP.defInventoryItem("repairkit", "Repair Kit", "", function(player)
	local user_id = vRP.getUserId(player)
	if exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
		TriggerClientEvent("mechanic:repairClosestCar", player)
	else
		vRPclient.notify(player, {"Nu stii sa folosesti trusa de reparatie", "error"})
	end
end, 0.5)

RegisterServerEvent("mechanic:useRepairKit", function()
    local player = source
    local user_id = vRP.getUserId(player)
    if user_id then
        vRP.removeItem(user_id, "repairkit")
    end
end)
