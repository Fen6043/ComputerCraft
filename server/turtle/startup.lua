local turtleI = require("version")
local env = require("envvar")
local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(env.myNumber)

-- Check version
modem.transmit(0, env.myNumber, "#getVersionTurtle")
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
        if serverTurtleVersion ~= turtleI.version then
            shell.run("delete commonTurtlelib.lua")
            shell.run("pastebin get 5Xj719PF commonTurtlelib.lua")
            shell.run("delete createRoom.lua")
            shell.run("pastebin get jKNMSkYd createRoom.lua")
            shell.run("delete mine.lua")
            shell.run("pastebin get GhesvWxn mine.lua")
            shell.run("delete routerTurtleLib.lua")
            shell.run("pastebin get spiUYdMK routerTurtleLib.lua")
            shell.run("delete version.lua")
            shell.run("pastebin get 0m7hauBR version.lua")
            shell.run("delete wirelessMine.lua")
            shell.run("pastebin get N2m4aLe7 wirelessMine.lua")
        end
        break
    end
end

local id = shell.openTab("routerTurtleLib.lua")
multishell.setTitle(id, "TurtleHotSpot")
