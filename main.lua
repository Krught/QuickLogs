local QuickLogs = CreateFrame("frame", "EventFrame")
local addonName, addonTable = ...

QuickLogs:RegisterEvent("PLAYER_TARGET_CHANGED")

local function inTabletwo(table_c_black, item)
  x_b_Ca = 0
  tag = 0
  for key, value in pairs(table_c_black) do
      if value == item then 
          x_b_Ca = 1
          black_det = 1
          tag = key
      else
          if x_b_Ca ~= 1 then
              x_b_Ca = 0
          end
      end
  end
  return x_b_Ca, tag
end
local function getColor(num)
  if num >= 100 then
      return "gold"
  elseif num >= 99 then
      return "pink"
  elseif num >= 95 then
      return "orange"
  elseif num >= 75 then
      return "purple"
  elseif num >= 50 then
      return "blue"
  elseif num >= 25 then
      return "green"
  else
      return "grey"
  end
end
local parse_colors = {
  gold = { r = 242/255, g = 209/255, b = 99/255 },
  pink = { r = 244/255, g = 140/255, b = 186/255 },
  orange = { r = 230/255, g = 113/255, b = 11/255 },
  purple = { r = 132/255, g = 43/255, b = 231/255 },
  blue = { r = 15/255, g = 101/255, b = 221/255 },
  green = { r = 28/255, g = 255/255, b = 8/255 },
  grey = { r = 157/255, g = 157/255, b = 157/255 }
}

local function QuickLogs_SaveData()
  QuickLogs_SavedVariables.only_show_avg_parse = only_show_avg_parse
  QuickLogs_SavedVariables.the_25_or_10_selection = the_25_or_10_selection
  QuickLogs_SavedVariables.only_show_avg_parse_search = only_show_avg_parse_search
end

local function QuickLogs_OnLog(self, event, ...)
  if event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" then
    QuickLogs_SaveData()
  end
end

local Logout = CreateFrame("Frame")
Logout:RegisterEvent("PLAYER_LOGOUT")
Logout:RegisterEvent("PLAYER_LEAVING_WORLD")
Logout:SetScript("OnEvent", QuickLogs_OnLog)


local function OnTooltipSetUnit(tooltip)
    if not tooltip:GetUnit() then
      return
    end
    local unitName, unit = tooltip:GetUnit()
    if (not UnitIsPlayer(unit)) then
      return
    end
    local function tooltip_text(line, line_num)
      local num = tonumber(line)
      local color = getColor(num)
      local bosstext = addonTable.quicklogs_bosses[line_num+1]
      local pre_h_text = "            "
      local after_text = "    "
      if (line_num == 0) then
        local header_text = "25 Man"
        header_text = pre_h_text .. header_text
        tooltip:AddLine(header_text, parse_colors["purple"].r, parse_colors["purple"].g, parse_colors["purple"].b)
      elseif (line_num == 13) then
        local header_text = "10 Man"
        header_text = pre_h_text .. header_text
        tooltip:AddLine(header_text, parse_colors["green"].r, parse_colors["green"].g, parse_colors["green"].b)
      end
      bosstext = string.sub(bosstext, 4)
      local line = string.format("%.2f", line)
      if (num < 100) then
        line = "  " .. line
      end
      local line_text = line .. "%  ".. "   ".. bosstext
      tooltip:AddLine(line_text, parse_colors[color].r, parse_colors[color].g, parse_colors[color].b)
    end
    local name, realm = tooltip:GetUnit()
    local target = name .. "-" .. (realm or GetRealmName())
    if realm == "target" or realm == "mouseover" or realm == "player" then
      realm = GetRealmName()
    end    
    local region = GetLocale()
    region = string.sub(region, 3)
    local combine_lookup_code = name .. "-" .. realm .. "-" .. region
    local parses = "No Parses Available"
    mystring = ""
    is_in_tabl, tag = inTabletwo(addonTable.quicklogs_names, combine_lookup_code)
    if is_in_tabl == 1 then
      -- combine_lookup_code = "ITS A ME SOULINE"
      mylist = addonTable.quicklogs_data[tag]
      separator = "\n"
      mystring = table.concat(mylist, separator)
      parses = mystring
    end

    local line_num = 0
    for line in string.gmatch(mystring, "[^\n]+") do
      ---line_num 0 = 25m Overall, 1 - 12 = 25m bosses, 13 = 10m Overall, 14 - 26 10m Bosses
      -- the_25_or_10_selection
      if (only_show_avg_parse) then
        if (line_num == 0 or line_num == 13) then
          if (the_25_or_10_selection == 1 and line_num == 0) then
            tooltip_text(line, line_num)
          elseif (the_25_or_10_selection == 2 and line_num == 13) then
            tooltip_text(line, line_num)
          end
        end
      else
        if (the_25_or_10_selection == 1 and line_num < 13) then
          tooltip_text(line, line_num)
        elseif (the_25_or_10_selection == 2 and line_num > 12) then
          tooltip_text(line, line_num)
        end
      -- tooltip:AddFontFlags("RIGHT")
      -- tooltip:SetJustifyH("RIGHT")
      end
      line_num = line_num + 1
    end

    -- Do something with the target name here
    -- the 1, 1, 1 are RBG values, 
    if (parses == "No Parses Available") then
      tooltip:AddLine(parses, 1, 1, 1)
    end
    tooltip:Show()
  end
  
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)




SLASH_QUICKLOGS1 = "/ql"
SlashCmdList["QUICKLOGS"] = function(msg)
  msg = msg:sub(1,1):upper()..msg:sub(2)
  if (msg == "Settings") then
    InterfaceOptionsFrame_OpenToCategory("QuickLogs")
    InterfaceOptionsFrame_OpenToCategory("QuickLogs") -- Call this twice to ensure the panel is fully opened
  else
    local function tooltip_text_print(line, line_num)
      local num = tonumber(line)
      local bosstext = addonTable.quicklogs_bosses[line_num+1]
      if (line_num == 0) then
        local header_text = "25 Man"
        print(header_text)
      elseif (line_num == 13) then
        local header_text = "10 Man"
        print(header_text)
      end
      bosstext = string.sub(bosstext, 4)
      local line = string.format("%.2f", line)
      local line_text = bosstext .. " - " .. line .. "%"
      print(line_text)
      -- local line_text = line .. "%"
      -- print(line_text)
    end
    local name = msg
    local realm = GetRealmName()
    local region = GetLocale()
    region = string.sub(region, 3)
    local combine_lookup_code = name .. "-" .. realm .. "-" .. region
    local parses = "No Parses Available"
    mystring = ""
    is_in_tabl, tag = inTabletwo(addonTable.quicklogs_names, combine_lookup_code)
    if is_in_tabl == 1 then
      mylist = addonTable.quicklogs_data[tag]
      separator = "\n"
      mystring = table.concat(mylist, separator)
      parses = mystring
      print(msg .. "'s Parses")
    end
    local line_num = 0
    for line in string.gmatch(mystring, "[^\n]+") do
      if (only_show_avg_parse_search == false) then
        if (the_25_or_10_selection == 1 and line_num == 0) then
          tooltip_text_print(line, line_num)
        elseif the_25_or_10_selection == 2 and (line_num == 13) then
          tooltip_text_print(line, line_num)
        end
      elseif (only_show_avg_parse_search == true) then
        if (line_num ~= 0 or line_num ~= 13) then
          if (the_25_or_10_selection == 1 and line_num < 13) then
            tooltip_text_print(line, line_num)
          elseif (the_25_or_10_selection == 2 and line_num > 12) then
            tooltip_text_print(line, line_num)
          end
        end
      end
      line_num = line_num + 1
    end
    if (parses == "No Parses Available") then
      print(parses .. " For " .. msg)
    end
  end
end







-- Define the options frame
local optionsFrame = CreateFrame("Frame", "MyAddonOptionsFrame", InterfaceOptionsFramePanelContainer)
optionsFrame.name = "QuickLogs"

-- Create a title text
optionsFrame.title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsFrame.title:SetPoint("TOPLEFT", 16, -16)
optionsFrame.title:SetText("Quick Logs Options")

-- Create a checkbox
optionsFrame.checkbox = CreateFrame("CheckButton", "MyAddonOptionCheckbox", optionsFrame, "InterfaceOptionsCheckButtonTemplate")
optionsFrame.checkbox:SetPoint("TOPLEFT", optionsFrame.title, "BOTTOMLEFT", 0, -16)
optionsFrame.checkbox:SetScript("OnClick", function(self)
    -- Set the addon option to the checkbox value
    local isChecked = self:GetChecked()
    -- only_show_avg_parse.isChecked = isChecked  
    only_show_avg_parse = isChecked  
end)
optionsFrame.checkbox.label = optionsFrame.checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
optionsFrame.checkbox.label:SetPoint("LEFT", optionsFrame.checkbox, "RIGHT", 0, 1)
optionsFrame.checkbox.label:SetText("Only Show Raid Average")


-- Create a checkbox
optionsFrame.checkbox2 = CreateFrame("CheckButton", "MyAddonOptionCheckbox", optionsFrame, "InterfaceOptionsCheckButtonTemplate")
optionsFrame.checkbox2:SetPoint("TOPLEFT", optionsFrame.title, "BOTTOMLEFT", 0, -32)
optionsFrame.checkbox2:SetScript("OnClick", function(self)
    -- Set the addon option to the checkbox value
    local isCheckedtwo = self:GetChecked()
    -- only_show_avg_parse.isChecked = isChecked  
    only_show_avg_parse_search = isCheckedtwo
end)
optionsFrame.checkbox2.label = optionsFrame.checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
optionsFrame.checkbox2.label:SetPoint("LEFT", optionsFrame.checkbox2, "RIGHT", 0, 1)
optionsFrame.checkbox2.label:SetText("On Search - Display All Bosses")



-- Create a dropdown menu
optionsFrame.dropdown = CreateFrame("Frame", "MyAddonOptionDropdown", optionsFrame, "UIDropDownMenuTemplate")
optionsFrame.dropdown:SetPoint("TOPLEFT", optionsFrame.checkbox, "BOTTOMLEFT", 0, -32)
optionsFrame.dropdown.text = optionsFrame.dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
optionsFrame.dropdown.text:SetPoint("LEFT", optionsFrame.dropdown, "LEFT", 20, 0)
optionsFrame.dropdown.text:SetText("Select Raid Size:")
UIDropDownMenu_SetWidth(optionsFrame.dropdown, 150)
UIDropDownMenu_SetButtonWidth(optionsFrame.dropdown, 124)
UIDropDownMenu_Initialize(optionsFrame.dropdown, function(self, level)
    local options = {
        {text = "25m", value = 1},
        {text = "10m", value = 2}
    }
    for _, option in ipairs(options) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = option.text
        info.value = option.value
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(optionsFrame.dropdown, self.value)
            the_25_or_10_selection = self.value
        end
        UIDropDownMenu_AddButton(info)
        if the_25_or_10_selection == 1 then
          the_25_or_10_selection = 1
          -- SetCVar("the_25_or_10_selection", 1)
          UIDropDownMenu_SetSelectedValue(optionsFrame.dropdown, 1)
        elseif the_25_or_10_selection == 2 then
          -- SetCVar("the_25_or_10_selection", 2)
          UIDropDownMenu_SetSelectedValue(optionsFrame.dropdown, 2)
        end
    end
end)



-- Add the options frame to the Interface Options panel
InterfaceOptions_AddCategory(optionsFrame)


local function QuickLogs_LoadData()
  if (QuickLogs_SavedVariables) then
    only_show_avg_parse = QuickLogs_SavedVariables.only_show_avg_parse
    optionsFrame.checkbox:SetChecked(only_show_avg_parse)
    the_25_or_10_selection = QuickLogs_SavedVariables.the_25_or_10_selection
    UIDropDownMenu_SetSelectedValue(optionsFrame.dropdown, the_25_or_10_selection)
    only_show_avg_parse_search = QuickLogs_SavedVariables.only_show_avg_parse_search
    optionsFrame.checkbox2:SetChecked(only_show_avg_parse_search)
  else
    QuickLogs_SavedVariables = {}
    only_show_avg_parse = false
    the_25_or_10_selection = 1
    only_show_avg_parse_search = false
  end
end
local Login = CreateFrame("FRAME")
Login:RegisterEvent("ADDON_LOADED")
Login:SetScript("OnEvent", function(self, event, addonName)
  if event == "ADDON_LOADED" and addonName == "QuickLogs" then
    QuickLogs_LoadData()
  end
end)