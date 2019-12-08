--! @file cps.lua
--!	A lightweight library with loop-like constructs for continuation passing style
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc. 

-- create a table to represent this package
local P = {}

--[[
--! @note	The following three functions that implement serial continuation apply are specifically optimized
--!			to produce a minimum number of closures for performance reasons. Closures are only created if
--!			the table that the function is being applied over contains at least two entries, and then only
--!			N - 1 closures will be created, where N is the number of entries. The previous implementation
--!			would create N + 1 closures, where N was the number of entries (!)

--!	retrieve the continuation for continuing a serial CPS (continuation passing style) apply of a function over a table's entries
--! @param	data	A user defined value that will be passed to the f function
--! @param	c		The continuation to call once this operation is complete
--! @param	f		The function to call for each item
--!	@param	iter	The iterator function (ie, next)
--!	@param	t		The table
--!	@param	k		The next key
--!	@param	v		The next value
function P.getSerialCForApply(...)
	-- return a continuation, which, when called will...
	
	-- implemented using lua's variable argument list functionality so that we only need a single upvalue
	local closureArg = arg
	local serialContinuation = 
		function()
			return P.serialApplyHelper(unpack(closureArg))
		end
		
	return serialContinuation;
end

--!	helper to apply the function to a table and determine the continuation for the next entry - if there is one
--! @param	data	A user defined value that will be passed to the f function
--! @param	c		The continuation to call once this operation is complete
--! @param	f		The function to call for each item
--!	@param	iter	The iterator function (ie, next)
--!	@param	t		The table
--!	@param	k		The current key
--!	@param	v		The current value
function P.serialApplyHelper(data, c, f, iter, t, k, v)
	
	local key, value = iter(t, k)
	
	local continuation =
		key ~= nil
		and
			P.getSerialCForApply(data, c, f, iter, t, key, value)
		or
			-- if there are no further entries, the continuation will simply be
			-- the passed in continuation
			c
	
	-- apply the function to the current entry with the appropriate continuation
	return f(data, continuation, k, v)
end

--!	apply a function over a table serially in CPS
--!	@param	data	A user defined value that will be passed to the f function
--!	@param	c		The continuation to call once this operation is complete
--!	@param	f		The function to call for each item
--!	@param	iter	The iterator function (ie, next)
--!	@param	t		The table
--!	@param	k		The previous key (nil if we're beginning to iterate)
function P.serialApply(data, c, f, iter, t, k)
	-- get the next key/value pair
	local key, value = iter(t, k)

	if key ~= nil then
		-- there is at least one entry, so apply the function with
		-- an appropriate continuation for further entries (if present)
		return P.serialApplyHelper(data, c, f, iter, t, key, value)
	else
		-- the table is empty, just call the continuation
		return c()
	end
end
--]]

function P.serialApply(data, c, f, iter, t, k0)
	local k1, v1 = iter(t, k0)

	if k1 ~= nil then
		local k, v = iter(t, k1)

		local continuation = c

		if k ~= nil then
			continuation = 
				function()
					local ki, vi = k, v

					k, v = iter(t, k)

					if k == nil then
						continuation = c
					end
					
					return f(data, continuation, ki, vi)
				end
		end

		return f(data, continuation, k1, v1)
	else
		-- the table is empty, just call the continuation
		return c()
	end
end

--! apply a function over a table in parallel in CPS
--! @param	data	A user defined value that will be passed to the f function
--! @param	c		The continuation to call once this operation is complete
--! @param	f		The function to call for each item
--! @param	iter	The iterator function (ie, next)
--! @param	t		The table
--! @param	k		The previous key (nil if we're beginning to iterate)
function P.parallelApply(data, c, f, iter, t, k0)
	local ki = iter(t, k0)
	
	if ki ~= nil then
		-- if the table is not empty
	
		-- this is a little confusing
		-- since we can't get the length of a table, we iterate once every time
		-- this join is called, and once it has been called as many times as there
		-- are entries in the table, it will get nil as the key and so it will
		-- call our continuation
		local joinContinuation = function()
				ki = iter(t, ki)
				if ki == nil then
					return c()
				end
			end
			
		-- iterate over all the entries in the table, and call f on them
		-- pass as the continuation the join continuation, which will
		-- trigger the passed in continuation to be called once all
		-- calls to f have been completed
		for k, v in iter, t, k0 do
			f(data, joinContinuation, k, v)
		end
	else
		-- the table is empty, just call the continuation
		return c()
	end
end

--! execute an array of cps functions in parallel and call a continuation when they're all finished
--!	@param	continuation	The continuation to call
--!	@param	array				An array of cps functions
function P.parallel(continuation, array)
	local count = #array
	local join = 
		function()
			count = count - 1
			if count <= 0 then
				continuation()
			end
		end

	for _, v in ipairs(array) do
		v(join)
	end
end

function P.closure(self, f)
	return 
		function(...) 
			return f(self, ...) 
		end
end

-- return a reference to our package
return P
