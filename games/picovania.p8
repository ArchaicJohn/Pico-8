pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--picovania by turbochop
function _init()
---[[


--poke(0x5f5c, 255)

--weapon and item tables
whp={}
itm={}
wpn={}
eft={}

act={}
plt={8,10,7}
--snd={

--player variables
det0={
x=0,
y=0,
h=-2,
w=8,
}
det1={
x=0,
y=0,
h=0,
w=8,
}

ply={
sp0=1,
sp1=17,
x=20,
y=110,
w=8,
h=16,
dx=0,
dy=0,
ox=0,
oy=13,
wo=0,
ho=0,
acc=.6,
buf=0,
anm=0,
tm0=0,
tm1=0,
tm2=0,
tm3=0,
tm4=0,
tm5=0,
str_t=0,
anmoff=0,
flp=false,
wlk=false,
canwlk=true,
stn=false,
dck=false,
jmp=false,
canjmp=true,
lnd=false,
fll=false,
ded=false,
atk=false,
thw=false,
wpn=0,
whp=0,
sht=3,
hth=16,
hrt=false,
blk=false,
pot=false,
blktm0=0,
blktm1=0,
blkmax=15,
pottm0=0,
onstr=false,
ammo=5,
clbur=false,
clbul=false,
clbdr=false,
clbdl=false,
clbing=false,
}
--]]

--general game variables
hrttmr=0
wpncnt=0
bar=16
pck=false
tm0=0
sel=80
camx=0
camy=0
camxmin=0
scene="title"
grav=.1
hrtgrav=.04
song=-1
sound=false
tran=false
stx=20
sty=107
lvs=2
rst=0
so=0
wpnout=0
hndout=0
wpnicn=16
spwntmr=0
clck=200
clckt=0
enmy=16
puptmr0=0
puptmr1=0
pup=false
paltmr=0
psel=1
clock=false
clockt=0
flash=false
flasht0=0
flasht1=0

end

function _update60()


if (scene=="game")  update_game()
if (scene=="title") update_title()
if (scene=="gameover") update_gameover()


end

function _draw()


if (scene=="game")  draw_game()
if (scene=="title") draw_title()
if (scene=="gameover") draw_gameover()


end
-->8
--title and game over
---[[
function update_title()
if pck then
tm0+=.25
end

--button press starts a timer
--for a more polished transition
--variable "pck" is a part 
--of this and is used 
--throughout the code

if btnp(❎) then pck=true 


end

--intialize variables that will
--be used later and start 
--the game

if tm0>=3 then 
music(5)
song=5
tm0=0
pck=false
scene="game"

--]]
end



end


function draw_title()
cls()

print("picovania!",camx+45,camy+52,6)
print("press ❎...",camx+45,camy+60,6)

if pck then
rectfill(camx,camy,camx+140,camy+140,0)

end


end
--]]
function update_gameover()

if pck then 
tm0+=.25

end

if not pck then

--move selector

if btnp(⬇️)  and sel==80 then

sfx(2)
sel=90



elseif btnp(⬆️) and sel==90 then

sfx(2)
sel=80

end
end

if btnp(❎) then 
music(-1)
pck=true
end

if tm0>=3 then

if sel==80 then 

--begin game again

if pck then
music(5)
scene="game"
pck=false
lvs=3
tm0=0
stx=20
sty=107

end

--quit to title

else if sel==90 then 
sel=80
scene="title"
song=-1
pck=false
tm0=0
lvs=3
stx=20
sty=107


end
end
end

end

function draw_gameover()

cls()

spr(12,camx+46,camy+sel)
--print(camx,camx,camy,7)
--print(camy,camx,camy+8,7)

print("game over",camx+50,camy+70,6)
print("continue",camx+55,camy+80,6)
print("end",camx+55,camy+90,6)
if pck then
rectfill(camx,camy,camx+140,camy+140,0)

end

end
-->8
--game
function update_game()
if not pup then
ply_actor()
poke(0x5f5c, 255)
camx=ply.x-60
wpnout+=.1
hndout+=.2
det0.x=ply.x-2
det0.y=ply.y-5
det1.x=ply.x+2
det1.y=ply.y-5
wpnicn=38+ply.wpn
spwntmr+=.1

--game clock
if clck>0 and not ply.ded and not clock then  clckt+=.018
if clckt>1 then
clckt=0
clck-=1
if (clck<=30 and clck>0) then 
sfx(60,1)
end
end
end
if clck<=0 then clck=0
ply.hth=0

end

--placeholder spawners

if spwntmr>1 then spwntmr=1

end

if spwntmr<=.2 then
add_emy(472,80,12)
add_emy(368,40,12)
add_emy(583,80,12)
add_emy(640,80,12)
--add_emy(736,80,12)
--add_emy(320,64,12)
add_emy(229,24,12)
add_cdl(70,102,24)
add_cdl(75,36,12)
add_cdl(100,36,12)
add_cdl(150,102,12)
add_cdl(125,102,24)
add_cdl(40,102,13)
add_cdl(616,50,39)
add_cdl(596,50,12)
add_cdl(690,40,45)
add_cdl(570,74,12)
add_cdl(630,74,12)
add_cdl(680,74,13)
add_cdl(740,74,12)
---[[
add_cdl(100,85,13)
add_cdl(16,60,44)
add_cdl(200,102,42)
add_cdl(250,102,12)
add_cdl(264,20,45)
add_cdl(300,20,44)
add_cdl(320,62,40)
add_cdl(360,85,41)
add_cdl(512,50,43)
--]]
end
if wpnout>1 then wpnout=1

end

if hndout>1 then hndout=1

end

if camx<=camxmin then camx=camxmin

end

--temporoary scroll stop

if camx>=797 then camx=797
end

camera(camx,camy)

--enemy actor update loops


for a in all(act) do

if tran then del(act,a)
end
if a.x>=ply.x-100 and a.x<=ply.x+100 then

a:update()
for a in all(act)do
if hit(a.x+4,a.y,ply.x,ply.y-9,ply.h+3,ply.w)
and a.harm and hrttmr==2 and not ply.blk
 then
sfx(48)
ply.hth-=2
hrttmr=0
ply.hrt=true
ply.tm3=0
ply.tm4=0

ply.dy=-1
if a.x<=ply.x then ply.flp=true
elseif a.x>=ply.x then ply.flp=false

end--]]
end
end
end
end



for whp in all(whp) do
whp:update()
for a in all(act) do
if whp.frm==3
and whp.tm0>=.5 then

if hit (a.x+4,a.y+6,whp.x,whp.y,whp.h+13,whp.w+(9*whp.w))
and 
a.tm2==1 then 
a.tm2=0 
   add_spk(whp.w+a.x,whp.y)
   if ply.whp==0 then
   a.life-=1
   else a.life-=1.5
   end
   if a.life>=1 then sfx(63)
   elseif a.life<=1 then
   sfx(47,3)
   
   
   end
   end
 end  
end
end

for ef in all(eft) do
ef:update()

end

for wpn in all(wpn) do
wpn:update()
--[
for a in all(act) do

if hit (a.x+4,a.y+6,wpn.x,wpn.y,wpn.h+10,wpn.w+10)
and 
a.tm2>=1 
then
a.tm2=0
   add_spk(a.x+wpn.w,wpn.y+a.h)
   if ply.wpn==3 then a.life-=3
   else a.life-=1
   end
   if a.life>=1 then sfx(63,3)
   elseif a.life<=1 then
   sfx(47,3)
   if flash==true then a.life-=100

end
   end
  if wpn.sp==39 then wpn.life-=2   
   
   
  end
 end  

end

end

for i in all(itm) do
i:update()
end



end
if pup then puptmr0+=.1
paltmr+=1
if paltmr>=3 then 
paltmr=0 
psel+=1
end
if psel>3 then psel=0
end
---[[
if paltmr>=1 then 
end
--]]
if puptmr0>=5 then
paltmr=0
puptmr0=0
pup=false
psel=0
end
end
end
function draw_game()

cls()
if flasht0>=.5 then rectfill(camx,camy,camx+140,camy+140,7)
end

--pal(11,9)
map(0,0,0,0,128,32)
spr(31,camx+12,camy+10)
spr(12,camx+90,camy+11)
spr(15,camx+113,camy+5)
--status bar (temporary?)
---[[
for b=1,bar do 

 spr(46,camx+20+b*2,camy+9)
 
 
  end

for h=1,ply.hth do 

 spr(47,camx+20+h*2,camy+11)
 
 
  end
  for h=1,enmy do 

 spr(63,camx+20+h*2,camy+9)
 
 
  end
  
  spr(wpnicn,camx+61,camy+7)
  rect(camx+58,camy+5,camx+71,camy+16,8)
--]]
--non player draw loops
for ef in all(eft) do
ef:draw()
--rect(x1r,y1r,x2r,y2r,7)
end

for whp in all(whp) do
whp:draw()
end
---[[


for a in all(act) do
if a.x>=ply.x-100 and a.x<=ply.x+100 then
a:draw()

end
end
--]]
for i in all(itm) do
i:draw()

end
if ply.pot then


pal(14,7)

end

if ply.blktm0<.5 then
if pup then 
pal (11,plt[psel])
pal(2,plt[psel-1])
pal(3,plt[psel+1])
pal(14,plt[psel+2])
else
pal(11,9)
pal(2,1)
pal(14,15)
pal(3,4)

end

if ply.pot then 
ply.pottm0+=.17
if ply.pottm0>=10 and ply.pottm0<=25 then 
pal(11,7)
pal(2,7)
pal(14,12)
pal(3,6)


end 
end
if ply.pottm0>=25 then
sfx(59,0,4,4)
ply.pottm0=0
ply.pot=false
ply.blk=true
end
spr(ply.sp0,ply.x+ply.ox,ply.y+ply.oy,1,1,ply.flp)
spr(ply.sp1,ply.x+ply.ox,ply.y+ply.oy+8,1+ply.wo,1+ply.ho,ply.flp)
--rect(x1r,y1r,x2r,y2r,7)
pal()



end

for wpn in all(wpn) do
wpn:draw()
--rect(x1r,y1r,x2r,y2r,7)
end







--status bar (preliminary)

print (" sc 000000      time p=",camx+10,camy+4,7)
print ("                      =",camx+10,camy+10,7)


print (lvs,camx+102,camy+4,7)
print (ply.ammo,camx+102,camy+10,7)
print (clck,camx+78,camy+10,7)



if tran then

rectfill(camx,camy,camx+140,camy+140,0)

end

if flash then 
flasht0+=.5
flasht1+=.1
end

if flasht0>=1 then flasht0=0
end
if flasht1>=1.5 then flash=false 
flasht1=0
flasht0=0

end


end


-->8
--player

function ply_actor()


 if (ply.clbur or ply.clbdl) or ply.clbul or ply.clbdr
 then ply.onstr=true
 so=1
 else ply.onstr=false
 so=0
 end
 
 --temporary checkpoint...
 if ply.x>=420 and not tran
  then stx=431
       sty=40
  elseif lvs==0 and tran then       
       stx=20
       sty=107
  
 
 end
 
--post-hit invincibility effect
 
 if ply.blk then plyblk()

 end

--run these if player is alive

 if ply.hth>=0 then
 atk_state()
 ply_stn()
 anmdta()
 ply_cld()
 
 end

--otherwise run these

 if ply.hth<=0 then
 anmdta()


 end

--check if in range of stairs

 if ply.str then

 st_start()

end

--if so, then prepare for 
--stair movement 
--these are subject to change
---[[ 
 if ply.clbing==false then
 
 if ply.clbur and (btn(⬇️)or btn(⬅️)) then
 ply.clbur=false
 ply.clbdl=true
 
 elseif ply.clbul and (btn(⬇️)or btn(➡️)) then
 ply.clbul=false
 ply.clbdr=true

 elseif ply.clbdr and (btn(⬆️)or btn(⬅️)) then
 ply.clbdr=false
 ply.clbul=true
 
elseif ply.clbdl and (btn(⬆️)or btn(➡️)) then
 ply.clbdl=false
 ply.clbur=true
 
 end
 end
 --]]
--climb up

 if ply.clbur then str("rt","up")
 end
 if ply.clbul then str("lt","up")
 end
--climb down

 if ply.clbdr then str("rt","dn")
 
 end
 
 if ply.clbdl then str("lt","dn")
 
end
--if you aren't climbing
--you are either dead, dying or
--walking


 if not (ply.ded or ply.hrt) and not ply.onstr

 then ply_mvmt()

 end
 
 
 
 

--bottomless pits

 if ply.y>140  then falldeath()
 

 end
---[[

--debug control



 if btn(⬆️) and (btn(❎)and btnp(🅾️)) and not ply.hrt and not ply.blk  then  
 
 foreach(act, del)
 end
  --]]
 
 
--player is hurt

 if ply.hrt and not ply.onstr then hurt()
 elseif ply.hrt and ply.onstr then strhurt()
 end
--[
 
 --is health zero?
 
 if ply.hth<=0 then ply.hth=0

--]]
  
--don't die until you are 
--grounded 
  
  if not ply.hrt  then
  if not ply.stn then
  if ply.lnd then
death()
end  
end  
end
--]]

 end

end

--player control

function ply_mvmt()

ply.x+=ply.dx
ply.y+=ply.dy
ply.dy+=grav
hrttmr+=.1

 --stop to attack
 ---[[
 if not ply.atk then ply_walk()
 
 end
--]]
 --maintain momentum 
 --while jumping

 if ply.wlk then ply.dx=ply.buf
 else ply.dx=0

 end

--sprite facing 

 if not (ply.jmp or ply.fll or ply.stn or ply.atk) then
  if btn(➡️) then ply.flp=false
  elseif btn(⬅️) then ply.flp=true

  end


 end
 
--stop moving 

 if ply.canwlk==false  then
 ply.dx=0

 end

 --duck and stop walking
 --also homing behavior
 --for stair railings
 
 if (btn(⬇️) or ply.stn)  and not (ply.fll or ply.jmp or (collide_map(ply,"down",7) or collide_map(ply,"down",5))) and ply.tm3==0 then 
 ply.dck=true 
 ply.canwlk=false

 --stand up
 --attacking delays response
 
 elseif not btn(⬇️) and not ply.atk then
 ply.dck=false
 ply.canwlk=true
 if ply.onstr then ply.dck=false
end

 end

--is player ducking?
 
 if ply.dck==false   then

--if not, player can walk
  
  if btn(➡️) and ply.lnd and not ply.atk and not ply.thw and not ply.onstr then  
  ply.dx=ply.acc 
  ply.buf=ply.acc  
  ply.wlk=true

 elseif btn(⬅️) and ply.lnd and not ply.atk and not ply.thw then  
 ply.dx=-ply.acc 
 ply.buf=-ply.acc 
 ply.wlk=true

--commit to your jumps...
 
 elseif ply.lnd then

 ply.wlk=false
    
  end
  
 end
  
 if btnp(❎) and ply.lnd==true and ply.canjmp and not (ply.stn or ply.dck) and not (ply.atk or ply.thw) then 
 ply.lnd=false
 ply.jmp=true
 --ply.str=false
 ply.dy=-1.8

 end
  
  
--hurt timer

if hrttmr>=2 then hrttmr=2

end
 
 --begin plummeting
 
 if ply.jmp and ply.dy>=2  then 
 ply.fll=true
 
 end
  --]]
  ---[[
 if ply.fll then 
 
 ply.dy=4
  if not ply.jmp then
 
   if not ply.flp then
   ply.dx=.2
   else ply.dx=-.2
 
   end
 
  end
 
 end
 --]]
 
 --stun timer (function below)
 
 if ply.stn==true then
 ply.tm2+=.1
  if ply.tm2>=1.5 then ply.stn=false
  ply.tm2=0
 
  end
 
 end

end

--falling death

function falldeath()
ply.dx=0
ply.dy=0
--ply.dy=.5 
ply.tm0=0 
ply.fll=false
rst+=.1
 
--play death song 
---[[ 
 if not ply.ded then
 music(15)
 ply.ded=true
 
 end
--]]
--screen transition 
 
 if rst>=9 then tran=true

 end 

 if rst>=12 then 

  if rst>=12 then

   if  lvs<=0 then 
   music(4)
   scene="gameover"


   elseif lvs>=0 then ply_rst()

   end

  end

 end

end

--player knockback

function hurt()

ply.anm=13
ply.x+=ply.dx
ply.y+=ply.dy


--a little hang time...
 
 if ply.dy<=0 then
 ply.dy+=hrtgrav

 end
--]]
 if ply.dy>=0 then 
 ply.dy+=grav

 end
 
--...then a plummet 
 
 if ply.dy>=2 then
 ply.dy=4
 ply.tm0+=.1

 end

--]]

--knockback direction
---[[
 
 
 if not ply.flp then 
 
 ply.dx=-.5
 
 else 
 
 ply.dx=.5

 

 end
--]]
--prevent passing through
--ceiling (testing...)
 
 if collide_map(ply,"up",0) and ply.hrt then 
 ply.dy+=1
 ply.dx=0
 end

--land from knockback
--and reel for a moment
 
 if collide_map(ply,"down",0) then 
 ply.y-=(ply.y+ply.h)%8
 ply.dx=0
 ply.dy+=1
 ply.tm2+=.1
  
--land from a high fall and
--legs buckle
 --[[ 
  if ply.dy>=4 and ply.tm0>=.7 then 
  sfx(58,3)
  ply.tm0=0
 
  end
--]]
--back in the action 
 
 if ply.tm2>=1.5  then 
 ply.tm2=0
 ply.hrt=false

 end

--did that hit kill the player?
--if so, then die!

 if ply.hth==0 and ply.lnd then
 death()

--otherwise, grant post-hit
--invincibility (function below)
  
  elseif ply.hth>=0 then 
  ply.blk=true
  
  ply.anm=10

  
 
  end
 end
end

--normal death

function death()

deathanim()
ply.tm0=0 
rst+=.1


 if not ply.ded then

--play the death song

 music(15)
 ply.ded=true

 end

--black screen for transition
--(effect is in draw function)

 if rst>=10 then tran=true

 end 

 if rst>=12 then

--if player is out of lives
--the game is over  
  
  if  lvs<=0 then 
  music(4)
  scene="gameover"
  
--otherwise, reset the player  
   
   elseif lvs>=0 then ply_rst()

   end

 end

end

--reset the player 

function ply_rst()
rst=0
lvs-=1
ply.hrt=false
ply.hth=16
ply.whp=0
ply.tm4=0
ply.tm3=0
ply.ded=false
ply.x=stx
ply.y=sty
tran=false
ply.flp=false
ply.wpn=0
ply.ammo=5
ply.jmp=false
ply.tm5=0
ply.ox=0
spwntmr=0
clck=300

music(5)

end

--player post-hit invincibility



function plyblk()

ply.blktm0+=.5
if not ply.pot then
ply.blktm1+=.1
end

 if ply.blktm0>=1 then ply.blktm0=0

 end
 
 if ply.blktm1>=ply.blkmax then
 ply.blktm1=0
 ply.blktm0=0
 ply.pot=false
 ply.blk=false
 
 end
end


function strhurt()
ply.tm5+=.1



--did that hit kill the player?
--if so, then fall off 
--stairs and die!

 
--otherwise, grant post-hit
--invincibility 
  
  if ply.hth>=0 and ply.tm5>=1 then 
  ply.blk=true
  ply.hrt=false
  ply.tm5=0
 
  
end

end

-->8
--collision



function collide_map(obj,mov,flag)
--obj = table needs x y w and h
--mov = left,right,up,down
 
 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h
 

 local x1=0  local y1=0
 local x2=0  local y2=0
  
 
  
 
 ---[[
 
 if mov=="down"
 then
 
   x1=x+3   y1=y+13
   x2=x+4   y2=y+h
 ---[[  
 elseif mov=="up" then
 
   x1=x+2   y1=y+13
   x2=x+5   y2=y+7
 --]]
 elseif     mov=="left"  then
   x1=x-1      y1=y+7
   x2=x+2    y2=y+h-3
 
 elseif mov=="right" then
 
   x1=x+4    y1=y+7
   x2=x+7    y2=y+h-3
   
 
 ---[[  
 


end
---[[
x1r=x1  y1r=y1
x2r=x2  y2r=y2

--]]

---[[
--pixels to tiles
 x1/=8   y1/=8
 x2/=8   y2/=8
 --]]
 if fget(mget(x1,y1), flag) 
 or fget(mget(x1,y2), flag) 
 or fget(mget(x2,y1), flag) 
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
  end
end


function ply_cld()

--collide with floor 
 
 if ply.dy>0 and not ply.onstr then

  if collide_map(ply,"down",0)  then
      ply.dy=0
      ply.jmp=false
      ply.lnd=true
      ply.fll=false
      ply.y-=(ply.y+ply.h)%8
      
  end
  
  if collide_map(det0,"down",0) or collide_map(det1,"down",0) then
  
  ply.canjmp=false
  else ply.canjmp=true
  
  end
  
  
 
--stair homing behior
 
   if ((collide_map(ply,"down",6) and btn(⬆️)) or (collide_map(ply,"down",5) and btn(⬇️))) 
   and  not ply.wlk 
   and not ply.onstr 
   and not ply.jmp 
   and not ply.ded 
   and not (ply.atk or ply.thw)
   and not ply.hrt then
   ply.dx=.6
   ply.wlk=true
   ply.flp=false
  
   end
  ---[[
 if ((collide_map(ply,"down",7) and btn(⬇️)) or (collide_map(ply,"down",4) and btn(⬆️)))
   and not ply.wlk 
 and not ply.onstr 
 and not ply.jmp 
 and not ply.ded 
 and not (ply.atk or ply.thw)
 and not ply.hrt then
  
  ply.dx=-.6
  ply.wlk=true
  ply.flp=true
  
  
 end


--]]  

--the player is in range of 
--stairs?  
 
 if collide_map(ply,"down",1) 
 or collide_map(ply,"down",2) 
 or collide_map(ply,"down",3) 
  
 and not ply.stn then
 ply.str=true

 else ply.str=false

 end

--walk off a ledge and plummet

 if not collide_map(ply,"down",0) 
 --[
 and not 
 (ply.jmp or ply.ded or ply.hrt) 
 then 
 ply.fll=true
 
   end
 
 end
---[[

 if ply.dx<0 then

  if  collide_map(ply,"left",0) 
  and not ply.onstr 
  then
  ply.dx=0
  
  end
  
 end


 if ply.dx>0 then

  if collide_map(ply,"right",0) 
  and not ply.onstr then
      ply.dx=0

  end
  
 end

end

function hit (x,y,ox,oy,oh,ow)
  if (x>ox and x<ox+ow) and
     (y>oy and y<oy+oh) then
     --there has been a collision
     return true
     end
   
   return false
  
  end
-->8
--attacks
--whip

function attack()
 if ply.tm4>=4.1 then 
 ply.tm4=0
 ply.anmoff+=1

 end

 if ply.thw or ply.atk  then 
 ply.anm=4+ply.anmoff

 end

 if ply.dck or ply.stn then
 ply.anm=7+ply.anmoff

 end
 if ply.thw and ply.anm==6 
 and wpnout>=1

  
  
  then
 add_hand()
 add_wpn(ply.x,ply.y-4)
 
 wpnout=0
 hndout=0
 end
 --[[
 if (ply.thw  
 and ply.anm==6 and hndout>=1
 then
 
 
 hndout=0
 
 end
--]]
end
--[[
function throw()
 if ply.tm4>=4 then 
 ply.tm4=0
 ply.anmoff+=1

 end

 if  ply.thw then 
 ply.anm=4+ply.anmoff

 end

 if ply.dck or ply.stn then
 ply.anm=7+ply.anmoff

 end

end

--]]
function atk_state()

--interrupt attack 
 
 if (ply.hrt or ply.ded) then 
 ply.thw=false
 ply.atk=false

 end

--attacking?

 if not (ply.hrt or ply.ded) 
 -- and not ply.onstr
  then
 
  if not btn(⬆️) and btnp(🅾️) and not ply.atk  
  
   then  
 
--bring out the weapon 
 
   add_whip()
   ply.atk=true
   end
 
 end
 
 if btn(⬆️) and btnp(🅾️) 
 and not (ply.atk or ply.thw) --and not ply.onstr 
 then  
 if wpncnt<ply.sht and ply.wpn~=0 and ply.ammo~=0 then   
 
 ply.thw=true 
  if ply.wpn==5 then ply.ammo-=5
  --clock=true
  else ply.ammo-=1
  end
  if ply.wpn==5 and not ply.clock then
  sfx(56)
  music(-1)
  clock=true
  
  end
 elseif ply.sht>=wpncnt then
 
   add_whip()
   ply.atk=true
 
 end 
--begin attack 
 end
 if not ply.ded then
 if ply.thw or ply.atk then
 ply.tm3+=.15
 ply.tm4+=.5
 attack()
 
--finish attack  
  
  if ply.tm3>=3.5 then
  ply.tm3=0
  ply.tm4=0
  ply.atk=false
  ply.thw=false
  ply.anmoff=0
  --sound=false
  
  end
  
  end
 end
 --[[
  if not (ply.thw or ply.atk)  
  then ply.anmoff=0
  
  end
 --]] 
if clock then
clockt+=.022

end
if clockt>=3.5 then
music(5)
clockt=0
clock=false
end
end




-->8
--stairs
--[
function st_start()
--prepare to climb

--climb up and right
 if btn(⬆️) then 
  
 if collide_map(ply,"down",2) 
 and collide_map(ply,"down",6) 
 and not ply.flp and ply.str
 then ply.clbur=true
 ply.wlk=false
 
 elseif collide_map(ply,"down",4) 
 and collide_map(ply,"down",1) 
 and ply.flp
 then ply.clbul=true
ply.wlk=false
 end
 end
--climb down and left 
 
 

 if btn(⬇️) then
  
if collide_map(ply,"down",5) 
 and collide_map(ply,"down",2) 
 and not ply.flp
 then ply.clbdr=true
 ply.wlk=false
 
 elseif collide_map(ply,"down",3) 
 and collide_map(ply,"down",7) 
 and ply.flp
 then ply.clbdl=true
ply.wlk=false
 end

end

end

function str(_xdir,_ydir)
xdir=_xdir
ydir=_ydir
ply.lnd=false
ply.x+=ply.dx
ply.y+=ply.dy

if not ((ply.atk or ply.thw) or ply.hrt)
then ply.str_t+=.06
else ply.str_t+=0

end

--face the correct way 
 if xdir=="lt" then ply.flp=true
 else ply.flp=false
 
 end
if not ((ply.atk or ply.thw) or ply.hrt) then
 
 if xdir=="rt" then 
 ply.dx=.25
 else ply.dx=-.25

 
 end
 
 
 if ydir=="up" then 

 
 ply.dy=-.25
 else ply.dy=.25
 
 end
 
 else ply.dx=0
      ply.dy=0
 
 end
 

--movement timer 
 
 if ply.str_t>=1 then 
 
 ply.str_t=1

 end

--climb a step at a time 
 

 if ply.str_t<.5 
 then 
 ply.clbing=true
 ply.anm=0
elseif ply.str_t>=.5 
 then 
 
 if ydir=="up" then ply.anm=11
 else  ply.anm=12
  
  end
  
  --stop here
  
  if   
  ply.str_t==1 then 
     ply.clbing=false
     ply.dx=0
     ply.dy=0 

 end
 
 end

--climbing controls

 if (btn(⬆️) or (btn(➡️)) or ((btn(⬇️)or (btn(⬅️))))) 
 and ply.str_t==1 

 then

 ply.str_t=0
 
end


--end climbing 

 if ply.str_t>=.66 
 and collide_map(ply,"down",7) or ply.hth<=0
 then 
 ply.str_t=0
 ply.clbur,ply.clbul,ply.clbdr,ply.clbdl=false,false,false,false
 ply.clbing=false

 end
 
 
end

--]]
-->8
--animation

function anmdta()
---[[
 if ply.anm==0 then 

 ply.sp0=3
 ply.sp1=19

 end
--]]
 if ply.anm==1 then 

 ply.sp0=4
 ply.sp1=20

 end
---[[
 if ply.anm==2 then 

 ply.sp0=3
 ply.sp1=19

 end
--]]
--standing and walk
 if ply.anm==3 then 

 ply.sp0=2
 ply.sp1=18

 end

--whip (standing)
 if ply.anm==4 then 

 ply.sp0=5
 ply.sp1=18

 end

 if ply.anm==5 then 

 ply.sp0=6
 ply.sp1=18

 end

 if ply.anm==6 then 

 ply.sp0=7
 ply.sp1=18

 end


--whip (ducking)
 if ply.anm==7 then 

 ply.sp0=5
 ply.sp1=21

 end

 if ply.anm==8 then 

 ply.sp0=6
 ply.sp1=21

 end

 if ply.anm==9 then 

 ply.sp0=7
 ply.sp1=21

 end

--duck
 if ply.anm==10 then 

 ply.sp0=2
 ply.sp1=21
 
 if not ply.onstr then
 ply.oy=4

 end
 end


--upstair
 if ply.anm==11 then 

 ply.sp0=4
 ply.sp1=22

 end


--downstair
 if ply.anm==12 then 

 ply.sp0=4
 ply.sp1=23

 end

--knockback

 if ply.anm==13 then 

 ply.sp0=8
 ply.sp1=23

 end

--keel over

 if ply.anm==14 then 
 ply.oy=4
 ply.sp0=8
 ply.sp1=21

 end

--lying on floor

 if ply.anm==15 then 
 ply.wo=1
 ply.oy=0
 ply.sp0=16
 ply.sp1=25
 if ply.flp then ply.ox=-8
 else ply.ox=0
 
 end
 
 else ply.wo=0
 
 end

end

--land from a high fall

function ply_stn()

 if ply.tm0>=.7 and ply.lnd==true 
 then ply.stn=true
 sfx(58,3)
 ply.tm0=0

 elseif ply.tm0<1 and ply.lnd==true

 then ply.tm0=0

 end

end

--walking

function ply_walk()

 if ply.fll==true
 then ply.tm1=0
     ply.tm0+=.1
     ply.lnd=false
     
 end

--
--]
 if ply.tm0>=1 then ply.tm0=1

 end
--]
 if ply.wlk==true 
 and ply.dck==false 
 and not ply.jmp then

 ply.tm1+=.15

 else ply.tm1=0 ply.anm=3 

 end

--animation cycle

 if ply.tm1>=1 then 
 ply.tm1=0 
 ply.anm+=1

 end

 if ply.anm>=4 then ply.anm=0

 end

--jumping

 if  (ply.jmp and ply.dy<.5) then 

 ply.anm=10
 ply.oy=2

 elseif ply.dck  then
 ply.anm=10

 else ply.oy=0

 end



end

function deathanim()

ply.tm5+=.1

 if ply.tm5>=2 then ply.tm5=2
 end

--slump over 
 
 if ply.tm5<1 then 

 ply.anm=14

 else ply.anm=15 

 end

end
-->8
--weapons

function add_wpn(_x,_y)
x=_x
y=_y

if ply.wpn~=0 then wpncnt+=1

if     ply.wpn==1 then 
add_knf(x,y)

elseif ply.wpn==2 then 
add_wtr(x,y)

end

if ply.wpn==3 and not ply.flp then 
add_brg(x,y+4,1.1,"right")
elseif ply.wpn==3 and ply.flp then
add_brg(x,y+4,-1.1,"left")

end
--[[
elseif ply.wpn==5 then 
stpwch(x,y)
--]]



if ply.wpn==4 and not ply.flp then 
add_axe(x,y,.8)
elseif ply.wpn==4 and ply.flp then
add_axe(x,y,-.8)

end
end
end



function add_whip()

add (whp,{
---[[
w=1,
h=2,
ox=0,
oy=ply.oy,
flp=ply.flp,
frm=1,
tm0=0,
sp=32,
--spo=0,
snd=false,
--]]
update=function(self)
 self.tm0+=.5
 self.x=ply.x+self.ox
 self.y=ply.y+self.oy
--correct facing 
 
 if not self.flp then 
 self.ox=-8
 elseif self.flp then
 self.ox=7
 end
 --whip graphic
 if ply.whp<=0 then
 self.sp=32
 else self.sp=34
  
 end

--whip crack 
 
 if self.frm==2 and self.snd==false 
 then 
 sfx(46,3)
 self.snd=true

 end
  

 
 if self.tm0>=4 then 
 self.tm0=0
 self.frm+=1
 
 end
 
 if self.frm==2 then
 if ply.whp==0 then
 self.sp=49
 else self.sp=35
  end
--modifier to adjust sprite 
--length 
 
 elseif self.frm==3 then
 self.h=1
 self.ox=-self.ox

 if ply.whp==0 then
 self.sp=36
 self.w=2
 elseif ply.whp==1 then
 self.sp=52
 self.w=2
 elseif ply.whp==2 then
 self.sp=54
 self.w=3
end
--offset if facing left 
 
  if self.flp then self.ox=-16
 
  end
 
 end
 

 ---[[
 if not ply.atk 
 or (ply.hrt or ply.ded)
 then
 
 del(whp,self)
 
 end
 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y,self.w,self.h,self.flp)
-- print(self.w,self.x,self.y-8)
 end
 
 })

end



function add_knf(_x,_y)

add (wpn,{
x=_x,
y=_y+4,
h=1,
w=1,
dx=2,
sp=39,
flp=ply.flp,
tm0=0,
life=1,

--]]
update=function(self)
self.x+=self.dx
self.tm0+=.2
if self.flp then self.dx=-2
else self.dx=2
end
if self.tm0<.21 then
sfx(49,3,0)
end

if self.x<camx-20 or self.x>camx+140 or self.life<=0 then

wpncnt-=1

del(wpn,self)

end

end,

draw=function(self)

 spr(self.sp,self.x,self.y,1,1,self.flp)
 --print(self.tm0,self.x,self.y-8)
 --print(self.frm,self.x,self.y-16)
 end
 
 })

end

function add_wtr(_x,_y)

add (wpn,{
---[[
x=_x,
y=_y+4,
dx=0,
dy=-1,
w=1,
h=1,
off=2,
ox=0,
oy=5,
flp=not ply.flp,
frm=1,
tm0=0,
sp=17,
life=1,
snd=false,
--]]
update=function(self)
 --self.tm0+=.5
 self.x+=self.dx
 self.y+=self.dy
 self.dy+=grav
 
 if collide_map(self,"down",0) and self.snd==false 
then
self.dx=0 
self.dy=0 
sfx(50,1,0)
self.snd=true
add_brn(self.x,self.y)
del(wpn,self)


 end
 --[[
 if self.dy<=0 then
 self.dy+=hrtgrav

 end

 if self.dy>=0 then 
 self.dy+=grav

 end
 
 --]]

if self.y>=140 then 
wpncnt-=1
del(wpn,self)

end
  
 if not self.flp then 
 self.ox=1
 self.dx=-1
 elseif self.flp then
 self.ox=-1
 self.dx=1
 end
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y,self.w,2,self.flp)
 --print(self.tm0,self.x,self.y-8)
 --print(self.frm,self.x,self.y-16)
 end
 
 })

end

function add_brg(_x,_y,_dx,_dir)

add (wpn,{
dir=_dir,
x=_x,
y=_y,
h=1,
w=1,
dx=_dx,
maxdx=1,
sp=28,
tm0=0,
tm1=0,
tm2=0,
rtn=false,
rtndx=.1,

update=function(self)
self.x+=self.dx
self.tm0+=.01
self.tm1+=.3*self.dx
self.tm2+=.02

if self.dx>self.maxdx then
self.dx=self.maxdx
elseif self.dx<-self.maxdx then
self.dx=-self.maxdx
end

if self.tm2>=1.3 then
self.rtn=true
self.tm2=1.3

end
 if self.rtn then
 
 if self.dir=="right" then self.dx-=self.rtndx
elseif self.dir=="left" then self.dx+=self.rtndx

end
end

if (self.x>camx+120 or self.x<camx) and self.rtn==false
then
self.rtn=true 
self.dx=-self.dx

end


if self.tm0>=.15 then
--sfx(51,3)
self.tm0=0
end
---[[
if self.tm0==.02 then

sfx(51,3)
end
--]]

if self.tm1>=1 then

self.tm1=0
self.sp+=1

end

if self.tm1<0 then

self.tm1=1
self.sp-=1

end


if self.sp>30 then self.sp=28

end

if self.sp<28 then self.sp=30

end

if (self.x<camx-20 or self.x>camx+140)
or (hit(self.x+4,self.y,ply.x,ply.y-9,ply.h+3,ply.w) and self.rtn) 
then

wpncnt-=1

del (wpn,self)

end
end,
draw=function(self)

 spr(self.sp,self.x,self.y)
 --print(self.rtn,self.x,self.y-8)
 --print(self.dx,self.x,self.y-16)
 end
 
 })

end

function add_axe(_x,_y,_dx)

add (wpn,{
x=_x,
y=_y+4,
h=1,
w=1,
dx=_dx,
dy=-2.3,
sp=42,
flpx=false,
flpy=false,
tm0=0,
tm1=0,
frm=1,


update=function(self)
self.y+=self.dy
self.dy+=grav
self.x+=self.dx
self.tm0+=.01
self.tm1+=.3*self.dx



if self.tm0>=.15 then
self.tm0=0

end

if self.tm0==.02 then

 sfx(46,3)

end
if self.tm1>=1 then

self.tm1=0
self.frm+=1
elseif self.tm1<=0 then
self.tm1=1
self.frm-=1
end

if self.frm>=5 then

self.frm=1
elseif self.frm<1 then
self.frm=4

end
---[[
  
if self.frm==1 then self.flpx=false self.flpy=false
elseif self.frm==2 then self.flpx=false self.flpy=true
elseif self.frm==3 then self.flpx=true self.flpy=true
elseif self.frm==4 then self.flpx=true self.flpy=false

end
--]]



if (self.x<camx-20 or self.x>camx+140) or self.y>140 then

wpncnt-=1

del (wpn,self)

end
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y,1,1,self.flpx,self.flpy)
 --print(self.tm0,self.x,self.y-8)
 --print(self.frm,self.x,self.y-16)
 end
 
 })

end


--]]
-->8
--effects

function add_hand()

add (eft,{
---[[
--x=_,
y=_y,
ox=ply.ox,
oy=ply.oy,
flp=ply.flp,
sp=36,
tm0=0,


--]]
update=function(self)
--self.tm0+=.2
self.x=ply.x+self.ox
self.y=ply.y+self.oy
 
--correct facing 
 if self.flp then self.ox=-1.5
 elseif not self.flp then self.ox=4
 
 end
 
 

 ---[[
 if hndout>=1 then
 
 del(eft,self)
 
 end
 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x+self.ox,self.y,.4,1,self.flp)
--print(self.tm0,self.x,self.y)
 end
 
 })

end

function add_brn(_x,_y)

add (wpn,{
---[[
x=_x,
y=_y-6,
w=2,
h=2,
tm0=0,
tm1=0,
sp=58,

--]]
update=function(self)
 self.tm0+=.05
 self.tm1+=.1
 
 if self.sp>62 then 
 self.sp=58
 
 end
 
 if self.tm0>=.25 then
 self.sp+=1
 self.tm0=0
 
 end
 
 if self.tm1>=12 then
 wpncnt-=1
 
 del(wpn,self)
 
 end


 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y+10)
--print(self.tm0,self.x,self.y-8,7)
--print(self.tm1,self.x,self.y-16,7)
 end
 
 })

end

function add_spk(_x,_y)

add (eft,{
---[[
x=_x,
y=_y,
tm0=0,
sp=64,

--]]
update=function(self)
 self.tm0+=.5
 
 
 
 if self.tm0>=6 then
 
 del(eft,self)
 
 end


 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y)
--print(self.tm0,self.x,self.y-8,7)
--print(self.tm1,self.x,self.y-16,7)
 end
 
 })

end
function add_flr(_x,_y,_item)

add (eft,{
---[[
x=_x,
y=_y,
itm=_item,
tm0=0,
tm1=0,
sp=59,

--]]
update=function(self)
 self.tm0+=.05
 
 
 if self.tm0>=.25 then
 self.sp-=1
 self.tm0=0
 
 end
 
 if self.sp<58 then 
 self.sp=58
 add_pup(self.x,self.y-8,self.itm)
 
 del(eft,self)
 
 end


 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y)
--print(self.tm0,self.x,self.y-8,7)
--print(self.tm1,self.x,self.y-16,7)
 end
 
 })

end






-->8
--items

function add_pup(_x,_y,_item)
add (itm,{
x=_x,
y=_y,
w=1,
h=8,
dx=0,
dy=0,
sp=_item,
tm0=0,
tm1=0,


--]]
update=function(self)
 --self.tm0+=.5
 self.x+=self.dx
 self.y+=self.dy
 --self.dy+=grav
 
 if self.sp==12 then 
 self.dy=.2
 self.tm0+=.02
 else self.dy+=grav
-- self.tm0=0
 end
 if self.tm0>=2 then 
 self.tm0=0
 
 
 end
 
  if collide_map(self,"down",0) 
then
self.dx=0
self.dy=0 
self.tm0=0
self.tm1+=.01
--self.y-=(self.y+self.h)%2
 end
 if self.dy~=0 then
 if self.sp==12 then
 if self.tm0<1  then self.dx+=.04
 elseif self.tm0>1 then self.dx-=.04
 end
 end
 end
 if self.dx>=.4 then self.dx=.4
 elseif self.dx<=-.4 then self.dx=-.4

 end
 

 

if hit(self.x+4,self.y,ply.x,ply.y-9,ply.h+3,ply.w)
and not (ply.hrt or ply.ded) 
then 
del(itm,self)
if self.sp<=13 then  sfx(54)
elseif self.sp==44 then sfx(59,0,0,4)
elseif self.sp==45 then sfx(62)

else sfx(57)
end

if (self.sp==12) ply.ammo+=.5
if (self.sp==13) ply.ammo+=2.5
if (self.sp==39) ply.wpn=1
if (self.sp==40) ply.wpn=2
if (self.sp==41) ply.wpn=3
if (self.sp==42) ply.wpn=4
if (self.sp==43) ply.wpn=5
if (self.sp==24) ply.whp+=.5 pup=true
if (self.sp==44) ply.pot=true ply.blk=true
if (self.sp==45) flash=true 




end
if tran or self.tm1>2 and self.sp~=45 then
del(itm,self)

end

 
end,
draw=function(self)

 spr(self.sp,self.x,self.y+6)
 --print(self.tm0,self.x,self.y-8)
 --print(self.dx,self.x,self.y-16)
 end
 
 })

end

-->8
--candles and enemies
function add_cdl(_x,_y,_item)
add (act,{
---[[
x=_x,
y=_y,
h=1,
w=1,
itm=_item,
life=1,
flp=false,
sp=1,
tm=0,
tm2=1,
harm=false,

--]]
update=function(self)
self.tm+=.15
---[[
 if self.tm>=2 then self.tm=0
 
 end

if not clock then
 if self.tm<=1 then self.flp=false
 else self.flp=true 
 
 end
 end
 
 --]]
 

 ---[[
 if self.life<=.5  then
 add_flr(self.x,self.y-2,self.itm)
-- add_spk(self.x,self.y)
 del(act,self)
 
 end
 --]]
 
 
end,
draw=function(self)

 spr(self.sp,self.x,self.y,1,1,self.flp)
-- print(self.life,self.x,self.y)
 end
 
 })

end

function add_fir(_x,_y,_flp)

add (act,{
x=_x,
y=_y,
h=1,
w=.5,
sp=80,
dx=1,
flp=_flp,
life=1,
harm=true,
tm2=0,

--]]
update=function(self)
self.x+=self.dx
self.tm2+=.1
if clock then self.dx=0
end
if not clock then
if self.flp then self.dx=-1
else self.dx=1
end
end

if self.tm2>=1 then self.tm2=1
 
 end
if flash then self.life-=100

end
if self.x<camx-20 or self.x>camx+140 or self.life<=0 then



del(act,self)

end

end,

draw=function(self)

 spr(self.sp,self.x,self.y,1,1,self.flp)
 --print(self.tm0,self.x,self.y-8)
 --print(self.frm,self.x,self.y-16)
 end
 
 })

end


function add_emy(_x,_y,_item)
add (act,{
---[[
x=_x,
y=_y,
h=3,
w=1,
itm=_item,
life=11,
flp=false,
sp=143,
tm0=0,
tm1=0,
tm2=0,
p0=4,
p1=14,
sht=0,
harm=true,
active=false,
--]]
update=function(self)
if clock==true or self.tm2<=.5 then
self.tm0+=0
else self.tm0+=.1
end

self.tm2+=.1
pal(11,self.p0)
pal(2,self.p1)
if self.active then
 if self.tm0>=25 and self.sht~=1 then self.tm1+=.3 
 
 
 end
 if self.tm1>=.5 then 
 self.p0=9
 self.p1=8
 elseif self.tm1<=.5 then
 self.p0=4
 self.p1=14
 
 
 end

 if self.tm0>=30  then 
 add_fir(self.x-1,self.y+1,self.flp)
 self.sht+=1
 if self.sht<=1 then
 self.tm0=25 
 self.tm1=0
 
 end
 if self.sht>=2 then
 self.sht=0
 self.tm0=0 
 self.tm1=0
 
 end
 end

 if self.tm1>1  then self.tm1=0
 
 end
 
 if self.tm2>=1 then self.tm2=1
 
 end
 
 if ply.x<self.x+2 then self.flp=true
 else self.flp=false
 end
 end
 if flash and self.active then self.life-=100
 
 end
if self.x>=ply.x-65 and self.x<=ply.x+65 then
self.active=true
else self.active=false

end
 if self.life<=.5  then
 add_flr(self.x,self.y-2,self.itm)

 del(act,self)
 
 end

 
 
end
,
draw=function(self)

 spr(self.sp,self.x-1,self.y,self.w,self.h-1,self.flp)
--print(self.tm0,self.x,self.y-8)
--print(self.tm1,self.x,self.y-16)
--print(self.tm2,self.x,self.y-24)
-- print(self.sht,self.x,self.y-16)
 
 end
 
 
 
 })

end


__gfx__
000000000080000000023320000023320000233222332000023332000033332000223223000000700c1111c0002332000008070007700870008008000e8888e0
0000000000a0080002233a30000233a3000233a3e3aa30002333a40002233a2022bb333300000067c1cccc1c222aa2220088887088878887000aa000e8eeee8e
00700700009089802b33ee2000233ee2002b3ee2ebee2200ebbee2002b3bbbb2bbbbbb3300000670c999999cbb3333bb000888008888888800088800aaaaaaaa
00077000008008002bb3bbb202bb3b2002bbb3b2e7bbbb202eebbb207ebbbeee2bb77ba3009944901c95c9c1ebb33bb700008000088888800084a880ea1aa1a8
00077000007007002ebbbe2e02bebb2002ebbbb2ee3b7b200255bb20e2bbb3b2233eeb22099999401c9c59c1eebbbbe70000000000888800048a4888ea1aa1a8
007007000888888002bb3eee023e3b2002e3bb202333b20002333b20e2b33320023e3b2064999946c999999ce23bb3e200000000000880004884a884aaaaaaaa
000000000040040002333222023eee0002eee20002333200002333202e333200023eee2079999467c1cccc1ce23333e20000000000000000448a8840e8eeee8e
000000000002200002b5b20002b5b200025bb200025bb200002b5b2002b5b20002b5b200066666600c1111c02ebbb5e20000000000000000044444000e8888e0
0000000000000000023b3320023b320002b33320023b33eb023b33eb2233b3200000004200000000000000002e3333b2007c7000770000770000077008880005
000000000000000002eb3e20002be20002be3ee202ee223b02eb22bb3bbebe7200000427000002200000000002e2ee2b007c70007c7007c777007c7008008050
000000000000000002ee2ee2002eeb0002ee2ee223eb23b202ee2332b2be2ee200676760000002b2000020002ee2ee22007c777707c77c707c77c70008880500
00000000007240000eeb2eb20025eb000eb202eb3bb023322eeb23bbb22b02eb070220000000002b2022b2002ee22e20777cdccc007cd70007cdc700080050ee
000000000706200023b22bb20023b20003b2023bb22002bb23b22000000002bb6042000000000223527eb2002b202b20cccdc777007dc700007cdc7008050e00
0000000006cc60003b2003b20023b2003b2002b2000000003b200000000023b20727d7002b2227e3b7ebb3202b202b207777c70007c77c70007c77c70050eee0
00000000006cd000332023320233320033202332000000003320000000002332425d5d00b3bb7be3be3bea322b22bb200007c7007c7007c707c70077050e0000
00000000000d00003bb223bb0023bb200bb003bb000000002bb20000000002bb2007d700b2beb3bbbeebea33bb22bb200007c700770000770770000050eeee00
00000011000000000000000000600011000000000000161000000000000000000004400000000770007770000000000000090000000000000000000000000000
000001ff0000000000000611675751ff000000000000161000000000001000000007700077007c7007cc0560000aa6d0009a9000000000000000000080000000
0000161100000000000061ff7506001111011111111161000000000011611111007777007c77c70007ccd650c00cc00600444700007000006600000080000000
00016100000000000000561156000000ff1666666666100000000000446777770055550007cdc70007007d07c1c16c0d009a907007c700005000000000000000
001610000000000000067000700000001101111111110000000000001161111107000070007cdc7000060cc76d6166c600aa70a07ccc70000000000000000000
00161000000000000000560056000000000000000000000000000000001000007c7cccc7007c77c700700cc76d6611cd09aaa70007c765600000000000000000
00161000000000000006700075000000000000000000000000000000000000007ccc7cc707c7007706007770c1c66c0609aaa70007c700055000000000000000
0016100000000000000056006700000000000000000000000000000000000000077777700770000060000000c00cc00d00999000007065606600000000000000
00161000000111100000007665600000000000000000000000000000000000000000000000000c00000000000000000000000000000000009000800800000000
00166100011666f10000006507600700000000000000070000000000000000000000070000007c00000000000000800000800080a080008a9908a08800000000
000161001661111f000006700650565011006060606056501100606060606060606056500cc07c00000000000008800008880888a8a808aaa90aa08a00000000
00001610611100010070056000076567ff15757575776567ff15757575757575757765677cc00000000080000088880088888888aaaa8aaaaaaaaaaa00000000
00001610610000000565500000005650110606060606565011060606060606060606565007000000000880000888888088899888aaaaaaaa8aa99aa900000000
000016101610001076567000000007000000000000000700000000000000000000000700000cc0000088880008899880889aa988a9aaaa9a8a9aa9a9e0000000
1111161001610161056500000000000000000000000000000000000000000000000000000007cc0000899800088aa88008aaaa80099aa9908aaaaaa9e0000000
66666610001666100070000000000000000000000000000000000000000000000000000000077c000008800000888800088888800098890008aaaa8000000000
00080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08eee888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88eee800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000898000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00808998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa44a400aaaaaa088888d10010588880aa44a400aa44a4000000000024114200555555555555550000000000000000000000011000c00001100000002bb0000
a9999944a9999994ad145001100541daa9999944a99999440000000002411420001111111111110000505000000050000000033000cc9000033000002b08b2bb
a4999994a9999994a5d4505005054d5aa4944494a44449940000000002411420000555555555500060505005000000000000110000cc990000110000bbbb0202
41499994a9999994455d101001014554419994944149999400000000024114200000011111100000655155500505005000003300090000c00033000000002020
49999444a999999445558888888855544999944449499444000000000241142000000d5d5d5000000100111000000000000033000990ccc0003300000b200000
a9999944a9999994a5555d1441d5555aa9999944a9999944000000000222122000000d5d5d500000dd1dd55505555550000011000990cc00001100000bbbb000
a9999994a9999994a55555d44d55555aa9999994a9999994000000000042540000000d5d5d500000d61d555515551050000033000000c0cc003300000000bb20
04444440044444400444445dd54444400444444004444440000000000042540000000d5d5d500000d60d50550515105000001100cccc0ccc0011000002bb0000
010588888888501000000000000000000000000000000000000000000042540000000d5d5d500000010001111000000000001100ccc00ccc001100000000bb20
100541d55d14500100000000000000000000000000000000000000000042540000000d5d5d500000ddd0dd555505555000003300cc0990c000330000bb2b80b2
05054d5005d4505010000000000000010000111111111100001111110042540000000d5d5d500000d661d65555011050000033000099090c003300002020bbbb
0101d500005d101001000000000000100000050505050510015050500042540000000d5d5d500000d661d6515505105000001100c090f0cc0011000002020000
888800000000888850100000000001050000050505050510015050500042540000000d5d5d500000110001110111000000003300090ff0cc00330000000002b0
41d5000000005d1450010000000010050000050505050500005050500042540000000d5d5d500000dd1dd5550555555000003300c0f00f0c00330000000bbbb0
4d500000000005d450501000000105050000050505050500005050500042540000000d5d5d500000d61d555515551050000033000909000c0033000002bb0000
d50000000000005d10100100001001010000010101010100001010100042540000000d5d5d500000d60d51550515105000001100c0090ff0001100000000bb20
000000000000000000000000000000000000000000000000000000000042540000000d5d5d500000000000000000000000003300cc0f0f000033000000000000
000000000000000000000000000000000000000000000000000000000042540000000d5d5d500000000000000000000000001100c0990f0c0011000000000000
000000000000000000000000000000001111000011111100001111110042540000000d5d5d50000000000000000000000000331309f0f0cc3133000000000000
000000000000000000000000000000005050000005050510015050500a4244a000000d5d5d500000000000000000000000003313c00f00cc3133000000000000
000000000000000000000000000000005050000005050510015050500a42a4a000000d5d5d500000000000000000000000000000c0f090000000000000313300
000000000000000000000000000000005050000005050500005050500a4244a000000d5d5d500000000000000000000000000000c0f0f0cc0000000001100110
000000000000000000000000000000005050000005050500005050500042540000000d5d5d5000000000000000000000000000000f09f0cc0000000033000033
000000000000000000000000000000001010000001010100001010100042540000000d5d5d500000000000000000000000000000c0c00ccc0000000010000001
266666622662000006666660333300006d60d0d0d5d05050000000000042540000000d5d5d50000000000000000000000000000000ccc0001110133000000000
6eeeeeee6e8e00006333333663360000d0d0d6d050505d50000000000042540000000d5d5d500000000000000000000000000000cc0ccccc1110111033103110
68868282e88200006333331616610000d6d00d005d500500000000000222522000000d5d5d500000000000000000000033133313ccc00cc00000000011101110
ee8888222220000063333336055000000d006d600500d5d0000000000241142000000d5d5d500000000000000000000033133313cccc000c0313011100000000
e88888820000266261313316000033336d60d0d0d5d050500000000002411420000001111110000000000000000000000000000000000ccc0111011103130111
6e88888200006e8e6333111600006336d0d0d6d050505d5000000000024114200005555555555000000000000000000000000000ccc0cccc0000000001110111
ee8882820000e8826111111600001661d6d00d005d50050000000000024114200011111111111100000000000000000000000000ccc000000001110000000000
2e2222200000222006666660000005500d006d600500d5d000000000024114200555555555555550000000000000000000000000ccc0cccc0001110000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000077007700000777077707770777077707770000000000000000000000000777077707770777000007770000077700000000000000000000000
000000000000007000700000007070707070707070707070700000000088888888888888000700070077707000000070707770007000000000e8888e00000000
00000000000000777070000000707070707070707070707070000000008000000000000800070007007070770000007770000077700000000e8eeee8e0000000
00000000000000007070000000707070707070707070707070000000008000000000000800070007007070700000007000777070000000000aaaaaaaa0000000
00000000000000770007700000777077707770777077707770000000008000000000000800070077707070777000007000000077700000000ea1aa1a80000000
00000000000000000000000000000000000000000000000000000000008000000000000800000000000000000000000000000000000000000ea1aa1a80000000
00000000000008880005000000000000000000000000000000000000008000000000000800000077007770777000000000000077007770000aaaaaaaa0000000
00000000000008008050006666666666666666666666666666666600008000000000000800000007000070707000080700777007007000000e8eeee8e0000000
000000000000088805000080808080808080808080808080805050000080000000000008000000070000707770008888700000070077700000e8888e00000000
000000000000080050ee008080808080808080808080808080000000008000000000000800000007000070007000088800777007000070000000000000000000
00000000000008050e0000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000008000000000000800000077700070007000008000000077707770000000000000000000
0000000000000050eee000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000008000000000000800000000000000000000000000000000000000000000000000000000
000000000000050e0000006666666666666666666666666666666600008888888888888800000000000000000000000000000000000000000000000000000000
00000000000050eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000003133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000
0000000000000000001100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a008000000000
30000000000000000330000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009089800000000
10000000000000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008000000000
01100000000000011000c00001100000000000000000000000000000000000444410000000000000099880000000000000000000000000000007007000000000
0033000000000033000cc90000330000000000000000000000000000000001144a10000000000998980988000700000000000000000000000088888800000000
0001100000000110000cc99000011000000000000000000000000000000019499991110060606868699998605650000000000000000000000004004000000000
00033000000003300090000c0003300000000000000000000000000000007f999fffff1575757585857575776567000000000000000000000000880000000000
000330000000033000990ccc000330000000000000000000000000000000f19994911106060606060689e6865650000000000000000000000000000000000000
000110000000011000990cc0000110000000000000000000000000000000f19444100000000000009999e8000700000000000000000000000000000000000000
c00330000000033000000c0cc003300000000000000000000000000000001f444100000000000089900088000000000000000000000000000000000000000000
c0011000000001100cccc0ccc0011000000000000000000000000000000001959100000000000000099808000000000000000000000000000000000000000000
c0011000000001100ccc00ccc0011000000000000000000000000000000001494410000000000089900000000000000000000000000000000000000000000000
00033000000003300cc0990c00033000000000000000000000000000000001f94f10000000000890898990000000000000000000000000000000000000000000
c00330000000033000099090c0033000000000000000000000000000111111ff1ff1000000000999908080000000000000000000000000000000000000000000
c0011000000001100c090f0cc001100000000000000000000000000100505ff91f91000000000000080800000000000000000000000000000000000000000000
c0033000000003300090ff0cc0033000000000000000000000000010505014911991000000000098000000000000000000000000000000000000000000000000
c0033000000003300c0f00f0c0033000000000000000000000000100505049100491000000000099990000000000000000000000000000000000000000000000
c00330000000033000909000c0033000000000000000000000001050505044101441000000000000099800000000000000000000000000000000000000000000
00011000000001100c0090ff00011000000000000000000000010010101049911499000000000089900000000000000000000000000000000000000000000000
00011000000001100cc0f0f00001100000000000000000000010588880aa44a400aa44a400aa44a400aa44a400aa44a400aa44a4000000000000000000000000
c0033000000003300c0990f0c003300000000000000000000100541daa9999944a9999944a9999944a9999944a9999944a999994400000000000000000000000
c003300000000330009f0f0cc00330000000000000000000105054d5aa4999994a4999994a4999994a4999994a4999994a499999400000000000000000000000
c0011000000001100c00f00cc0011000000000000000000100101455441499994414999944149999441499994414999944149999400000000000000000000000
00033000000003300c0f090000033000000000000000001058888555449999444499994444999944449999444499994444999944400000000000000000000000
c0033000000003300c0f0f0cc00330000000000000000100541d5555aa9999944a9999944a9999944a9999944a9999944a999994400000000000000000000000
c00330000000033000f09f0cc0033000000000000000105054d55555aa9999994a9999994a9999994a9999994a9999994a999999400000000000000000000000
c0011000000001100c0c00ccc001100000000000000100101d544444004444440044444400444444004444440044444400444444000000000000000000000000
0001100000000110000ccc000001100000000000001058888000000000aa44a40000000000000000000000000000000000000000000000000000000000000000
c0033000000003300cc0ccccc0033000000000000100541d500000000a9999944000000000000000000000000000000000000000000000000000000000000000
00033000000003300ccc00cc0003300000000000105054d5000000000a4999994000000000000000000000000000000000000000000000000000000000000000
c0011000000001100cccc000c00110000000000100101d5000000000041499994000000000000000000000000000000000000000000000000000000000000000
c003300000000330000000ccc0033000000000105888800000000000049999444000000000000000000000000000000000000000000000000000000000000000
c0033000000003300ccc0cccc003300000000100541d5000000000000a9999944000000000000000000000000000000000000000000000000000000000000000
00033000000003300ccc0000000330000000105054d50000000000000a9999994000000000000000000000000000000000000000000000000000000000000000
c0011000000001100ccc0cccc0011000000100101d50000000000000004444440000000000000000000000000000000000000000000000000000000000000000
0003300000000330000000000000000000105888800000000000000000aa44a40000000000000000000000000000000000000000000000000000000000000000
000110000000011000000000000000000100541d50000000000000000a9999944000000000000000000000000000000000000000000000000000000000000000
33133000000003313331333130000000105054d500000000000000000a4999994000000000000000000000000000000000000000000000000000000000000000
3313300000000331333133313000000100101d500000000000000000041499994000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000010588880000000000000000000049999444000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000100541d500000000000000000000a9999944000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000105054d5000000000000000000000a9999994000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000100101d5000000000000000000000004444440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000010588880000000000000000000000000aa44a40000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000100541d5000000000000000000000000a9999944000000000000000000000000000000000000000000000000000000000000000
000000000000000000000111105054d50000000000000000000000000a4999994000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005050101d50000000000000000000000000041499994000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005058888000000000000000000000000000049999444000000000000000000000000000000000000000000000000000000000000000
000000000000000000000050541d50000000000000000000000000000a9999944000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005054d500000000000000000000000000000a9999994000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000101d500000000000000000000000000000004444440000000000000000000000000000000000000000000000000000000000000000
00aa44a400aa44a400aa44a4088888d100aa44a400aa44a400aa44a400aa44a40000000000000000000000000000000000000000000000000000000000000000
4a9999944a9999944a9999944ad145001a9999944a9999944a9999944a9999944000000000000000000000000000000000000000000000000000000000000000
4a4999994a4999994a4999994a5d45050a4999994a4999994a4999994a4999994000000000000000000000000000000000000000000000000000000000000000
4414999944149999441499994455d101041499994414999944149999441499994000000000000000000000000000000000000000000000000000000000000000
44999944449999444499994444555888849999444499994444999944449999444000000000000000000000000000000000000000000000000000000000000000
4a9999944a9999944a9999944a5555d14a9999944a9999944a9999944a9999944000000000000000000000000000000000000000000000000000000000000000
4a9999994a9999994a9999994a55555d4a9999994a9999994a9999994a9999994000000000000000000000000000000000000000000000000000000000000000
00444444004444440044444400444445d04444440044444400444444004444440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000088885010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000005d145001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005d45050100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000005d1010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000008888501000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000005d14500100000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000005d4505010000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000005d101001000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888850100000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000005d1450010000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000005d450501000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005d10100100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000088885010000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000005d145001000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005d45050100000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000005d1010010000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008888501000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000005d14500100000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000005d4505010000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000005d101001000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000888850100000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000005d1450010000000000000000000000000000000000000000000000000000000000000000000
0000800000000000000000000000000000000000000000000008005d450501000000000000000000000000000000000000000800000000000000000000000000
0800a0000000000000000000000000000000000000000000000a0085d10100100000000000000000000000000000000000000a00800000000000000000000000
89809000000000000000000000000000000000000000000000090898088885010000000000000000000000000000000000000908980000000000000000000000
0800800000000000000000000000000000000000000000000008008005d145001000000000000000000000000000000000000800800000000000000000000000
07007000000000000000000000000000000000000000000000070070005d45050100000000000000000000000000000000000700700000000000000000000000
888888000000000000000000000000000000000000000000008888880005d1010010000000000000000000000000000000008888880000000000000000000001
04004000000000000000000000000000000000000000000000040040000008888501000000000000000000000000000000000400400000000000000000000010
00880000000000000000000000000000000000000000000000008800000005d14500100000000000000000000000000000000088000000000000000000000100
000000000000000000000000000000000000000000000000000000000000005d4505010000000000000000000000000000000000000000000000000000001050
0000000000000000000000000000000000000000000000000000000000000005d101001000000000000000000000000000000000000000000000000000010010
00000000000000000000000000000000000000000000000000000000000000000888850100000000000000000000000000000000000000000000000000105888
000000000000000000000000000000000000000000000000000000000000000005d145001000000000000000000000000000000000000000000000000100541d
0000000000000000000000000000000000000000000000000000000000000000005d4505011111100000000000000000000000000000000000011111105054d5
00000000000000000000000000000000000000000000000000000000000000000005d10100505051000000000000000000000000000000000015050500101d50
00000000000000000000000000000000000000000000000000000000000000000000088880505051000000000000000000000000000000000015050508888000
0000000000000000000000000000000000000000000000000000000000000000000005d1405050500000000000000000000000000000000000050505041d5000
00000000000000000000000000000000000000000000000000000000000000000000005d40505050000000000000000000000000000000000005050504d50000
000000000000000000000000000000000000000000000000000000000000000000000005d010101000000000000000000000000000000000000101010d500000
00aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a400aa44a4
4a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a999994
4a4999994a4999994a4999994a4999994a4999994a4999994a4999994a4999994a4444994a4999994a4999994a4444994a4999994a4999994a4999994a494449
44149999441499994414999944149999441499994414999944149999441499994414999944149999441499994414999944149999441499994414999944199949
44999944449999444499994444999944449999444499994444999944449999444494994444999944449999444494994444999944449999444499994444999944
4a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a9999944a999994
4a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a9999994a999999
00444444004444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444004444440044444400444444

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100050b05030001000000000000000000000000e080c0010000000000000000000000009090a00100000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000
0000af0000af00bebe00be9a9b0000000000af0000af00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000939500009395000000009395800000000000000000000000
808c8d8e8c8d8ebebe00009a9b000000008c8d8e8c8d8e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000093838080808380808080808380800000000000000000000000
809c9d9e9c9d9ebcbcbcbc9a9b000000009c9d9e9c9d9e000093950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009390800093900080000093900080800000000000000000000000
809cad9e9cad9e000000009a9b000000009cad9e9cad9e009383808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000939000809490000080009390000080800000000000000000000000
809cbd9e9cbd9e939500009a9b00a692009cbd9e9cbd9e939000800000000000000000000000000000000093950000000000009395000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000939596908080808082808080969000000080800000000000000000000000
80acbcaeacbc9383808080808080808292acbcaeacbc93900000800000000000000000000000000000009383808080800000808380808080000000000000000000000000000000000000000000000000000000000000000000000000000000000093838080848000000000919200808400000080800000000000000000000000
80000000009390800000008a8b00000091a400000094900000008000000000000000000000000000009390000000000000939000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000093908000000080000000000091a4808080000080800000000000000000000000
80000000969000800000009a9b00009383808080808082808080800000000000000000000000939594900000000000009390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000939000800000008080808080808380808080808080800000000000000000000000
80808080808480800000009a9b009390808a8b00000000919200000000000000000000000093838080829200000000939000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000093900080800000000000000093900000008889888980800000000000000000000000
87888988898889000000be8a8b93908b809a9b00000000009192000000000000000000009390000000009192000093900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009690008080800000000000009390000000009899989987000000000000000000000000
97989998999899000000bebe939000b5009a9b00000000000091920000000000000000939000000000000091a59690000000000000000000008080808000008080800000808000008080800000808080800000008080000080808080808084808080800000000000949000000000009899989997000000000000000000000000
a7a8a9a8a9a8a90000000093900000b5009a9b0000000000000091920000000000009390000000000000008580808400000000000000000000008a8b0000008a8b0000008a8b00008a8b000000008a8b000000008a8b000000008a8b00000000000000000000008080829200000000a8a9a8a9a7000000000000000000000000
b7b8b9b8b9b8b90000009690bebe00b5009a9b000000000000000091a500000000969000000000000000000000000000000000000000000000009a9b0000009a9b0000009a9b00009a9b000000009a9b000000009a9b000000009a9b000000000000000000000080808091a5000000b8b9b8b9b7000000000000000000000000
808080808080808080808084808080808080808080808080808080858080858080808400000000000000000000000000000000000000000000008a8b0000008a8b0000008a8b00008a8b000000008a8b000000008a8b000000008a8b000000000000000080808080808085808080808080808080808080000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9b0000009a9b0000009a9b00009a9b000000009a9b000000009a9b000000009a9b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8b0000008a8b0000008a8b00008a8b000000008a8b000000008a8b000000008a8b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9b0000009a9b0000009a9b00009a9b000000009a9b000000009a9b000000009a9b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8b0000008a8b0000008a8b00008a8b000000008a8b000000008a8b000000008a8b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9b0000009a9b0000009a9b00009a9b000000009a9b000000009a9b000000009a9b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8b0000008a8b0000008a8b00008a8b000000008a8b000000008a8b000000008a8b000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a9b0000009a9b0000009a9b00009a9b000000009a9b000000009a9b000000009a9b000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
091800000c255102551327511255132751125515275172752b3302b3302b33528330283302833524330243302433024335000002333024330293302d3302f3303631036322363423531035322353323534235372
01051000340762607624056230460c53110521235712d5713b57100100000002300024000290002d0002e00035000350003500034000340003400034000340000000000000000000000000000000000000000000
250b0800397703f7703f7203f71035700357003f7003f7003c7003f7003f7003f7003c7003f7003f7003c7003c7003f7003f7003c7003c7003f7003f7003f7003f700007003c700007003f700007000070000700
07180000003450234506345023450634502345073750b37500345023450434505345083450b3450c3450e34500345023450434505345083450b3450c345103450633006340063500532005330053400535005350
310a0000183312333118443263413435118463243613e3710c47302300003000c45305300003000c4330b3000c3000c4133f300003003f300003003f300003000030000300003000030000300003000030000300
0105000028434373542b434393542f4343b3542b4343e3542f4343e3542b43434354294343e354304343e3540000026300240002f300293000030023300003001a300003001f3000030028300003000030000300
1b1800003f6353f6353f6353f6353f6353f6353c6753c6753f6353f6353c6753f6353f6353f6353c6753f6353f6353f6353c6753c6753f6353c6753c6753c6750000300000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
390f0c002835527355233552635525355213552435523350233502335023350233500030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0d100000170451704523345003002334500300263452a3402a3452300023000230002334500300263452b3402b3452b3002b3452a345293452a345000002b3452b3002b345223402234523300233002334023345
11100000273202732529300273252630029325283002732526325263252400026325263002732524000263252432526325273252632527325293252b3202b3202b3202b3202b3202b3202b3002b3002b30024000
15100000243202432500000243250000026325000002432522320223250000022325000002432500000223251f325223252432522325243252632527320273202732027320273202732000000000000000000000
0d100000002450c245002450c245002450c245002450c2450a245162450a245162450a245162450a245162451425514245002001625516245000000c2500c2500c2500c2500c2500c25500200002000000000000
251000001d3003c6001e3453f6001e3450000023345263453f6003c6001d300000001e345000002334526345273000000027345263452534526345000002634500000263451e3453f6003c600000001e34500000
0d0e000026535265350050024535005002353023530235202352500000000001a535005001c5351d5351f5352153021525005001a5301a5350050021535005001f53524540245302453024530245202451500000
0d0e000026735267350000024535005002353023530235202352500000000001a535005001c5351d5351f5352153021525005001a5301a5250050021535005001f53518540185301853018530185201851500000
0d0e200000000000002673526500005002d73500500005002c7352d5352c535297550050000500005000050000000297352634500300003001d7351a345003000030029735263452973526345297352634529735
0d0e00002553025520255152853028520285152e5402e5352d5202d5302d53529540295302952526530265252553025530255252854028530285252e5402e5352d5202d5302d5352653026535005000000000000
0d0e00002553025520255152853028520285152e5402e5352d5202d5302d53529550295302953526550265352853028520285152b5302b5202b5252e5402e5352d5502d5302d5352f5502f5302f5353155031535
0d0e1e003253532535265352653026530265302653026530265302652026515005000000000000223350030022335003002633529550295350030024335003002433500300283352b5502b535003000030000000
0d0e1e003253532535265352653026530265302653026530265302652026515005000000000000223350030022335003002633529550295250030024335003002430000300155351856018555003000030000000
0d0e00002133521335003001f335003001f3301f3201f3201f31500000000001a335003001a33518335183351a3201a3201a3151632016315003001a3201a315183351f3301f3201f3201f3201f3201f31500000
0d0e000000000000002132500300003002632500300003002532526325253252432500300003000030000300000002d725003002d3252c725003002c3252b725003002d725003002d3252c725003002c3252b725
0d0e000022330223202231525330253202531528330283152633026320263152133021320213151d3301d31522330223202231525330253202531528330283152633026320263152133500300003000030000000
0d0e000022330223202231525330253202531528330283152633026320263152133021320213151d3301d31522330223202231525330253202531528330283152533025320253152833028320283152b3302b315
0d0e00002d3352d3352133521330213302133021330213302133021320213150030000300000001d335003001d33500300223352632026315003001f335003001f33500300243352832028315003000030000000
0d0e00002d3352d3352133521330213302133021330213302133021320213150030000300000001d335003001d33500300223352632026315003001f335005001f50000500245002850028500005000000000000
0d0e00000e245002000e2450e2450e2450c200002000c2000e245002000e2450e2450e2450e2450e2450e2450a245072000a2450a24516245002000b200002000c2450c245182450c2450c2450c2450c2450c245
0d100000172001720017255000000c20017255172550e200172550e20017255000000e20017255172550e200172550a200122550a200122551620012255122550c200000000a2550a25500000000000b2550b255
0d0e00000e245002000e2450e2450e2450c200002000c2000e245002000e2450e2450e2450e2450e2450e2450a245072000a2450a245162450a2450b2000a245162000a2451624518200162450c2001624500200
0d0e00000c2400c2400c2400c2400c2400c2450c200002000e2400e2400e2400e2400e2400e2450c200002001024010240102401024010240102450c200002000e2400e2400e2400e2400e2400e2450020000200
0d0e00000c2400c2400c2400c2400c2400c2450c200002000e2400e2400e2400e2400e2400e2450c200002001024010240102401024010240102450c200002001524015240152401524015240152450020000200
0d0e00000e245002000e24500200002000e2450c245002000e2450e200002000020000200002000a245002000a24500200002000e2000e200002000c2450c2000c24500200002000020000200002000020000200
0d0e00000e245002000e24500200002000e2450c245002000e2450e200002000020000200002000a245002000a24500200002000e2000e200002000c2450c2000c24500200092450c2500c255002000020000200
030e00003f625000003f6253f6253c65500000000003f6003f625000003f6253f6253c6553f6253f625000003f625000003f6253f6253c6550000000000000003f6253f6253c655000003c6553c6553c65500000
030e00003f625000003f6253f6253c65500000000003f6003f625000003f6253f6253c6553f6253f625000003f625000003f6253f6253c6550000000000000003f6253f6253c655000003c655000003c65500000
030e00003f625000003f6253f6253f6253f6253c655000003f625000003f6253f6253f6253f6253c655000003f625000003f6253f6253f6253f6253c655000003f625000003f6253f6253f6253f6253c6553c655
030e00003f625000003f6253f6253f6253f6253c655000003f625000003f6253f6253f6253f6253c655000003f625000003f6253f6253f6253f6253c655000003f665000003c6553f665000003c6553f66500000
030e00003c655000003c655000003f6253c655000003c655000003f6453f6453f6453f6453f6453f645000003c655000003c655000003c6553c65500000000003c655000003c655000003c6553c6550000000000
450e0000243452b345273452b345243452b345273452b345263452b345293452b345263452b345293452b345243452b345273452b345243452b345273452b345243452b345273452b345243452b345273452b345
450e0000243452c345293452c345243452c345293452c345243452b345273452b345243452b345273452b345263452b345293452b345263452b345293452b345243452b345293452b345243452b345293452b345
010e00002b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b3152b3102b3102b3102b315
030e00003f625000000000000000000000000000000000003c675000000000000000000000000000000000003f625000000000000000000000000000000000003c67500000000000000000000000000000000000
150e00000c2300c2300c2300c2300c2300c2300c2300c2300b2300b2300b2300b2300b2300b2300b2300b2300c2300c2300c2300c2300c2300c2300c2300c2300f2300f2300f2300f2300f2300f2300f2300f230
450e0000112301123011230112301123011230112301123013230132301323013230132301323013230132300b2300b2300b2300b2300b2300b2300b2300b2300c2300c2300c2300c2300c2300c2300c2300c230
050200002867028640286253067030630306253664036640366453f6153f6153f6153f6153f6133f6133f6133f6003c600000003c6003c6003c6003c6003c6003c6003f6003f6003f6003f600000000000000000
020200003e6153e6353e6553e673300003e6353e6453e663000003f6153f6253f643306003f6003b6003b60028600286002860030600306003060036600366003660000700007000070000700007000070000700
1f0508003c6730c673306703b6703c6503e6503f6503f6003f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c173181711a0000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
030200003f6303f6303f6733566134651326213061500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070700003f6703f6703f3603f3453f645305753f575186732467326673306731d6732d6732f6730c6731c673246732667310673306732b6732d6731767318673246730f673306731867326673306732667330653
01030000246102f6202463324664306303c610186100b6103f6003f6003760029600246000c600006003f6003f6003f6003760029600246000c600006003f6003f6003f6003760029600246000c6000060000000
3708000024673000003c6703c6403c6453c60000000000003f6303f6303f6303f63500000000000000000000246702461530600000003f6743e6603c6503c6303b6103a610396103761036610000000000000000
070f0000003450034500345003450034500345003450034500345003450430004300363053f300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
250300003f0503b0553905037013370503601333050300133304035011007003a0363b0163c0263f0113f01100700007000070000700007000070000700007000000000000000000000000000000000000000000
010400003f6343f3503f3303f310000003f3303f3103f31030300303003f3003f3003c3003f3003f3003f3003f3003f3003f30000000000000000000000000000000000000000000000000000000000000000000
310c1800283552a375283002a31500000000000000000000283552a375283002a31500000000000000000000283552a375283002a315000000000000000000000000000000000000000000000000000000000000
21060000343603f3511a354283512b351343513f351233542b341373411a3442d341133341833126331210002d300003001830018300003002f3002f300293002130021300233002330000300003000030000300
000100001867018630186201861034600000000000034677346503463034620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
251e00002d2542d2722d2222d2152b2542b2722b2222b215002000020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00003b7753b7753b7753b77500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
610500000c3730c37300000286740c4731c6750c4730b6750c4730b6750c473056750c47300675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0500003c0733e1713c0733e1713c0333e1213c0133e1110000000000392003e370303710000028343283431f3003e35030351000002834328343183003e33030331000002832328323000003e3103031100000
01040000024510e4413e46102451306310e6233e6130e6233e6130030000300003000030000300003000030000300003000030000300003000030000300003000000000000000000000000000000000000000000
__music__
05 00030644
00 41447b44
04 42454344
05 0a0b0c6d
05 090d1c44
01 0e151b22
00 0f151b22
00 10161d23
00 10161d23
00 11171e24
00 12181f25
00 13192026
02 141a2126
01 27292a2b
02 28292a2c
00 08483544

