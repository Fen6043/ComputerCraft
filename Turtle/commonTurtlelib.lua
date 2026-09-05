local common = {}
local modem = peripheral.find("modem")

common.cx = 0
common.cy = 0
common.cz = 0
common.faceDirection = 0
common.initialx = 0
common.initialy = 0
common.initialz = 0
common.collided = false
common.adminNumber = 5 -- SET THE ADMIN NUMBER
common.myNumber = os.getComputerID()
common.moveAlongXFirst = true

-- Trash coordinate system in minecraft
--  0    -y
-- 3 1 -x  +x
--  2    +y

function SelectMaterialCell(slabMaterial)
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name == slabMaterial then
            turtle.select(i)
            return true
        end
    end
    return false
end

common.SortInv = function ()
    local invLocation = {}
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).count < 64 then
            turtle.select(i)
            local itemName = turtle.getItemDetail(i).name
            if invLocation[itemName] == nil then
                table.insert(invLocation,itemName)
                invLocation[itemName] = i
            else
                turtle.transferTo(invLocation[itemName])
                if turtle.getItemDetail(invLocation[itemName]).count >= 64 then
                    invLocation[itemName] = i
                end
            end
        end
    end
    turtle.select(1)
end

common.CountItem = function (material)
    local totalCount = 0
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name == material then
            totalCount = totalCount + turtle.getItemDetail(i).count
        end
    end
    return totalCount
end

common.CountSimilarItem = function (material)
    local totalCount = 0
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name:find(material,1,true) ~= nil then
            totalCount = totalCount + turtle.getItemDetail(i).count
        end
    end
    return totalCount
end

common.usedInvSlotsCount = function ()
    local count = 0
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) then
            count = count + 1
        end
    end
    return count
end 

common.PutSlab = function (slabMaterial)
    local isThereFloor, floorDetails = turtle.inspectDown()
    if isThereFloor then
        if floorDetails.name ~= slabMaterial then
            while turtle.detectDown() do
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

common.PutSlabFront = function (slabMaterial)
    local isThereFloor, wallDetails = turtle.inspect()
    if isThereFloor then
        if wallDetails.name ~= slabMaterial then
            while turtle.detect() do
                turtle.dig()
            end
            if SelectMaterialCell(slabMaterial) then
               turtle.place()
            else
                print("No material found")
            end
        end
    else
        if SelectMaterialCell(slabMaterial) then
           turtle.place()
        else
            print("No material found")
        end
    end
end

common.PutSlabUp = function (slabMaterial)
    local isThereRoof, roofDetails = turtle.inspectUp()
    if isThereRoof then
        if roofDetails.name ~= slabMaterial then
            while turtle.detectUp() do
                turtle.digUp()
            end
            if SelectMaterialCell(slabMaterial) then
               turtle.placeUp()
            else
                print("No material found")
            end
        end
    else
        if SelectMaterialCell(slabMaterial) then
           turtle.placeUp()
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

common.MoveForward = function (steps,putSlab,slabMaterial,action)
    putSlab = putSlab or false
    slabMaterial = slabMaterial or ""
    action = action or "Move"
    for i = 1, steps, 1 do
        local isItTurtleTries = 0
        while turtle.detect() do
            local isThereblock, blockDetails = turtle.inspect()
            if isThereblock and blockDetails.name:find("turtle",1,true) == nil then
                turtle.dig()
            elseif isThereblock and blockDetails.name:find("turtle",1,true) ~= nil then
                isItTurtleTries = isItTurtleTries + 1
                if isItTurtleTries > 5 then
                    common.collided = true
                    return
                end
                os.sleep(1)
            end
        end
        turtle.forward()
        if action == "Mine" then
            while turtle.detectUp() do
                turtle.digUp()
            end
        end
        if putSlab then
            common.PutSlab(slabMaterial)
        end
        if common.faceDirection == 0 then
            common.cy = common.cy - 1
        elseif common.faceDirection == 1 then
            common.cx = common.cx + 1
        elseif common.faceDirection == 2 then
            common.cy = common.cy + 1
        elseif common.faceDirection == 3 then
            common.cx = common.cx - 1
        end
    end
end

common.MoveUp = function (steps,putSlab,slabMaterial)
    for i = 1, steps, 1 do
        while turtle.detectUp() do
            local isThereblock, blockDetails = turtle.inspectUp()
            if isThereblock and blockDetails.name:find("turtle",1,true) == nil then
                turtle.digUp()
            elseif isThereblock and blockDetails.name:find("turtle",1,true) ~= nil then
                os.sleep(1)
                isThereblock, blockDetails = turtle.inspectUp()
                if isThereblock and blockDetails.name:find("turtle",1,true) ~= nil then
                  common.collided = true
                  return
                end
            end
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
            local isThereblock, blockDetails = turtle.inspectDown()
            if isThereblock and blockDetails.name:find("turtle",1,true) == nil then
                turtle.digDown()
            elseif isThereblock and blockDetails.name:find("turtle",1,true) ~= nil then
                os.sleep(1)
                isThereblock, blockDetails = turtle.inspectDown()
                if isThereblock and blockDetails.name:find("turtle",1,true) ~= nil then
                  common.collided = true
                  return
                end
            end
        end
        turtle.down()
        common.cz = common.cz - 1
    end
end

function FindLadder()
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name:find("ladder",1,true) ~= nil then
            turtle.select(i)
            break
        end
    end
end

common.MoveDownLadder = function (steps)
    FindLadder()
    for i = 1, steps, 1 do
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
        turtle.placeUp()
        common.cz = common.cz - 1
        if turtle.getItemDetail() == nil then
            FindLadder()
        end
    end
    turtle.select(1)
end

function MoveAlongX(x,putSlab,slabMaterial,action)
    if common.cx < x then
        common.TurnTurtle(1)
        common.MoveForward(x-common.cx,putSlab,slabMaterial,action)
    elseif common.cx > x then
        common.TurnTurtle(3)
        common.MoveForward(common.cx-x,putSlab,slabMaterial,action)
    end
end

function MoveAlongY(y,putSlab,slabMaterial,action)
    if common.cy < y then
        common.TurnTurtle(2)
        common.MoveForward(y-common.cy,putSlab,slabMaterial,action)
    elseif common.cy > y then
        common.TurnTurtle(0)
        common.MoveForward(common.cy-y,putSlab,slabMaterial,action)
    end
end

common.MovetoLocation = function (x,y,z,putSlab,slabMaterial,action)
    -- print ("Current location - " .. common.cx .. "/" .. common.cy .. "/" .. common.cz)
    -- print("Moving to location - " .. x .. "/" .. y .. "/" .. z)
    if common.moveAlongXFirst then
        MoveAlongX(x,putSlab,slabMaterial,action)
        MoveAlongY(y,putSlab,slabMaterial,action)
    else
        MoveAlongY(y,putSlab,slabMaterial,action)
        MoveAlongX(x,putSlab,slabMaterial,action)
    end

    if common.cz < z then
        common.MoveUp(z-common.cz)
    elseif common.cz > z then
        common.MoveDown(common.cz-z)
    end

    if common.collided then
        while common.collided do
            common.collided = false
            common.TurnTurtle((common.faceDirection + 1) % 4)
            common.MoveForward(1)
            if not common.collided then
                common.TurnTurtle((common.faceDirection - 1) % 4)
                common.MoveForward(2)
            end
        end
        common.moveAlongXFirst = not common.moveAlongXFirst
        common.MovetoLocation(x,y,z,putSlab,slabMaterial,action)
    end
end

common.CheckFuel = function (steps)
    local currentFuel = turtle.getFuelLevel()
    if steps > currentFuel then
        print("Not Enough Fuel, Please refuel and press enter. currentFuel Level - " .. currentFuel .. "/" .. steps)
        return false
    else
        --print("Steps to take - " .. steps)
        return true
    end
end

common.CalibrateTurtle = function ()
    common.cx,common.cz,common.cy = gps.locate()
    common.initialx = common.cx
    common.initialz = common.cz
    common.initialy = common.cy
    print("calibrating...")
    --print(common.initialx .. "/" .. common.initialy .. "/" .. common.initialz)
    local fuelLevel = common.CheckFuel(5)
    if not fuelLevel then
        return
    end
    local try = 1
    while true do
        local isThereblock = turtle.inspect()
        if isThereblock then
            turtle.turnRight()
            try = try + 1
        else
            break
        end
        if try > 4 then
            print("Not able to calibrate direction")
            modem.transmit(common.adminNumber, common.myNumber, "Not able to calibrate direction for turtle:" .. common.myNumber)
            return
        end
    end
    -- start calibrating direction
    turtle.forward()
    common.cx,common.cz,common.cy = gps.locate()
    --print(common.cx .. "/" .. common.cy .. "/" .. common.cz)
    if common.cx > common.initialx then
        common.faceDirection = 1
    elseif common.cx < common.initialx then
        common.faceDirection = 3
    elseif common.cy > common.initialy then
        common.faceDirection = 2
    elseif common.cy < common.initialy then
        common.faceDirection = 0
    end
    --print(common.faceDirection)
    common.MovetoLocation(common.initialx,common.initialy,common.initialz)
    if try == 1 then
      common.TurnTurtle((common.faceDirection + 2) % 4)
    elseif try == 2 then
        common.TurnTurtle((common.faceDirection + 1) % 4)
    elseif try == 4 then
        common.TurnTurtle((common.faceDirection - 1) % 4)
    end
    print(common.cx .. "/" .. common.cy .. "/" .. common.cz)
end

return common