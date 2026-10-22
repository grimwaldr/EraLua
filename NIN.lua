local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
NIN - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Sets ending in _Priority take a list per slot; the first item you own at your level is used (good for level sync).
Ninjutsu: Utsusemi -> Haste then Utsusemi; elemental ninjutsu -> Ninjutsu, Nuke + obi; everything else -> Ninjutsu.
Utsusemi: Ichi only cancels shadows when they came from Ni (Phoenix overwrite rules). Monomi/Tonko cancel their own buff first.
WS: Blade: Teki / To / Chi / Ei share Ws_Elemental.
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = {
        Head = {'Emperor Hairpin'},
        Feet = {'Leaping Boots'},
    },
    Resting_Priority = {
    },
    Idle_Regen = { -- gcinclude.CheckDefault looks these two up by name, they have to exist even if empty
    },
    Idle_Refresh = {
    },
    Town_Priority = {
    },

    Dt = { -- kept empty on purpose: gcinclude's low-HP auto-swap force-equips this with no combat-status check, populating it caused Tp gear to get clobbered mid-fight
    },

    Tp_Default_Priority = {
        -- Main = { },  -- katanas best-first, uncomment once you add yours
        -- Sub = { },
        Head = {'Emperor Hairpin'},
        Neck = {'Peacock Amulet', 'Spike Necklace'},
        Feet = {'Leaping Boots'},
    },
    Tp_Hybrid_Priority = {
    },
    Tp_Acc_Priority = {
        Neck = {'Peacock Amulet'},
    },

    Precast_Priority = {
    },

    Haste_Priority = { -- folded into Utsusemi midcast for recast
    },

    Utsusemi_Priority = {
    },
    Nuke_Priority = { -- INT / magic attack for Katon, Hyoton, etc.
    },
    Ninjutsu_Priority = { -- Kurayami, Hojo, Jubaku, Dokumori
    },

    Preshot_Priority = {
    },
    Midshot_Priority = {
    },

    Ws_Default_Priority = {
    },
    Ws_Hybrid_Priority = {
    },
    Ws_Acc_Priority = {
    },

    Ws_BladeRin_Priority = { -- STR/DEX crit WS
        Neck = {'Spike Necklace'},
        Feet = {'Leaping Boots'},
    },
    Ws_BladeRin_Hybrid_Priority = {},
    Ws_BladeRin_Acc_Priority = {},

    Ws_BladeRetsu_Priority = { -- DEX, paralyze proc, stack DEX and accuracy
        Head = {'Emperor Hairpin'},
        Neck = {'Spike Necklace'},
        Feet = {'Leaping Boots'},
    },
    Ws_BladeRetsu_Hybrid_Priority = {},
    Ws_BladeRetsu_Acc_Priority = {
        Neck = {'Peacock Amulet'},
    },

    Ws_Elemental_Priority = { -- Blade: Teki / To / Chi / Ei, magic-damage WS so STR + INT + magic attack
    },
    Ws_Elemental_Hybrid_Priority = {},
    Ws_Elemental_Acc_Priority = {},

    Enmity_Priority = {
    },

    Movement_Priority = {
    },
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Shihei', Quantity = 'all'},
};

-- Utsusemi (n/+n) and Monomi/Tonko (x/+x) come from gcinclude.
profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Butsuon inv'},
    {'!y', '/tell Cidant inv'},
    {'q', '/ws "Blade: Retsu" <t>'},
    {'+q', '/ws "Blade: Rin" <t>'},
    {'^q', '/ws "Blade: Teki" <t>'},
    {'!q', '/ws "Blade: To" <t>'},
    {'e', '/ja "Provoke" <t>'},
    {'1', '/ja "Berserk" <me>'},
    {'2', '/ja "Warcry" <me>'},
    {'u', '/ma "Kurayami: Ichi" <t>'},
    {'+u', '/ma "Hojo: Ichi" <t>'},
    {'^u', '/ma "Jubaku: Ichi" <t>'},
    {'!u', '/ma "Dokumori: Ichi" <t>'},
};

profile.WsAlias = {
    ['Blade: Teki'] = 'Elemental', ['Blade: To'] = 'Elemental', ['Blade: Chi'] = 'Elemental', ['Blade: Ei'] = 'Elemental',
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = {
            CancelInvisible = true,
            CancelDelay = { ['Utsusemi: Ichi'] = 2.4, ['Monomi: Ichi'] = 1.4, ['Tonko: Ichi'] = 1.4 },
        },
        MacroBook = 4, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
