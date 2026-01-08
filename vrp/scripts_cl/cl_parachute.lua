
local parachutePos <const> = {
	vec3(455.27032470704,5571.806640625,781.18359375),
	vec3(429.11569213868,5614.8081054688,766.23840332032),
}

local parachute = GetHashKey("GADGET_PARACHUTE")


Citizen.CreateThread(function()
	local minRadius = 15.0

	local input = false

	while true do

		for k, pos in pairs(parachutePos) do
			local dst = #(pedPos - pos)

			while dst <= minRadius do
				Citizen.Wait(1)
				dst = #(pedPos - pos)

				DrawMarker(40, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 152, 203, 234, 100, true, true, false, true)
				DrawText3D(pos.x, pos.y, pos.z + 0.5, "Salturi cu parasuta", 1.0)

				if dst <= 1.0 then

					if not input then
						input = true
						TriggerEvent("vrp-hud:showBind", {key = "E", text = "Echipeaza o parasuta"})
					end

					if IsControlJustReleased(0, 38) then
						ExecuteCommand("e jtrynewc2")

						Citizen.Wait(500)

						GiveWeaponToPed(tempPed, parachute, 150, true, true)
					end
				elseif input then
					input = false
					TriggerEvent("vrp-hud:showBind", false)
				end
			end
		end
	
		Citizen.Wait(1000)
	end
end)
