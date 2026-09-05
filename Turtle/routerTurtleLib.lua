-- Mobile(M) Turtle(T)
-- M Sends #alive T replies with #Hi if awake or #Working if working
-- WaitForResponse is run in parallel while turtle is working
-- T sends #Free when it is done with the task and waits for a new command
-- T sends #working when it is working on a task

local CTL = require("commonTurtlelib")
local modem = peripheral.find("modem") or error("No modem attached", 0)
local wasTheProgramStopped = false

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
        modem.transmit(CTL.adminNumber, CTL.myNumber, "Not Enough Fuel for turtle:" .. CTL.myNumber)
        read()
    end
    modem.transmit(CTL.adminNumber, CTL.myNumber, "#Working")
    CTL.MovetoLocation(location[1],location[2],location[3])
    CTL.TurnTurtle(directionToNumber[direction])
    -- print(CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
    -- print(".......................................")
end

function WaitForResponse()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == CTL.myNumber and replyChannel == CTL.adminNumber then
            local stringMsg = tostring(message)
            print("Received a message: " .. stringMsg)
            if stringMsg == "#Stop" then
                wasTheProgramStopped = true
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#Free")
                break
            elseif stringMsg == "#alive" then
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#Working")
            elseif stringMsg == "#checkFuel" then
                local fuelLevel = turtle.getFuelLevel()
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#"..fuelLevel)
            elseif stringMsg == "#getLocation" then
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#location#"..CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
            end
        end
    end
end

function Start ()
    CTL.CalibrateTurtle()
    modem.open(CTL.myNumber)
    local command = {}
    modem.transmit(CTL.adminNumber, CTL.myNumber, "#Free")
    while true do
        print("Waiting for a message...")
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == CTL.myNumber and replyChannel == CTL.adminNumber then
            print("Received a message: " .. tostring(message))
            for i in string.gmatch(message,"[^#]+") do
                table.insert(command,i)
            end
            -- commands for turtles
            if command[1] == "alive" then -- check if turtle is running
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#Hi")
            elseif command[1] == "move" then -- For turtle to come to me
                parallel.waitForAny(function() MoveTurtle(command[2],command[3]) end, WaitForResponse)
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#Free")
            elseif command[1] == "checkFuel" then -- CheckFuel of turtle and send it back to admin
                local fuelLevel = turtle.getFuelLevel()
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#"..fuelLevel)
            elseif command[1] == "mine" then
                parallel.waitForAny(function() MoveTurtle(command[2],command[3]) end, WaitForResponse)
                parallel.waitForAny(function() shell.execute("wirelessMine", command[4]) end, WaitForResponse)
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#Free")
            elseif command[1] == "getLocation" then
                modem.transmit(CTL.adminNumber, CTL.myNumber, "#location#"..CTL.cx .. "/" .. CTL.cz .. "/" .. CTL.cy)
            end

            command = {}
        end
    end
end

Start()