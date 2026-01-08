local cfg = {}

cfg.gymLocations = vec3(-53.361316680908,-1288.7380371094,30.90510559082)

cfg.gymEquipment = {
	{
		location = vec3(-55.683681488037,-1278.8016357422,29.225439071655),
		type = "Abdomene",
		workoutDuration = 15000,
		animData = {pos = vector3(-55.683681488037,-1278.8016357422,29.225439071655), h = 270.0},
	},
	{
		location = vec3(-59.107162475586,-1284.8227539063,30.905076980591),
		type = "Tractiuni",
		workoutDuration = 15000,
		animData = {pos = vector3(-59.107162475586,-1285.0027539063,29.880076980591), h = 179.0}
	},
	{
		location = vec3(-55.94469833374,-1286.1669921875,29.225437164307),
		type = "Flotari",
		workoutDuration = 15000,
	},
	{
		location = vec3(-62.787372589111,-1282.7412109375,31.075536727905),
		type = "Biceps",
		workoutDuration = 15000,
	},
	{
		location = vec3(-60.920230865479,-1282.2559814453,30.905101776123),
		type = "Biceps",
		workoutDuration = 15000,
	},
	{
		location = vec3(-61.091247558594,-1278.7963867188,30.905107498169),
		type = "Yoga",
		workoutDuration = 15000,
	},
}

cfg.gymAnims = {
	["Abdomene"] = "WORLD_HUMAN_SIT_UPS",
	["Yoga"] = "WORLD_HUMAN_YOGA",
	["Biceps"] = "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS",
	["Tractiuni"] = "PROP_HUMAN_MUSCLE_CHIN_UPS",
	["Flotari"] = "WORLD_HUMAN_PUSH_UPS",
}

cfg.kgPerStrength = {
    [0] = 5,
    [100] = 15.5,
    [200] = 16,
    [300] = 16.5,
    [400] = 17,
    [500] = 17.5,
    [600] = 18,
    [700] = 18.5,
    [800] = 19,
    [900] = 19.5,
    [1000] = 20,
    [1100] = 20.5,
    [1200] = 21,
    [1300] = 22,
    [1400] = 23,
    [1500] = 25,
}

return cfg;