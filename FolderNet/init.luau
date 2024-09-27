--[[
    Credits:
        @Quenty/Remoting
        @Quenty/Table
        @Uiscript/Network

    How this works!
        Call the name of the folder and the event/function name!
            If you only want to use the folderName only, then use FolderNet v0.0.4.

    Setting:
        Change Modules/ResourceConstants for different Folder/Instance names.

    Example:
        Client:
            FolderNet.GetRemoteEvent("ShopUi", "BuyItem") <-- Waits for RemoteEvent.
            FolderNet.GetBindableEvent("ShopUi", "GuiTween") <-- Returns a BindableEvent in ReplicatedStorage.

        Server:
            FolderNet.GetRemoteEvent("ShopUi", "BuyItem") <-- Returns RemoteEvent in ReplicatedStorage.
            FolderNet.GetBindableEvent("ShopUi", "ItemBoughtFunnel") <-- Returns BindableEvent in ServerStorage.

        Tree [Output]:
            ReplicatedStorage:
                Shared
                    Module
                        Folders
                            ShopUi [Folder]:
                                RemoteEvent [Folder]
                                    BuyItem
                                BindableEvent [Folder]
                                    GuiTween
            ServerStorage:
                ServerBindables [Folder]:
                    ShopUi [Folder]:
                        BindableEvent [Folder]
                            ItemBoughtFunnel
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