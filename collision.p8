pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--todo:
-- pushable objects
-- modularise with addcollider(obj)?

spd=2
blockoverlap=true
colliders={}

function _init()
	a=makeobj(32,32,8,8,32,32,8,8)
	b=makeobj(96,32,16,16,96,32,16,16)
	c=makeobj(48,64,40,14,48,64,40,14)

	add(colliders,b)
	add(colliders,c)
end

function _update60()
	doinput()
	moveobj(a)
end

function _draw()
	cls()
	
	drawobj(a,8)
	drawcollider(a,11)
	
	drawobj(b,2)
	drawcollider(b,3)

	drawobj(c,9)
	drawcollider(c,10)

	print("blockoverlap: "..(blockoverlap and 'true' or 'false'))

	local res=overlapdir(a,b)
	print("l"..res.l)
	print("r"..res.r)
	print("t"..res.t)
	print("b"..res.b)

	--this detects the true overlap condition
	if	bor(res.l,res.r)==1 and
		bor(res.t,res.b)==1 then		
			print("overlap!",7)
	end

	print("❎: toggle overlap block",16,120)
end

function doinput()
	if btnp(❎) then
		blockoverlap = not blockoverlap
	end
end
-->8
function makeobj(ox,oy,ow,oh,ocx,ocy,ocw,och)
	--add a collision/overlap structure?
	--include
		--side(s)
		--other object

	local o={
		--position
		x=ox,
		y=oy,
		w=ow,
		h=oh,
		x1=ox+ow,
		y1=oy+oh,
		--collider
		cx=ocx,
		cy=ocy,
		cw=ocw,
		ch=och,
		cx1=ocx+ocw,
		cy1=ocy+och,
		--move delta
		dx=0,
		dy=0
	}
	return o
end

function moveobj(o)
	o.dx=0
	o.dy=0
	if btn(⬅️) then
		o.dx=-spd
	end
	if btn(➡️) then
		o.dx=spd
	end
	if btn(⬆️) then
		o.dy=-spd
	end
	if btn(⬇️) then
		o.dy=spd
	end
	
	if blockoverlap then
		movewithcollision(o)
	else
		updateobjposition(o)
		updatecolliderposition(o)
	end
end

function drawobj(o,c)
	rectfill(o.x,o.y,o.x1,o.y1,c)
end

function drawcollider(o,c)
	rect(o.cx,o.cy,o.cx1,o.cy1,c)
end
-->8
function overlap(ax,ay,ax1,ay1,bx,by,bx1,by1)
	if	ax>bx1 or
		ay>by1 or
		ax1<bx or
		ay1<by then
			return false
	end
	return true
end

function overlapobj(a,b)
	if	a.cx>b.cx1 or
		a.cy>b.cy1 or
		a.cx1<b.cx or
		a.cy1<b.cy then
			return false
	end
	return true
end

function movewithcollision(a)
	--last good deltas
	lgdx,lgdy=0,0

	--these iterators are required for the for loops to move in the correct direction
	local dxi = 1
	if a.dx < 0 then dxi = -1 end

	local dyi = 1
	if a.dy < 0 then dyi = -1 end

	for nx=0,a.dx,dxi do
		for ny=0,a.dy,dyi do
			local acx=a.cx+nx
			local acy=a.cy+ny
			local acx1=a.cx1+nx
			local acy1=a.cy1+ny
			local posgood = true

			for col in all(colliders) do
				if (overlap(acx,acy,acx1,acy1,col.cx,col.cy,col.cx1,col.cy1)) then
					posgood = false;
					break
				end
			end

			if posgood then
				lgdx,lgdy=nx,ny
			end

		end
	end

	-- set new, good delta for movement
	a.dx,a.dy=lgdx,lgdy
	updateobjposition(a)
	updatecolliderposition(a)
end

function updateobjposition(o)
	o.x+=o.dx
	o.y+=o.dy
	o.x1=o.x+o.w
	o.y1=o.y+o.h
end

function updatecolliderposition(o)
	o.cx+=o.dx
	o.cy+=o.dy
	o.cx1=o.cx+o.w
	o.cy1=o.cy+o.h
end

function overlapdir(a,b)
	r={
		l=0,
		r=0,
		t=0,
		b=0
	}

	--left
	if	a.cx<=b.cx1 and 
		a.cx1>=b.cx1 then
			r.l=1
	end
	
	--right
	if	a.cx1>=b.cx and 
		a.cx1<=b.cx1 then
			r.r=1
	end

	--top
	if	a.cy<=b.cy1 and 
		a.cy1>=b.cy1 then
			r.t=1
	end

	--bottom
	if	a.cy1>=b.cy	and 
		a.cy1<=b.cy1 then
			r.b=1
	end
	
	return r
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
