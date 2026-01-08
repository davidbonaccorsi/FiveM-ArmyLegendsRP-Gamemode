local cfg = {}

cfg.pdprops = {
    "prop_roadcone02a",
    "prop_barrier_work05",
    "prop_barrier_work06a",
    "prop_mp_barrier_02b",
    "prop_mp_arrow_barrier_01",
    "prop_gazebo_02",
    "prop_worklight_03b",
    "hei_prop_hei_monitor_police_01",
    "prop_tyre_spike_01",
}

cfg.backupTexts = {
    ["BK 0"] = "Un membru al departamentului are o situatie de urgenta, mergi si ajuta-l.",
    ["BK 1"] = "Un membru al departamentului are nevoie de asistenta cu risc mic.",
    ["BK 2"] = "Un membru al departamentului are nevoie de asistenta cu risc mediu.",
    ["BK 3"] = "Un membru al departamentului are nevoie de asistenta imediata, mergi si ajuta-l.",
    ["BK 4"] = "Un membru al departamentului are nevoie de ingrijiri medicale, mergi si ajuta-l.",

    ["10-11"] = "Un cetatean a sesizat focuri de arma in aceasta zona."
}


-- illegal items (seize)
cfg.seizable_items = {
	"dirty_money",
	"thermal_charge",
	"lockpick",
	"dia_box",
	"lingou_aur",
	"cocaine",
	"lsd",
	"credit",
	"credit_cards",
	"weed",
	"pills",
	"kidney",
	"heart",
	"liver",
	"horn",
	"ivory",
	"fur",
	"furs",
	"fake_id",
	"speish",
	"drug_seeds",
	"drug_cocaalka",
	"drug_unprocpcp",
	"drug_lyseracid",
	"drug_cansativa",
	"heroine",
	"pcp",
	"amphetamine",
	"subutex",
	"thc",
	"dmt",
	"shrooms"
}

-- jails {x,y,z,radius}
cfg.jails = {
    {1681.8041992188,2524.9958496094,-120.84016418457},
    {1684.7308349609,2524.8403320313,-120.8399810791},
    {1688.4840087891,2524.4291992188,-120.84742736816},
    {1691.9298095703,2524.0305175781,-120.8498840332},
    {1694.9956054688,2524.619140625,-120.84288024902},
    {1693.7166748047,2512.7495117188,-120.84320831299},
    {1690.6743164063,2512.7580566406,-120.84324645996},
    {1687.4689941406,2513.2009277344,-120.84210205078},
    {1684.3962402344,2512.9340820313,-120.83997344971},
    {1680.9261474609,2512.3046875,-120.84987640381},
    {459.485870361328,-1001.61560058594,24.914867401123,2.1},
    {459.305603027344,-997.873718261719,24.914867401123,2.1},
    {459.999938964844,-994.331298828125,24.9148578643799,1.6}
}  

-- fines
-- map of name -> money
cfg.fines = {
    ["Condus imprudent:"] = 10000,
    ["Viteza excesiva:"] = 15000,
    ["Parcare ilegala:"] = 2500,
    ["Geamuri fumurii/neoane:"] = 7500,
    ["Nerespectarea culorii rosie:"] = 10000,
    ["Deranjarea linistii publice:"] = 5000,
    ["Posesia de roti antiglont:"] = 30000,
    ["Punerea in circulatie sau conducerea unui autovehicul neinmatriculat:"] = 20000,
    ["Burnout/drift:"] = 7500,
    ["Vandalism:"] = 10000,
    ["Furt auto:"] = 20000,
    ["Furt masina de politie:"] = 30000,
    ["Jefuirea unei banci:"] = 100000,
    ["Jefuirea unei case:"] = 50000,
    ["Asalt cu arma mortala:"] = 25000,
    ["Crima:"] = 35000,
    ["Tentativa de omor:"] = 20000,
    ["Posesia unei arme de foc:"] = 20000,
    ["Posesia unei arme albe:"] = 5000,
    ["Rapirea unui civil:"] = 15000,
    ["Rapirea unui om al legii:"] = 50000,
    ["Obstructia unui om al legii:"] = 7500,
    ["Dare/Luare de mita:"] = 10000,
    ["Rezistenta la arest:"] = 20000,
    ["Nuditate in public:"] = 5000,
    ["Abuzul liniei de urgenta:"] = 10000,
}

return cfg