-- Return a letter's position in the alphabet
function chartonum(char)
    local r = string.find("abcdefghijklmnopqrstuvwxyz", char:lower())
    if r == nil then r = -1 end
    return r
end

-- Utility function to compare strings
function strcmp(s1,s2)
    local length = s1:len()
    if s2:len() < length then 
        length = s2:len()
    end
    for i = 1,length,1 do
        local i1 = chartonum(s1:sub(i,i))
        local i2 = chartonum(s2:sub(i,i))
        if i1 < i2 then
            return true
        elseif i1 > i2 then
            return false
        end
    end
    return s1:len() < s2:len()
end

-- Writes the pattern (of 0 and 1) to the led pin a specified number of times,
-- with "speed" being the ms of each char in the pattern.
function blinkPattern(times,pattern,speed)
    speed = speed or 250
    local count = 0
    local point = 1
    local max = pattern:len()
    gpio.mode(PIN_LED,gpio.OUTPUT)
    gpio.write(PIN_LED,1)
    local blinkTimer = tmr.create()
    blinkTimer:alarm(speed, tmr.ALARM_AUTO, function(t)
        gpio.write(PIN_LED,pattern:sub(point,point))
        point = point+1
        if point > max then
            point = 1
            count = count + 1
        end
        if count >= times then
            t:stop()
        end
    end)
end

-- Loads a file per HTTP request from the specified server to the specified local path.do
-- Ex.: 192.168.0.15/nodemcu/start.lua -> loadFile("192.168.0.15", "/nodemcu/start.lua", "foo.lua")
function loadFile(serverip, remotepath, localpath)
    local fullpath = "http://"..serverip..remotepath
    local conn = net.createConnection(net.TCP, 0)
    local contentLength = 0
    conn:on("receive", function(sck,c)
        --print("received answer of length "..c:len())
        local httpline = c:match("HTTP/1.1 %d+")
        local hasHeader = (httpline ~= nil)
        if hasHeader then
            local index = string.find(c, "\r\n\r\n")
            if index then
                local header = string.sub(c, 1, index-1)
                --print("httpline", httpline)
                local httpcode = httpline:sub(10,12)
                if httpcode ~= "200" then
                    print("Error: Received http code "..httpcode..".")
                    return
                end
                local contentLine = header:sub(-8) --TODO: EXTREMELY BAD!!! However, matching doesn't work
                --print("contentline", contentLine)
                contentLength = contentLine:match("%d+")

                local f = file.open(localpath, "w")
                local content = string.sub(c, index+4)
                contentLength = contentLength - content:len()
                f:write(content)
                f:close()
                --print("remaining content length: "..contentLength)
                if contentLength <= 0 then
                    print("Saved full file at "..localpath)
                    sck:close()
                end
            else
                print("No separating \\r\\n between header and content found.")
            end
        else
            local f = file.open(localpath, "a+")
            f:write(c)
            f:close()
            contentLength = contentLength - c:len()
            print("remaining content length: "..contentLength)
        end
    end)
    conn:on("connection", function(sck,c) conn:send("GET "..remotepath.." HTTP/1.1\r\nHost: "..serverip.."\r\nAccept: */*\r\n\r\n") end)
    conn:connect(80, serverip)
end

function sort(obj)
    local array = {}
    for k,v in pairs(obj) do
        array[#array + 1] = {key = k, value = v}
    end
    table.sort(array, function(a,b) return strcmp(a.key, b.key) end)
    return array
end

-- Prints all files with their size
function ls()
    l = sort(file.list())
    for _,entry in pairs(l) do
        local k = entry.key
        local v = entry.value
        local fill = string.rep(".", 32 - k:len() + 6 - tostring(v):len())
        print(k..fill..v)
    end
end

-- Removes all files except init.lua
function clearFiles()
    local l = file.list()
    for k,_ in pairs(l) do
        if k ~= "init.lua" then
            file.remove(k)
        end
    end
end

-- Prints a file
function cat(path)
    local f = file.open(path, "r")
    while true do
        local line = f:readline()
        if line == nil then break end
        print(line:sub(0,-2))
    end
    f:close()
end