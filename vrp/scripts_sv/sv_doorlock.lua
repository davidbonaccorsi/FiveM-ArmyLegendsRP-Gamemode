
local allDoors = {
    -- Usi interior inauntru
    {pos = vector3(449.52236938477, -980.36102294922, 30.874448776245), model = -1481015543, faction = "Politie"},
    {pos = vector3(449.52236938477, -982.95843505859, 30.874448776245), model = 952639784, faction = "Politie"},
    -- Usi acces in fata
    -- {pos = vector3(434.31747436523, -980.62573242188, 30.878421783447), model = 320433149, faction = "Politie"},
    -- {pos = vector3(434.31747436523, -983.22509765625, 30.878421783447), model = 320433149, faction = "Politie"},
    -- Usi Press Room
    {pos = vector3(434.52655029297, -989.49176025391, 30.873428344727), model = -1481015543, faction = "Politie"},
    {pos = vector3(437.12438964844, -989.49176025391, 30.873428344727), model = 952639784, faction = "Politie"},
    {pos = vector3(437.5100402832, -997.98663330078, 30.873428344727), model = -824920418, faction = "Politie"},
    -- Usi Parcare
    {pos = vector3(442.75088500977, -998.58380126953, 31.118602752686), model = 1847320387, faction = "Politie"},
    {pos = vector3(440.1142578125, -998.58435058594, 31.118141174316), model = -688443112, faction = "Politie"},
    -- Intrare angajati
    {pos = vector3(445.91851806641, -992.43664550781, 30.874198913574), model = 952639784, faction = "Politie"},
    {pos = vector3(445.91851806641, -995.03125, 30.874198913574), model = -1481015543, faction = "Politie"},
    --celule
    {pos = vector3(468.01861572266, -998.50024414063, 30.611513137817), model = 749848321, faction = "Politie"},
    {pos = vector3(476.40347290039, -1001.31640625, 30.610769271851), model = 1255964982, faction = "Politie"},
    --celule block A
    {pos = vector3(484.08312988281, -1006.7361450195, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(484.08306884766, -1010.8425292969, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(484.08306884766, -1014.9432983398, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(480.81735229492, -1006.7460327148, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(480.81729125977, -1010.8424682617, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(480.81729125977, -1014.9567871094, 30.612476348877), model = -1036090959, faction = "Politie"},
    --celule block B
    {pos = vector3(469.04446411133, -986.92669677734, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(464.93807983398, -986.92663574219, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(460.83731079102, -986.92663574219, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(469.03460693359, -983.66088867188, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(464.93814086914, -983.66082763672, 30.612476348877), model = -1036090959, faction = "Politie"},
    {pos = vector3(460.82385253906, -983.66082763672, 30.612476348877), model = -1036090959, faction = "Politie"},
    --Storage subsol
    {pos = vector3(480.58255004883, -1004.6126708984, 24.464721679688), model = 161378502, faction = "Politie"},
    {pos = vector3(477.97277832031, -1004.6127929688, 24.464660644531), model = -1572101598, faction = "Politie"},
    --Fotografie profil (mugshot)
    {pos = vector3(481.86373901367, -993.97302246094, 25.615550994873), model = 1255964982, faction = "Politie"},
    --MEDICAL JOS
    {pos = vector3(463.06848144531, -981.27825927734, 25.612670898438), model = 1438783233, faction = "Politie"},
    {pos = vector3(463.06848144531, -978.67846679688, 25.612670898438), model = 1438783233, faction = "Politie"},
    {pos = vector3(450.60971069336, -978.65026855469, 25.611850738525), model = 1438783233, faction = "Politie"},
    {pos = vector3(448.00802612305, -978.65026855469, 25.611850738525), model = 1438783233, faction = "Politie"},
    --GARAJ
    {pos = vector3(463.18762207031, -988.9169921875, 25.617481231689), model = 1255964982, faction = "Politie"},
    {pos = vector3(463.18762207031, -991.51568603516, 25.617481231689), model = 1255964982, faction = "Politie"},
    {pos = vector3(471.85821533203, -993.20336914063, 25.616542816162), model = 1255964982, faction = "Politie"},
    {pos = vector3(474.45706176758, -993.20336914063, 25.616542816162), model = 1255964982, faction = "Politie"},
    {pos = vector3(476.72189331055, -986.83129882813, 25.615550994873), model = 1255964982, faction = "Politie"},
    {pos = vector3(476.72189331055, -989.43341064453, 25.615550994873), model = 1255964982, faction = "Politie"},
    --USI EXTERIOR PARTEA DINSPRE AUTOBUZ
    {pos = vector3(479.69088745117, -979.45300292969, 28.143825531006), model = -1036090959, faction = "Politie"},
    {pos = vector3(477.09136962891, -979.45300292969, 28.143825531006), model = -1036090959, faction = "Politie"},
    --armurarie
    {pos = vector3(458.39822387695, -992.10705566406, 35.212627410889), model = -1036090959, faction = "Politie"},
    --storage sus
    {pos = vector3(467.50717163086, -994.43798828125, 35.212627410889), model = -1036090959, faction = "Politie"},
    --USI SUS ARMURARIE -> INTERGATORIU
    {pos = vector3(470.49057006836, -1000.7177124023, 35.206951141357), model = -1481015543, faction = "Politie"},
    {pos = vector3(470.48968505859, -998.11791992188, 35.206951141357), model = 952639784, faction = "Politie"},
    {pos = vector3(455.54663085938, -988.38311767578, 35.212100982666), model = 952639784, faction = "Politie"},
    {pos = vector3(455.54663085938, -985.78326416016, 35.212100982666), model = -1481015543, faction = "Politie"},
    --INTEROGARE
    {pos = vector3(477.64749145508, -996.25848388672, 35.21236038208), model = -1481015543, faction = "Politie"},
    {pos = vector3(477.64749145508, -988.15106201172, 35.21236038208), model = -824920418, faction = "Politie"},
    {pos = vector3(477.64309692383, -987.18200683594, 35.211696624756), model = -1481015543, faction = "Politie"},
    {pos = vector3(477.6438293457, -979.07934570313, 35.209060668945), model = -824920418, faction = "Politie"},
    {pos = vector3(482.66445922852, -996.25756835938, 35.214233398438), model = -1481015543, faction = "Politie"},
    {pos = vector3(482.66445922852, -988.14636230469, 35.214233398438), model = -824920418, faction = "Politie"},
    {pos = vector3(482.66006469727, -987.18804931641, 35.213569641113), model = -1481015543, faction = "Politie"},
    {pos = vector3(482.66079711914, -979.07202148438, 35.210933685303), model = -824920418, faction = "Politie"},
    --CAPTAIN ROOM
    {pos = vector3(447.36471557617, -974.37384033203, 35.212142944336), model = 952639784, faction = "Politie"},
    {pos = vector3(447.36471557617, -976.97344970703, 35.212142944336), model = -1481015543, faction = "Politie"},
    --BALCON USI
    {pos = vector3(429.24615478516, -993.95928955078, 35.940467834473), model = -2059357531, faction = "Politie"},
    {pos = vector3(429.24615478516, -996.30499267578, 35.940467834473), model = -1413382234, faction = "Politie"},
    --DALA UNDE TE IMBRACI ( NU MAI STIU CUM SE SCRIE )
    {pos = vector3(442.67965698242, -989.85278320313, 35.206253051758), model = -824920418, faction = "Politie"},
    {pos = vector3(448.22128295898, -989.84106445313, 35.210208892822), model = -824920418, faction = "Politie"},
    --HR
    {pos = vector3(449.26150512695, -996.04138183594, 39.567001342773), model = -1481015543, faction = "Politie"},
    --CAMERA DE CAMERE
    {pos = vector3(440.75659179688, -997.13043212891, 39.563663482666), model = -824920418, faction = "Politie"},
    --HELIPAD
    {pos = vector3(463.32379150391, -982.19689941406, 38.760417938232), model = -1036090959, faction = "Politie"},
    {pos = vector3(464.23046875, -984.68041992188, 43.843894958496), model = -1036090959, faction = "Politie"},

    -- Penitenciar
    {model = 1645000677,pos = vector3(1776.125, 2551.352, 46.09), faction = "Politie"},
    -- Interior Puscarie
    {pos = vector3(1789.2169189453, 2483.0424804688, 46.025375366211), model = -340230128, faction = "Politie"},
    {pos = vector3(1787.4438476563, 2484.92578125, 45.875511169434), model = -340230128, faction = "Politie"},
    {pos = vector3(1782.5235595703, 2481.9567871094, 45.891502380371), model = -519068795, faction = "Politie"},
    {pos = vector3(1759.9208984375, 2469.8642578125, 45.891502380371), model = -519068795, faction = "Politie"},
    {pos = vector3(1752.265625, 2465.2668457031, 45.848369598389), model = -340230128, faction = "Politie"},
    {pos = vector3(1749.8103027344, 2468.0747070313, 46.02368927002), model = -340230128, faction = "Politie"},
    {pos = vector3(1752.1328125, 2461.693359375, 46.012790679932), model = -340230128, faction = "Politie"},
    {pos = vector3(1786.498046875, 2490.2463378906, 46.048892974854), model = -340230128, faction = "Politie"},
    {pos = vector3(1766.2613525391, 2529.4147949219, 46.076061248779), model = -340230128, faction = "Politie"},

    -- Bijuterie
    -- ["biju_1"] = {pos = vector3(-630.42651367188, -238.43754577637, 38.206531524658), model = 9467943, allowed = true},
    -- ["biju_2"] = {pos = vector3(-631.95538330078, -236.33326721191, 38.206531524658), model = 1425919976, allowed = true},
}

Citizen.CreateThread(function()
    for k, v in pairs(allDoors) do
        v.isLocked = true
    end
end)

RegisterServerEvent('vrp-doors:toggle', function(id, lock)
    local player = source
    local user_id = vRP.getUserId(player)

    if allDoors[id].allowed or vRP.isUserInFaction(user_id, allDoors[id].faction) then
        allDoors[id].isLocked = lock
        TriggerClientEvent('vrp-doors:sync', -1, id, allDoors[id].isLocked)
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent('vrp-doors:sync', source, allDoors)
    end
end)
