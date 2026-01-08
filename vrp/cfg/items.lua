local cfg = {}
cfg.items = {
  ["phone"] = {
    name = "Telefon mobil",
    description = "Telefon mobil conectat la reteaua mobila ArmyLegends",
    category = 'electronics',
    useItem = function(player)
      vRPclient.executeCommand(player, {"phone"})
    end,
    weight = 0.2,
  },

  ["id_doc"] = {
    name = "Buletin",
    description = "Carte de identitate unicata",
    category = 'licences',
    useItem = function(player)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getNearestPlayer(player, {3}, function(nPlayer)
          if nPlayer then            
            TriggerClientEvent("vrp-identity:startBadgeAnim", player, "buletin")
            Citizen.Wait(300)

            vRP.getUserIdentity(user_id, function(userIdentity)
              if userIdentity then
                TriggerClientEvent("vRP:showBuletin", nPlayer, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                  target = player,
                  age = userIdentity.age,
                  usr_id = user_id,
                  adresa = "Str.  Nr. ",
                })

                TriggerClientEvent("vRP:showBuletin", player, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                  age = userIdentity.age,
                  usr_id = user_id,
                  adresa = "Str.  Nr. ",
                })
              end
            end)
          else
            vRP.getUserIdentity(user_id, function(userIdentity)
              if userIdentity then
                TriggerClientEvent("vRP:showBuletin", player, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                  age = userIdentity.age,
                  usr_id = user_id,
                  adresa = "Str.  Nr. ",
                })
              end
            end)
          end
        end)
      end
    end,
    weight = 0.05,
  },

  ["auto_doc"] = {
    name = "Permis Auto",
    description = "Permis de conducere a autovehiculelor",
    category = 'licences',
    useItem = function(player)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getNearestPlayer(player, {3}, function(nPlayer)
          if nPlayer then            
            TriggerClientEvent("vrp-identity:startBadgeAnim", player, "permis")
            Citizen.Wait(300)

            vRP.getUserIdentity(user_id, function(userIdentity)
              if userIdentity then
                TriggerClientEvent("vRP:showPermis", nPlayer, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                  target = player,
                })

                TriggerClientEvent("vRP:showPermis", player, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                })
              end
            end)
          else
            vRP.getUserIdentity(user_id, function(userIdentity)
              if userIdentity then
                TriggerClientEvent("vRP:showPermis", player, {
                  nume = userIdentity.firstname,
                  prenume = userIdentity.name,
                })
              end
            end)
          end
        end)
      end
    end,
    weight = 0.05,
  },

  ["body_armor"] = {
    name = "🔰 Vesta Anti-Glont",
    description = "Vesta Anti-Glont pentru o viata mai sigura.",
    category = 'weapons',
    useItem = function(player)
      local user_id = vRP.getUserId(player)

      if vRP.removeItem(user_id, 'body_armor') then
        TriggerClientEvent("vrp:progressBar", player, {
          duration = 5000,
          text = "Echipezi 🔰 Vesta Anti-Glont..",
        })
        
        vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
        Citizen.Wait(5000)
        vRPclient.setArmour(player,{100,false})
      end
    end,
    weight = 10.0,
  },

  ["fuelcan"] = {
    name = "Canistra cu Benzina",
    description = "Canistra plina cu benzina.",
    category = 'others',
    useItem = function(player)
      local user_id = vRP.getUserId(player)

      if vRP.removeItem(user_id, 'fuelcan') then
        TriggerClientEvent("vRP:useCanistra", player)
      end
      
    end,
    weight = 0.8,
  },

  ["conserva"] = {
    name = "Conserva",
    description = "Aceasta se poate recicla si se gaseste in gunoaie",
    category = 'others',
    useItem = function(player)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.varyHealth(player, {-5})
        vRPclient.notify(player, {"Ai gasit un sobolan mort...", "warning"})
      end
    end,
    weight = 0.1,
  },

  ["petdeplastic"] = {
    name = "Pet de plastic",
    description = "Acesta se poate recicla si se gaseste in gunoaie",
    useItem = function(player)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.varyHealth(player, {-5})
        vRPclient.notify(player, {"Ai gasit un sobolan mort...", "error"})
      end
    end,
    weight = 0.1,
  },

  ["radio"] = {
    name = "Statie Radio",
    description = "Folosita pentru comunicare cu alti oameni, prin intermediul antenelor radio.",
    category = 'electronics',
    useItem = function(player)
      TriggerClientEvent("vrp-radio:useItem", player)
    end,
    weight = 0.1,
  },
  
  ["dirty_money"] = {
    name = "Dirty money", 
    description = "Bani castigati ilegal",
    category = 'others',
    weight = 0.00001,
  },

  ["lockpick"] = {
    name = "Set de unelte", 
    description = "Set de unelte folosit la inchuietori.",
    category = 'others',
    maxUsage = 30,
    weight = 2,
  },

  ["momeala"] = {
    name = "Momeala", 
    description = "Momeala de pescuit",
    category = 'others',
    weight = 0.5,
  },

  ["proximity_mine"] = {
    name = "Bomba Termica", 
    description = "Bomba Termica folosita la jafuri.",
    category = 'others',
    weight = 0.3,
  },

  ["hacking_device"] = {
    name = "Laptop Hacking", 
    description = "Laptop pentru hackuit folosit la jafuri.",
    category = 'others',
    weight = 2,
  },

  ["petrol_nerafinat"] = {
    name = "Petrol Nerafinat", 
    description = "Petrol Nerafinat folosit in statile de combustibil.",
    category = 'others',
    weight = 0.1
  },

  ["torchkit"] = {
    name = "Kit de sudat", 
    description = "Kit de sudat care poate fi folosit la reparatii si multe altele.",
    category = 'others',
    weight = 1
  }
}

-- load more items function
local function load_item_pack(name)
  local items = module("cfg/item/"..name)
  if items then
    for k,v in pairs(items) do
      cfg.items[k] = v
    end
  else
    print(("^5Modules/Items: ^7Item pack ^5%s ^7does not exist!"):format(name))
  end
end

-- Packuri de iteme
load_item_pack("required")
load_item_pack("mancare")
load_item_pack("weapon_utils")
load_item_pack("ghiozdane")
load_item_pack('ammo')


return cfg
