
local tempWarns = {}

function vRP.getWarnsNum(user_id, cbr)
	local task = Task(cbr, {0})

	local warns = tempWarns[user_id]
	if warns then
		local warnsNr = 0
		for k, v in pairs(warns) do
			warnsNr = warnsNr + 1
		end
		task({warnsNr})
	else
		task({0})
	end
end

function vRP.getWarns(user_id)
	return tempWarns[user_id] or {}
end

function vRP.addWarn(user_id, reason, admin)
	local theWarn = {
		time = os.time(),
		reason = reason,
		admin = admin or "Necunoscut",
		date = os.date("%d/%m/%Y %H:%M"),
	}

	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
		["$push"] = {
			userWarns = theWarn
		}
	}}, function(success)
		table.insert(tempWarns[user_id], theWarn)
		local warns = tempWarns[user_id]
		if warns then
			local warnsNumber = 0
			for _, v in pairs(warns) do
				warnsNumber = warnsNumber + 1
			end
			
			if warnsNumber >= 3 then
				vRP.updateUser(user_id, 'userWarns', false)
				vRP.ban(user_id,"Acumulare a 3/3 Warnuri",false,14)
			end
		end
	end)
end

function vRP.removeWarn(user_id)
	local warns = tempWarns[user_id]
	if warns then
		local minWarn = 0
		local minIndx = 1
		for i, v in ipairs(warns) do
			if i == 1 then
				minWarn = v.time
			else
				if v.time > minWarn then
					minWarn = v.time
					minIndx = i
				end
			end
		end

		tempWarns[user_id][minIndx] = nil

		Citizen.Wait(500)
		local newWarns = table.len(tempWarns[user_id])

		if newWarns >= 1 then
			vRP.updateUser(user_id, 'userWarns', tempWarns[user_id])
		else
			vRP.updateUser(user_id, 'userWarns', false)
		end
	end
end

RegisterCommand("warn", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) < 2 then
		return vRPclient.noAccess(player, {})
	end

	if not args[1] or not args[2] then
		return vRPclient.sendSyntax(player, {"/warn <user_id> <motiv>"})
	end

	local target_id = tonumber(args[1])
	local target_src = vRP.getUserSource(target_id)

	local name = target_id
	if target_src then
		name = GetPlayerName(target_src).." ("..name..")"
	end

	local reason = table.concat(args, " ", 2)
	local adminName = GetPlayerName(player)
	local adminId = user_id;
	vRP.request(src, ("Esti sigur ca vrei sai dai warn lui ID: "..target_id), false, function(_, ok)
		if ok then
			exports.mongodb:insertOne({collection = "punishLogs", document = {
				user_id = tonumber(target_id),
				time = os.time(),
				type = "warn",
				text = "A primit WARN de la "..GetPlayerName(player).." ("..adminId.."). Motiv: "..reason
			}})

			print(adminName.." i-a dat warn lui "..name..", motiv: "..reason)
			vRPclient.msg(-1, {"^eWarn: "..adminName.." i-a dat un warn lui "..name..", motiv: "..reason})
			vRP.addWarn(target_id, reason, adminName.." ("..adminId..")")
		end
	end)
end)


RegisterCommand("unwarn", function(player, args)
	if player == 0 then
		if not args[1] then
			return print("^5Sintaxa: ^7/unwarn <id>")
		end

		vRP.removeWarn(tonumber(args[1]))
		print("^2Succes: ^7Warnul jucatorului a fost scos.")

		return
	end

	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) < 4 then
		return vRPclient.noAccess(player, {})
	end
	
	if not args[1] then
		return vRPclient.sendSyntax(player, {"/unwarn <user_id>"})
	end
	
	local target_id = tonumber(args[1])
	local target_src = vRP.getUserSource(target_id)

	local name = target_id
	if target_src then
		name = GetPlayerName(target_src).." ("..name..")"
	end

	exports.mongodb:insertOne({collection = "punishLogs", document = {
		user_id = tonumber(target_id),
		time = os.time(),
		type = "unwarn",
		text = "A primit UNWARN de la "..GetPlayerName(player).." ("..user_id..")"
	}})

	vRPclient.msg(-1, {"^eUnwarn: "..GetPlayerName(player).." i-a scos un warn lui "..name})
	vRP.removeWarn(target_id)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		tempWarns[user_id] = dbdata.userWarns or {}
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	tempWarns[user_id] = nil
end)