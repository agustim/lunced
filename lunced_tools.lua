

function run(command)
	print ("Try to execute: " .. command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end