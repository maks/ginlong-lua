print("Ginlong Reader started\n")

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    if str ~= nil then
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
    end
end

inqhex  = "7E01A1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000A2"

local test = assert(io.open("t1.bin","w"))
--test:write(string.fromhex(inqhex))
--test:close()

serialport = assert(io.open("/dev/rfcomm0","w"))
serialport:write(string.fromhex(inqhex))
serialport:close()


local tries = 0
while tries < 5 do
    print("try " .. tries)
    serialport = assert(io.open("/dev/rfcomm0","r"))
    local result = serialport:read("*all")
    if (result ~= nil) and (string.len(result) > 0) then
--        print("res:" .. result)    --print the data
        test:write(result)
        test:close()
        return
    end
    print("fail")
    tries = tries+1
    serialport:close()
end
