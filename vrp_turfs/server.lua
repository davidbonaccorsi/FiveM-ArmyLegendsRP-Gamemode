local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_turfs")
vRPturfs = Tunnel.getInterface("vRP_turfs", "vRP_turfs")

local allTurfs = {}
local warStatement = {}
local warTimeState = {}


Citizen.CreateThread(function() 
	Citizen.Wait(2000)
	exports.mongodb:find({collection = "turfs"}, function(success, result)
		allTurfs = result or {}
		for k, v in pairs(allTurfs) do
			if not vRP.getFactionByColor(v.color) then
				allTurfs[k].color = 37
			end
		end
		build_player_turfs(-1)
	end)
end)

local warTime = 20 -- minute de war intre mafii
local warInterval = {20, 22}

local function isAnAdmin(user_id, risk)
    if true then
        return true
    end

    if risk == 2 then
        return vRP.isUserOwner(user_id)
    else
        return vRP.isUserMod(user_id)
    end
end

local function msg(player, ...)
    TriggerClientEvent("chatMessage", player, ...)
end
local function sendError(player, error)
    msg(player, "^1Eroare^7: "..error, 'info')
end
local function noAccess(player)
    sendError(player,"Nu ai acces la aceasta comanda.",'info')
end
local function sendSyntax(player, syntax)
    msg(player,"^5Sintaxa^7: "..syntax, 'info')
end
local function sendInfo(player, info)
    msg(player, "^5Info^7: "..info, 'info')
end

RegisterCommand("addturf", function(player, args)
	local user_id = vRP.getUserId(player)
	if isAnAdmin(user_id, 2) then
		vRPclient.getPosition(player, {}, function(x, y, z)
			if #args >= 1 then
				local radius = math.floor(tonumber(args[1]))
				if radius > 5 then
					exports.mongodb:findOne({collection = "turfs", options = {sort = {id = -1}, projection = {id = 1}}}, function(success, result)
						local nextId = 0
						if #result > 0 then nextId = result[1].id end
						exports.mongodb:insertOne({collection = "turfs", document = {id = nextId + 1, x = x, y = y, z = z, radius = radius, color = 37}})
						Citizen.Wait(30)
						exports.mongodb:find({collection = "turfs"}, function(success, result)
							allTurfs = result or {}
							Citizen.Wait(30)
							build_player_turfs(-1)
						end)
					end)
				else
					sendError(player, "Radius prea mic !")
				end
			else
				sendSyntax(player, "/addturf <radius>")
			end
		end)
	else noAccess(player) end
end)

function setTurfColor(turfId, color, rebuild)
	exports.mongodb:updateOne({collection = "turfs", query = {id = turfId}, update = {['$set'] = {color = color}}}, function(success)
		exports.mongodb:find({collection = "turfs"}, function(success, result)
			allTurfs = result or {}
			Citizen.Wait(1000)

			if rebuild then
				build_player_turfs(-1)
			else
				TriggerClientEvent("turfs:setColor", -1, turfId, color)
			end
		end)
	end)
end

function getTurfColor(turfId)
	for k, v in pairs(allTurfs) do
		if v.id == turfId then
			return v.color
		end
	end
	return 0
end

local function isWarInterval()


	local hour = tonumber(os.date("%H"))
	local minute = tonumber(os.date("%M"))
	local curDay = tonumber(os.date("%w"))

    if true then return true end

	if hour == warInterval[2]-1 and curDay % 2 == 1 then
		return (minute <= 40)
	else
		return ((hour >= warInterval[1] and hour < warInterval[2]) and (curDay % 2 == 1))
	end
end


local cooldownSelf = {}
local cooldownProtect = {}

local attackCooldown = {}

function tryAttackTurf(player)
	local user_id = vRP.getUserId(player)
	local uFaction = vRP.getUserFaction(user_id)
	if (attackCooldown[player] or 0) <= os.time() then
		attackCooldown[player] = os.time() + 3
		local fType = vRP.getFactionType(uFaction)
		if fType == "Mafie" then
			if vRP.isUserCoLeader(user_id) or vRP.isFactionLeader(user_id, uFaction) then
				if not isWarInterval() then
					sendError(player, "Intervalul war-urilor este: ^1Luni, Miercuri, Vineri^7 intre orele ^1"..warInterval[1]..":00 ^7-> ^1"..warInterval[2]..":00")
					return
				end
				if (cooldownSelf[uFaction] or 0) <= os.time() then
					if not isFactionInWar(uFaction) then
						vRPturfs.isInTurf(player, {0}, function(onTurf)
							if onTurf then
								vRPclient.isInComa(player, {}, function(inComa)
									if not inComa then
										if warStatement[onTurf] then
											sendError(player, "Deja acest turf este intr-un war")
											return
										end
										local tColor = getTurfColor(onTurf)
										local uColor = vRP.getFactionColor(uFaction)
										if tColor ~= uColor then
											local uPlayers = 0
											vRP.doFactionFunction(uFaction, function(src)
												uPlayers = uPlayers + 1
											end)
											if tColor == 37 then -- not owned
                                                setTurfColor(onTurf, uColor)
                                                TriggerClientEvent("turfs:setColor", -1, onTurf, uColor)

                                                sendInfo(player, "Ai primit turf-ul pe care ai dat attack deoarece nu este detinut")
											else
												local tFaction = vRP.getFactionByColor(tColor)
												if tFaction then
													if not isFactionInWar(tFaction) then

														if (cooldownProtect[tFaction] or 0) <= os.time() then

															local tPlayers = 0
															vRP.doFactionFunction(tFaction, function(src)
																tPlayers = tPlayers + 1
															end)
															if tPlayers ~= 0 then
																sendInfo(player, "Ai inceput sa cuceresti un teritoriu detinut de ^1"..tFaction)
																vRP.doFactionFunction(uFaction, function(src)
																	sendInfo(src, "^1"..uFaction.." ^7a inceput un atac asupra unui teritoriu detinut de ^1"..tFaction)
																	msg(src, "Du-te si ajuta-ti mafia sa castige !")

																end, player)
																vRP.doFactionFunction(tFaction, function(src)
																	sendInfo(src, "^1"..uFaction.." ^7a inceput un atac asupra unui teritoriu detinut de mafia ta")
																	msg(src, "Du-te si apara-ti teritoriul !")

																end)
																startWar(onTurf, uFaction, tFaction, uColor, tColor)
															else
																sendError(player, "Factiunea inamica nu are membrii conectati pe server.")
															end
														else
															sendError(player, "Factiunea pe care doresti sa o ataci are protectie ^3"..cooldownProtect[tFaction]-os.time().." ^7secunde")
														end
													else
														sendError(player, "^1"..tFaction.." ^7 este deja intr-un war")
													end
												else
													setTurfColor(onTurf, 37)
                                                    TriggerClientEvent("turfs:setColor", -1, onTurf, 37)
                                                    Citizen.Wait(200)
													tryAttackTurf(player)
												end
											end
										else
											sendInfo(player, "Mafia ta detine deja acest teritoriu")
										end
									else
										sendError(player, "Nu poti ataca un turf daca esti lesinat")
									end
								end)
							else
								sendInfo(player, "Nu esti pe nici un turf\nFoloseste ^1/turfs ^7pentru a vedea pe harta turf-urile")
							end
						end)
					else
						sendError(player, "Mafia ta este deja intr-un war")
					end
				else
					sendError(player, "Cooldown ^3"..cooldownSelf[uFaction]-os.time().." ^7secunde")
				end
			else
				sendError(player, "Doar liderul si co-liderul poate ataca un turf")
			end
		else
			sendError(player, "Nu faci parte dintr-o mafie")
		end
	else
		sendError(player, "Cooldown "..attackCooldown[player]-os.time().." sec")
	end
end


RegisterServerEvent("turfs:playerDied")
AddEventHandler("turfs:playerDied", function(killer_src, headShot)
	local player = source
	local user_id = vRP.getUserId(player)

	for k, v in pairs(warStatement) do
		vRPturfs.isInTurf(player, {k}, function(inTurf)
			if inTurf then
				local theFaction = vRP.getUserFaction(user_id)
				
				Citizen.CreateThread(function()
					Citizen.Wait(2000)
					vRPclient.setHealth(player, {200})
					if vRP.getFactionType(theFaction) == "Mafie" then
						vRP.spawnAtFactionHome(user_id)
					end
					local thisTurf = allTurfs[k]
					vRPclient.setGPS(player, {thisTurf.x + 0.0001, thisTurf.y + 0.0001})
				end)


				local killer_id = vRP.getUserId(killer_src)
				local hisFaction = vRP.getUserFaction(killer_id)

				local showKill = (hisFaction == v.uFaction and theFaction == v.tFaction) or (hisFaction == v.tFaction and theFaction == v.uFaction)
				
				local logColor = 1
				if theFaction == v.uFaction then
					v.tScore = v.tScore + 1

				elseif theFaction == v.tFaction then
					v.uScore = v.uScore + 1
					logColor = not logColor
				end
				vRP.doFactionFunction(v.uFaction, function(src)
                    TriggerClientEvent("turfs:setScore", src, v.uFaction, v.uScore, v.tFaction, v.tScore)
					if showKill then
						TriggerClientEvent("turfs:addKill", src, GetPlayerName(killer_src), GetPlayerName(player), logColor, headShot)
					end
				end)
				vRP.doFactionFunction(v.tFaction, function(src)
                    TriggerClientEvent("turfs:setScore", src, v.tFaction, v.tScore, v.uFaction, v.uScore)
                    if showKill then
						TriggerClientEvent("turfs:addKill", src, GetPlayerName(killer_src), GetPlayerName(player), not logColor, headShot)
					end
				end)
			end
		end)
	end
end)

function isFactionInWar(faction)
	for k, v in pairs(warStatement) do
		if v.uFaction == faction or v.tFaction == faction then
			return true
		end
	end
	return false
end

local function checkIfWar(player, user_id)
	for turfId, tbl in pairs(warStatement) do
		local uColor = vRP.getFactionColor(tbl.uFaction)
		local tColor = vRP.getFactionColor(tbl.tFaction)
        TriggerClientEvent("turfs:flickTurf", player, turfId, uColor, tColor)

		if vRP.isUserInFaction(user_id, tbl.uFaction) then

            TriggerClientEvent("turfs:setInWar", player, true, turfId)
			SetPlayerRoutingBucket(player, tbl.vw)
			vRPturfs.drawTimer(player, {warTimeState[turfId], 0}, function()
                TriggerClientEvent("turfs:setInWar", player, false)
				SetPlayerRoutingBucket(player, 0)
			end)
            TriggerClientEvent("turfs:setScore", player, tbl.uFaction, tbl.uScore, tbl.tFaction, tbl.tScore)

		elseif vRP.isUserInFaction(user_id, tbl.tFaction) then

            TriggerClientEvent("turfs:setInWar", player, true, turfId)
			SetPlayerRoutingBucket(player, tbl.vw)
			vRPturfs.drawTimer(player, {warTimeState[turfId], 0}, function()
                TriggerClientEvent("turfs:setInWar", player, false)
				SetPlayerRoutingBucket(player, 0)
			end)
            TriggerClientEvent("turfs:setScore", player, tbl.tFaction, tbl.tScore, tbl.uFaction, tbl.uScore)

		end
	end
end

-- RegisterCommand("war", function(player)
-- 	local msg = "------Active WARs------"
-- 	for turfId, v in pairs(warStatement) do

-- 		local secLeft = (warTimeState[turfId] or 0)
-- 		local timeLeft = string.format("%02d:%02d", math.floor(secLeft/60), secLeft%60)

-- 		msg = msg .. "\nTurf #"..turfId.." ^1"..v.uFaction.."^7(^1"..v.uScore.."^7) - ^1"..v.tFaction.."^7(^1"..v.tScore.."^7) - "..timeLeft.." (vw "..v.vw..")"
-- 	end
-- 	msg = msg .. "\n------------"

-- 	msg(player, msg)
-- end)

local nextVirtualWorld = 1

function startWar(turfId, uFaction, tFaction, uColor, tColor, factionType)
	if not factionType then factionType = "Mafie" end
    TriggerClientEvent("turfs:flickTurf", -1, turfId, uColor, tColor)
	warStatement[turfId] = {uFaction = uFaction, tFaction = tFaction, uScore = 0, tScore = 0, type = factionType, scores = {}, startTime = os.time(), vw = nextVirtualWorld}
	nextVirtualWorld = nextVirtualWorld + 1
	vRP.doFactionFunction(uFaction, function(src)
        TriggerClientEvent("turfs:setInWar", src, true, turfId)
		SetPlayerRoutingBucket(src, warStatement[turfId].vw)
		vRPturfs.drawTimer(src, {warTime, 0}, function()
            TriggerClientEvent("turfs:setInWar", src, false)
			SetPlayerRoutingBucket(src, 0)
		end)
	end)
	vRP.doFactionFunction(tFaction, function(src)
        TriggerClientEvent("turfs:setInWar", src, true, turfId)
		SetPlayerRoutingBucket(src, warStatement[turfId].vw)
		vRPturfs.drawTimer(src, {warTime, 0}, function()
            TriggerClientEvent("turfs:setInWar", src, false)
			SetPlayerRoutingBucket(src, 0)
		end)
	end)
	warTimeState[turfId] = warTime
	while warTimeState[turfId] > 0 do
		Citizen.Wait(60 * 1000)
		warTimeState[turfId] = warTimeState[turfId] - 1

		if warTimeState[turfId] == 10 or warTimeState[turfId] == 5 then
			if warStatement[turfId].uScore > warStatement[turfId].tScore then
				setTurfColor(turfId, uColor)
			end
		end

	end
	warTimeState[turfId] = nil
	cooldownSelf[uFaction] = os.time() + 10 * 60
	cooldownProtect[tFaction] = os.time() + 220 -- 3 minute
	TriggerClientEvent("turfs:stopFlick", -1, turfId)
    local results = warStatement[turfId]


	if results.uScore > results.tScore then
		setTurfColor(turfId, uColor)
        TriggerClientEvent("turfs:setColor", -1, turfId, uColor)
		sendInfo(-1, "^1"..results.uFaction.." ^7a castigat un teritoriu detinut de ^1"..results.tFaction.." ^7!")
		msg(-1, "^1Scor^7: ^1"..results.uScore.." ^7("..results.uFaction..") - ^1"..results.tScore.." ^7("..results.tFaction..")")
	elseif results.uScore <= results.tScore then
		setTurfColor(turfId, tColor)
        TriggerClientEvent("turfs:setColor", -1, turfId, tColor)
		sendInfo(-1, "^1"..results.tFaction.." ^7a castigat un teritoriu detinut de ^1"..results.uFaction.." ^7!")
		msg(-1, "^1Scor^7: ^1"..results.tScore.." ^7("..results.tFaction..") - ^1"..results.uScore.." ^7("..results.uFaction..")")
	end


	vRP.doFactionFunction(results.uFaction, function(src)
        TriggerClientEvent("turfs:setScore", src, "", 0, "", 0)
	end)
	vRP.doFactionFunction(results.tFaction, function(src)
        TriggerClientEvent("turfs:setScore", src, "", 0, "", 0)
    end)

	Citizen.CreateThread(function()
		Wait(60000)
		warStatement[turfId] = nil
	end)

end

function build_player_turfs(player)
	for k, v in pairs(allTurfs) do 
		Citizen.Wait(5)
		local x = v.x + 0.0001
		local y = v.y + 0.0001
		local z = v.z + 0.0001
		local radius = v.radius + 0.0001
        TriggerClientEvent("turfs:createTurf", player, v.id, x, y, z, radius, v.color, vRP.getFactionByColor(v.color))
    end
end

AddEventHandler("vRP:playerSpawn",function(user_id, player, first_spawn)
	if first_spawn then
		build_player_turfs(player)
		Wait(5000)
		checkIfWar(player, user_id)
	end
end)

RegisterCommand("turfs", function(player)
    TriggerClientEvent("turfs:toggleTurfs", player, true)
end)

RegisterCommand("attack", function(player)
	tryAttackTurf(player)
end)

RegisterCommand("col", function(player, args)
	local user_id = vRP.getUserId({player})
	if isAnAdmin(user_id, 1) then
		vRPturfs.isInTurf(player, {0}, function(onTurf)
			setTurfColor(onTurf, tonumber(args[1]), true)
		end)
	else
		noAccess(player)
	end
end)


local lastHit = nil
AddEventHandler("weaponDamageEvent", function(sender, data)
	sender = tonumber(sender)
	if data.damageType ~= 0 then
		lastHit = {sender = sender, dmg = data.weaponDamage, kill = data.willKill}
	end
end)

AddEventHandler("weaponDamageReply", function(sender, data)
	sender = tonumber(sender)
	if lastHit ~= nil then
		TriggerClientEvent("war:showDealthDmg", lastHit.sender, sender, GetPlayerName(sender), lastHit.dmg, lastHit.kill)
		lastHit = nil
	end
end)