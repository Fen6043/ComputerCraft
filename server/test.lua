local timer_id = os.startTimer(2)
local event, id
while true do
    event, id = os.pullEvent("timer")
    print("Timer with ID " .. id .. " was fired")
end