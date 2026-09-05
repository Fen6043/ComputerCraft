local modem = peripheral.find("modem")
local myNumber = os.getComputerID()
modem.open(myNumber)

local id = shell.openTab("getMessage.lua")
multishell.setTitle(id, "Message")
shell.run("Turtle")