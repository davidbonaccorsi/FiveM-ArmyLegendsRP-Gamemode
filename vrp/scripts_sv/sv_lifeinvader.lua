
local cooldownAnn = nil
local cost = 2500

RegisterServerEvent("vrp-hud:addAnnounce")
AddEventHandler("vrp-hud:addAnnounce", function(msg)
	local player = source
	local user_id = vRP.getUserId(player)
	local identity = vRP.getIdentity(user_id)


	if msg:len() > 2 and (cooldownAnn or 0) <= os.time() then

		if vRP.tryPayment(user_id, cost, true, "Announcement") then
			local name = identity.name
			
			TriggerClientEvent("vrp-hud:addAnnounce", -1, name, identity.phone, msg)
			TriggerEvent("vrp-phone:newAd", {phone = identity.phone, name = identity.firstname.." "..name, text = msg, date = os.date("%d.%m.%Y %H:%M")})
			cooldownAnn = os.time() + 30
			
			vRP.createLog(user_id, {announcement = msg}, "LifeInvaderPost")

		end
	end
end)


RegisterServerEvent("vrp-lifeinvader:tryPostingAnn", function()
	
	local player = source
	local user_id = vRP.getUserId(player)

	if (cooldownAnn or 0) <= os.time() then
		local userIdentity = vRP.getIdentity(user_id)

		TriggerClientEvent("vrp:interfaceFocus", player, true)
		TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "lifeInvader", data = {phone = userIdentity.phone, name = userIdentity.name}})

		exports.vrp:achieve(user_id, "WeazelNewsEasy", 1)
	else
		vRPclient.notify(player, {"Asteapta inca "..(cooldownAnn - os.time()).." (de) secunde pentru a pune un anunt"})
	end

end)

