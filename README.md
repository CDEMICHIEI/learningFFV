# Learning: A Final Fantasy V LUA script.
 Named after the Blue Mage passive skill, the Learning script allows you to see and learn the underlying information of Final Fantasy V.

For example: The [Excalipur](https://finalfantasy.fandom.com/wiki/Excalipoor_(weapon)) has a listed attack of `100`, but does almost no damage when equiped in battle. That's because the Damage Formula for it's weapon is `0x28: Fixed Damage, Ignores Defense` and the Parameters for that Formula are set to force 1 damage. Most of the game's weapons have special Damage Formulas that range from elemental damage, extra damage to certain creature types, and even casting spells instead of a simple attack!

Learning currently exposes information in the following screens:
 ## Battle  
  * Push `L` or `R` in battle to page through visible information.
  * Player HP/MP, status effects, boosts, and elemental vulnerabilites, & more  
  * Monster LVL, HP/MP, ATB meter, steals/drops, creature type, elemental vulnerabilties, status vulnerabilites, & more

## Job
  * Current char Job levels
  * Job level rewards
  * Stat changes per Job
  * Job passives
  
## Item
  * Formula and use descripton of almost all non-key items
  * Quick info for equipment
  
## Equip
 * Stat comparisons to current equpment
 * Stat boosts
 * Weapon and Armor category
 * Status effects given and immunity for Armor
 * Elemental vulnerabilites for Armor
 * Damage Formulas and Parameters for Weapons
 * Mag Evade calculation
 
 ## Status
  * HP/MP
  * Current Stats
  * EXP and EXP to next level
  * ATB meter & Equipment weight
  * Currently active passives
  * Captured Monster and spell cast when released
  
  # Future
  Soon I plan to add support to the other menu screens and expose more information there.
  
  ## Ability
   * Stat changes for each equipped ability
   
  ## Magic
   * Magic damage formulas similar to Equip screen
   
  ## World
   * Expand information and clean up placeholder information
   * Encounter warnings
   
  
