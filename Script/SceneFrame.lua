-- [ts]: SceneFrame.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local Color = ____Dora.Color -- 11
local Director = ____Dora.Director -- 11
local Node = ____Dora.Node -- 11
local Size = ____Dora.Size -- 11
local Sprite = ____Dora.Sprite -- 11
local Vec2 = ____Dora.Vec2 -- 11
local View = ____Dora.View -- 11
____exports.W = 1280 -- 13
____exports.H = 804 -- 14
local MARGIN = 22 -- 16
local BORDER = 4 -- 17
local SHADOW = 10 -- 18
local PAD_SCREEN = 22 -- 19
local CARD_W = ____exports.W + (MARGIN + BORDER) * 2 -- 20
local CARD_H = ____exports.H + (MARGIN + BORDER) * 2 -- 21
local OUT_W = CARD_W + SHADOW -- 22
local OUT_H = CARD_H + SHADOW -- 23
local EDGE = MARGIN + BORDER -- 24
local C_PAPER = Color(237, 227, 200, 255) -- 26
local C_INK = Color(36, 73, 70, 255) -- 27
local C_SHADOW = Color(59, 89, 84, 255) -- 30
function ____exports.createSceneFrame(coverBias) -- 40
	if coverBias == nil then -- 40
		coverBias = 0 -- 40
	end -- 40
	Director.clearColor = Color(197, 190, 169, 255) -- 42
	local root = Node() -- 44
	root.anchor = Vec2(0.5, 0.5) -- 45
	root.size = Size(OUT_W, OUT_H) -- 46
	root.position = Vec2(0, 0) -- 47
	root:addTo(Director.ui) -- 48
	local function cardBlock(x, y, w, h, c) -- 50
		local sp = Sprite("Image/StartUI/white.png") -- 51
		sp.anchor = Vec2(0, 1) -- 52
		sp.size = Size(w, h) -- 53
		sp.position = Vec2(x, OUT_H - y) -- 54
		sp.color = c -- 55
		sp:addTo(root) -- 56
		return sp -- 57
	end -- 50
	cardBlock( -- 61
		0, -- 61
		0, -- 61
		CARD_W, -- 61
		CARD_H, -- 61
		C_PAPER -- 61
	) -- 61
	local inner = Node() -- 64
	inner.anchor = Vec2(0, 1) -- 65
	inner.size = Size(____exports.W, ____exports.H) -- 66
	inner.position = Vec2(MARGIN + BORDER, OUT_H - (MARGIN + BORDER)) -- 67
	inner:addTo(root) -- 68
	cardBlock( -- 73
		0, -- 73
		0, -- 73
		CARD_W, -- 73
		EDGE, -- 73
		C_PAPER -- 73
	) -- 73
	cardBlock( -- 74
		0, -- 74
		CARD_H - EDGE, -- 74
		CARD_W, -- 74
		EDGE, -- 74
		C_PAPER -- 74
	) -- 74
	cardBlock( -- 75
		0, -- 75
		0, -- 75
		EDGE, -- 75
		CARD_H, -- 75
		C_PAPER -- 75
	) -- 75
	cardBlock( -- 76
		CARD_W - EDGE, -- 76
		0, -- 76
		EDGE, -- 76
		CARD_H, -- 76
		C_PAPER -- 76
	) -- 76
	cardBlock( -- 79
		0, -- 79
		0, -- 79
		CARD_W, -- 79
		BORDER, -- 79
		C_INK -- 79
	) -- 79
	cardBlock( -- 80
		0, -- 80
		CARD_H - BORDER, -- 80
		CARD_W, -- 80
		BORDER, -- 80
		C_INK -- 80
	) -- 80
	cardBlock( -- 81
		0, -- 81
		0, -- 81
		BORDER, -- 81
		CARD_H, -- 81
		C_INK -- 81
	) -- 81
	cardBlock( -- 82
		CARD_W - BORDER, -- 82
		0, -- 82
		BORDER, -- 82
		CARD_H, -- 82
		C_INK -- 82
	) -- 82
	cardBlock( -- 85
		CARD_W, -- 85
		SHADOW, -- 85
		SHADOW, -- 85
		CARD_H, -- 85
		C_SHADOW -- 85
	) -- 85
	cardBlock( -- 86
		SHADOW, -- 86
		CARD_H, -- 86
		CARD_W, -- 86
		SHADOW, -- 86
		C_SHADOW -- 86
	) -- 86
	local outer = Node() -- 90
	outer.anchor = Vec2(0.5, 0.5) -- 91
	outer.size = Size(OUT_W, OUT_H) -- 92
	outer:addTo(Director.ui) -- 93
	local C_PAGE = Director.clearColor -- 95
	local BIG = 2600 -- 96
	local function outerBlock(x, y, w, h) -- 97
		local sp = Sprite("Image/StartUI/white.png") -- 98
		sp.anchor = Vec2(0, 1) -- 99
		sp.size = Size(w, h) -- 100
		sp.position = Vec2(x, OUT_H - y) -- 101
		sp.color = C_PAGE -- 102
		sp:addTo(outer) -- 103
	end -- 97
	outerBlock(-BIG, -BIG, BIG, OUT_H + BIG * 2) -- 105
	outerBlock(OUT_W, -BIG, BIG, OUT_H + BIG * 2) -- 106
	outerBlock(-BIG, -BIG, OUT_W + BIG * 2, BIG) -- 107
	outerBlock(-BIG, OUT_H, OUT_W + BIG * 2, BIG) -- 108
	local input = Node() -- 111
	input.size = Size(____exports.W, ____exports.H) -- 112
	input.anchor = Vec2(0, 0) -- 113
	input.position = Vec2(0, 0) -- 114
	input:addTo(inner) -- 115
	input.touchEnabled = true -- 116
	local function fit() -- 122
		local vs = View.size -- 123
		local availW = math.max(120, vs.width - PAD_SCREEN * 2) -- 124
		local availH = math.max(80, vs.height - PAD_SCREEN * 2) -- 125
		local s = math.min(availW / OUT_W, availH / OUT_H) -- 126
		if coverBias > 0 then -- 126
			local sW = availW / OUT_W -- 131
			local needH = OUT_H * sW -- 132
			if needH > availH and (needH - availH) / needH <= coverBias then -- 132
				s = sW -- 133
			end -- 133
		end -- 133
		root.scaleX = s -- 135
		root.scaleY = s -- 136
		outer.scaleX = s -- 137
		outer.scaleY = s -- 138
	end -- 122
	fit() -- 140
	local function destroy() -- 144
		root:removeFromParent() -- 145
		outer:removeFromParent() -- 146
	end -- 144
	return { -- 151
		root = root, -- 152
		inner = inner, -- 153
		input = input, -- 154
		fit = function() -- 155
			fit() -- 155
		end, -- 155
		destroy = function() -- 156
			destroy() -- 156
		end -- 156
	} -- 156
end -- 40
return ____exports -- 40