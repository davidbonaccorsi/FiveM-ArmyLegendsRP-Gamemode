local recoils = {
	[453432689] = 0.3, -- PISTOL
	[3219281620] = 0.8, -- PISTOL MK2
	[1593441988] = 0.8, -- COMBAT PISTOL
	[584646201] = 0.1, -- AP PISTOL
	[2578377531] = 2.6, -- PISTOL .50
	[324215364] = 0.2, -- MICRO SMG
	[736523883] = 0.1, -- SMG
	[2024373456] = 0.1, -- SMG MK2
	[4024951519] = 4.5, -- ASSAULT SMG
	[3220176749] = 0.9, -- ASSAULT RIFLE
	[961495388] = 2.2, -- ASSAULT RIFLE MK2
	[2210333304] = 4.8, -- CARBINE RIFLE
	[4208062921] = 2.8, -- CARBINE RIFLE MK2
	[2937143193] = 0.1, -- ADVANCED RIFLE
	[2634544996] = 25.5, -- MG
	[2144741730] = 11.5, -- COMBAT MG
	[3686625920] = 9.5, -- COMBAT MG MK2
	[487013001] = 5.5, -- PUMP SHOTGUN
	[1432025498] = 5.5, -- PUMP SHOTGUN MK2
	[2017895192] = 5.5, -- SAWNOFF SHOTGUN
	[3800352039] = 5.5, -- ASSAULT SHOTGUN
	[2640438543] = 5.5, -- BULLPUP SHOTGUN
	[911657153] = 0.1, -- STUN GUN
	[100416529] = 0.5, -- SNIPER RIFLE
	[205991906] = 0.7, -- HEAVY SNIPER
	[177293209] = 0.7, -- HEAVY SNIPER MK2
	[856002082] = 1.2, -- REMOTE SNIPER
	[2726580491] = 1.0, -- GRENADE LAUNCHER
	[1305664598] = 1.0, -- GRENADE LAUNCHER SMOKE
	[2982836145] = 0.0, -- RPG
	[1752584910] = 0.0, -- STINGER
	[1119849093] = 0.01, -- MINIGUN
	[3218215474] = 0.2, -- SNS PISTOL
	[2009644972] = 0.25, -- SNS PISTOL MK2
	[1627465347] = 5.8, -- GUSENBERG
	[3231910285] = 2.8, -- SPECIAL CARBINE
	[-1768145561] = 2.8, -- SPECIAL CARBINE MK2
	[3523564046] = 0.8, -- HEAVY PISTOL
	[2132975508] = 0.2, -- BULLPUP RIFLE
	[-2066285827] = 1.8, -- BULLPUP RIFLE MK2
	[137902532] = 0.8, -- VINTAGE PISTOL
	[-1746263880] = 1.1, -- DOUBLE ACTION REVOLVER
	[2828843422] = 0.7, -- MUSKET
	[984333226] = 5.5, -- HEAVY SHOTGUN
	[3342088282] = 0.3, -- MARKSMAN RIFLE
	[1785463520] = 0.35, -- MARKSMAN RIFLE MK2
	[1672152130] = 0, -- HOMING LAUNCHER
	[1198879012] = 0.9, -- FLARE GUN
	[171789620] = 2.0, -- COMBAT PDW
	[3696079510] = 0.9, -- MARKSMAN PISTOL
  	[1834241177] = 2.4, -- RAILGUN
	[3675956304] = 3.3, -- MACHINE PISTOL
	[3249783761] = 0.18, -- REVOLVER
	[-879347409] = 0.65, -- REVOLVER MK2
	[4019527611] = 5.5, -- DOUBLE BARREL SHOTGUN
	[1649403952] = 2.5, -- COMPACT RIFLE
	[317205821] = 5.5, -- AUTO SHOTGUN
	[125959754] = 0.5, -- COMPACT LAUNCHER
	[3173288789] = 0.1, -- MINI SMG

	--
	[GetHashKey("WEAPON_NAVYREVOLVER")] = 1.1, -- Navy Revolver
	[GetHashKey("WEAPON_GADGETPISTOL")] = 1.1, -- Gadget Pistol

	-- == NEW WEAPONS ==
	[GetHashKey("weapon_ak47")] = 0.5,
	[GetHashKey("weapon_de")] = 0.5,
	[GetHashKey("weapon_fnx45")] = 0.3,
	[GetHashKey("weapon_glock17")] = 0.3,
	[GetHashKey("weapon_m4")] = 0.3,
	[GetHashKey("weapon_hk416")] = 0.3,
	[GetHashKey("weapon_mk14")] = 0.4,
	[GetHashKey("weapon_m110")] = 0.4,
	[GetHashKey("weapon_ar15")] = 0.4,
	[GetHashKey("weapon_m9")] = 0.4,
	[GetHashKey("weapon_m70")] = 0.5,
	[GetHashKey("weapon_m1911")] = 0.4,
	[GetHashKey("weapon_mac10")] = 0.7,
	[GetHashKey("weapon_uzi")] = 0.7,
	[GetHashKey("weapon_mp9")] = 0.7,
	[GetHashKey("weapon_mossberg")] = 0.7,
	[GetHashKey("weapon_remington")] = 0.7,
	[GetHashKey("weapon_scarh")] = 0.5,
}

local weapShakes = {
	[GetHashKey('WEAPON_STUNGUN')] = 0.01,
	[GetHashKey('WEAPON_FLAREGUN')] = 0.01,
	[GetHashKey('WEAPON_SNSPISTOL')] = 0.15,
	[GetHashKey('WEAPON_SNSPISTOL_MK2')] = 0.15,
	[GetHashKey('WEAPON_PISTOL')] = 0.025,
	[GetHashKey('WEAPON_PISTOL_MK2')] = 0.15,
	[GetHashKey('WEAPON_APPISTOL')] = 0.05,
	[GetHashKey('WEAPON_COMBATPISTOL')] = 0.15,
	[GetHashKey('WEAPON_PISTOL50')] = 0.25,
	[GetHashKey('WEAPON_HEAVYPISTOL')] = 0.15,
	[GetHashKey('WEAPON_VINTAGEPISTOL')] = 0.15,
	[GetHashKey('WEAPON_MARKSMANPISTOL')] = 0.03,
	[GetHashKey('WEAPON_REVOLVER')] = 0.55,
	[GetHashKey('WEAPON_REVOLVER_MK2')] = 0.055,
	[GetHashKey('WEAPON_DOUBLEACTION')] = 0.25,
	[GetHashKey('WEAPON_NAVYREVOLVER')] = 0.35,
	[GetHashKey('WEAPON_GADGETPISTOL')] = 0.55,
	-- SMG
	[GetHashKey('WEAPON_MICROSMG')] = 0.095,
	[GetHashKey('WEAPON_COMBATPDW')] = 0.095,
	[GetHashKey('WEAPON_SMG')] = 0.095,
	[GetHashKey('WEAPON_SMG_MK2')] = 0.055,
	[GetHashKey('WEAPON_ASSAULTSMG')] = 0.095,
	[GetHashKey('WEAPON_MACHINEPISTOL')] = 0.095,
	[GetHashKey('WEAPON_MG')] = 0.095,
	[GetHashKey('WEAPON_COMBATMG')] = 0.095,
	[GetHashKey('WEAPON_COMBATMG_MK2')] = 0.095,
	[GetHashKey('WEAPON_MINISMG')] = 0.095,
    -- Rifles
	[GetHashKey('WEAPON_ASSAULTRIFLE')] = 0.040,
	[GetHashKey('WEAPON_ASSAULTRIFLE_MK2')] = 0.090,
	[GetHashKey('WEAPON_CARBINERIFLE')] = 0.095,
	[GetHashKey('WEAPON_CARBINERIFLE_MK2')] = 0.065,
	[GetHashKey('WEAPON_ADVANCEDRIFLE')] = 0.06,
	[GetHashKey('WEAPON_GUSENBERG')] = 0.095,
	[GetHashKey('WEAPON_SPECIALCARBINE')] = 0.06,
	[GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = 0.095,
	[GetHashKey('WEAPON_BULLPUPRIFLE')] = 0.05,
	[GetHashKey('WEAPON_BULLPUPRIFLE_MK2')] = 0.095,
	[GetHashKey('WEAPON_COMPACTRIFLE')] = 0.095,
	[GetHashKey('WEAPON_MILITARYRIFLE')] = 0.08,
    -- Shotguns
	[GetHashKey('WEAPON_PUMPSHOTGUN')] = 0.55,
	[GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = 0.55,
	[GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = 0.55,
	[GetHashKey('WEAPON_ASSAULTSHOTGUN')] = 0.55,
	[GetHashKey('WEAPON_BULLPUPSHOTGUN')] = 0.55,
	[GetHashKey('WEAPON_DBSHOTGUN')] = 0.55,
	[GetHashKey('WEAPON_AUTOSHOTGUN')] = 0.55,
	[GetHashKey("WEAPON_MUSKET")] = 0.04,
	[GetHashKey('WEAPON_HEAVYSHOTGUN')] = 0.55,
    -- Sniper Rifles
	[GetHashKey('WEAPON_SNIPERRIFLE')] = 0.2,
	[GetHashKey('WEAPON_HEAVYSNIPER')] = 0.3,
	[GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = 0.35,
	[GetHashKey('WEAPON_MARKSMANRIFLE')] = 0.1,
	[GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = 0.1,
    -- Heavy Weapons
    [GetHashKey("WEAPON_RPG")] = 0.9,
    [GetHashKey("WEAPON_GRENADELAUNCHER")] = 0.08,
    [GetHashKey("WEAPON_MINIGUN")] = 0.20,
    [GetHashKey("WEAPON_FIREWORK")] = 0.5,
    [GetHashKey("WEAPON_RAILGUN")] = 1.0,
    [GetHashKey("WEAPON_HOMINGLAUNCHER")] = 0.9,
    [GetHashKey("WEAPON_COMPACTLAUNCHER")] = 0.08,
    [GetHashKey("WEAPON_RAYMINIGUN")] = 0.5,

	-- == NEW WEAPONS ==
	[GetHashKey("weapon_ak47")] = 0.07,
	[GetHashKey("weapon_hk416")] = 0.08,
	[GetHashKey("weapon_m110")] = 0.095,
	[GetHashKey("weapon_m70")] = 0.095,

	-- Shotguns
	[GetHashKey("weapon_mossberg")] = 0.55,

	-- Crafting
	[GetHashKey("weapon_de")] = 0.15, -- Pistol
	[GetHashKey("weapon_m1911")] = 0.15, -- Pistol
	[GetHashKey("weapon_fnx45")] = 0.15, -- Pistol
	[GetHashKey("weapon_mac10")] = 0.095,
	[GetHashKey("weapon_uzi")] = 0.095,

	-- Police Weapons --
	[GetHashKey("weapon_glock17")] = 0.15, -- Pistol
	[GetHashKey("weapon_m9")] = 0.15, -- Pistol
	[GetHashKey("weapon_m4")] = 0.095, -- Rifle
	[GetHashKey("weapon_scarh")] = 0.095, -- Rifle
	[GetHashKey("weapon_ar15")] = 0.095, -- Rifle
	[GetHashKey("weapon_mk14")] = 0.095, -- Rifle
	[GetHashKey("weapon_remington")] = 0.08, -- Shotgun
}


AddEventHandler("CEventGunShot", function(ev,ent,extraData)
	if ent == tempPed then
		exports["vrp_anims"]:cancelEmotes()

		if not IsPedDoingDriveby(tempPed) then
			local weapon = GetSelectedPedWeapon(tempPed)
			local shake = weapShakes[weapon]

			if shake then
				ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', shake)
			end

			local _,wep = GetCurrentPedWeapon(tempPed)
			if recoils[wep] and recoils[wep] ~= 0 then
				tv = 0
				repeat
					Wait(0)
					p = GetGameplayCamRelativePitch()
					if GetFollowPedCamViewMode() ~= 4 then
						SetGameplayCamRelativePitch(p+0.1, 0.2)
					end
					tv = tv+0.1
				until tv >= (recoils[wep]*1) -- *3
			end

			DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
		end
	end
end)
