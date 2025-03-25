local STX = string.char(0x02)
local ETX = string.char(0x03)

-- Create and start TCP connection
local resultOpen1, socket1 = TCPCreate(false, '192.168.5.101', 8500)
if resultOpen1 == 0 then
    print("Create TCP Client Success!")
else
    print("Create TCP Client failed, code:", resultOpen1)
end

resultOpen1 = TCPStart(socket1, 0)
if resultOpen1 == 0 then
    print("Connect TCP Server Success!")
else
    print("Connect TCP Server failed, code:", resultOpen1)
end

-- Loop to send and receive data
local a = 5
 
    -- Send command to server
    local resultWrite1 = TCPWrite(socket1, STX .. "trigger" .. ETX)
    print("Write Result:", resultWrite1)
    
    -- Synchronization delay
    Sync()

    -- Read response from server
    local err, RecBuf = TCPRead(socket1, 0, "String")
    if err == 0 and RecBuf and RecBuf.buf then
        -- Convert ASCII values to string
        local ascii_values = RecBuf.buf
        local decoded_string = ""
        
        for i = 1, #ascii_values do
            decoded_string = decoded_string .. string.char(ascii_values[i])
        end
        
        print("Received Data (Decoded):", decoded_string)
    else
        print("TCP Read Failed, code:", err)
    end

    a = a + 1


-- Close TCP connection after loop
TCPDestroy(socket1)
