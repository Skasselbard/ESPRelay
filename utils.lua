-- Each setting is saved as a file in the "settings" pseudo-directory
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