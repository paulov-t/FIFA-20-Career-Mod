--! @file tableutil.lua
--!	This library implements some useful functions for dealing with tables
--!	@author Chris Burns (cburns@ea.com)
--!
--!	UX
--!	(c) 2011 Electronic Arts Inc.



local P = {}

--!	convert a table to a string
--!	@param	t		The table
--!	@param	indent	The indentation to use, or nil
function P.tostring(t, indent, refs)
	indent = indent or ""
	
	

	if type(t) == "table" then
	
	local v2k4debugfile = io.open("v2k4debugfile2.txt", "w")
	
		refs = refs or {}
		if refs[t] == nil then
			local tableid = tostring(t)
			refs[t] = tableid
			local s = indent.."{\t("..tableid..")\n"
			local newindent = indent.."\t"

			for k, v in pairs(t) do
				if type(v) == "table" then
					local tablestring = ""
					tablestring = P.tostring(v, newindent, refs)
					s = s..newindent..string.format("%s =", tostring(k)).." \n"..tablestring.." \n"
				else
					s = s..newindent..string.format("%s = %s", tostring(k), tostring(v)).." \n"
				end
			end

			return s..indent.."}"
		else
			-- Already printed the table, just print the recorded id tag
			return indent..string.format("(printed above as %s)", refs[t])
		end
	else
		-- Not a table, just print the value
		return indent..tostring(t)
	end
end

--!	print a table using the print function
--!	@param	t		The table
function P.print(t)
	local s = P.tostring(t)
	print(s)
end

--! turn an array into a set
--!	@param a		The array
--!	@param value	The value to use for the set's entries
--!	@return	table	A table that is a set of all the elements in the array
function P.arrayToSet(a, value)
	value = value or true
	local s = {}

	for i, v in ipairs(a) do
		s[v] = value
	end

	return s
end

--!	Return the complement of a in b
--!	@param	a		A set
--!	@param	b		Another set
--!	@return	table	The complement of a in b
function P.complement(a, b)
	local c = {}

	for k, v in pairs(b) do
		if not a[k] then
			c[k] = v
		end
	end

	return c
end

--!	perform a shallow copy of a table
--!	@param	a		The table
--!	@return	table	A shallow copy of the table
--!	@note a must be a table!
function P.shallowcopy(a)
	local t = {}

	for k, v in pairs(a) do
		t[k] = v
	end

	return t
end

function P.shallowcopyarray(a)
	return { unpack(a) }
	--[[
	local t = {}

	for i=1,#a do
		t[i] = a[i]
	end

	return t
	--]]
end

--!	clone a value
--!	@param	a		The value
--!	@return	table	A cycle-preserving deep copy of the value
--!	@note functions/closures are not duplicated so if your data structure contains
--!	them calling a closure in the copy may have side effects for the original
function P.clone(a, refs)
	if type(a) == "table" then
		local aref = refs and refs[a]

		if aref ~= nil then
			-- if we've already cloned a, then just return the clone
			return aref
		else
			-- we don't need refs until we're going to mutate it
			refs = refs or {}

			local t = {}

			-- store t in refs as the clone of a
			refs[a] = t

			setmetatable(t, P.clone(getmetatable(a), refs))

			for k, v in pairs(a) do
				t[P.clone(k, refs)] = P.clone(v, refs)
			end

			return t
		end
	else
		-- non-tables do not need special copying
		return a
	end
end

function P.shallowequal(a, b)
	if a ~= b then
		for k, v in pairs(a) do
			if b[k] ~= v then
				return false
			end
		end

		for k, v in pairs(b) do
			if a[k] ~= v then
				return false
			end
		end

		return true
	else
		return true
	end
end

--!	determine whether two values are structurally the same and contain the same primitive values
--!	@param	a	A value
--!	@param	b	Another value
--!	@return	boolean	true if the two values are equal, false otherwise
function P.equal(a, b, refs)

	if a ~= b then
		local at = type(a)

		if at == "table" and at == type(b) then
			-- we don't need to create refs unless we're going to use it
			refs = refs or {}

			local aref = refs[a]

			if aref ~= nil then
				-- if we're already testing the equality of a
				-- make sure that we think it should be b
				if aref == b then
					-- if we're already testing if a equals b
					-- return true because this doesn't indicate
					-- an inconsistency
					return true
				else
					-- a cannot equal b and equal something else
					-- at the same time
					-- return false as this indicates
					-- an inconsistency
					return false
				end
			end

			-- record that we assume (for now) that a equals b
			refs[a] = b

			if not P.equal(getmetatable(a), getmetatable(b), refs) then
				refs[a] = nil
				return false
			end

			local numak = 0
			local numbk = 0
			local atk = nil
			local numatk = 0

			for k, v in pairs(a) do
				numak = numak + 1

				if type(k) ~= "table" then
					-- primitive key, we can index b with it
					if not P.equal(v, b[k], refs) then
						refs[a] = nil
						return false
					end
				else
					-- we found a table key
					atk = atk or {}
					atk[k] = v
					numatk = numatk + 1
				end
			end

			local btk = nil
			local numbtk = 0
			for k, v in pairs(b) do
				numbk = numbk + 1

				if type(k) == "table" then
					btk = btk or {}
					btk[k] = v
					numbtk = numbtk + 1
				end
			end

			if numak ~= numbk then
				refs[a] = nil
				return false
			end

			if numatk ~= numbtk then
				refs[a] = nil
				return false
			end

			-- if atk is non-nil and numatk == numbtk then btk is non-nil
			if atk ~= nil then
				for k, v in pairs(atk) do
					found = false

					for bk, bv in pairs(btk) do
						local tmprefs = P.shallowcopy(refs)

						if P.equal(k, bk, tmprefs) and P.equal(v, bv, tmprefs) then
							btk[bk] = nil

							for rk in pairs(refs) do
								refs[rk] = nil
							end
							for rk, rv in pairs(tmprefs) do
								refs[rk] = rv
							end

							found = true
							break
						end
					end

					if not found then
						refs[a] = nil
						return false
					end
				end
			end

			-- structurally identical tables
			return true
		else
			-- not pointer equal and not tables
			return false
		end
	else
		-- pointer equality
		return true
	end
end

local cd = function(a, b) return a < b end
function P.binsert(t, v, c)
	c = c or cd

	local is, ie, im, ist = 1, #t, 1, 0

	local floor = math.floor

	while is <= ie do
		im = floor((is + ie)/2)

		if c(v, t[im]) then
			ie, ist = im - 1, 0
		else
			is, ist = im + 1, 1
		end
	end

	local r = im + ist

	table.insert(t, r, v)

	return r
end

return P
