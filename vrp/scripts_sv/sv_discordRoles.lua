local DiscordConfig = module('vrp', 'cfg/discord')
local FormattedToken = "Bot " .. GetConvar("discordBotKey", "false")

-- print(GetConvar("discordBotKey", "false"))

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(errorCode, resultData, resultHeaders)
        data = {data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {
        ["Content-Type"] = "application/json",
        ["Authorization"] = FormattedToken
    })

    while data == nil do
        Citizen.Wait(0)
    end

    return data
end

function GetRoles(user)
    local discordId = nil
    print('incepem getroles')
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            -- print("Found discord id: " .. discordId)
            break
        end
    end

    if discordId then
        local endpoint = ("guilds/%s/members/%s"):format(DiscordConfig.GuildId, discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            return roles
        else
            print("An error occurred, maybe they aren't in the discord? Error: " .. member.data)
            return false
        end
    else
        print("missing identifier")
        return false
    end
end

function IsRolePresent(user, role)
    local discordId = nil
    -- print('incepem isrolepresent '..role)
    -- for _, id in ipairs(GetPlayerIdentifiers(user)) do
    --     if string.match(id, "discord:") then
    --         discordId = string.gsub(id, "discord:", "")
    --         -- print("Found discord id: " .. discordId)
    --         break
    --     end
    -- end

    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            -- print("Found discord id: " .. discordId)
            break
        end
    end

    local theRole = nil
    if type(role) == "number" then
        theRole = tostring(role)
    else
        theRole = DiscordConfig.Roles[role]
    end

    if discordId then
        local endpoint = ("guilds/%s/members/%s"):format(DiscordConfig.GuildId, discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            for i = 1, #roles do
                if roles[i] == theRole then
                    -- print("Found role")
                    return true
                end
            end
            -- print("Not found!")
            return false
        else
            -- print("An error occurred, maybe they aren't in the discord? Error: " .. (data or 0))
            return false
        end
    else
        print("missing identifier")
        return false
    end
end

Citizen.CreateThread(function()
    local guild = DiscordRequest("GET", "guilds/" .. DiscordConfig.GuildId, {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        print("Permission system guild set to: " .. data.name .. " (" .. data.id .. ")")
    else
        print("An error occurred, please check your DiscordConfig and ensure everything is correct. Error: " .. (guild.data or guild.code)) 
    end
end)