local args = {...}
-- print("args[1]:" .. args[1])

local CTL = require("commonTurtlelib")

function RemoveTrash(slabMaterial)
    local trashMaterials = {["minecraft:cobblestone"] = true,["minecraft:blackstone"] = true,["minecraft:cobbled_deepslate"] = true
    ,["minecraft:gravel"] = true,["minecraft:tuff"] = true,["minecraft:dirt"] = true,["minecraft:calcite"] = true,
    ["create:limestone"] = true,["minecraft:diorite"] = true}
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) then
            if trashMaterials[turtle.getItemDetail(i).name] and turtle.getItemDetail(i).name ~= slabMaterial then
                turtle.select(i)
                turtle.dropDown()
            end
        end
    end
    CTL.SortInv()
end

function Mine()
    local argSplit = {}

    for i in string.gmatch(args[1],"[^/]+") do
        table.insert(argSplit,i)
    end

    if not (tonumber(argSplit[1]) and tonumber(argSplit[2]) and tonumber(argSplit[3])) then
        print("invalid input")
        return
    end

    local putSlab = false
    local slabMaterial = ""
    local x = tonumber(argSplit[1]) or 0
    local y = tonumber(argSplit[2]) or 0
    local z = tonumber(argSplit[3]) or 0
    local floor = argSplit[4] or "n"
    local xdirection = 1
    local ydirection = 0
    local modem = peripheral.find("modem") or error("No modem attached", 0)
    local myNumber = os.getComputerID()

    if not CTL.CheckFuel(((x) * (y) * math.ceil((z)/2)) + (x + y + z - 3)) then
        modem.transmit(CTL.adminNumber, myNumber, "Not Enough Fuel for turtle:" .. myNumber)
        return
    end

    if floor == "y" then
        putSlab = true
        while not turtle.getItemDetail(1) do
            print("Keep slab material in slot 1 and press enter")
            modem.transmit(CTL.adminNumber, myNumber, "Keep slab material in turtle:" .. myNumber)
            read()
        end
        slabMaterial = turtle.getItemDetail(1).name

        -- Check floor count
        local needItemCount = x * y
        local invItemCount = CTL.CountItem(slabMaterial)
        while (invItemCount < needItemCount) do
            print("Insufficient floor tiles" .. invItemCount .. "/" .. needItemCount)
            modem.transmit(CTL.adminNumber, myNumber, "Insufficient floor tiles in turtle:" .. myNumber)
            read()
            invItemCount = CTL.CountItem(slabMaterial)
        end
    end

    local action = "Move"

    if z > 1 then
        action = "Mine"
    end

    modem.transmit(CTL.adminNumber, myNumber, "Mining starting for turtle:" .. myNumber)

    for j = 1, z, 2 do
        for i = 1, x, 1 do
            if i == 1 then -- Edge case
                if j+1 <= z then
                    turtle.digUp()
                end
                if putSlab then
                    CTL.PutSlab(slabMaterial)
                end
            end
-- Y need to be negative because of trash coordinate system in minecraft
            if ydirection == 0 and xdirection == 1 then
                CTL.MovetoLocation(i-1,(y-1) * -1,CTL.cz,putSlab,slabMaterial,action)
            elseif ydirection == 2 and xdirection == 1 then
                CTL.MovetoLocation(i-1,0,CTL.cz,putSlab,slabMaterial,action)
            elseif ydirection == 0 and xdirection == 3 then
                CTL.MovetoLocation(x-i,(y-1) * -1,CTL.cz,putSlab,slabMaterial,action)
            else
                CTL.MovetoLocation(x-i,0,CTL.cz,putSlab,slabMaterial,action)
            end
            ydirection = (ydirection + 2) % 4
            if CTL.usedInvSlotsCount() > 13 then
                RemoveTrash(slabMaterial)
            end
        end

        if j + 1 < z then
            CTL.MoveUp(2)
            xdirection = (xdirection + 2) % 4
            putSlab = false
            if j + 2 == z then
                action = "Move"
            end
        end
    end

    CTL.MovetoLocation(0,0,0)
    CTL.TurnTurtle(0)
    modem.transmit(CTL.adminNumber, myNumber, "Mining completed for turtle:" .. myNumber)
end

Mine()