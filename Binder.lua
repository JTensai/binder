--Global Variables
ProfileName_OnButton = "";
Currently_Selected_Profile_Num = 0;
Selection = false;
Current_Specialization = 0;

Binder_Settings = {
	ProfilesCreated = 0;
	Profiles = {};
}

BinderMinimapSettings = {
	ShowMinimapButton = true;
	MinimapRadioOption = 1;
	xposition = 300;
	yposition = 0; -- default position of the minimap icon
	degree = -12;
}


--This appears in your chat frame
local function out_frame(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

--This appears on the top of your screen
local function out(text)
	UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end

function Binder_Debug(strName, tData) 
	if ViragDevTool_AddData and false then
		ViragDevTool_AddData(tData, strName)
    end
end

function Binder_OnLoad(self)
	out_frame("Binder is Loaded. Use /binder for help");
	self:RegisterEvent( "ADDON_LOADED" );
	self:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED" );

	SLASH_BINDER1 = "/binder";
	SlashCmdList["BINDER"] = function (cmd, editbox)
		local command, rest = cmd:match("^(%S*)%s*(.-)$");
		if command == "load" and rest ~= "" then
			Load_Profile(rest);
		elseif command == "toggle" then
			Binder_Toggle();
		elseif command == "info" then
			out_frame("Created by: Tensai");
			out_frame("Last updated: 9/21/2020")
			out_frame("Supports storing profiles of keybinds upto 2 keys per action.")
		else
			out_frame("Syntax for Binder slash commands:");
			out_frame("  - /binder toggle - Toggles main binder window");
			out_frame("  - /binder load (name) - Loads profile 'name', case sensitive");
		end
	end
end

function Binder_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		Binder_MinimapButton_OnLoad();
		Minimap_Options_WhenLoaded();
	elseif ( event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		local currentSpec = GetSpecialization()
		if Current_Specialization ~= currentSpec then
			local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
			out_frame("Specialization changed to: " .. currentSpecName)
			Current_Specialization = currentSpec
			Load_Profile(currentSpecName)
		end
	end
end

	
function Binder_Toggle()
	-- local frame = getglobal("Binder_Frame")
	Selection = false;
	-- if (frame) then
		if (  Binder_Frame:IsVisible()  ) then
			--When the Frame Goes away
			Binder_Frame:Hide();
			Binder_Title:Hide();
			Description_InputBox:Hide();
			Name_Input_Frame:Hide();
			ApplyOrDelete_Frame:Hide();
			Description_Frame:Hide();
			Selection_Frame:Hide();
			Loading_Frame:Hide();
			Options_Frame:Hide();
			Creation_Frame:Hide();
			Description_Input_Frame:Hide();
			Divider_Frame1:Hide();
			Divider_Frame2:Hide();
			Name_InputBox:SetText("");
			Description_InputBox:SetText("");
		else
			--When the Frame is Shown again
			Binder_Frame:Show();
			Binder_Title:Show();
			Name_Input_Frame:Show();
			Description_InputBox:Show();
			ApplyOrDelete_Frame:Show();
			Description_Frame:Show();
			Selection_Frame:Show();
			Loading_Frame:Show();
			Options_Frame:Show();
			Creation_Frame:Show();
			Description_Input_Frame:Show();
			Divider_Frame1:Show();
			Divider_Frame2:Show();
			Name_InputBox:SetText("");
			Description_InputBox:SetText("");
			BinderEntry1:UnlockHighlight();
			BinderEntry2:UnlockHighlight();
			BinderEntry3:UnlockHighlight();
			BinderEntry4:UnlockHighlight();
			BinderEntry5:UnlockHighlight();
		end
	-- end
end


--The Scrolling Frame
function BinderScrollBar_Update()

	local line; 
	local lineplusoffset;
	FauxScrollFrame_Update(BinderScrollBar,Binder_Settings.ProfilesCreated,5,19);
	for line = 1, 5 do 
		lineplusoffset = line + FauxScrollFrame_GetOffset(BinderScrollBar);
		if ( lineplusoffset < (Binder_Settings.ProfilesCreated + 1) ) then
			getglobal("BinderEntry"..line):SetText(Binder_Settings.Profiles[lineplusoffset].Name);
			getglobal("BinderEntry"..line):Show();
		else
			getglobal("BinderEntry"..line):Hide();
		end
	end
	
	if (Currently_Selected_Profile_Num == 0)then
	else
		if (BinderEntry1:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry1:LockHighlight()
			else
			BinderEntry1:UnlockHighlight();
		end
		
		if (BinderEntry2:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry2:LockHighlight()
			else
			BinderEntry2:UnlockHighlight();
		end
		
		if (BinderEntry3:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry3:LockHighlight()
			else
			BinderEntry3:UnlockHighlight();
		end
			
		if (BinderEntry4:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry4:LockHighlight()
			else
			BinderEntry4:UnlockHighlight();
		end
			
		if (BinderEntry5:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry5:LockHighlight()
			else
			BinderEntry5:UnlockHighlight();
		end
	end
end

--When you click on a profile
function ProfileSelection_OnClick(self)
	ProfileName_OnButton = self:GetText()
	
	--Sets Currently_Selected_Profile_Num to the profile number on button you pushed
	for i = 1, Binder_Settings.ProfilesCreated do 
		if ( ProfileName_OnButton ~= Binder_Settings.Profiles[i].Name )then
		end
		if ( ProfileName_OnButton == Binder_Settings.Profiles[i].Name )then
			Currently_Selected_Profile_Num = i
		end
	end
	Description_Update(Currently_Selected_Profile_Num)
	Selection = true
	
	BinderScrollBar_Update()	
end
	
function Description_Update(profilenum)
	if (profilenum == nil)then
	else
		Description_Frame_Text2:SetText(Binder_Settings.Profiles[profilenum].Description)
	end
end

----------------------------------------------------------------------

function Create_Button_OnUpdate()	
	if (Name_InputBox:GetText() == "") then
		Create_Button:Disable()
	else
		Create_Button:Enable()
	end
end

--creation on hover stuff
function Binder_CreateButton_Details(tt, ldb)
	tt:SetText("This will create a new Keybind Profile with|nthe inputed name using your current Keybinds.|n(Description is optional)")
end

function Binder_CreateButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_CreateButton_Details(GameTooltip)
end

function SaveCurrentBindsToProfile(profile_number)
	Binder_Settings.Profiles[profile_number].The_Binds = {}
	for i = 1, GetNumBindings() do
		-- Binder_Settings.Profiles[profile_number].The_Binds[i] = {["TheAction"] = select(1, GetBinding(i))}

		-- At some point blizzard modified how they display Keybinds to players to modify them. They added KeyBindingHeaders
		-- so that the keybind list would be more manageable. They apparently modified how GetBinding() works, it now
		-- returns TheAction(1) TheHeader(2) and all the keybinds(3 to n). This broke the system I was using which required
		-- TheAction(1), Bind1(2), Bind2(3). This caused errors for many players who seemingly had their keybinds just disappear.
		-- I now loop over all keybinds and store them, instead of just the first 2.

		-- We start from (j=2) here so we skip the action for the binds. We could start from (j=3) and skip the
		-- "KeyBindingHeader", but some keybinds don't have a header, and starting at 3 would skip the first bind.
		-- So we will just let it silently fail when we try to later set a keybind to a keybind header.

		-- for j = 2, select("#", GetBinding(i)) do
		-- 	Binder_Settings.Profiles[profile_number].The_Binds[i]["Binding"..j-1] = select(j, GetBinding(i))
		-- end

		-- This is the new and updated way (9/21/2020)
		-- loading profile has version detection now so we can always create using the new format
		local action = GetBinding(i)
		Binder_Settings.Profiles[profile_number].The_Binds[action] = {}

		for _, binding in pairs(Extract_Bindings(GetBinding(i))) do
			table.insert(Binder_Settings.Profiles[profile_number].The_Binds[action], binding)
		end
	end
	Binder_Debug("The_Binds", Binder_Settings.Profiles[profile_number].The_Binds)
end

--The Almighty Button that WILL create your new profile
function Create_OnClick(arg1)
	
	local exists = false;
	
	for i = 1, Binder_Settings.ProfilesCreated do 
		namecheck = Binder_Settings.Profiles[i].Name
		if (Name_InputBox:GetText() == namecheck) then
			exists = true
			out_frame("Profile '"..Binder_Settings.Profiles[i].Name.."' not created because it already exists.")
			out("Profile '"..Binder_Settings.Profiles[i].Name.."' not created because it already exists.")
			Name_InputBox:SetText("")
		end
	end
	
	if (exists == true)then
	else
		local NewProfileNum = Binder_Settings.ProfilesCreated +1;
		Binder_Settings.Profiles[NewProfileNum] = { Name = Name_InputBox:GetText(), Description = Description_InputBox:GetText(), The_Binds = {} }
							
		
		--Updates the number of profiles created
		Binder_Settings.ProfilesCreated = Binder_Settings.ProfilesCreated + 1
	
		SaveCurrentBindsToProfile(Binder_Settings.ProfilesCreated)
		
													
		out_frame("Binder Profile Created: " .. Name_InputBox:GetText()) 
		out("Profile Created: "..Binder_Settings.Profiles[Binder_Settings.ProfilesCreated].Name)
			
		--If something is written in the Description box when saved, this shows in the chat screen
		if (Description_InputBox:GetText() ~= "") then
			out_frame("Description: " .. Description_InputBox:GetText())
		end

		Name_InputBox:SetText("");
		Description_InputBox:SetText("");
			
		BinderScrollBar_Update()
	end
	Name_InputBox:ClearFocus()
	SaveBindings(2)
end

-- Minimap coding

function Binder_MinimapButton_OnLoad()
	if not BinderMinimapSettings.degree then
		out_frame("degree is broken :(")
		BinderMinimapSettings.degree = -12
	end

	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		Binder_MinimapButton:SetPoint("CENTER", "UIParent", "CENTER",BinderMinimapSettings.xposition,BinderMinimapSettings.yposition)
	elseif (BinderMinimapSettings.MinimapRadioOption == 2) then
		Binder_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-(80*cos(BinderMinimapSettings.degree)), (80*sin(BinderMinimapSettings.degree))-52 )
	end
end

function Binder_MinimapButton_Reposition()
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		local xlim = (GetScreenWidth()/2)
		local ylim = (GetScreenHeight()/2)
		
		if ( BinderMinimapSettings.xposition > xlim) then
			BinderMinimapSettings.xposition = xlim
			end
		if ( BinderMinimapSettings.xposition < (-1) * xlim) then
			BinderMinimapSettings.xposition = (-1) * xlim
			end
		if ( BinderMinimapSettings.yposition > ylim) then
			BinderMinimapSettings.yposition = ylim
			end
		if ( BinderMinimapSettings.yposition < (-1) * ylim) then
			BinderMinimapSettings.yposition = (-1) * ylim
			end
		
		Binder_MinimapButton:SetPoint("CENTER", "UIParent", "CENTER", BinderMinimapSettings.xposition, BinderMinimapSettings.yposition)
	else
		Binder_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-(80*cos(BinderMinimapSettings.degree)),(80*sin(BinderMinimapSettings.degree))-52)
	end
end

function Binder_MinimapButton_DraggingFrame_OnUpdate()
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		local xcursor, ycursor = GetCursorPosition()

		local xpos = (xcursor/UIParent:GetEffectiveScale()) - (GetScreenWidth()/2);
		local ypos = (ycursor/UIParent:GetEffectiveScale()) - (GetScreenHeight()/2);
		
		BinderMinimapSettings.xposition = xpos
		BinderMinimapSettings.yposition = ypos
		Binder_MinimapButton_Reposition() 
	else
		local xpos,ypos = GetCursorPosition()
		local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

		xpos = xmin-xpos/UIParent:GetScale()+70
		ypos = ypos/UIParent:GetScale()-ymin-70

		BinderMinimapSettings.degree = math.deg(math.atan2(ypos,xpos))
		Binder_MinimapButton_Reposition() 
	end	
end

function Binder_MinimapButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_LEFT")
	Binder_MinimapButton_Details(GameTooltip)
end

function Binder_MinimapButton_Details(tt, ldb)
	tt:SetText("Binder|n|nLeft Click: Open Frame|nRight Click: Drag)")
end

function Minimap_Reset(arg1)
	BinderMinimapSettings.xposition = 0
	BinderMinimapSettings.yposition = 0
	BinderMinimapSettings.degree = 30
	Binder_MinimapButton_Reposition()
end

function Minimap_Reset_Details(tt, ldb)
	tt:SetText("Will reset the position of the|nminimap button to center screen")
end

function Minimap_Reset_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Minimap_Reset_Details(GameTooltip)
end


function Minimap_Options_WhenLoaded()
	if (BinderMinimapSettings.ShowMinimapButton == true) then
		Minimap_CheckButton1:SetChecked(true)
	else
		Minimap_CheckButton1:SetChecked(false)
	end
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		Options_Frame_RadioButton1:SetChecked(true)
	else
		Options_Frame_RadioButton2:SetChecked(true)
	end

	Minimap_Options_OnUpdate()
end

function Minimap_Options_OnUpdate()
	-- Show Minimap Button
	if (Minimap_CheckButton1:GetChecked() == true) then
		BinderMinimapSettings.ShowMinimapButton = true
		Binder_MinimapButton:Show()
		Options_Frame_RadioButton1:Enable()
		Options_Frame_RadioButton1:SetAlpha(1)
		Options_Frame_RadioButton2:Enable()
		Options_Frame_RadioButton2:SetAlpha(1)
	else
	-- Hide Minimap Button
		BinderMinimapSettings.ShowMinimapButton = false
		Binder_MinimapButton:Hide()
		Options_Frame_RadioButton1:Disable()
		Options_Frame_RadioButton1:SetAlpha(.4)
		Options_Frame_RadioButton2:Disable()
		Options_Frame_RadioButton2:SetAlpha(.4)
	end

	-- 
	if (Options_Frame_RadioButton1:GetChecked() == true) then
		BinderMinimapSettings.MinimapRadioOption = 1
	else
		BinderMinimapSettings.MinimapRadioOption = 2
	end
end

--Stuff for the Apply Button

function Defaults_OnClick(arg1)
	LoadBindings(0)
	SaveBindings(2)
end

function Apply_OnClick()
	Load_Profile(ProfileName_OnButton);
end

-- This function will pull out and return only the actual bindings for a GetBinding() call
function Extract_Bindings(command, category, ...)
	-- GetBinding() returns multiple strings, this function allows us to extract all the keybinds for each action
	-- local cmdName = _G["BINDING_NAME_" .. command]
	-- local catName = _G[category]
	-- Binder_Debug(("%s > %s (%s) is bound to:"):format(catName or "?", cmdName or "?", command), strjoin(", ", ...))
	return {...}
end

function RemoveAllBinds()
	for i = 1, GetNumBindings() do
		for _, binding in pairs(Extract_Bindings(GetBinding(i))) do
			-- setting the binding with no key given will clear the binding
			SetBinding(binding)
		end
	end
end

function Load_Profile(profile_name)
	Profile_Num = nil;
	for i = 1, Binder_Settings.ProfilesCreated do
		if ( profile_name == Binder_Settings.Profiles[i].Name )then
			Profile_Num = i;
			break;
		end
	end
	
	if (Profile_Num == nil)then
		out_frame("Binder Profile '"..profile_name.."' not found.")
	else
		RemoveAllBinds();
		
		-- https://wow.gamepedia.com/API_SetBinding
		-- The Key Bindings UI will only show the first two bindings, but there is no limit to the number of keys that can be used for the same command.

		-- This is a simple data version detection system. If the old data is detected it will use the old system to load it and update to the new system
		if Binder_Settings.Profiles[Profile_Num].The_Binds[1] ~= nil then
			Binder_Debug("Keybind strorage version", 1.0)
			-- loop over all the actions and associated binds
			for _, action_and_bindings in pairs(Binder_Settings.Profiles[Profile_Num].The_Binds) do
				-- loop over each bind assigned to this action
				local action = action_and_bindings.TheAction
				for i, binding in pairs(action_and_bindings) do
					-- skip over the action
					if (i ~= 1)	then
						-- The binds sometimes also contain the useless header
						-- we just try to add that header as a keybind and it should fail silently.
						SetBinding(binding, action)
					end
				end
			end
			-- when a v1.0 data structure is loaded, convert it to a v2.0 data structure
			SaveCurrentBindsToProfile(Profile_Num)
		else
			-- This is the more modernized appraoch to data storage
			Binder_Debug("Keybind strorage version", 2.0)
			for action, bindings in pairs(Binder_Settings.Profiles[Profile_Num].The_Binds) do
				for _, binding in pairs(bindings) do
					SetBinding(binding, action)
				end
			end
		end

	 
		SaveBindings(2)
		LoadBindings(2)
		out_frame("Binder Profile "..profile_name.." has been loaded")
	end
end


function Apply_Button_OnUpdate()
	
	if (Selection == false) then
		Apply_Button:Disable()
		end
	if (Selection == true) then
		Apply_Button:Enable()
		end
end

function Binder_ApplyButton_Details(tt, ldb)
	tt:SetText("This Button will Apply|nthe currently selected|nBinder profile")
end

function Binder_ApplyButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_ApplyButton_Details(GameTooltip)
end

-- Stuff for the Update Button

function Update_Profile()
	SaveCurrentBindsToProfile(Currently_Selected_Profile_Num)
	out("Binder Profile: "..Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name..", has been updated to current Binds.")
	out_frame("Binder Profile: "..Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name..", has been updated to current Binds.")
end

function Update_Button_OnUpdate()
	
	if (Selection == false) then
		Update_Button:Disable()
		end
	if (Selection == true) then
		Update_Button:Enable()
		end
end

function Binder_UpdateButton_Details(tt, ldb)
	tt:SetText("This Button will Update|nthe Bindings of the currently|nselected Binder profile")
end

function Binder_UpdateButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_UpdateButton_Details(GameTooltip)
end

--Stuff for the Delete Button
function Binder_DeleteButton_Details(tt, ldb)
	tt:SetText("WARNING!!! If you delete a|nprofile, you CANNOT get it back|n|nSo be careful...")
end

function Binder_DeleteButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_DeleteButton_Details(GameTooltip)
end


function Delete_OnClick(arg1)
	out_frame("Profile "..ProfileName_OnButton.." was deleted")
	if (Currently_Selected_Profile_Num < Binder_Settings.ProfilesCreated)then
		for i = Currently_Selected_Profile_Num, Binder_Settings.ProfilesCreated-1 do
			Binder_Settings.Profiles[i] = Binder_Settings.Profiles[i + 1]
		end
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
	else
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
 	end
	
	Binder_Settings.ProfilesCreated = Binder_Settings.ProfilesCreated-1
	Currently_Selected_Profile_Num = 0
	Selection = false
	BinderScrollBar_Update()	
end

function Hide_Areyousure()
	Areyousure_Frame:Hide()
	Selection = false
end

function Delete_Button_OnUpdate()
	if (Selection == false) then
		Delete_Button:Disable()
	end
	
	if (Selection == true) then
		Delete_Button:Enable()
	end
end

function DeleteAll_Button_OnClick()
	for i = 1, Binder_Settings.ProfilesCreated do
		Binder_Settings.Profiles[i] = nil
	end
	Currently_Selected_Profile_Num = 0
	Binder_Settings.ProfilesCreated = 0
	BinderScrollBar_Update()
	out_frame("All profiles are erased.")
end

function DeleteAll_Button_OnUpdate()
	
	if (Currently_Selected_Profile_Num == 0)then
	else
		if (Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name == "Delete All") then
			DeleteAll_Button:Enable()
			
		else 
			DeleteAll_Button:Disable()
		end
	end
end

function Close_Button_Details(tt, ldb)
	tt:SetText("Close")
end

function Close_Button_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Close_Button_Details(GameTooltip)
end