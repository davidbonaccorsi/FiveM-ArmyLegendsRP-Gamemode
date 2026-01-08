

local function deleteAll(firstFunction, nextFunction, endFunction, deleteFunction)
  local handle, object = firstFunction()
  local finished = false
  repeat
    NetworkRequestControlOfEntity(object)

    local timeout = 20
    while timeout > 0 and not NetworkHasControlOfEntity(object) do
        Wait(100)
        timeout = timeout - 1
    end

    SetEntityAsMissionEntity(object, true, true)

    timeout = 20
    while timeout > 0 and not IsEntityAMissionEntity(object) do
        Wait(100)
        timeout = timeout - 1
    end


    if DoesEntityExist(object) then 
      if firstFunction ~= FindFirstVehicle then
        deleteFunction(object)
    else
      if GetEntityModel(object) ~= GetHashKey("rcbandito") and not IsEntityAttached(object) and not GetPedInVehicleSeat(object, -1) then
        deleteFunction(object)
      end
    end
  end

    finished, object = nextFunction(handle)
  until not finished
  endFunction(handle)
end

RegisterNetEvent("ac:deleteAllProps")
AddEventHandler("ac:deleteAllProps", function()
  deleteAll(FindFirstObject, FindNextObject, EndFindObject, DeleteObject)
end)

RegisterNetEvent("ac:deleteAllVehs")
AddEventHandler("ac:deleteAllVehs", function()
  deleteAll(FindFirstVehicle, FindNextVehicle, EndFindVehicle, DeleteVehicle)
end)

local blackListedEnts = {}

RegisterNetEvent("ac:updateBlacklistedEnts")
AddEventHandler("ac:updateBlacklistedEnts", function(entities)
  blackListedEnts = entities
end)

local isAdmin = false
RegisterNetEvent("ac:setAdmin")
AddEventHandler("ac:setAdmin", function(theCode)
  if theCode == 69132 then
    isAdmin = true
  else
    TriggerServerEvent("vrp:X", "Event Injection (cl_set admin)")
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)
    local ped = PlayerPedId()
    local handle, object = FindFirstObject()
    local finished = false
    repeat
        Wait(3)
        if blackListedEnts[GetEntityModel(object)] then -- GetEntityAttachedTo(object) == ped
          DeleteObject(object)
        end
        finished, object = FindNextObject(handle)
    until not finished
    EndFindObject(handle)

    if not isAdmin then
      if NetworkIsInSpectatorMode() then
        TriggerServerEvent("vrp:X", "Spectate")
      end
    end
  end
end)
  
local asked = false
RegisterNetEvent("esx:getSharedObject")
AddEventHandler("esx:getSharedObject", function()
  if not asked then
    asked = true
    TriggerServerEvent("vrp:X", "Inject (ESX method)")
  end
end)
   