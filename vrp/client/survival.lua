function tvRP.varyHealth(variation)
  local n = math.floor(GetEntityHealth(tempPed) + variation)
  if n <= cfg.coma_threshold then return taskInComa() end

  SetEntityHealth(tempPed, n)
end

function tvRP.setHealth(health)
  local n = math.floor(health)
  if n <= cfg.coma_threshold then return taskInComa() end

  SetEntityHealth(PlayerPedId(), n)
  CreateThread(function()
    Wait(1000)
    SetEntityHealth(PlayerPedId(), n)
  end)
end

function tvRP.getHealth()
  return GetEntityHealth(PlayerPedId())
end

function tvRP.setArmour(armour, vest)
  if vest then
    RequestAnimDict("clothingtie")
    while not HasAnimDictLoaded("clothingtie") do
      Wait(1)
    end
    
    TaskPlayAnim(tempPed, "clothingtie", "try_tie_negative_a", 3.0, 3.0, 2000, 01, 0, false, false, false)
  end

  local x = math.floor(armour)
  SetPedArmour(tempPed, x)
end

function tvRP.getArmour()
  return GetPedArmour(tempPed)
end

-- hunger and thirst

local function LoadAnimDict(animDict)
  if not HasAnimDictLoaded(animDict) then
      RequestAnimDict(animDict)

      while not HasAnimDictLoaded(animDict) do
          Citizen.Wait(1)
      end
  end
end

RegisterCommand("survival", function()
  loadAnimDict("amb@code_human_wander_idles@male@idle_a")
  TaskPlayAnim(tempPed, "amb@code_human_wander_idles@male@idle_a", "idle_a_wristwatch", 8.0, 8.0, -1, 48, 0, false, false, false)

  TriggerServerEvent("survival:togShow")

  Wait(10000)

  TriggerServerEvent("survival:togShow")
  
end)

RegisterKeyMapping("survival", "Vezi hunger si thirst", "keyboard", "f1")

-- COMA SYSTEM

local inComa, comaLeft, canRespawn

local comaDuration = cfg.coma_duration * 60000

AddEventHandler('gameEventTriggered', function(event, args)
  if event == 'CEventNetworkEntityDamage' then
    local ped, hasDied = args[1], args[6]
    local pedHealth = GetEntityHealth(ped)

    if not (ped == tempPed) then return end
        
    if hasDied and cfg.coma_threshold >= pedHealth then
      taskInComa()
    end
  end
end)

local function taskComaLeftDecrease()
  comaLeft = GetGameTimer() + comaDuration - 10000

  Citizen.CreateThread(function()
    while inComa do
      local time = GetGameTimer()

      if time >= comaLeft then
        inComa = false
        return
      end

      canRespawn = (time >= comaLeft - comaDuration + (cfg.time_can_respawn * 60000))

      local comaLeftTimer = math.floor((comaLeft - time) / 1000)

      SendNUIMessage({
        interface = "deathscreen",
        event = "setTime",
        time = {math.floor(comaLeftTimer / 60), (comaLeftTimer % 60)}
      })
      
      Citizen.Wait(1024)
    end
  end)
end


-- AddEventHandler('gameEventTriggered', function (name, args)
--   if name == 'CEventNetworkEntityDamage' then
--     local victim, attacker, weaponHash, isMelee = table.unpack(args)
--     local plyPed = PlayerPedId()

--     data = {
--       serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
--       weaponHash = weaponHash
--     }
--     TriggerServerEvent("vl:sendDataAboutWeapon", data)
--   end
-- end)


local inputActive

function taskInComa()
  if inComa then return end

  inComa = true
  TriggerEvent("vrp:playerInComa")

  SetEntityHealth(tempPed, cfg.coma_threshold - 1)

  tvRP.playScreenEffect(cfg.coma_effect, -1)

  SendNUIMessage({
    interface = "deathscreen",
    event = "show"
  })

  TriggerEvent("vrp-hud:updateMap", false)
  TriggerEvent("vrp-hud:setComponentDisplay", {
    serverHud = false,
    minimapHud = false,
  })

  taskComaLeftDecrease()

  Citizen.CreateThread(function()
    while inComa and GetEntityHealth(tempPed) <= cfg.coma_threshold do
      if IsEntityDead(tempPed) then
        local x, y, z = table.unpack(pedPos)
        NetworkResurrectLocalPlayer(x, y, z, true, true)
      end

      SetEntityHealth(tempPed, cfg.coma_threshold)
      SetEntityInvincible(tempPed, true)

      tvRP.ejectVehicle()

      if not tvRP.isRagdoll() then
        tvRP.setRagdoll(1)
      end

      if canRespawn then
        if not inputActive then
          inputActive = true
          TriggerEvent("vrp-hud:showBind", {key = "G", text = "Respawneaza-te"})
        end

        if IsControlJustPressed(0, 47) then
          SetEntityHealth(tempPed, 0)
          break
        end
      end

      Citizen.Wait(1)
    end

    if inputActive then
      inputActive = TriggerEvent("vrp-hud:showBind")
    end

    inComa = false

    SendNUIMessage({
      interface = "deathscreen",
      event = "hide"
    })

    TriggerEvent("vrp-hud:updateMap", true)
    TriggerEvent("vrp-hud:setComponentDisplay", {
      serverHud = true,
      minimapHud = true,
    })

    tvRP.stopScreenEffect(cfg.coma_effect)
    tvRP.setRagdoll()

    ClearPedBloodDamage(tempPed)

    if GetEntityHealth(tempPed) > cfg.coma_threshold then 
      return SetEntityInvincible(tempPed, false)
    end

    SetEntityHealth(tempPed, 0)
    SetEntityInvincible(tempPed, true)

    exports.vrp:spawnPlayer()

    CancelEvent()
  end)
end

function tvRP.isInComa()
  return inComa
end

exports("isInComa", tvRP.isInComa)

function tvRP.toggleComa(state)
  inComa = state
end

function tvRP.killComa()
  comaLeft, inComa = 0
end

local foodPoising, poisingEffect

function tvRP.getIllness()
  return foodPoising
end

exports("getIllness", tvRP.getIllness)

RegisterNetEvent('vrp-survival:foodPoising', function(poising)
  foodPoising = poising

  if not foodPoising and poisingEffect then
    StopScreenEffect(effect)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)

    StopGameplayCamShaking(true)
    poisingEffect = false
  end

  Citizen.CreateThread(function()
    while foodPoising do
      tvRP.varyHealth(-1)

      if math.random(25) > 20 and not poisingEffect then
        local effect = 'PPGreen'
        local waitTime = 65

        poisingEffect = true

        StartScreenEffect(effect, waitTime * 1000, true)
        local duration = GetGameTimer() + (waitTime * 1000)

        while GetGameTimer() < duration and poisingEffect do
          if GetEntityHealth(tempPed) <= 105 then
            break
          end

          Wait(0)
        end

        StopScreenEffect(effect)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)

        StopGameplayCamShaking(true)
        poisingEffect = false 
      end

      if GetEntityHealth(tempPed) <= 105 then
        StopScreenEffect('PPGreen')
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)

        StopGameplayCamShaking(true)
        foodPoising, poisingEffect = false 

        break
      end

      if math.random(10) > 5 then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
        StopGameplayCamShaking(true)

      elseif math.random(100) > 85 and GetGameTimer() > parseInt(threwUp) and not IsPedInAnyVehicle(tempPed) then
        local animDict = 'missfam5_blackout'
        local particleDict = 'cut_paletoscore'
      
        RequestAnimDict(animDict)
        RequestNamedPtfxAsset(particleDict)
      
        while not (HasAnimDictLoaded(animDict) and HasNamedPtfxAssetLoaded(particleDict)) do 
          Wait(1) 
        end

        threwUp = GetGameTimer() + 3600000
        
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
        StopGameplayCamShaking(true)
        
        SetPedToRagdoll(tempPed, 2000, 2000, 0, 0, 0, 0)
      
        DoScreenFadeOut(2000, true)
      
        Wait(12500)
      
        TaskPlayAnim(tempPed, animDict, 'vomit', 2.0, 2.0, -1, 0, 0)
        DoScreenFadeIn(2000, true)
      
        Wait(6500)

        UseParticleFxAsset(particleDict)
        
        local bone = GetPedBoneIndex(tempPed, 47495)
        StartParticleFxNonLoopedOnPedBone('cs_paleto_vomit', tempPed, 0.0, 0.6, 0.0, 0.1, 0.0, 0.0, bone, 1.5)
      end

      Citizen.Wait(60 * 1000 * math.random(3))
    end
  end)
end)