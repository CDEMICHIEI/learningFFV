-- -------------------------- 	--
-- Learning 					--
-- Final Fantasy V LUA script 	--
--                            	--
-- By Christopher DeMichiei  	--
-- -------------------------- 	--
-- original by samurai goroh

require "Learning_TableData"
-- ------- --
-- GLOBALS --
-- ------- --

wwidth = 256 -- window width
wheight = 224 -- window height
offsetX = 0 -- To move things in coord X
offsetY = 0 -- To move things in coord Y
gapX = 7 -- Text gap in coord X
gapY = 7 -- Text gap in coord Y

battlePage = 0 -- 'page' battle info
battlePageMax = 4
enemyPage = 0 -- 'page' battle info
enemyPageMax = 4
mapPage = 0
mapPageMax = 2

RDown = false -- RDOWN
LDown = false
SelDown = false
Flippy = false -- Flip Enemy pos on back attack

-- colors, just because
c = {
  Red = 0xC41F3BFF,
  Orange = 0xFF7D0AFF,
  Green = 0xABD473FF,
  Cyan = 0x69CCF0FF,
  Lime = 0x00FF96FF,
  Green = 0x008833FF,
  Pink = 0xF58CBAFF,
  Yellow = 0xFFF569FF,
  Blue = 0x0070DEFF,
  Purple = 0x9482C9FF,
  Tan = 0xC79C6EFF,
  Brown = 0x906C3FFF
}

readByte = memory.readbyte
readWord = memory.readword
readDWord = memory.readdword

DisplayBattleInfo = false
oldBattles = readByte(0x7E09C0)
oldEscapes = readByte(0x7E09B5)
oldEnemyReady = 0


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


-- Convert number to binary table
function getBitTable(number, size)
  local bit = {}
  local pos = 0

  for i = 1, size do
    bit[i] = 0
  end

  while number > 0 do
    pos = pos + 1
    if number % 2 == 1 then
      bit[pos] = 1
    end
    number = math.floor(number / 2)
  end

  return bit
end

-- Convert number to an inverted binary table (swap 1 and 0)
function getInvertedBitTable(number, size)
  local bit = {}
  local pos = 0

  for i = 1, size do
    bit[i] = 1
  end

  while number > 0 do
    pos = pos + 1
    if number % 2 == 1 then
      bit[pos] = 0
    end
    number = math.floor(number / 2)
  end

  return bit
end

-- Convert number to binary string
function getBitString(number, size)
  if size == nil then size = 8 end
  local b = getBitTable(number, size)
  local str = readBits(b)
  return str
end

-- Return string of number, padded at the start with char
function PadNum(num, ...)
  local len, pad = ...
  -- default len 2, pad = ' '
  if len == nil then len = 2 end
  if pad == nil then pad = ' ' end
  local s = tostring(num)
  local tot = len - #s
  -- pad start
  for i = 1, tot do
    s = pad .. s
  end
  return s
end

-- return a Color dependent on greater number
function HiLoColor(n1, n2)
  if n1 > n2 then return 'red' end
  if n1 < n2 then return 'green' end
  if n1 == n2 then return 'white' end
end

-- Display string comparing n1 & n2 @ x,y
function showCompare(x, y, s, n1, n2, color, ...)
  local len = ...
  if len == nil then len = 2 end
  local s1 = tostring(n1)
  local s2 = tostring(n2)

  gui.text(x, y, (s..' '), color)
  gui.text(x + (#s + 1) * 4, y, PadNum(n1, len), color)
  gui.text(x + (#s + 1) * 4 + (len) * 4, y, "|"..PadNum(n2, len), HiLoColor(n1, n2))
end

-- return string showing values for active bits; size for getBitTable optional
function readActiveBits(v, t, ...)
  local str = ''
  local size = ...
  local s = {}
  if size == nil then size = 8
  end
  if size > 0 then s = getBitTable(v, size) end
  if size < 0 then s = getInvertedBitTable(v, - size) end
  local len = #s

  for i = 1, len do
    if s[i] == 1 then
      str = str .. t[i].. ' '
    end
  end

  return str
end

-- return getBitTable table as 001101 or such
function readBits(s, ...)
  local str = table.concat(s)
  return str
end

-- return actors' active status effects. CAPS if status is initial
function readStatus(s1, s2, t)
  local str = ''
  local status1 = getBitTable(s1, 8)
  local status2 = getBitTable(s2, 8)
  local l = #status1
  -- table.concat quits early on a nil value
  local newT = {'', '', '', '', '', '', '', ''}

  for i = 1, l do
    if status1[i] == 1 then
      newT[i] = t[i]..' '
    end
  end

  for i = 1, l do
    if status2[i] == 1 then
      newT[i] = string.upper(t[i])..' '
    end
  end

  str = table.concat(newT)

  return str
end


-- return Equipment status Info. +CAPS if status is initial
function readEqStatus(s1, s2, t)
  local str = ''
  local status1 = getBitTable(s1, 8)
  local status2 = getBitTable(s2, 8)
  local l = #status1
  -- table.concat quits early on a nil value
  local newT = {'', '', '', '', '', '', '', ''}

  for i = 1, l do
    if status1[i] == 1 then
      newT[i] = "-"..string.lower(t[i])
    end
  end

  for i = 1, l do
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
  local rawsec = math.floor(n / 60)
  local seconds = rawsec%60
  -- 60 sec/min
  local rawmin = math.floor(rawsec / 60)
  local minutes = rawmin%60
  -- 60 min/hour
  local rawhour = math.floor(rawmin / 60)
  local hours = rawhour%60
  -- 24 hour/day
  local rawday = math.floor(rawhour / 24)

  local hoursFront = ''
  if hours > 0 then hoursFront = hours..":" end
  return hoursFront..PadNum(minutes, 2, '0')..":"..PadNum(seconds, 2, '0')
end

-- finds an enemy name; returns number if name is not on table
function findEnemyName(en)
  local N = TableEnemy[en.Name + 1]

  if N ~= nil then
    return N
  else
    return en.Name
  end
end

-- read Elemetal Defense bits and return symbol
function readEleDefense(C, x)
  local weak = getBitTable(C.ElementWeakness, 8)
  local half = getBitTable(C.ElementHalf, 8)
  local immu = getBitTable(C.ElementImmune, 8)
  local abso = getBitTable(C.ElementAbsorb, 8)
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

-- show Elemental Def table at location @ x,y
function showEleDefense(x, y, a)
  gui.text (x + 0, y, readEleDefense( a, 1), "red") -- Fire
  gui.text (x + 5, y, readEleDefense( a, 2), "cyan") -- Ice
  gui.text (x + 10, y, readEleDefense( a, 3), "yellow") -- Lit
  gui.text (x + 15, y, readEleDefense( a, 4), c.Purple) -- Poison
  gui.text (x + 20, y, readEleDefense( a, 5), "white") -- Holy
  gui.text (x + 25, y, readEleDefense( a, 6), c.Tan) -- Earth
  gui.text (x + 30, y, readEleDefense( a, 7), c.Green) -- Wind
  gui.text (x + 35, y, readEleDefense( a, 8), c.Blue) -- Water
end

-- show which status effects equpiment give/blocks @ x,y
function showStatusProp(a, x, y)
  gui.text (x, y + 00, readEqStatus(a.ImmuneC, a.InitialC, TableStatusCurable), 'cyan')
  gui.text (x, y + 08, readEqStatus(a.ImmuneT, a.InitialT, TableStatusTemporary), 'magenta')
  gui.text (x, y + 16, readEqStatus(a.ImmuneD, a.InitialD, TableStatusDispellable), 'red')
  gui.text (x, y + 24, readEqStatus(0, a.InitialP, TableStatusP), 'yellow')
end

-- Armours' Elemental Defense Definition
function EleDefenseDef(n)
  local def = {}
  local address = 0xD12580 + (n * 5)

  def = {
    ElementAbsorb = readByte(address + 0x0),
    ElementEvade = readByte(address + 0x1),
    ElementImmune = readByte(address + 0x2),
    ElementHalf = readByte(address + 0x3),
    ElementWeakness = readByte(address + 0x4),
  }

  return def
end


-- Armours' Staus Defense Definition
function StatDefenseDef(n)
  local def = {}
  local address = 0xD126C0 + (n * 7)

  def = {
    InitialC = readByte(address + 0x0),
    InitialT = readByte(address + 0x1),
    InitialD = readByte(address + 0x2),
    InitialP = readByte(address + 0x3),
    ImmuneC = readByte(address + 0x4),
    ImmuneT = readByte(address + 0x5),
    ImmuneD = readByte(address + 0x6),
  }

  return def
end

-- Display information about att formula parameters @ x,y
function DisplayParameters(o, x, y)
  local results = getParameters(o)
  local color = c.Cyan
  gui.text(x, y, results[1], color)
  gui.text(x, y + 8, results[2], color)
  gui.text(x, y + 16, results[3], color)
end

-- Every Attack Formula uses three bytes, but in different ways
function getParameters(o)
  local aType = o.AttFormula
  local s = {}
  if o.Special ~= nil then
    s = getBitTable(o.Special, 8)
  else s = getBitTable(0, 8)
  end
  local p1 = o.Parameter1
  local p2 = o.Parameter2
  local p3 = o.Parameter3
  local results = {'', '', ''}

  -- Ready? This will be VERY long
  -- No Effect (apparently)
  if aType == 0x00 then
    if p1 > 0 then
      results[1] = "Duration/2: " .. p1
    end
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      results[3] = "Ability   : " .. TableMagicID[p3 + 1]
    end
  end
  -- Offensive Magic
  if aType == 0x06 then
    results[2] = "AttPow    : " .. p2
    results[3] = "Element   : " .. readActiveBits(p3, TableElement)
  end

  -- Gravity Damage, Harp songs
  if aType == 0x07 then
    results[1] = "Hit%      : " .. p1
    results[2] = "x/16ths   : " .. p2
    results[3] = "Status add: " .. readActiveBits(p3, TableStatusT)
  end

  -- HP drain
  if aType == 0x0D then
    results[1] = "Hit%      : " .. p1
    results[2] = "AttPow    : " .. p2
  end

  -- Status C Bestow
  if aType == 0x12 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Duration  : " .. p2
    results[3] = "Status Add: " .. readActiveBits(p3, TableStatusCurable)
  end

  -- Status T Bestow
  if aType == 0x13 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Duration/2: " .. p2
    results[3] = "Status Add: " .. readActiveBits(p3, TableStatusTemporary)
  end

  -- Status D Bestow
  if aType == 0x14 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Duration  : " .. p2
    results[3] = "Status Add: " .. readActiveBits(p3, TableStatusDispellable)
  end

  -- Speed Status
  if aType == 0x16 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Status Rem: " .. readActiveBits(p2, TableStatusDispellable, - 8)
    results[3] = "Status Add: " .. readActiveBits(p3, TableStatusDispellable)
  end

  -- Status Removal
  if aType == 0x19 then
    if p1 < 0xFF then
      results[1] = "Status Rem: " .. readActiveBits(p1, TableStatusCurable, - 8)
    end
    if p2 < 0xFF then
      results[2] = "Status Rem: " .. readActiveBits(p2, TableStatusDispellable, - 8)
    end
    if p3 < 0xFF then
      results[3] = "Status Rem: " .. readActiveBits(p3, TableStatusTemporary, - 8)
    end
  end

  -- Resurrection
  if aType == 0x1A then
    results[1] = "Hit% (und): " .. p1
    results[2] = ""
    results[3] = p3..'/16 HP restored'
  end

  -- Restore HP Item
  if aType == 0x24 then
    results[1] = "Restore HP: " .. p1 * p2
  end

  -- Restore MP Item
  if aType == 0x25 then
    results[1] = "Restore MP: " .. p1 * p2
  end

  -- Full HP/MP
  if aType == 0x26 then
    local Res = "Full "
    if getBitTable(p1, 8)[1] then
      Res = Res .. 'HP '
    end
    if getBitTable(p1, 8)[1] then
      Res = Res .. 'MP '
    end
    results[1] = Res
  end

  -- Fixed Damage
  if aType == 0x28 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Damage    : " .. p2 + p3 * 512
  end

  -- Sword, Knife, Spear
  if aType == 0x31 or aType == 0x32 or aType == 0x33 then
    if p1 > 0 then
      results[1] = "Element   : " .. readActiveBits(p1, TableElement)
    else results[1] = "Element   : None"
    end
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
        results[3] = "Ability   : " .. TableAbilityID[p3 + 1]
      else results[3] = "Ability   : " .. TableMagicID[p3 + 1]
      end
    end
  end

  -- Axe, Staff, Whip, Long Reach Axe
  if aType == 0x34 or aType == 0x38 or aType == 0x3A then
    results[1] = "Hit%      : " .. p1
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
        results[3] = "Ability   : " .. TableAbilityID[p3 + 1]
      else results[3] = "Ability   : " .. TableMagicID[p3 + 1]
      end
    end
  end

  -- Status infliction bow
  if aType == 0x35 then
    results[1] = "Hit%      : " .. p1
    if math.floor(p2 / 128) == 1 then -- if inflict status
      results[2] = "Activate% : " .. p2%128
      results[3] = "Status add: " .. readActiveBits(p3, TableStatusC)
    end
  end

  -- Normal Bow
  if aType == 0x36 then
    results[1] = "Hit%      : " .. p1
    results[2] = "Critical% : " .. p2
    if p3 > 0 then
      results[3] = "Element   : " .. readActiveBits(p3, TableElement)
    else results[3] = "Element   : None"
    end
  end

  -- Katana
  if aType == 0x37 then
    results[1] = "Critical% : " .. p1
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
        results[3] = "Ability   : " .. TableAbilityID[p3 + 1]
      else results[3] = "Ability   : " .. TableMagicID[p3 + 1]
      end
    end
  end

  -- Rod
  if aType == 0x3B then
    results[1] = "Hit%      : " .. p1
    if p3 > 0 then
      results[3] = "Element   : " .. readActiveBits(p3, TableElement)
    else results[3] = "Element   : None"
    end
  end

  -- Rune weapon
  if aType == 0x3C then
    results[1] = "Hit%      : " .. p1
    results[2] = "Attack +  : " .. p2
    results[3] = "MP Cost   : " .. p3
  end

  -- HP and Status Remove
  if aType == 0x42 then
    results[1] = "Hit%      : " .. p1
    results[2] = "AttPow    : " .. p2
    results[3] = "Status rem: " .. readActiveBits(p3, TableStatusCurable, - 8)
  end

  -- Flirt
  if aType == 0x49 then
    results[1] = "Hit%      : " .. p1
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      results[3] = "Ability   : " .. TableMagicID[p3 + 1]
    end
  end

  -- Status Up/Down
  if aType == 0x51 then
    local p2Bits = getBitTable(p2, 8)
    results[1] = "Hit%      : " .. p1
    if p2Bits[8] == 1 or p2Bits[7] == 1 then
      results[2] = "Level Half"
    end
    if p2Bits[6] == 1 then
      results[2] = "Def Half  "
    end
    if p2Bits[5] == 1 then
      results[2] = "Level Up  "
    end
    if p2Bits[3] == 1 then
      results[2] = "Att Pow Up"
    end
    if p3 > 0 then
      results[3] = "Amount    : " .. p3
    end
  end

  -- Max HP Up (Giant Drink)
  if aType == 0x59 then

  end

  -- Chicken Knife
  if aType == 0x64 then
    -- Not actually part of Parameters, but useful info for the item
    results[1] = "Escapes   : " .. readByte(0x7E7C75)
    results[2] = "Activate% : " .. p2
    if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
      results[3] = "Ability   : " .. TableAbilityID[p3 + 1]
    else results[3] = "Ability   : " .. TableMagicID[p3 + 1]
    end
  end

  -- Anti-monster
  if aType == 0x6C then
    results[3] = "Strong Vs : " .. readActiveBits(p3, TableCreature)
  end

  -- Brave Blade
  if aType == 0x6E then
    -- Not actually part of Parameters, but useful info for the item
    results[1] = "Escapes   : " .. readByte(0x7E7C75)
  end

  -- Anti-monster Bow
  if aType == 0x72 then
    results[1] = "Strong Vs : " .. readActiveBits(p1, TableCreature)
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      results[3] = "Ability   : " .. TableMagicID[p3 + 1]
    end
  end

  -- Anti-monster 'spear'
  if aType == 0x73 then
    results[1] = "Strong Vs : " .. readActiveBits(p1, TableCreature)
  end

  -- No attack
  if aType == 0x7F then

    if p1 > 0 then
      results[1] = "Power     : " .. p1
    end
    if p2 > 0 then
      results[2] = "Activate% : " .. p2
      if s[2] == 1 then -- If "ability attack" special bit is set, use ability table
        results[3] = "Ability   : " .. TableAbilityID[p3 + 1]
      else results[3] = "Ability   : " .. TableMagicID[p3 + 1]
        if s[1] == 1 then -- Wonder Rod
          results[3] = "Ability   : Wonder Rod"
        end
      end

      -- if actually a harp, look for actual info
      if p3 == 0x74 or p3 == 0x75 or p3 == 0x76 or p3 == 0x77 then
        results[1] = "Harp"
        --results = getParameters(??)
      end
    end
  end
  return results
end

-- Quick check to see if weap is throwable
function throwCheck(n)
  if n == 0 then return "Can Throw"
  else return ""
  end
end

-- Calculate Equip Preview MagDef, since the game doesn't
function findNewMagEva(char, equip, point)
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

-- Paints an empty box unlike "gui.drawbox"
function drawEmptyBox(X, Y, Width, Height, Color)
  local x0 = X
  local y0 = Y
  local x1 = X + Width
  local y1 = Y + Height

  gui.drawline( x0, y0, x1, y0, Color)
  gui.drawline( x1, y0, x1, y1, Color)
  gui.drawline( x1, y1, x0, y1, Color)
  gui.drawline( x0, y1, x0, y0, Color)
end

-- Combine drawBox & drawEmptyBox into 1 function
function drawBorderBox(X, Y, Width, Height, ...)
  Color1, Color2 = ...
  if Color1 == nil then Color1 = "white" end
  if Color2 == nil then Color2 = "blue" end
  gui.transparency(0)
  drawEmptyBox(X, Y, Width, Height, Color1)
  gui.transparency(1)
  gui.drawbox(X + 1, Y + 1, X + Width - 1, Y + Height - 1, Color2)
end

-- if Flippy is set, pretent xorigin is @ right side (for back attack)
function determineX(x)
  if Flippy then
    return 225 - x
  else
    return x
  end
end

-- Mainly for showing battlepage
function positionString(current, total)
  str = ''
  for i = 0, total do
    if i == current then str = str .. '+'
    else str = str .. '-' end
  end
  return str
end

-- read memories that aren't 1,2,4 bytes long
function readRange(add, num)
  local result = 0
  for i = 0, num - 1 do
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
  if newEnemyReady == readByte(0x7E4000) ~= 0 and readByte(0x7E00DE) ~= 0 then
    ShowBattleDisplay()
    gui.text(0, 20, "++", "white")
  else
    HideBattleDisplay()
    gui.text(0, 20, "--", "red")
  end
end

--------------------------------------------------------------------------------
----- OBJECTS ------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Table with the parameters of monsters
function EnemyInfo(Enemy)
  local enemy = Enemy - 1
  local enemyOffset = enemy * (0x80)
  local enemyinfo = {}

  enemyinfo = {
    Name = readWord(0x7E4008 + enemy * (0x02)),
    --Type            = readWord(0x7E4038 + enemy*(0x04)) ,

    Level = readByte(0x7E2202 + enemyOffset),
    CurrentHp = readWord(0x7E2206 + enemyOffset),
    TotalHp = readWord(0x7E2208 + enemyOffset),
    CurrentMp = readWord(0x7E220A + enemyOffset),
    TotalMp = readWord(0x7E220C + enemyOffset),
    StatusC = readByte(0x7E221A + enemyOffset),
    StatusT = readByte(0x7E221B + enemyOffset),
    StatusD = readByte(0x7E221C + enemyOffset),
    StatusP = readByte(0x7E221D + enemyOffset),
    --MagicPower      = readByte(0x7E2227 + enemyOffset) ,
    --MagicPower      = readByte(0x7E222B + enemyOffset) ,
    Evade = readByte(0x7E222C + enemyOffset),
    Defense = readByte(0x7E222D + enemyOffset),
    MagicEvade = readByte(0x7E222E + enemyOffset),
    MagicDefense = readByte(0x7E222F + enemyOffset),
    ElementAbsorb = readByte(0x7E2230 + enemyOffset),
    --ElementWeakness = readByte(0x7E2231 + enemyOffset) , -- NOT Weakness; maybe evade?
    ElementHalf = 0,
    ElementImmune = readByte(0x7E2232 + enemyOffset),
    ElementWeakness = readByte(0x7E2234 + enemyOffset),
    ImmuneC = readByte(0x7E2235 + enemyOffset),
    ImmuneT = readByte(0x7E2236 + enemyOffset),
    ImmuneD = readByte(0x7E2237 + enemyOffset),
    Attack = readByte(0x7E2244 + enemyOffset),
    AttackMult = readByte(0x7E2262 + enemyOffset),
    CantEvade = readByte(0x7E2264 + enemyOffset),
    Type = readByte(0x7E2265 + enemyOffset),
    CommandImmunity = readByte(0x7E2266 + enemyOffset),
    Experience = readWord(0x7E2267 + enemyOffset),
    Gil = readWord(0x7E2269 + enemyOffset),
    InitialC = readByte(0x7E2270 + enemyOffset),
    InitialT = readByte(0x7E2271 + enemyOffset),
    InitialD = readByte(0x7E2272 + enemyOffset),
    InitialP = readByte(0x7E2273 + enemyOffset),

    AttackGauge = readByte(0x7E3DAB + enemy * (0x0B)),
    Position = readByte(0x7E4000 + enemy * (0x01)),
    PositionY = readByte(0x7E4000 + enemy * (0x01)) % 16, -- low nibble
    PositionX = math.floor( readByte(0x7E4000 + enemy * (0x01)) / 16 ), -- high nibble

    StealRare = readByte(0xD05000 + readWord(0x7E4008 + enemy * (0x02)) * 4),
    StealCommon = readByte(0xD05000 + readWord(0x7E4008 + enemy * (0x02)) * 4 + 1),
    DropRare = readByte(0xD05000 + readWord(0x7E4008 + enemy * (0x02)) * 4 + 2),
    DropCommon = readByte(0xD05000 + readWord(0x7E4008 + enemy * (0x02)) * 4 + 3),

    statusgap = 2
  }

  return enemyinfo
end

-- Table with the battle parameters of allies
function CharacterInfo(Character)
  local character = Character - 1
  local charOffset = character * (0x80)
  local characterinfo = {}

  characterinfo = {
    Character = readByte(0x7E2000 + charOffset),
    Job = readByte(0x7E0501 + character * (0x50)),
    Level = readByte(0x7E2002 + charOffset),
    CurrentHp = readWord(0x7E2006 + charOffset),
    TotalHp = readWord(0x7E2008 + charOffset),
    CurrentMp = readWord(0x7E200A + charOffset),
    TotalMp = readWord(0x7E200C + charOffset),

    StatusC = readByte(0x7E201A + charOffset), -- Status (Curable)
    StatusT = readByte(0x7E201B + charOffset), -- Status (Temporary)
    StatusD = readByte(0x7E201C + charOffset), -- Status (Dispellable)
    StatusP = readByte(0x7E201D + charOffset), -- Status (Permanent)

    InitialC = readByte(0x7E2070 + charOffset), -- Inital Status (C)
    InitialT = readByte(0x7E2071 + charOffset), -- Inital Status (C)
    InitialD = readByte(0x7E2072 + charOffset), -- Inital Status (C)
    InitialP = readByte(0x7E2073 + charOffset), -- Inital Status (C)

    PowSong = readByte(0x7E2074 + charOffset), -- Power Song
    SpeedSong = readByte(0x7E2075 + charOffset), -- Speed Song
    StrSong = readByte(0x7E2076 + charOffset), -- Str Song
    MagSong = readByte(0x7E2077 + charOffset), -- Mag Song
    HeroSong = readByte(0x7E2078 + charOffset), -- Hero Song

    ElementAbsorb = readByte(0x7E2030 + charOffset), -- Elemental Absorb
    ElementEvade = readByte(0x7E2031 + charOffset), -- Elemental Evade?
    ElementImmune = readByte(0x7E2032 + charOffset), -- Elemental Immunity
    ElementHalf = readByte(0x7E2033 + charOffset), -- Elemental Half
    ElementWeakness = readByte(0x7E2034 + charOffset), -- Elemental Weakness

    ElementBoost = readByte(0x7E2022 + charOffset) -- Magic Element UP
  }

  return characterinfo
end

-- parameters of characters' world map stats (out of battle)
function WorldCharInfo(Char)
  local charinfo = {}
  local address = 0x7E0500 + Char * 0x50

  charinfo = {
    CharInfo = readByte(address + 0x00), --XX       --1st Player (Character)+128 if backrow
    CharNo = readByte(address + 0x00)%8, --XX       --1st Player (Character)+128 if backrow
    Job = readByte(address + 0x01), --XX       --1st Player Job
    Level = readByte(address + 0x02), --XX       --1st Player Level
    Exp = readRange(address + 0x03, 3), --XXXXXX   --1st Player Exp.
    CurrentHP = readWord(address + 0x06), --XXXX     --1st Player Current Hp
    MaxHP = readWord(address + 0x08), --XXXX     --1st Player Max Hp
    CurrentMP = readWord(address + 0x0A), --XXXX     --1st Player Current Mp
    MaxMP = readWord(address + 0x0C), --XXXX     --1st Player Max Mp
    Head = readByte(address + 0x0E), --XX       --1st Player Head equipment modifier
    Body = readByte(address + 0x0F), --XX       --1st Player Body equipment modifier
    Relic = readByte(address + 0x10), --XX       --1st Player Relic equipment modifier
    RHandShield = readByte(address + 0x11), --XX       --1st Player Right Hand Shield modifier
    LHandShield = readByte(address + 0x12), --XX       --1st Player Left Hand Shield modifier
    RHand = readByte(address + 0x13), --XX       --1st Player Right Hand Weapon modifier
    LHand = readByte(address + 0x14), --XX       --1st Player Left Hand Weapon modifier
    CapMonster = readByte(address + 0x15), --XX       --1st Player Caught Monster modifier (World)
    Command1 = readByte(address + 0x16), --XX       --1st Player Battle Command 1 (Up) modifier
    Command2 = readByte(address + 0x17), --XX       --1st Player Battle Command 2 (Left) modifier
    Command3 = readByte(address + 0x18), --XX       --1st Player Battle Command 3 (Right) modifier
    Command4 = readByte(address + 0x19), --XX       --1st Player Battle Command 4 (Down) modifier
    StatusC = readByte(address + 0x1A), --XX       --1st Player Status (World - curable)
    Unknown1 = readByte(address + 0x1B), --XX       --1st Player
    Unknown2 = readByte(address + 0x1C), --XX       --1st Player
    Unknown3 = readByte(address + 0x1D), --XX       --1st Player
    Unknown4 = readByte(address + 0x1E), --XX       --1st Player
    Unknown5 = readByte(address + 0x1F), --XX       --1st Player
    Passive1 = readByte(address + 0x20), --XX       --1st Player Innate Abilities
    Passive2 = readByte(address + 0x21), --XX       --1st Player Innate Abilities
    EleBoost = readByte(address + 0x22), --XX       --1st Player Magic Element Up
    Weight = readByte(address + 0x23), --XX       --1st Player Equip Weight
    Str = readByte(address + 0x24), --XX       --1st Player Base Strength
    Agi = readByte(address + 0x25), --XX       --1st Player Base Agility
    Vit = readByte(address + 0x26), --XX       --1st Player Base Stamina
    Mag = readByte(address + 0x27), --XX       --1st Player Base Magic Power
    EqStr = readByte(address + 0x28), --XX       --1st Player Current Strength (Equipment)
    EqAgi = readByte(address + 0x29), --XX       --1st Player Current Agility (Equipment)
    EqVit = readByte(address + 0x2A), --XX       --1st Player Current Stamina (Equipment)
    EqMag = readByte(address + 0x2B), --XX       --1st Player Current Magic (Equipment)
    Evade = readByte(address + 0x2C), --XX       --1st Player Evade%
    Def = readByte(address + 0x2D), --XX       --1st Player Defense
    MagEvade = readByte(address + 0x2E), --XX       --1st Player Magic Evade%
    MagDef = readByte(address + 0x2F), --XX       --1st Player Magic Defense
    ElementAbsorb = readByte(address + 0x30), --XX       --1st Player Elemental Absorb
    --				= readByte(address + 0x31), --XX       --1st Player Elemental Evade
    ElementImmune = readByte(address + 0x32), --XX       --1st Player Elemental Immunity
    ElementHalf = readByte(address + 0x33), --XX       --1st Player Elemental Half
    ElementWeakness = readByte(address + 0x34), --XX       --1st Player Elemental Weakness
    Unknown7 = readByte(address + 0x35), --XX       --1st Player
    Unknown8 = readByte(address + 0x36), --XX       --1st Player
    Unknown9 = readByte(address + 0x37), --XX       --1st Player
    EquipableWeapon = readByte(address + 0x38), --XX       --1st Player Weapon Specialty
    EquipableArmor = readByte(address + 0x39), --XX       --1st Player Equipment Specialty
    JobLevel = readByte(address + 0x3A), --XX       --1st Player Job Level
    ABPoints = readWord(address + 0x3B), --XXXX     --1st Player ABP
    Unknown10 = readByte(address + 0x3D), --XX       --1st Player
    Unknown11 = readByte(address + 0x3E), --XX       --1st Player
    Unknown12 = readByte(address + 0x3F), --XX       --1st Player
    Mystery = memory.readdword(address + 0x40), --XXXXXXXX --1st Player Jobs?
    AttPow = readWord(address + 0x44), --XXXX     --1st Player Attack
    Unknown13 = readByte(address + 0x46), --XX       --1st Player
    Unknown14 = readByte(address + 0x47), --XX       --1st Player
    Unknown15 = readByte(address + 0x48), --XX       --1st Player
    Unknown16 = readByte(address + 0x49), --XX       --1st Player
    Unknown17 = readByte(address + 0x4A), --XX       --1st Player
    Unknown18 = readByte(address + 0x4B), --XX       --1st Player
    Unknown19 = readByte(address + 0x4C), --XX       --1st Player
    Unknown20 = readByte(address + 0x4D), --XX       --1st Player
    Unknown21 = readByte(address + 0x4E), --XX       --1st Player
    Unknown22 = readByte(address + 0x4F), --XX       --1st Player

  }
  return charinfo
end

-- Job Info (this is stored differently than, say Item data)
function JobInfo(n)
  local jobinfo = {}

  jobinfo = {
    index = n,

    FirstAbility = readWord(0xD152C0 + n * 2), -- 1st ability pointer
    NumOfAbility = readByte(0xD152EA + n), -- Number of abilites/job
    BaseStr = readByte(0xD156B0 + n * 4), -- Stat Modification
    BaseAgi = readByte(0xD156B1 + n * 4), -- Stat Modification
    BaseVit = readByte(0xD156B2 + n * 4), -- Stat Modification
    BaseMag = readByte(0xD156B3 + n * 4), -- Stat Modification
    Equipable = memory.readdword(0xD15708 + n * 4),
    Native1 = readByte(0xD15760 + n * 4), -- Native skills for job (Fight, Cover, etc)
    Native2 = readByte(0xD15761 + n * 4),
    Native3 = readByte(0xD15762 + n * 4),
    Native4 = readByte(0xD15763 + n * 4),
    Passive1 = readByte(0xD157B8 + n * 2), -- Auto Passives for Job
    Passive2 = readByte(0xD157B9 + n * 2),
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

-- Information game uses in equip screen
function EquipPreviewInfo()
  local eqpr = {}

  eqpr = {
    EqWt = readByte(0x7E2723), -- Equipment Weight    (Menu)
    BaseStr = readByte(0x7E2724), -- Base Strength       (Menu)
    BaseAgi = readByte(0x7E2725), -- Base Agility        (Menu)
    BaseVit = readByte(0x7E2726), -- Base Vitality       (Menu)
    BaseMag = readByte(0x7E2727), -- Base Magic Power    (Menu)
    Str = readByte(0x7E2728), -- Current Strength    (Menu)
    Agi = readByte(0x7E2729), -- Current Agility     (Menu)
    Vit = readByte(0x7E272A), -- Current Vitality    (Menu)
    Mag = readByte(0x7E272B), -- Current Magic Power (Menu)
    Eva = readByte(0x7E272C), -- Current Evade%      (Menu)
    Def = readByte(0x7E272D), -- Current Defense     (Menu)
    MagEvade = readByte(0x7E272E), -- Magic Evade%        (Menu)
    MagDef = readByte(0x7E272F), -- Magic Defense       (Menu)
    ElementAbsorb = readByte(0x7E2730), -- Elemental Absorb    (Menu)
    ElementImmune = readByte(0x7E2732), -- Elemental Immunity  (Menu)
    ElementHalf = readByte(0x7E2733), -- Elemental Half      (Menu)
    ElementWeakness = readByte(0x7E2734), -- Elemental Weakness  (Menu)
    --				= readByte(0x7E2738), -- Weapon Specialty    (Menu)
    --				= readByte(0x7E2739), -- Equipment Specialty (Menu)?
    --				= readByte(0x7E273A), -- Job Level           (Menu)?
    --				= readWord(0x7E273B), -- ABP                 (Menu)?
    AttPow = readWord(0x7E2744), -- Attack              (Menu)
  }

  return eqpr
end

function ItemInfo(n)
  local item = {index = n, itemType = "Nothing"}
  local address = 0

  -- item is weapon
  if n >= 0x01 and n <= 0x7F then
    address = 0xD10000 + (n * 12)
    item = {
      index = n,
      itemType = "weapon",
      -- D1/0000
      -- [Item] * 12 bytes
      Target = readByte(address + 0x0), -- 0 Targeting (when used as item)
      AttackType = readByte(address + 0x1), -- 1 [Attack type]
      ThrowEquip = readByte(address + 0x2), -- 2 Throw + Equipment type value
      Throwable = splitBot(readByte(address + 0x2), 64), -- 2 Throwable
      EquipType = splitTop(readByte(address + 0x2), 64), -- 2 Equipment type value
      BoostStats = readByte(address + 0x3), -- 3 Element/stats up
      StatsUpCheck = splitBot(readByte(address + 0x3), 128), -- 3 Stats up check bit
      EleBoost = splitTop(readByte(address + 0x3), 128), -- 3 Elemental Boost
      StatsUp = math.floor((readByte(address + 0x3)%128) / 8), -- 3 Bonus Stats
      StatsValue = readByte(address + 0x3)%8, -- 3 Stats up value
      DGDescript = readByte(address + 0x4), -- 4 Double Grip + Description
      Descript = readByte(address + 0x4)%64, -- 4 Description
      Double = math.floor(readByte(address + 0x4) / 64), -- 4 Double Grip info
      Special = readByte(address + 0x5), -- 5 Special properties
      UsedBreak = readByte(address + 0x6), -- 6 Used as item/Break on use
      Break = math.floor(readByte(address + 0x6) / 128), -- 6 Break on use
      Used = readByte(address + 0x6)%128, -- 6 Used as item
      AttPow = readByte(address + 0x7), -- 7 Attack power
      AttFormula = readByte(address + 0x8), -- 8 Attack formula
      Parameter1 = readByte(address + 0x9), -- 9 Parameter 1 \
      Parameter2 = readByte(address + 0xA), -- A Parameter 2  (See Actions chapter)
      Parameter3 = readByte(address + 0xB), -- B Parameter 3 /

    }
  end

  -- item is armor
  if n >= 0x80 and n <= 0xDF then
    address = 0xD10000 + (n * 12)
    item = {
      index = n,
      itemType = "armor",
      --	- D1/0600
      --	[Item] * 12 bytes
      EquipSlots = readByte(address + 0x0), --	0 Equipment slots
      Weight = readByte(address + 0x1), --	1 Equipment weight
      ThrowEquip = readByte(address + 0x2), --	2 Equipment type value \
      EquipType = readByte(address + 0x2) % 64, -- 2 Equipment type value
      BoostStats = readByte(address + 0x3), -- 3 Element/stats up
      StatsUpCheck = math.floor(readByte(address + 0x3) / 128), -- 3 Stats up check bit
      EleBoost = readByte(address + 0x3)%128, -- 3 Elemental Boost
      StatsUp = math.floor((readByte(address + 0x3)%128) / 8), -- 3 Bonus Stats
      StatsValue = readByte(address + 0x3)%8, -- 3 Stats up value
      Descript = readByte(address + 0x4), --	4 Description          /
      Special = readByte(address + 0x5), --	5 Special properties
      Evade = readByte(address + 0x6), --	6 Evade %
      Defense = readByte(address + 0x7), --	7 Defense
      MagEvade = readByte(address + 0x8), --	8 Magic evade %
      MagDefense = readByte(address + 0x9), --	9 Magic defense
      EleDefense = readByte(address + 0xA), --	A Element defense
      StatusProp = readByte(address + 0xB), --	B Status properties
    }
  end

  -- item is usable
  if n >= 0xE0 then
    address = 0xD10A80 + (n - 0xE0) * 8
    item = {
      index = n,
      itemType = "useable",
      --	- D1/0A80
      --	[Item] * 8 bytes
      Target = readByte(address + 0x0), --	0 Targeting
      AttackType = readByte(address + 0x1), --	1 [Attack Type]
      Misc = readByte(address + 0x2), --	2 Misc.
      Descript = readByte(address + 0x3)%128, --	3 Description (see Weapons section)
      Unavoid = math.floor(readByte(address + 0x4) / 128), --	3 Unavoidable formula
      AttAvoid = readByte(address + 0x4), --	4 Unavoidable + Attack formula
      AttFormula = readByte(address + 0x4)%128, --	4 Attack formula
      Parameter1 = readByte(address + 0x5), --	5 Parameter 1 \
      Parameter2 = readByte(address + 0x6), --	6 Parameter 2  (See Actions chapter)
      Parameter3 = readByte(address + 0x7), --	7 Parameter 3 /
    }
  end
  return item
end

--
-- Screen Displays
--

function AbilityScreen()
  local AbX = 104
  local AbY = 160
  local spacer = 8
  local pointingAt = readByte(0x7E0153)
  local pageOffset = readByte(0x7E016B)
  local truePoint = pointingAt + pageOffset - 4

  SelectChar = WorldCharInfo(readByte(0x7E0171))
  local charNo = SelectChar.CharNo
  if charNo == 4 then charNo = 2 end -- Galuf/Krile

  local learnedAddress = (0x7E08f7 + 0x14 * charNo)
  local learned = {}
  for i = 0, 0x11 do
    learned[i + 1] = readByte(learnedAddress + i)
  end
  drawBorderBox(96, 154, 150, 58, 'white', 'grey')
  gui.transparency(0)

  -- slot -1 : uh...
  gui.text(AbX, AbY + spacer * - 1, truePoint)
  -- gui.text(AbX, AbY + spacer * 0, bit.tohex(learnedAddress, - 6), c.Green)
  -- gui.text(AbX, AbY + spacer * 1, getBitString(learned[1]))
  -- gui.text(AbX, AbY + spacer * 2, getBitString(learned[2]))
  -- gui.text(AbX, AbY + spacer * 3, getBitString(learned[3]))
  -- gui.text(AbX, AbY + spacer * 4, getBitString(learned[4]))
  -- gui.text(AbX, AbY + spacer * 5, getBitString(learned[5]))
  -- gui.text(AbX, AbY + spacer * 6, getBitString(learned[6]), c.Pink)
  -- gui.text(AbX + 40, AbY + spacer * 1, getBitString(learned[7]), c.Cyan)
  -- gui.text(AbX + 40, AbY + spacer * 2, getBitString(learned[8]), "white")
  -- gui.text(AbX + 40, AbY + spacer * 3, getBitString(learned[9]), "grey")
  -- gui.text(AbX + 40, AbY + spacer * 4, getBitString(learned[10]), c.Orange)
  -- gui.text(AbX + 40, AbY + spacer * 5, getBitString(learned[11]), c.Lime)
  -- gui.text(AbX + 40, AbY + spacer * 6, getBitString(learned[12]), c.Red)
  -- gui.text(AbX + 80, AbY + spacer * 1, getBitString(learned[13]), c.Blue)
  -- gui.text(AbX + 80, AbY + spacer * 2, getBitString(learned[14]), c.Yellow)
  -- gui.text(AbX + 80, AbY + spacer * 3, getBitString(learned[15]), c.Yellow)
  -- gui.text(AbX + 80, AbY + spacer * 4, getBitString(learned[16]), c.Yellow)
  -- gui.text(AbX + 80, AbY + spacer * 5, getBitString(learned[17]), c.Yellow)
  -- gui.text(AbX + 80, AbY + spacer * 6, getBitString(learned[18]), c.Yellow)

end

------------------------------------------------------------------------------------------------------
-- Main Loop -----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

while true do -- Idle loop. Prevents pre-lua pause state

  local character = {} -- Holds the character's information
  local NoCharacters = 4 -- Number of characters in a battle

  local enemy = {} -- Holds the enemy's information
  local NoEnemies = 8 -- Number of enemies in a battle
  local visible = {} -- Determines if an enemy is visible

  local Equip = {}
  local SelectItem = {}
  local SelectChar = {}

  local MenuScreen = readByte(0x7E0143)
  local point = readByte(0x7E0153)

  --local DisplayBattleInfo =
  local newEnemyReady = readByte(0x7E4000) ~= 0 and readByte(0x7E00DE) ~= 0 -- Display Battle Information using EN1 'position'

  local DisplayMenuScreen = MenuScreen == 1 -- Display Menu
  local DisplayAbilityScreen = MenuScreen == 2 -- Display Ability screen info
  local DisplayJobScreen = MenuScreen == 3 -- Display Job screen info
  local DisplayEquipScreen = MenuScreen == 4 -- Display Equipment screen info
  local DisplayStatusScreen = MenuScreen == 5 -- Display Status screen info
  local DisplayItemScreen = MenuScreen == 7 -- Display Item Screen Info
  local DisplayMagicScreen = MenuScreen == 8 -- Display Mag Screen Info
  local DisplayGameStart = MenuScreen == 85 -- @ game start, this is 85
  local DisplayMap = DisplayMenuScreen -- Until I can tell the difference

  local timer = 0 -- In-game clock timer

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

  if TableMenuScreens[1 + MenuScreen] ~= nil then
    gui.text (8, 0, TableMenuScreens[1 + MenuScreen], 'green') -- Show which Menu is open
  else
    gui.text (8, 0, MenuScreen, 'red') -- Show which Menu is open
  end

  -- if battle is paused
  --if readByte(0x7E00A4) == 0 then
  --gui.text(0,0,"paused? " .. readByte(0x7E00A4), 'cyan')
  --end

  --gui.text(0,16,"something ".. readByte(0x7E0134), "cyan")
  -- display arena name
  gui.transparency(1)

  if arena < 33 then
    gui.text ( offsetX + 50, 0, TableBattleground[arena + 1], "white")
  else
    gui.text ( offsetX + 50, 0, arena, "white")
  end

  -- Menus
  -- Can't figure this out yet.
  --DisplayAbilityScreen = false
  if DisplayAbilityScreen then
    AbiltyScreen()
  end

  -- Magic Screen Info
  if DisplayMagicScreen then
    local subMenu = splitTop(readByte(0x7E60D2), 8) - 3
    local PointAt = readByte(0x7E0155)
    local SelectSpell = (18 * subMenu) + PointAt - 1

    gui.text( 8, 200, "?"..subMenu, 'cyan')
    --gui.text( 8,207,"?"..splitBot(readByte(0x7E60D2),8),'cyan')
    if SelectSpell < 0x48 and SelectSpell >= 0 then
      gui.text( 8, 207, bit.tohex(SelectSpell, - 2)..': '..TableMagicID[SelectSpell + 1], c.Lime)
    end
    gui.text(32, 200, "#"..SelectSpell, 'cyan')
  end

  if DisplayItemScreen then -- Item Screen Info
    local pointingAt = readByte(0x7E0153)
    local pageOffset = readByte(0x7E016B)
    local truePoint = pointingAt + pageOffset - 4
    local itemAt = readByte(0x7E0640 + truePoint)

    local ItemX = 14
    local ItemXR = 136
    local ItemY = 34
    local spacer = 8
    SelectItem = ItemInfo(itemAt)

    drawBorderBox(8, 32, 238, 34, 'white', c.Red)
    gui.transparency(0)

    --gui.text(114,50, truePoint..': '..bit.tohex(itemAt,-2),'cyan','blue')
    --gui.text(114,56, SelectItem.itemType,c.Orange)


    if SelectItem.itemType == 'weapon' then
      gui.text( ItemX, ItemY + spacer * - 1, TableEquipmentType[SelectItem.EquipType + 1], c.Orange)
      -- Slot 0 : Attack Power
      gui.text( ItemX, ItemY + spacer * 0, "Attack : ".. SelectItem.AttPow, 'yellow')
      -- Slot 1 : Dbl Grip/Throw
      gui.text( ItemX, ItemY + spacer * 1, readActiveBits(SelectItem.Double, TableDoubleGrip, 2)
      ..' '..throwCheck(SelectItem.Throwable), 'white')
      -- Slot 2 : Properties
      gui.text( ItemX, ItemY + spacer * 2, readActiveBits(SelectItem.Special, TableWeaponProperty), 'green')
      -- Slot 3 : Stats increased / Elemental Booster
      if SelectItem.StatsUpCheck == 1 then -- if showing stats
        if SelectItem.StatsUp > 0 then -- if stats are actually increased
          gui.text(ItemX, ItemY + spacer * 3,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, 4) ..
          TableStatValue[SelectItem.StatsValue + 1][1], c.Yellow)
        end
        if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
          gui.text(ItemXR, ItemY + spacer * 3,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, - 4) ..
          TableStatValue[SelectItem.StatsValue + 1][2], 'grey')
        end
        -- else show boosted elements
      else gui.text(ItemX, ItemY + spacer * 3, "Boosts : " .. readActiveBits(SelectItem.EleBoost, TableElement), c.Green)
      end
      gui.text( ItemXR, ItemY + spacer * 0, TableAttackFormula[SelectItem.AttFormula + 1], 'white')
      DisplayParameters(SelectItem, ItemXR, ItemY + spacer * 1)
    end
    if SelectItem.itemType == 'armor' then
      gui.text ( ItemX, ItemY + spacer * - 1, TableEquipmentType[SelectItem.EquipType + 1], c.Orange)
      -- Slot 0-Left : Defense
      gui.text(ItemX, ItemY + spacer * 0, 'Defense : ' .. SelectItem.Defense, 'white')
      -- Slot 0-Right: Evade
      gui.text(ItemXR, ItemY + spacer * 0, 'Evade : ' .. SelectItem.Evade, 'white')
      -- Slot 1-Left : Magic Defense
      gui.text(ItemX, ItemY + spacer * 1, 'MDefense: ' .. SelectItem.MagDefense, 'white')
      -- Slot 1-Right: Magic Evade
      gui.text(ItemXR, ItemY + spacer * 1, 'MEvade: ' .. SelectItem.MagEvade, 'white')
      -- Slot 2 : Special Armor Properties
      gui.text(ItemX, ItemY + spacer * 2, readActiveBits(SelectItem.Special, TableArmorProperty), 'green')
      -- Slot 2-R: Equipment's Elemental Defense
      showEleDefense(ItemXR, ItemY + spacer * 2, EleDefenseDef(SelectItem.EleDefense))
      -- Slot 3 : Stats increased / Elemental Booster
      if SelectItem.StatsUpCheck == 1 then -- if showing stats
        if SelectItem.StatsUp > 0 then -- if stats are actually increased
          gui.text(ItemX, ItemY + spacer * 3,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, 4) ..
          TableStatValue[SelectItem.StatsValue + 1][1], c.Yellow)
        end
        if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
          gui.text(ItemXR, ItemY + spacer * 3,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, - 4) ..
          TableStatValue[SelectItem.StatsValue + 1][2], 'grey')
        end
        -- else show boosted elements
      else gui.text(ItemX, ItemY + spacer * 3, "Boosts: " .. readActiveBits(SelectItem.EleBoost, TableElement), c.Green)


      end
    end
    if SelectItem.itemType == 'useable' then
      gui.text(ItemX, ItemY + spacer * 0, TableAttackFormula[SelectItem.AttFormula + 1], 'white')
      DisplayParameters(SelectItem, ItemX, ItemY + spacer * 1)

      --gui.text(ItemX , ItemY+spacer*0, getBitString(SelectItem.Target,8)..' '..readActiveBits(SelectItem.Target,TableTargeting),'white')
      --gui.text(ItemX , ItemY+spacer*1, getBitString(SelectItem.AttackType,8)..' '..readActiveBits(SelectItem.AttackType,TableAttackType), 'yellow')
      --gui.text(ItemX , ItemY+spacer*2, getBitString(SelectItem.Misc,8), 'cyan')
      --gui.text(ItemX , ItemY+spacer*3, getBitString(SelectItem.Descript,8)..' '..bit.tohex(SelectItem.Descript,-2), 'green')
      --gui.text(ItemX , ItemY+spacer*4, getBitString(SelectItem.AttAvoid,8)
      --    ..' '.. bit.tohex(SelectItem.AttFormula,-2)
      --	..' '.. TableAttackFormula[SelectItem.AttFormula+1],'white')
      --gui.text(ItemX , ItemY+spacer*5, getBitString(SelectItem.Parameter1,8), c.Purple)
      --gui.text(ItemX , ItemY+spacer*6, getBitString(SelectItem.Parameter2,8), c.Purple)
      --gui.text(ItemX , ItemY+spacer*7, getBitString(SelectItem.Parameter3,8), c.Purple)
    end


  end
  if DisplayGameStart then
    DisplayBattleInfo = false
    drawBorderBox( 0, 198, 254, 24, 'purple', c.Purple) -- Bottom Box
    gui.transparency(0)
    gui.text(2, 198, 'Learning', 'white', 0)
    gui.text(2, 208, 'A FFV LUA script --------------', 'white', 0)
    gui.text(2, 216, 'by Christopher DeMichiei -2019-', 'white', 0)

  end

  if DisplayStatusScreen then -- Status Screen Info
    local StatusX = 14
    local StatusXR = 70
    local StatusY = 100
    local Status2X = 129
    local Status2Y = 100
    local Status2XR = 190
    local spacer = 8

    SelectChar = WorldCharInfo(readByte(0x7E0171))

    drawBorderBox( 10, 86, 114, 16, c.Cyan, c.Blue) -- Box
    drawBorderBox( 10, 96, 114, 109) -- Left Box
    drawBorderBox( 125, 96, 122, 109)-- Right Box
    drawBorderBox( 0, 206, 254, 16, 'white', c.Green) -- Bottom Box
    gui.transparency(0)

    local charNo = SelectChar.CharNo
    if charNo == 4 then charNo = 2 end -- Galuf/Krile

    local N1 = 120 - SelectChar.EqAgi + math.floor(SelectChar.Weight / 8)
    local Nexp = memory.readdword(0x7E2746)
    local capMonSpell = readByte(0xD08600 + SelectChar.CapMonster)

    gui.text(StatusX, StatusY - 12, readActiveBits(SelectChar.StatusC, TableStatusCurable), 'cyan')

    -- Left Box --
    -- Slot 0 HP/MP
    gui.text(StatusX, StatusY + spacer * 0,
    "HP: ".. PadNum(SelectChar.CurrentHP, 4).."/"..PadNum(SelectChar.MaxHP, 4), 'green')
    gui.text(StatusXR, StatusY + spacer * 0,
    "MP: ".. PadNum(SelectChar.CurrentMP, 3).."/"..PadNum(SelectChar.MaxMP, 3), 'cyan')
    -- Slot 1-2 : EXP
    gui.text(StatusX, StatusY + spacer * 1, "EXP: ".. PadNum(SelectChar.Exp, 8), 'red')
    gui.text(StatusXR, StatusY + spacer * 1, "Next:".. PadNum(Nexp, 8), 'red')
    drawBorderBox(StatusX, StatusY + spacer * 2, 108, 6, c.Red, 'black')
    drawBorderBox(StatusX, StatusY + spacer * 2, 108 * (SelectChar.Exp / (SelectChar.Exp + Nexp)), 6, c.Red, c.Red)
    gui.transparency(0)
    -- Slot 3 : # of Ability
    gui.text(StatusX, StatusY + spacer * 3, "Abilities: "..readByte(0x7E08F3 + charNo), 'white')
    -- Slot 4-5 : Captured Monster
    if SelectChar.CapMonster ~= 255 then
      gui.text(StatusX, StatusY + spacer * 4, "Capture: "..findEnemyName({Name = SelectChar.CapMonster}), c.Yellow)
      gui.text(StatusX, StatusY + spacer * 5, "Release: ".. TableMagicID[capMonSpell + 1], c.Yellow)
    else
      gui.text(StatusX, StatusY + spacer * 4, "Capture: None", 'grey')
    end

    -- Right Box --
    -- Slot 0-Left: Strength
    gui.text(Status2X, Status2Y + spacer * 0, "Strength : "..SelectChar.EqStr, "white")
    -- Slot 1 : Agility..
    gui.text(Status2X, Status2Y + spacer * 1, "Agility  : "..SelectChar.EqAgi, "white")
    -- Slot 2 : Vitality..
    gui.text(Status2X, Status2Y + spacer * 2, "Vitality : "..SelectChar.EqVit, "white")
    -- Slot 3 : Magic Power..
    gui.text(Status2X, Status2Y + spacer * 3, "Magic Pow: "..SelectChar.EqMag, "white")
    -- Slot 0-Right : Total AttPow
    gui.text(Status2XR, Status2Y + spacer * 0, 'Attack : '..SelectChar.AttPow, 'white')
    -- Slot 1-Right : Total Def..
    gui.text(Status2XR, Status2Y + spacer * 1, 'Defense: '..SelectChar.Def, 'white')
    -- Slot 2-Right : Total Evade..
    gui.text(Status2XR, Status2Y + spacer * 2, 'Evade  : '..SelectChar.Evade, 'white')
    -- Slot 3-Right : Total MagDef..
    gui.text(Status2XR, Status2Y + spacer * 3, 'M Def  : '..SelectChar.MagDef, 'white')
    -- Slot 4-Right : Total MagEvade..
    gui.text(Status2XR, Status2Y + spacer * 4, 'M Evade: '..SelectChar.MagEvade, 'white')
    -- Slot 4 : Character's total Elemental Defense
    showEleDefense(Status2X, Status2Y + spacer * 4, SelectChar)
    -- Slot 5 : Equip Weight
    gui.text(Status2X, Status2Y + spacer * 5, 'Eq Weight: '..SelectChar.Weight, 'white')
    -- Slot 5-R: ATB bar prefill
    gui.text(Status2XR, Status2Y + spacer * 5, 'ATB : '..255 - N1, c.Pink)
    -- Bottom Box : Inate passives
    gui.text(2, 208, readActiveBits(SelectChar.Passive1, TablePassive1), 'green')
    gui.text(2, 215, readActiveBits(SelectChar.Passive2, TablePassive2), 'green')

  end

  if DisplayJobScreen then -- Job Screen Information
    local JobX = 12
    local JobY = 168
    local spacer = 8

    -- selected char
    SelectChar = WorldCharInfo(readByte(0x7E0171))
    SelectedJob = JobInfo(readByte(0x7E01D8))

    -- address for job info in RAM
    local jInfoAddress = readByte(0x7E0171) * 0x2C + 0x7E0843
    -- Level of selected Job
    local jLevel = splitBot(readByte(jInfoAddress + 0x1 + SelectedJob.index * 0x2), 16)
    -- current APB of selected Job
    local jAPB = readByte(jInfoAddress + SelectedJob.index * 0x2)
     + splitTop(readByte(jInfoAddress + 0x1 + SelectedJob.index * 0x2), 16) * 256
    -- address for APB needed for JOB level; displayed by game
    local next = readWord(0x7E01DE)
    -- Base stats (mod values, I assume)


    drawBorderBox(8, 164, 238, 50, 'white', 'grey')
    gui.transparency(0)
    -- Slot -1 : Job Name
    gui.text(JobX, JobY + spacer * - 1, TableJob[SelectedJob.index + 1], 'yellow')
    -- Slot -1 : stat adjustment (24 is base stat for Freelancer/Mimic)
    gui.text(JobX + 65 + spacer * 0, JobY + spacer * - 1, "Str:"..SelectedJob.BaseStr - 24, "red")
    gui.text(JobX + 65 + spacer * 4, JobY + spacer * - 1, "Agi:"..SelectedJob.BaseAgi - 24, "yellow")
    gui.text(JobX + 65 + spacer * 8, JobY + spacer * - 1, "Vit:"..SelectedJob.BaseVit - 24, c.Cyan)
    gui.text(JobX + 65 + spacer * 12, JobY + spacer * - 1, "Mag:"..SelectedJob.BaseMag - 24, c.Purple)
    -- Slot 0 : Number of Job Levels
    gui.text(JobX, JobY + spacer * 0, 'Level '..jLevel.. '/'..SelectedJob.NumOfAbility, 'white')
    -- Slot 0 Right : APB
    if jLevel < SelectedJob.NumOfAbility then
      gui.text(JobX + 65, JobY + spacer * 0, PadNum(jAPB, 3)..'/'..next, c.Pink)
      else if SelectedJob.NumOfAbility > 0 then
        gui.text(JobX + 65, JobY + spacer * 0, "*MASTER*", c.Yellow, c.Red)
      end
    end
    -- Slot 1-4 : Native Ability
    gui.text(JobX, JobY + spacer * 1, TableJobLevel[SelectedJob.Native1 + 1], c.Cyan)
    gui.text(JobX, JobY + spacer * 2, TableJobLevel[SelectedJob.Native2 + 1], c.Cyan)
    gui.text(JobX, JobY + spacer * 3, TableJobLevel[SelectedJob.Native3 + 1], c.Cyan)
    gui.text(JobX, JobY + spacer * 4, TableJobLevel[SelectedJob.Native4 + 1], c.Cyan)
    -- Slot 5 Passive Abilites
    gui.text(JobX, JobY + spacer * 5, readActiveBits(SelectedJob.Passive1, TablePassive1)..
    readActiveBits(SelectedJob.Passive2, TablePassive2), 'green')
    -- gui.text(JobX,JobY+spacer*1, bit.tohex(SelectedJob.FirstAbility,-2)  , 'white')
    -- Slots 1-4 Right: Job Levels
    for i = 1, SelectedJob.NumOfAbility do
      local learnedAbility = 'black'
      local j = i - 1
      local jlvl = SelectedJob.FirstAbility + (j * 3)
      local APNeeded = readWord(0xD10000 + jlvl)
      local ability = readByte(0xD10000 + jlvl + 0x2)

      if j < jLevel then learnedAbility = c.Red end

      gui.text(JobX + 65 + 75 * math.floor(j / 4), JobY + spacer * ((j%4) + 1), PadNum(APNeeded, 3)..': ', c.Orange)
      gui.text(JobX + 81 + 75 * math.floor(j / 4), JobY + spacer * ((j%4) + 1), TableJobLevel[ability + 1], 'white', learnedAbility)
    end
  end

  if DisplayEquipScreen then -- Equipment Screen Information
    -- Some information comes from Equipment screen (RAM)
    Equip = EquipPreviewInfo()

    SelectChar = WorldCharInfo(readByte(0x7E0171))

    -- Most information comes from the item pointed at (ROM)
    if point >= 10 then SelectItem = ItemInfo(readByte(0x7E0172)) else
      if point < 10 then SelectItem = ItemInfo(00) end
      if point == 00 then SelectItem = ItemInfo(math.max(SelectChar.RHandShield, SelectChar.RHand)) end -- Rhand
      if point == 01 then SelectItem = ItemInfo(math.max(SelectChar.LHandShield, SelectChar.LHand)) end -- Lhand
      if point == 02 then SelectItem = ItemInfo(SelectChar.Head) end -- Head
      if point == 03 then SelectItem = ItemInfo(SelectChar.Body) end -- Body
      if point == 04 then SelectItem = ItemInfo(SelectChar.Relic) end -- Accessory
    end
    local EquipX = 125
    local EquipY = 100
    local EquipXR = 195
    local spacer = 8

    drawBorderBox( 120, 96, 126, 126, 'white', 'grey')
    -- This Equipment Box gives 15 slots (starting @ 0)
    gui.transparency(0)

    -- Slot -1 (on top border) :  Item Index
    gui.text(EquipX, EquipY + spacer * - 1, bit.tohex(SelectItem.index, - 2), "cyan")

    if SelectItem.itemType == 'weapon' then
      -- Slot 5 : Equipment Type
      gui.text(EquipX, EquipY + spacer * 5, TableEquipmentType[SelectItem.EquipType + 1], c.Orange)
      -- Slot 6-Left : DoubleGrip Info
      gui.text(EquipX, EquipY + spacer * 6, readActiveBits(SelectItem.Double, TableDoubleGrip, 2), 'white')
      -- Slot 6-Right: Throwable
      gui.text(EquipXR, EquipY + spacer * 6, throwCheck(SelectItem.Throwable), 'white')
      -- Slot 7-Left : Attack Power
      gui.text(EquipX, EquipY + spacer * 7, 'WeapPow: '..SelectItem.AttPow, 'white')
      -- Slot 7-Right: Attack Type (Phys, Aerial, Black, Song)
      gui.text(EquipXR, EquipY + spacer * 7, readActiveBits(SelectItem.AttackType, TableAttackType), 'yellow')
      -- Slot 8 : Special Weapon Properties
      gui.text(EquipX, EquipY + spacer * 8, readActiveBits(SelectItem.Special, TableWeaponProperty), 'green')
      -- Slot 9 : Spell when used as item
      if SelectItem.Used ~= 0x78 then
        gui.text(EquipX, EquipY + spacer * 9, "USE: "..TableMagicID[SelectItem.Used + 1], 'cyan')
      end
      -- Slot 9-additional : Breaks when used
      if SelectItem.Break > 0 and SelectItem.index ~= 0x60 then -- Wonderwand flaged as break, but it doesn't
        gui.text(EquipX + 90, EquipY + spacer * 9, 'Breaks', 'red')
      end
      -- Slots 10 : Attack Formula
      gui.text(EquipX, EquipY + spacer * 10, TableAttackFormula[SelectItem.AttFormula + 1], 'white')
      -- Slots 11-13 : Parameters for the attack formula
      DisplayParameters(SelectItem, EquipX, EquipY + spacer * 11)
      -- Slot 14 : Stats increased / Elemental Booster
      if SelectItem.StatsUpCheck == 1 then -- if showing stats
        if SelectItem.StatsUp > 0 then -- if stats are actually increased
          gui.text(EquipX, EquipY + spacer * 14,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, 4) ..
          TableStatValue[SelectItem.StatsValue + 1][1], c.Yellow)
        end
        if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
          gui.text(EquipXR, EquipY + spacer * 14,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, - 4) ..
          TableStatValue[SelectItem.StatsValue + 1][2], 'grey')
        end
        -- else show boosted elements
      else gui.text(EquipX, EquipY + spacer * 14, "Boosts: " .. readActiveBits(SelectItem.EleBoost, TableElement), c.Green)

      end
    end

    if SelectItem.itemType == 'armor' then
      -- Slot 5-Left : Equipment Type
      gui.text(EquipX, EquipY + spacer * 5, TableEquipmentType[SelectItem.EquipType + 1], 'orange')
      -- Slot 5-Right: Weight
      gui.text(EquipXR, EquipY + spacer * 5, 'Weight: ' .. SelectItem.Weight, 'white')
      -- Slot 6-Left : Defense
      gui.text(EquipX, EquipY + spacer * 6, 'Defense : ' .. SelectItem.Defense, 'white')
      -- Slot 6-Right: Evade
      gui.text(EquipXR, EquipY + spacer * 6, 'Evade : ' .. SelectItem.Evade, 'white')
      -- Slot 7-Left : Magic Defense
      gui.text(EquipX, EquipY + spacer * 7, 'MDefense: ' .. SelectItem.MagDefense, 'white')
      -- Slot 7-Right: Magic Evade
      gui.text(EquipXR, EquipY + spacer * 7, 'MEvade: ' .. SelectItem.MagEvade, 'white')
      -- Slot 8 : Special Armor Properties
      gui.text(EquipX, EquipY + spacer * 8, readActiveBits(SelectItem.Special, TableArmorProperty), 'green')
      -- Slot 9 : Equipment's Elemental Defense
      showEleDefense(EquipX, EquipY + spacer * 9, EleDefenseDef(SelectItem.EleDefense))
      -- Slots 10-13 : Status Prop
      --gui.text(EquipX-5,EquipY+spacer*10, SelectItem.StatusProp, c.Blue)
      showStatusProp(StatDefenseDef(SelectItem.StatusProp), EquipX, EquipY + spacer * 10)
      -- Slot 14 : Stats increased / Elemental Booster
      if SelectItem.StatsUpCheck == 1 then -- if showing stats
        if SelectItem.StatsUp > 0 then -- if stats are actually increased
          gui.text(EquipX, EquipY + spacer * 14,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, 4) ..
          TableStatValue[SelectItem.StatsValue + 1][1], c.Yellow)
        end
        if SelectItem.StatsValue >= 3 and SelectItem.StatsValue <= 6 then -- if stats are also lowered
          gui.text(EquipXR, EquipY + spacer * 14,
            readActiveBits(SelectItem.StatsUp, TableStatBonus, - 4) ..
          TableStatValue[SelectItem.StatsValue + 1][2], 'grey')
        end
        -- else show boosted elements
      else gui.text(EquipX, EquipY + spacer * 14, "Boosts: " .. readActiveBits(SelectItem.EleBoost, TableElement), c.Green)


      end
    end

    if SelectItem.itemType == 'Nothing' or SelectItem.EquipType == 0 or point < 10 then
      -- Slot 0-Left: Strength
      gui.text(EquipX, EquipY + spacer * 0, "Strength : "..SelectChar.EqStr, "white")
      -- Slot 1 : Agility..
      gui.text(EquipX, EquipY + spacer * 1, "Agility  : "..SelectChar.EqAgi, "white")
      -- Slot 2 : Vitality..
      gui.text(EquipX, EquipY + spacer * 2, "Vitality : "..SelectChar.EqVit, "white")
      -- Slot 3 : Magic Power..
      gui.text(EquipX, EquipY + spacer * 3, "Magic Pow: "..SelectChar.EqMag, "white")
      -- Slot 0-Right : Total AttPow
      gui.text(EquipXR, EquipY + spacer * 0, 'Att: '..SelectChar.AttPow, 'white')
      -- Slot 1-Right : Total Def..
      gui.text(EquipXR, EquipY + spacer * 1, 'Def: '..SelectChar.Def, 'white')
      -- Slot 2-Right : Total Evade..
      gui.text(EquipXR, EquipY + spacer * 2, 'Eva: '..SelectChar.Evade, 'white')
      -- Slot 3-Right : Total MagDef..
      gui.text(EquipXR, EquipY + spacer * 3, 'MDF: '..SelectChar.MagDef, 'white')
      -- Slot 4-Right : Total MagEvade..
      gui.text(EquipXR, EquipY + spacer * 4, 'MEV: '..SelectChar.MagEvade, 'white')
    else
      -- Slot 0-Left: Strength
      showCompare(EquipX, EquipY + spacer * 0, "Strength :", SelectChar.EqStr, Equip.Str, "white")
      -- Slot 1 : Agility
      showCompare(EquipX, EquipY + spacer * 1, "Agility  :", SelectChar.EqAgi, Equip.Agi, "white")
      -- Slot 2 : Vitality
      showCompare(EquipX, EquipY + spacer * 2, "Vitality :", SelectChar.EqVit, Equip.Vit, "white")
      -- Slot 3 : Magic Power
      showCompare(EquipX, EquipY + spacer * 3, "Magic Pow:", SelectChar.EqMag, Equip.Mag, "white")
      -- Slot 0-Right : Total AttPow
      showCompare(EquipXR, EquipY + spacer * 0, 'Att:', SelectChar.AttPow, Equip.AttPow, 'white', 3)
      -- Slot 1-Right : Total Def
      showCompare(EquipXR, EquipY + spacer * 1, 'Def:', SelectChar.Def, Equip.Def, 'white')
      -- Slot 2-Right : Total Evade
      showCompare(EquipXR, EquipY + spacer * 2, 'Eva:', SelectChar.Evade, Equip.Eva, 'white')
      -- Slot 3-Right : Total MagDef
      showCompare(EquipXR, EquipY + spacer * 3, 'MDF:', SelectChar.MagDef, Equip.MagDef, 'white')
      -- Slot 4-Right : Total MagEvade
      showCompare(EquipXR, EquipY + spacer * 4, 'MEV:', SelectChar.MagEvade, findNewMagEva(SelectChar, SelectItem, point), 'white')
    end
    -- Slot 4 : Character's total Elemental Defense
    showEleDefense(EquipX, EquipY + spacer * 4, Equip)
  end

  -- Battle!
  if DisplayBattleInfo then

    local critHP = "" -- If enemy HP is in capture range

    -- Draws character's Box
    drawBorderBox( 104, 159, 143, 55, 'white')

    -- Draws enemy's Box
    --drawBorderBox(   9, 159,  94,  55, 'white')

    -- swap battlepages
    -- battlePage  is for character info
    -- enemyPage is for enemy info

    if keydown.R and RDown == false then
      RDown = true
      battlePage = battlePage + 1
    end
    if keydown.R == false then
      RDown = false
    end
    if keydown.L and LDown == false then
      LDown = true
      enemyPage = enemyPage + 1
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
    gui.text(10, 154, positionString(enemyPage, enemyPageMax), 'red')
    -- Display current battlepage
    gui.text(108, 154, positionString(battlePage, battlePageMax), 'white')

    -- Determine which enemies are hidden or visible
    --visible = getBitTable( readByte(0x7E3EF2), 8) -- initial visible? when formations change, this doesn't reflect
    visible = getBitTable( readByte(0x7E00DE), 8) -- currently visible

    local boxwidth = 60 -- Enemy's ATB box width

    for i = 1, NoEnemies do
      -- Populate the enemy's information
      enemy[i] = EnemyInfo(i)

      -- Display the enemy's information
      -- Need to find a way to hide info when running away from battle

      if visible[9 - i] == 1 and enemy[i].Name ~= 65535 then
        -- HP - shows "1) HP:50/100"
        critHP = "white"
        if enemy[i].CurrentHp <= enemy[i].TotalHp / 2 then
          critHP = "yellow"
        end
        if enemy[i].CurrentHp <= enemy[i].TotalHp / 8 then
          critHP = "orange"
        end

        local enX = determineX(10 * enemy[i].PositionX)
        local enY = 10 * enemy[i].PositionY

        gui.text ( offsetX + (enX),
          offsetY + (enY) + 0 * (gapY),
          i .. ') HP: ' .. enemy[i].CurrentHp .. '/' .. enemy[i].TotalHp,
        critHP)
        -- Name & Level - shows "L1 Goblin "
        gui.text ( offsetX + (enX),
          offsetY + (enY) + - 1 * (gapY),
          'L' .. enemy[i].Level .. ' ' .. findEnemyName(enemy[i]),
        "white")

        gui.transparency(1)
        -- Attack Gauge (painted)
        gui.drawbox( offsetX + (enX),
          offsetY + (enY) + 1 * (gapY),
          offsetX + (enX) + boxwidth,
          offsetY + (enY) + 1 * (gapY) + 2,
        'yellow')
        gui.drawbox( offsetX + (enX) + boxwidth * (enemy[i].AttackGauge / 128),
          offsetY + (enY) + 1 * (gapY),
          offsetX + (enX) + boxwidth,
          offsetY + (enY) + 1 * (gapY) + 2,
        'black')


        -- Enemy Status Effects
        if enemyPage == 0 then
          -- Status
          if enemy[i].StatusC > 0 then -- Curable
            gui.text ( offsetX + (enX),
              offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
              readActiveBits(enemy[i].StatusC, TableStatusC),
            "cyan")
            enemy[i].statusgap = enemy[i].statusgap + 1
          end

          if enemy[i].StatusD > 0 then -- Dispel
            gui.text ( offsetX + (enX),
              offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
              readActiveBits(enemy[i].StatusD, TableStatusD),
            "magenta")
            enemy[i].statusgap = enemy[i].statusgap + 1
          end

          if enemy[i].StatusT > 0 then -- Temporary
            gui.text ( offsetX + (enX),
              offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
              readActiveBits(enemy[i].StatusT, TableStatusT),
            "red")
            enemy[i].statusgap = enemy[i].statusgap + 1
          end

          if enemy[i].StatusP > 0 then -- Perm
            gui.text ( offsetX + (enX),
              offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
              readActiveBits(enemy[i].StatusP, TableStatusP),
            "yellow")
          end
        end

        -- Enemy Creature Type
        if enemyPage == 1 then
          gui.text ( offsetX - 25 + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            "Type: " .. readActiveBits(enemy[i].Type, TableCreature),
          "white")
        end

        -- Enemy Elemental Affinities
        if enemyPage == 2 then
          showEleDefense( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
          enemy[i])
        end

        -- Enemy Status Immunities
        if enemyPage == 3 then
          gui.text ( offsetX + (enX ) - 20,
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            "Imm",
          c.Pink)
          gui.text ( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            string.lower(readActiveBits(enemy[i].ImmuneC, TableStatusC)),
          c.Pink)
          enemy[i].statusgap = enemy[i].statusgap + 1
          gui.text ( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            string.lower(readActiveBits(enemy[i].ImmuneD, TableStatusD)),
          c.Pink)
          enemy[i].statusgap = enemy[i].statusgap + 1
          gui.text ( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            string.lower(readActiveBits(enemy[i].ImmuneT, TableStatusT)),
          c.Pink)
          enemy[i].statusgap = enemy[i].statusgap + 1
        end

        -- Stealables
        if enemyPage == 4 then

          -- Enemy MP (you can steal it!)
          if enemy[i].CurrentMp > 0 then
            gui.text ( offsetX + (enX),
              offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
            enemy[i].CurrentMp .. " MP", "cyan")
            enemy[i].statusgap = enemy[i].statusgap + 1
          end
          -- common steal
          gui.text ( offsetX + (enX ) - 25,
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
          "Steal", c.Yellow)
          gui.text( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
          TableItemID[enemy[i].StealCommon + 1], c.Yellow)
          enemy[i].statusgap = enemy[i].statusgap + 1
          -- rare steal
          gui.text ( offsetX + (enX ) - 25,
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
          " Rare", c.Yellow)
          gui.text( offsetX + (enX),
            offsetY + (enY) + enemy[i].statusgap * (gapY) - 3,
          TableItemID[enemy[i].StealRare + 1], c.Yellow)
        end
      end
    end


    for i = 1, NoCharacters do
      gui.transparency(0) -- Have no transparency

      -- Populate the character's information
      character[i] = CharacterInfo(i)
      -- Display the character's information
      if math.floor(character[i].Character / 0x40) % 2 == 0 then -- Display only info of current party
        gui.text ( 108,
          154 + 12 * i,
          'L' .. character[i].Level ..' '.. TableCharacter[(character[i].Character) % 8 + 1],
        "white")

        if battlePage == 0 then -- Cureable and Dispellable Status
          gui.text (108, 210, "Status C", "cyan")
          gui.text (147, 151 + 12 * i,
          '- ' .. readStatus(character[i].StatusC, character[i].InitialC, TableStatusC), "cyan")
          gui.text (108, 216, "Status D", "magenta")
          gui.text (147, 157 + 12 * i,
          '- ' .. readStatus(character[i].StatusD, character[i].InitialD, TableStatusD), "magenta")
        end
        if battlePage == 1 then -- Temp and Perm Status
          gui.text (108, 210, "Status T", "red")
          gui.text (147, 151 + 12 * i,
          '- ' .. readStatus(character[i].StatusT, character[i].InitialT, TableStatusT), "red")
          gui.text (108, 216, "Status P", "yellow")
          gui.text (147, 157 + 12 * i,
          '- ' .. readActiveBits(character[i].StatusP, TableStatusP), "yellow")
        end
        if battlePage == 2 then -- Elemental Defense
          gui.text (108, 210, "Element Def *:abs 0:imm #:half X:weak", "orange")
          showEleDefense(150, 154 + 12 * i, character[i])
        end
        if battlePage == 3 then -- Elemental Damage Boost
          gui.text (108, 210, "Element Damage Boost", "green")
          gui.text (147, 154 + 12 * i,
          '+ ' .. readActiveBits(character[i].ElementBoost, TableElement), "green")
        end
        if battlePage == 4 then -- Song Stat +
          gui.text (147, 154 + 12 * i, "L+"..character[i].HeroSong, "green")
          gui.text (167, 154 + 12 * i, "A+"..character[i].SpeedSong, "yellow")
          gui.text (187, 154 + 12 * i, "s+"..character[i].PowSong, "red")
          gui.text (207, 154 + 12 * i, "M+"..character[i].MagSong, c.Purple)
          gui.text (108, 210, "Song Boosts", c.Pink)
        end
        gui.transparency(1) -- Have small transparency
        -- Display characters' HP & MP
        gui.text ( determineX(215),
          47 + 24 * i,
          character[i].CurrentHp .. '/' .. character[i].TotalHp,
        "green")

        gui.text ( determineX(215),
          54 + 24 * i,
          character[i].CurrentMp .. '/' .. character[i].TotalMp,
        "cyan")
      end
    end
  else
    Flippy = false;
  end


  if DisplayMap then
    gui.transparency(0) -- Have no transparency
    local RightLine = 212
    if keydown.R and RDown == false then
      RDown = true
      mapPage = mapPage + 1
    end
    if keydown.R == false then
      RDown = false
    end
    if mapPage > mapPageMax then
      mapPage = 0
    end

    -- Display current mapPage
    gui.text( offsetX + RightLine,
    offsetY + 0 * (gapY), positionString(mapPage, mapPageMax), 'white')
    if mapPage == 0 then
      local gil = readRange(0x7E0947, 3) -- Gil, three bytes
      -- GIL
      gui.text ( offsetX + RightLine,
      offsetY + 1 * (gapY), "$"..gil, c.Yellow)

      -- In-game clock timer
      gui.text ( offsetX + RightLine,
        offsetY + 2 * (gapY),
      MakeTime(memory.readdword(0x7E094A)), "red" )
      -- In-game event timer
      --gui.text ( offsetX + RightLine,
      --		   offsetY + 2*(gapY),
      --		   PadNum(readWord(0x7E0AFC),7) )

      -- # of steps in world map
      --gui.text ( offsetX + RightLine,
      --		   offsetY + 2*(gapY),
      --		   readByte(0x7E16A9) )

      -- Coordinates
      gui.text ( offsetX + RightLine,
        offsetY + 3 * (gapY),
      ""..readByte(0x7E0AD8) .. ',' .. readByte(0x7E0AD9))
    end
    if mapPage == 1 then
      local escapes = readByte(0x7E09B5)
      local battles = readByte(0x7E09C0)
      local saves = readByte(0x7E09C2)
      -- # of battles
      gui.text ( offsetX + RightLine,
        offsetY + 1 * (gapY),
      "Battles:"..battles, c.Yellow )

      -- # of escapes
      gui.text ( offsetX + RightLine,
        offsetY + 2 * (gapY),
      "Escapes:"..escapes, c.Orange )

      -- # of saves
      gui.text ( offsetX + RightLine,
        offsetY + 3 * (gapY),
      "Saves  :"..saves, c.Cyan )
    end
    if mapPage == 2 then
      local BocoX = readByte(0x7E0ADF)
      local BocoY = readByte(0x7E0AE0)
      local DragonX = readByte(0x7E0AE7)
      local DragonY = readByte(0x7E0AE8)
      local JocoX = readByte(0x7E0AE3)
      local JocoY = readByte(0x7E0AE4)
      local AirshipX = readByte(0x7E0AF3)
      local AirshipY = readByte(0x7E0AF4)

      --  Boco oordinates
      gui.text ( offsetX + RightLine - 20,
        offsetY + 1 * gapY,
      "Boco:", c.Yellow)
      gui.text ( offsetX + RightLine,
        offsetY + 1 * (gapY),
      ""..BocoX .. ',' .. BocoY, c.Yellow)
      -- Airship oordinates
      gui.text ( offsetX + RightLine - 32,
        offsetY + 2 * gapY,
      "Airship:", c.Tan)
      gui.text ( offsetX + RightLine,
        offsetY + 2 * (gapY),
      ""..AirshipX .. ',' .. AirshipY, c.Tan)
      -- Airship oordinates
      gui.text ( offsetX + RightLine - 32,
        offsetY + 3 * gapY,
      "Blackie:", c.Purple)
      gui.text ( offsetX + RightLine,
        offsetY + 3 * (gapY),
      ""..JocoX .. ',' .. JocoY, c.Purple)

    end
  end
  snes9x.frameadvance()

end
