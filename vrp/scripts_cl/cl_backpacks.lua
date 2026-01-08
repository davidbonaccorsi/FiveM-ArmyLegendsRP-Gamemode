local lastBag = ""
local bagsData = {
  ["Ghiozdan Mic"] = {
    ["male"] = {
      component = 5,
      drawable = 9,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 26,
      texture = 1,
      default = 0,
    },
  },

  ["Ghiozdan Mediu"] = {
    ["male"] = {
      component = 5,
      drawable = 18,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 25,
      texture = 0,
      default = 0,
    },
  },
  
  ["Ghiozdan Mare"] = {
    ["male"] = {
      component = 5,
      drawable = 109,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 24,
      texture = 1,
      default = 0,
    },
  },
}

local function playToggleEmote(e, cb)
	while not HasAnimDictLoaded(e.Dict) do RequestAnimDict(e.Dict) Wait(100) end
	if IsPedInAnyVehicle(PlayerPedId()) then e.Move = 51 end
	TaskPlayAnim(PlayerPedId(), e.Dict, e.Anim, 3.0, 3.0, e.Dur, e.Move, 0, false, false, false)
    local Pause = e.Dur-500 if Pause < 500 then Pause = 500 end
    Wait(Pause)
    cb()
end

function IsMpPed(ped)
	local Male = GetHashKey("mp_m_freemode_01") local Female = GetHashKey("mp_f_freemode_01")
	local CurrentModel = GetEntityModel(ped)
	if CurrentModel == Male then return "male" elseif CurrentModel == Female then return "female" else return false end
end

AddEventHandler("vrp-inventory:updateBackpack", function(theBag)
  local pedType = IsMpPed(PlayerPedId())

  playToggleEmote({Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200}, function()
    if type(theBag) == "boolean" then
        return SetPedComponentVariation(tempPed, bagsData[lastBag][pedType].component, bagsData[lastBag][pedType].default, 0, 0)
      end
    
      local bagData = bagsData[theBag.name][pedType]
      lastBag = theBag.name
    
      SetPedComponentVariation(tempPed, bagData.component, bagData.drawable, bagData.texture, 1)
  end)
end)