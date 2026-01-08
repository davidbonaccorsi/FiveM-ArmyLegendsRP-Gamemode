function vRP.getUserIdentity(user_id, cbr)
  local task = Task(cbr, {{firstname = "Nume", name = "Prenume", age = 18, phone = 0, iban = 0, sex = "M"}})

  if vRP.usersData[user_id] and vRP.usersData[user_id].userIdentity then
      return task({vRP.usersData[user_id].userIdentity})
  end

  task()
end

function vRP.getIdentity(user_id)
  if vRP.usersData[user_id] and vRP.usersData[user_id].userIdentity then
      return vRP.usersData[user_id].userIdentity
  end

  local userData = exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {userIdentity =1}}})
  if userData.userIdentity and userData['userIdentity'].firstname and userData['userIdentity'].name then
      return {firstname = userData['userIdentity'].firstname, name = userData['userIdentity'].name }
  end

  return {firstname = "Nume", name = "Prenume"}
end

exports("getRoleplayName", function(user_id)
  local identity = vRP.getIdentity(user_id)

  return identity.firstname.." "..identity.name
end)

function vRP.getUserIban(user_id)
  return vRP.usersData[user_id] and vRP.usersData[user_id]['userIdentity'] and vRP.usersData[user_id]['userIdentity'].iban or false
end

function vRP.getUserByPhone(phone)
  local phoneExist =  exports.mongodb:findOne({collection = "users", query = {["userIdentity.phone"] = phone}, options = {projection = {id = 1}}})
  return phoneExist and phoneExist.id or false
end

function vRP.setPhoneNumber(user_id, number)
  exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {["$set"] = {["userIdentity.phone"] = number}}})
  vRP.usersData[user_id]['userIdentity'].phone = number
end

registerCallback('checkCharacterName', function(player, firstname, lastname)
  if string.len(firstname) < 4 or string.len(lastname) < 4 then
      return false
  end

  if string.match(firstname,"%d+") ~= nil or  string.match(lastname,"%d+") ~= nil then
      return false
  end

  return true
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, connect)
  if connect then
    Citizen.Wait(500)

    local data = vRP.usersData[user_id] or {}

    if not vRP.hasItem(user_id, "id_doc") and data.userIdentity then
      vRP.giveItem(user_id, "id_doc", 1)
    end
  end
end)

-- === [GENERATE FUNCTIONS] ===

local resetCharacters = {}

exports("createCharacter", function(user_id, player, fromReset)
  TriggerClientEvent('vrp:createCharacter', player)
  SetPlayerRoutingBucket(player, tonumber(user_id))
  TriggerEvent("afk-kick:passAutoKick", true)
    
  if fromReset then
    resetCharacters[user_id] = true
  end
end)

RegisterCommand("resetcharacter", function(player, args)
  local user_id = vRP.getUserId(player)

  if vRP.getUserAdminLevel(user_id) >= 4 then
      local target_id = tonumber(args[1])

      if target_id then
          local target_src = vRP.getUserSource(target_id)
          exports["vrp"]:createCharacter(target_id, target_src, true)
          vRPclient.msg(player, {"^3Minunat! ^7I-ai resetat caracterul jucatorului "..GetPlayerName(target_src)})
      else
          vRPclient.sendSyntax(player, {"/resetcharacter <user_id>"})
      end
  end
end)

exports("loadCharacter", function(user_id, player)
  vRP.getUData(user_id, 'characterData', function(data)
      local data = data or {}

      TriggerClientEvent('vrp:loadCharacter', player, {
        model = data.model,
        drawables = data.drawables or {},
        props = data.props or {},
        drawtextures = data.drawtextures or {},
        proptextures = data.proptextures or {},
        hairColor = data.hairColor or {1, 1},
        headBlend = data.headBlend or {},
        tattooes = data.tattooes or {},
        headOverlay = data.headOverlay or {},
        headStructure = data.headStructure or {},
        eyeColor = data.eyeColor or 0,
      })
  end)
end)

RegisterServerEvent('vrp:reloadCharacter', function()
  local player = source
  local user_id = vRP.getUserId(player)
  exports['vrp']:loadCharacter(user_id, player)
end)

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
      local char = string.sub(format, i,i)
      if char == "D" then number = number..string.char(zbyte+math.random(0,9))
      elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
      else number = number..char end
  end

  return number
end

-- === [CREATE IDENTITY EVENTS] ===

RegisterServerEvent("vrp:saveIdentity", function(data)
  local player = source
  local user_id = vRP.getUserId(player)

  if not (type(data) == "table" and next(data)) then
    exports["vrp"]:createCharacter(user_id, player)
    return
  end

  local iban = "AL"..user_id..''..vRP.generateStringNumber("DDDD")
  local phoneNumber = ''

  local function search()
      phoneNumber = vRP.generateStringNumber("DDD-DDDD")
      local phoneExist = vRP.getUserByPhone(phoneNumber)
      if phoneExist then
        search()
      end
      Citizen.Wait(1)
  end
  search()

  local userIdentity = {
      firstname = data.secondName or "Nume",
      name = data.name or "Prenume",
      age = math.floor(tonumber(data.age) or 18),
      sex = data.sex or "M",
      phone = phoneNumber,
      iban = iban
  }

  if not resetCharacters[user_id] then
      if vRP.getInventoryItemAmount(user_id, "id_doc") < 1 then
          vRP.giveItem(user_id, "id_doc", 1, false, false, false, 'Server Connect')
      end
      
      vRP.openRefferal(player)
  elseif resetCharacters[user_id] then
      resetCharacters[user_id] = nil
  end

  vRP.updateUser(user_id, 'userIdentity', userIdentity, 1)
  TriggerEvent("vRP:updateIdentity", user_id, userIdentity)
  TriggerClientEvent("introCinematic:start", player)
end)

RegisterServerEvent('vrp:saveCharacter', function(data, firstCharacter)
  local player = source
  local user_id = vRP.getUserId(player)

  local values = {
    model = data.model,
    drawables = data.drawables or {},
    props = data.props or {},
    drawtextures = data.drawtextures or {},
    proptextures = data.proptextures or {},
    eyeColor = math.max(0, parseInt(data.eyeColor)),
    tattooes = data.tattooes or {},
    hairColor = data.hairColor or {1, 1},
    headBlend = data.headBlend or {},
    headOverlay = data.headOverlay or {},
    headStructure = data.headStructure or {},
  }

  vRP.setUData(user_id, "characterData", values)

  if vRP.usersData[user_id]['uData'] and firstCharacter then
    local player = vRP.getUserSource(user_id)
    SetPlayerRoutingBucket(player, 0)
    vRP.updateUser(user_id, 'uData', vRP.usersData[user_id]['uData'], 1)

    local coords = vector3(-1049.4223632813,-2759.9516601563,21.36169052124)
    local playerPed = GetPlayerPed(player)
    Citizen.Wait(34010)
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z + 1, true, false, false, true)
    vRPclient.notify(player, {"Bun venit pe ArmyLegends Romania!", "info"})
    Citizen.Wait(6000)
    vRPclient.notify(player, {"Foloseste tasta M pentru a deschide meniurile de pe server!", "info"})
    Citizen.Wait(30000)
    vRPclient.notify(player, {"Cumpara-ti un telefon de la magazinul de electronice si intra la GPS pentru a gasii cele mai importante locatii!", "info"})
    Citizen.Wait(35000)
    vRPclient.notify(player, {"Apasa tasta HOME pentru a accesa lista de jucatori!", "info"})
    Citizen.Wait(15000)
    vRPclient.notify(player, {"Alatura-te comunitatii pe armylegends.ro sau pe discord.gg/armylegendsrp", "info"})
    Citizen.Wait(15000)
    vRPclient.notify(player, {"Mergi la Politia din Aeroport pentru a ridica permisul auto", "info"})
  end
end)