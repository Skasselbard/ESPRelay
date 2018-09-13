print("Successfully loaded postinit.lua")

function listFiles()
    l = file.list()
    for k,v in pairs(l) do
        print(k.."    "..v)
    end
end

function setServer(s)
    local f = file.open("server", "w")
    f:write(s)
    f:close()
end

function blink(n)
    gpio.mode(4,gpio.OUTPUT)
    gpio.write(4,1)
    local blinkCounter = 0
    local blinkTimer = tmr.create()
    blinkTimer:alarm(100, tmr.ALARM_AUTO, function(t)
        gpio.write(4,blinkCounter % 2)
        blinkCounter = blinkCounter + 1
        if blinkCounter >= 2*n then
            t:unregister()
        end
    end)
end

blink(5)

function loadModules()
    local serverip = getServerOrFallback()
    local f = file.open("modules", "r")
    if f then
        local line = nil
        while true do
            line = f:readline()
            if line == nil then
                break
            end
            local ind = line:find("\n")
            if ind then
                line = line:sub(0, ind-1)
            end
            line = tostring(line)
            loadModule(tostring(serverip), "/nodemcu/"..line..".lua", line, function(name) print("Loaded module \""..name.."\"") end)
        end
        f:close()
    end
end

loadModules()