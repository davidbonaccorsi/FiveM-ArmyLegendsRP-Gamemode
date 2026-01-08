local cfg = module('cfg/gym')
local inWorkout = false

Citizen.CreateThread(function()
	for k, objectData in pairs(cfg.gymEquipment) do
		tvRP.setArea("vRP:gymLocation"..k,objectData.location[1], objectData.location[2], objectData.location[3], 15,
		{key = 'E', text='Lucreaza '..objectData.type:gsub("_", " "), minDst = 1},
		{
			type = 20,
			effect = true,
			x = 0.35,
			y = 0.35,
			z = -0.35,
			color = {201, 225, 255, 200},
			coords = objectData.location
		},
		function()
			if inWorkout then
				tvRP.notify("Deja faci un exercitiu!", 'error')
				return
			end

			vRPserver.canUseGym({}, function(hasSubscription)
				if not hasSubscription then
					tvRP.notify("Ai nevoie de un abonament activ pentru a putea face sala!", "error")
				else
					TriggerEvent('vrp-hud:showBind', false)
					inWorkout = true			
					if objectData.animData then
						SetEntityCoords(PlayerPedId(), objectData.animData['pos'])
						SetEntityHeading(PlayerPedId(), objectData.animData['h'])
					end
					Citizen.Wait(100)
					TriggerEvent("vrp:progressBar", {
						duration = objectData.workoutDuration,
						text = "Lucrezi "..objectData.type:lower().."...",
					})
					tvRP.setCanStop(false)
					TaskStartScenarioInPlace(PlayerPedId(), cfg.gymAnims[objectData.type], 0, true)
					Wait(objectData.workoutDuration)
					TriggerServerEvent('vRP:updatePlayerGym')
					inWorkout = false
					tvRP.setCanStop(true)
					ClearPedTasks(PlayerPedId())
				end
			end)
		end)
	end
end)

Citizen.CreateThread(function()
	local pos = cfg.gymLocations
	exports['vrp']:spawnNpc("vRP:gymSubs", {
		position = pos,
		rotation = 191,
		model = "a_m_y_musclbeac_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Bogdan Diaconu",
        buttons = {
            {text = "Vreau sa cumpar abonament", response = function()
				local reply = promise.new()
				triggerCallback('buyGymSubscription', function(res)
					reply:resolve(res)
				end)
				return Citizen.Await(reply)
			end},
        },
	})

	local blip = AddBlipForCoord(pos)
	SetBlipSprite(blip, 311)
	SetBlipScale(blip, 0.6)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Los Santos Gym")
	EndTextCommandSetBlipName(blip)
end)