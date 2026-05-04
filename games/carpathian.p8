pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--the carpathian
--by jeff givens
--title & end music by gruber
--boss music by j.s.bach

function _init()
 --black=solid
 palt(0,false)
 --green=transp
 palt(11,true)
  s=1
  tb=5
  t=0
  blinkt=1
 menuscreen()
 wavetime=300
 cleartime=120
 waketime=2700
 lockout=0
 lockt=0
 unhold=false
 sink=57
 ang=0
 spd=0 
end

function _update60()
 blinkt+=1
 lockt+=1
 
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="over" then
  update_over()
 elseif mode=="enter" then
  update_enter()
 elseif mode=="leveltext" then
  update_leveltext()
 elseif mode=="clear" then
  update_levelclr()
 elseif mode=="win" then
  update_win()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="over" then
  draw_over()
 elseif mode=="enter" then
  draw_enter()
 elseif mode=="leveltext" then
  draw_leveltext()
 elseif mode=="clear" then
  draw_levelclr()
 elseif mode=="win" then
  draw_win()
 end
end

function  startenter()
 mode="enter"
 sfx(24)
 music(12,0,1)
 s=1
 t=0
 tb=5
 pt=6 
 tim=0
 p=makespr()
 p.x=-24
 p.y=96
 p.spr=1
 p.w=2
 p.h=2
 p.flip=false
  
 --univ color changes
 pal(1,140,1)
 pal(2,132,1)
 pal(4,137,1)
 pal(13,13,1)
 pal(3,11,1)

end

function startgame()
 mode="game"

 s=1
 t=0
 tb=5
 pt=6
 stage=1
 level=1
 wave=1
 lvlclr=1
 camposx=0
 camposy=0
 score=0
 lives=10
 maxlives=10
 invul=0
 tim=0
 bultimer=0
 
 p=makespr()
 p.x=54
 p.y=96
 p.spr=1
 p.w=2
 p.h=2
 p.flip=false
 p.dx=0
 p.dy=0
 p.max_dx=2
 p.max_dy=3
 p.acc=0.2
 p.boost=4.75
 p.anim=0
 p.walk=false
 p.slide=false
 p.jump=false
 p.fall=false
 p.landed=false
 p.crouch=false


 grav=0.3
 friction=0.85
 buls={}
 ebuls={}
 bulsr={}
 
 --univ color changes
 pal(1,140,1)
 pal(2,132,1)
 pal(4,137,1)
 pal(13,13,1)
 pal(3,11,1)
 pal(5,5,1)


 enemies={}
 spawnwave()
 parts={}
 pickups={}
end

function menuscreen()
 music(16)
 cls(0)
 mode="start"
 moon=0
 castl=-33
 sink=57
 level=1
 camera()
 camposx=0
 camposy=0
 
 --reset level colors
 pal(6,6,1)
 pal(10,10,1)
 pal(14,14,1)
 --reset default colors
 pal(1,1,1)
 pal(2,2,1)
 pal(4,4,1)
 pal(13,13,1)
 
end

function endscreen()
 music(19)
 cls(0)
 mode="win"
 moon=0
 castl=-33
 level=1
 camera()
 camposx=0
 camposy=0
end
-->8
--tools

function cprint(_t,_x,_y,_c,_c2)
 --centered print
 oprint(_t,_x-#_t*2,_y,_c,_c2)
end

function oprint(_t,_x,_y,_c,_c2)
 local _xo,_yo={-1,1,0,0,-1,-1,1,1},
               {0,0,-1,1,-1,1,-1,1}

 for i=1,8 do
  print(_t,_x+_xo[i],_y+_yo[i],_c2)
 end

 print(_t,_x,_y,_c)
end

--font thingy
fdat = [[  0000.0000! 739c.e038" 5280.0000# 02be.afa8$ 23e8.e2f8% 0674.45cc& 6414.c934' 2100.0000( 3318.c618) 618c.6330* 012a.ea90+ 0109.f210, 0000.0230- 0000.e000. 0000.0030/ 3198.cc600 fef7.bdfc1 f18c.637c2 f8ff.8c7c3 f8de.31fc4 defe.318c5 fe3e.31fc6 fe3f.bdfc7 f8cc.c6308 feff.bdfc9 fefe.31fc: 0300.0600; 0300.0660< 0199.8618= 001c.0700> 030c.3330? f0c6.e030@ 746f.783ca 76f7.fdecb f6fd.bdf8c 76f1.8db8d f6f7.bdf8e 7e3d.8c3cf 7e3d.8c60g 7e31.bdbch deff.bdeci f318.c678j f98c.6370k def9.bdecl c631.8c7cm dfff.bdecn f6f7.bdeco 76f7.bdb8p f6f7.ec60q 76f7.bf3cr f6f7.cdecs 7e1c.31f8t fb18.c630u def7.bdb8v def7.b710w def7.ffecx dec9.bdecy defe.31f8z f8cc.cc7c[ 7318.c638\ 630c.618c] 718c.6338^ 2280.0000_ 0000.007c``4100.0000`a001f.bdf4`bc63d.bdfc`c001f.8c3c`d18df.bdbc`e001d.be3c`f3b19.f630`g7ef6.f1fa`hc63d.bdec`i6018.c618`j318c.6372`kc6f5.cd6c`l6318.c618`m0015.fdec`n003d.bdec`o001f.bdf8`pf6f7.ec62`q7ef6.f18e`r001d.bc60`s001f.c3f8`t633c.c618`u0037.bdbc`v0037.b510`w0037.bfa8`x0036.edec`ydef6.f1ba`z003e.667c{ 0188.c218| 0108.4210} 0184.3118~ 02a8.0000`*013e.e500]]
cmap={}
for i=0,#fdat/11 do
 local p=1+i*11
 cmap[sub(fdat,p,p+1)]=
  tonum("0x"..sub(fdat,p+2,p+10))
end

function pr(str,sx,sy,col)
 local sx0=sx
 local p=1
 while (p <= #str) do
  local c=sub(str,p,p)
  local v 

  if (c=="\n") then
   -- linebreak
   sy+=9 sx=sx0 
  else
      -- single (a)
      v = cmap[c.." "] 
      if not v then 
       -- double (`a)
       v= cmap[sub(str,p,p+1)]
       p+=1
      end

   --adjust height
   local sy1=sy
   if (band(v,0x0.0002)>0)sy1+=2

   -- draw pixels
   for y=sy1,sy1+5 do
       for x=sx,sx+4 do
        if (band(v,0x8000)<0) pset(x,y,col)
        v=rotl(v,1)
       end
      end
      sx+=6
  end
  p+=1
 end
end
 
 function animt4()
  tb=tb-1
  if tb<0 then
   s=s+1
   if s>4 then s=1
   end
   tb=5
  end
 end
 
 --player animation
 function animt3()
  if pt<0 then
   p.spr=p.spr+2
   if p.spr==3 or p.spr==7 then
    sfx(2)
   end
   if p.spr>=9 then
    p.spr=1
   end
   pt=6
  end
 end
 
 --quiet walking on entry
 function animt3quiet()
  if pt<0 then
   p.spr=p.spr+2
   if p.spr>=9 then
    p.spr=1
   end
   pt=6
  end
 end
 
--draw sprites
function drwmyspr(myspr)
 local sprx=myspr.x
 local spry=myspr.y
 if myspr.shake>0 then
  myspr.shake-=1
  if t%4<2 then
   sprx+=1
  end
 end
 if myspr.bulmode then
  sprx-=2
  spry-=2
 end 
 spr(myspr.spr,sprx,spry,
 myspr.w,myspr.h,myspr.flip)
end

--sprite collision
function col(a,b)
 if a.ghost or b.ghost then 
  return false
 end
 
 
 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
  
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1
 
-- if p.crouch==true then
--  b_top+=8
-- end
 
-- if p.crouch==false then
--  b_top-=8
-- end

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end


function blink()
 local banim={15,15,15,15,15,15,15,15,8,8,8,8,8,8,8,8}
 if blinkt>#banim then
  blinkt=1
 end
 return banim[blinkt]
end

function explode(expx,expy,isblue)	
	local mypx={}
	mypx.x=expx
	mypx.y=expy
	mypx.sx=0
	mypx.sy=0
	mypx.age=13
	mypx.size=9
	mypx.maxage=8
 mypx.blue=isblue
 
	add(parts,mypx)
 
 for i=1,40 do
	 local mypx={}
	 mypx.x=expx
	 mypx.y=expy
	 mypx.sx=(rnd()-0.5)*2.5
	 mypx.sy=(rnd()-0.5)*2.5
	 mypx.age=rnd(5)
	 mypx.size=1+rnd(2)
	 mypx.maxage=15+rnd(15)
	 mypx.blue=isblue
	 add(parts,mypx)
 end
 
 for i=1,40 do
	 local mypx={}
	 mypx.x=expx
	 mypx.y=expy
	 mypx.sx=(rnd()-0.5)*1.5
	 mypx.sy=(rnd()-0.5)*1.5
	 mypx.age=rnd(5)
	 mypx.size=1+rnd(2)
	 mypx.maxage=15+rnd(15)
	 mypx.blue=isblue
	 mypx.spark=true
	 add(parts,mypx)
 end
 
end

function bigexplode(expx,expy)	
	local mypx={}
	mypx.x=expx
	mypx.y=expy
	mypx.sx=0
	mypx.sy=0
	mypx.age=13
	mypx.size=30
	mypx.maxage=8
 
	add(parts,mypx)
 
 for i=1,80 do
	 local mypx={}
	 mypx.x=expx
	 mypx.y=expy
	 mypx.sx=(rnd()-0.5)*5
	 mypx.sy=(rnd()-0.5)*5
	 mypx.age=rnd(5)
	 mypx.size=1+rnd(4)
	 mypx.maxage=30+rnd(30)
	 add(parts,mypx)
 end 
end

function pxage_red(page)
 local col=7
 if page>5 then
  col=9
 end
 if page>8 then
  col=15
 end
 if page>11 then
  col=4
 end
 if page>14 then
  col=8
 end
 if page>19 then
  col=5
 end
 return col
end

function pxage_blue(page)
  local col=7
 if page>5 then
  col=13
 end
 if page>10 then
  col=2
 end
 if page>15 then
  col=5
 end
 return col
end

 --skip to next level
function nextlvl()
 unhold=false
 waketime=800
 lockt=0
 lockout=lockt+20
 tim=0
 buls={}
 bulsr={}
 mode="leveltext"
 level+=1
 lvlclr+=1
 if level==9 then
  waketime=1500
  stage+=1
  camposx=0
  camposy=128
  p.x=54
  p.y=224
  maxlives=15
  lives=maxlives
  sfx(30)
  nextwave()
  spawnwave()   
  return
 end	 
 if level!=9 then
  camposx+=128
  p.x=54
  p.y=96
  p.x+=((level-1)%8*128)
  p.y+=((stage-1)*128)
 end
 if level==16 then
  lvlclr+=1
 end
 if level==1 then
  waketime=2700
 end
 if level==17 then
  camera(0,0)
  endscreen()
 end
 nextwave()
 spawnwave()
end


function map_coll(obj,aim,flag)
 --obj=table needs x,y,w,h
 --aim=left,right,up,down
 local x=obj.x local y=obj.y
 local w=obj.w*8 local h=obj.h*8
 local x1=0 local y1=0
 local x2=0 local y2=0
 
 if aim=="left" then
  x1=x     y1=y
  x2=x+1   y2=y+h-1
 elseif aim=="right" then
  x1=x+w-2 y1=y
  x2=x+w-1 y2=y+h-1
 elseif aim=="up" then
  x1=x+2   y1=y-1
  x2=x+w-3 y2=y
 elseif aim=="down" then
  x1=x+2     y1=y+h-1
  x2=x+w-3 y2=y+h
 end
 --pixels to tiles
  x1/=8 y1/=8
  x2/=8 y2/=8
  
  if fget(mget(x1,y1), flag)
   or fget(mget(x1,y2), flag)
   or fget(mget(x2,y1), flag)
   or fget(mget(x2,y2), flag) then
   return true
   else return false
  end
  
end

function makespr()
 local myspr={}
 myspr.x=0
 myspr.y=0
 myspr.flash=0
 myspr.shake=0
 myspr.aniframe=1
 myspr.anispd=0.12
 myspr.spr=0
 myspr.mx=0
 myspr.my=0
 myspr.w=2
 myspr.h=2
 myspr.flip=false
 myspr.colw=16
 myspr.colh=16
 myspr.torch=false
 myspr.wander4=false
 myspr.wander6=false
 return myspr
end




-->8
--updates

function update_game()

 if lockt<lockout then
  return
 end
 
 tim+=1
 t+=1
 lvlcomp=((level-1)%8*128)
 stgcomp=((stage-1)*128)

--[[ if t>30000 then
  t=1001
 end]]
--[[ if tim>30000 then
  tim=1001
 end]]
 if lockt>30000 then
  lockt=1
 end
 
 if #enemies==0 then
  mode="clear"
 end
 
 --player walk
 animt3()

 p_update()
 
 --level testing
-- if btnp(2) then
--  enemies={}
--  mode="win"
-- end
 
 --confine player to screen
 if p.y<0+stgcomp and p.x>104+lvlcomp then
  p.x=104+lvlcomp
 end
  if p.y<0+stgcomp and p.x<8+lvlcomp then
  p.x=8+lvlcomp
 end
 if p.x>124+lvlcomp then p.x=-14+lvlcomp end
 if p.x<-14+lvlcomp then p.x=124+lvlcomp end
 if p.y<-20+stgcomp then
  p.dy=0
 end

 --fire left
 if btn(❎) and
   p.flip==true and btn(3) then
  if bultimer<=0 then
   local newbul=makespr()
   newbul.x=p.x-5
   newbul.y=p.y+10
   newbul.spr=32
   newbul.w=1
   newbul.h=1
   newbul.colh=4
   newbul.flip=true
   add(buls,newbul)
   sfx(3)
   bultimer=12
  end
 elseif btn(❎) and p.flip==true then
  if bultimer<=0 then
   local newbul=makespr()
   newbul.x=p.x-5
   newbul.y=p.y
   newbul.spr=32
   newbul.w=1
   newbul.h=1
   newbul.colh=4
   newbul.flip=true
   add(buls,newbul)
   sfx(3)
   bultimer=12
  end
 end

 --fire right
 if btn(❎) and 
  p.flip==false and btn(3) then
  if bultimer<=0 then
   local newbul=makespr()
   newbul.x=p.x+13
   newbul.y=p.y+10
   newbul.spr=32
   newbul.w=1
   newbul.h=1
   newbul.colh=4
   newbul.flip=false
   add(bulsr,newbul)
   sfx(3)
   bultimer=12
  end
 elseif btn(❎) and p.flip==false then
  if bultimer<=0 then
   local newbul=makespr()
   newbul.x=p.x+13
   newbul.y=p.y
   newbul.spr=32
   newbul.w=1
   newbul.h=1
   newbul.colh=4
   newbul.flip=false
   add(bulsr,newbul)
   sfx(3)
   bultimer=12
  end
 end
 
 bultimer-=1
 
 --move the bullets left
 for mybul in all(buls) do
  mybul.x=mybul.x-2
  if mybul.x<(p.x-136) then
   del(buls,mybul)
  end
 end
 
 --move the bullets right
 for mybul in all(bulsr) do
  mybul.x=mybul.x+2
  if mybul.x>(p.x+136) then
   del(bulsr,mybul)
  end
 end
 
 --move the ebuls
 for myebul in all (ebuls) do
  move(myebul) 
  animate(myebul)
  if myebul.bone==true then
   myebul.my+=0.05
  end
  if myebul.x<(p.x-136) or
   myebul.x>(p.x+136) or
    myebul.y<(p.y-136) or
   myebul.y>(p.y+136) then
   del(ebuls,myebul)
  end
 end
 
  --move the pickups
 for mypick in all(pickups) do
  mypick.heartlife+=1
  if mypick.heartlife>=500 then
   del(pickups,mypick)
  end
  animate(mypick)
 end
  
 
 --moving enemies (bats)
 for myen in all(enemies) do
  --enemy mission
  doenemy(myen)
  --enemy leaving screen
  if myen.x<-40+lvlcomp then
	  myen.x=130+lvlcomp
	 end
	 if myen.x>130+lvlcomp then
	  myen.x=-40+lvlcomp
  -- if rnd()>.6 then sfx(0) end
	 end
	  
	 --enemy animation
	 animate(myen) 

  --kill offscreen enemies
  if myen.y>=138+stgcomp then
   killen(myen) 
  end
  if myen.y<=-20+stgcomp then
   killen(myen) 
  end
  if myen.x<=-60+lvlcomp then
   killen(myen) 
  end
  if myen.x>=150+lvlcomp then
   killen(myen) 
  end
 end
 
  --collision buls x enemies
 for myen in all(enemies) do
  for mybul in all(buls) do
   if col(myen,mybul) then
    del(buls,mybul)
    if myen.mission!="wakeup" then
     myen.hp-=1
    end
    sfx(4)
    if myen.boss then
     myen.flash=10
    else
     myen.flash=4
    end
    if myen.hp<=0 then
    killen(myen) 
		   if #enemies==0 then
		    mode="clear"
		    sfx(24)
		   end
    end
   end
  end
 end

 for myen in all(enemies) do
  for mybul in all(bulsr) do
   if col(myen,mybul) then
    del(bulsr,mybul)
    if myen.mission!="wakeup" then
     myen.hp-=1
    end
    sfx(4)
    if myen.boss then
     myen.flash=16
    else
     myen.flash=4
    end  
    if myen.hp<=0 then
     killen(myen) 
 	   if #enemies==0 then
	     mode="clear"
	     sfx(24)
	    end
    end
   end
  end
 end
 
 --collision p x enemies
 if invul<=0 then
  for myen in all(enemies) do
   if col(myen,p) then
    if myen.torch==false then
     lives-=1
     sfx(25)
     explode(p.x+8,p.y+8,true)
     invul=120
    end
   end
  end
 else
   invul-=1
 end
 
  --collision p x ebuls
 if invul<=0 then
  for myebul in all(ebuls) do
   if col(myebul,p) then
     lives-=1
     sfx(25)
     explode(p.x+8,p.y+8,true)
     invul=60
   end
  end
 end
 
 --collision with pickups
 for mypick in all(pickups) do
  if col(mypick,p) then
   del(pickups,mypick)
   sfx(31)
   if lives>=maxlives then
    lives=maxlives
    else
    lives+=1
   end
  end
 end
 
 --game over
 if lives<=0 then
  invul=-1
  p.spr=36
  sfx(23) 
  music(23)
  lockt=0
  lockout=lockt+60
  mode="over"
  return
 end
 
end

function update_start()
 animt4()
 moon+=0.1
 if btnp(❎) then
  startenter()
 end
 --move moon
 if moon>=143 then
  moon=-20  
 end
 --move castle
 castl+=0.135
 if castl>=158 then
 -- castl=-33 
   castl=-62 

 end
end


function update_over()
 
 if lockt<lockout then
  return
 end
 
 if btn(❎)==false and btn(🅾️)==false then
  btnreleased=true
 end
 if btnreleased then
  if btnp(❎) then
   menuscreen()
   btnreleased=false
  end
 end
 

end

function update_win()
 animt4()
 moon+=0.1
 --move moon
 if moon>=120 then
  moon=-20  
 end
 --move castle
 castl+=0.135
 if castl>=30 then
  sink+=0.07 
 end
 if castl>=158 then
  castl=158 
 end
 
 if lockt<lockout then
  return
 end
 
 if waketime<=-30000 then
  waketime=-1000
 end

 
 if btn(❎)==false and btn(🅾️)==false then
  btnreleased=true
 end
 if btnreleased then
  if btnp(❎) then
   menuscreen()
   btnreleased=false
  end
 end
end

function update_enter()
 tim+=0.5
 animt4()
 animt3quiet()
 p.y=97
 p.x+=0.5
 pt=pt-0.5
 p.dir=2
 if p.x>=128 then
  startgame()
  mode="leveltext"
 end
end


function update_leveltext()
 update_game()
 wavetime-=1
 if wavetime<=0 then
  mode="game"
  wavetime=180 
 end
end

function update_levelclr()
 update_game()
 ebuls={}
 cleartime-=1
 if cleartime<=0 then
  nextlvl()
  cleartime=120  
 end
end


-->8
--draw

function draw_game()
 cls(0)
 camera(camposx,camposy)
 lvlcomp=((level-1)%8*128)
 stgcomp=((stage-1)*128)
 
 --universal color manipulation
 pal(1,140,1)
 pal(2,132,1)
 pal(4,137,1)
 pal(13,13,1)
 pal(3,11,1)
 

 --brown-grey level colors+
 if lvlclr==1 then
  pal(10,5,1)
  pal(6,133,1)
  pal(14,128,1)
 end
 --dark green level colors+
 if lvlclr==3 then
  pal(10,3,1)
  pal(6,131,1)
  pal(14,129,1)
 end
  --dk blue level colors+
 if lvlclr==4 then
  pal(10,140,1)
  pal(6,1,1)
  pal(14,129,1)
 end
   --dark purple level colors+
 if lvlclr==5 then
  pal(10,2,1)
  pal(6,130,1)
  pal(14,128,1)
 end
 --red level colors
 if lvlclr==6 then
  pal(10,8,1)
  pal(6,2,1)
  pal(14,130,1)
 end
 --brown level colors+
 if lvlclr==2 then
  pal(10,4,1)
  pal(6,132,1)
  pal(14,128,1)
 end
 if lvlclr==7 then
  lvlclr=1
 end
 
 --map
 map(0,0,0,0,128,128)
 
 --drawing pickups
 for mypick in all(pickups) do
  drwmyspr(mypick)
 end
 
 -- drawing ebuls
 for myebul in all(ebuls) do
  drwmyspr(myebul)
 end

 
 --drawing enemies
 for myen in all(enemies) do
  if myen.flash>0 then 
   myen.flash-=1
   if myen.boss then
    myen.spr=199
    if t%8<4 then
     pal(0,8)
     pal(13,7)
    end
   else
   pal(12,7)
   pal(1,7)
   pal(9,7)
   pal(0,7)
   pal(4,7)
   pal(8,7)
   end
  end
  drwmyspr(myen)
  pal(12,12)
  pal(1,1)
  pal(9,9)
  pal(0,0)
  pal(4,4)
  pal(8,8)
  pal(13,13)
 end
 
 --player sprite
 if invul<=0 then
  drwmyspr(p)
 else
  --unvul state
  if sin(t/5)<0.5 then
   drwmyspr(p)
  end
 end

 --draw bullet left
  foreach(buls,drwmyspr)
 --draw bullet right
  foreach(bulsr,drwmyspr)

--drawing particles
 for mypx in all(parts) do
 local pc=7
 if mypx.blue then
  pc=pxage_blue(mypx.age)
  mypx.spark=false
 else
  pc=pxage_red(mypx.age)
 end
 
 if mypx.spark then
  pset(mypx.x,mypx.y,8)
 else
  circfill(mypx.x,mypx.y,mypx.size,pc)
 end
  mypx.x+=mypx.sx
  mypx.y+=mypx.sy
  mypx.sx*=0.95
  mypx.sy*=0.95
  mypx.age+=1
  if mypx.age>mypx.maxage then
   mypx.size-=0.5
   if mypx.size<0 then
    del(parts,mypx)
    mypx.age=0
   end
  end
 end
  
 --mummy boss sprite colors
 if level==8 then
 pal(3,6,1)
 pal(13,134,1)
 else
 pal(3,11,1)
 pal(13,13,1)
 end
 
 
 if level==7 or
  level==13 then
  if t%30+rnd(10)<=10+rnd(5) then
   pal(3,0,1)
   else
   pal(3,9,1)
  end
 end  
 
 if level==14 or level==15 then
  if t%180+rnd(60)<=10+rnd(30) then
   pal(1,1,1)
   else
   pal(1,129,1)
  end
  else
  pal(1,140,1)
 end
 
 --lightning level 15
 if level==15 then
  if t%360+rnd(60)<=10+rnd(30) then
   local lightflp=true
   if t%4>2 then
    lightflp=false
   end
   spr(229,800+rnd(64),129+rnd(8),1,1,lightflp)
   sfx(49)
  end
 end
 
 
 --final boss lightning
 if level==16 then
  pal(3,2,1)
  pal(4,136,1)
  pal(5,6,1)
  pal(1,1,1)
  
  if t%120+rnd(60)<=10+rnd(30) then
    pal(1,7,1)
    pal(2,128,1)
    pal(3,0,1)
    pal(5,7,1)
    pal(6,13,1)
    pal(8,14,1)
    pal(4,2,1)    
    pal(10,7,1)
    pal(12,7,1)
    pal(13,6,1) 
    pal(14,0,1)    
    pal(15,7,1)
    
   else
    pal(1,1,1)
    pal(2,132,1)
    pal(3,2,1)
    pal(5,6,1)  
    pal(6,130,1)   
    pal(8,8,1)    
    pal(4,136,1)
    pal(10,2,1)
    pal(12,140,1)
    pal(13,13,1)
    pal(14,128,1)
    pal(15,15,1)
  end
 end

 --ui
 rectfill(0+lvlcomp,
 120+stgcomp,
 128+lvlcomp,
 128+stgcomp,0)
 print("life:",
 1+lvlcomp,
 121+stgcomp,15)
 cprint("score:"..makescore(score),
 96+lvlcomp,
 121+stgcomp,15)
 --lives
 for i=1,maxlives do
  if lives>=i then
   spr(47,21+(i*3-3)+lvlcomp,
   120+stgcomp)
  else
   spr(63,21+(i*3-3)+lvlcomp,
   120+stgcomp)
  end
 end
 
-- print(p.x,5+lvlcomp,5+stgcomp,7)
-- print(wave,5+lvlcomp,5+stgcomp,7)
-- print(waketime,5+lvlcomp,5+stgcomp,7)
end

function makescore(val)
 if val==0 then
  return "0"
 end
 return val.."00"
end


function draw_over()
 draw_game()
  rectfill(38+lvlcomp,55+stgcomp,92+lvlcomp,62+stgcomp,0)
  pr("game over",39+lvlcomp,56+stgcomp,blink())
  cprint("press ❎ to reset",64+lvlcomp,66+stgcomp,15,0)
end

function draw_start()
 cls(0)
 pal(1,129,1)
 pal(3,130,1)
 pal(4,2,1)
 pal(14,136,1)
 pal(5,1,1)
 pal(13,133,1)
 pal(12,0,1)

 
 --sky
 rectfill(0,14,128,39,1)
 rectfill(0,40,128,72,3)
 rectfill(0,58,128,72,4)
 for i=1,20 do
  print("▤",(i*7)-7,16,0)
  print("▤",(i*7)-7,34,3)
  print("▤",(i*7)-7,52,4)
 end

 --moon
 circfill(64,-10+moon,20,9)
 circfill(64,-11+moon,19,10)
 circfill(64,-12+moon,17,7)


 --ground
-- circfill(castl-111,99,30,0)
-- circfill(castl-151,99,30,0)
-- circfill(castl-50,96,30,0)
-- circfill(castl+40,99,30,0)
-- circfill(castl+80,99,30,0)
-- circfill(castl-10,99,30,0)
-- circfill(castl+141,96,30,0)

 --castle
-- spr(224,castl,sink,4,2) 
 cstl="⁶-b⁶x8⁶y8 ᶜc⁶.@@@`ナナナユ⁶.\0\0\0\0\0\0\0¹             \n⁶.\0\0\0\0\0\0██⁶-#ᶜa⁶.@@\0\0\0@\0²⁸⁶-#ᶜc⁶.まぬユナヒせフハ⁶-#ᶜa⁶.\0\0\0\0\0\0 \0⁸⁶-#ᶜc⁶.³!!0pヲpz⁶-#⁶.\0\0\0\0\0\0\0▮            \n⁶-#ᶜa⁶.\0\0\0\0⁸\0\0\0⁸⁶-#ᶜc⁶.█ちゆうひュュ◜²a⁶.◝◝◝◝ヤ◝◜◝⁶-#ᶜa⁶.\0\0\0\n\0\0\0\0⁸⁶-#ᶜc⁶.○??5?○◝◝⁶-#ᶜa⁶.\0\0\0▮\0\0\0\0⁸⁶-#ᶜc⁶.▮「8,▤えトト⁶-#⁶.\0\0\0\0\0\0\0¹           \n⁶-#ᶜa⁶.\0▮\0\0\0\0\0\0⁸⁶-#ᶜc⁶.◜ヤ◝◝◝◝\0\0⁶-#⁶.◝◝◝◝◝◝\0\0⁶-#ᶜa⁶.¹\0@\0\0\0\0\0⁸⁶-#ᶜc⁶.◜◝よ◝◝◝\0\0⁶-#ᶜa⁶.⁴\0\0\0\0\0\0\0⁸⁶-#ᶜc⁶.タ◝○○○○\0\0⁶-#            \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                "
 ?cstl,castl,sink-14
 
 --mountains
 rectfill(0,73,128,128,0)
 mtn="⁶-b⁶x8⁶y8⁶-#ᶜ1⁶.\0\0¹³ᵉお|0⁸⁶-#ᶜ5⁶.\0³ᵉ<ユa²⁴⁸⁶-#ᶜd⁶.\0\0\0\0\0\0¹³⁶-#ᶜ1⁶. オ⁸🅾️い1█h⁸⁶-#ᶜ5⁶.\0\0きp ░⁷♥⁸⁶-#ᶜd⁶.\0 p\0⁴²\0\0⁶-#ᶜ1⁶.\0\0れ%「p<0⁸⁶-#ᶜ5⁶.\0\0\0bき█²っ⁸⁶-#ᶜd⁶.\0\0\0█@\0¹⁷⁶-#ᶜ1⁶.⁴¹\0\0@ユ8▮⁸⁶-#ᶜ5⁶.「6iサ\r¹⁴\0⁸⁶-#ᶜd⁶.\0⁸◀)²\0²ᶠ⁶-#ᶜ1⁶.\0 pきc\0\0\0⁸⁶-#ᶜ5⁶.\0らきp\0▮すゅ⁸⁶-#ᶜd⁶.\0\0\0⁸<モx5⁶-#ᶜ1⁶.²¹\0	⁶⁶¹¹⁸⁶-#ᶜ5⁶.ᶜ\n⁵⁶\0¹⁸⁴⁸⁶-#ᶜd⁶.\0⁴\n\0\0\0\0⁸⁶-#          \n⁶-#ᶜ1⁶.(☉っチ░j\"▮⁸⁶-#ᶜ5⁶.⁴⁵²²¹▒ら`⁸⁶-#ᶜd⁶.³²⁵¹²\0\0█⁶-#ᶜ1⁶.⁴□ᵇ¹¹²⁴😐⁸⁶-#ᶜ5⁶.b █▮2$h`⁸⁶-#ᶜd⁶.█らpヘアセ⧗⁙⁶-#ᶜ1⁶.\0\0\0█`「$□⁸⁶-#ᶜ5⁶.`█$i■⁷²¹⁸⁶-#ᶜd⁶.か○タ6ᵉ\0▒ら⁶-#ᶜ1⁶.⁴²³\0@█@█⁸⁶-#ᶜ5⁶.²!`x★qのd⁸⁶-#ᶜd⁶.▒ら…░,ᵉ\r•⁶-#ᶜ1⁶.█ら \0⁸⁴⁙웃⁸⁶-#ᶜ5⁶.v,」★d!█ ⁸⁶-#ᶜd⁶.	⁙⁶\r⬇️る`p⁶-#ᶜ1⁶.\0\0\0\0⁴⁸⁸⁸⁸⁶-#ᶜ5⁶.²\0²⁶⁸\0⁴²⁸⁶-#ᶜd⁶.ᶜᵉᶜ	³⁷³⁵⁶-#          \n⁶-#ᶜ1⁶.	\0⁘ᶜf⬇️▒²⁸⁶-#ᶜ5⁶.08⁸…☉\\.e⁸⁶-#ᶜd⁶.ららナ`0 p▤⁶-#ᶜ1⁶.😐っp8xn⁘%⁸⁶-#ᶜ5⁶.b⁵ᶠ⁶⁷¹³²⁸⁶-#ᶜd⁶.12\0¹\0\0\0\0⁶-#ᶜ1⁶.웃²a█\0⁴ア、⁸⁶-#ᶜ5⁶.\0\0 @☉x \0⁸⁶-#ᶜd⁶.`ユ…8pき▮ナ⁶-#ᶜ1⁶.っyね34\\「+⁸⁶-#ᶜ5⁶.!²ᵉᶜᵇ³⁶⁴⁸⁶-#ᶜd⁶.◀⁴\0\0\0\0¹\0⁶-#ᶜ1⁶.🐱✽\0き\"🐱#³⁸⁶-#ᶜ5⁶.\0@▮²de⁴⁸⁸⁶-#ᶜd⁶.x8l\\「「「4⁶-#ᶜ1⁶.ᵉ⁶\n\0²⁴¹¹⁸⁶-#ᶜ5⁶.¹\0\0\0\0\0\0\0⁶-#          \n⁶-#ᶜ1⁶.!@\0@\0\0\0▮⁸⁶-#ᶜ5⁶.をせ⬇️³a	■く⁸⁶-#ᶜd⁶.「「<<>vnn⁶-#ᶜ1⁶.\n\0²	▮²²⁴⁸⁶-#ᶜ5⁶.¹¹¹\0\0\0\0\0⁶-#ᶜ1⁶.◀ᵉ\n、‖9eカ⁸⁶-#ᶜ5⁶.⁸0ル\"bら█\0⁸⁶-#ᶜd⁶.ナら\0ら█\0\0\0⁶-#ᶜ1⁶.😐▤hᵉ「… @⁸⁶-#ᶜ5⁶.²⁴░▒█⁸■#⁸⁶-#ᶜd⁶.¹³³\0⁷⁷ᵉ、⁶-#ᶜ1⁶.cbcb●ᶜmお⁸⁶-#ᶜ5⁶.ᶜ\rᶜ‖9は2`⁸⁶-#ᶜd⁶.000(@\0\0\0⁶-#ᶜ1⁶.²\0\0\0\0¹\0\0⁸⁶-#ᶜ5⁶.\0\0⁸⁸⁸⁸ᶜ⁸⁶-#          \n⁶-#ᶜ1⁶. ナ█¹◆`\0\0⁸⁶-#ᶜ5⁶.■³cをp\0\0\0⁸⁶-#ᶜd⁶.ᵉ、<8\0\0\0\0⁶-#ᶜ1⁶.」\0003⁶\r \0\0⁸⁶-#ᶜ5⁶.\0\0\0¹\0\0\0\0⁶-#ᶜ1⁶.☉$(iヌ\0\0\0⁶-#⁶.▒³⁷なン`\0\0⁸⁶-#ᶜ5⁶.fチヲp\0\0\0\0⁸⁶-#ᶜd⁶.「 \0\0\0\0\0\0⁶-#ᶜ1⁶.t ¹⁶、h\0\0⁸⁶-#ᶜ5⁶.\0\0\0¹\0\0\0\0⁶-#ᶜ1⁶.	⁸\0⁴\n⁸\0\0          \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                "
 ?mtn,castl-186,69
 ?mtn,castl-142,69
 ?mtn,castl-98,69
 ?mtn,castl-54,69
 ?mtn,castl-10,69
 ?mtn,castl+34,69
 ?mtn,castl+78,69
 ?mtn,castl+122,69
 ?mtn,castl+166,69



 --trees
--[[ spr(244,castl+60,66)
 spr(244,castl-131,66)
 spr(244,castl+80,64)
 spr(244,castl-111,64)
 spr(244,castl+118,66)
 spr(244,castl-73,66)
 spr(244,castl+160,66)
 spr(244,castl-31,66)]]
 

--title
 if mode!="win" then
  titl="⁶-b⁶x8⁶y8ᶜ8⁶.@ナぬ「、、、、⁶.p !#'⁷⁷⁷⁶.u‖7‖u\0⁸う⁶.\0\0\0\0\0\0■;⁶.\0\0\0\0\0\0dモ ⁶.\0██らナナヌフ⁶.\0\0██████⁶.¹¹³³³³³⁙⁶.⁴⁴ᵉᵉ⁴\0\0⁴⁶.\0\0\0\0\0\0▮8⁶.\0\0\"wヤフフフ    \n⁶.、、、、、゛゜、⁶.⁷⁶🐱らナナナユ⁶.おえううううおツ⁶.wssss3•7⁶.テウウウウウウエ⁶.▒a!199み}⁶.フワフフフフフワ⁶.⬇️よ████░ア⁶.;wsssss{⁶.ᵉᵉᵉ🅾️ウウウヤ⁶.<:9999=め⁶.フフフフフフフワ    \n⁶.、、、、、、、「⁶.ヌヒフフフフg³⁶.うううう⁸\0\0\0⁶.ssssqp \0⁶.ウウテモnᵉᵉᵉ⁶.999888▮\0⁶.フフフフヌら█\0⁶.うううう😐░🐱▒⁶.sssssss#⁶.ウウウウ░\0\0\0⁶.9999▮\0\0\0⁶.フフフフフフフヌ    \n⁶.ぬナ@\0\0\0\0\0⁶.¹\0\0\0\0\0\0\0  ⁶.ᵉ⁴⁴\0\0\0\0\0  ⁶.█\0\0\0\0\0\0\0⁶.³¹¹\0\0\0\0\0  ⁶.ナ@@\0\0\0\0\0    \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                \n                "
  ?titl,16,79
--[[ cprint("the",61,81,15,1)
 rectfill(22,88,102,99,1)
 rectfill(21,89,103,98,1)
 pr("carpathian",33,92,2)
 pr("carpathian",33,91,2)
 pr("carpathian",33,90,15)]]
 cprint("press ❎ to start",63,112,15,2)
 end
-- spr(s+177,23,90)
-- spr(s+177,95,90)
 --version
 print("1.6",115,120,1)
 --conceal moon @ top of screen
 rectfill(0,0,128,14,0)

end



function draw_enter()
 cls(0)
 pal(10,5,1)
 pal(6,133,1)
 pal(14,128,1) 
 pal(1,129,1)
 pal(3,130,1)
 pal(4,2,1)
-- pal(5,5,1)
-- pal(13,13,1)
 pal(5,1,1)
 pal(13,133,1)
 pal(12,12,1)

 --sky
 rectfill(0,30+tim/6,128,128,1)
 rectfill(0,56+tim/8,128,73+tim/8,3)
 rectfill(0,74+tim/10,128,100+tim/10,4)
 --sky blends
 for i=1,20 do
  print("▤",(i*7)-7,31+tim/6,0)
  print("▤",(i*7)-7,50+tim/8,3)
  print("▤",(i*7)-7,68+tim/10,4)
 end
 --sun
-- circfill(50,96+tim/8,20,8)
 circfill(50,86+tim/8,20,8)

 --hills
 rectfill(0,83,128,128,0)

-- circfill(70,128,40,0)
-- circfill(30,128,36,0)
 ?mtn,-1,79
 ?mtn,43,79
 ?mtn,87,79
 rectfill(90,50,128,128,0)



 --braziers

 for i=1,70,24 do
  spr(s+177,i+15,100)
  spr(s+177,i+18,100)
 end
 for i=1,90,24 do
  spr(187,i+16,106)
 end
 
 --castle
 for i=17,100,16 do
  spr(176,88,i)
  spr(177,88,i+8)
 end
 for i=25,108,16 do
  spr(150,96,i)
  spr(151,96,i+8)
 end
 for i=17,50,16 do
  spr(176,104,i)
  spr(177,104,i+8)
 end
 
 --player
 drwmyspr(p)
 
 --castle covering player
 for i=17,100,16 do
 spr(166,112,i+8)
 spr(167,112,i+16)
 spr(176,120,i)
 spr(177,120,i+8)
 end 
 spr(132,100,44,2,3)
 
 --ground
 for i=1,120,16 do
 spr(144,i,113,2,1)
 end
 
 --caption
 cprint("transylvania",64,30,15,0)
 cprint("the count's castle",64,46,15,0)
 rectfill(51,60,75,67,0)
 pr("1479",52,61,15)
end


function draw_leveltext()
 draw_game()
 if level==16 then
  rectfill(929,168,989,175,0)
  pr("final boss",930,169,blink())
  cprint("the undead count",960,184,15,0) 
 elseif level==8 then
  rectfill(929,40,989,47,0)
  pr("boss fight",930,41,blink())
  cprint("mummies",960,56,15,0)
 elseif level==1 then
  cprint("chamber "..level,64,20,15,0) 
  cprint("destroy torches",64,36,blink(),0) 
  cprint("and enemies",64,44,blink(),0) 
  cprint("controls:",64,60,15,0)
  cprint("move: ⬅️➡️⬆️⬇️",54,68,15,0) 
  cprint("dagger: ❎ (x)",64,76,15,0) 
  cprint("jump: 🅾️ (z)",64,84,15,0) 

 elseif level==9 then
  cprint("chamber "..level,64,168,15,0) 
  cprint("the count's tower",64,184,15,0) 
  cprint("life increased!",64,192,blink(),0) 

 else
  cprint("chamber "..level,64+lvlcomp,40+stgcomp,15,0) 
 end
end

function draw_levelclr()
 draw_game()
 if level==16 then
  rectfill(921,168,998,175,0)
  pr("castle clear!",922,169,blink())
 else
 cprint("chamber",64+lvlcomp,40+stgcomp,15,0)
 cprint("clear!",64+lvlcomp,56+stgcomp,15,0)
 end
end

function draw_win()
 pal()
 palt(0,false)
 palt(11,true)
 pal(1,129,1)
 pal(3,130,1)
 pal(4,2,1)
 pal(14,136,1)
 cls(0)
 draw_start()
-- rectfill(0,80,128,128,0)
 cprint("evil has been defeated",64,25,15,0)
 cprint("the people are safe",64,40,15,0)
-- cprint("thanks to your heroism.",64,55,15,0)
 cprint("thank you for playing!",64,90,15,0)
 cprint("press ❎ to reset",62,106,15,0)
end
-->8
--waves and enemies

function spawnwave()
 
 if wave==1 then
 placens({
  { 0, 0, 9, 0, 9, 0, 1},
  { 2, 0, 0, 0, 0, 1, 0},
  { 0, 2, 0, 0, 1, 0, 0},
  { 9, 0, 0, 0, 0, 0, 9}
 })
 elseif wave==2 then
 placens({
  { 0, 0,10, 0,10, 0, 1},
  { 2, 3, 0, 0, 0, 3, 0},
  {10, 0, 0, 4, 0, 1,10},
  { 9, 3, 0, 0, 0, 3, 9}
 })
 elseif wave==3 then
 placens({
  { 9, 0, 0, 3, 0, 2, 9},
  {10, 3, 0, 0, 4, 1,10},
  { 3, 9, 0, 2, 0, 9, 3},
  { 9, 3, 0, 0, 0, 0, 9}
 })
 elseif wave==4 then
 placens({
  { 9, 2, 0,14, 0, 1, 9},
  { 9, 0,14, 1,14, 0, 9},
  { 9, 2, 0,14, 0, 1, 9},
  { 0, 9, 0, 0, 0, 9, 0}
 })
 elseif wave==5 then
 placens({
  { 5, 0, 0,10, 0, 1, 9},
  { 9, 2, 0,10, 0, 0, 5},
  { 5, 0, 0,10, 0, 0, 1},
  { 0, 3, 9, 0, 9, 0, 3}
 })
 elseif wave==6 then
 placens({
  { 0, 1, 0, 2, 0, 1, 0},
  {14, 9, 2, 0, 1, 0,14},
  { 0, 1, 7, 9, 6, 0, 0},
  {14, 9, 0, 0, 0, 9,14}
 })
 elseif wave==7 then
  placens({
  { 0, 7, 9, 4, 9, 0, 1},
  { 2, 9, 0, 4, 0, 9, 6},
  { 7, 0, 9, 4, 9, 0, 0},
  { 3, 9, 0, 0, 0, 9, 1}
 })
 elseif wave==8 then
  music(27,0,3)
  placens({
  { 0, 0, 0, 0, 0, 0, 0},
  { 9, 0, 0, 9, 8, 0, 9},
  { 0, 8, 0, 0, 0, 0, 0},
  { 9, 0, 0, 9, 0, 8, 9}
 })
 elseif wave==9 then
  music(29,0,1)
  placens({
  {11, 0,10, 0,10, 0,12},
  { 3, 0, 0,13, 0, 0, 3},
  { 9, 0, 9, 5, 9, 0, 9},
  { 0, 0, 9, 0, 9, 12, 0}
 })
  elseif wave==10 then
  placens({
  { 0, 0, 9,13, 9, 0, 0},
  { 5, 0, 0, 0, 0, 0, 6},
  { 0, 0, 9, 0, 9, 0, 3},
  { 4, 0, 0, 9, 0, 4, 9}
 })
  elseif wave==11 then
  placens({
  { 0, 0,13, 0,13, 0, 0},
  { 7, 0, 0, 5, 0, 0, 6},
  { 3, 0, 0, 0, 0, 0, 3},
  { 0, 0, 0, 9, 0, 0,12}
 })
  elseif wave==12 then
  placens({
  { 9, 0, 0,14, 5,12, 9},
  { 0, 0, 5,14, 0, 0, 0},
  { 0,12, 9, 0, 9, 0, 5},
  { 5, 0, 0, 0, 0, 0,14}
 })
  elseif wave==13 then
  placens({
  { 7, 5, 0, 0, 0,10, 6},
  { 0, 0, 9, 4, 9, 0, 0},
  {10, 7, 0, 0, 0, 6,10},
  { 4, 0,10, 0,10, 4, 9}
 })
  elseif wave==14 then
  placens({
  { 0,11,10,13,10, 0,12},
  {11, 0, 0, 4, 0,12, 0},
  {13, 0, 9, 0, 9, 0,13},
  { 0,12, 0, 9, 0, 0,12}
 })
  elseif wave==15 then
  placens({
  { 7, 0, 0,13, 0,12, 6},
  { 3,11, 0, 0, 0, 0, 3},
  { 0, 9, 0, 5, 0, 9, 0},
  {13, 0, 0, 0, 0, 0,13}
 })
  elseif wave==16 then
  music(24,0,3)
  placens({
  { 0, 0, 0, 0, 0, 0, 0},
  { 0, 0, 0, 0, 0, 0, 15},
  { 0, 0, 0, 0, 0, 0, 0},
  { 9, 0, 0, 9, 0, 0, 9}
 })
 end
end

function placens(lvl)

 for y=1,4 do
  local myline=lvl[y]
  for x=1,7 do
   if myline[x]!=0 then
    spawnen(myline[x],x*16-8,y*32-32)
   end
  end
 end
end

function nextwave()
 wave+=1
 if wave>16 then
  lockt=0
  lockout=lockt+60
 else
 end
end

function spawnen(entype,enx,eny)
 local myen=makespr()
  myen.x=enx+((level-1)%8*128)
  
  if stage==1 then
   myen.y=eny
  end
  if stage==2 then
   myen.y=eny+128
  end
  myen.mission="wakeup"
  myen.type=entype
  

 if entype==nil or entype==1 then
 --blue bat from right
	 myen.spr=192
	 myen.w=1
	 myen.h=1
	 myen.pts=2
	 myen.hp=1
	 myen.ani={192,193,194,193}
	 myen.mx=-.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
 elseif entype==2 then
 --blue bat from left
	 myen.spr=192
	 myen.w=1
	 myen.h=1
	 myen.pts=2
	 myen.hp=1
	 myen.ani={192,193,194,193}
	 myen.mx=.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
  myen.flip=true

	elseif entype==3 then
	--zombie wander4
	 myen.spr=64
	 myen.pts=2
	 myen.hp=3
	 myen.ani={64,64,66,66}
	 myen.mx=-.25
  myen.my=0
  myen.wander4=true
  myen.x+=9
	elseif entype==4 then
	--zombie wander6
	 myen.spr=64
	 myen.pts=2
	 myen.hp=3
	 myen.ani={64,64,66,66}
	 myen.mx=-.25
  myen.my=0
  myen.flip=true
  myen.wander6=true
  myen.x+=17

	elseif entype==5 then
	--jack-o-lantern
	 myen.spr=96
	 myen.pts=6
	 myen.hp=5
	 myen.ani={96}
  myen.my=0
  myen.colw=13
  myen.colh=13
  myen.x+=2
  myen.y+=4
  if myen.shake>0 then
   myen.spr=98
  end
	elseif entype==6 then
	--skeleton right
	 myen.spr=68
	 myen.pts=3
	 myen.hp=4
	 myen.ani={68,68,70,70}
	 myen.mx=-.25
  myen.my=0
  myen.colw=13
  myen.wander4=true
  myen.x+=8
 elseif entype==7 then
	--skeleton left
	 myen.spr=68
	 myen.pts=3
	 myen.hp=4
	 myen.ani={68,68,70,70}
	 myen.mx=.25
  myen.my=0
  myen.colw=13
  myen.x+=8
  myen.wander4=true
  myen.flip=true
	elseif entype==8 then
	--mummy
	 myen.spr=218
	 myen.w=2
	 myen.h=3
	 myen.pts=50
	 myen.hp=15
	 myen.ani={218,218,220,220,222,222,220,220}
  myen.mx=-.25
  myen.colh=24
  myen.wander6=true
  myen.my=0
  myen.y-=8
 elseif entype==9 then
 --high torch
	 myen.spr=178
	 myen.w=1
	 myen.h=1
	 myen.pts=1
	 myen.hp=1
	 myen.ani={178,179,180,181}
	 myen.colw=8
  myen.colh=8
  myen.x+=4
  myen.torch=true
 elseif entype==10 then
 --low torch
	 myen.spr=178
	 myen.w=1
	 myen.h=1
	 myen.pts=1
	 myen.hp=1
	 myen.ani={178,179,180,181}
	 myen.colw=8
  myen.colh=8
  myen.x+=8
  myen.torch=true
  myen.y+=8
 elseif entype==11 then
 --red bat from left
	 myen.spr=208
	 myen.w=1
	 myen.h=1
	 myen.pts=4
	 myen.hp=2
	 myen.ani={208,209,210,209}
	 myen.mx=.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
  myen.flip=true
 elseif entype==12 then
 --red bat from right
	 myen.spr=208
	 myen.w=1
	 myen.h=1
	 myen.pts=4
	 myen.hp=2
	 myen.ani={208,209,210,209}
	 myen.mx=-.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
	elseif entype==13 then
	--witch
	 myen.spr=100
	 myen.pts=10
	 myen.hp=3
	 myen.ani={100,100,102,102}
  myen.mx=0
  myen.my=0
	elseif entype==14 then
	--fish man
	 myen.spr=40
	 myen.pts=4
	 myen.hp=3
	 myen.ani={40,40,42,42}
	 myen.mx=-.25
  myen.my=0
  myen.x+=16
  myen.wander6=true
	elseif entype==15 then
	--the undead count
	 myen.spr=77
	 myen.w=3
	 myen.h=4
	 myen.pts=100
	 myen.hp=70
	 myen.ani={77,77,77,77,77,77,77,77,77,77,77,74,74,74,74,74,74}
	 myen.mx=-.5
  myen.my=0
  myen.colw=24
  myen.colh=32
  myen.boss=true
	end

 add(enemies,myen)
end
-->8
--player

function p_update()
 --physics
 p.dy+=grav
 p.dx*=friction
 
 --controls
 if btn(⬅️) then
  p.dx-=p.acc
  p.walk=true
  p.flip=true
  pt=pt-1
 end
 if btn(➡️) then
  p.dx+=p.acc
  p.walk=true
  p.flip=false
  pt=pt-1
 end
 
 if btn(⬇️) then
  p.spr=9
  pt=pt-7
  p.crouch=true
  else
  p.crouch=false
 end
 
 if btn(⬇️) and btn(➡️) then
  p.dx-=p.acc
 end
 if btn(⬇️) and btn(⬅️) then
  p.dx+=p.acc
 end
 
 if btn(⬇️) and btn(❎) then
  p.spr=13
  if t%14<7 then
   p.spr=9
  end
  pt=pt-7
 elseif btn(❎) and btn(➡️) then
  p.spr=11
  if t%14<7 then
   p.spr=3
  end
  pt=pt-7
   elseif btn(❎) and btn(⬅️) then
  p.spr=11
  if t%14<7 then
   p.spr=3
  end
  pt=pt-7
 elseif btn(❎) then
  p.spr=11
  if t%14<7 then
   p.spr=1
  end
  pt=pt-7
 end
 
 if p.walk
  and not btn(⬅️)
  and not btn(➡️)
  and not p.fall
  and not p.jump then
  p.walk=false
  p.slide=true
 end
 
 --jump
 if btn(🅾️) then
  p.spr=9
  pt=pt-7
 end
 if btnp(🅾️) and p.landed==true then
  p.dy-=p.boost
   sfx(29)
  p.landed=false
 end

 
 --check collision up and down
 if p.dy>0 then
  p.fall=true
  p.landed=false
  p.jump=false 
  if map_coll(p,"down",0) then
   p.landed=true
   p.fall=false
   p.dy=0
   p.y=flr((p.y)/8)*8
  end
 elseif p.dy<0 then
  p.jump=true
  if map_coll(p,"up",1) then
   p.dy=0
  end  
 end
 
 --check collision l and r
 if p.dx<0 then
  local pxstart=p.x
  if map_coll(p,"left",1) or map_coll(p,"left",0) then
   p.dx=0
   p.x=pxstart
  end
 elseif p.dx>0 then
  local pxstart=p.x
  if map_coll(p,"right",1) or map_coll(p,"right",0) then
   p.dx=0
   p.x=pxstart
  end
 end 
 
 --stop sliding
 if p.slide then
  if abs(p.dx)<.2
  or p.walk then
   p.dx=0
   p.slide=false
  end
 end
 
 p.x+=p.dx
 p.y+=p.dy
 
end

-->8
--behavior

function doenemy(myen)
 if waketime<=-1000 then
  unhold=true
 end
 if myen.mission=="wakeup" then
 --level start
  myen.x=myen.x
  myen.y=myen.y

  waketime-=1
  if waketime<=0 then
   myen.mission="wander"
   t=0
  end 
 
 
 elseif myen.mission=="wander" then
  waketime-=1
 --wander and wait
  --bat movement
	 batwave=sin(tim/34)*.7
	 move(myen)
  if myen.bat==true then
   myen.y-=batwave
   if abs(p.y-myen.y)<48 then
    myen.mission="wail"
   end 
  end
  
  if myen.boss then
   myen.mission="boss1"
   myen.phbegin=t
  end
  
  if myen.type==5 then
   --jack-o-lantern
   if abs(p.y-myen.y)<30 and unhold==true then   
    if p.x<myen.x and
	   t%100==0 then
	    myen.shake=10
	    fire(myen,0.25,0.8)
	    myen.spr=98
	   elseif p.x>myen.x and
	   t%100==0 then
	    myen.shake=10
	    fire(myen,0.75,0.8)
	    myen.spr=98
	   end
    if t%100==10 then
     myen.spr=96
    end
   end
  end
  
    -- wander back & forth
  if myen.wander4==true then
   if t%150<75 then
    myen.mx=-.25
    myen.flip=false
    else
    myen.mx=.25  
         
   if myen.type==6 then
    myen.flip=false
    if t%60==0 and unhold==true then
     toss(myen,0.375,0.5+rnd(0.5))
    end
   end
   
   if myen.type==7 then
    myen.flip=true
    if t%60==0 then 
     toss(myen,0.625,0.5+rnd(0.5))
    end
    else
     myen.flip=true
    end
   end
   
  end
  
  if myen.wander6==true then
   if t%270<135 then
    myen.mx=-.25
    myen.flip=false
   else
   myen.mx=.25
   myen.flip=true
   end
  end
  
  if myen.type==8 then
   --mummy
   if t%150==0 then
    myen.shake=10
    aimedfire(myen,1.2)
   end
  end
  
  if myen.type==13 then
   --witch
   if p.x>myen.x then
    myen.flip=true
    else
    myen.flip=false
   end
   if t%150==0 then
	   myen.shake=10
	   firespread(myen,8,0.8,rnd())
	  end
  end
  
  if myen.type==14 then
   --fishman
   if abs(p.y-myen.y)<30 and unhold==true then
    if p.x<myen.x and
    t%271<135 and
	   t%90==0 then
	    myen.shake=10
	    fire(myen,0.25,0.8)
	   elseif p.x>myen.x and
	   t%271>135 and
	   t%90==0 then
	    myen.shake=10
	    fire(myen,0.75,0.8)
	   end
	  end
	 end 
 
 elseif myen.mission=="boss1" then
  if t%200>100 then flywave=-0.1
   else
   flywave=0.1
	 end
	 myen.y-=flywave
	 move(myen)
	 if t%100==0 and myen.x>880 and myen.x<1024 then
	  myen.shake=10
	  aimedfire(myen,1.2)
	 end
	 
	 if myen.phbegin+600<t and myen.x==948 then
	  myen.mission="boss2"
	  myen.phbegin=t
	 end
 
 
 elseif myen.mission=="boss2" then
  if t%200>100 then flywave=-0.2
   else
   flywave=0.2
  end
  myen.y-=flywave
  if t%50==0then
   myen.shake=10
	  firespread(myen,12,0.8,rnd())
  end 
	 if myen.phbegin+600<t then
	  myen.mission="boss3"
	  myen.phbegin=t
	 end
 
 
 elseif myen.mission=="boss3" then  
  if t%60==0 then
   spawnbat(1,-8,32+rnd(32))
   spawnbat(2,130,32+rnd(32))
	 end
	 if myen.phbegin+240<t then
	  myen.mission="boss1"
	  myen.phbegin=t
	 end
	 
	 
 elseif myen.mission=="boss4" then
  music(-1)
  myen.shake=10
  myen.flash=10
  if t%16==0 then
   explode(myen.x+rnd(24),myen.y+rnd(32))
   sfx(25)
  end
  
  if myen.phbegin+120<t then
   if t%7==0 then
    explode(myen.x+rnd(24),myen.y+rnd(32))
    sfx(25)
   end
  end
  
  if myen.phbegin+240<t then
   bigexplode(myen.x+12,myen.y+16)
   enemies={}
   sfx(50)
	 end

 
 elseif myen.mission=="wail" then
 --attack
  if myen.bat==true then
   -- bats
	  move(myen)
		 if p.y<myen.y then
		  myen.y-=.2
		  else if p.y>=myen.y then
		   myen.y+=.2
		  end
		 end
	  myen.y-=batwave
  
  end
 end
end

function killen(myen)
 if myen.boss then
  myen.mission="boss4"
  myen.phbegin=t
  myen.ghost=true
  ebuls={}
  return
 end

 del(enemies,myen)
 score+=myen.pts
 sfx(26)
 explode(myen.x+5,myen.y+6)
 if level<9 then
  if flr(rnd(10))==0 then
   dropickup(myen.x,myen.y)
   sfx(28)
  end
  elseif level==16 then
  if flr(rnd(10))==0 then
   dropickup(myen.x,myen.y)
   sfx(28)
  end
  else
  if flr(rnd(10))<=2 then
   dropickup(myen.x,myen.y)
   sfx(28)
  end
 end
end

function dropickup(pix,piy)
 local mypick=makespr()
 mypick.x=pix
 mypick.y=piy
 mypick.spr=206
 mypick.ani={206,207}
 mypick.w=1
 mypick.h=1
 mypick.colw=7
 mypick.colh=7
 mypick.heartlife=0
 add(pickups,mypick)
end

function animate(myen)
 myen.aniframe+=myen.anispd
 if flr(myen.aniframe)>#myen.ani then
  myen.aniframe=1
 end
 if myen.type==5 then
  myen.spr=myen.spr
  else
  myen.spr=myen.ani[flr(myen.aniframe)]
 end
end

function move(obj)
 obj.x=obj.x+obj.mx
 obj.y=obj.y+obj.my
end
-->8
--bullets

function fire(myen,ang,spd)
 local myebul=makespr()
 myebul.spr=202
 myebul.x=myen.x+8
 myebul.y=myen.y+3
 
 if myen.type==5 then
  myebul.x=myen.x+8
  myebul.y=myen.y+6
 end
 
 myebul.mx=sin(ang)*spd
 myebul.my=cos(ang)*spd

 myebul.w=1
 myebul.h=1
 myebul.ani={202,203,204,}
 myebul.anispd=0.12
 myebul.colw=2
 myebul.colh=2
 myebul.bulmode=true
 add(ebuls,myebul)
 sfx(27)
 return myebul
end 

function firespread(myen,num,spd,base)
 if base==nil then
  base=0
 end
 for i=1,num do
  fire(myen,1/num*i+base,spd)
 end
end

function aimedfire(myen,spd)
 local myebul=fire(myen,0,spd)

 local ang=atan2((p.y+8)-myebul.y,(p.x+8)-myebul.x)
 
 myebul.mx=sin(ang)*spd
 myebul.my=cos(ang)*spd
end


function toss(myen,ang,spd)
 local myebul=makespr()
 myebul.spr=195
 myebul.x=myen.x
 myebul.y=myen.y
 
 myebul.mx=sin(ang)*spd
 myebul.my=cos(ang)*spd
 
 myebul.bone=true
 myebul.w=1
 myebul.h=1
 myebul.ani={195,212,211,196}
 myebul.anispd=0.12
 myebul.colw=2
 myebul.colh=2
 myebul.bulmode=true
 add(ebuls,myebul)
end

-->8
-- boss

function spawnbat(entype,enx,eny)
 local myen=makespr()
 myen.x=enx+((level-1)%8*128)  
 if stage==2 then
  myen.y=eny+128
 end
 myen.mission="wander"
 myen.type=entype
  
 if entype==nil or entype==1 then
 --blue bat from right
	 myen.spr=192
	 myen.w=1
	 myen.h=1
	 myen.pts=2
	 myen.hp=1
	 myen.ani={192,193,194,193}
	 myen.mx=-.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
 elseif entype==2 then
 --blue bat from left
	 myen.spr=192
	 myen.w=1
	 myen.h=1
	 myen.pts=2
	 myen.hp=1
	 myen.ani={192,193,194,193}
	 myen.mx=.5
	 myen.bat=true
	 myen.colw=8
  myen.colh=8
  myen.y-=6
  myen.flip=true  
 end
  add(enemies,myen)

end
__gfx__
00000000bbbbbbbb2222bbbbbbbbbbbbb2222bbbbbbbbbbbbb2222bbbbbbbbbbb2222bbbbbbbbbbbbbbbbbbbbbbbbbbb2222bbbbbbbbbbbbbbbbbbbbbbb8bbbb
00000000bbbbbbb222ff2bbbbbbbbbbb222ff2bbbbbbbbbbb222ff2bbbbbbbbb222ff2bbbbbbbbbbbbbbbbbbbbbbbb22222f2bbbbbbbbbbbbbbbbbbbb4bb8b4b
00700700bbbbbb2228f82bbbbbbbbbb2228f82bbbbbbbbbb2228f82bbbbbbbb2228f82bbbbbbbbbbbbbbbbbbbbbbbbb222f82bbbbbbbbbbbbbbbbbbbbb8898bb
00077000bbbbb22228ff2bbbbbbbb222288ff2bbbbbbbb222288ff2bbbbbb222288ff2bbbbbbbbbb2222bbbbbbbbb22222ff2bbbbbbbbbbb2222bbbbb89778b8
00077000bbbb288f228f2bbbbbbb28ff2888f2bbbbbbb28822888f2bbbbb28ff2888f2bbbbbbbbb222ff2bbbbbbb2888882f2bbbbbbbbb22222f2bbb8b87798b
00700700bbb22288f222bbbbbbb28888f2822bbbbbbb2288822822bbbbb28888f2822bbbbbbbbb2228f82bbbbbb288882222b22bbbbbbbb222f82bbbbb8988bb
00000000bb2f2222888222bbbbb2222888282bbbbbb288222882f2bbbbb2222888282bbbbbbbb22228ff2bbbbb22222228ff2ff2bbbbb22222ff2bbbb4b8bb4b
00000000bb2f22822f28ff2bbbb228222282bbbbbbb288f222282bbbbbb228222282bbbbbbbb2888228f2bbbbb22222288ff88f2bbbb2888882f2bbbbbbb8bbb
00000000bb222222f28fff2bbbb288ff28ff2bbbbbb22ff28ff22bbbbbb288ff28ff2bbbbbb2888882222bbbbb2222222228882bbbb288882222b22bb8bb4bbb
00000000bbb28282222222bbbbb222f28fff2bbbbbbb2228fff2bbbbbbb222f28fff2bbbbbb2288ff28ff2bbbbb282822bb222bbbbb2222228ff2ff2bb8bbbb8
00000000bb2222822bbbbbbbbbbb22222222bbbbbbb228222222bbbbbbbb22222222bbbbbbbb2222222ff2bbbb2222822bbbbbbbbbbb222288ff88f2bb97898b
00000000bb22222222bbbbbbbbbb222ff2f2bbbbbbb222222fff2bbbbbbb22222ff2bbbbbbbbb2ffff222bbbbb22222222bbbbbbbbbbb2ff2228882b4b8997bb
00000000bbb2ff22ff2bbbbbbbbbb22ff2ff2bbbbbb22ff2b2fff2bbbbbbb28f22ff2bbbbbbb22fffff2bbbbbbb2ff22ff2bbbbbbbbb22fffff222bbbb7998b4
00000000bb2882bb2882bbbbbbbb282882f2bbbbbb28822bbb2882bbbbbb2888fff2bbbbbbb2888f2882bbbbbb2882bb2882bbbbbbb2888f2882bbbbb89879bb
00000000b2882bbb2882bbbbbbbb8288222bbbbbb2882bbbbb2882bbbbb28882222bbbbbbbb288822882bbbbb2882bbb2882bbbbbbb288822882bbbb8bbbb8bb
00000000b28882bb28882bbbbbbbb28882bbbbbbbb288f2bbb28882bbbbb288822bbbbbbbbb2822b28882bbbb28882bb28882bbbbbb2822b28882bbbbbb4bb8b
bbb9bbbbbbb7cbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbb0000000000000000bbb00488000bbbbbbbbbbbbbbbbbbbbbbb7777bbbb7777bbbb7777bbbbbbbbbb
74497777bbb44bbbbbbbbbbbbbb7cbbbbbbbbbbbbbbbbbbb0000000000000000bb048008840000bbbb000488000bbbbbb777777bb887777bb777777b88bbbbbb
c449cccbbbb44bbbbbbb9bbbbbb7cbbbbbbbbbbbbbbbbbbb0000000000000000b04804088888880bb0448008840000bb77777777870877777887777748bbbbbb
bbb9bbbbbb9999bb77779447bbb7cbbbbbbbbbbbbbbbbbbb0000000000000000b04400888804800bb04404088888880b78877777800877778708777788bbbbbb
bbbbbbbbbbb7cbbbbccc944cbb9999bbbbbbbbbbbbbbbbbb0000000000000000b00048880004088bbb0400888804800b8708777ff887777f8008777f48bbbbbb
bbbbbbbbbbb7cbbbbbbb9bbbbbb44bbbbbbbbbbbbbbbbbbb0000000000000000b00004808840000bbb0048880004088b8008777ff777777ff887777f48bbbbbb
bbbbbbbbbbb7cbbbbbbbbbbbbbb44bbbbbbbbbbbbbbbbbbb0000000000000000b44444088400088bb00048808840000bb88777fbbf7777fbbf7777fbbbbbbbbb
bbbbbbbbbbb7bbbbbbbbbbbbbbb7cbbbbbbbbbbbbbbbbbbb0000000000000000b08800844000000b000400088400088bbbffffbbbbffffbbbbffffbbbbbbbbbb
bbbbbbbbb4bbbbbbbbbbbbbbbbcccbbbbbbbbbbbb22bbbbb0000000000000000bb0888400448088b444408844044000bbb7777bbbb7887bbbb7777bbbbbbbbbb
bbbb44bcb44bbbbbbbbbbbb4bbb77cbbbbbbbb222882bbbb0000000000000000bb0444080888008bb08884400888088bb777777bb787087bb777777b22bbbbbb
bbb4477cbb44bbbbbbcbbb44b447b7cbbbbbb288228822bb0000000000000000bb000088808880bbbb0440088088800b77788777778008777777777722bbbbbb
bb44bb7cbbb44bbbbc7bb44bbb44bbbbbbbb2222ff28222b0000000000000000bbbb0888004440bbbbbb08888808844077870877777887777777777722bbbbbb
b44bb7cbbbbb44bbc7bb44bbbbb44bbb222b22882f2822220000000000000000bbb040880404040bbbbbb0880480440bf780087ff777777ff778877f22bbbbbb
44bbbcbbbc7b744bc7744bbbbbbb44bb8882f288822288220000000000000000bb0488008804040bbbbbbb0048804040f778877ff777777ff78f087f22bbbbbb
4bbbbbbbbbc77bbbcb44bbbbbbbbb44b888ff228ff22ff22000000000000000000048000008800bbbbbb004488880b0bbf7777fbbf7777fbbf8008fbbbbbbbbb
bbbbbbbbbbbcccbbbbbbbbbbbbbbbb4b828ff222ff2ff2f2000000000000000008888808448880bbbbb0800000bbbbbbbbffffbbbbffffbbbbf88fbbbbbbbbbb
bbddbbbbbbd0d0bbbbbbbbbbbbbbbbbbbb077770bbbbbbbbbbbbbbbbbbbbbbbb69e669e000000000bbbbbbbbb0000bbbbbbb5d5bbbbbbbbbb0000bbbbbbbbbbb
bd00dbbbbd0d00bbbdddbbbbbdd0d0bbb07007770bbbbbbbbb077770bbbbbbbb0400040000000000bbbbbbbb000000bbbbbbb5d5bbbbbbbb000000bbbbbbbbbb
b0777770bbb0d0bbb000dbbbb00d00bbb070079990bbbbbbb07007770bbbbbbbf999994000000000bbbbbbbb5d55050bbbbdb5d5bbbbbbbb5d55050bbbbbbbbb
0dd007770bd0d0bbb0777770bbb0d0bb0707799990bbbbbbb070079990bbbbbb9eeeee9000000000bbbbbbbb8588dd0bbbbbddddbbbbbbbb8588dd0bbbbbbbbb
00d0007770ddd0bb0dd007770d00d0bb0999009990bbbbbb0707799990bbbbbb9e6e6e9e00000000bbbbbbbbd5dd5d0bbbbb0dd0bbbbbbbbd5dd5d0bbbbbbbbb
0d0dd07070bb00bb00d0007770ddd0bb0000090990bbbbbb0999009990bbbbbb9e6e6e9000000000bbbb883b707dd088bbb00000bbbb883bddddd088bbbbbbbb
0ddd0007070dd0bb0d0dd07070bb00bbb07770900bbbbbbb0000090990bbbbbb9e6e6e9e00000000bbbbb083000d080344000000bbbbb083707d080344bbbbbb
b000d007000d0bbb0ddd0070070dd0bbbb00009770bbbbbbb07770900bbbbbbb9e6e6e9e00000000bbbb3408d5d0804800000000bbbb3408d5d08048884bbbbb
b0dd000007dd0bbbb0000007000d0bbbbbbb0700770bbbbbbb00009070bbbbbb9e6e6e9e00000000bbb348308008043000000000bbb34830800804300484bbbb
b000000d70d070bbbb00d00007dd0bbbb00b70709090bbbbbbbb0709070bbbbb9e6e6e9000000000bbb488034004350000000000bbb48803400435000384bbbb
bb0700d7700070bbb0dd000d70d070bb0770070700070bbbbbbb70700090bbbb9f6f6f9000000000bb3488050005000000000000bb3488050005000000483bbb
bb077777700070bbb00000d7700070bb0979900070770bbbbbbb0707790bbbbb9f6f6f9000000000bb4888000700000000000000bb4888000700000000384bbb
b0d777777707700bbb077777700070bbb000000700790bbbbbbbb00790bbbbbb9fffff9e00000000bb44883078d0000000000000bb44883075d0000000084bbb
0d777d77d7777d0bb0d77777770770bbbb0700709000bbbbbbbbb090070bbbbb9efffe9e00000000bb44884078d0000000000000bb44884075d00000000843bb
077700d70d70770bb0d77d77d777070bbbb07070090bbbbbbbbbb0090070bbbb9e6e6e9e00000000bb4448800d00000000000400bb4448800d000000000884bb
007000070077007bb07070d7700770bbbbbb07099990bbbbbbbb0999970bbbbb9e6e6e9000000000bb48488000000000000044b0bb48488000000000000844bb
bbbbbbb44bbbbbbbbbbbbbb44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9e6e6e9e0ee66e00bb484883000000000008844bbb484883000000000008844b
bbbbbb4bbbbbbbbbbbbbbb4bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9e6e6e900ee66e00bb384884000000000008443bbb384884000000000008443b
bbb4440444bbbbbbbbb4440444bbbbbbbbbbbbbbbbbbb00bbbbbbbbb000000bb9e6e6e900ee66000bb484488000000000038844bbb484488000000000038844b
bb400000004bbbbbbb499000994bbbbbbbbbbbbb00000730bbbbbbb07777770b9e6e6e900ee60e00bb388488000000000048443bbb388488000000000048443b
b40990009904bbbbb40000000004bbbbbbbb0bb07777730bbbbb0007733303309e6e6e9e0e60ee00bb488448300000000084844bbb488448300000000084844b
4000990990004bbb4009090909004bbbbbb03007733300bb7bb033333330000b09eee9000ee66e00b33884384000000000484433b33884384000000000484433
4000000000004bbb4099999999904bbbb7bb03333330bbbb3bbb0000000330bb009e900e0ee66e00b34888348000000000848443b34888348000000000848443
4009090909004bbb4099999999904bbbb3bbb000000300bbb3bbb0370300030b0009000e00e66e00b33484384300000000484433b33484384300000000484433
4090999990904bbb4099999999904bbbb3bbb0370300330bbb3b07770030b0bbee000eeeeee000eeb33348348400000000448443b33348348400000000448443
4000000000004bbb4090999990904bbbbb3b0777003000bbbb0000700303bbbb000e00000000e000b34384834400000000484433b34384834400000000484433
4400400040044bbb4490400040944bbbbb00007003030bbbb077000330770bbb00ee00000000ee00b34348433430000000444343b34348433430000000444343
b44444444444bbbbb44444444444bbbbb07700033077700bb0777333303770bb0e0eee0000eee0e0334334433440000000343433334334433440000000343433
bb4444b4444bbbbbbb4444b4444bbbbbb077733330037770bb0003300303770be0000e0ee0e0000e334338430340000000044343334338430340000000044343
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0003300330370bbbbb0303333000300e0eee0000eee0e03343344400400000000434b33343344400400000000434b3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb030333330030bbbbb0333333333000ee00000000ee0034443004000000000004b3bb34443004000000000004b3bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb03333333330bbbbb03333333330000e00000000e0003bb4b000000000000004bbbb3bb4b000000000000004bbbb
ee0eeeee0e0eee0eeee0e00ee00eee0e000e0ee60ee000e00e000e0e000e000e0e0eee0e0e0eee0ee0e0e000000ee00eee066ee000ee600000e0000e00e00e0e
0000e0000000e00000000ee000e0000e66eee66ee66ee6600000e0000000e000e00000e00000e00000e0006eee0000e00000000000ee600066e066e66e0e0e66
0000e00000000000000ee000000ee00e6ee60eeee6e66ee00000000000000000e00e000e00eeee00e0006e0000ee000e0ee66e0000ee60006ee06e000eee06ee
000000000000e00000e0000000000e00ee606eeeeeee06ee0000000000000000e00000000eee00e0000600116000e0000000000066ee6066eeee00000000eeee
0e0eee0ee00ee0ee00000000e00000e0e6ee0ee060e0ee6e0e0e0000e00ee0000e00e00eee0000eee0600c010c010e0e0ee66e00ee6060ee00e0000000000e00
000000000000000e0e000ee00ee000e0e0eee000000eee0e0000000000000000e0000e0ee000000e00e0010601060e000ee66e00ee0060ee6600000000000066
0000000e0000000ee000e000000e000e6eee60000006eee60000000e0000000ee000000e0e00000e0600c110c110c0600ee66e0000ee6000e00000000000000e
0000000e00000000e00e00e00e00e00e6ee600e00e000ee600000000000000000eee0ee000e000e00e001160116010e006e66e0000ee6000e00000000000000e
6aaa6aa0ea6aa6a0e00e00e00e00e000e00600e00e00600e00e00000e0e000e0000000e000e000000e0c010c010c00e00e066e0000000000e0e0e000000ee00e
a666a66ea6666aee000e0e6ee6e0e00e06600e6ee6e066e0e6660e0e666e0e060066066e66ee660000010601060100000eee6e000300000000e0006eee0000e0
a6066660a6e0666ee00e00e00e0000006ee600e00e00eee6e6e006e0ee6000e006eeeeeeee6eeee0060110c110c110600ee66e0004000000e0006e0000ee000e
a6aa660e6666666e000000e00e00e00eeeee00e00e006ee6eeee0e0eeeee060eeeee660eeeeee0e00e016011601160e00ee66e00000003000006000ee000e000
6666606ea66e6a60e00e00e00e00e000600600e00e00600ee0e000e00ee00000e6e6eeeee00666e00e010c010c0100e00ee66e00f7000400e0600ee6eee00e0e
a60e666ea6e6606ee00e0e6ee6e0e00e6e660e6ee6e0ee6666e66e60666e6e60e6eeeee0666eeee00e060106010600e00ee66000f7f0000000e0e6e6e6ee0e00
60eee0e06ee00ee0e00000e00e00000e0eee00e00e006eeeeee6e00eee06e0000eeee66eeeeeeee00000c110c110c0000ee6ee00f7f0f7f00600e6e6e6e60060
0000000000000000000e00e00e00e00e6ee600e00e000ee6eeee0e0eeeee0e0e00ee0eeeeeeeee0006001160116010600ee66e00f7f0f7770e0ee6e6e6e6e0e0
eee0e00ee00eee0ee00000e00e00e00e000e00e00e00600600e0000000e000e00e000e0e006aaa000e0c010c010c00e00ee66e00000003000e06e6e6e606e0e0
00000ee000e0000ee00e0e6ee6e0e00e66e00e6ee6e066eee0660e6ee06e0e666aaaaa60e6aaaaae0e010601060100e00e666e00000004000e0000000000e0e0
000ee000000ee00e000e00e00e00e0006ee600e00e006ee0060e06e60e0006eea0a00aa66a00a00a0e0110c110c110e00ee66e00030000000006e6e6e606e000
00e0000000000e00e00000e00e00000e6eee00e00e00eee6e0e0eeee00e006eea0a00aa66a00a00a0001601160116000000000000400f7f00606e6e6e6e6e060
00000000000000e0000e0000000000000006000000000e06000000e00e0000006a0aaa666aaa0aa606000000000000600ee60e000000f7f00e06e6e6e6eaa0e0
0e000000000000e0e0eeeeeeee0ee00e6e666e66660660ee60e66e6e00606e600aaa666ee66aaa6e0e0a66666666e0e000000000f0f0f7f00e06e6e6e6ea60e0
e00000000000000ee000000000e0000e6e0ee6ee6e6ee0e60e060eee0e06e0e00aeaeee0eeaeaeae00a666aaaa666e00eee600e0f7f0f7f00e06e6e6e6eee0e0
e00000000000000e00e00000e0000000ee0eeeee0eeee6eee0e0eeeee0e0eeeee0ee00000ee0ee0e000000000000000000000000f7f0fff00006e6e6e606e000
00e00000e0e000e0bb8bbbbbb8b8b8bbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbb00aaa600e0e000e00e6aa6e0e66aa66e0e6aa6e00e6aa6e0060000000000e060
e6660e6e666e0e66b898b8bbbb989bbbbbbb88bbbbbbbbbbb88b88bbb22b22bbeaaaaa6e06aaaaa60e6aa6e0000000000e6aa6e00e6aae000e06e6e6e606e0e0
e6ee06e6ee6ee6ee8979898bbb898bbbb8b798bbb9b8b9bb8488488b2bb2bb2ba00a00a66aa00a0a0e6aa6e00e6aa6e00e6aa6e00e6aa0600e06e6e6e6e6e0e0
eeeeeeeeeeee06ee8979798bb89798bb8787978b8987898b8888888b2bbbbb2ba00a00a66aa00a0a00000000000000000e6aa6e00e6a60e00e06e6e6e6e6e0e0
e0e000e00ee00e008797978bb87978bb8979798b8797978bb88888bbb2bbb2bb6aa0aaa666aaa0a60e6aa6e00e6aa6e00e6aa6e00ee00ae00e000000000000e0
66e66e6e666e6e60b97779bbb87778bbb87778bb8877788bbb888bbbbb2b2bbbe6aaa66ee666aaa0000000000e6aa6e00e6aa6e00e0aa6e00e0a66666666e0e0
eee6eeeeeee6eee0b5ddd5bbb5ddd5bbb5ddd5bbb5ddd5bbbbb8bbbbbbb2bbbbeaeaeaee0eeeaea0e66aa66e0e6aa6e00e6aa6e00eaaa6e000a666aaaa666e00
eeeeeeeeeeeeeeeebb5d5bbbbb5d5bbbbb5d5bbbbb5d5bbbbbbbbbbbbbbbbbbbe0ee0ee00000ee0e000000000e6aa6e00e6aa6e00e6aa6e00000000000000000
bbcbcbbbbbbbbbbbcbbbbbbcbbbbbbbbb7bbbbbbbd7ddd5b11111111bbbbbbbbbbbbbbbbbbbbbbbbbb99bbbbbb77bbbbbb88bbbbb7cb7cbbbbbbbbbbbbbbbbbb
bcccc1bbbbcbcbbb1cbbbbc17bbbb7bb77bbbbbbbb5005bb11111111bbbbbbbbb0000bbbbbbbbbbbb9779bbbb7887bbbb8998bbb788c88cbb88b88bbb88b88bb
b7c7c01bbcccc0bb1cbbbbc1b7777bbbbb7bbbbbbbd00dbb11111111bbbbbbbb000000bbbbbbbbbb979879bb787987bb897798bb8487488b8488488b8778778b
10cc1bc107c7c1cb10cbcbcc7bbbb7bbbbb7bbbbb5d70d5b11111111bbbbbbbb5d55050bbbbbbbbb978879bb789987bb897798bb8877788b8888888b8777778b
cbb11bccc0cc1b1cbccccbc1bbbbbbbbbbbb77bbbd7000db11111111bbbbbbbb8588dd0bbbbbbbbbb9779bbbb7887bbbb8998bbbc88788dbb88888bbb87778bb
c1b1bbc1c1b111bcb7c7c111bbbbbbbbbbbb7bbbbd8888db11111111bbbb883bd5dd5d08bbbbbbbbbb99bbbbbb77bbbbbb88bbbbbc888dbbbb888bbbbb878bbb
c1bbbccbb1bbbbbbbbcc111bbbbbbbbbbbbbbbbbb588885b11111111bbbbb083dd33d08344bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc8dbbbbbb8bbbbbbb8bbbb
bcbbbcbbbbbbbbbbbbb111bbbbbbbbbbbbbbbbbbbb5dd5bb11111111bbbb334843443308884bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbbbbbbbbbbbbbbb
bb4b4bbbbbbbbbbb8bbbbbb4bb7b7bbbbbbb7bbbbbb94bbb11111110bbb33444388843300484bbbbbbbbbbbb000bbbbbbbbbbbbb000bbbbbbbbbbbbb000bbbbb
b44448bbbb4b4bbb48bbbb48bbb7bbbbbbbb77bbbbbf9bbb11111100bbb34483888884300384bbbbbbbbbbb03330bbbbbbbbbbb03330bbbbbbbbbbb03330bbbb
bf4f408bb44440bb48bbbb48bbb7bbbbbbb7bbbbb9ff9ffb11111001bb3448488888884000483bbbbbbbbb03777d0bbbbbbbbb03777d0bbbbbbbbb03777d0bbb
80448b480f4f484b404b4b44bbb7bbbbbb7bbbbbb449444b11100010bb3484888484843000384bbbbbbbbb0dd33d0bbbbbbbbb0dd33d0bbbbbbbbb0dd33d0bbb
4bb88b4440448b84b4444b48bbb7bbbb77bbbbbbbbbf9bbb11101000bb4348888844433000084bbbbbbbbb0377000bbbbbbbbb03777d0bbbbbbbbb0377000bbb
48b8bb4848b888b4bf4f4888bb7b7bbbb7bbbbbbbbbf9bbb11001010bb34888888844430000843bbbbbbbb00053730bbbbbbbbb0dd000bbbbbbbbb00053730bb
48bbb44bb8bbbbbbbb44888bbbbbbbbbbbbbbbbbbbbf9bbb11010100bb43488888884300000884bbbbb000d37377730bbbbbbb00053730bbbbb000d37377730b
b4bbb4bbbbbbbbbbbbb888bbbbbbbbbbbbbbbbbbbbb94bbb10000000bb34888848844400000843bbb00d377373333d0bbbb000d37377730bb00d377373333d0b
bbbbbbbbbbbbbb0b0b0bbbbbbbbbbbbbbb0000bb1117111111111111bb43488848884300000884bb0d77373d00573d0bb00d377373333d0b0d77373d00573d0b
bbbbbbbbbbbbbb00000bbbbbbbbbbbbbb0fffb0b11d7111d01111111bb34848883844400000843bb033dd50053dd750b0d77373d00573d0b033dd50053dd750b
bbbbbbbbbbbbbb000a0bbbbbbbbbbbbb0fffffb01d117dd100111111bb43448883884300003884bb03000005d77750bb033dd50053dd750b03000005d77750bb
bbbbbbbbbb0b0b0a000b0b0bbbbbbbbb000b00f01111711110011111bb34834883484400004843bbb00d500d33330bbb03000005d77750bbb00d500d33330bbb
bbbbbbbbbb000000000b000bbbbbbbbb000f00f01117171101011111bb33434883484300008484bbb0d3d503dddd0bbbb0b0d503dddd0bbbb0d3d503dddd0bbb
bbbbbbbb0b0a0000a00b0a0bbbbbbbbb0ff0ffb01dd117d100000111bb34834884344300004843bbb030000377350bbbbbb0d00d77330bbbb030000d77330bbb
bbb0b0bb00000a000000000bb0b0b0bbb0fff00b1111171100001001bbb3483484384000008483bbbb0bbb05ddd000bbbbbb0b053ddd0bbbbb0bbb050ddd50bb
bbb00000000000000000a00bb00000bbb0f0f0bb1111711100000101bbb3343848344000004843bbbbbbbb03775050bbbbbbbb0d37750bbbbbbbbb0d077730bb
bbb0a0bb0000000000000000b000a0bbbbbbbbbb1111111101111110bbb348383804400000444bbbbbbbb05ddd05d0bbbbbbbb003330bbbbbbbbb0555033d0bb
bbb000bb000a000000000000b00000bbbbbbbbbb0000000000111100bbb334343403400000483bbbbbbbb0777505d50bbbbbbb00ddd0bbbbbbbbb0dd50ddd50b
bbb000b0000000000000000000a000bbbbbbbbbb1111111100001100bbb343330400400003444bbbbbbbb033d00d770bbbbbbbb0d77000bbbbbbb033500d770b
bbb000000000000000000000000000bbbbb0bb0b0000000000000000bbb343040300300004343bbbbbbb0d77d0033d0bbbbbbbb053d000bbbbbb0ddd50033d0b
bbb0000000000000000000000000a0bbbb000b001111111100000000bbbb4004000000000443bbbbbbbb0d3350b07750bbbbbbbb077500bbbbbb0d3350b07750
bb0000000000000000000000000000bbb00000000000000000000000bbbb3003000000000433bbbbbbbb0d7d0bb0d3d0bbbbbbbb0d3d0bbbbbbb0d7d0bb0d3d0
b000000000000000000000000000000b000000001111111100000000bbbb3000000000000403bbbbbbb0337d0b0377d0bbbbbbb0377d0bbbbbb0337d0b0377d0
00000000000000000000000000000000000000001111111100000000bbbbb000000000000003bbbbbb0377d500d33d50bbbbbb0d33d50bbbbb0377d500d33d50
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaa777777777aaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaa7777777777777aaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaa777777777777777777777aahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaa77777777777777777777777aaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaa7777777777777777777777777aahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaa777777777777777777777777777aaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh9a77777777777777777777777777777a9hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaa7777777777777777777777777777777aaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa7777777777777777777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaa777777777777777707777777777777777aaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa777777777777777707777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9a77777777777777777077777777777777777a9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaa77777777777777770077777777777777777aaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777770007777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777770007777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777770007777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777700000777777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777000a00077777777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
222222222222222222222222222222222222222222229aa77777777777777700a00777707777777777aa92222222222222222222222222222222222222222222
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aa77777777777777700000777707777777777aa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
222222222222222222222222222222222222222222229aaa777777777777777000777700777777777aaa92222222222222222222222222222222222222222222
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii99aa777777777770077000777700077777777aa99iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
2222222222222222222222222222222222222222222229aaa777777777000770a077700000777777aaa922222222222222222222222222222222222222222222
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii9aaa7777777700007700077770007777777aaa9iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
22222222222222222222222222222222222222222222299aaa777777700a0770007070000777770aaa9922222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222229aaa77777770000000000000000777770aaa9222222222222222222222222222222222222222222222
222222222222222222222222222222222222222222222299aaa0707070000000000000007777700aa99222222222222222222222222222222222222222222222
2222222222222222222222222222222222222222222222299aa00000700000000000000077777000992222222222222222222222222222222222222222222222
2222222222222222222222222222222222222222222222299aaa000770000000000a0a00777700a0992222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222299aa0a00700000a000000000777aa009902222222222222222222222222222222222222222222222
222222222222222222222222222222222222222222222222299a000000000000000000000a0a0009202222222222222222222222222222222222222222222222
2222222222222222222222222222222222222222222222222299000000a000000000000000000002002222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222200000000000000000000000000002000222222222222222222222222222222222222222222222
222222222222222222222222222222222222222222222222222000000000000000a000000000a002002222222222222222222222222222222222222222222222
222222222222222222222222222222222222222222222222220000a0000000000000000000000000002222222222222222222222222222222222222222222222
222222222h222222222222h11222222222222h112222222222000h000000000000h11000a00000000h112222222222222h222222222222h11222222222222h11
22222222hlhh22222222h11l112222222h11h1l1112222222200hlhh00000000h11l110000000h11h1l1112222222222hlhh22222222h11l112222222h11h1l1
2222222hlll1hh2222hh1ll1l1122222h1h11l1lh1112222220hlll1hh0000hh1ll1l1100000h1h11l1lh1112222222hlll1hh2222hh1ll1l1122222h1h11l1l
11222hhh111hh1h2211ll11l1l11222l111hh11hhh1111222hhh111hh1h0011ll11l1l11000l111hh11hhh1111222hhh111hh1h2211ll11l1l11222l111hh11h
1111hhlhh10h000hh1l11l1100h0hhllllh00hh00hhh1111hhlhh10h000hh1l11l1100h0hhllllh00hh00hhh1111hhlhh10h000hh1l11l1100h0hhllllh00hh0
h11hhl10hh010000hhh11000hhhh0lll1lll1hh01hhhh11hhl10hh010000hhh11000hhhh0lll1lll1hh01hhhh11hhl10hh010000hhh11000hhhh0lll1lll1hh0
hhh01110000hl1hhhh000l1hhh00011llll1h001l1hhhhh01110000hl1hhhh000l1hhh00011llll1h001l1hhhhh01110000hl1hhhh000l1hhh00011llll1h001
hh00111h0hh1lll1hh11llllh000l1l1ll11h01lll10hh00111h0hh1lll1hh11llllh000l1l1ll11h01lll10hh00111h0hh1lll1hh11llllh000l1l1ll11h01l
0h0001h0011llllll11ll1h0000ll11l111h01llll1h0h0001h0011llllll11ll1h0000ll11l111h01llll1h0h0001h0011llllll11ll1h0000ll11l111h01ll
000h0h00h1lllllllll11h0001llll11l1hh0lll1l1h000h0h00h1lllllllll11h0001llll11l1hh0lll1l1h000h0h00h1lllllllll11h0001llll11l1hh0lll
00hhhh0hlll1ll1ll1llhh80l11l88818h80888ll1lh00hhhh0hlll1ll1ll1llhh00l11l1ll11h0081lll1lh008hhh0hlll1ll1ll1llhh00l11l1ll11h0001ll
h0hhh00l1lll1ll1ll1h0888111ll8ll8081811ll1hhh0hhh00l1lll1ll1ll1h00l11118l1ll1001811ll1hhh08hh00l1lll1ll1ll1h00l1111ll1ll1001l11l
000hh1ll11ll1lll1hh088l88lh1l81h888l88h11lh0000hh1ll11ll1lll1hh001ll1lh8ll1h011888h11lh00888h1ll11ll1lll18h008ll1lh1ll1h011lllh1
0hh1lh1ll1ll111hh0088lll881h18h0818l8llh1h0h0hh1lh1ll1ll111hh0001lll11881lh001l888lh1h0h0888lh1ll1ll111h8880888l111h1lh001lllllh
0h11llh1l11ll1h00h8881ll8881h8008l81888h0h000h11llh1l11ll1h00h0ll1ll1888hh00hll8881h0h000h81llh1l11ll1h08888l88811h1hh00hll1ll1h
h11lllhhl11h1h00h0888l1l888hh00hlllhl1lh0000h11lllhhl11h1h00h0llll1ll888h00hlll888lh0000h11lllhhl11h1h00888ll888l11hh00hlllhl1lh
11lll1hhll1hh00h0l888llh888h0h0llll81hhh800h81lll18hl88hh00h0llh18lhl8880h0llll888hhh00h11lll1hhll1h800h888h1888l1hh0h0llllh1hhh
11ll1l1hllhh0h00ll8881lh8880h0hlll888hh8880888ll1888l8880h00llll888hh888h0hlll1888h08001118l1l1hllh88800888lh888hhh0h0hlll1h0hh0
hlll1111hhh0h000l1888111888h00ll18888h088881888l18888h888000l1h88881h88888ll1ll8880888h1h8881111hh888800888lh888hh0h00ll1ll00h0h
1ll1l11hhh00000lll888h11h88001ll8h88800888hh8881l888hh88800ll88h88818888888888l88880888h1888l11hh808880l888hh888hh0001lllhlh0000
llh1111hhhh00001ll8881h1h8000h18l1888h0888h188811888hh888001l8l18881h8880h1ll11888008881l888111h8hh8880188811888hh000h1ll1100h00
1l1h1hhh0hh000h11l8881hhh0h01h88l18880h88811888h18880h8880h1881l888hh8881h1ll11888h0888118881hh88hh888h1888l1888h0h01h1ll11h00h0
lllh11h0h00000hhl188811hh000h888lh8880088811888h1888h08880h888hh888hh888hh1llh0888008881l8881188800888hh888hl888h000hh1llh00h000
l11lh1h00h0000hhh8888h1h0h00h888ll888008881l881lh8880h8880h888ll888h0888hhl1ll088800888ll888h1888h0888hh888lh8880h00hhl1ll00h000
lh111h0h00000hh1888881hh000hh888l8888h0888188h11188800888hh888l8888h0888hh81llh88800888ll8881h88808888h1888ll888000hhh11llh00h00
l1h1100000000hhh11888l1hh00h88888l888088888l88h1888800888h88888l888h88881h88ll888808888l88881888880888h8888l8888h00h1h11llh00000
ll011h0000000h1h11888l1h08h1h888ll88800888ll8881188800888h188811888h0888hh888lh88801888ll8881h888008881h8881l8880hh1hh11llh00001
llh0h00h000001hhh1888hhh088118881l88800888ll8880h888008881h888ll888h08881h888lh88801888ll888h088800888hh888l188800011h1l1lh00001
ll100000h000h1h0h1888llh888118881188800888ll88800888808881h8881l888hh8881h8881l88801888ll8880088800888h0888ll888h0011hh111lh0001
lll00h000000h00hhh888ll1888h18881188800888l1888008880888h00888118881h8881188810888018881l8880h888008880h8881l888h00h11hh1101h001
1ll00h000000h0h00h888lll8880h88811h800118lll888008880880h0h888h118ll1888h18811h88811888l1l800h08000080h0888118881h00h1hh11h00011
hll100h00000h000h08881ll88800888h11h00011lll888108880000h00888hh11lll1880h8hh1188801888lhll100h00000h000888h1888l1h00hhhh11h0001
1h00h00hh000000h0088811l888h0880hhh0h00h1lll1800h888h000000h800hh11ll11808h0hhh8880h888l1h00h00hh000000h888hh888l11h00h0hhh0h00h
lhhh0000000000h00h088h11881100000h00000h11lllhhh0888000000h00h00hh111l1180000h08880h18lllhhh0000000000h00800h8881l1100000h00000h
ll1hhh00hh00000h0h0088h88111h0000000000011llll1hh888hh00000h0h00hhh11111h0000008880011llll1hhh00hh00000h0h00h8881111h00000000000
ll111hh00000h00h0hh00888111h1hh0000000h0h11lll111h800000h00h0hh00hhh111h1hh0000080h0h11lll111hh00000h00h0hh00h8h111h1hh0000000h0
111hh0hh00000h000hhhh08hhhhh00hhh0000h0hhhhh111hh08h00000h000hhhh00hhhhh00hhh0008h0hhhhh111hh0hh00000h000hhhh08hhhhh00hhh0000h0h
0hh000000h000000000000000hh0000h0hh0000h00000hh000000h000000000000000hh0000h0hh0000h00000hh000000h000000000000000hh0000h0hh0000h
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000022222222222222222222200002222222000022222222200002222222222222222222200000000000000000000000000000
0000000000000000000000000000002fff2fff2fff22ff22ff200022fffff220002fff22ff200022ff2fff2fff2fff2fff200000000000000000000000000000
0000000000000000000000000000002f2f2f2f2f222f222f2220002ff2f2ff200022f22f2f20002f2222f22f2f2f2f22f2200000000000000000000000000000
0000000000000000000000000000002fff2ff22ff22fff2fff20002fff2fff200002f22f2f20002fff22f22fff2ff222f2000000000000000000000000000000
0000000000000000000000000000002f222f2f2f22222f222f20002ff2f2ff200002f22f2f2000222f22f22f2f2f2f22f2000000000000000000000000000000
0000000000000000000000000000002f202f2f2fff2ff22ff2200022fffff2200002f22ff220002ff222f22f2f2f2f22f2000000000000000000000000000000
00000000000000000000000000000022202222222222222222000002222222000002222222000022220222222222222222000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000hh000000h0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h000000h0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h000000hhh00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h000000h0h00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000hhh00h00hhh00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001010000000000000000000000000000000000000000000003030000000000000000000000000000030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
bdb0b1b0b1b0978180a7b0b1b0b1b0bcbb0087808786878081868786818600bbbc8786818087860000878681808786bcbb0000878081a6b1b0978081860000bbbc00879c81809c86879c81809c8600bc90878687860086878687008786878691b99d00809899a69dad979899810000a8a9b9b8b9b0b1968180a6b0b1a8b8a8b8
bab1b08485b181828380b18485b0b1babd8782838087808485818681828386bdba8687808186870000868780818687babd0000868180a7b0b1968180870000bcba0086ac8a8b9c87869c8a8bac8700ba91808180818681808180878081808190a9b986819899a7b1b0969899808700b8b9a9b9b0b19681808180a6b0b1a8a9a8
90919094959091929390919495909190bc8892938180a79495968980929381bc90919091808790919091868190919091bc0000879190919091909190860000bc919091909a9bac8687ac9a9b919091909081868780488081808148818687809190919091909190919091909188860091bbb9b0b19681808a8b8180a6b0b1a8bb
bbb1b09495bb87929386bb9495b0b1bbbc8192939091909495919091929380bdbb8687808186bb9e9f868780818687bbbc0000868c8283848582838c870000bdbb00868c9a9b909190919a9b8c8700bb91869e9f875881a0a18058869e9f8790b90086899899a7b0b1969899808700a8bdb0b196818a8b9a9b8a8b80a6b0b1bc
bcb0b1a4a5bd86a2a387bca4a5b1b0bdbd80a2a381a6b19495b09680a2a381bcbc8786a0a187bdaeaf8786a0a18786bdbc0000879ca2a3a4a5a2a369860000bcbc00879c9a9b8c86878c9a9b9c8600bc9087aeaf8668860000876887aeaf8691a90000809899a6ad9d9798998100adb8bcb19681809a9b9a9b9a9b8180a6b0bd
bab1b0b1b0ba81808180bab0b1b0b1baba81808980a7b09495989981808188baba8687808186babebf868780818687bcba000086ac80a7b0b19681ac870000baba0086ac9a9b9c87869c9a9bac8700ba9186bebf8780870000868186bebf8790b90086819899a7b0b19698998087a9a8ba96818081aaabaaabaaab808180a6ba
90848590919080828381919091848590909190919091b19495b09091909190919087869190919091909190919087869191000090919091909190919091000090919091909a9bac8687ac9a9b919091909091909180879091909180879091909190008780909190919091909190919091b997808191909190919091908081a7a8
869495b1b0bb81929380bbb0b19495870000868180a7b09495b1978180870000008687808186879e9fbb878081868700870000868c8283848582838c870000860000868c9a9b909190919a9b8c87000081808180818081808180818081808180a00086819899a7b0b1979899808700a1b19681808ca086868686a18c8180a6b0
78a4a5b0b1bc80a2a381bdb1b0a4a5797886828381a6b1a4a5b0968982838779008786a0a18786aeafbc86a0a18786008600008769a2a3a4a5a2a39c860000870000879c9a9b8c86878c9a9b9c860000b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1000078889899a69dad96989981790000b09780816987868a8b87869c8081a7b1
86a7b0b1b0ba81808980bab0b1b0978787899293a6b1b09899b1b0969293808600868780818687bebfba878081868700870000869c80a7b0b196816987000086000086ac9a9b9c87869c9a9bac870000b1b08e8fb1b0b1b0b1b0b1b08e8fb0b0000086819899a7b0b197989989870000b1968180ac8a8b9a9b8a8bac8180a6b0
919091848590918180909184859091909080929390919091909190919293819190919091808790919091868190919091919000879c9091909190919c86009190919091909a9bac8687ac9a9b9190919090978687a6919091909190978687a69190919091909190919091909181860091bbb99091909a9b9a9b9a9b919091a8bb
bbb0b19495b0819e9f80b19495b0b1bbbb819293b0b198999899b0b1929388bbbba087808186879e9f8687808186a1bbbb9190869c82838485828369879190bbbb00868caaab90919091aaab8c8700bbbb968180a78c81a0a1808c968180a7bbb90086819899a7b0b1979899808700a8bcbb8180879a9baaab9a9b868180bbbc
bd9899a4a5b180aeaf81b0a4a5b1b0bcbd80a2a3b1989998999899b0a2a381bcbc8786a0a18786aeaf8086a0a18786bdbc00008769a2a3a4a5a2a39c860000bdbc00879c81808c86878c81809c8600bcba978081a69c800000819c978081a6baa99d00889899a6ad879698998100adb8baba808186aaab8786aaab878081baba
bab0b1b0b1b081bebf80b19899b0b1baba8780a79899989998999899968186baba868780818687bebf868780818687baba000086ac80a7b0b19681ac870000baba0086ac8687ac8786ac8687ac8700ba91909190a7ac81000080ac9691909190b9a986819899a7b0b19798998087b8a8b8b9818087868786878687868180a8a9
9190919091909190919091909190919090909091909190919091909190919091909190919091909190919091909190919190919091909190919091909190919091909190919091909190919091909190909190919091909190919091909190919091909190919091909190919091909191909190919091909190919091909190
bb8180818081808180818081808180bbbbb0b1b0b1b0008681a7b1b0b1b0a7bbbbb1b0b1b0b1b0b1b0b1b0b1b0b1b0bbbb818081808c860000878c81808180bbbb0000000000000000000000000000bbbb0000000000000000000000000000bbbbc6c6c6c6c6c6c6c6c6c6c6c6c6c6bbb9b1b08e00000000000000008fb1b0b8
bc8082838182838088828380828381bdbcb18e818fb1008780a6b08e878fa6bcbcb0b1b0b1b0b1b0b1b0b1b0b1b0b1bdbc80a0a1819c870000869c80a0a181bdbd9800009998990000989998000099bcbd0000000000000000000000000000bcbce6c6c6c6c6c6c6c6c6c6c6c6c6c6bca9b08e008700870087008700878fb1a8
bd8192938092938180929381929380bcbcb0878081b0008681a7b1008681a7bcbc8e8fb18e8fb08e8fb18e8fb08e8fbcbc81000080ac86000087ac81000080bcba9998999899989998999899989998babaf5f5f5f5f5f5f5f5f5f5f5f5f5f5baba00e6c6c6c6c6c6c6c6c6c6d6e6c6bab98e86878687868a8b87868786878fb8
bc80a2a381a2a38081a2a380a2a381bcbcb18681a7b190919091b0008780a6bcbd0000919091900000919091900000bcbd8000008191909190919080000081bc909190919091b198999890919091909190c6c6c6c6909190919091c6c6c6c69190919091d6e690919091c6d690919091a9808180818a8b9a9b8a8b80818081a8
bc8180819190919091909190808188bdbcb0878891909186819091908681a7bcbc87008c00008c87008c00008c8700bdba818081808c8e00008f8c81808180babb998e8f98848584858485b18e8f98bbbbc6c6c6c68cc6c6c6c68cc6c6c6c6bbb9999899000098999899f600989998a8bb978081809a9b9a9b9a9b818081a7bb
bd8089808786878687868786818081bcbcb186818cb1008780a6b08c8788a6bcbc86879c87869c86876987869c8687bc909190808169870000869c8081919091bc989dad99a4a5a4a5a4a5b0ad0099bcbcc6c6c69899c69899c69899c6c6c6bdbc9899980000999899980000999899bcbcb0978a8b9a9b9a9b9a9b8a8ba7b1bc
ba8180818081808188818081808180babab087809cb0008689a7b19c8681a7baba8180ac8081ac8180ac8081ac8180ba91b9808180ac86000087ac818081a890ba999899b1b0b1b198999899989998babad6e6c69998999899989998c6d6e6baba9998999899989998999899989998babab1b09a9b9a9b9a9b9a9b9a9bb1b0ba
9091909181809091909181809091909190919091acb1008780a6b0ac9091909190919091b0b190919091b0b190919091b980a0a18191909190919080a0a181a8909199b0999190919091909899989091910000e69190919091909190d6000090909190919998998e8f989998909190919190919a9b9a9b9a9b9a9b9a9b909190
8e87828380488c82838c48818283868fa6b08e8ca6b091909190b1a08c81a7b0b18e8fb08e8fb18e8fb08e8fb18e8fb097810000808c8e00008f8c81000080a798998e8fb0848584858485998e8f98998e0000008cc6c6d6e6c6d68c0000008f9848b999988e000000008f9998a84899b9b1b09a9b9a9b9a9b9a9b9a9bb1b0a8
8180929388589c929369588092938180a7b18669a6b1a08780a7b0009c89a6b1b00000b10000b00000b10000b00000b196800000819c870000869c80000081a69998ad0099a4a5a4a5a4a5b09dad99989899009899e6d60000f60098990098999958bd988e008d8d8d8d008f99bc5898bbb0b1aaabaaabaaabaaabaaabb0b1bb
8081a2a38068aca2a3ac6881a2a38981a6b000aca7b0008681a6b100ac81a7b0b18700b08600b18700b08600b18700b09781808180ac86000087ac81808180a7989998999899b0b1b0b1b0b1b0b19899989998999800000000000099989998999868ba8c008d8d8d8d8d8d008cba6899bab1b0b1b0b1b0b1b0b1b0b1b0b1b0ba
9091909187869091909187869091909190919091a6b1008180a7b08190919091909190968786909190918786a6919091909190b0b19190b0b19190b0b19190919091909190918e86878f9091909190919190919091000000000000909190919090919069008d909190918d009c919091919091b08e8fb18e8fb08e8fb1909190
8cb1bb8e86878c9e9f8c86878fbbb08ca7b08e8ca7b091909190b1a08c81a7b08c81bb9780818c00008c8081a7bb808cbbb18e8fb0bbb08e8fb1bbb18e8fb0bbbb998e8fb0a09e9f9e9fa1998e8f98bbbb8e008fbb000000000000bb8e008fbbb999989c008d8d8d8d8d8d009c9998a8b98e8fb18687b08786b18687b08e8fa8
69b0bc0000009caeaf9c000000bdb169a6b1789ca6b1a08780a7b0006979a6b19cb0bca881806987869c8180a9bdb19cbdb08700b1bcb18600b0bdb08700b1bcbd989d9db186aeafaeaf87b1ad9d99bcbcf5f5f5bc99f59899f598bcf5f5f5bcbc98999c008d8d8d8d8d8d00699899bdbb8687b08180b18081b08180b18687bb
acb1ba000000acbebfac000000bab0aca7b087aca7b0008688a6b100ac81a7b0acb1baa9b981ac8180ac80b8a8bab0acba99808798ba99818698ba99808798baba9998999887bebfbebf8699989998babac6c6c6ba989998999899bac6c6c6baba9998ac008d8d8d8d8d8d00ac9998baba8180b18081b08180b18081b08180ba
909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909190919091909191f5f5f59190919091909190f5f5f5909091909190919091909190919091909191909190919091909190919091909190
000000000000000000000000000000000000000000000000000000000000000000000000000000009c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
c40200003c5463c5463d5563d5563e5663f5763d55639536295062e50600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506
9102000004612086220c6320f6220d6220b6220962207612056120361201612006020061200602006120060200602006120060200602006020060200602006020060200602006020060200602006020060200602
010100000f11500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90020000016100d6111c61131611146110c6110861105611026150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000562002610006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
d70100000074101701077010170104701017010170101701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
0107000009757097770b7620b7522d7071c7072a7072a707077570777709762097522a7072a7072a7072a70707762077622a70707752077522a70707742077422a70707772077620776207752077520774207732
000700002b7022b70207772077722a70206752067522670204732047322d70209772097722b70207752077522a70206732067322b70207772077722a702067520675226702047520475226702047320473204732
0020000012d6512d5512d4512d351575515745157351572500c5410d5510d4510d3510d250ed25107551074512d6512d5512d4512d351575515745157351572500c5410d5510d4510d3510d2510d2512d2512d35
be070000211572117723167231572d1071c1072a1072a1071f1571f17721167211572a1072a1072a1072a1071e1621e1622a1071e1521e1522a1071e1421e1422a1071e1721e1621e1621e1121e1571e1521e152
be0700002b1022b1021f1721f1722a1021e1521e152261021a1321a1322d10221172211722b1021f1521f1522a1021e1321e1322b1021f1721f1722a1021e1521e152261021a1521a152261021a1321a1321a132
000700002b7022b70207772077722a70206752067522670204732047322d70209772097722b70207752077522a70206732067322b702087700677004770027700775005750037500175005730037300173000750
be0700002b1022b1021f1721f1722a1021e1521e152261021a1321a1322d10221172211722b1021f1521f1522a1021e1321e1322b102061420613206125061100000000000000000000000000000000000000000
b90700002d1172d1372f1572f177000000000000000000002b1172b1372d1572d177000000000000000000002a1122a132000000000000000000000000000000000002a1122a1320000000000000000000000000
a807000000000000002b1422b162000000000000000000000000000000000002d1422d162000000000000000000000000000000000002b1622b142000000000000000000000000000000000001a1321a1321a132
902000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
90200c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
9020000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
90200c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
9020000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
902000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
902000200873508745087350872514040140301572215712087050874508705087251704017030197201971208735087450873508725140401403015722157120070008745087050872517040170301572015712
91200020087350874508735087251c0401c0301e7221e71208705087450870508725170401703019720197120873508745087350872514040140301572215712007000874508705087251c0401c0301e7201e712
690800001c06517755137450070517065137550f74500705130650f7550b745007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
6908000013036177461c75600006170361c74621756000061c0362174626756000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
690800001c06517755137450070517005137050f70500705130050f7050b705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
690800001a0561504610736157261a716000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
690800000e0560904604736157051a705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900800002002421034250442a0552a004000040000400004000040000400004000040000400004000040000436004000040000400004000040000400004000040000400004000040000400004000040000400004
900300000e7111071113711177111c711217112671100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
51080000170221c73221745000001c03221742267550000021042267522a76500000260522b762307750000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910800002a5552554521535255452a5552e5452150520505005050050500505005050050500505005050050536505005050050500505005050050500505005050050500505005050050500505005050050500505
20100000215421f542215422154221532215322153221532215322153218502185021f5221d5221c5221a522195121951219512195121a5221a5221a5221a5220750207502135020b50209502075020950209502
20100000155421354215542155421553215532155321553215532155220050200502105221052211522115320d5320d5220e5220e5220e5220e5220e5220e5221550213502155021350209542075420954209542
2010000015542155421554215542155421554213502115021353211532105320e5320d5320d5320d5320d5320e5320e5320e5320e532000020000200002000020000200002000020000200002000020000200002
681000002d5422b5422d5422d5422d5322d5322d5322d5322d5322d53224502245022b52229522285222652225512255122551225512265222652226522265220750207502135020b50209502075020950209502
20100000215421f542215422154221532215322153221532215322152218502185021c5221c5221d5221d53219532195221a5221a5221a5221a5221a5221a5221550213502155021350215542135421554215542
201000000954209542095420954209542095420750205502075320553204532025320153201532015320153202532025320253202532000020000200002000020000200002000020000200002000020000200002
50100000215352654521535285552153529565215352653521535285452153529555215352b56521535285352153529545215352b555215352d5652153529535215352b545215352d555215352e565215352b535
50100000215352d5452153529555215352b56521535285352153529545215352655521535285652153525535215352654521535215552153522565215351f5352153521545215351d555215351f565215351c555
70100000155351a545155351c555155351d565155351a535155351c545155351d555155351f565155351c535155351d545155351f5551553521565155351d535155351f54515535215551553522565155351f535
701000001553521535155351d535155351f535155351c535155351d535155351a535155351c5351553519535155351a5351553515535155351653515535135351553515535155351153515535135351553510535
70100000095350e54509535105550953511565095350e535095351054509535115550953513565095351053509535115450953513555095351556509535115350953513545095351555509535165650953513535
7010000009035150350903511035090351303509035100350903511035090350e0350903510035090350d035090350e0350903509035090350a03509035070350903509035090350503509035070350903504035
88200000090200e02009020100200902011020090200e020090201002009020110200902013020090201002009020110200902013020090201502009020110200902013020090201502009020160200902013020
8820000009020150200902011020090201302009020100200902011020090200e0200902010020090200d020090200e0200902009020090200a02009020070200902009020090200502009020070200902004020
9120000025d5525d4519d350dd55200502004020732207222fd352fd4517d3517d552105021040217322172225d5525d4519d350dd55230502504025732257222fd352fd4517d3517d55280502a0402a7322a722
9120000025d5525d4519d350dd55200502004020732207222fd352fd4517d3517d552105021040217322172225d5525d4519d350dd55230502504025732257222fd352fd4517d3517d55280502a0402a7322a722
912000002ad552ad451ed3512d552d0502d0402d7322d72234d4534d3534d252c0502c0522a0402a7322a7222ad552ad451ed3512d552d0502d040317323172234d5534d4534d3534d25280402a0302a7222a722
c21800000163702647016570665702657006570264700637006070263701647006470063700607006070062702637006270061700607006070162700607006170061700607006070060700607006070060700607
030400003c6702b6403c67021630376702767034670266602f6602d6602c6602a650276502465022650206501e6501b650196401764015640126400f6300c6300962007620056200362002620006200062000620
__music__
00 06090d44
04 070a0e44
00 08424344
00 06494344
04 074a4344
00 08424344
00 06094344
00 070a4344
00 08424344
00 06094344
04 0b0c4344
00 08424344
01 15424344
00 15424344
00 16424344
02 15424344
01 0f104344
00 0f104344
02 11124344
01 0f132e44
00 0f132f44
02 11143044
00 04424344
04 04424344
00 20234344
00 21244344
00 22254344
01 26286a44
02 27296b44
01 2c424344
02 2d424344

