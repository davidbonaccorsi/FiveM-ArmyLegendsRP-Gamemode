local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local config = module("cfg/base")

local whitelisted = json.decode(LoadResourceFile("vrp", "whitelisted.json")) or {}

vRP = {}
Proxy.addInterface("vRP",vRP)

tvRP = {}
Tunnel.bindInterface("vRP",tvRP)
vRPclient = Tunnel.getInterface("vRP","vRP")

vRP.users = {}
vRP.rusers = {}
vRP.user_sources = {}
vRP.usersData = {}
staffUsers = {}
vRP.serverLoaded = false

local sData = {}
local hoursPlayed, lastHours, hoursInt = {}, {}, {}

local toSendUI = {}

exports("link", function()
  return vRP or {}
end)

Citizen.CreateThread(function()
  Wait(5000)
  for _, resource in pairs(config.resources or {}) do
    Wait(500)
    StartResource(resource)
  end
  vRP.serverLoaded = true;
end)

Citizen.CreateThread(function()
  local uptimeMinute, uptimeHour = 0, 0
  while true do
    Citizen.Wait(1000 * 60)
    uptimeMinute = uptimeMinute + 1

    if uptimeMinute == 60 then
      uptimeMinute = 0
      uptimeHour = uptimeHour + 1
    end

    ExecuteCommand(("sets UpTime \"%02dh %02dm\""):format(uptimeHour, uptimeMinute))
  end
end)

Citizen.CreateThread(function()
  local lastHour = os.date("%H")
  while true do
      if not (lastHour == os.date('%H')) then
          lastHour = os.date('%H')
          TriggerEvent('timeChanged', lastHour, os.date('%d'))
      end
      Wait(1000 * 60 * 10)
  end
end)

local hoursCleared = false
Citizen.CreateThread(function()
  vRP.getSData('hoursCleared', function(cleared)
      hoursCleared = cleared or false
  end)

  AddEventHandler('timeChanged', function(hour, day)
      if (day == 0) and (hour == 0) and (not hoursCleared) then
          hoursCleared = day

          vRP.setSData('hoursCleared',hoursCleared)
          exports.mongodb:update({collection = "users", update = {
              ["$set"] = {lastHours = 0.0, hoursReward = false}
          }})
        elseif hoursCleared and not (hoursCleared == day) then
          hoursCleared = false
          vRP.setSData('hoursCleared',false)
      end
  end)
end)

AddEventHandler("ui:loaded", function(data)
  toSendUI = json.decode(data)
end)

local playerLoaded = {}
AddEventHandler("vRPcli:playerSpawned", function()
    local player = source
    
    if not playerLoaded[player] then
      TriggerClientEvent("vrp:sendNuiMessage", player, { data = toSendUI, category = "ui_load" })
      playerLoaded[player] = true
    end
end)

local function checkUserTokens(tokens, userTokens, user_id)
  if not (tokens and userTokens and user_id) then return end

  local exists = {}
  for i = 1, #userTokens do
    local document = userTokens[i]

    if document.banned then
      return document.user_id
    end

    exists[document.token] = true
  end

  local newTokens = {}
  for i = 1, #tokens do
    local token = tokens[i]

    if not exists[token] then
      newTokens[#newTokens + 1] = {token = token, banned = false, user_id = user_id}
    end
  end

  if next(newTokens) then
    exports.mongodb:insert({collection = "userTokens", documents = newTokens, ordered = false})
  end
end

function vRP.getUserIdByIdentifiers(player, ids, cbr)
  local task = Task(cbr, {0}, 30000)

  local license

  for idx = 1, #ids do
      if license then break end

      local identify = ids[idx]

      if identify:find("license:") then
          license = identify
      end
  end

  if not license then return task{0} end

  local playerTokens = GetPlayerTokens(player) or {}

  exports.mongodb:aggregate({collection = "users"; pipeline = {
    {
      ["$match"] = {
        ["$expr"] = {
          ["$eq"] = {"$gtaLicense"; license}
        }
      }
    };
    {
      ["$lookup"] = {
        from = "userVehicles";
        localField = "id";
        foreignField = "user_id";
        as = "userVehicles"
      }
    };
    {
      ["$lookup"] = {
        from = "userTokens";
        pipeline = {
            {
                ["$match"] = {
                    ["$expr"] = {
                        ["$in"] = {"$token"; playerTokens}
                    }
                }
            };
            {
                ["$project"] = {
                    _id = 0;
                    token = 1;
                    banned = 1;
                    user_id = 1
                }
            }
        };
        as = "userTokens"
      }
    }
  }}, function(success, result)
      
      if success and result[1] then
        local userData = result[1]

        if not userData.userBans then
          local tokenBanned = checkUserTokens(playerTokens, userData.userTokens or {}, userData.id)
          if tokenBanned then
            return task{-2; tokenBanned}
          end
        end

        vRP.usersData[userData.id] = userData

        return task{userData.id; userData}
      end

      exports.mongodb:aggregate({collection = "users"; pipeline = {
        {["$sort"] = {id = -1}};
        {
          ["$lookup"] = {
            from = "userTokens";
            pipeline = {
                {
                    ["$match"] = {
                        ["$expr"] = {
                            ["$in"] = {"$token"; playerTokens}
                        }
                    }
                };
                {
                    ["$project"] = {
                        _id = 0;
                        token = 1;
                        banned = 1;
                        user_id = 1
                    }
                }
            };
            as = "userTokens"
          }
        }
      }}, function(success, result)
          if success then
              local nextId = 1

              local userData = result[1] or {}
          
              if userData.id then
                  nextId = userData.id + 1
              end

              local tokenBanned = checkUserTokens(playerTokens, userData.userTokens or {}, nextId)
              if tokenBanned then
                return task{-2; tokenBanned}
              end
            
              local user = {id = nextId; gtaLicense = license; lastHours = 0.0; hoursPlayed = 0.0; firstConnect = os.time()}
              exports.mongodb:insertOne({collection = "users"; document = user}, function(succes)
                if not succes then return task{0} end

                vRP.usersData[nextId] = user
                task{nextId; user}
              end)
          end
      end)
    end)
end

function vRP.updateUser(user_id, key, data)
  if (vRP.usersData[user_id]) then
    vRP.usersData[user_id][key] = data or nil
  end
  exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = data and {["$set"] = {[key] = data}} or {["$unset"] = {[key] = 1}}})
end

exports("updateUser", vRP.updateUser)

function vRP.setUserData(user_id, key, value)
  if not vRP.usersData[user_id] then return end

  vRP.usersData[user_id][key] = value
end

function vRP.getUserData(user_id, key)
  if not vRP.usersData[user_id] then return end

  return vRP.usersData[user_id][key]
end

function vRP.getPlayerEndpoint(player)
  return GetPlayerEndpoint(player) or "0.0.0.0"
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "Necunoscut"
end

function vRP.formatMoney(amount)
  local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function vRP.isUserBanned(user_id, cbr)
  local task = Task(cbr, {false, {}})

  exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = { projection = {_id = 0, userBans = 1} }}, function(success, rows)
    if #rows > 0 then
      local userBans = rows[1].userBans or false

      task({(userBans and true or false), userBans})
    else
      task()
    end
  end)
end

function vRP.ban(user_id,reason,admin,days,payable)
  local source = vRP.getUserSource(user_id)

  if user_id ~= nil and reason ~= nil then
      vRP.setBanned(user_id,true,reason,admin,days,payable)
      Citizen.CreateThread(function()
          Wait(1000)
          if vRP.getUserSource(user_id) then
              vRP.kick(source, "Ai primit ban !")
          end
      end)

      local motiv = "Motiv: "..reason.."\nID-ul Tau: ["..user_id.."]"
      if admin then
          motiv = "De: "..vRP.getUserId(admin).."\nMotiv: "..reason.."\nID-ul Tau: ["..user_id.."]"
      end

      if days == 0 or not days then
          motiv = motiv .. "\nDurata: Permanent"
      else
          motiv = motiv .. "\nDurata: "..days.." zile"
      end
      motiv = motiv .. "\n\nPentru unban intra pe Discord: discord.gg/armylegendsrp"

      if source then vRP.kick(source,"[Banned] "..motiv) end
  end
end


function vRP.setBanned(user_id, banned, reason, by, days, payable)
  
  if (banned == false) then
      reason = ""
      if user_id ~= -1 then
          exports.mongodb:update({collection = "userTokens", query = {user_id = user_id}, update = {['$set'] = {banned = false}}})
          vRP.updateUser(user_id, 'userBans', false)
      end
  else
      if not days or (days == -1) then
          days = 0
      end

      local banBy = ""
      
      if type(by) ~= "string" then
          local adminName = ""
          if by then
              if GetPlayerName(by) then
                  adminName = GetPlayerName(by)
              end
          end
          if adminName and (adminName ~= "") then
              banBy = adminName .. " [" .. vRP.getUserId(by) .. "]"
          else
              banBy = "Consola"
          end
      else
          banBy = tostring(by)
      end

      if payable == nil then
        payable = true
      end

      local theBan = {
        expire = 0,
        payable = payable,
        bannedBy = banBy,
        banReason = reason,
        banDate = os.time(),
      }


      exports.mongodb:update({collection = "userTokens", query = {user_id = user_id}, update = {['$set'] = {banned = true}}})

      if days ~= 0 then
          theBan.expire = os.time() + daysToSeconds(days)
      end

      vRP.updateUser(user_id, "userBans", theBan)

      local user = vRP.getUser(user_id)
      if user then
        user.totalBans = (user.totalBans or 0) + 1
      end
      
      exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
        ["$inc"] = {totalBans = 1},
      }})
  end
end


function vRP.setUData(user_id,key,value)
  local user = vRP.getUser(user_id)
  if not user then
    print("[vRP] setUData failed because of unexisting user (user_id="..user_id..")")
    return
  end

  if not user.uData then
    user.uData = {}
  end
  user.uData[key] = value
end


function vRP.getUData(user_id, key, cbr)
  local task = Task(cbr, {""}, 120000)
  local user = vRP.getUser(user_id)

  if user and user.uData and user.uData[key] then
    return task({user.uData[key]})
  end

  task({})
end

function vRP.requestUData(user_id, key)
  local user = vRP.getUser(user_id)

  if user and user.uData and user.uData[key] then
    return user.uData[key]
  end

  return {}
end

function vRP.getUserTmpTable(user_id)
  return vRP.usersData[user_id]
end

function vRP.setTmpTableVar(user_id, key, value)
  vRP.usersData[user_id][key] = value
end

RegisterCommand("pushudata", function(player)
  if player == 0 then
    local users = vRP.getUsers()
    for k, v in pairs(users) do
      saveUDataInDb(k)
    end
    print("ArmyLegends: Pushed uData to database")
  end
end)

function saveUDataInDb(user_id)
  if vRP.usersData[user_id]['uData'] then
    vRP.updateUser(user_id, 'uData', vRP.usersData[user_id]['uData'])
  end
end

function vRP.getSData(key, cbr)
  local task = Task(cbr,{""})

  task({sData[key] and sData[key] or {}})
end

function vRP.requestSData(key)
  return sData[key]
end

function vRP.setSData(key,value)
  sData[key] = value
  exports.mongodb:updateOne({collection = "sData", query = {dkey = key}, update = {['$set'] = {dkey = key, dvalue = value}}, options = {upsert = 1}})
end

local function getServerData()
  exports.mongodb:find({collection = "sData", query = {}}, function(success, result)
    for k,v in pairs(result) do
      if v.dkey and v.dvalue then
        sData[v.dkey] = v.dvalue
      end
    end
  end)
end

AddEventHandler("onDatabaseConnect", getServerData)

Citizen.CreateThread(function()
  Wait(5000)
  getServerData()
end)

function vRP.isWhitelisted(user_id, cbr)
  local task = Task(cbr, {false})
  task({whitelisted[tostring(user_id)] or false})
end

function vRP.setWhitelisted(user_id,tog)
  whitelisted[tostring(user_id)] = tog
  SaveResourceFile("vrp", "whitelisted.json", json.encode(whitelisted, {indent = 1}), -1)
  ExecuteCommand("loadwhitelist")
end

function vRP.isConnected(user_id)
  return vRP.rusers[user_id] ~= nil
end

function vRP.isPlayerSpawned(user_id)
  return vRP.usersData[user_id] and vRP.usersData[user_id]['isSpawned'] or false
end

function vRP.isFirstSpawn(user_id)
  return vRP.usersData[user_id] and (vRP.usersData[user_id]['spawns'] == 1) or false
end

function vRP.getUserId(source)
  if source then
      local ids = GetPlayerIdentifiers(source) or {}
      if #ids > 0 then
          return vRP.users[ids[1]]
      end
  end
end

exports("getUserId", vRP.getUserId)

function vRP.getUser(user_id)
  return vRP.usersData[user_id]
end

function vRP.getUsers()
  local users = {}
  for k,v in pairs(vRP.user_sources) do
      users[k] = v
  end

  return users
end

function vRP.getStaffUsers()
    return staffUsers
end

function vRP.getUserSource(user_id)
  return vRP.user_sources[user_id]
end

exports("getUserSource", vRP.getUserSource)

function vRP.kick(player,reason)
  local user_id = vRP.getUserId(player)
  if user_id == 1 or user_id == 2 then
    TriggerClientEvent('chatMessage', player, "^1ArmyLegends: ^7Trebuia sa primesti kick, motiv: \n"..reason)
  else
    DropPlayer(player, reason)
  end
end

function vRP.getUserHoursPlayedInThisSession(user_id, fromated, secconds)
  local tmp = vRP.usersData[user_id]
  if not tmp then return 0 end

  local actTime = os.time()

  if not fromated then -- true in caz ca vrei sa faci o verificare gen if hoursPlayedInThisSession > 3 then print("can") end 
    return ((actTime - tmp.joinTime) / 3600)
  end

  if secconds then
    return time_diff_in_hours_minutes_seconds(tmp.joinTime, actTime)
  end

  return time_diff_in_hours_and_minutes(tmp.joinTime, actTime) -- hours, minutes (2, 30) -> 2 ore jumate, seconds ?
end

function vRP.getUserHoursPlayed(user_id)
  if hoursInt[user_id] then
      local diff = (os.time() - hoursInt[user_id]) or 0
      local hoursGained = diff / 3600

      return math.floor(((hoursPlayed[user_id] or 0) + hoursGained) * 100) / 100
  end

  return hoursPlayed[user_id] or 0
end

function vRP.getUserLastHours(user_id)
  if hoursInt[user_id] then
      local diff = (os.time() - hoursInt[user_id]) or 0
      local hoursGained = diff / 3600
      return math.floor(((lastHours[user_id] or 0) + hoursGained) * 100) / 100
  end

  return lastHours[user_id] or 0
end

function vRP.ReLoadChar(source)
    local playerIp = vRP.getPlayerEndpoint(source)
    local name = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source) or {}

    while not vRP.serverLoaded do
        Citizen.Wait(100)
    end

    vRP.getUserIdByIdentifiers(source, ids, function(user_id, rows)
        if user_id and user_id > 0 then

            vRP.users[ids[1]] = user_id
            vRP.rusers[user_id] = ids[1]
            vRP.user_sources[user_id] = source
            if (rows.adminLvl or 0) > 0 then
              staffUsers[user_id] = {lvl = rows.adminLvl, src = source}
            end
            local nowTime = os.time()

            exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
              ["$set"] = {username = name, last_login = nowTime}
            }})

            vRP.usersData[user_id]['spawns'] = 0
            vRP.usersData[user_id]['username'] = name
            vRP.usersData[user_id]['last_login'] = nowTime
            print("[AL:RP] "..name.." ("..playerIp..") joined (user_id = "..user_id..")")

            TriggerEvent("vRP:playerJoin", user_id, source, name, rows)
            TriggerClientEvent("vRP:checkIDRegister", source)

            for k,v in pairs(vRP.user_sources) do
              if user_id ~= k then
                  TriggerClientEvent("id:initPlayer", source, v, k)
              end
            end
  
            TriggerClientEvent("id:initPlayer", -1, source, user_id)
        else
            DropPlayer(source, "Contul tau nu a fost gasit. Reconnect!")
        end
    end)
end

RegisterNetEvent("vRP:loadPlayer")
AddEventHandler("vRP:loadPlayer", function()
    local user_id = vRP.getUserId(source)
    if not user_id then
        vRP.ReLoadChar(source)
    end
end)

local connectQueue = 0
local cancelQueue = false
RegisterCommand("queue", function(src)
  if src == 0 then
    return print("Queue-ul este acum de "..connectQueue.." (de) secunde!")
  end

  vRPclient.sendInfo(src, {"Queue-ul este acum de "..connectQueue.." (de) secunde!"})
end)

RegisterCommand("cancelqueue", function(src)
  if src ~= 0 then
    local user_id = vRP.getUserId(src)
    if vRP.getUserAdminLevel(user_id) < 5 then
      return vRPclient.noAccess(src)
    end
  end

  cancelQueue = true
  Citizen.SetTimeout(6500, function()
    cancelQueue = false
  end)

  if src == 0 then
    print("^5Info: ^0Queue-ul a fost anulat.")
  else
    vRPclient.sendInfo(src, {"Queue-ul a fost anulat."})
  end
end)

local adaptiveCardServerPassword = {
  type = "AdaptiveCard",
  body = {
      {
          type = "TextBlock",
          text = "Pentru a te conecta pe server introdu parola!"
      },
      {
          type = "Input.Text",
          placeholder = "Password",
          inlineAction = {
              type = "Action.Submit",
              title = "Join",
              iconUrl = ""
          },
    id = "password"
      }
  },
  ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
  version = "1.0"
}

local isOpeningDay, openingCard = false, {
  type = "AdaptiveCard",
  body = {
    {
      type = "Image",
      url = "https://cdn.discordapp.com/attachments/934897156584796201/1152663563169710160/GrandOpening_ArmyLegends_Poarta.png",
      horizontalAlignment = "Center"
    }, {
        type = "TextBlock",
        text = "ArmyLegends Romania",
        wrap = true,
        horizontalAlignment = "Center",
        separator = false,
        height = "auto",
        fontType = "Default",
        size = "Large",
        weight = "Bolder",
        color = "accent"
    }, {
        type = "TextBlock",
        text = "#ArmyLegends - Releasing soon.\nPentru a viziona live noua versiune a serverului vizitati armylegends.ro",
        wrap = true,
        horizontalAlignment = "Center",
        separator = true,
        height = "stretch",
        fontType = "Default",
        size = "Medium",
        weight = "Bolder",
        color = "Light"
    }
  },
  actions = { {
    type = "Action.OpenUrl",
    title = "Livestream YouTube",
    url = "https://www.youtube.com/live/Rbx3q6kwQxA?si=SUqx9d9fgHjM3BOX",
    horizontalAlignment = "Center"
  }, {
    type = "Action.OpenUrl",
    title = "Server Discord",
    url = "https://discord.gg/armylegendsrp",
    horizontalAlignment = "Center"
  }, {
    type = "Action.OpenUrl",
    title = "Website",
    url = "https://ArmyLegends-rp.ro",
    horizontalAlignment = "Center"
  } },
  horizontalAlignment = "Center", -- add this line
  ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
  version = "1.2"
}

AddEventHandler("playerConnecting",function(name, setMessage, game)
  game.defer()
  local source = source
  local playerIp = vRP.getPlayerEndpoint(source)
  local ids = GetPlayerIdentifiers(source) or {}

  -- STEAM
  
  local steam = false

  for k,v in pairs(GetPlayerIdentifiers(source)) do
      if v:find("steam:") then    
          steam = true
      end
  end
  if not steam then
      return game.done("Trebuie sa ai steam-ul pornit pentru a intra pe server!")
  end

  -- STEAM

  local checkedName = name:match("[<>&*%%'=`\"]")
  if checkedName then
      return game.done("[AL:RP] Nu acceptam caractere sau simboluri speciale in nume. ("..tostring(checkedName)..") \nAcesta va trebui sa fie format doar din litere si cifre ! \n\nDiscord: discord.gg/armylegendsrp")
  end

  local userWait = connectQueue + 1
  connectQueue = userWait

  while userWait > 0 do
      game.update("Te conectezi in "..userWait.." secunde...")
      userWait = userWait - 1

      if cancelQueue then
          break
      end

      Citizen.Wait(1000)
  end

  connectQueue = connectQueue - 1
  if connectQueue < 0 then
      connectQueue = 0
  end

  if isOpeningDay then
    game.presentCard(openingCard, function(data, extraData)
      game.done("[AL:RP] Serverul se deschide curand.")
    end)

    return
  end

  if config.password then
    local pwd = promise.new();
    game.presentCard(adaptiveCardServerPassword, function(data, extraData)
        if not (data.password == config.password) then
            pwd:resolve(false)
            game.done("[AL:RP] Parola introdusa este incorecta!")
        else
            pwd:resolve(true)
        end
    end)
    if not Citizen.Await(pwd) then
        return
    end
  end

  if not next(ids) then
      print("[AL:RP] "..name.." ("..playerIp..") rejected: missing identifiers")
      return game.done("\n[AL:RP] Eroare la identifiere, nu au fost gasite.\n\nDiscord: discord.gg/armylegendsrp")
  end

  if isServerRestarting() then
      return game.done("\n[AL:RP] Serverul se restarteaza, incearca sa te conectezi in cateva momente.\n\nDiscord: discord.gg/armylegendsrp")
  end

  game.update("[AL:RP] Se verifica baza de date...\n\nDiscord: discord.gg/armylegendsrp")
  vRP.getUserIdByIdentifiers(source, ids, function(user_id, rows)
      -- [Identification Error]
      if not user_id then
          print("[AL:RP] "..name.." ("..playerIp..") rejected: identification error")
          return game.done("\n[AL:RP] Eroare la identificarea jucatorului.\n\nDiscord: discord.gg/armylegendsrp")
      end


      if user_id > 0 then
          game.update("[AL:RP] Se verifica ban-urile...\n\nDiscord: discord.gg/armylegendsrp")
          -- [Fast Relog Check]
          local possibleSrc = vRP.getUserSource(user_id)
          if possibleSrc then
              print("[AL:RP] "..name.." ("..playerIp..") rejected: fast relog / double account")
              game.done("ArmyLegends:RP - Eroare la logare\n\nIncearca sa te conectezi din nou in 30 de secunde.\n\nDiscord: discord.gg/armylegendsrp")
              return vRP.deleteOnlineUser(user_id)
          end

          -- [User banned check]
          if (rows.userBans) then
              local banReason = rows.userBans['banReason'] or ""
              local bannedBy = rows.userBans['bannedBy'] or ""
              local banDays = rows.userBans['expire'] or 0
              local bannedDate = rows.userBans['banDate'] or os.time()
              local payable = rows.userBans['payable']

              if payable == nil then
                payable = true
              end

              local banMsg = "\nEsti banat pe acest server!\nBanat de: "..bannedBy.."\nMotiv: "..banReason.."\nDrept de plata: "..(payable and "Da" or "Nu").."\nID-ul Tau: ["..user_id.."]"
              if banDays > 0 then
                  if banDays > os.time() then
                      banMsg = banMsg .. "\nExpira in: "..os.date("%d/%m/%Y %H:%M", banDays)
                  else
                      game.done("\n[AL:RP] Banul tau a expirat, reconecteaza-te si citeste regulamentul serverului!\nPentru multe alte informatii utile poti intra pe discordul comunitatii noastre: discord.gg/armylegendsrp")
                      exports.mongodb:update({collection = "userTokens", query = {user_id = user_id}, update = {['$set'] = {banned = false}}})
                      vRP.updateUser(user_id, 'userBans', false)
                      return
                  end
              else
                  banMsg = banMsg .. "\nAcest ban nu expira niciodata !"
              end
              banMsg = banMsg .. "\n\nPentru unban intra pe Discord: discord.gg/armylegendsrp"

              print("[AL:RP] "..name.." ("..playerIp..") rejected: banned (user_id = "..user_id..")\n^3AdmBot - Detalii ban:^7\n|^1 "..banReason.."^7 | Admin: "..bannedBy.." | Data banului: "..os.date("%d/%m/%Y %H:%M:%S", bannedDate).." | Drept de plata: "..(payable and "Da" or "Nu").." | IP: "..playerIp.." |")
              return game.done(banMsg)
          end

          if config.whitelist then
              local p = promise.new()

              vRP.isWhitelisted(user_id, function(whitelisted)

                  if not whitelisted then
                      print("[AL:RP] "..name.." ("..playerIp..") rejected: whitelist (user_id = "..user_id..")")
                      game.done("\n[AL:RP] Nu esti pe lista alba.\nUser Id: "..user_id.."\n\nDiscord: discord.gg/armylegendsrp")
                  end

                  p:resolve(whitelisted)
              end)

              if not Citizen.Await(p) then
                return
              end
          end

          -- [CONNECT PLAYER TO SERVER]
          vRP.users[ids[1]] = user_id
          vRP.rusers[user_id] = ids[1]
          vRP.user_sources[user_id] = source

          if (rows.adminLvl or 0) > 0 then
              staffUsers[user_id] = {lvl = rows.adminLvl, src = source}
          end

          game.update("[AL:RP] Se incarca ultima logare...\n\nDiscord: discord.gg/armylegendsrp")
          local last_login_stamp = os.time()
          print("[AL:RP] "..name.." ("..playerIp..") joined (user_id = "..user_id..")")
          exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
              ["$set"] = {
                  last_login = last_login_stamp,
                  username = name
              }
          }})
          vRP.usersData[user_id]['spawns'] = 0
          vRP.usersData[user_id]['username'] = name
          vRP.usersData[user_id]['last_login'] = last_login_stamp

          TriggerEvent("vRP:playerJoin", user_id, source, name, rows)
          game.done()
      else
          if user_id == 0 then
              print("[AL:RP] "..name.." ("..playerIp..") rejected: identification error")
              return game.done("\n[AL:RP] Eroare la identificarea jucatorului.\n\nDiscord: discord.gg/armylegendsrp")
          end

          -- if user_id == -1 then
          --     print("[AL:RP] "..name.." ("..playerIp..") rejected: discord wasn't found")
          --     return game.done("\n[AL:RP] Discord-ul tau nu a fost gasit.\nTe rugam sa iti asociezi discord-ul pentru a te putea conecta.\n\nDiscord: discord.gg/armylegendsrp")
          -- end

          if user_id == -2 then
              print("[AL:RP] "..name.." ("..playerIp..") rejected: ^3token banat")
              return game.done("\n[AL:RP] Contul tau este banat.\nNu incerca sa scapi singur de ban!\nID-ul tau original este: "..rows.."\n\nDiscord: discord.gg/armylegendsrp")
          end
      end
  end)
end)

function vRP.deleteOnlineUser(user_id)
  local source = vRP.getUserSource(user_id)

  if source and vRP.rusers[user_id] then
      TriggerEvent("vRP:playerLeave", user_id, source, vRP.isPlayerSpawned(user_id))

      print("[vRP] user deleted from online users (user_id = "..user_id..")")
      vRP.users[vRP.rusers[user_id]] = nil
      vRP.rusers[user_id] = nil
      vRP.user_sources[user_id] = nil
      staffUsers[user_id] = nil
      CreateThread(function()
        Wait(1500)
        vRP.usersData[user_id] = nil
      end)
      
      hoursInt[user_id] = nil
  end
end

AddEventHandler("playerDropped",function(reason)
  local source = source
  local name = vRP.getPlayerName(source)

  if playerLoaded[source] then
    playerLoaded[source] = nil
  end

  TriggerClientEvent("id:removePlayer", -1, source)

  local user_id = vRP.getUserId(source)

  if user_id then
    TriggerEvent("vRP:playerLeave", user_id, source, vRP.isPlayerSpawned(user_id), reason or "No reason provided by server.")

    print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") disconnected (user_id = ^1"..user_id.."^0) Reason: ^1"..reason.."^0")
    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_sources[user_id] = nil
    staffUsers[user_id] = nil

    local hoursGained = math.floor(((os.time() - (hoursInt[user_id] or os.time())) / 3600) * 100) / 100
    hoursInt[user_id] = nil
    local updateQuery = {['$inc'] = {hoursPlayed = hoursGained, lastHours = hoursGained}, ['$set'] = {uData = vRP.usersData[user_id].uData, inventory = vRP.usersData[user_id].inventory, userAchievements = vRP.usersData[user_id].userAchievements, activeBag = vRP.usersData[user_id].activeBag}}

    Citizen.CreateThread(function()
      Wait(500)
      if not next(updateQuery["$set"]) then
        updateQuery["$set"] = nil
      end

      exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = updateQuery})
      Citizen.Wait(1000)
      vRP.usersData[user_id] = nil
    end)
  end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
  if user_id and vRP.usersData[user_id] then

    local logoutDetail = {
      user_id = user_id,
      time = os.time(),
      money = {
          wallet = vRP.getMoney(user_id) or 0,
          bank = vRP.getBankMoney(user_id) or 0,
          coins = vRP.getCoins(user_id) or 0
      },
      hours = vRP.getUserHoursPlayed(user_id),
      playerip = GetPlayerEndpoint(player)
    }

    exports.mongodb:insertOne({collection = "playerLogouts", document = logoutDetail})  
  end
end)

RegisterServerEvent("ples-idoverhead:setViewing")
AddEventHandler("ples-idoverhead:setViewing", function(val, activePlayers)
    local player = source
    for _, src in pairs(activePlayers) do
        TriggerClientEvent("ples-idoverhead:setCViewing", src, player, val)
    end
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
  local user_id = vRP.getUserId(source)
  local player = source
  if user_id then
    vRP.user_sources[user_id] = source

    if staffUsers[user_id] then
      staffUsers[user_id].src = source
    end

    vRP.usersData[user_id]['spawns'] += 1
    local first_spawn = (vRP.usersData[user_id]['spawns'] == 1)

    if first_spawn then
      for k,v in pairs(vRP.user_sources) do
          if user_id ~= k then
            TriggerClientEvent("id:initPlayer", source, v, k)
          end
      end

      TriggerClientEvent("id:initPlayer", -1, source, user_id)
      hoursPlayed[user_id] = tonumber(vRP.usersData[user_id].hoursPlayed or 0.0)
      lastHours[user_id] = tonumber(vRP.usersData[user_id].lastHours or 0.0)
      
      vRP.usersData[user_id]['joinTime'] = os.time()
      hoursInt[user_id] = vRP.usersData[user_id]['joinTime']

      local loginDetail = {
        user_id = user_id,
        time = os.time(),
        money = {
            wallet = vRP.getMoney(user_id) or 0,
            bank = vRP.getBankMoney(user_id) or 0,
            coins = vRP.getCoins(user_id) or 0
        },
        playerip = GetPlayerEndpoint(player)
      }

      exports.mongodb:insertOne({collection = "playerLogins", document = loginDetail})

      local quickLogin = {
          user_id = user_id,
          time = os.time(),
          hours = math.floor(hoursPlayed[user_id] * 100) / 100
      }
      exports.mongodb:insertOne({collection = "quickLogins", document = quickLogin})
    end
    Tunnel.setDestDelay(player, config.load_delay)
    SetTimeout(2000, function()
      if not first_spawn then
        TriggerEvent("vRP:playerSpawn", user_id, player, false)
      else
        TriggerEvent("vRP:playerSpawn", user_id, player, true, vRP.usersData[user_id])
        Citizen.Wait(10000)
        
        if vRP.usersData[user_id] then
          vRP.usersData[user_id].isSpawned = true
        end
      end
      SetTimeout(config.load_duration*1000, function()
        Tunnel.setDestDelay(player, config.global_delay)
      end)
    end)
  end
end)


RegisterServerEvent("vrp:X")
AddEventHandler("vrp:X", function(reason)
    local player = source
    local user_id = vRP.getUserId(player)
    if user_id > 3 then
        if vRP.getUserAdminLevel(user_id) < 4 then
            vRPclient.msg(-1, {"^1Server^7: "..GetPlayerName(player).." ["..user_id.."] a luat ^1BAN PERMANENT ^7de la ^9Anti^1Cheat"})
            vRP.ban(user_id, (reason or "Anticheat"), false, 0)
            DropPlayer(source, "Anticheat ce zici ?")
        elseif reason ~= "Spectate" then
            vRP.sendStaffMessage("^2Anticheat^0: "..GetPlayerName(player).." ["..user_id.."] ar trebuii sa ia ban permanent pentru: "..reason)
        end
    else
        for i=1, 10 do
            Wait(100)
            vRPclient.msg(player, {"^1SCOATE HACK ! ("..reason..")"})
        end
    end
end)

function tvRP.askForBan(src)
    local player = source
    local user_id = vRP.getUserId(player)
    if user_id > 3 then
        vRPclient.msg(-1, {"^1Server^7: "..GetPlayerName(player).." ["..user_id.."] a luat ^1BAN PERMANENT ^7de la ^9Anti^1Cheat"})
        vRP.ban(user_id, "Injection", false, 0)
    else
        for i=1,10 do
            Wait(100)
            vRPclient.msg(player, {"^1SCOATE HACK !"})
        end
    end
end

RegisterServerEvent("vRP:playerDied")

local restarting = false

function isServerRestarting()
    return restarting
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining <= 300 then
        restarting = true
    end
    
    if eventData.secondsRemaining == 60 then
        Citizen.CreateThread(function()
            Citizen.Wait(20000)
            ExecuteCommand("kickall")
        end)
    end
end)

RegisterCommand('kickall', function(source, args, rawCommand)
  if source == 0 or vRP.getUserAdminLevel(vRP.getUserId(source)) >= 6 then
    TriggerEvent("onServerRestarting")

    Citizen.CreateThread(function()
      local usrr = vRP.getUsers()
      for uid, src in pairs(usrr) do
        Citizen.Wait(50)
        saveUDataInDb(uid)
      end
    end)

    restarting = true

    if(rawCommand:sub(9) == nil) or (rawCommand:sub(9) == "")then
      reason = "Restart-urile sunt date in spre binele jucatorilor, si acestea dureaza in jur de 2-3 minute.\nPentru mai multe detalii poti intra pe discord: discord.gg/armylegendsrp"
    else
      reason = rawCommand:sub(9)
    end
    
    TriggerClientEvent("adminMessage", -1, "Server", "Atentie! Serverul se restarteaza in 30 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
    print("30 DE SECUNDE PANA LA RESTART!")

    SetTimeout(10000, function()
      TriggerClientEvent("adminMessage", -1, "Server", "Atentie! Serverul se restarteaza in 20 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
      print("20 DE SECUNDE PANA LA RESTART!")
      
      SetTimeout(10000, function()
        TriggerClientEvent("adminMessage", -1, "Server", "Atentie! Serverul se restarteaza in 10 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
        print("10 DE SECUNDE PANA LA RESTART!")
        
        SetTimeout(5000, function()
          TriggerClientEvent("adminMessage", -1, "Server", "Atentie! Serverul se restarteaza in 5 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
          print("5 DE SECUNDE PANA LA RESTART!")
          
          local users = vRP.getUsers()
          for i, v in pairs(users) do
            vRP.kick(v,reason)
          end
          Wait(3000)
          print("\n\n RESTART DONE \n\n")
        end)
      end)
    end)
  else
    vRPclient.noAccess(source)
  end
end)

RegisterCommand("loadwhitelist", function(src)
  if src == 0 then
    whitelisted = json.decode(LoadResourceFile("vrp", "whitelisted.json")) or {}
    print("[vRP] Whitelist reloaded ("..table.len(whitelisted).." users)!")
  end
end)

RegisterCommand("togwhitelist", function(src)
  if src == 0 then
    config.whitelist = not config.whitelist
    print("[vRP] Server under maintenance: "..(config.whitelist and "^2YES^7" or "^1NO^7"))
  end
end)

RegisterCommand("togpassword", function(player, args)
  if player == 0 or IsPlayerAceAllowed(player, "command") or vRP.getUserAdminLevel(user_id) >= 6 then
    config.password = args[1] or false
    print("[vRP] Server requires password: "..(config.password and "^2YES ^3("..config.password..")^7" or "^1NO^7"))
  end
end)

RegisterCommand("togopening", function(player, args)
  if player == 0 or IsPlayerAceAllowed(player, "command") then
    isOpeningDay = not isOpeningDay
    print("[AL:RP] Opening day state: "..(isOpeningDay and "^2YES^7" or "^1NO^7"))
  end
end)

RegisterCommand("listwhitelist", function(src)
  if src == 0 then
    print("Pe lista alba sunt in total " .. table.len(whitelisted) .. " (de) jucatori")
    print("---------------")
    print("Nume   ID   Acceptat")
    for user_id, state in pairs(whitelisted) do
        local uSrc = vRP.getUserSource(tonumber(user_id))
        print((uSrc and GetPlayerName(uSrc) or "Necunoscut").." ["..user_id.."] - "..(state and "Da" or "Nu"))
    end
    print("---------------")
  end
end)

RegisterCommand("addwhitelist", function(player, args)
  if player == 0 then
    if tonumber(args[1]) then
      vRP.setWhitelisted(tonumber(args[1]), true)
    end
  end
end)

RegisterCommand("logtunnel", function(player)
  local user_id = vRP.getUserId(player)
  if vRP.getUserAdminLevel(user_id) < 5 then
    return vRPclient.noAccess(player)
  end
  TriggerClientEvent("tunnel:toggleLogs", player)
end)

SetMapName("Los Santos")
SetGameType("Roleplay")