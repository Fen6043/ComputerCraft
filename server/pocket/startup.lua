local modem = peripheral.find("modem")
local env = require("envvar")
local pocketI = require("version")
modem.open(env.myNumber)

-- Check version
modem.transmit(0, env.myNumber, "#getVersionPocket")
local timerID = os.startTimer(3)
while true do
    local eventData = {os.pullEvent()}
    local event = eventData[1]
    -- print(event)
    if event == "timer" and eventData[2] == timerID then
        print("server asleep")
        break
    elseif event == "modem_message" and eventData[3] == env.myNumber then
        local serverTurtleVersion = eventData[5]
        if serverTurtleVersion ~= pocketI.version then
            shell.run("delete getMessage.lua")
            shell.run("pastebin get GWch2Q85 getMessage.lua")
            shell.run("delete sendMessage.lua")
            shell.run("pastebin get HNJYUbW9 sendMessage.lua")
            shell.run("delete turtle.lua")
            shell.run("pastebin get 6AuQCFSe turtle.lua")
            shell.run("delete version.lua")
            shell.run("pastebin get Y2NfH2Qh version.lua")
        end
        break
    end
end

local id = shell.openTab("getMessage.lua")
multishell.setTitle(id, "Message")
shell.run("Turtle")
