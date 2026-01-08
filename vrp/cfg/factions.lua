local cfg = {}

 cfg.factionTasks = {
    ['Mafia'] = {
        ['task_bancomat_medium'] = {
            reward = 350000,
            task = 250,
            text = "Jefuieste cu succes {0} bancomate pe server.",
        },
        ['task_bancomat_advanced'] = {
            reward = 350000,
            task = 1000,
            text = "Jefuieste cu succes {0} bancomate pe server.",
        },
        ['task_turfs'] = {
            reward = 350000,
            task = 5,
            text = "Controleaza {0} teritorii importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_turfs_hard'] = {
            reward = 350000,
            task = 15,
            text = "Controleaza {0} teritorii importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_turfs_fullmap'] = {
            reward = 350000,
            task = 1,
            text = "Controleaza toate teritoriile importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_bancomat_medium'] = {
            reward = 350000,
            task = 250,
            text = "Jefuieste cu succes {0} bancomate pe server.",
        },
        ['task_bancomat_advanced'] = {
            reward = 350000,
            task = 1000,
            text = "Jefuieste cu succes {0} bancomate pe server.",
        },
        ['task_turfs'] = {
            reward = 350000,
            task = 5,
            text = "Controleaza {0} teritorii importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_turfs_hard'] = {
            reward = 350000,
            task = 15,
            text = "Controleaza {0} teritorii importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_turfs_fullmap'] = {
            reward = 350000,
            task = 1,
            text = "Controleaza toate teritoriile importante de pe harta pentru o perioada de timp extinsa.",
        },
        ['task_banca_pacific_medium'] = {
            reward = 350000,
            task = 10,
            text = "Jefuieste cu succes {0} Banca Pacific",
        },
        ['task_banca_pacific_advanced'] = {
            reward = 350000,
            task = 25,
            text = "Jefuieste cu succes {0} Banca Pacific",
        },
        ['task_trafic_armament_easy'] = {
            reward = 350000,
            task = 50,
            text = "Asambleaza in buncar {0} arme din seria AK-47",
        },
        ['task_trafic_armament_medium'] = {
            reward = 350000,
            task = 125,
            text = "Asambleaza in buncar {0} arme din seria Mossberg 500",
        },
        ['task_trafic_armament_hard'] = {
            reward = 350000,
            task = 200,
            text = "Asambleaza in buncar {0} arme din seria M70"
        },
        ['task_trafic_munitie_easy'] = {
            reward = 350000,
            task = 300,
            text = "Asambleaza in buncar {0} cutii cu gloante de calibru 5.56MM",
        },
        ['task_trafic_munitie_hard'] = {
            reward = 350000,
            task = 450,
            text = "Asambleaza in buncar {0} cutii cu gloante de calibru 7.62MM",
        },
        ['task_wanted_easy'] = {
            reward = 350000,
            task = 3,
            text = "Condu politia sa te urmareasca international de {0} ori",
        },
        ['task_wanted_hard'] = {
            reward = 350000,
            task = 10,
            text = "Condu politia sa te urmareasca international de {0} ori",
        },
        ['task_transport_buncar_droguri'] = {
            reward = 350000,
            task = 7,
            text = "Realizeaza {0} transporturi de substante ilegale utilizand buncarul",
        },
        ['task_transport_buncar_special'] = {
            reward = 350000,
            task = 10,
            text = "Realizeaza {0} transporturi speciale ilegale  utilizand buncarul",
        },
        ['task_transport_buncar_auto'] = {
            reward = 350000,
            task = 17, --modifici tu in functie de timp de regenerare a misiunii {mai scurt=mai mult task}
            text = "Realizeaza {0} transporturi auto ilegale utilizand buncarul",
        },
    },
    ['EMS'] = {
        ['task_apeluri_preluate'] = {
            reward = 500000,
            task = 2500,
            text = "Preia {0} apelurile active de pe server.",
        },
        ['task_truse_oferite'] = {
            reward = 500000,
            task = 4000,
            text = "Ofera {0} de truse medicale cetatenilor.",
        },
        ['task_salvare_cetateni'] = {
            reward = 500000,
            task = 5000,
            text = "Salveaza {0} cetateni orasului Los Santos.",
        },
        ['task_salvare_npc'] = {
            reward = 500000,
            task = 15000,
            text = "Accepta {0} de apeluri de la server.",
        },
        ['task_salvarea_de_la_raceala'] = {
            reward = 500000,
            task = 4000,
            text = "Salveaza {0} pacenti de la raceala.",
        },
        ['task_salvare_politisti'] = {
            reward = 500000,
            task = 5000,
            text = "Salveaza {0} de politisti de la moarte.",
        }
    }
}

cfg.factionLevels = {
    { -- Level 1
        requiredXP = 0,
    },
    { -- Level 2
        requiredXP = 200,
    },
    { -- Level 3
        requiredXP = 500,
    },
    { --  Level 4
        requiredXP = 900,
    },
    { -- Level 5
        requiredXP = 1200,
    },
    { -- Level 6
        requiredXP = 1800,
    },
    { -- Level 7
        requiredXP = 2700,   
    },
    { -- Level 8
        requiredXP = 4000,   
    },
    { -- Level 9
        requiredXP = 6000,
    },
    { -- Level 10
        requiredXP = 8000,
    },
    { -- Level 11
        requiredXP = 10000,
    },
    { -- Level 12
        requiredXP = 14000,
    },
    { -- Level 13
        requiredXP = 18000,
    },
    { -- Level 14
        requiredXP = 22000,
    },
    { -- Level 15
        requiredXP = 26000,
    },
    { -- Level 16
        requiredXP = 30000,
    },
    { -- Level 17
        requiredXP = 34000,
    },
    { -- Level 18
        requiredXP = 38000,
    },
    { -- Level 19
        requiredXP = 42000,
    },
    { -- Level 20
        requiredXP = 46000,
    }
}

return cfg