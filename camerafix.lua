-- 
-- Deities Custom Shiftlock
-- https://github.com/saint-deity/Roblox-Custom-Shiftlock
--
-- MIT License
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

script:SetAttribute ('cameraeditable', true)
local rs = game:GetService ('RunService')
local uis = game:GetService ('UserInputService')
local camera = workspace.CurrentCamera
local client = game.Players.LocalPlayer
script:SetAttribute ('maxrange', client.CameraMaxZoomDistance)
local character = client.Character or client.CharacterAdded:Wait ( )
local cameraeditable = script:GetAttribute ('cameraeditable')
local shiftlocked = client:GetAttribute ('ShiftLocked')
local maxrange = script:GetAttribute ('maxrange')
local connection = nil
local saved, was = 0, false
local head = character:WaitForChild ('Head')
local mouse = client:GetMouse ( )

function connectioninit ( )
	connection = rs.RenderStepped:Connect (function ( )
		if not cameraeditable then return end

		local ray = Ray.new (head.CFrame.p, -camera.CFrame.lookVector*saved)
		local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList (ray, {game.Players.LocalPlayer.Character})
		if hitPart then
			was = true

			local mag = (head.Position - hitPos).magnitude
			if mag > maxrange then mag = maxrange end
			client.CameraMaxZoomDistance = mag
		else
			if was then
				was = false
				client.CameraMaxZoomDistance = maxrange
				client.CameraMinZoomDistance = saved
				task.wait (0.1)
				client.CameraMinZoomDistance = 0.5
			else
				print (saved)
				saved = (camera.CFrame.p - head.Position).Magnitude
			end
		end
	end)
end

function connectiondisc ( )
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

	print(saved)
end)

mouse.WheelBackward:Connect (function ( )
	if not was then return end
	if (saved + 2) >= maxrange then
		saved = maxrange
	else
		saved += 2
	end

	print(saved)
end)

script.AttributeChanged:Connect (function (attr)
	if attr == 'cameraeditable' then
		cameraeditable = script:GetAttribute ('cameraeditable')
		if not cameraeditable then
			connectiondisc ( )
		else
			if connection ~= nil then
				connectiondisc ( )
			end

			connectioninit ( )
		end
	elseif attr == 'maxrange' then
		maxrange = script:GetAttribute ('maxrange')
		client.CameraMaxZoomDistance = maxrange
	end
end)

connectioninit ( )
