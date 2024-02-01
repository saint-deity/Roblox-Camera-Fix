-- 
-- Deities Custom Camera
-- https://github.com/saint-deity/Roblox-Camera-Fix/
-- 
-- 
-- 
-- ==MIT License==
-- 
-- Copyright (c) 2024 Deity
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--
-- == SHIFTLOCK ==
-- This is a child of the main script. it
-- servers as an alternative to the default
-- ShiftLock function provided by Roblox.
--

local ShiftLock = {}

--
-- == Hard-Coded Variables ==
-- As the name suggests. Hard-coded variables
-- that can be reused later various times.
--

local ps = game:GetService ('Players')
local uis = game:GetService ('UserInputService')
local rs = game:GetService ('RunService')
local gs = UserSettings ( ):GetService ('UserGameSettings')
local client = ps.LocalPlayer
local character = client.Character or client.CharacterAdded:Wait ( )
local humanoid = character:FindFirstChild ('Humanoid')
local camera = workspace.CurrentCamera
local root = script.Parent
local cameraeditable = root:GetAttribute ('cameraeditable')
local shiftlockthread, look = nil, nil
local default, lockcenter = Enum.MouseBehavior.Default, Enum.MouseBehavior.LockCenter
local camerarelative, movementrelative = Enum.RotationType.CameraRelative, Enum.RotationType.MovementRelative

--
-- == SIGNALS & CONNECTIONS ==
-- These are events that will occur when
-- the signals are sent to action them.
-- These will need to be disconnected if
-- the client begins to stutter, but will
-- only be temporarily stored in memory.
--

function ShiftLock.shiftlockinit ( )
	if not cameraeditable then return end
	
	if shiftlockthread ~= nil then
		shiftlockthread:Disconnect ( )
		shiftlockthread = nil
	end
	
	local head, rootpart, rootattch = character:FindFirstChild ("Head"), character:FindFirstChild ('HumanoidRootPart'), nil
	rootattch = rootpart:FindFirstChild ('RootAttachment')
	client:GetMouse ( ).Icon = 'rbxasset://textures/MouseLockedCursor.png'
	
	shiftlockthread = rs.RenderStepped:Connect (function ( )
		if not cameraeditable then return end 
		gs.RotationType = camerarelative
		
		local forwardoffset = 0
		local negativeoffset = 0
		
		if humanoid.MoveDirection.Magnitude ~= 0 then
			forwardoffset = 0.5
		end
		
		local offset = root:GetAttribute ('xoffset')
		local zoom = root:GetAttribute ('Zoom')
		if offset > 0 then
			if zoom > 1 + forwardoffset then
				negativeoffset = (1.5 + forwardoffset) / zoom
			elseif zoom < 1 + forwardoffset then
				offset = 0
				negativeoffset = 0
			end
		end
		
		print(offset)
		humanoid.CameraOffset = Vector3.new (offset - negativeoffset, 0, 0)
		uis.MouseBehavior = lockcenter
	end)
end

function ShiftLock.shiftlockdisc ( )
	uis.MouseBehavior = default
	gs.RotationType = movementrelative
	client:GetMouse ( ).Icon = ''
	humanoid.CameraOffset = Vector3.new ( )
	shiftlockthread:Disconnect ( )
	shiftlockthread = nil
end

root.AttributeChanged:Connect (function (attr)
	if attr == 'cameraeditable' then
		cameraeditable = root:GetAttribute (attr)
	end
end)

return ShiftLock
