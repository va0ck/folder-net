---@diagnostic disable: redefined-type
--!strict

--[[Types]]
type Connection = RemoteFunctionServerConnection | RemoteFunctionClientConnection

type ConnectionConstructor = {
	Instance: Instance,
	Destroy: (self: any) -> (),
	[any]: any
}

export type RemoteFunctionServerConnection = ConnectionConstructor & {
	Invoke: (self: any, player: Player, ...any) -> ...any,
	Connect: (self: any, callbackFunction: ((player: Player, ...any) -> ...any)?) -> ()
}

export type RemoteFunctionClientConnection = ConnectionConstructor & {
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
local RunService = game:GetService("RunService")
local GetRemoteFunction = require(script.Parent.Parent.Modules.Remotes.GetRemoteFunction)

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
local RemoteFunctionWrapper = {}

function RemoteFunctionWrapper:Connect(folderName: string, functionName: string) :Connection
	assert(type(folderName) == "string", "Bad folder name")
	assert(type(functionName) == "string", "Bad function name")
	
	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName..functionName]

	local remoteInstance: Instance = GetRemoteFunction(folderName, functionName)

	connection = Connection.new(remoteInstance)
	connection._destroyedBindableEvent.Event:Once(function()
		networkDirectory[folderName..functionName] = nil
	    print(`Network connection to RemoteFunction '{folderName}'/'{functionName}' has been disconnected`)
	end)

	networkDirectory[folderName..functionName] = connection

	return connection
end

function RemoteFunctionWrapper:Disconnect(folderName: string, functionName: string)
	assert(type(folderName) == "string", "Bad folder name")
	assert(type(functionName) == "string", "Bad function name")

	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName..functionName]

	if connection ~= nil then
		connection:Destroy()
	else
		warn(`Network connection to {"RemoteFunction"} '{folderName}' does not exist`)
	end
end

--[[Connections]]
function Connection.new(instance: Instance): Connection
	assert(typeof(instance) == "Instance", `Connection.new(): invalid argument 'instance' (Instance expected, got {typeof(instance)})`)
	assert(instance.ClassName == "RemoteFunction", `Connection.new(): invalid instance type '{instance.ClassName}'`)

	local connection: Connection = {
		Instance = instance,
		_destroyedBindableEvent = Instance.new("BindableEvent")
	} :: Connection

	if instance.ClassName == "RemoteFunction" then
		if RunService:IsServer() == true then
			(connection :: RemoteFunctionServerConnection).Invoke = function(_: RemoteFunctionServerConnection, player: Player, ...): ...any
				return (instance :: RemoteFunction):InvokeClient(player, ...)
			end

			(connection :: RemoteFunctionServerConnection).Connect = function(_: RemoteFunctionServerConnection, callbackFunction: ((player: Player, ...any) -> ...any)?): ()
				(instance :: RemoteFunction).OnServerInvoke = callbackFunction :: (...any) -> ...any
			end
		elseif RunService:IsClient() == true then
			(connection :: RemoteFunctionClientConnection).Invoke = function(_: RemoteFunctionClientConnection, ...): ...any
				return (instance :: RemoteFunction):InvokeServer(...)
			end

			(connection :: RemoteFunctionServerConnection).Connect = function(_: RemoteFunctionServerConnection, callbackFunction: ((...any) -> ...any)?): ()
				(instance :: RemoteFunction).OnClientInvoke = callbackFunction :: (...any) -> ...any
			end
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
return function (folderName: string, functionName: string)
	return RemoteFunctionWrapper:Connect(folderName, functionName)
end