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

        local func = folder:FindFirstChild(ResourceConstants.REMOTE_FUNCTION_NAME)
		if func then
			return func
		end

        func = Instance.new("RemoteFunction")
		func.Name = ResourceConstants.REMOTE_FUNCTION_NAME
		func.Archivable = false
		func.Parent = folder

		return func
    end
elseif  RunService:IsClient() then
    return function (folderName)
        assert(type(folderName) == "string", "Bad name")

        return script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME):WaitForChild(folderName):WaitForChild(ResourceConstants.REMOTE_FUNCTION_NAME)
    end
else
    error("[GetRemoteFunction] - Unknown RunService state")
end