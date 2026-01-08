local requestSent = false
local defaultBlipScale = 0.5
local defaultMarkerDistance = 7.5
local currentArea = nil
local markersData = {}
local blipsData = {}
local mapAreas = {}

-- Graphics (3d text, subtitle)
function DrawText3D(x,y,z, text, scl, font) 
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  local px,py,pz = table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)
  local scale = (1/dist*scl)*(1/GetGameplayCamFov()*100);
 
  if onScreen then
    SetTextScale(0.0*scale, 1.1*scale)
    SetTextFont(font or 0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
  end
end

function DrawRectText(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35,0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function tvRP.displayHelp(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Blipuri (lista blips: https://wiki.rage.mp/index.php?title=Blips)
Citizen.CreateThread(function()
  local id = 0
  
  for blip, blip in pairs(cfg.map_blips) do
      id = id + 1
      local x,y,z = table.unpack(blip.coords)
    
      local nid = tvRP.addBlip("custom_blip:"..id, x, y, z, blip.blip_id, blip.blip_color, (type(blip) == "string" and blip or (blip.name or "")), blip.scale)
      if blip.blip_id == 161 then
        SetBlipPriority(nid, 1)
      else
        SetBlipPriority(nid, blip.priority or 2)
      end
  end
end)

function tvRP.addBlip(id, x, y, z, blipId, blipColor, name, scale)
  if not id then return end
  
  blipsData[id] = AddBlipForCoord(x+0.001, y+0.001, z+0.001)
  SetBlipSprite(blipsData[id], blipId)
  SetBlipAsShortRange(blipsData[id], true)
  SetBlipColour(blipsData[id], blipColor)
  
  if scale then
    SetBlipScale(blipsData[id], scale)
  end

  if name then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blipsData[id])
  end

  return blipsData[id]
end

function tvRP.setBlipRoute(blipId, routeState, keepColor)
  if not routeState then routeState = true end
  if not blipsData[blipId] then return end
  local theBlip = blipsData[blipId]

  SetBlipRoute(theBlip, routeState)
  
  if keepColor then
    if type(keepColor) == "string" then
      SetBlipRouteColour(theBlip, GetBlipColour(theBlip))
    elseif type(keepColor) == "number" then
      SetBlipRouteColour(theBlip, keepColor)
    end
  end
end

function tvRP.setBlipPriority(blipId, priority)
  if not blipsData[blipId] then
    return
  end

  SetBlipPriority(blipsData[blipId], priority)
end

function tvRP.setBlipCoords(blipId, newCoords)
  if not blipsData[blipId] then return end
  SetBlipCoords(blipsData[blipId], newCoords)
end

function tvRP.setGPS(x,y)
  SetNewWaypoint(x+0.0001,y+0.0001)
end

RegisterNUICallback("setMapPosition", function(data, cb)
  local x, y = tonumber(data[1]), tonumber(data[2])
  SetNewWaypoint(x, y)

  if data[3] then
    tvRP.notify("Pozitie setata pe harta.")
  end
  
  cb("ok")
end)

RegisterNetEvent("vRP:setGPS", tvRP.setGPS)

function tvRP.deleteBlip(blipId)
  if not blipsData[blipId] then return end
  RemoveBlip(blipsData[blipId])
  blipsData[blipId] = nil
end

-- Markere/floating texts (lista markere: https://wiki.rage.mp/index.php?title=Markers)
function tvRP.addHologram(x, y, z, text, size, textFont, distance, markWithID)
  local document = {
      coords = vector3(x, y, z),
      text = tostring(text),
      scale = size,
      font = (textFont or 0),
      colors = {0, 0, 0, 255},
      minDist = (distance or defaultMarkerDistance),
  }

  if markWithID then markersData[markWithID] = {type = "hologram", info = document} return end
  markersData[#markersData + 1] = {type = "hologram", info = document}
end

function tvRP.setHologramText(id, newValue)
  if markersData[id] then
    markersData[id].info.text = tostring(newValue or "")
  end
end

function tvRP.drawIndicator(text, pos)
	AddTextEntry("DUTYSTRING", text)
	
	SetFloatingHelpTextWorldPosition(1, pos)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)

	BeginTextCommandDisplayHelp("DUTYSTRING")
	EndTextCommandDisplayHelp(2, false, false, -1)
end

function tvRP.addMarker(x, y, z, sizeX, sizeY, sizeZ, r,g, b, a, markerType, distance, markWithID)
  local x,y,z = tonumber(x),tonumber(y),tonumber(z)
  local document = {
      coords = vector3(x,y,z),
      scale = vector3((sizeX or 0.45), (sizeY or 0.45), (sizeZ or 0.45)),
      colors = {(r or 255), (g or 255), (b or 255), (a or 255)},
      minDist = (distance or defaultMarkerDistance),
      displayId = (markerType or 21),
  }
  if markWithID then
    markersData[markWithID] = {type = "marker", info = document}
    return
  end
  markersData[#markersData + 1] = {type = "marker", info = document}
end

function tvRP.removeMarker(marker_id)
  if not markersData[marker_id] then return end
  markersData[marker_id] = nil
end

-- Map Areas
function tvRP.setArea(name, x, y, z, radius, text,marker, execAtJoin)
  local areaType = "server"
  if execAtJoin then areaType = "client" end

  mapAreas[name] = {
    coords = vector3(tonumber(x) + 0.001, tonumber(y) + 0.001, tonumber(z) + 0.001),
    radius = radius,
    key = text,
    marker = marker,
    areaType = areaType,
    onJoin = (execAtJoin or function() end),
    onLeave = (execAtLeave or function() end),
  }
end

function tvRP.removeArea(name)
  if not mapAreas[name] then return end
  mapAreas[name] = nil
end

function tvRP.enterArea(areaId)
  if not mapAreas[areaId] then return end
  mapAreas[areaId].onJoin(areaId)
  currentArea = areaId
end

function tvRP.leaveArea(areaId)
  if not mapAreas[areaId] then return end
  mapAreas[areaId].onLeave(areaId)
  currentArea = nil
  if requestSent then
    requestSent = false
    TriggerEvent("vrp-hud:showBind", false)
  end
end


local inputActive = {}
Citizen.CreateThread(function()

  while true do
    for key, data in pairs(mapAreas) do

      while #(data.coords - pedPos) <= data.radius do

        for key, data in pairs(mapAreas) do
          local marker = data.marker
          local areaType = data.areaType
          local areaDist = #(data.coords - pedPos)


          if areaDist <= data.radius then
            if marker then
              local coords = marker.coords or data.coords
              DrawMarker(marker.type, coords[1], coords[2], coords[3], 0, 0, 0, 0, 0, 0, marker.x, marker.y, marker.z, marker.color[1], marker.color[2], marker.color[3], marker.color[4], marker.effect, true)
            end

            if areaDist <= (data.key.minDst or 3) then
              if not inputActive[key] then
                  inputActive[key] = true
                  TriggerEvent("vrp-hud:showBind", data.key)
              end

              if IsControlJustPressed(0, 51) then
                TriggerEvent("vrp-hud:showBind", false)
                inputActive[key] = false

                if areaType == 'server' then
                  vRPserver.enterArea({key})
                else
                  tvRP.enterArea(key)
                end
              end
            else
              if inputActive[key] then
                TriggerEvent("vrp-hud:showBind", false)
                inputActive[key] = false
              end
            end
          end

        end

        Citizen.Wait(1)
      end

      if inputActive[key] then
        TriggerEvent("vrp-hud:showBind", false)
        inputActive[key] = false
      end

    end

    Citizen.Wait(1000)
  end

end)



