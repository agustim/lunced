#!/usr/bin/env lua

require "ubus"
require "uloop"
JSON = (loadfile "JSON.lua")()
require "lunced_tools"
require "lunced_local"
require "lunced_bmx"

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
		version = {
			function(req)
				conn:reply(req, lunced_local_version(selfInfo) );
				debugMsg("Call to function 'version'")
			end, { version = ubus.STRING }
		},
		reply = {
			function(req, msg)
				local datos = ""
				debugMsg("Call to function 'reply'")
				url = ""
				cmd = ""
				for k,v in pairs(msg) do
					if tostring(k) == "id" then 
						toIP = uuid2ipp(tostring(v))
					end
					if tostring(k) == "cmd" then
						cmd = tostring(v)
					end
				end
				if selfInfo.id == nil then
					 lunced_bmx6_getSelfInfo(selfInfo)
				end
				if toIP == uuid2ipp(selfInfo.id) then
					if cmd == "listnodes" then
						datos = lunced_bmx6_nodes(selfInfo)
					elseif cmd == "neighbours" then
						datos = lunced_bmx6_neighbours(selfInfo)
					elseif cmd == "self" then
						datos = lunced_bmx6_local(selfInfo)
					elseif cmd == "version" then
						datos = lunced_local_version(selfInfo)
					end
				else
					local comando = "/usr/bin/wget -T ".. timeout .." -t " .. tries .. " -qO - http://[" .. tostring(toIP) .. "]/cgi-bin/lunced?cmd=" .. tostring(cmd)
					local datosString = run(comando)
					if datosString == "" then
						datosString = errorCode(100)
					end
					datos = JSON:decode(datosString)
				end
				if datos ~= "" then
					conn:reply(req, datos )
				end
			end, { cmd = ubus.STRING }
		}

	}
}

conn:add(lunced_method)

local lunced_event = {
	lunced = function(msg)
		print("Call to lucent event")
		for k, v in pairs(msg) do
			print("key=" .. k .. " value=" .. tostring(v))
		end
	end,
}

conn:listen(lunced_event)

uloop.run()