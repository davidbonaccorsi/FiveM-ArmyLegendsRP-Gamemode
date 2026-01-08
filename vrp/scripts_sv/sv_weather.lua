
local apiKey <const>, town <const>, weatherTypes <const>, weatherCodes <const>, concatedWeatherTypes, weatherChanged, timeChanged = "aab76b6f0a7247a99b612750220907", "Timisoara", {
    ["Clear"] = "CLEAR";
    ["Clouds"]  = "CLOUDS";
    ["Drizzle"] = "CLEARING";
    ["Rain"] = "RAIN";
    ["Thunderstorm"] = "THUNDER";
    ["Fog"] = "FOGGY";
    ["Snow"] = "XMAS";
    ["Reset"] = "RESET";
}, {
    [1000] = {
        type = "CLEAR",
        rain = -1,
    },

    [1003] = {
       type = "CLOUDS",
       rain = -1,
    },

    [1006] = {
       type = "CLOUDS",
       rain = -1,
    },

    [1009] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1030] = {
       type = "FOGGY",
       rain = -1,
    },

    [1063] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1066] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1069] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1072] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1087] = {
       type = "OVERCAST",
       rain = 1.0,
    },

    [1114] = {
       type = "OVERCAST",
       rain = -1,
    },

    [1117] = {
       type = "BLIZZARD",
       rain = -1,
    },

    [1135] = {
       type = "FOGGY",
       rain = -1,
    },

    [1147] = {
       type = "FOGGY",
       rain = -1,
    },
    [1150] = {
       type = "RAIN",
       rain = 0.2,
    },

    [1153] = {
       type = "RAIN",
       rain = 0.3,
    },

    [1168] = {
       type = "RAIN",
       rain = 0.4,
    },

    [1171] = {
       type = "RAIN",
       rain = 0.4,
    },

    [1180] = {
       type = "RAIN",
       rain = 0.5,
    },

    [1183] = {
       type = "RAIN",
       rain = 0.5,
    },

    [1186] = {
       type = "RAIN",
       rain = 0.6,
    },

    [1189] = {
       type = "RAIN",
       rain = 0.6,
    },

    [1192] = {
       type = "RAIN",
       rain = 0.8,
    },

    [1195] = {
       type = "THUNDER",
       rain = 0.8,
    },

    [1198] = {
       type = "THUNDER",
       rain = 0.9,
    },

    [1201] = {
       type = "THUNDER",
       rain = 0.9,
    },

    [1204] = {
       type = "SNOWLIGHT",
       rain = 0.2,
    },

    [1207] = {
       type = "SNOWLIGHT",
       rain = 1.0,
    },

    [1210] = {
       type = "SNOWLIGHT",
       rain = -1,
    },

    [1213] = {
       type = "SNOWLIGHT",
       rain = -1,
    },

    [1216] = {
       type = "SNOWLIGHT",
       rain = -1,
    },

    [1219] = {
       type = "XMAS",
       rain = -1,
    },

    [1222] = {
       type = "XMAS",
       rain = -1,
    },

    [1225] = {
       type = "XMAS",
       rain = -1,
    },

    [1237] = {
       type = "XMAS",
       rain = -1,
    },

    [1240] = {
       type = "RAIN",
       rain = -1,
    },

    [1243] = {
       type = "THUNDER",
       rain = 1.0,
    },

    [1246] = {
       type = "THUNDER",
       rain = 1.0,
    },

    [1249] = {
       type = "SNOWLIGHT",
       rain = 0.3,
    },

    [1252] = {
       type = "SNOWLIGHT",
       rain = 1.0,
    },

    [1255] = {
       type = "SNOWLIGHT",
       rain = -1,
    },

    [1258] = {
       type = "XMAS",
       rain = -1,
    },

    [1261] = {
       type = "XMAS",
       rain = -1,
    },

    [1264] = {
       type = "XMAS",
       rain = -1,
    },

    [1273] = {
       type = "THUNDER",
       rain = 0.7,
    },

    [1276] = {
       type = "THUNDER",
       rain = 1.0,
    },

    [1279] = {
       type = "THUNDER",
       rain = 0.5,
    },

    [1282] = {
       type = "XMAS",
       rain = -1,
    },
}, "", false, false; GlobalState.actWeather, GlobalState.actTime = {type = weatherCodes[1000].type; rain = weatherCodes[1000].rain; wind = {.0; .0}}, os.date("*t");

local prepareConcatedWeatherTypes <const> = coroutine.create(function()
    local concatWeatherTypes <const> = {};
    for weatherType in next, weatherTypes do concatWeatherTypes[#concatWeatherTypes+1] = weatherType end;
    concatedWeatherTypes = table.concat(concatWeatherTypes, ", ");
    concatedWeatherTypes = concatedWeatherTypes:reverse():sub(1):reverse();
end); coroutine.resume(prepareConcatedWeatherTypes);

local fetchLink <const> = ("http://api.weatherapi.com/v1/current.json?key=%s&q=%s"):format(apiKey, town);

local function fetchSyncData(cb, resetTime, fetched)
   if weatherChanged or resetTime then return cb(false, os.date("*t")) end;

   PerformHttpRequest(fetchLink, function(_, data)
      local fetchedData = json.decode(data)
      
      if not fetchedData then
         fetched = fetched or 0
         if fetched > 3 then fetchedData = {} goto skip end
         Wait(100)
         fetched += 1
         return fetchSyncData(cb, resetTime, fetched)
      end

      ::skip::

      local weatherCode = weatherCodes[fetchedData.current?.condition?.code]
      local weather <const>, currentTime <const> = weatherCode and {type = weatherCode.type; rain = weatherCode.rain; wind = {fetchedData.current.wind_mph; fetchedData.current.wind_degree}}, (not timeChanged and os.date("*t"));
      cb(weather, currentTime);
   end);
end;

CreateThread(function()
    while true do

        if weatherChanged and timeChanged then
            goto continue
        end;

        fetchSyncData(function(weather, currentTime)
            if weather then
                GlobalState.actWeather = weather
            end;
            
            if currentTime then
                GlobalState.actTime = currentTime
            end;
            
            TriggerClientEvent("weather:syncData", -1, {(weather and true), (currentTime and true)});
        end);
        
        ::continue::;

        Wait(60000);
    end;
end);

local function changeWeatherCommandHandler(player, args)
   --  if not (player == 0) or not IsPlayerAceAllowed(player, "command") then return end;
   local granted = (player == 0)
   if not granted then
     granted = IsPlayerAceAllowed(player, "command")
   end
   
   if not granted then return vRPclient.noAccess(player) end

    local weatherToChange <const> = firstToUpper(tostring(args[1]));
    if not weatherTypes[weatherToChange] then return print(("^1weather <type>\n^3Tipuri disponibile: %s"):format(concatedWeatherTypes)) end;

    local reset <const> = (weatherToChange:lower() == "reset");
    weatherChanged = not reset;

    print("^2Vreme setata cu succes.");

    if not reset then
        GlobalState.actWeather = weatherTypes[weatherToChange] and {type = weatherTypes[weatherToChange]; rain = -1; wind = {.0; .0}} or GlobalState.actWeather;
        return TriggerClientEvent("weather:syncData", -1, {true}, true);
    end;

    fetchSyncData(function(weather)
        GlobalState.actWeather = weather or GlobalState.actWeather;
        TriggerClientEvent("weather:syncData", -1, {true});
    end);
end;

local function changeTimeCommandHandler(player, args)
   --  if not (player == 0) or not IsPlayerAceAllowed(player, "command") then return end;
    local granted = (player == 0)
    if not granted then
      granted = IsPlayerAceAllowed(player, "command")
    end
    
    if not granted then return vRPclient.noAccess(player) end
   

    local timeToChange = tostring(args[1] or "");
    if not (#timeToChange > 0) then return print("^1time <hour or reset>") end;

    local reset <const> = (timeToChange:lower() == "reset");
    timeChanged = not reset

    print("^2Timp setat cu succes.");

    if not reset then
        GlobalState.actTime = {hour = tonumber(timeToChange); min = 0} or GlobalState.actTime;
        return TriggerClientEvent("weather:syncData", -1, {false; true}, true);
    end;

    fetchSyncData(function(_, currentTime)
        GlobalState.actTime = currentTime or GlobalState.actTime;
        TriggerClientEvent("weather:syncData", -1, {false; true});
    end, 1);
end;

RegisterCommand("weather", changeWeatherCommandHandler);
RegisterCommand("time", changeTimeCommandHandler);

local function playerSpawnHandler(_, player, fs)
    if not fs then return end;
    TriggerClientEvent("weather:syncData", player, {weatherChanged; timeChanged}, (weatherChanged or timeChanged));
end;

AddEventHandler("vRP:playerSpawn", playerSpawnHandler);