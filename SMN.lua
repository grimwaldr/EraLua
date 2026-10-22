local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
SMN - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Avatar out: Idle_Pet, plus the staff of the avatar's element (cuts perpetuation cost). Avatar fighting alone: Pet_Only_Tp.
Blood pacts: BP while you use one (recast/delay gear); while the avatar performs it:
  SmnSkill (wards; + SmnAttributes for Wind's Blessing) / SmnMagical / SmnHybrid / SmnHealing / SmnEnfeebling / SmnPhysical.
Spells: SIR first. Elemental Siphon: Siphon. /siphon summons the day's spirit, siphons and resummons your avatar.
Commands: /siphon /dt /setcycle /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
    Idle_Pet = {--only need 14, rest 512|575|670 skill for favor then refresh
        Ring1 = 'Evoker\'s Ring', --1
    },
	Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
	Town = {
        Feet = 'Herald\'s Gaiters',
    },
	
	Dt = {
        Ring1 = 'Defending Ring',
	},
    Pet_Dt = {
	},
	
	Tp_Default = {
    },
	Tp_Hybrid = {
    },
	Tp_Acc = {
    },
    Pet_Only_Tp = {
        Ring1 = 'Evoker\'s Ring',
    },

    Precast = {
    },
    Cure_Precast = {
    },
    Enhancing_Precast = {
    },
    Stoneskin_Precast = {
    },

    Cure = {--I cap is 50, II cap is 30
    },
    Regen = {
    },
    Cursna = {
    },

    Enhancing = {
    },
    Stoneskin = {
    },
    Refresh = {
    },

    SIR = {--77
    },

    Drain = {
    },

	Ws_Default = {
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
	
    BP = {--I/II cap at 15, the rest need 680 skill total
        Ring1 = 'Evoker\'s Ring',
    },
    Siphon = {
        Ring1 = 'Evoker\'s Ring',
    },

	SmnPhysical = {
    },
	SmnMagical = {
    },
	SmnSkill = {
        Ring1 = 'Evoker\'s Ring',
    },
    SmnAttributes = {--mostly for Wind's Blessing'
        Ring1 = 'Evoker\'s Ring',
    },
    SmnHealing = {--avatar HP+
        Ring1 = 'Evoker\'s Ring',
    },
	SmnEnfeebling = {
        --Body = 'Con. Doublet +2',--after +2
        Ring1 = 'Evoker\'s Ring',
        --Feet = 'Con. Pigaches',--after +2
    },
    SmnHybrid = {--special set for flamming crush and burning strike (for now)
        --Body = 'Con. Doublet +2',-- after +2
    },
	
    TH = {--/th will force this set to equip for 10 seconds
	},
	Movement = {
        Feet = 'Herald\'s Gaiters',
	},
};
sets.SmnPhysical = sets.SmnPhysical or {};
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd siphon'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'1', '/ma "Carbuncle" <me>'},
    {'2', '/ma "Garuda" <me>'},
    {'3', '/ma "Ifrit" <me>'},
    {'4', '/ma "Titan" <me>'},
    {'5', '/ma "Leviathan" <me>'},
    {'6', '/ma "Shiva" <me>'},
    {'7', '/ma "Ramuh" <me>'},
    {'8', '/ma "Fenrir" <me>'},
    {'9', '/ma "Diabolos" <me>'},
    {'0', '/ja "Release" <me>'},
    {'q', '/ja "Assault" <t>'},
    {'+q', '/ja "Retreat" <me>'},
    {'t', '/ma "Cure IV" <stpc>'},
    {'b', '/ma "Stoneskin" <me>'},
};

local AvatarElement = {
    ['Carbuncle'] = 'Light', ['Ifrit'] = 'Fire', ['Shiva'] = 'Ice', ['Garuda'] = 'Wind', ['Titan'] = 'Earth',
    ['Ramuh'] = 'Thunder', ['Leviathan'] = 'Water', ['Fenrir'] = 'Dark', ['Diabolos'] = 'Dark',
    ['Fire Spirit'] = 'Fire', ['Ice Spirit'] = 'Ice', ['Air Spirit'] = 'Wind', ['Earth Spirit'] = 'Earth',
    ['Thunder Spirit'] = 'Thunder', ['Water Spirit'] = 'Water', ['Light Spirit'] = 'Light', ['Dark Spirit'] = 'Dark',
};

local SmnSkill = T{'Shining Ruby','Glittering Ruby','Crimson Howl','Frost Armor','Aerial Armor','Hastega','Earthen Ward','Rolling Thunder',
    'Lightning Armor','Soothing Current','Ecliptic Growl','Ecliptic Howl','Noctoshield','Dream Shroud','Reraise II','Wind\'s Blessing'};
local SmnMagical = T{'Searing Light','Meteorite','Holy Mist','Inferno','Fire II','Fire IV','Diamond Dust','Blizzard II','Blizzard IV','Aerial Blast',
    'Aero II','Aero IV','Earthen Fury','Stone II','Stone IV','Judgment Bolt','Thunder II','Thunder IV','Thunderspark','Tidal Wave','Water II','Water IV',
    'Howling Moon','Lunar Bay','Ruinous Omen','Somnolence','Nether Blast','Night Terror'};
local SmnHealing = T{'Healing Ruby','Healing Ruby II','Whispering Wind','Spring Water'};
local SmnHybrid = T{'Flaming Crush','Burning Strike'};
local SmnEnfeebling = T{'Diamond Storm','Sleepga','Shock Squall','Slowga','Tidal Roar','Ultimate Terror','Nightmare','Mewing Lullaby','Eerie Eye'};

profile.MidcastBase = 'SIR';

profile.OnPetAction = function(action)
    if SmnSkill:contains(action.Name) then
        gcinclude.EquipIfExists('SmnSkill');
        if action.Name == 'Wind\'s Blessing' then gcinclude.EquipIfExists('SmnAttributes') end
    elseif SmnMagical:contains(action.Name) then
        gcinclude.EquipIfExists('SmnMagical');
    elseif SmnHybrid:contains(action.Name) then
        gcinclude.EquipIfExists('SmnHybrid');
    elseif SmnHealing:contains(action.Name) then
        gcinclude.EquipIfExists('SmnHealing');
    elseif SmnEnfeebling:contains(action.Name) then
        gcinclude.EquipIfExists('SmnEnfeebling');
    else
        gcinclude.EquipIfExists('SmnPhysical');
    end
end

profile.OnDefault = function(player, pet)
    if pet ~= nil and player.Status ~= 'Engaged' then gcinclude.EquipStaff(AvatarElement[pet.Name]) end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Acc'},
        ElementalStaff = true,
        Settings = { RegenGearHPP = 50, RefreshGearMPP = 60, PetDTGearHPP = 30 },
        MacroBook = 6, MacroSet = 1,
    });
    gcinclude.AddCommand('siphon', function() gcinclude.DoSiphon() end);
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
