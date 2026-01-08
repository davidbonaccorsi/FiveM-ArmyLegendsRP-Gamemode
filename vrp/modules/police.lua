
local cfg = module("cfg/police")

local function showBadge(player, nPlayer)
	local user_id = vRP.getUserId(player) 
	local faction = vRP.getUserFaction(user_id)
	local rank = vRP.getFactionRank(user_id)

	vRP.getUserIdentity(user_id, function(userIdentity)
		if userIdentity then
			local name = userIdentity.firstname.." "..userIdentity.name
			local data = {name = name, faction = faction, rank = rank}

			if nPlayer then
				TriggerClientEvent("vrp-identity:startBadgeAnim", player, faction)
				Citizen.Wait(300)

				TriggerClientEvent("vrp:sendNuiMessage", nPlayer, {interface = "factionBadge", data = data})
			end

			TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "factionBadge", data = data})
		end
	end)
end

-- RegisterCommand('test', function(source)
-- 	local data = {name = 'Coi?', faction = 'Smurd', rank = 'Rege international'}

-- 	TriggerClientEvent("vrp:sendNuiMessage", source, {interface = "factionBadge", data = data})
-- end)

local allowedToSpawn = {}
local policeObj = {}
local function ch_policeprops(player, choice)
	allowedToSpawn[player] = true
	vRPclient.spawnAnyPoliceProp(player, {cfg.pdprops})
end

local function ch_policecalls(player, choice)
	TriggerEvent("ems:openCallsMenu", player)
end

registerCallback('isUserCop', function(player)
	local user_id = vRP.getUserId(player)

	return vRP.isUserInFaction(user_id, "Politie")
end)

-- police calls --

local activeCalls = {}

function vRP.getActiveCalls()
	return activeCalls
end

AddEventHandler("vrp-phone:callService", function(service)
    local player = source
    local user_id = vRP.getUserId(player)

    if service == "police" then

        if not activeCalls[user_id] then

            
            vRP.prompt(player, "Apel Politie", "Descrie motivul solicitarii unui echipaj din departament pe scurt.", false, function(note)

                if note then
                    activeCalls[user_id] = {
                        user_id = user_id,
                        player = player,
                        name = exports.vrp:getRoleplayName(user_id, true),
                        position = GetEntityCoords(GetPlayerPed(player)),
                        note = note,
                    }
                end

                Citizen.Wait(100)
                if activeCalls[user_id] then
                    vRP.doFactionFunction("Politie", function(member)
                        TriggerClientEvent("vrp:sendNuiMessage", member, {interface = "emsCallsAlert"})
                    end)
                end

            end)
        else
            vRPclient.notify(player, {"Ai deja un apel in asteptare.", "error"})
        end
    end
end)

AddEventHandler("ems:takeCall", function(target_id)
    local player = source
    local user_id = vRP.getUserId(player)

    if vRP.isUserPolitist(user_id) then
        if activeCalls[target_id] then
            TriggerClientEvent("ems:startCall", player, activeCalls[target_id].player, activeCalls[target_id].position, 137, 38)
            
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.notify(target_src, {"Un echipaj se indreapta de urgenta catre tine.", "error"})

                vRPclient.notify(player, {"Te indrepti catre un apel.\n\nSolicitant: "..exports.vrp:getRoleplayName(target_id).."\nDescriere: "..activeCalls[target_id].note, "info", "Apel preluat", 10000})
            end

            activeCalls[target_id] = nil
        else
            vRPclient.notify(player, {"Solicitare invalida.", "error"})
        end
    end
end)

AddEventHandler("ems:openCallsMenu", function(player)
    local user_id = vRP.getUserId(player)
    -- --

    if vRP.isUserPolitist(user_id) then
        TriggerClientEvent("ems:showCallsMenu", player, {
            interface = "emsCalls",
            calls = activeCalls,
        })
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if activeCalls[user_id] then
        activeCalls[user_id] = nil
    end
end)

--- ---

-- backup --

local backupCooldown = 0

local function checkCooldown(player, cb)
	if (backupCooldown or 0) <= os.time() then
		backupCooldown = os.time() + 5

		cb(player)
	else
		vRPclient.notify(player, {"Cooldown: "..backupCooldown - os.time().." secunde", "error"})
	end
end


local function sendPoliceBackup(player, medicsToo, tbl)
	local ped = GetPlayerPed(player)

	tbl.position = GetEntityCoords(ped)
	
	vRP.doFactionFunction("Politie", function(src)
		TriggerClientEvent("police:sendBackup", src, tbl)
	end)

	if medicsToo then
		vRP.doFactionFunction("Smurd", function(src)
			TriggerClientEvent("police:sendBackup", src, tbl)
		end)
	end
end

exports("sendPoliceBackup", sendPoliceBackup)

RegisterCommand("bk0", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		checkCooldown(player, function(player)
			local name = exports.vrp:getRoleplayName(user_id)

			sendPoliceBackup(player, true, {code = "BK 0", name = name, description = cfg.backupTexts["BK 0"]})
		end)
	end
end)

RegisterCommand("bk1", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local name = exports.vrp:getRoleplayName(user_id)

		sendPoliceBackup(player, false, {code = "BK 1", name = name, description = cfg.backupTexts["BK 1"]})
	end
end)

RegisterCommand("bk2", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local name = exports.vrp:getRoleplayName(user_id)

		sendPoliceBackup(player, false, {code = "BK 2", name = name, description = cfg.backupTexts["BK 2"]})
	end
end)

RegisterCommand("bk3", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local name = exports.vrp:getRoleplayName(user_id)

		sendPoliceBackup(player, false, {code = "BK 3", name = name, description = cfg.backupTexts["BK 3"]})
	end
end)

RegisterCommand("bk4", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local name = exports.vrp:getRoleplayName(user_id)

		sendPoliceBackup(player, true, {code = "BK 4", name = name, description = cfg.backupTexts["BK 4"]})
	end
end)

local shootCooldown = 0
RegisterServerEvent("police:reportShoot", function(data, playerCoords)
	local player = source
	local user_id = vRP.getUserId(player)

	if (shootCooldown or 0) < os.time() then
		-- if not exports["vrp_paintball"]:isInPaint(user_id) then	
			sendPoliceBackup(source, false, {code = "10-11", description = cfg.backupTexts["10-11"]})
			shootCooldown = os.time() + 5
		-- end
	end
end)

--- ---

-- jail --

local function getdist(x1, x2, y1, y2)
	return math.sqrt((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1))
end

local unjailed = {}
local function jail_clock(target_id, timer)
	local target = vRP.getUserSource(tonumber(target_id))
	if target then
		if timer > 0 then
			TriggerClientEvent("vrp-hud:runjs", target, "serverHud.jail_show = true; serverHud.jail_time = '"..timer.." minute'")
			-- vRPclient.notify(target, {"Timp ramas: " .. timer .. " minut(e)."})
			vRP.setUData(tonumber(target_id),"vRP:jail:time",tostring(timer))
			SetTimeout(60*1000, function()
				for k,v in pairs(unjailed) do -- check if player has been unjailed by cop or admin
					if v == tonumber(target_id) then
							unjailed[v] = nil
						timer = 0
					end
				end

				vRPclient.getPosition(target, {}, function(x, y, z)
					-- local jx, jy = -3696.9399414063,-4044.1381835938
					local jx, jy = -3696.9399414063,-4044.1381835938
					if getdist(x, jx, y, jy) > 200.0 then
						vRPclient.teleport(target, {jx, jy, 57.665592193604}) -- 57.665592193604
					end
				end)
				

				vRPclient.setHealth(target, {200})
				jail_clock(tonumber(target_id),timer-1)
				TriggerClientEvent("afk-kick:passAutoKick", target, true)
			end)
		else
			vRPclient.loadFreeze(target,{true})
			SetTimeout(15000, function()
				vRPclient.loadFreeze(target,{false})
			end)
			vRPclient.teleport(target,{425.7607421875,-978.73425292969,30.709615707397}) -- teleport to outside jail
			vRPclient.setHandcuff(target,{false})
				vRPclient.notify(target,{"Ai fost scos din jail."})
				TriggerClientEvent("afk-kick:passAutoKick", target, false)
			vRP.setUData(tonumber(target_id), "vRP:jail:time", tostring(-1))
			TriggerClientEvent("vrp-hud:runjs", target, "serverHud.jail_show = false")
		end
	end
end
exports("jail_clock", jail_clock)

function vRP.setInPoliceJail(user_id, jail_time)
	local target = vRP.getUserSource(user_id)

	if target then
		vRPclient.setHandcuff(target, {false})
		vRPclient.loadFreeze(target, {true})
		vRPclient.teleport(target, {-3696.9399414063,-4044.1381835938,57.665592193604}) -- teleport to inside jail {-3696.9399414063,-4044.1381835938,57.665592193604}
		SetTimeout(5000, function()
			vRPclient.loadFreeze(target, {false})
		end)
		
		vRPclient.notify(target, {"Ai fost trimis in Alcatraz."})

		vRP.depositFactionBudget("Politie", math.random(100, 150))
		vRP.closeMenu(target)
	
		jail_clock(user_id, jail_time)			
	end
end

local function ch_unjail(player,target) 
	local user_id = vRP.getUserId(player)
	local target_id = vRP.getUserId(target)
	vRP.getUData(tonumber(target_id),"vRP:jail:time",function(custom)
		custom = tonumber(custom) or 0
		if tonumber(custom) > 0 then
						unjailed[target] = tonumber(target_id)
			vRPclient.notify(player,{"Jucatorul va fi scos din jail in curand."})
			vRPclient.notify(target,{"Ti-a fost scazuta sentinta."})
		else
			vRPclient.notify(player,{"Jucatorul nu este in jail.", "error"})
		end
	end)
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	vRP.getUData(user_id, "vRP:jail:time", function(custom)
		custom = tonumber(custom) or 0

		if tonumber(custom) > 0 then
			Citizen.CreateThread(function()
				Citizen.Wait(5000)
				vRPclient.loadFreeze(source, {true})
				SetTimeout(5000, function()
					vRPclient.loadFreeze(source, {false})
				end)
				vRPclient.setHandcuff(source, {true})
				vRPclient.teleport(source, {-3837.1481933594,-4085.5886230469,57.432655334473}) -- teleport inside jail {1647.3854980469, 2539.63671875, 45.577964782715}
				-- vRPclient.notify(source, {"Mai ai "..custom.." (de) minute!"})
				jail_clock(user_id, tonumber(custom))
			end)
		end
	end)
end)

--- ---

-- storage --

local storage_items = {}

local cfg_storage = module("cfg/armory")
local storage_types = cfg_storage.storage_types

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	for gtype, items in pairs(storage_types) do
		storage_items[gtype] = {}

		for k, v in pairs(items) do
			if type(v) == "table" and k ~= "_config" then
				local item_name = vRP.getItemName(k)

				if item_name then
					storage_items[gtype][k] = {
						name = item_name,
						amount = v[1],
						rank = v[2]
					}
				end
			end
		end
	end
end)

local function build_client_storages(source)
	for i, v in pairs(cfg_storage.storages) do
		local x, y, z, gtype = table.unpack(v)
		local group = storage_types[gtype]

		if group and x and y and z then
			local gcfg = group._config

			local storage_enter = function(player,area)
				local user_id = vRP.getUserId(player)

				local canEnter = false
				if user_id ~= nil and vRP.hasPermissions(user_id,gcfg.permissions or {}) and gcfg.faction == nil and gcfg.fType == nil then
				  canEnter = true
				elseif(gcfg.fType ~= nil and gcfg.fType ~= "")then
					  if(vRP.hasUserFaction(user_id))then
						  local theFaction = vRP.getUserFaction(user_id)
						  if(tostring(vRP.getFactionType(theFaction)) == tostring(gcfg.fType))then
							  canEnter = true
						  end
					  end
				elseif(gcfg.faction ~= nil and gcfg.faction ~= "")then
					  if(vRP.isUserInFaction(user_id,gcfg.faction))then
						  canEnter = true
					  end
				end

				if canEnter then
					TriggerClientEvent("vrp-hud:updateMap", player, false)
					TriggerClientEvent("vrp-hud:setComponentDisplay", player, {
						serverHud = false,
						minimapHud = false,
						bottomRightHud = false,
						chat = false,
					})
					TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "factionStorage", faction = gtype})
				end
			end
		
	        if gcfg.blipid then
	          vRPclient.addBlip(source, {"vRP:storage"..i, x, y, z, gcfg.blipid, gcfg.blipcolor, "Echipament ("..gtype..")", 0.7})
	        end

	        vRP.setArea(source, "vRP:storage"..i, x, y, z, 15.0, {
				key = "E",
				text = gcfg.text or "Echipament "..gtype,
				minDst = 1
	        }, {
				type = 27,
				x = 0.501,
				y = 0.501,
				z = 0.5001,
				color = gcfg.iconColor or {255, 255, 255, 200},
				coords = vec3(x,y,z) - vec3(0.0, 0.0, 0.9)
			}, storage_enter, function() end)
		end
	end
end

local inv_cfg = module('cfg/inventory')
RegisterServerEvent("police:getStorageItem")
AddEventHandler("police:getStorageItem", function(itemid, gtype)
	local player = source
	local user_id = vRP.getUserId(player)

	local group, items = storage_types[gtype], storage_items[gtype] or {}

	if group and items[itemid] and user_id then
		local gcfg = group._config

		local canEnter = false
		if user_id ~= nil and vRP.hasPermissions(user_id,gcfg.permissions or {}) and gcfg.faction == nil and gcfg.fType == nil then
			canEnter = true
		elseif(gcfg.fType ~= nil and gcfg.fType ~= "")then
			if(vRP.hasUserFaction(user_id))then
				local theFaction = vRP.getUserFaction(user_id)
				if(tostring(vRP.getFactionType(theFaction)) == tostring(gcfg.fType))then
					canEnter = true
				end
			end
		elseif(gcfg.faction ~= nil and gcfg.faction ~= "")then
			if(vRP.isUserInFaction(user_id,gcfg.faction))then
				canEnter = true
			end
		end

		if canEnter and items[itemid].rank then
			canEnter = (tonumber(vRP.getFactionRankNumber(user_id)) >= items[itemid].rank)

			if not canEnter then
				vRPclient.notify(player, {"Nu detii rangul "..items[itemid].rank})
			end
		end

		local amount = items[itemid].amount

		if canEnter and vRP.canCarryItem(user_id, itemid, amount) then
			vRP.giveItem(user_id, itemid, amount, false, false, false, 'Faction Storage - '..gtype)
			if string.find(itemid, "weapon_") and inv_cfg.weapons[itemid] and inv_cfg.weapons[itemid].ammo then
				local ammo_amount = vRP.getInventoryItemAmount(user_id, inv_cfg.weapons[itemid].ammo)
				vRP.giveItem(user_id, inv_cfg.weapons[itemid].ammo, 250 - ammo_amount, false, false, false, 'Faction Storage - '..gtype)
			end
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(5000)
		TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "populateFactionStorage", cfg = storage_items})
		build_client_storages(player)
	end
end)

--- ---

-- mdt --
--[[
function vRP.addPoliceWarrant(user_id, reason, police)
	local tmp = vRP.getUserTmpTable(user_id)
	if not tmp.policeWarrants then
		tmp.policeWarrants = {}
	end

	local theWarn = {
		time = os.time(),
		reason = reason,
		name = exports.vrp:getRoleplayName(user_id),
		author = exports.vrp:getRoleplayName(police),
		police = police,
		rank = vRP.getFactionRank(police),
		date = os.date("%d/%m/%Y %H:%M"),
	}

	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
		["$push"] = {
			policeWarrants = theWarn
		}
	}}, function(success)
		table.insert(tmp.policeWarrants, theWarn)
		
		local player = vRP.getUserSource(user_id)
		local police_src = vRP.getUserSource(police)

		vRPclient.notify(police_src, {"Ai intocmit un dosar penal."})
		vRPclient.notify(player, {"Ti-a fost intocmit un dosar penal."})
	end)
end

function tvRP.mdtSearchPlate(plate)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local found = promise.new()

		exports.mongodb:findOne({collection = "userVehicles", query = {carPlate = plate}}, function(success, result)
			if not success or not result[1] then
				found:resolve({false, false})
			else
				local user_id = tonumber(result[1].user_id)
				local player = vRP.getUserSource(user_id)

				if player then
					found:resolve({result[1], exports.vrp:getRoleplayName(user_id)})
				else
					exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {_id = 0, userIdentity = 1}}}, function(success, rows)
						found:resolve({result[1], rows[1].userIdentity.firstname.." "..rows[1].userIdentity.name})
					end)
				end
			end
		end)

		return table.unpack(Citizen.Await(found))
	end
end

function tvRP.mdtGetMatchingCitizens(query)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local found = {}

		if tonumber(query) then
			local result = exports.mongodb:findOne({collection = "users", query = {id = tonumber(query)}, options = {projection = {_id = 0, id = 1, userIdentity = 1}}})
			if next(result or {}) then
				table.insert(found, result)
			end
		else
			local user = exports.mongodb:findMultiple({
				collection = 'users',
				query = {{
					id = tostring(query),
				}, {
					['userIdentity.firstname'] = {
						['$regex'] = string.format('^%s', query),
						['$options'] = 'i'
					},
				}, {
					['userIdentity.name'] = {
						['$regex'] = string.format('^%s', query),
						['$options'] = 'i'
					}
				}},
				options = {projection = {_id = 0, id = 1, userIdentity = 1}},
				required = false, 
			})

			for k, v in pairs(user or {}) do
				table.insert(found, v)
			end
		end

		if not next(found) then
			found = false
		end

		return found
	end

	return false
end

function tvRP.mdtSearchCitizen(query)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		local found = {}

		if tonumber(query) then
			local result = exports.mongodb:findOne({collection = "users", query = {id = tonumber(query)}, options = {projection = {_id = 0, id = 1, userIdentity = 1, dmvTest = 1}}})
			found.user = result or {}
		else
			local user = exports.mongodb:findMultiple({
				collection = 'users',
				limit = 1,
				query = {{
					id = tostring(query),
				}, {
					['userIdentity.firstname'] = {
						['$regex'] = string.format('^%s', query),
						['$options'] = 'i'
					},
				}, {
					['userIdentity.name'] = {
						['$regex'] = string.format('^%s', query),
						['$options'] = 'i'
					}
				}},
				options = {projection = {_id = 0, id = 1, userIdentity = 1, dmvTest = 1}},
				required = false, 
			})
			found.user = user[1] or {}
		end

		if found.user then
			local user_id = tonumber(found.user.id)
			
			local houseCount, userHouses = exports['playerhousing']:getUserHouses(user_id)
			found.houses = userHouses

			local result = exports.mongodb:find({collection = "userVehicles", query = {user_id = user_id}, options = {projection = {_id = 0, name = 1, carPlate = 1}}})
			found.vehicles = result or {}
		end

		if not next(found.user) or not found.user.userIdentity then
			found = false
		end
		
		return found
	end

	return false
end

function tvRP.mdtSearchWarrants(query)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then

		if string.find(query, "cnp:") then
			query = query:sub(5)
		end

		local found = exports.mongodb:findMultiple({
			collection = 'users',
			query = {{
				id = tonumber(query) or "invalid",
			}, {
				['userIdentity.firstname'] = {
					['$regex'] = string.format('^%s', query),
					['$options'] = 'i'
				},
			}, {
				['userIdentity.name'] = {
					['$regex'] = string.format('^%s', query),
					['$options'] = 'i'
				}
			}},
			options = {projection = {_id = 0, id = 1, policeWarrants = 1}},
			required = false, 
		})
		return found or {}
	end

	return false
end
]]

--- ---


local function ch_cuffplayer(player, nplayer)
	local user_id = vRP.getUserId(player)
	local nuser_id = vRP.getUserId(nplayer)

	if not nuser_id then
	  return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
	end

	vRPclient.isHandcuffed(nplayer,{true}, function(cuffed)  -- check handcuffed
		cuffed = not cuffed

		if not cuffed then
		  TriggerClientEvent("police:animUncuffed", nplayer, player)
		  vRPclient.executeCommand(player, {"e uncuff"})
		else
		  TriggerClientEvent('police:animBeingArrest', nplayer, player)
		  TriggerClientEvent('police:animArresting', player)
		end

		Citizen.CreateThread(function()
		  Citizen.Wait(3000)

		  vRPclient.togHandcuffs(nplayer, {})
		  vRPclient.executeCommand(player, {"e c"})
		end)
	end)
end


local function ch_putinveh(player, nplayer)
	local user_id = vRP.getUserId(player)
	local nuser_id = vRP.getUserId(nplayer)

	if not nuser_id then
		return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
	end

	vRPclient.isHandcuffed(nplayer,{true}, function(handcuffed)  -- check handcuffed
		if not handcuffed and not vRP.isUserInFaction(user_id, "Smurd") then
			return vRPclient.notify(player, {"Nu este incatusat!", "error"})
		end

		vRPclient.putInNearestVehicleAsPassenger(nplayer, {5}, function(inVehicle)
			if not inVehicle then return end

			vRPclient.notify(player, {"L-ai pus in vehicul cu succes."})
		end)
	end)
end

local function ch_ejectfromveh(player, nplayer)
	local user_id = vRP.getUserId(player)
    local nuser_id = vRP.getUserId(nplayer)

	if not nuser_id then
		return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
	end

    vRPclient.isHandcuffed(nplayer,{true}, function(handcuffed)  -- check handcuffed
	    if not handcuffed and not vRP.isUserInFaction(user_id, "Smurd") then
	    	return vRPclient.notify(player, {"Nu este incatusat!", "error"})
	    end

    	vRPclient.ejectVehicle(nplayer, {}, function(inVehicle)
    		if not inVehicle then return end

    		vRPclient.notify(player, {"L-ai scos din vehicul cu succes."})
  		end)
    end)
end

local function ch_seizeobjects(player, nplayer)
	local user_id = vRP.getUserId(player)
	local nuser_id = vRP.getUserId(nplayer)

	vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
	    if not handcuffed then
	    	return vRPclient.notify(player, {"Nu este incatusat!", "error"})
	    end

		-- todo: bankrob seize

		for k,v in pairs(cfg.seizable_items) do -- transfer seizable items
			local amount = vRP.getInventoryItemAmount(nuser_id,v)
			if amount > 0 then
			  local item = vRP.items[v]
			  if item then

				if vRP.removeItme(nuser_id, v, amount) then
					vRPclient.notify(nplayer,{"Ti-a fost confiscat: "..item.name.." ("..amount..")"})
					vRPclient.notify(nplayer,{"Ai confiscat: "..item.name.." ("..amount..")"})
				end
			  end
			end
		end
	end)
end

local function ch_seizeweapons(player, target_src)
	local user_id = vRP.getUserId(player)
	local target_id = vRP.getUserId(target_src)

	if vRP.hasPermission(user_id, "permis.arma") then
		vRP.request(player, "Persoana caruia incerci sa ii iei armele are permis de port arma. Esti sigur?", false, function(_, ok)
			if not ok then return end
			local function continueConfiscate()
				local userWeapons = vRP.getItemsByType(target_id, "weapons")
	
				if #userWeapons < 1 then
					vRPclient.notify(player, {'Jucatorul nu are arme pe care sa le poti confisca!'})
					vRP.closeMenu(player)
					return 
				end
	
				local menu = {name = 'Confisca Armele'}
	
				for _, weapData in pairs(userWeapons) do
					menu[weapData.label]  = {function(player)
						local userInventory = vRP.getUserInventory(target_id)
	
						for slot, data in pairs(userInventory) do
							if data.item == weapData.item then
								userInventory[slot] = nil
							end
						end
	
						vRP.saveInventory(target_id)
						vRPclient.notify(target_src, {"Politistul "..GetPlayerName(player).." ti-a confiscat "..weapData.label})
						vRPclient.notify(player, {"I-ai confiscat lui "..GetPlayerName(target_src).." "..weapData.label})
						continueConfiscate()
					end, ''}
				end
			
				if #userWeapons >= 2 then
					menu['Toate Armele'] = {function(player)
						local userInventory = vRP.getUserInventory(target_id)
	
						for slot, data in pairs(userInventory) do
							if vRP.items[data.item].category == 'weapons' then
								userInventory[slot] = nil
							end
						end
						vRP.saveInventory(target_id)
					end, ''}
				end
	
				vRP.openMenu(player, menu)
			end continueConfiscate()
		end)
	else
		local function continueConfiscate()
			local userWeapons = vRP.getItemsByType(target_id, "weapons")

			if #userWeapons < 1 then
				vRPclient.notify(player, {'Jucatorul nu are arme pe care sa le poti confisca!'})
				vRP.closeMenu(player)
				return 
			end

			local menu = {name = 'Confisca Armele'}

			for _, weapData in pairs(userWeapons) do
				menu[weapData.label]  = {function(player)
					local userInventory = vRP.getUserInventory(target_id)

					for slot, data in pairs(userInventory) do
						if data.item == weapData.item then
							userInventory[slot] = nil
						end
					end

					vRP.saveInventory(target_id)
					vRPclient.notify(target_src, {"Politistul "..GetPlayerName(player).." ti-a confiscat "..weapData.label})
					vRPclient.notify(player, {"I-ai confiscat lui "..GetPlayerName(target_src).." "..weapData.label})
					continueConfiscate()
				end, ''}
			end
		
			if #userWeapons >= 2 then
				menu['Toate Armele'] = {function(player)
					local userInventory = vRP.getUserInventory(target_id)

					for slot, data in pairs(userInventory) do
						if vRP.items[data.item].category == 'weapons' then
							userInventory[slot] = nil
						end
					end
					vRP.saveInventory(target_id)
				end, ''}
			end

			vRP.openMenu(player, menu)
		end continueConfiscate()
	end
end

local function ch_givelicense(player, nplayer)
	local user_id = vRP.getUserId(player)
	local nuser_id = vRP.getUserId(nplayer)
	local tmp = vRP.getUserTmpTable(nuser_id)
	if tmp then
		if not tmp.dmvTest then

			local acc = vRP.isFactionLeader(user_id, "Politie") or vRP.isUserCoLeader(user_id, "Politie")

			if (tmp.dmvCooldown or 0) < os.time() or acc then
				if vRP.removeItem(user_id, 'dmvact') then
					vRPclient.notify(player, {"I-ai oferit permisul lui "..GetPlayerName(nplayer).."."})
					vRPclient.notify(nplayer, {"Politistul "..GetPlayerName(player).." ti-a oferit permisul de conducere."})

					if not vRP.hasItem(nuser_id, 'auto_doc') then
						vRP.giveItem(nuser_id, "auto_doc", 1, false, false, false, 'Police Officer')
					end
					vRP.updateUser(nuser_id, "dmvTest", true)

					if not exports.vrp:hasCompletedBegginerQuest(nuser_id, 2) then
						exports.vrp:completeBegginerQuest(nuser_id, 2)
					end

					exports.vrp:achieve(nuser_id, 'drivingschoolEasy', 1)
					
					TriggerClientEvent('dmv:setLicenceStatus', nplayer, true)
				else
					vRPclient.notify(player, {"Nu detii dosarul de la jucatorul de langa tine.", "error"})
				end
			else
				vRPclient.notify(player, {"Permisul este confiscat pana pe "..os.date('%d/%m/%y %H:%M', tmp.dmvCooldown)})
				vRPclient.notify(nplayer, {"Permisul iti este confiscat pana pe "..os.date('%d/%m/%y %H:%M', tmp.dmvCooldown)})
			end
		else
			vRPclient.notify(player, {"Jucatorul de langa tine are deja un permis valid."})
		end
	end
end

local function ch_seizelicense(player, nplayer)
	local user_id = vRP.getUserId(player)
	local nuser_id = vRP.getUserId(nplayer)
	local data = vRP.usersData[nuser_id] or {}

	if data.dmvTest then
		vRP.prompt(player, "Suspenda permis", "Cate zile doresti sa ii confisti permisul (max: 3)", false, function(days)
			days = tonumber(days)

			if days and days > 0 and days <= 3 then
				vRP.updateUser(nuser_id, "dmvCooldown", os.time() + (86400*days))
				vRP.updateUser(nuser_id, "dmvTest", false)

				vRP.removeItem(nuser_id, "auto_doc")

				local tmp = vRP.getUserTmpTable(nuser_id)
				vRPclient.notify(player, {"I-ai confiscat permisul lui "..GetPlayerName(nplayer).." pentru "..days.." zile"})
				vRPclient.notify(nplayer, {"Politistul "..GetPlayerName(player).." ti-a confiscat permisul de conducere pentru "..days.." zile ("..os.date('%d/%m/%y %H:%M', tmp.dmvCooldown)..")"})
			end
		end)
	else
		vRPclient.notify(player, {"Cetateanul nu poseda un permis de conducere.", "error"})
	end
end

-- vinieta --

function getVignetteForVehicle(user_id, model)
	local vehicle = vRP.getVehicleDataTable(user_id, model)
	
	if not vehicle then return false, "Undefined", "NO CA RPT" end

	if (vehicle.vignette or 0) > os.time() then
		if vehicle.vtype == "car" then
			return "skip"
		end

		return vehicle.vignette, vehicle.name, vehicle.carPlate
	end
	return false, vehicle.name, vehicle.carPlate
end

RegisterServerEvent("vignette:check", function(name)
	local player = source
	local user_id = vRP.getUserId(player)

	if not name then return end

	local owned, name, plate = getVignetteForVehicle(user_id, name)

	if not owned and not (owned == "skip") then
		if not vRP.tryFullPayment(user_id, 500, true, false, "Rovinieta") then
			return "Nu ai destui bani pentru a plati amenda."
		end

		sendPoliceBackup(player, false, {code = plate, name = os.date("%H:%M"), description = "Un autoturism marca "..name.." a traversat autostrada fara a plati taxa pentru rovinieta."})
		vRPclient.notify(player, {"Ai fost amendat cu $500 pentru ca ai traversat fara rovinieta.", "error", "Camera de viteza"})
	end
end)


local vignettePrice <const> = 500

RegisterServerEvent("vignette:buy", function(model)
	local player = source
	local user_id = vRP.getUserId(player)

	if not model then return end

	if player and user_id then
		local vehicle = vRP.getVehicleDataTable(user_id, model)
		if not vehicle then return end

		if vehicle.vignette and (vehicle.vignette > os.time()) then
			vRPclient.notify(player, {"Ai deja vinieta pe acest vehicul. Expira pe: "..os.date("%d/%m/%Y %H:%M", vehicle.vignette), "error"})
			return
		end

		if vRP.tryFullPayment(user_id, vignettePrice, true, false, "Rovinieta") then
			local expire = os.time() + daysToSeconds(30)
			vRP.setVehicleData(user_id, model, "vignette", expire)
			TriggerClientEvent("vrp-phone:notify", player, "Ai facut vinieta pentru vehiculul marca "..vehicle.name)

			exports.vrp:achieve(user_id, "RovinietaEasy", 1)
		end
	end
end)

--- ---

local function ch_policeplayer(player, near)
	local user_id = vRP.getUserId(player)
	vRP.buildActionsMenu("policeply", {user_id = user_id, player = player, near = near}, function(menu)
		menu.onclose = function(player) end

		menu['Pune in vehicul'] = {function() ch_putinveh(player, near) end, "put_in_veh.svg"}
		menu['Scoate din vehicul'] = {function() ch_ejectfromveh(player, near) end, "rem_from_veh.png"}
		menu['Confisca ilegale'] = {function() ch_seizeobjects(player, near) end, "cannabis.svg"}
		menu['Confisca armele'] = {function() ch_seizeweapons(player, near) end, "pistol.svg"}
		menu['Legitimatie'] = {function() showBadge(player, near) end, "badge.svg"}
		menu['Incatuseaza'] = {function() ch_cuffplayer(player, near) end, "hostage.png"}
		menu['Ofera permisul'] = {function() ch_givelicense(player, near) end, "driverlic.svg"}
		menu['Confisca permisul'] = {function() ch_seizelicense(player, near) end, "driverlic.svg"}
		menu['Scoate de la puscarie'] = {function() ch_unjail(player, near) end, "unjail.svg"}

		if menu then
			vRP.openActionsMenu(player,menu)
		end
	end)
end


local function ch_policemenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildActionsMenu("police", {user_id = user_id, player = player}, function(menu)
			menu.onclose = function(player) end

			menu["Apeluri"] = {ch_policecalls, "departments/calls.svg"}
			menu["Solicita intariri imediate"] = {function()
				vRPclient.executeCommand(player, {"bk3"})
			end, "departments/helpbk.svg"}
			menu["Obiecte"] = {ch_policeprops, "departments/pdprop.svg"}
			
			menu["Tableta"] = {function(player)
				vRPclient.executeCommand(player, {"mdt"})
			end, "tablet.svg"}

			local nearSomeone = promise.new()
			vRPclient.getNearestPlayer(player, {2.5}, function(player)
				if player then
					nearSomeone:resolve({player, GetPlayerName(player)})
				else
					nearSomeone:resolve({false, ""})
				end
			end)

			local near, name = table.unpack(Citizen.Await(nearSomeone))
			
			if near then
				menu[name] = {function()
					ch_policeplayer(player, near)
				end, "police.svg"}
			end
			if menu then
				vRP.openActionsMenu(player,menu)
			end
		end)
	end
end

local revive_seq = {
	{"amb@medic@standing@kneel@enter","enter",1},
	{"amb@medic@standing@kneel@idle_a","idle_a",1},
	{"amb@medic@standing@kneel@exit","exit",1}
}

local function ch_revive(player, nplayer)
	local user_id = vRP.getUserId(player)
	vRPclient.getHealth(player,{}, function(health)
        if health and health > 105 then
        	vRPclient.getHealth(nplayer,{}, function(health)
            	if health and health <= 160 then
      
                	vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
      
					if vRP.removeItem(user_id, 'medkit') then
						SetTimeout(15000, function()
							vRPclient.varyHealth(nplayer, {50}) -- heal 50
						  vRP.depositFactionBudget("Smurd", math.random(100, 150))
					  end)
					end
                else
                	vRPclient.notify(player,{"Pacientul nu are nevoie de ingrijiri medicale.", "error"})
                end
            end)
        else
        	vRPclient.notify(player,{"Nu poti da revive cat timp esti mort.", "error"})
        end
    end)
end

local function ch_medicplayer(player, near)
	local user_id = vRP.getUserId(player)
	vRP.buildActionsMenu("emergencyply", {user_id = user_id, player = player, near = near}, function(menu)
		menu.onclose = function(player) end

		menu['Reinvie'] = {function() ch_revive(player, near) end, "medicrev.svg"}
		menu['Legitimatie'] = {function() showBadge(player, near) end, "badge.svg"}

		if menu then
			vRP.openActionsMenu(player,menu)
		end
	end)
end

local function ch_medicmenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildActionsMenu("emergency", {user_id = user_id, player = player}, function(menu)
			menu.onclose = function(player) end

			menu["Apeluri"] = {ch_policecalls, "departments/calls.svg"}

			local nearSomeone = promise.new()
			vRPclient.getNearestPlayer(player, {2.5}, function(player)
				if player then
					nearSomeone:resolve({player, GetPlayerName(player)})
				else
					nearSomeone:resolve({false, ""})
				end
			end)

			local near, name = table.unpack(Citizen.Await(nearSomeone))
			
			if near then
				menu[name] = {function()
					ch_medicplayer(player, near)
				end, "ems.svg"}
			end
			if menu then
				vRP.openActionsMenu(player,menu)
			end
		end)
	end
end


local function ch_mechanicmenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildActionsMenu("mechanic", {user_id = user_id, player = player}, function(menu)
			menu.onclose = function(player) end

			menu["Apeluri"] = {ch_policecalls, "departments/calls.svg"}

			menu["Tracteaza"] = {function(player, choice)
				TriggerClientEvent("mechanic:startTow", player)
			end, "tow.svg"}

			if menu then
				vRP.openActionsMenu(player,menu)
			end
		end)
	end
end

local function ch_taximenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildActionsMenu("mechanic", {user_id = user_id, player = player}, function(menu)
			menu.onclose = function(player) end

			menu["Apeluri"] = {ch_policecalls, "departments/calls.svg"}

			if menu then
				vRP.openActionsMenu(player,menu)
			end
		end)
	end
end

RegisterServerEvent("police:trySpawnProp", function(prop)
	local player = source

	if allowedToSpawn[player] then
		prop.id = #policeObj + 1
		table.insert(policeObj, prop)

		TriggerClientEvent("police:populateProps", -1, {prop})
	end
end)

RegisterServerEvent("police:tryDespawnProp", function(propid)
	local player = source

	if allowedToSpawn[player] then
		for k,v in pairs(policeObj) do
			if v.id == propid then
				table.remove(policeObj, k)
				break
			end
		end

		TriggerClientEvent("police:deleteExistentProp", -1, propid)
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		TriggerClientEvent("police:populateProps", player, policeObj)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
	if allowedToSpawn[source] then
		allowedToSpawn[source] = nil
	end
end)

RegisterServerEvent("vrp:tryOpenDepartmentMenu")
AddEventHandler("vrp:tryOpenDepartmentMenu", function()
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		ch_policemenu(player)
	elseif vRP.isUserInFaction(user_id, "Smurd") then
		ch_medicmenu(player)
	elseif exports["vrp_jobs"]:hasJob(user_id, "Mecanic") then
		ch_mechanicmenu(player)
	elseif exports["vrp_jobs"]:hasJob(user_id, "Taximetrist") then
		ch_taximenu(player)
	end
end)

local function calculatePercentage(percentage, number)
	return math.floor((number * percentage) / 100)
end

AddEventHandler('vRP:playerSpawn', function(user_id, player, spawned, data)
	if not spawned then
		return
	end
	local paydFine = false

	local userFines = vRP.usersData[user_id].userFines or {}

	if next(userFines) then
		for id, data in pairs(userFines or {}) do

			if (data.expireDate or 0) < os.time() then
				if vRP.tryBankPayment(user_id, tonumber(data.amount) + calculatePercentage(25, tonumber(data.amount)), false, 'Expired Fine', true) then
					local inventory = vRP.getUserInventory(user_id)

					userFines[id] = nil
	
					for slot, item in pairs(inventory) do
						if item.item == 'fine' and item.extraData.key == data.key then
							inventory[slot] = nil
							break
						end
					end

					paydFine = true
				end
			end

			if paydFine then
				TriggerClientEvent("vrp-hud:hint", player, "Nu ai platit amenda asa ca ti-au fost sustrasi automat bani din cont alaturi de o taxa!", "Amenda", "fa-light fa-money-check-dollar-pen")
			end
		end

		vRP.saveInventory(user_id)
		vRP.updateUser(user_id, 'userFines', userFines)
	end
end)

local speedTickets <const> = {
	{speed = 10, amount = 300},
	{speed = 20, amount = 500},
	{speed = 30, amount = 600},
	{speed = 40, amount = 750},
	{speed = 50, amount = 1000},
	{speed = 60, amount = 1500},
	{speed = 70, amount = 2000},
}

local function genereteUniqueKey(length, user_id)
	local chars = {}
	for i = 1, length do
		chars[i] = string.char(math.random(97, 122))
	end
	return user_id..':'..table.concat(chars)
end

local vehicles = module("cfg/vehicles")
RegisterServerEvent('vrp-tickets:speedRadar', function(speed, maxSpeed, carPlate, model)
	speed = tonumber(speed)
	maxSpeed = tonumber(maxSpeed)

	local player = source
	local user_id = vRP.getUserId(player)
	local userIdentity = vRP.getIdentity(user_id)
	local name = userIdentity.firstname..' '..userIdentity.name

	if carPlate == '' or carPlate == 'ADMIN' then
		return 
	end

	local fine = 0
	for _, data in pairs(speedTickets) do
		if data.speed <= (speed - maxSpeed) then
			fine = data.amount
		end
	end

	if not vRP.usersData[user_id].userFines then
		vRP.usersData[user_id].userFines = {}
	end

	local data  = {
		player = user_id,
		expireDate = os.time() + (86400 * 7),
		type = 'radar',
		name = name,
		amount = tonumber(fine),
		reason = 'Depasirea limitei maxima de viteza cu '..(speed - maxSpeed)..' km/h',
		carPlate = carPlate,
		speed = speed..' km/h',
		model = model and vehicles[model] and vehicles[model][1] or 'Necunoscut',
		sex = userIdentity.sex == 'M' and 'Barbat' or 'Femeie',
		createdAt = os.time(),
		key = genereteUniqueKey(3, user_id)
	}

	table.insert(vRP.usersData[user_id].userFines, data)
	vRP.updateUser(user_id, 'userFines', vRP.usersData[user_id].userFines)
	exports.vrp:sendPostPackage(user_id, 'fine', 1, data)
end)

Citizen.CreateThread(function()
	vRP.defInventoryItem('fine', 'Amenda', 'O amenda pe care trebuie sa o platesti inainte sa expire!', function(player, slot)
		local user_id = vRP.getUserId(player)
		local inventory = vRP.getUserInventory(user_id)
		if inventory[slot] and inventory[slot].item == 'fine' then
			TriggerClientEvent("vrp:sendNuiMessage", player, {
				interface = 'fine',
				data = inventory[slot].extraData
			})
		end
	end, 0.01, 'fine', true)
end)


function vRP.giveUserFine(player, user_id, data)
	if not vRP.usersData[user_id].userFines then
		vRP.usersData[user_id].userFines = {}
	end
	
	data.key = genereteUniqueKey(3, user_id)

	table.insert(vRP.usersData[user_id].userFines, data)
	vRP.giveItem(user_id, 'fine', 1, false, data, false, false, 'Police Officer')
	vRP.updateUser(user_id, 'userFines', vRP.usersData[user_id].userFines)
end

registerCallback("getPermisArma", function(player)
	local user_id = vRP.getUserId(player)
	local reply = promise.new()
	if vRP.hasPermission(user_id, "permis.arma") then
		vRP.giveItem(user_id, "permisarma", 1, false, false, false, true, "Police Officer")
		reply:resolve{false, true}
	else
		reply:resolve("Nu ai permisul de port arma.")
	end

	return Citizen.Await(reply)
end)

registerCallback('payFines', function(player)
	local user_id = vRP.getUserId(player)
	local userFines = vRP.usersData[user_id].userFines
	local choices = {}

	for _, data in pairs(userFines or {}) do
		table.insert(choices, {'Amenda - '..data.amount..'$', {type = 'fine', key = data.key, amount = data.amount, createdAt = data.createdAt}})
	end

	if #choices == 0 then
		return 'Nu ai nici o amenda. Te pot ajuta cu altceva?'
	end

	table.insert(choices, {'Plateste toate amenzile.', {type = 'all'}})

	local reply = promise.new()
	vRP.selectorMenu(player, 'Plateste Amenzi', choices, function(fine)

		if not fine then 
			return reply:resolve('Nu ai selectat o amenda. Te pot ajuta cu altceva?')
		end;

		if fine.type == 'all' then
			local finesPayed = 0

			for index, fine in pairs(userFines) do
				if vRP.tryBankPayment(user_id, fine.amount) then
					local inventory = vRP.getUserInventory(user_id)

					for slot, data in pairs(inventory) do
						if data.item == 'fine' and data.extraData.key == fine.key then
							inventory[slot] = nil
							break
						end
					end

					userFines[index] = nil
					finesPayed += 1

					exports.vrp:achieve(user_id, 'amendaEasy', 1)
				end
			end

			if finesPayed >= 1 then
			    reply:resolve('Ai platit '..finesPayed..' amenzi cu succes. Te pot ajuta cu altceva?')
			end
		else
		    if vRP.tryBankPayment(user_id, tonumber(fine.amount)) then
		    	local inventory = vRP.getUserInventory(user_id)
		    	
		    	exports.vrp:achieve(user_id, 'amendaEasy', 1)
    
		    	for id, data in pairs(userFines) do
		    		if data.key == fine.key and data.player == user_id then
		    			userFines[id] = nil
		    			break
		    		end
		    	end
    
		    	for slot, item in pairs(inventory) do
		    		if item.item == 'fine' and item.extraData.key == fine.key then
		    			inventory[slot] = nil
		    			break
		    		end
		    	end
    
		    	reply:resolve('Ai platit amenda cu succes. Te pot ajuta cu altceva?')
		    end
		end

		reply:resolve('Nu ai destui bani pentru a plati amenda. Te pot ajuta cu altceva?')
	end, true)

	return Citizen.Await(reply)
end)