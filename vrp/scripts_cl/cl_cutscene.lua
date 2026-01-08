local Cutscene = {}

Cutscene.WeatherType = "EXTRASUNNY"
Cutscene.RandomPassengersClothes = true

Cutscene.Faces = { 
    [0] = 21, 
    [1] = 13, 
    [2] = 15, 
    [3] = 14, 
    [4] = 18, 
    [5] = 27, 
    [6] = 16 
}

Cutscene.Masks = { 
    [0] = 0, 
    [1] = 0, 
    [2] = 0, 
    [3] = 0, 
    [4] = 0, 
    [5] = 0, 
    [6] = 0 
}

Cutscene.Hairs = { 
    [0] = 9, 
    [1] = 5, 
    [2] = 1, 
    [3] = 5, 
    [4] = 15, 
    [5] = 7, 
    [6] = 15
}

Cutscene.Torsos = {
    [0] = 1, 
    [1] = 1, 
    [2] = 1, 
    [3] = 3, 
    [4] = 15, 
    [5] = 11, 
    [6] = 3 
}

Cutscene.Legs = {
    [0] = 9, 
    [1] = 10, 
    [2] = 0, 
    [3] = 1, 
    [4] = 2, 
    [5] = 4, 
    [6] = 5 
}

Cutscene.ParachuteBags = { 
    [0] = 0, 
    [1] = 0, 
    [2] = 0, 
    [3] = 0, 
    [4] = 0, 
    [5] = 0, 
    [6] = 0 
}

Cutscene.Shoes = {
    [0] = 4, 
    [1] = 10, 
    [2] = 1 ,
    [3] = 11, 
    [4] = 4, 
    [5] = 13, 
    [6] = 2 
}

Cutscene.Accessories = {
    [0] = 0, 
    [1] = 11, 
    [2] = 0, 
    [3] = 0, 
    [4] = 4, 
    [5] = 5, 
    [6] = 0
}

Cutscene.Undershirts = {
    [0] = 15, 
    [1] = 13, 
    [2] = 2, 
    [3] = 2, 
    [4] = 3, 
    [5] = 3, 
    [6] = 2 
}

Cutscene.Kevlars = { 
    [0] = 0, 
    [1] = 0, 
    [2] = 0, 
    [3] = 0, 
    [4] = 0, 
    [5] = 0, 
    [6] = 0 
}

Cutscene.Badges = { 
    [0] = 0, 
    [1] = 0, 
    [2] = 0, 
    [3] = 0, 
    [4] = 0, 
    [5] = 0, 
    [6] = 0 
}

Cutscene.Torsos2s = { 
    [0] = 10, 
    [1] = 10, 
    [2] = 6, 
    [3] = 3, 
    [4] = 4, 
    [5] = 2, 
    [6] = 3
}

local pedsList = {
    [0] = "MP_Plane_Passenger_1",
    [1] = "MP_Plane_Passenger_2",
    [2] = "MP_Plane_Passenger_3",
    [3] = "MP_Plane_Passenger_4",
    [4] = "MP_Plane_Passenger_5",
    [5] = "MP_Plane_Passenger_6",
    [6] = "MP_Plane_Passenger_7"
}

-- Definition of the different components types.
local ComponentsTypes = { 
    [0] = Cutscene.Faces,
    [1] = Cutscene.Masks,
    [2] = Cutscene.Hairs,
    [3] = Cutscene.Torsos,
    [4] = Cutscene.Legs,
    [5] = Cutscene.ParachuteBags,
    [6] = Cutscene.Shoes,
    [7] = Cutscene.Accessories,
    [8] = Cutscene.Undershirts,
    [9] = Cutscene.Kevlars,
    [10] = Cutscene.Badges,
    [11] = Cutscene.Torsos2s
}

function IsMpPed(ped)
	local Male = GetHashKey("mp_m_freemode_01") local Female = GetHashKey("mp_f_freemode_01")
	local CurrentModel = GetEntityModel(ped)
	if CurrentModel == Male then return "male" elseif CurrentModel == Female then return "female" else return false end
end

RegisterNetEvent("introCinematic:start")
AddEventHandler("introCinematic:start", function()
    PrepareMusicEvent("FM_INTRO_START") -- ``FM_INTRO_START``
    TriggerMusicEvent("FM_INTRO_START") -- ``FM_INTRO_START``

    local playerId = PlayerPedId()
    local gender = IsMpPed(playerId)

    print(gender)
    
    if gender == "male" then 
        RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 31, 8)
    else 
        RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 103, 8)
    end

    while not HasCutsceneLoaded() do 
        Wait(10) 
    end -- Waiting for the cutscene to load!

    if gender == "male" then 
        GeneratePed("MP_Male_Character", "MP_Female_Character", playerId)
    else 
        GeneratePed("MP_Female_Character", "MP_Male_Character", playerId)
    end

    local peds = {}
    for pedIdx = 0, 6, 1 do
        if pedIdx == 1 or pedIdx == 2 or pedIdx == 4 or pedIdx == 6 then
            peds[pedIdx] = CreatePed(26, "mp_f_freemode_01", -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
        else
            peds[pedIdx] = CreatePed(26, "mp_m_freemode_01", -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
        end

        if not IsEntityDead(peds[pedIdx]) then
            HandlePassengersClothes(peds[pedIdx], pedIdx)
            FinalizeHeadBlend(peds[pedIdx])
            RegisterEntityForCutscene(peds[pedIdx], pedsList[pedIdx], 0, 0, 64)
        end
    end

    NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0) -- Avoid texture bugs!

    SetWeatherTypeNow(Cutscene.WeatherType) -- Setting the weather type!
    StartCutscene(4) -- Starting the cutscene!

    -- Wait for a specified duration (in milliseconds) before stopping the cutscene
    local cutsceneDuration = 34000 -- 34 seconds
    Wait(cutsceneDuration)

    StopCutsceneImmediately() -- Stop the cutscene

    for pedIdx = 0, 6, 1 do 
        DeleteEntity(peds[pedIdx]) 
    end

    PrepareMusicEvent("AC_STOP")
    TriggerMusicEvent("AC_STOP")
end)


-- Generate main char ped!
function GeneratePed(modelString, modelString2, playerId)
	RegisterEntityForCutscene(0, modelString, 3, GetEntityModel(playerId), 0)
	RegisterEntityForCutscene(playerId, modelString, 0, 0, 0)
	SetCutsceneEntityStreamingFlags(modelString, 0, 1) 

	local ped = RegisterEntityForCutscene(0, modelString2, 3, 0, 64)

	NetworkSetEntityInvisibleToNetwork(ped, true)
end

function ClearPedProps(ped)
    for i = 0, 8, 1 do
        ClearPedProp(ped, i)
    end
end

function HandleRandomPeds(ped)
    SetPedRandomComponentVariation(ped, 0) 
    ClearPedProps(ped)
end

function HandlePassengersClothes(ped, pedIdx)
    if Cutscene.RandomPassengersClothes then
        if pedIdx >= 0 and pedIdx <= 6 then HandleRandomPeds(ped) end
    else
        for i = 0, 6, 1 do -- Loop through all peds.
            if pedIdx >= 0 and pedIdx <= 6 then -- Checkt he player idx.
                for j = 0, 11, 1 do -- Loop through all of the 11 components.
                    local component = ComponentsTypes[j] -- Get omponent Cutscene.
                    local numberOfTextures = GetNumberOfPedTextureVariations(ped, j, component[i])
                    local randomTexture = math.random(numberOfTextures)

                    SetPedComponentVariation(ped, j, component[i], randomTexture, 0)
                    ClearPedProps(ped)
                end
            end
        end
    end
end
