RegisterServerEvent("voice:setRadioChannel")
local restrictedRadios = {
	[1] = {
		faction = "Politie",
	},
	[2] = {
		faction = "Politie",
	},
	[3] = {
		faction = "Smurd",
	},
}

function tvRP.canJoinRadio(channel)
	local user_id = vRP.getUserId(source)
	local cfg = restrictedRadios[channel]
	if cfg then

		if cfg.faction then
			return vRP.isUserInFaction(user_id, cfg.faction)
		elseif cfg.job then
			return exports["vrp_jobs"]:hasJob(user_id, cfg.job)
		end
	
	end

	return true
end

AddEventHandler("voice:setRadioChannel", function(channel)
	local player = source
	local user_id = vRP.getUserId(player)
	
	if user_id and channel then
		vRP.createLog(user_id, {channel = channel}, "RadioJoin")
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		TriggerClientEvent("vrp-radio:restrictChannels", player, restrictedRadios)
	end
end)
