local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
DNC - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Waltzes use Waltz (+ CuringWaltz, CuringWaltzIII... on top). Steps, Sambas, Jigs and Flourishes use Step, Samba, Jig, Flourish.
Provoke and Animated Flourish also use Enmity. Spectral Jig cancels Sneak first so it doesn't fail.
Aeolian Edge is out of era and was removed.
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
        Ear1 = 'Loquac. Earring',
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


    Waltz = {
    },

    TH = {--/th will force this set to equip for 10 seconds
	},
    Movement = {
	},
};
sets.Step = sets.Step or {};
sets.Samba = sets.Samba or {};
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Evisceration" <t>'},
    {'+q', '/ws "Dancing Edge" <t>'},
    {'t', '/ja "Curing Waltz III" <stpc>'},
    {'+t', '/ja "Curing Waltz II" <stpc>'},
    {'^t', '/ja "Healing Waltz" <stpc>'},
    {'1', '/ja "Haste Samba" <me>'},
    {'2', '/ja "Drain Samba II" <me>'},
    {'3', '/ja "Quickstep" <t>'},
    {'4', '/ja "Box Step" <t>'},
    {'5', '/ja "Violent Flourish" <t>'},
    {'e', '/ja "Animated Flourish" <t>'},
    {'b', '/ja "Spectral Jig" <me>'},
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 3, MacroSet = 7,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
