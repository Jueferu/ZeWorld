local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ZeWorld = require(Packages:WaitForChild("ZeWorld"))
ZeWorld.initialize()

ZeWorld.Data.hi = true
ZeWorld.Data.b = workspace.Terrain
ZeWorld.Data.c = {
    a = 1,
    b = 2,
    c = 3
}