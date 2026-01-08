function tvRP.gotoWaypoint()
  local targetPed = tempPed
  local targetVeh = GetVehiclePedIsUsing(targetPed)
  if(IsPedInAnyVehicle(targetPed))then
      targetPed = targetVeh
  end

  if(not IsWaypointActive())then
      tvRP.notify("Markerul nu a fost gasit.", "error")
      return
  end

  local waypointBlip = GetFirstBlipInfoId(8)
  local x,y,z = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector()))

  local ground
  local groundFound = false

  for height = 0, 800, 2 do
      SetEntityCoordsNoOffset(targetPed, x,y,height+0.0001, 0, 0, 1)
      Citizen.Wait(10)

      ground,z = GetGroundZFor_3dCoord(x,y,height+0.0001)
      if(ground) then
          z = z + 1
          groundFound = true
          break;
      end
  end

  if(not groundFound)then
      z = 1000
      GiveDelayedWeaponToPed(PlayerPedId(), 0xFBAB5776, 1, 0)
  end

  SetEntityCoordsNoOffset(targetPed, x,y,z, 0, 0, 1)
  tvRP.notify("Te-ai teleportat la waypoint!", "success")
end

RegisterNetEvent("adminMessage", function(sender, message)
  SendNUIMessage({interface = "adminMsg", text = message, name = sender})
  Wait(3000)
  TriggerEvent("sound:play", "adminmsg")
end)

local function drawSubtitle(text, font, sizeX, sizeY, alpha, posY)
  SetTextFont(font or 0)
  SetTextProportional(0)
  SetTextScale((sizeX or 0.25), sizeY or 0.3)
  SetTextColour(255, 255, 255, alpha or 255)
  SetTextDropShadow(40, 5, 5, 5, 255)
  SetTextEdge(30, 5, 5, 5, 255)
  SetTextDropShadow()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.5, posY or 0.95)
end

local canUseWeapon = true
function tvRP.toggleAllWeapons(state)
  canUseWeapon = state

  while not canUseWeapon do
    Citizen.Wait(1)
    drawSubtitle("~HC_31~Un membru staff a dezactivat folosirea armelor")

    DisableControlAction(0,24,true)
    DisableControlAction(0,25,true)
    DisableControlAction(0,47,true)
    DisableControlAction(0,58,true)
    DisableControlAction(0,263,true)
    DisableControlAction(0,264,true)
    DisableControlAction(0,257,true)
    DisableControlAction(0,140,true)
    DisableControlAction(0,141,true)
    DisableControlAction(0,142,true)
    DisableControlAction(0,143,true)
  end
end



