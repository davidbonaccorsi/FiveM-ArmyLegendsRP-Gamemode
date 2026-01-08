
local topPlayers = {}

local updateInterval = 5 * (60 * 60000) -- 5 * h  = 5h

Citizen.CreateThread(function()
    while true do
        local results = exports.mongodb:aggregate({collection = "users", pipeline = {
            {
                ['$project'] = {
                    _id = 0,
                    id = 1,
                    username = 1,
                    hoursPlayed = 1,
                }
            },
            {
                ['$sort'] = {
                    hoursPlayed = -1
                }
            },
            {
                ['$limit'] = 5
            }
        }})

        topPlayers = results or {}

        Citizen.Wait(updateInterval)
    end
end)


RegisterServerEvent("vrp-stats:openPlayer", function()
    local player = source
    local user_id = vRP.getUserId(player)
    local user = vRP.getUser(user_id) or {}

    vRP.getWarnsNum(user_id, function(warnsNr)
        local houseCount, userHouses = exports['playerhousing']:getUserHouses(user_id)

        local vehicles = {}
        for k, v in pairs(exports["vrp"]:getUserVehiclesTbl(user_id)) do
            if (v.vtype or "ds") ~= "ds" then goto skipModel end
            vehicles[k] = v.name
            ::skipModel::
        end

        TriggerClientEvent("vrp:sendNuiMessage", player, {
            interface = "statistics",
            data = {
                id = user_id,
                username = GetPlayerName(player),
                vehicles = vehicles or {},
                hours = vRP.getUserHoursPlayed(user_id) or 0,
                weekHours = vRP.getUserLastHours(user_id) or 0,
                level = vRP.getLevel(user_id) or 1,
                playtime = ("%d ore, %d minute si %d secunde."):format(vRP.getUserHoursPlayedInThisSession(user_id, 1, true)),
                prime = vRP.isUserVip(user_id),
                doubleXp = vRP.hasGroup(user_id, "doubleXp"),
                warns = tonumber(warnsNr),
                markets = exports["vrp"]:getUserMarketsCount(user_id),
                houses = houseCount,
                investments = user.investedTimes or 0,
                bans = user.totalBans or 0,
                top = topPlayers,
            }
        })
    end)
end)
