pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--todo:
-- pushable objects
-- modularise with addcollider(obj)?

spd=2
blockoverlap=true
colliders={}
drawcolliders=true

function _init()
	a=makeobj(32,32,8,8,32,32,8,8,8)
	b=makeobj(96,32,16,16,96,32,16,16,2)
	c=makeobj(48,64,40,14,48,64,40,14,9)
	d=makeobj(32,96,8,8,32,96,8,8,1)

	add(colliders,a)
	add(colliders,b)
	add(colliders,c)
	add(colliders,d)
end

function _update60()
	doinput()
	a.moveobj()
	d.moveobj()
end

function _draw()
	cls()
	
	for c in all(colliders) do
		c.drawobj()

		if (drawcolliders) then
			c.drawcollider()
		end
	end

	

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

	a.dx=0
	a.dy=0
	if btn(⬅️,0) then
		a.dx=-spd
	end
	if btn(➡️,0) then
		a.dx=spd
	end
	if btn(⬆️,0) then
		a.dy=-spd
	end
	if btn(⬇️,0) then
		a.dy=spd
	end

	d.dx=0
	d.dy=0
	if btn(⬅️,1) then
		d.dx=-spd
	end
	if btn(➡️,1) then
		d.dx=spd
	end
	if btn(⬆️,1) then
		d.dy=-spd
	end
	if btn(⬇️,1) then
		d.dy=spd
	end
end
-->8
function makeobj(ox,oy,ow,oh,ocx,ocy,ocw,och,col)
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
		colour=col,
		--move delta
		dx=0,
		dy=0
	}

	function o:drawobj()
		rectfill(o.x,o.y,o.x1,o.y1,o.colour)
	end

	function o:drawcollider()
		rect(o.cx,o.cy,o.cx1,o.cy1,11)
	end

	function o:moveobj()
		if blockoverlap then
			o.movewithcollision()
		else
			o.updateobjposition()
			o.updatecolliderposition()
		end
	end

	function o:movewithcollision()
		--last good deltas
		lgdx,lgdy=0,0

		--these iterators are required for the for loops to move in the correct direction
		local dxi = 1
		if o.dx < 0 then dxi = -1 end

		local dyi = 1
		if o.dy < 0 then dyi = -1 end

		for nx=0,o.dx,dxi do
			for ny=0,o.dy,dyi do
				local ocx=o.cx+nx
				local ocy=o.cy+ny
				local ocx1=o.cx1+nx
				local ocy1=o.cy1+ny
				local posgood = true

				for col in all(colliders) do
					-- exclude self
					if (col ~= o) then
						if (overlap(ocx,ocy,ocx1,ocy1,col.cx,col.cy,col.cx1,col.cy1)) then
							posgood = false;
							break
						end
					end
				end

				if posgood then
					lgdx,lgdy=nx,ny
				end
			end
		end

		function o:updateobjposition()
			o.x+=o.dx
			o.y+=o.dy
			o.x1=o.x+o.w
			o.y1=o.y+o.h
		end

		function o:updatecolliderposition()
			o.cx+=o.dx
			o.cy+=o.dy
			o.cx1=o.cx+o.w
			o.cy1=o.cy+o.h
		end

		-- set new, good delta for movement
		o.dx,o.dy=lgdx,lgdy
		o.updateobjposition()
		o.updatecolliderposition()
	end

	return o
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
