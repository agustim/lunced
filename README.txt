LUNCED
------

Lunced is an OpenWrt daemon written in Lua for the NCD/OC2 project. It provides information to the NCDui about the node itself and other nodes in the network via ubus.



REQUIREMENTS
------------

Lunced needs the libubox-lua package:

opkg update
opkg install libubox-lua



INSTALL
-------

Copy all the files in a directory and run ./lunced.lua (or ./lunced.lua to leave it in the background).
