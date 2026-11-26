-- [ts]: Level3ResultScene.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local Color = ____Dora.Color -- 12
local DrawNode = ____Dora.DrawNode -- 13
local Label = ____Dora.Label -- 15
local Node = ____Dora.Node -- 16
local Size = ____Dora.Size -- 18
local Sprite = ____Dora.Sprite -- 19
local Vec2 = ____Dora.Vec2 -- 20
local ____SceneFrame = require("Script.SceneFrame") -- 22
local createSceneFrame = ____SceneFrame.createSceneFrame -- 22
local W = 1280 -- 24
local H = 800 -- 24
local CT_T = 72 -- 27
local CT_B = 170 -- 27
local RM_T = 170 -- 28
local FOOT_T = 678 -- 28
local FOOT_B = 702 -- 28
local BASE_T = 702 -- 29
local LANE_X0 = 364 -- 30
local LANE_W = 168 -- 30
local LANE_GAP = 24 -- 30
local LANE_R = LANE_X0 + 3 * LANE_W + 2 * LANE_GAP -- 31
local C_PAPER = Color(237, 227, 200, 255) -- 34
local C_PAPER2 = Color(243, 234, 211, 255) -- 35
local C_SAND = Color(212, 203, 171, 255) -- 36
local C_SANDD = Color(197, 188, 156, 255) -- 37
local C_SEAM = Color(168, 159, 127, 255) -- 38
local C_TRAY = Color(186, 176, 144, 255) -- 39
local C_TEAL = Color(90, 121, 104, 255) -- 40
local C_INK = Color(36, 73, 70, 255) -- 41
local C_DEEP = Color(23, 51, 48, 255) -- 42
local C_VERM = Color(163, 59, 42, 255) -- 43
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 45
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 46
local function mixColor(a, b, t) -- 48
	return Color( -- 49
		math.floor(a.r + (b.r - a.r) * t + 0.5), -- 50
		math.floor(a.g + (b.g - a.g) * t + 0.5), -- 51
		math.floor(a.b + (b.b - a.b) * t + 0.5), -- 52
		math.floor(a.a + (b.a - a.a) * t + 0.5) -- 53
	) -- 53
end -- 48
local function approach(v, target, step) -- 56
	if v < target then -- 56
		return math.min(target, v + step) -- 57
	end -- 57
	if v > target then -- 57
		return math.max(target, v - step) -- 58
	end -- 58
	return v -- 59
end -- 56
function ____exports.startLevel3Result(res, opts) -- 73
	local failed = res.dead > 0 -- 74
	local frame = createSceneFrame() -- 75
	local root = frame.inner -- 76
	local function block(p, x, y, w, h, c, al) -- 79
		if al == nil then -- 79
			al = 1 -- 80
		end -- 80
		local s = Sprite("Image/StartUI/white.png") -- 82
		s.size = Size( -- 83
			math.abs(w), -- 83
			math.abs(h) -- 83
		) -- 83
		s.anchor = Vec2(0, 1) -- 84
		s.color = c -- 85
		s.opacity = al -- 86
		s.position = Vec2(x, H - y) -- 87
		s:addTo(p) -- 88
		return s -- 89
	end -- 79
	local function img(p, f, x, y, w, h) -- 91
		local s = Sprite(f) -- 92
		s.size = Size(w, h) -- 93
		s.anchor = Vec2(0, 1) -- 94
		s.position = Vec2(x, H - y) -- 95
		s:addTo(p) -- 96
		return s -- 97
	end -- 91
	local function label(p, font, size, c, x, y, ax, ls) -- 99
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 103
		lb.color = c -- 104
		lb.anchor = Vec2(ax, 1) -- 105
		lb.scaleX = 0.5 -- 106
		lb.scaleY = 0.5 -- 107
		lb.position = Vec2(x, H - y + size) -- 108
		if ls > 0 then -- 108
			lb.spacing = math.floor(ls * 2 + 0.5) -- 109
		end -- 109
		lb:addTo(p) -- 110
		return lb -- 111
	end -- 99
	local layer = Node() -- 114
	layer.size = Size(W, H) -- 115
	layer.anchor = Vec2(0, 0) -- 116
	layer.position = Vec2(0, 0) -- 117
	layer:addTo(root) -- 118
	img( -- 121
		layer, -- 121
		"Image/StartUI/lv2_paper.png", -- 121
		0, -- 121
		0, -- 121
		W, -- 121
		H + 4 -- 121
	) -- 121
	local wallFill = mixColor(C_SAND, C_PAPER, 0.34) -- 124
	block( -- 125
		layer, -- 125
		0, -- 125
		CT_T, -- 125
		W, -- 125
		CT_B - CT_T, -- 125
		wallFill -- 125
	) -- 125
	block( -- 126
		layer, -- 126
		0, -- 126
		CT_T, -- 126
		W, -- 126
		32, -- 126
		mixColor(C_PAPER, C_TEAL, 0.21) -- 126
	) -- 126
	local teeth = {} -- 129
	do -- 129
		local x = -16 -- 130
		while x < W + 80 do -- 130
			teeth[#teeth + 1] = x + 20 -- 130
			x = x + 112 -- 130
		end -- 130
	end -- 130
	for ____, bx in ipairs(teeth) do -- 131
		block( -- 131
			layer, -- 131
			bx, -- 131
			CT_T, -- 131
			64, -- 131
			32, -- 131
			wallFill -- 131
		) -- 131
	end -- 131
	local crenelDn = DrawNode() -- 134
	crenelDn:addTo(layer) -- 135
	for ____, bx in ipairs(teeth) do -- 136
		crenelDn:drawSegment( -- 137
			Vec2(bx, H - (CT_T + 32)), -- 137
			Vec2(bx, H - CT_T), -- 137
			1.2, -- 137
			Color(36, 73, 70, 184) -- 137
		) -- 137
		crenelDn:drawSegment( -- 138
			Vec2(bx, H - CT_T), -- 138
			Vec2(bx + 64, H - CT_T), -- 138
			1.2, -- 138
			Color(36, 73, 70, 184) -- 138
		) -- 138
		crenelDn:drawSegment( -- 139
			Vec2(bx + 64, H - CT_T), -- 139
			Vec2(bx + 64, H - (CT_T + 32)), -- 139
			1.2, -- 139
			Color(36, 73, 70, 184) -- 139
		) -- 139
	end -- 139
	local wtop = CT_T + 32 -- 141
	do -- 141
		local y = wtop + 26 -- 142
		while y < CT_B - 8 do -- 142
			block( -- 143
				layer, -- 143
				0, -- 143
				y - 0.7, -- 143
				W, -- 143
				1.4, -- 143
				C_SEAM, -- 143
				0.62 -- 143
			) -- 143
			y = y + 26 -- 142
		end -- 142
	end -- 142
	local function shade(y0, y1, al) -- 147
		local steps = {{0, 120, 1}, {120, 220, 0.55}, {220, 300, 0.22}} -- 148
		for ____, st in ipairs(steps) do -- 149
			block( -- 150
				layer, -- 150
				st[1], -- 150
				y0, -- 150
				st[2] - st[1], -- 150
				y1 - y0, -- 150
				C_INK, -- 150
				al * st[3] -- 150
			) -- 150
			block( -- 151
				layer, -- 151
				W - st[2], -- 151
				y0, -- 151
				st[2] - st[1], -- 151
				y1 - y0, -- 151
				C_INK, -- 151
				al * st[3] -- 151
			) -- 151
		end -- 151
	end -- 147
	shade(wtop, CT_B, 0.12) -- 154
	block( -- 157
		layer, -- 157
		0, -- 157
		RM_T, -- 157
		W, -- 157
		FOOT_B - RM_T, -- 157
		C_SANDD -- 157
	) -- 157
	do -- 157
		local y = RM_T + 96 -- 158
		while y < FOOT_T do -- 158
			block( -- 158
				layer, -- 158
				0, -- 158
				y, -- 158
				W, -- 158
				1.8, -- 158
				C_SEAM, -- 158
				0.22 -- 158
			) -- 158
			y = y + 116 -- 158
		end -- 158
	end -- 158
	do -- 158
		local x = 0 -- 159
		while x < W do -- 159
			block( -- 159
				layer, -- 159
				x, -- 159
				RM_T, -- 159
				58, -- 159
				FOOT_T - RM_T, -- 159
				C_SEAM, -- 159
				0.035 -- 159
			) -- 159
			x = x + 96 -- 159
		end -- 159
	end -- 159
	for ____, cx in ipairs({318, 944}) do -- 161
		block( -- 162
			layer, -- 162
			cx, -- 162
			RM_T, -- 162
			18, -- 162
			FOOT_T - RM_T, -- 162
			mixColor(C_TRAY, C_INK, 0.18) -- 162
		) -- 162
		block( -- 163
			layer, -- 163
			cx + 2, -- 163
			RM_T, -- 163
			3, -- 163
			FOOT_T - RM_T, -- 163
			C_PAPER, -- 163
			0.3 -- 163
		) -- 163
		block( -- 164
			layer, -- 164
			cx, -- 164
			RM_T, -- 164
			2.2, -- 164
			FOOT_T - RM_T, -- 164
			C_INK, -- 164
			0.5 -- 164
		) -- 164
		block( -- 165
			layer, -- 165
			cx + 15.8, -- 165
			RM_T, -- 165
			2.2, -- 165
			FOOT_T - RM_T, -- 165
			C_INK, -- 165
			0.5 -- 165
		) -- 165
	end -- 165
	block( -- 168
		layer, -- 168
		0, -- 168
		FOOT_T, -- 168
		W, -- 168
		FOOT_B - FOOT_T, -- 168
		mixColor(C_SANDD, C_INK, 0.14) -- 168
	) -- 168
	block( -- 169
		layer, -- 169
		0, -- 169
		FOOT_T + 2, -- 169
		W, -- 169
		3, -- 169
		C_PAPER, -- 169
		0.16 -- 169
	) -- 169
	block( -- 170
		layer, -- 170
		0, -- 170
		FOOT_T - 1.3, -- 170
		W, -- 170
		2.6, -- 170
		C_INK, -- 170
		0.78 -- 170
	) -- 170
	shade(RM_T, FOOT_T, 0.16) -- 171
	block( -- 174
		layer, -- 174
		0, -- 174
		140, -- 174
		W, -- 174
		30, -- 174
		mixColor(C_TRAY, C_INK, 0.74) -- 174
	) -- 174
	block( -- 175
		layer, -- 175
		0, -- 175
		141, -- 175
		W, -- 175
		3, -- 175
		C_PAPER, -- 175
		0.42 -- 175
	) -- 175
	block( -- 176
		layer, -- 176
		0, -- 176
		149, -- 176
		W, -- 176
		1.4, -- 176
		C_INK, -- 176
		0.16 -- 176
	) -- 176
	block( -- 177
		layer, -- 177
		0, -- 177
		157, -- 177
		W, -- 177
		1.4, -- 177
		C_INK, -- 177
		0.16 -- 177
	) -- 177
	block( -- 178
		layer, -- 178
		0, -- 178
		168.4, -- 178
		W, -- 178
		3.2, -- 178
		C_INK, -- 178
		0.95 -- 178
	) -- 178
	for ____, seg in ipairs({{0, LANE_X0}, {LANE_R, W - LANE_R}}) do -- 180
		block( -- 181
			layer, -- 181
			seg[1], -- 181
			CT_B, -- 181
			seg[2] - seg[1], -- 181
			20, -- 181
			C_INK, -- 181
			0.2 -- 181
		) -- 181
		block( -- 182
			layer, -- 182
			seg[1], -- 182
			CT_B + 20, -- 182
			seg[2] - seg[1], -- 182
			20, -- 182
			C_INK, -- 182
			0.11 -- 182
		) -- 182
		block( -- 183
			layer, -- 183
			seg[1], -- 183
			CT_B + 40, -- 183
			seg[2] - seg[1], -- 183
			18, -- 183
			C_INK, -- 183
			0.05 -- 183
		) -- 183
	end -- 183
	img( -- 190
		layer, -- 190
		"Image/StartUI/lv3_dawn.png", -- 190
		0, -- 190
		CT_B, -- 190
		W, -- 190
		H - CT_B -- 190
	) -- 190
	block( -- 193
		layer, -- 193
		0, -- 193
		BASE_T, -- 193
		W, -- 193
		H - BASE_T, -- 193
		C_TRAY -- 193
	) -- 193
	block( -- 194
		layer, -- 194
		0, -- 194
		BASE_T - 2, -- 194
		W, -- 194
		4, -- 194
		C_INK, -- 194
		0.95 -- 194
	) -- 194
	do -- 194
		local x = 26 -- 195
		while x < W do -- 195
			block( -- 195
				layer, -- 195
				x, -- 195
				BASE_T + 12, -- 195
				1.8, -- 195
				H - BASE_T - 12, -- 195
				C_INK, -- 195
				0.09 -- 195
			) -- 195
			x = x + 168 -- 195
		end -- 195
	end -- 195
	local face = img( -- 198
		layer, -- 198
		failed and "Image/StartUI/face_dot.png" or "Image/StartUI/face_laugh.png", -- 198
		856, -- 198
		350, -- 198
		300, -- 198
		400 -- 198
	) -- 198
	block( -- 199
		layer, -- 199
		914, -- 199
		736, -- 199
		192, -- 199
		12, -- 199
		C_INK, -- 199
		0.16 -- 199
	) -- 199
	local burstDn = DrawNode() -- 202
	burstDn:addTo(layer) -- 203
	do -- 203
		local i = 0 -- 204
		while i < 40 do -- 204
			local ang = i / 40 * math.pi * 2 + 0.31 -- 205
			local j = i * 37 % 11 / 11 -- 206
			local r0 = 210 * (0.86 + 0.3 * j) -- 207
			local r1 = 340 * (0.72 + 0.46 * j) -- 208
			burstDn:drawSegment( -- 209
				Vec2( -- 210
					250 + math.cos(ang) * r0, -- 210
					H - (330 + math.sin(ang) * r0) -- 210
				), -- 210
				Vec2( -- 211
					250 + math.cos(ang) * r1, -- 211
					H - (330 + math.sin(ang) * r1) -- 211
				), -- 211
				0.8, -- 212
				Color(36, 73, 70, 28) -- 212
			) -- 212
			i = i + 1 -- 204
		end -- 204
	end -- 204
	local WASH_N = 16 -- 217
	local WASH_X1 = 1080 -- 217
	local WASH_MID = WASH_X1 * 0.58 -- 217
	do -- 217
		local i = 0 -- 218
		while i < WASH_N do -- 218
			local x0 = WASH_X1 * i / WASH_N -- 219
			local x1 = WASH_X1 * (i + 1) / WASH_N -- 220
			local mid = (x0 + x1) / 2 -- 221
			local a = mid <= WASH_MID and 0.97 - 0.05 * (mid / WASH_MID) or 0.92 * (1 - (mid - WASH_MID) / (WASH_X1 - WASH_MID)) -- 222
			block( -- 225
				layer, -- 225
				x0, -- 225
				CT_B, -- 225
				x1 - x0 + 1, -- 225
				H - CT_B, -- 225
				C_PAPER, -- 225
				a -- 225
			) -- 225
			i = i + 1 -- 218
		end -- 218
	end -- 218
	block( -- 229
		layer, -- 229
		0, -- 229
		BASE_T - 1.5, -- 229
		W, -- 229
		3, -- 229
		C_INK, -- 229
		0.55 -- 229
	) -- 229
	local TITLE = failed and "田 荒 了" or (res.done >= 8 and "八块都收了" or ("收了 " .. tostring(res.done)) .. " 块") -- 232
	local L1 = failed and "水断了三天，那块田就干了。" or "水从水门进来，绕了八块田。" -- 233
	local L2 = failed and "八块田，一块都不能断水。" or "最后一块熟的时候，天快亮了。" -- 234
	local FOOT = failed and "田一荒，城里的米就断了。" or "城里有粮，围多久都撑得住。" -- 235
	local GRADE = failed and "丙" or (res.secs <= 100 and "甲" or (res.secs <= 150 and "乙" or "丙")) -- 236
	local iSealBg = block( -- 238
		layer, -- 238
		112, -- 238
		196, -- 238
		38, -- 238
		38, -- 238
		C_VERM -- 238
	) -- 238
	local iSealTx = label( -- 239
		layer, -- 239
		FONT_B, -- 239
		27, -- 239
		C_PAPER2, -- 239
		131, -- 239
		226, -- 239
		0.5, -- 239
		0 -- 239
	) -- 239
	iSealTx.text = failed and "败" or "胜" -- 240
	local iTag = label( -- 241
		layer, -- 241
		FONT_B, -- 241
		18, -- 241
		Color(36, 73, 70, 140), -- 241
		158, -- 241
		226, -- 241
		0, -- 241
		4 -- 241
	) -- 241
	iTag.text = "关 后" -- 242
	local iTitle = label( -- 244
		layer, -- 244
		FONT_B, -- 244
		72, -- 244
		failed and C_DEEP or C_INK, -- 244
		106, -- 244
		322, -- 244
		0, -- 244
		11 -- 244
	) -- 244
	iTitle.text = TITLE -- 245
	local iRule = block( -- 247
		layer, -- 247
		112, -- 247
		346, -- 247
		128, -- 247
		4, -- 247
		C_VERM -- 247
	) -- 247
	local iL1 = label( -- 249
		layer, -- 249
		FONT_B, -- 249
		24, -- 249
		Color(36, 73, 70, 224), -- 249
		112, -- 249
		402, -- 249
		0, -- 249
		1.4 -- 249
	) -- 249
	iL1.text = L1 -- 250
	local iL2 = label( -- 251
		layer, -- 251
		FONT_B, -- 251
		24, -- 251
		Color(36, 73, 70, 224), -- 251
		112, -- 251
		440, -- 251
		0, -- 251
		1.4 -- 251
	) -- 251
	iL2.text = L2 -- 252
	local iSep = block( -- 254
		layer, -- 254
		112, -- 254
		482, -- 254
		448, -- 254
		2, -- 254
		C_INK, -- 254
		0.32 -- 254
	) -- 254
	local stats = { -- 257
		{ -- 258
			"用时", -- 258
			tostring(res.secs) .. " 秒", -- 258
			math.min( -- 258
				1, -- 258
				90 / math.max(30, res.secs) -- 258
			) -- 258
		}, -- 258
		{ -- 259
			"灌熟", -- 259
			tostring(res.done) .. " / 8 块", -- 259
			res.done / 8 -- 259
		}, -- 259
		{"最长水头", failed and "4 格" or "6 格", failed and 0.55 or 0.8}, -- 260
		{ -- 261
			"荒田", -- 261
			tostring(res.dead) .. " 块", -- 261
			res.dead > 0 and 0.4 or 0 -- 261
		} -- 261
	} -- 261
	local statKeys = {} -- 263
	local statVals = {} -- 264
	local statBars = {} -- 265
	local statBarBg = {} -- 266
	do -- 266
		local i = 0 -- 267
		while i < #stats do -- 267
			local y = 516 + i * 25 -- 268
			statKeys[#statKeys + 1] = label( -- 269
				layer, -- 269
				FONT_R, -- 269
				16, -- 269
				Color(36, 73, 70, 153), -- 269
				112, -- 269
				y + 4, -- 269
				0, -- 269
				1.2 -- 269
			) -- 269
			statKeys[i + 1].text = stats[i + 1][1] -- 270
			statVals[#statVals + 1] = label( -- 271
				layer, -- 271
				FONT_B, -- 271
				17, -- 271
				C_INK, -- 271
				300, -- 271
				y + 4, -- 271
				1, -- 271
				0.8 -- 271
			) -- 271
			statVals[i + 1].text = stats[i + 1][2] -- 272
			statBarBg[#statBarBg + 1] = block( -- 273
				layer, -- 273
				320, -- 273
				y - 9, -- 273
				180, -- 273
				5, -- 273
				C_INK, -- 273
				0.1 -- 273
			) -- 273
			statBars[#statBars + 1] = block( -- 274
				layer, -- 274
				320, -- 274
				y - 9, -- 274
				180, -- 274
				5, -- 274
				C_INK, -- 274
				0.62 -- 274
			) -- 274
			i = i + 1 -- 267
		end -- 267
	end -- 267
	local iFoot = label( -- 277
		layer, -- 277
		FONT_B, -- 277
		18, -- 277
		Color(36, 73, 70, 204), -- 277
		112, -- 277
		630, -- 277
		0, -- 277
		1.2 -- 277
	) -- 277
	iFoot.text = FOOT -- 278
	local gs = 44 -- 281
	local gx = 560 - gs / 2 -- 281
	local gy = 190 -- 281
	local gradeParts = { -- 282
		block( -- 283
			layer, -- 283
			gx, -- 283
			gy, -- 283
			gs, -- 283
			2.6, -- 283
			C_VERM -- 283
		), -- 283
		block( -- 284
			layer, -- 284
			gx, -- 284
			gy + gs - 2.6, -- 284
			gs, -- 284
			2.6, -- 284
			C_VERM -- 284
		), -- 284
		block( -- 285
			layer, -- 285
			gx, -- 285
			gy, -- 285
			2.6, -- 285
			gs, -- 285
			C_VERM -- 285
		), -- 285
		block( -- 286
			layer, -- 286
			gx + gs - 2.6, -- 286
			gy, -- 286
			2.6, -- 286
			gs, -- 286
			C_VERM -- 286
		) -- 286
	} -- 286
	local gradeTx = label( -- 288
		layer, -- 288
		FONT_B, -- 288
		30, -- 288
		C_VERM, -- 288
		560, -- 288
		gy + 34, -- 288
		0.5, -- 288
		0 -- 288
	) -- 288
	gradeTx.text = GRADE -- 289
	local gradeCap = label( -- 290
		layer, -- 290
		FONT_R, -- 290
		13, -- 290
		Color(36, 73, 70, 115), -- 290
		560, -- 290
		264, -- 290
		0.5, -- 290
		2 -- 290
	) -- 290
	gradeCap.text = "今夜评级" -- 291
	local function mkBtn(x, y, w, h, main, sub) -- 299
		local parts = {} -- 300
		parts[#parts + 1] = block( -- 301
			layer, -- 301
			x + 8, -- 301
			y + 8, -- 301
			w, -- 301
			h, -- 301
			C_INK, -- 301
			0.88 -- 301
		) -- 301
		parts[#parts + 1] = block( -- 302
			layer, -- 302
			x, -- 302
			y, -- 302
			w, -- 302
			h, -- 302
			C_PAPER2 -- 302
		) -- 302
		parts[#parts + 1] = block( -- 303
			layer, -- 303
			x, -- 303
			y, -- 303
			w, -- 303
			3, -- 303
			C_INK, -- 303
			0.95 -- 303
		) -- 303
		parts[#parts + 1] = block( -- 304
			layer, -- 304
			x, -- 304
			y + h - 3, -- 304
			w, -- 304
			3, -- 304
			C_INK, -- 304
			0.95 -- 304
		) -- 304
		parts[#parts + 1] = block( -- 305
			layer, -- 305
			x, -- 305
			y, -- 305
			3, -- 305
			h, -- 305
			C_INK, -- 305
			0.95 -- 305
		) -- 305
		parts[#parts + 1] = block( -- 306
			layer, -- 306
			x + w - 3, -- 306
			y, -- 306
			3, -- 306
			h, -- 306
			C_INK, -- 306
			0.95 -- 306
		) -- 306
		local lb = label( -- 307
			layer, -- 307
			FONT_B, -- 307
			24, -- 307
			C_INK, -- 307
			x + w / 2, -- 307
			y + 38, -- 307
			0.5, -- 307
			10 -- 307
		) -- 307
		lb.text = main -- 308
		local sb = label( -- 309
			layer, -- 309
			FONT_R, -- 309
			13, -- 309
			Color(36, 73, 70, 128), -- 309
			x + w / 2, -- 309
			y + 56, -- 309
			0.5, -- 309
			0.6 -- 309
		) -- 309
		sb.text = sub -- 310
		return { -- 311
			x = x, -- 311
			y = y, -- 311
			w = w, -- 311
			h = h, -- 311
			parts = parts, -- 311
			lb = lb, -- 311
			sub = sb, -- 311
			hov = 0, -- 311
			prs = 0 -- 311
		} -- 311
	end -- 299
	local btns = { -- 314
		failed and mkBtn( -- 315
			112, -- 316
			660, -- 316
			200, -- 316
			60, -- 316
			"重 来", -- 316
			"按 R" -- 316
		) or mkBtn( -- 316
			112, -- 317
			660, -- 317
			200, -- 317
			60, -- 317
			"好", -- 317
			"去看守城的人" -- 317
		), -- 317
		failed and mkBtn( -- 318
			340, -- 319
			660, -- 319
			260, -- 319
			60, -- 319
			"王梓来帮你", -- 319
			"自动演示一遍" -- 319
		) or mkBtn( -- 319
			340, -- 320
			660, -- 320
			260, -- 320
			60, -- 320
			"再打一次", -- 320
			"按 R" -- 320
		) -- 320
	} -- 320
	local iFootLine = label( -- 323
		layer, -- 323
		FONT_R, -- 323
		13, -- 323
		Color(36, 73, 70, 102), -- 323
		112, -- 323
		764, -- 323
		0, -- 323
		1.2 -- 323
	) -- 323
	iFootLine.text = "永昌堡 · 嘉靖四十年 · 五月 · 夜尽" -- 324
	local T = 0 -- 327
	local ptrX = -999 -- 328
	local ptrY = -999 -- 328
	local ptrDown = false -- 328
	local function ease(t0, dur) -- 330
		local k = math.min( -- 331
			1, -- 331
			math.max(0, (T - t0) / dur) -- 331
		) -- 331
		return 1 - (1 - k) ^ 3 -- 332
	end -- 330
	local function sync(dt) -- 335
		local aWz = ease(0.16, 0.72) -- 337
		face.opacity = aWz -- 338
		face.position = Vec2( -- 339
			856 + (1 - aWz) * 48, -- 339
			H - (350 + math.sin(T * 1.45) * 2.2) -- 339
		) -- 339
		burstDn.opacity = ease(0.1, 0.75) -- 341
		local aSeal = ease(0.34, 0.28) -- 343
		iSealBg.opacity = aSeal -- 344
		iSealTx.opacity = aSeal -- 345
		iTag.opacity = ease(0.42, 0.4) -- 346
		local aTitle = ease(0.46, 0.55) -- 348
		iTitle.opacity = aTitle -- 349
		iTitle.position = Vec2(106 + (1 - aTitle) * 44, H - 322 + 72) -- 350
		iRule.scaleX = math.max( -- 352
			0.01, -- 352
			ease(0.74, 0.42) -- 352
		) -- 352
		iL1.opacity = ease(0.86, 0.5) -- 353
		iL2.opacity = ease(1, 0.5) -- 354
		iSep.scaleX = math.max( -- 355
			0.01, -- 355
			ease(1.1, 0.42) -- 355
		) -- 355
		do -- 355
			local i = 0 -- 357
			while i < #stats do -- 357
				local a = ease(1.1 + i * 0.1, 0.42) -- 358
				statKeys[i + 1].opacity = a -- 359
				statVals[i + 1].opacity = a -- 360
				statBarBg[i + 1].opacity = 0.1 * a -- 361
				statBars[i + 1].opacity = 0.62 * a -- 362
				statBars[i + 1].scaleX = math.max(0.01, stats[i + 1][3] * a) -- 363
				i = i + 1 -- 357
			end -- 357
		end -- 357
		iFoot.opacity = ease(1.3, 0.5) -- 366
		local aG = ease(1.46, 0.26) -- 368
		for ____, gp in ipairs(gradeParts) do -- 369
			gp.opacity = aG -- 369
		end -- 369
		gradeTx.opacity = aG -- 370
		gradeCap.opacity = ease(1.52, 0.4) -- 371
		local aBtn = ease(1.72, 0.5) -- 373
		for ____, b in ipairs(btns) do -- 374
			local inRect = ptrX >= b.x and ptrX <= b.x + b.w and ptrY >= b.y and ptrY <= b.y + b.h -- 375
			b.hov = approach(b.hov, inRect and 1 or 0, dt / 0.14) -- 376
			b.prs = approach(b.prs, inRect and ptrDown and 1 or 0, dt / 0.08) -- 377
			local hv = b.hov * b.hov * (3 - 2 * b.hov) -- 378
			local off = 3 * hv + 2 * b.prs -- 379
			b.parts[2].position = Vec2(b.x + off, H - (b.y + off)) -- 381
			b.parts[3].position = Vec2(b.x + off, H - (b.y + off)) -- 382
			b.parts[4].position = Vec2(b.x + off, H - (b.y + b.h - 3 + off)) -- 383
			b.parts[5].position = Vec2(b.x + off, H - (b.y + off)) -- 384
			b.parts[6].position = Vec2(b.x + b.w - 3 + off, H - (b.y + off)) -- 385
			b.lb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 38 + off) + 24) -- 386
			b.sub.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 56 + off) + 13) -- 387
			b.parts[2].color = mixColor( -- 388
				C_PAPER2, -- 388
				Color(206, 206, 206, 255), -- 388
				hv * 0.55 + b.prs * 0.35 -- 388
			) -- 388
			local a = aBtn -- 389
			do -- 389
				local k = 0 -- 390
				while k < #b.parts do -- 390
					b.parts[k + 1].opacity = (k == 0 and 0.88 or 1) * a -- 390
					k = k + 1 -- 390
				end -- 390
			end -- 390
			b.lb.opacity = a -- 391
			b.sub.opacity = a -- 392
		end -- 392
		iFootLine.opacity = ease(1.95, 0.6) -- 395
	end -- 335
	local function hitBtn(x, y) -- 399
		do -- 399
			local i = 0 -- 400
			while i < #btns do -- 400
				local b = btns[i + 1] -- 401
				if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then -- 401
					return i -- 402
				end -- 402
				i = i + 1 -- 400
			end -- 400
		end -- 400
		return -1 -- 404
	end -- 399
	local pendingAct = -1 -- 411
	local function activate(i) -- 413
		if i < 0 or pendingAct >= 0 then -- 413
			return -- 414
		end -- 414
		pendingAct = i -- 415
	end -- 413
	local function runPending() -- 418
		if pendingAct < 0 then -- 418
			return false -- 419
		end -- 419
		local i = pendingAct -- 420
		pendingAct = -1 -- 421
		local goNext = not failed and i == 0 -- 422
		local goAuto = failed and i == 1 and opts.onAuto ~= nil -- 423
		frame:destroy() -- 424
		if goNext then -- 424
			opts.onNext() -- 425
		elseif goAuto and opts.onAuto ~= nil then -- 425
			opts.onAuto() -- 426
		else -- 426
			opts.onRetry() -- 427
		end -- 427
		return true -- 428
	end -- 418
	frame.input:onMouseMove(function(touch) -- 431
		ptrX = touch.location.x -- 432
		ptrY = 800 - touch.location.y -- 433
	end) -- 431
	frame.input:onTapBegan(function(touch) -- 435
		ptrX = touch.location.x -- 436
		ptrY = 800 - touch.location.y -- 437
		ptrDown = true -- 438
	end) -- 435
	frame.input:onTapEnded(function() -- 440
		ptrDown = false -- 440
	end) -- 440
	frame.input:onTapped(function(touch) -- 441
		local ty = 800 - touch.location.y -- 442
		if T < 1 then -- 442
			return -- 443
		end -- 443
		activate(hitBtn(touch.location.x, ty)) -- 444
	end) -- 441
	frame.root:onKeyDown(function(key) -- 447
		if key == "R" then -- 447
			activate(1) -- 448
			return -- 448
		end -- 448
		if key == "Return" or key == "Space" then -- 448
			if T < 1 then -- 448
				return -- 450
			end -- 450
			activate(0) -- 451
		end -- 451
	end) -- 447
	frame.root:schedule(function(dt) -- 455
		if runPending() then -- 455
			return true -- 456
		end -- 456
		frame:fit() -- 457
		T = T + dt -- 458
		sync(dt) -- 459
		return false -- 460
	end) -- 455
	print(((("[Level3Result] " .. (failed and "失败页" or "结算页")) .. " 用时 ") .. tostring(res.secs)) .. "s") -- 463
end -- 73
return ____exports -- 73