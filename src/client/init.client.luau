local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ZeWorld = require(Packages:WaitForChild("ZeWorld"))
ZeWorld.initialize()

local function simulate(deltaTime: number)
    for userId, playerData in ZeWorld.Data.Players do
        local player = Players:GetPlayerByUserId(tonumber(userId))
        if not player then
            continue
        end

        if player == LocalPlayer then
            local movementInput = (player.InputContext.Movement :: InputAction):GetState() :: Vector2
            playerData.Velocity = Vector3.new(movementInput.X, 0, movementInput.Y) * 10
        end

        local position = playerData.Position
        local velocity = playerData.Velocity

        position += velocity * deltaTime
        playerData.Position = position
    end
end

RunService:BindToSimulation(simulate)