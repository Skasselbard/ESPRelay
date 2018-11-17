-- here you can initialize an event loop

counter = 1
local loop = {}
loop.gas = function()
    line = ""
    for i = 1, counter +1 do 
        line = line.."la"
    end
    print(line)
    counter = (counter +1)%5
end

return loop