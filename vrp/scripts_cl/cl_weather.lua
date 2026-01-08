local currentWeather, lastWeather, xmas, rain, wind, weatherChanged, crrentTime, lastTime, timeChanged = "EXTRASUNNY", "EXTRASUNNY", false, .0, {.0; .0}, false, {hour = 12; min = 30}, {hour = 12; min = 30}, false;

local function setWeather(change)
    weatherChanged = change;

    local actWeather = GlobalState.actWeather
    currentWeather, rain, wind = actWeather.type, actWeather.rain, actWeather.wind;
    if not (currentWeather ~= lastWeather) then 
        local tries = 0;
        ::retry::;
        if currentWeather ~= lastWeather or tries > 3 then goto continue end;
        actWeather = GlobalState.actWeather;
        currentWeather, rain, wind = actWeather.type, actWeather.rain, actWeather.wind;
        tries += 1;
        Wait(1000);
        goto retry;
    end;
    ::continue::;
    lastWeather = currentWeather;
    xmas = (currentWeather == "XMAS");
    CreateThread(function()
        SetBlackout(false);
        ClearOverrideWeather();
        ClearWeatherTypePersist();
        SetWeatherTypePersist(lastWeather);
        SetWeatherTypeNow(lastWeather);
        SetWeatherTypeNowPersist(lastWeather);
        SetForceVehicleTrails(xmas);
        SetForcePedFootstepsTracks(xmas);
        SetRainLevel(rain);
        SetWindSpeed(wind[1]);
        SetWindDirection(wind[2]);
    end);
end;

local function setTime(change)
    timeChanged = change;
    crrentTime = GlobalState.actTime;
    if not (crrentTime.hour ~= lastTime.hour) then 
        local tries = 0;
        ::retry::;
        if crrentTime.hour ~= lastTime.hour or tries > 3 then goto continue end;
        crrentTime = GlobalState.actTime;
        tries += 1;
        Wait(1000);
        goto retry;
    end;
    ::continue::;
    -- crrentTime.hour = 12
    NetworkOverrideClockTime(crrentTime.hour, crrentTime.min, 0);
end;

RegisterNetEvent("weather:syncData", function (reset, set)
    Wait(500);

    if not weatherChanged or reset[1] then
        setWeather(set)
    end;

    if not timeChanged or reset[2] then
        setTime(set)
    end;
end);

CreateThread(function() SetMillisecondsPerGameMinute(60000) end);