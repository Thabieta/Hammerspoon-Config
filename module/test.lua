local _,library,_ = hs.osascript.applescript([[tell application "iTunes" to get name of playlists]])
local playlist = {}
for i=7, #(library) do
	table.insert(playlist, {title = library[i], fn = shuffleplay(library[i])})
end
function shuffleplay(playlistname)
	local playscript = [[tell application "iTunes" to play playlist named pname]]
	hs.osascript.applescript(playscript:gsub("pname", "playlistname"))
end

local abar = hs.menubar.new()
function atime()
timeatime = os.time()
return timeatime
end
abar:setMenu({
{title = atime},
})
hs.hotkey.bind({"alt","ctrl","cmd"}, 'd', abar:delete())
