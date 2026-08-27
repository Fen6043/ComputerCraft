while true do
    while turtle.detect() do
        turtle.dig()
    end
    while turtle.detectUp() do
        turtle.digUp()
    end
    turtle.forward()
end
