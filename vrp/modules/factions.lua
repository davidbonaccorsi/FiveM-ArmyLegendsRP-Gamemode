

local factions = {}
local factionMembers = {}

local factionChests = {}

local function setFactionChest(name, pos, weight)
	local x, y, z = table.unpack(pos)
	factionChests[name] = {x, y, z, weight}
end

local function getFactionsConfig()
	exports.mongodb:find({collection = "factions", query = {}}, function(success, result)
		for _, fdata in pairs(result or {}) do
			factions[fdata.name] = {
				fType = fdata.type,
				fSlots = fdata.slots,
				fRanks = fdata.ranks,
				fBudget = fdata.budget or 0,
			}

			if fdata.type == "Mafie" then
				factions[fdata.name].fColor = fdata.color
				factions[fdata.name].fHome = fdata.home

				factions[fdata.name].weapons = fdata.weapons
			end

			if fdata.chest then
				setFactionChest(fdata.name, fdata.chest.pos, tonumber(fdata.chest.weight))
			end
		end

		for i, v in pairs(factions) do
			exports.mongodb:find({collection = "users", query = {['userFaction.faction'] = tostring(i)}, options = {projection = {_id = 0, id = 1, username = 1, userFaction = 1, last_login = 1}}}, function(success, result)
				factionMembers[tostring(i)] = result
			end)
			Wait(30)
		end

	end)
end

AddEventHandler("onDatabaseConnect", function(db)
	Citizen.Wait(500)
	getFactionsConfig()
end)

AddEventHandler("onResourceStart", function(res)
	if res == GetCurrentResourceName() then
		Citizen.Wait(500)
		getFactionsConfig()
	end
end)

RegisterCommand("loadfactions", function(player)
	if not (player == 0) then return end
	
	factions = {}
    factionMembers = {}
    getFactionsConfig()
    print("Factions Reloaded")
end)

function vRP.getFactionByColor(color)
	for i, v in pairs(factions) do
		if v.fColor == color then
			return tostring(i)
		end
	end
	return false
end

function vRP.getFactions()
	local factionsList = {}
	for i, v in pairs(factions) do
		factionsList[i] = v
	end
	return factionsList
end

function vRP.getFaction(faction)
	return factions[faction] or {}
end

function vRP.getUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return tmp.fName
	end
end

function vRP.getFactionRanks(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		return factionRanks
	end
end

function vRP.getFactionRankSalary(faction, rank)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		for i, v in pairs(factionRanks) do
			if (v.rank == rank)then
				return v.payday - 1
			end
		end
		return 0
	end
end

function vRP.getFactionSlots(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionSlots = ngroup.fSlots
		return factionSlots
	end
end

function vRP.getFactionColor(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionColor = ngroup.fColor
		return factionColor
	end
end

function vRP.getFactionType(faction)
	local ngroup = factions[faction]
	if ngroup then
		return tostring(ngroup.fType)
	end
end

function vRP.getFactionBudget(faction)
	local ngroup = factions[faction] or {fBudget = 0}
	if ngroup.fBudget then
		return ngroup.fBudget
	end

	return 0
end

function vRP.depositFactionBudget(faction, money)
	factions[faction].fBudget = (factions[faction].fBudget or 0) + money

	exports.mongodb:updateOne({collection = "factions", query = {name = faction}, update = {
		['$set'] = {
			['budget'] = factions[faction].fBudget
		}
	}})
	return true
end

function vRP.withdrawFactionBudget(faction, user_id, amount)
	if amount == 0 then return true end

	local budget = vRP.getFactionBudget(faction)
	if (budget >= amount) and (amount >= 0) then
		factions[faction].fBudget = (factions[faction].fBudget or 0) - amount
		vRP.giveMoney(user_id, amount, "Seiful Factiunii ("..faction..")")
		exports.mongodb:updateOne({collection = "factions", query = {name = faction}, update = {
			['$set'] = {
				['budget'] = factions[faction].fBudget
			}
		}})
		return true
	end		
	return false
end

function vRP.getFactionRanksNum(faction)
	local ngroup = factions[faction]
	if ngroup then
		return #ngroup.fRanks
	end
end

function vRP.hasUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		if tmp.fName == "user" then
			return false
		else
			return true
		end
	end
	return false
end

function vRP.isUserInFaction(user_id,group)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		if tmp.fName == group then
			return true
		else
			return false
		end
	end
end

function vRP.isUserPolitist(user_id)
	return vRP.isUserInFaction(user_id, "Politie")
end

function vRP.getFactionHome(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionHome = ngroup.fHome
		return factionHome[1], factionHome[2], factionHome[3]
	end
end

function vRP.spawnAtFactionHome(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local x, y, z = vRP.getFactionHome(vRP.getUserFaction(user_id))
		vRPclient.teleport(player, {x, y, z})
		vRPclient.setHealth(player, {200})
	end
end

function vRP.setFactionLeader(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.fLeader = 1

		local faction = vRP.getUserFaction(user_id)		
		local groupUsers = factionMembers[faction]
		if groupUsers then
			for i, v in pairs(groupUsers) do
				if v.id == user_id then
					v.userFaction.leader = tmp.fLeader
				end
			end
		end


		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userFaction.leader'] = 1}}})
	end
end

function vRP.setFactionNonLeader(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.fLeader = 0

		local faction = vRP.getUserFaction(user_id)		
		local groupUsers = factionMembers[faction]
		if groupUsers then
			for i, v in pairs(groupUsers) do
				if v.id == user_id then
					v.userFaction.leader = tmp.fLeader
				end
			end
		end

		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userFaction.leader'] = 0}}})
	end
end

function vRP.isFactionLeader(user_id,group)
	local tmp = vRP.getUserTmpTable(user_id)
	
	if tmp then
		return tmp.fName == group and tmp.fLeader == 1
	end
end

function vRP.getFactionRank(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return tmp.fRank
	end
end

function vRP.isUserCoLeader(user_id, group)
	local faction = group or vRP.getUserFaction(user_id)
	if faction then
		if factions[faction].fType ~= "Gang" then
			return (vRP.getFactionRankNumber(user_id) == vRP.getFactionRanksNum(faction)-1)
		end
	end
	return false
end


function vRP.getFactionRankNumber(user_id)
	local theRank = vRP.getFactionRank(user_id)
	local ngroup = factions[vRP.getUserFaction(user_id)]
	if ngroup then
		local factionRanks = ngroup.fRanks
		for k, v in pairs(factionRanks) do
			if theRank == v.rank then
				return k
			end
		end
		return 0
	end
end

local function setFactionRank(user_id, faction, rank)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.fRank = rank
	end

	local groupUsers = factionMembers[faction]
	if groupUsers then
		for i, v in pairs(groupUsers) do
			if v.id == user_id then
				v.userFaction.rank = rank
			end
		end
	end

	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userFaction.rank'] = rank}}})
end

function vRP.factionRankUp(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserTmpTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == #ranks)then
				return false
			else
				local theRank = tostring(ranks[i+1].rank)
				tmp.fRank = theRank
				exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userFaction.rank'] = theRank}}})
				ExecuteCommand("loadfactions")
				return true
			end
		end
	end
end

function vRP.factionRankDown(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserTmpTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == 1)then
				return false
			else
				local theRank = tostring(ranks[i-1].rank)
				tmp.fRank = theRank
				exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userFaction.rank'] = theRank}}})
				ExecuteCommand("loadfactions")
				return true
			end
		end
	end
end

function vRP.addUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local ngroup = factions[theGroup]
		if ngroup then
			local factionRank = ngroup.fRanks[1].rank
			local tmp = vRP.getUserTmpTable(user_id)
			if tmp then
				if factionMembers[tmp.fName] then
					for index, data in pairs(factionMembers[tmp.fName]) do
						if data.id == user_id then
							table.remove(factionMembers[tmp.fName], index)
						end
					end
				end

				tmp.fName = theGroup
				tmp.fRank = factionRank
				tmp.fLeader = 0
				tmp.fWarn = 0
				tmp.fJoin = os.time()

				TriggerClientEvent("vrp:playerJoinFaction", player, theGroup, vRP.getFactionType(theGroup))
				Player(player).state.faction = theGroup

				exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {
					['userFaction.faction'] = theGroup,
					['userFaction.rank'] = factionRank,
					['userFaction.join'] = tmp.fJoin
				}}}, function(success)
					exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {_id = 0, id = 1, username = 1, userFaction = 1, last_login = 1}}}, function(success, result)
						table.insert(factionMembers[theGroup], result[1])
					end)
				end)
			end
		end
	end
end

function vRP.getUsersByFaction(group)
	return factionMembers[group] or {}
end

function vRP.getUserFactionDays(user_id, timestamp)
	local user = vRP.getUser(user_id) or {}
	if timestamp or vRP.hasUserFaction(user_id) then
		local time = user.fJoin or os.time()

		return (os.time() - (timestamp or time)) / (24 * 60 * 60)
	end
	return false
end

function vRP.getOnlineUsersByFaction(faction)
	local users = {}

	for index, data in next, factionMembers[faction] do
		local source = vRP.getUserSource(data.id)

		if source then
			table.insert(users, data.id)
		end
	end

	return users
end

function vRP.removeUserFaction(user_id, theGroup, transfer)
	local player = vRP.getUserSource(user_id)
	local tmp = vRP.getUserTmpTable(user_id)

	if player then
		if tmp then
			if factionMembers[theGroup] then
				for i, v in pairs(factionMembers[theGroup]) do
					if v.id == user_id then
						table.remove(factionMembers[theGroup], i)
					end
				end
			end

			tmp.fName = "user"
			tmp.fRank = 'none'
			tmp.fLeader = 0

			Player(player).state.faction = nil
			TriggerClientEvent("vrp:playerJoinFaction", player, tmp.fName, "user")
		end
	else
		if factionMembers[theGroup] then
			for i, v in pairs(factionMembers[theGroup])do
				if v.id == user_id then
					table.remove(factionMembers[theGroup], i)
				end
			end
		end
	end

	local transferExpire = os.time() + 86400 * transfer
	if tmp then
		tmp.transferExpire = transferExpire
	end

	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
		['$set'] = {
			['userFaction.leader'] = 0, 
			['userFaction.faction'] = "user", 
			['userFaction.rank'] = "none",

			['transferExpire'] = transferExpire
		},
		['$unset'] = {
			['userFaction.warns'] = 1,
			['userFaction.warnExpire'] = 1
		}
	}})
end

function vRP.addFactionRaport(user_id, key)

	if vRP.hasUserFaction(user_id) then

		local theFaction = vRP.getUserFaction(user_id)

		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
			['$inc'] = {
				['raport'..theFaction..'.'..key] = 1
			}
		}})

	end
end

local vip_cfg = module("cfg/vip")

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
	if string.find(choice, 'transfer') then
		local user = vRP.getUser(user_id)

		if not user.transferExpire or (os.time() >= (user.transferExpire or os.time())) then
			vRPclient.notify(player, {"Nu ai transfer.", "error"})
			return
		end

		local transfer = parseInt(splitString(choice, ":")[2])

		local days = (transfer == 1) and 7 or 14

		if vRP.tryCoinsPayment(user_id, vip_cfg.clearTransfer[transfer], choice, true) then
			
			exports["vrp_phone"]:sendMessage(user_id, {
				message = [[
					Salutare, ]]..GetPlayerName(player)..[[!
					<br>Tocmai ai achizitionat Clear Transfer (]]..days..[[ zile).<br>
					<br><br>Iti multumim pentru sustinere.<br>
					- ArmyLegends Romania
				]],
				sender = "0101-0101",
				type = "message"
			})
			
			user.transferExpire = math.max(0, user.transferExpire - (86400 * days))


			if os.time() >= user.transferExpire then
				vRPclient.notify(player, {"Transferul ti-a expirat."})
				user.transferExpire = nil
			else
				vRPclient.notify(player, {"Ti-au mai ramas zile de transfer!\nExpira: "..os.date("%d/%m/%Y %H:%M", user.transferExpire)})
			end

			vRP.updateUser(user_id, "transferExpire", user.transferExpire)

		end
	end
end)


local function ch_inviteFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local members = vRP.getUsersByFaction(theFaction)
	local fSlots = factions[theFaction].fSlots
	if user_id ~= nil then
		vRP.prompt(player,"Invite faction","User ID: ",false,function(id)
			if not id then return end
			id = parseInt(id)
			if tonumber(#members) < tonumber(fSlots) then


				local target = vRP.getUserSource(id)
				if target then

					local name = GetPlayerName(target)
					if vRP.hasUserFaction(id) then
						vRPclient.notify(player,{name.." este deja intr-o factiune!"})
						return
					else

						exports.mongodb:findOne({collection = "users", query = {id = id}, options = {projection = {_id = 0, transferExpire = 1}}}, function(success, result)
							local transferDate = (result[1].transferExpire or 0)

							if transferDate <= os.time() then

								vRPclient.notify(player,{"L-ai adaugat pe "..name.." in "..theFaction.."!"})
								vRPclient.notify(target,{"Ai fost adaugat in "..theFaction.."!"})
								vRP.addUserFaction(id, theFaction)

							else
								vRPclient.notify(player, {"Jucatorul are transfer !\nExpira: "..os.date("%d/%m/%Y %H:%M", transferDate)})
							end

						end)

						
					end
				else
					vRPclient.notify(player,{"Nu sa gasit nici un jucator online cu ID-ul "..id.."!"})
				end
			else
				vRPclient.notify(player,{"Maximul de jucatori in factiune a fost atins! Sloturi: "..fSlots})
			end
		end, true)
	end
end

local function ch_removeFactionWarn(player)

	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)

	if user_id ~= nil then

		vRP.prompt(player, "Remove Faction","User ID:", false, function(id)
			if not id then return end
			local target_id = parseInt(id)

			if target_id ~= nil then

				local found = false
				for indx, v in pairs(factionMembers[theFaction]) do
					if v.id == target_id then
						found = true

						if v.userFaction.warns > 0 then

							v.userFaction.warns = v.userFaction.warns - 1

							if v.userFaction.warns > 0 then
								exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
									['$set'] = {
										['userFaction.warns'] = v.userFaction.warns
									}
								}})
							else
								exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
									['$set'] = {
										['userFaction.warns'] = 0
									},
									['$unset'] = {
										['userFaction.warnExpire'] = 1
									}
								}})
							end

							vRPclient.notify(player, {"I-ai setat lui "..v.username.." "..v.userFaction.warns.."/3 Faction Warn"})

							local target_src = vRP.getUserSource(target_id)
							if target_src then

								local tmp = vRP.getUserTmpTable(target_id)
								tmp.fWarn = v.userFaction.warns

								vRPclient.notify(target_src, {GetPlayerName(player).." ti-a setat "..tmp.fWarn.."/3 Faction Warn"})
							end

						end

						break
					end
				end

				if not found then
					vRPclient.notify(player, {"Jucatorul ales nu face parte din "..theFaction})
				end				

			else
				vRPclient.notify(player, {"Id Invalid"})
			end
		end)

	end

end

local function ch_giveFactionWarn(player)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil then
		vRP.prompt(player, "Give Faction Warn", "User ID:", false, function(id)
			if not id then return end
			local target_id = parseInt(id)

			if target_id ~= nil then

				local found = false
				for indx, v in pairs(factionMembers[theFaction]) do
					if v.id == target_id then
						found = true

						vRP.prompt(player, "Give Faction Warn", "Motiv:", false, function(reason)
							if not reason then return end
							
							v.userFaction.warns = (v.userFaction.warns or 0) + 1

							local target_src = vRP.getUserSource(target_id)

							if target_src then
								local tmp = vRP.getUserTmpTable(target_id)

								tmp.fWarn = v.userFaction.warns

								if v.userFaction.warns == 1 then
									tmp.warnExpire = os.time() + 14 * 86400
								end

								vRPclient.notify(target_src, {GetPlayerName(player).." ti-a acordat "..tmp.fWarn.."/3 Faction Warn"})
							end

							if v.userFaction.warns == 3 then

								if target_src then
									vRP.removeUserFaction(target_id, theFaction, 30)
									vRPclient.notify(target_src, {"Ai fost demis din "..theFaction.." deoarece ai acumulat 3/3 Faction Warn"})
								else
									exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
										['$set'] = {
											['userFaction.leader'] = 0, 
											['userFaction.faction'] = "user", 
											['userFaction.rank'] = "none",

											['transferExpire'] = os.time() + 86400 * 30
										},
										['$unset'] = {
											['userFaction.warns'] = 1,
											['userFaction.warnExpire'] = 1
										}
									}})
								end

							elseif v.userFaction.warns == 1 then

								v.userFaction.warnExpire = os.time() + 14 * 86400
								exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
									['$set'] = {
										['userFaction.warns'] = 1,
										['userFaction.warnExpire'] = v.userFaction.warnExpire
									}
								}})

							else
								exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
									['$set'] = {
										['userFaction.warns'] = v.userFaction.warns
									}
								}})
							end

							vRPclient.notify(player, {"I-ai acordat lui "..v.username.." "..v.userFaction.warns.."/3 Faction Warn"})
						end)
						break
					end
				end

				if not found then
					vRPclient.notify(player, {"Jucatorul ales nu face parte din "..theFaction})
				end
			else
				vRPclient.notify(player, {"Id invalid"})
			end

		end)
	end
end


AddEventHandler("vRP:playerJoin", function(user_id, player, name, extraData)
	Citizen.Wait(5000)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		local userFaction = extraData.userFaction or {faction = "user", leader = 0, rank = "none"}

		Citizen.CreateThread(function()
			Citizen.Wait(60000)
			TriggerClientEvent("discord:setUserData", player, user_id, (userFaction.faction ~= "user" and userFaction.faction or nil))
		end)

		if factions[userFaction.faction] or userFaction.faction == "user" then
			tmp.fName = userFaction.faction
			tmp.fRank = userFaction.rank
			tmp.fLeader = userFaction.leader
			tmp.fWarn = userFaction.warns or 0
			tmp.fJoin = userFaction.join
			if tmp.fWarn > 0 then

				tmp.warnExpire = userFaction.warnExpire or 0
				if tmp.warnExpire < os.time() then

					tmp.fWarn = tmp.fWarn - 1

					if tmp.fWarn > 0 then
						tmp.warnExpire = os.time() + 14 * 86400
						exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
							['$set'] = {
								['userFaction.warns'] = tmp.fWarn,
								['userFaction.warnExpire'] = tmp.warnExpire
							}
						}})
					else
						exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
							['$set'] = {
								['userFaction.warns'] = 0
							},
							['$unset'] = {
								['userFaction.warnExpire'] = 1
							}
						}})
					end

				end

			end
		elseif userFaction.faction ~= "user" then
			vRP.removeUserFaction(user_id, userFaction.faction, 0)
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(6500)
		TriggerClientEvent("vrp:playerJoinFaction", player, vRP.getUserFaction(user_id) or "user", vRP.getFactionType(theGroup))
		
		for faction, chestData in pairs(factionChests) do
			local x, y, z, weight = table.unpack(chestData)
			local chest_enter = function(player,area)
				local user_id = vRP.getUserId(player)

				if user_id and vRP.isUserInFaction(user_id, faction) then
					vRP.openChest(player, "fc:"..faction, weight, "Cufar factiune")
				end
			end

	        vRP.setArea(player, "factionchest:"..faction, x, y, z, 15.0, {minDst = 1.5, key = "E", text = "Acceseaza cufar"}, {
				type = 27,
				x = 0.501,
				y = 0.501,
				z = 0.501,
				color = {255, 255, 255, 150},
				coords = vec3(x,y,z) - vec3(0.0, 0.0, 0.9)
			}, chest_enter, function() end)
		end
	end
end)

local function ch_addfaction(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Add Faction","User id: ",false,function(id)
			if not id then return end
			id = parseInt(id)
			vRP.prompt(player,"Add Faction","Faction: ",false,function(group)
				if not group then return end
				group = tostring(group)
				if factions[group] then
					local members = vRP.getUsersByFaction(group)
					local fSlots = factions[group].fSlots
					if fSlots > #members or user_id <= 3 then

						exports.mongodb:findOne({collection = "users", query = {id = id}, options = {projection = {_id = 0, transferExpire = 1}}}, function(success, result)
							local transferDate = (result[1].transferExpire or 0)

							if transferDate <= os.time() then

								vRP.prompt(player,"Add Faction","Lider (1-0): ",false,function(lider)
									if not lider then return end
									lider = parseInt(lider)
									theTarget = vRP.getUserSource(id)
									if theTarget then

										if group == "Politie" then
											TriggerEvent("pd_eblips:add", {src = theTarget, color = 3, name = "Politist"})
										end

										local name = GetPlayerName(theTarget)
										if(lider == 1) then
											vRP.addUserFaction(id,group)
											Citizen.Wait(500)
											vRP.setFactionLeader(id,group)
											vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat ca lider in factiunea "..group})
											return
										else
											vRP.addUserFaction(id,group)
											vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat in factiunea "..group})
										end
									else
										vRPclient.notify(player, {"Jucatorul nu este conectat"})
									end
								end)

							else
								vRPclient.notify(player, {"Jucatorul are transfer !\nExpira: "..os.date("%d/%m/%Y %H:%M", transferDate)})
							end
						end)	
					else
						vRPclient.notify(player, {"Factiunea este plina"})
					end
				else
					vRPclient.notify(player, {"Factiunea este inexistenta"})
				end
			end)
		end)
	end
end

local function ch_removefactionAdmin(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Remove Faction","User id: ",false,function(id)
			if not id then return end
			local target_id = parseInt(id)

			vRP.prompt(player, "Remove Faction", "Transfer: (zile)", 0,function(days)
				if days and days:len() > 0 then
					local tDays = parseInt(days)
					if tDays >= 0 and tDays <= 90 then
						vRP.prompt(player, "Remove Faction","Motiv:", false,function(reason)
							if reason and reason:len() > 0 then
								local target = vRP.getUserSource(target_id)
								if target then
									local name = GetPlayerName(target)
									local target_faction = vRP.getUserFaction(target_id)
									
									vRPclient.notify(player,{"L-ai scos pe "..name.." din "..target_faction.."!\nTransfer: "..tDays.." zile\nMotiv: "..reason})
									vRPclient.notify(target,{"Ai fost scos din "..target_faction.."!\nTransfer: "..tDays.." zile\nMotiv: "..reason})
									vRP.removeUserFaction(target_id,target_faction,tDays)
								else

									exports.mongodb:findOne({collection = "users", query = {id = target_id}, options = {projection = {_id = 0, userFaction = 1}}}, function(success, result)
										local uFaction = result[1] and result[1].userFaction

										if uFaction.faction ~= "user" then

											vRPclient.notify(player,{"L-ai scos pe ID "..target_id.." din "..uFaction.faction.."!\nTransfer: "..tDays.." zile\nMotiv: "..reason})
											vRP.removeUserFaction(target_id, uFaction.faction, tDays)
										else
											vRPclient.notify(player, {"Jucatorul nu face parte din nici o factiune"})
										end
									end)

								end
							else
								vRPclient.notify(player, {"Este necesar un motiv pentru care doresti sa-l scoti din factiune"})
							end
						end)
					else
						vRPclient.notify(player, {"Ai voie sa dai transfer maxim 90 de zile"})
					end
				else
					vRPclient.notify(player, {"Zile de transfer invalide"})
				end
			end)


		end)
	end
end

local function ch_factionleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Faction Leader","User ID: ",false,function(id)
			if not id then return end
			id = parseInt(id)
			local theTarget = vRP.getUserSource(id)
			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." nu este in nici o factiune!"})
			else
				vRP.setFactionLeader(id,theFaction)
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." a fost adaugat ca lider in factiunea "..theFaction})
			end
		end)
	end
end

local function ch_createGang(player,  choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Create mafia", "Mafia name:", false, function(name)
			if name then
				vRP.prompt(player, "Create mafia", "Mafia slots:", false, function(slots)
					slots = tonumber(slots)
					if slots then
						vRP.prompt(player, "Create mafia", "Blip color:", false, function(color)
							color = tonumber(color)
							if color then
								vRP.request(player, "Esti sigur ca vrei sa creezi aceasta factiune ?<br><br>ATENTIE! Pozitia de spawn la war va fi setata la locatia ta actuala.", false, function(player, ok)
									if ok then
										local playerPed = GetPlayerPed(player)
										local x, y, z = table.unpack(GetEntityCoords(playerPed))

										local theFaction = {
											name = name,
											type = "Mafie",
											slots = slots,
											color = color,
											home = {x, y, z},
											ranks = {
												{rank = "Membru", payday = 100},
												{rank = "Co-Lider", payday = 150},
												{rank = "Lider", payday = 200}
											},
										}

										exports.mongodb:insertOne({collection = "factions", document = theFaction})
										vRPclient.notify(player, {"Ai creeat factiunea "..name.." !"})
										ExecuteCommand("loadfactions")
									end
								end)
							end
						end)
					end
				end)
			end
		end)
	end
end

local function ch_createChest(player,  choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Create chest", "Faction name:", false, function(name)
			if name then
				vRP.prompt(player, "Create chest", "Weight:", false, function(weight)
					weight = tonumber(weight)
					if weight then
						vRP.request(player, "Esti sigur ca vrei sa creezi acest cufar ?<br><br>ATENTIE! Pozitia lui va fi setata la locatia ta actuala.", false, function(player, ok)
							if ok then
								local playerPed = GetPlayerPed(player)
								local x, y, z = table.unpack(GetEntityCoords(playerPed))

								local theChest = {
									pos = {x, y, z},
									weight = weight,
								}

								exports.mongodb:updateOne({collection = "factions", query = {name = name}, update = {
									["$set"] = {chest = theChest}
								}})
								vRPclient.notify(player, {"Ai creeat cufarul factiunii "..name.." !\nAtentie! Acesta va aparea dupa restart."})
							end
						end)
					end
				end)
			end
		end)
	end
end

vRP.registerMenuBuilder("admin", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		local adminLevel = vRP.getUserAdminLevel(user_id)

		if vRP.hasGroup(user_id, "Manager Factiuni") or adminLevel >= 4 then
		-- build admin menu
			choices["Adauga in Factiune"] = {ch_addfaction, '<i class="fa-solid fa-user-plus"></i>'}
			choices["Adauga Lider Factiune"] = {ch_factionleader, '<i class="fa-solid fa-user-crown"></i>'}
			choices["Scoate din Factiune"] = {ch_removefactionAdmin, '<i class="fa-solid fa-house-person-return"></i>'}
		end

		if adminLevel >= 5 then
			choices["Creeaza o Mafie"] = {ch_createGang, '<i class="fas fa-cannabis"></i>'}
			choices["Creeaza un cufar"] = {ch_createChest, '<i class="fa-duotone fa-treasure-chest"></i>'}
		end

		add(choices)
	end
end)

-- menu related --


RegisterServerEvent("vrp-factions:inviteMember", function()
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.hasUserFaction(user_id) then
		local faction = vRP.getUserFaction(user_id)

		if not vRP.isFactionLeader(user_id, faction) then
			TriggerClientEvent("vrp-hud:sendApiError", "Nu esti lider in aceasta factiune")
			return
		end

		ch_inviteFaction(player)
	end
end)

registerCallback('faction:kick', function(player, target_id)
	local user_id = vRP.getUserId(player)

	if not target_id then return false end

	if vRP.hasUserFaction(user_id) then	
		local faction = vRP.getUserFaction(user_id)
		if vRP.isFactionLeader(user_id, faction) then
			local transfer = 0
			if vRP.getFactionType(faction) == "Lege" then
				local days = vRP.getUserFactionDays(target_id)

				local users, found = factionMembers[faction] or {}, false
				
				for i, v in pairs(users) do
					if v.id == target_id then
						found = v
						break
					end
				end

				if not found then goto skip end

				if days < 14 then
					transfer = 14-days
				end
			end
			::skip::
			-- TODO: de facut sa se calculeze automat transferul. DONE

			local target = vRP.getUserSource(target_id)
			if target then
				local name = GetPlayerName(target)
				TriggerClientEvent("vrp-hud:sendApiInfo", player, "L-ai scos pe "..name.." din "..faction.."!")
				vRPclient.notify(target,{"Ai fost scos din "..faction.."!\nTransfer: "..transfer.." zile"})
			else
				TriggerClientEvent("vrp-hud:sendApiInfo", player, "L-ai scos pe ID "..target_id.." din "..faction.."!")
			end

			vRP.removeUserFaction(target_id, faction, transfer)
		end

		return true
	end
	return {}
end)

registerCallback('faction:setRank', function(player, target_id, rank)
	local user_id = vRP.getUserId(player)

	if not target_id then return false end

	if vRP.hasUserFaction(user_id) then	
		local faction = vRP.getUserFaction(user_id)
		if vRP.isFactionLeader(user_id, faction) then
			setFactionRank(target_id, faction, rank)

			return true
		end
	end
	return false
end)

registerCallback('faction:deleteRank', function(player, rank)
	local user_id = vRP.getUserId(player)

	if not rank then return false end

	if vRP.hasUserFaction(user_id) then	
		local faction = vRP.getUserFaction(user_id)

		if vRP.getFactionType(faction) == "Lege" then
			return false
		end

		if vRP.isFactionLeader(user_id, faction) then
			local ranks = factions[faction].fRanks

			local prevRank = false
			for k,v in pairs(ranks) do
				if v.rank == rank then
					if k < 2 then
						TriggerClientEvent("vrp-hud:sendApiError", player, "Nu poti sterge cel mai mic rang.")
						return false
					end
					
					prevRank = ranks[k-1].rank
				end
			end

			if not prevRank then return false end

			local groupUsers = factionMembers[faction]
			if groupUsers then
				for i, v in pairs(groupUsers) do
					if v.userFaction.rank == rank then
						setFactionRank(v.id, faction, prevRank)
					end
				end

				local success = false
				for i, v in pairs(ranks) do
					if v.rank == rank then
						table.remove(ranks, i)
						success = true
						break
					end
				end
				if success then
					exports.mongodb:updateOne({collection = "factions", query = {name = faction}, update = {['$set'] = {ranks = ranks}}})
				end
			end

			return true
		end
	end
	return false
end)

registerCallback('faction:createRank', function(player, rank)
	local user_id = vRP.getUserId(player)

	if not rank then return false end

	if vRP.hasUserFaction(user_id) then	
		local faction = vRP.getUserFaction(user_id)

		if vRP.getFactionType(faction) == "Lege" then
			return false
		end

		if vRP.isFactionLeader(user_id, faction) then
			if not factions[faction].fRanks then
				factions[faction].fRanks = {}
			end
			local ranks = factions[faction].fRanks

			local groupUsers = factionMembers[faction]
			if groupUsers then
				table.insert(ranks, {rank = firstToUpper(rank), payday = 0})
				exports.mongodb:updateOne({collection = "factions", query = {name = faction}, update = {['$set'] = {ranks = ranks}}})
			end

			return true
		end
	end
	return false
end)


registerCallback("faction:deposit", function(player, amount)
	local user_id = vRP.getUserId(player)

	if vRP.hasUserFaction(user_id) then
		local faction = vRP.getUserFaction(user_id)

		amount = tonumber(amount)

		if amount and amount > 0 then
			if vRP.tryFullPayment(user_id, amount, true, false, "Faction Budget Deposit") then
				vRP.depositFactionBudget(faction, amount)
			else
				TriggerClientEvent("vrp-hud:sendApiError", player, "Nu iti permiti sa platesti $"..vRP.formatMoney(amount)..".")
			end

			return {budget = vRP.getFactionBudget(faction), cash = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id)}
		end
	end
end)

registerCallback("faction:withdraw", function(player, amount)
	local user_id = vRP.getUserId(player)

	if vRP.hasUserFaction(user_id) then
		local faction = vRP.getUserFaction(user_id)

		amount = tonumber(amount)

		if amount and amount > 0 then

			if vRP.isFactionLeader(user_id,faction) or vRP.isUserCoLeader(user_id, faction) then
				vRP.withdrawFactionBudget(faction, user_id, amount)
			else
				TriggerClientEvent("vrp-hud:sendApiError", player, "Doar liderul si coliderul pot retrage bani din factiune.")
			end

			return {budget = vRP.getFactionBudget(faction), cash = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id)}
		end
	end
end)

registerCallback('getFactionData', function(player)
	local user_id = vRP.getUserId(player)
	if not vRP.hasUserFaction(user_id) then return false end
	
	local userFaction = vRP.getUserFaction(user_id)
	
	local factionType = vRP.getFactionType(userFaction)

	local members = {}
	local factionRanks = {}
	local onlineMembers = 0
	local factionLeader = "Fara lider"
	local tasks = {}
	local factionLevel = {}

	for index, data in pairs(factions[userFaction].fRanks or {}) do
		factionRanks[data.rank] = {payday = data.payday, total = 0}
	end

	for index, data in pairs(factionMembers[userFaction] or {}) do
		data.online = vRP.getUserSource(data.id) ~= nil
		data.lastHours = data.lastHours or 0

		onlineMembers += (data.online and 1 or 0)

		if data.userFaction.rank and factionRanks[data.userFaction.rank] then
			factionRanks[data.userFaction.rank].total += 1
		end

		if data.userFaction.leader == 1 then
			factionLeader = data.username
		end

		table.insert(members, data)
	end

	-- for task, data in pairs(cfg.factionTasks[factionType] or {}) do
	-- 	data.complete = factions[userFaction].tasks and factions[userFaction].tasks[task] and factions[userFaction].tasks[task].complete or false
	-- 	data.progress = factions[userFaction].tasks and factions[userFaction].tasks[task] and factions[userFaction].tasks[task].value or 0

	-- 	table.insert(tasks, data)
	-- end

	local level = 0;
	-- for factionLevel, data in pairs(cfg.factionLevels) do
	-- 	if data.requiredXP <= factions[userFaction].factionXP then
	-- 		level = factionLevel
	-- 	end
	-- end

	factionLevel = {
		level = level,
		nextLevelXP = 0, --cfg.factionLevels[level + 1] and cfg.factionLevels[level + 1].requiredXP or 0
		currentXP = 0, -- factions[userFaction].
	}
	
	return {
		userData = {
			cash = vRP.getMoney(user_id),
			bank = vRP.getBankMoney(user_id),
		},
		onlineMembers = onlineMembers,
		faction = userFaction,
		members = members,
		factionLeader = factionLeader,
		ranks = factionRanks or {},
		menuRanks = factions[userFaction].fRanks or {},
		totalMembers = #factionMembers[userFaction],
		maxSlots = factions[userFaction].fSlots,
		balance = factions[userFaction].fBudget,
		factionType = factionType,
		isLeader = vRP.isFactionLeader(user_id, userFaction) or false,
		tasks = tasks,
		factionLevel = factionLevel,
	}
end)


--- ---

function vRP.doGroupFunction(group, cb)
	local users = vRP.getUsers()
	for user_id, source in pairs(users) do
		if vRP.hasGroup(user_id, group) then
			cb(source)
		end 
	end
end

function vRP.doFactionFunction(faction, fnct, exceptSrc)
	if not exceptSrc then exceptSrc = 0 end
	local members = vRP.getUsersByFaction(faction)
	for k, v in pairs(members) do
		local src = vRP.getUserSource(v.id)
		if src then
			if src ~= exceptSrc then
				fnct(src)
			end
		end
	end
end

function vRP.getAliveFactionMembers(faction)
	local alive = 0
	local members = vRP.getUsersByFaction(faction)
	for k, v in pairs(members) do
		local src = vRP.getUserSource(v.id)
		if src then
			vRPclient.isInComa(src, {}, function(inComa)
                if not inComa then
                    alive = alive + 1
                end
            end)
		end
	end
	Citizen.Wait(100)
	return alive
end

function vRP.doFactionTypeFunction(ftype, fnct, exceptFaction)
	if not exceptFaction then exceptFaction = "" end
	for i, v in pairs(factions) do
		if tostring(i) ~= exceptFaction then
			if v.fType == ftype then
				vRP.doFactionFunction(tostring(i), function(src) fnct(src) end)
			end
		end
	end
end


-- RegisterCommand('d', function(player, args, raw)
-- 	local user_id = vRP.getUserId(player)
-- 	if vRP.hasUserFaction(user_id) then
-- 		local tF = vRP.getUserFaction(user_id)

-- 		if tF == "Politie" or tF == "Avocat" or tF == "Smurd" then
-- 			local msg = raw:sub(3)
-- 			if msg:len() >= 1 then

-- 				msg = '^5[^7Dept^5][^7' .. tF:reverse():sub(tF:len()) .. "^5][^7" .. GetPlayerName(player) .. "^5]^7: " .. msg

-- 				for uid, src in pairs(vRP.rusers) do
-- 					local uFaction = vRP.getUserFaction(uid)
-- 					if uFaction == "Politie" or uFaction == "Avocat" or uFaction == "Smurd" then
-- 						TriggerClientEvent("chatMessage", src, msg)
-- 					end
-- 				end

-- 			else
-- 				vRPclient.sendSyntax(player, {"/d <mesaj>"})
-- 			end

-- 		else
-- 			vRPclient.noAccess(player)
-- 		end
-- 	end
-- end)
