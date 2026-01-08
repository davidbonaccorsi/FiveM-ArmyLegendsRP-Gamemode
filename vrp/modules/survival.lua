RegisterServerEvent("survival:togShow", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if player and user_id then  
        TriggerClientEvent("vrp:sendNuiMessage", player, {
            interface = "survival",
            hunger = vRP.getHunger(user_id),
            thirst = vRP.getThirst(user_id),
        })
    end
end)

local function task_vary()
    for user_id, data in pairs(vRP.usersData) do
        if not data.survival then goto continue end
  
        data.survival.hunger = math.max(0, (data.survival.hunger - math.random(1, 5)))
        data.survival.thirst = math.max(0, (data.survival.thirst - math.random(1, 5)))

        local target_src = vRP.getUserSource(user_id)
        
        if target_src then
            if data.survival.hunger < 20 then
                TriggerClientEvent("vrp-hud:hint", target_src, "Iti este foame, grabeste-te sa mananci ceva!", "Mancare si apa", "fa-solid fa-burger-soda")
            end
        
            if data.survival.thirst < 25 then
                TriggerClientEvent("vrp-hud:hint", target_src, "Iti este sete, grabeste-te sa bei ceva!", "Mancare si apa", "fa-solid fa-burger-soda")
            end

            if data.survival.thirst == 0 or data.survival.thirst == 0 then
                vRPclient.varyHealth(target_src, {-10})
            end

            -- TriggerClientEvent("vrp:sendNuiMessage", target_src, {
            --     interface = "survival",
            --     hunger = data.survival.hunger,
            --     thirst = data.survival.thirst,
            -- })
        end

        ::continue::
    end

    SetTimeout(600000, task_vary)
end 

task_vary()

function vRP.getHunger(user_id)
    local user = vRP.getUser(user_id)
    
    if user.survival then
        return math.min(user.survival.hunger, 100)
    end

    return 100
end

function vRP.getThirst(user_id)
    local user = vRP.getUser(user_id)
    
    if user.survival then
        return math.min(user.survival.thirst, 100)
    end

    return 100
end

function vRP.setHunger(user_id,value)
    local user = vRP.getUser(user_id)
    
    if user.survival then
        user.survival.hunger = value
    end
end

function vRP.setThirst(user_id,value)
    local user = vRP.getUser(user_id)
    
    if user.survival then
        user.survival.thirst = value
    end
end

function vRP.varyHunger(user_id, variation)
    local user = vRP.getUser(user_id)

    if user.survival then
        user.survival.hunger += variation

        local player = vRP.getUserSource(user_id)
        if player then
            TriggerClientEvent("vrp:sendNuiMessage", player, {
                interface = "survival",
                hunger = user.survival.hunger,
                thirst = user.survival.thirst,
            })

            if user.survival.hunger > 100 then
                user.survival.hunger = 100
                vRPclient.notify(player, {"Nu mai poti manca."})
            end
        end
    end
end

function vRP.varyThirst(user_id, variation)
    local user = vRP.getUser(user_id)

    if user.survival then
        user.survival.thirst += variation

        local player = vRP.getUserSource(user_id)
        if player then
            TriggerClientEvent("vrp:sendNuiMessage", player, {
                interface = "survival",
                hunger = user.survival.hunger,
                thirst = user.survival.thirst,
            })

            if user.survival.thirst > 100 then
                user.survival.thirst = 100
                vRPclient.notify(player, {"Nu mai poti bea."})
            end
        end
    end
end

function vRP.addThirst(user_id, variation)
    local user = vRP.getUser(user_id)
    if user.survival then
        user.survival.thirst -= variation

        local player = vRP.getUserSource(user_id)

        if player then
            TriggerClientEvent("vrp:sendNuiMessage", player, {
                interface = "survival",
                hunger = user.survival.hunger,
                thirst = user.survival.thirst,
            })
        end

        if player and user.survival.thirst < 25 then
            TriggerClientEvent("vrp-hud:hint", player, "Iti este sete, grabeste-te sa bei ceva!", "Mancare si apa", "fa-solid fa-burger-soda")
        end
        
        if user.survival.thirst < 0 then
            user.survival.thirst = 0
        end
    end
end

function vRP.maxPlayerSurvival(user_id)
    local user = vRP.getUser(user_id)

    if user.survival then
        vRP.setHunger(user_id,100)
        vRP.setThirst(user_id,100)

        Citizen.CreateThread(function()
            Citizen.Wait(100)
            vRP.updateUser(user_id, "survival", user.survival)
        end)
    end
end

function vRP.addFoodPoising(user_id, player)
    vRP.updateUser(user_id, "foodPoising", true)
    TriggerClientEvent('vrp-survival:foodPoising', player, true)
end

function vRP.removeFoodPoising(user_id, player)
    if vRP.usersData[user_id] and vRP.usersData[user_id].foodPoising then
        vRP.updateUser(user_id, "foodPoising")
    end
    TriggerClientEvent('vrp-survival:foodPoising', player, false)
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn, dbdata)
    if first_spawn then
        local user = vRP.getUser(user_id)

        if not dbdata.survival then
            user.survival = {hunger = 100, thirst = 100}
        end
    end

    vRP.removeFoodPoising(user_id, source)
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    local user = vRP.getUser(user_id)

    if user then
        vRP.updateUser(user_id, "survival", user.survival)
    end
end)