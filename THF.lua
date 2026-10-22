local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
THF - Phoenix XI (75 cap). Runs on the shared common folder.
Set order and naming: "Generic job handlers" in common/gcinclude.lua.

/meleeset: Default | Acc | dDEX | Farm | Dynamis
  Engaged: Tp_Default -> Tp_<Mode> -> TH (/th). Dynamis mode: Dynamis set while not engaged, TH on spells and shots.
SA / TA / SATA up: SA | TA | SATA over idle/TP (Rog. Armlets +1 for the AGI boost, etc.).
WS: Ws_Default -> Ws_<Mode> -> SA | TA | SATA -> Ws_<WsName>_SA|_TA|_SATA if it exists, otherwise Ws_<WsName>.
  e.g. Evisceration with SA up: Ws_Default, SA, Ws_Evisceration_SA (gorget only, so your SA set stays on).
/eva puts the Eva set on top. Ranged: Midshot (status bolts: accuracy first) -> Bloody_Bolt for Bloody Bolts -> TH.
Abilities use a set named after them: Steal, Flee, Hide, Mug, Charm.
Commands: /th /eva /meleeset /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    -- Partially utility, partially flexing
    Idle = {
        Head = 'Optical hat',
        Neck = 'Love Torque',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = 'Homam Corazza',
        Hands = 'Assassin\'s Armlets',
        Ring1 = 'Rajas ring',
        Ring2 = 'Toreador\'s ring',
        Back = 'Boxer\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Homam Cosciales',
        Feet = 'Trotter boots',
    },

    Dynamis = {
        Head = 'Homam Zucchetto',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = 'Blue Cotehardie',
        Hands = 'Assassin\'s Armlets',
        Ring1 = 'Jelly ring',
        Ring2 = 'Merman\'s ring',
        Back = 'Boxer\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Coral subligar',
        Feet = 'Trotter boots',
    },

    Town_Priority = {
        Head = {'Panther mask +1', 'Panther mask'},
        Ear1 = {'Beetle earring +1', 'Beetle Earring'}, -- Sansah signed
    },
    -- Will probably use this for MDT set in the future
    Dt = {},

    Tp_Default = {
        Head = 'Homam Zucchetto',
        Neck = 'Love Torque',
        Ear1 = 'Stealth earring',
        Ear2 = 'Brutal earring',
        Body = 'Rapparee harness',
        Hands = 'Dusk gloves',
        Ring1 = 'Rajas ring',
        Ring2 = 'Toreador\'s ring',
        Back = 'Forager\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Homam Cosciales',
        Feet = 'Homam Gambieras',
    },
    Tp_Acc = {
	    Head = 'Optical hat',
        Neck = 'Love Torque',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = 'Homam corazza',
        Hands = 'Homam manopolas',
        Ring1 = 'Rajas ring',
        Ring2 = 'Toreador\'s ring',
        Back = 'Forager\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Homam cosciales',
        Feet = 'Homam Gambieras',
    },
    -- Lots of DEX
    Tp_dDEX_Priority = {
        Head = 'Emperor hairpin',
        Neck = 'Love Torque',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = {'Dragon harness +1', 'Dragon Harness'},
        Hands = 'Dusk gloves',
        Ring1 = 'Rajas ring',
        Ring2 = 'Thunder ring',
        Back = 'Forager\'s mantle',
        Waist = 'Warwolf belt',
        Legs = {'Drn. Subligar +1', 'Dragon Subligar'},
        Feet = 'Bounding boots',
    },
    -- Stacking haste, dual wield, DEX
    Tp_Farm = {
        Head = 'Homam Zucchetto',
        Neck = 'Love Torque',
        Ear1 = 'Stealth Earring',
        Ear2 = 'Brutal earring',
        Body = 'Rapparee harness',
        Hands = 'Dusk gloves',
        Ring1 = 'Rajas ring',
        Ring2 = 'Thunder ring',
        Back = 'Forager\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Homam Cosciales',
        Feet = 'Homam Gambieras',
    },
    -- Toggle with /eva
	Eva = {
        Head = 'Optical Hat',
        Neck = 'Evasion Torque',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = 'Scorpion Harness',
        Back = 'Boxer\'s mantle',
        Waist = 'Scouter\'s rope',
	},

    -- I'm sort of baking in an assumption that all the WS I use are going to be DEX based
    Ws_Default_Priority = {
        Head = 'Assassin\'s bonnet',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
        Body = {'Dragon harness +1', 'Dragon Harness'},
        Hands = 'Hecatomb Mittens',
        Ring1 = 'Rajas ring',
        Ring2 = 'Thunder ring',
        Back = 'Forager\'s mantle',
        Waist = 'Warwolf belt',
        Legs = 'Dusk trousers',
        Feet = 'Hct. Leggings',
    },

    -- These are the base WS sets when SA/TA/SATA are active. WS sets do override these, however.
    -- Highest combined DEX/AGI, Rog. Armlets +1 for 15% boost to AGI contribution
    SATA_Priority = {
        Head = 'Emperor hairpin', -- Need Maat's cap
        Neck = 'Love Torque', -- BIS
        Ear1 = 'Suppanomimi', -- BIS
        Ear2 = 'Genin Earring', -- BIS?
        Body = {'Dragon harness +1', 'Dragon Harness'}, -- BIS
        Hands = {'Rog. Armlets +1', 'Rogue\'s Armlets'}, -- BIS for Non-WS pending testing on ASB's shit code
        Ring1 = 'Rajas ring', -- BIS
        Ring2 = 'Thunder ring', -- BIS
        Back = 'Assassin\'s cape', -- BIS I think?
        Waist = 'Warwolf belt', -- BIS
        Legs = {'Drn. Subligar +1', 'Dragon Subligar'}, -- Need Hecatomb +1 > AF+1
        Feet = 'Bounding boots', -- Need Dragon Leggings +1
    },
    -- Lots of DEX
    SA_Priority = {
        Head = {'Asn. Bonnet +1', 'Assassin\'s Bonnet'}, -- Need Maat's cap
        Neck = 'Love Torque', -- BIS
        Ear1 = 'Suppanomimi', -- BIS
        Ear2 = 'Brutal earring', -- Maybe BIS? Pixie?
        Body = {'Dragon harness +1', 'Dragon Harness'}, --BIS
        Hands = 'Hecatomb Mittens', -- Need +1
        Ring1 = 'Rajas ring', -- BIS
        Ring2 = 'Thunder ring', -- BIS
        Back = 'Forager\'s mantle', -- BIS (I think)
        Waist = 'Warwolf belt', -- BIS
        Legs = {'Drn. Subligar +1', 'Dragon Subligar'}, -- Need Hecatomb +1
        Feet = 'Hct. Leggings', -- Need +1
    },
    -- Lots of AGI, Rog. Armlets +1 for 15% boost to AGI contribution
    TA_Priority = {
        Head = 'Dragon cap', -- Need Maat's cap > Dragon cap +1
		Neck = 'Hope Torque', -- BIS
        Ear1 = 'Drone Earring', -- BIS?
        Ear2 = 'Genin Earring', -- BIS?
        Body = {'Dragon harness +1', 'Dragon Harness'}, -- BIS
        Hands = {'Rog. Armlets +1', 'Rogue\'s Armlets'}, -- BIS for rawdogging but may not work on WS on ASB
        Ring1 = 'Emerald ring', -- Need another Breeze ring but who cares
        Ring2 = 'Breeze ring', -- BIS
        Back = 'Forager\'s mantle', -- Assassin's cape? Forager's may be better...
        Waist = 'Scouter\'s rope', -- BIS
        Legs = {'War Brais +1', 'War Brais'}, -- Honestly Heca+1 probably just better here...
        Feet = 'Bounding boots', -- Need Dragon leggings +1
    },

    -- DEX, AGI WSC | Equipped AFTER WS_Default and SA/TA/SATA gear
	Ws_SharkBite = {
		Neck = 'Breeze Gorget',
	},
    Ws_SharkBite_SA = {
        Neck = 'Breeze Gorget',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal earring',
    },
    Ws_SharkBite_TA = {
        Neck = 'Breeze Gorget',
    },
    Ws_SharkBite_SATA = {
        Neck = 'Breeze Gorget',
        Ear1 = 'Suppanomimi',
    },

    Ws_EnergyDrain = {},

    -- DEX/CHR WSC, Crit WS | Equipped AFTER WS_Default and SA/TA/SATA gear
    Ws_Evisceration_Priority = {
        Head = {'Asn. Bonnet +1', 'Assassin\'s Bonnet'},
		Neck = 'Soil gorget',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Brutal Earring',
        Body = {'Dragon harness +1', 'Dragon Harness'},
        Hands = 'Hecatomb Mittens',
        Ring1 = 'Rajas ring',
        Ring2 = 'Thunder Ring',
        Back = 'Forager\'s Mantle',
        Waist = 'Warwolf belt',
        Legs = {'Drn. Subligar +1', 'Dragon Subligar'},
        Feet = 'Hct. leggings',
    },
    -- These SATA sets are prio over Evis_Default, so they're basically just overrides for SATA sets
    Ws_Evisceration_SA = {Neck = 'Soil gorget',},
    Ws_Evisceration_TA = {Neck = 'Soil gorget',},
    -- Worth prioritizing DEX over AGI for dDEX imo
    Ws_Evisceration_SATA = {
        Neck = 'Soil gorget',
    },
    -- Dancing Edge, DEX/CHR WSC, Acc varies
	Ws_DancingEdge = {Neck = 'Soil gorget',},

    -- True Strike
    Ws_TrueStrike = {
        Neck = 'Breeze Gorget',
    },

    -- Fast cast goes in precast
    Precast = {
        Ear1 = 'Loquac. Earring',
        Legs = 'Homam cosciales',
    },
    -- Haste > SIRD > PDT/Eva/Parry
    Haste = {
        Head = 'Homam zucchetto',
        Neck = 'Willpower torque',
        Ear1 = 'Suppanomimi',
        Ear2 = 'Magnetic earring',
        Body = 'Rapparee harness',
        Hands = 'Dusk gloves',
        Ring1 = 'Jelly Ring',
        Back = 'Boxer\'s mantle',
        Waist = 'Swift Belt',
        Legs = 'Homam cosciales',
        Feet = 'Homam Gambieras',
    },

    Preshot = {
    },
    -- Ranged Acc > Ranged Attack, because we're trying to hit status bolts here
    Midshot_Priority = {
		Head = 'Optical hat',
		Neck = 'Peacock Amulet',
		Ear1 = 'Drone Earring',
		Ear2 = 'Genin Earring',
		Body = {'Dragon Harness +1', 'Dragon Harness'},
		Ring1 = 'Merman\'s ring',
		Ring2 = 'Merman\'s ring',
        Back = 'Jaeger mantle',
		Waist = 'Scouter\'s rope',
		Legs = 'Dusk trousers',
		Feet = 'Homam Gambieras',
    },
    -- dINT increases bloody bolt HP yield
    Bloody_Bolt = {
        Head = 'Rogue\'s bonnet',
        Ring1 = 'Snow ring',
        Ring2 = 'Snow ring',
        Back = 'Fed. Army Mantle',
    },

    TH = {
        Hands = 'Assassin\'s Armlets',
    },

    -- JAs
    Flee = {Feet = 'Rogue\'s Poulaines',},
    Hide = {Body = 'Rogue\'s Vest',},
    Steal = {
		Head = 'Rogue\'s Bonnet',
		Hands = 'Thief\'s Kote',
		Legs = 'Assassin\'s Culottes',
		Feet = 'Rogue\'s Poulaines',
	},
    Mug = {Head = 'Asn. Bonnet +1'},
    Charm_Priority = {
        Head = {'Panther mask +1', 'Panther mask'},
        Neck = 'Bird whistle',
        Body = 'Savage separates',
        Ring1 = 'Loyalty ring',
        Ring2 = 'Loyalty ring',
        Waist = {'Corsette +1', 'Corsette'},
        Feet = 'Savage gaiters',
    },

    Movement = {Feet = "Trotter boots",},
};
profile.Sets = sets;

profile.Packer = {
    'Odious Blood',
    'Odious Pen',
    'Odious Skull',
    'Odious Horn',
    {Name = 'Forgotten Hope', Quantity = 'all'},
    {Name = 'Frgtn. Thought', Quantity = 'all'},
    'Shrouded Bijou',
    {Name = 'T. Whiteshell', Quantity = 'all'},
    {Name = 'O. Bronzepiece', Quantity = 'all'},
    {Name = '1 Byne Bill', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd th'},
    {'^=', '/lac fwd eva'},
    {'!=', '/lac fwd dt'},
    {'space', '/jump'},
    {'`', '/fillmode'},
    {'e', '/ra <t>'},  -- x / shift+x are sneak / invis on every job
    {'y', '/pcmd leave'},
    {'q', '/ws "Evisceration" <t>'},
    {'+q', '/ws "Dancing Edge" <t>'},
    {'^q', '/ws "Shark Bite" <t>'},
    {'1', '/ja "Sneak Attack" <me>'},
    {'2', '/ja "Trick Attack" <me>'},
    {'3', '/ja "Steal" <t>'},
    {'4', '/ja "Mug" <t>'},
    {'5', '/ja "Flee" <me>'},
    {'6', '/ja "Hide" <me>'},
};

local function SATA()
    local sa = gData.GetBuffCount('Sneak Attack') > 0;
    local ta = gData.GetBuffCount('Trick Attack') > 0;
    if sa and ta then return 'SATA' elseif sa then return 'SA' elseif ta then return 'TA' end
    return nil;
end

profile.OnDefault = function(player)
    if gcdisplay.GetCycle('MeleeSet') == 'Dynamis' and player.Status ~= 'Engaged' then gcinclude.EquipIfExists('Dynamis') end
    if gcdisplay.GetToggle('Eva') then gcinclude.EquipIfExists('Eva') end
    local s = SATA();
    if s then gcinclude.EquipIfExists(s) end
end

-- SA/TA/SATA sets are the WS base while those buffs are up; the WS's own SA/TA/SATA set (if any) replaces its default set.
profile.OnWsBase = function()
    local s = SATA();
    if s then gcinclude.EquipIfExists(s) end
end
profile.WsVariant = function() return SATA() end

profile.OnMidcast = function()
    if gcdisplay.GetCycle('MeleeSet') == 'Dynamis' then gcinclude.EquipIfExists('TH') end
end

profile.OnMidshot = function()
    if gcdisplay.GetCycle('MeleeSet') == 'Dynamis' then gcinclude.EquipIfExists('TH') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Acc', 'dDEX', 'Farm', 'Dynamis'},
        MacroBook = 2, MacroSet = 1,
    });
    if not gcdisplay.HasToggle('TH') then gcinclude.AddToggle('TH', false, 'th', 'Treasure Hunter') end
    gcinclude.AddToggle('Eva', false, 'eva', 'Evasion Set');
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
