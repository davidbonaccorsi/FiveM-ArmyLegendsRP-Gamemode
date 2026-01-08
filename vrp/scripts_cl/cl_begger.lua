
local beggers = {}

RegisterNetEvent("vrp-begger:setBeggers", function(forAll, user_id, tbl)
    if forAll then -- user_id = serverside beggers
        beggers = user_id
        return
    end

    beggers[user_id] = tbl
end)

RegisterNetEvent("vrp-begger:remove", function(user_id)
    if beggers[user_id] then
        beggers[user_id] = nil
    end
end)


Citizen.CreateThread(function()
    local nearBegger, user_id
    AddEventHandler("discord:setUserData", function()
        Citizen.Wait(1100)
        user_id = tonumber(exports.vrp:getMyUserId())
    end)

    while true do

        for k, v in pairs(beggers) do
            local dst = #(v.pos - pedPos)

            while dst <= 5 do
                nearBegger = k

                if dst <= 1.5 and (user_id ~= k) then
                    SetTextFont(0)
                    SetTextCentre(1)
                    SetTextProportional(0)
                    SetTextScale(0.35, 0.35)
                    SetTextDropShadow(30, 5, 5, 5, 255)
                    SetTextEntry("STRING")
                    SetTextColour(255, 255, 255, 255)
                    AddTextComponentString("Apasa ~y~E~w~ pentru a da bani cersetorului")
                    DrawText(0.5, 0.85)

                    if IsControlJustReleased(0, 51) then
                        TriggerServerEvent("vrp-begger:payBegger", nearBegger)
                        Citizen.Wait(100)
                    end
                end

                DrawText3D(v.pos.x, v.pos.y, v.pos.z+0.40, "~g~"..v.text, 0.7)
				DrawMarker(29, v.pos, 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 255, 0, 0, 200, 0, 0, 0, true)

                if not beggers[k] then break end
                dst = #(v.pos - pedPos)
                Citizen.Wait(1)
            end
            nearBegger = nil
        end
    
        if not nearBegger then
            Citizen.Wait(1000)
        end
        Citizen.Wait(1)
    end
end)
