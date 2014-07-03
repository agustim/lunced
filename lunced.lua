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
	broken = {
		nodes = 1,
		neighbours = {
			function(req)
			end, {id = "fail" }
		},
	},
	lucend = {
		listnodes = {
			function(req, msg)
				-- get nodes 
				conn:reply(req, lunced_bmx6_nodes());
				print("Call to function 'nodes'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
				end
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
		neighbours = {
			function(req)
				conn:reply(req, lunced_bmx6_neighbours());
				print("Call to function 'neighbours'")
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
		self = {
			function(req)
				conn:reply(req, lunced_bmx6_local());
				print("Call to function 'self'")
			end, {id = ubus.INT32, msg = ubus.STRING }			
		},
		version = {
			function(req)

				conn:reply(req, lunced_local_version() );
				print("Call to function 'version'")
			end, {id = ubus.INT32, msg = ubus.STRING }			
		},
		reply = {
			function(req, msg)
				print("Call to function 'reply'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
				end			
			end, {id = ubus.INT32, msg = ubus.STRING }
		}

	}
}

conn:add(lunced_method)

local lucend_event = {
	lucend = function(msg)
		print("Call to lucent event")
		for k, v in pairs(msg) do
			print("key=" .. k .. " value=" .. tostring(v))
		end
	end,
}

conn:listen(lucend_event)

uloop.run()