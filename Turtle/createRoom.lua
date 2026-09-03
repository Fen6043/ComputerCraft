local CTL = require("commonTurtlelib")

function RemoveTrash(floormaterial,wallmaterial,roofmaterial)
    local trashMaterials = {["minecraft:cobblestone"] = true,["minecraft:blackstone"] = true,["minecraft:cobbled_deepslate"] = true,["minecraft:gravel"] = true,["minecraft:tuff"] = true,["minecraft:dirt"] = true}
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) then
            if trashMaterials[turtle.getItemDetail(i).name] and turtle.getItemDetail(i).name ~= floormaterial and turtle.getItemDetail(i).name ~= wallmaterial and turtle.getItemDetail(i).name ~= roofmaterial then
                turtle.select(i)
                turtle.dropDown()
            end
        end
    end
    CTL.SortInv()
end

function CreateRoom()
    print("---------------------------------------")
    print("PLEASE KEEP FLOOR,WALL,ROOF MATERIALS IN SLOT 1,2,3 RESPECTIVELY")
    print("---------------------------------------")
    print("Are you expanding the room(y/n):")
    local expand = read()
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

    local floormaterial = ""
    local wallmaterial = ""
    local roofmaterial = ""
    local x = tonumber(dimention[1]) or 0
    local y = tonumber(dimention[2]) or 0
    local z = tonumber(dimention[3]) or 0
    local xdirection = 1
    local ydirection = 0
    local needItemCount = 0
    local invItemCount = 0

    if not CTL.CheckFuel(((x+1) * (y+1) * (z+1)) + (2 * depth) + (x + y + z)) then
        return
    end

    while not turtle.getItemDetail(1) do
        print("Keep floormaterial in slot 1 and press enter")
        read()
    end
    floormaterial = turtle.getItemDetail(1).name
    needItemCount = ((x+1) * (y+1))
    invItemCount = CTL.CountItem(floormaterial)
    while (invItemCount < needItemCount) do
        print("Insufficient floormaterial " .. invItemCount .. "/" .. needItemCount)
        read()
        invItemCount = CTL.CountItem(floormaterial)
    end

    while not turtle.getItemDetail(2) do
        print("Keep wallmaterial in slot 2 and press enter")
        read()
    end
    wallmaterial = turtle.getItemDetail(2).name
    needItemCount = ((2 * ((x+1) * (z+1))) + (2 * ((y+1) * (z+1))))
    invItemCount = CTL.CountItem(wallmaterial)
    while (invItemCount < needItemCount) do
        print("Insufficient wallmaterial " .. invItemCount .. "/" .. needItemCount)
        read()
        invItemCount = CTL.CountItem(wallmaterial)
    end

    while not turtle.getItemDetail(3) do
        print("Keep roofmaterial in slot 3 and press enter")
        read()
    end
    roofmaterial = turtle.getItemDetail(3).name
    needItemCount = ((x+1) * (y+1))
    invItemCount = CTL.CountItem(roofmaterial)
    while (invItemCount < needItemCount) do
        print("Insufficient roofmaterial " .. invItemCount .. "/" .. needItemCount)
        read()
        invItemCount = CTL.CountItem(roofmaterial)
    end

    CTL.MoveDown(depth)

    for k = 0, z, 1 do
        for j = 0, x, 1 do
            if xdirection == 1 then
                CTL.MovetoLocation(j,CTL.cy,CTL.cz)
            else
                CTL.MovetoLocation(x-j,CTL.cy,CTL.cz)
            end

            for i = 0, y, 1 do
                if k == 0 then
                    CTL.PutSlab(floormaterial)
                end

                if k == z then
                    CTL.PutSlabUp(roofmaterial)
                end

                if CTL.cy == 0 and expand ~= 'y' then
                    CTL.TurnTurtle(2)
                    CTL.PutSlabFront(wallmaterial)
                elseif CTL.cy == y then
                    CTL.TurnTurtle(0)
                    CTL.PutSlabFront(wallmaterial)
                end

                if CTL.cx == 0 then
                    CTL.TurnTurtle(3)
                    CTL.PutSlabFront(wallmaterial)
                elseif CTL.cx == x then
                    CTL.TurnTurtle(1)
                    CTL.PutSlabFront(wallmaterial)
                end
                CTL.TurnTurtle(ydirection)

                if i ~= y then
                    CTL.MoveForward(1)
                end
            end
            ydirection = (ydirection + 2) % 4
            if CTL.usedInvSlotsCount() > 13 then
                RemoveTrash(floormaterial,wallmaterial,roofmaterial)
            end
            
        end

        if k < z then
            CTL.MoveUp(1)
            xdirection = (xdirection + 2) % 4
        end
    end

    -- come back
    CTL.MovetoLocation(0,0,0)
    CTL.TurnTurtle(0)
end

CreateRoom()