local modem = peripheral.find("modem") or error("No modem attached", 0)
local myNumber = os.getComputerID()

local turtleIDs = {[1] = "asleep",[2] = "asleep",[10] = "asleep",[11] = "asleep"} -- add your turtle IDs here
local noOfAliveTurtles = 0
local blockRender = false

function MoveThere(k,cx,cy,cz,direction,action,actionMessage)
    if direction == nil or direction == "" then
        direction = "n"
    end
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
    print("Enter direction[n/s/e/w][optional] :")
    local input = read()
    local cx,cz,cy = gps.locate()
    cx = math.floor(cx)
    cy = math.floor(cy)
    cz = math.floor(cz) - 1
    for k,v in pairs(turtleIDs) do
        if v == "awake" then
            MoveThere(k,cx,cy,cz,input)
            cy = cy + 1
        end
    end
end

function CheckFuel()
    for k,v in pairs(turtleIDs) do
        if v == "awake" or v == "working" then
            modem.transmit(k, myNumber, "#checkFuel")
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
    if x%5 >= 3 then
        nob = nob + 1
    end

    if nob == 0 then
        nob = 1
    end
    if nob > noOfAliveTurtles then
        nob = noOfAliveTurtles
    end
    -- print("totalnob - " .. nob)
    local chunkLength = {}
    for i = 1, nob, 1 do
        chunkLength[i] = math.floor(x / nob)
    end
    local remainderChunk = x % nob
    for i = 1, remainderChunk, 1 do
        chunkLength[i] = chunkLength[i] + 1
    end
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
    local pointer = 1
    for k,v in pairs(turtleIDs) do
        if v == "awake" and noOfBotAssigned < nob then
            local message = ""
            noOfBotAssigned = noOfBotAssigned + 1
            message = chunkLength[pointer] .. "/" .. y .. "/" .. z .. "/" .. floor

            if direction == "n" or direction == "s"  then
                print("Assigning turtle " .. k .. " to start at " .. startxy .. "/" .. cy .. "/" .. cz)
                print("chunkLength: ".. chunkLength[pointer])
                MoveThere(k,startxy,cy,cz,direction,"Mine",message)
            else
                print("Assigning turtle " .. k .. " to start at " .. cx .. "/" .. startxy .. "/" .. cz)
                print("chunkLength: ".. chunkLength[pointer])
                MoveThere(k,cx,startxy,cz,direction,"Mine",message)
            end
            
            if direction == "s" or direction == "w" then
                startxy = startxy - chunkLength[pointer]
            else
                startxy = startxy + chunkLength[pointer]
            end

            pointer = pointer + 1
        end
    end
end

function RenderMainMenu()
    if blockRender then
        return
    end
    term.clear()
    term.setCursorPos(1,2)
    print("Turtle Status:")
    for k, v in pairs(turtleIDs) do
        if v == "awake" then
            term.setTextColor(colors.green)
            term.write(k .. " ")
        elseif v == "working" then
            term.setTextColor(colors.yellow)
            term.write(k .. " ")
        else
            term.setTextColor(colors.red)
            term.write(k .. " ")
        end
    end
    term.setTextColor(colors.white)
    print("..........................")
    print("TYPE")
    print("c - Come Here")
    print("f - Check Fuel")
    print("m - Mine")
    print("s - Stop All Turtles")
    print("l - Get turtle Location")
end

function CheckTurtleStatus()
    -- check if turtles are alive
    local tx,ty = term.getCursorPos()
    noOfAliveTurtles = 0
    for k,_ in pairs(turtleIDs) do
        local message = "#alive"
        modem.transmit(k, myNumber, message)
        local timerID = os.startTimer(1)

        while true do
            local eventData = {os.pullEvent()}
            local event = eventData[1]
            -- print(event)
            if event == "timer" and eventData[2] == timerID then
                turtleIDs[k] = "asleep"
                break
            elseif event == "modem_message" and eventData[3] == myNumber and eventData[5] == "#Hi" then
                turtleIDs[k] = "awake"
                os.cancelTimer(timerID)
                noOfAliveTurtles = noOfAliveTurtles + 1
                break
            elseif event == "modem_message" and eventData[3] == myNumber and eventData[5] == "#Working" then
                turtleIDs[k] = "working"
                os.cancelTimer(timerID)
                break
            end
        end
    end
    -- reseting turtle status indicator
    term.setCursorPos(1,2)
    print("Turtle Status:")
    for k, v in pairs(turtleIDs) do
        if v == "awake" then
            term.setTextColor(colors.green)
            term.write(k .. " ")
        elseif v == "working" then
            term.setTextColor(colors.yellow)
            term.write(k .. " ")
        else
            term.setTextColor(colors.red)
            term.write(k .. " ")
        end
    end
    term.setTextColor(colors.white)
    term.setCursorPos(tx,ty)
end

function GetTurtleMessage()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        local stringMessage = tostring(message)
        if channel == myNumber and turtleIDs[replyChannel] ~= nil then
            if stringMessage:find("#Free") ~= nil then -- message will be like #Free
                turtleIDs[replyChannel] = "awake"
                noOfAliveTurtles = noOfAliveTurtles + 1
                RenderMainMenu()
            elseif stringMessage:find("#Working") ~= nil then -- message will be like #Working
                turtleIDs[replyChannel] = "working"
                noOfAliveTurtles = noOfAliveTurtles - 1
                RenderMainMenu()
            end
        end
    end
end

function GetTurtleLocation()
    print("Enter turtle ID:")
    local input = read()
    local turtleID = tonumber(input)
    if turtleIDs[turtleID] == nil then
        print("Invalid turtle ID")
        return
    elseif turtleIDs[turtleID] == "asleep" then
        print("Turtle is asleep")
        return
    end
    modem.transmit(turtleID, myNumber, "#getLocation")
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == myNumber and replyChannel == turtleID and message:find("#location") ~= nil
    local locationString = string.sub(message, 10) -- remove the "#location#" prefix
    print("Turtle Location: " .. locationString)
end

function Start()
    term.setCursorPos(1,2)
    term.write("Loading Turtles...")
    CheckTurtleStatus()
    term.clear()
    term.setCursorPos(1,2)
    while true do
        blockRender = false
        RenderMainMenu()
        local command = read()
        blockRender = true
        term.write("Loading Turtles...")
        CheckTurtleStatus()
        term.clearLine()
        local _,ty = term.getCursorPos()
        term.setCursorPos(1,ty)
        -- Commands for Turtles
        if command == "c" then
            ComeHere()
        elseif command == "f" then
            CheckFuel()
            print("Press Enter to continue...")
            read()
        elseif command == "m" then
            MinewithTurtle()
            print("Press Enter to continue...")
            read()
        elseif command == "s" then
            for k,v in pairs(turtleIDs) do
                if v == "working" then
                    modem.transmit(k, myNumber, "#Stop")
                end
            end
        elseif command == "l" then
            GetTurtleLocation()
            print("Press Enter to continue...")
            read()
        end
        term.clear()
        term.setCursorPos(1,2)
    end
end
--#################################MAIN#################################
parallel.waitForAll(Start,GetTurtleMessage)