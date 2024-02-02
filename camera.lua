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
-- == Hard-Coded Variables ==
-- As the name suggests. Hard-coded variables
-- that can be reused later various times.
--

local ps = game:GetService ('Players')
local uis = game:GetService ('UserInputService')
local gs = UserSettings ( ):GetService ('UserGameSettings')
local rs = game:GetService ('RunService')

local client = ps.LocalPlayer
local character = client.Character or client.CharacterAdded:Wait ( )
local root = script
local camera = workspace.CurrentCamera
local humanoid = character:FindFirstChild ('Humanoid')

local shiftlocked = client:GetAttribute ('ShiftLock')
local cameraeditable = root:GetAttribute ('cameraeditable')
local maxrange = root:GetAttribute ('maxrange')
local head, rootpart = character:WaitForChild ('Head'), character:FindFirstChild ('HumanoidRootPart')
local mouse = client:GetMouse ( )

local shiftlockthread, look = nil, nil
local connection = nil
local saved, was = 0, false
local default, lockcenter = Enum.MouseBehavior.Default, Enum.MouseBehavior.LockCenter
local camerarelative, movementrelative = Enum.RotationType.CameraRelative, Enum.RotationType.MovementRelative

local ignoredlist = {character}

--
-- == ATTRIBUTES/PROPERTIES ==
-- These are properties of the script that will
-- be used to determine whether or not the modules
-- will actually perform the connections and how
-- the connections will behave.
--

script:SetAttribute ('cameraeditable', false)
script:SetAttribute ('xoffset', 1.5)
uis.MouseBehavior = default
gs.RotationType = movementrelative
client:GetMouse ( ).Icon = ' '

--
-- == DICTIONARIES ==
-- A table of functions that can be easily
-- accessed and organised.
--

local AutoZoom = {
	['connectioninit'] = function ( )
		connection = rs.RenderStepped:Connect (function ( )
			coroutine.wrap (function ( )
				for _, v in pairs (ps:GetChildren ( )) do
					local _character = v.Character or v.CharacterAdded:Wait ( )
					if table.find (ignoredlist, _character) then
						continue
					end

					table.insert (ignoredlist, _character)
					_character = nil
				end
			end) ( )

			if not cameraeditable then return end
			root:SetAttribute ('Zoom', (camera.CFrame.p - head.Position).Magnitude)
			local ray = Ray.new (head.CFrame.p, -camera.CFrame.lookVector*saved)
			local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, ignoredlist, false, true)

			if hitPart then
				if not hitPart.CanCollide and hitPart.Transparency > 0.4 or not hitPart.CanCollide or hitPart.Transparency > 0.4 then
					table.insert (ignoredlist, hitPart)
					return
				end

				was = true

				local mag = (head.Position - hitPos).magnitude
				if mag > maxrange then mag = maxrange end
				client.CameraMaxZoomDistance = mag
			else
				if was then
					was = false
					client.CameraMaxZoomDistance = maxrange
					client.CameraMinZoomDistance = saved
					task.wait (0.2)
					client.CameraMinZoomDistance = 0.5
				else
					saved = (camera.CFrame.p - head.Position).Magnitude
				end

				camera.FieldOfView = 70
			end

			if client:GetAttribute ('ShiftLock') then
				ray = Ray.new (camera.CFrame.p, camera.CFrame.LookVector)
				hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, ignoredlist, false, true)
				if hitPart then
					local bounds = hitPart.Size.magnitude/2 + (hitPart.Position - hitPos).magnitude
					local dist = (camera.CFrame.p - hitPos).magnitude
					local fov = math.rad (camera.FieldOfView)
					local angle = 2 * math.atan ((bounds/dist) * math.tan (fov/2))

					camera.FieldOfView = math.deg (angle)
				end

				ray = Ray.new (head.CFrame.p, head.CFrame.RightVector*2)
				hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, ignoredlist, false, true)
				if hitPart then
					root:SetAttribute ('xoffset', 0)
					camera.FieldOfView = 68
					return
				end

				ray = Ray.new (head.CFrame.p, camera.CFrame.RightVector)
				hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, ignoredlist, false, true)

				if hitPart then
					root:SetAttribute ('xoffset', (camera.CFrame.p - hitPos).magnitude-1)
				else
					root:SetAttribute ('xoffset', 1.5)
				end
			end
		end)
	end,

	['connectiondisc'] = function ( )
		connection:Disconnect ( )
		connection = nil
	end,
}

local ShiftLock = {
	['shiftlockinit'] = function ( )
		if not cameraeditable then return end

		if shiftlockthread ~= nil then
			shiftlockthread:Disconnect ( )
			shiftlockthread = nil
		end
		
		client:GetMouse ( ).Icon = 'rbxasset://textures/MouseLockedCursor.png'
		gs.RotationType = camerarelative
		uis.MouseBehavior = lockcenter
		
		shiftlockthread = rs.RenderStepped:Connect (function ( )
			if not cameraeditable then return end

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

			humanoid.CameraOffset = Vector3.new (offset - negativeoffset, 0, 0)
		end)
	end,

	['shiftlockdisc'] = function ( )
		uis.MouseBehavior = default
		gs.RotationType = movementrelative
		client:GetMouse ( ).Icon = ''
		humanoid.CameraOffset = Vector3.new ( )
		if shiftlockthread == nil then return end
		shiftlockthread:Disconnect ( )
		shiftlockthread = nil
	end,
}

--
-- == AUTOZOOM ==
-- This is a child of the main script. is 
-- a module of which's purpose is to prevent
-- cameras clipping through walls.
--

coroutine.wrap (function ( )
	AutoZoom['connectioninit'] ( ) -- initialises the module (it will make the initial connection and cache to memory so that it can disconnect, but will not run without cameraeditable being true)
end) ( )

--
-- == SHIFTLOCK ==
-- This is a child of the main script. it
-- servers as an alternative to the default
-- ShiftLock function provided by Roblox.
--

if shiftlocked then
	coroutine.wrap (function ( )
		ShiftLock['shiftlockinit'] ( )
	end) ( )
end

--
-- == SIGNALS & CONNECTIONS ==
-- These are events that will occur when
-- the signals are sent to action them.
-- These will need to be disconnected if
-- the client begins to stutter, but will
-- only be temporarily stored in memory.
--

client.AttributeChanged:Connect (function (attr)
	if attr == 'ShiftLock' then
		if not shiftlocked then
			coroutine.wrap (function ( )
				ShiftLock['shiftlockinit'] ( )
			end) ( )
		else
			coroutine.wrap (function ( )
				ShiftLock['shiftlockdisc'] ( )
			end) ( )
		end
		
		shiftlocked = client:GetAttribute (attr)
	end
end)

mouse.WheelForward:Connect (function ( )
	if not was then return end
	if (saved -  2) <= 0.5 then
		saved = 0.5
	else
		saved -= 2
	end
end)

mouse.WheelBackward:Connect (function ( )
	if not was then return end
	if (saved + 2) >= maxrange then
		saved = maxrange
	else
		saved += 2
	end
end)

root.AttributeChanged:Connect (function (attr)
	if attr == 'cameraeditable' then
		cameraeditable = root:GetAttribute (attr)
		if not cameraeditable then
			coroutine.wrap (function ( )
				AutoZoom['connectiondisc'] ( )
			end) ( )
			
			coroutine.wrap (function ( )
				ShiftLock['shiftlockdisc'] ( )
			end) ( )
		else
			if connection ~= nil then
				coroutine.wrap (function ( )
					AutoZoom['connectiondisc'] ( )
				end) ( )
			end
			
			if shiftlocked then
				coroutine.wrap (function ( )
					ShiftLock['shiftlockinit'] ( )
				end) ( )
			end
			
			coroutine.wrap (function ( )
				AutoZoom['connectioninit'] ( )
			end) ( )
		end
	elseif attr == 'maxrange' then
		maxrange = root:GetAttribute (attr)
		client.CameraMaxZoomDistance = maxrange
	end
end)

root.AttributeChanged:Connect (function (attr)
	if attr == 'cameraeditable' then
		cameraeditable = root:GetAttribute (attr)
	end
end)

script:SetAttribute ('maxrange', client.CameraMaxZoomDistance)
script:SetAttribute ('cameraeditable', true)
