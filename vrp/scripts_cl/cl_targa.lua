
local strNames = { 'v_med_bed1', 'v_med_bed2','prop_ld_binbag_01'} -- Add more model strings here if you'd like
local strHashes = {}
local animDict = 'missfbi5ig_0'
local animName = 'lyinginpain_loop_steve'
local isOnstr = false
local strTable = {}

Citizen.CreateThread(function()
    for k,v in ipairs(strNames) do
        table.insert( strHashes, GetHashKey(v))
    end
end) 

local function VehicleInFront()
  local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 30, player, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end

local inMana = false

local function PickUp(strObject)
    local closestPlayer = tvRP.getNearestPlayer(2.0)

    if closestPlayer ~= nil then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@heists@box_carry@', 'idle', 3) then
            tvRP.notify("Somebody is already pushing the Stretcher!")
            return
        end
    end

    NetworkRequestControlOfEntity(strObject)

    while not HasAnimDictLoaded("anim@heists@box_carry@") do
        RequestAnimDict("anim@heists@box_carry@")
        Citizen.Wait(1)
    end
    local pedid = PlayerPedId()
    AttachEntityToEntity(strObject, pedid, GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -1.0, -0.4, 0.0, 0.0, -178.0, 0.0, false, false, true, false, 2, true)
    inMana = true
    while IsEntityAttachedToEntity(strObject, pedid) do
        Citizen.Wait(5)

        if not IsEntityPlayingAnim(pedid, 'anim@heists@box_carry@', 'idle', 3) then
            TaskPlayAnim(pedid, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        if IsPedDeadOrDying(pedid) or IsControlJustPressed(0, 73) then
            DetachEntity(strObject, true, true)
            inMana = false
        end
    end
end

local open = false
RegisterNetEvent("ARPF-EMS:opendoors")
AddEventHandler("ARPF-EMS:opendoors", function()
    veh = VehicleInFront()
    if open == false then
        open = true
        SetVehicleDoorOpen(veh, 2, false, false)
        Citizen.Wait(1000)
        SetVehicleDoorOpen(veh, 3, false, false)
    elseif open == true then
        open = false
        SetVehicleDoorShut(veh, 2, false)
        SetVehicleDoorShut(veh, 3, false)
    end
end)

local incar = false

local function StreachertoCar()
    local veh = VehicleInFront()
    local ped = GetPlayerPed(-1)
    local pedCoords = GetEntityCoords(ped)
    local closestObject = GetClosestObjectOfType(pedCoords, 3.0, strHashes[3], false)
    if DoesEntityExist(closestObject) then
        if GetVehiclePedIsIn(ped, false) == 0 and DoesEntityExist(veh) and IsEntityAVehicle(veh) then
            AttachEntityToEntity(closestObject, veh, 0.0, 0.0, -1.5, -1.0, 0.0, 0.0, 90.0, false, false, true, false, 2, true)
            FreezeEntityPosition(closestObject, true)
        else
            print("car dose not exist ")
        end
    else
        print("nothing around here dumb ass")
    end
end

local function StretcheroutCar()
    local veh = VehicleInFront()
    local ped = GetPlayerPed(-1)
    local pedCoords = GetEntityCoords(ped)
    local closestObject = GetClosestObjectOfType(pedCoords, 15.0, strHashes[3], false)
    if DoesEntityExist(closestObject) then
        if GetVehiclePedIsIn(playerPed, false) == 0 and DoesEntityExist(veh) and IsEntityAVehicle(veh) then
            DetachEntity(closestObject, true, true)
            FreezeEntityPosition(closestObject, false)
            local coords = GetEntityCoords(closestObject, false)
            SetEntityCoords(closestObject, coords.x-3,coords.y,coords.z)
            PlaceObjectOnGroundProperly(closestObject)
        else
            print("dosenot exist car")
        end
    else
        print("nothing around here dumb ass")
    end
end

RegisterNetEvent("ARPF-EMS:togglestrincar")
AddEventHandler("ARPF-EMS:togglestrincar", function()
    if not inMana then
    	local veh = VehicleInFront()
        local ped = GetPlayerPed(-1)
        local pedCoords = GetEntityCoords(ped)
        local closestObject = GetClosestObjectOfType(pedCoords, 3.0, strHashes[3], false)
        if IsEntityAttachedToAnyVehicle(closestObject) then
        	incar = true
        elseif IsEntityAttachedToEntity(closestObject, veh) then 
        	incar = true
        end
        if incar == false then 
            StreachertoCar()
            incar = true
        elseif incar == true then
            incar = false
            StretcheroutCar()
        end
    else
        tvRP.notify("Trebuie sa lasi targa jos, apasa X")
    end
end)


-----------------------------------------------------------------------------------------------------------------------
--[[
test sync to server 
attchedStr = {}

if then 
	table.insert('attchedStr',['obj'] = closestObject, ['to'] = veh)
end 
TriggerServerEvent('stretcher:table:update',attchedStr)

ARPF-EMS:stretcherSync
ARPF-EMS:server:stretcherSync

strTable
]]

local theTarga = nil

RegisterNetEvent("ARPF-EMS:spawnstretcher")
AddEventHandler("ARPF-EMS:spawnstretcher", function()
    if not theTarga then
        while not HasModelLoaded('prop_ld_binbag_01') do
            RequestModel('prop_ld_binbag_01')
            Citizen.Wait(1)
        end
        theTarga = CreateObject(GetHashKey('prop_ld_binbag_01'), GetEntityCoords(PlayerPedId()), true)
    else
        if DoesEntityExist(theTarga) then
            for q,d in ipairs(strTable) do
                if d['obj'] == theTarga then
                    local attachedToWhat = GetEntityAttachedTo(theTarga) or "none" 
                    DeleteObject(theTarga)
                    TriggerServerEvent("ARPF-EMS:server:stretcherSync", 3, q, attachedToWhat)
                    break
                end
            end
            if DoesEntityExist(theTarga) then
                DeleteObject(theTarga)
            end
        end
        theTarga = nil
    end
end)

RegisterNetEvent("ARPF-EMS:stretcherSync")
AddEventHandler("ARPF-EMS:stretcherSync", function(tableUpdate)
	strTable = tableUpdate
end)

local changed = false
Citizen.CreateThreadNow(function()
	local wTime = 800
	while true do 
		Citizen.Wait(wTime)
		wTime = 800
		TableID = 0 
		local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local closestObject = GetClosestObjectOfType(pedCoords, 10.0, strHashes[3], false)
        if DoesEntityExist(closestObject) then
        	wTime = 10
            local strCoords = GetEntityCoords(closestObject)
            for i,v in ipairs(strTable) do
			 	local strobj = v['obj']
				if strobj == closestObject then
					TableID = i 
				elseif strobj ~= closestObject and TableID <= 0 then 
					TableID = -1 -- this means that the new stretcher is not in the table and after checking all of the stretches it will then add the new one to the table and then send it to the server to then update all the clients on the server
					print("not the right stretcher")
				end  
			end
			if TableID == -1 then -- add to server table 
				local attachedToWhat = GetEntityAttachedTo(closestObject) and not nil or "none" 
				local state = 2
				local tableNum = -1
				local what = attachedToWhat
				TriggerServerEvent("ARPF-EMS:server:stretcherSync",state,tableNum,what)
			elseif TableID > 0 then -- check if the stretcher has a changed state
			end 

			for k,u in pairs(strTable) do
        		local strobj = strTable[k]['obj']
        		--local strobj = u['obj'] -- one of these are faster 
        		if DoesEntityExist(strobj) then
        		 	local pedCoords = GetEntityCoords(ped)
					local strCoords = GetEntityCoords(closestObject)
					local distances = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, strCoords.x, strCoords.y, strCoords.z, true)
        			local attachedToWhat = GetEntityAttachedTo(strobj) and not nil or "none"
			        if 	distances < 5 then 
			        	if IsEntityAttachedToAnyPed(strobj) or IsEntityAttachedToAnyVehicle(strobj) or IsEntityAttachedToAnyObject(strobj) then 
							if attachedToWhat ~= v['to'] then -- even if somehow v['to'] == nil then it will change to "none"
								v['to'] = attachedToWhat
								local changed = true
							end
						else
							if attachedToWhat == v['to'] then 
								local change = false
							else 
								print(attachedToWhat)
								print("this fucked up if it gets here and nothing is shown")
							end
						end
					end
	        	else
	        	-- insert deleting into the deleting command TriggerServerEvent("ARPF-EMS:server:stretcherSync",state,tableNum,what,sync)	
	        	end
        	end  
        end
	end
end)

RegisterNetEvent("ARPF-EMS:pushstreacherss")
AddEventHandler("ARPF-EMS:pushstreacherss", function()
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local closestObject = GetClosestObjectOfType(pedCoords, 3.0, strHashes[3], false)
        if DoesEntityExist(closestObject) then
            local strCoords = GetEntityCoords(closestObject)
            local strVecForward = GetEntityForwardVector(closestObject)
            local sitCoords = (strCoords + strVecForward * - 0.5)
            local pickupCoords = (strCoords + strVecForward * 0.3)
            if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 2.0 then
                PickUp(closestObject)
            end
        end 
end)


RegisterNetEvent("ARPF-EMS:getintostretcher")
AddEventHandler("ARPF-EMS:getintostretcher", function()
 local pP = GetPlayerPed(-1)
 local ped = PlayerPedId()
 local pedCoords = GetEntityCoords(ped)
 local closestObject = GetClosestObjectOfType(pedCoords, 10.0, strHashes[3], false)
    if DoesEntityExist(closestObject) then
     local strCoords = GetEntityCoords(closestObject)
     local strVecForward = GetEntityForwardVector(closestObject)
     local sitCoords = (strCoords + strVecForward * - 0.5)
     local pickupCoords = (strCoords + strVecForward * 0.3)
        if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 2.0 then
            TriggerEvent('sit', closestObject) 
        end
    end
end)


function revivePed(ped)
  local playerPos = GetEntityCoords(ped, true)

  NetworkResurrectLocalPlayer(playerPos, true, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)
end

-- Anim Taken from bed script from FFourms
local inBedDicts = "anim@gangops@morgue@table@"
local inBedAnims = "ko_front"
RegisterNetEvent('sit')
AddEventHandler('sit', function(strObject)
    local closestPlayer = tvRP.getNearestPlayer(2.0)
    local playPed = GetPlayerPed(-1)
    if closestPlayer ~= nil then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), inBedDicts, inBedAnims, 3) then
            tvRP.notify("Somebody is already using the Stretcher!")
            return
        end
    end
    while not HasAnimDictLoaded(inBedDicts) do
        RequestAnimDict(inBedDicts)
        Citizen.Wait(1)
    end
    
    if IsPedDeadOrDying(playPed) then
        revivePed(playPed)
        wasdead = true
    else
        wasdead = false
    end

    local heading = GetEntityHeading(strObject)
    AttachEntityToEntity(PlayerPedId(), strObject, 0, 0, 0.0, 1.1, 0.0, 0.0, 178.0, 0.0, false, false, false, false, 2, true)
    while IsEntityAttachedToEntity(PlayerPedId(), strObject) do
        Citizen.Wait(5)

        if IsPedDeadOrDying(PlayerPedId()) then
            DetachEntity(PlayerPedId(), true, true)
        end

        if not IsEntityPlayingAnim(PlayerPedId(), inBedDicts, inBedAnims, 3) then
            TaskPlayAnim(PlayerPedId(), inBedDicts, inBedAnims, 8.0, 8.0, -1, 69, 1, false, false, false)
        end

        if IsControlPressed(0, 32) then
            PlaceObjectOnGroundProperly(strObject)
        elseif IsControlJustPressed(0, 73) then
            TriggerEvent("unsit", strObject)
        end
    end 
end)


RegisterNetEvent('unsit')
AddEventHandler('unsit', function(strObject)   
    if wasdead == true then
        pedss = GetPlayerPed(-1)
        DetachEntity(PlayerPedId(), true, true)
        local x, y, z = table.unpack(GetEntityCoords(strObject) + GetEntityForwardVector(strObject) * - 0.7)
        SetEntityCoords(PlayerPedId(), x,y,z)
        hels = GetEntityHealth(pedss)
        SetEntityHealth(pedss, hels -200)
        wasdead = false
    elseif wasdead == false then
        DetachEntity(PlayerPedId(), true, true)
        local x, y, z = table.unpack(GetEntityCoords(strObject) + GetEntityForwardVector(strObject) * - 0.7)
        SetEntityCoords(PlayerPedId(), x,y,z)
    end
end)

