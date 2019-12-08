--! @file navtester.lua
--! This library implements testing for navigation
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc.

local
	cps,
	tableutil,
	nav
= ...

local P =
{
}

--!	create a new navtester object
--!	@return	table	The new navtester object
function P:new()
	local o = 
	{
		viewId = 0
	}
	
	setmetatable(o, self)
	self.__index = self
	
	return o
end

--!	a verification function that expects no more actions
--!	@param	name	The name of the action
--!	@note	If called, this function always triggers a test assert
function P.emptyVerify(name, ...)
	local error = "received unexpected action "..name.."("
	
	if arg[1] ~= nil then
		error = error..tableutil.tostring(arg[1])
	end
	
	error = error..")"
		
	testassert(false, error)
end

--!	comparison function for argument lists
--!	@param	a	An array
--!	@param	b	An array
--!	@return	true if a and b are equivalent as arrays, false otherwise
--!	@note	Should this be in tableutil?
function P.equals(a, b)
	if type(a) == "table" and type(b) == "table" then
		if #a ~= #b then
			return false
		end
	
		for i, v in ipairs(a) do
			if not P.equals(b[i], v) then
				return false
			end
		end
	
		return true
	else
		return a == b
	end
end

--!	@param	recursively create a chain of verification functions by iterating over a table
--!	@param	iter		The iteration function
--!	@param	t			The table
--!	@param	k			The key
--!	@return	function	A verification function that will set up the next verification function when it is called
function P:makeVerify(iter, t, k)
	local key, value = iter(t, k)

	if key ~= nil then
		return function(name, ...)
				local actionName = value[1]
				local actionParameters = value[2]
				
				if name == actionName and P.equals(arg, actionParameters) then
					print("action "..name.."(\n"..tableutil.tostring(arg).."\n) verified")
					
					self.verify = self:makeVerify(iter, t, key)
				else
					local error = "received "..name.."(\n"
					
					error = error..tableutil.tostring(arg)
					
					error = error..") expected "..actionName.."("
					
					error = error..tableutil.tostring(actionParameters)
					
					error = error..")"
					
					testassert(false, error)
				end
			end
	else
		return self.emptyVerify
	end
end

--!	Test a particular event
--!	@param	c		The continuation to call after this event has been tested
--!	@param	key		not used, here so that we can pass this to the cps function
--!	@param	value	The entry for this event (contains the event and the expected actions)
function P:testEvent(c, key, value)
	local actions = value.actions
	
	self.verify = self:makeVerify(ipairs(actions))
	
	local done = function()
		print("done waiting")
		
		if self.verify ~= self.emptyVerify then
			testassert(testassert, "still actions to verify!")
		end
		
		return c()
	end
	
	if value.event then
		return self.nav:event(done, value.event, value.data)
	elseif value.back then
		return self.nav:back(done, value.back)
	else
		return self.nav:start(done)
	end
end

--!	Do the test
--!	@param	test	The test data
function P:test(callback, test)
	return cps.serialApply(						
		self,
		function()
			print("test complete")
			return callback()
		end,
		self.testEvent,
		ipairs(test)
	)
end

--!	Run the test
--! @param  callback			The function to call when the test is done
--!	@param	navFileName		The name of the nav file
--!	@param	testFileName	The name of the test file
--!	@param	actionFileName	A .lua file defining the actions
function P:run(callback, navFileName, testFileName)
	self.nav = nav:new({ debug = false, fileName = navFileName })
	self.verify = self.emptyVerify
	
	self.nav:setActionNotFound(function(c, ...) self.verify(...) return c() end)
	
	self.nav:addAction(
		"asyncTask",
		false,
		nil,
		function(name, task, event)
			self.verify(name, task, event)

			if event ~= nil then
				self.nav:event(nil, event)
			end
		end
		)
	
	return json.load(
		function(testData)
			return self:test(callback, testData)
		end,
		testFileName)
end

return P
