-- BMX commands

function ipp2uuid(ipp)
	ipp = string.gsub(ipp,"fd66:66:66:%w+:(%w+):(%w+):(%w+):(%w+)","%1%2%3%4")
	ipp = string.gsub(ipp,"fe80::(%w+):(%w+):(%w+):(%w+)","%1%2%3%4")
	return(ipp)
end 

-- function localIP2uuid(llip)
--	return(string.gsub(ipp,"",""))
-- end

function lunced_bmx6_nodes()
	local nodes = JSON:decode(run('bmx6 -c --jshow originators'))
	local ret_nodes = {}
	ret_nodes['nodes'] = {}
	for i,v in ipairs(nodes.originators) do
		ret_nodes['nodes'][i] = ipp2uuid(v.primaryIp)
	end
	nodes = nil
	return( ret_nodes ) 
end

function lunced_bmx6_neighbours()
	local nodes = JSON:decode(run('bmx6 -c --jshow links')) 
	local ret_nodes = {}
	ret_nodes['nodes'] = {}
	for i,v in ipairs(nodes.links) do
		ret_nodes['nodes'][i] = ipp2uuid(v.llocalIp)
	end
	nodes = nil
	return( ret_nodes ) 
end

function lunced_bmx6_local()
	local myinfo = JSON:decode(run("bmx6 -c --jshow status"))
	local ret = {}
	ret['id'] = ipp2uuid(myinfo.status.primaryIp)
	ret['name'] = myinfo.status.name
	myinfo = nil
	return (ret)
end

function lunced_bmx6_version()
	local myinfo = JSON:decode(run("bmx6 -c --jshow status"))
	local ret = {}
	ret['bmx6'] = myinfo.status.version
	myinfo = nil
	return (ret)	
end