local modem = peripheral.find("modem") or error("No modem attached", 0)
local env = require("envvar")
local turtleIDs = env.turtleIDs
local myNumber = env.myNumber
local noOfAliveTurtles = 0
local blockRender = false
-- Configure UI Position here
local renderText = {["Come Here"] = {0,0},["Check Fuel"] = {12,0},["Mine"] = {0,2},["Stop All Turtles"] = {7,2},["Create Room"] = {0,4},["Get turtle Location"] = {0,6}}
local maxy = 6 --set this for rendering. Has to set this since in lua pairs might not iterate in same order as above
local renderedTextPos = {}

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
        message = "#mine#" .. cx .. "/" .. cy .. "/" .. cz .. "#" .. direction .. "#" .. actionMessage --eg: #mine#105/404/30#n#10/5/6/y
    elseif action == "CreateRoom" then
        message = "#createRoom#" .. cx .. "/" .. cy .. "/" .. cz .. "#" .. direction .. "#" .. actionMessage --eg: #createRoom#105/404/30#n#10/5/6#y#tlr
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
    local _,ty = term.getCursorPos()
    term.write("Loading Turtles...")
    CheckTurtleStatus("awake")
    term.clearLine()
    term.setCursorPos(1,ty)
    for k,v in pairs(turtleIDs) do
        if v == "awake" then
            MoveThere(k,cx,cy,cz,input)
            cy = cy + 1
        end
    end
end

function CheckFuel()
    local _,ty = term.getCursorPos()
    term.write("Loading Turtles...")
    CheckTurtleStatus("awake")
    CheckTurtleStatus("working")
    term.clearLine()
    term.setCursorPos(1,ty)
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
    print("Press Enter to continue...")
    read()
end

function CreateRoomWithTurtle()
    print("--------------------------")
    print("Enter direction(n/s/e/w) :")
    local input = read()
    local direction = input
    if direction:gmatch("^[nsew]$") == nil then
        print("Invalid input")
        return
    end
    print("--------------------------")
    print("Are you expanding the room(y/n):")
    local expand = read() --arg1
    local walls = "tblr" -- Top Bottom Left Right
    if expand == "y" then
        while true do
            print("--------------------------")
            print("enter the walls[t - Top,b - Bottom,l - Left,r - Right] to create like[tblr,rbl..] :")
            walls = read() --arg2
            if walls:match("^[tblr]*$") ~= nil and #walls < 5 then
                break
            end
        end
    end
    print("--------------------------")
    print("Enter depth :")
    input = read() -- arg3
    if not tonumber(input) then
        print("invalid input")
        return
    end
    local depth = tonumber(input)
    print("--------------------------")
    print("Enter dimention as x/y/z :")
    input = read() -- arg4
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

    -- Calculating no of bots required and assigning starting point
    local nob = math.floor(x/5)
    if x%5 >= 3 then
        nob = nob + 1
    end

    if nob == 0 then
        nob = 1
    end

    local _,ty = term.getCursorPos()
    term.write("Loading Turtles...")
    CheckTurtleStatus()
    term.clearLine()
    term.setCursorPos(1,ty)
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
            local finalWall = walls
            noOfBotAssigned = noOfBotAssigned + 1

            if nob > 1 then -- If no of bots is more than 1 then we need to modify the walls to be built by each turtle
                if noOfBotAssigned == 1 then -- First bot Ignore right wall
                    finalWall = finalWall:gsub("r","")
                elseif noOfBotAssigned == nob then -- Last bot Ignore left wall
                    finalWall = finalWall:gsub("l","")
                else -- Ignore left and right wall
                    finalWall = finalWall:gsub("[lr]","")
                end
            end
            
            -- expand should always be y while passing the message to turtle since turtles share the work and need to ignore some walls
            message = chunkLength[pointer] .. "/" .. y .. "/" .. z .. "#" .. "y" .. "#" .. finalWall

            if direction == "n" or direction == "s"  then
                print("Assigning turtle " .. k .. " to start at " .. startxy .. "/" .. cy .. "/" .. cz)
                print("chunkLength: ".. chunkLength[pointer])
                MoveThere(k,startxy,cy,cz,direction,"CreateRoom",message)
            else
                print("Assigning turtle " .. k .. " to start at " .. cx .. "/" .. startxy .. "/" .. cz)
                print("chunkLength: ".. chunkLength[pointer])
                MoveThere(k,cx,startxy,cz,direction,"CreateRoom",message)
            end
            
            if direction == "s" or direction == "w" then
                startxy = startxy - chunkLength[pointer]
            else
                startxy = startxy + chunkLength[pointer]
            end

            pointer = pointer + 1
        end
    end
    print("--------------------------")
    term.setTextColor(colors.red)
    print("Please add materials to turtle...")
    term.setTextColor(colors.white)
    read()
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

    local _,ty = term.getCursorPos()
    term.write("Loading Turtles...")
    CheckTurtleStatus()
    term.clearLine()
    term.setCursorPos(1,ty)
    if nob > noOfAliveTurtles then
        nob = noOfAliveTurtles
    end
    print("totalnob - " .. nob)
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
    print("Press Enter to continue...")
    read()
end

function RenderMainMenu()
    if blockRender then
        return
    end
    term.clear()
    term.setCursorPos(1,2)
    print("Turtle Status:")
    for k, v in pairs(turtleIDs) do
        local x,y = term.getCursorPos()
        if x > 23 then
            term.setCursorPos(1,y+1)
        end
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
    print("SELECT")
    print("")
    local x,y = term.getCursorPos()
    term.setTextColor(colors.black)
    local test = 1
    for key, value in pairs(renderText) do
        term.setCursorPos(x + value[1],y + value[2])
        term.setBackgroundColor(colors.orange)
        term.write("-"..key.."-")
        term.setBackgroundColor(colors.black)
        renderedTextPos[key] = {x + value[1],x + value[1] + #key + 1,y + value[2]}
    end
    term.setTextColor(colors.white)
    term.setCursorPos(1,y+maxy+1)
    print("..........................")
end

function CheckTurtleStatus(status)
    status = status or "all"
    local turtleToCheck = {}
    if status ~= "all" then
        for key, value in pairs(turtleIDs) do
            if value == status then
                turtleToCheck[key] = turtleIDs[key]
            end
        end
    else
        turtleToCheck = turtleIDs
    end
    -- check if turtles are alive
    local tx,ty = term.getCursorPos()
    noOfAliveTurtles = 0
    for k,_ in pairs(turtleToCheck) do
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
                RenderMainMenu()
            elseif stringMessage:find("#Working") ~= nil then -- message will be like #Working
                turtleIDs[replyChannel] = "working"
                RenderMainMenu()
            elseif message == "#Exit" then
                turtleIDs[replyChannel] = "asleep"
                modem.transmit(replyChannel,myNumber,"#Exit")
                RenderMainMenu()
            end
        end
    end
end

function GetTurtleLocation()
    local _,ty = term.getCursorPos()
    term.write("Loading Turtles...")
    CheckTurtleStatus("awake")
    CheckTurtleStatus("working")
    term.clearLine()
    term.setCursorPos(1,ty)
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
    print("Press Enter to continue...")
    read()
end

function ClickScreen()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        -- print(("The mouse button %s was pressed at %d, %d"):format(button, x, y))
        if button == 1 then -- left click
            for key, value in pairs(renderedTextPos) do
                if value[3] == y then
                    if x>=value[1] and x<=value[2] then
                        return key
                    end
                end
            end
        end 
    end
end

function ExitProcess()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        -- print(("The mouse button %s was pressed at %d, %d"):format(button, x, y))
        if button == 2 then -- left click
            return
        end
    end
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
        local command = ClickScreen()
        blockRender = true
        local _,ty = term.getCursorPos()
        term.setCursorPos(1,ty)
        -- Commands for Turtles
        if command == "Come Here" then
            parallel.waitForAny(ComeHere,ExitProcess)
        elseif command == "Check Fuel" then
            parallel.waitForAny(CheckFuel,ExitProcess)
        elseif command == "Mine" then
            parallel.waitForAny(MinewithTurtle,ExitProcess)
        elseif command == "Create Room" then
            parallel.waitForAny(CreateRoomWithTurtle,ExitProcess)
        elseif command == "Stop All Turtles" then
            for k,v in pairs(turtleIDs) do
                if v == "working" then
                    modem.transmit(k, myNumber, "#Stop")
                end
            end
        elseif command == "Get turtle Location" then
            parallel.waitForAny(GetTurtleLocation,ExitProcess)
        end
        term.clear()
        term.setCursorPos(1,2)
    end
end
--#################################MAIN#################################
parallel.waitForAll(Start,GetTurtleMessage)