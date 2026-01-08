local vRP = Proxy.getInterface("vRP")

local coords = {-1828.1492919922,-1192.7012939453,14.308885574341}

local open = false
local function togglePrizes()
	open = not open
	SendNUIMessage({type = "toggle"})
	SetNuiFocus(open, open)

	if open then
		TriggerEvent("vrp-hud:updateMap", false)
		TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = false})
	end
end

RegisterNetEvent("prizes:setPrice")
AddEventHandler("prizes:setPrice", function(rollPrice, dmdPrice)
	SendNUIMessage({type = "setPrice", price = rollPrice, dmdPrice = dmdPrice})
end)

RegisterNetEvent("prizes:winSomething")
AddEventHandler("prizes:winSomething", function(winName)
	Citizen.Wait(600)
	SendNUIMessage({type = "spinTo", itemId = winName})
end)

RegisterNetEvent("prizes:noMoney", function()
	Citizen.Wait(500)
	SendNUIMessage({type = "noMoney"})
end)

RegisterNUICallback('tryGetPrize', function(data, cb)
	if open then
		TriggerServerEvent("prizes:doPayment", data.withDmd)
	else
		TriggerServerEvent("vrp:X", "vrp_prizes inject")
	end
	cb("ok")
end)

RegisterNUICallback('exit', function(data, cb)
	open = not open
	SetNuiFocus(open, open)
	TriggerEvent("vrp-hud:updateMap", true)
	TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = true})
	cb("ok")
end)


Citizen.CreateThread(function()
	local x, y, z = vRP.getPosition()
	local inputActive = false
	while true do
		Wait(1000)
		while Vdist(coords[1], coords[2], coords[3], x, y, z) <= 3 and not open do
			if not inputActive then
				inputActive = true
				TriggerEvent("vrp-hud:showBind", {key = "E", text = "Joaca la Lucky Roulette"})
			end

			if IsControlJustPressed(0, 38) then
				togglePrizes()
			end

			x, y, z = vRP.getPosition()
			Wait(1)
		end
		if inputActive then
			TriggerEvent("vrp-hud:showBind", false)
			inputActive = false
		end
		x, y, z = vRP.getPosition()
	end
end)

