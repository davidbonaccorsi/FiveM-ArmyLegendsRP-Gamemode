local canPush = true
local isResting = false
local isPushing = false

local powerVehs = {
	[10] = "Industrial",
	[15] = "Helicopters",
	[16] = "Planes",
	[19] = "Military",
	[21] = "Trains",
}

CreateThread(function()
	while true do
		local vehInFront = tvRP.getVehicleInFront()
		
		if vehInFront ~= 0 then
			local vehDimensions = GetModelDimensions(GetEntityModel(vehInFront), vec3(0.0, 0.0, 0.0), vec3(5.0, 5.0, 5.0))
			local vehPos = GetEntityCoords(vehInFront)
			local vehClass = GetVehicleClass(vehInFront)
			local isInFront = true

			local realVector = vector3(GetEntityForwardX(vehInFront), GetEntityForwardY(vehInFront), 0)
			if #((vehPos + realVector) - pedPos) > #((vehPos + (realVector * -1)) - pedPos) then
				isInFront = false
			end

			if powerVehs[vehClass] or (GetEntityModel(vehInFront) == `metrotrain`) then
				canPush = false
			end

			while #(vehPos - pedPos) <= 3.5 and IsVehicleSeatFree(vehInFront, -1) and (playerVehicle == 0) and ((GetVehicleEngineHealth(vehInFront) <= 100.0) or GetVehicleFuelLevel(vehInFront) < 5) and not tvRP.isInComa() do				
				DrawText3D(vehPos.x, vehPos.y, vehPos.z, "Apasa [~b~SHIFT~w~] + [~b~E~w~] - Impinge masina", 0.5)

				if IsControlPressed(0, 21) and IsControlJustPressed(0, 51) and not IsEntityAttachedToEntity(tempPed, vehInFront) then
					if not canPush then
						tvRP.notify("Nu ai destula putere pentru a impinge acest vehicul!", "error")
					elseif not isResting then
						NetworkRequestControlOfEntity(vehInFront)

						while not NetworkHasControlOfEntity(vehInFront) do
							Wait(1)
						end

						if isInFront then
                    		AttachEntityToEntity(tempPed, vehInFront, -1, 0.0, vehDimensions.y * -1 + 0.1 , vehDimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
						else
							AttachEntityToEntity(tempPed, vehInFront, -1, 0.0, vehDimensions.y - 0.3, vehDimensions.z + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
						end

                    	isPushing = true
                    	local expTime = GetGameTimer() + 30000
                    	
                    	CreateThread(function()
                    		while expTime > GetGameTimer() do
                    			if not isPushing then
                    				break
                    			end

                    			Wait(1)
                    		end

                    		if isPushing then
                    			isResting = true
                    		end
                    	end)

		                loadAnimDict('missfinale_c2ig_11')
		                TaskPlayAnim(tempPed, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
		                Wait(200)

		                while isPushing do
		                	vehPos = GetEntityCoords(vehInFront)

			                if IsDisabledControlPressed(0, 34) then
			                    TaskVehicleTempAction(tempPed, vehInFront, 11, 1000)
			                end

			                if IsDisabledControlPressed(0, 9) then
			                    TaskVehicleTempAction(tempPed, vehInFront, 10, 1000)
			                end

			                if isInFront then
			                    SetVehicleForwardSpeed(vehInFront, -1.0)
			                else
			                    SetVehicleForwardSpeed(vehInFront, 1.0)
			                end

			                if HasEntityCollidedWithAnything(vehInFront) then
			                    SetVehicleOnGroundProperly(vehInFront)
			                end

			                if not IsDisabledControlPressed(0, 51) then
			                    DetachEntity(tempPed, false, false)
			                    StopAnimTask(tempPed, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
			                    FreezeEntityPosition(tempPed, false)
								isPushing = false
							elseif isResting then
			                    DetachEntity(tempPed, false, false)
			                    StopAnimTask(tempPed, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
			                    FreezeEntityPosition(tempPed, false)
								tvRP.notify("Ai obosit prea tare, trebuie sa te odihnesti pentru a impinge iar!", "warning")
								
								CreateThread(function()
									Wait(30000)
									isResting = false
								end)

								isPushing = false
			                end
							
		                	Wait(5)
		                end
		            else
		            	tvRP.notify("Esti prea obosit pentru a impinge acest vehicul, odihneste-te!", "error")
					end
				end

				Wait(1)
			end

		end

		Wait(1000)
	end
end)