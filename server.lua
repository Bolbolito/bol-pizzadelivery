local QBCore = exports['qb-core']:GetCoreObject()
local currentAmount = {}

RegisterNetEvent('bol-pizzadelivery:giveMoney')
AddEventHandler('bol-pizzadelivery:giveMoney',function()
	local source = source
	local Player = QBCore.Functions.GetPlayer(source)
	if currentAmount[source] then
		local amount = currentAmount[source]
		currentAmount[source] = nil
		local finalAmount = amount * 2.0
		Player.Functions.AddMoney("cash", finalAmount, "sold-pizza")
		TriggerClientEvent("QBCore:Notify", source, "You recieved $"..finalAmount, "success")
	end
end)

RegisterNetEvent('bol-pizzadelivery:takeMoney')
AddEventHandler('bol-pizzadelivery:takeMoney',function()
	local source = source
	local Player = QBCore.Functions.GetPlayer(source)
	Player.Functions.RemoveMoney("bank", 50, source, "pizza-deposit")
	TriggerClientEvent("QBCore:Notify", source, "You did not return with your bike, therefore, you have been fined $50.", "error")
end)

RegisterNetEvent('bol-pizzadelivery:saveMoney')
AddEventHandler('bol-pizzadelivery:saveMoney',function(amount)
	local amount = amount/math.random(50,75)
	local fAmount = tonumber(string.format("%.0f",amount))
	if currentAmount[source] then
		currentAmount[source] = currentAmount[source] + fAmount
	else
		currentAmount[source] = 0
		currentAmount[source] = currentAmount[source] + fAmount
	end
end)

RegisterNetEvent('bol-pizzadelivery:defaultMe')
AddEventHandler('bol-pizzadelivery:defaultMe',function()
	if currentAmount[source] then
		currentAmount[source] = nil
	end
end)