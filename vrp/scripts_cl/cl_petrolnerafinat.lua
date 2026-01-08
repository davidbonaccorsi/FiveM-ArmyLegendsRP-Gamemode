local petrol_nerafinat = {2709.3220214844,1714.7430419922,24.576730728149}
local fura_petrol = {4284.845703125,2967.4372558594,-181.84521484375}
local inPos = false

Citizen.CreateThread(function()
    exports['vrp']:spawnNpc("petrolNerafinat", {
        position = vector3(petrol_nerafinat[1], petrol_nerafinat[2], petrol_nerafinat[3]),
        rotation = 137,
        model = "a_m_m_hasjew_01",
        freeze = true,
        minDist = 2.5,
        name = "Stanescu Lata",
        ["function"] = function()
            TriggerServerEvent("vl:cumpara_petrol_nerafinat")
        end
    })
    tvRP.addBlip("vRP:petrol_nerafinat_cumpara", petrol_nerafinat[1], petrol_nerafinat[2], petrol_nerafinat[3], 570, 17, "Punct Colectare Petrol", 0.5)
    tvRP.addBlip("vRP:petrol_nerafinat_fura", fura_petrol[1], fura_petrol[2], fura_petrol[3], 570, 17, "Punct Colectare Petrol", 0.5)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        if #(GetEntityCoords(PlayerPedId()) - vector3(fura_petrol[1], fura_petrol[2], fura_petrol[3])) <= 2 then
            if not inPos then TriggerEvent("vrp-hud:showBind", {key = "E", text = "Fura Petrol"}) end
            inPos = true
        elseif #(GetEntityCoords(PlayerPedId()) - vector3(fura_petrol[1], fura_petrol[2], fura_petrol[3])) > 2 then
            inPos = false
            TriggerEvent("vrp-hud:showBind", false)
        end
    end
end)

RegisterCommand("furapetrol", function()
    if inPos then
        SendNUIMessage({job = "petrol-nerafinat-game"})
    end
end)

RegisterKeyMapping("furapetrol", "Fura Petrol", "keyboard", "E")

RegisterNUICallback("petrol:gameDone", function()
    TriggerServerEvent("vl:fura_petrol")
end)