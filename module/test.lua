local _,library,_ = hs.osascript.applescript([[tell application "iTunes" to get name of playlists]])
local playlist = {}
local menulist = {}
for i=7, #(library) do
		--playlist.title = library[i]
		--playlist.fn = "1"
table.insert(menulist, {title = library[i], fn = "1"})
	end
print(menulist[1].title)
