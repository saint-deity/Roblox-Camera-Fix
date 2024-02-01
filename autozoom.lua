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
-- == AUTOZOOM ==
-- This is a child of the main script. is 
-- a module of which's purpose is to prevent
-- cameras clipping through walls.
--

local AutoZoom = { }

--
-- == Hard-Coded Variables ==
-- As the name suggests. Hard-coded variables
-- that can be reused later various times.
--
local rs = game:GetService ('RunService')
local root = script.Parent
local camera = workspace.CurrentCamera
local client = game.Players.LocalPlayer
local character = client.Character or client.CharacterAdded:Wait ( )
local cameraeditable = root:GetAttribute ('cameraeditable')
local maxrange = root:GetAttribute ('maxrange')
local connection = nil
local saved, was = 0, false
local head = character:WaitForChild ('Head')
local mouse = client:GetMouse ( )

local ignoredlist = {character}

--
-- == SIGNALS & CONNECTIONS ==
-- These are events that will occur when
-- the signals are sent to action them.
-- These will need to be disconnected if
-- the client begins to stutter, but will
-- only be temporarily stored in memory.
--

function AutoZoom.connectioninit ( )
	connection = rs.RenderStepped:Connect (function ( )
		if not cameraeditable then return end
		root:SetAttribute ('Zoom', (camera.CFrame.p - head.Position).Magnitude)
		local ray = Ray.new (head.CFrame.p, -camera.CFrame.lookVector*saved)
		local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, ignoredlist, false, true)
		
		if hitPart then
			print ("material: ", hitPart.Material)
			if not hitPart.CanCollide and hitPart.Transparency > 0.4 or not hitPart.CanCollide or hitPart.Transparency > 0.4 then
				table.insert (ignoredlist, hitPart)
				return
			end
			
			was = true

			local mag = (head.Position - hitPos).magnitude
			if mag > maxrange then mag = maxrange end
			client.CameraMaxZoomDistance = mag
			
			if client:GetAttribute ('ShiftLock') then
				local focus = camera:FindFirstChildOfClass ('Part')
				local ray = Ray.new (head.CFrame.p, camera.CFrame.rightVector*saved)
				local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, {game.Players.LocalPlayer.Character})
				if hitPart then
					local focus = camera:FindFirstChildOfClass ('Part'):FindFirstChildOfClass ('ManualWeld')
					focus.C0 = CFrame.new (hitPos - camera.CFrame.rightVector*1.2)
				end
			end
		else
			if was then
				was = false
				client.CameraMaxZoomDistance = maxrange
				client.CameraMinZoomDistance = saved
				task.wait (0.1)
				client.CameraMinZoomDistance = 0.5
			else
				saved = (camera.CFrame.p - head.Position).Magnitude
			end
		end
	end)
end

function AutoZoom.connectiondisc ( )
	connection:Disconnect ( )
	connection = nil
end

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
			AutoZoom.connectiondisc ( )
		else
			if connection ~= nil then
				AutoZoom.connectiondisc ( )
			end

			AutoZoom.connectioninit ( )
		end
	elseif attr == 'maxrange' then
		maxrange = root:GetAttribute (attr)
		client.CameraMaxZoomDistance = maxrange
	end
end)

return AutoZoom
