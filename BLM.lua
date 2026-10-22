local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
BLM - Phoenix XI (75 cap). Same layout as RDM, on the shared common folder. RDM-only gear was removed.
Sets ending in _Priority take a list per slot; the first item you own at your level is used.
Cycles:  /battle  Support | Tank       (Tank: no TP set while engaged, Cure_Tank, enmity on Blind/Flash)
         /spell   Accuracy | Potency   (Nuke_*, INT_*, MND_* sets)
         /idle    Default | Support | Hybrid | PDT | MDT  (/equippdt, /equipmdt jump straight there)
         /resist  Fire | Earth | Wind | Ice | Thunder    (/equipresist locks Resist_<element> for 7 seconds)
Midcast:
  Enfeebling: staff -> MND_<Spell> (Slow, Paralyze) | INT_<Spell> + Midcast_Enmity on Tank (Blind, Flash) | INT_<Spell> (rest; Dia gets staff only)
  Elemental:  staff -> Elemental_Debuff (Burn, Frost...) | Nuke_<Spell> + obi
  Dark: Dark + staff + obi.  Cure: Cure_<Battle>.  Enhancing: Enhancing_PhalanxBarspell | Stoneskin | Enhancing_General (+ SneakInvis)
  Utsusemi: Utsusemi. Anything else: Haste.
Abilities: Idle_PDT (Elemental Seal / Manafont use sets named after them if you add one).
Staves are picked from what you own (HQ first); /fight locks Main/Sub so meleeing doesn't lose TP to staff swaps.
Commands: /elecycle /nuke # /battle /spell /idle /resist /equippdt /equipmdt /equipresist /fight /dt /gckeys /gcdisplay
]]

local sets = {
    Precast_Priority = {
        Ear2 = 'Loquac. Earring',
    },
    Cure_Support_Priority = {
        Main = {'Apollo\'s Staff', 'Light Staff'},
        Ammo = 'Hedgehog Bomb',
        Head = {'Mahatma Hat', 'Errant Hat'},
        Neck = {'Healing Torque', 'Promise Badge', 'Holy Phial', 'Justice Badge'},
        Ear1 = {'Novia Earring', 'Geist Earring'},
        Ear2 = {'Magnetic Earring', 'Geist Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.'},
        Hands = {'Hydra Gloves', 'Devotee\'s Mitts'},
        Ring1 = {'Serene Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Umbra Cape', 'Errant Cape', 'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches'},
    },
    Cure_Tank = {},
    Midcast_Enmity = {},
    Utsusemi = {},
    Stoneskin_Priority = {
        Main = {'Mythic Wand +1', 'Mythic Wand', 'Solid Wand', 'Yew Wand +1', 'Yew Wand'},
        Sub = {'Solid Wand'},
        Head = {'Traveler\'s Hat'},
        Neck = {'Promise Badge', 'Holy Phial', 'Justice Badge'},
        Ear1 = {'Magnetic Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches'},
    },
    Nuke_Potency_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Novio Earring', 'Morion Earring'},
        Ear2 = {'Moldavite Earring', 'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Elder\'s surcoat', 'Ryl.Sqr. Robe'},
        Hands = {'Zenith Mitts', 'Errant Cuffs', 'Wizard\'s gloves', 'Elder\'s bracers', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Mahatma Slops', 'Errant Slops', 'Elder\'s Braguette'},
        Feet = {'Elder\'s sandals'},
    },
    Nuke_Accuracy_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Novio Earring', 'Morion Earring'},
        Ear2 = {'Moldavite Earring', 'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Elder\'s surcoat', 'Ryl.Sqr. Robe'},
        Hands = {'Zenith Mitts', 'Errant Cuffs', 'Wizard\'s gloves', 'Elder\'s bracers', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Elder\'s Braguette'},
        Feet = {'Elder\'s sandals'},
    },
    MND_Accuracy_Priority = {
        Head = {'Nashira Turban', 'Elite Beret', 'Errant Hat', 'Traveler\'s Hat'},
        Neck = {'Enfeebling Torque', 'Promise Badge', 'Holy Phial'},
        Ear1 = {'Enfeebling Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Elder\'s Braguette'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches'},
    },
    MND_Potency_Priority = {
        Main = {'Mythic Wand +1', 'Mythic Wand'},
        Head = {'Errant Hat', 'Traveler\'s Hat'},
        Neck = {'Faith Torque', 'Promise Badge', 'Holy Phial'},
        Ear1 = {'Enfeebling Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = {'Mahatma Slops', 'Errant Slops'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Elder\'s Braguette'},
    },
    INT_Accuracy_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Nashira Turban', 'Elite Beret', 'Baron\'s Chapeau'},
        Neck = {'Enfeebling Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Enfeebling Earring', 'Morion Earring'},
        Ear2 = {'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Elder\'s surcoat', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Elder\'s bracers', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Elder\'s Braguette'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Elder\'s sandals'},
    },
    INT_Potency_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Baron\'s Chapeau'},
        Neck = {'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Mahatma Slops', 'Errant Slops'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Elder\'s sandals'},
    },
    Elemental_Debuff_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf'},
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Zircon Ring'},
        Ring2 = {'Snow Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Black Cape +1', 'Black Cape'},
        Waist = 'Penitent\'s Rope',
        Legs = {'Mahatma Slops', 'Errant Slops'},
    },
    CC_Enfeebling = {
    },
    Idle_PDT = {
    },
    Idle_MDT = {
    },
    Enhancing_General = {
        Legs = 'Nashira Seraweels',
    },
    Enhancing_PhalanxBarspell = {
        Neck = 'Enhancing Torque',
    },
    Idle_Default_Priority = {
        Main = {'Terra\'s Staff', 'Earth Staff', 'Solid Wand'},
        Ammo = {'Hedgehog Bomb', 'Fortune Egg'},
        Neck = {'Promise Badge', 'Holy Phial'},
        Ear1 = 'Pigeon Earring',
        Ear2 = 'Pigeon Earring',
        Body = {'Dalmatica', 'Royal Cloak', 'Vermillion Cloak', 'Ryl.Sqr. Robe', 'Carpenter\'s Apron'},
        Hands = {'Errant Cuffs', 'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Merman\'s Ring', 'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Coral Ring', 'Snow Ring', 'Zircon Ring'},
        Back = {'Hexerei Cape', 'Sarcenet Cape'},
        Waist = {'Powerful Rope', 'Hierarch Belt', 'Reverend Sash'},
        Legs = {'Nashira Seraweels'},
        Feet = {'Mahatma Pigaches', 'San d\'Orian Clogs'},
    },
    Idle_Support = {
    },
    Idle_Hybrid = {
    },
    Town = {
        Main = 'Aquilo\'s Staff',
        Head = 'Gala Corsage',
        Neck = 'Checkered Scarf',
        Body = 'Mahatma Hpl.',
        Back = 'Prism Cape',
        Ring1 = 'Merman\'s Ring',
        Ring2 = 'Snow Ring',
        Waist = 'Penitent\'s Rope',
    },
    Resting_Priority = {
        Main = {'Pluto\'s Staff', 'Dark Staff', 'Pilgrim\'s Wand'},
        Neck = 'Checkered Scarf',
        Ear1 = 'Relaxing Earring',
        Ear2 = 'Magnetic Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Royal Cloak', 'Seer\'s Tunic'},
        Hands = 'Hydra Gloves',
        Waist = {'Hierarch Belt', 'Reverend Sash'},
        Legs = 'Baron\'s Slops',
        Back = 'Wizard\'s Mantle',
    },
    Dark_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Nashira Turban', 'Elite Beret', 'Baron\'s Chapeau'},
        Neck = {'Enfeebling Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Enfeebling Earring', 'Morion Earring'},
        Ear2 = {'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches'},
    },
    Convert_Tank = {
    },
    Convert_Support = {
    },
    Resist_Fire = {
    },
    Resist_Ice = {
    },
    Resist_Wind = {
    },
    Resist_Earth = {
    },
    Resist_Thunder = {
    },
    TP_Priority = {
        Ammo = 'Morion Tathlum',
        Head = 'Cmp. Eye Circlet',
        Neck = 'Holy Phial',
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Hands = {'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = 'Zircon Ring',
        Ring2 = 'Windurstian Ring',
        Back = 'Sarcenet Cape',
        Waist = 'Reverend Sash',
    },
    SneakInvis_Priority = {
        Back = 'Skulker\'s Cape',
        Hands = {'Dream Mittens +1', 'Dream Mittens'},
        Feet = {'Dream Boots +1', 'Dream Boots'},
    },
};
sets.Ws_Default = sets.Ws_Default or {};
sets.Ws_SavageBlade = sets.Ws_SavageBlade or {};
sets.Ws_SpiritsWithin = sets.Ws_SpiritsWithin or {};
profile.Sets = sets;

profile.Packer = {
};

-- Ashita key prefixes: + shift, ^ ctrl, ! alt, @ win.
profile.KeyBinds = {
    {'=', '/lac fwd spell'},
    {'+=', '/lac fwd idle'},
    {'^=', '/lac fwd elecycle'},
    {'!=', '/lac fwd resist'},
    {'^p', '/lac fwd equippdt'},
    {'!p', '/lac fwd equipmdt'},
    {'q', '/lac fwd nuke 4'},
    {'+q', '/lac fwd nuke 3'},
    {'^q', '/lac fwd nuke 2'},
    {'1', '/ma "Thunder IV" <t>'},
    {'2', '/ma "Blizzard IV" <t>'},
    {'3', '/ma "Fire IV" <t>'},
    {'4', '/ma "Aero IV" <t>'},
    {'5', '/ma "Water IV" <t>'},
    {'6', '/ma "Stone IV" <t>'},
    {'+1', '/ma "Thundaga III" <t>'},
    {'+2', '/ma "Blizzaga III" <t>'},
    {'+3', '/ma "Firaga III" <t>'},
    {'+4', '/ma "Aeroga III" <t>'},
    {'+5', '/ma "Waterga III" <t>'},
    {'+6', '/ma "Stonega III" <t>'},
    {'^1', '/ma "Shock" <t>'},
    {'^2', '/ma "Frost" <t>'},
    {'^3', '/ma "Burn" <t>'},
    {'^4', '/ma "Choke" <t>'},
    {'^5', '/ma "Drown" <t>'},
    {'^6', '/ma "Rasp" <t>'},
    {'7', '/ma "Aspir" <t>'},
    {'+7', '/ma "Drain" <t>'},
    {'+f', '/ma "Stun" <t>'},
    {'v', '/ma "Sleep II" <t>'},
    {'+v', '/ma "Sleep" <t>'},
    {'!v', '/ma "Sleepga II" <t>'},
    {'^v', '/ma "Sleepga" <t>'},
    {'!x', '/ma "Bind" <t>'},  -- x / shift+x are Sneak / Invisible when /WHM, /RDM or /SCH, else Silent Oil / Prism Powder
    {'c', '/ma "Bio II" <t>'},
    {'+c', '/ma "Poison II" <t>'},
    {'b', '/ma "Ice Spikes" <me>'},
    {'+b', '/ma "Shock Spikes" <me>'},
    {'e', '/ja "Elemental Seal" <me>'},
    {'+e', '/ja "Manafont" <me>'},
    {'j', '/ma "Warp" <me>'},
    {'+j', '/ma "Escape" <me>'},
    {'space', '/jump'},
};

-- Shared handlers for precast, items, ranged and WS; custom idle/ability/midcast logic replaces the rest below.
gcinclude.UseGenericHandlers(profile);

local MndDebuffs = T{'Slow', 'Paralyze'};
local WhateverDebuffs = T{'Dia', 'Dia II'};
local EnmityDebuffs = T{'Blind', 'Flash'};
local ElementalDebuffs = T{'Burn', 'Rasp', 'Drown', 'Choke', 'Frost', 'Shock'};

profile.HandleDefault = function()
    local player = gData.GetPlayer();
    gcinclude.SetManager:Recompute();
    if player.Status == 'Resting' then
        gcinclude.EquipIfExists('Resting');
    elseif player.Status == 'Engaged' and gcdisplay.GetCycle('BattleType') ~= 'Tank' then
        gcinclude.EquipIfExists('TP');
    else
        gcinclude.EquipIfExists('Idle_' .. gcdisplay.GetCycle('IdleType'));
    end
    gcinclude.CheckDefault();
end

profile.HandleAbility = function()
    local action = gData.GetAction();
    gcinclude.EquipIfExists('Idle_PDT');
    gcinclude.EquipIfExists(gcinclude.SetName(action.Name));
    gcinclude.CheckCancels();
end

profile.HandleMidcast = function()
    local spell = gData.GetAction();
    local spellType = gcdisplay.GetCycle('SpellType');
    local battle = gcdisplay.GetCycle('BattleType');

    if spell.Skill == 'Enfeebling Magic' then
        gcinclude.EquipStaff(spell.Element);
        if MndDebuffs:contains(gcinclude.Family(spell.Name)) then
            gcinclude.EquipIfExists('MND_' .. spellType);
        elseif EnmityDebuffs:contains(spell.Name) and battle == 'Tank' then
            gcinclude.EquipIfExists('INT_' .. spellType);
            gcinclude.EquipIfExists('Midcast_Enmity');
        elseif not WhateverDebuffs:contains(spell.Name) then
            gcinclude.EquipIfExists('INT_' .. spellType);
        end
    elseif spell.Skill == 'Elemental Magic' then
        gcinclude.EquipStaff(spell.Element);
        if ElementalDebuffs:contains(spell.Name) then
            gcinclude.EquipIfExists('Elemental_Debuff');
        else
            gcinclude.EquipIfExists('Nuke_' .. spellType);
            gcinclude.EquipObi(spell.Element);
        end
    elseif spell.Skill == 'Dark Magic' then
        gcinclude.EquipIfExists('Dark');
        gcinclude.EquipElemental(spell);
    elseif string.find(spell.Name, 'Cure') or string.find(spell.Name, 'Curaga') then
        gcinclude.EquipIfExists('Cure_' .. battle);
    elseif spell.Skill == 'Enhancing Magic' then
        if string.find(spell.Name, 'Phalanx') or string.find(spell.Name, '^Bar') then
            gcinclude.EquipIfExists('Enhancing_PhalanxBarspell');
        elseif spell.Name == 'Stoneskin' then
            gcinclude.EquipIfExists('Stoneskin');
        else
            gcinclude.EquipIfExists('Enhancing_General');
        end
        if spell.Name == 'Sneak' or spell.Name == 'Invisible' then gcinclude.EquipIfExists('SneakInvis') end
    elseif string.find(spell.Name, 'Utsusemi') then
        gcinclude.EquipIfExists('Utsusemi');
    else
        gcinclude.EquipIfExists('Haste');
    end
end

profile.OnCommand = function(args)
    if args[1] == 'synth' then
        for i = 1, tonumber(args[2]) or 1 do
            AshitaCore:GetChatManager():QueueCommand(-1, '/lastsynth');
            coroutine.sleep(23);
        end
        AshitaCore:GetChatManager():QueueCommand(-1, '/p <call20>');
    end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = false,
        WeaponLock = {'Main', 'Sub'},
        ElementalStaff = true,
    });
    gcinclude.AddCycle('BattleType', {'Support', 'Tank'}, 'battle', 'Battle Type');
    gcinclude.AddCycle('SpellType', {'Accuracy', 'Potency'}, 'spell', 'Spell Type');
    gcinclude.AddCycle('IdleType', {'Default', 'Support', 'Hybrid', 'PDT', 'MDT'}, 'idle', 'Idle Type');
    gcinclude.AddCycle('ResistElement', {'Fire', 'Earth', 'Wind', 'Ice', 'Thunder'}, 'resist', 'Resist Element');
    gcinclude.AddCommand('equippdt', function() gcdisplay.SetCycle('IdleType', 'PDT') gcinclude.StatusMessage('Idle Type', 'PDT') end);
    gcinclude.AddCommand('equipmdt', function() gcdisplay.SetCycle('IdleType', 'MDT') gcinclude.StatusMessage('Idle Type', 'MDT') end);
    gcinclude.AddCommand('equipresist', function()
        local set = gcinclude.GetSet('Resist_' .. gcdisplay.GetCycle('ResistElement'));
        if set ~= nil and next(set) ~= nil then gFunc.LockSet(set, 7) end
    end);
    gcinclude.AddNukeCommands();
    gcinclude.BindKeys(profile.KeyBinds);
end

return profile;
