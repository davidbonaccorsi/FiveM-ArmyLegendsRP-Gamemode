
local function tryLevelUp(user_id, exp, need)
  if exp and need then
    if exp >= need then
      local tmp = vRP.getUserTmpTable(user_id)
      if tmp then
        local source = vRP.getUserSource(user_id)
        tmp.level = tmp.level + 1
        tmp.xp = tmp.xp - need
        tmp.need = math.floor(tmp.need + tmp.need * 0.15)
        TriggerClientEvent("chatMessage", source, "^9ArmyLegends Roleplay^7: Felicitari, ai ajuns la nivelul ^1"..tmp.level.."!")
        tryLevelUp(user_id, tmp.xp, tmp.need)
      end
    end
  end
end

local function saveUserLevel(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp and tmp.level ~= nil and tmp.xp ~= nil and tmp.need ~= nil then
    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
      ['$set'] = {
        ['userLevel.level'] = tmp.level,
        ['userLevel.exp'] = tmp.xp,
        ['userLevel.need'] = tmp.need
      }
    }})
  end
end

function vRP.getNeedToLevelUp(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.need or 60
  else
    return 0
  end
end

-- get level
function vRP.getLevel(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.level or 1
  else
    return 0
  end
end

-- set level
function vRP.setLevel(user_id, value)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.level = value
    --print(user_id .. ": " .. tmp.level .. " " .. tmp.xp .. " " .. tmp.need)
  end
end

-- give Level
function vRP.giveLevel(user_id, value)
    local amount = vRP.getLevel(user_id) + value
    if amount > 0 then
      vRP.setLevel(user_id, amount)
    end
end

function vRP.hasLevel(user_id, level)
  return (level <= vRP.getLevel(user_id)) or false
end

-- get Exp
function vRP.getXp(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.xp or 0
  else
    return 0
  end
end

-- set Xp
function vRP.setXp(user_id, value)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.xp = value
    tryLevelUp(user_id, tmp.xp, tmp.need)
    Citizen.CreateThread(function()
      Wait(1000)
      saveUserLevel(user_id)
    end)
  end
end

-- give Xp
function vRP.giveXp(user_id, value)
    if vRP.hasGroup(user_id, "doubleXp") then
      value = value * 2
    end

    local nowXp = vRP.getXp(user_id)
    local amount = nowXp + value
    if amount > 0 then
        local source = vRP.getUserSource(user_id)

      vRPclient.showXpBar(source, {0, vRP.getNeedToLevelUp(user_id), nowXp, amount, vRP.getLevel(user_id)})

      vRP.setXp(user_id, amount)
    end
end

function tvRP.getLevelInfo()
  local player = source
  local user_id = vRP.getUserId(player)
  if user_id then
    return {
      xp = math.floor(vRP.getXp(user_id)),
      level = vRP.getLevel(user_id),
      need = vRP.getNeedToLevelUp(user_id)
    }
  end
end

AddEventHandler("vRP:playerJoin",function(user_id,source,name,extraData)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    local rows = extraData.userLevel or {level = 1, exp = 0, need = 60}
    tmp.level = rows.level
    tmp.xp = rows.exp
    tmp.need = rows.need
  end
end)

-- save level on leave
AddEventHandler("vRP:playerLeave", function(user_id,source)
    saveUserLevel(user_id)
end)