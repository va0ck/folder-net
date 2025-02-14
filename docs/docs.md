---
outline: deep
---

# Information
These all return a Remote/Bindable instance.
::: tip
Folder-Net is intended to be used in a Framework like CrusherFire module loader. 
:::

## Bindables

### GetBindableEvent
Returns a BindableEvent.

```lua
local FolderNet = require(path.to.FolderNet)

local NewBindableEvent = FolderNet.GetBindableEvent(folderName, remoteName)
```

### GetBindableFunction
Returns a BindableFunction.

```lua
local FolderNet = require(path.to.FolderNet)

local NewBindableFunction = FolderNet.GetBindableFunction(folderName, functionName)
```

## Remotes
::: warning
Remotes called on the client will wait until the server calls the same function with same parameters!
This may yeild then with WaitForChild and will fail!
:::

### GetRemoteEvent
Returns a RemoteEvent.

```lua
local FolderNet = require(path.to.FolderNet)

local NewRemoteEvent = FolderNet.GetRemoteEvent(folderName, remoteName)
```

### GetRemoteFunction
Returns a RemoteFunction.

```lua
local FolderNet = require(path.to.FolderNet)

local NewRemoteFunction = FolderNet.GetRemoteFunction(folderName, functionName)
```

### GetUnreliableRemoteEvent
Returns a UnreliableRemoteEvent.

```lua
local FolderNet = require(path.to.FolderNet)

local NewUnreliableRemoteEvent = FolderNet.GetUnreliableRemoteEvent(folderName, remoteName)
```