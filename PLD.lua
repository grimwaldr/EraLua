local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
PLD - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Every ability equips Enmity first, then a set named after it (Sentinel, Rampart, Cover, Fealty, Bash, Chivalry, Invincible).
Engaged with /tankset on Main or MEVA: Tp_* then Tank_Main / Tank_MEVA. Cover buff up: Fealty set.
Spells: SIR first; Cure, Phalanx, Reprisal, Flash use their own sets, everything else Enmity. /sir forces SIR on top (not Reprisal).
Savage Blade and Knights of Round share Ws_SavageBlade; Atonement (Burtgang mythic) uses Ws_Atonement. Chant du Cygne and Aeolian Edge are out of era and were removed.
Commands: /tankset /sir /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
    },
    Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
        --Ammo = 'Homiliary',
    },
    Town = {
        Sub = 'Aegis',
    },

    Dt = {
    },

    Tp_Default = {
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },

    --These will overwrite any above TP profile.Sets if /tankset is used
    Tank_Main = {--Default Tanking,  dt 
        Ear2 = 'Ethereal Earring',
        },
    Tank_MEVA = {
    },

    Precast = {--44 w/o Loquac due to HP drop
        --Ear1 = 'Tuisto Earring',
    },
    Cure_Precast = {
        --Ear1 = 'Mendi. Earring',
    },
    Enhancing_Precast = {
    },
    SIR = {--10 merits,101 gear
    },
    Enmity = {
    },

    Cure = {
        --Ear1 = 'Tuisto Earring',
    },
    Phalanx = {
    },
    Reprisal = {
    },
    Flash = {
    },

    Preshot = {},
    Midshot = {
    },

    Ws_Default = {
        Neck = 'Fotia Gorget',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },
    Ws_SavageBlade = {
        Neck = 'Fotia Gorget',
    },
    Ws_SavageBlade_Hybrid = {
    },
    Ws_SavageBlade_Acc = {
    },
    Ws_Atonement = {
    },
    Ws_Atonement_Hybrid = {
    },
    Ws_Atonement_Acc = {
    },

    Fealty = {
    },
    Sentinel = {
    },
    Bash = {
    },
    Invincible = {
    },
    Cover = {
    },
    Rampart = {
    },
    
    TH = {--/th will force this set to equip for 10 seconds
	},
    Movement = {
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Om. Sandwich', Quantity = 'all'},
    {Name = 'Black Curry Bun', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd tankset'},
    {'^=', '/lac fwd sir'},
    {'!=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'e', '/ma "Flash" <t>'},
    {'+e', '/ja "Provoke" <t>'},
    {'q', '/ws "Savage Blade" <t>'},
    {'+q', '/ws "Spirits Within" <t>'},
    {'t', '/ma "Cure IV" <stpc>'},
    {'+t', '/ma "Cure III" <stpc>'},
    {'1', '/ja "Sentinel" <me>'},
    {'2', '/ja "Rampart" <me>'},
    {'3', '/ja "Shield Bash" <t>'},
    {'4', '/ja "Cover" <stpc>'},
    {'5', '/ja "Chivalry" <me>'},
    {'6', '/ja "Fealty" <me>'},
    {'b', '/ma "Phalanx" <me>'},
    {'+b', '/ma "Reprisal" <me>'},
};

profile.AbilityBase = 'Enmity';
profile.AbilitySets = { ['Shield Bash'] = 'Bash' };
profile.WsAlias = { ['Knights of Round'] = 'SavageBlade' };
profile.MidcastBase = 'SIR';

local OwnSets = T{'Cure', 'Curaga', 'Phalanx', 'Reprisal', 'Flash'};

profile.OnDefault = function(player)
    if player.Status == 'Engaged' and gcdisplay.GetCycle('TankSet') ~= 'None' then
        gcinclude.EquipIfExists('Tank_' .. gcdisplay.GetCycle('TankSet'));
    end
    if gData.GetBuffCount('Cover') > 0 then gcinclude.EquipIfExists('Fealty') end
end

profile.OnMidcast = function(spell)
    local family = gcinclude.Family(spell.Name);
    if not OwnSets:contains(family) then gcinclude.EquipIfExists('Enmity') end
    if gcdisplay.GetToggle('SIR') and family ~= 'Reprisal' then gcinclude.EquipIfExists('SIR') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 11, MacroSet = 10,
    });
    gcinclude.AddCycle('TankSet', {'Main', 'MEVA', 'None'}, 'tankset', 'Tank Set');
    gcinclude.AddToggle('SIR', false, 'sir', 'Spell Interruption Set');
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
