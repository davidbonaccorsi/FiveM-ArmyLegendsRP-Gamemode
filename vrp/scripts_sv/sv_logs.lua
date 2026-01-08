local dbLog = true

local logsNr = 0
local cacheLogs = {}

AddEventHandler("onServerRestarting", function()
	if logsNr >= 1 then
		exports.mongodb:insert({collection = "serverLogs", documents = cacheLogs})
		cacheLogs = {}
		logsNr = 0
	end
end)

RegisterCommand('pushlogs', function(player)
	if (player == 0) then
		if logsNr >= 1 then
			exports.mongodb:insert({collection = "serverLogs", documents = cacheLogs})
			cacheLogs = {}
			logsNr = 0

			print("LOGS PUSHED TO DB")
		end
	end
end)

function vRP.createLog(user_id, details, lType, discordWeebhook, discordText)	
	if tonumber(lType) then
		if(lType == 1)then
			lType = "Transfer"
		elseif(lType == 2)then
			lType = "Purchase"
		elseif(lType == 3)then
			lType = "Fee"
		end
	end

	if discordWeebhook then
		PerformHttpRequest(discordWeebhook,function(err, text, headers)
		end, 'POST', json.encode({
			embeds = {{
				description = discordText,
				color = 0xFF6464,
				author = {
					name = (GetPlayerName(player) or 'Unknown') .. " [" .. vRP.getUserId(player) .. "]",
				},
				footer = {
					text = os.date("%d/%m/%y %H:%M")
				}
			}}
	
		}), {
			['Content-Type'] = 'application/json'
		})
	end

	local log = {user_id = user_id, details = details, type = lType, time = os.time()}
	table.insert(cacheLogs, log)
	logsNr = logsNr + 1

	if logsNr >= 10 then
		exports.mongodb:insert({collection = "serverLogs", documents = cacheLogs})
		cacheLogs = {}
		logsNr = 0
	end
end

function vRP.insertLog(user_id, details, lType)
	exports.mongodb:insertOne({collection = "serverLogs", document = {
		user_id = user_id,
		details = details,
		time = os.time(),
		type = lType
	}})
end