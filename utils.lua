function fmget(x,y)
	return fget(mget(x/8, y/8))
end

function checksolid(x,y,w,h)
	if (fget(mget(x/8,(y+h)/8)) == 1 or
		fget(mget((x+w)/8,(y+h)/8)) == 1) then 
			return true
	end
	return false
end

function checksolidentity(e)
	return checksolid(e.x,e.y,e.w,e.h)
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