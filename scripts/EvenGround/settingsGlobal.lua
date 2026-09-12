---@omw-context global
local I = require('openmw.interfaces')
local core = require("openmw.core")

local l10n = core.l10n("EvenGround")

---@class NewChanceArgument
---@field key string
---@field baseChance number
---@field levelMult number
---@field minChance number
---@field maxChance number
---@field guaranteedAt number

---@param arg NewChanceArgument
---@return table
local function newChance(arg)
    return {
        key = arg.key,
        name = arg.key .. "_name",
        description = arg.key .. "_desc",
        renderer = "multinumber",
        default = {
            baseChance   = arg.baseChance,
            levelMult    = arg.levelMult,
            minChance    = arg.minChance,
            maxChance    = arg.maxChance,
            guaranteedAt = arg.guaranteedAt,
        },
        argument = {
            keys = {
                "baseChance",
                "levelMult",
                "minChance",
                "maxChance",
                "guaranteedAt",
            },
            aliases = {
                baseChance   = l10n("baseChance"),
                levelMult    = l10n("levelMult"),
                minChance    = l10n("minChance"),
                maxChance    = l10n("maxChance"),
                guaranteedAt = l10n("guaranteedAt"),
            },
            min = {
                minChance = 0,
                maxChance = 0,
                guaranteedAt = 1,
            },
            max = {
                minChance = 100,
                maxChance = 100,
            },
            integer = false,
        },
    }
end

I.Settings.registerGroup {
    key = 'SettingsEvenGround_toggles',
    page = 'EvenGround',
    l10n = "EvenGround",
    name = "toggles_groupName",
    order = 0,
    permanentStorage = true,
    settings = {
        {
            key = 'enabled',
            name = 'enabled_name',
            description = 'enabled_desc',
            renderer = 'multiCheckbox',
            default = {
                racialPowers = true,
                birthsigns = true,
                birthsignPowers = true,
            },
            argument = {
                l10n = 'EvenGround',
                keys = {
                    'racialPowers',
                    'birthsigns',
                    'birthsignPowers',
                },
                colorful = true,
            },
        },
        {
            key = 'log',
            name = 'log_name',
            renderer = 'checkbox',
            default = false,
        },
    },
}

I.Settings.registerGroup {
    key = 'SettingsEvenGround_chances',
    page = 'EvenGround',
    l10n = "EvenGround",
    name = "chances_groupName",
    description = "chances_groupDesc",
    order = 1,
    permanentStorage = true,
    settings = {
        newChance {
            key          = "racialPower",
            baseChance   = -50,
            levelMult    = 5,
            minChance    = 5,
            maxChance    = 50,
            guaranteedAt = 50,
        },
        newChance {
            key          = "birthsign",
            baseChance   = 0,
            levelMult    = 1.2,
            minChance    = 5,
            maxChance    = 50,
            guaranteedAt = 50,
        },
        newChance {
            key          = "birthsignPower",
            baseChance   = 25,
            levelMult    = 0,
            minChance    = 0,
            maxChance    = 100,
            guaranteedAt = 50,
        },
    },
}

I.Settings.registerGroup {
    key = 'SettingsEvenGround_lists',
    page = 'EvenGround',
    l10n = "EvenGround",
    name = "lists_groupName",
    order = 1,
    permanentStorage = true,
    settings = {
        {
            key = "birthsignBlacklist",
            name = "birthsignBlacklist_name",
            description = "birthsignBlacklist_desc",
            renderer = "textSet",
            default = {},
            argument = {
                lower = true,
                label = "Birthsign Id",
            },
        },
        {
            key = "spellBlacklist",
            name = "spellBlacklist_name",
            description = "spellBlacklist_desc",
            renderer = "textSet",
            default = {},
            argument = {
                lower = true,
                label = "Spell Id",
            },
        },
        {
            key = "npcBlacklist",
            name = "npcBlacklist_name",
            description = "npcBlacklist_desc",
            renderer = "textSet",
            default = {},
            argument = {
                lower = true,
                label = "NPC Id",
            },
        },
        {
            key = "npcWhitelist",
            name = "npcWhitelist_name",
            description = "npcWhitelist_desc",
            renderer = "textSet",
            default = {
                umbra = true,
                gaenor = true,
                gaenor_b = true,
                ["snowy granius"] = true,
                ["boss crito"] = true,
                ["king hlaalu helseth"] = true,
                fargoth = true,
            },
            argument = {
                lower = true,
                label = "NPC Id",
            },
        },
        {
            key = 'whitelistFactionLeaders',
            name = 'whitelistFactionLeaders_name',
            renderer = 'checkbox',
            default = true,
        },
        {
            key = "birthsignOverride",
            name = "birthsignOverride_name",
            description = "birthsignOverride_desc",
            renderer = "textSet",
            default = {
                ["caius cosades>warwyrd"] = true,
                ["fargoth>lady's favor"] = true,
            },
            argument = {
                lower = true,
                label = "NPC Id>Birthsign Id",
            },
        },
    },
}
