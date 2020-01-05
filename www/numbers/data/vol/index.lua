
local webapp = require("webapp")

local default = {
	number  = 1,
	count   = 3,
	ndays   = tonumber(os.date("%H")) >= 10 and 8 or 7,
	digits  = 3,
	xoffset = 40,
	yoffset = 15,
	profile = "vol",
}

if mg.request_info.request_method == "GET" then
	local data = webapp.read("data/numvol.json")
	data = webapp.default(data, default)
	data = webapp.encode(data)
	webapp.send(data ~= nil, data)
else
	webapp.send_notallowed()
end
