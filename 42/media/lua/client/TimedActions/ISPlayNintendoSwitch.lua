require "TimedActions/ISBaseTimedAction"

ISPlayNintendoSwitch = ISBaseTimedAction:derive("ISPlayNintendoSwitch")

local BATTERY_DRAIN_RATE = 0.0008

function ISPlayNintendoSwitch:isValid()
    if not self.character:getInventory():contains(self.item) then
        return false
    end
    -- Stop if battery runs out
    if self.item:getCurrentUsesFloat() <= 0 then
        return false
    end
    return true
end

function ISPlayNintendoSwitch:update()
    -- Drain battery
    local newDelta = self.item:getCurrentUsesFloat() - (BATTERY_DRAIN_RATE * getGameTime():getMultiplier())
    if newDelta <= 0 then
        self.item:setUsedDelta(0)
        return
    end
    self.item:setUsedDelta(newDelta)

    local multiplier = getGameTime():getMultiplier()

    -- Gradually reduce boredom, unhappiness, and stress while playing (base effects)
    local stats = self.character:getStats()

    stats:remove(CharacterStat.BOREDOM, 0.15 * multiplier)
    stats:remove(CharacterStat.UNHAPPINESS, 0.08 * multiplier)
    stats:remove(CharacterStat.STRESS, 0.05 * multiplier)

    -- Apply skill XP if cartridge is inserted
    local cartridgeType = ZomboidResch.getInsertedCartridge(self.item)
    if cartridgeType then
        local cartridgeData = ZomboidResch.getCartridgeData(cartridgeType)
        if cartridgeData and cartridgeData.skill and cartridgeData.xpRate then
            local perk = Perks.FromString(cartridgeData.skill)
            if perk then
                self.character:getXp():AddXP(perk, cartridgeData.xpRate * multiplier)
            end
        end
    end
end

function ISPlayNintendoSwitch:start()
    self:setAnimVariable("ReadType", "book")
    self:setActionAnim(CharacterActionAnims.Read)
    self:setOverrideHandModels(nil, self.item)
end

function ISPlayNintendoSwitch:stop()
    ISBaseTimedAction.stop(self)
end

function ISPlayNintendoSwitch:perform()
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
