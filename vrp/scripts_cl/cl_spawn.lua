
local rentPos = vector3(-1032.3897705078,-2736.412109375,20.169290542603)
local rentSpawns = {
    vector3(-1016.8012695313,-2691.9033203125,13.984250068665),
    vector3(-1009.1018066406,-2681.8674316406,13.981590270996),
    vector3(-1009.6661987305,-2693.3566894531,13.989523887634),
}

local activeRent = {}

Citizen.CreateThread(function()
	local txd = CreateRuntimeTxd("helpped")
	CreateRuntimeTextureFromImage(txd, "info", "assets/helpped.png")
end)

local function DrawImage3D(name, x, y, z, width, height, rot) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, true)
	
    if onScreen then
		local width = (1/dist)*width
		local height = (1/dist)*height
		local fov = (1/GetGameplayCamFov())*100
		local width = width*fov
		local height = height*fov
	
		DrawSprite("helpped", name, _x, _y, width, height, rot, 255, 255, 255, 255)
	end
end


Citizen.CreateThread(function()
    local inputActive = false
        
    RegisterNetEvent("spawn:rent", function(pos, skip)
        if activeRent.ent then
            return TriggerEvent("vrp-hud:notify", "Ai deja un vehicul inchiriat.", "error", "Rent")
        end

        triggerCallback("rent:checkMoney", function(canRent)
            if not canRent then
                return tvRP.notify("Nu ai destui bani pentru a inchiria un vehicul.", "error")
            end

            activeRent.ent = tvRP.spawnCar("faggio", pos or rentSpawns[math.random(1, #rentSpawns)], 65.0)
            activeRent.time = GetGameTimer() + 600000

            Citizen.CreateThread(function()
                while true do
                    
                    if GetGameTimer() > activeRent.time then
                        DeleteEntity(activeRent.ent)
                        activeRent = false
                    end
                    
                    if not activeRent or not DoesEntityExist(activeRent.ent) then
                        activeRent = {}
                        TriggerEvent("vrp-hud:notify", "Timpul a expirat, prin urmare vehiculul inchiriat a fost sters.", "info", "Rent")
                        
                        break
                    end
                
                    Citizen.Wait(1000)
                end         
            end)
        end, pos, skip)

    end)

    tvRP.spawnNpc({
		position = rentPos,
		rotation = 120,
		model = "s_m_o_busker_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_STAND_IMPATIENT"
		},
		minDist = 3.5,
		
		name = "Sebastian Kevin",
        input = "Inchiriaza un scuter",
        ["function"] = function()
            TriggerEvent("spawn:rent")
        end
	})

    while true do
        Citizen.Wait(1000)

        while #(rentPos - pedPos) <= 15 do
            Citizen.Wait(1)

            DrawImage3D("info", rentPos.x, rentPos.y, rentPos.z + 1.5, 0.155, 0.28, 0.0)
        end
    end
end)
