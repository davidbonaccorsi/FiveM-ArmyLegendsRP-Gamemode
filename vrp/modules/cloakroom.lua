local cfg = module("cfg/cloakrooms")
local inCloakroom = {}

RegisterServerEvent("vrp-closets:setUniform")
AddEventHandler("vrp-closets:setUniform", function(uniformId, isMale)
    local player = source
    local ped = GetPlayerPed(player)
    local user_id = vRP.getUserId(player)

    isMale = isMale and 1 or 2

    if uniformId and inCloakroom[user_id] then
        local newUniform = cfg.uniforms[inCloakroom[user_id]][isMale][uniformId] or ""

        if type(newUniform) == "table" then
            TriggerClientEvent("vrp-closets:selectUniform", player, newUniform.rank)

            for index, v in pairs(newUniform.props or {}) do
                if v[1] < 0 then
                    ClearPedProp(ped,index)
                else
                    -- [ped, component, id_prop, textura_prop, attach]
                    SetPedPropIndex(ped,index,v[1],v[2],v[3] or 2)
                end
            end

            for index, v in pairs(newUniform.parts or {}) do
                -- [ped, component, id_haina, textura_haina, paleta_culori]
                SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
            end

        end
    end
end)

RegisterServerEvent("vrp-closets:resetUniform")
AddEventHandler("vrp-closets:resetUniform", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if inCloakroom[user_id] then
        exports["vrp"]:loadCharacter(user_id, player)
    end
end)

RegisterServerEvent("vrp-closets:exitCloset", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if inCloakroom[user_id] then
        inCloakroom[user_id] = nil
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        TriggerClientEvent("vrp-closets:populateClosets", player, cfg.cloakrooms)
    end
end)

RegisterServerEvent("vrp-closets:openMenu")
AddEventHandler("vrp-closets:openMenu", function(theCloset, isMale)
    local player = source
    local user_id = vRP.getUserId(player)
    
    isMale = isMale and 1 or 2

    if theCloset and cfg.uniforms[theCloset] then
        if vRP.isUserInFaction(user_id, cfg.uniforms[theCloset].faction) then
            inCloakroom[user_id] = theCloset
            TriggerClientEvent("vrp-closets:openMenu", player, theCloset, cfg.uniforms[theCloset][isMale])
        end
    end
end)