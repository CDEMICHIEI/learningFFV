-- -------------------------- 	--
-- Learning 					--
-- Final Fantasy V LUA script 	--
--                            	--
-- By Christopher DeMichiei  	--
-- -------------------------- 	--
-- original by samurai goroh
-- edits by Christopher August 2012-2014

-- ------- --
-- GLOBALS --
-- ------- --

wwidth  = 256   -- window width
wheight = 224   -- window height
offsetX = 0     -- To move things in coord X
offsetY = 0     -- To move things in coord Y
gapX    = 7     -- Text gap in coord X
gapY    = 7     -- Text gap in coord Y

battlePage = 0	-- 'page' battle info
battlePageMax = 4
enemyPage = 0	-- 'page' battle info
enemyPageMax = 4
mapPage = 0
mapPageMax = 2

RDown	= false -- RDOWN
LDown	= false
SelDown	= false
Flippy	= false -- Flip Enemy pos on back attack

-- colors, just because
cRed 	  = 0xC41F3BFF
cOrange	= 0xFF7D0AFF
cGreen	= 0xABD473FF
cLBlue	= 0x69CCF0FF
cLGreen	= 0x00FF96FF
cDGreen = 0x008833FF
cPink	  = 0xF58CBAFF
cYellow	= 0xFFF569FF
cBlue	= 0x0070DEFF
cPurple	= 0x9482C9FF
cTan	= 0xC79C6EFF
cBrown	= 0x906C38FF

readByte = memory.readbyte
readWord = memory.readword
readDWord = memory.readdword

DisplayBattleInfo = false
oldBattles = readByte(0x7E09C0)
oldEscapes = readByte(0x7E09B5)
oldEnemyReady = 0

-- ------ --
-- Tables --
-- ------ --
-- MenuScreens
TableMenuScreens = {
	'0   ',
	'1  Menu',
	'2  Ability',
	'3  Job',
	'4  Equip',
	'5  Status',
	'6  Shop',
	'7  Item',
	'8  Magic',
	'9  Config',
	'10 Dropped Items',
	'11 Save Game',
	'12 Load Game',
	'13 Name',
	'14 ??'
}
TableMenuScreens[86] = 'Game Start'

-- Statuses (Full Names)
TableStatusCurable = {
	'Dark',
	'Zombie',
	'Poison',
	'Float',
	'Mini',
	'Toad',
	'Petrify',
	'Dead'
}

TableStatusTemporary = {
	'Image (x1)',
	'Image (x2)',
	'Mute',
	'Berserk',
	'Charm',
	'Paralyze',
	'Sleep',
	'Aging'
}

TableStatusDispellable = {
	'Regen',
	'Invul',
	'Slow',
	'Haste',
	'Stop',
	'Shell',
	'Protect',
	'Reflect'
}

TableStatusPermanent = {
	'Hidden',
	'Near Death',
	'Singing',
	'Hp Leak',
	'Countdown',
	'Controlled',
	'False Image',
	'Erased'
}

-- Statuses (Abbr)
TableStatusC = {
	'Drk',
	'Zom',
	'Poi',
	'Flo',
	'Mini',
	'Toad',
	'Ston',
	'Dead'
}
-- Temp Status (Abbr)
TableStatusT 	= {
	'Im1',
	'Im2',
	'Mute',
	'Ber',
	'Charm',
	'Par',
	'Sleep',
	'Age'
}
-- Dispel Status (Abbr)
TableStatusD 	= {
	'Reg',
	'Inv',
	'Slo',
	'Has',
	'Stop',
	'Shl',
	'Pro',
	'Ref'
}
-- Permanant Status (Abbr)
TableStatusP 	= {
	'Hide',
	'Crit',
	'Sing',
	'Slip',
	'Count',
	'Controlled',
	'False Image',
	'Erased'
}

-- Elements
TableElement = {
	 'Fire', 	-- 1
	 'Ice',		-- 2
	 'Lit', 	-- 4
	 'Pois',	-- 8
	 'Holy',	-- 16
	 'Earth',	-- 32
	 'Wind',	-- 64
	 'Water'	-- 128
 }
-- Attack Types
TableAttackType = {
	'Blue',
	'White',
	'Black',
	'Dimen',
	'Summon',
	'Song',
	'Aerial',
	'Physical'
}
-- Creature Types
TableCreature = {
	'Undead',
	'Archaetoad',
	'Creature',
	'Avis',
	'Dragon',
	'Heavy',
	'Desert',
	'Human'
}
-- Attack Formula
TableAttackFormula = {
	'No effect',
	'Monster Attack',
	'Monster Specialty',
	'Magic SW -Type 1',
	'Magic SW -Type 2',
	'Magic SW -Type 3',
	'Offensive Magic',
	'Fractional HP based damage',
	'Pierce Magic defense',
	'Random Damage',
	'Physical magic',
	'Level based damage (+ Status?)',
	'HP leak',
	'HP drain',
	'MP drain',
	'HP to critical',
	'Restore HP (Magic)',
	'Restore full HP (Magic)',
	'Status 0 infliction',
	'Status 1 infliction',
	'Status 2 infliction',
	'Toggle Status',
	'Speed Status(Exclusive)',
	'Instant death',
	'Instant destroy',
	'Status removal',
	'Resurrection(fractional)',
	'Whispering Wind',
	'Element attribute change',
	'View stats',
	'Drag',
	'Void',
	'End battle',
	'Reset battle',
	'Double commands',
	'Earth Wall',
	'Restore HP (Item)',
	'Restore MP (Item)',
	'Restore HP / MP',
	'Inflict status, ignore immunity',
	'Fixed damage, ignore defense',
	'Countdown destroy',
	'Max HP based damage + HP leak',
	'Current user HP based damage',
	'Random effect',
	'Ground attacks',
	"Reaper's Sword",
	'?',
	'Unarmed',
	'Swords',
	'Knives',
	'Spears',
	'Axes , Staves',
	'Bows (Status effect)',
	'Bows (Elemental)',
	'Katanas',
	'Whips',
	'Bells',
	'Long reach axes',
	'Rods',
	'Rune weapons',
	'Reduce HP to critical + Status',
	'Reduce HP to critical or HP Leak',
	'Zombie Breath',
	'Change Row',
	'?',
	'HP and status restored',
	'!Steal (command)',
	'Escape (enemy)',
	'!Throw (command)',
	'!GilToss (command)',
	'!Tame (command)',
	'!Catch (command)',
	'Flirt',
	'!Dance(Command)',
	'Lv5 Doom',
	'Lv2 Old',
	'Lv4 Quarter',
	'Lv3 Flare',
	'Revive + Status',
	'Goblin Punch',
	'Level/Defense modifier',
	'HP Leak + Status',
	'Current MP damage',
	'Max - Current HP damage',
	'Kill Caster, Heal Raget',
	'?',
	'HP Leak + Status',
	'Flare damage + HP Leak + Status',
	'HP boost',
	'Heal HP based on current suser HP',
	'?',
	'Full Heal + Status',
	'Zombie magic',
	'Increase stats while Singing',
	'Damage creature type while Singing',
	'Unhide Monster',
	'Stalker Attack',
	'Unhide Next Page',
	'Grand Cross',
	'Chicken Knife',
	'Interceptor Rocket',
	'Targeting',
	'Pull',
	'Terminate',
	'!Control (command)',
	"? (Sandworm's Death)",
	'Status Immunity, Magic Element UP, Creature Type',
	'Strong vs. Creature type',
	'Drain HP based on current HP',
	'Brave Blade',
	'Strong Fight',
	'Wormhole',
	'Level Down',
	'Bows strong vs. Creature type',
	'Spears Strong vs. Creature type',
	'Unhide Monster',
	'Terminate',
	'?',
	'?',
	'?',
	'?',
	'?',
	'?',
	'?',
	'?',
	'Innefective',
	'No Action'
}

-- Magic Spells
TableMagicID = {
	-- SwordBlade
	"00 Sw|Fire",
	"01 Sw|Ice",
	"02 Sw|Bolt ",
	"03 Sw|Venom",
	"04 Sw|Mute ",
	"05 Sw|Sleep",
	"06 Sw|Fire2",
	"07 Sw|Ice 2",
	"08 Sw|Bolt2",
	"09 Sw|Drain",
	"0A Sw|Break",
	"0B Sw|Bio  ",
	"0C Sw|Fire3",
	"0D Sw|Ice 3",
	"0E Sw|Bolt3",
	"0F Sw|Holy ",
	"10 Sw|Flare",
	"11 Sw|Psych",
	-- White
	"12 Wh|Cure ",
	"13 Wh|Scan ",
	"14 Wh|Antdt",
	"15 Wh|Mute ",
	"16 Wh|Armor",
	"17 Wh|Size ",
	"18 Wh|Cure2",
	"19 Wh|Life ",
	"1A Wh|Charm",
	"1B Wh|Image",
	"1C Wh|Shell",
	"1D Wh|Heal ",
	"1E Wh|Cure3",
	"1F Wh|Wall ",
	"20 Wh|Bersk",
	"21 Wh|Life2",
	"22 Wh|Holy ",
	"23 Wh|Dispel",
	-- Black
	"24 Bk|Fire   ",
	"25 Bk|Ice    ",
	"26 Bk|Bolt   ",
	"27 Bk|Venom  ",
	"28 Bk|Sleep  ",
	"29 Bk|Toad   ",
	"2A Bk|Fire2  ",
	"2B Bk|Ice 2  ",
	"2C Bk|Bolt2  ",
	"2D Bk|Drain  ",
	"2E Bk|Break  ",
	"2F Bk|Bio    ",
	"30 Bk|Fire3  ",
	"31 Bk|Ice 3  ",
	"32 Bk|Bolt3  ",
	"33 Bk|Flare  ",
	"34 Bk|Doom   ",
	"35 BK|Psych  ",
	-- Dimension (Time)
	"36 Tm|Drag    ",
	"37 Tm|Slow    ",
	"38 Tm|Regen   ",
	"39 Tm|Void    ",
	"3A Tm|Haste   ",
	"3B Tm|Float   ",
	"3C Tm|Demi    ",
	"3D Tm|Stop    ",
	"3E Tm|Exit    ",
	"3F Tm|Comet   ",
	"40 Tm|Slow2   ",
	"41 Tm|Reset   ",
	"42 Tm|Qrter   ",
	"43 Tm|Hast2   ",
	"44 Tm|Old     ",
	"45 Tm|Meteo   ",
	"46 Tm|Quick   ",
	"47 Tm|Xzone   ",
	-- Summon (Spell that calls summon)
	"48 Su|Chocob ",
	"49 Su|Sylph  ",
	"4A Su|Remora ",
	"4B Su|Shiva  ",
	"4C Su|Ramuh  ",
	"4D Su|Ifrit  ",
	"4E Su|Titan  ",
	"4F Su|Golem  ",
	"50 Su|Shoat  ",
	"51 Su|Crbnkl ",
	"52 Su|Syldra ",
	"53 Su|Odin   ",
	"54 Su|Phenix ",
	"55 Su|Levia  ",
	"56 Su|Bahmut ",
	-- Songs
	"57 Sg|Power   ",
	"58 Sg|Speed   ",
	"59 Sg|Vitality",
	"5A Sg|Magic   ",
	"5B Sg|Hero    ",
	"5C Sg|Requiem ",
	"5D Sg|Love    ",
	"5E Sg|Charm   ",
	-- Summons' Action (Spell that the summon casts)
	"5F SA|Chocobo Kick              ",
	"60 SA|Whispering Wind           ",
	"61 SA|Latch On                  ",
	"62 SA|Diamond Dust              ",
	"63 SA|Bolt of Judgement         ",
	"64 SA|Hellfire                  ",
	"65 SA|Rage of the Earth         ",
	"66 SA|Earth Wall                ",
	"67 SA|Demon's Eye               ",
	"68 SA|Ruby Light                ",
	"69 SA|Thunder Storm             ",
	"6A SA|True Edge                 ",
	"6B SA|Fire of Resurection (Fire)",
	"6C SA|Big Wave                  ",
	"6D SA|Mega Flare                ",
	"6E SA|Fat Chocobo               ",
	"6F SA|Gungnir                   ",
	"70 SA|Fire of Resurection (Life)",
	-- Special Item Attacks
	"71 Dragon SW -Hp Drain            ",
	"72 Dragon SW -Mp Drain            ",
	"73 Egg Chop                           ",
	"74 Harp - Silver Harp (Item Magic 5)  ",
	"75 Harp - Dream Harp (Item Magic 6)   ",
	"76 Harp - Lamia's Harp (Item Magic 7) ",
	"77 Harp - Apollo's Harp (Item Magic 8)",
	"78 Item - Fail? (Item Magic 9)        ",
	-- Dance
	"79 Dance - Mystery Waltz              ",
	"7A Dance - Jitterbug Duet             ",
	"7B Dance - Tempting Tango             ",
	-- Command (I don't know what this is)
	"7C Command - Magic Barrier            ",
	"7D Command - Sword Dance              ",
	"7E Command - Ice Aura?                ",
	"7F Command - Entangle (Whip Magic)    ",
	-- Monster Actions
	"80 Monster Attack",
	"81 Monster Specialty",
	-- Blue
	"82 Bu|Condemn",
	"83 Bu|Roulette",
	"84 Bu|AquaRake",
	"85 Bu|L5 Doom",
	"86 Bu|L4 Qrter",
	"87 Bu|L2 Old",
	"88 Bu|L3 Flare",
	"89 Bu|FrogSong",
	"8A Bu|TinySong",
	"8B Bu|Flash",
	"8C Bu|Time Slip",
	"8D Bu|MoonFlut",
	"8E Bu|DethClaw",
	"8F Bu|Aero",
	"90 Bu|Aero 2",
	"91 Bu|Aero 3",
	"92 Bu|Emission",
	"93 Bu|GblinPnch",
	"94 Bu|DrkShock",
	"95 Bu|GuardOff",
	"96 Bu|Fusion",
	"97 Bu|MindBlst",
	"98 Bu|Vampire",
	"99 Bu|Hammer",
	"9A Bu|MgthyGrd",
	"9B Bu|Exploder",
	"9C Bu|????",
	"9D Bu|Blowfish",
	"9E Bu|WhiteWind",
	"9F Bu|Missile",
	-- Monster "Magic"
	"A0 EM|Kurururu",
	"A1 EM|Level Down",
	"A2 EM|Escape",
	"A3 EM|Stalker Attack",
	"A4 EM|Byblos Attack",
	"A5 EM|No Clue",
	"A6 EM|Grand Cross",
	"A7 EM|Delta Attack",
	"A8 EM|Interceptor Rocket",
	"A9 EM|Barrier Change",
	"AA EM|Nothing",
	"AB EM|Wind Slash",
	"AC EM|No-Damage Magic",
	"AD EM|Targeting",
	"AE EM|Gravity 100",
	"AF EM|Darkness",
	"B0 EM|Reaper's Sword",
	"B1 EM|Punishment",
	"B2 EM|Blaster",
	"B3 EM|Beak",
	"B4 EM|Hug",
	"B5 EM|Spore",
	"B6 EM|Poison Breath",
	"B7 EM|Dance of the Dead",
	"B8 EM|Zombie Powder",
	"B9 EM|Zombie Breath",
	"BA EM|Spirit",
	"BB EM|Allure",
	"BC EM|Entangle",
	"BD EM|Rainbow Wind",
	"BE EM|Strange Dance",
	"BF EM|Electromagn Field",
	"C0 EM|White Hole",
	"C1 EM|Needle",
	"C2 EM|Maelstrom",
	"C3 EM|Bone",
	"C4 EM|Tailscrew",
	"C5 EM|Stomach Acid",
	"C6 EM|Rocket Punch",
	"C7 EM|Mustard Bomb",
	"C8 EM|Almagest",
	"C9 EM|Quicksand",
	"CA EM|Atomic Ray",
	"CB EM|Mini Blaze",
	"CC EM|Snowstorm",
	"CD EM|Blaze",
	"CE EM|Electric Shock",
	"CF EM|Earth Shaker",
	"D0 EM|True Edge",
	"D1 EM|Tidal Wave",
	"D2 EM|Mega Flare",
	"D3 EM|Sonic Wave",
	"D4 EM|Thread",
	"D5 EM|Mucus",
	"D6 EM|Quake",
	"D7 EM|Strong Fight",
	"D8 EM|Medicine",
	"D9 EM|Image",
	"DA EM|Breath Wing",
	"DB EM|Flame",
	"DC EM|Thunder",
	"DD EM|Surge Beam",
	"DE EM|Fight",
	"DF EM|Remedy",
	"E0 EM|Valiant Attack",
	"E1 EM|Giga Flare",
	"E2 EM|Circle",
	"E3 EM|Wormhole",
	"E4 EM|Possess",
	"E5 EM|Dynamo",
	"E6 EM|Magnet",
	"E7 EM|Reverse Polarity",
	"E8 EM|Jump",
	"E9 EM|X-Zone",
	"EA EM|Hurricane",
	"EB EM|Demon's Eye",
	"EC EM|Pull",
	"ED EM|(6A) Invincibility? ((Sandworm) does it when he dies)",
	"EE EM|Unhide Monster",
	"EF EM|Terminate",
}

-- Abilities/Commands
TableAbilityID = {
	'00 Nothing',
	'01 Other',
	'02 Item',
	'03 Row',
	'04 Def.',
	'05 Fight',
	'06 Guard',
	'07 Kick',
	'08 BuildUp',
	'09 Mantra',
	'0A Escape',
	'0B Steal',
	'0C Capture',
	'0D Jump',
	'0E DrgnSwd',
	'0F Smoke',
	'10 Image',
	'11 Throw',
	'12 SwdSlap',
	'13 GilToss',
	'14 Slash',
	'15 Animals',
	'16 Aim',
	'17 X-Fight',
	'18 Conjure',
	'19 Observe',
	'1A Analyze',
	'1B Tame',
	'1C Control',
	'1D Catch',
	'1E Release',
	'1F Combine',
	'20 Drink',
	'21 Pray',
	'22 Revive',
	'23 Terrain',
	'24 (Nothing)',
	'25 Hide',
	'26 Show',
	'27 (MgcSwrd ?)',
	'28 Sing',
	'29 Flirt',
	'2A Dance',
	'2B Mimic',
	'2C MgcSwrd (Lv1)',
	'2D MgcSwrd (Lv2)',
	'2E MgcSwrd (Lv3)',
	'2F MgcSwrd (Lv4)',
	'30 MgcSwrd (Lv5)',
	'31 MgcSwrd (Lv6)',
	'32 White (Lv1)',
	'33 White (Lv2)',
	'34 White (Lv3)',
	'35 White (Lv4)',
	'36 White (Lv5)',
	'37 White (Lv6)',
	'38 Black (Lv1)',
	'39 Black (Lv2)',
	'3A Black (Lv3)',
	'3B Black (Lv4)',
	'3C Black (Lv5)',
	'3D Black (Lv6)',
	'3E Dimen (Lv1)',
	'3F Dimen (Lv2)',
	'40 Dimen (Lv3)',
	'41 Dimen (Lv4)',
	'42 Dimen (Lv5)',
	'43 Dimen (Lv6)',
	'44 Summon (Lv1)',
	'45 Summon (Lv2)',
	'46 Summon (Lv3)',
	'47 Summon (Lv4)',
	'48 Summon (Lv5)',
	'49 Red (Lv1)',
	'4A Red (Lv2)',
	'4B Red (Lv3)',
	'4C X-Magic',
	'4D Blue',
	'4E (Double damage)',
	'4F (Jump hit)',
	'50 (Jump miss)',
	'51 (Throbbing)',
	'52 (Jump)',
	'53 (AirBlade effect)',
	'54 (show final stats)',
	'55 (dual attack)',
	'56 (Earthquake effect)',
	'57 (Nothing)',
	'58 (Nothing)',
	'59 (Steal)',
	'5A (Row)',
	'5B (Nightingale)',
	'5C (battle stance)',
	'5D (Mysidian Rabbit)',
	'5E (Buildup)',
	'5F (Nothing)',
	'60 (Nothing)',
	'61 (Nothing)',
	'62 (Nothing)',
	'63 (Nothing)',
	'64 (Nothing)',
	'65 (Nothing)',
	'66 (Nothing)',
	'67 (Nothing)',
	'68 (Nothing)',
	'69 (Nothing)',
	'6A (Nothing)',
	'6B (Nothing)',
	'6C (Nothing)',
	'6D (Nothing)',
	'6E (Nothing)',
	'6F (Nothing)',
	'70 (Nothing)',
	'71 (Nothing)',
	'72 (Nothing)',
	'73 (Nothing)',
	'74 (Nothing)',
	'75 (Nothing)',
	'76 (Nothing)',
	'77 (Nothing)',
	'78 (Nothing)',
	'79 (Nothing)',
	'7A (Nothing)',
	'7B (Nothing)',
	'7C (Nothing)',
	'7D (Nothing)',
	'7E (Nothing)',
	'7F (Nothing)',
}

-- Passive/Support abilites
TableSupportID = {
	'80 Equip Shields',
	'81 Equip Armor',
	'82 Equip Ribbons',
	'83 Equip Swords',
	'84 Equip Spears',
	'85 Equip Katanas',
	'86 Equip Axes',
	'87 Equip Bows',
	'88 Equip Whips',
	'89 Equip Harps',
	'8A Agility Up',
	'8B HP Up 10%',
	'8C HP Up 20%',
	'8D HP Up 30%',
	'8E MP Up 10%',
	'8F MP Up 30%',
	'90 Brawl',
	'91 Double Grip',
	'92 2-Handed Grip',
	'93 Medicine',
	'94 Cover',
	'95 Counter',
	'96 Evade',
	'97 Learning',
	'98 Barrier',
	'99 Berserk',
	'9A Caution',
	'9B Alert',
	'9C See Passages',
	'9D Damage Floor',
	'9E See Pitfalls',
	'9F Equip Rods',
	'A0 Dash',
}
TableJobLevel = {
	' ',
	' Other',
	'!Item',
	' Row',
	' Def.',
	'!Fight',
	'!Guard',
	'!Kick',
	'!BuildUp',
	'!Mantra',
	'!Escape',
	'!Steal',
	'!Capture',
	'!Jump',
	'!DrgnSwd',
	'!Smoke',
	'!Image',
	'!Throw',
	'!SwdSlap',
	'!GilToss',
	'!Slash',
	'!Animals',
	'!Aim',
	'!X-Fight',
	'!Conjure',
	'!Observe',
	'!Analyze',
	'!Tame',
	'!Control',
	'!Catch',
	'!Release',
	'!Combine',
	'!Drink',
	'!Pray',
	'!Revive',
	'!Terrain',
	'(Nothing)',
	'!Hide',
	'!Show',
	'(MgcSwrd ?)',
	'!Sing',
	'!Flirt',
	'!Dance',
	'!Mimic',
	'!MgcSwrd (Lv1)',
	'!MgcSwrd (Lv2)',
	'!MgcSwrd (Lv3)',
	'!MgcSwrd (Lv4)',
	'!MgcSwrd (Lv5)',
	'!MgcSwrd (Lv6)',
	'!White (Lv1)',
	'!White (Lv2)',
	'!White (Lv3)',
	'!White (Lv4)',
	'!White (Lv5)',
	'!White (Lv6)',
	'!Black (Lv1)',
	'!Black (Lv2)',
	'!Black (Lv3)',
	'!Black (Lv4)',
	'!Black (Lv5)',
	'!Black (Lv6)',
	'!Dimen (Lv1)',
	'!Dimen (Lv2)',
	'!Dimen (Lv3)',
	'!Dimen (Lv4)',
	'!Dimen (Lv5)',
	'!Dimen (Lv6)',
	'!Summon (Lv1)',
	'!Summon (Lv2)',
	'!Summon (Lv3)',
	'!Summon (Lv4)',
	'!Summon (Lv5)',
	'!Red (Lv1)',
	'!Red (Lv2)',
	'!Red (Lv3)',
	'!X-Magic',
	'!Blue',
	'(Double damage)',
	'(Jump hit)',
	'(Jump miss)',
	'(Throbbing)',
	'(Jump)',
	'(AirBlade effect)',
	'(show final stats)',
	'(dual attack)',
	'(Earthquake effect)',
	'(Nothing)',
	'(Nothing)',
	'(Steal)',
	'(Row)',
	'(Nightingale)',
	'(battle stance)',
	'(Mysidian Rabbit)',
	'(Buildup)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	'(Nothing)',
	' Equip Shields',
	' Equip Armor',
	' Equip Ribbons',
	' Equip Swords',
	' Equip Spears',
	' Equip Katanas',
	' Equip Axes',
	' Equip Bows',
	' Equip Whips',
	' Equip Harps',
	' Agility Up',
	' HP Up 10%',
	' HP Up 20%',
	' HP Up 30%',
	' MP Up 10%',
	' MP Up 30%',
	' Brawl',
	' Double Grip',
	' 2-Handed Grip',
	' Medicine',
	' Cover',
	' Counter',
	' Evade',
	' Learning',
	' Barrier',
	' Berserk',
	' Caution',
	' Alert',
	' See Passages',
	' Damage Floor',
	' See Pitfalls',
	' Equip Rods',
	' Dash',
}
-- Passive Job Properties
TablePassive1 = {
	'Passages',
	'Pitfalls',
	'DmgFloors',
	'Dash',
	'Learning',
	'Barrier',
	'Evade',
	'Counter',
}
TablePassive2 = {
	'2-Handed',
					'Preempt',
					'Caution',
					'Berserk',
					'Medicine+',
					'Double-Grip',
					'Brawl',
					'Cover',
}

TableTargeting = { 	'',
					'',
					'Roulette',
					'Target:Enemy',
					'Target-Selectable',
					'Side-Selectable',
					'All Targets',
					'Multi-target optional'
}
-- All Equipment types
TableEquipmentType = {	'Nothing',
						'Common',
						'Knife',
						'Ninja Sword',
						'Sword',
						'Knight Sword',
						'Spear',
						'Axe',
						'Hammer',
						'Katana',
						'Rod',
						'Staff',
						'Flail',
						'Bow',
						'Harp',
						'Whip',
						'Bell',
						'Shield',
						'Heavy Helmet',
						'Light Helmet',
						'Mage Hat',
						'Dancer Gear',
						'Heavy Armor',
						'Light Armor',
						'Mage Robe',
						'Glove',
						'Ring',
						'Accessory',
						'Thief Gear',
						'Chemist Gear',
						'Exotic Weapon'
}
-- Quick Dbl Grip table (easier than sorting the bits)
TableDoubleGrip =	{	'2-Hand OK',
						'2-Hand Only',
						'2-Hand Only',
						''
						}
-- Equipment Stat Bonus
TableStatBonus = {	'Mag',
					'Vit',
					'Agi',
					'Str'
					}
-- Equipment Stat Bonus Value
TableStatValue = { 	{'+1','  '},
					{'+2','  '},
					{'+3','  '},
					{'+1','-1'},
					{'  ','-1'},
					{'+5','-5'},
					{'+0','-5'},
					{'+5','  '}
					}

-- Weapon Special Properties
TableWeaponProperty ={	'Wonder Rod',
						'Ability Attack',
						'Magic Sword OK',
						'Action on Hit',
						'',
						'First Strike',
						'Knife Parry',
						'Sword Parry'
						}
-- Armor Special Properties
TableArmorProperty = { 'Catch +',
						'Undead',
						'Dance +',
						'MP Half',
						'Steal +',
						'Brawl +',
						'Physical Dodge',
						'Magical Block'
						}
-- Armor Equip Slots
TableEquipSlot = {	'Accessory',
					'Body',
					'Head',
					'Shield'
					}
-- Characters
TableCharacter = { 'Bartz',
				   'Lenna',
				   'Galuf',
				   'Faris',
				   'Krile',
				   '',
				   '',
				   ''
				 }
-- Jobs
TableJob = { 'Knight',
			 'Monk',
			 'Thief',
			 'Dragoon',
			 'Ninja',
			 'Samurai',
			 'Berserker',
			 'Ranger',
			 'Mystic Knight',
			 'White Mage',
			 'Black Mage',
			 'Time Mage',
			 'Summoner',
			 'Blue Mage',
			 'Red Mage',
			 'Beastmaster',
			 'Chemist',
			 'Geomancer',
			 'Bard',
			 'Dancer',
			 'Mimic',
			 'Freelancer'
		   }
-- Battle Backgrounds/Arena
TableBattleground = { 'Grasslands',
					  'Forest',
					  'Desert',
					  'Swamp',
					  'Beach',
					  'Indoor Ghost Ship',
					  'Cave',
					  'Waterfall Cave',
					  'Castle',
					  'Outdoor Castle',
					  'Castle 2',
					  'Castle 3',
					  'Outdoor Castle 2',
					  'Library',
					  'Indoor Ship',
					  'Forest 2',
					  'Plain 2',
					  'Castle 4',
					  'Pier',
					  'Tree Root',
					  'Castle 5',
					  'Outdoor Ship',
					  'Steel Floor',
					  'Crystal Floor',
					  'Indoor Ruins',
					  'Outdoor Ghost Ship',
					  'Castle in Fire',
					  'Wall',
					  'Void',
					  'Underwater Castle',
					  'Desert 2',
					  'Distorted Space',
					  'Outdoor Castle 3',
					  'Wet Plains'
					}

-- Enemy Names
TableEnemy = { 'Goblin',
			   'Killer Bee',
			   'Nut Eater',
			   'Stray Cat',
			   'Steel Bat',
			   'Dearo',
			   'Stroper',
			   'Black Goblin',
			   'White Snake',
			   'Mold Wind',
			   'ManiWizard',
			   'Magic Pot',
			   'Sucker',
			   'Octoraken',
			   'Gatlings',
			   'Bighorn',
			   'Tatu',
			   'Bander S.',
			   'Galura',
			   'Skeleton',
			   'Carcurser',
			   'UndeadRusk',
			   'PsychoHead',
			   'RockGarter',
			   'Gala Cat',
			   'Cockatrice',
			   'Blocks',
			   'Elf Toad',
			   'IceSoldier',
			   'RikaldMage',
			   'Wyvern',
			   'Padosule',
			   'Byblos',
			   'Aegil',
			   'Zuu',
			   'Wild Nack',
			   'GrassTurtle',
			   'Silent Bee',
			   'Mithril Drgn',
			   'Ramuh',
			   'Crew Dust',
			   'Poltergeist',
			   'Motor Trap',
			   'Defeater',
			   'Garkimasra',
			   'Sergeant',
			   'Sorcerer',
			   'Karnak',
			   'Gigas',
			   'Page 32',
			   'Page 64',
			   'Page 128',
			   'Page 256',
			   'Ifrit',
			   'Bomb',
			   'TwinLizard',
			   'BioSoldier',
			   'Crescent',
			   'BlackFlame',
			   'StoneGolem',
			   'MiniDragon',
			   'Prototype',
			   'D.Chimera',
			   'Sand Porky',
			   'Sand Killer',
			   'Sand Bear',
			   'Ra Mage',
			   'LonkaKnght',
			   'StonedMask',
			   'Whirl Demon',
			   'Lamia',
			   'ArchaeToad',
			   'Hyudora',
			   'Hydra',
			   'Water Buzz',
			   'Torrent',
			   'Rock Brain',
			   'Tarantula',
			   'Jail Bear',
			   'Lunenta',
			   'Dilure',
			   'Faery Orc',
			   'Devourer',
			   'Mandrake',
			   'Kuzar',
			   'Cactus',
			   'Sand Crawl',
			   'ShieldDrgn',
			   'Blood Slime',
			   'Acrophese',
			   'MooglEater',
			   'Lopros',
			   'Skull Eater',
			   'Aquathone',
			   'Weresnake',
			   'Conago',
			   'Ridicule',
			   'Andagranda',
			   'Drippy',
			   'Likaon',
			   'BoneDragon',
			   'Sting Eagle',
			   'ZombieDrgn',
			   'Golem',
			   'Neon',
			   'Magnetes',
			   'Wall Knight',
			   'Traveler',
			   'Tricker',
			   'Gravido',
			   'Ziggurat',
			   'Cure Beast',
			   'Land Turtle',
			   'Bold Mani',
			   'Shoat',
			   'MiniMage',
			   'GajraGajri',
			   'Mammon',
			   'Imp',
			   'Wyrm',
			   'Twin Lizard',
			   'Blind Wolf',
			   'Arage',
			   'Wall Mage',
			   'Magic Drgn',
			   'DarkWizard',
			   'AdamaGolem',
			   'BalderKuar',
			   'Motodrive',
			   'BlueDragon',
			   'Red Dragon',
			   'Yellow Drgn',
			   'Sleepy',
			   'Treeman',
			   'Hedgehog',
			   'Python',
			   'Shadow',
			   'Elm Gigas',
			   'Pao',
			   'Radiator',
			   'Metamorpha',
			   'Unknown',
			   'Desertpede',
			   'Barette',
			   'Sekmet',
			   'BlandLamia',
			   'Pyra Layer',
			   'Nile',
			   'Archaesaur',
			   'ZephyrZone',
			   'ExdethSoul',
			   'Slug',
			   'GloomWidow',
			   'Mukare',
			   'Ixecrator',
			   'Owazoral',
			   'ShdwDancer',
			   'Cursed one',
			   'Slownin',
			   'TinyMage',
			   'Dim Master',
			   'Bone Dragon',
			   'Flare',
			   'DuelKnight',
			   'Ion',
			   'Berserker',
			   'Zombie Dragon',
			   'Druid',
			   'Iron Dress',
			   'Statue',
			   'Blizzard',
			   'Isteritos',
			   'Spizner',
			   'Unknown',
			   'Unknown',
			   'Unknown',
			   'Unknown',
			   'Mercury Bat',
			   'Coral',
			   'Tonberi',
			   'Gel Water',
			   'Fall Guard',
			   'Alcumia',
			   'Red Dragon (Alcumia)',
			   'Hydra (Alcumia)',
			   'BoneDragon (Alcumia)',
			   'Grenade',
			   'Sword Dancer',
			   'Bardandels',
			   'Doom Dealer',
			   'Anku Heggu',
			   'Ammona',
			   'Land Crawl',
			   'Chamcubia',
			   'Bella Donna',
			   'Cherie',
			   'White Flame',
			   'MossFungus',
			   'Orcat',
			   'Iron Gigas',
			   'Death Claw',
			   'K.Behemoth',
			   'Fanfarerro',
			   'Necromancr',
			   'Ninja',
			   'Great Drgn',
			   'AvisDragon',
			   'Gorchimera',
			   'LevelCheck',
			   'Mind Mage',
			   'Fury',
			   'Thing',
			   'Mover',
			   'CrysDragon',
			   'Achelone',
			   'Bodyguard',
			   'Gilgamesh (Void)',
			   'Sahagin',
			   'Th.Anemone',
			   'Sea Avis',
			   'Corvette',
			   'Armon',
			   'SeaScorpio',
			   'Silvune',
			   'Gel Fish',
			   'Giant Bird',
			   'Sea Devil',
			   'Stingray',
			   '???? (Golem)',
			   'Golem',
			   'Chimera',
			   'Shiva (Metamorpha)',
			   'Ifrit (Metamorpha)',
			   'Ramuh (Metamorpha)',
			   'Gala Cat (Metamorpha)',
			   'Wyvern (Metamorpha)',
			   'Elf Toad (Metamorpha)',
			   'Crew Dust (Metamorpha)',
			   'Whirl Demon (Metamorpha)',
			   'ZombieDrgn (Metamorpha)',
			   'D.Chimera (Zephyr Zone)',
			   'AdamaGolem (Zephyr Zone)',
			   'Ziggurat (Zephyr Zone)',
			   'LonkaKnght (Zephyr Zone)',
			   'BioSoldier (Zephyr Zone)',
			   'Lunenta (Zephyr Zone)',
			   'Tote Avis',
			   'Belfegor',
			   'Imp (Exdeath Castle)',
			   'Owazoral (Exdeath Castle)',
			   'Garkimasra (Exdeath Castle)',
			   'Gabbledegak',
			   'Gil Turtle',
			   'Omega',
			   'Big Boss',
			   'None',
			   'WingRaptor (1st Form)',
			   'WingRaptor (2nd Form)',
			   'Karlaboss',
			   'Twin Tania (2nd form)',
			   'Siren (1st Form)',
			   'Siren (2nd Form)',
			   'Forza',
			   'Magisa',
			   'Galura',
			   'LiquiFlame (Human)',
			   'LiquiFlame (Hand)',
			   'LiquiFlame (Whirlwind)',
			   'Commander',
			   'Sandworm',
			   'Hole (Sandworm)',
			   '____ (Sandworm)',
			   'AdamanTiMi',
			   'FlameGun',
			   'Rocket',
			   'Exdeath (Final Battle)',
			   'Sol Cannon',
			   'Archaeavis (1st Form)',
			   'Archaeavis (2nd Form)',
			   'Archaeavis (3rd Form)',
			   'Archaeavis (4th Form)',
			   'Archaeavis (Undead)',
			   'Chim.Brain',
			   'Titan',
			   'Puroboros',
			   'Abductor (Butz Battle)',
			   'Gilgamesh (Dungeon)',
			   'Fishman',
			   'FlyingKillr',
			   "Lil'Chariot",
			   'NeoGalura',
			   'Gilgamesh (Bridge)',
			   'Tyrasaurus',
			   'Shiva',
			   'Abductor (Val Castle)',
			   'HiryuuPlant',
			   'HiryuuFlowr (1)',
			   'HiryuuFlowr (2)',
			   'HiryuuFlowr (3)',
			   'HiryuuFlowr (4)',
			   'HiryuuFlowr (5)',
			   "Gilgamesh (Zeza's Fleet)",
			   'Enkidou',
			   'Atmos',
			   '(Seal Guardian - Fire)',
			   '(Seal Guardian - Earth)',
			   '(Seal Guardian - Water)',
			   '(Seal Guardian - Air)',
			   'Carbunkle ()',
			   'Merugene (*Demo)',
			   'Gilgamesh (Morphed - Exdeath Castle)',
			   'Exdeath (Exdeath Castle)',
			   'Antlion',
			   'Mummy',
			   'Aspis',
			   'MachinHead',
			   'Merugene (Form 1)',
			   'Merugene (Form 2)',
			   'Merugene (Form 3)',
			   'Merugene (Form 4)',
			   'Odin',
			   'Gargoyle',
			   'Triton',
			   'Neregeid',
			   'Phobos',
			   'Omniscient',
			   'Minotauros',
			   'Leviathan',
			   'Stalker',
			   'Gogo',
			   'Bahamut',
			   'Jura Avis',
			   'Halicarnaso',
			   'Exdeath (vs Galuf)',
			   'NeoExdeath (Fake 1)',
			   'NeoExdeath (Fake 2)',
			   'Goblin (Butz Fight)',
			   'Iron Claw',
			   'Sergeant ()',
			   'Karnak ()',
			   'Crayclaw',
			   'NeoGoblin',
			   'Calofisteri',
			   'Apocalypse',
			   'Catastroph',
			   'Necrofobia',
			   'Twin Tania (1st form)',
			   'Launcher',
			   'Launcher',
			   'Gigamesh (Exdeath Castle)',
			   'Carbunkle ()',
			   'GrandMummy',
			   'Apanda',
			   'Alte Roite',
			   'Invisible',
			   'Abductor (Exdeath Castle)',
			   'BandelKuar (Phoenix Tower)',
			   'LiquiFlame (Phoenix Tower)',
			   'Kuzar (Phoenix Tower)',
			   'Sol Cannon (Phoenix Tower)',
			   'Pantera',
			   'Shinryuu',
			   'Barrier',
			   'Neo Exdeath (Part 1)',
			   'Neo Exdeath (Part 2)',
			   'Neo Exdeath (Part 3)',
			   'Neo Exdeath (Part 4)',
			   'Gilgamesh (Necrofobia)',
}

TableItemID = {	"Nothing           ",
				"Empty             ",
				"Knife             ",
				"Dagger            ",
				"Mythril Knife     ",
				"Kunai             ",
				"Mage Masher       ",
				"Guardian          ",
				"Kodachi           ",
				"Orialicn          ",
				"Air Lance         ",
				"Assassin          ",
				"Hardened (Sasuke) ",
				"Broadsword        ",
				"RegalCut          ",
				"Mythril Sword     ",
				"Coral Sword       ",
				"Ancient Sword     ",
				"Epee Sword        ",
				"Slumber Sword     ",
				"Defender Sword    ",
				"Excalibur         ",
				"Ragnarok          ",
				"Javelin           ",
				"Spear             ",
				"Mythril Spear     ",
				"Trident           ",
				"Wind Spear        ",
				"Partisan          ",
				"Gungnir           ",
				"DblLance          ",
				"Holy Lance        ",
				"Dragoon Lance     ",
				"Battle Axe        ",
				"Mythril Hammer    ",
				"Ogre Killer       ",
				"War Hammer        ",
				"Venom Axe         ",
				"Earth Hammer      ",
				"Rune Axe          ",
				"Thor Hammer       ",
				"Katana            ",
				"Air Blade         ",
				"Kotetsu           ",
				"Bizen             ",
				"Forged            ",
				"Murasume          ",
				"Masamune          ",
				"Tempest           ",
				"Rod               ",
				"Fire Rod          ",
				"Ice Rod           ",
				"Thunder Rod       ",
				"Venom Rod         ",
				"Lillith Rod       ",
				"Wizard Rod        ",
				"Staff             ",
				"Mythril Staff     ",
				"Power Staff       ",
				"Healing Staff     ",
				"Staff of Light    ",
				"Sage's Staff      ",
				"Judgement Staff   ",
				"Fire Bow          ",
				"Ice Bow           ",
				"Thunder Bow       ",
				"Darkness Bow      ",
				"Killer Bow        ",
				"Elven Bow         ",
				"Yoichi Bow        ",
				"Artemis Bow       ",
				"Silver Harp       ",
				"Dream Harp        ",
				"Lamia's Harp      ",
				"Apollo's Harp     ",
				"Whip              ",
				"Chain Whip        ",
				"Thunder Whip      ",
				"Flame Whip        ",
				"Dragon's Whisker  ",
				"Giyaman           ",
				"Earth Bell        ",
				"Rune Chime        ",
				"Tinkerbell        ",
				"Sabre (*Dummy)    ",
				"Drain Sword       ",
				"RuneEdge          ",
				"Flametongue       ",
				"IceBrand          ",
				"Full Moon         ",
				"Shuriken          ",
				"Pinwheel          ",
				"Excailbur         ",
				"BeastKiller       ",
				"Flail             ",
				"Morning Star      ",
				"Wonder Wand       ",
				"Brave Blade       ",
				"Soot              ",
				"Chicken Knife     ",
				"RisingSun         ",
				"Silver Bow        ",
				"Gale Bow          ",
				"AntiMagic Bow     ",
				"Avis Killer       ",
				"DoomCut           ",
				"Giant's Axe       ",
				"ManEater          ",
				"Thief Knife       ",
				"Dancing Dagger    ",
				"Enhancer          ",
				"L. Hand           ",
				"R. Hand           ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"                  ",
				"Leather Shield    ",
				"Bronze Shield     ",
				"Iron Shield       ",
				"Mythril Shield    ",
				"Golden Shield     ",
				"Aegis Shield      ",
				"Diamond Shield    ",
				"Crystal Shield    ",
				"Leather Cap       ",
				"Bronze Helm       ",
				"Iron Helm         ",
				"Mythril Helm      ",
				"Golden Helm       ",
				"Diamond Helm      ",
				"Crystal Helm      ",
				"Plumed Hat        ",
				"Tricorn Hat       ",
				"Magus             ",
				"Circlet           ",
				"Gold Hairpin      ",
				"Ribbon            ",
				"Bandana           ",
				"GrnBeret          ",
				"DarkHood          ",
				"Lamia's Tiara     ",
				"Leather Armor     ",
				"Bronze Armor      ",
				"Iron Armor        ",
				"Mythril Armor     ",
				"Golden Armor      ",
				"Diamond Armor     ",
				"Crystal Armor     ",
				"CopperPlt         ",
				"Training Suit     ",
				"Silver Plate      ",
				"Stealth Suit      ",
				"DiamndPlt         ",
				"DarkSuit          ",
				"Cotton Robe       ",
				"Silk robe         ",
				"Gaia Gear         ",
				"Bard's Surplice   ",
				"Lumina Robe       ",
				"Black Robe        ",
				"White Robe        ",
				"Mirage Vest       ",
				"Guard Ring        ",
				"Thief's Glove     ",
				"Giant's Gloves    ",
				"Elf Cape          ",
				"Cursed Ring       ",
				"Glasses           ",
				"Running Shoes     ",
				"Mythril Glove     ",
				"Silver Armlet     ",
				"Diamond Armlet    ",
				"Strength          ",
				"Power Wrist       ",
				"Angel Gwn         ",
				"Angel Ring        ",
				"Flame ring        ",
				"Coral ring        ",
				"Bone Mail         ",
				"Leather Shoes     ",
				"Kaiser Knuckles   ",
				"Gauntlets         ",
				"Tiger Mask        ",
				"Flame Shield      ",
				"CornaJar          ",
				"Genji Shield      ",
				"Genji Helm        ",
				"Genji Armor       ",
				"Genji Gloves      ",
				"Wall Ring         ",
				"Coronet           ",
				"Thornlet          ",
				"Ice Shield        ",
				"Cursed Shield     ",
				"Rainbow Dress     ",
				"Red Shoes         ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Item0000 (*Dummy) ",
				"Potion            ",
				"Hi-Potion         ",
				"Ether             ",
				"Elixir            ",
				"Phoenix Down      ",
				"Maiden's Kiss     ",
				"Revivify          ",
				"TurtleShell       ",
				"Antidote          ",
				"Eyedrop           ",
				"DragonFang        ",
				"DarkMatter        ",
				"Soft              ",
				"LuckMallet        ",
				"Dummy (*Dummy)    ",
				"MagicLamp         ",
				"Tent              ",
				"Cabin             ",
				"Giant Drink       ",
				"Power Drink       ",
				"Speed Drink       ",
				"Protect Drink     ",
				"Hero Drink        ",
				"DrgnCrest         ",
				"OmegaMedl         ",
				"Ramuh             ",
				"Shoat             ",
				"Golem             ",
				"Flame Tech        ",
				"Water Tech        ",
				"Thunder Tech      ",
				"FF (*Dummy)       ",

}
---------------------------------------------------------------------
-- Functions --------------------------------------------------------
---------------------------------------------------------------------
-- Watch variable for changes, then run function
-- TODO: use array instead of 2 separate vars
function watch(watched, compared, event)
	if watched ~= compared then
		event()
	end

	return watched
end


function BitOn(number, size)    -- Determine which bits are 1's
	local bit = {}
	local pos = 0

	for i=1, size do
		bit[i] = 0
	end

	while number > 0 do
		pos = pos+1
		if number % 2 == 1 then
			bit[pos] = 1
		end
		number = math.floor(number / 2)
	end

	return bit
end

function BitNot(number, size)    -- Determine which bits are 0's
	local bit = {}
	local pos = 0

	for i=1, size do
		bit[i] = 1
	end

	while number > 0 do
		pos = pos+1
		if number % 2 == 1 then
			bit[pos] = 0
		end
		number = math.floor(number / 2)
	end

	return bit
end

function BitString(number, size) -- Show number as binary
	if size == nil then size = 8 end
	local b = BitOn(number,size)
	local str = readBits(b)
	return str
end

function LANum(n,...) -- Left Align Number
	local l,pad = ...
	if l == nil then l = 2 end
	if pad == nil then pad = ' ' end
	local s = tostring(n)
	local tot = l-#s
	local done = ""

	for i=1, tot do
		done = pad .. done
	end
	done = done..s
	return done
end

function HiLoColor(n1,n2) -- return a color dependent on greater number
	if n1 > n2  then return 'red' end
	if n2 > n1  then return 'green' end
	if n1 == n2 then return 'white' end

end

function showCompare(x,y,s,n1,n2,color,...) -- Display string comparing 2 numbers @ x,y
	local l = ...
	if l == nil then l = 2 end
	local s1 = tostring(n1)
	local s2 = tostring(n2)

	gui.text(x,y,(s..' '),color)
	gui.text(x+(#s+1)*4,y,LANum(n1),color)
	gui.text(x+(#s+1)*4+(l)*4,y,"|"..LANum(n2),HiLoColor(n1,n2))

end
function readActiveBits(v,t,...)  -- return string showing values for active bits; size for BitOn optional
	local str = ''
	local size  = ...
	local s = {}
	if size == nil then size = 8
	end
	if size > 0 then s = BitOn(v, size) end
	if size < 0 then s = BitNot(v, -size) end
	local l = #s

	for i=1, l do
		if s[i] == 1 then
		str = str .. t[i].. ' '
		end
	end

	return str
end

function readBits(s,...)  -- return BitOn table as 001101 or such
	local str = table.concat(s)
	return str
end

function readStatus(s1,s2, t) -- return actors' active status effects. CAPS if status is initial
	local str = ''
	local status1 = BitOn(s1,8)
	local status2 = BitOn(s2,8)
	local l = #status1
	local newT = {'','','','','','','',''} -- table.concat quits early on a nil value

	for i=1, l do
		if status1[i] == 1 then
		newT[i] = t[i]..' '
		end
	end

	for i=1, l do
		if status2[i] == 1 then
			newT[i] = string.upper(t[i])..' '
		end
	end

	str = table.concat(newT)

	return str
end
function readEqStatus(s1,s2, t) -- return Equipment status Info. +CAPS if status is initial
	local str = ''
	local status1 = BitOn(s1,8)
	local status2 = BitOn(s2,8)
	local l = #status1
	local newT = {'','','','','','','',''} -- table.concat quits early on a nil value

	for i=1, l do
		if status1[i] == 1 then
		newT[i] = "-"..string.lower(t[i])
		end
	end

	for i=1, l do
		if status2[i] == 1 then
			if t[i] == "Dead" then newT[i] = string.upper("Always")..' '
			else newT[i] = "+"..string.upper(t[i]) end
		end
	end

	str = table.concat(newT)

	return str
end

-- return hours:min:sec from num
function MakeTime(n)
	-- 60 f/sec (or 30)
	local rawsec = math.floor(n/60)
	local seconds = rawsec%60
	-- 60 sec/min
	local rawmin = math.floor(rawsec/60)
	local minutes = rawmin%60
	-- 60 min/hour
	local rawhour = math.floor(rawmin/60)
	local hours = rawhour%60
	-- 24 hour/day
	local rawday = math.floor(rawhour/24)

	local hoursFront = ''
	if hours > 0 then hoursFront = hours..":" end
	return hoursFront..LANum(minutes,2,'0')..":"..LANum(seconds,2,'0')
end
function findEnemyName(en) -- finds an enemy name; returns number if name is not on table
	local N = TableEnemy[en.Name+1]

	if N ~= nil then
		return N
	else
		return en.Name
	end
end

function readEleDefense(C,x) -- read Elemetal Defense bits and return symbol
	local weak = BitOn(C.ElementWeakness,8)
	local half = BitOn(C.ElementHalf,8)
	local immu = BitOn(C.ElementImmune,8)
	local abso = BitOn(C.ElementAbsorb,8)
	-- absorb
	if abso[x] == 1 then
		return "*"
	end
	-- immune
	if immu[x] == 1 then
		return "0"
	end
	-- half
	if half[x] == 1 then
		return "#"
	end
	-- weak
	if weak[x] == 1 then
		return "X"
	end
	return "."
end

function showEleDefense(x,y,a) -- show Elemental Def table at location @ x,y
	gui.text (x+0,  y, readEleDefense( a,1), "red") 	-- Fire
	gui.text (x+5 , y, readEleDefense( a,2), "cyan") 	-- Ice
	gui.text (x+10, y, readEleDefense( a,3), "yellow") 	-- Lit
	gui.text (x+15, y, readEleDefense( a,4), cPurple) 	-- Poison
	gui.text (x+20, y, readEleDefense( a,5), "white") -- Holy
	gui.text (x+25, y, readEleDefense( a,6), cTan) 	-- Earth
	gui.text (x+30, y, readEleDefense( a,7), cGreen) 	-- Wind
	gui.text (x+35, y, readEleDefense( a,8), cBlue) -- Water
end

function showStatusProp(a,x,y) -- show which status effects equpiment give/blocks @ x,y
	gui.text (x,y+00, readEqStatus(a.ImmuneC, a.InitialC, TableStatusCurable), 'cyan')
	gui.text (x,y+08, readEqStatus(a.ImmuneT, a.InitialT, TableStatusTemporary), 'magenta')
	gui.text (x,y+16, readEqStatus(a.ImmuneD, a.InitialD, TableStatusDispellable), 'red')
	gui.text (x,y+24, readEqStatus(0, a.InitialP, TableStatusP), 'yellow')
end

function EleDefenseDef(n) -- Armours' Elemental Defense Definition
	local def = {}
	local address = 0xD12580+(n*5)

	def = {
			ElementAbsorb	= readByte(address+0x0),
			ElementEvade	= readByte(address+0x1),
			ElementImmune	= readByte(address+0x2),
			ElementHalf		= readByte(address+0x3),
			ElementWeakness	= readByte(address+0x4),
	}

	return def
end
function StatDefenseDef(n)-- Armours' Staus Defense Definition
	local def = {}
	local address = 0xD126C0+(n*7)

	def = {
			InitialC	= readByte(address+0x0),
			InitialT	= readByte(address+0x1),
			InitialD	= readByte(address+0x2),
			InitialP	= readByte(address+0x3),
			ImmuneC		= readByte(address+0x4),
			ImmuneT		= readByte(address+0x5),
			ImmuneD		= readByte(address+0x6),
	}

	return def
end

function DisplayParameters(o,x,y) -- Display information about att formula parameters @ x,y
	local results = getParameters(o)
	local color = cLBlue
	gui.text(x,y, 	results[1], color)
	gui.text(x,y+8, results[2], color)
	gui.text(x,y+16, results[3], color)
end

function getParameters(o) -- Every Attack Formula uses three bytes, but in different ways
	local aType = o.AttFormula
	local s = {}
	if o.Special ~= nil then
		s = BitOn(o.Special,8)
		else s = BitOn(0,8)
	end
	local p1 = o.Parameter1
	local p2 = o.Parameter2
	local p3 = o.Parameter3
	local results = {'','',''}

	-- Ready? This will be VERY long
	-- No Effect (apparently)
	if aType == 0x00 then
		if p1 > 0 then
			results[1]			= "Duration/2: " .. p1
		end
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			results[3] 		= "Ability   : " .. TableMagicID[p3+1]
		end
	end
	-- Offensive Magic
	if aType == 0x06 then
		results[2]			= "AttPow    : " .. p2
		results[3]			= "Element   : " .. readActiveBits(p3,TableElement)
	end

	-- Gravity Damage, Harp songs
	if aType == 0x07 then
		results[1] 			= "Hit%      : " .. p1
		results[2]			= "x/16ths   : " .. p2
		results[3]			= "Status add: " .. readActiveBits(p3,TableStatusT)
	end

	-- HP drain
	if aType == 0x0D then
		results[1] 			= "Hit%      : " .. p1
		results[2]			= "AttPow    : " .. p2
	end

	-- Status C Bestow
	if aType == 0x12 then
		results[1]			= "Hit%      : " .. p1
		results[2]			= "Duration  : " .. p2
		results[3]			= "Status Add: " .. readActiveBits(p3,TableStatusCurable)
	end

	-- Status T Bestow
	if aType == 0x13 then
		results[1]			= "Hit%      : " .. p1
		results[2]			= "Duration/2: " .. p2
		results[3]			= "Status Add: " .. readActiveBits(p3,TableStatusTemporary)
	end

	-- Status D Bestow
	if aType == 0x14 then
		results[1]			= "Hit%      : " .. p1
		results[2]			= "Duration  : " .. p2
		results[3]			= "Status Add: " .. readActiveBits(p3,TableStatusDispellable)
	end

	-- Speed Status
	if aType == 0x16 then
		results[1]			= "Hit%      : " .. p1
		results[2]			= "Status Rem: " .. readActiveBits(p2,TableStatusDispellable,-8)
		results[3]			= "Status Add: " .. readActiveBits(p3,TableStatusDispellable)
	end

	-- Status Removal
	if aType == 0x19 then
		if p1<0xFF then
			results[1]		= "Status Rem: " .. readActiveBits(p1,TableStatusCurable,-8)
		end
		if p2<0xFF then
			results[2]		= "Status Rem: " .. readActiveBits(p2,TableStatusDispellable,-8)
		end
		if p3<0xFF then
			results[3]		= "Status Rem: " .. readActiveBits(p3,TableStatusTemporary,-8)
		end
	end

	-- Resurrection
	if aType == 0x1A then
		results[1]			= "Hit% (und): " .. p1
		results[2]			= ""
		results[3]			= p3..'/16 HP restored'
	end

	-- Restore HP Item
	if aType == 0x24 then
		results[1]			= "Restore HP: " .. p1 * p2
	end

	-- Restore MP Item
	if aType == 0x25 then
		results[1]			= "Restore MP: " .. p1 * p2
	end

	-- Full HP/MP
	if aType == 0x26 then
		local Res = "Full "
		if BitOn(p1,8)[1] then
		Res = Res .. 'HP '
		end
		if BitOn(p1,8)[1] then
		Res = Res .. 'MP '
		end
		results[1] 			= Res
	end

	-- Fixed Damage
	if aType == 0x28 then
		results[1] 			= "Hit%      : " .. p1
		results[2]			= "Damage    : " .. p2+p3*512
	end

	-- Sword, Knife, Spear
	if aType == 0x31 or aType == 0x32 or aType == 0x33  then
		if p1 > 0 then
			results[1] 		= "Element   : " .. readActiveBits(p1,TableElement)
		else results[1] 	= "Element   : None"
		end
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
				 results[3] = "Ability   : " .. TableAbilityID[p3+1]
			else results[3] = "Ability   : " .. TableMagicID[p3+1]
			end
		end
	end

	-- Axe, Staff, Whip, Long Reach Axe
	if aType == 0x34 or aType == 0x38 or aType == 0x3A then
		results[1] 			= "Hit%      : " .. p1
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
				 results[3] = "Ability   : " .. TableAbilityID[p3+1]
			else results[3] = "Ability   : " .. TableMagicID[p3+1]
			end
		end
	end

	-- Status infliction bow
	if aType == 0x35 then
		results[1] 			= "Hit%      : " .. p1
		if math.floor(p2/128) == 1 then -- if inflict status
			results[2] 		= "Activate% : " .. p2%128
			results[3]		= "Status add: " .. readActiveBits(p3,TableStatusC)
		end
	end

	-- Normal Bow
	if aType == 0x36 then
		results[1] 			= "Hit%      : " .. p1
		results[2]			= "Critical% : " .. p2
		if p3 > 0 then
			results[3] 		= "Element   : " .. readActiveBits(p3,TableElement)
		else results[3] 	= "Element   : None"
		end
	end

	-- Katana
	if aType == 0x37 then
		results[1] 			= "Critical% : " .. p1
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
				 results[3] = "Ability   : " .. TableAbilityID[p3+1]
			else results[3] = "Ability   : " .. TableMagicID[p3+1]
			end
		end
	end

	-- Rod
	if aType == 0x3B then
		results[1] 			= "Hit%      : " .. p1
		if p3 > 0 then
			results[3] 		= "Element   : " .. readActiveBits(p3, TableElement)
		else results[3] 	= "Element   : None"
		end
	end

	-- Rune weapon
	if aType == 0x3C then
		results[1] 			= "Hit%      : " .. p1
		results[2]			= "Attack +  : " .. p2
		results[3]			= "MP Cost   : " .. p3
	end

	-- HP and Status Remove
	if aType == 0x42 then
		results[1] 			= "Hit%      : " .. p1
		results[2] 			= "AttPow    : " .. p2
		results[3]			= "Status rem: " .. readActiveBits(p3,TableStatusCurable,-8)
	end

	-- Flirt
	if aType == 0x49 then
		results[1] 			= "Hit%      : " .. p1
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			results[3] 		= "Ability   : " .. TableMagicID[p3+1]
		end
	end

	-- Status Up/Down
	if aType == 0x51 then
		local p2Bits = BitOn(p2,8)
		results[1] 			= "Hit%      : " .. p1
		if p2Bits[8] == 1 or p2Bits[7] == 1 then
			results[2]			= "Level Half"
		end
		if p2Bits[6] == 1 then
			results[2]			= "Def Half  "
		end
		if p2Bits[5] == 1 then
			results[2]			= "Level Up  "
		end
		if p2Bits[3] == 1 then
			results[2]			= "Att Pow Up"
		end
		if p3 > 0 then
			results[3] 			= "Amount    : " .. p3
		end
	end

	-- Max HP Up (Giant Drink)
	if aType == 0x59 then

	end

	-- Chicken Knife
	if aType == 0x64 then
		-- Not actually part of Parameters, but useful info for the item
		results[1] 			= "Escapes   : " .. readByte(0x7E7C75)
		results[2] 			= "Activate% : " .. p2
			if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
				 results[3] = "Ability   : " .. TableAbilityID[p3+1]
			else results[3] = "Ability   : " .. TableMagicID[p3+1]
			end
	end

	-- Anti-monster
	if aType == 0x6C then
		results[3]			= "Strong Vs : " .. readActiveBits(p3,TableCreature)
	end

	-- Brave Blade
	if aType == 0x6E then
		-- Not actually part of Parameters, but useful info for the item
		results[1] 			= "Escapes   : " .. readByte(0x7E7C75)
	end

	-- Anti-monster Bow
	if aType == 0x72 then
		results[1]			= "Strong Vs : " .. readActiveBits(p1,TableCreature)
		if p2 > 0 then
			results[2] 		= "Activate% : " .. p2
			results[3] 		= "Ability   : " .. TableMagicID[p3+1]
		end
	end

	-- Anti-monster 'spear'
	if aType == 0x73 then
		results[1]			= "Strong Vs : " .. readActiveBits(p1,TableCreature)
	end

	-- No attack
	if aType == 0x7F then

		if p1 > 0 then
			results[1]		= "Power     : " .. p1
		end
		if p2> 0 then
		results[2] 			= "Activate% : " .. p2
			if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
				 results[3] = "Ability   : " .. TableAbilityID[p3+1]
			else results[3] = "Ability   : " .. TableMagicID[p3+1]
			if s[1] ==1 then -- Wonder Rod
				results[3]	= "Ability   : Wonder Rod"
			end
			end

		-- if actually a harp, look for actual info
		if p3 == 0x74 or p3 == 0x75 or p3 == 0x76 or p3 == 0x77 then
			results[1]="Harp"
			--results = getParameters(??)
		end
		end
	end
	return results
end

function throwCheck(n) -- Quick check to see if weap is throwable
	if n == 0 then return "Can Throw"
	else return ""
	end
end

function findNewMagEva(char, equip, point) -- Calculate Equip Preview MagDef, since the game doesn't
	local newMEV = 0
	local itemMEV = 0
	local baseMEV = char.MagEvade
	local equiMEV = 0
	if equip.itemType == 'armor' then equiMEV = equip.MagEvade end
	local slot = equip.EquipSlots
	local curr = {}
	if slot == 08 then curr = ItemInfo(char.RHandShield) end -- Rhand
	if slot == 08 then curr = ItemInfo(char.LHandShield) end -- Lhand
	if slot == 04 then curr = ItemInfo(char.Head) end -- Head
	if slot == 02 then curr = ItemInfo(char.Body) end -- Body
	if slot == 01 then curr = ItemInfo(char.Relic) end -- Accessory
	if slot == nil then curr = ItemInfo(char.LHandShield) end -- If replacing shield w/ weap

	if curr.itemType ~= 'armor' then itemMEV = 0
	else itemMEV = curr.MagEvade
	end

	newMEV = baseMEV - itemMEV
	if newMEV < 0 then newMEV = 0 end
	newMEV = newMEV + equiMEV

	return newMEV
end
function drawEmptyBox(X, Y, Width, Height, Color)   -- Paints an empty box unlike "gui.drawbox"
	local x0 = X
	local y0 = Y
	local x1 = X+Width
	local y1 = Y+Height

	gui.drawline( x0,y0, x1,y0, Color)
	gui.drawline( x1,y0, x1,y1, Color)
	gui.drawline( x1,y1, x0,y1, Color)
	gui.drawline( x0,y1, x0,y0, Color)
end

function drawBorderBox(X, Y, Width, Height,...) -- Combine drawBox & drawEmptyBox into 1 function
	Color1, Color2 = ...
	if Color1 == nil then Color1 = "white" end
	if Color2 == nil then Color2 = "blue" end
	gui.transparency(0)
	drawEmptyBox(X, Y, Width, Height, Color1)
	gui.transparency(1)
	gui.drawbox(X+1,Y+1,X+Width-1,Y+Height-1,Color2)
end

function determineX(x) -- if Flippy is set, pretent xorigin is @ right side (for back attack)
	if Flippy then
		return 225 - x
	else
		return x
	end
end

function positionString(current, total) -- Mainly for showing battlepage
	str = ''
	for i=0, total do
		if i==current then str = str .. '+'
		else str = str .. '-' end
	end
	return str
end

function readRange(add, num) -- read memories that aren't 1,2,4 bytes long
	local result = 0
	for i = 0, num-1 do
		result = result + readByte ( add + i ) * 256 ^ i
	end
	return result
end

function splitTop(num, split)
	return (num % split)
end

function splitBot(num, split)
	return math.floor(num / split)
end

function ShowBattleDisplay()
	DisplayBattleInfo = true
end

function HideBattleDisplay()
	DisplayBattleInfo = false
end

function adjustBattleDisplay()
	if newEnemyReady == readByte(0x7E4000) ~= 0 and readByte(0x7E00DE) ~=0 then
		ShowBattleDisplay()
		gui.text(0,20, "++", "white")
	else
		HideBattleDisplay()
		gui.text(0,20, "--", "red")
	end
end

--------------------------------------------------------------------------------
----- OBJECTS ------------------------------------------------------------------
--------------------------------------------------------------------------------
function EnemyInfo(Enemy)    -- Table with the parameters of monsters
	local enemy = Enemy - 1
	local enemyinfo = {}

	enemyinfo = {
		Name            = readWord(0x7E4008 + enemy*(0x02)) ,
	  --Type            = readWord(0x7E4038 + enemy*(0x04)) ,

		Level           = readByte(0x7E2202 + enemy*(0x80)) ,
		CurrentHp       = readWord(0x7E2206 + enemy*(0x80)) ,
		TotalHp         = readWord(0x7E2208 + enemy*(0x80)) ,
		CurrentMp       = readWord(0x7E220A + enemy*(0x80)) ,
		TotalMp         = readWord(0x7E220C + enemy*(0x80)) ,
		StatusC         = readByte(0x7E221A + enemy*(0x80)) ,
		StatusT         = readByte(0x7E221B + enemy*(0x80)) ,
		StatusD         = readByte(0x7E221C + enemy*(0x80)) ,
		StatusP         = readByte(0x7E221D + enemy*(0x80)) ,
	  --MagicPower      = readByte(0x7E2227 + enemy*(0x80)) ,
	  --MagicPower      = readByte(0x7E222B + enemy*(0x80)) ,
		Evade           = readByte(0x7E222C + enemy*(0x80)) ,
		Defense         = readByte(0x7E222D + enemy*(0x80)) ,
		MagicEvade      = readByte(0x7E222E + enemy*(0x80)) ,
		MagicDefense    = readByte(0x7E222F + enemy*(0x80)) ,
		ElementAbsorb   = readByte(0x7E2230 + enemy*(0x80)) ,
	  --ElementWeakness = readByte(0x7E2231 + enemy*(0x80)) , -- NOT Weakness; maybe evade?
		ElementHalf 	= 0,
		ElementImmune   = readByte(0x7E2232 + enemy*(0x80)) ,
		ElementWeakness = readByte(0x7E2234 + enemy*(0x80)) ,
		ImmuneC			= readByte(0x7E2235 + enemy*(0x80)) ,
		ImmuneT			= readByte(0x7E2236 + enemy*(0x80)) ,
		ImmuneD			= readByte(0x7E2237 + enemy*(0x80)) ,
		Attack          = readByte(0x7E2244 + enemy*(0x80)) ,
		AttackMult      = readByte(0x7E2262 + enemy*(0x80)) ,
		CantEvade       = readByte(0x7E2264 + enemy*(0x80)) ,
		Type            = readByte(0x7E2265 + enemy*(0x80)) ,
		CommandImmunity = readByte(0x7E2266 + enemy*(0x80)) ,
		Experience      = readWord(0x7E2267 + enemy*(0x80)) ,
		Gil             = readWord(0x7E2269 + enemy*(0x80)) ,
		InitialC		= readByte(0x7E2270 + enemy*(0x80)) ,
		InitialT		= readByte(0x7E2271 + enemy*(0x80)) ,
		InitialD		= readByte(0x7E2272 + enemy*(0x80)) ,
		InitialP		= readByte(0x7E2273 + enemy*(0x80)) ,

		AttackGauge     = readByte(0x7E3DAB + enemy*(0x0B)) ,
		Position        = readByte(0x7E4000 + enemy*(0x01)) ,
		PositionY       = readByte(0x7E4000 + enemy*(0x01)) % 16 ,                  -- low nibble
		PositionX       = math.floor( readByte(0x7E4000 + enemy*(0x01)) / 16 ) ,    -- high nibble

		StealCommon		= readByte(0xD05000+ readWord(0x7E4008 + enemy*(0x02))*4+1),
		StealRare		= readByte(0xD05000+ readWord(0x7E4008 + enemy*(0x02))*4)  ,
		DropCommon		= readByte(0xD05000+ readWord(0x7E4008 + enemy*(0x02))*4+3),
		DropRare		= readByte(0xD05000+ readWord(0x7E4008 + enemy*(0x02))*4+2),

	statusgap	= 2
	}

	return enemyinfo
end

function CharacterInfo(Character)    -- Table with the battle parameters of allies
	local character = Character - 1
	local characterinfo = {}


	characterinfo = {
		Character       = readByte(0x7E2000 + character*(0x80)) ,
		Job             = readByte(0x7E0501 + character*(0x50)) ,
		Level           = readByte(0x7E2002 + character*(0x80)) ,
		CurrentHp       = readWord(0x7E2006 + character*(0x80)) ,
		TotalHp         = readWord(0x7E2008 + character*(0x80)) ,
		CurrentMp       = readWord(0x7E200A + character*(0x80)) ,
		TotalMp         = readWord(0x7E200C + character*(0x80)),


		StatusC			= readByte(0x7E201A + character*(0x80)), -- Status (Curable)
		StatusT			= readByte(0x7E201B + character*(0x80)), -- Status (Temporary)
		StatusD			= readByte(0x7E201C + character*(0x80)), -- Status (Dispellable)
		StatusP			= readByte(0x7E201D + character*(0x80)), -- Status (Permanent)

		InitialC		= readByte(0x7E2070 + character*(0x80)), -- Inital Status (C)
		InitialT		= readByte(0x7E2071 + character*(0x80)), -- Inital Status (C)
		InitialD		= readByte(0x7E2072 + character*(0x80)), -- Inital Status (C)
		InitialP		= readByte(0x7E2073 + character*(0x80)), -- Inital Status (C)

		PowSong			= readByte(0x7E2074 + character*(0x80)), -- Power Song
		SpeedSong		= readByte(0x7E2075 + character*(0x80)), -- Speed Song
		StrSong			= readByte(0x7E2076 + character*(0x80)), -- Str Song
		MagSong			= readByte(0x7E2077 + character*(0x80)), -- Mag Song
		HeroSong		= readByte(0x7E2078 + character*(0x80)), -- Hero Song

		ElementAbsorb	= readByte(0x7E2030 + character*(0x80)), -- Elemental Absorb
		ElementEvade	= readByte(0x7E2031 + character*(0x80)), -- Elemental Evade?
		ElementImmune	= readByte(0x7E2032 + character*(0x80)), -- Elemental Immunity
		ElementHalf 	= readByte(0x7E2033 + character*(0x80)), -- Elemental Half
		ElementWeakness	= readByte(0x7E2034 + character*(0x80)), -- Elemental Weakness

		ElementBoost	= readByte(0x7E2022 + character*(0x80)) -- Magic Element UP
	}

	return characterinfo
end

function WorldCharInfo(Char)	-- parameters of characters' world map stats (out of battle)
	local charinfo = {}
	local address = 0x7E0500+ Char * 0x50

	charinfo = {
		CharInfo		= readByte(address + 0x00), --XX       --1st Player (Character)+128 if backrow
		CharNo			= readByte(address + 0x00)%8, --XX       --1st Player (Character)+128 if backrow
		Job				= readByte(address + 0x01), --XX       --1st Player Job
		Level			= readByte(address + 0x02), --XX       --1st Player Level
		Exp				= readRange(address + 0x03,3),					--XXXXXX   --1st Player Exp.
		CurrentHP		= readWord(address + 0x06), --XXXX     --1st Player Current Hp
		MaxHP			= readWord(address + 0x08), --XXXX     --1st Player Max Hp
		CurrentMP		= readWord(address + 0x0A), --XXXX     --1st Player Current Mp
		MaxMP			= readWord(address + 0x0C), --XXXX     --1st Player Max Mp
		Head			= readByte(address + 0x0E), --XX       --1st Player Head equipment modifier
		Body			= readByte(address + 0x0F), --XX       --1st Player Body equipment modifier
		Relic			= readByte(address + 0x10), --XX       --1st Player Relic equipment modifier
		RHandShield		= readByte(address + 0x11), --XX       --1st Player Right Hand Shield modifier
		LHandShield		= readByte(address + 0x12), --XX       --1st Player Left Hand Shield modifier
		RHand			= readByte(address + 0x13), --XX       --1st Player Right Hand Weapon modifier
		LHand			= readByte(address + 0x14), --XX       --1st Player Left Hand Weapon modifier
		CapMonster		= readByte(address + 0x15), --XX       --1st Player Caught Monster modifier (World)
		Command1		= readByte(address + 0x16), --XX       --1st Player Battle Command 1 (Up) modifier
		Command2		= readByte(address + 0x17), --XX       --1st Player Battle Command 2 (Left) modifier
		Command3		= readByte(address + 0x18), --XX       --1st Player Battle Command 3 (Right) modifier
		Command4		= readByte(address + 0x19), --XX       --1st Player Battle Command 4 (Down) modifier
		StatusC			= readByte(address + 0x1A), --XX       --1st Player Status (World - curable)
		UnKnown1		= readByte(address + 0x1B), --XX       --1st Player
		UnKnown2		= readByte(address + 0x1C), --XX       --1st Player
		UnKnown3		= readByte(address + 0x1D), --XX       --1st Player
		UnKnown4		= readByte(address + 0x1E), --XX       --1st Player
		UnKnown5		= readByte(address + 0x1F), --XX       --1st Player
		Passive1		= readByte(address + 0x20), --XX       --1st Player Innate Abilities
		Passive2		= readByte(address + 0x21), --XX       --1st Player Innate Abilities
		EleBoost		= readByte(address + 0x22), --XX       --1st Player Magic Element Up
		Weight			= readByte(address + 0x23), --XX       --1st Player Equip Weight
		Str				= readByte(address + 0x24), --XX       --1st Player Base Strength
		Agi				= readByte(address + 0x25), --XX       --1st Player Base Agility
		Vit				= readByte(address + 0x26), --XX       --1st Player Base Stamina
		Mag				= readByte(address + 0x27), --XX       --1st Player Base Magic Power
		EqStr			= readByte(address + 0x28), --XX       --1st Player Current Strength (Equipment)
		EqAgi			= readByte(address + 0x29), --XX       --1st Player Current Agility (Equipment)
		EqVit			= readByte(address + 0x2A), --XX       --1st Player Current Stamina (Equipment)
		EqMag			= readByte(address + 0x2B), --XX       --1st Player Current Magic (Equipment)
		Evade			= readByte(address + 0x2C), --XX       --1st Player Evade%
		Def				= readByte(address + 0x2D), --XX       --1st Player Defense
		MagEvade		= readByte(address + 0x2E), --XX       --1st Player Magic Evade%
		MagDef			= readByte(address + 0x2F), --XX       --1st Player Magic Defense
		ElementAbsorb	= readByte(address + 0x30), --XX       --1st Player Elemental Absorb
		--				= readByte(address + 0x31), --XX       --1st Player Elemental Evade
		ElementImmune	= readByte(address + 0x32), --XX       --1st Player Elemental Immunity
		ElementHalf		= readByte(address + 0x33), --XX       --1st Player Elemental Half
		ElementWeakness	= readByte(address + 0x34), --XX       --1st Player Elemental Weakness
		UnKnown7		= readByte(address + 0x35), --XX       --1st Player
		UnKnown8		= readByte(address + 0x36), --XX       --1st Player
		UnKnown9		= readByte(address + 0x37), --XX       --1st Player
		EquipableWeapon	= readByte(address + 0x38), --XX       --1st Player Weapon Specialty
		EquipableArmor	= readByte(address + 0x39), --XX       --1st Player Equipment Specialty
		JobLevel		= readByte(address + 0x3A), --XX       --1st Player Job Level
		ABPoints		= readWord(address + 0x3B), --XXXX     --1st Player ABP
		UnKnown10		= readByte(address + 0x3D), --XX       --1st Player
		UnKnown11		= readByte(address + 0x3E), --XX       --1st Player
		UnKnown12		= readByte(address + 0x3F), --XX       --1st Player
		Mystery			= memory.readdword(address + 0x40), --XXXXXXXX --1st Player Jobs?
		AttPow			= readWord(address + 0x44), --XXXX     --1st Player Attack
		UnKnown13		= readByte(address + 0x46), --XX       --1st Player
		UnKnown14		= readByte(address + 0x47), --XX       --1st Player
		UnKnown15		= readByte(address + 0x48), --XX       --1st Player
		UnKnown16		= readByte(address + 0x49), --XX       --1st Player
		UnKnown17		= readByte(address + 0x4A), --XX       --1st Player
		UnKnown18		= readByte(address + 0x4B), --XX       --1st Player
		UnKnown19		= readByte(address + 0x4C), --XX       --1st Player
		UnKnown20		= readByte(address + 0x4D), --XX       --1st Player
		UnKnown21		= readByte(address + 0x4E), --XX       --1st Player
		UnKnown22		= readByte(address + 0x4F), --XX       --1st Player

	}
	return charinfo
end

function JobInfo(n) -- Job Info (this is stored differently than, say Item data)
	local jobinfo = {}

	jobinfo = {
		index =   n,

		FirstAbility	= readWord(0xD152C0 + n*2), 	-- 1st ability pointer
		NumOfAbility	= readByte(0xD152EA + n), 	-- Number of abilites/job
		BaseStr			= readByte(0xD156B0 + n*4),	-- Stat Modification
		BaseAgi			= readByte(0xD156B1 + n*4),	-- Stat Modification
		BaseVit			= readByte(0xD156B2 + n*4),	-- Stat Modification
		BaseMag			= readByte(0xD156B3 + n*4),	-- Stat Modification
		Equipable		= memory.readdword(0xD15708 + n*4),
		Native1			= readByte(0xD15760 + n*4),	-- Native skills for job (Fight, Cover, etc)
		Native2			= readByte(0xD15761 + n*4),
		Native3			= readByte(0xD15762 + n*4),
		Native4			= readByte(0xD15763 + n*4),
		Passive1		= readByte(0xD157B8 + n*2),	-- Auto Passives for Job
		Passive2		= readByte(0xD157B9 + n*2),
	}
	return jobinfo
end

function AbilityInfo(n)
	local abilityinfo = {}
	local address = 0

	abilityinfo = {
		index = n,

	}
	return abilityinfo
end

function EquipPreviewInfo() -- Information game uses in equip screen
	local eqpr = {}

	eqpr = {
		EqWt			= readByte(0x7E2723), -- Equipment Weight    (Menu)
		BaseStr			= readByte(0x7E2724), -- Base Strength       (Menu)
		BaseAgi			= readByte(0x7E2725), -- Base Agility        (Menu)
		BaseVit			= readByte(0x7E2726), -- Base Vitality       (Menu)
		BaseMag			= readByte(0x7E2727), -- Base Magic Power    (Menu)
		Str				= readByte(0x7E2728), -- Current Strength    (Menu)
		Agi				= readByte(0x7E2729), -- Current Agility     (Menu)
		Vit				= readByte(0x7E272A), -- Current Vitality    (Menu)
		Mag				= readByte(0x7E272B), -- Current Magic Power (Menu)
		Eva				= readByte(0x7E272C), -- Current Evade%      (Menu)
		Def				= readByte(0x7E272D), -- Current Defense     (Menu)
		MagEvade		= readByte(0x7E272E), -- Magic Evade%        (Menu)
		MagDef			= readByte(0x7E272F), -- Magic Defense       (Menu)
		ElementAbsorb	= readByte(0x7E2730), -- Elemental Absorb    (Menu)
		ElementImmune	= readByte(0x7E2732), -- Elemental Immunity  (Menu)
		ElementHalf		= readByte(0x7E2733), -- Elemental Half      (Menu)
		ElementWeakness	= readByte(0x7E2734), -- Elemental Weakness  (Menu)
		--				= readByte(0x7E2738), -- Weapon Specialty    (Menu)
		--				= readByte(0x7E2739), -- Equipment Specialty (Menu)?
		--				= readByte(0x7E273A), -- Job Level           (Menu)?
		--				= readWord(0x7E273B), -- ABP                 (Menu)?
		AttPow			= readWord(0x7E2744), -- Attack              (Menu)
	}

	return eqpr
end

function ItemInfo(n)
	local item = {index = n, itemType = "Nothing"}
	local address = 0

	if n >= 0x01 and n <= 0x7F then -- weapon
		address = 0xD10000+(n*12)
		item = {
			index = n,
			itemType = "weapon",
			-- D1/0000
			-- [Item] * 12 bytes
			Target			= readByte(address+0x0), -- 0 Targeting (when used as item)
			AttackType		= readByte(address+0x1), -- 1 [Attack type]
			ThrowEquip		= readByte(address+0x2), -- 2 Throw + Equipment type value
			Throwable		= splitBot(readByte(address+0x2) , 64), -- 2 Throwable
			EquipType 		= splitTop(readByte(address+0x2) , 64), -- 2 Equipment type value
			BoostStats		= readByte(address+0x3), -- 3 Element/stats up
			StatsUpCheck	= splitBot(readByte(address+0x3),128), -- 3 Stats up check bit
			EleBoost		= splitTop(readByte(address+0x3),128),	-- 3 Elemental Boost
			StatsUp			= math.floor((readByte(address+0x3)%128)/8),	-- 3 Bonus Stats
			StatsValue		= readByte(address+0x3)%8,	-- 3 Stats up value
			DGDescript		= readByte(address+0x4), -- 4 Double Grip + Description
			Descript		= readByte(address+0x4)%64, -- 4 Description
			Double			= math.floor(readByte(address+0x4)/64), -- 4 Double Grip info
			Special			= readByte(address+0x5), -- 5 Special properties
			UsedBreak		= readByte(address+0x6), -- 6 Used as item/Break on use
			Break			= math.floor(readByte(address+0x6)/128), -- 6 Break on use
			Used			= readByte(address+0x6)%128, -- 6 Used as item
			AttPow			= readByte(address+0x7), -- 7 Attack power
			AttFormula		= readByte(address+0x8), -- 8 Attack formula
			Parameter1		= readByte(address+0x9), -- 9 Parameter 1 \
			Parameter2		= readByte(address+0xA), -- A Parameter 2  (See Actions chapter)
			Parameter3		= readByte(address+0xB), -- B Parameter 3 /

		}
	end
	if n >= 0x80 and n <= 0xDF then -- armor
		address = 0xD10000 + (n*12)
		item = {
			index = n,
			itemType = "armor",
			--	- D1/0600
			--	[Item] * 12 bytes
			EquipSlots		= readByte(address+0x0),--	0 Equipment slots
			Weight			= readByte(address+0x1),--	1 Equipment weight
			ThrowEquip		= readByte(address+0x2),--	2 Equipment type value \
			EquipType 		= readByte(address+0x2) % 64, -- 2 Equipment type value
			BoostStats		= readByte(address+0x3), -- 3 Element/stats up
			StatsUpCheck	= math.floor(readByte(address+0x3)/128), -- 3 Stats up check bit
			EleBoost		= readByte(address+0x3)%128,	-- 3 Elemental Boost
			StatsUp			= math.floor((readByte(address+0x3)%128)/8),	-- 3 Bonus Stats
			StatsValue		= readByte(address+0x3)%8,	-- 3 Stats up value
			Descript		= readByte(address+0x4),--	4 Description          /
			Special			= readByte(address+0x5),--	5 Special properties
			Evade			= readByte(address+0x6),--	6 Evade %
			Defense			= readByte(address+0x7),--	7 Defense
			MagEvade		= readByte(address+0x8),--	8 Magic evade %
			MagDefense		= readByte(address+0x9),--	9 Magic defense
			EleDefense		= readByte(address+0xA),--	A Element defense
			StatusProp		= readByte(address+0xB),--	B Status properties
		}
	end
	if n >= 0xE0 then				-- consumables
		address = 0xD10A80 + (n-0xE0)*8
		item = {
			index = n,
			itemType = "useable",
			--	- D1/0A80
			--	[Item] * 8 bytes
			Target			= readByte(address+0x0), --	0 Targeting
			AttackType		= readByte(address+0x1), --	1 [Attack Type]
			Misc			= readByte(address+0x2), --	2 Misc.
			Descript		= readByte(address+0x3)%128, --	3 Description (see Weapons section)
			Unavoid			= math.floor(readByte(address+0x4)/128), --	3 Unavoidable formula
			AttAvoid		= readByte(address+0x4), --	4 Unavoidable + Attack formula
			AttFormula		= readByte(address+0x4)%128, --	4 Attack formula
			Parameter1		= readByte(address+0x5), --	5 Parameter 1 \
			Parameter2		= readByte(address+0x6), --	6 Parameter 2  (See Actions chapter)
			Parameter3		= readByte(address+0x7), --	7 Parameter 3 /
		}
	end
	return item
end




------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

while true do  -- Idle loop. Prevents pre-lua pause state

local character = {}            -- Holds the character's information
local NoCharacters = 4          -- Number of characters in a battle

local enemy = {}                -- Holds the enemy's information
local NoEnemies = 8             -- Number of enemies in a battle
local visible = {}              -- Determines if an enemy is visible

local Equip = {}
local SelectItem = {}
local SelectChar = {}

local MenuScreen = readByte(0x7E0143)
local point = readByte(0x7E0153)

--local DisplayBattleInfo =
local newEnemyReady = readByte(0x7E4000) ~= 0 and readByte(0x7E00DE) ~=0 -- Display Battle Information using EN1 'position'

local DisplayMenuScreen		= MenuScreen == 1  -- Display Menu
local DisplayAbilityScreen	= MenuScreen == 2  -- Display Ability screen info
local DisplayJobScreen 		= MenuScreen == 3  -- Display Job screen info
local DisplayEquipScreen 	= MenuScreen == 4  -- Display Equipment screen info
local DisplayStatusScreen 	= MenuScreen == 5  -- Display Status screen info
local DisplayItemScreen		= MenuScreen == 7  -- Display Item Screen Info
local DisplayMagicScreen	= MenuScreen == 8  -- Display Mag Screen Info
local DisplayGameStart		= MenuScreen == 85 -- @ game start, this is 85
local DisplayMap 			= DisplayMenuScreen -- Until I can tell the difference


local timer = 0                 -- In-game clock timer

local keydown = joypad.get(1)

local arena = readByte(0x7E04F2)

-- whenever the number of battles increases, then the battle starts
-- whenever the number of escapes increases, then the battle is over
-- TODO: (STILL) find a way to tell when battle is over w/o escapes
local newBattles = readByte(0x7E09C0)
local newEscapes = readByte(0x7E09B5)
oldEnemyReady = watch(newEnemyReady, oldEnemyReady, adjustBattleDisplay) -- ??
oldBattles = watch(newBattles, oldBattles, ShowBattleDisplay)
oldEscapes = watch(newEscapes, oldEscapes, HideBattleDisplay)


if TableMenuScreens[1+MenuScreen] ~= nil then
	gui.text (8,0, TableMenuScreens[1+MenuScreen],'green') -- Show which Menu is open
else
	gui.text (8,0, MenuScreen,'red') -- Show which Menu is open
end

-- if battle is paused
--if readByte(0x7E00A4) == 0 then
	--gui.text(0,0,"paused? " .. readByte(0x7E00A4), 'cyan')
--end

	--gui.text(0,16,"something ".. readByte(0x7E0134), "cyan")
	-- display arena name
	gui.transparency(1)

if arena < 33 then
		gui.text ( offsetX + 50, 0, TableBattleground[arena+1], "white")
	else
		gui.text ( offsetX + 50, 0, arena, "white")
end

-- Menus
-- Can't figure this out yet.
--DisplayAbilityScreen = false
if DisplayAbilityScreen then
	local AbX = 104
	local AbY = 160
	local spacer = 8
	local pointingAt = readByte(0x7E0153)
	local pageOffset = readByte(0x7E016B)
	local truePoint  = pointingAt + pageOffset-4

	SelectChar 	= WorldCharInfo(readByte(0x7E0171))
	local charNo = SelectChar.CharNo
	if charNo == 4 then charNo = 2 end -- Galuf/Krile

	local learnedAddress = (0x7E08f7 + 0x14*charNo)
	local learned = {}
	for i=0, 0x11 do
		learned[i+1] = readByte(learnedAddress+i)
	end
	drawBorderBox(96,154,150,58,'white','grey')
	gui.transparency(0)

	-- slot -1 : uh...
	gui.text(AbX,AbY+spacer*-1,truePoint)
	--gui.text(AbX,AbY+spacer*0,bit.tohex(learnedAddress,-6),'green')
	--gui.text(AbX,AbY+spacer*1,BitString(learned[1]))
	--gui.text(AbX,AbY+spacer*2,BitString(learned[2]))
	--gui.text(AbX,AbY+spacer*3,BitString(learned[3]))
	--gui.text(AbX,AbY+spacer*4,BitString(learned[4]))
	--gui.text(AbX,AbY+spacer*5,BitString(learned[5]))
	--gui.text(AbX,AbY+spacer*6,BitString(learned[6]),cPink)
	--gui.text(AbX+40,AbY+spacer*1,BitString(learned[7]),cLBlue)
	--gui.text(AbX+40,AbY+spacer*2,BitString(learned[8]),"white")
	--gui.text(AbX+40,AbY+spacer*3,BitString(learned[9]),"grey")
	--gui.text(AbX+40,AbY+spacer*4,BitString(learned[10]),"orange")
	--gui.text(AbX+40,AbY+spacer*5,BitString(learned[11]),cLGreen)
	--gui.text(AbX+40,AbY+spacer*6,BitString(learned[12]),'red')
	--gui.text(AbX+80,AbY+spacer*1,BitString(learned[13]),cBlue)
	--gui.text(AbX+80,AbY+spacer*2,BitString(learned[14]),cYellow)
	--gui.text(AbX+80,AbY+spacer*3,BitString(learned[15]),cYellow)
	--gui.text(AbX+80,AbY+spacer*4,BitString(learned[16]),cYellow)
	--gui.text(AbX+80,AbY+spacer*5,BitString(learned[17]),cYellow)
	--gui.text(AbX+80,AbY+spacer*6,BitString(learned[18]),cYellow)
end

if DisplayMagicScreen then -- Magic Screen Info

	local subMenu = splitTop(readByte(0x7E60D2),8) - 3
	local PointAt = readByte(0x7E0155)
	local SelectSpell = (18*subMenu)+PointAt-1

	gui.text( 8,200,"?"..subMenu,'cyan')
	--gui.text( 8,207,"?"..splitBot(readByte(0x7E60D2),8),'cyan')
	if SelectSpell < 0x48 and SelectSpell >= 0 then
		gui.text( 8,207,bit.tohex(SelectSpell,-2)..': '..TableMagicID[SelectSpell+1], cLGreen)
	end
	gui.text(32,200,"#"..SelectSpell,'cyan')
end

if DisplayItemScreen then -- Item Screen Info
	local pointingAt = readByte(0x7E0153)
	local pageOffset = readByte(0x7E016B)
	local truePoint  = pointingAt + pageOffset-4
	local itemAt	= readByte(0x7E0640 + truePoint)

	local ItemX  = 14
	local ItemXR = 136
	local ItemY  = 34
	local spacer = 8
	SelectItem = ItemInfo(itemAt)

	drawBorderBox(8,32,238,34,'white',cRed)
	gui.transparency(0)

	--gui.text(114,50, truePoint..': '..bit.tohex(itemAt,-2),'cyan','blue')
	--gui.text(114,56, SelectItem.itemType,cOrange)


	if SelectItem.itemType == 'weapon' then
		gui.text( ItemX , ItemY+spacer*-1, TableEquipmentType[SelectItem.EquipType+1],cOrange)
	 -- Slot 0 : Attack Power
		gui.text( ItemX , ItemY+spacer*0 , "Attack : ".. SelectItem.AttPow, 'yellow')
	 -- Slot 1 : Dbl Grip/Throw
		gui.text( ItemX , ItemY+spacer*1, readActiveBits(SelectItem.Double,TableDoubleGrip,2)
			..' '..throwCheck(SelectItem.Throwable), 'white')
	 -- Slot 2 : Properties
		gui.text( ItemX , ItemY+spacer*2, readActiveBits(SelectItem.Special ,TableWeaponProperty), 'green')
	 -- Slot 3 : Stats increased / Elemental Booster
		if SelectItem.StatsUpCheck == 1 then 	-- if showing stats
			if SelectItem.StatsUp > 0 then	-- if stats are actually increased
				gui.text(ItemX,ItemY+spacer*3,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,4) ..
						TableStatValue[SelectItem.StatsValue+1][1], cYellow)
			end
			if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
					gui.text(ItemXR,ItemY+spacer*3,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,-4) ..
						TableStatValue[SelectItem.StatsValue+1][2], 'grey')
			end
			-- else show boosted elements
		else gui.text(ItemX,ItemY+spacer*3, "Boosts : " .. readActiveBits(SelectItem.EleBoost,TableElement), cGreen)
		end
		gui.text( ItemXR , ItemY+spacer*0, TableAttackFormula[SelectItem.AttFormula+1], 'white')
		DisplayParameters(SelectItem,ItemXR,ItemY+spacer*1)
	end
	if SelectItem.itemType == 'armor' then
		gui.text ( ItemX , ItemY+spacer*-1, TableEquipmentType[SelectItem.EquipType+1],cOrange)
	-- Slot 0-Left : Defense
		gui.text(ItemX , ItemY+spacer*0, 	'Defense : ' .. SelectItem.Defense, 'white')
	-- Slot 0-Right: Evade
		gui.text(ItemXR , ItemY+spacer*0, 'Evade : ' .. SelectItem.Evade, 'white')
	-- Slot 1-Left : Magic Defense
		gui.text(ItemX , ItemY+spacer*1, 	'MDefense: ' .. SelectItem.MagDefense, 'white')
	-- Slot 1-Right: Magic Evade
		gui.text(ItemXR , ItemY+spacer*1, 'MEvade: ' .. SelectItem.MagEvade, 'white')
	-- Slot 2 : Special Armor Properties
		gui.text(ItemX , ItemY+spacer*2, readActiveBits(SelectItem.Special, TableArmorProperty), 'green')
	-- Slot 2-R: Equipment's Elemental Defense
		showEleDefense(ItemXR , ItemY+spacer*2,EleDefenseDef(SelectItem.EleDefense))
	-- Slot 3 : Stats increased / Elemental Booster
		if SelectItem.StatsUpCheck == 1 then 	-- if showing stats
			if SelectItem.StatsUp > 0 then	-- if stats are actually increased
				gui.text(ItemX , ItemY+spacer*3,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,4) ..
						TableStatValue[SelectItem.StatsValue+1][1], cYellow)
			end
			if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
					gui.text(ItemXR , ItemY+spacer*3,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,-4) ..
						TableStatValue[SelectItem.StatsValue+1][2], 'grey')
			end
			-- else show boosted elements
		else gui.text(ItemX , ItemY+spacer*3, "Boosts: " .. readActiveBits(SelectItem.EleBoost,TableElement), cGreen)


		end
	end
	if SelectItem.itemType == 'useable' then
		gui.text(ItemX , ItemY+spacer*0, TableAttackFormula[SelectItem.AttFormula+1], 'white')
		DisplayParameters(SelectItem,ItemX,ItemY+spacer*1)

		--gui.text(ItemX , ItemY+spacer*0, BitString(SelectItem.Target,8)..' '..readActiveBits(SelectItem.Target,TableTargeting),'white')
		--gui.text(ItemX , ItemY+spacer*1, BitString(SelectItem.AttackType,8)..' '..readActiveBits(SelectItem.AttackType,TableAttackType), 'yellow')
		--gui.text(ItemX , ItemY+spacer*2, BitString(SelectItem.Misc,8), 'cyan')
		--gui.text(ItemX , ItemY+spacer*3, BitString(SelectItem.Descript,8)..' '..bit.tohex(SelectItem.Descript,-2), 'green')
		--gui.text(ItemX , ItemY+spacer*4, BitString(SelectItem.AttAvoid,8)
		--    ..' '.. bit.tohex(SelectItem.AttFormula,-2)
		--	..' '.. TableAttackFormula[SelectItem.AttFormula+1],'white')
		--gui.text(ItemX , ItemY+spacer*5, BitString(SelectItem.Parameter1,8), cPurple)
		--gui.text(ItemX , ItemY+spacer*6, BitString(SelectItem.Parameter2,8), cPurple)
		--gui.text(ItemX , ItemY+spacer*7, BitString(SelectItem.Parameter3,8), cPurple)
	end


end
if DisplayGameStart then
	DisplayBattleInfo = false
	drawBorderBox( 0, 198, 254, 24, 'purple', cPurple)   -- Bottom Box
	gui.transparency(0)
	gui.text(2,198, 'Learning','white',0)
	gui.text(2,208, 'A FFV LUA script by Christopher','white',0)
	gui.text(2,216, '-------------------------------','white',0)

end

if DisplayStatusScreen then -- Status Screen Info
	local StatusX  = 14
	local StatusXR = 70
	local StatusY  = 100
	local Status2X = 129
	local Status2Y = 100
	local Status2XR = 190
	local spacer = 8

	SelectChar 	= WorldCharInfo(readByte(0x7E0171))

	drawBorderBox( 10 , 86, 114,  16, cLBlue, cBlue) -- Box
	drawBorderBox( 10 , 96, 114, 109) -- Left Box
	drawBorderBox( 125, 96, 122, 109)-- Right Box
	drawBorderBox( 0, 206, 254, 16, 'white', cDGreen)   -- Bottom Box
	gui.transparency(0)

	local charNo = SelectChar.CharNo
	if charNo == 4 then charNo = 2 end -- Galuf/Krile

	local N1 = 120 - SelectChar.EqAgi + math.floor(SelectChar.Weight/8)
	local Nexp = memory.readdword(0x7E2746)
	local capMonSpell = readByte(0xD08600+SelectChar.CapMonster)

	gui.text(StatusX,StatusY-12,readActiveBits(SelectChar.StatusC,TableStatusCurable),'cyan')

	-- Left Box --
	-- Slot 0 HP/MP
	gui.text(StatusX,StatusY+spacer*0,
		"HP: ".. LANum(SelectChar.CurrentHP,4).."/"..LANum(SelectChar.MaxHP,4), 'green')
	gui.text(StatusXR,StatusY+spacer*0,
		"MP: ".. LANum(SelectChar.CurrentMP,3).."/"..LANum(SelectChar.MaxMP,3), 'cyan')
	-- Slot 1-2 : EXP
	gui.text(StatusX,StatusY+spacer*1 ,"EXP: ".. LANum(SelectChar.Exp,8), 'red')
	gui.text(StatusXR,StatusY+spacer*1,"Next:".. LANum(Nexp,8), 'red')
	drawBorderBox(StatusX,StatusY+spacer*2, 108, 6, cRed,'black')
	drawBorderBox(StatusX,StatusY+spacer*2, 108*(SelectChar.Exp/(SelectChar.Exp+Nexp)), 6, cRed,cRed)
	gui.transparency(0)
	-- Slot 3 : # of Ability
	gui.text(StatusX,StatusY+spacer*3, "Abilities: "..readByte(0x7E08F3+ charNo), 'white')
	-- Slot 4-5 : Captured Monster
	if SelectChar.CapMonster ~= 255 then
		gui.text(StatusX,StatusY+spacer*4, "Capture: "..findEnemyName({Name=SelectChar.CapMonster}),cYellow)
		gui.text(StatusX,StatusY+spacer*5, "Release: ".. TableMagicID[capMonSpell+1],cYellow)
	else
		gui.text(StatusX,StatusY+spacer*4, "Capture: None",'grey')
	end

	-- Right Box --
	-- Slot 0-Left: Strength
	gui.text(Status2X, Status2Y+spacer*0, "Strength : "..SelectChar.EqStr, "white")
	-- Slot 1 : Agility..
	gui.text(Status2X, Status2Y+spacer*1, "Agility  : "..SelectChar.EqAgi, "white")
	-- Slot 2 : Vitality..
	gui.text(Status2X, Status2Y+spacer*2, "Vitality : "..SelectChar.EqVit, "white")
	-- Slot 3 : Magic Power..
	gui.text(Status2X, Status2Y+spacer*3, "Magic Pow: "..SelectChar.EqMag, "white")
	 -- Slot 0-Right : Total AttPow
	gui.text(Status2XR, Status2Y+spacer*0, 'Attack : '..SelectChar.AttPow, 'white')
	 -- Slot 1-Right : Total Def..
	gui.text(Status2XR, Status2Y+spacer*1, 'Defense: '..SelectChar.Def, 'white')
	 -- Slot 2-Right : Total Evade..
	gui.text(Status2XR, Status2Y+spacer*2, 'Evade  : '..SelectChar.Evade, 'white')
	 -- Slot 3-Right : Total MagDef..
	gui.text(Status2XR, Status2Y+spacer*3, 'M Def  : '..SelectChar.MagDef, 'white')
	-- Slot 4-Right : Total MagEvade..
	gui.text(Status2XR, Status2Y+spacer*4, 'M Evade: '..SelectChar.MagEvade, 'white')
	-- Slot 4 : Character's total Elemental Defense
	showEleDefense(Status2X,Status2Y+spacer*4,SelectChar)
	-- Slot 5 : Equip Weight
	gui.text(Status2X, Status2Y+spacer*5, 'Eq Weight: '..SelectChar.Weight, 'white')
	-- Slot 5-R: ATB bar prefill
	gui.text(Status2XR, Status2Y+spacer*5, 'ATB : '..255-N1, cPink)
	-- Bottom Box : Inate passives
	gui.text(2,208, readActiveBits(SelectChar.Passive1,TablePassive1),'green')
	gui.text(2,215, readActiveBits(SelectChar.Passive2,TablePassive2),'green')

end

if DisplayJobScreen then -- Job Screen Information
	local JobX = 12
	local JobY = 168
	local spacer = 8

	-- selected char
	SelectChar 	= WorldCharInfo(readByte(0x7E0171))
	SelectedJob 		= JobInfo(readByte(0x7E01D8))

	-- address for job info in RAM
	local jInfoAddress = readByte(0x7E0171)*0x2C + 0x7E0843
	-- Level of selected Job
	local jLevel = splitBot(readByte(jInfoAddress+0x1 + SelectedJob.index * 0x2),16)
	-- current APB of selected Job
	local jAPB =  readByte(jInfoAddress + SelectedJob.index * 0x2)
				+splitTop(readByte(jInfoAddress+0x1 + SelectedJob.index * 0x2),16)*256
	-- address for APB needed for JOB level; displayed by game
	local next = readWord(0x7E01DE)
	-- Base stats (mod values, I assume)


	drawBorderBox(8,164,238,50,'white','grey')
	gui.transparency(0)
	-- Slot -1 : Job Name
	gui.text(JobX,JobY+spacer*-1, TableJob[SelectedJob.index+1],'yellow')
	-- Slot -1 : stat adjustment (24 is base stat for Freelancer/Mimic)
	gui.text(JobX+65+spacer*0 ,JobY+spacer*-1, "Str:"..SelectedJob.BaseStr-24, "red")
	gui.text(JobX+65+spacer*4 ,JobY+spacer*-1, "Agi:"..SelectedJob.BaseAgi-24, "yellow")
	gui.text(JobX+65+spacer*8 ,JobY+spacer*-1, "Vit:"..SelectedJob.BaseVit-24, cLBlue)
	gui.text(JobX+65+spacer*12,JobY+spacer*-1, "Mag:"..SelectedJob.BaseMag-24, cPurple)
	-- Slot 0 : Number of Job Levels
	gui.text(JobX,JobY+spacer*0, 'Level '..jLevel.. '/'..SelectedJob.NumOfAbility, 'white')
	-- Slot 0 Right : APB
	if jLevel < SelectedJob.NumOfAbility then
		gui.text(JobX+65,JobY+spacer*0, LANum(jAPB,3)..'/'..next, cPink)
	else if SelectedJob.NumOfAbility > 0 then
		gui.text(JobX+65,JobY+spacer*0, "*MASTER*", cYellow,cRed)
		end
	end
	-- Slot 1-4 : Native Ability
	gui.text(JobX,JobY+spacer*1, TableJobLevel[SelectedJob.Native1+1], cLBlue)
	gui.text(JobX,JobY+spacer*2, TableJobLevel[SelectedJob.Native2+1], cLBlue)
	gui.text(JobX,JobY+spacer*3, TableJobLevel[SelectedJob.Native3+1], cLBlue)
	gui.text(JobX,JobY+spacer*4, TableJobLevel[SelectedJob.Native4+1], cLBlue)
	-- Slot 5 Passive Abilites
	gui.text(JobX,JobY+spacer*5, readActiveBits(SelectedJob.Passive1,TablePassive1)..
								 readActiveBits(SelectedJob.Passive2,TablePassive2),'green')
	-- gui.text(JobX,JobY+spacer*1, bit.tohex(SelectedJob.FirstAbility,-2)  , 'white')
	-- Slots 1-4 Right: Job Levels
	for i=1, SelectedJob.NumOfAbility do
		local learnedAbility = 'black'
		local j= i-1
		local jlvl = SelectedJob.FirstAbility + (j * 3)
		local APNeeded = readWord(0xD10000+ jlvl)
		local ability = readByte(0xD10000+ jlvl + 0x2)

		if j<jLevel then learnedAbility = cRed end

		gui.text(JobX+65+75*math.floor(j/4),JobY+spacer*((j%4)+1), LANum(APNeeded,3)..': ', cOrange)
		gui.text(JobX+81+75*math.floor(j/4),JobY+spacer*((j%4)+1), TableJobLevel[ability+1], 'white',learnedAbility)
	end
end

if DisplayEquipScreen then -- Equipment Screen Information
	-- Some information comes from Equipment screen (RAM)
	Equip = EquipPreviewInfo()

	SelectChar 	= WorldCharInfo(readByte(0x7E0171))

	-- Most information comes from the item pointed at (ROM)
	if point >= 10 then SelectItem = ItemInfo(readByte(0x7E0172)) else
	if point <  10 then SelectItem = ItemInfo(00) end
	if point == 00 then SelectItem = ItemInfo(math.max(SelectChar.RHandShield,SelectChar.RHand)) end -- Rhand
	if point == 01 then SelectItem = ItemInfo(math.max(SelectChar.LHandShield,SelectChar.LHand)) end -- Lhand
	if point == 02 then SelectItem = ItemInfo(SelectChar.Head) end -- Head
	if point == 03 then SelectItem = ItemInfo(SelectChar.Body) end -- Body
	if point == 04 then SelectItem = ItemInfo(SelectChar.Relic) end -- Accessory
	end
	local EquipX = 125
	local EquipY = 100
	local EquipXR = 195
	local spacer = 8

   drawBorderBox( 120, 96, 126,  126, 'white','grey')
   -- This Equipment Box gives 15 slots (starting @ 0)
	gui.transparency(0)

	-- Slot -1 (on top border) :  Item Index
	gui.text(EquipX,EquipY+spacer*-1, bit.tohex(SelectItem.index,-2), "cyan")

	if SelectItem.itemType == 'weapon' then
	 -- Slot 5 : Equipment Type
		gui.text(EquipX,EquipY+spacer*5, TableEquipmentType[SelectItem.EquipType+1],cOrange)
	 -- Slot 6-Left : DoubleGrip Info
		gui.text(EquipX,EquipY+spacer*6, readActiveBits(SelectItem.Double,TableDoubleGrip,2), 'white')
	 -- Slot 6-Right: Throwable
		gui.text(EquipXR,EquipY+spacer*6,throwCheck(SelectItem.Throwable),'white')
	 -- Slot 7-Left : Attack Power
		gui.text(EquipX,EquipY+spacer*7, 'WeapPow: '..SelectItem.AttPow, 'white')
	 -- Slot 7-Right: Attack Type (Phys, Aerial, Black, Song)
		gui.text(EquipXR,EquipY+spacer*7, readActiveBits(SelectItem.AttackType,TableAttackType),'yellow')
	 -- Slot 8 : Special Weapon Properties
		gui.text(EquipX,EquipY+spacer*8, readActiveBits(SelectItem.Special ,TableWeaponProperty), 'green')
	 -- Slot 9 : Spell when used as item
		if SelectItem.Used ~= 0x78 then
			gui.text(EquipX,EquipY+spacer*9, "USE: "..TableMagicID[SelectItem.Used+1], 'cyan')
		end
	 -- Slot 9-additional : Breaks when used
		if SelectItem.Break >0 and SelectItem.index ~= 0x60 then -- Wonderwand flaged as break, but it doesn't
			gui.text(EquipX+90,EquipY+spacer*9, 'Breaks', 'red')
		end
	 -- Slots 10 : Attack Formula
		gui.text(EquipX,EquipY+spacer*10, TableAttackFormula[SelectItem.AttFormula+1], 'white')
	 -- Slots 11-13 : Parameters for the attack formula
		DisplayParameters(SelectItem,EquipX,EquipY+spacer*11)
	 -- Slot 14 : Stats increased / Elemental Booster
		if SelectItem.StatsUpCheck == 1 then 	-- if showing stats
			if SelectItem.StatsUp > 0 then	-- if stats are actually increased
				gui.text(EquipX,EquipY+spacer*14,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,4) ..
						TableStatValue[SelectItem.StatsValue+1][1], cYellow)
			end
			if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
					gui.text(EquipXR,EquipY+spacer*14,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,-4) ..
						TableStatValue[SelectItem.StatsValue+1][2], 'grey')
			end
			-- else show boosted elements
		else gui.text(EquipX,EquipY+spacer*14, "Boosts: " .. readActiveBits(SelectItem.EleBoost,TableElement), cGreen)

		end
	end

	if SelectItem.itemType == 'armor' then
	-- Slot 5-Left : Equipment Type
		gui.text(EquipX,EquipY+spacer*5, TableEquipmentType[SelectItem.EquipType+1],'orange')
	-- Slot 5-Right: Weight
		gui.text(EquipXR,EquipY+spacer*5, 'Weight: ' .. SelectItem.Weight, 'white')
	-- Slot 6-Left : Defense
		gui.text(EquipX,EquipY+spacer*6, 	'Defense : ' .. SelectItem.Defense, 'white')
	-- Slot 6-Right: Evade
		gui.text(EquipXR,EquipY+spacer*6, 'Evade : ' .. SelectItem.Evade, 'white')
	-- Slot 7-Left : Magic Defense
		gui.text(EquipX,EquipY+spacer*7, 	'MDefense: ' .. SelectItem.MagDefense, 'white')
	-- Slot 7-Right: Magic Evade
		gui.text(EquipXR,EquipY+spacer*7, 'MEvade: ' .. SelectItem.MagEvade, 'white')
	-- Slot 8 : Special Armor Properties
		gui.text(EquipX,EquipY+spacer*8, readActiveBits(SelectItem.Special, TableArmorProperty), 'green')
	-- Slot 9 : Equipment's Elemental Defense
		showEleDefense(EquipX,EquipY+spacer*9,EleDefenseDef(SelectItem.EleDefense))
	-- Slots 10-13 : Status Prop
		--gui.text(EquipX-5,EquipY+spacer*10, SelectItem.StatusProp, cBlue)
		showStatusProp(StatDefenseDef(SelectItem.StatusProp),EquipX,EquipY+spacer*10)
	-- Slot 14 : Stats increased / Elemental Booster
		if SelectItem.StatsUpCheck == 1 then 	-- if showing stats
			if SelectItem.StatsUp > 0 then	-- if stats are actually increased
				gui.text(EquipX,EquipY+spacer*14,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,4) ..
						TableStatValue[SelectItem.StatsValue+1][1], cYellow)
			end
			if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
					gui.text(EquipXR,EquipY+spacer*14,
						readActiveBits(SelectItem.StatsUp,TableStatBonus,-4) ..
						TableStatValue[SelectItem.StatsValue+1][2], 'grey')
			end
			-- else show boosted elements
		else gui.text(EquipX,EquipY+spacer*14, "Boosts: " .. readActiveBits(SelectItem.EleBoost,TableElement), cGreen)


		end
	end

	if SelectItem.itemType == 'Nothing' or SelectItem.EquipType == 0 or point < 10 then
	-- Slot 0-Left: Strength
	gui.text(EquipX, EquipY+spacer*0, "Strength : "..SelectChar.EqStr, "white")
	-- Slot 1 : Agility..
	gui.text(EquipX, EquipY+spacer*1, "Agility  : "..SelectChar.EqAgi, "white")
	-- Slot 2 : Vitality..
	gui.text(EquipX, EquipY+spacer*2, "Vitality : "..SelectChar.EqVit, "white")
	-- Slot 3 : Magic Power..
	gui.text(EquipX, EquipY+spacer*3, "Magic Pow: "..SelectChar.EqMag, "white")
	 -- Slot 0-Right : Total AttPow
	gui.text(EquipXR, EquipY+spacer*0, 'Att: '..SelectChar.AttPow, 'white')
	 -- Slot 1-Right : Total Def..
	gui.text(EquipXR, EquipY+spacer*1, 'Def: '..SelectChar.Def, 'white')
	 -- Slot 2-Right : Total Evade..
	gui.text(EquipXR, EquipY+spacer*2, 'Eva: '..SelectChar.Evade, 'white')
	 -- Slot 3-Right : Total MagDef..
	gui.text(EquipXR, EquipY+spacer*3, 'MDF: '..SelectChar.MagDef, 'white')
	 -- Slot 4-Right : Total MagEvade..
	gui.text(EquipXR, EquipY+spacer*4, 'MEV: '..SelectChar.MagEvade, 'white')
	else
	-- Slot 0-Left: Strength
	showCompare(EquipX, EquipY+spacer*0, "Strength :",SelectChar.EqStr, Equip.Str, "white")
	-- Slot 1 : Agility
	showCompare(EquipX, EquipY+spacer*1, "Agility  :",SelectChar.EqAgi, Equip.Agi, "white")
	-- Slot 2 : Vitality
	showCompare(EquipX, EquipY+spacer*2, "Vitality :",SelectChar.EqVit, Equip.Vit, "white")
	-- Slot 3 : Magic Power
	showCompare(EquipX, EquipY+spacer*3, "Magic Pow:",SelectChar.EqMag, Equip.Mag, "white")
	 -- Slot 0-Right : Total AttPow
	showCompare(EquipXR, EquipY+spacer*0, 'Att:',SelectChar.AttPow, Equip.AttPow, 'white',3)
	 -- Slot 1-Right : Total Def
	showCompare(EquipXR, EquipY+spacer*1, 'Def:',SelectChar.Def, Equip.Def, 'white')
	 -- Slot 2-Right : Total Evade
	showCompare(EquipXR, EquipY+spacer*2, 'Eva:',SelectChar.Evade, Equip.Eva, 'white')
	 -- Slot 3-Right : Total MagDef
	showCompare(EquipXR, EquipY+spacer*3, 'MDF:',SelectChar.MagDef, Equip.MagDef, 'white')
	 -- Slot 4-Right : Total MagEvade
	showCompare(EquipXR, EquipY+spacer*4, 'MEV:',SelectChar.MagEvade, findNewMagEva(SelectChar, SelectItem, point), 'white')
	end
	-- Slot 4 : Character's total Elemental Defense
	showEleDefense(EquipX,EquipY+spacer*4,Equip)
end

-- Battle!
if DisplayBattleInfo then

	local critHP = ""				-- If enemy HP is in capture range

	 -- Draws character's Box
	drawBorderBox( 104, 159, 143,  55, 'white')

	-- Draws enemy's Box
	--drawBorderBox(   9, 159,  94,  55, 'white')

	-- swap battlepages
	-- battlePage  is for character info
	-- enemyPage is for enemy info

	if keydown.R and RDown == false then
		RDown = true
		battlePage = battlePage +1
	end
	if keydown.R == false then
		RDown = false
	end
	if keydown.L and LDown == false then
		LDown = true
		enemyPage = enemyPage +1
	end
	if keydown.L == false then
		LDown = false
	end
	if keydown.select and SelDown == false then
		SelDown = true
		Flippy = (Flippy ~= true)
	end
	if keydown.select == false then
		SelDown = false
	end

	if battlePage > battlePageMax then
		battlePage = 0
	end
	if enemyPage > enemyPageMax then
		enemyPage = 0
	end

	-- Display current enemyPage
	gui.text(10, 154, positionString(enemyPage, enemyPageMax),'red')
	-- Display current battlepage
	gui.text(108, 154, positionString(battlePage, battlePageMax),'white')

	-- Determine which enemies are hidden or visible
	--visible = BitOn( readByte(0x7E3EF2), 8) -- initial visible? when formations change, this doesn't reflect
	visible = BitOn( readByte(0x7E00DE), 8) -- currently visible

	local boxwidth = 60             -- Enemy's ATB box width

	for i=1,NoEnemies do
		-- Populate the enemy's information
		enemy[i] = EnemyInfo(i)

		-- Display the enemy's information
		-- Need to find a way to hide info when running away from battle

	if visible[9-i] == 1 and enemy[i].Name ~= 65535 then
		-- HP - shows "1) HP:50/100"
		critHP = "white"
		if enemy[i].CurrentHp <= enemy[i].TotalHp/2 then
			critHP = "yellow"
		end
		if enemy[i].CurrentHp <= enemy[i].TotalHp/8 then
			critHP = "orange"
		end

		local enX = determineX(10*enemy[i].PositionX)
		local enY = 10*enemy[i].PositionY

		gui.text ( offsetX + (enX) ,
				   offsetY + (enY) + 0*(gapY),
				   i .. ') HP: ' .. enemy[i].CurrentHp .. '/' .. enemy[i].TotalHp,
				   critHP)
		-- Name & Level - shows "L1 Goblin "
		gui.text ( offsetX + (enX) ,
				   offsetY + (enY) + -1*(gapY),
				   'L' .. enemy[i].Level .. ' ' .. findEnemyName(enemy[i]),
				   "white")

		gui.transparency(1)
		-- Attack Gauge (painted)
		gui.drawbox( offsetX + (enX),
					 offsetY + (enY) + 1*(gapY),
					 offsetX + (enX) + boxwidth,
					 offsetY + (enY) + 1*(gapY) + 2,
					 'yellow')
		gui.drawbox( offsetX + (enX) + boxwidth*(enemy[i].AttackGauge / 128),
					 offsetY + (enY) + 1*(gapY),
					 offsetX + (enX) + boxwidth,
					 offsetY + (enY) + 1*(gapY) + 2,
					 'black')


		-- Enemy Status Effects
		if enemyPage == 0 then
			-- Status
			if enemy[i].StatusC > 0 then -- Curable
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						readActiveBits(enemy[i].StatusC, TableStatusC),
						"cyan")
			enemy[i].statusgap = enemy[i].statusgap+1
			end

			if enemy[i].StatusD > 0 then -- Dispel
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						readActiveBits(enemy[i].StatusD, TableStatusD),
						"magenta")
			enemy[i].statusgap = enemy[i].statusgap+1
			end

			if enemy[i].StatusT > 0 then -- Temporary
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						readActiveBits(enemy[i].StatusT, TableStatusT),
						"red")
			enemy[i].statusgap = enemy[i].statusgap+1
			end

			if enemy[i].StatusP > 0 then -- Perm
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						readActiveBits(enemy[i].StatusP, TableStatusP),
						"yellow")
			end
		end

		-- Enemy Creature Type
		if enemyPage == 1 then
			gui.text ( offsetX - 25 + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
				   "Type: " .. readActiveBits(enemy[i].Type, TableCreature),
				   "white")
		end

		-- Enemy Elemental Affinities
		if enemyPage == 2 then
			showEleDefense(	offsetX + (enX),
							offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
							enemy[i])
		end

		-- Enemy Status Immunities
		if enemyPage == 3 then
			gui.text ( offsetX + (enX )- 20 ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						"Imm",
						cPink)
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						string.lower(readActiveBits(enemy[i].ImmuneC, TableStatusC)),
						cPink)
			enemy[i].statusgap = enemy[i].statusgap+1
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						string.lower(readActiveBits(enemy[i].ImmuneD, TableStatusD)),
						cPink)
			enemy[i].statusgap = enemy[i].statusgap+1
			gui.text ( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						string.lower(readActiveBits(enemy[i].ImmuneT, TableStatusT)),
						cPink)
			enemy[i].statusgap = enemy[i].statusgap+1
		end

		-- Stealables
		if enemyPage == 4 then

			-- Enemy MP (you can steal it!)
			if enemy[i].CurrentMp > 0 then
				gui.text ( offsetX + (enX) ,
						offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						enemy[i].CurrentMp .. " MP", "cyan")
				enemy[i].statusgap = enemy[i].statusgap+1
			end
			-- common steal
			gui.text ( offsetX + (enX )- 25 ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						"Steal", cYellow)
			gui.text( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
					   TableItemID[enemy[i].StealCommon+1], cYellow)
			enemy[i].statusgap = enemy[i].statusgap+1
			-- rare steal
			gui.text ( offsetX + (enX )- 25 ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
						" Rare", cYellow)
			gui.text( offsetX + (enX) ,
					   offsetY + (enY) + enemy[i].statusgap*(gapY)-3,
					   TableItemID[enemy[i].StealRare+1], cYellow)
		end
		end
	end


	for i=1,NoCharacters do
		gui.transparency(0)     -- Have no transparency

		-- Populate the character's information
		character[i] = CharacterInfo(i)
	-- Display the character's information
		if math.floor(character[i].Character / 0x40) % 2 == 0 then  -- Display only info of current party
			gui.text ( 108,
					   154 + 12*i,
					   'L' .. character[i].Level ..' '.. TableCharacter[(character[i].Character) % 8 + 1],
					 "white")

		if battlePage == 0 then -- Cureable and Dispellable Status
			gui.text (108 , 210 , "Status C", "cyan")
			gui.text (147, 151 + 12*i,
				'- ' .. readStatus(character[i].StatusC, character[i].InitialC, TableStatusC), "cyan")
			gui.text (108 , 216 , "Status D", "magenta")
			gui.text (147, 157 + 12*i,
				'- ' .. readStatus(character[i].StatusD, character[i].InitialD, TableStatusD), "magenta")
		end
		if battlePage == 1 then -- Temp and Perm Status
			gui.text (108 , 210 , "Status T", "red")
			gui.text (147, 151 + 12*i,
				'- ' .. readStatus(character[i].StatusT, character[i].InitialT, TableStatusT), "red")
			gui.text (108 , 216 , "Status P", "yellow")
			gui.text (147, 157 + 12*i,
				'- ' .. readActiveBits(character[i].StatusP, TableStatusP), "yellow")
		end
		if battlePage == 2 then -- Elemental Defense
			gui.text (108 , 210 , "Element Def *:abs 0:imm #:half X:weak", "orange")
			showEleDefense(150, 154 + 12*i,character[i])
		end
		if battlePage == 3 then -- Elemental Damage Boost
			gui.text (108 , 210 , "Element Damage Boost", "green")
			gui.text (147, 154 + 12*i,
				'+ ' .. readActiveBits(character[i].ElementBoost, TableElement), "green")
		end
		if battlePage == 4 then -- Song Stat +
			gui.text (147, 154 + 12*i, "L+"..character[i].HeroSong,"green")
			gui.text (167, 154 + 12*i, "A+"..character[i].SpeedSong,"yellow")
			gui.text (187, 154 + 12*i, "s+"..character[i].PowSong,"red")
			gui.text (207, 154 + 12*i, "M+"..character[i].MagSong,cPurple)
			gui.text (108 , 210 , "Song Boosts", cPink)
		end
		gui.transparency(1)     -- Have small transparency
		-- Display characters' HP & MP
		gui.text ( determineX(215),
				   47 + 24*i,
				   character[i].CurrentHp .. '/' .. character[i].TotalHp,
				 "green")

		gui.text ( determineX(215),
				   54 + 24*i,
				   character[i].CurrentMp .. '/' .. character[i].TotalMp,
				 "cyan")
		 end
	end
else
	Flippy = false;
end


if DisplayMap then
gui.transparency(0)     -- Have no transparency
	local RightLine = 212
	if keydown.R and RDown == false then
		RDown = true
		mapPage = mapPage +1
	end
	if keydown.R == false then
		RDown = false
	end
	if mapPage > mapPageMax then
		mapPage = 0
	end

	-- Display current mapPage
	gui.text(	offsetX + RightLine,
				offsetY + 0*(gapY), positionString(mapPage, mapPageMax),'white')
	if mapPage == 0 then
		local gil = readRange(0x7E0947,3) -- Gil, three bytes
		-- GIL
		gui.text (	offsetX + RightLine,
					offsetY + 1*(gapY), "$"..gil,cYellow)

		-- In-game clock timer
		 gui.text ( offsetX + RightLine,
				   offsetY + 2*(gapY),
		 		   MakeTime(memory.readdword(0x7E094A)), "red" )
		-- In-game event timer
		--gui.text ( offsetX + RightLine,
		--		   offsetY + 2*(gapY),
		--		   LANum(readWord(0x7E0AFC),7) )

		-- # of steps in world map
		--gui.text ( offsetX + RightLine,
		--		   offsetY + 2*(gapY),
		--		   readByte(0x7E16A9) )

		-- Coordinates
		gui.text ( offsetX + RightLine,
				   offsetY + 3*(gapY),
				   ""..readByte(0x7E0AD8) .. ',' .. readByte(0x7E0AD9))
	end
	if mapPage == 1 then
		local escapes = readByte(0x7E09B5)
		local battles = readByte(0x7E09C0)
		local saves   = readByte(0x7E09C2)
		-- # of battles
		gui.text ( offsetX + RightLine,
				   offsetY + 1*(gapY),
				   "Battles:"..battles, cYellow )

		-- # of escapes
		gui.text ( offsetX + RightLine,
				   offsetY + 2*(gapY),
				   "Escapes:"..escapes,cOrange )

		-- # of saves
		gui.text ( offsetX + RightLine,
				   offsetY + 3*(gapY),
				   "Saves  :"..saves, cLBlue )
	end
	if mapPage == 2 then
		local BocoX		= readByte(0x7E0ADF)
		local BocoY		= readByte(0x7E0AE0)
		local DragonX	= readByte(0x7E0AE7)
		local DragonY	= readByte(0x7E0AE8)
		local JocoX		= readByte(0x7E0AE3)
		local JocoY		= readByte(0x7E0AE4)
		local AirshipX	= readByte(0x7E0AF3)
		local AirshipY	= readByte(0x7E0AF4)

		--  Boco oordinates
		gui.text ( offsetX + RightLine - 20,
					offsetY + 1*gapY,
					"Boco:", cYellow)
		gui.text ( offsetX + RightLine,
				   offsetY + 1*(gapY),
				   ""..BocoX .. ',' .. BocoY, cYellow)
		-- Airship oordinates
		gui.text ( offsetX + RightLine - 32,
					offsetY + 2*gapY,
					"Airship:", cTan)
		gui.text ( offsetX + RightLine,
				   offsetY + 2*(gapY),
				   ""..AirshipX .. ',' .. AirshipY, cTan)
		-- Airship oordinates
		gui.text ( offsetX + RightLine - 32,
					offsetY + 3*gapY,
					"Blackie:", cPurple)
		gui.text ( offsetX + RightLine,
				   offsetY + 3*(gapY),
				   ""..JocoX .. ',' .. JocoY, cPurple)

	end
end
snes9x.frameadvance()

end
