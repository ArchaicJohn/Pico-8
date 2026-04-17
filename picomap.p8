pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--picomap v0.43
--by jadelombax

function _init()
 --user settings
 obcounts={64,88,48} --# of bg,fg,& entity objects (max.of 232 total)
 obtype=1 --default obj.category
 grid=1 -- 1:0n,-1:off
 screen_ht=16 --height of 1 screen in tiles
 bord_obj_ptrn_size=1 --size of repeating pattern in bordered objects
 import_cart='picomap_smw.p8' --name of cart to import sprites, flags, & map memory from
 export_cart='testcart.p8' --name of cart data will export to
 spritesheet_h=128 --height in pixels to encode in string
 transparency_col=0 --spritesheet transparency color
 --
 update_strings()
 ref_tbl=""
 new_lvs=""
 vartype,maptype,at_interact,alt_mode=0,0,0,0
 obj_bookmarks=split"0,0,0,0,0,0" --last objects used in each category
 make_cam_bookmarks()
 camx,camy,cx,cy,celx,cely=0,8,0,8,0,0
 lvlnum=1
 add(obcounts,0)
 add(obcounts,1)
 add(obcounts,1)
 poke(0x5f5d,1) --btnp repeat speed
 poke(24365,1) --enable mouse
 --ui palette
 pal(split"128,133,3,4,5,6,7,8,9,10,11,12,134,14,15",2)
 poke(24415,16)
 poke(24432,255) --top tile row
 poke(24447,255) --bottom tile row
 if transparency_col!=0 then
  palt(0,_)
  palt(transparency_col,1)
 end
 cartdata("picomap_alpha")
 array={}
 def_obj,def_obj_old,prev=-1,-1,-1
 mbtn_old,boxw,boxh=0,0,0
 mnu,obsel,obinfo=-1,-1,-1
 sx1,sy1,var=0,0,0
 keybuffer=""
 lvs_buffer,lvlnum_buffer,ods_buffer=levels[lvlnum],lvlnum,ods --undo buffers
 nlh=split"0,0,0,0,0" --new level header
 mset(108,0,1) --mask object
 change_props=_
 nlm=-1
 tic,delpopup,nd=0,true
 x1,y1=0,0
 if(newday()) nd=1
 timer,popy=0,128
 level_setup()
 make_autotile_list()
 cache_obj_data()
 bgtile=0
 editing=_
end

function _update()
 cx,cy=camx\8,camy\8
 cls(bgc)
 objrange()
 buttoncontrols()
 mousecontrols()
 editstrings()
 drawgrid(1)
 build_lvl_map()
 objpreview()
 autotile()
 draw_lvl_map()
 drawgrid(2)
 edit_object()
 delete_object()
 select_obj()
 center_obj()
 draw_def_obj()
 drawselbox()
 drawui()
 infodisplay()
 iconcontrols()
 thumbnail(116,0,obnum)
 new_lvl_menu()
 menu()
 popups()
 drawmouse()
 def_obj_old=def_obj
end

function draw_lvl_map()
 if(def_obj<0)map(111,0,0,8)
end

function make_cam_bookmarks()
 cam_bookmarks={{0,8}}
 for i=2,#levels do
  add(cam_bookmarks,{0,8})
 end
end

function level_setup()
 lvs=levels[lvlnum]
 lvl_type=val(lvs,2) --level type
 bgc=val(lvs,3) --background color
 lvl_width=(val(lvs,4,2)+1)*16 --level width in tiles
 lvl_height=(val(lvs,6,2)+1)*screen_ht --level height in tiles
 bg_tile=val(lvs,8,2)
 draw_mask_sprite(bgc==6 and 7 or 6)
end

function update_strings()
 --v0.41 & earlier
 if sub(ods,1,7)!="6c00070" then
  ods="6c00070"..sub(ods,1,232*7)
 end
 for l=1,#levels do
  lvs=levels[l]
  if ord(lvs,1)<103 then
   lvs="g"..sub(lvs,1,6).."00"..sub(lvs,7)
		 local a,b,c={},{},"" --arrays for x values & their order
		 local n=#lvs\8-1 --# of objs in level string
		 for i=1,n do
		  j=i*8
		  --change mask objs to obj 0
		  if val(lvs,j+6,2)==237 then
		   lvs=sub(lvs,1,j+5).."00"..sub(lvs,j+8)
		  end
		  a[i]=val(lvs,j+2,3)\16
		  b[i]=i
		 end
		 --sort x values by increasing screen number
		 for i=1,n do j=n
		  while j>1 do
		   local k=j-1
		   if a[k]>a[j] then
		    a[j],a[k]=a[k],a[j]
		    b[j],b[k]=b[k],b[j]
		   end j-=1
		  end
		 end
		 --create string of sorted objects
		 for i=1,n do
		  local sl=b[i]*8+2 --sorted location
		  c..=sub(lvs,sl,sl+7)
		 end
		 levels[l]=sub(lvs,1,9)..c
		end
	end
end

function cache_obj_data()
 holdframe()
 obj_data={}
 lvs=levels[lvlnum]
 --level header
 lvl_width=(val(lvs,4,2)+1)*16
 lvl_height=(val(lvs,6,2)+1)*screen_ht
 --level string
 local lsl=10
 while lsl<#lvs do
  process_object('cache',lsl)
  lsl+=8
 end
end

function obj_visible(n)
 local tbl=obj_data[n]
 if cx>=tbl.ax1 then
  if cx<=tbl.ax2 then
   if cy>=tbl.ay1 then
    if cy<=tbl.ay2 then
     obs+=1
     return true
    end
   end
  end
 end
end

function make_autotile_list()
 at_list={}
 atl_length=1
 for i=1,#ods,7 do
  if val(ods,i+5)==4 then
   local k=val(ods,i,2)
   local sx,sy=k%128,k\128*16+val(ods,i+2)
   local dw,dh=val(ods,i+3)+1,val(ods,i+4)+1
   local tile=mget(sx,sy)
   if tile>1 then
    at_list[tile]=sx+sy*128+(dw+dh*16)/1024
    atl_length=tile
   end
  end
 end
end

function process_object(check,lsp,tbl)
 if check then
  local xpos,ypos,on,_xv,_yv=_
  --level string
  if lsp then
   xpos,ypos,on,_xv,_yv=val(lvs,lsp,3),val(lvs,lsp+3),val(lvs,lsp+4,2),val(lvs,lsp+6),val(lvs,lsp+7)
  --object preview
  else
   xpos,ypos,on,_xv,_yv=unpack(tbl)
  end
  
  local osp,xv,yv,sb,eb,psx,psy=on*7+1,0,0,1,0,16,16
  --obj type
  local typ=val(ods,osp+5)
  --mapping & variance type
  local mtyp,vtyp=typ\4,typ%4
  --autotile interaction
  local ati=(val(ods,osp+6)&1)/2
  --alt mode
  local alt=val(ods,osp+6)&2
  --x&y starting map cel
  local scx,scy=val(ods,osp,2)%128,val(ods,osp,2)\128*16+val(ods,osp+2)
  --default width & height
  local dw,dh=val(ods,osp+3)+1,val(ods,osp+4)+1
  --type properties
  if(vtyp==1) xv=_xv
  if(vtyp==2) yv=_yv
  if(vtyp==3) xv,yv=_xv,_yv
  --repeated pattern
  if(mtyp>=1) sb,psx,psy=0,dw,dh
  --pattern w/border
  if mtyp==2 then
   eb=1
   if alt>0 then
    psx,psy,dw,dh=dw,dh,1,1
    else
    psx,psy=bord_obj_ptrn_size,bord_obj_ptrn_size
   end
  end
  --multi-screen pattern
  if(mtyp==3) xv,yv=max(xv*16-dw),max(yv*screen_ht-dh)
  --for autotile objects
  if(typ==4)  xv,yv,psx,psy,dw,dh=_xv,_yv,1,1,1,1
  --array x&y position
  local ax=xpos%lvl_width
  local ay=ypos+1+xpos\lvl_width*screen_ht
  --screenspace x&y pos.
  local ssx,ssy=ax-cx,ay-cy
  --total obj w&h
  local tw,th=dw+xv-1,dh+yv-1
  --if obj preview
  local preview=tbl and 1 or false
  
  if check=='cache' then
   add(obj_data,{ax1=ax-16,ax2=ax+tw+1,ay1=ay-14,ay2=ay+th+1})
  else
   map_object(ssx,ssy,dw,dh,tw,th,scx,scy,psx,psy,sb,eb,ati,preview)
  end
 end
end

function map_object(ssx,ssy,dw,dh,tw,th,scx,scy,psx,psy,sb,eb,ati,preview)
 for w=max(ssx,-1)-ssx,min(16,ssx+tw)-ssx do
  for h=max(ssy,-1)-ssy,min(16,ssy+th)-ssy do
   local xpp,ypp,mp=(w-dw)%psx,(h-dh)%psy
   local dx=w>=dw and sb*dw+xpp+eb*(w\tw*(psx-xpp)+dw) or w
   local dy=h>=dh and sb*dh+ypp+eb*(h\th*(psy-ypp)+dh) or h
   local tile=mget(scx+dx,scy+dy)
   if at_list[tile] and not atbit[tile] then
    atbit[tile]=.125>>atb
    atb+=1
   end
   local bit,bits=atbit[tile],tile!=1 and array[ssy+h+2][ssx+w+2]%.5 or 0
   if(bit) bits=bits|bit
   if(tile>0) array[ssy+h+2][ssx+w+2]=tile+ati+bits
  end
 end
 --get data on object currently
 --moused over
 if not preview and gx==ssx and gy==ssy then
  mod_tbl={lsp,ssx*8,ssy*8,(ssx+tw+1)*8,(ssy+th+2)*8}
 end
end

function build_lvl_map()
 obs=0
 atbit,atb={},0
 if(not editing) mod_tbl=false
 local minx= cx==0
 local maxx= cx==lvl_width-16
 local miny= cy==1
 local maxy= cy==lvl_height-13
 local v=0
 for row=1,18 do
  array[row]={}
  for col=1,18 do
   if minx and col==1
   or maxx and col==18
   or miny and row==1
   or maxy and row==16 then
    v=.24609375 else v=bg_tile
   end
   array[row][col]=v
  end
 end
 lsp=10
 lsn=1
 while lsp<#lvs do
  process_object(obj_visible(lsn),lsp)
  lsp+=8
  lsn+=1
 end
end

function autotile()
 --increment value,tile location
 local inc,tl=split"16,1,32,2,0,4,64,8,128",split"12,7,11,6,13,8,10,5,17,2,16,1,18,3,15,0,12,4,9,12,19,12,12,12,14,12,12,12,12,12,12,12"
 for y=1,14 do
  for x=1,16 do
   local tile=array[y+1][x+1]\1
   local v1,v2=at_list[tile],atbit[tile]
   if v1 then
    local n=256
    for i=0,8 do
     local id=array[y+i\3][x+i%3]
     if id\1!=tile and id&.5>0 or id&v2==0 then
      n+=inc[i+1]
     end
    end
    local ntl=tl[(n%16<1 and n\16 or n%16)+1]
    local btx,bty=v1&127,v1\128
    tile=mget(btx+ntl%5,bty+ntl\5)
   end
   mset(x+110,y-1,tile)
  end
 end
end

function val(str,pos,dgts)
 dgts=dgts or 1
 return("0x"..sub(str,pos,pos+dgts-1))+0
end

function obval(n,dgts)
 dgts=dgts or 1
 return val(ods,ospos+n,dgts)
end

function hex(v,len)
 len=len or 1
 local pos=6
 for i=0,8,4 do
  if (v>=16<<i) pos-=1
 end
 local s=sub(tostr(v,1),pos,6)
 if #s<len then
  s=sub('000'..s,-len)
 end
 return s
end

function insert_hex(str,val,pos,len)
 return sub(str,0,pos-1)..hex(val,len)..sub(str,pos+len)
end

function newday()
 local nd=_
 if stat(90)>=dget(0) and stat(91)>=dget(1) and stat(92)>dget(2) then
  nd=1
 end
 for i=0,2 do
  dset(i,stat(90+i))
 end
  return nd
end

function popups()
 if(time()==2 and nd) timer,msg=80,'space:toggle ob.definition mode'
 if(mod_tbl and delpopup and nd and prev<0) timer,msg,delpopup=80,'x:delete object'
 -----
 local py=128
 if(timer>0) py=121 timer-=1
 popy=mid(popy-1,py,popy+1)
 rectfill(0,popy,127,128,2)
 ?msg,2,popy+1,6
end
-->8

--editor functions

function buttoncontrols()
 local p=btnp()
 local lr,ud=p\2%2-p%2,p\8%2-p\4%2
 if def_obj<0 then
  camx+=lr*8
  camy+=ud*8
 else
  celx+=lr
  cely+=ud
 end
 
 if(key' ') def_obj*=-1
 if(obnum>236) def_obj,obsel=-1,-1
 if(key'z') undo()

 if(def_obj<0) then
  if(key'g') grid*=-1
  if(key's') nlm*=-1 mnu=-1
  if(key'd') delete_lvl()
  if(key'h') camx,camy=0,0
  if(key'o') obinfo*=-1
  if(key'i') import_assets()
  if(key'e') levels2mem() export_data()
 else
  if(key'm') maptype+=1 maptype%=5 change_props=1
  if(key'v') vartype+=1 vartype%=4 change_props=1
  if(key'l') at_interact+=1 at_interact%=2 change_props=1
 end
end

function key(k)
 if(stat(30)) keyval=stat(31)
 if(keyval==k) keyval=_ return 1
end

function mousecontrols()
 mx,my,mbtn=stat(32),stat(33),stat(34)
 gx,gy=mx\8,my\8-1 --scrn.grid pos.
 mtx,mty=gx+cx,gy+cy-1 --map tile loc.
 pntr=1
 click,coords,sc,ec,grab=0,{}
 --start click
 if mbtn>mbtn_old then
  sc=1 x1,y1=gx,gy
  if mbtn==2 then
   if def_obj<0 then
    scxp,scyp=camx,camy
   else
    sccx,sccy=celx,cely
   end prev=-1
  end
 end
 --end click
 if mbtn<mbtn_old then
  ec=1 click=mbtn_old
  coords={x1,y1,gx,gy}
 end
 --drag view
 if mbtn==2 then
  if def_obj<0 then
   camx,camy=scxp+(x1-gx)*8,scyp+(y1-gy)*8
  else
   celx,cely=sccx+(x1-gx),sccy+(y1-gy)
  end grab,pntr=1,4
 end
 camx=mid(0,camx,(lvl_width-16)*8)
 camy=mid(8,camy,(lvl_height-13)*8)
 celx=mid(0,celx,92)
 cely=mid(0,cely,18)
 mbtn_old=mbtn
end

--obj.property names & icons
maptype_name=split"direct mapping,repeated ptrn,ptrn w/border,multi-scrn ptrn,autotile"
maptype_icon=split"dととととと,dm`m`m`m`m`m`m`m`m`m`m`m`m,dm`m`mmpm`m`m`mm…と,d♪p♪p♪`m…mp♪,dとm█mとm█mm█m"
vartype_name=split"fixed size,variable width,variable height,variable w&h"
vartype_icon=split"d}`}m█mきm█m}`},dき`m`m`}`}`m`m`き,dpmp`♪`き`♪`pmp,d}█m…pmp…m█}"
at_interact_name=split"at interact off,at interact on"
at_interact_icon=split"c`✽`e`e…`✽pe`,c`♪`m`m…`♪pm`"
alt_mode_name=split"set border size,set ptrn size"
alt_mode_icon=split"dとm…m`e`empe`m`e`e,dしe…e`m`mepm`e`m`m"

function objrange()
 rangetbl={0,obcounts[1],obcounts[1]+obcounts[2],obcounts[1]+obcounts[2]+obcounts[3],232}
 if not editing then
  obj_bookmarks[obtype]-=stat(36)
 end
 if obtype<5 then
  obj_bookmarks[obtype]=mid(rangetbl[obtype]+1,obj_bookmarks[obtype],rangetbl[obtype+1])
  obnum=obj_bookmarks[obtype]
 else obnum=0
 end
end

function editstrings()
 ospos=obnum*7+1
 --change object properties
 if change_props then
  ods_buffer=ods
  --block off fixed variance
  if(maptype>0) vartype=max(1,vartype)
 --adjust settings for autotile
 ----
  if maptype==4 then
   typevalue=4
  else typevalue=maptype*4+vartype
  end
  ods=sub(ods,1,ospos+4)..hex(typevalue)..hex(at_interact+alt_mode*2)..sub(ods,ospos+7)
  output_strings()
 end
 if obval(5)==4 then
  maptype=4
 ----
 else
  maptype=obval(5)\4
  vartype=obval(5)%4
 end
 at_interact=obval(6)&1
 alt_mode=(obval(6)&2)/2
 
 if change_props then
  make_autotile_list()
  change_props=_
 end
 
 if mnu<0 and nlm<0 then
  if click==1 and gy>=0 and gy<=13 then
   boxw,boxh=coords[3]-coords[1],coords[4]-coords[2]
   if boxw>=0 and boxh>=0 then
	   
	   --write obj string (define object)
	   --obj def format:xxywhss
	   if def_obj>0 then
	    ods_buffer=ods
	    local obw,obh=0,0
	    obw,obh=boxw,boxh
	    obj=hex(coords[1]+celx+(coords[2]+cely)\16*128,2)..hex((coords[2]+cely)%16)..hex(obw)..hex(obh)..sub(ods,ospos+5,ospos+6)
	    
	    ods=sub(ods,0,ospos-1)..obj..sub(ods,ospos+7)
	    output_strings()
	    
	   --write lvl string (place object)
	   --lvl obj format:xxxynnvv
	   elseif def_obj<0 and obsel<0 and prev>0 then
	    if sub(ods,ospos,ospos+6)!="0000000" then
	     lvs_buffer,levdel=levels[lvlnum]
	     local on=obnum
	     xvar,yvar=mid(0,boxw,15),mid(0,boxh,15)
	     levels[lvlnum]..=hex(coords[1]+cx+(coords[2]+cy-1)\screen_ht*lvl_width,3)..hex((coords[2]+cy-1)%screen_ht)..hex(on,2)..hex(xvar)..hex(yvar)
	     lvs=levels[lvlnum]
	     --
	     sort_objects()
	     --
	     cache_obj_data()
	     output_strings()
	     --process_object('cache',#lvs-7)
     end
    end
   end
  end
 end
 if(click==1 and not mod_tbl and gy>=0 and gy<=14) prev=1
 --output_strings()
end

function sort_objects()
 local len=#lvs
 if len>16 then
	 local pos1=len-7
	 local pos2=pos1
	 local oxp=val(lvs,pos1,3)\16
	 for i=len-15,9,-8 do
	  local oxp2=val(lvs,i,3)\16
	  if(oxp2>oxp) pos2=i
	 end
	 if pos2<pos1 then
	  levels[lvlnum]=sub(lvs,1,pos2-1)..sub(lvs,len-7,len)..sub(lvs,pos2,len-8)
	 end
	end
end

function radio_btn(n,val,x,y)
 for i=0,n-1 do
  ?'\^y2|',x+i*2,y,val==i and 6 or 0
 end
end

function draw_mask_sprite(xcol)
 poke(24405)
 rectfill(8,0,15,7,transparency_col)
 ?'>\-e<',10,2,xcol
 poke(24405,1)
end

function iconcontrols()
 xp0,xp1,xp2,xp3,mcx,vcx,acx,ciw=4,85,93,33,107,115,122,5
 if(def_obj>0) xp0,xp3,ciw=-16,-32,16
 if(icon('menu',xp0,2,7,5,"fイらイらイ")==2) mnu*=-1 nlm=-1
 if(icon('toggle grid (g)',xp0+9,2,7,5,"fm`m`m`mらm`m`m`mらm`m`m`m")==2) grid*=-1
 if(icon('undo (z)',xp0+19,1,7,6,"fpm…`}…や``}█mpm█mきm`")==2) undo()

 if(icon('background objects',xp1,1,7,6,"f`✽█e█epep✽`e`e█ee`e█eわ",1)==2 and def_obj<0) obtype=1
 if(icon('foreground objects',xp1+10,1,7,6,"fわeきeeきeeきeeきeわ",2)==2 and def_obj<0) obtype=2
 if(icon('entity objects',xp1+20,1,7,6,"fp✽p`e█e`e`e`e`ee`e`e`eeきe`し`",3)==2 and def_obj<0) obtype=3
 if(icon('mask object',xp3,2,5,5,"de█e`e`e`pep`e`e`e█e",5)==2 and def_obj<0) obtype=5
 if(icon('select object',116,1,8,6)==2 and def_obj<0) obsel*=-1
 
 if def_obj>0 then
  xp2,mcx,vcx,acx=67,81,100,117
  rect(79,120,98,128,0)
  line(115,120,115,127)
  radio_btn(5,maptype,87,122)
  radio_btn(4,vt-1,106,122)
  radio_btn(2,at_interact,123,122)
  
  icon('map data coords',2,121,24,7)
 else
  icon('screen pos. in level',2,121,22,7)
  icon('tile pos. in screen',26,121,24,7)
  
  if obinfo>0 then
   icon('objs in screen range',49,1,7,6)
   icon('total objs in level',61,1,11,6)
  end
 end

 --object property icons
 icon('object number',xp2,122,11,5)
 vt=maptype==4 and 4 or vartype+1
 if(icon(maptype_name[maptype+1],mcx,122,ciw,6,maptype_icon[maptype+1])==2 and def_obj>0) maptype=(maptype+1)%5 change_props=1
 if(icon(vartype_name[vt],vcx,122,ciw,6,vartype_icon[vt])==2 and def_obj>0 and maptype<4) vartype=(vartype+1)%4 change_props=1
 if(icon(at_interact_name[at_interact+1],acx,122,ciw,6,at_interact_icon[at_interact+1])==2 and def_obj>0) at_interact=(at_interact+1)%2 change_props=1
end

function icon(name,x,y,w,h,gfx,ot)
 if(ot and obtype==ot) pal(5,split"11,9,8,0,6"[ot])
 if(gfx) rle(gfx,x,y)
 pal(5,5)
 local state=0
 if(mx>=x and mx<x+w and my>=y and my<=y+h) then
  ?name,1,122,13
  if y<120 then
   pntr=2
   if(mbtn==1)pntr,state=3,1
  end
  if(click==1) state=2
 end
 return state
end

function undo()
 if def_obj<0 then
  if levdel then
   add(levels,lvs_buffer,lvlnum_buffer)
   lvlnum=lvlnum_buffer
   level_setup()
   add(cam_bookmarks,cbm_buffer,lvlnum)
   camx,camy=unpack(cbm_buffer)
   levdel=_
  else
   levels[lvlnum]=lvs_buffer
  end
  cache_obj_data()
 else
  ods=ods_buffer
  make_autotile_list()
 end
 output_strings()
end

function rle(s,x0,y)
 local x,w=x0,ord(s,1)-96
 for i=2,#s do
  local v=ord(s,i)-96
  local l=v\16
  if(v%16>0) line(x,y,x+l,y,v)
  x+=l+1 if(x>x0+w) x=x0 y+=1
 end
end

function thumbnail(x,y,n)
 ospos=n*7+1
 local dim=min(obval(3),obval(4))+1
 startcelx,startcely=obval(0,2)%128,obval(0,2)\128*16+obval(2)
 if dim==0 then
  map(x,y,startcelx,startcely,1,1)
 else
  for i=0,7 do
   tline(x,y+i,x+7,y+i,startcelx,startcely+i*dim/8,dim/8,0)
  end
 end
end

function objpreview()
 local mdx,mdy,xv,yv=0,0,0,0 --mouse displacement
 if prev>0 and def_obj<0 and mnu<0 and nlm<0 and grab==_ then
  if mbtn&1>0 then
   mdx,mdy=gx-x1,gy-y1
   xv,yv=mid(0,mdx,15),mid(0,mdy,15)
  end
  process_object(1,_,{mtx-mdx,mty-mdy,obnum,xv,yv})
 end
end

function delete_object()
 if mod_tbl and btnp(❎) then 
  --string pos.of obj.
  local sp=mod_tbl[1]
  --data table pos.of obj.
  local tp=(sp+1)\8
  lvs_buffer,levdel=levels[lvlnum]
  levels[lvlnum]=sub(levels[lvlnum],0,sp-1)..sub(levels[lvlnum],sp+8)
  output_strings()
  lvs=levels[lvlnum]
  deli(obj_data,tp)
 end
end

function edit_object()
 if mod_tbl and prev<0 then
  local sp,xa,ya,xb,yb=unpack(mod_tbl)
  --draw delete tab
  ?'\+ho⁶x1█\+bi█ᶜ7⁶x3\+cfx',xa,ya,0
  --draw object outline
  fillp(-13260.5)
  rect(xa-1,ya+7,xb,yb,bgc==7 and 6 or 7)
  fillp()
 end
end

function drawmouse()
 local pntrgfx=split("g█a…paga█pawappa♥a`pa❎apawq`█qga`,h█aきpaga…pagq`a`pagagaga`qせaagaせa`aほapq♥a`█a♥a`…▒p,hナナ█a`a`a`pagagaga`qせaagaせa`aほapq♥a`█a♥a`…▒p,h█a`a█pagagq`pagagagapagagaga`qせaagaせa`aほapq♥a`█a♥a`…▒p")
 rle(pntrgfx[pntr],mx-3,my-1)
end

function drawselbox()
 if gy>=0 and gy<=13 then
  if prev>0 and obsel<0 and mnu<0 and nlm<0 or def_obj>0 then
   local dow,doh=val(ods,obnum*7+4),val(ods,obnum*7+5)
   local dsx,dsy=1,1
  if(def_obj<0) dsx+=dow dsy+=doh
   if mbtn<=1 then
    local xa,ya=gx,gy
    if(mbtn>0) xa,ya=x1,y1
    rect(xa*8-1,ya*8+7,(gx+dsx)*8,(gy+dsy)*8+8,7)
   end
  end
 end
end

function drawgrid(mode)
 local gridcols="567567=67567567=67=776==2674779==377=67567=676=="
 local gcp=bgc*3+1
 if grid>0 then
  if mode==1 then
   for i=0,136,8 do
    local hp,vp=i-camx%16,i-camy%16
    line(hp,0,hp,127,ord(gridcols,gcp))
    line(0,vp,127,vp)
   end
  elseif mode==2 then
   for i=0,7 do
    local kx,ky=(i%2*128-camx)%256,(i\2*screen_ht*8+16-camy)%(screen_ht*16)
    if i<=3 then
     rect(kx-128,ky-screen_ht*8,kx,ky,ord(gridcols,gcp+1))
    else
     circfill(kx,ky,2,ord(gridcols,gcp+2))
    end
   end
  end
 end
end

function draw_def_obj()
 if def_obj>0 then
  rectfill(0,9,127,119,0)
  map(celx,cely,0,8,16,14)
  rect(0,8,127,8)
  --current obj defintion outline
  local outlinex=startcelx-celx
  local outliney=startcely-cely+1
  local olx,oly=outlinex*8-1,outliney*8-1
  --flashing outline color
  local olc=6+t()*2%2
  --extra 5*4 outline for at objs
  if obval(5)==4 and startcelx+startcely>0 then
   rect(olx,oly,olx+40,oly+32,olc)
  end
  --main outline
  rect(olx,oly,(outlinex+obval(3)+1)*8,(outliney+obval(4)+1)*8,olc)
 end
end

function center_obj()
 if def_obj>def_obj_old then
  celx=mid(0,startcelx-7+obval(3)\2,92)
  cely=mid(0,startcely-6+obval(4)\2,18)
 end
end

function drawui()
 rectfill(0,0,127,7,2)
 rectfill(0,121,127,127)
 rectfill(115,0,124,7,0)
end

function window(x1,y1,x2,y2)
 rect(x1,y1+1,x2,y2,0)
 rectfill(x1+1,y1,x2-1,y2-1,5)
 return (mx<x1 or mx>x2 or my>y2) and click>0
end

function select_obj()
 rect(-1,8,128,120,0)
 if obsel>0 and def_obj<0 and obnum>0 then
  if(window(50,8,126,ceil(obcounts[obtype]/8)*9+11-obcounts[obtype]\96)) obsel=-1
  for n=0,obcounts[obtype]-1 do
   local sx,sy,obn=53+n%8*9,10+n\8*9,rangetbl[obtype]+n+1
   rectfill(sx,sy,sx+7,sy+7,0)
   thumbnail(sx,sy,obn)
   if(obn==obnum) rect(sx-1,sy-1,sx+8,sy+8,7)
   if(icon("",sx,sy,8,8)==2) obj_bookmarks[obtype]=rangetbl[obtype]+n+1
  end
 end
end

function menu()
 if(key'q') change_lvl(-1)
 if(key'w') change_lvl(1)
 if mnu>0 then
  if(window(0,8,24,73) or def_obj>0) mnu=-1
  ?sub('0'..lvlnum,-2)..'/'..sub('0'..#levels,-2),3,33,6
  pal(1,0)
  if(icon('new map string (s)',10,12,7,5,"f`➡️pa█apa█apa…a`a█▒▒pa`")==2) nlm=1 mnu=-1 
  if(icon('delete map string (d)',10,22,7,5,"f`➡️pa█apaぬa█a`aa…a`▒`a`a")==2 and #levels>1) delete_lvl()
  if(icon('previous map (q)',4,41,6,5,"epapa`q`qね`q`qpapa")==2) change_lvl(-1) 
  if(icon('next map (w)',15,41,6,5,"eapapq`q`ねq`q`apap")==2) change_lvl(1)
  if(icon('import assets (i)',8,52,9,6,"ha█くqpa█a▒`a█aqpa█aa█く…➡️`")==2) import_assets() 
  if(icon('export maps (e)',8,63,9,6,"hく`apa█a`q`a█a`▒a█a`q`く`ap➡️き")==2) then
   levels2mem()
   export_data()
  end
 pal(1,1)
 end
end

function change_lvl(inc)
 cam_bookmarks[lvlnum]={camx,camy}
 lvlnum=mid(1,lvlnum+inc,#levels)
 level_setup()
 camx,camy=unpack(cam_bookmarks[lvlnum])
 cache_obj_data()
end

function delete_lvl()
 lvs_buffer=levels[lvlnum]
 lvlnum_buffer=lvlnum
 cbm_buffer=cam_bookmarks[lvlnum]
 deli(levels,lvlnum)
 deli(cam_bookmarks,lvlnum)
 levdel=1
 lvlnum=min(lvlnum,#levels)
 level_setup()
 camx,camy=unpack(cam_bookmarks[lvlnum])
 cache_obj_data()
end

function new_lvl_menu()
 if nlm>0 then
  if(window(0,8,39,64) or def_obj>0) nlm=-1
  --bgcolor
  rectfill(3,11,36,22,0)
  for i=0,15 do
   local h,v=i%8*4+4,i\8*5+12
   rectfill(h,v,h+3,v+4,i)
   if(icon("",h,v,4,5)==2) nlh[2]=i
  end
   h,v=nlh[2]%8*4+4,nlh[2]\8*5+12
   rect(h-1,v-1,h+4,v+5,7)
   rect(h,v,h+3,v+4,0)
  icon("background color",3,11,36,12)
  pal(1,0)

  adjust("level type",1,15,3,26,"f…ap…apa`a`a`aa`a`a`aa`a`a`a…ap…ap")
  adjust("map width (screens)",3,255,3,36,"faきaapapaapq`aりapq`aapapaaきa")
  adjust("map height (screens)",4,255,3,46,"fり█a█p▒p`く`█a██a█り")
  
  if(icon('reset',9,57,7,6,"da█a`a`a`pap`a`a`a█a")==2) nlh=split('0,0,0,0,0')
  if(icon('create new map',25,57,7,6,"fぬaきa`a█ap`a`a█pa…")==2) then
   add(levels,"g"..hex(nlh[1])..hex(nlh[2])..hex(nlh[3],2)..hex(nlh[4],2)..hex(nlh[5],2))
   lvlnum=#levels
   level_setup()
   camx,camy=0,8
   add(cam_bookmarks,{camx,camy})
   output_strings()
  end
  pal(1,1)
 end
end

function adjust(name,pnum,_max,x,y,gfx)
 ?'\^x5◀▶',x+26,y+1,0
 if(sc==1) tic=0
 local inc=10
 if(tic>30) inc=5
 if(tic>150) inc=1
 icon(name,x,y,36,7,gfx)
 if(icon("",x+25,y,5,7)==1 and tic%inc==0) nlh[pnum]=max(0,nlh[pnum]-1)
 if(icon("",x+30,y,5,7)==1 and tic%inc==0) nlh[pnum]=min(nlh[pnum]+1,_max)
 if(pnum==3) nlh[3]=min(nlh[3]+1,256\(nlh[4]+1))-1
 if(pnum==4) nlh[4]=min(nlh[4]+1,256\(nlh[3]+1))-1
 local value=nlh[pnum]
 if(pnum!=2 and pnum!=5) value+=1
 ?sub('00'..value,-3),x+12,y+1,6
 tic+=1
end

function infodisplay()
 if my>7 and my<120 and mnu<0 and nlm<0 then
  if def_obj<0 then
   ?sub('0'..mtx\16+1,-2)..','..sub('0'..mty\screen_ht+1,-2),1,122,13
   ?sub('0'..mtx%16,-2)..','..sub('0'..mty%screen_ht,-2),27,122,13
   ?'(     )',23,122,5
  else
   ?sub('00'..celx+gx,-3)..','..sub('00'..cely+gy,-3),1,122,13
  end
 end
 if obnum>0 then
  ?sub('00'..obnum,-3),xp2,122,5
 end
 if obinfo>0 and def_obj<0 then
  ?sub('00'..obs,-2)..'/'..sub('00'..#lvs\8,-3),49,2,13
 end
end

-->8
--import/export functions

function import_assets()
 reload(0,0,12544,import_cart)
 draw_mask_sprite(6)
 cstore(0,0,12544)
end

function output_strings()
 local lvls=""
 for i=1,#levels do
  if (i>1) lvls..="\n,"
  lvls..="\""..levels[i].."\""
 end
 printh('--object definition string\nods=\"'..ods..'\"'..'\n\n'.."--level strings\nlevels="..'{\n'..lvls..'\n}',"@clip")
end

function bytestring(t)
 local s=""
 for i=1,#t do
  local val,nxtval=t[i],t[i+1]
  if i<#t and nxtval>47 and nxtval<58 and val==0 then
   s..="\\000"
   elseif val==0 then s..="\\0"
   elseif val==10 then s..="\\n"
   elseif val==13 then s..="\\r"
   elseif val==34 then s..="\\\""
   elseif val==92 then s..="\\\\"
   else s..=chr(val)
  end
 end
 return s
end

function build_def_str()
 defs={screen_ht,bord_obj_ptrn_size,obcounts[1]+obcounts[2]}
 for i=1,#ods-6,7 do
  if sub(ods,i,i+6)=="0000000" then
   for i=1,4 do
    add(defs,95)
   end
  else
   local cx,cy=val(ods,i,2),val(ods,i+2)
   local scx,scy=cx%128,cy+cx\128*16
   local var,settings=val(ods,i+3,2),val(ods,i+5,2)
   --if autotile
   if settings\16==4 then
    var=0
   end
   add(defs,scx)
   add(defs,scy)
   add(defs,var)
   add(defs,settings)
  end
 end
 def_str=bytestring(defs)
end

function build_flag_str()
 flg_str=_
 if lbytes+mbytes+sbytes<=12288 then
 cstore(12288,12288,256,export_cart)
 else
  flg_tbl={}
	 for i=0,255 do
   add(flg_tbl,@(i+12288))
  end
  flg_str="⁶!3000"..bytestring(flg_tbl)
 end
end

function build_at_str()
 atl=""
 for i=1,atl_length do
  if at_list[i] then
   local v=at_list[i]
   local v1,v2=v\1,v%1*1024
   entry="0x"..hex(v1,3)
   if v2>0 then
    entry..="."..hex(v2%16)..hex(v2\16)
   end
  else
   entry=""
  end
  atl..=entry..","
 end
end

function levels2mem(ln)
 tl=0
 loc_tbl="1"
 lbytes=0
 at_used=_
 --clear high memory
 memset(32768,0,12288)
 --clear viewer cart memory
 cstore(0,32768,12288,export_cart)
 for ln=1,#levels do
  local c=levels[ln]
  --level header
  local new_lvs=sub(c,2,9)
  for i=10,#c-7,8 do
   --get object data (xxxynnvv)
   local xpos=val(c,i,3)
   local ypos=c[i+3]
   local on=val(c,i+4,2)
   local xv=c[i+6]
   local yv=c[i+7]
   --get obj defintion data
   local typ=val(ods,on*7+6)
   local vtype=typ%4
   --object screen numbers
   local last_sn=i>10 and val(c,i-8,3)\16 or 0
   local sn=xpos\16
   local next_sn=i<#c-7 and val(c,i+8,3)\16 or sn
   --screen number delta
   local dx=sn-last_sn
   local dx2=next_sn-sn
   --screen number commands
   if dx==1 and dx2==0 then
    --next screen flag
    new_lvs..=hex(233,2)
   elseif dx!=0 and dx2==-dx then
    --jump & return
    new_lvs..=hex(234,2)..hex(sn,2)
   elseif dx!=0 then
    --jump
    new_lvs..=hex(235,2)..hex(sn,2)
   end
    --add object number & pos data
   new_lvs..=hex(on,2)..hex(xpos%16)..ypos
   --add variance data
   if(vtype==1) new_lvs..=xv
   if(vtype==2) new_lvs..=yv
   if(vtype==3 or typ==4) new_lvs..=xv..yv
   if(typ==4) at_used=true
  end
  --make string whole # of bytes
  if #new_lvs%2>0 then
   new_lvs..="0"
  end
  --transfer data to upper mem
  local bytes=#new_lvs\2
  for i=0,bytes-1 do
   poke(32768+lbytes+i,val(new_lvs,i*2+1,2))
  end
  lbytes+=bytes
  --update table location data
  tl+=bytes*2
  if #loc_tbl>0 then
   loc_tbl..=','
  end
  loc_tbl..=tl+1
 end
end

function export_data()
--transfer assets to memory
 --map data
 mbytes=px9_comp(0,0,109,32,32768+lbytes,mget)
 --spritesheet
 draw_mask_sprite(transparency_col)
 sbytes=px9_comp(0,0,128,spritesheet_h,32768+lbytes+mbytes,sget)
 --restore mask sprite
 draw_mask_sprite(bgc==6 and 7 or 6)
--transfer byte data
 cstore(0,32768,lbytes+mbytes+sbytes,export_cart)
 
 build_def_str()
 build_flag_str()
 build_at_str()

 local strings='def_str="'..def_str..'"'..'\n'..'loc_tbl=split"'..loc_tbl..'"'..'\nmap_adr,spr_adr,lvl_bytes='..(lbytes+32768)..','..(lbytes+mbytes+32768)..','..lbytes
 if at_used then
  strings..='\nat_list=split"'..atl..'"'
 end
 if flg_str then
  strings..='\nflg_str="'..flg_str..'"'
 end
 --output data strings
 printh(strings,'@clip')
 --display exported data size
 timer,msg=80,'exported '..((lbytes+mbytes+sbytes)/1024)..' kb to ext.cart'
end

function px9_comp(x0,y0,w,h,dest,vget)
	local dest0=dest
	local function vlist_val(l, val)
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
		return i
	end
	local bit=1
	local byte=0
	local function putbit(bval)
		if (bval>0) byte+=bit
		poke(dest, byte) bit<<=1
		if (bit==256) then
			bit=1 byte=0
			dest += 1
		end
	end
	local function putval(val, bits)
		for i=0,bits-1 do
			putbit(val>>i&1)
		end
	end
	local function putnum(val)
		local bits = 0
		repeat
			bits += 1
			local mx=(1<<bits)-1
			local vv=min(val,mx)
			putval(vv,bits)
			val -= vv
		until vv<mx
	end
	local el={}
	local found={}
	local highest=0
	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
			c=vget(x,y)
			if not found[c] then
				found[c]=true
				add(el,c)
				highest=max(highest,c)
			end
		end
	end
	-- header
	local bits=1
	while highest >= 1<<bits do
		bits+=1
	end
	putnum(w-1)
	putnum(h-1)
	putnum(bits-1)
	putnum(#el-1)
	for i=1,#el do
		putval(el[i],bits)
	end
	-- data
	local pr={} -- predictions
	local dat={}
	for y=y0,y0+h-1 do
		for x=x0,x0+w-1 do
			local v=vget(x,y)
			local a=y>y0 and vget(x,y-1) or 0
			-- create vlist if needed
			local l=pr[a] or {unpack(el)}
			pr[a]=l
			-- add to vlist
			add(dat,vlist_val(l,v))
			-- and to running list
			vlist_val(el, v)
		end
	end
	-- write
	-- store bit-0 as runtime len
	-- start of each run
	local nopredict
	local pos=1
	while pos <= #dat do
		-- count length
		local pos0=pos
		if nopredict then
			while dat[pos]!=1 and pos<=#dat do
				pos+=1
			end
		else
			while dat[pos]==1 and pos<=#dat do
				pos+=1
			end
		end
		local splen = pos-pos0
		putnum(splen-1)
		if nopredict then
			-- values will all be >= 2
			while pos0 < pos do
				putnum(dat[pos0]-2)
				pos0+=1
			end
		end
		nopredict=not nopredict
	end
	if(bit>0) dest+=1 -- flush
	return dest-dest0
end
-->8
--object definition string
ods="6c000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

--level strings
levels={
"g06010100"
}
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll0000000000lll
lllllllllllllllllllllllllmllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllbbbllllll5555555lllll555lllll0000000000lll
llllmmmmmmmllmlmlmlmllllmmlllllll5lll5lllllllllllllllllllllllllllllllllllllllllllllllblllblllll5lllll5llll5lll5llll0000000000lll
lllllllllllllllllllllllmmmmmmlllll5l5llllllllllllllllllllllllllllllllllllllllllllllllbllbbbllll5lllll5lll5l5l5l5lll0000000000lll
llllmmmmmmmllmlmlmlmllllmmlllmlllll5lllllllllllllllllllllllllllllllllllllllllllllllllblblllblll5lllll5lll5l5l5l5lll0000000000lll
lllllllllllllllllllllllllmlllmllll5l5llllllllllllllllllllllllllllllllllllllllllllllllblblllblll5lllll5lll5lllll5lll0000000000lll
llllmmmmmmmllmlmlmlmllllllllmllll5lll5lllllllllllllllllllllllllllllllllllllllllllllllbbbbbbblll5555555llll55555llll0000000000lll
lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll0000000000lll
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666677
77666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d66666677777777776666666d6666666d6666666d6666666
7dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7dddddddd7ddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d666666676666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d666666676666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d666166676666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d661716676666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d661771676666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d661777176666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666667d661777716666666d6666666d6666666d6666666
7dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777177117ddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6661171d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
7ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
76666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
lmmmlmmllllllmmmlmmlllll5llmmllmmllllllmmmlmmmll5llllllllllllllllllllllllllllllllllllllllllll555l555l55llllmmmmmlllmmlmmlll555ll
lmlmllmllllllmlmllmllll5llllmlllmllllllmlmlmlmlll5lllllllllllllllllllllllllllllllllllllllllll5l5l5l5ll5llllmmmmmlllmlllmlll5l5ll
lmlmllmllllllmlmllmllll5llllmlllmllllllmlmlmmmlll5lllllllllllllllllllllllllllllllllllllllllll5l5l5l5ll5llllmmmmmllllllllllllllll
lmlmllmlllmllmlmllmllll5llllmlllmlllmllmlmlllmlll5lllllllllllllllllllllllllllllllllllllllllll5l5l5l5ll5llllmmmmmlllmlllmlll555ll
lmmmlmmmlmlllmmmlmmmllll5llmmmlmmmlmlllmmmlllmll5llllllllllllllllllllllllllllllllllllllllllll555l555l555lllmmmmmlllmmlmmllll5lll
llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll

__music__
02 41424344

