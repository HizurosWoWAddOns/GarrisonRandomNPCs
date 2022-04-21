
local _, ns = ...;

local L = setmetatable({},{
	__index=function(t,k)
		local v=tostring(k);
		rawset(t,k,v);
		return v;
	end
});
ns.L = L;

-- /end of english localization
L.AddOnName = "Garrison random NPCs"
L.AddOnLoaded = "AddOn loaded..."

-- options
L.OptHeadGeneral = "General options"
L.OptAddOnLoaded = "'AddOn loaded' message"
L.OptAddOnLoadedDesc = "Display 'AddOn loaded...' message on startup"

L.OptHeadTooltip = "Tooltip options"
L.OptTrader = "Trader of the Day"
L.OptTraderTTDesc = "Display 'Trader of the Day' in tooltip"

L.OptHeadBroker = "Broker options"
L.OptBrokerMode = "Broker mode"
L.OptBrokerModeDesc = "Broker modes: Launcher (mostly icon without futher informations), Data source (with further informations)"
L.OptBrokerModeL = "Launcher"
L.OptBrokerModeDS = "Data source"
L.OptHeadBrokerInfos = "Further informations on broker button"
L.OptMinimap = "Minimap button"
L.OptMinimapDesc = "Display a button for GarrisonRandomNPCs on minimap"
L.OptTraderBBDesc = "Display 'Trader of the Day' on broker button"
L.OptSeenToday = "List of 'Today seen'"
L.OptSeenTodayDesc = "Display list of 'Today seen' on your chars in tooltip"
L.OptTraderRealm = "Show 'Today seen' from realms"
L.OptTraderRealmDesc = "Choose from which realm you want to see list of 'Today seen' npc's on tooltip"
L.OptTraderRealmThis = "Current realm"
L.OptTraderRealmAll = "All realms"
L.OptTraderRealmConn = "Connected realms"

-- error
L.Error = "Error:"
L.ErrorMacro = "Can't create macro for scanning you garrison... while your are in combat."
L.ErrorMsg1 = "Player level is too low"
L.ErrorMsg2 = "Garrison level is too low"
L.ErrorMsg3 = "You are not in your garrison"
L.ErrorMsg4 = "You are out of scan range"
L.ErrorMsg5 = "You are in combat"

-- tooltip
L.ClickToScan = "Click to scan your garrison"
L.TraderOfTheDay = "Trader of the day:"
L.TodaySeen = "Today seen:"
L.Daily = "Daily quests"
L.PetDaily = "Pet battle dailys"
L.Trader = "Trader"
L.NoNPC = "No npc found"
L.TraderRegionInfo = "Hi. If Trader of the Day not match with your region, please let me know. Greetings Hizuro"

-- button
L.ScanGarr = "Scan my garrison"

if LOCALE_deDE then
	L["Click to scan your garrison"] = "Klick um deine Garnison zu scannen";
	L["Garrison level invalid. Blizzard function response wrong..."] = "Garnisonsstufe ungültig. Blizzards Funktionen antwortet manchmal inkorrekt...";
	L["Garrison level is too low"] = "Garnisonsstufe zu niedrig";
	--L["Garrison random NPCs"] = "";
	--L["Last seen npc by type"] = "";
	L["No npc found"] = "Keine NSC gefunden";
	L["Player level is too low"] = "Charakterstufe zu niedrig";
	L["Scan my garrison"] = "Scanne meine Garnison";
	L["Today seen in the garrison from %s:"] = "Heute gesehen in der Garnison von %s:";
	L["Today seen on other chars:"] = "Heute gesehen auf anderen Chars:";
	L["You are in combat"] = "Du befindest dich im Kampf";
	L["You are not in your garrison"] = "Du befindest dich nicht in deiner Garnison";
	L["You are out of scan range"] = "Du befindest dich außerhalb der Scanreichweite";
elseif LOCALE_esES then
elseif LOCALE_esMX then
elseif LOCALE_frFR then
elseif LOCALE_itIT then
elseif LOCALE_koKR then
elseif LOCALE_ptBR or LOCALE_ptPT then
elseif LOCALE_ruRU then
elseif LOCALE_zhCN then
elseif LOCALE_zhTW then
end
