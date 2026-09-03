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

    local putSlab = false
    local slabMaterial = ""
    local x = tonumber(dimention[1]) or 0
    local y = tonumber(dimention[2]) or 0
    local z = tonumber(dimention[3]) or 0
    local xdirection = 1
    local ydirection = 0

    if not CTL.CheckFuel(((x) * (y) * math.ceil((z)/2)) + (2 * depth) + (x + y + z - 3)) then
        return
    end

    print("Create ladder(y/n)" .. "[" .. (depth) .. " nos]".. ":")
    local ladder = read()
    print("Create floor(y/n)" .. "[" .. ((x) * (y)) .. " tiles]".. ":")
    local floor = read()

    if floor == "y" then
        putSlab = true
        while not turtle.getItemDetail(1) do
            print("Keep slab material in slot 1 and press enter")
            read()
        end
        slabMaterial = turtle.getItemDetail(1).name

        -- Check floor count
        local needItemCount = x * y
        local invItemCount = CTL.CountItem(slabMaterial)
        while (invItemCount < needItemCount) do
            print("Insufficient floor tiles" .. invItemCount .. "/" .. needItemCount)
            read()
            invItemCount = CTL.CountItem(slabMaterial)
        end
    end

    if ladder == "y" then
        while true do
            if turtle.getItemDetail(2) ~= nil and turtle.getItemDetail(2).name:find("ladder",1,true) ~= nil then
                break
            end
            print("Keep ladder in slot 2 and press enter")
            read()
        end

        -- Check ladder count
        local needItemCount = depth
        local invItemCount = CTL.CountSimilarItem("ladder")
        while (invItemCount < needItemCount) do
            print("Insufficient ladder " .. invItemCount .. "/" .. needItemCount)
            read()
            invItemCount = CTL.CountSimilarItem("ladder")
        end
    end

    if ladder == "y" then
        CTL.MoveDownLadder(depth)
    else
        CTL.MoveDown(depth)
    end

    local action = "Move"

    if z > 1 then
        action = "Mine"
    end

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

    -- come back
    if ladder ~= "y" then
        CTL.MovetoLocation(0,0,0)
    end
    CTL.TurnTurtle(0)
end

Mine()