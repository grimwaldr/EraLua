local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
NIN/DRK - Phoenix XI (75 cap). Load with /lac load NINDRK (LuAshitacast only auto-loads NIN.lua).
Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Enmity-focused: every ability equips Enmity; Ninjutsu, Dark and Enfeebling magic use Enmity (Utsusemi: Utsusemi on top),
other spells use Ninjutsu. Movement_Night replaces Movement at night (18:00-06:00).
WS: Ws_BladeJin, Ws_BladeMetsu, Ws_BladeKu.
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = { --pdt/mdt set with some hp
        Main = 'Earth Staff',
		Range = 'Ungur Boomerang',
        Head = 'Arhat\'s jinpachi',
        Neck = 'Fortitude Torque',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Body = {'Arhat\'s gi +1', 'Arhat\'s Gi'},
        Hands = 'Seiryu\'s Kote',
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Jelly ring',
        Back = 'Gigant mantle',
        Waist = 'Warwolf Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = 'Suzaku\'s Sune-Ate',
    },
    Resting = {
	},
    Idle_Regen = {
        Neck = 'Orochi nodowa',
        Body = 'War shinobi gi',
    },
    Idle_Refresh = {},
    Town = {
        Body = 'Republic Aketon',
        Back = 'Gigant Mantle',
        Feet = 'Ninja Kyahan',
    },
    Dt = {
    },
    Tp_Default = {
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },
    Precast = {
    },
    Utsusemi_Priority = {
        Main = 'Earth Staff',
		Range = 'Ungur Boomerang',
        Head = 'Panther mask',
        Neck = 'Fortitude Torque',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Body = {'Arhat\'s gi +1', 'Arhat\'s Gi'},
        Hands = 'Dusk gloves',
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Jelly ring',
        Back = 'Boxer\'s mantle',
        Waist = 'Swift belt',
        Legs = 'Byakko\'s Haidate',
        Feet = 'Fuma Sune-Ate',
    },
    Nuke = {
    },
    Ninjutsu = {
        Head = 'Ninja Hatsuburi',
        Neck = 'Ninjutsu torque',
        Ear1 = 'Stealth Earring',
        Ear2 = 'Ninjutsu Earring',
        Ring2 = 'Omega Ring',
        Back = 'Astute Cape',
        Feet = 'Koga Kyahan',
    },
    Preshot = {
    },
    Midshot = {
    },
    Ws_Default = {
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
    Ws_BladeJin = {
    },
    Ws_BladeJin_Hybrid = {
	},
    Ws_BladeJin_Acc = {
	},
    Ws_BladeMetsu = {
    },
    Ws_BladeMetsu_Hybrid = {
	},
    Ws_BladeMetsu_Acc = {
	},
    Ws_BladeKu = {
    },
    Ws_BladeKu_Hybrid = {},
    Ws_BladeKu_Acc = {},
    Enmity_Priority = {
        Ammo = 'Nokizaru Shuriken',
        Head = 'Arhat\'s jinpachi',
        Neck = 'Harmonia\'s torque',
        Ear1 = 'Eris\' Earring',
        Ear2 = 'Eris\' Earring',
        Body = {'Arhat\'s gi +1', 'Arhat\'s Gi'},
        Hands = 'Yasha tekko',
        Back = 'Resentment Cape',
        Waist = 'Warwolf Belt',
		Legs = 'Byakko\'s Haidate',
        Feet = 'Yasha Sune-Ate',
    },
    Movement = {
        Feet = 'Ninja Kyahan',
	},
    Movement_Night = {
        Feet = 'Ninja Kyahan',
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Toolbag (Ino)', Quantity = 'all'},
    {Name = 'Toolbag (Shika)', Quantity = 'all'},
    {Name = 'Toolbag (Cho)', Quantity = 'all'},
    {Name = 'Toolbag (Shihe)', Quantity = 'all'},
    {Name = 'Shihei', Quantity = 'all'},
    {Name = 'Inoshishinofuda', Quantity = 'all'},
    {Name = 'Chonofuda', Quantity = 'all'},
    {Name = 'Shikanofuda', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'^=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Blade: Jin" <t>'},
    {'+q', '/ws "Blade: Ku" <t>'},
    {'^q', '/ws "Blade: Metsu" <t>'},
    {'e', '/ja "Provoke" <t>'},
    {'+e', '/ma "Stun" <t>'},
    {'1', '/ja "Souleater" <me>'},
    {'2', '/ja "Last Resort" <me>'},
    {'3', '/ja "Weapon Bash" <t>'},
    {'u', '/ma "Kurayami: Ni" <t>'},
    {'+u', '/ma "Hojo: Ni" <t>'},
    {'^u', '/ma "Jubaku: Ichi" <t>'},
};

profile.AbilityBase = 'Enmity';

local EnmitySkills = T{'Ninjutsu', 'Dark Magic', 'Enfeebling Magic'};

profile.OnMidcast = function(spell)
    if EnmitySkills:contains(spell.Skill) then
        gcinclude.EquipIfExists('Enmity');
        if string.find(spell.Name, 'Utsusemi') then gcinclude.EquipIfExists('Utsusemi') end
    end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = { CancelDelay = { ['Utsusemi: Ichi'] = 2.4 } },
        MacroBook = 8, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
