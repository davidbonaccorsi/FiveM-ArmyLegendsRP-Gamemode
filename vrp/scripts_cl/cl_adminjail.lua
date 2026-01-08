
local inAjail = false
local rulesPos = {-473.73126220703,6098.5834960938,29.721248626709}

RegisterNetEvent("vrp-jail:sendCoords")
AddEventHandler("vrp-jail:sendCoords", function(cpData, anim, remainCp)
	if type(cpData) == "table" and type(anim) == "string" then
		tvRP.notify("Mai ai de facut "..remainCp.." checkpoint-uri", "info", "Admin Jail")

		local pos = vec3(table.unpack(cpData))

		local blip = AddBlipForCoord(pos)
	    SetBlipSprite(blip, 271)
	    SetBlipAsShortRange(blip, true)
	    SetBlipScale(blip, 0.6)
	    SetBlipColour(blip, 5)

	    BeginTextCommandSetBlipName("STRING")
	    AddTextComponentString("Admin Jail")
	    EndTextCommandSetBlipName(blip)

	    inAjail = true

		while #(pedPos - pos) > 1.0 and inAjail do
			DrawMarker(20, pos, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 246, 255, 139, 200, 0, 0, 0, 1)
			if IsPedInAnyVehicle(tempPed) then
				local veh = GetVehiclePedIsIn(tempPed)
				DeleteVehicle(veh)
				tvRP.notify("Nu ai voie sa folosesti nici un vehicul !", "error", "Admin Jail")
				Citizen.Wait(1000)
			end
			Citizen.Wait(1)
		end

		if inAjail then
			TaskStartScenarioInPlace(tempPed, anim, 0, true)

			local untilTime = GetGameTimer() + 15000
			FreezeEntityPosition(tempPed, true)
			while GetGameTimer() < untilTime do
				Citizen.Wait(100)
			end
			ClearPedTasks(tempPed)
			RemoveBlip(blip)
			Citizen.Wait(1000)
			FreezeEntityPosition(tempPed, false)

			TriggerServerEvent("vrp-jail:checkCheckpoint", cpData)
		end
	end
end)

function isInAdminJail()
	return inAjail or false
end

local inputActive = false
RegisterNetEvent("vrp-jail:stopWeapons")
AddEventHandler("vrp-jail:stopWeapons", function(status)
	inAjail = status

	if inAjail then
		tvRP.setCanStop(false)
	end

	Citizen.CreateThread(function()
		while inAjail do
			SetEntityHealth(tempPed, 200.0)
			DisableControlAction(0,19,true)
			DisableControlAction(0,21,true)
			DisableControlAction(0,22,true)
			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,37,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,264,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,143,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,44,true)
			DisableControlAction(0,170,true)

			DrawMarker(20, rulesPos[1], rulesPos[2], rulesPos[3], 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 56, 212, 255, 200, 0, 0, 0, 1)

			if GetDistanceBetweenCoords(GetEntityCoords(tempPed), rulesPos[1], rulesPos[2], rulesPos[3], false) < 1.5 then
				if not inputActive then
					inputActive = true
					TriggerEvent("vrp-hud:showBind", {key = "E", text = "Citeste informatii utile"})
				end
				
				if IsControlJustPressed(1, 38) then
					SendNUIMessage({act = "web_redirect", url = "https://armylegends.ro/"})
					TriggerEvent("vrp-hud:showBind", false)
					inputActive = false
					Citizen.Wait(100)
				end
			else
				if inputActive then
					TriggerEvent("vrp-hud:showBind", false)
					inputActive = false
				end
			end

			Citizen.Wait(1)
		end
		tvRP.setCanStop(true)
	end)
	
end)