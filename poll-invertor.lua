print("Ginlong Invertor Poller started\n")

DEBUG = false

SERIAL_PORT = "/dev/rfcomm0"

-- Max number of times to retry reading response from serial port after sending a inquiry request
MAX_RETRIES = 5

-- Bytes to send to request data from invertor
INQUIRY_HEX  = "7E01A1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000A2"
-- all valid responses from invertor begin with this set of bytes
RESPONSE_PREFIX  = "7E01A11C"

----------------
-- inverter data
----------------

DATA_DEFS = {}

DATA_DEFS["vpv1"] = { 
multiply = 0.1,
units  = "V",
index	   = 0,
descr    = "Panel 1 Voltage",
flip     = 1
}

DATA_DEFS["vpv2"] = {
multiply = 0.1,
units  = "V",
index	   = 24,
descr    = "Panel 2 Voltage",
flip     = 1
}

DATA_DEFS["ipv1"] = {
multiply = 0.1,
units  = "A",
index	 = 2,
descr    = "Panel 1 DC Current"
}

DATA_DEFS["ipv2"] = {
multiply = 0.1,
units  = "A",
index	 = 26,
descr    = "Panel 2 DC Current"
}

DATA_DEFS["emonth"] = {
multiply = 1,
units  = "kWh",
index	 = 29,
descr    = "Accumulated Energy This Month"
}

DATA_DEFS["lmonth"] = {
multiply = 1,
units  = "kWh",
index    = 31,
descr    = "Accumulated Energy Last Month"
}

DATA_DEFS["iac"] = {
multiply = 0.1,
units  = "A",
index	 = 6,
descr    = "Grid Current"
}

DATA_DEFS["vac"] = {
multiply = 0.1,
units  = "V",
index	 = 4,
descr    = "Grid Voltage"
}

DATA_DEFS["fac"] = {
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
  local prefixLen = string.len(RESPONSE_PREFIX) + 1
  local hexData = str:tohex()
  if string.sub(hexData, 1, #RESPONSE_PREFIX) == RESPONSE_PREFIX then
      print("Data OK: " .. "[" .. #str .."]" .. hexData)
  else
    print("Data BAD: " .. "[" .. #str .."]" .. hexData)
  end
--  local highbyte = string.sub(str,2,2) or "0"
--  local lowbyte =  string.sub(str,1,1) or "0"
--  print((lowbyte..highbyte):tohex())
  
  for i in pairs(DATA_DEFS) do
    dataIndex = prefixLen + (DATA_DEFS[i].index * 2)
    print(dataIndex .. ":" .. i)
    local lowbyte =  string.sub(hexData, dataIndex, dataIndex+1) or "0"
    local highbyte = string.sub(hexData, dataIndex+2, dataIndex+3) or "0"
    local val = (highbyte .. lowbyte)
    print(val .. "=" .. (tonumber(val, 16) * DATA_DEFS[i].multiply) .. DATA_DEFS[i].units)
  end

end

if DEBUG then
  dumpResponse = assert(io.open("reading.bin","w"))
end

serialport = assert(io.open(SERIAL_PORT,"w"))
serialport:write(string.fromhex(INQUIRY_HEX))
serialport:close()


local tries = 0
while tries < MAX_RETRIES do
    print("try " .. tries)
    serialport = assert(io.open(SERIAL_PORT,"r"))
    local result = serialport:read("*all")
    if (result ~= nil) and (string.len(result) > 0) then
        if DEBUG then
          dumpResponse:write(result)
          dumpResponse:close()
        end
        parseResponse(result)
        return
    end
    print("failed to read response")
    tries = tries+1
    serialport:close()
end
