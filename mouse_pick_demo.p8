pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--main

function _init()
  mkb_init(true,false,true)
  
	 objs={}
  makeobj(2,64,64)
  mouse=makeobj(1,stat(32),stat(33))
  
  btnprs=false
end

function _update()
	updatemouse()
	updateobjs()
	
	for o in all(objs) do
		if o~=mouse then
			if overlapobj(mouse,o) then
				--if an object is clicked
				--and nothing is on the cursor
				--pick it up/follow cursor
				if stat(34)==1 then
					--lmb click
					btnprs=true
				end
			end
		end
	end
end

function _draw()
	cls()
	drawobjs()
	print(btnprs)
	--drawcolliders()
end


-->8
-- mouse
-- enable = enables devkit mode with mouse and keyboard
-- btn_emu = left,right,middle mouse buttons -> btn(❎),btn(🅾️),btn(6)
-- ptr_lock = enable pointer lock
function mkb_init(enable, btn_emu, ptr_lock)
  -- pass args as bitfield into hardware register
  poke(0x5f2d,(enable   and 1 or 0)
             |(btn_emu  and 2 or 0)
             |(ptr_lock and 4 or 0))
end

function updatemouse()
	mouse.x=stat(32)
	mouse.y=stat(33)
end

function click(x,y,btn)
	if mspr==1 then
		return
	end
	
	
end
-->8
--objects

function makeobj(sp,ox,oy,ow,oh)
	local o={
	 sp=sp,
	 x=ox,
	 y=oy,
	 w=ow or 8,
	 h=oh or 8,
	 x1=ox+(ow or 8),
	 y1=oy+(oh or 8)
	}

	add(objs,o)

	return o
end

function updateobjs()
	for o in all(objs) do
		o.x1=o.x+o.w
		o.y1=o.y+o.h
	end
end

function drawobjs()
	for o in all(objs) do
		spr(o.sp,o.x,o.y)
	end
end

function overlapobj(a,b)
	if (a.x>b.x1 or 
					a.y>b.y1 or 
					a.x1<b.x or 
					a.y1<b.y) then
						return false
	end	
	return true
end
-->8
--debug

function drawcolliders()
	for o in all(objs) do
		rect(o.x,o.y,o.x1,o.y1,11)
	end
end
__gfx__
000000000550000022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005775000022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007005677500022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005677750022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005667775022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007005665577522222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005650055022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000500000022222222eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
