#!/usr/bin/env lua

require "ubus"
require "uloop"
require "lunced.tools"
require "lunced.local"
require "lunced.bmx"
JSON = (loadfile "/usr/share/lunced/JSON.lua")()
RUNDIR = "/var/run/lunced"
PIDFILE = "pid"
STATFILE = "/proc/self/stat"

local fstat = assert(io.open(STATFILE, "r"))
local pid = fstat:read("*number")
fstat:close()

os.execute("mkdir -p " .. RUNDIR)

local fpid = assert(io.open( RUNDIR .. "/" .. PIDFILE, "w+"))
io.output(fpid)
io.write(pid)
io.write("\n")
fpid:close()

local selfInfo = {}

uloop.init()

local timeout = 10
local tries = 2
local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local lunced_method = {
	lunced = {
		listnodes = {
			function(req, msg)
				-- get nodes
				conn:reply(req, lunced_bmx6_nodes(selfInfo));
				debugMsg("Call to function 'nodes'")
			end, { nodes = ubus.STRING }
		},
		neighbours = {
			function(req)
				conn:reply(req, lunced_bmx6_neighbours(selfInfo));
				debugMsg("Call to function 'neighbours'")
			end, { nodes = ubus.STRING }
		},
		self = {
			function(req)
				conn:reply(req, lunced_bmx6_local(selfInfo));
				debugMsg("Call to function 'self'")
			end, {id = ubus.STRING, name = ubus.STRING }
		},
		systemBoard = {
			function(req)
				conn:reply(req, conn:call("system", "board", {}));
				debugMsg("Call to function 'systemBoard'")
			end, {systemBoard = ubus.STRING}
		},
		systemInfo = {
			function(req)
				conn:reply(req, conn:call("system", "info", {}));
				debugMsg("Call to function 'systemInfo'")
			end, {systemBoard = ubus.STRING}
		},
		version = {
			function(req)
				conn:reply(req, lunced_local_version(selfInfo) );
				debugMsg("Call to function 'version'")
			end, { version = ubus.STRING }
		},
		reply = {
			function(req, msg)
				local data = ""
				debugMsg("Call to function 'reply'")
				url = ""
				cmd = ""
				for k,v in pairs(msg) do
					if tostring(k) == "id" then
						toIP = uuid2ipv6(tostring(v))
					end
					if tostring(k) == "cmd" then
						cmd = tostring(v)
					end
				end

				if selfInfo.id == nil then
					 lunced_bmx6_getSelfInfo(selfInfo)
				end

				if toIP == uuid2ipv6(selfInfo.id) then
					if cmd == "listnodes" then
						data = lunced_bmx6_nodes(selfInfo)
					elseif cmd == "neighbours" then
						data = lunced_bmx6_neighbours(selfInfo)
					elseif cmd == "self" then
						data = lunced_bmx6_local(selfInfo)
					elseif cmd == "version" then
						data = lunced_local_version(selfInfo)
					end

				elseif node_in_nodes(ipv62uuid(toIP), lunced_bmx6_nodes(selfInfo).nodes) then
					local command = "/usr/bin/wget -T ".. timeout .." -t " .. tries .. " -qO - http://[" .. tostring(toIP) .. "]/cgi-bin/lunced?cmd=" .. tostring(cmd)
					local dataString = run(command)
					if dataString == "" then
						dataString = errorCode(100)
					end
					data = JSON:decode(dataString)

				else
					data = JSON:decode(errorCode(101))
				end

				if data ~= "" then
					conn:reply(req, data )
				end
			end, { cmd = ubus.STRING }
		}

	}
}

conn:add(lunced_method)

local lunced_event = {
	lunced = function(msg)
		print("Call to lunced event")
		for k, v in pairs(msg) do
			print("key=" .. k .. " value=" .. tostring(v))
		end
	end,
}

conn:listen(lunced_event)

uloop.run()
