local cfg = module('cfg/clothes')

local player, oldPed

local enabled = false
local cam = false
local customCam = false

local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local prop_names = {"hats", "glasses", "earrings", "mouth", "lhand", "rhand", "watches", "braclets"}
local head_overlays = {"Blemishes","FacialHair","Eyebrows","Ageing","Makeup","Blush","Complexion","SunDamage","Lipstick","MolesFreckles","ChestHair","BodyBlemishes","AddBodyBlemishes"}
local face_features = {"Nose_Width","Nose_Peak_Hight","Nose_Peak_Lenght","Nose_Bone_High","Nose_Peak_Lowering","Nose_Bone_Twist","EyeBrown_High","EyeBrown_Forward","Cheeks_Bone_High","Cheeks_Bone_Width","Cheeks_Width","Eyes_Openning","Lips_Thickness","Jaw_Bone_Width","Jaw_Bone_Back_Lenght","Chimp_Bone_Lowering","Chimp_Bone_Lenght","Chimp_Bone_Width","Chimp_Hole","Neck_Thikness"}
local tatCategory, tattooHashList

local StoreCost = 100
local isService = false
local inputActive = false

Citizen.CreateThread(function()
	for category in pairs(cfg.shops) do
		for index, shop in pairs(cfg.shops[category].coords) do
			local x, y, z = table.unpack(shop)
			local areaStr = string.format("vRP:shops:%s:%d", category, index)

			local blipId, color, name = table.unpack(cfg.shops[category].blip)
			tvRP.addBlip(areaStr, x, y, z, blipId, color, name, 0.5)

			tvRP.setArea(areaStr, x, y, z, 15, {key = "E", text = "Pentru a accesa meniul ($"..StoreCost..")"},
            {
				type = 25,
				x = 1.0,
				y = 1.0,
				z = 0.25,
            	color = {0, 55, 240, 20},
            	coords = {x, y, z},
            },

            function()
				triggerCallback('canPay', function(canPay)
					if not canPay then
						return tvRP.notify('Nu ai destui bani pentru a te putea imbraca!', 'error')
					end

					OpenMenu(category)

					Citizen.CreateThread(function()
						while enabled do
							
							if tvRP.isInComa() then
								LoadPed(oldPed)
								EnableGUI(false)

								break
							end
							
							Citizen.Wait(1024)
						end
					end)

				end, StoreCost, name)
            end)
		end
	end
end)

function RefreshUI()
	hairColors, makeupColors = {}, {}

	for i = 0, GetNumHairColors()-1 do
		local outR, outG, outB= GetPedHairRgbColor(i)
		hairColors[i] = {outR, outG, outB}
	end

	for i = 0, GetNumMakeupColors()-1 do
		local outR, outG, outB= GetPedMakeupRgbColor(i)
		makeupColors[i] = {outR, outG, outB}
	end

	SendNUIMessage({
		type = "colors",
		hairColors = hairColors,
		makeupColors = makeupColors,
		hairColor = GetPedHair()
	})

	SendNUIMessage({
		type = "menutotals",
		drawTotal = GetDrawablesTotal(),
		propDrawTotal = GetPropDrawablesTotal(),
		textureTotal = GetTextureTotals(),
		headoverlayTotal = GetHeadOverlayTotals(),
		skinTotal = GetSkinTotal()
	})

	SendNUIMessage({
		type = "barbermenu",
		headBlend = GetPedHeadBlendData(),
		headOverlay = GetHeadOverlayData(),
		headStructure = GetHeadStructureData()
	})

	SendNUIMessage({
		type = "tattoomenu",
		totals = tatCategory,
		values = GetTats()
	})
	
	SendNUIMessage({
		type = "clothesmenudata",
		drawables = GetDrawables(),
		props = GetProps(),
		drawtextures = GetDrawTextures(),
		proptextures = GetPropTextures(),
		eyeColor = GetPedEyeColor(player),
		skin = GetSkin(),
		oldPed = oldPed
	})
end

function GetSkin()
	for i = 1, #cfg.frm_skins do
		if (GetHashKey(cfg.frm_skins[i]) == GetEntityModel(PlayerPedId())) then
			return {name = "skin_male", value = i}
		end
	end
	
	for i = 1, #cfg.fr_skins do
		if (GetHashKey(cfg.fr_skins[i]) == GetEntityModel(PlayerPedId())) then
			return {name = "skin_female", value = i}
		end
	end
end

function GetDrawables()
	drawables = {}

	local model, mpPed = GetEntityModel(PlayerPedId())
	
	if (model == GetHashKey("mp_f_freemode_01") or model == GetHashKey("mp_m_freemode_01")) then
		mpPed = true
	end

	for i = 0, #drawable_names-1 do
		if mpPed and drawable_names[i+1] == "undershirts" and GetPedDrawableVariation(player, i) == -1 then
			SetPedComponentVariation(player, i, 15, 0, 2)
		end

		drawables[i] = {drawable_names[i+1], GetPedDrawableVariation(player, i)}
	end

	return drawables
end

function GetProps()
	props = {}

	for i = 0, #prop_names-1 do
		props[i] = {prop_names[i+1], GetPedPropIndex(player, i)}
	end

	return props
end

function GetDrawTextures()
	textures = {}

	for i = 0, #drawable_names-1 do
		table.insert(textures, {drawable_names[i+1], GetPedTextureVariation(player, i)})
	end

	return textures
end

function GetPropTextures()
	textures = {}

	for i = 0, #prop_names-1 do
		table.insert(textures, {prop_names[i+1], GetPedPropTextureIndex(player, i)})
	end

	return textures
end

function GetDrawablesTotal()
	drawables = {}

	for i = 0, #drawable_names - 1 do
		drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(player, i)}
	end

	return drawables
end

function GetPropDrawablesTotal()
	props = {}

	for i = 0, #prop_names - 1 do
		props[i] = {prop_names[i+1], GetNumberOfPedPropDrawableVariations(player, i)}
	end

	return props
end

function GetTextureTotals()
	local values = {}
	local draw = GetDrawables()
	local props = GetProps()

	for idx = 0, #draw-1 do
		local name, value = table.unpack(draw[idx])

		values[name] = GetNumberOfPedTextureVariations(player, idx, value)
	end

	for idx = 0, #props-1 do
		local name, value = table.unpack(draw[idx])

		values[name] = GetNumberOfPedPropTextureVariations(player, idx, value)
	end

	return values
end

function SetClothing(drawables, props, drawTextures, propTextures)
	for i = 1, #drawable_names do
		if drawables[0] == nil then
			if drawable_names[i] == "undershirts" and drawables[tostring(i-1)][2] == -1 then
				SetPedComponentVariation(player, i-1, 15, 0, 2)
			else
				if drawTextures[i] and drawables[tostring(i-1)] then
					SetPedComponentVariation(player, i-1, drawables[tostring(i-1)][2], drawTextures[i][2], 2)
				end
			end
		else
			if drawable_names[i] == "undershirts" and drawables[i-1][2] == -1 then
				SetPedComponentVariation(player, i-1, 15, 0, 2)
			else
				SetPedComponentVariation(player, i-1, drawables[i-1][2], drawTextures[i][2], 2)
			end
		end
	end

	for i = 1, #prop_names do
		local propZ = (drawables[0] == nil and props[tostring(i-1)][2] or props[i-1][2])

		ClearPedProp(player, i-1)

		SetPedPropIndex(player, i-1, propZ, propTextures[i][2], true)
	end	
end

function GetSkinTotal()
	return {#cfg.frm_skins, #cfg.fr_skins}
end

local toggleClothing = {}
function ToggleProps(data)
	local name = data["name"]

	selectedValue = has_value(drawable_names, name)

	if (selectedValue > -1) then
		if (toggleClothing[name] ~= nil) then
			SetPedComponentVariation(player, tonumber(selectedValue), tonumber(toggleClothing[name][1]), tonumber(toggleClothing[name][2]), 2)
			toggleClothing[name] = nil
		else
			toggleClothing[name] = {
				GetPedDrawableVariation(player, tonumber(selectedValue)),
				GetPedTextureVariation(player, tonumber(selectedValue))
			}

			local value = -1

			if name == "undershirts" or name == "torsos" then
				value = 15

				if name == "undershirts" and GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
					value = -1
				end
			end

			if name == "legs" then
				value = 14
			end

			SetPedComponentVariation(player, tonumber(selectedValue), value, 0, 2)
		end
	else
		selectedValue = has_value(prop_names, name)
		if (selectedValue > -1) then
			if (toggleClothing[name] ~= nil) then
				SetPedPropIndex(player, tonumber(selectedValue), tonumber(toggleClothing[name][1]), tonumber(toggleClothing[name][2]), true)
				toggleClothing[name] = nil
			else
				toggleClothing[name] = {
					GetPedPropIndex(player, tonumber(selectedValue)),
					GetPedPropTextureIndex(player, tonumber(selectedValue))
				}

				ClearPedProp(player, tonumber(selectedValue))
			end
		end
	end
end

function SaveToggleProps()
	for k in pairs(toggleClothing) do
		local name = k

		selectedValue = has_value(drawable_names, name)

		if (selectedValue > -1) then
			SetPedComponentVariation(player, tonumber(selectedValue), tonumber(toggleClothing[name][1]), tonumber(toggleClothing[name][2]), 2)

			toggleClothing[name] = nil
		else
			selectedValue = has_value(prop_names, name)

			if (selectedValue > -1) then
				SetPedPropIndex(player, tonumber(selectedValue), tonumber(toggleClothing[name][1]), tonumber(toggleClothing[name][2]), true)

				toggleClothing[name] = nil
			end
		end
	end
end

function LoadPed(data)
	if data.model == '1885233650' or tonumber(data.model) == 1885233650 then
		SetSkin('mp_m_freemode_01', true)
	elseif data.model == '-1667301416' or tonumber(data.model) == -1667301416 then
		SetSkin('mp_f_freemode_01', true)
	else 
		SetSkin(data.model, true)
	end

	SetPedEyeColor(player, data.eyeColor)
	
	SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
	Citizen.Wait(500)

	data.hairColor = data.hairColor or {1, 1}
	
	local head = data.headBlend or {}
	local haircolor = data.hairColor or {}
	
	SetPedHeadBlendData(player,
		tonumber(head['shapeFirst']),
		tonumber(head['shapeSecond']),
		tonumber(head['shapeThird']),
		tonumber(head['skinFirst']),
		tonumber(head['skinSecond']),
		tonumber(head['skinThird']),
		tonumber(head['shapeMix']),
		tonumber(head['skinMix']),
		tonumber(head['thirdMix'])
	)
	
	SetHeadStructure(data.headStructure)

	SetPedHairColor(player, tonumber(haircolor[1]), tonumber(haircolor[2]))
	SetHeadOverlayData(data.headOverlay)

	if data.tattooes then
		currentTats = data.tattooes

		SetTats(currentTats)
	end
end

RegisterNetEvent("vrp:loadCharacter", LoadPed);

function GetCurrentPed()
	player = PlayerPedId()

	return {
		model = GetEntityModel(player),
		hairColor = GetPedHair(),
		headBlend = GetPedHeadBlendData(),
		headOverlay = GetHeadOverlayData(),
		headStructure = GetHeadStructure(),
		drawables = GetDrawables(),
		props = GetProps(),
		tattooes = currentTats,
		drawtextures = GetDrawTextures(),
		proptextures = GetPropTextures(),
		eyeColor = GetPedEyeColor(player)
	}
end

tvRP.getCurrentPed = GetCurrentPed

function PlayerModel(data)
	local skins = nil
	if (data['name'] == 'skin_male') then
		skins = cfg.frm_skins
	else
		skins = cfg.fr_skins
	end
	local skin = skins[tonumber(data['value'])]
	rotation(180.0)
	SetSkin(GetHashKey(skin), true)
	Citizen.Wait(1)
	rotation(180.0)
end

local state_ready = false
Citizen.CreateThread(function()
	Citizen.Wait(15000)
	state_ready = true
end)

function SetSkin(model, setDefault)
	SetEntityInvincible(PlayerPedId(), true)

	if IsModelInCdimage(model) and IsModelValid(model) then
		RequestModel(model)
		while (not HasModelLoaded(model)) do
			Citizen.Wait(0)
		end
		local health = tvRP.getHealth()
		SetPlayerModel(PlayerId(), model)
		if state_ready then
			tvRP.setHealth(health)
		end
		SetModelAsNoLongerNeeded(model)

		player = PlayerPedId()

		FreezePedCameraRotation(player, true)

		if setDefault and model ~= nil then
			if (model ~= 'mp_f_freemode_01' and model ~= 'mp_m_freemode_01') then
				SetPedRandomComponentVariation(PlayerPedId(), true)
			else
				SetPedHeadBlendData(player, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
				SetPedComponentVariation(player, 11, 0, 11, 0)
				SetPedComponentVariation(player, 8, 0, 1, 0)
				SetPedComponentVariation(player, 6, 1, 2, 0)
				SetPedHeadOverlayColor(player, 1, 1, 0, 0)
				SetPedHeadOverlayColor(player, 2, 1, 0, 0)
				SetPedHeadOverlayColor(player, 4, 2, 0, 0)
				SetPedHeadOverlayColor(player, 5, 2, 0, 0)
				SetPedHeadOverlayColor(player, 8, 2, 0, 0)
				SetPedHeadOverlayColor(player, 10, 1, 0, 0)
				SetPedHeadOverlay(player, 1, 0, 0.0)
				SetPedHairColor(player, 1, 1)
			end
		end
	end
	SetEntityInvincible(PlayerPedId(), false)
end

RegisterNUICallback('updateclothes', function(data, cb)
	toggleClothing[data["name"]] = nil

	if data["name"] == "eyecolor" then
		SetPedEyeColor(player, tonumber(data["value"]))
	end

	selectedValue = has_value(drawable_names, data["name"])
	
	if (selectedValue > -1) then
		SetPedComponentVariation(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), 2)

		cb({
			GetNumberOfPedTextureVariations(player, tonumber(selectedValue), tonumber(data["value"]))
		})
	else
		selectedValue = has_value(prop_names, data["name"])

		if (tonumber(data["value"]) == -1) then
			ClearPedProp(player, tonumber(selectedValue))
		else
			SetPedPropIndex(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), true)
		end

		cb({
			GetNumberOfPedPropTextureVariations( player, tonumber(selectedValue), tonumber(data["value"]))
		})
	end
end)

RegisterNUICallback('customskin', function(data, cb)
	local dtt = GetHashKey(data)
	if dtt then
		SetSkin(dtt, true)
	end
end)

RegisterNUICallback('setped', function(data, cb)
	PlayerModel(data)
	RefreshUI()
	cb('ok')
end)

RegisterNUICallback('resetped', function(data, cb)
	LoadPed(oldPed)
	cb('ok')
end)


------------------------------------------------------------------------------------------
-- Barber

function GetPedHeadBlendData()
	local blob = string.rep("\0\0\0\0\0\0\0\0", 6 + 3 + 1) -- Generate sufficient struct memory.
	if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, player, blob, true) then -- Attempt to write into memory blob.
		return nil
	end

	return {
		shapeFirst = string.unpack("<i4", blob, 1),
		shapeSecond = string.unpack("<i4", blob, 9),
		shapeThird = string.unpack("<i4", blob, 17),
		skinFirst = string.unpack("<i4", blob, 25),
		skinSecond = string.unpack("<i4", blob, 33),
		skinThird = string.unpack("<i4", blob, 41),
		shapeMix = string.unpack("<f", blob, 49),
		skinMix = string.unpack("<f", blob, 57),
		thirdMix = string.unpack("<f", blob, 65),
		hasParent = string.unpack("b", blob, 73) ~= 0,
	}
end

function SetPedHeadBlend(data)
	SetPedHeadBlendData(player,
		tonumber(data['shapeFirst']),
		tonumber(data['shapeSecond']),
		tonumber(data['shapeThird']),
		tonumber(data['skinFirst']),
		tonumber(data['skinSecond']),
		tonumber(data['skinThird']),
		tonumber(data['shapeMix']),
		tonumber(data['skinMix']),
		tonumber(data['thirdMix'])
	)
end

function GetHeadOverlayData()
	local headData = {}
	
	for i = 1, #head_overlays do
		local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, i-1)
		if retval then
			headData[i] = {}
			headData[i].name = head_overlays[i]
			headData[i].overlayValue = overlayValue
			headData[i].colourType = colourType
			headData[i].firstColour = firstColour
			headData[i].secondColour = secondColour
			headData[i].overlayOpacity = overlayOpacity
		end
	end

	return headData
end

function SetHeadOverlayData(data)
	if json.encode(data) ~= "[]" then
		for i = 1, #head_overlays do
			SetPedHeadOverlay(player, i-1, tonumber(data[i].overlayValue), tonumber(data[i].overlayOpacity))
		end

		SetPedHeadOverlayColor(player, 0, 0, tonumber(data[1].firstColour), tonumber(data[1].secondColour))
		SetPedHeadOverlayColor(player, 1, 1, tonumber(data[2].firstColour), tonumber(data[2].secondColour))
		SetPedHeadOverlayColor(player, 2, 1, tonumber(data[3].firstColour), tonumber(data[3].secondColour))
		SetPedHeadOverlayColor(player, 3, 0, tonumber(data[4].firstColour), tonumber(data[4].secondColour))
		SetPedHeadOverlayColor(player, 4, 2, tonumber(data[5].firstColour), tonumber(data[5].secondColour))
		SetPedHeadOverlayColor(player, 5, 2, tonumber(data[6].firstColour), tonumber(data[6].secondColour))
		SetPedHeadOverlayColor(player, 6, 0, tonumber(data[7].firstColour), tonumber(data[7].secondColour))
		SetPedHeadOverlayColor(player, 7, 0, tonumber(data[8].firstColour), tonumber(data[8].secondColour))
		SetPedHeadOverlayColor(player, 8, 2, tonumber(data[9].firstColour), tonumber(data[9].secondColour))
		SetPedHeadOverlayColor(player, 9, 0, tonumber(data[10].firstColour), tonumber(data[10].secondColour))
		SetPedHeadOverlayColor(player, 10, 1, tonumber(data[11].firstColour), tonumber(data[11].secondColour))
		SetPedHeadOverlayColor(player, 11, 0, tonumber(data[12].firstColour), tonumber(data[12].secondColour))
	end
end

function GetHeadOverlayTotals()
	local totals = {}
	
	for i = 1, #head_overlays do
		totals[head_overlays[i]] = GetNumHeadOverlayValues(i-1)
	end

	return totals
end

function GetPedHair()
	return {
		GetPedHairColor(player),
		GetPedHairHighlightColor(player)
	}
end

function GetHeadStructureData()
	local structure = {}
	for i = 1, #face_features do
		structure[face_features[i]] = GetPedFaceFeature(player, i-1)
	end
	return structure
end

function GetHeadStructure(data)
	local structure = {}
	for i = 1, #face_features do
		structure[i] = GetPedFaceFeature(player, i-1)
	end
	return structure
end

function SetHeadStructure(data)
	for i = 1, #face_features do
		SetPedFaceFeature(player, i-1, data[i])
	end
end

RegisterNUICallback('saveheadblend', function(data, cb)
	SetPedHeadBlendData(player,
	    tonumber(data.shapeFirst),
	    tonumber(data.shapeSecond),
	    tonumber(data.shapeThird),
	    tonumber(data.skinFirst),
	    tonumber(data.skinSecond),
	    tonumber(data.skinThird),
	    tonumber(data.shapeMix) / 100,
	    tonumber(data.skinMix) / 100,
	    tonumber(data.thirdMix) / 100
	)
	
	cb('ok')
end)

RegisterNUICallback('savehaircolor', function(data, cb)
	SetPedHairColor(player, tonumber(data['firstColour']), tonumber(data['secondColour']))
	cb("ok")
end)

RegisterNUICallback('savefacefeatures', function(data, cb)
	local index = has_value(face_features, data["name"])
	if (index <= -1) then return end
	local scale = tonumber(data["scale"]) / 100
	SetPedFaceFeature(player, index, scale)
	cb('ok')
end)

RegisterNUICallback('saveheadoverlay', function(data, cb)
	local index = has_value(head_overlays, data["name"])

	SetPedHeadOverlay(player, index, tonumber(data["value"]), tonumber(data["opacity"]) / 100)

	cb('ok')
end)

RegisterNUICallback('saveheadoverlaycolor', function(data, cb)
	local index = has_value(head_overlays, data["name"])
	local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, index)
	local sColor = tonumber(data['secondColour'])

	if (sColor == nil) then
		sColor = tonumber(data['firstColour'])
	end
	SetPedHeadOverlayColor(player, index, colourType, tonumber(data['firstColour']), sColor)
	cb('ok')
end)
----------------------------------------------------------------------------------
-- UTIL SHIT

function has_value (tab, val)
	for index = 1, #tab do
		if tab[index] == val then
			return index-1
		end
	end
	return -1
end

function EnableGUI(enable, menu)
	enabled = enable

	TriggerEvent("vrp-hud:updateMap", not enable)
	TriggerEvent("vrp-hud:setComponentDisplay", {
		serverHud = not enable,
		minimapHud = not enable,
		bottomRightHud = not enable,
		chat = not enable
	})

	SetNuiFocus(enable, enable)
	SendNUIMessage({
		type = "enableclothesmenu",
		enable = enable,
		menu = menu,
		isService = isService,
	})

	if (not enable) then
		SaveToggleProps()
		oldPed = {}
	end
end

function CustomCamera(position)
	if customCam or position == "torso" then
		FreezePedCameraRotation(player, false)
		SetCamActive(cam, false)
		RenderScriptCams(false,  false,  0,  true,  true)
		if (DoesCamExist(cam)) then
			DestroyCam(cam, false)
		end
		customCam = false
	else
		if (DoesCamExist(cam)) then
			DestroyCam(cam, false)
		end

		local pos = GetEntityCoords(player, true)
		SetEntityRotation(player, 0.0, 0.0, 0.0, 1, true)
		FreezePedCameraRotation(player, true)

		cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
		SetCamCoord(cam, player)
		SetCamRot(cam, 0.0, 0.0, 0.0)

		SetCamActive(cam, true)
		RenderScriptCams(true,  false,  0,  true,  true)

		SwitchCam(position)
		customCam = true
	end
end

function rotation(dir)
	local pedRot = GetEntityHeading(PlayerPedId())+dir
	SetEntityHeading(PlayerPedId(), pedRot % 360)
end

function TogRotation()
	local pedRot = GetEntityHeading(PlayerPedId())+90 % 360
	SetEntityHeading(PlayerPedId(), math.floor(pedRot / 90) * 90.0)
end

function SwitchCam(name)
    if name == "cam" then
        TogRotation()
        return
    end

    player = PlayerPedId()

    local pos = GetEntityCoords(player, true)
    local bonepos = false
    
    if inCreateCharacter then
        FreezeEntityPosition(player, true)
    end

    if inCreateCharacter then
        if (name == "head") then
            bonepos = GetPedBoneCoords(player, 31086)
            bonepos = vector3(bonepos.x, bonepos.y - 0.4, bonepos.z + 0.05)
        end
        if (name == "torso") then
            bonepos = GetPedBoneCoords(player, 11816)
            bonepos = vector3(bonepos.x - 0.4, bonepos.y + 2.2, bonepos.z + 0.2)
        end
        if (name == "leg") then
            bonepos = GetPedBoneCoords(player, 46078)
            bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
        end
    else
        if (name == "head") then
            bonepos = GetPedBoneCoords(player, 31086)
            bonepos = vector3(bonepos.x - 0.1, bonepos.y + 0.4, bonepos.z + 0.05)
        end
        if (name == "torso") then
            bonepos = GetPedBoneCoords(player, 11816)
            bonepos = vector3(bonepos.x - 0.4, bonepos.y + 2.2, bonepos.z + 0.2)
        end
        if (name == "leg") then
            bonepos = GetPedBoneCoords(player, 46078)
            bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
        end
    end

    if inCreateCharacter then
        local pedCoords = GetEntityCoords(player, true)
        local angle = math.atan2(bonepos.y - pedCoords.y, bonepos.x - pedCoords.x)
        local heading = math.deg(angle) - 90.0
        SetEntityHeading(player, heading)

        SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
        SetCamRot(cam, 0.0, 0.0, 0.0)
    else
        SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
        SetCamRot(cam, 0.0, 0.0, 180.0)
    end
end

RegisterNUICallback('escape', function(data, cb)
	Save(data['save'])
	EnableGUI(false, false)
	
	if inputActive then
		TriggerEvent("vrp-hud:showBind", false)
		inputActive = false
	end
	cb('ok')
end)

RegisterNUICallback("clothes:request", function(data, cb)
	if data[1] then
		cb(data[1])
	else
		exports.vrp:request("Esti sigur ca vrei sa salvezi modificarile facute?", false, false, function(ok)
			cb(ok)
		end)
	end
end)

RegisterNUICallback('toggleCursor', function(data, cb)
	CustomCamera("torso")
	SetNuiFocus(false)

	FreezePedCameraRotation(player)

	Citizen.CreateThread(function()
		while true do
			
			if IsDisabledControlJustReleased(0, 347) then
				FreezePedCameraRotation(player, true)
				Citizen.Wait(100)

				SetNuiFocus(true, true)

				break
			end

			Citizen.Wait(1)
		end
	end)

	cb('ok')
end)

RegisterNUICallback('rotate', function(data, cb)
	if (data["key"] == "left") then
		rotation(20)
	else
		rotation(-20)
	end
	cb('ok')
end)

RegisterNUICallback('switchcam', function(data, cb)
	CustomCamera(data['name'])
	cb('ok')
end)

RegisterNUICallback('toggleclothes', function(data, cb)
	ToggleProps(data)
	cb('ok')
end)

local inCreateCharacter = false
RegisterNetEvent('vrp:createCharacter', function()
	inCreateCharacter = true
	tvRP.toggleComa(false)
	DoScreenFadeOut(500)
    Wait(600)
    FreezeEntityPosition(PlayerPedId(), true)
	SetEntityCoords(PlayerPedId(), -795.49780273438,331.75720214844,201.42440795898-1.0)
    SetNuiFocus(true,true)
    CustomCamera("head")
    Wait(1000)
    DoScreenFadeIn(500)
    Wait(250)
    RenderScriptCams(0,true,500,true,true)
    RenderScriptCams(1,true,500,true,true)
    SetEntityCoords(PlayerPedId(), -795.49780273438,331.75720214844,201.42440795898-1.0)

	TriggerEvent("vrp-hud:updateMap", false)
	TriggerEvent("vrp-hud:setComponentDisplay", {
		serverHud = false,
		minimapHud = false,
		bottomRightHud = false,
		chat = false
	})

	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "enableclothesmenu",
		enable = true,
		menu = 'character-identity',
		isService = false,
	})
end)

RegisterNUICallback("character:startAnimForClothing", function()
	tvRP.executeCommand("e t")
end)

------------------------------------------------------------------------
-- Tattooooooos

function GetTats()
	local tempTats = {}
	if currentTats == nil then return {} end
	for i = 1, #currentTats do
		for key in pairs(tattooHashList) do
			for j = 1, #tattooHashList[key] do
				if tattooHashList[key][j][1] == currentTats[i][2] then
					tempTats[key] = j
				end
			end
		end
	end
	return tempTats
end

function SetTats(data)
	currentTats = data or currentTats
	ClearPedDecorations(player)
	
	for i = 1, #currentTats do
		ApplyPedOverlay(player, currentTats[i][1], currentTats[i][2])
	end
end

RegisterNUICallback('setTattoo', function(data, cb)
	local tattoos = data[1]

	currentTats = {}

	ClearPedDecorations(player)

	for zone, tattoo in next, tattoos do
		local tattooData = tattooHashList[zone][tattoo]

		if tattooData then
			table.insert(currentTats, {tattooData[2], tattooData[1]})

			ApplyPedOverlay(player, tattooData[2], tattooData[1])
		end
	end

	cb('ok')
end)

function OpenMenu(name)
	player = PlayerPedId()
	oldPed = GetCurrentPed()

	FreezePedCameraRotation(player, true)
	RefreshUI()
	EnableGUI(true, name)
end

function Save(save)
	if save then
		data = GetCurrentPed()
		TriggerServerEvent('vrp:saveCharacter', data)
		inCreateCharacter = false
	else
		LoadPed(oldPed)
	end

	SetCamActive(cam)
	RenderScriptCams(false, false, 0, true, true)

	if DoesCamExist(cam) then
		DestroyCam(cam)
	end

	customCam = false
end

RegisterNUICallback("checkName", function(response, cb)
	triggerCallback('checkCharacterName', function(ok)
		if ok then
			data = GetCurrentPed()

			LoadPed(data)
			OpenMenu('characterCreator')
		end

		cb(ok)
	end, response[1], response[2])
end)

-- Scuter

-- local spawnPoints = {
-- 	vec3(-1059.2833251953,-2782.3139648438,21.361570358276),
-- 	vec3(-1053.8311767578,-2784.9760742188,21.361373901367),
-- }

-- local function randomSpawn()
-- 	local spawnPos = spawnPoints[math.random(1, #spawnPoints)]
-- 	RequestCollisionAtCoord(spawnPos[1], spawnPos[2], spawnPos[3])
-- 	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
-- 		Wait(1)
-- 	end
-- end

RegisterNUICallback('character:save', function(data, cb)
	InvalidateIdleCam()
	InvalidateVehicleIdleCam()
	CustomCamera('cam')
	FreezeEntityPosition(PlayerPedId(), false)

	TriggerServerEvent("vrp:saveIdentity", data[1])
	TriggerServerEvent('vrp:saveCharacter', GetCurrentPed(), true)
	TriggerEvent("afk-kick:passAutoKick", false)
	-- SetNuiFocus(false, false)
	Citizen.Wait(34010)
	EnableGUI(false, false)
	-- randomSpawn()
	cb('ok')
end)

RegisterNUICallback('character:setGender', function(data, cb)
	if data[1] == 'M' then
		if IsModelInCdimage('mp_m_freemode_01') and IsModelValid('mp_m_freemode_01') then
			RequestModel('mp_m_freemode_01')
			while (not HasModelLoaded('mp_m_freemode_01')) do
				Citizen.Wait(0)
			end
			local health = GetEntityHealth(PlayerPedId())
			SetPlayerModel(PlayerId(), 'mp_m_freemode_01')
			SetEntityHealth(PlayerPedId(), health)
			SetModelAsNoLongerNeeded('mp_m_freemode_01')
			FreezePedCameraRotation(PlayerPedId(), true)
			SetPedHeadOverlayColor(PlayerPedId(), 1, 1, 1)
			-- Debug Vesta
			SetPedComponentVariation(PlayerPedId(), 53, 0, 0, 0, false)
			-- Tricou
			SetPedComponentVariation(PlayerPedId(), 11, 257, 0, 0, false)
			SetPedComponentVariation(PlayerPedId(), 3, 0, 0, 0, false)
			SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 0, false)
			-- Pants
			SetPedComponentVariation(PlayerPedId(), 4, 109, 0, 0, false)
			-- Shoes
			SetPedComponentVariation(PlayerPedId(), 6, 11, 0, false)
			-- Hair Color
			SetPedHeadOverlayColor(PlayerPedId(), 1, 1, 0, 0)
			SetPedHeadOverlayColor(PlayerPedId(), 2, 1, 0, 0)
			SetPedHeadOverlayColor(PlayerPedId(), 4, 2, 0, 0)
			SetPedHeadOverlayColor(PlayerPedId(), 5, 2, 0, 0)
			SetPedHeadOverlayColor(PlayerPedId(), 8, 2, 0, 0)
			SetPedHeadOverlayColor(PlayerPedId(), 10, 1, 0, 0)
			SetPedHairColor(PlayerPedId(), 1, 1)
		end
	else
		local girlData = {
			['tempCharacterData'] = {["eyeborows"] = 0,["hair_color"] = 10, ["beard" ]= 0,["skinMix"] = 0.05,["mother"] = 7,["father"] = 21,["sex"] = "F",["hair"] = 3,["shapeMix"] = 0.05,["eye_color"] = 2,["hair"] = 73},
			["headStructure"] = {["jaw_width"]=0.0,["jaw_height"]=0.0,["nose_breakage"]=0.0,["chin_height"]=0.0,["cheekbone_height"]=0.10999999940395,["nose_height"]=0.0,["chin_depth"]=0.00999999977648,["nose_bridge_depth"]=0.43999999761581,["eyebrow_height"]=0.0,["cheek_depth"]=0.15999999642372,["nose_tip_length"]=0.0,["eyebrow_depth"]=0.4699999988079,["cheekbone_width"]=0.10999999940395,["eye_size"]=0.0,["chin_indent"]=0.0,["lip_thickness"]=0.0,["neck_circumference"]=0.0,["nose_tip_height"]=0.0,["nose_width"]=0.0,["chin_width"]=0.0},
		}
		if IsModelInCdimage('mp_f_freemode_01') and IsModelValid('mp_f_freemode_01') then
			RequestModel('mp_f_freemode_01')
			while (not HasModelLoaded('mp_f_freemode_01')) do
				Citizen.Wait(0)
			end
			local health = GetEntityHealth(PlayerPedId())
			SetPlayerModel(PlayerId(), 'mp_f_freemode_01')
			SetEntityHealth(PlayerPedId(), health)
			SetModelAsNoLongerNeeded('mp_f_freemode_01')
			FreezePedCameraRotation(PlayerPedId(), true)
			if girlData.headStructure then
				-- Set Head Structures
				for k, v in pairs(face_features) do
					SetPedFaceFeature(PlayerPedId(), v, girlData[k])
				end 
			end
			if girlData.tempCharacterData then
				SetPedHeadBlendData(PlayerPedId(), girlData.tempCharacterData['father'], girlData.tempCharacterData['mother'], 0, girlData.tempCharacterData['father'],  girlData.tempCharacterData['mother'], 0, girlData.tempCharacterData['shapeMix'], girlData.tempCharacterData['skinMix'], nil, true)
				SetPedComponentVariation(PlayerPedId(), 2, girlData.tempCharacterData['hair'], 0, 0, false)
				SetPedHairColor(PlayerPedId(), girlData.tempCharacterData['hair_color'], girlData.tempCharacterData['hair_color'])
				-- Set Hair Color
				SetPedHeadOverlayColor(PlayerPedId(), 1,girlData.tempCharacterData['face_color'],  1, 0, 0)
				SetPedHeadOverlayColor(PlayerPedId(), 2, girlData.tempCharacterData['face_color'], 0, 0, 0)
				SetPedHeadOverlayColor(PlayerPedId(), 4, girlData.tempCharacterData['face_color'], 0, 0, 0)
				SetPedHeadOverlayColor(PlayerPedId(), 5, girlData.tempCharacterData['face_color'], 0, 0, 0)
				SetPedHeadOverlayColor(PlayerPedId(), 8, girlData.tempCharacterData['face_color'], 0, 0, 0)
				SetPedHeadOverlayColor(PlayerPedId(), 10, girlData.tempCharacterData['face_color'],0, 0, 0)
			end
			SetPedHeadOverlayColor(PlayerPedId(), 1, 1, 1)
			-- Debug Vesta
			SetPedComponentVariation(PlayerPedId(), 9, -1, 0, 0, false)
			-- Tricou
			SetPedComponentVariation(PlayerPedId(), 11, 105, 0, 0, false)
			SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 0, false)
			SetPedComponentVariation(PlayerPedId(), 8, 14, 0, 0, false)
			-- Pants
			SetPedComponentVariation(PlayerPedId(), 4, 1, 0, 0, false)
			-- Shoes
			SetPedComponentVariation(PlayerPedId(), 6, 3, 1, false)
		end
	end
	RefreshUI()
	cb('ok')
end)

RegisterNetEvent("vrp:playerJoinFaction")
AddEventHandler("vrp:playerJoinFaction", function(service, ftype)
	isService = false
	if ftype == "Lege" then
		isService = service
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

exports("setClothes", function(data, onlyClothes)
	local nowDrawables = GetDrawables()
	
	if onlyClothes then
		data.model = GetEntityModel(PlayerPedId())
		data.hairColor = GetPedHair()
		data.headBlend = GetPedHeadBlendData()
		data.headOverlay = GetHeadOverlayData()
		data.headStructure = GetHeadStructure()

		data.drawables['hair'] = nowDrawables['hair']
	end

	LoadPed(data)
end)

exports("getClothes", function(onlyClothes)
	if not onlyClothes then return GetCurrentPed() end

	return {
		drawables = GetDrawables(),
		props = GetProps(),
		drawtextures = GetDrawTextures(),
		proptextures = GetPropTextures()
	}
end)

-- Tattoos

local tattoosList = {
	["mpbusiness_overlays"] = {
		"MP_Buis_M_Neck_000",
		"MP_Buis_M_Neck_001",
		"MP_Buis_M_Neck_002",
		"MP_Buis_M_Neck_003",
		"MP_Buis_M_LeftArm_000",
		"MP_Buis_M_LeftArm_001",
		"MP_Buis_M_RightArm_000",
		"MP_Buis_M_RightArm_001",
		"MP_Buis_M_Stomach_000",
		"MP_Buis_M_Chest_000",
		"MP_Buis_M_Chest_001",
		"MP_Buis_M_Back_000",
		"MP_Buis_F_Chest_000",
		"MP_Buis_F_Chest_001",
		"MP_Buis_F_Chest_002",
		"MP_Buis_F_Stom_000",
		"MP_Buis_F_Stom_001",
		"MP_Buis_F_Stom_002",
		"MP_Buis_F_Back_000",
		"MP_Buis_F_Back_001",
		"MP_Buis_F_Neck_000",
		"MP_Buis_F_Neck_001",
		"MP_Buis_F_RArm_000",
		"MP_Buis_F_LArm_000",
		"MP_Buis_F_LLeg_000",
		"MP_Buis_F_RLeg_000",
	},

	["mphipster_overlays"] = {
		"FM_Hip_M_Tat_000",
		"FM_Hip_M_Tat_001",
		"FM_Hip_M_Tat_002",
		"FM_Hip_M_Tat_003",
		"FM_Hip_M_Tat_004",
		"FM_Hip_M_Tat_005",
		"FM_Hip_M_Tat_006",
		"FM_Hip_M_Tat_007",
		"FM_Hip_M_Tat_008",
		"FM_Hip_M_Tat_009",
		"FM_Hip_M_Tat_010",
		"FM_Hip_M_Tat_011",
		"FM_Hip_M_Tat_012",
		"FM_Hip_M_Tat_013",
		"FM_Hip_M_Tat_014",
		"FM_Hip_M_Tat_015",
		"FM_Hip_M_Tat_016",
		"FM_Hip_M_Tat_017",
		"FM_Hip_M_Tat_018",
		"FM_Hip_M_Tat_019",
		"FM_Hip_M_Tat_020",
		"FM_Hip_M_Tat_021",
		"FM_Hip_M_Tat_022",
		"FM_Hip_M_Tat_023",
		"FM_Hip_M_Tat_024",
		"FM_Hip_M_Tat_025",
		"FM_Hip_M_Tat_026",
		"FM_Hip_M_Tat_027",
		"FM_Hip_M_Tat_028",
		"FM_Hip_M_Tat_029",
		"FM_Hip_M_Tat_030",
		"FM_Hip_M_Tat_031",
		"FM_Hip_M_Tat_032",
		"FM_Hip_M_Tat_033",
		"FM_Hip_M_Tat_034",
		"FM_Hip_M_Tat_035",
		"FM_Hip_M_Tat_036",
		"FM_Hip_M_Tat_037",
		"FM_Hip_M_Tat_038",
		"FM_Hip_M_Tat_039",
		"FM_Hip_M_Tat_040",
		"FM_Hip_M_Tat_041",
		"FM_Hip_M_Tat_042",
		"FM_Hip_M_Tat_043",
		"FM_Hip_M_Tat_044",
		"FM_Hip_M_Tat_045",
		"FM_Hip_M_Tat_046",
		"FM_Hip_M_Tat_047",
		"FM_Hip_M_Tat_048",
	},

	["mpbiker_overlays"] = {
		"MP_MP_Biker_Tat_000_M",
		"MP_MP_Biker_Tat_001_M",
		"MP_MP_Biker_Tat_002_M",
		"MP_MP_Biker_Tat_003_M",
		"MP_MP_Biker_Tat_004_M",
		"MP_MP_Biker_Tat_005_M",
		"MP_MP_Biker_Tat_006_M",
		"MP_MP_Biker_Tat_007_M",
		"MP_MP_Biker_Tat_008_M",
		"MP_MP_Biker_Tat_009_M",
		"MP_MP_Biker_Tat_010_M",
		"MP_MP_Biker_Tat_011_M",
		"MP_MP_Biker_Tat_012_M",
		"MP_MP_Biker_Tat_013_M",
		"MP_MP_Biker_Tat_014_M",
		"MP_MP_Biker_Tat_015_M",
		"MP_MP_Biker_Tat_016_M",
		"MP_MP_Biker_Tat_017_M",
		"MP_MP_Biker_Tat_018_M",
		"MP_MP_Biker_Tat_019_M",
		"MP_MP_Biker_Tat_020_M",
		"MP_MP_Biker_Tat_021_M",
		"MP_MP_Biker_Tat_022_M",
		"MP_MP_Biker_Tat_023_M",
		"MP_MP_Biker_Tat_024_M",
		"MP_MP_Biker_Tat_025_M",
		"MP_MP_Biker_Tat_026_M",
		"MP_MP_Biker_Tat_027_M",
		"MP_MP_Biker_Tat_028_M",
		"MP_MP_Biker_Tat_029_M",
		"MP_MP_Biker_Tat_030_M",
		"MP_MP_Biker_Tat_031_M",
		"MP_MP_Biker_Tat_032_M",
		"MP_MP_Biker_Tat_033_M",
		"MP_MP_Biker_Tat_034_M",
		"MP_MP_Biker_Tat_035_M",
		"MP_MP_Biker_Tat_036_M",
		"MP_MP_Biker_Tat_037_M",
		"MP_MP_Biker_Tat_038_M",
		"MP_MP_Biker_Tat_039_M",
		"MP_MP_Biker_Tat_040_M",
		"MP_MP_Biker_Tat_041_M",
		"MP_MP_Biker_Tat_042_M",
		"MP_MP_Biker_Tat_043_M",
		"MP_MP_Biker_Tat_044_M",
		"MP_MP_Biker_Tat_045_M",
		"MP_MP_Biker_Tat_046_M",
		"MP_MP_Biker_Tat_047_M",
		"MP_MP_Biker_Tat_048_M",
		"MP_MP_Biker_Tat_049_M",
		"MP_MP_Biker_Tat_050_M",
		"MP_MP_Biker_Tat_051_M",
		"MP_MP_Biker_Tat_052_M",
		"MP_MP_Biker_Tat_053_M",
		"MP_MP_Biker_Tat_054_M",
		"MP_MP_Biker_Tat_055_M",
		"MP_MP_Biker_Tat_056_M",
		"MP_MP_Biker_Tat_057_M",
		"MP_MP_Biker_Tat_058_M",
		"MP_MP_Biker_Tat_059_M",
		"MP_MP_Biker_Tat_060_M",
	},

	["mpairraces_overlays"] = {
		"MP_Airraces_Tattoo_000_M",
		"MP_Airraces_Tattoo_001_M",
		"MP_Airraces_Tattoo_002_M",
		"MP_Airraces_Tattoo_003_M",
		"MP_Airraces_Tattoo_004_M",
		"MP_Airraces_Tattoo_005_M",
		"MP_Airraces_Tattoo_006_M",
		"MP_Airraces_Tattoo_007_M",
	},

	["mpbeach_overlays"] = {
		"MP_Bea_M_Back_000",
		"MP_Bea_M_Chest_000",
		"MP_Bea_M_Chest_001",
		"MP_Bea_M_Head_000",
		"MP_Bea_M_Head_001",
		"MP_Bea_M_Head_002",
		"MP_Bea_M_Lleg_000",
		"MP_Bea_M_Rleg_000",
		"MP_Bea_M_RArm_000",
		"MP_Bea_M_Head_000",
		"MP_Bea_M_LArm_000",
		"MP_Bea_M_LArm_001",
		"MP_Bea_M_Neck_000",
		"MP_Bea_M_Neck_001",
		"MP_Bea_M_RArm_001",
		"MP_Bea_M_Stom_000",
		"MP_Bea_M_Stom_001",
	},

	["mpchristmas2_overlays"] = {
		"MP_Xmas2_M_Tat_000",
		"MP_Xmas2_M_Tat_001",
		"MP_Xmas2_M_Tat_003",
		"MP_Xmas2_M_Tat_004",
		"MP_Xmas2_M_Tat_005",
		"MP_Xmas2_M_Tat_006",
		"MP_Xmas2_M_Tat_007",
		"MP_Xmas2_M_Tat_008",
		"MP_Xmas2_M_Tat_009",
		"MP_Xmas2_M_Tat_010",
		"MP_Xmas2_M_Tat_011",
		"MP_Xmas2_M_Tat_012",
		"MP_Xmas2_M_Tat_013",
		"MP_Xmas2_M_Tat_014",
		"MP_Xmas2_M_Tat_015",
		"MP_Xmas2_M_Tat_016",
		"MP_Xmas2_M_Tat_017",
		"MP_Xmas2_M_Tat_018",
		"MP_Xmas2_M_Tat_019",
		"MP_Xmas2_M_Tat_022",
		"MP_Xmas2_M_Tat_023",
		"MP_Xmas2_M_Tat_024",
		"MP_Xmas2_M_Tat_025",
		"MP_Xmas2_M_Tat_026",
		"MP_Xmas2_M_Tat_027",
		"MP_Xmas2_M_Tat_028",
		"MP_Xmas2_M_Tat_029",
	},

	["mpgunrunning_overlays"] = {
		"MP_Gunrunning_Tattoo_000_M",
		"MP_Gunrunning_Tattoo_001_M",
		"MP_Gunrunning_Tattoo_002_M",
		"MP_Gunrunning_Tattoo_003_M",
		"MP_Gunrunning_Tattoo_004_M",
		"MP_Gunrunning_Tattoo_005_M",
		"MP_Gunrunning_Tattoo_006_M",
		"MP_Gunrunning_Tattoo_007_M",
		"MP_Gunrunning_Tattoo_008_M",
		"MP_Gunrunning_Tattoo_009_M",
		"MP_Gunrunning_Tattoo_010_M",
		"MP_Gunrunning_Tattoo_011_M",
		"MP_Gunrunning_Tattoo_012_M",
		"MP_Gunrunning_Tattoo_013_M",
		"MP_Gunrunning_Tattoo_014_M",
		"MP_Gunrunning_Tattoo_015_M",
		"MP_Gunrunning_Tattoo_016_M",
		"MP_Gunrunning_Tattoo_017_M",
		"MP_Gunrunning_Tattoo_018_M",
		"MP_Gunrunning_Tattoo_019_M",
		"MP_Gunrunning_Tattoo_020_M",
		"MP_Gunrunning_Tattoo_021_M",
		"MP_Gunrunning_Tattoo_022_M",
		"MP_Gunrunning_Tattoo_023_M",
		"MP_Gunrunning_Tattoo_024_M",
		"MP_Gunrunning_Tattoo_025_M",
		"MP_Gunrunning_Tattoo_026_M",
		"MP_Gunrunning_Tattoo_027_M",
		"MP_Gunrunning_Tattoo_028_M",
		"MP_Gunrunning_Tattoo_029_M",
		"MP_Gunrunning_Tattoo_030_M",
	},

	["mpimportexport_overlays"] = {
		"MP_MP_ImportExport_Tat_000_M",
		"MP_MP_ImportExport_Tat_001_M",
		"MP_MP_ImportExport_Tat_002_M",
		"MP_MP_ImportExport_Tat_003_M",
		"MP_MP_ImportExport_Tat_004_M",
		"MP_MP_ImportExport_Tat_005_M",
		"MP_MP_ImportExport_Tat_006_M",
		"MP_MP_ImportExport_Tat_007_M",
		"MP_MP_ImportExport_Tat_008_M",
		"MP_MP_ImportExport_Tat_009_M",
		"MP_MP_ImportExport_Tat_010_M",
		"MP_MP_ImportExport_Tat_011_M",
	},

	["mplowrider2_overlays"] = {
		"MP_LR_Tat_000_M",
		"MP_LR_Tat_003_M",
		"MP_LR_Tat_006_M",
		"MP_LR_Tat_008_M",
		"MP_LR_Tat_011_M",
		"MP_LR_Tat_012_M",
		"MP_LR_Tat_016_M",
		"MP_LR_Tat_018_M",
		"MP_LR_Tat_019_M",
		"MP_LR_Tat_022_M",
		"MP_LR_Tat_028_M",
		"MP_LR_Tat_029_M",
		"MP_LR_Tat_030_M",
		"MP_LR_Tat_031_M",
		"MP_LR_Tat_032_M",
		"MP_LR_Tat_035_M",
	},

	["mplowrider_overlays"] = {
		"MP_LR_Tat_001_M",
		"MP_LR_Tat_002_M",
		"MP_LR_Tat_004_M",
		"MP_LR_Tat_005_M",
		"MP_LR_Tat_007_M",
		"MP_LR_Tat_009_M",
		"MP_LR_Tat_010_M",
		"MP_LR_Tat_013_M",
		"MP_LR_Tat_014_M",
		"MP_LR_Tat_015_M",
		"MP_LR_Tat_017_M",
		"MP_LR_Tat_020_M",
		"MP_LR_Tat_021_M",
		"MP_LR_Tat_023_M",
		"MP_LR_Tat_026_M",
		"MP_LR_Tat_027_M",
		"MP_LR_Tat_033_M",
	}
}

local tatCategs = {
    {"ZONE_TORSO", 0},
    {"ZONE_HEAD", 0},
    {"ZONE_LEFT_ARM", 0},
    {"ZONE_RIGHT_ARM", 0},
    {"ZONE_LEFT_LEG", 0},
    {"ZONE_RIGHT_LEG", 0},
    {"ZONE_UNKNOWN", 0},
    {"ZONE_NONE", 0},
}

function AddZoneIDToTattoos()
    tempTattoos = {}
    for key in pairs(tattoosList) do
        for i = 1, #tattoosList[key] do
            if tempTattoos[key] == nil then tempTattoos[key] = {} end
            tempTattoos[key][i] = {
                tattoosList[key][i],
                tatCategs[
                    GetPedDecorationZoneFromHashes(
                        key,
                        GetHashKey(tattoosList[key][i])
                    ) + 1
                ][1]
            }
        end
    end
    tattoosList = tempTattoos
end 

function CreateHashList()
    tempTattooHashList = {}
    for key in pairs(tattoosList) do
        for i = 1, #tattoosList[key] do
            local categ = tattoosList[key][i][2]
            if tempTattooHashList[categ] == nil then tempTattooHashList[categ] = {} end
            table.insert(
                tempTattooHashList[categ],
                {GetHashKey(tattoosList[key][i][1]),
                GetHashKey(key)}
            )
        end
    end
	tattooHashList = tempTattooHashList
end 

function GetTatCategs()
    for key in pairs(tattoosList) do
        for i = 1, #tattoosList[key] do
            local zone = GetPedDecorationZoneFromHashes(
                key,
                GetHashKey(tattoosList[key][i][1])
            )
            tatCategs[zone+1] = {tatCategs[zone+1][1], tatCategs[zone+1][2]+1}
        end
    end
	tatCategory = tatCategs
end 

AddZoneIDToTattoos()

CreateHashList()
GetTatCategs()
