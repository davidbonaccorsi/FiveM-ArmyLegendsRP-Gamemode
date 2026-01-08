local lastUsedVeh = nil
local plateData = {
    index = false,
    text = false,
}

RegisterCommand("scoateplacuta", function()
    if not lastUsedVeh or (lastUsedVeh and not DoesEntityExist(lastUsedVeh)) then
        local theVeh = GetClosestVehicle(pedPos, 3.5, 0, 70)
        local vehCds = GetEntityCoords(theVeh)
        local dist = #(vehCds - pedPos)

        if dist < 3.5 and (playerVehicle == 0) then
			lastUsedVeh = theVeh
            TriggerEvent("vrp:progressBar", {
                text = "Demontezi placuta...",
                duration = 6000,
                anim = {
                    dict = "mini@repair",
                    name = "fixing_a_player"
                }
            }, function()
                plateData = {
                    index = GetVehicleNumberPlateTextIndex(theVeh),
                    text = GetVehicleNumberPlateText(theVeh),
                }

                SetVehicleNumberPlateText(theVeh, " ")
            end)
        else
            tvRP.notify("Nu este niciun vehicul in apropiere!", "error")
        end
    else
        tvRP.notify("Ai scos deja placuta de inmatriculare!", "error")
    end
end)

RegisterCommand("puneplacuta", function()
    if plateData.index and plateData.text then
        local theVeh = GetClosestVehicle(pedPos, 3.5, 0, 70)
        local vehCds = GetEntityCoords(theVeh)
        local dist = #(vehCds - pedPos)

        if dist < 3.5 and (playerVehicle == 0) then
            if (theVeh == lastUsedVeh) then
                lastUsedVeh = nil
                TriggerEvent("vrp:progressBar", {
                    text = "Montezi placuta...",
                    duration = 6000,
                    anim = {
                        dict = "mini@repair",
                        name = "fixing_a_player"
                    }
                }, function()
                    SetVehicleNumberPlateTextIndex(theVeh, plateData.index)
                    SetVehicleNumberPlateText(theVeh, plateData.text)
                    
                    plateData = {
                        index = false,
                        text = false,
                    }
                end)
            else
                tvRP.notify("Nu se poate monta placuta pe aceasta masina!", "error")
            end
        else
            tvRP.notify("Nu este niciun vehicul in apropiere!", "error")
        end
    else
        tvRP.notify("Ai scos deja placuta de inmatriculare!", "error")
    end
end)
