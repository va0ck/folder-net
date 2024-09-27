---@diagnostic disable: redefined-type
--!strict

--[[Types]]
type Connection = RemoteEventServerConnection | RemoteEventClientConnection | UnreliableRemoteEventServerConnection | UnreliableRemoteEventClientConnection

type ConnectionConstructor = {
	Instance: Instance,
	Destroy: (self: any) -> (),
	[any]: any
}

export type RemoteEventServerConnection = ConnectionConstructor & {
	Fire: (self: any, player: Player, ...any) -> (),
	FireAll: (self: any, ...any) -> (),
	Connect: (self: any, callbackFunction: (player: Player, ...any) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: any, callbackFunction: (player: Player, ...any) -> ()) -> RBXScriptConnection,
	Once: (self: any, callbackFunction: (player: Player, ...any) -> ()) -> RBXScriptConnection,
	Wait: (self: any) -> (Player, ...any)
}

export type RemoteEventClientConnection = ConnectionConstructor & {
	Fire: (self: any, ...any) -> (),
	Connect: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	Once: (self: any, callbackFunction: (...any) -> ()) -> RBXScriptConnection,
	Wait: (self: any) -> ...any
}

export type UnreliableRemoteEventServerConnection = RemoteEventServerConnection
export type UnreliableRemoteEventClientConnection = RemoteEventClientConnection

type NetworkDirectory = {[string]: Connection}

export type Network = {
	Connect: (self: any, folderName: string) -> Connection,
	Disconnect: (self: any, folderName: string) -> (),
	[any]: any
}

--[[Service]]
local RunService = game:GetService("RunService")
local GetUnreliableRemoteEvent = require(script.Parent.Parent.Modules.Remotes.GetUnreliableRemoteEvent)

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
local UnreliableRemoteEventWrapper = {}

function UnreliableRemoteEventWrapper:Connect(folderName: string, eventName: string) :Connection
	assert(type(folderName) == "string", "Bad folder name")
	assert(type(eventName) == "string", "Bad event name")
	
	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName..eventName]

	local remoteInstance: Instance = GetUnreliableRemoteEvent(folderName, eventName)

	connection = Connection.new(remoteInstance)
	connection._destroyedBindableEvent.Event:Once(function()
	networkDirectory[folderName] = nil
	    warn(`Network connection to {"UnreliableRemoteEvent"} '{folderName}' has been disconnected`)
	end)

	networkDirectory[folderName] = connection

	return connection
end

function UnreliableRemoteEventWrapper:Disconnect(folderName: string, eventName: string)
	assert(type(folderName) == "string", "Bad folder name")
	assert(type(eventName) == "string", "Bad event name")

	local networkDirectory: NetworkDirectory = getNetworkDirectory()
	local connection: Connection = networkDirectory[folderName..eventName]

	if connection ~= nil then
		connection:Destroy()
	else
		warn(`Network connection to {"UnreliableRemoteEvent"} '{folderName}' does not exist`)
	end
end

--[[Connections]]
function Connection.new(instance: Instance): Connection
	assert(typeof(instance) == "Instance", `Connection.new(): invalid argument 'instance' (Instance expected, got {typeof(instance)})`)
	assert(instance.ClassName == "UnreliableRemoteEvent", `Connection.new(): invalid instance type '{instance.ClassName}'`)

	local connection: Connection = {
		Instance = instance,
		_destroyedBindableEvent = Instance.new("BindableEvent")
	} :: Connection

	if instance.ClassName == "UnreliableRemoteEvent" then
		if RunService:IsServer() == true then
			(connection :: RemoteEventServerConnection).Fire = function(_: RemoteEventServerConnection, player: Player, ...): ()
				(instance :: RemoteEvent):FireClient(player, ...)
			end

			(connection :: RemoteEventServerConnection).FireAll = function(_: RemoteEventServerConnection, ...): ()
				(instance :: RemoteEvent):FireAllClients(...)
			end

			(connection :: RemoteEventServerConnection).Connect = function(_: RemoteEventServerConnection, callbackFunction: (player: Player, ...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnServerEvent:Connect(callbackFunction)
			end

			(connection :: RemoteEventServerConnection).ConnectParallel = function(_: RemoteEventServerConnection, callbackFunction: (player: Player, ...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnServerEvent:ConnectParallel(callbackFunction)
			end

			(connection :: RemoteEventServerConnection).Once = function(_: RemoteEventServerConnection, callbackFunction: (player: Player, ...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnServerEvent:Once(callbackFunction)
			end

			(connection :: RemoteEventServerConnection).Wait = function(_: RemoteEventServerConnection): (Player, ...any)
				return (instance :: RemoteEvent).OnServerEvent:Wait()
			end
		elseif RunService:IsClient() == true then
			(connection :: RemoteEventClientConnection).Fire = function(_: RemoteEventClientConnection, ...): ()
				(instance :: RemoteEvent):FireServer(...)
			end

			(connection :: RemoteEventClientConnection).Connect = function(_: RemoteEventClientConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnClientEvent:Connect(callbackFunction)
			end

			(connection :: RemoteEventClientConnection).ConnectParallel = function(_: RemoteEventClientConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnClientEvent:ConnectParallel(callbackFunction)
			end

			(connection :: RemoteEventClientConnection).Once = function(_: RemoteEventClientConnection, callbackFunction: (...any) -> ()): RBXScriptConnection
				return (instance :: RemoteEvent).OnClientEvent:Once(callbackFunction)
			end

			(connection :: RemoteEventClientConnection).Wait = function(_: RemoteEventClientConnection): ...any
				return (instance :: RemoteEvent).OnClientEvent:Wait()
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
return function (folderName: string, eventName: string)
	return UnreliableRemoteEventWrapper:Connect(folderName, eventName)
end