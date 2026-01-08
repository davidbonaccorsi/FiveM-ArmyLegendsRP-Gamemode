local secondsUntilKick = 1200
local kickPass = false
RegisterNetEvent("afk-kick:passAutoKick")
AddEventHandler("afk-kick:passAutoKick", function(bool)
	kickPass = bool
end)


Citizen.CreateThread(function()
	local prevPos
	local time = secondsUntilKick
	
	RegisterNetEvent("afk-kick:setPrime", function(amm)
		secondsUntilKick = amm;
		time = amm;
	end)
	
	while true do
		Citizen.Wait(5000)

		if not kickPass then
			if tempPed then
				local currentPos = GetEntityCoords(tempPed, true)

				if Vdist2(currentPos, prevPos) < 10 and not NetworkIsPlayerTalking(GPLAYER) then
					if time > 0 then
						if time == 120 then
							TriggerServerEvent("chatForKick")
						end

						time = time - 5
					else
						TriggerServerEvent("kickForBeingAnAFKDouchebag")
					end
				else
					time = secondsUntilKick
				end

				prevPos = currentPos
			end
		end
	end
end)