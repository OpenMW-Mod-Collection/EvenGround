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

---@param arg NewChanceArgument
---@return table
local function newChance(arg)
    return {
        key = arg.key,
        name = arg.key .. "_name",
        description = arg.key .. "_desc",
        renderer = "multinumber",
        default = {
            baseChance = arg.baseChance,
            levelMult  = arg.levelMult,
            minChance  = arg.minChance,
            maxChance  = arg.maxChance,
        },
        argument = {
            keys = {
                "baseChance",
                "levelMult",
                "minChance",
                "maxChance",
            },
            aliases = {
                baseChance = l10n("baseChance"),
                levelMult  = l10n("levelMult"),
                minChance  = l10n("minChance"),
                maxChance  = l10n("maxChance"),
            },
            min = {
                minChance = 0,
                maxChance = 0,
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
            key        = "racialPower",
            baseChance = -50,
            levelMult  = 5,
            minChance  = 5,
            maxChance  = 50,
        },
        newChance {
            key        = "birthsign",
            baseChance = 0,
            levelMult  = 1.2,
            minChance  = 5,
            maxChance  = 50,
        },
        newChance {
            key        = "birthsignPower",
            baseChance = 25,
            levelMult  = 0,
            minChance  = 0,
            maxChance  = 100,
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
            key = "blacklist",
            name = "blacklist_name",
            description = "blacklist_desc",
            renderer = "textSet",
            argument = {
                lower = true,
            },
            default = {},
        },
        {
            key = "whitelist",
            name = "whitelist_name",
            description = "whitelist_desc",
            renderer = "textSet",
            argument = {
                lower = true,
            },
            default = {
                umbra = true,
                gaenor = true,
                gaenor_b = true,
                ["snowy granius"] = true,
                ["boss crito"] = true,
                ["king hlaalu helseth"] = true,
            },
        },
        {
            key = 'whitelistFactionLeaders',
            name = 'whitelistFactionLeaders_name',
            renderer = 'checkbox',
            default = true,
        },
    },
}
