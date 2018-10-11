local segdisp = {}

--               a b c d e f g h
segdisp.pins = { 0,1,2,3,5,6,7,8 }

function segdisp.initDisplay()
    for _,pin in pairs(segdisp.pins) do
        gpio.mode(pin,gpio.OUTPUT)
    end
end

function segdisp.showDigit(n)
    local translation = {
        --     abcdefgh
        [0] = "11111100",
        [1] = "01100000",
        [2] = "11011010",
        [3] = "11110010",
        [4] = "01100110",
        [5] = "10110110",
        [6] = "10111110",
        [7] = "11100000",
        [8] = "11111110",
        [9] = "11110110",
    }
    local code = translation[n]
    for i=1,8,1 do
        gpio.write(segdisp.pins[i],code:sub(i,i))
    end
end

return segdisp