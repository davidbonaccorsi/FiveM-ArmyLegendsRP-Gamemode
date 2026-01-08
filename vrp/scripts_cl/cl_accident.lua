local isBlackedOut = false
local injuredTime = 0

RegisterNetEvent("carCrash", function()
    isBlackedOut = true

    Citizen.CreateThread(function()
        DoScreenFadeOut(100)
        StartScreenEffect('DeathFailOut', 0, true)
        SetCurrentPedWeapon(tempPed, GetHashKey('WEAPON_UNARMED'), true)
        Citizen.Wait(1000)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(1000)
        Citizen.Wait(1000)

        DoScreenFadeOut(100)
        Citizen.Wait(750)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(750)
        Citizen.Wait(750)

        DoScreenFadeOut(100)
        Citizen.Wait(500)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(500)
        Citizen.Wait(500)

        DoScreenFadeOut(100)
        Citizen.Wait(250)
        StopScreenEffect('DeathFailOut')
        DoScreenFadeIn(250)

        injuredTime = math.random(15, 20)
        isBlackedOut = false
    end)

	Citizen.CreateThread(function()
		while isBlackedOut do
			DisableControlAction(0, 71, true) -- veh forward
            DisableControlAction(0, 72, true) -- veh backwards
            DisableControlAction(0, 63, true) -- veh turn left
            DisableControlAction(0, 64, true) -- veh turn right
            DisableControlAction(0, 75, true) -- disable exit vehicle
			Wait(1)
		end
	end)

	while injuredTime > 1 do
		SetPedMovementClipset(tempPed, "move_m@injured", 1.0)
		ShakeGameplayCam("DRUNK_SHAKE", 3.0)
		injuredTime = injuredTime - 1

		if math.random(1, 100) < 50 then
			Citizen.CreateThread(function()
				ClearTimecycleModifier()
				SetCurrentPedWeapon(tempPed, GetHashKey('WEAPON_UNARMED'), true)
				Citizen.Wait((20 - injuredTime) * 50)
				SetTimecycleModifier("hud_def_blur")
			end)
		end
        
		Citizen.Wait(1400)
	end

	ClearTimecycleModifier()

	StopGameplayCamShaking(true)
	ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
	ResetPedMovementClipset(tempPed, 0.0)
end)