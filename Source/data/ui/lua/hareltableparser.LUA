--! @file hareltableparser.lua
--! This library processes a harel statechart in a table format based on SCXML, and converts it into a more convenient form
--! for use by the harel library. It also does verification that the state chart is well formed and is logically sound
--!	@author Chris Burns (cburns@ea.com)
--!
--!	UX
--!	(c) 2011 Electronic Arts Inc.

-- we need to depend on the harel libary so we can use its least common ancestor calculations
local
	harel
= ...

local P =
{
	-- this is the set of valid state types
	types =
	{
		state = true,
		parallel = true,
		external = true
	},
	-- this is the default state type for a state that doesn't specify a type
	defaultType = "state",

	transitionKeys = {event=true, cond=true, targets=true, actions=true, let=true},
	initialTransitionKeys = {targets=true, actions=true, let=true},
	externalStateKeys = {name=true, type=true, file=true, inputs=true, outputs=true},
	stateKeys = {name=true, type=true, initial=true, onEnter=true, onExit=true, transitions=true, states=true, let=true}
}

--! Create a new state chart table parser
--!	@return	table	A state chart table parser
function P:new()
	local o =
	{
		numAnonymous = 0,
		fileLevel = 0,
		fileOrder = 0,
		contexts = {},
		builtStates = {},
	}

	setmetatable(o, self)
	self.__index = self

	return o
end

function P:error(message)
	self.errors = self.errors or ""
	self.errors = self.errors..message.."\n"
end

--! this method parses an object and verifies that all it's keys are valid.
--!	@param	context		A parsing context
--!	@param	name		The name that describes the object properties we are validating is case we need to display an error message
--!	@param	object		The object to check
--!	@param	validKeys	A table of valid key values
--!	@return	boolean		true if the object only contains validKeys, false otherwise
function P:verify(context, name, object, keys)
	for k in pairs(object) do
		if not keys[k] then
			self:error(context.."."..k.. " is not a valid "..name.." key")
			return false
		end
	end

	return true
end

--! this method parses and verifies that an action table is well-formed.
--!	@attention	an action must be a table with the following keys:
--!				[1] a string naming the action
--!				[2] a table representing the argument list
--!	@param	context	A parsing context
--!	@param	action	An action
--!	@return	boolean	true if the action is well-formed, false otherwise
function P:parseAction(context, action)
	local name = action[1]
	local arguments = action[2]

	if type(name) ~= "string" then
		self:error(context..".[1] must be a string")
		return false
	end

	if arguments ~= nil and type(arguments) ~= "table" then
		self:error(context..".[2] must be a table")
		return false
	end

	return true
end

--! this method parses and verifies that an array of actions is well-formed.
--!	@param	context	A parsing context
--!	@param	actions	An array of actions
--!	@return	boolean	true if the action array is well-formed, false otherwise
function P:parseActionArray(context, actions)
	if type(actions) ~= "table" then
		self:error(context.." must be a table")
		return false
	end

	for i = 1, #actions do
		if not self:parseAction(context.."["..i.."]", actions[i]) then
			return false
		end
	end

	return true
end

--!	this method parses and verifies that an array of targets is well-formed.
--!	@attention	a target array should be an array of strings
--!	@param	context	A parsing context
--!	@param	targets	An array of targets
--!	@return	boolean	true if the array of targets is well-formed, false otherwise
function P:parseTargetArray(context, targets)
	if type(targets) ~= "table" then
		self:error(context.." must be a table")
		return false
	end

	for i = 1, #targets do
		if type(targets[i]) ~= "string" then
			self:error(context.."["..i.."] must be a string")
			return false
		end
	end

	return true
end

--!	this method parses a transition and verifies that it is well-formed.
--!	@attention	a transition must be a table with the following keys:
--!				["event"] a string representing the event
--!				["cond"] an optional boolean expression that guards the transition
--!				["targets"] an array of targets, or nil
--!				["actions"] an array of actions, or nil
--!				["let"] a table of variable assignments, or nil
--!	@param	context		A parsing context
--!	@param	transition	A transition
--!	@return	boolean		true if the transition is well-formed, false otherwise
function P:parseTransition(context, transition)
	if not self:verify(context, "transition", transition, self.transitionKeys) then
		return false
	end

	local event = transition.event
	if event and type(event) ~= "string" then
		self:error(context..".event must be a string")
		return false
	end
	
	local targets = transition.targets
	if targets ~= nil then
		if not self:parseTargetArray(context..".targets", targets) then
			return false
		end
	end
	
	local actions = transition.actions
	if actions ~= nil then
		if not self:parseActionArray(context..".actions", actions) then
			return false
		end
	end
	
	local let = transition.let
	if let ~= nil and type(let) ~= "table" then
		self:error(context..".let must be a table")
		return false
	end

	return true
end

--! this method parses a transition array and verifies that it is well-formed.
--!	@param	context		A parsing context
--!	@param	transitions	An array of transitions
--!	@return	boolean		true if the transition array is well-formed, false otherwise
function P:parseTransitionArray(context, transitions)
	if type(transitions) ~= "table" then
		self:error(context.." must be a table")
		return false
	end

	for i = 1, #transitions do
		if not self:parseTransition(context.."["..i.."]", transitions[i]) then
			return false
		end
	end

	return true
end

--! this method parses a state array and verifies that it is well-formed.
--!	@param	context	A parsing context
--!	@param	states	An array of states
--!	@return	boolean	true if the array of states is well-formed, false otherwise
function P:parseStateArray(context, states)
	if type(states) ~= "table" then
		self:error(context.." must be a table")
		return false
	end

	for i = 1, #states do
		if not self:parseState(context.."["..i.."]", states[i]) then
			return false
		end
	end

	return true
end

--!	this method parses an initial transition and verifies that it is well-formed.
--!	@attention	an initial transition must be a table with the following keys:
--!				["targets"] an array of targets
--!				["actions"] an array of actions, or nil
--!				["let"] a table of variable assignments, or nil
--!	@param	context	A parsing context
--!	@param	initial	An initial transition
--!	@return	boolean	true if the initial transition is well-formed, false otherwise
function P:parseInitialTransition(context, initial)
	if not self:verify(context, "initial state", initial, self.initialTransitionKeys) then
		return false
	end

	local targets = initial.targets
	if targets == nil then
		self:error(context..".targets must not be nil")
		return false
	else
		if not self:parseTargetArray(context..".targets", targets) then
			return false
		end
	end

	local actions = initial.actions
	if actions ~= nil then
		if not self:parseActionArray(context..".actions", actions) then
			return false
		end
	end
	
	local let = initial.let
	if let ~= nil and type(let) ~= "table" then
		self:error(context..".let must be a table")
		return false
	end

	return true
end

--! this method parses an external state map and verifies that it is well-formed.
--! @attention	an external state map must be a table with string keys and string values
function P:parseExternalStateMap(context, map)
	if type(map) ~= "table" then
		self:error(context.." must be a table")
		return false
	end

	for key, value in pairs(map) do
		if type(key) ~= "string" then
			self:error("key "..tostring(key).." in table "..context.." must be a string")
			return false
		end

		if type(value) ~= "string" then
			self:error(context.."."..key.." must be a string")
			return false
		end
	end

	return true
end

--!	parse a map of inputs
--!	@param	context	The current context
--!	@param	inputs	The map of inputs
--!	@return boolean	true, no matter what
--!	@note	needed so that the parser recognizes the inputs as states
function P:parseInputs(context, inputs)
	for state in pairs(inputs) do
		self.contexts[state] = context.."."..state
	end

	return true
end

--!	this method parses an external state and verifies that it is well-formed.
--!	@attention	an external state must be a table with the following keys:
--!				["name"] a string naming the state (verified by parseState())
--!				["type"] the string "external" (verified by parseState())
--!				["outputs"] a mapping of output states, or nil
--!				["inputs"] a mapping of input states, or nil
--!				["file"] a string containing an identifier to be passed when requesting this state be loaded
--!	@param	context	A parsing context
--!	@param	state	An external state
--!	@return	boolean	true if the external state is well formed, false otherwise
function P:parseExternalState(context, state)
	if not self:verify(context, "external state", state, self.externalStateKeys) then
		return false
	end

	local outputs = state.outputs

	if outputs ~= nil then
		if not self:parseExternalStateMap(context..".outputs", outputs) then
			return false
		end
	end

	local inputs = state.inputs

	if inputs ~= nil then
		local inputsContext = context..".inputs"

		if not (self:parseExternalStateMap(inputsContext, inputs) and self:parseInputs(inputsContext, inputs)) then
			return false
		end
	end

	local file = state.file

	if file == nil then
		self:error(context..".file must not be nil")
		return false
	end

	return true
end

--!	this method parses a state and verifies that it is well-formed.
--!	@attention	an state must be a table with the following keys:
--!				["name"] a string naming the state
--!				["type"] a string indicating the type, or nil
--!				["initial"] an initial transition, or nil
--!				["onEnter"] an array of actions to execute upon entering this state, or nil
--!				["onExit"] an array of actions to execute upon leaving this state, or nil
--!				["transitions"] an array of transitions that can be taken while in this state, or nil
--!				["states"] an array of states, or nil
--!	@param	context	A parsing context
--!	@param	state	A state
--!	@return	boolean	true if the state is well-formed, false otherwise
function P:parseState(context, state)
	local name = state.name

	if name then
		if type(name) ~= "string" then
			self:error(context..".name must be a string")
			return false
		end
	else
		self.numAnonymous = self.numAnonymous + 1
		name = "__anonymous"..self.numAnonymous
		state.name = name
	end

	local stateContext = context.."."..tostring(name)

	local duplicateContext = self.contexts[name]

	if duplicateContext ~= nil then
		self:error(stateContext.." has the same name as "..duplicateContext)
		return false
	end

	self.contexts[name] = stateContext

	-- use t so we don't shadow the type function
	local t = state.type
	if t ~= nil then
		if self.types[t] == nil then
			local error = stateContext..".".."type must be nil or one of"
			for k, v in pairs(self.types) do
				error = error.." "..k
			end
			self:error(error)
			return false
		end
	else
		t = self.defaultType
	end

	if t == "external" then
		return self:parseExternalState(context, state)
	else
		if not self:verify(context, "state", state, self.stateKeys) then
			return false
		end

		local initial = state.initial

		if initial ~= nil then
			if t ~= "state" then
				self:error(stateContext..".".."initial must be nil if "..stateContext.." is of type "..t)
				return false
			end

			if not self:parseInitialTransition(stateContext..".initial", initial) then
				return false
			end
		end

		local onEnter = state.onEnter
		if onEnter ~= nil then

			if not self:parseActionArray(stateContext..".onEnter", onEnter) then
				return false
			end
		end

		local onExit = state.onExit
		if onExit ~= nil then

			if not self:parseActionArray(stateContext..".onExit", onExit) then
				return false
			end
		end

		local transitions = state.transitions
		if transitions ~= nil then

			if not self:parseTransitionArray(stateContext..".transitions", transitions) then
				return false
			end
		end

		local states = state.states
		if states ~= nil then

			if not self:parseStateArray(stateContext..".states", states) then
				return false
			end
		end
		
		local let = state.let
		if let ~= nil and type(let) ~= "table" then
			self:error(context..".let must be an table")
			return false
		end

		return true
	end
end

--! this method creates an array of built states given an array of unbuilt states and a built parent state
--!	@param	builtParent	The built state that is the built parent of this state array
--!	@param	states		An array of states
--!	@param	array		An array of built states
function P:buildStateArray(builtParent, states)
	local numStates = #states

	if numStates > 0 then
		local builtStates = {}

		for i = 1, numStates do
			builtStates[i] = self:buildState(builtParent, states[i])
		end

		return builtStates
	end
end

--! this method builds a transition
--!	@param	transition	A transition
--!	@return	table		A built transition
function P:buildTransition(transition)
	return
		{
			event = transition.event,
			cond = transition.cond,
			targets = transition.targets, -- we will fix this up
			actions = transition.actions,
			let = transition.let
		}
end

--! this method builds an array of transitions
--!	@param	transitions	An array of transitions
--!	@param	array		An array of built transitions
function P:buildTransitionArray(transitions)
	local numTransitions = #transitions

	if numTransitions > 0 then
		local builtTransitions = {}

		for i = 1, numTransitions do
			builtTransitions[i] = self:buildTransition(transitions[i])
		end

		return builtTransitions
	end
end

--!	this method builds a state
--!	@attention	a built state is different from a regular state in that:
--!				it has a ["parent"] value which is a reference to its parent, or nil'
--!				it always has a valid ["type"] value
--!				it has a ["fileParent"] value, or nil
--!				it has a ["fileLevel"] value
--!				it has a ["fileOrder"] value
--!				all of its children are built states
--!	@param	builtParent	The built parent of this state
--!	@param	state		A state
--!	@return	table		A built state
function P:buildState(builtParent, state)
	-- increment file order
	self.fileOrder = self.fileOrder + 1

	local name = state.name
	local stateType = state.type

	if stateType == nil then
		stateType = self.defaultType
	end

	local builtState = nil

	if stateType == "external" then

		builtState =
		{
			parent = builtParent,
			name = name,
			type = "external",

			-- set up ordering information so we can sort states consistently
			fileParent = self.fileParent,
			fileLevel = self.fileLevel,
			fileOrder = self.fileOrder,
			inputs = state.inputs, -- keep this around for introspection purposes
			outputs = state.outputs, -- we will fix this up
			file = isabsolutepath(state.file) and appendpathraw(self.root, state.file) or appendpath(self.path, state.file),
			external = true -- insert true temporarily so there is no rehash
		}

		builtState.external = builtState

		if state.inputs ~= nil then
			for inputName, inputTarget in pairs(state.inputs) do
				local inputState =
				{
					name = inputName,
					type = "external",
					target = inputTarget,
					external = builtState,
					parent = builtState, -- needed so that we can figure out if transitions are valid
				}

				if self.builtStates[inputName] then
					self:error("a state named "..inputName.." has already been built - perhaps an existing state was provided in the inputs map?")
					return nil
				end

				self.builtStates[inputName] = inputState
			end
		end
	else
		local initial = state.initial
		if initial ~= nil then
			initial = self:buildTransition(initial)
		end

		local transitions = state.transitions
		if transitions ~= nil then
			transitions = self:buildTransitionArray(transitions)
		end

		local states = state.states

		builtState =
		{
			parent = builtParent,
			name = not EA_FINAL and name,
			type = stateType,

			-- set up ordering information so we can sort states consistently
			fileParent = self.fileParent,
			fileLevel = self.fileLevel,
			fileOrder = self.fileOrder,

			initial = initial,
			onEnter = state.onEnter,
			onExit = state.onExit,
			states = state.states, -- insert this temporarily so there is no rehash
			transitions = transitions,
			let = state.let
		}

		if states ~= nil then
			builtState.states = self:buildStateArray(builtState, states)
		end
	end

	if self.builtStates[name] then
		self:error("a state named "..name.." has already been built - perhaps an existing state was provided in the map of outputs?")
		return nil
	end

	self.builtStates[name] = builtState

	return builtState
end

--! this method builds a target looking up the built state for the name
--!	@param	target	A target
--!	@return	table	A built target
function P:buildTarget(target)

	local state = self.builtStates[target]

	if state then
		return state
	else
		self:error("reference to nonexistent state "..target)
		return nil
	end
end

--! this method builds an array of targets
--!	@param	targets	An array of targets
--!	@return	array	An array of built targets
function P:buildTargetArray(targets)
	local numTargets = #targets

	if numTargets > 0 then
		local builtTargets = {}

		for i = 1, numTargets do
			builtTargets[i] = self:buildTarget(targets[i])
		end

		return builtTargets
	end
end

--! this method generates an assert for and invalid initial transition
--!	@param	source	A source state
--!	@param	targets	An array of built targets
function P:invalidInitialTransition(source, targets)
	local message = "initial transition targets "

	for i = 1, #targets do
		message = message..self.contexts[targets[i].name].." "
	end

	message = message.."are not direct descendants of "..self.contexts[source.name]
	self:error(message)
end

--!	this method fixes up an initial transition by building its target array.
--!	@note	it also verifies that the transition is valid
--!	@param	source		A source state
--!	@param	transition	A transition
function P:fixupInitialTransition(source, transition)
	transition.targets = self:buildTargetArray(transition.targets)

	local children = source.states

	if children == nil then
		self:invalidInitialTransition(source, transition.targets)
		return
	end
	--[[
	local invalidTargets = {}
	local numInvalidTargets = 0

	local targets = transition.targets

	for i = 1, #targets do
		local target = targets[i]

		local found = false
		for j = 1, #children do
			if children[j] == target then
				found = true
				break
			end
		end

		if not found then
			numInvalidTargets = numInvalidTargets + 1
			invalidTargets[numInvalidTargets] = target
		end
	end

	if numInvalidTargets > 0 then
		self:invalidInitialTransition(source, invalidTargets)
	end
	--]]
end

--!	this method fixes up an transition by building its target array.
--!	@note	it also verifies that the transition is valid
--!	@param	source		A source state
--!	@param	transition	A transition
function P:fixupTransition(source, transition)

	if transition.targets ~= nil then
		transition.targets = self:buildTargetArray(transition.targets)
	end

	if transition.targets ~= nil then
		local leastCommonAncestor = harel.getLeastCommonAncestor(source, transition.targets)

		if leastCommonAncestor == nil then
			local message = "transition between source "..self.contexts[source.name].." and targets "

			local targets = transition.targets

			for i = 1, #targets do
				message = message..self.contexts[targets[i].name].." "
			end

			message = message.."has no least common ancestor"
			self:error(message)
			return
		end

		if leastCommonAncestor.type == "parallel" then
			local message = "transition between source "..self.contexts[source.name].." and targets "

			local targets = transition.targets
			for i = 1, #targets do
				message = message..self.contexts[targets[i].name].." "
			end

			local description = self.contexts[leastCommonAncestor.name] or leastCommonAncestor.name
			message = message.."is between parallel regions in "..description..". "..
				"This implies that the transition cause one of the parallel substates to exit, which is not allowed. "..
				"A potential solution is to create a state above the transtion to prevent leaving the parallel substate."

			self:error(message)
		end
	end
end

--! this method fixes up a transition array
--!	@param	source		A source state
--!	@param	transitions	An array of transitions
function P:fixupTransitionArray(source, transitions)
	for i = 1, #transitions do
		self:fixupTransition(source, transitions[i])
	end
end

--! this method fixes up a state array
--!	@param	states	An array of states
function P:fixupStateArray(states)
	for i = 1, #states do
		self:fixupState(states[i])
	end
end

--!	this method builds and external state map
--!	@param	map		An external state map
--!	@return	table	A built external state map
function P:buildExternalStateMap(map)
	local builtMap = {}

	for key, value in pairs(map) do
		builtMap[key] = self:buildTarget(value)
	end

	return builtMap
end

--! this method fixes up an external state
--!	@param	state	An external state
function P:fixupExternalState(state)
	if state.outputs ~= nil then
		state.outputs = self:buildExternalStateMap(state.outputs)
	end
end

--! this method fixes up a state
--!	@param	state	A state
function P:fixupState(state)
	if state.type == "external" then
		self:fixupExternalState(state)
	else
		local initial = state.initial
		if initial ~= nil then
			self:fixupInitialTransition(state, initial)
		end

		local states = state.states
		if states ~= nil then
			self:fixupStateArray(states)
		end

		local transitions = state.transitions
		if transitions ~= nil then
			self:fixupTransitionArray(state, transitions)
		end
	end
end

--! this method parses as state chart, builds it and then fixes it up
--!	@param	parent		A parent state, or nil
--!	@param	stateTable	A state table (unparsed)
--!	@return	table		The root of the parsed state table (and a set of the built states)
function P:parseStateTable(parent, stateTable)
	if stateTable ~= nil then
		if self:parseState("", stateTable) then

			if parent ~= nil then
				self.fileLevel = parent.fileLevel + 1
			end

			local root = self:buildState(parent, stateTable)

			self:fixupState(root)

			if not self.errors then
				root.path = self.path
			
				return root, self.builtStates
			else
				return nil, nil, self.errors
			end
		else
			return nil, nil, self.errors
		end
	else
		self:error("cannot parse a nil state table")
		return nil, nil, self.errors
	end
end

--! this method parses as state chart, builds it and then fixes it up
--! @param	root		The root directory of all the .nav files
--!	@param	fileName	A filename (also used as the parsing context)
--!	@param	parent		A parent state, or nil
--!	@param	fileParent	A file parent state, or nil
--!	@param	stateTable	A state table (unparsed)
--!	@return	table		The root of the parsed state table (and a set of the built states)
function P.parse(root, fileName, parent, fileParent, stateTable)
	local parser = P:new()

	-- initialize builtStates with anything provided in the outputs
	if fileParent and fileParent.outputs then
		for outputName, outputState in pairs(fileParent.outputs) do
			parser.builtStates[outputName] = outputState
		end
	end

	parser.root = root
	parser.fileParent = fileParent
	parser.path = getpath(fileName)

	return parser:parseStateTable(parent, stateTable)
end

return P
