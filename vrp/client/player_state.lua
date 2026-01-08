local isFrozen = false
function tvRP.loadFreeze(flag)
	isFrozen = flag
  Citizen.CreateThread(function()
    while isFrozen do
      SetEntityInvincible(tempPed,true)
      SetEntityVisible(tempPed,false)
      FreezeEntityPosition(tempPed,true)
      Citizen.Wait(1)
    end
    SetEntityInvincible(tempPed,false)
    SetEntityVisible(tempPed,true)
    FreezeEntityPosition(tempPed,false)
  end)
end

function tvRP.setFreeze(bool, ignoreVisibility)
  isFrozen = bool

  if not ignoreVisibility then
    SetEntityVisible(tempPed, not bool)
  end
  
  FreezeEntityPosition(tempPed, isFrozen)
  SetEntityInvincible(tempPed, isFrozen)

  CreateThread(function()
    while isFrozen do
      DisableControlAction(0, 311, true) -- K
      DisableControlAction(0, 24, true) -- Click
      DisableControlAction(0, 22, true) -- Space
      DisableControlAction(0, 288, true) -- F1 vMenu
      DisableControlAction(0, 289, true) -- F2 NoClip
      DisableControlAction(0, 37, true) -- TAB

      DisableControlAction(0,19,true)
      DisableControlAction(0,21,true)
      DisableControlAction(0,22,true)
      DisableControlAction(0,25,true)
      DisableControlAction(0,47,true)
      DisableControlAction(0,58,true)
      DisableControlAction(0,263,true)
      DisableControlAction(0,264,true)
      DisableControlAction(0,257,true)
      DisableControlAction(0,140,true)
      DisableControlAction(0,141,true)
      DisableControlAction(0,142,true)
      DisableControlAction(0,143,true)
      DisableControlAction(0,170,true)
      
      Citizen.Wait(1)
    end
  end)
end

RegisterNetEvent("vrp:setFreeze", function(...)
  tvRP.setFreeze(...)
end)


-- WEAPONS

-- def
local weapon_types = {
  "WEAPON_KNIFE",
  "WEAPON_STUNGUN",
  "WEAPON_FLASHLIGHT",
  "WEAPON_NIGHTSTICK",
  "WEAPON_HAMMER",
  "WEAPON_BAT",
  "WEAPON_GOLFCLUB",
  "WEAPON_CROWBAR",
  "WEAPON_PISTOL",
  "WEAPON_COMBATPISTOL",
  "WEAPON_APPISTOL",
  "WEAPON_PISTOL50",
  "WEAPON_MICROSMG",
  "WEAPON_SMG",
  "WEAPON_SMG_MK2",
  "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE",
  "WEAPON_ASSAULTRIFLE_MK2",
  "WEAPON_CARBINERIFLE",
  "WEAPON_ADVANCEDRIFLE",
  "WEAPON_MACHINEPISTOL",
  "WEAPON_PISTOL_MK2",
  "WEAPON_MG",
  "WEAPON_COMBATMG",
  "WEAPON_COMBATMG_MK2",
  "WEAPON_PUMPSHOTGUN",
  "WEAPON_PUMPSHOTGUN_MK2",
  "WEAPON_SAWNOFFSHOTGUN",
  "WEAPON_ASSAULTSHOTGUN",
  "WEAPON_BULLPUPSHOTGUN",
  "WEAPON_BULLPUPRIFLE",
  "WEAPON_SNIPERRIFLE",
  "WEAPON_HEAVYSHOTGUN",
  "WEAPON_HEAVYPISTOL",
  "WEAPON_HEAVYSNIPER",
  "WEAPON_HEAVYSNIPER_MK2",
  "WEAPON_PASSENGER_ROCKET",
  "WEAPON_AIRSTRIKE_ROCKET",
  "WEAPON_STINGER",
  "WEAPON_GRENADE",
  "WEAPON_STICKYBOMB",
  "WEAPON_SMOKEGRENADE",
  "WEAPON_BZGAS",
  "WEAPON_FIREEXTINGUISHER",
  "WEAPON_GADGET_PARACHUTE",
  "WEAPON_HAZARDCAN",
  "WEAPON_ASSAULTRIFLE_MK2",
  "WEAPON_FERTILIZERCAN",
  "WEAPON_PETROLCAN",
  "WEAPON_DIGISCANNER",
  "WEAPON_BRIEFCASE",
  "WEAPON_BRIEFCASE_02",
  "WEAPON_SPECIALCARBINE",
  "WEAPON_SPECIALCARBINE_MK2",
  "WEAPON_FLARE",
  "WEAPON_SWITCHBLADE",
  "WEAPON_MARKSMANRIFLE",
  "WEAPON_MARKSMANRIFLE_MK2",
  "WEAPON_MARKSMANPISTOL",
  "WEAPON_DOUBLEACTION",
  "WEAPON_NAVYREVOLVER",
  "WEAPON_GADGETPISTOL",
  "WEAPON_COMBATPDW",
  "WEAPON_FLAREGUN",
  "WEAPON_SNSPISTOL",
  "WEAPON_SNSPISTOL_MK2",
  "WEAPON_HATCHET",
  "WEAPON_MACHETE",
  "WEAPON_BATTLEAXE",
  "WEAPON_POOLCUE",
  "WEAPON_DAGGER",
  "WEAPON_BOTTLE",
  "WEAPON_KNUCKLE",
  "WEAPON_WRENCH",
  "WEAPON_STONE_HATCHET",
  "WEAPON_CANDYCANE",
  "WEAPON_VINTAGEPISTOL",
  "WEAPON_REVOLVER",
  "WEAPON_REVOLVER_MK2",
  "WEAPON_RAYPISTOL",
  "WEAPON_CERAMICPISTOL",
  "WEAPON_STUNGUN_MP",
  "WEAPON_PISTOLXM3",
  "WEAPON_MINISMG",
  "WEAPON_RAYCARBINE",
  "WEAPON_TECPISTOL",
  "WEAPON_MUSKET",
  "WEAPON_DBSHOTGUN",
  "WEAPON_AUTOSHOTGUN",
  "WEAPON_COMBATSHOTGUN",
  "WEAPON_CARBINERIFLE",
  "WEAPON_CARBINERIFLE_MK2",
  "WEAPON_BULLPUPRIFLE",
  "WEAPON_BULLPUPRIFLE_MK2",
  "WEAPON_COMPACTRIFLE",
  "WEAPON_MILITARYRIFLE",
  "WEAPON_HEAVYRIFLE",
  "WEAPON_TACTICALRIFLE",
  "WEAPON_GUSENBERG",
  "WEAPON_PRECISIONRIFLE",
  "WEAPON_RPG",
  "WEAPON_GRENADELAUNCHER",
  "WEAPON_GRENADELAUNCHER_SMOKE",
  "WEAPON_MINIGUN",
  "WEAPON_RAILGUN",
  "WEAPON_HOMINGLAUNCHER",
  "WEAPON_COMPACTLAUNCHER",
  "WEAPON_RAYMINIGUN",
  "WEAPON_EMPLAUNCHER",
  "WEAPON_RAILGUNXM3",
  "WEAPON_MOLOTOV",
  "WEAPON_PROXMINE",
  "WEAPON_SNOWBALL",
  "WEAPON_PIPEBOMB",
  "WEAPON_BALL",
  "WEAPON_ACIDPACKAGE",
  
  -- addon weapons
  "WEAPON_AK47",
  "WEAPON_DE",
  "WEAPON_FNX45",
  "WEAPON_M70",
  "WEAPON_M1911",
  "WEAPON_UZI",
  "WEAPON_MAC10",
  "WEAPON_MOSSBERG",
  "WEAPON_HK416",
  "WEAPON_KATANA",
  "WEAPON_SLEDGEHAMMER",
  "WEAPON_KNIFE",
  "WEAPON_STUNGUN",
  "WEAPON_GLOCK17",
  "WEAPON_M9",
  "WEAPON_M4",
  "WEAPON_SCARH",
  "WEAPON_AR15",
  "WEAPON_MK14",
  "WEAPON_REMINGTON",
}

exports("getWeaponTypes", function()
  return weapon_types
end)

function tvRP.getWeaponTypes()
  return weapon_types
end

function tvRP.getWeapons(slow)
  local player = GetPlayerPed(-1)

  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k,v in pairs(weapon_types) do
    if slow then
      Citizen.Wait(50)
    end
    local hash = GetHashKey(v)
    if HasPedGotWeapon(player,hash) then
      local weapon = {}
      weapons[v] = weapon

      local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
      if ammo_types[atype] == nil then
        ammo_types[atype] = true
        weapon.ammo = GetAmmoInPedWeapon(player,hash)
      else
        weapon.ammo = 0
      end
    end
  end

  return weapons or {}
end

function tvRP.giveWeapons(weapons,clear_before)
  local player = GetPlayerPed(-1)

  -- give weapons to player

  if clear_before then
    RemoveAllPedWeapons(player,true)
    canBeEmpty = true
  end

  for k,weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0
    if ammo >= 0 then
      GiveWeaponToPed(player, hash, ammo, false)
    end
  end
  
end

-- Player Customization

local function parse_part(key)
  if type(key) == "string" and string.sub(key,1,1) == "p" then
    return true,tonumber(string.sub(key,2))
  else
    return false,tonumber(key)
  end
end


function tvRP.getCustomization()
  local ped = tempPed

  local custom = {}

  custom.modelhash = GetEntityModel(ped)

  -- ped parts
  for i=0,20 do -- index limit to 20
    custom[i] = {GetPedDrawableVariation(ped,i), GetPedTextureVariation(ped,i), GetPedPaletteVariation(ped,i)}
  end

  -- props
  for i=0,10 do -- index limit to 10
    custom["p"..i] = {GetPedPropIndex(ped,i), math.max(GetPedPropTextureIndex(ped,i),0)}
  end

  return custom
end

-- partial customization (only what is set is changed)
function tvRP.setCustomization(custom) -- indexed [drawable,texture,palette] components or props (p0...) plus .modelhash or .model
  
  local exit = TUNNEL_DELAYED() -- delay the return values

  CreateThread(function() -- new thread
    if custom then
      local ped = tempPed
      local mhash = nil

      -- model
      if custom.modelhash ~= nil then
        mhash = custom.modelhash
      elseif custom.model ~= nil then
        mhash = GetHashKey(custom.model)
      end

      if mhash ~= nil then
        local i = 0
        while not HasModelLoaded(mhash) and i < 10000 do
          RequestModel(mhash)
          Citizen.Wait(10)
        end

        if HasModelLoaded(mhash) then
          SetPlayerModel(PlayerId(), mhash)
          SetModelAsNoLongerNeeded(mhash)
        end
      end

      ped = tempPed

      -- parts
      for k,v in pairs(custom) do
        if k ~= "model" and k ~= "modelhash" then
          local isprop, index = parse_part(k)
          if isprop then
            if v[1] < 0 then
              ClearPedProp(ped,index)
            else
              SetPedPropIndex(ped,index,v[1],v[2],v[3] or 2)
            end
          else
            SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
          end
        end
      end
    end

    exit({})
  end)
end


function tvRP.getClothes(onlyClothes)
  return exports['raid_clothes']:getClothes(onlyClothes)
end

function tvRP.setClothes(data, onlyClothes)
  exports['raid_clothes']:setClothes(data, onlyClothes)
end
