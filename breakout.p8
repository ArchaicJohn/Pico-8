pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--breakout

gamestate="gameplay"

lives=3

paddles={}
balls={}

function _init()
	resetgameplay()
end

function _update60()
	if gamestate=="gameplay" and lives<=0 then
		
	end

	if gamestate=="gameplay" then
		doinput()
		
		for b in all(balls) do
			moveball(b)
		end
		
		if #balls<=0 then
			resetgameplay()
		end
	end
end

function _draw()
	cls()
	
	for b in all(balls) do
		drawball(b)
	end
	
	for p in all(paddles) do
		drawpaddle(p)	
	end
end

function resetgameplay()
	--rethink this function...

	for p in all(paddles) do
		removepaddle(p)
	end
	
	for b in all(balls) do
		removeball(b)
	end

	--todo:fix this mess
	local pw=3
	local px=64-pw*8/2
	local py=112
	addpaddle(px,py,pw)
	addball(64,64)
end


-->8
--draw
function drawpaddle(p)
	for i=0,p.w-1 do
		local sp,flp=1,false
		
		if i>0 and i<p.w-1 then
			--middle sprite
			sp=2
		end
		
		if i==p.w-1 then
			--flip right side end sprite
			flp=true
		end
		
		spr(sp,p.x+8*i,p.y,1,1,flp)		
	end
end

function drawball(b)
	circfill(b.x,b.y,b.r,6)
	--circ(ball.x,ball.y,ball.r-1,13)
	circ(b.x,b.y,b.r,5)
end
-->8
--game logic
function doinput()
	local l,r,x=btn(0),btn(1),btnp(5)
	local dx=0
	
	for p in all(paddles) do
		if l then
				dx=-p.spd
		elseif r then
				dx=p.spd			
		end
		movepaddle(p,dx)
	end
	
	if x and #balls>0 then 
			--launch the next unlaunched ball
			for i=1,#balls do
				local b=balls[i]
				if b.launched==false then
					b.dx=(rnd(2)-1)+0.15
					b.dy+=-b.spd				
					b.launched=true
					return
				end
			end
	end
end

function addpaddle(px,py,pw)
	p={
		x=px,y=py,
		x1=0,y1=0,
		dx=0,
		w=pw or 3,
		spd=1
	}
	
	p.x1=p.x+p.w*8
	p.y1=p.y+8
	
	add(paddles,p)
end

function removepaddle(p)
	del(paddles,p)
end

function movepaddle(p,dx)
	p.x1=p.x+p.w*8
	if inbounds(p.x+dx,p.x1+dx-1,
													p.y,p.y1) then
		p.x+=dx
		p.x1+=dx
	end
end

function getpaddlecentre(p)
	return p.x+((p.w*8)/2)
end

function addball(x,y,p)
	b={
		x=x,y=y,
		dx=0,dy=0,
		r=2,
		d=0,
		spd=1,
		spdmax=5,
		launched=false
	}
	b.d=b.r*2
	
	if p then
		setballstartpos(b,p)
	end
	
	add(balls,b)
end

function removeball(b)
	del(balls,b)
end

function setballstartpos(b,p)
	b.x=getpaddlecentre(p)-(b.r/2)+1
	b.y=p.y-b.r-1
end

function moveball(b)
	if not b.launched then
		setballstartpos(b,paddles[1])
	else
		--move the ball based on it's direction and speed
		if not inbounds(b.x-b.r,b.x+b.r,b.y-b.r,b.y+b.r) then			
			--off bottom of screen
			if b.y>132 then
				removeball(b)
				return
			end
			
			--bounds check
			if b.x-b.r<=0 or 
						b.x+b.r>=127 then
				b.dx*=-1			
			end
			
			if b.y-b.r<=0 then
				b.dy*=-1
			end
		end
		
		for p in all(paddles) do
			--todo:fix or replace
			--ball doesn't have x1,y1
			if overlap(b,p) then
				b.dy*=-1
			end
		end
		
		--todo: normalize move speed
		b.x+=b.dx
		b.y+=b.dy
	end
end

-->8
--utils
function inbounds(x,x1,y,y1)
	if x>=0 and x1<=127 then
		if y>=0 and y1<=127 then
			return true
		end
	end
	return false
end

function overlap(a,b)
	if (a.x>b.x1 or 
		a.y>b.y1 or 
		a.x1<b.x or 
		a.y1<b.y) then
			return false
	end	
	return true
end

function wait()
	--for i=
end
__gfx__
00000000005555555555555500555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005777e777777777705666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700576668666666666656766665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005d6668666666666656666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700051ddd2dddddddddd56666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070005111211111111115d6666d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555555555555505dddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
