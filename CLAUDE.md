# EraLua

LuAshitacast gear-swap profiles for Grimwald on Phoenix XI (private server, 75 level cap,
ToAU era, plus the WotG content Phoenix is working toward). Repo: github.com/grimwaldr/EraLua.
In game it lives at config/addons/luashitacast/Grimwald_141/ (LuAshitacast loads
<CharName>_<ServerId>). After an edit, test in game with /lac reload.

21 job files (WAR MNK THF PLD DRK SAM DRG NIN NINDRK DNC BST PUP WHM BLM RDM SCH SMN BLU RNG
COR BRD), settings.lua, and common/ (gcinclude.lua, gcdisplay.lua, setmanager.lua).
README.md documents the layout, set order and era rules.

## Workflow

- This folder is the repo root. Commit and push every change to origin/main.
- The repo is the source of truth. Only profile code and docs belong in it: no changelogs,
  gear lists, exported XML or other scratch files.
- settings.lua is written by LuAshitacast with CRLF line endings; core.autocrlf=input
  normalizes it on commit.

## Hard rules

1. 75 era is the priority. Anything from Abyssea / level 76+ onward is out (gear, weapon
   skills, abilities, spells, status effects). WotG is in. GEO and RUN are out of era and
   have no profiles.
2. Check mechanics against the Phoenix repo, not wikis: github.com/phoenixffxi/Phoenix,
   especially modules/era and modules/phoenix, which override retail behaviour. Useful files:
   - sql/item_equipment.sql + modules/phoenix/sql/pxi_item_equipment.sql (item level and
     job masks; the pxi file overrides jobs)
   - sql/item_mods.sql (stats; mod ids in the modifier list, e.g. 365 snapshot, 359 rapid shot)
   - sql/item_latents.sql
   - sql/weapon_skills.sql (skill level, unlock tier)
   - sql/abilities.sql (ability levels)
   - sql/spell_list.sql (spell elements)
3. Weapon skill era rule: quest WS, relic WS and the mythic WS are era (Leaden Salute,
   Trueflight, Atonement, Expiacion, Mordant Rime etc. stay). Empyrean / Abyssea and later,
   or anything needing skill above the 75 cap, is out.
4. Use the SHORT in-game item name. LuAshitacast does not match long names
   ("Bugard Strap +1", not "Bugard Leather Strap +1"; "Brd. Roundlet +1").
5. No em dashes in code comments, docs or replies.
6. READMEs: no pitch intro. How it works first, justifications at the bottom.
7. The public repo doesn't name or credit other players in comments or docs. The
   /tell <name> inv keybinds are working binds and stay.

## How the code works

Each job file:

```lua
local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');
local sets = { ... };  profile.Sets = sets;
profile.Packer = {...};  profile.KeyBinds = {...};
-- optional hooks: OnDefault, OnLast, OnAbility, OnMidcast, OnWsBase,
--   WsVariant, WsAlias, OnPreshot, OnCommand, LockWeapons, OnPetAction
profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, { MeleeModes=..., MagicModes=..., WeaponLock=...,
        AutoLock=..., ElementalStaff=..., Settings=..., MacroBook=..., MacroSet=... });
    gcinclude.BindKeys(profile.KeyBinds);
end
gcinclude.UseGenericHandlers(profile);
return profile;
```

RDM and BLM call UseGenericHandlers first and then override HandleDefault, HandleAbility
and HandleMidcast with their own logic. Keep that order or the overrides get clobbered.

Sets are looked up by name, and a missing or empty set is skipped. Layering (later
overwrites earlier):

- Idle/TP: Idle -> Idle_Pet -> Tp_Default -> Tp_<Mode> -> TH -> OnDefault -> Idle_Regen / Dt
  (AutoGear) -> Dt (/dt) -> Movement while moving (Movement_Night at night) -> Town / aketon
  -> OnLast
- Ability: Enmity -> type (Roll, QuickDraw, Ready, BP) -> last word -> family -> exact name,
  each + _<Mode>
- Precast: Precast -> <Skill>_Precast -> <Spell>_Precast
- Midcast: <Skill> -> _<Mode> -> Self_<Skill> -> Haste -> last word -> family -> exact ->
  Self_<Spell> -> staff/grip/obi -> OnMidcast -> TH
- WS: Ws_Default -> Ws_<Mode> -> OnWsBase -> Ws_<Name> (or WsVariant) -> Ws_<Name>_<Mode> ->
  elemental WS obi -> OnWeaponskill
- Ranged: Preshot / Midshot -> Midshot_<Mode> -> Barrage -> TH

<Mode> is the /meleeset or /nukeset value and is skipped on the first value. Set names drop
spaces and punctuation (Ws_BladeJin).

_Priority sets: a list per slot, and setmanager uses the first item owned at the current
level. HQ armor falls back to NQ (+2 -> +1 -> NQ). Relic weapons do NOT fall back through
earlier stages. BRD instruments: Gjallarhorn, then the song's own instrument as +2, then +1,
never NQ.

## Keybinds (every job)

- n / Shift+n: Utsusemi: Ni / Ichi
- x / Shift+x: Sneak / Invisible if WHM, RDM or SCH is main or sub (sub >= 20); else Monomi /
  Tonko on NIN or /NIN; else Silent Oil / Prism Powder
- = row: that job's toggles (/meleeset, /dt ...)

Key prefixes: + shift, ^ ctrl, ! alt, @ win. A bind can take a condition function (WAR and
DRK /SAM binds on 6-9 only while subbing SAM). Binds refresh on subjob change. /gckeys lists
them. Ranged: COR /ra <t> is Shift+4. RNG /ra <t> is q.

## Decisions already made (don't undo without asking)

- No kite toggle. Movement gear goes on whenever moving, engaged or not.
- Utsusemi: Ni never cancels shadows; Ichi cancels only when the last cast was Ni (Phoenix:
  a cast only lands over the same or lower tier).
- Sneak/Invis/Monomi/Tonko/Stoneskin/Blink self-cancel just before landing. Silent Oil
  cancels Sneak first (it fails if Sneak is up). Skulker's Cape is the only era gear with
  sneak/invis duration; items ignore gear.
- No Holy Water / Doom set (only gear that helps is level 96).
- No Hasso set on WAR/DRK (era Hasso has no gear at 75), just /SAM binds.
- Leaden Salute stays on COR (mythic, era).
- THF is a separate, well-structured profile kept close to its original layout (modes
  Default/Acc/dDEX/Farm/Dynamis, SA/TA/SATA layered sets). Respect its structure.
- BRD: idle is an MDT-leaning defensive set (BRDs fear magic more than physical). Dt = Idle
  without Main/Sub/Range/Ammo. Deliberate pieces kept: Merman's Bangles, Rostrum Pumps
  (Galka HP trick), Hexerei Cape. Minstrel's Ring latent: HP <= 75% and TP < 100. Minstrel's
  Earring latent: HP <= 25% and TP < 100 (OnLast hook). /swords locks Blau Dolch + Joyeuse
  on engage.
- Song elements: Lullaby and Finale Light, Elegy Earth, each Threnody carries the counter
  element (Ice Threnody is Fire), so staff selection follows that.
- Flurry is a 2014 addition and was removed (no Preshot_FlurryI/II). Double Shot (79) and
  Triple Shot (87) hooks were removed.
- RNG and COR Preshot sets are commented out, with a note that most players didn't bother
  with preshot in era. Era pieces are listed in the comment: RNG Htr. Beret +1 / Sct. Jerkin
  +1 (Rapid Shot +5), COR Zhago's Barbut (Snapshot +3) and Comm. Gants +1 (Snapshot +5).
- PLD, DRK, SCH, SMN, BLU, MNK, DNC and PUP were mostly retail gear before; many of their
  sets are empty now, waiting for era gear. That's expected.

## Checking gear

Every gear entry was audited against Phoenix's SQL: level <= 75, wearable by the job (with
the pxi job-mask overrides applied), and a real Phoenix item by short name. The last full
audit was clean across all 21 files. For any new gear: grep the item's short name in
item_equipment.sql, confirm level and job bit (job bit order WAR MNK WHM BLM RDM THF PLD DRK
BST BRD RNG SAM NIN DRG SMN BLU COR PUP DNC SCH = bits 0..19), then check
pxi_item_equipment.sql for a job override.

## Open ideas (not started)

- Add a tools/ folder with a gear audit script against a Phoenix clone.
- Possibly move COR's /ra off Shift+4 to match RNG (q). Undecided.
