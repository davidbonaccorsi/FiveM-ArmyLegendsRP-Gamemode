
local allDeposit = module("cfg/deposit")

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    
    if first_spawn then
        TriggerClientEvent("vrp-deposits:populateLocations", player, allDeposit)
    end

end)

RegisterServerEvent("vrp-deposits:tryPayment")
AddEventHandler("vrp-deposits:tryPayment", function(depId)
    local player = source
    local ped = GetPlayerPed(player)
    local pedPos = GetEntityCoords(ped)
    local user_id = vRP.getUserId(player)

    if depId and allDeposit[depId] then
        
        if #(allDeposit[depId].pos - pedPos) > 15.0 then
            DropPlayer(player, "Injection detected [vrp][depositDst]")
        else

            if vRP.tryBankPayment(user_id, allDeposit[depId].fare, true, "Deposit ("..depId..")") or vRP.tryPayment(user_id, allDeposit[depId].fare, true, "Deposit ("..depId..")") then

                TriggerEvent("vRP:depositEnter", user_id, allDeposit[depId].fare)

                vRP.openChest(player, "deposit:u"..user_id.."dep_"..depId, allDeposit[depId].weight, "Depozit", false, function()
                    TriggerEvent("vRP:depositLeave", user_id, depId)
                end)
            end
        end
    end
end)