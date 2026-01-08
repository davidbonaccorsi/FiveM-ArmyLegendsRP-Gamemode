function weaponHolster(canHolster)
  if (playerVehicle == 0) and not tvRP.isInComa() then
      RequestAnimDict("reaction@intimidation@1h")
      while not HasAnimDictLoaded("reaction@intimidation@1h") do
          Citizen.Wait(1)
      end

      if canHolster then
          TaskPlayAnim(tempPed, "reaction@intimidation@1h", "intro", 8.0, 2.0, -1, 48, 2, 0, 0, 0)
          Citizen.CreateThread(function()
              local expTask = GetGameTimer() + 2500

              while expTask > GetGameTimer() do
                  DisableControlAction(1, 37, true)
                  DisableControlAction(0,24)
                  DisableControlAction(0,25)
                  DisableControlAction(0,69)
                  DisableControlAction(0,70)
                  DisableControlAction(0,92)
                  DisableControlAction(0,114)
                  DisableControlAction(0,257)
                  DisableControlAction(0,331)
                  
                  Citizen.Wait(1)
              end
              Citizen.Wait(250)
              ClearPedTasks(tempPed)
          end)
      else
          TaskPlayAnim(tempPed, "reaction@intimidation@1h", "outro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
          Citizen.Wait(1500)
          ClearPedTasks(tempPed)
      end
  end
end
