local gcinclude = T{};

--[[
Shared code for every job file. Built for Phoenix XI (75 cap, through WotG).

The two tables at the top (sets, settings) are the only parts meant to be edited by hand.
Anything in settings can be overridden per job, either in gcinclude.SetupJob's Settings
option or in OnLoad, for example:
    gcinclude.settings.RefreshGearMPP = 50;

Avoid main/sub/range/ammo in the shared sets. A slot can be a list ({'HQ', 'NQ'}): the first one you own is used.
]]
gcinclude.sets = T{
    Sleeping = {     -- equipped while asleep
    },
    Reraise = {      -- /rrset toggles this on (e.g. Reraise Hairpin / Reraise Gorget / Reraise Earring)
    },
    Crafting = {     -- /craftset
        Body = 'Tanner\'s Apron',
        Hands = 'Tanner\'s Gloves',
    },
    Fishing = {      -- /fishset, and automatically while a fishing rod is in the Range slot
        Body = {'Angler\'s Tunica', 'Fsh. Tunica'},
        Hands = {'Angler\'s Gloves', 'Fsh. Gloves'},
        Legs = {'Angler\'s Hose', 'Fisherman\'s Hose'},
        Feet = {'Waders', 'Angler\'s Boots', 'Fisherman\'s Boots'},
    },
    Helm = {         -- /helmset (harvesting, excavation, logging, mining)
        Body = {'Worker Tunica', 'Field Tunica'},
        Hands = {'Worker Gloves', 'Field Gloves'},
        Legs = {'Worker Hose', 'Field Hose'},
        Feet = {'Worker Boots', 'Field Boots'},
    },
};

gcinclude.settings = {
    Messages = true;          -- chat message every time a /command changes a toggle or cycle
    AutoGear = false;         -- auto Idle_Regen / Idle_Refresh / Dt / Pet_Dt at the %s below
    RegenGearHPP = 60;
    RefreshGearMPP = 25;
    DTGearHPP = 40;
    PetDTGearHPP = 50;
    AutoMovement = true;      -- equip the Movement set whenever you are moving, engaged or not
    Aketons = true;           -- nation aketon in your nation's zones (only works for your own nation)

    WScheck = true;           -- cancel melee WS if the mob is farther than WSdistance (saves your TP)
    WSdistance = 6;

    -- Elemental staves and obis. ElementalStaff only swaps Main when the job allows it and Main is not locked.
    ElementalStaff = false;   -- casting jobs turn this on in SetupJob
    ElementalObi = true;      -- waist only, safe for every job

    -- Buff cancelling. /cancel <id> needs the 'debuff' addon (or another /cancel provider) loaded.
    CancelShadows = true;     -- Utsusemi: Ichi cancels existing shadows only when it would otherwise fail
    CancelSneak = true;       -- recasting Sneak on yourself / using Silent Oil while Sneak is up
    CancelInvisible = false;  -- recasting Invisible on yourself (off by default: you are visible during the cancel)
    CancelStoneskin = true;
    CancelBlink = true;
    -- When the cancel fires: (cast time x (1 - FastCast)) - CancelLead seconds after you start casting.
    -- Per-spell overrides in seconds go in CancelDelay, e.g. CancelDelay = { ['Sneak'] = 1.4 }.
    FastCast = 0;
    CancelLead = 0.8;
    CancelDelay = {};
};

--[[
Everything below here is functions and tables. Edit with care.
]]
gcdisplay = gFunc.LoadFile('common\\gcdisplay.lua');
local setmanager = gFunc.LoadFile('common\\setmanager.lua');

---------------------------------------------------------------------------
-- Tables
---------------------------------------------------------------------------
gcinclude.Towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]',
    'San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria',
    'Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower',
    'Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg'};

-- Aketons give movement speed in your own nation's zones.
gcinclude.NationAketons = T{
    ['Southern San d\'Oria'] = 'Kingdom Aketon', ['Northern San d\'Oria'] = 'Kingdom Aketon',
    ['Port San d\'Oria'] = 'Kingdom Aketon', ['Chateau d\'Oraguille'] = 'Kingdom Aketon',
    ['Bastok Mines'] = 'Republic Aketon', ['Bastok Markets'] = 'Republic Aketon',
    ['Port Bastok'] = 'Republic Aketon', ['Metalworks'] = 'Republic Aketon',
    ['Windurst Waters'] = 'Federation Aketon', ['Windurst Walls'] = 'Federation Aketon',
    ['Port Windurst'] = 'Federation Aketon', ['Windurst Woods'] = 'Federation Aketon',
    ['Heavens Tower'] = 'Federation Aketon',
};

-- Rings that should never be swapped off while worn (exp bands, teleport rings).
gcinclude.LockingRings = T{'Chariot Band','Empress Band','Emperor Band','Anniversary Ring','Tavnazian Ring','Warp Ring'};

-- Ranged / magical WS that skip the WS distance check.
gcinclude.DistanceWS = T{'Flaming Arrow','Piercing Arrow','Dulling Arrow','Sidewinder','Blast Arrow','Arching Arrow','Empyreal Arrow','Namas Arrow',
    'Hot Shot','Split Shot','Sniper Shot','Slug Shot','Blast Shot','Heavy Shot','Detonator','Coronach','Trueflight','Leaden Salute','Starlight','Moonlight'};

-- Weapon skills with an element (magical / hybrid): the matching obi goes on when day/weather help.
gcinclude.ElementalWS = T{
    ['Burning Blade'] = 'Fire', ['Red Lotus Blade'] = 'Fire', ['Shining Blade'] = 'Light', ['Seraph Blade'] = 'Light',
    ['Gust Slash'] = 'Wind', ['Cyclone'] = 'Wind', ['Energy Steal'] = 'Dark', ['Energy Drain'] = 'Dark',
    ['Frostbite'] = 'Ice', ['Freezebite'] = 'Ice', ['Thunder Thrust'] = 'Thunder', ['Raiden Thrust'] = 'Thunder',
    ['Blade: Teki'] = 'Water', ['Blade: To'] = 'Ice', ['Blade: Chi'] = 'Earth', ['Blade: Ei'] = 'Dark',
    ['Tachi: Jinpu'] = 'Wind', ['Tachi: Koki'] = 'Light', ['Tachi: Goten'] = 'Thunder', ['Tachi: Kagero'] = 'Fire',
    ['Shining Strike'] = 'Light', ['Seraph Strike'] = 'Light', ['Rock Crusher'] = 'Earth', ['Earth Crusher'] = 'Earth',
    ['Shadow of Death'] = 'Dark', ['Dark Harvest'] = 'Dark', ['Infernal Scythe'] = 'Dark',
    ['Flaming Arrow'] = 'Fire', ['Hot Shot'] = 'Fire', ['Trueflight'] = 'Light', ['Leaden Salute'] = 'Dark',
};

-- Rolls: {name, lucky, unlucky}
gcinclude.Rolls = T{{'Fighter\'s Roll',5,9}, {'Monk\'s Roll',3,7}, {'Healer\'s Roll',3,7}, {'Corsair\'s Roll',5,9}, {'Ninja Roll',4,8},
    {'Hunter\'s Roll',4,8}, {'Chaos Roll',4,8}, {'Magus\'s Roll',2,6}, {'Drachen Roll',4,8}, {'Choral Roll',2,6}, {'Beast Roll',4,8},
    {'Samurai Roll',2,6}, {'Evoker\'s Roll',5,9}, {'Rogue\'s Roll',5,9}, {'Warlock\'s Roll',4,8}, {'Puppet Roll',3,7}, {'Gallant\'s Roll',3,7},
    {'Wizard\'s Roll',5,9}, {'Dancer\'s Roll',3,7}, {'Scholar\'s Roll',2,6}};

-- Elemental staves: HQ first, the first one you own is used.
gcinclude.ElementalStaves = T{
    ['Fire']    = {'Vulcan\'s Staff', 'Fire Staff'},
    ['Ice']     = {'Aquilo\'s Staff', 'Ice Staff'},
    ['Wind']    = {'Auster\'s Staff', 'Wind Staff'},
    ['Earth']   = {'Terra\'s Staff', 'Earth Staff'},
    ['Thunder'] = {'Jupiter\'s Staff', 'Thunder Staff'},
    ['Water']   = {'Neptune\'s Staff', 'Water Staff'},
    ['Light']   = {'Apollo\'s Staff', 'Light Staff'},
    ['Dark']    = {'Pluto\'s Staff', 'Dark Staff'},
};
-- Elemental grips go in Sub with the matching staff when you own one.
gcinclude.ElementalGrips = T{
    ['Fire'] = 'Fire Grip', ['Ice'] = 'Ice Grip', ['Wind'] = 'Wind Grip', ['Earth'] = 'Earth Grip',
    ['Thunder'] = 'Thunder Grip', ['Water'] = 'Water Grip', ['Light'] = 'Light Grip', ['Dark'] = 'Dark Grip',
};
gcinclude.ElementalObis = T{
    ['Fire'] = 'Karin Obi', ['Ice'] = 'Hyorin Obi', ['Wind'] = 'Furin Obi', ['Earth'] = 'Dorin Obi',
    ['Thunder'] = 'Rairin Obi', ['Water'] = 'Suirin Obi', ['Light'] = 'Korin Obi', ['Dark'] = 'Anrin Obi',
};
-- The element each element is weak to (that day/weather works against it).
gcinclude.WeakTo = T{
    ['Fire'] = 'Water', ['Ice'] = 'Fire', ['Wind'] = 'Ice', ['Earth'] = 'Wind',
    ['Thunder'] = 'Earth', ['Water'] = 'Thunder', ['Light'] = 'Dark', ['Dark'] = 'Light',
};

-- /elecycle order and the spell name for each (BLM/RDM/SCH /nuke, SCH /helix and /weather)
gcinclude.Elements = T{'Thunder', 'Blizzard', 'Fire', 'Stone', 'Aero', 'Water'};
gcinclude.HelixSpells = T{'Ionohelix', 'Cryohelix', 'Pyrohelix', 'Geohelix', 'Anemohelix', 'Hydrohelix'};
gcinclude.StormSpells = T{'Thunderstorm', 'Hailstorm', 'Firestorm', 'Sandstorm', 'Windstorm', 'Rainstorm'};
gcinclude.NinNukes = T{'Katon: Ichi', 'Katon: Ni', 'Hyoton: Ichi', 'Hyoton: Ni', 'Huton: Ichi', 'Huton: Ni',
    'Doton: Ichi', 'Doton: Ni', 'Raiton: Ichi', 'Raiton: Ni', 'Suiton: Ichi', 'Suiton: Ni'};

-- Buff IDs used for cancelling.
gcinclude.BuffId = { Sneak = 71, Invisible = 69, Stoneskin = 37, Blink = 36, Deodorize = 70, CopyImage = {66, 444, 445, 446} };

gcinclude.CraftSet = false;
gcinclude.FishSet = false;
gcinclude.HelmSet = false;
gcinclude.RRSet = false;
gcinclude.CORmsg = true;
gcinclude.LastUtsu = nil;   -- 'Ichi' or 'Ni', the last Utsusemi you started casting

---------------------------------------------------------------------------
-- Messages and set helpers
---------------------------------------------------------------------------
function gcinclude.Message(text)
    print(chat.header('GCinclude'):append(chat.message(text)));
end

function gcinclude.StatusMessage(label, status)
    if gcinclude.settings.Messages and label ~= nil and status ~= nil then
        gcinclude.Message(label .. ' is now ' .. tostring(status));
    end
end

-- Find a set in the profile by name (case-insensitive), nil if missing. Avoids "Set not found" spam.
function gcinclude.GetSet(name)
    if gProfile == nil or gProfile.Sets == nil or name == nil then return nil end
    local lname = string.lower(name);
    for k, v in pairs(gProfile.Sets) do
        if string.lower(k) == lname then return v end
    end
    return nil;
end

-- Equip a set by name only if it exists and is not empty.
function gcinclude.EquipIfExists(name)
    local set = gcinclude.GetSet(name);
    if type(set) == 'table' and next(set) ~= nil then
        gFunc.EquipSet(set);
        return true;
    end
    return false;
end

-- A copy of a set without the listed slots, e.g. Dt = gcinclude.Without(sets.Idle, {'Main','Sub','Range','Ammo'})
function gcinclude.Without(set, slots)
    local copy = {};
    for k, v in pairs(set or {}) do copy[k] = v end
    for _, s in ipairs(slots or {}) do copy[s] = nil end
    return copy;
end

---------------------------------------------------------------------------
-- Inventory lookups (cached; rebuilt on zone and every 10 seconds at most)
---------------------------------------------------------------------------
local ownedItems = {};
local ownedTime = -100;

local function RebuildOwned()
    ownedItems = {};
    local inv = AshitaCore:GetMemoryManager():GetInventory();
    if inv == nil then return end
    for _, container in ipairs(gSettings.EquipBags) do
        if gData.GetContainerAvailable(container) then
            for index = 1, gData.GetContainerMax(container) do
                local item = inv:GetContainerItem(container, index);
                if item ~= nil and item.Id ~= nil and item.Id > 0 and item.Count > 0 then
                    ownedItems[item.Id] = true;
                end
            end
        end
    end
    ownedTime = os.clock();
end

ashita.events.register('packet_in', 'gcinclude_zone_cb', function (e)
    if e.id == 0x0A then ownedTime = -100 end
end);

function gcinclude.HaveItem(name)
    if os.clock() - ownedTime > 10 then RebuildOwned() end
    local res = AshitaCore:GetResourceManager():GetItemByName(name, 0);
    return res ~= nil and ownedItems[res.Id] == true;
end

-- First item in the list that you own, or nil.
function gcinclude.FirstOwned(list)
    for _, name in ipairs(list) do
        if gcinclude.HaveItem(name) then return name end
    end
    return nil;
end

-- Equip one of the shared sets above, resolving {'HQ', 'NQ'} lists to the first one you own.
function gcinclude.EquipShared(set)
    local resolved = {};
    for slot, value in pairs(set or {}) do
        if type(value) == 'table' then value = gcinclude.FirstOwned(value) end
        if value ~= nil then resolved[slot] = value end
    end
    if next(resolved) ~= nil then gFunc.EquipSet(resolved) end
end

-- True while a fishing rod (Fishing skill item) is in the Range slot.
function gcinclude.HoldingRod()
    local range = gData.GetEquipment().Range;
    if range == nil or range.Name == nil then return false end
    local res = AshitaCore:GetResourceManager():GetItemByName(range.Name, 0);
    return res ~= nil and res.Skill == 48;
end

---------------------------------------------------------------------------
-- Toggles, cycles and /commands
---------------------------------------------------------------------------
gcinclude.Commands = {};   -- alias -> function(args)

function gcinclude.AddCommand(alias, func)
    gcinclude.Commands[alias] = func;
end

-- A toggle with an optional /alias. onChange(newValue) runs after it flips.
function gcinclude.AddToggle(name, default, alias, label, onChange)
    gcdisplay.CreateToggle(name, default);
    if alias ~= nil then
        gcinclude.AddCommand(alias, function()
            gcdisplay.AdvanceToggle(name);
            local value = gcdisplay.GetToggle(name);
            if onChange ~= nil then onChange(value) end
            gcinclude.StatusMessage(label or name, value);
        end);
    end
end

-- A cycle with an optional /alias that advances it.
function gcinclude.AddCycle(name, values, alias, label)
    gcdisplay.CreateCycle(name, values);
    if alias ~= nil then
        gcinclude.AddCommand(alias, function()
            gcdisplay.AdvanceCycle(name);
            gcinclude.StatusMessage(label or name, gcdisplay.GetCycle(name));
        end);
    end
end

-- The current value of a cycle, or nil when it is on its first (default) value.
function gcinclude.Mode(name)
    if not gcdisplay.HasCycle(name) then return nil end
    local value = gcdisplay.GetCycle(name);
    if value == gcdisplay.FirstValue(name) then return nil end
    return value;
end

-- Weapon lock (/fight): disables the given slots so casting swaps don't eat your TP.
function gcinclude.AddWeaponLock(slots, default)
    gcinclude.LockSlots = slots or {'Main', 'Sub'};
    local function apply(locked)
        for _, slot in ipairs(gcinclude.LockSlots) do
            if locked then gFunc.Disable(slot) else gFunc.Enable(slot) end
        end
    end
    gcinclude.AddToggle('Fight', default == true, 'fight', 'Weapon Lock', apply);
    if default == true then apply(true) end
end

-- Turn the weapon lock on or off from code (only acts when it actually changes).
-- weaponSet (optional): when locking, its locked slots (e.g. your TP Main/Sub) are equipped first,
-- so you don't lock in whatever staff you were idling with.
function gcinclude.SetWeaponLock(locked, weaponSet)
    if not gcdisplay.HasToggle('Fight') or gcdisplay.GetToggle('Fight') == locked then return end
    if locked and type(weaponSet) == 'table' then
        local weapons = {};
        for _, slot in ipairs(gcinclude.LockSlots) do weapons[slot] = weaponSet[slot] end
        if next(weapons) ~= nil then gFunc.ForceEquipSet(weapons) end
    end
    gcinclude.Commands['fight']();
end

local function SetupCommonCommands()
    gcinclude.AddToggle('DTset', false, 'dt', 'DT Set');

    gcinclude.AddCommand('gcmessages', function()
        gcinclude.settings.Messages = not gcinclude.settings.Messages;
        gcinclude.Message('Chat messages are now ' .. tostring(gcinclude.settings.Messages));
    end);
    gcinclude.AddCommand('wsdistance', function(args)
        if tonumber(args[2]) then
            gcinclude.settings.WScheck = true;
            gcinclude.settings.WSdistance = tonumber(args[2]);
            gcinclude.Message('WS distance check is on at ' .. gcinclude.settings.WSdistance .. ' yalms');
        else
            gcinclude.settings.WScheck = not gcinclude.settings.WScheck;
            gcinclude.Message('WS distance check is now ' .. tostring(gcinclude.settings.WScheck) .. ' (/wsdistance ## to set the distance)');
        end
    end);
    gcinclude.AddCommand('setcycle', function(args)
        local name = args[2] and gcdisplay.FindCycle(args[2]);
        if name and gcdisplay.SetCycle(name, args[3]) then
            gcinclude.StatusMessage(name, gcdisplay.GetCycle(name));
        else
            gcinclude.Message('Usage: /setcycle <cycle> <value>');
        end
    end);
    gcinclude.AddCommand('craftset', function()
        gcinclude.CraftSet = not gcinclude.CraftSet;
        gcinclude.StatusMessage('Crafting Set', gcinclude.CraftSet);
    end);
    gcinclude.AddCommand('fishset', function()
        gcinclude.FishSet = not gcinclude.FishSet;
        gcinclude.StatusMessage('Fishing Set', gcinclude.FishSet);
    end);
    gcinclude.AddCommand('helmset', function()
        gcinclude.HelmSet = not gcinclude.HelmSet;
        gcinclude.StatusMessage('HELM Set', gcinclude.HelmSet);
    end);
    gcinclude.AddCommand('rrset', function()
        gcinclude.RRSet = not gcinclude.RRSet;
        gcinclude.StatusMessage('Reraise Set', gcinclude.RRSet);
    end);
    gcinclude.AddCommand('gckeys', function() gcinclude.ListBinds() end);
end

-- Call from profile.HandleCommand. Returns true if the command was handled here.
function gcinclude.HandleCommands(args)
    local func = gcinclude.Commands[args[1]];
    if func == nil then return false end
    func(args);
    return true;
end

local function SetAliases()
    for alias, _ in pairs(gcinclude.Commands) do
        AshitaCore:GetChatManager():QueueCommand(-1, '/alias /' .. alias .. ' /lac fwd ' .. alias);
    end
end

local function ClearAliases()
    for alias, _ in pairs(gcinclude.Commands) do
        AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /' .. alias);
    end
end

---------------------------------------------------------------------------
-- Keybinds
---------------------------------------------------------------------------
--[[
Each job lists its own binds in profile.KeyBinds as { key, command } or { key, command, function(player) return condition end }.
On top of those, gcinclude adds Utsusemi on n / shift+n for every job, and stealth binds (x / shift+x) for what your jobs can use,
unless the job already binds that key. Binds are refreshed if your subjob changes.
Ashita key prefixes: + shift, ^ ctrl, ! alt, @ win.
]]
gcinclude.DefaultBinds = {
    -- Utsusemi is always n / shift+n on every job, whatever the subjob.
    { 'n',  '/ma "Utsusemi: Ni" <me>' },
    { '+n', '/ma "Utsusemi: Ichi" <me>' },
    -- Stealth: x = sneak, shift+x = invisible on every job. White magic (WHM/RDM/SCH main or sub) wins,
    -- then NIN tools (Monomi/Tonko, NIN main or /NIN), then Silent Oil / Prism Powder.
    { 'x',  '/ma "Sneak" <stal>',        function(p) return gcinclude.CanCastStealth(p) end },
    { '+x', '/ma "Invisible" <stal>',    function(p) return gcinclude.CanCastStealth(p) end },
    { 'x',  '/ma "Monomi: Ichi" <me>',   function(p) return p.MainJob == 'NIN' or (p.SubJob == 'NIN' and p.SubJobLevel >= 19) end },
    { '+x', '/ma "Tonko: Ichi" <me>',    function(p) return p.MainJob == 'NIN' or (p.SubJob == 'NIN' and p.SubJobLevel >= 9) end },
    { 'x',  '/item "Silent Oil" <me>',   function(p) return not gcinclude.CanCastStealth(p) end },
    { '+x', '/item "Prism Powder" <me>', function(p) return not gcinclude.CanCastStealth(p) end },
};

-- WHM 20, RDM 20, SCH 20 (main or sub) have Sneak and Invisible.
function gcinclude.CanCastStealth(p)
    local casters = T{'WHM', 'RDM', 'SCH'};
    return casters:contains(p.MainJob) or (casters:contains(p.SubJob) and p.SubJobLevel >= 20);
end

local activeBinds = {};
local boundSubJob = nil;

function gcinclude.BindKeys(jobBinds)
    gcinclude.UnbindKeys();
    gcinclude.JobBinds = jobBinds or gcinclude.JobBinds or {};
    local player = gData.GetPlayer();
    local used = {};
    -- A job bind can have a third entry: function(player) returning true when the bind applies (e.g. only when /SAM).
    for _, b in ipairs(gcinclude.JobBinds) do
        if b[3] == nil or b[3](player) then
            activeBinds[#activeBinds + 1] = { b[1], b[2] };
            used[b[1]] = true;
        end
    end
    for _, b in ipairs(gcinclude.DefaultBinds) do
        if not used[b[1]] and (b[3] == nil or b[3](player)) then
            activeBinds[#activeBinds + 1] = { b[1], b[2] };
            used[b[1]] = true;
        end
    end
    for _, b in ipairs(activeBinds) do
        AshitaCore:GetChatManager():QueueCommand(-1, '/bind ' .. b[1] .. ' ' .. b[2]);
    end
    boundSubJob = player.SubJob;
end

function gcinclude.UnbindKeys()
    for _, b in ipairs(activeBinds) do
        AshitaCore:GetChatManager():QueueCommand(-1, '/unbind ' .. b[1]);
    end
    activeBinds = {};
end

function gcinclude.ListBinds()
    for _, b in ipairs(activeBinds) do
        gcinclude.Message(b[1] .. '  ->  ' .. b[2]);
    end
end

local function CheckSubJobBinds()
    local sub = gData.GetPlayer().SubJob;
    if boundSubJob ~= nil and sub ~= boundSubJob then gcinclude.BindKeys() end
end

---------------------------------------------------------------------------
-- Idle/default helpers
---------------------------------------------------------------------------
function gcinclude.CheckCommonDebuffs()
    if gData.GetBuffCount('Sleep') >= 1 then gFunc.EquipSet(gcinclude.sets.Sleeping) end
end

function gcinclude.CheckLockingRings()
    local equip = gData.GetEquipment();
    for _, slot in ipairs({'Ring1', 'Ring2'}) do
        if equip[slot] ~= nil and gcinclude.LockingRings:contains(equip[slot].Name) then
            gFunc.Equip(slot, equip[slot].Name);
        end
    end
end

function gcinclude.SetTownGear()
    local zone = gData.GetEnvironment();
    if zone.Area == nil then return end
    if gcinclude.Towns:contains(zone.Area) then gcinclude.EquipIfExists('Town') end
    if gcinclude.settings.Aketons and gcinclude.NationAketons[zone.Area] then
        gFunc.Equip('Body', gcinclude.NationAketons[zone.Area]);
    end
end

function gcinclude.SetRegenRefreshGear()
    if gcinclude.settings.AutoGear == false then return end
    local player = gData.GetPlayer();
    local pet = gData.GetPet();
    if player.Status == 'Idle' then
        if player.HPP < gcinclude.settings.RegenGearHPP then gcinclude.EquipIfExists('Idle_Regen') end
        if player.MPP < gcinclude.settings.RefreshGearMPP then gcinclude.EquipIfExists('Idle_Refresh') end
    end
    if player.HPP < gcinclude.settings.DTGearHPP then gcinclude.EquipIfExists('Dt') end
    if pet ~= nil and pet.HPP < gcinclude.settings.PetDTGearHPP then gcinclude.EquipIfExists('Pet_Dt') end
end

--[[
Runs at the end of every idle/TP update (gcinclude.DoDefault calls it).
Order: auto regen/refresh/DT, DT toggle, movement, town and aketon, debuff sets,
craft/fish/HELM/reraise toggles, locking rings.
]]
function gcinclude.CheckDefault()
    local player = gData.GetPlayer();
    gcinclude.SetRegenRefreshGear();
    if gcdisplay.GetToggle('DTset') then
        gcinclude.EquipIfExists('Dt');
        if gData.GetPet() ~= nil then gcinclude.EquipIfExists('Pet_Dt') end
    end
    -- Moving means you want move speed, engaged or not (chasing, kiting, repositioning). Your TP gear comes back when you stop.
    if gcinclude.settings.AutoMovement and player.IsMoving then
        -- Movement_Night (e.g. Ninja Kyahan) is used instead of Movement from 18:00 to 06:00 if you have one
        local time = gData.GetEnvironment().Time;
        local night = time ~= nil and (time < 6.00 or time >= 18.00);
        if not (night and gcinclude.EquipIfExists('Movement_Night')) then gcinclude.EquipIfExists('Movement') end
    end
    if player.Status ~= 'Engaged' then gcinclude.SetTownGear() end
    gcinclude.CheckCommonDebuffs();
    if gcinclude.CraftSet then gcinclude.EquipShared(gcinclude.sets.Crafting) end
    if gcinclude.HelmSet then gcinclude.EquipShared(gcinclude.sets.Helm) end
    if gcinclude.FishSet or gcinclude.HoldingRod() then
        gcinclude.EquipShared(gcinclude.sets.Fishing);
        -- Keep the rod and bait on over job sets that use Range/Ammo (BRD instruments, RNG/COR guns)
        local equip = gData.GetEquipment();
        if gcinclude.HoldingRod() then
            gFunc.Equip('Range', equip.Range.Name);
            if equip.Ammo ~= nil and equip.Ammo.Name ~= nil then gFunc.Equip('Ammo', equip.Ammo.Name) end
        end
    end
    if gcinclude.RRSet then gcinclude.EquipShared(gcinclude.sets.Reraise) end
    gcinclude.CheckLockingRings();
    CheckSubJobBinds();
    gcdisplay.Update();
end

---------------------------------------------------------------------------
-- Bailouts
---------------------------------------------------------------------------
-- Returns false if the WS should be cancelled (asleep/stunned etc, under 1000 TP, or too far).
function gcinclude.CheckWsBailout()
    local player = gData.GetPlayer();
    local ws = gData.GetAction();
    local target = gData.GetActionTarget();
    local blocked = gData.GetBuffCount('Sleep') + gData.GetBuffCount('Petrification') + gData.GetBuffCount('Stun')
        + gData.GetBuffCount('Terror') + gData.GetBuffCount('Amnesia') + gData.GetBuffCount('Charm');

    if gcinclude.settings.WScheck and target ~= nil and not gcinclude.DistanceWS:contains(ws.Name)
        and tonumber(target.Distance) > gcinclude.settings.WSdistance then
        gcinclude.Message('Too far for ' .. ws.Name .. '! Move closer or /wsdistance ##');
        return false;
    end
    if player.TP <= 999 or blocked >= 1 then return false end
    return true;
end

function gcinclude.CheckSpellBailout()
    local blocked = gData.GetBuffCount('Sleep') + gData.GetBuffCount('Petrification') + gData.GetBuffCount('Stun')
        + gData.GetBuffCount('Terror') + gData.GetBuffCount('Silence') + gData.GetBuffCount('Charm');
    return blocked == 0;
end

---------------------------------------------------------------------------
-- Buff cancelling (Utsusemi, Sneak, Invisible, Stoneskin, Blink, Silent Oil, Spectral Jig)
---------------------------------------------------------------------------
local function Cancel(id, delay)
    local cmd = function() AshitaCore:GetChatManager():QueueCommand(-1, '/cancel ' .. id) end;
    if delay and delay > 0 then cmd:once(delay) else cmd() end
end

local function CancelDelay(action)
    local override = gcinclude.settings.CancelDelay[action.Name];
    if override ~= nil then return override end
    local cast = (action.CastTime or 0) / 1000;
    return math.max(0.3, cast * (1 - gcinclude.settings.FastCast) - gcinclude.settings.CancelLead);
end

local function CopyImageBuff()
    for _, id in ipairs(gcinclude.BuffId.CopyImage) do
        if gData.GetBuffCount(id) >= 1 then return id end
    end
    return nil;
end

--[[
Phoenix rule (scripts/globals/spells/enhancing_ninjutsu.lua): a new Utsusemi lands if your current
shadows are the same tier or lower. So Ni always lands, Ichi over Ichi lands, and only
Ichi over Ni shadows fails. The buff icon only shows the shadow count, so we remember the
tier of the last Utsusemi you started. If we don't know (just loaded), Ichi cancels to be safe.
]]
function gcinclude.DoShadows(action)
    if not string.find(action.Name, 'Utsusemi') then return end
    local tier = string.match(action.Name, 'Utsusemi: (%a+)');
    if tier == 'Ichi' and gcinclude.settings.CancelShadows then
        local buff = CopyImageBuff();
        if buff ~= nil and gcinclude.LastUtsu ~= 'Ichi' then
            Cancel(buff, CancelDelay(action));
        end
    end
    gcinclude.LastUtsu = tier;
end

-- Spells (and NIN tools) that refuse to overwrite their own buff, and the buff to cancel.
local SelfCancels = {
    ['Sneak'] = { 'Sneak', 'CancelSneak', true }, ['Monomi: Ichi'] = { 'Sneak', 'CancelSneak', true },
    ['Invisible'] = { 'Invisible', 'CancelInvisible', true }, ['Tonko: Ichi'] = { 'Invisible', 'CancelInvisible', true },
    ['Tonko: Ni'] = { 'Invisible', 'CancelInvisible', true },
    ['Stoneskin'] = { 'Stoneskin', 'CancelStoneskin', false }, ['Blink'] = { 'Blink', 'CancelBlink', false },
};

-- Call in HandlePrecast / HandleAbility (DoPrecast and DoAbility already do).
function gcinclude.CheckCancels()
    local action = gData.GetAction();
    if action == nil or action.Name == nil then return end
    local target = gData.GetActionTarget();
    local onSelf = target == nil or target.Name == gData.GetPlayer().Name;

    if action.Name == 'Spectral Jig' then
        if gData.GetBuffCount(gcinclude.BuffId.Sneak) >= 1 then
            gFunc.CancelAction();
            Cancel(gcinclude.BuffId.Sneak);
            (function() AshitaCore:GetChatManager():QueueCommand(1, '/ja "Spectral Jig" <me>') end):once(1.5);
        end
        return;
    end

    gcinclude.DoShadows(action);

    local c = SelfCancels[action.Name];
    if c ~= nil and gcinclude.settings[c[2]] and (onSelf or not c[3]) then
        local id = gcinclude.BuffId[c[1]];
        if gData.GetBuffCount(id) >= 1 then Cancel(id, CancelDelay(action)) end
    end
end

--[[
Call in HandleItem (DoItem does). Silent Oil does nothing if Sneak is already up (Phoenix item script),
so Sneak is cancelled right before the oil goes off. Prism/Rainbow Powder replace Invisible
on their own. Items do not use gear duration bonuses, so there is no gear to swap.
]]
function gcinclude.CheckItem()
    local item = gData.GetAction();
    if item == nil or item.Name == nil then return end
    if item.Name == 'Silent Oil' and gcinclude.settings.CancelSneak then
        if gData.GetBuffCount(gcinclude.BuffId.Sneak) >= 1 then
            Cancel(gcinclude.BuffId.Sneak, math.max(0, (item.CastTime or 0) / 1000 - 0.5));
        end
    end
end

---------------------------------------------------------------------------
-- Elemental staves and obis
---------------------------------------------------------------------------
-- Equip the best owned staff for the element (and its grip, if owned). Only when settings.ElementalStaff is on;
-- LuAshitacast already skips Main if it is locked with /fight.
function gcinclude.EquipStaff(element)
    if not gcinclude.settings.ElementalStaff or element == nil then return false end
    local list = gcinclude.ElementalStaves[element];
    if list == nil then return false end
    local staff = gcinclude.FirstOwned(list);
    if staff ~= nil then
        gFunc.Equip('Main', staff);
        local grip = gcinclude.ElementalGrips[element];
        if grip ~= nil and gcinclude.HaveItem(grip) then gFunc.Equip('Sub', grip) end
        return true;
    end
    return false;
end

--[[
Equip the matching obi only when day/weather help more than they hurt:
matching day +1, opposing day -1, matching weather +1 (double +2), opposing weather -1 (double -2).
]]
function gcinclude.EquipObi(element)
    if not gcinclude.settings.ElementalObi or element == nil then return false end
    local obi = gcinclude.ElementalObis[element];
    if obi == nil or not gcinclude.HaveItem(obi) then return false end
    local env = gData.GetEnvironment();
    local weak = gcinclude.WeakTo[element];
    local weight = (env.Weather and string.find(env.Weather, 'x2')) and 2 or 1;
    local score = 0;
    if env.DayElement == element then score = score + 1 elseif env.DayElement == weak then score = score - 1 end
    if env.WeatherElement == element then score = score + weight elseif env.WeatherElement == weak then score = score - weight end
    if score > 0 then
        gFunc.Equip('Waist', obi);
        return true;
    end
    return false;
end

-- Staff + obi for a spell (or anything with an .Element field).
function gcinclude.EquipElemental(action, useObi)
    if action == nil then return end
    gcinclude.EquipStaff(action.Element);
    if useObi ~= false then gcinclude.EquipObi(action.Element) end
end

---------------------------------------------------------------------------
-- Generic job handlers
---------------------------------------------------------------------------
--[[
Every job file hands its LuAshitacast handlers to these. Sets are found by name and applied
general to specific; any set that doesn't exist (or is empty) is skipped. <Mode> is the current
MeleeSet value (TP/WS/abilities/ranged) or NukeSet value (spells), skipped when on Default/Power.

  Idle/TP:   Idle -> Idle_Pet (pet out) -> Tp_Default -> Tp_<Mode> -> TH (/th)    | Resting | Pet_Only_Tp -> Pet_Only_Tp_<Mode>
             -> profile.OnDefault -> Dt (/dt) -> Movement (while moving) -> Town/aketon -> ...
  Ability:   Enmity (Provoke etc.) -> set by type (Roll, QuickDraw, Ready, BP) -> <LastWord> -> <Family> -> <Exact>  (each + _<Mode>)
             e.g. Curing Waltz III -> Waltz, CuringWaltz, CuringWaltzIII; Super Jump -> Jump, SuperJump
  Precast:   Precast -> <Skill>_Precast (Cure_, Enhancing_, Song_ ...) -> <Family>_Precast (Stoneskin_Precast)
  Midcast:   profile.MidcastBase (e.g. SIR) -> <Skill> -> <Skill>_<Mode> -> Self_<Skill> (on yourself) -> Haste (Utsusemi/Blink/Aquaveil)
             -> <LastWord> -> <Family> -> <Exact> (+ _<Mode>) -> Self_<Family> -> staff/obi -> profile.OnMidcast -> TH
             Skill sets: Cure, Enhancing, Enfeebling, Nuke, Dark, Divine, Ninjutsu, Blue, Summon; songs use Song_Buff/Song_Debuff
             and Song_<Type> (Song_March, Song_Lullaby, Song_HordeLullaby). NIN nukes also use Nuke.
  WS:        Ws_Default -> Ws_<Mode> -> profile.OnWsBase -> Ws_<WsName> -> Ws_<WsName>_<Mode> -> profile.OnWeaponskill
             (WsName = name without spaces/punctuation, e.g. Ws_BladeJin; profile.WsAlias maps several WS to one set)
  Ranged:    Preshot | Midshot -> Midshot_<Mode> -> Barrage -> TH
  Pet moves: profile.OnPetAction(petAction) runs instead of idle/TP while your pet is using a move.

SetName() strips spaces and punctuation, Family() strips tiers (II, IV, : Ni), LastWord() is the last word of Family().
]]
gcinclude.SkillSets = {
    ['Healing Magic'] = 'Cure', ['Enhancing Magic'] = 'Enhancing', ['Enfeebling Magic'] = 'Enfeebling',
    ['Elemental Magic'] = 'Nuke', ['Dark Magic'] = 'Dark', ['Divine Magic'] = 'Divine', ['Singing'] = 'Song',
    ['Ninjutsu'] = 'Ninjutsu', ['Blue Magic'] = 'Blue', ['Summoning Magic'] = 'Summon',
};
gcinclude.StaffSkills = T{'Elemental Magic', 'Enfeebling Magic', 'Dark Magic', 'Healing Magic', 'Divine Magic'};
gcinclude.ObiSkills = T{'Elemental Magic', 'Dark Magic', 'Healing Magic', 'Divine Magic'};
gcinclude.OffensiveSkills = T{'Enfeebling Magic', 'Elemental Magic', 'Dark Magic', 'Divine Magic', 'Ninjutsu', 'Blue Magic'};
gcinclude.HasteFamilies = T{'Utsusemi', 'Blink', 'Aquaveil', 'Haste'};
gcinclude.DebuffSongs = T{'Lullaby', 'Elegy', 'Finale', 'Requiem', 'Threnody'};
gcinclude.EnmityAbilities = T{'Provoke', 'Animated Flourish'};
gcinclude.AbilityTypeSets = { ['Corsair Roll'] = 'Roll', ['Quick Draw'] = 'QuickDraw', ['Ready'] = 'Ready',
    ['Blood Pact: Rage'] = 'BP', ['Blood Pact: Ward'] = 'BP' };

function gcinclude.SetName(text)
    return (string.gsub(text or '', '[%s\'%-:%.]', ''));
end

function gcinclude.Family(name)
    local f = string.gsub(name or '', ' [IVX]+$', '');
    f = string.gsub(f, ': %a+$', '');
    return f;
end

function gcinclude.LastWord(name)
    return string.match(gcinclude.Family(name), '(%S+)$') or name;
end

-- Equip prefix..LastWord, prefix..Family, prefix..Exact (general to specific), each followed by _<mode>.
function gcinclude.EquipLayers(prefix, name, mode)
    local done = {};
    for _, n in ipairs({ gcinclude.LastWord(name), gcinclude.Family(name), name }) do
        local key = prefix .. gcinclude.SetName(n);
        if not done[key] then
            done[key] = true;
            gcinclude.EquipIfExists(key);
            if mode ~= nil then gcinclude.EquipIfExists(key .. '_' .. mode) end
        end
    end
end

local function EquipModed(name, mode)
    gcinclude.EquipIfExists(name);
    if mode ~= nil then gcinclude.EquipIfExists(name .. '_' .. mode) end
end

--[[
Call once at the top of profile.OnLoad. Options (all optional):
  MeleeModes = {'Default','Acc'}   cycle for TP/WS sets (/meleeset). false for none.
  MagicModes = {'Power','Macc'}    cycle for spell sets (/nukeset)
  WeaponLock = {'Main','Sub'}      adds /fight; AutoLock = true locks it (with TP weapons) when you engage
  ElementalStaff = true            swap elemental staves for elemental/enfeebling/dark/healing/divine
  Settings = { RefreshGearMPP = 50, ... }   overrides for gcinclude.settings
  MacroBook = 1, MacroSet = 1
A TH toggle (/th) is added automatically when the job has a non-empty TH set.
]]
function gcinclude.SetupJob(profile, opts)
    opts = opts or {};
    gcinclude.Profile = profile;
    gcinclude.Initialize();
    if opts.Settings then
        for k, v in pairs(opts.Settings) do gcinclude.settings[k] = v end
    end
    if opts.ElementalStaff ~= nil then gcinclude.settings.ElementalStaff = opts.ElementalStaff end
    if opts.MeleeModes ~= false then
        gcinclude.AddCycle('MeleeSet', opts.MeleeModes or {'Default', 'Acc'}, 'meleeset', 'Melee Set');
    end
    if opts.MagicModes then
        gcinclude.AddCycle('NukeSet', opts.MagicModes, 'nukeset', 'Magic Set');
    end
    if opts.WeaponLock then
        gcinclude.AddWeaponLock(opts.WeaponLock);
        profile.AutoLock = opts.AutoLock == true;
    end
    local th = gcinclude.GetSet('TH');
    if type(th) == 'table' and next(th) ~= nil then
        gcinclude.AddToggle('TH', false, 'th', 'Treasure Hunter');
    end
    gcinclude.SetManager = setmanager;
    setmanager:Init(profile.Sets);
    if opts.MacroBook then
        AshitaCore:GetChatManager():QueueCommand(1, '/macro book ' .. opts.MacroBook);
        AshitaCore:GetChatManager():QueueCommand(1, '/macro set ' .. (opts.MacroSet or 1));
    end
end

function gcinclude.DoDefault(profile)
    local player = gData.GetPlayer();
    local pet = gData.GetPet();
    setmanager:Recompute();

    if profile.OnPetAction ~= nil then
        local petAction = gData.GetPetAction();
        if petAction ~= nil then
            profile.OnPetAction(petAction);
            return;
        end
    end

    if player.Status == 'Engaged' and profile.AutoLock then
        gcinclude.SetWeaponLock(true, (profile.LockWeapons and profile.LockWeapons()) or gcinclude.GetSet('Tp_Default'));
    end

    local mode = gcinclude.Mode('MeleeSet');
    gcinclude.EquipIfExists('Idle');
    if pet ~= nil then gcinclude.EquipIfExists('Idle_Pet') end
    if player.Status == 'Engaged' then
        EquipModed('Tp_Default', nil);
        if mode ~= nil then gcinclude.EquipIfExists('Tp_' .. mode) end
        if gcdisplay.GetToggle('TH') then gcinclude.EquipIfExists('TH') end
    elseif pet ~= nil and pet.Status == 'Engaged' then
        EquipModed('Pet_Only_Tp', mode);
    elseif player.Status == 'Resting' then
        gcinclude.EquipIfExists('Resting');
    end
    if profile.OnDefault ~= nil then profile.OnDefault(player, pet, mode) end
    gcinclude.CheckDefault();
    -- profile.OnLast runs after DT / movement / town gear, for pieces that must win over everything (e.g. HP latents).
    if profile.OnLast ~= nil then profile.OnLast(player, pet, mode) end
end

function gcinclude.DoAbility(profile)
    local ability = gData.GetAction();
    if ability == nil or ability.Name == nil then return end
    local mode = gcinclude.Mode('MeleeSet');
    if profile.AbilityBase then gcinclude.EquipIfExists(profile.AbilityBase) end
    if gcinclude.EnmityAbilities:contains(ability.Name) then gcinclude.EquipIfExists('Enmity') end
    local byType = ability.Type and gcinclude.AbilityTypeSets[ability.Type];
    if byType then EquipModed(byType, mode) end
    local mapped = profile.AbilitySets and profile.AbilitySets[ability.Name];
    if mapped then
        EquipModed(mapped, mode);
    else
        gcinclude.EquipLayers('', ability.Name, mode);
    end
    if ability.Type == 'Quick Draw' then
        gcinclude.EquipObi(string.match(ability.Name, '^(%a+)'));
    elseif ability.Type == 'Corsair Roll' then
        gcinclude.DoCORmsg(ability.Name);
    end
    if profile.OnAbility ~= nil then profile.OnAbility(ability, mode) end
    gcinclude.CheckCancels();
end

function gcinclude.DoItem(profile)
    gcinclude.CheckItem();
    local item = gData.GetAction();
    if item ~= nil and item.Name ~= nil then gcinclude.EquipIfExists(gcinclude.SetName(item.Name)) end
    if profile ~= nil and profile.OnItem ~= nil then profile.OnItem(item) end
end

function gcinclude.DoPrecast(profile)
    local spell = gData.GetAction();
    gcinclude.CheckCancels();
    gcinclude.EquipIfExists('Precast');
    local sk = gcinclude.SkillSets[spell.Skill];
    if sk then gcinclude.EquipIfExists(sk .. '_Precast') end
    gcinclude.EquipIfExists(gcinclude.SetName(gcinclude.Family(spell.Name)) .. '_Precast');
    if profile.OnPrecast ~= nil then profile.OnPrecast(spell) end
end

function gcinclude.DoMidcast(profile)
    local spell = gData.GetAction();
    local target = gData.GetActionTarget();
    local onSelf = target ~= nil and target.Name == gData.GetPlayer().Name;
    local mode = gcinclude.Mode('NukeSet');
    local family = gcinclude.Family(spell.Name);
    local prefix = '';

    if profile.MidcastBase then gcinclude.EquipIfExists(profile.MidcastBase) end

    if spell.Skill == 'Singing' then
        local debuff = gcinclude.DebuffSongs:contains(gcinclude.LastWord(spell.Name));
        EquipModed(debuff and 'Song_Debuff' or 'Song_Buff', mode);
        prefix = 'Song_';
        if debuff then gcinclude.EquipStaff(spell.Element) end
    else
        local sk = gcinclude.SkillSets[spell.Skill];
        if sk then
            EquipModed(sk, mode);
            if onSelf then gcinclude.EquipIfExists('Self_' .. sk) end
        end
        if spell.Skill == 'Ninjutsu' and gcinclude.NinNukes:contains(spell.Name) then
            EquipModed('Nuke', mode);
            gcinclude.EquipObi(spell.Element);
        end
    end
    if gcinclude.HasteFamilies:contains(family) then gcinclude.EquipIfExists('Haste') end

    gcinclude.EquipLayers(prefix, spell.Name, mode);
    if onSelf then gcinclude.EquipIfExists('Self_' .. gcinclude.SetName(family)) end
    if gcinclude.StaffSkills:contains(spell.Skill) then gcinclude.EquipStaff(spell.Element) end
    if gcinclude.ObiSkills:contains(spell.Skill) then gcinclude.EquipObi(spell.Element) end

    if profile.OnMidcast ~= nil then profile.OnMidcast(spell, target, mode) end
    if gcdisplay.GetToggle('TH') and gcinclude.OffensiveSkills:contains(spell.Skill)
        and (profile.WantsTH == nil or profile.WantsTH(spell)) then
        gcinclude.EquipIfExists('TH');
    end
end

function gcinclude.DoWeaponskill(profile)
    if not gcinclude.CheckWsBailout() then
        gFunc.CancelAction();
        return;
    end
    local ws = gData.GetAction();
    local mode = gcinclude.Mode('MeleeSet');
    EquipModed('Ws_Default', nil);
    if mode ~= nil then gcinclude.EquipIfExists('Ws_' .. mode) end
    if profile.OnWsBase ~= nil then profile.OnWsBase(ws, mode) end
    local name = (profile.WsAlias and profile.WsAlias[ws.Name]) or gcinclude.SetName(ws.Name);
    -- profile.WsVariant(ws) can return a suffix (e.g. 'SA'); if Ws_<WsName>_<suffix> exists it is used instead of Ws_<WsName>.
    local variant = profile.WsVariant and profile.WsVariant(ws);
    if not (variant and gcinclude.EquipIfExists('Ws_' .. name .. '_' .. variant)) then
        EquipModed('Ws_' .. name, mode);
    end
    gcinclude.EquipObi(gcinclude.ElementalWS[ws.Name]);
    if profile.OnWeaponskill ~= nil then profile.OnWeaponskill(ws, mode) end
end

function gcinclude.DoPreshot(profile)
    gcinclude.EquipIfExists('Preshot');
    if profile.OnPreshot ~= nil then profile.OnPreshot() end
end

function gcinclude.DoMidshot(profile)
    local mode = gcinclude.Mode('MeleeSet');
    EquipModed('Midshot', mode);
    if gData.GetBuffCount('Barrage') > 0 then
        gcinclude.EquipIfExists('Midshot_Acc');
        gcinclude.EquipIfExists('Barrage');
    end
    local ammo = gData.GetEquipment().Ammo;
    if ammo ~= nil and ammo.Name == 'Bloody Bolt' then gcinclude.EquipIfExists('Bloody_Bolt') end
    if profile.OnMidshot ~= nil then profile.OnMidshot(mode) end
    if gcdisplay.GetToggle('TH') then gcinclude.EquipIfExists('TH') end
end

-- Wire every LuAshitacast handler of a profile to the generic ones. Jobs can still replace any of them afterwards.
function gcinclude.UseGenericHandlers(profile)
    profile.OnUnload = function() gcinclude.Unload() end;
    profile.HandleCommand = function(args)
        if gcinclude.HandleCommands(args) then return end
        if profile.OnCommand ~= nil then profile.OnCommand(args) end
    end;
    profile.HandleDefault = function() gcinclude.DoDefault(profile) end;
    profile.HandleAbility = function() gcinclude.DoAbility(profile) end;
    profile.HandleItem = function() gcinclude.DoItem(profile) end;
    profile.HandlePrecast = function() gcinclude.DoPrecast(profile) end;
    profile.HandleMidcast = function() gcinclude.DoMidcast(profile) end;
    profile.HandlePreshot = function() gcinclude.DoPreshot(profile) end;
    profile.HandleMidshot = function() gcinclude.DoMidshot(profile) end;
    profile.HandleWeaponskill = function() gcinclude.DoWeaponskill(profile) end;
end

---------------------------------------------------------------------------
-- Job helpers
---------------------------------------------------------------------------
function gcinclude.DoCORmsg(roll)
    if not gcinclude.CORmsg then return end
    for _, r in ipairs(gcinclude.Rolls) do
        if r[1] == roll then
            print(chat.header('GCinclude'):append('[' .. chat.warning(roll) .. ']  [Lucky: ' .. chat.success(r[2]) .. ']  [Unlucky: ' .. chat.error(r[3]) .. ']'));
        end
    end
end

-- /nuke 1-4 casts the tier of the element in the Element cycle (BLM/RDM/SCH).
function gcinclude.DoNukes(tier)
    local numerals = { ['1'] = '', ['2'] = ' II', ['3'] = ' III', ['4'] = ' IV' };
    local suffix = numerals[tostring(tier)];
    if suffix == nil then gcinclude.Message('Usage: /nuke 1-4') return end
    AshitaCore:GetChatManager():QueueCommand(1, '/ma "' .. gcdisplay.GetCycle('Element') .. suffix .. '" <t>');
end

-- /helix and /weather for SCH main, or BLM/SCH sub. Tier I only at 75.
function gcinclude.DoSCHspells(kind)
    local list = (kind == 'helix') and gcinclude.HelixSpells or gcinclude.StormSpells;
    local target = (kind == 'helix') and '<t>' or '<me>';
    local index = nil;
    for k, v in ipairs(gcinclude.Elements) do
        if v == gcdisplay.GetCycle('Element') then index = k end
    end
    if index and list[index] then
        AshitaCore:GetChatManager():QueueCommand(1, '/ma "' .. list[index] .. '" ' .. target);
    end
end

-- Adds /elecycle, /nuke #, /helix, /weather (for BLM, SCH, RDM).
function gcinclude.AddNukeCommands()
    gcinclude.AddCycle('Element', gcinclude.Elements, 'elecycle', 'Spell Element');
    gcinclude.AddCommand('nuke', function(args) gcinclude.DoNukes(args[2]) end);
    gcinclude.AddCommand('helix', function() gcinclude.DoSCHspells('helix') end);
    gcinclude.AddCommand('weather', function() gcinclude.DoSCHspells('weather') end);
end

function gcinclude.DoAspir()
    if AshitaCore:GetMemoryManager():GetRecast():GetSpellTimer(247) == 0 then
        AshitaCore:GetChatManager():QueueCommand(1, '/ma "Aspir" <t>');
    end
end

function gcinclude.DoDrain()
    local recast = AshitaCore:GetMemoryManager():GetRecast();
    if gData.GetPlayer().MainJob == 'DRK' and recast:GetSpellTimer(246) == 0 then
        AshitaCore:GetChatManager():QueueCommand(1, '/ma "Drain II" <t>');
    elseif recast:GetSpellTimer(245) == 0 then
        AshitaCore:GetChatManager():QueueCommand(1, '/ma "Drain" <t>');
    end
end

function gcinclude.CheckAbilityRecast(check)
    local recast = 0;
    for x = 0, 31 do
        local id = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimerId(x);
        local timer = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimer(x);
        if (id ~= 0 or x == 0) and timer > 0 then
            local ability = AshitaCore:GetResourceManager():GetAbilityByTimerId(id);
            if ability ~= nil and ability.Name[1] == check then recast = timer end
        end
    end
    return recast;
end

-- SMN: summon the day's spirit, Elemental Siphon, release, resummon your avatar.
function gcinclude.DoSiphon()
    if gcinclude.CheckAbilityRecast('Elemental Siphon') ~= 0 then
        print(chat.header('GCinclude'):append(chat.warning('Elemental Siphon not available yet!')));
        return;
    end
    local spirits = { ['Firesday'] = 'Fire Spirit', ['Earthsday'] = 'Earth Spirit', ['Watersday'] = 'Water Spirit', ['Windsday'] = 'Air Spirit',
        ['Iceday'] = 'Ice Spirit', ['Lightningday'] = 'Thunder Spirit', ['Lightsday'] = 'Light Spirit', ['Darksday'] = 'Dark Spirit' };
    local pet = gData.GetPet();
    local oldpet = pet and pet.Name or nil;
    local spirit = spirits[gData.GetEnvironment().Day];
    if spirit == nil then return end
    local q = function(cmd) return function() AshitaCore:GetChatManager():QueueCommand(1, cmd) end end;
    if oldpet ~= nil then q('/ja "Release" <me>'):once(1) end
    q('/ma "' .. spirit .. '" <me>'):once(3);
    q('/ja "Elemental Siphon" <me>'):once(7);
    q('/ja "Release" <me>'):once(9);
    if oldpet ~= nil then q('/ma "' .. oldpet .. '" <me>'):once(11) end
end

---------------------------------------------------------------------------
-- Load / unload
---------------------------------------------------------------------------
-- Old-style job files still call these.
gcinclude.SetCommands = function(args) return gcinclude.HandleCommands(args) end;
gcinclude.DoMoonshade = function() end;

function gcinclude.Initialize()
    SetupCommonCommands();
    gcdisplay.Initialize();
    SetAliases:once(2);
end

function gcinclude.Unload()
    ClearAliases();
    gcinclude.UnbindKeys();
    if gcinclude.LockSlots ~= nil and gcdisplay.GetToggle('Fight') then
        for _, slot in ipairs(gcinclude.LockSlots) do gFunc.Enable(slot) end
    end
    ashita.events.unregister('packet_in', 'gcinclude_zone_cb');
    gcdisplay.Unload();
end

return gcinclude;
