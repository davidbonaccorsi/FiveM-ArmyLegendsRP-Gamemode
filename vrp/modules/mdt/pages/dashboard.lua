registerCallback('updateMDTDashboard', function(player)
    local user_id = vRP.getUserId(player)
    local identity = vRP.getIdentity(user_id)

    local cops = vRP.getOnlineUsersByFaction('Politie')
    local medics = vRP.getOnlineUsersByFaction('Smurd')

    return {
        player = {
            name = identity.name,
            firstname = identity.firstname,
            phone = identity.phone,
            jobRank = vRP.getFactionRank(user_id),
        },

        stats = {
            cops = #cops,
            medics = #medics,
            alerts = #(vRP.getActiveCalls())
        }
    }
end)