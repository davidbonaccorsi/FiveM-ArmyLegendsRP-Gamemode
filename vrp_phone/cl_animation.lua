
local phoneProp, phoneModel = 0, `prop_npc_phone_02`
phoneAnim = {}


local function loadAnimation(dict)
	RequestAnimDict(dict)
    
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

function newPhoneProp()
	deletePhoneProp()
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(1)
	end
	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)

	local bone = GetPedBoneIndex(PlayerPedId(), 28422)
	if phoneModel == `prop_cs_phone_01` then
		AttachEntityToEntity(phoneProp, PlayerPedId(), bone, 0.0, 0.0, 0.0, 50.0, 320.0, 50.0, 1, 1, 0, 0, 2, 1)
	else
		AttachEntityToEntity(phoneProp, PlayerPedId(), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
	end
end


function deletePhoneProp()
	if phoneProp ~= 0 then
		DeleteObject(phoneProp)
		phoneProp = 0
	end
end

function startPhoneAnimation(anim)
    local ped = PlayerPedId()
    local animLib = 'cellphone@'
    if IsPedInAnyVehicle(ped, false) then
        animLib = 'anim@cellphone@in_car@ps'
    end

    loadAnimation(animLib)
    TaskPlayAnim(ped, animLib, anim, 3.0, 3.0, -1, 50, 0, false, false, false)
    
    phoneAnim.lib = animLib
    phoneAnim.anim = anim

    Citizen.CreateThread(function()
        while phoneAnim.lib and phoneAnim.anim do
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, phoneAnim.lib, phoneAnim.anim, 3) then
                loadAnimation(phoneAnim.lib)
                TaskPlayAnim(ped, phoneAnim.lib, phoneAnim.anim, 3.0, 3.0, -1, 50, 0, false, false, false)
            end

            Citizen.Wait(500)
        end
    end)
end