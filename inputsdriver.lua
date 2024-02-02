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
-- == INPUTS ==
-- This is a child of StarterPlayerScripts. It
-- serves its purpose as a driver meant to interpret
-- the clients' inputs and any variables associated
-- with the inputs it reads.
--

--
-- == Hard-Coded Variables ==
-- As the name suggests. Hard-coded variables
-- that can be reused later various times.
--

local ps = game:GetService ('Players')
local uis = game:GetService ('UserInputService')
local client = ps.LocalPlayer
local shiftlocked = client:GetAttribute ('ShiftLock')
local lshift, rshift = Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift

--
-- == ATTRIBUTES ==eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- These are properties of the script that will
-- be used to determine whether or not the modules
-- will actually perform the connections and how
-- the connections will behave.
--

client:SetAttribute ('ShiftLock', false)

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
		shiftlocked = client:GetAttribute (attr)
	end
end)

uis.InputBegan:Connect (function (input, gp)
	if gp then return end
	input = input.KeyCode
	
	if input == lshift or input == rshift then
		client:SetAttribute ('ShiftLock', not client:GetAttribute ('ShiftLock'))
	end
end)
