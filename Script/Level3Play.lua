-- [ts]: Level3Play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Audio = ____Dora.Audio -- 10
local Color = ____Dora.Color -- 11
local DrawNode = ____Dora.DrawNode -- 12
local Label = ____Dora.Label -- 14
local Node = ____Dora.Node -- 15
local Rect = ____Dora.Rect -- 16
local Size = ____Dora.Size -- 17
local Sprite = ____Dora.Sprite -- 18
local Vec2 = ____Dora.Vec2 -- 19
local ____Nav = require("Script.Nav") -- 21
local backToTitle = ____Nav.backToTitle -- 21
local ____Level3ResultScene = require("Script.Level3ResultScene") -- 22
local startLevel3Result = ____Level3ResultScene.startLevel3Result -- 22
local ____Level3PostScene = require("Script.Level3PostScene") -- 23
local startLevel3Post = ____Level3PostScene.startLevel3Post -- 23
local ____SceneFrame = require("Script.SceneFrame") -- 24
local createSceneFrame = ____SceneFrame.createSceneFrame -- 24
local W = 1280 -- 26
local H = 800 -- 26
local G = 24 -- 29
local COLS = 44 -- 29
local ROWS = 22 -- 29
local GW = COLS * G -- 30
local GH = ROWS * G -- 30
local OX = (W - GW) / 2 -- 31
local OY = 86 -- 32
local ST_T = OY + GH -- 33
local ST_Y = ST_T -- 34
local NEED = 3 -- 37
local TOTAL_POUR = 24 -- 37
local SPD_0 = 3.9 -- 38
local SPD_STEP = 0.15 -- 38
local SPD_MAX = 5.1 -- 38
local LEN_0 = 2 -- 39
local LEN_MAX = 6 -- 39
local CUT = 2 -- 39
local WIN_KEEP = 38 -- 40
local DRY_GRACE = 18 -- 40
local NEVER_GRACE = 60 -- 40
local NEED_LEN = {3, 4, 5, 0} -- 41
local RESET_LEN = {2, 3, 4, 0} -- 42
local START_DELAY = 0.9 -- 43
local STUN = 0.5 -- 43
local DITCH_MAX = 1 -- 44
local DITCH_T = 4 -- 44
local DITCH_ROWS = {6, 7, 14, 15} -- 45
local C_PAPER = Color(237, 227, 200, 255) -- 48
local C_PAPER2 = Color(243, 234, 211, 255) -- 49
local C_SAND = Color(212, 203, 171, 255) -- 50
local C_SEAM = Color(168, 159, 127, 255) -- 51
local C_TEAL = Color(90, 121, 104, 255) -- 52
local C_INK = Color(36, 73, 70, 255) -- 53
local C_DEEP = Color(23, 51, 48, 255) -- 54
local C_VERM = Color(163, 59, 42, 255) -- 55
local C_GOLD = Color(176, 138, 66, 255) -- 56
local C_LV1 = Color(184, 198, 158, 255) -- 57
local C_LV2 = Color(150, 180, 128, 255) -- 58
local C_LV3 = Color(104, 150, 100, 255) -- 59
local C_EMPTY = Color(214, 206, 183, 255) -- 60
local function approach(v, target, step) -- 62
	if v < target then -- 62
		return math.min(target, v + step) -- 63
	end -- 63
	if v > target then -- 63
		return math.max(target, v - step) -- 64
	end -- 64
	return v -- 65
end -- 62
local function mixColor(a, b, t) -- 67
	return Color( -- 68
		math.floor(a.r + (b.r - a.r) * t + 0.5), -- 69
		math.floor(a.g + (b.g - a.g) * t + 0.5), -- 70
		math.floor(a.b + (b.b - a.b) * t + 0.5), -- 71
		math.floor(a.a + (b.a - a.a) * t + 0.5) -- 72
	) -- 72
end -- 67
local C_WATER_HI = Color(126, 166, 156, 255) -- 76
local C_WATER_LO = Color(58, 92, 88, 255) -- 77
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 79
local FONT_M = "Font/SourceHanSerifSC-Medium.ttf" -- 80
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 81
local THUD = "Audio/lv2_thud2.wav" -- 83
local SOUR = "Audio/lv2_miss.wav" -- 84
local FIELD_DEF = { -- 92
	{ -- 93
		cn = "甲", -- 93
		c0 = 1, -- 93
		r0 = 1, -- 93
		c1 = 12, -- 93
		r1 = 5 -- 93
	}, -- 93
	{ -- 94
		cn = "乙", -- 94
		c0 = 16, -- 94
		r0 = 1, -- 94
		c1 = 32, -- 94
		r1 = 5 -- 94
	}, -- 94
	{ -- 95
		cn = "丙", -- 95
		c0 = 36, -- 95
		r0 = 1, -- 95
		c1 = 42, -- 95
		r1 = 5 -- 95
	}, -- 95
	{ -- 96
		cn = "丁", -- 96
		c0 = 1, -- 96
		r0 = 8, -- 96
		c1 = 7, -- 96
		r1 = 13 -- 96
	}, -- 96
	{ -- 97
		cn = "戊", -- 97
		c0 = 11, -- 97
		r0 = 8, -- 97
		c1 = 27, -- 97
		r1 = 13 -- 97
	}, -- 97
	{ -- 98
		cn = "己", -- 98
		c0 = 31, -- 98
		r0 = 8, -- 98
		c1 = 42, -- 98
		r1 = 13 -- 98
	}, -- 98
	{ -- 99
		cn = "庚", -- 99
		c0 = 1, -- 99
		r0 = 16, -- 99
		c1 = 19, -- 99
		r1 = 20 -- 99
	}, -- 99
	{ -- 100
		cn = "辛", -- 100
		c0 = 23, -- 100
		r0 = 16, -- 100
		c1 = 42, -- 100
		r1 = 20 -- 100
	} -- 100
} -- 100
local GATES = { -- 103
	{c = 13, r = 3, f = 0, side = "w"}, -- 104
	{c = 15, r = 3, f = 1, side = "e"}, -- 105
	{c = 33, r = 3, f = 1, side = "w"}, -- 106
	{c = 35, r = 3, f = 2, side = "e"}, -- 107
	{c = 8, r = 10, f = 3, side = "w"}, -- 108
	{c = 10, r = 10, f = 4, side = "e"}, -- 109
	{c = 28, r = 10, f = 4, side = "w"}, -- 110
	{c = 30, r = 10, f = 5, side = "e"}, -- 111
	{c = 20, r = 18, f = 6, side = "w"}, -- 112
	{c = 22, r = 18, f = 7, side = "e"} -- 113
} -- 113
local DIRV = {u = {c = 0, r = -1}, d = {c = 0, r = 1}, l = {c = -1, r = 0}, r = {c = 1, r = 0}} -- 116
local OPP = {u = "d", d = "u", l = "r", r = "l"} -- 119
local function inField(c, r) -- 121
	do -- 121
		local i = 0 -- 122
		while i < #FIELD_DEF do -- 122
			local f = FIELD_DEF[i + 1] -- 123
			if c >= f.c0 and c <= f.c1 and r >= f.r0 and r <= f.r1 then -- 123
				return i -- 124
			end -- 124
			i = i + 1 -- 122
		end -- 122
	end -- 122
	return -1 -- 126
end -- 121
local function isCh(c, r) -- 128
	return c >= 0 and r >= 0 and c < COLS and r < ROWS and inField(c, r) < 0 -- 129
end -- 128
local function isOuter(c, r) -- 130
	return r == 0 or r == ROWS - 1 or c == 0 or c == COLS - 1 -- 131
end -- 130
local function gateAt(c, r) -- 133
	for ____, g in ipairs(GATES) do -- 134
		if g.c == c and g.r == r then -- 134
			return g -- 134
		end -- 134
	end -- 134
	return nil -- 135
end -- 133
function ____exports.createLevel3Play(parent, opts) -- 154
	local spawnDitch, autoDir -- 154
	local function block(p, x, y, w, h, c, al) -- 156
		if al == nil then -- 156
			al = 1 -- 157
		end -- 157
		local s = Sprite("Image/StartUI/white.png") -- 159
		s.size = Size( -- 160
			math.abs(w), -- 160
			math.abs(h) -- 160
		) -- 160
		s.anchor = Vec2(0, 1) -- 161
		s.color = c -- 162
		s.opacity = al -- 163
		s.position = Vec2(x, H - y) -- 164
		s.visible = true -- 165
		s:addTo(p) -- 166
		return s -- 167
	end -- 156
	local function img(p, file, x, y, w, h) -- 170
		local s = Sprite(file) -- 171
		s.size = Size(w, h) -- 172
		s.anchor = Vec2(0, 1) -- 173
		s.position = Vec2(x, H - y) -- 174
		s.visible = true -- 175
		s:addTo(p) -- 176
		return s -- 177
	end -- 170
	local function label(p, font, size, c, x, y, ax, ls) -- 180
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 184
		lb.color = c -- 185
		lb.anchor = Vec2(ax, 1) -- 186
		lb.scaleX = 0.5 -- 187
		lb.scaleY = 0.5 -- 188
		lb.position = Vec2(x, H - y + size) -- 189
		if ls > 0 then -- 189
			lb.spacing = math.floor(ls * 2 + 0.5) -- 190
		end -- 190
		lb.visible = true -- 191
		lb:addTo(p) -- 192
		return lb -- 193
	end -- 180
	local layer = Node() -- 196
	layer.size = Size(W, H) -- 197
	layer.anchor = Vec2(0, 0) -- 198
	layer.position = Vec2(0, 0) -- 199
	layer:addTo(parent) -- 200
	block( -- 203
		layer, -- 203
		0, -- 203
		0, -- 203
		W, -- 203
		H, -- 203
		C_PAPER -- 203
	) -- 203
	img( -- 204
		layer, -- 204
		"Image/StartUI/lv3_rampart.png", -- 204
		0, -- 204
		0, -- 204
		1280, -- 204
		86 -- 204
	) -- 204
	img( -- 205
		layer, -- 205
		"Image/StartUI/lv3_grid.png", -- 205
		OX, -- 205
		OY, -- 205
		GW, -- 205
		GH -- 205
	) -- 205
	local dn = DrawNode() -- 208
	dn:addTo(layer) -- 209
	local ST_X0 = OX -- 212
	local ST_X1 = OX + GW -- 212
	block( -- 213
		layer, -- 213
		ST_X0, -- 213
		ST_Y, -- 213
		ST_X1 - ST_X0, -- 213
		H - ST_Y, -- 213
		Color(228, 220, 195, 255) -- 213
	) -- 213
	block( -- 214
		layer, -- 214
		ST_X0, -- 214
		ST_Y, -- 214
		ST_X1 - ST_X0, -- 214
		1, -- 214
		C_SEAM, -- 214
		0.5 -- 214
	) -- 214
	local ks = 30 -- 217
	local kg = 4 -- 217
	local kx = 128 -- 217
	local ky = 660 -- 217
	local keyDef = {{"W", kx + ks + kg, ky}, {"A", kx, ky + ks + kg}, {"S", kx + ks + kg, ky + ks + kg}, {"D", kx + 2 * (ks + kg), ky + ks + kg}} -- 219
	local function mkKey(x, y, ch) -- 226
		block( -- 227
			layer, -- 227
			x + 2, -- 227
			y + 2, -- 227
			ks, -- 227
			ks, -- 227
			C_DEEP, -- 227
			0.14 -- 227
		) -- 227
		block( -- 228
			layer, -- 228
			x, -- 228
			y, -- 228
			ks, -- 228
			ks, -- 228
			Color(252, 247, 232, 255) -- 228
		) -- 228
		block( -- 229
			layer, -- 229
			x, -- 229
			y, -- 229
			ks, -- 229
			1.4, -- 229
			C_INK, -- 229
			0.62 -- 229
		) -- 229
		block( -- 230
			layer, -- 230
			x, -- 230
			y + ks - 1.4, -- 230
			ks, -- 230
			1.4, -- 230
			C_INK, -- 230
			0.62 -- 230
		) -- 230
		block( -- 231
			layer, -- 231
			x, -- 231
			y, -- 231
			1.4, -- 231
			ks, -- 231
			C_INK, -- 231
			0.62 -- 231
		) -- 231
		block( -- 232
			layer, -- 232
			x + ks - 1.4, -- 232
			y, -- 232
			1.4, -- 232
			ks, -- 232
			C_INK, -- 232
			0.62 -- 232
		) -- 232
		label( -- 233
			layer, -- 233
			FONT_B, -- 233
			15, -- 233
			C_DEEP, -- 233
			x + ks / 2, -- 233
			y + 21, -- 233
			0.5, -- 233
			0 -- 233
		).text = ch -- 233
	end -- 226
	for ____, kd in ipairs(keyDef) do -- 235
		mkKey(kd[2], kd[3], kd[1]) -- 235
	end -- 235
	local rkx = kx + 3 * (ks + kg) + 10 -- 237
	mkKey(rkx, ky + ks + kg, "R") -- 238
	label( -- 241
		layer, -- 241
		FONT_B, -- 241
		13, -- 241
		Color(36, 73, 70, 230), -- 241
		kx, -- 241
		ky + 2 * (ks + kg) + 28, -- 241
		0, -- 241
		0.8 -- 241
	).text = "WASD 改道　R 重开" -- 241
	local rows = { -- 245
		{"改道", "水只往前，你能改的只有方向。"}, -- 246
		{"选边", "贴哪边过田口，哪边的田才涨水。"}, -- 247
		{"带水", "续命 2/3/4 格，升档 3/4/5 格；短了只续命，不会升。"}, -- 248
		{"撞岸", "水头断两格；见底了就卡住半秒。"}, -- 249
		{"旱退", "久了不灌就退档，退到干就荒了。"}, -- 250
		{"水沟", "踩上去多带一格，满六格就没了。"} -- 251
	} -- 251
	do -- 251
		local i = 0 -- 253
		while i < #rows do -- 253
			local y = 656 + i * 21 -- 254
			block( -- 255
				layer, -- 255
				290, -- 255
				y - 11, -- 255
				4, -- 255
				13, -- 255
				C_TEAL -- 255
			) -- 255
			label( -- 256
				layer, -- 256
				FONT_M, -- 256
				13, -- 256
				C_DEEP, -- 256
				303, -- 256
				y, -- 256
				0, -- 256
				1.5 -- 256
			).text = rows[i + 1][1] -- 256
			label( -- 257
				layer, -- 257
				FONT_R, -- 257
				12.5, -- 257
				Color(36, 73, 70, 209), -- 257
				346, -- 257
				y, -- 257
				0, -- 257
				0.3 -- 257
			).text = rows[i + 1][2] -- 257
			i = i + 1 -- 253
		end -- 253
	end -- 253
	block( -- 261
		layer, -- 261
		768, -- 261
		ST_Y + 10, -- 261
		1, -- 261
		H - 10 - (ST_Y + 10), -- 261
		C_SEAM, -- 261
		0.42 -- 261
	) -- 261
	local wzSmall = img( -- 264
		layer, -- 264
		"Image/StartUI/face_wave.png", -- 264
		1134, -- 264
		800 - 134, -- 264
		100, -- 264
		134 -- 264
	) -- 264
	local panelRoot = Node() -- 268
	panelRoot.size = Size(W, H) -- 269
	panelRoot.anchor = Vec2(0, 0) -- 270
	panelRoot.position = Vec2(0, 0) -- 271
	panelRoot:addTo(layer) -- 272
	block( -- 274
		panelRoot, -- 274
		792, -- 274
		690, -- 274
		332, -- 274
		108, -- 274
		Color(252, 247, 232, 255) -- 274
	) -- 274
	block( -- 275
		panelRoot, -- 275
		792, -- 275
		690, -- 275
		332, -- 275
		1, -- 275
		C_SEAM, -- 275
		0.9 -- 275
	) -- 275
	block( -- 276
		panelRoot, -- 276
		792, -- 276
		797, -- 276
		332, -- 276
		1, -- 276
		C_SEAM, -- 276
		0.9 -- 276
	) -- 276
	block( -- 277
		panelRoot, -- 277
		792, -- 277
		690, -- 277
		1, -- 277
		108, -- 277
		C_SEAM, -- 277
		0.9 -- 277
	) -- 277
	block( -- 278
		panelRoot, -- 278
		1123, -- 278
		690, -- 278
		1, -- 278
		108, -- 278
		C_SEAM, -- 278
		0.9 -- 278
	) -- 278
	label( -- 279
		panelRoot, -- 279
		FONT_R, -- 279
		10.5, -- 279
		Color(36, 73, 70, 107), -- 279
		806, -- 279
		712, -- 279
		0, -- 279
		2 -- 279
	).text = "王 梓" -- 279
	block( -- 280
		panelRoot, -- 280
		806, -- 280
		719, -- 280
		42, -- 280
		1, -- 280
		C_SEAM, -- 280
		0.55 -- 280
	) -- 280
	label( -- 286
		layer, -- 286
		FONT_B, -- 286
		26, -- 286
		C_DEEP, -- 286
		24, -- 286
		48, -- 286
		0, -- 286
		2.5 -- 286
	).text = "叁 · 引流" -- 286
	label( -- 287
		layer, -- 287
		FONT_R, -- 287
		16, -- 287
		Color(36, 73, 70, 184), -- 287
		150, -- 287
		47, -- 287
		0, -- 287
		1 -- 287
	).text = "八块田 · 每块三趟" -- 287
	label( -- 288
		layer, -- 288
		FONT_R, -- 288
		14, -- 288
		Color(36, 73, 70, 117), -- 288
		508, -- 288
		47, -- 288
		0, -- 288
		0 -- 288
	).text = "田" -- 288
	label( -- 289
		layer, -- 289
		FONT_R, -- 289
		14, -- 289
		Color(36, 73, 70, 117), -- 289
		1048, -- 289
		47, -- 289
		0, -- 289
		0 -- 289
	).text = "水量" -- 289
	local pourLb = label( -- 291
		layer, -- 291
		FONT_R, -- 291
		16, -- 291
		Color(36, 73, 70, 178), -- 291
		772, -- 291
		47, -- 291
		0, -- 291
		0.4 -- 291
	) -- 291
	local needLb = {} -- 294
	do -- 294
		local i = 0 -- 295
		while i < 8 do -- 295
			needLb[#needLb + 1] = label( -- 296
				layer, -- 296
				FONT_R, -- 296
				16, -- 296
				C_TEAL, -- 296
				0, -- 296
				0, -- 296
				1, -- 296
				0.5 -- 296
			) -- 296
			i = i + 1 -- 295
		end -- 295
	end -- 295
	local secLb = label( -- 298
		layer, -- 298
		FONT_B, -- 298
		14, -- 298
		C_DEEP, -- 298
		0, -- 298
		0, -- 298
		1, -- 298
		0.3 -- 298
	) -- 298
	local ABT_X = 940 -- 303
	local ABT_Y = 574 -- 303
	local ABT_W = 250 -- 303
	local ABT_H = 44 -- 303
	local ABT_BX = ABT_X + ABT_W - 92 -- 304
	local ABT_BY = ABT_Y + 7 -- 304
	local ABT_BW = 84 -- 304
	local ABT_BH = 30 -- 304
	local autoRoot = Node() -- 306
	autoRoot.size = Size(W, H) -- 307
	autoRoot.anchor = Vec2(0, 0) -- 308
	autoRoot.position = Vec2(0, 0) -- 309
	autoRoot.visible = false -- 310
	autoRoot:addTo(layer) -- 311
	block( -- 313
		autoRoot, -- 313
		ABT_X + 5, -- 313
		ABT_Y + 5, -- 313
		ABT_W, -- 313
		ABT_H, -- 313
		C_DEEP, -- 313
		0.9 -- 313
	) -- 313
	block( -- 314
		autoRoot, -- 314
		ABT_X, -- 314
		ABT_Y, -- 314
		ABT_W, -- 314
		ABT_H, -- 314
		C_PAPER2 -- 314
	) -- 314
	block( -- 315
		autoRoot, -- 315
		ABT_X, -- 315
		ABT_Y, -- 315
		ABT_W, -- 315
		1.2, -- 315
		C_DEEP -- 315
	) -- 315
	block( -- 316
		autoRoot, -- 316
		ABT_X, -- 316
		ABT_Y + ABT_H - 1.2, -- 316
		ABT_W, -- 316
		1.2, -- 316
		C_DEEP -- 316
	) -- 316
	block( -- 317
		autoRoot, -- 317
		ABT_X, -- 317
		ABT_Y, -- 317
		1.2, -- 317
		ABT_H, -- 317
		C_DEEP -- 317
	) -- 317
	block( -- 318
		autoRoot, -- 318
		ABT_X + ABT_W - 1.2, -- 318
		ABT_Y, -- 318
		1.2, -- 318
		ABT_H, -- 318
		C_DEEP -- 318
	) -- 318
	block( -- 319
		autoRoot, -- 319
		ABT_X + 3, -- 319
		ABT_Y + 3, -- 319
		6, -- 319
		ABT_H - 6, -- 319
		C_VERM -- 319
	) -- 319
	local abtFace = block( -- 320
		autoRoot, -- 320
		ABT_BX, -- 320
		ABT_BY, -- 320
		ABT_BW, -- 320
		ABT_BH, -- 320
		C_VERM -- 320
	) -- 320
	block( -- 321
		autoRoot, -- 321
		ABT_BX, -- 321
		ABT_BY, -- 321
		ABT_BW, -- 321
		1.8, -- 321
		C_DEEP -- 321
	) -- 321
	block( -- 322
		autoRoot, -- 322
		ABT_BX, -- 322
		ABT_BY + ABT_BH - 1.8, -- 322
		ABT_BW, -- 322
		1.8, -- 322
		C_DEEP -- 322
	) -- 322
	block( -- 323
		autoRoot, -- 323
		ABT_BX, -- 323
		ABT_BY, -- 323
		1.8, -- 323
		ABT_BH, -- 323
		C_DEEP -- 323
	) -- 323
	block( -- 324
		autoRoot, -- 324
		ABT_BX + ABT_BW - 1.8, -- 324
		ABT_BY, -- 324
		1.8, -- 324
		ABT_BH, -- 324
		C_DEEP -- 324
	) -- 324
	label( -- 325
		autoRoot, -- 325
		FONT_B, -- 325
		22, -- 325
		C_DEEP, -- 325
		ABT_X + 22, -- 325
		ABT_Y + 30, -- 325
		0, -- 325
		2 -- 325
	).text = "王梓在操作" -- 325
	label( -- 326
		autoRoot, -- 326
		FONT_B, -- 326
		19, -- 326
		C_PAPER2, -- 326
		ABT_BX + ABT_BW / 2, -- 326
		ABT_BY + 22, -- 326
		0.5, -- 326
		2 -- 326
	).text = "让我来" -- 326
	local hintLb = label( -- 327
		layer, -- 327
		FONT_R, -- 327
		13, -- 327
		Color(36, 73, 70, 230), -- 327
		810, -- 327
		748, -- 327
		0, -- 327
		0.4 -- 327
	) -- 327
	local clockLb = label( -- 328
		layer, -- 328
		FONT_B, -- 328
		14, -- 328
		C_INK, -- 328
		1108, -- 328
		712, -- 328
		1, -- 328
		1 -- 328
	) -- 328
	local pauseLb1 = label( -- 330
		layer, -- 330
		FONT_B, -- 330
		44, -- 330
		C_DEEP, -- 330
		640, -- 330
		396, -- 330
		0.5, -- 330
		8 -- 330
	) -- 330
	pauseLb1.text = "" -- 331
	local pauseLb2 = label( -- 332
		layer, -- 332
		FONT_R, -- 332
		18, -- 332
		Color(36, 73, 70, 153), -- 332
		640, -- 332
		440, -- 332
		0.5, -- 332
		1 -- 332
	) -- 332
	pauseLb2.text = "" -- 333
	local fields = {} -- 336
	local water = {} -- 337
	local dir = "d" -- 338
	local pendingQ = {} -- 339
	local len = LEN_0 -- 340
	local ditches = {} -- 341
	local ditchT = 0 -- 342
	local speed = SPD_0 -- 343
	local stuck = false -- 344
	local stun = 0 -- 345
	local acc = 0 -- 346
	local startDelay = START_DELAY -- 347
	local poured = 0 -- 348
	local done = 0 -- 349
	local t = 0 -- 350
	local hint = "" -- 351
	local hintT = 0 -- 352
	local flash = 0 -- 353
	local flashAt = nil -- 354
	local phase = "intro" -- 355
	local finished = false -- 356
	local paused = false -- 357
	local ptrX = -999 -- 358
	local ptrY = -999 -- 358
	local rx = 0 -- 359
	local ry = 0 -- 359
	local rInit = false -- 359
	local autoOn = opts.auto == true -- 360
	local wantBegin = false -- 361
	local wantRestart = false -- 362
	local overT = 0 -- 363
	local deadIdx = -1 -- 364
	local wantFinish = false -- 365
	local function reset() -- 368
		fields = __TS__ArrayMap( -- 369
			FIELD_DEF, -- 369
			function(____, f) return { -- 369
				cn = f.cn, -- 370
				c0 = f.c0, -- 370
				r0 = f.r0, -- 370
				c1 = f.c1, -- 370
				r1 = f.r1, -- 370
				lv = 0, -- 371
				timer = NEVER_GRACE, -- 371
				everWatered = false, -- 371
				refuseT = 0 -- 371
			} end -- 371
		) -- 371
		water = {{c = 14, r = 0}} -- 374
		while #water < len do -- 374
			water[#water + 1] = {c = 14, r = -1} -- 375
		end -- 375
		ditches = {} -- 376
		ditchT = 0 -- 377
		rInit = false -- 378
		dir = "d" -- 379
		pendingQ = {} -- 380
		len = LEN_0 -- 381
		speed = SPD_0 -- 382
		stuck = false -- 383
		stun = 0 -- 384
		acc = 0 -- 385
		startDelay = START_DELAY -- 386
		poured = 0 -- 387
		done = 0 -- 388
		t = 0 -- 389
		hint = "把水引进田口。撞岸会断尾。" -- 390
		hintT = 3.2 -- 391
		flash = 0 -- 392
		flashAt = nil -- 393
		phase = "play" -- 394
		paused = false -- 395
		finished = false -- 396
		spawnDitch() -- 397
		overT = 0 -- 398
		deadIdx = -1 -- 399
	end -- 368
	local function say(s, dur) -- 402
		hint = s -- 402
		hintT = dur -- 402
	end -- 402
	spawnDitch = function() -- 407
		if len >= LEN_MAX then -- 407
			return -- 408
		end -- 408
		if #ditches >= DITCH_MAX then -- 408
			return -- 409
		end -- 409
		local pool = {} -- 410
		for ____, r in ipairs(DITCH_ROWS) do -- 411
			do -- 411
				local c = 1 -- 412
				while c < COLS - 1 do -- 412
					do -- 412
						if not isCh(c, r) then -- 412
							goto __continue37 -- 413
						end -- 413
						if gateAt(c, r) ~= nil then -- 413
							goto __continue37 -- 414
						end -- 414
						if __TS__ArraySome( -- 414
							water, -- 415
							function(____, w) return w.c == c and w.r == r end -- 415
						) then -- 415
							goto __continue37 -- 415
						end -- 415
						if __TS__ArraySome( -- 415
							ditches, -- 416
							function(____, d) return d.c == c and d.r == r end -- 416
						) then -- 416
							goto __continue37 -- 416
						end -- 416
						pool[#pool + 1] = {c = c, r = r} -- 417
					end -- 417
					::__continue37:: -- 417
					c = c + 1 -- 412
				end -- 412
			end -- 412
		end -- 412
		if #pool == 0 then -- 412
			return -- 420
		end -- 420
		ditches[#ditches + 1] = pool[math.floor(math.random() * #pool) + 1] -- 421
	end -- 407
	local function clearDitches() -- 424
		ditches = {} -- 424
		ditchT = 0 -- 424
	end -- 424
	local function ditchTick(dt) -- 426
		if len >= LEN_MAX then -- 426
			if #ditches > 0 then -- 426
				clearDitches() -- 427
			end -- 427
			return -- 427
		end -- 427
		if #ditches >= DITCH_MAX then -- 427
			return -- 428
		end -- 428
		if #ditches == 0 then -- 428
			spawnDitch() -- 430
			ditchT = 0 -- 430
			return -- 430
		end -- 430
		ditchT = ditchT + dt -- 431
		while ditchT >= DITCH_T do -- 431
			ditchT = ditchT - DITCH_T -- 432
			spawnDitch() -- 432
		end -- 432
	end -- 426
	local function eatDitch(c, r) -- 435
		local idx = -1 -- 436
		do -- 436
			local i = 0 -- 437
			while i < #ditches do -- 437
				if ditches[i + 1].c == c and ditches[i + 1].r == r then -- 437
					idx = i -- 438
					break -- 438
				end -- 438
				i = i + 1 -- 437
			end -- 437
		end -- 437
		if idx < 0 then -- 437
			return -- 440
		end -- 440
		__TS__ArraySplice(ditches, idx, 1) -- 441
		ditchT = 0 -- 442
		if len < LEN_MAX then -- 442
			len = math.min(LEN_MAX, len + 1) -- 444
			say( -- 445
				((("捡到一股水，多带一格（" .. tostring(len)) .. " / ") .. tostring(LEN_MAX)) .. "）", -- 445
				2 -- 445
			) -- 445
			if len >= LEN_MAX then -- 445
				clearDitches() -- 446
			end -- 446
		end -- 446
	end -- 435
	local function pourInto(f) -- 450
		if f.lv >= NEED then -- 450
			return -- 451
		end -- 451
		f.lv = f.lv + 1 -- 452
		f.everWatered = true -- 453
		poured = poured + 1 -- 454
		Audio:play(THUD) -- 455
		if f.lv >= NEED then -- 455
			f.timer = math.huge -- 457
			done = done + 1 -- 458
			speed = math.min(SPD_MAX, SPD_0 + done * SPD_STEP) -- 459
			say(f.cn .. " 熟了。", 2) -- 460
			if done >= #FIELD_DEF then -- 460
				phase = "win" -- 461
				overT = 0 -- 461
			end -- 461
		else -- 461
			f.timer = WIN_KEEP -- 463
			say( -- 464
				((((f.cn .. " 吃到一趟（") .. tostring(f.lv)) .. " / 3），下次要 ") .. tostring(NEED_LEN[f.lv + 1])) .. " 格", -- 464
				1.8 -- 465
			) -- 465
		end -- 465
	end -- 450
	local function refuse(f) -- 469
		if f.refuseT > 0 then -- 469
			return -- 470
		end -- 470
		f.refuseT = 0.9 -- 471
		Audio:play(SOUR) -- 472
		say( -- 473
			((((("水不够。" .. f.cn) .. " 要 ") .. tostring(NEED_LEN[f.lv + 1])) .. " 格，你只有 ") .. tostring(len)) .. " 格。", -- 473
			2.2 -- 473
		) -- 473
	end -- 469
	local function breach(h) -- 476
		stuck = true -- 477
		flash = 0.45 -- 478
		flashAt = h -- 479
		Audio:play(SOUR) -- 480
		if len <= 1 then -- 480
			stun = STUN -- 482
			say("水见底了，卡住了半拍。", 2.2) -- 483
		else -- 483
			len = math.max(1, len - CUT) -- 485
			while #water > len do -- 485
				table.remove(water) -- 486
			end -- 486
			say( -- 487
				((("水头撞岸了，断掉两格（" .. tostring(len)) .. " / ") .. tostring(LEN_MAX)) .. "）", -- 487
				2.2 -- 487
			) -- 487
		end -- 487
	end -- 476
	local function enqueue(d) -- 495
		if d == OPP[dir] then -- 495
			return -- 496
		end -- 496
		local last = #pendingQ > 0 and pendingQ[#pendingQ] or dir -- 497
		if d == last then -- 497
			return -- 498
		end -- 498
		if #pendingQ >= 2 then -- 498
			table.remove(pendingQ, 1) -- 499
		end -- 499
		pendingQ[#pendingQ + 1] = d -- 500
	end -- 495
	local function step() -- 503
		if autoOn then -- 503
			local ad = autoDir() -- 505
			if ad ~= nil then -- 505
				enqueue(ad) -- 506
			end -- 506
		end -- 506
		if #pendingQ > 0 then -- 506
			local d = table.remove(pendingQ, 1) -- 510
			if d ~= OPP[dir] then -- 510
				dir = d -- 511
			end -- 511
		end -- 511
		local h = water[1] -- 514
		local v = DIRV[dir] -- 515
		local nc = h.c + v.c -- 516
		local nr = h.r + v.r -- 516
		if not isCh(nc, nr) then -- 516
			breach(h) -- 518
			return -- 518
		end -- 518
		__TS__ArrayUnshift(water, {c = nc, r = nr}) -- 520
		while #water > len do -- 520
			table.remove(water) -- 521
		end -- 521
		eatDitch(nc, nr) -- 522
		local hit = {} -- 525
		for ____, s in ipairs(water) do -- 526
			do -- 526
				local g = gateAt(s.c, s.r) -- 527
				if g == nil or __TS__ArrayIndexOf(hit, g.f) >= 0 then -- 527
					goto __continue82 -- 528
				end -- 528
				local f = fields[g.f + 1] -- 529
				if f == nil or f.lv >= NEED then -- 529
					goto __continue82 -- 530
				end -- 530
				hit[#hit + 1] = g.f -- 531
				if len < RESET_LEN[f.lv + 1] then -- 531
					refuse(f) -- 532
					goto __continue82 -- 532
				end -- 532
				if len < NEED_LEN[f.lv + 1] then -- 532
					f.timer = WIN_KEEP -- 534
					say( -- 535
						((((f.cn .. " 续了一趟（") .. tostring(len)) .. " 格），升档要 ") .. tostring(NEED_LEN[f.lv + 1])) .. " 格", -- 535
						1.8 -- 536
					) -- 536
					goto __continue82 -- 537
				end -- 537
				pourInto(f) -- 539
				if phase ~= "play" then -- 539
					return -- 540
				end -- 540
			end -- 540
			::__continue82:: -- 540
		end -- 540
	end -- 503
	autoDir = function() -- 548
		local h = water[1] -- 549
		local function key(c, r) -- 550
			return (tostring(c) .. ",") .. tostring(r) -- 550
		end -- 550
		local dist = __TS__New(Map) -- 551
		local first = __TS__New(Map) -- 552
		local qc = {h.c} -- 553
		local qr = {h.r} -- 554
		dist:set( -- 555
			key(h.c, h.r), -- 555
			0 -- 555
		) -- 555
		do -- 555
			local qi = 0 -- 556
			while qi < #qc do -- 556
				local c = qc[qi + 1] -- 557
				local r = qr[qi + 1] -- 557
				local dirs = {"u", "d", "l", "r"} -- 558
				for ____, k in ipairs(dirs) do -- 559
					do -- 559
						if c == h.c and r == h.r and k == OPP[dir] then -- 559
							goto __continue93 -- 560
						end -- 560
						local v = DIRV[k] -- 561
						local nc = c + v.c -- 562
						local nr = r + v.r -- 562
						if not isCh(nc, nr) then -- 562
							goto __continue93 -- 563
						end -- 563
						local kk = key(nc, nr) -- 564
						if dist:has(kk) then -- 564
							goto __continue93 -- 565
						end -- 565
						dist:set( -- 566
							kk, -- 566
							dist:get(key(c, r)) + 1 -- 566
						) -- 566
						first:set( -- 567
							kk, -- 567
							dist:get(key(c, r)) == 0 and k or first:get(key(c, r)) -- 567
						) -- 567
						qc[#qc + 1] = nc -- 568
						qr[#qr + 1] = nr -- 569
					end -- 569
					::__continue93:: -- 569
				end -- 569
				qi = qi + 1 -- 556
			end -- 556
		end -- 556
		local best = nil -- 574
		local bestScore = -1000000000 -- 575
		for ____, f in ipairs(fields) do -- 576
			do -- 576
				if f.lv >= NEED then -- 576
					goto __continue98 -- 577
				end -- 577
				if len < NEED_LEN[f.lv + 1] then -- 577
					goto __continue98 -- 578
				end -- 578
				for ____, g in ipairs(GATES) do -- 579
					do -- 579
						if g.f ~= __TS__ArrayIndexOf(fields, f) then -- 579
							goto __continue101 -- 580
						end -- 580
						local kk = key(g.c, g.r) -- 581
						if not dist:has(kk) then -- 581
							goto __continue101 -- 582
						end -- 582
						local d = dist:get(kk) -- 583
						if d == 0 then -- 583
							goto __continue101 -- 584
						end -- 584
						local tm = f.timer == math.huge and NEVER_GRACE or f.timer -- 585
						local score = NEVER_GRACE - tm - d * 1.6 -- 586
						if score > bestScore then -- 586
							bestScore = score -- 587
							best = first:get(kk) -- 587
						end -- 587
					end -- 587
					::__continue101:: -- 587
				end -- 587
			end -- 587
			::__continue98:: -- 587
		end -- 587
		if best ~= nil then -- 587
			return best -- 590
		end -- 590
		if len < LEN_MAX and #ditches > 0 then -- 590
			local bd = 1000000000 -- 594
			local bk = nil -- 595
			for ____, d in ipairs(ditches) do -- 596
				do -- 596
					local kk = key(d.c, d.r) -- 597
					if not dist:has(kk) then -- 597
						goto __continue110 -- 598
					end -- 598
					local dd = dist:get(kk) -- 599
					if dd < bd then -- 599
						bd = dd -- 600
						bk = first:get(kk) -- 600
					end -- 600
				end -- 600
				::__continue110:: -- 600
			end -- 600
			if bk ~= nil and bd > 0 then -- 600
				return bk -- 602
			end -- 602
		end -- 602
		local v = DIRV[dir] -- 606
		if isCh(h.c + v.c, h.r + v.r) then -- 606
			return dir -- 607
		end -- 607
		for ____, k in ipairs({"u", "d", "l", "r"}) do -- 608
			do -- 608
				if k == OPP[dir] then -- 608
					goto __continue116 -- 609
				end -- 609
				local w = DIRV[k] -- 610
				if isCh(h.c + w.c, h.r + w.r) then -- 610
					return k -- 611
				end -- 611
			end -- 611
			::__continue116:: -- 611
		end -- 611
		return nil -- 613
	end -- 548
	local function press(d) -- 616
		if phase == "intro" then -- 616
			wantBegin = true -- 617
			return -- 617
		end -- 617
		if phase ~= "play" or paused then -- 617
			return -- 618
		end -- 618
		if stuck then -- 618
			if stun > 0 then -- 618
				enqueue(d) -- 621
				return -- 621
			end -- 621
			local h = water[1] -- 622
			local v = DIRV[d] -- 622
			if isCh(h.c + v.c, h.r + v.r) and d ~= OPP[dir] then -- 622
				dir = d -- 624
				stuck = false -- 624
				acc = 0 -- 624
				stun = 0 -- 624
				pendingQ = {} -- 624
			end -- 624
			return -- 626
		end -- 626
		enqueue(d) -- 628
	end -- 616
	local function tick(dt) -- 632
		if phase == "win" or phase == "lose" then -- 632
			overT = overT + dt -- 633
			return -- 633
		end -- 633
		if phase ~= "play" then -- 633
			return -- 634
		end -- 634
		t = t + dt -- 635
		if hintT > 0 then -- 635
			hintT = hintT - dt -- 636
		end -- 636
		if flash > 0 then -- 636
			flash = flash - dt -- 637
		end -- 637
		for ____, f in ipairs(fields) do -- 638
			if f.refuseT > 0 then -- 638
				f.refuseT = f.refuseT - dt -- 638
			end -- 638
		end -- 638
		if startDelay > 0 then -- 638
			startDelay = startDelay - dt -- 640
			return -- 640
		end -- 640
		ditchTick(dt) -- 642
		if stun > 0 then -- 642
			stun = stun - dt -- 645
		else -- 645
			acc = acc + dt -- 647
			local per = 1 / speed -- 648
			while acc >= per do -- 648
				acc = acc - per -- 650
				step() -- 651
				if phase ~= "play" then -- 651
					break -- 652
				end -- 652
			end -- 652
		end -- 652
		do -- 652
			local i = 0 -- 657
			while i < #fields do -- 657
				do -- 657
					local f = fields[i + 1] -- 658
					if f.lv >= NEED then -- 658
						goto __continue140 -- 659
					end -- 659
					f.timer = f.timer - dt -- 660
					if f.timer <= 0 then -- 660
						if f.lv == 0 then -- 660
							phase = "lose" -- 662
							overT = 0 -- 662
							deadIdx = i -- 662
							return -- 662
						end -- 662
						f.lv = f.lv - 1 -- 663
						poured = math.max(0, poured - 1) -- 666
						f.timer = f.lv == 0 and DRY_GRACE or WIN_KEEP -- 667
					end -- 667
				end -- 667
				::__continue140:: -- 667
				i = i + 1 -- 657
			end -- 657
		end -- 657
	end -- 632
	local function cw(c) -- 673
		return OX + c * G -- 673
	end -- 673
	local function ch(r) -- 674
		return OY + r * G -- 674
	end -- 674
	local function smoothHead(dt) -- 678
		local h0 = water[1] -- 679
		if h0 == nil then -- 679
			return -- 680
		end -- 680
		local tx = OX + h0.c * G -- 681
		local ty = OY + h0.r * G -- 682
		if not rInit or math.abs(rx - tx) > G * 3 or math.abs(ry - ty) > G * 3 then -- 682
			rx = tx -- 685
			ry = ty -- 685
			rInit = true -- 685
			return -- 686
		end -- 686
		local k = math.min(1, dt * 16) -- 688
		rx = rx + (tx - rx) * k -- 689
		ry = ry + (ty - ry) * k -- 690
	end -- 678
	local function draw() -- 693
		dn:clear() -- 694
		for ____, f in ipairs(fields) do -- 697
			do -- 697
				if f.lv <= 0 then -- 697
					goto __continue150 -- 698
				end -- 698
				local x = cw(f.c0) -- 699
				local y = ch(f.r0) -- 699
				local w = (f.c1 - f.c0 + 1) * G -- 700
				local h = (f.r1 - f.r0 + 1) * G -- 700
				local col = f.lv >= NEED and C_LV3 or (f.lv == 2 and C_LV2 or C_LV1) -- 701
				dn:drawRect( -- 702
					Rect(x, H - y - h, w, h), -- 702
					col, -- 702
					0 -- 702
				) -- 702
			end -- 702
			::__continue150:: -- 702
		end -- 702
		for ____, f in ipairs(fields) do -- 707
			do -- 707
				if f.lv <= 0 then -- 707
					goto __continue153 -- 708
				end -- 708
				local x = cw(f.c0) -- 709
				local y = ch(f.r0) -- 709
				local w = (f.c1 - f.c0 + 1) * G -- 710
				local h = (f.r1 - f.r0 + 1) * G -- 710
				if f.lv == 1 then -- 710
					do -- 710
						local r = 1 -- 712
						while r <= 3 do -- 712
							local ly = y + h * r / 4 -- 713
							dn:drawSegment( -- 714
								Vec2(x + 6, H - ly), -- 714
								Vec2(x + w - 6, H - ly), -- 714
								1.2, -- 714
								Color(58, 92, 88, 46) -- 714
							) -- 714
							r = r + 1 -- 712
						end -- 712
					end -- 712
					do -- 712
						local c = 1 -- 716
						while c <= 4 do -- 716
							local lx = x + w * c / 5 -- 717
							local ly = y + h * (c % 2 == 0 and 0.34 or 0.66) -- 718
							dn:drawSegment( -- 719
								Vec2(lx, H - (ly + 5)), -- 719
								Vec2(lx - 9, H - (ly - 3)), -- 719
								1.6, -- 719
								Color(58, 92, 88, 38) -- 719
							) -- 719
							c = c + 1 -- 716
						end -- 716
					end -- 716
				else -- 716
					local rows = 4 -- 722
					local step = f.lv >= NEED and 14 or 18 -- 723
					local col = f.lv >= NEED and Color(126, 112, 56, 104) or Color(52, 86, 74, 92) -- 724
					local tall = f.lv >= NEED and 5 or 4 -- 725
					do -- 725
						local r = 0 -- 726
						while r < rows do -- 726
							local ly = y + h * (r + 0.5) / rows -- 727
							do -- 727
								local lx = x + 8 -- 728
								while lx < x + w - 8 do -- 728
									dn:drawSegment( -- 729
										Vec2(lx, H - (ly + tall)), -- 729
										Vec2(lx, H - (ly - tall)), -- 729
										1.5, -- 729
										col -- 729
									) -- 729
									lx = lx + step -- 728
								end -- 728
							end -- 728
							r = r + 1 -- 726
						end -- 726
					end -- 726
				end -- 726
			end -- 726
			::__continue153:: -- 726
		end -- 726
		for ____, f in ipairs(fields) do -- 737
			do -- 737
				if f.lv >= NEED then -- 737
					goto __continue166 -- 738
				end -- 738
				local x = cw(f.c0) -- 739
				local y = ch(f.r0) -- 739
				local w = (f.c1 - f.c0 + 1) * G -- 740
				local h = (f.r1 - f.r0 + 1) * G -- 740
				local base = f.lv == 2 and C_LV2 or C_LV1 -- 741
				if f.lv > 0 then -- 741
					local remain = math.min( -- 743
						1, -- 743
						math.max(0, f.timer / WIN_KEEP) -- 743
					) -- 743
					if remain >= 0.5 then -- 743
						goto __continue166 -- 744
					end -- 744
					local t2 = math.max(2, (0.5 - remain) / 0.5 * 9) -- 745
					local dry = mixColor(base, C_GOLD, 0.5) -- 746
					dn:drawRect( -- 747
						Rect(x, H - y - t2, w, t2), -- 747
						dry, -- 747
						0 -- 747
					) -- 747
					dn:drawRect( -- 748
						Rect(x, H - y - h, w, t2), -- 748
						dry, -- 748
						0 -- 748
					) -- 748
					dn:drawRect( -- 749
						Rect(x, H - y - h, t2, h), -- 749
						dry, -- 749
						0 -- 749
					) -- 749
					dn:drawRect( -- 750
						Rect(x + w - t2, H - y - h, t2, h), -- 750
						dry, -- 750
						0 -- 750
					) -- 750
					local t3 = t2 * 0.52 -- 751
					local deep2 = mixColor( -- 752
						mixColor(base, C_SAND, 0.7), -- 752
						C_GOLD, -- 752
						0.3 -- 752
					) -- 752
					dn:drawRect( -- 753
						Rect(x, H - y - t3, w, t3), -- 753
						deep2, -- 753
						0 -- 753
					) -- 753
					dn:drawRect( -- 754
						Rect(x, H - y - h, w, t3), -- 754
						deep2, -- 754
						0 -- 754
					) -- 754
					dn:drawRect( -- 755
						Rect(x, H - y - h, t3, h), -- 755
						deep2, -- 755
						0 -- 755
					) -- 755
					dn:drawRect( -- 756
						Rect(x + w - t3, H - y - h, t3, h), -- 756
						deep2, -- 756
						0 -- 756
					) -- 756
					if remain < 0.32 then -- 756
						dn:drawRect( -- 758
							Rect(x + 2.5, H - y - h + 2.5, w - 5, h - 5), -- 758
							Color(0, 0, 0, 0), -- 758
							1.6, -- 758
							Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 242) -- 759
						) -- 759
					end -- 759
				elseif f.everWatered then -- 759
					local remain = math.min( -- 762
						1, -- 762
						math.max(0, f.timer / DRY_GRACE) -- 762
					) -- 762
					local tint = mixColor(C_SAND, C_GOLD, 0.55) -- 763
					dn:drawRect( -- 764
						Rect(x, H - y - h, w, h), -- 764
						Color( -- 764
							tint.r, -- 764
							tint.g, -- 764
							tint.b, -- 764
							math.floor(255 * (0.1 + 0.26 * (1 - remain)) + 0.5) -- 764
						), -- 764
						0 -- 764
					) -- 764
					if remain < 0.5 then -- 764
						dn:drawRect( -- 766
							Rect(x + 2.5, H - y - h + 2.5, w - 5, h - 5), -- 766
							Color(0, 0, 0, 0), -- 766
							1.8, -- 766
							Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 242) -- 767
						) -- 767
					end -- 767
				end -- 767
			end -- 767
			::__continue166:: -- 767
		end -- 767
		local urgent = -1 -- 777
		secLb.text = "" -- 778
		do -- 778
			local i = 0 -- 779
			while i < #fields do -- 779
				do -- 779
					local f = fields[i + 1] -- 780
					if f.lv >= NEED then -- 780
						goto __continue175 -- 781
					end -- 781
					if urgent < 0 or f.timer < fields[urgent + 1].timer then -- 781
						urgent = i -- 782
					end -- 782
				end -- 782
				::__continue175:: -- 782
				i = i + 1 -- 779
			end -- 779
		end -- 779
		do -- 779
			local i = 0 -- 784
			while i < #fields do -- 784
				do -- 784
					local f = fields[i + 1] -- 785
					local x = cw(f.c0) -- 786
					local y = ch(f.r0) -- 786
					local w = (f.c1 - f.c0 + 1) * G -- 787
					local h = (f.r1 - f.r0 + 1) * G -- 787
					if f.lv >= NEED then -- 787
						needLb[i + 1].text = "" -- 788
						goto __continue179 -- 788
					end -- 788
					local span = f.lv > 0 and WIN_KEEP or (f.everWatered and DRY_GRACE or NEVER_GRACE) -- 790
					local remain = math.min( -- 791
						1, -- 791
						math.max(0, f.timer / span) -- 791
					) -- 791
					local dryBack = f.lv == 0 and f.everWatered -- 792
					local never = f.lv == 0 and not f.everWatered -- 793
					local bx = x + 10 -- 795
					local by = y + 13 -- 795
					local bw = w - 20 -- 795
					local bh = 7 -- 795
					dn:drawRect( -- 796
						Rect(bx, H - by - bh, bw, bh), -- 796
						Color(23, 51, 48, never and 61 or 112), -- 796
						0 -- 796
					) -- 796
					local col = never and mixColor(C_PAPER, C_DEEP, 0.44) or (dryBack and mixColor(C_SAND, C_GOLD, 0.55) or mixColor( -- 797
						Color(243, 234, 211, 255), -- 799
						C_SAND, -- 799
						0.28 -- 799
					)) -- 799
					if remain < 0.3 then -- 799
						col = C_GOLD -- 800
					end -- 800
					dn:drawRect( -- 801
						Rect( -- 801
							bx + 1, -- 801
							H - by - bh + 1, -- 801
							math.max(0, (bw - 2) * remain), -- 801
							bh - 2 -- 801
						), -- 801
						col, -- 801
						0 -- 801
					) -- 801
					do -- 801
						local sx = bx + 22 -- 802
						while sx < bx + bw - 1 do -- 802
							dn:drawRect( -- 803
								Rect(sx, H - by - bh + 1.5, 1, bh - 3), -- 803
								Color(23, 51, 48, 38), -- 803
								0 -- 803
							) -- 803
							sx = sx + 22 -- 802
						end -- 802
					end -- 802
					dn:drawRect( -- 805
						Rect(bx + 0.5, H - by - bh + 0.5, bw - 1, bh - 1), -- 805
						Color(0, 0, 0, 0), -- 805
						1, -- 805
						Color(36, 73, 70, 87) -- 806
					) -- 806
					if i == urgent and remain < 0.55 then -- 806
						local tw = 34 -- 810
						local tx2 = math.max(bx + (bw - 2) * remain + 4, bx + bw - tw) -- 811
						local blink = remain < 0.16 and 0.4 + 0.6 * math.abs(math.sin(t * 5.5)) or 0.92 -- 812
						dn:drawRect( -- 813
							Rect(tx2, H - by - bh - 2 - 14, tw, 14), -- 813
							Color(243, 234, 211, 224), -- 813
							0 -- 813
						) -- 813
						secLb.text = tostring(math.ceil(f.timer)) .. "s" -- 814
						secLb.position = Vec2(tx2 + tw - 3, H - (by + bh + 2 + 13) + 14) -- 815
						secLb.color = Color( -- 816
							23, -- 816
							51, -- 816
							48, -- 816
							math.floor(255 * blink + 0.5) -- 816
						) -- 816
					end -- 816
					do -- 816
						local k = 0 -- 820
						while k < NEED do -- 820
							local px2 = x + 11 + k * 8 -- 821
							local py2 = y + 24 -- 821
							if k < f.lv then -- 821
								dn:drawRect( -- 823
									Rect(px2, H - py2 - 6, 6, 6), -- 823
									C_GOLD, -- 823
									1, -- 823
									Color(36, 73, 70, 56) -- 823
								) -- 823
							else -- 823
								dn:drawRect( -- 825
									Rect(px2, H - py2 - 6, 6, 6), -- 825
									Color(0, 0, 0, 0), -- 825
									1, -- 825
									Color(23, 51, 48, 87) -- 825
								) -- 825
							end -- 825
							k = k + 1 -- 820
						end -- 820
					end -- 820
					local n = NEED_LEN[f.lv + 1] -- 830
					local ok = len >= n -- 831
					needLb[i + 1].text = "需 " .. tostring(n) -- 832
					needLb[i + 1].color = ok and C_TEAL or Color(23, 51, 48, 140) -- 833
					needLb[i + 1].position = Vec2(x + w - 12, H - (y + h - 10) + 16) -- 834
				end -- 834
				::__continue179:: -- 834
				i = i + 1 -- 784
			end -- 784
		end -- 784
		for ____, g in ipairs(GATES) do -- 840
			do -- 840
				local f = fields[g.f + 1] -- 841
				if f == nil then -- 841
					goto __continue189 -- 842
				end -- 842
				local x = cw(g.c) -- 843
				local y = ch(g.r) -- 843
				local full = f.lv >= NEED -- 844
				local west = g.side == "w" -- 845
				local bx = west and x - 2 or x + G - 2 -- 848
				dn:drawRect( -- 849
					Rect(bx, H - y - G + 4, 4, G - 8), -- 849
					full and C_GOLD or C_DEEP, -- 849
					0 -- 849
				) -- 849
				dn:drawRect( -- 850
					Rect(bx, H - y - G + 4, 1, G - 8), -- 850
					Color(36, 73, 70, 128), -- 850
					0 -- 850
				) -- 850
				dn:drawRect( -- 851
					Rect(bx - 1, H - y - G + 3, 6, 2), -- 851
					Color(23, 51, 48, 128), -- 851
					0 -- 851
				) -- 851
				dn:drawRect( -- 852
					Rect(bx - 1, H - y - 5, 6, 2), -- 852
					Color(23, 51, 48, 128), -- 852
					0 -- 852
				) -- 852
				local okLen = len >= NEED_LEN[f.lv + 1] -- 855
				local fx = west and x - 13 or x + G + 1 -- 856
				local fy = y + G / 2 - 8 -- 857
				local fc = full and mixColor(C_GOLD, C_PAPER, 0.3) or (okLen and mixColor(C_TEAL, C_PAPER, 0.46) or Color(23, 51, 48, 148)) -- 858
				dn:drawRect( -- 861
					Rect(fx, H - fy - 16, 13, 16), -- 861
					fc, -- 861
					1, -- 861
					Color(36, 73, 70, 56) -- 861
				) -- 861
				if not full and not okLen then -- 861
					local a = f.refuseT > 0 and math.min( -- 863
						1, -- 863
						math.max(0, f.refuseT / 0.9) -- 863
					) or 0 -- 863
					dn:drawRect( -- 864
						Rect(fx + 2, H - fy - 9, 9, 2), -- 864
						Color( -- 865
							243, -- 865
							234, -- 865
							211, -- 865
							math.floor(255 * (a > 0 and 0.45 + 0.55 * a or 0.42) + 0.5) -- 865
						), -- 865
						0 -- 865
					) -- 865
				end -- 865
			end -- 865
			::__continue189:: -- 865
		end -- 865
		for ____, d in ipairs(ditches) do -- 870
			local x = cw(d.c) + 2 -- 871
			local y = ch(d.r) + 8 -- 871
			local w = G - 4 -- 872
			local h = 13 -- 872
			dn:drawRect( -- 873
				Rect(x, H - y - h, w, h), -- 873
				Color(23, 51, 48, 66), -- 873
				0 -- 873
			) -- 873
			dn:drawRect( -- 874
				Rect(x + 2, H - y - h + 2.5, w - 4, h - 5), -- 874
				Color(237, 227, 200, 77), -- 874
				0 -- 874
			) -- 874
			dn:drawRect( -- 875
				Rect(x + 5, H - y - h + 4.5, w - 12, 1.6), -- 875
				Color(237, 227, 200, 168), -- 875
				0 -- 875
			) -- 875
			dn:drawRect( -- 876
				Rect(x + 7, H - y - h + 7.5, w - 17, 1.4), -- 876
				Color(237, 227, 200, 140), -- 876
				0 -- 876
			) -- 876
			dn:drawRect( -- 877
				Rect(x, H - y - h, 2, h), -- 877
				Color(23, 51, 48, 92), -- 877
				0 -- 877
			) -- 877
			dn:drawRect( -- 878
				Rect(x + w - 2, H - y - h, 2, h), -- 878
				Color(23, 51, 48, 92), -- 878
				0 -- 878
			) -- 878
		end -- 878
		if #water >= 2 then -- 878
			do -- 878
				local i = #water - 1 -- 884
				while i >= 1 do -- 884
					do -- 884
						local a0 = water[i + 1] -- 885
						local a1 = water[i] -- 885
						if a0.r < 0 or a1.r < 0 then -- 885
							goto __continue197 -- 886
						end -- 886
						local t2 = #water <= 2 and 1 or (i - 1) / (#water - 1) -- 887
						local w = G * (0.62 - 0.46 * t2) -- 888
						local al = math.floor(255 * (0.92 - 0.42 * t2) + 0.5) -- 889
						local fromX = i == 1 and rInit and rx + G / 2 or cw(a1.c) + G / 2 -- 890
						local fromY = i == 1 and rInit and ry + G / 2 or ch(a1.r) + G / 2 -- 891
						dn:drawSegment( -- 892
							Vec2( -- 893
								cw(a0.c) + G / 2, -- 893
								H - (ch(a0.r) + G / 2) -- 893
							), -- 893
							Vec2(fromX, H - fromY), -- 894
							math.max(1.4, w / 2), -- 895
							Color(C_TEAL.r, C_TEAL.g, C_TEAL.b, al) -- 895
						) -- 895
					end -- 895
					::__continue197:: -- 895
					i = i - 1 -- 884
				end -- 884
			end -- 884
		end -- 884
		local hd = water[1] -- 902
		if hd ~= nil and hd.r >= 0 then -- 902
			local hx = (rInit and rx or cw(hd.c)) + G / 2 -- 904
			local hy = (rInit and ry or ch(hd.r)) + G / 2 -- 904
			local R = G * 0.4 -- 905
			dn:drawRect( -- 906
				Rect(hx - R, H - hy - R, R * 2, R * 2), -- 906
				C_DEEP, -- 906
				0 -- 906
			) -- 906
			dn:drawRect( -- 907
				Rect(hx - R * 0.55, H - hy - R * 0.3 - 4, 4, 4), -- 907
				Color(252, 247, 232, 217), -- 907
				0 -- 907
			) -- 907
			if len <= 1 then -- 907
				local ga = math.floor(255 * (0.35 + 0.45 * math.abs(math.sin(t * 6))) + 0.5) -- 911
				dn:drawRect( -- 912
					Rect(hx - R - 6, H - hy - R - 6, (R + 6) * 2, (R + 6) * 2), -- 912
					Color(0, 0, 0, 0), -- 913
					2.4, -- 913
					Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, ga) -- 913
				) -- 913
			end -- 913
		end -- 913
		if flash > 0 and flashAt ~= nil then -- 913
			local a = math.floor(200 * (flash / 0.45) + 0.5) -- 919
			dn:drawRect( -- 920
				Rect( -- 921
					cw(flashAt.c) - 2, -- 921
					H - ch(flashAt.r) - G - 2, -- 921
					G + 4, -- 921
					G + 4 -- 921
				), -- 921
				Color(0, 0, 0, 0), -- 922
				2.4, -- 922
				Color(163, 59, 42, a) -- 922
			) -- 922
		end -- 922
		local sx = 1088 -- 927
		local sw = 20 -- 927
		local sg = 28 -- 927
		do -- 927
			local i = 0 -- 928
			while i < LEN_MAX do -- 928
				local x = sx + i * sg -- 929
				local y = 30 -- 929
				local hh = 15 -- 929
				local fill = i < len and (i < 2 and Color(56, 96, 90, 255) or C_TEAL) or Color(36, 73, 70, 16) -- 930
				dn:drawRect( -- 933
					Rect(x, H - y - hh, sw, hh), -- 933
					fill, -- 933
					1, -- 933
					Color(36, 73, 70, i < len and 77 or 51) -- 934
				) -- 934
				i = i + 1 -- 928
			end -- 928
		end -- 928
		dn:drawSegment( -- 936
			Vec2(sx + 2 * sg - 4, H - 14), -- 936
			Vec2(sx + 2 * sg - 4, H - 37), -- 936
			0.7, -- 936
			C_GOLD -- 936
		) -- 936
		if phase == "win" then -- 936
			do -- 936
				local i = 0 -- 940
				while i < #fields do -- 940
					do -- 940
						local k = math.min( -- 941
							1, -- 941
							math.max(0, (overT - i * 0.06) / 0.18) -- 941
						) -- 941
						if k <= 0 then -- 941
							goto __continue206 -- 942
						end -- 942
						local f = fields[i + 1] -- 943
						local x = cw(f.c0) -- 944
						local y = ch(f.r0) -- 944
						local w = (f.c1 - f.c0 + 1) * G -- 945
						local h = (f.r1 - f.r0 + 1) * G -- 945
						dn:drawRect( -- 946
							Rect(x, H - y - h, w, h), -- 946
							Color( -- 947
								252, -- 947
								247, -- 947
								232, -- 947
								math.floor(102 * (1 - k) + 0.5) -- 947
							), -- 947
							0 -- 947
						) -- 947
						dn:drawRect( -- 948
							Rect(x + 1.5, H - y - h + 1.5, w - 3, h - 3), -- 948
							Color(0, 0, 0, 0), -- 949
							3, -- 949
							Color( -- 949
								C_GOLD.r, -- 949
								C_GOLD.g, -- 949
								C_GOLD.b, -- 949
								math.floor(235 * k + 0.5) -- 949
							) -- 949
						) -- 949
					end -- 949
					::__continue206:: -- 949
					i = i + 1 -- 940
				end -- 940
			end -- 940
		end -- 940
		if phase == "lose" and deadIdx >= 0 then -- 940
			local f = fields[deadIdx + 1] -- 955
			local x = cw(f.c0) -- 956
			local y = ch(f.r0) -- 956
			local w = (f.c1 - f.c0 + 1) * G -- 957
			local h = (f.r1 - f.r0 + 1) * G -- 957
			local dry = mixColor(C_SEAM, C_GOLD, 0.45) -- 958
			dn:drawRect( -- 959
				Rect(x, H - y - h, w, h), -- 959
				Color(dry.r, dry.g, dry.b, 133), -- 959
				0 -- 959
			) -- 959
			dn:drawRect( -- 960
				Rect(x, H - y - h, w, h), -- 960
				Color(23, 51, 48, 26), -- 960
				0 -- 960
			) -- 960
			dn:drawRect( -- 961
				Rect(x + 1.5, H - y - h + 1.5, w - 3, h - 3), -- 961
				Color(0, 0, 0, 0), -- 962
				3, -- 962
				Color(23, 51, 48, 179) -- 962
			) -- 962
		end -- 962
		local px = 540 -- 966
		do -- 966
			local i = 0 -- 967
			while i < 8 do -- 967
				local f = fields[i + 1] -- 968
				local x = px + i * 26 -- 969
				local y = 30 -- 969
				local w = 19 -- 969
				local hh = 15 -- 969
				local col = f.lv > 0 and (f.lv >= NEED and C_LV3 or (f.lv == 2 and C_LV2 or C_LV1)) or C_EMPTY -- 970
				dn:drawRect( -- 971
					Rect(x, H - y - hh, w, hh), -- 971
					col, -- 971
					1, -- 971
					Color(36, 73, 70, f.lv >= 3 and 117 or 61) -- 972
				) -- 972
				if f.lv > 0 and f.lv < NEED and f.timer / WIN_KEEP < 0.34 then -- 972
					dn:drawRect( -- 975
						Rect(x + w - 5, H - y - hh, 4, 4), -- 975
						C_GOLD, -- 975
						0 -- 975
					) -- 975
				end -- 975
				i = i + 1 -- 967
			end -- 967
		end -- 967
		autoRoot.visible = autoOn and phase == "play" -- 979
		if autoOn then -- 979
			local over = ptrX >= ABT_X and ptrX <= ABT_X + ABT_W and ptrY >= ABT_Y and ptrY <= ABT_Y + ABT_H -- 981
			abtFace.color = over and C_DEEP or C_VERM -- 982
		end -- 982
		if paused then -- 982
			dn:drawRect( -- 987
				Rect(0, 0, W, H), -- 987
				Color(237, 227, 200, 140), -- 987
				0 -- 987
			) -- 987
			pauseLb1.text = "暂 停" -- 988
			pauseLb2.text = "按 Esc 继续" -- 989
		else -- 989
			pauseLb1.text = "" -- 991
			pauseLb2.text = "" -- 992
		end -- 992
		pourLb.text = (("灌溉 " .. tostring(poured)) .. " / ") .. tostring(TOTAL_POUR) -- 996
		hintLb.text = phase == "play" and hintT > 0 and hint or "" -- 997
		hintLb.color = Color(36, 73, 70, phase == "play" and hintT > 0 and 255 or 0) -- 998
		clockLb.text = phase == "play" and ("用时 " .. tostring(math.floor(t + 0.5))) .. " s" or "" -- 1001
	end -- 693
	local introRoot = Node() -- 1007
	introRoot.size = Size(W, H) -- 1008
	introRoot.anchor = Vec2(0, 0) -- 1009
	introRoot.position = Vec2(0, 0) -- 1010
	introRoot:addTo(layer) -- 1011
	local WASH_N = 16 -- 1015
	local WASH_X1 = 940 -- 1015
	local WASH_MID = WASH_X1 * 0.55 -- 1015
	do -- 1015
		local i = 0 -- 1016
		while i < WASH_N do -- 1016
			local x0 = WASH_X1 * i / WASH_N -- 1017
			local x1 = WASH_X1 * (i + 1) / WASH_N -- 1018
			local mid = (x0 + x1) / 2 -- 1019
			local a = mid <= WASH_MID and 0.98 - 0.04 * (mid / WASH_MID) or 0.94 * (1 - (mid - WASH_MID) / (WASH_X1 - WASH_MID)) -- 1020
			block( -- 1023
				introRoot, -- 1023
				x0, -- 1023
				0, -- 1023
				x1 - x0 + 1, -- 1023
				H, -- 1023
				C_PAPER, -- 1023
				a -- 1023
			) -- 1023
			i = i + 1 -- 1016
		end -- 1016
	end -- 1016
	local burstDn = DrawNode() -- 1027
	burstDn:addTo(introRoot) -- 1028
	do -- 1028
		local i = 0 -- 1029
		while i < 40 do -- 1029
			local ang = i / 40 * math.pi * 2 + 0.31 -- 1030
			local j = i * 37 % 11 / 11 -- 1031
			local r0 = 210 * (0.86 + 0.3 * j) -- 1032
			local r1 = 360 * (0.72 + 0.46 * j) -- 1033
			burstDn:drawSegment( -- 1034
				Vec2( -- 1035
					250 + math.cos(ang) * r0, -- 1035
					H - (330 + math.sin(ang) * r0) -- 1035
				), -- 1035
				Vec2( -- 1036
					250 + math.cos(ang) * r1, -- 1036
					H - (330 + math.sin(ang) * r1) -- 1036
				), -- 1036
				0.8, -- 1037
				Color(36, 73, 70, 26) -- 1037
			) -- 1037
			i = i + 1 -- 1029
		end -- 1029
	end -- 1029
	local introWz = img( -- 1042
		introRoot, -- 1042
		"Image/StartUI/face_wave.png", -- 1042
		918, -- 1042
		316, -- 1042
		286, -- 1042
		384 -- 1042
	) -- 1042
	local introWzShadow = block( -- 1043
		introRoot, -- 1043
		964, -- 1043
		704, -- 1043
		192, -- 1043
		10, -- 1043
		C_INK, -- 1043
		0.1 -- 1043
	) -- 1043
	local iSealBg = block( -- 1046
		introRoot, -- 1046
		112, -- 1046
		196, -- 1046
		38, -- 1046
		38, -- 1046
		C_VERM, -- 1046
		1 -- 1046
	) -- 1046
	local iSealTx = label( -- 1047
		introRoot, -- 1047
		FONT_B, -- 1047
		27, -- 1047
		Color(252, 247, 232, 255), -- 1047
		131, -- 1047
		226, -- 1047
		0.5, -- 1047
		0 -- 1047
	) -- 1047
	iSealTx.text = "叁" -- 1048
	local iQian = label( -- 1049
		introRoot, -- 1049
		FONT_B, -- 1049
		15, -- 1049
		Color(36, 73, 70, 140), -- 1049
		158, -- 1049
		226, -- 1049
		0, -- 1049
		4 -- 1049
	) -- 1049
	iQian.text = "关 前" -- 1050
	local iTitle = label( -- 1053
		introRoot, -- 1053
		FONT_B, -- 1053
		82, -- 1053
		C_INK, -- 1053
		106, -- 1053
		342, -- 1053
		0, -- 1053
		12 -- 1053
	) -- 1053
	iTitle.text = "引 流" -- 1054
	local iRule = block( -- 1057
		introRoot, -- 1057
		112, -- 1057
		366, -- 1057
		128, -- 1057
		4, -- 1057
		C_VERM, -- 1057
		1 -- 1057
	) -- 1057
	local iSep = block( -- 1058
		introRoot, -- 1058
		112, -- 1058
		516, -- 1058
		448, -- 1058
		2, -- 1058
		C_INK, -- 1058
		0.32 -- 1058
	) -- 1058
	local iL1 = label( -- 1061
		introRoot, -- 1061
		FONT_B, -- 1061
		22, -- 1061
		Color(36, 73, 70, 220), -- 1061
		112, -- 1061
		434, -- 1061
		0, -- 1061
		1.4 -- 1061
	) -- 1061
	iL1.text = "城墙三面临水，城里有两条渠。" -- 1062
	local iL2 = label( -- 1063
		introRoot, -- 1063
		FONT_B, -- 1063
		22, -- 1063
		Color(36, 73, 70, 220), -- 1063
		112, -- 1063
		474, -- 1063
		0, -- 1063
		1.4 -- 1063
	) -- 1063
	iL2.text = "水从水门进来。船，也从这儿进来。" -- 1064
	local iH1 = label( -- 1066
		introRoot, -- 1066
		FONT_B, -- 1066
		14, -- 1066
		Color(36, 73, 70, 163), -- 1066
		112, -- 1066
		558, -- 1066
		0, -- 1066
		0.8 -- 1066
	) -- 1066
	iH1.text = "八块田，每块三趟水。你是渠里那道水头。" -- 1067
	local iH2 = label( -- 1068
		introRoot, -- 1068
		FONT_R, -- 1068
		14, -- 1068
		Color(36, 73, 70, 163), -- 1068
		112, -- 1068
		586, -- 1068
		0, -- 1068
		0.5 -- 1068
	) -- 1068
	iH2.text = "田越熟越挑水：干要三格，湿要四格，秧要五格。" -- 1069
	local iBtnShadow = block( -- 1075
		introRoot, -- 1075
		120, -- 1075
		648, -- 1075
		240, -- 1075
		60, -- 1075
		C_DEEP, -- 1075
		0.9 -- 1075
	) -- 1075
	local iBtnBody = block( -- 1076
		introRoot, -- 1076
		112, -- 1076
		640, -- 1076
		240, -- 1076
		60, -- 1076
		Color(252, 247, 232, 255), -- 1076
		1 -- 1076
	) -- 1076
	local iBtnT = block( -- 1077
		introRoot, -- 1077
		112, -- 1077
		640, -- 1077
		240, -- 1077
		3, -- 1077
		C_INK, -- 1077
		0.95 -- 1077
	) -- 1077
	local iBtnB = block( -- 1078
		introRoot, -- 1078
		112, -- 1078
		697, -- 1078
		240, -- 1078
		3, -- 1078
		C_INK, -- 1078
		0.95 -- 1078
	) -- 1078
	local iBtnL = block( -- 1079
		introRoot, -- 1079
		112, -- 1079
		640, -- 1079
		3, -- 1079
		60, -- 1079
		C_INK, -- 1079
		0.95 -- 1079
	) -- 1079
	local iBtnR = block( -- 1080
		introRoot, -- 1080
		349, -- 1080
		640, -- 1080
		3, -- 1080
		60, -- 1080
		C_INK, -- 1080
		0.95 -- 1080
	) -- 1080
	local iBtnFill = block( -- 1081
		introRoot, -- 1081
		115, -- 1081
		643, -- 1081
		234, -- 1081
		54, -- 1081
		C_VERM, -- 1081
		0.5 -- 1081
	) -- 1081
	local iBtnTx = label( -- 1082
		introRoot, -- 1082
		FONT_B, -- 1082
		21, -- 1082
		C_INK, -- 1082
		232, -- 1082
		678, -- 1082
		0.5, -- 1082
		10 -- 1082
	) -- 1082
	iBtnTx.text = "开 始" -- 1083
	local iBtnTip = label( -- 1084
		introRoot, -- 1084
		FONT_R, -- 1084
		13, -- 1084
		Color(36, 73, 70, 133), -- 1084
		378, -- 1084
		677, -- 1084
		0, -- 1084
		1.6 -- 1084
	) -- 1084
	iBtnTip.text = "点任意处 / 空格 / WASD" -- 1085
	local BTN_RECT = {x = 112, y = 640, w = 240, h = 60} -- 1088
	local function inBtn(x, y) -- 1089
		return x >= BTN_RECT.x and x <= BTN_RECT.x + BTN_RECT.w and y >= BTN_RECT.y and y <= BTN_RECT.y + BTN_RECT.h -- 1090
	end -- 1089
	local iHover = 0 -- 1093
	local iHoverT = 0 -- 1093
	local iPress = 0 -- 1094
	local iDown = false -- 1094
	local pressHold = 0 -- 1095
	local beginWait = -1 -- 1096
	local iFoot = label( -- 1098
		introRoot, -- 1098
		FONT_R, -- 1098
		11, -- 1098
		Color(36, 73, 70, 102), -- 1098
		112, -- 1098
		764, -- 1098
		0, -- 1098
		1.2 -- 1098
	) -- 1098
	iFoot.text = "永昌堡 · 嘉靖四十年 · 五月" -- 1099
	local introT = 0 -- 1102
	local function syncIntro(dt) -- 1104
		local function ease(t0, dur) -- 1105
			local k = math.min( -- 1106
				1, -- 1106
				math.max(0, (introT - t0) / dur) -- 1106
			) -- 1106
			return 1 - (1 - k) ^ 3 -- 1107
		end -- 1105
		local aL = ease(0.1, 0.75) -- 1110
		burstDn.opacity = aL * 0.95 -- 1111
		local aWz = ease(0.16, 0.72) -- 1113
		local wdx = (1 - aWz) * 48 -- 1114
		local bob = math.sin(introT * 1.45) * 2.2 -- 1115
		introWz.opacity = 0.98 * aWz -- 1116
		introWz.position = Vec2(918 + wdx, H - (316 + bob)) -- 1117
		introWzShadow.opacity = 0.1 * aWz -- 1118
		introWzShadow.position = Vec2(964 + wdx, H - 704) -- 1119
		local aSeal = ease(0.34, 0.28) -- 1121
		iSealBg.opacity = aSeal -- 1122
		iSealTx.opacity = aSeal -- 1123
		iQian.opacity = aSeal -- 1124
		local aTitle = ease(0.46, 0.55) -- 1126
		iTitle.opacity = aTitle -- 1127
		iTitle.position = Vec2(106 + 44 * (1 - aTitle), H - 342 + 82) -- 1128
		iRule.scaleX = math.max( -- 1130
			0.01, -- 1130
			ease(0.74, 0.42) -- 1130
		) -- 1130
		iL1.opacity = ease(0.88, 0.5) -- 1131
		iL2.opacity = ease(1.02, 0.5) -- 1132
		iSep.scaleX = math.max( -- 1133
			0.01, -- 1133
			ease(1.18, 0.42) -- 1133
		) -- 1133
		iH1.opacity = ease(1.34, 0.5) -- 1134
		iH2.opacity = ease(1.34, 0.5) -- 1135
		local aBtn = ease(1.52, 0.5) -- 1137
		local pulse = 0.5 + 0.5 * math.sin(introT * 2.3) -- 1138
		iBtnShadow.opacity = 0.9 * aBtn -- 1139
		iBtnBody.opacity = aBtn -- 1140
		iBtnT.opacity = 0.95 * aBtn -- 1141
		iBtnB.opacity = 0.95 * aBtn -- 1142
		iBtnL.opacity = 0.95 * aBtn -- 1143
		iBtnR.opacity = 0.95 * aBtn -- 1144
		iBtnTx.opacity = aBtn -- 1145
		iBtnTip.opacity = aBtn * 0.9 -- 1146
		iFoot.opacity = ease(1.75, 0.6) -- 1147
		iHover = approach(iHover, iHoverT, dt / 0.14) -- 1150
		iPress = approach(iPress, (iDown or pressHold > 0) and 1 or 0, dt / 0.08) -- 1151
		local hv = iHover * iHover * (3 - 2 * iHover) -- 1152
		local off = 3 * hv + 2 * iPress -- 1153
		iBtnBody.position = Vec2(112 + off, H - (640 + off)) -- 1154
		iBtnT.position = Vec2(112 + off, H - (640 + off)) -- 1155
		iBtnB.position = Vec2(112 + off, H - (697 + off)) -- 1156
		iBtnL.position = Vec2(112 + off, H - (640 + off)) -- 1157
		iBtnR.position = Vec2(349 + off, H - (640 + off)) -- 1158
		iBtnFill.position = Vec2(115 + off, H - (643 + off)) -- 1159
		iBtnTx.position = Vec2(232 + off, H - (678 + off) + 21) -- 1160
		iBtnFill.color = mixColor(C_VERM, C_DEEP, 0.24 * hv + 0.16 * iPress) -- 1161
		iBtnFill.opacity = (0.4 + 0.26 * pulse + 0.22 * hv) * aBtn -- 1162
	end -- 1104
	local deadLb = label( -- 1166
		layer, -- 1166
		FONT_B, -- 1166
		24, -- 1166
		Color(23, 51, 48, 230), -- 1166
		0, -- 1166
		0, -- 1166
		0.5, -- 1166
		6 -- 1166
	) -- 1166
	deadLb.visible = false -- 1167
	local function begin() -- 1170
		if phase ~= "intro" then -- 1170
			return -- 1171
		end -- 1171
		introRoot.visible = false -- 1172
		panelRoot.visible = true -- 1173
		wzSmall.visible = true -- 1174
		reset() -- 1175
	end -- 1170
	reset() -- 1178
	phase = "intro" -- 1179
	panelRoot.visible = false -- 1180
	wzSmall.visible = false -- 1181
	syncIntro(0) -- 1182
	draw() -- 1183
	local play = { -- 1186
		update = function(____, dt) -- 1187
			if phase == "intro" then -- 1187
				introT = introT + dt -- 1189
				if autoOn and introT > 1.8 then -- 1189
					wantBegin = true -- 1191
				end -- 1191
				if beginWait > 0 then -- 1191
					beginWait = beginWait - dt -- 1193
					if beginWait <= 0 then -- 1193
						wantBegin = true -- 1194
					end -- 1194
				end -- 1194
				if pressHold > 0 then -- 1194
					pressHold = pressHold - dt -- 1196
				end -- 1196
				syncIntro(dt) -- 1197
				draw() -- 1198
			end -- 1198
			if wantBegin then -- 1198
				wantBegin = false -- 1201
				begin() -- 1201
			end -- 1201
			if phase == "intro" then -- 1201
				return -- 1202
			end -- 1202
			if wantRestart then -- 1202
				wantRestart = false -- 1204
				reset() -- 1204
			end -- 1204
			if paused then -- 1204
				draw() -- 1206
				return -- 1206
			end -- 1206
			tick(dt) -- 1207
			smoothHead(dt) -- 1208
			draw() -- 1209
			if phase == "lose" and deadIdx >= 0 and not deadLb.visible then -- 1209
				local f = fields[deadIdx + 1] -- 1214
				local cx = cw(f.c0) + (f.c1 - f.c0 + 1) * G / 2 -- 1215
				local cy = ch(f.r0) + (f.r1 - f.r0 + 1) * G / 2 + 8 -- 1216
				deadLb.text = f.cn .. " 荒了" -- 1217
				deadLb.position = Vec2(cx, H - cy + 24) -- 1218
				deadLb.visible = true -- 1219
			end -- 1219
			if not finished and overT > (phase == "win" and 1.2 or 1.3) then -- 1219
				finished = true -- 1223
				opts.onFinish({ -- 1224
					done = done, -- 1224
					secs = math.floor(t + 0.5), -- 1224
					dead = phase == "lose" and 1 or 0 -- 1224
				}) -- 1224
			end -- 1224
		end, -- 1187
		destroy = function() -- 1227
			layer:removeFromParent() -- 1227
		end, -- 1227
		press = function(____, dir) -- 1228
			press(dir) -- 1228
		end, -- 1228
		tapAt = function(____, x, y) -- 1229
			ptrX = x -- 1230
			ptrY = y -- 1231
			if paused then -- 1231
				paused = false -- 1232
				return true -- 1232
			end -- 1232
			if phase == "play" and autoOn then -- 1232
				if x >= ABT_BX and x <= ABT_BX + ABT_BW and y >= ABT_BY and y <= ABT_BY + ABT_BH then -- 1232
					autoOn = false -- 1235
					return true -- 1236
				end -- 1236
				return false -- 1238
			end -- 1238
			if phase == "intro" then -- 1238
				if inBtn(x, y) then -- 1238
					pressHold = 0.12 -- 1242
					beginWait = 0.12 -- 1242
				else -- 1242
					wantBegin = true -- 1243
				end -- 1243
				return true -- 1244
			end -- 1244
			return false -- 1246
		end, -- 1229
		pointerAt = function(____, x, y, down) -- 1248
			ptrX = x -- 1249
			ptrY = y -- 1250
			if phase ~= "intro" then -- 1250
				return -- 1251
			end -- 1251
			iHoverT = inBtn(x, y) and 1 or 0 -- 1252
			iDown = down and iHoverT == 1 -- 1253
		end, -- 1248
		togglePause = function() -- 1255
			if phase ~= "play" then -- 1255
				return -- 1256
			end -- 1256
			paused = not paused -- 1257
		end, -- 1255
		restart = function() -- 1259
			if phase == "intro" then -- 1259
				wantBegin = true -- 1263
				return -- 1263
			end -- 1263
			if phase == "win" or phase == "lose" then -- 1263
				return -- 1264
			end -- 1264
			deadLb.visible = false -- 1265
			reset() -- 1266
		end, -- 1259
		skip = function() -- 1268
			if phase == "intro" then -- 1268
				wantBegin = true -- 1270
				return -- 1270
			end -- 1270
			if phase == "play" then -- 1270
				for ____, f in ipairs(fields) do -- 1274
					f.lv = NEED -- 1274
					f.timer = math.huge -- 1274
				end -- 1274
				done = #FIELD_DEF -- 1275
				poured = TOTAL_POUR -- 1276
				phase = "win" -- 1277
				overT = 0 -- 1278
				return -- 1279
			end -- 1279
			wantFinish = true -- 1281
		end -- 1268
	} -- 1268
	print("[Level3Play] 渠网调度就绪") -- 1285
	return play -- 1286
end -- 154
function ____exports.startLevel3(auto) -- 1291
	if auto == nil then -- 1291
		auto = false -- 1291
	end -- 1291
	local frame = createSceneFrame() -- 1292
	local play = nil -- 1293
	local function leave(stats) -- 1296
		if play ~= nil then -- 1296
			play:destroy() -- 1297
			play = nil -- 1297
		end -- 1297
		frame:destroy() -- 1298
		startLevel3Result( -- 1299
			stats, -- 1299
			{ -- 1299
				onNext = function() -- 1301
					startLevel3Post(function() -- 1302
						backToTitle() -- 1302
					end) -- 1302
				end, -- 1301
				onRetry = function() -- 1304
					____exports.startLevel3(false) -- 1304
				end, -- 1304
				onAuto = function() -- 1305
					____exports.startLevel3(true) -- 1305
				end -- 1305
			} -- 1305
		) -- 1305
	end -- 1296
	play = ____exports.createLevel3Play(frame.inner, {onFinish = leave, auto = auto}) -- 1309
	frame.root:onKeyDown(function(key) -- 1311
		if key == "W" or key == "Up" then -- 1311
			play:press("u") -- 1313
			return -- 1313
		end -- 1313
		if key == "S" or key == "Down" then -- 1313
			play:press("d") -- 1314
			return -- 1314
		end -- 1314
		if key == "A" or key == "Left" then -- 1314
			play:press("l") -- 1315
			return -- 1315
		end -- 1315
		if key == "D" or key == "Right" then -- 1315
			play:press("r") -- 1316
			return -- 1316
		end -- 1316
		if key == "Space" then -- 1316
			play:restart() -- 1318
			return -- 1318
		end -- 1318
		if key == "Escape" then -- 1318
			play:togglePause() -- 1320
			return -- 1320
		end -- 1320
		if key == "R" then -- 1320
			play:restart() -- 1322
			return -- 1322
		end -- 1322
		if key == "P" then -- 1322
			play:skip() -- 1324
		end -- 1324
	end) -- 1311
	frame.input:onMouseMove(function(touch) -- 1329
		if play == nil then -- 1329
			return -- 1330
		end -- 1330
		play:pointerAt(touch.location.x, 800 - touch.location.y, false) -- 1331
	end) -- 1329
	frame.input:onTapBegan(function(touch) -- 1334
		if play == nil then -- 1334
			return -- 1335
		end -- 1335
		play:pointerAt(touch.location.x, 800 - touch.location.y, true) -- 1336
	end) -- 1334
	frame.input:onTapEnded(function() -- 1339
		if play == nil then -- 1339
			return -- 1340
		end -- 1340
		play:pointerAt(-1, -1, false) -- 1341
	end) -- 1339
	frame.input:onTapped(function(touch) -- 1344
		if play == nil then -- 1344
			return -- 1345
		end -- 1345
		play:tapAt(touch.location.x, 800 - touch.location.y) -- 1346
	end) -- 1344
	frame.root:schedule(function(dt) -- 1349
		frame:fit() -- 1350
		if play ~= nil then -- 1350
			play:update(dt) -- 1351
		end -- 1351
		return false -- 1352
	end) -- 1349
end -- 1291
return ____exports -- 1291