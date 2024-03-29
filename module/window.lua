hs.window.animationDuration = 0
local winhistory = {}
local windowMeta = {}
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
-- 窗口定义
function windowMeta.new()
	local self = setmetatable(windowMeta, {
			__call = function (cls, ...)
				return cls.new(...)
			end,
		})
	self.window = hs.window.focusedWindow()
	self.screen = self.window:screen()
	self.resolution = self.screen:fullFrame()
	self.windowFrame = self.window:frame()
	self.screenFrame = self.screen:frame()
	return self
end
-- 窗口动作
local Resize = {}
Resize.halfleft = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:setFrame({this.screenFrame.x, this.screenFrame.y, this.screenFrame.w/2, this.screenFrame.h})
end
Resize.halfright = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:setFrame({this.screenFrame.x+this.screenFrame.w/2, this.screenFrame.y, this.screenFrame.w/2, this.screenFrame.h})
end
Resize.halfup = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:setFrame({this.screenFrame.x, this.screenFrame.y, this.screenFrame.w, this.screenFrame.h/2})
end
Resize.halfdown = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:setFrame({this.screenFrame.x, this.screenFrame.y+this.screenFrame.h/2, this.screenFrame.w, this.screenFrame.h/2})
end
Resize.fullscreen = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:setFrame({x=this.resolution.x, y=this.resolution.y, w=this.resolution.w, h=this.resolution.h})
end
Resize.center = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:centerOnScreen()
end
Resize.reset = function ()
	local this = windowMeta.new()
	local thisid = this.window:id()
	for idx,val in ipairs(winhistory) do
		if val[1] == thisid then
			this.window:setFrame(val[2])
		end
	end
end
Resize.toleft = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:move({0,(this.screenFrame.h-this.windowFrame.h)/2,this.windowFrame.w,this.windowFrame.h})
end
Resize.toright = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:move({this.screenFrame.w-this.windowFrame.w,(this.screenFrame.h-this.windowFrame.h)/2,this.windowFrame.w,this.windowFrame.h})
end
Resize.toup = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:move({this.windowFrame.x,0,this.windowFrame.w,this.windowFrame.h})
end
Resize.todown = function ()
	local this = windowMeta.new()
	windowStash(this.window)
	this.window:move({this.windowFrame.x,this.screenFrame.h-this.windowFrame.h,this.windowFrame.w,this.windowFrame.h})
end
hotkey = require "hs.hotkey"
hyper = {"ctrl", "alt"}
Hyper = {"ctrl", "alt", "command"}
function windowsManagement(hyperkey,keyFuncTable)
	for key,fn in pairs(keyFuncTable) do
		hotkey.bind(hyperkey, key, fn)
	end
end
hotkey.bind(hyper, 'return', Resize.fullscreen)
windowsManagement(hyper,{
		left = Resize.halfleft,
		right = Resize.halfright,
		up = Resize.halfup,
		down = Resize.halfdown,
		c = Resize.center,
		delete = Resize.reset,
	})
windowsManagement(Hyper,{
		left = Resize.toleft,
		right = Resize.toright,
		up = Resize.toup,
		down = Resize.todown,
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
hotkey.bind(hyper, 'right', function() Resize("halfright") end)
hotkey.bind(hyper, 'left', function() Resize("halfleft") end) 
hotkey.bind(hyper, 'up', function() Resize("halfup") end)
hotkey.bind(hyper, 'down', function() Resize("halfdown") end)
hotkey.bind(hyper, 'c', function() Resize("center") end)
hotkey.bind(hyper, 'return', function() Resize("fullscreen") end)
hotkey.bind(hyper, 'delete', function() Resize("reset") end)
--]]
