local registeredStashes = {}
local ox_inventory = exports.ox_inventory

RegisterServerEvent('grn_wallet:openWallet')
AddEventHandler('grn_wallet:openWallet', function(identifier)
	if not registeredStashes[identifier] then
        ox_inventory:RegisterStash('wallet_'..identifier, 'Wallet', false)
        registeredStashes[identifier] = true
    end
end)

lib.callback.register('grn_wallet:getNewIdentifier', function(source, slot)
	local newId = GenerateSerial()
	ox_inventory:SetMetadata(source, slot, {identifier = newId})
	ox_inventory:RegisterStash('wallet_'..newId, 'Wallet', false)
	registeredStashes[newId] = true
	return newId
end)

CreateThread(function()
	while GetResourceState('ox_inventory') ~= 'started' do Wait(500) end
	local swapHook = ox_inventory:registerHook('swapItems', function(payload)
		local start, destination, move_type = payload.fromInventory, payload.toInventory, payload.toType
		local count_wallets = ox_inventory:GetItem(payload.source, 'wallet', nil, true)
	
		if string.find(destination, 'wallet_') then
			TriggerClientEvent('ox_lib:notify', payload.source, {type = 'error', title = Strings.action_incomplete, description = Strings.backpack_in_backpack}) -- You can replace it for your notify script
			return false
		end
		if Config.OneWalletInInventory then
			if (count_wallets > 0 and move_type == 'player' and destination ~= start) then
				TriggerClientEvent('ox_lib:notify', payload.source, {type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only}) -- You can replace it for your notify script
				return false
			end
		end
		
		return true
	end, {
		print = false,
		itemFilter = {
			backpack = true,
		},
	})
	
	local createHook
	if Config.OneWalletInInventory then
		createHook = exports.ox_inventory:registerHook('createItem', function(payload)
			local count_wallets = ox_inventory:GetItem(payload.inventoryId, 'wallet', nil, true)
			local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)
	
	
			if count_wallets > 0 then
				local slot = nil
	
				for i,k in pairs(playerItems) do
					if k.name == 'wallet' then
						slot = k.slot
						break
					end
				end
	
				Citizen.CreateThread(function()
					local inventoryId = payload.inventoryId
					local dontRemove = slot
					Citizen.Wait(1000)
	
					for i,k in pairs(ox_inventory:GetInventoryItems(inventoryId)) do
						if k.name == 'wallet' and dontRemove ~= nil and k.slot ~= dontRemove then
							local success = ox_inventory:RemoveItem(inventoryId, 'wallet', 1, nil, k.slot)
							if success then
								TriggerClientEvent('ox_lib:notify', inventoryId, {type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only}) -- You can replace it for your notify script
							end
							break
						end
					end
				end)
			end
		end, {
			print = false,
			itemFilter = {
				backpack = true
			}
		})
	end
	
	function DiscordLogs(color, name, message)
		local embed = {
			  {
				  ["color"] = color,
				  ["title"] = "**".. name .."**",
				  ["description"] = message,
			  }
		  }
		PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.BotName, embeds = embed}), { ['Content-Type'] = 'application/json' })
	  end

	AddEventHandler('onResourceStop', function()
		ox_inventory:removeHooks(swapHook)
		if Config.OneWalletInInventory then
			ox_inventory:removeHooks(createHook)
		end
	end)
end)
