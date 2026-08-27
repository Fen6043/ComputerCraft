local commonlib = require("commonTurtlelib")
local checkedBlock = {}

function AddToCheckedBlock(x,y,z,lookDirection)
    if lookDirection == "Up" then
        z = z + 1
    elseif lookDirection == "Down" then
        z = z - 1
    elseif lookDirection == 0 then
        y = y + 1
    elseif lookDirection == 1 then
        x = x + 1
    elseif lookDirection == 2 then
        y = y - 1
    elseif lookDirection == 3 then
        x = x - 1
    end
    if checkedBlock[x.."/"..y.."/"..z] == nil then
        checkedBlock[x.."/"..y.."/"..z] = true
    end
end

function CheckCheckedBlock(x,y,z)
    if checkedBlock[x.."/"..y.."/"..z] ~= nil then
        return true
    else
        return false
    end
end

-- checks up and down diagonal block 
function CheckDiagonal(faceDirection)
    local detectBlock, blockDetails
    commonlib.TurnTurtle(faceDirection)
    commonlib.MoveForward(1)
    local x = commonlib.cx
    local y = commonlib.cy
    local z = commonlib.cz
    detectBlock, blockDetails = turtle.inspectUp()
    AddToCheckedBlock(x,y,z,"Up")
    if detectBlock and string.find(blockDetails.name,"log") then
        turtle.digUp()
        commonlib.MoveUp(1)
        CutTree()
    end
    commonlib.MovetoLocation(x,y,z)
    detectBlock, blockDetails = turtle.inspectDown()
    AddToCheckedBlock(x,y,z,"Down")
    if detectBlock and string.find(blockDetails.name,"log") then
        turtle.digDown()
        commonlib.MoveDown(1)
        CutTree()
    end
    commonlib.MovetoLocation(x,y,z)
end

function CutTree(prevMove)
    prevMove = prevMove or ""
    local detectBlock, blockDetails
    local x = commonlib.cx
    local y = commonlib.cy
    local z = commonlib.cz
    local lookPointer = commonlib.faceDirection
    local checkRight = false
    local checkLeft = false
    local checkBack = false
    local checkFront = false
    local checkTop = false
    local checkDown = false

    -- top
    detectBlock, blockDetails = turtle.inspectUp()
    AddToCheckedBlock(x,y,z,"Up")
    if detectBlock and string.find(blockDetails.name,"log") and prevMove ~= "Down" then
        turtle.digUp()
        commonlib.MoveUp(1)
        CutTree("Up")
        checkTop = true
    end

    -- front
    commonlib.MovetoLocation(x,y,z)
    commonlib.TurnTurtle(lookPointer)
    detectBlock, blockDetails = turtle.inspect()
    AddToCheckedBlock(x,y,z,commonlib.faceDirection)
    if detectBlock and string.find(blockDetails.name,"log") then
        turtle.dig()
        commonlib.MoveForward(1)
        CutTree("Front")
        checkFront = true
    end

    -- right
    commonlib.MovetoLocation(x,y,z)
    commonlib.TurnTurtle((lookPointer + 1) % 4)
    detectBlock, blockDetails = turtle.inspect()
    AddToCheckedBlock(x,y,z,commonlib.faceDirection)
    if detectBlock and string.find(blockDetails.name,"log") then
        turtle.dig()
        commonlib.MoveForward(1)
        CutTree("Front")
        checkRight = true
    end

    -- back
    commonlib.MovetoLocation(x,y,z)
    if prevMove ~= "Front" then
       commonlib.TurnTurtle((lookPointer + 2) % 4)
        detectBlock, blockDetails = turtle.inspect()
        AddToCheckedBlock(x,y,z,commonlib.faceDirection)
        if detectBlock and string.find(blockDetails.name,"log") then
            turtle.dig()
            commonlib.MoveForward(1)
            CutTree("Front")
            checkLeft = true
        end
    end

    -- left
    commonlib.MovetoLocation(x,y,z)
    commonlib.TurnTurtle((lookPointer - 1) % 4)
    detectBlock, blockDetails = turtle.inspect()
    AddToCheckedBlock(x,y,z,commonlib.faceDirection)
    if detectBlock and string.find(blockDetails.name,"log") then
        turtle.dig()
        commonlib.MoveForward(1)
        CutTree("Front")
        checkBack = true
    end

    -- bottom
    commonlib.MovetoLocation(x,y,z)
    commonlib.TurnTurtle(lookPointer)
    detectBlock, blockDetails = turtle.inspectDown()
    AddToCheckedBlock(x,y,z,"Down")
    if detectBlock and string.find(blockDetails.name,"log") and prevMove ~= "Up" then
        turtle.digDown()
        commonlib.MoveDown(1)
        CutTree("Down")
        checkDown = true
    end

    -- diagonal(no idea how i did this)
    commonlib.MovetoLocation(x,y,z)
    if not (checkTop or checkDown) and not (x == 0 and y == 0 and z == 0) then
        -- Is going to check the right diagonal blocks if not already checked
        if not checkRight and not (CheckCheckedBlock(x+1,y,z+1) and CheckCheckedBlock(x+1,y,z-1) and CheckCheckedBlock(x+1,y+1,z) and CheckCheckedBlock(x+1,y-1,z)) then
            CheckDiagonal((lookPointer + 1) % 4)
            commonlib.TurnTurtle(lookPointer) -- turn left to check Left block
            detectBlock, blockDetails = turtle.inspect()
            AddToCheckedBlock(x,y,z,commonlib.faceDirection)
            if detectBlock and string.find(blockDetails.name,"log") then
                turtle.dig()
                commonlib.MoveForward(1)
                CutTree()
            end
            commonlib.TurnTurtle((lookPointer + 2) % 4) -- turn right to check Right block
            detectBlock, blockDetails = turtle.inspect()
            AddToCheckedBlock(x,y,z,commonlib.faceDirection)
            if detectBlock and string.find(blockDetails.name,"log") then
                turtle.dig()
                commonlib.MoveForward(1)
                CutTree()
            end
        end
        commonlib.MovetoLocation(x,y,z)
        -- Is going to check the left diagonal blocks if not already checked
        if not checkLeft and not (CheckCheckedBlock(x-1,y,z+1) and CheckCheckedBlock(x-1,y,z-1) and CheckCheckedBlock(x-1,y+1,z) and CheckCheckedBlock(x-1,y-1,z)) then
            CheckDiagonal((lookPointer - 1) % 4)
            commonlib.TurnTurtle(lookPointer) -- turn left to check Left block
            detectBlock, blockDetails = turtle.inspect()
            AddToCheckedBlock(x,y,z,commonlib.faceDirection)
            if detectBlock and string.find(blockDetails.name,"log") then
                turtle.dig()
                commonlib.MoveForward(1)
                CutTree()
            end
            commonlib.TurnTurtle((lookPointer + 2) % 4) -- turn right to check Right block
            detectBlock, blockDetails = turtle.inspect()
            AddToCheckedBlock(x,y,z,commonlib.faceDirection)
            if detectBlock and string.find(blockDetails.name,"log") then
                turtle.dig()
                commonlib.MoveForward(1)
                CutTree()
            end
        end
        commonlib.MovetoLocation(x,y,z)
        -- Is going to check the front diagonal blocks if not already checked
        if not checkFront and not (CheckCheckedBlock(x,y+1,z+1) and CheckCheckedBlock(x,y+1,z-1) and CheckCheckedBlock(x-1,y+1,z+1) and CheckCheckedBlock(x-1,y+1,z-1) and CheckCheckedBlock(x+1,y+1,z+1) and CheckCheckedBlock(x+1,y+1,z-1)) then
            CheckDiagonal(lookPointer)
            CheckDiagonal((lookPointer + 1) % 4)
            commonlib.TurnTurtle((lookPointer - 1) % 4)
            commonlib.MoveForward(1)
            CheckDiagonal((lookPointer - 1) % 4)
        end
        commonlib.MovetoLocation(x,y,z)
        -- Is going to check the back diagonal blocks if not already checked
        if not checkBack and prevMove ~= "Front" and not (CheckCheckedBlock(x,y-1,z+1) and CheckCheckedBlock(x,y-1,z-1) and CheckCheckedBlock(x-1,y-1,z+1) and CheckCheckedBlock(x-1,y-1,z-1) and CheckCheckedBlock(x+1,y-1,z+1) and CheckCheckedBlock(x+1,y-1,z-1)) then
            CheckDiagonal((lookPointer + 2) % 4)
            CheckDiagonal((lookPointer + 1) % 4)
            commonlib.TurnTurtle((lookPointer - 1) % 4)
            commonlib.MoveForward(1)
            CheckDiagonal((lookPointer - 1) % 4)
        end
    end
    commonlib.MovetoLocation(x,y,z)
end

function BeginWorkflow()
    CutTree()
    commonlib.TurnTurtle(0)
end

BeginWorkflow()