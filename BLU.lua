local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
BLU - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Blue magic: BluMagical base, then by spell: BluPhysical / BluMagicAccuracy (debuffs) / BluStun / CMP (buffs) / BluSkill /
Cure / Enmity / WhiteWind / BluDark. Chain Affinity, Burst Affinity, Diffusion up: Ca / Ba / Diffusion on top.
TH (/th, if you add a TH set) only for Actinic Burst, Dream Flower, Subduction. Inside Salvage (Remnants): Salvage set.
WS: Ws_SavageBlade, Ws_Expiacion (Tizona mythic).
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
	Resting = {
    },
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
	Town = {
    },

    Evasion = {--this set will be my idle set when in /cj mode for evasion pulling
        --Ammo = 'Amar Cluster',--this is on wig atm
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
	
	Precast = {--64
    },
    Stoneskin_Precast = {
    },

    Cure = {--I cap is 50, II cap is 30
    },
    WhiteWind = {--HP+ go!
    },
    BluSkill = {
    },
    BluMagical = {
    },
    BluDark = {
    },
    BluMagicAccuracy = {
        --Ear2 = 'Regal Earring',--use this after getting AF legs +2/3
    },
    CJmid = {--same as macc set but with weapons since in CJmode we idle in eva swords
        --Ear2 = 'Regal Earring',--use this after getting AF legs +2/3
    },
    BluStun = {
    },
    BluPhysical = {
    },
    CMP = {
        --Head = 'Ipoca Beret',--in storage probably
        Waist = 'Hachirin-no-Obi',
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
    Ws_SavageBlade = {
    },
    Ws_SavageBlade_Hybrid = {
    },
    Ws_SavageBlade_Acc = {
    },
    Ws_Expiacion = {
    },
    Ws_Expiacion_Hybrid = {
    },
    Ws_Expiacion_Acc = {
    },
	
    Ca = {
    },
    Ba = {
    },
    Diffusion = {
    },

    Enmity = {
    },

    TH = {
	},
    Salvage = {
	},
	Movement = {
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Tropical Crepe', Quantity = 'all'},
    {Name = 'Rolan. Daifuku', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Savage Blade" <t>'},
    {'+q', '/ws "Vorpal Blade" <t>'},
    {'^q', '/ws "Expiacion" <t>'},
    {'1', '/ja "Chain Affinity" <me>'},
    {'2', '/ja "Burst Affinity" <me>'},
    {'3', '/ja "Diffusion" <me>'},
    {'t', '/ma "Magic Fruit" <stpc>'},
    {'+t', '/ma "Healing Breeze" <me>'},
    {'b', '/ma "Cocoon" <me>'},
    {'+b', '/ma "Refueling" <me>'},
    {'e', '/ma "Head Butt" <t>'},
    {'+e', '/ma "Sheep Song" <t>'},
};

local Physical = T{'Foot Kick','Sprout Smack','Wild Oats','Power Attack','Queasyshroom','Battle Dance','Feather Storm','Helldive','Bludgeon',
    'Claw Cyclone','Screwdriver','Grand Slam','Smite of Rage','Pinecone Bomb','Jet Stream','Uppercut','Terror Touch','Mandibular Bite','Sickle Slash',
    'Dimensional Death','Spiral Spin','Death Scissors','Seedspray','Body Slam','Hydro Shot','Frenetic Rip','Spinal Cleave','Hysteric Barrage',
    'Asuran Claws','Cannonball','Disseverment','Ram Charge','Vertical Cleave','Final Sting','Goblin Rush','Vanity Dive','Whirl of Rage'};
local Debuff = T{'Filamented Hold','Cimicine Discharge','Demoralizing Roar','Venom Shell','Light of Penance','Sandspray','Auroral Drape','Frightful Roar',
    'Enervation','Infrasonics','Lowing','Awful Eye','Voracious Trunk','Sheep Song','Soporific','Yawn','Dream Flower','Chaotic Eye','Sound Blast',
    'Blank Gaze','Stinking Gas','Geist Wall','Feather Tickle','Reaving Wind','Mortal Ray','Absolute Terror','Blistering Roar'};
local Stun = T{'Head Butt','Frypan','Tail Slap','Sub-zero Smash','Sudden Lunge'};
local Buff = T{'Cocoon','Refueling','Feather Barrier','Memento Mori','Zephyr Mantle','Warm-Up','Amplification','Triumphant Roar','Saline Coat',
    'Reactor Cool','Plasma Charge','Regeneration','Animating Wail','Battery Charge','Winds of Promy.','Barrier Tusk'};
local Skill = T{'Metallic Body','Diamondhide','Magic Barrier','Occultation'};
local Cures = T{'Pollen','Healing Breeze','Wild Carrot','Magic Fruit'};
local Enmity = T{'Actinic Burst','Exuviation','Fantod','Jettatura','Temporal Shift'};
local THSpells = T{'Actinic Burst','Dream Flower','Subduction'};

profile.OnDefault = function()
    local zone = gData.GetEnvironment().Area;
    if zone ~= nil and string.find(zone, 'Remnants') then gcinclude.EquipIfExists('Salvage') end
end

profile.OnMidcast = function(spell)
    if spell.Skill ~= 'Blue Magic' then return end
    local n = spell.Name;
    gcinclude.EquipIfExists('BluMagical');
    if Physical:contains(n) then gcinclude.EquipIfExists('BluPhysical')
    elseif Debuff:contains(n) then gcinclude.EquipIfExists('BluMagicAccuracy')
    elseif Stun:contains(n) then gcinclude.EquipIfExists('BluStun')
    elseif Buff:contains(n) then gcinclude.EquipIfExists('CMP')
    elseif Skill:contains(n) then gcinclude.EquipIfExists('BluSkill')
    elseif Cures:contains(n) then gcinclude.EquipIfExists('Cure')
    elseif Enmity:contains(n) then gcinclude.EquipIfExists('Enmity')
    elseif n == 'White Wind' then gcinclude.EquipIfExists('WhiteWind')
    elseif n == 'Evryone. Grudge' then gcinclude.EquipIfExists('BluDark') end
    if gData.GetBuffCount('Chain Affinity') > 0 then gcinclude.EquipIfExists('Ca') end
    if gData.GetBuffCount('Burst Affinity') > 0 then gcinclude.EquipIfExists('Ba') end
    if gData.GetBuffCount('Diffusion') > 0 then gcinclude.EquipIfExists('Diffusion') end
end

-- With /th on, only these spells get the TH set.
profile.WantsTH = function(spell) return THSpells:contains(spell.Name) end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 5, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
