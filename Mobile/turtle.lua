local modem = peripheral.find("modem") or error("No modem attached", 0)
local myNumber = os.getComputerID()

local turtleIDs = {[1] = false,[2] = false,[10] = false,[11] = false}
local noOfAliveTurtles = 0

function MoveThere(k,cx,cy,cz,direction,action,actionMessage)
    direction = direction or "n"
    action = action or "Move"
    actionMessage = actionMessage or ""
    -- print("location - " .. cx .. "/" .. cy .. "/" .. cz .. "#" .. direction)
    local message = ""
    -- call the turtle over
    if action == "Move" then
        message = "#move#" .. cx .. "/" .. cy .. "/" .. cz .. "#" .. direction
    elseif action == "Mine" then
        message = "#mine#" .. cx .. "/" .. cy .. "/" .. cz .. "#" .. direction .. "#" .. actionMessage
    end
    modem.transmit(k, myNumber, message)
end

function ComeHere()
    local cx,cz,cy = gps.locate()
    cx = math.floor(cx)
    cy = math.floor(cy)
    cz = math.floor(cz) - 1
    for k,v in pairs(turtleIDs) do
        if v then
            MoveThere(k,cx,cy,cz)
            cy = cy + 1
        end
    end
end

function CheckFuel()
    for k,v in pairs(turtleIDs) do
        local message = "#checkFuel"
        if v then
            modem.transmit(k, myNumber, message)
            local event, side, channel, replyChannel, message, distance
            repeat
                event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
            until channel == myNumber and replyChannel == k
            print("Fuel Level for " .. k .. " is " .. message)
        end
    end
end

function MinewithTurtle()
    print("Enter depth :")
    local input = read()
    if not tonumber(input) then
        print("invalid input")
        return
    end
    local depth = tonumber(input) or 0

    print("Enter direction(n/s/e/w) :")
    input = read()
    local direction = input

    print("Enter dimention as x/y/z :")
    input = read()
    local dimention = {}

    for i in string.gmatch(input,"[^/]+") do
        table.insert(dimention,i)
    end

    if not (tonumber(dimention[1]) and tonumber(dimention[2]) and tonumber(dimention[3])) then
        print("invalid input")
        return
    end

    local x = tonumber(dimention[1]) or 0
    local y = tonumber(dimention[2]) or 0
    local z = tonumber(dimention[3]) or 0
    print("Create floor(y/n)" .. "[" .. ((x) * (y)) .. " tiles]".. ":")
    local floor = read()

    -- Calculating no of bots required and assigning starting point
    local nob = math.floor(x/5)
    if x%5 > 3 then
        nob = nob + 1
    end

    if nob == 0 then
        nob = 1
    end
    if nob > noOfAliveTurtles then
        nob = noOfAliveTurtles
    end
    -- print("totalnob - " .. nob)
    local oneChunkLength = math.floor(x / nob)
    -- print("oneChunkLength - " .. oneChunkLength)
    local cx,cz,cy = gps.locate()
    cx = math.floor(cx)
    cy = math.floor(cy)
    cz = math.floor(cz) - 1
    cz = cz - depth

    local noOfBotAssigned = 0
    local startxy = 0
    if direction == "n" or direction == "s" then
        startxy = cx
    else
        startxy = cy
    end
    -- print("assigning startxy:"..startxy .. cx .. cy)
    local remainingChunkSize = x
    for k,v in pairs(turtleIDs) do
        if v and noOfBotAssigned < nob then
            if noOfBotAssigned ~= 0 then
                if direction == "s" or direction == "w" then
                    startxy = startxy - oneChunkLength
                else
                    startxy = startxy + oneChunkLength
                end
            end
            
            local message = ""
            noOfBotAssigned = noOfBotAssigned + 1
            if noOfBotAssigned >= nob then -- last bot will take the remaining chunk size
                message = remainingChunkSize .. "/" .. y .. "/" .. z .. "/" .. floor
            else
                message = oneChunkLength .. "/" .. y .. "/" .. z .. "/" .. floor
            end

            if direction == "n" or direction == "s"  then
                print("Assigning turtle " .. k .. " to start at " .. startxy .. "/" .. cy .. "/" .. cz)
                MoveThere(k,startxy,cy,cz,direction,"Mine",message)
            else
                print("Assigning turtle " .. k .. " to start at " .. cx .. "/" .. startxy .. "/" .. cz)
                MoveThere(k,cx,startxy,cz,direction,"Mine",message)
            end
            remainingChunkSize = remainingChunkSize - oneChunkLength
        end
    end
end

function CheckTurtleAlive()
    -- check if turtles are alive
    noOfAliveTurtles = 0
    print("Turtle Status:")
    for k,_ in pairs(turtleIDs) do
        local message = "#alive"
        modem.transmit(k, myNumber, message)
        local timerID = os.startTimer(3)

        while true do
            local eventData = {os.pullEvent()}
            local event = eventData[1]
            -- print(event)
            if event == "timer" and eventData[2] == timerID then
                turtleIDs[k] = false
                print(k .. " is offline")
                break
            elseif event == "modem_message" and eventData[3] == myNumber and eventData[5] == "#Hi" then
                turtleIDs[k] = true
                os.cancelTimer(timerID)
                print(k .. " is online")
                noOfAliveTurtles = noOfAliveTurtles + 1
                break
            end
        end
    end
end

--#################################MAIN#################################
CheckTurtleAlive()
local commands = {["a"] = "Check Turtle Status",["c"] = "Come Here",["f"] = "Check Fuel",["m"] = "Mine"}
while true do
    print("..........................")
    print("TYPE")
    for key, value in pairs(commands) do
        print(key .. " - " .. value)
    end
    local command = read()
    if command == "c" then
        ComeHere()
    elseif command == "f" then
        CheckFuel()
    elseif command == "m" then
        MinewithTurtle()
    elseif command == "a" then
        CheckTurtleAlive()
    end
    print("..........................")
end