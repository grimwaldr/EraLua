local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
WHM - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Healing: Cure_Precast -> Cure -> Self_Cure (on yourself) -> Cursna etc. -> Light staff/obi.
Enhancing: Enhancing -> Self_Enhancing -> Stoneskin / Regen / Refresh / Phalanx -> Self_Refresh.
Nukes and enfeebles get the matching elemental staff unless /fight has your weapons locked; obi when day/weather help.
/nukeset switches Power/Macc (Nuke_Macc, Enfeebling_Macc, ... on top).
Commands: /fight /nukeset /meleeset /dt /setcycle /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = {
        Main = 'Pilgrim\'s Wand',
        Body = {'Seer\'s tunic +1', 'Seer\'s Tunic'},
        Hands = 'Elder\'s bracers',
        Legs = 'Baron\'s slops',
        Feet = 'Elder\'s sandals',
    },
    Resting = {
	Main = 'Pilgrim\'s Wand',
	Legs = 'Baron\'s slops',
	},
    Idle_Regen = {
    },
    Idle_Refresh = {
		Main = 'Pilgrim\'s Wand',
    },
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
    Cure_Precast = {
    },
    Enhancing_Precast = {
    },
    Stoneskin_Precast = {
    },


    Cure_Priority = {--I cap is 50, II cap is 30
        Main = {'Yew wand +1', 'Yew Wand'},
        Hands = 'Zealot\'s mitts', --I 9
    },
    Self_Cure = {--cap 30
    },
    Regen = {
    },
    Cursna = {
    },

    Enhancing = {
    },
    Self_Enhancing_Priority = {
		Hands = {'Dream mittens +1', 'Dream Mittens'},
		Feet = {'Dream boots +1', 'Dream Boots'},
	},
    Stoneskin = {
    },
    Phalanx = {},
    Refresh = {
    },
    Self_Refresh = {},

    Enfeebling_Priority = {
        Main = {'Yew wand +1', 'Yew Wand'},
		Body = 'Baron\'s saio',
    },

    Drain = {
    },

    Nuke = {
    },
    Nuke_Macc = {
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

    TH = {--/th will force this set to equip for 10 seconds
	},
    Movement = {
        Feet = 'Herald\'s Gaiters',
	},
};
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd fight'},
    {'+=', '/lac fwd nukeset'},
    {'^=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'t', '/ma "Cure IV" <stpc>'},
    {'+t', '/ma "Cure V" <stpc>'},
    {'^t', '/ma "Curaga III" <stpc>'},
    {'!t', '/ma "Curaga II" <stpc>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Blink" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'1', '/ma "Haste" <stpc>'},
    {'2', '/ma "Protectra V" <me>'},
    {'3', '/ma "Shellra V" <me>'},
    {'4', '/ma "Regen III" <stpc>'},
    {'5', '/ja "Divine Seal" <me>'},
    {'e', '/ma "Slow" <t>'},
    {'+e', '/ma "Paralyze" <t>'},
    {'^e', '/ma "Silence" <t>'},
    {'j', '/ma "Teleport-Mea" <me>'},
    {'v', '/ma "Paralyna" <stpc>'},
    {'+v', '/ma "Silena" <stpc>'},
    {'^v', '/ma "Poisona" <stpc>'},
    {'!v', '/ma "Blindna" <stpc>'},
    {'#v', '/ma "Cursna" <stpc>'},
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Acc'},
        MagicModes = {'Power', 'Macc'},
        WeaponLock = {'Main', 'Sub'},
        ElementalStaff = true,
        MacroBook = 8, MacroSet = 9,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
