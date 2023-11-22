-- Version: Lua 5.3.5

-- Initialize variable
a=0

--Pick 1
function gerak()
    MovJ(InitialPose)
    Go(RP(P1, {0,0,80,0}))
    MovL(P1)
    pick_object()
    Go(RP(P1, {0,0,80,0}))
    print("Pick1 Finish")
    a = a + 5
    DO(17,ON)
    Sync()
end

--Place 1
function Gerak2()
    MovJ(InitialPose)
    Go(RP(P2, {0, 0, 80,0}))
    MovL(P2)
    place_object()
    Go(RP(P2, {0,0, 80,0}))
    print("Place1 Finish")
    MovJ(InitialPose)
    Sync()
    a = a+5
end

--Pick 2
function Gerak3()
    Go(RP(P3, {0, 0, 80,0}))
    MovL(P3)
    pick_object()
    Go(RP(P3, {0, 0, 80,0}))
    print("Pick 2 Finish")
    MovJ(InitialPose)
    Sync()
    a= a+5
 end
 
 --Place2
 function Gerak4()
 Go(RP(P4, {0, 0, 80,0}))
 MovL(P4)
 place_object()
 Go(RP(P4, {0, 0, 80,0}))
 print("Place 2 Finish")
 MovJ(InitialPose)
 Sync()
 a = 20
end

--Main Program To Execute the Function
while(a<5) 
   do
    gerak()
  end

while(a>=5 and a<10) 
  do 
    Gerak2()
  end

while(a>= 10 and a<15) 
  do 
    Gerak3()
  end

while(a>=15 and a<20) 
  do 
    Gerak4()
  end
