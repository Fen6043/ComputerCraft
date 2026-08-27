local common = {}

common.cx = 0
common.cy = 0
common.cz = 0
common.faceDirection = 0

function SelectMaterialCell(slabMaterial)
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name == slabMaterial then
            turtle.select(i)
            return true
        end
    end
    return false
end

common.PutSlab = function (slabMaterial)
    local isThereFloor, floorDetails = turtle.inspectDown()
    if isThereFloor then
        if floorDetails.name ~= slabMaterial then
            while turtle.detectDown() do
                -- print("inside while 1")
                turtle.digDown()
            end
            if SelectMaterialCell(slabMaterial) then
               turtle.placeDown()
            else
                print("No material found")
            end
        end
    else
        if SelectMaterialCell(slabMaterial) then
           turtle.placeDown()
        else
            print("No material found")
        end
    end
    
end

common.TurnTurtle = function (toDirection)
    if common.faceDirection == toDirection then
        return
    end
    local turnLeftPointer = (4 + (common.faceDirection - 1)) % 4
    local turnRightPointer = (common.faceDirection + 1) % 4

    if  turnLeftPointer == toDirection then
      turtle.turnLeft()
      common.faceDirection = turnLeftPointer
    elseif turnRightPointer == toDirection then
      turtle.turnRight()
      common.faceDirection = turnRightPointer
    else
      turtle.turnRight()
      turtle.turnRight()
      common.faceDirection = (common.faceDirection + 2) % 4
    end
end

common.MoveForward = function (steps,putSlab,slabMaterial)
    for i = 1, steps, 1 do
        while turtle.detect() do
            -- print("inside while 7")
            turtle.dig()
        end
        turtle.forward()
        if putSlab then
            common.PutSlab(slabMaterial)
        end
        if common.faceDirection == 0 then
            common.cy = common.cy + 1
        elseif common.faceDirection == 1 then
            common.cx = common.cx + 1
        elseif common.faceDirection == 2 then
            common.cy = common.cy - 1
        elseif common.faceDirection ==3 then
            common.cx = common.cx - 1
        end
    end
end

common.MoveUp = function (steps,putSlab,slabMaterial)
    for i = 1, steps, 1 do
        while turtle.detectUp() do
            -- print("inside while 8")
            turtle.digUp()
        end
        turtle.up()
        if putSlab then
            common.PutSlab(slabMaterial)
        end
        common.cz = common.cz + 1
    end
end

common.MoveDown = function (steps)
    for i = 1, steps, 1 do
        while turtle.detectDown() do
            -- print("inside while 9")
            turtle.digDown()
        end
        turtle.down()
        common.cz = common.cz - 1
    end
end

common.MovetoLocation = function (x,y,z,putSlab,slabMaterial)
    if common.cx < x then
        common.TurnTurtle(1)
        common.MoveForward(x-common.cx,putSlab,slabMaterial)
    elseif common.cx > x then
        common.TurnTurtle(3)
        common.MoveForward(common.cx-x,putSlab,slabMaterial)
    end

    if common.cy < y then
        common.TurnTurtle(0)
        common.MoveForward(y-common.cy,putSlab,slabMaterial)
    elseif common.cy > y then
        common.TurnTurtle(2)
        common.MoveForward(common.cy-y,putSlab,slabMaterial)
    end

    if common.cz < z then
        common.MoveUp(z-common.cz)
    elseif common.cz > z then
        common.MoveDown(common.cz-z)
    end
end

common.CheckFuel = function (steps)
    local currentFuel = turtle.getFuelLevel()
    if steps > currentFuel then
        print("Not Enough Fuel. currentFuel Level - " .. currentFuel .. "/" .. steps)
        return false
    else
        return true
    end
end

return common