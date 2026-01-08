local cfg = module('cfg/inventory')
local openedChests = {}

vRP.items = {}

local ammo <const> = {
   ['ammo_45acp_pd'] = true,
   ['ammo_556_pd'] = true,
   ['ammo_762_pd'] = true,
   ['ammo_9mm_pd'] = true,
   ['ammo_45acp'] = true,
   ['ammo_556'] = true,
   ['ammo_762'] = true,
   ['ammo_9mm'] = true,
}

AddEventHandler('vRP:playerLeave', function(user_id, player)
   for chest, user_id in pairs(openedChests) do
      if user_id == user_id then
         openedChests[chest] = nil
      end
   end
end)


AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, data)
   if not first_spawn then return end
   
   if not vRP.usersData[user_id].inventory then
       vRP.usersData[user_id].inventory = {}
   else
       local tempInventory = {}
       for _, data in pairs(vRP.usersData[user_id].inventory) do
         if data.item and vRP.items[data.item] then
            if data.amount > 0 then
               tempInventory[data.slot] = data
            end
         else
            print("[vRP] ERROR: "..(data.item or 'Necunoscut')..' is not defined in items.lua!, removing from inventory of '..user_id..'!')
         end
       end
       vRP.usersData[user_id].inventory = tempInventory
   end

   local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)
   TriggerClientEvent('vrp-inventory:setInventoryData', player, vRP.usersData[user_id].inventory, maxWeight)

   Citizen.Wait(5000)

   if vRP.usersData[user_id].activeBag then
      TriggerClientEvent('vrp-inventory:updateBackpack', player, vRP.usersData[user_id].activeBag)
   end
end)

-- AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn)
--    if not first_spawn then return end;
--    Citizen.Wait(5000)

--    if vRP.usersData[user_id].activeBag then
--       TriggerClientEvent('vrp-inventory:updateBackpack', player, vRP.usersData[user_id].activeBag)
--    end
-- end)

Citizen.CreateThread(function()
   for item, data in pairs(cfg.weapons) do
      vRP.defInventoryItem(item, data.name, data.description or 'Acest item nu are o descriere', clothes_choice, 1.0, 'weapons', true)
   end
end)

local function clothes_choice() end;
Citizen.CreateThread(function()
   local theItems = module("cfg/items")
 
   for item, itemData in pairs(theItems.items) do
     vRP.defInventoryItem(item, itemData.name, itemData.description, itemData.useItem, itemData.weight, itemData.category, itemData.isUnique, itemData.maxUsage)
   end
end)

function cloneTable(originalTable)
   local jsonStr = json.encode(originalTable)
   local copiedTable = json.decode(jsonStr)
   return copiedTable
end

function vRP.getUserInventory(user_id)
  return vRP.usersData[user_id].inventory
end

function vRP.getItemsByType(user_id, category)
   local inventory = vRP.getUserInventory(user_id)
   local items = {}

   for slot, data in pairs(inventory) do
      if vRP.items[data.item].category == category then
         table.insert(items, data)
      end
   end

   return items
end

function vRP.clearInventory(user_id)
   local inventory = vRP.getUserInventory(user_id)
   local player = vRP.getUserSource(user_id)
   
   for slot, data in pairs(inventory) do
      if not vRP.items[data.item] then
         return print("ERROR: Itemul " .. data.item .. " nu este inregistrat!")
      end

      local category = vRP.items[data.item].category

      if inventory[slot] then
         print('item found ', data.item)
      end

      if not (category == 'licences') or not (category == 'premium') then
         inventory[slot] = nil
      end
   end

   -- print(json.encode(inventory))

   vRP.createLog(user_id, nil, "ClearInventory")
   TriggerClientEvent('vrp-inventory:cleanSlots', player)
   vRP.saveInventory(user_id)
end

local perchezitieActiva = {}
function vRP.openOtherPlayerInventory(player, user_id)
   vRPclient.getNearestPlayer(player, {15}, function(target)
      if not target then
         return vRPclient.notify(player, {'Nu exista jucatori in apropiere!', 'error'})
      end

      vRP.request(target, 'Doresti sa permiti o perchezitie?', false, function(target, ok)
         if not ok then
            return vRPclient.notify(player, {'Jucatorul a refuzat perchezitia!', 'error'})
         end
         local target_id = vRP.getUserId(target)

         Player(player).state.lockedInventory = true
         if vRP.usersData[target_id].lockedInventory then
            return vRPclient.notify(player, {'Cineva acceseaza deja acest inventar!', 'error'})
         end 

         local inventory = vRP.getUserInventory(target_id)
         local maxWeight, maxSlots = vRP.getInventoryMaxData(target_id)
         vRP.usersData[target_id].lockedInventory = true

         perchezitieActiva[user_id] = target_id
         
         TriggerClientEvent('vrp-inventory:openChest', player, {
            name = 'Inventarul lui ' .. GetPlayerName(target),
            type = 'player-inv',
            chestData = {
                key = target_id,
            },
            maxWeight = maxWeight,
            items = inventory,
         })
      end)
   end)
end

function vRP.openChest(player, chest, maxWeight, name)
   local user_id = vRP.getUserId(player)

   if openedChests[chest] then
      return vRPclient.notify(player, {'Acest chest este deja folosit de catre cineva!', 'error'})
   end

   vRP.getSData(chest, function(chestDecoded)
      openedChests[chest] = user_id

      local tempInventory = {}
      for slot, data in pairs(chestDecoded or {}) do
         tempInventory[data.slot] = data
      end

      TriggerClientEvent('vrp-inventory:openChest', player, {
         name = name,
         type = 'chest',
         chestData = {
             key = chest,
         },
         maxWeight = maxWeight,
         items = chestDecoded
      })
   end)
end

function vRP.getVehicleTrunk(user_id, vname)
   if not vRP.usersData[user_id].userVehicles[vname].trunk then
       vRP.usersData[user_id].userVehicles[vname].trunk = {}
   end

   local newItems = {}
   for slot, data in pairs(vRP.usersData[user_id].userVehicles[vname].trunk) do
       if data.amount > 0 then
           newItems[parseInt(data.slot)] = data
       end
   end vRP.usersData[user_id].userVehicles[vname].trunk = newItems

   return vRP.usersData[user_id].userVehicles[vname].trunk
end

function vRP.getVehicleGlovebox(user_id, vname)
   if not vRP.usersData[user_id].userVehicles[vname].glovebox then
       vRP.usersData[user_id].userVehicles[vname].glovebox = {}
   end

   local newItems = {}
   for slot, data in pairs(vRP.usersData[user_id].userVehicles[vname].glovebox) do
       if data.amount > 0 then
           newItems[parseInt(data.slot)] = data
       end
   end vRP.usersData[user_id].userVehicles[vname].glovebox = newItems

   return vRP.usersData[user_id].userVehicles[vname].glovebox
end

function vRP.getInventoryMaxData(user_id)
   local space = vRP.usersData[user_id].activeBag?.space and vRP.getUserSpaceFromStrength(user_id) or 5;
   local value = (vRP.isUserInFaction(user_id, 'Politie') or vRP.isUserInFaction(user_id, 'Smurd')) and 50 or 0

   space += (vRP.usersData[user_id].activeBag?.space or 0) + value

   return math.floor(space), 41
end

local function getSlotByItem(inventory, item)
   for slot, data in pairs(inventory) do
      if data.item == item then
         return slot
      end
   end

   return false
end

local function getUserFreeSlot(user_id)
   local inventory = vRP.getUserInventory(user_id)
   local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)
   local from, to = 12, maxSlots

   if not vRP.hasBag(user_id) then
       from, to = 1, 6
   end

   ::slotCheck::
   for i = from, to do
      if inventory[i] == nil then
         return i
      end

      if i == maxSlots then
         from, to = 1, 6
         goto slotCheck
      end
   end
      
   return false
end

function vRP.defInventoryItem(idname, name, description, onUse, weight, category, isUnique, maxUsage)
   weight = weight or 0
   category = category or 'pocket'
 
   if not vRP.items[idname] then
      vRP.items[idname] = {
         name = name,
         description = description,
         useItem = onUse,
         weight = weight,
         category = category,
         isUnique = isUnique,
         maxUsage = maxUsage or 100
      }
   end
end

local function getItemsTotalWeight(user_id)
  local inventory = vRP.getUserInventory(user_id)
  local totalWeight = 0

  for slot, data in pairs(inventory) do
   if vRP.items[data.item] then
      totalWeight = totalWeight + (vRP.items[data.item].weight * data.amount)
   end
  end

  return totalWeight
end

local function saveInventory(user_id)
  local inventory = vRP.getUserInventory(user_id)
  local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)

  exports.mongodb:updateOne({collection = 'users', query = {id = user_id}, update = {["$set"] = {inventory = inventory or false}}})
  TriggerClientEvent('vrp-inventory:setInventoryData', vRP.getUserSource(user_id), inventory, maxWeight)
end vRP.saveInventory = saveInventory

function vRP.useInventoryItem(player, item, slot)
   if vRP.items[item] and vRP.items[item].useItem then

      vRP.createLog(user_id, {item = item, item_name = vRP.getItemName(item), amount = 1}, "UseItem")

      vRP.items[item].useItem(player, slot)
   end
end

function vRP.getItemName(item)
   return vRP.items[item] and vRP.items[item].name or 'Unknown'
end

function vRP.getInventoryItemAmount(user_id, item)
   local amount = 0
   local inventory = vRP.getUserInventory(user_id)
   for slot, data in pairs(inventory) do
      if data.item == item then
         amount += data.amount
      end
   end

   return amount
end

function vRP.canCarryItem(user_id, item, amount, customWeight)
   if not item or not amount then
      return false
   end

   local totalWeight = getItemsTotalWeight(user_id)
   local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)
   local itemWeight = customWeight or vRP.items[item].weight * amount

   local freeSlot = getUserFreeSlot(user_id)
   
   if not freeSlot then
      local player = vRP.getUserSource(user_id)

      if player then
         vRPclient.notify(player, {'Nu mai ai sloturi libere in inventar!', 'error'})
      end

      return false
   end

   return (totalWeight + (itemWeight or 0)) <= maxWeight
end

function vRP.removeItemByCategory(user_id, category)
   local inventory = vRP.getUserInventory(user_id)

   for slot, data in pairs(inventory) do
      if not vRP.items[data.item] then
         return print("ERROR: Itemul " .. data.item .. " nu este inregistrat!")
      end

      if vRP.items[data.item].category == category then
         inventory[slot] = nil
      end
   end

   saveInventory(user_id)
end

function vRP.removeItem(user_id, item, amount, extraData)
   local inventory = vRP.getUserInventory(user_id)
   local slot = getSlotByItem(inventory, item)
   amount = amount or 1

   if slot and inventory[slot].item == item and not vRP.items[item].isUnique then
      if inventory[slot].amount == amount then
         inventory[slot] = nil
         saveInventory(user_id)
         return true
      end

      if inventory[slot].amount > amount then
         inventory[slot].amount -= amount
         saveInventory(user_id)
         return true
      end

   elseif vRP.items[item].isUnique then
      local itemAmount = 0
      local hasItem = false

      for slot, data in pairs(inventory) do
         if extraData and extraData.weight then
            if data.item == item and data.weight == extraData.weight then
               hasItem = true
               itemAmount += data.amount
            end
         else
            if data.item == item then
               hasItem = true
               itemAmount += data.amount
            end
         end
      end

      if hasItem and itemAmount >= amount then
         for slot, data in pairs(inventory) do
            if extraData and extraData.weight then
               if data.item == item and data.weight == extraData.weight then
                  itemAmount -= data.amount
                  inventory[slot] = nil
               end
            else
               if data.item == item then
                  itemAmount -= data.amount
                  inventory[slot] = nil
               end
            end

            if hasItem and itemAmount <= 0 then
               saveInventory(user_id)
               return true
            end
         end   
      end
   end

   return false
end

function vRP.damageItem(user_id, item, damage)
   if not vRP.items[item] then
      return print("[vRP] Itemul " .. item .. " nu este inregistrat!")
   end

   if not vRP.items[item].isUnique or not vRP.items[item].maxUsage then
      return print("[vRP] Itemul " .. item .. " nu este un item unique sau nu are maxUsage!")
   end

   local inventory = vRP.getUserInventory(user_id)
   local slot = getSlotByItem(inventory, item)

   if inventory[slot] and inventory[slot].item then
      if not inventory[slot].currentUsage then
         inventory[slot].currentUsage = 0
      end

      inventory[slot].currentUsage += damage

      if inventory[slot].currentUsage >= inventory[slot].maxUsage then
         inventory[slot] = nil

         local name = inventory[slot].name
         local player = vRP.getUserSource(user_id)
         if player then
            TriggerClientEvent("vrp-hud:hint",player, name..' tocmai s-a stricat!', "Item spart", "fa-solid fa-wand-magic-sparkles")
         end
         return saveInventory(user_id)
      end

      local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)
      TriggerClientEvent('vrp-inventory:setInventoryData', vRP.getUserSource(user_id), inventory, maxWeight)

      return true
   end

   return false
end

function vRP.hasBag(user_id)
   return vRP.usersData[user_id] and vRP.usersData[user_id].activeBag or false
end

function vRP.hasItem(user_id, item, amount)
   local inventory = vRP.getUserInventory(user_id)
   local slot = getSlotByItem(inventory, item)
   local hasItem = false
   amount = amount or 1

   if slot and inventory[slot] and not vRP.items[item].isUnique then
      if inventory[slot].amount >= amount then
         return true, slot
      end

   elseif vRP.items[item].isUnique then
      local itemAmount = 0
      for slot, data in pairs(inventory) do
         if data.item == item then
            itemAmount += data.amount
            hasItem = true
         end

         if hasItem and itemAmount >= amount then
            return true, slot
         end
      end
   end

   return false, nil
end

function vRP.forceRemoveItem(user_id, item)
   local inventory = vRP.getUserInventory(user_id)

   for slot, data in pairs(inventory) do
      if data.item == item then
         inventory[slot] = nil
      end
   end
   saveInventory(user_id)
end

function vRP.getChestData(chest)
   local chestDecoded = vRP.requestSData(chest)
   local tempInventory = {}

   for slot, data in pairs(chestDecoded or {}) do
      tempInventory[data.slot] = data
   end

   return tempInventory
end

-- ToDo: Add from to all items
function vRP.giveItem(user_id, item, amount, slot, extraData, notify, from)
   local inventory = vRP.getUserInventory(user_id)
   amount = tonumber(amount) or 1
   slot = tonumber(slot) or getSlotByItem(inventory, item) or nil
   local hasBag = vRP.hasBag(user_id)
   local player = vRP.getUserSource(user_id)

   local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)
   local totalWeight = getItemsTotalWeight(user_id)

    if not vRP.items[item] then
       print("[vRP] Item "..item.." has got no definition.")
       return false
    end

    local itemWeight = (extraData and extraData.weight) or vRP.items[item].weight * amount

   if (totalWeight + (itemWeight or 0)) > maxWeight then
      vRPclient.notify(player, {'Nu mai ai spatiu in inventar!', 'error'})
      return false
   end

   if (slot and inventory[slot]) and (inventory[slot].item == item) and not vRP.items[item].isUnique then
      inventory[slot].amount += amount

      -- Ammo Check
      if ammo[item] then
         TriggerClientEvent('vrp-inventory:updateBullets', player, item, inventory[slot].amount)
      end

      if from then
         vRP.createLog(user_id, {
            item = item,
            amount = amount,
            item_name = vRP.items[item].name,
            from = from,
         }, 'ReceiveItem')
      end

      TriggerClientEvent('vrp:sendNuiMessage', player, {
         interface = 'inventory',
         act = 'notify',
         time = 5000,
         item = item,
         name = vRP.items[item].name,
         amount = amount,
      })
      
      saveInventory(user_id)
      return true
   elseif (slot and inventory[slot] == nil) then
      if not vRP.items[item].isUnique and not type(extraData) == 'table' then
         inventory[slot] = {
            item = item,
            amount = amount,
            slot = slot,
            isUnique = vRP.items[item].isUnique,
            label = vRP.items[item].name,
            description = ((vRP.items[item].description or ""):len() > 2 and vRP.items[item].description) or "Acest item nu detine o descriere",
            weight = (vRP.items[item].weight > 0 and vRP.items[item].weight) or vRP.items[item].weight or 0.00,
         }
         TriggerClientEvent('vrp:sendNuiMessage', player, {
            interface = 'inventory',
            act = 'notify',
            time = 5000,
            item = item,
            name = vRP.items[item].name,
            amount = amount,
         })

         if from then
            vRP.createLog(user_id, {
               item = item,
               amount = amount,
               item_name = vRP.items[item].name,
               from = from,
            }, 'ReceiveItem')
         end
      else
         inventory[slot] = {
            item = item,
            amount = 1,
            slot = slot,
            isUnique = true,
            currentUsage = 0,
            maxUsage = vRP.items[item].maxUsage or 100,
            label = vRP.items[item].name,
            description = ((vRP.items[item].description or ""):len() > 2 and vRP.items[item].description) or "Acest item nu detine o descriere",
            weight = extraData and extraData.weight or (vRP.items[item].weight > 0 and vRP.items[item].weight) or 0.00,
            extraData = extraData or {}
         }
 
         if amount > 1 then
            vRP.giveItem(user_id, item, amount -1, false, extraData, false, false, from)
         end

         if from then
            vRP.createLog(user_id, {
               item = item,
               amount = amount,
               item_name = vRP.items[item].name,
               from = from,
            }, 'ReceiveItem')
         end
      
         TriggerClientEvent('vrp:sendNuiMessage', player, {
            interface = 'inventory',
            act = 'notify',
            time = 5000,
            item = item,
            name = vRP.items[item].name,
            amount = 1,
         })
      end
      
      saveInventory(user_id)
      return true
   elseif (vRP.items[item].isUnique) or (not slot or slot == nil) or vRP.items[item].type == 'weapon' then
      local from, to = 12, maxSlots
      if not hasBag then
          from, to = 1, 6
      end
 
      ::slotCheck::
      for i = from, to do
         if inventory[i] == nil then
            if vRP.items[item].isUnique then
               inventory[i] = {
                  item = item,
                  slot = i,
                  isUnique = true,
                  currentUsage = 0,
                  maxUsage = vRP.items[item].maxUsage or 100,
                  amount = 1,
                  label = vRP.items[item].name,
                  description = ((vRP.items[item].description or ""):len() > 2 and vRP.items[item].description) or "Acest item nu detine o descriere",
                  weight = extraData and extraData.weight or (vRP.items[item].weight > 0 and vRP.items[item].weight) or 0.00,
                  extraData = extraData or {}
               }
 
               if amount > 1 then
                  vRP.giveItem(user_id, item, amount -1, false, extraData, false, false, from)
               end
               TriggerClientEvent('vrp:sendNuiMessage', player, {
                  interface = 'inventory',
                  act = 'notify',
                  time = 5000,
                  item = item,
                  name = vRP.items[item].name,
                  amount = 1,
               })

               if from then
                  vRP.createLog(user_id, {
                     item = item,
                     amount = amount,
                     item_name = vRP.items[item].name,
                     from = from,
                  }, 'ReceiveItem')
               end

               saveInventory(user_id)
               return true 
            else
               inventory[i] = {
                  item = item,
                  slot = i,
                  isUnique = vRP.items[item].isUnique,
                  amount = amount,
                  label = vRP.items[item].name,
                  description = ((vRP.items[item].description or ""):len() > 2 and vRP.items[item].description) or "Acest item nu detine o descriere",
                  weight = (vRP.items[item].weight > 0 and vRP.items[item].weight) or vRP.items[item].weight or 0.00,
                  extraData = extraData or {}
               }

               -- Ammo Check
               if ammo[item] then
                  TriggerClientEvent('vrp-inventory:updateBullets', player, item, amount)
               end
            end

            if from then
               vRP.createLog(user_id, {
                  item = item,
                  amount = amount,
                  item_name = vRP.items[item].name,
                  from = from,
               }, 'ReceiveItem')
            end

            TriggerClientEvent('vrp:sendNuiMessage', player, {
               interface = 'inventory',
               act = 'notify',
               time = 5000,
               item = item,
               name = vRP.items[item].name,
               amount = amount,
            })
            saveInventory(user_id)
            return true
         end
 
         if i == maxSlots then
            from, to = 1, 6
            goto slotCheck
         end
      end

      if notify then
         vRPclient.notify(player, {'Nu mai ai loc in inventar!', 'error'})
      end
      return false
   end
 end

 RegisterServerEvent('vrp-inventory:moveItem', function(data)
   local player = source
   local user_id = vRP.getUserId(player)
   local inventory = vRP.getUserInventory(user_id)

   local fromSlot = parseInt(data.fromSlot)
   local toSlot = parseInt(data.toSlot)
   local maxWeight, maxSlots = vRP.getInventoryMaxData(user_id)

   if not getUserFreeSlot(user_id) then
      vRPclient.notify(player, {"Nu mai ai slot-uri libere", "error"})
   end

   if (data.from == data.to) or (data.from == 'backpack' and data.to == 'pocket') or (data.from == 'pocket' and data.to == 'backpack') then
       if (data.from == data.to) and (data.from == 'glovebox') then
            local chestData = data.chestData
            local vehicle = chestData.vehicle
            local vehGlovebox = vRP.getVehicleGlovebox(user_id, vehicle)

           if (data.itemTo) then
               local tempData = cloneTable(vehGlovebox[toSlot])

               vehGlovebox[toSlot] = cloneTable(vehGlovebox[data.fromSlot])
               vehGlovebox[toSlot].slot = toSlot

               vehGlovebox[fromSlot] = tempData
               vehGlovebox[fromSlot].slot = fromSlot
           else
               if not vehGlovebox[toSlot] then
                   vehGlovebox[toSlot] = {}
               end
               vehGlovebox[toSlot] = cloneTable(inventory[data.fromSlot])
               vehGlovebox[toSlot].slot = toSlot

               vehGlovebox[fromSlot] = nil
           end
           TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehGlovebox)
       elseif (data.from == data.to) and (data.from == 'trunk') then
         local chestData = data.chestData
         local vehicle = chestData.vehicle
         local vehTrunk = vRP.getVehicleTrunk(user_id, vehicle)
         
         if (data.itemTo) then
            local tempData = cloneTable(vehTrunk[toSlot])

            vehTrunk[toSlot] = cloneTable(vehTrunk[data.fromSlot])
            vehTrunk[toSlot].slot = toSlot

            vehTrunk[fromSlot] = tempData
            vehTrunk[fromSlot].slot = fromSlot
         else
            if not vehTrunk[toSlot] then
                  vehTrunk[toSlot] = {}
            end
            vehTrunk[toSlot] = cloneTable(inventory[data.fromSlot])
            if not vehTrunk[toSlot] then
               print(toSlot, "toSlot", "found error at line 800, returning")
               return
            end
            vehTrunk[toSlot].slot = toSlot

            vehTrunk[fromSlot] = nil
         end
         TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehTrunk)
       else
           if (data.itemTo) then
               local tempData = cloneTable(inventory[toSlot])

               inventory[toSlot] = cloneTable(inventory[data.fromSlot])
               inventory[toSlot].slot = toSlot

               inventory[fromSlot] = tempData
               inventory[fromSlot].slot = fromSlot
               TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight)
           else
               if not inventory[toSlot] then
                   inventory[toSlot] = {}
               end
               inventory[toSlot] = cloneTable(inventory[data.fromSlot])
               inventory[toSlot].slot = toSlot

               inventory[fromSlot] = nil
               TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight)
           end
       end
   --- ========= Server Glovebox =========
   elseif (data.from == 'glovebox' and data.to == 'backpack') or (data.from == 'glovebox' and data.to == 'pocket') then
      local vehicle = data.chestData and data.chestData.vehicle
      local vehGlovebox = vRP.getVehicleGlovebox(user_id, vehicle)
      local slot = getSlotByItem(inventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item from glovebox, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         from = vehicle,
      }, 'MoveItemToGlovebox');

      if slot and inventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         inventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not inventory[toSlot] == nil then
            return
         end

         if not inventory[toSlot] then
            inventory[toSlot] = {}
         end

         inventory[toSlot] = cloneTable(vehGlovebox[fromSlot])
         inventory[toSlot].slot = toSlot
         inventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      vehGlovebox[fromSlot].amount -= math.abs(tonumber(data.amount))
      if vehGlovebox[fromSlot].amount <= 0 then
         vehGlovebox[fromSlot] = nil
      end

      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$set"] = {glovebox = vehGlovebox}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehGlovebox)
   elseif (data.from == 'backpack' and data.to == 'glovebox') or (data.from == 'pocket' and data.to == 'glovebox') then
      local vehicle = data.chestData and data.chestData.vehicle
      local vehGlovebox = vRP.getVehicleGlovebox(user_id, vehicle)
      local slot = getSlotByItem(vehGlovebox, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item to glovebox, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         to = vehicle,
      }, 'MoveItemFromGlovebox');

      if slot and vehGlovebox[slot].item == data.item and not vRP.items[data.item].isUnique then
         vehGlovebox[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not vehGlovebox[toSlot] == nil then
            return
         end

         if not vehGlovebox[toSlot] then
            vehGlovebox[toSlot] = {}
         end

         vehGlovebox[toSlot] = cloneTable(inventory[fromSlot])
         vehGlovebox[toSlot].slot = toSlot
         vehGlovebox[toSlot].amount = math.abs(tonumber(data.amount))
      end

      inventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if inventory[fromSlot].amount <= 0 then
          inventory[fromSlot] = nil
      end

      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$set"] = {glovebox = vehGlovebox}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehGlovebox)
   -- ========= Server Trunk =========    
   elseif (data.from == 'trunk' and data.to == 'backpack') or (data.from == 'trunk' and data.to == 'pocket') then
      local vehicle = data.chestData and data.chestData.vehicle
      local vehTrunk = vRP.getVehicleTrunk(user_id, vehicle)
      local slot = getSlotByItem(inventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item from trunk, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         from = vehicle,
      }, 'MoveItemFromTrunk');

      if slot and inventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         inventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not inventory[toSlot] == nil then
            return
         end

         if not inventory[toSlot] then
            inventory[toSlot] = {}
         end

         inventory[toSlot] = cloneTable(vehTrunk[fromSlot])
         if not inventory[toSlot] then
            print(toSlot, "toSlot", "found error at line 936, returning")
            return
         end
         inventory[toSlot].slot = toSlot
         inventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      vehTrunk[fromSlot].amount -= math.abs(tonumber(data.amount))
      if vehTrunk[fromSlot].amount <= 0 or vehTrunk[fromSlot].amount == 0 then
         vehTrunk[fromSlot] = nil
      end
      
      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$set"] = {trunk = vehTrunk}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehTrunk)
   elseif (data.from == 'backpack' and data.to == 'trunk') or (data.from == 'pocket' and data.to == 'trunk') then
      local vehicle = data.chestData and data.chestData.vehicle
      local vehTrunk = vRP.getVehicleTrunk(user_id, vehicle)
      local slot = getSlotByItem(vehTrunk, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item to trunk, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         to = vehicle,
      }, 'MoveItemToTrunk');

      if slot and vehTrunk[slot].item == data.item  and not vRP.items[data.item].isUnique then
         vehTrunk[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not vehTrunk[toSlot] == nil then
            return
         end

         if not vehTrunk[toSlot] then
            vehTrunk[toSlot] = {}
         end

         vehTrunk[toSlot] = cloneTable(inventory[fromSlot])
         vehTrunk[toSlot].slot = toSlot
         vehTrunk[toSlot].amount = math.abs(tonumber(data.amount))
      end

      inventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if inventory[fromSlot].amount <= 0 then
          inventory[fromSlot] = nil
      end

      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$set"] = {trunk = vehTrunk}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehTrunk)
   -- ========= Server Chests =========
   elseif (data.from == 'chest' and data.to == 'backpack') or (data.from == 'chest' and data.to == 'pocket') then
      local chest = data.chestData and data.chestData.key
      local chestData = vRP.getChestData(chest)
      local slot = getSlotByItem(inventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item from chest, amount is 0 or less! Chest'..chest..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         from = chest,
      }, 'MoveItemFromChest');

      if slot and inventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         inventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and (not inventory[toSlot] == nil) then
            return
         end

         if not inventory[toSlot] then
            inventory[toSlot] = {}
         end

        inventory[toSlot] = cloneTable(chestData[fromSlot])
        inventory[toSlot].slot = toSlot
        inventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      chestData[fromSlot].amount -= math.abs(tonumber(data.amount))
      if chestData[fromSlot].amount <= 0 then
          chestData[fromSlot] = nil
      end

      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, chestData)
      vRP.setSData(chest, chestData)
   elseif (data.from == 'backpack' and data.to == 'chest') or (data.from == 'pocket' and data.to == 'chest') then
      local chest = data.chestData and data.chestData.key
      local chestData = vRP.getChestData(chest)
      local slot = getSlotByItem(chestData, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item to chest, amount is 0 or less! Chest'..chest..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         to = chest,
      }, 'MoveItemToChest');

      if slot and chestData[slot].item == data.item and not vRP.items[data.item].isUnique then
         chestData[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not chestData[toSlot] == nil then
            return
         end

         if not chestData[toSlot] then
            chestData[toSlot] = {}
         end

         chestData[toSlot] = cloneTable(inventory[fromSlot])
         chestData[toSlot].slot = toSlot
         chestData[toSlot].amount = math.abs(math.abs(tonumber(data.amount)))
      end

      inventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if inventory[fromSlot].amount <= 0 then
          inventory[fromSlot] = nil
      end

      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, chestData)
      vRP.setSData(chest, chestData)
   --- ========= PLAYER INVENTORY =========
   elseif (data.from == 'player-inv' and data.to == 'pocket') or (data.from == 'player-inv' and data.to == 'backpack') then
      local target_id = data.chestData and data.chestData.key
      local targetInventory = vRP.getUserInventory(target_id)
      local slot = getSlotByItem(inventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item from Player, amount is 0 or less! Player Target'..target_id..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         from = 'Player ('..target_id..')',
      }, 'MoveItemFromPlayer');

      if slot and inventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         inventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not inventory[toSlot] == nil then
            return
         end

         if not inventory[toSlot] then
            inventory[toSlot] = {}
         end

         inventory[toSlot] = cloneTable(inventory[fromSlot])
         inventory[toSlot].slot = 0
         inventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      targetInventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if targetInventory[fromSlot].amount <= 0 then
         targetInventory[fromSlot] = nil
      end
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, targetInventory)
   elseif (data.from == 'pocket' and data.to == 'player-inv') or (data.from == 'backpack' and data.to == 'player-inv') then
      local target_id = data.chestData and data.chestData.key
      local targetInventory = vRP.getUserInventory(target_id)
      local slot = getSlotByItem(targetInventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item to Player, amount is 0 or less! Player Target'..target_id..' Item: '..data.item..' Player: '..user_id)
      end

      vRP.createLog(user_id, {
         item = data.item,
         amount = data.amount,
         item_name = vRP.items[data.item].name,
         to = 'Player ('..target_id..')',
      }, 'MoveItemToPlayer');

      if slot and targetInventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         targetInventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not targetInventory[toSlot] == nil then
            return
         end

         if not targetInventory[toSlot] then
            targetInventory[toSlot] = {}
         end

         targetInventory[toSlot] = cloneTable(inventory[fromSlot])
         targetInventory[toSlot].slot = toSlot
         targetInventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      inventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if inventory[fromSlot].amount <= 0 then
         inventory[fromSlot] = nil
      end
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, targetInventory)
   -- ========= OTHER PLAYER TRUNK =========
   elseif (data.from == 'trunk-player' and data.to == 'pocket') or (data.from == 'trunk-player' and data.to == 'backpack') then
      local target_id = data.chestData and data.chestData.key
      local vehicle = data.chestData and data.chestData.vehicle
      local vehTrunk = vRP.getVehicleTrunk(target_id, vehicle)
      local slot = getSlotByItem(inventory, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item from Player Trunk, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      if slot and inventory[slot].item == data.item and not vRP.items[data.item].isUnique then
         inventory[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not inventory[toSlot] == nil then
            return
         end

         if not inventory[toSlot] then
            inventory[toSlot] = {}
         end

         inventory[toSlot] = cloneTable(vehTrunk[fromSlot])
         inventory[toSlot].slot = toSlot
         inventory[toSlot].amount = math.abs(tonumber(data.amount))
      end

      vehTrunk[fromSlot].amount -= math.abs(tonumber(data.amount))
      if vehTrunk[fromSlot].amount <= 0 then
         vehTrunk[fromSlot] = nil
      end

      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = target_id, vehicle = vehicle}, update = {["$set"] = {trunk = vehTrunk}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehTrunk)
   elseif (data.from == 'pocket' and data.to == 'trunk-player') or (data.from == 'backpack' and data.to == 'trunk-player') then
      local target_id = data.chestData and data.chestData.key
      local vehicle = data.chestData and data.chestData.vehicle
      local vehTrunk = vRP.getVehicleTrunk(target_id, vehicle)
      local slot = getSlotByItem(vehTrunk, data.item)

      if data.amount <= 0 then
         saveInventory(user_id)
         TriggerClientEvent("vrp-hud:sendApiError", player, "A aparut o eroare, te rugam sa te reconectezi pe server sau sa contactezi un membru din staff!")
         return print('ERROR: Cannot move item to Player Trunk, amount is 0 or less! Vehicle'..vehicle..' Item: '..data.item..' Player: '..user_id)
      end

      if slot and vehTrunk[slot].item == data.item and not vRP.items[data.item].isUnique then
         vehTrunk[slot].amount += math.abs(tonumber(data.amount))
      else
         if vRP.items[data.item].isUnique and not vehTrunk[toSlot] == nil then
            return
         end

         if not vehTrunk[toSlot] then
            vehTrunk[toSlot] = {}
         end

         vehTrunk[toSlot] = cloneTable(inventory[fromSlot])
         vehTrunk[toSlot].slot = toSlot
         vehTrunk[toSlot].amount = math.abs(tonumber(data.amount))
      end

      inventory[fromSlot].amount -= math.abs(tonumber(data.amount))
      if inventory[fromSlot].amount <= 0 then
         inventory[fromSlot] = nil
      end

      exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = target_id, vehicle = vehicle}, update = {["$set"] = {trunk = vehTrunk}}})
      TriggerClientEvent('vrp-inventory:setInventoryData', player, inventory, maxWeight, vehTrunk)
   end
end)
RegisterServerEvent('vrp-inventory:useItem', function(item, slot)
   local player = source
   vRP.useInventoryItem(player, item, slot)
end)

RegisterServerEvent('vrp-inventory:giveItem', function(item, amount, fromSlot)
   local player = source
   local user_id = vRP.getUserId(player)
   amount = parseInt(amount)
   fromSlot = parseInt(fromSlot)
   
   if item and amount >= 1 then
      vRPclient.getNearestPlayer(player, {15}, function(target)
         if not target then return vRPclient.notify(player, {'Nu ai un jucator in apropiere', 'error'}) end;
         local target_id = vRP.getUserId(target)
         local inventory = vRP.getUserInventory(user_id)

         if inventory[fromSlot] and inventory[fromSlot].item == item then
            local extraData = inventory[fromSlot].extraData or false
            if vRP.giveItem(target_id, item, amount, false, extraData, false, 'Player ('..user_id..')') then

               vRP.createLog(target_id, {
                  item = item,
                  amount = amount,
                  item_name = vRP.items[item].name,
                  from = 'Player ('..user_id..')',
               }, 'ReceiveItemFromPlayer')

               vRP.createLog(user_id, {
                  item = item,
                  amount = amount,
                  item_name = vRP.items[item].name,
                  to = 'Player ('..target_id..')',
                }, 'GiveItemToPlayer')

               inventory[fromSlot].amount -= amount
               if inventory[fromSlot].amount <= 0 or inventory[fromSlot].amount == 0 then
                  inventory[fromSlot] = nil
               end
   
               vRPclient.playAnim(player, {true, {{"mp_common","givetake1_a",1}}})
               vRPclient.playAnim(target, {true, {{"mp_common","givetake2_a",1}}})
               saveInventory(user_id)
            else
               vRPclient.notify(player, {'Jucatorul nu mai are spatiu in inventar!', 'error'})
               vRPclient.notify(target, {'Nu mai ai spatiu in inventar!', 'error'})
            end
         end
      end)
   end
end)

RegisterServerEvent('vrp-inventory:trashItem', function(item, amount, slot)
   local player = source
   local user_id = vRP.getUserId(player)
   local inventory = vRP.getUserInventory(user_id)
   amount = math.abs(parseInt(amount))


   if inventory[slot] and inventory[slot].item == item then
      inventory[slot].amount -= amount
      if inventory[slot].amount <= 0 or inventory[slot].amount == 0 then
         inventory[slot] = nil
      end

      vRPclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
      saveInventory(user_id)
   end
end)

RegisterServerEvent("vrp-inventory:unequipSlot", function(item, fromSlot, toSlot)
   local player = source
   local user_id = vRP.getUserId(player)
   local inventory = vRP.getUserInventory(user_id)
   toSlot = tonumber(toSlot)

   if inventory[fromSlot] and inventory[fromSlot].item == item then
       if not inventory[toSlot] == nil then
           return
       end

       if not inventory[toSlot] then
           inventory[toSlot] = {}
       end

       inventory[toSlot] = cloneTable(inventory[fromSlot])
       inventory[toSlot].slot = toSlot
       inventory[fromSlot] = nil
   end
   
   saveInventory(user_id)
end)


RegisterServerEvent('vrp-inventory:equipSlot', function(data)
   local player = source
   local user_id = vRP.getUserId(player)
   local inventory = vRP.getUserInventory(user_id)
   local item = data.item
   local fromSlot = data.fromSlot
   local toslot = data.slot

   if inventory[fromSlot] and inventory[fromSlot].item == item then
      if not inventory[toslot] == nil then
         return
      end

      if not inventory[toslot] then
         inventory[toslot] = {}
      end

      inventory[toslot] = cloneTable(inventory[fromSlot])
      inventory[toslot].slot = toslot
      inventory[fromSlot] = nil
   end

   saveInventory(user_id)
end)

RegisterServerEvent('vrp-inventory:close', function(data)
   local player = source
   local user_id = vRP.getUserId(player)

   if data.otherType and data.otherType == 'chest' then
      local chest = data.otherData and data.otherData.key

      if openedChests[chest] then
         openedChests[chest] = nil
      end
   end

   saveInventory(user_id)

   if perchezitieActiva[user_id] ~= nil then
      -- print(perchezitieActiva[user_id])
      vRP.usersData[perchezitieActiva[user_id]].lockedInventory = false
      Player(player).state.lockedInventory = false
   end
end)

registerCallback('openInventory', function(player, type, theCar)
   local user_id = vRP.getUserId(player)

   if (type == 'glovebox' and theCar) then
      local vehicleData = vRP.getVehicleDataTable(user_id, vehicle)
      if vehicleData and vehicleData.trunkUsed then
         return false
      end

      return {
           name = "Torpedou",
           type = 'glovebox',
           chestData = {
               vehicle = theCar
           },
           maxWeight = cfg.chest_weights[theCar] or 30,
           items = vRP.getVehicleGlovebox(user_id, theCar)
      }
   elseif (type == 'trunk' and theCar) then
      local vehicleData = vRP.getVehicleDataTable(user_id, vehicle)
      if vehicleData and vehicleData.trunkUsed then
         return false
      end

      return {
           name = "Portbagaj",
           type = "trunk",
           chestData = {
               vehicle = theCar
           },
           maxWeight = cfg.chest_weights[theCar] or 30,
           items = vRP.getVehicleTrunk(user_id, theCar)
      }
   end

   return false
end)

registerCallback('getWeaponAmmo', function(player, weapon)
   local user_id = vRP.getUserId(player)
   local weapons = cfg.weapons[weapon]

   if weapons and weapons.ammo then
      return vRP.getInventoryItemAmount(user_id, weapons.ammo)
   end

   return 0;
end)

RegisterServerEvent('vrp-weapons:setAmmo', function(ammo, weapon)
   if not (weapon and ammo) then
      return
   end

   ammo = tonumber(ammo) or 0

   local player = source
   local user_id = vRP.getUserId(player)
   local ammo_used = cfg.weapons[weapon].ammo

   if ammo_used then
      local ammoAmount = vRP.getInventoryItemAmount(user_id, ammo_used)
      local used_ammo = ammoAmount - ammo

      if used_ammo > 0 then
         vRP.removeItem(user_id, ammo_used, used_ammo)
      end
   end
end)



RegisterServerEvent("vl:trashGhiozdan", function()
   player = source
   local user_id = vRP.getUserId(player)
   vRP.usersData[user_id].activeBag = nil
   TriggerClientEvent('vrp-inventory:updateBackpack', player, false)
end)

RegisterCommand('saveinv', function(player)
   local user_id = vRP.getUserId(player)

   saveInventory(user_id)
end)


function tvRP.getModelMaxTrunkSpace(vname)
   if cfg.chest_weights[vname] then
     return cfg.chest_weights[vname]
   end
 
   return 30
end

RegisterCommand('giveitem', function(player, args)
   local user_id = vRP.getUserId(player)
   
   local target_id = parseInt(args[1])
   local item = tostring(args[2])
   local amount = tonumber(args[3]) or 1

   if not (vRP.getUserAdminLevel(user_id) >= 5) then
      return vRPclient.noAcces(player, {})
   end

   if not target_id or not item then
      return vRPclient.sendSyntax(player, {'/giveitem [id] [item] [amount]'})
   end

   if not vRP.items[item] then
      return vRPclient.sendError(player, {'Itemul ' .. item .. ' nu exista!'})
   end

   vRP.giveItem(target_id, item, amount, false, false, false, 'Admin ('..user_id..')')
end)



-- Temp Perchezitioneaza

local function ch_searchPlayer(player, target)
   local user_id = vRP.getUserId(player)
   local target_id = vRP.getUserId(target)

   local function continueTake()
      local userInventory = vRP.getUserInventory(target_id)

      local menu = {name = 'Inventar Jucator'}

      for slot, data in pairs(userInventory) do
         menu[data.label..' - x'..data.amount] = {function(player)
            continueTake()
         end, '', data.description}
      end

      vRP.openMenu(player, menu)
   end continueTake()

   -- vRP.openOtherPlayerInventory(player,user_id)
end

vRP.registerActionsMenuBuilder("basicply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  local choices = {}

	  choices["Perchezitioneaza Jucator"] = {function()
         vRPclient.getNearestPlayer(player, {2}, function(targetSrc)
            if not targetSrc then
               return vRPclient.notify(player, {"Nu ai niciun jucator in apropiere!", "error"})
            end

            ch_searchPlayer(player, targetSrc)
         end)
		end, "person-search.svg"}
  
		add(choices)
	end
end)