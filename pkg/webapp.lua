
package.loaded.lfs = lfs
local json = require("json")

function send_info()
	mg.write("Date:" .. os.date("! %a, %d %b %Y %H:%M:%S GMT") .. "\r\n")
	mg.write("Connection: close\r\n")
	mg.write("\r\n")
end

function send_ok(body)
	mg.write("HTTP/1.0 200 OK\r\n")
	mg.write("Content-Type: application/json\r\n")
	mg.write("Cache-Control: no-cache\r\n")
	send_info()
	if body then
		mg.write(body, "\r\n")
	end
end

function send_error(body)
	mg.write("HTTP/1.0 500 Internal Server Error\r\n")
	send_info()
	if body then
		mg.write(body, "\r\n")
	end
end

function send_notallowed()
	mg.write("HTTP/1.0 405 Method Not Allowed\r\n")
	send_info()
end

function send(status, body)
	if status then send_ok(body) else send_error(body) end
end

function default(data, default)
	if not data then return default end
	local r = { }
	for k, v in pairs(default) do
		local vt = type(v)
		local dt = type(data[k])
		if vt == "number" and dt ~= "number" then
			data[k] = tonumber(data[k])
		elseif vt == "string" and dt ~= "string" then
			data[k] = tostring(data[k])
		end
		if data[k] and type(data[k]) == vt then
			r[k] = data[k]
		else
			r[k] = v
		end
	end
	return r
end

function encode(data)
	local s, r = pcall(json.encode, data)
	if s then return r else return nil, r end
end

function decode(data)
	local s, r = pcall(json.decode, data)
	if s then return r else return nil, r end
end

function read(name)
	local f, e = io.open(name)
	if not f then return f, e end
	local b, e = f:read("*a")
	if not b then return b, e end
	f:close()
	return decode(b)
end

return {
	send_ok         = send_ok,
	send_error      = send_error,
	send_notallowed = send_notallowed,
	send            = send,
	default         = default,
	encode          = encode,
	decode          = decode,
	read            = read,
}
