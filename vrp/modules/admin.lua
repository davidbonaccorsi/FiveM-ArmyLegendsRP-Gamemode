local adminsDuty = {}

local activeLogs, blipsActive = {}, {}


function vRP.isAdminDuty(user_id)
	if adminsDuty[user_id] then
		return true
	end
	return false
end


function vRP.getUserAdminLevel(user_id)
	if not vRP.isAdminDuty(user_id) then return 0 end

	local tmp = vRP.usersData[user_id]
	local adminLevel = 0
	if tmp then
		adminLevel = tmp.adminLvl
	end
	return adminLevel or 0
end

function vRP.isAdmin(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if (adminLevel > 0) then
		return true
	else
		return false
	end
end

--[[
	Admin Levels
	1, 2, 3: Admin Team
	4: Administrator
	5: Owner
]]

function tvRP.getUserAdminLevel()
	local player = source
	local user_id = vRP.getUserId(player)
	
	return vRP.getUserAdminLevel(user_id)
end

function vRP.getTrueAdminLevel(user_id)
	local tmp = vRP.usersData[user_id]
	local adminLevel = 0
	if tmp then
		adminLevel = tmp.adminLvl
	end
	return adminLevel or 0
end


function vRP.setUserAdminLevel(user_id, admin)
	local source = vRP.getUserSource(user_id)
	
	vRP.updateUser(user_id, 'adminLvl', admin)

	if admin > 0 and source then
		staffUsers[user_id] = {lvl = admin, src = source}
	elseif staffUsers[user_id] then
		staffUsers[user_id] = nil
	end
end

function vRP.getUserAdminTitle(user_id)
	local adminLvl = vRP.getUserAdminLevel(user_id)
	local titles = {'Trial Helper', 'Helper', 'Moderator', 'Administrator', 'Supervizor', 'Manager', 'Fondator'}

	return titles[adminLvl] or "No title"
end

function vRP.getColoredAdminTitle(adminLvl)
	local titles = {'#{808080}Trial Helper', '#{8200ff}Helper', '#{0000ff}Moderator', '#{008000}Administrator', '#{ffff00}Supervizor', '#{ffa500}Manager', '#{c25050}Fondator'}
	return titles[adminLvl] or "No title"
end

function vRP.countOnlineStaff()
    return table.len(vRP.getStaffUsers())
end

function vRP.doStaffFunction(minAdminLvl, cb, duty)
	local minAdminLvl = minAdminLvl or 1
    local users = vRP.getStaffUsers()

    for user_id, data in pairs(users) do
        if (not duty or vRP.isAdminDuty(user_id)) and data.lvl >= minAdminLvl then
            cb(data.src)
        end
    end
end

function vRP.sendStaffMessage(msg, msgType, minLvl)
	local staffUsers = vRP.getStaffUsers()

	if not minLvl or type(msgType) == "number" then
		minLvl = msgType or 1
	end

	for uid, val in pairs(staffUsers) do
		if vRP.getUserAdminLevel(uid) >= minLvl then
			TriggerClientEvent("chatMessage", val.src, msg, type(msgType) == "string" and msgType or "msg")
		end
	end
end

exports("sendStaffMessage", vRP.sendStaffMessage)

RegisterCommand("status", function(source)
	if source == 0 then
		local users = vRP.getUsers()

		print("Pe server sunt in total " .. table.len(users) .. " (de) jucatori conectati")
		print("---------------")
		print("ID   Source   Nume   Adresa IP")

		for user_id, player in pairs(users) do
			local pName = GetPlayerName(player) or "Username"
			local pEndPoint = GetPlayerEndpoint(player) or "0.0.0.0"
			print(user_id .. "   " .. player .. "   " .. pName .. "   " .. pEndPoint)
		end

		print("---------------")
	else
		vRPclient.noAccess(source)
	end
end)

function tryNoclipToggle(src)
	local src = src or source
    local user_id = vRP.getUserId(src)
    
    if vRP.getUserAdminLevel(user_id) >= 1 then
        vRPclient.toggleNoclip(src, {})
    end
end
tvRP.tryNoclipToggle = tryNoclipToggle


local canUseWeapons = true
local function ch_toggleWeaps(player, choice)
	canUseWeapons = not canUseWeapons
	vRPclient.toggleAllWeapons(-1, {canUseWeapons})
end

AddEventHandler('txAdmin:events:announcement', function(eventData)
    if eventData.message then
        Citizen.CreateThread(function()
			TriggerClientEvent("adminMessage", -1, eventData.author, eventData.message)
        end)
    end
end)

local function ch_giveitem(player)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then

		vRP.prompt(player, "GIVE ITEM", "Introdu in caseta de mai jos utilizatorul selectat apoi apasa pe butonul de confirmare.", false, function(target_id)
			target_id = tonumber(target_id)

			if target_id then
				vRP.prompt(player, "GIVE ITEM", "Introdu in caseta de mai jos itemul oferit apoi apasa pe butonul de confirmare.", false, function(idname)
					if idname then
						vRP.prompt(player, "GIVE ITEM", "Introdu in caseta de mai jos cantitatea oferita apoi apasa pe butonul de confirmare.", 1, function(amount)
							amount = tonumber(amount)

							if amount and amount > 0 then

								local target_src = vRP.getUserSource(target_id)
								if target_src then
									vRP.giveItem(target_id, idname, amount, false, false, false, 'Admin Give')
									local itemName = vRP.getItemName(idname)
									vRP.createLog(user_id, {item = idname, amount = amount, item_name = itemName, to = target_id}, "AdminGiveItem")
					
									if target_id ~= user_id then
										vRPclient.notify(player, {idname.." ("..amount..") a fost adaugat in invetar la ID-ul "..target_id.." (online)", "info"})
									end
								else -- offline
									vRPclient.notify(player, {"Jucatorul nu este conectat.", "error"})
									-- exports.mongodb:findOne({collection = "users", query = {id = target_id}, options = {projection = {_id = 0, inventory = 1}}}, function(success, result)
									-- 	if result[1] then
									-- 		local inventory = result[1].inventory or {}
														
									-- 		if inventory[idname] then
									-- 			inventory[idname].amount = (inventory[idname].amount or 0) + amount
									-- 		else
									-- 			local itemLabel, itemDesc, itemWeight, _ = vRP.getItemDefinition(idname)
									-- 			if itemLabel then
									-- 				inventory[idname] = {
									-- 					amount = amount,
									-- 					label = itemLabel,
									-- 					description = ((itemDesc or ""):len() > 2 and itemDesc) or "Acest item nu detine o descriere",
									-- 					weight = (itemWeight > 0 and itemWeight) or 0.00,
									-- 				}
									-- 			end
									-- 		end
											
									-- 		exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {['$set'] = {
									-- 			inventory = inventory
									-- 		}}})
									-- 		local itemName = vRP.getItemName(idname)
									-- 		vRP.createLog(target_id, {item = idname, amount = amount, item_name = itemName, from = "Admin Give (ID "..user_id..")"}, "ReceiveItem")
									-- 		vRP.createLog(user_id, {item = idname, amount = amount, item_name = itemName, to = target_id}, "AdminGiveItem")
									-- 		vRPclient.notify(player, {idname.." ("..amount..") a fost adaugat in invetar la ID-ul "..target_id.." (offline)", "info"})
									-- 	end
									-- end)
								end
							end
						end)
					end
				end)
			end
		end)
	end
end

local function ch_addgroup(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Add Group","ID: ",false,function(id)
			id = tonumber(id)
			if id then
				vRP.prompt(player,"Add Group","Ce group sa fie adaugat: ",false,function(group)
					if group then

						local target_src = vRP.getUserSource(id)
						if target_src then
							vRP.addUserGroup(id,group)
							vRPclient.notify(player, {group.." a fost adaugat la ID-ul "..id.." (online)"})
						else -- offline

							vRPclient.notify(player, {group.." a fost adaugat la ID-ul "..id.." (offline)"})

						end

						exports.mongodb:updateOne({collection = "users", query = {id = id}, update = {
							["$set"] = {
								["userGrades."..group] = {grade = group, time = os.time()}
							}
						}})
					end
				end)
			end
		end)
	end
end

local function ch_removegroup(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Remove Group","ID: ",false,function(id)
			id = tonumber(id)
			if id then
				vRP.prompt(player,"Remove Group","Ce group sa fie scos: ",false,function(group)
					if group then

						local target_src = vRP.getUserSource(id)

						if target_src then

							vRP.removeUserGroup(id,group)
							vRPclient.notify(player,{group.." a fost scos de la ID-ul "..id})
						else -- offline

							vRPclient.notify(player, {group.." a fost scos de la ID-ul "..id.." (offline)"})

						end

						exports.mongodb:updateOne({collection = "users", query = {id = id}, update = {
							["$unset"] = {["userGrades."..group] = 1}
						}})
					end
				end)
			end
		end)
	end
end

local function ch_kick(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Kick","Scrie in caseta ID-ul jucatorului si apasa butonul de confirmare.",false,function(id)
			id = tonumber(id)
			if id then
				vRP.prompt(player,"Kick","Scrie in caseta motivul si apasa butonul de confirmare.",false,function(reason)
					if reason then
						local source = vRP.getUserSource(id)
						if source ~= nil then
							vRPclient.msg(-1, {{"Kick", "Adminul "..GetPlayerName(player).." l-a dat afara pe "..GetPlayerName(source), "Motivul sanctiunii: "..reason}, "info"})

							vRP.kick(source,reason)
						end
					end
				end)
			end
		end)
	end
end

local function ch_resetIdentity(player)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Reset Identity", "Scrie in caseta ID-ul jucatorului si apasa butonul de confirmare.", false, function(target)
			local target_id = tonumber(target)

			if target_id then
				vRPclient.executeCommand(player, {"resetcharacter "..target_id})
			end
			vRP.closeMenu(player)
		end)
	end
end

local function ch_ban(player)
	vRP.prompt(player, "Ban Player", "Introdu in caseta de mai jos utilizatorul selectat apoi apasa pe butonul de confirmare.", false, function(target_id)
		target_id = tonumber(target_id)

		if target_id then
			vRP.prompt(player, "Ban Player", "Introdu in caseta de mai jos durata banului apoi apasa pe butonul de confirmare.<br/><br/>Pentru a bana permanent jucatorul scrie 0 in caseta de raspuns.", false, function(durata)
				durata = tonumber(durata)
		
				if durata then
					vRP.prompt(player, "Ban Player", "Introdu in caseta de mai jos motivul banului apoi apasa pe butonul de confirmare.", false, function(motiv)		
						if motiv then
							vRP.selectorMenu(player, 'Drept de plata', {{'Da', true}, {'Nu', false}}, function(drept)
								if drept ~= nil then
									vRP.selectorMenu(player, 'Esti sigur ca vrei sa il banezi pe ID: '..target_id, {{'Da', true}, {'Nu', false}}, function(sure)
										if not sure then return vRPclient.notify(player, {"Ai anulat actiunea."}) end
										local adminId = vRP.getUserId(player)
										
										if target_id == 1 or target_id == 2 or target_id == 3 or target_id == 4 then
											vRP.ban(adminId, "Ai incercat sa banez unul dintre id-urile 1,2,3,4. Aleluia ai luat muia :)", player, 0, false)
											return
										end

										if(durata > 0)then
											exports.mongodb:insertOne({collection = "punishLogs", document = {
												user_id = tonumber(target_id),
												time = os.time(),
												type = "ban",
												text = "A primit Ban Temporar timp de "..durata.." zile de la "..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv
											}})
										else
											exports.mongodb:insertOne({collection = "punishLogs", document = {
												user_id = tonumber(target_id),
												time = os.time(),
												type = "banPermanent",
												text = "A primit Ban Permanent de la "..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv
											}})
										end

										vRP.ban(target_id,motiv,player,durata,drept)

										vRP.addRaport(adminId, "bans")

										local target_src = vRP.getUserSource(target_id)
										local name = "ID "..target_id
									
										if target_src then
											name = GetPlayerName(target_src)
										end
									
										vRPclient.sendInfo(-1, {"^5"..GetPlayerName(player).."^7 i-a dat ban ^5"..((durata or 0) > 0 and ""..durata.." zile" or "permanent").."^7 lui ^5"..name.." ^7("..(not drept and "fara" or "cu").." drept de plata)"})
										vRPclient.msg(-1, {"^5Motiv^7: "..motiv})
									end)
								end	
							end)
						end
					end)
				end
			end)
		end
	end)
end

local function ch_coords(player)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) > 1 then
      	vRPclient.getPosition(player,{},function(x,y,z)
			vRP.prompt(player,"Coords","Pentru a copia coordonatele foloseste tastele CTRL-A pentru a selecta textul apoi apasa CTRL-C pentru a-l copia", (x..","..y..","..z), function(choice) end)
      	end)
	end
end

local function ch_tptocoords(player,choice)
	vRP.prompt(player,"Teleport To Coords", "Coordonate (x,y,z):", false, function(coords)
		if coords then
			local x, y, z = table.unpack(splitString(coords, ','))

			vRPclient.teleport(player, {parseFloat(x), parseFloat(y), parseFloat(z)})
		end
	end)
end

local function ch_givemoney(player)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Give Money", "Scrie in caseta suma si apasa butonul de confirmare.", false, function(amount)
			amount = tonumber(amount)

			if amount then
				vRP.giveMoney(user_id, amount, "Admin")
				vRP.createLog(user_id, {name = GetPlayerName(player), text = "A oferit $"..vRP.formatMoney(amount).." lui ID "..user_id, action = "Give Money"}, "AdminAction")
			end
		end)
	end
end

local premiiev = {
	100000, --locul I
	50000, --locul II
	30000  --locul III
}
local coolDownOre = 20

local function ch_evMoney(player, choice)
	local user_id = vRP.getUserId(player)
	local positions = {}
	
	if vRP.hasGroup(user_id, "event") or vRP.getUserAdminLevel(user_id) >= 5 then
		vRP.getUData(user_id, "eventMoney", function(time)
			local theTime = tonumber(time) or 0
			if theTime <= os.time() then
				vRP.prompt(player, "Event Money", "ID Locul 1:", false, function(loc1)
					loc1 = tonumber(loc1)
					if loc1 then
						table.insert(positions, {id = loc1, place = 1})
						vRP.prompt(player, "Event Money", "ID Locul 2", false, function(loc2)
							loc2 = tonumber(loc2)
							if loc2 then
								table.insert(positions, {id = loc2, place = 2})
							end

							vRP.prompt(player, "Event Money", "ID Locul 3", false, function(loc3)
								loc3 = tonumber(loc3)
								if loc3 then
									table.insert(positions, {id = loc3, place = 3})
								end

								if next(positions) then
									for k, data in pairs(positions) do
										local source = vRP.getUserSource(data.id)
										
										if source then
											TriggerClientEvent("chatMessage", -1, "^9Event: ^7Felicitari lui ^9"..GetPlayerName(source).."^7 fiindca a ajuns locul "..data.place.." la eveniment!")
											vRP.giveMoney(data.id, premiiev[data.place], "Event Money")
										else
											vRPclient.notify(player, {"Locul "..data.place.." nu este online."})
										end
									end
								end

								local nextCooldown = os.time() + (coolDownOre*3600)
								vRP.setUData(user_id, "eventMoney", tostring(nextCooldown))

								vRPclient.notify(player, {"Urmatorul cooldown: "..os.date("%d %b, %H:%M", nextCooldown)})
							end)
						end)
					end
				end)
			else
				vRPclient.notify(player, {"Ai cooldown pana "..os.date("%d %b, %H:%M", theTime), "error"})
			end
		end)
	end
end

function vRP.addRaport(user_id, raport_type, many)
	exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {_id = 0, userRaport = 1}}}, function(success, result)
		local raport = result[1].userRaport or {}
		raport[raport_type] = (raport[raport_type] or 0) + (many or 1)

		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
			['$set'] = {
				["userRaport."..raport_type] = raport[raport_type]
			}
		}})
	end)
end

-- Admin Tickets ---
local adminCalls = {}
local lastTk = {}

local function updateTickets()
	for ticketId, ticketData in pairs(adminCalls) do
		if ticketData.expire <= os.time() then
			adminCalls[ticketId] = nil

			vRPclient.notify(ticketData.player, {"Ticketul tau a expirat, in cazul in care mai ai nevoie de ajutor, poti face un alt ticket!", "warning", false, "fas fa-ticket"})
		end
	end

	SetTimeout(60000, updateTickets)
end updateTickets()

RegisterServerEvent("vrp-admin:answerTicket", function(ticket)
	local player = source
	local user_id = vRP.getUserId(player)

	local ticketData = adminCalls[ticket]
	if vRP.getUserAdminLevel(user_id) < 1  then
		return vRPclient.denyAcces(player, {})
	end
	
	local user = vRP.getUser(user_id) or {}

	if ticketData then
		adminCalls[ticket] = nil

		local adminUsername = GetPlayerName(player)
		local targetSrc = ticketData.player
		vRP.addRaport(user_id, "tickets")

		vRPclient.getPosition(targetSrc, {}, function(x, y, z)
			vRPclient.teleport(player, {x, y, z})
			vRPclient.notify(targetSrc, {adminUsername.." ti-a preluat ticketul, explica-i problema intampinata!", "info", false, "fas fa-ticket"})
			vRP.sendStaffMessage("^5TK^7: ^5"..adminUsername.." ["..user_id.."]^7 i-a preluat ticketul lui ^5"..ticketData.name.." ("..ticket..")")

			local userWorld = GetPlayerRoutingBucket(targetSrc)
        	SetPlayerRoutingBucket(player, userWorld)

        	lastTk[user_id] = ticket
		end)
		
		user.paydayTk = (user.paydayTk or 0) + 1
	end
end)

RegisterServerEvent("vrp-admin:skipTicket", function(ticketId)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) < 1 then
		return vRPclient.denyAcces(source, {})
	end

	vRP.prompt(player, "ADMIN TICKETS", "Introdu in caseta de mai jos <span style='color: var(--prompt-yellow);'>motivul skipului</span> apoi apasa pe butonul de confirmare.", false, function(reason)
		if reason then

			if adminCalls[ticketId] then
				local name = adminCalls[ticketId].name

				adminCalls[ticketId] = nil

				vRP.sendStaffMessage("^3TK: ^3"..GetPlayerName(player).."["..user_id.."]^7 i-a inchis ticketul lui "..name.." - "..reason)

				local hook = "https://discord.com/api/webhooks/1227247517251534918/4Fn7ffDzPLNlFTu8mxlvJ0RD7ct3pM9Q99hQwaHB9onRst1iLNfCkhieA1UU0ReKZCcE"             

				-- PerformHttpRequest(hook, function(err, text, headers) end, 'POST', json.encode({
                --     embeds = {{
                --         description = "Admin "..GetPlayerName(player).." ("..user_id..") has just skipped the ticket of "..name.." ("..ticketId..")\nReason of skipping: "..reason.."\n\n"..os.date("%d.%m.%Y %H:%M"),
                --         color = 0xffe813,
                --     }}

                -- }), {['Content-Type'] = 'application/json'})

			end		
		end
	end, true)
end)

local ticketCooldown = {}
local function ch_calladmin(source)
	local user_id = vRP.getUserId(source)

	if ticketCooldown[user_id] and ticketCooldown[user_id] > os.time() then
		vRPclient.notify(player, {"Trebuie sa mai astepti "..(ticketCooldown[user_id] - os.time()).." (de) secunde pentru a face un alt ticket!", "error"})
	else

		if not adminCalls[user_id] then
			TriggerClientEvent('vrp:sendNuiMessage', source, {
				interface = 'adminTickets',
				event = 'createTicket',
			})
			vRP.closeMenu(source)
		elseif adminCalls[user_id].expire <= os.time() then
			adminCalls[user_id] = nil
			
			Citizen.CreateThread(function()
				Citizen.Wait(200)
				ch_calladmin(source)
			end)
		else
			vRPclient.notify(source, {"Ai un ticket activ, trebuie sa mai astepti "..(adminCalls[user_id].expire - os.time()).." (de) secunde pentru a face un alt ticket!", "error"})
		end
	end
end

RegisterServerEvent("vrp-admin:sendTicket", function(ticketData)
	local player = source
	local user_id = vRP.getUserId(player)

	if not adminCalls[user_id] then

		adminCalls[user_id] = {
			expire = os.time() + 120,
			name = GetPlayerName(player),
			player = player,
			subject = ticketData[1],
			description = ticketData[2],
		}

		vRP.doStaffFunction(1, function(staff)
			TriggerClientEvent("vrp:sendNuiMessage", staff, {interface = "adminTickets", event = "newTicketAlert"})
		end, true)
	end
end)

RegisterCommand("canceltk", function(source)
	local user_id = vRP.getUserId(source)

	if adminCalls[user_id] then
		adminCalls[user_id] = nil

		vRPclient.notify(source, {"Ai anulat ticketul!", "info", false, "fas fa-ticket"})
	end
end)

RegisterCommand("tk", function(player, args)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) < 1 then
		return vRPclient.denyAcces(player, {})
	end

	local tbl = {}
	for uid, data in pairs(adminCalls or {}) do
	  	data.id = uid
	  	table.insert(tbl, data)
	end

	TriggerClientEvent('vrp:sendNuiMessage', player, {
		interface = 'adminTickets',
		event = 'ticketsList',
		data = {
			tickets = tbl,
			admin = true,
		}
	})
end)

RegisterCommand("lasttk", function(player)
	local user_id = vRP.getUserId(player)
	local targetId = lastTk[user_id]

	if vRP.getUserAdminLevel(user_id) < 1 then
		return vRPclient.denyAcces(player)
	end

	if targetId then
		local uSrc = vRP.getUserSource(targetId)
		if uSrc then

			vRPclient.getPosition(uSrc, {}, function(x, y, z)
				local userWorld = GetPlayerRoutingBucket(uSrc)
        		SetPlayerRoutingBucket(player, userWorld)
        		vRPclient.teleport(player, {x, y, z})

        		vRPclient.msg(player, {"^5Tickets: ^7Te-ai intors la ultimul ticket facut de ^5"..GetPlayerName(uSrc).." ^7[^5"..targetId.."^7]."})
			end)
		else
			lastTk[user_id] = nil
			vRPclient.msg(player, {"^1Tickets: ^7Jucatorul caruia i-ai preluat ultimul ticket s-a deconectat."})
		end
	else
		vRPclient.msg(player, {"^1Tickets: ^7Niciun jucator caruia i-ai preluat ticketul."})
	end
end)

------

local function ch_noclip(player)
	tryNoclipToggle(player)
end

local function ch_openTunningMenu(player)
	TriggerClientEvent('vrp-customs:openAdmin', player)
	vRP.closeMenu(player)
end

--[[local function ch_createMarket(player)
	local user_id = vRP.getUserId(player)
	vRP.prompt(player, "CREATE MARKET", "Introdu in caseta de mai jos tipul magazinului pe care vrei sa il creezi apoi apasa pe butonul de confirmare.", false, function(gtype)
		if gtype then
			vRPclient.getPosition(player, {}, function(x,y, z)
				vRP.createMarket(player, x, y, z, gtype)
			end)
		end
	end)
end]]

local function ch_addAdmin(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"Add Admin", "Scrie in caseta ID-ul jucatorului apoi apasa butonul de confirmare.",false,function(id) 
			id = tonumber(id)
			local target = vRP.getUserSource(id)
			if id then

				if(target)then
					vRP.prompt(player,"Add Admin", "Scrie in caseta nivelul de admin si apasa butonul de confirmare.",false,function(rank) 
						rank = tonumber(rank)
						if(tonumber(rank))then
							if(rank <= 3) and (0 < rank)then
								vRP.setUserAdminLevel(id,rank)
								Wait(100)
								vRPclient.notify(player,{"L-ai promovat pe "..GetPlayerName(target).." la "..vRP.getUserAdminTitle(id).."!"})
								vRPclient.notify(target,{"Ai fost promovat la "..vRP.getUserAdminTitle(id).." de catre "..GetPlayerName(player)})
								vRP.createLog(user_id, {target = id, targetName = GetPlayerName(target), promovarela = vRP.getUserAdminTitle(id), dela = user_id, delanume = GetPlayerName(player)}, "Add Admin Logs")
							elseif(rank == 0)then
								vRP.setUserAdminLevel(id,rank)
								vRPclient.notify(target,{"Admin-ul ti-a fost scos de catre "..GetPlayerName(player)})
								vRPclient.notify(player,{"Ai scos admin-ul jucatorului "..GetPlayerName(target)})
								vRP.createLog(user_id, {target = id, targetName = GetPlayerName(target), dela = user_id, delanume = GetPlayerName(player)}, "Remove Admin Logs")
							end
						end
					end)
				else
					vRPclient.notify(player, {"Playerul nu este conectat.", "error"})
				end
			end
		end)
	end
end

local function ch_ann(player)
	local user_id = vRP.getUserId(player)
	vRP.prompt(player,"Anunt Admin", "Scrie anuntul apoi apasa butonul de confirmare.", false, function(msg)
		if msg then
			TriggerClientEvent("adminMessage", -1, GetPlayerName(player), msg)
		end
	end)
end

local function ch_givevip(player)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Give Vip", "Scrie in caseta ID-ul jucatorului apoi apasa butonul de confirmare.", false, function(id)
			id = tonumber(id)

			if id then
				vRP.prompt(player, "Give Vip", "Scrie in caseta nivelul VIP apoi apasa butonul de confirmare.", false, function(vip)
					vip = tonumber(vip)
					
					if vip then
						local target = vRP.getUserSource(id)
						if target then
							local name = GetPlayerName(target)

							if (vip > 0) then
								local expireTime = os.time() + daysToSeconds(30)
								local theGrade, vipLvl = "vip:"..vip, vip
				
								vRP.setUserVip(id, tonumber(vipLvl))
								vRP.updateUser(id, 'userVip', {
									expireTime = expireTime,
									vip = tonumber(vipLvl),
								})
								
								vRP.createLog(user_id, {where = name.."["..id.."]", amount = vipLvl, from = GetPlayerName(player).."["..user_id.."]"}, "Add vip")

								local vipTitle = vRP.getUserVipTitle(id)
								vRPclient.notify(player, {"I-ai dat "..vipTitle.." lui "..name.." pentru 30 de zile"})
								vRPclient.notify(target, {"Ai primit "..vipTitle.." pentru 30 de zile"})
							else
								vRP.setUserVip(id, 0)
								vRP.updateUser(id, "userVip", false)

								vRP.createLog(user_id, {where = name.."["..id.."]", amount = "Remove", from = GetPlayerName(player).."["..user_id.."]"}, "Remove vip")

								vRPclient.notify(player, {"I-ai scos VIP-ul lui "..name.."."})
								vRPclient.notify(target, {"VIP-ul ti-a fost scos.", "warning"})
							end
						else
							vRPclient.notify(player, {"Playerul nu este conectat.", "error"})
						end
					end
				end)
			end
		end)
	end
end

local function ch_adminJail(player)
	vRP.prompt(player, "Admin Jail", "Scrie in caseta ID-ul jucatorului apoi apasa butonul de confirmare.", false, function(target_id)
		target_id = tonumber(target_id)
		if target_id then
			vRP.prompt(player, "Admin Jail", "Scrie numarul de checkpointuri apoi apasa pe butonul de confirmare.", false, function(cps)
				cps = tonumber(cps)
				if cps and cps > 0 then
					vRP.prompt(player, "Admin Jail", "Introdu in caseta de mai jos motivul sanctiunii apoi apasa pe butonul de confirmare.", false, function(motiv)				
						if motiv then
							local adminId = vRP.getUserId(player)
							local ok = vRP.setInAdminJail(target_id, cps, GetPlayerName(player), motiv)
							if ok == 2 or ok == 3 then

								vRPclient.sendInfo(-1, {"^5"..GetPlayerName(player).."^7 i-a dat lui ^5"..(vRP.getUserSource(target_id) and GetPlayerName(vRP.getUserSource(target_id)) or "").." ^7[^5"..target_id.."^7] "..cps.." (de) jail checkpoint-uri"})
								vRPclient.msg(-1, {"^5Motiv: ^7"..motiv})

								vRP.addRaport(adminId, "jail")
								vRPclient.notify(player, {"L-ai trimis la Admin Jail "..cps.." (de) checkpoint-uri."})
								exports.mongodb:insertOne({collection = "punishLogs", document = {
									user_id = tonumber(target_id),
									time = os.time(),
									type = "jail",
									text = "A primit Admin Jail "..cps.."CP de la "..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv
								}})
							elseif ok == 1 then
								vRPclient.notify(player, {"Checkpointurile trebuie sa fie intre 0 si 600.", "error"})
							elseif ok == 4 then
								vRPclient.notify(player, {"Playerul este deja in jail.", "error"})
							end
						end
					end)
				end
			end)
		end
	end)
end

local function ch_adminUnJail(player)
	vRP.prompt(player, "Admin UnJail", "Scrie in caseta ID-ul jucatorului apoi apsa butonul de confirmare.", false, function(target)
		local target_id = tonumber(target)

		if target_id then
			vRPclient.notify(player, {"I-ai scos jailul cu succes.", "success"})
			local user_id = vRP.getUserId(player)
			vRP.createLog(user_id, {name = GetPlayerName(player), text = "Unjailed player with ID "..target_id, action = "Unjail"}, "AdminAction")
			vRPclient.sendInfo(-1, {"^5"..GetPlayerName(player).."^7 i-a dat unjail lui id ^5"..target_id})
			vRP.removeAdminJail(target_id)
		end
	end)
end


local jobs = {
	-- {job, pos, legal}

	{"Taietor de iarba", {-1051.0393066406,6.0683135986328,50.631088256836}, true},
	{"Constructor", {-848.66363525391,-799.65399169922,19.383190155029}, true},
	{"Pilot Los Santos", {-1173.1021728516,-2681.1352539063,19.837062835693}, true},
	{"Pilot Cayo Perico", {4427.7822265625,-4451.53125,7.2367177009583}, true},
	{"Pilot Grapeseed", {2139.9816894531,4788.71484375,40.970268249512}, true},
	{"Culegator de portocale", {2031.8414306641,4732.9262695312,41.615966796875}, true},
	{"Sofer de autobuz", {454.33969116211,-600.66027832031,28.569381713867}, true},
	{"Pescar", {-1514.3322753906, 1512.4349365234, 115.28856658936}, true},
	{"Curatator de strazi", {1070.5645751953,-780.34704589844,58.33911895752}, true},
	{"Mecanic", {-1602.8032226562,-832.99890136719,10.074475288391}, true},
	{"Taxi", {895.46307373047,-179.29476928711, 74.70036315918}, true},
	{"Vanator", {-677.31420898438,5825.65625,17.331727981567}, true},
	{"Furnizor de stocuri", {846.9814453125,-902.86309814453,25.251491546631}, true},

	-- {"Traficant de iarba", {1591.8784179688,3584.5717773438,38.766506195068}, false},
	-- {"Traficant de PCP", {3311.2775878906,5176.1411132812,19.61457824707}, false},
	-- {"Hacker", {1272.2534179688,-1712.0582275391,54.771514892578}, false},
	-- {"Traficant de opium", {3726.7416992188,4541.5727539062,21.404193878174}, false},
	-- {"Cercetator maritim", {3063.2646484375,2219.7868652344,3.0527558326721}, false},
}

local submenus = {
	-- [job] = {name, coords}
	["Traficant de PCP"] = {
		{"Chemist", {1391.9638671875,3605.6708984375,38.941940307617}},
		{"Combining", {1390.0197753906,3608.7841796875,38.941886901855}}
	},
	["Hacker"] = {
		-- added via export addTpToJobSubch: vrp_jobs/sv_hacker.lua
	},
	["Traficant de opium"] = {
		{"Island", {3489.6767578125,2573.9060058594,15.606701850891}},
		{"Wagon 1", {2641.0319824219,1349.7413330078,26.184257507324}},
		{"Wagon 2", {2865.0251464844,4904.0590820312,63.437152862549}},
	},
	["Cercetator maritim"] = {
		{"Bench", {4819.296875,-4306.6137695312,5.3888082504272}},
		{"Search area middle", {3242.2421875,-662.01153564453,-142.24685668945}},
	}
}

exports("addTpToJobSubch", function(job, choice)
	if not submenus[job] then
		print("[vRP] No submenu found for job "..job)
		return
	end
	
	table.insert(submenus[job], choice)
end)

local function ch_tptojob(player,choice)
	local menu = {name = "Teleport to job"}

	local legal = '<span style="color: lightgreen">Legal</span>'
	local illegal = '<span style="color: red">Ilegal</span>'

	for k, v in pairs(jobs) do
		menu[v[1]] = {function(player)
			vRPclient.teleport(player, v[2])

			if submenus[v[1]] then
				local submenu = {name = v[1]}

				submenu.onclose = function(player)
					vRP.openMenu(player, menu)
				end

				for k, v in pairs(submenus[v[1]]) do
					submenu[v[1]] = {function(player)
						vRPclient.teleport(player, v[2])
					end, '<i class="fa-duotone fa-location-dot"></i>'}
				end

				vRP.openMenu(player, submenu)
			end

		end, "<i class='fas fa-chevron-right'></i>", 'Tip job: '..(v[3] and legal or illegal)}
	end

	vRP.openMenu(player, menu)
end

local function ch_giveweaponspack(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player, "Weapons Pack", "Factiune:", false, function(name)
			if not name then return end

			vRP.prompt(player, "Weapons Pack", "Ce faci? (1 = adauga, 0 = scoate):", false, function(add)
				add = tonumber(add)
				
				if add then

					local faction = vRP.getFaction(name)
					if faction then
						faction.weapons = add > 0
				
						exports.mongodb:updateOne({collection = "factions", query = {name = name}, update = {
							["$set"] = {weapons = faction.weapons}
						}})

						if faction.weapons then
							vRPclient.notify(player, {"Ai oferit pachetul de arme factiunii "..name})
							return
						end

						vRPclient.notify(player, {"Ai scos pachetul de arme factiunii "..name, "error"})
					else
						vRPclient.notify(player, {"Aceasta factiune nu exista.", "error"})
					end

				end
			end)
		end)
	end
end

local function ch_giverpticket(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then

		vRP.prompt(player, "GIVE ROLEPLAY TICKET", "ID:", false, function(target_id)
			target_id = tonumber(target_id)

			if target_id then
				local target_src = vRP.getUserSource(target_id)

				if target_src then
					TriggerClientEvent("vrp:sendNuiMessage", target_src, {interface = "rpticket"})
				end
				vRPclient.notify(player, {"Ai oferit un Roleplay Ticket.", "success"})

				local user = vRP.getUser(user_id)

				if not user then
					exports.mongodb:updateOne({collection = "users", query = {id = target_id}, update = {
						["$inc"] = {rpTickets = 1},
						["$set"] = {showRpTicket = true},
					}})
					return
				end

				user.rpTickets = (user.rpTickets or 0) + 1
				vRP.updateUser(user_id, "rpTickets", user.rpTickets)
			end
		end)
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn and dbdata.showRpTicket then
		Citizen.CreateThread(function()
			Citizen.Wait(10000)
			TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "rpticket"})
		end)
		vRP.updateUser(user_id, "showRpTicket", false)
	end
end)

local function ch_createAuction(player, choice)
	local user_id = vRP.getUserId(player)

	vRP.selectorMenu(player, 'Auction Type', {{'House', 'house'}, {'Market', 'market'}, {'Gas Station', 'gas'}}, function(auctionType)
		if not auctionType then
			return
		end

		vRP.prompt(player, "Auction Title", 'Title:', '', function(title)
			if not title then
				return
			end

			vRP.prompt(player, "Auction Description", 'Description:', '', function(description)
				if not description then
					return
				end

				vRP.prompt(player, "Auction Image", 'Image:', '', function(img)
					if not img then
						return
					end

					vRP.prompt(player, 'Auction Price', 'Start Price:', '', function(price)
						if not price or tonumber(price) < 0 then
							return
						end
	
						if auctionType == 'house' then
							vRP.prompt(player, 'Auction House', 'House Number:', '', function(house)
								if not house and not tonumber(house) then
									return
								end
				
								vRP.createAuction({
									type = auctionType,
									startPrice = price,
									img = img,
									time = os.time() + 60 * 30,
									title = title,
									description = description,
									houseNumber = house,
								})
							end)
						elseif auctionType == 'market' then
							vRP.prompt(player, 'Auction Market', 'Market id:', '', function(market)
								if not market or not tonumber(market) then
									return
								end
			
								vRP.createAuction({
									type = auctionType,
									startPrice = price,
									img = img,
									time = os.time() + 60 * 30,
									market = market,
									title = title,
									description = description,
								})
							end)
			
						elseif auctionType == 'gas' then
							vRP.prompt(player, 'Auction Gas', 'Gas id:', '', function(gas)
								if not gas or not tonumber(gas) then
									return
								end
			
								vRP.createAuction({
									type = auctionType,
									startPrice = price,
									img = img,
									time = os.time() + 60 * 30,
									title = title,
									description = description,
									gasId = gas,
									
								})
							end)
						end
					end)
				end)
			end)
		end)
	end)
end

local function toggleAdminDuty(user_id)
	local player = vRP.getUserSource(user_id)

	if adminsDuty[user_id] then
		adminsDuty[user_id] = nil
		-- vRPclient.notify(player, {"De acum esti Staff Off Duty."})
		
		TriggerClientEvent("vrp:adminBlips", player, false)
	else
		adminsDuty[user_id] = {startTime = os.time()}
		-- vRPclient.notify(player, {"De acum esti Staff On Duty."})
	end

	vRP.closeMenu(player)
end

vRP.registerMenuBuilder("main", function(add, data)
  	local user_id = vRP.getUserId(data.player)
  	if user_id ~= nil then
		local user = vRP.getUser(user_id)
    	local choices = {}

		-- build admin menu
		if vRP.isAdminDuty(user_id) or vRP.getTrueAdminLevel(user_id) == 0 then
			choices["Admin"] = {function(player, choice)
				vRP.buildMenu("admin", {player = player}, function(menu)
					-- menu.onclose = function(player) vRP.closeMenu(player) end -- nest menu

					local adminLvl = vRP.getUserAdminLevel(user_id)

					if adminLvl >= 4 or vRP.hasGroup(user_id, "event") then -- Organizator Event
						menu["Event Money"] = {ch_evMoney, "<i class='fa-solid fa-dollar'></i>"}
					end
					if adminLvl >= 6 then -- Manager
						menu["Ofera Bani"] = {ch_givemoney, "<i class='fa-solid fa-university'></i>"}
						menu["Adauga/Scoate VIP"] = {ch_givevip, "<i class='fa-sharp fa-solid fa-face-tongue-money'></i>"}
						-- menu["Ofera Roleplay Ticket"] = {ch_giverpticket, '<i class="fa-duotone fa-ticket"></i>'}
						menu["Ofera pachet arme"] = {ch_giveweaponspack, '<i class="fa-solid fa-person-rifle"></i>'}
						menu['Creaza Licitatie'] = {ch_createAuction, '<i class="fa-solid fa-gavel"></i>'}
						menu["Adauga/Scoate Admin"] = {ch_addAdmin, "<i class='fa-sharp fa-solid fa-graduation-cap'></i>"}
						menu["Ofera un Item"] = {ch_giveitem, "<i class='fa-solid fa-hand-holding-hand'></i>"}
					end
					if adminLvl >= 5 then
						menu["Teleport to job"] = {ch_tptojob, '<i class="fa-duotone fa-location-pin-lock"></i>'}
						menu["Adauga Grup"] = {ch_addgroup, "<i class='fa-sharp fa-solid fa-graduation-cap'></i>"}
						menu["Scoate Grup"] = {ch_removegroup, "<i class='fa-sharp fa-regular fa-face-smile-tear'></i>"}
						menu["Tunning Menu"] = {ch_openTunningMenu, "<i class='fa-solid fa-car'></i>"}
						menu["Schimba Buletin"] = {ch_resetIdentity, "<i class='fa-regular fa-id-card'></i>"}					
					end
					if adminLvl >= 4 then -- Administrator
						menu["TpToCoords"] = {ch_tptocoords, "<i class='fa-solid fa-location-crosshairs'></i>"}
						menu["Toggle Arme"] = {ch_toggleWeaps, "<i class='fa-solid fa-gun'></i>"}
					end
					if adminLvl >= 3 then
						menu["Ban"] = {ch_ban, "<i class='fa-solid fa-ban'></i>"}
					end
					if adminLvl >= 2 then
						menu["No Clip"] = {ch_noclip, "<i class='fa-sharp fa-solid fa-dove'></i>"}
						menu["Kick"] = {ch_kick, "<i class='fas fa-virus'></i>"}
						menu["Admin UnJail"] = {ch_adminUnJail, "<i class='fas fa-hands-bound'></i>"}
						menu["Anunt Admin"] = {ch_ann, "<i class='fas fa-headset'></i>"}
						menu["Coordonate"] = {ch_coords, "<i class='fas fa-location-dot'></i>"}
					end
					if adminLvl >= 1 then
						menu["Admin Jail"] = {ch_adminJail, "<i class='fas fa-handcuffs'></i>"}
					end

					if vRP.getTrueAdminLevel(user_id) == 0 then
						menu["Cheama un Admin"] = {ch_calladmin, "<i class='fas fa-ticket'></i>"}
					end
					vRP.openMenu(player, menu)
				end)
			end, "<i class='fas fa-heart'></i>"}

			if vRP.getTrueAdminLevel(user_id) ~= 0 then
				choices["Admin Off-Duty"] = {function() toggleAdminDuty(user_id) end, "<i class='far fa-circle-xmark'></i>"}
			end
		else
			if vRP.getTrueAdminLevel(user_id) ~= 0 then
				choices["Admin On-Duty"] = {function() toggleAdminDuty(user_id) end, "<i class='far fa-circle-check'></i>"}
			end
		end

		-- choices["Roleplay Ticket"] = {function(player)
		-- 	if (user.rpTickets or 0) > 0 then
		-- 		vRP.giveCoins(user_id, user.rpTickets, true, "Roleplay Ticket")
		-- 		vRP.updateUser(user_id, "rpTickets", 0)
		-- 		vRP.closeMenu(player)
		-- 	end
		-- end, "<i class='fa-duotone fa-ticket'></i>", [[
		-- 	Aceste tickete se obtin in urma unor roleplay-uri complexe realizate pe serverul nostru.
		-- 	<br><br>
		-- 	Momentan detii <span style="color: #C69E78">]]..(user.rpTickets or 0)..[[</span> tickete
		-- 	<br><br>
		-- 	Apasa <span style="color: #C69E78">ENTER</span> pentru a transforma ticketele in coinuri.
		-- 	<br><span style="font-style: italic; color: hsla(0, 0%, 100%, .45); font-size: 15px">1 ticket = 1 coin</span>
		-- ]]}

    	add(choices)
	end
end)

-- [ADMIN COMMANDS]

RegisterCommand('tptocoords',function(player)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 4 then
		ch_tptocoords(player)
	else
		vRPclient.noAccess(player)
	end
end)

RegisterCommand('coords',function(src)
	if src == 0 then return end
	ch_coords(src)
end)

RegisterCommand("nc", function(player)
	tryNoclipToggle(player)
end)


RegisterCommand("staff", function(src)
	local staffOn = vRP.countOnlineStaff()
    local msg = "---- Staff Online ----"

	if staffOn == 0 then
		msg = msg.."\nNu sunt membrii staff online momentan!"
	end
	
	for uid, val in pairs(staffUsers) do
		msg = msg.."\n"..vRP.getColoredAdminTitle(val.lvl).."^7 - ^7"..(GetPlayerName(val.src) or "Username").." ^7[^1" .. uid .. "^7]"..(vRP.getUserAdminLevel(uid) == 0 and " [^3OFF-DUTY^7]" or "")
	end
	
	if src == 0 then
		print(msg.."\n^7--- ^1" .. staffOn .. " ^7Staff Online ---")
		return
	end
	
	TriggerClientEvent("chatMessage", src, msg.."\n^7--- ^1" .. staffOn .. " ^7Staff Online ---")
end)

local hasSpec = {}
RegisterCommand("spec", function(player, args)
	local user_id = vRP.getUserId(player)
	local target = parseInt(args[1])
	local target_src = vRP.getUserSource(target)

	if vRP.getUserAdminLevel(user_id) >= 2 then
		if (target == user_id) then 
			vRPclient.notify(player, {"Nu poti sa dai spec pe tine!", "error"})
			return
		end

		if not hasSpec[user_id] then
			hasSpec[user_id] = true
			SetPlayerRoutingBucket(player, GetPlayerRoutingBucket(target_src))
			TriggerClientEvent('vrp:setSpectator', player, target_src, GetEntityCoords(GetPlayerPed(target_src)))
		else
			SetPlayerRoutingBucket(player, 0)
			TriggerClientEvent('vrp:stopSpectating', player)
			hasSpec[user_id] = nil
		end
	end
end)

RegisterCommand("toglogs", function(player)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 1 then
		if activeLogs[player] then
			activeLogs[player] = nil
			vRPclient.msg(player, {"#{a1c9ff}ArmyLegends: ^7Ti-ai dezactivat admin log-urile."})
		else
			activeLogs[player] = true
			vRPclient.msg(player, {"#{a1c9ff}ArmyLegends: ^7Ti-ai activat admin log-urile."})
		end
	end
end)

function toggleBlips(player)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 2 then
		if blipsActive[user_id] then
			vRPclient.msg(player, {"#{a1c9ff}ArmyLegends: ^7Ti-ai dezactivat blips-urile."})
			TriggerClientEvent("vrp:adminBlips", player, false)
			blipsActive[user_id] = nil
		else
			blipsActive[user_id] = true
			vRPclient.msg(player, {"#{a1c9ff}ArmyLegends: ^7Ti-ai activat blips-urile."})
			TriggerClientEvent("vrp:adminBlips", player, true)
		end
	end
end

RegisterCommand("sprites", toggleBlips)
RegisterCommand("blips", toggleBlips)

AddEventHandler("vRP:playerSpawn", function(user_id, src, first_spawn)
	if first_spawn then
		if vRP.getTrueAdminLevel(user_id) >= 4 then
			toggleAdminDuty(user_id)
		end

		if not canUseWeapons then
			vRPclient.toggleAllWeapons(source, {canUseWeapons})
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source, spawned)
	if spawned then

		blipsActive[user_id] = nil

		if adminsDuty[user_id] then
			adminsDuty[user_id] =  nil
		end
	end
end)