local iTunesBar = nil
local songtitle = nil
local songloved = nil
local songdisliked = nil
local songrating = nil
local songalbum = nil
local owner = hs.host.localizedName()
-- iTunes功能函数集 --
local iTunes = {}
-- 曲目信息
iTunes.title = function () 
	return hs.itunes.getCurrentTrack()
end
iTunes.artist = function () 
	local artist = hs.itunes.getCurrentArtist()
	return artist
end
iTunes.album = function () 
	local album = hs.itunes.getCurrentAlbum()
	return album
end
iTunes.loved = function () 
	local _,loved,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's loved]])
	return loved
end
iTunes.disliked = function () 
	local _,disliked,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's disliked]])
	return disliked
end
iTunes.rating = function () 
	local _,rating100,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's rating]])
	rating = rating100/20
	return rating
end
iTunes.state = function () 
	local _,state,_ = hs.osascript.applescript([[tell application "iTunes" to get player state as string]])
	return state
end
-- 跳转至当前播放的歌曲
iTunes.locate = function ()
	hs.osascript.applescript([[
		tell application "iTunes"
			activate
			tell application "System Events" to keystroke "l" using command down
		end tell
				]])
end
-- 保存专辑封面
iTunes.saveartwork = function ()
	-- 判断是否为Apple Music
	local _,kind,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's kind]])
	if string.len(kind) > 0 then --若为本地曲目
		local script = [[
			try
				tell application "iTunes"
					set theartwork to raw data of current track's artwork 1
					set theformat to format of current track's artwork 1
					if theformat is «class PNG » then
						set ext to ".png"
					else
						set ext to ".jpg"
					end if
				end tell
				set fileName to ("Macintosh HD:Users:userName:.hammerspoon:" & "currentartwork" & ext)
				set outFile to open for access file fileName with write permission
				set eof outFile to 0
				write theartwork to outFile
				close access outFile
			end try
					]]
		if owner == "鳳凰院カミのMacBook Pro" then
			saveartworkscript = script:gsub("userName","hououinkami")
		else
			saveartworkscript = script:gsub("userName","cynthia")
		end
		if hs.itunes.getCurrentAlbum() ~= songalbum then
			songalbum = hs.itunes.getCurrentAlbum()
			hs.osascript.applescript(saveartworkscript)
		end
		-- 获取图片后缀名
		local _,format,_ = hs.osascript.applescript([[tell application "iTunes" to get format of current track's artwork 1 as string]])
		if string.find(format, "PNG") then
			ext = "png"
		else
			ext = "jpg"
		end
		artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork." .. ext):setSize({h = 300, w = 300}, absolute == true)
	else -- 若为Apple Music
		local album = hs.itunes.getCurrentAlbum()
		local artist = hs.itunes.getCurrentArtist()
		local amurl = "https://itunes.apple.com/search?term=" .. hs.http.encodeForQuery(album .. " " .. artist) .. "&country=jp&entity=album&limit=1&output=json"
		--[[
		hs.http.asyncGet(amurl, nil, function(status, body, headers)
			if status == 200 then
				local songdata = hs.json.decode(body)
				artworkurl100 = songdata.results[1].artworkUrl100
			end
			artworkurl = artworkurl100:gsub("100x100", "1000x1000")
			local artworkfile = hs.image.imageFromURL(artworkurl):setSize({h = 300, w = 300}, absolute == true)
			artworkfile:saveToFile(hs.configdir .. "/currentartwork.jpg")
		end)
		--]]
		local status,body,headers = hs.http.get(amurl, nil)
		if status == 200 then
			local songdata = hs.json.decode(body)
			if songdata.resultCount ~= 0 then
				artworkurl100 = songdata.results[1].artworkUrl100
				artworkurl = artworkurl100:gsub("100x100", "1000x1000")
				local artworkfile = hs.image.imageFromURL(artworkurl):setSize({h = 300, w = 300}, absolute == true)
				artworkfile:saveToFile(hs.configdir .. "/currentartwork.jpg")
			end
		end
		if artworkurl ~= nil then
			artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork.jpg")
		else
			artwork = nil
		end
	end
	return artwork
end
-- 随机播放列表中曲目
local iTunesShuffleplay = {}
local _,library,_ = hs.osascript.applescript([[tell application "iTunes" to get name of playlists]])
for i=7, #(library) do
	local playscript = [[tell application "iTunes" to play playlist named pname]]
	local playlistscript = playscript:gsub("pname",  "\"" .. library[i] .. "\"")
	iTunesShuffleplay.i = function ()
		hs.osascript.applescript(playlistscript)
	end
end
-- menubar函数集 --
-- 删除Menubar
function deletemenubar()
	if iTunesBar ~= nil then
		iTunesBar:delete()
	end
end
-- 创建标题
function settitle()
	if iTunes.state() == "playing" then
		local infolength = string.len(iTunes.title() .. ' - ' .. iTunes.artist())
		if infolength < 90 then
			iTunesBar:setTitle('🎵' .. iTunes.title() .. ' - ' .. iTunes.artist())
		else
			iTunesBar:setTitle('🎵' .. iTunes.title())
		end
	elseif iTunes.state() == "paused" then
		iTunesBar:setTitle('⎮⎮' .. iTunes.title() .. ' - ' .. iTunes.artist())
	elseif iTunes.state() == "stopped" then
		iTunesBar:setTitle('■停止中')
	end
end
-- 创建菜单
function setmenu()
	if iTunes.state() ~= "stopped" then
		if iTunes.loved() == true then
			lovedtitle = "❤️ラブ済み"
		else
			lovedtitle = "🖤ラブ"
		end
		if iTunes.disliked() == true then
			dislikedtitle = "💔好きじゃない済み"
		else
			dislikedtitle = "🖤好きじゃない"
		end
		local ratingtitle5 = "⭑⭑⭑⭑⭑"
		local ratingtitle4 = "⭑⭑⭑⭑⭐︎"
		local ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		local ratingtitle2 = "⭑⭑⭐︎⭐︎⭐︎"
		local ratingtitle1 = "⭑⭐︎⭐︎⭐︎⭐︎"
		local star5 = false
		local star4 = false
		local star3 = false
		local star2 = false
		local star1 = false
		if iTunes.rating() == 5 then
			ratingtitle5 = hs.styledtext.new("⭑⭑⭑⭑⭑", {color = {hex = "#0000FF", alpha = 1}})
			star5 = true
		elseif iTunes.rating() == 4 then
			ratingtitle4 = hs.styledtext.new("⭑⭑⭑⭑⭐︎", {color = {hex = "#0000FF", alpha = 1}})
			star4 = true
		elseif iTunes.rating() == 3 then
			ratingtitle3 = hs.styledtext.new("⭑⭑⭑⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
			star3 = true
		elseif iTunes.rating() == 2 then
			ratingtitle2 = hs.styledtext.new("⭑⭑⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
			star2 = true
		elseif iTunes.rating() == 1 then
			ratingtitle1 = hs.styledtext.new("⭑⭐︎⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
			star1 = true
		end
		if artwork ~= nil then
			imagemenu = {title = "", image = artwork, fn = iTunes.locate}
		else
			imgaemenu = {}
		end
		if owner == "鳳凰院カミのMacBook Pro" then
			lovedmenu = {title = lovedtitle, fn = function() hs.osascript.applescript([[
						tell application "iTunes"
							if current track's loved is false then
								set current track's loved to true
							else
								set current track's loved to false
							end if
						end tell
						]]) end}
			dislikedmenu = {title = dislikedtitle, fn = function() hs.osascript.applescript([[
						tell application "iTunes"
							if current track's disliked is false then
								set current track's disliked to true
							else
								set current track's disliked to false
							end if
						end tell
						]]) end}
		else
			lovedmenu = {}
			dislikedmenu = {}
		end
		-- 显示菜单
		iTunesBarMenu = {
			imagemenu,
			{title = "🎸" .. iTunes.title(), fn = iTunes.locate},
			{title = "👩🏻‍🎤" .. iTunes.artist(), fn = iTunes.locate},
			{title = "💿" .. iTunes.album(), fn = iTunes.locate},
			{title = "-"},
			lovedmenu,
			dislikedmenu,
			{title = ratingtitle5, checked = star5, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 100]]) end},
			{title = ratingtitle4, checked = star4, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 80]]) end},
			{title = ratingtitle3, checked = star3, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 60]]) end},
			{title = ratingtitle2, checked = star2, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 40]]) end},
			{title = ratingtitle1, checked = star1, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 20]]) end},
				}
	else
		-- 获取播放列表
		local _,library,_ = hs.osascript.applescript([[tell application "iTunes" to get name of playlists]])
		local iTunesBarMenu = {}
		for i=7, #(library) do
			table.insert(iTunesBarMenu, {title = library[i], fn = iTunesShuffleplay.i})
		end
	end
	return iTunesBarMenu
end
-- 延迟函数
function delay(gap, func)
	local delaytimer = hs.timer.delayed.new(gap, func)
	delaytimer:start() 
end
-- 更新Menubar
function updatemenubar()
	if iTunes.state() ~= "stopped" then
		if iTunes.title() ~= songtitle or iTunes.loved() ~= songloved or iTunes.disliked() ~= songdisliked or iTunes.rating() ~= songrating then --若更换了曲目
			songtitle = iTunes.title()
			songloved = iTunes.loved()
			songdisliked = iTunes.disliked()
			songrating = iTunes.rating()
			iTunes.saveartwork()
		end
	end
	settitle()
	--delay(1, iTunes.saveartwork)
end
-- 创建Menubar
function setitunesbar()
	if hs.itunes.isRunning() then -- 若iTunes正在运行
		-- 若首次播放则新建menubar item
		if iTunesBar == nil then
			iTunesBar = hs.menubar.new()
			iTunesBar:setTitle('🎵iTunes')
		end
		updatemenubar()
	else -- 若iTunes没有运行
		deletemenubar()
	end
	hs.timer.doAfter(1, setitunesbar)
end
setitunesbar()
iTunesBar:setMenu(setmenu)
