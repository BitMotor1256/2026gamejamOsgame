-- [ts]: Level1Scene.ts
local ____exports = {} -- 1
local ____BrickGame = require("Script.BrickGame") -- 4
local createBrickGame = ____BrickGame.createBrickGame -- 4
local ____Dialogue = require("Script.Dialogue") -- 5
local createDialogue = ____Dialogue.createDialogue -- 5
local ____InfoDeck = require("Script.InfoDeck") -- 6
local startDeck = ____InfoDeck.startDeck -- 6
local ____Level2Scene = require("Script.Level2Scene") -- 7
local startLevel2 = ____Level2Scene.startLevel2 -- 7
local ____Nav = require("Script.Nav") -- 8
local backToTitle = ____Nav.backToTitle -- 8
local ____SceneFrame = require("Script.SceneFrame") -- 9
local createSceneFrame = ____SceneFrame.createSceneFrame -- 9
local ____Story = require("Script.Story") -- 10
local LEVEL1_INTRO = ____Story.LEVEL1_INTRO -- 10
local LEVEL1_OUTRO = ____Story.LEVEL1_OUTRO -- 10
local LEVEL1_SLIDES = ____Story.LEVEL1_SLIDES -- 10
function ____exports.startLevel1() -- 12
	local startBrick, startOutro, startEnd -- 12
	local frame = createSceneFrame() -- 13
	local root = frame.root -- 14
	local inner = frame.inner -- 15
	local input = frame.input -- 16
	local phase = 0 -- 19
	local dlg = nil -- 20
	local goNext = false -- 21
	local goTitle = false -- 22
	local deck = nil -- 23
	local game = nil -- 24
	local SCENE_IMG = "Image/StartUI/scene_lv1.png" -- 26
	local function startIntro() -- 28
		phase = 0 -- 29
		dlg = createDialogue( -- 30
			inner, -- 30
			{ -- 30
				header = "一 · 砌墙　关前", -- 31
				headerImg = "Image/StartUI/h1.png", -- 32
				scene = SCENE_IMG, -- 33
				speaker = "王 梓", -- 34
				lines = LEVEL1_INTRO, -- 35
				fxGroups = {"ruler", "height", "seal"}, -- 36
				onFinish = function() -- 37
					if dlg ~= nil then -- 37
						dlg.destroy() -- 39
						dlg = nil -- 40
					end -- 40
					phase = 1 -- 42
					startBrick() -- 43
				end -- 37
			} -- 37
		) -- 37
	end -- 28
	startBrick = function() -- 50
		game = createBrickGame( -- 51
			inner, -- 51
			function() -- 51
				if game ~= nil then -- 51
					game.destroy() -- 53
					game = nil -- 54
				end -- 54
				startOutro() -- 56
			end, -- 51
			function() -- 57
				goTitle = true -- 59
			end -- 57
		) -- 57
	end -- 50
	local function startDeckFlow() -- 65
		phase = 4 -- 66
		deck = startDeck( -- 67
			inner, -- 67
			"一 · 砌墙　补充科普", -- 67
			LEVEL1_SLIDES, -- 67
			function() -- 67
				if deck ~= nil then -- 67
					deck.destroy() -- 69
					deck = nil -- 70
				end -- 70
				startEnd() -- 72
			end -- 67
		) -- 67
	end -- 65
	startOutro = function() -- 77
		phase = 2 -- 78
		dlg = createDialogue( -- 79
			inner, -- 79
			{ -- 79
				header = "一 · 砌墙　关后", -- 80
				scene = SCENE_IMG, -- 81
				speaker = "王 梓", -- 82
				lines = LEVEL1_OUTRO, -- 83
				fxGroups = {"gap", "ruler", "height", "crown"}, -- 84
				tags = {height = "高 8 米　底宽 3.9 米"}, -- 85
				spots = false, -- 86
				onFinish = function() -- 87
					if dlg ~= nil then -- 87
						dlg.destroy() -- 89
						dlg = nil -- 90
					end -- 90
					startEnd() -- 92
				end -- 87
			} -- 87
		) -- 87
	end -- 77
	startEnd = function() -- 97
		phase = 3 -- 98
		goNext = true -- 99
	end -- 97
	local function skipPhase() -- 104
		if phase == 0 or phase == 2 then -- 104
			if dlg ~= nil then -- 104
				dlg.skip() -- 106
			end -- 106
		elseif phase == 1 then -- 106
			if game ~= nil then -- 106
				game.skip() -- 108
			end -- 108
		elseif phase == 4 then -- 108
			if deck ~= nil then -- 108
				deck.skip() -- 110
			end -- 110
		end -- 110
	end -- 104
	local function advance() -- 114
		if phase == 1 then -- 114
			return -- 115
		end -- 115
		if phase == 4 then -- 115
			if deck ~= nil then -- 115
				deck.next() -- 117
			end -- 117
			return -- 118
		end -- 118
		if dlg ~= nil then -- 118
			dlg.next() -- 121
		end -- 121
	end -- 114
	input:onTapped(function(touch) -- 126
		if dlg ~= nil and dlg.tapAt(touch.location.x, touch.location.y) then -- 126
			return -- 128
		end -- 128
		advance() -- 130
	end) -- 126
	root:onKeyDown(function(key) -- 132
		if key == "P" then -- 132
			skipPhase() -- 134
			return -- 135
		end -- 135
		if key == "Return" or key == "Space" then -- 135
			advance() -- 138
		end -- 138
	end) -- 132
	root:schedule(function(dt) -- 143
		if goNext then -- 143
			dlg = nil -- 147
			game = nil -- 148
			frame:destroy() -- 149
			print("[Level1] 关前流程走完，进第二关") -- 150
			startLevel2() -- 151
			return true -- 152
		end -- 152
		if goTitle then -- 152
			dlg = nil -- 156
			game = nil -- 157
			deck = nil -- 158
			frame:destroy() -- 159
			print("[Level1] 返回主界面") -- 160
			backToTitle() -- 161
			return true -- 162
		end -- 162
		frame:fit() -- 165
		if dlg ~= nil then -- 165
			dlg.update(dt) -- 168
		end -- 168
		if deck ~= nil then -- 168
			deck.update(dt) -- 171
		end -- 171
		if game ~= nil then -- 171
			game.update(dt) -- 174
		end -- 174
		return false -- 177
	end) -- 143
	startIntro() -- 180
	print("[Level1] 台词流程开始") -- 181
end -- 12
return ____exports -- 12