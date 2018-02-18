local class = require "mini.class"

local inst2env
do
	local G = _G
	local ro2rw = require "mini.proxy.ro2rw.with-internalregistry"(G)
	local mkproxies = require "mini.proxy.ro2rw.mkproxies"(G)
	local mkmap = require "mini.proxy.ro2rw.mkmap"(G)

	local mkproxy = mkproxies.mkproxy_inst2env
	local map = mkmap({
		["function"]=mkproxy,
		--["table"]=true,
	})
	assert(map["function"]==mkproxy)

	inst2env = function(orig, prefix)
		return ro2rw(orig, map, nil, prefix)
	end
end

local nashell = class("nashell")

function nashell:init(mods)
	local modnames = {"io", "os", "lfs"}
	for i,name in pairs(modnames) do
		local mod = mods[name]
		assert(mod, "missing mod: "..name)
		self["_"..name]=mod
	end
	do local lfs=self._lfs
		assert(lfs.currentdir)
		assert(lfs.dir)
		assert(lfs.chdir)
	end
	do local io=self._io
		assert(io.open)
	end
	do local os=self._os
		assert(os.getenv)
	end
	return inst2env(self, "_pub_")
end

-- pwd()
function nashell:pwd()
	local lfs = assert(self._lfs)
	return lfs.currentdir()
end

-- cd()
-- cd("path")
function nashell:cd(target)
	if not target then
		self:cdhome()
	else
		local lfs = assert(self._lfs)
		lfs.chdir(target)
	end
end

function nashell:cdhome()
	local home = assert(os.getenv("HOME"), "unable to get HOME")
	lfs.chdir(home)
end

function nashell:isabspath(path)
	assert(type(path)=="string")
	if path:sub(1,1)=="/" then -- is an absolute path
		return true
	end
	return false
end

function nashell:_pub_cd(target)
	self:cd(target)
	return self:pwd()
end

function nashell:ls(mask)
	local lfs = assert(self._lfs)
	local dir = self:pwd()
	local r = {}
	for d in lfs.dir(dir) do
		-- glob(mask)
		table.insert(r, d)
	end
	return r
end

function nashell:basename(path,ext) end
function nashell:dirname(path) end

function nashell:_pub_ls(mask)
	return self:ls(mask)
end
function nashell:_pub_pwd()
	return self:pwd()
end
function nashell:_pub_isabspath(path)
	return self:isabspath(path)
end


function nashell:_pub_mkdir(targets) end
function nashell:_pub_rmdir(targets) end
function nashell:_pub_rm(targets) end
function nashell:_pub_touch(targets) end
function nashell:_pub_cat(targets) end

function nashell:_pub_filetype(targets) end
function nashell:_pub_exists(targets) end
function nashell:_pub_fileexists(targets) end
function nashell:_pub_direxists(targets) end

function nashell:_pub_echo(anyargs) end
function nashell:_pub_printf(fmt, anyargs) end

return nashell
