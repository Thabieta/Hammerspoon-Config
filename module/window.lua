hs.window.animationDuration = 0
local winhistory = {}
--[[
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
--]]
-- 记录窗口初始位置
local function windowStash(window)
	local winid = window:id()
	local winf = window:frame()
	if #winhistory > 50 then
		table.remove(winhistory)
	end
	local winstru = {winid, winf}
	local exist = false
	for idx,val in ipairs(winhistory) do
		if val[1] == winid then
			exist = true
		end
	end
	if exist == false then
		table.insert(winhistory, winstru) 
	end
end
-- 窗口动作
local cscreen = cwin:screen()
local cres = cscreen:fullFrame()
local wf = cwin:frame()
local Resize = {}
Resize.halfleft = function ()
	windowStash(cwin)
	cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
end
Resize.halfright = function ()
	windowStash(cwin)
	cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
end
Resize.halfup = function ()
	windowStash(cwin)
	cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
end
Resize.halfdown = function ()
	windowStash(cwin)
	cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
end
Resize.fullscreen = function ()
	windowStash(cwin)
	cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
end
Resize.center = function ()
	windowStash(cwin)
	cwin:centerOnScreen()
end
Resize.reset = function ()
	local cwin = hs.window.focusedWindow()
	local cwinid = cwin:id()
	for idx,val in ipairs(winhistory) do
		if val[1] == cwinid then
			cwin:setFrame(val[2])
		end
	end
end
hotkey = require "hs.hotkey"
hyper = {"ctrl", "alt"}
local enter = "return"
function windowsManagement(keyFuncTable)
	for key,fn in pairs(keyFuncTable) do
		hotkey.bind(hyper, key, fn)
	end
end
windowsManagement({
		left = Resize.halfleft,
		right = Resize.halfright,
		up = Resize.halfup,
		down = Resize.halfdown,
		enter = Resize.fullscreen,
		delete = Resize.reset,
	})
--[[
function Resize(option)
	local cwin = hs.window.focusedWindow()
	if cwin then
		local cscreen = cwin:screen()
		local cres = cscreen:fullFrame()
		local wf = cwin:frame()
		if option == "halfleft" then
			windowStash(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfright" then
			windowStash(cwin)
			cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfup" then
			windowStash(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
		elseif option == "halfdown" then
			windowStash(cwin)
			cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
		elseif option == "fullscreen" then
			windowStash(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
		elseif option == "center" then
			windowStash(cwin)
			cwin:centerOnScreen()
		elseif option == "reset" then
			local cwin = hs.window.focusedWindow()
			local cwinid = cwin:id()
			for idx,val in ipairs(winhistory) do
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
hotkey.bind(hyper, 'right', function() Resize("halfright") end)
hotkey.bind(hyper, 'left', function() Resize("halfleft") end) 
hotkey.bind(hyper, 'up', function() Resize("halfup") end)
hotkey.bind(hyper, 'down', function() Resize("halfdown") end)
hotkey.bind(hyper, 'c', function() Resize("center") end)
hotkey.bind(hyper, 'return', function() Resize("fullscreen") end)
hotkey.bind(hyper, 'delete', function() Resize("reset") end)
--]]
