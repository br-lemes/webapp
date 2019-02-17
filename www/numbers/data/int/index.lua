
local webapp = require("pkg.webapp")

local default = {
	number  = 0,
	count   = 3,
	ndays   = tonumber(os.date("%H")) >= 10 and 21 or 20,
	digits  = 3,
	xoffset = 40,
	yoffset = 15,
	profile = "int",
}

if mg.request_info.request_method == "GET" then
	local data = webapp.read("data/numint.json")
	data = webapp.default(data, default)
	data = webapp.encode(data)
	webapp.send(data ~= nil, data)
else
	webapp.send_notallowed()
end
