local items = {}
local inEating = {}

local function gen(player, item, slot, ftype, vary_hunger, vary_thirst, onUse)
  local user_id = vRP.getUserId(player)
  local inventory = vRP.getUserInventory(user_id)

  if (inEating[user_id] or 0) > os.time() then
      return  vRPclient.notify(player, {"Trebuie sa astepti "..inEating[user_id] - os.time().." secunde inainte sa poti efectua aceasta actiune!", "error"})
  end

  if inventory[slot] and inventory[slot].item == item then
      local extraData = inventory[slot].extraData or {}


      if item == 'redbull' then
        exports.vrp:achieve(user_id, 'RedbullEasy', 1)
      elseif item == 'cafea' then
        exports.vrp:achieve(user_id, 'cafeaEasy', 1)
      elseif item == 'cola' then
        exports.vrp:achieve(user_id, 'ColaEasy', 1)
      elseif item == 'shaorma' then
        exports.vrp:achieve(user_id, 'ShaormaEasy', 1)
      end
    

      inEating[user_id] = os.time() + 10

      if parseInt(extraData.expire) > os.time() then
          vRP.varyThirst(user_id, vary_thirst > 0 and vary_thirst or 0)
          vRP.varyHunger(user_id, vary_hunger > 0 and vary_hunger or 0)

          if ftype == "drink" then
              TriggerClientEvent("vrp:progressBar", player, {
                  duration = 4000,
                  text = "🥤 Bei "..vRP.getItemName(item),
              })

              vRPclient.playAnim(player,{true,{
                  {"mp_player_intdrink","intro_bottle",1},
                  {"mp_player_intdrink","loop_bottle",1},
                  {"mp_player_intdrink","outro_bottle",1}
              },false})
          else
              vRP.addThirst(user_id, math.random(15, 25))
              TriggerClientEvent("vrp:progressBar", player, {
                  duration = 4000,
                  text = "🍴 Mananci "..vRP.getItemName(item),
              })

              vRPclient.playAnim(player,{true,{
                  {"mp_player_inteat@burger", "mp_player_int_eat_burger_enter",1},
                  {"mp_player_inteat@burger", "mp_player_int_eat_burger",1},
                  {"mp_player_inteat@burger", "mp_player_int_eat_burger_fp",1},
                  {"mp_player_inteat@burger", "mp_player_int_eat_exit_burger",1}
              },false})
          end
      elseif ftype ~= "drink" then
        TriggerClientEvent("vrp-hud:hint", player, "Ai mancat mancare expirata! Este posibil sa faci Toxinfectie Alimentara!", "Mancare Expirata", "fa-regular fo-pot-food")
        vRP.addFoodPoising(user_id, player)
      end

      if onUse then
          onUse(player, user_id)
      end

      inventory[slot] = nil;
  end
end


-- ==================== --
--        BAUTURI       --
-- ==================== --

items["water"] = {
  name = "Apa",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'water',slot,"drink",0,40)
  end,
  weight = 0.5
}

items["cola"] = {
  name = "Coca-Cola",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'cola',slot,"drink",0,30)
  end,
  weight = 0.3,
}

items["redbull"] = {
  name = "RedBull",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'redbull',slot,"drink",0,20,function(player, user_id)
      TriggerClientEvent("vRP:useRedbullOrCoffee", player)
    end)
  end,
  weight = 0.3,
}

items["lipton"] = {
  name = "Lipton",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'lipton',slot,"drink",0,35)
  end,
  weight = 0.3
}

items["vodka"] = {
  name = "Sticla Vodka",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'vodka',slot,"drink",0,40)
  end,
  weight = 0.7
}

items["bere"] = {
  name = "Bere",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'bere',slot,"drink",0,25)
  end,
  weight = 0.3,
}

items["fanta"] = {
  name = "Fanta",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'fanta',slot,"drink",0,30)
  end,
  weight = 0.3,
}

items["cafea"] = {
  name = "Cafea",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'cafea',slot,"drink",0,20,function(player, user_id)
      TriggerClientEvent("vRP:useRedbullOrCoffee", player)
    end)
  end,
  weight = 0.2,
}

items["lapte"] = {
  name = "Lapte",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'lapte',slot,"drink",0,40)
  end,
  weight = 1,
}

items["milkshake"] = {
  name = "Milkshake",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'milkshake',slot,"drink",0,35)
  end,
  weight = 0.5,
}

items["bloody_mary"] = {
  name = "Bloody Mary",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'bloody_mary',slot,"drink",0,40)
  end,
  weight = 0.5,
}

items["sticla_sampanie"] = {
  name = "Sticla Sampanie",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'sticla_sampanie',slot,"drink",0,100)
  end,
}

items["pahar_sampanie"] = {
  name = "Pahar Sampanie",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pahar_sampanie',slot,"drink",0,20)
  end,
}

items["sticla_whiskey"] = {
  name = "Sticla Whiskey",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'sticla_whiskey',slot,"drink",0,100)
  end,
}

items["pahar_whiskey"] = {
  name = "Pahar Whiskey",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pahar_whiskey',slot,"drink",0,20)
  end,
}

items["sticla_tequila"] = {
  name = "Sticla Tequila",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'sticla_tequila',slot,"drink",0,100)
  end,
}

items["shot_tequila"] = {
  name = "Shot Tequila",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'shot_tequila',slot,"drink",0,20)
  end,
}

items["sticla_vin"] = {
  name = "Sticla Vin",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'sticla_vin',slot,"drink",0,100)
  end,
}

items["pahar_vin"] = {
  name = "Pahar Vin",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pahar_vin',slot,"drink",0,20)
  end,
}

items["pina-colada"] = {
  name = "Pina-Colada",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pina-colada',slot,"drink",0,40)
  end,
}

items["martini"] = {
  name = "Martini",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'martini',slot,"drink",0,40)
  end,
}
-- ==================== --
--        MANCARE       --
-- ==================== --

items["shaorma"] = {
  name = "Shaorma",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'shaorma',slot,"eat",60,0)
  end,
  weight = 0.7,
}

items["pepene_rosu"] = {
  name = "Pepene Rosu",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pepene_rosu',slot,"eat",30,20)
  end,
  weight = 0.3,
}

items["pleskavita"] = {
  name = "Pleskavita Banateana",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pleskavita',slot,"eat",60,0)
  end,
  weight = 0.5,
}

items["gogoasa_ciocolata"] = {
  name = "Gogoasa cu Ciocolata",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'gogoasa_ciocolata',slot,"eat",50,0)
  end,
  weight = 0.2,
}

items["gogoasa_capsuni"] = {
  name = "Gogoasa cu Capsuni",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'gogoasa_capsuni',slot,"eat",50,0)
  end,
  weight = 0.2,
}

items["chipsuri_lays"] = {
  name = "Chipsuri Lays",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'chipsuri_lays',slot,"eat",30,0)
  end,
  weight = 0.5,
}

items["tacos"] = {
  name = "Taco",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'tacos',slot,"eat",30,0)
  end,
  weight = 0.2,
}

items["burger"] = {
  name = "Burger",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'burger',slot,"eat",45,0)
  end,
  weight = 0.5,
}

items["burrito"] = {
  name = "Burrito",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'burrito',slot,"eat",35,0)
  end,
  weight = 0.5,
}

items["sandvis"] = {
  name = "Sandwich",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'sandvis',slot,"eat",25,0)
  end,
  weight = 0.3,
}

items["cookie"] = {
  name = "Cookie cu Ciocolata",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'cookie',slot,"eat",20,0)
  end,
  weight = 0.2,
}

items["hotdog"] = {
  name = "Hotdog",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'hotdog',slot,"eat",30,0)
  end,
  weight = 0.5,
}

items["briosa"] = {
  name = "Briosa",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'briosa',slot,"eat",20,0)
  end,
  weight = 0.2,
}

items["pizza"] = {
  name = "Pizza",
  description = "",
  category = 'food',
  isUnique = true,
  useItem = function(player, slot)
    gen(player,'pizza',slot,"eat",50,0)
  end,
  weight = 0.3,
}

return items
