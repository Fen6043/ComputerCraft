local myNumber = os.getComputerID()
local randomColor = 1
term.setCursorPos(1,2)
print("MessageList:")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local stringMessage = tostring(message)
    randomColor = math.random(1, 15)
    if channel == myNumber and stringMessage:find("#") == nil then
        if stringMessage:find("Mining starting") then
            term.setTextColor(colors.yellow)
        elseif stringMessage:find("Mining completed") then
            term.setTextColor(colors.green)
        else
            term.setTextColor(colors.white)
        end
        print(stringMessage)
    end
end