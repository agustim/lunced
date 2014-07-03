

function run(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end