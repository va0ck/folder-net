---@diagnostic disable: redefined-type
--!strict

--[[Types]]
type Connection = BindableFunctionConnection

type ConnectionConstructor = {
	Instance: Instance,
	Destroy: (self: any) -> (),
	[any]: any
}

export type BindableFunctionConnection = ConnectionConstructor & {
	Invoke: (self: any, ...any) -> ...any,
	Connect: (self: any, callbackFunction: ((...any) -> ...any)?) -> ()
}

type NetworkDirectory = {[string]: Connection}

export type Network = {
	Connect: (self: any, folderName: string) -> Connection,
	Disconnect: (self: any, folderName: string) -> (),
	[any]: any
}

--[[Service]]
local GetBindableFunction = require(script.Parent.Parent.Modules.Bindables.GetBindableFunction)

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
local BindableFunctionWrapper = {}

function BindableFunctionWrapper:Connect(folderName: string) :Connection
	assert(type(folderName) == "string", "Bad name")
	
	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName]

	if connection == nil then
		local bindableInstance: Instance = GetBindableFunction(folderName)

		connection = Connection.new(bindableInstance)
		connection._destroyedBindableEvent.Event:Once(function()
			print(`Network connection to {"BindableFunction"} '{folderName}' has been disconnected`)
			networkDirectory[folderName] = nil
		end)

		networkDirectory[folderName] = connection
	end

	return connection
end

function BindableFunctionWrapper:Disconnect(folderName: string)
	assert(type(folderName) == "string", "Bad name")

	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName]

	if connection ~= nil then
		connection:Destroy()
	else
		warn(`Network connection to {"BindableFunction"} '{folderName}' does not exist`)
	end
end

--[[Connections]]
function Connection.new(instance: Instance): Connection
	assert(typeof(instance) == "Instance", `Connection.new(): invalid argument 'instance' (Instance expected, got {typeof(instance)})`)
	assert(instance.ClassName == "BindableFunction", `Connection.new(): invalid instance type '{instance.ClassName}'`)

	local connection: Connection = {
		Instance = instance,
		_destroyedBindableEvent = Instance.new("BindableEvent")
	} :: Connection

	if instance.ClassName == "BindableFunction" then
		(connection :: BindableFunctionConnection).Invoke = function(_: BindableFunctionConnection, ...): ...any
			return (instance :: BindableFunction):Invoke(...)
		end

		(connection :: BindableFunctionConnection).Connect = function(_: BindableFunctionConnection, callbackFunction: ((...any) -> ...any)?): ()
			(instance :: BindableFunction).OnInvoke = callbackFunction :: (...any) -> ...any
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
	return BindableFunctionWrapper:Connect(folderName)
end