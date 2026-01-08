local marketTypes = module("cfg/markets").market_types

Citizen.CreateThread(function()
    Citizen.Wait(4096)

    for _, market in pairs(GlobalState.markets) do
        local index = market.id

        local marketCfg = marketTypes[market.type]?._config
        
        if marketCfg then
            local areaStr = ("vRP:market:"..index)

            local x, y, z = market.x, market.y, market.z

            if marketCfg.blipid then
                tvRP.addBlip(areaStr, x, y, z, marketCfg.blipid, marketCfg.blipcolor, "Magazin ("..market.type..")", 0.5)
            end

            tvRP.setArea(areaStr, x, y, z, 10.0, {key = "E", text = marketCfg.text or "Magazin "..market.type, minDst = 1}, 
            
            {
				type = 27,
				x = 0.501,
				y = 0.501,
				z = 0.5001,
				color = marketCfg.iconColor or {255, 255, 255, 200},
				coords = {x, y, z - 0.9}
			}, function()
                TriggerServerEvent("vrp-markets:openMarket", index)
            end)

            if next(market.bizPos or {}) then
                local areaStr = ("vRP:market_biz:"..index)
                
                local x, y, z = table.unpack(market.bizPos)

                tvRP.addBlip(areaStr, x, y, z, 605, 16, "Afacere", 0.4)

                tvRP.setArea(areaStr, x, y, z, 10.0, {key = "E", text = "Administreaza afacerea"},
                {
					type = 27,
					x = 0.901,
					y = 0.901,
					z = 0.5001,
					color = {254, 235, 169, 100},
					coords = {x, y, z - 0.9}
				}, function()
                    local canAccess = (market.owner == LocalPlayer.state.user_id)

                    if not canAccess then
                        return tvRP.notify("Nu esti detinatorul acestui magazin!", "error")
                    end

                    TriggerServerEvent("vrp-markets:openMarketBiz", index)
                end)
            end
        end
    end
end)