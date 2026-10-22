local chat = require('chat');

local inventoryItems = {};
local sets = {};
local lastComputedLevel = nil;
local inventoryLoaded = false;

local GetCharLevel = function()
    return AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
end

local LoadInventory = function()
    local inventoryManager = AshitaCore:GetMemoryManager():GetInventory();
    if (inventoryManager == nil) then
        return;
    end
    for _,container in ipairs(gSettings.EquipBags) do
        local available = gData.GetContainerAvailable(container);
        if (available == true) then
            local max = gData.GetContainerMax(container);
            for index = 1,max,1 do
                local containerItem = inventoryManager:GetContainerItem(container, index);
                if containerItem ~= nil and containerItem.Count > 0 and containerItem.Id ~= nil and containerItem.Id > 0 then
                    inventoryItems[containerItem.Id] = true
                end
            end
        end
    end
    inventoryLoaded = true;
end

local CheckItemEquippable = function(item, myLevel)
    if (item == nil or myLevel == nil) then
        return false;
    end
    return inventoryItems[item.Id] ~= nil and myLevel >= item.Level
end

local ReduceSet = function(set, myLevel)
    local newSet = {};
    for slotName,slotEntries in pairs(set) do
        if (gData.Constants.EquipSlots[slotName] ~= nil) then
            if type(slotEntries) == 'string' then
                newSet[slotName] = slotEntries;
            elseif type(slotEntries) == 'table' then
                if slotEntries[1] == nil then
                    newSet[slotName] = slotEntries;
                else
                    for _,potentialEntry in ipairs(slotEntries) do
                        local item = AshitaCore:GetResourceManager():GetItemByName(potentialEntry, 0);
                        if CheckItemEquippable(item, myLevel) then
                            newSet[slotName] = potentialEntry;
                            break;
                        end
                    end
                end
            end
        end
    end
    return newSet;
end

local RecomputePrioritySets = function(allSets, myLevel)
    local buffer = {};

    if (inventoryLoaded == false) then
        LoadInventory();
    end

    -- iterate the sets, removing missing items from them
    for name,set in pairs(allSets) do
        if (#name > 9) and (string.sub(name, -9) == '_Priority') then
            buffer[string.sub(name, 1, -10)] = ReduceSet(set, myLevel);
        end
    end
    for key,val in pairs(buffer) do
        allSets[key] = val;
    end
    lastComputedLevel = myLevel;
end

local CombinePrioritySets = function(base, override)
    return base;
end

ashita.events.register('packet_in', 'setmanager_inventoryload_check', function (e)
    if (e.id == 0x1D) and (struct.unpack('B', e.data, 0x04 + 1) == 1) then
        inventoryLoaded = false;
        RecomputePrioritySets(sets, lastComputedLevel);
        --print(chat.header('SetManager') .. chat.message('Inventory Loaded: Recomputed Sets.'));
    end
end);

local lib = {}

function lib:Init(profileSets)
    sets = profileSets;
    RecomputePrioritySets(sets, GetCharLevel());
    print(chat.header('SetManager') .. chat.message('Init (Level ' .. GetCharLevel() .. '): Recomputed Sets.'));
end

function lib:ReduceSet(set)
    return ReduceSet(set, GetCharLevel());
end

function lib:CombinePrioritySets(base, override)
    return CombinePrioritySets(base, override);
end

function lib:Recompute()
    local newLevel = GetCharLevel();
    if (newLevel == lastComputedLevel) then
        return;
    end
    RecomputePrioritySets(sets, newLevel);
    print(chat.header('SetManager') .. chat.message('New Level Detected (' .. newLevel .. '): Recomputed Sets.'));
end

return lib;