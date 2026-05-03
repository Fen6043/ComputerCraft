CTL = require("commonTurtlelib")

function Mine()
    print("Enter depth :")
    local input = read()
    if not tonumber(input) then
        print("invalid input")
        return
    end
    local depth = tonumber(input)

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

    local x = tonumber(dimention[1])
    local y = tonumber(dimention[2])
    local z = tonumber(dimention[3])
    local xdirection = 1
    local ydirection = 0

    CTL.CheckFuel((x * y * z) + (2 * depth) + (x + y))

    CTL.MoveDown(depth)
    
    for j = 0, z, 1 do
        for i = 0, x, 1 do
            if ydirection == 0 and xdirection == 1 then
                CTL.MovetoLocation(i,y,CTL.cz)
            elseif ydirection == 2 and xdirection == 1 then
                CTL.MovetoLocation(i,0,CTL.cz)
            elseif ydirection == 0 and xdirection == 3 then
                CTL.MovetoLocation(x-i,y,CTL.cz)
            else
                CTL.MovetoLocation(x-i,0,CTL.cz)
            end
            ydirection = (ydirection + 2) % 4
        end

        if j ~= z then
            CTL.MoveUp(1)
            xdirection = (xdirection + 2) % 4
        end
    end

    -- come back
    CTL.MovetoLocation(0,0,0)
    CTL.TurnTurtle(0)
end

Mine()