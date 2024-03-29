local cmdArr = {
    "cd ~/.hammerspoon && git pull",
}
function shell(cmd)
    result = hs.osascript.applescript(string.format('do shell script "%s"', cmd))
end
function runAutoScripts()
    for key, cmd in ipairs(cmdArr) do
        shell(cmd)
    end
    hs.reload()
end
hs.timer.doEvery(86400, runAutoScripts)
