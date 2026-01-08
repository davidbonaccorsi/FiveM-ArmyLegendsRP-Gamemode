local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(player) (called when the player spawn with the group)
--- onjoin (optional): function(player) (called when the player join the group)
--- onleave (optional): function(player) (called when the player leave the group)
--- (you have direct access to vRP and vRPclient, the tunnel to client, in the config callbacks)

cfg.groups = {


    ["user"] = {
        "player.phone",
        --"player.calladmin",
        "admin.tickets",
        "player.fix_haircut",
        --"mugger.mug",
        --"police.askid",
        "player.userlist",
        "player.check",
        --"player.store_money",
        "vip.skins",
        "player.player_menu",
        "police.seizable", -- can be seized
    },


    ["youtuber"] = {
        _config = {onspawn = function(player)
                vRPclient.notify(player, {"Te-ai logat cu gradul de Youtuber"})
            end},
        "player.phone"
    },
     ["ytacces"] = {
        _config = {onspawn = function(player)
                vRPclient.notify(player, {"Te-ai logat cu gradul de Youtuber"})
            end},
        "player.phone"
    },

    -- Staff Groups
    ["Manager Factiuni"] = {
       _config = {onspawn = function(player)
           vRPclient.notify(player, {"Esti manager de factiuni."})
       end}
    },
    ["event"] = {
        "event.access"
    },
    ["event"] = {
        _config = {onspawn = function(player)
            vRPclient.notify(player, {"Esti Organizator de Evenimente."})
        end}
    },
    
    
    
    -- grade premium
    ["sponsors"] = {
        "player.phone"
    },
    ["Player Tracker"] = {
        "player.tracker"
    },
    ["Permis Port Arma"] = {
        "permis.arma"
    },
    ["doubleXp"] = {
        "doubleXp"
    },
    
    ["Weapon Dealer"] = {
        "player.store_weapons",
        "player.store_armor",
        "weapon.dealer"
    },

}

-- groups are added dynamically using the API or the menu, but you can add group when an user join here
cfg.users = {}

-- group selectors
-- _config
--- x,y,z, blipid, blipcolor, permissions (optional)

cfg.selectors = {}

return cfg
