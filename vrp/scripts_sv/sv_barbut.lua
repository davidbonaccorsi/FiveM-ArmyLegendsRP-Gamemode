
local userJoined = {}
local activeGames = {}
local barbutPositons = {}

local creatorGames = {}

RegisterServerEvent("vrp-barbut:startRolling")
AddEventHandler("vrp-barbut:startRolling", function()
	
	local player = source
	local dcs = {}

	math.randomseed(os.time())
	for i=1, 4 do
		dcs[i] = math.random(1, 6)
	end

	if userJoined[player] then
		local creatorId = activeGames[userJoined[player]].creator
		local creatorSrc = vRP.getUserSource(creatorId)

		if creatorSrc then
			local user_id = vRP.getUserId(player)
			local bet = tonumber(activeGames[userJoined[player]].bet)
			if bet then
				activeGames[userJoined[player]].safeBet = bet
				if vRP.tryPayment(user_id, bet) then
					if vRP.tryPayment(creatorId, bet) then
						TriggerClientEvent("vrp-barbut:getResults", player, dcs)
						TriggerClientEvent("vrp-barbut:getResults", creatorSrc, dcs, true)
						activeGames[userJoined[player]].results = dcs
					else
						vRPclient.notify(creatorSrc, {"Ai ramas fara bani", "error"})
						vRPclient.notify(player, {"Inamicul tau a ramas fara bani !\nTi-ai luat banii inapoi.", "error"})
						TriggerClientEvent("vrp-barbut:cancelGame", creatorSrc)
						TriggerClientEvent("vRP:triggerServerEvent", creatorSrc, "vrp-barbut:abortGame")
						vRP.giveMoney(user_id, bet)
					end
				else
					vRPclient.notify(player, {"Ai ramas fara bani", "error"})
					vRPclient.notify(creatorSrc, {"Inamicul tau a ramas fara bani", "error"})
					TriggerClientEvent("vrp-barbut:cancelGame", player)
					TriggerClientEvent("vRP:triggerServerEvent", player, "vrp-barbut:abortGame")
				end
			end
		else
			vRPclient.notify(player, {"Inamicul tau a parasit jocul de barbut", "error"})
			TriggerClientEvent("vrp-barbut:cancelGame", player)
			TriggerClientEvent("vrp-barbut:deletePosition", -1, creatorId)
			barbutPositons[creatorId] = nil
			creatorGames[creatorId] = nil
			activeGames[userJoined[player]] = nil
			userJoined[player] = nil
		end
	else
		vRPclient.notify(player, {"Nu esti in nici un joc", "error"})
	end
end)

RegisterServerEvent("vrp-barbut:abortGame")
AddEventHandler("vrp-barbut:abortGame", function()
	if userJoined[source] then -- player
		activeGames[userJoined[source]].inProgress = nil
		local creatorSrc = vRP.getUserSource(activeGames[userJoined[source]].creator)
		if creatorSrc then
			vRPclient.notify(creatorSrc, {GetPlayerName(source).." a renuntat la jocul de barbut.", "error"})
			TriggerClientEvent("vrp-barbut:setEnemy", creatorSrc, "...")
		end
		userJoined[source] = nil
	else -- creator
		local user_id = vRP.getUserId(source)
		for gameId, gameData in pairs(activeGames) do
			if gameData.creator == user_id then
				for src, gameJoined in pairs(userJoined) do
					if gameJoined == gameId then
						vRPclient.notify(src, {GetPlayerName(source).." a renuntat la jocul de barbut.", "error"})
						TriggerClientEvent("vrp-barbut:cancelGame", src)
						userJoined[src] = nil
					end
				end
				TriggerClientEvent("vrp-barbut:deletePosition", -1, user_id)
				barbutPositons[user_id] = nil
				creatorGames[user_id] = nil
				activeGames[gameId] = nil
				break
			end
		end
	end
end)

RegisterServerEvent("vrp-barbut:doneRolls")
AddEventHandler("vrp-barbut:doneRolls", function()
	local gameId = userJoined[source]
	if gameId then
		local dices = activeGames[gameId].results
		local bet = tonumber(activeGames[gameId].safeBet)
		local creatorId = activeGames[gameId].creator
		local creatorSrc = vRP.getUserSource(creatorId)
		if creatorSrc then
			if dices and bet then
				local user_id = vRP.getUserId(source)

				local userDices = dices[1] + dices[2]
				local creatorDices = dices[3] + dices[4]

				if userDices == creatorDices then
					vRP.giveMoney(user_id, bet)
					vRP.giveMoney(creatorId, bet)

					TriggerClientEvent("vrp-barbut:getWinFeedback", source, "EGAL")
					TriggerClientEvent("vrp-barbut:getWinFeedback", creatorSrc, "EGAL")
				else
					if userDices > creatorDices then
						vRP.giveMoney(user_id, bet * 2, "Barbut")

						local txt = vRP.formatMoney(bet * 2).."$"
						TriggerClientEvent("vrp-barbut:getWinFeedback", source, "+ "..txt)
						TriggerClientEvent("vrp-barbut:getWinFeedback", creatorSrc, "- "..txt)

						vRP.createLog(user_id, {winner = user_id, bet = bet, loser = creatorId}, "BarbutGame")
						vRP.createLog(creatorId, {winner = user_id, bet = bet, loser = creatorI}, "BarbutGame")
					else
						vRP.giveMoney(creatorId, bet * 2, "Barbut")

						local txt = vRP.formatMoney(bet * 2).."$"
						TriggerClientEvent("vrp-barbut:getWinFeedback", source, "- "..txt)
						TriggerClientEvent("vrp-barbut:getWinFeedback", creatorSrc, "+ "..txt)
					end
					
					vRP.createLog(creatorId, {winner = creatorId, bet = bet, loser = user_id}, "BarbutGame")
					vRP.createLog(user_id, {winner = creatorId, bet = bet, loser = user_id}, "BarbutGame")
				end

				activeGames[gameId].results = nil
			end
		else
			vRPclient.notify(source, {"Inamicul tau a parasit jocul de barbut", "error"})
			TriggerClientEvent("vrp-barbut:cancelGame", source)
			TriggerClientEvent("vrp-barbut:deletePosition", -1, creatorId)
			barbutPositons[creatorId] = nil
			creatorGames[creatorId] = nil
			activeGames[userJoined[source]] = nil
			userJoined[source] = nil
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		for uid, data in pairs(barbutPositons) do
			if uid == user_id then
				TriggerClientEvent("vRP:triggerServerEvent", player, "vrp-barbut:abortGame")
			else
				TriggerClientEvent("vrp-barbut:getNewPosition", player, uid, data)
			end
		end
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(250)
	vRP.defInventoryItem("dices", "Zaruri", "Cu aceste zaruri poti crea jocuri de barbut", function(player)
		vRP.prompt(player, "Barbut", "Miza:", false, function(bet)
			bet = tonumber(bet)
			if not bet then return end

			if bet > 0 then
				bet = math.floor(bet)
				local user_id = vRP.getUserId(player)
	
				local anotherGame = false
				for gameId, gameData in pairs(activeGames) do
					if gameData.creator == user_id then
						anotherGame = true 
						break
					end
				end
	
				local playerPed = GetPlayerPed(player)
				local pedPos = GetEntityCoords(playerPed)
	
				if not anotherGame or true then
					table.insert(activeGames, {
						creator = user_id,
						bet = bet
					})
					creatorGames[user_id] = #activeGames
					TriggerClientEvent("vrp-barbut:createGame", player, {name = GetPlayerName(player), bet = vRP.formatMoney(bet)})
					vRPclient.notify(player, {"Ai creeat un joc de barbut cu miza $"..vRP.formatMoney(bet) })
	
			
					barbutPositons[user_id] = {pedPos.x, pedPos.y, pedPos.z, bet}
					TriggerClientEvent("vrp-barbut:getNewPosition", -1, user_id, {pedPos.x, pedPos.y, pedPos.z, vRP.formatMoney(bet)})
					
				else
					vRPclient.sendInfo(player, {"Ai deja un joc de barbut in desfasurare", "error"})
				end
			end
		end)
	end, 0.0)
end)

vRP.registerActionsMenuBuilder("nearply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  	local choices = {}


		local needToAdd = promise.new()

        vRPclient.getNearestPlayer(player,{10},function(nplayer)
            local userID = vRP.getUserId(nplayer)
    
            needToAdd:resolve(creatorGames[userID] or false)
        end)

		local gameId = Citizen.Await(needToAdd)

        if gameId then
			choices["Joaca barbut"] = {function()
				if activeGames[gameId] then
					if not activeGames[gameId].inProgress then
						local creatorSrc = vRP.getUserSource(activeGames[gameId].creator)

						if creatorSrc then

							local gameData = {
								name = GetPlayerName(player),
								ename = GetPlayerName(creatorSrc),
								bet = vRP.formatMoney(activeGames[gameId].bet)
							}

							activeGames[gameId].inProgress = player
							userJoined[player] = gameId
							TriggerClientEvent("vrp-barbut:joinGame", player, gameId, gameData)
							TriggerClientEvent("vrp-barbut:setEnemy", creatorSrc, GetPlayerName(player))
							vRPclient.notify(creatorSrc, {GetPlayerName(player).." a intrat in joc", "success"})
						else
							vRPclient.sendError(player, {"Jucatorul care a propus jocul de barbut nu mai este online"})
						end
					else
						vRPclient.sendError(player, {"Jocul de barbut este deja in desfasurare"})
					end
				else
					vRPclient.sendError(player, {"Nu exista un joc deschis de acel jucator !"})
				end
			end, "barbut.svg"}
		end
  
		add(choices)
	end
end)

RegisterServerEvent("vrp-barbut:changeBet")
AddEventHandler("vrp-barbut:changeBet", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		local gameId = 0
		for gmId, gameData in pairs(activeGames) do
			if gameData.creator == user_id then 
				gameId = gmId
				break
			end
		end
		if gameId > 0 then
			local emenySrc = activeGames[gameId].inProgress
			if emenySrc then
				TriggerClientEvent("vrp-hud:runjs", emenySrc, "barbut.rolling = true;")
			end
			vRP.prompt(player, "Barbut", "Miza Noua:", false, function(stringBet) 
				if stringBet then
					if stringBet:len() > 0 then
						local bet = tonumber(stringBet) or 0

						if bet > 0 then
							bet = math.floor(bet)
							TriggerClientEvent("vrp-barbut:setNewBet", player, bet)
							if emenySrc then
								TriggerClientEvent("vrp-barbut:setNewBet", emenySrc, bet)
							end
							activeGames[gameId].bet = bet
						else
							TriggerClientEvent("vrp-barbut:setNewBet", player, activeGames[gameId].bet)
							if emenySrc then
								TriggerClientEvent("vrp-barbut:setNewBet", emenySrc, activeGames[gameId].bet)
							end
						end
					else
						TriggerClientEvent("vrp-barbut:setNewBet", player, activeGames[gameId].bet)
						if emenySrc then
							TriggerClientEvent("vrp-barbut:setNewBet", emenySrc, activeGames[gameId].bet)
						end
					end
				else
					TriggerClientEvent("vrp-barbut:setNewBet", player, activeGames[gameId].bet)
					if emenySrc then
						TriggerClientEvent("vrp-barbut:setNewBet", emenySrc, activeGames[gameId].bet)
					end
				end
			end, true)
		end
	end
end)