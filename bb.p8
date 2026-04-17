pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
-- pico bobble 0.8
-- 2020 paul hammond

cartdata("phammond_bb_1p8")

playercount=1
startlevel=1
hiscore=dget(0)
maxstartlevel=max(dget(1),1)

gravity=0.7

d_none=0
d_up=1
d_down=3
d_left=4
d_right=2

xinc={[0]=0,0,1,0,-1}
yinc={[0]=0,-1,0,1,0}
dirrev={d_down,d_left,d_up,d_right}

s_gamestart=-2
s_levelstart=-1
s_levelcomplete=-3
s_playing=0
s_gameover=9
s_complete=10

ps_normal=0
ps_dying=1

bt_normal=11
bt_lightning=13
bt_fire=14
bt_water=15
bt_letter=132

e_normal=0
e_trapped=1
e_spin=2

et_zen=1
et_banebou=2
et_mighta=3
et_hidegon=4
et_pulpul=5
et_monsta=6
et_invader=7
et_drunk=8
et_super=9
et_baron=10

titletext="paul hammond 2020 ♥ testing by finn ♥ low-res gfx thanks to dwedit.org & @justin_cyr ♥ q to quit mid-game"

mi=1
mode=1
modes={"normal","harder","hardest"}

function _init()
 poke(24365,1)
 c_falls=0
 c_runs=0
 c_jumps=0
 c_pops=0
 c_popswater=0
 c_specials=0
 reset()
end

function reset()
 titlex=0
 g_state=0 
 sfx(-1)
 music(35)
 t_fadein()
end

function _update60()
 if g_state==0 then
  titles_update()
 else
  game_update()
  
  if gameover then
   if (max(p1.score,p2.score)>hiscore) hiscore=max(p1.score,p2.score)
   dset(0,hiscore)
   maxstartlevel=max(maxstartlevel,level)
   dset(1,maxstartlevel)
   reset()
  end
 end

 t_update()
 if (kb("q")) gameover=true
end

function titles_update()
 titlex+=0.5
 titlex=titlex%675
 
 local inc=0
 if (btnp(0)) inc=-1
 if (btnp(1)) inc=1
 if (btnp(2)) mi-=1
 if (btnp(3)) mi+=1
 
 mi=mid(1,mi,3)
 if mi==1 then
  playercount=mid(1,playercount+inc,2)
 elseif mi==2 then
  startlevel=max(1,flr(min(startlevel+5*inc,maxstartlevel)/5)*5)
 else
  mode=mid(1,mode+inc,#modes) 
 end
 
 if btnp(5) then
  g_state=1
  game_reset()
 end
end

function _draw()
 cls(0)
 
 if g_state==0 then
  stars()
  
  map(0,26,27,12,9,6)
  pc("high "..hiscore.."0",2,7)
  for i=1,3 do
   local s,c,ox="",12,0
   
   if i==1 then
    s="players: "..playercount
   elseif i==2 then
    s="level: "..startlevel
   else
    s="mode: "..modes[mode]
   end
   
   if (i==mi) s,ox,c="⬅️ "..s.." ➡️",-4,8
   pc(s,56+i*10,c,ox)
  end
  
  if (time()%1<0.5) pc("❎ start",102,7,-2)
  ps(titletext,128-titlex,121,7)
 else
  game_draw()
 end

 t_draw()
end
-->8
-- game
function game_reset()
 --music(-1) 

 gameover=false
 level=startlevel-1
 
 p1=player_new(1)
 p2=player_new(2)
 gplayers={p1,p2}
 
 -- state
 game_resetlevel(true)
 game_setstate(s_gamestart) 
 
 glettercount=0
 gskip=0
 
 t_fadein()
 
 music(2) 
end

function game_resetlevel(newgame)
 local ol=level
 level+=1
 
 sfx(-1)

 gbubbles={}
 genemies={}
 gitems={}
 gparticles={} 
 
 -- state
 game_setstate(s_levelstart) 
 
 -- map
 gmap=map_init(level,false)
 gtiles=gmap.tiles
 
 -- players
 for p in all(gplayers) do
  if newgame then
   player_reset(p,true)
  else
   player_reset_newlevel(p)
  end
 end

 gtime=0
 gbubblesspawned=0
 gwaterlevel=999
 golarge=false

 -- reset map scroller
 ms_reset(ol,level,2,level==startlevel)

 -- apply counters for special items
 gspecials={9+flr(rnd(15))} 
 local sp=nil
 if level%100==0 then
  -- lightning potion
  gspecials={29}
 elseif c_jumps>=50 then
  -- fast firing
  sp=25 
  c_jumps=0
 elseif c_pops>=50 then
  -- long firing
  sp=24
  c_pops=0
 elseif c_runs>=1500 then
  -- fast shoes
  sp=28
  c_runs=0
 elseif c_specials>=9 then
  -- lightning potion
  sp=29
  c_specials=0
 elseif c_popswater>=10 then
  -- umbrella
  sp=26
  c_popswater=0
 elseif c_falls>=16 then
  -- water cross
  sp=27
  c_falls=0
 end
 if (sp) add(gspecials,sp)
 
 -- message
 message="round "..level 
end

function game_setstate(s,c)
 gs=s
 gstatecount=c or 0
end

function game_update()
 local ec=0 

 for p in all(gparticles) do
  p.ttl-=1
  p.r-=0.09
  p.x+=p.dx
  p.y+=p.dy
  if (p.ttl==0 or p.r<0.5) del(gparticles,p)
 end

 bubbles_update()

 for i in all(gitems) do
  item_update(i)
  if (not i.active) del(gitems,i)
 end
 
 if gs!=s_levelstart and gs!=s_gamestart then
  for e in all(genemies) do
   enemy_update(e)
   if (e.active and e.type!=et_baron) ec+=1
  end
 end
 
 if gs==s_gamestart then
  -- ############
  -- # game start
  -- ############
  if (gstatecount==400) game_setstate(s_levelstart)
 elseif gs==s_levelstart then
  -- #############
  -- # level start
  -- #############
  if gstatecount==100 then
   message=""
   game_setstate(s_playing)
   
   if gskip>0 then
    gskip-=1
    game_resetlevel()
   end
  end
  
  ms_update()
 elseif gs==s_playing then
  -- #########
  -- # playing
  -- #########
  -- spawn bubble?
  if (#gspawns>0 and gstatecount%(120)==1) bubble_spawn()
  
  -- spawn special item?
  if #gspecials>0 and (gstatecount==120 or gstatecount%960==0) then
   item_collectible(gmap.sx[#gspecials]*4,gmap.sy[#gspecials]*4,gspecials[1],450)
   del(gspecials,gspecials[1])
  end
  
  -- cleared?
  if (ec==0) game_setstate(s_levelcomplete)
  if (ec==1) enemies_angry(1)
  
  -- timer
  gtime+=1
  if gtime==0 then
   enemies_angry(0)
  elseif gtime==gmap.time then
   -- hurry
   music(-1)
   sfx(0)
   for i=0,90 do
    pc("hurry up!!",50,8+2*((i/4)%2))
    flip()
   end
   music(7)
   enemies_angry(1)
  elseif gtime==gmap.time2 then
   -- baron
   for p in all(gplayers) do
    if p.active and not p.baron then
     local b=enemy_add(et_baron,p.stx/4,p.sty/4,p.startdir)
     p.baron=b
     b.player=p
     if (p.y>60) b.y=20
     particles_add(8,b,4,7)
     sfx(4)
    end
   end
  else
   -- extra?
   for p in all(gplayers) do
    if p.extra==63 then
     music(32)
     for i=0,520 do
      cls(0)
      map_draw(gmap)
      for j=0,5 do
       spr(132+j,34+j*10,32+cos((i+j*12)/75)*8)
      end
      flip()
     end
     music(7)
     
     p.lives+=1
     p.extra=0
     
     game_resetlevel()
    end
   end
  end
  
  -- game over?
  if (not p1.active and not p2.active) game_setstate(s_gameover)
 elseif gs==s_levelcomplete then
  -- ################
  -- # level complete
  -- ################
  if gstatecount==1 then
   -- bubbles to fruit?
   if level%5==0 or golarge then
    local f=1+#gbubbles%12
    if golarge then
     item_collectible(56,0,50,-1,true)   
    end
    
    for b in all(gbubbles) do
     b.active=false
     item_collectible(b.x,b.y,f)
    end
   end
  elseif gstatecount>=400 then
   game_resetlevel(false)
  end
 elseif gs==s_complete then
  -- ###############
  -- # game complete
  -- ###############
  genemies={}
  message="game complete, well done!"
  if (gstatecount==240) game_setstate(s_levelcomplete)
 elseif gs==s_gameover then
  -- # game over
  if gstatecount==60 then
   message="game over"
  elseif gstatecount==240 then
   gameover=true
  end
 end

 -- players
 for p in all(gplayers) do
  if p.active then
   player_update(p)
   
   -- collisions
   if gs==s_playing and p.invincible==0 and p.st==ps_normal then
    for e in all(genemies) do
     --if e.active and e.st==e_normal and ecol(p,e) then
     if e.st==e_normal and ecol(p,e) then
      if p.ontrain then
       enemy_spin(e)
       e.collectible=1
      else
       player_setstate(p,ps_dying)
       gtime=-1
      end
     end
    end
   end
  end
  
  p.ontrain=false  
 end 
 
 -- counters
 gstatecount+=1
 if (gwaterlevel!=999) gwaterlevel-=1
end

function game_draw()
 if gs==s_gamestart then
  -- #######
  -- # intro
  -- #######
  stars()
  pc("now begins a fantastic story!",10,8)
  pc("let's make a journey to the",20,8)
  pc("cave of monsters!",30,8)
  pc("good luck!",40,8)
 else
  -- ######
  -- # game
  -- ######
  clip(0,12,128,104)
   
  if gs==s_levelstart then
   -- scroll
   camera(0,-ms.offy)
   if (not ms.map1hide) map_draw(ms.map1)
   camera(0,-ms.offy-128)
   map_draw(ms.map2)
   camera()
   clip()
  else
   camera(0,-12)
   
   -- map
   map_draw(gmap)
   clip()

   -- scores etc
   ?"high score",44,-12,8
   pc(hiscore.."0",-6,7)

   ps(level,0,2,15)
  
   for p in all(gplayers) do
    local lay=({{16,32,0,5},{100,116,124,-5}})[p.index]
    
    ?p.index.."p",lay[1],-12,p.c1
    local t=p.score.."0"
    ?t,lay[2]-#t*4,-6,7
    
    if p.active then
     for i=0,p.lives-2 do spr(29+p.im1,lay[3]+lay[4]*i,101) end
    end
    
    for i=0,5 do
     --if (band(p.extra,2^i)!=0) spr(132+i,120*p.im1,20+i*10)
     if (p.extra & 2^i !=0) spr(132+i,120*p.im1,20+i*10)
    end    
   end
  end

  camera(0,-12+gmap.offy)
  clip(0,0,128,116)   

  -- bubbles
  for b in all(gbubbles) do
   if b.ttl<150 then
    pal(11,8)
    if (b.ttl<75 and b.ttl%4<2) pal(11,14)
    pal(3,2)
    pal(10,9)
   elseif b.ttl<300 then
    pal(11,9)
    pal(3,4)
   end
   
   spr(b.spr+b.spriteoffset,b.x,b.y)
   
   pal()
  end
  
  foreach(gitems,gspr)
  
  foreach(genemies,gspr)
 end

 -- particles
 for p in all(gparticles) do circfill(p.x,p.y,p.r,p.c) end
 
 -- players
 for p in all(gplayers) do
  if p.active then
   pal(11,p.c1)
   pal(3,p.c2)
   pal(10,p.c3)

   if (gs==s_gamestart or gs==s_levelstart) spr(174,p.x-4,p.y-4,2,2)

   if p.invincible==0 or p.invincible%2==1 then
    if p.st!=ps_dying and p.stun==0 then
     for i=2,5 do
      local t1,t2=p.tail[i],p.tail[i-1]
      line(t1.x,t1.y,t2.x,t2.y,p.c1)
      if (i<3) line(t1.x,t1.y,p.tailjoinx,p.y+5)
     end
    end
    
    gspr(p)
   end
   
   pal()
  end
 end
 
 camera()
 --clip()

 -- message
 if (message and gs!=s_gamestart) pc(message,48,7)
end

function particles_add(count,e,r,c,speedmult)
 speedmult=speedmult or 1
 for i=1,count do
  add(gparticles,{x=e.x+(e.w/2)-r+rnd(r*2),y=e.y+(e.h/2)-r+rnd(r*2),r=0.5+rnd(r),c=c or 7,dx=(0.5-rnd(1))*speedmult,dy=(0.5-rnd(1))*speedmult,ttl=30+rnd(15)})
 end
end


-- bubbles
function bubbles_poptouching(bb,p)
 bb.active=false
 bb.popply=p
 
 sfx(6)
 
 c_pops+=1
 if (bb.type==bt_water) c_popswater+=1
 
 --if (bb.type==bt_letter) p.extra=bor(p.extra,2^(bb.letter))
 if (bb.type==bt_letter) p.extra|=2^bb.letter
 
 for b in all(gbubbles) do
  -- recurse
  if (b.active and rectsoverlap(b,bb)) bubbles_poptouching(b,p)
 end
end

function bubbles_update()
 local kc,kp=0,p1
 
 for b in all(gbubbles) do
  -- update
  bubble_update(b)
  
  -- burst?
  if not b.active then
   particles_add(6,b,2)
   
   -- enemy?
   local te=b.trappedenemy
   if te then
    if b.popply then
     enemy_spin(te)
     kc+=1
     kp=b.popply
    else
     te.st=e_normal
     te.angry=1
    end
   end
   
   -- special
   if b.popply then
    player_scoreadd(b.popply,1)   
    
    if b.type==bt_water then
     item_train(b)
    elseif b.type==bt_lightning or b.type==bt_fire then
     item_bullet(b,dirrev[b.popply.dir],b.type)
    end
   end
   
   del(gbubbles,b)
  end
 end
 
 -- score based on kill count
 if kc>0 then
  for e in all(genemies) do e.collectible=kc end
  player_scoreadd(kp,10*2^(kc-1))
  
  -- next level will spawn more letters
  if (kc>2) glettercount+=kc-2
 end
end


-- player
function player_new(i)
 return {index=i,
         im1=i-1,
         extra=0,
         lives=({5,3,2})[mode],
         score=0,
         input={i=i-1}}
         
end

function player_reset(s,newgame)
 reset_g_obj(s,12,108,0.8)
 
 s.firedelay=24
 s.firecounter=0
 s.firespeed=1.5
 s.firedistance=30
 
 s.jumpspeed=0.07
 s.jumpamount=-1.75
 
 if s.index==1 then
  s.startdir=d_right 
  s.c1=11
  s.c2=3
  s.c3=10
 else
  s.x=108
  s.startdir=d_left
  s.c1=12
  s.c2=1
  s.c3=8  
 end
 s.stx=s.x
 s.sty=s.y
 player_reset_newlevel(s) 
 
 if newgame then
  s.active=(s.index==1 or playercount==2) 
 else
  s.invincible=120
 end
 
 player_tail_reset(s)
 
 player_setstate(s,ps_normal)
end

function player_reset_newlevel(s)
 s.holdmove=0
 s.jumping=false
 s.spr=1
 s.invincible=0
 s.dir=s.startdir
 s.pow=0
 s.stun=0

 if s.baron then
  del(genemies,s.baron)
  s.baron=nil
 end
end

function player_setstate(s,st,c)
 s.st=st
 s.statecount=c or 0
end

function player_update(s)
 local i=s.input
 
 in_update(i)

 if gs==s_gamestart then
  -- ##########
  -- # circling
  -- ##########
  local n=s.statecount/120
  s.x=17+s.im1*87-sin(n)*12*xinc[s.dir]
  s.y=52+cos(n)*12  
 elseif gs==s_levelstart then
  -- #####################
  -- # moving to start pos
  -- #####################
  s.x=move(s.x,s.stx)
  s.y=move(s.y,s.sty-4)
 elseif s.st==ps_normal then
  -- ########
  -- # normal
  -- ########
  local bubblejump,holdmove,speedresolved,ox,oy,olddir=false,false,s.speed,s.x,s.y,s.dir
  
  if (not s.jumping) s.jumpdir=d_none
  
  local dx=xinc[s.jumpdir]*speedresolved*0.6
  if (s.jumping or s.dy>0) speedresolved*=0.25

  -- input direction
  if i.left then
   s.dir=d_left
   if (s.jumpdir!=d_left) s.jumpdir,dx=d_none,-speedresolved
  elseif i.right then
   s.dir=d_right  
   if (s.jumpdir!=d_right) s.jumpdir,dx=d_none,speedresolved
  end
  
  if (s.dir==dirrev[olddir]) s.holdmove=3 -- allow face-about without moving
  
  if s.holdmove>0 then
   s.holdmove-=1
  elseif s.stun==0 then
   -- do not stop x jump direction when hitting wall otherwise levels like 11 are odd
   if (dx!=0) entity_move_leftright(s,abs(dx),dx>0)
   
   if (ox!=s.x) c_runs+=1
  end
  
  -- vertical momentum
  if s.jumping then
   s.dy+=s.jumpspeed
  else
   s.dy=s.jumpspeed*10
  end
  
  if s.dy>=0 then
   s.grounded=not entity_move_down(s,s.dy)
   if (s.grounded or (s.jumping and s.y>=s.jumpstarty)) s.dy,s.jumping=0,false
  else
   s.grounded=false
   s.y+=s.dy
   
   wrap_y(s)
  end
  
  -- counters
  if (oy>100 and s.y<10) c_falls+=1
  
  -- bubble interactions with player
  for b in all(gbubbles) do
   if not b.firing and rectsoverlap(b,s) then
    if s.dy>0 and i.up and s.y+6<=b.y and i.up then
     bubblejump=true
     break
    elseif ecol(s,b) then
     bubbles_poptouching(b,s)
     break
    end
   end
  end
  
  -- jump?
  if (bubblejump or (i.uphit and s.grounded)) and s.stun==0 then
   s.dy=s.jumpamount
   s.jumping=true
   s.jumpstarty=s.y
   s.jumpdir=d_none
   if i.left then
    s.jumpdir=d_left
   elseif i.right then
    s.jumpdir=d_right
   end
   
   -- counter
   c_jumps+=1
   
   sfx(2)
  end
  
  if (i.fire1hit or (s.firedelay<20 and i.fire1)) and s.firecounter==0 then
   s.firecounter=s.firedelay
   if s.pow>0 then
    s.pow-=1
    item_bullet(s,s.dir,bt_lightning).ply=s
    sfx(8)
   else
    bubble_addplayer(s)
   end
  end
  if (s.firecounter>0) s.firecounter-=1
  
  if (s.invincible>0) s.invincible-=1
  if s.stun>0 then
   s.stun-=1
   if (s.stun==0) s.invincible=20
  end
 elseif s.st==ps_dying then
  -- #######
  -- # dying
  -- #######
  if s.statecount==1 then
   sfx(7)
  elseif s.statecount==120 then
   s.lives-=1
   if s.lives==0 then
    s.active=false
   else
    player_reset(s,false)
   end   
  end
 end
 
 -- counters
 s.statecount+=1
 
 -- animation
 player_tail_update(s)
 if s.st==ps_dying or s.stun>0 then
  s.spr=5+(s.statecount/6)%4
 elseif s.firecounter>0 then
  s.spr=4
 elseif s.jumping then
  s.spr=3
 else
  s.spr=1+flr(s.x/6)%2
 end
end

function player_tail_reset(s)
 s.tail={} 
 for i=1,5 do add(s.tail,{x=s.x+4,y=s.y+6}) end
end

function player_tail_update(s)
 local targetx,targety=s.x+3.5-3*xinc[s.dir],s.y+7
 s.tailjoinx=targetx 
 
 for i=1,5 do
  local t=s.tail[i]
  
  t.x=mid(targetx-0.25,move(t.x,targetx,s.speed/i),targetx+0.25)
  t.y=mid(targety-0.75,move(t.y,targety,0.25+s.speed/i),targety+0.75)
  
  targetx=t.x-xinc[s.dir]*i*0.3
  targety=t.y
  
  if (s.grounded and i>3 and time()%3<1) targety=s.y+5+(time()*4)%3
 end
end

function player_scoreadd(s,v)
 if (s.score<2500 and s.score+v>=2500) s.lives+=1
 s.score+=v
end


-- map
function map_init(l,temp)
 local s={
  temp=temp,
  offy=16,
  inmemory=false,
  tiles={},
  sx={},
  sy={}
 }
 local tiles=s.tiles
 
 -- initialise tiles
 for y=0,34 do
  local row={}
  for x=1,32 do
   add(row,{solid=false,x=(x-1)*4,y=(y-1)*4,w=4,h=4,flow=d_up})
  end
  --add(tiles,row)
  tiles[y]=row
 end
 
 -- ceiling and floor
 map_rect(tiles,1,1,32,5,true)
 map_rect(tiles,1,30,32,5,true)
 
 -- get map definition
 local def=maps[1+(l-1)%100]
 local pos,region=18,1
 --if (def=="") return s
 
 -- header
 local arr=c2arr(def,0,17)
 s.tile=arr[1]+63
 s.time=arr[2]*120
 s.time2=s.time+arr[3]*120
 s.bubblespeed=arr[4]/10
 s.enemyspeed=arr[5]
 s.bubblettl=arr[6]*2
 s.ratewater=arr[7]
 s.ratefire=arr[8]+s.ratewater
 s.ratelightning=arr[9]+s.ratefire
 s.sx[1]=arr[10]
 s.sy[1]=arr[11]
 s.sx[2]=arr[12]
 s.sy[2]=arr[13]
 s.gaps=arr[14]
 s.c1=arr[15]
 s.c2=arr[16]
 s.c3=arr[17]

 -- solids, airflow and enemies
 while pos<#def do
  pos+=1
  local t=sub(def,pos,pos)
  arr={}

  if t=="|" then
   -- next region
   region+=1
  elseif region<3 then
   -- solids and airflow sections
   if t=="m" then
    -- mirror
    map_mirror(tiles)
   elseif t=="s" then
    -- solid pattern from sprite
    arr=c2arr(def,pos,3)
    
    for y=0,7 do
     for x=0,7 do
      local spr=arr[3]
      tiles[arr[2]+y][arr[1]+x].solid=sget(spr%16*8+x,96+y+flr(spr/16)*8)!=0
     end
    end
   elseif t=="t" then
    -- solid pattern from tile map
    arr=c2arr(def,pos,6)
    
    map_tilem(tiles,arr[1],arr[2],arr[3],arr[4],arr[5],arr[6])
   else
    -- solid/ hollow/ airflow rectangle
    arr=c2arr(def,pos,4)
    
    local v=t=="r"
    if (region==2) v=flr(t)
    
    map_rect(tiles,arr[1],arr[2],arr[3],arr[4],v)
   end
  else
   -- enemy
   local e=flr(c2int[t])
   local dir=d_left
   if e>16 then
    e-=16
    dir=d_right
   end
   
   arr=c2arr(def,pos,2)
   
   if (not temp) enemy_add(e,arr[1],arr[2],dir)
  end

  -- move pointer on based on how may characters were read
  pos+=#arr
 end
 
 -- gaps in floor and ceiling
 for i=0,3 do
  map_rect(tiles,({10,20,10,20})[i+1],({1,1,30,30})[i+1],4,5,not bandb(s.gaps,2^i))
 end
 
 -- mark vertical walls and also pick up spawn points
 gspawns={}
 for y=1,33 do
  for x=3,30 do
   local t=tiles[y][x]
   
   if t.solid then
    t.solidwall=(tiles[y-1][x].solid or tiles[y+1][x].solid)
    --t.solidwall_left=t.solidwall and not tiles[y][x+1].solid
    -- and (not tiles[y][x-1].solid or not tiles[y][x+1].solid)   
   else
    if (((y==5 and t.flow==d_down) or (y==30 and t.flow==d_up)) and (x==11 or x==21)) add(gspawns,{x=t.x,y=t.y})   
   end
   --t.solidwall=t.solid and y>5 and (tiles[y-1][x].solid or tiles[y+1][x].solid)
   
   
   --if (not t.solid and ((y==5 and t.flow==d_down) or (y==30 and t.flow==d_up)) and (x==11 or x==21)) add(gspawns,{x=t.x,y=t.y})
  end
 end
 
 -- finalise
 --s.shadow=sget(4+(s.tile-64)*8,33)
 --s.shadow=s.c3
 
 return s
end

function map_rect(tiles,x,y,w,h,sorf)
 for py=y,y+h-1 do
  for px=x,x+w-1 do
   if type(sorf)=="number" then
    tiles[py][px].flow=sorf
   else
    tiles[py][px].solid=sorf
   end
  end
 end
end

function map_tilem(tiles,mx,my,tmx4,tmy4,tmw,tmh)
 for y=0,tmh-1 do
  for x=0,tmw-1 do
   local spr=mget(x+tmx4*4,y+tmy4*4)-239
   --spr-=239
   local tx,ty=mx+x*2,my+y*2
   --todo:consolidate like gaps code
   tiles[ty][tx].solid=bandb(spr,1)
   tiles[ty][tx+1].solid=bandb(spr,2)
   tiles[ty+1][tx].solid=bandb(spr,4)
   tiles[ty+1][tx+1].solid=bandb(spr,8)
  end
 end
end

function map_mirror(tiles)
 for y=1,32 do
  for x=1,16 do
   local tl,tr=tiles[y][x],tiles[y][33-x]
   tr.solid=tl.solid
   if tl.flow==d_left or tl.flow==d_right then
    tr.flow=dirrev[tl.flow]
   else
    tr.flow=tl.flow
   end
  end
 end
end

function map_draw(s)
 if (gwaterlevel!=999) rectfill(0,gwaterlevel,128,128,1)

 if s.inmemory and gwaterlevel==999 then
  memcpy(0x6300,0x4300,6656)
 else
  pal(14,s.c1)
  pal(8,s.c2)
  pal(2,s.c3)
  
  -- left side wall shadow
  rectfill(9,4,2,100,2)
  
  -- solids
  for y=1,32 do
   for x=3,30 do
    --if (s.tiles[y][x].solid) spr(s.tile,(x-1)*4,(y-1)*4-s.offy)
    local t=s.tiles[y][x]
    if (t.solid) spr(s.tile,t.x,t.y-s.offy)
    --if (t.solidwall) rect(t.x,t.y-s.offy,t.x+4,t.y-s.offy+4,11)
   end
  end

  -- side walls
  for y=0,128,8 do
   for i=0,1 do
    spr(s.tile+16,120*i,y-s.offy)
   end
  end  
  
  if not s.temp and gwaterlevel==999 then
   memcpy(0x4300,0x6300,6656)
   s.inmemory=true
  end
  
  pal()
 end
end

function map_platformabove(e)
 local isplatform,oy=false,e.y
 e.y-=20
 for i=0,4 do
  if (not entity_move_down(e,2)) isplatform=true
  e.y+=2
 end
 e.y=oy
 return isplatform
end

function map_isgapinfloor(e,dir)
 return not gtiles[1+flr((e.y+10)/4)][1+flr((e.x+4+xinc[dir]*4)/4)].solid
end

function map_overlapssolid(e)
 --local tilex,tiley=1+flr(e.x/4),1+flr(e.y/4)
 local tilex,tiley=1+e.x\4,1+e.y\4
 for y=max(1,tiley),min(32,tiley+2) do
  for x=max(1,tilex),min(32,tilex+2) do 
   local t=gtiles[y][x]
   if (t.solid and rectsoverlap(t,e)) return true
  end
 end
 
 return false
end

function entity_move(e,speed)
 if e.dir==d_down then
  return entity_move_down(e,speed)
 elseif e.dir==d_update then
  return entity_move_up(e,speed)
 else
  return entity_move_leftright(e,speed,e.dir==d_right) 
 end
end

function entity_move_down(e,speed)
 local stopy=999
 
 local stx=1+e.x\4--flr(e.x/4)
 local endx=1+(e.x+e.w-1)\4 --(flr((e.x+e.w-1)/4)
 --local sty=mid(1,1+ceil((e.y+e.h)/4),32)
 local sty=mid(1,1+ceil((e.y+e.h-1)/4),32)
 --n=1+ceil((e.x+e.w-1)/4)
 
 for x=stx,endx do
  local t=gtiles[sty][x]
  if t.solid then
   if sty>1 and gtiles[sty-1][x].solid then
    stopy=999
    break
   else
    stopy=t.y-e.h
   end
  end
 end
 
 if (stopy<16) stopy=999
 
 if e.y<stopy then
  e.y=min(stopy,e.y+speed)
  
  wrap_y(e)
  
  return true
 end
 
 return false
end

function entity_move_up(e,speed)
 local stopy=-999
 
 local stx=1+e.x\4--flr(e.x/4)
 local endx=1+(e.x+e.w-1)\4 --flr((e.x+e.w-1)/4)
 local sty=mid(1,flr((e.y+e.h)/4)-1,32)
 
 for x=stx,endx do
  local t=gtiles[sty][x]
  if t.solid then
   stopy=t.y+t.h
  end
 end
 
 if e.y>stopy then
  e.y=max(stopy,e.y-speed)
  
  wrap_y(e)
  
  return true
 end
 
 return false
end

function entity_move_leftright(e,speed,right)
 local stopx=8
 if (right) stopx=120-e.w
 
 --local sty=mid(1,1+flr(e.y/4),32)
 local sty=mid(1,1+e.y\4,32)
 local endy=mid(1,1+flr((e.y+e.h-1)/4),32)

 if (e.grounded) sty=endy

 local n=e.x\4--flr(e.x/4)
 if (right) n=1+ceil((e.x+e.w-1)/4)
 local stx=mid(1,n,32)

 if not e.jumping or endy>6 then
  for y=sty,endy do
   local t=gtiles[y][stx]
   if (e.grounded and t.solid) or (not e.grounded and t.solidwall) then
    if right then
     if (e.grounded or not gtiles[y][stx-1].solid) stopx=min(stopx,t.x-e.w)
    else
     if (e.grounded or not gtiles[y][stx+1].solid) stopx=max(stopx,t.x+t.w)
    end
   end
  end
 end
 
 if not right and e.x>stopx then
  e.x=max(stopx,e.x-speed)
  return true
 elseif right and e.x<stopx then
  e.x=min(stopx,e.x+speed)
  return true 
 end
 
 return false 
end


-- map scroller
function ms_reset(fromlevel,tolevel,speed,map1hide)
 ms={
  map1hide=map1hide,
  done=(fromlevel==tolevel),
  fromlevel=fromlevel,
  tolevel=tolevel,
  currentlevel=fromlevel,
  pausecounter=0,
  speed=speed,
  offy=12
 }

 ms.map1=map_init(fromlevel,true)
 ms.map2=map_init(fromlevel+1,true)
end

function ms_update()
 if (ms.done) return
 
 if ms.pausecounter>0 then
  ms.pausecounter-=1
 else
  ms.offy-=ms.speed
  if ms.offy==-116 or ms.offy==12 then
   ms.currentlevel+=1
   
   if ms.currentlevel==ms.tolevel then
    ms.done=true
   else
    ms.pausecounter=30
    ms.offy=12
    ms.map1=map_init(ms.currentlevel,true)
    ms.map2=map_init(ms.currentlevel+1,true)    
   end
  end
 end
end


-- bubble
function bubble_new()
 local s={
  type=bt_normal,
  dirhold=0,
  letter=0,
  spr=9,
  trappedenemy=nil,
  trappedspr=0,
  ttl=900,
  xmod=0
 }
 
 reset_g_obj(s,x,y,0)
 
 gbubblesspawned+=1

 return add(gbubbles,s)
end

function bubble_addplayer(p)
 local s=bubble_new()
 
 s.firing=true
 s.x=p.x+xinc[p.dir]*4
 s.firecount=0
 s.y=p.y
 s.dir=p.dir
 s.speed=p.firespeed
 s.statecount=p.firedistance/p.firespeed
 s.spriteoffset=p.im1*16
 s.player=p
 
 sfx(1)
end

function bubble_spawn()
 local s=bubble_new()
 
 -- get spawn point
 local sp=gspawns[1+#gbubbles%#gspawns] 
 
 -- decide bubble type
 local n=gbubblesspawned%16
 if glettercount>0 and n==9 then
  s.type=bt_letter
  s.letter=gbubblesspawned%6
  glettercount-=1 
 elseif n<gmap.ratewater then
  s.type=bt_water
 elseif n<gmap.ratefire then
  s.type=bt_fire
 elseif n<gmap.ratelightning then
  s.type=bt_lightning
 else
  s.type=bt_normal
  if (n%2==0) s.letter=16
 end
 
 -- set direction based on spawn point (top or bottom)
 if sp.y<50 then
  s.dir=d_down
  s.y=0
 else
  s.dir=d_up
  s.y=128
 end
 
 s.x=sp.x
 s.spr=s.type
 s.spriteoffset=s.letter
end

function bubble_update(s)
 local sp=s.speed
 
 if gwaterlevel<s.y then
  -- swamped by water
  s.active=false
 elseif s.firing then
  -- ########
  -- # firing
  -- ########
  s.firecount+=s.speed
  
  if s.firecount<2 then
   -- always move short distances so we can fire through walls we're aligned with
   s.x+=xinc[s.dir]*s.speed
  else 
   -- can't move so stop firing
   if (not entity_move(s,sp)) s.statecount=-1
   
   -- hit solid?
   if (map_overlapssolid(s)) s.active=false
  end
  
  -- trap enemy?
  for e in all(genemies) do
   if e.st==e_normal and rectsoverlap(s,e) then
    if e.invincible>0 then
     s.active=false
    else
     e.st=e_trapped
     e.bubble=s
     s.trappedenemy=e
     s.statecount=2 -- is this required?
     s.spr=12
     s.firing=false
    end
    break
   end
  end
 
  -- finish firing?
  if s.statecount<=0 then
   s.firing=false
   s.spr=bt_normal  
  end
 else
  -- ########
  -- # normal
  -- ########
  s.speed=gmap.bubblespeed
  
  if s.dx!=0 or s.dy!=0 then
   -- momentum, e.g., jostled or pushed by player
   s.x+=s.dx
   s.y=max(20,s.y+s.dy)
   s.dx*=0.5--0.5
   s.dy*=0.5--0.5
   if (abs(s.dx)<0.1) s.dx=0
   if (abs(s.dy)<0.1) s.dy=0
  else
   -- flow
   if s.dirhold<=0 then
    local t=gtiles[max(1,1+flr((s.y+4)/4))][1+flr((s.x+3+xinc[s.dir])/4)]
    if s.dir!=t.flow then
     s.dirhold=2--4
     s.dir=t.flow
    end
   else
    s.dirhold-=sp
   end

   s.x+=xinc[s.dir]*sp
   s.y+=yinc[s.dir]*sp
  end
  
  wrap_y(s)
  
  s.ttl-=1
  if (s.ttl<100) s.spriteoffset=0
  if (s.ttl<=0) s.active=false
  
  if s.dx==0 and s.dy==0 then
   -- jostle
   if s.dirhold<=0 then
    for b in all(gbubbles) do
     if b!=s and b.dirhold<=0 and b.dx==0 and b.dy==0 and ecol(s,b) then
      b.dy=sgn(b.y-s.y)*sp*0.75--0.75
      b.dx=sgn(b.x-s.x)*sp*3.2
      
      -- only jostle one bubble per loop (doesn't seem to make much difference)
      break
     end
    end   
   end

   -- push
   for p in all(gplayers) do
    if p.active and rectsoverlap(s,p) and abs(p.y-s.y)<4 then
     entity_move_leftright(p,1,s.x<p.x)
     s.dx=sgn(s.x-p.x)
    end
   end
  end
 end
 
 -- horizontal clamping
 s.x=mid(8,s.x,112)
 
 -- counters
 s.statecount-=1 
end


-- enemies
function enemy_add(t,x,y,dir)
 if (level>100 or mode>1 and t==et_zen) t=et_hidegon

 local e={
  index=#genemies,
  type=t,
  dir=dir,
  angry=0,
  bubble=nil,
  paused=0,
  invincible=0,
  firehold=-1,
  collectible=7,
  jumpspeed=0.05,
  jumpstrength=1.5
 }
 
 reset_g_obj(e,x*4,y*4,({0.5,0.55,0.6})[mode])
 
 -- zen,banebou,mighta,hidegon,pulpul,monsta,invader,drunk,baron,super
 e.sprbase=({16,32,50,123,105,41,96,114,72,59})[t]
 e.score=(t-1)*100
 if (t==1) e.score=50

 if t==et_mighta then
  e.firehold=0  
 elseif t==et_drunk or t==et_hidegon then
  e.speed*=1.25
  e.firehold=0
 elseif t==et_super then
  e.bouncer=true
  e.jumpspeed=0.04
  e.jumpstrength=1.5
  e.speed*=0.55
  e.invincible=50
  e.w=16
  e.h=16
 elseif t==et_pulpul then
  e.flyer=true
  e.dy=1
  e.speedy=e.speed*0.5
 elseif t==et_monsta then
  e.flyer=true
  e.dy=1
  e.speedy=e.speed*1.12
 elseif t==et_banebou then
  e.bouncer=true
  e.jumpspeed=0.02
  e.jumpstrength=0.85
  e.speed*=0.5
 elseif t==et_invader then
  --e.speed=0.25  
  e.speed*=1.5
  e.firehold=0  
 elseif t==et_baron then
  e.speed=0.25
  e.invincible=9999
  e.baronvert=true
  e.baroncounter=20
  e.baronmoves=0
  e.paused=30
 end
 
 e.spr=e.sprbase 
 
 return add(genemies,e) 
end

function enemy_update(s)
 -- inactive?
 if (not s.active) return
 
 -- initialise
 local speedresolved=s.speed
 if (s.angry>0) speedresolved*=1.5
 
 if s.st==e_spin then
  -- ##########
  -- # spinning
  -- ##########
  if (s.dir!=d_left and s.dir!=d_right) s.dir=d_right
  
  s.x+=xinc[s.dir]
  if (s.x<=8 or s.x>=112) s.dir=dirrev[s.dir]
  
  s.dy=min(s.dy+0.07,gravity)
  if s.dy>0.5 and s.statecount>100 then
   if not entity_move_down(s,s.dy) then
    s.active=false
    item_collectible(s.x,s.y,s.collectible)
   end
  else
   s.y+=s.dy
  end
  
  s.spr=s.sprbase+5+(s.statecount*speedresolved*0.5)%4
 elseif s.st==e_normal then
  -- ########
  -- # normal
  -- ########
  if s.paused>0 then
   -- paused, e.g., zen afer jump
   s.paused-=1
  elseif s.type==et_baron then
   -- # baron
   local p=s.player
   if p.st!=ps_normal or gs!=s_playing then
    s.active=false
    particles_add(8,s,4,7)
   elseif s.baronvert then
    s.y=move(s.y,p.y)
   else
    local ox=s.x
    s.x=move(s.x,p.x)
    if s.x>ox then
     s.dir=d_right
    elseif s.x<ox then
     s.dir=d_left
    end
   end
   s.baroncounter-=1
   if s.baroncounter<=0 then
    s.baronmoves+=1
    s.baroncounter=20+s.baronmoves*2
    s.baronvert=not s.baronvert
    s.paused=80-s.baronmoves*2
   end
  else
   -- horizontal bouncing off walls
   if s.grounded or s.bouncer or s.flyer then
    if (not entity_move(s,speedresolved)) s.dir=dirrev[s.dir]
   end
  
   if s.bouncer then
    -- # bouncer
    s.jumping=true

    s.dy=min(s.dy+s.jumpspeed,gravity)
    
    if s.dy>=0 then
     if (not entity_move_down(s,s.dy)) s.dy=-s.jumpstrength
    else
     s.y+=s.dy
    end
   elseif s.flyer then
    -- # flyer
    if s.dy>0 then
     if (not entity_move_down(s,s.speedy)) s.dy*=-1
    else
     if (not entity_move_up(s,s.speedy)) s.dy*=-1
    end
   else
    -- # platformer
    local olddir=s.dir
    
    -- find player to home in on
    local ply=p1
    if (not p1.active or (p2.active and s.index%2==0)) ply=p2

    -- jumping
    if s.jumping then
     if (s.jumpdir!=d_none) entity_move_leftright(s,speedresolved,s.jumpdir==d_right)    
     s.dy+=s.jumpspeed
     if (s.y>s.jumpstarty) s.jumping=false
    else
     s.dy=gravity
    end
    
    -- falling
    if s.dy>=0 then
     s.grounded=not entity_move_down(s,s.dy)
     if s.grounded then
      --s.dy=0
      s.jumping=false
     end
    else
     s.grounded=false
     s.y+=s.dy
    end
    
    -- ai
    local canfire=(s.type==et_invader and s.grounded)
    local jump,jumpmult=false,1
    local trigger=ply.st==ps_normal and flr((gstatecount+s.x)%22)==s.index*3
    
    if s.type==et_invader or not ply then
     
    elseif not s.jumping then
     if (ply.y==s.y and ply.grounded) or (ply.jumping and ply.jumpstarty==s.y) then
      -- home
      if trigger then
       canfire=true
       
       if s.x>ply.x then
        s.dir=d_left
       elseif s.x<ply.x then
        s.dir=d_right
       end
      end
     
      -- gaps
      if s.grounded and map_isgapinfloor(s,s.dir) then
       jump=true
       jumpmult=0.6
       s.jumpdir=s.dir
      end
     elseif ply.y+4<s.y and trigger and s.grounded then
      -- up?
      if map_platformabove(s) then
       jump=true
       s.jumpdir=d_none
       s.paused=15
      end
     end
    end
    
    -- change of direction should hold fire for a beat
    if (olddir==dirrev[s.dir] and s.firehold>=0) s.firehold=15
    
    -- jump
    if jump then
     s.dy=-s.jumpstrength*jumpmult
     s.jumping=true
     s.jumpstarty=s.y
    end
    
    -- fire
    if canfire and s.firehold==0 then
     item_bullet(s,s.dir,s.type).firer=s
     s.firehold=90
     
     if s.type==et_mighta then
      s.paused=30
     elseif s.type==et_drunk then
      s.paused=120
     end
    end
    
    if (s.firehold>0) s.firehold-=1
   end
  end
  
  -- animate
  local t=(s.statecount*speedresolved*0.20)%2  
  if s.type==et_baron then
    s.spr=s.sprbase+t
  elseif s.type==et_super then
  s.spr=72+flr(t)*2
  else
   s.spr=s.sprbase+(s.angry*2)+t
  end
  
  -- drown
  if (gwaterlevel<s.y) enemy_spin(s)
 elseif s.st==e_trapped then
  -- #########
  -- # trapped
  -- #########
  s.x=s.bubble.x
  s.y=s.bubble.y
  
  s.spr=s.sprbase+4
  if (s.statecount%16==1) s.dir=dirrev[s.dir]
 end
 
 wrap_y(s)
  
 s.statecount+=1
end

function enemy_spin(s)
 if s.type==et_super then
  particles_add(100,s,3,8)
  s.active=false
  game_setstate(s_complete)
 elseif s.active then
  s.st=e_spin
  s.statecount=0
  s.dy=-1.75
 end
end

function enemies_angry(angry)
 for e in all(genemies) do e.angry=angry end
end


-- item
function item_collectible(x,y,t,ttl,big)
 local s={
  collectible=true,
  type=t,
  ttl=ttl,
  score=5*t,
  spr=138+t
 }
 
 reset_g_obj(s,x,y,gravity)

 if big then
      --f=4+8*(level%2)
  s.spr=76
  if (level%2==1) s.spr=78
  s.w=16
  s.h=16
  s.speed=1.4
  --s.score=250
 end

 return add(gitems,s) 
end

function item_bullet(e,dir,bt)
 local s={
  bullet=true,
  dir=dir,
  diry=0,
  sc=0,
  spr=63,
  type=bt,
  dam=1, -- 1=ply kill, 2=ply stun, 4=en kill,8 bub burst
  ttl=-1
 }

 reset_g_obj(s,e.x,e.y,1)
 
 if bt==-1 then
  -- fire parcel
  s.w=4
  s.h=4
  s.dir=d_down
  s.spr=172
  s.ttl=240
  s.dam=6 -- stun player, kill enemy
 elseif bt==bt_fire then
  s.dir=d_down
  s.spread=dir
  s.spr=62
  s.speed=gravity
  s.dam=0
 elseif bt==bt_lightning then
  s.spr=61
  s.dam=14 -- kill enemy, burst bubbles
 elseif bt==et_mighta then
  s.speed=0.75
 elseif bt==et_hidegon then  
  s.speed=1.35
 elseif bt==et_drunk then
  s.spr=159 
  --s.speed=1.25
  s.rebound=true
 elseif bt==et_invader then
  s.spr=138
  s.speed=gravity
  s.diry=d_down
  s.dir=d_none
 end
 
 return add(gitems,s)
end

function item_train(e)
 local s={
  train=true,
  player=e.popply,
  dir=dirrev[e.popply.dir],
  spr=31
 }
 
 reset_g_obj(s,e.x,e.y-4,2)
 
 s.w=4
 s.h=4
 
 add(gitems,s) 
end

function item_update(s)
 if s.bullet then
  -- ########
  -- # bullet
  -- ########
  s.y+=yinc[s.diry]*s.speed
  s.active=s.x>=8 and s.x<=112 and s.y<128
  
  if s.type==et_invader then
   particles_add(3,s,1,8,0.5)
  elseif s.type==bt_lightning then
   s.x+=xinc[s.dir]*1.5
  elseif not entity_move(s,s.speed) then
   if s.type==bt_fire then
    -- turn dropping fire into fire parcels that spread
    s.active=false
    item_bullet(s,d_none,-1)
    local b=item_bullet(s,d_none,-1)
    entity_move_leftright(b,8,s.spread==d_right)
   elseif s.rebound then
    s.rebound=false
    s.dir=dirrev[s.dir]
   elseif s.ttl>0 then
    s.ttl-=1
    s.spr=172+((s.ttl/10)%2)
    if (s.ttl%20==1) particles_add(3,s,1,9,0.5)
   else
    s.active=false
   end
  elseif s.type==et_mighta or s.type==et_hidegon then
   particles_add(2,s,1.5,8,0.1)
  elseif s.type==et_drunk then
   s.spr=168+(s.x/2)%4
  end
  
  s.sc+=1
 elseif s.train then
  -- #######
  -- # train
  -- #######
  if (s.grounded and not entity_move(s,s.speed)) s.dir=dirrev[s.dir]
   
  s.grounded=not entity_move_down(s,s.speed)

  particles_add(4,s,1.25,12,0)
  
  if (s.y<2) s.active=false
 else
  -- #############
  -- # collectible
  -- #############
  if s.w==16 and s.y<80 then
   s.y+=s.speed
  else
   entity_move_down(s,s.speed)
  end
  
  if s.ttl and level!=100 then
   s.ttl-=1
   if (s.ttl==0) s.active=false
  end
 end

 for p in all(gplayers) do
  if p.active and (ecol(p,s) or (s.w!=8 and rectsoverlap(p,s))) then
   if bandb(s.dam,2) and s.sc>30 and p.stun==0 and p.invincible==0 then
    p.stun=15--30
   elseif s.collectible then
    player_scoreadd(p,s.score)
    s.active=false
    sfx(5)
    
    -- collectile type
    if (s.type==23) golarge=true
    if (s.type==24) p.firedistance=50
    if (s.type==25) p.firespeed,p.firedelay=3,12
    if s.type==26 then
     gskip=2
     game_resetlevel()
    end
    if (s.type==27) gwaterlevel=128
    if (s.type==28) p.speed,p.jumpspeed,p.jumpamount=1.25,0.17,-2.75
    if s.type==29 then
     gspecials={29}
     p.pow=10
    end
    
    if (s.type>12) c_specials+=1
   elseif s.train then
    if (not (p.jumping and p.dy<-1)) p.x,p.y,p.ontrain=s.x,s.y-4,true
   elseif bandb(s.dam,1) and p.st==ps_normal and p.invincible==0 and not p.ontrain then
    player_setstate(p,ps_dying)
    s.active=false
   end
  end
 end
 
 -- enemy collisions
 for e in all(genemies) do
  if e.active and e.st==e_normal and rectsoverlap(e,s) then
   if s.firer==e and e.type==et_drunk then
    -- bottle returned
    if (not s.rebound) s.active,e.paused=false,0
   elseif bandb(s.dam,4) then
    -- kill enemy
    if (e.invincible>0) e.invincible-=1
    if (e.invincible==0) enemy_spin(e)
    if (s.type!=-1) s.active=false
   end
  end
 end
 
 -- bubble collisions
 if bandb(s.dam,8) then
  for b in all(gbubbles) do
   if ecol(b,s) then
    b.active=false
    b.popply=s.ply
    --s.active=false
   end
  end
 end
 
 if (not s.active) particles_add(8,s,1,10)
end
-->8
-- helper

function stars()
 srand(10)
 for i=0,100 do pset(rnd(128),(-time()*20+rnd(128))%128,1) end
end

function bandb(a,b)
 return band(a,b)==b
end

function wrap_y(s)
 if (s.y<-8) s.y=122
 if (s.y>122) s.y=-8
end

function move(c,d,s)
 s=s or 1
 if c<d then
  return min(c+s,d)
 elseif c>d then
  return max(c-s,d)
 end
 return c
end

function gspr(e)
 if (e.active) spr(e.spr+e.spriteoffset,e.x,e.y,e.w/8,e.h/8,e.dir==d_right)
end

function ecol(e1,e2)
 if (e2.w==16) return rectsoverlap(e1,e2)
 return abs(e1.x-e2.x)<5 and abs(e1.y-e2.y)<6
end

function rectsoverlap(e1,e2)
 return e1.x<e2.x+e2.w and
        e2.x<e1.x+e1.w and
        e1.y<e2.y+e2.h and
        e2.y<e1.y+e1.h
end

function kb(k)
 return stat(30) and stat(31)==k
end

function reset_g_obj(s,x,y,sp)
 s.x=x
 s.y=y
 s.speed=sp

 s.active=true
 s.w=8
 s.h=8
 s.dx=0
 s.dy=0
 s.st=0
 s.statecount=0
 s.jumping=false
 s.jumpstarty=0
 s.spriteoffset=0
end

function pc(s,y,c,o)
 ps(s,64-#s*2+(o or 0),y,c)
end

function ps(s,x,y,c)
 for y1=-1,1 do
  for x1=-1,1 do
   ?s,x+x1,y+y1,0
  end
 end

	?s,x,y,c
end


-- input
function in_update(s)
 local i=s.i
 s.up=btn(4,i) or btn(2,i)
 s.uphit=s.up and not s.oup
 s.down=btn(3,i)
 s.left=btn(0,i)
 s.right=btn(1,i)
 s.fire1=btn(5,i)
 s.fire1hit=s.fire1 and not s.ofire1
 
 s.oup=s.up
 s.ofire1=s.fire1
end
-->8
-- effects

function t_draw()
 if (_ta) rectfill(0,_tv,128,128,0)
end

function t_update()
 if _ta then
  _tv+=4
  _ta=_tv<128
 end
end

function t_fadein()
 _ta,_tv=true,0
end
-->8
-- maps

maps={
"1f525f000ackc0e82|r3fs1r3ks1r3ps1b583k|236c43f643m|1f61f91fc",
"2f525f000fhfm0a94|rea31rbf51r8k91r5p71rep31|236c43f643m|1e7hg71cchic",
"2f525u000a7k7fa84|r6a81r6f91r6ka1rap31r3p51r6a1a|3f648236d22c84227b9417d2227g8417i2246lb423qc41fn47m|h6cha71oc1k7",
"6f525f0002rsrf835|r9612r9731r6b9fb7c63bac3db7l94b6g74bak61bdp21rgp11|236ek3d68h336731393713k3a36pb246rb33ac2d4cb1c1gl242an22m|h581p8h7c1nch9m1lm",
"3f525ac00fhfrf8e2|r791hr1111r8a91r8f91r8k91r8p81b7b13b7g13b7l13mb8a11bpf11b8k11|33us546qb42hqb423ld34ild346gb32hgb325bb34ibb3289g1331s84a7g2237514q751|1i71gc1eh1cm",
"7f525ac0087q7f482|r7ao1r3fo1r7ko1r5pb1ripb1|311vw469q122eq146jq123or123t814dt412ht414nt911gp21|1o71qh3kcjfh",
"7f525a00057p7f1cd|r3a71r3f91r3kb1r5pa1|3a17n2368o2bb2j2dg252dl243au452dp35m|j273s7j4c3qc",
"7f525a00089m9367d|r681cr9c21r9h21r9m81r3q51raq21req31|321uj457c11782a4889i45k4623k264ar73m|j893m9h8e1me",
"6f525a00067o73982|r6a41r5e41r6i41r7m41r9q61r1111rga11rfe21rei31rdm31|331er4575b4da4846j4348n8323sc24ck42m|j773n7j5b3pb3ff",
"2f525ac0026s6f615|r3921r3d21r3h61r3l81r3p41r4b31r6c11r6d32r6f51rag11rah32raj51rck34reo12r9p41r9q13m|32uf52e73c4a74637536321f62374427b2239b2229d223bd222bf223dd142ch22m|h6a1erhgr1oamfcmhe6de",

"8f5256400f5fif65d|r6m51rem31ret31rgr12t980044|321ff457c123d1824g9245sa23au45m|1d51f5hh5697679ml7mn9",
"2f525f800a6k6fd65|sa9gs8kwrgg12r6811r6d1cr3o11r5o11|3254j466b71g8152f8184ad564fg174gk1a2ar5322c2c45c1cm|m2lm2km2j6sl6sk6sj",
"1f525f00000000000|||",
"2f5256000d8njfc15|s997sh98s9hnshhoras21rms21|225934d5462h5474n59322a9222e5245if421m7222q9245ob22god245tb12gtd14rk422mg724nc822la82|6g96ia6jb6kc6lejmi37c",
"8f5255c00c8p8bd65|r9714r9b64rgbf1rgcf5r4gc1r5ho6b6im5bpc65r7mk1r5qo1r3i11r4k11r3m11|22sr235ro14ki8222535476f5355232k7621p5444r5563g1b53q6233ku45|h98hc81j81m81fj3ojj6j",
"3f52660009dld08e2|r5882rc715r5a22rcb31reb12red31rge14rcf11r3g5brak62ram23ras72rgo14reo22r3r13|22q642ap334eq222cm4227i8222cc435a8232537455732c6123d3852d83532b52m|m456q5mc86i8m2a6sa6fh",
"1f525f00000000000|||",
"1f525f00000000000|||",
"5f525600846q6fe82|r59cer6nb1rco51b5gc1b692db992dbc92dbf92drdp41req34bfp15r3o13r3q53b3r42|336e1369b7237d22f91d23fe245n1146o824aq43m|65j68j6bj6fjmjjmmjmpj",
"2f5256c0098l8f6d5|r6912r6b51rcb51rb711r9s12r3rd1rfs11r3na1ren31r4ld1mr4pn1rsp31|45nc12hnc145lc12hlc125c2237c2227e222be222fe222je222ne223bc223fc223jc223nc2229c212dc212hc212lc212pc42457r1325u2279i237822|j683o858b5mb5fe",

"6f535600098k83865|rf821re921rda21rab41r9c21r7d31r6e21r5f21r5g1cr6ra1r9e1drdc1fred31rei31rem31r6i31r6m31rag31rak31rao31bar31|22se22ed2em225j34n593|3fajff3fj1lhh9hh9l1ll",
"1f525c00g2fsffca1|ras41r8991r7aa1r6bbcr8o91r7na1b8b2cb7c4abdb2cm||57f5cf5if5nf",
"1f525f00000000000|||",
"1f525f00000000000|||",
"3f52560c08lfl3a92|t4701d3r5k14r6n12r7od1rjn21rkk13rll11rmk81roj61|321uh236814c6512h6414m69137kd326j1422i4249if24nh9246b1148b114ab114cb114eb114gb114ib114kb114mb114ob114qb114sb114ub11|66l68l6al6cl6el6gl",
"7f53560808fmf376d|r3841r3b31r3e21r3h21r3k11r3n11r3qe4b4r23r9o11rfo11re831reb31rfe21rfh21rgk11|321uom|j253s5jf5j283s83f8jfb",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"4f537f00c36r6f655|r5966b6945re936bf925r9j66baj45m||5aflkfi6bifbiob2al2kl",

"1f525f00000000000|||",
"1f536k000fdff0d75|r6cbbb8d99b7e17b6c11b6m11bgc11r3p11r3k11r3f11r3a11|236e637ca627g9446nb7m3g61a|5ejlgj5ehlgh5eflgf5fd",
"1f525f00000000000|||",
"8f5256008c7i73e82|r9811r5a21rda21rad11r5f21rdf21r5k21rdk21r5p21rdp21r9i11ran11mrg811rhd11rgi11rhn11|321us11111|3fa34c34m3chjqcjihjqm",
"3f53650002ese3a94|s9dms9l#r3h61r3m51r4k11r6k11r8k11rcc11r9d11rae11r8g11mt5710c2|33rs222cf24hcf2325373t537321u5456922k6922e6314h6313e766|15ehpehle19e18mhmm1fr",
"2f5368000fdf90cd1|sdcxrfk32|225b54k5c53d573|2f92ja2mc2of26f28c2ba",
"8f53670a066p61605|r79oer5pq1bt922bjbc6b8g36bbg12bcc27beh12bfe36bie11br912bp912bn912rlb13bmh91bja21|46nq2321u7225943ja223cc2228g424ai142fe434hh13|1i61lf1fh18j1am1hm1nm",
"4f53360a0aqkqca52|r3c4irg812rgb1gr7ta1b3d32b3j32b3g32b3m32b3p32b3s32|326f54e633m|26q29q2cq2fqiiqilqioq",
"4f52660g0d5h5f984|re83mr8a2kb8a11bf811bfq24ber12|236e2458922aa1l4da1lm|15rh9rhbrhfr1jr1lrhpr",
"1f525f00000000000|||",

"1f525f00000000000|||",
"3e536400036r60e25|r3aehb5bc1b5dc2b5gc2b5jc2b5mc2b5pc1r9a1gred1db5ec1b9h11|335e322r53m|4a94f94k945c4pc4ff4fl",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"2d53660c0f6f9f67d|r6961r6c71r6f61r6i61r6l61r5o71r5rc1rb91ircq51res32|225934d5442cd4d2as32m|456kp6ip925925cipckfn",
"5f5255c00fafnfe82|rd641rc751ret31rbs61r5qc2r3ac1r6db1r3gc1r3h15r3m91r8j91|2258322be245ec223hd247ka222nb244sa2m391652b8c23au45|197hl7jfajfgj9j1lj",
"1f525f00000000000|||",
"1c5376000fdfi0cd1|r3b21r7ba1rcc22r5gc1r7h22rgh12r3lb1rgl12r5qc1|236923c652m|3983c83c63f83i83i63l8",

"6b537a000f7ff0982|r3a21r3e21r3i21r3m41r3q41r9a81r7ea1r7i21rbi21rgi11rgm11r9m51r9q71r6n11r6r11r9b13reb13|22fe3m|ja7jf5jf7jk73kb3fb3ab",
"6b5373000fmfr0865|r3ae1r3fe1r3ke1r3pe1|235a53d543m|3f7j6c3ncj8h3lhj4m3qm",
"5b5373222a7k7fc1d|r5a1ir8a1irba1ire91j|225934e5354589245sc2m|l5gl8glbglfg5jg5mg5pg",
"2c536800099l907d5|saaysalzsdf!sh92r4h92rg811rgr11rga11|3dl474ds423958222573m|3aejkejfhj5j37j4qjkoj",
"1f525f00000000000|||",
"24337400068o8f675|saa1sia2saihsiii|2h5473e6614ah6b2giba3cna348e28227924e733325823o5824n7922kc6649a54|4673972c71f7li7ml7mo7",
"1f525f00000000000|||",
"1f525f00000000000|||",
"6b5f7a00098l8f865|r5bobt6d37c4btb2b|45lc32hld3226924d6422h6424n692|1684985c86f8li8jl8ho8",
"2b53d400065o5faf5|r58q1r3bq1r5eq1r3hq1r5kq1r3nq1r5qq1||7s57p57m57j5",

"1f525f00000000000|||",
"1f525f00000000000|||",
"2ka16400069o936d5|r5b12r6cb1r7g21r7n21|321fs16bb112c31m12j21|7997b97d97f97h97j97l9",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1a52310c07kokfa94|r5aceb6abds883rbg25|321f63273m3ao4b25o564eo3622t91457c3m|26k29k2ck2fk2ik2lk2ok",

"5a53880005fpffef2|r38egb384fb882gbb86freo36|49s8339187224a42b812m|13khrk2ck2fkiik5iflcf",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"2f555h0007fmf0a82|t7934a9|22qr43255n455q81qa542ni422om263ir21|l68l885l85n85jplfplap",
"1f525f00000000000|||",
"8f525a008j8alfad4|t6804aa|3255n32ocb22s824ds422hsc24n692321c74d5432h546458d147a8d|hg5hl9jnb1a917d",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",

"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"3f535a0c0a7k7f6d5|r3ee1r3keab3l34b3q34m||k65k95kc5kf54i54l54o5",
"1f525f00000000000|||",

"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1f525f00000000000|||",
"1k037h2226coc0e82|r7f21rgf11rak21r7p21rgp11r38e1|236a53d645m|33a5ba6ja9ekn257s5"
}

b40="0123456789abcdefghijklmnopqrstuvwxyz!@#$%"
c2int={}

for i=1,40 do
 c2int[sub(b40,i,i)]=i-1
end

function c2arr(s,p,l)
 local a={}
 for i=p+1,p+l do
  add(a,c2int[sub(s,i,i)])
 end
 return a
end
__gfx__
0000000000a0a00000a0a00000a0a00000bba00000a0a000000a0bb00bbbee7eee0bbb00000000000000000000bbbb0000bbbb0000bbbb0000bbbb0000bbbb00
000000000bbbbba00bbbbba00bbbbba00b1bbba00bbbbba00abbebbbbbbb777e771b71b00000000000aaaa000baabbb00bbbbbb00b7aabb00b78bbb00b7bbbb0
00700700b1b1bbb0b1b1bbb0b1b1bbb000bb1bb0b1b7bbb00bbbbebbbbe11110e71bbbba000aa0000abbbba0ba77abb3bbbbbbbbb7aabbb3b7b8bbb3b7bbbb11
00077000b1b1bbbab1b1bbbab1b1bbea000bbbbab7b1bbbaabbbb1bb0ebbbbbbe71b17b000a7ba000ab7bba0ba77abb3bbbbbbbbbbaaaab3bb8e8bb31bbbb1c1
00077000bbbbb1b0bbbbb1b0bbbbbeb00000bbbbbbbbbbe00b71b17eabbb1b7bbb1bbbba00abba000abbbba0bbaabbb3bbbbbbbbbbbaabb3b8eae8b3c1111cc1
0070070001111beb01111ebb01111bbb00000ebb01111ebbabbbb17e0bbb7b1bbbebbbb0000aa0000abbbba0bbbbbbb3bbbbbbbbbbaabbb3b89a98b3ccccccc1
00000000b777bbbbe777bbbbe77ebbbbb777bbebe777bbbb0b17b1770abbbbb0bbbebba00000000000aaaa000bbbbb300bbbbbb00aabbb300b888b300ccccc10
00000000ee7eebb0e7eebbb0be77ebb0ee7eebbbe7eebbb000bbb0ee000a0a000bb0a00000000000000000000033330000bbbb00003333000033330000111100
06666660066666600eeeeee00eeeeee00000000001111110011002000000222220011110000000000000000000cccc0000cccc0000000000000000000cc00000
6766666661616666eeeeeeeee8e8eeee000660001111111111d1d120022011102101551100000000006666000c66ccc00cccccc00000000000000000cccc0000
616166c661616c66e8e8eefee8e8efee00616600151511d1111d112021100000210111110006600006cccc60c6776cc1cccccccc0000000000000000cccc0000
61616c606666c1c0e8e8efe0eeeef1f00056616015151d10111110000d111111210155110067c60006c7cc60c6776cc1cccccccc00000000000000000cc00000
666661c000005050eeeee120000020200e556660111111d01155101201d1515100011111006cc60006cccc60cc66ccc1cccccccc0bb000000cc0000000000000
0000055ee55000000000022ee220000000e5550000000112111110121d1151510211d1110006600006cccc60ccccccc1ccccccccb7bb0000c7cc000000000000
05550ee00ee0555002220ee00ee02220000ee000011102201155101211111111021d1d1100000000006666000ccccc100cccccc0bbbb0000cccc000000000000
eeee00000000eeeeeeee00000000eeee000000002222000001111002011111100020011000000000000000000011110000cccc000bb000000cc0000000000000
0eeeeee000000000088888800000000000000000011111100d1000000666666006060d100ddddd000ddddd000eeeee000eeeee00000000000111110000011110
ee1e1eeb000000008828288e00000000000ee0001151511d11d106060000000660601111dddd7cd0dddd7cd0eeee78e0eeee78e0000dd0001111651001111111
be1e1ebe0eeeeee0e82828e20000000000e1ee00d15151d1111106060666666060601551ddddccd0ddddccd0eeee88e0eeee88e000dcdd001111551015511011
0eeeeee0ee1e1eee0888888008888880000ee1e001111110155106060000000660601111ddddddddd00dddddeeeeeeeee00eeeee005ddcd01001111116510011
70000000ee1e1ebe70000000882828880700eeb060000000111106060111111060601551d000dddd00000ddde000eeee00000eee0d55ddd00000011111110010
07777770beeeeeeb07777770882828e80070000006666660155106061d15151d606011110ddd00dddd0000dd0eee00eeee0000ee00d555001100001111100011
70000000b000000070000000e888888e000770006000000011110606d115151160601d11dddddddd0dddddddeeeeeeee0eeeeeee000dd0000111111111100111
077777700777777007777770e7777770000000000666666001d0606001111110000001d00dd0ddd00dd0ddd00ee0eee00ee0eee0000000000110111001110100
01110110001011100007770000077707000eee00000eee0e00000000000111000100011001dd11ddd0d001000777770007777700000000000000000000000000
111111101110011107777777077777770eeeeeee0eeeeeee00077000011111110111001111111100d01252107777e87077776e70009aa0000008000000888800
11000011110001117222777072227770e222eee0e222eee000727700122211101111111d101d001d11022210767788707677ee7009aa00000008000008888880
1110000001001111082827700828277008282ee008282ee0006772700525211011122d1d0012222011025211700677777006777700aaaa00008e800008888880
111110011100156102222700e222270002222e00e2222e000c6677e0022221001125201101125250d1d221110000077760000777000aa00008eae80008888880
0155111111011551e700e70707007e702e002e0e0e00e2e000c66600d100d1010122201101112221d1111111760000777706007700aa0000089a980008888880
015611111111111000777777c077777700eeeeee20eeeeee000cc000001111110125210d111111101100111007777777077777770aa000000088800000888800
0011111001111000cc77cc700c7cc70722ee22e002e22e0e00000000dd11dd1000100d0d00111000011000100770777000000770000000000000000000000000
eee800008ee8000088880000eeee000088ee000018810000828200008e8e00000000333333330000000033333333300000111110011111000000000000000000
ee8e2000e82e20008eee2000888e200088ee20008fe820002ee82000888820000003333333333000000333333333333001cccc111dcccc100000000000000000
e8ee2200e28e22008eee2200eeee2200ee8822008ee822008ee22200e8e822000bbbbbbb33333300000bbbbbbb3333301c77ccc1dcc77cc10000000000000000
8eee22008ee822008eee22008e882200ee8822001881220028282200eeee2200bb00000bb333333000bb00000bb33300d7ccccc1dc7cccc1beeeeeeeeeeeeeeb
0222220002222200022222000222220002222200022222000222220002222200b0777770b333300000b0707070b33300d7cc6cc1dc7cccc17288888888888827
0022220000222200002222000022220000222200002222000022220000222200b77000770b33000000b70000770b3300dcccccc1dccc6cc1b28880888808882b
0000000000000000000000000000000000000000000000000000000000000000b70707070b33300003b70070770b3300dcccccc1dcccccc1b28888888888882b
000000000000000000000000000000000000000000000000000000000000000030700070888333000337770777033390dc6cccc1dcccc6c1bb280888888082bb
eee8eee88e2e8e2eeeeeee28eeeeeeee88ee88ee8ee88ee88282828288ee88ee38770770888333090300770788033900dccc6cc1dcccccc13b288888888882b3
ee8eee8ee8e2e8e2ee222288888e888e88ee88ee188118812eeeeee8e88ee88e088ffffff83333900ffffff888339000dcccccc1dc6cccc13b288808808882b3
e8eee8ee2e8e2e8ee28888e8eeeeeeeeee88ee88111881118eeeeee288ee88ee03ff0fffff393300fff0ffff89330000dcccccc1dcccccc13bb2888888882bb3
8eee8eeee2e8e2e8e28828e88e888e88ee88ee88818fe8182ee82ee8e88ee88e03ff0fff99903380ffffff99903330001dcccc111dcccc1003b2880880882b30
eee8eee88e2e8e2ee28228e8eeeeeeee88ee88ee818ee8188ee28ee288ee88ee003fff3f900338800f3f3f9003333000011111101111110003bb22888822bb30
ee8eee8ee8e2e8e2e28888e8888e888e88ee88ee111881112eeeeee8e88ee88e003833309933888088333099333380000004440000444000003bbb2222bbb300
e8eee8ee2e8e2e8e28eeee88eeeeeeeeee88ee88188118818eeeeee288ee88ee00888833003888000888330033338000000ff40000ff400000033bbbbbb33000
8eee8eeee2e8e2e8888888888e888e88ee88ee888fe88fe828282828e88ee88e08888880330000000008803333880000000ff40000ff40000000033333300000
0c0000c000c00c000a0000a00a0000a0000000000d0000d0001110022200002220011100000ee000000ee0000008800000088000000000000001100000220022
000000000000000000a00a0000a00a000006c00000d00d00d0011102001001002011100d00ee2e0000e2ee000088780000878800000e20000011c10000211112
e066660e00666600909999090099990000616600101111010d15511001111110011551d0aae2eeaaaaee2eaaee8788eeee8878ee00eee200221c112201115510
66166166061661609489989909899890005661c011511511001111001151151100111100aeeeeeeaaeeeeeeae888888ee888888e00e1eee0211111121c111110
6616616666166166998998999989989908006660115115110011110011511511001111000e1ee1e00e1ee1e008288280082882800aee1ea00151151011c11110
06666660e060060e092222909090090900805500011111100d15511010111101011551d00e1ee1e00e1ee1e0082882800828828000eeee000151151001115510
0060060006066060009009000e0220e00008800000100100d001110200d00d002011100daaeeeeeaaeeeeeaaee88888eee88888e000aa0002211111200211122
880000880880088088000088088008800000000022000022001110020d0000d020011100aa0000aaaa0000aaee0000eeee0000ee000000002200002200220022
22000022220022000bbbb3000bbbb3000888880008888800000000000111110000109102222200000021111006666660556556600eeeeee022e22ee000000000
2111112222111200bffffb30bffffb308ffff8808ffff880000bb00010000110011191120129122002005501556556666161666622e22ee2e8e8eeee00066000
0151151001551110b1f1ffb3b1f1ffb381f1ff8881f1ff8800b1fb00150500111101192211990002020100016161668661616666e8e8eefee8e8eeee00816600
0151151001111c11b1f1fb30b1f1fb3981f1f88081f1f88900fff1b0150501101000299299120101010055016161688686668886e8e8effefeeefffe00566160
21111112011111c1bf1f8399bf1fb3938f1f28998f1f8898080fffb0101021991055001001105051299200018666688081118880feeeeff0f111fff00a006660
2211c122015511108fff993303ff89382fff998808ff29820080f900200099111000102011005051229110118811166aa6601110ff111eeaaee0111000a05800
001c11002111120008839830833398800228928028889220000880000221921010550020011000012119111006660aa00aa066600eee0aa00aa0eee0000aa000
0001100022002200000088880880000000002222022000000000000000002222011112000011111020190100aaaa00000000aaaaaaaa00000000aaaa00000000
011111100111020000002222202211500088880000ffff0000aaaa0000bbbb0000cccc0000dddd000000000000000000000000000003bb000000000000000000
55155111112221200220111021210051087888800f7ffff00a7aaaa00b7bbbb00c7cccc00d7dddd000000000000000000003300000433bb00000000000002840
1010112111122120211000222101111187111888f71f1fffa7111aaab7111bbbc711ccccd711dddd00000000000000040443b990094a33300000000000e524b3
1010122115111000022111122101005188188888ff1f1fffaaa1aaaabb1bbbbbcc1c1cccdd1d1ddd0000000000000004449999f99aaaaaf03e8808e30022f80b
2111122015001012122101010001115188118888fff1ffffaaa1aaaabb11bbbbcc1c1cccdd1d1ddd00088000490000fa44999ff99aaaaaaf37888073e2f88800
2200011211111012121101010212211188188888ff1f1fffaaa1aaaabb1bbbbbcc1c1cccdd1d1ddd008a98009a9ffaa9449999949aaaaaaf37eeee73228825e2
01110220150012121115515502122211081118800f1f1ff00aa1aaa00b111bb00c1c1cc00d111dd00089980009aaaa900449994009aaaaa003777730f8e2f822
222200000511220201111110002011100088880000ffff0000aaaa0000bbbb0000cccc0000dddd0000088000009999000044440000999a000033330088228800
00b00b000000000000000000000bb00000000030000000001cc11cc109f99990000f80004992499000888800004fff000000000000ffff000077770000000000
0b0bb0b0000000000000000000823b20000002b300003bb07ccc7cccf999f9f90ee88ee0444244400827828004ff4ff0000000d00f7ffff00777777004444ff0
0043b40000fe200000dc1000088b3b8000002222000b0300ccc5ccc588888888e8ee8ee82220222008f882804ff4ff4f76666d67f7ffffff077777704444f8ef
049494400feee2000dccc100088288800222e22200303000ccc5ccc5baaaaaabee8ee8ee4992499008288280777777770768b670ffffffff77a99a774244f88f
04994940ffeee220ddccc11008828880227e222208208200ccc5ccc5444aa444888888884442444008288280087878700073370000044400779999774442f87f
04949440022d5500011d5500028288202722222087820820cccccccc4444444407f7f7f022202220088888800878787000077000000fff00779999772444f88f
04999940002d5000001d500002882820222222008882082004400440999999990f9f9f904992499000022000087878700007700000ffff0007a99a702222f8ef
0044440000020000000100000022020002222000022082000ff00ff0099999900f9f9f9044424440000ff00002f2f2f00077770000fff0000077770002222ff0
000887700028820000000000000000000099400000ccc00000000000000cc0000000000000000000000000000000000000807080807080090000067777600000
0078877700820820000000000000000009a9940000c8c00000000000000000000490000000000940009900000000990008000809080908000006770000776000
07777777b0282820f000000fa00000099a999940ccc8ccc000000000000cc000099990000009999009449000000944908e808e808e808e800077000000007700
7777777700028200ef0fe0ee9a0a909a99999940c88a88c00887000000c9ac0000944900009449000944490000944490eae8eae8eae8eae80700077000000070
4ff44ff400282000f0fe0f0fa0a90a09000c0000ccc8ccc0811178800c9abbc00094449009444900009449000094490000000000000000000700700000000070
f44ff44f028200b0e0e0fe0e9090a90a000c000000c8c000788888880cbba9c00009449009449000000999900999900000000000000000007000000000000007
444444442820b000fe0fe0efa90a90990909000000c8c000177888870caa9bc00000990000990000000009400490000000000000000000007070000000000007
f777777fc2000000e000000e9000000a0090000000ccc0000117777000cccc000000000000000000000000000000000000000000000000007070000000000007
0000000000000000000000000000000000000000aaaaaaaa99999999aaaaaaaa999999999999999994aaaaaaaaaaaaf994aaaaaaaaaaaaf97000000000000007
0000033330333300333003333000003333000000aaaaaaaa44444444aaaaaaaa944444444444444994aaaaaaaaaaaaf994aaaaaaaaaaaaf97000000000000007
00003bbbb3bbbb33bbb33bbbb30003bbbb300000aaaaaaaaaaaaaaaaaaaaaaaa94aaaaaaaaaaaaf994aaaaaaaaaaaaf994aaaaaaaaaaaaf97000000000000007
0003bb0bb33bb30bb333bb0bb33303b00b300000aaaaaaaaaaaaaaaaaaaaaaaa94aa79aaaa79aaf994aaaaaaaaaaaaf994aa79aaaa79aaf90700000000000070
0003bbbbb33bb30bb303bb0bb3bb3bbbbb300000aaaaaaaaaaaaaaaaaaaaaaaa94aa99aaaa99aaf994aaaaaaaaaaaaf994aa99aaaa99aaf90700000000000070
0003bb33303bb30bb333bb0bb3333bb00b300000aaaaaaaaaaaaaaaaaaaaaaaa94aaaaaaaaaaaaf994aaaaaaaaaaaaf994aaaaaaaaaaaaf90077000000007700
0003bb3003bbbb3bbbb3bbbb30003bbbbb300000aaaaaaaaaaaaaaaaffffffff94aaaaaaaaaaaaf994aaaaaaaaaaaaf994fffffffffffff90006770000776000
0000330000333300333033330000033333000000aaaaaaaaaaaaaaaa9999999994aaaaaaaaaaaaf994aaaaaaaaaaaaf999999999999999990000067777600000
0b0b00000000aaaa0000000000000c00bbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000aaaaa000aaa00aa0aaaaa000aaaaa000aaa00000aaaaaaa00000
b0b0b00000aaaaaaaa000000000cc000bb000bbbbb000000bb0000bb0000000000000000000a11111a0a111aa11a11111a0a11111a0a111a000a1111111a0000
b000b0000aaaaaa000a0000000cccc00bb0000bbbbbbbbb0bb0000bb0000cccc0000000000a1eeeee1a1eee11ee1eeeee1a1eeeee1a1eee1a0a1eeeeeee1a000
0b0b00000aaaaa00000a000000cc0c00bb0000bb0bbbbbbbbb0000bb00ccc00ccc00000000a1e7e1ee11e7e11ee1e7e1ee11e7e1ee11e7e1a0a1e7e11ee1a000
00b00000aaaaaa00a000a000000cc000bb0000bb000000bbbb0000bb0cc00cccccc0000000a1efe1ee11efe11ee1efe1ee11efe1ee11efe1a0a1efe1111a0000
00000000aaaaaa00a000a0000cccccc0bb0000bb000000bbbb0000bb0c0ccccc00cc000000a1eeeee111eee11ee1eeeee111eeeee111eee1aaa1eeee1aa00000
00000000aaaaaaa00000a00000cccc00bb0000bbbbbbbbbbbbbbbbbbcc0cccc0c00cc00000a1eee11e11eee11ee1eee11e11eee11e11eee1a111eeee111a0000
00000000aa0aa0aa000aaa0000cccc00bb0000bbbbbbbbb00bbbbbb0ccccccc0c00cc00000a1eee11ee1eee11ee1eee11ee1eee11ee1eee11ee1eee11ee1a000
03330000a00000aaaaa0aa0a00000000000000000000000000000000cccccccc00cccc0000a1eeeeeee1eeeeeee1eeeeeee1eeeeeee1eeeeeee1eeeeeee1a000
330330000000000a0aa0aaaa000000000000000000000000000000eec0000ccccccccc0000a1eeeeee11eeeeeee1eeeeee11eeeeee11eeeeeee1eeeeeee1a000
303030000a0aa0000aa0aaaa0000000000000000000000000000eeee000000cccccccc00000a111111aa1111111a111111aa111111aa1111111a1111111a0000
330330000aaaa0aa000aaaa0000000000000000000000000000eeeee00000000cccccc000000aaaaaa00aaaaaaa0aaaaaa00aaaaaa00aaaaaaa0aaaaaaa00000
0333000000aaaaaa0aaaaaa000000000000000000000000000eeeeee0cccc00000ccccc0000a11111aaa1111111a11111a0a11111a0a111a000a1111111a0000
00000000000aaaaaaaaaa00000000000000000000000000000eeeeee00cccccccccccccc00a1eeeee1a1eeeeeee1eeeee1a1eeeee1a1eee1a0a1eeeeeee1a000
000000000000aa0000aa00000000000000000000000000000eeeeeee00cccccccccccccc00a1e7e1ee11e7e11ee1e7e1ee11e7e1ee11e7e1a0a1e7e11ee1a000
0000000000000000000000000000000000000000000000000eeeeeee0cccc00cccc0000000a1efe1ee11efe11ee1efe1ee11efe1ee11efe1a0a1efe1111a0000
033000000eeeee0000d0000000ddd000000dd000000000000eeeeeee000000000000000000a1eeeee111eee11ee1eeeee111eeeee111eee1aaa1eeee1aa00000
30330000eeeeeee000dd00000dddd0000dd00dd0000000000eeeeeee000000000000000000a1eee11e11eee11ee1eee11e11eee11e11eee1a111eeee111a0000
33330000ee000ee0ddddd000ddddd0000d0000d00000000000eeeeee000000000000000000a1eee11ee1eee11ee1eee11ee1eee11ee1eee11ee1eee11ee1a000
03333000ee000ee00dddd00000dd00000d0000d00000000000eeeeee000000000000000000a1eeeeeee1eeeeeee1eeeeeee1eeeeeee1eeeeeee1eeeeeee1a000
00333000000eeee000ddd00000d000000dd00dd000000000000eeeee000000000000000000a1eeeeee11eeeeeee1eeeeee11eeeeee11eeeeeee1eeeeeee1a000
0003330000eee0000000000000000000000dd000000000000000eeee0000000000000000000a111111aa1111111a111111aa111111aa1111111a1111111a0000
0000330000eee00000000000000000000000000000000000000000ee00000000000000000000aaaaaa00aaaaaaa0aaaaaa00aaaaaa00aaaaaaa0aaaaaaa00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99990000000099999999999900000000999900000000999999999999000000009999000000009999999999990000000099990000000099999999999900000000
99990000000099999999999900000000999900000000999999999999000000009999000000009999999999990000000099990000000099999999999900000000
99990000000099999999999900000000999900000000999999999999000000009999000000009999999999990000000099990000000099999999999900e0e000
999900000000999999999999000000009999000000009999999999990000000099990000000099999999999900000000999900000000999999999999000e0000
00000000000000000000000099990000999900009999000099990000000099990000999900009999000099999999999999999999999999999999999900e0e000
00000000000000000000000099990000999900009999000099990000000099990000999900009999000099999999999999999999999999999999999900000000
00000000000000000000000099990000999900009999000099990000000099990000999900009999000099999999999999999999999999999999999900000000
00000000000000000000000099990000999900009999000099990000000099990000999900009999000099999999999999999999999999999999999900000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888882282288882288228882228228888888ff888888228888
888882888888888ff8ff8ff88888888888888888888888888888888888888888888888888888888888228882288822222288822282288888ff8f888888222888
88888288828888888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888ff888f888888288888
888882888282888ff8ff8ff888888888888888888888888888888888888888888888888888888888882288822888222222888888222888ff888f888822288888
8888828282828888888888888888888888888888888888888888888888888888888888888888888888228882288882222888822822288888ff8f888222288888
888882828282888ff8ff8ff8888888888888888888888888888888888888888888888888888888888882282288888288288882282228888888ff888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
555555e555566556665555e555555555555665666566555506600606000055555555555555555555565555665566566655506660666000055066606660000555
55555ee555556556565555ee55555555556555656565655500600606000055555555555555555555565556565656565655506060606000055060606060000555
5555eee555556556665555eee5555555556665666565655500600666000055555555555555555555565556565656566655506060606000055060606060000555
55555ee555556556565555ee55555555555565655565655500600006000055555555555555555555565556565656565555506060606000055060606060000555
555555e555566656665555e555555555556655655566655506660006000055555555555555555555566656655665565555506660666000055066606660000555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555566666566666577777566666555555588888888566666666566666666566666666566666666566666666566666666566666666555555555
55555665566566655565566565556575557565656555555588877888566666766566666677566777776566667776566766666566766676566677666555dd5555
5555656565555655556656656665657775756565655555558878878856667767656666776756676667656666767656767666657676767656677776655d55d555
5555656565555655556656656555657755756555655555558788887856776667656677666756676667656666767657666767657777777756776677655d55d555
55556565655556555566566565666577757566656555555578888887576666667577666667577766677577777677576667767567676767577666677555dd5555
55556655566556555565556565556575557566656555555588888888566666666566666666566666666566666666566666666567666667566666666555555555
55555555555555555566666566666577777566666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555005005005005005dd500566555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555565655665655555005005005005005dd5665665555555dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd555555555
555565656565655555005005005005005775665665555555dddddddd5d55ddddd5dd5dd5dd5ddd55ddd5ddddd5dd5775777775dddddddd5dddddddd555555555
555565656565655555005005005005665775665665555555dddddddd5d555dddd5d55d55dd5dddddddd5dddd55dd57755777755d5d5d5d5d55dd55d555555555
555566656565655555005005005665665775665665555555ddd55ddd5dddd555d5dd55d55d5d5d55d5d5ddd555dd57755577755d5d5d5d5d55dd55d555555555
555556556655666555005005665665665775665665555555dddddddd5ddddd55d5dd5dd5dd5d5d55d5d5dd5555dd5775555775dddddddd5dddddddd555555555
555555555555555555005665665665665775665665555555dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00ccc00ddd005507700000066600eee00ccc00ddd005500770707066600eee00ccc00ddd005507700707066600eee00ccc00ddd00555
55507000000000600e0e00c0000d00005507070000000600e0e0000c00d00005507000777000600e0e00c0000d00005507070777000600e0e00c0000d0000555
55507700000066600e0e00ccc00ddd005507070000066600e0e000cc00ddd005507000707066600e0e00ccc00ddd005507070707006600e0e00ccc00ddd00555
55507000000060000e0e0000c0000d005507070000060000e0e0000c0000d005507070777060000e0e0000c0000d005507070777000600e0e0000c0000d00555
55507770000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507770707066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005501111111aaaaa1111111111111110555
55507700000066600eee00ccc00ddd005500770000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507711717a666a1eee11cc111ddd10555
55507070000000600e0e00c0000d00005507000000000600e0e0000c00d00005507070000000600e0e00c0000d00005507171777aaa6a1e1e111c111d1110555
55507070000006600e0e00ccc00ddd005507000000066600e0e000cc00ddd005507770000066600e0e00ccc00ddd005507171717aa66a1e1e111c111ddd10555
55507070000000600e0e0000c0000d005507000000060000e0e0000c0000d005507070000060000e0e0000c0000d005507171777aaa6a1e1e111c11111d10555
55507770000066600eee00ccc00ddd005500770000066600eee00ccc00ddd005507070000066600eee00ccc00ddd005507771717a666a1eee11ccc11ddd10555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005501111111aaaa11111111111111110555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000171000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000177100000000000000555
55500770000066600eee00ccc00ddd005507770000066000eee00ccc00ddd005507770000066600eee00ccc00ddd00550770070706617771e00c0c00ddd00555
55507000000000600e0e00c0000d00005507070000006000e0e0000c00d00005507070000000600e0e00c0000d0000550707077700017777100c0c00d0000555
55507000000006600e0e00ccc00ddd005507700000006000e0e000cc00ddd005507700000066600e0e00ccc00ddd00550707070700617711e00ccc00ddd00555
55507000000000600e0e0000c0000d005507070000006000e0e0000c0000d005507070000060000e0e0000c0000d00550707077700061171e0000c0000d00555
55500770000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507770707066600eee0000c00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00ccc00ddd005507770000066000eee00ccc00ddd005500770000066600eee00ccc00ddd005507700707066600eee00cc000ddd00555
55507070000000600e0e00c0000d00005507070000006000e0e0000c00d00005507000000000600e0e00c0000d00005507070777000600e0e000c000d0000555
55507700000066600e0e00ccc00ddd005507770000006000e0e000cc00ddd005507000000006600e0e00ccc00ddd005507070707006600e0e000c000ddd00555
55507070000060000e0e0000c0000d005507070000006000e0e0000c0000d005507000000000600e0e0000c0000d005507070777000600e0e000c00000d00555
55507770000066600eee00ccc00ddd005507070000066600eee00ccc00ddd005500770000066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00c0c00ddd005500770000066000eee00ccc00ddd005507770000066600eee00ccc00ddd005507700707066600eee00ccc00ddd00555
55507070000000600e0e00c0c00d00005507000000006000e0e0000c00d00005507070000000600e0e00c0000d00005507070777000600e0e0000c00d0000555
55507770000066600e0e00ccc00ddd005507000000006000e0e00ccc00ddd005507770000066600e0e00ccc00ddd005507070707006600e0e000cc00ddd00555
55507070000060000e0e0000c0000d005507070000006000e0e00c000000d005507070000060000e0e0000c0000d005507070777000600e0e0000c0000d00555
55507070000066600eee0000c00ddd005507770000066600eee00ccc00ddd005507070000066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500770000066600eee00c0c00ddd005507770000066000eee00ccc00ddd005507770000066600eee00ccc00ddd005507700707066600eee00cc000ddd00555
55507000000000600e0e00c0c00d00005507000000006000e0e0000c00d00005507070000000600e0e00c0000d00005507070777000600e0e000c000d0000555
55507000000066600e0e00ccc00ddd005507700000006000e0e00ccc00ddd005507700000066600e0e00ccc00ddd005507070707006600e0e000c000ddd00555
55507070000060000e0e0000c0000d005507000000006000e0e00c000000d005507070000060000e0e0000c0000d005507070777000600e0e000c00000d00555
55507770000066600eee0000c00ddd005507000000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00c0c00ddd005507770000066000eee00cc000ddd005500770000066600eee00ccc00ddd005507700707066600eee00ccc00ddd00555
55507000000000600e0e00c0c00d00005507000000006000e0e000c000d00005507000000000600e0e00c0000d00005507070777000600e0e0000c00d0000555
55507700000066600e0e00ccc00ddd005507700000006000e0e000c000ddd005507000000006600e0e00ccc00ddd005507070707006600e0e00ccc00ddd00555
55507000000060000e0e0000c0000d005507000000006000e0e000c00000d005507000000000600e0e0000c0000d005507070777000600e0e00c000000d00555
55507000000066600eee0000c00ddd005507770000066600eee00ccc00ddd005500770000066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600eee00c0c00ddd005507700000066000eee00cc000ddd005507700000066600eee00ccc00ddd005507700707066600eee00cc000ddd00555
55507000000000600e0e00c0c00d00005507070000006000e0e000c000d00005507070000000600e0e00c0000d00005507070777000600e0e000c000d0000555
55507700000066600e0e00ccc00ddd005507070000006000e0e000c000ddd005507070000006600e0e00ccc00ddd005507070707006600e0e000c000ddd00555
55507000000060000e0e0000c0000d005507070000006000e0e000c00000d005507070000000600e0e0000c0000d005507070777000600e0e000c00000d00555
55507770000066600eee0000c00ddd005507770000066600eee00ccc00ddd005507770000066600eee00ccc00ddd005507770707066600eee00ccc00ddd00555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
fff7fdfefffaf0f4f9f9faf8f9f2f4f4fe00fdf1fef0fef3f7fef1fef0000000fef7fbf4fef9f7f3f4fbf4fbfafe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f7f6fefaf9fdfffcfdf9f9f9f9f2f0f3fefdf000fe00fefaf6fe00fe00000000fefbf3f4fef9f7fbf4fbf4fbfafe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f2fafefa000000000000000000000000fefaf300fe00fe0000fe00fe00000000fefbfbfcfbfdfdfefcfbfcfefdfe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffff0ff000000000000000000000000fe00faf7fef3fe0000fef7fef3000000f7fbf4fbf9f7f7f9f7fdf7f5f4f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f4f6f4f6f4f6f9faf9faf9f800000000000000000000000000000000000000f9f3f4fbf9f9f9f9f7fdf7f5fcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f0fcf4f6f0fcf9fdf9f8f9f900000000000000000000000000000000000000fbfbfcfefdfdfdfdfbfdfdfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff3f3f3f3f3f3f3f3f3f3f3f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fbf3f9f4f7f3f900fefefef6f2fefaf6f6f2fafefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f1f00000f100fefefef4f2fdf9f4f4fef9fefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f2f0f1f2f2f000fefefef4fef9f1f0f4fef9fefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000fef2fefafefaf6faf6fef6f6f6fe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f4f2f9f9f9f9f1f0f4f2f0f4f4fe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f4fef9f1f1f9f9f4fef4fef6f6fe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffffff5f3ffffff0000fffffffff5f3ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffff9fbfdfbffff0000fffff7fbf8f8fbffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff7f2f2f2f2f2f2f2f3ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffff6f8fefefefefcff0000f7fdfef4f4f4fefefbff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff9f7f2fffffffffff4ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffff8fefef6f7f8f1f40000f6f8fafef5fdfef8f2f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff9f7f3f7f3fff7f2f2f80000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff6fafefef4f9f9fff40000f8f5fdf6fef6fef5fbf00000fffbf6fcffff0000f6f2fa0000000000000000000000000000000000000000000000000000000000000000000000000000000000fff9f9f4f9f4fff9f1f6f90000000000fffffffffff700000000000000000000fffffffffb000000fff7fe000000000000000000
fff1fdfefefafbfcfdf40000fff7fef6fef6fefcffff0000f9f0fff1fcff0000f4fef90000000000000000000000000000000000000000000000000000000000000000000000000000000000fff9fbfbfbf3f5f8f0f3f80000000000fffffffff7fd00000000000000000000fffffffdfe000000f7fefb000000000000000000
fff6f6fff9fbfbfbfbff0000fffdfef4fef4fefef3ff0000f6fffffff1ff0000fcfffd0000000000000000000000000000000000000000000000000000000000000000000000000000000000fffbfbfbfbf5fff9f1f2f90000000000fffffffdfafc00000000000000000000f3fffdfefe000000f9fefe000000000000000000
f7f1f4fffdf6fffff8ff0000f9f2f5fefefef6f5faff0000fcffffffffff0000fefffd0000000000000000000000000000000000000000000000000000000000000000000000000000000000fff4fffffffffffff2f6f00000000000f7fff7fef3f600000000000000000000f4f7fefefe000000f1fefe000000000000000000
f1fefefef6f8fff7f2f30000f1fbf0f1f2f2fff8f5ff0000f9f3ffffffff0000fefbfd000000000000000000f7fbf3f4fbfbf3f4fbfbf9f4f4000000f4f9f9fff1f6f9f2f9f2f9f9f9000000fbf8fbfbfbfbfbfbfbf0ff0000000000f9f3f9fef0f80000fffffffff7f00000f4f9fefefe000000fff1fa000000000000000000
fff1f2fafbfbf6fafbf50000000000000000000000000000fffcffffffff0000000000000000000000000000f1f2f2f4fefef4f4f2f2faf4f4000000f6faf9f1f0f4f9f2f9fff9faf1000000f8fbfbfbf5fbfbf0f8fbf30000000000f9fcf3f1fafd0000fffff3f7f1f30000fffffafefe000000fffff4000000000000000000
000000000000000000000000000000000000000000000000fff1fcffffff0000000000000000000000000000fafef4f4fefef4f6fefef9fcfc000000f0f1f1fffff0f1f2f1f2f1f1f1000000fffffffffff8fbfbfbfbf00000000000f1fefefffbff0000fff3f1fff0ff0000fbfffff2fa000000fffff4000000000000000000
00c9cacbcccdcecf00000000000000000000000000000000fffff1fcffff0000000000000000000000000000fbfbfbfcfbfbfbfcfbfbfdfcfc0000000000000000000000000000000000000000000000000000000000000000000000fff1fefff9ff0000fffffdf9fef40000fafcfffff1000000fffdf4000000000000000000
00d9dadbdcdddedf00000000f6f2faf2f2fef2faf6f2fafefffffff1fcff0000f7faf9f9f7faf7faf9fef7fdfbfbfbfbfbfbfbfbfbfbfbfbfb000000fff3fafff3f9fff3f9fff4f9fffbfe00f7f3f4fef9f7fbf4f2f9f9f9f9000000fffff9fcf3ff0000f7fffaf9fef40000f1fef3fffb000000f9f0f4000000000000000000
00e9eaebecedeeef00000000fff0f9f4f9f4f9fefff4f9fefffffffff1ff0000f1fdf9f9f1fdf1fdf9fef1fa00000000000000000000000000000000fff3fafff4f9fff4f9fff4f9fbfffe00f1f0f4f2f9f1f2f4fef9fafafa000000fffffffafefe0000f8f8ffffffff0000fffffffff2000000f9f3f1000000000000000000
0000b0b1b2b3b40000000000fffefef0f1f4f1fafff0f9fe0000000000000000f9f9f9f9f9f9f9f9f9fef9fe00000000000000000000000000000000fbfbfefbfbfdfbfcfdfbfbfdfbfbfe00fefefefefefefefefefefefefe000000fffffff1fefe00000000000000000000fffffffcfb000000fff2ff000000000000000000
000000000000000000000000fefefefefefefefefefefefe0000000000000000fbfefbfefbfefbfefbfdfbfd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff1f2000000000000000000000000000000000000000000000000000000000000
__sfx__
010400001832018331183412435230312003000030000300183201833118341243523031200300003000030018320183311834124352303120030000300003001832018331183412435230312003000030000300
0101000016714177100c7201a7301c7301f73021730237301a7301d7302273036720357103f71526700287002a7002d70032700367003c7003f70025700277002a7002c7002e7003270035700397003d70000700
00010000085101051014510185101b5101d5101d5101d5101d5101d5101b51018510145100f5100d5100a5100951008510095100a5100e51012510165101d510235102c5002e5003250035500395003d50000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000017500165001550014500135001250217502125031750315503135031150017500155001350011506105061050610506105061050610506105061050610506105061050610506105061050610506105
010200000a5170b517085270e537105371353715537175370e5371153716537225271d5171751710557285072a5072d50732507365073c5073f50725507275072a5072c5072e5073250735507395073d50700507
0101000017745177451674514745117350e7350a7350672502725007150b705007050770504705017050070500705007050070501705017050270502705157051370514705167051770518705197051b7051d705
010400001657511575095750457515565125650b565085650456500565125550c5550455500555105450d5450654502545005450d535095350353500535005350952505525015250052506515045150051500515
010200002f2662d25629246262362422621216122060f20623236212361d2361a21618216152161e2061d20623526215261d5261a5161851615516232062120623716217161d7161a71618716157161220610206
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e0000136451362513615136153c6251b5051f6251b505376050f505136351b5053c6251b505186151b505136451362513615136153c6251b5051f6251b505376050f505136351b5053c6251b505186151b505
010700000f5450f5250f5450f5251b5451b5251b5451b5250f5350f5150f5350f5151b5351b5151b5351b5150f5250f5150f5250f5151b5251b5151b5251b5150f5150f5050f5150f5050f5150f5050f5151b505
010700000a5450a5250a5450a525165451652516545165250a5350a5150a5350a515165351651516535165150a5250a5150a5250a515165251651516525165150a5150a5050a5150a50516515165051651516505
010700000c5450c5250c5450c525185451852518545185250c5350c5150c5350c515185351851518535185150c5250c5150c5250c515185251851518525185150c5150c5050c5150c50518515185051851518505
010700000554505525055450552511545115251154511525055350551505535055151153511515115351151505515055050551505505115151150511515115050550505505055050550511505115051150511505
010e00003002430032300423004230032300112d0412d0422d0422d0422d0422d0422d0322d0322d0222d0122f0412f0322f0422f0422f0322f01230042300423004230042320423204132031320323202232012
010e00003405532055300552f0552d0452b0452904528045260352403523035210351f0251d0251c0251a02523055230452303523025230152301523015230152301523015230152301523015230152301523015
010e00001c055260552405523055210451f0451d0451c0451a0351803517035150351302511025100150e01520075210752307524075210652306524055260552026521265232552425521245232352422526215
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000297752977529755297552974529735297252972529715297152b7752b7752b7552b7552b7452b7352b7252b7252b7152b7152d7752d7752d7552d7552d7452d7352d7252d7252d7152d7152d7052d715
010700003a5523a5323a5223a51539552395323952239515375523754237532375223751237515355523553539552395323952239515375523753237522375153555235532355223551533552335323352233515
0107000037552375323752237515355523553235522355153355233525325523253232522325153555235542355323552235512355153550235512355023551500502005021a5020050232552325253055230525
010700002e5522e5322e5222e51530552305323052230515325523253232522325153355233532335223351530552305323052230515325523253232522325153355233525355523554235532355223552235515
010700003555235532355223551537552375323752237515395523952537552375323752237515355523554235532355223552235515355523553235522355153755237532375223751539552395323952239515
01070000355523553235522355153755237532375223751539552395253555235542355323552235512355123a5523a5323a5223a515355523553235522355153755237532375223751538552385323852238515
0107000039552395323952239515293222934129332293222b3222b3412b3322b3222c3222c3412c3322c3222d3322d3412d3322d322355523553235522355153755237532375223751539552395323952239515
010700003a5523a5323a5223a515293222934129332293222b3222b3412b3322b3222d3222d3412d3322d3222e3222e3412e3322e322355523553235522355153755237532375223751539552395323952239515
010700003c5523c5323c5223c512293222934129332293222b3222b3412b3322b3222d3222d3412d3322d32230322303413033230322355523553235522355153755237532375223751539552395323952239515
010700003e5523e5323e5223e515293222934129332293222b3222b3412b3322b3222d3222d3412d3322d322323223234132332323223a5523a5323a5223a5153c5523c5323c5223c5153e5523e5323e5223e515
010700003f0523f0323f0023f0123f0523f0323f0223f012330023f012000003f0123f0523f0323f0223f012320023f012000003f0123e0523e0323e0023e0123c0523c0323c0223c012320023c012320023c012
010700003e7523e7423e7323e7323e7223e7223e7123e712327023e712007003e715327023e702007003e70232702007000070000700327020070000700007003e7523e7423e7323e7323e7223e7123e7023e712
010700003c7523c7423c7423c7323c7323c7223c7123c712377023c712007003c7153775237742377423773237732377223771237712007003771200700377153e7523e7323e7223e712327023e712007003e715
010700003c7523c7423c7423c7323c7323c7223c7223c712007003c712007003c7120070000700007000070000700007000070000700357523573235722357153775237732377223771538752387323872238715
010700003c7523c7423c7423c7323c7323c7223c7223c712375023c712000003c71535552355323552235512375023551200000355153e5523e5323e5023e5153c5523c5323c5023c5153e5523e5323e5023e512
010700003a7523a7423a7423a7323a7323a7223a7223a712357023a712007003a7150070000700007000070037702007000070000700355523553235522355153755237532375223751539552395323952239515
010900001177211772117521175211742117321172211722117121171513772137721375213752137421373213722137221371213715157721577215752157521574215732157221572215712157122d70215715
010700000a7500a7300a71000700167501673016710007000a7500a7300a71000700167501673016710007000a7500a7300a71000700167501673016710007000a7500a7300a7100070016750167301671000700
010700000775007730077100070013750137301371000700077500773007710007001375013730137100070007750077300771000700137501373013710007000775007730077100070013750137301371000700
01070000057500573005710007001375013730137100070014750147301471000700157501573015710007000a7500a7300a71000700167501673016710007000a7500a7300a7100070016750167301671000700
010700000975009730097100c700157501573015710007000975009730097100c700157501573015710007000975009730097100c700157501573015710007000975009730097100c70015750157301571000700
010700000975009730097100070015750157301571000700097500973009710007001575015730157100070009750097300971000700157501573015710007000975009730097100070015750157301571000700
010700000a7500a7300a71000700167501673016710007000a7500a7300a71000700167501673016710007000a7500a7300a7100070011750117301171000700187501873018710007001a7501a7301a71000700
01070000037500373003710007000f7500f7300f71000700037500373003710007000f7500f7300f71000700037500373003710007000f7500f7300f71000700037500373003710007000f7500f7300f71000700
01070000007500073000710007000c7500c7300c71000700007500073000710007000c7500c7300c71000700007500073000710007000c7500c7300c71000700007500073000710007000c7500c7300c71000700
010700000575005730057100070011750117301171000700057500573005710007001175011730117100070005750057300571000700117501173011710007001375013730137100070014750147301471000700
010700000a7500a7300a71000700167501673016710007000a7500a7300a71000700167501673016710007000a7500a7300a71000700117501173011710007001375013730137100070015750157301571000700
010700002776527765277552775527745277452773527735277252772527715277152776527755277552774527735277252772527715267652675526745267352476524755247552474524745247352472524715
010700002676526755267452673527765277552774527735277652775527745277352976529755297452973522765227552274522735227252272522715227152271522705227152270522715227052270522705
010700002476524765247552475524745247452473524735247252472524715247151f7651f7551f7451f7351f7251f7251f7251f7151f7151f7051f7151f7052676526755267452673526725267252671526715
010400002476224765247622476524752247552475224755247422474524742247452473224735247322473524722247252472224725247222472524722247252472224725247222472524712247152471224715
0108000033055330322e0552e0322b0552b03227055270322e0552e0322b0552b0323305533032270552703233055330322e0552e0322b0552b03227055270322e0552e0322b0552b03233055330322705527032
010800002e0552e032290552903226055260322205522032290552903226055260322e0552e03222055220322e0552e032290552903226055260322205522032290552903226055260322e0552e0322205522032
01100000215551d555215551d555215551d5551f55521555225551f555225551f555225551f55521555225552455521555245552155524555215552255524555225551f555225551f555225551f5552155522555
011000000503511055050351105505035110550503511055070351305507035130550703513055070351305509035150550903515055090351505509035150550a035160550a035160550a035160550a03516055
010e0000091550912515155151250c1350c1251013510115091550912515155151250c1350c12510135101150415504125101551012507135071250b1350b1150415504125101551012507135071250b1350b115
010e00000e1550e1251a1551a125111351112515135151150e1550e1251a1551a1251113511125151351511510155101251c1551c1251313513125171351711510155101251c1551c12513135131251713517115
010e00000e1550e1251a1551a125111351112515135151150e1550e1251a1551a12511135111251513515115091550912515155151250d1350d12513135131150915509125111551112509135091251013510115
010e00000c1750c1251817518125101651012513135131150c1750c12516175161251516515125111351111510175101251317513125151651512517135171151017510125161751612515165151251313513155
010e0000243752434524345243352434524325213652133521345213352134521325213452132521325213152336523335233452333523355233251f3451f3351f3351f3151f3551f3151a3551a3150e3350e315
010e00001d0751d0551d0451d0350c0550c0251f0751f0451f0451f0350c0550c015210652103521035210151c0651c0651c0451c03510055100151c0751c0551c0351c0151c0551c01510045100151002510015
010e0000240652406524045240351835518325210652106521045210452103521035152551522521045210152306523065230452303517455174251f0651f0651f0451f0451f0351f03513255132250706507035
010e00001d0751d0551d0451d0350c2650c2351f0751f0751f0451f0350c3650c335210652104521265212351c0651c0651c0451c03510465104451c0651c0551c0351c01510265102351c0551c0151045510435
010e00001d0751d0751d0451d0350c4650c4451f0751f0751f0451f0350c2650c2352107521045211652113520065200452005520035143451432521065210652116521135210452101523265232351706517025
__music__
00 41424344
00 41424344
00 2f0c4344
00 300d4344
00 310e4344
00 320f4344
00 14244344
01 15254344
00 16254344
00 17264344
00 18264344
00 15254344
00 16254344
00 17264344
00 19274344
00 1a284344
00 1b254344
00 1c294344
00 1d2a4344
00 1e2b4344
00 1f254344
00 202c4344
00 212d4344
00 1a284344
00 1b254344
00 1c294344
00 1d2a4344
00 1e2b4344
00 1f254344
00 222c4344
02 232e4344
00 41424344
00 35364344
00 35364344
00 41424344
01 373d7f0b
00 373c510b
00 383e7f0b
00 393f7f0b
00 373d3b0b
00 373c110b
00 383e110b
02 393f120b
02 7a424344
02 7a424344

