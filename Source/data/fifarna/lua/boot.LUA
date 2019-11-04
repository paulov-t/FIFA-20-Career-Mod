-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
gSportsRNA = SportsRNA:new()
--gPassManager = Pass:new()
--gRenderables = Renderables:new()
--gFifaRNA = FifaRNA:new()

EA_PLATFORM_WINDOWS = false
EA_PLATFORM_PS3 = false
EA_PLATFORM_XENON = false
EA_PLATFORM_MAC = false
EA_PLATFORM_DURANGO = false

ALLOCTYPE_PERM = 0
ALLOCTYPE_TEMP_MANUAL_RELEASE = 1 -- Allocated in temp memory, renderable is still responsible for freeing
ALLOCTYPE_TEMP_AUTO_RELEASE = 2 -- Allocated in temp and auto freed when no longer in use by composite

ASSET_NO_COPY = 0
ASSET_MAKE_CPU_COPY = 1

USE_ENLIGHTEN = false

local InitializePlatform = function()
	-- Work out platform
	local platform = gSportsRNA:GetPlatform()
	if platform == "WINDOWS" then
		EA_PLATFORM_WINDOWS = true
	elseif platform == "XENON" then
		EA_PLATFORM_XENON = true
	elseif platform == "PS3" then
		EA_PLATFORM_PS3 = true
	elseif platform == "MAC" then
		EA_PLATFORM_MAC = true
	elseif platform == "DURANGO" then
		EA_PLATFORM_DURANGO = true
	elseif platform == "KETTLE" then
		EA_PLATFORM_KETTLE = true
	else
		gSportsRNA:Assert(0, "Unknown Platform")
	end
end
InitializePlatform()
InitializePlatform = nil

-----------------------------------------------------------------------------
collectgarbage('collect')

