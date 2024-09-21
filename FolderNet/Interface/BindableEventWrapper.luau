---@diagnostic disable: redefined-type
--!strict

--[[Types]]
type Connection = BindableEventConnection

type ConnectionConstructor = {
	Instance: Instance,
	Destroy: (self: any) -> (),
	[any]: any
}

export type BindableEventConnection = ConnectionConstructor & {
	Fire: (self: any, ...any) -> (),
	Connect: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	Once: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	Wait: (self: any) -> ...any
}

type NetworkDirectory = {[string]: Connection}

export type Network = {
	Connect: (self: any, folderName: string) -> Connection,
	Disconnect: (self: any, folderName: string) -> (),
	[any]: any
}

--[[Service]]
local GetBindableEvent = require(script.Parent.Parent.Modules.Bindables.GetBindableEvent)

--[[Variables]]
local Connection = {}
local Network = {_self = {}} ::Network

--[[Network]]
local function getNetworkDirectory(): NetworkDirectory
	local networkDirectory: NetworkDirectory = nil
	networkDirectory = Network._self
	return networkDirectory
end


--[[Main Entry]]
local BindableEventWrapper = {}

function BindableEventWrapper:Connect(folderName: string) :Connection
	assert(type(folderName) == "string", "Bad name")
	
	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName]

	if connection == nil then
		local bindableInstance: Instance = GetBindableEvent(folderName)

		connection = Connection.new(bindableInstance)
		connection._destroyedBindableEvent.Event:Once(function()
			print(`Network connection to {"BindableEvent"} '{folderName}' has been disconnected`)
			networkDirectory[folderName] = nil
		end)

		networkDirectory[folderName] = connection
	end

	return connection
end

function BindableEventWrapper:Disconnect(folderName: string)
	assert(type(folderName) == "string", "Bad name")

	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName]

	if connection ~= nil then
		connection:Destroy()
	else
		warn(`Network connection to {"BindableEvent"} '{folderName}' does not exist`)
	end
end

--[[Connections]]
function Connection.new(instance: Instance): Connection
	assert(typeof(instance) == "Instance", `Connection.new(): invalid argument 'instance' (Instance expected, got {typeof(instance)})`)
	assert(instance.ClassName == "BindableEvent", `Connection.new(): invalid instance type '{instance.ClassName}'`)

	local connection: Connection = {
		Instance = instance,
		_destroyedBindableEvent = Instance.new("BindableEvent")
	} :: Connection

	if instance.ClassName == "BindableEvent" then
		(connection :: BindableEventConnection).Fire = function(_: BindableEventConnection, ...): ()
			(instance :: BindableEvent):Fire(...)
		end

		(connection :: BindableEventConnection).Connect = function(_: BindableEventConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
			return (instance :: BindableEvent).Event:Connect(callbackFunction)
		end

		(connection :: BindableEventConnection).ConnectParallel = function(_: BindableEventConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
			return (instance :: BindableEvent).Event:ConnectParallel(callbackFunction)
		end

		(connection :: BindableEventConnection).Once = function(_: BindableEventConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
			return (instance :: BindableEvent).Event:Once(callbackFunction)
		end

		(connection :: BindableEventConnection).Wait = function(_: BindableEventConnection): ...any
			return (instance :: BindableEvent).Event:Wait()
		end
	end

	function connection:Destroy()
		instance:Destroy()
	end

	connection.Instance.Destroying:Once(function()
		connection._destroyedBindableEvent:Fire()
		connection._destroyedBindableEvent:Destroy()
	end)

	table.freeze(connection)
	return connection
end

--[[Access everything.]]
return function (folderName: string)
	return BindableEventWrapper:Connect(folderName)
end