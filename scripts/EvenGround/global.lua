---@diagnostic disable: need-check-nil
---@omw-context global
local types = require("openmw.types")
local storage = require("openmw.storage")
local async = require("openmw.async")
local core = require("openmw.core")
local world = require("openmw.world")

local settingsCache = require("scripts.EvenGround.utils.settingsCache")

local toggles = settingsCache.new(
    storage.globalSection("SettingsEvenGround_toggles"),
    async
)
local chances = settingsCache.new(
    storage.globalSection("SettingsEvenGround_chances"),
    async
)
local lists = settingsCache.new(
    storage.globalSection("SettingsEvenGround_lists"),
    async
)
local birthsignRecords = types.Player.birthSigns.records
local raceRecords = types.NPC.races.records
local spellRecords = core.magic.spells.records
local factionRecords = core.factions.records

local recordedNPCs = {}

---@class NPCInfo
---@field npc openmw.GObject
---@field level number
---@field record openmw.types.NpcRecord
---@field whitelisted boolean
---@field blackslisted boolean

---@param msg string
local function log(msg, ...)
    if toggles.log then
        print(msg:format(...))
    end
end

---@param config table
---@param npcInfo NPCInfo
---@return boolean
local function qualifies(config, npcInfo)
    if npcInfo.blackslisted then
        return false
    end

    if npcInfo.whitelisted then
        return true
    end

    if npcInfo.level >= config.guaranteedAt then
        return true
    end

    local chance = config.baseChance + npcInfo.level * config.levelMult
    chance = math.max(config.minChance, math.min(config.maxChance, chance))
    return math.random(100) > chance
end

---@param npcInfo NPCInfo
local function giveBirthsign(npcInfo)
    if not toggles.enabled.birthsigns then
        return
    end

    if not qualifies(chances.birthsign, npcInfo) then
        log("Birthsign roll failed for '%s'", npcInfo.npc.recordId)
        return
    end

    local birthsign = birthsignRecords[math.random(#birthsignRecords)]
    log("Assigning birthsign '%s' to '%s'", birthsign.id, npcInfo.npc.recordId)
    local npcSpells = types.NPC.spells(npcInfo.npc)
    for _, spellId in ipairs(birthsign.spells) do
        local spell = spellRecords[spellId]
        if spell.type == core.magic.SPELL_TYPE.Power and qualifies(chances.birthsignPower, npcInfo) then
            log("Granting birthsign power '%s' to '%s'", spellId, npcInfo.npc.recordId)
            npcInfo.npc:sendEvent("NPCPowers_addPower", spellId)
        elseif spell.type == core.magic.SPELL_TYPE.Ability then
            log("Adding birthsign ability '%s' to '%s'", spellId, npcInfo.npc.recordId)
            npcSpells:add(spellId)
        end
    end
end

---@param npcInfo NPCInfo
local function giveRacialPowers(npcInfo)
    if not toggles.enabled.racialPowers then
        return
    end

    local race = npcInfo.record.race
    for _, spellId in ipairs(raceRecords[race].spells) do
        local spell = spellRecords[spellId]
        if spell.type == core.magic.SPELL_TYPE.Power and qualifies(chances.racialPower, npcInfo) then
            log("Granting racial power '%s' to '%s' (race '%s')", spellId, npcInfo.npc.recordId, race)
            npcInfo.npc:sendEvent("NPCPowers_addPower", spellId)
        end
    end
end

---@param npc openmw.GObject
---@return boolean
local function isWhitelisted(npc)
    if lists.blacklist[npc.recordId] then
        return false
    end

    if lists.whitelist[npc.recordId] then
        return true
    end

    if lists.whitelistFactionLeaders then
        for _, factionId in ipairs(types.NPC.getFactions(npc)) do
            local faction = factionRecords[factionId]
            if types.NPC.getFactionRank(npc, factionId) == #faction.ranks then
                return true
            end
        end
    end

    return false
end

---@param actor openmw.GObject
local function onActorActive(actor)
    if not types.NPC.objectIsInstance(actor) and not types.Player.objectIsInstance(actor) then
        return
    elseif recordedNPCs[actor.id] then
        log("Skipping an already processed NPC: %s", actor.recordId)
        return
    end

    recordedNPCs[actor.id] = true
    log("Processing new NPC: %s", actor.recordId)
    local npcInfo = {
        npc = actor,
        level = types.NPC.stats.level(actor).current,
        record = types.NPC.records[actor.recordId],
        whitelisted = isWhitelisted(actor),
        blacklisted = lists.blacklist[actor.recordId],
    }

    giveRacialPowers(npcInfo)
    giveBirthsign(npcInfo)
end

local function onSave()
    return {
        recordedNPCs = recordedNPCs
    }
end

local function onLoad(data)
    if not data then return end
    recordedNPCs = data.recordedNPCs or recordedNPCs
end

for _, actor in ipairs(world.activeActors) do
    onActorActive(actor)
end

return {
    engineHandlers = {
        onActorActive = onActorActive,
        onSave = onSave,
        onLoad = onLoad,
    }
}
