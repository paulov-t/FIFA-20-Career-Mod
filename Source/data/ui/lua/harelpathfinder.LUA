--! @file harelpathfinder.lua
--!	This library implements pathfinding for a harel statechart
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc.

local
	harel,
	hareltableparser,
	tableutil,
	cps
= ...

local P =
{
}

--!	Create a new pathfinder object
--!	@return	table	The pathfinder object
function P:new()
	local o =
	{
		numNodes = 0,
		nodes = {}
	}
		
	setmetatable(o, self)
	self.__index = self

	return o
end

--! Format the name of a state
--!	@param	state	The state
--!	@return	string	The formatted name of the state
local qualifiedNameCache = setmetatable({}, { __mode = 'k' })
local function getQualifiedName(state)
	local qualifiedName = qualifiedNameCache[state]

	if not qualifiedName then
		local fileParent = state.fileParent

		qualifiedName = fileParent and getQualifiedName(fileParent).."."..state.name or state.name
		qualifiedNameCache[state] = qualifiedName
	end
	
	return qualifiedName
end

--!	Get the unique id for a state, based on the qualified name
--!	@param	state	The state
--!	@return	number	The id
local ids = {}
local numIds = 0
local function getID(state)
	local qualifiedName = getQualifiedName(state)
	local id = ids[qualifiedName]
	
	if not id then
		id = numIds
		ids[qualifiedName] = id
		numIds = id + 1
	end
	
	return id
end

--!	Get the hash for a set of states
--!	@param	The set of states
--!	@return	number	The hash
--!	@note	This works because configurations are always sorted in file order, 
--!			so any two configurations that have the same set of states with the same
--!			qualified names will have the same hash
local function DJBHash(states)
	local hash = 5381

	for i = 1, #states do
		hash = (hash * 32) + hash + getID(states[i])
	end
	
	return hash
end

--!	Make a new node for the reachability tree
--!	@param	configuration	The configuration for the node
--!	@return	table			The new node
function P:makeNode(configuration)
	self.numNodes = self.numNodes + 1
	return
		{
			configuration = configuration, 
			children = {} 
		}
end

--!	Determine if two sets of states are equivalent
--!	@param	a		A set of states
--!	@param	b		Another set of states
--!	@return	boolean	true if the sets of states are equivalent, false otherwise
local function statesEqual(a, b)
	local numA = #a

	if numA == #b then
		for i = 1, numA do
			local v = a[i]
			local bv = b[i]
			if 
				v ~= bv 
			and 
				getQualifiedName(v) ~= getQualifiedName(bv) 
			then
				return false
			end
		end
		
		return true
	else
		return false
	end
end

--!	Get the node for a configuration
--!	@param	configuration	The configuration
--!	@return	table			The node
--!	@note	This function will create a new node if there is no node for this configuration
function P:getNode(configuration)
	local hash = DJBHash(configuration)
	
	local bucket = self.nodes[hash]
	
	if bucket then
		local bucketSize = #bucket

		--! Loop through nodes in this bucket and find the one matching 'configuration'
		for i = 1, bucketSize do
			if 
				statesEqual(configuration, bucket[i].configuration)
			then
				return bucket[i]
			end
		end
		--! Node is not in the bucket, create it and insert it to the bucket.
		local node = self:makeNode(configuration)
		
		bucket[bucketSize + 1] = node
		
		return node
	else
		--! Create a node for the configuration and assign it to a bucket.
		local node = self:makeNode(configuration)
		
		bucket = { node }
	
		self.nodes[hash] = bucket
		
		return node
	end
end

--!	Function for searching
--! @param	callback	The function to call when we've finished our search
--!	@param	root		The root path for the .nav files
--!	@param	fileLoader	The loader for state files
--!	@param	initial		The node to start the search
--! @param	filteredEvents The set of events not to search through
--!	@param	maxNodes	The maximum number of nodes to visit
--!	@param	halt		A function representing the halting condition
function P:search(callback, root, fileLoader, initial, filteredEvents, maxNodes, halt)
	
	local loader
	
	loader = function(cb, unresolvedState)
		--! recursively resolve states until we actually get a non-external state
		if unresolvedState.type == "external" then
			local externalState = unresolvedState.external
			local target = unresolvedState.target

			return fileLoader(
				function(data)
					local stateTable, builtStates, error = hareltableparser.parse(root, externalState.file, externalState.parent, externalState, data)
			
					if not error then
						return loader(cb, target and builtStates[target] or stateTable)
					else
						assert(false, error)
						cb(nil)
					end
				end,
				externalState.file
			)
		else
			return cb(unresolvedState)
		end
	end
		
	local sim = harel:new({ loader = loader })
	
	local actionHandler = function(c) return c() end
	
	sim:setActionNotFound(actionHandler)
	
	local numVisited = 0
	local numNodes = self.numNodes
	
	local queued = {}
	local processQueue = {}

	local function queueCmp(a, b)
		return a[3] > b[3]
	end
	
	local function addNodeToQueue(childNode, childPath, score)
		queued[childNode] = true

		tableutil.binsert(processQueue, { childNode, childPath, score }, queueCmp)
			
		collectgarbage("step", 10)
	end
	
	local function searchHelper(callback, halt)
		if #processQueue <= 0 then
			return callback()
		else
		
			local entry = table.remove(processQueue, 1)
			local node = entry[1]
			local path = entry[2]
		
			local configuration = node.configuration
			
			numVisited = numVisited + 1
			
			if numVisited >= maxNodes then
				return callback()
			end
			
			--! Get list of child nodes of the current node
			local children = node.children

			--! Get events to transition into child nodes, used as indexes for 'children'
			local events = harel.getTransitionEvents(configuration)
			
			local foundPath = nil
			--! Add children to queue if not queued previously
			return cps.serialApply(
			self,	-- data
			function()	-- post 'loop' function
				if foundPath then
					return callback(foundPath)
				else
					return searchHelper(callback, halt)
				end
			end,
			function(data, continuation, e, v)	-- function to apply
				if not foundPath then
					
					if filteredEvents[e] then
						return continuation()
					end
					
					local child = children[e]
					
					local newPath = { unpack(path) }
					newPath[#newPath + 1] = e
					
					if not child then
						--! child node not in cache. 
						--! Set Sim's configuration to current node ( configuration is list of states, 
						--! configuration is data) and process the event on it to get to the child node.
						sim:setConfiguration(tableutil.shallowcopyarray(configuration))
						--! this should be async due to file loading, but isn't
						return sim:processEvent( 
							function()
								--! newly created current configuration in sim
								local newConfiguration = sim:getConfiguration()

								child = self:getNode(newConfiguration)
								children[e] = child

								if not queued[child] then
									local found, score = halt(newConfiguration)
									if found then
										foundPath = newPath
									else
										addNodeToQueue(child, newPath, score)
									end
								end
								
								return continuation()						
							end, 
							e)
					else
						if not queued[child] then
							local found, score = halt(child.configuration)
							if found then
								foundPath = newPath
							else
								addNodeToQueue(child, newPath, score)
							end
						end
						
						return continuation()
					end
				else
					return continuation()
				end
			end,
			pairs(events)	-- iterator
			)		
		end
	end

	local function done(path)
		if not path then
			print("search failed")
		else
			print("search complete")
			if path then
				print("best path has "..#path.." events")
				tableutil.print(path)
			else
				print("no path found")
			end
		end
			
		print(self.numNodes - numNodes.." nodes generated")
		print(numVisited.." nodes visited")
		print(#processQueue.." nodes in queue to visit")
		print(self.numNodes.." nodes total")
		--print(tostring(collectgarbage("count")).." KB memory in lua")

		return callback(path, not path and "no suitable path found")
	end

	print("beginning search")

	local found, score = halt(initial)

	if not found then
		addNodeToQueue(self:getNode(initial), {}, score)
	
		return searchHelper(
			--! Callback that will print out nodes visited, total nodes, and number of hops for best path if found
			done,
			halt)
	else
		return done({})
	end
end

--!	Function for searching
--! @param	callback	The function to call when we've finished our search
--!	@param	fileLoader	The loader for state files
--!	@param	initial		The node to start the search
--! @param	filteredEvents The set of events not to search through
--!	@param	targets		The list of target states to find
function P:findPath(callback, root, fileLoader, initial, filteredEvents, targets, maxNodes)
	filteredEvents = tableutil.arrayToSet(filteredEvents, true)

	local numTargets = #targets
	return self:search(
		--! Copy list of events from results and pass it to this callback.
		callback,
		root,
		fileLoader, 
		initial,
		filteredEvents,
		maxNodes,
		--! after looping through 'states' in 'configuration' to match 'target' 
		function(configuration)
			local getQualifiedName = getQualifiedName

			local totalScore = 0
			local allFound = true

			for i = 1, numTargets do
				local target = targets[i]
				local targetScore = 0
				local found = false
				for j = 1, #configuration do
					local name = getQualifiedName(configuration[j])
					if name == target then
						targetScore = #target
						found = true
						break
					else
						local s, e = string.find(target, string.gsub(name, "%.[^%.]*$", ""), 1, true)
						local score = s == 1 and e - s + 1 or 0
						targetScore = score > targetScore and score or targetScore
					end
				end
				
				if not found then
					allFound = false
				end

				totalScore = totalScore + targetScore
			end

			if allFound then
				return true
			else
				return false, totalScore
			end
		end)
end

return P
