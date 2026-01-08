
local allowedFiles <const> = {
	--[file] = true,
}

RegisterServerEvent("sound:playAudioInRadius", function(radius, file, volume)
	local player = source
	if radius > 5.0 then
		vRPclient.notify(player, {"Raza nu poate fi mai mare de 5 metri.", "error"})
		return
	end

	vRPclient.getPosition(source, {}, function(x, y, z)
		vRPclient.getPlayersInCoords(source, {x, y, z, radius}, function(players)
			if (next(players) == nil) then return end
			
			for playerSrc, _ in pairs(players) do
				TriggerClientEvent("sound:play", playerSrc, file, volume)
			end
		end)
	end)
end)

RegisterServerEvent("sound:playAudioToAll", function(file, volume)
	local user_id = vRP.getUserId(source)
	if not allowedFiles[file] and (vRP.getUserAdminLevel(user_id) < 4) then
		CancelEvent()
		vRP.ban(user_id, 'Sound inject', false, 0)
		return false
	end

	if not WasEventCanceled() then
		TriggerClientEvent("sound:play", -1, file, volume)
	end
end)