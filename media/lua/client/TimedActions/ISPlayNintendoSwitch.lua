require "TimedActions/ISBaseTimedAction"

ISPlayNintendoSwitch = ISBaseTimedAction:derive("ISPlayNintendoSwitch")

local BATTERY_DRAIN_RATE = 0.0008

function ISPlayNintendoSwitch:isValid()
    if not self.character:getInventory():contains(self.item) then
        return false
    end
    -- Stop if battery runs out
    if self.item:getUsedDelta() <= 0 then
        return false
    end
    return true
end

function ISPlayNintendoSwitch:update()
    -- Drain battery
    local newDelta = self.item:getUsedDelta() - (BATTERY_DRAIN_RATE * getGameTime():getMultiplier())
    if newDelta <= 0 then
        self.item:setUsedDelta(0)
        return
    end
    self.item:setUsedDelta(newDelta)

    local multiplier = getGameTime():getMultiplier()

    -- Gradually reduce boredom, unhappiness, and stress while playing (base effects)
    local stats = self.character:getStats()
    local bodyDamage = self.character:getBodyDamage()

    stats:setBoredom(stats:getBoredom() - 0.15 * multiplier)
    bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() - 0.08 * multiplier)
    stats:setStress(stats:getStress() - 0.05 * multiplier)

    -- Apply skill XP if cartridge is inserted
    local cartridgeType = ZomboidResch.getInsertedCartridge(self.item)
    if cartridgeType then
        local cartridgeData = ZomboidResch.getCartridgeData(cartridgeType)
        if cartridgeData and cartridgeData.skill and cartridgeData.xpRate then
            local perk = Perks[cartridgeData.skill]
            if perk then
                self.character:getXp():AddXP(perk, cartridgeData.xpRate * multiplier)
            end
        end
    end
end

function ISPlayNintendoSwitch:start()
    self:setActionAnim("HoldItem")
    self.character:setSecondaryHandItem(self.item)
end

function ISPlayNintendoSwitch:stop()
    self.character:setSecondaryHandItem(nil)
    ISBaseTimedAction.stop(self)
end

function ISPlayNintendoSwitch:perform()
    self.character:setSecondaryHandItem(nil)
    ISBaseTimedAction.perform(self)
end

function ISPlayNintendoSwitch:new(character, item, time)
    local o = ISBaseTimedAction.new(self, character)
    o.item = item
    o.maxTime = time
    o.stopOnWalk = true
    o.stopOnRun = true
    return o
end
