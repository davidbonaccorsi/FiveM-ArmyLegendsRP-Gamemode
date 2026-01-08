
local shellTypes = {
    ['nice']       =    {prop = `shell_v16mid`, exit = vector3(1.350654602051, -13.6745605469, 1.1480102539063)},
    ['trevor']     =    {prop = `shell_trevor`, exit = vector3(0.174087524414, -2.9365234375, 2.4279838204384)},
    ['lester']     =    {prop = `shell_lester`, exit = vector3(-1.59306716919, -5.4445800781, 1.1083898544311)},
    ['mansion']    =    {prop = `shell_ranch`,  exit = vector3(-0.891490936279, 5.5625, 2.403707504272)},
    ['kinda_nice'] =    {prop = `shell_v16low`, exit = vector3(4.7033157348633, -5.9797363281, 1.133777141571)},

    ['app1'] =    {prop = `shell_apartment1`, exit = vector3(-2.1644287109375, 7.9835815429688, 8.6945953369141)}, -- 3etj - rosu
    ['app2'] =    {prop = `shell_apartment2`, exit = vector3(-2.16748046875, 7.8786926269531, 8.6947326660156)}, -- 3etj -- maro
    ['app3'] =    {prop = `shell_apartment3`, exit = vector3(10.953491210938, 4.0802917480469, 8.1300201416016)}, -- franklin

    ['sh1'] =    {prop = `shell_michael`, exit = vector3(-8.645263671875, 5.6779937744141, 9.9177551269531)}, -- michael
    ['sh2'] =    {prop = `shell_highend`, exit = vector3(-20.912353515625, -0.27378845214844, 7.2604675292969)}, -- eclipse 2 nivele
    ['sh3'] =    {prop = `shell_highendv2`, exit = vector3(-9.4288330078125, 1.3128051757812, 6.5580139160156)}  -- eclipse un nivel
}

function createHouseShell(pos, tip)
    local shellProp = shellTypes[tip].prop
    RequestModel(shellProp)
    local k = 0
    while not HasModelLoaded(shellProp) do
        k = k + 1
        if k >= 1000 then break end
        Citizen.Wait(10)
    end

    if k < 1000 then
        local objs = {}

        table.insert(objs, CreateObject(shellProp, pos.x, pos.y, pos.z, false, false, false))
        FreezeEntityPosition(objs[1], true, true)

        local e = pos.xyz + shellTypes[tip].exit

        local exit = vector4(e.x, e.y, e.z, 2.26)

        return {
            objects = objs,
            exit = exit
        }
    end
    return false
end


-- local plypos, name = nil, nil

-- RegisterCommand("shell", function(player, args)
--     if args[1] then
--         local shellProp = GetHashKey(args[1])

--         print(shellProp)
--         RequestModel(shellProp)
--         local k = 0
--         while not HasModelLoaded(shellProp) do
--             k = k + 1
--             if k >= 1000 then break end
--             Citizen.Wait(10)
--         end

--         if k < 1000 then

--             plypos = GetEntityCoords(GetPlayerPed(-1))

--             local obj = CreateObject(shellProp, plypos.x, plypos.y, plypos.z, true, false, false)
--             FreezeEntityPosition(obj, true, true)

--             Citizen.CreateThread(function()
--                 Citizen.Wait(120000)
--                 DeleteObject(obj)
--             end)
--         end
--     end
-- end)

-- RegisterCommand("ext", function()
--    if plypos then
--         local nowpos = GetEntityCoords(GetPlayerPed(-1))
--         local diff = nowpos - plypos

--         print(name, diff.x, diff.y, diff.z)
--    end
-- end)

