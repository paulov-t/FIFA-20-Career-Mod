v2k4Patch = {}
v2k4debugfile = io.open("v2k4debugfile.txt", "w")
--v2k4debugfile:write('initialisation\n')

PLAYER_FLUSHNESS_COLOR_LIST = { 0x00, 0xFFDE64AE, 0xFFDE64AE, 0xE5DE64AE, 0xD8DE64AE, 0xCCDE64AE, 0x99DE64AE, 0x8CDE64AE, 0x7FDE64AE, 0x66DE64AE, 0x4CDE64AE }

-- generic hair colors
PLAYER_COLOR_PRI_LIST = { 0x00B5A787, 0x00000000, 0x00AB875E, 0x00534238, 0x00A89176, 0x007B614A, 0x00483928, 0x00744F34, 0x007A7A7A, 0x00777777, 0x006A7434, 0x00346A74, 0x00744F34, 0x00603124, 0x00e75366 }
PLAYER_COLOR_SEC_LIST = { 0x00A89269, 0x00231E1E, 0x00A28963, 0x0045332B, 0x00C5B48F, 0x007E6751, 0x00544236, 0x006C371C, 0x009C9996, 0x00787B7D, 0x004B6C28, 0x0028466C, 0x006C4633, 0x00583325, 0x00720c38 }
PLAYER_COLOR_TER_LIST = { 0x00473326, 0x00100E0D, 0x00362815, 0x0017110E, 0x0056463A, 0x002F211A, 0x001F140E, 0x00250E02, 0x00362F2D, 0x00232421, 0x0022250F, 0x0016162C, 0x0021150F, 0x00171413, 0x00330f2d }

use_mpr_face_system = 0
use_mpr_boot_system = 0
use_mpr_tattoo_system = 0
	
use_ufm_face_system = 0

use_other_face_system = 0

-------------------------
----- PAULS HELPERS -----

function dumpJson(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. ''..k..' : ' .. dumpJson(v) .. ',\n'
      end
      return s .. '}\n '
   else
      return tostring(o)
   end
end

function dumpKeyValue(o) 
	local s = ''
	for k, v in pairs(o) do
		s = s .. k
		s = s .. '='
		s = s .. v
		s = s .. "\n"
		
	end
	return s
end

function dir_exists(directory)
  local ok, err, code = os.rename(directory, directory)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

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

function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function getVariableFromTable(t, vr) 
	if contains(t, vr) then 
		
		for _, v in pairs(t) do
		if v == vr then return t[vr] end
	end
	
	end
	return nil
end

function getVariableFromFile(file, variableToGet) 
	if(file_exists(file)) then
		
		local lines = lines_from(file)
		
		
		for k,v in pairs(lines) do
		
			local r = split(v, '=')
			
			local varName = ""
			local varValue = ""
			for key, value in pairs(r) do
			
				if (varName == "") then
					varName = value
				
				else
					varValue = value
					
					if varName == variableToGet then
						return varValue
					end
					
				end
			end
		end
	end
	
	return nil
end

function random_elem(tb)
    local keys = {}
    for k in pairs(tb) do table.insert(tb, k) end
    return tb[keys[math.random(#keys)]]
end

--v2k4debugfile:write('create hair and facial hair table arrays\n')
local hair_bald = {
	0, -- Bald
	26 -- thin sides
}

local hair_receeding = {
	29, -- receeding
	72, -- receeding thick
	112, -- receeding thick slight spike and mullet
	43
}

local hair_veryshort = {
	1, -- Crew
	16, -- Crew thick
	25, -- thin
	28 -- Crew thick
}

local hair_short_wavy = {
	17, -- Wavy slight spiked, thick sides
	18, -- Wavy spiked, thin sides
	57, -- Wavy Styled parting
	114, -- Wavy Styled parting
	115, -- Wavy Styled parting
	118 -- Wavy Styled parting
}

local hair_short_curly = {
	21, -- Curly slight spiked
	22, -- Curly Thick spiked
	65 -- short and slick
}

local hair_short_straight = {
	23, -- straight flat hair
	24, -- straight spiked fringe
	64, -- Spiked top (mowhawk)
	65, -- short and slick
	133 -- straight spiked fringe
}

local hair_medium_straight = {
	126, -- straight spiked parted hair
	128, -- straight spiked parted hair
	130 -- straight spiked parted hair
}

local hair_medium_wavy = {
	509, -- wavy spiked parted hair 
	116 -- Wavy Styled parting
	
}

local hair_afro = {
	2, -- Small Afro
	3 -- Big Afro
}

local hair_cornrows = {
	4, -- Short Cornrows
	5, -- Side Parted Long Cornrows
	6, -- Ponytail Cornrows
	7 -- Ponytail Cornrows 2
}

local hair_wavyShoulderLength = {
	11, -- Wavy Long Hair with Fringe
	12, -- Wavy Long Hair brushed back
	32, -- Wavy Long Hair 
	33 -- Wavy Long Hair 
	
}

local hair_wavyMediumLength = {
	13, -- Wavy - Thick - cut short at back parted
	14, -- Wavy - Thick - cut short at back, fringe slicked
	34 -- Wavy - Thin
}


local facialHairShort = {
	1, -- Chin Fuzz
	2, -- Jaw Strap
	4, -- Goatee Thin/Stubble
	7, -- Soul Patch
	9, -- Goatee Thick / Think mustache
	10, -- Moustache
	16 -- Think Chin Strap
}

local facialHairMedium = {
	3, -- Goatee
	5, -- Goatee, not joined up
	15, -- Goatee, not joined up
	17 -- Goatee
}

local facialHairLong = {
	8, -- Long Thick Beard
	14, -- Long Beard, No mustache
	11, -- Long Beard, No mustache
	13 -- Long Beard, No mustache
}



function doPlayerInjection(dir, player) 
	v2k4debugfile:write('checking ' .. dir .. 'exists\n')
	if(dir_exists(dir)) then
		v2k4debugfile:write('checking ' .. dir .. player.PlayerId .. '.txt exists\n')
		
		if(file_exists(dir .. player.PlayerId .. '.txt')) then
		
			v2k4debugfile:write('->>>>> ' .. dir .. player.PlayerId .. '.txt file exists\n')
			
			local lastEditedHour = nil

			if(string.find(dir, "overwrite") == false) then
			
				lastEditedHour = getVariableFromFile(dir .. player.PlayerId .. '.txt', "v2k4LastEditedHour")
				if(lastEditedHour ~= nil) then
					v2k4debugfile:write('->>>>> check file last edited hour ' .. lastEditedHour .. '\n')
				end
			end
			
			
			
			if(lastEditedHour == nil or (tonumber(lastEditedHour) ~= tonumber(os.date("%H")))) then
			
				local head = getVariableFromFile(dir .. player.PlayerId .. '.txt', "Head")
				if(head ~= 0) then
					player.Head = tonumber(head)
					v2k4debugfile:write('->>>>> ->>>>> Attempting to set field head to ' .. head .. '\n')
				end
			
			
				local lines = lines_from(dir .. player.PlayerId .. '.txt')
				
				for k,v in pairs(lines) do
				
					local r = split(v, '=')
					
					local varName = ""
					local varValue = ""
					for key, value in pairs(r) do
					
						if (varName == "") then
							varName = value
						
						else
							varValue = value
							
							if varName == "FacialHairType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.FacialHairType = tonumber(varValue)
							elseif varName == "Hair" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.Hair = tonumber(varValue)	
							elseif varName == "HairStyle" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.HairStyle = tonumber(varValue)	
							elseif varName == "ShoeType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.ShoeType = tonumber(varValue)	
							elseif varName == "TattooLeftArm" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.TattooLeftArm ~= 0) then
									player.HasTattooUpperBody = 1
									player.TattooLeftArm = tonumber(varValue)	
								end
							elseif varName == "TattooRightArm" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.TattooRightArm ~= 0) then
									player.HasTattooUpperBody = 1
									player.TattooRightArm = tonumber(varValue)	
								end
							elseif varName == "TattooRightLeg" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.TattooRightLeg ~= 0) then
									player.HasTattooLowerBody = 1
									player.TattooRightLeg = tonumber(varValue)	
								end
							elseif varName == "TattooLeftLeg" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.TattooLeftLeg ~= 0) then
									player.HasTattooLowerBody = 1
									player.TattooLeftLeg = tonumber(varValue)	
								end
							elseif varName == "TattooHead" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.TattooHead ~= 0) then
									player.HasTattooHead = 1
									player.TattooHead = tonumber(varValue)	
								end
							elseif varName == "HeadAssetId" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								--if(player.HeadAssetId ~= 0) then
									player.HeadAssetId = tonumber(varValue)
									--player.HeadVariation = 0
								--end
							elseif varName == "Head" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.Head ~= 0) then
									player.Head = tonumber(varValue)
								end
							elseif varName == "HeadClass" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								--if(player.HeadClass ~= 0) then
									player.HeadClass = tonumber(varValue)
								--end
							elseif varName == "HeadSkinType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								--if(player.HeadClass ~= 0) then
									player.HeadSkinType = tonumber(varValue)
								--end
							elseif varName == "FaceProxyHeadClass" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								--if(player.HeadClass ~= 0) then
									player.FaceProxyHeadClass = tonumber(varValue)
								--end
							elseif varName == "FaceType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								--if(player.HeadClass ~= 0) then
									player.FaceType = tonumber(varValue)
								--end
							elseif varName == "BodyType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								if(player.BodyType ~= 0) then
									player.BodyType = tonumber(varValue)
								end
							elseif varName == "FaceGenSkinToneType" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.FaceGenSkinToneType = tonumber(varValue)
							elseif varName == "IsCreatedPlayer" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.IsCreatedPlayer = tonumber(varValue)
							elseif varName == "UseFaceTextureComposition" then
								v2k4debugfile:write('->>>>> ->>>>> Attempting to set field ' .. varName .. ' to ' .. varValue .. '\n')
								player.UseFaceTextureComposition = tonumber(varValue)
							end
							
							
							
							varName = "";
						end
				
				
					end
					
				end
				
			end
			
			
			if (player.HeadClass == 0) then

				local playerassetid = player.HeadAssetId

				player.Head = playerassetid

				--player.Eyebrow = 0
				player.FaceType = playerassetid
				
				--player.FaceSideBurn = 0
				--player.FacialHairColor = 0
				--player.FacialHairType = 0
				--player.HeadSkinType = 0
				--player.HeadSkinToneType = 0

				--player.Hair = playerassetid
				--player.HairColor = 0
				--player.UseFaceTextureComposition = 0
			end
			
		end	
	end
end



function doPlayerRandomFacialHair(player, use, growthchance)

	if(use == 1 and player.Gender ~= 1) then
		v2k4debugfile:write('Using Facial Hair Growth System\n')
		
		local hairRandom = 100 - math.random(growthchance)
		local hairRandomOther = math.random(100)
		v2k4debugfile:write('Facial Hair Growth System : ' .. hairRandom .. ' < ' .. hairRandomOther .. '?\n')
		if(hairRandom < hairRandomOther) then
			v2k4debugfile:write('Facial Hair Growth System : Make a change \n')
			
			player.FacialHairType = math.random(30)
			player.FacialHairChangeTime = os.time()
			
		end

		
	end
		

end

function doPlayerRandomHair(player, use, growthchance)

	if(use == 1) then
		v2k4debugfile:write('Using Hair Growth System\n')
		
		local hairRandom = 100 - math.random(growthchance)
		local hairRandomOther = math.random(100)
		v2k4debugfile:write('Hair Growth System : ' .. hairRandom .. ' < ' .. hairRandomOther .. '?\n')
		if(hairRandom < hairRandomOther) then
			v2k4debugfile:write('Hair Growth System : Make a change \n')
					
			if(player.Hair == 0 or player.Hair == 26) then
				v2k4debugfile:write('Hair Growth System : is bald, staying bald \n')
				if(math.random(100) < math.random(100)) then
					player.Hair = 26
				end
			end
			
			if(contains(hair_afro, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_afro, staying hair_afro \n')
				player.Hair = hair_afro[math.random( #hair_afro )]
						
			elseif(contains(hair_cornrows, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_cornrows, staying hair_cornrows \n')
				player.Hair = hair_cornrows[math.random( #hair_cornrows )]
			end
			
			if(contains(hair_medium_straight, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_medium_straight, staying hair_medium_straight \n')
				player.Hair = hair_medium_straight[math.random( #hair_medium_straight )]
			end
			
			if(contains(hair_medium_wavy, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_medium_wavy, staying hair_medium_wavy \n')
				player.Hair = hair_medium_wavy[math.random( #hair_medium_wavy )]
			end
			
			if(contains(hair_receeding, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_receeding, staying hair_receeding \n')
				player.Hair = hair_receeding[math.random( #hair_receeding )]
			end
			
			if(contains(hair_short_curly, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_short_curly, staying hair_short_curly \n')
				player.Hair = hair_short_curly[math.random( #hair_short_curly )]
			end
			
			if(contains(hair_short_straight, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_short_straight, staying hair_short_straight \n')
				player.Hair = hair_short_straight[math.random( #hair_short_straight )]
			end
			
			if(contains(hair_short_wavy, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_short_wavy, staying hair_short_wavy \n')
				player.Hair = hair_short_wavy[math.random( #hair_short_wavy )]
			end
			
			if(contains(hair_veryshort, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_veryshort, staying hair_veryshort \n')
				player.Hair = hair_veryshort[math.random( #hair_veryshort )]
			end
			
			if(contains(hair_wavyMediumLength, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_wavyMediumLength, staying hair_wavyMediumLength \n')
				player.Hair = hair_wavyMediumLength[math.random( #hair_wavyMediumLength )]
			end
			
			if(contains(hair_wavyShoulderLength, tonumber(player.Hair))) then
				v2k4debugfile:write('Hair Growth System : is hair_wavyShoulderLength, staying hair_wavyShoulderLength \n')
				player.Hair = hair_wavyShoulderLength[math.random( #hair_wavyShoulderLength )]
			end
			
			
			
			
			
			
		end

		
	end
		

end

function doPlayerRandomShoe(player, use, growthchance) 
	if(use == 1) then
		v2k4debugfile:write('Using Dynamic Boot System\n')
		
	end
end

function doPlayerRandomTattoo(player, use, growthchance)
	if(use == 1) then
		v2k4debugfile:write('Using Dynamic Tattoo System\n')
		
		if(player.HasTattooUpperBody == 0) then
			local tattooRandom = 100 - math.random(growthchance)
			local tattooRandomOther = math.random(100)
			v2k4debugfile:write('Random Tattoo System : ' .. tattooRandom .. ' < ' .. tattooRandomOther .. '?\n')
			if(tattooRandom < tattooRandomOther) then
				v2k4debugfile:write('Tattoo System : Make a change \n')
				
				player.HasTattooUpperBody = 1
				player.TattooLeftArm = 100 - math.random(99)
			
			end
		end
	end
end




function doPlayerFaceMod(player, fileLoc, debugFileLoc) 

	local debuggingfile = io.open(debugFileLoc, "w")

	if(file_exists(fileLoc)) then
		debuggingfile:write('Using ' .. fileLoc .. '\n')
		
		for k,v in pairs(lines_from(fileLoc)) do
			local r = split(v, '=')
			local varName = ""
			local varValue = ""
			for key, value in pairs(r) do
				
				
				if (varName == "") then
					varName = value
				
				else
					varValue = value
					
						
					if(tonumber(player.PlayerId) == tonumber(varName)) then 
						
						player.HeadClass = 0
						player.Head = tonumber(varValue)
						player.HeadAssetId = tonumber(varValue)
						player.PlayerAssetId = tonumber(varValue)
						player.Hair = tonumber(varValue)						
						player.FaceType = tonumber(varValue)
												
						debuggingfile:write('Face ' .. varName .. ' has been set to ' .. varValue .. '\n')
						
					end
					
					-- Set Old Player Id
					if(tonumber(player.PlayerId) == tonumber(varValue)) then 
						
						player.HeadClass = 1
						player.Head = 0
						player.HeadAssetId = 0
						player.PlayerAssetId = 0
						player.Hair = 65		

						local hairColor = player.HairColor
						hairColorPri = PLAYER_COLOR_PRI_LIST[1]
						hairColorSec = PLAYER_COLOR_SEC_LIST[1]
						hairColorTer = PLAYER_COLOR_TER_LIST[1]

						player.HairColor = 1
						player.HairColorPri = hairColorPri
						player.HairColorSec = hairColorSec
						player.HairColorTer = hairColorTer
		
						player.FaceType = 1
												
						debuggingfile:write('Face ' .. varValue .. ' has been set to basic model\n')
						
					end
					
				end
				
			end
		end
		
	end
	
	debuggingfile:close()

end

function doPlayerUFMFace(player) 

	doPlayerFaceMod(player,'UFMFaces.txt', 'v2k4debugfile_UFM.txt')

end


function doPlayerMPRFace(player) 

	doPlayerFaceMod(player,'MPRFaces.txt', 'v2k4debugfile_MPR.txt')

end

function doOtherFaceSystem(player)

	doPlayerFaceMod(player,'OtherFaces.txt', 'v2k4debugfile_Other.txt')

end

function doMPRSystem(player) 


	if(use_mpr_face_system >= 1) then
		doPlayerMPRFace(player)
	
	end
	
	
end

function doUFMSystem(player) 
	
	doPlayerUFMFace(player)

end



function doEAFaceSystem(player) 

	local v2k4debugfileEA = io.open("v2k4debugfile_EA.txt", "w")
	if(file_exists('EAFaces.txt')) then
		v2k4debugfileEA:write('Using EA Faces\n')
		
		for k,v in pairs(lines_from("EAFaces.txt")) do
			
			local id = v
			v2k4debugfileEA:write('EA Face ' .. id .. '?\n')
			
			if(tonumber(player.PlayerId) == tonumber(id)) then 
				
				player.HeadClass = 0
				player.Head = tonumber(id)
				player.HeadAssetId = tonumber(id)
				player.PlayerAssetId = tonumber(id)
				player.Hair = tonumber(id)						
				player.FaceType = tonumber(id)
										
				v2k4debugfileEA:write('EA Face ' .. id .. ' has been set to ' .. id .. '\n')
				
			end
					
				
		end
		
	end
	v2k4debugfileEA:close()
end





function PlayerUpdate()
		
	local player = db.player
	
	local file_dump_db = io.open("dump_db.json", "w")
	file_dump_db:write(dumpJson(db))
	file_dump_db:close()

	local file_currently_editing = io.open("currently_editing.json", "w")
	file_currently_editing:write(dumpJson(player))
	file_currently_editing:close()
		
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

	
	
	local file_out2 = io.open("currently_editing_postEA.txt", "w")
	file_out2:write(dumpKeyValue(player))
	file_out2:close()
	
	local use_system = 0
	local use_hairgrowth_system = 0
	local use_facialhairgrowth_system = 0
	local use_bodyweight_system = 0
	local use_shoe_system = 0
	
	local hairgrowth_system_randomgrowth_chance = 100
	local facialhairgrowth_system_randomgrowth_chance = 100
	local shoe_system_randomchange_chance = 100
	
	
	
	v2k4debugfile = io.open("v2k4debugfile.txt", "w")
	
	
	--if(player.IsVirtualPro == 0 and player.IsCreatedPlayer == 0) then
	
		v2k4debugfile:write('loading settings\n')
		if(file_exists('v2k4settings.txt')) then
		

		-- do settings stuff
			for k,v in pairs(lines_from("v2k4settings.txt")) do
				local r = split(v, '=')
				local varName = ""
				local varValue = ""
				for key, value in pairs(r) do
					
					if (varName == "") then
						varName = value
					
					else
						varValue = value
						
						if varName == "use_system" then 
							use_system = tonumber(varValue)
						elseif varName == "use_hairgrowth_system" then
							use_hairgrowth_system = tonumber(varValue)
						elseif varName == "use_facialhairgrowth_system" then
							use_facialhairgrowth_system = tonumber(varValue)
						elseif varName == "use_bodyweight_system" then
							use_bodyweight_system = tonumber(varValue)
						elseif varName == "hairgrowth_system_randomgrowth_chance" then
							hairgrowth_system_randomgrowth_chance = tonumber(varValue)
						elseif varName == "facialhairgrowth_system_randomgrowth_chance" then
							facialhairgrowth_system_randomgrowth_chance = tonumber(varValue)
						elseif varName == "bodyweight_system_randomgrowth_chance" then
							bodyweight_system_randomgrowth_chance = tonumber(varValue)
						elseif varName == "use_shoe_system" then
							use_shoe_system = tonumber(varValue)
						elseif varName == "shoe_system_randomchange_chance" then
							shoe_system_randomchange_chance = tonumber(varValue)
						elseif varName == "use_tattoo_system" then	
							use_tattoo_system = tonumber(varValue)
						elseif varName == "use_mpr_face_system" then
							use_mpr_face_system = tonumber(varValue)
						elseif varName == "use_mpr_boot_system" then
							use_mpr_boot_system = tonumber(varValue)
						elseif varName == "use_ufm_face_system" then
							use_ufm_face_system = tonumber(varValue)
						elseif varName == "use_other_face_system" then
							use_other_face_system = tonumber(varValue)
							
							
						
						end
					end
				end
			end
		
		
		
		end
			-- end of do settings stuff
			
		if use_system >= 1 then 
			
			-- Use Dynamic System
			if(player.IsAvatar ~= 1 and use_system == 1) then 
			
				local v2k4LastEditedHour = getVariableFromFile("paulv2k4/saved/" .. player.PlayerId .. '.txt', "v2k4LastEditedHour")
			
				local bOkToUseFile = true
				
				local viewStateFilePath = "paulv2k4/saved/__viewState.txt"
				local currentEditedPlayerId = getVariableFromFile(viewStateFilePath, "PlayerId")
				v2k4debugfile:write('PlayerId View State: ' .. currentEditedPlayerId .. ' vs ' .. player.PlayerId .. '\n')
				if(currentEditedPlayerId ~= nil and tonumber(currentEditedPlayerId) == tonumber(player.PlayerId)) then
					bOkToUseFile = false
				end
				
				if(v2k4LastEditedHour ~= nil) then
					v2k4debugfile:write('->>>>> check file last edited hour ' .. tostring(v2k4LastEditedHour) .. ' vs ' .. tostring(os.date("%H")) .. '\n')
				end
				
				if(v2k4LastEditedHour ~= nil and (tonumber(v2k4LastEditedHour) == tonumber(os.date("%H")))) then
					
					bOkToUseFile = false
				end
				
				local viewStateFile = io.open(viewStateFilePath, "w")
				viewStateFile:write('PlayerId=' .. player.PlayerId .. '\n')
				viewStateFile:write("v2k4LastLoaded=" .. os.date() .. "\n")
				viewStateFile:close()
				
				--v2k4debugfile:write('Ok to use Save file??: ' .. bOkToUseFile .. '\n')
				if(bOkToUseFile == true) then
				
				
					-- Player Dynamic Changing System - Load in
					doPlayerInjection('paulv2k4/saved/', player) 
				
					-- make change
					doPlayerRandomFacialHair(player, use_facialhairgrowth_system, facialhairgrowth_system_randomgrowth_chance)
					
					-- make change
					doPlayerRandomHair(player, use_hairgrowth_system, hairgrowth_system_randomgrowth_chance)
					
					-- make change
					--doPlayerRandomShoe(player, use_shoe_system, shoe_system_randomchange_chance)
					
					-- make change to tattoo
					--doPlayerRandomTattoo(player, use_tattoo_system, 100)
				
				end
				
				-- save change
				if(dir_exists('paulv2k4/saved')) then
					local fileSaveChanges = io.open('paulv2k4/saved/' .. player.PlayerId .. '.txt', "w")
					for k, v in pairs(player) do
						fileSaveChanges:write(k)
						fileSaveChanges:write('=')
						fileSaveChanges:write(v)
						fileSaveChanges:write("\n")
					end
					fileSaveChanges:write("v2k4LastLoaded=" .. os.date() .. "\n")
					if(bOkToUseFile == false or v2k4LastEditedHour ~= nil) then 
						fileSaveChanges:write("v2k4LastEditedHour=" .. os.date("%H") .. "\n")
					else 
						fileSaveChanges:write("v2k4LastDynamicSystemHour=" .. os.date("%H") .. "\n")
					end
					fileSaveChanges:close()
					
					
				
				end
			
			end
			
			-- EA Starheads first, then let the rest do their thing
			v2k4debugfile:write("-- EA -- \n")
			doEAFaceSystem(player)
			
			-- MPR System
			v2k4debugfile:write("-- MPR -- \n")
			doMPRSystem(player)
			
			v2k4debugfile:write("-- UFM -- \n")
			if(use_ufm_face_system >= 1) then
				-- UFM System
				doUFMSystem(player)
			end
			
			v2k4debugfile:write("-- Other -- \n")
			-- Other Faces System
			if(use_other_face_system >= 1) then
			
				doOtherFaceSystem(player)
			end
			
			-- Overwrite System
			v2k4debugfile:write("-- Overwrite -- \n")
			doPlayerInjection('paulv2k4/overwrite/', player) 
		
		end
		
	--end
	
	-- if createplayer female disable facial hair stamping
	--if (player.IsCreatedPlayer == 1 and player.Gender == 1) then
	if(player.Gender == 1) then
		player.FacialHairType = 0
	end
	
	

	---------------------------
	-- User Request Settings --
	v2k4debugfile:write("-- User Request Settings -- \n")
	if(file_exists('v2k4settings.txt')) then
		
		-- Force JerseyFit (request from @hugodm7)
		local ForceTightFitJersey = getVariableFromFile('v2k4settings.txt', "ForceTightFitJersey")
		v2k4debugfile:write("-- ForceTightFitJersey: " .. tostring(ForceTightFitJersey) .. "\n")
		if(ForceTightFitJersey ~= nil and tonumber(ForceTightFitJersey) == 1) then
			player.JerseyFit = 1
		end
	end
	
	
	
	
	
	v2k4debugfile:close()
	
	
end



-- Converts Lua table to HTML output in table.html file
function tohtml(x)
  ret = tohtml_table(x,1)
  writefile("table.html", ret)
  os.execute("table.html")
  return(ret)
end

-- Saves a string to file
function writefile(filename, value)
  if (value) then
    local file = io.open(filename,"w+")
    file:write(value)
    file:close()
  end
end

-- Flattens a table to html output
function tohtml_table(x, table_level)
  local k, s,  tcolor
  local html_colors = {
    "#339900","#33CC00","#669900","#666600","#FF3300",
    "#FFCC00","#FFFF00","#CCFFCC","#CCCCFF","#CC66FF",
    "#339900","#33CC00","#669900","#666600","#FF3300",
    "#FFCC00","#FFFF00","#CCFFCC","#CCCCFF","#CC66FF"
  }
  local lineout = {}
  local tablefound = false
    if type(x) == "table" then
    s = ""
    k = 1
    local i, v = next(x)
    while i do
      if (type(v) == "table") then
        if (table_level<10) then
          lineout[k] =  "<b>" .. flat(i) .. "</b>".. tohtml_table(v, table_level + 1)   
        else
          lineout[k] = "<b>MAXIMUM LEVEL BREACHED</b>"
        end
        tablefound = true
      else
        lineout[k] = flat(i) .. "=" .. tohtml_table(v)
      end
      k = k + 1
      i, v = next(x, i)
    end

    for k,line in ipairs(lineout) do
      if (tablefound) then
        s = s .. "<tr><td>" .. line .. "</td></tr>\n"
      else
        s = s .. "<td>" .. line .. "</td>\n"
      end
    end
    if not (tablefound) then
      s = "<table border='1' bgcolor='#FFFFCC' cellpadding='5' cellspacing='0'>" ..
        "<tr>" .. s .. "</tr></table>\n"
    else
      tcolor = html_colors[table_level]
      s = "<table border='3' bgcolor='"..tcolor.."' cellpadding='10' cellspacing='0'>" ..
          s ..  "</table>\n"
    end

    return s 
  end
  if type(x) == "function" then
    return "FUNC"
  end
  if type(x) == "file" then
    return "FILE"
  end

  return tostring(x) 
end

-- Flattens a table to string
function flat(x)  
  return toflat(x,1)
end

-- Flattens a table to string
function toflat(x, tlevel)
  local s
  tlevel = tlevel + 1

  if type(x) == "table" then
    s = "{"
    local i, v = next(x)
    while i do
      if (tlevel < 15) then
        s = s .. i .. "=" .. toflat(v, tlevel) 
      else
        s = s .. i .. "={#}" 
      end

      i, v = next(x, i)
      if i then
        s = s .. ", " 
      end
    end
    return s .. "}\n"
  end
  if type(x) == "function" then
    return "FUNC"
  end
  if type(x) == "file" then
    return "FILE"
  end

  return tostring(x) 
end