PLAYER_FLUSHNESS_COLOR_LIST = { 0x00, 0xFFDE64AE, 0xFFDE64AE, 0xE5DE64AE, 0xD8DE64AE, 0xCCDE64AE, 0x99DE64AE, 0x8CDE64AE, 0x7FDE64AE, 0x66DE64AE, 0x4CDE64AE }

-- generic hair colors
PLAYER_COLOR_PRI_LIST = { 0x00B5A787, 0x00000000, 0x00AB875E, 0x00534238, 0x00A89176, 0x007B614A, 0x00483928, 0x00744F34, 0x007A7A7A, 0x00777777, 0x006A7434, 0x00346A74, 0x00744F34, 0x00603124, 0x00e75366 }
PLAYER_COLOR_SEC_LIST = { 0x00A89269, 0x00231E1E, 0x00A28963, 0x0045332B, 0x00C5B48F, 0x007E6751, 0x00544236, 0x006C371C, 0x009C9996, 0x00787B7D, 0x004B6C28, 0x0028466C, 0x006C4633, 0x00583325, 0x00720c38 }
PLAYER_COLOR_TER_LIST = { 0x00473326, 0x00100E0D, 0x00362815, 0x0017110E, 0x0056463A, 0x002F211A, 0x001F140E, 0x00250E02, 0x00362F2D, 0x00232421, 0x0022250F, 0x0016162C, 0x0021150F, 0x00171413, 0x00330f2d }

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function PlayerUpdate()
	
	-- JSON = require("JSON")
	-- v2k4Patch = require("v2k4Patch")
	
	local player = db.player
	
	
	--require("testotherluafile");
	-- loadAPlayer(); 
	-- causes a command window to appear
	--os.execute("mkdir paulv2k4")
	
	local file = io.open("currently_editing.txt", "w")
	for k, v in pairs(player) do
		file:write(k)
		file:write('=')
		file:write(v)
		file:write("\n")
	end
	file:close()
	
	local file = io.open("db.txt", "w")
	for k, v in pairs(db) do
		file:write(k)
		file:write('=')
		file:write(v)
		file:write("\n")
	end
	file:close()
	
	
	-- female added in fifa 2016
	--db.player.Gender = 0 --as:GetInt(player, "gender")  -- 0=male, 1=female
	
	local kitNumber = player.KitNumber
	player.KitNumberTens = math.floor ( kitNumber / 10 )
	player.KitNumberUnits = math.floor ( math.fmod(kitNumber, 10) )

	-- Faceproxyheadclass should never be greater than one including createplayer
	if (player.FaceProxyHeadClass == 2) then
		player.FaceProxyHeadClass = 1
	end

	if (player.Cold ~= 1) then
		player.TeamColorPri = 0x00FF0000
		player.TeamColorSec = 0x0000FF00
		player.TeamColorTer = 0x000000FF
	end
	
	local headSkinToneType = player.HeadSkinToneType

	-- player flushness color per skintone
	local flushnessColor = PLAYER_FLUSHNESS_COLOR_LIST[headSkinToneType + 1]

	if (flushnessColor == nil) then
		flushnessColor = 0xCCDE64AE
	end

	player.FlushnessColor = flushnessColor

	local hairColorPri= 0x00FF0000
	local hairColorSec= 0x0000FF00
	local hairColorTer= 0x000000FF

	if (player.HeadClass == 0) then

		-- local playerassetid = player.PlayerAssetId
		local playerassetid = player.HeadAssetId

		player.Head = playerassetid

		player.Eyebrow = 0
		player.FaceType = playerassetid
		
		player.FaceSideBurn = 0
		player.FacialHairColor = 0
		player.FacialHairType = 0
		player.HeadSkinType = 0
		player.HeadSkinToneType = 0

		player.Hair = playerassetid
		player.HairColor = 0
		player.UseFaceTextureComposition = 0
		
	else

		local hairColor = player.HairColor
		hairColorPri = PLAYER_COLOR_PRI_LIST[hairColor + 1]
		hairColorSec = PLAYER_COLOR_SEC_LIST[hairColor + 1]
		hairColorTer = PLAYER_COLOR_TER_LIST[hairColor + 1]

		if (hairColorPri == nil or hairColorSec == nil or hairColorTer == nil) then
			hairColorPri= 0x00FF0000
			hairColorSec= 0x0000FF00
			hairColorTer= 0x000000FF
		end
	end
	
	player.HairColorPri = hairColorPri
	player.HairColorSec = hairColorSec
	player.HairColorTer = hairColorTer
	
	-- sets dirt color per play surface type
	local playSurfaceType = player.PlaySurfaceType
	if (playSurfaceType == 1) then
		-- Mud
		player.DirtType = 1
		player.DirtColorPri = 0x00362606
		player.DirtColorSec = 0x000F0B03
		player.DirtColorTer = 0x00070501
	else
		-- if (playSurfaceType == 0) then
		-- Grass 
		player.DirtType = 0
		player.DirtColorPri = 0x00759600
		player.DirtColorSec = 0x00290800
		player.DirtColorTer = 0x00040100		
	end

	-- Seasonal Assets 

	-- These exist only here and not in the code:
	local seasonal = player.SeasonalJersey

	if(player.IsVirtualPro == 1 or player.IsCreatedPlayer == 1) then
		if(seasonal < 2) then
			seasonal = player.JerseySleeveLength
		end
	elseif(player.Cold == 0) then
		seasonal = player.JerseySleeveLength
	end


	if (seasonal == 0) then
		-- Short Sleeves
		player.JerseySleeveLength  = 0
		player.UnderNeck = -1
		player.UnderArms = -1
		player.ArmLength = 0
	elseif (seasonal == 1) then
		-- Long Sleeves
		player.JerseySleeveLength  = 1
		player.UnderNeck = -1
		player.UnderArms = -1
		player.ArmLength = 1
	elseif (seasonal == 2) then
		-- Long Sleeves and just underarmor neck
		player.JerseySleeveLength = 1
		player.UnderNeck = 0
		player.UnderArms = -1
		player.ArmLength = 1
	elseif (seasonal == 3) then
		-- Short sleeves with underarmor arms no neck
		player.JerseySleeveLength  = 0
		player.UnderNeck = -1
		player.UnderArms = 0
		player.ArmLength = 1
	elseif (seasonal == 4) then
		-- Short sleeves with underarmor neck and arms
		player.JerseySleeveLength  = 0
		player.UnderNeck = 0
		player.UnderArms = 0
		player.ArmLength = 1
	end

	-- Only if not wearing outfit
	if (player.OutfitId <= 0) then

		--if (db.player.Cold > 0 or db.player.IsVirtualPro == 1 or db.player.IsCreatedPlayer == 1) then
		if (player.Cold > 0) then
			player.UnderShorts = 0
		else
			player.UnderShorts = -1
		end

		-- end of seasonal assets

		-- check if we need to force underwear for injuries
		if ( player.ForceUnderArm == 1 ) then
			player.JerseySleeveLength  = 0
			player.UnderArms = 0
			player.ArmLength = 1
		end

		if ( player.ForceUnderShorts == 1 ) then
			player.UnderShorts = 0
		end

		if ( player.ForceUnderNeck == 1 ) then
			player.UnderNeck = 0
		end

		-- Goalie long pants, turn off necessary assets.
		if( player.ShortStyle == 1 ) then
			player.SockLength = -1
			player.UnderShorts = -1
		end
		
		player.UseKitWarmUpBib = 1
		player.UseKitWarmUpJacket = 1
		player.UseKitWarmUpPants = 1			
	else
		player.UnderNeck = -1
		player.UnderArms = -1
		player.UnderShorts = -1
	end

	-- Seasonal assets

	-- if createplayer female disable facial hair stamping
	if (player.IsCreatedPlayer == 1 and player.Gender == 1) then
		player.FacialHairType = 0
	end
	
	
	
	
		
	
	
	if(file_exists(player.PlayerId .. '.txt')) then
		local lines = lines_from(player.PlayerId .. '.txt')
		
		local file_out_temp = io.open("temp.txt", "w")
		
		
		for k,v in pairs(lines) do
		
			local r = split(v, '=')
			
			local varName = ""
			local varValue = ""
			--for key, value in pairs(r) do
			
				--if (varName == "") then
					-- varName = value
				--end
				-- else
				--	varValue = value;
				--file_out_temp:write(value)
				--file_out_temp:write("\n")
				--	
					--player[varName] = varValue;
				--	varName = "";
				-- end
		
		
			--end
			
		
			player.FacialHairType = 1
		end
		
		file_out_temp:close()
	end	
	

	
	local file_out2 = io.open("currently_editing_postEA.txt", "w")
	for k, v in pairs(player) do
		file_out2:write(k)
		file_out2:write('=')
		file_out2:write(v)
		file_out2:write("\n")
	end
	file_out2:close()

end



