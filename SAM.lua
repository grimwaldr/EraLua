local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

--[[
SAM - Phoenix XI (75 cap). Set order and naming: "Generic job handlers" in common/gcinclude.lua.
Engaged: Tp_* -> Hasso (Hasso up) -> ThirdEye (Seigan + Third Eye) or Seigan (Seigan only).
WS: ... -> Ws_<WsName> -> MeikyoShisui (Meikyo up) -> Sekkanoki (Sekkanoki up).
Abilities use a set named after them (Meditate, ThirdEye, MeikyoShisui, WardingCircle...). Provoke uses Enmity.
Commands: /meleeset (Default/Hybrid/Acc) /dt /setcycle /wsdistance /gckeys /gcdisplay
]]

local sets = {
    Idle = {
        Ring1 = 'Defending Ring',
    },
    Resting = {},
    Idle_Regen = {
    },
    Idle_Refresh = {},
    Town = {
        Ring1 = 'Defending Ring',
    },

    Dt = {
        Ring1 = 'Defending Ring', --10
    },

    Tp_Default_Priority = {
--        Ammo = 'Tiphia sting',
        Head = 'Ace\'s Helm',
        Neck = 'Justice torque',
        Ear1 = 'Brutal Earring',
        Ear2 = 'Bushinomimi',
        Body = {'Haubergeon +1', 'Haubergeon'},
        Hands = {'Dusk gloves +1', 'Dusk gloves'},
        Ring1 = 'Rajas Ring',
        Ring2 = 'Toreador\'s ring',
        Back = {'Cerb. Mantle +1', 'Cerberus Mantle'},
        Waist = 'Sonic belt',
        Legs = 'Byakko\'s haidate',
        Feet = 'Usukane sune-ate',
    },
    Tp_Hybrid = {
    },
    Tp_Acc = {
    },

    Precast = {
        Ear2 = 'Loquac. Earring',
    },


    Cure = {
    },

    Enhancing = {
    },

    Preshot = {
    },
    Midshot_Priority = {
        Ring1 = {'Beetle Ring +1', 'Beetle Ring'},
        Ring2 = {'Beetle Ring +1', 'Beetle Ring'},
    },

    Ws_Default_Priority = {
        Head = 'Win. hachimaki',
        Neck = 'Spike Necklace',
        Ear1 = {'Beetle Earring +1', 'Beetle Earring'},
        Ear2 = {'Beetle Earring +1', 'Beetle Earring'},
        Ring1 = 'Courage Ring',
        Ring2 = 'Courage Ring',
        Waist = 'Brave belt',
        Legs = 'Republic Subligar',
        Feet = 'Leaping boots',
    },
    Ws_Hybrid = {
    },
    Ws_Acc = {
    },

    Ws_TachiJinpu = {
    },
    Ws_TachiJinpu_Hybrid = {
    },
    Ws_TachiJinpu_Acc = {},


    Ws_NamasArrow_Priority = {
        Ammo = 'Kabura arrow',
        Head = {'Wyvern Helm +1', 'Wyvern helm'},
        Neck = 'Light Gorget',
        Ear1 = 'Triumph Earring',
        Ear2 = 'Bushinomimi',
        Body = 'Kirin\'s Osode',
        Hands = 'Alkyoneus\'s Brc.',
        Ring1 = 'Rajas Ring',
        Ring2 = 'Flame Ring',
        Back = {'Amemet Mantle +1', 'Amemet Mantle'},
        Waist = 'Buccaneer\'s Belt',
        Legs = 'Hachiryu Haidate',
        Feet = {'Hmn. Sune-Ate +1', 'Hmn. Sune-ate'},
    },

    Hasso = {
    },
    ThirdEye = {
    },
    Seigan = {
    },
    Sekkanoki = {
    },
    Meditate = {
    },
    MeikyoShisui = {
    },
    Enmity = {
    },

    TH = {--/th will force this set to equip for 10 seconds
	},
    Movement = {
	},
};
profile.Sets = sets;

profile.Packer = {
    {Name = 'Red Curry Bun', Quantity = 'all'},
};

profile.KeyBinds = {
    {'=', '/lac fwd meleeset'},
    {'+=', '/lac fwd dt'},
    {'e', '/ws "Tachi: Enpi" <t>'},
    {'+e', '/ws "Tachi: Gekko" <t>'},
    {'^e', '/ws "Tachi: Kasha" <t>'},
    {'q', '/ja "Jump" <t>'},
    {'+q', '/ja "High Jump" <t>'},
    {'y', '/pcmd leave'},
    {'+y', '/tell Sundrix inv'},
    {'!y', '/tell Butsuon inv'},
    {'1', '/ja "Hasso" <me>'},
    {'2', '/ja "Berserk" <me>'},
    {'3', '/ja "Meditate" <me>'},
    {'4', '/ja "Third Eye" <me>'},
    {'5', '/ja "Seigan" <me>'},
    {'6', '/ja "Sekkanoki" <me>'},
};

profile.OnDefault = function(player)
    if player.Status ~= 'Engaged' then return end
    if gData.GetBuffCount('Hasso') > 0 then gcinclude.EquipIfExists('Hasso') end
    local seigan = gData.GetBuffCount('Seigan') > 0;
    if seigan and gData.GetBuffCount('Third Eye') > 0 then
        gcinclude.EquipIfExists('ThirdEye');
    elseif seigan then
        gcinclude.EquipIfExists('Seigan');
    end
end

profile.OnWeaponskill = function()
    if gData.GetBuffCount('Meikyo Shisui') > 0 then gcinclude.EquipIfExists('MeikyoShisui') end
    if gData.GetBuffCount('Sekkanoki') > 0 then gcinclude.EquipIfExists('Sekkanoki') end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, {
        MeleeModes = {'Default', 'Hybrid', 'Acc'},
        MacroBook = 1, MacroSet = 1,
    });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
