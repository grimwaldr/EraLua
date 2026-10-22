local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
BRD - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Songs: Song_Precast (HP+ so Minstrel's Ring is active) | Song_Buff or Song_Debuff -> Song_<Type> (Song_March, Song_Lullaby,
       Song_HordeLullaby...) -> elemental staff + grip for debuffs (unless /fight) -> Harp (/forcestring).
Engaging locks Main/Sub with your TP weapons (/fight to unlock while not fighting). /swords locks Blau Dolch + Joyeuse instead (/NIN).
Idle is the MDT-leaning defensive set; Dt is the same gear without weapons/instrument, so /dt (or low HP) puts it on over TP.
Low HP: Idle_Regen under 75% HP; Minstrel's Earring at 25% HP or lower with under 100 TP (its Phoenix latent).
Abilities: a set named after them if you make one (SoulVoice, Nightingale, Troubadour).

Sets ending in _Priority list several items per slot: the first one you own (at your level) is used.
Each list is 75 BiS first, then the next best piece, so upgrades go on as you get them.
Instruments: Gjallarhorn, then the song's own instrument as +2, then +1 (no NQ). HQ armor falls back to NQ.
Phoenix notes:
  Minstrel's Ring needs HP at or under 75% AND TP under 100 when the song starts (latent "hp_under_tp_under_100").
  Threnody spells carry the counter element (Ice Threnody is Fire), so the auto staff picks the right one.
  Ajase Beads is not BRD-wearable on Phoenix, so it is not in Song_Precast.
Commands: /fight /swords /forcestring /meleeset /dt /setcycle /wsdistance /synth # /gckeys /gcdisplay
]]

local sets = {
    Idle_Priority = { -- focus on mdt over pdt; your biggest threats are from magic (usually), hence merman bangles over darksteel mitts +1
        Main = 'Terra\'s Staff',
        Sub = {'Bugard Strap +1', 'Bugard Strap'},
        Range = 'Mythic Harp +1',
        Neck = {'Star Necklace', 'Wind Torque'}, -- swap to Orochi nodowa in ToAU
        Ear1 = 'Merman\'s Earring',
        Ear2 = 'Merman\'s Earring',
        Head = {'Zenith Crown +1', 'Zenith Crown', 'Darksteel Cap +1', 'Darksteel Cap'}, -- once you get a dalm, can make this any form of mdt or pdt
        Body = {'Dalmatica', 'Vermillion Cloak'}, -- dalmatica is better especially when paired with darksteel beret+1
        Hands = 'Merman\'s Bangles',
        Ring1 = 'Merman\'s Ring',
        Ring2 = 'Merman\'s Ring',
        Back = 'Hexerei Cape', -- Umbra Cape also an option, I think Hexerei is better, mdt is more important
        Waist = 'Scouter\'s Rope', -- galka players; we need to manipulate my hp aggressively for minstrel, otherwise put something else if another race
        Legs = {'Goliard Trews', 'Dst. Subligar +1', 'Darksteel Subligar'}, -- goliard trews at ToAU
        Feet = 'Rostrum Pumps', -- using rostrum to force hp easier, galka problems
    },
    Idle_Regen_Priority = { -- under 75% HP (low-HP swap)
        Neck = 'Orochi Nodowa',
        Hands = 'Garden Bangles', -- regen is daytime only on Phoenix
        Ring1 = 'Serene Ring',
    },
    Idle_Refresh = {},
    HP_Critical = { -- 25% HP or lower with under 100 TP: Minstrel's Earring latent (damage taken down)
        Ear1 = 'Minstrel\'s Earring',
    },
    Resting_Priority = {
        Main = 'Pluto\'s Staff',
        Head = 'Oracle\'s Cap',
        Neck = {'Beak Necklace +1', 'Beak Necklace'},
        Ear1 = 'Relaxing Earring',
        Ear2 = 'Antivenom Earring',
        Body = 'Oracle\'s Robe',
        Hands = 'Oracle\'s Gloves',
        Ring1 = 'Sattva Ring',
        Ring2 = 'Merman\'s Ring',
        Back = 'Invigorating Cape',
        Waist = {'Qiqirn Sash +1', 'Qiqirn Sash'},
        Legs = 'Oracle\'s Braconi',
        Feet = 'Goliard Clogs',
    },
    Town_Priority = { -- for baiting those examines to make you feel special and important
        Main = 'Tutelary',
        Sub = 'Genbu\'s Shield',
        Range = 'Mythic Harp +1',
        Head = 'Demon Helm',
        Neck = 'Wind Torque',
        Ear1 = 'Beastly Earring',
        Ear2 = 'Musical Earring',
        Body = 'Sha\'ir Manteel',
        Hands = 'Sha\'ir Gages',
        Ring1 = 'Tamas Ring',
        Ring2 = 'Defending Ring',
        Back = 'Astute Cape',
        Waist = 'Swift Belt',
        Legs = 'Sha\'ir Seraweels',
        Feet = 'Goliard Clogs',
    },
    Movement = {},

    Tp_Default_Priority = { -- for when its time to beat someone's ass to a soundtrack
        Main = 'Joyeuse',
        Sub = 'Genbu\'s Shield',
        Range = {'Angel Lyre', 'Gjallarhorn'},
        Head = 'Walahra Turban',
        Neck = {'Spike Necklace', 'Peacock Amulet'},
        Ear1 = {'Brutal Earring', 'Suppanomimi'},
        Ear2 = 'Suppanomimi',
        Body = {'Goliard Saio', 'Scorpion Harness'},
        Hands = 'Hydra Gloves',
        Ring1 = 'Sniper\'s Ring',
        Ring2 = 'Aqua Ring',
        Back = 'Bard\'s Cape',
        Waist = {'Speed Belt', 'Swift Belt'},
        Legs = 'Byakko\'s Haidate',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Tp_Acc = {},
    Swords = { -- /swords: dual wield when /NIN
        Main = 'Blau Dolch',
        Sub = 'Joyeuse',
    },

    Ws_Default = {},
    Ws_Acc = {},
    Ws_Evisceration = {
        Range = 'Frenzy Fife',
        Head = 'Hecatomb Cap',
        Neck = 'Soil Gorget',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Pixie Earring',
        Body = 'Hecatomb Harness',
        Hands = 'Hecatomb Mittens',
        Ring1 = 'Toreador\'s Ring',
        Ring2 = 'Toreador\'s Ring',
        Back = 'Forager\'s Mantle',
        Waist = 'Gleeman\'s Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = 'Hct. Leggings',
    },
    Ws_MordantRime_Priority = { -- Carnwenhan mythic WS, CHR
        Range = 'Oliphant',
        Head = 'Hecatomb Cap',
        Neck = 'Love Torque',
        Ear1 = 'Storm Loop',
        Ear2 = 'Brutal Earring',
        Body = 'Kirin\'s Osode',
        Hands = {'Chl. Cuffs +1', 'Choral Cuffs'},
        Ring1 = 'Heavens Ring',
        Ring2 = 'Heavens Ring',
        Back = 'Bard\'s Cape',
        Waist = 'Gleeman\'s Belt',
        Legs = 'Sheikh Seraweels',
        Feet = 'Hct. Leggings',
    },

    -- Precast ---------------------------------------------------------------
    Precast_Priority = {
        Range = 'Angel Lyre',
        Head = 'Walahra Turban',
        Neck = 'Bloodbead Amulet',
        Ear1 = 'Loquac. Earring',
        Ear2 = 'Novia Earring',
        Body = 'Goliard Saio',
        Hands = 'Dusk Gloves',
        Ring1 = 'Bomb Queen Ring',
        Ring2 = 'Minstrel\'s Ring',
        Back = 'Errant Cape',
        Waist = {'Speed Belt', 'Swift Belt'},
        Legs = 'Byakko\'s Haidate',
        Feet = 'Rostrum Pumps',
    },
    Cure_Precast = {},
    Enhancing_Precast = {},
    Stoneskin_Precast = {},
    Song_Precast_Priority = { -- not to be confused with precast, this is specifically to equip enough +HP or convert gear to make sure Minstrel's ring is active
        Main = 'Tutelary',
        Sub = 'Genbu\'s Shield',
        Range = 'Gjallarhorn',
        Head = 'Genbu\'s Kabuto',
        Neck = 'Bloodbead Amulet',
        Ear1 = 'Loquac. Earring',
        Ear2 = 'Bloodbead Earring',
        Body = 'Sha\'ir Manteel',
        Hands = 'Seiryu\'s Kote',
        Ring1 = 'Bomb Queen Ring',
        Ring2 = 'Minstrel\'s Ring',
        Back = 'Gigant Mantle',
        Waist = {'Gold Mog. Belt', 'Powerful Rope'},
        Legs = {'Dusk Trousers', 'Sha\'ir Seraweels'},
        Feet = {'Rostrum Pumps', 'Dusk Ledelsens'},
    },

    -- White magic ---------------------------------------------------------------
    Cure_Priority = {
        Main = {'Apollo\'s Staff', 'Light Staff'},
        Sub = {'Light Grip', 'Raptor Strap +1', 'Raptor Strap'},
        Range = 'Angel Lyre',
        Head = 'Walahra Turban',
        Neck = 'Promise Badge',
        Ear1 = {'Magnetic Earring', 'Cmn. Earring'},
        Ear2 = {'Cmn. Earring', 'Magnetic Earring'},
        Body = 'Goliard Saio',
        Hands = 'Dusk Gloves',
        Ring1 = {'Tamas Ring', 'Aqua Ring'},
        Ring2 = 'Aqua Ring',
        Back = 'Prism Cape',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = 'Suzaku\'s Sune-Ate',
    },
    Self_Cure = {},
    Cursna = {},
    Regen = {},
    Refresh = {},
    Enhancing_Priority = { -- white magic set: haste for recast
        Range = 'Angel Lyre',
        Head = 'Walahra Turban',
        Body = 'Goliard Saio',
        Hands = 'Dusk Gloves',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Back = 'Prism Cape',
    },
    Stoneskin_Priority = { -- go for big dick mnd to scale that stoneskin
        Main = 'Neptune\'s Staff',
        Sub = {'Raptor Strap +1', 'Raptor Strap'},
        Range = 'Angel Lyre',
        Head = {'Chl. Roundlet +1', 'Choral Roundlet'},
        Neck = {'Stoneskin Torque', 'Stone Gorget'},
        Ear1 = 'Cmn. Earring',
        Ear2 = 'Cmn. Earring',
        Body = {'Kirin\'s Osode', 'Mahatma Hpl.'},
        Hands = {'Dvt. Mitts +1', 'Devotee\'s Mitts'},
        Ring1 = 'Tamas Ring',
        Ring2 = 'Aqua Ring',
        Back = 'Prism Cape',
        Waist = 'Penitent\'s Rope',
        Legs = {'Brd. Cannions +1', 'Bard\'s Cannions'},
        Feet = 'Suzaku\'s Sune-Ate',
    },
    Phalanx = {},
    -- Phoenix: Dream Boots +1 / Dream Mittens +1 have no Sneak/Invisible duration bonus in Phoenix's item data,
    -- and Skulker's Cape is WHM/BLM/RDM/SMN/BLU/SCH only. Kept in case that changes.
    Sneak_Priority = {
        Feet = {'Dream Boots +1', 'Dream Boots'},
    },
    Invisible_Priority = {
        Hands = {'Dream Mittens +1', 'Dream Mittens'},
    },
    Haste_Priority = { -- for utsusemi recast mostly; don't blow all your money on this stuff just pick it up when you can afford it, even in really good meritpo you generally dont need this much gear to be effective
        Range = 'Angel Lyre',
        Head = 'Walahra Turban',
        Ear1 = 'Loquac. Earring',
        Ear2 = 'Novia Earring',
        Body = {'Goliard Saio', 'Sha\'ir Manteel'},
        Hands = 'Dusk Gloves',
        Ring1 = {'Tamas Ring', 'Defending Ring'},
        Ring2 = 'Peace Ring',
        Back = 'Errant Cape',
        Waist = {'Speed Belt', 'Swift Belt'},
        Legs = 'Byakko\'s Haidate',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Enfeebling = {}, -- can do mnd set if you want, but you'll never stick stuff on harder targets, not enough enfeeb skill
    Nuke = {},
    Drain = {},

    -- Songs: base sets ------------------------------------------------------------
    -- Buff songs: this should be all your +singing and +wind gear, helping you push the highest march tier possible.
    -- most songs are easily capped with merited singing/wind
    Song_Buff_Priority = {
        Main = 'Chanter\'s Staff',
        Sub = {'Staff Strap', 'Bugard Strap +1', 'Bugard Strap'},
        Range = 'Gjallarhorn',
        Head = {'Demon Helm +1', 'Demon Helm', 'Brd. Roundlet +1', 'Bard\'s Roundlet'},
        Neck = 'Wind Torque',
        Ear1 = 'Musical Earring',
        Ear2 = 'Singing Earring',
        Body = 'Minstrel\'s Coat',
        Hands = {'Chl. Cuffs +1', 'Choral Cuffs'},
        Ring1 = 'Tamas Ring',
        Ring2 = {'Serene Ring', 'Minstrel\'s Ring'},
        Back = {'Errant Cape', 'Astute Cape'},
        Waist = {'Speed Belt', 'Swift Belt'},
        Legs = {'Chl. Cannions +1', 'Choral Cannions'},
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens', 'Oracle\'s Pigaches'},
    },
    -- Debuff songs: singing is 1:1 macc, CHR is 2:1 and wind is 3:1 macc respectively.
    -- Main/Sub are filled by the elemental staff + grip for the song's element unless /fight is on.
    Song_Debuff_Priority = {
        Sub = {'Bugard Strap +1', 'Bugard Strap', 'Staff Strap'},
        Range = 'Gjallarhorn',
        Head = {'Brd. Roundlet +1', 'Bard\'s Roundlet'},
        Neck = {'Temp. Torque', 'Wind Torque'},
        Ear1 = {'Musical Earring', 'Beastly Earring'},
        Ear2 = 'Singing Earring',
        Body = {'Oracle\'s Robe', 'Errant Hpl.'},
        Hands = {'Chl. Cuffs +1', 'Choral Cuffs'},
        Ring1 = {'Heavens Ring', 'Tamas Ring'},
        Ring2 = {'Balrahn\'s Ring', 'Minstrel\'s Ring'},
        Back = 'Astute Cape',
        Waist = 'Gleeman\'s Belt',
        Legs = {'Sheikh Seraweels', 'Chl. Cannions +1', 'Choral Cannions'},
        Feet = {'Goliard Clogs', 'Dune Sandals'},
    },

    -- Songs: per type (equipped over the base set) -------------------------------
    Song_Elegy_Priority = { -- your bread and butter. CHR does have a diminishing return after you get enough, but still worth getting as much as possible
        Range = {'Gjallarhorn', 'Horn +1'},
        Legs = {'Sheikh Seraweels', 'Sha\'ir Seraweels'},
    },
    Song_Finale_Priority = { -- lullaby-style recast pieces
        Range = {'Gjallarhorn', 'Horn +1'},
        Head = {'Brd. Roundlet +1', 'Bard\'s Roundlet', 'Demon Helm'},
        Ear1 = 'Loquac. Earring',
        Hands = 'Sheikh Gages',
        Waist = 'Speed Belt',
        Legs = 'Sheikh Seraweels',
        Feet = 'Sheikh Crackows',
    },
    Song_Lullaby_Priority = { -- generally you're gearing to land stuff reliably for meritpo not endgame monsters, thus you wanna go for reduced cooldown. also recommend meriting lullaby
        Range = {'Gjallarhorn', 'Horn +1'},
        Ear1 = 'Loquac. Earring',
        Body = 'Oracle\'s Robe',
        Hands = {'Sheikh Gages', 'Sha\'ir Gages'},
        Waist = {'Speed Belt', 'Swift Belt'},
        Legs = {'Sheikh Seraweels', 'Sha\'ir Seraweels'},
        Feet = {'Sheikh Crackows', 'Dune Sandals'}, -- galka 60+ rse boots, can use sha'ir instead
    },
    Song_HordeLullaby_Priority = { -- for harps, mostly for Horde Lullaby
        Range = 'Nursemaid\'s Harp',
        Body = {'Chl. Jstcorps +1', 'Choral Jstcorps'},
        Neck = 'String Torque',
        Ear2 = 'String Earring',
    },
    Song_Requiem = {
        Range = 'Requiem Flute',
    },
    Song_Threnody = {
        Range = 'Sorrowful Harp',
    },
    Song_March_Priority = { -- once again going for as much singing/wind as possible to hit the highest vmarch breakpoint you can; https://ffxiclopedia.fandom.com/wiki/Victory_March?oldid=1041394
        Range = {'Gjallarhorn', 'Faerie Piccolo'},
        Head = {'Demon Helm +1', 'Demon Helm'},
        Back = 'Astute Cape',
    },
    Song_Minuet_Priority = {
        Range = {'Gjallarhorn', 'Cornette +2', 'Cornette +1'},
        Hands = 'Sheikh Gages',
    },
    Song_Madrigal_Priority = {
        Range = {'Gjallarhorn', 'Traversiere +2', 'Traversiere +1'},
        Hands = 'Sheikh Gages',
    },
    Song_Prelude_Priority = {
        Range = {'Gjallarhorn', 'Angel\'s Flute +1'},
        Hands = 'Sheikh Gages',
    },
    Song_Ballad_Priority = { -- recast pieces over the wind set
        Range = {'Gjallarhorn', 'Storm Fife'}, -- assault reward, get it useful in nyzul especially
        Head = 'Walahra Turban',
        Neck = 'Van Pendant',
        Ear1 = 'Loquac. Earring',
        Ear2 = 'Novia Earring',
        Body = 'Goliard Saio',
        Hands = 'Sheikh Gages',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Song_Carol_Priority = {
        Range = {'Gjallarhorn', 'Crumhorn +2', 'Crumhorn +1'},
        Hands = 'Sheikh Gages',
    },
    Song_Paeon_Priority = { -- paeon is pretty useful situationally. you can also use /forcestring if you want
        Main = 'Taillefer\'s Dagger',
        Range = {'Ebony Harp +2', 'Ebony Harp +1', 'Nursemaid\'s Harp'},
        Head = 'Walahra Turban',
        Neck = 'String Torque',
        Ear1 = 'String Earring',
        Ear2 = 'Musical Earring',
        Body = {'Chl. Jstcorps +1', 'Choral Jstcorps'},
        Hands = 'Sheikh Gages',
        Ring1 = 'Tamas Ring',
        Ring2 = 'Peace Ring',
        Back = 'Astute Cape',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = 'Bard\'s Slippers',
    },
    Song_Mazurka_Priority = { -- recast
        Head = 'Walahra Turban',
        Ear1 = 'Loquac. Earring',
        Body = 'Goliard Saio',
        Hands = 'Sheikh Gages',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Song_Etude_Priority = { -- recast
        Head = 'Walahra Turban',
        Ear1 = 'Loquac. Earring',
        Body = 'Goliard Saio',
        Hands = 'Sheikh Gages',
        Waist = 'Speed Belt',
        Legs = 'Byakko\'s Haidate',
        Feet = {'Dusk Ledelsens +1', 'Dusk Ledelsens'},
    },
    Song_Minne = {},
    Song_Mambo = {
        Hands = 'Sheikh Gages',
    },
    Song_Hymnus = {
        Hands = 'Sheikh Gages',
    },

    Harp = { -- use /forcestring in game to lock this on all songs, I personally just use Paeons
        Range = 'Nursemaid\'s Harp', -- This should be your dummy harp, whichever you use
    },
};
sets.Dt_Priority = gcinclude.Without(sets.Idle_Priority, {'Main', 'Sub', 'Range', 'Ammo'});
profile.Sets = sets;

profile.Packer = {
    {Name = 'Shihei', Quantity = 'all'},
};

--[[
{ key, command }. + shift, ^ ctrl, ! alt, @ win.
Utsusemi (n / +n) is added by gcinclude on every job; Sneak/Invis (x / +x) when your subjob can cast them,
falling back to Silent Oil / Prism Powder. /gckeys lists everything bound.
]]
profile.KeyBinds = {
    {'=', '/lac fwd fight'},
    {'+=', '/lac fwd forcestring'},
    {'^=', '/lac fwd meleeset'},
    {'!=', '/lac fwd dt'},
    {'@=', '/lac fwd swords'},
    {'e', '/ma "Foe Lullaby" <t>'},
    {'+e', '/ma "Horde Lullaby" <t>'},
    {'q', '/ma "Carnage Elegy" <t>'},
    {'+q', '/ma "Battlefield Elegy" <t>'},
    {'t', '/ma "Curaga II" <me>'},
    {'+t', '/ja "Divine Seal" <me>'},
    {'b', '/ma "Stoneskin" <me>'},
    {'+b', '/ma "Blink" <me>'},
    {'^b', '/ma "Aquaveil" <me>'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Butsuon inv'},
    {'!y', '/tell Cidant inv'},
    {'p', '/item "Timeless Hrglass." <t>'},
    {'1', '/ma "Victory March" <me>'},
    {'2', '/ma "Advancing March" <me>'},
    {'3', '/ma "Mage\'s Ballad II" <me>'},
    {'4', '/ma "Mage\'s Ballad" <me>'},
    {'5', '/ma "Chocobo Mazurka" <me>'},
    {'+5', '/ma "Magic Finale" <t>'},
    {'+1', '/ma "Valor Minuet IV" <me>'},
    {'+2', '/ma "Valor Minuet III" <me>'},
    {'+3', '/ma "Blade Madrigal" <me>'},
    {'+4', '/ma "Sword Madrigal" <me>'},
    {'j', '/ma "Teleport-Mea" <me>'},
    {'+j', '/ma "Warp" <me>'},
    {'v', '/ma "Paralyna" <stal>'},
    {'+v', '/ma "Silena" <stal>'},
    {'^v', '/ma "Poisona" <stal>'},
    {'!v', '/ma "Blindna" <stal>'},
};

-- Weapons the auto-lock puts on when you engage.
profile.LockWeapons = function()
    if gcdisplay.GetToggle('Swords') then return gcinclude.GetSet('Swords') end
    return gcinclude.GetSet('Tp_Default');
end

profile.OnDefault = function(player)
    if player.Status == 'Engaged' and gcdisplay.GetToggle('Swords') then gcinclude.EquipIfExists('Swords') end
end

-- After the DT set, so the latent earring isn't swapped back off.
profile.OnLast = function(player)
    if player.HPP <= 25 and player.TP < 100 then gcinclude.EquipIfExists('HP_Critical') end
end

profile.OnMidcast = function(spell)
    if spell.Skill == 'Singing' and gcdisplay.GetToggle('String') then gcinclude.EquipIfExists('Harp') end
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
        MeleeModes = {'Default', 'Acc'},
        WeaponLock = {'Main', 'Sub'}, AutoLock = true,
        ElementalStaff = true,
        Settings = {
            AutoGear = true, RegenGearHPP = 75,
            CancelDelay = { ['Sneak'] = 1.4, ['Stoneskin'] = 5.6, ['Utsusemi: Ichi'] = 2.4 },
        },
        MacroBook = 1, MacroSet = 1,
    });
    gcinclude.AddToggle('String', false, 'forcestring', 'BRD Forced Harp');
    -- /swords: lock Blau Dolch + Joyeuse instead of your TP set weapons; re-locks right away if already locked
    gcinclude.AddToggle('Swords', false, 'swords', 'Dual Wield Swords', function()
        if gcdisplay.GetToggle('Fight') then
            gcinclude.SetWeaponLock(false);
            gcinclude.SetWeaponLock(true, profile.LockWeapons());
        end
    end);
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
