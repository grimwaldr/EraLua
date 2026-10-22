local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
SCH - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
/weapon Club or Staff: on Staff, Idle_Staff goes on while idle and spells swap to the matching elemental staff.
Nukes: Nuke -> Nuke_Macc (/nukeset) -> Helix for helixes -> obi -> Mp_Body under 40% MP. Storms use Storm.
Ebullience / Rapture up: Power. Sublimation charging: Sublimation.
/elecycle picks the element for /nuke 1-4, /helix and /weather.
Commands: /weapon /elecycle /nuke # /helix /weather /nukeset /dt /setcycle /gckeys /gcdisplay
]]

local sets = {
    Idle = {
    },
    Idle_Staff = {
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

    Tp_Default = {
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },


    Precast = {
        Ear1 = 'Loquac. Earring',
    },
    Cure_Precast = {
    },
    Enhancing_Precast = {
    },
    Stoneskin_Precast = {
    },


    Cure = {--I cap is 50, II cap is 30
    },
    Self_Cure = {--cap 30
    },
    Regen = {
    },
    Cursna = {
    },

    Enhancing = {
    },
    Self_Enhancing = {},
    Stoneskin = {
    },
    Phalanx = {},
    Refresh = {
    },
    Self_Refresh = {},

    Enfeebling = {
    },

    Drain = {
    },

    Nuke = {
    },
    Nuke_Macc = {
    },
    Burst = {
    },
    Helix = {
    },
    HelixBurst = {
    },
    Storm = {
    },
    Mp_Body = {Body = 'Seidr Cotehardie',},

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

    Sublimation = {
    },
    Power = {--rapture/ebullience
	},
    Movement = {
        Feet = 'Herald\'s Gaiters',
	},
};
sets.Helix = sets.Helix or {};
sets.Storm = sets.Storm or {};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Tropical Crepe', Quantity = 'all'},
    {Name = 'Rolan. Daifuku', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd weapon'},
    {'+=', '/lac fwd nukeset'},
    {'^=', '/lac fwd elecycle'},
    {'!=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/lac fwd nuke 1'},
    {'+q', '/lac fwd nuke 2'},
    {'^q', '/lac fwd nuke 3'},
    {'e', '/lac fwd helix'},
    {'+e', '/lac fwd weather'},
    {'t', '/ma "Cure IV" <stpc>'},
    {'+t', '/ma "Cure III" <stpc>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Blink" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'1', '/ja "Light Arts" <me>'},
    {'2', '/ja "Dark Arts" <me>'},
    {'3', '/ja "Sublimation" <me>'},
    {'4', '/ja "Penury" <me>'},
    {'5', '/ja "Parsimony" <me>'},
    {'v', '/ma "Paralyna" <stpc>'},
    {'+v', '/ma "Silena" <stpc>'},
    {'^v', '/ma "Poisona" <stpc>'},
    {'!v', '/ma "Blindna" <stpc>'},
};

profile.OnDefault = function(player)
    if gcdisplay.GetCycle('Weapon') == 'Staff' and player.Status ~= 'Engaged' then gcinclude.EquipIfExists('Idle_Staff') end
    if gData.GetBuffCount('Sublimation: Activated') > 0 then gcinclude.EquipIfExists('Sublimation') end
end

profile.OnMidcast = function(spell)
    if string.find(spell.Name, 'helix') then gcinclude.EquipIfExists('Helix') end
    if string.find(spell.Name, 'storm') then gcinclude.EquipIfExists('Storm') end
    if spell.Skill == 'Elemental Magic' and gData.GetPlayer().MPP <= 40 then gcinclude.EquipIfExists('Mp_Body') end
    if gData.GetBuffCount('Ebullience') + gData.GetBuffCount('Rapture') > 0 then gcinclude.EquipIfExists('Power') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Acc'},
        MagicModes = {'Power', 'Macc'},
        ElementalStaff = false,
        MacroBook = 8, MacroSet = 2,
    });
    gcinclude.AddCycle('Weapon', {'Club', 'Staff'}, nil);
    gcinclude.AddCommand('weapon', function()
        gcdisplay.AdvanceCycle('Weapon');
        gcinclude.settings.ElementalStaff = gcdisplay.GetCycle('Weapon') == 'Staff';
        gcinclude.StatusMessage('Mage Weapon', gcdisplay.GetCycle('Weapon'));
    end);
    gcinclude.AddNukeCommands();
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
