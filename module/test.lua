

local abar = hs.menubar.new()
function atime()
timeatime = os.time()
return timeatime
end
abar:setMenu({
{title = atime},
})
--hs.hotkey.bind({"alt","ctrl","cmd"}, 'd', abar:delete())
