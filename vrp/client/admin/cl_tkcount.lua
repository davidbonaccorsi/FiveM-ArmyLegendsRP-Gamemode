RegisterNUICallback("sendAdminTicket", function(data, cb)
  TriggerServerEvent("vrp-admin:sendTicket", data)
  cb("ok")
end)

RegisterNUICallback("answerAdminTicket", function(data, cb)
  TriggerServerEvent("vrp-admin:answerTicket", data[1])
  cb("ok")
end)

RegisterNUICallback("skipAdminTicket", function(data, cb)
  TriggerServerEvent("vrp-admin:skipTicket", data[1])
  cb("ok")
end)
