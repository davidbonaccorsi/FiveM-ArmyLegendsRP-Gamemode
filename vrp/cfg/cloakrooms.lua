local cfg = {}

--[[

  Component variations:
  0 - Face
  1 - Masks
  2 - Hair
  3 - Hands/Gloves
  4 - Legs
  5 - Bags
  6 - Shoes
  7 - Neck
  8 - Undershirts
  9 - Vest
  10 - Decals
  11 - Jackets

  
  Props variations:
  0 - Helmets, hats, earphones
  1 - Glasses
  2 - Ear accessories
]]

cfg.uniforms = {

  ["Politie"] = {
    faction = "Politie",
    { -- male
      { 
        rank = "Cadet", 
        props = {
          [0] = {149, 0}, --- Helmets, hats
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {34, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {204, 0}, --- Jackets
        } 
      },

      { 
        rank = "Agent", 
        props = {
          [0] = {149, 0}, --- Helmets, hats
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {34, 1}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {204, 0}, --- Jackets
        } 
      },

      { 
        rank = "Agent Sef Principal", 
        props = {
          [0] = {149, 0}, --- Helmets, hats
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {204, 0}, --- Jackets
        } 
      },

      { 
        rank = "Inspector", 
        props = {
          [0] = {-1}, --- Helmets, hats, earphones, masks
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {301, 3}, --- Jackets
        } 
      },

      { 
        rank = "Sub-Comisar", 
        props = {
          [0] = {-1}, --- Helmets, hats, earphones, masks
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {301, 2}, --- Jackets
        } 
      },

      { 
        rank = "Comisar", 
        props = {
          [0] = {-1}, --- Helmets, hats, earphones, masks
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {301, 4}, --- Jackets 
        } 
      },

      { 
        rank = "Comisar-Sef", 
        props = {
          [0] = {-1}, --- Helmets, hats, earphones, masks
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE

          [3] = {0, 0}, --- Hands/Gloves
          [4] = {48, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {8, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {301, 1}, --- Jackets
        } 
      },

      { 
        rank = "D.I.I.C.O.T", 
        props = {
          [0] = {191, 1}, --- Helmets, hats
          [1] = {49, 1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {42, 0}, --EXAMPLE / MASK

          [3] = {19, 0}, --- Hands/Gloves
          [4] = {132, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {119, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {1, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {4, 0}, --- Jackets
        } 
      },

      { 
        rank = "Coordonator D.I.I.C.O.T", 
        props = {
          [0] = {191, 1}, --- Helmets, hats, earphones, masks
          [1] = {49, 1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {42, 0}, --EXAMPLE / MASK

          [3] = {19, 0}, --- Hands/Gloves
          [4] = {132, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {119, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {1, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {4, 0}, --- Jackets
        } 
      },

      { 
        rank = "Moto", 
        props = {
          [0] = {170, 0}, --- Helmets, hats
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE / MASK

          [3] = {19, 0}, --- Hands/Gloves
          [4] = {134, 0}, --- Legs
          [5] = {100, 0}, --- Bags
          [6] = {119, 0}, --- Shoes
          [8] = {91, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {18, 0}, --- Jackets
        } 
      },
    },

    { -- female
      { 
        rank = "Femei", 
        props = {
          [0] = {45, 0}, --- Helmets, hats
          [1] = {-1}, --- Glasses
          [2] = {-1}, --- Ear accessories
        }, 
        parts = {
          [1] = {0, 0}, --EXAMPLE / MASK

          [3] = {31, 0}, --- Hands/Gloves
          [4] = {34, 0}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {24, 0}, --- Shoes
          [8] = {189, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {48, 0}, --- Jackets
        } 
      },
    },
  },

  ["Smurd"] = {
    faction = "Smurd",
    { -- male
      { 
        rank = "Asistent Medical", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {77, 0}, --- Hands/Gloves
          [4] = {27, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {12, 3}, --- Shoes
          [8] = {52, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {5, 1}, --- Jackets
        } 
      },

      { 
        rank = "Medic Stagiar/Rezident", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {77, 0}, --- Hands/Gloves
          [4] = {27, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {12, 3}, --- Shoes
          [8] = {52, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {5, 0}, --- Jackets
        } 
      },

      { 
        rank = "Medic Specialist", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {77, 0}, --- Hands/Gloves
          [4] = {48, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {21, 3}, --- Shoes
          [8] = {52, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {186, 0}, --- Jackets
        } 
      },

      { 
        rank = "Medic Chirurg", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {76, 0}, --- Hands/Gloves
          [4] = {48, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {21, 3}, --- Shoes
          [8] = {52, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {185, 0}, --- Jackets
        } 
      },

      { 
        rank = "Medic Inspector", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {77, 0}, --- Hands/Gloves
          [4] = {48, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {21, 3}, --- Shoes
          [8] = {52, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {70, 2}, --- Jackets
        } 
      },

      { 
        rank = "Director General / Adjunct", 
        parts = {
          [1] = {31, 0}, --EXAMPLE / MASK

          [3] = {6, 0}, --- Hands/Gloves
          [4] = {124, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {106, 3}, --- Shoes
          [8] = {11, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {226, 0}, --- Jackets
        } 
      },
    },
    { -- female
      { 
        rank = "Asistenta", 
        parts = {
          [1] = {0, 0}, --EXAMPLE / MASK

          [3] = {14, 0}, --- Hands/Gloves
          [4] = {41, 1}, --- Legs
          [5] = {0, 0}, --- Bags
          [6] = {1, 0}, --- Shoes
          [8] = {15, 0}, --- Undershirts
          [9] = {0, 0}, --- Vest
          [10] = {0, 0}, --- Decals
          [11] = {49, 0}, --- Jackets
        } 
      },
    },
  }
}

cfg.cloakrooms = {
  {"Politie", vec3(443.44000244141,-997.01977539062,35.062427520752), 312, {129, 188, 251}}, --LS
  {"Politie", vec3(-436.42218017578,6010.7060546875,36.995666503906), 312, {129, 188, 251}}, --PALETO
  {"Politie", vec3(1838.8785400391,3677.9514160156,38.929264068604), 312, {129, 188, 251}}, -- SANDY
  {"Smurd", vec3(310.84802246094,-587.55810546875,38.330955505371), 235, {194, 80, 80}}, --LS
  {"Smurd", vec3(1785.0380859375,3652.1694335938,34.852584838867), 235, {194, 80, 80}}, --SANDY
  {"Smurd", vec3(-251.47398376465,6309.1806640625,32.427223205566), 235, {194, 80, 80}}, --PALETO
}

return cfg