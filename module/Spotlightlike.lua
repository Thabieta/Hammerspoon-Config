local search = nil
local base = {
		[1] = { name = "百度", baseurl = "https://www.baidu.com/s?wd=keyword", },
		[2] = { name = "Google", baseurl = "https://www.google.com/search?q=keyword", },
		[3] = { name = "ウィキペディア", baseurl = "https://ja.wikipedia.org/wiki/keyword", },
		[4] = { name = "Google翻訳", baseurl = "https://translate.google.com/#view=home&op=translate&sl=auto&tl=zh-CN&text=keyword", },
	}
-- 生成搜索列表
function searchList()
	local choices = {}
	local query = hs.http.encodeForQuery(search:query()):gsub("%%", "%%%%")
       	for key,data in ipairs(base) do
       			local full_url = data["baseurl"]:gsub ("keyword", query)
        		local choice = {}
        		choice["text"] = data["name"]
			--choice["subText"] = full_url
        		choice["fullurl"] = full_url
        		table.insert(choices, choice)
	end
	return choices
end
-- 执行的动作
function searchcompletionCallback(rowInfo)
	if rowInfo == nil or string.len(search:query()) == 0 then
        	return
	elseif string.find(search:query(), "://") ~= nil or string.find(search:query(), "www.") ~= nil or string.find(search:query(), ".com") ~= nil or string.find(search:query(), ".jp") ~= nil then
		hs.urlevent.openURLWithBundle(search:query(), "com.apple.Safari")
	else
		hs.urlevent.openURLWithBundle(rowInfo["fullurl"], "com.apple.Safari")
    	end
end
-- 搜索关键词改变时的行为
function queryChangedCallback()
	if queryChangedTimer then
		queryChangedTimer:stop()
	end
	queryChangedTimer = hs.timer.doAfter(0.2, function() 
			search:choices(searchList()) 
			search:refreshChoicesCallback()	end)
end
-- 输出Spotlight式输入框
function searchMain()
	search = hs.chooser.new(searchcompletionCallback)
	search:placeholderText("検索したいキーワードを入力")
	search:rows(4)
	search:queryChangedCallback(queryChangedCallback)
	if search:isVisible() then 
		search:hide()
	else 
		search:show()
	end
	return search
end
hs.hotkey.bind({"alt"}, 'space', "Toggle show chooser", searchMain)
