
local rematPos = vector3(-424.06857299804,-1711.6420898438,19.291410446166)

local function drawText(text, x, y, scale, r, g, b)
	SetTextFont(0)
	SetTextCentre(1)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextDropShadow(30, 5, 5, 5, 255)
	SetTextEntry("STRING")
	SetTextColour(r, g, b, 255)
	AddTextComponentString(text)
	DrawText(x, y)
end

local blip = AddBlipForCoord(rematPos)
SetBlipSprite(blip, 380)
SetBlipColour(blip, 49)
SetBlipAsShortRange(blip, true)
SetBlipScale(blip, 0.6)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Remat Masini")
EndTextCommandSetBlipName(blip)

Citizen.CreateThread(function()
    while true do

        local dst = #(pedPos - rematPos)
        
        while dst <= 10 do

            
            DrawText3D(rematPos[1], rematPos[2], rematPos[3]-0.25, "Rameaza Masina", 1.0)
            DrawMarker(27, rematPos[1], rematPos[2], rematPos[3]-0.9, 0, 0, 0, 0, 0, 0, 1.601, 1.601, 0.6001, 224, 58, 58, 100, 0, 0, 0, 1)

            if dst <= 5 then
                if not (playerVehicle == 0) then

                    drawText("Apasa ~HC_28~ENTER~w~ sa rameazi masina pe care o conduci !~n~Merg doar masinile personale", 0.5, 0.85, 0.4, 255, 255, 255)
                    if IsControlJustPressed(0, 191) then
                        TriggerServerEvent("vrp-garages:rematOwned") 
                        break
                    end

                end
            end
            
            dst = #(pedPos - rematPos)
            Citizen.Wait(1)
        end

        Citizen.Wait(1000)
    end
end)