--!strict
-- Dependencies
const Types = require('@self/Types')
const Janitor = require('./Janitor')

-- Services
const CollectionService = game:GetService("CollectionService")
const RunService = game:GetService("RunService")
const HttpService = game:GetService("HttpService")

-- Local Functions
const function getFirstChildOfClassAndName(parent: Instance, className: string, name: string): Instance?
    for _, child in parent:GetChildren() do
        if child.ClassName == className and child.Name == name then
            return child
        end
    end

    return nil
end

const function uuidRegexMatch(uuid: string): boolean
    return string.match(uuid, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

const function setPredictionMode(instance: Instance, mode: Enum.PredictionMode)
    if RunService:IsClient() then
        RunService:SetPredictionMode(instance, mode)
    end
end

-- Module
--[=[
    @class ZeWorld
]=]
local ZeWorld = {}

-- Properties
ZeWorld._initialized = false :: boolean
ZeWorld._dataFolder = nil :: Folder?
ZeWorld._proxies = {} :: {[Instance]: Types.Proxy}
ZeWorld.Data = nil :: Types.Proxy?

-- Functions

function ZeWorld.getKey(instance: Folder, key: string): any
    Types.typeInstanceAssert(instance, "Folder")
    Types.typeAssert(key, "string")

    local attributeValue = instance:GetAttribute(key) :: Types.AttributeValue?
    if attributeValue then
        if typeof(attributeValue) == "string" and uuidRegexMatch(attributeValue) then
            local taggedInstances = CollectionService:GetTagged(attributeValue)
            return taggedInstances[1] :: Instance?
        end

        return attributeValue
    end

    local childFolder = getFirstChildOfClassAndName(instance, "Folder", key) :: Folder?
    if not childFolder then
        return nil
    end

    return ZeWorld.getProxyForInstance(childFolder)
end

function ZeWorld.setKey(instance: Folder, key: string, value: Types.SupportedValue): nil
    Types.typeInstanceAssert(instance, "Folder")
    Types.typeAssert(key, "string")
    Types.typeAssertSupported(value)

    if typeof(value) == "Instance" then
        local instanceId = value:GetAttribute("ZeWorldId")

        if not instanceId then
            local newInstanceId = HttpService:GenerateGUID(false)
            value:SetAttribute("ZeWorldId", newInstanceId)
            value:AddTag(newInstanceId)
            instanceId = newInstanceId
        end

        instance:SetAttribute(key, instanceId)
        return nil
    end
    
    if typeof(value) == "table" then
        local childFolder = getFirstChildOfClassAndName(instance, "Folder", key) :: Folder

        if not childFolder then
            local newChildFolder = Instance.new("Folder") :: Folder
            newChildFolder.Name = key
            newChildFolder.Parent = instance
            childFolder = newChildFolder
        end

        local proxy = ZeWorld.getProxyForInstance(childFolder)
        for childKey, childValue in value do
            proxy[childKey] = childValue
        end

        return
    end

    instance:SetAttribute(key, value)
    return nil
end

function ZeWorld.iter(instance: Folder)
    local dictionary = {}

	for key, _ in instance:GetAttributes() do
		dictionary[key] = ZeWorld.getKey(instance, key)
	end

	for _, child in instance:GetChildren() do
		if not (child:IsA("Folder")) then
			continue
		end

		dictionary[child.Name] = ZeWorld.getKey(instance, child.Name)
	end

	return next, dictionary
end

function ZeWorld.getProxyForInstance(instance: Folder): Types.Proxy
    Types.typeInstanceAssert(instance, "Folder")

    if ZeWorld._proxies[instance] then
        return ZeWorld._proxies[instance]
    end

    setPredictionMode(instance, Enum.PredictionMode.On)
    
    local janitor = Janitor.new()
    local metatable = {
        __index = function(_, key: string)
            return ZeWorld.getKey(instance, key)
        end,
        __newindex = function(_, key, value)
            return ZeWorld.setKey(instance, key, value)
        end,
        __iter = function()
            return ZeWorld.iter(instance)
        end
    }

    local proxy = setmetatable({}, metatable) :: Types.Proxy

    janitor:Add(function()
        table.clear(metatable)
        table.clear(proxy)
        setmetatable(proxy, nil)

        ZeWorld._proxies[instance] = nil
    end)

    janitor:LinkToInstance(instance)
    ZeWorld._proxies[instance] = proxy
    return proxy
end

function ZeWorld.initializeProxy()
    assert(not ZeWorld._initialized, "Already initialized.")

    ZeWorld._initialized = true
    ZeWorld.Data = ZeWorld.getProxyForInstance(ZeWorld._dataFolder :: Folder)
end

function ZeWorld.initialize()
    assert(not ZeWorld._initialized, "Already initialized.")

    if RunService:IsServer() then
        local dataFolder = Instance.new("Folder")
        dataFolder.Name = "Data"
        dataFolder.Parent = workspace

        ZeWorld._dataFolder = dataFolder
        ZeWorld.initializeProxy()
        return
    end

    local dataFolder = workspace:WaitForChild("Data", 60) :: Folder
    assert(dataFolder, "Client could not find Data folder under Workspace.")
    
    ZeWorld._dataFolder = dataFolder
    ZeWorld.initializeProxy()
end

-- Return
return ZeWorld