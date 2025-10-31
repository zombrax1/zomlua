setImmersiveMode(true)
version = "Main: 2.1.0"
Settings:setCompareDimension(true, 720)
Settings:setScriptDimension(true, 720)

if (ImageCache) then
	ImageCache:setCheckEnable(true)
	ImageCache:setUpdateEnable(true)
	ImageCache:setImageSizeLimit(1000)
	ImageCache:setCacheNumber(20)
end

local lastHomeScreenSkipLog = 0

local _execute = os.execute
local _io = io

function mkdir(p) return _execute('mkdir -p "' .. p .. '"') == 0 end

local CHARACTER_ACCOUNT = "Main"

local screen = getRealScreenSize()
local Screen_Center = string.format("%s,%s", screen.x/2,screen.y/2)
local Home_Screen_Region = Region((screen.x/2)-20, 0, 40, 40)
local Upper_Half = Region(0, 0, screen.x, screen.y/2)
local Upper_Right = Region(screen.x/2, 0, screen.x/2, screen.y/2)
local Upper_Left = Region(0, 0, screen.x/2, screen.y/2)
local Lower_Half = Region(0, screen.y/2, screen.x, screen.y/2)
local Lower_Right = Region(screen.x/2, screen.y/2, screen.x/2, screen.y/2)
local Lower_Left = Region(0, screen.y/2, screen.x/2, screen.y/2)
local Lower_Most_Half = Region(0, screen.y - screen.y/14, screen.x, screen.y/14)
local Agnes_Region = Region(0, math.floor(screen.y * 0.08), math.floor(screen.x * 0.30), math.floor(screen.y * 0.42))
local Trek_Bag_Indicators = {"trek/claimtrek.png", "trek/claimtrek1.png", "trek/close.png", "trek/bar.png", "trek/tap.png"}
local Nomadic_Discount_Patterns = {"Nomadic Merchant/NMP.png", "Nomadic Percentage.png", "Nomadic No Discount.png"}
local Nomadic_Slot_ROI = {
	Region(30, 630, 197, 54),
	Region(261, 630, 197, 54),
	Region(493, 630, 197, 54),
	Region(30, 919, 197, 54),
	Region(261, 919, 197, 54),
	Region(493, 919, 197, 54)
}

------- Pre Configured Buttons ---------
local Back_Btn, Obtain_More_X = nil, nil
local Gathered_in_Region, March_Clock_Region = nil, nil
local Magnifyer_Level_Region, Heal_Frame = nil, nil
local Quick_Select_Btn, Severely_Injured_Btn = nil, nil
local Meat_March, Wood_March, Coal_March, Iron_March = nil, nil, nil, nil
local Total_Loc, Frame_List, Troop_Frame_List = nil, {}, {}
local Lv, Finish, Severely_Injured = nil, nil, nil
local eventROI = Region(496, 1068, 203, 370)
local Req_Lv = nil
local Auto_Chests_With_Tech = false
local Capture_Troop_Status = false
local txtLogs = ""
--local Logs = {}
--local Logs = {"", "[Script Started]"}
local Bear_Max_March = 0
local Reset_Time = nil
local maxInjured
local Main = {AM = {timer = nil, cooldown = 0, Exclusive = {Region(30, 590, 315, 250), Region(350, 590, 315, 250)}, reqList = {}}, Meat = {timer = nil, cooldown = 0}, Wood = {timer = nil, cooldown = 0}, Coal = {timer = nil, cooldown = 0}, Iron = {timer = nil, cooldown = 0},
	Tech = {timer = nil, cooldown = 0}, Attack = {timer = nil, cooldown = 0, counter = 0}, Exploration = {timer = nil, cooldown = 0}, Auto_Join = {timer = nil, cooldown = 0, enabled = false, status = false}, StartAPP1 = {timer = nil, cooldown = 0},
	StartAPP2 = {timer = nil, cooldown = 0}, City = {timer = nil, cooldown = 0}, Arena = {timer = nil, cooldown = 0, dir = "Arena/"}, Crystal_Laboratory = {timer = nil, cooldown = 0, status = nil}, War_Academy = {timer = nil, cooldown = 0, status = nil},
	Infantry = {timer = nil, cooldown = 0}, Lancer = {timer = nil, cooldown = 0}, Marksman = {timer = nil, cooldown = 0}, Experts = {timer = nil, cooldown = 0, enabled = false, request = false, dawnEnabled = false, dawnTimer = nil, dawnCooldown = 0, dawnNeedsImmediateCheck = false, dawnInterval = 0, enlistEnabled = false, enlistPending = false, enlistTimer = nil, enlistCooldown = 0}, Claim_Rewards = {timer = nil, cooldown = 0}, Recruit_Heroes = {timer = nil, cooldown = 0}, Triumph = {timer = nil, cooldown = 0, status = false},
	Maps_Option = {timer = nil, cooldown = 0}, My_Island = {timer = nil, cooldown = 0, screenTimer = nil, myIslandScreen = nil}, Chests = {timer = nil, cooldown = 0}, Nomadic_Merchant = {timer = nil, cooldown = 0}, 
	Bear_Event = {timer = nil, cooldown = 0, status = nil, dir = "Bear Event/", bearStartTime = nil, bearPrepTime = nil, running = false, initialCheck = true, marchTime = 0}, The_Labyrinth = {timer = nil, cooldown = 0, status = nil},
	Intel = {timer = nil, cooldown = 0, status = false}, Chief_Order_Event = {timer = nil, cooldown = 0, dir = "Chief Order/"}, Daily_Rewards = {timer = nil, cooldown = 0, dir = "Daily Rewards/"},
	Pet_Adventure = {timer = nil, cooldown = 0, dir = "Pet Skill/", ally_treasure = true, treasure_spots = true}, Barney = {timer = nil, cooldown = 0, bear_timer = nil, bear_cooldown = 0, status = false}, Extra_Gather_1 = {timer = nil, cooldown = 0}, 
	Extra_Gather_2 = {timer = nil, cooldown = 0}, Pack_Promotion = {timer = nil, cooldown = 0}, Hero_Mission = {timer = nil, cooldown = 0, rewards = false, rewards_box = 0, enabled = false, status = false}, Reset = {timer = nil, cooldown = 0, cooldownBeforeReset = 0, status = true},
	Storehouse = {timer = nil, cooldown = 0}, DailyRewards = {timer = nil, cooldown = 0}, Mail = {timer = nil, cooldown = 0}, mercPrestige = {timer = nil, cooldown = 0, lossCounter = 0, marchSet = 1, marchSettings = nil, enabled = false, status = false},
	Events = {Status = false, List = {}}, rssGather = {marchTime =  {["Meat"] = 0, ["Wood"] = 0, ["Coal"] = 0, ["Iron"] = 0, ["Extra1"] = 0, ["Extra2"] = 0}, requiredGathers = {[1] = 0, [2] = 0, [3] = 0}}}

local function primeMainTaskTimers()
	Main.forceInitialSweep = true
	for name, task in pairs(Main) do
		if typeOf(task) == "table" then
			local cooldown = rawget(task, "cooldown")
			if cooldown ~= nil then
				if typeOf(cooldown) == "number" then
					task.cooldown = -1
				end
			else
				if rawget(task, "timer") ~= nil then
					task.cooldown = -1
				end
			end
			if name == "Experts" then
				if task.dawnEnabled then
					task.dawnCooldown = 0
				end
				if task.enlistEnabled then
					task.enlistCooldown = 0
				end
			end
		end
	end
end
	
local Alt_Events = {Alt_Tech = false, Alt_Alliance_Chest = false, Alt_Exploration = false, Alt_My_Island = false, Alt_Training_Troops = false, Alt_Recruit_Heroes = false, Alt_Pet_Adventure = false, Alt_Arena = false, 
	Alt_Gather_RSS = false, Alt_Auto_Join = false, Alt_Pet_Skills = false, Alt_City_Store = false, Alt_Daily_Rewards = false, Alt_War_Academy = false, Chief_Order_store = false, Alt_Crystal_Laboratory = false, 
	Alt_Mail = false, Alt_Bear = false, Nomadic_Merchant = false, Heal = false, Help = false, Alt_Triumph = false, Alt_Labyrinth = false}

local Enlistment_Claim_Date = preferenceGetString("expertsEnlistmentDate", "NA")
local Enlistment_Button_Region = Region(244, 101, 152, 152)

local DAWN_ACADEMY_PREF_KEY = "expertsDawnAcademyLastClaim"
local Dawn_Academy_Last_Claim = tonumber(preferenceGetString(DAWN_ACADEMY_PREF_KEY, ""))

local function updateDawnAcademyLastClaim(epoch)
	Dawn_Academy_Last_Claim = epoch
	if (epoch) then
		preferencePutString(DAWN_ACADEMY_PREF_KEY, tostring(epoch))
	else
		preferencePutString(DAWN_ACADEMY_PREF_KEY, "")
	end
end

local function getDawnAcademyLastClaim()
	return Dawn_Academy_Last_Claim
end

local shouldTriggerImmediateDawnAcademy

local function expertsLogMessage(message)
	if (Label_Region) then
		Logger(message)
	else
		print(message)
	end
end

local function scheduleEnlistmentClaim(context)
	context = context or ""
	if not Main.Experts.enlistEnabled then
		return
	end
	local today = os.date("%Y-%m-%d")
	if (Enlistment_Claim_Date == today) then
		Main.Experts.enlistPending = false
		expertsLogMessage(string.format("Experts: Enlistment already claimed today%s", context))
		return
	end
	Main.Experts.enlistPending = true
	Main.Experts.enlistCooldown = 0
	Main.Experts.enlistTimer = Main.Experts.enlistTimer or Timer()
	Main.Experts.enlistTimer:set()
	expertsLogMessage(string.format("Experts: Enlistment claim queued%s", context))
end

local function isForegroundGameLost()
	usePreviousSnap(false)
	local homeHit = SearchImageNew("Home Screen.png", Home_Screen_Region, 0.9, true)
	if not(homeHit.name) then return false end

	-- Avoid reopening if we’re still inside the game and the match is a false positive.
	usePreviousSnap(false)
	local cityVisible = SearchImageNew("City.png", Lower_Most_Half, 0.9, true).name
	local worldVisible = SearchImageNew("World.png", Lower_Most_Half, 0.9, true).name
	local allianceVisible = SearchImageNew("Alliance.png", nil, 0.9, true).name
	if cityVisible or worldVisible or allianceVisible then
		local now = os.time()
		if (now - lastHomeScreenSkipLog) >= 60 then
			Logger("Home Screen pattern matched but game UI is still present; skipping reopen")
			lastHomeScreenSkipLog = now
		end
		return false
	end

	return true
end

local RSS_Gathering = {Meat = 1, Wood = 2, Coal = 3, Iron = 4, Extra = 5}
local Bear_Checker_Trigger = true
local ABTTrigger = false

local StartAPP_Timer2
local Pack_Sale_List, Pack_Sale_Dir = {}, {}
--local RSS_Region = {RGS={R=Region(530, 745, 100, 22), N=0, RGB=0}, Meat={R=Region(530, 808, 100, 22), N=0, L=0}, Wood={R=Region(530, 871, 100, 22), N=0, L=0}, Coal={R=Region(530, 934, 100, 22), N=0, L=0}, Iron={R=Region(530, 998, 100, 22), N=0, L=0}}
local RSS_Region = {RGS={R=Region(530, 619, 100, 22), N=0, RGB=0}, Meat={R=Region(530, 682, 100, 22), N=0, L=0}, Wood={R=Region(530, 745, 100, 22), N=0, L=0}, Coal={R=Region(530, 808, 100, 22), N=0, L=0}, Iron={R=Region(530, 871, 100, 22), N=0, L=0}}
local RSS_Capacity = {[8]=14000000, [7]=6000000, [6]=3000000, [5]=1200000, [4]=600000, [3]=300000, [2]=150000, [1]=70000}

local Burden_Bearer_Skill = false
local Current_Date = os.date("%Y-%m-%d")
local Max_March = nil
local flags_coordinates = {}
local Enable_City_Timer = false

local Chief_Order_Events = {}

local new_startup = true
local Maps_Current_Iteration = 1

local Polar_Checker, AM_Status = false, true
local Divider_March, Current_Time
local Attack_Trigger = not Att_Timer
local Garbage_Cool_Down = 600 + os.time()
local Frame_Var, Heal_Var_Count = nil, 0
local Current_Injured = 0
local Chat_XY_Location
local Claim_Stamina = true
local Start_Heal = true
local Current_Heal_Gem = 0
local Chief_Island_Claims = 3
local Start_Time = os.time()
local Current_Function = ""
local Barney_Time = {}
local Rally_Troop_ROI

local Time_List = {31, 61, 91, 152, 302, 602, 1201, 1800, 2701, 3602, 4322, 6482, 7201}
local Claim_Rewards_Initial_Timer

local Agnes_Claimed_Date = nil

local function AgnesWasClaimedToday()
    local today = os.date("%Y-%m-%d")
    if Agnes_Claimed_Date == today then
        return true
    end
    if Agnes_Claimed_Date and Agnes_Claimed_Date ~= today then
        Agnes_Claimed_Date = nil
    end
    return false
end

local function MarkAgnesClaimed()
    Agnes_Claimed_Date = os.date("%Y-%m-%d")
end

local function ResetAgnesClaim()
    Agnes_Claimed_Date = nil
end

local rallyTeamCharTable = { {target = "charOCR/Rally Team/0.png", char = "0"},
						{target = "charOCR/Rally Team/1.png", char = "1"},
						{target = "charOCR/Rally Team/2.png", char = "2"},
						{target = "charOCR/Rally Team/3.png", char = "3"},
						{target = "charOCR/Rally Team/4.png", char = "4"},
						{target = "charOCR/Rally Team/5.png", char = "5"},
						{target = "charOCR/Rally Team/6.png", char = "6"},
						{target = "charOCR/Rally Team/7.png", char = "7"},
						{target = "charOCR/Rally Team/8.png", char = "8"},
						{target = "charOCR/Rally Team/9.png", char = "9"},
						{target = "charOCR/Rally Team/slash.png", char = "/"},
						{target = "charOCR/Rally Team/colon.png", char = ":"},
						{target = "charOCR/Rally Team/∞.png", char = "∞"}
			}
			
local rallyTimeCharTable = { {target = "charOCR/Rally Team/t0.png", char = "0"},
						{target = "charOCR/Rally Team/t1.png", char = "1"},
						{target = "charOCR/Rally Team/t2.png", char = "2"},
						{target = "charOCR/Rally Team/t3.png", char = "3"},
						{target = "charOCR/Rally Team/t4.png", char = "4"},
						{target = "charOCR/Rally Team/t5.png", char = "5"},
						{target = "charOCR/Rally Team/t6.png", char = "6"},
						{target = "charOCR/Rally Team/t7.png", char = "7"},
						{target = "charOCR/Rally Team/t8.png", char = "8"},
						{target = "charOCR/Rally Team/t9.png", char = "9"},
						{target = "charOCR/Rally Team/tcolon.png", char = ":"}
			}

local TaskTimeCharTable = { {target = "charOCR/Rally Team/t0.png", char = "0"},
						{target = "charOCR/Rally Team/t1.png", char = "1"},
						{target = "charOCR/Rally Team/t2.png", char = "2"},
						{target = "charOCR/Rally Team/t3.png", char = "3"},
						{target = "charOCR/Rally Team/t4.png", char = "4"},
						{target = "charOCR/Rally Team/t5.png", char = "5"},
						{target = "charOCR/Rally Team/t6.png", char = "6"},
						{target = "charOCR/Rally Team/t7.png", char = "7"},
						{target = "charOCR/Rally Team/t8.png", char = "8"},
						{target = "charOCR/Rally Team/t9.png", char = "9"},
						{target = "charOCR/Rally Team/tslash.png", char = "/"}
			}
			
local AMTimeCharTable = { {target = "charOCR/Alliance Mobilization/0.png", char = "0"},
						{target = "charOCR/Alliance Mobilization/1.png", char = "1"},
						{target = "charOCR/Alliance Mobilization/2.png", char = "2"},
						{target = "charOCR/Alliance Mobilization/3.png", char = "3"},
						{target = "charOCR/Alliance Mobilization/4.png", char = "4"},
						{target = "charOCR/Alliance Mobilization/5.png", char = "5"},
						{target = "charOCR/Alliance Mobilization/6.png", char = "6"},
						{target = "charOCR/Alliance Mobilization/7.png", char = "7"},
						{target = "charOCR/Alliance Mobilization/8.png", char = "8"},
						{target = "charOCR/Alliance Mobilization/9.png", char = "9"},
						{target = "charOCR/Alliance Mobilization/colon.png", char = ":"}
			}
			
local severelyInjuredCharTable = { {target = "charOCR/Severely Injured/0.png", char = "0"},
						{target = "charOCR/Severely Injured/1.png", char = "1"},
						{target = "charOCR/Severely Injured/2.png", char = "2"},
						{target = "charOCR/Severely Injured/3.png", char = "3"},
						{target = "charOCR/Severely Injured/4.png", char = "4"},
						{target = "charOCR/Severely Injured/5.png", char = "5"},
						{target = "charOCR/Severely Injured/6.png", char = "6"},
						{target = "charOCR/Severely Injured/7.png", char = "7"},
						{target = "charOCR/Severely Injured/8.png", char = "8"},
						{target = "charOCR/Severely Injured/9.png", char = "9"},
						{target = "charOCR/Severely Injured/slash.png", char = "/"},
			}

local ArenaCharTable = { {target = "charOCR/Arena Challenge/Big A.png", char = "A"},
					{target = "charOCR/Arena Challenge/Big B.png", char = "B"},
					{target = "charOCR/Arena Challenge/Big D.png", char = "D"},
					{target = "charOCR/Arena Challenge/Big E.png", char = "E"},
					{target = "charOCR/Arena Challenge/Big G.png", char = "G"},
					{target = "charOCR/Arena Challenge/Big H.png", char = "H"},
					{target = "charOCR/Arena Challenge/Big L.png", char = "L"},
					{target = "charOCR/Arena Challenge/Big M.png", char = "M"},
					{target = "charOCR/Arena Challenge/Big N.png", char = "N"},
					{target = "charOCR/Arena Challenge/Big P.png", char = "P"},
					{target = "charOCR/Arena Challenge/Big R.png", char = "R"},
					{target = "charOCR/Arena Challenge/Big S.png", char = "S"},
					{target = "charOCR/Arena Challenge/Big T.png", char = "T"},
					{target = "charOCR/Arena Challenge/Big U.png", char = "U"},
					{target = "charOCR/Arena Challenge/Big W.png", char = "W"},
					{target = "charOCR/Arena Challenge/Big Y.png", char = "Y"},
			}

local Message = {Game_Name = "WhiteOut Survival T", Beast_attack = 0, Polar_attack = 0, Meat_Gather = 0, Wood_Gather = 0, Coal_Gather = 0, Iron_Gather = 0, Online_Rewards = 0, Arena_Result = 0, Total_Restart = 0, Total_Reconnect = 0, Total_Screenshot = 0, Total_Error = 0, Total_Time = ""}
local keyOrder = {"Game_Name", "Beast_attack", "Polar_attack", "Meat_Gather", "Wood_Gather", "Coal_Gather", "Iron_Gather", "Online_Rewards", "Arena_Result", "Total_Restart", "Total_Reconnect", "Total_Screenshot", "Total_Error", "Total_Time"}
function printMessage(msg, order)
    local result = ""
    for _, key in ipairs(order) do
        result = result .. key:gsub("_", " ") .. " = " .. tostring(msg[key]) .. "\n"
    end
    return result
end

Label_Region = nil
local Error_Msg = ""

function folderExists(path)
    local file = io.open(scriptPath().. path, "r")
    if file ~= nil then return true
    else return false end
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

local personal = true
local DialogTitle = "Whiteout Survival"
if not(personal) then DialogTitle = "Whiteout Survival: v0607b" end

function formatTime(time)
    local hour, minute = string.match(time, "(%d+):(%d+)")
    hour = tonumber(hour)
    if hour < 10 then
        return string.format("0%d:%s", hour, minute)
    else
        return string.format("%d:%s", hour, minute)
    end
end

function Changelogs_GUI()
	local content 
	local file = io.open(scriptPath().. "Changelogs.txt", "r")
	if file then
		content = file:read("*a")
		file:close()
	else content = "File not found!" end
	dialogInit()
	addTextView(content)
	dialogShowFullScreen("Changelogs")
	preferencePutBoolean("readChangelogs", false)
end

function Main_GUI(version)
	dialogInit()
	newRow()
	addSeparator()
	addCheckBox("HealOption", "Heal Toggle", true)
	addSpinner("Heal_Status", {"Auto", "Manual"}, "Auto")
	newRow()
	addTextView("     Healing Count")
	addEditNumber("Allocate_Total", 100)
	addTextView("Multiplier ")
	addEditNumber("allocateTotalMultiplier", 1)
	addTextView("x")
	addSeparator()
	addCheckBox("HelpOption", "Help Toggle", true)
	addCheckBox("ChatClose", "Close Share Screen", true)
	newRow()
	addSeparator()
	addCheckBox("Auto_Intel", "Auto Intel", false)
	addCheckBox("Auto_Join_Enabled", "Auto Join", false)
	addTextView(" Queue Limit")
	addSpinner("autoJoinQueueLimit", {"0", "1", "2", "3", "4", "5", "6"}, 0)
	newRow()
	addSeparator()
	addCheckBox("Auto_Attack", "Auto Attack", false)
	addSpinner("Attack_Type", {"Beasts", "Polar Terror", "Reaper"}, "Beasts")	
	newRow()
	addCheckBox("Auto_Chests", "Alliance Chests", false)
	addCheckBox("Auto_Gather", "RSS Gather", false)
	addTextView("    Option")
	addSpinnerIndex("Auto_Gather_Option", {"1", "2"}, 1)
	newRow()
	addCheckBox("Enable_Experts", "Experts", false)
	addCheckBox("Exploration_Enabled", "Exploration", false)
	newRow()
	addCheckBox("Auto_Nomadic_Merchant", "Nomadic Merchant", false)
	addSpinner("Discounted", {"All RSS", "Discount", "Select"}, "All RSS")
	addSeparator()
	newRow()
	addTextView("   Timer in Minutes")
	newRow()
	addTextView("   Alliance Tech")
	addEditNumber("Auto_Tech_Timer", 60)
	addTextView("m")
	addTextView("   Daily Rewards")
	addEditNumber("Auto_DailyRewards_Timer", 60)
	addTextView("m")
	addTextView("   Mail Rewards")
	addEditNumber("Auto_Mail_Timer", 60)
	addTextView("m")
	newRow()
	addCheckBox("Auto_Triumph", "Alliance Triumph", false)
	newRow()
	addCheckBox("Auto_Tech", "Alliance Tech", false)
	addCheckBox("Auto_DailyRewards", "Daily Rewards", false)
	addCheckBox("Auto_Mail", "Mail Rewards", false)
	newRow()
	addCheckBox("Enable_My_Island", "Daybreak Island", false)
	addEditNumber("Auto_My_Island_Timer", 60)
	addTextView("m")
	addSpinner("mainDaybreakIslandOption", {"MyRewards", "Island Treasure", "Help Other", "All"}, "MyRewards")
	newRow()
	addSeparator()
	addTextView("          Events")
	newRow()
	addCheckBox("City_Events", "City Events", false)
	addCheckBox("AM_Enabled", "Alliance Mobilization", false)
	addCheckBox("Map_Options", "Map Options", false)
	addSeparator()
	newRow()
	addCheckBox("Barney_Enabled", "Use Alternate Character", false)
	addSeparator()
	newRow()
	addCheckBox("Auto_Reconnect", "Reconnect on Device Switch", false)
	addTextView("   Delay")
	addEditNumber("Auto_Reconnect_Timer", 5)
	addTextView(" m")
	newRow()
	addCheckBox("Enable_Logs", "File Logging", true)
	addCheckBox("Enable_Label", "On-Screen Logging", true)
	newRow()
	addCheckBox("auto_restart", "Restart on Error", true)
	addCheckBox("Reopen_Game", "Reopen Game if Closed", true)
	addEditNumber("Reopen_Game_Timer", 30)
	addTextView(" s")
	newRow()
	addCheckBox("Check_Alerts", "Check Alerts", false)
	addCheckBox("useShield", "Use Shield", false)
	addSpinner("requiredShield", {"2h", "8h", "24h", "72h"}, "8h")
	newRow()
	addTextView("   Sleep before next loop")
	addEditNumber("Repeat_Delay", 1)
	addTextView("   Second(s)")
	newRow()
	addTextView("   Return to Home Timer")
	addEditNumber("Stuck_Timer", 5)
	addTextView("   Minute(s)")
	newRow()
	addTextView("   Repetitions")
	addEditText("repeatCount", "00")
	addTextView("   use 00 for unlimited")
	newRow()
	addCheckBox("ignorePersistence", "Ignore Persistence", false)
	addCheckBox("readChangelogs", "Changelogs", false)
	addSeparator()
	if (getUserID() ~= "") then
		newRow()
		addCheckBox("Enable_Volume_Control", "Enable Volume Control", true)
		newRow()
		addCheckBox("Volume_UP", "V. Up", false)
		addSpinner("Volume_UP_Command", {"Auto Attack", "Gather Rss", "Intel", "Sleep", "Stop"}, "Auto Attack")
		addCheckBox("Volume_DOWN", "V. Down", false)
		addSpinner("Volume_DOWN_Command", {"Auto Attack", "Gather Rss", "Intel", "Sleep", "Stop"}, "Auto Attack")
		if (getUserID() == "zombrox@pm.me") then
			newRow()
			--addCheckBox("Send_Report_GUI", "Send Report", false)
			addTextView(" Starting Account")
			addSpinner("forceUse", {"Main", "Alt", "Alt_Bear"}, "Main")
		end
	end
	dialogShowFullScreen(DialogTitle.. " " ..version)
	--if not(getUserID() == "") then addEditNumber("Collect_Garbage_Timer", 10) end
	Auto_Allocate = true
	Allocate_Total = Allocate_Total * allocateTotalMultiplier
	Stuck_Timer = Stuck_Timer * 60
	Auto_My_Island_Timer = Auto_My_Island_Timer * 60
	
	if (readChangelogs) then Changelogs_GUI() end
	--[[Collect_Garbage_Timer = Collect_Garbage_Timer * 60
	--if (alternateClick) then setAlternativeClick(true) end
	--addEditNumber("First_Total", 100)
	--addTextView("Second")
	--addEditNumber("Second_Total", 100)
	--addTextView("Third")
	--addEditNumber("Third_Total", 100)--]]
end

function Intel_Options_GUI()
	dialogInit()
	addTextView("Intel Now/Later?")
	addSpinner("Intel_Now_later", {"Now", "Later"}, "Now")
	addCheckBox("Intel_Master_Bounty", "Include Bounty", false)
	newRow()
	addTextView("Intel Count")
	addSpinnerIndex("Intel_Count", {"1", "2", "3"}, 3)
	newRow()
	addTextView("Time 1")
	addEditText("intel_time1", "00:01")
	addCheckBox("Claim_Stamina1", "Claim Stamina", false)
	newRow()
	addTextView("Time 2")
	addEditText("intel_time2", "08:01")
	addCheckBox("Claim_Stamina2", "Claim Stamina", false)
	newRow()
	addTextView("Time 3")
	addEditText("intel_time3", "16:01")
	addCheckBox("Claim_Stamina3", "Claim Stamina", false)
	newRow()
	addCheckBox("Use_RSS_Pet_Skill", "Use RSS Pet Skills", false)
	addSpinner("Pet_Skill_Time", {"Time 1", "Time 2", "Time 3"}, "Time1")
	--newRow()
	--addCheckBox("flameFangs", "Flame and Fangs", false)
	newRow()
	addCheckBox("Enable_Auto_Attack", "Enable Auto Attack", false)
        dialogShowFullScreen("Intel Options")
        Logger("Post-GUI Flag_Req=" .. tostring(Flag_Req))
end

function Maps_Options_GUI()
	dialogInit()
	newRow()
	addTextView("Option")
	addSpinner("Maps_Option_Type", {"Scout", "Attack", "SFC"}, "Attack")
	addCheckBox("SFC_SVS", "State VS State", false)
	newRow()
	addTextView("Coordinates")
	addSpinner("Coordinates_Type", {"Bookmarks", "Manual"}, "Bookmarks")
	newRow()
	addTextView("X: ")
	addEditNumber("X_Coordinate", 100)
	addTextView("Y: ")
	addEditNumber("Y_Coordinate", 100)
	newRow()
	addCheckBox("Attack_Heal", "Check Injured", false)
	addCheckBox("Spam_Heal", "Spam Heal", false)
	newRow()
	addTextView("  Max Injured Troops")
	addEditNumber("Required_Injured", 20000)
	addTextView("  Min Spam Heal")
	addEditNumber("minSpamHeal", 5000)
	newRow()
	addTextView("  Heal Time Per Batch")
	addEditNumber("healTimebyBatch", 2)
	addTextView("  Seconds")
	newRow()
	addCheckBox("coordOffsetCB", "Coord Offset", false)
	addEditText("coordOffset", "X,Y")
	newRow()
	addSeparator()
	addTextView("Sunfire Castle Specific Options")
	newRow()
	addCheckBox("Sunfire_Castle", "Sunfire Castle", false)
	newRow()
	addCheckBox("Turret_Northground", "Northground", false)
	addCheckBox("Turret_Eastcourt", "Eastcourt", false)
	newRow()
	addCheckBox("Turret_Westplain", "Westplain", false)
	addCheckBox("Turret_Southwing", "Southwing", false)
	newRow()
	addTextView("Repeat Count")
	addEditNumber("Maps_Repeat_Total", 0)
	newRow()
	addTextView("Repeat Delay in Seconds")
	addEditNumber("Maps_Repeat_Delay", 0)
	addSeparator()
	newRow()
	addSeparator()
	addTextView("Manual: Input XY Coordinates")
	newRow()
	addTextView("Bookmarks: Use saved Coordinates")
	newRow()
	addTextView("             in Bookmarks")
	newRow()
	addTextView("Attack Heal: Attack Only if injured")
	newRow()
	addTextView("             is less than Injured Troops")
	newRow()
	dialogShowFullScreen("Map Options")
end

function AutoAttack_GUI()
	dialogInit()
	newRow()
	addTextView("          Level")
	if (Attack_Type == "Beasts") then
		addEditNumber("Beasts_Req_Lv", 1)
	elseif (Attack_Type == "Polar Terror") then
		addSpinnerIndex("Polar_Req_Lv", {"1", "2", "3", "4", "5", "6", "7", "8"}, 8)
	end
	addTextView("Flag")
        addSpinner("Flag_Req", {"0", "1", "2", "3", "4", "5", "6", "7", "8"}, "0")
	addCheckBox("Use_Hero", "Use Hero", false)
	addSpinner("Hero_Type", {"Gina", "Bokan", "Both"}, 1)
	newRow()
	addTextView("          Gina Level")
	addSpinnerIndex("Gina_Skills", {"10", "12", "15", "18", "20"}, 10)
	addCheckBox("Use_All", "All March", false)
	newRow()
	addCheckBox("Att_Timer", "Attack Time", false)
	addTextView("   Hour")
	addEditText("Attack_Hour","00")
	addTextView("Minutes")
	addEditText("Attack_Minutes","00")
	newRow()
	addTextView("          Delay Timer")
	addEditNumber("Use_All_Timer", 30)
	newRow()
	addCheckBox("Equalize_March", "Equalize", false)
	addCheckBox("Solo_troop", "Solo Troop", true)
	addSeparator()
	addCheckBox("AutoStop_Attack", "Stop at 0 Stamina", true)
	newRow()
	addTextView(" Attack Limit")
	addEditNumber("attackLimit", 30)
	addTextView(" Current : " ..preferenceGetNumber("attackLimitCounter", 0))
	addCheckBox("resetAttackLimit", "Reset Limit", false)
	newRow()
	addSeparator()
	if (getUserID() == "zombrox@pm.me") then
		addTextView("  Prioritize Events")
		newRow()
		addCheckBox("Auto_Merc_Prestige", "Mercenary Prestige", false)
		newRow()
		addCheckBox("Auto_Hero_Mission", "Hero Mission", false) --check events on reset, read OCR from 0 - 10, attack remaining mission using backpack?, check hero mission tab to claim rewards.
	end	
        dialogShowFullScreen("Auto Attack Options")
        Logger("Post-GUI Flag_Req=" .. tostring(Flag_Req))
        if (resetAttackLimit) then
		preferencePutNumber("attackLimitCounter", 0)
		preferencePutBoolean("resetAttackLimit", false)
	end
	Main.Attack.counter = preferenceGetNumber("attackLimitCounter", 0)
	if (Auto_Hero_Mission) then table.insert(Main.Events.List, "Hero Mission/Events Hero Mission Tab.png") end
end

function RSS_GUI1()
	dialogInit()
	newRow()
	addTextView("Auto Gather")
	addSpinner("RSS_Input0", {"Automatic", "Manual"}, "Automatic")
	addCheckBox("exactTroops0", "Fixed Count", false)
	newRow()
	addTextView("   Troop Allocation")
	addEditNumber("troopAllocation0", 1200)
	addTextView(" Manual Only*")
	newRow()
	addCheckBox("useBoost", "Use Boost", false)
	addSpinner("rssBoostType", {"8 Hours", "24 Hours"}, "8 Hours")
	addCheckBox("useGatheringGems", "Use Gems", false)
	newRow()
	addTextView("Resources Max Level")
	addEditNumber("RSS_Max_Level0", 8)
	addTextView("Min Level")
	addEditNumber("RSS_Min_Level0", 5)
	newRow()
	addTextView("Cloris Level")
	addSpinner("Cloris_Level0", {"5", "10", "15", "20", "25"}, "25")
	
	addTextView("Eugene Level")
	addSpinner("Eugene_Level0", {"5", "10", "15", "20", "25"}, "25")
	newRow()
	addTextView("Charlie Level")
	addSpinner("Charlie_Level0", {"5", "10", "15", "20", "25"}, "25")
	
	addTextView("Smith Level")
	addSpinner("Smith_Level0", {"5", "10", "15", "20", "25"}, "25")
	newRow()
	addTextView("Extra Gathers")
	newRow()
	addCheckBox("Extra_Gather_1_Status_0", "Extra Gather 1", false)
	addSpinner("Extra_Gather_1_0", {"Meat", "Wood", "Coal", "Iron"}, "Meat")
	newRow()
	addCheckBox("Extra_Gather_2_Status_0", "Extra Gather 2", false)
	addSpinner("Extra_Gather_2_0", {"Meat", "Wood", "Coal", "Iron"}, "Meat")
	newRow()
	addCheckBox("priorityTroops1", "Priority High Level Troop", false)
	dialogShowFullScreen("Resources Gathering Options 1")
end

function RSS_GUI2()
	dialogInit()
	newRow()
	addTextView("Auto Gather")
	addSpinner("RSS_Input1", {"Automatic", "Manual"}, "Automatic")
	addCheckBox("exactTroops1", "Fixed Count", false)
	newRow()
	addTextView("   Troop Allocation")
	addEditNumber("troopAllocation1", 1200)
	addTextView(" Manual Only*")
	newRow()
	addCheckBox("useBoost", "Use Boost", false)
	addSpinner("boostType", {"8 Hours", "24 Hours"}, "8 Hours")
	addCheckBox("useGatheringGems", "Use Gems", false)
	newRow()
	addTextView("Resources Max Level")
	addEditNumber("RSS_Max_Level1", 8)
	addTextView("Min Level")
	addEditNumber("RSS_Min_Level1", 5)
	
	newRow()
	addTextView("Cloris Level")
	addSpinner("Cloris_Level1", {"5", "10", "15", "20", "25"}, "25")
	
	addTextView("Eugene Level")
	addSpinner("Eugene_Level1", {"5", "10", "15", "20", "25"}, "25")
	newRow()
	addTextView("Charlie Level")
	addSpinner("Charlie_Level1", {"5", "10", "15", "20", "25"}, "25")	
	addTextView("Smith Level")
	addSpinner("Smith_Level1", {"5", "10", "15", "20", "25"}, "25")
	newRow()
	addTextView("Extra Gathers")
	newRow()
	addCheckBox("Extra_Gather_1_Status_1", "Extra Gather 1", false)
	addSpinner("Extra_Gather_1_1", {"Meat", "Wood", "Coal", "Iron"}, "Meat")
	newRow()
	addCheckBox("Extra_Gather_2_Status_1", "Extra Gather 2", false)
	addSpinner("Extra_Gather_2_1", {"Meat", "Wood", "Coal", "Iron"}, "Meat")
	--addSpinnerIndex("Smith_Count0", {"1", "2"}, 1)
	newRow()
	addCheckBox("priorityTroops2", "Priority High Level Troop", false)
	dialogShowFullScreen("Resources Gathering Options 2")
end

function RSS_GUI_Settings()
	RSS_Input = RSS_Input0 or RSS_Input1
	exactTroops = exactTroops0 or exactTroops1
	troopAllocation = troopAllocation0 or troopAllocation1
	RSS_Max_Level = RSS_Max_Level0 or RSS_Max_Level1
	RSS_Min_Level = RSS_Min_Level0 or RSS_Min_Level1
	RGS = RGS0 or RGS1
	MGS = MGS0 or MGS1
	Cloris_Level = Cloris_Level0 or Cloris_Level1
	WGS = WGS0 or WGS1
	Eugene_Level = Eugene_Level0 or Eugene_Level1
	CGS = CGS0 or CGS1
	Charlie_Level = Charlie_Level0 or Charlie_Level1
	IGS = IGS0 or IGS1
	Smith_Level = Smith_Level0 or Smith_Level1
	Extra_Gather_1_Status = Extra_Gather_1_Status_0 or Extra_Gather_1_Status_1
	Extra_Gather_2_Status = Extra_Gather_2_Status_0 or Extra_Gather_2_Status_1
	Extra_Gather_1 = Extra_Gather_1_0 or Extra_Gather_1_1
	Extra_Gather_2 = Extra_Gather_2_0 or Extra_Gather_2_1
	Gather_Priority_Troops = priorityTroops1 or priorityTroops2
	RSS_Region["Meat"].L = tonumber(Cloris_Level)
	RSS_Region["Wood"].L = tonumber(Eugene_Level)
	RSS_Region["Coal"].L = tonumber(Charlie_Level)
	RSS_Region["Iron"].L = tonumber(Smith_Level)
end

function CityEvents_GUI()
	dialogInit()
	addCheckBox("Troops_Training", "Troops Training", true)
	addCheckBox("upgradeTroops", "Priority Upgrade", false)
	newRow()
	addSeparator()
	newRow()
	addCheckBox("Recruit_Heroes", "Recruit Heroes", true)
	addCheckBox("Online_Rewards", "Online Rewards", true)
	newRow()
	addCheckBox("Pet_Adventure", "Pet Adventure", true)
	addCheckBox("Chief_Order", "Chief Order", true)
	newRow()
	addCheckBox("Auto_Arena", "Auto Arena", false)
	addTextView(" *")
	addSpinner("Arena_Now_later", {"Now", "Later"}, "Now")
	addTextView(" *")
	addTextView("  Arena Time")
	addEditText("Arena_Time", "23:50")
	newRow()
	addTextView("  Arena Daily Purchase")
	addSpinner("mainArenaGems", {"0", "1", "2", "3", "4", "5"}, 0)
	addTextView("Arena Exclusion: ")
	addEditText("arenaExclusion", "0")
	newRow()
	addCheckBox("Enable_War_Academy", "Auto War Academy", false)
	addEditNumber("WARedeemTotal", 20)
	newRow()
	addCheckBox("Enable_Crystal_Laboratory", "Auto Laboratory", false)
	addCheckBox("Enable_The_Labyrinth", "The Labyrinth", false)
	newRow()
	addCheckBox("Enable_Bear_Event", "Bear Hunting Event", false)
	addTextView(" *")
	addSpinner("Bear_Now_later", {"byTask", "byEvents", "Now"}, "byTask")
	newRow()
	addCheckBox("Enable_Hero_Mission", "Hero Mission", false)
	if not(Auto_Intel) then
		addCheckBox("Storehouse_Stamina", "Claim Stamina", false)
	end
	dialogShowFullScreen("City Events Options")
end

function isValidTimeHHMM(timeString)
    local hour, minute = timeString:match("^(%d%d):(%d%d)$")
    if hour and minute then
        hour, minute = tonumber(hour), tonumber(minute)
        if hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 then
            return true
        end
    end 
    return false
end

function Chief_Order_GUI()
	dialogInit()
	addCheckBox("Urgent_Mobilization", "Urgent Mobilization", true)
	addTextView(" Count")
	addSpinnerIndex("Urgent_Mobilization_Count", {"1", "2", "3"}, 2)
	newRow()
	addTextView(" Preferred Time")
	newRow()
	addEditText("Urgent_Mobilization_Time1", "04:00")
	addEditText("Urgent_Mobilization_Time2", "16:00")
	addEditText("Urgent_Mobilization_Time3", "00:00")
	newRow()
	addCheckBox("Productivity_Day", "Productivity Day", true)
	addTextView(" Count")
	addSpinnerIndex("Productivity_Day_Count", {"1", "2"}, 2)
	newRow()
	addTextView(" Preferred Time")
	newRow()
	addEditText("Productivity_Day_Time1", "04:00")
	addEditText("Productivity_Day_Time2", "16:00")
	newRow()
	addCheckBox("Rush_Job", "Rush Job", true) -- once only
	addEditText("Rush_Job_Time1", "04:00")
	newRow()
	addCheckBox("Festivities", "Festivities", true) -- once only
	addEditText("Festivities_Time1", "04:30")
	addSeparator()
	newRow()
	addTextView("Guide on Using Chief Order")
	newRow()
	addTextView("")
	newRow()
	addTextView("Choose from 4 Chief Orders available.")
	newRow()
	addTextView("Some Chief Orders have a Count feature, allowing you to specify how many times you want to use them.")
	newRow()
	addTextView("")
	newRow()
	addTextView("Time Configuration:")
	newRow()
	addTextView("Configure the time for claiming the Chief Order based on your Count feature")
	newRow()
	addTextView("")
	newRow()
	addTextView("Example:")
	newRow()
	addTextView("For Urgent Mobilization, which can be used 3 times, set the Count to 3 and choose preferred times such as 09:00, 17:00, 01:00.")
	dialogShowFullScreen("Chief Order Options")
	if (Urgent_Mobilization) then
		for i = 1, Urgent_Mobilization_Count do
			if not(isValidTimeHHMM(_G["Urgent_Mobilization_Time" ..i])) then scriptExit(string.format("Invalid Time format in Urgent Mobilization\nTime: %s\nFound: %s\nRequired Format HH:MM\nSample: 16:00", i, _G["Urgent_Mobilization_Time" ..i])) end
		end
	end
	if (Productivity_Day) then
		for i = 1, Productivity_Day_Count do
			if not(isValidTimeHHMM(_G["Productivity_Day_Time" ..i])) then scriptExit(string.format("Invalid Time format in Productivity Day\nTime: %s\nFound: %s\nRequired Format HH:MM\nSample: 16:00", i, _G["Productivity_Day_Time" ..i])) end
		end
	end
	if (Rush_Job) and not(isValidTimeHHMM(Rush_Job_Time1)) then scriptExit(string.format("Invalid Time format in Rush Job\nFound: %s\nRequired Format HH:MM\nSample: 16:00", Rush_Job_Time1)) end
	if (Festivities) and not(isValidTimeHHMM(Festivities_Time1)) then scriptExit(string.format("Invalid Time format in Festivities\nFound: %s\nRequired Format HH:MM\nSample: 16:00", Festivities_Time1)) end
end

function Bear_Hunting_GUI()
	local bearStatus = Bear_Now_later
	local Rally_Hero_List = {Infantry = {}, Lancer = {}, Marksman = {}}
	for i, heroType in ipairs({"Infantry", "Lancer", "Marksman"}) do
		local initialList = scandirNew("Hero List/" ..heroType)
		for i2, hero in ipairs(initialList) do
			curHero = hero:gsub(".png", "")
			table.insert(Rally_Hero_List[heroType], curHero)
		end
	end
	dialogInit()
	if (find_in_list({"Now", "byEvents"}, bearStatus))  then
		newRow()
		addTextView("  Prep Time")
		addEditText("Bear_Start_Time", "00:01")
		addTextView("  *")
		addTextView("  Bear Event Time")
		addEditText("Actual_Bear_Time", "00:01")
		addTextView("  *")
	end
	newRow()
	addCheckBox("Bear_Pet_Skill", "Use Pet Skill", false)
	addCheckBox("Use_Troop_Ratio", "Troop Ratio", false)
	addCheckBox("Check_Troop_Count", "Check Troop Count", false)
	newRow()
	addTextView("Infantry    |    Lancer    |    Marksman   Troop Ratio %")
	newRow()
	addEditNumber("Troop_Ratio_Infantry", 33)
	addTextView(" %      ")
	addEditNumber("Troop_Ratio_Lancer", 34)
	addTextView(" %      ")
	addEditNumber("Troop_Ratio_Marksman", 33)
	addTextView(" %")
	newRow()
	addCheckBox("Enable_Check_Hero", "Check Heroes", false)
	addSpinner("Rally_Hero3", Rally_Hero_List["Infantry"], "None")
	addSpinner("Rally_Hero1", Rally_Hero_List["Marksman"], "None")
	addSpinner("Rally_Hero2", Rally_Hero_List["Lancer"], "None")
	newRow()
	addCheckBox("Bear_Troop_Flag", "Rally Troop Formation", false)
	addSpinner("Bear_Flag_Req", {"1", "2", "3", "4", "5", "6", "7", "8"}, 1)
	addCheckBox("Joiner_Flags", "Joiner Flags", false)
	newRow()
	addCheckBox("Bear_Self_Rally", "Start Bear Rally", false)
	addCheckBox("Bear_Join_rally", "Join Bear Rally", false)
	newRow()
	addTextView("  Required Trap")
	addSpinner("mainBearTrap", {"Trap 1", "Trap 2", "Any"}, "Trap 1")
	newRow()
	addSeparator()
	addTextView(" Last Run Date")
	addEditText("mainBearLastRun", "2024/11/03 19:00:00")
	addTextView("Ex. 2024/11/03 19:00:00")
	newRow()
	addTextView(" Next Run Date")
	addEditText("mainBearNextRun", "NA")
	addTextView("Auto Update")
	addSeparator()
	addTextView("Bear Guide")
	if (bearStatus == "byEvents") then 
		newRow()
		addTextView("Bear Time Prep: Set at least 7 minutes before the actual Bear hunting event.")
	end
	newRow()
	addTextView("Use Pet Skills: Activates all Battle Pet skills.")
	newRow()
	addTextView("Troop Ratio: Adjusts Troop Ratio. Should not exceed 100% of total troops.")
	newRow()
	addTextView("Check Troop Count: Captures troop count during preparation and ignores any troops that don’t match this count when joining rally.")
	newRow()
	addTextView("It’s recommended to use Troop Ratio to update troop count when activating Pet Skills!")
	newRow()
	addTextView("Check Heroes: This function only verifies if a Hero is placed but doesn’t add your selected Hero. Uncheck this option if using Joiner Flags and Rally Formation set to 7th or 8th.")
	newRow()
	addTextView("To add your desired Hero, configure it within the Rally Formation you plan to use; the 7th or 8th Flag is recommended.")
	newRow()
	addTextView("Troop Formation: Selects required troop formation when starting the bear rally.")
	if (find_in_list({"Now", "byEvents"}, bearStatus))  then
		newRow()
		addTextView("Actual Bear Time: Set your actual bear hunting time.")
	end
	newRow()
	addTextView("Start Bear Rally: Enables you to start your own Bear Rally.")
	newRow()
	addTextView("Join Bear Rally: Allows you to join a Bear Rally.")
	newRow()
	addTextView("Joiner Flags: Clicks all available flags and stops immediately when a hero is found. Will check from 1-6 only")
	newRow()
	addTextView("After Bear Rally, if Auto Gather is Enabled, you will automatically gather again.")
	newRow()
	addTextView("After Bear Rally, if Troop Ratio is Enabled, you will return to a 33-34-33 ratio.")

	if (bearStatus == "byTask") then 
		newRow()
		addTextView("Last Run Date: Initially set manually, it will auto-update when the Bear Event triggers. If the task is unavailable, the bot will search for the bear image automatically after 46 hours.")
		newRow()
		addTextView("Next Run Date: Automatically updates when a task is found. Add manually if the bear has not been scheduled. Optional, as the script will auto-start when the bear button is detected.")
	end
	dialogShowFullScreen("Bear Hunting Options")
	if not(Troop_Ratio_Infantry + Troop_Ratio_Lancer + Troop_Ratio_Marksman == 100) then scriptExit("Invalid Ratio. Total should be 100") end
end

function Nomadic_Merchant_GUI()
	dialogInit()
	addCheckBox("nomadicGems", "Use Gems", false)
	addCheckBox("nomadicFree", "All Free", true)
	addSeparator()
	addTextView(" Resources")
	newRow()
	addCheckBox("nomadicMeat", "Meat", true)
	addCheckBox("nomadicWood", "Wood", true)
	addCheckBox("nomadicCoal", "Coal", true)
	addCheckBox("nomadicIron", "Iron", true)
	newRow()
	addSeparator()
	addTextView(" Speedups")
	newRow()
	addCheckBox("nomadicTroopTraining", "Troop Training", true)
	addCheckBox("nomadicConstruction", "Construction", true)
	newRow()
	addCheckBox("nomadicResearch", "Research", true)
	addCheckBox("nomadicHealing", "Healing", true)
	newRow()
	addSeparator()
	addTextView(" Skill Manual")
	newRow()
	addCheckBox("nomadicEpicExpedition", "Epic Expedition", true)
	addCheckBox("nomadicRareExpedition", "Rare Expedition", true)
	newRow()
	addCheckBox("nomadicEpicExploration", "Epic Exploration", true)
	addCheckBox("nomadicRareExploration", "Rare Exploration", true)
	addSeparator()
	addTextView(" EXP")
	newRow()
	addCheckBox("nomadicHero", "Hero", true)
	addCheckBox("nomadicVIP", "VIP", true)
	addSeparator()
	addTextView(" Teleport")
	newRow()
	addCheckBox("nomadicRandomTeleporter", "Random Teleporter", true)	
	addCheckBox("nomadicAdvancedTeleporter", "Advanced Teleporter", true)	
	newRow()
	addSeparator()
	addTextView(" List of Items you want to buy with Gems. Ex. 'VIP, Random Teleport'")
	newRow()
	addTextView(" Write 'All' to use all Gem Items.")
	newRow()
	addEditText("nomadicGemsList", "All")
	dialogShowFullScreen("Nomadic Merchant Options")
	if (nomadicGems) and (nomadicGemsList == "") then scriptExit("You left Gems List Empty. Write 'All' if you want to buy all gems item or Write 'VIP, Random Teleport' if you want specific items only.") end
end

function Experts_GUI()
	dialogInit()
	newRow()
	addTextView("Manual Expert Controls")
	newRow()
	addCheckBox("Experts_Claim_Marksmen", "Claim Marksmen", false)
	newRow()
	addCheckBox("Experts_Dawn_Academy", "Dawn Academy", false)
	newRow()
	addCheckBox("Experts_Enlistment_Claim", "Enlistment Claim", false)
	newRow()
	addEditNumber("Experts_Dawn_Timer", 120)
	addTextView(" minutes between Trek Supply checks (min 15)")
	newRow()
	addTextView("Check to queue the expert marksman routine once.")
	newRow()
	addTextView("Dawn Academy (Trek Supplies) runs on a repeating timer when enabled.")
	newRow()
	addTextView("Enlistment Claim runs automatically after the daily reset.")
	dialogShowFullScreen("Experts")
	Main.Experts.enabled = true
	Main.Experts.request = Experts_Claim_Marksmen or false
	Main.Experts.dawnEnabled = Experts_Dawn_Academy or false
	Main.Experts.enlistEnabled = Experts_Enlistment_Claim or false
	if (Main.Experts.request) then
		if (Label_Region) then Logger("Experts: Claim Marksmen queued") else print("Experts: Claim Marksmen queued") end
	else
		if (Label_Region) then Logger("Experts: no manual actions queued") else print("Experts: no manual actions queued") end
	end
	if (Main.Experts.dawnEnabled) then
		Main.Experts.dawnNeedsImmediateCheck = shouldTriggerImmediateDawnAcademy()
		local dawnTimerMinutes = tonumber(Experts_Dawn_Timer) or 0
		if dawnTimerMinutes <= 0 then dawnTimerMinutes = 120 end
		dawnTimerMinutes = math.max(15, dawnTimerMinutes)
		Main.Experts.dawnInterval = dawnTimerMinutes * 60
		if not (Main.Experts.dawnTimer) then Main.Experts.dawnTimer = Timer() end
		Main.Experts.dawnTimer:set()
		if (Main.Experts.dawnNeedsImmediateCheck) then
			Main.Experts.dawnCooldown = 0
			expertsLogMessage("Experts: Dawn Academy immediate check queued to verify trek claim status")
		else
			Main.Experts.dawnCooldown = Main.Experts.dawnInterval
			local nextRunUTC = formatUTCRelative(Main.Experts.dawnCooldown)
			local logMsg = string.format("Experts: Dawn Academy scheduled in %d minutes (%s UTC)", dawnTimerMinutes, nextRunUTC)
			if (Label_Region) then Logger(logMsg) else print(logMsg) end
			expertsLogMessage(logMsg)
		end
	else
		Main.Experts.dawnTimer = nil
		Main.Experts.dawnCooldown = 0
		Main.Experts.dawnNeedsImmediateCheck = false
		Main.Experts.dawnInterval = 0
		if (Label_Region) then
			Logger("Experts: Dawn Academy disabled")
		else
			print("Experts: Dawn Academy disabled")
		end
	end
	if (Main.Experts.enlistEnabled) then
		scheduleEnlistmentClaim(" (via Experts menu)")
	else
		Main.Experts.enlistPending = false
		Main.Experts.enlistTimer = nil
		Main.Experts.enlistCooldown = 0
		if (Label_Region) then
			Logger("Experts: Enlistment claim disabled")
		else
			print("Experts: Enlistment claim disabled")
		end
	end
end

function ALT_GUI()
	dialogInit()
	newRow()
	addSeparator()
	addTextView("  Alternate Character Schedule")
	newRow()
	addEditText("Barney_Time_Str", "06:00, 15:00, 20:00")
	addSeparator()
	newRow()
	addCheckBox("altTech", "Tech", false)
	addCheckBox("altAllianceChest", "Alliance Chest", false)
	newRow()
	addCheckBox("altExploration", "Exploration", false)
	addCheckBox("altMyIsland", "My Island", false)
	newRow()
	addCheckBox("altTroopTraining", "Troop Training", false)
	addCheckBox("altRecruitHeroes", "Recruit Heroes", false)
	newRow()
	addCheckBox("altPetAdventure", "Pet Adventure", false)
	addCheckBox("altRssGather", "RSS Gather", false)
	newRow()
	addCheckBox("altAutoJoin", "Auto Join", false)
	addCheckBox("altWarAcademy", "War Academy", false)
	addEditNumber("altWARedeemTotal", 20)
	newRow()
	addCheckBox("altPetSkills", "Pet Skills", false)
	addCheckBox("altStoreHouse", "Store House", false)
	newRow()
	addCheckBox("altDailyRewards", "Daily Rewards", false)
	addCheckBox("altNomadicMerchant", "Nomadic Merchant", false)
	newRow()
	addCheckBox("altChiefOrder", "Chief Order", false)
	addCheckBox("altCrystalLaboratory", "Crystal Laboratory", false)
	newRow()
	addCheckBox("altArena", "Arena", false)
	addTextView("  Daily Purchase")
	addSpinner("altArenaGems", {"0", "1", "2", "3", "4", "5"}, "0")
	newRow()
	addCheckBox("altMail", "Mail Rewards", false)
	addCheckBox("Alt_Triumph", "Triumph", false)
	newRow()
	addCheckBox("Alt_Labyrinth", "Labyrinth", false)
	newRow()
	addSeparator()
	addCheckBox("altBear", "Bear Hunting", false)
	addTextView("  Process")
	addSpinner("altBearProcess", {"byTask", "byEvents"}, "byTask")
	newRow()
	addTextView("  Required Trap")
	addSpinner("altBearTrap", {"Trap 1", "Trap 2", "Any"}, "Trap 1")
	newRow()
	addTextView("  Last Run")
	addEditText("altBearLastRun", "2024/11/11 21:35:00")
	addTextView("  *")
	newRow()
	addTextView("  Next Run")
	addEditText("altBearNextRun", "2024/11/13 21:35:00")
	addTextView("  *")
	addSeparator()
	dialogShowFullScreen("Alt Options")
end

function Mercenary_Prestige_GUI()
	dialogInit()
	newRow()
	addTextView("                    Flag No  |       Attack Type        | Stamina")
	newRow()
	addTextView("March Set 1")
	addSpinnerIndex("March_Set1", {"1", "2", "3", "4", "5", "6", "7", "8"}, 1)
	addSpinner("March_Status_1", {"Solo", "Rally", "Request Help"}, "Solo")
	addEditNumber("Stamina_Set1", 30)
	newRow()
	addTextView("March Set 2")
	addSpinnerIndex("March_Set2", {"1", "2", "3", "4", "5", "6", "7", "8"}, 1)
	addSpinner("March_Status_2", {"Solo", "Rally", "Request Help"}, "Solo")
	addEditNumber("Stamina_Set2", 30)
	newRow()
	addTextView("March Set 3")
	addSpinnerIndex("March_Set3", {"1", "2", "3", "4", "5", "6", "7", "8"}, 1)
	addSpinner("March_Status_3", {"Solo", "Rally", "Request Help"}, "Solo")
	addEditNumber("Stamina_Set3", 30)
	newRow()
	
	--add option which level to choose
	dialogShowFullScreen("Merceneray Prestige Options")
	Main.mercPrestige.marchSettings = {[1] = {flag = March_Set1, attackType = March_Status_1, stamina = Stamina_Set1}, 
		[2] = {flag = March_Set2, attackType = March_Status_2, stamina = Stamina_Set2}, 
		[3] = {flag = March_Set3, attackType = March_Status_3, stamina = Stamina_Set3}}
	table.insert(Main.Events.List, "Mercenary Prestige/Events Merc Tab.png")
end

function Other_GUI()
	dialogInit()
	addTextView("Sleep Time in Minute(s)")
	addEditNumber("manualSleepTimer", 30)
	dialogShowFullScreen("Sleep GUI")
	local waitTime = manualSleepTimer * 60
	local current_time = os.time()
	formatted_time = os.date("%H:%M:%S", current_time + waitTime)
	Logger(string.format("Sleep: %s minute(s) (Until %s)", manualSleepTimer, formatted_time))
	wait(waitTime)
end

function OtherRequired_GUI()
	addEditNumber("rssMeatMarchTime", 0)
	addEditNumber("rssWoodMarchTime", 0)
	addEditNumber("rssCoalMarchTime", 0)
	addEditNumber("rssIronMarchTime", 0)
	addEditNumber("rssExtra1MarchTime", 0)
	addEditNumber("rssExtra2MarchTime", 0)
	
	Main.rssGather.marchTime["Meat"] = preferenceGetNumber("rssMeatMarchTime", 0)
	Main.rssGather.marchTime["Wood"] = preferenceGetNumber("rssWoodMarchTime", 0)
	Main.rssGather.marchTime["Coal"] = preferenceGetNumber("rssCoalMarchTime", 0)
	Main.rssGather.marchTime["Iron"] = preferenceGetNumber("rssIronMarchTime", 0)
	Main.rssGather.marchTime["Extra1"] = preferenceGetNumber("rssExtra1MarchTime", 0)
	Main.rssGather.marchTime["Extra2"] = preferenceGetNumber("rssExtra2MarchTime", 0)
end

local function tableToString(tbl)
    local result = ""  -- Start with an empty string
    for i, v in ipairs(tbl) do
        if v and v:match("%S") then  -- Check for non-whitespace entries
            result = result .. v .. "\n"  -- Append each entry followed by a newline
        end
    end
    return result
end

function Logger(message)
	if typeOf(message) == 'table' then message = table.concat(message, "\n")
	elseif typeOf(message) == 'number' then message = tonumber(message) end

    if Enable_Logs then
        if message and message:match("%S") then
            local current_time = os.date("%Y-%m-%d %H:%M:%S")
            local log_message = string.format("[%s] %s - %s", current_time, CHARACTER_ACCOUNT, message)
            --table.insert(Logs, log_message)
			txtLogs = txtLogs .. log_message .. "\n"
			if #txtLogs >= 50000 then
				File_Writer("Error Screenshot/Logs", txtLogs)
				txtLogs = ""
			end
        end
    end

    if (Enable_Label) then
        if not Label_Region then
            local regionWidth = (screen and screen.x) or 720
            Label_Region = Region(0, 89, regionWidth, 40)
        end
        if Label_Region then
            if message then Label_Region:highlightUpdate(message)
            else Label_Region:highlightOff() end
        end
    end
end

function parseStringToTable(str)
    local result = {}
    for section in string.gmatch(str, '([^|]+)') do
        local mainKey, keyValues = string.match(section, '(%d+)%-"([^"]+)"')
        if mainKey and keyValues then
            result[mainKey] = {}  -- Keep keys as strings to match lookup

            for pair in string.gmatch(keyValues, '([^,]+)') do
                local key, value = string.match(pair, '([^=]+)=(.+)')  -- Capture values properly
                if key and value then
                    result[mainKey][key] = tonumber(value) or value  -- Convert numbers where possible
                end
            end
        end
    end
    return result
end



function tableToString(tbl)
    local parts = {}
    for mainKey, subTable in pairs(tbl) do
        local subParts = {}
        for key, value in pairs(subTable) do
            table.insert(subParts, key .. "=" .. value)
        end
        local subString = table.concat(subParts, ",")  -- Join sub-keys
        table.insert(parts, mainKey .. '-"' .. subString .. '"')
    end
    return table.concat(parts, "|")  -- Join main sections
end

function Reset_Daily_Events()
	Logger("Reset Daily Events Started")
	Current_Date = os.date("%Y-%m-%d")
	ResetAgnesClaim()
	Logger("Agnes intel claim tracker reset")
	if (Main.Experts.enlistEnabled) then
		Enlistment_Claim_Date = "NA"
		preferencePutString("expertsEnlistmentDate", "NA")
		scheduleEnlistmentClaim(" (after reset)")
	end
	if (Pet_Adventure) then
		Logger("Refreshing Pet Adventure")
		Main.Pet_Adventure.timer:set()
		Main.Pet_Adventure.treasure_spots, Main.Pet_Adventure.ally_treasure, Main.Pet_Adventure.cooldown = true, true, 0
		Logger("Treasure Spots: " ..tostring(Main.Pet_Adventure.treasure_spots))
		Logger("Ally Treasure: " ..tostring(Main.Pet_Adventure.ally_treasure))
		Logger("Pet Adventure Timer and Cooldown refreshed")
	end
	
	if (Enable_My_Island) then
		Logger("Refreshing Daybreak Island")
		Chief_Island_Claims = 3 
		Logger("Chief Island Claims: " ..Chief_Island_Claims)
	end
	
	if (Online_Rewards) then
		Logger("Refreshing Online Rewards")
		Main.Claim_Rewards.timer:set() 
		Main.Claim_Rewards.cooldown = 30
		Time_List = {31, 61, 91, 152, 302, 602, 1201, 1800, 2701, 3602, 4322, 6482, 7201}
		Logger("Online Rewards Timer and Cooldown refreshed")
	end
	if (Recruit_Heroes) then 
		Logger("Refreshing Hero Recruitment")
		Main.Recruit_Heroes.timer:set()  
		Main.Recruit_Heroes.cooldown = 30
		Logger("Recruit Heroes Timer and Cooldown refreshed")
	end
	
	if (Auto_Nomadic_Merchant) then
		Logger("Refreshing Nomadic Merchant")
		Main.Nomadic_Merchant.timer:set()
		Main.Nomadic_Merchant.cooldown = 30
		Logger("Nomadic Merchant Timer and Cooldown refreshed")
	end
	
	if (Auto_Triumph) then Main.Triumph.status = true end
	
	Main.Attack.counter = 0
	preferencePutNumber("attackLimitCounter", 0)
	
	preferencePutString("AM_StrPreference", '1-"task=NA,time=120,count=0,expiresAt=0"|2-"task=NA,time=120,count=0,expiresAt=0"')
	
	if (table.getn(Main.Events.List) > 0) then eventsChecker() end
	
	if (Enable_Bear_Event) and (Bear_Now_later == "byTask") then Check_Bear_Day2() end
	
	Logger("Refreshing Main Timer")
	Main.Reset.timer:set() 
	Main.Reset.cooldown = Get_Time_Difference()
	Main.Reset.cooldownBeforeReset = Main.Reset.cooldown - 60
	Main.Reset.status = true
	Logger("Main Timer and Cooldown refreshed")
	Logger("Reset Daily Events Completed")
end

function Misc_GUI()
	addTextView("     Gems/Second Ratio")
	addEditNumber("Gems_Time_Ratio", 4.51)
	newRow()
	addTextView("  Max Troop Rally")
	addEditNumber("Troop_Rally_Max", 100000)
	addTextView("  *")
end

function getCurrentFunctionName()
    local info = debug.getinfo(2, "n")  -- Get info about the caller of this function
    if info and info.name then
        return info.name  -- Return the name of the calling function
    else
        return nil  -- Unable to determine function name
    end
end


local filtered_range = {
    start_r = 135, end_r = 225,
    start_g = 60, end_g = 110,
    start_b = 90, end_b = 160
}

local function isInFilteredRange(r, g, b)
    return (r >= filtered_range.start_r and r <= filtered_range.end_r
        and g >= filtered_range.start_g and g <= filtered_range.end_g
        and b >= filtered_range.start_b and b <= filtered_range.end_b)
end


function copyList(original)
    local newList = {}
    for i, v in ipairs(original) do
        newList[i] = v
    end
    return newList
end

function invertList(list)
    local invertedList = {}
    for i = #list, 1, -1 do
        table.insert(invertedList, list[i])
    end
    return invertedList
end

function File_Writer2(filename, msg)
	local file = io.open(string.format("%simage/%s.txt", scriptPath(), filename), "a")
	if file then
		file:write(msg.. "\n")
		file:close()
	else print("Error: Unable to open the file.")
	end
	Error_Msg = ""
end

function File_Writer(filename, msg)
	if (#msg > 1) then
		local file
		local file_path = string.format("%simage/%s.txt", scriptPath(), filename)
		if (filename == "Error Screenshot/Logs") then file = io.open(file_path, "a")
		else file = io.open(file_path, "a") end

		if not file then
			file = io.open(file_path, "w")
			if not file then
				return
			end
		end
		file:write(msg)
		file:close()
	end
    Error_Msg = ""
end

function textToBase64(text)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  -- Encode the text to base64
  local data = text
  return ((data:gsub('.', function(x)
    local r, b = '', x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2^i - b % 2^(i - 1) > 0 and '1' or '0')
    end
    return r
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == '1' and 2^(6 - i) or 0)
    end
    return b:sub(c + 1, c + 1)
  end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

function base64ToText(base64)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local data = base64:gsub('[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if (x == '=') then return '' end
    local r, f = '', b:find(x) - 1
    for i = 6, 1, -1 do r = r..(f % 2^i - f % 2^(i - 1) > 0 and '1' or '0') end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then return '' end
    local c = 0
    for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0) end
    return string.char(c)
  end))
end

function imageToBase64(path)
  local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local f = assert(io.open(path, "rb"))
  local data = f:read("*all")
  return ((data:gsub('.', function(x) 
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

function jsonify(tbl)
  local function escape_str(s)
    s = string.gsub(s, '[\\"/]', '\\%1')
    s = string.gsub(s, '\n', '\\n')
    return s
  end

  local function serialize(val)
    if typeOf(val) == 'table' then
      local res = {}
      for k, v in pairs(val) do
        local key = typeOf(k) == 'number' and '[' .. k .. ']' or '["' .. escape_str(k) .. '"]'
        table.insert(res, key .. '=' .. serialize(v))
      end
      return '{' .. table.concat(res, ',') .. '}'
    elseif typeOf(val) == 'string' then
      return '"' .. escape_str(val) .. '"'
    else
      return tostring(val)
    end
  end

  return serialize(tbl)
end

function processOCR(ocrNumber)
    local year, month, day = string.sub(ocrNumber, 1, 4), string.sub(ocrNumber, 5, 6), string.sub(ocrNumber, 7, 8)
    local hour, minute = string.sub(ocrNumber, 9, 10), string.sub(ocrNumber, 11, 12)
    local date = string.format("%s-%s-%s", year, month, day)
    local time = string.format("%s:%s", hour, minute)
    return {d=date, t=time}
end

function timeToSeconds(timeString)
    local hour, minute, second = timeString:match("^(%d%d):(%d%d):(%d%d)$")
    if hour and minute and second then
        hour, minute, second = tonumber(hour), tonumber(minute), tonumber(second)
        return hour * 3600 + minute * 60 + second
    end
    return nil -- Return nil if input format is invalid
end

function isValidTime(timeString)
    local hour, minute, second = timeString:match("^(%d%d):(%d%d):(%d%d)$")
    if hour and minute and second then
        hour, minute, second = tonumber(hour), tonumber(minute), tonumber(second)
        if hour >= 0 and hour < 24 and minute >= 0 and minute < 60 and second >= 0 and second < 60 then
            return true
        end
    end 
    return false
end

local function getUTCOffset()
    local now = os.time()
    local localTime = os.date("*t", now)
    local utcTime = os.date("!*t", now)
    local offset = (localTime.hour - utcTime.hour) + (localTime.min - utcTime.min) / 60
    if localTime.day > utcTime.day then offset = offset + 24
    elseif localTime.day < utcTime.day then offset = offset - 24 end
    return offset
end

local Dawn_Academy_UTC_TIMES = {
	{hour = 8, min = 1, sec = 0},
	{hour = 16, min = 1, sec = 0},
}

local function secondsUntilNextUTCEvent(timeList, now)
	now = now or os.time()
	local utcNow = os.date("!*t", now)
	local currentSeconds = (utcNow.hour * 3600) + (utcNow.min * 60) + utcNow.sec
	local secondsInDay = 86400
	local nextDelta = secondsInDay

	for _, t in ipairs(timeList) do
		local targetSeconds = (t.hour * 3600) + (t.min * 60) + (t.sec or 0)
		local delta = targetSeconds - currentSeconds
		if (delta < 0) then delta = delta + secondsInDay end
		if (delta < nextDelta) then nextDelta = delta end
	end

	return nextDelta
end

local function secondsSinceMostRecentUTCEvent(timeList, now)
	now = now or os.time()
	local utcNow = os.date("!*t", now)
	local currentSeconds = (utcNow.hour * 3600) + (utcNow.min * 60) + utcNow.sec
	local secondsInDay = 86400
	local lastDelta = secondsInDay

	for _, t in ipairs(timeList) do
		local targetSeconds = (t.hour * 3600) + (t.min * 60) + (t.sec or 0)
		local delta = currentSeconds - targetSeconds
		if (delta < 0) then delta = delta + secondsInDay end
		if (delta < lastDelta) then lastDelta = delta end
	end

	return lastDelta
end

function getNextDawnAcademyCooldown(now)
	return secondsUntilNextUTCEvent(Dawn_Academy_UTC_TIMES, now)
end

function getLastDawnAcademyEventTimestamp(now)
	now = now or os.time()
	local sinceLast = secondsSinceMostRecentUTCEvent(Dawn_Academy_UTC_TIMES, now)
	return now - sinceLast
end

shouldTriggerImmediateDawnAcademy = function(now)
	local lastClaim = getDawnAcademyLastClaim()
	if not lastClaim then
		return true
	end
	local lastEvent = getLastDawnAcademyEventTimestamp(now)
	return lastClaim < lastEvent
end

function formatUTCRelative(secondsFromNow, reference)
	reference = reference or os.time()
	return os.date("!%Y-%m-%d %H:%M:%S", reference + secondsFromNow)
end

function subtractHoursFromTime(timeStr, hoursToSubtract)
	if #timeStr == 5 then
        timeStr = timeStr .. ":00"
    end
    local hour, min, sec = timeStr:match("(%d+):(%d+):(%d+)")
    hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)
    hour = hour - hoursToSubtract
    if hour < 0 then hour = (hour % 24 + 24) % 24  end
    local newTimeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    return newTimeStr
end

function subtractSecondsFromTime(timeStr, secondsToSubtract)
    local hour, min, sec = timeStr:match("(%d+):(%d+):(%d+)")
    hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)
    local totalSeconds = hour * 3600 + min * 60 + sec
    totalSeconds = totalSeconds - secondsToSubtract
    if totalSeconds < 0 then totalSeconds = (totalSeconds % 86400 + 86400) % 86400 end
    hour, min, sec = math.floor(totalSeconds / 3600), math.floor((totalSeconds % 3600) / 60), totalSeconds % 60
    local newTimeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    return newTimeStr
end

function Get_Time(seconds)
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local seconds = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function Get_Time2(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local seconds = seconds % 60
    return string.format("%dd %02d:%02d:%02d", days, hours, minutes, seconds)
end

function Get_Time_Difference(time1, time2)
	time1 = time1 or os.date("%H:%M:%S")
	time2 = time2 or Reset_Time
	
	if time1 and not time1:match("%d+:%d+:%d+") then time1 = time1 .. ":00" end
    if time2 and not time2:match("%d+:%d+:%d+") then time2 = time2 .. ":00" end
	
	local time1_hour, time1_min, time1_sec = time1:match("(%d+):(%d+):(%d+)")
	local time2_hour, time2_min, time2_sec = time2:match("(%d+):(%d+):(%d+)")
	time2_hour, time2_min, time2_sec = tonumber(time2_hour), tonumber(time2_min), tonumber(time2_sec)
	time1_hour, time1_min, time1_sec = tonumber(time1_hour), tonumber(time1_min), tonumber(time1_sec)
	
	local time1_total_Seconds = time1_hour * 3600 + time1_min * 60 + time1_sec
	local time2_total_Seconds = time2_hour * 3600 + time2_min * 60 + time2_sec
	
	local time_difference_seconds = time2_total_Seconds - time1_total_Seconds
	if time1_total_Seconds > time2_total_Seconds then
		time_difference_seconds = (24 * 3600) - (time1_total_Seconds - time2_total_Seconds)
	end
	
	return time_difference_seconds
end

function timestr_To_Seconds(time_str)
    local hours, minutes, seconds = time_str:match("(%d+):(%d+):(%d+)")
    local total_seconds = tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
    return total_seconds
end

function Convert_To_Seconds(number)
	local numbers = {}
	local number_string = tostring(number)
	local groups, remaining_time = {}, 0
	for i = 1, string.len(number_string) do
	  local digit = string.sub(number_string, i, i)
	  table.insert(numbers, tonumber(digit))
	end
	for i = #numbers, 1, -2 do
	  local first_number = numbers[i]
	  local second_number = numbers[i-1] or nil

	  local group_string = tostring(first_number)
	  if second_number then
		group_string = second_number .. group_string
	  end

	  table.insert(groups, group_string)
	end
	for i, v in ipairs(groups) do 
		if (i == 1) then remaining_time = remaining_time + v
		elseif (i == 2) then remaining_time = remaining_time + (v * 60)
		elseif (i == 3) then remaining_time = remaining_time + (v * 60 * 60) end
	end
	return remaining_time
end

function Reset_Remaining_Time()
	local currentTime = os.time()
	local currentDateTime = os.date("*t", currentTime)
	local nextThreeAMDateTime = {
		year = currentDateTime.year,
		month = currentDateTime.month,
		day = currentDateTime.day,
		hour = 3,
		min = 0,
		sec = 0
	}
	if currentDateTime.hour >= 3 then
		nextThreeAMDateTime.day = nextThreeAMDateTime.day + 1
	end
	local nextThreeAMTime = os.time(nextThreeAMDateTime)
	local timeDifferenceSeconds = nextThreeAMTime - currentTime	
	--print(Get_Time(timeDifferenceSeconds))
	return timeDifferenceSeconds
end

function has46HoursPassed(lastRun)
	if (lastRun == "NA") then return false end
    local lastRunTime = os.time({
        year = tonumber(lastRun:sub(1, 4)),
        month = tonumber(lastRun:sub(6, 7)),
        day = tonumber(lastRun:sub(9, 10)),
        hour = tonumber(lastRun:sub(12, 13)),
        min = tonumber(lastRun:sub(15, 16)),
        sec = tonumber(lastRun:sub(18, 19))
    })
    return os.difftime(os.time(), lastRunTime) >= 46 * 3600
end

function PixelX(XY_Pixel)
	Screen_Size, Script_Size = screen.x, 720
	if (Screen_Size == Script_Size) then
		return XY_Pixel
	else
		if (Script_Size > Screen_Size) then --720 is bigger than current screen
			New_Size = 720 / (Script_Size - Screen_Size)
			return XY_Pixel - New_Size
		elseif (Script_Size < Screen_Size) then --720 is lower than current screen
			New_Size = 720 * (Screen_Size / Script_Size)
			return XY_Pixel + New_Size
		end
	end
end

function PixelY(XY_Pixel)
	Screen_Size, Script_Size = screen.y, 1520
	if (Screen_Size == Script_Size) then
		return XY_Pixel
	else
		if (Script_Size > Screen_Size) then --1520 is bigger than current screen
			New_Size = (Script_Size - Screen_Size) / 40
			return XY_Pixel - New_Size
		elseif (Script_Size < Screen_Size) then --1520 is lower than current screen
			New_Size = (Screen_Size - Script_Size) / 40
			return XY_Pixel + New_Size
		end
	end
end

function isInRegion(ROI, px, py)
    return px >= ROI:getX() and px <= (ROI:getX() + ROI:getW() - 1)
           and py >= ROI:getY() and py <= (ROI:getY() + ROI:getH() - 1)
end

function isYWithinRegionY(ROI, py)
    return py >= ROI:getY() and py <= (ROI:getY() + ROI:getH() - 1)
end

function isYWithinRegionYButNotX(ROI1, ROI2)
    local py = ROI2:getY()  -- Get the y-coordinate of ROI2 (point)
    local px = ROI2:getX()  -- Get the x-coordinate of ROI2 (point)

    local withinYBounds = py >= ROI1:getY() and py <= (ROI1:getY() + ROI1:getH() - 1)
    local withinXBounds = px >= ROI1:getX() and px <= (ROI1:getX() + ROI1:getW() - 1)
    
    return withinYBounds and not withinXBounds
end

function isTable(t)
    return typeOf(t) == "table"
end

function isColorWithinThreshold(r, g, b, targetR, targetG, targetB, threshold)
    local diffR, diffG, diffB = math.abs(r - targetR), math.abs(g - targetG), math.abs(b - targetB)
    if diffR <= threshold and diffG <= threshold and diffB <= threshold then return true end
	return false
end

function rgbToHex(location)
    local r, g, b = getColor(location)
    return string.format("#%02X%02X%02X", r, g, b)
end

function multiHexColorFind(loc, hexList, threshold)
	if not(typeOf(hexList) == "table") then hexList = {hexList} end
	while true do
		for i, hex in ipairs(hexList) do
			if (isColorWithinThresholdHex(loc, hex, threshold)) then return hex end
		end
	end
end

function isColorWithinThresholdHex(loc, hexList, threshold)
	local r, g, b = getColor(loc)
	if not(typeOf(hexList) == "table") then hexList = { hexList } end
	for _, hex in ipairs(hexList) do
		hex = hex:gsub("#", "")
		local targetR, targetG, targetB = tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
		local diffR, diffG, diffB = math.abs(r - targetR), math.abs(g - targetG), math.abs(b - targetB)
		if diffR <= threshold and diffG <= threshold and diffB <= threshold then return true end
	end
	return false
end

function waitHexColorExist(loc, hexList, threshold)
	if not(typeOf(hexList) == "table") then hexList = { hexList } end
	threshold = threshold or 10
    while true do
        for _, hex in ipairs(hexList) do
            if isColorWithinThresholdHex(loc, hex, threshold) then return hex end
        end
        wait(50)
    end
end

function colorExists(obj, time)
    time = time or 1
    local timer = Timer()
    local r, g, b
    obj.diff = obj.diff or { 0, 0, 0 }

    if not obj.color or not obj.location or not isTable(obj.color) or not isTable(obj.diff) then
        print(obj)
        scriptExit("colorExists: Obj bad format")
    end

    while true do
        r, g, b = getColor(obj.location)

        if math.abs(obj.color[1] - r) <= obj.diff[1] then
            if math.abs(obj.color[2] - g) <= obj.diff[2] then
                if math.abs(obj.color[3] - b) <= obj.diff[3] then
                    return true
                end
            end
        end
        --
        r, g, b = nil, nil, nil

        if timer:check() >= time then
            break
        end
    end
    return false
end

function colorExistsClick(obj, time)
    if colorExists(obj, time) then
        click(obj.location)
        return true
    end
    return false
end

function findPixelTarget(reg,range_x, range_y)
    local white = {
        location = Location(0, 0), 
        color = { 255, 255, 255 }, -- { r, g, b }
        diff = { 10, 10, 10 }, --diff is like a threshold, rgb can be 10 above or below. 0,0,0 would be exact match
    } 
    local reg = reg or Region(0,0,0,0) --set this to desired region to check, or send it with function as variable

    range_x = range_x or 1
    range_y = range_y or 1
    snapshotColor()  --takes a single screenshot to check all pixels quickly, depends on how big the region is, smaller is faster
    test_Timer2 = Timer()

    for x = reg.x, reg.w, range_x do
        for y = reg.y, reg.y + reg.h, range_y do
            white.location = Location(x, y) --set location to current pixel
            local r, g, b = getColor(white.location)
            if not colorExists(white, 0) then --if the pixel is not white
                usePreviousSnap(false) --were done using single snapshot, now set to false to continue normal
                return Location(x, y)
            end
        end
    end
end

function scandirNew(scan_dir)
    --local temp, lines = scriptPath().. "image/TxtFiles/", {}
    local temp, lines = "/sdcard/__temp/", {}
	scan_dir = scriptPath().. "image/" ..scan_dir
    local list_file = temp .. "_scandir_"
    local create_list_file = 'ls "' .. scan_dir .. '" > ' .. list_file
    if not mkdir(temp) then return {}, "_mkdir_" end
    if _execute(create_list_file) ~= 0 then return {}, "_list_" end
    for line in _io.lines(list_file) do
        --lines[#lines + 1] = line
		table.insert(lines, line)
    end
    return lines
end

function Capture_Screenshot()
	Message.Total_Screenshot = Message.Total_Screenshot + 1
	usePreviousSnap(false)
	local error_directory = "Error Screenshot/"
	local error_images = scandirNew(error_directory)
	local error_ROI = Region(0, 0, screen.x, screen.y)
	local Cur_Function = Current_Function:gsub('[<>:"/\\|?*%c]', "-")
	local filename = string.format("%sError - %s %s.png", error_directory, Cur_Function, (table.getn(error_images) + 1))
	error_ROI:saveColor(filename)
	--print("Screenshot taken: image/Error Screenshot/")
	--print(filename)
end

function find_in_list(list, str)
	local status = false
	for i, curList in ipairs(list) do if (curList == str) then status = true end end
	return status
end

function removeStringFromTable(tbl, str)
    for i = #tbl, 1, -1 do
        if tbl[i] == str then
            table.remove(tbl, i)
            break
        end
    end
end

function isWordInString(str, word)
	if not(str) then return false end
	if not(word) then return false end
    local lowerStr = string.lower(str)
    local lowerWord = string.lower(word)
    local _, endIndex = string.find(lowerStr, "%f[%a]" .. lowerWord .. "%f[%A]")
    if endIndex then return true
    else return false end
end

	
function OCR_Res_Checker(ocr_res, path)
	local file_result, ResResult = {}, nil
	path = scriptPath().. "Image/TxtFiles/" ..path
	for line in io.lines(path) do table.insert(file_result, line) end
	for i, v in ipairs(file_result) do
		if string.match(v, ocr_res) then
			ResResult = Split(v, ",")[2]
			break
		end
	end
	return ResResult
end

function TargetOffset(xy, x, y)
	return string.format("%s,%s", xy:getX() + x, xy:getY() + y)
end

function contains_number(large_number, small_number)
    if string.find(tostring(large_number), tostring(small_number)) then return true
    else return false end
end

function Add_Subtract_Time(Time, value, Return_Type)
	local total_seconds = Convert_To_Seconds(Time)
	total_seconds = total_seconds + value
	local new_hours = math.floor(total_seconds / 3600) % 24
	local new_minutes = math.floor((total_seconds % 3600) / 60)
	local new_seconds = total_seconds % 60
	local adjusted_time = string.format("%02d:%02d:%02d", new_hours, new_minutes, new_seconds)
	return {s = total_seconds, t = adjusted_time}
end

-- === Flags Discovery (auto) ===============================================
-- Scans Flags/ for files named Flag<number>.png and records on-screen coords.
-- Populates global flags_coordinates[i] = { f=cur_flag, t=0, ft=0 }
-- Options:
--   opts = {
--     dir = "Flags",           -- image folder
--     prefix = "Flag",         -- filename prefix
--     ext = ".png",            -- extension
--     region = Upper_Half,     -- search ROI
--     conf = 0.90,             -- confidence
--     retries = 1,             -- attempts per flag
--     retry_wait = 0.15,       -- seconds between retries
--     log_each = true          -- per-flag logs
--   }
--
-- Dependencies: Logger, SearchImageNew, scandirNew, wait, Timer (already present in your script)

function Discover_Flags_Coordinates(opts)
    opts = opts or {}
    local dir        = opts.dir        or "Flags"
    local prefix     = opts.prefix     or "Flag"
    local ext        = opts.ext        or ".png"
    local region     = opts.region     or Upper_Half
    local conf       = opts.conf       or 0.85
    local retries    = opts.retries    or 1
    local retry_wait = opts.retry_wait or 0.15
    local log_each   = (opts.log_each ~= false)

    -- discover candidate files -> numeric indices
    local indices = {}
    local files = scandirNew(dir)
    for _, f in ipairs(files) do
        local n = string.match(f, "^" .. prefix .. "(%d+)" .. ext:gsub("%.", "%%.") .. "$")
        if n then table.insert(indices, tonumber(n)) end
    end
    table.sort(indices)
    if #indices == 0 then
        Logger(string.format("No %s%s%s found in '%s'", prefix, "<n>", ext, dir))
        return 0, flags_coordinates
    end

    -- ensure table exists and clear stale entries for discovered indices only
    if flags_coordinates == nil then flags_coordinates = {} end
    for _, i in ipairs(indices) do flags_coordinates[i] = nil end

    local t0 = os.clock()
    local found = 0
    Logger(string.format("Flags: scanning %d candidates @ conf=%.2f in %s", #indices, conf, tostring(region)))

    for _, i in ipairs(indices) do
        local path = string.format("%s/%s%d%s", dir, prefix, i, ext)
        local hit = nil
        for attempt = 1, math.max(1, retries) do
            hit = SearchImageNew(path, region, conf, true)
            if hit and hit.name then break end
            if attempt < retries then wait(retry_wait) end
        end

        if hit and hit.name then
            flags_coordinates[i] = { f = hit, t = 0, ft = 0 }  -- keep your schema
            found = found + 1
            if log_each then
                Logger(string.format("[✓] Flag %d @ (%d,%d) -> %s", i, hit.xy.x, hit.xy.y, path))
            end
        else
            if log_each then
                Logger(string.format("[ ] Flag %d not found -> %s", i, path))
            end
        end
    end

    local ms = (os.clock() - t0) * 1000
    Logger(string.format("Flags discovery complete: %d/%d found in %.1f ms", found, #indices, ms))
    return found, flags_coordinates
end

-- Optional: a tiny GUI to run discovery with knobs (match your dialog style)
function Flags_Discovery_GUI()
    dialogInit()
    addTextView("Flags Discovery")
    newRow()
    addTextView("Confidence")
    addEditNumber("flagsConf", 90)        -- percent
    addTextView("Retries")
    addEditNumber("flagsRetries", 1)
    newRow()
    addCheckBox("flagsLogEach", "Verbose per-flag logs", true)
    dialogShowFullScreen("Flags")

    local conf = (tonumber(flagsConf) or 90) / 100
    local retries = tonumber(flagsRetries) or 1
    Discover_Flags_Coordinates({
        conf = conf,
        retries = retries,
        log_each = flagsLogEach
    })
end



function get_file_name(file)
      local file_name = file:match("[^/]*.png$")
      return file_name:sub(0, #file_name - 4)
end


function SearchImage(target, boxRegion, maxScore, Color)
	if not(maxScore) then maxScore = 0.9 end
	local TImage = target
	if not (typeOf(target) == "table") then TImage = {target} end
    local maxIndex, found, XY, X, Y, Fname = 0, false
    for i, t in ipairs(TImage) do
		if (Color) then
			if (boxRegion) then CurScore = boxRegion:exists(Pattern(t):color(), 0)
			else CurScore = exists(Pattern(t):color(), 0) end
		else
			if (boxRegion) then CurScore = boxRegion:exists(Pattern(t), 0)
			else CurScore = exists(Pattern(t), 0) end
		end
		if (CurScore) then
			local score = CurScore:getScore()
			--print(score)
			if (score > maxScore) then
				maxScore = score
				maxIndex = i
				X = CurScore:getCenter():getX()
				Y = CurScore:getCenter():getY()
				XY = CurScore:getCenter():getX()..","..CurScore:getCenter():getY()
				Fname = get_file_name(TImage[i])
				--print(Fname)
			end		
		end			
    end
    if (maxScore == 0.9) then return nil end
	local result = {x = X, y = Y, xy = XY, name = Fname}
    return XY, Fname
end

function SingleImageWait(target, waitTime, boxRegion, Similarity, Color, Mask)
	local PatternBuilder, Cur_Image = Pattern(target)
	PatternBuilder = PatternBuilder:similar(Similarity or 0.9)
	if (Color) then PatternBuilder = PatternBuilder:color() end
	if (Mask) then PatternBuilder = PatternBuilder:mask() end
	boxRegion = boxRegion or Region(0, 0, screen.x, screen.y)
	return boxRegion:exists(PatternBuilder, waitTime or 0)
end

function SearchImageNew(target, boxRegion, maxScore, Color, Mask, Time)
        if (target.target) then boxRegion, maxScore, Color, Mask, Time, target = target.region, target.score, target.color, target.mask, target.ttime, target.target end
        Time, Color, Mask, maxScore = Time or 0, Color or false, Mask or false, maxScore or 0.9
        local TImage = target
        if not (typeOf(target) == "table") then TImage = {target} end
        local result = {x = nil, y = nil, xy = nil, name = nil, score=maxScore}
	local Search_Timer = Timer()
	repeat
		for i, t in ipairs(TImage) do
			local PatternBuilder, Cur_Image, Cur_Score = Pattern(t)
			if (Color) then PatternBuilder = PatternBuilder:color() end
			if (Mask) then PatternBuilder = PatternBuilder:mask() end
			if (boxRegion) then Cur_Image = boxRegion:exists(PatternBuilder, 0)
			else Cur_Image = exists(PatternBuilder, 0) end
			if (Cur_Image) then
				local Cur_Score, X, Y, XY, Fname = Cur_Image:getScore()
				if (Cur_Score > maxScore) then
					local X, W, Y, H, XY, SX, SY = Cur_Image:getCenter():getX(), Cur_Image:getW(), Cur_Image:getCenter():getY(), Cur_Image:getH(), Cur_Image:getCenter(), Cur_Image:getX(), Cur_Image:getY()
					local R = Region(X - (W / 2), Y - (H / 2), W, H)
					maxScore = Cur_Score
					result = {x = X, y = Y, xy = XY, name = get_file_name(TImage[i]), score=maxScore, w = W, h = H, r = R, sx = SX, sy = SY, loc=Location(X,Y)}
				end
			else
				Cur_Image = nil
			end			
		end
	until(result.name) or (Search_Timer:check() > Time)
	Search_Timer = nil
	target, boxRegion, maxScore, Color, Mask, Time = nil, nil, nil, nil, nil, nil
    return result
end

function tapSearchResult(result, clickType)
        if not result then return false end
        local target = result.xy or result.loc
        if target then
                Press(target, clickType)
                return true
        end
        return false
end

function ClickImg(image, region, score, color, mask, waitTime)
        score = score or 0.9
        local searchResult = SearchImageNew(image, region, score, color, mask, waitTime)
        if (searchResult and searchResult.xy) then
                Press(searchResult.xy, 1)
		return true, searchResult
	end
	return false, searchResult
end

function WaitExists(image, timeout, region, score, color, mask)
	timeout = timeout or 0
	score = score or 0.9
	local timer = Timer()
	repeat
		local result = SearchImageNew(image, region, score, color, mask, 0)
		if (result and result.name) then
			return true, result
		end
		wait(0.2)
	until(timer:check() >= timeout)
	return false
end

function testClick()
	action, locTable, touchTable = getTouchEvent()
	print (action)
	if (action == "click" or action == "longClick") then
		print (locTable)
		local r, g, b = getColor(locTable)
		local hex = string.format("#%02X%02X%02X", r, g, b)
		print(getColor(locTable))
		print(hex)
	end
end

function SearchImage_Test(img, ROI, score, color, mask, t, press)
	test = SearchImageNew(img, ROI, score, color, mask, t)
	if (test.name) then 
		test.r:highlight(1) 
		if (press) then Press(test.xy, 1) end
	end
	print(test.name)
	print(test.score)
end

function Split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function PressOld(Click, Stats)
	local status, X, Y = ""
	if typeOf(Click) == "userdata" then
		if (Stats == 1) then click(Click)
		else doubleClick(Click) end
	else
		if (string.find(Click, ",")) then status = Click
		else status = SearchImage(Click) end
		if (status) then
			X = tonumber(Split(status, ",")[1])
			Y = tonumber(Split(status, ",")[2])
			if (Stats == 1) then click(Location(X, Y))
			else doubleClick(Location(X, Y)) end
		end
	end	
end

function checkObjType(obj)
	if (obj:getX()) and (obj:getY()) and (obj:getW()) then return true
	else return false end
end

function ranCoords(obj, threshold)
	threshold = threshold or 2
	local success, result = pcall(checkObjType, obj)
	local x,y
	if (success) then x,y = obj:getCenter():getX(), obj:getCenter():getY()
	else x,y = obj:getX(), obj:getY() end

	local randomX, operationX = math.random(0, threshold), math.random(0, 1)
	if (operationX == 0) then x = x - randomX
    else x = x + randomX end
	
	local randomY
	repeat randomY = math.random(0, threshold) until not(randomX == randomY)
	
	local operationY = math.random(0, 1)
	if (operationY == 0) then y = y - randomY
    else y = y + randomY end
	return Location(x, y)	
end

function ranNumbers(num, threshold)
	threshold = threshold or 2
	local randomX, operationX = math.random(0, threshold), math.random(0, 1)
	if (operationX == 0) then num = num - randomX
    else num = num + randomX end
	return num
end

function Press(Click, clickType)
	clickType = clickType or 1
	local status, X, Y = ""
	if typeOf(Click) == "userdata" then
		if (clickType == 1) then click(ranCoords(Click))
		else doubleClick(ranCoords(Click)) end
	else
		if (string.find(Click, ",")) then status = Click
		else status = SearchImage(Click) end
		if (status) then
			X, Y = tonumber(Split(status, ",")[1]), tonumber(Split(status, ",")[2])
			if (clickType == 1) then click(ranCoords(Location(X, Y)))
			else doubleClick(ranCoords(Location(X, Y))) end
		end
	end	
end

local Folder = "Fight/"
local QuickBattleFolder = Folder.. "QuickBattle/"

function PressRepeat(From, To, Stats, Time, r1, r2, score, color1, color2)
	if not(Time) then Time = 0 end
	local Res, SIImage, Isearch, t
	if not(typeOf(To) == "table") then To = {To} end
	repeat
		if (typeOf(From) == "table") then 
			if (color1) then Isearch = SearchImage(From, r1, score, color1)
			else Isearch = SearchImage(From, r1, score) end
		elseif (typeOf(From) == "userdata") then
			Isearch = From
		else
			if (string.find(From,",")) then Isearch = From
			elseif (From == 4) then Isearch = From
			else
				if (color1) then Isearch = SearchImage(From, r1, score, color1)
				else Isearch = SearchImage(From, r1, score) end
			end
		end
		if (Isearch == 4) then keyevent(4)
		elseif (Isearch) then Press(Isearch, Stats)
		end
		t = Timer()
		if color2 then repeat Res, SIImage = SearchImage(To, r2, score, color2) until(Res) or (t:check() > Time)
		else repeat Res, SIImage = SearchImage(To, r2, score) until(Res) or (t:check() > Time) end		
	until(Res)
	return Res, SIImage
end

function swipeStopper(loc, iteration)
	for i = 1, iteration do
		wait(0.1)
		click(loc)
		wait(0.1)
		longClick(Location(17, 1404))
		wait(0.2)
		stopLongClick()
	end
end

function stuckReconOpen()
	setAlternativeClick(false)
	while true do
		local Alliance_Screen = SearchImageNew({"Alliance.png", "Reconnect.png"}, nil, 0.9, true)
		if (Alliance_Screen.name) and (Alliance_Screen.name == "Alliance") and (Alliance_Screen.y > 1400) then 
			Logger("Going to Home Screen and try to refresh game screen")
			while true do
				keyevent(3)
				if (SingleImageWait("Home Screen.png", 3, Home_Screen_Region, 0.9, true)) then break
				else wait(3) end
			end
			wait(2)
			Logger("Opening the Game again")
			while true do
				startApp("com.gof.global")
				if (SingleImageWait("Alliance.png", 3, Lower_Most_Half, 0.9, true)) then break
				else wait(3) end
			end
			Logger()
			error("Timeout Error: Failed to open the next screen by clicking the button.")
		elseif (Alliance_Screen.name) and (Alliance_Screen.name == "Reconnect") then --someone else logged in
			snapshotColor()
			local reconStatus = SearchImageNew({"Change Character/Connection Lost.png", "Change Character/Tips.png"}, nil, 0.9, true, false, 99999999) --Tips = Someone else logged in
			usePreviousSnap(false)
			if (reconStatus.name == "Tips") then
				error("Timeout Error: Someone has logged in on your account.")
			else
				while true do
					Press(reconStatus.xy, 1)
					if not(SingleImageWait("Change Character/Connection Lost.png", 1)) then break
					else wait(10) end
				end
				error("Timeout Error: Connection is unstable.")
			end
		else --stuck
			if (Check_Screen() == "Reopened") then --Homescreen Found. Game closed for unknown reason
				local Current_Pack, Task = copyList(Pack_Sale_List)
				Logger("Searching for Packs")
				local Image_result = SearchImageNew(Current_Pack, nil, 0.9, false)
				if (Image_result.name) and (string.match(Image_result.name, "Pack Sale")) then 
					Logger("Pack found and closing!!!!")
					BackToWorld()
				end
				error("Timeout Error: Game was Closed for Unknown Reason.")
			else
				keyevent(4)
				wait(.3)
			end
		end
	end
end

function PressRepeatNew(From, To, Stats, Time, r1, r2, score, color1, color2, mask1, mask2)
	if not(Time) then Time = 0 end
	local Res, Isearch, t
	--if not(typeOf(To) == "table") then To = {To} end
	local R_Timer_Total, R_Timer = nil, nil
	if (auto_restart) then R_Timer_Total, R_Timer = 30, Timer() end
	repeat
		if (typeOf(From) == "table") then Isearch = SearchImageNew(From, r1, score, color1, mask1).xy
		elseif (typeOf(From) == "userdata") then Isearch = From
		else		
			if (string.find(From,",")) then Isearch = From
			elseif (From == 4) then Isearch = From
			else Isearch = SearchImageNew(From, r1, score, color1, mask1).xy end
		end
		if (Isearch == 4) then keyevent(4)
		elseif (Isearch) then Press(Isearch, Stats) end
		Isearch = nil
		if (typeOf(To) == "table") then
			Res = SearchImageNew(To, r2, score, color2, mask2, Time)
		else
			local imgResult = SingleImageWait(To, Time, r2, score, color2, mask2)
			if (imgResult) then
				local X, W, Y, H, XY, SX, SY = imgResult:getCenter():getX(), imgResult:getW(), imgResult:getCenter():getY(), imgResult:getH(), imgResult:getCenter(), imgResult:getX(), imgResult:getY()
				Res = {x = X, y = Y, xy = XY, name = get_file_name(To), score=imgResult:getScore() , w = W, h = H, r = imgResult, sx = SX, sy = SY, loc=Location(X,Y)}
			else Res = {name = nil} end
		end
		----------go back to home screen if image is not found----------------
		if (auto_restart) and ((R_Timer:check() >= 15) and (R_Timer:check() < R_Timer_Total)) and not(Res.name) then setAlternativeClick(true) end
		if (auto_restart) and (R_Timer:check() >= R_Timer_Total) and not(Res.name) then
			local From_String, To_String = From, To
			if (typeOf(From) == "table") then From_String = table.concat(From, ", ") end
			if (typeOf(To) == "table") then To_String = table.concat(To, ", ") end
			Error_Msg = string.format("From: %s | To: %s", tostring(From_String), tostring(To_String))
			Capture_Screenshot()
			stuckReconOpen()
		end
	until(Res.name)
	setAlternativeClick(false)
	return Res
end

function PressRepeatHexColor(loc1, loc2, hexList, threshold, aTime)
	if not(typeOf(hexList) == "table") then hexList = {hexList} end
	local R_Timer_Total, R_Timer, hexResult = nil, nil
	if (auto_restart) then R_Timer_Total, R_Timer = 30, Timer() end
	repeat
		Press(loc1, 1)
		t = Timer()
		repeat
			for i, hex in ipairs(hexList) do
				if (isColorWithinThresholdHex(loc2, hex, threshold)) then hexResult = hex end
			end
		until(hexResult) or (t:check() >= aTime)
		
		if (auto_restart) and ((R_Timer:check() >= 15) and (R_Timer:check() < R_Timer_Total)) and not(hexResult) then setAlternativeClick(true) end
		if (auto_restart) and (R_Timer:check() >= R_Timer_Total) and not(hexResult) then
			local From_String, To_String = From, To
			if (typeOf(From) == "table") then From_String = table.concat(From, ", ") end
			if (typeOf(To) == "table") then To_String = table.concat(To, ", ") end
			Error_Msg = string.format("From: %s | To: %s", tostring(From_String), tostring(To_String))
			Capture_Screenshot()
			stuckReconOpen()
		end
	until(hexResult)
	setAlternativeClick(false)
end

function PressRepeatSingle(From, To, Stats, Time, r1, r2, score, color1, color2, mask1, mask2)
	if not(Time) then Time = 0 end
	local Res, Isearch
	local R_Timer_Total, R_Timer = nil, nil
	if (auto_restart) then R_Timer_Total, R_Timer = 20, Timer() end
	repeat
		if (typeOf(From) == "table") then Isearch = SearchImageNew(From, r1, score, color1, mask1).xy
		elseif (typeOf(From) == "userdata") then Isearch = From
		else
			if (string.find(From,",")) then Isearch = From
			elseif (From == 4) then Isearch = From
			else Isearch = SearchImageNew(From, r1, score, color1, mask1).xy end
		end
		if (Isearch == 4) then keyevent(4)
		elseif (Isearch) then Press(Isearch, Stats) end
		Isearch = nil
		Res = SingleImageWait(To, Time, r2, score, color2, mask2)
		----------go back to home screen if image is not found----------------
		if (auto_restart) and not(Res) and (R_Timer:check() >= R_Timer_Total) then
			local From_String, To_String = From, To
			if (typeOf(From) == "table") then From_String = table.concat(From, ", ") end
			if (typeOf(To) == "table") then To_String = table.concat(To, ", ") end
			Error_Msg = string.format("From: %s | To: %s", tostring(From_String), tostring(To_String))
			Capture_Screenshot()
			stuckReconOpen()
		end
	until(Res)
	local SX,SY,W,H,X,Y, XY = Res:getX(), Res:getY(), Res:getW(), Res:getH(), Res:getCenter():getX(), Res:getCenter():getY(), Res:getCenter()
	local result = {x = X, y = Y, xy = XY, name = get_file_name(To), score=Res:getScore(), w = W, h = H, r = Res, sx = SX, sy = SY, loc=Location(X,Y)}
	return result
end

function PressRepeatNot(From, To, Stats, Time, r1, r2, score)
	if not(Time) then Time = 0 end
	local Isearch, To_Image, t
	--if not(typeOf(To) == "table") then To = {To} end
	repeat
		if (typeOf(From) == "table") then
			Isearch = SearchImageNew(From, r1, score).xy
		elseif (typeOf(From) == "userdata") then
			Isearch = From
		else
			if (string.find(From, ",")) then Isearch = From
			elseif (From == 4) then Isearch = From
			else Isearch = SearchImageNew(From, r1, score).xy end
		end
		if (Isearch == 4) then keyevent(4)
		elseif (Isearch) then Press(Isearch, Stats) end
		t = Timer()
		repeat To_Image = SearchImageNew(To, r2, score) until not(To_Image.name) or (t:check() > Time)
	until not(To_Image.name)
end

function PressUntilNot(From, Stats)
	repeat
		Press(From, Stats)
		Stats = SearchImage({From})
	until not (Stats)
end

function tryOCR(ROI)
	local function getUniqueWithoutNumbers(list)
		local result, unique = {}, {}
		for _, item in ipairs(list) do
			local stripped = item:match("^[%a_]+")  -- Remove numbers from the string
			if stripped and not unique[stripped] then
				unique[stripped] = true
				table.insert(result, stripped)
			end
		end

		return result
	end

	local list = scandirNew("ocr")
	local uniqueList = getUniqueWithoutNumbers(list)
	snapshotColor()
	for _, v in ipairs(uniqueList) do
		local ocrResult, ocrStatus = numberOCRNoFindException(ROI, "ocr/"..v)
		if (ocrStatus) then print(string.format("OCR %s: %s", v, ocrResult)) end
	end
	usePreviousSnap(false)
end

function Num_OCR(ROI, img, Snap, Color, use_Previous)
	if Snap then
		if Color then snapshotColor()
		else snapshot() end
	end
	local Total_March, Number_Status
	local breakTimer = Timer()
	repeat Total_March, Number_Status = numberOCRNoFindException(ROI, "ocr/"..img) until ((Number_Status) and (Total_March >= 0)) or (breakTimer:check() > 20)
	if use_Previous then usePreviousSnap(false) end
	if (auto_restart) and (breakTimer:check() > 20) and not(Number_Status) then
		Error_Msg = string.format("Num_OCR Failed to recognize OCR")
		Capture_Screenshot()
		local Alliance_Screen
		repeat
			Alliance_Screen = SearchImageNew({"Alliance.png", "Reconnect.png"}, nil, 0.8, true)
			if not(Alliance_Screen.name) then
				if (SearchImageNew("Home Screen.png", Home_Screen_Region, 0.9, true).name) then 
					startApp("com.gof.global")
					SingleImageWait("Alliance.png", 15)
				else
					keyevent(4)
					wait(.3)
				end
			end
		until(Alliance_Screen.name)
		Logger()
		error("Timeout Error: Failed to open the next screen by clicking the button.")
		--SearchImageNew("DONOTMINDME.png")
	end
	return Total_March
end

function Char_OCR(ROI, charTable)
	local charTimer, charResult, charStatus = Timer()
	repeat charResult, charStatus = charOCRNoFindException(ROI, charTable) until(charStatus) or (charTimer:check() > 5)
	if not(charStatus) then charResult = "0/0" end
	return charResult
end

function charTimeOCR(ROI, charTable)
	local charTimer, charResult, charStatus = Timer()
	repeat charResult, charStatus = charOCRNoFindException(ROI, charTable) until(charStatus) or (charTimer:check() > 5)
	if not(charStatus) then return false end
	return charResult
end

function GetColor(X,Y)
	local loc = Location(X,Y)
	local r, g, b = getColor(loc)
	return(r.. "," ..g.. "," ..b)
end

function Go_Back2(msg)
	usePreviousSnap(false)
	Logger(msg and msg or "Going back to Main Screen")
	local Back_Screen = PressRepeatNew(4, {"World.png", "City.png"}, 1, 1, nil, Lower_Right, 0.9)
	Logger("Go Back Screen Found " .. Back_Screen.name)
	if (Back_Screen.name == "World") then PressRepeatNew(Back_Screen.xy, "City.png", 1, 4, nil, Lower_Right, 0.9) end
	Logger("Go Back Screen Completed")
	return true
end

function DONOTMINDME_Fn()
	Capture_Screenshot()
	Logger()
	--stuckReconOpen()
	error("Timeout Error: Failed to open the next screen by clicking the button.")
end

function Go_Back(msg)
	local goBackTimer = Timer()
	usePreviousSnap(false)
	Logger(msg and msg or "Going back to Main Screen")
	goBackTimer:set()
	while not(Lower_Most_Half:exists(Pattern("Alliance Icon.png"):similar(0.90):color(), 0)) do
		keyevent(4)
		wait(.5)
		if (goBackTimer:check() > 20) then DONOTMINDME_Fn() end
	end
	Logger("Checking if City Image is Found")
	goBackTimer:set()
	while not(Lower_Most_Half:exists(Pattern("City.png"):similar(0.90), 0)) do
		Logger("City Image Found and clicking!")
		local World_Image = Lower_Most_Half:exists(Pattern("World.png"):similar(0.90), 0)
		if (World_Image) then click(World_Image) end
		wait(1)
		if (goBackTimer:check() > 20) then DONOTMINDME_Fn() end
	end
	Logger("Go Back Screen Completed")
	wait(1)
	return true
end

function parseDateTime(dateTime)
    local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTime:match(pattern)
    return {
        year = year, month = month, day = day,
        hour = hour, min = min, sec = sec
    }
end

function Side_Check_Opener()
	local Side_Opened = SingleImageWait("Side Closed.png", 2, Region(0, 610, 40, 118), 0.9, true)
	if not(Side_Opened) then
		Logger("Side button not found sleeping for 5 Minutes")
		return false
	end
	Logger("Opening Side Button")
	PressRepeatNew(Side_Opened, "Side Opened.png", 1, 2, nil, Region(screen.x/2, 610, 160, 118), 0.9, nil, true)
	return true
end

function Check_Bear_Day2()
	Logger("Check Bear Day 2")
	Main.Bear_Event.initialCheck = false
	local bearStatus = bearCalendarChecker(mainBearTrap) -- when bot starts initially to setup timer
	if (bearStatus.status) then
		Main.Bear_Event.cooldown, Main.Bear_Event.status, Main.Bear_Event.bearStartTime = Get_Time_Difference(nil, Get_Time(bearStatus.seconds)), true, bearStatus.seconds
		if not(Main.Bear_Event.timer) then Main.Bear_Event.timer = Timer() end
		Main.Bear_Event.timer:set()
	else Main.Bear_Event.status = false end
end

function Check_altBear_Day2()
	local bearStatus = bearCalendarChecker(altBearTrap) -- when bot starts initially to setup timer
	if (bearStatus.status) then
		Main.Barney.bear_cooldown, Main.Barney.status = Get_Time_Difference(nil, Get_Time(bearStatus.seconds)) - 300, true
		preferencePutString("altBearStart", Get_Time(bearStatus.seconds))
		preferencePutString("altPrepStart", Get_Time(bearStatus.seconds - 300))
		Main.Barney.bear_timer:set()
	else 
		Main.Barney.status = false
		Main.Barney.bear_timer, Main.Barney.bear_cooldown = Timer(), 86400
	end
end

function Check_Bear_Day(ATB)
	Current_Function = getCurrentFunctionName()
	function event_day(ATB)
		local remainingTime, eventDate
		snapshotColor()
		Logger("Searching for Cooldown/Pre-Registration")
		local bearEventStatus = SearchImageNew({Main.Bear_Event.dir.. "Cooldown.png", Main.Bear_Event.dir.. "Pre Registration.png", Main.Bear_Event.dir.. "Ends.png"}, Lower_Half, 0.9, false, false, 3) --pre reg not found
		if (bearEventStatus.name) then
			local cooldownROI = Region(bearEventStatus.sx + bearEventStatus.w, bearEventStatus.sy, 300, bearEventStatus.h)
			remainingTime = Num_OCR(cooldownROI, "a")
			Logger(string.format("Remaining Time: %s", tostring(remainingTime)))
			usePreviousSnap(false)
			Logger(bearEventStatus.name)
			if (bearEventStatus.name == "Cooldown") then
				Logger("Cooldown Found")
				if (SearchImageNew(Main.Bear_Event.dir.. "Bear 1d.png", cooldownROI).name) then return false end
				local time1 = subtractHoursFromTime(os.date("%H:%M:%S"), getUTCOffset())
				local time2 = subtractHoursFromTime(ATB, getUTCOffset())
				local result, CurTime = Convert_To_Seconds(remainingTime) + Convert_To_Seconds(time1), Convert_To_Seconds(time2)	
				if (CurTime < result) then return false end
				local time_result = Get_Time_Difference(os.date("%H:%M:%S"), Get_Time(CurTime))
				if (time_result >= 0) and (time_result < 900) then return true end
			elseif (bearEventStatus.name == "Pre Registration") then
				Logger("Pre-Registration Found")
				local result = processOCR(remainingTime)
				Logger("Result Date: " ..result.d) --[2024-07-14 01:53:00] Result: 2024-07-13
				Logger("Result Time: " ..result.t) --[2024-07-14 01:53:00] Result: 23:00
				local originalDateTime = string.format("%s %s:00" , result.d, result.t)
				Logger("Result Original Date and Time: " ..originalDateTime)
				local dateTable = parseDateTime(originalDateTime)
				local newTimestamp = os.time(dateTable) + (getUTCOffset() * 60 * 60)
				local newDateTime = os.date("%Y-%m-%d %H:%M:%S", newTimestamp)
				Logger("Result Processed Date and Time: " ..newDateTime)
				local datePart, timePart = newDateTime:match("(%d+%-%d+%-%d+) (%d+:%d+:%d+)")
				Logger("Result Processed Date: " ..datePart) --[2024-07-14 01:53:00] Result: 2024-07-13
				Logger("Result Processed Time: " ..timePart) --[2024-07-14 01:53:00] Result: 23:00:00
				if not(datePart == os.date("%Y-%m-%d")) then return false end
				local result = Get_Time_Difference(os.date("%H:%M:%S"), timePart) --[2024-07-14 01:53:00] Result Difference: 86820
				Logger("Result Difference: " ..result) --[2024-07-14 01:53:00] Bear Status: false
				if (result >= 0) and (result < 900) then return true end
			elseif (bearEventStatus.name == "Ends") then
				return true
			else
				Logger("Add something here")
				return false
			end
		else  -- there are cases where cooldown and pre-reg is not found probably manual trigger
			Logger("Cannot Find Cooldown/Pre Registration Images")
			if (SingleImageWait(Main.Bear_Event.dir.. "Enable Only.png", 2, Lower_Half, 0.9, true)) then return true end
			return false 
		end
		return false
	end
	
	local BearEventDir = "Events/"
	Logger("Checking Bear Event")
	local Events_Logo = SingleImageWait("Event logo.png", 5, Upper_Half, 0.9, true)
	if not(Events_Logo) then
		Logger("Events screen not found")
		return false
	end
	PressRepeatNew(Events_Logo, "Events.png", 1, 2, Upper_Half, Upper_Half, 0.9, true, true)
	Logger("Searching for Bear")
	local Bear_Tab = SearchImageNew(BearEventDir.. "Bear.png", Upper_Half, 0.9, true)
	local result
	if not(Bear_Tab.name) then
		local Swipe_Right, Swipe_Left, Middle = Location(50, 170), Location(655, 170), Location(screen.x/2, 170)
		local Start_Loc = Swipe_Right 
		while true do
			swipe(ranNumbers(Start_Loc, 10), Middle, 2)
			wait(1)
			Bear_Tab = SearchImageNew(BearEventDir.. "Bear.png", Upper_Half, 0.9, true)
			if (Bear_Tab.name) then break end
			if (SearchImageNew("Events/Calendar.png", Upper_Half, 0.9, true).name) then 
				Logger("Calendar Found Swiping Right")
				Start_Loc = Swipe_Left 
			end
			if (SearchImageNew("Events/Community.png", Upper_Right, 0.9, true).name) then 
				Logger("Community found")
				Go_Back("Bear Event Unavailable")
				return 0
			end
		end
	end
	if (Bear_Tab.name) then
		Logger("Clicking Bear Tab")
		PressRepeatNew(Bear_Tab.xy, "Bear Trap Enhancement.png", 1, 1)
		wait(3)
		result = event_day(ATB)
		Logger("Bear Status: " ..tostring(result))
	end
	Go_Back("Bear Checking Completed!: ")
	return result or false
end

function Search_Magnifyer(image)
	local Screen_Status, Search 
	snapshotColor()
	Screen_Status = SearchImageNew({"Magnifying.png", "Magnifyer New.png"}, Lower_Left, 0.8, true)
	usePreviousSnap(false)
	if (Screen_Status.name) then
		Logger("Magnifyer Found! searching for " ..image)
		Search = PressRepeatNew(Screen_Status.xy, image, 1, 4, nil, Lower_Half, 0.9)
		Logger("Search Found!")
		return {status = true, search = Search}
	end
	return {status = false, search = false}
end

function MagnifyerSearch(Required)
	local Magnifyer_Folder, All_Image_Final, Required_Result, All_Image_Found, All_Image_Scanned = "Magnifyer/", {}
	local SwipeLoc = {Beasts = screen.x - 8, Polar_Terror = screen.x - 8, Meat = screen.x - 8, Wood = 8, Coal = 8, Iron = 8}
	local Required_Checked, Frame_Region = Required:gsub(" ", "_")
	Logger("Searching for " .. Required)
	Required_Result = SearchImageNew(string.format("%s%s.png", Magnifyer_Folder, Required), Lower_Half, 0.9, true)
	if not(Required_Result.name) then
		Logger("Image not found " ..Required)
		All_Image_Scanned = scandirNew(Magnifyer_Folder)
		for i, img in ipairs(All_Image_Scanned) do table.insert(All_Image_Final, string.format("%s%s", Magnifyer_Folder, img)) end
		Logger("Searching for Image to Swipe")
		repeat All_Image_Found = SearchImageNew(All_Image_Final, Lower_Half, 0.9, true) until(All_Image_Found.name)
		Logger("Image found: " ..All_Image_Found.name)
		repeat
			Logger("Swiping")
			swipe(Location(All_Image_Found.x, All_Image_Found.y), Location(SwipeLoc[Required_Checked], All_Image_Found.y), .8)
			wait(.5)
			Logger("Looking for Image: " ..Required)
			Required_Result = SearchImageNew(string.format("%s%s.png", Magnifyer_Folder, Required), Lower_Half, 0.9, true)
		until(Required_Result.name)
		Logger("Image Found: " ..Required)
	end
	Frame_Region = Region(Required_Result.sx + (Required_Result.w/2), Required_Result.sy + (Required_Result.h/2), Required_Result.w, Required_Result.h)
	Logger("Pressing Required Image")
	PressRepeatNew(Required_Result.xy, string.format("%sFrame.png", Magnifyer_Folder, Required), 1, 2, nil, Frame_Region, 0.95, false, true, false, true)
end

local function normalizeFlag(v)
	if v == nil then return "0" end
	v = tostring(v)
	local digits = v:match("(%d+)")
	local n = tonumber(digits or "0") or 0
	if n < 0 then n = 0 end
	if n > 8 then n = 8 end
	return tostring(n)
end

function Auto_Beast_Search(Search)
        Logger("Starting Attack on " ..Attack_Type)
	local Screen_Status, Cur_Lv, OCR_Status
	------- Magnifyer Search ----------------
	MagnifyerSearch(Attack_Type)
	Logger("Searching Current Level")
	if not(Magnifyer_Level_Region) then Magnifyer_Level_Region = SearchImageNew("Level.png", Lower_Half, 0.90, true, true, 999).r end
	repeat
		Logger("Running OCR on Current Level")
		repeat Cur_Lv, OCR_Status = numberOCRNoFindException(Magnifyer_Level_Region, "ocr/l") until(OCR_Status)
		Logger("Current Level: " ..Cur_Lv)
		if (Cur_Lv == Req_Lv) then break
		elseif (Cur_Lv < Req_Lv) then 
			local Total_Click = Req_Lv - Cur_Lv
			local Plus = SearchImageNew("Plus.png", Lower_Half)
			for i = 1, Total_Click do
				Logger("Clicking Plus Button")
				Press(Plus.xy, 1)
			end
		elseif (Cur_Lv > Req_Lv) then
			local Total_Click = Cur_Lv - Req_Lv
			local Minus = SearchImageNew("Minus.png", Lower_Half)
			for i = 1, Total_Click do
				Logger("Clicking Minus Button")
				Press(Minus.xy, 1)
			end
		end
	until(Cur_Lv == Req_Lv)
	-------------- Searching for Monster ----------------
	Logger("Clicking Search Button")
	local Deploy_Btn
	if (Attack_Type == "Beasts") then
		Logger("Searching for Beasts")
		local Attack = PressRepeatNew(Search.xy, "Attack.png", 1, 5, Lower_Half, nil, 0.8, true, true)
		Logger("Attacking Beasts")
		local Attack_Status = PressRepeatNew(Attack.xy, {"Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.8, true)
		if (Attack_Status.name == "March Queue Limit") then
			Go_Back("March Queue limit sleeping for 300 seconds")
			return 300
		else Deploy_Btn = Attack_Status
		end
                local rawFlagReq = Flag_Req
                local _flagReq = normalizeFlag(rawFlagReq)
                Logger(string.format("AutoAttack: using Flag_Req=%s (raw=%s)", tostring(_flagReq), tostring(rawFlagReq)))
                return Auto_Beast(Deploy_Btn, Attack_Type, _flagReq, Use_Hero, true)
	else
		Logger("Searching for Polar Terror")
		local Rally = PressRepeatNew(Search.xy, "Rally.png", 1, 5, Lower_Half, nil, 0.8, true, true)
		return rallyStarter(Rally, true)
	end
end

function Auto_Beast(Deploy_Btn, attackType, flagReq, useHero, useCounter)
	useCounter = useCounter or false
	----------- USE ALL --------------------
	if (Use_All) then
		Logger("Clicking Deploy")
		if (Solo_troop) then
			PressRepeatNew("Withdraw All.png", "Zero Troops ON.png", 1, 2, Lower_Half, Lower_Half, 0.9, true, true)
			PressRepeatNew("Troop Plus.png", "Zero Troops OFF.png", 1, 2, Upper_Half, Lower_Half, 0.9, true, true)
		end
		if (Equalize_March) then
			local Repeat_Counter, Equalize_Image = 0
			Equalize_Image = SearchImageNew("Equalize.png", Lower_Half, 0.8, true, false, 9999)
			repeat
				Repeat_Counter = Repeat_Counter + 1
				Press(Equalize_Image.xy, 1)
				wait(.1)
			until(Repeat_Counter >= 3)
		end
		local Deploy_Status = PressRepeatNew(Deploy_Btn.xy, {"World.png", "City.png", "Obtain More.png", "Confirmation.png", "Other Troops Marching.png"}, 1, 4, nil, nil, 0.9, true, true)
		if (Deploy_Status.name == "Confirmation") then
			Diversity = SearchImageNew("Not Enough Diversity.png", nil, 0.9, true)
			if (Diversity.name) then 
				PressRepeatNew(string.format("%s,%s", Diversity.sx, Diversity.sy), "Diversity Checked.png", 1, 3, nil, nil, 0.9, nil, true) 
				PressRepeatNew("Confirmation Deploy.png", {"World.png", "City.png"}, 1, 4, nil, nil, 0.9, true, true)
				return Use_All_Timer
			end
			
			Logger("Closing Confirmation")
			PressRepeatNot("Confirmation X.png", "Confirmation.png", 1, 1, Upper_Half, Upper_Half, 0.8)
			Go_Back()
			--Logger("Total sleep time is " ..total_Seconds)
		elseif (Deploy_Status.name == "Obtain More") then
			Go_Back()
			if (AutoStop_Attack) then
				Auto_Attack = false
				total_Seconds = 0
			end
			return total_Seconds
		
		elseif (Deploy_Status.name == "Other Troops Marching") then
			Logger("Other Troops Marching")
			Go_Back()
			total_Seconds = 1
			
		elseif (Deploy_Status.name == "City") or (Deploy_Status.name == "World") then
			Message.Polar_attack = Message.Polar_attack + 1
			if (useCounter) then
				Main.Attack.counter = Main.Attack.counter + 1
				preferencePutNumber("attackLimitCounter", Main.Attack.counter)
			end
		end
		return Use_All_Timer
	end
	----------- Search for Gina --------------------
	local Hero_List = {}
	if (useHero) then
		if (Hero_Type == "Both") then Hero_List = {"Gina.png", "Bokan.png"}
		else Hero_List = {string.format("%s.png", Hero_Type)} end
	end
	
	if (useHero) and not(Use_All) then
		Logger("Checking for required HERO")
		local Hero_Found = 0
		for _, Cur_Hero in ipairs(Hero_List) do
			local Hero_Status = SearchImageNew(Cur_Hero, Upper_Half, 0.85, true, false, 2)
			if (Hero_Status and Hero_Status.name) then
				Hero_Found = Hero_Found + 1
			end
		end
		if not(Hero_Found == table.getn(Hero_List)) then
			Logger("Required HERO is not found. Sleeping for 60 Seconds")
			Go_Back("Waiting for hero")
			return 60
		end
	end

	flagReq = normalizeFlag(flagReq)
	if flagReq and flagReq ~= "0" then
		Logger(string.format("Auto_Beast: selecting flag=%s", flagReq))

		local roiY = math.floor(screen.y * 0.55)
		local roiH = math.floor(screen.y * 0.25)
		local flagROI = Region(0, roiY, screen.x, roiH)

		local flagImage = string.format("Flags/Flag%s.png", flagReq)
		local Troop_Flag = SearchImageNew(flagImage, flagROI, 0.85, true, false, 3)
		if not (Troop_Flag and Troop_Flag.xy) then
			Logger("Auto_Beast: flag not in primary ROI; expanding search")
			Get_Flags_Coordinates()
			Troop_Flag = SearchImageNew(flagImage, nil, 0.85, true, false, 3)
		end

		if Troop_Flag and Troop_Flag.xy then
			local confirmationRegion
			if Troop_Flag.r then
				confirmationRegion = Troop_Flag.r
			else
				confirmationRegion = Region(Troop_Flag.sx - 27, Troop_Flag.sy - 20, 53, 46)
			end
			PressRepeatNew(Troop_Flag.xy, "Flag Selected.png", 1, 2, nil, confirmationRegion, 0.9, false, true)
			Logger(string.format("Auto_Beast: flag %s tapped", flagReq))
		else
			Logger(string.format("Auto_Beast: requested flag %s NOT found; leaving current flag unchanged", flagReq))
		end
	else
		Logger("Auto_Beast: flagReq is '0'/nil (no preference) — leaving current flag unchanged")
	end


        local total_Seconds = Get_March_Time()
	if (Solo_troop) and (attackType == "Polar Terror") then
		PressRepeatNew("Withdraw All.png", "Zero Troops ON.png", 1, 2, Lower_Half, Lower_Half, 0.9, true, true)
		PressRepeatNew("Troop Plus.png", "Zero Troops OFF.png", 1, 2, Upper_Half, Lower_Half, 0.9, true, true)
	else
		total_Seconds = total_Seconds * 2
	end
	wait(.5)
	if ((attackType == "Polar Terror") or (attackType == "Reaper")) then total_Seconds = total_Seconds + 300 end --polar terror/Reaper adds 5 minutes for rally
	Logger("Clicking Deploy")
	local Deploy_Status = PressRepeatNew(Deploy_Btn.xy, {"World.png", "City.png", "Obtain More.png", "Confirmation.png", "Other Troops Marching.png"}, 1, 4, nil, nil, 0.8, true, true)
	if (Deploy_Status.name == "Obtain More") then
		Logger("Stamina Insufficient Checking Remaining Stamina")
		local Obtain_More_Max = SearchImageNew("Obtain More Max 200.png", Upper_Half, 0.9, true, false, 99999)
		local Max_Region = Region(Obtain_More_Max.sx - (Obtain_More_Max.w * 2), Obtain_More_Max.sy, Obtain_More_Max.w * 2, Obtain_More_Max.h)
		local Number, Number_Status
		repeat Number, Number_Status = numberOCRNoFindException(Max_Region, "ocr/s") until(Number_Status)	
		Logger("Closing Obtain More")
		Go_Back()
		
		if (Auto_Join_Enabled) and not(Main.Auto_Join.status) then 
			Auto_Join("ON")
			Main.Auto_Join.status = true
		end

		if (AutoStop_Attack) then Auto_Attack, total_Seconds = false, 0
		else total_Seconds = checkStamina(Number, "") end
	elseif (Deploy_Status.name == "Confirmation") then
		if (SearchImageNew("Other Troops Marching.png", nil, 0.9, true).name) then total_Seconds = 1
		else total_Seconds = 120 end
		Diversity = SearchImageNew("Not Enough Diversity.png", nil, 0.9, true)
		if (Diversity.name) then 
			PressRepeatNew(string.format("%s,%s", Diversity.sx, Diversity.sy), "Diversity Checked.png", 1, 3, nil, nil, 0.9, nil, true) 
			PressRepeatNew("Confirmation Deploy.png", {"World.png", "City.png"}, 1, 4, nil, nil, 0.9, true, true)
			return total_Seconds
		end
		
		Logger("Closing Confirmation")
		PressRepeatNot("Confirmation X.png", "Confirmation.png", 1, 1, Upper_Half, Upper_Half, 0.8)
		Go_Back()
		Logger("Total sleep time is " ..total_Seconds)
	elseif (Deploy_Status.name == "Other Troops Marching") then
		Logger("Other Troops Marching")
		Go_Back()
		total_Seconds = 1
	else
		if (useCounter) then
			Main.Attack.counter = Main.Attack.counter + 1
			preferencePutNumber("attackLimitCounter", Main.Attack.counter)
		end
		if (attackType == "Polar Terror") then Message.Polar_attack = Message.Polar_attack + 1
		else Message.Beast_attack = Message.Beast_attack + 1 end
	end
	return total_Seconds
end

local TechX = nil
function Tech_Help()
	Current_Function = getCurrentFunctionName()
	local Contribute_Status, Thumbs_Up, Thumbs_Up_Timer, Alliance_Btn
	Logger("Checking Alliance Button")
	Alliance_Btn = SearchImageNew("Alliance.png", Lower_Half, 0.8, true)
	if not(Alliance_Btn.name) then 
		Logger("Alliance button not found")
		return 0
	end
	
	Logger("Clicking Alliance")
	local Tech_Btn = PressRepeatNew(Alliance_Btn.xy, "Tech.png", 1, 2)
	Logger("Clicking Tech")
	local Tech_Label = PressRepeatNew(Tech_Btn.xy, "Tech Label 2.png", 1, 2)
	Logger("Searching for Thumbs Up")
	Thumbs_Up = SearchImageNew("Thumbs Up.png", nil, 0.8, true, false, 1.5)
	if (Thumbs_Up.name) then 
		Logger("Checking Contribute")
		Contribute_Status = PressRepeatNew(Thumbs_Up.xy, {"Contribute Available.png", "Contribute Unavailable.png"}, 1, 2, nil, nil, 0.9, true, true)
		Logger(Contribute_Status.name)
		if (Contribute_Status.name == "Contribute Available") then 
			Logger("Clicking Contribute")
			longClick(Contribute_Status.xy)
			SearchImageNew("Attempts 0.png", Lower_Half, 0.96, true, false, 5)
			Logger("Stopping Long Press")
			stopLongClick()
		end
	end
	
	local aTriumph = false

	if (Main.Triumph.status) then
		Logger("Going Back To Alliance Screen")
		PressRepeatNew(Tech_Label.xy, "Tech Label 2.png", 1, 2, nil, Upper_Left, 0.90, false, true)
		PressRepeatNew("Back Btn.png", "Alliance Chests.png", 1, 3, Upper_Left, nil, 0.90, true, true)
		aTriumph = true
		Logger("Checking Triumph")
		Triumph("Alliance")
	end
	if (Auto_Chests) then
		Logger("Going Back To Alliance Screen")
		Main.Chests.timer, Auto_Chests_With_Tech = nil, true
		if not(aTriumph) then
			PressRepeatNew(Tech_Label.xy, "Tech Label 2.png", 1, 2, nil, Upper_Left, 0.90, false, true)
			PressRepeatNew("Back Btn.png", "Alliance Chests.png", 1, 3, Upper_Left, nil, 0.90, true, true)
		end
		Logger("Checking Alliance Chest")
		Alliance_Chests("Alliance")
	else Go_Back("Completing Tech") end
	return 0
end

function Triumph(initialScreen)
	local TriumphDir = "Triumph/"
	Current_Function = getCurrentFunctionName()

	if (initialScreen == "World") then
		Logger("Checking Alliance Button")
		Alliance_Btn = SearchImageNew("Alliance.png", Lower_Half, 0.8, true)
		if not(Alliance_Btn.name) then 
			Logger("Alliance button not found")
			return 300
		end
	
		Logger("Clicking Alliance")
		PressRepeatNew(Alliance_Btn.xy, TriumphDir.. "Triumph.png", 1, 2)
	elseif (initialScreen == "Alliance") then
		Logger("Alliance Screen Found")
		SingleImageWait(TriumphDir.. "Triumph.png", 999999)
	else return 300 end
	
	local returnTime = 1800
	local triumpStatus = multiHexColorFind(Location(388, 1417), {"#72B0DE", "#FF1E1F"}, 10) -- FF1E1F red dot found
	if (triumpStatus == "#FF1E1F") then
		Logger("Red Dot Found")
		PressRepeatHexColor(Location(360, 1444), Location(680, 35), "#EEF0F2", 5, 4)
		if not(isColorWithinThresholdHex(Location(439, 561), "#805712", 5)) then -- Claim Weekly Reward
			PressRepeatHexColor(Location(439, 561), Location(350, 250), "#FFFFFF", 5, 4)  --Click Box until tap to continue
			PressRepeatHexColor(Location(30, 400), Location(30, 400), {"#59A3DD", "#4D9EDC"}, 5, 1)  --Clicking Somewhere until Tap to continue is gone
		end
		
		local dailyRedDot = multiHexColorFind(Location(689, 1043), {"#FFB54A", "#FF1E1F"}, 10) -- FF1E1F red dot found
		if (dailyRedDot == "#FF1E1F") then
			PressRepeatHexColor(Location(125, 1074), Location(20, 920), "#0E1C2E", 5, 4) --Click Box until tap to continue
			PressRepeatHexColor(Location(30, 400), Location(30, 400), {"#59A3DD", "#4D9EDC"}, 5, 1) --Clicking Somewhere until Tap to continue is gone
			returnTime = Get_Time_Difference()
			Main.Triumph.status = false
		end
		PressRepeatNew(4, TriumphDir.. "Triumph.png", 1, 5)
	else
		Logger("Red Dot Not Found")
	end
	
	if (initialScreen == "World") then
		Go_Back("Triumph Completed")
	end
	
	return returnTime
end

function Alliance_Chests(Screen)
	Current_Function = getCurrentFunctionName()
	Screen = Screen or nil
	if not(Screen == "Alliance") then
		Logger("Checking Alliance Button")
		Alliance_Btn = SearchImageNew("Alliance.png", Lower_Half, 0.8, true)
		if not(Alliance_Btn.name) then 
			Logger("Alliance button not found")
			return 0
		end
		Logger("Clicking Alliance")
		PressRepeatNew(Alliance_Btn.xy, "Alliance Chests.png", 1, 2)
	end
	Logger("Waiting for Buttons to fully load")
	wait(.5)
	Logger("Checking Chests for available Rewards")
	local r, g, b = getColor(Location(674, 626))
	if (isColorWithinThreshold(r, g, b, 61, 148, 229, 10)) then --- GET COLOR
		Go_Back("Nothing to Claim")
		return 0
	end
	
	Logger("Opening Chests Screen")
	PressRepeatNew("Alliance Chests.png", {"Alliance Loot Chest Clicked.png", "Alliance Gift Clicked.png"}, 1, 2)
	Logger("Waiting for Chests Screen to Fully Load")
	wait(.5)
	local Tab, rewardsAvailable = {[1] = {loc = Location(333, 370), status = false, claimAll = Location(360, 1420)}, [2] = {loc = Location(672, 370), status = false, claimAll = Location(602, 1410)}, [3] = {loc = Location(400, 160), status = false}}, false
	snapshotColor()
	local r, g, b = getColor(Tab[1].loc) --(left tab)
	if not(isColorWithinThreshold(r, g, b, 139, 196, 255, 10)) and not(isColorWithinThreshold(r, g, b, 46, 105, 162, 10)) then --- GET COLOR 1 for clicked/1 for unclicked
		Tab[1].status, rewardsAvailable = true, true
	end
	
	local r, g, b = getColor(Tab[2].loc) --(right tab)
	if not(isColorWithinThreshold(r, g, b, 139, 196, 255, 10)) and not(isColorWithinThreshold(r, g, b, 46, 105, 162, 10)) then --- GET COLOR 1 for clicked/1 for unclicked
		Tab[2].status, rewardsAvailable = true, true
	end
	
	local r, g, b = getColor(Tab[3].loc) --(Honor Chest)
	if not(isColorWithinThreshold(r, g, b, 178, 129, 20, 10)) then
		Tab[3].status, rewardsAvailable = true, true
	end
	usePreviousSnap(false)
	
	if not(rewardsAvailable) then
		Go_Back("No Rewards Available")
		return 0 
	end
	
	if (Tab[1].status) then -- Loot Chest
		Logger("Opening Loot Chest Tab")
		Press(Tab[1].loc, 1)
		wait(0.2)
		Press(Tab[1].loc, 1)
		Logger("Waiting for Claim All button to appear")
		if (SingleImageWait("Alliance Claim All Active.png", 2, Lower_Most_Half, 0.97, true)) then
			local Tap_Anywhere = PressRepeatNew(Tab[1].claimAll, "Tap Anywhere.png", 1, 3, nil, Lower_Half, 0.9, nil, true)
			PressRepeatNew(TargetOffset(Tap_Anywhere.xy, "0", "-100"), "Alliance Claim All Inactive.png", 1, 3, nil, Lower_Half, 0.9, false, true)
		end
	end
	
	if (Tab[2].status) then -- Alliance Gift
		Logger("Opening Alliance Gift Tab")
		PressRepeatNew(Tab[2].loc, "Alliance Gift Clicked.png", 1, 2, nil, Upper_Half, 0.9, true, true)
		Logger("Checking Claim All Status")
		
		local r, g, b = getColor(Tab[2].claimAll) --Claim All Btn
		if not(isColorWithinThreshold(r, g, b, 13, 69, 125, 10)) then
			PressRepeatNew(Tab[2].claimAll, "Tap Anywhere.png", 1, 3, nil, Lower_Half, 0.9, false, true)
			PressRepeatNew(Tab[2].claimAll, "Alliance Gift Clicked.png", 1, 1, nil, Upper_Half, 0.9, false, true)
		else
			local Claim_Counter = 0
			while true do
				local Alliance_Claim = findAllNoFindException(Pattern("Alliance Claim.png"):similar(0.9):color())
				if (table.getn(Alliance_Claim) > 0) then 
					Logger("Claiming Chest")
					Claim_Timer = nil
					Press(Alliance_Claim[1])
					wait(.8)
				else 
					Claim_Counter = Claim_Counter + 1
					wait(.8)
					if (Claim_Counter >= 2) then break end
				end
			end
		end
	end
	
	if (Tab[3].status) then -- Honor Chest
		Logger("Claiming Honor Chest Rewards") --try to use color instead of images
		local imgResult = PressRepeatNew(Tab[3].loc, {"Tap Anywhere.png", "Honor Chest.png"}, 1, 4)
		if (imgResult.name == "Tap Anywhere") then
			Logger("Tap Anywhere Found and Closing!!!")
			PressRepeatNew(TargetOffset(imgResult.xy, "0", "-100"), "Alliance Reward Chest Empty.png", 1, 3, nil, Upper_Half, 0.9, false, true)
		else
			Logger("No Rewards Found and Closing Honor Chest Screen")
			PressRepeatNot(Tab[3].loc, "Honor Chest.png", 1, 2) 
		end
	end
	Go_Back("Completing Chests Claiming")
end

function Get_Max_Troop()
	Current_Function = getCurrentFunctionName()
	Ratio_Infantry = Ratio_Infantry or Troop_Ratio_Infantry
	Ratio_Lancer = Ratio_Lancer or Troop_Ratio_Lancer
	Ratio_Marksman = Ratio_Marksman or Troop_Ratio_Marksman
	local Daily_Mission_Logo = SearchImageNew("Daily Mission.png", Lower_Left, 0.9, true, false, 2)
	local Ratio_List = {["Infantry Logo"] = Ratio_Infantry, ["Lancer Logo"] = Ratio_Lancer, ["Marksman Logo"] = Ratio_Marksman}
	Logger("Clicking Chief Profile")	
	local Troops = PressRepeatNew("50,50", "Troops.png", 1, 4, nil, Lower_Half, 0.9, false, true)
	Logger("Clicking Troops")	
	local Formations = PressRepeatNew(Troops.xy, "Formations.png", 1, 2, nil, Lower_Half, 0.9, false, true)
	Logger("Clicking Balance")	
	PressRepeatNew(Formations.xy, "Balance.png", 1, 2, nil, Lower_Half, 0.9, false, false)
	------
	snapshot()
	if not(Rally_Troop_ROI) then
		local Rally_Troop_Divider = SearchImageNew("March Divider.png", Upper_Left, 0.9, false, false, 99999)
		local Rally_Troop_Exclamation = SearchImageNew("Deployment Exclamation.png", Upper_Left, 0.9, false, false, 99999)
		Rally_Troop_ROI = Region(Rally_Troop_Divider.x, Rally_Troop_Divider.sy, Rally_Troop_Exclamation.sx - (Rally_Troop_Divider.sx + Rally_Troop_Divider.w), Rally_Troop_Divider.h)
	end
	Troop_Rally_Max = Num_OCR(Rally_Troop_ROI, "t")
	usePreviousSnap(false)
	Go_Back()
end

function troopUpdateCount(Ratio_Infantry, Ratio_Lancer, Ratio_Marksman)
	local xList = {[1]=115, [2]=187, [3]=255, [4]=325, [5]=397, [6]=466, [7]=534}
	local Ratio_List = {["Infantry"] = Ratio_Infantry, ["Lancer"] = Ratio_Lancer, ["Marksman"] = Ratio_Marksman}
	local Troop_Area_List = {Infantry = {whole = Region(164, 566, 383, 125), input_box = Region(564, 630, 62, 37)}, 
			Lancer = {whole = Region(164, 712, 383, 125), input_box = Region(564, 776, 62, 37)},
			Marksman = {whole = Region(164, 859, 383, 125), input_box = Region(564, 922, 62, 37)}}
	for i = 1, 7 do
		local curFlag = flags_coordinates[i]
		if (curFlag) then
			click(curFlag.f.xy)
			while true do
				if(isColorWithinThresholdHex(Location(curFlag.f.sx, curFlag.f.y), "#F5BC3D", 5)) then break end
			end
			
			PressRepeatHexColor(Location(330, 1425), Location(492, 519), "#C6D6EC", 5, 1) --Click Balance to Open Balance Screen
			if (i == 1) then
				for i, troop in ipairs({"Infantry", "Lancer", "Marksman"}) do
					Logger("Searching for Input Box")
					while true do
						Logger("Checking Troop Percentage on Input Box")
						local Number = Num_OCR(Troop_Area_List[troop]["input_box"], "a")
						if (Number == Ratio_List[troop]) or (Number == 0) then
							Logger("Required Percentage Found")	
							break
						else
							Logger(string.format("Swiping: Required %s - Found %s", tostring(Ratio_List[troop]), tostring(Number)))	
							local Slider = SearchImageNew("Slider Button.png", Troop_Area_List[troop]["whole"])
							swipe(Location(Slider.x, Slider.y), Location(5, Slider.y), 1)
						end
					end
				end
			
				local r, g, b = getColor(Location(screen.x/2, screen.y-5))	
				for i, Cur_Troop in ipairs({"Infantry", "Lancer", "Marksman"}) do
					Logger("Updating Troop: " .. Cur_Troop)
					while true do
						local Number = Num_OCR(Troop_Area_List[Cur_Troop]["input_box"], "a")
						if (Number == Ratio_List[Cur_Troop]) then
							Logger("Required Percentage Found")	
							break
						else
							if (Number > 0) then
								Logger(string.format("Swiping: Required %s - Found %s", tostring(Ratio_List[troop]), tostring(Number)))	
								local Slider = SearchImageNew("Slider Button.png", Troop_Area_List[Cur_Troop]["whole"])
								swipe(Location(Slider.x, Slider.y), Location(5, Slider.y), 1)
								wait(.5)
							end
							Logger("Clicking Input Box to Add required Troop Percentage")
							click(Troop_Area_List[Cur_Troop]["input_box"])
							wait(0.8)
							type(tostring(Ratio_List[Cur_Troop]))
							wait(.3)
							while true do
								Press(Location(492, 519), 1)
								local r2, g2, b2 = getColor(Location(screen.x/2, screen.y-5))
								if (isColorWithinThreshold(r, g, b, r2, g2, b2, 5)) then break end
							end
						end
					end
				end
			end
			Logger("1")
			PressRepeatHexColor(Location(358, 1102), Location(513, 542), "#0D315F", 5, 2) --Press Confirm to Close Balance Screen
			Logger("2")
			--[[PressRepeatHexColor(Location(67, 1424), Location(630, 1443), "#697079", 10, 1) --Press Quick Select
			wait(0.2)
			PressRepeatHexColor(Location(67, 1424), Location(630, 1443), "#4FA5FC", 10, 1) --Press Quick Select to Activate Save--]]
			Logger("3")
			PressRepeatHexColor(Location(630, 1443), Location(436, 885), "#697079", 10, 2) --click Save
			Logger("4")
			PressRepeatHexColor(Location(xList[i], 645), Location(436, 970), "#4FA5FC", 10, 2) --Select Flag
			--PressRepeatHexColor(Location(xList[i], 700), Location(436, 885), "#4FA5FC", 10, 2) --Select Flag
			Logger("5")
			PressRepeatHexColor(Location(436, 970), Location(630, 1443), "#4FA5FC", 10, 2) --Press Confirm / New Update 03/03/2025 confirm now is on different location
			Logger("6")
		end
	end
end

function Balance_Troop_Ratio(Ratio_Infantry, Ratio_Lancer, Ratio_Marksman, Task)
	Current_Function = getCurrentFunctionName()
	Ratio_Infantry = Ratio_Infantry or Troop_Ratio_Infantry
	Ratio_Lancer = Ratio_Lancer or Troop_Ratio_Lancer
	Ratio_Marksman = Ratio_Marksman or Troop_Ratio_Marksman
	local Daily_Mission_Logo = SearchImageNew("Daily Mission.png", Lower_Left, 0.9, true, false, 2)
	local Ratio_List = {["Infantry"] = Ratio_Infantry, ["Lancer"] = Ratio_Lancer, ["Marksman"] = Ratio_Marksman}
	Logger("Clicking Chief Profile")	
	local Troops = PressRepeatNew("50,50", "Troops.png", 1, 4, nil, Lower_Half, 0.9, false, true)
	Logger("Clicking Troops")	
	local Formations = PressRepeatNew(Troops.xy, "Formations.png", 1, 2, nil, Lower_Half, 0.9, false, true)
	Bear_Max_March = Num_OCR(Region(288,228, 74, 24), "t") % 10
	Logger("Clicking Balance")	
	PressRepeatNew(Formations.xy, "Balance.png", 1, 2, nil, Lower_Half, 0.9, false, false)

	snapshot()
	if not(Rally_Troop_ROI) then
		local Rally_Troop_Divider = SearchImageNew("March Divider.png", Upper_Left, 0.9, false, false, 99999)
		local Rally_Troop_Exclamation = SearchImageNew("Deployment Exclamation.png", Upper_Left, 0.9, false, false, 99999)
		Rally_Troop_ROI = Region(Rally_Troop_Divider.x, Rally_Troop_Divider.sy, Rally_Troop_Exclamation.sx - (Rally_Troop_Divider.sx + Rally_Troop_Divider.w), Rally_Troop_Divider.h)
	end
	Troop_Rally_Max = Num_OCR(Rally_Troop_ROI, "t")
	usePreviousSnap(false)
	
	if (Task) then
		Logger("Checking Flags Coordinate")	
		Get_Flags_Coordinates()
		Logger()	
		troopUpdateCount(Ratio_Infantry, Ratio_Lancer, Ratio_Marksman)
	else
		Logger("Checking Flags Coordinate without updating troop count")
		Get_Flags_Coordinates()
	end
	Go_Back("Ratio Completed and Going Back")
end


function RSS_Stats_Checker(RSS)
	local RGSBoost = false
	if (SingleImageWait("Resources Gathering/Resources Gathering Speed.png", 1, Region(62,98, 236, 40), 0.9, true)) then RGSBoost = true end
	Logger("Automatic RSS Activated")	
	if (RSS == "") then
		Logger("Clicking Chief Profile")	
		local Troops = PressRepeatNew("50,50", "Troops.png", 1, 4, nil, Lower_Half, 0.9, false, true)
		Logger("Clicking Troops")	
		local Formations = PressRepeatNew(Troops.xy, "Formations.png", 1, 2, nil, Lower_Half, 0.9, false, true)
		PressRepeatNew(Formations.xy, "Deployment Exclamation.png", 1, 2, nil, Upper_Half, 0.9, false, true)
	elseif (RSS == "1") then return 0
	end
	Logger("Opening Troops Bonus")
	local Close = PressRepeatNew("Deployment Exclamation.png", "Confirmation X.png", 1, 2, Upper_Left, Upper_Half, 0.9, true, true)
	wait(1)
	Logger("Closing Troops Preview Tab")
	local tab_opened = SingleImageWait("Troop Bonus/Tab Opened.png", 999999999, Region(634, 346, 43, 34))
	Logger("Tab Closing")
	PressRepeatNew(tab_opened, "Troop Bonus/Tab Closed.png", 1, 2, Region(634, 346, 43, 34), Region(634, 346, 43, 34))
	Logger("Closing Rally Bonus Tab")
	Logger("Tab Closing")
	PressRepeatNew("Troop Bonus/Tab Opened.png", "Troop Bonus/Tab Closed.png", 1, 2, Region(634, 421, 43, 34), Region(634, 421, 43, 34))
	Logger("Waiting for Iron Gathering Speed to Appear")
	local IronImg = SingleImageWait("Troop Bonus/Iron.png", 5, Lower_Half)
	wait(1)
	snapshotColor()
	Troop_RSS_Bonus = {"RGS", "Meat", "Wood", "Coal", "Iron"}
	for i, Cur_Item in ipairs(Troop_RSS_Bonus) do
		local curBonus = SingleImageWait(string.format("Troop Bonus/%s.png", Cur_Item), 3)
		if (curBonus) then
			RSS_Region[Cur_Item].R = Region(530, curBonus:getY() - 2, 105, curBonus:getH())
			local ResOCR = Num_OCR(RSS_Region[Cur_Item].R, "gs")
			--RSS_Region[Cur_Item].R:highlight(1)
			ResOCR = tonumber(string.format("%.2f", ResOCR / 100))
			Logger(Cur_Item.. " :" ..tostring(ResOCR))
			local ROI2 = Region(RSS_Region[Cur_Item].R:getX() - RSS_Region[Cur_Item].R:getW(), RSS_Region[Cur_Item].R:getY(), RSS_Region[Cur_Item].R:getW(), RSS_Region[Cur_Item].R:getH()):highlight(tostring(ResOCR))
			local Hero_Speed
			if not(Cur_Item == "RGS") then Hero_Speed = RSS_Region[Cur_Item].L end	
			if not(Hero_Speed) then Hero_Speed = 0 end
			if not(Cur_Item == RSS) and not(Cur_Item == "RGS") then ResOCR = ResOCR + Hero_Speed end
			RSS_Region[Cur_Item].N = ResOCR
			wait(.2)
			--RSS_Region[Cur_Item].R:highlightOff()
			ROI2:highlightOff()
		else Logger("Cannot Find Gathering Bonus: " ..Cur_Item) end
	end
	if (RGSBoost) and (RSS_Region["RGS"].N > 100) then RSS_Region["RGS"].N = RSS_Region["RGS"].N - 100 end
	usePreviousSnap(false)
	if (RSS == "") then
		Go_Back("Going back to Home Screen")
	else
		PressRepeatNew(Close.xy, "Gather Deploy.png", 1, 1, nil, Lower_Half, 0.9, nil, true)
	end
end

function RSS_Time_Checker(RSS, Lvl, Gather_Status)
	local Base_Speed, Ups_Speed = 316800
	--Add gatheringSpeedBoost = 100
	Base_Speed = Base_Speed + (15840 * (Lvl-1))
	--Ups_Speed = Base_Speed * ((RSS_Region[RSS].N + RSS_Region["RGS"].N) / 100)
	Ups_Speed = Base_Speed * ((RSS_Region[RSS].N + (RSS_Region["RGS"].N + RSS_Region["RGS"].RGB)) / 100)
	if (Gather_Status == "Extra1") or (Gather_Status == "Extra2") then 
		--Ups_Speed = Base_Speed * (((RSS_Region[RSS].N - RSS_Region[RSS].L) + RSS_Region["RGS"].N) / 100) 
		Ups_Speed = Base_Speed * (((RSS_Region[RSS].N - RSS_Region[RSS].L) + (RSS_Region["RGS"].N + RSS_Region["RGS"].RGB)) / 100) 
	end
	local Total_Time = RSS_Capacity[Lvl] / (Base_Speed + Ups_Speed)
	Total_Time = Total_Time * 3600
	Logger(string.format("Gathering Time: %s", Get_Time(Total_Time)))
	RSS_Region["RGS"].RGB = 0
	return Total_Time
end

function Check_Gather_Time(image, RSS_Type, Gather_Status)
	Current_Function = getCurrentFunctionName()
	Logger("Checking Gather Details")
	local Details = PressRepeatNew(image, {"Details.png", "Emote.png"}, 1, 4, nil, nil, 0.9, false, true)
	Logger("Details Result: " ..Details.name)
	if (Details.name == "Emote") then --add checker while marching
		return {Seconds = 60, Status = true} 
	end
	Logger("Clicking Details")	
	local Obtain_More_X = PressRepeatNew(Details.xy, "Obtain More X.png", 1, 2, nil, Upper_Half, 0.9, false, true)
	Logger("Searching for RSS Hero: " ..RSS_Type)
	local Hero_Status = SearchImageNew(string.format("RSS %s Hero.png", RSS_Type), nil, 0.9, true, false, 2)
	if (Hero_Status.name) and ((Gather_Status == "Extra1") or (Gather_Status == "Extra2")) then
		Go_Back(RSS_Type.. " Hero Not Required!!")
		return {Seconds = 1, Status = false}
	elseif not(Hero_Status.name) and (Gather_Status == "Hero") then
		Go_Back(RSS_Type.. " Hero Not Found")
		return {Seconds = 1, Status = false}
	end

	local Number, Number_Status, Seconds
	local Dir_Result, Level_List = scandirNew("Troop Details/"), {}
	for i, v in ipairs(Dir_Result) do table.insert(Level_List, "Troop Details/" ..v) end
	local Level_Found = SearchImageNew(Level_List, Upper_Half, .9, Upper_Left, false, 999999)
	Logger("RSS Found: " ..Level_Found.name.. " - Reading Gathering Time!")
	while true do
		local timeStr = Char_OCR(Region(503, 357, 160, 26), rallyTeamCharTable)
		if (timeStr == "0/0") then
			Logger("CharOCR Failed. Trying to use NumOCR. Reading Max time")
			local Max_Time = RSS_Time_Checker(RSS_Type, tonumber(Level_Found.name), Gather_Status) ---------- REQUIRE RSS FOUND
			local gatheringTimer = Timer()
			repeat Number, Number_Status = numberOCRNoFindException(Region(503, 357, 160, 26), "ocr/rg") until(Number_Status) or (gatheringTimer:check() > 5)
			Seconds = Convert_To_Seconds(Number)
			Logger(string.format("Comparing Remaining Time: Max - %s | Current - %s", Get_Time(Max_Time), Get_Time(Seconds)))
			if (Number_Status) and (Seconds <= Max_Time) then
				Logger("OCR Time Checking Successful")
				break
			end
		else 
			Logger("OCR Found: " ..timeStr)
			if string.match(timeStr, "^%d%d:%d%d:%d%d$") then
				local hour, minute, second = string.match(timeStr, "(%d%d):(%d%d):(%d%d)")
				hour, minute, second = tonumber(hour), tonumber(minute), tonumber(second)
				if hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 and second >= 0 and second <= 59 then
					Seconds = timestr_To_Seconds(timeStr)
					if (Seconds > 0) then
						Logger(string.format("Remaining Time: %s", Get_Time(Seconds)))
						break
					end
				else Logger("Invalid time values: " .. timeStr) end
			else Logger("Invalid time format: " ..timeStr) end
		end
	end

	Go_Back(string.format("Remaining Gathering Time: %s", Get_Time(Seconds)))
	return {Seconds = Seconds, Status = true}
end

function Get_March_Time()
	Logger("Checking March Clock Region")	
	if not(March_Clock_Region) then
		local Clock = SearchImageNew("March Clock.png", Lower_Half, 0.9, true, false, 0)
		March_Clock_Region = Region(Clock.sx + Clock.w, Clock.sy, screen.x - Clock.sx - (Clock.w*3), Clock.h)
	end
	Logger("Reading Marching Time")	
	repeat Number, Number_Status = numberOCRNoFindException(March_Clock_Region, "ocr/t") until(Number_Status)
	local Seconds = Convert_To_Seconds(Number)
	Logger(string.format("March Time: %s", Get_Time(Seconds)))
	wait(.5)
	return Seconds
end

function Gathering_Speed_Boost()
	local gatherDir = "Resources Gathering/"
	Logger("Checking if Gathering Speed Boost is Available")
	Logger()
	if (SingleImageWait(gatherDir.. "Resources Gathering Speed.png", 1, Region(62,98, 236, 40), 0.9, true)) then
		Logger("Speed Boost is already Active")
		RSS_Region["RGS"].RGB = 100
		return true
	end
	Logger("Activating Speed boost")
	Logger()
	local imgResult = PressRepeatNew(gatherDir.. "City Bonus Btn.png", {gatherDir.. "Growth Unclicked.png", gatherDir.. "Growth Clicked.png"}, 1, 2, Upper_Half, Upper_Half)
	if (imgResult.name == "Growth Unclicked") then PressRepeatNew(gatherDir.. "Growth Unclicked.png", gatherDir.. "Growth Clicked.png", 1, 2, Upper_Half, Upper_Half) end
	Logger("Searching for Gathering Speed")
	local gatheringSpeed = SingleImageWait(gatherDir.. "Gathering Speed.png", 9999999, Upper_Half)
	Logger("Generating ROI")
	local x,y,w,h = gatheringSpeed:getX(), gatheringSpeed:getY(), gatheringSpeed:getW(), gatheringSpeed:getH()
	local bonusRegion = Region(x - 10, y + h, w, h*2)
	Logger("Searching for Active Bar")
	if (SingleImageWait(gatherDir.. "Bonus Active Bar.png", 0, bonusRegion)) then --active already and do nothing
		Go_Back("Speed Boost is already Active")
	else
		Logger("Active Bar Unavailable. Activating Boost")
		local boostType = gatherDir.. "8 Hours.png"
		if (rssBoostType == "24 Hours") then boostType = gatherDir.. "24 Hours.png" end
		Logger("Clicking Gathering to Open Use Boost")
		local boostArea = PressRepeatNew(gatheringSpeed, boostType, 1, 2)
		Logger("Generating Use ROI")
		local boostROI = Region(boostArea.sx + boostArea.w + 50, boostArea.sy, 130, 80)
		Logger("Search and Click Use Btn to Activate")
		local boostUseResult = PressRepeatNew(gatherDir.. "Boost Use.png", {gatherDir.. "Bonus Active Bar.png", "Obtain More.png"}, 1, 2, boostROI, Upper_Half)
		if (boostUseResult.name == "Obtain More") then
			Logger("No Boost Available")
			if (useGatheringGems) then
				Logger("Using Gems to buy Boost")
				PressRepeatNew(gatherDir.. "Buy & Use.png", "Daily Rewards/Top up Gems.png", 1, 2)
				PressRepeatNew("Daily Rewards/Top up Gems.png", gatherDir.. "Bonus Active Bar.png", 1, 2, nil, Upper_Half)
				Go_Back("Boost Activated and Going Back")
			else
				Go_Back("Boost Unavailable and Going Back")
				RSS_Region["RGS"].RGB = 0
				return false
			end
		end
		Go_Back("Boost Activated and Going Back")
	end
	RSS_Region["RGS"].RGB = 100
	return true
end

function deploySquadSlider(input)
	local gatherDir = "Resources Gathering/"
	local x,y,w,h = input:getX(), input:getY(), input:getW(), input:getH()
	while true do
		local sliderBtn = SingleImageWait(gatherDir.. "Slider Button.png", 9999999, Region(230, y + h + 10, 390, 53))
		Logger("Slider Btn Found and Swiping")
		swipe(Location(sliderBtn:getCenter():getX(), sliderBtn:getCenter():getY()), Location(4, sliderBtn:getCenter():getY()), .6)
		wait(.5)
		Logger("Checking if Input is Zero")
		if (SingleImageWait(gatherDir.. "Input 0.png", 0, input)) then break end
	end
end

function priorityGatherTroops(requiredPoints, rssType)
	local gatherDir, zeroInput, troopType = "Resources Gathering/"
	Logger("Checking if there's enough troop type")

	repeat troopType = findAllNoFindException(Pattern(gatherDir.. "Slider Button.png"):color():similar(0.9)) until(table.getn(troopType) > 0)
	if (table.getn(troopType) <= 3) then
		Logger("Not enough troop type")
		return 0
	end
	
	if (rssType == "Coal") then requiredPoints = requiredPoints / 5
	elseif (rssType == "Iron") then requiredPoints = requiredPoints / 20 end
	
	Logger("Clicking Withdraw All")
	while true do
		Press(Location(84, 1408), 1)
		wait(.5)
		if (SingleImageWait(gatherDir.. "Deploy Unavailable.png", .5, Lower_Most_Half, 0.9, true)) then break end
	end
	Logger("Finding All Empty Input")
	zeroInput = findAllNoFindException(Pattern(gatherDir.. "Input 0.png"):color():similar(0.9))
	if (table.getn(zeroInput) < 3) then
		Logger("Retrying to Click Withdraw All")
		PressRepeatNew(gatherDir.. "Withdraw All.png", gatherDir.. "Deploy Unavailable.png", 1, 2, Lower_Most_Half, Lower_Most_Half, 0.92, nil, true)
	end
	Logger("Swiping Twice")
	for i = 1, 2 do
		swipe(Location(4, 1320), Location(4, 245), .6)
		if (i == 1) then wait(0.6) end
	end
	wait(1)
	local function addCheckOCR(troopNum, input)
		wait(.5)
		Logger("Adding: " ..troopNum)
		click(input)
		wait(0.5)
		type(tostring(troopNum))
		wait(0.5)
		local troopTimer, curTroop = Timer()
		repeat curTroop = Num_OCR(input, "a") until(curTroop > 0) or (troopTimer:check() > 1)
		Logger("Troop Found: " ..curTroop)
		PressRepeatNew(Location(585,190), gatherDir.. "Deploy Unavailable.png", 1, .2, nil, Lower_Most_Half, 0.9)
		return curTroop
	end
	
	Logger("Searching for Empty Input Again")
	repeat zeroInput = findAllNoFindException(Pattern(gatherDir.. "Input 0.png"):color():similar(0.9)) until(table.getn(zeroInput) > 0)
	Logger("Input Found: " ..table.getn(zeroInput))
	local lastThree, troopsDivision, totTroops = {zeroInput[#zeroInput-2], zeroInput[#zeroInput-1], zeroInput[#zeroInput]}, 0, 0
	
	local totalResources = requiredPoints / 3
	local troop = {[1] = 0, [2] = 0, [3] = 0}
	if (RSS_Input == "Automatic") or (CHARACTER_ACCOUNT == "Alt") then
		for i, input in ipairs(lastThree) do
			if ((CHARACTER_ACCOUNT == "Main") and (Main.rssGather.requiredGathers[i] == 0)) or (CHARACTER_ACCOUNT == "Alt")then
				Logger("Initiating Troops Required: " ..i)
				while true do
					addCheckOCR(100, input)
					Logger("Reading Troop Resources OCR")
					local curRss = Num_OCR(Region(522, 182, 153, 23), "t")
					Logger("OCR Result: " ..curRss)
					deploySquadSlider(input)
					if (curRss > 0) then 
						troop[i] = curRss / 100
						Logger(string.format("Troop Required %s: %s", i, troop[i]))
						break 
					end
				end
				
				if (CHARACTER_ACCOUNT == "Main") then
					local totTroopROI = Region(input:getX() + input:getW() +10, input:getY(), 160, 38)
					local troopCount = Num_OCR(totTroopROI, "c")
					Logger(string.format("Total Troops %s: %s", i, troopCount))
					local minRequired = 4
					if (Extra_Gather_1_Status) then minRequired = minRequired + 1 end
					if (Extra_Gather_2_Status) then minRequired = minRequired + 1 end
					local troopsNeeded = math.ceil(totalResources / troop[i])
					if ((troopsNeeded * minRequired) < troopCount) then Main.rssGather.requiredGathers[i] = troopsNeeded end
				end
			end
		end
		
		Logger("Doing some Calculation to Divide required troops")
		wait(1)
		for i, input in ipairs(lastThree) do
			local troopsNeeded = math.ceil(totalResources / troop[i])
			if (CHARACTER_ACCOUNT == "Main") and (Main.rssGather.requiredGathers[i] > 0) then troopsNeeded = Main.rssGather.requiredGathers[i] end
			Logger(string.format("Troop %s: %s", i, troopsNeeded))
			while true do
				local curTroop = addCheckOCR(troopsNeeded, input)
				if (exactTroops) then
					if (curTroop == troopsNeeded) then break
					else deploySquadSlider(input) end
				else
					if (curTroop <= 100) then deploySquadSlider(input)
					elseif (curTroop > 100) and not(SingleImageWait(gatherDir.. "Input 0.png", 0, input)) then break end
				end
			end
		end
		Logger("Priority Troops Added")	
	else	
		for i, input in ipairs(lastThree) do
			Logger(string.format("Troop %s: %s", i, troopAllocation))
			while true do
				local curTroop = addCheckOCR(troopAllocation, input)
				if (exactTroops) then
					if (curTroop == troopAllocation) then break
					else deploySquadSlider(input) end
				else
					if (curTroop <= 100) then deploySquadSlider(input)
					elseif (curTroop > 100) and not(SingleImageWait(gatherDir.. "Input 0.png", 0, input)) then break end
				end
			end
		end
	end
	
end

function SearchResources(rss_Type, Gather_Status)
	Current_Function = getCurrentFunctionName()
	local Lv, Cur_RSS, RSS_Found, Iron, City, March, Side_Opened, March_Timer
	Logger("Checking RSS for " ..rss_Type)	
	City = SearchImageNew("City.png", Lower_Right, .8, true)
	if not(City.name) then
		Logger("Home Screen not found. Trying again in 60 Seconds")
		return 60 
	end
	Logger()
	if (CHARACTER_ACCOUNT == "Main") and not(Burden_Bearer_Skill) and (SearchImageNew("Burden Bearer Skill.png", Upper_Half, 0.92, true).name) then Burden_Bearer_Skill = true end
	
	Logger("Checking Side Screen")
	Side_Opened = SearchImageNew("Side Opened.png", nil, .9, true)
	if (Side_Opened.name) then
		Logger("Side screen is opened please close manually")
		Side_Opened.r:highlight(5)
		return 60 
	end
	Logger("Searching for March screen")
	March_Timer = Timer()
	repeat March = SearchImageNew({"March 2.png", "March All.png"}, Upper_Half, .85, true) until(March.name) or (March_Timer:check() > 2)
	if (March.name == "March 2") then 
		Logger("March 2 Found opening all March")
		PressRepeatNew("March 2.png", "March All.png", 1, 2, Upper_Half, Upper_Half, 0.8, true, true)
		wait(1)
	end
	----- add to check how many gathers are out
	if (useBoost) then Gathering_Speed_Boost() end

	Logger("Searching for Magnifying Glass")
	local magnify = Search_Magnifyer("Search.png")
	if not(magnify.status) then
		Logger("Magnifying Glass not found")
		return 60 
	end
	Logger("Searching for RSS Images")
	MagnifyerSearch(rss_Type)
	Logger("Searching Level for OCR")
	if not(Lv) then Lv = SearchImageNew("Level.png", Lower_Half, 0.9, true, true, 9999) end
	Starting_Level = RSS_Max_Level
	local Max_Reached = false
	while true do
		Logger("Checking Current RSS Level")
		local Cur_Lv = Num_OCR(Lv.r, "l")
		if (Cur_Lv == Starting_Level) then
			Max_Reached = true
			Logger("Searching for RSS to Gather")
			local Search_Result, Deploy, Hero_Timer, Hero, Hero_Remove, Task
			Search_Result = PressRepeatNew("Search.png", {"Gather.png", "No Suitable Target.png"}, 1, 4, Lower_Half, nil, 0.9, true, true)
			if (Search_Result.name == "Gather") then
				Logger("Gather Found and Clicking")
				Deploy = PressRepeatNew(Search_Result.xy, {"Gather Deploy.png", "March Queue Maxed.png", "March Queue Limit 2.png"}, 1, 4, nil, nil, 0.85, nil, true)
				if (Deploy.name == "Gather Deploy") then
					Logger("Searching for RSS HERO")
					--search for battle bonus
					wait(1)
					local hexResult, squadHero = multiHexColorFind(Location(652, 257), {"#0D315F", "#FFFFFF"}, 10) --0D315F (No Pet) | FFFFFF (with Pets)
					if (hexResult == "#0D315F")then
						squadHero = {[1] = {r = Region(131, 339, 79, 80), loc = Location(237, 256)}, [2] = {r = Region(320, 339, 79, 80), loc = Location(427, 256)}, [3] = {r = Region(509, 339, 79, 80), loc = Location(615, 256)}}
					else
						squadHero = {[1] = {r = Region(131, 402, 79, 80), loc = Location(237, 305)}, [2] = {r = Region(320, 402, 79, 80), loc = Location(427, 305)}, [3] = {r = Region(509, 402, 79, 80), loc = Location(615, 305)}}
					end
					
					Hero_Timer = Timer()
					repeat Hero = SearchImageNew(string.format("%s Hero.png", rss_Type), Upper_Half, 0.8, true) until(Hero.name) or (Hero_Timer:check() > 2)
					if (Hero.name) then --Hero Found
						if not(RSS_Region["RGS"].N > 0) then RSS_Stats_Checker(rss_Type) end ----- NEW
						Logger("RSS HERO Found removing Unwanted HERO")
						for i = 2, 3 do 
							if not(SearchImageNew("Resources Gathering/selectHeroes.png", squadHero[i].r).name) then
								PressRepeatNew(squadHero[i].loc, "Resources Gathering/selectHeroes.png", 1, 1, nil, squadHero[i].r)
							end
						end
						Logger("Clicking Deploy")
						---- ADD stuff to read OCR before Deploying ---- GOING TO TASK
						Task = "Deploy"
					else --Hero Not Found
						if(Gather_Status == "Extra1") or (Gather_Status == "Extra2") then -- If EXTRA
							Logger("Removing All Heroes")
							for i = 1, 3 do 
								if not(SearchImageNew("Resources Gathering/selectHeroes.png", squadHero[i].r).name) then
									PressRepeatNew(squadHero[i].loc, "Resources Gathering/selectHeroes.png", 1, 1, nil, squadHero[i].r)
								end
							end
							Task = "Deploy"
						else
							Go_Back("RSS HERO not Found Sleeping for 00:01:00")
							return 60
						end
					end
					
					if (Task == "Deploy") then
						if (Gather_Priority_Troops) then priorityGatherTroops(RSS_Capacity[Cur_Lv], rss_Type) end
						Logger("Checking March Time")
						local originalMarchTime = Get_March_Time()
						local March_Time = originalMarchTime * 2
						if (CHARACTER_ACCOUNT == "Main") and (Burden_Bearer_Skill) then Burden_Bearer_Skill = false
						else March_Time = March_Time + RSS_Time_Checker(rss_Type, Cur_Lv, Gather_Status) end
						--add new here
						Logger("Clicking Deploy")
						local Deploy_Status = PressRepeatNew("Gather Deploy.png", {"World.png", "City.png", "Other Troops Marching.png", "Other Troops Marching 2.png"}, 1, 2, Lower_Right, nil, 0.9, true, true)
						if (Deploy_Status.name == "Other Troops Marching") or (Deploy_Status.name == "Other Troops Marching 2") then
							Go_Back("Other Troops Marching Searching for New RSS")
							return 10
						end
						
						if (CHARACTER_ACCOUNT == "Main") then
							if (Gather_Status == "Hero") then 
								Main.rssGather.marchTime[rss_Type] = originalMarchTime
								preferencePutNumber("rss" ..rss_Type.. "MarchTime", originalMarchTime)
							else 
								Main.rssGather.marchTime[Gather_Status] = originalMarchTime 
								preferencePutNumber("rss" ..Gather_Status.. "MarchTime", originalMarchTime)
							end
						end
						local t = os.date("*t")
						local secondsNow = (t.hour * 3600) + (t.min * 60) + t.sec
						Logger(string.format("RSS %s: March: %s | Gather: %s | End: %s", rss_Type, Get_Time(originalMarchTime), Get_Time(March_Time - (originalMarchTime * 2)), Get_Time(secondsNow + (March_Time - originalMarchTime))))
						wait(.5)
						Message[rss_Type.."_Gather"] = Message[rss_Type.."_Gather"] + 1
						return March_Time
					end
				else
					Go_Back("March QUEUE Maxed and Closing")
					return 60
				end
			elseif (Search_Result.name == "No Suitable Target") then Starting_Level = Starting_Level - 1 end
		else
			if (Cur_Lv < Starting_Level) then 
				Logger("Clicking Plus Button")
				local Plus = SearchImageNew("Plus.png", Lower_Half, 0.8)
				Press(Plus.xy, 1)
			elseif(Cur_Lv < RSS_Min_Level) and (Max_Reached) then
				Go_Back("Closing due to minimum rss is not available")
				return 300
			else
				Logger("Clicking Minus Button")
				local Minus = SearchImageNew("Minus.png", Lower_Half, 0.8)
				Press(Minus.xy, 1)
			end
		end
	end
end

function Exploration()
	Current_Function = getCurrentFunctionName()
	Logger("Checking Exploration")
	local Exploration = SearchImageNew("Exploration.png", Lower_Most_Half, 0.9, true)
	if not(Exploration.name) then 
		Logger("Exploration Not found. Returning")
		return 60
	end
	Logger("Clicking Exploration")
	PressRepeatNew("Exploration.png", {"Claim Available.png", "Claim Available 2.png", "Claim Unavailable.png"}, 1, 2, Lower_Most_Half, nil, 0.9, true, true)
	wait(2)
	local Exploration_Status = SearchImageNew({"Claim Available.png", "Claim Available 2.png", "Claim Unavailable.png"}, Lower_Half, 0.9, true)
	if (Exploration_Status.name == "Claim Available") then
		Logger("Exploration Available")
		local Claim_Available_2 = PressRepeatNew(Exploration_Status.xy, "Claim Available 2.png", 1, 2, nil, nil, 0.8, true, true)
		Logger("Clicking Claim Available 2")
		local Tap_Anywhere = PressRepeatNew(Claim_Available_2.xy, "Tap Anywhere.png", 1, 2, nil, nil, 0.8, true, true)
		Logger("Clicking Tap Anywhere")
		PressRepeatNew(Tap_Anywhere.xy, "Claim Unavailable.png", 1, 2, nil, Lower_Half, 0.8, true, true)
	elseif (Exploration_Status.name == "Claim Available 2") then 
		Logger("Exploration Available")
		local Tap_Anywhere = PressRepeatNew(Exploration_Status.xy, "Tap Anywhere.png", 1, 2, nil, nil, 0.8, true, true)
		Logger("Clicking Tap Anywhere")
		PressRepeatNew(Tap_Anywhere.xy, "Claim Unavailable.png", 1, 2, nil, Lower_Half, 0.8, true, true)
	end
	Go_Back()
	return 21600
end

local AutoJoinX = nil
function Auto_Join(status)
	Current_Function = getCurrentFunctionName()
	local Alliance, Rally_Status
	Logger("Checking Alliance")
	Alliance = SearchImageNew("Alliance.png", Lower_Half, 0.8, true)
	if not(Alliance.name) then 
		Logger("Alliance Not found. Returning")
		return 60
	end
	Logger("Clicking Alliance")
	local War = PressRepeatNew("Alliance.png", "War.png", 1, 2, Lower_Half, Upper_Half, 0.8, true, true)
	Logger()
	Rally_Status = PressRepeatNew(War.xy, {"War Rally Clicked.png", "War Rally Unclicked.png"}, 1, 2, Upper_Half, Upper_Half, 0.8, true, true)
	if (Rally_Status.name == "War Rally Unclicked") then PressRepeatNew(Rally_Status.xy, "War Rally Clicked.png", 1, 3, Upper_Half, Upper_Half, 0.8, true, true) end
	Logger("War Screen Opened")
	local Auto_Join_Image = SearchImageNew({"Auto Join.png", "Auto Joining.png"}, Lower_Half, 0.8, true, false, 5)
	if (Auto_Join_Image.name) then
		Logger("Clicking Auto Join")
		PressRepeatNew(Auto_Join_Image.xy, "Enable.png", 1, 2, Lower_Half, Lower_Half, 0.8, true, true)
		if (status == "ON") then
			Logger("Clicking Enable")
			if (autoJoinQueueLimit == "0") then
				PressRepeatNew("Enable.png", "Stop Enabled.png", 1, 2, Lower_Half, Lower_Half, 0.8, true, true)
			else
				Logger("Reading Current Queue Limit")
				local curQueueLimit = Num_OCR(Region(528, 693, 120, 50), "s")
				Logger("Queue Limit: " ..curQueueLimit)
				while not(curQueueLimit == tonumber(autoJoinQueueLimit)) do
					if (curQueueLimit > tonumber(autoJoinQueueLimit)) then -- current is 6 required is 1
						for i = 1, (curQueueLimit - tonumber(autoJoinQueueLimit)) do 
							Press(Location(97, 718), 1)
							wait(0.1)
						end
					elseif (curQueueLimit < tonumber(autoJoinQueueLimit)) then
						for i = 1, (tonumber(autoJoinQueueLimit) - curQueueLimit) do 
							Press(Location(482, 718), 1)
							wait(0.1)
						end
					end
					curQueueLimit = Num_OCR(Region(528, 693, 120, 50), "s")
				end
				PressRepeatNew("Enable.png", "Stop Enabled.png", 1, 2, Lower_Half, Lower_Half, 0.8, true, true)
			end
		else
			Logger("Clicking Stop")
			PressRepeatNew("Stop Enabled.png", "Locked.png", 1, 2, Lower_Half, Upper_Half, 0.8, true, true)
		end
	end
	Go_Back()
	return 25200
end

function Sleep_Iter(Tot_Time)
	repeat
		Tot_Time = Tot_Time - 1
		Logger(string.format("Sleeping: %s", Get_Time(Tot_Time)))
		wait(1)
	until(Tot_Time <= 0)
end

function Auto_Reconnect_fn()
	Current_Function = getCurrentFunctionName()
	Logger("Reconnect Screen found!")
	Message.Total_Reconnect = Message.Total_Reconnect + 1
	local Recon_Screen, Recon_Screen_Timer
	local Pack_Sale = copyList(Pack_Sale_List)
	for i, v in ipairs({"World.png", "City.png"}) do table.insert(Pack_Sale, v) end
	Recon_Screen_Timer = Timer()
	Logger("Checking Reconnect Screen Type!")
	repeat
		usePreviousSnap(false)
		Recon_Screen = SearchImageNew({"Duplicate Login.png", "Connection Lost.png"}, nil, 0.85, true)
	until(Recon_Screen.name) or (Recon_Screen_Timer:check() > 5)
	if (Recon_Screen.name == "Duplicate Login") then Sleep_Iter(Auto_Reconnect_Timer * 60) end
	Logger("Clicking Reconnect")
	local attempt, Home_Screen_Status = 0, nil
	local fallbackX = math.floor(screen.x * 0.75)
	local fallbackY = math.floor(screen.y * 0.80)
	repeat
		attempt = attempt + 1
		usePreviousSnap(false)
		local reconnectBtn = SearchImageNew("Reconnect.png", Lower_Half, 0.82, true, false, 3)
		if (reconnectBtn and reconnectBtn.name) then
			Logger(string.format("Reconnect attempt %d using image %s", attempt, reconnectBtn.name))
			Press(reconnectBtn.xy, 1)
		else
			Logger(string.format("Reconnect attempt %d using fallback tap (%d,%d)", attempt, fallbackX, fallbackY))
			Press(Location(fallbackX, fallbackY), 1)
		end
		wait(2)
		usePreviousSnap(false)
		Home_Screen_Status = SearchImageNew(Pack_Sale, nil, 0.9, false)
	until(Home_Screen_Status and Home_Screen_Status.name and not string.match(Home_Screen_Status.name, "Reconnect")) or (attempt >= 3)
	Sleep_Iter(5)
	usePreviousSnap(false)
	if not(Home_Screen_Status and Home_Screen_Status.name) then
		Home_Screen_Status = SearchImageNew(Pack_Sale, nil, 0.9, false)
	end
	if (Home_Screen_Status and Home_Screen_Status.name and string.match(Home_Screen_Status.name, "Reconnect")) then
		Logger("Reconnect prompt persists after multiple attempts; will retry on next loop")
		return
	end
	if not(Home_Screen_Status and Home_Screen_Status.name) then
		Logger("Reconnect: unable to verify post-click state; will retry on next loop")
		return
	end

	if (string.match(Home_Screen_Status.name, "Pack Sale")) then 
		Logger("Pack Sale Found and Closing")
		Home_Screen_Status = PressRepeatNew(4, {"World.png", "City.png"}, 1, 2, nil, Lower_Right, 0.8, nil, true)
	else
		if (SearchImageNew(Pack_Sale_List, Lower_Half, 0.9, true, false, 2).name) then
			Logger("Other Screen Found and Closing")
			Home_Screen_Status = PressRepeatNew(4, {"World.png", "City.png"}, 1, 2, nil, Lower_Right, 0.8, nil, true)
		end
	end
	if (Home_Screen_Status.name == "World") then
		Logger("City Screen Found")
		PressRepeatNew(Home_Screen_Status.xy, "City.png", 1, 4, nil, Lower_Right, 0.8, 0.8, false, true) 
	elseif (Home_Screen_Status.name == "City") then
		Logger("World Screen Found")
		local Task
		Logger("Opening City to Clear other Popups")
		local Status = PressRepeatNew(Home_Screen_Status.xy, {"World.png", "Confirm Button.png"}, 1, 4, nil, nil, 0.8, false, true)
		if (Status.name == "World") then
			Logger("Searching for Popups!")
			local Confirm_Button = SearchImageNew("Confirm Button.png", nil, 0.9, true, false, 5)
			if (Confirm_Button.name) then Task = "Confirm" end
		else
			Task = "Confirm"
		end
		if (Task == "Confirm") then
			Logger("Popup Found and Closing")
			PressRepeatNew("Confirm Button.png", "World.png", 1, 2, nil, Lower_Right,0.9, true, true)
		end
		PressRepeatNew("World.png", "City.png", 1, 2, nil, Lower_Right,0.9, true, true)
	end
end

function Alliance_Mobilization_GUI()
	local AMQ_Folder, Cur_Iter = "Alliance Mobilization Quest/", 0
	Quest_Var = {}
	Quest_Dir = scandirNew(AMQ_Folder)
	dialogInit()
	newRow()
	addTextView("Rewards Percentage")
	addSpinner("Percentage_Status", {"120%", "200%", "Any"}, "Any")
	newRow()
	local To_Exclude = {"AM Mission refreshing.png", "AM Completed.png", "AM Completed 2.png"}
	for i, quest in ipairs(Quest_Dir) do
		if not(find_in_list(To_Exclude, quest)) then
			Cur_Iter = Cur_Iter + 1
			local cur_quest, cur_quest_var
			cur_quest = quest:gsub("AM ", ""):gsub("%.png$", "")
			cur_quest_var = cur_quest:gsub(" ", "_")
			table.insert(Quest_Var, cur_quest_var)
			addCheckBox(cur_quest_var, cur_quest, false)
			if (Cur_Iter%2 == 0) then newRow() end
		end
	end
	newRow()
	addTextView("  Minimum Points")
	addEditNumber("Min_Points", 0)
	addCheckBox("AM_Accept", "Auto Accept", false)
	addCheckBox("AM_Gems", "Use Gems", false)
	newRow()
	dialogShowFullScreen("Alliance Mobilization Options")
	for i, v in ipairs(Quest_Var) do
		local filename = string.format("%sAM %s.png", AMQ_Folder, v:gsub("_", " "))
		if (_G[v]) then table.insert(Main.AM.reqList, filename) end
	end
end

function AM_Points_Checker(Cur_Region)
	local AMP_Timer, Number, Number_Status, AMP = Timer()
	repeat
		AMP = SearchImageNew("AM +.png", Cur_Region, 0.9, true)
		if (AMP.name) then
			AMP_Num_Region = Region(AMP.sx + AMP.w, AMP.sy, 100, AMP.h)
			Number, Number_Status = numberOCRNoFindException(AMP_Num_Region, "ocr/AMP")
		else Number = 1 end
	until(Number_Status) or (AMP_Timer:check() > 10)
	return Number
end

function AM_Time_Checker(Cur_Region) -- Obsolete
	local Clock_Timer, Number, Number_Status, Clock, Time_Region, timeResult = Timer()
	repeat
		Clock = SearchImageNew("Alliance Mobilization/Clock.png", Cur_Region, 0.9, true, false, 1)
		if (Clock.name) then 
			timeResult = charTimeOCR(Region(Clock.sx + Clock.w, Clock.sy - 2, 120, Clock.h + 5), AMTimeCharTable)
		end
	until((timeResult) and (isValidTime(timeResult))) or (Clock_Timer:check() > 5)
	if (timeResult) and (isValidTime(timeResult)) then
		Logger("Time Result: " ..timeResult)
		local timeToSeconds = timeToSeconds(timeResult)
		Logger("Time to Seconds: " ..timeToSeconds)
		return {LEN = #tostring(timeResult), TIME = timeToSeconds}
	else return {LEN = #tostring(1), TIME = 1} end
end

function getLowestExpiryTime(t1, t2)
    if t1 < 0 and t2 < 0 then
        return 0  -- If both are negative, return 0
    elseif t1 < 0 then
        return math.max(0, t2)  -- If t1 is negative, return t2 (or 0 if it's also negative)
    elseif t2 < 0 then
        return math.max(0, t1)  -- If t2 is negative, return t1 (or 0 if it's also negative)
    else
        return math.min(t1, t2)  -- If both are positive, return the smallest
    end
end

function AMQ()
	local AM_Quests = {[1] = {status = true, loc = Location(200, 612)}, [2] = {status = true, loc = Location(519, 612)}}
	local Task_Status, skipChecker = {[1] = "", [2] = ""}, false
	local hexLegend = {["#A69169"] = "Refreshing", ["#F8AA45"] = "Available", ["#FFE7AC"] = "Selected", ["#7F5523"] = "Completed"}
	local refreshPatterns = {"AM Refresh Mission.png", "Alliance Mobilization/am copy/AM Refresh Mission.png"}
	local refreshConfirmPatterns = {"AM Refresh.png", "Alliance Mobilization/am copy/AM Refresh.png"}
	local acceptButtonPatterns = {"AM Accept.png", "Alliance Mobilization/am copy/AM Accept.png"}
	local buyPatterns = {"Alliance Mobilization/Buy.png", "Alliance Mobilization/am copy/Buy.png"}
	local fullPatterns = {"AM Full.png", "Alliance Mobilization/am copy/AM Full.png"}
	local attemptsPatterns = {"Attempts.png", "Alliance Mobilization/am copy/Attempts.png"}
	local questPercentPatterns = {"Alliance Mobilization/AM 120%.png", "Alliance Mobilization/AM 200%.png",
		"Alliance Mobilization/am copy/AM 120%.png", "Alliance Mobilization/am copy/AM 200%.png"}
	local refreshTimePatterns = {"Alliance Mobilization/2 Mins.png", "Alliance Mobilization/5 Mins.png",
		"Alliance Mobilization/am copy/2 Mins.png", "Alliance Mobilization/am copy/5 Mins.png"}

	local Minimum_Time = 600
	local AM_TblPreference = parseStringToTable(preferenceGetString("AM_StrPreference", '1-"task=NA,time=120,count=0,expiresAt=0"|2-"task=NA,time=120,count=0,expiresAt=0"'))
	for curExclusive, curExclusivePref in pairs(AM_TblPreference) do
		curExclusive = tonumber(curExclusive)
		if (curExclusivePref.count and curExclusivePref.count <= 2) and (curExclusivePref.expiresAt and curExclusivePref.expiresAt <= os.time()) then
			Logger("Checking Exclusive: " ..curExclusive)
			if Main.AM.Exclusive[curExclusive] and Main.AM.Exclusive[curExclusive].highlight then
				Main.AM.Exclusive[curExclusive]:highlight()
			end
			local hexResult = multiHexColorFind(AM_Quests[curExclusive].loc, {"#A69169", "#F8AA45", "#FFE7AC", "#7F5523"}, 10)
			Logger("Exclusive Hex: " .. hexResult)
			if Main.AM.Exclusive[curExclusive] and Main.AM.Exclusive[curExclusive].highlightOff then
				Main.AM.Exclusive[curExclusive]:highlightOff()
			end
			if (hexLegend[hexResult] == "Refreshing") then --Refreshing
				curExclusivePref.task, skipChecker = "Refreshing", false
			elseif (hexLegend[hexResult] == "Selected") then-- Active Selected
				curExclusivePref.task, Minimum_Time, skipChecker = "Skip", 600, true -- DO NOTHING
			elseif (hexLegend[hexResult] == "Completed") then-- Completed
				Logger("Claiming Completed Quest")
				PressRepeatHexColor(Main.AM.Exclusive[curExclusive], AM_Quests[curExclusive].loc, "#A69169", 10, 2)
				curExclusivePref.task, skipChecker = "Refreshing", false
			elseif (hexLegend[hexResult] == "Available") then-- Available -- To Refresh
				skipChecker = false
				local wantedQuest = SearchImageNew(Main.AM.reqList, Main.AM.Exclusive[curExclusive], 0.85)
				if (wantedQuest and wantedQuest.name) then --Search if your wanted quest is found
					Logger("Wanted quest detected: " .. tostring(wantedQuest.name))
					if wantedQuest.r and wantedQuest.r.highlight then wantedQuest.r:highlight(1) end
					Logger("Percentage Selected: ".. Percentage_Status)
					if (Percentage_Status == "Any") then curExclusivePref.task = "Accept"
					else
						Logger("Searching Current Quest Percentage")
						local Percentage_Found = SearchImageNew(questPercentPatterns, Main.AM.Exclusive[curExclusive], 0.85)
						if Percentage_Found and Percentage_Found.name then
							local Percentage_Final = Percentage_Found.name:gsub("AM ", "")
							Logger("Quest Percent Found: " ..Percentage_Final)
							if (Percentage_Status == Percentage_Final) then curExclusivePref.task = "Accept" else curExclusivePref.task = "Refresh" end
						else
							Logger("Quest percentage badge not found; deferring to refresh")
							curExclusivePref.task = "Refresh"
						end
					end
					if wantedQuest.r and wantedQuest.r.highlightOff then wantedQuest.r:highlightOff() end
				else 
					Logger("Desired quest not present; scheduling refresh")
					curExclusivePref.task = "Refresh" 
				end
			end

			if (curExclusivePref.task == "Refreshing") then
				local refreshHexLegend = {["#A69169"] = "Completed", ["#FFB80F"] = "Refresh Now"}
				local refreshStatus = multiHexColorFind(Location(Main.AM.Exclusive[curExclusive].x + 70, Main.AM.Exclusive[curExclusive].y + 200), {"#FFB80F", "#A69169"}, 10)
				if (refreshHexLegend[refreshStatus] == "Completed") then Minimum_Time = Get_Time_Difference() end
				if (refreshHexLegend[refreshStatus] == "Refresh Now") then 
					Minimum_Time = 120
					if (curExclusivePref.count == 1) then Minimum_Time = 300 end
				end
				-- add if 2nd exclusive is completed and first exclusive status is claim then claim the first one first before going home 
			end
						
			if (curExclusivePref.task == "Accept") then
				Logger("Quest Found")
				local currentQuestPoints = AM_Points_Checker(Main.AM.Exclusive[curExclusive])
				if (currentQuestPoints >= Min_Points) then	----------- MINIMUM POINTS --------------
					Logger(string.format("Quest Points: %s | Min Points: %s", currentQuestPoints, Min_Points))
					if (AM_Accept) and (AM_Quests[curExclusive].status) then
						Logger("Accepting Quest")
						PressRepeatNew(Main.AM.Exclusive[curExclusive], acceptButtonPatterns, 1, 2, false, false, 0.9, false, true)
						local acceptResult = PressRepeatNew(acceptButtonPatterns, {
							"AM Full.png", "Alliance Mobilization/am copy/AM Full.png",
							"Attempts.png", "Alliance Mobilization/am copy/Attempts.png",
							"Alliance Mobilization/Buy.png", "Alliance Mobilization/am copy/Buy.png"
						}, 1, 2, false, false, 0.9, true, true)
						Logger("Quest Result: " ..acceptResult.name)
						if (acceptResult.name == "Buy" or acceptResult.name == "Alliance Mobilization/am copy/Buy") then
							if (AM_Gems) then
								Logger("Buying Additional Attempts")
								PressRepeatHexColor(Location(362, 884), Location(278, 564), {"#22588C"}, 5, 3) --clicking Buy
								Minimum_Time = 600
								curExclusivePref.count, curExclusivePref.task = curExclusivePref.count + 1, "Active"
							else
								Logger("Attempts Not Available")
								PressRepeatHexColor(Location(350, 350), Location(278, 564), {"#22588C"}, 5, 0.5)
								Minimum_Time = Get_Time_Difference()
							end
						elseif (acceptResult.name == "AM Full") then
							Minimum_Time = 600
						end
					else
						Minimum_Time = 600
					end
					AM_Quests[curExclusive].status = false
				else curExclusivePref.task = "Refresh" end
			end
			
			if (curExclusivePref.task == "Refresh") then 
				Logger("Refreshing Quest")
				PressRepeatNew(Main.AM.Exclusive[curExclusive], refreshPatterns, 1, 2, false, false, 0.9, false, true)
				PressRepeatNew(refreshPatterns, refreshConfirmPatterns, 1, 2, false, false, 0.9, true, true)
				local refreshingTime = SearchImageNew(refreshTimePatterns, nil, 0.9, true, false, 9999999)
				PressRepeatNew(refreshConfirmPatterns, attemptsPatterns, 1, 2, false, false, 0.9, true, true)
				Minimum_Time = 120
				if refreshingTime and refreshingTime.name and refreshingTime.name:find("5") then 
					Minimum_Time, curExclusivePref.count = 300, 1
				end
			end
			
			if (curExclusivePref.task == "Skip") then 
				AM_Quests[curExclusive].status = false
				curExclusivePref.task = "Active"
				Minimum_Time = 600
			end
			curExclusivePref.time, curExclusivePref.expiresAt = Minimum_Time, os.time() + Minimum_Time
		end -- end of IF
	end --end of For
	preferencePutString("AM_StrPreference", tableToString(AM_TblPreference))
	Minimum_Time = AM_TblPreference["1"]["time"]
	if (AM_TblPreference["2"]["time"] < Minimum_Time) then Minimum_Time = AM_TblPreference["2"]["time"] end
	local expiryTime1, expiryTime2 = AM_TblPreference["1"]["expiresAt"] - os.time(), AM_TblPreference["2"]["expiresAt"] - os.time()
	local expiryTime = getLowestExpiryTime(expiryTime1, expiryTime2)
	if (expiryTime > 0) then return expiryTime end
	return Minimum_Time
end

function Alliance_Mobilization()
	Current_Function = getCurrentFunctionName()
	Logger("Checking Alliance Mobilization")
	local Events_Logo = SearchImageNew("Event logo.png", Upper_Half, 0.9, true, false)
	if not(Events_Logo.name) then
		Logger("Events screen not found")
		return 10
	end

	local amLogoPatterns = {"AM Logo.png", "Alliance Mobilization/am copy/AM Logo.png", "Alliance Mobilization/am copy/AM Logo1.png"}
	local amScreenPatterns = {"Alliance Mobilization.png", "Alliance Mobilization/am copy/Alliance Mobilization.png"}

	local AM_Completed, Current_Events = false
	Logger("Checking for Alliance Mobilization Screen")
	if not(SearchImageNew(amScreenPatterns, Upper_Half, 0.9, true).name) then
		Logger("Pressing Events")
		PressRepeatNew(Events_Logo.xy, "Events.png", 1, 2, Upper_Half, Upper_Half, 0.9, true, true)
		Logger("Searching for Alliance Mobilization")
		local Alliance_Mob, All_Events = nil, {}
		Alliance_Mob = SearchImageNew(amLogoPatterns, Upper_Half, 0.9, true)
		if not(Alliance_Mob.name) then
			local Events_Folder = "Events/"
			for _, event in ipairs(scandirNew(Events_Folder)) do
				table.insert(All_Events, Events_Folder .. event)
			end
			local Location_1_X, Location_1_Y = Location(ranNumbers(360, 10), 143), Location(360 + 150, 143)
			local Location_2_X, Location_2_Y = Location(ranNumbers(360, 10), 143), Location(360 - 150, 143)
			local Final_Loc1, Final_Loc2 = Location_1_X, Location_1_Y
			local swipeAttempts, swipeLimit = 0, 12
			Logger("Swiping and Looking for Alliance Mobilization")
			repeat
				swipeAttempts = swipeAttempts + 1
				local xCurrent, xStart = {350, 360, 370}, 360
				for i = 1, 3 do
					if not(isColorWithinThresholdHex(Location(xCurrent[i], 143), "#111C40", 10)) then
						xStart = xCurrent[i]
						break
					end
				end
				swipe(Location(xStart, 143), Final_Loc2, .8)
				wait(1)
				Alliance_Mob = SearchImageNew(amLogoPatterns, Upper_Half, 0.9, true)
				if (SearchImageNew("Events/Calendar.png", Upper_Half, 0.9, true).name) then
					Logger("Calendar Found Swiping Right")
					Final_Loc1, Final_Loc2 = Location_2_X, Location_2_Y
				end
				if (Final_Loc2 == Location_2_Y) and (SearchImageNew("Events/Community.png", Upper_Right, 0.9, true).name) then
					Logger("Community found")
					Go_Back("Alliance Mobilization is Unavailable")
					AM_Enabled = false
					return 0
				end
			until(Alliance_Mob.name or swipeAttempts >= swipeLimit)

			if not(Alliance_Mob and Alliance_Mob.name) then
				Logger("Alliance Mobilization logo not found after swipes; exiting")
				Go_Back("Alliance Mobilization not located")
				AM_Enabled = false
				return 0
			end
			Logger("Clicking Alliance Mobilization")
		end
		if Alliance_Mob and Alliance_Mob.xy then
			if Alliance_Mob.r then Alliance_Mob.r:highlight(1) end
			click(Alliance_Mob.xy)
			wait(0.3)
			if Alliance_Mob.r then Alliance_Mob.r:highlightOff() end
		end
		PressRepeatNew(amLogoPatterns, amScreenPatterns, 1, 2, Upper_Half, Upper_Half, 0.9, true, true)
	end

	local AMStatus = SearchImageNew({"Alliance Mobilization/Clock 2.png", "Alliance Mobilization/Tally.png"}, Upper_Left, 0.9, true, false, 9999999)
	if (AMStatus.name) and (AMStatus.name == "Tally") then
		AM_Enabled = false
		Go_Back("Alliance Mobilization Tally Stage")
		return 0
	elseif not(AMStatus.name) then
		Go_Back("Cannot Identify AM Status")
		AM_Enabled = false
		return 0
	end

	local AM_Quests = {[1] = {status = true, loc = Location(200, 612)}, [2] = {status = true, loc = Location(519, 612)}}
	local Complete_Trigger, Minimum_Time, AMQ_Folder = 0, 0, "Alliance Mobilization Quest/"
	local plusRegion = Region(400, 511, 115, 70)
	local plus = SingleImageWait("Alliance Mobilization/Plus.png", 999999999, plusRegion)
	if plus then
		plusRegion:highlight(1)
		if (isColorWithinThresholdHex(Location(plus.x + 33, plus.y - 7), "#FF1E22", 5)) then
			Logger("Red Dot Found and Claiming")
			PressRepeatHexColor(plus, Location(434, 895), {"#25B756"}, 5, 2)
			PressRepeatHexColor(Location(434, 895), Location(278, 564), {"#22588C"}, 5, 2)
			Logger("Red Dot Claimed")
		end
		plusRegion:highlightOff()
	end
	
	Minimum_Time = AMQ()
	Go_Back("Rechecking: " ..Get_Time(Minimum_Time))
	return Minimum_Time
end

function myIslandGoBack()
	Logger("Going Back to City")
	while true do
		Logger("Clicking City")
		Press("City.png", 1)
		Logger("Searching for Chief Order Image")
		local cityScreen = SingleImageWait(Main.Chief_Order_Event.dir.. "Chief Order Button.png", 5, Region(629, 1067, 70, 260), 0.9, true)
		if (cityScreen) then break end
	end
	Logger("Going back to World")
	while true do
		Logger("Clicking World")
		Press("World.png", 1)
		Logger("Searching for City Image")
		local cityScreen = SingleImageWait("City.png", 5, Region(screen.x - 120, screen.y - 112, 120, 112), 0.9, true)
		if (cityScreen) then break end
	end	
	Logger("Going back Completed")
end

function swipenFindDot()
	local DaybreakDir = "Daybreak Island/"
	Logger()
	PressRepeatNew(DaybreakDir.. "Trophy.png", DaybreakDir.. "Your Alliance.png", 1, 2, Upper_Right, Upper_Half, 0.9, false, true) --to delete Dot Available.png
	wait(2)
	local dotStatus = SearchImageNew({DaybreakDir.. "Dot Available.png", DaybreakDir.. "Dot Unavailable.png"}, Upper_Half, 0.9, true, false, 99999)
	if (dotStatus.name == "Dot Unavailable") then
		Logger("Dot No Longer Available")
		return false
	end
	Logger("Waiting for Screen to Load")
	while true do
		Logger("Searching for Red Dot")
		local dot = SingleImageWait(DaybreakDir.. "Dot.png", 1)
		if (dot) then
			Logger("Red dot found and clicking")
			--PressRepeatNew(Location(dot:getX(), dot:getY() + dot:getH()), {"Island Exclamation.png", "Daybreak Island Tag Disabled.png"}, 1, 5, nil, Upper_Left, 0.9, true, true)
			PressRepeatNew(Location(dot:getX(), dot:getY() + dot:getH()), DaybreakDir.. "Tree Icon.png", 1, 5, nil, Lower_Right, 0.9)
			Logger("Zooming Out")
			wait(3)
			zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
			wait(1)
			zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
			Logger("Waiting for Chief Island Help")
			local Chief_Island_Help = SearchImageNew("Chief Island Help.png", nil, 0.9, true, true, 10)
			if (Chief_Island_Help.name) then
				if (CHARACTER_ACCOUNT == "Main") then
					Logger("Trying to Check Visit Count")
					local Visit_Island_Count = SearchImageNew({"Visit Island 1.png", "Visit Island 2.png", "Visit Island 3.png"}, Lower_Right, 0.75, true, false)
					if (Visit_Island_Count.name) then
						Logger("Visit Count Found: " ..Visit_Island_Count.name)
						local count_gsub = Visit_Island_Count.name:gsub("Visit Island ", "")
						Chief_Island_Claims = tonumber(count_gsub) - 1
					else
						Logger("Visit Count Not Found")
						Chief_Island_Claims = Chief_Island_Claims - 1 
					end
				end
				Logger("Pressing Help Button")
				Press(Chief_Island_Help.xy, 1) 
				wait(0.2)
				Logger("Pressing Help Button")
				Press(Chief_Island_Help.xy, 1)
				wait(1)
				break
			end
		else
			Logger("Red dot not found and swiping")
			swipe(Location(700, 760), Location(700, 310), 1)
			wait(.2)
			click(Location(700, 760))
			Logger("clicking to stop further swipe 1")
			wait(.2)
			click(Location(700, 760))
			Logger("clicking to stop further swipe 2")
			wait(2)
		end
		Logger()
		local dotStatus = SearchImageNew({DaybreakDir.. "Dot Available.png", DaybreakDir.. "Dot Unavailable.png"}, Upper_Half, 0.9, true, false, 99999)
		if (dotStatus.name == "Dot Unavailable") then break end
	end
end

function myIslandFreeClaims()
	local trophyDotTrigger = false
	while true do
		local DaybreakDir = "Daybreak Island/"
		Logger()
		local trophy = SingleImageWait(DaybreakDir.. "Trophy.png", 999999)
		local trophyDotROI = Region(trophy:getX() + trophy:getW() + 5, trophy:getY() - trophy:getH() - 22, 25, 25)
		local trophyDot = SingleImageWait(DaybreakDir.. "Trophy Dot.png", 2, trophyDotROI, 0.9, true)
		local dotX, dotY = trophyDotROI:getCenter():getX(), trophyDotROI:getCenter():getY()
		local r, g, b = getColor(Location(dotX, dotY))
		local colorTrigger = isColorWithinThreshold(r, g, b, 255, 30, 31, 5)
		if (trophyDot) and (colorTrigger) then
			trophyDotTrigger = true
			Logger("Trophy Dot Found!")
			swipenFindDot()
			Logger("Swipe n Find Dot Completed")
			wait(2)
		else
			Logger("Trophy Dot No Longer Available! Going Back to City")
			if (trophyDotTrigger) then PressRepeatNew(Location(45, 27), "City.png", 1, 6, nil, Lower_Most_Half, 0.9, false, true) end
			break
		end
	end
end

function My_Island()
	Current_Function = getCurrentFunctionName()
	Logger("Starting My Island")
	if not (Side_Check_Opener()) then return 300 end
		
	Logger("Searching Image for Troop Training")
	local Troop_Training = SearchImageNew("Troop Training.png", nil, 0.9, true, false, 1)
	if not(Troop_Training.name) then
		Logger("Troop Training NOT Found! Closing")
		PressRepeatSingle("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	
	local treeOfLife = SingleImageWait("Tree of Life.png", 0, nil, 0.9, true)
	Logger("Searching for Tree of Life")
	if not(treeOfLife) then
		while true do
			swipe(Location(6, 845), Location(6, 10), .5)
				wait(.2)
				Press(Location(6, 845), 1)
				wait(.2)
				Press(Location(6, 845), 1)
			treeOfLife = SingleImageWait("Tree of Life.png", 1, nil, 0.9, true)
			if (treeOfLife) then break end
		end
	end
	wait(1)
	Logger("Tree of Life Found and Clicking!")
	PressRepeatSingle("Tree of Life.png", "Island Storehouse.png", 1, 1, nil, Lower_Left, 0.9)
	Logger("Zooming Out 1")
	zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
	if not(SearchImageNew("Island Rocks.png", nil, 0.9, true, false, 2).name) then
		Logger("Zooming Out 2")
		zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
	end
	Logger("Searching for Life Essence")
	local Essence_Timer = Timer()
	local essenceClaimed = false
	while true do
		local Life_Essence = SearchImageNew("Island Life Essence.png", Region(0, 100, screen.x, screen.y), 0.9, true)
		if (Life_Essence.name) then 
			Logger("Life Essence Found and Claiming")	
			Press(Life_Essence.xy, 1)
			wait(1)
			Essence_Timer:set()
			essenceClaimed = true
		else if (Essence_Timer:check() > 2) then break end end
	end
	if (essenceClaimed) then
		Logger("Attempting to claim Daybreak freebie after essence")
		Claim_Daybreak_Freebie()
	end
	
	if (find_in_list({"Island Treasure", "All"}, mainDaybreakIslandOption)) then	
		Logger("Checking for Island Treasure")
		while true do
			PressRepeatSingle(string.format("%s,%s", 582,33), "My Island Treasure.png", 1, 4, nil, nil, 0.90, true)
			wait(2)
			local mitROI = SingleImageWait("My Island Treasure.png", 99999, nil, 0.9, true)
			My_Island_Treasure = PressRepeatNew("My Island Go.png", {"Island Storehouse.png", "No Island Treasure Found.png"}, 1, 4, Region(mitROI:getX(), mitROI:getY(), screen.x - mitROI:getX() - mitROI:getW(), mitROI:getH()), nil, 0.90, false, true)
			if (My_Island_Treasure.name == "Island Storehouse") then 
				PressRepeatSingle(Location(screen.x/2, screen.y/2), "Tap Anywhere.png", 1, 4)
				PressRepeatSingle("Tap Anywhere.png", "My Island Obtain More.png", 1, 4)
			else
				PressRepeatSingle(4, "My Island Obtain More.png", 1, 4)
				break
			end
		end
	end
	if (find_in_list({"Help Other", "All"}, mainDaybreakIslandOption)) then	
		Logger("Checking for Available Island Claim")
		----------------check for free claims ------------
		if (Chief_Island_Claims > 0) then myIslandFreeClaims() end
	end
	myIslandGoBack()
	return Auto_My_Island_Timer
end
------free bee island starts here 
-- Scenario: After Daybreak Island claims essence, open Buy and grab the freebie, then go back.
function Claim_Daybreak_Freebie()
	Logger("Claim_Daybreak_Freebie: starting")

	local buyBtn = SearchImageNew("buy.png", nil, 0.9, true, false, 4)
	if not (buyBtn and buyBtn.xy) then
		Logger("Claim_Daybreak_Freebie: buy.png not found - skipping freebie flow")
		return false
	end
	Logger("Claim_Daybreak_Freebie: buy.png found, clicking")
	Press(buyBtn.xy, 1)
	wait(0.6)

	Logger("Claim_Daybreak_Freebie: searching free Btn")
	local freeFull = SearchImageNew("free.png", nil, 0.9, true, false, 4)
	if not (freeFull and freeFull.xy) then
		Logger("Claim_Daybreak_Freebie: free.png not found - returning to Island view")
		local backBtn = SearchImageNew("trek/back.png", Upper_Half, 0.9, true, false, 3)
		if backBtn and backBtn.xy then
			Press(backBtn.xy, 1)
			wait(0.3)
		end
		return false
	end
	Logger("Claim_Daybreak_Freebie: free Btn found, clicking")
	Press(freeFull.xy, 1)
	wait(0.5)

	Logger("Claim_Daybreak_Freebie: searching free 1")
	local freeConfirm = SearchImageNew("free1.png", Lower_Half, 0.9, true, false, 3)
	if freeConfirm and freeConfirm.xy then
		Logger("Claim_Daybreak_Freebie: free1.png found, clicking")
		Press(freeConfirm.xy, 1)
		wait(0.5)
	else
		Logger("Claim_Daybreak_Freebie: free1.png not found - continuing")
	end

	Logger("Claim_Daybreak_Freebie: tapping Back ")
	local backBtn = SearchImageNew("trek/back.png", Upper_Left, 0.9, true, false, 3)
	if backBtn and backBtn.xy then
		Press(backBtn.xy, 1)
		wait(0.3)
	else
		Logger("Claim_Daybreak_Freebie: back button not found - invoking Go_Back fallback")
		Go_Back("Daybreak freebie fallback")
	end

	SearchImageNew("Island Storehouse.png", Lower_Left, 0.9, true, false, 3)
	Logger("Claim_Daybreak_Freebie: done")
	return true
end
------ free bee island ends here
---
function Check_OCR_Slider(i, Cur_Bar, ToT_Frame)
	Logger(string.format("Checking Troop %s", i))	
	local OCR_Counter = 0
	local ROI = Region(Cur_Bar:getX(), Cur_Bar:getY(), Cur_Bar:getW(), Cur_Bar:getH())
	ROI:highlight()
	while true do
		local Number, Number_Status = numberOCRNoFindException(ROI, "ocr/a")
		ROI:highlightOff()
		Logger(string.format("Checking Troop %s | Found: %s", i, Number))	
		if (Number_Status) then
			if (Number < Total[i]) and (Number > 0) and not(SearchImageNew("Slider Maxed.png", Region(Cur_Bar:getX() - (Cur_Bar:getW()/1.5), Cur_Bar:getY(), Cur_Bar:getW(), Cur_Bar:getH()), 0.90).name) then -- Let's Say number is 25 and should be 50
				Logger("Search and Swiping Slider")	
				Slider_Button = SearchImageNew("Slider Button.png", Region(10, Cur_Bar:getY(), screen.x - 20, Cur_Bar:getH()), 0.90)
				if (Slider_Button.name) then swipe(Location(Slider_Button.x, Slider_Button.y), Location(8, Slider_Button.y), .5) end
			elseif (Number < Total[i]) and (Number == 0) then -- Number is 0
				Logger("Adding Required Number")
				wait(0.3)
				type(Location(Cur_Bar:getCenter():getX(), Cur_Bar:getCenter():getY()), tostring(Total[i]))
				wait(0.3)
				if not(Severely_Injured_Btn) then Severely_Injured_Btn = SearchImageNew("Severely Injured.png", Upper_Half, 0.9, true) end
				PressRepeatNew(Severely_Injured_Btn.xy, "Quick Select.png", 1, .2, nil, Lower_Half, 0.9, false, true)
				--Press(string.format("%s,%s", Cur_Bar:getCenter():getX(), Cur_Bar:getCenter():getY()), 1)
			elseif (Number == Total[i]) or (SearchImageNew("Slider Maxed.png", Region(Cur_Bar:getX() - (Cur_Bar:getW()/1.5), Cur_Bar:getY(), Cur_Bar:getW(), Cur_Bar:getH()), 0.95).name) then -- Do nothing
				Logger("Required Number Added")
				break
			end
		else
			OCR_Counter = OCR_Counter + 1
			if (OCR_Counter == 5) then break end
		end
	end
	OCR_Counter = nil
end

function Check_Injured_Region(Heal_Frame)
	local status = true
	for i = table.getn(Heal_Frame), 1, -1 do
		local Injured_Region = Region(Heal_Frame[i]:getX(), Heal_Frame[i]:getY(), Heal_Frame[i]:getW(), Heal_Frame[i]:getH())
		local Number, Number_Status = numberOCRNoFindException(Injured_Region, "ocr/a")
		if (Number_Status) then
			if (Number > Total[i]) then
				status = false 
				break
			elseif (Number == 0) then
				status = false 
				break
			end
		end
	end
	return {stats = status, reg = Injured_Region}
end

function ordinal(n)
    local suffix = {"st", "nd", "rd"}
    local digit = n % 10
    if n >= 11 and n <= 13 then
        return n .. "th"
    else
        return n .. (suffix[digit] or "th")
    end
end

function Get_Injured_Troops()
	--snapshotColor()
	if not(Severely_Injured) then Severely_Injured = SearchImageNew("Severely Injured.png", Upper_Half, 0.9, true, false, 99) end
	local Severely_Injured_Divider = SearchImageNew("Severely Injured Divider.png", Upper_Half, 0.9, true, false, 99)
	local Number, Number_Status
	repeat Number, Number_Status = numberOCRNoFindException(Region(Severely_Injured.sx, Severely_Injured_Divider.sy, Severely_Injured_Divider.sx - Severely_Injured.sx, Severely_Injured_Divider.h), "ocr/SI") until(Number_Status)
	--usePreviousSnap(false)
	Current_Injured = Number
end

function newHeal(quickHealBtn)
	function severelyInjuredOCR()
		if (isColorWithinThresholdHex(Location(500, 532), "#D0DDF0", 5)) then
			local injuredOCR = Char_OCR(Region(155, 508, 300, 37), rallyTeamCharTable)
			Logger("OCR Result: " ..injuredOCR)
			local splitOCR = Split(injuredOCR, "/")
			if (#splitOCR == 2) and (#splitOCR[2] > 0) then
				if (splitOCR[2] == "∞") then
					Current_Injured = tonumber(splitOCR[1]) 
					return true
				elseif (maxInjured) and (maxInjured == tonumber(splitOCR[2])) then 
					Current_Injured = tonumber(splitOCR[1]) 
					return true
				end
				if not(maxInjured) then maxInjured = tonumber(splitOCR[2]) end
			else wait(1) end
		else wait(1) end
		return false
	end
	
	healDir = "Heal/"
	Current_Function = getCurrentFunctionName()
	if not(quickHealBtn) then quickHealBtn = SingleImageWait(healDir.. "Quick Heal Btn.png", 0, eventROI, 0.9) end
	if not(quickHealBtn) then return 0 end --NA
	--local healInjuredLabel = PressRepeatNew(quickHealBtn, healDir.. "Heal Injured.png", 1, 2, nil, Upper_Half)
	PressRepeatHexColor(quickHealBtn, Location(372, 1156), "#FFB80F", 5, 2)
	
	Logger("Taking Snapshot and Searching for Heal Button")
	--local healBtn = SingleImageWait(healDir.. "Heal.png", 9999999, Lower_Half, 0.9)
	if (Map_Options) and (find_in_list({"SFC", "Attack"}, Maps_Option_Type)) and (Attack_Heal) then 
		Logger("Running OCR on Currently Injured")
		while true do
			if (severelyInjuredOCR()) then break end
		end
		
	end
	snapshotColor()
	if (Heal_Status == "Auto") then
		Logger("Auto Heal Starting")
		local gemsROI = Region(228, 1175, 171, 36)
		Logger("Running OCR on Current GEMS")
		local Current_Gems = Num_OCR(gemsROI, "newHeal")
		Logger(string.format("Gems Found: %s | Required: %s", Current_Gems, Current_Heal_Gem))
		if (Current_Gems > Current_Heal_Gem) then --need to press quick select but need to count troop type
			local troopLocation, Troop_Type_Count = {Location(600, 580), Location(600, 723), Location(600, 866)}, 0
			Logger("Counting Available Troop Type to Heal")
			for i = 3, 1, -1 do
				if not(isColorWithinThresholdHex(troopLocation[i], "#F3FDFF", 5)) then
					Troop_Type_Count = i
					break
				end
			end
			--if not(Quick_Select_Btn) then Quick_Select_Btn = SearchImageNew(healDir.. "Quick Select.png", Lower_Left) end
			usePreviousSnap(false)
			local Total = {First_Total, Second_Total, Third_Total}
			if (Auto_Allocate) then Total = {math.floor(Allocate_Total / Troop_Type_Count), math.floor(Allocate_Total / Troop_Type_Count), math.floor(Allocate_Total / Troop_Type_Count)} end
			Logger("Pressing Quick Select to remove all current heals")
			--PressRepeatNew(Quick_Select_Btn.xy, healDir.. "Select a target.png", 1, .8, nil, Lower_Half, 0.9)
			PressRepeatHexColor(Location(106, 1178), Location(560, 1156), "#697079", 5, .8)
			local troopROI = {Region(480, 615, 124, 54), Region(480, 758, 124, 54), Region(480, 901, 124, 54)}
			for i = 1, Troop_Type_Count do
				while true do
					local Current_Troop = Num_OCR(troopROI[i], "a")
					Logger(string.format("Checking Troop %s | Found: %s", i, Current_Troop))	
					if (Current_Troop < Total[i]) and (Current_Troop == 0) then -- Number is 0
						Logger("Adding Required Number")
						--Press(troopROI[i], 1)
						click(troopROI[i])
						wait(0.5)
						type(tostring(Total[i]))
						local troopTimer, curTroop = Timer()
						repeat curTroop = Num_OCR(troopROI[i], "a") until(curTroop > 0) or (troopTimer:check() > 1)
						--PressRepeatNew(Location(341, 434), healDir.. "Quick Select.png", 1, .2, nil, Lower_Half, 0.9, false, true)
						PressRepeatHexColor(Location(341, 434), Location(600, 1513), "#5276AF", 5, .8)
					elseif (Current_Troop == Total[i]) or ((Total[i] > 0) and not(Current_Troop == 0)) then -- Do nothing
						Logger("Required Number Added")
						break
					end
				end
			end
			Current_Heal_Gem = Num_OCR(gemsROI, "newHeal")
		end
	end
	usePreviousSnap(false)
	local Task
	if (Attack_Heal) and (Spam_Heal) then
		Logger(string.format("Current: %s | Required: %s | MinSpam: %s", Current_Injured, Required_Injured, minSpamHeal))
		if (Current_Injured > Required_Injured) then Task = "SpamHeal"
		elseif (Current_Injured > minSpamHeal) and (Maps_Current_Iteration > 1) then Task = "healOnly" end
		Logger("Generating Healing Task")
		local function SpamHeal(totalHealing, typeOfHeal)
			while true do
				if (severelyInjuredOCR()) then break end
			end
					
			local requiredHealing = Current_Injured - typeOfHeal
			Logger(string.format("Required Healing %s", requiredHealing))
			local batches = math.ceil(requiredHealing / totalHealing)
			Logger(string.format("Total Batches %s", batches))
			local total_time = batches * healTimebyBatch
			Logger(string.format("Required Time to Heal All Batches %s", Get_Time(total_time)))
			local healTimer = Timer()
			Logger("Spamming Heal")
			while true do
				if (Enable_Label) then Label_Region:highlightUpdate("Remaining Time: " ..Get_Time(total_time - healTimer:check())) end
				click(Location(523, 1165))
				if (healTimer:check() >= total_time) then break end
			end
			if (SingleImageWait(healDir.. "Ask Help.png", 1, Region(422, 1133, 192, 86), 0.9)) then click(Location(523, 1165)) end
			Logger()
		end
		
		if (Task) then
			Logger("Starting Task: " ..Task)
			local totalHealing
			if (Auto_Allocate) then totalHealing = Allocate_Total end
			
			if (Task == "healOnly") then
				SpamHeal(totalHealing, minSpamHeal)
				while true do
					if (severelyInjuredOCR()) then break end
				end
				if (Current_Injured > Required_Injured) then Task = "SpamHeal" end --check ocr again current_injured gave 1 false positive
			end
			
			if (Task == "SpamHeal") then
				while true do
					while true do
						if (severelyInjuredOCR()) then break end
					end
					if (Current_Injured <= Required_Injured) then break 
					else SpamHeal(totalHealing, Required_Injured) end
				end
			end
			Logger("Current Injured: " ..Current_Injured)
		end
	end
	
	if not(Task) then
		Logger("Pressing Heal/Help")
		--PressRepeatNew(healDir.. "Heal.png", healDir.. "Ask Help.png", 1, 1, Lower_Half, Lower_Half, 0.9, true, true)
		PressRepeatHexColor(Location(523, 1165), Location(106, 1178), "#FF6600", 5, 2)
		click(Location(523, 1165))
	end
	while true do
		Press(TargetOffset(Location(341, 434), "0", "-100"), 1)
		if (Region(242, 405, 205, 66):waitVanish(Pattern(healDir.. "Heal Injured.png"):similar(0.9), .5)) then break end
	end
end

function Go_Coordinates(x,y)
	Logger("Searching for Bookmarks")
	local Find_Coordinates = {X=x, Y=y}
	local Bookmark_Star = SearchImageNew("Bookmarks Star.png", Lower_Half, 0.9, true)
	Logger("Opening Coordinates")
	PressRepeatNew(TargetOffset(Bookmark_Star.xy, string.format("-%s", (Bookmark_Star.w*2)), "0"), "Coordinates Go.png", 1, 4, Lower_Half, nil, 0.9, true, true)
	for i, coords in ipairs({"Coordinates X", "Coordinates Y"}) do
		Logger("Checking " ..coords)
		local Current_Coord = SearchImageNew(coords.. ".png", nil, 0.9, true, true, 99)
		local Number, OCR_Status = numberOCRNoFindException(Region(Current_Coord.sx + Current_Coord.w, Current_Coord.sy, Current_Coord.w * 2.5, Current_Coord.h), "ocr/a")
		Logger(coords.. ": " .. Number)
		local xy = x
		if (coords == "Coordinates Y") then xy = y end
		if not(Number == xy) then
			Logger("Required Coordinates not Found. Adding Manually")
			local Chat_OK1, Chat_OK = PressRepeatNew(TargetOffset(Current_Coord.xy, tostring(Current_Coord.w), "0"), {"Chat OK.png", "Chat OK2.png"}, 1, 4, nil, nil, 0.9, false, false)
			Logger("Searching for Pixel Colors")
			repeat Chat_OK = SearchImageNew({"Chat OK.png", "Chat OK2.png"}, nil, 0.9, true) until(Chat_OK.name) and (Chat_OK1.sy == Chat_OK.sy)
			if not(Chat_XY_Location) then
			Chat_XY_Location = findPixelTarget(Region(20, Chat_OK.sy, Chat_OK.w * 2,  Chat_OK.h),1, 1) end
			Logger("Pixel Colors found and Clicking")
			doubleClick(Chat_XY_Location)
			local coord_gsub = coords:gsub("Coordinates ", "")
			Logger("Adding: " ..tostring(Find_Coordinates[coord_gsub]))
			type(tostring(Find_Coordinates[coord_gsub]))
			wait(.3)
			Logger("Closing Chat")
			PressRepeatNot(Chat_OK.xy, {"Chat OK.png", "Chat OK2.png"}, 1, 2)
		end
	end
	Logger("Clicking Go Button")
	PressRepeatNew("Coordinates Go.png", "City.png", 1, 2, nil, Lower_Right, 0.9, false, true)
	Logger("Clicking Middle Screen until Additional Option is found")
	local result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), {"Scout Option.png", "City Attack.png", "Garrison.png", "Attack Sword.png"}, 1, .5, nil, nil, 0.9, false, true)
	return result
end

function Go_Bookmarks(target)
	local result, Hostile_Status
	Logger("Clicking Bookmarks")
	Hostile_Status = PressRepeatNew("Bookmarks Star.png", {"Bookmarks Hostile Selected.png", "Bookmarks Hostile Unselected.png"}, 1, 4, Lower_Half, Upper_Half, 0.9, true, true)
	if (Hostile_Status.name == "Bookmarks Hostile Unselected") then 
		Logger("Clicking Hostile Tab")
		--PressRepeatNew("Bookmarks Hostile Unselected.png", "Bookmarks Hostile Selected.png", 1, 2, nil, Upper_Half, 0.9, nil, true)
		PressRepeatHexColor(Location(493, 150), Location(493, 150), "#D8E6E9", 5, 2)
		wait(0.5)
	end
	
	if (target == 1) then --make this dynamic use coordinates instead of image search
		wait(1)
		--if (isColorWithinThresholdHex(Location(101, 301), "#EA5454", 5)) then whiteish color
		if not(isColorWithinThresholdHex(Location(101, 301), "#0D457D", 5)) then
			PressRepeatHexColor(Location(234, 282), Location(594, 1425), "#FEFFFF", 5, 2)
			Logger("Clicking Middle Screen until Additional Option is found")
			if (coordOffsetCB) then
				local coordSplit = Split(coordOffset, ",")
				result = PressRepeatNew(string.format("%s,%s", (screen.x/2) + tonumber(coordSplit[1]), (screen.y/2) + tonumber(coordSplit[2])), {"Scout Option.png", "City Attack.png", "Garrison.png", "Attack Sword.png"}, 1, 0, nil, nil, 0.9, false, true)
			else
				result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), {"Scout Option.png", "City Attack.png", "Garrison.png", "Attack Sword.png"}, 1, 0, nil, nil, 0.9, false, true)
			end
		else
			print("Turret & SFC Bookmarks not found in Hostile TAB")
			Logger("Turret & SFC Bookmarks not found in Hostile TAB")
			scriptExit()
		end
		--[[Logger("Searching for ROI")
		local Bookmarks_Sword_List = findAllNoFindException(Pattern("Bookmarks Sword.png"):color():similar(0.95))
		if (table.getn(Bookmarks_Sword_List) > 0) then
			Logger("ROI Created")
			ROI = Region(Bookmarks_Sword_List[1].x*3, Bookmarks_Sword_List[1].y, Bookmarks_Sword_List[1].w, Bookmarks_Sword_List[1].h)
			Logger("Clicking on ROI")
			PressRepeatNew(ROI, "City.png", 1, 2, nil, Lower_Right, 0.9, false, true)
			Logger("Clicking Middle Screen until Additional Option is found")
			if (coordOffsetCB) then
				local coordSplit = Split(coordOffset, ",")
				result = PressRepeatNew(string.format("%s,%s", (screen.x/2) + tonumber(coordSplit[1]), (screen.y/2) + tonumber(coordSplit[2])), {"Scout Option.png", "City Attack.png", "Garrison.png", "Attack Sword.png"}, 1, 0, nil, nil, 0.9, false, true)
			else
				result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), {"Scout Option.png", "City Attack.png", "Garrison.png", "Attack Sword.png"}, 1, 0, nil, nil, 0.9, false, true)
			end
		else 
			Go_Back("Bookmarks Unavailable") 
			result = {name = nil}
		end--]]
	else
		Logger("Searching for Target Bookmarks")
		local Bookmarked = SearchImageNew(target, nil, 0.95, true, false, 10)
		if (Bookmarked.name) then
			Logger("Target Bookmarks Found and Clicking")
			PressRepeatNew(TargetOffset(Bookmarked.xy, "0", tostring(Bookmarked.h*2)), "City.png", 1, 2, nil, Lower_Right, 0.9, false, true)
			Logger("Clicking Middle Screen until Additional Option is found")
			--result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), {"Scout Option.png", "City Attack.png", "Garrison.png", "Battle Record.png"}, 1, 0, nil, nil, 0.9, false, true)
			result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), {"City Attack.png", "Garrison.png"}, 1, 0, nil, nil, 0.9, false, true)
		else
			print("Turret & SFC Bookmarks not found in Hostile TAB")
			Logger("Turret & SFC Bookmarks not found in Hostile TAB")
			scriptExit()
		end
	end
	return result
end

function Map_function()
	Current_Function = getCurrentFunctionName()
	local result
	Logger("Starting Map Function: " ..Maps_Option_Type)
	if (Maps_Option_Type == "Attack") then --Attack
		local Task, time_result = "None"
		Logger(string.format("Current Injured: %s | Required Injured: %s", Current_Injured, Required_Injured))
		if (Attack_Heal) and (Current_Injured <= Required_Injured) then Task = "Continue"
		elseif (Attack_Heal) and (Current_Injured > Required_Injured) then time_result = 10
		elseif not(Attack_Heal) then Task = "Continue" end
		if (Task == "Continue") then
			if Coordinates_Type == "Manual" then result = Go_Coordinates(X_Coordinate, Y_Coordinate) else result = Go_Bookmarks(1) end
			if not(result.name) then
				Go_Back()
				return 60
			end
			if not(result.name == "Garrison") then
				Logger("Clicking Attack")
				--local Attack_Status = PressRepeatNew("City Attack.png", {"City Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.9, true, true)
				local Attack_Status = PressRepeatNew(result.name.. ".png", {"City Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.9, true, true)
				if (Attack_Status.name == "City Deploy") then
					time_result = Get_March_Time()
					time_result = time_result * 2				
					local Deploy_Status = PressRepeatNew(Attack_Status.xy, {"World.png", "City.png", "Obtain More.png", "Confirmation.png", "Other Troops Marching.png"}, 1, 4, nil, nil, 0.8, true, true)
					Maps_Current_Iteration = Maps_Current_Iteration + 1
					return time_result
				else
					Go_Back()
					return 60
				end
			end
		end				
		return Maps_Repeat_Delay
	elseif (Maps_Option_Type == "Scout") then --Scout
		if Coordinates_Type == "Manual" then result = Go_Coordinates(X_Coordinate, Y_Coordinate) else result = Go_Bookmarks(1) end
		if not(result.name == "Garrison") then
			Logger("Clicking Scout")
			PressRepeatNew("Scout Option.png", "Scout Confirmation.png", 1, 2, nil, nil, 0.9, true, true)
			Logger("Clicking Scout again for Confirmation")
			PressRepeatNot("Scout Confirmation.png", "Scout Confirmation.png", 1, 2, nil, nil, 0.9, true, true)
			Logger("Scouting Completed")
		end
		return Maps_Repeat_Delay
	else --SFC
		local Task, time_result = "None"
		if (Attack_Heal) and (Current_Injured <= Required_Injured) then Task = "Continue"
		elseif (Attack_Heal) and (Current_Injured > Required_Injured) then time_result = 10
		elseif not(Attack_Heal) then Task = "Continue" end
		
		if (Task == "Continue") then
			local Turret_of_Interest = false
			Logger("Task Continue Found")
			if Coordinates_Type == "Manual" then 
				result = Go_Coordinates(X_Coordinate, Y_Coordinate)
			else 
				local Map_Target = {}
				if (Sunfire_Castle) then table.insert(Map_Target, "Bookmark Sunfire Castle.png") end
				if (Turret_Northground) then table.insert(Map_Target, "Bookmark Northground.png") end
				if (Turret_Eastcourt) then table.insert(Map_Target, "Bookmark Eastcourt.png") end
				if (Turret_Westplain) then table.insert(Map_Target, "Bookmark Westplain.png") end
				if (Turret_Southwing) then table.insert(Map_Target, "Bookmark Southwing.png") end
				for i, current_Target in ipairs(Map_Target) do
					result = Go_Bookmarks(current_Target)
					if (result.name == "City Attack") then
						if (SFC_SVS) then
							local Turret_Status = SearchImageNew({"SFC Opposing State.png", "SFC Your State.png"}, Region(screen.x/2, 680, 120, 60), false, false, 30)
							if (Turret_Status.name == "SFC Opposing State") then
								Turret_of_Interest = true
								break
							end
						else 
							Turret_of_Interest = true
							break
						end
					end
				end
			end
			if (Turret_of_Interest) then
				-- ADD SOMETHING TO ATTACK requires march time -------
				local Attack_Status = PressRepeatNew(result.name.. ".png", {"City Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.9, true, true)
				if (Attack_Status.name == "City Deploy") then
					time_result = Get_March_Time()
					time_result = time_result * 2				
					local Deploy_Status = PressRepeatNew(Attack_Status.xy, {"World.png", "City.png", "Obtain More.png", "Confirmation.png", "Other Troops Marching.png"}, 1, 4, nil, nil, 0.8, true, true)
					Maps_Current_Iteration = Maps_Current_Iteration + 1
				else
					Go_Back()
					return 60
				end
			else
				keyevent(4)
				wait(1)
				--Go_Back()
				time_result = Maps_Repeat_Delay
			end	
		end
		return time_result
	end
end

function Close_Share_Screen()
	Logger("Checking if Share coordinates is opened by mistake")
	wait(.8)
	Chat_Screen = SearchImageNew("Share Coordinates.png", nil, 0.9, true)
	if (Chat_Screen.name) then keyevent(4) end
end

function AutoHelp(Help_Status)
	Current_Function = getCurrentFunctionName()
	if not(Help_Status.name) then Help_Status = SearchImageNew("Help.png", eventROI, 0.9, true) end
	if (Help_Status.name) then
		Logger("Clicking Help")
		click(Location(Help_Status.sx, Help_Status.sy + 1))
		Logger("Help Button Clicked")
	end
	Help_Status = nil
	return nil
end

function rallyStarter(Rally, useCounter)
	Logger("Clicking Rally")
	local Attack_Status = PressRepeatNew(Rally.xy, {"Hold Rally.png", "March Queue Limit.png", "March Queue Maxed.png"}, 1, 3, nil, nil, 0.75, true, true)
	if (Attack_Status.name == "March Queue Limit") then
		Go_Back("March Queue limit sleeping for 300 seconds")
		return 300
	elseif(Attack_Status.name == "March Queue Maxed") then
		Go_Back(string.format("March Queue Maxed sleeping for %s seconds", Use_All_Timer))
		return Use_All_Timer
	end
	Logger("Clicking Hold Rally")
	Deploy_Btn = PressRepeatNew(Attack_Status.xy, {"Deploy.png", "March Queue Limit.png", "March Queue Maxed.png"}, 1, 2, nil, nil, 0.8, true)
	if (find_in_list({"March Queue Limit", "March Queue Maxed"}, Deploy_Btn.name)) then
		Go_Back("March Queue limit sleeping for 300 seconds")
		return 300
	end
        local rawFlagReq = Flag_Req
        local _flagReq = normalizeFlag(rawFlagReq)
        Logger(string.format("AutoAttack: using Flag_Req=%s (raw=%s)", tostring(_flagReq), tostring(rawFlagReq)))
        return Auto_Beast(Deploy_Btn, Attack_Type, _flagReq, Use_Hero, useCounter)
end

function checkStamina(Number, flowType) -- returns seconds
	if (flowType == "Intel") then
		Logger("Searching for Intel Button")
		local Intel_Button = SearchImageNew("Intel Button.png", Lower_Right, 0.9, true)
		if not(Intel_Button.name) then return 60 end
		Logger("Intel Found and Opening")
		PressRepeatNew(Intel_Button.xy, "Intel Cans.png", 1, 2, nil, Upper_Right, 0.9, nil, true)
		Number = Num_OCR(Region(580,20,97,39), "t")
		Go_Back()
	end
	Logger("Calculating Time required to earn stamina")
	local Stamina_Required, Beasts_Stamina, Polar_Terror_Stamina, total_Seconds = 0, 10, 25, 0
	if ((Attack_Type == "Polar Terror") or (Attack_Type == "Reaper")) and (Use_Hero) and ((Hero_Type == "Gina") or (Hero_Type == "Both")) then 
		local Polar_Terror_Dictionary = {[1] = 22, [2] = 22, [3] = 21, [4] = 20, [5] = 20}
		Stamina_Required = Polar_Terror_Dictionary[Gina_Skills] - Number
	elseif ((Attack_Type == "Polar Terror") or (Attack_Type == "Reaper")) and (not(Use_Hero) or ((Use_Hero) and not((Hero_Type == "Gina") or (Hero_Type == "Both")))) then
		Stamina_Required = Polar_Terror_Stamina - Number
	elseif (Attack_Type == "Beasts") and (Use_Hero) and ((Hero_Type == "Gina") or (Hero_Type == "Both")) then
		Beasts_Dictionary = {[1] = 9, [2] = 8, [3] = 8, [4] = 8, [5] = 8}
		Stamina_Required = Beasts_Dictionary[Gina_Skills] - Number
	elseif (Attack_Type == "Beasts") and (not(Use_Hero) or ((Use_Hero) and not((Hero_Type == "Gina") or (Hero_Type == "Both")))) then
		Stamina_Required = Beasts_Stamina - Number
	end 
	total_Seconds = Stamina_Required * 300
	Logger("Total Time Required: " .. Get_Time(total_Seconds))
	return total_Seconds
end

function Hunting(Divider_March)
	Current_Function = getCurrentFunctionName()
	local Attack_Cool_Down_Timer = false
	Logger("Searching for Marching")
	local Marching = SearchImageNew("Marching.png", Upper_Half, 0.9, true)
	local Magnify
	if (Marching.name) then
		Logger("Preparing Marching Region")
		local Max_March, Min_March
		Marching_Region = Region(Marching.sx, Marching.sy, screen.x, Marching.h)
		Logger("Looking for Divider")
		if not(Divider_March) then repeat Divider_March = SearchImageNew("March Divider.png", Marching_Region, 0.9, true) until(Divider_March.name) end
		local Divider_Region_Min = Region(Divider_March.sx - 150, Divider_March.sy - 5, Divider_March.sx - (Divider_March.sx - 150), Divider_March.h + 10)
		local Divider_Region_Max = Region(Divider_March.sx, Divider_March.sy - 5, 150, Divider_March.h + 10)	
		Logger("Checking Current March")
		Min_March = SearchImageNew({"M1.png", "M2.png", "M3.png", "M4.png", "M5.png", "M6.png"}, Divider_Region_Min, 0.9, true, false, 5)
		Logger("Checking total March")
		Max_March = SearchImageNew({"M1.png", "M2.png", "M3.png", "M4.png", "M5.png", "M6.png"}, Divider_Region_Max, 0.9, true, false, 5)
		if (Min_March.name) and (Max_March.name) and (Min_March.name == Max_March.name) then
			Logger("Marching Maxed")
			return {Cool_Down = Use_All_Timer, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = false}
		end
	end

	if (Attack_Type == "Reaper") then
		if (checkStamina(0, "Intel") > 0) then
			local Attack_Cool_Down_Timer = true
			return {Cool_Down = curStamina, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = false}
		end

		local reaperDir = "Reaper Rally/"
		Logger()
		local dirResult = PressRepeatNew(reaperDir.. "Backpack.png", {reaperDir.. "Other Unclicked.png", reaperDir.. "Other Clicked.png"}, 1, 4, Lower_Most_Half, Upper_Half)
		if (dirResult.name == "Other Unclicked") then PressRepeatNew(reaperDir.. "Other Unclicked.png", reaperDir.. "Other Clicked.png", 1, 4, Upper_Half, Upper_Half) end
		Logger("Waiting for Items to Load")
		wait(1)
		Logger("Searching for Reaper Item")
		local reaper = SingleImageWait(reaperDir.. "Reaper Item.png")
		if not(reaper) then reaper = SingleImageWait(reaperDir.. "Horn of Cryptid.png") end
		if (reaper) then
			Logger("Reaper Item Found and Clicking")
			local useButton = PressRepeatNew(reaper, Main.Pet_Adventure.dir.. "Pet Skill Use.png", 1, 4)
			Logger("Using Reaper Item!")
			PressRepeatNew(useButton.xy, "City.png", 1, 4, nil, Lower_Most_Half, 0.9, false, true)
			Logger("Clicking Middle Screen until Additional Option is found")
			local result = PressRepeatNew(string.format("%s,%s", screen.x/2,screen.y/2), "Rally.png", 1, 1, nil, nil, 0.9, false, true)
			local Attack_Cool_Down = rallyStarter(result, false)
			local Attack_Cool_Down_Timer = true
			if (Attack_Type == "Reaper") and not(Attack_Cool_Down == 300) and not(Use_All) then Polar_Checker = true end
			return {Cool_Down = Attack_Cool_Down, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = Polar_Checker}
		else
			Go_Back("Reaper Item Unavailable! Checking in 1 Hour")
			return {Cool_Down = 3600, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = false}
		end
	else
		Logger("Checking Screen")
		Magnify = Search_Magnifyer("Search.png")
		if not(Magnify.status) then
			Logger("Magnifying Not found")
			return {Cool_Down = Use_All_Timer, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = false}
		end
		Logger("Initiating March")
		local Attack_Cool_Down = Auto_Beast_Search(Magnify.search)
		local Attack_Cool_Down_Timer = true
		if (Attack_Type == "Polar Terror") and not(Attack_Cool_Down == 300) and not(Use_All) then Polar_Checker = true end
		return {Cool_Down = Attack_Cool_Down, Timer = Attack_Cool_Down_Timer, Divider = Divider_March, Polar = Polar_Checker}
	end
end

-- All below for automatic getting of pet skill if intel is disabled

function getNextNearestTime()
	local function timeToSeconds3(timeStr)
		local h, m, s = timeStr:match("(%d+):(%d+):(%d+)")
		return (tonumber(h) * 3600) + (tonumber(m) * 60) + tonumber(s)
	end

	local function getCurrentTimeInSeconds()
		local t = os.date("*t")
		return (t.hour * 3600) + (t.min * 60) + t.sec
	end
	
    local now = getCurrentTimeInSeconds()
    local utcOffset = getUTCOffset() * 3600 -- Convert UTC offset to seconds
    local secondsInDay = 24 * 3600 -- Total seconds in a day

    -- Define original times (midnight and midday) in seconds
    local midnightUTC = timeToSeconds3("00:02:00")
    local middayUTC = timeToSeconds3("12:02:00")

    -- Adjust the times based on UTC offset
    local midnightLocal = (midnightUTC + utcOffset) % secondsInDay
    local middayLocal = (middayUTC + utcOffset) % secondsInDay

    -- Calculate seconds left until the next adjusted time
    if now < midnightLocal then
        return midnightLocal - now -- Time left until midnight
    elseif now < middayLocal then
        return middayLocal - now -- Time left until midday
    else
        return (secondsInDay - now) + midnightLocal -- Time left until midnight of the next day
    end
end --stops here

function City_Storehouse(Intel_Button)
	if (Intel_Button) then
		Go_Back("Going back to World")
	end
	--------------- Use Side Button to Locate Research Facility --------------
	Logger("Starting Stamina Claim")
	
	if not (Side_Check_Opener()) then return 300 end
	
	Logger("Searching Image for Tech Research")
	local Tech_Research = SearchImageNew("City Tech Research.png", nil, 0.92, true, false, 99)
	Logger("Clicking City Tech Research")
	PressRepeatNew(Tech_Research.xy, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
	local Details = SearchImageNew("City Details.png", nil, 0.9, true, false, 5)
	if not(Details.name) then Sleep_Iter(5) end
	Logger("Zooming Out")
	zoom(screen.x -100, 350, 1200, screen.x + 100, 1200, 350, 350, 350, 300)
	Logger("Searching for Storehouse")
	local storeHouseTimer, storehouseUpgrading = Timer(), false
	while not(SearchImageNew("Storehouse.png", nil, 0.9, true).name) do
		zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
		if (storeHouseTimer:check() > 5) then 
			storehouseUpgrading = true
			break 
		end
	end
	storeHouseTimer = nil
	local storeHouseTime = 10
	if (storehouseUpgrading) then storeHouseTime = 1 end
	Logger("Searching for Storehouse Images")
	local required_image = SearchImageNew({"City Cans.png", "City Online Rewards.png", "City Storehouse No Rewards.png"}, nil, 0.75, false, false, storeHouseTime)
	--------------- Continue --------------
	
	if (required_image.name) then
		Logger("Storehouse Found")
		local initial_swipe, Storehouse_Timer = true, Timer()
		while true do
			Storehouse_Status = SearchImageNew({"City Cans.png", "City Online Rewards.png", "City Storehouse No Rewards.png"}, nil, 0.75, false, 5)
			if (Storehouse_Status.name == "City Online Rewards") then
				Logger("Storehouse Result: City Online Rewards")
				initial_swipe = false
				Logger("Swiping to adjust location")
				Logger("Searching for City Online Rewards Again")
				local City_Online_Rewards = SearchImageNew("City Online Rewards.png", nil, 0.75, true, 4)
				if (City_Online_Rewards.name) then
					Logger("Pressing Rewards")
					PressRepeatNew(City_Online_Rewards.xy, "Next Chest Ready In.png", 1, 4, nil, Lower_Half, 0.95, false, true)
					Logger("Rewards Claimed")
					PressRepeatNew(4, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
				end
			elseif (Storehouse_Status.name == "City Cans") then
				Logger("City Cans")
				if (initial_swipe) then
					Logger("Swiping to adjust location")
					initial_swipe = false
				else
					Logger("Claiming Stamina")
					PressRepeatNew(Storehouse_Status.xy, "City Cans Claim.png", 1, 4, nil, nil, 0.90, false, true)
					Logger("Stamina Claimed")
					PressRepeatNew("City Cans Claim.png", "World.png", 1, 2, nil, Lower_Right, 0.95, false, true)
					break
				end
			elseif (Storehouse_Status.name == "City Storehouse No Rewards") then
				Logger("No Rewards Found")
				break
			elseif not(Storehouse_Status.name) and (Storehouse_Timer:check() > 5) then break
			end
			wait(1)
		end
	end
	Logger("Going Back to World")
	PressRepeatNew("World.png", "City.png", 1, 1, Lower_Right, Lower_Right, 0.9, true, true)
	if (Intel_Button) then
		PressRepeatNew(Intel_Button.xy, "Intel Cans.png", 1, 2, nil, Upper_Right, 0.9, nil, true)
	end
	return getNextNearestTime()
end

function Intel_Get_Stamina(Intel_Button)
	local function timeToMinutes(timeString)
		local hour, minute = timeString:match("(%d+):(%d+)")
		return hour * 60 + minute
	end
	local currentTime = os.date("%H:%M")
	local result, result_time = false, "NA"
	for i = Intel_Count, 1, -1 do
		local currentIntelTime = _G["intel_time"..i]
		local currentClaimStamina = _G["Claim_Stamina"..i]
		if (timeToMinutes(currentTime) >= timeToMinutes(currentIntelTime)) then	
			result, result_time = currentClaimStamina, currentIntelTime
			break
		end
	end
	Logger(string.format("Intel Settings Result: Time: %s - Result: %s", result_time, tostring(result)))
	wait(1)
	if (result) then City_Storehouse(Intel_Button) end
	
	if (Use_RSS_Pet_Skill) then
		local Pet_Skill_Time_Edited = string.lower(Pet_Skill_Time)
		Pet_Skill_Time_Edited = Pet_Skill_Time_Edited:gsub(" ", "")
		Pet_Skill_Time_Edited = "intel_" ..Pet_Skill_Time_Edited
		if (_G[Pet_Skill_Time_Edited] == result_time) then
			Go_Back()
			Use_Pet_Skills("Resources")
			PressRepeatNew(Intel_Button.xy, "Intel Cans.png", 1, 2, nil, Upper_Right, 0.9, nil, true)
		end
	end
end

local function timeToSeconds2(timeStr)
	local hours, minutes = timeStr:match("(%d+):(%d+)")
	return tonumber(hours) * 3600 + tonumber(minutes) * 60
end

local function timeToSeconds(timeStr)
	if timeStr and not timeStr:match("%d+:%d+:%d+") then timeStr = timeStr.. ":00" end
	local time1_hour, time1_min, time1_sec = timeStr:match("(%d+):(%d+):(%d+)")
	time1_hour, time1_min, time1_sec = tonumber(time1_hour), tonumber(time1_min), tonumber(time1_sec)
	local time1_total_Seconds = time1_hour * 3600 + time1_min * 60 + time1_sec
	return time1_total_Seconds
end

function timeToHoursAndMinutes(timeStr)
	if timeStr and not timeStr:match("%d+:%d+:%d+") then timeStr = timeStr.. ":00" end
    local hour, min, sec = string.match(timeStr, "(%d%d):(%d%d):(%d%d)")
    return tonumber(hour), tonumber(min), tonumber(sec)
end

function Get_Nearest_Time(availableTimes)
	local Intel_Time_List = {}
	if (Intel_Count == 3) then Intel_Time_List = {intel_time1, intel_time2, intel_time3}
	elseif (Intel_Count == 2) then Intel_Time_List = {intel_time1, intel_time2}
	else Intel_Time_List = {intel_time1} end

	availableTimes = availableTimes or Intel_Time_List
	local currentSeconds = timeToSeconds(os.date("%H:%M:%S"))
	local nextTime = nil
	local minTimeDifference = math.huge
	for _, time in ipairs(availableTimes) do
		local timeSeconds = timeToSeconds(time)
		local timeDifference = timeSeconds - currentSeconds

		if timeDifference > 0 and timeDifference < minTimeDifference then
			minTimeDifference = timeDifference
			nextTime = time
		end
	end
	
    if nextTime == nil then
        nextTime = availableTimes[1] -- Assuming availableTimes is not empty
    end
    local nextHour, nextMinute, nextSecond = timeToHoursAndMinutes(nextTime)
    local nextTimeDate = os.date("*t")
    nextTimeDate.hour, nextTimeDate.min, nextTimeDate.sec = nextHour, nextMinute, nextSecond
    local nextTimeSeconds = os.time(nextTimeDate)
    local timeDifferenceSeconds = nextTimeSeconds - os.time()
    if timeDifferenceSeconds < 0 then
        nextTimeSeconds = nextTimeSeconds + 86400
    end
    timeDifferenceSeconds = nextTimeSeconds - os.time()
    return timeDifferenceSeconds
end

----------------------------------------------------------------
-- Screen regions (fixed Lower_Right) — safe to paste as-is
----------------------------------------------------------------

-- Focused sub-region for the Agnes intel side tab (based on your screenshot):
-- roughly left 30% of screen, from ~8% down to ~50% height.


----------------------------------------------------------------
-- Helper: tap Agnes if visible (for Intel LIST screen)
----------------------------------------------------------------
local function Maybe_Handle_Agnes_OnIntelList(max_taps)
    if AgnesWasClaimedToday() then
        Logger("Agnes intel already claimed today; skipping list scan")
        return false
    end

    max_taps = max_taps or 2
    for n = 1, max_taps do
        local agnes = SearchImageNew({"Agnes.png", ""}, Agnes_Region, 0.88, true, false, 6)
        if agnes and agnes.name then
            Logger(string.format("Agnes intel (list) spotted, tap #%d ...", n))
            -- Tap and accept any of these post states; don’t block
            PressRepeatNew(
                agnes.xy,
                {"Intel Cans.png", "Intel View.png", "World.png", "City.png"},
                1, 2, nil, nil, 0.85, true, true
            )
            MarkAgnesClaimed()
            wait(0.6)
        else
            -- no more Agnes in the region; bail out
            return false
        end
    end
    return true
end

----------------------------------------------------------------
-- Helper: backup - tap Agnes if it appears during Beast branch
----------------------------------------------------------------
local function Maybe_Handle_Agnes_Fallback()
    if AgnesWasClaimedToday() then
        return false, nil
    end

    local agnes = SearchImageNew({"Agnes.png", ""}, Upper_Left, 0.88, true, false, 6)
    if agnes and agnes.name then
        Logger("Agnes intel spotted (fallback). Tapping and continuing...")
        PressRepeatNew(agnes.xy, {"World.png","City.png","Intel Cans.png","Intel View.png"}, 1, 2, nil, nil, 0.85, true, true)
        MarkAgnesClaimed()
        return true, 2
    end
    return false, nil
end

----------------------------------------------------------------
-- Main: Search_Intel (with early + fallback Agnes support)
----------------------------------------------------------------
function Search_Intel()
    Current_Function = getCurrentFunctionName()

    if (Auto_Merc_Prestige) and (Main.mercPrestige.enabled) then
        Logger("Mercenary Prestige in progress, delaying Intel run")
        return 60
    end

    if (Auto_Hero_Mission) and (Main.Hero_Mission.enabled) then
        Logger("Hero Mission in progress, delaying Intel run")
        return 60
    end

    -- Pause other schedulers while we run Intel
    if (Auto_Join_Enabled) and (Main.Auto_Join.status) then
        Auto_Join("OFF")
        Main.Auto_Join.status = false
    end

    Close_Share_Screen()
    Main.Intel.status = false

    Logger("Searching for Intel Button")
    local Intel_Button = SearchImageNew("Intel Button.png", Lower_Right, 0.9, true)
    if not (Intel_Button and Intel_Button.name) then return 60 end

    Logger("Intel Found and Opening")
    PressRepeatNew(Intel_Button.xy, "Intel Cans.png", 1, 2, nil, Upper_Right, 0.9, nil, true)

    ----------------------------------------------------------------
    -- Early: tap Agnes on Intel list if present, then continue
    ----------------------------------------------------------------
    Logger("Quick scan for Agnes on Intel list")
    Maybe_Handle_Agnes_OnIntelList(2) -- try up to 2 taps if stacked

    ----------------------------------------------------------------
    -- Clear any completed intel first
    ----------------------------------------------------------------
    Logger("Checking for Completed Intel")
    local Completed_Intel = findAllNoFindException(Pattern("Intel Check.png"):similar(0.85):color())
    for i, cur_Completed in ipairs(Completed_Intel) do
        Logger(string.format("Intel Completed Found %s/%s", i, table.getn(Completed_Intel)))
        PressRepeatNew(cur_Completed, "Tap Anywhere.png", 1, 4, cur_Completed, Lower_Half, 0.9, true, true)
        Logger("Clicking Tap Anywhere")
        PressRepeatNew("Tap Anywhere.png", "Intel Cans.png", 1, 2, Lower_Half, Upper_Right, 0.9, true, true)
        wait(1)
    end

    ----------------------------------------------------------------
    -- Find an available Intel card
    ----------------------------------------------------------------
    Logger("Searching for Intel Quests")
    local Intel_List = {
        "Intel Beast Hunting.png", "Intel Rescue Survivor.png", "Intel Firebeast.png",
        "Intel Hero Journey.png", "Intel Hero Journey 1.png",
        "Intel Beast Hunting 1.png", "Intel Beast Hunting 2.png",
        "Intel Rescue Survivor 1.png"
    }
    if (Intel_Master_Bounty) then table.insert(Intel_List, "Intel Master Bounty.png") end

    local Intel_Completed, Intel_Found = false, nil
    while true do
        Intel_Found = SearchImageNew(Intel_List, nil, 0.9, false, false, 3)
        if (Intel_Found and Intel_Found.name) then
            break
        else
            local No_Other_Quest = SearchImageNew({"Intel Refreshes.png", "Intel Master Bounty.png"}, nil, 0.9, false, false)
            if (No_Other_Quest and No_Other_Quest.name) then
                Intel_Completed = true
                break
            end
        end
        -- Opportunistic scan each loop (cheap)
        Maybe_Handle_Agnes_OnIntelList(1)
    end

    ----------------------------------------------------------------
    -- Gate on stamina / availability
    ----------------------------------------------------------------
    if (Intel_Completed) or (Num_OCR(Region(580,20,97,39), "t") < 12) then -- stamina check
        Claim_Stamina = true
        local return_value = Get_Nearest_Time()
        Go_Back("Completed! Returning in: " .. Get_Time(return_value))
        wait(1)

        if (Enable_Auto_Attack) then
            if (Auto_Merc_Prestige) and (Main.mercPrestige.status) and not(Main.mercPrestige.enabled) then 
                Main.mercPrestige.enabled, Main.mercPrestige.cooldown, Main.mercPrestige.timer = true, 0, Timer()
            elseif (Auto_Hero_Mission) and (Main.Hero_Mission.status) and not(Main.Hero_Mission.enabled) then
                Main.Hero_Mission.enabled, Main.Hero_Mission.cooldown, Main.Hero_Mission.timer = true, 0, Timer()
            else
                Auto_Attack, Main.Attack.cooldown, Main.Attack.timer = true, 0, Timer()
            end
        else
            if (Auto_Join_Enabled) and not (Main.Auto_Join.status) then
                Auto_Join("ON")
                Main.Auto_Join.status = true
            end
        end
        return return_value
    end

    ----------------------------------------------------------------
    -- Optional stamina claim if flagged
    ----------------------------------------------------------------
    if (Claim_Stamina) then
        Claim_Stamina = false
        Intel_Get_Stamina(Intel_Button)
    end

    ----------------------------------------------------------------
    -- Open the selected intel and branch by type
    ----------------------------------------------------------------
    Main.Intel.status = true
    Logger("Clicking Intel Quest: " .. (Intel_Found and Intel_Found.name or "N/A"))
    PressRepeatNew(string.format("%s.png", Intel_Found.name), "Intel View.png", 1, 4, nil, nil, 0.9, false, true)
    Logger("Intel View Opened")

    -- Rescue Survivor
    if (find_in_list({"Intel Rescue Survivor", "Intel Rescue Survivor 1"}, Intel_Found.name)) then
        local Intel_Rescue = PressRepeatNew("Intel View.png", "Intel Rescue.png", 1, 4, nil, nil, 0.9, true, true)
        Logger("Pressing Intel Rescue")
        PressRepeatNot("Intel Rescue.png", "Intel Rescue.png", 1, 2, nil, nil, 0.9)
        wait(1)
        if (SearchImageNew("Obtain More.png").name) then
            keyevent(4)
            return 300
        end
        return 15

    -- Hero Journey
    elseif (find_in_list({"Intel Hero Journey", "Intel Hero Journey 1"}, Intel_Found.name)) then
        PressRepeatNew("Intel View.png", "Intel Explore.png", 1, 4, nil, nil, 0.9, true, true)
        Logger("Pressing Intel Explore")
        local exploreStatus = PressRepeatNew("Intel Explore.png", {"Squad Fight.png", "Obtain More.png"}, 1, 4, nil, Lower_Half, 0.9, true, true)
        if (exploreStatus.name == "Squad Fight") then
            Logger("Clicking Squad Fight and wait for Completion")
            PressRepeatNew("Squad Fight.png", "Squad Tap Anywhere to Exit.png", 1, 4, Lower_Half, Lower_Half, 0.9, true, true)
            Go_Back("Hero Journey Completed and Going back")
            return 2
        else
            keyevent(4)
            return 300
        end

    -- Beasts / Firebeast (Agnes fallback lives here)
    else
        local Attack = PressRepeatNew("Intel View.png", "Attack.png", 1, 4, nil, nil, 0.9, true, true)
        Logger("Pressing Attack")
        local Attack_Status = PressRepeatNew(
            Attack.xy,
            {"Deploy.png", "March Queue Limit.png", "March Queue.png"},
            1, 2, nil, nil, 0.8, true
        )

        if (Attack_Status.name == "March Queue Limit") then
            Logger("March Queue Limit! will come back in 00:05:00")
            return 300
        end

        if (find_in_list({"Intel Beast Hunting", "Intel Beast Hunting 1", "Intel Beast Hunting 2", "Intel Firebeast"}, Intel_Found.name)) then
            -- Fallback Agnes check (covers late appearance)
            local handled, delay_s = Maybe_Handle_Agnes_Fallback()
            if handled then
                return delay_s or 2
            end

            Logger("Setting up attack for Beast")
            local Original_Attack_Type = Attack_Type
            Attack_Type = "Beasts"
            local rawFlagReq = Flag_Req
            local _flagReq = normalizeFlag(rawFlagReq)
            Logger(string.format("AutoAttack: using Flag_Req=%s (raw=%s)", tostring(_flagReq), tostring(rawFlagReq)))
            total_Seconds = Auto_Beast(Attack_Status, Attack_Type, _flagReq, Use_Hero, false)
            Attack_Type = Original_Attack_Type
            Logger("Attack in progress")
            return total_Seconds
        else
            Logger("Setting Up attack for Bounty")
            total_Seconds = Get_March_Time()
            local Deploy_Status = PressRepeatNew(
                Attack_Status.xy,
                {"World.png", "City.png", "Obtain More.png", "Confirmation.png", "Other Troops Marching.png"},
                1, 4, nil, nil, 0.8, true, true
            )
            if (Deploy_Status.name == "Obtain More") then
                Go_Back("Obtain More Found!")
                return 300
            end
            return total_Seconds * 2
        end
    end

    return 2
end

function mailRewardsClaim()
	local mailDir = "Mail/"
	Logger("Searching for Mail Button")
	snapshotColor()
	local Mail_Button = SearchImageNew(mailDir.. "Mail Btn.png", Lower_Right, 0.9, true)
	if not(Mail_Button.name) then return 60 end
	Logger("Mail Button Found and Checking")
	local r, g, b = getColor(Location(Mail_Button.sx + Mail_Button.w, Mail_Button.sy - 10))
	usePreviousSnap(false)
	if not(isColorWithinThreshold(r, g, b, 103, 141, 202, 10)) then --- GET COLOR
		local mailLabel = PressRepeatNew(Mail_Button.xy, mailDir.. "Mail Label.png", 1, 2)
		Logger() -- closing Label
		local locList = {Location(133, 95), Location(269, 95), Location(405, 95), Location(541, 95)}
		local readClaimAll = SingleImageWait(mailDir.. "Read & Claim All.png", 99999, Lower_Most_Half)
		for i, loc in ipairs(locList) do
			local rN, gN, bN = getColor(loc)
			if not(isColorWithinThreshold(rN, gN, bN, 107, 159, 216, 10)) and not(isColorWithinThreshold(rN, gN, bN, 216, 230, 233, 10)) then --- GET COLOR
				Press(loc, 1)
				wait(.2)
				Press(loc, 1)
				wait(1)
				local repeatCounter = 0
				while true do
					Logger("Rewards Found and Clicking Claim All")
					Press(readClaimAll, 1)
					Logger("Checking for Tap Anywhere")
					if (SingleImageWait("Tap Anywhere.png", 1.5, Lower_Half)) then 
						Logger("Tap Anywhere Found and Closing!!!")
						PressRepeatNew(mailLabel.xy, mailDir.. "Mail Label.png", 1, 0, nil, Upper_Half, 0.9, false, true)
					end
					Logger("Checking Color Again")
					Logger()
					rN, gN, bN = getColor(loc)
					if not(isColorWithinThreshold(rN, gN, bN, 216, 230, 233, 10)) then --clicked color
						if (i == 3) then
							local redDots = regionFindAllNoFindException(Region(660, 157, 51, 1270), Pattern(mailDir.. "Dot.png"):similar(0.9))
							for i, dot in ipairs(redDots) do
								Logger("Red Dots Found!")
								PressRepeatNew(dot, mailDir.. "Delete.png", 1, 2, nil, Lower_Half)
								claim = SingleImageWait(mailDir.. "Claim.png", 2)
								if (claim) then 
									Logger("Claim Found!")
									Press(claim, 1)
									wait(1)
									Press(claim, 1)
									wait(.5)
								end
								Logger("Going back to Mail tabs!")
								keyevent(4)
							end
						end
						Logger("Red Dot Still Available Trying To Swipe")
						repeatCounter = repeatCounter + 1
						for i = 1, 3 do
							Logger(string.format("Swiping %s/3", i))
							if (i < 3) then
								swipe(Location(702, 1386), Location(702, 1000), .5)
								wait(.5)
							else swipe(Location(702, 1386), Location(702, 187), .5) end
							Press(readClaimAll, 1)
							wait(0.5)
							Press(readClaimAll, 1)
						end
					else break end
					if (repeatCounter >= 4) then 
						Press(readClaimAll, 1)
							wait(0.5)
						Press(readClaimAll, 1)
						break
					end
				end
			end
		end
		Go_Back("Rewards Claimed in Mail")
	else Logger("Nothing to Claim in Mail") end
	return Auto_Mail_Timer * 60
end

function checkUpgradeableTroops()
	local Task = ""
	local highestTroopLevel, troopOfInterest, highestOpenedTroop = 1, 1, 1
	local troopInterest = {}
	local upgradeAvailable = false
	local promotional = SearchImageNew("Troop Training/Promotional.png", Lower_Half)
	if (promotional.name) then
		Task = "Direct Promotion"
		PressRepeatNot(promotional.xy, "Troop Training/Promotional.png", 1, 2, nil, Lower_Half)
		wait(1)
	else
		local promotionStatus = SearchImageNew({"Troop Training/Promotion Available.png", "Troop Training/Promotion Unavailable.png"}, Lower_Half, 0.9, true, false, 2) --some has no images for this
		if (promotionStatus.name == "Promotion Available") then
			Task = "Direct Promotion"
		else
			local troopLevelFound = false
			for i = 1, 11 do
				local repeater, activeTroopTrigger = 0, true
				while true do
					local pressFlagger = true
					Logger("Searching for Troop Level: " ..i)
					local curIMG = SearchImageNew(string.format("Troop Training/%s.png", i), Region(2, 1088, 716, 28), 0.85)
					if (curIMG.name) then
						local flagger = false
						Logger("Troop Level: " ..i.. " Found!")
						troopLevelFound = true
						local ROI = Region(curIMG.sx, curIMG.sy + (curIMG.h * 1.2), curIMG.w, curIMG.h * 2)
						if not(SearchImageNew("Troop Training/0.png", ROI).name) then
							Press(curIMG.xy, 1)
							pressFlagger = false
							local troopLocked = SingleImageWait("Troop Training/Troop Locked.png", 2, Lower_Half)
							if (troopLocked) then activeTroopTrigger = false
							else
								flagger = true
								table.insert(troopInterest, i)
							end
						end
						if (pressFlagger) then
							Logger("Pressing Troop Level: " ..i)
							Press(curIMG.xy, 1)
						end
						if (flagger) then
							wait(1)
							local promotionStatus = SearchImageNew({"Troop Training/Promotion Available.png", "Troop Training/Promotion Unavailable.png"}, Lower_Half, 0.9, true, false, 2)
							if (promotionStatus.name == "Promotion Available") then
								troopOfInterest, upgradeAvailable = i, true
							end
						end
						highestTroopLevel = i
						if (activeTroopTrigger) then highestOpenedTroop = i end
						break
					else
						Logger("Troop Level: " ..i.. " Unavailable")
						if (troopLevelFound) then
							swipe(Location(610, 1160), Location(210, 1160), 1) --right to left
							wait(.2)
							click(Location(610, 1160))
							wait(.2)
							click(Location(610, 1160))
						end
						if (repeater == 0) then repeater = repeater + 1
						else break end
					end
				end
			end
		end
	end

	--check if troops are available to be upgraded
	if (Task == "") then
		if (upgradeAvailable) then
			wait(1)
			if not(troopOfInterest == highestTroopLevel) then
				local curIMG
				while true do
					Logger("Searching for Troop Image: " ..troopOfInterest)
					curIMG = SearchImageNew(string.format("Troop Training/%s.png", troopOfInterest), Region(2, 1088, 716, 28), 0.9)
					if (curIMG.name) then
						Logger("Image Found!")
						break
					else
						Logger("Image not found and swiping")
						swipe(Location(210, 1160), Location(610, 1160), 1) --right to left
						wait(.2)
						click(Location(610, 1160))
						wait(.2)
						click(Location(610, 1160))
						wait(1.6)
					end
				end
				Logger("Pressing Troop: " ..troopOfInterest)
				Press(curIMG.xy, 1)
				wait(.2)
				Logger("Re-pressing Troop: " ..troopOfInterest)
				Press(curIMG.xy, 1)
				wait(1)
				Task = "Direct Promotion"
			else Task = "Unavailable" end
		else --no Upgrade and requires to go back to highest troop you can train
			if (table.getn(troopInterest) > 0) then troopOfInterest = math.max(unpack(troopInterest)) end
			if not(troopOfInterest == highestTroopLevel) then
				local swipeRepeater = 0
				while true do
					Logger("Searching for Troop Image: " ..highestOpenedTroop)
					curIMG = SearchImageNew(string.format("Troop Training/%s.png", highestOpenedTroop), Region(2, 1088, 716, 28), 0.85)
					if (curIMG.name) then
						Logger("Image Found!")
						Press(curIMG.xy, 1)
						wait(.2)
						Press(curIMG.xy, 1)
						break
					else
						Logger("Image not found and swiping")
						swipe(Location(210, 1160), Location(610, 1160), 1) --right to left
						wait(.2)
						click(Location(610, 1160))
						wait(.2)
						click(Location(610, 1160))
						wait(1.6)
						swipeRepeater = swipeRepeater + 1
						if (swipeRepeater > 5) then
							Logger("Required image has not been found. Training Currently Clicked Troops")
							break
						end
					end
				end
			end
		end
	end
	Logger("Task: " ..Task)
	if (Task == "Unavailable") then
		return {result = false, seconds = 0}
	elseif (Task == "Direct Promotion") then
		Logger("Searching for Promotion Type")
		local promotionStatus = SearchImageNew({"Troop Training/Promotion Available.png", "Troop Training/Promotion Unavailable.png"}, Lower_Half, 0.9, true, false, 9999)
		Logger("Promotion Result: " ..promotionStatus.name)
		if (promotionStatus.name == "Promotion Available") then
			Logger("Clicking Promotion")
			local PromotionBtn = PressRepeatNew(promotionStatus.xy, "Troop Training/Promotion.png", 1, 3)
			wait(1.5)
			local res = Convert_To_Seconds(Num_OCR(Region(476, 1023, 129, 30), "SI"))
			local trainingSpeedups = PressRepeatNew(PromotionBtn.xy, "Training Speedups.png", 1, 4, nil, Lower_Half, 0.9, false, true)
			return {result = true, seconds = res}
		else return {result = false, seconds = 0} end
	end
	
	return {result = false, seconds = 0}
end
function expert(button, opts)
	opts = opts or {}
	if (button ~= "marksman") then
		Logger("Expert: unsupported button - " .. tostring(button))
		return false, 600
	end

	Logger("Expert: starting marksman expert routine")
	if not (Side_Check_Opener()) then
		Logger("Expert: failed to open side panel")
		return false, 300
	end

	Logger("Expert: locating marksman entry")
	local marksmanEntry = SearchImageNew("City Marksman.png", nil, 0.92, true, false, 99)
	if not (marksmanEntry and marksmanEntry.xy) then
		Logger("Expert: marksman entry not found; closing side panel")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return false, 1200
	end

	Logger("Expert: opening marksman camp")
	Press(marksmanEntry.xy, 1)
	wait(0.5)
	if not (SearchImageNew("World.png", Lower_Right, 0.9, true).name) then
		PressRepeatNew(marksmanEntry.xy, "World.png", 1, 2, nil, Lower_Right, 0.9, false, true)
	end
	wait(2)

	Logger("Expert: clearing overlay buttons")
	Press(Location(screen.x/2, screen.y/2), 1)
	wait(2)

	Logger("Expert: searching for Romulus Marksman ")
	local centerRegionSize = 320
	local romulusRegion = Region(
		math.max(0, math.floor((screen.x / 2) - (centerRegionSize / 2))),
		math.max(0, math.floor((screen.y / 2) - (centerRegionSize / 2))),
		math.min(screen.x, centerRegionSize),
		math.min(screen.y, centerRegionSize)
	)
	local romulus = SearchImageNew("Rmrk.png", romulusRegion, 0.82, true)
	if not (romulus and romulus.xy) then
		romulus = SearchImageNew("Rmrk.png", nil, 0.8, true)
	end

	if (romulus and romulus.xy) then
		Logger("Expert: Rmrk  found, tapping")
		Press(romulus.xy, 1)
		wait(3)
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return true, 0
	end

	Logger("Expert: Marksman not found; switching to world")
	local worldIcon = SearchImageNew("World.png", Lower_Right, 0.9, true)
	if not (worldIcon and worldIcon.name) then
		PressRepeatNew(marksmanEntry.xy, "World.png", 1, 2, nil, Lower_Right, 0.9, false, true)
	else
		Press(worldIcon.xy, 1)
	end
	wait(1.5)
	PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
	return false, 10800
end
-------------------------------Dawn Academy Claim--------------------------------------------------
function Dawn_Academy()
        ClickImg("Side Closed.png", Upper_Left, 0.85)
        Logger("Swipe Up x2")
        swipe(Location(6, 845), Location(6, 10), 0.5)
        wait(0.5)
        swipe(Location(6, 845), Location(6, 10), 0.5)
        wait(0.5)
        swipe(Location(6, 845), Location(0, 0), 0.1)
        Logger("Click Trek Btn")
        ClickImg("trek/trek.png", Lower_Left, nil)
        Logger("Waiting back Btn to show ")
        wait(1)
        WaitExists("trek/back.png", 2, Upper_Left, 0.85)
        if WaitExists("trek/bag.png", 1, Upper_Right, 0.8) then
                Logger("Bag Btn Found , Clicking")
                ClickImg("trek/bag.png", Upper_Right, 0.8)
        else
                Logger("Bag Not Found ")
                ClickImg("trek/back.png", Upper_Left, 0.85)
        end
        if WaitExists("trek/claimtrek1.png", 2, Upper_Right, 0.9) then
                Logger("Claim Found , Clicking ")
                ClickImg("trek/claimtrek1.png", Upper_Right, 0.9)
                updateDawnAcademyLastClaim(os.time())
                return true, true
        else
                Logger("Claim Button Not Found")
                ClickImg("trek/close.png", Upper_Right, 0.89)
                ClickImg("trek/back.png", Upper_Left, 0.9)
                return true, false
        end
end


function Run_Experts_Enlistment_Claim()
	Logger("Claim Enlistment Romulus ")
	ClickImg("Side Closed.png", Upper_Left, 0.8)
	Logger("Going To City Tech Research")
	ClickImg("City Tech Research.png", Lower_Left, 0.9)
	wait(4)
	local enlistPatterns = {"trek/Enlistment.png", "trek/Enlistment2.png"}
	local found, enlistButton = WaitExists(enlistPatterns, 2, Enlistment_Button_Region, 0.8)
	if found and enlistButton and enlistButton.xy then
		Logger("Enlistment button found; attempting claim")
		Press(enlistButton.xy, 1)
		wait(1.5)
		usePreviousSnap(false)
		local stillVisible = SearchImageNew(enlistPatterns, Enlistment_Button_Region, 0.8, true)
		if stillVisible and stillVisible.xy then
			Logger("Enlistment button still visible after first tap; retrying")
			Press(stillVisible.xy, 1)
			wait(1.5)
			usePreviousSnap(false)
			stillVisible = SearchImageNew(enlistPatterns, Enlistment_Button_Region, 0.8, true)
		end
		if not (stillVisible and stillVisible.name) then
			Logger("Enlistment Claimed ")
			wait(2)
			return true
		end
		Logger("Enlistment button did not disappear after tap; assuming claim failed")
	else
		Logger("Experts: Enlistment button not found")
	end
	ClickImg("World.png", Lower_Most_Half, 0.9)
	Logger("Enlisment Not Claimed ")
	return false
end
------------ CITY EVENTS -------------
function City_Troop_Training(Troop_Type)
	Current_Function = getCurrentFunctionName()
	local troopState = (Main and Main[Troop_Type]) or nil
	local lastDurationKey = string.format("TroopTrainingLast_%s", Troop_Type or "Unknown")
	local AMTroop = ""
	if (CHARACTER_ACCOUNT == "Main") and (AM_Enabled) and (#Main.AM.reqList > 0) then
		local listOfAMQuest = table.concat(Main.AM.reqList, ", ")
		if (string.find(listOfAMQuest, "Train Troops")) then
			AMTroop = "Delay"
			if (SingleImageWait("Alliance Mobilization/AM Troop Training Logo.png", 0, Lower_Left)) then AMTroop = "Found" end
		end
	end
	
	Logger("Checking Troop " ..Troop_Type)
	
	if not (Side_Check_Opener()) then return 300 end
	
	Logger("Searching Image for " ..Troop_Type)
	local Troop = SearchImageNew("City ".. Troop_Type.. ".png", nil, 0.92, true, false, 99)
	if not (Troop.name) then
		Logger("Troop Type not Found and Closing")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 3600
	end
	
	if (CHARACTER_ACCOUNT == "Main") then
		if (AMTroop == "Delay") and isColorWithinThresholdHex(Location(417, Troop.sy + 5), "#FF1E1F", 5) then
			Logger("Troop Completed but Waiting for AM Troop to be Selected")
			PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
			return 600
		end
	end
	local Upgrading_ROI = Region(Troop.sx + Troop.w, Troop.sy, Troop.w*6, Troop.h*1.2)
	Logger("Checking if Camp is upgrading")
	local Upgrading_Building = SearchImageNew("Upgrading Building.png", Upgrading_ROI, 0.90, true, false)
	if (Upgrading_Building.name) then
		Logger("Troop " ..Troop_Type .." is Currently Upgrading")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 3600
	end
	
	Logger("Clicking Troop " ..Troop_Type)
	PressRepeatNew(Troop.xy, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
	wait(2)
	Logger("Removing Unnecessary Buttons")
	--local Troop_Train = PressRepeatNew(string.format("%s,%s", screen.x/2, screen.y/2), {"Troop Train.png", "Troop Train Logo.png"}, 1, .2, nil, nil, 0.85, false, false)
	local Troop_Gems
	while true do
		Press(Location(screen.x/2, screen.y/2), 1)
		local Troop_Train = SearchImageNew({"Troop Train.png", "Troop Train Logo.png"}, nil, 0.85)
		if (Troop_Train.name) then
			Logger("Clicking Train Button")
			Troop_Gems = PressRepeatNew(Troop_Train.xy, {"Troop Gems 1.png", "Troop Gems 2.png", "Troop Upgraded.png"}, 1, 4, nil, Lower_Half, 0.9, false, true)
			break
		end
	end
	--local Troop_Gems = PressRepeatNew(Troop_Train.xy, {"Troop Gems 1.png", "Troop Gems 2.png", "Troop Upgraded.png"}, 1, 4, nil, Lower_Half, 0.9, false, true)
	if (Troop_Gems.name == "Troop Upgraded") then PressRepeatNew("Troop Upgraded.png", {"Troop Gems 1.png", "Troop Gems 2.png"}, 1, 2, Lower_Half, Lower_Half, 0.9, true, true) end
	Logger("Searching for Training Status")
	local Training_Status = PressRepeatNew(string.format("%s,%s", screen.x/2, screen.y/2), {"Training Button.png", "Training Speedups.png"}, 1, 1, nil, Lower_Half, 0.9, false, true)
	Logger("Searching Gems Image to Generate ROI")
	
	local Gems_Number, OCR_Status
	local return_result
	if (Training_Status.name == "Training Button") then --------- You can train troop
		---new option to upgrade troops
		if (upgradeTroops) then
			Logger("Checking Troops to Upgrade")
			local upgradeStatus = checkUpgradeableTroops()
			if (upgradeStatus.result) then
				Go_Back("Troop Upgrading Completed " ..Get_Time(upgradeStatus.seconds))
				return upgradeStatus.seconds
			end
		end
		--- train troops regularly
		--local Clock = SearchImageNew("Pet Skill/Pet Adventure Clock.png", Lower_Most_Half)
		local Clock = SingleImageWait("Pet Skill/Pet Adventure Clock.png", 9999999, Lower_Most_Half)
		--local Clock_ROI = Region(Clock.sx + Clock.w * 1.5, Clock.sy - 10, 160, 40)
		local Clock_ROI = Region(Clock:getX() + Clock:getW() * 1.5, Clock:getY() - 10, 160, 40)
		local Training_OCR = Num_OCR(Clock_ROI, "Gems")
		local Current_Number = (Training_OCR) and Convert_To_Seconds(Training_OCR) or 0
		while true do
			snapshotColor()
			local Troop_Gems = SearchImageNew({"Troop Gems 1.png", "Troop Gems 2.png"}, Lower_Half, 0.9, true)
			Logger("ROI Generated")
			Gems_Number, OCR_Status = numberOCRNoFindException(Region(Troop_Gems.sx + Troop_Gems.w, Troop_Gems.sy, Troop_Gems.w * 5.5, Troop_Gems.h), "ocr/Gems")
			usePreviousSnap(false)
			if ((OCR_Status) and (Gems_Number > 0)) and ((OCR_Status) and (Gems_Number < 40000)) then break end
		end
		--Logger("Training Troops Seconds: " ..tostring(Current_Number))
		--Logger("Training Troops Gems: " ..tostring(Gems_Number))
		Logger(string.format("Gems: %s | Time: %s", Gems_Number, Get_Time(Current_Number)))
		if (Gems_Number > 0) and (Current_Number > 0) then
			local Ratio = Current_Number / Gems_Number
			if (CHARACTER_ACCOUNT == "Main") then preferencePutNumber("Gems_Time_Ratio", Ratio) end
		end
		Logger("Training Troops")
		local Training_Result = PressRepeatNew("Training Button.png", {"Training Speedups.png","Cannot Train.png"}, 1, 2, Lower_Half, nil, 0.9, true, true)
		if (Training_Result.name == "Cannot Train") then
			return_result = (Current_Number > 0) and Current_Number or 3600
		else
			local ratioFallback = tonumber(preferenceGetNumber("Gems_Time_Ratio", 4.51)) or 4.51
			return_result = (Current_Number > 0) and Current_Number or math.floor((Gems_Number > 0 and Gems_Number or 1) * ratioFallback)
		end
	else
		local Clock = SearchImageNew("Pet Skill/Pet Adventure Clock.png", Lower_Most_Half, 0.9, true)
		if (Clock) and (Clock.name) then
			local Clock_ROI = Region(Clock.sx + Clock.w * 1.5, Clock.sy - 10, 160, 40)
			local Clock_OCR = Num_OCR(Clock_ROI, "Gems")
			local Clock_Number = (Clock_OCR) and Convert_To_Seconds(Clock_OCR) or nil
			if (Clock_Number) and (Clock_Number > 0) then
				return_result = Clock_Number
				Logger("Training queue time derived from clock: " .. Get_Time(return_result))
			end
		end
		if not(return_result) then
			while true do
				snapshotColor()
				local Troop_Gems = SearchImageNew({"Troop Gems 1.png", "Troop Gems 2.png"}, Lower_Half, 0.9, true)
				Logger("ROI Generated")
				Gems_Number, OCR_Status = numberOCRNoFindException(Region(Troop_Gems.sx + Troop_Gems.w, Troop_Gems.sy, Troop_Gems.w * 5.5, Troop_Gems.h), "ocr/Gems")
				usePreviousSnap(false)
				if ((OCR_Status) and (Gems_Number > 0)) and ((OCR_Status) and (Gems_Number < 40000)) then break end
			end
			local ratio = tonumber(preferenceGetNumber("Gems_Time_Ratio", 4.51)) or 4.51
			return_result = math.floor(Gems_Number * ratio)
			Logger(string.format("Training queue time estimated via ratio: %s (gems %s, ratio %.2f)", Get_Time(return_result), tostring(Gems_Number), ratio))
		end
	end	

	if (return_result) then
		local minimal = 600
		if (return_result < minimal) then
			local stored = tonumber(preferenceGetNumber(lastDurationKey, minimal))
			if (stored and stored > minimal) then
				Logger(string.format("Training estimate below threshold (%s). Using stored duration %s", Get_Time(return_result), Get_Time(stored)))
				return_result = stored
			end
		else
			preferencePutNumber(lastDurationKey, return_result)
		end
	end

	if (return_result) and (troopState and troopState.timer and troopState.cooldown) then
		local elapsed = troopState.timer:check()
		local remaining = troopState.cooldown - elapsed
		if (remaining) and (remaining > 600) then
			if (return_result < remaining * 0.5) or (return_result < 600) then
				Logger(string.format("Training estimate too low (%s). Restoring previous remaining %s", Get_Time(return_result), Get_Time(remaining)))
				return_result = math.max(math.floor(remaining), 600)
				preferencePutNumber(lastDurationKey, return_result)
			end
		end
	end
	Go_Back("Troop Training Completed " ..Get_Time(return_result))
	return return_result
end

function Recruiting_Heroes()
	Current_Function = getCurrentFunctionName()
	local remaining_time, Pet_Adventure_Repeater, Pet_Adventure_IMG = 300
	Logger("Starting Recruit Heroes")
	
	if not (Side_Check_Opener()) then return 300 end
	
	local Troop_Training = SearchImageNew("Troop Training.png", nil, 0.9, true)
	if not(Troop_Training.name) then
		Logger("Troop Training NOT Found! Closing")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	local Advanced_Recruit = SearchImageNew("City Advanced Recruit.png", nil, 0.9, true, false)
	Logger("Searching for Advanced Recruit")
	Pet_Adventure_Repeater = 0
	for i = 1, 10 do
		if (i == 1) or ((i >= 2) and not(Pet_Adventure_IMG.name)) then
			swipe(Location(6, 680), Location(6, 480), .6)
			--swipe(Location(Troop_Training.sx - 8, Troop_Training.y), Location(Troop_Training.sx - 8, Troop_Training.y - 200), .6)
		end
		if not(Advanced_Recruit.name) then wait(.5) end
		Advanced_Recruit = SearchImageNew("City Advanced Recruit.png", nil, 0.9, true, false)
		if (Advanced_Recruit.name) then break end
		Pet_Adventure_IMG = SearchImageNew("Pet Adventure.png", nil, 0.9, true)
		if (Pet_Adventure_IMG.name) then
			if (Pet_Adventure_Repeater == 2) then break
			else Pet_Adventure_Repeater = Pet_Adventure_Repeater + 1 end
		end
	end

	if not(Advanced_Recruit.name) then 
		Logger("Advance Recruitment NOT Found! Closing")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	Logger("Opening Hero Recruitment Screen")
	local Recruitment_Preview = PressRepeatNew("City Advanced Recruit.png", "Recruitment Preview.png", 1, 4, nil, nil, 0.9, false, true)
	
	------------------- Recruitment Screen Opened --------------------------
	local Return_time = 259200
	Logger("Searching for Free Recruit")
	local Advanced_Recruitment_Status = findAllNoFindException(Pattern("Recruit Once Free.png"):color():similar(0.95))
	Logger("Free Recruit Found: " ..table.getn(Advanced_Recruitment_Status))
	for i, v in ipairs(Advanced_Recruitment_Status) do
		local x,y,w,h = v:getX(), v:getY(), v:getW(), v:getH()
		Logger("Recruit Once Free Found and Clicking")
		PressRepeatNot("Recruit Once Free.png", "Recruitment Preview.png", 1, .5, Region(x, y, w, h))
		Logger("Tapping Anywhere to Exit")
		PressRepeatNew(TargetOffset(Recruitment_Preview.xy, "0", string.format("-%s", Recruitment_Preview.h*3)), "Recruitment Preview.png", 1, 0, nil, nil, 0.9, true, true)
		wait(2)
	end
	Logger("Searching for Next Free Recruit")
	local Alliance_Claim = findAllNoFindException(Pattern("Next Free.png"):similar(0.9))
	snapshotColor()
	for i, v in ipairs(Alliance_Claim) do
		Logger("Next Free Recruit found creating ROI for OCR")
		local Current_Time
		local x,y,w,h = v:getX(), v:getY(), v:getW(), v:getH()
		local ROI = Region(x + w, y, w, h)
		local Number, Number_Status
		local Day_One = SearchImageNew("Hero Recruitment Day.png", ROI, 0.9, true)
		local Seconds_Remaining
		if (Day_One.name) then
			local d_Zero = SearchImageNew("Hero Recruitment d Zero.png", ROI, 0.9, true) ---- Search 1d 0 or 1d 1
			repeat
				ROI = Region(Day_One.sx + Day_One.w - 2, y, w, h - 2)
				repeat Number, Number_Status = numberOCRNoFindException(ROI, "ocr/er") until(Number_Status)
				Seconds_Remaining = Convert_To_Seconds(Number) 
			until((d_Zero.name) and (Seconds_Remaining < 35999)) or (not(d_Zero.name) and (Seconds_Remaining < 86400))
			Current_Time = 86400 + Seconds_Remaining
		else
			repeat
				Number = Num_OCR(ROI, "c")
				Seconds_Remaining = Convert_To_Seconds(Number)
				if (Seconds_Remaining > 86400) then wait(.5) end
			until(Seconds_Remaining < 86400)
			Current_Time = Seconds_Remaining
		end
		if (Current_Time < Return_time) then Return_time = Current_Time end
	end
	usePreviousSnap(false)
	
	--Check Points Chest
	Logger("Checking Points Chest")
	local r, g, b = getColor(Location(667,695))
	if not(isColorWithinThreshold(r, g, b, 139, 203, 233, 10)) then --- GET COLOR
		Logger("Clicking Points Chests")
		local imgResult = PressRepeatNew(Location(667,695), {"Tap Anywhere.png", "Points Chest.png"}, 1, 4)
		if (imgResult.name == "Tap Anywhere") then
			Logger("Tap Anywhere Found and Closing!!!")
			PressRepeatNew(TargetOffset(imgResult.xy, "0", "-100"), "Recruitment Preview.png", 1, 3, nil, nil, 0.9, false, true)
		else
			Logger("No Rewards Found and Closing Point Chest Screen")
			PressRepeatNot(Location(667,695), "Points Chest.png", 1, 2) 
		end
	end
	
	Go_Back("Returning for Recruit in .." ..Get_Time(Return_time))
	return Return_time
end

function Claim_Rewards(Initial_Timer)
	Current_Function = getCurrentFunctionName()
	Logger("Checking My Rewards")
	
	if not (Side_Check_Opener()) then return 300 end
	
	Logger("Searching for Images")
	local Troop_Training, Rewards_Status, Next_Chest, Zero, Time_Region, Number, OCR_Status, treeOfLife, Pet_Adventure_Repeater
	Troop_Training = SearchImageNew("Troop Training.png", nil, 0.9, true, false, 5)
	if not(Troop_Training.name) then
		Logger("Online Rewards NOT Found! Closing")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	Rewards_Status = SearchImageNew("Online Rewards.png", nil, 0.9, true)
	Logger("Swiping to Look for Online Rewards")
	if not(Rewards_Status.name) then
		Pet_Adventure_Repeater = 0
		for i = 1, 10 do
			if (i == 1) or ((i >= 3) and not(treeOfLife.name)) then
				swipe(Location(6, 845), Location(6, 10), .5)
				--wait(.2)
				--Press(Location(6, 845), 1)
				wait(.5)
				swipe(Location(6, 845), Location(6, 10), .5)
				wait(.2)
				Press(Location(6, 845), 1)
				wait(.2)
			end
			if not(Rewards_Status.name) then wait(.5) end
			Rewards_Status = SearchImageNew("Online Rewards.png", nil, 0.9, true)
			if (Rewards_Status.name) then break end
			treeOfLife = SearchImageNew("Tree of Life.png", nil, 0.9, true)
			if (treeOfLife.name) then
				if (Pet_Adventure_Repeater == 2) then break
				else Pet_Adventure_Repeater = Pet_Adventure_Repeater + 1 end
			end
		end
	end
	if (Rewards_Status.name) then
		if (Claim_Rewards_Initial_Timer) then
			Claim_Rewards_Initial_Timer = nil
		end
		Logger("Online Rewards Found! Claiming")
		Rewards_Status = SingleImageWait("Online Rewards.png", 9999)
		Logger("Getting Regions for OCR")
		PressRepeatNew(Rewards_Status, "Next Chest Ready In.png", 1, 4, nil, Lower_Half, 0.95, nil, true)
		local min_range = (screen.x/2) - 10
		local max_range = (screen.x/2) + 10
		repeat 
			Next_Chest = SearchImageNew("Next Chest Ready In.png", Lower_Half, 0.95, true, 99)
		until(Next_Chest.name) and ((Next_Chest.x >= min_range) and (Next_Chest.x <= max_range))
		Zero = SearchImageNew("ocr/or0.png", Region(Next_Chest.sx, Next_Chest.sy + Next_Chest.h, Next_Chest.w, 200), 0.95, true, 99)
		Time_Region = Region(Next_Chest.sx, Zero.sy, Next_Chest.w, Zero.h)
		Time_Region:highlight()
		repeat Number, OCR_Status = numberOCRNoFindException(Time_Region, "ocr/or") until(OCR_Status) and (Number > 0)
		Logger("Coming back in " ..Get_Time(Convert_To_Seconds(Number)))
		local new_reg = Region(Next_Chest.sx, Zero.sy + Zero.h, Next_Chest.w, Zero.h)
		new_reg:highlight(tostring(Get_Time(Convert_To_Seconds(Number))))
		
		wait(1)
		Time_Region:highlightOff()
		new_reg:highlightOff()
		local Remaining_Reset_Time = Get_Time_Difference()
		remaining_time = math.floor(Convert_To_Seconds(Number))
		if (remaining_time > Remaining_Reset_Time) then remaining_time = Remaining_Reset_Time end
		Go_Back(tostring(Get_Time(remaining_time)))
		Message.Online_Rewards = Message.Online_Rewards + 1
		return remaining_time
	else
		if not(Claim_Rewards_Initial_Timer) then
			Claim_Rewards_Initial_Timer = Initial_Timer
		end
		local Time_List2 = Time_List
		local return_time = 300
		local Current_Timer = Main.Claim_Rewards.timer:check()
		for i, Time_Current in ipairs(Time_List2) do
			table.remove(Time_List, i)
			if (Current_Timer < Time_Current) then
				--print(Time_Current)
				return_time = Time_Current - Claim_Rewards_Initial_Timer:check()
				break				
			end
		end
		local Remaining_Reset_Time = Get_Time_Difference()
		if (return_time > Remaining_Reset_Time) then return_time = Remaining_Reset_Time end
		Logger("Online Rewards NOT Found! Returning in " ..Get_Time(return_time))
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return return_time
	end
end

local function getNextScheduledTime(timesList, currentTime)
    local currentMinutes = timeToHoursAndMinutes(currentTime)
    local currentSeconds = timeToSeconds(currentTime)
    local nextTime = timesList[1]  -- Default next time
    local secondsUntilNext = 0

    for _, timeStr in ipairs(timesList) do
        local timeSeconds = timeToSeconds(timeStr)
        if timeSeconds > currentSeconds then
            nextTime = timeStr
            secondsUntilNext = timeToSeconds(timeStr) - currentSeconds
            break
        end
    end

    -- If next time is earlier than current time, calculate until next day's same time
	if timeToSeconds(nextTime) <= timeToSeconds(currentTime) then
		secondsUntilNext = (24 * 3600) - currentSeconds + timeToSeconds(nextTime)
	end
    return nextTime, secondsUntilNext
end

local function extractTimeComponents(timeStr)
    local hour, min, sec = string.match(timeStr, "(%d%d):(%d%d):(%d%d)")
    return tonumber(hour), tonumber(min), tonumber(sec)
end

function Populate_Chief_Order_Events()
	Chief_Order_Events = {}
	local Order_Events, Order_Events_Final = {}, {}
	local event_list = {"Urgent Mobilization", "Rush Job", "Productivity Day", "Festivities"}
	local Order_Events, Nearest_Time_List = {}, {}
	for _, event in ipairs(event_list) do
		local event_var = event:gsub(" ", "_")
		if (_G[event_var]) then
			local Current_Event = event:gsub(" ", "_")
			local Current_Count = _G[Current_Event.. "_Count"] or 1
			Order_Events[event] = {}
			for i = 1, Current_Count do
				table.insert(Order_Events[event], string.format("%s:00", _G[Current_Event.."_Time"..i]))
				table.insert(Nearest_Time_List, string.format("%s:00", _G[Current_Event.."_Time"..i]))
			end
		end
	end
	table.sort(Nearest_Time_List, function(a, b)
		local hourA, minA, secA = extractTimeComponents(a)
		local hourB, minB, secB = extractTimeComponents(b)

		-- Compare hours first
		if hourA ~= hourB then
			return hourA < hourB
		end

		-- If hours are equal, compare minutes
		if minA ~= minB then
			return minA < minB
		end

		-- If minutes are also equal, compare seconds
		return secA < secB
	end)
	
	--print(table.concat(Nearest_Time_List, ", "))
	--local nextScheduledTime, secondsUntilNext = getNextScheduledTime(Nearest_Time_List, "07:30:00") -- 9PM
	local nextScheduledTime, secondsUntilNext = getNextScheduledTime(Nearest_Time_List, os.date("%H:%M:%S"))
	
	for event, value in pairs(Order_Events) do	
		for _, value_time in pairs(value) do
			if (value_time == nextScheduledTime) then
				table.insert(Order_Events_Final, event)
			end
		end
	end	

	for _, event in ipairs(event_list) do
		for i, Cur_CO in ipairs(Order_Events_Final) do
			if (event == Cur_CO) then table.insert(Chief_Order_Events, event) end
		end
	end
	return secondsUntilNext
end

------------------------------------------ ARENA -------------------------------------

local function Millions_Digit(number)
    local numberStr = tostring(number)
    if #numberStr > 1 then
        local modifiedStr = string.sub(numberStr, 1, -2) .. "." .. string.sub(numberStr, -1)
        local modifiedNumber = tonumber(modifiedStr)
        return modifiedNumber
    else
        return number
    end
end

local function Thousands_Digit(number)
    local numberStr = tostring(number)
    local firstDigit = string.sub(numberStr, 1, 1)
    local firstDigitNumber = tonumber(string.format("0.%s", firstDigit))
    return firstDigitNumber
end

function Attack_Squad(Fight_Button)
	usePreviousSnap(false)
	PressRepeatNew(Fight_Button.xy, "Squad Fight.png", 1, 2, nil, Lower_Half, 0.9, false, true)
	Logger("Clicking Squad Fight and wait for Completion")
	local Battle_Pause = PressRepeatNew("Squad Fight.png", "Arena Pause.png", 1, 4, Lower_Half, Lower_Left, 0.9, true, true) ---ERROR
	PressRepeatNew(Battle_Pause.xy, "Retreat.png", 1, 1, nil, nil, 0.9, false, true)
	local Battle_Result = PressRepeatNew("Retreat.png", {"Battle Victory.png", "Battle Defeat.png"}, 1, 2, nil, nil, 0.9, true, true)
	PressRepeatNew(4, "Arena Challenge List.png", 1, 4, nil, Upper_Half, 0.9, false, true)
	return Battle_Result
end


function purchaseArenaGems(maxPurchase)
	maxPurchase = tonumber(maxPurchase)
	while true do
		Logger("Clicking Plus Button")
		local plusStatus = PressRepeatNew(Main.Arena.dir.. "ArenaPlus.png", {Main.Arena.dir.. "Challenge Attempts.png", Main.Arena.dir.. "Purchased Maxed.png"}, 1, 2, nil, Region(0, 500, screen.x, 100))
		if (plusStatus.name == "Challenge Attempts") then
			Logger("Purchase Available")
			local curGems = SearchImageNew({Main.Arena.dir.. "1.png", Main.Arena.dir.. "2.png", Main.Arena.dir.. "3.png", Main.Arena.dir.. "4.png", Main.Arena.dir.. "5.png"}, nil, 0.9, true, false, 9999999)
			Logger("Gems Found: " .. curGems.name..  "00")
			local curGemsResult = tonumber(curGems.name)
			if (curGemsResult <= maxPurchase) then 
				Logger("Purchasing Current Gems")
				PressRepeatNew(curGems.xy, Main.Arena.dir.. "ArenaPlus.png", 1, 2)
			else 
				PressRepeatNew(Location(63, 278), Main.Arena.dir.. "ArenaPlus.png", 1, 2) 
				Logger("Current Gems is Above Max Purchase")
				wait(1)
				break
			end
		else
			Logger("Purchase Maxed")
			break
		end
	end
end


function Arena(arenaGems)
	Current_Function = getCurrentFunctionName()
	Logger("Starting Arena")
	
	if not (Side_Check_Opener()) then return 300 end
	
	Logger("Searching Image for Marksman")
	local Troop = SearchImageNew("City Marksman.png", nil, 0.92, true, false, 99)
	if not (Troop.name) then
		Logger("Troop Marksman Image not Found")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	Logger("Clicking Troop Marksman")
	PressRepeatNew(Troop.xy, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
	wait(1)
	Logger("Removing Unnecessary Button")
	while true do
		Press(Location(screen.x/2, screen.y/2), 1)
		local Troop_Train = SearchImageNew({"Troop Train.png", "Troop Train Logo.png"}, nil, 0.85)
		if (Troop_Train.name) then break end
	end
	Logger("Zooming In")
	wait(1)
	zoom(360, 760, 360, 380, 360, 760, 360, 1140, 200) -- zoom in
	Logger("Zooming Out and Searching for Arena")
	local zoomOutTimer, arenaBuilding, arenaChallengeFound = Timer()
	while true do
		zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300) --zoom out using X coordinates
		zoom(360, 380, 360, 760, 360, 1140, 360, 760, 200) -- zoom out using Y coordinates
		arenaBuilding = SearchImageNew({"Arena Building 1.png", "Arena Building 2.png"})
		if (arenaBuilding.name) then 
			Logger("Opening Arena Challenge")
			PressRepeatNew(arenaBuilding.xy, "Arena Challenge Available.png", 1, 2, nil, Lower_Half, 0.9, true, true)
			break
		else
			Press(Location(700, 810), 1)
			Logger("Trying to Open Arena Challenge")
			arenaChallengeFound = SingleImageWait("Arena Challenge Available.png", 3, Lower_Half)
			break
		end
		if (zoomOutTimer:check() > 10) then
			Logger("Cannot find Arena Building")
			return 300
		end
	end
	Logger("Searching Images for Power Region")
	local personal_power, personal_M, Hero_Power, personal_ROI
	personal_power = SearchImageNew("Arena Personal Power.png", Lower_Half, 0.9, true, false, 99999999999)
	personal_M = SearchImageNew("Arena Personal M.png", Lower_Half, 0.9, true)
	local Final_W = personal_power.w * 6
	if (personal_M.name) then Final_W = personal_M.sx - (personal_power.sx + personal_power.w + 1) end
	personal_ROI = Region(personal_power.sx + personal_power.w, personal_power.sy, Final_W, personal_power.h)
	Logger("Region Gathered Preparing for OCR")
	repeat Number, Number_Status = numberOCRNoFindException(personal_ROI, "ocr/t") until(Number_Status)	
	Logger("OCR Completed")	
	Hero_Power = Millions_Digit(Number)
	Logger("Opening Arena Challenge")
	PressRepeatNew("Arena Challenge Available.png", "Arena Challenge List.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
	wait(.5)
	local Challenge_List = {1, 2, 3, 4, 5}
	local Defeat_list = {}
	if not(arenaGems == "0") then purchaseArenaGems(arenaGems) end --if zero and you buy more challenges check if the arena fight color changes
	local Arena_Fight = findAllNoFindException(Pattern("Arena Fight OLD.png"):similar(0.9):color())
	local Daily_Challenges = SearchImageNew("Daily Challenges.png", Lower_Half, 0.9, false, false, 999999)
	Daily_Challenges_ROI = Region(Daily_Challenges.sx + Daily_Challenges.w - 10, Daily_Challenges.sy - 2, Daily_Challenges.w, Daily_Challenges.h)
	while true do
		repeat Arena_Remaining_Challenge, Number_Status = numberOCRNoFindException(Daily_Challenges_ROI, "ocr/c") until(Number_Status)
		if (Arena_Remaining_Challenge == 0) then break end
		Logger("Arena Challenge Remaining: " ..Arena_Remaining_Challenge)
		local Current_Power_List, Challenge_Victory, Button_Inactive = {}, false, false
		snapshotColor()
		for i = 1, table.getn(Arena_Fight) do
			Challenge_List[i] = {"power", "button"}
			local x,y,w,h = Arena_Fight[i]:getX(), Arena_Fight[i]:getY(), Arena_Fight[i]:getW(), Arena_Fight[i]:getH()
			local Arena_Fight_ROI = Region(50, y - h, screen.x - 100, h*3.2)
			local Proceed = true
			allianceList = Split(arenaExclusion, ";")
			Logger("Alliance Exclusion: " ..table.getn(allianceList))
			Logger("Alliance Exclusion: " ..allianceList[1])
			if (table.getn(allianceList) > 0) and not(allianceList[1] == "0") then
				Logger("Alliance Exclusion: Looking for State Hash")
				local stateROI = Region(152, (y - h) + 78,85, 26)
				--if i == 4 then scriptExit() end
				--Arena_Fight_ROI:highlight()
				local Hash = SingleImageWait("Arena/Hash.png", 2, stateROI, 0.9, true)
				--Arena_Fight_ROI:highlightOff()
				if (Hash) then
					Logger("Alliance Exclusion: State Hash Found Reading State")
					local curState = Num_OCR(stateROI, "t")
					Logger(string.format("Current State: " ..curState))
					for i, curAlliance in ipairs(allianceList) do
						if (string.find(tostring(curState), curAlliance)) then 
							Proceed = false
							Logger(string.format("Alliance Exclusion: Found! Excluding this State"))
						end
					end
				else
					Logger("Alliance Exclusion: State Hash Not Found")
				end
			end

			if (Proceed) then
				local Arena_Fist = SearchImageNew("Arena Fist.png", Arena_Fight_ROI) ----this
				local Arena_M = SearchImageNew({"Arena M Green.png", "Arena M Red.png"}, Arena_Fight_ROI, 0.85, true, false)
				local ROI
				if (Arena_M.name) then ROI = Region(Arena_Fist.sx + Arena_Fist.w, Arena_Fist.sy, Arena_M.sx - Arena_Fist.sx - Arena_M.w, Arena_Fist.h)
				else 
					Arena_M = SearchImageNew("Arena Star.png", Arena_Fight_ROI, 0.9, true, false, 9999) 
					ROI = Region(Arena_Fist.sx + Arena_Fist.w, Arena_Fist.sy, Arena_M.sx - Arena_Fist.sx - (Arena_M.w * 1.5), Arena_Fist.h)
				end
				Logger(string.format("Area %s: Region Gathered Starting OCR", i))
				if (Arena_M.name == "Arena Star") then table.insert(Challenge_List[i], 1, 0.9)
				else
					local Number = Num_OCR(ROI, "red")
					table.insert(Challenge_List[i], 1, Millions_Digit(Number))
				end
				
				local Current_Challenge_Power = Challenge_List[i][1]
				Logger(string.format("Area %s: Power: %s", i, Current_Challenge_Power))
				table.insert(Current_Power_List, Current_Challenge_Power)
				local Fight_Button = SearchImageNew({"Arena Fight.png", "Arena Fight Unavailable.png"}, Arena_Fight_ROI, 0.9, true, false, 9999) ----this
				if (Fight_Button.name == "Arena Fight") then --"Arena Fight Unavailable"
					if (Hero_Power > Current_Challenge_Power) then
						usePreviousSnap(false) ------- Enemy Found
						Logger(string.format("Area %s: Starting Attack: Enemy Power: %s - Personal Power: %s", i, Current_Challenge_Power, Hero_Power))
						Battle_Result = Attack_Squad(Fight_Button)
						wait(2)
						Logger(string.format("Area %s: Battle Result: %s", i, Battle_Result.name))
						if (Battle_Result.name) == "Battle Victory" then
							Challenge_Victory = true
							Message.Arena_Result = Message.Arena_Result + 1
							break
						else table.insert(Defeat_list, Current_Challenge_Power) end
					end
				else Button_Inactive = true end
				table.insert(Challenge_List[i], 2, Fight_Button)
			end
		end

		if (Button_Inactive) then
			usePreviousSnap(false)
			break
		end
		
		if not(Challenge_Victory) then
			repeat Arena_Remaining_Challenge, Number_Status = numberOCRNoFindException(Daily_Challenges_ROI, "ocr/c") until(Number_Status)
			if (Arena_Remaining_Challenge == 0) then break end
			Logger("Checking Refresh Status")
			local Refresh_Status = SearchImageNew({"Arena Free Refresh.png", "Arena Paid Refresh.png"}, Lower_Half, 0.9, true)
			Logger(string.format("Refresh Found: %s", Refresh_Status.name))
			if (Refresh_Status.name == "Arena Free Refresh") then 
				Logger("Clicking Refresh")
				Press("Arena Free Refresh.png", 1)
				local Arena_Wait
				repeat
					wait(1)
					Arena_Wait = findAllNoFindException(Pattern("Arena Fist.png"):similar(0.9):color())
				until(table.getn(Arena_Wait) == 5)
			else
				--Current_Power_List -- add checker if list is empty
				if (table.getn(Current_Power_List) > 0) then
					Logger("Rechecking Enemy Power to Attack")
					local set1 = {}
					for _, item in ipairs(Defeat_list) do set1[item] = true end
					for i = #Current_Power_List, 1, -1 do
						local item = Current_Power_List[i]
						if set1[item] then table.remove(Current_Power_List, i) end
					end
					Logger("Current List: " ..table.getn(Current_Power_List))
					for i, v in ipairs(Current_Power_List) do Logger(string.format("Power: %s - %s", i, v)) end
					local lowest = math.min(unpack(Current_Power_List))
					for _, v in ipairs(Challenge_List) do
						if (v[1] == lowest) then
							Logger("Attacking Enemy")
							Battle_Result = Attack_Squad(v[2])
							wait(2)
							if (Battle_Result.name == "Battle Defeat") then table.insert(Defeat_list, v[1]) end
							Logger(string.format("Battle Result: %s", Battle_Result.name))
						end
					end
				else
					Logger("Power List is 0")
					break
				end
			end	
		end
		usePreviousSnap(false)
	end		
	Go_Back("Arena Completed and Closing")
	local result = Get_Time_Difference(nil, Arena_Time)
	if (result < 10) then 
		result = 86400 - result
	end
	return result
end

function War_Academy_Fn(RedeemAmount)
	Logger("Starting War Academy")
	local War_Academy_Folder = "War Academy/"
	Current_Function = getCurrentFunctionName()
	
	if not (Side_Check_Opener()) then return 300 end
	
	Logger("Searching Image for Infantry")
	local Troop = SearchImageNew("City Infantry.png", nil, 0.92, true, false, 99)
	if not (Troop.name) then
		Logger("Troop Infantry Image not Found")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	Logger("Clicking Troop Infantry")
	PressRepeatNew(Troop.xy, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
	Logger("City Opened! waiting for screen to load")
	wait(2)
	Logger("Searching for War Academy")
	local War_Academy_1 = SearchImageNew({War_Academy_Folder.. "War Academy 1.png", War_Academy_Folder.. "Upgrading.png"}, nil, 0.9, false, false, 5)
	if not(War_Academy_1.name) then
		Logger("War Academy is not Available and Closing")
		Go_Back()
		return 300
	end
	
	Logger("Clicking War Academy and Waiting for Research Button")
	local Research_Btn = PressRepeatNew({War_Academy_Folder.. "War Academy 1.png", War_Academy_Folder.. "Upgrading.png"}, War_Academy_Folder.. "War Academy Research Btn.png", 1, 2)
	--local Research_Btn = PressRepeatNew(War_Academy_Folder.. "War Academy 1.png", War_Academy_Folder.. "War Academy Research Btn.png", 1, 2)
	Logger("Checking if There is a Redeem Button on Screen")
	local Quick_Redeem = SearchImageNew(War_Academy_Folder.. "War Academy Initial Redeem.png", nil, 0.9, false, false, 1)
	local Steel_ROI = Region(450, 600, 180, 75) --static
	if (Quick_Redeem.name) then
		Logger("Redeem Button found and Clicking")
		PressRepeatNew(Quick_Redeem.xy, War_Academy_Folder.. "Steel.png", 1, 3, nil, nil, 0.9, false, false, false, true)
	else
		Logger("Redeem Button not found! Clicking Research Button")
		local Redeem = PressRepeatNew(Research_Btn.xy, War_Academy_Folder.. "Redeem.png", 1, 2)
		Logger("Clicking Redeem")
		PressRepeatNew(Redeem.xy, War_Academy_Folder.. "Steel.png", 1, 3, nil, nil, 0.9, false, false, false, true)
	end
	wait(3)
	Logger("Checking for Redeem Availability")
	snapshotColor()
	local Redeem_Status = SearchImageNew({War_Academy_Folder.. "Redeem Available.png", War_Academy_Folder.. "Redeem Unavailable.png"}, Steel_ROI, 0.9, true, false, 999)
	local r, g, b = getColor(Location(603, 639))
	local redeemColor = isColorWithinThreshold(r, g, b, 79, 165, 252, 10)
	local curRemaining = Num_OCR(Region(582, 577, 40, 20), "AM")
	usePreviousSnap(false)
	if (Redeem_Status.name == "Redeem Available") and (redeemColor) then
		local maxRemaining = 20
		local redeemedTotal = maxRemaining - curRemaining
		local remainingRedeem = RedeemAmount - redeemedTotal
		curRemaining = math.ceil(curRemaining/2)
		if (remainingRedeem > 0) then
			Logger("Redeem Available and Clicking")
			local Slider = PressRepeatNew(Redeem_Status.xy, {"Slider Button.png", War_Academy_Folder.. "Obtain More.png"}, 1, 3)
			if (Slider.name == "Obtain More") then
				Go_Back("Redeem Completed")
				return Get_Time_Difference()
			end
			
			--if (RedeemAmount > 10) then
			if (remainingRedeem > curRemaining) then
				Logger("Swiping to Max Redeem")
				swipe(Location(Slider.x, Slider.y), Location(screen.x - 10, Slider.y), 1)
			end
			
			local curROI = Region(480, 805, 60, 35)
			local curAmount = Num_OCR(curROI, "a")
			local maxedCounter, maxedTotal = 0, 1
			--while not(RedeemAmount == curAmount) do
			while not(remainingRedeem == curAmount) do
				if (curAmount > remainingRedeem) then
				--if (curAmount > RedeemAmount) then
					Logger("Clicking Minus Button")
					click(Location(108, 822))
				elseif (curAmount < remainingRedeem) then
				--elseif (curAmount < RedeemAmount) then
					Logger("Clicking Plus Button")
					click(Location(413, 822))
				end
				wait(.1)
				Logger("Reading OCR")
				curAmount = Num_OCR(curROI, "a")
				if (maxedTotal == curAmount) then
					maxedCounter = maxedCounter + 1
					if (maxedCounter >= 2) then break end
				else maxedTotal = curAmount end
			end
			Logger("Clicking Redeem")
			PressRepeatNew(War_Academy_Folder.. "Redeeming Steel.png", {War_Academy_Folder.. "Redeem Unavailable.png", War_Academy_Folder.. "Redeem Available.png"}, 1, 2, nil, Steel_ROI, 0.9, false, true)
		end	
	end
	Go_Back("Redeem Completed")
	return Get_Time_Difference()
end

function theLabyrinth()
	Logger("Starting The Labyrinth")
	local labyrinthDir = "Labyrinth/"
	local labyrinthBtn = SearchImageNew(labyrinthDir.. "Labyrinth Btn.png")
	if not(labyrinthBtn.name) then
		Logger("The Labyrinth Image not Found")
		return 1800
	end
	Logger("Opening The Labyrinth")
	PressRepeatNew(labyrinthBtn.xy, labyrinthDir.."The Labyrinth Label.png", 1, 2, nil, Upper_Half)
	while true do
		Logger("Searching For Exclamation")
		local exclamation = SingleImageWait(labyrinthDir.. "Exclamation.png", 3)
		if not(exclamation) then
			Logger("Exclamation not Found and closing")
			break 
		end
		Logger("Clicking Exclamation and checking raid status")
		local raidStatus = PressRepeatNew(exclamation, {labyrinthDir.."Raid.png", labyrinthDir.."Quick Challenge.png"}, 1, 2, nil, Lower_Half)
		if (raidStatus.name == "Quick Challenge") then
			Logger("Quick Challenge found and clicking")
			local quickChallengeStatus = PressRepeatNew(labyrinthDir.."Quick Challenge.png", {labyrinthDir.. "Skip.png", labyrinthDir.. "Tap Anywhere to Exit.png"}, 1, 5, Lower_Half)
			if (quickChallengeStatus.name == "Skip") then
				Logger("Trying to Skip")
				PressRepeatNew(quickChallengeStatus.xy, labyrinthDir.. "Tap Anywhere to Exit.png", 1, 5, nil, Lower_Half)
			end
			local anywhere = SingleImageWait(labyrinthDir.. "Tap Anywhere to Exit.png", 999999)
			Logger("Closing Tap Anywhere")
			PressRepeatNew(Location(680, 1470), labyrinthDir.. "Challenge.png", 1, 1)
		else
			Logger("Raid found and clicking")
			local claim = PressRepeatNew(raidStatus.xy, labyrinthDir.."Claim.png", 1, 4)
			Logger("Claiming Rewards")
			PressRepeatNew(claim.xy, labyrinthDir.."Challenge.png", 1, 1)
		end
		Logger("Going back to main Labyrinth screen")
		PressRepeatNew(4, labyrinthDir.."The Labyrinth Label.png", 1, 5)
	end
	Go_Back("The Labyrinth Completed")
	preferencePutString("mainTheLabyrinth", Current_Date)
	return Get_Time_Difference()
end

function Crystal_Laboratory_Fn()
	Logger("Starting Crystal Laboratory")
	local Crystal_Laboratory_Folder = "Crystal Laboratory/"
	Current_Function = getCurrentFunctionName()
	if not(Side_Check_Opener()) then return 300 end
	
	Logger("Searching Image for Lancer")
	local Troop = SearchImageNew("City Lancer.png", nil, 0.92, true, false, 99)
	if not (Troop.name) then
		Logger("Troop Lancer Image not Found")
		PressRepeatNew("Side Opened.png", "Side Closed.png", 1, 2, nil, nil, 0.9, true, true)
		return 300
	end
	Logger("Clicking Troop Lancer")
	PressRepeatNew(Troop.xy, "World.png", 1, 4, nil, Lower_Right, 0.95, false, true)
	Logger("City Opened! waiting for screen to load")
	wait(2)
	Logger("Searching for Crystal Laboratory")
	local Crystal_Laboratory_1 = SearchImageNew(Crystal_Laboratory_Folder.. "Crystal Laboratory 1.png", nil, 0.9, false, false, 5)
	if not(Crystal_Laboratory_1.name) then
		Logger("Crystal Laboratory is not Available and Closing")
		Go_Back()
		return 300
	end
	Logger("Clicking Crystal Laboratory and Checking Refine")
	local Refine = PressRepeatNew(Crystal_Laboratory_Folder.. "Crystal Laboratory 1.png", {Crystal_Laboratory_Folder.. "Refine Available.png", Crystal_Laboratory_Folder.. "Refine Unavailable.png"}, 1, 2, nil, nil, 0.9, false, true)
	if (Refine.name == "Refine Available") then
		Logger("Refine Available and Clicking")
		while not(SearchImageNew(Crystal_Laboratory_Folder.. "Refine Unavailable.png", Refine.r, 0.9, true).name) do
			Press(Refine.xy, 1)
			wait(.5)
		end
	end
	Logger("Checking for Super Refinement 50% Off")
	while true do
		if (SingleImageWait(Crystal_Laboratory_Folder.. "Fifty Off.png", 1)) then
			Logger("Super Refinement 50% Off Found and Clicking")
			Press(Crystal_Laboratory_Folder.. "Super Refine.png", 1)
			wait(1)
		else break end
	end	
	Go_Back("Crystal Laboratory Completed")
	return Get_Time_Difference()
end

function Compare_March()
	Logger("Preparing Marching Region")
	local Marching = SearchImageNew("Marching.png", Upper_Half, 0.9, true)
	if (Marching.name) then
		local Min_March
		Marching_Region = Region(Marching.sx, Marching.sy, screen.x, Marching.h)
		Logger("Looking for Divider")
		if not(Divider_March) then repeat Divider_March = SearchImageNew("March Divider.png", Marching_Region, 0.9, true) until(Divider_March.name) end
		local Divider_Region_Min = Region(Divider_March.sx - 150, Divider_March.sy - 5, Divider_March.sx - (Divider_March.sx - 150), Divider_March.h + 10)
		local Divider_Region_Max = Region(Divider_March.sx, Divider_March.sy - 5, 150, Divider_March.h + 10)	
		Logger("Checking Current March")
		Min_March = SearchImageNew({"M1.png", "M2.png", "M3.png", "M4.png", "M5.png", "M6.png"}, Divider_Region_Min, 0.9, true, false, 5)
		Logger("Checking total March")
		if not(Max_March) then Max_March = SearchImageNew({"M1.png", "M2.png", "M3.png", "M4.png", "M5.png", "M6.png"}, Divider_Region_Max, 0.9, true, false, 5) end
		if (Min_March.name) and (Max_March.name) and (Min_March.name == Max_March.name) then return false
		else return true end
	else return true	
	end
end

function flags_checker() --check flags available
	Logger()
	local function flagClicker(curFlag, flagNumber)
		local flagTimer = Timer()
		while true do
			if (flagTimer:check() > 2) then flagTimer:set() end
			click(curFlag.f.xy)
			repeat
				if isColorWithinThresholdHex(Location(curFlag.f.sx, curFlag.f.y), "#F5BC3D", 10) then
					return multiHexColorFind(Location(237, 320), {"#FFFFFF", "#2A60A0"}, 10) == "#FFFFFF"
					--return multiHexColorFind(Location(237, 305), {"#FFFFFF", "#2A60A0"}, 10) == "#FFFFFF"
				end
			until(flagTimer:check() > 2)
		end
	end
	
	local now = os.date("*t")
	local curSeconds = (now.hour * 3600) + (now.min * 60) + now.sec
	for i = 1, 6 do --checks time and only click flags if bot thinks there's a flag available
		if not(i == tonumber(Bear_Flag_Req)) then
			local curFlag = flags_coordinates[i]
			if (curFlag) and (curSeconds > curFlag.ft) and (flagClicker(curFlag, i)) then return i end
		end
	end
	
	for i = 1, 6 do -- when bot thinks there's no flags available bot should click from flag 1 to 6
		if not(i == tonumber(Bear_Flag_Req)) then
			local curFlag = flags_coordinates[i]
			if (curFlag) and (flagClicker(curFlag, i)) then return i end
		end
	end
	return false
	--Get_Flags_Coordinates()
	--
end

----------------------------------- RALLY ------------------------------------------
function Check_Heroes()
	snapshotColor()
		--local Hero1, Hero2, Hero3
		for i = 1, 3 do
			local Hero_Dir = "Hero List/Marksman/"
			if i == 2 then Hero_Dir = "Hero List/Lancer/" elseif i == 3 then Hero_Dir = "Hero List/Infantry/" end
			if not(SearchImageNew(string.format("%s%s.png", Hero_Dir, _G["Rally_Hero" ..i]), Region(93, 243, 534, 206), 0.9, false).name) then 
				usePreviousSnap(false)
				return false
			end
		end
	usePreviousSnap(false)
	return true
end

function Join_March_Checker()
	local Available_Rally = {}
	snapshotColor()
	local Rally_List = findAllNoFindException(Pattern("Rally Plus.png"):similar(0.95):color())
	local Troops_Divider = findAllNoFindException(Pattern("Rally Troops Divider.png"):similar(0.9))
	for ip, plus in ipairs(Rally_List) do
		for i, divider in ipairs(Troops_Divider) do
			if isYWithinRegionYButNotX(plus:offset(0, -67), divider) then
				Available_Rally[ip] = {plus=plus, divider=divider}
				break
			end
		end
	end
	for i=1, table.getn(Rally_List) do
		local PlusX, PlusY, PlusW, PlusH = Available_Rally[i].plus:getX(), Available_Rally[i].plus:getY(), Available_Rally[i].plus:getW(), Available_Rally[i].plus:getH()
		local dividerX, dividerY, dividerW, dividerH = Available_Rally[i].divider:getX(), Available_Rally[i].divider:getY(), Available_Rally[i].divider:getW(), Available_Rally[i].divider:getH()
		local ROI_Current = Region(PlusX - 335, dividerY, dividerX - (338 - PlusW) + dividerW + (dividerW/2), dividerH)
		local ROI_Max = Region(dividerX + dividerW, dividerY, PlusX - (dividerX + dividerW) - 50, dividerH)
		repeat Current_Number, Number_Status = numberOCRNoFindException(ROI_Current, "ocr/jr") until(Number_Status)
		repeat Max_Number, Number_Status = numberOCRNoFindException(ROI_Max, "ocr/jr") until(Number_Status)
		if ((Current_Number + preferenceGetNumber("Troop_Rally_Max", 150000)) < Max_Number) then 
			usePreviousSnap(false)
			return Available_Rally[i].plus
		end
		break
	end
	usePreviousSnap(false)
	return false
end

function Capture_Troop_Count()
	local Deployment_Exclamation = SearchImageNew("Deployment Exclamation.png", Upper_Left, 0.9, false, false, 9999)
	local Rally_Logo = SearchImageNew("Rally Troop Logo.png", Upper_Left, 0.9, false, false, 9999)
	local ROI = Region(Rally_Logo.sx + Rally_Logo.w, Rally_Logo.sy, Deployment_Exclamation.sx - (Rally_Logo.sx + Rally_Logo.w), Rally_Logo.h)
	ROI:saveColor("Bear Event/Troop Count.png")
	Capture_Troop_Status = true
end

function checkRallyTime(x, y, event)
	local rallyTimeLeft = 300
	snapshotColor()
	local remainingRallyTime = Char_OCR(Region(x - 42, y - 166, 115, 30), rallyTimeCharTable) --get dynamic ROI
	local now = os.date("*t")
	Logger(string.format("OCR Result: " ..remainingRallyTime))
	if not(remainingRallyTime == "0/0") then
		local hour, minute, second = remainingRallyTime:match("^(%d+):(%d%d):(%d%d)$")
		if (event == "bear") and (minute) and (tonumber(minute) <= 5) and (second) then rallyTimeLeft = (tonumber(minute) * 60) + tonumber(second) end
	end
	usePreviousSnap(false)
	local fTime = ((now.hour * 3600) + (now.min * 60) + now.sec) + rallyTimeLeft + Main.Bear_Event.marchTime --22 is my personal march time to bear
	local rallyTime = Get_Time(fTime)
	Logger(string.format("Processed Result: " ..rallyTime))
	return {s = rallyTimeLeft, t = rallyTime, ft = fTime}
end

function Join_Rally(Bear_Rally_Timer, Bear_Rally_Cool_Down, Event_Status)
	Logger("Searching for Rally Image")
	local Rally_Image = SearchImageNew("Rally Image.png", nil, 0.9, true)
	if (Rally_Image.name) then
		if not(Compare_March()) then return 1 end -- some bugs
		Logger("Compare March Completed")
		local Swipe_Count = 1
		while true do
			Logger("Clicking Rally Button")
			click(Rally_Image.xy)
			local rallyScreen = SingleImageWait("Bear Event/War.png", 2, Region(0, 0, 180, 70), 0.9, true)
			if (rallyScreen) then break end
		end
		Logger("Rally Screen Opened")
		while true do
			Logger("Searching for Rally List")
			local Rally_List = findAllNoFindException(Pattern("Rally Plus.png"):similar(0.95):color())
			Logger(string.format("Rally List Found: %s", table.getn(Rally_List)))
			for i, v in ipairs(Rally_List) do
				Logger("Checking Current Rally")
				local x,y,w,h,xy = v:getX(), v:getY(), v:getW(), v:getH(), string.format("%s,%s", v:getCenter():getX(), v:getCenter():getY())
				local rallyCharOCR_Initial = Char_OCR(Region(x - 338, y - 70, x - (x - 300), h), rallyTeamCharTable) --Reading Rally Troop Count
				rallyCharOCR_Initial = string.gsub(rallyCharOCR_Initial, ":", "")
				if not(rallyCharOCR_Initial == "0/0") and string.match(rallyCharOCR_Initial, "^%d%d+/%d%d+$") then --Checking if Current Rally Troop Count is Enough
					local rallyCharOCR = Split(rallyCharOCR_Initial, "/")
					Logger(string.format("Rally OCR Result: %s", rallyCharOCR_Initial))
					if (typeOf(rallyCharOCR) == "table") and (table.getn(rallyCharOCR) == 2) and (rallyCharOCR[1] and (string.len(rallyCharOCR[1]) > 0)) and (rallyCharOCR[2] and (string.len(rallyCharOCR[2]) > 0)) then
						Troop_Rally_Max = tonumber(Troop_Rally_Max)
						Logger(string.format("Current: %s | Max: %s | Minimum: %s", rallyCharOCR[1], rallyCharOCR[2], Troop_Rally_Max))
						if ((tonumber(rallyCharOCR[2]) - tonumber(rallyCharOCR[1])) >= Troop_Rally_Max) then
							if ((Bear_Rally_Cool_Down - Bear_Rally_Timer:check()) < 3) then
								Go_Back("Going Back")
								return 1
							end
							local res = checkRallyTime(x, y, "bear")
							--local Deploy_Status = PressRepeatNew(v, {"City Deploy.png", "Rally March Queue Limit.png", "Rally March Queue Limit Frame.png", "Rally March Queue Limit2.png", "Rally Captain.png", "Bear Event/March Queue Prompt 1.png"}, 1, 2, nil, nil, 0.85, false, false)
							local deployTimer = Timer()
							local Deploy_Status = PressRepeatNew(v, {"City Deploy.png", "Rally March Queue Limit.png", "Rally March Queue Limit Frame.png", "Bear Event/March Queue Prompt 1.png", "Bear Event/Rally Bonus.png"}, 1, 2, nil, nil, 0.85, false, false)
							Logger(string.format("Image Found: %s | Timer: %s", Deploy_Status.name, tostring(deployTimer:check())))
							if (Deploy_Status.name == "City Deploy") then --- IS this the deploy screen?
								local Task = true
								Logger("Clicking Deploy and Checking Status")
								if (CHARACTER_ACCOUNT == "Main") and (Event_Status == "Bear") and (Enable_Check_Hero) and (Check_Heroes()) then
									Go_Back("Required Hero Found in Joining Rally")
									return 1
								end
								snapshotColor()
								local marchTime = Get_March_Time()
								if (CHARACTER_ACCOUNT == "Main") and (Check_Troop_Count) then
									Logger("Final Checking on Troop Count")
									local Troop_Min_Max_Count = Num_OCR(Region(5, 179, screen.x/2, 31), "t")
									usePreviousSnap(false)
									Logger()
									if not(contains_number(Troop_Min_Max_Count, Troop_Rally_Max)) then
										Logger("Troop Count less than Required March")
										Task = false
										while true do
											Logger("Pressing Key Event 4")
											keyevent(4)
											Logger("Waiting for Settings Image to Appear")
											if (SingleImageWait("Bear Event/Settings.png", 1, Region(655, 13, 52, 53), 0.9, true)) then
												Logger("Settings Image found!")
												break
											elseif (SingleImageWait("City.png", 0, Lower_Most_Half, 0.9, true)) then
												Logger("Homescreen Found Instead of Rally Screen")
												local Rally_Image = SearchImageNew("Rally Image.png", nil, 0.9, true)
												PressRepeatNew("Rally Image.png", "Bear Event/War.png", 1, 2, nil, Region(0, 0, 180, 70))
												break
											end
										end
									else Logger("Troop Count Checking Completed") end
								end
								usePreviousSnap(false)
								if (Task) then
									local flagSelected = false
									if (CHARACTER_ACCOUNT == "Main") and (Joiner_Flags) then
										Logger("Flags Checker")
										flagSelected = flags_checker()
									end
									
									local result = Get_Time_Difference(nil, res.t) --before pressing okay check time difference
									if (result > marchTime) then 
										Logger("Clicking Deploy and Checking Screens")
										if (CHARACTER_ACCOUNT == "Main") and (Joiner_Flags) and (flagSelected) then
											flags_coordinates[flagSelected].ft = res.ft
										end
										local Deploy_Result = PressRepeatNew(Deploy_Status.xy, {"Confirmation.png", Main.Bear_Event.dir.. "War.png"}, 1, 2, nil, Upper_Half, 0.9, false, true)
										if (Deploy_Result.name == "Confirmation") then							
											PressRepeatNew(4, {"Auto Join.png", "Auto Joining.png"}, 1, .5, nil, Lower_Half, 0.9, false, true)
										end
									else PressRepeatNew(4, {"Auto Join.png", "Auto Joining.png"}, 1, .5, nil, Lower_Half, 0.9, false, true) end
								else
									Logger("Skipping Current Rally")
								end
							elseif (Deploy_Status.name == "Rally Captain") then
								PressRepeatNew(4, {"Auto Join.png", "Auto Joining.png"}, 1, .5, nil, Lower_Half, 0.9, false, true)
							elseif (Deploy_Status.name == "Rally Bonus") then
								Logger("Rally Bonus Found!")
								while true do
									Logger("Pressing Key Event 4")
									keyevent(4)
									Logger("Waiting for Settings Image to Appear")
									if (SingleImageWait("Bear Event/Settings.png", 1, Region(655, 13, 52, 53), 0.9, true)) then
										Logger("Settings Image found!")
										break
									elseif (SingleImageWait("City.png", 0, Lower_Most_Half, 0.9, true)) then
										Logger("Homescreen Found Instead of Rally Screen")
										local Rally_Image = SearchImageNew("Rally Image.png", nil, 0.9, true)
										PressRepeatNew("Rally Image.png", "Bear Event/War.png", 1, 2, nil, Region(0, 0, 180, 70))
										break
									end
								end
							else
								Go_Back()
								return 1
							end
						end
					end
				end
			end
			if (Swipe_Count == 6) then break end
			if (table.getn(Rally_List) == 0) then break end
			if (table.getn(Rally_List) >= 1) then
				Logger(string.format("Swiping: %s", Swipe_Count))
				swipe(Location(703, 1323), Location(703, 507), .6)
				swipeStopper(Location(703, 225), 3)
				Swipe_Count = Swipe_Count + 1
			else break end
			
		end
		Go_Back("Going Back")
	end
end

function clickFlag(flag)
	local curFlag = flags_coordinates[flag]
	local flagFound = false
	if (curFlag) then
		while not(flagFound) do
			click(curFlag.f.xy)
			t = Timer()
			while true do
				if(isColorWithinThresholdHex(Location(curFlag.f.sx, curFlag.f.y), "#F5BC3D", 5)) then
					flagFound = true
					break
				end
				if (t:check() > 2) then break end
			end
		end
	end
end

function Start_Bear_Rally(Bear_Image)
	Logger("Starting Bear Rally")
	local Rally = PressRepeatNew(Bear_Image, "Bear Rally.png", 1, 4, nil, nil, 0.9, false, true) --------- Clicks the bear image to open the option to click rally
	Logger("Clicking Bear Rally")
	local Hold_Rally = PressRepeatNew(Rally.xy, "Hold Rally.png", 1, 4, nil, nil, 0.9, false, true) --------- clicking rally to open hold rally screen
	Logger("Clicking Hold Rally")
	local City_Deploy = PressRepeatNew(Hold_Rally.xy, {"City Deploy.png", "Bear Single Target.png"}, 1, 4, nil, nil, 0.9, false, true) ----------- clicking hold rally screen to open rally screen
	if (City_Deploy.name == "Bear Single Target") then
		return 10
	end
	if (Bear_Troop_Flag) and (CHARACTER_ACCOUNT == "Main") then --------- Flags
		Logger()
		clickFlag(tonumber(Bear_Flag_Req))
		Logger(string.format("Flag Selected: %s", Bear_Flag_Req))
		if (Enable_Check_Hero) and not(Check_Heroes()) then
			Go_Back("Required Hero Not Found.")
			return 10
		end
	end
	Logger("Checking March Time")
	local total_Seconds = Get_March_Time()
	if (CHARACTER_ACCOUNT == "Main") then Main.Bear_Event.marchTime = total_Seconds end
	total_Seconds = (total_Seconds * 2) + 300
	Logger("March Time Taken and Clicking Deploy")
	PressRepeatNew(City_Deploy.xy, "City.png", 1, 4, nil, nil, 0.9, false, true)
	return total_Seconds
end

function bearTimeChecker(bearTime)
	local hour, min, sec = bearTime:match("(%d+):(%d+):(%d+)")
	local bearTimeSeconds = tonumber(hour) * 3600 + tonumber(min) * 60 + tonumber(sec) + 2
	while true do
		local t = os.date("*t")
		local currentSeconds = t.hour * 3600 + t.min * 60 + t.sec
		if (currentSeconds >= bearTimeSeconds) then break end
		wait(1)
	end
end

function checkRecall()
	while true do
		Logger("Checking Recall Buttons")
		local Recall_Btn = findAllNoFindException(Pattern("Recall Button.png"):color():similar(0.95))
		for i, recall in ipairs(Recall_Btn) do
			Logger("Recalling Marches")
			Press(recall, 1)
			Logger("Checking for Confirm Button")
			local confirmBtn = SingleImageWait("Confirm.png", 2)
			if (confirmBtn) then
				Logger("Confirm Button Found and Checking!")
				PressRepeatNew(confirmBtn, "City.png", 1, 2, nil, Lower_Right, 0.9, true, true)
				wait(.8)
			end
		end
		wait(1)
		if (table.getn(Recall_Btn) == 0) then break end
	end
end

function bearCalendarChecker(requiredTrap)
	Logger("Checking Calendar for Bear Day")
	Logger()
	local dir = "Bear Event/"
	--local colLoc = {["World"] = {loc = Location(379, 7), hex = "#FF1E1F"}}
	local taskListStatus = PressRepeatNew(Location(115,23), {dir.. "Local Time.png", dir.. "UTC Time.png", dir.. "Nothing.png"}, 1, 3) -- ADD NONE
	if (taskListStatus.name == "UTC Time")  then PressRepeatNew(Location(430,670), dir.. "Local Time.png", 1, 2) end
	if (taskListStatus.name == "Nothing")  then 
		Logger("No Task List Available")
		PressRepeatNew(Location(115,23), "City.png", 1, 2)
		return {status = false, seconds = 300}
	end
	Logger("Checking Time Format: " ..taskListStatus.name)
	local taskListStatus = SearchImageNew(dir.. "Local Time.png", nil, 0.9, true, false, 9999999)
	local swipeCounter, Task, bearSchedule, lastDateLabel = 0, false
	local ROI = Region(150, taskListStatus.sy + taskListStatus.h + 20, 300, 1520 - (taskListStatus.sy + taskListStatus.h) - 20)
	while true do
		local dateTimer, dateLabel = Timer()
		repeat 
			dateLabel = regionFindAllNoFindException(Region(Region(5, taskListStatus.sy + taskListStatus.h, 710, 1520 - (taskListStatus.sy + taskListStatus.h))), Pattern(dir.. "Date Label.png"):similar(0.9))
		until(#dateLabel > 0) or (dateTimer:check() > 1)
		if (#dateLabel == 0) and (swipeCounter == 0) then
			while not(#dateLabel > 0) do
				for i = 1, 2 do
					swipe(Location(17, 732), Location(17, 1492), 0.8)
					wait(0.2)
				end
				wait(2)
				dateTimer:set()
				repeat 
					dateLabel = regionFindAllNoFindException(Region(Region(5, taskListStatus.sy + taskListStatus.h, 710, 1520 - (taskListStatus.sy + taskListStatus.h))), Pattern(dir.. "Date Label.png"):similar(0.9))
				until(#dateLabel > 0) or (dateTimer:check() > 1)
			end
		end
		snapshotColor()
		local bearHuntList = regionFindAllNoFindException(ROI, Pattern(dir.. "Bear Hunt.png"):similar(0.9))
		local requiredTrapFound, bearHunt = false
		
		if (table.getn(bearHuntList) > 0) and (requiredTrap == "Any") then
			requiredTrapFound = true
			bearHunt = SearchImageNew(dir.. "Bear Hunt.png", ROI)
		else
			for i, curBearHunt in ipairs(bearHuntList) do
				local x,y,w,h = curBearHunt:getX(), curBearHunt:getY(), curBearHunt:getW(), curBearHunt:getH()
				local bearTrapType = SearchImageNew({dir.. "Trap 1.png", dir.. "Trap 2.png"}, Region(357, y, 55, h), 0.9, true, false, 999999)
				if (bearTrapType.name == requiredTrap) then 
					bearHunt = SearchImageNew(dir.. "Bear Hunt.png", curBearHunt)
					requiredTrapFound = true
					break
				end
			end
		end

		if (bearHunt) and (bearHunt.name) and (requiredTrapFound) then
			Logger("Bear Hunt image found checking for bear status")
			bearStatusROI = Region(570, bearHunt.sy, 120, bearHunt.h)
			if (SearchImageNew(dir.. "Ended.png", bearStatusROI).name) then break
			else
				if (#dateLabel > 0) then
					for i, curDate in ipairs(dateLabel) do
						local dateROI = Region(5, curDate:getY(), 710, curDate:getH())
						--dateROI:highlight(1)
						if (curDate:getY() < bearHunt.y) then
							Task = true
							if (isColorWithinThresholdHex(Location(60, curDate:getY() + (curDate:getH() / 2)), "#D39D63", 10)) then bearSchedule = "Today" --only time will true if it's today
							else bearSchedule = Char_OCR(dateROI, TaskTimeCharTable) end
						end	
					end
				else 
					Task, bearSchedule = true, lastDateLabel
				end
				break
			end
		else
			local color1, color2, color3 = isColorWithinThresholdHex(Location(360, 1410), "#C5D6F8", 3), isColorWithinThresholdHex(Location(360, 1450), "#C5D6F8", 3), isColorWithinThresholdHex(Location(360, 1490), "#C5D6F8", 3)
			if (color1) and (color2) and (color3) then break
			else
				if (#dateLabel > 0) then -- if there's a date label then check the last date. This allows you to check bear date if incase scrolling removes date label
					Logger("Checking Date")
					local dateROI = Region(5, dateLabel[#dateLabel]:getY(), 710, dateLabel[#dateLabel]:getH())
					while true do
						if (isColorWithinThresholdHex(Location(60, dateLabel[#dateLabel]:getY() + (dateLabel[#dateLabel]:getH() / 2)), "#D39D63", 10)) then lastDateLabel = "Today"
						else 	
							lastDateLabel = Char_OCR(dateROI, TaskTimeCharTable)
						end
						if (lastDateLabel == "Today") or (string.match(lastDateLabel, "^%d%d%d%d/%d%d/%d%d$")) then break end
					end
				end
				usePreviousSnap(false)
				swipeCounter = swipeCounter + 1
				Logger("Extra Task Available Swiping to check if there's more")
				swipe(Location(17, 1404), Location(17, 845), 1)
				swipeStopper(Location(17, 845), 2)
				if (swipeCounter >= 5) then break end
			end
		end
	end
	usePreviousSnap(false)
	if (Task) and (bearSchedule) then
		local hours, minutes, timeStr, totalSeconds, status, bearDate
		if (SearchImageNew(dir.. "In Progress.png", bearStatusROI).name) then
			Logger("Bear in Progress")
			local currentTime = os.date("*t")
			if currentTime.min < 30 then currentTime.min = 0 -- Round down
			else currentTime.min = 30  end
			hours, minutes = currentTime.hour, currentTime.min
			bearDate, timeStr = os.date("%Y/%m/%d"), os.date("%H:%M") --need to add time
		else
			Logger("Bear hunt available. Reading Time")
			repeat timeStr = Char_OCR(bearStatusROI, rallyTeamCharTable) until(#timeStr == 5)
			Logger("Time Found: " ..timeStr)
			hours, minutes = tonumber(timeStr:sub(1, 2)), tonumber(timeStr:sub(4, 5))
		end
		
		if (bearSchedule == "Today") then totalSeconds, status, bearDate = (hours * 3600) + (minutes * 60), true, os.date("%Y/%m/%d")
		else totalSeconds, status, bearDate = 300, false, bearSchedule end 
		Logger("Date Found: " ..bearSchedule)
		if (CHARACTER_ACCOUNT == "Main") then
			preferencePutString("mainBearNextRun", string.format("%s %s:00", bearDate, timeStr))
		else
			preferencePutString("altBearNextRun", string.format("%s %s:00", bearDate, timeStr))
		end
		
		Logger("Closing Task List")
		PressRepeatNew(Location(115,23), "City.png", 1, 2)
		return {status = status, seconds = totalSeconds}
	else
		Logger("Bear Event Unavailable")
		PressRepeatNew(Location(115,23), "City.png", 1, 2)
		return {status = false, seconds = 300}
	end
end

function bearBoolTimer(seconds)
	local maxMarchTime = -math.huge
	for key, value in pairs(Main.rssGather.marchTime) do if value > maxMarchTime then maxMarchTime = value end end
	if (maxMarchTime < 300) then maxMarchTime = maxMarchTime + 120 + Repeat_Delay end
	local prepTime = tonumber(seconds) - maxMarchTime
	Main.Bear_Event.bearPrepTime = Get_Time(seconds)
	local now = os.date("*t")
	local curTime = now.hour * 3600 + now.min * 60 + now.sec
	if (curTime >= prepTime) then return true end
	return false
end

function addDatetoDateTime(dt, days)
    local year, month, day, hour, min, sec = dt:match("(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
    local time_table = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }
    local timestamp = os.time(time_table)
    local new_timestamp = timestamp + (days * 24 * 60 * 60)
    local new_date_string = os.date("%Y/%m/%d %H:%M:%S", new_timestamp)
    return new_date_string
end

function Bear_Event(ATB, prepTime)
	Current_Function = getCurrentFunctionName()
	Logger("Bear Event Starting")
	if (CHARACTER_ACCOUNT == "Main") then Main.Bear_Event.running = true end
	local Bear_Rally_Cool_Down, Bear_Rally_Timer = 0
	checkRecall()
	if (CHARACTER_ACCOUNT == "Main") and (Auto_Join_Enabled) and (Main.Auto_Join.status) then 
		Auto_Join("OFF")
		Main.Auto_Join.status = false
	elseif (CHARACTER_ACCOUNT == "Alt_Bear") and (altAutoJoin) then Auto_Join("OFF") end
	if (SearchImageNew("Share Coordinates.png", nil, 0.9, true).name) then keyevent(4) end
	if ((CHARACTER_ACCOUNT == "Main") and (Bear_Pet_Skill)) or ((CHARACTER_ACCOUNT == "Alt_Bear") and (altPetSkills)) then Use_Pet_Skills("Battle") end
	if (SearchImageNew("Share Coordinates.png", nil, 0.9, true).name) then keyevent(4) end
	
	if (CHARACTER_ACCOUNT == "Main") and (Use_Troop_Ratio) then Balance_Troop_Ratio(nil, nil, nil, true)
	else Balance_Troop_Ratio() end -- Ratio_Infantry, Ratio_Lancer, Ratio_Marksman
	
	local actualBearTime = ATB
	if ATB:match("^%d%d:%d%d:%d%d$") then actualBearTime = ATB:sub(1, 5) end
	if ATB and not ATB:match("%d+:%d+:%d+") then 
		ATB = ATB .. ":00" 
		if (CHARACTER_ACCOUNT == "Main") then preferencePutString("Actual_Bear_Time", Actual_Bear_Time) end
	end
	Logger("Waiting for Bear Event to Start")
	local Bear_Remaining_Time = Get_Time_Difference(os.date("%H:%M:%S"), ATB)
	if (Bear_Remaining_Time > 10) and (Bear_Remaining_Time < 1800) then -- update to include if you are late with bear event
		--Logger("Sleeping in " ..Get_Time(Bear_Remaining_Time - 10))
		Logger(string.format("Sleep: %s (Until: %s)", Get_Time(Bear_Remaining_Time - 10), ATB))
		wait(Bear_Remaining_Time - 10)
		checkRecall()
		Logger("Checking if game still running")
		if (isForegroundGameLost()) then
			Logger("Home Screen Found! Reopening the Game")
			local result_timer = Timer()
			repeat
				startApp("com.gof.global")
				result = SearchImageNew("Alliance.png", nil, 0.9, true)
			until(result.name) or (result_timer:check() > 10)
			Logger("Game Reopened")
		end
	end
	Current_Function = getCurrentFunctionName()
	Logger("Waiting for Bear Event to Start")
	local Bear_Image = SingleImageWait("Bear Button.png", 600, Lower_Right, 0.9, true)
	if (Bear_Image) then
		bearTimeChecker(ATB) --add wait timer here to make sure to wait 2 seconds after	
		if (find_in_list({"byTask", "byEvents"}, Bear_Now_later)) and (Get_Time_Difference(ATB, os.date("%H:%M:%S")) > 60) and not(ABTTrigger) then --incase auto time was changed in-game
			ABTTrigger = true
			ATB = os.date("%H:%M:00")
		end
		Bear_Rally_Timer = Timer()
		local First_Wait_Trigger = true
		local rallyTrigger = Bear_Self_Rally
		while true do
			Logger("Refreshing Waiting for event")
			local Bear_Time_Difference = Get_Time_Difference(ATB, os.date("%H:%M:%S")) --[2024-06-19 17:59:59] Refreshing Waiting for event
			Logger("Remaining Event Time: " ..Bear_Time_Difference)
			
			if (rallyTrigger) and (Bear_Time_Difference < (1500 + Main.Bear_Event.marchTime)) and (Bear_Rally_Timer:check() > Bear_Rally_Cool_Down) and not(SearchImageNew("Special.png").name) then 
				Bear_Rally_Cool_Down = Start_Bear_Rally(Bear_Image)
				Bear_Rally_Timer:set()
			elseif (Bear_Time_Difference > (1500 + Main.Bear_Event.marchTime)) and (rallyTrigger) then 
				rallyTrigger = false
				Bear_Rally_Timer:set()
			end
			
			if (Bear_Time_Difference >= 1560) then break end ------ 1560 is 26 minutes event completed after 26 minutes
			Logger("Waiting for Available March")
			if (Region(193, 193, 55, 40):waitVanish(Pattern(string.format("Bear Event/Max %s.png", Bear_Max_March)):similar(0.93), Bear_Rally_Cool_Down - Bear_Rally_Timer:check())) then
				if (Bear_Join_rally) and (rallyTrigger) and ((Bear_Rally_Cool_Down - Bear_Rally_Timer:check()) > 5) then Join_Rally(Bear_Rally_Timer, Bear_Rally_Cool_Down, "Bear")
				elseif (Bear_Join_rally) and not(rallyTrigger) then Join_Rally(Timer(), 9999, "Bear") end
			end
			wait(2)
		end
	else
		Logger("Bear Button is not available")
	end

	Logger("Bear Event Completed. Enabling previous settings")
	Logger("Character Account: " ..CHARACTER_ACCOUNT)
	if (CHARACTER_ACCOUNT == "Main") then
		ABTTrigger = false
		preferencePutString("mainBearLastRun", string.format("%s %s:00", os.date("%Y/%m/%d"), actualBearTime)) --add when running bear event save the last date and time of bear event (e.g today)
		if (Auto_Gather) then -- set to run after 5 minutes
			Main.Meat.timer:set()
			Main.Wood.timer:set()
			Main.Coal.timer:set()
			Main.Iron.timer:set()
			Main.Meat.cooldown, Main.Wood.cooldown, Main.Coal.cooldown, Main.Iron.cooldown = 300, 300, 300, 300
			if (Extra_Gather_1_Status) then 
				Main.Extra_Gather_1.cooldown = 300 
				Main.Extra_Gather_1.timer:set()
			end
			if (Extra_Gather_2_Status) then 
				Main.Extra_Gather_2.cooldown = 300
				Main.Extra_Gather_2.timer:set()
			end
		end
		if (Auto_Join_Enabled) and not(Main.Auto_Join.status) then 
			Auto_Join("ON")
			Main.Auto_Join.status = true
		end
		if (Use_Troop_Ratio) then Balance_Troop_Ratio(33, 34, 33, true) end
		Main.Bear_Event.running = false
		return Get_Time_Difference(nil, prepTime)
	elseif (CHARACTER_ACCOUNT == "Alt_Bear") then
		local curBearTime = string.format("%s %s:00", os.date("%Y/%m/%d"), actualBearTime)
		Logger("Current Bear Time: " ..curBearTime)
		local nextBearTime = addDatetoDateTime(curBearTime, 2)
		Logger("Next Bear Time: " ..curBearTime)
		preferencePutString("altBearLastRun", curBearTime) --add when running bear event save the last date and time of bear event (e.g today)
		preferencePutString("altBearNextRun", nextBearTime) --add when running bear event save the last date and time of bear event (e.g today)
		Logger("Re-Enabling Previous Settings")
		if (altAutoJoin) then
			Logger("Enabling Auto Join")
			Auto_Join("ON") 
		end
		if (altRssGather) then
			Logger("Waiting for 250 seconds to clear Marches before starting RSS Gather")
			wait(250)
			SearchResources("Meat", "Hero")
			SearchResources("Wood", "Hero")
			SearchResources("Coal", "Hero")
			SearchResources("Iron", "Hero")
		end
		Logger("Alt Bear Completed")
		return 86400
	end
end

------------------------------------------ SHOP -------------------------------------
function Nomadic_Merchant()
	Current_Function = getCurrentFunctionName()
	Logger("Starting Nomadic Merchant")
	local Shop_Image = SearchImageNew("Shop Button.png", Lower_Half, 0.9, true, false)
	if not(Shop_Image.name) then 
		Logger("Shop Button Not Found. Returning in 00:05:00")
		return 300 
	end
	Logger("Clicking Shop")
	local Nomadic_Merchant_Status = PressRepeatNew(Shop_Image.xy, {"Nomadic Merchant Clicked.png", "Nomadic Merchant Unclicked.png"}, 1, 3, nil, Lower_Half, 0.9, false, true)
	if (Nomadic_Merchant_Status.name == "Nomadic Merchant Unclicked.png") then PressRepeatNew("Nomadic Merchant Unclicked.png", "Nomadic Merchant Clicked.png", 1, 3, Lower_Half, Lower_Half, 0.9, true, true) end
	wait(1)
	local Nomadic_Status
	local nomadicRequiredList = {}
	
	if (Discounted == "Select") then
		local allItemsList = {"Meat", "Wood", "Coal", "Iron", "Troop Training", "Construction", "Research", "Healing", "Epic Expedition", "Rare Expedition", "Epic Exploration", "Rare Exploration", "Hero", "VIP", "Random Teleporter"}
		for i, v in ipairs(allItemsList) do
			local v2 = v:gsub(" ", "")
			if (_G["nomadic" ..v2]) then table.insert(nomadicRequiredList, "Nomadic Merchant/" ..v ..".png") end
		end
	end
	local nomadicIteration = 0
	local nomadicIterationLimit = 10
	repeat
		nomadicIteration = nomadicIteration + 1
		for i = 1, #Nomadic_Slot_ROI do
			Logger("Checking Area: " .. i)
			local slotROI = Nomadic_Slot_ROI[i]
			local x,y,w,h = slotROI:getX(), slotROI:getY(), slotROI:getW(), slotROI:getH()
			local areaROI = Region(x, y - 197, w, h + 143)

			while true do
				Logger("Evaluating slot resources")
				local Task = ""

				if (Discounted == "Select") and (#nomadicRequiredList > 0) then
					local nomadicList = Split(nomadicGemsList, ",")
					for idx, v in ipairs(nomadicList) do
						nomadicList[idx] = string.lower(string.gsub(v, "^%s*(.-)%s*$", "%1"))
					end
					local nomadicItemFound = SearchImageNew(nomadicRequiredList, areaROI, 0.9, false, false, 1.5)
					local priceGems = SearchImageNew("Nomadic Gems.png", slotROI, 0.9, true, false, 1)
					if (nomadicItemFound and nomadicItemFound.name) and (find_in_list(nomadicList, "all") or find_in_list(nomadicList, string.lower(nomadicItemFound.name))) then
						if priceGems and priceGems.name then
							Task = nomadicGems and "Gem Claim" or "Skip"
						else
							Task = "Claim"
						end
					else
						if nomadicFree and not (priceGems and priceGems.name) then Task = "Claim"
						else Task = "Skip" end
					end
				else
					local gemCheck = SearchImageNew("Nomadic Gems.png", slotROI, 0.85, true, false, 2)
					Logger("Gem check result: " .. tostring(gemCheck and gemCheck.name))
					if gemCheck and gemCheck.name then
						Logger("Item costs gems. Skipping.")
						Task = "Skip"
					else
						Logger("No gems detected - evaluating free item")
						if (Discounted == "Discount") then
							local discountROI = Region(x, y - 197, 80, 80)
							Logger("Searching for discount badge (% symbol) in top-left corner of area " .. i)
							local discountStatus = SearchImageNew(Nomadic_Discount_Patterns, discountROI, 0.80, true, false, 2)
							Logger("Discount search result: " .. tostring(discountStatus and discountStatus.name))
							local hasDiscount = discountStatus and discountStatus.name and discountStatus.name ~= "Nomadic No Discount"
							Task = hasDiscount and "Claim" or "Skip"
							if Task == "Claim" then
								Logger("Discount badge found; claiming free discounted item")
							else
								Logger("No discount badge detected; skipping free item")
							end
						else
							Logger("Not in discount mode - claiming free item")
							Task = "Claim"
						end
					end
				end

				if Task == "Claim" then
					Logger("Resources found and pressing price area")
					local offsetX = math.random(5, slotROI:getW() - 6)
					local offsetY = math.random(3, slotROI:getH() - 7)
					local targetTap = Location(slotROI:getX() + offsetX + 5, slotROI:getY() + offsetY + 3)
					click(targetTap)
					wait(0.6)
					usePreviousSnap(false)
					Logger("Claim completed for slot " .. i)
					break
				elseif Task == "Gem Claim" then
					Logger("Gem item selected; proceeding with purchase flow")
					local offsetX = math.random(5, slotROI:getW() - 6)
					local offsetY = math.random(3, slotROI:getH() - 7)
					PressRepeatNew(Location(slotROI:getX() + offsetX + 5, slotROI:getY() + offsetY + 3), "Daily Rewards/Top up Gems.png", 1, 2, nil, Lower_Half)
					Logger("Clicking Gems")
					wait(1)
					local gems = SingleImageWait("Daily Rewards/Top up Gems.png", 9999999, Lower_Half)
					Logger()
					local result = PressRepeatNew(gems, {"Nomadic Merchant/Purchase.png", "Nomadic Merchant/nomadic Exclamation.png"}, 1, 2)
					if (result.name == "Purchase") then PressRepeatNew(gems, "Nomadic Merchant/nomadic Exclamation.png", 1, 3, nil, Upper_Right) end
					Logger("Purchase Completed")
					usePreviousSnap(false)
					wait(0.8)
					break
				else
					Logger("Skipping slot")
					break
				end
			end
		end
		Logger("Checking Nomadic Status")
		Nomadic_Status = SearchImageNew({"Nomadic Free Refresh.png", "Nomadic Gems Refresh.png"}, Upper_Half, 0.9, true, false, 99999)
		Logger("Nomadic Status: "  ..Nomadic_Status.name)
		if (Nomadic_Status.name == "Nomadic Free Refresh") then
			Logger("Free Refresh Found and Clicking")
			Press(Nomadic_Status.xy, 1)
			wait(1)
		end
		if nomadicIteration >= nomadicIterationLimit then
			Logger("Nomadic Merchant: maximum refresh iterations reached; exiting loop")
			break
		end
	until(Nomadic_Status.name == "Nomadic Gems Refresh")
	Go_Back("Nomadic Merchant Completed")
	return Get_Time_Difference()
end
------------------------------------------------ PET SKILLS ------------------------------------------------
function Use_Pet_Skills(Skills_Type)
	Current_Function = getCurrentFunctionName()
	Close_Share_Screen()
	PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Button.png", Main.Pet_Adventure.dir.. "Pet Skill Logo.png", 1, 2, nil, nil, 0.9, true, true)
	if (Skills_Type == "Battle") then
		local Battle_Skills_List = findAllNoFindException(Pattern(Main.Pet_Adventure.dir.. "Pet Skill Fight Icon.png"):similar(0.90):color())
		for _, Battle_Skill in ipairs(Battle_Skills_List) do
			local Current_Skill_Status = PressRepeatNew(Battle_Skill, {Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png", Main.Pet_Adventure.dir.. "Pet Skill Cooldown.png", Main.Pet_Adventure.dir.. "Pet Skill Active.png"}, 1, 2, nil, Lower_Half, 0.9, nil, false)
			if (Current_Skill_Status.name == "Pet Skill Quick Use") then
				PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png", Main.Pet_Adventure.dir.. "Pet Skill Use All Confirmation.png", 1, 2, nil, nil, 0.9, true, true)
				PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Use.png", Main.Pet_Adventure.dir.. "Pet Skill Logo.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
				break
			end
		end
	elseif (Skills_Type == "Resources") then
		local Build_Skills_List = findAllNoFindException(Pattern(Main.Pet_Adventure.dir.. "Pet Skill Build Icon.png"):similar(0.90):color())
		Logger(string.format("Pet Skills: found %d resource skill icons", #Build_Skills_List))
		local Builders_Aid_Trigger = false
		for i, Build_Skill in ipairs(Build_Skills_List) do
			local Current_Skill_Status = PressRepeatNew(
				Build_Skill,
				{
					Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png",
					Main.Pet_Adventure.dir.. "Pet Skill Use.png",
					Main.Pet_Adventure.dir.. "Pet Skill Cooldown.png",
					Main.Pet_Adventure.dir.. "Pet Skill Active.png"
				},
				1, 2, nil, Lower_Half, 0.9, nil, false)
		Logger(string.format("Pet Skills: resource slot %d status %s", i, tostring(Current_Skill_Status.name or "nil")))
			if (i == 1) and (SearchImageNew(Main.Pet_Adventure.dir.. "Pet Skill Builders Aid.png", Lower_Half, 0.9, true).name) then 
				--DO NOTHING
			else
				if (Current_Skill_Status.name == "Pet Skill Quick Use") then
					PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png", Main.Pet_Adventure.dir.. "Pet Skill Use All Confirmation.png", 1, 2, nil, nil, 0.9, true, true)
					local Skill_Status = PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Use.png", {"Tap Anywhere.png", Main.Pet_Adventure.dir.. "Pet Skill Active.png", Main.Pet_Adventure.dir.. "Pet Skill Cooldown.png"}, 1, 2, nil, Lower_Half, 0.9, true, true)
					if (Skill_Status.name == "Tap Anywhere") then
						PressRepeatNew("Tap Anywhere.png", Main.Pet_Adventure.dir.. "Pet Skill Logo.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
					elseif (Skill_Status.name == "Pet Skill Active") and (CHARACTER_ACCOUNT == "Main") then Burden_Bearer_Skill = true
					end
				elseif (Current_Skill_Status.name == "Pet Skill Use") then
					local Skill_Status = PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Use.png", {"Tap Anywhere.png", Main.Pet_Adventure.dir.. "Pet Skill Active.png", Main.Pet_Adventure.dir.. "Pet Skill Cooldown.png"}, 1, 2, nil, Lower_Half, 0.9, true, true)
					if (Skill_Status.name == "Tap Anywhere") then
						PressRepeatNew("Tap Anywhere.png", Main.Pet_Adventure.dir.. "Pet Skill Logo.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
					elseif (Skill_Status.name == "Pet Skill Active") and (CHARACTER_ACCOUNT == "Main") then Burden_Bearer_Skill = true
					end
				elseif (Current_Skill_Status.name == "Pet Skill Cooldown") then	
					--Add OCR for return time
				end	
			end
		end
	elseif (Skills_Type == "Mystical Finding") then
		PressRepeatNew(Main.Pet_Adventure.dir.. "Mystical Finding Skill.png", Main.Pet_Adventure.dir.. "Mystical Finding Label.png", 1, 2)
		local skillStatus = SearchImageNew({Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png", Main.Pet_Adventure.dir.. "Pet Skill Cooldown.png"}, Lower_Half, 0.9, false, false, 999999)
		if (skillStatus.name == "Pet Skill Cooldown") then --Cooldown
			snapshotColor()
			local cooldownROI = Region(skillStatus.sx + 6 + skillStatus.w, skillStatus.sy - 2, skillStatus.w, skillStatus.h + 2)
			--read OCR for TIME
			usePreviousSnap(false)
			Go_Back()
			return cooldownROI
		else --skills available and can be used.
			PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Quick Use.png", Main.Pet_Adventure.dir.. "Pet Skill Use All Confirmation.png", 1, 2, nil, nil, 0.9, true, true)
			PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Use.png", Main.Pet_Adventure.dir.. "Pet Skill Logo.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
		end
	end
	Go_Back()
end

function Pet_Adventure_Event()
	Current_Function = getCurrentFunctionName()
	Logger("Starting Pet Adventure")
	if not(SearchImageNew("City.png", Lower_Right, .9, true).name) then
		Logger("Cannot Find Image! Returning in 1 Minute")
		return 300
	end
	Logger("Checking If share Screen is opened by mistake")
	Close_Share_Screen()
	Logger("Clicking Pet Skill")
	PressRepeatNew(Main.Pet_Adventure.dir.. "Pet Skill Button.png", Main.Pet_Adventure.dir.. "Beast Cage.png", 1, 2)
	Logger("Clicking Beast Cage")
	PressRepeatNew(Main.Pet_Adventure.dir.. "Beast Cage.png", Main.Pet_Adventure.dir.. "Adventure Button.png", 1, 2)
	Logger("Clicking Adventure")
	PressRepeatNew(Main.Pet_Adventure.dir.. "Adventure Button.png", Main.Pet_Adventure.dir.. "Ally Treasure.png", 1, 2)
	--searching all boxes
	Logger("Searching for all Treasure Spots")
	local Boxes = {}
	while not (table.getn(Boxes) == 3) do
		Boxes = findAllNoFindException(Pattern(Main.Pet_Adventure.dir.. "test1.png"):similar(0.98):mask())
	end
	Logger("Treasure Spots Found! Checking Remaining Attempts")
	Logger()
	-- checking for completed boxes
	snapshotColor()
	-- Read Remaining Attemps
	local Remaining_Attempts = SearchImageNew(Main.Pet_Adventure.dir.. "Attempts 0.png", Upper_Half, 0.9)
	Logger("Checking each treasure spots")
	local Rewards = {}
	for _,img in ipairs(Boxes) do
		local x,y,w,h = img:getX(), img:getY(), img:getW(), img:getH()
		local leftROI = Region(x + 13, y - 20, 5, 5)
		local rightROI = Region(x + w - 15, y - 20, 5, 5)
		local r, g, b = getColor(leftROI)
		local leftResult = isColorWithinThreshold(r, g, b, 230, 232, 230, 40)
		if not(leftResult) then
			local r, g, b = getColor(rightROI)
			local rightResult = isColorWithinThreshold(r, g, b, 230, 232, 230, 40)
			if not(rightResult) then table.insert(Rewards, img) end
		end
	end
	usePreviousSnap(false)
	
	-- Claiming Completed boxes if any
	for _,v in ipairs(Rewards) do
		Logger("Completed Treasure Found and Claiming!!!")
		PressRepeatNew(v, Main.Pet_Adventure.dir.. "Completed.png", 1, 2, nil, Upper_Half) -- check if you get any error again
		Logger("Clicking Completed")
		PressRepeatNew(string.format("%s,%s", screen.x/2, 920), "Tap Anywhere.png", 1, 3)
		Logger("Claiming Completed")
		PressRepeatNew(4, Main.Pet_Adventure.dir.. "Ally Treasure.png", 1, 2)
	end
	Logger("Treasure Spot: " ..tostring(Main.Pet_Adventure.treasure_spots))
	if (CHARACTER_ACCOUNT == "Main") and (Main.Pet_Adventure.treasure_spots) then
		if (Remaining_Attempts.name) then
			Logger("Remaining Attempts 0")
			if (CHARACTER_ACCOUNT == "Main") then Main.Pet_Adventure.treasure_spots = false end
		else
			Boxes = {}
			while not(table.getn(Boxes) == 3) do Boxes = findAllNoFindException(Pattern(Main.Pet_Adventure.dir.. "test1.png"):similar(0.98):mask()) end
			Logger("Remaining Attempts Found!")
			local shouldBreak = false
			local Available_List = {}
			snapshotColor()
			for _, Cur_Chest in ipairs({Main.Pet_Adventure.dir.. "Treasure Spot Lv3.png", Main.Pet_Adventure.dir.. "Treasure Spot Lv2.png", Main.Pet_Adventure.dir.. "Treasure Spot Lv1.png"}) do
				local Treasure_Chests = findAllNoFindException(Pattern(Cur_Chest):similar(0.9):color())
				for _, Cur_Tchest in ipairs(Treasure_Chests) do
					local r, g, b = getColor(Location(Cur_Tchest:getCenter():getX() - 42, Cur_Tchest:getCenter():getY() - 42)) -- above 210 for all colors
					if (r >= 210) and (g >= 210) and (b >= 210) then
						table.insert(Available_List, Cur_Tchest)
					end
				end
			end
			usePreviousSnap(false)
			for _, v in ipairs(Available_List) do
				Logger("Clicking Treasure Box")
				PressRepeatNew(v, Main.Pet_Adventure.dir.. "Select Pet.png", 1, 3)
				Logger("Selecting Pet")
				local Start_Status = PressRepeatNew(Main.Pet_Adventure.dir.. "Select Pet.png", {Main.Pet_Adventure.dir.. "Insufficient Attempts.png", Main.Pet_Adventure.dir.. "Start Available.png", Main.Pet_Adventure.dir.. "Start Unavailable.png"}, 1, 3, nil, nil, 0.9, true, true)
				--if (Start_Status.name == "Insufficient Attempts") or (Start_Status.name == "Start Unavailable") then
				if (find_in_list({"Insufficient Attempts", "Start Unavailable"}, Start_Status.name)) then
					Logger("Insufficient Attempts")
					PressRepeatNew(4, Main.Pet_Adventure.dir.. "Ally Treasure.png", 1, 2)
					break
				end
				local staminaStatus = SearchImageNew({Main.Pet_Adventure.dir.. "Stamina Available.png", Main.Pet_Adventure.dir.. "Stamina Unavailable.png"}, Lower_Half, 0.9, true)
				if (staminaStatus.name == "Stamina Unavailable") then
					Logger("Stamina Unavailable")
					PressRepeatNew(4, Main.Pet_Adventure.dir.. "Ally Treasure.png", 1, 2)
					break
				end
				Logger("Clicking Available")
				Press(Start_Status.xy, 1)
				Logger("Closing Ally Treasure")
				PressRepeatNew(4, Main.Pet_Adventure.dir.. "Ally Treasure.png", 1, 2)
				Logger()
				if (SearchImageNew(Main.Pet_Adventure.dir.. "Attempts 0.png", Upper_Half, 0.9, false, false).name) then break end
			end	
			Logger("Treasure Completed")
		end
	end
	
	Logger("Looking for Clock")
	snapshot()
	local Clock_List = findAllNoFindException(Pattern(Main.Pet_Adventure.dir.. "Pet Adventure Clock.png"):similar(0.9))
	local Box_Return_Time
	for _, Current_Clock in ipairs(Clock_List) do
		Logger("Clock Found and Generating Region for OCR")
		local x,y,w,h = Current_Clock:getX(), Current_Clock:getY(), Current_Clock:getW(), Current_Clock:getH()
		local Number, Number_Status, Remaining_Time_S
		while true do
			repeat Number, Number_Status = numberOCRNoFindException(Region(x+w + 5, y - 1, w * 6, h + 4), "ocr/t") until(Number_Status)
			Remaining_Time_S = Convert_To_Seconds(Number)
			if (Remaining_Time_S < 36000) then break end -- less than 10 hours
		end
		Logger("OCR Completed")
		if (Box_Return_Time) then
			if (Remaining_Time_S < Box_Return_Time) then Box_Return_Time = Remaining_Time_S end
		else Box_Return_Time = Remaining_Time_S end
	end
	usePreviousSnap(false)
	Box_Return_Time = Box_Return_Time or Get_Time_Difference()
	-----------
	----Ally Treasure
	Logger("Ally Treasure: " ..tostring(Main.Pet_Adventure.ally_treasure))
	local Ally_Return_Time = Get_Time_Difference()
	if (Main.Pet_Adventure.ally_treasure) or (CHARACTER_ACCOUNT == "Alt") then
		Logger("Pressing Ally Treasure")
		local Ally_Treasure_Tab = PressRepeatNew(Main.Pet_Adventure.dir.. "Ally Treasure.png", {Main.Pet_Adventure.dir.. "My Shares Unclicked.png", Main.Pet_Adventure.dir.. "My Shares Clicked.png"}, 1, 2)
		--My Shares
		Logger("Checking My Shares")
		if (Ally_Treasure_Tab.name == "My Shares Unclicked") then PressRepeatNew(Main.Pet_Adventure.dir.. "My Shares Unclicked.png", Main.Pet_Adventure.dir.. "My Shares Clicked.png", 1, 4) end
		local Share_Status = SearchImageNew(Main.Pet_Adventure.dir.. "Share.png")
		if (Share_Status.name) then Press(Share_Status.xy, 1) end
		
		--Alliance Shares
		PressRepeatNew(Main.Pet_Adventure.dir.. "Alliance Shares Unclicked.png", Main.Pet_Adventure.dir.. "Alliance Shares Clicked.png", 1, 4)
		Logger("Checking for available rewards in Alliance Share")
		local claimAll = SingleImageWait(Main.Pet_Adventure.dir.. "Claim All.png", 0, Lower_Half, 0.9, true)
		if (claimAll) then
			local tapAnywhere = PressRepeatNew(claimAll, "Tap Anywhere.png", 1, 2, nil, Lower_Half)
			PressRepeatNew(tapAnywhere.xy, Main.Pet_Adventure.dir.. "Alliance Shares Clicked.png", 1, 2, nil, Upper_Half)
		else
			while true do
				local Remaining_Claims = SearchImageNew(Main.Pet_Adventure.dir.. "Remaining Claims 0.png", Upper_Half, 0.9, false, false, 2)
				if (Remaining_Claims.name) then
					Logger("Remaining Claims 0")
					if (CHARACTER_ACCOUNT == "Main") then Main.Pet_Adventure.ally_treasure = false end
					Ally_Return_Time = Get_Time_Difference()
					break
				else
					local Claim_Button = SearchImageNew("Alliance Claim.png", nil, 0.9, false, false, 2)
					if (Claim_Button.name) then
						Logger("Claiming Reward")
						PressRepeatNew(Claim_Button.xy, "City Cans Claim.png", 1, 4)
						PressRepeatNew("City Cans Claim.png", Main.Pet_Adventure.dir.. "Remaining Treasure.png", 1, 3)
						PressRepeatNew(4, Main.Pet_Adventure.dir.. "Ally Treasure Logo.png", 1, 4)
						Logger("Reward Claimed")
					else
						Logger("Claim Not Found!")
						Ally_Return_Time = 3600
						break 
					end
				end
			end
		end
		Logger("Ally Treasure Completed")
	end
	
	local Return_Time = Box_Return_Time
	if (Ally_Return_Time < Return_Time) then Return_Time = Ally_Return_Time end
	Go_Back("Pet Adventure Completed and Going Back")
	return Return_Time
end

function Chief_Order_Store()
	Current_Function = getCurrentFunctionName()
	local Required_Chief_Order = {}
	
	Logger("Opening City")	
	PressRepeatNew("City.png", "World.png", 1, 2, Lower_Right, Lower_Right, 0.9, true, true)
	Logger("Pressing Chief Order Button")	
	PressRepeatNew(Main.Chief_Order_Event.dir.. "Chief Order Button.png", Main.Chief_Order_Event.dir.. "Urgent Mobilization Label.png", 1, 4) ---- ERROR
	wait(3)
	
	if (CHARACTER_ACCOUNT == "Main") then
		for _, event in ipairs(Chief_Order_Events) do
			if (SearchImageNew(Main.Chief_Order_Event.dir.. event .. ".png").name) then
				table.insert(Required_Chief_Order, Main.Chief_Order_Event.dir.. event .. ".png")
			else
				--local Banner = SearchImageNew(Main.Chief_Order_Event.dir.. event .. " Label.png")
				--local Banner_ROI = Region(Banner.sx, Banner.sy - 200, Banner.w, 200)
				local Banner = SingleImageWait(Main.Chief_Order_Event.dir.. event .. " Label.png", 99999999)
				local Banner_ROI = Region(Banner.x, Banner.y - 200, Banner.w, 200)
				local On_cooldown = SearchImageNew(Main.Chief_Order_Event.dir.. "On cooldown.png", Banner_ROI)
				local Remaining_Seconds = 60
				if (On_cooldown.name) then
					local Cooldown_ROI = Region(On_cooldown.sx, On_cooldown.sy + On_cooldown.h, On_cooldown.w, On_cooldown.h)
					local Number, Number_Status
					repeat Number, Number_Status = numberOCRNoFindException(Cooldown_ROI, "ocr/er") until(Number_Status)
					Remaining_Seconds = Convert_To_Seconds(Number)
				end
				PressRepeatNew(4, "World.png", 1, 4, nil, Lower_Right, 0.9, nil, true)
				PressRepeatNew("World.png", "City.png", 1, 2, Lower_Right, Lower_Right, 0.9, true, true)
				return Remaining_Seconds
			end
		end
	else	
		for _, event in ipairs({"Urgent Mobilization", "Rush Job", "Productivity Day", "Festivities"}) do
			if (SearchImageNew(Main.Chief_Order_Event.dir.. event .. ".png").name) then
				table.insert(Required_Chief_Order, Main.Chief_Order_Event.dir.. event .. ".png")
			end
		end
	end
	
	for i, Chief_Order in ipairs(Required_Chief_Order) do
		local Current_Order = Chief_Order:gsub("Main.Chief_Order_Event.dir", "")
		Current_Order = Chief_Order:gsub(".png", "")
		Logger("Searching Current Order: " ..Current_Order)	
		local Cur_Chief_Order = SearchImageNew(Chief_Order, nil, 0.9, false, false, 2)
		if (Cur_Chief_Order.name) then
			Logger("Claiming Current Order: " ..Current_Order)	
			local Enact = PressRepeatNew(Cur_Chief_Order.xy, Main.Chief_Order_Event.dir.. "Enact.png", 1, 4)
			local Enact_Result = PressRepeatNew(Main.Chief_Order_Event.dir.. "Enact.png", {Main.Chief_Order_Event.dir.. "Chief Order Button.png", Main.Chief_Order_Event.dir.. "Publish After.png", "Tap Anywhere.png"}, 1, 2) -- error on this part
			if (Enact_Result.name == "Tap Anywhere") then
				PressRepeatNew("Tap Anywhere.png", Main.Chief_Order_Event.dir.. "Chief Order Button.png", 1, 2)
			--elseif (Enact_Result.name ==  "Publish After") then
			end
			if not(i == table.getn(Required_Chief_Order)) then 
				PressRepeatNew(Main.Chief_Order_Event.dir.. "Chief Order Button.png", Main.Chief_Order_Event.dir.. "Chief Order Logo.png", 1, 4)
			end
		else
			if (getUserID() == "zombrox@pm.me") then
				print("Image not found for " ..Chief_Order)
			end	
		end
	end
	Go_Back()
	if (CHARACTER_ACCOUNT == "Main") then return Populate_Chief_Order_Events()
	else return 0 end
end

function findDot(yCoord)
	local result = {}
	snapshotColor()
	local dotList = findAllNoFindException(Pattern("Daily Rewards/Red Dot.png"):similar(0.7):color())
	if (#dotList > 0) then
		for i, v in ipairs(dotList) do
			if(isColorWithinThresholdHex(Location(v:getCenter():getX(), v:getCenter():getY()), "#FF1E1F", 5)) and (v.y > yCoord) then 
				table.insert(result, Location(v:getCenter():getX(), v:getCenter():getY()))
			end
		end
	end
	usePreviousSnap(false)
	return result
end

function dotClicker()
	local dotList = findDot(270)
	for _, dot in ipairs(dotList) do
		local dotFound = dot
		while true do
			Press(Location(ranNumbers(dotFound.x - 5, 3), dotFound.y + 5), 1)
			wait(3)
			local newCoord = 1
			if (SingleImageWait("Daily Rewards/Deals Logo.png")) then newCoord = 270 end		
			local dotListNew = findDot(newCoord)				
			if (#dotListNew > 0) then 
				dotFound = dotListNew[1]
			else
				while true do
					local dealsLogo = SearchImageNew({"Daily Rewards/Deals Logo.png", "Daily Rewards/Deals.png"}, Upper_Half, 0.9, false, false, 1)
					if (dealsLogo.name) then
						if (dealsLogo.name == "Deals") then PressRepeatNew(dealsLogo.xy, "Daily Rewards/Deals Logo.png", 1, 2, nil, Upper_Left) end
						break
					else
						keyevent(4)
						wait(2)
					end
				end
				break
			end
		end
	end
end

function dotClicker2()
	local dotList = findDot()
	for _,dot in ipairs(dotList) do
		if (dot.y > 270) then
			local dotFound = dot
			while true do
				Press(Location(ranNumbers(dotFound.x - 5, 3), dotFound.y + 5), 1)
				wait(3)
				local dotListNew = findDot()				
				if (#dotListNew > 0) then 
					dotFound = dotListNew[1]
					if (SingleImageWait("Daily Rewards/Deals Logo.png")) then
				
					else
					
					end	
				else
					while true do
						local dealsLogo = SearchImageNew({"Daily Rewards/Deals Logo.png", "Daily Rewards/Deals.png"}, Upper_Half, 0.9, false, false, 1)
						if (dealsLogo.name) then
							if (dealsLogo.name == "Deals") then PressRepeatNew(dealsLogo.xy, "Daily Rewards/Deals Logo.png", 1, 2, nil, Upper_Left) end
							break
						else
							keyevent(4)
							wait(2)
						end
					end
					break
				end
			end
		end
	end
end

function Daily_Rewards()
    Current_Function = getCurrentFunctionName()

    -- Mark as running so your UI doesn’t say “not active”
    if Main and Main.Daily_Rewards then
        Main.Daily_Rewards.status = true
    end

    ---------------------------------------------------------------------------
    -- Context detector: accept City OR any Daily-Rewards surfaces
    ---------------------------------------------------------------------------
    local function inDailyRewardsContext()
        -- already on City
        if SingleImageWait("City.png", 0, Lower_Most_Half) then return true end
        -- Events hub or tab open
        if SearchImageNew("Events.png", Upper_Half, 0.9, true).name then return true end
        if SearchImageNew("Event logo.png", Upper_Half, 0.9, true).name then return true end
        -- Deals/VIP/Top-Up screens (these hide City.png)
        if SearchImageNew(Main.Daily_Rewards.dir.."Deals Logo.png", Upper_Left, 0.9, true).name then return true end
        if SearchImageNew(Main.Daily_Rewards.dir.."Shop.png", Upper_Half, 0.9, true).name then return true end
        if SearchImageNew(Main.Daily_Rewards.dir.."Top up Gems.png", Upper_Right, 0.9, true).name then return true end
        return false
    end

    local function recoverContext(maxSteps)
        maxSteps = maxSteps or 3
        for _=1,maxSteps do
            -- clear common overlays quickly
            local tapAny = SearchImageNew("Tap Anywhere.png", nil, 0.9, true, false, 1)
            if tapAny.name then Press(tapAny.xy, 1) end

            -- close sheets/tips with a generic back
            Go_Back()
            wait(0.6)
            if inDailyRewardsContext() then return true end
        end
        return inDailyRewardsContext()
    end

	local function locateDailyDeals()
		-- try to capture a fresh frame so the ROI math lines up with the current UI
		usePreviousSnap(false)

		-- always prefer the clickable Daily Deals button on the Events bar
		local dealsButton = SearchImageNew(Main.Daily_Rewards.dir.. "Deals.png", Upper_Right, 0.9, false, false, 9999)
		if not(dealsButton and dealsButton.name) then
			Logger("Daily Deals: icon not found in Upper_Right")

			-- if the Deals tab is already open, keep a reference to the header so callers can still interact
			local dealsHeader = SearchImageNew(Main.Daily_Rewards.dir.. "Deals Logo.png", Upper_Left, 0.9, false, false, 3)
			if (dealsHeader and dealsHeader.name) then
				Logger("Daily Deals: tab header detected instead of button")
				return dealsHeader, false
			end
			return nil, false
		end

		Logger(string.format("Daily Deals: button at (%d,%d,%d,%d)", dealsButton.sx, dealsButton.sy, dealsButton.w, dealsButton.h))

		local roiX = dealsButton.sx + dealsButton.w - 5
		local roiY = dealsButton.sy - math.floor(dealsButton.h / 1.2)
		local roiW = dealsButton.w
		local roiH = dealsButton.h
		local roiLeft = math.max(0, roiX - math.floor(roiW * 0.25))
		local roiTop = math.max(0, roiY - math.floor(roiH * 0.25))
		local roiWidth = math.min(screen.x - roiLeft, roiW + math.floor(roiW * 0.5))
		local roiHeight = math.min(screen.y - roiTop, roiH + math.floor(roiH * 0.5))
		local dealsROI = Region(roiLeft, roiTop, roiWidth, roiHeight)
		Logger(string.format("Daily Deals: ROI (%d,%d,%d,%d)", roiLeft, roiTop, roiWidth, roiHeight))

		local dotImage = SearchImageNew({Main.Daily_Rewards.dir.. "Deals Dot.png", Main.Daily_Rewards.dir.. "Deals No Dot.png"}, dealsROI, 0.88, false, false, 1)
		if (dotImage and dotImage.name == "Deals Dot") then
			Logger("Daily Deals: dot image found via ROI search")
			return dealsButton, true
		end

		-- fallback: rely on the generic dot finder in case the overlay is offset
		local fallbackDots = findDot(0)
		for _, dot in ipairs(fallbackDots) do
			if (dot.x >= dealsButton.sx - 10) and (dot.x <= dealsButton.sx + dealsButton.w + 10) and (dot.y >= dealsButton.sy - 20) and (dot.y <= dealsButton.sy + dealsButton.h + 20) then
				Logger("Daily Deals: dot matched via fallback finder")
				return dealsButton, true
			end
		end

		Logger("Daily Deals: no notification dot aligned with button")
		return dealsButton, false
	end
    ---------------------------------------------------------------------------

    -- Ensure we’re on any valid surface; on failure back off to normal cadence
    if not inDailyRewardsContext() then
        if not recoverContext(3) then
            return math.max(60, Auto_DailyRewards_Timer * 60)
        end
    end

    local DM_Rewards, VIP_Rewards, Top_Up_Center, Daily_Deals = false, false, false, false

    ---------------------------------------------------------------------------
    -- DAILY MISSIONS (color snapshot needed for dot check)
    ---------------------------------------------------------------------------
    snapshotColor() --- requires colored snapshot

    -- NOTE: Previously this gated on City.png; that’s brittle because Deals/VIP/Top-Up cover City.
    -- We’ve already validated context above, so we proceed directly.

    local Daily_Mission_Logo = SingleImageWait("Daily Mission.png", 99999, Lower_Left)
    if (Daily_Mission_Logo) then
        local DM_ROI = Region(Daily_Mission_Logo:getX(), Daily_Mission_Logo:getY() - (Daily_Mission_Logo:getH() * 2), Daily_Mission_Logo:getW() * 2, Daily_Mission_Logo:getH() * 2)
        if (SearchImageNew(Main.Daily_Rewards.dir.. "Daily Mission Available.png", DM_ROI, 0.93, true, true).name) then DM_Rewards = true end
    end
    usePreviousSnap(false)

    ---------------------------------------------------------------------------
    -- VIP (plain snapshot)
    ---------------------------------------------------------------------------
    snapshot() -- no color snapshot
    local VIP = SingleImageWait(Main.Daily_Rewards.dir.. "VIP.png", 9999999, Upper_Right)
    if (VIP) then
        local VIP_ROI = Region(VIP:getX() + VIP:getW() + 95, VIP:getY() - VIP:getH(), VIP:getW() + 7, VIP:getH() + 10)
        if (SearchImageNew({Main.Daily_Rewards.dir.. "VIP Dot.png", Main.Daily_Rewards.dir.. "VIP No Dot.png"}, VIP_ROI).name == "VIP Dot") then VIP_Rewards = true end
    end

    ---------------------------------------------------------------------------
    -- TOP-UP CENTER
    ---------------------------------------------------------------------------
    local Top_Up_Center_Image = SearchImageNew(Main.Daily_Rewards.dir.. "Top up Center.png", Upper_Right, 0.9, false, false, 99999)
    if (Top_Up_Center_Image.name) then
        local Top_Up_Center_ROI = Region(Top_Up_Center_Image.x, Top_Up_Center_Image.sy - Top_Up_Center_Image.h, Top_Up_Center_Image.w + 5, Top_Up_Center_Image.h + Top_Up_Center_Image.h / 2)
        if (SearchImageNew({Main.Daily_Rewards.dir.. "Top Up Dot.png", Main.Daily_Rewards.dir.. "Top Up No Dot.png"}, Top_Up_Center_ROI).name == "Top Up Dot") then Top_Up_Center = true end
    end

    ---------------------------------------------------------------------------
    -- DAILY DEALS
    ---------------------------------------------------------------------------
	local Daily_Deals_Image, Daily_Deals_Status = locateDailyDeals()
	if (Daily_Deals_Status) then
		Logger("Daily Deals: notification detected")
		Daily_Deals = true
	else
		Logger("Daily Deals: no notification detected")
	end

    ---------------------------------------------------------------------------
    -- CLAIM DAILY MISSION
    ---------------------------------------------------------------------------
    usePreviousSnap(false)
    if (DM_Rewards) then
        PressRepeatHexColor(Daily_Mission_Logo, Location(687, 243), "#D1F7FB", 5, 1, 2)
        local Daily_Mission_Label = SearchImageNew(Main.Daily_Rewards.dir.. "Daily Mission Label.png", Upper_Half, 0.9, false, false, 2) --Daily Mission Label
        if not(Daily_Mission_Label.name) then
            Daily_Mission_Label = PressRepeatNew(Main.Daily_Rewards.dir.. "Daily Missions Unclicked.png", Main.Daily_Rewards.dir.. "Daily Mission Label.png", 1, 2, Lower_Half, Upper_Half, 0.9, true, true)
        end
        local Claim_All = SearchImageNew(Main.Daily_Rewards.dir.. "Claim All.png")
        if (Claim_All.name) then
            PressRepeatNew(Claim_All.xy, "Tap Anywhere.png", 1, 5)
            PressRepeatNew(Daily_Mission_Label.xy, Main.Daily_Rewards.dir.. "Daily Mission Label.png", 1, 1)
            if (SearchImageNew("Tap Anywhere.png", Lower_Half, 0.9, true, false, 2).name) then
                PressRepeatNew(Daily_Mission_Label.xy, Main.Daily_Rewards.dir.. "Daily Mission Label.png", 1, 1)
            end
        else
            local DMTimer = Timer()
            while true do
                if (DMTimer:check() > 150) then break end
                local Claim_Anywhere = SearchImageNew({Main.Daily_Rewards.dir.. "Claim.png", "Tap Anywhere.png"})
                if (Claim_Anywhere.name == "Claim") then
                    Press(Claim_Anywhere.xy, 1)
                elseif (Claim_Anywhere.name == "Tap Anywhere") then
                    PressRepeatNew(Daily_Mission_Label.xy, Main.Daily_Rewards.dir.. "Daily Mission Label.png", 1, 4)
                else break end
            end
        end
        Go_Back()
		if not(Daily_Deals) then
			Daily_Deals_Image, Daily_Deals_Status = locateDailyDeals()
			if (Daily_Deals_Status) then
				Logger("Daily Deals: notification detected after Daily Mission")
				Daily_Deals = true
			else
				Logger("Daily Deals: still no notification after Daily Mission")
			end
		end
	end

    ---------------------------------------------------------------------------
    -- VIP CLAIM
    ---------------------------------------------------------------------------
    if (VIP_Rewards) then
        Logger()
        ---- VIP ---------
        --print(getColor(VIP_ROI)) -- 255 30 31 color red and non color red 98 136 194
        PressRepeatNew(VIP, Main.Daily_Rewards.dir.. "Shop.png", 1, 2, Upper_Half, Upper_Half)		
        local VIP_Box = SearchImageNew({Main.Daily_Rewards.dir.. "VIP Box.png", Main.Daily_Rewards.dir.. "VIP Box Opened.png"}, Upper_Right, 0.9, false, false, 9999)
        local VIP_Claim = SearchImageNew(Main.Daily_Rewards.dir.. "Claim.png")
        if (VIP_Box.name == "VIP Box") then
            PressRepeatNew(VIP_Box.xy, Main.Daily_Rewards.dir.. "Click to Continue.png", 1, 4, nil, Lower_Half)
            PressRepeatNew(4, Main.Daily_Rewards.dir.. "Shop.png", 1, 4, Lower_Half)
        end
        if (VIP_Claim.name) then VIP_Claim.r:highlight(.2)
            PressRepeatNew(VIP_Claim.xy, "Tap Anywhere.png", 1, 4, nil, Lower_Half)
            PressRepeatNew("Tap Anywhere.png", Main.Daily_Rewards.dir.. "Shop.png", 1, 4, Lower_Half)
        end
        Go_Back()
    end

    ---------------------------------------------------------------------------
    -- TOP-UP CENTER CLAIM
    ---------------------------------------------------------------------------
    if (Top_Up_Center) then
        Logger()
        local topUpTimer = Timer()
        PressRepeatNew(Top_Up_Center_Image.xy, Main.Daily_Rewards.dir..  "Top up Gems.png", 1, 2, nil, Upper_Right)
        while true do
            if (topUpTimer:check() > 150) then break end
            local rewards = SearchImageNew({Main.Daily_Rewards.dir.. "Free.png", Main.Daily_Rewards.dir.. "Claimable.png", Main.Daily_Rewards.dir.. "Claimable 2.png", Main.Daily_Rewards.dir.. "Claimable 3.png"})
            if (rewards.name == "Free") then
                local result = PressRepeatNew(TargetOffset(rewards.xy, "0", "-20"), {Main.Daily_Rewards.dir.. "Click to Continue.png", "Tap Anywhere.png"}, 1, 4)
                PressRepeatNew({Main.Daily_Rewards.dir.. "Click to Continue.png", "Tap Anywhere.png"}, Main.Daily_Rewards.dir..  "Top up Gems.png", 1, 2, nil, Upper_Right)
            elseif (isWordInString(rewards.name, "Claimable")) then
                Press(TargetOffset(rewards.xy, "0", "-20"), 1)
            end
            local Exclamation = SearchImageNew({Main.Daily_Rewards.dir.. "Exclamation.png", Main.Daily_Rewards.dir.. "Dot.png"}, Upper_Half, 0.95, true, false, 2)
            if (Exclamation.name) then Press(Exclamation.xy, 1)
            else break end
            wait(1)
        end
        Go_Back()
    end

    ---------------------------------------------------------------------------
    -- DAILY DEALS CLAIM
    ---------------------------------------------------------------------------
	if (Daily_Deals) then
		-- prefer a fresh lookup so we always tap the clickable button instead of a stale header reference
		local refreshedButton = SearchImageNew(Main.Daily_Rewards.dir.. "Deals.png", Upper_Right, 0.9, false, false, 6)
		if (refreshedButton and refreshedButton.name) then
			Daily_Deals_Image = refreshedButton
		elseif not(Daily_Deals_Image and Daily_Deals_Image.name) then
			Logger("Daily Deals: need fresh icon search before entering tab")
			Daily_Deals_Image = select(1, locateDailyDeals())
		end
	end
	if (Daily_Deals) and (Daily_Deals_Image and Daily_Deals_Image.name) then
		Logger("Daily Deals: entering Deals tab")
        Logger()
        local dealsTimer = Timer()
        local rewardsList = {
            Main.Daily_Rewards.dir.. "Current Day.png",
            Main.Daily_Rewards.dir.. "Claim.png",
            Main.Daily_Rewards.dir.. "Withdraw.png",
            Main.Daily_Rewards.dir.. "Claimable 4.png",
            Main.Daily_Rewards.dir.. "Check Mark.png",
            Main.Daily_Rewards.dir.. "Check Mark 2.png"
        }
        PressRepeatNew(Daily_Deals_Image.xy, Main.Daily_Rewards.dir..  "Deals Logo.png", 1, 2, nil, Upper_Left)
        while true do
            if (dealsTimer:check() > 150) then break end
            dotClicker()
            local rewards = SearchImageNew(rewardsList, nil, 0.93, true, true, 1)
            if (rewards.name == "Claim") then
                while true do
                    local claim = SearchImageNew(Main.Daily_Rewards.dir.. "Claim.png", nil, 0.93, true, false, 1)
                    if (claim.name) then 
                        Press(claim.xy, 1)
                        wait(1)
                    else break end
                end
            elseif (rewards.name == "Claimable 4") then
                Press(TargetOffset(rewards.xy, "0", "-20"), 1)
            elseif ((rewards.name == "Check Mark") or (rewards.name == "Check Mark 2")) and (isInRegion(Region(602, 418, 96, 160), rewards.x, rewards.y)) then
                -- remove tip or notifications
                PressRepeatNot(rewards.xy, Main.Daily_Rewards.dir.. rewards.name.. ".png", 1, 2, nil, rewards.r)
            elseif (rewards.name == "Current Day") then
                local Current_Day_ROI = Region(rewards.sx - (rewards.w*1.2), rewards.sy + (rewards.h / 2), rewards.w / 2, rewards.h / 2)
                Press(Current_Day_ROI, 1)
                removeStringFromTable(rewardsList, Main.Daily_Rewards.dir.. "Current Day.png")
            elseif (rewards.name == "Withdraw") then
                PressRepeatNew(rewards.xy, "Tap Anywhere.png", 1, 4)
                PressRepeatNew("Tap Anywhere.png", Main.Daily_Rewards.dir.. "Deposit.png", 1, 2)
                local Plus = PressRepeatNew(rewards.xy, "Plus.png", 1, 4)
                local Slider = SearchImageNew("Slider Button.png", nil, 0.9, true, false, 9999)
                swipe(Slider.loc, Plus.loc, .8)
                PressRepeatNew(Main.Daily_Rewards.dir.. "Confirm Deposit.png", Main.Daily_Rewards.dir.. "Deposit.png", 1, 2)
            end
            local Exclamation = SearchImageNew({Main.Daily_Rewards.dir.. "Exclamation.png", Main.Daily_Rewards.dir.. "Dot.png"}, Upper_Half, 0.95, true, false, 2)
            if (Exclamation.name) then 
                Press(Exclamation.xy, 1)
                wait(1)
            else break end
        end
        Go_Back()
    end

    Logger()
    -- Steady-state delay: Auto_Daily_Rewards_Timer minutes
    -- (Use >=60s if someone sets it absurdly low)
    local nextDelay = math.max(60, Auto_DailyRewards_Timer * 60)
    Logger(string.format("Daily_Rewards: next run in %ds", nextDelay))
    return nextDelay
end


function heroMission()
	Current_Function = getCurrentFunctionName()
	Logger("Hero Mission Started")
	if (checkStamina(0, "Intel") > 0) then
		Logger("Hero Mission Stamina Lacking")
		Main.Hero_Mission.enabled, Main.Hero_Mission.timer = false, nil
		return 0
	end
	local heroMissionEventDir = "Hero Mission/"
	Logger("Checking Hero Mission Event")
	local Events_Logo = SingleImageWait("Event logo.png", 5, Upper_Half, 0.9, true)
	if not(Events_Logo) then
		Logger("Events screen not found")
		return 300
	end
	PressRepeatNew(Events_Logo, "Events.png", 1, 2, Upper_Half, Upper_Half, 0.9, true, true)
	Logger("Searching for Hero Mission Tab")
	local heroMissionTab = SearchImageNew(heroMissionEventDir.. "Hero Mission Tab Selected.png", Upper_Half, 0.9, true)
	if not(heroMissionTab.name) then
		local Swipe_Right, Swipe_Left, Middle = Location(ranNumbers(50, 10), 170), Location(ranNumbers(655, 10), 170), Location(screen.x/2, 170)
		local Start_Loc = Swipe_Right

		-- NEW: after Calendar appears, do exactly two right swipes
		local pendingRightSwipes = 0

		local swipeTimer = Timer()
		while true do
			-- Force right swipe if we owe any
			if pendingRightSwipes > 0 then
				Start_Loc = Swipe_Left  -- left->middle = swipe RIGHT
			end

			--swipe(ranNumbers(Start_Loc, 10), Middle, 2)
			swipe(Start_Loc, Middle, 2)
			wait(1)

			-- If we just did one of the "owed" swipes, decrement it
			if pendingRightSwipes > 0 then
				pendingRightSwipes = pendingRightSwipes - 1
			end

			heroMissionTab = SearchImageNew(heroMissionEventDir.. "Hero Mission Tab Unselected.png", Upper_Half, 0.9, true)
			if (heroMissionTab.name) then break end

			if (SearchImageNew("Events/Calendar.png", Upper_Half, 0.9, true).name) then 
				Logger("Calendar Found – will swipe RIGHT x2")
				-- Queue exactly two right swipes on the next iterations
				pendingRightSwipes = 2
			end

			if (SearchImageNew("Events/Community.png", Upper_Right, 0.9, true).name) then 
				Logger("Community found")
				Go_Back("Hero Mission Event Unavailable")
				Main.Hero_Mission.enabled, Main.Hero_Mission.status, Main.Hero_Mission.timer = false, false, nil
				if (Enable_Auto_Attack) and (checkStamina(0, "Intel") <= 0) then Auto_Attack, Main.Attack.cooldown, Main.Attack.timer = true, 0, Timer() end
				return 0
			end
			if (swipeTimer:check() >= 30) then
				Go_Back("Got Stuck with Swiping")
				return 300
			end
		end
	end
	if (heroMissionTab.name) then
		Logger("Clicking Hero Mission Tab")
		PressRepeatNew(heroMissionTab.xy, {heroMissionEventDir.. "Event Rewards.png", heroMissionEventDir.. "Event Rewards 2.png"}, 1, 1)
		
		if (SingleImageWait(heroMissionEventDir.. "Preview.png", 2, Lower_Half)) then
			Logger("Hero Mission is on Preview")
			Main.Hero_Mission.enabled, Main.Hero_Mission.timer = false, nil
			if (Enable_Auto_Attack) then
				if (checkStamina(0, "Intel") <= 0) then Auto_Attack, Main.Attack.cooldown, Main.Attack.timer = true, 0, Timer() end
			else
				if (Auto_Join_Enabled) and not(Main.Auto_Join.status) then 
					Auto_Join("ON")
					Main.Auto_Join.status = true
				end
			end
			return 0
		else
			if (Main.Hero_Mission.rewards) then
				Logger("Hero Mission Rewards Activated")
				local Box_List = {[1] = Region(146, 1212, 45, 36), [3] = Region(252, 1212, 45, 36), [5] = Region(357, 1212, 45, 36), [7] = Region(462, 1212, 45, 36), [10] = Region(610, 1212, 45, 36)}
				if (find_in_list({1, 3, 5, 7, 10}, Main.Hero_Mission.rewards_box)) then
					Logger("Clicking Location")
					local currentBox, rewardResult = Box_List[Main.Hero_Mission.rewards_box]
					while true do
						local offsetX, offsetY = math.random(1, currentBox:getW() - 1), math.random(1, currentBox:getH() - 1)
						click(Location(currentBox:getX() + offsetX, currentBox:getY() + offsetY))
						wait(2)
						rewardResult = SearchImageNew({heroMissionEventDir.. "Exp.png", heroMissionEventDir.. "Tap Anywhere.png"}, Lower_Half, 0.9, true)
						if (rewardResult.name) then break end
					end
					Logger("Closing Rewards")
					PressRepeatNot(heroMissionTab.xy, heroMissionEventDir.. rewardResult.name.. ".png", 1, 1)
					Main.Hero_Mission.rewards = false
					Logger("Claiming Rewards Completed")
				end
			end
			
			local currentTotal = Num_OCR(Region(76, 1303, 40, 33), "a")
			if (currentTotal >= 0) and (currentTotal < 10) then
				Logger("Checking for Event Status")
				local Task
				local eventStatus = SearchImageNew({heroMissionEventDir.. "Trace the Reaper.png", heroMissionEventDir.. "Capture the Reaper.png"}, Lower_Most_Half, 0.9, true, false, 5)
				if (eventStatus.name == "Trace the Reaper") then
					Logger("Trace the Reaper")
					local x,y,w,h = eventStatus.sx, eventStatus.sy, eventStatus.w, eventStatus.h
					local ROI = Region(x + w, y, w * 4, h)
					local scatteredParts = tostring(Num_OCR(ROI, "a"))
					if (#scatteredParts > 1) and (tonumber(scatteredParts:sub(1, #scatteredParts - 1)) > 0) then
						PressRepeatNew(eventStatus.xy, "City.png", 1, 4)
						wait(2)
						Task = "Attack"
					else Logger("Scattered Parts is not enough") end
				elseif (eventStatus.name == "Capture the Reaper") then
					Logger("Capture the Reaper")
					PressRepeatNew(eventStatus.xy, "City.png", 1, 4)
					Task = "Attack"
				else Logger("Scattered Parts image not found") end
				
				if (Task == "Attack") then
					Logger("Starting Rally")
					if not(SearchImageNew("Share Coordinates.png", nil, 0.9, true).name) then
						Logger("Rally button Unavailable")
						PressRepeatNew(Location(screen.x/2, screen.y/2), "Share Coordinates.png", 1, 2)
					end
					Logger("Searching Rally")
					local Rally = SingleImageWait("Rally.png", 10, nil, 0.9, true)
					Logger("Clicking Rally")
					local Attack_Status = PressRepeatNew(Rally, {"Hold Rally.png", "March Queue Limit.png", "March Queue Maxed.png"}, 1, 3, nil, nil, 0.75, true, true)
					if (Attack_Status.name == "March Queue Limit") then
						Go_Back("March Queue limit sleeping for 300 seconds")
						return 300
					elseif(Attack_Status.name == "March Queue Maxed") then
						Go_Back(string.format("March Queue Maxed sleeping for %s seconds", Use_All_Timer))
						return Use_All_Timer
					end
					Logger("Clicking Hold Rally")
					Deploy_Btn = PressRepeatNew(Attack_Status.xy, "Deploy.png", 1, 2, nil, nil, 0.8, true)
					Logger("Changing Original Settings")
					local Original_Attack_Type, Original_AutoStop_Attack, Original_Solo_troop = Attack_Type, AutoStop_Attack, Solo_troop
					Attack_Type, AutoStop_Attack, Solo_troop = "Polar Terror", false, false
					Logger("Starting Auto_Beast")
                                        local rawFlagReq = Flag_Req
                                        local _flagReq = normalizeFlag(rawFlagReq)
                                        Logger(string.format("AutoAttack: using Flag_Req=%s (raw=%s)", tostring(_flagReq), tostring(rawFlagReq)))
                                        total_Seconds = Auto_Beast(Deploy_Btn, Attack_Type, _flagReq, Use_Hero, false)
					Logger("Going back to original Settings")
					Attack_Type, AutoStop_Attack, Solo_troop = Original_Attack_Type, Original_AutoStop_Attack, Original_Solo_troop
					if not(total_Seconds == 1500) then
						if (currentTotal + 1 == 1) or (currentTotal + 1 == 3) or (currentTotal + 1 == 5) or (currentTotal + 1 == 7) or (currentTotal + 1 == 10) then
							Logger("Rewards Possible and Adding to claim")
							Main.Hero_Mission.rewards = true
							Main.Hero_Mission.rewards_box = currentTotal + 1
						end
					end
					return total_Seconds
				end
			end
		end
	end
	
	Go_Back("Hero Mission Event Completed")
	Main.Hero_Mission.enabled, Main.Hero_Mission.status, Main.Hero_Mission.timer = false, false, nil
	if (Enable_Auto_Attack) then
		if (checkStamina(0, "Intel") <= 0) then Auto_Attack, Main.Attack.cooldown, Main.Attack.timer = true, 0, Timer() end
	else
		if (Auto_Join_Enabled) and not(Main.Auto_Join.status) then 
			Auto_Join("ON")
			Main.Auto_Join.status = true
		end
	end
	return 0
end


function checkIntelStamina()
	Logger("Searching for Intel Button")
	local Intel_Button = SearchImageNew("Intel Button.png", Lower_Right, 0.9, true)
	if not(Intel_Button.name) then return 60 end
	Logger("Intel Found and Opening")
	PressRepeatNew(Intel_Button.xy, "Intel Cans.png", 1, 2, nil, Upper_Right, 0.9, nil, true)
	Number = Num_OCR(Region(580,20,97,39), "t")
	Go_Back()
	return Number
end

function mercPrestige()
	Current_Function = getCurrentFunctionName()
	local mercDir = "Mercenary Prestige/"
	if (Main.mercPrestige.marchSet > 3) then
		Main.mercPrestige.enabled, Auto_Merc_Prestige, Main.mercPrestige.status = false, false, false
		Main.mercPrestige.timer = nil
		return 0
	end
	local curStamina = checkIntelStamina()
	local mercBtn = SingleImageWait(mercDir.. "Merc Prestige Quick Btn.png", 2, Lower_Half)
	if not(mercBtn) then
		Main.mercPrestige.enabled, Auto_Merc_Prestige, Main.mercPrestige.status = false, false, false
		Main.mercPrestige.timer = nil
		return 0
	end
	local deploySettings, marchType, flagType = Main.mercPrestige.marchSettings[Main.mercPrestige.marchSet]
	local attackStatus, attack = false, {name = false}
	local mercStatus = PressRepeatNew(mercBtn, {mercDir.. "Scout.png", mercDir.. "Attack.png"}, 1, 4, nil, Lower_Half)
	if (mercStatus.name == "Scout") then
		if (curStamina < deploySettings.stamina + 15) then
			Main.mercPrestige.enabled, Auto_Attack = false, false
			Go_Back("Stamina Insufficient Checking Remaining Stamina")
			return 0
		end
		attackStatus = true
		attack = PressRepeatNew(mercStatus.xy, mercDir.. "Attack.png", 1, 4, nil, Lower_Half)
	else
		if (curStamina < deploySettings.stamina) then
			Logger("Stamina Insufficient Checking Remaining Stamina")
			Main.mercPrestige.enabled, Auto_Attack = false, false
			return 0
		end
		Main.mercPrestige.lossCounter = Main.mercPrestige.lossCounter + 1
		attack = mercStatus
		if (Main.mercPrestige.lossCounter == 2) then
			Main.mercPrestige.marchSet = Main.mercPrestige.marchSet + 1
			Main.mercPrestige.lossCounter = 0
		end
	end
	
	if (deploySettings.attackType == "Request Help") then
		--add request help here
	else
		local Deploy_Btn
		if (deploySettings.attackType == "Solo") then
			Deploy_Btn = PressRepeatNew(attack.xy, {"Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.8, true)
			marchType, flagType = "Beasts", deploySettings.flag
		else
			Deploy_Btn = PressRepeatNew(mercDir.. "Rally.png", {"Deploy.png", "March Queue Limit.png"}, 1, 2, nil, nil, 0.8, true)
			marchType, flagType = "Reaper", deploySettings.flag 
		end
                local rawFlagReq = flagType
                local _flagReq = normalizeFlag(rawFlagReq)
                Logger(string.format("AutoAttack: using Flag_Req=%s (raw=%s)", tostring(_flagReq), tostring(rawFlagReq)))
                return Auto_Beast(Deploy_Btn, marchType, _flagReq, false)
        end
end

function eventsChecker() --add more events
	Current_Function = getCurrentFunctionName()
	Logger("Checking Events")
	local Events_Logo = SearchImageNew("Event logo.png", Upper_Half, 0.9, true, false)
	if not(Events_Logo.name) then
		Logger("Events screen not found")
		return 10
	end
	Logger("Opening Events")
	PressRepeatNew(Events_Logo.xy, "Events.png", 1, 2, Upper_Half, Upper_Half, 0.9, true, true)
	Logger("Events Opened")
	for i, event in ipairs(Main.Events.List) do
		Logger("Event")
		Logger()
		local eventStatus = SearchImageNew(event, Upper_Half, 0.9, true)
		if (eventStatus.name) then
			if (event == "Mercenary Prestige/Events Merc Tab.png") then
				Main.mercPrestige.enabled, Main.mercPrestige.status, Main.mercPrestige.timer = true, true, Timer()
			elseif (event == "Hero Mission/Events Hero Mission Tab.png") then
				Main.Hero_Mission.enabled, Main.Hero_Mission.status, Main.Hero_Mission.timer = true, true, Timer()
			end
		else
			Logger("Swiping to Left Most")
			Logger()
			swipe(Location(35, 190), Location(1510, 190), .5)
			wait(.5)
			swipe(Location(35, 190), Location(1510, 190), .5)
			wait(.5)
			
			while true do
				Logger("Swiping")
				swipe(Location(ranNumbers(564, 10), 190), Location(357, 190), 1)
				Logger("Searching for Image")
				Logger()
				eventStatus = SingleImageWait(event, 1.5, Upper_Half, 0.9, true)
				if (eventStatus) then
					Logger("Image Found and waiting to stop!")
					wait(1)
					Logger("Searching for Image again")
					Logger()
					eventStatus = SingleImageWait(event, 999999, Upper_Half, 0.9, true)
					Logger("Clicking current event!")
					Logger()
					Press(eventStatus, 1)
					Logger("Current Event Enabled")
					wait(1)
					if (event == "Mercenary Prestige/Events Merc Tab.png") then
						Main.mercPrestige.enabled, Main.mercPrestige.status, Main.mercPrestige.timer = true, true, Timer()
					elseif (event == "Hero Mission/Events Hero Mission Tab.png") then
						local heroMissionEventDir = "Hero Mission/"
						if (SingleImageWait(heroMissionEventDir.. "Preview.png", 2, Lower_Half)) then
							Logger("Hero Mission is on Preview")
						else 
							if (Num_OCR(Region(76, 1303, 40, 33), "a") < 10) then
								Main.Hero_Mission.enabled, Main.Hero_Mission.status, Main.Hero_Mission.timer = true, true, Timer()
							end
						end
					end
					break
				else
					if (SearchImageNew("Events/Community.png", Upper_Right, 0.9, true).name) then 
						Logger("Community found")
						break
					end
				end
			end
		end
	end
	if not(Main.Events.Status) then Main.Events.Status = true end
	Go_Back("Events Checker Completed")
end

function Check_Red_Alerts()
	function shield()
		--SingleImageWait(target, waitTime, boxRegion, Similarity, Color, Mask)
		Logger()
		if (SingleImageWait("Red Alert/Active Shield.png", 1, Region(60, 99, 240, 39))) then
			Logger("Shield Still Active")
			return 0
		end
		Logger("No Active Shield Found, Activating Shield")
		Logger()
		PressRepeatHexColor(Location(34, 114), Location(417, 122), "#6B9FD8", 5, 1)
		Logger("Clicking Shield to activate list")
		PressRepeatHexColor(Location(114, 272), Location(114, 344), "#166AA8", 5, 2)
		Logger("Searching for rechargeable shield")
		if(isColorWithinThresholdHex(Location(630, 410), "#4FA5FC", 5)) then --will prioritize rechargeable shield
			Logger("Rechargeable shield found and activating")
			PressRepeatHexColor(Location(630, 410), Location(181, 288), "#26E34B", 5, 2)
			Go_Back("8 Hour Shield Activated")
			return 0
		end
		
		local shieldLoc = {["2h"] = Location(630, 545), ["8h"] = Location(630, 700), ["24h"] = Location(630, 845), ["72h"] = Location(630, 995)}
		Logger("Activating " .. RequiredShield .. " Shield")
		local useStatus = PressRepeatHexColor(shieldLoc[RequiredShield], Location(181, 288), {"#6288C2", "#26E34B"}, 5, 2) --6288C2 gems required
		if (useStatus == "6288C2") then
			Logger("Shield Item Not Found! Buying shield instead")
			PressRepeatHexColor(shieldLoc[RequiredShield], Location(520, 520), "#FFB80F", 5, 2) -- Click Use until Buy & Use
			Logger("Clicking Buy & use until purchase")
			PressRepeatHexColor(Location(520, 520), Location(250, 900), "#FFB80F", 5, 2) -- Click Buy & Use until Purchase
			Logger("Clicking Purchase until back to original screen")
			PressRepeatHexColor(Location(250, 900), Location(181, 288), "#26E34B", 5, 2) -- Click Purchase Until back Original Screen
			Go_Back(RequiredShield .. " Shield Activated")
			return 0
		end
	end

	Current_Function = getCurrentFunctionName()
	local r, g, b = getColor(Location(screen.x - 1, screen.y - 1))
	if isInFilteredRange(r, g, b) then
		Logger("Found reddish color at the specified coordinate")
		local Red_Alert = SearchImageNew("Red Alert/Red Alert.png")
		local Alerts_Found = {}
		if (Red_Alert.name) then
			local Ignore_All = PressRepeatNew(Red_Alert.xy, "Red Alert/Ignore All.png", 1, 2)
			snapshot()
			for _, Alert in ipairs({"Red Alert/Attacking.png", "Red Alert/Rallying.png", "Red Alert/Scout.png"}) do
				local Red_Alert_Result = SearchImageNew(Alert)
				if (Red_Alert_Result.name) then
					table.insert(Alerts_Found, Red_Alert_Result.name)
				end
			end
			usePreviousSnap(false)
			Press(Ignore_All.xy, 1)
			Go_Back(table.concat(Alerts_Found, ", "))
		end
		local Task
		if (find_in_list(Alerts_Found, "Attacking")) then
			Task = "Attacking"
		elseif (find_in_list(Alerts_Found, "Rallying")) then
			Task = "Rallying"
		elseif (find_in_list(Alerts_Found, "Scout")) then
			Task = "Scout"
		end
		
		--what to do on such cases
		if ((Task == "Attacking") or (Task == "Rallying")) and (useShield) then
			shield()
		end

		--[[if (Task == "Emoji") then
			PressRepeatNew("City.png", "World.png", 1, 2, Lower_Right, Lower_Right, 0.9, true, true)
			PressRepeatNew("World.png", "City.png", 1, 2, Lower_Right, Lower_Right, 0.9, true, true)
			PressRepeatNew(Screen_Center, "Emoji/Emoji.png", 1, 2)
			PressRepeatNew("Emoji/Emoji.png", "Emoji/Settings.png", 1, 2)
			local Emoji_List = findAllNoFindException(Pattern("Emoji/Emoji Frame2.png"):similar(0.75):color())
			if (table.getn(Emoji_List) > 0) then
				local randomEmoji = math.random(1, #Emoji_List)
				Press(Emoji_List[randomEmoji], 1)
			end
		end--]]
	--else
		--Logger("No reddish color found at the specified coordinate")
	end
end


function Change_Char(CharType)
	local Change_Char_Folder = "Change Character/"
	Logger("Changing Character")
	local Settings = PressRepeatSingle("50,50", Change_Char_Folder.. "Settings.png", 1, 4, nil, Lower_Right, 0.9, false, true)
	Logger("Clicking Settings")
	local Characters = PressRepeatSingle(Settings.xy, Change_Char_Folder.. "Characters.png", 1, 4, nil, Upper_Left, 0.9, false, true)
	Logger("Searching Character Label")
	PressRepeatSingle(Characters.xy, Change_Char_Folder.. "Characters Label.png", 1, 4, nil, Upper_Half, 0.9, false, true)
	wait(1.5)
	Logger("Clicking Character Area")
	PressRepeatSingle(Change_Char_Folder.. "Character Area.png", Change_Char_Folder.. "Login Confirm.png", 1, 3, nil, nil, 0.9, true, true)
	Logger("Pressing Login Confirm")
	PressRepeatSingle(Change_Char_Folder.. "Login Confirm.png", "Customer Service.png", 1, 4)
	Logger("Waiting for Customer Service to Disappear")
	waitVanish(Pattern("Customer Service.png"):similar(0.9), 10)
	Logger("Waiting for Customer Service to Appear")
	SingleImageWait("Customer Service.png", 5, Upper_Left)
	Logger("Waiting for Customer Service to Disappear again")
	waitVanish(Pattern("Customer Service.png"):similar(0.9), 10)
	Sleep_Iter(13)
	
	if not(SingleImageWait("World.png", 2, Lower_Right, 0.9, true)) then
		Logger("Cannot Find World in Screen")
		PressRepeatSingle(4, "World.png", 1, 4, nil, Lower_Half)
		while true do
			Sleep_Iter(3)
			if (SearchImageNew("World.png", nil, 0.9, true).name) then break
			else 
				startApp("com.gof.global")
				wait(1)
				PressRepeatSingle(4, "World.png", 1, 2, nil, Lower_Half) 
			end
		end
	end
	Logger("World Image found and Clicking!")
	PressRepeatSingle("World.png", "City.png", 1, 2, Lower_Right, Lower_Right, 0.9, true, true)
	Logger("Changing Character Completed")
	CHARACTER_ACCOUNT = CharType
	Logger("Current Character: " ..CHARACTER_ACCOUNT)
end

function Enable_Alt_Events()
	Alt_Events = {Alt_Tech = altTech, Alt_Alliance_Chest = altAllianceChest, Alt_Exploration = altExploration, Alt_My_Island = altMyIsland, Alt_Training_Troops = altTroopTraining, Alt_Recruit_Heroes = altRecruitHeroes, Alt_Pet_Adventure = altPetAdventure, Alt_Arena = altArena,
		Alt_Gather_RSS = altRssGather, Alt_Auto_Join = altAutoJoin, Alt_Pet_Skills = altPetSkills, Alt_City_Store = altStoreHouse, Alt_Daily_Rewards = altDailyRewards, Alt_War_Academy = altWarAcademy, Chief_Order_store = altChiefOrder, Alt_Crystal_Laboratory = altCrystalLaboratory, 
		Alt_Mail = altMail, Alt_Bear = altBear, Nomadic_Merchant = altNomadicMerchant, Heal = false, Help = false, Alt_Triumph = false, Alt_Labyrinth = false}
end

function altPrepTimer(timeOnly)
	local hour, min = timeOnly:match("(%d+):(%d+)")
	hour, min = tonumber(hour), tonumber(min)
	min = min - 5
	if min < 0 then
		min = min + 60
		hour = hour - 1
		if hour < 0 then
			hour = 23  -- Wrap around if it goes below 0
		end
	end
	return string.format("%02d:%02d", hour, min)
end

function Barney_Specifics_AM(Task)
	if (Task == "Bear") then
		if (Alt_Events.Alt_Bear) then
			local dateTime = preferenceGetString("altBearNextRun", "2024/11/13 21:35:00")
			local timeOnly, cooldown = dateTime:match("%d+:%d+"), 0
			if (altBearProcess == "byEvents") then
				if (Check_Bear_Day(timeOnly)) then
					Logger("ALT Bear Event Started")
					cooldown = Bear_Event(timeOnly, altPrepTimer(timeOnly))
				else
					Logger("ALT Bear Event Unavailable")
					local barneyChangeCharTime = subtractSecondsFromTime(string.format("%s:00", timeOnly), "120")
					Logger("ALT Change Char Time: " ..barneyChangeCharTime)
					cooldown = Get_Time_Difference(nil, barneyChangeCharTime)
				end
			else -- TASKS
				if (Main.Barney.status) then 
					Logger("New ALT Bear Event Started")
					cooldown = Bear_Event(timeOnly, altPrepTimer(timeOnly))
				end
			end
			Main.Barney.bear_cooldown = cooldown
			Logger("Alt Bear: " ..cooldown)
			Main.Barney.bear_timer:set()
		end
		Change_Char("Main")	
	else
		if (Alt_Events.Alt_Alliance_Chest) then
			Alliance_Chests()
			Alt_Events.Alt_Alliance_Chest = false
		end
		if (Alt_Events.Alt_Exploration) then
			Exploration()
			Alt_Events.Alt_Exploration = false
		end
		if (Alt_Events.Alt_My_Island) then
			My_Island()
			Alt_Events.Alt_My_Island = false
		end
		if (Alt_Events.Alt_Training_Troops) then	
			City_Troop_Training("Infantry")
			City_Troop_Training("Lancer")
			City_Troop_Training("Marksman")
			Alt_Events.Alt_Training_Troops = false
		end
		if (Alt_Events.Alt_Recruit_Heroes) then
			Recruiting_Heroes()	
			Alt_Events.Alt_Recruit_Heroes = false
		end
		if (Alt_Events.Alt_Pet_Adventure) then
			Pet_Adventure_Event()
			Alt_Events.Alt_Pet_Adventure = false
		end		
		if (Alt_Events.Alt_Arena) and not(preferenceGetString("altAccountArena", "NA") == Current_Date) then
			Arena(altArenaGems)
			Alt_Events.Alt_Arena = false
			preferenceGetString("altAccountArena", Current_Date)
		end
		if (Alt_Events.Alt_War_Academy) and not(preferenceGetString("altAccountWarAcademy", "NA") == Current_Date) then
			War_Academy_Fn(altWARedeemTotal)
			Alt_Events.Alt_War_Academy = false
			preferenceGetString("altAccountWarAcademy", Current_Date)
		end
		if (Alt_Events.Chief_Order_store) then
			Chief_Order_Store()
			Alt_Events.Chief_Order_store = false
		end
		
		if (Alt_Events.Alt_Crystal_Laboratory) and not(preferenceGetString("altAccountCrystalLaboratory", "NA") == Current_Date) then
			Crystal_Laboratory_Fn()
			Alt_Events.Alt_Crystal_Laboratory = false
			preferenceGetString("altAccountCrystalLaboratory", Current_Date)
		end
		
		if (Alt_Events.Nomadic_Merchant) and not(preferenceGetString("altAccountNomadicMerchant", "NA") == Current_Date) then
			Nomadic_Merchant()
			Alt_Events.Nomadic_Merchant = false
			preferenceGetString("altAccountNomadicMerchant", Current_Date)
		end
		
		if (Alt_Events.Alt_Gather_RSS) then
			local newRss = false
			while true do
				snapshotColor()
				local meat = SingleImageWait("March Animal Farm.png", 0, Upper_Left, 0.9, true)
				local wood = SingleImageWait("March Lumberyard.png", 0, Upper_Left, 0.9, true)
				local coal = SingleImageWait("March Coal Mine.png", 0, Upper_Left, 0.9, true)
				local iron = SingleImageWait("March Smelter.png", 0, Upper_Left, 0.9, true)
				local burdenBearer = SingleImageWait("Burden Bearer Skill.png", 0, Upper_Half, 0.92, true)
				usePreviousSnap(false)
				if not(meat) then 
					newRss = true
					SearchResources("Meat", "Hero")
				end
				if not(wood) then
					newRss = true
					SearchResources("Wood", "Hero")
				end
				if not(coal) then
					newRss = true
					SearchResources("Coal", "Hero")
				end
				if not(iron) then
					newRss = true
					SearchResources("Iron", "Hero")
				end
				if (newRss) and (burdenBearer) then 
					Logger("Waiting 180 seconds for Burden Bearer to Clear")
					wait(180)
				else break end
			end
			Alt_Events.Alt_Gather_RSS = false
		end
		if (Alt_Events.Alt_Auto_Join) then
			Auto_Join("ON")
			Alt_Events.Alt_Auto_Join = false
		end
		if (Alt_Events.Alt_Pet_Skills) then
			Use_Pet_Skills("Resources")
			Alt_Events.Alt_Pet_Skills = false
		end
		if (Alt_Events.Alt_City_Store) then
			City_Storehouse(nil)
			Alt_Events.Alt_City_Store = false
		end
		if (Alt_Events.Alt_Daily_Rewards) then
			Daily_Rewards()
			Alt_Events.Alt_Daily_Rewards = false
		end
		if (Alt_Events.Alt_Tech) then
			Tech_Help()
			Alt_Events.Alt_Tech = false
		end
		if (Alt_Events.Alt_Triumph) then
			Triumph("World")
			Alt_Events.Alt_Triumph = false
		end
		if (Alt_Events.Alt_Labyrinth) then
			theLabyrinth()
			Alt_Events.Alt_Labyrinth = false
		end
		if (Alt_Events.Alt_Mail) then
			mailRewardsClaim()
			Alt_Events.Alt_Mail = false
		end
		
		if (Alt_Events.Alt_Bear) and (altBearProcess == "byTask") then Check_altBear_Day2() end
		
		if (HelpOption) then AutoHelp({name = nil}) end
		if (HealOption) then newHeal(nil) end
		
		Main.Barney.cooldown = Get_Nearest_Time(Barney_Time)
		Main.Barney.timer:set()
		Enable_Alt_Events()
		Change_Char("Main")	
	end
end

function Volume_Commands(Command)
	if (Command == "Auto Attack") then
		Auto_Attack, Main.Attack.timer, Main.Attack.cooldown = true, Timer(), 0
		AutoAttack_GUI()
	elseif (Command == "Gather Rss") then
		Auto_Gather = true
		Main.Meat.timer, Main.Wood.timer, Main.Coal.timer, Main.Iron.timer = Timer(), Timer(), Timer(), Timer()
		Main.Meat.cooldown, Main.Wood.cooldown, Main.Coal.cooldown, Main.Iron.cooldown = 0, 0, 0, 0
		if (Auto_Gather_Option == 1) then RSS_GUI1() else RSS_GUI2() end
	elseif (Command == "Intel") then
		Auto_Intel, Main.Intel.timer, Main.Intel.cooldown = true, Timer(), 0
		Intel_Options_GUI()
	elseif (Command == "Stop") then
		Message.Total_Time = Get_Time2(os.time() - Start_Time)
		setStopMessage(printMessage(Message, keyOrder))
		scriptExit(result)
	elseif (Command == "Sleep") then
		Other_GUI()
	end
end

function Timer_Setup()
	if (AM_Enabled) then Main.AM.timer = Timer() end
	if (Auto_Gather) then 
		Main.Meat.timer, Main.Wood.timer, Main.Coal.timer, Main.Iron.timer = Timer(), Timer(), Timer(), Timer()
		if (Extra_Gather_1_Status) then Main.Extra_Gather_1.timer = Timer() end
		if (Extra_Gather_2_Status) then Main.Extra_Gather_2.timer = Timer() end
	end
	if (Auto_Tech) then Main.Tech.timer = Timer() end
	if (Auto_Triumph) then 
		Main.Triumph.timer, Main.Triumph.status = Timer(), true
	end
	if (Auto_Attack) then Main.Attack.timer = Timer() end
	if (Main.Experts.enabled) then
		Main.Experts.timer = Timer()
		Main.Experts.cooldown = Main.Experts.cooldown or 0
		if (Main.Experts.dawnEnabled) then
			Main.Experts.dawnTimer = Timer()
			if (Main.Experts.dawnNeedsImmediateCheck == nil) or (Main.Experts.dawnNeedsImmediateCheck == false) then
				Main.Experts.dawnNeedsImmediateCheck = shouldTriggerImmediateDawnAcademy()
			end
			if not (Main.Experts.dawnCooldown and Main.Experts.dawnCooldown > 0) then
				Main.Experts.dawnCooldown = getNextDawnAcademyCooldown()
			end
		end
		if (Main.Experts.enlistEnabled) then
			Main.Experts.enlistTimer = Main.Experts.enlistTimer or Timer()
		end
	end
	if (Exploration_Enabled) then Main.Exploration.timer = Timer() end
	if (Auto_Join_Enabled) then 
		Main.Auto_Join.timer, Main.Auto_Join.status = Timer(), true	
	end
	if (Reopen_Game) then Main.StartAPP1.timer = Timer() end
	if (Troops_Training) then Main.Infantry.timer, Main.Lancer.timer, Main.Marksman.timer = Timer(), Timer(), Timer() end
	if (Online_Rewards) then Main.Claim_Rewards.timer = Timer() end
	if (Recruit_Heroes) then Main.Recruit_Heroes.timer = Timer() end
	if (Map_Options) then Main.Maps_Option.timer = Timer() end
	if (Enable_My_Island) then Main.My_Island.timer = Timer() end
	if (Auto_Chests) then Main.Chests.timer = Timer() end
	if (Auto_Nomadic_Merchant) then Main.Nomadic_Merchant.timer = Timer() end
	if (Auto_Arena) then 
		Main.Arena.timer = Timer()
		if (Arena_Now_later == "Later") then Main.Arena.cooldown = Get_Time_Difference(nil, Arena_Time) end
	end
	if (Enable_War_Academy) then Main.War_Academy.timer = Timer() end
	if (Enable_Crystal_Laboratory) then Main.Crystal_Laboratory.timer = Timer() end
	if (Enable_Hero_Mission) then
		Main.Hero_Mission.enabled = true
		Main.Hero_Mission.timer = Timer()
	end
	
	if (Enable_The_Labyrinth) then Main.The_Labyrinth.timer = Timer() end
	
	if (Enable_Bear_Event) and (find_in_list({"Now", "byEvents"}, Bear_Now_later))  then
		Main.Bear_Event.timer = Timer()
		if (Bear_Now_later == "byEvents") then Main.Bear_Event.cooldown = Get_Time_Difference(nil, Bear_Start_Time) end			
	end
	
	if (Auto_Intel) then 
		Main.Intel.timer = Timer()
		if (Intel_Now_later == "Later") then Main.Intel.cooldown = Get_Nearest_Time() end
	end
	
	if (Auto_DailyRewards) then Main.DailyRewards.timer = Timer() end
	
	if (Auto_Mail) then Main.Mail.timer = Timer() end
	
	if (Storehouse_Stamina and not(Auto_Intel)) then Main.Storehouse.timer = Timer() end
	
	if (Chief_Order) then
		Main.Chief_Order_Event.timer = Timer() 
		Main.Chief_Order_Event.cooldown = Populate_Chief_Order_Events()
	end
	if (Pet_Adventure) then Main.Pet_Adventure.timer = Timer() end
	
	if (Barney_Enabled) then -- and (getUserID() == "zombrox@pm.me")
		Main.Barney.timer = Timer() 
		for timer in Barney_Time_Str:gmatch("%d+:%d+") do
			table.insert(Barney_Time, formatTime(timer))
		end
		Main.Barney.cooldown = Get_Nearest_Time(Barney_Time)
		Enable_Alt_Events()
		
		if (Alt_Events.Alt_Bear) then
			Main.Barney.bear_timer = Timer()
			if (altBearProcess == "byEvents") then
				local barneyChangeCharTime = subtractSecondsFromTime(altPrepStart, "120")
				Main.Barney.bear_cooldown = Get_Time_Difference(nil, barneyChangeCharTime)
			elseif (altBearProcess == "byTask") then
				local dateTime = preferenceGetString("altBearNextRun", "2024/11/13 21:35:00")
				local barneyChangeCharTime = subtractSecondsFromTime(dateTime:match("%d+:%d+:%d+"), "120")
				Main.Barney.bear_cooldown = Get_Time_Difference(nil, barneyChangeCharTime)
			else Main.Barney.bear_cooldown = 86400 end --24 hours
		end
	end
	
	OtherRequired_GUI()
	Main.Reset.timer = Timer()
	Main.Reset.cooldown = Get_Time_Difference()
	Main.Reset.cooldownBeforeReset = Main.Reset.cooldown - 60
	Main.City.timer = Timer()
end

function BackToWorld()
	local home_screen = PressRepeatNew(4, {"World.png", "City.png"}, 1, 3, Upper_Half, Lower_Half, 0.8, true, true)
	Logger("Checking Home Screen")
	if (home_screen.name == "World") then PressRepeatNew(home_screen.xy, "City.png", 1, 5, nil, Lower_Half, 0.9, false, true) end
	if (StartAPP_Timer2) then StartAPP_Timer2 = nil end
end

function Report_Sender()
	dialogInit()
	newRow()
	addCheckBox("Text_Report", "Send Text Report", false)
	newRow()
	addCheckBox("Image_Report", "Include Images", false)
	newRow()
	addTextView("Explain the issue you are facing")
	addEditText("Explain_Report", "")
	newRow()
	addCheckBox("Delete_Reports", "Delete TXT and Image File", false)
	newRow()
	addSeparator()
	newRow()
	addTextView("DISCLAIMER!!!!!!!")
	newRow()
	addTextView("Before sending any report, please ensure that you have thoroughly reviewed error logs and checked images to avoid inadvertently sharing sensitive information. I am not responsible for any data breaches in case you have not properly checked. This precaution helps maintain data security and confidentiality.")
	newRow()
	addTextView("TEXT REPORT LOCATION")
	newRow()
	addTextView(scriptPath().. "image/Error Logs.txt")
	newRow()
	addTextView("IMAGE REPORT DIRECTORY")
	newRow()
	addTextView(scriptPath().. "image/Error Screenshot/")
	newRow()
	dialogShowFullScreen("Report Screen")

	local explanation = Explain_Report or "No Explanation Added"
	local fileContents = ""
	if (Text_Report) then
		local file = io.open(scriptPath().. "image/Error Screenshot/Error Logs.txt", "r")
		if file then
			for line in file:lines() do fileContents = fileContents .. line .. "\n" end
			file:close()
		else print("Failed to open the file.") end
	end
	
	local image_table, error_images = {}
	if (Image_Report) then
		error_images = scandirNew("Error Screenshot/")
		for i, cur_image in ipairs(error_images) do
			if not(cur_image == "Error Logs.txt") then 
				table.insert(image_table, imageToBase64(scriptPath().. "image/Error Screenshot/" ..cur_image))
			end
		end
	end
	local result = ""
	if (Text_Report) or (Image_Report) then
		local reportToken = preferenceGetString("reportServerToken", "")
		if not (reportToken and reportToken ~= "") then
			Logger("Report not sent: reportServerToken preference is empty")
		else
			local query = {
				token = reportToken,
				so = "ankulua",
				mod = "activity",
				msg = string.format("%s\n%s", explanation, fileContents),
				images = table.concat(image_table, ", "),
			}
			local userId = getUserID()
			if userId and userId ~= "" then
				query.userid = userId
			end
			result = httpPost('http://178.153.194.140:32400', {data=textToBase64(jsonify(query))})
		end
	end
	if (Delete_Reports) and (result == "Report Sent Successfully!") then 
		local file = io.open(scriptPath() .. "image/Error Screenshot/Error Logs.txt", "w")
		if file then
			file:write("")
			file:close()
		else print("Failed to open the file.") end
		for _, cur_image in ipairs(error_images) do
			if cur_image ~= "Error Logs.txt" then
				local image_path = scriptPath() .. "image/Error Screenshot/" .. cur_image
				os.remove(image_path)
			end
		end
	end
	os.exit()
end

local No_Game
function Check_Screen()
	local result
	--Logger("Checking Home Screen")
	------------ Take Snapshot First ----------------
	if not(No_Game) then
		Logger("Going to Home Screen")
		keyevent(3)
		wait(2)
		Logger("Capturing Image from Home Screen")
		repeat 
			Home_Screen_Region:saveColor("Home Screen.png")
			wait(.2)
			No_Game = SearchImageNew("Home Screen.png", Home_Screen_Region, 0.9, true)
		until(No_Game.name)
		Logger("Image Captured! Reopening the Game!!!")
		local result_timer = Timer()
		repeat
			startApp("com.gof.global")
			result = SearchImageNew("Alliance.png", nil, 0.9, true)
		until(result.name) or (result_timer:check() > 10)
	end
	------------ Checking Home Screen Images ----------------
	if (Auto_Reconnect) then
		usePreviousSnap(false)
		local reconnectPrompt = SearchImageNew("Reconnect.png", nil, 0.85, true, false, 1)
		if (reconnectPrompt and reconnectPrompt.name) then
			Logger("Reconnect popup detected during home screen check; invoking reconnect handler")
			Auto_Reconnect_fn()
			return "Completed"
		end
	end
	if (isForegroundGameLost()) then
		Logger("Home Screen Found! Reopening the Game")
		while true do
			startApp("com.gof.global")
			if (SingleImageWait("Alliance.png", 15, Lower_Most_Half, 0.9, true)) then break
			else Go_Back("Trying to Go Back to Home Screen!") end
		end
		PressRepeatNew("World.png", "City.png", 1, 3, Lower_Most_Half, Lower_Most_Half, 0.9, true, true)
		Logger("Game Reopened")
		return "Reopened"
	end
	return "Completed"
end

function StartBot(User_ID)
	if (Main.Reset.timer:check() > Main.Reset.cooldown) then Reset_Daily_Events() end
	if (Auto_DailyRewards) and (Main.Reset.timer:check() >= Main.Reset.cooldownBeforeReset) and (Main.Reset.status) then 
		Daily_Rewards()
		Main.Reset.status = false
	end
	
	------------------------- HOME SCREEN CHECKER ----------------------------------------	
	if (Reopen_Game) and (Main.StartAPP1.timer:check() >= Main.StartAPP1.cooldown) then
		Current_Function = os.date("%Y-%m-%d %H:%M:%S - ").. "Home Screen Checker Started"
		local Current_Pack, Task = copyList(Pack_Sale_List)
		table.insert(Current_Pack, "Reconnect.png")
		Check_Screen()
		local Image_result = SearchImageNew(Current_Pack, nil, 0.9, false)
		if (Image_result.name) and (string.match(Image_result.name, "Pack Sale")) then Task = "Pack Sale" 
		elseif (Image_result.name) and (Image_result.name == "Reconnect") then Task = "Reconnect" 
		end		
		-------------------- TASKS --------------------
		if (Task == "Pack Sale") then
			Logger("Pack found and closing!!!!")
			BackToWorld()
		elseif (Task == "Reconnect") and (Auto_Reconnect) then
			Auto_Reconnect_fn()
		end
		Main.StartAPP1.cooldown = Reopen_Game_Timer
		Main.StartAPP1.timer:set()
		Current_Function = "Home Screen Checker Completed"
		Current_Function = os.date("%Y-%m-%d %H:%M:%S - ").. "Home Screen Checker Started"
	end	
		
	------------------------------- CHECK IF SCREEN IS WORLD OR CITY---------------
	snapshotColor()
	--if not(SearchImageNew("City.png", Lower_Most_Half).name) then
	if not(SingleImageWait("City.png", 1, Lower_Most_Half)) then
		usePreviousSnap(false)
		Logger("World Screen not found! Going back to world in " ..Get_Time(Get_Time_Difference(Get_Time(Main.City.timer:check()), Get_Time(Stuck_Timer))))
		wait(1)
		if (Enable_City_Timer) then 
			if (Main.City.timer:check() > (Stuck_Timer)) then
				Go_Back()
				Main.City.timer:set()
			end
		else 
			Enable_City_Timer = true
			Main.City.timer:set()
		end
		return "Completed"
	end
	
	if (Enable_My_Island) then
		myIslandScreen = SingleImageWait("Island Storehouse.png", 0, Lower_Left, 0.9, true)
		if (myIslandScreen) and not(Main.My_Island.screenTimer) then
			Logger("Island Screen Found! Starting Timer")
			Main.My_Island.screenTimer = Timer()
		end
		if not(myIslandScreen) and (Main.My_Island.screenTimer) then 
			Logger("Island Screen No Longer Available! Closing Timer")
			Main.My_Island.screenTimer = nil
		end
	end
	local Help_Status = SearchImageNew("Help.png", eventROI, 0.9, true)
	local quickHealBtn = SingleImageWait("Heal/Quick Heal Btn.png", 0, eventROI, 0.9)
	if (ChatClose) and (SearchImageNew("Share Coordinates.png", nil, 0.9, true).name) then
		Logger("Sharing Screen Found and Closing!")
		keyevent(4) 
	end
	
	local enableBearTaskList
	if (Enable_Bear_Event) and (Bear_Now_later == "byTask") and SingleImageWait("City.png", 0, Lower_Right, .9, true) then 
		enableBearTaskList = isColorWithinThresholdHex(Location(379, 7), {"#FF1E22", "#FF1E1F"}, 3)
	end
	if (Bear_Now_later == "byTask") and not(Main.Bear_Event.status) and (has46HoursPassed(preferenceGetString("mainBearLastRun", "NA"))) then --retrieve (add to main iteration to check everytime if there' still no task. starts checking bear image)
		local currentMinute = os.date("%M", os.time())
		if not(currentMinute == preferenceGetString("mainlastCheckedMinute", "-1")) then
			if (SingleImageWait("Bear Button.png", 0, Lower_Right, 0.9, true)) then
				Logger("Bear Button Found! Immediately Starting Event")
				local timeNow = os.date("%H:%M")
				Main.Bear_Event.status, Main.Bear_Event.bearStartTime, Main.Bear_Event.bearPrepTime = true, timeToSeconds(timeNow), timeToSeconds(timeNow) - 300
			end
		end
		preferencePutString("mainlastCheckedMinute", currentMinute)
	end
	usePreviousSnap(false)
	
	if (Check_Alerts) then Check_Red_Alerts() end
	
	if (Enable_My_Island) and (myIslandScreen) and (Main.My_Island.screenTimer:check() > 60) then
		myIslandScreen, Main.My_Island.screenTimer = nil, nil
		myIslandGoBack()
	elseif (Enable_My_Island) and (myIslandScreen) and (Main.My_Island.screenTimer:check() < 60) then
		Logger("Island Screen Found!")
		return "Completed"
	end
	
	Enable_City_Timer = false
	
	if not(Main.Events.Status) and (table.getn(Main.Events.List) > 0) then eventsChecker() end
	
	-------------------------------------- BEAR ----------------------------------------

	if (Enable_Bear_Event) then
		if (Bear_Now_later == "byTask") then
			if (Main.Bear_Event.initialCheck) then
				Logger("Initial Bear Check")
				Check_Bear_Day2()
			elseif (enableBearTaskList) then 
				Logger("Red Dot Found in Task Area")
				Check_Bear_Day2()
			end
			if not(Main.Bear_Event.status) then
				local mainBearSchedule = preferenceGetString("mainBearNextRun", "NA")
				if not(mainBearSchedule == "NA") and (string.match(mainBearSchedule, os.date("%Y/%m/%d"))) and not(mainBearSchedule == preferenceGetString("mainBearLastRun", "NA")) then
					local timePart = string.match(mainBearSchedule, "%d+/%d+/%d+ (%d+:%d+:%d+)")
					Logger("Bear Time Found: " ..timePart)
					Main.Bear_Event.bearStartTime, Main.Bear_Event.bearPrepTime, Main.Bear_Event.status = timeToSeconds(timePart), timeToSeconds(timePart) - 300, true
					Main.Bear_Event.cooldown = Get_Time_Difference(nil, Get_Time(Main.Bear_Event.bearPrepTime))
				end
			end

			if (Main.Bear_Event.status) and bearBoolTimer(Main.Bear_Event.bearStartTime) then --Main.Bear_Event.bearPrepTime is being processed in bearBoolTimer to become proper time
				Main.Bear_Event.cooldown, Main.Bear_Event.status, Bear_Now_later = Bear_Event(Get_Time(Main.Bear_Event.bearStartTime), Main.Bear_Event.bearPrepTime), false, "byTask"
				if (Main.Bear_Event.timer) then Main.Bear_Event.timer:set() end
			end
		end
		if (Bear_Now_later == "byEvents") and not(Main.Bear_Event.status) and (Main.Bear_Event.timer:check() > Main.Bear_Event.cooldown) then -- Using Event Tab
			if (Check_Bear_Day(Actual_Bear_Time)) then Main.Bear_Event.status = true
			else
				Main.Bear_Event.cooldown = Get_Time_Difference(nil, Bear_Start_Time)
				Main.Bear_Event.timer:set()
			end
			if (Main.Bear_Event.status) then
				Main.Bear_Event.cooldown, Main.Bear_Event.status, Bear_Now_later = Bear_Event(Actual_Bear_Time, Bear_Start_Time), false, "byEvents" --goes to byEvents by default
				Main.Bear_Event.timer:set()
			end
		end
		if (Bear_Now_later == "Now") then
			Main.Bear_Event.cooldown, Main.Bear_Event.status, Bear_Now_later = Bear_Event(Actual_Bear_Time, Bear_Start_Time), false, "byTask" --goes to byTask by default
			Main.Bear_Event.timer:set()
		end

		if (Main.Bear_Event.running) then return "Completed" end -- means bear isn't finished yet
	end

	---------------------- HELP -------------------------------------	
	if (HelpOption) then AutoHelp(Help_Status) end
	
	------------------------------ HEAL ----------------------------------
	if (HealOption) then newHeal(quickHealBtn) end

	--------------------------- MAPS Option ------------------------------	
	if (Map_Options) and (Maps_Current_Iteration <= Maps_Repeat_Total) and (Main.Maps_Option.timer:check() >= Main.Maps_Option.cooldown) and (SearchImageNew("City.png", Lower_Right, .9, true).name) then 
		Main.Maps_Option.cooldown = Map_function()
		Main.Maps_Option.timer:set()
	end
	
	--------------- INTEL ------------------
	if (Auto_Intel) and (Main.Intel.timer:check() > Main.Intel.cooldown) then
		Main.Intel.cooldown = Search_Intel()
		Main.Intel.timer:set()
	end
	
	if (Storehouse_Stamina and not(Auto_Intel)) and (Main.Storehouse.timer:check() > Main.Storehouse.cooldown) then
		Main.Storehouse.cooldown = City_Storehouse(nil)
		Main.Storehouse.timer:set()
	end
	
	---------------------- Beast and Polar Terror/Reaper -------------------------------------
	if ((Auto_Attack) and not(Main.Intel.status)) and ((Auto_Attack) and not(Main.mercPrestige.enabled)) then	
		if (Att_Timer) and not(Attack_Trigger) then
			local currentTime = os.time()
			if (tonumber(os.date("%H", currentTime)) == tonumber(Attack_Hour))then
				if (tonumber(os.date("%M", currentTime)) >= tonumber(Attack_Minutes)) and (tonumber(os.date("%M", currentTime)) <= tonumber(Attack_Minutes) + 20) then
					if (Auto_Join_Enabled) and (Main.Auto_Join.status) then 
						Auto_Join("OFF")
						Main.Auto_Join.status, Attack_Trigger = false, true
					end
				end
			end
		end

		if (Auto_Attack) and (Main.Attack.timer:check() > Main.Attack.cooldown) and (Attack_Trigger) and (attackLimit > Main.Attack.counter) then 
			local Hunting_Result = Hunting(Divider_March)
			Main.Attack.cooldown, Divider_March, Polar_Checker = Hunting_Result.Cool_Down, Hunting_Result.Divider_March, Hunting_Result.Polar
			if (Auto_Attack) then Main.Attack.timer:set()
			else Main.Attack.timer = nil end
		end
		
		if (Auto_Attack) and ((Attack_Type == "Polar Terror") or (Attack_Type == "Reaper")) and (Polar_Checker) and ((Main.Attack.timer:check() >= 80) and (Main.Attack.timer:check() <= 300)) and (SearchImageNew("Personal Rally.png").name) then
			Main.Attack.cooldown = (Main.Attack.cooldown - 300)
			Polar_Checker = false
			Main.Attack.timer:set()
		end	
	end
	
	---------------------- TECH -------------------------------------	
	if (Auto_Tech) and (Main.Tech.timer:check() > Main.Tech.cooldown) then 
		Tech_Help()
		Main.Tech.cooldown = Auto_Tech_Timer * 60
		Main.Tech.timer:set()
	end
	
	if (Auto_Triumph) and (Main.Triumph.timer:check() > Main.Triumph.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainTriumph", "NA") == Current_Date)) then 
		Main.Triumph.cooldown = Triumph("World")
		if (Main.Triumph.cooldown >= Get_Time_Difference()) then 
			preferencePutString("mainTriumph", Current_Date)
		end
		Main.Triumph.timer:set()
	end
	
	if (Auto_DailyRewards) and ((Main.DailyRewards.timer:check() > Main.DailyRewards.cooldown)) then -- add 2 minutes before reset also
		Main.DailyRewards.cooldown = Daily_Rewards()
		Main.DailyRewards.timer:set()
	end
	
	if (Auto_Mail) and (Main.Mail.timer:check() > Main.Mail.cooldown) then
		Main.Mail.cooldown = mailRewardsClaim()
		Main.Mail.timer:set()
	end
	
	if (Auto_Chests) and not(Auto_Chests_With_Tech) and (Main.Chests.timer:check() > Main.Chests.cooldown) then 
		Alliance_Chests()
		Main.Chests.cooldown = Auto_Tech_Timer * 60
		Main.Chests.timer:set()
	end	
	---------------------- RESOURCES GATHERING START -------------------------------------
	
	if (Auto_Gather) then
		if (Main.Meat.timer:check() > Main.Meat.cooldown) then
			Logger("Checking Animal Farm RSS")
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Required, RSS_Trigger, RSS_Image = "Meat", true, "March Animal Farm"
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Hero")
					Main.Meat.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Meat"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Meat.cooldown = SearchResources(RSS_Required, "Hero")
				end
				Main.Meat.timer:set()
			end
		end
		if (Main.Wood.timer:check() > Main.Wood.cooldown) then
			Logger("Checking Lumberyard RSS")
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Required, RSS_Trigger, RSS_Image = "Wood", true, "March Lumberyard"
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Hero")
					Main.Wood.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Wood"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Wood.cooldown = SearchResources(RSS_Required, "Hero")
				end		
				Main.Wood.timer:set()
			end
		end		
		if (Main.Coal.timer:check() > Main.Coal.cooldown) then
			Logger("Checking Coal Mine RSS")
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Required, RSS_Trigger, RSS_Image = "Coal", true, "March Coal Mine"
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Hero")
					Main.Coal.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Coal"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Coal.cooldown = SearchResources(RSS_Required, "Hero")
				end			
				Main.Coal.timer:set()
			end	
		end
		if (Main.Iron.timer:check() > Main.Iron.cooldown) then
			Logger("Checking Smelter RSS")
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Required, RSS_Trigger, RSS_Image = "Iron", true, "March Smelter"
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Hero")
					Main.Iron.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Iron"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Iron.cooldown = SearchResources(RSS_Required, "Hero")
				end
				Main.Iron.timer:set()
			end
		end
		if (Extra_Gather_1_Status) and (Main.Extra_Gather_1.timer:check() > Main.Extra_Gather_1.cooldown) then
			Logger("Checking EXTRA RSS: " ..Extra_Gather_1)
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Mapping = {Meat = "March Animal Farm", Wood = "March Lumberyard", Coal = "March Coal Mine", Iron = "March Smelter"}
				local RSS_Required, RSS_Trigger, RSS_Image = Extra_Gather_1, true, RSS_Mapping[Extra_Gather_1]
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				local RSS_Total = 2
				if (Extra_Gather_2_Status) and (Extra_Gather_2 == Extra_Gather_1) then RSS_Total = 3 end			
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Extra1")
					Main.Extra_Gather_1.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Extra1"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Extra_Gather_1.cooldown = SearchResources(RSS_Required, "Extra1")
				end
				Main.Extra_Gather_1.timer:set()
			end
		end
		if (Extra_Gather_2_Status) and (Main.Extra_Gather_2.timer:check() > Main.Extra_Gather_2.cooldown) then 
			Logger("Checking EXTRA RSS: " ..Extra_Gather_2)
			if (SearchImageNew("City.png", Lower_Right, .9, true).name) then
				local RSS_Mapping = {Meat = "March Animal Farm", Wood = "March Lumberyard", Coal = "March Coal Mine", Iron = "March Smelter"}
				local RSS_Required, RSS_Trigger, RSS_Image = Extra_Gather_2, true, RSS_Mapping[Extra_Gather_2]
				local RSS = regionFindAllNoFindException(Upper_Left, Pattern(RSS_Image ..".png"):color():similar(0.9))
				local RSS_Total = 2
				if (Extra_Gather_1_Status) and (Extra_Gather_2 == Extra_Gather_1) then RSS_Total = 3 end			
				for i, Cur_RSS in ipairs(RSS) do
					Logger(RSS_Image.. " RSS Found")
					if (RSS_Region["RGS"].N == 0) then RSS_Stats_Checker("") end
					local Result, Time_Status
					Result = Check_Gather_Time(Cur_RSS, RSS_Required, "Extra2")
					Main.Extra_Gather_2.cooldown, Time_Status = Result.Seconds + Main.rssGather.marchTime["Extra2"], Result.Status
					if (Time_Status) then
						RSS_Trigger = false 
						break
					end
				end
				if (RSS_Trigger) then
					Logger(RSS_Image.. " RSS Not Found")
					Main.Extra_Gather_2.cooldown = SearchResources(RSS_Required, "Extra2")
				end
				Main.Extra_Gather_2.timer:set()
			end
		end
	end
	
	---------------------- RESOURCES GATHERING END -------------------------------------
	
	if (Exploration_Enabled) and (Main.Exploration.timer:check() > Main.Exploration.cooldown) then 
		Main.Exploration.cooldown = Exploration()
		Main.Exploration.timer:set()
	end
	
	if (Main.Auto_Join.status) and (Main.Auto_Join.timer:check() > Main.Auto_Join.cooldown) then
		Main.Auto_Join.cooldown = Auto_Join("ON")
		Main.Auto_Join.timer:set()
	end

	---------------------- ALLIANCE MOBILIZATION START -------------------------------------

	if (AM_Enabled) and (Main.AM.timer:check() > Main.AM.cooldown) then
		Main.AM.cooldown = Alliance_Mobilization()
		if (AM_Enabled) then Main.AM.timer:set()
		else Main.AM.timer = nil end
	end
	
	if (Enable_My_Island) and (Main.My_Island.timer:check() > Main.My_Island.cooldown) then
		Main.My_Island.cooldown = My_Island()
		Main.My_Island.timer:set()
	end
	---------------------------------------- CITY ------------------------------------------
	if (Troops_Training) then
		if (Main.Infantry.timer:check() >= Main.Infantry.cooldown) then
			Main.Infantry.cooldown = City_Troop_Training("Infantry")
			Main.Infantry.timer:set()
		end
		if (Main.Lancer.timer:check() >= Main.Lancer.cooldown) then
			Main.Lancer.cooldown = City_Troop_Training("Lancer")
			Main.Lancer.timer:set()
		end
		if (Main.Marksman.timer:check() >= Main.Marksman.cooldown) then
			Main.Marksman.cooldown = City_Troop_Training("Marksman")
			Main.Marksman.timer:set()
		end
	end
	if (Main.Experts.enabled) then
		if not (Main.Experts.timer) then Main.Experts.timer = Timer() end
		Main.Experts.cooldown = Main.Experts.cooldown or 0
		if (Main.Experts.request) and (Main.Experts.timer:check() >= Main.Experts.cooldown) then
			Logger("Experts: executing Claim Marksmen")
			Main.Experts.request = false
			local success, followup = expert("marksman")
			local numericFollowup = tonumber(followup) or 0
			if (success) then
				Main.Experts.cooldown = numericFollowup
				Logger("Experts: Claim Marksmen completed")
			else
				if (numericFollowup <= 0) then numericFollowup = 600 end
				Main.Experts.cooldown = numericFollowup
				Main.Experts.request = true
				Logger(string.format("Experts: Claim Marksmen failed; retry in %s seconds", numericFollowup))
			end
			Main.Experts.timer:set()
		end

		if (Main.Experts.dawnEnabled) then
			if not (Main.Experts.dawnTimer) then Main.Experts.dawnTimer = Timer() end
			local interval = Main.Experts.dawnInterval or 0
			if interval <= 0 then
				interval = getNextDawnAcademyCooldown()
				Main.Experts.dawnInterval = interval
			end
			if not (Main.Experts.dawnCooldown and Main.Experts.dawnCooldown >= 0) then
				Main.Experts.dawnCooldown = interval
			end
			local dawnDue = Main.Experts.dawnTimer:check() >= Main.Experts.dawnCooldown
			if (Main.Experts.dawnNeedsImmediateCheck) then
				Logger("Experts: forcing Dawn Academy run to validate trek claim state")
			end
			if (Main.Experts.dawnNeedsImmediateCheck) or dawnDue then
				Logger("Experts: executing Dawn Academy")
				Main.Experts.dawnNeedsImmediateCheck = false
				local success, followup = Dawn_Academy()
				local nextCooldown = Main.Experts.dawnInterval or getNextDawnAcademyCooldown()
				if (success == false) then
					Logger("Experts: Dawn Academy encountered an issue; retrying after interval")
					expertsLogMessage("Experts: Dawn Academy encountered an issue; retrying after interval")
				end
				Main.Experts.dawnCooldown = nextCooldown
				Main.Experts.dawnTimer:set()
				if (Main.Experts.dawnInterval and Main.Experts.dawnInterval > 0) then
					local nextMinutes = math.floor((nextCooldown or 0) / 60)
					local logMsg = string.format("Experts: next Dawn Academy run in %d minutes", nextMinutes)
					Logger(logMsg)
					expertsLogMessage(logMsg)
				else
					local logMsg = string.format("Experts: next Dawn Academy run at %s UTC", formatUTCRelative(nextCooldown))
					Logger(logMsg)
					expertsLogMessage(logMsg)
				end
			end
		end

	if (Main.Experts.enlistEnabled) and (Main.Experts.enlistPending) then
		if not (Main.Experts.enlistTimer) then Main.Experts.enlistTimer = Timer() end
		local enlistCooldown = Main.Experts.enlistCooldown or 0
		if (Main.Experts.enlistTimer:check() >= enlistCooldown) then
			Logger("Experts: executing Enlistment claim")
			local success = Run_Experts_Enlistment_Claim()
				if (success) then
					local today = os.date("%Y-%m-%d")
					Enlistment_Claim_Date = today
					preferencePutString("expertsEnlistmentDate", today)
					Main.Experts.enlistPending = false
					Main.Experts.enlistCooldown = 0
					Main.Experts.enlistTimer:set()
					Logger("Experts: Enlistment claim completed")
				else
					local retry = 600
					Main.Experts.enlistCooldown = retry
					Main.Experts.enlistTimer:set()
					Logger(string.format("Experts: Enlistment claim failed; retry in %s seconds", retry))
				end
			end
		end
	end
	
	if (Recruit_Heroes) and (Main.Recruit_Heroes.timer:check() > Main.Recruit_Heroes.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainRecruitHeroes", "NA") == Current_Date)) then
		Main.Recruit_Heroes.cooldown = Recruiting_Heroes()
		Main.Recruit_Heroes.timer:set()	
		if (Main.Recruit_Heroes.cooldown >= Get_Time_Difference()) then 
			preferencePutString("mainRecruitHeroes", Current_Date)
		end
	end
	if (Online_Rewards) and (Main.Claim_Rewards.timer:check() > Main.Claim_Rewards.cooldown) and (SearchImageNew("City.png", Lower_Right, .9, true).name) then
		Main.Claim_Rewards.cooldown = Claim_Rewards(Main.Claim_Rewards.timer)
		Main.Claim_Rewards.timer:set()
	end
	
	if (Pet_Adventure) and (Main.Pet_Adventure.timer:check() > Main.Pet_Adventure.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainPetAdventure", "NA") == Current_Date)) then
		Main.Pet_Adventure.cooldown = Pet_Adventure_Event()
		Main.Pet_Adventure.timer:set()
		if not(Main.Pet_Adventure.treasure_spots) and not(Main.Pet_Adventure.ally_treasure) then 
			preferencePutString("mainPetAdventure", Current_Date)
		end
	end
	
	if (Chief_Order) and (Main.Chief_Order_Event.timer:check() > Main.Chief_Order_Event.cooldown) then
		Main.Chief_Order_Event.cooldown = Chief_Order_Store()
		Main.Chief_Order_Event.timer:set()
	end
	
	-------------------------------------- SHOP ----------------------------------------
	if (Auto_Nomadic_Merchant) and (Main.Nomadic_Merchant.timer:check() > Main.Nomadic_Merchant.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainNomadicMerchant", "NA") == Current_Date)) then
		Main.Nomadic_Merchant.cooldown = Nomadic_Merchant()
		Main.Nomadic_Merchant.timer:set()
		preferencePutString("mainNomadicMerchant", Current_Date)
	end
	
	-------------------------------------- ARENA ----------------------------------------
	if (Auto_Arena) and (Main.Arena.timer:check() > Main.Arena.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainArena", "NA") == Current_Date)) then
		Main.Arena.cooldown = Arena(mainArenaGems)
		Main.Arena.timer:set()
		preferencePutString("mainArena", Current_Date)
	end
	
	if (Enable_War_Academy) and (Main.War_Academy.timer:check() > Main.War_Academy.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainWarAcademy", "NA") == Current_Date)) then
		Main.War_Academy.cooldown = War_Academy_Fn(WARedeemTotal)
		Main.War_Academy.timer:set()
		preferencePutString("mainWarAcademy", Current_Date)
	end
	
	if (Enable_The_Labyrinth) and (Main.The_Labyrinth.timer:check() > Main.The_Labyrinth.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainTheLabyrinth", "NA") == Current_Date)) then
		Main.The_Labyrinth.cooldown = theLabyrinth()
		Main.The_Labyrinth.timer:set()
	end
	
	if (Enable_Crystal_Laboratory) and (Main.Crystal_Laboratory.timer:check() > Main.Crystal_Laboratory.cooldown) and ((ignorePersistence) or not(preferenceGetString("mainCrystalLaboratory", "NA") == Current_Date)) then
		Main.Crystal_Laboratory.cooldown = Crystal_Laboratory_Fn()
		Main.Crystal_Laboratory.timer:set()
		preferencePutString("mainCrystalLaboratory", Current_Date)
	end

	if (Main.Hero_Mission.enabled) and (Main.Hero_Mission.timer:check() > Main.Hero_Mission.cooldown) then
		Main.Hero_Mission.cooldown = heroMission()
		if (Main.Hero_Mission.timer) then Main.Hero_Mission.timer:set() end
	end

	if (Main.mercPrestige.enabled) and (Main.mercPrestige.timer:check() > Main.mercPrestige.cooldown) then
		Main.mercPrestige.cooldown = mercPrestige()
		if (Main.mercPrestige.timer) then Main.mercPrestige.timer:set() end
	end
	
	if (Enable_Volume_Control) then
		if (isVolumeUp()) then Volume_Commands(Volume_UP_Command) end
		if (isVolumeDown()) then Volume_Commands(Volume_DOWN_Command) end
	end
	
	if (Barney_Enabled) and (Main.Barney.timer:check() > Main.Barney.cooldown) then
		Change_Char("Alt")
		return "Completed"
	end	
	
	--if (Barney_Enabled) and (Alt_Events.Alt_Bear) and not(altBearLastRun == altBearNextRun) and (Main.Barney.bear_timer:check() >= Main.Barney.bear_cooldown) then -- add another boolean if still does not work
	if (Barney_Enabled) and (Alt_Events.Alt_Bear) and (Main.Barney.bear_timer:check() >= Main.Barney.bear_cooldown) then -- add another boolean if still does not work
		Logger("Last: " ..altBearLastRun.. " | Next: " ..altBearNextRun)
		Logger("Changing Char for Bear Event")
		Change_Char("Alt_Bear")
		return "Completed"
	end

	if not(getUserID() == "") and (os.time() > Garbage_Cool_Down) then
		Logger("Trying to clear memory")
		collectgarbage()
		Logger("Refreshing Memory")
		wait(5)		
		Garbage_Cool_Down = os.time() + 600
	end
	
	return "Completed"
end

function getResetTime()
    local now = os.time()
    local localTime = os.date("*t", now)
    local utcTime = os.date("!*t", now)
    local offset = (localTime.hour - utcTime.hour) + (localTime.min - utcTime.min) / 60
    if localTime.day > utcTime.day then offset = offset + 24
    elseif localTime.day < utcTime.day then offset = offset - 24 end
    Reset_Time = string.format("%02d:%02d:%02d", offset, 0, 0)
    return Reset_Time
end

function ScreenSizeChecker()
	if not(screen.x == 720 and screen.y == 1520) then
		dialogInit()
		addTextView(string.format("Your Current Resolution is %sx%s", screen.x, screen.y))
		newRow()
		addTextView("The required Resolution is 720x1520 DPI 240")
		newRow()
		addTextView("Press OK to continue running the script, but note that there may be issues.")
		dialogShowFullScreen("Alert!")
	end
end

function RunScript(version)
	if not(folderExists("image")) then
		scriptExit("Image Folder is Unavailable!\nPlease redownload all files to run script properly.")
	end
	
	ScreenSizeChecker()

	getResetTime()
	Pack_Sale_Dir = scandirNew("Pack Sale")
	if (table.getn(Pack_Sale_Dir) > 0) then for i, pack in ipairs(Pack_Sale_Dir) do table.insert(Pack_Sale_List, "Pack Sale/"..pack) end end
	User_ID = getUserID()
	Main_GUI(version)
	Main.Experts.enabled, Main.Experts.request = false, false
	Main.Experts.dawnEnabled, Main.Experts.dawnTimer, Main.Experts.dawnCooldown = false, nil, 0
	Main.Experts.dawnInterval = 0
	Main.Experts.enlistEnabled, Main.Experts.enlistPending = false, false
	Main.Experts.enlistTimer, Main.Experts.enlistCooldown = nil, 0
	if (Enable_Experts) then Experts_GUI() end
	
	if (Send_Report_GUI) then Report_Sender() end
	
	if (Map_Options) then Maps_Options_GUI() end
	
	if (Auto_Attack) then
		AutoAttack_GUI()
		if (Attack_Type == "Beasts") then Req_Lv = Beasts_Req_Lv
		elseif (Attack_Type == "Polar Terror") then Req_Lv = Polar_Req_Lv end
		if (Auto_Merc_Prestige) then Mercenary_Prestige_GUI() end
	end
	if (Auto_Intel) then
		Intel_Options_GUI()
		if not(Auto_Attack) then 
			AutoAttack_GUI()
			if (Attack_Type == "Beasts") then Req_Lv = Beasts_Req_Lv
			elseif (Attack_Type == "Polar Terror") then Req_Lv = Polar_Req_Lv end
			if (Auto_Merc_Prestige) then Mercenary_Prestige_GUI() end
		end
	end 
	
	Start_Time = os.time()
	local Label
	if ((Enable_Logs) or (Enable_Label)) and not(Label_Region) then
		Label = SearchImageNew("VIP.png")
		if (Label.name) then Label_Region = Region(0, Label.y + Label.h, screen.x, 40) 
		else Label_Region = Region(0, 89, screen.x, 40) end
	end
	if (AM_Enabled) then Alliance_Mobilization_GUI() end
	if (City_Events) then CityEvents_GUI() end
	if (Enable_Bear_Event) then Bear_Hunting_GUI() end
	if (Chief_Order) then Chief_Order_GUI() end	
	if (Auto_Gather) then
		if (Auto_Gather_Option == 1) then RSS_GUI1() 
		else RSS_GUI2() end
		RSS_GUI_Settings()
	end
	if (Auto_Nomadic_Merchant) and (Discounted == "Select") then Nomadic_Merchant_GUI() end
	if (Barney_Enabled) then ALT_GUI() end
	if not(Auto_Gather) and (altRssGather) then
		if (Auto_Gather_Option == 1) then RSS_GUI1() 
		else RSS_GUI2() end
		RSS_GUI_Settings()
	end
	if (Auto_Gather) then RSS_Stats_Checker("1") end
	if (Enable_Volume_Control) then setVolumeDetect(true) end
	if (getUserID() ~= "") then 
		Logger("Script Started - P")
		Message.Game_Name = "WhiteOut Survival P"
	else Logger("Script Started - T") end
	local Restart_Counter, Iteration = 0, 0
	-------------------- Start Loop ----------------------
	Logger("Setting up timer")
	Timer_Setup()
	primeMainTaskTimers()
	Logger("Starting")
	if (getUserID() == "zombrox@pm.me") then CHARACTER_ACCOUNT = forceUse end

	while true do
		Message.Total_Time = Get_Time2(os.time() - Start_Time)
		setStopMessage(printMessage(Message, keyOrder))

		local success, result
		if (CHARACTER_ACCOUNT == "Main") then success, result = xpcall(function() return StartBot(User_ID) end, debug.traceback)
		elseif (CHARACTER_ACCOUNT == "Alt_Bear") then success, result = xpcall(function() return Barney_Specifics_AM("Bear") end, debug.traceback)
		else success, result = xpcall(function() return Barney_Specifics_AM("Default") end, debug.traceback) end
		if (success) then
			File_Writer("Error Screenshot/Logs", txtLogs)
			txtLogs = ""
			Logger()
			wait((StartAPP_Timer2) and .5 or Repeat_Delay)
			Iteration = Iteration + 1
			if Main.forceInitialSweep then
				Main.forceInitialSweep = false
			end
			if not(repeatCount == "00") then
				if (Iteration >= tonumber(repeatCount)) then
					Message.Total_Time = Get_Time2(os.time() - Start_Time)
					setStopMessage(printMessage(Message, keyOrder))
					scriptExit("Max Repetitions Reached")
				end
			end
		else
			Message.Total_Error = Message.Total_Error + 1
			Logger()
			if (auto_restart) then
				local errMsg, Task = Error_Msg
				File_Writer("Error Screenshot/Logs", txtLogs)
				txtLogs = ""
				if string.find(result, "Abort") then Task = "Abort" -- Manual Stop
				elseif string.find(result, "Timeout Error:") then  -- Forced Stop
					File_Writer("Error Screenshot/Error Logs", string.format("[%s] - %s\n[Error Message:] %s\n[Traceback:] %s\nTrace Back End\n", os.date("%Y-%m-%d %H:%M:%S"), Current_Function, errMsg, result))
					Message.Total_Restart = Message.Total_Restart + 1
					Logger("Restarting")
					wait(2)
					snapshotColor()
					local Alliance_Screen = SearchImageNew({"Alliance.png", "Reconnect.png"}, nil, 0.8, true)
					local checkHomesScreen = SingleImageWait("Home Screen.png", 0, Home_Screen_Region, 0.9, true)
					usePreviousSnap(false)
					if not(checkHomesScreen) and (not(Alliance_Screen.name) or (Alliance_Screen.name == "Alliance")) then Go_Back2() end
					if ((Enable_My_Island) or (Alt_Events.Alt_My_Island)) and (SingleImageWait("Island Storehouse.png", 0, Lower_Left, 0.9, true)) then myIslandGoBack() end		
				else   -- Error Bugs
					Capture_Screenshot()
					Task = "Break"
				end
				if (Task == "Break") then
					File_Writer("Error Screenshot/Error Logs", string.format("[%s] - %s\n[Error Message:] %s\n[Traceback:] %s\nTrace Back End\n", os.date("%Y-%m-%d %H:%M:%S"), Current_Function, errMsg, result))
					Message.Total_Time = Get_Time2(os.time() - Start_Time)
					setStopMessage(printMessage(Message, keyOrder))
					scriptExit(string.format("%s\n%s", "image/Error Screenshot/", "Script Error! Please Check Error Logs!!!"))
				elseif (Task == "Abort") then
					Message.Total_Error = Message.Total_Error - 1
					Message.Total_Time = Get_Time2(os.time() - Start_Time)
					setStopMessage(printMessage(Message, keyOrder))
					if (Message.Total_Error > 0) then scriptExit(string.format("%s\n%s", "Error Found Please Check Error Logs", "image/Error Screenshot/"))
					else 
						Logger("User Abort!")
						File_Writer("Error Screenshot/Logs", txtLogs)
						txtLogs = ""
						scriptExit("User Abort")
					end
				end
			else
				Message.Total_Time = Get_Time2(os.time() - Start_Time)
				setStopMessage(printMessage(Message, keyOrder))
				if string.find(result, "Abort") then
					Logger("User Abort!")
					File_Writer("Error Screenshot/Logs", txtLogs)
					txtLogs = ""
					scriptExit("User Abort") 
				end
				File_Writer("Error Screenshot/Logs", txtLogs)
				txtLogs = ""
				scriptExit(string.format("%s\n%s", "image/Error Screenshot/", result))
				------------- DEBUG PURPOSE --------------------
			end
		end
		Message.Total_Time = Get_Time2(os.time() - Start_Time)
		setStopMessage(printMessage(Message, keyOrder))
	end
	-------------------- End Loop ----------------------
	Logger("Closing Script!")
	File_Writer("Error Screenshot/Logs", txtLogs)
	txtLogs = ""
	scriptExit()
end

function scriptExit(message)
	if message then
		print(message)
	end
	os.exit()
end

function luckyPouch()
	local LPDir = "Lucky Pouch/"
	if (SingleImageWait(LPDir.. "Lucky Pouch.png", 0, Lower_Half, 0.9, true)) then
		PressRepeatHexColor(Location(610, 1380), Location(682, 39), "#CFF4F5", 5, 3)
		while true do
			local luckyPouchChat = SingleImageWait(LPDir.. "Lucky Pouch.png", 0, Upper_Half, 0.9, true)
			if (luckyPouchChat) then
				Press(luckyPouchChat, 1)
				sleep(1)
				local LPTimer = SingleImageWait(LPDir.. "Lucky Pouch Timer.png", 2, Upper_Half, 0.9, true)
				if (LPTimer) then
					PressRepeatNew(LPTimer, LPDir.. "Lucky Pouch Reward.png", 1, 3)
					PressRepeatHexColor(Location(320, 30), Location(682, 39), "#CFF4F5", 5, 1)
				end
			else break end
		end
		Go_Back("Lucky Pouch Claimed?")
	end
end
--luckyPouch()
RunScript("v25.10.26")
scriptExit()

-- EOF
