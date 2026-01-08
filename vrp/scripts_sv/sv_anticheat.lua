local countedEnts = {}
local blackListedEnts = {}

local clearlyBlacklisted = {
	[-1127612162] = true,
	[-331093529] = true,
	[-1873481708] = true,
	[-2132681077] = true,
	[-1169517510] = true,
	[-1165757722] = true,
	[1817192171] = true,
	[94602826] = true,
	[877353931] = true,
	[-325175137] = true,
	[206865238] = true,
	[-2081176489] = true,
	[1670285818] = true,
	[1347635924] = true,
	[-1757087661] = true,
	[-1081534242] = true,
	[-496991810] = true,
	[37299309] = true,
	[1918463407] = true,
	[1953633095] = true,
	[580737581] = true,
	[-145066854] = true,
	[1708919037] = true,
	[1952396163] = true,
	[-2007231801] = true,
	[1694452750] = true,
	[1339433404] = true,
	[1933174915] = true,
	[-462817101] = true,
	[-164877493] = true,
	[-469694731] = true,
	[-1065766299] = true,
	[1270590574] = true,
	[2129526670] = true,
	[-1272895592] = true,
	[-2020505541] = true,
	[430430733] = true,
	[1369844566] = true,
	[-1157901789] = true,
	[-772034186] = true,
	[1982829832] = true,
	[-1685045150] = true,
	[-1127914163] = true,
	[-1919316447] = true,
	[1157292806] = true,
	[33644338] = true,
	[33644338] = true,
	[-183132887] = true,
	[-1082910619] = true,
	[-1082910619] = true,
	[1649550295] = true,
	[1649550295] = true,
	[1688567163] = true,
	[1688567163] = true,
	[852117134] = true,
	[852117134] = true,
	[-177141645] = true,
	[-177141645] = true,
	[-253989004] = true,
	[-253989004] = true,
	[-409826211] = true,
	[-409826211] = true,
	[684389648] = true,
	[684389648] = true,
	[-386896723] = true,
	[-386896723] = true,
	[969992943] = true,
	[969992943] = true,
	[1382165918] = true,
	[1382165918] = true,
	[-885621137] = true,
	[-885621137] = true,
	[1331928335] = true,
	[1331928335] = true,
	[441009964] = true,
	[441009964] = true,
	[2126974554] = true,
	[2126974554] = true,
	[-1462060028] = true,
	[-1462060028] = true,
	[1106835635] = true,
	[1106835635] = true,
	[1762103260] = true,
	[1762103260] = true,
	[-1460271444] = true,
	[-1460271444] = true,
	[-811841173] = true,
	[-811841173] = true,
	[203806105] = true,
	[203806105] = true,
	[2017293393] = true,
	[2017293393] = true,
	[-800778325] = true,
	[-800778325] = true,
	[-465751269] = true,
	[-465751269] = true,
	[1744002921] = true,
	[1744002921] = true,
	[-1222681440] = true,
	[-1826381033] = true,
	[-1404869155] = true,
	[-1782242710] = true,
	[-1268267712] = true,
	[335154249] = true,
	[827254092] = true,
	[1925170211] = true, -- sts (apa_mp_apa_crashed_usaf_01a)
	[298623376] = true,
	[954232759] = true,
	[654887944] = true,
	[682082323] = true,
	[-864163686] = true,
	[-1103279079] = true,
	[-1070059960] = true,
	[-131025346] = true,
	[-1550393228] = true,
	[-1773582887] = true,
	[-1062232474] = true,
	[-543669801] = true,
	[-1027860019] = true, -- de testat (p_cs_mp_jet_01_s)
	[-444717304] = true,
	[1774596576] = true,
	[-411908812] = true,
	[959604918] = true,
	[511619919] = true,
	[148511758] = true,
	[-473036318] = true, -- plane
	[1387939745] = true, -- plane
	[-621274213] = true, -- N E B U N I E 
	[959275690] = true,
	[1396140175] = true,
	[962669262] = true, -- remat gen
	[350589690] = true, -- nane
	[865506001] = true,
	[-1027805354] = true,
	[1952396163] = true,
	[-1404196790] = true,
	[598954707] = true, -- gen ce pula mea
	[894826008] = true,
	[-2145849767] = true, --
	[774425122] = true, -- gen ce pula mea v2
	[-1307682939] = true, -- remat 2 =]]
	[-234152995] = true, -- titanic in gta
	[899449633] = true,
	[-1139005491] = true
}

RegisterCommand("addprop", function(player, args)
	if player == 0 then
		if tonumber(args[1]) then
			blackListedEnts[tonumber(args[1])] = true
			TriggerClientEvent("ac:updateBlacklistedEnts", -1, blackListedEnts)
		end
	end
end)

RegisterCommand("removeprop", function(player, args)
	if player == 0 then
		if tonumber(args[1]) then
			blackListedEnts[tonumber(args[1])] = nil
			TriggerClientEvent("ac:updateBlacklistedEnts", -1, blackListedEnts)
		end
	end
end)

local trustedProps = {
	[GetHashKey('vw_prop_vw_luckywheel_01a')] = true,
	[GetHashKey('vw_prop_vw_luckywheel_02a')] = true,
	[GetHashKey('vw_prop_vw_casino_podium_01a')] = true,
	[GetHashKey('vw_prop_casino_slot_06a')] = true,
	[GetHashKey('vw_prop_casino_roulette_01b')] = true,
	[GetHashKey('prop_bucket_01a')] = true,
	[GetHashKey('prop_cs_hand_radio')] = true,
	[GetHashKey("prop_npc_phone_02")] = true,
	[GetHashKey("prop_weed_01")] = true,
	[GetHashKey("prop_weed_02")] = true,
	[GetHashKey("prop_wheelchair_01")] = true,
	[GetHashKey("p_ing_microphonel_01")] = true,
	[GetHashKey("prop_v_bmike_01")] = true,
	[GetHashKey("prop_xmas_tree_int")] = true,
	[452618762] = true, -- iarba mare
	[-305885281] = true, -- iarba mica
	[1407197773] = true, -- telefon
	[-1910604593] = true, -- undita
	[1336576410] = true, -- parasuta
	[1919238784] = true, -- vanix
	[-1585232418] = true, -- tableta
	[-935625561] = true, -- targa
	[600967813] = true, -- vanix la punga
	[-1109340972] = true,
	[1302435108] = true, -- cutie
	[GetHashKey("prop_atm_01")] = true,
	[GetHashKey("prop_novel_01")] = true, -- e book
	[1184113278] = true, -- prop_pool_cue

	-- bankrob
	-- [269934519] = true,
	-- [2007413986] = true,
	-- [881130828] = true,
	-- [2714348429] = true,
	-- [769923921] = true,
	-- [-1580618867] = true,
	-- [289396019] = true,
	-- [GetHashKey("hei_prop_heist_cash_pile")] = true,
	-- [GetHashKey("ch_prop_gold_bar_01a")] = true,
	-- [GetHashKey("ch_prop_vault_dimaondbox_01a")] = true,
	-- [GetHashKey("hei_p_m_bag_var22_arm_s")] = true,
	-- [GetHashKey("hei_prop_heist_thermite")] = true,
	-- [GetHashKey("hei_prop_hst_laptop")] = true,
	-- [GetHashKey("hei_prop_heist_card_hack_02")] = true,
	-- [GetHashKey("prop_v_cam_01")] = true,
	-- [GetHashKey("p_ld_id_card_01")] = true,
	
	-- [GetHashKey("lr_supermod_carlift2")] = true,
	-- [GetHashKey("nacelle")] = true,

	-- [GetHashKey("offstore_abobora_prop1")] = true,
	-- [GetHashKey("offstore_abobora_prop2")] = true,
	-- [GetHashKey("offstore_abobora_prop3")] = true,

	-- Spalare Bani
    [GetHashKey("bkr_prop_fakeid_papercutter")] = true,
    [GetHashKey("bkr_prop_cutter_moneypage")] = true,
    [GetHashKey("bkr_prop_fakeid_table")] = true,
    [GetHashKey("bkr_prop_cutter_moneystack_01a")] = true,
    [GetHashKey("bkr_prop_cutter_moneystrip")] = true,
    [GetHashKey("bkr_prop_cutter_singlestack_01a")] = true,
	[GetHashKey("bkr_prop_coke_tin_01")] = true,
	[GetHashKey("bkr_prop_tin_cash_01a")] = true,
	[GetHashKey("bkr_prop_money_unsorted_01")] = true,
	[GetHashKey("bkr_prop_money_wrapped_01")] = true,
	[GetHashKey("bkr_prop_money_counter")] = true,

	
	-- Heists
	[881130828] = true,
	[2007413986] = true,
	[269934519] = true,
	[769923921] = true,
	[GetHashKey("h4_prop_h4_gold_stack_01a")] = true,
	[GetHashKey("h4_prop_h4_cash_stack_01a")] = true,
	[GetHashKey("hei_p_m_bag_var22_arm_s")] = true,
	[GetHashKey("ch_prop_vault_dimaondbox_01a")] = true,
	[GetHashKey("ch_prop_gold_bar_01a")] = true,
	[GetHashKey("hei_prop_heist_cash_pile")] = true,
	[GetHashKey("hei_prop_heist_drill")] = true,
	[GetHashKey("p_chem_vial_02b_s")] = true,
	[GetHashKey("prop_cs_vial_01")] = true,
	[GetHashKey("w_me_switchblade")] = true,
	[GetHashKey("tr_prop_tr_grinder_01a")] = true,
	[GetHashKey("ch_p_m_bag_var02_arm_s")] = true,
	[GetHashKey("hei_prop_hst_laptop")] = true,
	[GetHashKey("hei_prop_heist_card_hack_02")] = true,
	[GetHashKey("h4_prop_h4_cutter_01a")] = true,
	[GetHashKey("prop_biotech_store")] = true,
	[GetHashKey("prop_ld_container")] = true,
	[GetHashKey("prop_ld_cont_light_01")] = true,
	[GetHashKey("p_pallet_02a_s")] = true,
	[GetHashKey("prop_cs_gascutter_1")] = true,
	[GetHashKey("prop_chem_grill")] = true,
	[GetHashKey("prop_chem_grill_bit")] = true,
	[GetHashKey("p_d_scuba_mask_s")] = true,
	[GetHashKey("p_michael_scuba_tank_s")] = true,
	[GetHashKey("p_steve_scuba_hood_s")] = true,
	[GetHashKey("ch_prop_diamond_trolly_01c")] = true,
	[GetHashKey("ch_prop_ch_cash_trolly_01b")] = true,
	[GetHashKey("ch_prop_gold_trolly_01a")] = true,
	[GetHashKey("imp_prop_impexp_coke_trolly")] = true,
	[GetHashKey("h4_prop_h4_diamond_01a")] = true,
	[GetHashKey("h4_prop_h4_diamond_disp_01a")] = true,
	[GetHashKey("h4_prop_h4_art_pant_01a")] = true,
	[GetHashKey("h4_prop_h4_necklace_01a")] = true,
	[GetHashKey("h4_prop_h4_neck_disp_01a")] = true,
	[GetHashKey("h4_prop_h4_t_bottle_02b")] = true,
	[GetHashKey("vw_prop_vw_pogo_gold_01a")] = true,
	[GetHashKey("h4_prop_h4_painting_01e")] = true,
	[GetHashKey("h4_prop_h4_painting_01f")] = true,
	[GetHashKey("h4_prop_h4_glass_disp_01a")] = true,
	[GetHashKey("tr_prop_tr_container_01a")] = true,
	[GetHashKey("prop_ld_container")] = true,
	[GetHashKey("tr_prop_tr_lock_01a")] = true,
	[GetHashKey("xm_prop_lab_desk_02")] = true,
	[GetHashKey("h4_prop_h4_glass_disp_01b")] = true,

	-- police props
    [GetHashKey("prop_roadcone02a")] = true,
    [GetHashKey("prop_barrier_work05")] = true,
    [GetHashKey("prop_barrier_work06a")] = true,
    [GetHashKey("prop_mp_barrier_02b")] = true,
	[GetHashKey("prop_mp_arrow_barrier_01")] = true,
    [GetHashKey("prop_gazebo_02")] = true,
    [GetHashKey("prop_worklight_03b")] = true,
    [GetHashKey("hei_prop_hei_monitor_police_01")] = true,
    [GetHashKey("prop_tyre_spike_01")] = true,

	-- builder job
	[GetHashKey("prop_woodpile_02a")] = true,
	[GetHashKey("prop_pooltable_02")] = true,
	[GetHashKey("prop_skid_pillar_01")] = true,
	[GetHashKey("prop_ld_balcfnc_02b")] = true,
	[GetHashKey("prop_fncwood_01c")] = true,
	[GetHashKey("prop_const_fence01a")] = true,
	[GetHashKey("prop_table_02_chr")] = true,
	[GetHashKey("prop_table_para_comb_04")] = true,
	[GetHashKey("prop_doghouse_01")] = true,

	-- opium trafficker job
	[GetHashKey("prop_bzzz_gardenpack_poppy001")] = true,

	-- maritime researcher job
	[GetHashKey("prop_drop_armscrate_01b")] = true,
    [GetHashKey("prop_drop_armscrate_01")] = true,
    [GetHashKey("prop_money_bag_01")] = true,
    [GetHashKey("bkr_prop_fakeid_binbag_01")] = true,
	[GetHashKey("p_s_scuba_mask_s")] = true,
	[GetHashKey("p_s_scuba_tank_s")] = true,
}

local npcUsed = {
	[1885233650] = true, -- Baiat
	[-1667301416] = true, -- Fata
	[225514697] = true,
	[-1692214353] = true,
	[-1686040670] = true,
	[68070371] = true,

	-- Heists
	[GetHashKey("csb_tomcasino")] = true,
	[GetHashKey("s_m_m_highsec_01")] = true,
	[GetHashKey("s_m_m_highsec_02")] = true,
	[GetHashKey("s_m_m_fiboffice_02")] = true,
	[GetHashKey("s_m_m_scientist_01")] = true,
	[GetHashKey("s_m_m_chemsec_01")] = true,
	[GetHashKey("s_m_y_blackops_01")] = true
}

-- types: 1 - peds, 2 - vehs, 3 - objs

--[[
AddEventHandler("entityCreating", function(entity)
	local model = GetEntityModel(entity)
	local strToAdd = "["..entity.."]["..GetEntityType(entity).."]["..(vRP.getUserId({NetworkGetEntityOwner(entity)}) or "0").."]: "..model
	local file = LoadResourceFile("vrp", "entLogsFull.txt")
	SaveResourceFile("vrp", "entLogsFull.txt", file .. "\n" .. strToAdd, -1)
end)
--]]

local trustedPlayers = {}
RegisterCommand("syncthem", function(player)
	local user_id = vRP.getUserId(player)
	trustedPlayers[user_id] = true
	Citizen.CreateThread(function()
		Wait(5 * 1000)
		trustedPlayers[user_id] = nil
	end)
end)

RegisterCommand("delvehs", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 4 then
		if args[1] then
			TriggerClientEvent("ac:deleteAllVehs", -1)
		else
			TriggerClientEvent("ac:deleteAllVehs", player)
		end
	else
		vRPclient.noAccess(player)
	end
end)

RegisterCommand("delobjects", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 4 then
		if args[1] then
			TriggerClientEvent("ac:deleteAllProps", -1)
		else
			TriggerClientEvent("ac:deleteAllProps", player)
		end
	else
		vRPclient.noAccess(player)
	end
end)

local vehSpawning = {}
RegisterServerEvent("ac:getSpawnPoint", function(player)
	-- vehSpawning[player] = (vehSpawning[player] or 0) + 1
end)

AddEventHandler("entityCreating", function(entity)
	if GetEntityType(entity) == 3 then
		local model = GetEntityModel(entity)
		if model ~= 0 then
			local player = NetworkGetEntityOwner(entity)
			local user_id = vRP.getUserId(player)
			if not clearlyBlacklisted[model] then
				if not blackListedEnts[model] then
					if not trustedProps[model] then
						if not trustedPlayers[user_id] then

							local strToAdd = "["..entity.."]["..GetEntityType(entity).."]["..(user_id or "0").."]: "..model
							local file = LoadResourceFile("vrp", "entLogs.txt") or ""
							SaveResourceFile("vrp", "entLogs.txt", file .. "\n" .. strToAdd, -1)

							countedEnts[model] = (countedEnts[model] or 0) + 1
							Citizen.CreateThread(function()
								Wait(180000)
								countedEnts[model] = countedEnts[model] - 1
							end)
							if countedEnts[model] > 1 then
								blackListedEnts[model] = true
								TriggerClientEvent("ac:updateBlacklistedEnts", -1, blackListedEnts)
							end
						end
					end
				else
					CancelEvent()
				end
			else
				
				if model == -2132681077 then -- steagul mortii
					TriggerClientEvent("vRP:triggerServerEvent", player, "vrp:X", "Joaca fara meniuri !")
				else
					TriggerEvent("chat:sendLogs", "^1AC^7: ^1"..(GetPlayerName(player) or "Unknown").." ^7[^1"..(user_id or "0").."^7] a creeat un obiect: ^1"..model)
				end
				CancelEvent()
			end
		end
	elseif GetEntityType(entity) == 1 then
		-- ped
		local model = GetEntityModel(entity)
		if npcUsed[model] ~= true then
			local sender = NetworkGetEntityOwner(entity)
			local user_id = vRP.getUserId(sender)
			if not trustedPlayers[user_id] then
				CancelEvent()
			end
		end
	elseif GetEntityType(entity) == 2 then
		-- vehicle
		local player = NetworkGetEntityOwner(entity)
		local user_id = vRP.getUserId(player)

		-- if (vehSpawning[player] or 0) > 0 then
		-- 	vehSpawning[player] = vehSpawning[player] - 1
		-- elseif vRP.getUserAdminLevel(user_id) < 4 and not vRP.hasGroup(user_id, "event") then
		-- 	CancelEvent()
		-- end
	end
end)

AddEventHandler('explosionEvent', function(sender, ev)
	local user_id = vRP.getUserId(sender)
	if ev.damageScale ~= 0 and ev.explosionType ~= 38 and ev.explosionType ~= 20 then
		if ev.explosionType ~= 13 and ev.explosionType ~= 22 then
			TriggerEvent("chat:sendLogs", "^1AC^7: ^1"..(GetPlayerName(sender) or "Unknown").." ^7[^1"..(user_id or "0").."^7] a creeat o explozie (DMG: "..ev.damageScale..", Type: "..ev.explosionType..")")
		end
		CancelEvent()
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(1000)

		vRPclient.executeCommand(player, {"syncthem"})
		TriggerClientEvent("ac:updateBlacklistedEnts", player, blackListedEnts)

		if vRP.getTrueAdminLevel(user_id) ~= 0 then
			TriggerClientEvent("ac:setAdmin", player, 69132)
		end
	end
end)
