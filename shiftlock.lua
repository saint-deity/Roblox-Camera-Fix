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
local ts = game:GetService ('TweenService')
local client = ps.LocalPlayer
local character = client.Character or client.CharacterAdded:Wait ( )
local camera = workspace.CurrentCamera
local root = script.Parent
local cameraeditable = root:GetAttribute ('cameraeditable')
local shiftlockthread, look, focus, tween = nil, nil, nil, nil
local custom, follow, default, lockcenter = Enum.CameraType.Custom, Enum.CameraType.Follow, Enum.MouseBehavior.Default, Enum.MouseBehavior.LockCenter
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
	
	local head = character:WaitForChild ("Head")

	look = camera.CFrame.lookVector
	look = Vector3.new (look.X, 0, look.Z)
	character:SetPrimaryPartCFrame (CFrame.new (character.PrimaryPart.Position, character.PrimaryPart.Position + look))
	
	focus = Instance.new ('Part')
	focus.Transparency = 1
	focus.CanCollide = false
	focus.CanTouch = false
	focus.CanQuery = false
	focus.EnableFluidForces = false
	focus.Anchored = true
	focus.CFrame = head.CFrame
	focus.Parent = camera
	
	-- change mouse icon
	client:GetMouse ( ).Icon = 'rbxasset://textures/MouseLockedCursor.png'
	
	camera.CameraSubject = focus
	local last = character.PrimaryPart.CFrame.p
	shiftlockthread = rs.RenderStepped:Connect (function ( )
		if not cameraeditable then return end
		
		local forwardoffset = 0
		local negativeoffset = 0
		
		if character:FindFirstChild ('Humanoid').MoveDirection.Magnitude ~= 0 then
			forwardoffset = 0.5
		end
		
		if root:GetAttribute ('Zoom') < 1+forwardoffset then
			camera.CameraSubject = character:FindFirstChild ('Humanoid')
		elseif root:GetAttribute ('Zoom') > 1+forwardoffset then
			negativeoffset = (1.5 + forwardoffset)/root:GetAttribute ('Zoom')
			camera.CameraSubject = focus
		end
		
		focus.CFrame = focus.CFrame:Lerp (character:FindFirstChild ('HumanoidRootPart').CFrame * CFrame.new (1.5-negativeoffset, 1.5, -0.1), 1)
		uis.MouseBehavior = lockcenter
		look = camera.CFrame.lookVector
		look = Vector3.new (look.X, 0, look.Z)
		
		if (character.PrimaryPart.CFrame.p - last).Magnitude < 0.0007 then
			if character:FindFirstChild ('Humanoid'):GetState ( ) ~= Enum.HumanoidStateType.Freefall and character:FindFirstChild ('Humanoid').MoveDirection.Magnitude == 0 or character:FindFirstChild ('Humanoid'):GetState ( ) ~= Enum.HumanoidStateType.FallingDown and character:FindFirstChild ('Humanoid').MoveDirection.Magnitude == 0 then
				character:SetPrimaryPartCFrame (CFrame.new (character.PrimaryPart.Position, character.PrimaryPart.Position + look))
				last = character.PrimaryPart.CFrame.p
			end
			
			return
		end
		
		character:SetPrimaryPartCFrame (CFrame.new (character.PrimaryPart.Position, character.PrimaryPart.Position + look))
		last = character.PrimaryPart.CFrame.p
	end)
end

function ShiftLock.shiftlockdisc ( )
	if cameraeditable then
		uis.MouseBehavior = default
		camera.CameraSubject = character:FindFirstChild ('Humanoid')
	end
	
	client:GetMouse ( ).Icon = ''
	focus:Destroy ( )
	shiftlockthread:Disconnect ( )
	shiftlockthread = nil
end

root.AttributeChanged:Connect (function (attr)
	if attr == 'cameraeditable' then
		cameraeditable = root:GetAttribute (attr)
	end
end)

return ShiftLock
