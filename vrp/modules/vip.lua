
local titles = { "Prime", "Prime Platinum" }
local cfg = module("cfg/vip")

function vRP.getUserVipRank(user_id)
	if vRP.usersData[user_id] then
		return vRP.usersData[user_id]['vipLvl'] or 0
	end
	
	return 0
end

function vRP.isUserVip(user_id)
	local vipRank = vRP.getUserVipRank(user_id)
	if(vipRank > 0)then
		return true
	end
	return false
end

function vRP.isUserPrimeVip(user_id)
	local vipRank = vRP.getUserVipRank(user_id)
	if(vipRank >= 1)then
		return true
	end
	return false
end

function vRP.isUserPlatinumVip(user_id)
	local vipRank = vRP.getUserVipRank(user_id)
	if(vipRank >= 2)then
		return true
	end
	return false
end

function vRP.setUserVip(user_id,vip)
	vRP.updateUser(user_id, 'vipLvl', vip)
end

function vRP.getUserVipTitle(user_id, rank)
	local vipLvl = rank or vRP.getUserVipRank(user_id)
    local text = titles[vipLvl] or "V.I.P"
    return text, vipLvl
end

function vRP.getOnineVips()
	local oUsers = {}
	for k,v in pairs(vRP.rusers) do
		if vRP.isUserVip(tonumber(k)) then table.insert(oUsers, tonumber(k)) end
	end
	return oUsers
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn and dbdata.userVip then
		local userVip = dbdata.userVip

		if (userVip.expireTime or 0) <= os.time() then
			vRP.setUserVip(user_id, 0)
			vRP.updateUser(user_id, 'userVip', false)
			vRPclient.notify(player, {"Tocmai ti-a expirat gradul de "..cfg.grades["vip:"..tostring(userVip.vip)][3], "error"})
		end
	end
end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
	if string.find(choice, 'vip') then
		if (vRP.usersData[user_id] and vRP.usersData[user_id]['userVip']) then
			return vRPclient.notify(player, {'Ai deja un Prime Account cumparat, asteapta sa expire pentru a iti putea achizitiona altul!'})
		end
		if vRP.tryCoinsPayment(user_id, cfg.grades[choice][2], choice, true) then
			local expireTime = os.time() + daysToSeconds(cfg.grades[choice][1])
			local vipLvl = parseInt(splitString(choice, ":")[2])
			local grade = {
				expireTime = expireTime,
				vip = tonumber(vipLvl),
			}
			vRP.setUserVip(user_id, tonumber(vipLvl))
			if tonumber(vipLvl) > 1 then
				TriggerClientEvent("afk-kick:setPrime", player, 3600)
			end
			local bonusMoney = cfg.vipMoney[vipLvl]
			vRP.updateUser(user_id, 'userVip', grade)
			if bonusMoney > 0 then
				vRP.giveBankMoney(user_id, bonusMoney, "VIP Bonus")
				exports["vrp_phone"]:sendMessage(user_id, {
					message = [[
						Salutare, ]]..GetPlayerName(player)..[[!
						<br>Tocmai ai achizitionat gradul ]]..titles[vipLvl]..[[.<br>
						Data expirarii: ]]..os.date("%d/%m/%Y", expireTime)..[[<br>
						Ai primit bonus +$]]..vRP.formatMoney(bonusMoney)..[[ in contul bancar.
						<br><br>Iti multumim pentru sustinere.<br>
						- ArmyLegends Romania
					]],
					sender = "0101-0101",
					type = "message"
				})
			end
			
			for k, v in pairs(cfg.vipVouchers[choice]) do
				vRP.setUserPremiumVoucher(user_id, v[1], v[2])
				vRP.giveItem(user_id, v[1], v[2], false, false, false, 'Premium Shop')
			end
		end
	end
end)

function vRP.giveJobBoostMoney(user_id, amount)
	local vipRank = vRP.getUserVipRank(user_id)
	if vipRank > 0 then
		local boost = cfg.jobBoost[vipRank] or 0
		
		if boost > 0 then
			local money = math.floor(amount * boost / 100)
			return money
		end
	end
	return 0
end

function vRP.getUserPremiumVouchers(user_id)
	if (vRP.usersData[user_id] and vRP.usersData[user_id]['vipVouchers']) then
		return vRP.usersData[user_id]['vipVouchers'] 
	end

	return 0
end

function vRP.getUserPremiumVoucher(user_id, voucher)
	if (vRP.usersData[user_id] and vRP.usersData[user_id]['vipVouchers']) then
		return vRP.usersData[user_id]['vipVouchers'][voucher]
	end

	return 0
end

function vRP.setUserPremiumVoucher(user_id, voucher, amount)
	if vRP.usersData[user_id] then
		if (not vRP.usersData[user_id]['vipVouchers']) then
			vRP.usersData[user_id]['vipVouchers'] = {}
		end

		vRP.usersData[user_id]['vipVouchers'][voucher] = amount
	end

	vRP.updateUser(user_id, 'vipVouchers', vRP.usersData[user_id]['vipVouchers'])
end

Citizen.CreateThread(function()
	Citizen.Wait(2500)
	vRP.defInventoryItem("premium_xenon", "Xenon Premium", "Cu acest obiect ii poti modifica culoarea Xenonului unui vehicul", function(player) 
		vRP.openXenonMenu(vRP.getUserId(player))
	end, 0.1, "premium")
end)

function vRP.openXenonMenu(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local xenonMenu = {
			name = "Xenon Colors",
		}

		local colors = {
			["Albastru"] = 1,
			["Albastru deschis"] = 2,
			["Verde"] = 3,
			["Lime"] = 4,
			["Galben"] = 5,
			["Gold"] = 6,
			["Portocaliu"] = 7,
			["Rosu"] = 8,
			["Roz deschis"] = 9,
			["Roz"] = 10,
			["Mov"] = 11,
			["Indigo"] = 12
		}

		local function choose(player, choice)
			vRP.closeMenu(player)
			vRPclient.getNearestOwnedVehicle(player, {10}, function(vname)
				if vname then
					vRPclient.setPremiumXenon(player, {vname, colors[choice], true})

					vRP.request(player, "Doresti sa pastrezi xenon ["..choice.."]?", false, function(player, ok)
						if ok then
							if vRP.removeItem(user_id, 'premium_xenon') then
								vRPclient.setPremiumXenon(player, {vname, colors[choice], false})
								exports.mongodb:updateOne({
									collection = "userVehicles", 
									query = {
										user_id = user_id,
										vehicle = vname,
									},
									update = {
										['$set'] = {
											premiumXenon = colors[choice]
										}
									}
								})
							end
						else
							vRPclient.setPremiumXenon(player, {vname, 0, true})
						end
					end)
				end
			end)
		end

		for color, id in pairs(colors) do
			xenonMenu[color] = {choose, '<i class="fa-solid fa-brush"></i>'}
		end

		vRP.openMenu(player, xenonMenu)
	end
end