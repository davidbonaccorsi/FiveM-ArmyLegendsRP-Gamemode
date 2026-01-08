local cfg = module('cfg/inventory')
cfg = table.clone(cfg)

local equipedWeapons, lastAmmoUpdate, ammo, updateBullets = {}, {},  {}, false
local userInventory, userMaxWeight, hasBag, sex, equipedClothes, otherInventory, equipedSlots, otherInvData = {}, 0.0, false, "M", {}, {}, {}, {}
local backpacks <const> = {
	["ghiozdanMic"] = true,
	["ghiozdanMediu"] = true,
	["ghiozdanMare"] = true,
}

RegisterNetEvent('vrp-inventory:setInventoryData', function(invData, maxWeight, otherInv)
    userInventory = invData
    userMaxWeight = maxWeight
    if otherInv then
        otherInventory = otherInv
        if otherInvData and otherInvData.items then
            otherInvData.items = otherInv
        end
    end

    local tempSlots = {}
    for slot, data in pairs(userInventory) do
        if data.slot > 6 and data.slot < 12 then
            tempSlots[data.slot] = data
        end
    end
    equipedSlots = tempSlots

    SendNUIMessage({
        interface = 'inventory',
        act = 'updateInventory',
        data = {
            player = {
                fastSlots = equipedSlots,
                maxWeight = userMaxWeight,
                hasBag = hasBag,
                items = userInventory
            },
            other = otherInvData or false
        },
    })
end)

AddEventHandler('vrp-hud:updateMoney', function(money)
    userMoney = money
end)

RegisterNetEvent('vrp-inventory:updateBackpack')
AddEventHandler('vrp-inventory:updateBackpack', function(bagData)
    hasBag = bagData
end)

RegisterNetEvent('vrp-inventory:updateSlots', function(slots)
    equipedSlots = slots
end)

RegisterNUICallback('inventory:moveItem', function(data, cb)
    TriggerServerEvent('vrp-inventory:moveItem', data)
    cb('ok')
end)

RegisterNUICallback('hasNearPlayers', function(data, cb)
    cb(tvRP.getNearestPlayer(10))
end)

RegisterNUICallback('canUnequipBag', function(data, cb)
    for slot, data in pairs(userInventory) do
        if data.slot > 11 then
            return cb(false)
        end
    end

    cb(true)
end)

RegisterNUICallback('trashGhiozdan', function()
    TriggerServerEvent("vl:trashGhiozdan")
end)

RegisterNUICallback('normalNotify', function(data)
    tvRP.notify(data[1], 'error')
end)

-- function tvRP.canUnequipBag()
--     for slot, data in pairs(userInventory) do
--         if data.slot > 11 then
--             return false
--         end
--     end

--     return true
-- end

RegisterNetEvent('vrp-inventory:openChest', function(data)
    otherInvData = data;
    otherInventory = data and data.items
    SendNUIMessage({
        interface = 'inventory',
        act = 'show',
        data = {
            player = {
                fastSlots = equipedSlots,
                clothes = equipedClothes,
                maxWeight = userMaxWeight,
                hasBag = hasBag,
                money = userMoney,
                items = userInventory
            },
            other = data
        },
    })
end)

RegisterNUICallback('getWeight', function(data, cb)
    local playerWeight = 0.0
    local otherWeight = 0.0

    for slot, data in pairs(userInventory) do
        playerWeight = playerWeight + (data.amount * data.weight)
    end
    
    for slot, data in pairs(otherInventory or {}) do
        otherWeight = otherWeight + (data.amount * data.weight)
    end

    cb({
        playerWeight = playerWeight,
        otherWeight = otherWeight
    })
end)

RegisterNUICallback("hasItem", function(info, cb)
    if (info.to == 'pocket' or info.to == 'backpack') then
        for slot, data in pairs(userInventory) do
            if data.item == info.item then
                return cb(data.slot)
            end
        end
    else
        for slot, data in pairs(otherInventory or {}) do
            if data.item == info.item then
                return cb(data.slot)
            end
        end
    end

    cb(false)
end)

RegisterNUICallback("useItem", function(data, cb)
    TriggerServerEvent("vrp-inventory:useItem", data[1], data[2])
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('vrp-inventory:giveItem', data[1], data[2], data[3])
    cb('ok')
end)

RegisterNUICallback('trashItem', function(data, cb)
    TriggerServerEvent('vrp-inventory:trashItem', data[1], data[2], data[3])
    cb('ok')
end)

RegisterCommand("inventory", function()
    if tvRP.isInComa() then
        return
    end

    if tvRP.isHandcuffed(true) then return end

    if IsPauseMenuActive() then
        return
    end

    if LocalPlayer.state.lockedInventory then
        return
    end

    local nearestVeh = tvRP.getNearestOwnedVehicle(5)
    if IsPedInAnyVehicle(tempPed) and nearestVeh then
        local veh = GetVehiclePedIsIn(tempPed, false)
        local canAcces = (GetPedInVehicleSeat(veh, -1) == tempPed)

        if (canAcces and nearestVeh) then
            triggerCallback('openInventory', function(other)
                TriggerEvent("vrp-hud:updateMap", false)
                TriggerEvent("vrp-hud:setComponentDisplay", {
                    minimapHud = false,
                    serverHud = false,
                    bottomRightHud = false,
                    chat = false
                })

                if other and other.items then
                    otherInventory = other and other.items
                    otherInvData = other
                end
                SendNUIMessage({
                    interface = 'inventory',
                    act = 'show',
                    data = {
                        player = {
                            fastSlots = equipedSlots,
                            maxWeight = userMaxWeight,
                            hasBag = hasBag,
                            money = userMoney,
                            items = userInventory
                        },
                        other = other
                    },
                })
            end, 'glovebox', nearestVeh)
        end
    elseif (nearestVeh) then
        triggerCallback('openInventory', function(other)
            TriggerEvent("vrp-hud:updateMap", false)
            TriggerEvent("vrp-hud:setComponentDisplay", {
                minimapHud = false,
                serverHud = false,
                bottomRightHud = false,
                chat = false
            })

            if other and other.items then
                otherInventory = other and other.items
                otherInvData = other
            end
            SendNUIMessage({
                interface = 'inventory',
                act = 'show',
                data = {
                    player = {
                        fastSlots = equipedSlots,
                        maxWeight = userMaxWeight,
                        clothes = equipedClothes,
                        hasBag = hasBag,
                        money = userMoney,
                        items = userInventory
                    },
                    other = other
                },
            })
        end, 'trunk', nearestVeh)
    else
        TriggerEvent("vrp-hud:updateMap", false)
        TriggerEvent("vrp-hud:setComponentDisplay", {
            minimapHud = false,
            serverHud = false,
            bottomRightHud = false,
            chat = false
        })

        SendNUIMessage({
            interface = 'inventory',
            act = 'show',
            data = {
                player = {
                    fastSlots = equipedSlots,
                    maxWeight = userMaxWeight,
                    clothes = equipedClothes,
                    hasBag = hasBag,
                    money = userMoney,
                    items = userInventory
                }
            }
        })
    end
end) RegisterKeyMapping("inventory", "Open Inventory", "keyboard", "I")

RegisterNUICallback("closeInv", function(data, cb)
    otherInvData = false;
    TriggerEvent("vrp-hud:updateMap", true)
    TriggerEvent("vrp-hud:setComponentDisplay", {
        minimapHud = true,
        serverHud = true,
        bottomRightHud = true,
        chat = true
    })

    TriggerServerEvent("vrp-inventory:close", data)
    cb("ok")
end)

RegisterNetEvent("vrp-inventory:notify", function(data)
    SendNUIMessage({
        interface = 'inventory',
        act = 'notify',
        time = data.time,
        item = data.item,
        name = data.name,
        amount = data.amount,
    })
end)

-- [INV SLOTS]
CreateThread(function()
    for _, data in next, cfg.weapons do
        data.hash = GetHashKey(data.weapon)
    end
end)

AddEventHandler("CEventGunShot", function(_,entity,_)
    if entity == PlayerPedId() then
        local armaInHand = GetSelectedPedWeapon(PlayerPedId())
        if not equipedWeapons[armaInHand] and GetAmmoInPedWeapon(PlayerPedId(), armaInHand) > 0 then
            return TriggerServerEvent('vRP:$x', "[AC] INJECTION DETECTED - WEAPONS")
        end
        
        if not equipedSlots[equipedWeapons[armaInHand]] then return end

        local arma = cfg.weapons[equipedSlots[equipedWeapons[armaInHand]].item]
        if armaInHand == arma.hash then

            local weaponAmmo = ammo[arma.weapon]
            if not weaponAmmo then return end
            if not lastAmmoUpdate[arma.weapon] then lastAmmoUpdate[arma.weapon] = 0 end

            while updateBullets do
                Wait(1)
            end

            weaponAmmo.ammo = GetAmmoInPedWeapon(PlayerPedId(), arma.hash)
            SendNUIMessage({
                interface = 'updateHudWeapon',
                ammo = weaponAmmo.ammo,
            })

            if weaponAmmo.ammo <= 0 then
                lastAmmoUpdate[arma.weapon] = 0
                SendNUIMessage({
                    interface = 'setHudWeapon',
                    weapon = false,
                })
                TriggerServerEvent("vrp-weapons:setAmmo", weaponAmmo.ammo, equipedSlots[equipedWeapons[armaInHand]].item)
                return
            end

            lastAmmoUpdate[arma.weapon] = lastAmmoUpdate[arma.weapon] + 1
            if lastAmmoUpdate[arma.weapon] > 3 then
                TriggerServerEvent("vrp-weapons:setAmmo", weaponAmmo.ammo, equipedSlots[equipedWeapons[armaInHand]].item)
                lastAmmoUpdate[arma.weapon] = 0
            end
        end
    end
end)

function useSlot(slot)
    if not equipedSlots[slot] then return end

    if cfg.weapons[equipedSlots[slot].item] then
        local arma = cfg.weapons[equipedSlots[slot].item]

        if not (GetSelectedPedWeapon(PlayerPedId()) == arma.hash) then 
            if arma.meele then
                RemoveAllPedWeapons(PlayerPedId(), true)
                GiveWeaponToPed(PlayerPedId(), arma.hash, 0, false, true)
                SetCurrentPedWeapon(PlayerPedId(), arma.hash, true)
            else
                triggerCallback('getWeaponAmmo', function(nAmmo)
                    nAmmo = tonumber(nAmmo) or 0;

                    if arma.weapon then
                        if not ammo[arma.weapon] then
                            ammo[arma.weapon] = {
                                ammo = nAmmo,
                                weapon = equipedSlots[slot].item,
                                usedAmmo = arma.ammo,
                            }
                        else
                            ammo[arma.weapon].ammo = nAmmo
                        end
                        SendNUIMessage({
                            interface = 'setHudWeapon',
                            weapon = {
                                name = arma.name,
                                max = 250,
                                load = nAmmo,
                            }
                        })
                        
                        if not equipedWeapons[arma.hash] then
                            equipedWeapons[arma.hash] = slot;
                        end

                        SetWeaponsNoAutoswap(true)
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), arma.hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), arma.hash, true)
                        weaponHolster(true)
                        RefillAmmoInstantly(PlayerPedId())
                        if ammo[arma.weapon].ammo then
                            SetPedAmmo(PlayerPedId(), arma.hash, ammo[arma.weapon].ammo)
                        end
                        RefillAmmoInstantly(PlayerPedId())
                    end
                end, equipedSlots[slot].item)
            end
        else
            weaponHolster(false)
            RemoveAllPedWeapons(PlayerPedId(), true)
            SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
            SendNUIMessage({
                interface = 'setHudWeapon',
                weapon = false,
            })
        end
    else 
        TriggerServerEvent('vrp-inventory:useItem', equipedSlots[slot].item, slot)
    end 
end 

RegisterCommand("slot1", function() useSlot(7) end)
RegisterCommand("slot2", function() useSlot(8) end)
RegisterCommand("slot3", function() useSlot(9) end)
RegisterCommand("slot4", function() useSlot(10) end)
RegisterCommand("slot5", function() useSlot(11) end)

RegisterNUICallback("inventory:equipSlot", function(data, cb)
    data.slot = tonumber(data.slot)

    if data.item == 'weapon_musket' then
        local job = exports['vrp_jobs']:getActiveJob()
        
        if job and not (job == 'Vanator') then
            return TriggerEvent("vrp-hud:sendApiError", "Trebuie sa fi vanator pentru a putea echipa aceasta arma!")
        end
    end

    if isItemEquiped(data.item) then
        return tvRP.notify('Ai deja echipat acest item!', 'error')
    else
        equipedSlots[data.slot] = data
        TriggerServerEvent('vrp-inventory:equipSlot', data)
        if cfg.weapons[data.item] then
            if cfg.weapons[data.item].meele then
                local arma = cfg.weapons[data.item]
                GiveWeaponToPed(PlayerPedId(), arma.hash, 0, false, true)
                SetCurrentPedWeapon(PlayerPedId(), arma.hash, true)
                return cb(true);
            end
            triggerCallback('getWeaponAmmo', function(nAmmo)
                if nAmmo > 250 then
                    tvRP.notify('Nu poti incarca aceasta arma deoarece ai prea multe gloante in inventar, trebuie sa ai maxim 250!', 'error')
                    equipedSlots[data.slot] = nil
                    TriggerServerEvent('vrp-inventory:unequipSlot', data.item, data.fromSlot, data.toSlot)
                    cb(false)
                else
                    local arma = cfg.weapons[data.item]
                    local usedAmmo = cfg.weapons[data.item].ammo
                    ammo[arma.weapon] = {
                        ammo = nAmmo,
                        weapon = data.item,
                        usedAmmo = usedAmmo,
                    }
                    SendNUIMessage({
                        interface = 'setHudWeapon',
                        weapon = {
                            name = arma.name,
                            max = 250,
                            load = nAmmo,
                        }
                    })
                    SetPedAmmo(PlayerPedId(), arma.hash, tonumber(nAmmo))
                    equipedWeapons[arma.hash] = data.slot;
                    GiveWeaponToPed(PlayerPedId(), arma.hash, 0, false, true)
                    SetCurrentPedWeapon(PlayerPedId(), arma.hash, true)
                    weaponHolster(true)
                    RefillAmmoInstantly(PlayerPedId())
                    SetPedAmmo(PlayerPedId(), arma.hash, ammo[arma.weapon].ammo)
                    RefillAmmoInstantly(PlayerPedId())
                    cb(true)
                end
            end, data.item)
        else
            cb(true)
        end
    end
end)

function isItemEquiped(item)
    for k, v in pairs(equipedSlots) do
        if v.item == item then
            return true
        end
    end
    return false
end

RegisterNUICallback("inventory:removeSlot", function(data, cb)
    data.slot = tonumber(data.slot)

    if cfg.weapons[data.item] then
        lastAmmoUpdate[cfg.weapons[data.item].weapon] = 0

        if cfg.weapons[data.item].meele then
            SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
            RemoveAllPedWeapons(PlayerPedId(), true)
        else
            TriggerServerEvent('vrp-weapons:setAmmo', ammo[cfg.weapons[data.item].weapon] and ammo[cfg.weapons[data.item].weapon].ammo, data.item)
            equipedWeapons[cfg.weapons[data.item].hash] = nil;
            SetPedAmmo(PlayerPedId(), cfg.weapons[data.item].hash, 0)
            ammo[cfg.weapons[data.item].weapon] = nil
            SendNUIMessage({
                interface = 'setHudWeapon',
                weapon = false,
            })
            RemoveWeaponFromPed(PlayerPedId(), cfg.weapons[data.item].hash)
            SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
        end

        weaponHolster(false)
    end

    equipedSlots[data.slot] = nil
    TriggerServerEvent('vrp-inventory:unequipSlot', data.item, data.slot, data.toSlot)
    cb(true)
end)

RegisterNetEvent('vrp-inventory:updateBullets', function(ammoType, gloante)
    if not ammoType then return end
    updateBullets = true

    gloante = tonumber(gloante) or 0
    gloante = gloante < 0 and 0 or gloante

    local arma = GetSelectedPedWeapon(PlayerPedId())
    if arma ~= `WEAPON_UNARMED` then
        SetPedAmmo(PlayerPedId(), arma, gloante)
    end

    for _, data in next, equipedSlots do
        local arma = cfg.weapons[data.item]
        if arma then
            local weaponAmmo = ammo[arma.weapon]
            if weaponAmmo and weaponAmmo.usedAmmo:lower() == ammoType:lower() then
                weaponAmmo.ammo = gloante
                SendNUIMessage({
                    interface = 'updateHudWeapon',
                    ammo = weaponAmmo.ammo,
                })
            end
        end
    end

    updateBullets = false
end)

RegisterNetEvent('vrp-inventory:cleanSlots', function()
    equipedSlots = {}
    equipedWeapons = {}
    lastAmmoUpdate = {}
    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

RegisterKeyMapping('slot1', 'Obiect [1]', 'keyboard', "1")
RegisterKeyMapping('slot2', 'Obiect [2]', 'keyboard', "2")
RegisterKeyMapping('slot3', 'Obiect [3]', 'keyboard', "3")
RegisterKeyMapping('slot4', 'Obiect [4]', 'keyboard', "4")
RegisterKeyMapping('slot5', 'Obiect [5]', 'keyboard', "5")

-- Clothes
local Variations = {
	Jackets = {Male = {}, Female = {}},
	Hair = {Male = {}, Female = {}},
	Bags = {Male = {}, Female = {}},
	Visor = {Male = {}, Female = {}},
	Gloves = {
		Male = {
			[16] = 4,
			[17] = 4,
			[18] = 4,
			[19] = 0,
			[20] = 1,
			[21] = 2,
			[22] = 4,
			[23] = 5,
			[24] = 6,
			[25] = 8,
			[26] = 11,
			[27] = 12,
			[28] = 14,
			[29] = 15,
			[30] = 0,
			[31] = 1,
			[32] = 2,
			[33] = 4,
			[34] = 5,
			[35] = 6,
			[36] = 8,
			[37] = 11,
			[38] = 12,
			[39] = 14,
			[40] = 15,
			[41] = 0,
			[42] = 1,
			[43] = 2,
			[44] = 4,
			[45] = 5,
			[46] = 6,
			[47] = 8,
			[48] = 11,
			[49] = 12,
			[50] = 14,
			[51] = 15,
			[52] = 0,
			[53] = 1,
			[54] = 2,
			[55] = 4,
			[56] = 5,
			[57] = 6,
			[58] = 8,
			[59] = 11,
			[60] = 12,
			[61] = 14,
			[62] = 15,
			[63] = 0,
			[64] = 1,
			[65] = 2,
			[66] = 4,
			[67] = 5,
			[68] = 6,
			[69] = 8,
			[70] = 11,
			[71] = 12,
			[72] = 14,
			[73] = 15,
			[74] = 0,
			[75] = 1,
			[76] = 2,
			[77] = 4,
			[78] = 5,
			[79] = 6,
			[80] = 8,
			[81] = 11,
			[82] = 12,
			[83] = 14,
			[84] = 15,
			[85] = 0,
			[86] = 1,
			[87] = 2,
			[88] = 4,
			[89] = 5,
			[90] = 6,
			[91] = 8,
			[92] = 11,
			[93] = 12,
			[94] = 14,
			[95] = 15,
			[96] = 4,
			[97] = 4,
			[98] = 4,
			[99] = 0,
			[100] = 1,
			[101] = 2,
			[102] = 4,
			[103] = 5,
			[104] = 6,
			[105] = 8,
			[106] = 11,
			[107] = 12,
			[108] = 14,
			[109] = 15,
			[110] = 4,
			[111] = 4,
			[115] = 112,
			[116] = 112,
			[117] = 112,
			[118] = 112,
			[119] = 112,
			[120] = 112,
			[121] = 112,
			[122] = 113,
			[123] = 113,
			[124] = 113,
			[125] = 113,
			[126] = 113,
			[127] = 113,
			[128] = 113,
			[129] = 114,
			[130] = 114,
			[131] = 114,
			[132] = 114,
			[133] = 114,
			[134] = 114,
			[135] = 114,
			[136] = 15,
			[137] = 15,
			[138] = 0,
			[139] = 1,
			[140] = 2,
			[141] = 4,
			[142] = 5,
			[143] = 6,
			[144] = 8,
			[145] = 11,
			[146] = 12,
			[147] = 14,
			[148] = 112,
			[149] = 113,
			[150] = 114,
			[151] = 0,
			[152] = 1,
			[153] = 2,
			[154] = 4,
			[155] = 5,
			[156] = 6,
			[157] = 8,
			[158] = 11,
			[159] = 12,
			[160] = 14,
			[161] = 112,
			[162] = 113,
			[163] = 114,
			[165] = 4,
			[166] = 4,
			[167] = 4,
		},
		Female = {
			[16] = 11,
			[17] = 3,
			[18] = 3,
			[19] = 3,
			[20] = 0,
			[21] = 1,
			[22] = 2,
			[23] = 3,
			[24] = 4,
			[25] = 5,
			[26] = 6,
			[27] = 7,
			[28] = 9,
			[29] = 11,
			[30] = 12,
			[31] = 14,
			[32] = 15,
			[33] = 0,
			[34] = 1,
			[35] = 2,
			[36] = 3,
			[37] = 4,
			[38] = 5,
			[39] = 6,
			[40] = 7,
			[41] = 9,
			[42] = 11,
			[43] = 12,
			[44] = 14,
			[45] = 15,
			[46] = 0,
			[47] = 1,
			[48] = 2,
			[49] = 3,
			[50] = 4,
			[51] = 5,
			[52] = 6,
			[53] = 7,
			[54] = 9,
			[55] = 11,
			[56] = 12,
			[57] = 14,
			[58] = 15,
			[59] = 0,
			[60] = 1,
			[61] = 2,
			[62] = 3,
			[63] = 4,
			[64] = 5,
			[65] = 6,
			[66] = 7,
			[67] = 9,
			[68] = 11,
			[69] = 12,
			[70] = 14,
			[71] = 15,
			[72] = 0,
			[73] = 1,
			[74] = 2,
			[75] = 3,
			[76] = 4,
			[77] = 5,
			[78] = 6,
			[79] = 7,
			[80] = 9,
			[81] = 11,
			[82] = 12,
			[83] = 14,
			[84] = 15,
			[85] = 0,
			[86] = 1,
			[87] = 2,
			[88] = 3,
			[89] = 4,
			[90] = 5,
			[91] = 6,
			[92] = 7,
			[93] = 9,
			[94] = 11,
			[95] = 12,
			[96] = 14,
			[97] = 15,
			[98] = 0,
			[99] = 1,
			[100] = 2,
			[101] = 3,
			[102] = 4,
			[103] = 5,
			[104] = 6,
			[105] = 7,
			[106] = 9,
			[107] = 11,
			[108] = 12,
			[109] = 14,
			[110] = 15,
			[111] = 3,
			[112] = 3,
			[113] = 3,
			[114] = 0,
			[115] = 1,
			[116] = 2,
			[117] = 3,
			[118] = 4,
			[119] = 5,
			[120] = 6,
			[121] = 7,
			[122] = 9,
			[123] = 11,
			[124] = 12,
			[125] = 14,
			[126] = 15,
			[127] = 3,
			[128] = 3,
			[132] = 129,
			[133] = 129,
			[134] = 129,
			[135] = 129,
			[136] = 129,
			[137] = 129,
			[138] = 129,
			[139] = 130,
			[140] = 130,
			[141] = 130,
			[142] = 130,
			[143] = 130,
			[144] = 130,
			[145] = 130,
			[146] = 131,
			[147] = 131,
			[148] = 131,
			[149] = 131,
			[150] = 131,
			[151] = 131,
			[152] = 131,
			[154] = 153,
			[155] = 153,
			[156] = 153,
			[157] = 153,
			[158] = 153,
			[159] = 153,
			[160] = 153,
			[162] = 161,
			[163] = 161,
			[164] = 161,
			[165] = 161,
			[166] = 161,
			[167] = 161,
			[168] = 161,
			[169] = 15,
			[170] = 15,
			[171] = 0,
			[172] = 1,
			[173] = 2,
			[174] = 3,
			[175] = 4,
			[176] = 5,
			[177] = 6,
			[178] = 7,
			[179] = 9,
			[180] = 11,
			[181] = 12,
			[182] = 14,
			[183] = 129,
			[184] = 130,
			[185] = 131,
			[186] = 153,
			[187] = 0,
			[188] = 1,
			[189] = 2,
			[190] = 3,
			[191] = 4,
			[192] = 5,
			[193] = 6,
			[194] = 7,
			[195] = 9,
			[196] = 11,
			[197] = 12,
			[198] = 14,
			[199] = 129,
			[200] = 130,
			[201] = 131,
			[202] = 153,
			[203] = 161,
			[204] = 161,
			[206] = 3,
			[207] = 3,
			[208] = 3,
		}
	}
}


function AddNewVariation(which, gender, one, two, single)
	local Where = Variations[which][gender]
	if not single then
		Where[one] = two
		Where[two] = one
	else
		Where[one] = two
	end
end

Citizen.CreateThread(function()
	-- Male Visor/Hat Variations
	AddNewVariation("Visor", "Male", 9, 10)
	AddNewVariation("Visor", "Male", 18, 67)
	AddNewVariation("Visor", "Male", 82, 67)
	AddNewVariation("Visor", "Male", 44, 45)
	AddNewVariation("Visor", "Male", 50, 68)
	AddNewVariation("Visor", "Male", 51, 69)
	AddNewVariation("Visor", "Male", 52, 70)
	AddNewVariation("Visor", "Male", 53, 71)
	AddNewVariation("Visor", "Male", 62, 72)
	AddNewVariation("Visor", "Male", 65, 66)
	AddNewVariation("Visor", "Male", 73, 74)
	AddNewVariation("Visor", "Male", 76, 77)
	AddNewVariation("Visor", "Male", 79, 78)
	AddNewVariation("Visor", "Male", 80, 81)
	AddNewVariation("Visor", "Male", 91, 92)
	AddNewVariation("Visor", "Male", 104, 105)
	AddNewVariation("Visor", "Male", 109, 110)
	AddNewVariation("Visor", "Male", 116, 117)
	AddNewVariation("Visor", "Male", 118, 119)
	AddNewVariation("Visor", "Male", 123, 124)
	AddNewVariation("Visor", "Male", 125, 126)
	AddNewVariation("Visor", "Male", 127, 128)
	AddNewVariation("Visor", "Male", 130, 131)
	-- Female Visor/Hat Variations
	AddNewVariation("Visor", "Female", 43, 44)
	AddNewVariation("Visor", "Female", 49, 67)
	AddNewVariation("Visor", "Female", 64, 65)
	AddNewVariation("Visor", "Female", 65, 64)
	AddNewVariation("Visor", "Female", 51, 69)
	AddNewVariation("Visor", "Female", 50, 68)
	AddNewVariation("Visor", "Female", 52, 70)
	AddNewVariation("Visor", "Female", 62, 71)
	AddNewVariation("Visor", "Female", 72, 73)
	AddNewVariation("Visor", "Female", 75, 76)
	AddNewVariation("Visor", "Female", 78, 77)
	AddNewVariation("Visor", "Female", 79, 80)
	AddNewVariation("Visor", "Female", 18, 66)
	AddNewVariation("Visor", "Female", 66, 81)
	AddNewVariation("Visor", "Female", 81, 66)
	AddNewVariation("Visor", "Female", 86, 84)
	AddNewVariation("Visor", "Female", 90, 91)
	AddNewVariation("Visor", "Female", 103, 104)
	AddNewVariation("Visor", "Female", 108, 109)
	AddNewVariation("Visor", "Female", 115, 116)
	AddNewVariation("Visor", "Female", 117, 118)
	AddNewVariation("Visor", "Female", 122, 123)
	AddNewVariation("Visor", "Female", 124, 125)
	AddNewVariation("Visor", "Female", 126, 127)
	AddNewVariation("Visor", "Female", 129, 130)
	-- Male Bags
	AddNewVariation("Bags", "Male", 45, 44)
	AddNewVariation("Bags", "Male", 41, 40)
	-- Female Bags
	AddNewVariation("Bags", "Female", 45, 44)
	AddNewVariation("Bags", "Female", 41, 40)
	-- Male Hair
	AddNewVariation("Hair", "Male", 7, 15, true)
	AddNewVariation("Hair", "Male", 43, 15, true)
	AddNewVariation("Hair", "Male", 9, 43, true)
	AddNewVariation("Hair", "Male", 11, 43, true)
	AddNewVariation("Hair", "Male", 15, 43, true)
	AddNewVariation("Hair", "Male", 16, 43, true)
	AddNewVariation("Hair", "Male", 17, 43, true)
	AddNewVariation("Hair", "Male", 20, 43, true)
	AddNewVariation("Hair", "Male", 22, 43, true)
	AddNewVariation("Hair", "Male", 45, 43, true)
	AddNewVariation("Hair", "Male", 47, 43, true)
	AddNewVariation("Hair", "Male", 49, 43, true)
	AddNewVariation("Hair", "Male", 51, 43, true)
	AddNewVariation("Hair", "Male", 52, 43, true)
	AddNewVariation("Hair", "Male", 53, 43, true)
	AddNewVariation("Hair", "Male", 56, 43, true)
	AddNewVariation("Hair", "Male", 58, 43, true)
	-- Female Hair
	AddNewVariation("Hair", "Female", 1, 49, true)
	AddNewVariation("Hair", "Female", 2, 49, true)
	AddNewVariation("Hair", "Female", 7, 49, true)
	AddNewVariation("Hair", "Female", 9, 49, true)
	AddNewVariation("Hair", "Female", 10, 49, true)
	AddNewVariation("Hair", "Female", 11, 48, true)
	AddNewVariation("Hair", "Female", 14, 53, true)
	AddNewVariation("Hair", "Female", 15, 42, true)
	AddNewVariation("Hair", "Female", 21, 42, true)
	AddNewVariation("Hair", "Female", 23, 42, true)
	AddNewVariation("Hair", "Female", 31, 53, true)
	AddNewVariation("Hair", "Female", 39, 49, true)
	AddNewVariation("Hair", "Female", 40, 49, true)
	AddNewVariation("Hair", "Female", 42, 53, true)
	AddNewVariation("Hair", "Female", 45, 49, true)
	AddNewVariation("Hair", "Female", 48, 49, true)
	AddNewVariation("Hair", "Female", 49, 48, true)
	AddNewVariation("Hair", "Female", 52, 53, true)
	AddNewVariation("Hair", "Female", 53, 42, true)
	AddNewVariation("Hair", "Female", 54, 55, true)
	AddNewVariation("Hair", "Female", 59, 42, true)
	AddNewVariation("Hair", "Female", 59, 54, true)
	AddNewVariation("Hair", "Female", 68, 53, true)
	AddNewVariation("Hair", "Female", 76, 48, true)
	-- Male Top/Jacket Variations
	

    for i=0,593 do
		AddNewVariation("Jackets", "Male", i, -1)
	end

    for i=0,644 do
		AddNewVariation("Jackets", "Female", i, -1)
	end
end)


local Config = {}
local LastEquipped = {}
local Cooldown = false

function IsMpPed(ped)
	local male = GetHashKey("mp_m_freemode_01") 
	local female = GetHashKey("mp_f_freemode_01")
	local CurrentModel = GetEntityModel(ped)
	if CurrentModel == male then 
		return "Male" 
	elseif CurrentModel == female then 
		return "Female" 
	else 
		return false 
	end
end

function Notify(message) -- However you want your notifications to be shown, you can switch it up here.
	SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0,1)
end

local function Distance(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt(dx * dx + dy * dy)
end

function log(l) -- Just a simple logging thing, to easily log all kinds of stuff.
	if l == nil then print("nil") return end
	if not Config.Debug then return end
	if type(l) == "table" then print(json.encode(l)) elseif type(l) == "boolean" then print(l) else print(l.." | "..type(l)) end
end

Config.Commands = {
	['top'] = {
		Func = function() ToggleClothing("Top") end,
	},
	['gloves'] = {
		Func = function() ToggleClothing("Gloves") end,
	},
	['visor'] = {
		Func = function() ToggleProps("Visor") end,
	},
	['bag'] = {
		Func = function() ToggleClothing("Bag") end,
	},
	['shoes'] = {
		Func = function() ToggleClothing("Shoes") end,
	},
	['vests'] = {
		Func = function() ToggleClothing("Vest") end,
	},
	['hair'] = {
		Func = function() ToggleClothing("Hair") end,
	},
	['hats'] = {
		Func = function() ToggleProps("Hat") end,
	},
	['glasses'] = {
		Func = function() ToggleProps("Glasses") end,
	},
	['earings'] = {
		Func = function() ToggleProps("Ear") end,
	},
	['gat'] = {
		Func = function() ToggleClothing("Neck") end,
	},
	['watches'] = {
		Func = function() ToggleProps("Watch") end,
	},
	['bratara'] = {
		Func = function() ToggleProps("Bracelet") end,
	},
	['mask'] = {
		Func = function() ToggleClothing("Mask") end,
	},
    ['pants'] = {
		Func = function() ToggleClothing("Pants", true) end,
	},
	['undershirt'] = {
		Func = function() ToggleClothing("Shirt", true) end,
	},
	['reset'] = {
		Func = function() if not ResetClothing(true) then Notify(Lang("AlreadyWearing")) end end,
	},
}

local Bags = {
	[40] = true,
	[41] = true,
	[44] = true,
	[45] = true
}

local Drawables = {
	["Top"] = {
		Drawable = 11,
		Table = Variations.Jackets,
		Emote = {Dict = "missmic4", Anim = "michael_tux_fidget", Move = 51, Dur = 1500}
	},
	["Gloves"] = {
		Drawable = 3,
		Table = Variations.Gloves,
		Remember = true,
		Emote = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200}
	},
	["Shoes"] = {
		Drawable = 6,
		Table = {Standalone = true, male = 99, female = 35},
		Emote = {Dict = "random@domestic", Anim = "pickup_low", Move = 0, Dur = 1200}
	},
	["Neck"] = {
		Drawable = 7,
		Table = {Standalone = true, male = 0, female = 0 },
		Emote = {Dict = "clothingtie", Anim = "try_tie_positive_a", Move = 51, Dur = 2100}
	},
	["Vest"] = {
		Drawable = 9,
		Table = {Standalone = true, male = 0, female = 0 },
		Emote = {Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200}
	},
	["Bag"] = {
		Drawable = 5,
		Table = Variations.Bags,
		Emote = {Dict = "anim@heists@ornate_bank@grab_cash", Anim = "intro", Move = 51, Dur = 1600}
	},
	["Mask"] = {
		Drawable = 1,
		Table = {Standalone = true, male = 0, female = 0 },
		Emote = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 800}
	},
	["Hair"] = {
		Drawable = 2,
		Table = Variations.Hair,
		Remember = true,
		Emote = {Dict = "clothingtie", Anim = "check_out_a", Move = 51, Dur = 2000}
	},
}

local Extras = {
	["Shirt"] = {
		Drawable = 11,
		Table = {
			Standalone = true, male = 15, female = 74,
			Extra = { 
				{Drawable = 8, Id = 15, Tex = 0, Name = "Extra Undershirt"},
				{Drawable = 3, Id = 15, Tex = 0, Name = "Extra Gloves"},
				{Drawable = 10, Id = 0, Tex = 0, Name = "Extra Decals"},
			}
		},
		Emote = {Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200}
	},
	["Pants"] = {
		Drawable = 4,
		Table = {Standalone = true, male = 102, female = 14},
		Emote = {Dict = "re@construction", Anim = "out_of_breath", Move = 51, Dur = 1300}
	},
	["Bagoff"] = {
		Drawable = 5,
		Table = {Standalone = true, male = 0, female = 0},
		Emote = {Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200}
	},
}

local Props = {
	["Visor"] = {
		Prop = 0,
		Variants = Variations.Visor,
		Emote = {
			On = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600},
			Off = {Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200}
		}
	},
	["Hat"] = {
		Prop = 0,
		Emote = {
			On = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600},
			Off = {Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200}
		}
	},
	["Glasses"] = {
		Prop = 1,
		Emote = {
			On = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400},
			Off = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400}
		}
	},
	["Ear"] = {
		Prop = 2,
		Emote = {
			On = {Dict = "mp_cp_stolen_tut", Anim = "b_think", Move = 51, Dur = 900},
			Off = {Dict = "mp_cp_stolen_tut", Anim = "b_think", Move = 51, Dur = 900}
		}
	},
	["Watch"] = {
		Prop = 6,
		Emote = {
			On = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200},
			Off = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200}
		}
	},
	["Bracelet"] = {
		Prop = 7,
		Emote = {
			On = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200},
			Off = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200}
		}
	},
}

local function PlayToggleEmote(e, cb)
	local Ped = PlayerPedId()
	while not HasAnimDictLoaded(e.Dict) do RequestAnimDict(e.Dict) Wait(100) end
	if IsPedInAnyVehicle(Ped) then e.Move = 51 end
	TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, e.Dur, e.Move, 0, false, false, false)
	local Pause = e.Dur-500 if Pause < 500 then Pause = 500 end
	IncurCooldown(Pause)
	Wait(Pause) -- Lets wait for the emote to play for a bit then do the callback.
	cb()
end

function ResetClothing(anim)
	local Ped = PlayerPedId()
	local e = Drawables.Top.Emote
	if anim then TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, 3000, e.Move, 0, false, false, false) end
	for k,v in pairs(LastEquipped) do
		if v then
			if v.Drawable then SetPedComponentVariation(Ped, v.Id, v.Drawable, v.Texture, 0)
			elseif v.Prop then ClearPedProp(Ped, v.Id) SetPedPropIndex(Ped, v.Id, v.Prop, v.Texture, true) end
		end
	end
	LastEquipped = {}
end

function ToggleClothing(which, extra)
	if Cooldown then return end
	print("fjgjgjgj", which)
	local Toggle = Drawables[which] if extra then Toggle = Extras[which] end
	local Ped = PlayerPedId()
	local Cur = { -- Lets check what we are currently wearing.
		Drawable = GetPedDrawableVariation(Ped, Toggle.Drawable), 
		Id = Toggle.Drawable,
		Ped = Ped,
		Texture = GetPedTextureVariation(Ped, Toggle.Drawable),
	}
	local Gender = IsMpPed(Ped)
	if Gender == "male" then
		Gender = "Male"
	elseif Gender == "female" then
		Gender = "Female"
	end

	if which ~= "Mask" then
		if not Gender then tvRP.notify('Nu functioneaza pe acest ped!', 'error') return false end -- We cancel the command here if the person is not using a multiplayer model.
	end
	local Table = Toggle.Table[Gender]
	if not Toggle.Table.Standalone then -- "Standalone" is for things that dont require a variant, like the shoes just need to be switched to a specific drawable. Looking back at this i should have planned ahead, but it all works so, meh!
		for k,v in pairs(Table) do
			print(v)
			if not Toggle.Remember then
				if k == Cur.Drawable then
					PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end) return true
				end
			else
				if not LastEquipped[which] then
					if k == Cur.Drawable then
						PlayToggleEmote(Toggle.Emote, function() LastEquipped[which] = Cur SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end) return true
					end
				else
					local Last = LastEquipped[which]
					PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0) LastEquipped[which] = false end) return true
				end
			end
		end
        return tvRP.notify('Nu ai ce sa dai jos!', 'error')
	else
		if not LastEquipped[which] then
			if Cur.Drawable ~= Table then 
				PlayToggleEmote(Toggle.Emote, function()
					LastEquipped[which] = Cur
					SetPedComponentVariation(Ped, Toggle.Drawable, Table, 0, 0)
					if Toggle.Table.Extra then
						local Extras = Toggle.Table.Extra
						for k,v in pairs(Extras) do
							local ExtraCur = {Drawable = GetPedDrawableVariation(Ped, v.Drawable),  Texture = GetPedTextureVariation(Ped, v.Drawable), Id = v.Drawable}
							SetPedComponentVariation(Ped, v.Drawable, v.Id, v.Tex, 0)
							LastEquipped[v.Name] = ExtraCur
						end
					end
				end)
				return true
			end
		else
			local Last = LastEquipped[which]
			PlayToggleEmote(Toggle.Emote, function()
				SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0)
				LastEquipped[which] = false
				if Toggle.Table.Extra then
					local Extras = Toggle.Table.Extra
					for k,v in pairs(Extras) do
						if LastEquipped[v.Name] then
							local Last = LastEquipped[v.Name]
							SetPedComponentVariation(Ped, Last.Id, Last.Drawable, Last.Texture, 0)
							LastEquipped[v.Name] = false
						end
					end
				end
			end)
			return true
		end
	end
	tvRP.notify('Deja porti asta!', 'error') return false
end

function ToggleProps(which)
	if Cooldown then return end
	local Prop = Props[which]
	local Ped = PlayerPedId()
	local Gender = IsMpPed(Ped)
	local Cur = { -- Lets get out currently equipped prop.
		Id = Prop.Prop,
		Ped = Ped,
		Prop = GetPedPropIndex(Ped, Prop.Prop), 
		Texture = GetPedPropTextureIndex(Ped, Prop.Prop),
	}
	if not Prop.Variants then
		if Cur.Prop ~= -1 then -- If we currently are wearing this prop, remove it and save the one we were wearing into the LastEquipped table.
			PlayToggleEmote(Prop.Emote.Off, function() LastEquipped[which] = Cur ClearPedProp(Ped, Prop.Prop) end) return true
		else
			local Last = LastEquipped[which] -- Detect that we have already taken our prop off, lets put it back on.
			if Last then
				PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, Last.Prop, Last.Texture, true) end) LastEquipped[which] = false return true
			end
		end
		tvRP.notify('Nu ai ce sa dai jos!', 'error') return false
	else
		local Gender = IsMpPed(Ped)
		if not Gender then vRP.notify('Nu functioneaza pe acest ped!', 'error') return false end -- We dont really allow for variants on ped models, Its possible, but im pretty sure 95% of ped models dont really have variants.
		local Variations = Prop.Variants[Gender]
		for k,v in pairs(Variations) do
			if Cur.Prop == k then
				PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, v, Cur.Texture, true) end) return true
			end
		end
		tvRP.notify('Nu ai variante!', 'error') return false
	end
end

for k,v in pairs(Config.Commands) do
	RegisterCommand(k, v.Func)
end

function IncurCooldown(ms)
	Citizen.CreateThread(function()
		Cooldown = true Wait(ms) Cooldown = false
	end)
end


RegisterNUICallback("inventory:changeVariation", function(data, cb)
    local drawable = data[1]

    if Config.Commands[drawable] and Config.Commands[drawable].Func then
        Config.Commands[drawable].Func()
    end

    cb("ok")
end)