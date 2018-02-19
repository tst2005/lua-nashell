local nashell = require "nashell"

local minimal = {}
minimal.os = {getenv=require"os".getenv}
minimal.io = {open=require"io".open}
minimal.lfs = require"lfs"
assert(minimal.lfs.chdir)
local S0,S = nashell(minimal)

do
	local startpwd = S.pwd()

	S.cd()
	print(S.pwd()==os.getenv("HOME"))

	S.cd("/tmp")
	print(S.pwd()=="/tmp")

	local r = S.ls('*')
	table.sort(r)
	for i,item in ipairs(r) do
		print(i,item)
	end
	S.cd(startpwd) -- restore the original
	assert(S.pwd()==startpwd)
end

do
	local package = require"package"
	local uniformapi = require "uniformapi"
	local G = uniformapi({_G=_G, package=package})
	assert(G.load)
	S.ipairs=ipairs
	S.print=print
	S.table=table

	local code=[[

	cd '/tmp'
	local r = ls '*'
	table.sort(r)
	for i,v in ipairs(r) do
		print(i,v)
	end

	]]
	G.load(code, code, "t", S)()
end
