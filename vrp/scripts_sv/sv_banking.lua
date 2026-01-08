
RegisterServerEvent("vrp-banking:donateToCharity", function()
	local player = source
	local user_id = vRP.getUserId(player)

	vRP.prompt(player, "CHARITY", "Introdu in caseta de mai jos suma pe care doresti sa o donezi.", false, function(amount)
		amount = tonumber(amount)

		if amount and amount > 0 then
			if vRP.tryBankPayment(user_id, amount, false, "Charity") then
				TriggerClientEvent("vrp-banking:updateScreenVal", player, "balance", vRP.getBankMoney(user_id))
			
			else
				TriggerClientEvent("vrp-banking:notification", player, "Nu ai destui bani pentru a dona.")
			end
		end
	end, true)
end)

function tvRP.tryBankDeposit()
	local player = source
	local user_id = vRP.getUserId(player)

	vRP.prompt(player, "BALANCE REPLENISH", "Introdu in caseta de mai jos suma pe care doresti sa o depozitezi.", false, function(amount)
		amount = tonumber(amount)

		if amount and amount > 0 then
			local done = vRP.tryDeposit(user_id,amount)

			if done then
				
				TriggerClientEvent("vrp-banking:updateScreenVal", player, "balance", vRP.getBankMoney(user_id))
				TriggerClientEvent("vrp-banking:updateScreenVal", player, "cash", vRP.getMoney(user_id))

			else
				TriggerClientEvent("vrp-banking:notification", player, "Nu ai $"..vRP.formatMoney(amount).." in buzunar.")
			end
		end
	end, true)
end

function tvRP.tryBankWithdraw()
	local player = source
	local user_id = vRP.getUserId(player)

	vRP.prompt(player, "WITHDRAW MONEY", "Introdu in caseta de mai jos suma pe care doresti sa o retragi.", false, function(amount)
		amount = tonumber(amount)

		if amount and amount > 0 then
			local done = vRP.tryWithdraw(user_id,amount,true)

			if done then
				
				TriggerClientEvent("vrp-banking:updateScreenVal", player, "balance", vRP.getBankMoney(user_id))
				TriggerClientEvent("vrp-banking:updateScreenVal", player, "cash", vRP.getMoney(user_id))

			else
				TriggerClientEvent("vrp-banking:notification", player, "Nu ai $"..vRP.formatMoney(amount).." in contul bancar.")
			end
		end
	end, true)
end

function tvRP.tryFactionDeposit(amount)
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.hasUserFaction(user_id) then

		local faction = vRP.getUserFaction(user_id)

		vRP.prompt(player, "REPLENISH FACTION BUDGET", "Introdu in caseta de mai jos suma pe care doresti sa o depozitezi.", false, function(amount)
			amount = tonumber(amount)

			if amount and amount > 0 then
				if vRP.tryPayment(user_id,amount,false,"Faction Budget Deposit") then
					local done = vRP.depositFactionBudget(faction, amount)

					if done then
						TriggerClientEvent("vrp-banking:updateScreenVal", player, "cash", vRP.getMoney(user_id))
						TriggerClientEvent("vrp-banking:updateScreenVal", player, "balance", vRP.getBankMoney(user_id))
						TriggerClientEvent("vrp-banking:updateScreenVal", player, "faction", vRP.getFactionBudget(faction))
					end
				else
					TriggerClientEvent("vrp-banking:notification", player, "Nu ai $"..vRP.formatMoney(amount).." in buzunar.")
				end
			end
		end, true)
	end
end

function tvRP.tryFactionWithdraw()
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.hasUserFaction(user_id) then

		local faction = vRP.getUserFaction(user_id)

		if vRP.isFactionLeader(user_id,faction) or vRP.isUserCoLeader(user_id, faction) then

			vRP.prompt(player, "WITHDRAW FROM FACTION", "Introdu in caseta de mai jos suma pe care doresti sa o retragi.", false, function(amount)
				amount = tonumber(amount)

				if amount and amount > 0 then
					local done = vRP.withdrawFactionBudget(faction, user_id, amount)

					if done then
							
						TriggerClientEvent("vrp-banking:updateScreenVal", player, "cash", vRP.getMoney(user_id))
						TriggerClientEvent("vrp-banking:updateScreenVal", player, "faction", vRP.getFactionBudget(faction))

					else
						TriggerClientEvent("vrp-banking:notification", player, "Nu ai $"..vRP.formatMoney(amount).." in bugetul factiunii.")
					end
				end
			end, true)
		else
			TriggerClientEvent("vrp-banking:notification", player, "Doar liderul si coliderul pot retrage bani din factiune.")
		end
	end
end

local function calculatePercentage(percentage, number)
	return math.floor((number * percentage) / 100)
end

function tvRP.tryBankTransfer(iban, amount)
	local player = source
	local user_id = vRP.getUserId(player)


	vRP.prompt(player, "TRANSFER MONEY", "Introdu in caseta de mai jos iban-ul catre care transferi bani.", false, function(iban)
		if iban then
			local to_id = exports["vrp_phone"]:getUserByIban(iban)

			if to_id then
				local to_src = vRP.getUserSource(to_id)

				if to_src then
				
					vRP.prompt(player, "TRANSFER MONEY", "Introdu in caseta de mai jos suma pe care doresti sa o transferi.", false, function(amount)
						amount = tonumber(amount)
			
						if amount and amount > 0 then
							if vRP.tryBankPayment(user_id, amount, false, "Bank Transfer (iban: "..iban..")") then
								
								local reduce = calculatePercentage(10, amount)
								local vipRank = vRP.getUserVipRank(user_id)
							
								if vipRank > 1 then
									reduce = calculatePercentage(5, amount)
								end
							
								amount = math.floor(amount - reduce)
								
								vRP.giveBankMoney(to_id, amount, "Bank Transfer (from: "..user_id..")")
								TriggerClientEvent("vrp-banking:updateScreenVal", player, "balance", vRP.getBankMoney(user_id))

								local identity = vRP.getIdentity(user_id)
								local name = identity.firstname.." "..identity.name.." "


								exports.vrp:achieve(to_id, 'TransferEasy', 1)
								exports["vrp_phone"]:sendMessage(to_id, {
									message = name..[[
										v-a transferat in contul dvs. bancar suma de $]]..vRP.formatMoney(amount)..[[.<br>
										<br><br>- Fleeca Bank<br>
										www.fleeca.com
									]],
									sender = "2002-2202",
									type = "message"
								})
							else
								TriggerClientEvent("vrp-banking:notification", player, "Nu ai $"..vRP.formatMoney(amount).." in contul tau bancar.")
							end
						end
					end, true)

				else
					TriggerClientEvent("vrp-banking:notification", player, "Nu s-a gasit nici o persoana cu acest IBAN")
				end
			else
				TriggerClientEvent("vrp-banking:notification", player, "Nu s-a gasit nici o persoana cu acest IBAN")
			end
		end
	end, true)
end

function tvRP.getBankingData()
	local player = source
	local user_id = vRP.getUserId(player)

	local bank, cash = vRP.getBankMoney(user_id), vRP.getMoney(user_id)
	local name = exports['vrp']:getRoleplayName(user_id)
	local iban = vRP.getUserIban(user_id)

	return {
		faction = faction,
		balance = bank,
		name = name,
		iban = iban,
		cash = cash
	}
end