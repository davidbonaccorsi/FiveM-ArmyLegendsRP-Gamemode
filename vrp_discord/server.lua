local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_discord")

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        local cfg = getDiscordConfig()
        local user_id = vRP.getUserId({source})
        local id = parseInt(user_id)
        local faivem = nil
        local faction1 = vRP.getUserFaction({user_id})
        local adminrank = vRP.getUserAdminLevel({user_id})
        -- print('test sef')

        for k,v in pairs(cfg.grade_discord) do
            print(v, k)
            if exports.vrp:IsRolePresent(source, v.discord) and v.type == "Staff" then
                vRP.setUserAdminLevel({user_id, v.rank})
            elseif adminrank >= 1 and not exports.vrp:IsRolePresent(source, v.discord) then
                vRP.setUserAdminLevel({user_id, 0})
            end

            if exports.vrp:IsRolePresent(source, v.discord) and v.type == "Faction" then
                vRP.addUserFaction({user_id, v.faction})
            -- elseif faction1 == v.faction and not exports.vrp:IsRolePresent(source, v.discord) then
            --     vRP.removeUserFaction({user_id, v.faction, 0})
            end

            if exports.vrp:IsRolePresent(source, v.discord) and v.type == "Grade" then
                vRP.addUserGroup({id, v.group})
            elseif vRP.hasGroup({user_id,v.group}) and not exports.vrp:IsRolePresent(source, v.discord) then
                vRP.removeUserGroup({id, v.group})
            end

            -- if exports.vrp:IsRolePresent(source, v.discord) and v.type == "vip" then
            --     vRP.setUserVip(user_id, v.vipLvl)
            -- elseif vRP.hasGroup({user_id,v.group}) and not exports.vrp:IsRolePresent(source, v.discord) then
            --     vRP.setUserVip(user_id, 0)
            -- end
        end
    end
end)