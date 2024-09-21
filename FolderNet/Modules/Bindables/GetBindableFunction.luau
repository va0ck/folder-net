local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)

if RunService:IsServer() then
    return function (folderName)
        assert(type(folderName) == "string", "Bad name")

        local storage = ServerStorage:FindFirstChild(ResourceConstants.SERVER_BINDABLES_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SERVER_BINDABLES_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = ServerStorage
		end

        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        local event = folder:FindFirstChild(ResourceConstants.SERVER_BINDABLE_EVENT_NAME)
        if event then
            return event
        end

        event = Instance.new("BindableFunction")
		event.Name = ResourceConstants.SERVER_BINDABLE_EVENT_NAME
		event.Archivable = false
		event.Parent = folder

        return event
    end

elseif RunService:IsClient() then

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

        local event = folder:FindFirstChild(ResourceConstants.CLIENT_BINDABLE_FUNCTION_NAME)
        if event then
            return event
        end

        event = Instance.new("BindableFunction")
		event.Name = ResourceConstants.CLIENT_BINDABLE_FUNCTION_NAME
		event.Archivable = false
		event.Parent = folder

        return event
    end
else
    error("[GetBindableFunction] - Unknown RunService state")
end