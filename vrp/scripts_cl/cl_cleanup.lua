local enumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function getEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
    
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, enumerator)
    
		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next
  
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

local isCanceled = false
RegisterNetEvent("vrp-cleanup:cancelDellAllVehs")
AddEventHandler("vrp-cleanup:cancelDellAllVehs", function()
	isCanceled = true
end)

local function deleteAllVehs(theTime)
	TriggerEvent("adminMessage", "Server", "Atentie! Toate masinile neocupate vor fi sterse in "..theTime.." secunde, va rugam sa va indreptati catre vehicule in cel mai scurt timp posibil pentru a evita pierderea acestora.")

	isCanceled = false
	SetTimeout(theTime * 1000, function()
		if not isCanceled then
			theVehicles = getEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
			TriggerEvent("adminMessage", "Server", "Toate masinile neocupate au fost sterse cu succes.")
			for entity in theVehicles do
				local veh = entity
				NetworkRequestControlOfEntity(veh)

				local timeout = 2000
				while timeout > 0 and not NetworkHasControlOfEntity(veh) do
	    			Wait(100)
	    			timeout = timeout - 100
				end

				SetEntityAsMissionEntity(veh, true, true)

				local timeout = 2000
				while timeout > 0 and not IsEntityAMissionEntity(veh) do
	    			Wait(100)
	    			timeout = timeout - 100
				end

				if DoesEntityExist(veh) then 
					if GetEntityModel(veh) ~= GetHashKey("rubble") then

						if not IsEntityAttached(veh) then
							if((GetPedInVehicleSeat(veh, -1)) == false) or ((GetPedInVehicleSeat(veh, -1)) == nil) or ((GetPedInVehicleSeat(veh, -1)) == 0)then
								Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( veh ) )
						
								if (DoesEntityExist(veh)) then
									DeleteEntity(veh)
								end
							end
						end

					end
				end
			end
		end
	end)
end

RegisterNetEvent("vrp-cleanup:delAllVehs")
AddEventHandler("vrp-cleanup:delAllVehs", function(sec)
	deleteAllVehs(sec)
end)