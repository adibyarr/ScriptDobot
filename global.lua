-- Global variable module is only used to define global variables and module functions. The motion command cannot be called here.
-- Version: Lua 5.3.5

function pick_object()
DO(1, ON)
Wait(1000)
print("Pick")
DO(1,OFF)
Sync()
end

function place_object()
DO(2, ON)
Wait(1000)
print("Place on the hell")
DO(2, OFF)
Sync()
end