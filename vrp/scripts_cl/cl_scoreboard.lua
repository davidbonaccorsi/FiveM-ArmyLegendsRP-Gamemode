RegisterNetEvent("scoreboard:togShow", function(data)    
    local fix = {} -- fast fix to be repaired

    for k, v in pairs(data.playerList) do
        table.insert(fix, v)
    end
    data.playerList = fix

    SendNUIMessage({interface = "scoreboard", data = data})
end)