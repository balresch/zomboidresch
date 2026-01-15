-- ZomboidResch Shared Module
-- Loaded first, available to both client and server

ZomboidResch = ZomboidResch or {}

-- Cartridge definitions: itemType -> { skill, xpRate, displayName }
ZomboidResch.Cartridges = {
    ["ZomboidResch.Cartridge_Fishing"] = {
        skill = "Fishing",
        xpRate = 0.5,
        displayName = "Bass Master Pro",
    },
    ["ZomboidResch.Cartridge_Cooking"] = {
        skill = "Cooking",
        xpRate = 0.5,
        displayName = "Cooking Mama",
    },
    ["ZomboidResch.Cartridge_Mechanics"] = {
        skill = "Mechanics",
        xpRate = 0.4,
        displayName = "Car Mechanic Sim",
    },
    ["ZomboidResch.Cartridge_Electrical"] = {
        skill = "Electricity",
        xpRate = 0.4,
        displayName = "Circuit Builder",
    },
    ["ZomboidResch.Cartridge_Carpentry"] = {
        skill = "Woodwork",
        xpRate = 0.4,
        displayName = "Bob's Workshop",
    },
    ["ZomboidResch.Cartridge_Aiming"] = {
        skill = "Aiming",
        xpRate = 0.3,
        displayName = "Duck Hunt",
    },
}

function ZomboidResch.getCartridgeData(cartridgeType)
    return ZomboidResch.Cartridges[cartridgeType]
end

function ZomboidResch.getInsertedCartridge(switchItem)
    local modData = switchItem:getModData()
    return modData.insertedCartridge
end

function ZomboidResch.setInsertedCartridge(switchItem, cartridgeType)
    local modData = switchItem:getModData()
    modData.insertedCartridge = cartridgeType
end
