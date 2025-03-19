-- Version: Lua 5.3.5
local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=4, user=0, load=0, armOrientation={1,1,1,-1}}
  local mm_status=0
  local pos_num=0
  local label_1=0
  local speed_1=0
while(true)
do
MoveJ(P1)
DO(3, OFF)
DO(1, ON)
mm_init_skt("192.168.5.22", 50000, 300)
mm_open_skt()
--Set model
--mm_set_model(1,1)
mm_start_vis(2, 0, 2, JPS)
Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
mm_status,pos_num=mm_get_vis_data(2)
--mm_get_pos(qty,pos_1)
label_1,speed_1 = mm_get_pos(1,pos_1)
if  mm_status~=1100 then
   Go(P2, "CP=1 Speed=50 Accel=20 SYNC=1")
  end
local pick_offset = {0, 0, 50}
  local pos_app=RP(pos_1, pick_offset)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_1, "CP=0 Speed=50 Accel=100 SYNC=1")
  DO(3, ON)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 50}
  local drop_app=RP(P4, drop_offset)
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P4)
  DO(3, OFF)
  mm_close_skt()
end
