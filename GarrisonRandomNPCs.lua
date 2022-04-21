
local addon, ns = ...;
local L,C = ns.L,WrapTextInColorCode;
local region = GetCurrentRegion();
local version,author = GetAddOnMetadata(addon,"Version"),GetAddOnMetadata(addon,"Author");
local libDB,libDBI = (LibStub("LibDataBroker-1.1")),(LibStub("LibDBIcon-1.0"));
local faction,player,realm,level = (UnitFactionGroup("player")),(UnitName("player")),GetRealmName(),UnitLevel("player");
local outofrange = (faction=="Alliance") and {0.52,0.52} or {0.52,0.52};
local current_errno,numNpcsCurrentChar,dailyReset,numNpcsOtherChars,classColors = 0,0,0,0;
local factionIcon = "|TInterface\\PVPFrame\\PVP-Currency-%s:16:16:0:-1:16:16:0:16:0:16|t";
local _error,QuestNameCollectorLocked,RFPC, _, ClassName = false,false,nil;
local dbDefaults = {
	minimap = {hide=false},
	visible = true,
	ttTraderOfTheDay = true,
	bbTraderOfTheDay = true,
	AddOnLoaded = true,
	brokermode = "launcher",
	ttSeenToday = true
};
local npcsByName = {};
local npcs = {
	-- alliance
	[91024] = {line2=true,faction="Alliance",type="Trader"}, -- leather trader
	[91025] = {line2=true,faction="Alliance",type="Trader"}, -- fur trader
	[91020] = {line2=true,faction="Alliance",type="Trader"}, -- enchant trader
	[90894] = {line2=true,faction="Alliance",type="Trader"}, -- Ore trader
	[91404] = {line2=true,faction="Alliance",type="Trader"}, -- herb trader
	[90675] = {line2=false,faction="Alliance",type="PetDaily"}, -- erris
	[91196] = {line2=false,faction="Alliance",type="Daily"}, -- muradin
	[89805] = {line2=false,faction="Alliance",type="Daily"}, -- renzik
	[85418] = {line2=true,faction="Alliance",hidden=true,type="PetDaily"}, -- Lio the Lioness <Battle Pet Master>

	-- horde
	[91033] = {line2=true,faction="Horde",type="Trader"}, -- leather trader
	[91034] = {line2=true,faction="Horde",type="Trader"}, -- fur trader
	[91029] = {line2=true,faction="Horde",type="Trader"}, -- enchant trader
	[91030] = {line2=true,faction="Horde",type="Trader"}, -- Ore trader
	[91031] = {line2=true,faction="Horde",type="Trader"}, -- herb trader
	[91363] = {line2=false,faction="Horde",type="PetDaily"}, -- kura
	[91195] = {line2=false,faction="Horde",type="Daily"}, -- saurfang
	[89806] = {line2=false,faction="Horde",type="Daily"}, -- ty'jin
	[79858] = {line2=true,faction="Horde",hidden=true,type="PetDaily"},  -- Serr'ah <Battle Pet Master>

	-- neutral
	[89793] = {line2=false,faction=nil,type="Daily"}, -- harrison
	[92223] = {line2=false,faction=nil,type="Daily"}, -- Surveyor Daltry // replacement if harrison jones your follower
};
local questNames = {[40329]="",[37644]="",[37645]="",[38299]="",[38300]=""};
local npcsByType = { -- usage uncommented...
	["Leather Trader"]	= {91024,91033},
	["Fur Trader"]		= {91025,91034},
	["Enchant Trader"]	= {91020,91029},
	["Ore Trader"]		= {90894,91030},
	["Herb Trader"]		= {91404,91031},
	["Menagerie Daily NPC"] = {90675,91361},
	["Dugeon & Raid Quest NPC"] = {91196,91195},
	["Daily Group Quest NPC"] = {89805,89806},
	["Archaeology Quest NPC"] = {89793,89793}
};
local petTrainerIDs = {[90675]=true,[91016]=true,[91361]=true,[91363]=true};
local petTrainer1Faction2ID = {Alliance=90675, Horde=91363};
local petTrainer2Faction2ID = {Alliance=85418, Horde=79858};
local traderOrder2NpcID = {
	{90894,91030}, -- ore
	{91020,91029}, -- enchant
	{91025,91034}, -- fur
	{91024,91033}, -- leather
	{91404,91031}  -- herb
};
local PLAYERLEVEL_TOO_LOW,GARRLEVEL_TOO_LOW,OUT_OF_ZONE,OUT_OF_RANGE,PLAYER_IN_COMBAT = 1,2,3,4,5;

--[[

--]]

function ns.print(...)
	local colors,t,c = {"82c5ff","00ff00","ff6060","44ffff","ffff00","ff8800","ff44ff","ffffff"},{},1;
	for i,v in ipairs({...}) do
		v = tostring(v);
		if i==1 and v~="" then
			tinsert(t,"|cff82c5ff"..addon.."|r:"); c=2;
		end
		if not v:match("||c") then
			v,c = "|cff"..colors[c]..v.."|r", c<#colors and c+1 or 1;
		end
		tinsert(t,v);
	end
	print(unpack(t));
end

function ns.debug(...)
	if "@project-version@"=="@".."project-version".."@" then
		ns.print("<debug>",...);
	end
end

local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

local function TraderOfTheDay(day)
	local t=date("*t"); t.hour, t.min, t.sec = t.isdst and 9 or 8, 0, 0;
	local timeCap = t.hour*60*60;

	if type(day)=="number" then
		t.day = t.day+day; -- custom day
	elseif GetQuestResetTime()<timeCap then
		t.day = t.day-1; -- last reset was yesterday
	end

	local lastReset = time(t);
	local T = (lastReset-1504940400)/432000; -- 1425002400
	T = ceil(floor((T-floor(T))*10)/2)+1;
	--if region==? then
		-- this code match with eu region
		-- other regions maybe needs adjustment
	--end
	return T<1 and T+5 or T;
end

local function CheckGarrisonStatus()
	-- in combat
	if InCombatLockdown() then
		return PLAYER_IN_COMBAT;
	end

	-- check player level
	if(UnitLevel("player")<GetMaxLevelForExpansionLevel(5))then
		return PLAYERLEVEL_TOO_LOW;
	end

	-- check garrison level
	local garrLevel = C_Garrison.GetGarrisonInfo(Enum.GarrisonType.Type_6_0) or 0;
	if garrLevel<3 then
		return GARRLEVEL_TOO_LOW;
	end

	-- check current zone
	local wmZone = C_Map.GetBestMapForUnit("player");
	if not (wmZone==582 or wmZone==590) then
		return OUT_OF_ZONE;
	end

	-- check player position
	--[[
	local x,y = GetPlayerMapPosition("player");
	if(x>outofrange[1] or y>outofrange[2])then
		return OUT_OF_RANGE;
	end
	--]]

	return 0;
end

local function checkDBData()
	local t=time();
	local r=GetQuestResetTime();
	dailyReset = t + r - 86400;

	if dailyReset<=0 then
		-- there is a really rare problem with PLAYER_ENTERING_WORLD
		-- sometimes (time()+GetQuestResetTime())==0
		C_Timer.After(1,checkDBData);
		return;
	end

	numNpcsCurrentChar = 0;
	numNpcsOtherChars = 0;
	for _RFPC,_npcs in pairs(GarrisonRandomNPCsDB.Chars)do
		local _realm,_faction,_player,_class = strsplit(";",_RFPC);
		for id, scanned in pairs(_npcs)do
			if(scanned > dailyReset)then
				if(_realm==realm and _player==player)then
					numNpcsCurrentChar=numNpcsCurrentChar+1;
				end
				numNpcsOtherChars=numNpcsOtherChars+1;
			end
		end
	end
end

local function UpdateBroker()
	--[[
		local num, itemType = TraderOfTheDay();
		local id = traderOrder2NpcID[num][faction=="Alliance" and 1 or 2];
		tt:AddLine(" ");
		tt:AddDoubleLine(L["Town hall trader forecast:"]);
		tt:AddLine(npcs[id].line2,0,.8,1);
	]]
	-- GarrisonRandomNPCsDB
end

local function UpdateTooltip(tt,button)
	current_errno = CheckGarrisonStatus();
	local IsPetQuest1Finished = C_QuestLog.IsQuestFlaggedCompleted(38299) or C_QuestLog.IsQuestFlaggedCompleted(38300); -- accountwide
	local IsPet2AQuestFinished = C_QuestLog.IsQuestFlaggedCompleted(37644); -- per character (alliance)
	local IsPet2HQuestFinished = C_QuestLog.IsQuestFlaggedCompleted(37645); -- per character (horde)
	local IsPet3QuestFinished = C_QuestLog.IsQuestFlaggedCompleted(40329); -- accountwide
	dailyReset = time() + GetQuestResetTime() - 86400;
	local today = time();
	classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

	tt:ClearLines();
	tt:AddLine(L.AddOnName);

	if button==true then
		tt:AddLine(L.ClickToScan,.4,.9,.4);
		if current_errno~=0 then
			tt:AddLine(" ");
			tt:AddLine(L["ErrorMsg"..current_errno],1,.6,0);
		end
	end

	if GarrisonRandomNPCsDB.ttTraderOfTheDay then
		local num, itemType = TraderOfTheDay();
		local id = traderOrder2NpcID[num][faction=="Alliance" and 1 or 2];
		tt:AddLine(" ");
		tt:AddLine(L.TraderOfTheDay);
		tt:AddDoubleLine(C(npcs[id].name,"ffffffff"),C(npcs[id].line2,"ffaaaaaa"));
		if region~=3 then
			tt:AddLine(L.TraderRegionInfo,.7,.7,.7,1);
		end
		tt:AddLine(" ")
		tt:AddLine(L.TheNextDays);
		local n=1;
		for i=num+1, #traderOrder2NpcID do
			local id = traderOrder2NpcID[i][faction=="Alliance" and 1 or 2];
			tt:AddDoubleLine(C(npcs[id].name,"ffffffff").." "..C("("..npcs[id].line2..")","ffaaaaaa"),L["WeekDay"..date("%w",today+(n*86400))]);
			n=n+1;
		end
		for i=1, num-1 do
			local id = traderOrder2NpcID[i][faction=="Alliance" and 1 or 2];
			tt:AddDoubleLine(C(npcs[id].name,"ffffffff").." "..C("("..npcs[id].line2..")","ffaaaaaa"),L["WeekDay"..date("%w",today+(n*86400))]);
			n=n+1;
		end
	end

	--[=[
	if IsPetQuest1Finished or IsPetQuest2AFinished or IsPetQuest2HFinished or IsPetQuest3Finished then
		local npcData1 = npcs[petTrainer1Faction2ID[faction]];
		local npcData2 = npcs[petTrainer2Faction2ID[faction]];
		npcData1.line2 = npcData1.line2~="" and " |cffcccccc<"..npcData1.line2..">|r" or "";
		npcData2.line2 = npcData2.line2~="" and " |cffcccccc<"..npcData2.line2..">|r" or "";

		tt:AddLine(" ");
		tt:AddLine(L["Completed garrison pet dailys:"]);
		if IsPetQuest1Finished then
			tt:AddLine("- "..questNames[faction=="Alliance" and 38299 or 38300],.4,.9,.4);
			tt:AddLine("   "..npcData1.name..npcData1.line2,0,.8,1);
		end
		--[[
		if IsPetQuest2AFinished then
			tt:AddLine("- "..questNames[37644],.2,.8,.2);
			tt:AddLine("   "..npcData2.name..npcData2.line2,0,.8,1);
		end
		if IsPetQuest2HFinished then
			tt:AddLine("- "..questNames[37645],.2,.8,.2);
			tt:AddLine("   "..npcData2.name..npcData2.line2,0,.8,1);
		end
		if IsPetQuest3Finished then
			tt:AddLine("- "..questNames[40329],.4,.9,.4);
			tt:AddLine("   "..npcData2.name..npcData2.line2,0,.8,1);
		end
		]]
	end
	--]=]

	--[[
	if button==nil and IsShiftKeyDown() then
		tt:AddLine(" ");
		tt:AddLine(L["Last seen npc by type"],1,1,1);
		for label, ids in pairs(npcsByType)do
			tt:AddLine(" ");
			tt:AddLine(label);
			local id, scanned, onChar = ids[faction=="Alliance" and 1 or 2],0,nil;
			for _rpf,_npcs in pairsByKeys(GarrisonRandomNPCsDB.Chars)do
				for npcID, npcData in pairs(npcs)do
					if not npcData.hidden then
						local _scanned = _npcs[npcID] or 0;
						if _scanned and _scanned>scanned then
							scanned = _scanned;
							onChar = _rpf;
						end
					end
				end
			end
			if scanned>0 then
				local _realm,_faction,_player,_class = strsplit(";",onChar);
				tt:AddLine(" - ".._player.." - ".._realm.." - ("..scanned..")",0,.8,1);
			end
		end
		return;
	end
	]]

	--[[
	if numNpcsCurrentChar>0 or IsPetQuest1Finished then
		tt:AddLine(" ");
		tt:AddLine(L.TodaySeen);
		-- ["Today seen in the garrison of %s:"]:format("|c"..classColors[ClassName].colorStr..player.."|r")
		--tt:AddLine(
		for id, scanned in pairs(GarrisonRandomNPCsDB.Chars[RFP])do
			if(scanned>dailyReset and not (petTrainerIDs[id] and IsPetQuest1Finished) )then
				local line2 = " ("..((npcs[id].line2 and npcs[id].line2~="") and npcs[id].line2 or L[npcs[id].type])..")";
				tt:AddDoubleLine(C(player,classColors[ClassName].colorStr),C(npcs[id].name,"ffffffff")..C(line2,"ffaaaaaa"));
			end
		end
	elseif button~=true then
		tt:AddLine(L.NoNPC,1,1,1);
	end
	--]]

	--[[
	tt:AddLine(" ");
	tt:AddLine(L.TodaySeen);

	local linecount=0;
	if (numNpcsOtherChars>0 or IsPetQuest1Finished) then
		local addTitle = true;
		local names,count,line2 = {},0;
		local lastRealm = "";

		for _rfpc,_npcs in pairsByKeys(GarrisonRandomNPCsDB.Chars)do
			local _realm,_faction,_player,_class = strsplit(";",_rfpc);
			for npcID, npcData in pairs(npcs)do
				local scanned = _npcs[npcID];
				if(not npcData.hidden and scanned~=nil and scanned>dailyReset and not (petTrainerIDs[npcID] and IsPetQuest1Finished==true) )then

					if _realm~=lastRealm then
						tt:AddLine(C(_realm,"ffaaaaaa"));
						lastRealm = _realm;
					end

					if _player~="" then
						_player = C(_player,classColors[_class].colorStr)..factionIcon:format(_faction);
					end

					local line2 = " ("..((npcData.line2 and npcData.line2~="") and npcData.line2 or L[npcData.type])..")";

					local thisChar = RFPC==_rfpc and C("||","ff00ff00").."  " or "   "
					tt:AddDoubleLine(thisChar.._player,C(npcData.name,"ffffffff")..C(line2,"ffaaaaaa")..thisChar:trim());

					_player = "";

					linecount=linecount+1;
				end
			end
		end
	end

	if linecount==0 then
		tt:AddLine(L.NoNPC,1,1,1);
	end
	--]]

	tt:AddLine(" ")
	--tt:AddLine(C(L.LeftClick,"fff0a55f") .. " | " .. C(L.ToggleScanBtn,"ff80ff80"));
	tt:AddLine(C(L.RightClick,"fff0a55f") .. " | " .. C(L.ToggleOptions,"ff80ff80"));
end

local function ScanTooltip_GetLines(objType,id)
	local tt,data,link = GarrisonRandomNPCsScanTT,{};
	if objType=="unit" then
		link = "unit:Creature-0-0000-0000-00000-%d-0000000000";
	elseif objType=="quest" then
		link = "quest:%d";
	end
	if link then
		tt:SetOwner(_G.UIParent,"ANCHOR_LEFT",-200,0);
		tt:SetHyperlink(link:format(id));
		tt:Show();
		for _,line in pairs({tt:GetRegions()}) do
			if (line~=nil) and (line:GetObjectType()=="FontString") and (line:GetText()~=nil) then
				tinsert(data,line:GetText());
			end
		end
		tt:ClearLines();
		tt:Hide();
	end
	return data;
end

local function CollectQuestNames()
	local checked,added=0,0;
	for id,name in pairs(questNames)do
		local lines = ScanTooltip_GetLines("quest",id)
		if(#lines>0)then
			questNames[id] = lines[1];
			added=added+1;
		end
		checked=checked+1;
	end
	if(added<checked)then
		wipe(npcsByName);
		if QuestNameCollectorLocked==false then
			C_Timer.After(3,CollectQuestNames);
		end
		QuestNameCollectorLocked=true;
		return;
	end
	QuestNameCollectorLocked = false;
end

local function GenerateNpcList()
	local checked,added=0,0;
	for id,data in pairs(npcs) do
		local lines = ScanTooltip_GetLines("unit",id);
		if(#lines>0)then
			data.name=lines[1];
			data.line2=data.line2==true and lines[2] or "";
			npcsByName[lines[1]]=id;
			added=added+1;
		end
		checked=checked+1;
	end

	if(added<checked)then
		wipe(npcsByName);
		if _error==false then
			C_Timer.After(3,GenerateNpcList);
		end
		_error=true;
		return;
	end
	_error = false;
	CollectQuestNames();
end


--[ DataBroker & Icon ]--
local function RegisterDatabroker()
	local Object = libDB:NewDataObject(addon, {
		type = "launcher",
		text = L.AddOnName,
		icon = "Interface\\Addons\\"..addon.."\\radar",
		OnClick = function(_,button)
			if button=="RightButton" then
				local Lib = LibStub("AceConfigDialog-3.0");
				if Lib.OpenFrames[addon]~=nil then
					Lib:Close(addon);
				else
					Lib:Open(addon);
					Lib.OpenFrames[addon]:SetStatusText(("%s: %s, %s: %s"):format(GAME_VERSION_LABEL,version,L.Author,author));
				end
			else
				if (GarrisonRandomNPCsFrame:IsShown()) then
					GarrisonRandomNPCsFrame:Hide();
					GarrisonRandomNPCsDB.Visible=false;
				else
					current_errno = CheckGarrisonStatus();
					if current_errno==0 then
						GarrisonRandomNPCsFrame:Show();
					end
					GarrisonRandomNPCsDB.Visible=true;
				end
			end
		end,
		OnTooltipShow = UpdateTooltip
	});
	if GarrisonRandomNPCsDB.minimap==nil then
		GarrisonRandomNPCsDB.minimap={hide=false};
	end
	libDBI:Register(addon, Object, GarrisonRandomNPCsDB.minimap);
end


--[ Options ]--
local function opt(info, value)
	local key = info[#info];
	if value~=nil then
		if key=="minimap" then
			GarrisonRandomNPCsDB.minimap.hide = not value;
		else
			GarrisonRandomNPCsDB[key] = value;
		end
	end
	if key=="minimap" then
		return not GarrisonRandomNPCsDB.minimap.hide;
	end
	return GarrisonRandomNPCsDB[key];
end

local function disabled(info)
	local key = info[#info];
	if key=="bbTraderOfTheDay" then
		return GarrisonRandomNPCsDB.brokermode=="launcher"
	end
end

local options = {
	type = "group",
	name = L.AddOnName,
	get = opt,
	set = opt,
	args = {
		general = {
			type = "group", inline = true, order = 1,
			name = L.OptHeadGeneral,
			args = {
				AddOnLoaded = {
					type = "toggle", width = "double",
					name = L.AddOnLoaded, desc = L.AddOnLoadedDesc
				},
			}
		},
		broker = {
			type = "group", inline = true, order = 2,
			name = L.OptHeadBroker,
			args = {
				minimap = {
					type = "toggle", order = 1,
					name = L.OptMinimap, desc = L.OptMinimapDesc
				},
				brokermode = {
					type = "select", order = 2,
					name = L.OptBrokerMode, desc = L.OptBrokerModeDesc,
					values = {
						["launcher"] = L.OptBrokerModeL,
						["data source"] = L.OptBrokerModeDS,
					}
				},
				info = {
					type = "header", order = 3,
					name = L.OptHeadBrokerInfos,
					hidden = true
				},
				bbTraderOfTheDay = {
					type = "toggle", order = 4,
					name = L.OptTrader, desc = L.OptTraderBBDesc,
					disabled = disabled,
					hidden = true
				},
			}
		},
		tooltip = {
			type = "group", inline = true, order = 3,
			name = L.OptHeadTooltip,
			args = {
				ttTraderOfTheDay = {
					type = "toggle", order = 1,
					name = L.OptTrader, desc = L.OptTraderTTDesc
				},
				ttTraderRealm = {
					type = "select",
					name = L.OptTraderRealm, desc = L.OptTraderRealmDesc,
					values = {
						this = L.OptTraderRealmThis,
						connected = L.OptTraderRealmConn,
						all = L.OptTraderRealmAll
					},
					hidden = true
				},
				ttSeenToday = {
					type = "toggle", order = 3,
					name = L.OptSeenToday, desc = L.OptSeenTodayDesc,
					hidden = true
				}
			}
		}
	}
};

local function RegisterOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon);
end

--[ GarrisonRandomNPCsFrame functions ]--
GarrisonRandomNPCsFrame_Mixin = {}

function GarrisonRandomNPCsFrame_Mixin:CreateMacro()
	if not (InCombatLockdown() or _error) then
		local str = "/cleartarget";
		for name,id in pairs(npcsByName)do
			if not npcs[id].hidden and npcs[id].faction==nil or npcs[id].faction==faction then
				str = str .. "\n/tar " .. name;
			end
		end
		CreateMacro("GRNPCS_"..faction,"Achievement_Garrison_Tier03_"..faction,str);
		return true;
	end
	_error = true;
	return false;
end

function GarrisonRandomNPCsFrame_Mixin:OnEvent(event,...)
	if event=="VARIABLES_LOADED" then

		if GarrisonRandomNPCsDB==nil then
			GarrisonRandomNPCsDB = {};
		end

		if GarrisonRandomNPCsDB.Chars~=nil and GarrisonRandomNPCsDB.CharClasses~=nil then
			-- integrate class name into chars table key
			GarrisonRandomNPCsDB.migrated = true;
			for k,v in pairs(GarrisonRandomNPCsDB.Chars)do
				local key = {strsplit(";",k)};
				if k:match("Horde$") or k:match("Alliance$") then
					local Key = key[1]..";"..key[3]..";"..key[2]..";"..GarrisonRandomNPCsDB.CharClasses[k];
					GarrisonRandomNPCsDB.Chars[Key] = v;
					GarrisonRandomNPCsDB.Chars[k]=nil;
				end
			end
			GarrisonRandomNPCsDB.CharClasses=nil;
		end

		_, ClassName = UnitClass("player");
		RFPC = realm..";"..faction..";"..player..";"..ClassName;

		if(GarrisonRandomNPCsDB==nil)then
			GarrisonRandomNPCsDB={Chars={[RFPC]={}}};
		elseif(GarrisonRandomNPCsDB.Chars==nil)then
			GarrisonRandomNPCsDB.Chars={[RFPC]={}};
		elseif(GarrisonRandomNPCsDB.Chars[RFPC]==nil)then
			GarrisonRandomNPCsDB.Chars[RFPC]={};
		end

		for k,v in pairs(dbDefaults)do
			if type(GarrisonRandomNPCsDB[k])~=type(v) then
				GarrisonRandomNPCsDB[k]=v;
			end
		end

		if GarrisonRandomNPCsDB.AddOnLoaded then
			ns.print(L.AddOnLoaded);
		end
	elseif event=="PLAYER_ENTERING_WORLD" then
		--SetMapToCurrentZone();

		checkDBData();

		GenerateNpcList();

		RegisterDatabroker();

		RegisterOptions();

		if GarrisonRandomNPCsDB.Visible then
			C_Timer.After(4,function()
				current_errno = CheckGarrisonStatus();
				if current_errno==0 then
					self:Show();
				end
			end);
		end

		self:UnregisterEvent(event);
	elseif event=="PLAYER_TARGET_CHANGED" and UnitGUID("target")~=nil and CheckGarrisonStatus()==0 then
		local Type,_,_,_,_,ID = strsplit("-",UnitGUID("target"));
		ID = tonumber(ID);
		-- ID~=90793 exclude the follower "harrison jones"
		if ID==90793 then return end
		local name = UnitName("target");
		if(npcsByName[name] and ID~=npcsByName[name])then
			ID = npcsByName[name]; -- some npcs have multible npcIDs
		end
		if(Type=="Creature" and npcsByName[name])then
			GarrisonRandomNPCsDB.Chars[RFPC][ID] = time();
			numNpcsCurrentChar=numNpcsCurrentChar+1;
		end
	elseif (event=="ZONE_CHANGED" or event=="ZONE_CHANGED_INDOORS") and not InCombatLockdown() then
		self:SetShown(GarrisonRandomNPCsDB.Visible==true and CheckGarrisonStatus()==0);
	elseif event=="PLAYER_REGEN_DISABLED" and self:IsShown() then
		self:Hide();
	elseif event=="PLAYER_REGEN_ENABLED" and GarrisonRandomNPCsDB.Visible then
		current_errno = CheckGarrisonStatus();
		if current_errno==0 or current_errno==OUT_OF_RANGE then
			self:Show();
		end
	elseif event=="PLAYER_LEVEL_UP" then
		if lvl~=level then
			level=lvl;
		else
			C_Timer.After(2,function()
				-- sometimes this function return old level on levelup event
				level = UnitLevel("player");
			end);
		end
	end
end

function GarrisonRandomNPCsFrame_Mixin:OnLoad()
	self.ScanButton:SetFrameLevel(self:GetFrameLevel()+1);
	self.ScanButton:SetAttribute("macro","GRNPCS_"..faction);
	self.ScanButton.Text:SetText(L.ScanGarr);
	self:SetWidth(self.ScanButton.Text:GetWidth()+24);

	self.ScanButton:HookScript("OnEnter",function()
		if not GetMacroInfo("GRNPCS_"..faction) and not self:CreateMacro() then
			ns.print(L.Error,L.ErrorMacro);
		else
			GameTooltip:SetOwner(self,"ANCHOR_BOTTOM");
			UpdateTooltip(GameTooltip,true);
			GameTooltip:Show();
		end
	end);

	self.ScanButton:HookScript("OnLeave",function()
		GameTooltip:Hide();
	end);

	self.ScanButton:HookScript("OnClick",function()
		UpdateTooltip(GameTooltip,true);
		GameTooltip:Show();
	end);

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
end

