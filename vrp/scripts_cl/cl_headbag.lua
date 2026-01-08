
local theBag = nil

RegisterNetEvent("vrp-headbag:useHeadBag")
AddEventHandler("vrp-headbag:useHeadBag", function()
	if not theBag then
		local model = GetHashKey("prop_money_bag_01")
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end

		Citizen.CreateThread(function()
			theBag = CreateObject(model, pedPos.x, pedPos.y, pedPos.z, true, true, false)
			AttachEntityToEntity(theBag, tempPed, GetPedBoneIndex(tempPed, 12844), 0.2, 0.04, 0, 0, 270.0, 60.0, true, false, false, false, 1, true)
		end)
	end
	
	SendNUIMessage({interface = "headbag", tog = true})
end)

RegisterNetEvent("vrp-headbag:takeOffBag")
AddEventHandler("vrp-headbag:takeOffBag", function()
	if theBag then
		DetachEntity(theBag)
		DeleteObject(theBag)
		theBag = nil

		SendNUIMessage({interface = "headbag", tog = false})
	end
end)
