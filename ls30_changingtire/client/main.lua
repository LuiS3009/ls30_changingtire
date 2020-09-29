local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX						= nil
local CurrentAction		= nil
local PlayerData		= {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('ls30_ changingtire:usar')
AddEventHandler('ls30_ changingtire:usar', function()
	animacao()
end)

function Maisproximo(vehicle)
	local tireBones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local tireIndex = {
		["wheel_lf"] = 0,
		["wheel_rf"] = 1,
		["wheel_lm1"] = 2,
		["wheel_rm1"] = 3,
		["wheel_lm2"] = 45,
		["wheel_rm2"] = 47,
		["wheel_lm3"] = 46,
		["wheel_rm3"] = 48,
		["wheel_lr"] = 4,
		["wheel_rr"] = 5,
	}
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local minDistance = 1.5
	local closestTire = nil
	
	for a = 1, #tireBones do
		local bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tireBones[a]))
		local distance = Vdist(plyPos.x, plyPos.y, plyPos.z, bonePos.x, bonePos.y, bonePos.z)

		if closestTire == nil then
			if distance <= minDistance then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		else
			if distance < closestTire.boneDist then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		end
	end

	return closestTire
end

function Draw3DText(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 28, 28, 28, 240)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local vehicle = Carromaisproximo()
		if vehicle ~= 0 then
			local closestTire = Maisproximo(vehicle)
			if closestTire ~= nil then
				if IsVehicleTyreBurst(vehicle, closestTire.tireIndex, 0) == false then
					Citizen.Wait(1500)
				else
					Draw3DText(closestTire.bonePos.x, closestTire.bonePos.y, closestTire.bonePos.z, "~r~Pneu danificado")
				end
			end
		end
	end
end)

function Carromaisproximo()
	local plyPed = GetPlayerPed(-1)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 0.3
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end

function animacao()
	FreezeEntityPosition(GetPlayerPed(-1), false)
	substituirpneu = true
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	prop = CreateObject(GetHashKey('prop_rub_tyre_01'), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309), 0.025, 0.11, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
	while substituirpneu do
		Citizen.Wait(250)
		local vehicle   = Carromaisproximo()
		local coords    = GetEntityCoords(GetPlayerPed(-1))
		LoadDict('anim@heists@box_carry@')
	
		if not IsEntityPlayingAnim(GetPlayerPed(-1), "anim@heists@box_carry@", "idle", 3 ) and substituirpneu == true then
			TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
		end
		
		if DoesEntityExist(vehicle) then
			substituirpneu = false
			TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_MEDIC_KNEEL", 0, false)
			ClearPedTasks(GetPlayerPed(-1))
			DeleteEntity(prop)
			TriggerServerEvent('ls30_ changingtire:remover')
				Citizen.CreateThread(function()
					CurrentAction = 'pneu'
					Citizen.Wait(5)
					if CurrentAction ~= nil then
						local closestTire = Maisproximo(vehicle)
						if closestTire ~= nil then
							SetVehicleTyreFixed(vehicle, closestTire.tireIndex)
							ClearPedTasksImmediately(GetPlayerPed(-1))
							TriggerEvent('mythic_progbar:client:progress', {
								name = '',
								duration = 30000,
								label = 'A substituir pneu...',
								useWhileDead = false,
								canCancel = true,
								controlDisables = {
									disableMovement = false,
									disableCarMovement = false,
									disableMouse =  false,
									disableCombat = true,
								},
								animation = {
									animDict = "anim@heists@box_carry@",
									anim = "idle",
									flags = 49,
								},
								prop = {"prop_rub_tyre_01"}
							})
							Citizen.Wait(2500)
							exports['mythic_notify']:SendAlert('inform',"A tirar os parafusos...")
							Citizen.Wait(5500)
							exports['mythic_notify']:SendAlert('inform',"A remover pneu danificado...")
							Citizen.Wait(5500)
							exports['mythic_notify']:SendAlert('inform',"A colocar o pneu suplente...")
							Citizen.Wait(5500)
							exports['mythic_notify']:SendAlert('inform',"A apertar parafusos...")
							Citizen.Wait(5500)
							exports['mythic_notify']:SendAlert('inform',"A verificar se está tudo OK...")
							Citizen.Wait(100)
							exports["mythic_notify"]:SendAlert('success', "Trocas-te o pneu")
						end
					end
					CurrentAction = nil
				end)
		end
	end
end

function LoadDict(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	  	Citizen.Wait(10)
    end
end

