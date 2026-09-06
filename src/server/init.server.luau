local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")

Players.CharacterAutoLoads = false

local InputContextTemplate = Instance.new("InputContext")

local MovementAction = Instance.new("InputAction")
MovementAction.Name = "Movement"
MovementAction.Type = Enum.InputActionType.Direction2D
MovementAction.Parent = InputContextTemplate

local InputBinding = Instance.new("InputBinding")
InputBinding.Right = Enum.KeyCode.D
InputBinding.Left = Enum.KeyCode.A
InputBinding.Up = Enum.KeyCode.W
InputBinding.Down = Enum.KeyCode.S
InputBinding.Parent = MovementAction

local ZeWorld = require(Packages:WaitForChild("ZeWorld"))
ZeWorld.initialize()
ZeWorld.Data.Players = {}

local function simulate(deltaTime: number)
    for userId, playerData in ZeWorld.Data.Players do
        local player = Players:GetPlayerByUserId(tonumber(userId))
        if not player then
            continue
        end

        local movementInput = (player.InputContext.Movement :: InputAction):GetState() :: Vector2
        playerData.Velocity = Vector3.new(movementInput.X, 0, movementInput.Y) * 10

        local position = playerData.Position
        local velocity = playerData.Velocity

        position += velocity * deltaTime
        playerData.Position = position
    end
end

local function onPlayerAdded(player: Player)
    local inputContext = InputContextTemplate:Clone()
    inputContext.Parent = player

    ZeWorld.Data.Players[player.UserId] = {
        Position = Vector3.new(0, 0, 0),
        Velocity = Vector3.new(0, 0, 0),
    }
end

local function onPlayerRemoving(player: Player)
    ZeWorld.Data.Players[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end

RunService:BindToSimulation(simulate)