
local inGame = false
local theBet = 0

local function rollAnim()
	local anim = {"anim@mp_player_intcelebrationmale@wank", "wank"}
	while not HasAnimDictLoaded(anim[1]) do
		RequestAnimDict(anim[1])
		Citizen.Wait(10)
	end

	local ped = tempPed

	TaskPlayAnim(ped, anim[1], anim[2], 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Citizen.Wait(1500)
	ClearPedTasks(ped)
end

RegisterNetEvent("vrp-barbut:cancelGame")
AddEventHandler("vrp-barbut:cancelGame", function()
	inGame = false
	exports.vrp:runjs("barbut.destroy();")
end)

RegisterNetEvent("vrp-barbut:getWinFeedback")
AddEventHandler("vrp-barbut:getWinFeedback", function(text)
	exports.vrp:runjs([[
		barbut.feedback = "]]..text..[[";

		setTimeout(() => {
			barbut.feedback = false;
		}, 3500)
	]])
end)


local dcs = {}
RegisterNetEvent("vrp-barbut:getResults")
AddEventHandler("vrp-barbut:getResults", function(results, withFakeRolls)
	dcs = results
	if withFakeRolls then
		Citizen.CreateThread(rollAnim)
		exports.vrp:runjs([[
			barbut.rolling = true;
			barbut.roll();
			setTimeout(() => {
				barbut.rolling = false;
				barbut.post("barbut:getResults", [true]);
			}, 4000)
		]])
	end

end)

RegisterNUICallback("barbut:getResults", function(data, cb)
	local withFakeRolls = data[1]

	if withFakeRolls then
		exports.vrp:runjs("barbut.results = ["..dcs[3]..", "..dcs[4]..", "..dcs[1]..", "..dcs[2].."];")
	else
		exports.vrp:runjs("barbut.results = ["..dcs[1]..", "..dcs[2]..", "..dcs[3]..", "..dcs[4].."];")
	end

	exports.vrp:runjs([[
		for (let i = 0; i < barbut.results.length; i++) {
			barbut.dcsObj[i].css("background-image", `url(../../public/dices/${barbut.results[i]}.png)`);
		}
	]])

	cb("ok")
end)

RegisterNetEvent("vrp-barbut:setNewBet")
AddEventHandler("vrp-barbut:setNewBet", function(newBet)
	theBet = newBet
	exports.vrp:runjs("barbut.bet = "..newBet.."; barbut.rolling = false;")
	Citizen.Wait(500)
end)

RegisterNetEvent("vrp-barbut:joinGame")
AddEventHandler("vrp-barbut:joinGame", function(gameId, gameData)
	inGame = true
	theBet = gameData.bet

	SendNUIMessage({
		interface = "barbut",
		bet = theBet,
		role = "player",
		playerTags = {gameData.name, gameData.ename},
	})
end)

RegisterNetEvent("vrp-barbut:setEnemy")
AddEventHandler("vrp-barbut:setEnemy", function(name)
	exports.vrp:runjs("barbut.enemy = '"..name.."';")
	
	if name == "..." then
		exports.vrp:runjs("barbut.results = false;")
	end
end)

RegisterNetEvent("vrp-barbut:createGame")
AddEventHandler("vrp-barbut:createGame", function(gameData)
	inGame = true
	theBet = gameData.bet

	SendNUIMessage({
		interface = "barbut",
		bet = theBet,
		role = "creator",
		playerTags = {gameData.name, "..."},
	})
end)

RegisterNUICallback("barbut:abortGame", function(data, cb)
	inGame = false
	TriggerServerEvent("vrp-barbut:abortGame")
	cb("ok")
end)


RegisterNUICallback("barbut:startRoll", function(data, cb)
	TriggerServerEvent("vrp-barbut:startRolling")
	Citizen.CreateThread(rollAnim)
	cb("ok")
end)

local barbutLocations = {}

RegisterNetEvent("vrp-barbut:getNewPosition")
AddEventHandler("vrp-barbut:getNewPosition", function(posIndex, posData)
	barbutLocations[posIndex] = posData
end)

RegisterNetEvent("vrp-barbut:deletePosition")
AddEventHandler("vrp-barbut:deletePosition", function(posIndex)
	barbutLocations[posIndex] = nil
end)


Citizen.CreateThread(function()
	local txd = CreateRuntimeTxd("barbutGame")
	CreateRuntimeTextureFromImage(txd, "info", "assets/barbutGame.png")
end)

local function DrawImage3D(name, x, y, z, width, height, rot) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, true)
	
    if onScreen then
		local width = (1/dist)*width
		local height = (1/dist)*height
		local fov = (1/GetGameplayCamFov())*100
		local width = width*fov
		local height = height*fov
	
		DrawSprite("barbutGame", name, _x, _y, width, height, rot, 255, 255, 255, 255)
	end
end

Citizen.CreateThread(function()
	local nearGames = {}
	local ped = tempPed

	Citizen.CreateThread(function()
		while true do
            local ticks = 200
			if inGame then
				Citizen.Wait(5000)
			else
				for i, v in pairs(nearGames) do
                    ticks = 1
					if v then
                        DrawImage3D("info", v[1], v[2], v[3] + 1.1, 0.094, 0.16, 0.0)
					end
				end
			end
			Citizen.Wait(ticks)
		end
	end)

	while true do
		Citizen.Wait(1500)
		nearGames = {}
		if inGame then
			InvalidateIdleCam()
			InvalidateVehicleIdleCam()
			Citizen.Wait(5000)
		else
			ped = tempPed
			if not IsPedSittingInAnyVehicle(ped) then 
				local pedCoords = GetEntityCoords(ped)
				for indx, data in pairs(barbutLocations) do
					local dst = GetDistanceBetweenCoords(pedCoords, data[1], data[2], data[3], false)
					if dst < 10 then
						nearGames[indx] = data
					end
				end
			end
		end
	end

end)