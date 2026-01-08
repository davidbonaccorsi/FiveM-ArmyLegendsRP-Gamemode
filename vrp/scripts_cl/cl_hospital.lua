local isJoiningBed = false
local inTreatment = false
local hospitalBeds = {}

local function disableControls()
	DisableControlAction(0, 24, true) 
	DisableControlAction(0, 257, true)
	DisableControlAction(0, 25, true)
	DisableControlAction(0, 263, true)
	DisableControlAction(0, 32, true)
	DisableControlAction(0, 34, true)
	DisableControlAction(0, 31, true)
	DisableControlAction(0, 30, true)
	DisableControlAction(0, 45, true)
	DisableControlAction(0, 44, true)
	DisableControlAction(0, 37, true)
	DisableControlAction(0, 23, true)
	DisableControlAction(0, 289, true)
	DisableControlAction(0, 170, true)
	DisableControlAction(0, 167, true)
	DisableControlAction(0, 0, true)
	DisableControlAction(0, 26, true)
	DisableControlAction(0, 73, true)
	DisableControlAction(2, 199, true)
	DisableControlAction(0, 59, true)
	DisableControlAction(0, 71, true)
	DisableControlAction(0, 72, true)
	DisableControlAction(2, 36, true)
	DisableControlAction(0, 47, true)
	DisableControlAction(0, 264, true)
	DisableControlAction(0, 257, true)
	DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)
	DisableControlAction(0, 143, true)
	DisableControlAction(0, 75, true)
	DisableControlAction(27, 75, true)
end

local function drawText(text, x, y, scale, r, g, b)
	SetTextFont(0)
	SetTextCentre(1)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextDropShadow(30, 5, 5, 5, 255)
	SetTextEntry("STRING")
	SetTextColour(r, g, b, 255)
	AddTextComponentString(text)
	DrawText(x, y)
end

local function joinBed(theBed, htype)
	inTreatment = true
	local bedData = hospitalBeds[htype][theBed]
	loadAnimDict("amb@lo_res_idles@")

	tvRP.setHealth(cfg.coma_threshold + 5) -- min coma treshold + 5hp sa nu si dea disconnect
	local x, y, z = table.unpack(bedData.pos) 
	RequestCollisionAtCoord(x, y, z)
	while not HasCollisionLoadedAroundEntity(tempPed) do
		Citizen.Wait(100)
	end
	SetEntityCoords(tempPed, x, y, z-1.0, true, false, false, false)
	FreezeEntityPosition(tempPed, true)
	SetEntityHeading(tempPed, bedData.pos[4])

	tvRP.notify("Ai fost internat in spital iar un medic te va ajuta cat de curand!", "error")

	CreateThread(function()
		math.randomseed(GetGameTimer())
		local addedTime = 1
		local donePercent = 0

		CreateThread(function()
			while inTreatment do
				donePercent = donePercent + 1
				Wait(2000 * addedTime)
			end
		end)

		while inTreatment do
			if donePercent >= 100 then
				inTreatment = false
			end

			disableControls()

			if IsEntityPlayingAnim(tempPed, 'amb@lo_res_idles@', 'world_human_bum_slumped_left_lo_res_base', 3) ~= 1 then
				TaskPlayAnim(tempPed, "amb@lo_res_idles@", "world_human_bum_slumped_left_lo_res_base", 5.0, 1.0, -1, 33, 0, 0, 0, 0)
			end

			drawText("Te afli sub tratament !~n~~r~"..donePercent.."% vindecat", 0.5, 0.85, 0.4, 255, 255, 255)

			DisablePlayerFiring(tempPlayer, true)
			Wait(1)
		end

		tvRP.setHealth(200)

		DisablePlayerFiring(tempPlayer, false)
		ClearPedTasks(tempPed)
		FreezeEntityPosition(tempPed, false)
		tvRP.playAnim(false, {{"switch@franklin@bed", "sleep_getup_rubeyes"}})
		tvRP.notify("Un medic te-a ingrijit si ai fost externat!", "info")
		TriggerServerEvent("vrp-hospitals:leaveBed")
	end)
end

local function drawArrow(coords, label)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    local icon_scale = 1.0
    local text_scale = 0.25

    RequestStreamedTextureDict("basejumping", false)
    DrawSprite("basejumping", "arrow_pointer", screenX, screenY - 0.015, 0.015 * icon_scale, 0.025 * icon_scale, 180.0, 255, 0, 0, 255)

    SetTextCentre(true)
    SetTextScale(0.0, text_scale)
    SetTextEntry("STRING")
    AddTextComponentString(label)
    DrawText(screenX, screenY)
end


RegisterNetEvent("populateHospitals", function(x, hospitals)
	hospitalBeds = x

	Citizen.CreateThread(function()
		for k, v in pairs(hospitals) do
			local enterPos = v[1]
			if not v[3] then
				tvRP.addBlip("vRP:hospitalBeds:"..k, enterPos[1], enterPos[2], enterPos[3], 107, 1, "Spital", 0.5)
			end
		end

		local inputActive = false

		while true do
			for k, v in pairs(hospitals) do
				local dst = #(v[1] - pedPos)

				while dst <= 12.5 do
					drawArrow(v[1], "Punct de internare")

					if dst <= 2 then

						if not inputActive then
							inputActive = true
							TriggerEvent("vrp-hud:showBind", {key = "E", text = "Interneaza-te in spital"})
						end

						if IsControlJustReleased(0, 38) then
							if not isJoiningBed then
								isJoiningBed = true
			
								triggerCallback("hospital:getBed", function(theBed)
									if theBed then
										vRPserver.canReviveAtHospital({}, function(canRevive)
											if canRevive then
												FreezeEntityPosition(tempPed, true)
												TriggerEvent("vrp:progressBar", {
													duration = 5000,
													text = "Analizam fisa medicala..",
												}, function()
													FreezeEntityPosition(tempPed, false)
													TriggerServerEvent("vrp-hospitals:getInBed", v[2], theBed)
													isJoiningBed = false
			
													tvRP.notify("Ai platit $200", "success")
													joinBed(theBed, v[2])

													TriggerEvent("vrp-hud:showBind", false)
													inputActive = false
												end)
											else
												isJoiningBed = false
											end
										end)
									else
										isJoiningBed = false
										tvRP.notify("Nu sunt locuri libere pentru internare!", "error")
									end
								end, v[2])
							end
						end
					elseif inputActive then
						TriggerEvent("vrp-hud:showBind", false)
						inputActive = false
					end

					Citizen.Wait(1)
					dst = #(v[1] - pedPos)
				end
			end

			if inputActive then
				TriggerEvent("vrp-hud:showBind", false)
				inputActive = false
			end

			Citizen.Wait(1024)
		end
	end)
end)

function tvRP.isHospitalTreated()
	return inTreatment
end

