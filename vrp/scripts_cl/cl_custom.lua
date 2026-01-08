onlinePlayers = 0
RegisterNetEvent('getOnlinePly', function(ammt)
    onlinePlayers = ammt
end)


local myUserData = {
    faction = "Civil"
}

RegisterNetEvent("discord:setUserData", function(uid, faction)
    myUserData.uid = uid
    myUserData.name = GetPlayerName(PlayerId())
    if faction then
        myUserData.faction = faction
    end
end)


exports("getMyUserId", function()
    return myUserData.uid or false
end)

Citizen.CreateThread(function()
  local appId = 1233863980855070823
  local buttons = {{0, "Website", "https://armylegends.ro"}, {1, "Direct Connect", "fivem://connect/fivem.armylegends.ro"}}

  while not myUserData.uid do
      Citizen.Wait(100)
  end

  while true do
      SetDiscordAppId(appId)
      for indx, btnData in pairs(buttons) do
        SetDiscordRichPresenceAction(btnData[1], btnData[2], btnData[3])
      end

      SetDiscordRichPresenceAsset('elogo')
      SetDiscordRichPresenceAssetSmall('elogo')
      SetDiscordRichPresenceAssetText('fivem.armylegends.ro')
      SetDiscordRichPresenceAssetSmallText('ArmyLegends Romania RolePlay')
      SetRichPresence(onlinePlayers.." jucatori conectati.\n"..myUserData.name.." ("..myUserData.uid..")")

      Citizen.Wait(30000)
  end
end)

-- ropes

local targetedPed, targetedPlayer = 0, 0

exports("isTiedWithRope", function()
  local ropeResult = promise.new()
  vRPserver.isTiedWithRope({}, function(tied)
      ropeResult:resolve(tied)
  end)

  return Citizen.Await(ropeResult)
end)

Citizen.CreateThread(function()
	local runOnce = true

	local tied = false
	local targetId = nil

	while true do
		Citizen.Wait(100)

		while targetedPlayer ~= 0 do
			if runOnce then
				targetId = GetPlayerServerId(targetedPlayer)

				local weapon = GetSelectedPedWeapon(tempPed)
				if weapon == GetHashKey("WEAPON_KNIFE") or weapon == GetHashKey("WEAPON_SWITCHBLADE") or weapon == GetHashKey("WEAPON_MACHETE") then 
					vRPserver.isTiedWithRope({targetId}, function(tiedWithRope)
						tied = tiedWithRope
					end)
				else
					tied = false
				end

				runOnce = false
			end

			if tied then
				SetTextFont(0)
				SetTextCentre(1)
				SetTextProportional(0)
				SetTextScale(0.55, 0.55)
				SetTextDropShadow(30, 5, 5, 5, 255)
				SetTextEntry("STRING")
				SetTextColour(255, 255, 255, 255)
				AddTextComponentString("Apasa ~b~E~w~ pentru a taia sfoara")
				DrawText(0.5, 0.85)

				if IsControlJustPressed(0, 38) then
					ClearPedTasksImmediately(tempPed)
					vRPserver.cutRope({targetId})
					Citizen.Wait(6000)
				end
			end

			Citizen.Wait(1)
		end

		tied = false
		hoursToShow = -1
		runOnce = true
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300)
		local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
		if aiming then
			if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) then
				if targetedPed ~= targetPed then
					for _, player in pairs(GetActivePlayers()) do
						if GetPlayerPed(player) == targetPed then
							targetedPed = targetPed
							targetedPlayer = player
							break
						end
					end
				end
			end
		else
			targetedPed, targetedPlayer = 0, 0
		end
	end
end)


RegisterCommand("photo", function()
  N_0xa67c35c56eb1bd9d()
  if N_0x0d6ca79eeebd8ca3() and N_0x3dec726c25a11bac(-1) then
    N_0xd801cc02177fa3f1() -- clear photo
  end
end)

local musketDmg = false
RegisterNetEvent("dmg:setMusket", function(state)
  musketDmg = state
end)

Citizen.CreateThread(function()
  local punch = GetHashKey('WEAPON_UNARMED')
  local rozeta = GetHashKey('WEAPON_KNUCKLE')
  local bat = GetHashKey('WEAPON_BAT')
  local fallingDmg = GetHashKey('WEAPON_FALL')
  local knife = GetHashKey('WEAPON_KNIFE')
  local animal = GetHashKey('WEAPON_ANIMAL')
  local cougar = GetHashKey('WEAPON_COUGAR')
  local pulan = GetHashKey('WEAPON_NIGHTSTICK')
  local lnt = GetHashKey('WEAPON_FLASHLIGHT')
  local bulgare = GetHashKey('WEAPON_SNOWBALL')
  local smokeGrenade = GetHashKey("WEAPON_SMOKEGRENADE")
  local snowBall = GetHashKey("WEAPON_SNOWBALL")
  local musket = GetHashKey("WEAPON_MUSKET")

  SetBlipAlpha(GetNorthRadarBlip(), 0)
  SetRadarBigmapEnabled(false, false)

  while true do
    N_0x4757f00bc6323cfe(-1553120962, 0.4) -- Masina
    N_0x4757f00bc6323cfe(fallingDmg, 0.8)
    N_0x4757f00bc6323cfe(punch, 0.1)
    N_0x4757f00bc6323cfe(rozeta, 0.8)
    N_0x4757f00bc6323cfe(bat, 0.5)
    N_0x4757f00bc6323cfe(knife, 0.6)
    N_0x4757f00bc6323cfe(animal, 0.0)
    N_0x4757f00bc6323cfe(cougar, 0.0)
    N_0x4757f00bc6323cfe(pulan, 0.1)
    N_0x4757f00bc6323cfe(lnt, 0.05)
    N_0x4757f00bc6323cfe(smokeGrenade, 0.0)
    N_0x4757f00bc6323cfe(snowBall, 0.0)

    if not musketDmg then
      N_0x4757f00bc6323cfe(musket, 0.0)
    else
      N_0x4757f00bc6323cfe(musket, 1.0)
    end

    if IsPedArmed(tempPed, 6) then
      DisableControlAction(1, 140, true)
      DisableControlAction(1, 141, true)
      DisableControlAction(1, 142, true)
    end

    DisplayAmmoThisFrame(false)
    HudWeaponWheelIgnoreSelection(true)
    DisableControlAction(1, 37)

    DisablePlayerVehicleRewards(PlayerId())
    DisablePlayerVehicleRewards(-1)

    RemoveAllPickupsOfType(0xDF711959) -- carbine rifle
    RemoveAllPickupsOfType(0xF9AFB48F) -- pistol
    RemoveAllPickupsOfType(0xA9355DCD) -- pumpshotgun
    RemoveAllPickupsOfType(0x3A4C2AD2) -- smg

    Citizen.Wait(1)
  end
end)


local masive = false

RegisterNetEvent("event:spawnMasiv")
AddEventHandler("event:spawnMasiv", function(args)
	if not masive then
		if args[1] then
			local numaratoare = 0
			local i = 0
			local mhash = GetHashKey(args[1])
			tvRP.sendInfo("Modelul se incarca")
			while not HasModelLoaded(mhash) and i < 1000 do
		      RequestModel(mhash)
		      Citizen.Wait(30)
			  i = i + 1
		    end
		    if HasModelLoaded(mhash) then
		    	tvRP.sendInfo("Modelul s-a incarcat, apasa SPACE pentru ca sa spawnezi masini (atentie la spam)")
		    	masive = mhash
		    	Citizen.CreateThread(function()
		    		Wait(100)
		    		local head = GetEntityHeading(GetPlayerPed(-1))
		    		while masive do
		    			Wait(1)
		    			if IsControlJustReleased(0, 22) then
		    				numaratoare = numaratoare + 1
		    				tvRP.sendInfo("Ai spawnat "..numaratoare.." masini")
		    				local x,y,z = tvRP.getPosition()
		    				tvRP.teleport(x,y,z+1.0)
                local nveh = CreateVehicle(masive, x,y,z+0.5, head, true, false) -- added player heading
                SetVehicleFuelLevel(nveh, 100.0)
                SetVehicleOnGroundProperly(nveh)
                SetEntityInvincible(nveh, false)
                Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
                SetVehicleHasBeenOwnedByPlayer(nveh,true)
		    			end
		    		end
		    		SetModelAsNoLongerNeeded(mhash)
		    	end)
		    else
		    	tvRP.sendError("Model invalid")
		    end
		else
			tvRP.sendSyntax("/spawnmasiv <model>")
		end
	else
		tvRP.sendInfo("Spawnmasiv oprit")
		masive = false
	end
end)


-- Crouch --

local isCrouched, lastUserCam = false, 0

Citizen.CreateThread(function()
  while not HasAnimSetLoaded('move_ped_crouched') do
    Wait(5)
    RequestAnimSet('move_ped_crouched')
  end
end)

local function resetCrouch()
  SetPedMaxMoveBlendRatio(tempPed, 1.0)
  ResetPedMovementClipset(tempPed, 0.55)
  ResetPedStrafeClipset(tempPed)
  SetPedCanPlayAmbientAnims(tempPed, true)
  SetPedCanPlayAmbientBaseAnims(tempPed, true)
  ResetPedWeaponMovementClipset(tempPed)
  SetFollowPedCamViewMode(lastUserCam)
  SetPedStealthMovement(tempPed,false,"")
end

RegisterCommand('useCrouch', function()
  local currentCamera = GetFollowPedCamViewMode()
  
  if isCrouched then
      isCrouched = false;
      resetCrouch()
  else
      lastUserCam = currentCamera
      isCrouched = true;
      Citizen.CreateThread(function()
          while isCrouched do
              SetPedUsingActionMode(tempPed, false, -1, "DEFAULT_ACTION")
              SetPedMovementClipset(tempPed, 'move_ped_crouched', 0.55)
              SetPedStrafeClipset(tempPed, 'move_ped_crouched_strafing')
              SetWeaponAnimationOverride(tempPed, "Ballistic")
              Wait(5)
          end
          resetCrouch()
      end)
  end
end, false)

RegisterKeyMapping('useCrouch', 'Intra in modul crouch', 'keyboard', 'LCONTROL')

-- Ridica mainile --
local handsup = false
RegisterCommand("+ridicamaini", function()
    if (playerVehicle == 0) then
        handsup = true
        Citizen.CreateThread(function()
            local dict = "missminuteman_1ig_2"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(100)
            end
        end)
        if handsup then
            TaskPlayAnim(tempPed, "missminuteman_1ig_2", "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
            handsup = true
        end
    end
end)

RegisterCommand("-ridicamaini", function()
    if handsup then
        RemoveAnimSet("missminuteman_1ig_2")
        ClearPedSecondaryTask(tempPed)
        handsup = false
    end
end)

RegisterKeyMapping("+ridicamaini", "Ridica mainile", "keyboard", "x")

-- Finger Pointing --
local isPlayerPointing = false

function tvRP.isPointingFinger()
  return isPlayerPointing
end

RegisterCommand('+arataCuDegetul', function()
    local ped = tempPed
    isPlayerPointing = true

    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")

    while isPlayerPointing do
        local camPitch = GetGameplayCamRelativePitch()
        if camPitch < -70.0 then
            camPitch = -70.0
        elseif camPitch > 42.0 then
            camPitch = 42.0
        end
        camPitch = (camPitch + 70.0) / 112.0
        
        local camHeading = GetGameplayCamRelativeHeading()
        local cosCamHeading = Cos(camHeading)
        local sinCamHeading = Sin(camHeading)
        if camHeading < -180.0 then
            camHeading = -180.0
        elseif camHeading > 180.0 then
            camHeading = 180.0
        end
        camHeading = (camHeading + 180.0) / 360.0
        
        local blocked = 0
        local nn = 0
        
        local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
        local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
        nn, blocked, coords, coords = GetRaycastResult(ray)
        
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
        SetCurrentPedWeapon(tempPed, GetHashKey("WEAPON_UNARMED"), true)

        if not IsPedOnFoot(tempPed) then
            CancelEvent();
            isPlayerPointing = false
        end
        
        Wait(1)
    end
end)

RegisterCommand('-arataCuDegetul', function()
    isPlayerPointing = false
    local ped = tempPed
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(tempPed)
end)

RegisterKeyMapping("+arataCuDegetul", "Arata cu degetul", "keyboard", "B")

-- Overhead talking marker --
Citizen.CreateThread(function()
  while true do
    local ticks = 500
    local theUsers = GetActivePlayers()

    for _, i in pairs(theUsers)  do
      local ped = GetPlayerPed(i)

      if NetworkIsPlayerTalking(i) then
        ticks = 1

        local coords = GetEntityCoords(ped) + vector3(0.0, 0.0, 1.0)
        DrawMarker(28, coords, 0, 0, 0, 0, 0, 0, 0.020, 0.020, 0.020, 255, 255, 255, 200)
        PlayFacialAnim(ped, 'mic_chatter', 'mp_facial')
      else
        PlayFacialAnim(ped, 'mood_normal_1', 'facials@gen_male@variations@normal')
      end
    end

    Wait(ticks)
  end
end)

-- Maini in san --
local mainiInSan = false
RegisterCommand("dabrotinmainileinsan", function()
  mainiInSan = not mainiInSan

  if mainiInSan then
    RequestAnimDict("amb@world_human_hang_out_street@female_arms_crossed@base")
    while not HasAnimDictLoaded("amb@world_human_hang_out_street@female_arms_crossed@base") do
      Wait(1)
    end

    TaskPlayAnim(tempPed, "amb@world_human_hang_out_street@female_arms_crossed@base", "base", 8.0, 8.0, -1, 50, 0, false, false, false)
    return
  end

  ClearPedTasks(tempPed)
end)

RegisterKeyMapping("dabrotinmainileinsan", "Tine mainile in san", "keyboard", "O")

-- Sistem Fluierat --

RegisterCommand("fluiera", function()
  if IsControlPressed(0, 21) then
    return
  end

  if playerVehicle == 0 and not IsPedSwimming(tempPed) and not IsPedShooting(tempPed) and not IsPedClimbing(tempPed) and not IsPedCuffed(tempPed) and not IsPedDiving(tempPed) and not IsPedFalling(tempPed) and not IsPedJumping(tempPed) and not IsPedJumpingOutOfVehicle(tempPed) and IsPedOnFoot(tempPed) and not IsPedRunning(tempPed) and not IsPedUsingAnyScenario(tempPed) and not IsPedInParachuteFreeFall(tempPed) then
    SetCurrentPedWeapon(tempPed, GetHashKey("WEAPON_UNARMED"), true)

    Citizen.CreateThread(function()
      loadAnimDict("rcmnigel1c")

      TaskPlayAnim(tempPed, "rcmnigel1c", "hailing_whistle_waive_a", 2.7, 2.7, -1, 49, 0, 0, 0, 0)
        
      Wait(1347)
      ClearPedSecondaryTask(tempPed)
    end)  
  end
end)

RegisterKeyMapping("fluiera", "Fluiera", "keyboard", "H")

local isBusted = false
RegisterCommand("k", function()
  local player = tempPed

  if not IsEntityDead(player) then 
    loadAnimDict("random@arrests")
    loadAnimDict("random@arrests@busted")

    if IsEntityPlayingAnim(player, "random@arrests@busted", "idle_a", 3) then 
      TaskPlayAnim(player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(3000)

      TaskPlayAnim(player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0)
      isBusted = false
    else
      TaskPlayAnim(player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(4000)
      
      TaskPlayAnim(player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(500)
      
      TaskPlayAnim(player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(1000)
      
      TaskPlayAnim(player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
      isBusted = true

      Citizen.CreateThread(function()
        while isBusted do
          DisableControlAction(1, 140, true)
          DisableControlAction(1, 141, true)
          DisableControlAction(1, 142, true)
          DisableControlAction(0,21,true)

          Wait(1)
        end
      end)
    end     
  end
end)


Citizen.CreateThread(function()
	local bhops = 0
	local reduction = 0

	while true do
		if IsPedJumping(tempPed) then
			bhops = bhops + 1
      
      if bhops >= 1 then
				Citizen.Wait(300)
				SetPedToRagdoll(tempPed, 500, 500, 0, 0, 0, 0)
			end
		end

		Citizen.Wait(1100)
		reduction = reduction + 1
		if reduction == 2 then
			bhops = math.max(bhops - 1, 0)
			reduction = 0
		end
	end
end)

-- /me

local nbrDisplaying = 1

local function DrawMeText3D(x, y, z, text, backgroundEnabled)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoord())
	local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

	local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

	if onScreen then

		-- Formalize the text
		SetTextColour(255, 255, 255, 250)
		if backgroundEnabled then
			SetTextColour(219, 29, 29, 200)
		end
		SetTextScale(0.0 * scale, 0.55 * scale)
		SetTextFont(font)
		SetTextProportional(1)
		SetTextCentre(true)

		-- Calculate width and height
		BeginTextCommandWidth("STRING")
		AddTextComponentString(text)
		local height = GetTextScaleHeight(0.55 * scale, font)
		local width = EndTextCommandGetWidth(font)

		-- Diplay the text
		SetTextEntry("STRING")
		AddTextComponentString(text)
		EndTextCommandDisplayText(_x, _y)

		if backgroundEnabled then
			DrawRect(_x, (_y + scale / 58) + 0.005, width, height + 0.01, 0, 0, 0, 100)
		end
	end
end

local function Display(mePlayer, text, offset, backgroundEnabled)
	local mePed = GetPlayerPed(mePlayer)

	if NetworkIsPlayerActive(mePlayer) and mePed then

		local untilTime = GetGameTimer() + 4000
		local coords = GetEntityCoords(PlayerPedId(), false)

		Citizen.CreateThread(function()
			nbrDisplaying = nbrDisplaying + 1

			while GetGameTimer() < untilTime do
				Citizen.Wait(1)
				local coordsMe = GetEntityCoords(mePed, false)
				local dist = #(coordsMe - coords)
				if dist < 150 then
					DrawMeText3D(coordsMe.x, coordsMe.y, coordsMe.z + offset - 0.1, text, backgroundEnabled)
				else
					break
				end
			end

			nbrDisplaying = nbrDisplaying - 1
		end)
	end
end

RegisterCommand('me', function(source, args)
	local text = "~HC_139~"
	for i = 1, #args do
		text = text .. ' ' ..args[i]
	end
	text = text .. ''

	local activePly = GetActivePlayers()
	local activeSrc = {}
	for _, ply in ipairs(activePly) do
		table.insert(activeSrc, GetPlayerServerId(ply))
	end

	TriggerServerEvent('3dme:shareDisplay', text, false, activeSrc)
end)

RegisterNetEvent("vrp-3dme:display")
AddEventHandler("vrp-3dme:display", function(msg)

	local activePly = GetActivePlayers()
	local activeSrc = {}
	for _, ply in ipairs(activePly) do
		table.insert(activeSrc, GetPlayerServerId(ply))
	end

	TriggerServerEvent('3dme:shareDisplay', msg, true, activeSrc)
end)

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(mePlayer, text, bg)
	local offset = 1 + (nbrDisplaying * 0.14)
	Display(GetPlayerFromServerId(mePlayer), text, offset, bg)
end)

-- Freeze Keys
local freezeKeys = false
exports("freezeKeys", function(state)
  freezeKeys = state
  Citizen.CreateThread(function()
    while freezeKeys do
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
      DisableControlAction(0,32,true) -- disable move up
      DisableControlAction(0,268,true)
      DisableControlAction(0,182,true)
      DisableControlAction(0,217,true)
      DisableControlAction(0,33,true) -- disable move down
      DisableControlAction(0,269,true)
      DisableControlAction(0,34,true) -- disable move left
      DisableControlAction(0,270,true)
      DisableControlAction(0,35,true) -- disable move right
      DisableControlAction(0,1,true)
      DisableControlAction(0,2,true)
      DisableControlAction(0,3,true)
      DisableControlAction(0,4,true)
      DisableControlAction(0,5,true)
      DisableControlAction(0,6,true)
      DisableControlAction(0,7,true)
      DisableControlAction(0,14,true)
      DisableControlAction(0,15,true)
      DisableControlAction(0,16,true)
      DisableControlAction(0,17,true)
      DisableControlAction(0,245,true)
      DisableControlAction(0,246,true)
      DisableControlAction(0,254,true)
      DisableControlAction(0,255,true)
      DisableControlAction(0,236,true)
      DisableControlAction(0,252,true)
      DisableControlAction(0,253,true)
      DisableControlAction(0,73,true)
      DisableControlAction(0,74,true)
      DisableControlAction(0,303,true)
      DisableControlAction(0,305,true)
      DisableControlAction(0,199,true)
      DisableControlAction(0,22,true)
      DisableControlAction(0,202,true)
      DisableControlAction(0,311,true)
      DisableControlAction(0,323,true)
      DisableControlAction(0,29,true)
      DisableControlAction(0,79,true)
      DisableControlAction(0,0,true)
      DisableControlAction(0,322,true)
      DisableControlAction(0,177,true)
      DisableControlAction(0,200,true)
      DisableControlAction(0,75, true)
      DisableControlAction(0,244, true)
      DisableControlAction(0,86, true)
      DisableControlAction(0,85, true)
      DisableControlAction(0,80, true)
      DisableControlAction(0,38, true)
      Citizen.Wait(1)
    end
  end)
end)
