local CTL = require("commonTurtlelib")
local modem = peripheral.find("modem")
local args = {...}

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

function SendMessageToAdmin(mode)
    local message = ""
    if mode == "manualMode" then
        message = "#Exit"
    else
        message = "#Working"
    end
    for _, value in ipairs(CTL.adminNumber) do
        modem.transmit(value, CTL.myNumber, message)
    end
end

function CreateRoom()
    print("---------------------------------------")
    print("Are you expanding the room(y/n):")
    local expand = args[1] or read()
    local walls = "tblr" -- Top Bottom Left Right
    if expand == "y" then
        while true do
            print("---------------------------------------")
            print("enter the walls[t - Top,b - Bottom,l - Left,r - Right] to create like[tblr,rbl..] :")
            walls = args[2] or read()
            if walls:match("^[tblr]*$") ~= nil and #walls < 5 then
                break
            end
        end
    end
    print("---------------------------------------")
    print("Enter depth :")
    local input = arg[3] or read()
    if not tonumber(input) then
        print("invalid input")
        return
    end
    local depth = tonumber(input)
    print("---------------------------------------")
    print("Enter dimention as x/y/z :")
    input = arg[4] or read()
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
    local invItemCount = 0

    while not CTL.CheckFuel((x* y * z) + (2 * depth) + (x + y + z - 3)) do
        read()
        shell.run("refuel")
    end

    print("---------------------------------------")
    print("PLEASE KEEP FLOOR,WALL,ROOF MATERIALS IN SLOT 1,2,3 RESPECTIVELY")
    print("---------------------------------------")
    read()
    --#Start Sets/Checks the material to be used and its count
    --Floor
    local floorItemCount = 0
    print("Change Floor Material(y/n):")
    local putFloor = read()
    if putFloor == "y" then
        floorItemCount = x * y
        while not turtle.getItemDetail(1) do
            print("Keep floormaterial in slot 1 and press enter")
            read()
        end
        floormaterial = turtle.getItemDetail(1).name
        invItemCount = CTL.CountItem(floormaterial)
        while (invItemCount < floorItemCount) do
            print("Insufficient floormaterial " .. invItemCount .. "/" .. floorItemCount)
            read()
            invItemCount = CTL.CountItem(floormaterial)
        end
    end
    

    --Wall
    local wallItemCount = 0
    print("Change Wall Material(y/n):")
    local putWall = read()
    if putWall == "y" then
        if #walls > 0 then
            while not turtle.getItemDetail(2) do
                print("Keep wallmaterial in slot 2 and press enter")
                read()
            end
            wallmaterial = turtle.getItemDetail(2).name
            if wallmaterial == floormaterial then
                wallItemCount = floorItemCount
            end
            -- counting wallmaterial
            for c in walls:gmatch(".") do
                if c == "t" or c == "b" then
                    wallItemCount = wallItemCount + (x * z)
                else
                    wallItemCount = wallItemCount + (y * z)
                end
            end

            invItemCount = CTL.CountItem(wallmaterial)
            while (invItemCount < wallItemCount) do
                print("Insufficient wallmaterial " .. invItemCount .. "/" .. wallItemCount)
                read()
                invItemCount = CTL.CountItem(wallmaterial)
            end
        end
    end

    --Roof
    print("Change Roof Material(y/n):")
    local putRoof = read()
    if putRoof == "y" then
        local roofItemCount = 0
        while not turtle.getItemDetail(3) do
            print("Keep roofmaterial in slot 3 and press enter")
            read()
        end
        roofmaterial = turtle.getItemDetail(3).name
        if roofmaterial == wallmaterial then
            roofItemCount = wallItemCount
        elseif roofmaterial == floormaterial then
            roofItemCount = floorItemCount
        end
        roofItemCount = roofItemCount + x * y
        invItemCount = CTL.CountItem(roofmaterial)
        while (invItemCount < roofItemCount) do
            print("Insufficient roofmaterial " .. invItemCount .. "/" .. roofItemCount)
            read()
            invItemCount = CTL.CountItem(roofmaterial)
        end
    end
    --#End

    local mode = arg[5] or "manualMode"
    if modem ~= nil then
        SendMessageToAdmin(mode)
    end

    CTL.MoveDown(depth)
    local leftpoint = CTL.cx
    local rightpoint= CTL.cx + x - 1
    local bottompoint = CTL.cy
    local toppoint = (CTL.cy + y - 1) * -1 -- Top y point will be negative due to trash coordinate system in minecraft

    for k = 1, z, 1 do
        for j = 1, x, 1 do
            if xdirection == 1 then -- Sets Starting position after each y movement
                CTL.MovetoLocation(j-1,CTL.cy,CTL.cz)
            else
                CTL.MovetoLocation(x-j,CTL.cy,CTL.cz)
            end

            for i = 1, y, 1 do
                if k == 1 and putFloor == 'y' then
                    CTL.PutSlab(floormaterial)
                end

                if k == z and putRoof == 'y' then
                    CTL.PutSlabUp(roofmaterial)
                end
                --print(CTL.cy .. " " .. toppoint)
                if putWall == 'y' then
                    if CTL.cy == bottompoint and walls:find("b") ~= nil then
                        CTL.TurnTurtle(2)
                        CTL.PutSlabFront(wallmaterial)
                    elseif CTL.cy == toppoint and walls:find("t") ~= nil then
                        CTL.TurnTurtle(0)
                        CTL.PutSlabFront(wallmaterial)
                    end
                
                    if CTL.cx == leftpoint and walls:find("l") ~= nil then
                        CTL.TurnTurtle(3)
                        CTL.PutSlabFront(wallmaterial)
                    elseif CTL.cx == rightpoint and walls:find("r") ~= nil then
                        CTL.TurnTurtle(1)
                        CTL.PutSlabFront(wallmaterial)
                    end
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