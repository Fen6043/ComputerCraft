local turtleV = 12
local pocketV = 6
local modem = peripheral.find("modem")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local monitor = peripheral.find("monitor")
    term.redirect(monitor)   
    print(".............................")
    print("channel:" .. channel .. " replyChannel:" .. replyChannel .. " message:" .. message .. " distance:" .. distance)
    if channel == os.getComputerID() then
        if message == "#getVersionTurtle" then
            modem.transmit(replyChannel, channel, turtleV)
        elseif message == "#getVersionPocket" then
            modem.transmit(replyChannel, channel, pocketV)
        end
    end
end
