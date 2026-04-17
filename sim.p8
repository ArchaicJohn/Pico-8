pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
plants={}
--index of all plant types?
--uses a lot of tokens
plant={
	first={
		name="cave wheat",
		frames={1,2,3,4,5},
		maxage=750,
		agespd=1,
		hasfruit=false,
		agefruit=90
	},
	second={
		name="glow shroom",
		frames={6,7,8,9,10},
		maxage=600,
		agespd=1,
		hasfruit=false,
		agefruit=90
	}
}

function _init()
 addplant(plant.first,32,32)
 addplant(plant.first,115,115)
 addplant(plant.second,67,22)
end

function _update()
	updateplants()
end

function _draw()
	cls()
	drawplants()	
end

function addplant(pl,x,y)
	p=pl
	p.x=x
	p.y=y
	p.age=1 --should this be renamed?
	p.timer=0
	add(plants,p)
end

function updateplants()
	for p in all(plants) do
 	p.timer+=p.agespd
 	
 	if p.age==p.fruitage then
			p.hasfruit=true
		else
			p.hasfruit=false
		end
 	
		--only age up every n frames
		--n=p.maxage/#p.frames
	 --only when this has remainder 0?
		--if there is a remainder we don't age up
		local milestone=p.maxage/#p.frames
 	if (p.timer%milestone)==0 then
			p.age+=1
		end
 	
		if p.timer>=p.maxage then
			del(plants,p)
		end
	end
end

--choosing frame based on age
--doesn't work properly
function drawplants()
	for p in all(plants) do
		spr(p.frames[p.age],p.x,p.y)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000b0000080b0000000000000000000000000000000000000cc000000000000000000000000000000000000000000000000000
0070070000000000000000000000b0000000b0800000040000000000000000000000000000c11c00000100000000000000000000000000000000000000000000
00077000000000000000000000b0b00000b0b00000004040000000000000000000011c000c1111c000d11d000000000000000000000000000000000000000000
00077000000000000000b000000b0000080b000000440000000000000000000000c010100000c0000d1011000000000000000000000000000000000000000000
0070070000000000000b0000000b0000000b00000004000000000000001c100000010000000c1000010100000000000000000000000000000000000000000000
00000000000b0000000b0000000b0000000b00000004000000010000000100000001000000011000001110100000000000000000000000000000000000000000
