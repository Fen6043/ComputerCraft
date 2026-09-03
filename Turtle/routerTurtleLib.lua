local CTL = require("commonTurtlelib")
local routerTurtle = {}
local modem = peripheral.find("modem") or error("No modem attached", 0)
local myNumber = os.getComputerID()

function MoveTurtle(locationString,direction)
    local location = {}
    local directionToNumber = {["n"] = 0, ["e"] = 1, ["s"] = 2, ["w"] = 3}
    for i in string.gmatch(locationString,"[^/]+") do
        table.insert(location,tonumber(i))
    end
    -- print(".......................................")
    -- print(CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
    -- print(location[1] .. "/" .. location[2] .. "/" .. location[3])
    local hasFuel = CTL.CheckFuel(math.abs((location[1] - CTL.cx)) + math.abs((location[2] - CTL.cy)) + math.abs((location[3] - CTL.cz)))
    if hasFuel then
       CTL.MovetoLocation(location[1],location[2],location[3])
       CTL.TurnTurtle(directionToNumber[direction])
    else
        modem.transmit(CTL.adminNumber, myNumber, "Not Enough Fuel for turtle:" .. myNumber)
    end
    -- print(CTL.cx .. "/" .. CTL.cy .. "/" .. CTL.cz)
    -- print(".......................................")
end

routerTurtle.Start = function ()
    CTL.CalibrateTurtle()
    modem.open(myNumber)
    local command = {}
    while true do
        print("Waiting for a message...")
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == myNumber and replyChannel == CTL.adminNumber then
            print("Received a message: " .. tostring(message))
            for i in string.gmatch(message,"[^#]+") do
                table.insert(command,i)
            end

            if command[1] == "alive" then -- check if turtle is running
                modem.transmit(CTL.adminNumber, myNumber, "#Hi")
            elseif command[1] == "move" then -- For turtle to come to me
                MoveTurtle(command[2],command[3])
            elseif command[1] == "checkFuel" then -- CheckFuel of turtle and send it back to admin
                local fuelLevel = turtle.getFuelLevel()
                modem.transmit(CTL.adminNumber, myNumber, "#"..fuelLevel)
            elseif command[1] == "mine" then
                MoveTurtle(command[2],command[3])
                shell.execute("wirelessMine", command[4])
            end

            command = {}
        end
    end
end

return routerTurtle