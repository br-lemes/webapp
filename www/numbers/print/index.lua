
local webapp = require("pkg.webapp")

local default_vol = {
	number  = 1,
	count   = 3,
	ndays   = tonumber(os.date("%H")) >= 10 and 8 or 7,
	digits  = 3,
	xoffset = 40,
	yoffset = 15,
	profile = "vol",
}

local default_int = {
	number  = 1,
	count   = 3,
	ndays   = tonumber(os.date("%H")) >= 10 and 21 or 20,
	digits  = 3,
	xoffset = 40,
	yoffset = 15,
	profile = "int",
}

if mg.request_info.request_method == "POST" then
	local data, e = webapp.decode(mg.read())
	if not data then webapp.send_error(e) return end
	if data.profile == "vol" then
		data = webapp.default(data, default_vol)
	elseif data.profile == "int" then
		data = webapp.default(data, default_int)
	else webapp.send_error("No profile") return end

	local p, e = io.open("LPT1:", "w") -- WARNING: Windows only
	if not p then webapp.send_error(e) return end
	local date
	if data.ndays and data.ndays > 0 then
		date = os.date("*t")
		date.day = date.day + data.ndays
		date = os.date("%d/%m/%Y", os.time(date))
	end
	local format = "^FO%d,%d^A0R,%d,%d^FD%s^FS\n"
	for i = 1, math.ceil(data.count / 3) do
		local s,e = p:write("^XA\n")
		if not s then webapp.send_error(e) return end
		for j = 1, 3 do
			if date then
				local s, e = p:write(string.format(format,
					data.xoffset + ((j - 1) * 220),
					data.yoffset, 35, 35, "ATE " .. date))
				if not s then webapp.send_error(e) return end
			end
			local s, e = p:write(string.format(format,
				data.xoffset + ((j - 1) * 220), data.yoffset, 185, 185,
				string.format(string.format("%%0%dd", data.digits), data.number)))
			if not s then webapp.send_error(e) return end
			data.number = data.number + 1
		end
		local s, e = p:write("^XZ\n")
		if not s then webapp.send_error(e) return end
	end
	p:close()
	webapp.send_ok()
	local f, e = io.open(data.profile == "vol" and "data/numvol.json" or "data/numint.json", "w")
	if not f then mg.write(e, "\r\n") return end
	data.ndays = nil
	data = webapp.encode(data)
	local s, e = f:write(data)
	f:close()
	if not s then mg.write(e, "\r\n") return end
	mg.write(data, "\r\n")
else
	webapp.send_notallowed()
end
