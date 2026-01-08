

local _SafeCrackingStates = "Setup"
local _onSpot             = false
local _try                = 0
local isMinigame          = false


local function EndMiniGame(safeUnlocked)
    if safeUnlocked then
        PlaySoundFrontend(0, "SAFE_DOOR_OPEN", "SAFE_CRACK_SOUNDSET", true )
    else
        PlaySoundFrontend(0, "SAFE_DOOR_CLOSE", "SAFE_CRACK_SOUNDSET", true )
    end
    isMinigame = false
    SafeCrackingStates = "Setup"
    FreezeEntityPosition(PlayerPedId(),false)
    ClearPedTasks(PlayerPedId())
end

local function ReleaseCurrentPin()
    _safeLockStatus[_currentLockNum] = false
    _currentLockNum = _currentLockNum + 1

    if _requiredDialRotationDirection == "Anticlockwise" then
        _requiredDialRotationDirection = "Clockwise"
    else
        _requiredDialRotationDirection = "Anticlockwise"
    end
    
    PlaySoundFrontend(0, "TUMBLER_PIN_FALL_FINAL", "SAFE_CRACK_SOUNDSET", true )
end

local function GetCurrentSafeDialNumber(currentDialAngle)
    local number = math.floor(100 * (currentDialAngle / 360))
    if number > 0 then number = 100 - number end

    return math.abs(number)
end

local function InitSafeLocks() -- Load the locks
    if not _safeCombination then
        return
    end
    
    local locks = {}
    for i=1, #_safeCombination do
        table.insert(locks, true)
    end

    return locks
end

local function RelockSafe()
    if not _safeCombination then return end
    
    _safeLockStatus = InitSafeLocks()
    _currentLockNum = 1
    _try = 0
    _requiredDialRotationDirection = _initDialRotationDirection
    _onSpot = false

    for i=1, #_safeCombination do
        _safeLockStatus[i] = true
    end
end

local function RotateSafeDial(rotationDirection)
    
    if (rotationDirection == "Anticlockwise" or rotationDirection == "Clockwise") and _requiredDialRotationDirection == rotationDirection then
        local rotationPerNumber = 1
        local multiplier
        if rotationDirection == "Anticlockwise" then
            multiplier = 1
        elseif rotationDirection == "Clockwise" then
            multiplier = -1
        end
        local rotationChange = multiplier * rotationPerNumber
        SafeDialRotation = SafeDialRotation + rotationChange
        PlaySoundFrontend( 0, "TUMBLER_TURN", "SAFE_CRACK_SOUNDSET", true )
    end

    _currentDialRotationDirection = rotationDirection
    _lastDialRotationDirection = rotationDirection
end

local function RunMiniGame()
    if _SafeCrackingStates == "Setup" then
        

        _SafeCrackingStates = "Cracking"
    elseif _SafeCrackingStates == "Cracking" then
        local isDead = GetEntityHealth(PlayerPedId()) <= 100
        if isDead then
            EndMiniGame(false)
            return false
        end

        if IsControlJustPressed( 0, 33 ) then
            EndMiniGame(false)
            return false
        end

        if IsControlJustPressed( 0, 32 ) then
            if _onSpot then
                ReleaseCurrentPin()
                _onSpot = false
                if _safeLockStatus[_currentLockNum] == nil then
                    EndMiniGame( true, false )
                    return true
                end
            else
                if _try >= 3 then
                    EndMiniGame(false)
                    return false
                else
                    _try = _try + 1
                    PlaySoundFrontend(0, "TUMBLER_RESET", "SAFE_CRACK_SOUNDSET", true )
                end
            end
        end

        if IsControlPressed( 0, 34 ) then
	        RotateSafeDial("Anticlockwise")
	    elseif IsControlPressed( 0, 35 ) then
	        RotateSafeDial("Clockwise")
	    else
	        RotateSafeDial("Idle")
	    end

        local incorrectMovement = _currentLockNum ~= 0 and
            _requiredDialRotationDirection ~= "Idle" and
            _currentDialRotationDirection ~= "Idle" and
            _currentDialRotationDirection ~= _requiredDialRotationDirection

        if  _currentDialRotationDirection ~= "Idle" then
            local currentDialNumber = GetCurrentSafeDialNumber(SafeDialRotation)
            local correctMovement = _requiredDialRotationDirection ~= "Idle" and
                                  (_currentDialRotationDirection == _requiredDialRotationDirection or
                                   _lastDialRotationDirection == _requiredDialRotationDirection)
            
            if correctMovement then
                local pinUnlocked = _safeLockStatus[_currentLockNum] and currentDialNumber == _safeCombination[_currentLockNum]
                if pinUnlocked then
                    PlaySoundFrontend(0, "TUMBLER_PIN_FALL", "SAFE_CRACK_SOUNDSET", false )
                    _onSpot = true
                end
            end
        end
    end
end

local function DrawSprites(drawLocks)
    local textureDict = "MPSafeCracking"
    local _aspectRatio = GetAspectRatio( true )
    
    DrawSprite( textureDict, "Dial_BG", 0.48, 0.3, 0.3, _aspectRatio * 0.3, 0, 255, 255, 255, 255 )
    DrawSprite( textureDict, "Dial", 0.48, 0.3, 0.3 * 0.5, _aspectRatio * 0.3 * 0.5, SafeDialRotation, 255, 255, 255, 255 )

    if not drawLocks then
        return
    end

    local xPos = 0.6
    local yPos = (0.3 * 0.5) + 0.035
    for _,lockActive in pairs(_safeLockStatus) do
        local lockString
        if lockActive then
            lockString = "lock_closed"
        else
            lockString = "lock_open"
        end
            
        DrawSprite( textureDict, lockString, xPos, yPos, 0.025, _aspectRatio * 0.015, 0, 231, 194, 81, 255 )
        yPos = yPos + 0.05
    end
end

local function InitializeSafe(safeCombination)
    _initDialRotationDirection = "Clockwise"
    _safeCombination = safeCombination

    RelockSafe()

    local dialStartNumber = math.random(0, 100)
    SafeDialRotation = 3.6 * dialStartNumber
end

local function createSafe(combination) 
    RequestStreamedTextureDict( "MPSafeCracking", false )
    RequestAmbientAudioBank( "SAFE_CRACK", false )
    local res
    isMinigame = not isMinigame
    if isMinigame then 
        InitializeSafe(combination)
		
        while isMinigame do

            RequestAnimDict("mini@safe_cracking")
		    while not HasAnimDictLoaded("mini@safe_cracking") do Wait(10) end
		    TaskPlayAnim(PlayerPedId(), "mini@safe_cracking", "idle_base", 1.5, 1.5, -1, 16, 0, 0, 0, 0)

            FreezeEntityPosition(PlayerPedId(), true)
            DrawSprites(true)
            res = RunMiniGame()
            
            if res == true then
                return res
            elseif res == false then
                return res
            end
        
            Citizen.Wait(1)
        end
        
    else
        FreezeEntityPosition(PlayerPedId(), false)
    end
end


local storeAlerts = {}
local storeBlips = {}

local inSafe = false
local runningAllert = false

local storesPos = {}

local function alertText(secconds)
	if not runningAllert then
		runningAllert = true
		Citizen.CreateThread(function()
			while secconds > 0 do
				Citizen.Wait(1000)
				secconds = secconds - 1
			end
		end)
		Citizen.CreateThread(function()
			while secconds > 0 or inSafe do
				SetTextFont(2)
				SetTextCentre(1)
				SetTextProportional(0)
				SetTextScale(0.55, 0.55)
				SetTextDropShadow(30, 5, 5, 5, 255)
				SetTextEntry("STRING")
				if secconds == 0 then
					SetTextColour(230, 0, 0, 255)
					AddTextComponentString("POLITIA ESTE ALERTATA")
				else
					SetTextColour(255, 255, 255, 255)
					AddTextComponentString(string.format("POLITIA ESTE ALERTATA IN ~r~%02d ~s~SECUNDE", secconds))
				end
				DrawText(0.5, 0.94)

				Citizen.Wait(1)
			end
			if not inSafe then
				local untilTimer = GetGameTimer() + 3000
				while untilTimer >= GetGameTimer() do
					SetTextFont(2)
					SetTextCentre(1)
					SetTextProportional(0)
					SetTextScale(0.55, 0.55)
					SetTextDropShadow(30, 5, 5, 5, 255)
					SetTextEntry("STRING")
					SetTextColour(230, 0, 0, 255)
					AddTextComponentString("POLITIA ESTE ALERTATA")
					DrawText(0.5, 0.94)

					Citizen.Wait(1)
				end
			end
			TriggerEvent("vrp-hud:showBind", false)

			runningAllert = false
		end)
	end
end

RegisterNetEvent("vrp-storerob:start")
AddEventHandler("vrp-storerob:start", function(storeId, combination, secconds)
	if type(combination) == "table" and type(storeId) == "number" then
		if not inSafe then
			if GetPedDrawableVariation(tempPed, 1) > 0 then
				inSafe = true
				Citizen.CreateThread(function()
					alertText(secconds)
					while inSafe do
						SetTextFont(2)
						SetTextCentre(1)
						SetTextProportional(0)
						SetTextScale(0.6, 0.6)
						SetTextColour(255, 255, 255, 255)
						SetTextDropShadow(30, 5, 5, 5, 255)
						SetTextEntry("STRING")
						AddTextComponentString("~b~W~s~ Incearca   ~b~A~s~ Stanga   ~b~D~s~ Dreapta   ~b~S~s~ Opreste")
						DrawText(0.5, 0.9)

						Citizen.Wait(1)
					end
				end)
				local res = createSafe(combination)
				inSafe = false
				TriggerServerEvent("vrp-storerob:check", storeId, res)
			else
				TriggerServerEvent("vrp-storerob:cancel", storeId)
				TriggerEvent("chatMessage", "^1Eroare^7: Ai nevoie de o masca pentru a da jaf !")
			end
		end
	end
end)

local blacklistStores = {}

RegisterNetEvent("vrp-storerob:addBlip")
AddEventHandler("vrp-storerob:addBlip", function(storeId, pos)
	storeAlerts[storeId] = AddBlipForCoord(pos[1], pos[2], pos[3])
    SetBlipSprite(storeAlerts[storeId], 161)
    SetBlipScale(storeAlerts[storeId], 0.6)
    SetBlipColour(storeAlerts[storeId], 1)
    PulseBlip(storeAlerts[storeId])
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Jaf in desfasurare")
    EndTextCommandSetBlipName(storeAlerts[storeId])

    SetBlipAsShortRange(storeBlips[storeId], false)
    SetBlipColour(storeBlips[storeId], 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Jaf in desfasurare")
    EndTextCommandSetBlipName(storeBlips[storeId])

    blacklistStores[storeId] = true

    Citizen.CreateThread(function()
    	Citizen.Wait(120000)
		if DoesBlipExist(storeAlerts[storeId]) then
            RemoveBlip(storeAlerts[storeId])
            storeAlerts[storeId] = nil
        end
        SetBlipAsShortRange(storeBlips[storeId], true)
    	SetBlipColour(storeBlips[storeId], 47)
    	BeginTextCommandSetBlipName("STRING")
	    AddTextComponentString("Jaf Magazin")
	    EndTextCommandSetBlipName(storeBlips[storeId])
	    blacklistStores[storeId] = nil
    end)
end)

local stores = {
	{-47.861663818359, -1759.3719482422, 28.421010971069},
	{-46.668876647949, -1758.0550537109, 28.421010971069},
	{1134.1508789063, -982.48638916016, 45.415809631348},
	{-1221.9808349609, -908.28363037109, 11.326354026794},
	{-1486.2336425781, -377.97994995117, 39.163421630859},
	{-2966.4196777344, 390.85485839844, 14.043313026428},
	{373.07879638672, 328.72894287109, 102.56639099121},
	{372.50723266602, 326.4162902832, 102.56639099121},
	{24.464073181152, -1344.9854736328, 28.497026443481},
	{24.404426574707, -1347.2951660156, 28.497026443481},
	{2554.8881835938, 380.85437011719, 107.62294769287},
	{2557.2954101563, 380.78680419922, 107.62294769287},
	{-3041.2126464844, 583.82006835938, 6.9089317321777},
	{-3038.9929199219, 584.50128173828, 6.9089317321777},
	{-3244.6044921875, 1000.2213134766, 11.830711364746},
	{-3242.2651367188, 999.96533203125, 11.830711364746},
	{1164.9465332031, -322.81149291992, 68.205146789551},
	{1165.0662841797, -324.4753112793, 68.205146789551}
} 

RegisterNetEvent("vrp-storerob:initBlips")
AddEventHandler("vrp-storerob:initBlips", function(storesNum)

	if storesNum == #stores then

		for storeId, pos in pairs(stores) do

			storesPos[storeId] = pos

			storeBlips[storeId] = AddBlipForCoord(pos[1], pos[2], pos[3])
		    SetBlipSprite(storeBlips[storeId], 271)
		    SetBlipAsShortRange(storeBlips[storeId], true)
		    SetBlipScale(storeBlips[storeId], 0.3)
		    SetBlipColour(storeBlips[storeId], 47)

		    BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString("Jaf Magazin")
		    EndTextCommandSetBlipName(storeBlips[storeId])
		end

	else
		print("^1Error^7: StoreRobbery client locations does not match with server-side locations")
	end
end)


Citizen.CreateThread(function()
	local nearStores = {}
	local closeStores = {}
	local ped = tempPed
	local inputActive = {}

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1)
			if inSafe then
				Citizen.Wait(5000)
			else
				for i, v in pairs(nearStores) do
					if v then
						DrawMarker(1, v[1], v[2], v[3], 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.5, 255, 154, 24, 130, 0, 0, 2, 0, 0, 0, 0)
						if closeStores[i] then
							if not inputActive[i] then
								inputActive[i] = true
								TriggerEvent("vrp-hud:showBind", {key = "E", text = "Jefuieste magazinul"})
							end
							if IsControlJustPressed(0, 38) then
								TriggerServerEvent("vrp-storerob:try", i)
							end
						elseif inputActive[i] then
							inputActive[i] = nil
							TriggerEvent("vrp-hud:showBind", false)
						end
					end
				end
			end
		end
	end)

	while true do
		Citizen.Wait(1500)
		nearStores = {}
		closeStores = {}
		if inSafe then
			Citizen.Wait(5000)
			inputActive = {}
		else
			ped = tempPed
			if not IsPedSittingInAnyVehicle(ped) then 
				local pedCoords = pedPos
				for storeId, pos in pairs(storesPos) do
					if not blacklistStores[storeId] then
						local dst = GetDistanceBetweenCoords(pedCoords, pos[1], pos[2], pos[3], false)
						if dst < 3 then
							nearStores[storeId] = pos
							if dst < 1 then
								closeStores[storeId] = true
							end
						end
					end
				end
			end
		end
	end

end)