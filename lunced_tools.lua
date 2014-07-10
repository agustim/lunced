

function run(command)
	debugMsg ("Try to execute: " .. command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

function errorCode(num)
	return '{ "error" : "' .. tostring(num) .. '" }'
end

function debugMsg(msg)
	local debug = 0
	if debug == 1 then
		print (msg)
	end
end