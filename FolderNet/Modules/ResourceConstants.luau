local ReadOnlyTable = require(script.Parent.ReadOnlyTable)

return ReadOnlyTable({
    SHARED_FOLDER_NAME = "SharedNet";
    SERVER_BINDABLES_FOLDER_NAME = "FolderNet_Server";

    REMOTE_EVENT_NAME = "RemoteEvent";
    REMOTE_FUNCTION_NAME = "RemoteFunction";
    UNRELIABLE_REMOTE_EVENT_NAME = "UnreliableRemoteEvent";

    CLIENT_BINDABLE_EVENT_NAME = "BindableEvent";
    CLIENT_BINDABLE_FUNCTION_NAME = "BindableFunction";

    SERVER_BINDABLE_EVENT_NAME = "BindableEvent";
    SERVER_BINDABLE_FUNCTION_NAME = "BindableFunction";
})