-- Global variable module is only used to define global variables and module functions. The motion command cannot be called here.
-- Version: Lua 5.3.5
function SafeSkinOn()
  SetSafeSkin(1)
  --SetObstacleAvoid(1)
  end
  
function SafeSkinOff()
  SetSafeSkin(0)
  SetObstacleAvoid(0)
  end
