local myNumber = os.getComputerID()
print("MessageList:")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local stringMessage = tostring(message)
    if channel == myNumber and stringMessage:find("#") == nil then
        print(stringMessage)
    end
end