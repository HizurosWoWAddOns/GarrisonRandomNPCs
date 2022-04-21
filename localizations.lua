
local L, addon, ns = {},...;

ns.L = setmetatable(L,{
	__index=function(t,k)
		local v=tostring(k);
		rawset(t,k,v);
		return v;
	end
});

--
L.AddOnName = "Garrison random NPCs"
L.AddOnLoaded = "AddOn loaded..."
L.AddOnLoadedDesc = "Display 'AddOn loaded...' message on startup"

-- options
L.OptHeadGeneral = "General options"

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
L.LeftClick = "Left click"
L.RightClick = "Right click"
L.ToggleOptions = "Show/Hide options"
L.ToggleScanBtn = "Show/Hide scan button"
L.TheNextDays = "The mext days:"
L.WeekDay1 = "Monday"
L.WeekDay2 = "Tuesday"
L.WeekDay3 = "Wednesday"
L.WeekDay4 = "Thursday"
L.WeekDay5 = "Friday"
L.WeekDay6 = "Saturday"
L.WeekDay0 = "Sunday"

-- button
L.ScanGarr = "Scan my garrison"

if LOCALE_deDE then
	L.AddOnName = "Garnison Zufall-NSCs"
	L.AddOnLoaded = "AddOn geladen..."
	L.AddOnLoadedDesc = "Zeige 'AddOn geladen...' Nachricht beim Start"

	-- options
	L.OptHeadGeneral = "Allgemeine Options"

	L.OptHeadTooltip = "Tooltip Optionen"
	L.OptTrader = "Händler des Tages"
	L.OptTraderTTDesc = "Zeige 'Händler des Tages' im Tooltip"

	L.OptHeadBroker = "Broker Optionen"
	L.OptBrokerMode = "Broker Modus"
	L.OptBrokerModeDesc = "Broker Modis: Launcher (meist Symbol ohne weitere Informationen), Data source (mit weiteren Informationen)"
	--L.OptBrokerModeL = "Launcher"
	--L.OptBrokerModeDS = "Data source"
	L.OptHeadBrokerInfos = "Weiter Information auf dem Broker-Button"
	L.OptMinimap = "Minikartensymbol"
	--L.OptMinimapDesc = "Display a button for GarrisonRandomNPCs on minimap"
	--L.OptTraderBBDesc = "Display 'Trader of the Day' on broker button"
	--L.OptSeenToday = "List of 'Today seen'"
	--L.OptSeenTodayDesc = "Display list of 'Today seen' on your chars in tooltip"
	--L.OptTraderRealm = "Show 'Today seen' from realms"
	--L.OptTraderRealmDesc = "Choose from which realm you want to see list of 'Today seen' npc's on tooltip"
	--L.OptTraderRealmThis = "Current realm"
	--L.OptTraderRealmAll = "All realms"
	--L.OptTraderRealmConn = "Connected realms"

	-- error
	L.Error = "Fehler:"
	--L.ErrorMacro = "Can't create macro for scanning you garrison... while your are in combat."
	L.ErrorMsg1 = "Charakterstufe zu niedrig";
	L.ErrorMsg2 = "Garnisonsstufe zu niedrig";
	L.ErrorMsg3 = "Du befindest dich nicht in deiner Garnison";
	L.ErrorMsg4 = "Du befindest dich außerhalb der Scanreichweite";
	L.ErrorMsg5 = "Du befindest dich im Kampf";

	-- tooltip
	L.ClickToScan = "Klick um deine Garnison zu scannen";
	L.TraderOfTheDay = "Händler des Tages:"
	L.TodaySeen = "Today seen:"
	L.Daily = "Tägliche Quests"
	L.PetDaily = "Kampfhaustier-Dailys"
	L.Trader = "Händler"
	L.NoNPC = "Keine NSC gefunden";
	--L.TraderRegionInfo = "Hi. If Trader of the Day not match with your region, please let me know. Greetings Hizuro"
	L.LeftClick = "Linksklick"
	L.RightClick = "Rechtsklick"
	L.ToggleOptions = "Zeige/Verstecke Optionen"
	L.ToggleScanBtn = "Zeige/Verstecke Scan Button"
	L.TheNextDays = "Die nächsten Tage:"
	L.WeekDay1 = "Montag"
	L.WeekDay2 = "Dienstag"
	L.WeekDay3 = "Mittwoch"
	L.WeekDay4 = "Donnerstag"
	L.WeekDay5 = "Freitag"
	L.WeekDay6 = "Samstag"
	L.WeekDay0 = "Sonntag"

	-- button
	L.ScanGarr = "Scanne meine Garnison";

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
