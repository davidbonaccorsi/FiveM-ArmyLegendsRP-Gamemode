local wantedPlayers = {}
local isCop = false;

AddEventHandler('vrp:playerJoinFaction', function(faction)
    isCop = faction == "Politie" 

    Citizen.CreateThread(function()
        while isCop do
            for playerId, data in pairs(wantedPlayers) do
                local wlevel = #data;
                local player = GetPlayerFromServerId(playerId)
                if NetworkIsPlayerActive(player) then
                    local ped = GetPlayerPed(player)
                    local blip = GetBlipFromEntity(ped)

                    if not DoesBlipExist(blip) then
                        blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
						ShowHeadingIndicatorOnBlip(blip, 1)
						ShowNumberOnBlip(blip, wlevel)
						SetBlipColour(blip, 2)
						SetBlipAsFriendly(blip, false)
                    else
                        local blipSprite = GetBlipSprite(blip)
						if GetEntityHealth(ped) <= 110 then
							if not (blipSprite == 274) then
								SetBlipSprite(blip, 274)
								ShowHeadingIndicatorOnBlip(blip, 0)
							end
						else
							if not (blipSprite == 1) then
								SetBlipSprite(blip, 1)
								SetBlipColour(blip, 2)
								SetBlipAsFriendly(blip, false)
								ShowHeadingIndicatorOnBlip(blip, 1)
							end
						end
                    end

                    ShowNumberOnBlip(blip, wlevel)
					SetBlipRotation(blip, math.ceil( GetEntityHeading(ped) ) )
					SetBlipNameToPlayerName(blip, player)
					SetBlipScale(blip, 0.6)
					SetBlipAlpha(blip, 255)
                end
            end
            Wait(1)
        end
    end)
end)

RegisterNetEvent('vrp-wanted:updatePlayers', function(playerId, data)
    if not data or #data < 1 then
        wantedPlayers[playerId] = nil
        local player = GetPlayerFromServerId(playerId)
        local ped = GetPlayerPed(player)
        local blip = GetBlipFromEntity(ped)
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    else
        wantedPlayers[playerId] = data;
    end
end)