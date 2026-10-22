local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
DRK - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Dark magic: Dark -> Drain / Aspir / Absorb / DreadSpikes (by spell name) -> obi on matching day/weather.
Dread Spikes up: Spikes set over idle/TP. Blood Weapon / Souleater / Last Resort / Weapon Bash use sets named after them.
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
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

    Tp_Default = {
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },


    Precast = {
    },


    Cure = {
    },

    Enhancing = {
    },
    DreadSpikes = { -- HP+++++ at cast for max potency
    },

    Enfeebling = {
    },
    Dark = {
    },

    Drain = {
    },

    Nuke = {
    },

    Preshot = {
    },
    Midshot = {
    },

    Ws_Default = { -- WSD for all scythe basically
        Neck = 'Fotia Gorget',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },


    Spikes = { -- set to leave body on with dread spikes up, only body here!
    },
    BloodWeapon = {
    },
    Movement = {
	},
};
sets.Aspir = sets.Aspir or sets.Drain;
sets.Aspir_Priority = sets.Aspir_Priority or sets.Drain_Priority;
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Guillotine" <t>'},
    {'+q', '/ws "Spiral Hell" <t>'},
    {'^q', '/ws "Cross Reaper" <t>'},
    {'e', '/ma "Stun" <t>'},
    {'+e', '/ja "Provoke" <t>'},
    {'t', '/ma "Drain" <t>'},
    {'+t', '/ma "Aspir" <t>'},
    {'1', '/ja "Last Resort" <me>'},
    {'2', '/ja "Souleater" <me>'},
    {'3', '/ja "Weapon Bash" <t>'},
    {'4', '/ja "Berserk" <me>'},
    -- /SAM (Hasso 25, Third Eye 15, Meditate 30, Seigan 35): only bound while your subjob is SAM
    {'6', '/ja "Hasso" <me>', function(p) return p.SubJob == 'SAM' end},
    {'7', '/ja "Meditate" <me>', function(p) return p.SubJob == 'SAM' end},
    {'8', '/ja "Third Eye" <me>', function(p) return p.SubJob == 'SAM' end},
    {'9', '/ja "Seigan" <me>', function(p) return p.SubJob == 'SAM' end},
    {'b', '/ma "Dread Spikes" <me>'},
};

profile.OnDefault = function()
    if gData.GetBuffCount('Dread Spikes') > 0 then gcinclude.EquipIfExists('Spikes') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 7, MacroSet = 10,
    });
    gcinclude.AddCommand('gcdrain', function() gcinclude.DoDrain() end);
    gcinclude.AddCommand('gcaspir', function() gcinclude.DoAspir() end);
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
