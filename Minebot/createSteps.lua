commonlib = require("commonTurtlelib")
floorMaterial = ""
putSlab = false

function CreateSlope(stepLength,stepWidth,stepHeight)
    local pointer1 = 0
    local pointer2 = 1
    local nexty = 0
    commonlib.MoveForward(1,putSlab,floorMaterial)
    commonlib.cy = 0
    print("Begin - " .. commonlib.cx .. " " .. commonlib.cy .. " " .. commonlib.cz)
    for i = 1, stepHeight, 1 do
        for j = 1, stepHeight * stepWidth, 1 do
            commonlib.TurnTurtle(pointer2)
            pointer2 = (pointer2 + 2) % 4
            commonlib.MoveForward(stepLength - 1, putSlab, floorMaterial)

            if j ~= stepHeight * stepWidth then
                commonlib.TurnTurtle(pointer1)
                if pointer1 == 0 then
                    nexty = commonlib.cy + 1
                else
                    nexty = commonlib.cy - 1
                end
                if nexty >= stepWidth * (i - 1) and floorMaterial ~= "" then
                    putSlab = true
                else
                    putSlab = false
                end

                commonlib.MoveForward(1, putSlab, floorMaterial)
            end
        end

        if i ~= stepHeight then
            commonlib.MoveUp(1,putSlab,floorMaterial)
            pointer1 = (pointer1 + 2) % 4
        end
    end
    print(commonlib.cx .. " " .. commonlib.cy .. " " .. commonlib.cz)
    commonlib.MovetoLocation(0,0,0)
end

function BeginWorkflow()
    local stepLength
    local stepWidth
    local stepHeight
    local inputTable = {}
    print("Note: Add floor material in cell 1 if needed")
    print("Enter slopes length(x)/width(y)/height(z):")
    local input = read()
    for match in input.gmatch(input,"[^/]+") do
        table.insert(inputTable,match)
    end
    stepLength = tonumber(inputTable[1])
    stepWidth = tonumber(inputTable[2])
    stepHeight = tonumber(inputTable[3])

    if turtle.getItemDetail(1) ~= nil then
       floorMaterial = turtle.getItemDetail(1).name
       putSlab = true
    end

    print(floorMaterial)
    local fuelNeeded = (stepLength * stepWidth * stepHeight) + (stepWidth * stepHeight) + (stepHeight - 1) + (stepLength + ( stepWidth * stepHeight ) +(stepHeight - 1))
    if commonlib.CheckFuel(fuelNeeded) then
        -- print(stepLength .. stepWidth .. stepHeight)
        CreateSlope(stepLength,stepWidth,stepHeight)
    else
        return
    end
end

local success,err = pcall(BeginWorkflow)

if not success then
    print("Error occured: ",err)
end