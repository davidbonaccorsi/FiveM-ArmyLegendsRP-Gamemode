tvRP = {}
Tunnel.bindInterface("vRP",tvRP)

Proxy.addInterface("vRP",tvRP)
vRPserver = Tunnel.getInterface("vRP","vRP")

cfg = module("cfg/client")

tempPed = PlayerPedId()
tempPlayer = PlayerId()
pedPos = GetEntityCoords(tempPed)
playerVehicle = GetVehiclePedIsIn(tempPed)

exports('link', function()
  return tvRP
end)

local oldFadeIn = _G.DoScreenFadeIn
_G.DoScreenFadeIn = function(...)
  local time, controlsHud, hudComponents = table.unpack({...})
  oldFadeIn(time)

  if controlsHud then
    Citizen.Wait(time)
    TriggerEvent("vrp-hud:setComponentDisplay", hudComponents or {["*"] = true})
  end
end

local oldFadeOut = _G.DoScreenFadeOut
_G.DoScreenFadeOut = function(...)
  local time, controlsHud, hudComponents = table.unpack({...})

  oldFadeOut(time)
  if controlsHud then
    TriggerEvent("vrp-hud:setComponentDisplay", hudComponents or {["*"] = false})
  end
end

Citizen.CreateThread(function()
  while true do
    SetVehicleDensityMultiplierThisFrame(0.0)
    SetPedDensityMultiplierThisFrame(0.0) 
    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)
    SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    
    local x,y,z = pedPos.x, pedPos.y, pedPos.z
    ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
    RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
    Citizen.Wait(25)
  end
end)

Citizen.CreateThread(function()
  SetHudComponentPosition(3, 1.0, 1.0)
  SetHudComponentPosition(4, 1.0, 1.0)
  SetHudComponentPosition(6, 1.0, 1.0)
  SetHudComponentPosition(7, 1.0, 1.0)
  SetHudComponentPosition(8, 1.0, 1.0)
  SetHudComponentPosition(9, 1.0, 1.0)
  SetHudComponentPosition(13, 1.0, 1.0)

  SetWeaponDamageModifier(GetHashKey("WEAPON_UNARMED"), 0.5) 
  SetWeaponDamageModifier(GetHashKey("WEAPON_FLASHLIGHT"), 0.1)
  SetWeaponDamageModifier(GetHashKey("WEAPON_NIGHTSTICK"), 0.2)
end)

Citizen.CreateThread(function()
  SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
  SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
  SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
  SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
  SetMapZoomDataLevel(4, 24.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
  SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0) -- ZOOM_LEVEL_GOLF_COURSE
  SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0) -- ZOOM_LEVEL_INTERIOR
  SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0) -- ZOOM_LEVEL_GALLERY
  SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0) -- ZOOM_LEVEL_GALLERY_MAXIMIZE

  while true do
    tempPed = PlayerPedId()
    tempPlayer = PlayerId()
    pedPos = GetEntityCoords(tempPed)
    playerVehicle = GetVehiclePedIsIn(tempPed)
    if IsPedOnFoot(tempPed) then 
      SetRadarZoom(1100)
    elseif not (playerVehicle == 0) then
      SetRadarZoom(1100)
    end
    Wait(500)
  end
end)

Citizen.CreateThread(function()
  local paused = false
  while true do
    
    while IsPauseMenuActive() do
      if not paused then
        TriggerEvent("vrp-hud:setComponentDisplay", {
          ["serverHud"] = false,
          ["minimapHud"] = false,
          ["bottomRightHud"] = false,
          ["chat"] = false,
        })
        paused = true
      end

      Citizen.Wait(100)
    end

    if paused then
      TriggerEvent("vrp-hud:setComponentDisplay", {
        ["serverHud"] = true,
        ["minimapHud"] = true,
        ["bottomRightHud"] = true,
        ["chat"] = true,
      })
      paused = false
    end
  
    Citizen.Wait(500)
  end
end)

Citizen.CreateThread(function()
  for i = 1, 12 do
    EnableDispatchService(i, false)
  end


  DisableIdleCamera(true)
  SetPedCanPlayAmbientAnims(tempPed, false)


  while true do
    SetPlayerWantedLevel(tempPlayer, 0, false)
    SetPlayerWantedLevelNow(tempPlayer, false)
  
    RemoveAllPickupsOfType(0xDF711959) -- Rifle
    RemoveAllPickupsOfType(0xF9AFB48F) -- Pistol
    RemoveAllPickupsOfType(0xA9355DCD) -- Shotgun
    RemoveAllPickupsOfType(`PICKUP_ARMOUR_STANDARD`)
  
    SetPlayerWantedLevelNoDrop(tempPlayer, 0, false)
  
    SetPlayerHealthRechargeMultiplier(tempPlayer, 0.0)
    SetPedConfigFlag(tempPed, 184, true)
    Citizen.Wait(2000)
  end
end)

Citizen.CreateThread(function()
  while true do
    SetVehicleDensityMultiplierThisFrame(0.0)
    SetPedDensityMultiplierThisFrame(0.0) 
    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)
    SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    
    local x,y,z = pedPos.x, pedPos.y, pedPos.z
    ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
    RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
    Citizen.Wait(25)
  end
end)

Citizen.CreateThread(function()
  SetPedCanLosePropsOnDamage(tempPed, false, 0)
  SetCanAttackFriendly(tempPed, true, false)
  SetPoliceIgnorePlayer(tempPlayer, true)
	SetDispatchCopsForPlayer(tempPlayer, false)
  NetworkSetFriendlyFireOption(true)
  SetPlayerCanDoDriveBy(tempPlayer, false)
  Citizen.Wait(15000)
  local injuredWalking, injuredRunning = false, false
  RegisterNetEvent("vRP:bypassRunning", function()
    injuredRunning = true
    Citizen.SetTimeout(45000, function()
      injuredRunning = false
    end)
  end)

  if not HasAnimSetLoaded("move_m@injured") then
      RequestAnimSet("move_m@injured")
  end

  -- while true do
  --     if not DoesEntityExist(tempPed) then
  --         tempPed = PlayerPedId()
  --         SetPedCanLosePropsOnDamage(tempPed, false, 0)
  --         SetCanAttackFriendly(tempPed, true, false)
  --     end
  --     local playerHealth = GetEntityHealth(tempPed)
  --     local playerArmor = GetPedArmour(tempPed)

  --     if not playerArmor or playerArmor < 50 then
  --         SetPedConfigFlag(tempPed, 438, true)
  --     else
  --         SetPedConfigFlag(tempPed, 438, false)
  --     end
  --     SetPedConfigFlag(tempPed, 184, true)

  --     if playerHealth <= 130 then
  --         SetPedMovementClipset(tempPed, "move_m@injured", 0.2)
  --         if not injuredWalking then
  --             injuredWalking = true
  --             Citizen.CreateThread(function()
  --               while injuredWalking do
  --                 DisableControlAction(0, 21, true)
  --                 DisableControlAction(0, 22, true)
                  
  --                 if injuredRunning then
  --                   Citizen.Wait(1000)
  --                 end
  --                 Citizen.Wait(1)
  --               end
  --             end)
  --         end
  --     elseif injuredWalking then
  --         injuredWalking = false
  --         ResetPedMovementClipset(tempPed)
  --     end

  --     Citizen.Wait(2000)
  -- end
end)

function tvRP.teleport(x,y,z)
  -- if IsPedInAnyVehicle(tempPed,false) then
  --   SetEntityCoords(GetVehiclePedIsIn(tempPed, false), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  --   SetEntityCoords(tempPed, x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  -- else
  --   SetEntityCoords(tempPed, x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  -- end

  if IsPedInAnyVehicle(tempPed,false) then
    SetPedCoordsKeepVehicle(tempPed, x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  else
    SetEntityCoords(tempPed, x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  end
end

function tvRP.getPosition()
  local x,y,z = table.unpack(GetEntityCoords(tempPed))
  return x,y,z
end

function tvRP.getOffsetPosition(ox, oy, oz)
  return GetOffsetFromEntityInWorldCoords(tempPed, ox, oy, oz)
end

function tvRP.getDst(coords)
  return #(coords - pedPos)
end

function tvRP.getPositionWithArea()
  local x,y,z = table.unpack(GetEntityCoords(tempPed))

  local theZone, _ = GetStreetNameAtCoord(x, y, z)
  local theStreet = GetStreetNameFromHashKey(theZone)

  return {coords = {x,y,z}, zone = theStreet}
end

function tvRP.isInside()
  local x,y,z = tvRP.getPosition()
  return not (GetInteriorAtCoords(x,y,z) == 0)
end

function tvRP.getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(tempPed))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function tvRP.isFalling()
  return IsPedFalling(tempPed) or IsPedInParachuteFreeFall(tempPed)
end

function tvRP.formatMoney(amount)
  local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function tvRP.getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(tempPed)
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

tvRP.user_cdata = {}
function tvRP.setCData(dkey, dvalue)
  tvRP.user_cdata[dkey] = dvalue
end

function tvRP.setCDataVar(dkey, vkey, vvalue)
  local dvalue = tvRP.getCData(dkey)

  if dvalue then
    dvalue[vkey] = vvalue
  else
    tvRP.setCData(dkey, {[vkey] = vvalue})
  end
end

function tvRP.getCData(dkey)
  return tvRP.user_cdata[dkey]
end

function tvRP.getCDataVar(dkey, vkey)
  local dvalue = tvRP.getCData(dkey) or {}

  if dvalue then
    return dvalue[dkey][vkey]
  end
end

function tvRP.getPlayersInCoords(x, y, z, radius)
  local r = {}

  for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      local px,py,pz = table.unpack(GetEntityCoords(ped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
  end

  return r
end

function tvRP.getNearestPlayers(radius)
  local r = {}

  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

  for _, player in ipairs(GetActivePlayers()) do
    if player ~= pid then
      local ped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(ped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

function tvRP.getNearestPlayer(radius)
  local p = nil

  local plys = tvRP.getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(plys) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end



local function ButtonMessage(text)
  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform(text)
  EndTextCommandScaleformString()
end

local function Button(ControlButton)
  N_0xe83a3e3557a56640(ControlButton)
end

local function setupSelectScaleform(scaleform)
  local scaleform = RequestScaleformMovie(scaleform)
  while not HasScaleformMovieLoaded(scaleform) do
      Citizen.Wait(1)
  end

  DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

  PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
  PopScaleformMovieFunctionVoid()
  
  PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
  PushScaleformMovieFunctionParameterInt(200)
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(0)
  Button(GetControlInstructionalButton(0, 177, true))
  ButtonMessage("Cancel")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(1)
  Button(GetControlInstructionalButton(0, 191, true))
  ButtonMessage("Alege")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(2)
  Button(GetControlInstructionalButton(0, 174, true))
  ButtonMessage("Selecteaza Inainte")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(3)
  Button(GetControlInstructionalButton(0, 175, true))
  ButtonMessage("Selecteaza Urmatorul")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(80)
  PopScaleformMovieFunctionVoid()

  return scaleform
end


function tvRP.selectNearestPlayer(radius, selfSelect, skipPlayers)

    local pid = PlayerId()
    local nearPlayers, selected = {}, 0

    local pPos = GetEntityCoords(GetPlayerPed(-1))

    local skipIndex = {}
    if skipPlayers then
      for i in pairs(skipPlayers) do
        skipIndex[skipPlayers[i]] = true
      end
    end


    local activePlayers = GetActivePlayers()
    for _, player in ipairs(activePlayers) do
      if selfSelect or player ~= pid then
        if not skipIndex[player] then
          local ped = GetPlayerPed(player)
          local distance = #(pPos - GetEntityCoords(ped))
          if distance <= radius then
            selected = 1
            table.insert(nearPlayers, {id = GetPlayerServerId(player), ped = ped, player = player})
          end
        end
      end
    end

    if selected > 0 then
      local form = setupSelectScaleform("instructional_buttons")
      TriggerEvent("vrp-hud:notify", "Jucatorul cu un marker galben deasupra capului este cel selectat")
      local timeout = GetGameTimer() + 60000
      while timeout > GetGameTimer() do
        
        DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
        
        if not DoesEntityExist(nearPlayers[selected].ped) or not NetworkIsPlayerActive(nearPlayers[selected].player) then
          nearPlayers[selected] = nil
          for i = selected, #nearPlayers do
            nearPlayers[i] = nearPlayers[i+1]
          end
          table.remove(nearPlayers, #nearPlayers)
          if #nearPlayers == 0 then
            break
          end
        end
        
        
        local pos = GetEntityCoords(nearPlayers[selected].ped)
        DrawMarker(0,pos.x,pos.y,pos.z+1.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.15,0.15,0.15,255,255,0,255,true,true,2,false,false,false,false)

        if IsControlJustPressed(0, 174) then
          selected = selected + 1
          if selected > #nearPlayers then
            selected = 1
          end
        end

        if IsControlJustPressed(0, 175) then
          selected = selected - 1
          if selected < 1 then
            selected = #nearPlayers
          end
        end

        DisableControlAction(0, 177, false)
        if IsDisabledControlJustPressed(0, 177) then
          return false
        end

        if IsControlJustPressed(0, 191) then
          if nearPlayers[selected] then
            return nearPlayers[selected].id
          end
        end

        Citizen.Wait(1)
      end
    end

    TriggerEvent("vrp-hud:notify", "Nimeni nu este langa tine", "error")
    return false
end



local subtitle_ended = true
function tvRP.subtitle(msg, secconds)
  while not subtitle_ended do Citizen.Wait(100) end
  subtitle_ended = false
  Citizen.CreateThread(function()
  	while not subtitle_ended do
  		Citizen.Wait(1)
  		SetTextFont(6)
  		SetTextProportional(0)
  		SetTextScale(0.6, 0.6)
  		SetTextColour(255, 255, 255, 255)
  		SetTextDropShadow(0, 0, 0, 0, 255)
  		SetTextEdge(1, 0, 0, 0, 255)
  		SetTextDropShadow()
  		SetTextOutline()
  		SetTextCentre(1)
  		SetTextEntry("STRING")
  		AddTextComponentString(msg)
  		DrawText(0.5, 0.8)
  	end
  end)
  if not secconds then secconds = 3 end
  Citizen.Wait(secconds * 1000)
  subtitle_ended = true
end

function tvRP.registerKeybind(...)
  RegisterKeyMapping(...)
end

function tvRP.playScreenEffect(name, duration)
  if duration < 0 then -- loop
    StartScreenEffect(name, 0, true)
  else
    StartScreenEffect(name, 0, true)

    Citizen.CreateThread(function()
      Citizen.Wait(math.floor((duration+1)*1000))
      StopScreenEffect(name)
    end)
  end
end

function tvRP.stopScreenEffect(name)
  StopScreenEffect(name)
end

local anims = {}
local anim_ids = Tools.newIDGenerator()
local inAnim = false

function loadAnimDict(dict)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(1)
  end

  return true
end

function tvRP.playAnim(upper, seq, looping)
  Citizen.CreateThread(function()
      Citizen.Wait(250)
      Citizen.CreateThread(function()
        while inAnim do
          DisableControlAction(0, 37, false)
          Citizen.Wait(1)
        end
      end)
      Citizen.Wait(15000)
      inAnim = false
  end)
  if seq.task ~= nil then -- is a task (cf https://github.com/ImagicTheCat/vRP/pull/118)
    tvRP.stopAnim(true)

    inAnim = true
    

    local ped = tempPed
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local x,y,z = tvRP.getPosition()
      TaskStartScenarioAtPosition(ped, seq.task, x, y, z-1, GetEntityHeading(ped), 0, 0, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    tvRP.stopAnim(upper)

    inAnim = true

    local flags = 0
    if upper then flags = flags+48 end
    if looping then flags = flags+1 end

    Citizen.CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = anim_ids:gen()
      anims[id] = true

      for k,v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i=1,loops do
          if anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local i = 0
            while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
              Citizen.Wait(10)
              RequestAnimDict(dict)
              i = i+1
            end

            -- play anim
            if HasAnimDictLoaded(dict) and anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end

              TaskPlayAnim(tempPed,dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
            end

            Citizen.Wait(0)
            while GetEntityAnimCurrentTime(tempPed,dict,name) <= 0.95 and IsEntityPlayingAnim(tempPed,dict,name,3) and anims[id] do
              Citizen.Wait(0)
            end
          end
        end
      end

      -- free id
      anim_ids:free(id)
      anims[id] = nil
    end)
  end
end

local canStopAnim = true
function tvRP.setCanStop(set)
  canStopAnim = set
end

exports("canStopAnim", function()
  return canStopAnim
end)

function tvRP.isInAnim()
  return inAnim
end

function tvRP.stopAnim(upper)
  anims = {} -- stop all sequences
  if not importantAnim then
    inAnim = false
    if upper then
      ClearPedSecondaryTask(tempPed)
    else
      ClearPedTasks(tempPed)
    end
  else
    tvRP.notify("Nu poti oprii aceasta animatie.", "error")
  end
end

local ragdoll = false

function tvRP.setRagdoll(flag)
  ragdoll = flag
  Citizen.CreateThread(function()
      while ragdoll do
        SetPedToRagdoll(tempPed, 1000, 1000, 0, 0, 0, 0)
        Citizen.Wait(50)
      end
  end)
end

function tvRP.isRagdoll()
  return ragdoll
end

-- SOUND
-- some lists: 
-- pastebin.com/A8Ny8AHZ
-- https://wiki.gtanet.work/index.php?title=FrontEndSoundlist

-- play sound at a specific position
function tvRP.playSpatializedSound(dict,name,x,y,z,range)
  PlaySoundFromCoord(-1,name,x+0.0001,y+0.0001,z+0.0001,dict,0,range+0.0001,0)
end

function tvRP.playSound(dict,name)
  PlaySound(-1,name,dict,0,0,1)
end

RegisterCommand("playsound", function(src, args)
  PlaySoundFrontend(-1, args[1], args[2])
  print("Play sound:", table.unpack(args))
end)

function tvRP.deleteEntity(entity)
  if DoesEntityExist(entity) then
    DeleteObject(entity)
  end
end

function tvRP.deleteVehicle(veh)
  if DoesEntityExist(veh) then
    DeleteEntity(veh)

    if IsEntityAMissionEntity(veh) then
      DeleteVehicle(veh)
    end
  end
end

function tvRP.getVehicleInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end

function tvRP.getVehicleInFront()
    local pos = pedPos
    local entityWorld = GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 5.0, 0.0)
    
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, tempPed, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)

    return result
end

RegisterNetEvent("vehicle:fix", function()
  local playerPed = PlayerPedId()
  if IsPedInAnyVehicle(playerPed) then
    local vehicle = GetVehiclePedIsIn(playerPed)
    SetVehicleEngineHealth(vehicle, 9999)
    SetVehiclePetrolTankHealth(vehicle, 9999)
    SetVehicleFixed(vehicle)
    SetVehicleEngineOn(vehicle, true, true)
  end
end)

RegisterNetEvent("vehicle:flip", function()
  local vehicle = tvRP.getNearestVehicle(3.5)
  if vehicle then
    SetVehicleOnGroundProperly(vehicle)
  end
end)

function tvRP.executeCommand(...)
  ExecuteCommand(...)
end

RegisterNUICallback("vrp:executeCommand", function(data, cb)
  tvRP.executeCommand(table.unpack(data))
  cb("ok")
end)

function tvRP.doesModelExist(model)
  return IsModelInCdimage(model)
end

function tvRP.spawnCar(model, coords, heading, keepOutPed)
    local i = 0
    local mhash = GetHashKey(model)
    while not HasModelLoaded(mhash) and i < 1000 do
      RequestModel(mhash)
      Citizen.Wait(30)
      i = i + 1
    end

    if HasModelLoaded(mhash) then
      local nveh = CreateVehicle(mhash, (coords or pedPos), (heading and (heading + 0.0) or GetEntityHeading(tempPed)), true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      
      if not keepOutPed then
        SetPedIntoVehicle(tempPed,nveh,-1)
      end

      Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true)
      SetVehicleHasBeenOwnedByPlayer(nveh,true)
      SetModelAsNoLongerNeeded(mhash)
      return nveh
  end
end

function tvRP.repairVehicle()
  local playerPed = tempPed
  if (playerVehicle == 0) then
    local vehicle = playerVehicle
    SetVehicleEngineHealth(vehicle, 9999)
    SetVehiclePetrolTankHealth(vehicle, 9999)
    SetVehicleFixed(vehicle)
    return true
  else
    return false
  end
end

RegisterNetEvent("vRP:triggerServerEvent")
AddEventHandler("vRP:triggerServerEvent", function(event, ...)
	TriggerServerEvent(event, ...)
end)

RegisterNUICallback("vrp:triggerServerEvent", function(data, cb)
  TriggerServerEvent(table.unpack(data))
  cb("ok")
end)

RegisterNUICallback("vrp:triggerEvent", function(data, cb)
  TriggerEvent(table.unpack(data))
  cb("ok")
end)

function tvRP.notify(msg,type,title,time)
  SendNUIMessage({interface = "addNotify", type = type, time = time, title = title, text = msg})
end

RegisterNetEvent("notifyEvent", function(msg,type,title,time)
  SendNUIMessage({interface = "addNotify", type = type, time = time, title = title, text = msg})
end)

function tvRP.hint(msg,title,icon)
  if not icon then
    icon = "fa-solid fa-lightbulb-exclamation"
  end
  SendNUIMessage({interface = "hintNotify", title = title, text = msg, icon = icon})
end

function tvRP.msg(...)
  TriggerEvent("chatMessage", ...)
end

function tvRP.sendInfo(theInfo)
	tvRP.msg("^5Info^7: "..theInfo)
end

function tvRP.sendError(theError)
	tvRP.msg("^1Eroare^7: "..theError)
end

function tvRP.sendSyntax(theCmd)
	tvRP.msg("^5Syntaxa^7: "..theCmd)
end

function tvRP.sendOffline()
  tvRP.sendError('Playerul nu este conectat pe server.')
end

function tvRP.noAccess()
	tvRP.sendError("Nu ai acces la aceasta comanda.")
end


exports("sendSyntax", tvRP.sendSyntax)
exports("sendError", tvRP.sendError)
exports("noAccess", tvRP.noAccess)
exports("sendOffline", tvRP.sendOffline)


function EnumerateEntitiesWithinDistance(gameData, coords, radius, affectPlayers)
    local nEnts = {}

    if not coords then
        coords = pedPos
    end

    for _objectId, theEntity in pairs(gameData) do
        local inRadius = #(coords - GetEntityCoords(theEntity)) <= radius

        if inRadius then
          table.insert(nEnts, affectPlayers and _objectId or theEntity)
        end
    end

    return nEnts
end

-- handle framework events

RegisterNetEvent("sound:play", function(sound, volume)
  SendNUIMessage{
    act = "sound_manager",
    call = "play",
    sound = sound,
    volume = volume,
  }
end)

RegisterNetEvent("vRP:stopAudio", function()
  SendNUIMessage{
    act = "sound_manager",
    call = "stop",
  }
end)

RegisterNetEvent("vrp-hud:notify", tvRP.notify)

if tvRP.hint then
  RegisterNetEvent("vrp-hud:hint", tvRP.hint)
end

TriggerServerEvent('vRP:loadPlayer')
RegisterNetEvent('vRP:checkIDRegister')
AddEventHandler('vRP:checkIDRegister', function()
  TriggerEvent('playerSpawned', GetEntityCoords(PlayerPedId()))
end)

AddEventHandler("playerSpawned", function()
  TriggerServerEvent("vRPcli:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

RegisterCommand("usecursor", function()
  TriggerEvent("vrp:interfaceFocus", true)
  SetCursorLocation(0.5, 0.5)

  Citizen.Wait(500)
  SendNUIMessage({
    act = "useCursor",
  })
end)

RegisterNUICallback("vacnuiblocker", function(data, cb)
  TriggerServerEvent('vrp-anticheat:kickPlayer', 'Dev Tools')
  cb('muie dev tools')
end)

RegisterKeyMapping("usecursor", "Foloseste cursorul", "keyboard", "GRAVE")
