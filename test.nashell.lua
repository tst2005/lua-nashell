local nashell = require "nashell"

local minimal = {}
minimal.os = {getenv=require"os".getenv}
minimal.io = {open=require"io".open}
minimal.lfs = require"lfs"
assert(minimal.lfs.chdir)
local S0,S = nashell(minimal)

S.cd()
print(S.pwd()==os.getenv("HOME"))

S.cd("/tmp")
print(S.pwd()=="/tmp")

for i,item in ipairs(S.ls("*")or{}) do
	print(i,item)
end
