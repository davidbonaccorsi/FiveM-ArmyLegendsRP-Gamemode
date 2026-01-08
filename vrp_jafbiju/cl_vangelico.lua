local vRP = exports.vrp:link()
local resName = GetCurrentResourceName()

local function callback(cbName, cb, ...)
	TriggerServerEvent(resName..":s_callback:"..cbName, ...)
	return RegisterNetEvent(resName..":c_callback:"..cbName, function(...)
		cb(...)
	end)
end

function triggerCallback(cbName, cb, ...)
	local ev = false
	local f = function(...)
		if ev ~= false then
			RemoveEventHandler(ev)
		end
		cb(...)
	end
	ev = callback(cbName, f, ...)
	return ev
end

local gameFinish
RegisterNUICallback("vangelico:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish()
    end
    gameFinish = false
    
    cb("ok")
end)

RegisterNUICallback("setFocus", function(data, cb)
    SetNuiFocus(data[1], data[1])
    cb("ok")
end)

local objs = {}
AddEventHandler("onResourceStop", function(res)
	if res == resName then
		for k, object in pairs(objs) do
			DeleteEntity(object)
		end
		objs = {}
	end
end)

local bijuArea = vec3(-622.12969970703,-230.79737854004,38.057075500488)

local robPositions = {
	{-627.2122, -234.895, 37.64523, "des_jewel_cab3_start", "des_jewel_cab3_end"},
	{-626.1615, -234.1316, 37.64523, "des_jewel_cab4_start", "des_jewel_cab4_end"},
	{-627.595, -234.3683, 37.64523},
	{-626.5442, -233.6049, 37.54623},
	{-625.275, -238.2881, 37.64523, "des_jewel_cab3_start", "des_jewel_cab2_end"},
	{-626.3253, -239.0511, 37.64523, "des_jewel_cab2_start", "des_jewel_cab2_end"},
	{-625.3298, -227.3696, 37.64523},
	{-619.9666, -226.1982, 37.64523},
	{-619.2035, -227.2485, 37.64523, "des_jewel_cab2_start", "des_jewel_cab2_end"},
	{-617.086, -230.163, 37.64523},
	{-618.7983, -234.1508, 37.64523},
	{-619.8483, -234.9137, 37.64523},
	{-617.8491, -229.1127, 37.64523},
	{-624.2798, -226.6067, 37.64523},
	{-620.5214, -232.8823, 37.64523},
	{-623.6131, -228.6263, 37.64523},
	{-623.9567, -230.7202, 37.64523},
	{-622.6159, -232.5636, 37.64523},
}

local canRob = true
local pedPos = GetEntityCoords(PlayerPedId())
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(bijuArea)
	SetBlipSprite(blip,674)
	SetBlipColour(blip,46)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Bijuteria Vangelico")
	EndTextCommandSetBlipName(blip)
	while true do
		pedPos = GetEntityCoords(PlayerPedId())
		Citizen.Wait(200)
	end
end)


RegisterNetEvent("vrp-biju:setState")
AddEventHandler("vrp-biju:setState", function(state)
	canRob = state
end)

RegisterNetEvent("vrp-biju:sendCoords")
AddEventHandler("vrp-biju:sendCoords", function(cpData)
	local bps = {}
	local inRob = true

	for _, pos in pairs(robPositions) do
		local id = AddBlipForCoord(pos[1], pos[2], pos[3])
		SetBlipSprite(id, 618)
		SetBlipColour(id, 73)
		SetBlipScale(id, 0.45)
		SetBlipAsShortRange(id, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Masa Bijuterii")
		EndTextCommandSetBlipName(id)
		
		table.insert(bps, id)
	end

	Citizen.CreateThread(function()
		local requestInteract = {}
		local tblThatWereRobbed = {}

        vRP.subtitle("Ai inceput sa jefuiesti ~y~Bijuteria Vangelico~w~, misca-te repede !")

		while inRob do

			if #(bijuArea - pedPos) > 15 then
				TriggerServerEvent("vrp-biju:cancelRob")
				inRob = false
				break
			end

			for tblId, pos in pairs(robPositions) do
				local dist = #(vec3(pos[1], pos[2], pos[3]) - pedPos)
				if dist <= 8.5 then

					local wasRobbed = tblThatWereRobbed[tblId]

					if dist <= 1 and not wasRobbed then
						if not requestInteract[tblId] then
							requestInteract[tblId] = true
							TriggerEvent("vrp-hud:showBind", {key = "E", text = "Fura din vitrina"})
						end

						if IsControlJustReleased(0, 51) then

							local weap = GetSelectedPedWeapon(PlayerPedId())
							if not weap then
								TriggerEvent("vrp-hud:notify", "Nu poti sparge vitrina fara o arma!", "error")
							else
								TriggerEvent("vrp-hud:showBind", false)
								RequestAnimDict("missheist_jewel")
								while not HasAnimDictLoaded("missheist_jewel") do
									Citizen.Wait(1)
								end

                                local evt, p = nil, promise.new()
                                evt = RegisterNetEvent("vrp-biju:robSuccess", function(wins)
                                    SendNUIMessage({interface = "vangelico", wins = wins})
                                    gameFinish = function()
                                        TriggerServerEvent("vrp-biju:robCoords", cpData)
                                        p:resolve(true)
										RemoveEventHandler(evt)
									end
                                end)
                                TriggerServerEvent("vrp-biju:tryToRob", cpData)

								TaskPlayAnim(PlayerPedId(), 'missheist_jewel', 'smash_case', 1.0, -1.0,-1,1,0,0, 0,0)
								Citizen.Wait(1500)
								CreateModelSwap(pos[1], pos[2], pos[3], 0.1, GetHashKey(pos[4] or "des_jewel_cab_start"), GetHashKey(pos[5] or "des_jewel_cab_end"), false)
								PlaySoundFromCoord(-1, "Glass_Smash", pos[1], pos[2], pos[3], 0, 0, 0)
								Citizen.Wait(3000)
								tblThatWereRobbed[tblId] = true

                                Citizen.Await(p)
								
                                Citizen.Wait(500)
								ClearPedTasks(PlayerPedId())
								requestInteract[tblId] = nil
							end


						end
					elseif requestInteract[tblId] then
						TriggerEvent("vrp-hud:showBind", false)
						requestInteract[tblId] = nil
					end

					if not wasRobbed then
						DrawMarker(3, pos[1], pos[2], pos[3] + 0.5, 0, 0, 0, 0, 0, 0, 0.15, 1.25, 0.15, 239, 202, 87, 105, true, true, false)
					else
						DrawMarker(3, pos[1], pos[2], pos[3] + 0.5, 0, 0, 0, 0, 0, 0, 0.15, 1.25, 0.15, 153, 34, 18, 105, true, true, false)
					end
				end
			end

			Citizen.Wait(1)
		end

		for _, id in pairs(bps) do
			RemoveBlip(id)
		end
	end)
end)


AddEventHandler("CEventGunShot", function(none, eventEnt, possibleData)
	if (eventEnt == PlayerPedId()) and canRob and (#(bijuArea - pedPos) <= 10) then
        local weapon = GetSelectedPedWeapon(PlayerPedId())

        if weapon then
		    TriggerServerEvent("vrp-biju:startRobbing")
        end
	end
end)
