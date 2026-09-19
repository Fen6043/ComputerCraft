for i = 1, 16, 1 do
    turtle.select(i)
    turtle.refuel()
end
print(turtle.getFuelLevel())
