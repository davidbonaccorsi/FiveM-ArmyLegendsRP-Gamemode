registerCallback('getMenuData', function(player)
    local user_id = vRP.getUserId(player)

    return  {
        cash = vRP.getMoney(user_id),
        bank = vRP.getBankMoney(user_id),
        coins = vRP.getCoins(user_id),
        refferal = user_id,
        username = GetPlayerName(player),
    }
end)

registerCallback('menu:userData', function(player)
    local user_id = vRP.getUserId(player)
    local identity = vRP.getIdentity(user_id) or {sex = "M"}
    local faction = vRP.getUserFaction(user_id)

    if faction == "user" then
        faction = "Not in a faction"
    end

    local warnsNr = 0
    vRP.getWarnsNum(user_id, function(warnsNr)
        warnsNr = warnsNr
    end)

    local data = {
        user_id = user_id,
        faction = faction,
        coins = vRP.getCoins(user_id),
        sex = identity.sex:lower(),
        phone = identity.phone,
        prime = vRP.isUserVip(user_id),
        warns = warnsNr,
    }

    data.sessionTime = ("%d H. %d M."):format(vRP.getUserHoursPlayedInThisSession(user_id, 1))
    data.hoursPlayed = vRP.getUserHoursPlayed(user_id)
    data.adminJails = vRP.getAdminJails(user_id)

    local houses, totalHouses = exports["vrp_housing"]:getUserHouse(user_id) or {}

    data.houses = houses
    data.totalHouses = totalHouses

    local cars, tbl = {}, vRP.getUserVehicles(user_id)
    for car, data in pairs(tbl) do
        table.insert(cars, data)
    end

    data.cars = cars
    data.totalCars = #cars

    return data
end)


RegisterCommand("jobs", function(player, args)
    vRPclient.sendInfo(player, {"Foloseste tasta ^5M ^7pentru a deschide Meniul Principal."})
end)
