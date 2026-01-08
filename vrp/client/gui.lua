local inEvent = false

function tvRP.toggleInEvent()
  inEvent = not inEvent
end

function tvRP.setInEvent(flag)
  if inEvent ~= flag then
    tvRP.toggleInEvent()
  end
end

function tvRP.isInEvent()
  return inEvent
end

local focus = false
exports("isUiFocused", function()
  return focus
end)

RegisterNetEvent("vrp:interfaceFocus")
AddEventHandler("vrp:interfaceFocus", function(stateTbl, keepInput)
	if type(stateTbl) == "table" then
		SetNuiFocus(stateTbl[1], stateTbl[2])
  else
    SetNuiFocus(stateTbl, stateTbl)
  end

  focus = stateTbl

  SetNuiFocusKeepInput(keepInput)
end)

RegisterNetEvent("vrp:sendNuiMessage", function(...)
  SendNUIMessage(...)
end)

function runjs(code)
  SendNUIMessage({eval = code})
end
exports("runjs", runjs)

RegisterNetEvent("vrp-hud:runjs", runjs)

RegisterNUICallback("setFocus", function(data, cb)
  TriggerEvent("vrp:interfaceFocus", table.unpack(data))

  cb('ok')
end)

RegisterNUICallback("setGameBlur", function(data, cb)
  if data[1] then
    TriggerScreenblurFadeIn(100)
  else
    TriggerScreenblurFadeOut(100)
  end

  cb('ok')
end)


AddEventHandler("vRP:pauseChange", function(paused)
  SendNUIMessage({act="pause_change", paused=paused})
end)

function tvRP.openMenuData(menudata)
  SendNUIMessage({act="open_menu", menudata = menudata})
end

function tvRP.closeMenu()
  SendNUIMessage({act="close_menu"})
  -- TriggerEvent("vrp:interfaceFocus", false)
end

local keepSelectorFocus = false

local keepPromptFocus, keepRequestFocus = false, false
local cbPrompt = false
function tvRP.prompt(title,description,response,keepFocus,cb)
  keepPromptFocus = keepFocus
  SendNUIMessage({interface="prompt",title=title,description=description,text=response})
  TriggerEvent("vrp:interfaceFocus", true)
  -- SetCursorLocation(0.5, 0.5)

  if type(cb) == "function" or cb then
    cbPrompt = cb
end; end

local waitingRequestResult, okRequest = false, false
function tvRP.request(id,text,title,keepFocus, cb)
  SendNUIMessage({interface="dialog",id=id,description=tostring(text),title=title})
  -- tvRP.playSound("HUD_MINI_GAME_SOUNDSET","5_SEC_WARNING")
  SetCursorLocation(0.5, 0.5)
  TriggerEvent("vrp:interfaceFocus", true, true)
  waitingRequestResult = true
  keepRequestFocus = keepFocus

  if id == "client" then
    okRequest = cb
  end

  while waitingRequestResult do
    DisableControlAction(0, 24, true) -- disable attack
		DisableControlAction(0, 25, true) -- disable aim
		DisableControlAction(0, 1, true) -- disable mouse look
		DisableControlAction(0, 2, true) -- disable mouse look
		DisableControlAction(0, 3, true) -- disable mouse look
		DisableControlAction(0, 4, true) -- disable mouse look
		DisableControlAction(0, 5, true) -- disable mouse look
		DisableControlAction(0, 6, true) -- disable mouse look
		DisableControlAction(0, 263, true) -- disable melee
		DisableControlAction(0, 264, true) -- disable melee
		DisableControlAction(0, 257, true) -- disable melee
		DisableControlAction(0, 140, true) -- disable melee
		DisableControlAction(0, 141, true) -- disable melee
		DisableControlAction(0, 142, true) -- disable melee
		DisableControlAction(0, 143, true) -- disable melee
		DisableControlAction(0, 177, true) -- disable escape
		DisableControlAction(0, 199, true) -- disable escape
		DisableControlAction(0, 200, true) -- disable escape
		DisableControlAction(0, 202, true) -- disable escape
		DisableControlAction(0, 322, true) -- disable escape
		DisableControlAction(0, 245, true) -- disable chat
    Citizen.Wait(1)
  end
end

exports("request", function(...)
  tvRP.request("client", ...)
end)

RegisterNUICallback("request", function(data, cb)
  exports.vrp:request(data[1], data[2], data[3], function(result)
    cb(result)
  end)
end)


exports("prompt", function(...)
  tvRP.prompt(...)
end)

RegisterNUICallback("prompt", function(data, cb)
  exports.vrp:prompt(data[1],data[2],data[3],data[4],function(result)
    cb(result)
  end)
end)

RegisterNetEvent("vrp-hud:showBind", function(data)
  if type(data) == "table" then

    PlaySoundFrontend(-1, "INFO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    SendNUIMessage({
      interface = "bindsList",
      event = "add",

      key = data.key,
      text = data.text or "Interact",
    })

    return
  end

  SendNUIMessage({
    interface = "bindsList",
    event = "hide",
  })
end)

RegisterNUICallback("menu",function(data,cb)
  if data.act == "close" then
    vRPserver.closeMenu({data.id})
  elseif data.act == "valid" then
    vRPserver.validMenuChoice({data.id,data.choice,data.mod})
  end

  cb("ok")
end)

RegisterNUICallback("result:prompt",function(data,cb)
  if cbPrompt then
    cbPrompt(data[1])
  else  
    TriggerServerEvent("vRP:promptResult", data[1])
  end
  cbPrompt = false
  
  if not keepPromptFocus then
    TriggerEvent("vrp:interfaceFocus", false)
  end

  cb("ok")
end)

-- gui request event
RegisterNUICallback("result:request",function(data,cb)
  if data[1] == "client" then
    
    if okRequest then
      okRequest(data[2])
    end
    okRequest = false
  else
    TriggerServerEvent("vRP:requestResult", data[1], data[2])
  end
  
  if not keepRequestFocus then
    TriggerEvent("vrp:interfaceFocus", false, false)
  end
  SetNuiFocusKeepInput(false)

  waitingRequestResult = false
  cb("ok")
end)

RegisterNetEvent("vrp:progressBar", function(...)
  exports.vrp:progressBar(...)
end)

local activeProgress = false

RegisterNUICallback("progressBars:end", function(data, cb)
  if activeProgress.onComplete then
    activeProgress.onComplete()
  end

  if activeProgress.anim then
    
    if activeProgress.anim.scenario then
      ClearPedTasks(tempPed)
    elseif activeProgress.anim.dict and activeProgress.anim.name then
      StopAnimTask(tempPed, activeProgress.anim.dict, activeProgress.anim.name, 1.0)
    end

  end

  activeProgress = false

  cb("ok")
end)

exports("progressBar", function(data, cb)
  data.onComplete = cb
  activeProgress = data

  SendNUIMessage({interface = "progressBars", data = {title = data.text, duration = data.duration}})

  if data.anim then
    local animation = data.anim
    
    if not IsEntityDead(tempPed) then  
        Citizen.CreateThread(function()
            if animation.scenario then
                TaskStartScenarioInPlace(tempPed, animation.scenario, 0, true)
            elseif animation.dict and animation.name then
                RequestAnimDict(animation.dict)
                while not HasAnimDictLoaded(animation.dict) do
                    Citizen.Wait(1)
                end

                TaskPlayAnim(tempPed, animation.dict, animation.name, 3.0, 1.0, -1, (animation.flag or 1), 0, 0, 0, 0)
            end
        end)
    end
  end

  Citizen.CreateThread(function()
    while activeProgress and data.disableControls do

        if data.disableControls.mouse then
          DisableControlAction(1, 1, true)
          DisableControlAction(1, 2, true)
          DisableControlAction(1, 106, true)
        end
        
        if data.disableControls.player then
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 36, true)
        end

        if data.disableControls.vehicle then
            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)
            DisableControlAction(0, 75, true)
        end

        Citizen.Wait(1)

    end
  end)

end)

function tvRP.isPaused()
  return IsPauseMenuActive()
end

local keytable = {
  ["k"] = {
    commandname = "gui_openmainmenu",
    description = "Deschide meniul principal K",
    fnc = function()
      if (not tvRP.isInEvent()) and (not tvRP.isInComa() or not cfg.coma_disable_menu) and (not tvRP.isHandcuffed(true) or not cfg.handcuff_disable_menu) then
      	TriggerServerEvent("vRP:openMainMenu")
      end
    end
  },
  ["F5"] = {
    commandname = "f5_departments",
    description = "Deschide meniu departamente",
    fnc = function()
      TriggerServerEvent("vrp:tryOpenDepartmentMenu")
    end
  },
  ["up"] = {
    commandname = "gui_menuup",
    description = "Key UP",
    fnc = function() 
      SendNUIMessage({act="event",event="UP"})
      CreateThread(function()
        local timer = 0
        while IsControlPressed(table.unpack(cfg.controls.phone.up)) do
          Citizen.Wait(0)
          timer = timer + 1
          if timer > 30 then
            Citizen.Wait(90)
            SendNUIMessage({act="event",event="UP"})
          end
        end
      end)
     end
  },
  ["down"] = {
    commandname = "gui_menudown",
    description = "Key DOWN",
    fnc = function() 
      SendNUIMessage({act="event",event="DOWN"}) 
      CreateThread(function()
        local timer = 0
        while IsControlPressed(table.unpack(cfg.controls.phone.down)) do
          Citizen.Wait(0)
          timer = timer + 1
          if timer > 30 then
          Citizen.Wait(25)
          SendNUIMessage({act="event",event="DOWN"})
          end
        end
      end)
    end
  },
  ["left"] = {
    commandname = "gui_menuleft",
    description = "Key LEFT",
    fnc = function()
    	SendNUIMessage({act="event",event="LEFT"})
    end
  },
  ["right"] = {
    commandname = "gui_menuright",
    description = "Key RIGHT",
    fnc = function()
    	SendNUIMessage({act="event",event="RIGHT"})
	end
  },
  ["return"] = {
    commandname = "gui_menuselect",
    description = "Key SELECT",
    fnc = function()
    	SendNUIMessage({act="event",event="SELECT"})
    end
  },
  ["back"] = {
    commandname = "gui_menuback",
    description = "Key BACK",
    fnc = function()
    	SendNUIMessage({act="event",event="CANCEL"})
    end
  },
  ["Y"] = {
    commandname = "gui_menuacceptrequest",
    description = "Accepta request",
    fnc = function()
    	SendNUIMessage({act="event",event="F5"})
    end
  },
  ["N"] = {
    commandname = "gui_menudenyrequest",
    description = "Respinge request",
    fnc = function()
    	SendNUIMessage({act="event",event="F6"})
	end
  }
}

for k,v in pairs(keytable) do
  RegisterCommand(v.commandname, v.fnc)
  RegisterKeyMapping(v.commandname, v.description, 'keyboard', k)
end

RegisterNUICallback("frontendSound", function(data, cb)
  PlaySoundFrontend(-1, data.dict, data.sound, 1)
  cb("ok")
end)

function tvRP.openSelectorMenu(title, items, keepFocus)
  keepSelectorFocus = keepFocus
  SendNUIMessage({interface = "selector", title = title, items = items})
  TriggerEvent("vrp:interfaceFocus", true)
end

RegisterNUICallback('result:selector', function(data, cb)
  TriggerServerEvent('vRP:selectorResult', data[1])
  
  if not keepSelectorFocus then
    TriggerEvent("vrp:interfaceFocus", false)
  end
  cb('ok')
end)

function tvRP.openActionsMenuData(menudata)
  TriggerEvent("vrp:interfaceFocus", true)
  SendNUIMessage({ interface = "actionsMenu", type = "open_menu", menu = menudata })
end

function tvRP.closeActionsMenu()
  SendNUIMessage({ interface = "actionsMenu", type = "close_menu" })
end

RegisterNUICallback("useHoneycomb",function(data,cb)

  if data[2] then
    vRPserver.validActionsMenuChoice({data[1],data[2]})
  else
    vRPserver.closeActionsMenu({data[1]})
  end

  TriggerEvent("vrp:interfaceFocus", false)

  cb("ok")
end)


Citizen.CreateThread(function()
    while true do

        local ticks = 1000
        local player = tvRP.getNearestPlayer(2.0)

        if player and (playerVehicle == 0) then
            player = GetPlayerFromServerId(player)
            local ped = GetPlayerPed(player)
            
            if HasEntityClearLosToEntity(tempPed, ped, 17) and (not tvRP.isInComa()) then
                local coords = GetEntityCoords(ped)

                DrawText3D(coords.x, coords.y, coords.z, "G", 0.75)

                if IsControlJustReleased(0, 47) then
                    vRPserver.openNearestPlayerMenu({})
                    Citizen.Wait(100)
                end
            end

            ticks = 1
        end
    
        Citizen.Wait(ticks)
    end
end)