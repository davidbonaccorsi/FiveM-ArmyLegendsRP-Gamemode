
local cfg = {
    checkDuration = 30, -- secunde
}

local startable = {
    -- {money, duration}
    {25000, 1},
    {35000, 2},
    {50000, 5},
    {75000, 6},
    {100000, 8},
    {125000, 10},
    {200000, 12},
    {250000, 14},
}

local nextInvestments = {}

local investments, hoursInt = {}, {}

local function secondsToHours(seconds)
    local hours = math.floor(seconds / 3600)
    local remainder = seconds % 3600
    local minutes = math.floor(remainder / 60)
    local seconds = remainder % 60
    
    return hours, minutes, seconds
end  

local function updateTime(user_id, player)
    local inv = investments[user_id]
    local diff = os.time() - (hoursInt[user_id] or os.time())
    local timeGained = math.floor((diff / 60) * 100) / 100

    hoursInt[user_id] = os.time()
  
    inv.playtime = inv.playtime + timeGained

    local hours, minutes, seconds = secondsToHours(inv.playtime * 60)

    local done = hours >= inv.needtime
    if (os.time() >= (nextInvestments[user_id] or 0)) or done then
        local state = "loss"
        if done then
            vRP.giveMoney(user_id, inv.money*2)
            vRPclient.notify(player, {"Ai obtinut profit $"..vRP.formatMoney(inv.money), "success"})
            state = "finish"
        else
            vRPclient.notify(player, {"Ai pierdut investitia.\nPlaytime: "..hours.."h / "..inv.needtime.."h", "error"})
        end

        vRP.createLog(user_id, {name = GetPlayerName(player), state = state, amount = tonumber(inv.money) * 2, start = inv.time}, "Investments")
        investments[user_id] = nil
        vRP.updateUser(user_id, "investment", false)
    end
end


AddEventHandler("vRP:playerLeave", function(user_id)
    if investments[user_id] then
        vRP.updateUser(user_id, "investment", investments[user_id])
        investments[user_id] = nil
    end

    nextInvestments[user_id] = nil
    hoursInt[user_id] = nil
end)


local checkInterval = os.time() + cfg.checkDuration

function timeCheck()

	Citizen.CreateThread(function()
		SetTimeout(5000, timeCheck)
	end)
	

	if os.time() >= checkInterval then
		checkInterval = os.time() + cfg.checkDuration
		Citizen.CreateThread(function()
			for user_id, d in pairs(investments) do
				updateTime(user_id, vRP.getUserSource(user_id))
				Citizen.Wait(150)
			end
		end)
		TriggerEvent("vRP:investUpdate")
	end
end

timeCheck()

RegisterServerEvent("vrp-investments:start", function(invest)
    local player = source
    local user_id = vRP.getUserId(player)

    local user = vRP.getUser(user_id) or {}

    if investments[user_id] then
        vRPclient.notify(player, {"Ai deja o investitie activa.", "error"})
        return
    end

    if (nextInvestments[user_id] or 0) > os.time() then
        vRPclient.notify(player, {"Trebuie sa astepti inainte de a face o alta investitie!", "error"})
        return
    end

    local start = startable[invest]

    if start and vRP.tryFullPayment(user_id, start[1], false, false, "Investment "..invest) then
        if start[2] == 6 then
            exports.vrp:achieve(user_id, 'BusinessEasy', 1)
        end

        investments[user_id] = {
            playtime = 0.0,
            needtime = start[2],
            money = start[1],
            time = os.time()
        }
        
        vRP.updateUser(user_id, "investment", investments[user_id])

        local nextDay = os.time() + daysToSeconds(1)
        vRP.updateUser(user_id, "nextInvest", nextDay)
        nextInvestments[user_id] = nextDay

        vRPclient.notify(player, {"Ai inceput o investitie care se va termina in "..os.date("%d %b", nextDay)..".", "success"})
        vRP.createLog(user_id, {name = GetPlayerName(player), state = "start", amount = tonumber(start[1]), finish = nextDay}, "Investments")

        user.investedTimes = (user.investedTimes or 0) + 1
        vRP.updateUser(user_id, "investedTimes", user.investedTimes)
    else
        vRPclient.notify(player, {"Nu ai destui bani pentru a investi.", "error"})
    end
end)

local function remainingTime(tsX, tsY)
    local delta = tsY - tsX
    local hours = math.floor(delta / 3600)
    local minutes = math.floor((delta % 3600) / 60)
    
    return hours, minutes
end

local function calculatePercentage(number, max)
    local percentage = math.floor((number / max) * 100)
    return math.min(percentage, 100)
end

RegisterServerEvent("vrp-investments:openMenu", function()
    local player = source
    local user_id = vRP.getUserId(player)
    local investment = investments[user_id]

    local hours, minutes = 0, 0, 0

    local cooldown = false
    if (nextInvestments[user_id] or 0) > os.time() then
        cooldown = true
    end

    local progress = 0
    if investment then
        hours, minutes = remainingTime(os.time(), nextInvestments[user_id])

        local hours, minutes, seconds = secondsToHours(investment.playtime)
        progress = calculatePercentage(hours, investment.needtime)
    end

    TriggerClientEvent("vrp:sendNuiMessage", player, {
        interface = "investment",
        cooldown = cooldown,
        remaining = investment and (hours.."h "..minutes.."m") or false,
        progress = progress,
    })
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
    if first_spawn then
        
        if dbdata.nextInvest then
            nextInvestments[user_id] = dbdata.nextInvest
        end
        
        if dbdata.investment then
            investments[user_id] = dbdata.investment

            Citizen.Wait(150)
            updateTime(user_id, player)
        end
    end
end)
