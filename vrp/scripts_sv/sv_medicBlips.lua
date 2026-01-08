
RegisterServerEvent("eblips:add", function(blipInfo)
	local src = blipInfo.src
	blipInfo.src = nil
	TriggerClientEvent("eblips:addOne", -1, src, blipInfo)
end)

RegisterServerEvent("eblips:remove", function(src)
	TriggerClientEvent("eblips:remove", -1, src)
end)