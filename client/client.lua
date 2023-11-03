local bagEquipped, bagObj
local ox_inventory = exports.ox_inventory
local justConnect = true

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(4500)
        justConnect = nil
    end
    for k, v in pairs(changes) do
        if type(v) == 'table' then
            local count = ox_inventory:Search('count', 'wallet')
	        if count > 0 and (not bagEquipped or not bagObj) then
                PutOnBag()
            elseif count < 1 and bagEquipped then
                RemoveBag()
            end
        end
        if type(v) == 'boolean' then
            local count = ox_inventory:Search('count', 'wallet')
            if count < 1 and bagEquipped then
                RemoveBag()
            end
        end
    end
end)

exports('openWallet', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('grn_wallet:getNewIdentifier', 100, data.slot)
        ox_inventory:openInventory('stash', 'wallet_'..identifier)
    else
        TriggerServerEvent('grn_wallet:openWallet', slot.metadata.identifier)
        ox_inventory:openInventory('stash', 'wallet_'..slot.metadata.identifier)
    end
end)
