--[[
    Credits:
        @Quenty/Remoting
        @Quenty/Table
        @Uiscript/Network

    How this works!
        Call the name of the folder with a Event/Function,
            -> the Event/Function is created if doesn't exist,
            -> Connect/Fire/Invoke/Bind afterwards! ✨
        The name of the Event/Function shouldn't matter, it should only be the folder name!

    Setting:
        Change Modules/ResourceConstants for different Folder/Instance names.

    Example:
        Client:
            FolderNet.GetRemoteEvent("ShopUi") <-- Waits for RemoteEvent.
            FolderNet.GetBindableEvent("ShopUi") <-- Returns a BindableEvent in ReplicatedStorage.

        Server:
            FolderNet.GetRemoteEvent("ShopUi") <-- Returns RemoteEvent in ReplicatedStorage.
            FolderNet.GetBindableEvent("ShopUi") <-- Returns BindableEvent in ServerStorage.

        Tree [Output]:
            ReplicatedStorage:
                Shared
                    Module
                        Folders
                            ShopUi [Folder]:
                                RemoteEvent
                                BindableEvent
                                BindableFunction
            ServerStorage:
                ServerBindables [Folder]:
                    ShopUi [Folder]:
                        BindableEvent
                    
]]--

local BindableEventWrapper = require(script.Interface.BindableEventWrapper)
local BindableFunctionWrapper = require(script.Interface.BindableFunctionWrapper)
local RemoteEventWrapper = require(script.Interface.RemoteEventWrapper)
local RemoteFunctionWrapper = require(script.Interface.RemoteFunctionWrapper)
local UnreliableRemoteEvent = require(script.Interface.UnreliableRemoteEventWrapper)

return {
    GetBindableEvent = BindableEventWrapper,
    GetBindableFunction = BindableFunctionWrapper,
    GetRemoteEvent = RemoteEventWrapper,
    GetRemoteFunction = RemoteFunctionWrapper,
    GetUnreliableRemoteEvent = UnreliableRemoteEvent
}