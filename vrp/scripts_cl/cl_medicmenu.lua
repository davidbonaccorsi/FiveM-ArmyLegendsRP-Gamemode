local modelTarga = 'v_med_bed1'
local modelScaun = 'prop_wheelchair_01'
local currentFocus = "targa"
local nearestObj, isLocalObj
local medicalBeds = {
	GetHashKey('v_med_bed1'),
	GetHashKey('v_med_bed2'),
	GetHashKey('v_med_emptybed'),
}

local function joinObj()
	local ped = tempPed
	local theDict = "anim@gangops@morgue@table@"
	local theAnim = "ko_front"

	if currentFocus == "scaun" then
		theDict = "missfinale_c2leadinoutfin_c_int"
		theAnim = "_leadin_loop2_lester"
	end

	RequestAnimDict(theDict)

	while not HasAnimDictLoaded(theDict) do
		RequestAnimDict(theDict)
		Wait(10)
	end

	if currentFocus == "scaun" then
		AttachEntityToEntity(ped, nearestObj, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
		
		while IsEntityAttachedToEntity(ped, nearestObj) do
			Wait(5)

			if not IsEntityPlayingAnim(ped, theDict, theAnim, 3) then
				TaskPlayAnim(ped, theDict, theAnim, 8.0, 8.0, -1, 69, 1, false, false, false)
			end

			if IsControlJustPressed(0, 73) then
				DetachEntity(nearestObj, true, true)
				ClearPedTasks(ped)
			end
		end

		return
	end

	AttachEntityToEntity(ped, nearestObj, 0, -0.06, 0.1, 1.3, 0.0, 0.0, 179.0, 0.0, false, false, false, false, 2, true)

	while IsEntityAttachedToEntity(ped, nearestObj) do
		Wait(5)
		
		if not IsEntityPlayingAnim(ped, theDict, theAnim, 3) then
			TaskPlayAnim(ped, theDict, theAnim, 8.0, 8.0, -1, 69, 1, false, false, false)
		end
		
		if IsControlJustPressed(0, 73) then
			DetachEntity(nearestObj, true, true)
			ClearPedTasks(ped)
		end
	end
end

local function pickupObj()
	local ped = tempPed
	local theDict = "anim@mp_ferris_wheel"
	local theAnim = "idle_a_player_one"

	if currentFocus == "scaun" then
		theDict = "anim@heists@box_carry@"
		theAnim = "idle"
	end

	RequestAnimDict(theDict)

	while not HasAnimDictLoaded(theDict) do
		RequestAnimDict(theDict)
		Wait(10)
	end

	NetworkRequestControlOfEntity(nearestObj)

	if currentFocus == "scaun" then
		AttachEntityToEntity(nearestObj, ped, GetPedBoneIndex(ped,  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

		while IsEntityAttachedToEntity(nearestObj, ped) do
			Wait(5)

			if not IsEntityPlayingAnim(ped, theDict, theAnim, 3) then
				TaskPlayAnim(ped, theDict, theAnim, 8.0, 8.0, -1, 50, 0, false, false, false)
			end
			
			if IsControlJustPressed(0, 73) then
				DetachEntity(nearestObj, true, true)
				ClearPedTasks(ped)
			end
		end

		return
	end

	AttachEntityToEntity(nearestObj, ped, ped, 0.0, 1.8, -0.40 , 180.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

	while IsEntityAttachedToEntity(nearestObj, ped) do
		Wait(5)

		if not IsEntityPlayingAnim(ped, theDict, theAnim, 3) then
			TaskPlayAnim(ped, theDict, theAnim, 8.0, 8.0, -1, 50, 0, false, false, false)
		end
		
		if IsControlJustPressed(0, 73) then
			DetachEntity(nearestObj, true, true)
			ClearPedTasks(ped)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Wait(1500)

		for _, v in pairs(medicalBeds) do
			local closestObject = GetClosestObjectOfType(pedPos, 1.0, v, false)
			local closestChair = GetClosestObjectOfType(pedPos, 1.0, GetHashKey("prop_wheelchair_01"), false)

			if DoesEntityExist(closestObject) then
				nearestObj = closestObject
				isLocalObj = not NetworkGetEntityIsNetworked(closestObject)
				currentFocus = "targa"
				break
			elseif DoesEntityExist(closestChair) and NetworkGetEntityIsNetworked(closestChair) then
				nearestObj = closestChair
				isLocalObj = false
				currentFocus = "scaun"
				break
			else
				nearestObj = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
    	while nearestObj and not tvRP.isHospitalTreated() do
			local objPos = GetEntityCoords(nearestObj)
			local text = '[~HC_177~E~w~] Ridica~n~[~HC_143~G~w~] Aseaza-te~n~[~HC_28~X~w~] Anuleaza'
			
			if isLocalObj then
				text = '[~HC_143~G~w~] Aseaza-te~n~[~HC_28~X~w~] Ridica-te'
			end

		    if IsControlJustPressed(0, 38) and not isLocalObj then
		      pickupObj()
		    elseif IsControlJustPressed(0, 47) then
		      joinObj()
		    end

		    DrawText3D(objPos.x, objPos.y, objPos.z + 0.5, text, 0.7)
    		Citizen.Wait(1)
    	end

    	Citizen.Wait(2000)
	end
end)

local function spawnChair()
	RequestModel(modelScaun)

	while not HasModelLoaded(modelScaun) do
		RequestModel(modelScaun)
		Wait(10)
	end

	local theObj = CreateObject(GetHashKey(modelScaun), pedPos, true)
	nearestObj = theObj
	isLocalObj = false
	currentFocus = "scaun"

	pickupObj()
end

local function deleteNearest()
	local scaunObj = GetClosestObjectOfType(pedPos, 10.0, GetHashKey(modelScaun))
	local targaObj = GetClosestObjectOfType(pedPos, 10.0, GetHashKey(modelTarga))

	if DoesEntityExist(scaunObj) then
		DeleteEntity(scaunObj)
	elseif DoesEntityExist(targaObj) then
		DeleteEntity(targaObj)
	end
end

RegisterNetEvent("medic:spawnChair", spawnChair)
RegisterNetEvent("medic:deleteNearest", deleteNearest)
