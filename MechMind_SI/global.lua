-- Global variable module is only used to define global variables and module functions. The motion command cannot be called here.
-- Version: Lua 5.3.5

-- 全局变量模块仅用于定义全局变量和模块函数，不能调用运动指令。
-- Version: Lua 5.3.5
------------------------------------------------------------------------------------------------------------
----------------------------------------------Standard Interface For Dobot----------------------------------
------------------------------------------------------------------------------------------------------------
-- MM Global Variable Definition
g_server_ip="127.0.0.1"
g_server_port=50000
g_timeout=0
g_err=0
g_socket=0
g_mm_cmd=0
g_mm_status=0
g_userdata_num=0
g_resource=0
g_pos_type=0
vis_pos_x={}
vis_pos_y={}
vis_pos_z={}
vis_pos_rx={}
vis_pos_ry={}
vis_pos_rz={}
vis_pos_lbl={}
vis_pos_spd={}
vis_pos_toolnum={}
vis_pos_movetype={}
vis_pos_j1={}
vis_pos_j2={}
vis_pos_j3={}
vis_pos_j4={}
vis_pos_j5={}
vis_pos_j6={}
userdata={}
plandata={}
is_vispos={}
do_list={}
mm_userdata={}
mm_plandata={}

-- MM Function Definition
-- decode_recv_buffer
function decode(str, delimiter)
	local result = {}
	string.gsub(str, '[^'..delimiter..']+', function(token) table.insert(result, tonumber(token)) end )
	return result
end
-- open_socket
function mm_open_skt()
  g_err, g_socket=TCPCreate(false, g_server_ip, g_server_port)
  if (g_err==0) then
    if (TCPStart(g_socket, g_timeout)~=0) then 
      print("MM:socket open failure!")
    end
  else
    print("MM:socket create failure!")
  end
end
-- close_socket
function mm_close_skt()
  if (TCPDestroy(g_socket)~=0) then 
    print("MM:socket close failure!") 
  end
end
-- init_socket
function mm_init_skt(_server_ip, _server_port, _timeout)
  g_server_ip=_server_ip
  g_server_port=_server_port
  g_timeout=_timeout*1000
end
-- start_vision
function mm_start_vis(_job, _pos_num_need, _sendpos_type, _init_jps)
  --Sync()
  local CMD_CODE=101
  local RET_STATUS=1102
  local send_data=""
  local data_buf=""
  local cur_jps=GetAngle()
  local cur_pose=GetPose()
  if (_sendpos_type==0) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",0,0,0,0,0,0)
  elseif (_sendpos_type==1) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r", 
    cur_jps.joint[1],cur_jps.joint[2],cur_jps.joint[3],cur_jps.joint[4],cur_jps.joint[5],cur_jps.joint[6],
    cur_pose.coordinate[1],cur_pose.coordinate[2],cur_pose.coordinate[3],cur_pose.coordinate[4],
    cur_pose.coordinate[5],cur_pose.coordinate[6])
  elseif (_sendpos_type==2) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",cur_pose.coordinate[1],cur_pose.coordinate[2],
    cur_pose.coordinate[3],cur_pose.coordinate[4],cur_pose.coordinate[5],cur_pose.coordinate[6])
  elseif (_sendpos_type==3) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",_init_jps.joint[1],_init_jps.joint[2],
    _init_jps.joint[3],_init_jps.joint[4],_init_jps.joint[5],_init_jps.joint[6])
  else
    print("MM:robot argument error")
    Pause()
  end
  send_data = string.format("%d,%d,%d,%d,%s", CMD_CODE,_job,_pos_num_need,_sendpos_type, data_buf)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end
end
-- start_viz
function mm_start_viz(_sendpos_type, _init_jps)
  --Sync()
  local CMD_CODE=201
  local RET_STATUS=2103
  local send_data=""
  local data_buf=""
  local cur_jps=GetAngle()
  local cur_pose=GetPose()
  if (_sendpos_type==0) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",0,0,0,0,0,0)
  elseif (_sendpos_type==1) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",cur_jps.joint[1],
    cur_jps.joint[2],cur_jps.joint[3],cur_jps.joint[4],cur_jps.joint[5],cur_jps.joint[6],cur_pose.coordinate[1],
    cur_pose.coordinate[2],cur_pose.coordinate[3],cur_pose.coordinate[4],cur_pose.coordinate[5],cur_pose.coordinate[6])
  elseif (_sendpos_type==2) then
    data_buf=string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",_init_jps.joint[1],_init_jps.joint[2],_init_jps.joint[3],
    _init_jps.joint[4],_init_jps.joint[5],_init_jps.joint[6])
  else
    print("MM:robot argument error")
    Pause()
  end
  send_data = string.format("%d,%d,%s", CMD_CODE, _sendpos_type, data_buf)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end
end
-- stop viz
function mm_stop_viz()
  local CMD_CODE=202
  local RET_STATUS=2104
  local send_data=""
  send_data=string.format("%d\r", CMD_CODE)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end
end
-- get vision data
function mm_get_vis_data(_job)  --return g_mm_status, _pos_num
  local CMD_CODE=102
  local RET_STATUS=1100
  local send_data=""
  local _pos_num=0
  ::resend::
  send_data=string.format("%d,%d\r", CMD_CODE,_job)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status==RET_STATUS then 
      for i=1,recv_data[4] do
        vis_pos_x[_pos_num+i] = recv_data[6+(i-1)*8]
        vis_pos_y[_pos_num+i] = recv_data[7+(i-1)*8]
        vis_pos_z[_pos_num+i] = recv_data[8+(i-1)*8]
        vis_pos_rx[_pos_num+i] = recv_data[9+(i-1)*8]
        vis_pos_ry[_pos_num+i] = recv_data[10+(i-1)*8]
        vis_pos_rz[_pos_num+i] = recv_data[11+(i-1)*8]
        vis_pos_lbl[_pos_num+i] = recv_data[12+(i-1)*8]
        vis_pos_spd[_pos_num+i] = recv_data[13+(i-1)*8]
      end
      _pos_num = _pos_num + recv_data[4]
      if recv_data[3]==0 then
        goto resend
      end
    end
    return g_mm_status, _pos_num
  end
end
-- get vision dy data
function mm_get_dy_data(_job)  --return g_mm_status, _pos_num
  local CMD_CODE=110
  local RET_STATUS=1100
  local send_data=""
  local _pos_num=0
  ::resend::
  send_data=string.format("%d,%d\r", CMD_CODE,_job)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    g_userdata_num=recv_data[4]
    if g_mm_status==RET_STATUS then 
      vis_pos_x[_pos_num+1] = recv_data[5]
      vis_pos_y[_pos_num+1] = recv_data[6]
      vis_pos_z[_pos_num+1] = recv_data[7]
      vis_pos_rx[_pos_num+1] = recv_data[8]
      vis_pos_ry[_pos_num+1] = recv_data[9]
      vis_pos_rz[_pos_num+1] = recv_data[10]
      vis_pos_lbl[_pos_num+1] = recv_data[11]
      for i=(_pos_num+1),(_pos_num+1) do
        userdata[i]={}
        for j=1,g_userdata_num do
          userdata[i][j]=recv_data[11+j]
        end
      end
      _pos_num = _pos_num + 1
      if recv_data[3]==0 then
        goto resend
      end
    end
    return g_mm_status, _pos_num
  end
end
-- get vision path
function mm_get_vis_path(_job,_pos_type)  --return g_mm_status,_pos_num,_vispos_idx
  local CMD_CODE=105
  local RET_STATUS=1103
  local send_data=""
  local _pos_num=0
  local _vispos_idx=0
  ::resend::
  send_data=string.format("%d,%d,%d\r", CMD_CODE,_job,_pos_type)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status==RET_STATUS then 
      for i=1,recv_data[4] do
        if _pos_type==2 then
          vis_pos_x[_pos_num+i] = recv_data[6+(i-1)*8]
          vis_pos_y[_pos_num+i] = recv_data[7+(i-1)*8]
          vis_pos_z[_pos_num+i] = recv_data[8+(i-1)*8]
          vis_pos_rx[_pos_num+i] = recv_data[9+(i-1)*8]
          vis_pos_ry[_pos_num+i] = recv_data[10+(i-1)*8]
          vis_pos_rz[_pos_num+i] = recv_data[11+(i-1)*8]
          vis_pos_lbl[_pos_num+i] = recv_data[12+(i-1)*8]
          vis_pos_spd[_pos_num+i] = recv_data[13+(i-1)*8]
        elseif _pos_type==1 then
          vis_pos_j1[_pos_num+i] = recv_data[6+(i-1)*8]
          vis_pos_j2[_pos_num+i] = recv_data[7+(i-1)*8]
          vis_pos_j3[_pos_num+i] = recv_data[8+(i-1)*8]
          vis_pos_j4[_pos_num+i] = recv_data[9+(i-1)*8]
          vis_pos_j5[_pos_num+i] = recv_data[10+(i-1)*8]
          vis_pos_j6[_pos_num+i] = recv_data[11+(i-1)*8]
          vis_pos_lbl[_pos_num+i] = recv_data[12+(i-1)*8]
          vis_pos_spd[_pos_num+i] = recv_data[13+(i-1)*8]
        else
          print("MM:robot argument error")
          Pause()
        end
      end
      _pos_num = _pos_num + recv_data[4]
      if recv_data[3]==0 then
        goto resend
      end
      _vispos_idx=recv_data[5]
    end
    return g_mm_status,_pos_num,_vispos_idx
  end  
end

-- get viz/vision plan data
function mm_get_plan_data(_resource,_pos_type) --return g_mm_status,_pos_num,_vispos_idx
  local CMD_CODE
  local RET_STATUS
  local send_data=""
  local _pos_num=0
  local _vispos_idx=0
  g_mm_status=0
  g_resource=_resource
  g_pos_type=_pos_type
  ::resend::
  if _resource==0 then 
    CMD_CODE=210
    RET_STATUS=2100
    send_data=string.format("%d,%d\r", CMD_CODE,_pos_type)
  else
    CMD_CODE=111
    RET_STATUS=1103
    send_data=string.format("%d,%d,%d\r", CMD_CODE,_resource,_pos_type)
  end
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    is_vispos[_pos_num+1]=recv_data[4]
    if g_mm_status==RET_STATUS then 
      if _pos_type==2 or _pos_type==4 then
        vis_pos_x[_pos_num+1] = recv_data[5]
        vis_pos_y[_pos_num+1] = recv_data[6]
        vis_pos_z[_pos_num+1] = recv_data[7]
        vis_pos_rx[_pos_num+1] = recv_data[8]
        vis_pos_ry[_pos_num+1] = recv_data[9]
        vis_pos_rz[_pos_num+1] = recv_data[10]
        vis_pos_movetype[_pos_num+1] = recv_data[11]
        vis_pos_toolnum[_pos_num+1] = recv_data[12]
        vis_pos_spd[_pos_num+1] = recv_data[13]
    elseif _pos_type==1 or _pos_type==3 then
        vis_pos_j1[_pos_num+1] = recv_data[5]
        vis_pos_j2[_pos_num+1] = recv_data[6]
        vis_pos_j3[_pos_num+1] = recv_data[7]
        vis_pos_j4[_pos_num+1] = recv_data[8]
        vis_pos_j5[_pos_num+1] = recv_data[9]
        vis_pos_j6[_pos_num+1] = recv_data[10]
        vis_pos_movetype[_pos_num+1] = recv_data[11]
        vis_pos_toolnum[_pos_num+1] = recv_data[12]
        vis_pos_spd[_pos_num+1] = recv_data[13]
    else
      print("MM:robot argument error")
      Pause()
    end
    if recv_data[4]==1 then
      _vispos_idx=_pos_num + 1
      if _resource==0 then
        if _pos_type==1 or _pos_type==2 then
          --get userdata
          g_userdata_num=recv_data[14]
          for i=(_pos_num+1),(_pos_num+1) do
            userdata[i]={}
            for j=1,g_userdata_num do
              userdata[i][j]=recv_data[14+j]
            end
          end
        else
          --get plandata
          for i=(_pos_num+1),(_pos_num+1) do
            plandata[i]={}
            for j=1,21 do
              plandata[i][j]=recv_data[13+j]
            end
          end
            --get userdata
            g_userdata_num=recv_data[35]
            for i=(_pos_num+1),(_pos_num+1) do
              userdata[i]={}
              for j=1,g_userdata_num do
                userdata[i][j]=recv_data[35+j]
              end
            end
        end
      else
        --get plandata
        for i=(_pos_num+1),(_pos_num+1) do
          plandata[i]={}
          for j=1,21 do
            plandata[i][j]=recv_data[13+j]
          end
        end
      end
    end
      _pos_num = _pos_num + 1
      if recv_data[3]==0 then
        goto resend
      end
    end
    return g_mm_status,_pos_num,_vispos_idx
  end  
end
-- get viz data
function mm_get_viz_data(_pos_type)
  local CMD_CODE=205
  local RET_STATUS=2100
  local send_data=""
  local _pos_num=0
  local _vispos_idx=0
  ::resend::
  send_data=string.format("%d,%d\r", CMD_CODE,_pos_type)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status==RET_STATUS then 
      for i=1,recv_data[4] do
        if _pos_type==2 then
          vis_pos_x[_pos_num+i] = recv_data[6+(i-1)*8]
          vis_pos_y[_pos_num+i] = recv_data[7+(i-1)*8]
          vis_pos_z[_pos_num+i] = recv_data[8+(i-1)*8]
          vis_pos_rx[_pos_num+i] = recv_data[9+(i-1)*8]
          vis_pos_ry[_pos_num+i] = recv_data[10+(i-1)*8]
          vis_pos_rz[_pos_num+i] = recv_data[11+(i-1)*8]
          vis_pos_lbl[_pos_num+i] = recv_data[12+(i-1)*8]
          vis_pos_spd[_pos_num+i] = recv_data[13+(i-1)*8]
        elseif _pos_type==1 then
          vis_pos_j1[_pos_num+i] = recv_data[6+(i-1)*8]
          vis_pos_j2[_pos_num+i] = recv_data[7+(i-1)*8]
          vis_pos_j3[_pos_num+i] = recv_data[8+(i-1)*8]
          vis_pos_j4[_pos_num+i] = recv_data[9+(i-1)*8]
          vis_pos_j5[_pos_num+i] = recv_data[10+(i-1)*8]
          vis_pos_j6[_pos_num+i] = recv_data[11+(i-1)*8]
          vis_pos_lbl[_pos_num+i] = recv_data[12+(i-1)*8]
          vis_pos_spd[_pos_num+i] = recv_data[13+(i-1)*8]
        else
          print("MM:robot argument error")
          Pause()
        end
      end
      _pos_num = _pos_num + recv_data[4]
      if recv_data[3]==0 then
        goto resend
      end
      _vispos_idx=recv_data[5]
    end
    return g_mm_status,_pos_num,_vispos_idx
  end
end
-- get dolist
function mm_get_dolist(_resource)
  local CMD_CODE
  local RET_STATUS
  local send_data=""
  if _resource==0 then 
    CMD_CODE=206
    RET_STATUS=2102
    send_data=string.format("%d\r", CMD_CODE)
  else
    CMD_CODE=106
    RET_STATUS=1106
    send_data=string.format("%d,%d\r", CMD_CODE,_resource)
  end
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    else
      for i=1,64 do
          do_list[i]=recv_data[2+i]
      end
    end
  end  
end
-- set dolist
function mm_set_dolist()
  for i=1,64 do  
    if do_list[i]>=0 then
      DO(do_list[i], ON)
    end
  end
end
-- set viz branch
function mm_set_branch(_branch_id,_port)
  local CMD_CODE=203
  local RET_STATUS=2105
  local send_data=""
  send_data=string.format("%d,%d,%d\r", CMD_CODE,_branch_id,_port)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end
end
-- set viz index
function mm_set_index(_skill_num,_index_num)
  local CMD_CODE=204
  local RET_STATUS=2106
  local send_data=""
  send_data=string.format("%d,%d,%d\r", CMD_CODE,_skill_num,_index_num)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end
end
-- set vision model
function mm_set_model(_job,model_id)
  local CMD_CODE=103
  local RET_STATUS=1107
  local send_data=""
  send_data=string.format("%d,%d,%d\r", CMD_CODE,_job,model_id)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end  
end
-- set vision boxsize
function mm_set_boxsize(_job,_length,_width,_height)
  local CMD_CODE=501
  local RET_STATUS=1108
  local send_data=""
  send_data=string.format("%d,%d,%.6f,%.6f,%.6f\r", CMD_CODE,_job,_length,_width,_height)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
  end  
end
-- get viz/vision notify
function mm_get_notify()  --return _msg
  local CMD_CODE=601
  local send_data=""
  local _msg=0
  send_data=string.format("%d\r", CMD_CODE)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    _msg=recv_data[2]
    print("MM:recv notify msg: %d",_msg)
    return _msg
  end    
end
-- set viz property
function mm_set_property(_config_id) --return g_mm_status
  local CMD_CODE=208
  local RET_STATUS=2108
  local send_data=""
  send_data=string.format("%d,%d\r", CMD_CODE,_config_id)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
    return g_mm_status
  end
end
-- get viz property
function mm_get_property(_config_id) --return g_mm_status,viz_prop_val
  local CMD_CODE=207
  local RET_STATUS=2109
  local send_data=""
  local viz_prop_val=0
  send_data=string.format("%d,%d\r", CMD_CODE,_config_id)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    if g_mm_status~=RET_STATUS then 
      print("MM:ipc error code: ",g_mm_status)
      Pause()
    end
    viz_prop_val=recv_data[3]
    return g_mm_status, viz_prop_val
  end
end
-- get status
function mm_get_status()  --return g_mm_status
  local CMD_CODE=901
  local send_data=""
  send_data=string.format("%d\r", CMD_CODE)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    Pause()
  end
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    Pause()
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    if g_mm_cmd~=CMD_CODE then
      print("MM:robot cmd error")
      Pause()
    end
    g_mm_status=recv_data[2]
    return g_mm_status
  end  
end
-- get pos
function mm_get_pos(_idx,_pos)  --return _label,_speed
  local _label=0
  local _speed=0
  if vis_pos_x[_idx]==0 and vis_pos_y[_idx]==0 and vis_pos_z[_idx]==0 and 
     vis_pos_rx[_idx]==0 and vis_pos_ry[_idx]==0 and vis_pos_rz[_idx]==0 then
      print("MM:pos data is empty")
      Pause()
  else
    _pos.coordinate = {vis_pos_x[_idx],vis_pos_y[_idx],vis_pos_z[_idx],
    vis_pos_rx[_idx],vis_pos_ry[_idx],vis_pos_rz[_idx]}
    _label = vis_pos_lbl[_idx]
    _speed = vis_pos_spd[_idx]
    vis_pos_x[_idx]=0 
    vis_pos_y[_idx]=0 
    vis_pos_z[_idx]=0
    vis_pos_rx[_idx]=0
    vis_pos_ry[_idx]=0 
    vis_pos_rz[_idx]=0 
    vis_pos_lbl[_idx]=0
    vis_pos_spd[_idx]=0
    return _label,_speed
  end
end
-- get jps
function mm_get_jps(_idx,_jps)  --return _label,_speed
  local _label=0
  local _speed=0  
  if vis_pos_j1[_idx]==0 and vis_pos_j2[_idx]==0 and vis_pos_j3[_idx]==0 and 
     vis_pos_j4[_idx]==0 and vis_pos_j5[_idx]==0 and vis_pos_j6[_idx]==0 then
      print("MM:jps data is empty")
      Pause()
  else
    _jps.joint = {vis_pos_j1[_idx],vis_pos_j2[_idx],vis_pos_j3[_idx],
    vis_pos_j4[_idx],vis_pos_j5[_idx],vis_pos_j6[_idx]}
    _label = vis_pos_lbl[_idx]
    _speed = vis_pos_spd[_idx]
    vis_pos_j1[_idx]=0 
    vis_pos_j2[_idx]=0 
    vis_pos_j3[_idx]=0
    vis_pos_j4[_idx]=0
    vis_pos_j5[_idx]=0 
    vis_pos_j6[_idx]=0 
    vis_pos_lbl[_idx]=0
    vis_pos_spd[_idx]=0  
    return _label,_speed
  end
end
-- get dy pos
function mm_get_dypos(_idx,_pos)  --return _label
  local _label=0
  if vis_pos_x[_idx]==0 and vis_pos_y[_idx]==0 and vis_pos_z[_idx]==0 and 
     vis_pos_rx[_idx]==0 and vis_pos_ry[_idx]==0 and vis_pos_rz[_idx]==0 then
      print("MM:pos data is empty")
      Pause()
  else
    _pos.coordinate = {vis_pos_x[_idx],vis_pos_y[_idx],vis_pos_z[_idx],
    vis_pos_rx[_idx],vis_pos_ry[_idx],vis_pos_rz[_idx]}
    _label = vis_pos_lbl[_idx]
    for i=1,g_userdata_num do
      mm_userdata[i] = userdata[_idx][i]
      userdata[_idx][i]=0
    end
    vis_pos_x[_idx]=0 
    vis_pos_y[_idx]=0 
    vis_pos_z[_idx]=0
    vis_pos_rx[_idx]=0
    vis_pos_ry[_idx]=0 
    vis_pos_rz[_idx]=0 
    vis_pos_lbl[_idx]=0
    return _label
  end  
end
-- get pos and plandata
function mm_get_plan_pos(_idx,_pos) --return _movetype,_toolnum,_speed
  local _movetype=0
  local _toolnum=0
  local _speed=0
  if vis_pos_x[_idx]==0 and vis_pos_y[_idx]==0 and vis_pos_z[_idx]==0 and 
     vis_pos_rx[_idx]==0 and vis_pos_ry[_idx]==0 and vis_pos_rz[_idx]==0 then
      print("MM:pos data is empty")
      Pause()
  else
    _pos.coordinate = {vis_pos_x[_idx],vis_pos_y[_idx],vis_pos_z[_idx],
    vis_pos_rx[_idx],vis_pos_ry[_idx],vis_pos_rz[_idx]}
    _movetype = vis_pos_movetype[_idx]
    _toolnum = vis_pos_toolnum[_idx]
    _speed = vis_pos_spd[_idx]
    vis_pos_x[_idx]=0 
    vis_pos_y[_idx]=0 
    vis_pos_z[_idx]=0
    vis_pos_rx[_idx]=0
    vis_pos_ry[_idx]=0 
    vis_pos_rz[_idx]=0 
    vis_pos_movetype[_idx]=0
    vis_pos_toolnum[_idx]=0
    vis_pos_spd[_idx]=0
    if is_vispos[_idx]==1 then
      if g_resource==0 then
        for i=1,g_userdata_num do
          mm_userdata[i]=userdata[_idx][i]
          userdata[_idx][i]=0
        end
        if g_pos_type==3 or g_pos_type==4 then
          for i=1,21 do
            mm_plandata[i]=plandata[_idx][i]
            plandata[_idx][i]=0
          end
        end
      else
        if g_pos_type==1 or g_pos_type==2 then
          for i=1,21 do
            mm_plandata[i]=plandata[_idx][i]
            plandata[_idx][i]=0
          end
        end
      end
    end
    return _movetype,_toolnum,_speed
  end 
end
-- get jps and plandata
function mm_get_plan_jps(_idx,_jps) --return _movetype,_toolnum,_speed
  local _movetype=0
  local _toolnum=0
  local _speed=0  
  if vis_pos_j1[_idx]==0 and vis_pos_j2[_idx]==0 and vis_pos_j3[_idx]==0 and 
     vis_pos_j4[_idx]==0 and vis_pos_j5[_idx]==0 and vis_pos_j6[_idx]==0 then
      print("MM:jps data is empty")
      Pause()
  else
    _jps.joint = {vis_pos_j1[_idx],vis_pos_j2[_idx],vis_pos_j3[_idx],
    vis_pos_j4[_idx],vis_pos_j5[_idx],vis_pos_j6[_idx]}
    _movetype = vis_pos_movetype[_idx]
    _toolnum = vis_pos_toolnum[_idx]
    _speed = vis_pos_spd[_idx]
    vis_pos_j1[_idx]=0 
    vis_pos_j2[_idx]=0 
    vis_pos_j3[_idx]=0
    vis_pos_j4[_idx]=0
    vis_pos_j5[_idx]=0 
    vis_pos_j6[_idx]=0 
    vis_pos_movetype[_idx]=0
    vis_pos_toolnum[_idx]=0
    vis_pos_spd[_idx]=0
    if is_vispos[_idx]==1 then
      if g_resource==0 then
        for i=1,g_userdata_num do
          mm_userdata[i]=userdata[_idx][i]
          userdata[_idx][i]=0
        end
        if g_pos_type==3 or g_pos_type==4 then
          for i=1,21 do
            mm_plandata[i]=plandata[_idx][i]
            plandata[_idx][i]=0
          end
        end
      else
        if g_pos_type==1 or g_pos_type==2 then
          for i=1,21 do
            mm_plandata[i]=plandata[_idx][i]
            plandata[_idx][i]=0
          end
        end
      end
    end 
    return _movetype,_toolnum,_speed
  end  
end
-- calibration
function mm_calib(_movetype,_waittime)
  local send_data=""
  local calib_status=0
  local cur_pose=GetPose()
  mm_open_skt()
  send_data=sendcurpos(0)
  print(send_data)
  g_err=TCPWrite(g_socket, send_data, g_timeout)
  if g_err~=0 then 
    print("MM:socket send data failure")
    goto ENDLOOP
  end
  ::CALIBLOOP::
  g_err, recv_buf=TCPRead(g_socket, g_timeout, "string")
  if g_err~=0 then
    print("MM:socket recv data failure")
    goto ENDLOOP
  else
    local recv_data = decode(recv_buf.buf, ",")
    print(recv_data)
    g_mm_cmd=recv_data[1]
    g_mm_status=recv_data[2]
    if g_mm_cmd~=701 then
      print("MM:robot cmd error")
      goto ENDLOOP
    end
    if g_mm_status~=7101 then 
      print("Calibration Failed!")
      goto ENDLOOP
    end
    calib_status=recv_data[3]
    local cal_jps={joint={recv_data[10], recv_data[11], recv_data[12], recv_data[13], recv_data[14], recv_data[15]}}
    local cal_pos={coordinate={recv_data[4],recv_data[5],recv_data[6],recv_data[7],recv_data[8],recv_data[9]},
                   tool=0,user=0,load=0,armOrientation=cur_pose.armOrientation}
    if _movetype==1 then 
      Move(cal_pos, "CP=0 SpeedS=50 AccelS=50 SYNC=1")
    elseif _movetype==2 then
      MoveJ(cal_jps, "CP=0 Speed=50 Accel=50 SYNC=1")
    else
      print("MM:robot argument error")
      goto ENDLOOP
    end
    if calib_status==1 then
      print("MM:calibration finished")
      goto ENDLOOP
    end
    Sleep(_waittime*1000)
    --resend current robot status
    send_data=sendcurpos(1)
    print(send_data)
    g_err=TCPWrite(g_socket, send_data, g_timeout)
    if g_err~=0 then 
      print("MM:socket send data failure")
      goto ENDLOOP
    end
    goto CALIBLOOP
  end
  ::ENDLOOP::
  mm_close_skt()
end
function sendcurpos(_status)
  local data_buf=""
  local cur_jps=GetAngle()
  local cur_pose=GetPose()
  data_buf=string.format("%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r",701,_status,cur_pose.coordinate[1],
  cur_pose.coordinate[2],cur_pose.coordinate[3],cur_pose.coordinate[4],cur_pose.coordinate[5],cur_pose.coordinate[6],
  cur_jps.joint[1],cur_jps.joint[2],cur_jps.joint[3],cur_jps.joint[4],cur_jps.joint[5],cur_jps.joint[6])
  return data_buf
end

------------------------------------------------------------------------------------------------------------
----------------------------------------------Sample Functions----------------------------------------------
------------------------------------------------------------------------------------------------------------

--test connection between robot and ipc
function mm_comtest()
  mm_init_skt("192.168.5.22", 50000, 300)
  mm_open_skt()
  Sleep(500)
  mm_close_skt()
end
--standard interface auto calibration
function mm_auto_calib()
  mm_init_skt("127.0.0.1", 50000, 300)
  --Pause()
  --move to start point
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_calib(2,2)
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
end
--sample_1:get visdata from Mech-Vision
function sample_1()
----------------------------------------------------
--FUNCTION:simple pick and place with Mech-Vision
--mechmind, 2023-11-9
----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=4, user=0, load=0, armOrientation={1,1,1,-1}}
  local mm_status=0
  local pos_num=0
  local label_1=0
  local speed_1=0
  DO(1, ON)
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  --Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC
  mm_init_skt("192.168.5.22", 50000, 300)
  --open socket
  mm_open_skt()
  --set vision recipe if necessary
  mm_set_model(1,1)
  --run vision project
  mm_start_vis(2, 0, 1, JPS)
   Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  Sleep(1000)
  mm_status,pos_num=mm_get_vis_data(1)
  if  mm_status~=1100 then
   Pause()
  end
  label_1,speed_1 = mm_get_pos(1,pos_1)
  local pick_offset = {0, 0, 50}
  local pos_app=RP(pos_1, pick_offset)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  --DO(1, ON)
  DO(3, ON)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 100}
  local drop_app=RP(P3, drop_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, ON)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
end
--sample_2:get vizdata from Mech-Viz
function sample_2()
----------------------------------------------------
--FUNCTION:simple pick and place with Mech-Viz
--mechmind, 2023-11-9
----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local jps_1 = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_2 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_3 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local mm_status=0
  local pos_num=0
  local vpos_idx=0
  local label_1={0, 0, 0}
  local speed_1={0, 0, 0}
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC  
  mm_init_skt("127.0.0.1", 50000, 300)
  --open socket
  mm_open_skt()
  --stop Mech-Viz first if necessary
  mm_stop_viz()
  --run Viz project
  mm_start_viz(1, JPS)
  --set branch exitport
  mm_set_branch(1,1)
  --get planned path
  mm_status,pos_num,vpos_idx=mm_get_viz_data(2)
  if  mm_status~=2100 then
    Pause()
  end
  label_1[1],speed_1[1] = mm_get_pos(1,pos_1)
  label_1[2],speed_1[2] = mm_get_pos(2,pos_2)
  label_1[3],speed_1[4] = mm_get_pos(3,pos_3)
  Go(pos_1, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  --DO(1, ON)
  --DO(2, OFF)
  Go(pos_3, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 100}
  local drop_app=RP(P3, drop_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, ON)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
end
--sample_3:get vispath from Mech-Vision
function sample_3()
----------------------------------------------------
--FUNCTION:105_GET_VISPATH with Mech-Vision
--mechmind, 2023-11-9
----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}  
  local jps_1 = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_2 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_3 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}    
  local mm_status=0
  local pos_num=0
  local vpos_idx=0
  local label_1={0, 0, 0}
  local speed_1={0, 0, 0}
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC  
  mm_init_skt("127.0.0.1", 50000, 300)
  --open socket
  mm_open_skt()
  --set vision recipe if necessary
  mm_set_model(1,1)
  --run vision project
  mm_start_vis(1, 0, 1, JPS)
  --get planned path
  mm_status,pos_num,vpos_idx=mm_get_vis_path(1,2)
  if  mm_status~=1103 then
    Pause()
  end
  label_1[1],speed_1[1] = mm_get_pos(1,pos_1)
  label_1[2],speed_1[2] = mm_get_pos(2,pos_2)
  label_1[3],speed_1[4] = mm_get_pos(3,pos_3)
  Go(pos_1, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  --DO(1, ON)
  --DO(2, OFF)
  Go(pos_3, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 100}
  local drop_app=RP(P3, drop_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, ON)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
end
--sample_4:get plandata from Mech-Viz
function sample_4()
----------------------------------------------------
--FUNCTION:simple pick and place with Mech-Viz. 
--Example for Planned Results from Mech-Viz
--mechmind, 2023-11-9
----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_2 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_3 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local mm_status=0
  local pos_num=0
  local vpos_idx=0
  local movetype_1={0, 0, 0}
  local toolnum_1={0, 0, 0}
  local speed_1={0, 0, 0}
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC  
  mm_init_skt("127.0.0.1", 50000, 300)
  --open socket
  mm_open_skt()
  --stop Mech-Viz first if necessary
  mm_stop_viz()
  --run Viz project
  mm_start_viz(1, JPS)
  --set branch exitport
  mm_set_branch(1,1)
  --get planned path
  mm_status,pos_num,vpos_idx=mm_get_plan_data(0,4)
  if  mm_status~=2100 then
    Pause()
  end
  mm_get_dolist(0)
  movetype_1[1],toolnum_1[1],speed_1[1] = mm_get_plan_pos(1,pos_1)
  movetype_1[2],toolnum_1[2],speed_1[2] = mm_get_plan_pos(2,pos_2)
  movetype_1[3],toolnum_1[3],speed_1[3] = mm_get_plan_pos(3,pos_3)
  Go(pos_1, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  mm_set_dolist()
  Go(pos_3, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 100}
  local drop_app=RP(P3, drop_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, OFF)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
end
--sample_5:get plandata from Mech-Vision
function sample_5()
  ----------------------------------------------------
  --FUNCTION:simple pick and palce with Mech-Vision. 
  --Example for Planned Results from Mech-Vision
  --mechmind, 2023-11-9
  ----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_2 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local pos_3 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}  
  local mm_status=0
  local pos_num=0
  local vpos_idx=0
  local movetype_1={0, 0, 0}
  local toolnum_1={0, 0, 0}
  local speed_1={0, 0, 0}
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC  
  mm_init_skt("127.0.0.1", 50000, 300)
  --open socket
  mm_open_skt()
  --set vision recipe if necessary
  mm_set_model(1,1)
  --run vision project
  mm_start_vis(1, 0, 1, JPS)
  --get planned path
  mm_status,pos_num,vpos_idx=mm_get_plan_data(1,4)
  if  mm_status~=1103 then
    Pause()
  end
  mm_get_dolist(1)
  movetype_1[1],toolnum_1[1],speed_1[1] = mm_get_plan_pos(1,pos_1)
  movetype_1[2],toolnum_1[2],speed_1[2] = mm_get_plan_pos(2,pos_2)
  movetype_1[3],toolnum_1[3],speed_1[3] = mm_get_plan_pos(3,pos_3)
  Go(pos_1, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  mm_set_dolist()
  Go(pos_3, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local drop_offset = {0, 0, 100}
  local drop_app=RP(P3, drop_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, OFF)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
  end
--sample_6:get dydata from Mech-Vision
function sample_6()
----------------------------------------------------
--FUNCTION:simple pick and palce with Mech-Vision. 
--Example for custom data from Mech-Vision
--mechmind, 2023-11-9
----------------------------------------------------
  local JPS = {joint = {0, 0, 0, 0, 0, 0}}
  local pos_1 = {coordinate = {0, 0, 0, 0, 0, 0}, tool=0, user=0, load=0, armOrientation={1,1,1,-1}}
  local mm_status=0
  local pos_num=0
  local label_1=0
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --move to camera capture position
  Go(P2, "CP=0 Speed=50 Accel=100 SYNC=1")
  --set IP address of IPC
  mm_init_skt("127.0.0.1", 50000, 300)
  --open socket
  mm_open_skt()
  --set vision recipe if necessary
  mm_set_model(1,1)
  --run vision project
  mm_start_vis(1, 0, 1, JPS)
  mm_status,pos_num=mm_get_dy_data(1)
  if  mm_status~=1100 then
    Pause()
  end
  label_1 = mm_get_dypos(1,pos_1)
  local app_offset = {0, 0, 100}
  local pos_app=RP(pos_1, app_offset)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(pos_1, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object grasping logic here.
  --DO(1, ON)
  --DO(2, OFF)
  Go(pos_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to drop position
  local app_offset = {0, 0, 100}
  local drop_app=RP(P3, app_offset)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  Go(P3, "CP=0 Speed=50 Accel=100 SYNC=1")
  --Add object releasing logic here.
  --DO(1, OFF)
  --DO(2, ON)
  Go(drop_app, "CP=50 Speed=100 Accel=100 SYNC=0")
  --move to home position
  Go(P1, "CP=0 Speed=50 Accel=100 SYNC=1")
  mm_close_skt()
end
