local blipsActive = false
local playerGamerTags = {}
local playerIds = {}

local weapons = {}

local distance = 150
local gamerTagCompsEnum = {
    GamerName = 0,
    CrewTag = 1,
    HealthArmour = 2,
    BigText = 3,
    AudioIcon = 4,
    UsingMenu = 5,
    PassiveMode = 6,
    WantedStars = 7,
    Driver = 8,
    CoDriver = 9,
    Tagged = 12,
    GamerNameNearby = 13,
    Arrow = 14,
    Packages = 15,
    InvIfPedIsFollowing = 16,
    RankText = 17,
    Typing = 18
}

local function cleanupGamerTags()
    for _, v in pairs(playerGamerTags) do
        if IsMpGamerTagActive(v.gamerTag) then
            RemoveMpGamerTag(v.gamerTag)
        end
    end
    playerGamerTags = {}
end

RegisterNetEvent("vrp:adminBlips", function(toggle, radius)
    blipsActive = toggle
    distance = radius or 150

    if not blipsActive then
       return cleanupGamerTags()
    end

    while blipsActive do
        local curCoords = GetEntityCoords(PlayerPedId())
        -- Per infinity this will only return players within 300m
        local allActivePlayers = GetActivePlayers()


        for _, i in ipairs(allActivePlayers) do
            local src = GetPlayerServerId(i)
            local targetPed = GetPlayerPed(i)
            local uData = playerIds[src]
            if uData and not (targetPed == tempPed) then
                local playerStr = '[ID: '..uData.id..'] '.. ' ' .. GetPlayerName(i)
    
                -- If we have not yet indexed this player or their tag has somehow dissapeared (pause, etc)
                if not playerGamerTags[i] or not IsMpGamerTagActive(playerGamerTags[i].gamerTag) then
                    playerGamerTags[i] = {
                        gamerTag = CreateFakeMpGamerTag(targetPed, playerStr, false, false, 0),
                        ped = targetPed
                    }
                end
        
                local targetTag = playerGamerTags[i].gamerTag

                SetMpGamerTagsVisibleDistance((distance * 10) + 0.0)
                -- Setup name
                SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.GamerName, 1)
                -- Setup AudioIcon
                SetMpGamerTagAlpha(targetTag, gamerTagCompsEnum.AudioIcon, 255)
                -- Set audio to red when player is talking
                SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.AudioIcon, NetworkIsPlayerTalking(i))
                -- Setup Health
                SetMpGamerTagHealthBarColor(targetTag, 129)
                SetMpGamerTagAlpha(targetTag, gamerTagCompsEnum.HealthArmour, 255)
                SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.HealthArmour, 1)
    
                if IsPedInAnyVehicle(targetPed) then
                    -- Set if player is driving a vehicle
                    SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.Driver, (GetPedInVehicleSeat(GetVehiclePedIsIn(targetPed, false), -1) == targetPed))
                    -- Set if player is CoDriver in a vehicle
                    SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.CoDriver, (GetPedInVehicleSeat(GetVehiclePedIsIn(targetPed, false), 0) == targetPed))
                else
                    -- Set if player is driving a vehicle
                    SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.Driver, 0)
                    -- Set if player is CoDriver in a vehicle
                    SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.CoDriver, 0)
                end

                local x, y, z = table.unpack(GetEntityCoords(targetPed))
                local weapon = GetSelectedPedWeapon(targetPed)
                if weapon and weapons[weapon] then
                    DrawText3D(x + 0.05, y, z-0.7, weapons[weapon], 0.45)
                end
            end
        end
        Wait(1)
    end
end)

Citizen.CreateThread(function()
    local types = exports.vrp:getWeaponTypes()

    for k, v in pairs(types) do
        weapons[GetHashKey(v)] = v
    end
end)

AddEventHandler("id:initPlayer", function(src, uid)
	playerIds[src] = {id = uid}
end)

AddEventHandler("id:removePlayer", function(src)
	playerIds[src] = nil
end)