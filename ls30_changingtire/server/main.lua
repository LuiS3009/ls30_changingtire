ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('pneu', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local chavef = xPlayer.getInventoryItem('chavematricula').count
	if chavef >= 1 then
		TriggerClientEvent('ls30_ changingtire:usar', _source)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Não tens nenhuma chave de fendas!'})
	end
end)

RegisterNetEvent('ls30_ changingtire:remover')
AddEventHandler('ls30_ changingtire:remover', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('pneu', 1)
	TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = 'Usas-te um pneu suplente'})
end)