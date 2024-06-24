# Learning: A Final Fantasy V LUA script.

Named after the Blue Mage passive skill, the Learning script allows you to see and learn the underlying information of Final Fantasy V. Like most Final Fantasy games, FFV has myriad information that is hidden form the player and must be intuited or researched from external sources. For a casual playthrough, this is just fine. However, why leave to look up this info when it exists straight from the game itself!

For example: The [Excalipur](<https://finalfantasy.fandom.com/wiki/Excalipoor_(weapon)>) has a listed attack of `100`, but does almost no damage in battle. That's because the Damage Formula for its weapon is `0x28: Fixed Damage, Ignores Defense` and the Parameters for that Formula are set to force 1 damage. Most of the game's weapons have special Damage Formulas that range from elemental damage, extra damage to certain creature types, and even casting spells instead of a simple attack!

Learning currently exposes information in the following screens:

## Battle

- Push `L` or `R` in battle to page through visible information for players and monsters.
- Player HP/MP, status effects, boosts, and elemental vulnerabilities, & more
- Monster LVL, HP/MP, ATB meter, steals/drops, creature type, elemental vulnerabilities, status vulnerabilities, & more

## Job

- Current character's Job levels
- Rewards for each Job level
- Stat changes per Job
- Jobs' passives

## Item

- Formula and use description of almost all non-key items
- Quick info for equipment

## Equip

- Stat comparisons to current equipment
- Stat boosts
- Weapon and Armor category
- Status effects given and immunity for Armor
- Elemental vulnerabilities for Armor
- Damage Formulas and Parameters for Weapons
- Mag Evade calculation

## Status

- HP/MP
- Current Stats
- Current EXP and EXP to next level
- ATB meter & Equipment weight
- Currently active Job passives
- Captured Monster and the spell it casts when released

# Future

Soon I plan to add support to the other menu screens and expose more information there.

## Ability

- Stat changes for each equipped ability

## Magic

- Magic damage formulas similar to Equip screen

## World

- Expand information and clean up placeholder information
- Encounter warnings
