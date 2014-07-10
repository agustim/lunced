-- BMX commands

function ipp2uuid(ipp)
--	ipp = string.gsub(ipp,"fd66:66:66:(%w+):(%w+):(%w+):(%w+):(%w+)","%1g%2g%3g%4")
--	ipp = string.gsub(ipp,"fe80::(%w+):(%w+):(%w+):(%w+)","%1g%2g%3g%4")
	ipp = string.gsub(ipp,":","_")
	return(ipp)
end 

function uuid2ipp(uuid)
	uuid = string.gsub(uuid,"_",":")
	return(uuid)
end 

-- function localIP2uuid(llip)
--	return(string.gsub(ipp,"",""))
-- end

function lunced_bmx6_nodes(sI)
	local nodes = JSON:decode(run('bmx6 -c --jshow originators'))
	local ret_nodes = {}
	ret_nodes['nodes'] = {}
	for i,v in ipairs(nodes.originators) do
		ret_nodes['nodes'][i] = ipp2uuid(v.primaryIp)
	end
	nodes = nil
	return( ret_nodes ) 
end

function lunced_bmx6_neighbours(sI)
	local links = JSON:decode(run('bmx6 -c --jshow links')) 
	local nodes = JSON:decode(run('bmx6 -c --jshow originators'))
	local list_nodes = {}
	local ret_nodes = {}
	local counter = 1
	list_nodes['nodes'] = {}
	ret_nodes['nodes'] = {}

	if links ~= nil then
		for i,v in ipairs(links.links) do
			for o,b in ipairs(nodes.originators) do
				if v.name == b.name then
					list_nodes['nodes'][b.name] = ipp2uuid(b.primaryIp)
				end
			end
		end
		counter = 1
		for i,v in pairs(list_nodes.nodes) do
			ret_nodes['nodes'][counter] = v
			counter = counter + 1
		end
	end
	list_nodes = nil
	links = nil
	nodes = nil
	return( ret_nodes ) 
end

function lunced_bmx6_local(sI)
	local ret = {}
	if sI.id == nil then
		lunced_bmx6_getSelfInfo(sI)
	end
	ret['id'] = sI['id']
	ret['name'] = sI['name']
	return (ret)
end

function lunced_bmx6_version(sI)
	local ret = {}
	if sI.bmx6 == nil then
		lunced_bmx6_getSelfInfo(sI)
	end
	ret['bmx6'] = sI['bmx6']
	return (ret)	
end

function lunced_bmx6_getSelfInfo(sI)
	local myinfo = JSON:decode(run("bmx6 -c --jshow status"))
	sI['id'] = ipp2uuid(myinfo.status.primaryIp)
	sI['name'] = myinfo.status.name
	sI['bmx6'] = myinfo.status.version
	myinfo = nil
end