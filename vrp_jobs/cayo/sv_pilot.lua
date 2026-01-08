
local destinations = {
	["Los Santos"] = {
		prices = {
			["Grapeseed"] = 7500,
			["Cayo Perico"] = 10000
		},
		planeSpawn = {-1218.3823242188,-2623.6911621094,14.871240615845,33.43},
		plane = {-1030.6369628906,-2974.9045410156,13.946404457092}, 
		pilot = {-1185.9552001953,-2673.7973632813,13.94441986084},
		client = {-1038.1479492188,-2738.2143554688,20.1692943573}
	},
	["Grapeseed"] = {
		prices = {
			["Los Santos"] = 10000,
			["Cayo Perico"] = 20000
		},
		planeSpawn = {2142.4621582031,4816.0498046875,42.182922363281,115.27},
		plane = {2126.1740722656,4797.3369140625,41.141120910645},
		pilot = {2136.107421875,4796.8500976563,41.138900756836},
		client = {2162.3071289063,4806.3354492188,41.18578338623}
	},
	["Cayo Perico"] = {
		prices = {
			["Los Santos"] = 17500,
			["Grapeseed"] = 20000
		},
		planeSpawn = {4450.26171875,-4516.0849609375,5.1197500228882,110.48},
		plane = {4449.322265625,-4486.9711914063,4.2186441421509},
		pilot = {4425.5776367188,-4456.4013671875,4.3284096717834},
		client = {4512.0610351563,-4544.9243164063,4.1781349182129}
	},
}

local planeHash, missionCooldown, activeFlights = GetHashKey("velum2"), {}, {}

RegisterServerEvent("vrp-pilot:startMission")
AddEventHandler("vrp-pilot:startMission", function(localPosition)
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		
		if vRP.hasLevel(user_id, 50) then -- 10

			if (missionCooldown[localPosition] or 0) <= os.time() then

				missionCooldown[localPosition] = os.time() + 60

				local locationMenu = {name = "Location"}

				for name, destData in pairs(destinations) do
					if name ~= localPosition then
						locationMenu[name] = {function(player)
							TriggerEvent("ac:getSpawnPoint", player)

							TriggerClientEvent("vrp-pilot:spawnPlane", player, {
								hash = planeHash,
								pos = destinations[localPosition].planeSpawn
							}, destData.plane, destData.pilot)

							vRPclient.notify(player, {"Daca nu ai nici un pasager, nu o sa primesti nici un ban"})

							vRP.closeMenu(player)

							activeFlights[player] = {
								pilotName = GetPlayerName(player), 
								from = localPosition, 
								to = name, 
								passagers = 0, 
								clients = {},
								inAir = false, 
								price = destinations[localPosition].prices[name]
							}

						end, "<i class='fa-duotone fa-plane'></i>", "Incepe un zbor catre "..name}
					end
				end

				vRP.openMenu(player, locationMenu)
				
			else
				vRPclient.notify(player, {"Asteapta "..(missionCooldown[localPosition] - os.time()).." secunde", "error"})
			end

		else
			vRPclient.notify(player, {"Ai nevoie de nivel 50 pentru a practica acest job", "error"})
		end
	end
end)

RegisterServerEvent("vrp-pilot:flightArrived")
AddEventHandler("vrp-pilot:flightArrived", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if activeFlights[player] then
		for src, _ in pairs(activeFlights[player].clients) do
			if vRP.getUserId(src) then
				local pos = destinations[activeFlights[player].to].client
				TriggerClientEvent("vrp-pilot:flightDone", src, pos)
				vRPclient.notify(src, {"Ai ajuns la destinatie", "success"})
			end
		end

		math.randomseed(os.time() * GetGameTimer() * user_id)
		
		local passagers = activeFlights[player].passagers
		vRP.giveJobMoney(user_id, math.random(3500, 4000), "Pilot")

		if passagers == 0 then
			vRPclient.notify(player, {"Ai ajuns la destinatie, dar nu ai primit nici un ban deoarece nu ai avut nici un pasager", "success"})
		else
			if passagers == 1 then
				vRPclient.notify(player, {"Ai ajuns la destinatie, cu un pasager", "success"})
			else
				vRPclient.notify(player, {"Ai ajuns la destinatie, cu "..passagers.." pasageri", "success"})
			end
		end

		activeFlights[player] = nil
	end
end)

RegisterServerEvent("vrp-pilot:planeTookOff")
AddEventHandler("vrp-pilot:planeTookOff", function()
	local player = source
	if activeFlights[player] then
		activeFlights[player].inAir = true

		exports.vrp:achieve(vRP.getUserId(player), 'PilotEasy', 1)
	end
end)

RegisterServerEvent("vrp-pilot:flightCanceled")
AddEventHandler("vrp-pilot:flightCanceled", function()
	local player = source
	if activeFlights[player] then
		for src in pairs(activeFlights[player].clients) do
			local pos = destinations[activeFlights[player].from].client
			TriggerClientEvent("vrp-pilot:flightDone", src, pos)
			vRPclient.notify(src, {"Din pacate zborul tau s-a anulat", "error"})
		end

		activeFlights[player] = nil
	end
end)

RegisterServerEvent("vrp-pilot:setPlane")
AddEventHandler("vrp-pilot:setPlane", function(networkId)
	local player = source
	if activeFlights[player] then
		activeFlights[player].nid = networkId
	end
end)

RegisterServerEvent("vrp-pilot:startFlight")
AddEventHandler("vrp-pilot:startFlight", function(localPosition)
	local player = source
	local locationMenu = {name = "Location"}

	local availableFlights = 0

	for pilot, data in pairs(activeFlights) do
		if data.from == localPosition then

			if not data.inAir and data.passagers < 4 then

				availableFlights = availableFlights + 1

				locationMenu[data.to] = {function(player)

					if not activeFlights[pilot].inAir then
						if activeFlights[pilot].passagers < 4 then

							local user_id = vRP.getUserId(player)

							if vRP.tryPayment(user_id, data.price, false, "Plane Flight") then

								TriggerClientEvent("vrp-pilot:getInPlane", player, data.nid, activeFlights[pilot].passagers)

								activeFlights[pilot].clients[player] = true
								activeFlights[pilot].passagers += 1

								Citizen.Wait(1200)
								vRPclient.getPosition(pilot, {}, function(x, y, z)
									vRPclient.teleport(player, {x, y, z-10.0})
								end)

								TriggerClientEvent("vrp-pilot:setPassangers", pilot, activeFlights[pilot].passagers)
							else
								vRPclient.notify(player, {"Nu ai destui bani", "error"})
							end
						else
							vRPclient.notify(player, {"Nu mai sunt locuri in acel zbor", "error"})
						end
					else
						vRPclient.notify(player, {"Acel zbor a decolat deja", "error"})
					end

					vRP.closeMenu(player)

				end, "Pilot: <font color='#7ac3fe'>"..data.pilotName.."</font><br/>Pret: <font color='lightgreen'>$"..vRP.formatMoney(data.price).."</font>"}
			end
		end
	end

	if availableFlights == 0 then
		locationMenu["Nici un zbor activ..."] = {function() end, "", "Asteapta pentru ca un pilot sa faca un zbor catre o destinatie."}
	end

	vRP.openMenu(player, locationMenu)
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	if activeFlights[player] then
		for src, _ in pairs(activeFlights[player].clients) do
			local pos = destinations[activeFlights[player].from].client
			TriggerClientEvent("vrp-pilot:flightDone", src, pos)
			vRPclient.notify(src, {"Din pacate zborul tau s-a anulat", "error"})
		end

		activeFlights[player] = nil
	end
end)
