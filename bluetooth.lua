function listenAT()
    uart.alt(0)
    uart.setup(0, 38400, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    uart.on("data", "\n", function(data)
            print("uart: "..data)
    end, 0)
end

function listenNormal()
    uart.alt(0)
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    uart.on("data", "\n", function(data)
            print("uart: "..data)
    end, 0)
end

function writeSerial(s)
    uart.write(0, s.."\r\n")
end