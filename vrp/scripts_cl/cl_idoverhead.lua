local showIds, playerData = false, {}

RegisterCommand("+viewIds_start", function()
  showIds = true
  loadAnimDict("anim@heists@ornate_bank@thermal_charge")
  TaskPlayAnim(tempPed, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)

  CreateThread(function()
    while showIds do
      for _, id in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(id) then
          local uPed = GetPlayerPed(id)

          if uPed ~= tempPed then
            local sId = GetPlayerServerId(id)
            local uData = playerData[sId]
            local uPos = GetEntityCoords(uPed)

            if uData and not uData.drawing then
              playerData[sId].drawing = true

              CreateThread(function()
                while #(uPos - pedPos) <= 13 and showIds do
                  uPos = GetEntityCoords(uPed)

                  local txt = uData.user_id
                  if NetworkIsPlayerTalking(id) then
                    txt = "~HC_10~"..txt
                  end

                  DrawText3D(uPos.x, uPos.y, uPos.z + 1.15, txt, 1.25)
                  Wait(1)
                end

                playerData[sId].drawing = false
              end)
            end
          end
        end
      end
      Wait(3000)
    end
  end)
end)

RegisterCommand("-viewIds_start", function()
  showIds = false
  ClearPedTasks(tempPed)
end)

RegisterKeyMapping("+viewIds_start", "Vezi ID-urile jucatorilor", "keyboard", "HOME")

RegisterNetEvent("id:initPlayer")
AddEventHandler("id:initPlayer", function(src, uid)
	playerData[src] = {user_id = uid}
end)

RegisterNetEvent("id:removePlayer")
AddEventHandler("id:removePlayer", function(src)
	playerData[src] = nil
end)
