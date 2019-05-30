local iTunesBar = nil
local songtitle = nil
local songloved = nil
local songdisliked = nil
local songrating = nil
local songalbum = nil
local owner = hs.host.localizedName()
-- 删除Menubar
function deletemenubar()
	if iTunesBar ~= nil then
		iTunesBar:delete()
	end
end
-- 创建标题
function settitle()
	local track = hs.itunes.getCurrentTrack()
	local artist = hs.itunes.getCurrentArtist()
	local album = hs.itunes.getCurrentAlbum()
	local itunesinfo = '🎵' .. track .. ' - ' .. artist
	local infolength = string.len(itunesinfo)
	if infolength < 90 then
		iTunesBar:setTitle(itunesinfo)
	else
		iTunesBar:setTitle('🎵' .. track)
	end
end
-- 跳转至当前播放的歌曲
function locate()
	hs.osascript.applescript([[
		tell application "iTunes"
			activate
			tell application "System Events" to keystroke "l" using command down
		end tell
				]])
end
-- 保存本地曲目的专辑封面
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
function saveartwork()
	if hs.itunes.getCurrentAlbum() ~= songalbum then
		songalbum = hs.itunes.getCurrentAlbum()
	hs.osascript.applescript(saveartworkscript)
	end
end
-- 获取Apple Music曲目的专辑封面
function saveartworkam()
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
	return artworkurl
end
-- 创建菜单
function setmenu()
	local track = hs.itunes.getCurrentTrack()
	local artist = hs.itunes.getCurrentArtist()
	local album = hs.itunes.getCurrentAlbum()
	local _,loved,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's loved]])
	local _,disliked,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's disliked]])
	local _,rating,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's rating]])
	if loved == true then
		lovedtitle = "❤️ラブ済み"
	else
		lovedtitle = "🖤ラブ"
	end
	if disliked == true then
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
	if rating == 100 then
		ratingtitle5 = hs.styledtext.new("⭑⭑⭑⭑⭑", {color = {hex = "#0000FF", alpha = 1}})
		star5 = true
	elseif rating == 80 then
		ratingtitle4 = hs.styledtext.new("⭑⭑⭑⭑⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		star4 = true
	elseif rating == 60 then
		ratingtitle3 = hs.styledtext.new("⭑⭑⭑⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		star3 = true
	elseif rating == 40 then
		ratingtitle2 = hs.styledtext.new("⭑⭑⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		star2 = true
	elseif rating == 20 then
		ratingtitle1 = hs.styledtext.new("⭑⭐︎⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		star1 = true
	end
	saveartwork()
	-- 判断是否为Apple Music
	local _,kind,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's kind]])
	if string.len(kind) > 0 then
		-- 获取图片后缀名
		local _,format,_ = hs.osascript.applescript([[tell application "iTunes" to get format of current track's artwork 1 as string]])
		if string.find(format, "PNG") then
			ext = "png"
		else
			ext = "jpg"
		end
		local artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork." .. ext):setSize({h = 300, w = 300}, absolute == true)
		imagemenu = {title = "", image = artwork, fn = locate}
	else
		local artworkurl = saveartworkam()
		if artworkurl ~= nil then
			local artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork.jpg")
			imagemenu = {title = "", image = artwork, fn = locate}
		else
			imgaemenu = {}
		end
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
	iTunesBar:setMenu({
			imagemenu,
			{title = "🎸" .. track, fn = locate},
			{title = "👩🏻‍🎤" .. artist, fn = locate},
			{title = "💿" .. album, fn = locate},
			{title = "-"},
			lovedmenu,
			dislikedmenu,
			{title = ratingtitle5, checked = star5, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 100]]) end},
			{title = ratingtitle4, checked = star4, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 80]]) end},
			{title = ratingtitle3, checked = star3, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 60]]) end},
			{title = ratingtitle2, checked = star2, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 40]]) end},
			{title = ratingtitle1, checked = star1, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 20]]) end},
			})
end
-- 延迟函数
function delay(gap, func)
	local delaytimer = hs.timer.delayed.new(gap, func)
	delaytimer:start() 
end
-- 更新Menubar
function updatemenubar()
	local track = hs.itunes.getCurrentTrack()
	local _,loved,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's loved]])
	local _,disliked,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's disliked]])
	local _,rating,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's rating]])
	if track ~= songtitle or loved ~= songloved or disliked ~= songdisliked or rating ~= songrating then --若更换了曲目
		songtitle = track
		songloved = loved
		songdisliked = disliked
		songrating = rating
		settitle()
		delay(1, setmenu)
	end
end
-- 创建Menubar
function setitunesbar()
	if hs.itunes.isRunning() then -- 若iTunes正在运行
		-- 若首次播放则新建menubar item
		if iTunesBar == nil and hs.itunes.getCurrentTrack() ~= nil then
			iTunesBar = hs.menubar.new()
		end
		if hs.itunes.getCurrentTrack() ~= nil then
			updatemenubar()
		else -- 若iTunes停止播放
			deletemenubar()
		end
	else -- 若iTunes没有运行
		deletemenubar()
	end
	hs.timer.doAfter(1, setitunesbar)
end
setitunesbar()
