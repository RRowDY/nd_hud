util.AddNetworkString("OpenMissionInformationDerma")
util.AddNetworkString("SendMissionInformationTable")

local missionInformation = {
    "Anaxes",
    "Lorem ipsum dolor sit amet",
    "5",
    "All Flights Clear",
    "Clear to Patrol"
}

local function sendMissionInformationTable(ply)
    net.Start("SendMissionInformationTable")
    net.WriteTable(missionInformation)
    net.Send(ply)
end

net.Receive("SendMissionInformationTable", function()
    missionInformation = net.ReadTable()
end)

local function openMissionInformationDerma(ply)
    net.Start("OpenMissionInformationDerma")
    net.WriteTable(missionInformation)
    net.Send(ply)
end

hook.Add("PlayerSay", "OpenMissionInformationDerma", function(ply, text)
    local args = string.Explode(" ", text)
    if args[1] ~= "/test" then return end

    openMissionInformationDerma(ply)
    return ""
end)

hook.Add("PlayerInitialSpawn", "SendMissionInformationTableOnJoin", sendMissionInformationTable)
