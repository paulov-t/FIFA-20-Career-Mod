--! @file autonav.lua
--! This library implements automatic navigation
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc.

local
	cps,
	tableutil,
	harelpathfinder
= ...

local P = 
{
}

--! create a new autonav object
--! @param nav		The nav object that we want to do autonav for
--!	@return	table	The autonav object
function P:new(nav)
	local o =
	{
		nav = nav,
		pathfinder = harelpathfinder:new(),
		handlers = {}
	}

	setmetatable(o, self)
	self.__index = self
	
	return o
end

--! create a cached file loader from a file loader
--!	@param	The file loader
--!	@return	function	The cached file loader
function P.cacheFileLoader(fileLoader)
	local cache = {}

	return 
		function(callback, fileName)
			local data = cache[fileName]
			
			if data then
				return callback(data)
			else
				return fileLoader(
					function(data)
						cache[fileName] = data
						return callback(data)
					end,
					fileName
					)
			end
		end
end

function P.getHint(hints, eventList, i)
	local children = hints.children

	if children then
		local child = children[eventList[i]]

		if child then
			local value, index = P.getHint(child, eventList, i + 1)

			if value then
				return value, index
			end
		end
	end

	return hints.value, i - 1
end

function P.match(hints, eventList)
	return 
		function(e, i)
			i = i + 1

			if e[i] then
				local hint, index = P.getHint(hints, e, i)

				if hint then
					return index, hint
				else
					return i
				end
			end
		end,
		eventList,
		0
end

function P.insertHint(hints, path, hint)
	local node = hints

	for _, v in ipairs(path) do
		if not node.children then
			node.children = {}
		end

		local child = node.children[v]
		if not child then
			child = {}
			node.children[v] = child
		end

		node = child
	end

	node.value = hint
end

--!	automatically navigate to a configuration containing the given target states
--! @param callback			The callback to call once the automatic navigation is completed
--! @param defaultHandler	The function to call for uninteresting events
--! @param hintFile			The name of a file containing hints for what to do with unusual events
--!	@param excludeFile		The name of a file containing a list of events to exclude from the path
--!	@param maxNodes			How many nodes to search
function P:navigate(callback, defaultHandler, hintFile, excludeFile, targets, maxNodes)

	local hints = {}

	local excludedEvents

	local function empty() end

	local auto

	auto = 
		function()
			--profiler.start()
			return self:findPath(
				function(eventList, error)
					--profiler.stop()

					if eventList ~= nil then

						return cps.serialApply(
							nil,
							function()
								return self.nav:getStates(
									function(states)

										local allFound = true	

										for _, t in ipairs(targets) do
											local found = false

											for _, s in ipairs(states) do
												if t == s then
													found = true
												end
											end

											if not found then
												allFound = false
												break
											end
										end

										if allFound then
											return callback(true)
										else
											print("target states not reached, retrying autonavigation")
											return auto()
										end
									end)
							end,
							function(_, c, index, hint)
								if interrupted then
									return c()
								end

								local expected
								local i = 1

								local function listener(_, e)

									if e == expected[i] then
										if i == #expected then
											self.nav:removeListener("autonav")
											return c()
										end

										i = i + 1
									end
								end

								self.nav:addListener("autonav", { "eventProcessed" }, listener)

								if hint then
									expected = hint[3] or hint[1]

									return cps.serialApply(
										nil,
										empty,
										function(_, c, index, handler)
											local name = handler[1]
											local parameters = handler[2]
											self.handlers[name](c, name, unpack(parameters))
										end,
										ipairs(hint[2])
										)
								else
									expected = { eventList[index] }

									return defaultHandler(empty, eventList[index])
								end
							end,
							P.match(hints, eventList))
					else
						if callback then return callback(false, error) end
					end
				end,
				excludedEvents,
				targets,
				maxNodes)
		end

	cps.parallel(
		auto,
		{
			function(c)
				return json.load(
					function(data)
						for i, v in ipairs(data) do
							P.insertHint(hints, v[1], v)
						end

						return c()
					end, 
					hintFile)
			end,
			function(c)
				return json.load(
					function(data)
						excludedEvents = data
						return c()
					end,
					excludeFile)
			end
		})
end

function P:addHandler(name, handler)
	self.handlers[name] = handler
end

function P:removeHandler(name, handler)
	self.handlers[name] = nil
end

--! find the shortest path to a configuration with a given set of targets using a search tree of a given depth
--! @param callback			A function to call when the path has been found is complete (a list of events will be passed into this function)
--! @param excludedEvents	An array of events we don't want in our path
--! @param targets			An array of the names of the targets we want to reach
--!	@param maxNodes			The maximum number of nodes to search
function P:findPath(callback, excludedEvents, targets, maxNodes)
	return self.nav.interpreter:getConfigurationAsync(
		function(configuration)
			return self.pathfinder:findPath(callback, self.nav.path, self.nav.fileLoader, tableutil.clone(configuration), excludedEvents, targets, maxNodes)
		end)
end

return P
