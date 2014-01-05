print("Ginlong Invertor Poller started\n")

SERIAL_PORT = "/dev/rfcomm0"

-- Bytes to send to request info from invertor
inquiryHex  = "7E01A1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000A2"
-- all valid responses from invertor begin with this set of bytes
responsePrefix  = "7E01A11C"

--------------------------------------------------
-- hex start indeces and lengths for certain data
--------------------------------------------------

data_to_follow_index    = 3
capacity_index          = 20
capacity_length         = 0
firmware_index          = 32
firmware_length         = 0
model_index             = 46
model_length            = 0
manuf_index             = 74
manuf_length            = 0
serial_index            = 106
serial_length           = 0
other_index             = 138
other_length            = 0
confserial_index        = 18


----------------
-- inverter data
----------------

data = {}

data["vpv1"] = { 
multiply = 0.1,
units  = "V",
index	   = 0,
descr    = "Panel 1 Voltage",
flip     = 1
}

data["vpv2"] = {
multiply = 0.1,
units  = "V",
index	   = 24,
descr    = "Panel 2 Voltage",
flip     = 1
}

data["ipv1"] = {
multiply = 0.1,
units  = "A",
index	 = 2,
descr    = "Panel 1 DC Current"
}

data["ipv2"] = {
multiply = 0.1,
units  = "A",
index	 = 26,
descr    = "Panel 2 DC Current"
}

data["emonth"] = {
multiply = 1,
units  = "kWh",
index	 = 29,
descr    = "Accumulated Energy This Month"
}

data["lmonth"] = {
multiply = 1,
units  = "kWh",
index    = 31,
descr    = "Accumulated Energy Last Month"
}

data["iac"] = {
multiply = 0.1,
units  = "A",
index	 = 6,
descr    = "Grid Current"
}

data["vac"] = {
multiply = 0.1,
units  = "V",
index	 = 4,
descr    = "Grid Voltage"
}

data["fac"] = {
multiply = 0.01,
units  = "Hz",
index	 = 20,
descr    = "Grid Frequency"
}


function string.fromhex(str)
  if str ~= nil then
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
  end
end

function string.tohex(str)
  if str ~= nil then
    return (str:gsub('.', function (c)
        if c == 0 then return "00" end
        return string.format('%02X', string.byte(c))
    end))
  end
end

function parseResponse(str)
  if str == nill then return end
  local prefixLen = string.len(responsePrefix) + 1
  local hexData = str:tohex()
  if string.sub(hexData, 1, #responsePrefix) == responsePrefix then
      print("Data OK: " .. "[" .. #str .."]" .. hexData)
  else
    print("Data BAD: " .. "[" .. #str .."]" .. hexData)
  end
--  local highbyte = string.sub(str,2,2) or "0"
--  local lowbyte =  string.sub(str,1,1) or "0"
--  print((lowbyte..highbyte):tohex())
  
  for i in pairs(data) do
    dataIndex = prefixLen + (data[i].index * 2)
    print(dataIndex .. ":" .. i)
    local lowbyte =  string.sub(hexData, dataIndex, dataIndex+1) or "0"
    local highbyte = string.sub(hexData, dataIndex+2, dataIndex+3) or "0"
    local val = (highbyte .. lowbyte)
--    if (data[i].flip == 1) then
--      val = (lowbyte .. highbyte)
--    end
    print(val .. "=" .. (tonumber(val, 16) * data[i].multiply) .. data[i].units)
  end

end

local test = assert(io.open("docs/examples/reading1.bin","r"))
--parseResponse(test:read("*all"))

--local test = assert(io.open("t1.bin","w"))

serialport = assert(io.open(SERIAL_PORT,"w"))
serialport:write(string.fromhex(inquiryHex))
serialport:close()


local tries = 0
while tries < 5 do
    print("try " .. tries)
    serialport = assert(io.open(SERIAL_PORT,"r"))
    local result = serialport:read("*all")
    if (result ~= nil) and (string.len(result) > 0) then
        test:write(result)
        test:close()
        parseResponse(result)
        return
    end
    print("failed to read response")
    tries = tries+1
    serialport:close()
end
