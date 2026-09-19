local monitor = peripheral.find("monitor")
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write("Hello, world!")
monitor.setCursorPos(1, 2)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local displayMessage = (("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
        side, channel, replyChannel, distance, tostring(message)
    ))
    monitor.write(#displayMessage)
    local _,y = monitor.getCursorPos()
    monitor.setCursorPos(1, y)
end