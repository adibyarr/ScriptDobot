-- Version: Lua 5.3.5

-- Initialize variable
a=0
function gerak()
    MovJ(InitialPose)
    Go(RP(P1, {0,0,80,0}))
    MovL(P1)
    pick_object()
    Go(RP(P1, {0,0,80,0}))
    print("Pick1 selesai")
    a = a + 5
    Sync()
end

function Gerak2()
    
    MovJ(InitialPose)
    Go(RP(P2, {0, 0, 80,0}))
    MovL(P2)
    place_object()
    Go(RP(P2, {0,0, 80,0}))
    print("Place Selesai")
    MovJ(InitialPose)
    Sync()
    a = 10
  
end

while(a< 5) do
   gerak()
end
while(a>=5 and a<10) do
  Gerak2()
  end
