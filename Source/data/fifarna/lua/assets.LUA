-----------------------------------------------------------------------------
-- Asset module
-----------------------------------------------------------------------------
gLoadAsyncTable = {}

function LoadAsync(fname)
	local handle = gSportsRNA:LoadScriptAsync(fname)
    gLoadAsyncTable[fname] = handle
end

function LoadAsyncWait()
    for fname,handle in pairs(gLoadAsyncTable) do
		gSportsRNA:LoadScriptAsyncComplete(handle)
	end
	gLoadAsyncTable = {}
end

-----------------------------------------------------------------------------
-- Fire off all load requests simultaneously to get more efficient throughput

LoadAsync("data/fifarna/lua/assets/player.lua")
LoadAsync("data/fifarna/lua/assets/accessory.lua")
LoadAsync("data/fifarna/lua/assets/sle.lua")

-----------------------------------------------------------------------------
function InitializeDB()
	
	--v2k4debugfile = io.open("v2k4debugfile.txt", "w")
	--v2k4debugfile:write('gSportsRNA\n')
	--v2k4debugfile:write(gSportsRNA)
	
	db = {
		accessory = {},
		stadium = {},
		player = {},
		sle = {}
	}
end

-----------------------------------------------------------------------------
InitializeDB()
LoadAsyncWait() -- ensure all files are loaded
collectgarbage('collect')