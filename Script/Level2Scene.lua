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
local ____Level3PreScene = require("Script.Level3PreScene") -- 12
local startLevel3Pre = ____Level3PreScene.startLevel3Pre -- 12
local ____Level3Play = require("Script.Level3Play") -- 13
local startLevel3 = ____Level3Play.startLevel3 -- 13
function ____exports.startLevel2(startAt, mode) -- 17
	local startPlay -- 17
	local frame = createSceneFrame() -- 18
	local dlg = nil -- 20
	local phase = 0 -- 21
	local play = nil -- 22
	local function startIntro() -- 24
		phase = 0 -- 25
		dlg = createDialogue( -- 26
			frame.inner, -- 26
			{ -- 26
				header = "二 · 砻糠计　关前", -- 27
				headerImg = "Image/StartUI/h2.png", -- 28
				scene = "Image/StartUI/lv2_scene.png", -- 29
				speaker = "王 梓", -- 30
				lines = LEVEL2_INTRO, -- 31
				fxGroups = {"mill", "siege", "bin", "bran"}, -- 32
				spotData = LEVEL2_SPOTS, -- 33
				caption = "城内 · 碾房与晒场（示意）", -- 34
				startAt = startAt, -- 35
				sayTall = true, -- 36
				onFinish = function() -- 37
					if dlg ~= nil then -- 37
						dlg.destroy() -- 39
						dlg = nil -- 40
					end -- 40
					startPlay() -- 42
				end -- 37
			} -- 37
		) -- 37
	end -- 24
	local function goPost() -- 50
		if phase == 3 then -- 50
			return -- 51
		end -- 51
		if play ~= nil then -- 51
			play:destroy() -- 52
			play = nil -- 52
		end -- 52
		frame:destroy() -- 53
		phase = 3 -- 54
		startLevel2Post(function() -- 55
			startLevel3Pre(function() -- 56
				startLevel3() -- 57
			end) -- 56
		end) -- 55
	end -- 50
	startPlay = function() -- 62
		phase = 1 -- 63
		local ____createLevel2Play_8 = createLevel2Play -- 64
		local ____frame_inner_7 = frame.inner -- 64
		local function ____temp_1() -- 65
			goPost() -- 65
		end -- 65
		local function ____temp_2() -- 66
			goPost() -- 66
		end -- 66
		local function ____temp_3() -- 67
			if play ~= nil then -- 67
				play:destroy() -- 68
				play = nil -- 68
			end -- 68
			frame:destroy() -- 69
			____exports.startLevel2(nil, "play") -- 70
		end -- 67
		local function ____temp_4() -- 72
			if play ~= nil then -- 72
				play:destroy() -- 73
				play = nil -- 73
			end -- 73
			frame:destroy() -- 74
			backToTitle() -- 75
		end -- 72
		local ____temp_5 = mode == "play" or mode == "panel" or mode == "pause" -- 77
		local ____temp_6 = mode == "panel" and "panel" or (mode == "pause" and "pause" or (mode == "btn" and "btn" or (mode == "hov" and "hov" or nil))) -- 78
		local ____temp_0 -- 80
		if mode == "play" then -- 80
			____temp_0 = startAt -- 80
		else -- 80
			____temp_0 = nil -- 80
		end -- 80
		play = ____createLevel2Play_8(____frame_inner_7, { -- 64
			onFinish = ____temp_1, -- 65
			onNext = ____temp_2, -- 66
			onRestart = ____temp_3, -- 67
			onQuit = ____temp_4, -- 72
			immediate = ____temp_5, -- 77
			debugView = ____temp_6, -- 78
			startAt = ____temp_0 -- 80
		}) -- 80
	end -- 62
	local function startEnd() -- 86
		phase = 2 -- 87
		print("[Level2] 一夜过去了") -- 88
		goPost() -- 89
	end -- 86
	local function skipPhase() -- 95
		if phase == 0 then -- 95
			if dlg ~= nil then -- 95
				dlg.skip() -- 97
			end -- 97
		elseif phase == 1 then -- 97
			if play ~= nil then -- 97
				play:skip() -- 99
			end -- 99
		elseif phase == 2 then -- 99
			goPost() -- 103
		end -- 103
	end -- 95
	local function advance() -- 108
		if dlg ~= nil then -- 108
			dlg.next() -- 109
		end -- 109
	end -- 108
	frame.input:onTapped(function(touch) -- 113
		if phase == 1 and play ~= nil then -- 113
			play:tapAt(touch.location.x, H - touch.location.y) -- 116
			return -- 117
		end -- 117
		if dlg ~= nil and dlg.tapAt(touch.location.x, touch.location.y) then -- 117
			return -- 120
		end -- 120
		advance() -- 122
	end) -- 113
	frame.input:onMouseMove(function(touch) -- 126
		if phase == 1 and play ~= nil then -- 126
			play:hoverAt(touch.location.x, H - touch.location.y) -- 128
		end -- 128
	end) -- 126
	frame.input:onTapBegan(function(touch) -- 133
		if phase == 1 and play ~= nil then -- 133
			play:setPointer(touch.location.x, H - touch.location.y, true) -- 135
		end -- 135
	end) -- 133
	frame.input:onTapEnded(function(touch) -- 138
		if phase == 1 and play ~= nil then -- 138
			play:setPointer(touch.location.x, H - touch.location.y, false) -- 140
		end -- 140
	end) -- 138
	frame.input:onTapMoved(function(touch) -- 145
		if phase == 1 and play ~= nil then -- 145
			local tx = touch.location.x -- 147
			local ty = H - touch.location.y -- 147
			play:hoverAt(tx, ty) -- 148
			play:dragTo(tx, ty) -- 149
		end -- 149
	end) -- 145
	frame.root:onKeyDown(function(key) -- 153
		if key == "P" then -- 153
			skipPhase() -- 157
			return -- 158
		end -- 158
		if key == "Escape" and phase == 1 and play ~= nil and play:setPanelOpen() then -- 158
			play:tapAt(1214, 36) -- 162
			return -- 163
		end -- 163
		if key == "R" and phase == 2 then -- 163
			frame:destroy() -- 168
			____exports.startLevel2(nil, "play") -- 169
			return -- 170
		end -- 170
		local hit0 = key == "1" or key == "J" or key == "D" -- 177
		local hit1 = key == "2" or key == "K" or key == "F" -- 178
		local hit2 = key == "3" or key == "L" or key == "G" -- 179
		if hit0 or hit1 or hit2 then -- 179
			if phase == 1 and play ~= nil then -- 179
				if hit0 then -- 179
					play:hit(0) -- 182
				end -- 182
				if hit1 then -- 182
					play:hit(1) -- 183
				end -- 183
				if hit2 then -- 183
					play:hit(2) -- 184
				end -- 184
				return -- 185
			end -- 185
			if phase == 0 then -- 185
				advance() -- 187
				return -- 187
			end -- 187
			return -- 188
		end -- 188
		if key == "Space" then -- 188
			if phase == 1 and play ~= nil then -- 188
				play:hit(1) -- 192
				return -- 192
			end -- 192
			advance() -- 193
			return -- 194
		end -- 194
		if key == "Return" then -- 194
			advance() -- 197
		end -- 197
	end) -- 153
	frame.root:schedule(function(dt) -- 201
		frame:fit() -- 202
		if dlg ~= nil then -- 202
			dlg.update(dt) -- 204
		end -- 204
		if play ~= nil then -- 204
			play:update(dt) -- 207
		end -- 207
		return false -- 209
	end) -- 201
	if mode == "card" or mode == "play" or mode == "panel" or mode == "pause" or mode == "btn" or mode == "hov" then -- 201
		startPlay() -- 213
		print("[Level2] 跳过对话（调试后门）") -- 214
		return -- 215
	end -- 215
	startIntro() -- 217
	print("[Level2] 关前台词开始") -- 218
end -- 17
return ____exports -- 17