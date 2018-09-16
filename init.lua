function getSetting(name)
    local f = file.open("settings/"..name, "r")
    if f == nil then
        return nil
    end
    local res = f:readline()
    f:close()
    return res
end

function setSetting(key,value)
    local f = file.open("settings/"..key, "w")
    if f ~= nil then
        f:write(value)
        f:close()
    else
        print("Error while setting property")
    end
end

function chartonum(char)
    local r = string.find("abcdefghijklmnopqrstuvwxyz", char:lower())
    if r == nil then r = -1 end
    return r
end

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

function listFiles()
    l = file.list()
    for k,v in pairs(l) do
        print(k,v)
    end
end

function clearFiles()
    local l = file.list()
    for k,_ in pairs(l) do
        if k ~= "init.lua" then
            file.remove(k)
        end
    end
end

function cat(path)
    local f = file.open(path, "r")
    while true do
        local line = f:readline()
        if line == nil then break end
        print(line:sub(0,-1))
    end
    f:close()
end

function blinkPattern(times,pattern,speed)
    speed = speed or 1000
    local count = 0
    local point = 1
    local max = pattern:len()
    gpio.mode(4,gpio.OUTPUT)
    gpio.write(4,1)
    local blinkTimer = tmr.create()
    blinkTimer:alarm(speed, tmr.ALARM_AUTO, function(t)
        gpio.write(4,pattern:sub(point,point))
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
            f:writeline(c)
            f:close()
            contentLength = contentLength - c:len()
            print("remaining content length: "..contentLength)
        end
    end)
    conn:on("connection", function(sck,c) conn:send("GET "..remotepath.." HTTP/1.1\r\nHost: "..serverip.."\r\nAccept: */*\r\n\r\n") end)
    conn:connect(80, serverip)
end

-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/telnet.lua
function startServer()
    if telnet_srv ~= nil then
        telnet_srv:close()
    end
    telnet_srv = net.createServer(net.TCP, 180)
    telnet_srv:listen(2323, function(socket)
        local fifo = {}
        local fifo_drained = true

        local function sender(c)
            if #fifo > 0 then
                c:send(table.remove(fifo, 1))
            else
                fifo_drained = true
            end
        end

        local function s_output(str)
            table.insert(fifo, str)
            if socket ~= nil and fifo_drained then
                fifo_drained = false
                sender(socket)
            end
        end

        node.output(s_output, 0)   -- re-direct output to function s_ouput.

        socket:on("receive", function(c, l)
            node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
        end)
        socket:on("disconnection", function(c)
            node.output(nil)        -- un-regist the redirect output function, output goes to serial
        end)
        socket:on("sent", sender)

        print("Welcome to NodeMCU world.")
    end)
end

function connectWifi()
    local ssid = getSetting("wifi_ssid")
    local pwd = getSetting("wifi_pwd")
    if (ssid == nil) or (pwd == nil) or (ssid:len() < 1) or (pwd:len() < 1) then
        print("Error while loading wifi settings")
    else
        wifi.setmode(wifi.STATION)
        wifi.sta.autoconnect(1)
        local cfg = {}
        cfg.ssid = ssid
        cfg.pwd = pwd
        cfg.got_ip_cb = function(t)
            print("Connected to network, received ip:", t.IP)
            wifiTimer:stop()
        end
        wifi.sta.config(cfg)
        wifi.sta.connect(function(x) print("Connected to wifi, waiting for ip...") end)
    end
end

wifiTimer = tmr.create()
wifiTimer:register(10000,tmr.ALARM_AUTO,connectWifi)

local initTimer = tmr.create()
initTimer:register(3000, tmr.ALARM_SINGLE, function(t)
    if wifi.sta.getip() == nil then
        connectWifi()
        wifiTimer:start()
    end
    startServer()
    local sfile = file.open("start.lua", "r")
    if sfile ~= nil then
        node.compile("start.lua")
        dofile("start.lc")
    end
end)
initTimer:start()