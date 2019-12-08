--! @file nav.lua
--! This library implements a navigation system based on the harel library
--!	@author Chris Burns (cburns@ea.com)
--!
--!	UX
--!	(c) 2011 Electronic Arts Inc.

local
	harel,
	hareltableparser,
	autonav
= ...

if EA_FINAL then
	autonav = nil
end -- EA_FINAL

local P =
{
}

--!	create a new navigation object
--! @param	init			Initialization parameters for the harel package
--!	@return	table	A new navigation object
function P:new(init)
	local o

	local loader
	loader = function(callback, unresolvedState)
			-- recursively resolve states until we actually get a non-external state
			if unresolvedState.type == "external" then
				local externalState = unresolvedState.external

				print("loading "..externalState.file)

				return o:loadHelper(
					function(state)
						return loader(callback, state)
					end,
					externalState.file,
					externalState.parent,
					externalState,
					unresolvedState.target
				)
			else
				return callback(unresolvedState)
			end
		end

	init.loader = loader

	o =
	{
		interpreter = harel:new(init),
		path = getpath(init.fileName),
		fileName = init.fileName,
		fileLoader = json.load
	}

	setmetatable(o, self)
	self.__index = self

	if not EA_FINAL then
		o.autonav = autonav:new(o)
	end -- not EA_FINAL

	return o
end

--!	a helper function for loading nav files
--!	@param	fileName	The name of the file to load
--!	@param	parent		The parent state, or nil
--!	@param	fileParent	The file parent, or nil
--!	@return	table		The parsed state table
function P:loadHelper(callback, fileName, parent, fileParent, target)
	return self.fileLoader(
		function(data, error)

			local fail = nil

			local parse =
				function(data)
					local stateTable, builtStates, error = hareltableparser.parse(self.path, fileName, parent, fileParent, data)

					if not error then
						return callback(target and builtStates[target] or stateTable)
					else
						return fail(error)
					end
				end

			fail =
				function(error)
					if self.loadFailed and fileParent then

						local outputs = {}

						if fileParent.outputs then
							for k, v in pairs(fileParent.outputs) do
								outputs[k] = v.name
							end
						end

						self.loadFailed(parse, error, fileName, next(outputs, nil) and outputs)
					else
						assert(false, "Error loading "..fileName..": "..error)
						return callback(nil)
					end
				end

			if data then
				return parse(data)
			else
				return fail(error)
			end
		end,
		fileName
	)
end

--!	add an action to the navigation system
--! @param name		The action name
--!	@param async	Whether or not the action is asynchronous
--! @param read		The data to read for this action
--!	@param handler	The action handler
function P:addAction(...)
	return self.interpreter:addAction(...)
end

--!	remove an action from the navigation system
--! @param name		The action name
function P:removeAction(...)
	return self.interpreter:removeAction(...)
end

function P:setLoadFailed(handler)
	self.loadFailed = handler
end

--!	add the handler for missing actions to the navigation system
--!	@param handler	The handler
function P:setActionNotFound(handler)
	return self.interpreter:setActionNotFound(handler)
end

function P:saveConfiguration(callback)
	return self.interpreter:saveConfiguration(callback)
end

function P:loadConfiguration(callback, configuration)
	return self.interpreter:loadConfiguration(callback, configuration)
end

--!	start the navigation system
--!	@param	done	The continuation to call for this function
function P:start(done)
	return self:loadHelper(
		function(state)
			return self.interpreter:start(done or function() end, state)
		end,
		self.fileName
		)
end

--!	process an event
--!	@param	done	The continuation to call for this function
--!	@param	e		The event to process
function P:event(done, e, data)
	return self.interpreter:processEvent(
		done or function() end,
		e,
		data
		)
end

if not EA_FINAL then

	--!	Add a listener to the nav object
	--!	@param	name		The name of the listener
	--! @param	filter		The array of events to listen to
	--!	@param	listener	The listener
	function P:addListener(...)
		return self.interpreter:addListener(...)
	end

	--!	Remove a listener from the nav object
	--!	@param	name		The name of the listener
	function P:removeListener(...)
		return self.interpreter:removeListener(...)
	end

	--! get the names of the states in the current configuration of the navigation system
	--!	@param	callback	A function that accepts the list of the names of the states
	function P:getStates(callback)
		return self.interpreter:getConfigurationAsync(
			function(configuration)
				local names = {}
				for i, v in ipairs(configuration) do
					names[i] = harel.getQualifiedName(v)
				end

				return callback(names)
			end
			)
	end

	--! Get all events that have transitions for the current configuration
	--!	@param	callback	A callback to receive the set of events
	function P:getTransitionEvents(callback)
		return self.interpreter:getTransitionEventsAsync(callback)
	end

	--! Gets the active states as a tree, including information useful for reflection.
	--! @param callback A callback to receive the tree.
	function P:getConfiguration(callback)
		return self.interpreter:getConfigurationAsync(
			function(configuration)
				local root = nil
				local activestates = {}

				-- First record each active state. We'll build the tree after.
				for i,state in ipairs(configuration) do
					local s = {}
					root = root or s
					activestates[state] = s

					s.name = state.name
					s.id = harel.getQualifiedName(state)
					if state.fileParent then
						s.file = state.fileParent.file
					else
						s.file = self.fileName
					end
					s.parentlink = state.parent
				end

				-- Now go through the active states and build the tree.
				for k,child in pairs(activestates) do
					if child.parentlink then
						local parent = activestates[child.parentlink]
						parent.states = parent.states or {}
						parent.states[#parent.states+1] = child
						child.parentlink = nil
					end
				end

				return callback(root)
			end
		)
	end
    
    function P:reload(done, name)
        return self.interpreter:reload(done or function() end, name)
    end

	--!	automatically navigate to a configuration containing the given target states
	--! @param callback			The callback to call once the automatic navigation is completed
	--! @param defaultHandler	The function to call for uninteresting events
	--! @param hintFile			The name of a file containing hints for what to do with unusual events
	--!	@param excludeFile		The name of a file containing a list of events to exclude from the path
	--!	@param maxNodes			How many nodes to search
	function P:auto(callback, defaultHandler, hintFile, excludeFile, targets, maxNodes)
		return self.autonav:navigate(callback, defaultHandler, hintFile, excludeFile, targets, maxNodes)
	end

	function P:addAutoHandler(name, handler)
		return self.autonav:addHandler(name, handler)
	end

	function P:removeAutoHandler(name)
		return self.autonav:removeHandler(name)
	end

end -- not EA_FINAL

return P
