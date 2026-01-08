
RegisterNetEvent("vrp-begginer:setQuest")
AddEventHandler("vrp-begginer:setQuest", function(questTbl, allQuest)

    if type(questTbl) == "table" then
        for key, index in pairs(questTbl) do
            allQuest[index].done = true
        end

        SendNUIMessage({
            interface = "beginnerQuest",
            event = "show",
            quests = allQuest
        })

    else
        SendNUIMessage({interface = "beginnerQuest", event = "hide"})
    end

end)

RegisterNetEvent("vrp-begginer:showCompleted", function(mission)
    
    PlaySoundFrontend(-1, "OTHER_TEXT", "HUD_AWARDS")
    SendNUIMessage({
        interface = "beginnerQuest",
        event = "complete",
        quest = mission,
    })
end)
