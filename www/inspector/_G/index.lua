
package.loaded.lfs = lfs
local mustache = require("mustache")

local view = { }

mg.write("HTTP/1.0 200 OK\r\n")
mg.write("Date:", os.date("! %a, %d %b %Y %H:%M:%S GMT"), "\r\n")
mg.write("Cache-Control: no-cache\r\n")
mg.write("Content-Type: text/html; charset=UTF-8\r\n")
mg.write("Connection: close\r\n")
mg.write("\r\n")

view.path_info = string.format("/_G%s", mg.request_info.path_info or "")
view.path_path = { }

view.table = { }
local full = ""
local t = _G
for p in view.path_info:gmatch("/([^/]*)") do
	t = t[p]
	full = string.format("%s/%s", full, p)
	table.insert(view.path_path, {path = p, full = full})
end
for k,v in pairs(t) do
	local key = k
	if type(v) == "table" then
		key = string.format(
			[[<a href="#" onclick="loadTable('/inspector%s/%s');">%s</a>]],
			view.path_info, k, k)
	end
	table.insert(view.table, {k = k, v = v, key = key, value = tostring(v)})
end

local function sort(a, b)
	local typea = type(a.v) == "table"
	local typeb = type(b.v) == "table"
	if typea and typeb then
		return a.k < b.k
	end
	if not typea and not typeb then
		return a.k < b.k
	end
	return typea
end

table.sort(view.table, sort)

local template = [[
		<h1 class="section row">
			{{#path_path}}
			<a href="#" onclick="loadTable('/inspector{{full}}');">
				/{{path}}
			</a>
			{{/path_path}}
		</h1>
		<div class="section">
			<table>
				<thead>
					<tr>
						<th>Key</th>
						<th>Value</th>
					</tr>
				</thead>
				<tbody>
					{{#table}}
					<tr>
						<td data-label="Key">{{{key}}}</td>
						<td data-label="Value">{{value}}</td>
					</tr>
					{{/table}}
				</tbody>
			</table>
		</div>
]]

local snippet = mg.get_var(mg.request_info.query_string, "snippet") == "true"
if snippet then
	mg.write(mustache.render(template, view))
else
	mg.write(string.format([[
<!DOCTYPE html>
<html lang="pt-br">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<link href="/mini-default.min.css" rel="stylesheet">
	<link rel="icon" href="/fatcow/16/document_inspector.png">
	<title>Inspecionar</title>
	<style>body { background-color: #eee; }</style>
	<script>
		var output;
		function loadTable(path) {
			fetch(path + "?snippet=true")
				.then(function(response) { return response.text(); })
				.then(function(data) { output.innerHTML = data; });
		};
		document.addEventListener("DOMContentLoaded", function() {
			output = document.getElementById("output");
		});
	</script>
</head>
<body>
	<header class="row sticky">
		<a href="/" class="col-sm button">
			<img src="/fatcow/32/bullet_back.png" width="32" height="32" alt="Voltar">
		</a>
		<a href="/inspector" class="col-sm button">
			<img src="/fatcow/32/document_inspector.png" width="32" height="32" alt="Inspecionar">
		</a>
	</header>
	<div class="card fluid container" id="output">
%s
	</div>
</body>
</html>
]], mustache.render(template, view)))
end
