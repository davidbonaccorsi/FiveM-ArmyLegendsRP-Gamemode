
local utils = {}

-- Vectors
utils.vecDist = function(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

utils.clampVecLength = function(v,maxLength)  
  if (v.x * v.x) + (v.y * v.y) + (v.z * v.z) > (maxLength * maxLength) then    
    v = utils.vecSetNormalize(v)
    v = utils.vecMulti(v,maxLength)        
  end

  return v
end

utils.vecLength = function(v)
  return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

utils.vecSetNormalize = function(v)
  local num = utils.vecLength(v)  
  
  if num == 1 then
    return v
  elseif num > 1e-5 then    
    local x = v.x / num
    local y = v.y / num
    local z = v.z / num
    
    return vector3(x,y,z)
  else    
    return vector3(0,0,0)
  end 
end


utils.vecMulti = function(v,q)
  local x,y,z
  local retVec
  if type(q) == "number" then
    x = v.x * q
    y = v.y * q
    z = v.z * q
    retVec = vector3(x,y,z)
  end
  
  return retVec
end


utils.drawText3D = function(coords, text, size, font)
  coords = vector3(coords.x, coords.y, coords.z)

  local camCoords = GetGameplayCamCoords()
  local distance = #(coords - camCoords)

  if not size then size = 1 end
  if not font then font = 0 end
  
  local scale = (size / distance) * 2
  local fov = (1 / GetGameplayCamFov()) * 100
  scale = scale * fov

  SetTextScale(0.0 * scale, 0.55 * scale)
  SetTextFont(font)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)

  SetDrawOrigin(coords, 0)
  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.0, 0.0)
  ClearDrawOrigin()
end


utils.getCoordsInFrontOfCam = function(...)
  local coords,direction    = GetGameplayCamCoord(), utils.rotationToDirection()
  local inTable  = {...}
  local retTable = {}

  if ( #inTable == 0 ) or ( inTable[1] < 0.000001 ) then inTable[1] = 0.000001 ; end

  for k,distance in pairs(inTable) do
    if ( type(distance) == "number" )
    then
      if    ( distance == 0 )
      then
        retTable[k] = coords
      else
        retTable[k] =
          vector3(
            coords.x + ( distance*direction.x ),
            coords.y + ( distance*direction.y ),
            coords.z + ( distance*direction.z )
          )
      end
    end
  end

  return table.unpack(retTable)
end

utils.rotationToDirection = function(rot)
  if     ( rot == nil ) then rot = GetGameplayCamRot(2);  end
  local  rotZ = rot.z  * ( 3.141593 / 180.0 )
  local  rotX = rot.x  * ( 3.141593 / 180.0 )
  local  c = math.cos(rotX);
  local  multXY = math.abs(c)
  local  res = vector3( ( math.sin(rotZ) * -1 )*multXY, math.cos(rotZ)*multXY, math.sin(rotX) )
  return res
end

math.pow = math.pow or function(n,p) return (n or 1)^(p or 1) ; end
utils.round = function(val, scale)
  val,scale = val or 0, scale or 0
  return (
    val < 0 and  math.floor((math.abs(val*math.pow(10,scale))+0.5))*math.pow(10,((scale)*-1))*(-1)
             or  math.floor((math.abs(val*math.pow(10,scale))+0.5))*math.pow(10,((scale)*-1))
  )
end







furni.rotMult  = 5.0
furni.rotationAxis = "x"
furni.rotation = {x = 0.0, y = 0.0, z = 0.0}
furni.position = {x = 0.0, y = 0.0, z = 0.0}
furni.distMult = 55.0
furni.distAdder = 1.0
furni.minDist = 5.0
furni.maxDist = 20.0
furni.focused = false
furni.canEdit = false

local vRP = exports.vrp:link()
local svRP = Tunnel.getInterface("vRP_housing", "vRP_furni")

furni.nudgeOffsets = {x = 0.00, y = 0.00, z = 0.00}
furni.nudgeMult = 0.01

furni.spawnedObjects = {}

furni.init = function()
  SendNUIMessage({
    type              = "init",
    onOpen            = "http://playerhousing/DoOpen",
    onClose           = "http://playerhousing/DoClose",
    onCancel          = "http://playerhousing/DoCancel",
    onSelect          = "http://playerhousing/DoSelect",
    onPlace           = "http://playerhousing/DoPlace",
    onStartAim        = "http://playerhousing/DoStartAim",
    onStopAim         = "http://playerhousing/DoStopAim",
    onReposition      = "http://playerhousing/DoReposition",
    onRepositionStart = "http://playerhousing/DoRepositionStart",
    onTransform       = "http://playerhousing/DoTransform",
    onEdit            = "http://playerhousing/DoEdit",
    onRemove          = "http://playerhousing/DoRemove",
    onExit            = "http://playerhousing/DoExit",
    items             = furni.objects,
    top               = "300px",
    left              = "20px"
  })
end

furni.handleControls = function(e)
  if not e and     IsControlEnabled(0,  23) then d = true;
  elseif e and not IsControlEnabled(0,  23) then d = true;
  end

  if d then
    -- All controls related to [F] key
    DisableControlAction(0,  23, e)
    DisableControlAction(0,  75, e)
    DisableControlAction(0, 144, e)
    DisableControlAction(0, 145, e)
    DisableControlAction(0, 185, e)
    DisableControlAction(0, 251, e)

    -- Left click
    DisableControlAction(0,  18, e)
    DisableControlAction(0,  24, e)
    DisableControlAction(0,  69, e)
    DisableControlAction(0,  92, e)
    DisableControlAction(0, 106, e)
    DisableControlAction(0, 122, e)
    DisableControlAction(0, 135, e)
    DisableControlAction(0, 142, e)
    DisableControlAction(0, 144, e)
    --DisableControlAction(0, 176, e)
    DisableControlAction(0, 223, e)
    DisableControlAction(0, 229, e)
    DisableControlAction(0, 237, e)
    DisableControlAction(0, 257, e)
    DisableControlAction(0, 329, e)
    DisableControlAction(0, 346, e)

    -- Right Click
    DisableControlAction(0,  25, e)
    DisableControlAction(0,  68, e)
    DisableControlAction(0,  70, e)
    DisableControlAction(0,  91, e)
    DisableControlAction(0, 114, e)
    --DisableControlAction(0, 177, e)
    DisableControlAction(0, 222, e)
    DisableControlAction(0, 225, e)
    DisableControlAction(0, 238, e)
    DisableControlAction(0, 330, e)
    DisableControlAction(0, 331, e)
    DisableControlAction(0, 347, e)

    -- Numpad -
    DisableControlAction(0,  96, e)
    DisableControlAction(0,  97, e)
    DisableControlAction(0, 107, e)
    DisableControlAction(0, 108, e)
    DisableControlAction(0, 109, e)
    DisableControlAction(0, 110, e)
    DisableControlAction(0, 111, e)
    DisableControlAction(0, 112, e)
    DisableControlAction(0, 117, e)
    DisableControlAction(0, 118, e)
    DisableControlAction(0, 123, e)
    DisableControlAction(0, 124, e)
    DisableControlAction(0, 125, e)
    DisableControlAction(0, 126, e)
    DisableControlAction(0, 127, e)
    DisableControlAction(0, 128, e)
    DisableControlAction(0, 314, e)
    DisableControlAction(0, 315, e)
  end
end

furni.update = function()

  local keyHeldFor = 0
  local lastFrame = 0
  local lastHouseCheck = 0
  while true do
    if furni.inHouse and not furni.editing and not furni.doingRemoval and not furni.object and furni.canEdit then
      if IsControlJustPressed(0, Controls["Focus"]) or IsDisabledControlJustPressed(0, Controls["Focus"]) then
        furni.focus(true)
      end
    end
    
    if furni.inHouse then
      local timeNow = GetGameTimer()
      if (not lastHouseCheck) or ((timeNow - lastHouseCheck) > 1000) then
        lastHouseCheck = timeNow
        N_0xf4f2c0d4ee209e20() -- Disable the pedestrian idle camera
      end
    end

    if furni.active then      
      local start,fin               = utils.getCoordsInFrontOfCam(0, 5000)
      local ray                     = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 1, (furni.object or GetPlayerPed(-1)), 5000)
      local oRay                    = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 16, (furni.object or GetPlayerPed(-1)), 5000)
      local r,hit,pos,norm,ent      = GetShapeTestResult(ray)
      local oR,oHit,oPos,oNorm,oEnt = GetShapeTestResult(oRay)

      if oHit > 0 then r,hit,pos,norm,ent = oR,oHit,oPos,oNorm,oEnt; end

      if furni.doAim and not furni.focused then
        if IsDisabledControlJustReleased(0, Controls["Grab"]) or IsControlJustReleased(0, Controls["Grab"]) then
          FreezeEntityPosition(furni.object,true)
          furni.doAim = false     
          furni.focus   (true)
        end
      end

      if hit > 0 then        
        furni.hitPos = pos

        if furni.editing then
          furni.handleControls(true)

          local ped = GetPlayerPed(-1)
          local p = GetEntityCoords(ped)

          if ent and ent ~= -1 and ent ~= 0 and DoesEntityExist(ent) then
            local ePos = GetEntityCoords(ent)
            if ePos.x ~= 0.0 then
              local model = GetEntityModel(ent)
              if model ~= 276092861 and model ~= -775821472 and model ~= -944672758 and model ~= -1065164752 and model ~= -886563882 then
                if wasPressing and keyHeldFor >= 500 then
                  utils.drawText3D(pos,"~r~Lasa [~s~Click~r~] pentru a muta [~s~"..(hashtable[model] and hashtable[model].name or "Unknown").."~r~]~s~",1,7)
                else
                  utils.drawText3D(pos,"~y~Tine apasat [~s~Click~y~] pentru a muta [~s~"..(hashtable[model] and hashtable[model].name or "Unknown").."~y~]~s~",1,7)
                end

                if IsDisabledControlJustReleased(0, Controls["Grab"]) or IsDisabledControlReleased(0, Controls["Grab"]) and wasPressing then
                  if keyHeldFor >= 500 then
                    keyHeldFor = 0
                    wasPressing = false
                    furni.editing = false
                    local fwd,up,right,p = GetEntityMatrix(ent)
                    furni.wasEditing = {pos = GetEntityCoords(ent), rot = GetEntityRotation(rot,2), lastPos = p}
                    furni.edit(ent,hashtable[model]) 
                  end
                end
                if IsDisabledControlPressed(0, Controls["Grab"]) or IsControlPressed(0, Controls["Grab"]) and not furni.focused then
                  keyHeldFor = keyHeldFor + (GetGameTimer() - lastFrame)
                  wasPressing = true
                else
                  keyHeldFor = 0
                  wasPressing = false
                end
              end
            end
          end   
          if IsDisabledControlJustPressed(0, Controls["Focus"]) or IsControlJustPressed(0, Controls["Focus"]) then
            furni.editing = false
            furni.wasEditing = false
            furni.focus(true)
          end 
        elseif furni.doingRemoval then
          furni.handleControls(true)

          local ped = GetPlayerPed(-1)
          local p = GetEntityCoords(ped)

          if ent and ent ~= -1 and ent ~= 0 then
            local ePos = GetEntityCoords(ent)
            if ePos and ePos.x and ePos.x ~= 0 and ePos.x ~= 0.0 then
              local model = GetEntityModel(ent)
              if model ~= 276092861 and model ~= -775821472 and model ~= -944672758 and model ~= -1065164752 and model ~= -886563882 then
                utils.drawText3D(pos,"~y~Tine apasat [~s~Click~y~] pentru a vinde [~s~"..(hashtable[model] and hashtable[model].name or "Unknown").."~y~] [~s~"..(hashtable[model] and "$"..math.floor(hashtable[model].price*0.1) or "Unknown").."~y~]~s~",1,7)
                if IsDisabledControlPressed(0, Controls["Grab"]) or IsControlPressed(0, Controls["Grab"]) and not furni.focused then
                  keyHeldFor = keyHeldFor + (GetGameTimer() - lastFrame)
                  if keyHeldFor >= 500 then
                    keyHeldFor = 0
                    if hashtable[model] and hashtable[model].name then
                      furni.remove(ent, {object = model, sellPrice = math.floor(hashtable[model].price*0.1)})
                    end
                  end
                else
                  keyHeldFor = 0
                end
              end
            end
          end
          if IsDisabledControlJustPressed(0, Controls["Focus"]) or IsControlJustPressed(0, Controls["Focus"]) then
            furni.doingRemoval = false
            furni.focus(true)
          end
        elseif furni.object then
          furni.handleControls(true)
          
          local min,max =  GetModelDimensions(GetEntityModel(furni.object))
          local minOff  = -GetOffsetFromEntityGivenWorldCoords(furni.object, min.x, min.y, min.z)
          local maxOff  = -GetOffsetFromEntityGivenWorldCoords(furni.object, max.x, max.y, max.z)
          local off     =  maxOff - minOff

          local p = GetEntityCoords(furni.object)
          p = vector3(p.x, p.y, p.z + (max.z/2)) 

          local x,y,z = 0,0,0
          local targetPos
          local dist = utils.vecDist(start, pos)

          if dist < furni.distMult + 0.5 then
            if norm.x >  0.5  then x = x + max.x; end
            if norm.x < -0.5  then x = x + min.x; end
            if norm.y >  0.5  then y = y + max.y; end
            if norm.y < -0.5  then y = y + min.y; end
            if norm.z >  0.5  then z = z - min.z; end
            if norm.z < -0.5  then z = z - max.z; end

            targetPos = vector3(pos.x + x,pos.y + y,pos.z + z)
          else
            local dir = pos - start
            local clamped = utils.clampVecLength(dir, furni.distMult)
            targetPos = start + clamped
          end

          if furni.controlling then
            SetEntityCoordsNoOffset(
              furni.object, 
              targetPos.x + furni.nudgeOffsets.x, 
              targetPos.y + furni.nudgeOffsets.y, 
              targetPos.z + furni.nudgeOffsets.z
            )
          end

          local rot         = furni.rotation
          SetEntityRotation (furni.object, rot.x*1.0,rot.y*1.0,rot.z*1.0, 2)
        else
          furni.handleControls(false)
        end
      end
    end
    lastFrame = GetGameTimer()

    if not furni.inHouse then Citizen.Wait(1024) end
    Wait(0)
  end
end

furni.overlay = function(overlay)
  local enabled,type,text,color
  if not overlay then
    enabled = false
    type = "overlay"
    text = ""
    color = {r = 0, g = 0, b = 0, a = 0}
  elseif overlay == "place" then
    enabled = true
    type = "overlay"
    text = "place furniture"
    color = {r = 0, g = 0, b = 255, a = 100}
  elseif overlay == "remove" then
    enabled = true
    type = "overlay"
    text = "remove furniture"
    color = {r = 255, g = 0, b = 0, a = 100}
  elseif overlay == "edit" then
    enabled = true
    type = "overlay"
    text = "edit furniture"
    color = {r = 0, g = 255, b = 0, a = 100}
  end
  SendNUIMessage({enabled = enabled, type = type, text = text, color = color})
  --furni.setAlpha(0.1)
end

furni.edit = function(ent,data)
  furni.object = ent
  furni.objectData = data
  furni.focus(true)

  local rot = GetEntityRotation(ent,2)
  furni.rotation = {x = rot.x, y = rot.y, z = rot.z}
  furni.nudgeOffsets = {x = 0.0, y = 0.0, z = 0.0}

  SetEntityAsMissionEntity(ent,true,true)
  DeleteEntity(ent)
  DeleteObject(ent)

  SendNUIMessage({  type = "openEdit", name = data.name, id = data.id, price = data.price})
end

furni.remove = function(ent,data)
  local r = GetEntityRotation(ent,2)
  local p = GetEntityCoords(ent)
  SetEntityAsMissionEntity(ent,true,true)
  DeleteEntity(ent,true)
  DeleteObject(ent,true)

  furni.controlling = false
  TriggerServerEvent('furni:DeleteFurniture', furni.inHouse.id, data)
end

furni.display = function(display)
  SendNUIMessage({type = "display", enabled = display})
  furni.controlling = display
end

furni.focus = function(focus)
  furni.focused = focus

  if focus then
    SetControlNormal(0, Controls["Grab"], 1.0)
    Wait(100)
    SetControlNormal(0, Controls["Grab"], 0.0)
    Wait(100)
  end

  SetNuiFocus(focus,focus)

  if furni.object then
    local pos = GetEntityCoords(furni.object)
    local rot = GetEntityRotation(furni.object, 2)
    SendNUIMessage({ type = "setTransform", position = {x = utils.round(pos.x,2), y = utils.round(pos.y,2), z = utils.round(pos.z,2)}, rotation = {x = rot.x, y = rot.y, z = rot.z} })
  end

  furni.lastPosition = pos;
  if focus then
    SendNUIMessage({ type = "focus" })
    furni.setAlpha(1.0)
    furni.controlling = false

    if not furni.object then
      furni.overlay(false)
    end
  else
    furni.setAlpha(0.1)
    furni.controlling = true
  end
end

furni.setAlpha = function(a)
  SendNUIMessage({ type = "setAlpha", alpha = a })
end 

-- NUI callback functions.
furni.doOpen = function(...)
  furni.display(true)
end

furni.doClose = function()
  
end

furni.doCancel = function(...) 
  if furni.object and not furni.wasEditing then
    SetEntityAsMissionEntity(furni.object,true,true)
    DeleteObject(furni.object)
  elseif furni.object then
    local p = furni.wasEditing.pos
    local r = furni.wasEditing.rot
    SetEntityCoordsNoOffset(furni.object, p.x,p.y,p.z)
    SetEntityRotation(furni.object, r.x,r.y,r.z, 2)
    furni.editing = true
    furni.focus(false)
    furni.overlay("edit")
  end
  furni.nudgeOffsets = {x = 0.0, y = 0.0, z = 0.0}
  furni.rotation = {x = 0.0, y = 0.0, z = 0.0}

  furni.object = false
end

furni.doPlace = function()

  FreezeEntityPosition(furni.object, true)

  if furni.inHouse then
    local pos = GetEntityCoords(furni.object) - furni.inHouse.pos.xyz
    local rot = GetEntityRotation(furni.object, 2)

    local item = lookuptable[furni.objectData.id]
    if furni.wasEditing then
      TriggerServerEvent('furni:ReplaceFurniture', tonumber(furni.inHouse.id), item, pos, rot)
    else
      svRP.hasMoney({item.price}, function(canPay)
        if canPay then
          TriggerServerEvent('furni:PlaceFurniture', tonumber(furni.inHouse.id), item, pos, rot)
        else
          vRP.notify("Nu iti permiti acest obiect")
        end
      end)
      
    end
  end

  furni.nudgeOffsets = {x = 0.0, y = 0.0, z = 0.0}
  furni.rotation = {x = 0.0, y = 0.0, z = 0.0}

  furni.object = false
  if furni.wasEditing then
    SendNUIMessage({type = "close"})
    furni.focus(false)
    furni.editing = true
    furni.overlay("edit")
    furni.wasEditing = false
  end
end

furni.doSelect = function(obj) 
  while not furni.hitPos do Wait(0); end
  local hash = GetHashKey(obj.id)
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0); end

  ExecuteCommand("syncthem")

  furni.objectData = obj
  furni.object = CreateObject(hash, furni.hitPos.x,furni.hitPos.y,furni.hitPos.z, false,false,false)
  furni.spawnedObjects[#furni.spawnedObjects+1] = furni.object

  Wait(10)

  local pos = GetEntityCoords(furni.object)
  local rot = GetEntityRotation(furni.object, 2)
  SendNUIMessage({ type = "setTransform", position = {x = utils.round(pos.x,2), y = utils.round(pos.y,2), z = utils.round(pos.z,2)}, rotation = {x = rot.x, y = rot.y, z = rot.z} })
end

furni.doStartAim = function(...)
  furni.doAim = true
  if not furni.wasEditing or not furni.editing or not furni.doingRemoval then
    furni.overlay("place")
  end
  furni.focus(false)
  SetCurrentPedWeapon(GetPlayerPed(-1), `WEAPON_UNARMED`, true)
  if furni.object then FreezeEntityPosition(furni.object,false); end
end

furni.doStopAim = function(...) end
furni.doRepo = function() end
furni.doRepoStart = function() end

furni.doTransform = function(tab)
  local vPos = vector3(tab.position.x,tab.position.y,tab.position.z)
  local p = vPos - furni.hitPos
  local r = tab.rotation

  FreezeEntityPosition(furni.object,false)
  furni.nudgeOffsets = {x = p.x, y = p.y, z = p.z}
  furni.rotation = r
  SetEntityCoordsNoOffset(furni.object, utils.round(tab.position.x,2),utils.round(tab.position.y,2),utils.round(tab.position.z,2))
  FreezeEntityPosition(furni.object,true)
end

furni.doEdit = function()
  furni.editing = true
  furni.overlay("edit")
  furni.focus(false)
end

furni.doRemove = function()
  furni.doingRemoval = true
  furni.overlay("remove")
  furni.focus(false)
end

furni.doExit = function()
  furni.focus(false)
end


RegisterNUICallback('DoOpen',             furni.doOpen)
RegisterNUICallback('DoClose',            furni.doClose)
RegisterNUICallback('DoCancel',           furni.doCancel)
RegisterNUICallback('DoSelect',           furni.doSelect)
RegisterNUICallback('DoPlace',            furni.doPlace)
RegisterNUICallback('DoStartAim',         furni.doStartAim)
RegisterNUICallback('DoStopAim',          furni.doStopAim)
RegisterNUICallback('DoReposition',       furni.doRepo)
RegisterNUICallback('DoRepositionStart',  furni.doRepoStart)
RegisterNUICallback('DoTransform',        furni.doTransform)
RegisterNUICallback('DoEdit',             furni.doEdit)
RegisterNUICallback('DoRemove',           furni.doRemove)
RegisterNUICallback('DoExit',             furni.doExit)

local function spawnFurniture(housePos, jfTbl)
  local fTbl = jfTbl or {}

  ExecuteCommand("syncthem")

  for _, obj in pairs(fTbl) do
    local theObj = CreateObject(GetHashKey(obj.model), 
      housePos.x + obj.pos.x, 
      housePos.y + obj.pos.y,
      housePos.z + obj.pos.z, 
    false, false, false)
    
    furni.spawnedObjects[#furni.spawnedObjects+1] = theObj

    Wait(10)

    SetEntityAsMissionEntity(theObj, true, true)
    SetEntityRotation(theObj, obj.rot.x, obj.rot.y, obj.rot.z, 2)
    FreezeEntityPosition(theObj, true)
  end
end

RegisterNetEvent("playerhousing:Entered")
AddEventHandler("playerhousing:Entered", function(pos,id,jfTbl,ownerId,hasKeys)
  furni.inHouse = {pos = pos, id = id}

  spawnFurniture(pos, jfTbl)

  svRP.getMyId({}, function(myId)
    if tostring(myId) == tostring(ownerId) or hasKeys then
      furni.active = true
      furni.display(true)
      furni.focus(false)
      furni.canEdit = true
    end
  end)
end)

RegisterNetEvent("playerhousing:Leave")
AddEventHandler("playerhousing:Leave", function()
  furni.inHouse = false
  for key,val in pairs(furni.spawnedObjects) do
    SetEntityAsMissionEntity(val,true,true)
    DeleteEntity(val)
    DeleteObject(val)
  end
  furni.spawnedObjects = {}

  furni.doingRemoval = false
  furni.editing = false
  furni.wasEditing = false
  furni.doAim = false

  furni.focus(true)
  Wait(50)
  furni.focus(false)

  furni.active = false
  furni.canEdit = false 
  furni.display(false)
end)

Citizen.CreateThread(function()
  Wait(5)
  furni.init      (false)
  furni.display   (false)

  furni.update    (false)
end)


RegisterCommand('furni', function()
  if furni.inHouse then
    furni.active = true
    furni.display(true)
  else
    vRP.notify("You must be inside a house.")
  end
end)
RegisterCommand('focus', function()
  if furni.inHouse then
    furni.focus(true)
  else
    vRP.notify("You must be inside a house.")
  end
end)