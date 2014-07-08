#!/usr/bin/env lua

require "ubus"
require "uloop"
JSON = (loadfile "JSON.lua")()
require "lunced_tools"
require "lunced_local"
require "lunced_bmx"

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local lunced_method = {
	lunced = {
		listnodes = {
			function(req, msg)
				-- get nodes
				conn:reply(req, lunced_bmx6_nodes());
				print("Call to function 'nodes'")
			end, { nodes = ubus.STRING }
		},
		neighbours = {
			function(req)
				conn:reply(req, lunced_bmx6_neighbours());
				print("Call to function 'neighbours'")
			end, { nodes = ubus.STRING }
		},
		self = {
			function(req)
				conn:reply(req, lunced_bmx6_local());
				print("Call to function 'self'")
			end, {id = ubus.STRING, name = ubus.STRING }
		},
		version = {
			function(req)

				conn:reply(req, lunced_local_version() );
				print("Call to function 'version'")
			end, { version = ubus.STRING }
		},
		reply = {
			function(req, msg)
				print("Call to function 'reply'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
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