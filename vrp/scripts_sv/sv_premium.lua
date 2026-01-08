
local cfg = module("cfg/vip")

RegisterServerEvent("vrp-premium:getProduct", function(product)
    local player = source
    local user_id = vRP.getUserId(player)

    if user_id and product then
        TriggerEvent("vrp-premium:onBoughtProduct", user_id, player, product)
    end

end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if startsWith(choice, "money:") then
        local money = tonumber(sanitizeString(choice, "0123456789", true))
        if money > 0 then
            local dmd = 0
            for _, v in pairs(cfg.money) do
                if v[1] == money then
                    dmd = v[2]
                    break
                end
            end
            if dmd > 0 then
                if vRP.tryCoinsPayment(user_id, dmd, choice, true) then
                    vRP.giveBankMoney(user_id, money, "Shop")

                    exports["vrp_phone"]:sendMessage(user_id, {
                        message = [[
                            Salutare, ]]..GetPlayerName(player)..[[!
                            <br>Tocmai ai achizitionat $]]..vRP.formatMoney(money)..[[.<br>
                            <br><br>Iti multumim pentru sustinere.<br>
                            - ArmyLegends Romania
                        ]],
                        sender = "0101-0101",
                        type = "message"
                    })
                end
            end
        end
    end
end)

local function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.mongodb:count({collection = "userVehicles", query = {["carPlate"] = plate_number}}, function(success, result)
	  task({result})
	end)
end

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if startsWith(choice, "car:") then
        local model = choice:sub(5)
        local v = cfg.cars[model]

        if v then
            local dmd = v[2] or 0

            if dmd > 0 then
                if not exports.vrp:isUserOwningVehicle(user_id, model) then
                    if vRP.tryCoinsPayment(user_id, dmd, choice, true) then

                        local carPlate = "RX00ERR"
                        local function searchOne()
                            carPlate = vRP.generatePlateNumber()
                        
                            getIdentifierByPlateNumber(carPlate, function(onePlate)
                                if not onePlate or onePlate ~= 0 then
                                    searchOne()
                                end
                            end)
                        end
                        searchOne()
                        
                        local newVehicle = {
                            user_id = user_id,
                            vehicle = model,
                            vtype = v[3] or "ds",
                            name = v[1],
                            carPlate = carPlate,
                            state = 1,
                            premium = true
                        }
            
                        exports.mongodb:insertOne({collection = "userVehicles", document = newVehicle})
                        vRP.addCacheVehicle(user_id, newVehicle)

                        vRP.createLog(user_id, {price = dmd, vehicle = model, vehicle_name = newVehicle.name, plate = carPlate, name = GetPlayerName(player)}, "PremiumCarPurchase")

                        exports["vrp_phone"]:sendMessage(user_id, {
                            message = [[
                                Salutare, ]]..GetPlayerName(player)..[[!
                                <br>Tocmai ai achizitionat vehiculul ]]..v[1]..[[, acesta
                                ti-a fost livrat in garaj.
                                <br><br>Iti multumim pentru sustinere.<br>
                                - ArmyLegends Romania
                            ]],
                            sender = "0101-0101",
                            type = "message"
                        })
                    end
                else
                    vRPclient.notify(player, {"Detii deja acest vehicul pe cont.", "error"})
                end
            end
        end
    end
end)


AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "starterpack" then
        if vRP.getUserHoursPlayed(user_id) <= 25 and not vRP.usersData[user_id].starterPack then
            if vRP.tryCoinsPayment(user_id, cfg.starterPack, choice, true) then

                local expireTime = os.time() + daysToSeconds(14)

                vRP.giveBankMoney(user_id, cfg.starterMoney, "Starter Pack")
                vRP.addUserGroup(user_id, "doubleXp", expireTime)
                
                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat Newbie Set, acesta contine:<br>
                        - Haine<br>
                        - +$150,000 in banca<br>
                        - Prime (30 de zile)<br>
                        <br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })

                vRP.giveLevel(user_id, 15)

                local identity = vRP.getIdentity(user_id)

                -- for k, item in pairs(cfg.starterClothes[identity.sex:lower()]) do
                --     vRP.giveItem(user_id, item, 1)
                -- end

                vRP.updateUser(user_id, "starterPack", true, 1)
                
                local expireTime = os.time() + daysToSeconds(30)
                local theGrade, vipLvl = "vip:1", 1

                vRP.setUserVip(user_id, tonumber(vipLvl))
                vRP.updateUser(user_id, 'userVip', {
                    expireTime = expireTime,
                    vip = tonumber(vipLvl),
                })

                if tonumber(vipLvl) > 1 then
                    TriggerClientEvent("afk-kick:setPrime", player, 3600)
                end

                local bonusMoney = cfg.vipMoney[vipLvl]
                if bonusMoney > 0 then
                    vRP.giveBankMoney(user_id, bonusMoney, "VIP")
                end

                for k, v in pairs(cfg.vipVouchers[theGrade] or {}) do
                    vRP.setUserPremiumVoucher(user_id, v[1], v[2])
                    vRP.giveItem(user_id, v[1], v[2])
                end

            end
        end
    end
end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "clearwarn" then
        vRP.getWarnsNum(user_id, function(warns)
            if warns > 0 then
                if vRP.tryCoinsPayment(user_id, cfg.clearWarnPrice, choice, true) then
                    vRP.removeWarn(user_id)
                    vRPclient.notify(player, {"Ti-a fost sters un warn de pe cont, acum mai ai: "..(warns-1).."/3"})
                end
            else
                vRPclient.notify(player, {"Nu ai un warn activ pe cont.", "error"})
            end
        end)
    end
end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "carplate" then
        if vRP.tryCoinsPayment(user_id, 5, choice, true) then
			vRP.giveInventoryItem(user_id, "car_plate_voucher", 1, true)
			vRPclient.notify(player, {"🪙 Ai cumparat 1x Number Plate", "info"})
            exports["vrp_phone"]:sendMessage(user_id, {
                message = [[
                    Salutare, ]]..GetPlayerName(player)..[[!
                    <br>Tocmai ai achizitionat un numar de inmatriculare custom.<br>
                    <br><br>Iti multumim pentru sustinere.<br>
                    - ArmyLegends Romania
                ]],
                sender = "0101-0101",
                type = "message"
            })
			-- vRP.createLog(user_id, {detail = name.." ["..user_id.."] si-a cumparat: 1x Plate Number cu 5 Premium Coins", "premiumShop"}, "plate-vouchers")	
		end
    end
end)


AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "resetcharacter" then
        if vRP.tryCoinsPayment(user_id, 5, choice, true) then
			exports["vrp"]:createCharacter(user_id, user_id, true)
            exports["vrp_phone"]:sendMessage(user_id, {
                message = [[
                    Salutare, ]]..GetPlayerName(player)..[[!
                    <br>Tocmai ai achizitionat o resetare a caracterului.<br>
                    <br><br>Iti multumim pentru sustinere.<br>
                    - ArmyLegends Romania
                ]],
                sender = "0101-0101",
                type = "message"
            })
		end
    end
end)


AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "weapondealer" then
        if not vRP.hasPermission(user_id, "weapon.dealer") then
            local grade = "Weapon Dealer"
            local expireTime = os.time() + daysToSeconds(cfg.grades[grade][1])
            if vRP.tryCoinsPayment(user_id, cfg.grades[grade][2], choice, true) then
                vRP.addUserGroup(user_id, grade, expireTime)
                exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                    ["$set"] = {
                        ["userGrades."..grade] = {grade = grade, expireTime = expireTime, time = os.time()}
                    }
                }})
                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat Weapon Dealer.<br>
                        <br><br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })
            end
        else
            vRPclient.notify(player, {"Esti deja Traficant de arme !", "error"})
        end
    end
end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "sponsor" then
        if not vRP.hasGroup(user_id, "sponsors") then
            local grade = "sponsors"
            local expireTime = os.time() + daysToSeconds(cfg.grades[grade][1])
            if vRP.tryCoinsPayment(user_id, cfg.grades[grade][2], choice, true) then
                vRP.addUserGroup(user_id, grade, expireTime)
                exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                    ["$set"] = {
                        ["userGrades."..grade] = {grade = grade, expireTime = expireTime, time = os.time()}
                    }
                }})
                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat Sponsor.<br>
                        <br><br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })
            end
        else
            vRPclient.notify(player, {"Esti deja un Sponsor !", "error"})
        end
    end
end)

function is_valid_format(str)
	return string.match(str, "^%d%d%d%-%d%d%d%d$") ~= nil
end

local function getIdentifierByPhoneNumber(phone_number, cbr) 
    local task = Task(cbr, {0}, 2000)
  
    exports.mongodb:count({collection = "users", query = {['userIdentity.phone'] = phone_number}}, function(success, result)
      task({result})
    end)
end

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "buynr" then
        if vRP.tryCoinsPayment(user_id, 5, choice, true) then
            vRP.prompt(player, "CUSTOM PHONE NUMBER", "NUMAR DE TELEFON (XXX-XXXX)", false, function(ret)
                print(ret)
                local phone_number = ret
                if is_valid_format(phone_number) then
                    getIdentifierByPhoneNumber(tostring(phone_number), function(hasPhone)
                        if not hasPhone or hasPhone == 0 then
                            if vRP.tryCoinsPayment(user_id, 3) then
                                vRP.setPhoneNumber(user_id, tostring(phone_number))

                                vRPclient.notify(player, {"Pentru a se updata numarul de telefon trebuie sa dai restart la joc.", "warn"})

                                exports["vrp_phone"]:sendMessage(user_id, {
                                    message = [[
                                        Salutare, ]]..GetPlayerName(player)..[[!
                                        <br>Tocmai ai achizitionat un numar custom de telefon.<br>
                                        <br><br>Iti multumim pentru sustinere.<br>
                                        - ArmyLegends Romania
                                    ]],
                                    sender = "0101-0101",
                                    type = "message"
                                })
                            else
                                vRPclient.notify(player, {"Nu ai destui Legend Coins", "error"})
                            end
                        else
                            return vRPclient.notify(player, {"Acest numar este deja detinu de catre o persoana, alege alt numar!", "error"})
                        end
                    end)
                else
                    return vRPclient.notify(player, {"Formatul nu a fost respectat!", "error"})
                end
            end)
        end
    end
end)


AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "buyxenon" then
        if vRP.tryCoinsPayment(user_id, 5, choice, true) then
            if not hasPhone or hasPhone == 0 then
                vRP.giveItem(user_id, 'premium_xenon', 1, false, false, false, 'Shop')

                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat un xenon.<br>
                        <br><br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })
            end
        end
    end
end)


AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "doublexp" then
        if not vRP.hasGroup(user_id, "doubleXp") then
            local grade = "doubleXp"
            local expireTime = os.time() + daysToSeconds(14)
            if vRP.tryCoinsPayment(user_id, cfg.doubleXpPrice, choice, true) then
                vRP.addUserGroup(user_id, grade, expireTime)
                exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                    ["$set"] = {
                        ["userGrades."..grade] = {grade = grade, expireTime = expireTime, time = os.time()}
                    }
                }})
                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat Double XP.<br>
                        <br><br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })
            end
        else
            vRPclient.notify(player, {"Ai deja Double Xp !", "error"})
        end
    end
end)

AddEventHandler("vrp-premium:onBoughtProduct", function(user_id, player, choice)
    if choice == "gunpermit" then
        if not vRP.hasPermission(user_id, "permis.arma") then
            local grade = "Permis Port Arma"
            local expireTime = os.time() + daysToSeconds(cfg.grades[grade][1])
            if vRP.tryCoinsPayment(user_id, cfg.grades[grade][2], choice, true) then
                vRP.addUserGroup(user_id, grade, expireTime)
                exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                    ["$set"] = {
                        ["userGrades."..grade] = {grade = grade, expireTime = expireTime, time = os.time()}
                    }
                }})
                exports["vrp_phone"]:sendMessage(user_id, {
                    message = [[
                        Salutare, ]]..GetPlayerName(player)..[[!
                        <br>Tocmai ai achizitionat Permis Port Arma.<br>
                        <br><br>Iti multumim pentru sustinere.<br>
                        - ArmyLegends Romania
                    ]],
                    sender = "0101-0101",
                    type = "message"
                })
            end
        else
            vRPclient.notify(player, {"Ai deja Permis Port Arma !", "error"})
        end
    end
end)

for k, voucher in pairs(cfg.vouchers.vehicle) do
    local balance = tonumber(voucher:sub(17))
    vRP.defInventoryItem(voucher, "Vehicle Voucher "..balance.."FC", "Cu acest voucher puteti cumpara vehicule premium de maxim "..balance.."FC", function(player)
        local user_id = vRP.getUserId(player)

        local elligibleCars = {}
        for k, v in pairs(cfg.cars) do
            if v[2] <= balance and k ~= "serv_electricscooter" then
                table.insert(elligibleCars, {v[1], k})
            end
        end

        vRP.selectorMenu(player, 'PREMIUM SHOP', elligibleCars, function(choice)
            if choice and not exports.vrp:isUserOwningVehicle(user_id, choice) then
                local vouchers = vRP.getUserPremiumVoucher(user_id, "vehicle_voucher_"..balance)
                if vRP.removeItem(user_id, "vehicle_voucher_"..balance) and vouchers > 0 then
                    vRP.setUserPremiumVoucher(user_id, "vehicle_voucher_"..balance, vouchers-1)

                    local carPlate = "RX00ERR"
                    local function searchOne()
                        carPlate = vRP.generatePlateNumber()
                    
                        getIdentifierByPlateNumber(carPlate, function(onePlate)
                            if not onePlate or onePlate ~= 0 then
                                searchOne()
                            end
                        end)
                    end

                    searchOne()

                    local v = cfg.cars[choice]
                    
                    local newVehicle = {
                        user_id = user_id,
                        vehicle = choice,
                        vtype = v[3] or "ds",
                        name = v[1],
                        carPlate = carPlate,
                        state = 1,
                        premium = true
                    }
        
                    exports.mongodb:insertOne({collection = "userVehicles", document = newVehicle})
                    vRP.addCacheVehicle(user_id, newVehicle)
                    vRPclient.notify(player, {"Vehiculul ti-a fost adaugat in garaj!"})
                elseif vouchers <= 0 then
                    vRPclient.notify(player, {"Nu detii acest voucher.", "error"})
                end
            end
        end)
    end, 0, 'premium')
end

local function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.mongodb:count({collection = "userVehicles", query = {["carPlate"] = plate_number}}, function(success, result)
	  task({result})
	end)
end

vRP.defInventoryItem(cfg.vouchers.carplate, "Car Plate Voucher", "Cu acest voucher poti schimba placuta unui vehicul detinut", function(player)
    local user_id = vRP.getUserId(player)

    vRPclient.getNearestOwnedVehicle(player, {5}, function(name)
        if name then
            vRP.prompt(player,"NUMBER PLATE", "Introdu in caseta de mai jos placuta dorita apoi apasa pe butonul de confirmare.", false, function(vehPlate)
                if vehPlate then
                    if string.match(vehPlate, "%d%d%a%a%a") then
                        local vehicle_plate = "LS " .. vehPlate:upper()
                        if (string.len(vehicle_plate) <= 8) then

                            local clean = sanitizeString(vehicle_plate, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", true)
                            if clean:sub(3) ~= vehicle_plate:sub(4) then
                                vRPclient.notify(player, {"Placuta poate contine doar numere si litere!"})
                            else
                                getIdentifierByPlateNumber(vehicle_plate, function(plate)
                                    if plate and plate > 0 then
                                        return vRPclient.notify(player, {"Aceasta placuta de inmatriculare este detinuta deja de cineva!"})
                                    else
                                        local vouchers = vRP.getUserPremiumVoucher(user_id, "car_plate_voucher")
                                        if vRP.removeItem(user_id, 'car_plate_voucher') and vouchers > 0 then
                                            vRP.setUserPremiumVoucher(user_id, "car_plate_voucher", vouchers-1)                            

                                            vRPclient.notify(player, {"Placuta de inmatriculare a fost schimbata in: " .. vehicle_plate})
                                            vRP.updateCarPlate(user_id, name, vehicle_plate)
                                            vRPclient.despawnGarageVehicle(player, {name, 15})
                                        elseif vouchers <= 0 then
                                            vRPclient.notify(player, {"Nu detii acest voucher.", "error"})
                                        end
                                    end
                                end)
                            end
                        else
                            vRPclient.notify(player, {"Placuta de inmatriculare nu poate avea mai mult de 8 caractere", "error"})
                        end

                    else
                        vRPclient.notify(player, {"Formatul nu a fost respectat! Format: 2 cifre + 3 litere la alegere (ex: 21SEB )", "error"})
                    end
                end
            end)
        else
            vRPclient.notify(player, {"Nici un vehicul detinut in jurul tau.", "error"})
        end
    end)
end, 0, 'premium')