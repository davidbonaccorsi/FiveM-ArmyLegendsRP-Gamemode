carBelt = false
local function IsCar(veh)
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end 


local excludedClasses = {
  [8] = "Motorcycles",
  [21] = "Trains",
}

local function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

local isInVehicle = false
local oldSpeed = 0.0

AddEventHandler('vrp:onPlayerLeaveVehicle', function()
  isInVehicle, carBelt = false, false
end)

AddEventHandler('vrp:onPlayerEnterVehicle', function(veh)
  oldSpeed = 0.0
  isInVehicle = true

  if not carBelt and not excludedClasses[GetVehicleClass(veh)] then
    tvRP.notify("Apasa tasta G pentru a-ti pune centura.")
  end

  if exports.vrp:isCop() then
    tvRP.notify("Apasa tasta Numpad 5 pentru radar.")
  end

  Citizen.CreateThread(function()
      while isInVehicle do
          if carBelt then DisableControlAction(0, 75) end

          local currentSpeed = GetEntitySpeed(playerVehicle)
          if (currentSpeed < oldSpeed) and (GetEntitySpeedVector(playerVehicle, true).y > 1.0) and (oldSpeed - currentSpeed) >= 20.0 then
              TriggerEvent("carCrash")
              if not carBelt then
                  local pedCoords = GetEntityCoords(tempPed)
                  local pedFw = Fwv(tempPed)
                  SetEntityCoords(tempPed, pedCoords.x + pedFw.x, pedCoords.y + pedFw.y, pedCoords.z - 0.47, true, true, true)
                  SetEntityVelocity(tempPed, GetEntityVelocity(car))
                  Wait(100)
                  SetPedToRagdoll(tempPed, 1000, 1000, 0, 0, 0, 0)
              end
              Wait(1000)
          end
          oldSpeed = currentSpeed
          Wait(1)
      end
  end)
end)

function tvRP.isInSeatbelt()
	return carBelt
end 

RegisterCommand("switchseatbelt", function()
  Wait(500)
  local veh = playerVehicle
  
  if (veh ~= 0) and not excludedClasses[GetVehicleClass(veh)] then
    carBelt = not carBelt
  end
end)

RegisterKeyMapping("switchseatbelt", "Pune/scoate centura", "keyboard", "G")