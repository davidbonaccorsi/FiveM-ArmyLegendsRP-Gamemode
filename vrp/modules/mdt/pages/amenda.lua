registerCallback('createAmenda', function(player, data)
    local playersFined = data.players

    if #playersFined > 1 then
        for _, player in next, playersFined do
            exports.mongodb:insertOne({
                collection = 'mdt_amenzi',
                document = {
                    id = exports.mongodb:countSync({collection = 'mdt_amenzi'}) + 1,
                    user_id = tonumber(player.id),
                    name = data.name,
                    description = data.description,
                    players = data.players,
                    cops = data.cops,
                    createdAt = data.createdAt,
                    vehicles = data.vehicles,
                    fines = data.fines
                }
            })
        end
    else
        exports.mongodb:insertOne({
            collection = 'mdt_amenzi',
            document = {
                id = exports.mongodb:countSync({collection = 'mdt_amenzi'}) + 1,
                user_id = tonumber(data.targetId),
                name = data.name,
                description = data.description,
                players = data.players,
                cops = data.cops,
                createdAt = data.createdAt,
                vehicles = data.vehicles,
                fines = data.fines
            }
        })
    end

    if #playersFined >= 1 then
        local amount = 0

        local fineReason = ''
        for _, fine in next, data.fines do
            amount += fine.amount
            fineReason = fine.name..', '
        end

        local fineReduction = tonumber(data.fine_reduction)

        if fineReduction > 0 then
            amount -= ((fineReduction / 100) * amount)
        end

        for _, player in next, data.players do
            local target_src = vRP.getUserSource(tonumber(player.id))

            if target_src then
                local userIdentity = vRP.getIdentity(tonumber(player.id))
                local name = userIdentity.firstname..' '..userIdentity.name

                local function calculatePercentage(percentage, number)
					return math.floor((number * percentage) / 100)
				end

				local gain = calculatePercentage(2, math.floor(amount))
				if gain > 0 then
					vRP.depositFactionBudget("Politie", gain)
				end

                vRP.giveUserFine(target_src, tonumber(player.id), {
                    player = tonumber(player.id),
                    expireDate = os.time() + (86400 * 7),
                    type = 'cop',
                    name = name,
                    amount = math.floor(amount),
                    reason = fineReason,
                    cop = data.cops[1] and data.cops[1].userIdentity and data.cops[1].userIdentity.firstname..' '..data.cops[1].userIdentity.name or 'N/A',
                    rank = data.cops[1] and data.cops[1].faction and data.cops[1].faction.rank or 'N/A',
                    badge = data.cops[1] and data.cops[1].id or 'N/A',
                    sex = userIdentity.sex == 'M' and 'Barbat' or 'Femeie',
                    createdAt = os.time(),
                })
            end
        end
    end

    return exports.mongodb:countSync({collection = 'mdt_amenzi'})
end)

registerCallback('searchAmenda', function(player, user_id)
    local user_id = tonumber(user_id)
    local data = exports.mongodb:findSync({collection = 'mdt_amenzi', query = {user_id = user_id}})

    return data or {}
end)