pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
text="this is a test."
text1="this is much longer text blah blah blah. in fact it is very long. expect much exposition here."

texttable={
	"this is the first entry in the text table",
	"and this is the second"
}
texttableidx=1

activetext=texttable

textbutton=1

windowstyles={}
windows={}

--[[
todo:
 multi-page windows (vertical overflow with button for next page)
 window alignment (left,right,centre)
 fit window size to text
 integrate window style into window for simplicity?
]]

function _init()
	windowstyles.box=addwindowstyle(2,2,2,2)
	add(windows,addwindow(0,96,127,31,windowstyles.box))
	
	windowstyles.bubble=addwindowstyle(1,1,1,1,5,15,5)
	add(windows,addwindow(32,32,61,8,windowstyles.bubble))
	
	windowstyles.flat=addwindowstyle(0,0,1,1,2,2,14)
	add(windows,addwindow(32,48,59,6,windowstyles.flat))
end

function _update()
	if type(activetext) == "table" then
		if btnp(❎) then
			texttableidx+=1
			if texttableidx>#texttable then
				texttableidx=#texttable
			end
		end
	end
end

function _draw()
	cls()
	--drawtextbox(32,32,text)
	--drawdialoguebox()
	--[[
	local ws=windowstyles.box
	for w in all(windows) do
		drawwindow(w,ws)
		drawtext(text1,w,ws)
	end
	]]
	
	drawwindow(windows[1],windowstyles.box)
	if type(activetext) == "table" then
		drawtext(activetext[texttableidx],windows[1],windowstyles.box)
		if texttableidx<#texttable then
			--drawtextbutton(windows[1],windowstyles.box)
			textbutton=1
		else 
			textbutton=2	
		end
	else
		drawtext(activetext,windows[1],windowstyles.box)
	end
	drawtextbutton(windows[1],windowstyles.box)
	
	drawwindow(windows[2],windowstyles.bubble)
	drawtext(text,windows[2],windowstyles.bubble)
	
	drawwindow(windows[3],windowstyles.flat)
	drawtext(text,windows[3],windowstyles.flat)

end

--fits a box around text
function drawtextbox(x,y,t)
	local x1=x+#t*4
	local y1=y+6

	rectfill(x,y,x1,y1,1)
	print(t,x+1,y+1,7)
end

function drawdialoguebox()
	--todo:return dialogue box
	--then use printtext function
	--to print text into it
	local x,y=0,86
	local borderx,bordery=2,2
	local xpad,ypad=2,2
	local width=127-borderx-xpad
	local height=127-bordery-ypad

	--draw box
	rectfill(x,y,127,127,7)
	rectfill(x+borderx,y+bordery,127-borderx,127-bordery,1)
	
	--add text
	local sx=x+borderx+xpad
	local sy=y+bordery+ypad
	--[[
	for i=sx,width,4 do
		for j=sy,height,6 do
			print("x",i,j,7)		
		end
	end
	]]
end

function drawtextbutton(w,st)
	spr(textbutton,w.x1-st.bordx-st.padx-5,w.y1-st.bordy-st.pady-6)
end

function addwindow(wx,wy,ww,wh)
	w={
		x=wx,
		y=wy,
		x1=wx+ww,
		y1=wy+wh,
		w=ww,
		h=wh
	}
	return w
end

function drawwindow(w,st)
	--draw border
	rectfill(w.x,w.y,w.x1,w.y1,st.bordcol)
	--draw window
	rectfill(w.x+st.bordx,w.y+st.bordy,w.x1-st.bordx,w.y1-st.bordy,st.bgcol)	
end

function drawtext(t,w,st)
	local parsed=wraptext(t,w.x1/4)
	for i=1,#parsed do
		print(parsed[i],w.x+st.bordx+st.padx,w.y+st.bordy+st.pady+i*6-6,st.textcol)
	end
end

function addwindowstyle(bx,by,px,py,bc,bgc,tc)
	ws={
		bordx=bx,
		bordy=by,
		padx=px,
		pady=py,
		bordcol=bc or 7,
		bgcol=bgc or 1,
		textcol=tc or 7
	}
	return ws
end

-- this takes a string and fills an array with the letter count of each word
function wordcounts(str)
	local ret={}
	local idx=1
	-- gmatch doesnt exist in pico8 but split does; you can iterate over that result
	--for word in string.gmatch(str, "%w+") do
	for word in all(split(str," ")) do
		ret[idx]=#word
		idx=idx+1
	end
	
	return ret
end

function wraptext(str,maxlen)
	local result={}
	local wordcounts=wordcounts(str)

	local linelen=0
	local startidx=1
	local counts=#wordcounts
	for i = 1,counts do
		local len=wordcounts[i]
		local nextlen=(i < counts and wordcounts[i+1]) or 0
		linelen=linelen+len

		-- if this word plus next word is less than our max, update linelen and continue
		if linelen+nextlen+1<=maxlen and i!=counts then
			linelen=linelen+1 -- adding 1 for the space in between
		else -- if it doesn't fit, we have our new line string. 
			result[#result+1] = sub(str,startidx,startidx+linelen)
			startidx=startidx+linelen+1 -- update startidx to be after the word we just took, +1 for space
			linelen=0 -- reset linelen for the next count
		end
	end

	return result
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000000007d7d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000000077d770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000677776007d7d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006776000677760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
