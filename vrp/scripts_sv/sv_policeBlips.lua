local ACTIVE_EMERGENCY_PERSONNEL = {}

RegisterServerEvent("pd_eblips:add")
AddEventHandler("pd_eblips:add", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("pd_eblips:updateAll", k, ACTIVE_EMERGENCY_PERSONNEL)
	end
	TriggerClientEvent("pd_eblips:toggle", person.src, true)
end)

RegisterServerEvent("pd_eblips:remove")
AddEventHandler("pd_eblips:remove", function(src)
	ACTIVE_EMERGENCY_PERSONNEL[src] = nil
	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("pd_eblips:remove", tonumber(k), src)
	end
	TriggerClientEvent("pd_eblips:toggle", src, false)
end)

AddEventHandler("playerDropped", function()
	if ACTIVE_EMERGENCY_PERSONNEL[source] then
		ACTIVE_EMERGENCY_PERSONNEL[source] = nil
	end
end)