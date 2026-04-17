pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--megaman prototype v0.1
--by jadelombax

function _init()
 cls()
 lvlnum=1
 levselect=true
 move_data()
 decompress(sprites,sset)
 decompress(map_mem,mset)
 --turn off btnp repeat
 ?"⁶!5f5c◝"
 lvl_pals={
 "1,2,3,132,5,6,7,8,9,10,11,12,13,12,15",
 "128,2,132,4,133,6,7,8,9,10,11,142,13,140,15",
 "128,2,3,131,140,6,7,8,1,10,11,12,13,12,15",
 "1,2,139,4,5,6,7,8,9,10,11,138,13,12,15",
 "1,2,3,4,5,6,7,8,142,10,2,12,13,0,15",
 "128,2,137,4,132,6,7,8,9,10,11,12,13,1,15"
 }
end

function _update60()
 if levselect then
  lvl_select()
 else
  play_lvl()
  tic+=1
 end
 --letterboxing
 memset(vals"24576,0,256")
 memset(vals"32512,0,256")
 camera(0,-4)
end

function lvl_select()
 palt(14,_)
 pal(split"128,140,132,4,132,6,7,8,9,2,11,142,13,12,15",1)
 cls(2)
 lvlnum=loop_tbl(lvlnum+btnp()\2%2-btnp()%2,6)
 for i=1,6 do
  if(i==5) pal(11,10) else pal(11,11)
  local x=split"40,72,90,72,40,22"[i]
  local y=split"18,18,52,86,86,52"[i]
  --blinking cursor
  pal(10,lvlnum==i and 14+t()\.25%2 or 14)
  --boxes
  sd("\0\0⁶⁶J\0□⁶「A□\0「⁶A■□▶「A■\0▶⁶J「²「‖!³「⁘「!\0■⁶▶J■■▶▶J²\0⁘▶j\0³▶‖j¹²¹‖'²◀‖◀'²¹‖¹'◀²◀‖'³³⁘⁘`",x-4,y-4)
  map(14+i*2,10,x,y,2,2)
  ?split"CUTMAN,GUTSMAN,ICEMAN,BOMBMAN,FIREMAN,ELECMAN"[i],x-4,y+21,7
 end
 if btnp(❎) then
  setup_lvl()
  levselect=_
 end
end

function setup_lvl()
 fg_array={}
 build_array(fg_array,lvlnum)
 fgw,fgh=lvl_width,lvl_ht
 --
 spawnpoints,
 entities,
 bullets,
 explosions={},{},{},{}
 --
 camx,
 px,
 pdx,
 pdy,
 jump_vel,
 extra_dx,
 energy,
 weapon,
 mnu,
 teleport,
 hitdir,
 damage,
 pit,
 pflip
 =vals"0,64,0,0,2,0,28,1,-1,1,0"--_,_
 --
 camy=split"960,0,0,480,240,2400"[lvlnum]
 py=camy-32
 --
 starttimer,
 phasetimer,
 onground,
 jumptimer,
 blinktimer,
 shottimer,
 dmgtimer,
 deathtimer,
 tic
 =vals"0,0,0,0,0,0,0,0,0"
 weapon_energy=split"28,28,28,28,28,28,28,28"
 palt(0)
 palt(14,1)
end

function play_lvl()
 --lvl palette
 pal(split(lvl_pals[lvlnum]),1)
 cls(14)
 --mm palette
 local mmcols=
 split(split("12,140 7,3 9,5 7,4 7,140 7,5 9,8 12,140"," ")[weapon])
 
 pal(10,mmcols[1],1)
 pal(2,mmcols[2],1)
 
 map_array(fg_array,1,0,0)
 
 if starttimer<144 then
  ?'ready',54,cycle("57,192",8),7
  starttimer+=1
 else
  if mnu<0 then
   update_bullets()
  end
  if energy>0 then
   if mnu<0 then
    update_character()
    draw_character()
   end
  else
   if not pit then
    boss_explosion()
   end
   if deathtimer>150 then
    setup_lvl()
   end
   deathtimer+=1
  end
   if mnu<0 then
    energy_meter(energy,vals"12,8,15,7,1")
    if weapon>1 then
     energy_meter(weapon_energy[weapon],vals"8,8,2,10,1")
    end
   end
  end
 menu()
end

function scroll_limit()
 --x-axis
 for e=0,1 do --edge
  for d=0,1 do --move dir
   if aget(camx+d*127.9,camy+e*119.9)==2 then
    camx=(d>0 and flr or ceil)(camx/128)*128
   end
  end
 end
 --y-axis
 cpy=py\120*120
 if camy!=cpy and
 not teleport and
 aget(px,py)!=2 then
  camy=mid(camy-2,cpy,camy+2)
 end
end
-->8
--player

function update_character()
 local b=btn()
	if teleport then
	 b,g,cyos,syos,tvel=vals"0,4,3,2,8"
	else
	 g,cyos,syos,tvel=vals".225,0,0,4"
	end
	--jumping
	if btnp(❎) and
	 onground>0 and
	 dmgtimer<80 then
	 pdy=-jump_vel
	 jumptimer=10
	end
	--variable jump height
	if jumptimer>0 then
	 if (btn(❎)) g=.02
	 jumptimer-=1
	end
	--water gravity
	if afget(px,py)==16 then
	 g=.032
	end
	--gravity & terminal vel.
	pdy=min(pdy+g,tvel)
	--dpad input
	xbtn=b\2%2-b%2
	ybtn=b\8%2-b\4%2
	--x movement
	if camy==cpy or py<1 then
	 pdx=xbtn
	 if xbtn!=0 then
	  pflip=xbtn<0
	 end
	else
	 pdx=0
	end
	if onground>2 then
	--running animation
	 if abs(pdx)>.1 then
	  pspr=cycle("194,196,198,196",8)
	 else pspr=192
  end
 --in-air sprite
 else pspr=200
 end
 --shooting animation
 if shottimer>0 then
  pspr+=32
 end
 --x velocity
 pdx=mid(-1,pdx,1)+extra_dx
 --ladder position bitfield
 local ladderval=0
 for i=0,2 do
  if aget(px,py+pdy-3.5+i*5)==16 then
   ladderval+=2^i
  end
 end
 sxos=0
 --climbing
 if climbing then
  pspr,pdx=202,0
  pdy=ybtn/2
  cflip=py%8<4
  if shottimer>0 then
   pspr,pdy=234,0
  end
  if btnp(❎) or ladderval==0 then
   climbing=_
  end
 end
 --sprite x-offset
 if pspr==224 or pspr==234 then
  sxos=pflip and -2 or 2
 end
 extra_dx=0
 --damage
 if damage and dmgtimer==0 then
  energy-=damage
  dmgtimer=120
 end
 if dmgtimer>0 then
  if dmgtimer>=80 then
   pspr=cycle("204,204,206",2)
   pdx=hitdir*.25
	 else
   pspr=tic%2>0 and pspr or 256
  end
  dmgtimer-=1
 end
 damage=_
 ----map collision
  if py>camy+60+lvlnum\5*16 
  or not teleport then
  for i=-1,1 do
	  --x-axis
	  local xfget=afget(px+pdx+sgn(pdx)*3.99,py+i*5.99)
	  if flag(xfget,0) or
	  (flag(xfget,5) and py>camy+8
	  and py<camy+99) then
	   px=(pdx>=0 and flr or ceil)((px+3.99+pdx)/8)*8-4
	   pdx=0
	  end
	  --y-axis
	  local yfget=afget(px+i*3.99,py+pdy+sgn(pdy)*5.99)
	  local yfget2=afget(px+i*3.99,py+pdy)
	  --ground
	  if (pdy>0 and flag(yfget,0))
	  --top of ladder
	  or (pdy>0 and flag(yfget,3) and not flag(yfget2,3) and not climbing)
	  --surmounting ladder
	  or (pdy<0 and climbing and ladderval==4) then
	   py=(py+5.99+pdy)\8*8-6
	   pdy=0
	   climbing=_
	   onground=4
--    --conveyor belts
--    for j=1,2 do
--     if flag(yfget,j) then
--      extra_dx=split"-.75,.75"[j]
--     end
--    end
   --ceiling
   elseif flag(yfget,0) and pdy<0 then
    py=ceil((py+pdy)/8)*8
    pdy=0
   end
  end
 end
 --spikes
 if flag(afget(px,py+5),7) then
  energy=0
 end
 --pits
 if py>camy+90 and aget(px,py-8)==2 then
  energy=0
	 pit=true
 end
	local function grab_ladder()
	 px,pdx,climbing=px\8*8+4,0,true
	 mmflip=pflip
	 pspr=202
	 sxos=0
	end
 if not climbing and ladderval&1>0
  and ((onground<=0 and ybtn!=0) or (onground>0 and ybtn<0)) then 
	 grab_ladder()
	end
	if ladderval==4 and ybtn==1 then
  grab_ladder()
	 py+=4
	end
 px=mid(4,px+pdx,fgw*8-4)
	if cpy==camy
	or teleport
	or aget(px,py)==2
	or py<1 then
	 py+=pdy
	end
	--camera
	camx=px-mid(50,px-camx,64)
	camx=mid(0,camx,fgw*8-128)
	scroll_limit()
	--
 if climbing and shottimer<0 then
  mmflip=cflip
 else mmflip=pflip
 end
 shottimer-=1
	if teleport then
	 pspr=236
	 if onground>0 then
	  phasetimer,
	  teleport=0
	 end
	end
	if phasetimer<8 then
	 pspr=cycle("236,238,238,236",2,phasetimer)
	 pdx,
	 pdy,
	 extra_dx,
	 extra_dy,
	 cyos,
	 syos=vals"0,0,0,0,3,2"
	 phasetimer+=1
	end
	if btnp(🅾️) and phasetimer>7 and not teleport then
	 add_mm_bullet()
	end
	if(onground>0) onground-=1
end

function draw_character()
 pal(split"1,2,7,7,0")
 --blinking
 if pspr==192 then
  blinktimer+=1
  if blinktimer%120>109 then
   pal(split"1,2,15,13,13")
  end
 else blinktimer=0
 end
 --draw sprite
 spr(pspr,px-camx+sxos-8,py-camy-7,2,2,mmflip)
 --reset pal
 pal(split"1,2,3,4,5")
end

function add_mm_bullet()
 local bx=px+(pflip and -8 or 8)
 local by=py
 local dir=pflip and -1 or 1
 local max_t=split"99,99,99,99,99,62,99,99"
 local bv=(btn()\8%2-btn()\4%2)*3
 if #bullets<3 then
  add(bullets,{enmy=_,x=bx,y=by,w=weapon,dir=dir,t=0,t_max=max_t[weapon],v=bv})
 end
 shottimer=15
end

function update_bullets()
 for b in all(bullets) do
  bt=b.t
  --buster
  --bomb(arc down)
  --elec(wave)
  --guts(arc down)
  --ice(fast)
  --cut(oval)
  --fire(fast)
  --m.beam(slow)
  local bdx=({3,2.5,2,3,3.5,trig(1,64,-2.2),3.5,2})[b.w]
  local bdy=({0,trig(1,240,-6),trig(2,24,-3),trig(1,240,-4),0,trig(2,64,-1.3),0,0})[b.w]  b.x+=bdx*b.dir
  b.y+=bdy
  b.t+=1
  bspr=0
  spr(bspr,b.x-camx-4,b.y-camy-4)
  --delete if offscreen
  if abs(b.x-(camx+64))>96
  or abs(b.y-(camy+64))>96 
  or b.t>b.t_max then
   del(bullets,b)
  end
 end
end

-->8
--general functions

function recolor_tiles()
 pal(split(({
 "1,4,4,11,4",
 "1,5,14,6,5",
 "1,5,5,12,5",
 "1,5,14,6,14",
 "0,5,8,6,13",
 "1,5,4,9,3"})[lvlnum]))
 if lvlnum==5 then
  col_cycle(8,"9,8,11",8)
  col_cycle(9,"8,11,9",8)
  col_cycle(10,"11,9,8",8)
 end
end

function trig(fn,speed,mult)
 return mult*({sin,cos})[fn](bt/speed)
end

function loop_tbl(v,vmax)
 return (v-1)%vmax+1
end

function cycle(str,frames,timer)
 timer=timer or tic
 local tbl=split(str)
 return tbl[timer\frames%#tbl+1]
end

function col_cycle(col,str,frames)
 pal(col,cycle(str,frames))
end

function aget(x,y)
 local ay,ax=fg_array[y\8],x\8
 return ay and ay[ax] and ay[ax]&255 or 2
end

function afget(x,y,f)
-- return f and fget(agetf(x,y,f))
 return fget(aget(x,y))
end

function flag(v,f)
 return v&2^f>0
end

function energy_meter(val,x,y,col1,col2,typ)
 --type: 0-horiz 1-vert
 local j=23*typ
 rectfill(x,y,x+27-j,y+4+j,0)
 for i=1,ceil(val/2) do
  if typ==1 then
   local k=y+24-i*2
   ?'³h_',x,k,col1
   ?'³h.',x,k,col2
  else
   local k=x+i*2
   ?'³f⁶x1c',k,y,col1
   ?'⁵ee.',k,y,col2
  end
 end
end

function menu()
 menuitem(1,"stage select", function() levselect=true end)
 if btnp(6) then
  poke(24368,1)
  if starttimer>=144 then
   mnu*=-1
   phasetimer=0
  end
 end
 if mnu>0 then
  --draw menu
  fillp'1892'
  rectfill(vals"48,20,95,95,118")
  fillp'1911.5'
  rectfill(vals"48,20,96,96,1")
  fillp'0'
  pal(14,split"5,3,4,4,11,4,0,0"[lvlnum])
  rectfill(vals"53,25,91,91,14")
  --select weapon
  weapon=loop_tbl(weapon+btnp()\8%2-btnp()\4%2,8)
  for i=1,8 do
   local c=weapon==i and cycle("7,14",8) or 7
   ?("pbegicfm")[i],55,20+i*8,c
   energy_meter(i==1 and energy or weapon_energy[i],62,20+i*8,15,7,0)
  end
 end
 pal(14,14)
end

--use string as list of values
function vals(str)
 return unpack(split(str))
end

function boss_explosion()
 for i=0,1.75,.125 do
  j=deathtimer*(1-i\1/2)
  if i<1 or i%.25==0 then
   circfill(px-camx+sin(i)*j,py-camy+cos(i)*j,cycle("2,4",1),cycle("2,10",3))
  end
 end
end

function sd(s,x,y)
 fn_tbl={line,oval,ovalfill,rect,rectfill,trifill}
 camera(-x,-y)
 for i=1,#s,5 do
  fn_tbl[ord(s,i+4)\16-1](ord(s,i,5))
 end
 camera()
end
-->8
--picomap functions

function move_data()
 map_tbl={}
 for i=0,8191 do
  add(map_tbl,@i\16)
  add(map_tbl,@i%16)
 end
end

function decompress(str,set)
 local n,w,k=0,ord(str,1,2)
 for i=3,#str do
  local v=255-ord(str,i)
  for l=0,v\16^k do
   set(n%w,n\w,v) n+=1
  end
 end
end

function build_array(array,lvlnum)
 screen_num,screen_ht,bops,map_obs=0,ord(def_str,1,3)
 --lvl data loc.,autotile bit tbl,autotile bit
 local l,atb,atbit=loc_tbl[lvlnum],0,{}
 --reads table values
 local function t(n)
  local q=n\2
  local v=map_tbl[l]*16^q+map_tbl[l+1]*q 
  l+=n
  return v
 end
 --lvl header
 lvl_type,bgc,lvl_width,lvl_ht,bgtile=t'1',t'1',t'2'*16+16,t'2'*screen_ht+screen_ht,t'2'
 --create array
 local function create(s,e,v)
  for row=s,lvl_ht+e do
  if(s==0) array[row]={}
   for col=s,lvl_width+e do
    array[row][col]=v
   end
  end
 end
 create(0,2,0x.3f)
 create(2,1,bgtile)
 while l<loc_tbl[lvlnum+1]-1 do
 
  obnum,screen_num_b=t'2'
  --next screen flag
  if obnum==0 then
   screen_num+=1 obnum=t'2'
  --screen jump & return
  elseif obnum==251 then
   screen_num_b,screen_num,obnum=screen_num,t'2',t'2'
  --screen jump
  elseif obnum==252 then
   screen_num,obnum=t'2',t'2'
  end
  
  --obj position
  local xpos,ypos=t'1',t'1'
  local xp=xpos+screen_num*16
  --obj def data
  local scx,scy,ds,vi=ord(def_str,obnum*4,4)
  local dw,dh,typ,ati,draw=ds\16+1,ds%16+1,vi\16,vi%16/2,1
  --obj type traits
  local tbl,mso,k={},typ\13,split"¹¹²¹³³,⁷¹²¹³³,¹⁷²¹³³,⁷⁷²¹³³,⁷⁷¹¹²²,⁷¹¹¹⁵⁶,¹⁷¹¹⁵⁶,⁷⁷¹¹⁵⁶,_,⁷¹¹²⁴⁴,¹⁷¹²⁴⁴,⁷⁷¹²⁴⁴,_,⁷¹¹¹⁵⁶,¹⁷¹¹⁵⁶,⁷⁷¹¹⁵⁶"[typ+1]
  for n=1,6 do
   z=ord(k,n)
   add(tbl,({0,1,256,bops,dw,dh,t(z\7)})[z])
  end
  xv,yv,sb,eb,psx,psy=unpack(tbl)
  --total obj w&h
  local tw,th=max(dw+xv,xv*16*mso)-1,max(dh+yv,yv*screen_ht*mso)-1
  if(obnum==58)psx,psy=2,2
  if(obnum==78)psx,psy=4,4
  --if entity obj
--   if obnum>map_obs then
--    draw=_
--   end
  if draw then
   --x&y start pos.
   local sx,sy=xp%lvl_width,ypos+xp\lvl_width*screen_ht
   for x=0,tw do
    for y=0,th do
     local px,py,ax,ay=(x-dw)%psx,(y-dh)%psy,sx+x+2,sy+y+2
     local tile=mget(scx+(x>=dw and sb*dw+px+eb*(x\tw*(psx-px)+dw) or x),scy+(y>=dh and sb*dh+py+eb*(y\th*(psy-py)+dh) or y))
     if array[ay] and array[ay][ax] then
      if tile>0 then
       if at_list[tile] and not atbit[tile] then
        atbit[tile]=.125>>atb
        atb+=1
       end
       array[ay][ax]=tile+ati+array[ay][ax]%.5|(atbit[tile] or 0)
      end
     end
    end
    screen_num=screen_num_b or screen_num
   end
  end
 end
 --autotiling
 for y=1,lvl_ht do
  for x=1,lvl_width do
   local tile=array[y+1][x+1]\1
   local v1,v2,n=tonum(at_list[tile]),atbit[tile],256
   if v1 then
    for i=0,8 do
     local id=array[y+i\3][x+i%3]
     if id\1!=tile and id&.5>0 or id&v2==0 then
      n+=ord("▮¹ ²\0⁴@⁸█",i+1)
     end
    end
    local btx,bty,nto=v1&127,v1\128,ord("ᶜ⁷ᵇ⁶\r⁸\n⁵■²▮¹□³ᶠ\0ᶜ⁴	ᶜ⁙ᶜᶜᶜᵉᶜᶜᶜᶜᶜᶜᶜ",(n%16<1 and n\16 or n%16)+1)
    tile=mget(btx+nto%5,bty+nto\5)
    if tile==1 then
     tile=mget(btx+5+x%(v1<<4&15),bty+y%(v1<<8&15))
    end
   end
   array[y-1][x-1]=tile
  end
 end
end

function map_array(array,scroll_coef,x_offset,y_offset)
 local ht,w,cx,cy=#array-2,#array[1]-2,camx*scroll_coef,camy*scroll_coef
 local px,py=cx\8+x_offset,cy\8+y_offset
 for row=0,screen_ht do
  local r=(row+py)%ht
  for col=0,16 do
   mset(111+col,row,array[r][(col+px)%w])
  end
 end
 local function map_f(f)
  map(111,0,-(cx%8),-(cy%8),17,16,f)
 end
 map_f()
 recolor_tiles()
 map_f(64)
 pal(split"1,2,3,4,5,6,7,8,9,10,11,12,13,14")
end

-->8
sprites="█¹¹➡️ン²웃ッスン「ンヲッ◜ン⁸そラAッなッ¹¹ニンヨrなラ◝ラトラヤッヲンヲラヲ)ランッ◜ン⁸そ◜qミロ◜ヒ◜ヒ◜ミモAヤ¹ンニr◜るンラヨン◜ニン◜ヨッヲンヲラヲ)ランッ◜ッヨンヨンヨンヨンヨンヨンヨンヨンヨンヨンヨン◜➡️ャッᵉq◝ヘ◝!ンカyラゃヲンヨン◜ニン◜ヨッ²のッ◜ヨᶠに➡️ャロ◜ャ●◜ャ◜ロャテ▒◝ヘ◝1ンりyラゃヲンヨン◜ニン◜ヨッ⁸スンヲッ◜ン⁸そラねッモサなすタ◜▒ヤ1ンねyラゃヲンヨン◜ニン◜ヨッヲンヲラヲ)ランッ◜ン⁸そ◜りャロ◜ロモい^¹ねンくyラまンヨン◜ニン◜ヨッヲンヲラヲ)ランッ◜ッヨンヨンヨンヨンヨンヨンヨンヨンヨンヨンヨン◜カッモF◜ロ◜ロ◜ヒタ◜¹カン➡️	ヨン◜ニン◜ヨッ²のッ◜ヨᶠにカャロ◜ヒャᵉウャ◜ニ◝ョゅョ◝カ◜り◆	ヨン◜ニン◜ヨ◜ランヲラヲ)ランッ◝◜ヘ◜ンHンヲン◜ヘ◜ニな¹◜ロミモニラそラカ◜り◆yけンヨン◜ニン◜ヨ◜ランヲラヲンッyッホランッ◝◜ヲン◜ンHンヲヨ◜ホ◜ヨミを◜くむね◜ロモャモヨョつョニ◜ヲ◜カ◆yラゃヲンヨン◜ニン◜ヨ◜ランヲラヲセっラたランッ◝◜ヲン◜」ヨ◜ホ◜ヨャすりマサッャッ◜カヒタモヨ◝と◝ニ◜ヲ◜カ◆yラゃヲンヨン◜ニン◜ヨ◜ランヲラヲセのたランッ◝テン゛ヨラテヨおカッヒソヒミ◜ニおヨ◝ョゅョ◝ヨ◜ヲンョ◜ニ◆yラゃヲンヨン◜ニン◜ヨ◜ランヲラヲセッゃッみランッ◝◜ヘ◜ヲンソみソンラヨ◜ヘ◜ャロ◜ヒ◜ロ◜ニ◜ロャ◜タ◜ッ◜ャッ◜ヨロ◜ロ◜ャ◜ャ◜ラそラヨ◜ヲンョ◜ニ◆yラゃヲン☉◜ランヲラヲンッホむホッホランッ◝◜ヲン◜ヲ◜セ◜セ◜セ◜ラヨ◜ホ◜ッテャテニャサャロャロャヒャ◜ヨロャロ◜ャ◜ャ◜ョつョ◜ヲンヲョャ◜ヨ◆yラまy◜ランヲラヲ)ランッ◝◜ヲンモンヘッン◜ン◜ンヘッン◜ヨ◜ホ◜ャロ◜ヒ◜ロ◜ヨャッ◜ッ◜ッ◜ッ◜ッ◜ッ^◝と◝◜ヲンヲョャ◜ヨ◆	웃◜ランヲラヲ)ランッ◝テンヘセッン◜ンヲセッラヨラテャおヨロッ◜ロ◜ロ◜ロ◜ロ◜ャ◜ッモロ◜ャ◜ミ◜ュヲミ◜ャ◜ャ◜ャ◜ミヲャ◜ぬャ…ャ`웃²ロ◜ヒ◜ロ◜ロ◜ヘ◜ヘセッセヲセッラヨ◜ヘ◜ャ∧ヨロKッモロ◜ャ◜ミ◜ヲ◜ヘ◜ヲ◜ヲ◜ヲ◜ヘミ◜ャろャユノャきルッろッル⌂ラ/ヲ~ヲン◜ヲラホヌン◜ンラホキヨ◜ホ◜ャ◜ャ◜ャ◜ャ◜ヨャサ◜ロ◜ロ◜ロ◜ロ◜ャ~ラヲミ◜ャ◜ャ◜ャ◜タ◜ミろャユノャユひ◆ラ◝ラ◝ラ◝ラ◝ラ◝ッoッ◝ヲ●◜ヲンモンマラン◜ヲ◜ンマラン◜ヨ◜ホ◜ャ∧ヨャモャ◜ャ◜ャ◜ャモミ◜ヒめ◜ラヲャ>らャよユろユ◝ユろャ◝ン◝ン◝ン◝ン◝ラ◝ンoン◝ヲ^ンヲ◜セ◜ヲンヲ◜セ◜ラヨラテャ◜ロモヒ◜ニャfャ◜ヨ🅾️ラヲミ◜ャ◜ャ◜ャ◜ミ◜ャヲろャ…タユ⬅️ラ◝ラ◝ラ◝ラ◝ラ◝ラoラ◝ヲロ◜ロ◜サモヘ◜ヲン◜ン◜ヲセヲ◜ン◜ンラヨ◜ヘ◜ヨ◜ャモミ◜ニッモッ◜ゅモッ◜ヨロャ◜タ◜ヨャラヘ◜ヲ◜ヲ◜ヲ◜ヘャ◜ャろャユさャノp☉ラ◝ヲoヲ◝ヲロ◜ロなヲン◜ヲ◜セ◜セ◜セ◜ラヨ◜ホ◜ヨャへ◜カッミヒャヒミ◜ニロャ◜ミモヨヲ◜ミ◜ャ◜ャ◜ャ◜ミヲャ◜ろャユさャノユルッろッル웃ラ◝ンoン◝ヲロ◜ロ◜サモヲンモンヘッン◜ン◜ンヘッン◜ヨ◜ホ◜ヨおりマャ◜ャ◜ャモカャなヨNャヲャ◜よ⬅️_웃ラ◝ッoッ◝ヲ^ンヘセッン◜ンヲセッラヨラテニャ◜ロ◜ロ◜くッウねモタ◜ニ~スウラオャラきャナ◝	\n➡️ロャ◜Qッヒモラ➡️ミ⁶をょモニセヌセ◜ヲ◜ヲラヲャ◜ユケャユさャユルャ	ッ(ッ➡️ャッラAモロャ◜▒ᵉnカ~タウユケャユノラノミユルャホBッンッのンモン◜るッ➡️ロャ◜Qッヒモラqャ◜ロ◜ャ◜ャ◜vタ◜ミ◜りセヌセ◜ャ◜ャラヲャ◜•◝ンッヲ◜ヲ◜ヲ◜ヲ◜ヲ◜ヲ◜ン◜ンッるンス◜キッン➡️ャッラAモロャ◜a◜ミへモヒ◜ロ◜ょテね~タウャナャオャラナャオ◝ンッラ◜ラ◜ラ◜ラ◜ラ◜ラ◜ラ◜ホゅゆソホ➡️ロャ◜QッヒモラQ◜ミ◜ロ◜サ⬅️◜ャ◜くセヌセ◜ュ◜ュラヲャ◜ャユルャユノャユノャユルラ◝ホ>	ン➡️ャッラAモロャ◜Aッᵉ◜➡️~チウャユルャユノャユノャユノ◝	ホッセウセッホ➡️ロャ◜Qッヒモラ!ッ◜ャ◜ミ◜ミ◜ャテqセヌセウラヲャ◜ミラミラタラめ◝	▥モ▥➡️ャッラAモロャ◜¹ヨッなッA◆ヘセワっセワヲラ▤ッ◆ワトワトルトルトワトワトサミッナロらタサミユャッニオロャッャをッニャュミュネュリュ◝ッ◜トンスンス◆ンヲセワセヲセワンッヲッゃマ○ワ◝ワ◝ワ◝ワ◝ル◝ル◝ル◝ル◝ワ◝ワ◝ワ◝ワナロッャサャロタッャロナャッナッャヨヒャロャヤタモミヨャュミュミュャュ◜ャット☉◆ンヲッランワホッヲッランワッルヲたッ웃ヤワトワトルトルトワトワ◝らッミオロャッャらャッヒャッユヒミ◜ャぬ◜ッャロムミュタク◝テ◝ヲリスンヘュックッネャヲッヲンワミ◝ヲッヲンワヤ♥⌂◝ワ◝ワ◝ワ◝ワ◝ル◝ル◝ル◝ル◝ワ◝ワトワオャッぬロャぬロャッナロャナャロャきャ◜ッナクょュタ◝ャッャ◜ンッスランヲュッリムッリュヘラヲンワっラヲンワヲラヲラヲラヲラヲラ◝ントンヤワトワトワトワトワかユミッぬャロャロらャッオロャユミロャらロャ◜ャオミムれタュネ◝ュラヲラヲンマ◜ッリムゅンヲセワセヲセワンッンッンッンッンッ◝ントントワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワトワ◝ワミッロオロャッャッャサャッオロャッロミ◜ャサミ◜ャらミチミュクタリ◝ンヲッヲッラヲマリムックンヲセワホッヲセワッルワルワルワルワル◝ントンエワトワトワトワかワ◝ナミをャッオャロャッユャヒミッャ◜ャユミロャヒタサミムkュ◝ンヲラッヌヲ◜むリムャヲセワミ◝ヲセワ_ントントワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワ◝ワヒャらャッロらミナロャロャッタオロミナミロナロミュャュクつムンヲッヘラヲ◜クッネュッン◝ンoン◝ホラヲホランッ웃ᶠヤルよミロぬャヒナロャッ◆ャへャ◜ミロぬュミムクュクュネュンヲッキヲ◜リムッリムッン◝ンoン◝ホひンッンちンᶠ◝ろトナャヒャロマャをミ█モをャ◜タヒャユャュネュょュタュミュンヲッヘラヲ◜リュちン◝ン◝웃ッン◝ホルヲホルンッホヘルラルラトワᶠエオょオャヒャッユヒヤヒヤャをャ◜ロナロょッ◝ミネタュタュミ◝ンヲッキヲ◜ュックッネン◝ンoン◝ホひンッンヲッンヘルヲヤワロワ_ワヤワ◝ワ◝ワらャッぬャッオロヤヒヤロオロャ◜ロきャッユ◜ャュミュネュミネュヤンヲッヘラヲ◜ュッリムッリュン◝ンoン◝ホラスランッンマンルンルンワルワルロルgャヤワ◝ワ◝ワユヒャッロぬッロ ロ◜ぬロャマナ◜◝タュャュネュミ◜ャュンヲッキヲ◜ッリムゅン◝ンoン◝ホラッンッランッゃ◜ワ◜ワトロOフ◝ロ◝ロ◝ロタッユリをャッロオト◜ャトヒャッャオロャヒッャヒ◝ャ◝ミュャュミュミ◜ャュンヲッヘラヲ◜ッリムックン◝ン◝웃ッン◝ホラヲホランッンマントヲᶠケ◝ろャッオャサミッャヒャヤャ◜ロトヨミマサャテユ◜ャヨ◝◜ャ◝モャュミュ◝ュ◝ュ◝ンヲッキヲ◜むリムン◝ンoン◝ンラひラッゃラヘᶠトロよらャッぬッャヒッヤャ◜ロトニユャッヒャ◜オロ◜ニエャュ◜ャモ◝ミトンヲッヘラヲ◜y◝ン◝☉◝ン◝ンᶠᶠそンヘッゃヲッホりヲンニワリ◝ワニュ◜◝ュ◝ッュ◜➡️ミュミュネュャュタュネ◜マキヲ◜○ルン◝ヲッゃッン◝ンルかルかッᶠ◝たッンヲマホッヲッ◜ホニヲン◜ヨせヨ◜◝ムヤムね◜タュミュミュャュミムミンヲッヘラヲ◜iラ◝ヲ▥◝ラホヤひトむヤロトロᶠヤヲッゃヲッン◜ホヲン◜ンシマシヤッュ◜◝ッュニ◝ャ◝ャネムミュタクュャュミ★◜Oヲンッヤッホᶠエロわサにワロンッンランッホヲよヲッンヨ◜ヲン◜ヨンリワッリワッワリュ◝◜ムヤュヨヤ◜◝ミュクょュミアミ◜そ◜◝ントンヤまホマセっ♥😐レロレフヒレエロワロレセラゃヲッゃヲッンヨヲン◝ラヨン◝ワッフッワ◝ッ◝◜ムヤュャ◝ャリッミュミムれタュクュ◜け◜◝ントンヤヲッIッンワめロワュむンュワレワヒハワヤレワロハワセラゃヲマホッヲッンヲンモンランシマシヤムッ◝◜ュヤミックミチミュタュミムラお◝ントンヤヲセあラゃワャへワュッみュロワハワヒワ◝ロワレヒワロンッンランッホラッゃラッヲン◜ニ◜ンラヨせヨヤッュヤムクャ◝ミュミムょれタュンヲッキヘ◝ントンヤヲセッにヲゃ♥😐ワサレワサワレロレワヒ⌂ヲッゃヲッン◜り◜ンニワリ◝ワニュヤュ◝◜ュ◜リミ◝タュミュャュクュミュミムンヲッヘヌ◜◝ントンヤヲセッにヲゃ♥😐かロレロハワヒレヲッみマゃッヲッ¹●ュリくュクャネムャムれンリセリホ◝ントンヤヲセッにヲゃワめロワュむンュにロレワへハヲマホッンソホマヲッ¹●ャッ◜ねュミュタュャクタュ☉◝ントンヤヲッホラ▤ホッンワャへワュッみュよロレサシヒワヲッみマゃッヲッ¹●ク◜りュミュタムミュタュリ◜ク◜ネ◝ントンヤヲ」♥😐よワロんへヲにマエッヲッ⬇️▒●ミュャリャニュミリュクュャネュク🅾️◝ットッにヲ▥エ♥😐エワロワサコヒレヲッみマゃッヲッ◝フヤフ◝ワ◜ワ◜ワ◜ワ◜●タモムヨネミュミチミュミュンリセリIラ◝ヲ▥◝ラホワめロワュむンュエサコフロハワヲマホッンソホマヲッ😐▒●タ◝ネ◜ヨャュミリミュネミュミュ☉○ルン◝ヲッゃッン◝ンル◝ワャへワュッみュトハロレワ∧ワラッみマゃッラッ¹●クュミ◜ヨャュネュミュャュれャュリ◜ク◜ネy◝ン◝ヲ▥◝ン◝ン♥😐トレロワヒフコフロヲッみマゃッヲッ¹●ミムタ◜リタュミリャュょュリ🅾️¹ヘン▒ヲヨラニッリ▤リヲネラリ○⬅️ヲユタヲユッヘャヘャヲロヘャユヲロャヲ◆ち◜ャち◜ょ◝ロミ○ねス➡️ヲンヨヲン➡️ヘカッリ▤リヲネラリ○ナッナッナヲユャユャヲユッヲすャヒミロャナ◆モャソウャソモャマヤャッ○りヲヨンヨヲねヲヨキン➡️ヲヨラニッリ▤リヲネラリ○ムッムッムマャロャソヲあヒャユヲヒャ◆⁶ャロッ◝ロ_カヲヨキンヲカヲヨラヨっくヲンラニ¥サムミヒ⌂ヲユャロャヲユソスャユロユスマヲロッ◜ャむᶠャマ◝ッロ◝ッ◆カっニラヲニヲヌヲヨンヨンヲねヲヨラニッリ☉リンク●ュ●タロタッヒャヒャユロユサッロソ◜ャむV◝ゅャロッ◝ヒ◝ッ◆ニヲンヨンヨヘヨヲヨヲヌヲヨキヨヲンりンヲカッリのヘッリヘッリヒュャロムミ🅾️ヲユャロャヲユッヲロヲタユロユサッサモャソモoャロ◝ッモエタ○ヨヘヨるヨヲヨンヲラヲヨラカラヨヲりヲヨラニッリンスロヲリッリヲリッリロュミへユッナッナッヲユタヲユッヒヲらヒヲロヲッスタソ◜ょソ◜ょロ◝ッ◜ャッロ◝ロャマ○ヨヲヨラりヌヘヨヲヌねラヲりヲンラニッラヲヒリロヲマリソリへチロュッムッムソャロャソヲロユへャロャロッユヒち◜ャち◜ャソロ◝ッ◜ャッロ◝ロOヲンラりスランヲラっカラヲカンヨヲラヲヨッラヲクロスリンクロュロュャヒャロヲ▮ヘッそてヲち◜ャソロ◝ッ◜ャソロ◝ッ◜つ◝◜ャ◆ヲラカヘヨンヨヲニンヌヨンヘニンニヲヨヲラヲヨラッリへヘッリヘッリロャロャロュャロュヲヒ◝ヲ◝ヘトヲ◝ヒ◜ラロッユラロラヒヲぬロモャソウャロ◝ッウャロ◝ッモャサッ◝モ◆ヲラニヲヨンキヨヲヨヲニヌヨンヲカヲラヲヨラヲラヨッリランリッヘリッリヲリッリロャサュャロャヲロOロ◜ヒッユへヲをッロャ◜ャソタ◜ャロ◝ッタ◜ャッをャゅ◝ミ◆りヲヌりヲヨンヲカラヨヲカヲヨヲラヲヨラヲッリラヲリッヘリッリソリサムミヒヲロンoンロ◜ソユロょヲロヲ◜ロッャッ◜ャち◜ャロ◝ソ/マ◆カヲヨラねンヲラヲりラヨヲニラヲヨラヲヨヲヨッリラヲリッヘリッリヲク●ュヲロラoラロ◜ユッロユロャナロヲロ◜ャロッュッ◜ャち◜ャロ◝ソ●ッ◜ャロッ◜◝ッ◆カヲラくヲンランヲりラヲニヲヨラヲラヲヨラッリラヲリッヘリッリサリヒュャロムミヲロOロ◜ロッロソユラロヲをッュモャソウャロ◝ッモ◆モャヒ◜ッロ◆カヲ➡️ヲヨヌヲねヲニヲヨラヲラヲヨラッリラヲリッヘマリヲクロュミへヲヒoヒ◜ロッロヲャロユヒャむュタソ◜ょロ◝ッ◜ょソ◜ょマ◜ッ○Qヲンラヨヲ▒ンるンヌッリラヲリッっリサリへチ⁶◜ロッユロユロユラロうち◜ャソロ◝ッ◜ャち◜ャむヤャ◆リヘンスリスンスン⁸ラリッヲリマxリ◜リッモッ◜⬅️Xャスャ◆ち◜ャ⌂す◜ユ▒◆⁸ャホょン☉リッヲマヲッラ☉ッ◜ッ◜リッ◜リヤャエャヘラヒラヒラロミサャᶠかテユサモ▒◆「リょホミ☉ラッスリッxッテリッ◜ッよャヤkちᶠかャユ◜ユサナ▒◆ンヘラヲッスラスラヘ⬅️☉ロヘマリッラ☉モネマモ⬅️ヲユッヲッヲッナャオャロミ◜ュめトャ◝ッ◝ャソタ◝ャロ◜ユへ▒◆ンヲラリッリラヲラッラヲラッヲラ⬅️☉ランヲクッxおリ⬅️ュユロユロユロユロャユヒッロミ◜ュめ◝ャ◝ャ◝タトャマ◝ャロ◜ユへ▒◆リンちリッリゅリ⬅️☉リッヲンッリッラ☉◜リッ◜ネマ⬅️ュユめユちロャモュタモ◝ッ◝ッ◝ャ◝ャソエテユサモ▒◆ッネッヘリむクッ⬅️ヲユセユヘラッヲマリッxリマゆ⬅️ヲユッユッユッャッロャロャヒャチタ◜ュトッエタソ◝ャオサ◜ユ▒◆⌂クむ⬅️▒ロラへxウク◜⬅️ナッユッユッナ;◜ュよタトミヤャす◜ユ▒◆ッスッヘッスリック⬅️ヨン⁸ンねンロエラネラエンロヲャッャロラロラロッヲッヲッロい◜ュヤタにットャᶠ◆ッリ*⬅️ン⁸ヘンりンロヤヌエヌヤンロヘッヲへッロッロッロャモュタモ◝む◝ャ◝ソ◝ャ◝◜ᶠ◆リヲッヘリッリヘッヘリッリ⬅️ニ	くンロ◝ラヤゅヤラ◝ンロミゅヘャッヲッヲッロャュ◜ュタムヤッ◝ッヤッ◝め◝ャᶠ◆ッリッネゅリッネソ⬅️¹▒ンロッ◝ロッエッロ◝ッンロヲユッヲュャヘャッャッャッロミ◜ュめ◝ャ◝ャ◝ャ◝ャ◝ャマ◝ッ◝ャᶠ◆リッスッヘリッヘリッネ⬅️ニン⁸スンヨンロエラネラエンサッヒャユロャユヒッょ◜ュめ○ャよャᶠ◆リッリむリッリむ⬅️ヨン⁸まホロヤヌエヌヤンロヘッヲュャユロャオッユロャモュタᵉモᶠ◆ッヘッヘリむクッ⬅️カ	セニンロ◝ラヤゅヤラ◝ンサッヒャロミロユロッヲロャチタ◜ュつ◜い◜ャᶠ◆クむクむ⬅️¹▒ンロッ◝ロッエッロ◝ッンロヲユッタロめッ{◜ュち◜ャち◜ャᶠ◆くテ¹1テ¹1テQモ¹テAヲりヲa◜ョハ◜AテA◜ョハ◜Aテ▒◜カ◜ョハ◜ニ◜く◜メ◜ラモQ◜ョハ◜Qヘニヘq◜メ◜レョ◜a◜ョハ◜a◜メ◜レョ◜a◜ョハ◜く◜ョ◜ヨ◜メ◜レョモョ◜ね◜ョ◜ョレメ◜q◜メ◜レョ◜➡️ヘヨそヨヘくレョム◜ュ◜q◜メ◜レョ◜qレョヘ◜ヲ◜q◜メ◜レョ◜ね◜メ◜レョヘ◜ヲ◜メ◜ね◜レ◜ョレメレqレョナ◜ユ◜➡️Hくラョャッユッ◜➡️モレョヘ◜ヲ◜qラョヲ◝ユ◝◜qレョヘ◜ヲ◜く◜ョレラョヲ◝ユ◝レョ◜く◜レ◜ョレメレモねモラョヌユラテくh➡️モら◜く◜ョレラョヲ◝ユ◝モ▒モら◜➡️モラョヲ◝ユ◝◜➡️◜レョ◜ナ◜ユョ◜▒◜ライ◜ョ◜り◜ョレョ◜ナ◜ユ◜レョ◜ニ⁸カ◜ハラモラレ◜ね◜ョ◜ョ◜ら◜ョ◜く◜ハラテ➡️◜ョレモら◜▒◜ハラモラ◜q◜レウレョ◜カ◜メ◜ハラモラモメ◜ニ(カ◜ョモコモョ◜り◜メ◜レラモラレョ◜ね◜ハモハョ◜く◜メ◜レラゆ▒◜わ◜Q◜し◜カテヨ◜わ◜ニテカHり◜メ◜コ◜メ◜ねテョコテ➡️◜ツ◜レモ➡️テョ◜レツ◜▒◜わモa◜ラコ◜レ◜➡️◜わモ➡️Hねテツテね◜ツ◜ツ◜a◜ョ◜ョ◜ョ➡️◜ツレョゆ▒◜イハ◜▒◜レ◜ツモラ➡️◜イハ◜ね(ね◜ハ◜ハ◜く◜ョ◜ョレ◜ョハ◜a◜ハ◜▒◜ョ◜ョレ◜ョハ◜q◜ハモメ◜▒◜ハ◜メレラ➡️◜ハテメ◜り⁸カ◜メ◜ヨ◜メ◜ねモヨモヨモョ◜q◜メ◜qモヨモヨモョ◜q◜レ◜ニ◜メ◜➡️◜メモハ◜➡️◜レョ◜ニ◜メ◜くhね◜ツ◜ヨ◜ツ◜a◜ツ◜q◜メ◜!◜ツ◜▒◜メ◜ヨウ▒◜ョ◜ヨ◜ョ◜▒◜ョ◜ニウねH¹¹¹¹➡️◜ョ◜1モヨ◜メ◜➡️◜メ◜Qヘヨヘニヘヨヘ¹¹¹¹➡️◜ョ◜¹◜メ◜➡️テ■ヲりヲ¹¹¹¹aテ¹ヨテ¹¹aテ¹1テ¹1テqモ¹ニ◜メ◜¹Q◜ョハ◜AテA◜ョハ◜Aテ▒◜カ◜ョハ◜➡️◜メウ!◜ョレ◜¹a◜メ◜レョ◜a◜ョハ◜a◜メ◜レョ◜a◜ョハ◜く◜ョ◜ヨ◜メ◜レョ◜く◜ョモハラ◜A◜コ◜¹aレョヘ◜ヲ◜q◜メ◜レョ◜qレョヘ◜ヲ◜q◜メ◜レョ◜ね◜メ◜レョヘ◜ヲ◜く◜レ◜イレ◜Q◜ツ◜¹q◜ラョヲ◝ユ◝◜➡️モレョヘ◜ヲ◜qラョヲ◝ユ◝◜qレョヘ◜ヲ◜く◜ョレラョヲ◝ユ◝ゆニ◜レ◜レョヘラ◜A◜メ◜¹▒◜ハ◜らゆニ◜ョレラョヲ◝ユ◝ゆねモらゆねラョヲ◝ユ◝ゆカ◜レョ◜ナ◜ユョレ◜メ◜ニモレョヲ◝ユゆ▒◜ョレ◜¹➡️◜ョレ◜レラモラハ◜メ◜ヨ◜ョ◜ョ◜ら◜レ◜メ◜カ◜ハラモラハ◜メ◜りモら◜レ◜メ◜カ◜ハラモラゆカ◜レ◜ョオハ◜メ◜く◜コ◜Aテ▒◜ツ◜コなニ◜メ◜レラモラゆカ◜ハモハョゆね◜レラ🅾️ね◜わ◜q◜ふゆ➡️◜ツ◜▒ラモョコョモラね◜ョモハ◜qテョコ◜q◜ツ◜レ◜▒テョ◜レツ◜▒◜わモ▒◜ラコ◜1◜メ◜¹q◜イ◜▒◜ツ◜ツ◜a◜ョ◜ョ◜ョ➡️◜ツレョゆ▒◜イハ◜く◜レ◜ツ◜1◜ョレ◜Aテq◜ハ◜ョハ◜➡️◜ョ◜ョレ◜ョハ◜a◜ハ◜▒◜ョ◜ョレ◜ョハ◜q◜ハモメ◜く◜ハ◜メレラQ◜コ◜▒ラテコテラり◜メ◜ヨ◜メ◜➡️モヨモヨモョ◜q◜メ◜qモヨモヨモョ◜q◜レ◜ニ◜メ◜ね◜メモハ◜Q◜ツ◜▒◜メレツレメ◜カ◜ツ◜ヨ◜ツ◜A◜ツ◜q◜メ◜!◜ツ◜▒◜メ◜ヨウく◜ョ◜ヨ◜ョ◜A◜メ◜q◜ョレツレョ◜¹¹¹¹q◜ョ◜Qモヨ◜メ◜A◜ョレ◜a◜レョレョレ◜¹¹¹¹a◜ョ◜!◜メ◜Q◜コ◜q◜ツレツ◜¹¹¹¹qテ■テQ◜ツ◜aおね"
map_mem="m²◝ョヤイアュュュュ◜ミムムムム◝リラヨユ◝よヒハノ◝◝もももも◜ゆゆゆゆゆゆゆ◝◝▤▤▤▤◜ほへˇ●●ˇ✽∧◝ほへyyyyi_^_^]]]]]ZZZZZZZZZZZZZZZZON◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◜メ◝モイアュュュュ◜ミムムミム◝ネシシナ◝にサコケ◝◝もももも◜ややゆゆゆゆゆ◝◝▤▤▤▤ふせす◝くけくけ◝◝せすyyyyiONONMMMMM\\\\\\ZZ\\\\\\\\\\\\ZZZZ\\ON◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝トテテタタ◜◜◜◜◜ムソソムミ◝クシシオヌニサコケ◝◝◜◜◜◜◜ゆゆゆゆゆゆいいいふ◜◜ふ◜❎☉くメメメメけ◝⬆️⬆️iiiiiONONMMMMM◝◝LKKJ◝◝◝◝LKKKKJyy◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝トテテタタ◜◜◜◜◜ムミムムム◝れるりらキカサケ◝◝◝◜◜◜◜◜ゆゆゆゆやや⬅️⬅️⬅️ふ◜◜ふ◜ふ♥しししししし◝⬆️⬆️iiiiiONONMMMMMKKKJ◝◝◝◝LKJ◝◝◝LKii◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝トウウタタタタ◜ツチ◝◝◝◝◝◝◝わろ◝んを◝◝◝◝◝うううう😐◝◝◝◝◝◝⬅️⬅️⬅️★◜◜◜◜★➡️◜⧗け◝◝◝◝⬆️⬆️ぬぬぬぬ◜きききき{zMMM}◝◝◝○~}◝◝◝○~}◝○~ii◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝ャャャタタタタ◜チツンヲヲヲヲワ◝わろ◝んをレロレルレうううう😐おえかかなと⬅️◝◝◜◜◜◜◜🐱▒⧗◝ねけ◝◝◝⬆️⬆️ぬぬぬぬ◜…き…きkjMMMm○~}onm○~}onm◝onii◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝ミミミ◜◜◜◜◜ッ◝ホヘょゅヘフレレレレレレレロレルレ😐😐😐😐😐🅾️♪◆◆◝◝も◝◝◜◜◜◜◜◝◝⬇️◜◝ねけ◝◝ほへ◜◜◜◜◜き…きき[j███◝onm||◝onm◝||◝◝|_^◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝ミミミ◜◜◜◜◜マ◝ホヘセスヘフ◝◝◝◝◝◝レロレルレ😐😐😐😐😐めてつ◝▥あゆ◝◝◜◜◜◜◜◝◝◝⬇️◝◝ね◝◝せす◜◜◜◜◜ききき…IHY◝◝llll||◝l|l◝|llllON◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝qaq◝◝◝◝◝◝ホヘゃっヘフレレレレレレレロレルレたちたそ◝むみま⌂웃웃◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝X◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝qaqWuUUUホヘょゅヘフ◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝r◝◝◝aGFEEEWffufVタタく◝○~れるゆうqs◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝c◝◝◝◝WeEEEGeGuGGャQししonQわゆ😐ad◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝bss◝◝GF◝◝◝WfWffV◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝dtttdvTShgGuGefu◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝ttttdRDC◝◝WFfFfV◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝dddddxwxhgGuuGuF◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝ddddddddEEヤE◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝◝"
def_str="ᶠ¹き\000¹\000ユ¹\000\000ユ²\000\000a________²¹\000Q\000² き\n²\000\000³⁴\000A⁵\000\000A⁸⁶¹P³\000■q____³²□ユ\n⁵T\000\000⁵\000ね▮\0003き⁘²■き◀⁵\000@▮⁶Rオ◀\000\000ぬ◀³▮ナ‖¹\000p‖\000\000P•\000\000A \000\000q•⁴\000@゜⁴\000p ⁸\000p!⁸\000P\"⁸\000\000•⁸▮…#⁷■\000%⁷¹オ ⁷\000P!⁷\000\000\"⁷\000\000 ⁵■➡️$⁵▮`&\000⁷オ&²\000ね)\000\000@0\000\000…1\000\000…4\000\000\0005\000\000`)\000■ナ7\000▶オ7²\000p.²\000p/²\000`.³▮`)⁴\000A0⁴\00000⁶\00002⁴#\0000¹R\000>\000\000ね9⁴\000A9\000\000@B\000\000ぬB\000◀…B⁷▮`D⁷\000¹G⁴リオG\000リオO³\000…>²■ユ>⁷\000pW\000▶オ9²\000PD⁷¹\000⁵ᶠ ナ\000\r\000@\000▮pナ⁶\r■\000____\n\n\000ね⁵\r\000Q⁵ᵉ\000Q⁸\r▮き⁵	⁙ニ⁷	\000ぬ⁸▮0ナ¹ᶜ\000P\000\n\000ぬ¹⁸\0000³	\0000________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________l\000\000pl¹\000ユ"
loc_tbl=split"1,1145,1957,3003,4361,5589,7185"


at_list=split",,0x5.54,,,,,,,0x296,,,,,,,,,,,,,,,,,,,,,,,,,,0x203.22,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,0x1b.64,,,,,,,,,,,,0x239.44,,,,,,,,,,,,,,,,,,,,0x21b,,,,0x29.22,,,,,,0x229.22,,,,,,,,,,,,,,,,,,,,,,,,,0x39,,,,,,,,,,,,,,,,,,,,,0x680"
__gfx__
c0c09000cf00200045a04523cf50e0ce4090d23b9040a1e0ce02f08630d30500091a0129f803699601002998010e0c03c35ccf80200031cf21a02875e0003090
6201906c3190a44990d310c0860030d2094336cf3120004100a0527290020390121290321b905211b09201691900a91900295d07631330d6f31c0f8a500c293a
0229ad01895a00a93801c916012c08f02c012a360629160139cd01791900d91900d914006a1201d61360d807235dcf62e0b021cfc2a00a63bff130ddf52c0c29
1400293700c914008a570b29ac02891600c917006c0a00d36c3074f42c0e0e2c00291a012c28004c2a0000a95a01d75000100013e04003e0900301603fcf1301
603fcf2301603f0001219d016030c0a102cf43200043cf73e0ce4090d417f08630d306000e2c00191700495a01693801c91902e91b008c06e0ad1c02004a7407
490405690401692900b90a01992401c91407c9000153548047cf44a004c9bf7390ccc1cf44a0d711900605901704902a01903b00905304908308b03403393d01
993d014348cf54200042cf15a00ac3bf4430ddf45c01c91305a91503890701390501291b03490d01894d01d34d3052059357cfe5a0989590d01990dc30b0a805
697701895501a93301390801d35d3082f46c0809b6000a77048c04008c0a00ac08020b28e0c004906e0d306505a31600a07047c0a800c08a20c04800b08002e9
1600a31630650500191700491a016938038c0600c91902e91be0ad1c02004a7407490405690401692900b90a01c9160599440153548047cf57200013e0e04000
cf00a2c02b532a97a2ac41a28e655300b99392730900732b11632d11834d00530279a26483a248a5b24f3d261031a7100120dc34b2872afbdcd28e00c28226dc
8cd286d2c3d2c7d2cbd2cf00a2ca2bd2c353b930536a51532c9f639910636a11632c1100a2c625a2ac41532c75732b11632d11834dbf605302bfcf50a28e6593
9253001973090000a2648ba24611a24e11536a11630211832100532ac8a2c02ba2ac41a28e625302b79392730900732b11632d11834d00537370a28109a28d01
e299255e59e29d05110931270230370600202a98200a8e209a1905068de293246e49f20f34e3d023ac0023ed0033ee30a459cfa0200041cff0200049cf81330e
3de3def2003432073b62163ca2173b04604371fb2c37e3dd23a66123ca41236a31a2b25260b4310434438133320833444ccf63a2c6282363d060bc3162143504
324361fd4c252a15294a3836b516258a3a24cadc32320530a50930a60731d56437b61531c614301405005304bba2aa46700d352939461001000130310034cfa4
a2b03f230fb0a290211300911302bc230050e0314000cf0024003a0afc424324c39100148003300afc42432400a3a043a38467a36c87b38431b38a11b36c7154
c50054ab0054ec0000a344a5e36e34aa56380b16334b14376b1433ab1633eb1648150a40450c40650840a50a0040044d304e46e36a08304e46e36a08304e46e3
6a08304af6386b19344d36338d3631cb1645d50c40750e40532400a344a5a36a85b36031b34471b34631b36a3154aa0054860054c40054a100b36e8100c3606b
a36821b36421b36a41a36043a3d01b440e207466414324cfa0200021cf41200029cfd1440020c302bbbf90f36cfc1c4d041e306d7c312fb30438046a048d04ab
0488049684b8cf22b3eed1cf13c302bbcfd1a37491548400b33441cf1344e001a3c211d3c419f30243e250a36e8f5431505440300452043b046704750479049a
049304a6043804ac00a344a5b36e81b36031b34471b34631b36a3154aa0054860054c40054a10000545301549901549e0100a3a84154a401549d010054a30154
8801547d0100a360cbf36c48e40d32eb1d3b4c7b314a7d40f40c40f404f03c070250f24c070230f24c3a2cb437cf90444020a38219a3c42954ae00442f00cfb4
c3e0cfcfe5c302bdbfa4f3c2f65c3e2adc02300a9c32aa5a04d75000100013644043651431ab1a0140651431ab1a01300b1a314b1a416514f16c430410f14b3f
bb1ef26c331cd2390c06331adc301b0c314b1c31cb1c41550e40c50e00c0015000cfa02000210031e40b51c32131a700317800317c0060d50a232c0011601442
191125168248219a13b16441c011453c0210c146219a13041c3143123173023193225125c13189165108315168313042071001821165143239219913b16441c0
1103a811634512634310634011d32012f144314d32510a9331cd2f51ca23002193114162218812b34a14a51a04d7500010004131a01431401a61a413a6347170
29816019673a1d451a0083dacfc131e00d31c60731bf21319f00315d03316f1131590031550060d005e3d53002fb2c1167390d83d9cf72200021001123167126
219b13c16441c311335d10853c02236c0011601442191125168248219a13b16441c011e40c51c4230031a01251826131c61431a802518a6141ce0010032a1125
1816634c11832a10a51816e40c0011141a8249218a15c15631c41a3187173144175143a1518e1151ce213042071002391141166191218914042c315201317600
31a500314709316a06317b05318c0431bb0531af01514da1310f31cf237186833088f63c18f3fe0010f31e14838c10a51c12d33a11934910b35810237410a515
14930512451417b35010c34110f31214e30300067d308e0a8374cfa3200025cf24610ff14c131320f11b0d0240f34c13c32011f61031c12d51c42151ca217121
9d812114a842001160145162114b164219219a13824841c011453c02100182116314041c31a008318414318b0231ab145168830011601451622194118248219a
13b16441c011453c12e40c0031a01251826131c61431a802518a6141ce0010032a11251816634c11832a10a51816e40c001140166162116c12921941c011232a
10934810d51711538d10451816d51c021002391141166191218914231510530a10630710739410a36610b35710c34810b35b10e32a10042c514da1cf45119a00
0002500100d02000cf2091d0919100c1309319493914891b12a95a13ea1e10a953247429940b100907201527051a192c10590af00b06436dcf3091c700917601
91ba01915803a16871a16a00526b918e0091be2300915013917285915611918801915a3191c65591e0934275425730cd19e91014ea150d00021022f06b0091d0
51a100c091d514c1c40191c6030291146c5615891a11a93814c916f10b275073cf60c1283db15e6fa15e31914e0e91ce0f22dc23a12d10530091810c308003d3
34b19e21a10e81de5623c16611d16211f173e192f30b180c90fc0b17e95c00e00d1011691c002374d14451d16651d18831c14a8fde4c1591ca0191ce2bf175f1
9900de4613de6811d18013d1a213f193f1b591aa45700d25b42ad40a000130210834cfd091003fa14fa18240100a0c1219dc2219d2f90c000220f21c1009381c
491c12696d01d35da1eed1919a03305d03b339428342c5915606a10ed1cf1120002100915407a190b191c43130c315ea141d895b16691ee3ad1b20942bd4fb1c
24c73b629c204669625424a60530db1b09ad13091418290911ea1d1dea101c2b9b11cb11176b57115b40142c10083339305c13ca10f01c050270f21c2c02eda1
00c1b1526b30421339a41029a81029bc00d338a14e81d17401d1a415e194135f2b5043c10233c10a3500b1506f91400c91c00f308003d33491810ca10e81de56
23c16611d16211e192133f275073c120150091c00391a64142a791ca01b15a63914a03304b174914100916f12c100a1616491c12891a14c91b20542c940ad337
917e05326e0510891a10a937009327326a13e91c22f40c10291a14695a20342ac7b0912017cf92b1ad0010304100cf00a43523cf20940f0102100340e910e400
1fe4c02f35219de4a011cf701000312504f20b53642ccf70250af20c5b633b5da21c4566f10c0d02100200238ce4c34c700d45ae5a51810d15bc02400eba410e
54510356534200cf2130dc450ebd41ee1747ce3641ae52433f08f4a550c121155cf21c030210f21c04021008404ebc425eaae1ed1b01338c15b652c12b00f4d2
406f0df4c940bf0af47a40df06cf9130d24d6e8c426e14473e08403ec8418e34012348a46813a4a914308843ae50f11c0a0210f81c4d2edc02437ce4c89130cc
427a60fb1b09c3acbfd1e40553bf91e4c881cfd1e46551e488163087538103c46a552a51d60254d706f02c410efce24d1c00336c3082433f28f442416f16a40a
b3e4aa11153804c3d030ecf42c452edc02435c3082433ec8416e94412f15bf92b408f22c05c38c25c8f22c492e5c426e1a01336cf482416f16f4aa53815b1538
44ac4cac52d505754a11cfd2e4c22dbf91250ef72c0d43ccf482416f16f44241be2401a334e48a11308c438a1a51621a30c85c8145559d50a532cf9230acf83c
419a404b6a2a51a532652923654b80e4c02f30cc56c71a51970450d704f03c445eaa444e0ce2ed1b01338c15b652c12b00f4d2406f0df4c940bf0af47a40df06
cf8394b047d97ab482476b7ae46047e468113067434e3d00334d30cd57903ce42a75157252c143e40817cf93200071cfc3f43340df05e4d81105545060070579
50b005f4a9402c5c561955480e504719518542752611652920754811cf04e4d41230d3414c4a2c522588bfc330d7fd4c50963856b71851c71e51880e50251085
0411651450751400756411cf44e4d41230b7434c4a2c522588bf0430c7fd4c54964856b71851880e50c71e512510650460756411750411cf84e4d014e4d71630
dd415f18e45331f4a841cf16c4ac5522f34b04336dcf845539547603549548752612857711cfc4e4d014e4d71530dd05331de45331f46c415f18c4acf4a85125
32bf8430d3f64c5c95436527505589546722517817f15c402e4a402e46402c542548552248ae3440ae3850964254860756b70250871750770850880650b80340
0efdf15c436e06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0cccccccccccccccccccccccccccccccccccccccccccccccdfffkdffffffkff0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000cccccccccccccccccccccccccccccccccccccccccccccccfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc0f7f0cccccccccccccccccccccccccccccccccccccccccccccccfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccccccckkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckffkfffkdffkfff0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdfffkdffffffkff0cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckffkfffkdffkfff0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccckkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccccccccccccccccccc
ffffffffffffffffffffffffffffffffffffffff0kkkkkk0ffffffffffffffffffffffffffffffff0kkkkkk0ffffffffccccccccccccccccffffffffffffffff
b5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bd777777db5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bd777777db5bbbb5bccccccccccccccccb5bbbb5bb5bbbb5b
0000000000000000000000000000000000000000kbbbbbbk00000000000000000000000000000000kbbbbbbk00000000cccccccccccccccc0000000000000000
0fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00kkkkkk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00kkkkkk00fbbbbk0cccccccccccccccc0fbbbbk00fbbbbk0
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk0kkkkkk0kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk0kkkkkk0kkkkkkkkcccccccccccccccckkkkkkkkkkkkkkkk
ffffffffffffffffffffffffffffffffffffffffd777777dffffffffffffffffffffffffffffffffd777777dffffffffccccccccccccccccffffffffffffffff
b5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bkbbbbbbkb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bkbbbbbbkb5bbbb5bccccccccccccccccb5bbbb5bb5bbbb5b
00000000000000000000000000000000000000000kkkkkk0000000000000000000000000000000000kkkkkk000000000cccccccccccccccc0000000000000000
dddddddddddddddddddddddddddddddddddddddd0kkkkkk0ddddddddddddddddcccccccccccccccc0kkkkkk0cccccccccccccccccccccccccccccccccccccccc
ddddddddddddddddddddddddddddddddddddddddd777777dddddddddddddddddccccccccccccccccd777777dcccccccccccccccccccccccccccccccccccccccc
ddddddddddddddddddddddddddddddddddddddddkbbbbbbkddddddddddddddddcccccccccccccccckbbbbbbkcccccccccccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666cccccccccccccccc0kkkkkk0cccccccccccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666cccccccccccccccc0kkkkkk0cccccccccccccccccccccccccccccccccccccccc
6666666666666666666666666666666666666666d777777d6666666666666666ccccccccccccccccd777777dcccccccccccccccccccccccccccccccccccccccc
6666666666666666666666666666666666666666kbbbbbbk6666666666666666cccccccccccccccckbbbbbbkcccccccccccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666cccccccccccccccc0kkkkkk0cccccccccccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666ccccccccccccccccdfffkdffffffkff0cccccccccccccccccccccccccccccccc
0d000d000d000d000d000d00666666666dddddd6d777777d666666666dddddd6ccccccccccccccccfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c666666666d666676kbbbbbbk666666666d666676ccccccccccccccccfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c666666666d6666760kkkkkk0666666666d666676cccccccccccccccckkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c666666666d6666760kkkkkk0666666666d666676cccccccccccccccckffkfffkdffkfff0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c666666666d666676d777777d666666666d666676cccccccccccccccckfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c666666666d777776kbbbbbbk666666666d777776cccccccccccccccckfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c66666666666666660kkkkkk06666666666666666cccccccccccccccckkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c66666666666666660kkkkkk06666666666666666ccccccccccccccccdfffkdffffffkff0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c6dddddd666666666d777777d5555555566666666ccccccccccccccccfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c6d66667666666666kbbbbbbkd0d0d0d066666666ccccccccccccccccfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c6d666676666666660kkkkkk06060606066666666cccccccccccccccckkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccc
c61cc61cc61cc61cc61cc61c6d666676666666660kkkkkk0d0d0d0d066666666cccccccccccccccckffkfffkdffkfff0cccccccccccccccccccccccccccccccc
7777777777777777777777776d66667666666666d777777d7777777766666666cccccccccccccccckfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccc
6666666666666666666666666d77777666666666kbbbbbbk6666666666666666cccccccccccccccckfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666cccccccccccccccckkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666666666666666dfffkdffffffkff0dfffkdffffffkff0cccccccccccccccccccccccccccccccc
6dddddd666666666666666666666666666666666d777777d6666666666666666fbbbkfbbbbbbkfbkfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccc
6d66667666666666666666666666666666666666kbbbbbbk6666666666666666fbbbkfbbdbbkkfbkfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccc
6d666676666666666666666666666666666666660kkkkkk06666661116666666kkkkkkkkkkkkkkk0kkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccc
6d666676666666666666666666666666666666660kkkkkk0666661scc1666666kffkfffkdffkfff0kffkfffkdffkfff0cccccccccccccccccccccccccccccccc
6d66667666666666666666666666666666666666d777777d66661ss1cs166666kfbkfbbkfbbkfbd0kfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccc
6d77777666666666666666666666666666666666kbbbbbbk6666cs7717166666kfbkfbbkfbbkfbb0kfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk06666ds70f0166666kkdkkdkkkdkkkkk0kkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk0666611ffff166666dfffkdffffffkff0dfffkdffffffkff0cccccccccccccccccccccccccccccccc
666666666666666666666666666666666dddddd6d777777d6661ccd11dc16666fbbbkfbbbbbbkfbkfbbbkfbbbbbbkfbkcccccccccccccccccccccccccccccccc
666666666666666666666666666666666d666676kbbbbbbk661s11ccc11s1666fbbbkfbbdbbkkfbkfbbbkfbbdbbkkfbkcccccccccccccccccccccccccccccccc
666666666666666666666666666666666d6666760kkkkkk0661ss1ccc1ss1666kkkkkkkkkkkkkkk0kkkkkkkkkkkkkkk0cccccccccccccccccccccccccccccccc
666666666666666666666666666666666d6666760kkkkkk0666111sss1116666kffkfffkdffkfff0kffkfffkdffkfff0cccccccccccccccccccccccccccccccc
666666666666666666666666666666666d666676d777777d66661cc1cc166666kfbkfbbkfbbkfbd0kfbkfbbkfbbkfbd0cccccccccccccccccccccccccccccccc
666666666666666666666666666666666d777776kbbbbbbk6661ss161ss16666kfbkfbbkfbbkfbb0kfbkfbbkfbbkfbb0cccccccccccccccccccccccccccccccc
66666666666666666666666666666666666666660kkkkkk0661sss161sss1666kkdkkdkkkdkkkkk0kkdkkdkkkdkkkkk0cccccccccccccccccccccccccccccccc
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5b
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk00fbbbbk0
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5b
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkff
bkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfb
bkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfb
00fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk000
ffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfff
bbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbb
bbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbb
kkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkk
fffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkfffffffkff
kbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffffkbbbbkfbbkffffff
kbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbbkbbbbkfbbkfbbbbb
ffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbfffffk00000fbbbbf
bbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkfbbbbkfffffffkkkf
bbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbf
bbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbfbbbbkfbbbbbbkbbf
00000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk00000000kkkkkkkk000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000200000000000000101010000000048c00000000000000001010100000000414101010100000000010101000000004041010100000000000000000000000000010101000000000101010101000001000101010100000001010001010000010101010000c0c00101000100000000010101010000c0c0010101010000000001
00000000010100010101010000000000000000000101000101010100000000000101100000000110010100000001c0000101100000000000010100000000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
