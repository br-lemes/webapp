
package.loaded.lfs = lfs
local json = require("json")
local mustache = require("mustache")

mg.write("HTTP/1.0 200 OK\r\n")
mg.write("Date:" .. os.date("! %a, %d %b %Y %H:%M:%S GMT") .. "\r\n")
mg.write("Cache-Control: max-age=3600\r\n")
mg.write("Last-Modified:" .. os.date("! %a, %d %b %Y %H:%M:%S GMT",
	lfs.attributes("www/index.lua", "modification")) .. "\r\n")
mg.write("Content-Type: text/html; charset=UTF-8\r\n")
mg.write("Connection: close\r\n")
mg.write("\r\n")

local view = { }
view.applist = { }

for file in lfs.dir("www") do
	if file ~= "." and file ~= ".." then
		local mode = lfs.attributes("www/" .. file, "mode")
		if mode == "directory" then
			local f, e = io.open(string.format("www/%s/info.json", file))
			if f then
				local buf = f:read("*a")
				f:close()
				local app = json.decode(buf)
				app.href = file
				table.insert(view.applist, app)
			end
		end
	end
end

local f, e = io.open("mustache/index")
if not f then error(e) end
local template = f:read("*a")
f:close()
mg.write(mustache.render(template, view))
