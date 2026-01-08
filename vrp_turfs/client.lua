
local vRPturfs = {}

vRP = Proxy.getInterface("vRP") -- vRPclient
Tunnel.bindInterface("vRP_turfs", vRPturfs)
Proxy.addInterface("vRP_turfs", vRPturfs)

local function drawTxt(x, y, scale, text, r,g,b, font, centered)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	if centered then
		SetTextCentre(true)
	end
	SetTextColour(r, g, b, 255)
	SetTextDropShadow(0, 0, 0, 0, 150)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

local turfsCircle = {}
local turfsData = {}
local turfsEnabled = 0

local inWar = false

RegisterNetEvent("turfs:setScore", function(uN, uS, tN, tS)
    SendNUIMessage({type = "setScore", uName = uN, uScore = uS, tName = tN, tScore = tS})
end)

local ootProtection = false

Citizen.CreateThread(function()
	while true do

		local ped = PlayerPedId()
		while ootProtection do

			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,264,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,143,true)

			SetEntityInvincible(ped, true)
			SetPlayerInvincible(PlayerId(), true)
			ClearPedLastWeaponDamage(ped)
			SetEntityCanBeDamaged(ped, false)

			Citizen.Wait(1)
		end

		SetEntityInvincible(ped, false)
		SetPlayerInvincible(PlayerId(), false)
		SetEntityCanBeDamaged(ped, true)

		Citizen.Wait(250)
	end
end)

RegisterNetEvent("turfs:addKill")
AddEventHandler("turfs:addKill", function(killer, victim, logType, headShot)
	SendNUIMessage({
        type = "kill",
        killer = killer,
        victim = victim,
        logType = logType,
        headShot = headShot
	})
end)

local inTheTurf = false
RegisterNetEvent("turfs:setInWar", function(bool, turfId)
	if bool and not inWar then
		inWar = bool

		Citizen.CreateThread(function()
			while inWar do
				Citizen.Wait(500)
				if vRPturfs.isInTurf(turfId) then
					inTheTurf = true
					StopScreenEffect("MP_race_crash")
					ootProtection = false
				else
					ootProtection = true
					if inTheTurf then
						inTheTurf = false
						StartScreenEffect("MP_race_crash", 0, false)
					end
				end
			end
			StopScreenEffect("MP_race_crash")
			ootProtection = false
		end)
	else
		inWar = false
	end
end)


local death = false
AddEventHandler('gameEventTriggered', function(ev, eventData)
    if inWar and ev == "CEventNetworkEntityDamage" then
		local victim = tonumber(eventData[1])
        local attacker = tonumber(eventData[2])

        local foundDmgBone, lastDmgBone = GetPedLastDamageBone(victim)
        local headShot = false
        if foundDmgBone then
            headShot = (tonumber(lastDmgBone) == 31086)
        end

		if victim == PlayerPedId() and not death then
			local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
			
            if GetEntityHealth(PlayerPedId()) <= 105 then
				death = true
				TriggerServerEvent("turfs:playerDied", attackerId, headShot)
	
				Citizen.CreateThread(function()
					Citizen.CreateThread(function()
                        Citizen.Wait(2100)
                        local x, y, z = vRP.getPosition()
                        NetworkResurrectLocalPlayer(x, y, z, true, true, false)
                        death = false
                    end)
	
					SetTimeout(2500, function()
						inTheTurf = false
						StopScreenEffect("MP_race_crash")
					end)
				end)
			end
		end
	end
end)

function vRPturfs.isInWar()
	return inWar
end

exports("isInWar", vRPturfs.isInWar)

RegisterNetEvent("turfs:setColor", function(id, color)
	if turfsCircle[id] then
		SetBlipColour(turfsCircle[id], color)
	end
end)

RegisterNetEvent("turfs:createTurf", function(id, x, y, z, radius, color, faction)
	if turfsCircle[id] then RemoveBlip(turfsCircle[id]) end
	turfsCircle[id] = AddBlipForRadius(x, y, z, radius)
	TriggerEvent("turfs:setColor", id, color) -- 37 = Alb
	SetBlipAlpha(turfsCircle[id], turfsEnabled)

	turfsData[id] = {x, y, z, radius, color, faction}
end)

local inTurf = false;
RegisterNetEvent("turfs:toggleTurfs", function(msg)
	if turfsEnabled ~= 0 then
		turfsEnabled = 0
		if msg then
            TriggerEvent("chatMessage", "^5Info: ^7Ai ascuns turf-urile")
        end
	else
		turfsEnabled = 150
		if msg then
			TriggerEvent("chatMessage", "^5Info: ^7Ai afisat turf-urile")
		end
	end
	for i, v in pairs(turfsCircle) do
		SetBlipAlpha(turfsCircle[i], turfsEnabled)
	end

	while turfsEnabled ~= 0 do

		local turfId = vRPturfs.isInTurf()
		if not inTurf and turfId then
			inTurf = turfId;
			local name = turfsData[turfId] and turfsData[turfId][6] or 'Necunoscut'
			TriggerEvent("vrp-hud:notify", "Ai intrat pe un turf detinut de catre "..name)
		elseif not turfId then
			inTurf = false;
		end 

		Citizen.Wait(1000)
	end
end)

function vRPturfs.isInTurf(oneTurf)
	local x, y, z = vRP.getPosition({})
	if oneTurf and oneTurf ~= 0 then
		local theTurf = turfsData[oneTurf]
		if theTurf then
			if GetDistanceBetweenCoords(x, y, z, theTurf[1], theTurf[2], theTurf[3], false) < theTurf[4] then
				return true
			end
		end
	else
		for i, v in pairs(turfsCircle) do 
			local theTurf = turfsData[i]
			if theTurf then
				if GetDistanceBetweenCoords(x, y, z, theTurf[1], theTurf[2], theTurf[3], false) < theTurf[4] then
					return i
				end
			end
		end
	end
	return false
end

local flickering = {}
RegisterNetEvent("turfs:stopFlick", function(id)
	flickering[id] = nil
end)

RegisterNetEvent("turfs:flickTurf", function(id, color1, color2, time)
    if id and color1 and color2 then
		if not time then 
			flickering[id] = true
			time = 0
		end

		while time >= 0 or flickering[id] == true do
			Citizen.Wait(1000)
			TriggerEvent("turfs:setColor", id, color1)
			Citizen.Wait(1000)
			TriggerEvent("turfs:setColor", id, color2)
			time = time - 2
		end
	end
end)

local stopTimer = false

local min, sec = 0, 0

function vRPturfs.drawTimer(min_r, sec_r, turfId)
	stopTimer = false
	turfsEnabled = 150

	min = min_r
	sec = sec_r

	Citizen.CreateThread(function()
		while min + sec > 0 and not stopTimer do
			Citizen.Wait(1000)
			sec = sec - 1
			if sec < 0 then
				min = min - 1
				sec = 59
			end

			SendNUIMessage({type = "timer", m = min, s = sec})
		end
        SendNUIMessage({type = "timer", hide = true})
	end)

	if turfId then
		if turfsCircle[turfId] then
			Citizen.CreateThread(function()
				while min + sec > 0 and not stopTimer do
					Citizen.Wait(500)
					if not vRPturfs.isInTurf(turfId) or vRP.isInComa({}) then
						stopTimer = true
					end
				end
			end)
		end
	end

	while min + sec > 0 and not stopTimer do
		Citizen.Wait(0)
	end
	if stopTimer then
		stopTimer = false
		StartScreenEffect("SuccessFranklin", 1200, 0)
		vRP.playSound({"SHORT_PLAYER_SWITCH_SOUND_SET", "slow"})
		return false
	else
		stopTimer = false
		StartScreenEffect("SuccessFranklin", 1000, 0)
		vRP.playSound({"DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", "Mission_Pass_Notify"})
		return true
	end
end

local dmgList = {}
local dmgIndex = -1
RegisterNetEvent("war:showDealthDmg", function(senderId, name, dmg, isKill)

	if isInWar then

		print("DMG Dealt: "..name.." ^1"..dmg.." DMG")

		if not dmgList[senderId] then
			dmgList[senderId] = {utime = GetGameTimer() + 1500, totalDmg = math.min(dmg, 200)}
			dmgIndex = dmgIndex + 1

			local posY = 0.49 + (dmgIndex * 0.011)

			while GetGameTimer() < dmgList[senderId].utime do

				drawTxt(0.53, posY, 0.3, dmgList[senderId].totalDmg, 252, 78, 66, 2, 1)

				Citizen.Wait(1)
			end

			dmgList[senderId] = nil
			dmgIndex = dmgIndex - 1

		else
			dmgList[senderId] = {utime = dmgList[senderId].utime + 1000, totalDmg = math.min(dmgList[senderId].totalDmg + dmg, 200)}
		end
	end
end)