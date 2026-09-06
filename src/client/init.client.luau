local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ZeWorld = require(Packages:WaitForChild("ZeWorld"))
ZeWorld.initialize()