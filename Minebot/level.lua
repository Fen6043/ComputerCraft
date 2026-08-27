doFloor = "N"
cz = 1
replaceMaterial = ""

function SelectMaterialCell()
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) ~= nil and turtle.getItemDetail(i).name == replaceMaterial then
            turtle.select(i)
            return true
        end
    end
    return false
end

function MoveForward(steps)
    for i = 1, steps, 1 do
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()
        print(doFloor .. " " .. cz .. " " .. replaceMaterial)
        if ((doFloor == "Y" or doFloor == "y") and cz == 1) then
            local getResult = SelectMaterialCell()
            if getResult then
                turtle.digDown()
                turtle.placeDown() 
            end
        end
    end
end

function MoveUp(steps)
    for i = 1, steps, 1 do
        while turtle.detectUp() do
            turtle.digUp()
        end
        turtle.up()
    end
end

function MoveDown(steps)
    for i = 1, steps, 1 do
        while turtle.detectDown() do
            turtle.digDown()
        end
        turtle.down()
    end
end
--  0
-- 3 1
--  2
function Turn(currentDirection, toDirection)
    if currentDirection == toDirection then
        return currentDirection
    end
    local turnLeftPointer = (4 + (currentDirection - 1)) % 4
    local turnRightPointer = (currentDirection + 1) % 4
    
    if  turnLeftPointer == toDirection then
      turtle.turnLeft()
      currentDirection = turnLeftPointer
    elseif turnRightPointer == toDirection then
      turtle.turnRight()
      currentDirection = turnRightPointer
    else
      turtle.turnRight()
      turtle.turnRight()
      currentDirection = (currentDirection + 2) % 4
    end

    return currentDirection
end

function CheckFuel(steps)
    local currentFuel = turtle.getFuelLevel()
    if steps > currentFuel then
        return false
    else
        return true
    end
end

function StartWork(x,y,z)
    local pointer1 = 0
    local pointer2 = 1
    local lookPointer = 0
    MoveForward(1)
    for j = 1, z, 1 do
        cz = j
        for i = 1, y, 1 do
            if i ~= 1 then
                MoveForward(1)
            end
            if x ~= 1 then
                lookPointer = Turn(lookPointer,pointer2)
                pointer2 = (pointer2 + 2) % 4
                MoveForward(x-1)
            end
            lookPointer = Turn(lookPointer,pointer1)
        end
        pointer1 = (pointer1 + 2) % 4
        if j ~= z then
            print(j,z)
            MoveUp(1)
        end
    end
    MoveDown(z-1)
end

function Begin()
    print("Enter Dimention(x/y/z):")
    local test = read()
    print("Do I need to replace floor(Y/N):")
    print("(If Y then please put the item to be replaced in cell 1)")
    doFloor = read()

    if doFloor == "Y" or doFloor == "y" then
        replaceMaterial = turtle.getItemDetail(1).name
    end

    local dimention = {}

    for match in test.gmatch(test,"[^/]+") do
        table.insert(dimention,match)
    end
    if CheckFuel(tonumber((dimention[1] * dimention[2] * dimention[3]) + 1 + dimention[3])) then
        StartWork(tonumber(dimention[1]),tonumber(dimention[2]),tonumber(dimention[3]))
    else
        print("not enough fuel")
    end
end

local success,err = pcall(Begin)

if not success then
    print("Invalid input",err)
end