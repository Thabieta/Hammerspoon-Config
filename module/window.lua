hs.window.animationDuration = 0
local winhistory = {}
local winhistory2 = {}
-- 记录窗口历史
local function windowStash(window)
	local winid = window:id()
	local winf = window:frame()
	-- 确认存储历史不超过50个
	if #winhistory > 50 then
		-- 移除最后一次历史
		table.remove(winhistory)
	end
	local winstru = {winid, winf}
	table.insert(winhistory, winstru)
end
-- 记录窗口初始位置
local function windowStash2(window)
	local winid = window:id()
	local winf = window:frame()
	if #winhistory2 > 50 then
		table.remove(winhistory2)
	end
	local winstru = {winid, winf}
	local exist = false
	for idx,val in ipairs(winhistory2) do
		if val[1] == winid then
			exist = true
		end
	end
	if exist == false then
		table.insert(winhistory2, winstru) 
	end
end
-- 窗口动作
function Resize(option)
	local cwin = hs.window.focusedWindow()
	if cwin then
		local cscreen = cwin:screen()
		local cres = cscreen:fullFrame()
		local wf = cwin:frame()
		if option == "halfleft" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfright" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfup" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
		elseif option == "halfdown" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
		elseif option == "fullscreen" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
		elseif option == "center" then
			windowStash2(cwin)
			cwin:centerOnScreen()
		elseif option == "reset" then
			local cwin = hs.window.focusedWindow()
			local cwinid = cwin:id()
			for idx,val in ipairs(winhistory2) do
				if val[1] == cwinid then
					cwin:setFrame(val[2])
				end
			end
		elseif option == "expand" then
			cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)})
		elseif option == "shrink" then
			cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)})
		else
			hs.alert.show("Unknown option: " .. option)
		end
	else
		hs.alert.show("ウィンドウは指定されていません！")
	end
end
-- 撤销最近一次动作
function Undo()
	local cwin = hs.window.focusedWindow()
	local cwinid = cwin:id()
	for idx,val in ipairs(winhistory) do
        -- Has this window been stored previously?
		if val[1] == cwinid then
			cwin:setFrame(val[2])
		end
	end
end
hotkey = require "hs.hotkey"
hyper = {"ctrl", "alt"}
--[[
function windowManagement(keyFuncTable)
	for key,fn in pairs(keyFuncTable) do
		hotkey.bind(hyper, "'" .. key .. "'", function() Resize("'" .. fn .. "'") end)
	end
end
windowManagement({
	--right = halfright,
	--left = halfleft,
	--up = halfup,
	--down = halfdown,
	c = center,
	--[return] = fullscreen,
	--delete = reset,
		})
--]]
hotkey.bind(hyper, 'right', function() Resize("halfright") end)
hotkey.bind(hyper, 'left', function() Resize("halfleft") end) 
hotkey.bind(hyper, 'up', function() Resize("halfup") end)
hotkey.bind(hyper, 'down', function() Resize("halfdown") end)
hotkey.bind(hyper, 'c', function() Resize("center") end)
hotkey.bind(hyper, 'return', function() Resize("fullscreen") end)
hotkey.bind(hyper, 'delete', function() Resize("reset") end)
