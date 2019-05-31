hs.window.animationDuration = 0
local winhistory = {}
-- 记录窗口初始位置
function windowStash(window)
	local winid = window:id()
	local winf = window:frame()
	if #winhistory > 50 then
		table.remove(winhistory)
	end
	local winstru = {winid, winf}
	-- table.insert(winhistory, winstru) 注释掉本栏目后面几行取消注释该行则为记录窗口历史
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
			local cwinid = cwin:id()
			for idx,val in ipairs(winhistory) do
				if val[1] == cwinid then
					cwin:setFrame(val[2])
				end
			end
		end
	end
end
hotkey = require "hs.hotkey"
hyper = {"ctrl", "alt"}
function windowsManagement(keyFuncTable)
	for key,opt in pairs(keyFuncTable) do
		hotkey.bind(hyper, key, Resize(opt))
	end
end
hotkey.bind(hyper, 'return', Resize(fullscreen))
windowsManagement({
		left = halfleft,
		right = halfright,
		up = halfup,
		down = halfdown,
		c = center,
		delete = reset,
	})
--[[
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
