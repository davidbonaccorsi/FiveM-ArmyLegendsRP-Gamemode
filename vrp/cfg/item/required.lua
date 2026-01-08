local items = {}

items["head_bag"] = {name = "Punga Hartie", description = "O punga groasa de hartie", choices = function(player)
	TriggerEvent("vrp-headbag:useHeadBag", player)
end, weight = 1.0}

items["mouthgag"] = {name = "Mouthgag", description = "O bila de bagat in gura", useItem = function(player)
	TriggerEvent("vrp-headbag:coverTheMouth", player)
end, weight = 1.0}

items["dmvact"] = {name = "Dosar DMV", description = "Actul care dovedeste trecerea testului teoretic", useItem = false, weight = 0.2}
items["permisarma"] = {name = "Permis Port Arma", description = "Actul care dovedeste ca poti manui o arma de foc", useItem = false, weight = 0.2}

local healingState = {}
local function getHealth(player, itm, min, max)
	local user_id = vRP.getUserId(player)

	vRPclient.getHealth(player, {}, function(health)
		if type(health) == "number" and health > 120 then
			local otime = os.time()
			if (healingState[user_id] or 0) < otime then
				if vRP.removeItem(user_id, itm) then
					healingState[user_id] = otime + 60 -- 2 minute
					local randomHealth = math.random(min, max)
					vRPclient.varyHealth(player, {randomHealth})
					if itm == "adrenaline" then
						TriggerClientEvent("vrp:progressBar", player, {
                            duration = 3500,
                            text = "💉 Injectezi adrenalina..",
                        })
						vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
						TriggerClientEvent("vrp-3dme:display", player, "Isi administreaza o injectie de adrenalina.")
					elseif itm == "paracetamol" then
						vRPclient.notify(player, {"Ai luat o pastila paracetamol"})
					else
						vRPclient.notify(player, {"Ti-ai aplicat un bandaj pe rani"})
					end
				end
			else
				vRPclient.notify(player, {"Ai cooldown inca "..healingState[user_id]-otime.." secunde", "error"})
			end
		else
			vRPclient.notify(player, {"Esti prea ranit ca sa folosesti "..itm, "error"})
		end
	end)
end

AddEventHandler("vRP:playerLeave", function(user_id)
	healingState[user_id] = nil
end)

items["medkit"] = {name = "Trusa Medicala",description = "Foloseste aceasta trusa pentru a acorda primul ajutor celui mai apropiat jucator.",
useItem = function(player)
	vRPclient.getNearestPlayer(player, {10}, function(nPlayer)
		if nPlayer then
			vRPclient.isInComa(player, {}, function(userDied)
				if not userDied then
					vRPclient.isInComa(nPlayer, {}, function(inComa)
						if inComa then
							-- vRP.tryGetInventoryItem(user_id, "medkit", 1, true)
							if vRP.removeItem(vRP.getUserId(player), 'medkit') then
								TriggerClientEvent("vrp:progressBar", player, {
									duration = 15000,
									text = "💊 Acorzi primul ajutor..",
								})

								TriggerClientEvent("vrp:progressBar", nPlayer, {
									duration = 15000,
									text = "🩺 Primesti ingrijiri medicale..",
								})

								vRPclient.playAnim(player,{false,anim_trusa_medicala,false})
								
								Citizen.CreateThread(function()
									Citizen.Wait(15000)

									vRPclient.isInComa(player, {}, function(inComa)
										if not inComa then
											vRPclient.varyHealth(nPlayer, {25})
										end
									end)
								end)
							end
						else
							vRPclient.notify(player, {"Aceasta persoana nu are nevoie de ingrijiri medicale!", "error"})
						end
					end)
				end
			end)
		else
			vRPclient.notify(player, {"Nu a fost gasit niciun jucator in jurul tau!", "error"})
		end
	end)
end, weight = 1.0}


items["bandage"] = {name = "Bandaj",description = "Un bandaj pentru a oprii sangerarile.",useItem = function(player) return getHealth(player, "bandage", 5, 50) end, weight = 0.2}
items["adrenaline"] = {name = "Injectie Adrenalina",description = "O injectie cu adrenalina.",useItem = function(player) return getHealth(player, "adrenaline", 50, 100) end, weight = 0.25}
items["paracetamol"] = {name = "Paracetamol",description = "Un paracetamol pentru raceala si gripa.",useItem = function(player) return getHealth(player, "paracetamol", 5, 25) end, weight = 0.1}

items["furazolidon"] = {
	name = "Furazolidon",
	description = "Pastila pentru a ameliora durerile de burta si efectele adverse ale toxinfectiei.",

	useItem = function(player)
		local user_id = vRP.getUserId(player)

		vRPclient.getIllness(player, {}, function(illness)
			if not illness then
				return vRPclient.notify(player, {"Nu esti bolnav.", "error"})
			end

			if vRP.removeItem(user_id, "furazolidon") then
				vRPclient.notify(player, {"Ai luat o pastila furazolidon pentru a-ti ameliora toxinfectia."})
				
				vRP.removeFoodPoising(user_id, player)
			end
		end)
	end,

	weight = 0.1
}

items['cuie'] = {
	name = 'Cuie',
	description = 'Cuie, pot fi folosite la confectionarea diferitor obiecte.',
	useItem = false,
	weight = 0.1
}

items['undita_1'] = {
	name = 'Undita Zebco Slingshot Spinning Combo',
	desciption = 'O undita simpla',
	useItem = false,
	isUnique = true,
	maxUsage = 1000,
	weight = 0.5,
}

items['undita_2'] = {
	name = 'Undita Ugly Stik GX2 Spinning Rod',
	desciption = 'O undita decenta',
	useItem = false,
	isUnique = true,
	maxUsage = 5000,
	weight = 0.7,
}

items['undita_3'] = {
	name = 'Undita G. Loomis NRX Spinning Rod',
	desciption = 'O undita foarte buna',
	useItem = false,
	isUnique = true,
	maxUsage = 9000,
	weight = 1.0,
}

return items