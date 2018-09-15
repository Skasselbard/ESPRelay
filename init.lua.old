function loadModule(serverip, path, name, successCallback)
    print("Loading module "..name)
    local path = "http://"..serverip..path
    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(sck,c)
        local match = c:match("HTTP/1.1 %d+")
        local code = match:sub(10,12)
        if tonumber(code) ~= 200 then
            print("Error code "..code.." while getting "..path)
            return
        end
        local index = string.find(c, "\r\n\r\n")
        if index then
            local f = file.open(name..".lua", "w")
            f:write(string.sub(c, index+4))
            f:close()
            successCallback(name)
        else
            print("Received malformed HTTP response?")
        end
    end)
    conn:on("connection", function(sck,c) conn:send("GET "..path.." HTTP/1.1\r\nHost: "..serverip.."\r\nAccept: */*\r\n\r\n") end)
    conn:connect(80, serverip)
end

function getServerOrFallback()
    local f = file.open("server", "r")
    local serverip = "192.168.0.15"
    if f then
        serverip = f:readline()
        f:close()
        return serverip
    else 
        print("Could not open file \"server\".")
        return nil
    end
end

function loadPostInit()
    loadModule(getServerOrFallback(), "/nodemcu/postinit.lua", "postinit", function() dofile("postinit.lua") end)
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

startServer()

local mytimer = tmr.create()
mytimer:register(3000, tmr.ALARM_SINGLE, loadPostInit)
mytimer:start()