local _

local function OnCraftStation(eventCode, craftId, sameStation)
	if eventCode ~= 0 then -- 0 is an invalid code
			BUI.Writs.Show(tonumber(craftId))
	end
end

local function OnCloseCraftStation(eventCode)
	BUI.Writs.Hide()
end

local function OnCraftItem(eventCode, craftId)
	if eventCode ~= 0 then -- 0 is an invalid code
			BUI.Writs.Show(tonumber(craftId))
	end
end

function BUI.Writs.Setup()
	local tlw = BUI.WindowManager:CreateTopLevelWindow("BUI_TLW")
	local BUI_WP = BUI.WindowManager:CreateControlFromVirtual("BUI_WritsPanel",tlw,"BUI_WritsPanel")

	EVENT_MANAGER:RegisterForEvent(BUI.name, EVENT_CRAFTING_STATION_INTERACT, OnCraftStation)
	EVENT_MANAGER:RegisterForEvent(BUI.name, EVENT_END_CRAFTING_STATION_INTERACT, OnCloseCraftStation)
	EVENT_MANAGER:RegisterForEvent(BUI.name, EVENT_CRAFT_COMPLETED, OnCraftItem)

	BUI_WP:SetHidden(true)
end

function BUI.Writs.Get(qId)
	writLines = {}
	writConcate = ''
	for lineId = 1, GetJournalQuestNumConditions(qId,1) do
		local writLine,current,maximum,_,complete = GetJournalQuestConditionInfo(qId,1,lineId)
		local colour
		if writLine ~= '' then
			if current == maximum then
				colour = "00FF00"
			else
				colour = "CCCCCC"
			end
			writLines[lineId] = {line=zo_strformat("|c<<1>><<2>>|r",colour,writLine),cur=current,max=maximum}
		end
	end
	for key,line in pairs(writLines) do
		writConcate = zo_strformat("<<1>><<2>>\n",writConcate,line.line)
	end

	return writConcate
end

function BUI.Writs.Update()
	BUI.Writs.List = {}
	for qId=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(qId) then
			if GetJournalQuestType(qId) == QUEST_TYPE_CRAFTING then
				local qName,_,qDesc,_,_,qCompleted  = GetJournalQuestInfo(qId)
				local currentWrit = -1

				if string.find(string.lower(qName),'blacksmith') then currentWrit = CRAFTING_TYPE_BLACKSMITHING end
				if string.find(string.lower(qName),'cloth') then currentWrit = CRAFTING_TYPE_CLOTHIER end
				if string.find(string.lower(qName),'woodwork') then currentWrit = CRAFTING_TYPE_WOODWORKING end
				if string.find(string.lower(qName),'enchant') then currentWrit = CRAFTING_TYPE_ENCHANTING end
				if string.find(string.lower(qName),'provision') then currentWrit = CRAFTING_TYPE_PROVISIONING end
				if string.find(string.lower(qName),'alchemist') then currentWrit = CRAFTING_TYPE_ALCHEMY end

				if currentWrit ~= -1 then
					BUI.Writs.List[currentWrit] = { id = qId, writLines = BUI.Writs.Get(qId) }
				end
			end
		end
	end
end

function BUI.Writs.Show(writType)
	if BUI.settings.showWritHelper == true then 
		BUI.Writs.Update()
		if BUI.Writs.List[writType] ~= nil then
			local qName,_,activeText,_,_,completed = GetJournalQuestInfo(BUI.Writs.List[writType].id)
			BUI_WritsPanelSlotContainerExtractionSlotWritName:SetText(zo_strformat("|c0066ff[BUI]|r <<1>>",qName))
			BUI_WritsPanelSlotContainerExtractionSlotWritDesc:SetText(zo_strformat("<<1>>",BUI.Writs.List[writType].writLines))
			BUI_WritsPanel:SetHidden(false)
		end
	else
		BUI_WritsPanel:SetHidden(true)
	end
end

function BUI.Writs.Hide()
	BUI_WritsPanel:SetHidden(true)
end