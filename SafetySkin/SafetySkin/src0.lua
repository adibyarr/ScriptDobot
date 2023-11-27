-- Version: Lua 5.3.5
resultCreate,id = ModbusCreate('192.168.5.1', 502, 1)
  if resultCreate == 0 then
      print("Create modbus master success!")
  else
      print("Create modbus master failed, code:", resultCreate)
  end
  Sync()
print((resultCreate))
Sync()
while 1 do
--  SetSafeSkin(1)
 -- SetObstacleAvoid(1)
  Sleep(50)
  Sync()
  if (GetHoldRegs(id,0,1,"U16")[1])==10 then
    SafeSkinOn()
    Sync()
    print('Modbus 1 Success!')
    Sync()
    MoveJ((P1))
    SetHoldRegs(id,0,1,{20},"U16")
    Sync()
  end
  if (GetHoldRegs(id,0,1,"U16")[1])==20 then
    Sync()
    print('Modbus Address 1 Success')
    MoveJ((P2))
    SetHoldRegs(id,0,1,{30},"U16")
    SafeSkinOff()
    Sync()
  end
  if (GetHoldRegs(id,0,1,"U16")[1])==30 then
    Sync()
    print('Modbus Address 2 Success')
    MoveJ((P3))
    SetHoldRegs(id,0,1,{10},"U16")
    Sync()
    --SafeSkinOff()
  end
end
