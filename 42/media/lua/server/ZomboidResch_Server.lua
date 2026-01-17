-- ZomboidResch Server Module
-- Spawning, server events, authoritative game logic

ZomboidResch = ZomboidResch or {}
ZomboidResch.Server = ZomboidResch.Server or {}

local function addToDistribution(containerName, itemType, chance)
    local container = ProceduralDistributions.list[containerName]
    if container and container.items then
        table.insert(container.items, itemType)
        table.insert(container.items, chance)
    end
end

local function initDistributions()
    local switchItem = "ZomboidResch.NintendoSwitch"

    -- Nintendo Switch distribution
    addToDistribution("BedroomDresser", switchItem, 0.5)
    addToDistribution("BedroomSideTable", switchItem, 0.3)
    addToDistribution("Wardrobe", switchItem, 0.2)
    addToDistribution("LivingRoomShelf", switchItem, 0.4)
    addToDistribution("LivingRoomSideTable", switchItem, 0.3)
    addToDistribution("CrateToys", switchItem, 0.8)
    addToDistribution("ShelvesEntertainment", switchItem, 0.6)
    addToDistribution("ElectronicStoreMisc", switchItem, 1.5)
    addToDistribution("GigamartElectronics", switchItem, 1.0)

    -- Cartridge distributions
    local cartridges = {
        "ZomboidResch.Cartridge_Fishing",
        "ZomboidResch.Cartridge_Cooking",
        "ZomboidResch.Cartridge_Mechanics",
        "ZomboidResch.Cartridge_Electrical",
        "ZomboidResch.Cartridge_Carpentry",
        "ZomboidResch.Cartridge_Aiming",
    }

    local distributions = {
        { container = "ElectronicStoreMisc", chance = 0.8 },
        { container = "GigamartElectronics", chance = 0.5 },
        { container = "CrateToys", chance = 0.4 },
        { container = "ShelvesEntertainment", chance = 0.3 },
        { container = "BedroomDresser", chance = 0.2 },
        { container = "LivingRoomShelf", chance = 0.2 },
        { container = "BedroomSideTable", chance = 0.15 },
    }

    for _, cartridge in ipairs(cartridges) do
        for _, dist in ipairs(distributions) do
            addToDistribution(dist.container, cartridge, dist.chance)
        end
    end
end

Events.OnPreDistributionMerge.Add(initDistributions)
