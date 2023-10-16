local theme = NewDawnLibrary.Colors
local scrW = ScrW()
local scrH = ScrH()

local SCREEN_WIDTH = 1920
local SCREEN_HEIGHT = 1080

local scaledX = scrW / SCREEN_WIDTH
local scaledY = scrH / SCREEN_HEIGHT

local compassPoints = {
    [0] = "N",
    [15] = "15",
    [30] = "30",
    [45] = "NE",
    [60] = "60",
    [75] = "75",
    [90] = "E",
    [105] = "105",
    [120] = "120",
    [135] = "SE",
    [150] = "150",
    [165] = "165",
    [180] = "S",
    [195] = "195",
    [210] = "210",
    [225] = "SW",
    [240] = "240 ",
    [255] = "255",
    [270] = "W",
    [285] = "285",
    [300] = "300",
    [315] = "NW",
    [330] = "330",
    [345] = "345",
    [360] = "N",
}

local armorIcon = Material("nd_hudicons/armorshield.png", "noclamp smooth mips")
local outerSquadIcon = Material("nd_hudicons/squad_icon.png", "noclamp smooth mips")

local disabledElements = {
    ["CHudHealth"] = true,
    ["CHudAmmo"] = true,
    ["CHudBattery"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "ND.DisableHudElements", function(element)
    if (disabledElements[element]) then
        return false
    end
end)

hook.Add("OnScreenSizeChanged", "ND.OnScreenSizeChanged", function(oldWidth, oldHeight)
    scrW = ScrW()
    scrH = ScrH()
    scaledX = scrW / 1920
    scaledY = scrH / 1080
    NewDawnLibrary.Debug("ND.OnScreenSizeChanged", "Screen size changed - updating screen values")
end)

local function drawPlayerInformation()
    -- Get the local player
    local ply = LocalPlayer()

    -- Check if the player is valid
    if not IsValid(ply) then
        -- Print a debug message and return if the player is not valid
        NewDawnLibrary.Debug("drawPlayerInformation", "ply is nil - returning")
        return
    end

    -- Get the player's name, health, and armor
    local plyName = ply:Name()
    local plyHealth = ply:Health()
    local plyArmor = ply:Armor()

    -- Draw the player's name in uppercase using a custom font
    draw.SimpleText(string.upper(plyName), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 40 * scaledX), scrW * .02, scrH * .85, theme.transparent_blue, TEXT_ALIGN_LEFT)

    -- Draw the player's role (e.g., "501st Trooper") in uppercase using a custom font
    draw.SimpleText(string.upper("501st Trooper"), NewDawnLibrary.CreateFont("thin", "Montserrat Thin", 36 * scaledX), scrW * .02, scrH * .88, theme.transparent_white, TEXT_ALIGN_LEFT)

    -- Draw an armor icon using a material and set its color
    surface.SetMaterial(armorIcon)
    surface.SetDrawColor(theme.orange)
    surface.DrawTexturedRect(scrW * .02, scrH * .955, 24 * scaledX, 24 * scaledX)

    -- Draw a health bar using a custom function
    NewDawnLibrary.DrawLerpHealthBar(scrW * .02, scrH * .92, scrW * .2, scrH * .02, theme.white, 5, plyHealth, true)

    -- Draw the player's health in text using a custom font
    NewDawnLibrary.DrawLerpHealthText(NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 30 * scaledX), scrW * .225, scrH * .914, theme.white, plyHealth)

    -- Draw a segmented armor bar using a custom function
    NewDawnLibrary.DrawSegmentedArmorBar(scrW * .04, scrH * .96, scrW * .16, scrH * .012, 5, 5, plyArmor)
end


local function drawSquadInformation()
    -- Get the local player
    local ply = LocalPlayer()

    -- Check if the local player is valid
    if not IsValid(ply) then
        -- Debug message and early return if not valid
        NewDawnLibrary.Debug("drawSquadInformation", "ply is nil - returning")
        return
    end

    -- Define padding for circles in Y-axis
    local circlePaddingY = scrH * 0.02

    -- Check if the player is in a squad
    if not ply:GetSquad() then
        return
    end

    -- Get the player's squad
    local squad = ply:GetSquad()

    -- Get the squad's title
    local squadTitle = squad:GetTitle()

    -- Draw the squad title at the specified position
    draw.SimpleText(string.upper(squadTitle), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 52 * scaledX), scrW * 0.06, scrH * 0.01, theme.blue, TEXT_ALIGN_LEFT)

    -- Loop through squad members
    for k, squadMember in SortedPairs(squad:GetMembers()) do
        -- Check if the squad member is valid
        if not IsValid(squadMember) then
            -- Debug message and skip to the next iteration if not valid
            NewDawnLibrary.Debug("drawSquadInformation", "squadMember is nil - skipping")
            continue
        end

        -- Check if the squad member is the squad leader
        local isSquadLeader = squadMember:IsSquadLeader()

        -- Check if the squad owner (player) is alive
        local isSquadOwnerAlive = squad:GetOwner():Alive()

        -- Check if the squad member is alive
        local isSquadMemberAlive = squadMember:Alive()

        if isSquadLeader then
            -- Determine the color for the squad leader's name based on their status
            local leaderColor = isSquadOwnerAlive and theme.orange or theme.transparent_white

            -- Draw the squad leader's name
            draw.SimpleText(string.upper(squad:GetOwner():Name()), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * 0.06, scrH * 0.06, leaderColor, TEXT_ALIGN_LEFT)
        else
            -- Determine the colors for squad members based on their status
            local squadMemberColor = isSquadMemberAlive and theme.white or theme.transparent_white
            local circleColor = isSquadMemberAlive and theme.blue or theme.red

            -- Draw a colored circle next to the squad member's name
            surface.SetDrawColor(circleColor)
            NewDawnLibrary.DrawCircle(scrW * 0.02, scrH * 0.08 + (circlePaddingY * k), 5 * scaledX, 5, true)

            -- Draw the squad member's name
            draw.SimpleText(string.upper(squadMember:Name()), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * 0.025, scrH * 0.07 + (circlePaddingY * k), squadMemberColor, TEXT_ALIGN_LEFT)
        end
    end

    -- Draw an outer squad icon
    surface.SetMaterial(outerSquadIcon)
    surface.SetDrawColor(theme.white)
    surface.DrawTexturedRect(scrW * 0.02, scrH * 0.02, 64 * scaledX, 64 * scaledX)
end


local function drawCompass()
    -- Get the local player
    local ply = LocalPlayer()

    -- Check if the player is valid
    if not IsValid(ply) then
        NewDawnLibrary.Debug("drawCompass", "ply is nil - returning")
        return
    end

    -- Get the player's view angle (yaw)
    local playerYaw = math.Round(ply:EyeAngles().yaw)

    -- Define compass settings
    local compassWidth = scrW * 0.15
    local lineHeight = 2

    -- Loop through compass directions (0 to 360 degrees)
    for angle = 0, 360 do
        -- Calculate the angular difference between the current angle and player's yaw
        local angleDifference = math.AngleDifference(angle, playerYaw)

        -- Check if the direction is within the visible range (within 80 degrees of the player's view)
        if math.abs(angleDifference) < 80 then
            -- Calculate the position of the text and line
            local position = ((angleDifference / 40 * (compassWidth / 5)) * 2) * scaledY
            local textX = scrW / 2 - position
            local textY = scrH - 55
            local lineX = textX - scrW * .01 * scaledX
            local lineY = textY + scrH * .02 * scaledX
            local lineWidth = scrW * .02 * scaledX

            -- Check if the angle is a multiple of 15 degrees
            if (angle % 15 ~= 0) then
                continue -- Skip this iteration
            end

            -- Determine line color & font based on conditions
            local lineColor = theme.white
            local textColor = theme.white
            local textFont = NewDawnLibrary.CreateFont("bold", "Montserrat Bold", 18 * scaledX)

            if angle % 45 == 0 and angle ~= 360 then
                lineColor = theme.blue
                textColor = theme.blue
                textFont = NewDawnLibrary.CreateFont("bold", "Montserrat Bold", 28 * scaledX)
            elseif angle == 360 then
                lineColor = theme.orange
                textColor = theme.orange
                textFont = NewDawnLibrary.CreateFont("bold", "Montserrat Bold", 28 * scaledX)
            end

            -- Draw the compass direction text
            local directionText = compassPoints[360 - angle]
            draw.SimpleText(directionText, textFont, textX, textY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Draw a rounded box (line) below the text with the determined color
            draw.RoundedBox(0, lineX, lineY, lineWidth, lineHeight, lineColor)
        end
    end
end


local function drawCommsInformation()
    -- Get the local player
    local ply = LocalPlayer()

    -- Check if the player is valid
    if not IsValid(ply) then
        return
    end

    -- Set the font for rendering text
    surface.SetFont(NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX))

    -- Prepare text for the voice state
    local voiceText = string.upper("Voice: ")
    local voiceTextW, voiceTextH = surface.GetTextSize(voiceText)

    -- Determine whether the player's voice is active or muted
    local voiceStateText = string.upper(ply:GetComlinkState() == 0 and "Active " or "Muted ")
    local voiceStateTextW, voiceStateTextH = surface.GetTextSize(voiceStateText)

    -- Get information about the active and passive communication channels
    local plyActiveChannel = Comlink.Channels[ply:GetComlinkActive()] or {}
    local plyPassiveChannel1 = Comlink.Channels[ply:GetComlinkPassive1()] or {}
    local plyPassiveChannel2 = Comlink.Channels[ply:GetComlinkPassive2()] or {}

    -- Prepare text for the active channel
    local activeText = string.upper("Active: ")
    local activeTextW, activeTextH = surface.GetTextSize(activeText)

    -- Determine the name of the active communication channel
    local activeChannelText = string.upper(plyActiveChannel.name or "None") .. " "
    local activeChannelTextW, activeChannelTextH = surface.GetTextSize(activeChannelText)

    -- Prepare text for passive channels
    local passiveChannelText = string.upper(((plyPassiveChannel1.name or "None") .. " / " .. (plyPassiveChannel2.name or "None")) .. " ")
    -- local passiveChannelTextW, passiveChannelTextH = surface.GetTextSize(passiveChannelText)

    -- Render voice information
    draw.SimpleText(voiceText, NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98 - (voiceStateTextW + voiceTextW + voiceTextW + 27), scrH * .02, theme.white)
    draw.SimpleText(voiceStateText, NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98 - (voiceStateTextW + voiceTextW + 27), scrH * .02, Comlink.Config.Theme.Indicators[ply:GetComlinkState()])
    draw.SimpleText(string.upper("[Shift + H]"), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98, scrH * .02, theme.white, TEXT_ALIGN_RIGHT)

    -- Render active channel information
    draw.SimpleText(activeText, NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98 - (activeChannelTextW + activeTextW + activeTextW + 5), scrH * .045, theme.white)
    draw.SimpleText(activeChannelText, NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98 - (activeChannelTextW + activeTextW + 5), scrH * .045, theme.orange)
    draw.SimpleText(string.upper("[Alt + H]"), NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 20 * scaledX), scrW * .98, scrH * .045, theme.white, TEXT_ALIGN_RIGHT)

    -- Render passive channel information
    draw.SimpleText(passiveChannelText, NewDawnLibrary.CreateFont("extrabold", "Montserrat ExtraBold", 16 * scaledX), scrW * .98, scrH * .0673, theme.lightergray, TEXT_ALIGN_RIGHT)
end
local missionInformation = {}

local function createMissionInformationTextEntry(frame, index)
    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(0, 5, 0, 0)
    textEntry:SetPlaceholderText(missionInformation[index])
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255 * .05))
        if ( self.GetPlaceholderText and self.GetPlaceholderColor and self:GetPlaceholderText() and self:GetPlaceholderText():Trim() ~= "" and self:GetPlaceholderColor() and ( not self:GetText() or self:GetText() == "" ) ) then
            local oldText = self:GetText()

            local str = self:GetPlaceholderText()
            if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
            str = language.GetPhrase( str )

            self:SetText( str )
            self:DrawTextEntryText(Color(255, 255, 255, 255 * .5), Color(30, 130, 255), color_white)
            self:SetText( oldText )

            return
        end
        self:DrawTextEntryText(color_white, Color(30, 130, 255), color_white)
    end
    textEntry.OnTextChanged = function(self, newValue)
        if index == 1 then
            if #self:GetText() >= 20 then
                self:SetText(string.sub(self:GetText(), 1, 20))
                self:SetCaretPos(20)
            end
        elseif index == 2 then
            if #self:GetText() >= 26 then
                self:SetText(string.sub(self:GetText(), 1, 26))
                self:SetCaretPos(26)
            end
        end

    end
    -- textEntry.OnEnter = function(self, newValue)
    --     missionInformation[index] = newValue
    --     net.Start("SendMissionInformationTable")
    --     net.WriteTable(missionInformation)
    --     net.SendToServer()
    -- end

    local textEntryButton = vgui.Create("DButton", textEntry)
    textEntryButton:Dock(RIGHT)
    textEntryButton:DockMargin(0, 2, 2, 2)
    textEntryButton:SetTextColor(color_white)
    textEntryButton:SetText("Save")
    textEntryButton.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255 * .1))
    end
    textEntryButton.DoClick = function()
        missionInformation[index] = textEntry:GetText()
        net.Start("SendMissionInformationTable")
        net.WriteTable(missionInformation)
        net.SendToServer()
    end
    return textEntry
end

local function createMissionInformationFrame()
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrW * .2, scrH * .18)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(17, 24, 39))
    end
    PrintTable(missionInformation)

    for i = 1, #missionInformation do
        local textEntry = createMissionInformationTextEntry(frame, i)
    end
end

net.Receive("SendMissionInformationTable", function()
    missionInformation = net.ReadTable()
end)

net.Receive("OpenMissionInformationDerma", function()
    missionInformation = net.ReadTable()
    createMissionInformationFrame()
end)


-- hook.Remove("HUDPaint", "ND_HUD")

local function drawMissionInformation()
    local xPadding = scrW * .004
    local yPadding = scrH * .004
    local yMargin = scrH * .016
    local x = scrW * .98 - scrW * .12
    local y = scrH * .0973
    -- local x2 = (scrW * .98 - scrW * .12)
    local y2 = (scrH * .0973) + (yMargin * 5)

    NewDawnLibrary.DrawLinearGradient(x, y, scrW * .14, scrH * .0673, {
        {offset = 0, color = theme.transparent_gray},
        {offset = .1, color = theme.transparent_gray2},
        {offset = .3, color = theme.transparent_gray3},
        {offset = .6, color = theme.transparent_gray4},
        {offset = 1, color = Color(0, 0, 0, 0)}
    }, true)

    draw.SimpleText(missionInformation[1], NewDawnLibrary.CreateFont("bold", "Montserrat Bold", 26 * scaledX), x + xPadding, y + yPadding, color_white)
    NewDawnLibrary.DrawLinearGradient(x + xPadding, y + yPadding + (yMargin * 2 - scrH * .002), scrW * .1, scrH * .002, {
        {offset = 0, color = theme.blue},
        {offset = 1, color = Color(0, 0, 0, 0)}
    }, true)
    draw.SimpleText("Base Commander: " .. missionInformation[2], NewDawnLibrary.CreateFont("regular", "Montserrat", 14 * scaledX), x + xPadding, y + yPadding + (yMargin * 2.4), color_white)

    NewDawnLibrary.DrawLinearGradient(x, y2, scrW * .14, scrH * .0973, {
        {offset = 0, color = theme.transparent_gray},
        {offset = .1, color = theme.transparent_gray2},
        {offset = .3, color = theme.transparent_gray3},
        {offset = 1, color = Color(0, 0, 0, 0)}
    }, true)
    draw.SimpleText("Status", NewDawnLibrary.CreateFont("bold", "Montserrat Bold", 26 * scaledX), x + xPadding, y2 + yPadding, color_white)
    NewDawnLibrary.DrawLinearGradient(x + xPadding, y2 + yPadding + (yMargin * 2 - scrH * .002), scrW * .1, scrH * .002, {
        {offset = 0, color = theme.blue},
        {offset = 1, color = Color(0, 0, 0, 0)}
    }, true)
    draw.SimpleText("| DEFCON " .. missionInformation[3] .. " |", NewDawnLibrary.CreateFont("regular", "Montserrat", 14 * scaledX), x + xPadding, y2 + yPadding + (yMargin * 2.4), color_white)
    draw.SimpleText("| Traffic Control: " .. missionInformation[4] .. " |", NewDawnLibrary.CreateFont("regular", "Montserrat", 14 * scaledX), x + xPadding, y2 + yPadding + (yMargin * 3.4), color_white)
    draw.SimpleText("| Air Control: " .. missionInformation[5] .. " |", NewDawnLibrary.CreateFont("regular", "Montserrat", 14 * scaledX), x + xPadding, y2 + yPadding + (yMargin * 4.4), color_white)
end

hook.Add("HUDPaint", "ND_HUD", function()
    drawPlayerInformation()
    drawSquadInformation()
    drawCompass()
    drawCommsInformation()
    drawMissionInformation()
end)