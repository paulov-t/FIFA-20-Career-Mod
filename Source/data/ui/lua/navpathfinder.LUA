--! @file navpathfinder.lua
--! This library implements a basic nav pathfinder for testing purposes
--!	@todo	Hook up proper scripting instead of passing the target state!
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc.

local
	nav,
	autonav
= ...

local P =
{
}

--!	Create a new navpathfinder object
--!	@return	table	The new navpathfinder
function P:new()
	local o = {}
	
	setmetatable(o, self)
	self.__index = self
	
	return o
end

--!	Run our test on a given nav file with a given target
--! @param  callback			The function to call when the test is done
--!	@param	navFileName			The .nav file name
--!	@param	actionsFileName		A lua file defining the set of actions
--!	@param	hintFileName		A json file specifying hints
--!	@param	excludeFileName		A json file specifying events to exclude
--!	@param	target				The name of the target state
function P:run(callback, navFileName, hintFileName, excludeFileName, target)
	self.nav = nav:new({ debug = true, fileName = navFileName })
	
	self.nav:setActionNotFound(function(c) c() end)
	
	self.nav:addAction(
		"asyncTask", 
		false,
		nil,
		function(name, task, event)
			if event ~= nil then
				self.nav:event(nil, event)
			end
		end
	)
	
	self.autonav = autonav:new(self.nav)
	
	return self.nav:start(
		function()
			return self.autonav:navigate(callback, function(callback, name) self.nav:event(callback, name) end, hintFileName, excludeFileName, { target }, 100)
		end)
end

return P
