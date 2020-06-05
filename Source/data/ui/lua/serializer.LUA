--! @file serializer.lua
--!	This library implements transformations on tables to put them in a form suitable for serialization
--! as JSON or as some other intermediate format. In particular, it eliminates cycles and table keys
--!
--! This library also implements deserialization, which reconstructs tables that are topologically identical
--! to the original from the serialized form
--!
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc. 

local P = {}

function P.addValueRef(refs, v)
	if type(v) == "table" then
		local vrefs = refs[v]
		
		if vrefs then
			refs[v] = vrefs + 1
		else
			refs[v] = 0
			P.findRefs(refs, v)
		end
	end
end

--!	Count all the table references in a table
--!	@param	refs	The table to store the reference counts in
--!	@param	t		The table
--!	@note	References that only appear once have a count of 0, unless they appear as keys
function P.findRefs(refs, t)
	local m = getmetatable(t)
	if m then
		P.addValueRef(refs, m)
	end
	
	for k, v in pairs(t) do
		if type(k) == "table" then
			local krefs = refs[k]
			if krefs then
				refs[k] = krefs + 1
			else
				refs[k] = 1
				P.findRefs(refs, k)
			end
		end
		
		P.addValueRef(refs, v)
	end
end

--!	Create string keys for any multiply-referenced values and place the values in a sorted array
--!	@param	refs	A table containing reference counts
--!	@return	tables	A lookup table for references keyed by the values, a sorted array of the values
function P.enumerateRefs(refs)
	local enumeratedRefs = {}
	local sortedValues = {}
	
	local i = 1
	
	for k, v in pairs(refs) do
		if v > 0 then
			enumeratedRefs[k] = "~"..i.."~"
			sortedValues[i] = k
			i = i + 1
		end
	end
	
	return enumeratedRefs, sortedValues
end

--! Replace all table references with string keys
--!	@param	refs	An array of refs
--!	@param	value	The value we're unlinking
--!	@return value	A new value will all the table references in refs replaced by their string keys
function P.unlink(refs, value)
	local ref = refs[value]
	
	if ref then
		return ref
	elseif type(value) == "table" then
		return P.unlinkref(refs, value)
	else
		return value
	end
end

--!	Replace all table references in a given table with string keys
--!	@param	refs	An array of refs
--!	@param	value	The table we're unlinking
--!	@return	table A new table with all the table references in refs replaced by their string keys
function P.unlinkref(refs, value)
	local unlinked = {}
	
	local m = getmetatable(value)
	if m ~= nil then
		unlinked["~m~"] = P.unlink(refs, m)
	end

	for k, v in pairs(value) do
		unlinked[P.unlink(refs, k)] = P.unlink(refs, v)
	end
	
	return unlinked
end

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

--!	Serialize a table
--!	@param	t		The table
--!	@return	table	The serialized table
function P.serialize(t)

	local json = dumpJson(t)
	local file_serializer = io.open("serializer_test.json", "w")
	file_serializer:write(json)
	file_serializer:close()
	

	local refs = {}
	refs[t] = 0
	P.findRefs(refs, t)
	
	local sortedValues = nil
	refs, sortedValues = P.enumerateRefs(refs)
	
	local unlinked = {}
	
	for i, v in pairs(sortedValues) do
		unlinked[i] = P.unlinkref(refs, v)
	end
	
	local returnable = { P.unlink(refs, t), unpack(unlinked) }
	
	
	return returnable
end

--!	Link a value given a table of refs mapping string keys to their deserialized values
--!	@param	refs	The table of refs
--!	@param	value	The value
--!	@return	value	A new value with all the string keys replaced by their deserialized values
function P.link(refs, value)
	if type(value) == "string" then
		local s, e, i = value:find("~(%d+)~")
		if s == 1 and e == #value then
			return refs[tonumber(i)]
		end
	elseif type(value) == "table" then
		local linked = {}
		
		P.linkref(refs, linked, value)
		
		return linked
	end
	
	return value
end

--!	Link a table given a table of refs mapping string keys to their deserialized values
--!	@param	refs	The table of refs
--!	@param	t		The table to link
--!	@param	u		The serialized table
function P.linkref(refs, t, u)
	local m = u["~m~"]
	
	if m then
		setmetatable(t, P.link(refs, m))
		u["~m~"] = nil
	end

	for k, v in pairs(u) do
		t[P.link(refs, k)] = P.link(refs, v)
	end
end

--!	Deserialize a table
--!	@param	t		The serialized table
--!	@return	table	A deserialized table
function P.deserialize(t)
	local refs = {}
	
	for i = 2, #t do
		refs[i - 1] = {}
	end
	
	for i = 2, #t do
		P.linkref(refs, refs[i - 1], t[i])
	end
	
	return P.link(refs, t[1])
end

return P
