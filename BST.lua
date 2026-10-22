local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
BST - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Pet out and fighting on its own: Pet_Only_Tp. /dt also adds Pet_Dt while a pet is out.
Ready moves: Ready while you use it; while the pet performs it: Ready -> PetAttack / PetMagicAttack / PetMagicAccuracy.
Call Beast and Bestial Loyalty share Call. Reward, Charm, KillerInstinct use their own sets.
/autofight: when you engage and your pet isn't fighting, send it in with Fight (every 3 seconds at most).
Commands: /autofight /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = {
        Main = 'Maneater',
        Sub = 'Ridill',
        Head = {'Darksteel cap +1', 'Darksteel Cap'},
        Neck = 'Peacock amulet',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Ring1 = 'Merman\'s ring',
        Ring2 = 'Merman\'s ring',
        Legs = {'Dst. Subligar +1', 'Darksteel Subligar'},
        Feet = {'Dst. Leggings +1', 'Dst. Leggings'},
    },
	Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {
        Body = 'Gaudy harness',
    },
	Town = {
        Main = 'Juggernaut',
        Sub = 'Ridill',
        Ammo = 'Tiphia sting',
        Neck = 'Peacock amulet',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Stealth Earring',
        Body = 'Republic aketon',
    },	
	Dt = {
        Ammo = 'Tiphia sting',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Ring1 = 'Sattva Ring',
        Ring2 = 'Merman\'s ring',
	},
    Pet_Dt = {
        Head = 'Anwig Salade',
        Ring1 = 'Defending Ring',
	},
	
	Tp_Default_Priority = {
        Ammo = 'Tiphia sting',
        Head = 'Optical hat',
        Neck = 'Peacock amulet',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Beastly Earring',
        Body = 'Haubergeon',
        Hands = 'Dusk gloves',
        Ring1 = 'Rajas Ring',
        Ring2 = 'Toreador\'s Ring',
        Back = {'Forager\'s mantle', 'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Swift Belt',
        Legs = 'Byakko\'s haidate',
    },
	Tp_Acc = {
        Ring1 = 'Sniper\'s Ring',
        Ring2 = 'Sniper\'s Ring',
    },
	Charm_Priority = {
        Main = 'Light staff',
        Sub = {'Bugard Strap +1', 'Bugard Strap'},
        Head = 'Panther Mask',
        Neck = 'Flower Necklace',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Beastly Earring',
        Body = 'Beast Jackcoat',
        Hands = 'Beast Gloves',
        Waist = {'Corsette +1', 'Corsette'},
        Feet = 'Dune Sandals',
    },

    Precast = {
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
        Neck = 'Spike Necklace',
        Ear1 = 'Brutal Earring',
        Ring1 = 'Flame Ring',
        Ring2 = 'Rajas Ring',
        Legs = 'Ryl.Kgt. Breeches',
    },
    Ws_Hybrid = {
        Ammo = 'Tiphia sting',
    },
    Ws_Acc = {
        Ammo = 'Tiphia sting',
    },
    Ws_Rampage = {
        Head = 'Voyager Sallet',
        Neck = 'Soil gorget',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Beastly Earring',
        Body = 'Haubergeon',
        Hands = 'Thick mufflers',
        Ring1 = 'Sniper\'s ring',
        Ring2 = 'Sniper\'s ring',
        Back = 'Forager\'s mantle',
        Waist = 'Life Belt',
        Legs = 'Ryl.Kgt. Breeches',
    },
	
	Call = {
	},
	Reward = {
		Ammo = 'Pet Food Zeta',
		Head = 'Bison warbonnet',
		Body = 'Beast jackcoat',
		Hands = 'Ogre gloves',
		Feet = 'Beast gaiters',
	},
    KillerInstinct = {
	},
    Ready = {
	},
	Ready = {
	},
	PetAttack = {},
	PetMagicAttack = {},
	PetMagicAccuracy = {},
	
    TH = {--/th will force this set to equip for 10 seconds
	},
	Movement = {
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Pet Food Zeta', Quantity = 'all'},
    {Name = 'Furious Broth', Quantity = 'all'},
    {Name = 'Poisonous Broth', Quantity = 'all'},
    {Name = 'Livid Broth', Quantity = 'all'},
    {Name = 'Crackling Broth', Quantity = 'all'},
    {Name = 'Dire Broth', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'^=', '/lac fwd autofight'},
    {'y', '/pcmd leave'},
    {'q', '/ws "Rampage" <t>'},
    {'+q', '/ws "Decimation" <t>'},
    {'1', '/ja "Fight" <t>'},
    {'2', '/ja "Heel" <me>'},
    {'3', '/ja "Stay" <me>'},
    {'4', '/ja "Reward" <me>'},
    {'5', '/ja "Call Beast" <me>'},
    {'e', '/ja "Charm" <t>'},
    {'+e', '/ja "Sic" <t>'},
};

-- Pet moves by type (from the old shared spell lists).
local PetAttack = T{'Foot Kick','Whirl Claws','Big Scissors','Tail Blow','Blockhead','Sensilla Blades','Tegmina Buffet','Lamb Chop','Sheep Charge','Pentapeck',
    'Recoil Dive','Frogkick','Queasyshroom','Numbshroom','Shakeshroom','Nimble Snap','Cyclotail','Somersault','Tickling Tendrils','Sweeping Gouge','Grapple',
    'Double Claw','Spinning Top','Suction','Tortoise Stomp','Power Attack','Rhino Attack','Razor Fang','Claw Cyclone','Crossthrash','Scythe Tail','Ripper Fang',
    'Chomp Rush','Pecking Flurry','Sickle Slash','Mandibular Bite','Wing Slap','Beak Lunge','Head Butt','Wild Oats','Needle Shot','Disembowel',
    'Extirpating Salvo','Mega Scissors','Back Heel','Hoof Volley','Fluid Toss','Fluid Spread'};
local PetMagicAttack = T{'Gloom Spray','Fireball','Acid Spray','Molting Plumage','Cursed Sphere','Nectarous Deluge','Charged Whisker','Nepenthic Plunge'};
local PetMagicAccuracy = T{'Toxic Spit','Leaf Dagger','Venom Spray','Venom','Dark Spore','Sandblast','Dust Cloud','Stink Bomb','Slug Family','Intimidate',
    'Gloeosuccus','Spider Web','Filamented Hold','Choke Breath','Blaster','Snow Cloud','Roar','Palsy Pollen','Spore','Brain Crush','Silence Gas','Chaotic Eye',
    'Sheep Song','Soporific','Predatory Glare','Sudden Lunge','Numbing Noise','Jettatura','Bubble Shower','Spoil','Scream','Noisome Powder','Acid Mist',
    'Rhinowrecker','Swooping Frenzy','Venom Shower','Corrosive Ooze','Spiral Spin','Infrasonics','Hi-Freq Field','Purulent Ooze','Foul Waters','Sandpit',
    'Infected Leech','Pestilent Plume'};

profile.AbilitySets = { ['Call Beast'] = 'Call', ['Bestial Loyalty'] = 'Call' };

profile.OnPetAction = function(action)
    gcinclude.EquipIfExists('Ready');
    if PetAttack:contains(action.Name) then
        gcinclude.EquipIfExists('PetAttack');
    elseif PetMagicAttack:contains(action.Name) then
        gcinclude.EquipIfExists('PetMagicAttack');
    elseif PetMagicAccuracy:contains(action.Name) then
        gcinclude.EquipIfExists('PetMagicAccuracy');
    end
end

local lastFight = -100;
profile.OnDefault = function(player, pet)
    if gcdisplay.GetToggle('AutoFight') and pet ~= nil and player.Status == 'Engaged' and pet.Status ~= 'Engaged'
        and os.clock() - lastFight > 3 then
        lastFight = os.clock();
        AshitaCore:GetChatManager():QueueCommand(1, '/ja "Fight" <t>');
    end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = { RefreshGearMPP = 50 },
        MacroBook = 1, MacroSet = 1,
    });
    gcinclude.AddToggle('AutoFight', true, 'autofight', 'Auto Fight');
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
