local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
WAR - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Abilities use a set named after them (Berserk, Warcry, Aggressor, Defender, Tomahawk).
WS sets: Ws_Default -> Ws_<Mode> -> Ws_<WsName> -> Ws_<WsName>_<Mode>.
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
    Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
    Town = {
        Feet = 'Hermes\' Sandals',
    },

    Dt = {
        Ring1 = 'Defending Ring',
    },

    Tp_Default = {
        Ammo = 'Bomb core',
        Neck = 'Peacock amulet',
        Ear1 = 'Brutal Earring',
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },
    Precast = {
    },

    -- Placeholder sets referenced by HandleMidcast / HandlePreshot / HandleMidshot.
    -- Left empty so those handlers don't pass nil to EquipSet. Fill in if you ever need them.
    Enhancing = {},
    Cure = {},
    Nuke = {},
    Enfeebling = {},
    Dark = {},
    Drain = {},
    Preshot = {},
    Midshot = {},

    Ws_Default = {
        Neck = 'Spike necklace',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
    Ws_Rampage = {
        Ammo = 'Bomb core',
        Head = 'Emperor Hairpin',
        Neck = 'Peacock amulet',
    },
    Ws_Rampage_Hybrid = {
    },
    Ws_Rampage_Acc = {
        Ammo = 'Bomb core',
        Head = 'Emperor Hairpin',
        Neck = 'Peacock amulet',
    },
    Ws_SteelCyclone = {
        Ammo = 'Bomb core',
        Head = 'Emperor Hairpin',
        Neck = 'Peacock amulet',
    },
    Ws_SteelCyclone_Hybrid = {
        Ammo = 'Bomb core',
        Head = 'Emperor Hairpin',
        Neck = 'Peacock amulet',
    },
    Ws_SteelCyclone_Acc = {
        Ammo = 'Bomb core',
        Head = 'Emperor Hairpin',
        Neck = 'Peacock amulet',
    },
    Ws_RagingRush = {
    },
    Ws_RagingRush_Hybrid = {
    },
    Ws_RagingRush_Acc = {
    },
    Ws_PentaThrust = {
        Neck = 'Fotia Gorget',
    },
    Ws_PentaThrust_Hybrid = {
    },
    Ws_PentaThrust_Acc = {
    },

    Tomahawk = {
        Ammo = 'Thr. Tomahawk',
    },
    Warcry = {
    },
    Aggressor = {
    },
    Defender = {
    },
    Berserk = {
    },

    TH = {--/th will force this set to equip for 10 seconds
    },
    Movement = {
        Feet = 'Hermes\' Sandals',
    },
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Thr. Tomahawk', Quantity = 'all'},
    {Name = 'Red Curry Bun', Quantity = 'all'},
};

-- Utsusemi (n/+n) and Monomi/Tonko or oils (x/+x) are added by gcinclude.
profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Butsuon inv'},
    {'!y', '/tell Cidant inv'},
    {'q', '/ws "Sturmwind" <t>'},
    {'+q', '/ws "Raging Rush" <t>'},
    {'^q', '/ws "Steel Cyclone" <t>'},
    {'!q', '/ws "Rampage" <t>'},
    {'e', '/ja "Provoke" <t>'},
    {'1', '/ja "Berserk" <me>'},
    {'2', '/ja "Warcry" <me>'},
    {'3', '/ja "Aggressor" <me>'},
    {'4', '/ja "Defender" <me>'},
    {'5', '/ja "Tomahawk" <t>'},
    -- /SAM (Hasso 25, Third Eye 15, Meditate 30, Seigan 35): only bound while your subjob is SAM
    {'6', '/ja "Hasso" <me>', function(p) return p.SubJob == 'SAM' end},
    {'7', '/ja "Meditate" <me>', function(p) return p.SubJob == 'SAM' end},
    {'8', '/ja "Third Eye" <me>', function(p) return p.SubJob == 'SAM' end},
    {'9', '/ja "Seigan" <me>', function(p) return p.SubJob == 'SAM' end},
    -- /NIN enfeebles
    {'u', '/ma "Kurayami: Ichi" <t>'},
    {'+u', '/ma "Hojo: Ichi" <t>'},
    {'^u', '/ma "Jubaku: Ichi" <t>'},
    {'!u', '/ma "Dokumori: Ichi" <t>'},
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = { RegenGearHPP = 65, RefreshGearMPP = 40 },
        MacroBook = 3, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
