--! @file harel.lua
--!	This library implements a Harel state chart interpreter. A StateChart permits composite and parallel states.
--! The implementation here is based on SCXML, although it uses LUA tables for representing the state chart.
--!	@author Chris Burns (cburns@ea.com)
--!	
--!	UX
--!	(c) 2011 Electronic Arts Inc. 

local
	cps,
	tableutil
= ...

--!	sort function for states
--!	@param	a		A state
--!	@param	b		Another state
--! @return	boolean	true if a precedes b, false otherwise
local function stateSorter(a, b)
	-- a, b = stateSorterHelper(a, b)

	local fileLevel = b.fileLevel
	while(a.fileLevel > fileLevel) do
		a = a.fileParent
	end
	
	fileLevel = a.fileLevel
	while(b.fileLevel > fileLevel) do
		b = b.fileParent
	end
	
	while(a.fileParent ~= b.fileParent) do
		a = a.fileParent
		b = b.fileParent
	end
	
	return a.fileOrder < b.fileOrder
end

--!	reversed sort function for states
--!	@param	a		A state
--!	@param	b		Another state
--! @return	boolean	true if b precedes a, false otherwise
local function stateSorterReversed(a, b)
	-- a, b = stateSorterHelper(a, b)

	local fileLevel = b.fileLevel
	while(a.fileLevel > fileLevel) do
		a = a.fileParent
	end
	
	fileLevel = a.fileLevel
	while(b.fileLevel > fileLevel) do
		b = b.fileParent
	end
	
	while(a.fileParent ~= b.fileParent) do
		a = a.fileParent
		b = b.fileParent
	end
	
	return a.fileOrder > b.fileOrder
end

--! sort function for states as keys in pair form
--!	@param a		An entry
--!	@param b		Another entry
--!	@return boolean	true if a[1] precedes b[1], false otherwise
local function stateSorterP(a, b)
	return stateSorter(a[1], b[1])
end

--! reverse sort function as keys in pair form
--!	@param	a		A entry
--!	@param	b		Another entry
--! @return	boolean	The negative of stateSorterP(a, b)
local function stateSorterPReversed(a, b)
	return stateSorterReversed(a[1], b[1])
end

--! turn a table into an array in k/v form
--! @param	t		The table
--!	@return	array	A new array containing the keys of the set
local function tableToArray(t)
	local a = {}
	local i = 1
	
	for k, v in pairs(t) do
		a[i] = { k, v }
		i = i + 1
	end
	
	return a
end

--! sort a set of states in reverse
--!	@param	states	The set of states
--!	@return	array	The states, in a reverse sorted array
local function sortStatesSetReversed(states)
	local a = tableToArray(states)
	table.sort(a, stateSorterPReversed)
	return a
end

--!	sort a set of states
--!	@param	states	The set of states
--!	@return	array	The states, in a sorted array
local function sortStatesSet(states)
	local a = tableToArray(states)
	table.sort(a, stateSorterP)
	return a
end

--! modified version of or that only returns the rhs if the lhs is actually nil (not just false)
--! naturally it is not infix and does not have or's short circuit evaluation abilities (sad face)
--! @param lhs      The left hand side
--! @param rhs      The right hand side
--! @return value   The lhs, if not nil, otherwise the rhs
local function ornil(lhs, rhs)
    if lhs ~= nil then
        return lhs
    else
        return rhs
    end
end

-- create a table to represent this package
local P =
{
}

--! construct a new state chart interpreter
--! @return	table	The new interpreter
function P:new(init)
	local debug = not EA_FINAL and init.debug

	local o =
	{
		loader = init.loader,
		let = init.let or {},
		isProcessing = false,
		configuration = {},
		internalQueue = {},
		externalQueue = {},
		listeners = {},
		debug = debug
	}
	
	-- read-only global environment for ".event"
	o.globalWEnv = setmetatable({}, { __index = function(t, k) return k == "event" and o.event or nil end })
	
	-- read-only environment for actions
	o.actionEnv = setmetatable({}, { __index = function(t, k) local wEnv = o.actionState.wEnv return ornil(wEnv and wEnv[k], ornil(o.actionData[k], o.globalWEnv[k])) end })
		
	setmetatable(o, self)
	self.__index = self

	-- set up the invoke action
	o:addAction("invoke",
				false,
	            nil,
	            function(name, ...)
					-- insert the event into the internal queue
					local queue = o.internalQueue
					queue[#queue + 1] = { fn = P.eventTask, args = { ... } }
				end
				)
				
	o:addAction("call",
				false,
				nil,
				function(name, fn, parameters)
					if fn then
						parameters = parameters or {}
						fn(unpack(parameters))
					end
				end
				)
	        
		
	-- set up the set action
	o:addAction("set", 
				false,
				nil,
				function(name, dst, src)
					return {{[dst] = src}}
				end
				)
				
	o.globalWEnv["if"] = self.ifAction

	return o
end

--!	Add a listener to be notified when an event has been processed
--!	@param	name		The name of the listener
--! @param	filter		The array of events to listen to
--!	@param	listener	The listener to add
function P:addListener(name, filter, listener)
    self.listeners[name] = { filter = tableutil.arrayToSet(filter, true), listener = listener }
end

--!	Remove a listener
--!	@param	name		The name of the listener
--!	@param	listener	The listener to remove
function P:removeListener(name)
    self.listeners[name] = nil
end

--!	Dispatch an event to all the listeners
--!	@param	name		The name of the event
--!	@note	The table of listeners will be duplicated before the event is dispatched so that add or removeListener can be called re-entrantly
function P:dispatch(name, ...)
    local tmp = tableutil.shallowcopy(self.listeners)

    for k, v in pairs(tmp) do
        if v.filter[name] then
            v.listener(name, ...)
        end
    end
end

local function getQualifiedId(state)
    local result = state.fileParent and getQualifiedId(state.fileParent) or {}
    
    result[#result + 1] = state.fileOrder
    
    return result
end

local getQualifiedName

if not EA_FINAL then

	--! create a debug continuation
	--!	@param	continuation	The continuation
	--!	@param	message			The message associated with this continuation
	--!	@return	function		The debug continuation
	function P:debugContinuation(continuation, message)
		self:dispatch("debugPush", message)
		return function(...) self:dispatch("debugPop") return continuation(...) end
	end

	--!	get the qualified name for a state
	--!	@param	state	The state
	--!	@return	string	The qualified name
	function getQualifiedName(state)
		local fileParent = state.fileParent
		local name = state.name
		return fileParent and getQualifiedName(fileParent).."."..name or name
	end

	P.getQualifiedName = getQualifiedName

	--! set the configuration for the interpreter
	--!	@param	configuration	The set of states in the configuration
	function P:setConfiguration(configuration)
		self.configuration = configuration
	end

	--! get the configuration from the interpreter
	--!	@return	table	The set of states in the configuration
	function P:getConfiguration()
		assert(not self.isProcessing)
		
		return self.configuration
	end

	--! asynchronously retrieve the configuration from the interpreter
	--! @param callback	A callback to receive the set of states in the configuration
	function P:getConfigurationAsync(callback)
		local configuration
		
		return self:process(
							function()
								return callback(configuration) 
							end, 
							function(interpreter, continuation)
								configuration = interpreter.configuration
								return continuation() 
							end
							)
	end

	--! Get all events that have transitions for a given configuration
	--!	@param	configuration	A state chart interpreter configuration
	--!	@return	table			A set of events
	local function getTransitionEvents(configuration)

		local events = {}
	
		for i = 1, #configuration do
			local transitions = configuration[i].transitions

			if transitions then
				for j = 1, #transitions do
					events[transitions[j].event] = true
				end
			end
		end
	
		return events
	end

	P.getTransitionEvents = getTransitionEvents

	--! Get all events that have transitions for the current configuration
	--!	@param	callback	A callback to receive the set of events
	function P:getTransitionEventsAsync(callback)
		local events = {}
		
		return self:process(
							function()
								return callback(events) 
							end, 
							function(interpreter, continuation)
								local numEvents = 0

								for k in pairs(getTransitionEvents(interpreter.configuration)) do
									numEvents = numEvents + 1
									events[numEvents] = k
								end

								return continuation() 
							end
							)
	end
    
    
    function P:reload(continuation, name)
        return self:process(continuation, P.reloadTask, name)
    end
    
    function P:reloadTask(continuation, name)
        for _, v in ipairs(self.configuration) do
            if getQualifiedName(v) == name then
                local targets = { v }
                local lca = self.getLeastCommonAncestor(v, targets)
                local data = { {} }
                local statesToExit = lca and self:getStatesToExit(lca, data) or {}
            
                return self:processTransitions(
                    self.debug and self:debugContinuation(continuation, "reload") or continuation, 
                    { { source = v, targets = targets, lca = lca, actions = {}, data = { {} } } },
                    statesToExit
                )
            end
        end
    end
	
end -- not EA_FINAL

--! Read variables from an environment
--! @param	env		The environment to read from
--!	@param	read	A list of variables to read
--!	@return	table	A set of read variables (keyed by name)
local function readVariables(env, read)
	local r = {}
	
	for i = 1, #read do
		local v = read[i]
		r[v] = env[v]
	end
	
	return r
end

local primitives

--! Recursive expression evaluator
--!	@param	env		The environment to use
--!	@param	expr	The expression to evaluate
--!	@return	table	The value of the expression
local function evaluate(env, expr)
	if type(expr) == "string" then
		if string.sub(expr, 1, 1) == "." and string.sub(expr, 2, 2) ~= "." then
			for name in string.gmatch(expr, ".([^.]+)") do
				if env == nil then
					break
				end
				
				env = env[name]
			end
			
			return env
		else
			return expr
		end
	elseif type(expr) == "table" then
		local name = expr[1]

		if name and type(name) == "string" then
			-- is this comparison chain faster than a table of closures? We are not sure...
			local primitive = primitives[name]
			if primitive then
				return primitive(env, expr)
			else
				local p = {}
				local n = #expr
				for i = 2, n do p[i - 1] = evaluate(env, expr[i]) end
				
				local f = env[name]
				return (type(f) == "function" or type(f) == "userdata") and f(unpack(p))
			end
		else
			local r = {}
			for k, v in pairs(expr) do r[k] = evaluate(env, v) end
			return r
		end
	else
		return expr
	end
end

-- primitives the expression evaluator can use
primitives =
{
	["=="] =
		function(env, expr)
			return tableutil.equal(evaluate(env, expr[2]), evaluate(env, expr[3]))
		end,
	["or"] =
		function(env, expr)
			return evaluate(env, expr[2]) or evaluate(env, expr[3])
		end,
	["and"] =
		function(env, expr)
			return evaluate(env, expr[2]) and evaluate(env, expr[3])
		end,
	["array"] =
		function(env, expr)
			local r = {}
			for i = 2, #expr do r[i - 1] = evaluate(env, expr[i]) end
			return r
		end,
	["?"] =
		function(env, expr)
			if(evaluate(env, expr[2])) then return evaluate(env, expr[3])
			else return evaluate(env, expr[4]) end
		end
}

--! Helper function that evaluates an array of expressions
--!	@param	env		The environment to use
--!	@param	a		The array of expressions
--!	@return	table	The value of the expression
local function evaluateArray(env, a)
	local r = {}
	for i = 1, #a do r[i] = evaluate(env, a[i]) end
	return r
end

--!	This function adds an action to the interpreter
--!	The handler should be a function that accepts the following arguments:
--!
--!	1. (only for asynchronous handlers)
--!	a no-argument continuation/callback that is to be called when the action is complete
--!
--!	2.
--!	a string naming the action to take
--!
--!	3. (only for actions added with a non-nil, non-empty read parameter)
--!	an object containing the read variables
--!
--!	4.
--!	an arbitrary parameter for the action
--!
--!	@param	name	The action name
--!	@param	async	Whether or not the action is asynchronous
--! @param	read	The variables to read
--!	@param	handler	The handler function
function P:addAction(name, async, read, handler)
	self.globalWEnv[name] = 
		function(interpreter, c, p)

			local function callback(write, delete)
            
				local env = interpreter.actionState.wEnv
								
				if env then
					if write then
						for k, v in pairs(write) do
							env[k] = v
						end
					end
								
					if delete then
						for i = 1, #delete do
							env[delete[i]] = nil
						end
					end
				end
								
				return c()
			end

			local e = interpreter.actionEnv

			local rp = p and evaluateArray(e, p) or {}

			local n = #rp

			if read and next(read) then
				local r = readVariables(e, read)
				r = next(r, nil) and r

				rp = { r, unpack(rp, 1, n) }
				n = n + 1
			end
		
			if async then
				return handler(callback, name, unpack(rp, 1, n))
			else
				local data = handler(name, unpack(rp, 1, n))
				if data then
					return callback(unpack(data))
				else
					return c()
				end
			end
		end
end

--! This function removes an action from the interpreter
--!	@param	name	The action name
function P:removeAction(name)
	self.globalWEnv[name] = nil
end

--!	Set the handler to be called when an action cannot be found
--!	@param	handler	The handler
function P:setActionNotFound(handler)
	self.actionNotFound = handler
end

--! Save the current configuration as a tree of state indices
--! @param callback	The callback to call with the configuration
function P:saveConfiguration(callback)
	local configuration = nil

	return self:process(
			function() return callback(configuration) end,
			function(interpreter, continuation)
				local fragments = {}
				
				for _, state in ipairs(interpreter.configuration) do
					
					local parent = state.parent
					
					if parent then
						local child = state.fileParent and state.fileParent.parent == parent and state.fileParent or state

						local index = 1
						for i, v in ipairs(parent.states) do if v == child then index = i break end end
						
						local fragment = { index, {} }
						table.insert(fragments[parent][2], fragment)
						fragments[state] = fragment
					else
						configuration = { 1, {} }
						fragments[state] = configuration
					end
				end
				
				return continuation()
			end
		)
end

function P:resolveStateFromConfiguration(state)
	local parent = state.parent
	local external = state.type == "external"
	for _, v in ipairs(self.configuration) do
		if v == state or (external and v.fileParent == state and v.parent == parent) then
			return v
		end
	end
		
	return nil
end

function P:addStatesToEnterFromFragment(continuation, statesToEnter, fragment, unresolvedState, data)
	return self:resolveState(
			function(state)
				statesToEnter[state] = data
				
				return cps.parallelApply(
						self,
						continuation,
						function(interpreter, c, _, f)
							interpreter:addStatesToEnterFromFragment(c, statesToEnter, f, state.states[f[1]], data)
						end,
						ipairs(fragment[2])
					)
			end,
			unresolvedState
		)
end

function P:addStatesToExitAndEnterFromFragment(continuation, statesToEnter, statesToExit, fragment, state, data)
	local states = state.states
	if states then
		return cps.parallelApply(
				self,
				continuation,
				function(interpreter, c, i, s)
					
					local resolved = interpreter:resolveStateFromConfiguration(s)
					
					if fragment then
						for _, f in ipairs(fragment[2]) do
							if f[1] == i then
								if not resolved then
									return interpreter:addStatesToEnterFromFragment(c, statesToEnter, f, s, data)
								else
									return interpreter:addStatesToExitAndEnterFromFragment(c, statesToEnter, statesToExit, f, resolved, data)
								end
							end
						end
					end

					if resolved then
						statesToExit[resolved] = data
						return interpreter:addStatesToExitAndEnterFromFragment(c, statesToEnter, statesToExit, nil, resolved, data)
					end
					
					return c()
				end,
				ipairs(states)
			)
	else
		return continuation()
	end
end

function P:loadConfiguration(callback, configuration)
	return self:process(
			callback,
			function(interpreter, continuation)
				local statesToExit = {}
				local statesToEnter = {}
			
				return interpreter:addStatesToExitAndEnterFromFragment(
						function()
							local sortedStatesToExit = sortStatesSetReversed(statesToExit)
							local sortedStatesToEnter = sortStatesSet(statesToEnter)
										
							return interpreter:exitAndEnterStates(continuation, sortedStatesToExit, sortedStatesToEnter)
						end,
						statesToEnter,
						statesToExit,
						configuration,
						self.configuration[1],
						{ {} }
					)
			end
		)
end

--! @return boolean	true if the named state is properly descendant from another named state, false otherwise
--!	@note			a state is not its own proper descendant
--!	@param	state				The state
--!	@param	possibleAncestor	A state that the state may be descendant from
local function isProperDescendant(state, possibleAncestor)
	repeat
		state = state.parent
	until state == possibleAncestor or state == nil
	
	return state == possibleAncestor
end

--! @return	boolean	true if the named state is descendant from another named state, false otherwise
--!	@note	a state is considered to be its own descendant
--!	@param	state				The state
--!	@param	possibleAncestor	A state that the state may be descendant from
--! @note	This function works with external states
local function isDescendantExternal(state, possibleAncestor)
	local parent
	local pAParent = possibleAncestor.parent
	
	repeat
		parent = state.parent
		-- this comparison is the best razor we have, so do it first
		if parent == pAParent then
			if state == possibleAncestor or state.fileParent == possibleAncestor then
				return true
			end
			break
		end
		state = parent
	until state == nil
	
	return false
end

--! @return	array	all the proper ancestors of a state up to but not including root
--!	@return	state	The state whose ancestors we are retrieving
--!	@return	root	The state where we will stop accumulating, or nil
local properAncestorsCache = setmetatable({}, { __mode = 'kv' })
local function getProperAncestors(state, root)
	local properAncestors

	if not root then
		properAncestors = properAncestorsCache[state]
	end

	if not properAncestors then
		local index = 1
		properAncestors = {}
	
		local parent = state.parent
	
		while parent ~= root do
			properAncestors[index] = parent
		
			index = index + 1
		
			parent = parent.parent
		end

		if not root then
			properAncestorsCache[state] = properAncestors
		end
	end
	
	return properAncestors
end

--! @return	table	The least common ancestor of source and targets, or nil
--!	@param	source	A source state
--!	@param	targets	An array of target states
--!	@note			not a very efficient implementation of least common ancestor
--!					this is what SCXML does, however
local function getLeastCommonAncestor(source, targets)
	local properAncestors = getProperAncestors(source, nil)
	
	for i = 1, #properAncestors do
		local ancestor = properAncestors[i]
	
		local notCommon = false
		for j = 1, #targets do
			if not isProperDescendant(targets[j], ancestor) then
				notCommon = true
				break
			end
		end
		
		-- evil double negatives
		if not notCommon then
			return ancestor
		end
	end

	return nil
end

P.getLeastCommonAncestor = getLeastCommonAncestor

--!	This function retrieves a continuation that should be called after processing a task
--! It more or less behaves as a co-routine with processExternalQueue
--!	@param	continuation	The continuation to call after the continuation we are going to create is complete
function P:getProcessTaskInternalContinuation(continuation)
	return function()
			if #self.internalQueue > 0 then
				-- get the task
				local task = self.internalQueue[1]
				
				-- remove the task from the queue
				table.remove(self.internalQueue, 1)
				
				return task.fn(self, self:getProcessTaskInternalContinuation(continuation), unpack(task.args))
			else
				return continuation() -- no more tasks, call our continuation
			end
		end
end

--! process a named event
--!	@param	continuation	The continuation to call after the event has been processed
--!	@param	name			The name of the event
--!	@param	data			The data associated with the event
function P:processEvent(continuation, name, data)
	return self:process(function() self:dispatch("eventProcessed", name, data) if continuation then return continuation() end end or continuation, P.eventTask, name, data)
end

--! function to be queued for starting the interpreter
--!	@param	continuation	The continuation to call after starting the interpreter is complete
--! @param	state			The initial state
function P:startTask(continuation, state)
	return self:processTransitions(
			self.debug and self:debugContinuation(continuation, "start") or continuation, 
			{ { targets = { state }, actions = {}, data = { {} } } },
			{}
		)
end

--! start the interpreter by processing a transition into the root state of the provided state chart
--!	@param	continuation	The continuation to call after the interpreter has been started
--! @param	state			The initial state
function P:start(continuation, state)
	return self:process(continuation, P.startTask, state)
end

--!	queue and perhaps process a task
--!	@param	continuation	The continuation to call after the task is complete
--!	@param	fn				The function representing the task
function P:process(continuation, fn, ...)
	-- always add the task to the end of the queue
	-- this simplifies the algorithm
	local task = { continuation = continuation, fn = fn, args = { ... } }
	
	local queue = self.externalQueue
	queue[#queue + 1] = task

	-- process our external queue
	return self:processExternalQueue()
end

--! process some transitions, and continuously process eventless transitions afterwards until no
--! further eventless transitions are available
--! @param	continuation	The continuation to call after the transitions (and any subsequent eventless transitions) have been processed
--!	@param	transitions		The transitions to process
--!	@param	statesToExit	The states that will be exited by the given transitions
function P:processTransitions(continuation, transitions, statesToExit)
	return self:microstep(
		function()
			-- select eventless transitions
			local transitions, statesToExit = self:selectTransitions()
			
			if #transitions > 0 then
				return self:processTransitions(continuation, transitions, statesToExit)
			else
				return continuation()
			end
		end,
		transitions,
		statesToExit
		)
end

--! function to be queued for processing an event
--!	@param	continuation	The continuation to call after the event has been processed
--!	@param	name			The name of the event
--!	@param	data			The data associated with the event
function P:eventTask(continuation, name, data)
	continuation = self.debug and self:debugContinuation(continuation, "event "..tostring(name)..", data "..tableutil.tostring(data)) or continuation

	if name then
		self.event = { name = name, data = data }
		
		local transitions, statesToExit = self:selectTransitions(name)

		return self:processTransitions(function() self.event = nil return continuation() end, transitions, statesToExit)
	else
		return continuation()
	end
end

--!	Exit a set of states and enter another set of states
--!	@param	continuation	The continuation to call after everything is done
--!	@param	statesToExit	An array of states to exit in the order they are to be exited
--!	@param	statesToEnter	An array of states to enter in the order they are to be entered
function P:exitAndEnterStates(continuation, statesToExit, statesToEnter)
	return self:exitStates(
		function()
			return self:enterStates(
				continuation,
				statesToEnter, 
				{}
				)
		end, 
		statesToExit
		)
end

--!	process the interpreter's external queue until it is empty, or do nothing if the interpreter is already processing
function P:processExternalQueue()
	-- if the interpreter is not currently busy and if there is at least one entry in the queue
	if not self.isProcessing and #self.externalQueue > 0 then
	
		-- we are now processing an task
		self.isProcessing = true
		
		-- grab the task and its corresponding continuation
		local externalTask = self.externalQueue[1]
		
		local fn = externalTask.fn
		local args = externalTask.args
		local continuation = externalTask.continuation
		
		-- remove it from the queue
		table.remove(self.externalQueue, 1)
		
		-- process the task
		local queue = self.internalQueue
		queue[#queue + 1] = { fn = fn, args = args }
	
		return self:getProcessTaskInternalContinuation(
			function()
			
				-- when we are done processing the task, call its continuation(), and then try to process the next task
				self.isProcessing = false
				
				if continuation then
					continuation()
				end
				
				return self:processExternalQueue()
			end
			)()
	end
end

--!	@return	boolean	true if the state is compound, false otherwise
--!	@param	state	The state
local function isCompound(state)
	return state.type == "state" and state.states
end

--!	@return	boolean	true if the state is parallel, false otherwise
--!	@param	state	The state
local function isParallel(state)
	return state.type == "parallel" and state.states
end

--!	@return	array	An array containing the initial states for a compound state
--!	@param	state	A compound state		
--!	@note			should only be called for compound states
--!	@note			If a state has no explicit initial transition, the initial state will be the 
--!					first state in the states array
--!	@todo			Determine if this function will ever return an array with more than one element
function P:getInitialStates(state)
	local transition = state.initial
	
	if transition then
		local targets = transition.targets
	
		if targets then
			return targets
		end
	end
	
	return { state.states[1] }
end

--!	@return	array	the actions for a state's initial transition, or nil
--!	@param	state	The state
function P:getInitialActions(state)
	local transition = state.initial
	
	return transition and transition.actions
end

function P:getInitialLet(state)
	local transition = state.initial
	
	return transition and transition.let
end

--! check to see if set a intersects set b
--!	@param	a	a set
--!	@param	b	another set
--!	@return	boolean	true if a intersects b, false otherwise
--!	@note for optimal execution time, a should be the smallest set
--!	@warning	will not work if the values in the set are false!
local function intersects(a, b)
	for k in pairs(a) do
		if b[k] then
			return true
		end
	end
	
	return false
end

--! get the states that would be exited by a given transition
--!	@param	lca			The least common ancestor of the source and targets of the transition
--!	@param	data		The value to use as the value in the set
--!	@return	set		The set of states that would be exited, with data as the value
function P:getStatesToExit(lca, data)
	local statesToExit = {}

	local configuration = self.configuration
	
	for i = 1, #configuration do
		local state = configuration[i]
		if isProperDescendant(state, lca) then
			statesToExit[state] = data
		end
	end
	
	return statesToExit
end

--! select the transitions that should be processed as a result of an event
--!	@param	event	The event
--!	@return	array	An array of transitions with source entries, and the set of states to be exited
--! @note			The most deeply nested states will be searched for a matching transition first
function P:selectTransitions(event)

	-- configuration should already be sorted
	local configuration = self.configuration
	
	local transitionSet = {}
	local transitionList = {}
	local numTransitions = 0
	local statesToExit = {}
	
	for i = 1, #configuration do
		local state = configuration[i]

		-- for every atomic state that is not preempted
		if not state.states and not statesToExit[state] then

			local properAncestors = getProperAncestors(state, nil)
			local ancestors = { state, unpack(properAncestors) }
			
			-- iterate over all the state's ancestors
			for j = 1, #ancestors do
				local ancestor = ancestors[j]

				-- search the ancestor's transitions for a transition that matches our event
				local transitions = ancestor.transitions
				
				if transitions then
					local found = false
					
					for k = 1, #transitions do
						local transition = transitions[k]

						if transition.event == event and (not transition.cond or evaluate(ancestor.rEnv, transition.cond)) then
						   
							if not transitionSet[transition] then
							
								-- do variable substitution on the transition let using the source state
								local data = { evaluate(setmetatable({}, { __index = function(t, k) local wEnv = ancestor.wEnv return ornil(wEnv and wEnv[k], self.globalWEnv[k]) end }), transition.let) or {} }
								
								local targets = transition.targets
								
								local lca = ancestor and targets and getLeastCommonAncestor(ancestor, targets)
						   
								local transitionStatesToExit = lca and self:getStatesToExit(lca, data) or {}
						   
								if not intersects(transitionStatesToExit, statesToExit) then
								
									for k, v in pairs(transitionStatesToExit) do
										statesToExit[k] = v
									end
								
									numTransitions = numTransitions + 1
									-- generate a transition in the correct format

									transitionList[numTransitions] = { source = ancestor, targets = targets, lca = lca, actions = transition.actions, data = data }
									transitionSet[transition] = true
									
									found = true
									break
								end
							else
								found = true
								break
							end
						end
					end
					
					if found then
						break
					end
				end
			end
		end
	end
	
	return transitionList, statesToExit
end

--! fully resolve a state
--!	@param	callback		A function that takes a single argument (the resolved state)
--!	@param	unresolvedState	A state that may or may not be fully resolved
function P:resolveState(callback, state)
	if state.type == "external" then
	
		-- if the state is unresolved, use the loader to resolve it
		return self.loader(self.debug and self:debugContinuation(callback, "resolving state "..state.name) or callback, state)
	else
		return callback(state)
	end
end

--! add the ancestors of a state to the set of states to enter
--!	@note	This function is written in continuation passing style. Please don't freak out
--!	@param	continuation			The continuation to call for this function
--!	@param	statesToEnter			The set of states to enter
--!	@param	statesForDefaultEntry	The set of states that have been entered by default 
--!									(compound states that have been entered without one 
--!									of their children having been entered explicitly)
--!	@param	state					The state
--!	@param	root					The root of our search (so we know how deep to go)
--!	@param	data					An arbitrary non-nil value to be used as the value for the set
function P:addAncestorsToEnter(continuation, statesToEnter, statesForDefaultEntry, state, root, data)
	-- iterate in continuation passing style over the proper ancestors (up to the root) of the state
	return cps.serialApply(	self,
									continuation,
									function(interpreter, c, _, ancestor)
										-- add the ancestor to the set of states to enter
										statesToEnter[ancestor] = data
										
										if isParallel(ancestor) then
											-- if the ancestor is parallel, then iterate over all its children 
											-- in continuation passing style
											return cps.parallelApply(	interpreter,
																		c,
																		function(interpreter, cc, _, child)
																			local descendantFound = false
												
																			for stateToEnter in pairs(statesToEnter) do
																				if isDescendantExternal(stateToEnter, child) then
																					descendantFound = true
																				end
																			end
																			
																			if not descendantFound then
																				-- if the child is not descendant from one of the states we're
																				-- already entering, then we need to add it to our states to
																				-- enter
																				return interpreter:addStatesToEnter(cc, statesToEnter, statesForDefaultEntry, child, ancestor, data)
																			else
																				return cc()
																			end
																		 end,
																		 ipairs(ancestor.states)
																		)
										else
											-- otherwise, just call our continuation
											return c()
										end
									end,
									ipairs(getProperAncestors(state, root))
								)
end

--! add to the states to be entered all the states that are implied to be entered by
--! entering a particular state, including those specified in an "initial" entry
--!	@note	This function is written in continuation passing style. Please don't freak out
--!	@param	continuation			The continuation to call for this function
--!	@param	statesToEnter			The set of states to enter
--!	@param	statesForDefaultEntry	The set of states that have been entered by default 
--!									(compound states that have been entered without one 
--!									of their children having been entered explicitly)
--!	@param	unresolvedState			The state
--!	@param	root					The root of our search (so we know how deep to go)
--!	@param	data					An arbitrary non-nil value to be used as the value for the set
function P:addStatesToEnter(continuation, statesToEnter, statesForDefaultEntry, unresolvedState, root, data)
	-- resolve the state in continuation passing style
	return self:resolveState(
		function(state)
			-- create a continuation for adding all the ancestors of the state
			local addAncestorsContinuation = 
				function()
					return self:addAncestorsToEnter(continuation, statesToEnter, statesForDefaultEntry, state, root, data)
				end
		
			-- add the state to the set of states to enter
			statesToEnter[state] = data
			
			if isParallel(state) then
				-- if the state is parallel, then just recursively add all its children
				-- then add its ancestors
				return cps.parallelApply(	self,
											addAncestorsContinuation, 
											function(interpreter, c, _, child) 
												return interpreter:addStatesToEnter(c, statesToEnter, statesForDefaultEntry, child, state, data)
											end,
											ipairs(state.states)
										)
			elseif isCompound(state) then
				-- if the state is compound, add it to the set of states for default entry
				-- recursively add its initial states
				-- then add its ancestors
				
				-- we must fill this in later, after entering the state and evaluating initial transition's let
				local defaultData = { data[1] }
									
				statesForDefaultEntry[state] = defaultData
				
				return cps.parallelApply(	self,
											addAncestorsContinuation, 
											function(interpreter, c, _, initial) 
												return interpreter:addStatesToEnter(c, statesToEnter, statesForDefaultEntry, initial, state, defaultData)
											end,
											ipairs(self:getInitialStates(state))
										)
			else
				-- the state is atomic, so just add its ancestors
				return addAncestorsContinuation()
			end
		end,
		unresolvedState
		)
end

--!	function designed to be called by cps.serialApply() for executing actions on a table
--!	@param interpreter		The interpreter
--!	@param c				The continuation to call for this function
--!	@param _				The key (ignored)
--!	@param action			The action to execute
local function applyExecuteAction(interpreter, c, _, action)
	-- execute the action
	return interpreter:executeAction(c, action)
end

--! function that serially executes a series of actions in continuation passing style
--!	@param	interpreter		The interpreter
--!	@param	continuation	The continuation to call for this function
--!	@param	actions			An array of actions to execute
local function serial(interpreter, continuation, actions)
	-- iterate over the array of actions in continuation passing style
	return cps.serialApply(
		interpreter,
		continuation, 
		applyExecuteAction,
		ipairs(actions)
		)
end

--! function that implements the "if" control structure for actions
--! @param	c	The continuation to call for this function
--!	@param	p	The parameter list
--!	@note p[1] will be evaluated and its truth value will select either p[2] or p[3] to be executed
function P:ifAction(c, p) return serial(self, c, evaluate(self.actionEnv, p[1]) and p[2] or p[3]) end

--[[
--! action that executes a series of actions in parallel in continuation passing style
--! @param	interpreter		The interpreter
--! @param	continuation	The continuation to call for this function
--!	@param	_				An unused parameter (will be the string, "parallel")
--!	@param	actions			An array of actions to execute
local function parallel(interpreter, continuation, _, actions)
	if actions then
		-- execute all the actions in parallel in continuation passing style
		cps.parallelContinuationApply(
			interpreter,
			continuation, 
			applyExecuteAction, 
			ipairs(actions))
	else
		continuation()
	end
end
--]]

--! helper function to be applied over a list of actions
--!	@param	interpreter	The interpreter
--!	@param	c			The continuation for this function
--!	@param	_			The index (unused, but needed so that function can be applied)
--!	@param	actions		A table containing the state for the actions and the actions themselves
local function doActions(interpreter, c, _, actions)
	local aa = actions.actions

	if aa and #aa > 0 then
	
		c = interpreter.debug and interpreter:debugContinuation(c, "transition actions") or c

		interpreter:setActionEnv(actions.state, actions.data[1])
		return serial(
					interpreter, 
					function()
						interpreter:clearActionEnv()
						return c()
					end,
					aa
				)
	else
		return c()
	end
end

--! process a set of transitions
--!	@note	This function is written in continuation passing style. Please don't freak out
--!	@param	continuation	The continuation to call for this function
--!	@param	transitions		An array of transitions (with source entries) to process
--!	@param	statesToExit	The set of states to exit
function P:microstep(continuation, transitions, statesToExit)
	local statesToEnter = {}
	local statesForDefaultEntry = {} -- so we know if we need to execute actions for default transitions
	local actionsToDo = {}
	
	-- iterate over the array of transitions in continuation passing style to
	-- create the states to exit, enter, and actions to do
	return cps.serialApply(	self,
									function()
										local sortedStatesToExit = sortStatesSetReversed(statesToExit)
										local sortedStatesToEnter = sortStatesSet(statesToEnter)
										
										-- currently all states are exited serially - we could make this parallel, but between orthogonal regions only
										-- the actions of all transitions are performed in parallel, although the actions of each transition are serial
										-- currently all states are entered serially - we could make this parallel, but between orthogonal regions only
										
										-- in continuation passing style, exit the sorted states to exit,
										-- then do all the actions (in parallel)
										-- then enter all the states to enter
										
										return self:exitStates(
														function()
															return cps.serialApply(
																self,
																function()
																	return self:enterStates(
																						continuation,
																						sortedStatesToEnter, 
																						statesForDefaultEntry
																					)
																end, 
																doActions,
																ipairs(actionsToDo)
															)
														end,
														sortedStatesToExit
														)
									end,
									function(interpreter, c, index, transition)
										-- for each transition
									
										local source = transition.source
										local targets = transition.targets
										local lca = transition.lca or source
										local actions = transition.actions
										local data = transition.data
										
										-- add the actions for this transition to the actions to do
										actionsToDo[index] = { actions = actions, state = lca, data = data }
										
										if targets then
										
											-- if there are targets, iterate over them and add them to the states to enter
											return cps.serialApply(	interpreter,
																			c,
																			function(interpreter, cc, _, target)
																				return interpreter:addStatesToEnter(cc, statesToEnter, statesForDefaultEntry, target, lca, data)
																			end,
																			ipairs(targets)
																		)
										else
											-- otherwise, just call the continuation
											return c()
										end
									end,
									ipairs(transitions)
								)
end

--! execute a particular action
--!	@param	continuation	The continuation to call for this function
--!	@param	action			The action to perform
function P:executeAction(continuation, action)
	local name = action[1]
	local parameters = action[2]
	
	local env = self.actionEnv
	
	-- if the name is a string, then evaluate it as a variable
	-- otherwise, evaluate it as an expression
	local action = type(name) == "string" and env[name] or evaluate(env, name)
	
	if type(action) == "function" then
		-- if this action exists, execute it
		return action(
				self,
				self.debug and self:debugContinuation(continuation, "action "..tableutil.tostring(name)..", parameters "..tableutil.tostring(parameters)) or continuation,
				parameters
				)
	elseif self.actionNotFound then
		local rp = parameters and evaluateArray(env, parameters) or {}
		
		return self.actionNotFound(continuation, tableutil.tostring(name), unpack(rp))
	else
		assert(false, "No action "..tableutil.tostring(name).." registered")
		return continuation()
	end
end

--!	Setup the action execution environment
--!	@param	state	The state whose environment should be used for action execution, or nil
--!	@param	data	Custom data associated with action execution
function P:setActionEnv(state, data)
	self.actionState = state
	self.actionData = data
end

--!	Clear the action execution environment
function P:clearActionEnv()
	self.actionState = nil
	self.actionData = nil
end

--! exit states serially in continuation passing style
--!	@param	continuation		The continuation to call for this function
--!	@param	sortedStatesToExit	An array of states to exit
function P:exitStates(continuation, sortedStatesToExit)
	return cps.serialApply(
		self,
		continuation,
		function(interpreter, c, key, value)
			return interpreter:exitState(c, value)
		end,
		ipairs(sortedStatesToExit)
		)
end

--! exit a state in continuation passing style
--!	@param	continuation	The continuation to call for this function
--! @param	state			The state to exit	
function P:exitState(continuation, value)
	local state = value[1]
	local data = value[2]
	
	local name = getQualifiedName and getQualifiedName(state)
	
	continuation = self.debug and self:debugContinuation(continuation, "exiting state "..name) or continuation

	local c = 
		function()
			self:clearActionEnv()
			
			state.wEnv = nil
			state.rEnv = nil
			
			local configuration = self.configuration

			for i = 1, #configuration do
				if configuration[i] == state then
					table.remove(self.configuration, i)
					break
				end
			end
			
			self:dispatch("stateExited", name, getQualifiedId(state), os.difftime(os.time(), state.time))
            state.time = nil
			
			return continuation()
		end
	
	self:setActionEnv(state, data[1])
	
	if state.onExit then
		return serial(
			self, 
			self.debug and self:debugContinuation(c, "onExit actions") or c,
			state.onExit
			)
	else
		return c()
	end
end

--! enter states serially in continuation passing style
--!	@param	continuation			The continuation to call for this function
--!	@param	sortedStatesToEnter		An array of states to enter
--!	@param	statesForDefaultEntry	The set of states for default entry
function P:enterStates(continuation, sortedStatesToEnter, statesForDefaultEntry)
	local apply = 
		function(interpreter, c, key, value)
			return interpreter:enterState(c, value, statesForDefaultEntry[value[1]])
		end

	return cps.serialApply(
		self,
		continuation,
		apply,
		ipairs(sortedStatesToEnter)
		)
end

--! enter a state in continuation passing style
--!	@param	continuation	The continuation to call for this function
--!	@param	state			The state to enter
--!	@param	defaultEntry	Whether or not to perform the initial actions for this state
function P:enterState(continuation, value, defaultEntry)
	local state = value[1]
	local data = value[2]

	tableutil.binsert(self.configuration, state, stateSorter)
	
	local name = getQualifiedName and getQualifiedName(state)
	
	continuation = self.debug and self:debugContinuation(continuation, "entering state "..name) or continuation
	
	local parent = state.parent
	local parentREnv = parent and parent.rEnv or self.let
	local let = state.let
	
	local rEnvM = { __index = parentREnv }
	local rEnv = parentREnv and setmetatable(let and evaluate(setmetatable({}, rEnvM), let) or {}, rEnvM)
	state.rEnv = rEnv
	
	local parentWEnv = parent and parent.wEnv or {}
	
	-- make the environment for a state inherit the environment of its parent or the global environment if it is the root state
	state.wEnv = setmetatable({ _name = name, _path = state.path }, { __index = function(t, k) return ornil(rEnv[k], parentWEnv[k]) end })
			
	local cc = 
		function()
			self:clearActionEnv()
			
			state.time = os.time()
			self:dispatch("stateEntered", name, getQualifiedId(state))
					
			return continuation()
		end
		
	local c = cc
	
	if defaultEntry then
		local initialActions = self:getInitialActions(state)
		local initialLet = self:getInitialLet(state)
		
		if initialActions then
			c = function()
			
					-- do variable substitution if necessary
					defaultEntry[1] = initialLet and setmetatable(evaluate(self.actionEnv, initialLet), { __index = data[1] }) or defaultEntry[1]
				
					self:setActionEnv(state, defaultEntry[1])
					
					return serial(
						self,
						self.debug and self:debugContinuation(cc, "initial actions") or cc,
						initialActions
						)
				end
		-- no initial actions, but still initial let properties needing substitution
		elseif initialLet then
			c = function()
					defaultEntry[1] = setmetatable(evaluate(self.actionEnv, initialLet), { __index = data[1] })
					cc()
				end
		end
	end
	
	self:setActionEnv(state, data[1])
	
	if state.onEnter then
		return serial(self, 
				 self.debug and self:debugContinuation(c, "onEnter actions") or c,
				 state.onEnter)
	else
		return c()
	end
end

return P
