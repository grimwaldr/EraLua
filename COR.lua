local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
COR - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Rolls: Roll (+ a set named after the roll on top) and a Lucky/Unlucky chat line (/cormsg turns it off).
Quick Draw: QuickDraw -> QuickDraw_Acc (/meleeset Acc, and always for Light Shot / Dark Shot) -> obi when day/weather help.
Wild Card, Fold, Random Deal, Snake Eye use sets named after them. /tpgun keeps Idle_TPgun on while idle.
Ranged: Preshot (commented out, see the set) | Midshot -> Midshot_Acc. Movement: Blood Cuisses, else Crimson Cuisses.
WS: Ws_SlugShot, Ws_Detonator, Ws_LeadenSalute (+ Anrin Obi when day/weather help).
Commands: /tpgun /cormsg /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = {
        Neck = 'Orochi Nodowa',
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Head = {'Darksteel Cap +1', 'Darksteel Cap'},
        Body = {'Dst. Harness +1', 'Darksteel Harness'},
        Hands = 'Merman\'s Bangles',
        Ring1 = 'Merman\'s Ring',
        Ring2 = 'Merman\'s Ring',
        Waist = 'Lieutenant\'s Sash', -- Resolute belt if you prefer MDB
        Legs = {'Dst. Subligar +1', 'Darksteel Subligar'},
        Feet = {'Dst. Leggings +1', 'Dst. Leggings'},
    },
    Idle_TPgun = {
        Main = 'Mercurial Kris',
        Range = 'Martial Gun',
    },
    Resting_Priority = {
        Main = 'Pluto\'s staff',
        Neck = {'Beak Necklace +1', 'Beak Necklace'},
        Ear1 = 'Antivenom Earring',
        Ear2 = 'Relaxing Earring',
    },
    Idle_Regen = {
    },
    Idle_Refresh = {
    },
    Town_Priority = {
        Main = 'Joyeuse',
        Range = 'Martial Gun',
        Ammo = 'Steel Bullet',
        Head = 'Corsair\'s Tricorne',
        Neck = 'Faith Torque',
        Body = {'Comm. Frac +1', 'Commodore Frac'},
        Hands = {'Comm. Gants +1', 'Commodore Gants'},
        Ring1 = 'Toreador\'s Ring',
        Ring2 = 'Rajas Ring',
        Legs = 'Crimson Cuisses',
    },

    Dt = { -- kept empty on purpose: gcinclude's low-HP auto-swap force-equips this with no combat-status check, populating it caused Tp gear to get clobbered mid-fight
    },

    Tp_Default_Priority = {
        Main = 'Mercurial Kris',
        Range = 'Martial Gun',
        Ammo = 'Steel Bullet',
        Head = 'Walahra Turban',
        Neck = 'Love Torque',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Diabolos\'s Earring', -- swapped during Dark weather, see HandleDefault
        Body = 'Skadi\'s Cuirie',
        Hands = {'Dusk Gloves +1', 'Dusk gloves'},
        Ring1 = 'Toreador\'s Ring',
        Ring2 = 'Rajas Ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Sonic Belt',
        Legs = 'Barb. Zerehs',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
        Neck = 'Peacock Amulet',
    },


    Precast = {
        Ear1 = 'Loquac. Earring',
    },


    Cure = {
        Main = 'Apollo\'s Staff',
    },

    Enhancing = {
    },

    Haste_Priority = {
        Head = 'Walahra Turban',
        Hands = {'Dusk Gloves +1', 'Dusk gloves'},
        Waist = 'Sonic Belt',
        Legs = 'Barb. Zerehs',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },

    Stoneskin = {
    },

    Enfeebling = {
    },

    -- Preshot is worn when /ra starts, so only Snapshot (shorter delay) matters here.
    -- Most players skip a preshot set: the gains are small and few pieces exist at 75.
    -- Uncomment to use it.
    -- Preshot_Priority = {
    --     Head = 'Zhago\'s Barbut',                       -- Snapshot +3
    --     Hands = {'Comm. Gants +1', 'Commodore Gants'},  -- Snapshot +5
    -- },
    Midshot = {
    },
    Midshot_Acc = {
    },

    Ws_Default = {
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },

    Ws_SlugShot = {
    },
    Ws_SlugShot_Hybrid = {
    },
    Ws_SlugShot_Acc = {
    },

    Ws_Detonator_Priority = { -- WS has +100 RACC innately, so you go all in on STR
        Head = {'Cor. Tricorne +1', 'Corsair\'s Tricorne'},
        Neck = 'Light Gorget',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Triumph Earring',
        Body = 'Denali Jacket',
        Hands = 'Alkyoneus\'s Brc.',
        Ring1 = 'Rajas Ring',
        Ring2 = 'Flame Ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Commodore Belt',
        Legs = 'Enkidu\'s Subligar',
        Feet = {'Cor. Bottes +1', 'Corsair\'s Bottes'},
        Ammo = 'Steel Bullet',
    },
    Ws_Detonator_Hybrid = {
    },
    Ws_Detonator_Acc = {
    },

    Ws_LeadenSalute_Priority = { -- there are better chest pieces than Blue Cotehard +1, but this will trigger Uggy on its own
        Head = {'Cor. Tricorne +1', 'Corsair\'s Tricorne'},
        Neck = 'Uggalepih Pendant',
        Ear1 = 'Novio Earring',
        Ear2 = 'Moldavite Earring',
        Body = {'Blue Cotehard. +1', 'Blue Cotehardie'},
        Hands = 'Skadi\'s Bazubands',
        Ring1 = 'Breeze Ring',
        Ring2 = 'Breeze Ring',
        Back = 'Commander\'s Cape',
        Waist = 'Scouter\'s Rope',
        Legs = 'Denali Kecks',
        Feet = {'Cor. Bottes +1', 'Corsair\'s Bottes'},
        Ammo = 'Corsair Bullet',
    },
    Ws_LeadenSalute_Hybrid = {
    },
    Ws_LeadenSalute_Acc = {
    },

    QuickDraw_Priority = {
        Ammo = 'Corsair Bullet',
        Head = {'Cor. Tricorne +1', 'Corsair\'s Tricorne'},
        Neck = 'Uggalepih Pendant',
        Ear1 = 'Moldavite Earring',
        Ear2 = 'Novio Earring',
        Body = 'Denali Jacket',
        Hands = {'Comm. Gants +1', 'Commodore Gants'},
        Ring1 = 'Breeze Ring',
        Ring2 = 'Breeze Ring',
        Back = 'Commander\'s Cape',
        Legs = 'Denali Kecks',
        Feet = {'Cor. Bottes +1', 'Corsair\'s Bottes'},
    },
    QuickDraw_Acc_Priority = {
        Ammo = 'Corsair Bullet',
        Head = {'Cor. Tricorne +1', 'Corsair\'s Tricorne'},
        Neck = 'Hope Torque',
        Ear1 = 'Drone Earring',
        Ear2 = 'Drone Earring',
        Body = 'Denali Jacket',
        Hands = {'Comm. Gants +1', 'Commodore Gants'},
        Ring1 = 'Breeze Ring',
        Ring2 = 'Breeze Ring',
        Back = 'Commander\'s Cape',
        Waist = 'Scouter\'s Rope',
        Legs = 'Denali Kecks',
        Feet = {'Cor. Bottes +1', 'Corsair\'s Bottes'},
    },
    Roll = {
        Head = 'Comm. Tricorne',
        Ring1 = 'Luzaf\'s Ring',
    },
    Fold = {},
    WildCard = {},
    RandomDeal = {},
    SnakeEye = {},
};
sets.Movement_Priority = { Legs = {'Blood Cuisses', 'Crimson Cuisses'} };
profile.Sets = sets;

profile.Packer = {
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd tpgun'},
    {'^=', '/lac fwd dt'},
    {'e', '/ja "Light Shot" <t>'},
    {'+e', '/ja "Dark Shot" <t>'},
    {'q', '/ja "Double-Up" <me>'},
    {'+q', '/ja "Snake Eye" <me>'},
    {'t', '/ma "Cure III" <stpc>'},
    {'+t', '/ja "Divine Seal" <me>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Blink" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Butsuon inv'},
    {'!y', '/tell Cidant inv'},
    {'p', '/dig'},
    {'1', '/ja "Hunter\'s Roll" <me>'},
    {'2', '/ja "Chaos Roll" <me>'},
    {'3', '/ja "Fighter\'s Roll" <me>'},
    {'4', '/ja "Evoker\'s Roll" <me>'},
    {'5', '/ja "Wizard\'s Roll" <me>'},
    {'6', '/ja "Corsair\'s Roll" <me>'},
    {'+1', '/ws "Slug Shot" <t>'},
    {'+2', '/ws "Detonator" <t>'},
    {'+3', '/ws "Leaden Salute" <t>'},
    {'+4', '/ra <t>'},
};

profile.OnDefault = function(player)
    if gcdisplay.GetToggle('TPgun') and player.Status ~= 'Engaged' then gcinclude.EquipIfExists('Idle_TPgun') end
end

profile.OnAbility = function(ability)
    if ability.Name == 'Light Shot' or ability.Name == 'Dark Shot' then gcinclude.EquipIfExists('QuickDraw_Acc') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        Settings = { RefreshGearMPP = 50 },
        MacroBook = 10, MacroSet = 10,
    });
    gcinclude.AddToggle('TPgun', false, 'tpgun', 'COR Forced TP Gun');
    gcinclude.AddCommand('cormsg', function()
        gcinclude.CORmsg = not gcinclude.CORmsg;
        gcinclude.StatusMessage('COR roll messages', gcinclude.CORmsg);
    end);
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
