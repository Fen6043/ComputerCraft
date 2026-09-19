local args = {...}
local modem = peripheral.find("modem") or error("No modem attached", 0)
-- print("args[1]:" .. args[1])

local CTL = require("commonTurtlelib")

function SendMessageToAdmin(message)
    for _, value in ipairs(CTL.adminNumber) do
        modem.transmit(value, CTL.myNumber, message)
    end
end

function RemoveTrash(slabMaterial)
    local trashMaterials = {["minecraft:cobblestone"] = true,["minecraft:blackstone"] = true,["minecraft:cobbled_deepslate"] = true
    ,["minecraft:gravel"] = true,["minecraft:tuff"] = true,["minecraft:dirt"] = true,["minecraft:calcite"] = true,
    ["create:limestone"] = true,["minecraft:diorite"] = true,["minecraft:andesite"] = true}
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

    while not CTL.CheckFuel(((x) * (y) * math.ceil((z)/2)) + (x + y + z - 3)) do
        SendMessageToAdmin("Not Enough Fuel for turtle:" .. CTL.myNumber)
        read()
        shell.run("refuel")
    end

    if floor == "y" then
        putSlab = true
        -- Just to give a chance to change the block in slot 1 as while moving to position there is a chance slot 1 will be occupied
        repeat
            print("Keep slab material in slot 1 and press enter")
            SendMessageToAdmin("Keep slab material in turtle:" .. CTL.myNumber)
            read()
        until turtle.getItemDetail(1) ~= nil
        slabMaterial = turtle.getItemDetail(1).name

        -- Check floor count
        local needItemCount = x * y
        local invItemCount = CTL.CountItem(slabMaterial)
        while (invItemCount < needItemCount) do
            print("Insufficient floor tiles" .. invItemCount .. "/" .. needItemCount)
            SendMessageToAdmin("Insufficient floor tiles in turtle:" .. CTL.myNumber)
            read()
            invItemCount = CTL.CountItem(slabMaterial)
        end
    end

    local action = "Move"

    if z > 1 then
        action = "Mine"
    end
    SendMessageToAdmin("Mining starting for turtle:" .. CTL.myNumber)
    CTL.moveAlongXFirst = true -- Reset moveAlongXFirst to true before starting the mining operation
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
    SendMessageToAdmin("Mining completed for turtle:" .. CTL.myNumber)
end

Mine()