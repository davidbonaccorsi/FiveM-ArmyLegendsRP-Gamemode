local handcuffed = false
local cuffsVariation = nil
local cuffsHash = GetHashKey("p_cs_cuffs_02_s")

function tvRP.togHandcuffs()
  if IsPedInAnyVehicle(tempPed) then
      if handcuffed then
          handcuffed = false
          SetEnableHandcuffs(tempPed, handcuffed)
          tvRP.stopAnim(true)
          Citizen.Wait(500)
          SetPedStealthMovement(tempPed,false,"")
          tvRP.setCanStop(true)
          return
      end
  else
      RequestAnimDict("mp_arresting")
      while not HasAnimDictLoaded("mp_arresting") do
          Citizen.Wait(10)
      end

      handcuffed = not handcuffed
      SetEnableHandcuffs(tempPed, handcuffed)
      if handcuffed then
          tvRP.setCanStop(false)
          SetCurrentPedWeapon(tempPed, -1569615261, true)
          TaskPlayAnim(tempPed, "mp_arresting", "idle", 30.0, 1.0, -1, 49, 0,0,0,0)

           Citizen.CreateThread(function()
              RequestModel(cuffsHash)
              while not HasModelLoaded(cuffsHash) do
                  Citizen.Wait(10)
              end

              local cuffsObj = CreateObject(cuffsHash, GetEntityCoords(tempPed), true, true)
              AttachEntityToEntity(cuffsObj, tempPed, GetPedBoneIndex(tempPed, 0xDEAD), 0.01, 0.075, 0.0, 10.0, 45.0, 80.0, true, true, false, true, 1, true)
              while handcuffed do
                  Citizen.Wait(1)
                  tempPed = PlayerPedId()
                  SetPedStealthMovement(tempPed, true, "")

                  if not IsEntityPlayingAnim(tempPed, "mp_arresting", "idle", 3) then
                      TaskPlayAnim(tempPed, "mp_arresting", "idle", 30.0, 1.0, -1, 49, 0, 0, 0, 0)
                  end

                  DisableControlAction(0,21,true) -- disable sprint
                  DisableControlAction(0,22,true) -- disable space
                  DisableControlAction(0,24,true) -- disable attack
                  DisableControlAction(0,25,true) -- disable aim
                  DisableControlAction(0,44,true) -- disable cover
                  DisableControlAction(0,47,true) -- disable weapon
                  DisableControlAction(0,58,true) -- disable weapon
                  DisableControlAction(0,263,true) -- disable melee
                  DisableControlAction(0,264,true) -- disable melee
                  DisableControlAction(0,257,true) -- disable melee
                  DisableControlAction(0,140,true) -- disable melee
                  DisableControlAction(0,141,true) -- disable melee
                  DisableControlAction(0,142,true) -- disable melee
                  DisableControlAction(0,143,true) -- disable melee
                  DisableControlAction(0,73,true) -- disable X
                  DisableControlAction(0,75,true) -- disable exit vehicle
                  DisableControlAction(0,75,true) -- disable exit vehicle
                  DisableControlAction(27,75,true) -- disable exit vehicle
                  DisableControlAction(0,170,true) -- F3
              end
              if DoesEntityExist(cuffsObj) then
                  DeleteEntity(cuffsObj)
              end
              ClearPedTasks(tempPed)
          end)
      else
          tvRP.setCanStop(true)
          tvRP.stopAnim(true)
          Citizen.Wait(500)
          SetPedStealthMovement(tempPed,false,"")
          ForcePedMotionState(tempPed, 247561816)
      end
  end
end

function tvRP.setHandcuff(flag)
  if handcuffed ~= flag then
    tvRP.togHandcuffs()
  end
end

function tvRP.isHandcuffed(rope)
  if rope and not handcuffed then
    return exports.vrp:isTiedWithRope()
  end

  return handcuffed
end

-- (experimental, based on experimental getNearestVehicle)
function tvRP.putInNearestVehicleAsPassenger(radius)
  local veh = tvRP.getNearestVehicle(radius)

  if IsEntityAVehicle(veh) then
    for i=1,math.max(GetVehicleMaxNumberOfPassengers(veh),3) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
  
  return false
end

function tvRP.putInNetVehicleAsPassenger(net_veh)
  local veh = NetworkGetEntityFromNetworkId(net_veh)
  if IsEntityAVehicle(veh) then
    for i=1,GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
end

function tvRP.putInVehiclePositionAsPassenger(x,y,z)
  local veh = tvRP.getVehicleAtPosition(x,y,z)
  if IsEntityAVehicle(veh) then
    for i=1,GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
end

RegisterNetEvent('police:animBeingArrest')
AddEventHandler('police:animBeingArrest', function(target)
	local playerPed = tempPed
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Citizen.Wait(10)
	end
	AttachEntityToEntity(tempPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	Citizen.Wait(950)
	DetachEntity(tempPed, true, false)
end) 

RegisterNetEvent('police:animUncuffed')
AddEventHandler('police:animUncuffed', function(target)
  local playerPed = tempPed
  local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

  AttachEntityToEntity(tempPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
  Citizen.Wait(950)
  DetachEntity(tempPed, true, false)
end)

RegisterNetEvent('police:animArresting')
AddEventHandler('police:animArresting', function()
	local playerPed = tempPed
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Citizen.Wait(10)
	end
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	Citizen.Wait(3000)
end)

function tvRP.isInJail()
  return tvRP.getJailTime() > 0
end


-- police props --
-- putin cam trash code dar o sa l refac alta data, daca il refaceti voi sa mi-l dati si mie :3

local function rotToDir(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGameplayCamera(distance)
  local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = rotToDir(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestSweptSphere(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 0.2, 339, PlayerPedId(), 4))
	return b, c, e -- credits: annalouu
end

local policeObj = {}
local spawningObjects = false
function tvRP.spawnAnyPoliceProp(props, bypass)
  if spawningObjects and not spawningObjects then
    TriggerEvent("vrp-hud:notify", "Spawnezi deja obiecte.", "error")
    return
  end

  spawningObjects = true

  TriggerEvent("vrp-hud:updateMap", false)
  TriggerEvent("vrp-hud:setComponentDisplay", {
    serverHud = false,
    minimapHud = false,
    chat = false,
  })
  TriggerEvent("vrp-hud:showBind", {key = "L ALT", text = "Mod stergere"})
  TriggerEvent("vrp-hud:showBind", {key = "Q", text = "Schimba modelul"})
  TriggerEvent("vrp-hud:showBind", {key = "⬅", text = "Creste rotatia"})
  TriggerEvent("vrp-hud:showBind", {key = "➡", text = "Scade rotatia"})
  TriggerEvent("vrp-hud:showBind", {key = "ENTER", text = "Spawneaza obiect"})
  TriggerEvent("vrp-hud:showBind", {key = "BACKSPACE", text = "Opreste spawnarea"})

  local deletingProps = false

  Citizen.CreateThread(function()

    local objNum, objHash = 1, false
    local tempPos = GetEntityCoords(PlayerPedId()) + vector3(1.0, 1.0, 1.0)

    local obj, heading = false, 0.0

    local function spawnPreviewObject()
      objHash = GetHashKey(props[objNum])

      RequestModel(objHash)
      while not HasModelLoaded(objHash) do
        Citizen.Wait(100)
      end
      
      if DoesEntityExist(obj) then
        DeleteEntity(obj)
      end

      obj = CreateObject(objHash, tempPos, true, true, false)
      SetEntityHeading(obj, heading)
      SetEntityAlpha(obj, 150)
      SetEntityCollision(obj, false, false)
      FreezeEntityPosition(obj, true)
      PlaceObjectOnGroundProperly(obj)
    end
    spawnPreviewObject()

    while true do
        
        local hit, coords, entity = RayCastGameplayCamera(15.0)
        tempPos = coords
    
        if not DoesEntityExist(obj) then
          spawnPreviewObject()
        end

        if hit then
          SetEntityCoords(obj, coords.x, coords.y, coords.z)
        end

        
        DrawMarker(28, coords + vec3(0.0, 0.0, 1.0), 0, 0, 0, 0, 0, 0, 0.040, 0.040, 0.040, 246, 255, 139, 255)

        if IsControlPressed(0, 174) then
          heading = heading + 1
          if heading > 360 then
            heading = 0.0
          end
        end

        if IsControlPressed(0, 175) then
          heading = heading - 1
          if heading < 0 then
            heading = 360.0
          end
        end

        SetEntityHeading(obj, heading)

        if IsControlJustReleased(0, 44) then
          objNum = objNum + 1
          if objNum > #props then
            objNum = 1
          end

          spawnPreviewObject()
          Citizen.Wait(10)
        end

        if IsControlJustReleased(0, 215) and (playerVehicle == 0) then
          TriggerServerEvent("police:trySpawnProp", {pos = coords, h = heading, model = props[objNum]})
        end

        if IsControlJustReleased(0, 19) then
          deletingProps = true
          break
        end

        if IsControlJustReleased(0, 177) then break end

        Citizen.Wait(1)
    end

    TriggerEvent("vrp-hud:showBind", false)
    if DoesEntityExist(obj) then
      DeleteEntity(obj)
    end
    if not deletingProps then

      TriggerEvent("vrp-hud:updateMap", true)
      TriggerEvent("vrp-hud:setComponentDisplay", {
        serverHud = true,
        minimapHud = true,
        chat = true,
      })

      spawningObjects = false

    else
      Citizen.Wait(150)
      tvRP.deletePoliceProps(props)
    end

    -- DeleteEntity(obj)
  end)
end


function tvRP.deletePoliceProps(propsList)
  TriggerEvent("vrp-hud:showBind", {key = "ENTER", text = "Sterge obiectul"})
  TriggerEvent("vrp-hud:showBind", {key = "L ALT", text = "Iesi din modul stergere"})

  while true do

    for k, v in pairs(policeObj) do
      local entity = GetClosestObjectOfType(pedPos, 1.5, GetHashKey(v.model))
      
      if entity ~= 0 then

        while DoesEntityExist(entity) and #(v.pos - pedPos) <= 1.5 do
          SetEntityAlpha(entity, 100)
          DrawMarker(21, GetEntityCoords(entity) + vec3(0.0, 0.0, 1.0), 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 246, 255, 139, 200, true, true)

          if IsControlJustReleased(0, 215) then
            TriggerServerEvent("police:tryDespawnProp", v.id)
            break
          end
        
          Citizen.Wait(1)
        end
        SetEntityAlpha(entity, 255)

      end
    end

    if IsControlJustReleased(0, 19) then break end -- L ALT

    Citizen.Wait(1)
  end

  TriggerEvent("vrp-hud:showBind", false)

  Citizen.Wait(150)
  tvRP.spawnAnyPoliceProp(propsList, true)
end

RegisterNetEvent("police:populateProps", function(props)
  for k, prop in pairs(props) do
     table.insert(policeObj, prop)
     local objHash = GetHashKey(prop.model)

     RequestModel(objHash)
     while not HasModelLoaded(objHash) do
       Citizen.Wait(100)
     end

     prop.obj = CreateObject(objHash, prop.pos, false, false, false)
     SetEntityHeading(prop.obj, prop.h)
     FreezeEntityPosition(prop.obj, true)
     SetEntityInvincible(prop.obj, true)
  end
end)

RegisterNetEvent("police:deleteExistentProp", function(propid)
  for k,v in pairs(policeObj) do
    if v.id == propid then
      DeleteEntity(v.obj)
      table.remove(policeObj, k)
      break
    end
  end
end)

-- calls

local bindsOn = false
RegisterNetEvent("ems:showCallsMenu", function(data)
  local calls = {}
  for user_id, data in pairs(data.calls) do
      data.distance = math.floor(#(data.position - pedPos))
      table.insert(calls, data)
  end
  data.calls = calls
  if #data.calls > 0 then

    SendNUIMessage(data)

    if not bindsOn then
      bindsOn = true
      TriggerEvent("vrp-hud:showBind", {key = "ENTER", text = "Preia un apel"})
      TriggerEvent("vrp-hud:showBind", {key = "⬆", text = "Apelant anterior"})
      TriggerEvent("vrp-hud:showBind", {key = "⬇", text = "Apelant urmator"})
      TriggerEvent("vrp-hud:showBind", {key = "BACKSPACE", text = "Inchide meniul"})
    end
  else
    TriggerEvent("vrp-hud:notify", "Nici un apel nu asteapta un raspuns.", "error")
  end
end)

RegisterNUICallback("ems:hideBinds", function(data, cb)
  TriggerEvent("vrp-hud:showBind", false)
  bindsOn = false
  cb("ok")
end)

RegisterNetEvent("ems:startCall", function(target_src, position, blipid, blipcolor)
  local target_ped = GetPlayerPed(target_src)
  local blip = AddBlipForCoord(position)
  
  SetBlipSprite(blip, blipid)
  SetBlipColour(blip, blipcolor)
  SetBlipRoute(blip, true)
  SetBlipRouteColour(blip, blipcolor)
  
  SetBlipScale(blip, 0.6)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Alerta departament")
  EndTextCommandSetBlipName(blip)

  while #(position - pedPos) > 20 do
      Citizen.Wait(100)
  end
  RemoveBlip(blip)

end)


-- backup codes

local isCop = false
RegisterNetEvent("vrp:playerJoinFaction", function(group)
  isCop = (group == "Politie")
end)

exports("isCop", function()
  return isCop
end)

RegisterNetEvent("police:sendBackup", function(tbl)
  tbl.interface = "policeBk"

  if tbl.position then
    local x,y,z = table.unpack(tbl.position)

    local blip = AddBlipForCoord(x, y, z)
    SetBlipAsShortRange(blip, true)
    SetBlipSprite(blip, 42)
    if tbl.code == "10-11" then
      SetBlipSprite(blip, 567)
    end
    SetBlipScale(blip, 0.6)
    SetBlipAlpha(blip, 150)
    if tbl.code == "10-11" then
      SetBlipAlpha(blip, 200)
    end

    BeginTextCommandSetBlipName("STRING")
    if tbl.code == "10-11" then
      AddTextComponentString("Focuri de arma")
    else
      AddTextComponentString("Cerere intariri")
    end
    EndTextCommandSetBlipName(blip)

    Citizen.CreateThread(function()
      Citizen.Wait(15000)
      if tbl.code == "10-11" then
        Citizen.Wait(10000)
      end
      RemoveBlip(blip)
    end)

    SetNewWaypoint(x, y)

    local var1, var2 = GetStreetNameAtCoord(x, y, z)
    local street = GetStreetNameFromHashKey(var1)
    local district = GetStreetNameFromHashKey(var2)

    if street:len() < 2 then
        street = district
    end

    tbl.location = street..", "..district
  end

  if not tbl.stopsound then
    if tbl.code == "BK 0" then
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    else
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 1)
    end
  end

  SendNUIMessage(tbl)
end)

local huntArea <const> = vector3(-1464.5980224609, 4573.728515625, 42.793586730957)

AddEventHandler("CEventGunShot", function(someData, entity, extraData)
  if (entity == tempPed) and not isCop then
    local pedCoords = GetEntityCoords(tempPed)

    if #(pedCoords - huntArea) <= 250 then return end
    
    local max, preferred = 3, 2

    if IsPedCurrentWeaponSilenced(tempPed) then
      max, preferred = 4, 4
    end

    local result = math.random(1, max)
    if result == preferred then -- and not exports["vrp_turfs"]:isInWar()
      TriggerServerEvent('police:reportShoot')
      local chanceWanted = math.random(0,100)
      if chanceWanted == 1 then
        TriggerEvent("vrp-wanted:addWanted", 1, "Focuri de Arma")
      end
    end
  end
end)

-- mdt

--[[RegisterNUICallback("mdt:findPlate", function(data, cb)
  vRPserver.mdtSearchPlate({data[1]}, function(found, name)
    cb({found, name})
  end)
end)

RegisterNUICallback("mdt:matchCitizen", function(data, cb)
  vRPserver.mdtGetMatchingCitizens({data[1]}, function(found)
    cb(found)
  end)
end)

RegisterNUICallback("mdt:findCitizen", function(data, cb)
  vRPserver.mdtSearchCitizen({data[1]}, function(found)
    cb(found)
  end)
end)

RegisterNUICallback("mdt:findWarrants", function(data, cb)
  vRPserver.mdtSearchWarrants({data[1]}, function(found)
    if not next(found) then
      found = false
    end
    
    cb(found)
  end)
end)]]

-- --

-- radio codes --

local group = false
RegisterNetEvent("vrp:playerJoinFaction", function(faction)
  group = faction
end)

RegisterCommand("codes", function()
  if (group == "Smurd") or (group == "Politie") then
    exports["vrp"]:runjs([[
      if (serverHud.radio_codes) {
        serverHud.radio_codes = false;
      } else {
        serverHud.radio_codes = "]]..group..[[";
      }
    ]])
  end
end)

RegisterKeyMapping("codes", "Coduri Smurd/Politie", "keyboard", "F7")



local copPos = vector3(442.49398803711,-986.44720458984,30.72430229187)
Citizen.CreateThread(function()
  exports['vrp']:spawnNpc("policeMenu", {
      position = copPos,
      rotation = 360,
      model = "s_m_y_cop_01",
      freeze = true,
      minDist = 2.5,
      name = "Traian Berbeceanu",
      buttons = {
          {text = "Vreau sa imi platesc cazierele", response = function()
              local reply = promise.new()

              triggerCallback("searchCazier", function(warrants)
                  local total = #warrants
                  if not (0 < total) then
                    reply:resolve('Nu ai caziere. Te pot ajuta cu altceva?')
                  else
                    reply:resolve{false, true}
                    Wait(1024)
                    
                    SendNUIMessage({
                      interface = "policeWarrants",
                      data = {total = total, warrants = warrants}
                    })
                  end
              end, LocalPlayer.state.user_id, true)

              return Citizen.Await(reply)
          end},
          {text = 'Vreau sa imi platesc amenzile', response = function()
              local reply = promise.new()
              triggerCallback('payFines', function(res)
                  reply:resolve(res)
              end)
              return Citizen.Await(reply)
          end},
          {text = 'Vreau sa imi iau certificatul de port arma', response = function()
            local reply = promise.new()
            triggerCallback('getPermisArma', function(res)
              reply:resolve(res)
            end)
            -- if vRP.hasPermission(LocalPlayer.state.user_id, "permis.arma") then
            --   vRP.giveInventoryItem(LocalPlayer.state.user_id, "permisarma", 1, true)
            --   reply:resolve{false, true}
            -- else
            --   reply:resolve("Nu ai permisul de port arma.")
            -- end
            return Citizen.Await(reply)
          end},
      }
  })
end)