
local beggers = {}

local anim = {"anim@amb@nightclub@lazlow@lo_alone@", "lowalone_base_laz"}

local function isAnyBeggerNear(pos)
    local any = false
    for k, v in pairs(beggers) do
        if #(pos - v.pos) <= 5 then
            any = true
            break
        end
    end

    return any
end

local deniedAreas <const> = {
    {vector3(-42.759887695312,-1094.1492919922,27.274343490601),30,"Dealership"},
    {vector3(450.03936767578,-992.50994873047,30.724315643311),40,"Politie Oras"},
    {vector3(312.97171020508,-582.74847412109,43.267612457275),35,"Spital Oras"},
    {vector3(-1080.6009521484,-249.85322570801,37.763305664062),30,"Life Invader"},
    {vector3(374.02630615234,326.81622314453,103.56641387939),20,"Magazin Electronice"},
}

local function isInAllowedArea(player)
    local playerPed = GetPlayerPed(player)
    local pedPos = GetEntityCoords(playerPed)

    for k,v in pairs(deniedAreas) do
        if #(pedPos - v[1]) <= v[2] then
            return false
        end
    end
    return true
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        TriggerClientEvent("vrp-begger:setBeggers", player, true, beggers)
    end
end)

local function cancelBegging(player, user_id)
    vRPclient.setCanStop(player, {true})
    vRPclient.executeCommand(player, {"e c"})

    beggers[user_id] = nil
    TriggerClientEvent("vrp-begger:remove", -1, user_id)
end

AddEventHandler("vRP:playerLeave", function(uid)
    if beggers[uid] then
        beggers[uid] = nil
        TriggerClientEvent("vrp-begger:remove", -1, uid)
    end
end)

RegisterServerEvent("vrp-begger:payBegger", function(target_id)
    local player = source
    local user_id = vRP.getUserId(player)

    if target_id and beggers[target_id] then
        vRP.prompt(player, "Cersetor", "Suma de bani:", false, function(amount)
            amount = tonumber(amount)

            if amount and amount > 0 then
                local target_src = vRP.getUserSource(target_id)

                if vRP.tryPayment(user_id, amount, true, "Begger ("..target_id..")") then
                    vRP.giveMoney(target_id, amount)
                    vRPclient.notify(target_src, {"Ai primit $"..vRP.formatMoney(amount).." de la "..GetPlayerName(player), "success"})
                end
            end
        end)
    end
end)

vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        -- build begger menu
        choices["Cerseste"] = {function(player, choice)
            local ped = GetPlayerPed(player)
            local pedPos = GetEntityCoords(ped)

            if not isInAllowedArea(player) then
                return vRPclient.notify(player, {"Nu poti cersi aici.", "error"})
            end
            
            if not beggers[user_id] then

                if not isAnyBeggerNear(pedPos) then
                    vRP.prompt(player, "Cerseste", "Mesaj:", false, function(message)
                        if not message then
                            vRPclient.notify(player, {"Trebuie sa scrii un mesaj.", "error"})
                            return
                        end

                        vRPclient.getOffsetPosition(player, {0.0, 1.25, -0.5}, function(pos)
                            beggers[user_id] = {
                                pos = pos,
                                text = message,
                            }
        
                            vRPclient.executeCommand(player, {"e sit7"})
                            vRPclient.executeCommand(player, {"e beg"})
                            vRPclient.setCanStop(player, {false})
        
                            TriggerClientEvent("vrp-begger:setBeggers", -1, false, user_id, beggers[user_id])
                        end)
                    end)
                else
                    vRPclient.notify(player, {"Cineva cerseste deja aici.", "error"})
                end
            else
                cancelBegging(player, user_id)
            end
        end, '<i class="fa-duotone fa-face-pleading"></i>', "Cerseste bani de la jucatori."}

        add(choices)
    end
end)