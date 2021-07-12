--[==[
Copyright ©2020 Porthios of Myzrael
The contents of this addon, excluding third-party resources, are
copyrighted to Porthios with all rights reserved.
This addon is free to use and the members hereby grants you the following rights:
1. You may make modifications to this addon for private use only, you
   may not publicize any portion of this addon.
2. Do not modify the name of this addon, including the addon folders.
3. This copyright notice shall be included in all copies or substantial
  portions of the Software.
All rights not explicitly addressed in this license are reserved by
the copyright holders.
]==]--

MAX_MEMBER_PROFESSIONS = 800
MAX_MEMBER_RECIPES = 255 --we can't add more than the packet will allow us

local DNAProfScrollFrame_w = 200
local DNAProfScrollFrame_h = 500

DNAProfessions = {
  {"Alchemy",       171, "trade_alchemy"},
  {"Cooking",       185, "inv_misc_food_15"},
  {"Engineering",   202, "trade_engineering"},
  {"Fishing",       356, "trade_fishing"},
  {"First Aid",     129, "spell_holy_sealofsacrifice"},
  {"Tailoring",     197, "trade_tailoring"},
  {"Skinning",      393, "inv_misc_pelt_wolf_01"},
  {"Blacksmithing", 164, "trade_blacksmithing"},
  {"Jewelcrafting", 755, "inv_misc_gem_01"},
  {"Herbalism",     182, "spell_nature_naturetouchgrow"},
  {"Enchanting",    333, "trade_engraving"},
  {"Leatherworking",165, "inv_misc_armorkit_17"},
  {"Mining",        186, "trade_mining"},
}

local cachedProf = DNAProfessions[1][1]

DNAButtonProf={}
DNAButtonProf_y=0
for k,v in ipairs(DNAProfessions) do
  DNAButtonProf_y = DNAButtonProf_y +24
  DNAButtonProf[v[1]] = CreateFrame("Button", nil, page["Professions"], "BackdropTemplate")
  DNAButtonProf[v[1]]:SetPoint("TOPLEFT", 25, -30-DNAButtonProf_y)
  DNAButtonProf[v[1]]:SetSize(DNAGlobal.btn_w+30, DNAGlobal.btn_h)
  DNAButtonProf[v[1]].text = DNAButtonProf[v[1]]:CreateFontString(nil, "ARTWORK")
  DNAButtonProf[v[1]].text:SetFont(DNAGlobal.font, DNAGlobal.fontSize, "OUTLINE")
  DNAButtonProf[v[1]].text:SetPoint("TOPLEFT", 28, -6)
  DNAButtonProf[v[1]].text:SetText(v[1])
  DNAButtonProf[v[1]].icon = DNAButtonProf[v[1]]:CreateTexture(nil, "OVERLAY")
  DNAButtonProf[v[1]].icon:SetTexture("Interface/ICONS/" .. v[3])
  DNAButtonProf[v[1]].icon:SetPoint("TOPLEFT", 3, -3)
  DNAButtonProf[v[1]].icon:SetSize(20, 20)
  DNAButtonProf[v[1]]:SetBackdrop({
    bgFile = DNAGlobal.slotbg,
    edgeFile = DNAGlobal.slotborder,
    edgeSize = 12,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  DNAButtonProf[v[1]]:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
  DNAButtonProf[v[1]]:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(1,1,1,1)
  end)
  DNAButtonProf[v[1]]:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
  end)
  DNAButtonProf[v[1]]:SetScript("OnClick", function()
    DN:GetGuildProfessions(v[1])
  end)
end

DNAProfScrollFrame = CreateFrame("Frame", DNAProfScrollFrame, page["Professions"], "InsetFrameTemplate")
DNAProfScrollFrame:SetWidth(DNAProfScrollFrame_w+20)
DNAProfScrollFrame:SetHeight(DNAProfScrollFrame_h)
DNAProfScrollFrame:SetPoint("TOPLEFT", 200, -50)
DNAProfScrollFrame:SetFrameLevel(5)
DNAProfScrollFrame.text = DNAProfScrollFrame:CreateFontString(nil, "ARTWORK")
DNAProfScrollFrame.text:SetFont(DNAGlobal.font, DNAGlobal.fontSize, "OUTLINE")
DNAProfScrollFrame.text:SetPoint("TOPLEFT", DNAProfScrollFrame, "TOPLEFT", 0, 15)
DNAProfScrollFrame.text:SetText("Guild Members")
DNAProfScrollFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, DNAProfScrollFrame, "UIPanelScrollFrameTemplate")
DNAProfScrollFrame.ScrollFrame:SetPoint("TOPLEFT", DNAProfScrollFrame, "TOPLEFT", 3, -3)
DNAProfScrollFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", DNAProfScrollFrame, "BOTTOMRIGHT", 10, 4)
local DNAProfScrollFrameScrollChildFrame = CreateFrame("Frame", DNAProfScrollFrameScrollChildFrame, DNAProfScrollFrame.ScrollFrame)
DNAProfScrollFrameScrollChildFrame:SetSize(DNAProfScrollFrame_w, DNAProfScrollFrame_h)
DNAProfScrollFrame.ScrollFrame:SetScrollChild(DNAProfScrollFrameScrollChildFrame)
DNAProfScrollFrame.ScrollFrame.ScrollBar:ClearAllPoints()
DNAProfScrollFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", DNAProfScrollFrame.ScrollFrame, "TOPRIGHT", 0, -17)
DNAProfScrollFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", DNAProfScrollFrame.ScrollFrame, "BOTTOMRIGHT", -42, 14)
DNAProfScrollFrame.MR = DNAProfScrollFrame:CreateTexture(nil, "BACKGROUND", DNAProfScrollFrame, -2)
DNAProfScrollFrame.MR:SetTexture(DNAGlobal.dir .. "images/scroll-mid-right")
DNAProfScrollFrame.MR:SetPoint("TOPLEFT", DNAProfScrollFrame_w-5, 0)
DNAProfScrollFrame.MR:SetSize(24, DNAProfScrollFrame_h)

local DNAMemberProfDetailFrame = CreateFrame("Frame", "DNAMemberProfDetailFrame", page["Professions"])
DNAMemberProfDetailFrame:SetPoint("TOPLEFT", 450, -60)
DNAMemberProfDetailFrame:SetWidth(200)
DNAMemberProfDetailFrame:SetHeight(100)
DNAMemberProfDetailFrame:SetFrameLevel(5)
DNAMemberProfDetailFrame:Hide()
local memberProfDetailBar = {}
memberProfDetailBarBack =  CreateFrame("Frame", nil, DNAMemberProfDetailFrame, "InsetFrameTemplate")
memberProfDetailBarBack:SetPoint("TOPLEFT", 0, -10)
memberProfDetailBarBack:SetSize(378, 24)
memberProfDetailBar = CreateFrame("Button", nil, memberProfDetailBarBack, "BackdropTemplate")
memberProfDetailBar:SetPoint("TOPLEFT", 2, -1)
memberProfDetailBar:SetSize(1, 21)
memberProfDetailBar:SetBackdrop({
  bgFile = "Interface/Buttons/BlueGrad64",
  edgeFile = "",
  edgeSize = 12,
  insets = {left=2, right=2, top=2, bottom=2},
})
memberProfDetailBar:SetFrameLevel(6)
memberProfDetailBar:SetBackdropColor(0.2, 0.2, 0.5, 1)

--bar text
local memberProfDetailText = {}
memberProfDetailText[1] = memberProfDetailBarBack:CreateFontString(nil, "TOOLTIP", 7)
memberProfDetailText[1]:SetFont(DNAGlobal.font, DNAGlobal.fontSize-1, "OUTLINE")
memberProfDetailText[1]:SetPoint("CENTER", 0, 0)
memberProfDetailText[1]:SetText("")

--misc details
memberProfDetailTextName = DNAMemberProfDetailFrame:CreateFontString(nil, "ARTWORK")
memberProfDetailTextName:SetFont(DNAGlobal.font, DNAGlobal.fontSize, "OUTLINE")
memberProfDetailTextName:SetPoint("TOPLEFT", 0, 10)
memberProfDetailTextName:SetText("")

local professionSlot={}
--local professionSlotText = {}
for i=1, MAX_MEMBER_PROFESSIONS do
  professionSlot[i] = {}
  professionSlot[i] = CreateFrame("button", professionSlot[i], DNAProfScrollFrameScrollChildFrame, "BackdropTemplate")
  professionSlot[i]:SetWidth(DNAProfScrollFrame_w-5)
  professionSlot[i]:SetHeight(raidSlot_h)
  professionSlot[i]:SetBackdrop({
    bgFile = DNAGlobal.slotbg,
    edgeFile = DNAGlobal.slotborder,
    edgeSize = 12,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  professionSlot[i]:SetBackdropColor(1, 1, 1, 0.3)
  professionSlot[i]:SetBackdropBorderColor(1, 0.98, 0.98, 0.30)
  professionSlot[i]:SetPoint("TOPLEFT", 0, (-i*18)+raidSlot_h-4)
  professionSlot[i].text = professionSlot[i]:CreateFontString(nil, "ARTWORK")
  professionSlot[i].text:SetFont(DNAGlobal.font, DNAGlobal.fontSize-1, "OUTLINE")
  professionSlot[i].text:SetPoint("TOPLEFT", 5, -4)
  professionSlot[i].text:SetText("")
  professionSlot[i].text:SetTextColor(0.6, 0.6, 0.6, 1)
  professionSlot[i]:SetScript('OnEnter', function()
    professionSlot[i]:SetBackdropBorderColor(1, 1, 0.6, 1)
  end)
  professionSlot[i]:SetScript('OnLeave', function()
    professionSlot[i]:SetBackdropBorderColor(1, 0.98, 0.98, 0.30)
  end)
  professionSlot[i]:SetScript('OnClick', function(self)
    DN:GetMemberProf(cachedProf, self.text:GetText())
  end)
  professionSlot[i]:Hide()
end

local profCount = 0
local profName = {}
local profPacketString = ""
local sentMyProfs = 1
function DN:SendMyProfessions(notification, author)
  sentMyProfs = sentMyProfs +1
  local profPacketString = ""
  if (notification) then
    sentMyProfs = 4
  end
  if (sentMyProfs == 4) then
    if (IsInGuild()) then
      local guildName, guildRankName, guildRankIndex, realm = GetGuildInfo("player")
      for skillIndex = 1, GetNumSkillLines() do
        local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(skillIndex)
        for k,v in ipairs(DNAProfessions) do
          if (v[1] == skillName) then
            local skillId = v[2]
            profName[skillName] = skillRank
          end
        end
      end

      for k,v in pairs(profName) do
        profPacketString = profPacketString .. k .. "," .. v .. ","
      end

      if (profPacketString) then
        profPacketString = profPacketString:sub(1, string.len(profPacketString) -1)
        if (notification) then
          DN:SendPacket(packetPrefix.professionN .. player.name .. "," .. guildName .. "," .. author .. "," .. profPacketString, false, "GUILD")
        else
          DN:SendPacket(packetPrefix.profession .. player.name .. "," .. guildName .. "," .. author .. "," .. profPacketString, false, "GUILD")
        end
      end

    end
  end
end

function DN:SaveGuildProfessions(prof_data)
  local member= prof_data[1]
  local guild = prof_data[2]
  local author= prof_data[3]
  local profN1= prof_data[4]
  local profL1= prof_data[5]
  local profN2= prof_data[6]
  local profL2= prof_data[7]
  local profN3= prof_data[8]
  local profL3= prof_data[9]
  local profN4= prof_data[10]
  local profL4= prof_data[11]
  local profN5= prof_data[12]
  local profL5= prof_data[13]
  if (IsInGuild()) then
    DNAProfScrollFrame.text:SetText(guild)
  end
  if (DNA["PROFESSIONS"] == nil) then
    DNA["PROFESSIONS"] = {}
  end
  if (DNA["PROFESSIONS"][guild] == nil) then
    DNA["PROFESSIONS"][guild] = {}
  end
  DNA["PROFESSIONS"][guild][member] = {} --flush all profs from toon and restart
  if (profN1) then
    DNA["PROFESSIONS"][guild][member][profN1] = profL1
  end
  if (profN2) then
    DNA["PROFESSIONS"][guild][member][profN2] = profL2
  end
  if (profN3) then
    DNA["PROFESSIONS"][guild][member][profN3] = profL3
  end
  if (profN4) then
    DNA["PROFESSIONS"][guild][member][profN4] = profL4
  end
  if (profN5) then
    DNA["PROFESSIONS"][guild][member][profN5] = profL5
  end
end

function DN:GetGuildProfessions(prof)
  for i=1, MAX_MEMBER_PROFESSIONS do
    professionSlot[i].text:SetText("")
    professionSlot[i]:Hide()
  end
  local guildMemberSort={}
  local memberCount = 0
  if (IsInGuild()) then
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
    --print("clicking " .. prof)
    --print("guild " .. guildName)
    for k,v in ipairs(DNAProfessions) do
      --DNAButtonProf[v[1]]:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
      DNAButtonProf[v[1]]:SetBackdropColor(0.7, 0.7, 0.7, 1)
    end
    --DNAButtonProf[prof]:SetBackdropBorderColor(1, 1, 0.5, 1)
    DNAButtonProf[prof]:SetBackdropColor(1, 1, 0.2, 1)
    DNAMemberProfDetailFrame:Hide()
    cachedProf = prof
    DNAProfScrollFrame.text:SetText(guildName .. " - " .. prof)
    if (DNA["PROFESSIONS"][guildName]) then
      for k in pairs(guildMemberSort) do
        guildMemberSort[k] = nil
      end
      for member,v in pairs(DNA["PROFESSIONS"][guildName]) do
        --print(member)
        for k,v in pairs(DNA["PROFESSIONS"][guildName][member]) do
          if (k == prof) then
            table.insert(guildMemberSort, member)
          end
        end
      end
    end

    table.sort(guildMemberSort)
    for profession,v in ipairs(guildMemberSort) do
      memberCount = memberCount +1
      professionSlot[memberCount].text:SetText(v)
      professionSlot[memberCount]:Show()
      for i=1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
        local guild_member = split(name, "-") --remove server
        if (v == guild_member[1]) then
          DN:ClassColorText(professionSlot[memberCount].text, "Offline")
          if (online) then
            DN:ClassColorText(professionSlot[memberCount].text, class)
          end
        end
      end
    end

  end
end

function DN:GetMemberProf(prof, member)
  local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
  if (DNA["PROFESSIONS"][guildName][member][prof]) then
    --print(DNA["PROFESSIONS"][guildName][member][prof])
    memberProfDetailText[1]:SetText(prof .. " ".. DNA["PROFESSIONS"][guildName][member][prof] ..  "/375")
    local skillLevel = tonumber(DNA["PROFESSIONS"][guildName][member][prof])
    --print(skillLevel)
    memberProfDetailBar:SetSize(skillLevel, 21)
    memberProfDetailTextName:SetText(member)
    DNAMemberProfDetailFrame:Show()
    DN:UpdateProfessionList(prof, member, skillLevel)
  end
end

local guildRosterArray={}
local nextGuildName=1
local countGuildOnline = 0
local profSendDelayTimer = 0
function ProfDelayTimerFrame()
  profSendDelayTimer = profSendDelayTimer+1
  if (guildRosterArray[profSendDelayTimer]) then
    --print(guildRosterArray[profSendDelayTimer])
    DN:SendPacket(packetPrefix.profrequest .. guildRosterArray[profSendDelayTimer] .. "," .. player.name, false, "GUILD")
  end
end
profsendDelay = C_Timer.NewTicker(1, ProfDelayTimerFrame, 1)
profsendDelay:Cancel()

function DN:ProfSendAlphaSync()
  for k in pairs(guildRosterArray) do --clear array
    guildRosterArray[k] = nil
  end
  for i=1, GetNumGuildMembers() do
    local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
    local guild_member = split(name, "-") --remove server
    if (online) then
      countGuildOnline = countGuildOnline +1
      table.insert(guildRosterArray, guild_member[1])
    end
  end
  table.sort(guildRosterArray)
  --print("DN:ProfSendAlphaSync()")
end

DNAProfSyncGuild = CreateFrame("Button", nil, page["Professions"], "UIPanelButtonTemplate")
DNAProfSyncGuild:SetSize(150, 24)
DNAProfSyncGuild:SetPoint("TOPLEFT", 230, -555)
DNAProfSyncGuild.text = DNAProfSyncGuild:CreateFontString(nil, "ARTWORK")
DNAProfSyncGuild.text:SetFont(DNAGlobal.font, DNAGlobal.fontSize, "OUTLINE")
DNAProfSyncGuild.text:SetPoint("CENTER", 0, 0)
DNAProfSyncGuild.text:SetText("Sync Guild")
DNAProfSyncGuild:SetFrameLevel(5)
DNAProfSyncGuild:SetScript('OnClick', function(self)
  if (IsInGuild()) then
    profsendDelay:Cancel()
    DN:ProfSendAlphaSync()
    --print(countGuildOnline)
    profsendDelay = C_Timer.NewTicker(0.320, ProfDelayTimerFrame, countGuildOnline)
    DN:ChatNotification("Collecting Guild ["..DNAGlobal.color.."Professions|r]")
    self:Hide()
  else
    print("|cfffaff04You are not in a guild.")
  end
end)

--local spellID = 26746 -- NW Bag
--local spellID = 22757 --Ele Sharpening stone
--local spellID = 12046 --simple kilt
--local spellID = 20020 --ench greater stam

function DN:HasSkill(spellID)
  --local spellName = GetSpellInfo(spellID)
  local hasSpell = IsPlayerSpell(spellID)
  --[==[
  if (spellName) then
    print("|Hspell:" .. spellID .."|h|r|cfffaff04[" .. spellName .. "]|r|h")
    print(hasSpell)
  else
    print("unknown spell")
  end
  ]==]--
  return hasSpell
end

function DN:LinkSkill(spellID)
  --[==[
  local spellName = GetSpellInfo(spellID)
  if (spellName) then
    return "|Hspell:" .. spellID .."|h|r|cfffaff04[" .. spellName .. "]|r|h"
  else
    return "unknown"
  end
  ]==]--
end

local DNAProfRecipeScrollFrame_w = 358
local DNAProfRecipeScrollFrame_h = 230

DNAProfRecipeScrollFrame = CreateFrame("Frame", DNAProfRecipeScrollFrame, DNAMemberProfDetailFrame, "InsetFrameTemplate")
DNAProfRecipeScrollFrame:SetWidth(DNAProfRecipeScrollFrame_w+20)
DNAProfRecipeScrollFrame:SetHeight(DNAProfRecipeScrollFrame_h)
DNAProfRecipeScrollFrame:SetPoint("TOPLEFT", 0, -36)
--DNAProfRecipeScrollFrame:SetFrameLevel(5)
--[==[
DNAProfRecipeScrollFrame.text = DNAProfRecipeScrollFrame:CreateFontString(nil, "ARTWORK")
DNAProfRecipeScrollFrame.text:SetFont(DNAGlobal.font, DNAGlobal.fontSize, "OUTLINE")
DNAProfRecipeScrollFrame.text:SetPoint("TOPLEFT", DNAProfRecipeScrollFrame, "TOPLEFT", 0, 15)
DNAProfRecipeScrollFrame.text:SetText("Recipes")
]==]--
DNAProfRecipeScrollFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, DNAProfRecipeScrollFrame, "UIPanelScrollFrameTemplate")
DNAProfRecipeScrollFrame.ScrollFrame:SetPoint("TOPLEFT", DNAProfRecipeScrollFrame, "TOPLEFT", 3, -3)
DNAProfRecipeScrollFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", DNAProfRecipeScrollFrame, "BOTTOMRIGHT", 10, 4)
local DNAProfRecipeScrollFrameScrollChildFrame = CreateFrame("Frame", DNAProfRecipeScrollFrameScrollChildFrame, DNAProfRecipeScrollFrame.ScrollFrame)
DNAProfRecipeScrollFrameScrollChildFrame:SetSize(DNAProfRecipeScrollFrame_w, DNAProfRecipeScrollFrame_h)
DNAProfRecipeScrollFrame.ScrollFrame:SetScrollChild(DNAProfRecipeScrollFrameScrollChildFrame)
DNAProfRecipeScrollFrame.ScrollFrame.ScrollBar:ClearAllPoints()
DNAProfRecipeScrollFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", DNAProfRecipeScrollFrame.ScrollFrame, "TOPRIGHT", 0, -17)
DNAProfRecipeScrollFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", DNAProfRecipeScrollFrame.ScrollFrame, "BOTTOMRIGHT", -42, 14)
DNAProfRecipeScrollFrame.MR = DNAProfRecipeScrollFrame:CreateTexture(nil, "BACKGROUND", DNAProfRecipeScrollFrame, -2)
DNAProfRecipeScrollFrame.MR:SetTexture(DNAGlobal.dir .. "images/scroll-mid-right")
DNAProfRecipeScrollFrame.MR:SetPoint("TOPLEFT", DNAProfRecipeScrollFrame_w-5, 0)
DNAProfRecipeScrollFrame.MR:SetSize(24, DNAProfRecipeScrollFrame_h)

DNAProfRecipeMatsFrame = CreateFrame("Frame", DNAProfRecipeScrollFrame, DNAMemberProfDetailFrame, "InsetFrameTemplate")
DNAProfRecipeMatsFrame:SetWidth(DNAProfRecipeScrollFrame_w+20)
DNAProfRecipeMatsFrame:SetHeight(220)
DNAProfRecipeMatsFrame:SetPoint("TOPLEFT", 0, -DNAProfRecipeScrollFrame_h-38)
DNAProfRecipeMatsFrame.text = DNAProfRecipeMatsFrame:CreateFontString(nil, "ARTWORK")
DNAProfRecipeMatsFrame.text:SetFont(DNAGlobal.font, DNAGlobal.fontSize-1, "OUTLINE")
DNAProfRecipeMatsFrame.text:SetPoint("TOPLEFT", 15, -10)
DNAProfRecipeMatsFrame.text:SetText("fff")

local recipeSlot={}

local recipeCount=0
for i=1, MAX_MEMBER_RECIPES  do
  recipeCount = recipeCount+1
  recipeSlot[i] = {}
  recipeSlot[i] = CreateFrame("button", recipeSlot[i], DNAProfRecipeScrollFrameScrollChildFrame, "BackdropTemplate")
  recipeSlot[i]:SetWidth(DNAProfRecipeScrollFrame_w-5)
  recipeSlot[i]:SetHeight(raidSlot_h)
  recipeSlot[i]:SetBackdrop({
    --bgFile = DNAGlobal.slotbg,
    edgeFile = DNAGlobal.slotborder,
    edgeSize = 12,
    insets = {left=2, right=2, top=2, bottom=2},
  })
  recipeSlot[i]:SetBackdropColor(1, 1, 1, 0.3)
  --recipeSlot[i]:SetBackdropBorderColor(1, 0.98, 0.98, 0.30)
  recipeSlot[i]:SetBackdropBorderColor(0, 0, 0, 0)
  recipeSlot[i]:SetPoint("TOPLEFT", 0, (-i*18)+raidSlot_h-4)
  recipeSlot[i].text = recipeSlot[i]:CreateFontString(nil, "ARTWORK")
  recipeSlot[i].text:SetFont(DNAGlobal.font, DNAGlobal.fontSize-1, "OUTLINE")
  recipeSlot[i].text:SetPoint("TOPLEFT", 15, -4)
  --recipeSlot[i].text:SetText(DN:LinkSkill(DNAProf.Enchanting[recipeCount]))
  recipeSlot[i].text:SetText("fff")
  --recipeSlot[i].text:SetTextColor(0.6, 0.6, 0.6, 1)
  recipeSlot[i]:SetScript('OnEnter', function()
    recipeSlot[i]:SetBackdropBorderColor(1, 1, 0.6, 1)
  end)
  recipeSlot[i]:SetScript('OnLeave', function()
    --recipeSlot[i]:SetBackdropBorderColor(1, 0.98, 0.98, 0.30)
    recipeSlot[i]:SetBackdropBorderColor(0, 0, 0, 0)
  end)
  recipeSlot[i]:SetScript('OnClick', function(self)
    local prof_data = split(self.text:GetText(), " | ")
    print(prof_data[1])
    print(prof_data[2])
    --local name, rank, icon, castTime, minRange, maxRange, Id = GetSpellInfo(self.text:GetText())
    --print(DNAProf.Reagents[prof_data[2]])
    local spellID = tonumber(prof_data[2])
    --print(DNAProf.Reagents[spellID])
    for k,v in pairs(DNAProf.Reagents[spellID]) do
      --print(tonumber(v[1]))
      --print(tonumber(v[7]))
    end
    local reagents = DNAProf.Reagents[spellID][6]
    local reagentCount=DNAProf.Reagents[spellID][7]
    print(reagents)
    for k,v in ipairs(reagents) do
      print(v)
      print(reagentCount[k])
    end
    -- [spellID] = { createdItemID, prof, minLvl, lowLvl, highLvl, reagents{}, reagentsCount{}, numCreatedItems }
  end)
end

function DN:UpdateProfessionList(prof, member, skillLevel)
  print("prof: " .. prof)
  print("member: " .. member)
  print("skillLevel: " .. skillLevel)
  for i=1, MAX_MEMBER_RECIPES  do
    recipeSlot[i].text:SetText("")
    recipeSlot[i]:Hide()
  end

  --prediction recipes based off of their skill level
  local recipeCount=0
  local recipeAlpha={}
  for k in pairs(recipeAlpha) do
    recipeAlpha[k] = nil
  end
  for k,v in ipairs(DNAProf[prof]) do
    if (v[2] <= skillLevel) then
      recipeCount = recipeCount+1
      local spellName = GetSpellInfo(v[1]) .. " | " .. v[1]
      table.insert(recipeAlpha, spellName)
    end
  end
  table.sort(recipeAlpha)
  for k,v in ipairs(recipeAlpha) do
    recipeSlot[k].text:SetText(v)
    recipeSlot[k]:Show()
  end
end
