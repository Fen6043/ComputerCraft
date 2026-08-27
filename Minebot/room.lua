cx = 0
cy = -1
cz = 0
maxx = 0
maxy = 0
maxz = 0
faceDirection = 0
putslab = true
floorMaterial = ""
roofMaterial = ""
wallMaterial = ""

--  0
-- 3 1
--  2
function Turn(toDirection)
    if faceDirection == toDirection then
        return
    end
    local turnLeftPointer = (4 + (faceDirection - 1)) % 4
    local turnRightPointer = (faceDirection + 1) % 4

    if  turnLeftPointer == toDirection then
      turtle.turnLeft()
      faceDirection = turnLeftPointer
    elseif turnRightPointer == toDirection then
      turtle.turnRight()
      faceDirection = turnRightPointer
    else
      turtle.turnRight()
      turtle.turnRight()
      faceDirection = (faceDirection + 2) % 4
    end
end

function SelectMaterialCell(toBuild)
    local noMaterialFound = true
    if toBuild == "Floor" then
        for _, value in ipairs({1,2,3,4}) do
            if turtle.getItemDetail(value) ~= nil and turtle.getItemDetail(value).name == floorMaterial then
                turtle.select(value)
                noMaterialFound = false
                break
            end
        end
    elseif toBuild == "Roof" then
        for _, value in ipairs({5,6,7,8}) do
            if turtle.getItemDetail(value) ~= nil and turtle.getItemDetail(value).name == roofMaterial then
                turtle.select(value)
                noMaterialFound = false
                break
            end
        end
    elseif toBuild == "Wall" then
        for _, value in ipairs({9,10,11,12}) do
            if turtle.getItemDetail(value) ~= nil and turtle.getItemDetail(value).name == wallMaterial then
                turtle.select(value)
                noMaterialFound = false
                break
            end
        end
    end

    if noMaterialFound then
        error("no material found")
    end

end

function PutSlab()
    if not putslab then
        return
    end

    local floorDetails , roofDetails, wallDetails

    if cz == 0 then
        _, floorDetails = turtle.inspectDown()
        if floorDetails.name ~= floorMaterial then
            while turtle.detectDown() do
                -- print("inside while 1")
                turtle.digDown()
            end
            SelectMaterialCell("Floor")
            turtle.placeDown()
        end
    elseif cz == maxz then
        _, roofDetails = turtle.inspectUp()
        if roofDetails.name ~= roofMaterial then
            while turtle.detectUp() do
                -- print("inside while 2")
                turtle.digUp()
            end
            SelectMaterialCell("Roof")
            turtle.placeUp()
        end
    end

    local tempDirection = 0
    if cx == 0 then
        tempDirection = faceDirection
        Turn(3)
        _, wallDetails = turtle.inspect()
        if wallDetails.name ~= wallMaterial then
            while turtle.detect() do
                -- print("inside while 3")
                turtle.dig()
            end
            SelectMaterialCell("Wall")
            turtle.place()
        end
        Turn(tempDirection)
    elseif cx == maxx then
        tempDirection = faceDirection
        Turn(1)
        _, wallDetails = turtle.inspect()
        if wallDetails.name ~= wallMaterial then
            while turtle.detect() do
                -- print("inside while 4")
                turtle.dig()
            end
            SelectMaterialCell("Wall")
            turtle.place()
        end
        Turn(tempDirection)
    end

    if cy == 0 then
        tempDirection = faceDirection
        Turn(2)
        _, wallDetails = turtle.inspect()
        if wallDetails.name ~= wallMaterial then
            while turtle.detect() do
                -- print("inside while 5")
                turtle.dig()
            end
            SelectMaterialCell("Wall")
            turtle.place()
        end
        Turn(tempDirection)
    elseif cy == maxy then
        tempDirection = faceDirection
        Turn(0)
        _, wallDetails = turtle.inspect()
        if wallDetails.name ~= wallMaterial then
            while turtle.detect() do
                -- print("inside while 6")
                turtle.dig()
            end
            SelectMaterialCell("Wall")
            turtle.place()
        end
        Turn(tempDirection)
    end
end

function MoveForward(steps)
    for i = 1, steps, 1 do
        while turtle.detect() do
            -- print("inside while 7")
            turtle.dig()
        end
        turtle.forward()
        if faceDirection == 0 then
            cy = cy + 1
        elseif faceDirection == 1 then
            cx = cx + 1
        elseif faceDirection == 2 then
            cy = cy - 1
        elseif faceDirection ==3 then
            cx = cx - 1
        end
        PutSlab()
    end
end

function MoveUp(steps)
    for i = 1, steps, 1 do
        while turtle.detectUp() do
            -- print("inside while 8")
            turtle.digUp()
        end
        turtle.up()
        cz = cz + 1
        PutSlab()
    end
end

function MoveDown(steps)
    for i = 1, steps, 1 do
        while turtle.detectDown() do
            -- print("inside while 9")
            turtle.digDown()
        end
        turtle.down()
        cz = cz - 1
        PutSlab()
    end
end

function MovetoLocation(x,y,z)
    if cx < x then
        Turn(1)
        MoveForward(x-cx)
    elseif cx > x then
        Turn(3)
        MoveForward(cx-x)
    end

    if cy < y then
        Turn(0)
        MoveForward(y-cy)
    elseif cy > y then
        Turn(2)
        MoveForward(cy-y)
    end

    if cz < z then
        MoveUp(z-cz)
    elseif cz > z then
        MoveDown(cz-z)
    end
end

function CreateRoom(x,y,z)
    maxx = x-1
    maxy = y-1
    maxz = z-1
    MoveForward(1)
    for i = 0, maxz, 1 do
        if i%2 == 0 then
            for j = 0, maxy, 1 do
                MovetoLocation(cx,j,i)
                if cx < maxx then
                    MovetoLocation(maxx,j,i)
                else
                    MovetoLocation(0,j,i)
                end
            end
        else
            for j = maxy, 0, -1 do
                MovetoLocation(cx,j,i)
                if cx < maxx then
                    MovetoLocation(maxx,j,i)
                else
                    MovetoLocation(0,j,i)
                end
            end
        end
    end
    putslab = false
    MovetoLocation(0,0,0)
    Turn(2)
    MoveForward(1)
end

function CheckFuel(steps)
    local currentFuel = turtle.getFuelLevel()
    if steps > currentFuel then
        return false
    else
        return true
    end
end

function BeginWorkflow()
    print("xxx---------------------------------xxx")
    print("Place floor, roof, wall materials in 1,2,3 rows respectively")
    print("xxx---------------------------------xxx")
    print("Enter Dimention(x/y/z):")
    local test = read()
    local dimention = {}

    for match in test.gmatch(test,"[^/]+") do
        table.insert(dimention,match)
    end

    local x = tonumber(dimention[1])
    local y = tonumber(dimention[2])
    local z = tonumber(dimention[3])
    if CheckFuel((x*y*z) + (x+y+z) + 1) then
        local floorOrRoof = x * y
        local walls = (2*x*z) + (2*y*z)
        local brickCount1 = turtle.getItemCount(1) + turtle.getItemCount(2) + turtle.getItemCount(3) + turtle.getItemCount(4)
        local brickCount2 = turtle.getItemCount(5) + turtle.getItemCount(6) + turtle.getItemCount(7) + turtle.getItemCount(8)
        local brickCount3 = turtle.getItemCount(9) + turtle.getItemCount(10) + turtle.getItemCount(11) + turtle.getItemCount(12)

        if brickCount1 < floorOrRoof then
            print("not enough floor tiles need " .. floorOrRoof)
            return
        elseif brickCount2 < floorOrRoof  then
            print("not enough roof tiles need " .. floorOrRoof)
            return
        elseif brickCount3 < walls then
            print("not enough wall tiles need " .. walls)
            return
        end

        floorMaterial = turtle.getItemDetail(1).name
        roofMaterial = turtle.getItemDetail(5).name
        wallMaterial = turtle.getItemDetail(9).name

        CreateRoom(x,y,z)
    else
        print("not enough fuel")
    end
end

local success,err = pcall(BeginWorkflow)

if not success then
    print(err)
end