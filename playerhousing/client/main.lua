local housing = playerhousing

local vRP = exports.vrp:link()
local svRP = Tunnel.getInterface("vRP_housing", "vRP_housing")

local function draw3DText(coords, text, size, font)
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

RegisterNetEvent("vrp-housing:updateRents")
AddEventHandler("vrp-housing:updateRents", function(rents)
  housing.Rents = (rents or {})
  for k, v in pairs(housing.Rents) do
    if housing.HouseData[v.house] then
      housing.HouseData[v.house].rent = v.formated
    end
  end
end)

RegisterNetEvent("vrp-housing:startDone")
AddEventHandler("vrp-housing:startDone", function(keys, rents)
  housing.Keys = (keys or {})
  for k, v in pairs(housing.Keys) do
    if housing.HouseData[v.house] then
      housing.HouseData[v.house].keys = true
    end
  end

  housing.Rents = (rents or {})
  for k, v in pairs(housing.Rents) do
    if housing.HouseData[v.house] then
      housing.HouseData[v.house].rent = v.formated
    end
  end

  local ready = false
  svRP.getUserSuperData({}, function(theData)
    housing.PlayerData = theData
    ready = true
  end)

  while not ready do Citizen.Wait(50) end
  housing:RefreshBlips()
  housing:Update()

end)

function housing:RefreshBlips()
  if self.Blips then
    for k,v in pairs(self.Blips) do
      RemoveBlip(v)
    end
  end

  self.Blips = {}
  for k,v in pairs(self.HouseData) do
    if not v.owner or (tostring(v.owner) == tostring(self.PlayerData.identifier)) then
      local blip = AddBlipForCoord(v.Entry.x, v.Entry.y, v.Entry.z)
      SetBlipDisplay              (blip, 4)
      SetBlipScale                (blip, 0.35)
      SetBlipColour               (blip, 4)
      SetBlipSprite               (blip, 350)
      SetBlipColour               (blip, 4)
      SetBlipAsShortRange         (blip, true)
      SetBlipHighDetail           (blip, true)
      BeginTextCommandSetBlipName ("STRING")
      if v.owner and tostring(v.owner) == tostring(self.PlayerData.identifier) then
        AddTextComponentString("Casa Detinuta")
        SetBlipSprite(blip, 40)
      elseif not v.owner then -- oprit
        AddTextComponentString("Casa de vanzare")
      else
        AddTextComponentString("Casa Cumparata")
        SetBlipSprite(blip, 374)
        SetBlipColour(blip, 1)
      end
      EndTextCommandSetBlipName   (blip)
      table.insert(self.Blips,blip)
    end
  end
end

local sleeping = false
RegisterCommand("sleep", function()
  if housing.CurHouse then
    if not sleeping then
      sleeping = true
      TriggerServerEvent("vrp-housing:startSleeping")
      ExecuteCommand("e sleep")

      local initialPos = GetEntityCoords(PlayerPedId())
      FreezeEntityPosition(PlayerPedId(), true)
      SetEntityInvincible(PlayerPedId(), true)
      Citizen.CreateThread(function()
        while sleeping do
          local pos = GetEntityCoords(PlayerPedId())
          if Vdist(pos.x, pos.y, pos.z, initialPos.x, initialPos.y, initialPos.z) >= 3.0 then
            SetEntityCoords(PlayerPedId(), initialPos)
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityInvincible(PlayerPedId(), true)
          end
          Citizen.Wait(5000)
        end
      end)

    else
      sleeping = false
      FreezeEntityPosition(PlayerPedId(), false)
      SetEntityInvincible(PlayerPedId(), false)
      ExecuteCommand("e c")
      TriggerServerEvent("vrp-housing:stopSleeping")
    end
  else
    vRP.sendInfo("Trebuie sa fi intr-o casa pentru a putea dormi.")
  end
end)

function housing:Update()
  local isOwned,lastHouse,lastAct,onLast
  local text = "Press [E] to buy this house."

  self.updateInProgress = false
  Citizen.Wait(500)
  self.updateInProgress = true

  while self.updateInProgress do
    local ticks = 1000

    self.ClearLast = false -- checkVeh (it was)    

    if self.ClearLast then
      lastHouse = false
      lastAct = false
      isOwned = false
      text = false
      self.ClearLast = false
    else
      if not self.CurHouse then
        local closest,closestDist,closestAct,closestPos = self:GetClosestAction()

        if not closest then
          Citizen.Wait(500)
        end

        if closestDist and closestDist < self.DrawTextDist then
          ticks = 1
          --if not lastHouse or not lastAct or lastHouse ~= closest.id or closestAct ~= lastAct then
            text,isOwned,lastAct,lastHouse,hasKeys,hasRent = self:GetActionInfo(closest,closestAct)
          --end
          draw3DText(closestPos, text, 0.7)

          if text ~= '' then
            if closestAct == "Entry" then

              if not isOwned and not hasKeys then
                if closest.rentPriceStr and not hasRent then
                  draw3DText(closestPos, "~n~~n~~n~~n~[~g~H~w~] Inchiriaza $~g~"..closest.rentPriceStr.."~w~/7 zile", 0.7)
                  if IsDisabledControlJustPressed(0, 104) then -- H
                    TriggerServerEvent("vrp-housing:tryToRent", closest.id)
                  end
                elseif hasRent then
                  draw3DText(closestPos, "~n~~n~~n~~n~Chiria expira pe ~g~"..hasRent, 0.7)
                end
              end

            elseif closestAct == "Garage" then

              DrawMarker(36, closestPos.x, closestPos.y, closestPos.z + 0.2, 0, 0, 0, 0, 0, 0, 0.501, 0.501, 0.5001, 235, 33, 19, 200, 0, 0, 0, 1)
            end
          end

          if closestDist < self.InteractDist then
            if IsDisabledControlJustPressed(0, 38) then
              self:DoAction(closest,closestAct,isOwned,hasKeys,hasRent)
            end
            if IsDisabledControlJustPressed(0, 58) then
              self:DoSecondary(closest,closestAct,isOwned,hasKeys)
            end
          end
        else
          self.ClearLast = true
        end
      elseif not sleeping then
        ticks = 1
        if self.GiveKeysNow then
          self:GiveKeys(lastHouse,isOwned,self.GiveKeysNow)
          self.GiveKeysNow = false
        end

        if self.TakeKeysNow then
          self:TakeKeys(lastHouse,isOwned,self.TakeKeysNow)
          self.TakeKeysNow = false
        end

        if self.SetWardrobe and IsDisabledControlJustPressed(0, 38) then
          self:PlaceWardrobe(lastHouse,isOwned)
          self.SetWardrobe = false
        end

        if self.SetChest and IsDisabledControlJustPressed(0, 38) then
          self:PlaceChest(lastHouse,isOwned)
          self.SetChest = false
        end

        local plyPos = GetEntityCoords(PlayerPedId())
        local pos = self.CurHouse.wardrobe
        local tryChest = true
        if pos then
          local dist = Vdist(pos.x,pos.y,pos.z, plyPos.x,plyPos.y,plyPos.z)
          if dist and dist < (self.DrawTextDist/2) then
            draw3DText(pos, "Apasa [~r~E~s~] pentru garderoba", 0.7)
            if dist < self.InteractDist and IsDisabledControlJustPressed(0, 38) then
              TriggerServerEvent("vrp-housing:enterWarderobe")
              tryChest = false
            end
          end
        end

        if tryChest then
          local tryDoor = true
          local cpos = self.CurHouse.chest
          if cpos then
            local dist = Vdist(cpos.x,cpos.y,cpos.z, plyPos.x,plyPos.y,plyPos.z)
            if dist and dist < (self.DrawTextDist/2) then
              draw3DText(cpos, "Apasa [~r~E~s~] pentru cufar", 0.7)
              if dist < self.InteractDist and IsDisabledControlJustPressed(0, 38) then
                svRP.openHouseChest({self.CurHouse.id})
                tryDoor = false
              end
            end
          end
          
          if tryDoor then
            local txt = "Apasa [~r~E~s~] pentru a iesi."
            local pos = self.CurHouse.exit
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, plyPos.x, plyPos.y, plyPos.z, false)
            if dist then
              if dist < (self.DrawTextDist/2) then
                if tostring(self.CurHouse.owner) == tostring(self.PlayerData.identifier) then
                  txt = txt .. "\nApasa [~r~G~s~] pentru meniu locuinta"
                end
                draw3DText(pos, txt, 0.7)
                if dist < self.InteractDist then
                  if IsDisabledControlJustPressed(0, 38) then
                    self:LeaveHouse()
                    Wait(500)
                  elseif string.find(txt, "~G~") and IsDisabledControlJustPressed(0, 58) then
                    svRP.openHouseMenu({self.CurHouse.id})
                    Wait(500)
                  end
                end
              elseif dist > 40.0 then
                self:LeaveHouse()
                Wait(500)
              end
            end
          end
        end
      end
    end
    Citizen.Wait(ticks)
  end
end

function housing:GetActionInfo(closest,closestAct)
  local text,isOwned,lastAct,lastHouse,hasKeys,hasRent
  if closestAct == "Entry" then
    if closest.owner and tostring(closest.owner) == tostring(self.PlayerData.identifier) then
      text = "Nr. ~r~"..closest.id.."\n~w~[~r~E~s~] intra in casa\n[~r~G~s~] seteaza garaj"
      isOwned = true
    elseif closest.owner and tostring(closest.owner) ~= tostring(self.PlayerData.identifier) then
      if self.PlayerData.job and self.PlayerData.job.name == "Politie" and self.copsRush then
        text = "Nr. ~r~"..closest.id.."\n~w~Proprietar ~r~"..closest.owner.."\n~w~[~r~E~s~] Bate la usa\n[~r~G~s~] Intra cu mandat de perchezitie."
      else
        text = "Nr. ~r~"..closest.id.."\n~w~Proprietar ~r~"..closest.owner.."\n~w~[~r~E~s~] Bate la usa"
      end
      isOwned = false
    else
      text = "Nr. ~r~"..closest.id.."\n~w~["..(closest.Premium and "FC " or "$").."~r~"..closest.PriceStr.."~s~] [~r~E~s~] Cumpara casa"
      isOwned = false
    end

    if closest.keys then
      text = "Nr. ~r~"..closest.id.."\n~w~Proprietar ~r~"..closest.owner.."\n~w~[~r~E~s~] Intra in casa"
      hasKeys = true
    end

    if closest.rent then
      text = "Nr. ~r~"..closest.id.."\n~w~Proprietar ~r~"..closest.owner.."\n~w~[~r~E~s~] Intra in casa"
      hasRent = closest.rent
    end

  elseif closestAct == "Garage" then
    if closest.owner and (tostring(closest.owner) == tostring(self.PlayerData.identifier) or closest.keys or closest.rent) then
      if not IsPedInAnyVehicle(PlayerPedId()) then
        text = "Apasa [~r~E~s~] pentru a folosii garajul."
      end
      isOwned = true
    else
      text = ''
      isOwned = false
    end

  else
    text = ''
    isOwned = ''
  end
  lastAct = closestAct
  lastHouse = closest.id
  return text,isOwned,lastAct,lastHouse,hasKeys,hasRent
end

function housing:DoAction(closest,closestAct,isOwned,hasKeys,hasRent)
  if closestAct == "Entry" then
    if isOwned or hasKeys or hasRent then
      self:EnterHouse(closest.Entry,closest)
    else
      if not closest.owner then
        self:BuyHouse(closest.id)
      else
        self:KnockOnDoor(closest)
      end
    end
  elseif closestAct == "Garage" then
    if isOwned or hasKeys or hasRent then
      TriggerServerEvent("vrp-housing:tryUseGarage", closest.id)
    end
  end
end

function housing:DoSecondary(closest,closestAct,isOwned,hasKeys)
  if closestAct == "Entry" then
    if isOwned then
      vRP.notify("Apasa E pentru a seta garajul.")
      while not IsDisabledControlJustPressed(0, 38) do
        Citizen.Wait(1)
      end

      local pos = GetEntityCoords(PlayerPedId())

      if Vdist(pos.x, pos.y, pos.z, closest.Entry.x, closest.Entry.y, closest.Entry.z) <= 40.0 then
        TriggerServerEvent("vrp-housing:setGaragePos", closest.id, pos)
        vRP.notify("Ai setat noua pozitie a garajului")
      else
        vRP.notify("Esti prea departe de casa ta", "error")
      end

    elseif self.copsRush and self.PlayerData.job.name == "Politie" and closest.owner then
      self:EnterHouse(closest.Entry, closest)
    end
  end
end

function housing:GetClosestAction()
  local pos = GetEntityCoords(PlayerPedId())
  local closest,closestDist,closestAct,closestPos
  for k,v in pairs(self.HouseData) do
    local entryDist = Vdist(v.Entry.x,v.Entry.y,v.Entry.z, pos.x,pos.y,pos.z)
    if not closestDist or entryDist < closestDist then
      closestDist = entryDist
      closest = v
      closestAct = "Entry"
      closestPos = v.Entry
    end

    if v.Garage then
      local garageDist = Vdist(v.Garage.x,v.Garage.y,v.Garage.z, pos.x,pos.y,pos.z)
      if not closestDist or garageDist < closestDist then
        closestDist = garageDist
        closest = v
        closestAct = "Garage"
        closestPos = v.Garage
      end
    end
  end
  if not closestDist then return false,999999,false,false
  else return closest,closestDist,closestAct,closestPos
  end
end

function playerhousing:Teleport(x,y,z,h,enter)
  local self = housing
  self:FadeScreen(false,500,true)

  SetEntityCoords(PlayerPedId(), x, y, z, 0, 0, 0, false)
  SetEntityHeading(PlayerPedId(), h)

  FreezeEntityPosition(PlayerPedId(), true)
  Citizen.CreateThread(function()
    Citizen.Wait(3000)
    FreezeEntityPosition(PlayerPedId(), false)
  end)

  Citizen.Wait(2000)

  self:FadeScreen(true,1000,true)
end

function housing:EnterHouse(pos,house)
  self.LastPos = pos

  local pos = vector4(pos.x,pos.y,pos.z+100.0,pos.w)

  self.CurHouse = createHouseShell(pos, house.Class)

  if self.CurHouse then

    self:Teleport(self.CurHouse.exit.x,self.CurHouse.exit.y,self.CurHouse.exit.z, self.CurHouse.exit.w, true)
    self.CurHouse.owner = house.owner

    svRP.getHouseBigData({house.id}, function(houseBigData)
      
      self.CurHouse.wardrobe = (houseBigData.wardrobe or false)
      self.CurHouse.chest = (houseBigData.chest or false)

      self.CurHouse.id = house.id
      self.CurHouse.keys = (house.keys or false)

      if tostring(self.CurHouse.owner) == tostring(self.PlayerData.identifier) or self.CurHouse.keys then
        vRP.notify("Apasa F pentru a edita mobilierul.")
      end

      TriggerEvent('playerhousing:Entered', pos, house.id, houseBigData.furniture, house.owner, house.keys or false)
      TriggerServerEvent('playerhousing:Enter',house.id)

    end)
    
  else
    vRP.notify("Din pacate a aparut o eroare la incarcarea locuintei", "error")
  end
end

function housing:LeaveHouse()
  if not self.LastPos or not self.CurHouse then return; end
  local pos = self.LastPos
  self:Teleport(pos.x,pos.y,pos.z-1.0,pos.w)
  if self.CurHouse then
    self:DespawnInterior(self.CurHouse.objects)
  end
  self.LastPos = nil
  self.CurHouse = nil
  TriggerEvent('playerhousing:Leave')
  TriggerServerEvent('playerhousing:Leave')       
end

function housing:GoToDoor(house)
  local p = house.Entry
  local plyPed = PlayerPedId()
  TaskGoStraightToCoord(plyPed, p.x, p.y, p.z, 10.0, 10, p.w, 0.5)
  local dist = 999
  local tick = 0
  while dist > 0.5 and tick < 10000 do
    local pPos = GetEntityCoords(plyPed)
    dist = Vdist(pPos.x,pPos.y,pPos.z, p.x,p.y,p.z)
    tick = tick + 1
    Citizen.Wait(100)  
  end
  ClearPedTasksImmediately(plyPed)
end

function housing:KnockOnDoor(house)
  if tonumber(house.owner) and tonumber(house.id) then
    self:GoToDoor(house)
    local plyPed = PlayerPedId()
    while not HasAnimDictLoaded("timetable@jimmy@doorknock@") do RequestAnimDict("timetable@jimmy@doorknock@"); Citizen.Wait(0); end
    TaskPlayAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 4, 0, 0, 0, 0 )     
    Citizen.Wait(0)
    while IsEntityPlayingAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 3) do 
      Citizen.Wait(0)
    end
    TriggerServerEvent('playerhousing:KnockOnDoorX', tonumber(house.owner), tonumber(house.id))
    vRP.notify("Ai batut la usa.")
  end
end

function housing:FadeScreen(fadeIn,time,wait)
  if not time then time = 500; end
  if fadeIn then DoScreenFadeIn(time)
  else DoScreenFadeOut(time); end
  if wait then 
    if fadeIn then
      while not IsScreenFadedIn() do Citizen.Wait(0); end; 
    else
      while not IsScreenFadedOut() do Citizen.Wait(0); end; 
    end
  end
end

function housing:DespawnInterior(objects)
  for k, v in pairs(objects) do
    if DoesEntityExist(v) then
      DeleteEntity(v)
    end
  end
end

function housing:BuyHouse(closestId)
	TriggerServerEvent('playerhousing:BuyHouse', closestId)
	self.ClearLast = true

	Citizen.Wait(5000)
	self:RefreshBlips()
end

function housing:PlayerKnocked(player, houseId)
  if self.CurHouse and self.CurHouse.owner and (tostring(self.CurHouse.owner) == tostring(self.PlayerData.identifier) or self.CurHouse.keys) then
    vRP.notify("Cineva a batut la usa [ID: "..tostring(player).."]\nApasa H pentru a accepta.")
    local timer = GetGameTimer()
    while GetGameTimer() - timer < 10 * 1000 do
      if IsDisabledControlJustPressed(0, 74) then
        svRP.teleportInsideHouse({player, houseId})
        Wait(500)
        return
      end
      Citizen.Wait(0)
    end
  end
end

function housing:PlaceWardrobe(id,owner)
  if not self.CurHouse then
    vRP.notify("Trebuie sa fii intr-o casa")
  else
    if owner then
      local pos = GetEntityCoords(PlayerPedId())
      local tPos = vector3(pos.x,pos.y,pos.z+0.3)
      self.CurHouse.wardrobe = tPos
      vRP.notify("Ai setat garderoba")
      TriggerServerEvent('playerhousing:SetWardrobe',id,tPos)
    else
      vRP.notify("Nu detii aceasta casa")
    end
  end
end

function housing:PlaceChest(id,owner)
  if not self.CurHouse then
    vRP.notify("Trebuie sa fii intr-o casa")
  else
    if owner then
      local pos = GetEntityCoords(PlayerPedId())
      local tPos = vector3(pos.x,pos.y,pos.z+0.3)
      self.CurHouse.chest = tPos
      vRP.notify("Ai setat cufarul")
      TriggerServerEvent('playerhousing:SetChest',id,tPos)
    else
      vRP.notify("Nu detii aceasta casa")
    end
  end
end

function housing:GiveKeys(id,owner,target)
  if not self.CurHouse or not owner then return; end
  vRP.notify("I-ai oferit un set de chei")
  TriggerServerEvent('playerhousing:GiveKeys', target, id)
end

function housing:GotKey(id)
  vRP.notify("Proprietarul ti-a oferit un set de chei")
  self.HouseData[id].keys = true
  self.ClearLast = true
end

function housing:TakeKeys(id,owner,target)
  if not self.CurHouse or not owner then return; end
  vRP.notify("Ai luat cheile de la casa.")
  TriggerServerEvent('playerhousing:TakeKeys', target, id)
end

function housing:TookKey(id)
  vRP.notify("Ti s-a luat cheile de la casa.")
  self.HouseData[id].keys = nil
  self.ClearLast = true
end

RegisterNetEvent('playerhousing:SyncHouse')
AddEventHandler('playerhousing:SyncHouse', function(houseData)
  housing.HouseData[houseData.id] = houseData

  svRP.getKeys({}, function(keys)
    housing.Keys = keys
    for k, v in pairs(housing.Keys or {}) do
      if housing.HouseData[v.house] then
        housing.HouseData[v.house].keys = true
      end
    end
  end)

  svRP.getRents({}, function(rents)
    housing.Rents = rents
    for k, v in pairs(housing.Rents or {}) do
      if housing.HouseData[v.house] then
        housing.HouseData[v.house].rent = v.formated
      end
    end
  end)
  
end)

RegisterNetEvent('playerhousing:LeaveHouse')
AddEventHandler('playerhousing:LeaveHouse', function() housing:LeaveHouse(); end)

RegisterNetEvent('playerhousing:GiveKey')
AddEventHandler('playerhousing:GiveKey', function(...) housing:GotKey(...); end)

RegisterNetEvent('playerhousing:TakeKey')
AddEventHandler('playerhousing:TakeKey', function(...) housing:TookKey(...); end)

RegisterNetEvent('vrp-housing:GiveKeys')
AddEventHandler('vrp-housing:GiveKeys', function() housing.DoGiveKeys = true; end)

RegisterNetEvent('vrp-housing:TakeKeys')
AddEventHandler('vrp-housing:TakeKeys', function() housing.DoTakeKeys = true; end)

RegisterNetEvent('vrp-housing:setGarderoba')
AddEventHandler('vrp-housing:setGarderoba', function() housing.SetWardrobe = true; end)

RegisterNetEvent('vrp-housing:setChest')
AddEventHandler('vrp-housing:setChest', function() housing.SetChest = true; end)

RegisterNetEvent('playerhousing:PlayerKnocked')
AddEventHandler('playerhousing:PlayerKnocked', function(player, houseId) housing:PlayerKnocked(player, houseId); end)

RegisterNetEvent('playerhousing:EnterHouse')
AddEventHandler('playerhousing:EnterHouse', function(...) housing:EnterHouse(...); end)

Citizen.CreateThread(function()
  local ready = false
  svRP.getUserSuperData({}, function(theData)
    housing.PlayerData = theData
    housing.HouseData = {}
    ready = true
  end)
  while not ready do Citizen.Wait(50) end
  TriggerServerEvent('playerhousing:Start')
end)

Citizen.CreateThread(function() 
  local allPlayers = false
  local selectedPlayer = false  

  local scaleform = RequestScaleformMovie("instructional_buttons")
  while not HasScaleformMovieLoaded(scaleform) do
      Citizen.Wait(0)
  end
  PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
  PopScaleformMovieFunctionVoid()
  
  PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
  PushScaleformMovieFunctionParameterInt(200)
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(0)
  N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 174, true))

  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform("Inainte")
  EndTextCommandScaleformString()

  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(1)
  N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 175, true))

  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform("Urmator")
  EndTextCommandScaleformString()

  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(2)
  N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 191, true))

  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform("Alege Jucator")
  EndTextCommandScaleformString()

  PopScaleformMovieFunctionVoid()


  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(3)
  N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 200, true))

  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform("Cancel")
  EndTextCommandScaleformString()

  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(80)
  PopScaleformMovieFunctionVoid()

  while true do
    if housing.CurHouse and housing.CurHouse.owner and tostring(housing.CurHouse.owner) == tostring(housing.PlayerData.identifier) and (housing.DoGiveKeys or housing.DoTakeKeys) then
      if not allPlayers then
        allPlayers = GetPlayersInArea(GetEntityCoords(PlayerPedId()), 20.0)
      else
        if not selectedPlayer then selectedPlayer = 1; end
        local pos = GetEntityCoords(GetPlayerPed(allPlayers[selectedPlayer]))
        local r = 0
        local g = 0
        if housing.DoGiveKeys then
          g = 255
        else
          r = 255
        end

        if IsDisabledControlJustPressed(0, 174) then
          selectedPlayer = selectedPlayer + 1
          if selectedPlayer > #allPlayers then
            selectedPlayer = 1
          end
        end

        if IsDisabledControlJustPressed(0, 175) then
          selectedPlayer = selectedPlayer - 1
          if selectedPlayer < 1 then
            selectedPlayer = #allPlayers
          end
        end

        if IsDisabledControlJustPressed(0, 200) then
          housing.DoGiveKeys = false
          housing.DoTakeKeys = false
          allPlayers = false
          selectedPlayer = false
        end

        if IsDisabledControlJustPressed(0, 191) then
          if allPlayers[selectedPlayer] == PlayerId() then 
          elseif housing.DoTakeKeys then
            housing.TakeKeysNow = GetPlayerServerId(allPlayers[selectedPlayer])
          else            
            housing.GiveKeysNow = GetPlayerServerId(allPlayers[selectedPlayer])
          end

          housing.DoGiveKeys = false
          housing.DoTakeKeys = false
          allPlayers = false
          selectedPlayer = false
        end

        DrawMarker(0, pos.x,pos.y,pos.z + 1.2, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.2,0.2,0.2, r,g,0,255, true, true, 2, false,false,false,false)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
      end
    else
      housing.DoGiveKeys = false
      housing.DoTakeKeys = false
      allPlayers = false
      selectedPlayer = false
      Citizen.Wait(1000)
    end
    Citizen.Wait(1)
  end
end)


--[[ restart housing
	
Citizen.CreateThread(function()

	TriggerServerEvent('playerhousing:Start', false)
	Citizen.Wait(500)
	TriggerEvent("vrp-housing:startDone", {})
end)

--]]