local RunService = game:GetService("RunService")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)
if RunService:IsServer() then
    return function (folderName)
        assert(type(folderName) == "string", "Bad name")

        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        local event = folder:FindFirstChild(ResourceConstants.REMOTE_EVENT_NAME)
		if event then
			return event
		end

        event = Instance.new("RemoteEvent")
		event.Name = ResourceConstants.REMOTE_EVENT_NAME
		event.Archivable = false
		event.Parent = folder

		return event
    end
elseif  RunService:IsClient() then
    return function (folderName)
        assert(type(folderName) == "string", "Bad name")

        return script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME):WaitForChild(folderName):WaitForChild(ResourceConstants.REMOTE_EVENT_NAME)
    end
else
    error("[GetRemoteEvent] - Unknown RunService state")
end