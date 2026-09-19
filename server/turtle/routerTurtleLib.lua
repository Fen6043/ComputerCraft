-- Mobile(M) Turtle(T)
-- M Sends #alive T replies with #Hi if awake or #Working if working
-- WaitForResponse is run in parallel while turtle is working
-- T sends #Free when it is done with the task and waits for a new command
-- T sends #working when it is working on a task

local CTL = require("commonTurtlelib")
local modem = peripheral.find("modem") or error("No modem attached", 0)
local wasTheProgramStopped = false

function SendMessageToAdmin(message)
    for _, value in ipairs(CTL.adminNumber) do
        modem.transmit(value, CTL.myNumber, message)
    end
end

function IsAdmin(val)
    for _, value in ipairs(CTL.adminNumber) do
        if value == val then
            return true
        end
    end
    return false
end

function MoveTurtle(locationString,direction)
    local location = {}
    if wasTheProgramStopped then
        wasTheProgramStopped = false
        CTL.CalibrateTurtle()
    end
    local directionToNumber = {["n"] = 0, ["e"] = 1, ["s"] = 2, ["w"] = 3}
    for i in string.gmatch(locationString,"[^/]+") do
        table.insert(location,tonumber(i))
    end
    -- print(".......................................")
    -- print(CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
    -- print(location[1] .. "/" .. location[2] .. "/" .. location[3])
    local stepsToTake = math.abs((location[1] - CTL.cx)) + math.abs((location[2] - CTL.cy)) + math.abs((location[3] - CTL.cz)) + 50 -- collision buffer as 50
    while not CTL.CheckFuel(stepsToTake) do
        SendMessageToAdmin("Not Enough Fuel for turtle:" .. CTL.myNumber)
        read()
        shell.run("refuel")
    end
    SendMessageToAdmin("#Working")
    CTL.MovetoLocation(location[1],location[2],location[3])
    CTL.TurnTurtle(directionToNumber[direction])
    -- print(CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
    -- print(".......................................")
end

function WaitForResponse()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == CTL.myNumber and IsAdmin(replyChannel) then
            local stringMsg = tostring(message)
            print("Received a message: " .. stringMsg)
            if stringMsg == "#Stop" then
                wasTheProgramStopped = true
                SendMessageToAdmin("#Free")
                break
            elseif stringMsg == "#alive" then
                SendMessageToAdmin("#Working")
            elseif stringMsg == "#checkFuel" then
                local fuelLevel = turtle.getFuelLevel()
                SendMessageToAdmin("#"..fuelLevel)
            elseif stringMsg == "#getLocation" then
                SendMessageToAdmin("#location#"..CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
            end
        end
    end
end

function Start ()
    CTL.CalibrateTurtle()
    local command = {}
    SendMessageToAdmin("#Free")
    while true do
        print("Waiting for a message...")
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == CTL.myNumber and IsAdmin(replyChannel) then
            print("Received a message: " .. tostring(message))
            for i in string.gmatch(message,"[^#]+") do
                table.insert(command,i)
            end
            -- commands for turtles
            if command[1] == "alive" then -- check if turtle is running
                SendMessageToAdmin("#Hi")
            elseif command[1] == "move" then -- For turtle to come to me
                parallel.waitForAny(function() MoveTurtle(command[2],command[3]) end, WaitForResponse)
                SendMessageToAdmin("#Free")
            elseif command[1] == "checkFuel" then -- CheckFuel of turtle and send it back to admin
                local fuelLevel = turtle.getFuelLevel()
                SendMessageToAdmin("#"..fuelLevel)
            elseif command[1] == "mine" then --eg: #mine#105/404/30#n#10/5/6/y
                parallel.waitForAny(function() MoveTurtle(command[2],command[3]) end, WaitForResponse)
                parallel.waitForAny(function() shell.execute("wirelessMine", command[4]) end, WaitForResponse)
                SendMessageToAdmin("#Free")
            elseif command[1] == "createRoom" then --eg: #createRoom#105/404/30#n#10/5/6#y#tlr
                parallel.waitForAny(function() MoveTurtle(command[2],command[3]) end, WaitForResponse)
                parallel.waitForAny(function() shell.execute("createRoom", command[5], command[6], "0", command[4], "wifiMode") end, WaitForResponse)
            elseif command[1] == "getLocation" then
                SendMessageToAdmin("#location#"..CTL.cx .. "/" .. CTL.cz .. "/" .. CTL.cy)
            elseif command[1] == "Exit" then
                SendMessageToAdmin("Turtle " .. CTL.myNumber .. " going Offline")
                break
            end
            command = {}
        end
    end
end

Start()