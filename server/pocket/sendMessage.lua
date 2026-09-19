local modem = peripheral.find("modem") or error("No modem attached", 0)
local myNumber = os.getComputerID()
local cx,cz,cy = gps.locate()
cx = math.floor(cx)
cy = math.floor(cy)
cz = math.floor(cz) - 1
print("location - " .. cx .. "/" .. cy .. "/" .. cz)
print("To Number:")
local toNumber = tonumber(read()) or error("not a number",0)
print("Message:")
local message = read()
-- Send our message
modem.transmit(toNumber, myNumber, message)