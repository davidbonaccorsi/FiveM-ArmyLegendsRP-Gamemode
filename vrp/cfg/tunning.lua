local Config = {}

Config.TunningActionDistance = 8.0
Config.TunningKeys = {
    action = {key = 38, label = 'E', name = 'INPUT_PICKUP'}
}

Config.TunningMenus = {
    ['empty'] = {
        title = '',
        options = {},
    },
    ['main'] = {
        title = '',
        options = {
            {label = 'Repara', img = 'https://cdn.armylegends.ro/tunning/icons/repair.png', price = 550, onSelect = function() repairtVehicle(customVehicle) end},
            {label = 'Modificari', img = 'https://cdn.armylegends.ro/tunning/icons/visual.png', openSubMenu = 'visual'},
            {label = 'Performanta', img = 'https://cdn.armylegends.ro/tunning/icons/upgrade.png', openSubMenu = 'upgrade'}
        },
        onBack = function() closeUI(1) end,
        defaultOption = 1
    },
        ['upgrade'] = {
            title = 'Performanta',
            options = {
                {label = 'Soft', img = 'https://cdn.armylegends.ro/tunning/icons/engine.png', modType = 11, priceMult = {1.0, 3.0, 4.0, 5.5, 7.0, 7.0}},
                {label = 'Frane', img = 'https://cdn.armylegends.ro/tunning/icons/brakes.png', modType = 12, priceMult = {1.0, 1.5, 2.0, 2.5, 2.5}},
                {label = 'Transmisie', img = 'https://cdn.armylegends.ro/tunning/icons/transmission.png', modType = 13, priceMult = {1.0, 3.0, 3.5, 4.0, 4.0}},
                {label = 'Suspensie', img = 'https://cdn.armylegends.ro/tunning/icons/suspension.png', modType = 15, priceMult = {1.0, 3.0, 3.5, 4.0, 10.00, 10.0, 10.0}},
                {label = 'Armura', img = 'https://cdn.armylegends.ro/tunning/icons/armor.png', modType = 16, priceMult = {1.0, 4.0, 4.5, 5.0, 5.5, 6.0, 6.0, 6.0}},
                {label = 'Turbina', img = 'https://cdn.armylegends.ro/tunning/icons/engine.png', modType = 18, priceMult = {1.0, 10.0}},
            },
            onBack = function() updateMenu('main') end
        },
        ['visual'] = {
            title = 'Modificari',
            options = {
                {label = 'Caroserie', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', openSubMenu = 'body_parts'},
                {label = 'Interior', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', openSubMenu = 'inside_parts'},
                {label = 'Vopsea', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', openSubMenu = 'respray'},
                {label = 'Jante', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', openSubMenu = 'wheels', onSelect = function()
                    moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.3, y = 1.9, z = 0.1}, {x = -10.0, y = 0.0, z = 20.0})
                end, onSubBack = function()
                    SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                end},
                {label = 'Placute', img = 'https://cdn.armylegends.ro/tunning/icons/plate.png', openSubMenu = 'plate'},
                {label = 'Lumini', img = 'https://cdn.armylegends.ro/tunning/icons/headlights.png', openSubMenu = 'lights'},
                {label = 'Colant', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', openSubMenu = 'stickers'},
                {label = 'Extra', img = 'https://cdn.armylegends.ro/tunning/icons/plus.png', modType = 'extras', priceMult = 0.5},
                {label = 'Folii geamuri', img = 'https://cdn.armylegends.ro/tunning/icons/door.png', modType = 'windowTint', priceMult = 0.3, onSelect = function()
                    moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.0, y = -0.5, z = 0.3}, {x = 0.0, y = 0.0, z = 0.0})
                end, onSubBack = function()
                    SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                end},
                {label = 'Claxon', img = 'https://cdn.armylegends.ro/tunning/icons/horn.png', modType = 14, priceMult = 35.00},
                {label = 'Placute Lowrider', img = '', modType = 35, priceMult = 0.5},
                {label = 'Boxe', img = 'https://cdn.armylegends.ro/tunning/icons/speaker.png', modType = 36, priceMult = 1.00},
                {label = 'Portbagaj', img = 'https://cdn.armylegends.ro/tunning/icons/trunk.png', modType = 37, priceMult = 1.00, onSelect = function() openDoors(customVehicle, {0,0,0,0,0,1,1}) end},
                {label = 'Hidraulice', img = 'https://cdn.armylegends.ro/tunning/icons/hydrulics.png', modType = 38, priceMult = 3.00},
                {label = 'Bloc motor', img = 'https://cdn.armylegends.ro/tunning/icons/engine_block.png', modType = 39, priceMult = 2.00, onSelect = function() openDoors(customVehicle, {0,0,0,0,1,0,0}) moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 4.0, z = 1.7}, {x = -30.0, y = 0.0, z = 0.0}) end, onSubBack = function()
                    SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                end},
                {label = 'Filtru de aer', img = 'https://cdn.armylegends.ro/tunning/icons/air_filter.png', modType = 40, priceMult = 150.00},
                {label = 'Distantier', img = 'https://cdn.armylegends.ro/tunning/icons/suspension.png', modType = 41, priceMult = 1.00},
                {label = 'Rezervor', img = 'https://cdn.armylegends.ro/tunning/icons/gas_tank.png', modType = 45, priceMult = 1.00},
            },
            onBack = function() updateMenu('main') end
        },
            ['body_parts'] = {
                title = 'Caroserie',
                options = {
                    {label = 'Spoiler', img = 'https://cdn.armylegends.ro/tunning/icons/spoiler.png', modType = 0, priceMult = 1.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.3, z = 0.9}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Bara fata', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 1, priceMult = 2.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 4.6, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Bara spate', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 2, priceMult = 2.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Praguri', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 3, priceMult = 1.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.0, y = 2.0, z = 0.0}, {x = 0.0, y = 0.0, z = -20.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Evacuare', img = 'https://cdn.armylegends.ro/tunning/icons/exhaust.png', modType = 4, priceMult = 2.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.0}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Cusca', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 5, priceMult = 1.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 1.2, z = 1.1}, {x = -30.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Grila', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 6, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 3.2, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Capota', img = 'https://cdn.armylegends.ro/tunning/icons/hood.png', modType = 7, priceMult = 2.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 4.0, z = 1.7}, {x = -30.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Aripa stanga', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 8, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 2.0, y = 2.5, z = 1.0}, {x = -25.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Aripa dreapta', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 9, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.5, y = 0.6, z = 0.4}, {x = 0.0, y = 0.0, z = -25.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Plafon', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 10, priceMult = 2.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -1.0, y = 2.0, z = 2.1}, {x = -25.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Aparatori', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 42, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Antena', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 43, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Aripi', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 44, priceMult = 1.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.5, y = 0.6, z = 0.4}, {x = 0.0, y = 0.0, z = -25.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Oglinzi', img = 'https://cdn.armylegends.ro/tunning/icons/door.png', modType = 46, priceMult = 0.5, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = -2.0, y = 0.4, z = 0.8}, {x = 0.0, y = 0.0, z = 20.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                },
                onBack = function() updateMenu('visual') end
            },
            ['inside_parts'] = {
                title = 'Interior',
                options = {
                    {label = 'Bord', img = 'https://cdn.armylegends.ro/tunning/icons/dashboard.png', modType = 29, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -20.0, y = 0.0, z = 270.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Ceasuri', img = 'https://cdn.armylegends.ro/tunning/icons/dashboard.png', modType = 30, priceMult = 0.20, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -10.0, y = 0.0, z = 270.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Trimuri Usi', img = 'https://cdn.armylegends.ro/tunning/icons/speaker.png', modType = 31, priceMult = 1.00, onSelect = function() openDoors(customVehicle, {1,1,1,1,0,0,0}) moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -10.0, y = 0.0, z = 270.0}) end,onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end },
                    {label = 'Scaune', img = 'https://cdn.armylegends.ro/tunning/icons/seat.png', modType = 32, priceMult = 1.50, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 1.2, z = 1.1}, {x = -30.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Volan', img = 'https://cdn.armylegends.ro/tunning/icons/steering_wheel.png', modType = 33, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -20.0, y = 0.0, z = 270.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Schimbator', img = 'https://cdn.armylegends.ro/tunning/icons/shifter_leaver.png', modType = 34, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -70.0, y = 0.0, z = 270.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Ornamente', img = '', modType = 28, priceMult = 0.5, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.1, y = 0.0, z = 0.785}, {x = -20.0, y = 0.0, z = 270.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Tapiterie', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 27, priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 1.2, z = 1.1}, {x = -30.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Ceasuri Bord Trim', img = 'https://cdn.armylegends.ro/tunning/icons/body.png', modType = 'dcol', priceMult = 1.00, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = 1.2, z = 1.1}, {x = -30.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                },
                onBack = function() updateMenu('visual') end
            },
            ['respray'] = {
                title = 'Vopsea',
                options = {
                    {label = 'Principala', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'color1', customType = 'customColor', priceMult = 1.12, onSelect = function() openColorPicker('Primary Color', 'color1', true, 1.0) end},
                    {label = 'Secundara', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'color2', customType = 'customColor', priceMult = 0.66, onSelect = function() openColorPicker('Secondary Color', 'color2', true, 1.0) end},
                    {label = 'Tip vopsea Principala', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'paintType1', priceMult = 1.0},
                    {label = 'Tip vopsea Secundara', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'paintType2', priceMult = 1.0},
                    {label = 'Perla', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'pearlescentColor', customType = 'color', priceMult = 0.88, onSelect = function() openColorPicker('Pearlescent Color', 'pearlescentColor', false, 1.0) end},
                },
                onBack = function() updateMenu('visual') end
            },
            ['wheels'] = {
                title = 'Jante',
                options = {
                    {label = 'Tip Jante', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', onSelect = function() updateMenu('wheels_type') end},
                    {label = 'Culoare Jante', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'wheelColor', customType = 'color', priceMult = 0.66, onSelect = function() openColorPicker('Wheels Color', 'wheelColor', false, 1.0) end},
                    {label = 'Culoare Fum Cauciucuri', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'tyreSmokeColor', customType = 'customColor', priceMult = 1.12, onSelect = function() openColorPicker('Tyre Smoke Color', 'tyreSmokeColor', true, 10.0) end},
                    -- {label = 'Cauciucuri Runflat', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 'bulletproof', customType = 'bulletproofTyres', priceMult = 500.00, onSelect = function() end},
                },
                onBack = function() updateMenu('visual') SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true) end
            },
                ['wheels_type'] = {
                    title = 'Tip Jante',
                    options = {
                        {label = 'Jante Sport', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 7.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 0) end},
                        {label = 'Jante Muscle ', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 3.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 1) end},
                        {label = 'Jante Lowrider', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 5.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 2) end},
                        {label = 'Jante SUV', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 3.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 3) end},
                        {label = 'Jante Offroad', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 6.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 4) end},
                        {label = 'Jante Tuner', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 18.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 5) end},
                        {label = 'Jante Super', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 10.0, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 7) end},
                        {label = 'Jante Bennys Sport', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 30.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 8) end},
                        {label = 'Jante Bennys Lowrider', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 35.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 9) end},
                        {label = 'Jante Drag', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 50.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 10) end},
                        {label = 'Jante Street', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 46.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 11) end},
                        {label = 'Jante Track', img = 'https://cdn.armylegends.ro/tunning/icons/wheel.png', modType = 23, priceMult = 46.00, onSelect = function() SetVehicleModData(customVehicle, 'wheels', 12) end},
                    },
                    onBack = function() updateMenu('wheels') end
                },
            ['plate'] = {
                title = 'Placute',
                options = {
                    {label = 'Tip', img = 'https://cdn.armylegends.ro/tunning/icons/plate.png', modType = 25, priceMult = 0.1, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Culoare', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'plateIndex', priceMult = 0.1, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                    {label = 'Suport Numar', img = 'https://cdn.armylegends.ro/tunning/icons/bumper.png', modType = 26, priceMult = 0.1, onSelect = function()
                        moveToCameraToBoneSmoth(customCamMain, customCamSec, customVehicle, {x = 0.0, y = -4.0, z = 0.1}, {x = 0.0, y = 0.0, z = 0.0})
                    end, onSubBack = function()
                        SetCamActiveWithInterp(customCamMain, customCamSec, 500, true, true)
                    end},
                },
                onBack = function() updateMenu('visual') end
            },
            ['lights'] = {
                title = 'Lumini',
                options = {
                    -- {label = 'Xenon', img = 'https://cdn.armylegends.ro/tunning/icons/headlights.png', modType = 'modXenon', priceMult = 35.0, onSelect = function() SetVehicleEngineOn(customVehicle, true, false, false) end},
                    {label = 'Neon', img = 'https://cdn.armylegends.ro/tunning/icons/headlights.png', modType = 'neonColor', customType = 'customColor', priceMult = 1.12, onSelect = function() SetVehicleEngineOn(customVehicle, true, false, false) openColorPicker('Neon Color', 'neonColor', true, 1.0) end},
                },
                onBack = function() updateMenu('visual') end
            },
            ['stickers'] = {
                title = 'Colant',
                options = {
                    {label = 'Colant', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 48, priceMult = 5.0},
                    {label = 'Colant', img = 'https://cdn.armylegends.ro/tunning/icons/respray.png', modType = 'livery', priceMult = 5.0},
                },
                onBack = function() updateMenu('visual') end
            },
}


Config.TunningPositions = {
    {
		pos = {x = -211.53, y = -1324.28, z = 30.890403747558}, -- "Benny's Motoworks"
	},
	{
		pos = {x = -336.92, y = -137.42, z = 39.009666442872}, --"Los Santos Customs"
	},
	{
		pos = {x = 733.67, y = -1088.77, z = 22.168996810914}, -- "LA Mesa LSC"
	},
	{
		pos = {x = 1174.22, y = 2638.78, z = 37.763023376464}, -- "Sandy LSC"
	},
	{
		pos = {x = 109.39, y = 6627.74, z = 31.787231445312}, -- "Beekers Garage"
	},
	{
		pos = {x = -1155.32, y = -2005.93, z = 13.180257797242}, -- "LS Custom Airport"
	},
	{
		pos = {x = 1766.87, y = 3329.49, z = 41.438526153564}, -- "Bob's Motoworks"
	},
	{
		pos = {x = 480.43, y = -1318.13, z = 29.203395843506}, -- "Tuning Mecanic"
	},
    {
        pos = {x = -34.813983917236, y = -1052.8277587891, z = 28.396305084229}, -- "Tunning Bennys Showroom"
    },
    {
        pos = {x = -1620.6206054688, y = -827.87689208984, z = 10.232138633728}, -- "Tunning Sediu Mecanici"
    },
    {
        pos = {x = 910.97650146484, y = -2360.6181640625, z = 21.208070755005}, -- "Carmeet"
    },
    {
        pos = {x = 887.31121826172, y = -2126.2565917969, z = 30.558624267578}, -- "East Customs"
    },
    {
        pos = {x = 480.61215209961, y = -1318.1802978516, z = 29.203155517578}, -- "Hayes Centru"
    },
    {
        pos = {x = 548.45574951172, y = -198.24276733398, z = 54.493186950684}, -- "Tunning langa Alta"
    },
    {
        pos = {x = -1416.2451171875, y = -445.79287719727, z = 35.909698486328}, -- "Hayes Del Perro"
    },
    {
        pos = {x = 960.26330566406, y = -112.13963317871, z = 74.363639831543}, -- "The Lost"
    },
}

return Config;
