local cfg = module('cfg/fuelstation')
local gas_business = {}
local fuelPrice = 7

Citizen.CreateThread(function()
	Citizen.Wait(2500)
	exports.mongodb:find({collection = "gas_business", query = {}}, function(success, result)
		for _, data in pairs(result) do
			gas_business[data.gasId] = data;
		end
	end)
end)

RegisterServerEvent('vrp-fuelstation:businessMenu', function(gasId)
    local player = source
    local user_id = vRP.getUserId(player)

    if gas_business[gasId] then
        if gas_business[gasId].owner == user_id then
            local data = gas_business[gasId]

            TriggerClientEvent('vrp:sendNuiMessage', player, {
                interface = 'fuelStation',
                data = {
                    menu = 'business',
                    fuelStation = gasId,
                    maxPrice = cfg.maxPrice,
                    minPrice = cfg.minPrice,
                    money = data.money,
                    fuelLevel = data.fuelLevel,
                    currentPrice = data.fuelPrice,
                }
            })
        else
            vRPclient.notify(player, {'Doar proprietarul poate accesa meniul acestei benzinari!', 'error'})
        end
    else
        vRP.request(player, 'Doresti sa cumperi aceasta benzinarie pentru suma de '..vRP.formatMoney(cfg.fuelStationPrice)..'$ ?', false, function(_, ok)
            if ok then
                if vRP.tryPayment(user_id, cfg.fuelStationPrice, true, "Fuel station") then
                    vRPclient.notify(player, {"Ai cumparat aceasta benzinarie", "success"})
                    gas_business[gasId] = {
                        gasId = gasId,
                        owner = user_id,
                        fuelLevel = 100,
                        fuelPrice = fuelPrice,
                        money = 0,
                    }
                    exports.mongodb:insertOne({collection = "gas_business", document = gas_business[gasId]})
                else
                    vRPclient.notify(player, {"Nu ai suficienti bani", "error"})
                end
            end
        end)
    end
end)

exports('setGasOwner', function(user_id, gasId)
    if gas_business[gasId] then
        gas_business[gasId].owner = user_id
        exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {owner = user_id}}})
    else
        gas_business[gasId] = {
            gasId = gasId,
            owner = user_id,
            fuelLevel = 100,
            fuelPrice = fuelPrice,
            money = 0,
        }
        exports.mongodb:insertOne({collection = "gas_business", document = gas_business[gasId]})
    end
end)

RegisterServerEvent("vrp-fuelstation:sellStation", function(gasId)
    local player = source
    local user_id = vRP.getUserId(player)

    if gas_business[gasId] and gas_business[gasId].owner == user_id then
        vRPclient.getNearestPlayer(player, {15}, function(target_src)
            if not target_src then return vRPclient.notify(player, {"Nu este niciun jucator in apropiere", "error"}) end
            local target_id = vRP.getUserId(target_src)

            vRP.prompt(player, "VINDE BENZINARIA", "Introdu in caseta de mai jos <span style='color: var(--prompt-yellow);'>suma</span> pe care o doresti pe benzinarie apoi apasa pe butonul de confirmare.", false, function(amount)
                amount = tonumber(amount)
                if amount and amount > 0 then

                    vRP.request(player, 'Doresti sa vinzi benzinaria pentru suma de '..vRP.formatMoney(amount)..'$ ?', false, function(_, ok)
                        if not ok then return end;

                        vRP.request(target_src, 'Doresti sa cumperi aceasta benzinarie pentru suma de '..vRP.formatMoney(amount)..'$ ?', false, function(_, ok)
                            if not ok then return vRPclient.notify(player, {"Jucatorul nu a acceptat sa cumpere benzinaria", "error"}) end;

                            if vRP.tryPayment(target_id, amount, true, "Buy Fuel Station from "..user_id) then
                                vRPclient.notify(player, {"Ai vandut aceasta benzinarie", "success"})
                                vRPclient.notify(target_src, {"Ai cumparat aceasta benzinarie", "success"})

                                gas_business[gasId].owner = target_id
                                exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {owner = target_id}}})
                            else
                                vRPclient.notify(target_src, {"Nu ai suficienti bani", "error"})
                                vRPclient.notify(player, {"Jucatorul nu are suficienti bani", "error"})
                            end
                        end)
                    end)
                end
            end)
        end)
    end
end)

RegisterServerEvent("vrp-fuelstation:updatePrice", function(gasId, price)
    local player = source
    local user_id = vRP.getUserId(player)

    print(gasId, price)

    if gas_business[gasId] and gas_business[gasId].owner == user_id then
        if price ~= gas_business[gasId].fuelPrice then
            gas_business[gasId].fuelPrice = price         

            exports.mongodb:updateOne({collection = "gas_business", query = {gasId = gasId}, update = {["$set"] = {fuelPrice = price}}})
        end
     end
end)

RegisterServerEvent('vrp-fuelstation:withdrawBalance', function(gasId)
    local player = source
    local user_id = vRP.getUserId(player)

    if gas_business[gasId] and gas_business[gasId].owner == user_id then
        if gas_business[gasId].money > 0 then
            vRPclient.notify(player, {"Ai retras $"..vRP.formatMoney(gas_business[gasId].money)..' din balanta benzinariei!', "success"})
            vRP.giveMoney(user_id, gas_business[gasId].money, 'Fuel station')
            gas_business[gasId].money = 0

            exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {money = 0}}})
        else
            vRPclient.notify(player, {"Benzinaria ta nu dispune de o balanta pe care sa o poti retrage!", "error"})
        end
    end
end)

RegisterServerEvent('vrp-fuelstation:addFuel', function(gasId)
local player = source
    local user_id = vRP.getUserId(player)

    if gas_business[gasId] and gas_business[gasId].owner == user_id then
        vRP.prompt(player, "ADAUGA COMBUSTIBIL", "Introdu in caseta de mai jos <span style='color: var(--prompt-yellow);'>cantitatea</span> de combustibil pe care doresti sa o adaugi in benzinaria ta.", false, function(amount)
            amount = parseInt(amount)

            if amount and amount > 0 then
                if vRP.removeItem(user_id, 'petrol_nerafinat', amount) then
                    gas_business[gasId].fuelLevel += amount

                    vRPclient.notify(player, {"Ai adaugat "..amount.." litri de combustibil in benzinaria ta", "success"})
                    exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {fuelLevel = gas_business[gasId].fuelLevel}}})
                end
            end
        end)
    end
end)

registerCallback('canPayFuel', function(player, gasId, amount, payment)
    amount = tonumber(amount)
    local user_id = vRP.getUserId(player)
    local buyPrice = gas_business[gasId] and gas_business[gasId].fuelPrice or fuelPrice
    local price = tonumber(amount * buyPrice)

    if (payment == 'cash' and vRP.tryPayment(user_id, price, false, "Refuel")) or (payment == 'card' and vRP.tryBankPayment(user_id, price, false, false, "Refuel")) then
    
        exports.vrp:achieve(user_id, 'CombustibilEasy', 1)

        if gas_business[gasId] then
            gas_business[gasId].fuelLevel -= amount
            gas_business[gasId].money += price
            exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {money = gas_business[gasId].money, fuelLevel = gas_business[gasId].fuelLevel}}})
        end
        
        return true
    end

    return false
end)

registerCallback('canPayElectricFuel', function(player, amount)
    local user_id = vRP.getUserId(player)

    if vRP.tryPayment(user_id, amount, false, "Electric Refuel") then
        exports.vrp:achieve(user_id, 'ElectricCarEasy', 1)

        return true
    end

    return false
end)

registerCallback('getFuelStationData', function(player, gasId)
    local user_id = vRP.getUserId(player)
    local gasPrice = gas_business[gasId] and gas_business[gasId].fuelPrice or fuelPrice

    print(gasId)

    local fuelLevel = gas_business[gasId] and gas_business[gasId].fuelLevel or 100

    return gasPrice, fuelLevel, vRP.getMoney(user_id)
end)

RegisterServerEvent('vRP:buyFuelStationProduct', function(gasId, product)
    local player = source;
    local user_id = vRP.getUserId(player)
    

    if product == 'gas' then
        if vRP.tryPayment(user_id, 50, true, "Fuel Can") then
            if gas_business[gasId] then
                gas_business[gasId].money += 50;
                exports.mongodb:updateOne({collection = "gas_business", query =  {gasId = gasId}, update = {["$set"] = {money = gas_business[gasId].money}}})
            end    
            vRPclient.notify(source, {"Ai platit $50", "success"})
            vRP.giveItem(user_id, "fuelcan", 1, false, false, false, 'Fuel Station')
        end
    end
end)
