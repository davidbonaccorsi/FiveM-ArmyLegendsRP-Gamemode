
-- Lista peduri: https://wiki.rage.mp/index.php?title=Peds

local tempPeds = {}
local inAnyDialog = false
local textKeys = {
  [47] = "G",
}

local npcIds = Tools.newIDGenerator()

function tvRP.spawnNpc(id, options)
  
  if not options then
    options = id
    id = npcIds:gen()
  end

  local model = GetHashKey(options.model)
  RequestModel(model)

  local coords = options.position

  RequestAnimDict("mini@strip_club@idles@bouncer@base")
  while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
    Citizen.Wait(1)
  end

  while not HasModelLoaded(model) do
    Citizen.Wait(250)
  end

  local nPed = CreatePed(1, model, coords.x, coords.y, coords.z - 1.0, (options.rotation or 0) + 0.0, false, false)
  tempPeds[id] = {
    coords = coords,
    minDist = options.minDist or 3.5,
    buttons = options.buttons,
    ["function"] = options["function"],
    name = options.name,
    description = options.description,
    key = options.key or 51,
    entity = nPed,
    input = options.input,
  }

  if tempPeds[id].buttons then
    table.insert(tempPeds[id].buttons, {
      text = "La revedere!",
      response = "post:closedPedDialog",
    })
  end

  SetModelAsNoLongerNeeded(model)
  FreezeEntityPosition(nPed, (options.freeze or false))
  SetEntityInvincible(nPed, true)
  SetBlockingOfNonTemporaryEvents(nPed, true)

  Citizen.Wait(1000)
  local scenario = options.scenario
  if scenario then
    if scenario.default then
      TaskPlayAnim(nPed,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    else
      if scenario.anim then
        RequestAnimDict(scenario.anim.dict)
        while not HasAnimDictLoaded(scenario.anim.dict) do
          Citizen.Wait(1)
        end

        TaskPlayAnim(nPed, scenario.anim.dict, scenario.anim.name, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
      else
        if scenario.startAtPosition then
          local behindPed = GetOffsetFromEntityInWorldCoords(nPed, 0.0, 0 - 0.5, -0.5);
          TaskStartScenarioAtPosition(nPed, scenario.name:upper(), behindPed.x, behindPed.y, behindPed.z, GetEntityHeading(nPed), 0, 1, false)
        else
          TaskStartScenarioInPlace(nPed, scenario.name:upper(), 0, false)
        end
      end
    end
  end

  for _, v in pairs(options.variations or {}) do
    local face = v.faceData
    if face then

      if face.face then
        SetPedHeadBlendData(nPed, face.face, face.face, 0, face.faceTexture, face.faceTexture, 0, 1.0, 0.1, 0.0, false)
        SetPedHeadOverlay(nPed, 2, 12, 1.0)
        SetPedHeadOverlayColor(nPed, 2, 1, 1, 0)
      end

      if face.ruj then
        SetPedHeadOverlay(nPed, 8, face.ruj, 1.0)
        SetPedHeadOverlayColor(nPed, 8, 1, face.culoareRuj, 0)
      end

      if face.barba then
        SetPedHeadOverlay(nPed, 1, face.barba, 1.0)
        SetPedHeadOverlayColor(nPed, 1, 1, 1, 0)
      end

      if face.machiaj then
        SetPedHeadOverlay(nPed, 4, face.machiaj, 1.0)
        SetPedHeadOverlayColor(nPed, 4, 1, face.culoareMachiaj, 0)
      end
    end

    local clothes = v.haine
    if clothes then
      for k, v in pairs(clothes) do
        local args = splitString(k, ":")
        local index = parseInt(args[2])

        if index ~= 0 then
          SetPedComponentVariation(nPed, index, v[1], v[2], v[3] or 2)
        end
      end
    end

  end

  return tonumber(nPed)
end

exports("spawnNpc", tvRP.spawnNpc)

function tvRP.deleteNpc(id)
  if tempPeds[id] then
    DeletePed(tempPeds[id].entity)
  end

  tempPeds[id] = nil
end

local cam = false
local keyActive = false
Citizen.CreateThread(function()

  while true do
    for thePed, pedData in pairs(tempPeds) do
      local coords = pedData.coords

      while #(coords - pedPos) <= pedData.minDist do
        if not tempPeds[thePed] then break end

        if not inAnyDialog then
          local key = pedData.key
          if IsControlJustReleased(0, key) and (pedData.buttons or pedData["function"]) then
            TriggerEvent("vrp-hud:showBind", false)
            inAnyDialog = true

            if pedData.buttons then
              TriggerEvent("vrp-hud:updateMap", false)
              TriggerEvent("vrp-hud:setComponentDisplay", {
                serverHud = false,
                minimapHud = false,
                bottomRightHud = false,
                chat = false,
              })
              SendNUIMessage({
                interface = "pedDialog",

                data = {
                  pedId = thePed,
                  buttons = pedData.buttons,
                  name = pedData.name,
                }
              })

              local px, py, pz = table.unpack(pedData.coords)
              local x, y, z = px + GetEntityForwardX(pedData.entity) * 1.2, py + GetEntityForwardY(pedData.entity) * 1.2, pz + 0.52
              local rx = GetEntityRotation(pedData.entity, 2)
  
              local camRotation = rx + vector3(0.0, 0.0, 181)
              local camCoords = vector3(x, y, z)
  
              ClearFocus()
              cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())
  
              SetCamActive(cam, true)
              RenderScriptCams(true, true, 1000, true, false)

              TriggerEvent("vrp:interfaceFocus", true)
            else
              inAnyDialog = false
              keyActive = false

              if pedData["function"] then
                pedData["function"]()
              end
            end
          end

          if not keyActive and (pedData.buttons or pedData["function"]) then
            keyActive = true
            TriggerEvent("vrp-hud:showBind", {key = textKeys[key] or "E", text = pedData.input or "Interactioneaza cu "..pedData.name})
          end

          DrawText3D(coords.x, coords.y, coords.z + 1.1, "~HC_54~NPC ~w~"..pedData.name, 0.750)
        end

        Citizen.Wait(1)
      end

      if keyActive then
        TriggerEvent("vrp-hud:showBind", false)
        keyActive = false
      end

    end

    Citizen.Wait(1000)
  end
end)

RegisterNUICallback("closePedDialog", function(_, cb)
  Citizen.CreateThread(function()
    Citizen.Wait(800)
    inAnyDialog = false
    keyActive = false
  end)

  TriggerEvent("vrp:interfaceFocus", false)
  TriggerEvent("vrp-hud:updateMap", true)
  
  TriggerEvent("vrp-hud:setComponentDisplay", {
    serverHud = true,
    minimapHud = true,
    bottomRightHud = true,
    chat = true,
  })
  
  ClearFocus()
  RenderScriptCams(false, true, 1000, true, false)

  DestroyCam(cam, false)

  cam = false

  cb("ok")
end)

RegisterNUICallback("selectDialogBtn", function(data, cb)
  if data[2] == "server" then
    TriggerServerEvent(data[1], table.unpack(data[3] or {}))
  else
    TriggerEvent(data[1], table.unpack(data[3] or {}))
  end

  cb("ok")
end)

RegisterNUICallback('getResponse', function(data, cb)
  if not inAnyDialog then return end

  if tempPeds[data[2]] and tempPeds[data[2]].buttons then
    local response = tempPeds[data[2]].buttons[data[1] + 1].response()
    local retArgs = type(response) ~= 'table' and table.pack(response)

    cb(retArgs or response)
  end
end)

RegisterNUICallback("getCharacterName", function(data, cb)
  cb(exports["vrp_phone"]:getCharacterName())
end)
