local theElevators = {
	-- Spital Pillbox
	{ -- to helipad first floor
		coordsFrom = vec3(327.72906494141,-569.10278320313,48.211158752441),
		coordsTo = vec3(338.73883056641,-583.86999511719,74.165557861328),
	},

	{ -- from helipad first floor
		coordsFrom = vec3(338.73883056641,-583.86999511719,74.165557861328),
		coordsTo = vec3(327.72906494141,-569.10278320313,48.211158752441),
	},

	{ -- to helipad downstair
	    coordsFrom = vec3(316.48791503906,-597.53295898438,38.329345703125),
	    coordsTo = vec3(338.73883056641,-583.86999511719,74.165557861328),
    },

    { -- from helipad downstair
	    coordsFrom = vec3(338.73883056641,-583.86999511719,74.165557861328),
	    coordsTo = vec3(316.48791503906,-597.53295898438,38.329345703125),
    }, 

	{ -- to garage downstairs
		coordsFrom = vec3(319.92041015625,-598.61785888672,38.325710296631),
		coordsTo = vec3(319.6975402832,-559.75018310547,28.743745803833),
	},

	{ -- from garage downstairs
		coordsFrom = vec3(319.6975402832,-559.75018310547,28.743745803833),
		coordsTo = vec3(319.92041015625,-598.61785888672,38.325710296631),
	},

	-- Club Lux
	{ -- from club to upper
	    coordsFrom = vec3(-320.80230712891,209.70222473145,87.932998657227),
	    coordsTo = vec3(-303.9333190918,192.21334838867,144.37258911133),
    },

	{ -- from upper back to club
	    coordsFrom = vec3(-303.9333190918,192.21334838867,144.37258911133),
	    coordsTo = vec3(-320.80230712891,209.70222473145,87.932998657227),
    },

	-- GALAXY
	{ -- outside in garage
	    coordsFrom = vec3(323.80480957031,267.44161987305,104.40523529053),
	    coordsTo = vec3(406.09838867188,243.73863220215,93.094184875488),
    },

	{ -- from garage to outside
	    coordsFrom = vec3(406.09838867188,243.73863220215,93.094184875488),
	    coordsTo = vec3(323.80480957031,267.44161987305,104.40523529053),
    }
}

Citizen.CreateThread(function()
	for k, v in pairs(theElevators) do
		tvRP.setArea("vRP:elevators"..k ,v.coordsFrom[1], v.coordsFrom[2], v.coordsFrom[3], 15,
		{key = 'E', text = "Foloseste liftul", minDst = 1.5},
		{
			type = 1,
			x = 1.10,
			y = 0.90,
			z = 0.90,
			color = {255, 255, 255, 200},
			coords = v.coordsFrom-vector3(0.0, 0.0, 1.0)
		},
		function()
			DoScreenFadeOut(1000, true)
			Citizen.SetTimeout(1400,function()
				local cdsTo = v.coordsTo
				local veh = playerVehicle
				TriggerEvent("vrp-hud:showBind", false)

				if veh ~= 0 then
					local tmpFuel = GetVehicleFuelLevel(veh)

					SetEntityCoords(veh, cdsTo.x+0.0001, cdsTo.y+0.0001, cdsTo.z+0.0001, 1, 0, 0, 1)
					SetVehicleOnGroundProperly(veh)
					SetVehicleFuelLevel(veh, tmpFuel)
				end

				tvRP.teleport(cdsTo.x, cdsTo.y, cdsTo.z)
				if veh ~= 0 then
					TaskWarpPedIntoVehicle(tempPed, veh, -1)
				end

				DoScreenFadeIn(1000, true)
				Citizen.Wait((veh ~= 0) and 6500 or 2500)
				entered = false
			end)
		end)
	end
end)