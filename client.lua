local QBCore = exports['qb-core']:GetCoreObject()
local pizzeria, spawnfaggio = vector3(538.40, 101.35, 96.52), vector3(550.61, 124.21, 98.04)
local hasPizza, doingJob, currentDel, goingToHouse, isToPizzaria, count = false, false, 0, false, false, 0
local spawned_car = 0
local Blipy = {}

local delLocs = {
	[1] = {name = "Bay City Ave", coords = vector3(-1015.07, -1514.83, 6.51)},
	[2] = {name = "Bay City Ave", coords = vector3(-1083.03, -1631.47, 4.74)},
	[3] = {name = "Sandcastle Way", coords = vector3(-1318.34, -832.39, 16.97)},
	[4] = {name = "GWC & Golfing Society", coords = vector3(-1366.49, 56.61, 54.10)},
	[5] = {name = "Mad Wayne Thunder Drive", coords = vector3(-1294.23, 454.52, 97.54)},
	[6] = {name = "Barbareno Rd", coords = vector3(-3193.53, 1209.31, 9.43)},
	[7] = {name = "North Chumash", coords = vector3(-2305.04, 3427.33, 31.03)},
	[8] = {name = "Tonga Dr", coords = vector3(-1507.25, 1505.19, 115.29)},
	[9] = {name = "Cockingend Dr", coords = vector3(-950.49, 464.89, 80.80)},
	[10] = {name = "Cockingend Dr", coords = vector3(-1006.89, 512.73, 79.60)},
	[11] = {name = "Eclipse Blvd", coords = vector3(-361.29, 275.26, 86.42)},
	[12] = {name = "Eclipse Blvd", coords = vector3(-310.28, 222.16, 87.93)},
	[13] = {name = "Alta St", coords = vector3(241.69, 359.94, 105.61)},
	[14] = {name = "Brouge Ave", coords = vector3(130.53, -1853.33, 25.23)},
	[15] = {name = "Carson Ave", coords = vector3(320.13, -1853.95, 27.51)},
	[16] = {name = "Little Bighorn Ave", coords = vector3(548.05, -1572.99, 29.26)},
	[17] = {name = "Popular St", coords = vector3(868.85, -1639.82, 30.34)},
	[18] = {name = "Fudge Ln", coords = vector3(1214.37, -1644.01, 48.65)},
	[19] = {name = "El Rancho Blvd", coords = vector3(1365.47, -1721.41, 65.63)},
	[20] = {name = "El Rancho Blvd", coords = vector3(1383.82, -2079.39, 52.00)},
}

Citizen.CreateThread(function()
	Blipy['praca'] = AddBlipForCoord(pizzeria)
    SetBlipSprite(Blipy['praca'], 488)
    SetBlipDisplay(Blipy['praca'], 4)
    SetBlipScale(Blipy['praca'], 0.5)
    SetBlipAsShortRange(Blipy['praca'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Pizza Boy')
	EndTextCommandSetBlipName(Blipy['praca'])
end)

function CreateJBlip(delLocs,currentDel)
	local coords = delLocs[currentDel].coords
	blip_casa = AddBlipForCoord(coords)
	SetBlipSprite(blip_casa, 1)
	SetNewWaypoint(coords.x,coords.y)
end

function DrawText3DTest(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.37, 0.37)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0127, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function DeliverToHouse(coords)
	if goingToHouse then
		local ped = PlayerPedId()
		local DrawText = false
		local distance = nil
		local finish = false
		local notification = false
		local stop = false
		QBCore.Functions.Notify("Take the bike and head to "..delLocs[currentDel].name.." and deliver the Pizza.", "primary")
		Citizen.CreateThread(function()
			while true do
				Wait(1000)
				distance = #(coords - GetEntityCoords(ped))
				if distance < 20 then
					DrawText = true
				else
					DrawText = false
				end
				if finish then
					return
				end
			end
		end)
		Citizen.CreateThread(function()
			while true do
				Wait(0)
				if DrawText then
					if not notification then
						QBCore.Functions.Notify("Hop off the bike and grab the Pizza box.", "primary")
						notification = true
					end
					if not hasPizza and not stop then
						if not IsPedInAnyVehicle(ped, false) then
							GrabPizza()
							stop = true
						end
					end
					DrawText3DTest(coords, "Press [~g~E~s~] to deliver the Pizza")
					if distance < 5 then
						if IsControlJustPressed(1,38) and hasPizza then
							if spawned_car ~= GetVehiclePedIsIn(PlayerPedId(), true) then
								count = 1
								QBCore.Functions.Notify("Wrong vehicle.", "error")
							end
							TriggerServerEvent('bol-pizzadelivery:giveMoney')
							goingToHouse = false
							count = count - 1
							print("Detatching prop!")
							TaskPlayAnim(ped, "anim@heists@box_carry@", "exit", 3.0, 1.0, -1, 49, 0, 0, 0, 0 )
							DetachEntity(prop, 1, 1)
							DeleteObject(prop)
							Wait(1000)
							ClearPedSecondaryTask(ped)
							hasPizza = false
							if count <= 0 then
								GoingBack()
								isToPizzaria = true
								RemoveBlip(blip_casa)
							else
								RemoveBlip(blip_casa)
								NewJob(false)
							end
							finish = true
							if finish then
								return
							end
						end
					end
				else
					Wait(1000)
				end
			end
		end)
	end
end

function GrabPizza()
	local playerped = PlayerPedId()
    local coordA = GetEntityCoords(playerped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 20.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)
    if targetVehicle ~= 0 then
        local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
        local moveto = GetOffsetFromEntityInWorldCoords(targetVehicle, 1.0,d2["y"]-1.5,0.0)
        local dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(playerped))
        local count = 1000
		while dist > 1.0 and count > 0 do
			local something = vector3(moveto["x"],moveto["y"],moveto["z"])
            dist = #(something - GetEntityCoords(playerped))
            Citizen.Wait(1)
            count = count - 1
            DrawText3DTest(something,"Collect the Pizza box")
        end
        local timeout = 40
        NetworkRequestControlOfEntity(targetVehicle)
        while not NetworkHasControlOfEntity(targetVehicle) and timeout > 0 do 
            NetworkRequestControlOfEntity(targetVehicle)
            Citizen.Wait(100)
            timeout = timeout -1
        end
		if dist < 1.0 then
			print("GIVING PROP!")
			local ad = "anim@heists@box_carry@"
			
			loadAnimDict(ad)

			local x,y,z = table.unpack(GetEntityCoords(playerped))
            prop = CreateObject(GetHashKey("prop_pizza_box_01"), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, playerped, GetPedBoneIndex(playerped, 60309), 0.2, 0.08, 0.2, -45.0, 290.0, 0.0, true, true, false, true, 1, true)
			TaskPlayAnim(playerped, ad, "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
			hasPizza = true
        end
	end
end

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle
    for i = 0, 100 do
        rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)   
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        offset = offset - 1
        if vehicle ~= 0 then break end
    end
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    if distance > 25 then vehicle = nil end
    return vehicle ~= nil and vehicle or 0
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
		Citizen.Wait(0)
		RequestAnimDict(dict)
    end
end

function GoingBack()
	if isToPizzaria then
		SetNewWaypoint(pizzeria.x,pizzeria.y)
		local ped = PlayerPedId()
		local DrawText = false
		local distance = nil
		QBCore.Functions.Notify("Head back to the Pizzeria to collect more Pizza or end your shift.", "primary")
		Citizen.CreateThread(function()
			while true do
				Wait(1000)
				distance = #(pizzeria - GetEntityCoords(ped))
				if distance < 10 then
					DrawText = true
				else
					DrawText = false
				end
			end
		end)
		Citizen.CreateThread(function()
			while true do
				Wait(0)
				if DrawText then
					DrawText3DTest(coords, "Press [~g~E~s~] to refresh your shift")
					if distance < 5 then
						if IsControlJustPressed(1,38) then
							local vehicle = GetVehiclePedIsIn(ped, true)
							if IsVehicleModel(vehicle, `blazer3`) then
								goingToHouse, isToPizzaria, doingJob = false, false, false
								DelVeh()
								return
							else
								goingToHouse, isToPizzaria, doingJob = false, false, false
								TriggerServerEvent('bol-pizzadelivery:takeMoney')
								return
							end
						end
					else
						Wait(1000)
					end
				else
					Wait(1000)
				end
			end
		end)
	end
end

function NewJob(vehicle)
	Wait(500)
	local position = GetEntityCoords(PlayerPedId())
	doingJob, goingToHouse, currentDel, count = true, true, math.random(1, #delLocs), math.random(4, 10)
	local coords = delLocs[currentDel].coords
	local distance = round(#(position - coords))
	TriggerServerEvent('bol-pizzadelivery:saveMoney', distance)
	if vehicle then
		spawn_faggio()
	end
	CreateJBlip(delLocs,currentDel)
	DeliverToHouse(coords)
end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local shouldWait = true
		if not doingJob then
			local distance = #(pizzeria - GetEntityCoords(PlayerPedId()))
			if distance < 5 then
				shouldWait = false
				DrawText3DTest(pizzeria, "Press [~g~E~s~] to start job")
				if distance < 2 then
					if IsControlJustPressed(1,38) then
						NewJob(true)
					end
				end
			end
		elseif doingJob then
			local ped = PlayerPedId()
			local distance = #(pizzeria - GetEntityCoords(ped))
			if distance < 5 then
				shouldWait = false
				DrawText3DTest(pizzeria, "Press [~g~E~s~] to cancel job")
				if distance < 2 then
					if IsControlJustPressed(1,38) then
						count = 0
						local vehicle = GetVehiclePedIsIn(ped, true)
						goingToHouse, isToPizzaria, doingJob = false, false, false
						if IsVehicleModel(vehicle, `blazer3`) then
							DelVeh()
							TriggerServerEvent('bol-pizzadelivery:defaultMe')
						else
							TriggerServerEvent('bol-pizzadelivery:takeMoney')
							TriggerServerEvent('bol-pizzadelivery:defaultMe')
						end
						RemoveBlip(blip_casa)
					end
				end
			end
		else
			Wait(1000)
		end
		if shouldWait then
			Wait(1000)
		end
	end
end)

function spawn_faggio()
	local ped = PlayerPedId()
	local vehicle = `blazer3`
	RequestModel(vehicle)
	while not HasModelLoaded(vehicle) do
		Wait(1)
	end
	spawned_car = CreateVehicle(vehicle, spawnfaggio.x,spawnfaggio.y,spawnfaggio.z, 431.436, - 996.786, 25.1887, true, false)
	SetVehicleOnGroundProperly(spawned_car)
	SetPedIntoVehicle(ped, spawned_car, - 1)
	TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(spawned_car))
	exports['ps-fuel']:SetFuel(spawned_car, 100.0)
	SetModelAsNoLongerNeeded(spawned_car)
	SetEntityAsNoLongerNeeded(spawned_car)
end

function round(num, numDecimalPlaces)
	local mult = 5^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function DelVeh()
    QBCore.Functions.Notify('Work Vehicle Stored!')
    local car = GetVehiclePedIsIn(PlayerPedId(),true)
    NetworkFadeOutEntity(car, true, false)
    Citizen.Wait(2000)
    QBCore.Functions.DeleteVehicle(car)
end