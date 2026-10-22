--[[
gcdisplay: the on-screen bar showing level/job, Attk/Def and every toggle and cycle.
Toggles show green when on, red when off. Cycles show their current value.
/gcdisplay hides or shows the bar.

Toggles and cycles are shown in the order they were created.
]]
local gcdisplay = {};

local fonts = require('fonts');

local Toggles = {};
local Cycles = {};
local Order = {};   -- { {kind='toggle'|'cycle', name=...}, ... } in creation order

local Def, Attk, MainLV, SubLV = 0, 0, 0, 0;
local Main, Sub = '', '';

local fontSettings = T{
    visible = true,
    font_family = 'Arial',
    font_height = 12,
    color = 0xFFFFFFFF,
    position_x = 300,
    position_y = 0,
    background = T{
        visible = true,
        color = 0xFF000000,
    }
};

local function remember(kind, name)
    for _, v in ipairs(Order) do
        if v.name == name and v.kind == kind then return end
    end
    table.insert(Order, { kind = kind, name = name });
end

-- Toggles -----------------------------------------------------------------

function gcdisplay.CreateToggle(name, default)
    Toggles[name] = (default == true);
    remember('toggle', name);
end

function gcdisplay.HasToggle(name)
    return type(Toggles[name]) == 'boolean';
end

function gcdisplay.GetToggle(name)
    return Toggles[name] == true;
end

function gcdisplay.SetToggle(name, value)
    if type(Toggles[name]) ~= 'boolean' then return false end
    Toggles[name] = (value == true);
    return true;
end

function gcdisplay.AdvanceToggle(name)
    if type(Toggles[name]) ~= 'boolean' then return false end
    Toggles[name] = not Toggles[name];
    return true;
end

-- Cycles ------------------------------------------------------------------

function gcdisplay.CreateCycle(name, values)
    Cycles[name] = { Index = 1, Array = values };
    remember('cycle', name);
end

function gcdisplay.HasCycle(name)
    return type(Cycles[name]) == 'table';
end

function gcdisplay.GetCycle(name)
    local c = Cycles[name];
    if type(c) ~= 'table' then return 'Unknown' end
    return c.Array[c.Index];
end

function gcdisplay.FirstValue(name)
    local c = Cycles[name];
    if type(c) ~= 'table' then return nil end
    return c.Array[1];
end

function gcdisplay.AdvanceCycle(name)
    local c = Cycles[name];
    if type(c) ~= 'table' then return false end
    c.Index = c.Index + 1;
    if c.Index > #c.Array then c.Index = 1 end
    return true;
end

-- Set a cycle straight to a value (case-insensitive). Returns true if found.
function gcdisplay.SetCycle(name, value)
    local c = Cycles[name];
    if type(c) ~= 'table' or value == nil then return false end
    for k, v in ipairs(c.Array) do
        if string.lower(v) == string.lower(value) then
            c.Index = k;
            return true;
        end
    end
    return false;
end

-- Find a cycle by name ignoring case (for /setcycle).
function gcdisplay.FindCycle(name)
    for k, _ in pairs(Cycles) do
        if string.lower(k) == string.lower(name) then return k end
    end
    return nil;
end

-- Display -----------------------------------------------------------------

function gcdisplay.Update()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    Def = player:GetDefense();
    Attk = player:GetAttack();
    MainLV = player:GetMainJobLevel();
    SubLV = player:GetSubJobLevel();
    Main = AshitaCore:GetResourceManager():GetString('jobs.names_abbr', player:GetMainJob()) or '';
    Sub = AshitaCore:GetResourceManager():GetString('jobs.names_abbr', player:GetSubJob()) or '';
end

function gcdisplay.Initialize()
    gcdisplay.Update();
    if gcdisplay.FontObject == nil then
        gcdisplay.FontObject = fonts.new(fontSettings);
    end
    ashita.events.register('d3d_present', 'gcdisplay_present_cb', function ()
        local display = MainLV .. Main .. '/' .. SubLV .. Sub .. '   Attk:' .. Attk .. '   Def:' .. Def;
        for _, entry in ipairs(Order) do
            if entry.kind == 'toggle' and Toggles[entry.name] ~= nil then
                local color = Toggles[entry.name] and '|cFF00FF00|' or '|cFFFF0000|';
                display = display .. '   ' .. color .. entry.name .. '|r';
            elseif entry.kind == 'cycle' and Cycles[entry.name] ~= nil then
                local c = Cycles[entry.name];
                display = display .. '   ' .. entry.name .. ': |cFF00FF00|' .. tostring(c.Array[c.Index]) .. '|r';
            end
        end
        gcdisplay.FontObject.text = display;
    end);
    ashita.events.register('command', 'gcdisplay_cb', function (e)
        local args = e.command:args();
        if #args == 0 or args[1] ~= '/gcdisplay' then return end
        e.blocked = true;
        if gcdisplay.FontObject ~= nil then
            gcdisplay.FontObject.visible = not gcdisplay.FontObject.visible;
        end
    end);
end

function gcdisplay.Unload()
    if gcdisplay.FontObject ~= nil then
        gcdisplay.FontObject:destroy();
        gcdisplay.FontObject = nil;
    end
    ashita.events.unregister('d3d_present', 'gcdisplay_present_cb');
    ashita.events.unregister('command', 'gcdisplay_cb');
end

return gcdisplay;
