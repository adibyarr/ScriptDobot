-- Global variable module is only used to define global variables and module functions. The motion command cannot be called here.
-- Version: Lua 5.3.5

function OnVacuum()
  Wait(500)
  DO(2,ON)
  end
  
  function OffVacuum()
    Wait(500)
    DO(2,OFF)
    end
  