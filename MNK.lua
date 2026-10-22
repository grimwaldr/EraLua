local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
MNK - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Abilities use a set named after them (Boost, Focus, Dodge, Chakra, Counterstance, Footwork, ChiBlast...).
WS sets: Ws_Default -> Ws_<Mode> -> Ws_<WsName> (Ws_AsuranFists, Ws_DragonKick, Ws_HowlingFist...).
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
    Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {},
    Town = {
    },

    Dt = {
        Ring1 = 'Defending Ring',
    },

    Tp_Default = {
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },


    Precast = {
    },

    Preshot = {
    },
    Midshot = {
    },

    Ws_Default = {
        Neck = 'Fotia Gorget',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },




    Movement = {
        Feet = 'Herald\'s Gaiters',
	},
};
sets.Ws_AsuranFists = sets.Ws_AsuranFists or {};
sets.Ws_DragonKick = sets.Ws_DragonKick or {};
sets.Chakra = sets.Chakra or {};
sets.Boost = sets.Boost or {};
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Asuran Fists" <t>'},
    {'+q', '/ws "Dragon Kick" <t>'},
    {'^q', '/ws "Howling Fist" <t>'},
    {'1', '/ja "Focus" <me>'},
    {'2', '/ja "Dodge" <me>'},
    {'3', '/ja "Counterstance" <me>'},
    {'4', '/ja "Chakra" <me>'},
    {'5', '/ja "Boost" <me>'},
    {'e', '/ja "Chi Blast" <t>'},
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 4, MacroSet = 10,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
