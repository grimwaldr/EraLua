# EraLua

LuAshitacast profiles for Phoenix XI's 75 cap (ToAU era, plus the WotG content Phoenix is working toward). All 20 era jobs, plus a NIN/DRK variant, running on one shared common library.

## Install

Clone into your character's LuAshitacast folder (`<CharName>_<ServerId>`):

```
cd Ashita/config/addons/luashitacast
git clone https://github.com/grimwaldr/EraLua <CharName>_<ServerId>
```

Then `/lac load` in game. `git pull` gets updates, and `/lac reload` picks them up.

## Layout

- `common/gcinclude.lua`: shared settings, sets, commands, keybinds, buff cancels, elemental staves and obis, and the handlers every job uses.
- `common/gcdisplay.lua`: the on-screen bar showing every toggle and cycle.
- `common/setmanager.lua`: resolves `_Priority` sets.
- `<JOB>.lua`: that job's sets, keybinds and a few hooks for job-specific logic.
- `settings.lua`: LuAshitacast's own settings (bags, delays).

## How sets are applied

Sets are looked up by name. A missing or empty set is skipped, so a job file only has to define the sets it uses. `<Mode>` is the current `/meleeset` value (TP, WS, abilities, ranged) or `/nukeset` value (spells), and is skipped while you're on the first value.

| Action | Order (later overwrites earlier) |
| --- | --- |
| Idle / TP | `Idle` -> `Idle_Pet` -> `Tp_Default` -> `Tp_<Mode>` -> `TH` -> job hook -> `Idle_Regen` / `Dt` (AutoGear) -> `Dt` (/dt) -> `Movement` while moving (`Movement_Night` at night) -> `Town` / aketon -> final job hook |
| Ability | `Enmity` (Provoke, Animated Flourish) -> by type (`Roll`, `QuickDraw`, `Ready`, `BP`) -> last word -> family -> exact name, each + `_<Mode>` |
| Precast | `Precast` -> `<Skill>_Precast` -> `<Spell>_Precast` |
| Midcast | `<Skill>` -> `<Skill>_<Mode>` -> `Self_<Skill>` -> `Haste` (Utsusemi, Blink, Aquaveil) -> last word -> family -> exact -> `Self_<Spell>` -> staff / obi -> job hook -> `TH` |
| WS | `Ws_Default` -> `Ws_<Mode>` -> job hook -> `Ws_<WsName>` -> `Ws_<WsName>_<Mode>` |
| Ranged | `Preshot` / `Midshot` -> `Midshot_<Mode>` -> `Barrage` -> `TH` |

Skill set names: `Cure`, `Enhancing`, `Enfeebling`, `Nuke`, `Dark`, `Divine`, `Ninjutsu`, `Blue`, `Summon`. Songs use `Song_Buff` / `Song_Debuff`, then `Song_<Type>`.

Name rules: the "last word" of Super Jump is `Jump` and of Curing Waltz III is `Waltz`. "Family" drops tiers (`Cure IV` -> `Cure`, `Utsusemi: Ni` -> `Utsusemi`). Set names drop spaces and punctuation (`Ws_BladeJin`).

## Fallback gear

Any set ending in `_Priority` takes a list per slot, and the first item you own at your current level is used. HQ armor falls back to NQ (`+2` -> `+1` -> NQ), so a set works before you've finished upgrading it, and under level sync. BRD instruments go Gjallarhorn, then the song's own instrument as +2, then +1. The set is still used under its plain name (`Idle`, `Tp_Default`). After picking up new gear, `/lac reload` so the lists are re-checked.

## Keybinds

Every job has a `profile.KeyBinds` table of `{ key, command }` pairs (`+` shift, `^` ctrl, `!` alt, `@` win). A bind can take a condition, such as only while subbing SAM. Binds refresh when your subjob changes, and `/gckeys` lists everything bound.

These are the same on every job:

- `n` / `Shift+n`: Utsusemi: Ni / Ichi.
- `x` / `Shift+x`: Sneak / Invisible when WHM, RDM or SCH is main or sub, otherwise Monomi / Tonko on NIN or /NIN, otherwise Silent Oil / Prism Powder.
- `=` row: that job's toggles (`/meleeset`, `/dt` and so on).

## Buff cancelling

- Utsusemi: Ni never cancels shadows. Ichi only cancels them when they came from Ni.
- Sneak, Monomi, Invisible, Tonko, Stoneskin and Blink cancel their own buff just before the new cast lands. Cancel timing is the spell's cast time minus a lead, and jobs can override it per spell.
- Silent Oil cancels Sneak first. Spectral Jig cancels Sneak and then uses itself again.

## Common commands

`/dt` `/meleeset` `/nukeset` `/setcycle <cycle> <value>` `/wsdistance` `/gcmessages` `/gckeys` `/gcdisplay` `/craftset` `/fishset` `/helmset` `/rrset`

Holding a fishing rod in the Range slot equips the Fishing set automatically (rod and bait stay on). `/fishset` and `/helmset` force those sets on; each slot uses the HQ piece first, then NQ.

Job commands are listed in the comment at the top of each job file.

## Adding a job

```lua
local profile = {};
gcinclude = gFunc.LoadFile('common\\gcinclude.lua');

local sets = { Idle = {}, Tp_Default = {}, Ws_Default = {} };
profile.Sets = sets;
profile.Packer = {};
profile.KeyBinds = { {'=', '/lac fwd meleeset'} };

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    gcinclude.SetupJob(profile, { MeleeModes = {'Default', 'Acc'} });
    gcinclude.BindKeys(profile.KeyBinds);
end

gcinclude.UseGenericHandlers(profile);
return profile;
```

Job-specific logic goes in hooks (`OnDefault`, `OnLast`, `OnAbility`, `OnMidcast`, `OnWsBase`, `OnCommand`, ...) rather than rewritten handlers.

## How the era rules were decided

Everything was checked against the [Phoenix server repo](https://github.com/phoenixffxi/Phoenix), including its `modules/`, rather than wikis, since Phoenix changes a lot of retail behaviour back to how it was in era.

- **Gear:** every entry was audited against `sql/item_equipment.sql` and `modules/phoenix/sql/pxi_item_equipment.sql`. Anything above level 75, unwearable by the job on Phoenix, or not a Phoenix item was removed. Long item names were changed to the short names LuAshitacast matches (`Bugard Strap +1`, not `Bugard Leather Strap +1`).
- **Weapon skills:** `sql/weapon_skills.sql`. Quest, relic and mythic WS are era (Leaden Salute, Trueflight, Atonement, Expiacion stay). Empyrean and later, or anything needing skill above the 75 cap, is out.
- **Abilities:** `sql/abilities.sql`. Anything above level 75 is out (Double Shot, Triple Shot, Blood Rage, Impetus...).
- **Flurry:** added in 2014, so there are no Flurry preshot sets.
- **Preshot:** only Snapshot and Rapid Shot matter when `/ra` starts, and few pieces at 75 have either. Most players skipped a preshot set in era, so the RNG and COR ones are commented out with the era pieces listed.
- **Utsusemi:** a cast only lands over shadows of the same or lower tier (`scripts/globals/spells/enhancing_ninjutsu.lua`), so only Ichi over Ni needs a cancel. Cancelling before Ni could leave you with no shadows if Ni was interrupted.
- **Sneak / Invisible:** random 30-300s base duration plus gear bonuses (`modules/phoenix/lua/globals/spells/enhancing_spell.lua`). Skulker's Cape is the only gear with the bonus, and items ignore gear entirely, so there is no swap for oils and powders. Silent Oil does nothing while Sneak is up (`modules/era/lua/items/pot_of_silent_oil.lua`), hence the cancel.
- **Hasso:** the Zanshin bonus is removed in era (`modules/era/lua/globals/job_utils/samurai.lua`) and no gear at 75 enhances it, so WAR and DRK get /SAM binds but no Hasso set.
- **Song elements:** `sql/spell_list.sql`. Lullaby and Finale are Light, Elegy is Earth, and each Threnody carries its counter element (Ice Threnody is Fire), so the elemental staff lookup picks the right staff for each song.
- **Minstrel's Ring / Earring:** `sql/item_latents.sql`. The ring needs 75% HP or less and under 100 TP when the song starts; the earring needs 25% HP or less and under 100 TP.
- **Holy Water:** 33% Doom removal (`scripts/items/flask_of_holy_water.lua`). The only gear that improves it is level 96, so there is no Holy Water set.
- **GEO and RUN** are out of era and have no profiles.

### Why one shared library

Most job files used to be copies of the same handlers with small differences, so a bug fixed in one stayed broken in the others. With shared handlers a fix lands everywhere, and each job file only holds what makes that job different.
