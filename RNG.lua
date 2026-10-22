local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
RNG - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Ranged: Preshot (commented out, see the set) | Midshot -> Midshot_Acc (/meleeset Acc) -> Barrage (Midshot_Acc first) -> TH.
Engaged at night (18:00-06:00): Tp_Night on top of your TP set.
WS: Ws_Default -> Ws_<Mode> -> Ws_SlugShot / Ws_Detonator / Ws_Trueflight (+ Korin Obi when day/weather help)... Ranged WS skip the distance check.
Commands: /meleeset (Default/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Merman\'s ring',
        Feet = 'Trotter Boots',
    },
    Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
    Town = {
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Merman\'s ring',
        Feet = 'Trotter boots',
    },

    Dt = {
        Ring1 = 'Defending Ring',
    },

    Tp_Default = {
        Head = 'Optical hat',
        Neck = 'Ranger\'s necklace',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Kirin\'s Osode',
        Hands = 'Blood Fng. Gnt.',
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Merman\'s ring',
        Waist = 'Scout\'s belt',
        Legs = 'Galliard trousers',
        Feet = 'Scout\'s Socks',
    },
    Tp_Night = {
        Ear2 = 'Fenrir\'s Earring',
    },
    Tp_Acc = {
    },

    Precast = {
        Waist = 'Swift Belt',
        Legs = 'Byakko\'s haidate',
    },


    Cure = {
    },

    Enhancing = {
    },

    Enfeebling = {
    },
    Dark = {    
    },

    Drain = {
    },

    Nuke = {
    },

    -- Preshot is worn when /ra starts, so only Snapshot (shorter delay) and Rapid Shot (RNG trait, instant shot chance) matter here.
    -- Most players skip a preshot set: the gains are small and few pieces exist at 75.
    -- Uncomment to use it.
    -- Preshot_Priority = {
    --     Head = {'Htr. Beret +1', 'Hunter\'s Beret'},  -- Rapid Shot +5
    --     Body = {'Sct. Jerkin +1', 'Scout\'s Jerkin'}, -- Rapid Shot +5
    -- },
    Midshot = {
    },
    Barrage_Priority = {
        Hands = {'Htr. Bracers +1', 'Hunter\'s Bracers'},
        Feet = 'Hunter\'s Socks',
    },
    Midshot_Acc = {--will be over written by barrage set still 
    },

    Ws_Default = {
        Head = 'Wyvern helm',
        Neck = 'Spike necklace',
        Hands = 'Blood Fng. Gnt.',
        Ring1 = 'Courage Ring',
        Ring2 = 'Courage Ring',
        Feet = 'Hunter\'s Socks',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
    Ws_SlugShot_Priority = {
        Head = 'Optical hat',
        Neck = 'Light Gorget',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Kirin\'s Osode',
        Hands = 'Blood Fng. Gnt.',
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Merman\'s ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Scout\'s belt',
        Legs = 'Galliard trousers',
        Feet = 'Hunter\'s socks',
    },
    Ws_SlugShot_Acc = {
    },
    Ws_Detonator_Priority = {
        Head = 'Wyvern helm',
        Neck = 'Light Gorget',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Kirin\'s Osode',
        Hands = 'Blood Fng. Gnt.',
        Ring1 = 'Rajas ring',
        Ring2 = 'Flame ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Scout\'s belt',
        Legs = 'Galliard trousers',
        Feet = 'Scout\'s socks',
    },
    Ws_Trueflight = {
    },
    Ws_Trueflight_Hybrid = {
    },
    Ws_Trueflight_Acc = {
    },

    Scavenge = {
        Feet = 'Hunter\'s socks',
    },
    Sharpshot = {
        Legs = 'Hunter\'s braccae',
    },
    Movement = {
        Legs = 'Crimson cuisses',
        --Feet = 'Trotter boots',
	},
};
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'e', '/equip ammo "Acid Bolt"; /ra <t>'},
    {'+e', '/equip ammo "Silver Bullet"; /ra <t>'},
    {'q', '/ra <t>'},
    {'+q', '/ws "Slug Shot" <t>'},
    {'^q', '/ws "Detonator" <t>'},
    {'!q', '/ws "Trueflight" <t>'},
    {'b', '/ja "Shadowbind" <t>'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Sundrix inv'},
    {'!y', '/tell Butsuon inv'},
    {'1', '/ja "Sharpshot" <me>'},
    {'2', '/ja "Barrage" <me>'},
    {'3', '/ja "Camouflage" <me>'},
    {'4', '/ja "Berserk" <me>'},
    {'5', '/ja "Scavenge" <me>'},
};

profile.OnDefault = function(player)
    local time = gData.GetEnvironment().Time;
    if player.Status == 'Engaged' and (time < 6.00 or time >= 18.00) then gcinclude.EquipIfExists('Tp_Night') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Acc'},
        MacroBook = 10, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
