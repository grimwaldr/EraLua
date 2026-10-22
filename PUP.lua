local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
PUP - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Automaton out: Idle_Pet. Automaton fighting: Pet_Only_Tp (you idle) or Tp_* (you engaged), then the /pupmode set
(Tank / Melee / Ranger / Mage). Automaton at 950+ TP and fighting: Pet_WS (Melee) or Pet_RNGWS (Ranger). Overdrive up: Overdrive.
Repair and Maintenance share Repair; maneuvers use Maneuver. /dt also adds Pet_Dt.
Commands: /pupmode /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
    Idle_Pet = {
    },
	Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
	Town = {
        Feet = 'Hermes\' Sandals',
    },
	
	Dt = {
        Ring1 = 'Defending Ring',
	},
    Pet_Dt = {
        Head = 'Anwig Salade', --10pt
        --Ear2 = 'Kara. Earring +1',
        Ring1 = 'Defending Ring',
	},
	
    Pet_Only_Tp = {
    },
    Pet_Only_Tp_Hybrid = {
    },
    Pet_Only_Tp_Acc = {
    },
    -- These profile.Sets will be for when both you and your pet are engaged
	Tp_Default = {
    },
	Tp_Hybrid = {
    },
	Tp_Acc = {
    },
    -- These following profile.Sets are intended for one off items to equip while the pet is engaged (or both of you) based on the PupMode. An example would be Pet HP+ pieces for Tank mode. Can be empty but do not delete.
    Tank = {
    },
    Melee = {
    },
    Ranger = {
        -- Waist = 'Klouskap Sash +1', -- do this after getting +1
    },
    Mage = {
    },

    Precast = {
        Ear1 = 'Loquac. Earring',
    },

    Enhancing = {
    },
    Phalanx = {
    },
    Stoneskin = {
    },
    Refresh = {
    },

    Cure = {
    },

    Enfeebling = {
    },

	Ws_Default = {
        Neck = 'Fotia Gorget',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },


    Pet_WS = {
	},
    Pet_RNGWS = {
	},
	
	Repair = {
	},
    Maneuver = {
	},
    Overdrive = {-- this set will force on the ability AND stay on for the duration of OD, dont change the body out because of that
    },

	TH = {--/th will force this set to equip for 10 seconds
	},
	Movement = {
        Feet = 'Hermes\' Sandals',
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Automat. Oil +3', Quantity = 'all'},
    {Name = 'Bean Daifuku', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd pupmode'},
    {'^=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Asuran Fists" <t>'},
    {'+q', '/ws "Dragon Kick" <t>'},
    {'1', '/ja "Activate" <me>'},
    {'2', '/ja "Deploy" <t>'},
    {'3', '/ja "Retrieve" <me>'},
    {'4', '/ja "Repair" <me>'},
    {'5', '/ja "Deactivate" <me>'},
    {'e', '/ja "Fire Maneuver" <me>'},
    {'+e', '/ja "Wind Maneuver" <me>'},
    {'^e', '/ja "Light Maneuver" <me>'},
    {'!e', '/ja "Thunder Maneuver" <me>'},
};

profile.AbilitySets = { ['Maintenance'] = 'Repair' };

profile.OnDefault = function(player, pet)
    if pet ~= nil and pet.Status == 'Engaged' then
        local pupmode = gcdisplay.GetCycle('PupMode');
        gcinclude.EquipIfExists(pupmode);
        if pet.TP ~= nil and pet.TP > 950 then
            if pupmode == 'Ranger' then
                gcinclude.EquipIfExists('Pet_RNGWS');
            elseif pupmode == 'Melee' then
                gcinclude.EquipIfExists('Pet_WS');
            end
        end
    end
    if gData.GetBuffCount('Overdrive') > 0 then gcinclude.EquipIfExists('Overdrive') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = { RefreshGearMPP = 30 },
        MacroBook = 9, MacroSet = 1,
    });
    gcinclude.AddCycle('PupMode', {'Tank', 'Melee', 'Ranger', 'Mage'}, 'pupmode', 'Puppet Mode');
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
