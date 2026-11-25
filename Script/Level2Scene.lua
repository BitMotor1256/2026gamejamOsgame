-- [ts]: Level2Scene.ts
local ____exports = {} -- 1
local ____Dialogue = require("Script.Dialogue") -- 5
local createDialogue = ____Dialogue.createDialogue -- 5
local ____SceneFrame = require("Script.SceneFrame") -- 6
local createSceneFrame = ____SceneFrame.createSceneFrame -- 6
local ____Story = require("Script.Story") -- 7
local LEVEL2_INTRO = ____Story.LEVEL2_INTRO -- 7
local LEVEL2_SPOTS = ____Story.LEVEL2_SPOTS -- 7
local ____Level2Play = require("Script.Level2Play") -- 8
local createLevel2Play = ____Level2Play.createLevel2Play -- 8
local ____SceneFrame = require("Script.SceneFrame") -- 9
local H = ____SceneFrame.H -- 9
local ____Nav = require("Script.Nav") -- 10
local backToTitle = ____Nav.backToTitle -- 10
local ____Level2PostScene = require("Script.Level2PostScene") -- 11
local startLevel2Post = ____Level2PostScene.startLevel2Post -- 11
function ____exports.startLevel2(startAt, mode) -- 15
	local startPlay, startEnd -- 15
	local frame = createSceneFrame() -- 16
	local dlg = nil -- 18
	local phase = 0 -- 19
	local play = nil -- 20
	local function startIntro() -- 22
		phase = 0 -- 23
		dlg = createDialogue( -- 24
			frame.inner, -- 24
			{ -- 24
				header = "二 · 砻糠计　关前", -- 25
				headerImg = "Image/StartUI/h2.png", -- 26
				scene = "Image/StartUI/lv2_scene.png", -- 27
				speaker = "王 梓", -- 28
				lines = LEVEL2_INTRO, -- 29
				fxGroups = {"mill", "siege", "bin", "bran"}, -- 30
				spotData = LEVEL2_SPOTS, -- 31
				caption = "城内 · 碾房与晒场（示意）", -- 32
				startAt = startAt, -- 33
				sayTall = true, -- 34
				onFinish = function() -- 35
					if dlg ~= nil then -- 35
						dlg.destroy() -- 37
						dlg = nil -- 38
					end -- 38
					startPlay() -- 40
				end -- 35
			} -- 35
		) -- 35
	end -- 22
	startPlay = function() -- 46
		phase = 1 -- 47
		local ____createLevel2Play_8 = createLevel2Play -- 48
		local ____frame_inner_7 = frame.inner -- 48
		local function ____temp_1() -- 49
			if play ~= nil then -- 49
				play:destroy() -- 51
				play = nil -- 52
			end -- 52
			startEnd() -- 54
		end -- 49
		local function ____temp_2() -- 56
			if play ~= nil then -- 56
				play:destroy() -- 58
				play = nil -- 58
			end -- 58
			frame:destroy() -- 59
			startLevel2Post(function() -- 60
				print("[Level2] 关后科普看完 → 第三关（引流）尚未接入") -- 61
			end) -- 60
		end -- 56
		local function ____temp_3() -- 64
			if play ~= nil then -- 64
				play:destroy() -- 65
				play = nil -- 65
			end -- 65
			frame:destroy() -- 66
			____exports.startLevel2(nil, "play") -- 67
		end -- 64
		local function ____temp_4() -- 69
			if play ~= nil then -- 69
				play:destroy() -- 70
				play = nil -- 70
			end -- 70
			frame:destroy() -- 71
			backToTitle() -- 72
		end -- 69
		local ____temp_5 = mode == "play" or mode == "panel" or mode == "pause" -- 74
		local ____temp_6 = mode == "panel" and "panel" or (mode == "pause" and "pause" or (mode == "btn" and "btn" or (mode == "hov" and "hov" or nil))) -- 75
		local ____temp_0 -- 77
		if mode == "play" then -- 77
			____temp_0 = startAt -- 77
		else -- 77
			____temp_0 = nil -- 77
		end -- 77
		play = ____createLevel2Play_8(____frame_inner_7, { -- 48
			onFinish = ____temp_1, -- 49
			onNext = ____temp_2, -- 56
			onRestart = ____temp_3, -- 64
			onQuit = ____temp_4, -- 69
			immediate = ____temp_5, -- 74
			debugView = ____temp_6, -- 75
			startAt = ____temp_0 -- 77
		}) -- 77
	end -- 46
	startEnd = function() -- 81
		phase = 2 -- 82
		print("[Level2] 一夜过去了") -- 83
	end -- 81
	local function skipPhase() -- 89
		if phase == 0 then -- 89
			if dlg ~= nil then -- 89
				dlg.skip() -- 91
			end -- 91
		elseif phase == 1 then -- 91
			if play ~= nil then -- 91
				play:skip() -- 93
			end -- 93
		elseif phase == 2 then -- 93
			if play ~= nil then -- 93
				play:tapAt(232, 690) -- 95
			end -- 95
		end -- 95
	end -- 89
	local function advance() -- 99
		if dlg ~= nil then -- 99
			dlg.next() -- 100
		end -- 100
	end -- 99
	frame.input:onTapped(function(touch) -- 104
		if phase == 1 and play ~= nil then -- 104
			play:tapAt(touch.location.x, H - touch.location.y) -- 107
			return -- 108
		end -- 108
		if dlg ~= nil and dlg.tapAt(touch.location.x, touch.location.y) then -- 108
			return -- 111
		end -- 111
		advance() -- 113
	end) -- 104
	frame.input:onMouseMove(function(touch) -- 117
		if phase == 1 and play ~= nil then -- 117
			play:hoverAt(touch.location.x, H - touch.location.y) -- 119
		end -- 119
	end) -- 117
	frame.input:onTapBegan(function(touch) -- 124
		if phase == 1 and play ~= nil then -- 124
			play:setPointer(touch.location.x, H - touch.location.y, true) -- 126
		end -- 126
	end) -- 124
	frame.input:onTapEnded(function(touch) -- 129
		if phase == 1 and play ~= nil then -- 129
			play:setPointer(touch.location.x, H - touch.location.y, false) -- 131
		end -- 131
	end) -- 129
	frame.input:onTapMoved(function(touch) -- 136
		if phase == 1 and play ~= nil then -- 136
			local tx = touch.location.x -- 138
			local ty = H - touch.location.y -- 138
			play:hoverAt(tx, ty) -- 139
			play:dragTo(tx, ty) -- 140
		end -- 140
	end) -- 136
	frame.root:onKeyDown(function(key) -- 144
		if key == "P" then -- 144
			skipPhase() -- 148
			return -- 149
		end -- 149
		if key == "Escape" and phase == 1 and play ~= nil and play:setPanelOpen() then -- 149
			play:tapAt(1214, 36) -- 153
			return -- 154
		end -- 154
		if key == "R" and phase == 2 then -- 154
			frame:destroy() -- 159
			____exports.startLevel2(nil, "play") -- 160
			return -- 161
		end -- 161
		local hit0 = key == "1" or key == "J" or key == "D" -- 168
		local hit1 = key == "2" or key == "K" or key == "F" -- 169
		local hit2 = key == "3" or key == "L" or key == "G" -- 170
		if hit0 or hit1 or hit2 then -- 170
			if phase == 1 and play ~= nil then -- 170
				if hit0 then -- 170
					play:hit(0) -- 173
				end -- 173
				if hit1 then -- 173
					play:hit(1) -- 174
				end -- 174
				if hit2 then -- 174
					play:hit(2) -- 175
				end -- 175
				return -- 176
			end -- 176
			if phase == 0 then -- 176
				advance() -- 178
				return -- 178
			end -- 178
			return -- 179
		end -- 179
		if key == "Space" then -- 179
			if phase == 1 and play ~= nil then -- 179
				play:hit(1) -- 183
				return -- 183
			end -- 183
			advance() -- 184
			return -- 185
		end -- 185
		if key == "Return" then -- 185
			advance() -- 188
		end -- 188
	end) -- 144
	frame.root:schedule(function(dt) -- 192
		frame:fit() -- 193
		if dlg ~= nil then -- 193
			dlg.update(dt) -- 195
		end -- 195
		if play ~= nil then -- 195
			play:update(dt) -- 198
		end -- 198
		return false -- 200
	end) -- 192
	if mode == "card" or mode == "play" or mode == "panel" or mode == "pause" or mode == "btn" or mode == "hov" then -- 192
		startPlay() -- 204
		print("[Level2] 跳过对话（调试后门）") -- 205
		return -- 206
	end -- 206
	startIntro() -- 208
	print("[Level2] 关前台词开始") -- 209
end -- 15
return ____exports -- 15