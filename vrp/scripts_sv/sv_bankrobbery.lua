local robberyTime, robberyCooldown, activeRobbery = 0

local doorsLocked = {
    {coords = vec3(257.10, 220.30, 106.28), objModel = joaat("hei_v_ilev_bk_gate_pris"), h1 = "hei_v_ilev_bk_gate_pris", h2 = "hei_v_ilev_bk_gate_molten", locked = true},
    {coords = vec3(236.91, 227.50, 106.29), objModel = joaat("v_ilev_bk_door"), locked = true},
    {coords = vec3(262.35, 223.00, 107.05), objModel = joaat("hei_v_ilev_bk_gate2_pris"), locked = true},
    {coords = vec3(252.72, 220.95, 101.68), objModel = joaat("hei_v_ilev_bk_safegate_pris"), h1 = "hei_v_ilev_bk_safegate_pris", h2 = "hei_v_ilev_bk_safegate_molten", locked = true},
    {coords = vec3(261.01, 215.01, 101.68), objModel = joaat("hei_v_ilev_bk_safegate_pris"), h1 = "hei_v_ilev_bk_safegate_pris", h2 = "hei_v_ilev_bk_safegate_molten", locked = true},
    {coords = vec3(253.92, 224.56, 101.88), objModel = joaat("v_ilev_bk_vaultdoor"), locked = true}
}

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    TriggerClientEvent("vrp-robbery:updateDoors", -1, doorsLocked)
end)

registerCallback("startBankRobbery", function(player)
    local user_id = vRP.getUserId(player)
    local userFaction = vRP.getUserFaction(user_id)

    local cops = vRP.getUsersByFaction("Politie")

    if not (#cops >= 12) then return false, "Nu sunt destui politisti in oras!" end

    if parseInt(robberyCooldown) >= os.time() then
        return false, "Este cooldown activ, o sa poti da jaf in "..math.floor((robberyCooldown - os.time()) / 60).." minute"
    end

    if not (vRP.getFactionType(userFaction) == "Mafie") then
        return false, "Doar mafiile pot da jaf la aceasta locatie!"
    end

    if not vRP.removeItem(user_id, "proximity_mine", 1) then return false, "Ai nevoie de Bomba Termica" end

    robberyCooldown = os.time() + 21600

    robberyTime = 4
    activeRobbery = userFaction

    vRP.doFactionFunction(activeRobbery, function(src)
        TriggerClientEvent("vrp-robbery:startRobbery", src)
        TriggerClientEvent("vrp-robbery:startTimer", src, robberyTime)
    end)

    TriggerEvent("vrp-wanted:addWanted", 5, "Jaf la Banca")

    Citizen.CreateThread(function()
        while robberyTime > 0 do
            Citizen.Wait(60000)
            robberyTime -= 1
        end

        if not activeRobbery then return end

        Citizen.Wait(1500)

        vRP.doFactionFunction(activeRobbery, function(src)
            TriggerClientEvent("vrp-hud:hint", src, "Usa seifului se inchide! Iesi repede pana nu ramai inauntru!", "Jaf Pacific", "fa-sharp fa-solid fa-vault")
        end)

        Citizen.Wait(2000)

        TriggerClientEvent("vrp-robbery:changeVaultState", -1, true)
        TriggerClientEvent("vrp-robbery:finishRobbery", -1)

        activeRobbery = false

        Citizen.Wait(15000)
        
        for door in next, doorsLocked do
            doorsLocked[door].locked = true
        end

        TriggerClientEvent("vrp-robbery:updateDoors", -1, doorsLocked)
    end)

    return true
end)

registerCallback("canHackTerminal", function(player)
    local user_id = vRP.getUserId(player)
    local userFaction = vRP.getUserFaction(user_id)

    if not (vRP.getFactionType(userFaction) == "Mafie") then
        return false, "Doar mafiile pot da jaf la aceasta locatie!"
    end

    if not vRP.removeItem(user_id, "hacking_device", 1) then return false, "Ai nevoie de un dispozitiv de hacking." end

    return true
end)

registerCallback("canPlantProximity", function(player)
    local user_id = vRP.getUserId(player)
    local userFaction = vRP.getUserFaction(user_id)

    if not (vRP.getFactionType(userFaction) == "Mafie") then
        return false, "Doar mafiile pot da jaf la aceasta locatie!"
    end

    if not vRP.removeItem(user_id, "proximity_mine", 1) then return false, "Ai nevoie de Bomba Termica." end

    return true
end)

RegisterServerEvent("vrp-robbery:changeDoorState", function(door, state)
    local player = source
    local user_id = vRP.getUserId(player)

    if not activeRobbery or not (vRP.getUserFaction(user_id) == activeRobbery) then
        return
    end

    doorsLocked[door].locked = state

    TriggerClientEvent("vrp-robbery:updateDoors", -1, doorsLocked)
end)

RegisterServerEvent("vrp-robbery:openVault", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if not activeRobbery or not (vRP.getUserFaction(user_id) == activeRobbery) then
        return
    end

    TriggerClientEvent("vrp-robbery:changeVaultState", -1)
end)

RegisterServerEvent("vrp-robbery:robberyAlert", function(failed)
    if not activeRobbery or alertedPolice then return end

    alertedPolice = true

    vRP.doFactionFunction("Politie", function(src)
        TriggerClientEvent("vrp:sendNuiMessage", src, {action = "robberyAlert"})
    end)

    if failed then
        robberyTime, activeRobbery = 0

        TriggerClientEvent("vrp-robbery:changeVaultState", -1, true)
        TriggerClientEvent("vrp-robbery:finishRobbery", -1)
        
        activeRobbery = false
                
        for door in next, doorsLocked do
            doorsLocked[door].locked = true
        end
    
        TriggerClientEvent("vrp-robbery:updateDoors", -1, doorsLocked)
    end
end)

RegisterServerEvent("vrp-robbery:tableReward", function(index)
    local player = source
    local user_id = vRP.getUserId(player)
    
    local userFaction = vRP.getUserFaction(user_id)

    if not activeRobbery or not (userFaction == activeRobbery) then
        return vRP.kick(user_id, '[Anticheat] (#5382)')
    end

    local itemCount = GlobalState.propsToSpawn[index]?.amount

    if vRP.giveItem(user_id, "dirty_money", itemCount) then
        vRP.doFactionFunction(userFaction, function(src)
            TriggerClientEvent("vrp-robbery:updateLoot", src)
        end)
    end
end)

--- @description Config

GlobalState.propsToSpawn = {
    {
        grab = 1,
        hash = 269934519,
        coords = vec3(257.44, 215.07, 100.68),
        text = "FURA BANII DE PE MASA #1",
        amount = 800000
    },

    {
        grab = 2,
        hash = 269934519,
        coords = vec3(262.34, 213.28, 100.68),
        text = "FURA BANII DE PE MASA #2",
        amount = 800000
    },

    {
        grab = 3,
        hash = 269934519,
        coords = vec3(263.45, 216.05, 100.68),
        text = "FURA BANII DE PE MASA #3",
        amount = 800000
    },
    
    {
        grab = 4,
        hash = 2007413986,
        emptyObj = 2714348429,
        coords = vec3(266.02, 215.34, 100.68),
        rewardModel = `ch_prop_gold_bar_01a`,
        text = "FURA AURUL",
        amount = 200000
    },

    {
        grab = 5,
        hash = 881130828,
        emptyObj = 2714348429,
        coords = vec3(265.11, 212.05, 100.68),
        rewardModel = `ch_prop_vault_dimaondbox_01a`,
        text = "FURA ARGINTUL",
        amount = 100000
    }
}