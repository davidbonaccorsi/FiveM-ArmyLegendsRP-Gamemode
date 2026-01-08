local object = nil

LoadDict = function(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(200)
    end
end

LoadProp = function(model)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(200)
    end
end

ToggleAnimation = function(state)
    local ped = PlayerPedId()
    
    if state then
        LoadDict('amb@world_human_seat_wall_tablet@female@base')

        if not object then
            LoadProp('prop_cs_tablet')

            local hash = GetHashKey('prop_cs_tablet')
            local coords = GetEntityCoords(ped, false)

            object = CreateObject(hash, x, y, z, true, true, false)
            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 28422),  0.0, 0.0, 0.03, 0.0, 0.0, 0.0, true, true, false, false, 0, true)
        end

        if not IsEntityPlayingAnim(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 3) then
            TaskPlayAnim(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 8.0, 1.0, -1, 49, 1.0, false, false, false)
        end
    else
        DeleteEntity(object)
        DetachEntity(object)
        ClearPedTasks(ped)
        object = nil
    end
end