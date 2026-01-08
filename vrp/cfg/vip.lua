local cfg = {}

cfg.grades = {
	--["grad"] = {zile, coinsi, descriere},
	["vip:1"] = {30, 20, "Prime"},
	["vip:2"] = {30, 35, "Prime Platinum"},

	["sponsors"] = {7, 10, "Sponsor"},
	["Permis Port Arma"] = {30, 10, "Permis Port Arma"},
}

cfg.vouchers = {
	vehicle = {"vehicle_voucher_20", "vehicle_voucher_40"},
	carplate = "car_plate_voucher",

	all = {"vehicle_voucher_20", "vehicle_voucher_40", "car_plate_voucher"}
}
 
cfg.cars = {
    ["akumac"] = {"Dinka Akuma Classic V.I.P.", 15},
    ["asteropers"] = {"Karin Asterope RS V.I.P.", 20},
    ["auroras"] = {"Progen Aurora Sport LHD V.I.P.", 20},
    ["auroras2"] = {"Progen Aurora Sport RHD V.I.P.", 15},
    ["buffalo4h"] = {"Bravado Buffalo Hellfire V.I.P.", 30},
    ["callista"] = {"Pfister Comet Callista V.I.P.", 30},
    ["cheetahfel"] = {"Grotti Cheetah Veloce V.I.P.", 30},
    ["clique2"] = {"Vapid Clique Deluxe V.I.P.", 30},
    ["coquette4c"] = {"Invetero Coquette D10 Widebody V.I.P.", 30},
    ["elegyrace"] = {"Annis Elegy Race V.I.P.", 40},
    ["euros"] = {"Annis Euros V.I.P.", 15},
    ["f620d"] = {"Ocelot F620 Sleeper V.I.P.", 15},
    ["feltzer9"] = {"Benefactor Sterling V.I.P.", 20},
    ["gauntletc"] = {"Bravado Gauntlet Classic V.I.P.", 20},
    ["gauntletstx"] = {"Bravado Gauntlet STX V.I.P.", 20},
    ["gstyosemite1"] = {"Declasse Yosemite DRT V.I.P.", 15},
    ["hachura"] = {"Vulcar Hachura R V.I.P.", 15},
    ["kampfer"] = {"Übermacht Kampfer V.I.P.", 15},
    ["kawaii"] = {"Annis Kawaii V.I.P.", 30},
    ["kriegerc"] = {"Benefactor Krieger BPX-32B V.I.P.", 15},
    ["m420"] = {"Pegassi Monroe SOTW Edition V.I.P.", 10},
    ["meteor"] = {"Pfister Meteor V.I.P.", 15},
    ["missile"] = {"1932 Albany JSS Hawk Missile V.I.P.", 15},
    ["nerops"] = {"Truffade Nero Pur Sport V.I.P.", 30},
    ["paragonxr"] = {"Enus Paragon XR V.I.P.", 30},
    ["picadorexr"] = {"Cheval Picador EXR V.I.P.", 30},
    ["playboy"] = {"Vapid Playboy V.I.P.", 30},
    ["raidenz"] = {"Coil Raiden Z V.I.P.", 30},
    ["rh4"] = {"Annis Elegy RH4 V.I.P.", 30},
    ["roxanne"] = {"Annis Roxanne V.I.P.", 30},
    ["sheavas"] = {"Emperor Sheava V.I.P.", 30},
    ["spritzerdtm"] = {"Benefactor Spritzer DTM V.I.P.", 30},
    ["stardust"] = {"Pfister Stardust V.I.P.", 30},
    ["stingersc"] = {"Grotti Stinger SC V.I.P.", 30},
    ["sunrise1"] = {"Maibatsu Sunrise R V.I.P.", 30},
    ["toreador2"] = {"Pegassi Toreador V.I.P.", 30},
    ["turismo2lm"] = {"Grotti Turismo LM V.I.P.", 30},
    ["zr380s"] = {"Annis ZR-380 Custom V.I.P.", 30},

    ["serv_electricscooter"] = {"Scooter Electric", 10}
}


cfg.vipMoney = {
	50000, -- VIP Prime
	250000, -- VIP Platinum
}

cfg.vipVouchers = {
	-- {grad, {voucher, amount}}
	["vip:1"] = {{"vehicle_voucher_20", 1}},
	["vip:2"] = {{"vehicle_voucher_40", 2}, {"car_plate_voucher", 1}}
}

cfg.money = {
	-- {bani, diamante}
	{20000, 5},
	{100000, 10},
    {300000, 20},
	{1100000, 80},
	{3000000, 160},
}

cfg.jobBoost = {5, 15}

cfg.starterMoney = 150000

cfg.starterClothes = {
	m = {"pantaloni940", "tricou8"},
	f = {"pantaloni_f116", "top225"},
}

cfg.clearTransfer = {10, 20} -- 7days, 14 days

cfg.starterPack = 25
cfg.doubleXpPrice = 10
cfg.clearWarnPrice = 10

return cfg