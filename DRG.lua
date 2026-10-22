local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
DRG - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Jump, High Jump, Super Jump all use the Jump set (+ Jump_<Mode>); a set named SuperJump etc. goes on top.
Wyvern breaths (Healing Breath etc.) equip the Breath set while the wyvern uses them.
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
    Idle_Refresh = {
    },
    Town = {
    },

    Dt = {
        Ring1 = 'Defending Ring',
    },

    Tp_Default_Priority = {
        Ammo = 'Tiphia sting',
        Head = 'Walkure mask',
        Neck = 'Peacock amulet',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Body = 'Scorpion harness',
        Hands = 'Battle gloves',
        Ring1 = 'Woodsman Ring',
        Ring2 = 'Woodsman Ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Swift belt',
        Legs = 'Republic subligar',
        Feet = 'Leaping boots',
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },

    Precast = {
    },
	
    Sneak_Priority = { --fishing for that longer duration
		Feet = {'Dream boots +1', 'Dream Boots'},
    },
	Invisible_Priority = { --see note above
		Hands = {'Dream mittens +1', 'Dream Mittens'},
    },

    Cure = {
    },

    Enhancing = {
    },

    Enfeebling = {
    },
    Dark = {},

    Drain = {
    },

    Nuke = {
    },

    Preshot = {
    },
    Midshot = {
    },

    Ws_Default_Priority = {
        Ammo = 'Tiphia sting',
        Head = 'Walkure Mask',
        Neck = 'Peacock Charm',
        Ear1 = 'Spike Earring',
        Ear2 = 'Spike Earring',
        Body = 'Scorpion Harness',
        Hands = 'Battle gloves',
        Ring1 = 'Woodsman Ring',
        Ring2 = 'Woodsman Ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Life belt',
        Legs = 'Republic subligar',
        Feet = 'Leaping boots',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
    Ws_Skewer = {
        Ammo = 'Tiphia sting',
        Head = 'Walkure mask',
        Neck = 'Spike necklace',
        Ring1 = 'Flame ring',
        Waist = 'Warwolf belt',
    },

    Jump = {
    Neck = 'Spike Necklace',
    Ring1 = 'Rajas Ring',
    Feet = 'Drachen greaves',
    },
    TH = {--/th will force this set to equip for 10 seconds
	},
    Movement = {
        Legs = 'Crimson Cuisses',
	},
};
sets.Breath = sets.Breath or {}; -- HP+ / wyvern HP+ for Healing Breath
profile.Sets = sets;

profile.Packer = {
    {Name = 'Shihei', Quantity = 'all'},
};

-- White magic binds assume /WHM (Curaga, not Curaga II, at /WHM 37); Warp needs /BLM.
profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'e', '/ws "Penta Thrust" <t>'},
    {'+e', '/ws "Skewer" <t>'},
    {'^e', '/ws "Wheeling Thrust" <t>'},
    {'q', '/ja "Jump" <t>'},
    {'+q', '/ja "High Jump" <t>'},
    {'^q', '/ja "Super Jump" <t>'},
    {'t', '/ma "Curaga" <me>'},
    {'+t', '/ja "Divine Seal" <me>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Blink" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Sundrix inv'},
    {'!y', '/tell Butsuon inv'},
    {'1', '/ja "Call Wyvern" <me>'},
    {'2', '/ja "Berserk" <me>'},
    {'3', '/ja "Ancient Circle" <me>'},
    {'4', '/ja "Spirit Link" <me>'},
    {'j', '/ma "Teleport-Mea" <me>'},
    {'+j', '/ma "Warp" <me>'},
    {'v', '/ma "Paralyna" <stal>'},
    {'+v', '/ma "Silena" <stal>'},
    {'^v', '/ma "Poisona" <stal>'},
    {'!v', '/ma "Blindna" <stal>'},
};

profile.OnPetAction = function(action)
    if action.Name ~= nil and string.find(action.Name, 'Breath') then gcinclude.EquipIfExists('Breath') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 1, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
