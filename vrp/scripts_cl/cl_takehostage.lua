local takeHostage = {
	weaponGroups = {
		-- "WEAPON_PISTOL",
		-- "WEAPON_PISTOL50",
		-- "WEAPON_COMBATPISTOL",
		-- "WEAPON_VINTAGEPISTOL",
		-- "WEAPON_DOUBLEACTION",
		-- "WEAPON_PISTOL_MK2",
		-- "WEAPON_KNIFE",
		-- "WWEAPON_BOTTLE",
		-- "WEAPON_SWITCHBLADE",
		-- "WEAPON_DAGGER",
		-- "WEAPON_MACHINEPISTOL",
		-- "WEAPON_GADGETPISTOL",
		-- "WEAPON_NAVYREVOLVER",
		[416676503] = true,
		[-72855502] = true,
		[-957766203] = true,
	},

	InProgress = false,
	type = "",
	targetSrc = -1,
	targetPed = -1,
	agressor = {
		animDict = "anim@gangops@hostage@",
		anim = "perp_idle",
		flag = 49,
	},
	
	hostage = {
		animDict = "anim@gangops@hostage@",
		anim = "victim_idle",
		attachX = -0.24,
		attachY = 0.11,
		attachZ = 0.0,
		flag = 49,
	}
}

-- local foundWeap = false
local function checkIfHostage(oRadius)
    local players = GetActivePlayers()
    local cDist = -1
    local closestPlayer = -1
    local closestPed = -1
    local playerPed = tempPed
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            
            if cDist == -1 or cDist > distance then
                closestPlayer = playerId
                closestPed = targetPed
                cDist = distance
            end
        end
    end

	if IsPedInAnyVehicle(closestPed, true) then
		return nil
	end

	if cDist ~= -1 and cDist <= oRadius then
		return closestPlayer, closestPed
	end

	return nil
end

RegisterCommand("th", function()
	initOstatic()
end)

local function hostageFuncs()
	while takeHostage.type do 
		local HostageTaken = false

		if takeHostage.type == "agressor" then
			HostageTaken = true
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,21,true) -- disable sprint
			DisablePlayerFiring(tempPed, true)

			local hostageCds = GetEntityCoords(takeHostage.targetPed)
			DrawText3D(hostageCds.x, hostageCds.y, hostageCds.z + 0.250, "~b~G ~w~- Elibereaza~n~~HC_28~H ~w~- Ucide ostatic", 0.8)

			if IsEntityDead(tempPed) then	
				takeHostage.type = false
				takeHostage.InProgress = false
				loadAnimDict("reaction@shove")
				TaskPlayAnim(tempPed, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("takeHostage:releaseHostage", takeHostage.targetSrc)
			end 

			if IsDisabledControlJustPressed(0,47) then --release	
				takeHostage.type = false
				takeHostage.InProgress = false 
				loadAnimDict("reaction@shove")
				TaskPlayAnim(tempPed, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("takeHostage:releaseHostage", takeHostage.targetSrc)
			elseif IsDisabledControlJustPressed(0,74) then --kill 			
				takeHostage.type = false
				takeHostage.InProgress = false 		
				loadAnimDict("anim@gangops@hostage@")
				TaskPlayAnim(tempPed, "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("takeHostage:killHostage", takeHostage.targetSrc)
				TriggerServerEvent("takeHostage:stop",takeHostage.targetSrc)
				Wait(100)
				SetPedShootsAtCoord(tempPed, 0.0, 0.0, 0.0, 0)
			end
		elseif takeHostage.type == "hostage" then 
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		end

		if takeHostage.type == "agressor" then
			if not IsEntityPlayingAnim(tempPed, takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				TaskPlayAnim(tempPed, takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			end
		elseif takeHostage.type == "hostage" then
			if not IsEntityPlayingAnim(tempPed, takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				TaskPlayAnim(tempPed, takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			end
		end
		
		Wait(1)
	end
end

function initOstatic()
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)

	local canTakeHostage = false
	local selectedWeapon = GetSelectedPedWeapon(tempPed)
	local weaponGroup = GetWeapontypeGroup(selectedWeapon)

	if takeHostage.weaponGroups[weaponGroup] then
		canTakeHostage = true
	end

	-- for _, theWeap in pairs(takeHostage.allowedWeapons) do
	-- 	if HasPedGotWeapon(tempPed, theWeap, false) then
	-- 		canTakeHostage = true 
	-- 		foundWeap = theWeap
	-- 		break
	-- 	end
	-- end

	if not canTakeHostage then 
		tvRP.notify("Ai nevoie de o arma pentru a lua un ostatic!", "error")
		return
	end

	if not takeHostage.InProgress then			
		local closestPlayer, closestPed = checkIfHostage(1)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				if GetEntityHealth(closestPed) < 121 then
					return tvRP.notify("Nu poti lua ostatic un jucator mort!", "error")
				end

				-- SetCurrentPedWeapon(tempPed, foundWeap, true)
				takeHostage.InProgress = true
				takeHostage.targetSrc = targetSrc
				takeHostage.targetPed = closestPed
				TriggerServerEvent("takeHostage:sync",targetSrc)
				loadAnimDict(takeHostage.agressor.animDict)
				takeHostage.type = "agressor"

				Citizen.CreateThreadNow(hostageFuncs)
			else
				tvRP.notify("Niciun jucator prin preajma!", "error")
			end
		else
			tvRP.notify("Niciun jucator prin preajma!", "error")
		end
	end
end 

RegisterNetEvent("takeHostage:syncTarget")
AddEventHandler("takeHostage:syncTarget", function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	takeHostage.InProgress = true
	loadAnimDict(takeHostage.hostage.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	takeHostage.type = "hostage" 
end)

RegisterNetEvent("takeHostage:releaseHostage")
AddEventHandler("takeHostage:releaseHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = false
	DetachEntity(tempPed, true, false)
	loadAnimDict("reaction@shove")
	TaskPlayAnim(tempPed, "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	Wait(250)
	ClearPedSecondaryTask(tempPed)
end)

RegisterNetEvent("takeHostage:killHostage")
AddEventHandler("takeHostage:killHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = false
	SetEntityHealth(tempPed,0)
	DetachEntity(tempPed, true, false)
	loadAnimDict("anim@gangops@hostage@")
	TaskPlayAnim(tempPed, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("takeHostage:cl_stop")
AddEventHandler("takeHostage:cl_stop", function()
	takeHostage.InProgress = false
	takeHostage.type = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)


-- carry
local piggyback = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personPiggybacking = {
		animDict = "anim@arena@celeb@flat@paired@no_props@",
		anim = "piggyback_c_player_a",
		flag = 49,
	},
	personBeingPiggybacked = {
		animDict = "anim@arena@celeb@flat@paired@no_props@",
		anim = "piggyback_c_player_b",
		attachX = 0.0,
		attachY = -0.07,
		attachZ = 0.45,
		flag = 33,
	}
}


local function checkIfPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local playerPed = tempPed
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestPed = targetPed
                closestDistance = distance
            end
        end
    end
	
	if IsPedInAnyVehicle(closestPed, true) then
		return nil
	end

	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer, closestPed
	end

	return nil
end

RegisterCommand("caraprieten",function(source, args)
	if tvRP.isInComa() then return tvRP.notify("Nu poti cara un prieten mort!", "error") end
	

	if not (playerVehicle == 0) then
		TriggerEvent("vrp-hud:notify", "Nu poti cara o persoana din masina.", "error")
		return
	end

	if not piggyback.InProgress then
		local closestPlayer, closestPed = checkIfPlayer(3)

		if closestPlayer then
			if GetEntityHealth(closestPed) < 121 then
				return tvRP.notify("Nu poti cara un prieten mort!", "error")
			end

			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				piggyback.InProgress = true
				piggyback.targetSrc = targetSrc
				TriggerServerEvent("Piggyback:sync",targetSrc)
				loadAnimDict(piggyback.personPiggybacking.animDict)
				piggyback.type = "piggybacking"

				DisableControlAction(0, 22, true)
				DisableControlAction(0, 61, true)
                
                CreateThread(function()
                    while piggyback.InProgress do
                        if piggyback.type == "beingPiggybacked" then
                            if not IsEntityPlayingAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 3) then
                                TaskPlayAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 8.0, -8.0, 100000, piggyback.personBeingPiggybacked.flag, 0, false, false, false)
                            end
                        elseif piggyback.type == "piggybacking" then
                            if not IsEntityPlayingAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 3) then
                                TaskPlayAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 8.0, -8.0, 100000, piggyback.personPiggybacking.flag, 0, false, false, false)
                            end
                        end
                        Wait(0)
                    end
                end)
			else
				tvRP.notify("Nu ai jucatori in jur!")
			end
		else
			tvRP.notify("Nu ai jucatori in jur!")
		end
	else
		piggyback.InProgress = false
		ClearPedSecondaryTask(tempPed)
		DetachEntity(tempPed, true, false)
		TriggerServerEvent("Piggyback:stop",piggyback.targetSrc)
		piggyback.targetSrc = 0
		DisableControlAction(0, 22, false)
		DisableControlAction(0, 61, false)
	end
end)

RegisterNetEvent("Piggyback:syncTarget")
AddEventHandler("Piggyback:syncTarget", function(targetSrc)
	local playerPed = tempPed
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	piggyback.InProgress = true
	loadAnimDict(piggyback.personBeingPiggybacked.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, piggyback.personBeingPiggybacked.attachX, piggyback.personBeingPiggybacked.attachY, piggyback.personBeingPiggybacked.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	piggyback.type = "beingPiggybacked"

	exports["vrp"]:freezeKeys(true)

    CreateThread(function()
        while piggyback.InProgress do
            if piggyback.type == "beingPiggybacked" then
                if not IsEntityPlayingAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 3) then
                    TaskPlayAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 8.0, -8.0, 100000, piggyback.personBeingPiggybacked.flag, 0, false, false, false)
                end
            elseif piggyback.type == "piggybacking" then
                if not IsEntityPlayingAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 3) then
                    TaskPlayAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 8.0, -8.0, 100000, piggyback.personPiggybacking.flag, 0, false, false, false)
                end
            end

            Wait(1)
        end
		exports["vrp"]:freezeKeys(false)
    end)
end)

RegisterNetEvent("Piggyback:cl_stop")
AddEventHandler("Piggyback:cl_stop", function()
	piggyback.InProgress = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)

local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {
		animDict = "missfinale_c2mcs_1",
		anim = "fin_c2_mcs_1_camman",
		flag = 49,
	},
	personCarried = {
		animDict = "nm",
		anim = "firemans_carry",
		attachX = 0.27,
		attachY = 0.15,
		attachZ = 0.63,
		flag = 33,
	}
}

local function carryFuncs()
	while carry.InProgress do
		if carry.type == "beingcarried" then
			if not IsEntityPlayingAnim(tempPed, carry.personCarried.animDict, carry.personCarried.anim, 3) then
				TaskPlayAnim(tempPed, carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
			end
		elseif carry.type == "carrying" then
			if not IsEntityPlayingAnim(tempPed, carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
				TaskPlayAnim(tempPed, carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, 100000, carry.personCarrying.flag, 0, false, false, false)
			end
		end

		Wait(1)
	end
	exports["vrp"]:freezeKeys(false)
end

RegisterCommand("cara",function(source, args)
	if tvRP.isInComa() then return tvRP.notify("Nu poti cara un om mort!", "error") end
	
	if not (playerVehicle == 0) then
		TriggerEvent("vrp-hud:notify", "Nu poti cara o persoana din masina.", "error")
		return
	end

	if not carry.InProgress then
		local closestPlayer = checkIfPlayer(3)

		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent("CarryPeople:sync",targetSrc)
				loadAnimDict(carry.personCarrying.animDict)
				carry.type = "carrying"

				Citizen.CreateThreadNow(carryFuncs)
			else
				tvRP.notify("Niciun jucator prin preajma!", "warning")
			end
		else
			tvRP.notify("Niciun jucator prin preajma!", "warning")
		end
	else
		carry.InProgress = false
		ClearPedSecondaryTask(tempPed)
		DetachEntity(tempPed, true, false)
		TriggerServerEvent("CarryPeople:stop",carry.targetSrc)
		carry.targetSrc = 0
	end
end)

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	carry.InProgress = true
	loadAnimDict(carry.personCarried.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	carry.type = "beingcarried"

	exports["vrp"]:freezeKeys(true)

	Citizen.CreateThreadNow(carryFuncs)
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
	carry.InProgress = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)
