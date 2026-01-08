Config = {}

Config.debug = false

-- Vehicles from which players can jump
Config.jumpableVehicles = {
    classes = { 8, 13 },
    models = {
        'blazer',
        'blazer2',
        'blazer3',
        'blazer4',
        'seashark',
    },
}

-- Type of the input hints. '3d-text' or 'floating'
Config.inputType = '3d-text'
-- Size of the 3d text. (Only applicable for the 3d-text option)
Config.textScale = 1.0

-- Minimum bike speed in km/h
Config.minBikeSpeed = 10.0

-- Force of a normal jump. (side, front, up)
Config.jumpForce = vector3(8.0, 0.7, 5.0)

-- Settings related to landing and holding onto roofs of cars
Config.roofHolding = {
    enabled = true,

    -- Minimum force to fall off a roof
    falloffForces = 8.0,

    -- Multiplier of the minimum force required to fall off when holding onto the roof
    holdingForceMultiplier = 2.5,

    -- Whether to allow players to enter vehicles from the roof
    allowVehicleEntering = true,
}

-- Settings related to "focus" jumping. (Jumping onto specific vehicles, sort of an aimbot for jumping)
Config.focusJump = {
    enabled = true,

    -- Maximum difference of velocity for focused jump
    maxVelocityDifference = 5.0
}

-- Controls which will be disabled when jumping/preparing a jump
Config.jumping = {
    disableControls = {
        24, 69, 92, 106, 122, 135, 223, 257,
        25, 68, 70, 91, 114, 330,
        38, 86,
        140, 141, 142, 143
    }
}

-- Keybinds
-- https://docs.fivem.net/docs/game-references/controls/
Config.keybinds = {
    -- Hardcoded keybinds
    jumpRight = {
        name = 'INPUT_VEH_AIM',
        label = 'RMB',
        input = 68,
    },
    jumpLeft = {
        name = 'INPUT_VEH_ATTACK',
        label = 'LMB',
        input = 69,
    },
    jumpFocus = {
        name = 'INPUT_VEH_HORN',
        label = 'E',
        input = 86,
    },
    enterVehicleSeat = {
        name = 'INPUT_VEH_HORN',
        label = 'E',
        input = 86,
    },

    -- FiveM Keybinds. Editable through the in-game keybinds settings
    jumpPrepare = {
        key = 'G',
    }
}
