local function createExamVeh(model, coords, heading)
    local hash, loadTime = GetHashKey(model), GetGameTimer()
    
    RequestModel(hash)
    while not HasModelLoaded(hash) and GetGameTimer() - loadTime <= 50000 do
        Citizen.Wait(1)
    end

    if not HasModelLoaded(hash) then
        print("[ERROR] Vehicle doesent loaded")
        return
    end

    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, true)
    NetworkFadeInEntity(veh, 0)
    SetEntityInvincible(veh, false)
    SetPedIntoVehicle(tempPed, veh, -1)

    return veh
end

Citizen.CreateThread(function()
    local dmvCoords = vec3(-1109.9117431641,-2771.3215332031,21.361360549927)

    local blip = AddBlipForCoord(dmvCoords)
	SetBlipSprite(blip, 773)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 62)
    SetBlipPriority(blip, 1)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Scoala de Soferi")
    EndTextCommandSetBlipName(blip)

    exports["vrp"]:spawnNpc("dmvSchool", {
        position = dmvCoords,
        rotation = 295,
        model = "a_m_m_prolhost_01",
        freeze = true,
        minDist = 2.5,
        name = "Mircea Instructoru'",

        buttons = {
            {
                text = "Sustine testul teoretic", response = function()
                    local p = promise.new()

                    triggerCallback("vrp-dmv:openExaminationMenu", function(success, message)
                        if success then
                            SendNUIMessage({
                                act = "interface",
                                target = "drivingSchool",
                            })
                        end

                        p:resolve({message or false, success})
                    end)

                    return Citizen.Await(p)
                end
            }
        }
    })
end)

RegisterNUICallback("completeDmv", function(data, cb)
    TriggerServerEvent("vrp-dmv:updateExamination", data[1])
    cb("ok")
end)

local drivingCoords = vector3(-978.71099853516,-2689.3059082031,13.831010818481)
local drivingRoute = {
	vector3(-991.07135009766,-2695.0537109375,13.831010818481),
	vector3(-1006.4624023438,-2703.2529296875,13.831010818481),
    vector3(-1006.4624023438,-2703.2529296875,13.831010818481),
    vector3(-1003.4439697266,-2724.0405273438,13.812890052795),
    vector3(-952.36401367188,-2730.5727539063,13.812936782837),
    vector3(-909.74969482422,-2685.5578613281,13.774210929871),
    vector3(-845.50866699219,-2570.8879394531,13.72399520874),
    vector3(-806.5986328125,-2475.6965332031,13.736536979675),
    vector3(-839.37725830078,-2398.1435546875,16.120262145996),
    vector3(-800.92846679688,-2236.6994628906,17.285041809082),
    vector3(-694.80126953125,-2136.3469238281,13.376739501953),
    vector3(-549.10601806641,-2072.7543945313,27.682699203491),
    vector3(-467.16513061523,-2046.0623779297,36.508632659912),
    vector3(-470.62768554688,-1986.5637207031,35.54663848877),
    vector3(-595.55090332031,-1950.005859375,27.174812316895),
    vector3(-754.49261474609,-1772.8537597656,29.2887840271),
    vector3(-797.82403564453,-1710.3189697266,30.122501373291),
    vector3(-922.14270019531,-1837.7149658203,34.706153869629),
    vector3(-625.67419433594,-2183.5295410156,52.793262481689),
    vector3(-255.47393798828,-2440.7099609375,57.839893341064),
    vector3(-73.321464538574,-2572.6591796875,36.337627410889),
    vector3(141.87376403809,-2657.9243164063,19.119226455688),
    vector3(337.81390380859,-2671.994140625,19.898170471191),
    vector3(903.89581298828,-2611.1494140625,50.081031799316),
    vector3(1216.0021972656,-2544.6091308594,38.48900604248),
    vector3(1256.005859375,-2077.1481933594,44.730308532715),
    vector3(1091.8515625,-2069.0751953125,36.099208831787),
    vector3(808.23687744141,-2061.9436035156,29.360420227051),
    vector3(838.29846191406,-1775.3072509766,29.123777389526),
    vector3(798.67523193359,-1458.3891601563,27.234878540039),
    vector3(798.9462890625,-1165.2462158203,28.828401565552),
    vector3(679.37408447266,-412.22232055664,41.61060333252),
    vector3(495.25479125977,-316.85894775391,45.520027160645),
    vector3(94.896789550781,-166.1490020752,54.961605072021),
    vector3(-539.11346435547,9.0624170303345,44.242443084717),
    vector3(-565.30548095703,-39.688049316406,42.334671020508),
    vector3(-525.88720703125,-120.99896240234,38.449607849121),
    vector3(-591.28869628906,-165.54266357422,37.647899627686),
    vector3(-572.88903808594,-280.1611328125,34.740459442139),
    vector3(-610.9501953125,-329.81521606445,34.431995391846),
    vector3(-639.57836914063,-491.89157104492,34.377742767334),
    vector3(-640.85723876953,-810.2529296875,24.637571334839),
    vector3(-749.99163818359,-1100.3083496094,10.366600990295),
    vector3(-693.45819091797,-1240.2388916016,10.17905902862),
    vector3(-771.38244628906,-1693.1735839844,28.789558410645),
    vector3(-767.0068359375,-1747.5280761719,28.796543121338),
    vector3(-703.36395263672,-2022.48828125,24.084844589233),
    vector3(-825.5927734375,-2245.3420410156,16.766304016113),
    vector3(-947.05560302734,-2404.7124023438,13.351971626282),
    vector3(-1003.5022583008,-2705.1923828125,13.408432006836),
    vector3(-992.92510986328,-2697.0385742188,13.418845176697)
}

RegisterNetEvent("vrp-dmv:startDriving", function()
    local inDriveTest
    local vehicle = createExamVeh("emperor2", drivingCoords, GetEntityHeading(tempPed))

    TriggerEvent("vrp-hud:hint", "Urmareste indicatiile traseului pentru a termina testul.", "DMV School", "fas fa-car")

    while not DoesEntityExist(vehicle) do
		Citizen.Wait(100)
	end
    
    inDriveTest = true
    
	Citizen.CreateThread(function()
		while inDriveTest do
			Citizen.Wait(500)

			if not DoesEntityExist(vehicle) then
				inDriveTest = false
				break
			end
		end
	end)

    local blip = AddBlipForCoord(drivingRoute[1])

	SetBlipSprite(blip, 271)
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.6)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 0)
    SetBlipAsShortRange(blip, true)

    for i in pairs(drivingRoute) do

		while inDriveTest do
			Citizen.Wait(1)
			DrawMarker(1, drivingRoute[i] - vec3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 4.0, 255, 255, 255, 100)
            DrawMarker(22, drivingRoute[i] + vec3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 200, true, true, false, true)

            local vehCoords = GetEntityCoords(vehicle)

			if #(drivingRoute[i] - vehCoords) <= 10.0 then
                if drivingRoute[i + 1] then
                    SetBlipCoords(blip, drivingRoute[i + 1])
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 0)
                end

				break
			end
		end
    end

    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end

	if inDriveTest then
        TriggerEvent("vrp-hud:hint", "Parcheaza autoturismul cu spatele.", "DMV School", "fas fa-car")

		while inDriveTest do
			local heading = GetEntityHeading(vehicle) or 0.0

            if math.abs(heading - 208.0) <= 3 and GetEntitySpeed(vehicle) <= 0.5 then
				Citizen.Wait(2000)

				break
			end

			Citizen.Wait(1)
		end

        DoScreenFadeOut(3000)
		Citizen.Wait(3000)

		inDriveTest = false

		TriggerServerEvent("vrp-dmv:finishExamination")

        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end

		Citizen.Wait(1000)
		DoScreenFadeIn(2000)
	end
end)