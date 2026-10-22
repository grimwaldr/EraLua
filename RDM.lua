local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
RDM - Phoenix XI (75 cap). Runs on the shared common folder.
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
Convert: Convert_<Battle> locked for 5 seconds. Other abilities: Idle_PDT.
Staves are picked from what you own (HQ first); /fight locks Main/Sub so meleeing doesn't lose TP to staff swaps.
Commands: /battle /spell /idle /resist /equippdt /equipmdt /equipresist /fight /dt /gckeys /gcdisplay
]]

local sets = {
    Precast_Priority = {
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau'},
        Ear2 = 'Loquac. Earring',
        Body = {'Dls. Tabard +1', 'Duelist\'s Tabard', 'Crow Jupon'},
    },
    Cure_Support_Priority = {
        Main = {'Apollo\'s Staff', 'Light Staff'},
        Ammo = 'Hedgehog Bomb',
        Head = {'Mahatma Hat', 'Errant Hat', 'Crow Beret'},
        Neck = {'Healing Torque', 'Promise Badge', 'Holy Phial', 'Justice Badge'},
        Ear1 = {'Novia Earring', 'Geist Earring'},
        Ear2 = {'Magnetic Earring', 'Geist Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Crow Jupon'},
        Hands = {'Hydra Gloves', 'Raven Bracers', 'Crow Bracers', 'Devotee\'s Mitts'},
        Ring1 = {'Serene Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Umbra Cape', 'Errant Cape', 'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = {'Warlock\'s Tights'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
    },
    Cure_Tank = {},
    Midcast_Enmity = {},
    Utsusemi = {},
    Stoneskin_Priority = {
        Main = {'Mythic Wand +1', 'Mythic Wand', 'Solid Wand', 'Yew Wand +1', 'Yew Wand'},
        Sub = {'Numinous Shield'},
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Traveler\'s Hat'},
        Neck = {'Promise Badge', 'Holy Phial', 'Justice Badge'},
        Ear1 = {'Magnetic Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = 'Warlock\'s Tights',
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
    },
    Nuke_Potency_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Novio Earring', 'Morion Earring'},
        Ear2 = {'Moldavite Earring', 'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Zenith Mitts', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = {'Duelist\'s Boots', 'Warlock\'s Boots'},
    },
    Nuke_Accuracy_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Novio Earring', 'Morion Earring'},
        Ear2 = {'Moldavite Earring', 'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Zenith Mitts', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = {'Duelist\'s Boots', 'Warlock\'s Boots'},
    },
    MND_Accuracy_Priority = {
        Head = {'Dls. Chapeau +1', 'Duelist\'s Chapeau', 'Nashira Turban', 'Elite Beret', 'Errant Hat', 'Traveler\'s Hat'},
        Neck = {'Enfeebling Torque', 'Promise Badge', 'Holy Phial'},
        Ear1 = {'Enfeebling Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Wlk. Tabard +1', 'Warlock\'s Tabard', 'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Warlock\'s Tights', 'Magic Cuisses'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
    },
    MND_Potency_Priority = {
        Main = {'Mythic Wand +1', 'Mythic Wand'},
        Sub = {'Numinous Shield'},
        Head = {'Errant Hat', 'Traveler\'s Hat'},
        Neck = {'Faith Torque', 'Promise Badge', 'Holy Phial'},
        Ear1 = {'Enfeebling Earring', 'Geist Earring'},
        Ear2 = {'Cmn. Earring', 'Geist Earring'},
        Body = {'Blood Scale Mail', 'Mahatma Hpl.', 'Crm. Scale Mail', 'Errant Hpl.', 'Warlock\'s Tabard', 'Ryl.Sqr. Robe'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Aqua Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Ring2 = {'Tamas Ring', 'Aquamarine Ring', 'Saintly Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'White Cape +1', 'White Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash', 'Friar\'s Rope'},
        Legs = {'Mahatma Slops', 'Errant Slops', 'Warlock\'s Tights', 'Magic Cuisses'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
    },
    INT_Accuracy_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Nashira Turban', 'Elite Beret', 'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Enfeebling Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Enfeebling Earring', 'Morion Earring'},
        Ear2 = {'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
    },
    INT_Potency_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = 'Mahatma Pigaches',
    },
    Elemental_Debuff_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Elemental Torque', 'Checkered Scarf'},
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Zircon Ring'},
        Ring2 = {'Snow Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Black Cape +1', 'Black Cape'},
        Waist = 'Penitent\'s Rope',
        Legs = {'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = {'Warlock\'s Boots'},
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
        Hands = 'Duelist\'s Gloves',
        Legs = 'Warlock\'s Tights',
    },
    Idle_Default_Priority = {
        Main = {'Terra\'s Staff', 'Earth Staff', 'Solid Wand'},
        Ammo = {'Hedgehog Bomb', 'Fortune Egg'},
        Neck = {'Promise Badge', 'Holy Phial'},
        Ear1 = 'Pigeon Earring',
        Ear2 = 'Pigeon Earring',
        Body = {'Dalmatica', 'Royal Cloak', 'Vermillion Cloak', 'Ryl.Sqr. Robe', 'Carpenter\'s Apron'},
        Hands = {'Blood Fng. Gnt.', 'Errant Cuffs', 'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = {'Merman\'s Ring', 'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Coral Ring', 'Snow Ring', 'Zircon Ring'},
        Back = {'Empwr. Mantle +1', 'Empwr. Mantle', 'Hexerei Cape', 'Sarcenet Cape'},
        Waist = {'Powerful Rope', 'Hierarch Belt', 'Reverend Sash'},
        Legs = {'Blood Cuisses', 'Nashira Seraweels', 'Warlock\'s Tights', 'Magic Cuisses'},
        Feet = {'Crimson Greaves', 'Dst. Leggings +1', 'Dst. Leggings', 'Mahatma Pigaches', 'Warlock\'s Boots', 'San d\'Orian Clogs'},
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
        Hands = 'Blood Fng. Gnt.',
        Back = 'Prism Cape',
        Ring1 = 'Merman\'s Ring',
        Ring2 = 'Snow Ring',
        Waist = 'Penitent\'s Rope',
        Legs = 'Blood Cuisses',
        Feet = 'Crimson Greaves',
    },
    Resting_Priority = {
        Main = {'Pluto\'s Staff', 'Dark Staff', 'Pilgrim\'s Wand'},
        Neck = 'Checkered Scarf',
        Ear1 = 'Relaxing Earring',
        Ear2 = 'Magnetic Earring',
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Royal Cloak'},
        Hands = 'Hydra Gloves',
        Waist = {'Duelist\'s Belt', 'Hierarch Belt', 'Reverend Sash'},
        Legs = 'Baron\'s Slops',
        Back = 'Wizard\'s Mantle',
    },
    Dark_Priority = {
        Ammo = {'Phtm. Tathlum', 'Morion Tathlum'},
        Head = {'Nashira Turban', 'Elite Beret', 'Wlk. Chapeau +1', 'Warlock\'s Chapeau', 'Baron\'s Chapeau'},
        Neck = {'Enfeebling Torque', 'Checkered Scarf', 'Black Neckerchief'},
        Ear1 = {'Enfeebling Earring', 'Morion Earring'},
        Ear2 = {'Morion Earring'},
        Body = {'Mahatma Hpl.', 'Errant Hpl.', 'Ryl.Sqr. Robe'},
        Hands = {'Mahatma Cuffs', 'Errant Cuffs', 'Dream Mittens +1', 'Dream Mittens'},
        Ring1 = {'Snow Ring', 'Zircon Ring'},
        Ring2 = {'Tamas Ring', 'Zircon Ring'},
        Back = {'Prism Cape', 'Rainbow Cape', 'Black Cape +1', 'Black Cape'},
        Waist = {'Penitent\'s Rope', 'Reverend Sash'},
        Legs = {'Nashira Seraweels', 'Mahatma Slops', 'Errant Slops', 'Magic Cuisses'},
        Feet = {'Mahatma Pigaches', 'Errant Pigaches', 'Warlock\'s Boots'},
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
        Main = {'Bee Spatha +1', 'Bee Spatha'},
        Sub = 'Marine Shield',
        Ammo = 'Morion Tathlum',
        Head = 'Cmp. Eye Circlet',
        Neck = 'Holy Phial',
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = 'Ryl.Ftm. Vest',
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
    {'^=', '/lac fwd battle'},
    {'!=', '/lac fwd resist'},
    {'^p', '/lac fwd equippdt'},
    {'!p', '/lac fwd equipmdt'},
    {'e', '/ma "Cure IV" <stal>'},
    {'+e', '/ma "Cure III" <stal>'},
    {'q', '/ma "Haste" <stal>'},
    {'+q', '/ma "Refresh" <stal>'},
    {'^q', '/ma "Regen" <stal>'},
    {'!q', '/ma "Erase" <stal>'},
    {'t', '/ma "Curaga II" <me>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Phalanx" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'!b', '/ma "Blink" <me>'},
    {'^\\', '/ma "Protect IV" <stal>'},
    {'!\\', '/ma "Shell IV" <stal>'},
    {'1', '/ma "Thunder III" <t>'},
    {'2', '/ma "Blizzard III" <t>'},
    {'3', '/ma "Fire III" <t>'},
    {'4', '/ma "Aero III" <t>'},
    {'5', '/ma "Water III" <t>'},
    {'6', '/ma "Stone III" <t>'},
    {'+1', '/ma "Thunder II" <t>'},
    {'+2', '/ma "Blizzard II" <t>'},
    {'+3', '/ma "Fire II" <t>'},
    {'+4', '/ma "Aero II" <t>'},
    {'+5', '/ma "Water II" <t>'},
    {'+6', '/ma "Stone II" <t>'},
    {'^1', '/ma "Shock" <t>'},
    {'^2', '/ma "Frost" <t>'},
    {'^3', '/ma "Burn" <t>'},
    {'^4', '/ma "Choke" <t>'},
    {'^5', '/ma "Drown" <t>'},
    {'^6', '/ma "Rasp" <t>'},
    {'!1', '/ma "Enthunder" <me>'},
    {'!2', '/ma "Enblizzard" <me>'},
    {'!3', '/ma "Enfire" <me>'},
    {'!4', '/ma "Enaero" <me>'},
    {'!5', '/ma "Enwater" <me>'},
    {'!6', '/ma "Enstone" <me>'},
    {'@1', '/ma "Barthundra" <me>; /ma "Barthunder" <me>'},
    {'@2', '/ma "Barblizzara" <me>; /ma "Barblizzard" <me>'},
    {'@3', '/ma "Barfira" <me>; /ma "Barfire" <me>'},
    {'@4', '/ma "Baraera" <me>; /ma "Baraero" <me>'},
    {'@5', '/ma "Barwatera" <me>; /ma "Barwater" <me>'},
    {'@6', '/ma "Barstonra" <me>; /ma "Barstone" <me>'},
    {'7', '/ma "Aspir" <t>'},
    {'+7', '/ma "Drain" <t>'},
    {'8', '/ma "Paralyna" <stal>'},
    {'+8', '/ma "Silena" <stal>'},
    {'^8', '/ma "Poisona" <stal>'},
    {'!8', '/ma "Cursna" <stal>'},
    {'@8', '/ma "Viruna" <stal>'},
    {'u', '/ma "Paralyze" <t>'},
    {'+u', '/ma "Slow" <t>'},
    {'^u', '/ma "Blind" <t>'},
    {'!u', '/ma "Silence" <t>'},
    {'@u', '/ma "Dispel" <t>'},
    {'c', '/ma "Dia II" <t>'},
    {'!c', '/ma "Bio" <t>'},
    {'+c', '/ma "Poison II" <t>'},
    {'@c', '/ma "Dia" <t>'},
    {'+f', '/ma "Stun" <t>'},
    {'v', '/ma "Sleep II" <t>'},
    {'+v', '/ma "Sleep" <t>'},
    {'!v', '/ma "Sleepga" <t>'},
    {'^v', '/ma "Sleepga" <t>'},
    {'^x', '/ma "Gravity" <t>'},  -- x / shift+x are Sneak / Invisible (from gcinclude)
    {'!x', '/ma "Bind" <t>'},
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
    if action.Name == 'Convert' then
        local set = gcinclude.GetSet('Convert_' .. gcdisplay.GetCycle('BattleType'));
        if set ~= nil and next(set) ~= nil then gFunc.LockSet(set, 5) end
    else
        gcinclude.EquipIfExists('Idle_PDT');
    end
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
