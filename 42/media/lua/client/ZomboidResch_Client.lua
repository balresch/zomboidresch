-- ZomboidResch Client Module
-- UI, context menus, timed actions, client-side logic

require "ISUI/ISPanel"
require "TimedActions/ISPlayNintendoSwitch"

ZomboidResch = ZomboidResch or {}
ZomboidResch.Client = ZomboidResch.Client or {}

-- Play duration in ticks (200 = ~20 seconds of play time)
ZomboidResch.Client.PLAY_TIME = 200
-- How much charge one battery adds (0.0 to 1.0)
ZomboidResch.Client.BATTERY_CHARGE = 0.5

function ZomboidResch.Client.onPlayNintendoSwitch(player, item)
    ISTimedActionQueue.add(ISPlayNintendoSwitch:new(player, item, ZomboidResch.Client.PLAY_TIME))
end

function ZomboidResch.Client.onInsertBattery(player, switchItem, battery)
    local currentCharge = switchItem:getCurrentUsesFloat()
    local newCharge = math.min(1.0, currentCharge + ZomboidResch.Client.BATTERY_CHARGE)
    switchItem:setUsedDelta(newCharge)
    player:getInventory():Remove(battery)
end

function ZomboidResch.Client.onInsertCartridge(player, switchItem, cartridge)
    local cartridgeType = cartridge:getFullType()

    -- If there's already a cartridge, return it to inventory first
    local currentCartridge = ZomboidResch.getInsertedCartridge(switchItem)
    if currentCartridge then
        local oldCartridge = instanceItem(currentCartridge)
        if oldCartridge then
            player:getInventory():AddItem(oldCartridge)
        end
    end

    -- Set the new cartridge
    ZomboidResch.setInsertedCartridge(switchItem, cartridgeType)

    -- Remove the cartridge item from inventory
    player:getInventory():Remove(cartridge)
end

function ZomboidResch.Client.onRemoveCartridge(player, switchItem)
    local currentCartridge = ZomboidResch.getInsertedCartridge(switchItem)
    if currentCartridge then
        local cartridge = instanceItem(currentCartridge)
        if cartridge then
            player:getInventory():AddItem(cartridge)
        end
        ZomboidResch.setInsertedCartridge(switchItem, nil)
    end
end

function ZomboidResch.Client.getBatteryTooltip(item)
    local charge = item:getCurrentUsesFloat()
    local percent = math.floor(charge * 100)
    return "Battery: " .. percent .. "%"
end

function ZomboidResch.Client.getCurrentGameTooltip(switchItem)
    local cartridgeType = ZomboidResch.getInsertedCartridge(switchItem)
    if cartridgeType then
        local data = ZomboidResch.getCartridgeData(cartridgeType)
        if data then
            return "Current Game: " .. data.displayName .. " <LINE> <RGB:0.5,1,0.5> +" .. data.skill .. " XP while playing"
        end
    end
    return "Current Game: Built-in Games <LINE> <RGB:0.7,0.7,0.7> No skill bonus"
end

function ZomboidResch.Client.getCartridgesInInventory(inventory)
    local cartridges = {}
    local items = inventory:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local fullType = item:getFullType()
        if ZomboidResch.Cartridges[fullType] then
            table.insert(cartridges, item)
        end
    end
    return cartridges
end

function ZomboidResch.Client.onFillInventoryContextMenu(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)
    local inventory = player:getInventory()

    for i = 1, #items do
        local item = items[i]
        -- Handle item stacks
        if not instanceof(item, "InventoryItem") then
            item = item.items[1]
        end

        if item:getFullType() == "ZomboidResch.NintendoSwitch" then
            local charge = item:getCurrentUsesFloat()
            local hasBattery = charge > 0

            -- Play option (disabled if no battery)
            local playOption = context:addOption("Play Nintendo Switch", player, ZomboidResch.Client.onPlayNintendoSwitch, item)
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip:setName("Nintendo Switch")
            tooltip.description = ZomboidResch.Client.getBatteryTooltip(item) .. " <LINE> " .. ZomboidResch.Client.getCurrentGameTooltip(item)
            playOption.toolTip = tooltip

            if not hasBattery then
                playOption.notAvailable = true
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0.3,0.3> Needs batteries!"
            end

            -- Insert Cartridge submenu
            local cartridgesInInventory = ZomboidResch.Client.getCartridgesInInventory(inventory)
            if #cartridgesInInventory > 0 then
                local insertSubmenu = context:getNew(context)
                local insertOption = context:addOption("Insert Cartridge", nil, nil)
                context:addSubMenu(insertOption, insertSubmenu)

                for _, cartridge in ipairs(cartridgesInInventory) do
                    local cartridgeData = ZomboidResch.getCartridgeData(cartridge:getFullType())
                    if cartridgeData then
                        local cartridgeOption = insertSubmenu:addOption(
                            cartridgeData.displayName,
                            player,
                            ZomboidResch.Client.onInsertCartridge,
                            item,
                            cartridge
                        )
                        local cartridgeTip = ISWorldObjectContextMenu.addToolTip()
                        cartridgeTip:setName(cartridgeData.displayName)
                        cartridgeTip.description = "<RGB:0.5,1,0.5> +" .. cartridgeData.skill .. " XP while playing"
                        cartridgeOption.toolTip = cartridgeTip
                    end
                end
            end

            -- Remove Cartridge option
            local insertedCartridge = ZomboidResch.getInsertedCartridge(item)
            if insertedCartridge then
                local cartridgeData = ZomboidResch.getCartridgeData(insertedCartridge)
                local removeName = "Remove Cartridge"
                if cartridgeData then
                    removeName = "Remove " .. cartridgeData.displayName
                end
                context:addOption(removeName, player, ZomboidResch.Client.onRemoveCartridge, item)
            end

            -- Insert battery option
            local battery = inventory:getFirstTypeRecurse("Base.Battery")
            if battery then
                local batteryOption = context:addOption("Insert Battery", player, ZomboidResch.Client.onInsertBattery, item, battery)
                local currentCharge = item:getCurrentUsesFloat()
                if currentCharge >= 1.0 then
                    batteryOption.notAvailable = true
                    local tipFull = ISWorldObjectContextMenu.addToolTip()
                    tipFull:setName("Insert Battery")
                    tipFull.description = "Battery is already full"
                    batteryOption.toolTip = tipFull
                end
            end
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ZomboidResch.Client.onFillInventoryContextMenu)
