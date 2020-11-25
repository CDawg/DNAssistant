--[==[
Copyright ©2020 Porthios of Myzrael
The contents of this addon, excluding third-party resources, are
copyrighted to Porthios with all rights reserved.
This addon is free to use and the authors hereby grants you the following rights:
1. You may make modifications to this addon for private use only, you
   may not publicize any portion of this addon.
2. Do not modify the name of this addon, including the addon folders.
3. This copyright notice shall be included in all copies or substantial
  portions of the Software.
All rights not explicitly addressed in this license are reserved by
the copyright holders.
]==]--

DEBUG = false

DNAGlobal = {}
DNAGlobal.name    = "Destructive Nature Assistant"
DNAGlobal.dir     = "Interface/AddOns/DNAssistant/"
DNAGlobal.vmajor  = 1
DNAGlobal.vminor  = 203
DNAGlobal.width   = 980
DNAGlobal.height  = 550
--DNAGlobal.font    = "Fonts/ARIALN.TTF"
--DNAGlobal.font    = DNAGlobal.dir .. "Fonts/Verdana.ttf"
DNAGlobal.font    = "Fonts/FRIZQT__.TTF"
DNAGlobal.btn_w   = 130
DNAGlobal.btn_h   = 25

DNAGlobal.prefix  = "dnassist"
DNAGlobal.version = DNAGlobal.vmajor .. "." .. DNAGlobal.vminor
--DNAGlobal.background="Interface/FrameGeneral/UI-Background-Rock"
--DNAGlobal.background="Interface/Garrison/GarrisonShipMissionParchment"
DNAGlobal.background = "Interface/Garrison/GarrisonMissionParchment"
DN = {}

date_day = date("%y-%m-%d")
timestamp = date("%y-%m-%d %H:%M:%S")

player = {}
player.name = UnitName("player")
player.realm = GetRealmName()
player.combine=player.name .. "-" .. player.realm

total = {}
total.warriors= 0
total.rogues = 0
total.hunters = 0
total.paladins= 0
total.shamans= 0
total.priests = 0
total.warlocks= 0
total.mages = 0
total.druids = 0
total.warriors_dps = 0 --dps warrs called to OT
total.druids_dps = 0 --dps druids called to OT
total.paladins_dps = 0 --dps paladins called to OT
total.shaman_dps = 0 --dps shamans called to OT
--
total.tanks = 0
total.healers = 0
total.melee = 0
total.range = 0
--
total.raid = 0

note_color = "|cffe2dbbf" --extra note assignment color

function debug(msg)
  if (DEBUG) then
    return print("DEBUG: " .. msg)
  end
end

--single array
function singleKeyFromValue(_array, value)
  for k,v in pairs(_array) do
    if v==value then return k end
  end
  return nil
end
--matrix array
function multiKeyFromValue(_array, value)
  for k,v in pairs(_array) do
    if v[1]==value then return k end
  end
  return nil
end

function reindexArray(input, reval)
  local n=#input
  for i=1,n do
    if reval[input[i]] then
      input[i]=nil
    end
  end
  local j=0
  for i=1,n do
    if input[i]~=nil then
      j=j+1
      input[j]=input[i]
    end
  end
  for i=j+1,n do
    input[i]=nil
  end
end

function split(s, delimiter)
  result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

function isempty(s)
  return s == nil or s == ''
end

function table.merge(t1, t2)
 for k,v in ipairs(t2) do
    table.insert(t1, v)
 end
  return t1
end

function removeValueFromArray(array, value)
  if (value) then
    remove_key = singleKeyFromValue(array, value)
    array[remove_key] = nil
    reindexArray(array, array)
  end
end

player = {}
player.name = UnitName("player")
player.realm = GetRealmName()
player.combine=player.name .. "-" .. player.realm

DNACheckbox = {}

DNASlots = {}
DNASlots.tank = 6
DNASlots.heal = 12

MAX_FRAME_LINES = 25 --also setup the same for the assign window

DNAInstance = {}
DNARaidBosses = {}

function DN:ChatNotification(msg)
  print("|cff00e3d5" .. DNAGlobal.name .. "|r " .. msg)
end

function DN:PromoteToAssistant(name)
  DN:ChatNotification("Auto promoted: " .. name)
  PromoteToAssistant(name)
end

function DN:SetupDefaultVars() --called only when a new profile is created
  DNACheckbox["AUTOPROMOTE"]:SetChecked(true)
  DNA[player.combine]["CONFIG"]["AUTOPROMOTE"] = "ON"
  DNACheckbox["RAIDCHAT"]:SetChecked(true)
  DNA[player.combine]["CONFIG"]["RAIDCHAT"] = "ON"
end

function DN:BuildGlobalVars()
  if (DNA == nil) then
    DNA = {}
  end
  if (DNA[player.combine] == nil) then
    DNA[player.combine] = {}
    if (DNA[player.combine]["CONFIG"] == nil) then
      DNA[player.combine]["CONFIG"] = {}
    end
    if (DNA[player.combine]["ASSIGN"] == nil) then
      DNA[player.combine]["ASSIGN"] = {}
    end
    if (DNA[player.combine]["LOOTLOG"] == nil) then
      DNA[player.combine]["LOOTLOG"] = {}
    end
    DN:ChatNotification("Creating Raid Profile: " .. player.combine)
    DN:SetupDefaultVars()
  else
    DN:ChatNotification("Loading Raid Profile: " .. player.combine)
  end
end

function DN:SendPacket(packet, filtered)
  filteredPacket = nil
  if (filtered) then
    filteredPacket = packet:gsub("%s+", "") --filter spaces
  else
    filteredPacket = packet
  end
  C_ChatInfo.SendAddonMessage(DNAGlobal.prefix, filteredPacket, "RAID")
end

DNAClasses={
  "Warrior",
  "Druid",
  "Priest",
  "Paladin",
  "Rogue",
  "Mage",
  "Warlock",
  "Hunter",
  "Shaman"
}

TANK="T"
HEAL="H"

netCode = {
  --packet codes
  {"tanks",   "0xEFTa"},
  {"healers", "0xEFHe"},
  --class codes
  {"Warrior", "0xEFWa"},
  {"Hunter",  "0xEFHu"},
  {"Druid",   "0xEFDr"},
  {"Rogue",   "0xEFRo"},
  {"Warlock", "0xEFLo"},
  {"Paladin", "0xEFPa"},
  {"Shaman",  "0xEFSh"},
  {"Priest",  "0xEFPr"},
  {"Mage",    "0xEFMa"},
  --app codes
  {"posttoraid","0xEFPo"},
  {"version",   "0xEFVe"},
  {"readyyes",  "0xEFRy"},
  {"readyno",   "0xEFNr"},
  {"postdkp",   "0xEFPd"},
  {"author",    "0xEFAu"},
}

DNARaidMarkerText={
  "",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_7",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_4",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_2",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_6",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_3",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_5",
  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_1",
}

DNARaidMarkerIcon={
  "",
  "{skull}",
  "{cross}",
  "{triangle}",
  "{circle}",
  "{square}",
  "{diamond}",
  "{moon}",
  "{star}",
}

DNARaidMarkers={
  {"",   ""}, --leave blank for boss icons that are dynamic
  {"{skull}",   "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8"},
  {"{cross}",   "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_7"},
  {"{triangle}","Interface/TARGETINGFRAME/UI-RaidTargetingIcon_4"},
  {"{circle}",  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_2"},
  {"{square}",  "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_6"},
  {"{diamond}", "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_3"},
  {"{moon}",    "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_5"},
  {"{star}",    "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_1"},
  {"{alert}",   "Interface/DialogFrame/UI-Dialog-Icon-AlertNew"},
  {"{up}",       DNAGlobal.dir .. "images/arrow-up"},
  {"{down}",     DNAGlobal.dir .. "images/arrow-down"},
  {"{left}",     DNAGlobal.dir .. "images/arrow-left"},
  {"{right}",    DNAGlobal.dir .. "images/arrow-right"},
}

icon_boss    = DNARaidMarkers[1][2]
icon_skull   = DNARaidMarkers[2][2]
icon_cross   = DNARaidMarkers[3][2]
icon_triangle= DNARaidMarkers[4][2]
icon_circle  = DNARaidMarkers[5][2]
icon_square  = DNARaidMarkers[6][2]
icon_diamond = DNARaidMarkers[7][2]
icon_moon    = DNARaidMarkers[8][2]
icon_star    = DNARaidMarkers[9][2]
icon_alert   = DNARaidMarkers[10][2]
icon_up      = DNARaidMarkers[11][2]
icon_down    = DNARaidMarkers[12][2]
icon_left    = DNARaidMarkers[13][2]
icon_right   = DNARaidMarkers[14][2]

function DN:ClassColorText(frame, class)
  local rgb={0.60, 0.60, 0.60} --offline gray
  if (class == "Warrior") then
    rgb={0.78, 0.61, 0.43}
  end
  if (class == "Warlock") then
    rgb={0.53, 0.53, 0.93}
  end
  if (class == "Rogue") then
    rgb={1.00, 0.96, 0.41}
  end
  if (class == "Druid") then
    rgb={1.00, 0.49, 0.04}
  end
  if (class == "Hunter") then
    rgb={0.67, 0.83, 0.45}
  end
  if (class == "Paladin") then
    rgb={0.96, 0.55, 0.73}
  end
  if (class == "Shaman") then
    rgb={0.00, 0.44, 0.87}
  end
  if (class == "Mage") then
    rgb={0.25, 0.78, 0.92}
  end
  if (class == "Priest") then
    rgb={1.00, 1.00, 1.00}
  end
  if (class == "Empty") then --empty slot
    rgb={0.20, 0.20, 0.20}
  end
  return frame:SetTextColor(rgb[1],rgb[2],rgb[3])
end

function DN:ClassColorAppend(name, class)
  local rgb="dedede" --offline gray
  if (class == "Warrior") then
    rgb="C79C6E"
  end
  if (class == "Warlock") then
    rgb="8787ED"
  end
  if (class == "Rogue") then
    rgb="FFF569"
  end
  if (class == "Druid") then
    rgb="FF7D0A"
  end
  if (class == "Hunter") then
    rgb="A9D271"
  end
  if (class == "Paladin") then
    rgb="F58CBA"
  end
  if (class == "Shaman") then
    rgb="0070DD"
  end
  if (class == "Mage") then
    rgb="40C7EB"
  end
  if (class == "Priest") then
    rgb="ffffff"
  end
  if (class == "Empty") then --empty slot
    rgb="ededed"
  end
  return "|cff" .. rgb .. name .. "|r"
end

DNAGuild={}
DNAGuild["member"] = {}
DNAGuild["rank"] = {}

DNARaid={}
DNARaid["member"] = {}
DNARaid["class"] = {}
DNARaid["race"] = {}
DNARaid["groupid"] = {}
DNARaid["assist"] = {}

DNABossIcon = nil
DNABossMap = nil

DNAFrameViewScrollChild_tank = {}
DNAFrameViewScrollChild_mark = {}
DNAFrameViewScrollChild_heal = {}
DNAFrameViewBossMap = {}
DNAFrameAssignScrollChild_tank = {}
DNAFrameAssignScrollChild_mark = {}
DNAFrameAssignScrollChild_heal = {}
DNAFrameAssignPersonal={}
DNAFrameAssignPersonalMark={}
DNAFrameAssignPersonalText={}
DNAFrameAssignBossIcon = {}
DNAFrameAssignBossText = {}
DNAFrameAssignBossMap = {}
DNAFrameAssignAuthor = {}

function isItem(compare, item) --dropdown packets that are filtered from spaces
  local boss_icon = nil
  filteredItem = item:gsub("%s+", "")
  if ((compare == item) or (compare == filteredItem)) then
    DNAFrameAssignBossText:SetText(item)
    for i=1, table.getn(DNARaidBosses) do
      boss_icon = multiKeyFromValue(DNARaidBosses[i], item)
      if (boss_icon) then
        DNABossIcon = DNARaidBosses[i][boss_icon][2]
      end
    end
    return true
  else
    return false
  end
end
