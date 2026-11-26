-- [ts]: Level2Play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 15
local Audio = ____Dora.Audio -- 16
local Color = ____Dora.Color -- 17
local Label = ____Dora.Label -- 18
local Node = ____Dora.Node -- 19
local Size = ____Dora.Size -- 20
local Sprite = ____Dora.Sprite -- 21
local Vec2 = ____Dora.Vec2 -- 22
local W = 1280 -- 25
local H = 800 -- 26
local HUD_H = 72 -- 29
local CT_T = 72 -- 30
local CT_B = 170 -- 30
local RM_T = 170 -- 31
local RM_B = 686 -- 31
local FOOT_T = 678 -- 32
local FOOT_B = 702 -- 32
local BASE_T = 702 -- 33
local JUDGE_Y = 702 -- 34
local LANE_W = 168 -- 36
local LANE_GAP = 24 -- 36
local LANE_X0 = 364 -- 36
local LANE_CX = {LANE_X0 + LANE_W / 2, LANE_X0 + LANE_W + LANE_GAP + LANE_W / 2, LANE_X0 + (LANE_W + LANE_GAP) * 2 + LANE_W / 2} -- 37
local LANE_R = LANE_X0 + 3 * LANE_W + 2 * LANE_GAP -- 42
local FALL_DIST = JUDGE_Y - RM_T -- 43
local WZ_X = 40 -- 45
local WZ_W = 266 -- 45
local WZ_H = 357 -- 45
local WZ_BOT = 708 -- 45
local C_PAPER = Color(237, 227, 200, 255) -- 48
local C_PAPER2 = Color(243, 234, 211, 255) -- 49
local C_SANDD = Color(197, 188, 156, 255) -- 50
local C_SEAM = Color(168, 159, 127, 255) -- 51
local C_TRAY = Color(186, 176, 144, 255) -- 52
local C_TEAL = Color(90, 121, 104, 255) -- 53
local C_INK = Color(36, 73, 70, 255) -- 54
local C_DEEP = Color(23, 51, 48, 255) -- 55
local C_VERM = Color(163, 59, 42, 255) -- 56
local C_BEAM = Color(75, 100, 89, 255) -- 59
local C_FOOT = Color(174, 172, 144, 255) -- 60
local C_MILLBASE = Color(207, 197, 168, 255) -- 61
local C_MULLION = Color(141, 145, 122, 255) -- 62
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 64
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 65
local BPM = 88 -- 68
local SPB = 60 / BPM -- 68
local FALL_BEATS = 3 -- 68
local TOTAL_BEATS = 128 -- 68
local PREROLL = 1.4 -- 68
local PX_PER_SEC = FALL_DIST / (FALL_BEATS * SPB) -- 69
local SEGS = {{ -- 72
	name = "戌时", -- 73
	tag = "一更 · 只一台在响", -- 73
	from = 0, -- 73
	to = 24, -- 73
	lanes = {1} -- 73
}, { -- 73
	name = "子时", -- 74
	tag = "三更 · 两台交替", -- 74
	from = 24, -- 74
	to = 56, -- 74
	lanes = {0, 1} -- 74
}, { -- 74
	name = "寅时", -- 75
	tag = "五更 · 三台全开", -- 75
	from = 56, -- 75
	to = 88, -- 75
	lanes = {0, 1, 2} -- 75
}, { -- 75
	name = "卯时", -- 76
	tag = "天将亮 · 加花", -- 76
	from = 88, -- 76
	to = 128, -- 76
	lanes = {0, 1, 2} -- 76
}} -- 76
local THUD = {"Audio/lv2_thud1.wav", "Audio/lv2_thud2.wav", "Audio/lv2_thud3.wav"} -- 79
local MISS_SFX = "Audio/lv2_miss.wav" -- 80
local BGM = "Audio/lv2_bgm.ogg" -- 81
local WIN_BASE = 0.14 -- 83
local WIN_MUL = {1, 0.92, 0.85, 0.79} -- 84
function ____exports.createLevel2Play(parent, opts) -- 114
	local syncIntro, endRoot, syncEnd, beginPlay -- 114
	local function block(p, x, y, w, h, c, al) -- 118
		if al == nil then -- 118
			al = 1 -- 119
		end -- 119
		local s = Sprite("Image/StartUI/white.png") -- 121
		s.size = Size( -- 122
			math.abs(w), -- 122
			math.abs(h) -- 122
		) -- 122
		s.anchor = Vec2(0, 1) -- 123
		s.color = c -- 124
		s.opacity = al -- 125
		s.position = Vec2(x, H - y) -- 126
		s.visible = true -- 127
		s:addTo(p) -- 128
		return s -- 129
	end -- 118
	local function img(p, file, x, y, w, h) -- 133
		local s = Sprite(file) -- 134
		s.size = Size(w, h) -- 135
		s.anchor = Vec2(0, 1) -- 136
		s.position = Vec2(x, H - y) -- 137
		s.visible = true -- 138
		s:addTo(p) -- 139
		return s -- 140
	end -- 133
	local function label(p, font, size, c, x, y, ax, ls) -- 145
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 149
		lb.color = c -- 150
		lb.anchor = Vec2(ax, 1) -- 151
		lb.scaleX = 0.5 -- 152
		lb.scaleY = 0.5 -- 153
		lb.position = Vec2(x, H - y + size) -- 154
		if ls > 0 then -- 154
			lb.spacing = math.floor(ls * 2 + 0.5) -- 155
		end -- 155
		lb.visible = true -- 156
		lb:addTo(p) -- 157
		return lb -- 158
	end -- 145
	local function ease3(t, t0, dur) -- 163
		local k = math.min( -- 164
			1, -- 164
			math.max(0, (t - t0) / dur) -- 164
		) -- 164
		return 1 - (1 - k) ^ 3 -- 165
	end -- 163
	local function approach(v, target, step) -- 168
		return v < target and math.min(target, v + step) or math.max(target, v - step) -- 169
	end -- 168
	local layer = Node() -- 171
	layer.size = Size(W, H) -- 172
	layer.anchor = Vec2(0, 0) -- 173
	layer.position = Vec2(0, 0) -- 174
	layer:addTo(parent) -- 175
	img( -- 180
		layer, -- 180
		"Image/StartUI/lv2_paper.png", -- 180
		0, -- 180
		0, -- 180
		W, -- 180
		H -- 180
	) -- 180
	img( -- 183
		layer, -- 183
		"Image/StartUI/lv2_crenel.png", -- 183
		0, -- 183
		CT_T, -- 183
		W, -- 183
		CT_B - CT_T -- 183
	) -- 183
	local guard = img( -- 186
		layer, -- 186
		"Image/StartUI/lv2_guard.png", -- 186
		1058, -- 186
		CT_B - 4 - 114, -- 186
		64, -- 186
		114 -- 186
	) -- 186
	local playRoot = Node() -- 192
	playRoot.size = Size(W, H) -- 193
	playRoot.anchor = Vec2(0, 0) -- 194
	playRoot.position = Vec2(0, 0) -- 195
	playRoot:addTo(layer) -- 196
	img( -- 198
		playRoot, -- 198
		"Image/StartUI/lv2_wall.png", -- 198
		0, -- 198
		RM_T, -- 198
		W, -- 198
		FOOT_B - RM_T -- 198
	) -- 198
	block( -- 205
		playRoot, -- 205
		0, -- 205
		140, -- 205
		W, -- 205
		30, -- 205
		C_BEAM -- 205
	) -- 205
	block( -- 206
		playRoot, -- 206
		0, -- 206
		141, -- 206
		W, -- 206
		3, -- 206
		C_PAPER, -- 206
		0.42 -- 206
	) -- 206
	block( -- 207
		playRoot, -- 207
		0, -- 207
		149, -- 207
		W, -- 207
		1.4, -- 207
		C_INK, -- 207
		0.16 -- 207
	) -- 207
	block( -- 208
		playRoot, -- 208
		0, -- 208
		157, -- 208
		W, -- 208
		1.4, -- 208
		C_INK, -- 208
		0.16 -- 208
	) -- 208
	block( -- 209
		playRoot, -- 209
		0, -- 209
		168.4, -- 209
		W, -- 209
		3.2, -- 209
		C_INK, -- 209
		0.95 -- 209
	) -- 209
	do -- 209
		local i = 0 -- 211
		while i < 6 do -- 211
			block( -- 212
				playRoot, -- 212
				0, -- 212
				170 + i * 9.67, -- 212
				LANE_X0, -- 212
				9.67, -- 212
				C_INK, -- 212
				0.24 * (1 - i / 6) -- 212
			) -- 212
			block( -- 213
				playRoot, -- 213
				LANE_R, -- 213
				170 + i * 9.67, -- 213
				W - LANE_R, -- 213
				9.67, -- 213
				C_INK, -- 213
				0.24 * (1 - i / 6) -- 213
			) -- 213
			i = i + 1 -- 211
		end -- 211
	end -- 211
	local SHAFT_H = JUDGE_Y + 6 - RM_T -- 219
	local shafts = {} -- 220
	local shaftDim = {} -- 221
	local idleTips = {} -- 222
	do -- 222
		local i = 0 -- 223
		while i < 3 do -- 223
			local x = LANE_X0 + i * (LANE_W + LANE_GAP) -- 224
			shafts[#shafts + 1] = img( -- 225
				playRoot, -- 225
				"Image/StartUI/lv2_shaft.png", -- 225
				x, -- 225
				RM_T, -- 225
				LANE_W, -- 225
				SHAFT_H -- 225
			) -- 225
			local dim = block( -- 227
				playRoot, -- 227
				x, -- 227
				RM_T, -- 227
				LANE_W, -- 227
				JUDGE_Y - RM_T, -- 227
				C_DEEP, -- 227
				0.1 -- 227
			) -- 227
			dim.visible = false -- 228
			shaftDim[#shaftDim + 1] = dim -- 229
			local tip = label( -- 230
				playRoot, -- 230
				FONT_B, -- 230
				12, -- 230
				Color(36, 73, 70, 87), -- 230
				LANE_CX[i + 1] - 18, -- 230
				RM_T + 48 + 12, -- 230
				0, -- 230
				3 -- 230
			) -- 230
			tip.text = "闲 置" -- 231
			tip.opacity = 0 -- 232
			idleTips[#idleTips + 1] = tip -- 233
			i = i + 1 -- 223
		end -- 223
	end -- 223
	for ____, cx in ipairs({LANE_X0 + LANE_W + LANE_GAP / 2, LANE_X0 + (LANE_W + LANE_GAP) * 2 - LANE_GAP / 2}) do -- 239
		block( -- 240
			playRoot, -- 240
			cx - 4, -- 240
			RM_T, -- 240
			8, -- 240
			JUDGE_Y - RM_T + 4, -- 240
			C_MULLION -- 240
		) -- 240
		block( -- 241
			playRoot, -- 241
			cx - 4, -- 241
			RM_T, -- 241
			1.6, -- 241
			JUDGE_Y - RM_T + 4, -- 241
			C_INK, -- 241
			0.45 -- 241
		) -- 241
		block( -- 242
			playRoot, -- 242
			cx + 3.2, -- 242
			RM_T, -- 242
			1.6, -- 242
			JUDGE_Y - RM_T + 4, -- 242
			C_INK, -- 242
			0.45 -- 242
		) -- 242
	end -- 242
	img( -- 247
		playRoot, -- 247
		"Image/StartUI/lv2_basket.png", -- 247
		1050 - 62, -- 247
		616 - 100, -- 247
		124, -- 247
		178 -- 247
	) -- 247
	local BS = 46 / 58 -- 248
	img( -- 249
		playRoot, -- 249
		"Image/StartUI/lv2_basket.png", -- 249
		1160 - 62 * BS, -- 250
		628 - 100 * BS, -- 250
		124 * BS, -- 250
		178 * BS -- 250
	) -- 250
	block( -- 253
		playRoot, -- 253
		0, -- 253
		BASE_T, -- 253
		W, -- 253
		H - BASE_T, -- 253
		C_TRAY -- 253
	) -- 253
	block( -- 254
		playRoot, -- 254
		0, -- 254
		BASE_T - 2, -- 254
		W, -- 254
		4, -- 254
		C_INK, -- 254
		0.95 -- 254
	) -- 254
	do -- 254
		local x = 26 -- 255
		while x < W do -- 255
			block( -- 256
				playRoot, -- 256
				x, -- 256
				BASE_T + 12, -- 256
				1.8, -- 256
				H - BASE_T - 12, -- 256
				C_INK, -- 256
				0.09 -- 256
			) -- 256
			x = x + 168 -- 255
		end -- 255
	end -- 255
	local SACK_W = 112 -- 261
	local SACK_H = 102 -- 261
	local SACK_CX = 56 -- 261
	local SACK_BY = 88 -- 261
	img( -- 262
		playRoot, -- 262
		"Image/StartUI/lv2_sack.png", -- 262
		118 - SACK_CX, -- 262
		798 - SACK_BY, -- 262
		SACK_W, -- 262
		SACK_H -- 262
	) -- 262
	local SS = 82 / 104 -- 263
	img( -- 264
		playRoot, -- 264
		"Image/StartUI/lv2_sack.png", -- 264
		248 - SACK_CX * SS, -- 265
		798 - SACK_BY * SS, -- 265
		SACK_W * SS, -- 265
		SACK_H * SS -- 265
	) -- 265
	local SS2 = 96 / 104 -- 266
	img( -- 267
		playRoot, -- 267
		"Image/StartUI/lv2_sack.png", -- 267
		1118 - SACK_CX * SS2, -- 268
		798 - SACK_BY * SS2, -- 268
		SACK_W * SS2, -- 268
		SACK_H * SS2 -- 268
	) -- 268
	do -- 268
		local i = 0 -- 275
		while i < 16 do -- 275
			local bw = 21 -- 276
			local t = (i * bw + bw / 2) / 336 -- 280
			local al = t <= 0.74 and 0.5 + (0.44 - 0.5) * (t / 0.74) or 0.44 * (1 - (t - 0.74) / 0.26) -- 281
			block( -- 284
				playRoot, -- 284
				i * bw, -- 284
				316, -- 284
				bw + 0.5, -- 284
				FOOT_T - 316, -- 284
				C_PAPER2, -- 284
				math.max(0, al) -- 284
			) -- 284
			i = i + 1 -- 275
		end -- 275
	end -- 275
	block( -- 286
		playRoot, -- 286
		0, -- 286
		315, -- 286
		292, -- 286
		2.2, -- 286
		C_INK, -- 286
		0.13 -- 286
	) -- 286
	local wangzi = img( -- 287
		playRoot, -- 287
		"Image/StartUI/face_smile.png", -- 287
		WZ_X, -- 287
		WZ_BOT - WZ_H, -- 287
		WZ_W, -- 287
		WZ_H -- 287
	) -- 287
	local wangziLaugh = img( -- 289
		playRoot, -- 289
		"Image/StartUI/face_laugh.png", -- 289
		WZ_X, -- 289
		WZ_BOT - WZ_H, -- 289
		WZ_W, -- 289
		WZ_H -- 289
	) -- 289
	wangziLaugh.visible = false -- 290
	local POOL = 18 -- 294
	local kangsN = {} -- 297
	local kangsH = {} -- 298
	local kangsM = {} -- 299
	do -- 299
		local i = 0 -- 300
		while i < POOL do -- 300
			local a = img( -- 301
				playRoot, -- 301
				"Image/StartUI/lv2_kang.png", -- 301
				-400, -- 301
				-200, -- 301
				168, -- 301
				30 -- 301
			) -- 301
			a.opacity = 0 -- 301
			local b = img( -- 302
				playRoot, -- 302
				"Image/StartUI/lv2_kang_hit.png", -- 302
				-400, -- 302
				-200, -- 302
				168, -- 302
				30 -- 302
			) -- 302
			b.opacity = 0 -- 302
			local c = img( -- 303
				playRoot, -- 303
				"Image/StartUI/lv2_kang_miss.png", -- 303
				-400, -- 303
				-200, -- 303
				168, -- 303
				30 -- 303
			) -- 303
			c.opacity = 0 -- 303
			kangsN[#kangsN + 1] = a -- 304
			kangsH[#kangsH + 1] = b -- 304
			kangsM[#kangsM + 1] = c -- 304
			i = i + 1 -- 300
		end -- 300
	end -- 300
	local judgeBand = {} -- 308
	local judgeLine = {} -- 309
	do -- 309
		local i = 0 -- 310
		while i < 3 do -- 310
			local x = LANE_X0 + i * (LANE_W + LANE_GAP) -- 311
			judgeLine[#judgeLine + 1] = block( -- 312
				playRoot, -- 312
				x, -- 312
				JUDGE_Y - 5, -- 312
				LANE_W, -- 312
				5, -- 312
				C_INK, -- 312
				0.92 -- 312
			) -- 312
			judgeLine[#judgeLine + 1] = block( -- 313
				playRoot, -- 313
				x + LANE_W / 2 - 14, -- 313
				JUDGE_Y - 5, -- 313
				28, -- 313
				5, -- 313
				C_VERM -- 313
			) -- 313
			local band = block( -- 314
				playRoot, -- 314
				x, -- 314
				JUDGE_Y - 16, -- 314
				LANE_W, -- 314
				12, -- 314
				C_VERM, -- 314
				0 -- 314
			) -- 314
			judgeBand[#judgeBand + 1] = band -- 315
			i = i + 1 -- 310
		end -- 310
	end -- 310
	local MILL_Y = 706 -- 322
	local MILL_H = 88 -- 322
	local MILL_CY = MILL_Y + MILL_H / 2 - 1 -- 322
	local millFrames = {} -- 323
	local millKeys = {} -- 324
	local millDiscs = {} -- 325
	local millHis = {} -- 326
	local millIdles = {} -- 327
	local millHisIdle = {} -- 328
	local millEdges = {} -- 329
	local millMiss = {} -- 330
	local millSparks = {} -- 331
	do -- 331
		local i = 0 -- 332
		while i < 3 do -- 332
			local x = LANE_X0 + i * (LANE_W + LANE_GAP) -- 333
			block( -- 334
				playRoot, -- 334
				x + 5, -- 334
				MILL_Y + 5, -- 334
				LANE_W, -- 334
				MILL_H, -- 334
				C_INK, -- 334
				0.88 -- 334
			) -- 334
			millFrames[#millFrames + 1] = block( -- 335
				playRoot, -- 335
				x, -- 335
				MILL_Y, -- 335
				LANE_W, -- 335
				MILL_H, -- 335
				C_MILLBASE -- 335
			) -- 335
			millEdges[#millEdges + 1] = block( -- 338
				playRoot, -- 338
				x + 1.3, -- 338
				MILL_Y + 1.3, -- 338
				LANE_W - 2.6, -- 338
				2.6, -- 338
				C_INK, -- 338
				0.9 -- 338
			) -- 338
			millEdges[#millEdges + 1] = block( -- 339
				playRoot, -- 339
				x + 1.3, -- 339
				MILL_Y + MILL_H - 3.9, -- 339
				LANE_W - 2.6, -- 339
				2.6, -- 339
				C_INK, -- 339
				0.9 -- 339
			) -- 339
			millEdges[#millEdges + 1] = block( -- 340
				playRoot, -- 340
				x + 1.3, -- 340
				MILL_Y + 1.3, -- 340
				2.6, -- 340
				MILL_H - 2.6, -- 340
				C_INK, -- 340
				0.9 -- 340
			) -- 340
			millEdges[#millEdges + 1] = block( -- 341
				playRoot, -- 341
				x + LANE_W - 3.9, -- 341
				MILL_Y + 1.3, -- 341
				2.6, -- 341
				MILL_H - 2.6, -- 341
				C_INK, -- 341
				0.9 -- 341
			) -- 341
			local px36 = LANE_CX[i + 1] - 36 -- 344
			local py36 = MILL_CY - 36 -- 344
			local dn = img( -- 345
				playRoot, -- 345
				"Image/StartUI/lv2_mill.png", -- 345
				px36, -- 345
				py36, -- 345
				72, -- 345
				72 -- 345
			) -- 345
			local di = img( -- 346
				playRoot, -- 346
				"Image/StartUI/lv2_mill_idle.png", -- 346
				px36, -- 346
				py36, -- 346
				72, -- 346
				72 -- 346
			) -- 346
			local hn = img( -- 347
				playRoot, -- 347
				"Image/StartUI/lv2_mill_hi.png", -- 347
				px36, -- 347
				py36, -- 347
				72, -- 347
				72 -- 347
			) -- 347
			local hi2 = img( -- 348
				playRoot, -- 348
				"Image/StartUI/lv2_mill_hi_idle.png", -- 348
				px36, -- 348
				py36, -- 348
				72, -- 348
				72 -- 348
			) -- 348
			di.visible = false -- 349
			hn.opacity = 0 -- 349
			hi2.opacity = 0 -- 349
			millDiscs[#millDiscs + 1] = dn -- 350
			millIdles[#millIdles + 1] = di -- 351
			millHis[#millHis + 1] = hn -- 352
			millHisIdle[#millHisIdle + 1] = hi2 -- 353
			local sp12 = img( -- 356
				playRoot, -- 356
				"Image/StartUI/lv2_spark12.png", -- 356
				px36 - 32, -- 356
				py36 - 32, -- 356
				136, -- 356
				136 -- 356
			) -- 356
			sp12.opacity = 0 -- 357
			sp12.visible = false -- 358
			millSparks[#millSparks + 1] = sp12 -- 359
			millMiss[#millMiss + 1] = block( -- 361
				playRoot, -- 361
				x + 4, -- 361
				MILL_Y + MILL_H - 9, -- 361
				LANE_W - 8, -- 361
				6, -- 361
				C_VERM, -- 361
				0 -- 361
			) -- 361
			local kl = label( -- 364
				playRoot, -- 364
				FONT_B, -- 364
				14, -- 364
				Color(36, 73, 70, 185), -- 364
				x + LANE_W - 18, -- 364
				MILL_Y + MILL_H - 12, -- 364
				1, -- 364
				1 -- 364
			) -- 364
			kl.text = ({"1", "2", "3"})[i + 1] -- 365
			millKeys[#millKeys + 1] = kl -- 366
			i = i + 1 -- 332
		end -- 332
	end -- 332
	local PART_N = 36 -- 371
	local partSprites = {} -- 374
	local partFills = {} -- 375
	do -- 375
		local i = 0 -- 376
		while i < PART_N do -- 376
			local b = block( -- 377
				playRoot, -- 377
				0, -- 377
				0, -- 377
				5.2, -- 377
				5.2, -- 377
				C_INK -- 377
			) -- 377
			b.opacity = 0 -- 378
			partSprites[#partSprites + 1] = b -- 379
			local f = block( -- 380
				playRoot, -- 380
				0, -- 380
				0, -- 380
				4, -- 380
				4, -- 380
				C_PAPER2 -- 380
			) -- 380
			f.opacity = 0 -- 381
			partFills[#partFills + 1] = f -- 382
			i = i + 1 -- 376
		end -- 376
	end -- 376
	local particles = {} -- 385
	local function spawnHitFx(lane) -- 387
		local cx = LANE_CX[lane + 1] -- 388
		local cy = JUDGE_Y - 8 -- 388
		do -- 388
			local i = 0 -- 389
			while i < 6 do -- 389
				local a = -math.pi / 2 + (i - 2.5) * 0.42 + (math.random() - 0.5) * 0.3 -- 390
				particles[#particles + 1] = { -- 391
					x = cx + (math.random() - 0.5) * LANE_W * 0.6, -- 392
					y = cy, -- 393
					vx = math.cos(a) * (60 + math.random() * 90), -- 394
					vy = math.sin(a) * (90 + math.random() * 70), -- 395
					s = 3 + math.random() * 3, -- 396
					r = math.random() * math.pi, -- 397
					life = 1 -- 398
				} -- 398
				i = i + 1 -- 389
			end -- 389
		end -- 389
		if #particles > PART_N then -- 389
			__TS__ArraySplice(particles, 0, #particles - PART_N) -- 401
		end -- 401
	end -- 387
	local hudRoot = Node() -- 405
	hudRoot.size = Size(W, H) -- 406
	hudRoot.anchor = Vec2(0, 0) -- 407
	hudRoot.position = Vec2(0, 0) -- 408
	hudRoot:addTo(playRoot) -- 409
	block( -- 411
		hudRoot, -- 411
		0, -- 411
		0, -- 411
		W, -- 411
		HUD_H, -- 411
		C_PAPER -- 411
	) -- 411
	block( -- 412
		hudRoot, -- 412
		0, -- 412
		67.6, -- 412
		W, -- 412
		3.4, -- 412
		C_INK, -- 412
		0.95 -- 412
	) -- 412
	block( -- 414
		hudRoot, -- 414
		40, -- 414
		15, -- 414
		34, -- 414
		34, -- 414
		C_VERM -- 414
	) -- 414
	block( -- 415
		hudRoot, -- 415
		40.75, -- 415
		15.75, -- 415
		32.5, -- 415
		1.5, -- 415
		C_INK, -- 415
		0.55 -- 415
	) -- 415
	block( -- 416
		hudRoot, -- 416
		40.75, -- 416
		47.75, -- 416
		32.5, -- 416
		1.5, -- 416
		C_INK, -- 416
		0.55 -- 416
	) -- 416
	block( -- 417
		hudRoot, -- 417
		40.75, -- 417
		15.75, -- 417
		1.5, -- 417
		32.5, -- 417
		C_INK, -- 417
		0.55 -- 417
	) -- 417
	block( -- 418
		hudRoot, -- 418
		72.75, -- 418
		15.75, -- 418
		1.5, -- 418
		32.5, -- 418
		C_INK, -- 418
		0.55 -- 418
	) -- 418
	local sealLb = label( -- 419
		hudRoot, -- 419
		FONT_B, -- 419
		19, -- 419
		C_PAPER2, -- 419
		57, -- 419
		40, -- 419
		0.5, -- 419
		0 -- 419
	) -- 419
	sealLb.text = "贰" -- 420
	local nameLb = label( -- 421
		hudRoot, -- 421
		FONT_B, -- 421
		24, -- 421
		C_INK, -- 421
		86, -- 421
		42, -- 421
		0, -- 421
		4 -- 421
	) -- 421
	nameLb.text = "砻糠计" -- 422
	local subLb = label( -- 423
		hudRoot, -- 423
		FONT_R, -- 423
		11, -- 423
		Color(36, 73, 70, 133), -- 423
		88, -- 423
		61, -- 423
		0, -- 423
		0.8 -- 423
	) -- 423
	subLb.text = "永昌堡 · 嘉靖四十年 · 五月" -- 424
	local PB_X = 372 -- 427
	local PB_Y = 26 -- 427
	local PB_W = 452 -- 427
	local PB_H = 9 -- 427
	local PB_GAP = 6 -- 427
	local pbFill = {} -- 428
	local pbName = {} -- 429
	local pbTick = {} -- 430
	local pbEdge = {} -- 431
	local px = PB_X -- 432
	do -- 432
		local i = 0 -- 433
		while i < #SEGS do -- 433
			local seg = SEGS[i + 1] -- 434
			local share = (seg.to - seg.from) / TOTAL_BEATS -- 435
			local w = (PB_W - PB_GAP * 3) * share -- 436
			block( -- 437
				hudRoot, -- 437
				px, -- 437
				PB_Y, -- 437
				w, -- 437
				PB_H, -- 437
				C_PAPER2 -- 437
			) -- 437
			pbEdge[#pbEdge + 1] = block( -- 439
				hudRoot, -- 439
				px + 0.8, -- 439
				PB_Y + 0.8, -- 439
				w - 1.6, -- 439
				1.6, -- 439
				C_INK, -- 439
				0.34 -- 439
			) -- 439
			pbEdge[#pbEdge + 1] = block( -- 440
				hudRoot, -- 440
				px + 0.8, -- 440
				PB_Y + PB_H - 2.4, -- 440
				w - 1.6, -- 440
				1.6, -- 440
				C_INK, -- 440
				0.34 -- 440
			) -- 440
			pbEdge[#pbEdge + 1] = block( -- 441
				hudRoot, -- 441
				px + 0.8, -- 441
				PB_Y + 0.8, -- 441
				1.6, -- 441
				PB_H - 1.6, -- 441
				C_INK, -- 441
				0.34 -- 441
			) -- 441
			pbEdge[#pbEdge + 1] = block( -- 442
				hudRoot, -- 442
				px + w - 2.4, -- 442
				PB_Y + 0.8, -- 442
				1.6, -- 442
				PB_H - 1.6, -- 442
				C_INK, -- 442
				0.34 -- 442
			) -- 442
			pbFill[#pbFill + 1] = block( -- 443
				hudRoot, -- 443
				px + 1.6, -- 443
				PB_Y + 1.6, -- 443
				1, -- 443
				PB_H - 3.2, -- 443
				C_VERM -- 443
			) -- 443
			local nm = label( -- 444
				hudRoot, -- 444
				FONT_R, -- 444
				11.5, -- 444
				Color(36, 73, 70, 102), -- 444
				px, -- 444
				PB_Y + 28, -- 444
				0, -- 444
				1.4 -- 444
			) -- 444
			nm.text = seg.name -- 445
			pbName[#pbName + 1] = nm -- 446
			local tk = block( -- 448
				hudRoot, -- 448
				px, -- 448
				PB_Y + 33, -- 448
				26, -- 448
				2, -- 448
				C_VERM -- 448
			) -- 448
			tk.visible = false -- 449
			pbTick[#pbTick + 1] = tk -- 450
			px = px + (w + PB_GAP) -- 451
			i = i + 1 -- 433
		end -- 433
	end -- 433
	local SX = 862 -- 455
	local SY = 26 -- 455
	local SW = 272 -- 455
	local SH = 9 -- 455
	local susLabel = label( -- 456
		hudRoot, -- 456
		FONT_B, -- 456
		11.5, -- 456
		Color(36, 73, 70, 140), -- 456
		SX, -- 456
		SY + 28, -- 456
		0, -- 456
		1.4 -- 456
	) -- 456
	susLabel.text = "疑心" -- 457
	local SBOX = SX + 40 -- 458
	local SBW = SW - 40 -- 458
	block( -- 459
		hudRoot, -- 459
		SBOX, -- 459
		SY, -- 459
		SBW, -- 459
		SH, -- 459
		C_PAPER2 -- 459
	) -- 459
	block( -- 460
		hudRoot, -- 460
		SBOX + 0.9, -- 460
		SY + 0.9, -- 460
		SBW - 1.8, -- 460
		1.8, -- 460
		C_INK, -- 460
		0.8 -- 460
	) -- 460
	block( -- 461
		hudRoot, -- 461
		SBOX + 0.9, -- 461
		SY + SH - 2.7, -- 461
		SBW - 1.8, -- 461
		1.8, -- 461
		C_INK, -- 461
		0.8 -- 461
	) -- 461
	block( -- 462
		hudRoot, -- 462
		SBOX + 0.9, -- 462
		SY + 0.9, -- 462
		1.8, -- 462
		SH - 1.8, -- 462
		C_INK, -- 462
		0.8 -- 462
	) -- 462
	block( -- 463
		hudRoot, -- 463
		SBOX + SBW - 2.7, -- 463
		SY + 0.9, -- 463
		1.8, -- 463
		SH - 1.8, -- 463
		C_INK, -- 463
		0.8 -- 463
	) -- 463
	local susFill = block( -- 464
		hudRoot, -- 464
		SBOX + 2, -- 464
		SY + 2, -- 464
		1, -- 464
		SH - 4, -- 464
		C_INK, -- 464
		0.7 -- 464
	) -- 464
	do -- 464
		local k = 1 -- 465
		while k < 4 do -- 465
			block( -- 466
				hudRoot, -- 466
				SBOX + SBW * k / 4, -- 466
				SY - 2, -- 466
				1.6, -- 466
				SH + 4, -- 466
				C_INK, -- 466
				0.55 -- 466
			) -- 466
			k = k + 1 -- 465
		end -- 465
	end -- 465
	local susTip = label( -- 468
		hudRoot, -- 468
		FONT_B, -- 468
		11, -- 468
		Color(36, 73, 70, 97), -- 468
		SX + SW, -- 468
		SY + 28, -- 468
		1, -- 468
		0.8 -- 468
	) -- 468
	susTip.text = "难度 1/4" -- 469
	block( -- 472
		hudRoot, -- 472
		1192, -- 472
		14, -- 472
		44, -- 472
		44, -- 472
		C_INK, -- 472
		0.04 -- 472
	) -- 472
	block( -- 473
		hudRoot, -- 473
		1192.5, -- 473
		14.5, -- 473
		43, -- 473
		1.6, -- 473
		C_INK, -- 473
		0.55 -- 473
	) -- 473
	block( -- 474
		hudRoot, -- 474
		1192.5, -- 474
		56.5, -- 474
		43, -- 474
		1.6, -- 474
		C_INK, -- 474
		0.55 -- 474
	) -- 474
	block( -- 475
		hudRoot, -- 475
		1192.5, -- 475
		14.5, -- 475
		1.6, -- 475
		43, -- 475
		C_INK, -- 475
		0.55 -- 475
	) -- 475
	block( -- 476
		hudRoot, -- 476
		1234.5, -- 476
		14.5, -- 476
		1.6, -- 476
		43, -- 476
		C_INK, -- 476
		0.55 -- 476
	) -- 476
	img( -- 477
		hudRoot, -- 477
		"Image/StartUI/lv2_gear.png", -- 477
		1192, -- 477
		14, -- 477
		44, -- 477
		44 -- 477
	) -- 477
	local plateRoot = Node() -- 482
	plateRoot.size = Size(W, H) -- 483
	plateRoot.anchor = Vec2(0, 0) -- 484
	plateRoot.position = Vec2(0, 0) -- 485
	plateRoot:addTo(playRoot) -- 486
	local bannerSpark = img( -- 490
		plateRoot, -- 490
		"Image/StartUI/lv2_spark22.png", -- 490
		640 - 232, -- 490
		119 - 232, -- 490
		464, -- 490
		464 -- 490
	) -- 490
	bannerSpark.opacity = 0 -- 491
	local pauseRoot = Node() -- 495
	pauseRoot.size = Size(W, H) -- 496
	pauseRoot.anchor = Vec2(0, 0) -- 497
	pauseRoot.position = Vec2(0, 0) -- 498
	pauseRoot.visible = false -- 499
	pauseRoot:addTo(layer) -- 500
	block( -- 502
		pauseRoot, -- 502
		0, -- 502
		0, -- 502
		W, -- 502
		H, -- 502
		C_DEEP, -- 502
		0.55 -- 502
	) -- 502
	block( -- 503
		pauseRoot, -- 503
		W / 2 - 150 + 9, -- 503
		H / 2 - 66 + 9, -- 503
		300, -- 503
		132, -- 503
		C_INK, -- 503
		0.88 -- 503
	) -- 503
	block( -- 504
		pauseRoot, -- 504
		W / 2 - 150, -- 504
		H / 2 - 66, -- 504
		300, -- 504
		132, -- 504
		C_PAPER2 -- 504
	) -- 504
	block( -- 505
		pauseRoot, -- 505
		W / 2 - 150, -- 505
		H / 2 - 66, -- 505
		300, -- 505
		3, -- 505
		C_INK, -- 505
		0.95 -- 505
	) -- 505
	block( -- 506
		pauseRoot, -- 506
		W / 2 - 150, -- 506
		H / 2 + 63, -- 506
		300, -- 506
		3, -- 506
		C_INK, -- 506
		0.95 -- 506
	) -- 506
	block( -- 507
		pauseRoot, -- 507
		W / 2 - 150, -- 507
		H / 2 - 66, -- 507
		3, -- 507
		132, -- 507
		C_INK, -- 507
		0.95 -- 507
	) -- 507
	block( -- 508
		pauseRoot, -- 508
		W / 2 + 147, -- 508
		H / 2 - 66, -- 508
		3, -- 508
		132, -- 508
		C_INK, -- 508
		0.95 -- 508
	) -- 508
	local pauseT = label( -- 510
		pauseRoot, -- 510
		FONT_B, -- 510
		46, -- 510
		C_INK, -- 510
		W / 2, -- 510
		H / 2 + 4, -- 510
		0.5, -- 510
		8 -- 510
	) -- 510
	pauseT.text = "暂 停" -- 511
	local pauseTip = label( -- 512
		pauseRoot, -- 512
		FONT_R, -- 512
		13, -- 512
		Color(36, 73, 70, 140), -- 512
		W / 2, -- 512
		H / 2 + 34, -- 512
		0.5, -- 512
		2 -- 512
	) -- 512
	pauseTip.text = "按 P 继续" -- 513
	local SET_X = 988 -- 519
	local SET_Y = 68 -- 519
	local SET_W = 248 -- 519
	local SET_H = 204 -- 519
	local PAD = 22 -- 520
	local IX = SET_X + PAD -- 520
	local IW = SET_W - PAD * 2 -- 520
	local setRoot = Node() -- 521
	setRoot.size = Size(W, H) -- 522
	setRoot.anchor = Vec2(0, 0) -- 523
	setRoot.position = Vec2(0, 0) -- 524
	setRoot.visible = false -- 525
	setRoot:addTo(layer) -- 526
	img( -- 530
		setRoot, -- 530
		"Image/StartUI/lv2_panel.png", -- 530
		SET_X, -- 530
		SET_Y, -- 530
		SET_W, -- 530
		SET_H -- 530
	) -- 530
	local audioBgm = 0.7 -- 532
	local audioSfx = 0.8 -- 532
	local setLb1 = label( -- 534
		setRoot, -- 534
		FONT_R, -- 534
		15, -- 534
		Color(36, 73, 70, 230), -- 534
		IX, -- 534
		SET_Y + 30, -- 534
		0, -- 534
		0.8 -- 534
	) -- 534
	setLb1.text = "背景音乐" -- 535
	local setVal1 = label( -- 536
		setRoot, -- 536
		FONT_R, -- 536
		14, -- 536
		Color(90, 121, 104, 242), -- 536
		IX + IW, -- 536
		SET_Y + 30, -- 536
		1, -- 536
		0.6 -- 536
	) -- 536
	local setLb2 = label( -- 537
		setRoot, -- 537
		FONT_R, -- 537
		15, -- 537
		Color(36, 73, 70, 230), -- 537
		IX, -- 537
		SET_Y + 96, -- 537
		0, -- 537
		0.8 -- 537
	) -- 537
	setLb2.text = "音效" -- 538
	local setVal2 = label( -- 539
		setRoot, -- 539
		FONT_R, -- 539
		14, -- 539
		Color(90, 121, 104, 242), -- 539
		IX + IW, -- 539
		SET_Y + 96, -- 539
		1, -- 539
		0.6 -- 539
	) -- 539
	local bar1 = block( -- 542
		setRoot, -- 542
		IX, -- 542
		SET_Y + 46, -- 542
		IW, -- 542
		6, -- 542
		C_INK, -- 542
		0.14 -- 542
	) -- 542
	local fill1 = block( -- 543
		setRoot, -- 543
		IX, -- 543
		SET_Y + 46, -- 543
		IW * audioBgm, -- 543
		6, -- 543
		C_TEAL -- 543
	) -- 543
	local knob1 = block( -- 544
		setRoot, -- 544
		IX + IW * audioBgm - 5, -- 544
		SET_Y + 40, -- 544
		10, -- 544
		18, -- 544
		C_PAPER2 -- 544
	) -- 544
	local bar2 = block( -- 545
		setRoot, -- 545
		IX, -- 545
		SET_Y + 112, -- 545
		IW, -- 545
		6, -- 545
		C_INK, -- 545
		0.14 -- 545
	) -- 545
	local fill2 = block( -- 546
		setRoot, -- 546
		IX, -- 546
		SET_Y + 112, -- 546
		IW * audioSfx, -- 546
		6, -- 546
		C_TEAL -- 546
	) -- 546
	local knob2 = block( -- 547
		setRoot, -- 547
		IX + IW * audioSfx - 5, -- 547
		SET_Y + 106, -- 547
		10, -- 547
		18, -- 547
		C_PAPER2 -- 547
	) -- 547
	local knobEdges = {} -- 548
	do -- 548
		local i = 0 -- 549
		while i < 2 do -- 549
			local ky = i == 0 and SET_Y + 40 or SET_Y + 106 -- 550
			knobEdges[#knobEdges + 1] = block( -- 551
				setRoot, -- 551
				0, -- 551
				ky, -- 551
				10, -- 551
				1.6, -- 551
				C_INK -- 551
			) -- 551
			knobEdges[#knobEdges + 1] = block( -- 552
				setRoot, -- 552
				0, -- 552
				ky + 16.4, -- 552
				10, -- 552
				1.6, -- 552
				C_INK -- 552
			) -- 552
			knobEdges[#knobEdges + 1] = block( -- 553
				setRoot, -- 553
				0, -- 553
				ky, -- 553
				1.6, -- 553
				18, -- 553
				C_INK -- 553
			) -- 553
			knobEdges[#knobEdges + 1] = block( -- 554
				setRoot, -- 554
				8.4, -- 554
				ky, -- 554
				1.6, -- 554
				18, -- 554
				C_INK -- 554
			) -- 554
			i = i + 1 -- 549
		end -- 549
	end -- 549
	block( -- 557
		setRoot, -- 557
		IX, -- 557
		SET_Y + 140, -- 557
		IW, -- 557
		1, -- 557
		C_INK, -- 557
		0.12 -- 557
	) -- 557
	block( -- 560
		setRoot, -- 560
		IX + 0.8, -- 560
		SET_Y + 152.8, -- 560
		IW - 1.6, -- 560
		1.6, -- 560
		C_INK, -- 560
		0.7 -- 560
	) -- 560
	block( -- 561
		setRoot, -- 561
		IX + 0.8, -- 561
		SET_Y + 186.4, -- 561
		IW - 1.6, -- 561
		1.6, -- 561
		C_INK, -- 561
		0.7 -- 561
	) -- 561
	block( -- 562
		setRoot, -- 562
		IX + 0.8, -- 562
		SET_Y + 152.8, -- 562
		1.6, -- 562
		35.2, -- 562
		C_INK, -- 562
		0.7 -- 562
	) -- 562
	block( -- 563
		setRoot, -- 563
		IX + IW - 2.4, -- 563
		SET_Y + 152.8, -- 563
		1.6, -- 563
		35.2, -- 563
		C_INK, -- 563
		0.7 -- 563
	) -- 563
	local setQuit = label( -- 564
		setRoot, -- 564
		FONT_R, -- 564
		16, -- 564
		Color(36, 73, 70, 224), -- 564
		IX + IW / 2, -- 564
		SET_Y + 178, -- 564
		0.5, -- 564
		2.4 -- 564
	) -- 564
	setQuit.text = "返回主菜单" -- 565
	local function syncSet() -- 567
		fill1.size = Size( -- 568
			math.max(1, IW * audioBgm), -- 568
			6 -- 568
		) -- 568
		fill1.anchor = Vec2(0, 1) -- 569
		knob1.position = Vec2(IX + IW * audioBgm - 5, H - (SET_Y + 40)) -- 570
		fill2.size = Size( -- 571
			math.max(1, IW * audioSfx), -- 571
			6 -- 571
		) -- 571
		fill2.anchor = Vec2(0, 1) -- 572
		knob2.position = Vec2(IX + IW * audioSfx - 5, H - (SET_Y + 106)) -- 573
		do -- 573
			local i = 0 -- 574
			while i < 2 do -- 574
				local kx = i == 0 and IX + IW * audioBgm - 5 or IX + IW * audioSfx - 5 -- 575
				local ky = i == 0 and SET_Y + 40 or SET_Y + 106 -- 576
				knobEdges[i * 4 + 1].position = Vec2(kx, H - ky) -- 577
				knobEdges[i * 4 + 1 + 1].position = Vec2(kx, H - (ky + 16.4)) -- 578
				knobEdges[i * 4 + 2 + 1].position = Vec2(kx, H - ky) -- 579
				knobEdges[i * 4 + 3 + 1].position = Vec2(kx + 8.4, H - ky) -- 580
				i = i + 1 -- 574
			end -- 574
		end -- 574
		setVal1.text = tostring(math.floor(audioBgm * 100 + 0.5)) -- 582
		setVal2.text = tostring(math.floor(audioSfx * 100 + 0.5)) -- 583
		Audio.globalVolume = audioSfx -- 586
	end -- 567
	syncSet() -- 588
	local function mkPlate(w, h, off, edge, edgeA, lw, cornerLen, cornerPad, cornerA, cornerColor, fs1, ls1, ls2) -- 595
		local root = Node() -- 601
		root.size = Size(W, H) -- 602
		root.anchor = Vec2(0, 0) -- 603
		root.position = Vec2(0, 0) -- 604
		root.opacity = 0 -- 605
		root.visible = false -- 606
		root:addTo(plateRoot) -- 607
		local x = (W - w) / 2 -- 609
		local pp = {} -- 610
		local function add(s, rx, ry) -- 611
			pp[#pp + 1] = {s = s, rx = rx, ry = ry} -- 612
		end -- 611
		add( -- 615
			block( -- 615
				root, -- 615
				0, -- 615
				0, -- 615
				w, -- 615
				h, -- 615
				C_INK, -- 615
				0.88 -- 615
			), -- 615
			off, -- 615
			off -- 615
		) -- 615
		add( -- 616
			block( -- 616
				root, -- 616
				0, -- 616
				0, -- 616
				w, -- 616
				h, -- 616
				C_PAPER2 -- 616
			), -- 616
			0, -- 616
			0 -- 616
		) -- 616
		add( -- 618
			block( -- 618
				root, -- 618
				0, -- 618
				0, -- 618
				w - lw, -- 618
				lw, -- 618
				edge, -- 618
				edgeA -- 618
			), -- 618
			lw / 2, -- 618
			lw / 2 -- 618
		) -- 618
		add( -- 619
			block( -- 619
				root, -- 619
				0, -- 619
				0, -- 619
				w - lw, -- 619
				lw, -- 619
				edge, -- 619
				edgeA -- 619
			), -- 619
			lw / 2, -- 619
			h - lw * 1.5 -- 619
		) -- 619
		add( -- 620
			block( -- 620
				root, -- 620
				0, -- 620
				0, -- 620
				lw, -- 620
				h - lw, -- 620
				edge, -- 620
				edgeA -- 620
			), -- 620
			lw / 2, -- 620
			lw / 2 -- 620
		) -- 620
		add( -- 621
			block( -- 621
				root, -- 621
				0, -- 621
				0, -- 621
				lw, -- 621
				h - lw, -- 621
				edge, -- 621
				edgeA -- 621
			), -- 621
			w - lw * 1.5, -- 621
			lw / 2 -- 621
		) -- 621
		local cx0 = cornerPad -- 624
		local cy0 = cornerPad -- 624
		local cw = w - cornerPad * 2 -- 625
		local ch = h - cornerPad * 2 -- 625
		local cl = cornerLen -- 626
		local cw2 = lw -- 626
		add( -- 627
			block( -- 627
				root, -- 627
				0, -- 627
				0, -- 627
				cl, -- 627
				cw2, -- 627
				cornerColor, -- 627
				cornerA -- 627
			), -- 627
			cx0, -- 627
			cy0 -- 627
		) -- 627
		add( -- 628
			block( -- 628
				root, -- 628
				0, -- 628
				0, -- 628
				cw2, -- 628
				cl, -- 628
				cornerColor, -- 628
				cornerA -- 628
			), -- 628
			cx0, -- 628
			cy0 -- 628
		) -- 628
		add( -- 629
			block( -- 629
				root, -- 629
				0, -- 629
				0, -- 629
				cl, -- 629
				cw2, -- 629
				cornerColor, -- 629
				cornerA -- 629
			), -- 629
			cx0 + cw - cl, -- 629
			cy0 -- 629
		) -- 629
		add( -- 630
			block( -- 630
				root, -- 630
				0, -- 630
				0, -- 630
				cw2, -- 630
				cl, -- 630
				cornerColor, -- 630
				cornerA -- 630
			), -- 630
			cx0 + cw - cw2, -- 630
			cy0 -- 630
		) -- 630
		add( -- 631
			block( -- 631
				root, -- 631
				0, -- 631
				0, -- 631
				cl, -- 631
				cw2, -- 631
				cornerColor, -- 631
				cornerA -- 631
			), -- 631
			cx0, -- 631
			cy0 + ch - cw2 -- 631
		) -- 631
		add( -- 632
			block( -- 632
				root, -- 632
				0, -- 632
				0, -- 632
				cw2, -- 632
				cl, -- 632
				cornerColor, -- 632
				cornerA -- 632
			), -- 632
			cx0, -- 632
			cy0 + ch - cl -- 632
		) -- 632
		add( -- 633
			block( -- 633
				root, -- 633
				0, -- 633
				0, -- 633
				cl, -- 633
				cw2, -- 633
				cornerColor, -- 633
				cornerA -- 633
			), -- 633
			cx0 + cw - cl, -- 633
			cy0 + ch - cw2 -- 633
		) -- 633
		add( -- 634
			block( -- 634
				root, -- 634
				0, -- 634
				0, -- 634
				cw2, -- 634
				cl, -- 634
				cornerColor, -- 634
				cornerA -- 634
			), -- 634
			cx0 + cw - cw2, -- 634
			cy0 + ch - cl -- 634
		) -- 634
		local t1 = label( -- 636
			root, -- 636
			FONT_B, -- 636
			fs1, -- 636
			C_INK, -- 636
			0, -- 636
			0, -- 636
			0.5, -- 636
			ls1 -- 636
		) -- 636
		local t2 = label( -- 637
			root, -- 637
			FONT_B, -- 637
			11, -- 637
			C_VERM, -- 637
			0, -- 637
			0, -- 637
			0.5, -- 637
			ls2 -- 637
		) -- 637
		local function placeAt(by) -- 641
			for ____, p in ipairs(pp) do -- 642
				p.s.position = Vec2(x + p.rx, H - (by + p.ry)) -- 643
			end -- 643
		end -- 641
		return { -- 646
			root = root, -- 647
			place = function(____, by) -- 648
				placeAt(by) -- 648
			end, -- 648
			t1 = t1, -- 649
			t2 = t2 -- 650
		} -- 650
	end -- 595
	local banner = mkPlate( -- 654
		300, -- 654
		54, -- 654
		7, -- 654
		C_INK, -- 654
		0.95, -- 654
		3, -- 654
		10, -- 654
		4, -- 654
		0.5, -- 654
		C_INK, -- 654
		19, -- 654
		7, -- 654
		2.4 -- 654
	) -- 654
	local knock = mkPlate( -- 655
		404, -- 655
		52, -- 655
		6, -- 655
		C_VERM, -- 655
		0.85, -- 655
		3, -- 655
		11, -- 655
		5, -- 655
		0.55, -- 655
		C_VERM, -- 655
		16, -- 655
		1, -- 655
		0.8 -- 655
	) -- 655
	banner.t1.color = C_INK -- 656
	knock.t1.text = "墙外传来一声闷响。他在试。" -- 657
	knock.t2.text = "他盯得更紧了 —— 判定变窄" -- 658
	local bannerTick = block( -- 661
		plateRoot, -- 661
		0, -- 661
		0, -- 661
		4, -- 661
		54 - 24, -- 661
		C_VERM -- 661
	) -- 661
	bannerTick.visible = false -- 662
	local knockTicks = {} -- 664
	do -- 664
		local i = 0 -- 665
		while i < 6 do -- 665
			local s = block( -- 666
				plateRoot, -- 666
				0, -- 666
				0, -- 666
				14, -- 666
				2.2, -- 666
				C_VERM, -- 666
				0.3 -- 666
			) -- 666
			s.visible = false -- 667
			knockTicks[#knockTicks + 1] = s -- 668
			i = i + 1 -- 665
		end -- 665
	end -- 665
	local elapsed = 0 -- 672
	local state = 0 -- 673
	local suspicion = 0 -- 674
	local combo = 0 -- 675
	local maxCombo = 0 -- 675
	local diff = 0 -- 675
	local hits = 0 -- 676
	local misses = 0 -- 676
	local goods = 0 -- 676
	local suspPeak = 0 -- 677
	local flash = {0, 0, 0} -- 678
	local laneMiss = {0, 0, 0} -- 679
	local segIdx = -1 -- 680
	local segStart = -99 -- 680
	local knockT = 0 -- 680
	local finished = false -- 681
	local startBeat = 0 -- 682
	local seed = 20261122 -- 684
	local function rnd() -- 685
		seed = seed * 1103515245 + 12345 & 2147483647 -- 686
		return seed / 2147483647 -- 687
	end -- 685
	local function rndInt(n) -- 689
		return math.floor(rnd() * n) -- 689
	end -- 689
	local function buildChart() -- 691
		seed = 20261122 -- 692
		local out = {} -- 693
		do -- 693
			local b = 3 -- 701
			while b < 24 do -- 701
				out[#out + 1] = {b = b, lane = 1} -- 701
				b = b + 3 -- 701
			end -- 701
		end -- 701
		do -- 701
			local b = 24 -- 704
			while b < 52 do -- 704
				out[#out + 1] = {b = b, lane = (b - 24) % 4 == 0 and 1 or 0} -- 705
				b = b + 2 -- 704
			end -- 704
		end -- 704
		out[#out + 1] = {b = 52, lane = 1} -- 707
		out[#out + 1] = {b = 54, lane = 0} -- 708
		local prev = 1 -- 710
		local run = 0 -- 710
		do -- 710
			local b = 56 -- 711
			while b < 88 do -- 711
				local lane = 1 -- 712
				local gd = 0 -- 712
				repeat -- 712
					do -- 712
						local r = rnd() -- 714
						lane = r < 0.4 and 1 or (r < 0.7 and 0 or 2) -- 715
						gd = gd + 1 -- 716
					end -- 716
				until not (lane == prev and run >= 1 and gd < 12) -- 716
				run = lane == prev and run + 1 or 0 -- 718
				prev = lane -- 719
				out[#out + 1] = {b = b, lane = lane} -- 720
				b = b + 1 -- 711
			end -- 711
		end -- 711
		prev = 1 -- 723
		run = 0 -- 723
		do -- 723
			local b = 88 -- 724
			while b < 128 do -- 724
				local lane = 1 -- 725
				local gd = 0 -- 725
				repeat -- 725
					do -- 725
						local r = rnd() -- 727
						lane = r < 0.36 and 1 or (r < 0.68 and 0 or 2) -- 728
						gd = gd + 1 -- 729
					end -- 729
				until not (lane == prev and run >= 1 and gd < 12) -- 729
				run = lane == prev and run + 1 or 0 -- 731
				prev = lane -- 732
				out[#out + 1] = {b = b, lane = lane} -- 733
				if (b - 88) % 4 == 0 then -- 733
					local l2 = 0 -- 738
					repeat -- 738
						do -- 738
							l2 = rndInt(3) -- 739
						end -- 739
					until not (l2 == lane) -- 739
					out[#out + 1] = {b = b + 0.5, lane = l2} -- 740
				end -- 740
				b = b + 1 -- 724
			end -- 724
		end -- 724
		__TS__ArraySort( -- 744
			out, -- 744
			function(____, a, b) return a.b - b.b end -- 744
		) -- 744
		local ns = {} -- 745
		for ____, n in ipairs(out) do -- 746
			ns[#ns + 1] = { -- 747
				t = n.b * SPB, -- 747
				lane = n.lane, -- 747
				judged = false, -- 747
				result = 0, -- 747
				fx = 0 -- 747
			} -- 747
		end -- 747
		return ns -- 749
	end -- 691
	local notes = {} -- 752
	local function winNow() -- 754
		return WIN_BASE * WIN_MUL[diff + 1] -- 754
	end -- 754
	local function checkKnock() -- 756
		if suspicion < 100 then -- 756
			return -- 757
		end -- 757
		suspicion = 55 -- 758
		diff = math.min(3, diff + 1) -- 759
		knockT = 2.2 -- 760
	end -- 756
	local function hit(lane) -- 763
		if state == 0 then -- 763
			beginPlay() -- 764
			return -- 764
		end -- 764
		if state ~= 1 then -- 764
			return -- 765
		end -- 765
		local t = elapsed -- 766
		local win = winNow() -- 767
		local best = nil -- 769
		local bd = 1000000000 -- 770
		for ____, n in ipairs(notes) do -- 771
			do -- 771
				if n.judged or n.lane ~= lane then -- 771
					goto __continue72 -- 772
				end -- 772
				local dt = t - n.t -- 773
				if dt < -win or dt > win then -- 773
					goto __continue72 -- 774
				end -- 774
				local ad = math.abs(dt) -- 775
				if ad < bd then -- 775
					bd = ad -- 776
					best = n -- 776
				end -- 776
			end -- 776
			::__continue72:: -- 776
		end -- 776
		if best == nil then -- 776
			flash[lane + 1] = 0.6 -- 780
			Audio:play(THUD[lane + 1]) -- 781
			return -- 782
		end -- 782
		best.judged = true -- 785
		best.fx = 1 -- 786
		flash[lane + 1] = 1 -- 787
		Audio:play(THUD[lane + 1]) -- 788
		spawnHitFx(lane) -- 789
		if bd <= win * 0.5 then -- 789
			best.result = 1 -- 792
			hits = hits + 1 -- 793
			combo = combo + 1 -- 794
			if combo > maxCombo then -- 794
				maxCombo = combo -- 795
			end -- 795
			if combo % 6 == 0 then -- 795
				suspicion = math.max(0, suspicion - 2) -- 796
			end -- 796
		else -- 796
			best.result = 2 -- 798
			goods = goods + 1 -- 799
			combo = 0 -- 800
			suspicion = math.min(100, suspicion + 2) -- 801
		end -- 801
		checkKnock() -- 803
	end -- 763
	local endT = 0 -- 807
	local bgmOn = false -- 808
	local introT = 0 -- 809
	local paused = false -- 810
	local showSet = false -- 811
	local ptrX = -999 -- 813
	local ptrY = -999 -- 813
	local ptrDown = false -- 813
	local btnHov = 0 -- 814
	local btnPrs = 0 -- 814
	local function update(dt) -- 816
		if state == 0 then -- 816
			syncIntro(dt) -- 817
			return -- 817
		end -- 817
		if state == 2 then -- 817
			endT = endT + dt -- 819
			syncEnd() -- 820
			return -- 821
		end -- 821
		if paused then -- 821
			return -- 823
		end -- 823
		elapsed = elapsed + dt -- 824
		if not bgmOn and elapsed >= 0 then -- 824
			bgmOn = true -- 828
			Audio:playStream(BGM, true, 0) -- 831
		end -- 831
		do -- 831
			local i = 0 -- 834
			while i < 3 do -- 834
				flash[i + 1] = math.max(0, flash[i + 1] - dt * 7) -- 835
				laneMiss[i + 1] = math.max(0, laneMiss[i + 1] - dt * 2.2) -- 836
				i = i + 1 -- 834
			end -- 834
		end -- 834
		knockT = math.max(0, knockT - dt) -- 838
		do -- 838
			local i = #particles - 1 -- 840
			while i >= 0 do -- 840
				do -- 840
					local p = particles[i + 1] -- 841
					p.life = p.life - dt * 1.6 -- 843
					if p.life <= 0 then -- 843
						__TS__ArraySplice(particles, i, 1) -- 844
						goto __continue90 -- 844
					end -- 844
					p.x = p.x + p.vx * dt -- 845
					p.y = p.y + p.vy * dt -- 846
					p.vy = p.vy + 620 * dt -- 847
					p.r = p.r + dt * 6 -- 848
				end -- 848
				::__continue90:: -- 848
				i = i - 1 -- 840
			end -- 840
		end -- 840
		for ____, n in ipairs(notes) do -- 851
			do -- 851
				if n.fx <= 0 then -- 851
					goto __continue92 -- 852
				end -- 852
				n.fx = math.max(0, n.fx - dt * 5) -- 853
			end -- 853
			::__continue92:: -- 853
		end -- 853
		if state ~= 1 then -- 853
			return -- 856
		end -- 856
		for ____, n in ipairs(notes) do -- 859
			do -- 859
				if n.judged then -- 859
					goto __continue96 -- 860
				end -- 860
				if elapsed - n.t > winNow() then -- 860
					n.judged = true -- 862
					n.result = 3 -- 863
					n.fx = 1 -- 864
					misses = misses + 1 -- 865
					combo = 0 -- 866
					suspicion = math.min(100, suspicion + 7) -- 867
					laneMiss[n.lane + 1] = 1 -- 868
					Audio:play(MISS_SFX) -- 869
					checkKnock() -- 870
				end -- 870
			end -- 870
			::__continue96:: -- 870
		end -- 870
		if suspicion > suspPeak then -- 870
			suspPeak = suspicion -- 879
		end -- 879
		local b = elapsed / SPB -- 881
		local idx = 0 -- 882
		do -- 882
			local i = 0 -- 883
			while i < #SEGS do -- 883
				if b >= SEGS[i + 1].from then -- 883
					idx = i -- 883
				end -- 883
				i = i + 1 -- 883
			end -- 883
		end -- 883
		if b >= 0 and idx ~= segIdx then -- 883
			segIdx = idx -- 884
			segStart = elapsed -- 884
		end -- 884
		if b >= TOTAL_BEATS + 1.2 then -- 884
			state = 2 -- 887
			wangzi.visible = false -- 889
			wangziLaugh.visible = true -- 890
			wangziLaugh.size = Size(300, 400) -- 892
			wangziLaugh.anchor = Vec2(0, 1) -- 893
			wangziLaugh.position = Vec2(856, H - 350) -- 894
			for ____, jl in ipairs(judgeLine) do -- 895
				jl.visible = false -- 895
			end -- 895
			hudRoot.visible = false -- 896
			plateRoot.visible = false -- 897
			endRoot.visible = true -- 898
			elapsed = 0 -- 899
			endT = 0 -- 900
			syncEnd() -- 901
		end -- 901
	end -- 816
	local function draw() -- 906
		if state == 0 then -- 906
			return -- 907
		end -- 907
		local cur = segIdx >= 0 and SEGS[segIdx + 1] or nil -- 910
		do -- 910
			local i = 0 -- 911
			while i < 3 do -- 911
				local idle = cur ~= nil and __TS__ArrayIndexOf(cur.lanes, i) < 0 -- 912
				shafts[i + 1].opacity = idle and 0.45 or 1 -- 913
				shaftDim[i + 1].visible = idle -- 914
				idleTips[i + 1].opacity = idle and 1 or 0 -- 915
				i = i + 1 -- 911
			end -- 911
		end -- 911
		do -- 911
			local i = 0 -- 919
			while i < 3 do -- 919
				judgeBand[i + 1].opacity = 0.3 * laneMiss[i + 1] -- 920
				i = i + 1 -- 919
			end -- 919
		end -- 919
		local k = 0 -- 924
		for ____, n in ipairs(notes) do -- 925
			do -- 925
				if k >= POOL then -- 925
					break -- 926
				end -- 926
				if n.result == -1 then -- 926
					goto __continue114 -- 927
				end -- 927
				if n.result == 3 and n.fx <= 0 then -- 927
					goto __continue114 -- 928
				end -- 928
				local y = JUDGE_Y - (n.t - elapsed) * PX_PER_SEC -- 929
				if y < RM_T - 34 or y > JUDGE_Y + 34 then -- 929
					goto __continue114 -- 930
				end -- 930
				local idx = k -- 932
				k = k + 1 -- 932
				local x = LANE_X0 + n.lane * (LANE_W + LANE_GAP) + 3 -- 933
				local dy = 0 -- 934
				local alpha = 1 -- 934
				local isHit = n.result == 1 or n.result == 2 -- 935
				local isMiss = n.result == 3 -- 936
				if isHit then -- 936
					alpha = n.fx -- 938
				elseif isMiss then -- 938
					alpha = n.fx * 0.6 -- 940
					dy = (1 - n.fx) * 18 -- 941
				end -- 941
				local s = isHit and kangsH[idx + 1] or (isMiss and kangsM[idx + 1] or kangsN[idx + 1]) -- 944
				kangsN[idx + 1].opacity = 0 -- 945
				kangsH[idx + 1].opacity = 0 -- 946
				kangsM[idx + 1].opacity = 0 -- 947
				s.position = Vec2(x, H - (y - 12 + dy)) -- 948
				s.opacity = alpha -- 949
			end -- 949
			::__continue114:: -- 949
		end -- 949
		do -- 949
			while k < POOL do -- 949
				kangsN[k + 1].opacity = 0 -- 952
				kangsH[k + 1].opacity = 0 -- 953
				kangsM[k + 1].opacity = 0 -- 954
				k = k + 1 -- 951
			end -- 951
		end -- 951
		local curSeg = segIdx >= 0 and SEGS[segIdx + 1] or nil -- 960
		do -- 960
			local i = 0 -- 961
			while i < 3 do -- 961
				local idle = curSeg ~= nil and __TS__ArrayIndexOf(curSeg.lanes, i) < 0 -- 962
				local f = flash[i + 1] -- 963
				local hit = f > 0.02 -- 964
				millDiscs[i + 1].visible = not idle and not hit -- 966
				millIdles[i + 1].visible = idle and not hit -- 967
				millHis[i + 1].visible = not idle and hit -- 968
				millHis[i + 1].opacity = f -- 969
				millHisIdle[i + 1].visible = idle and hit -- 970
				millHisIdle[i + 1].opacity = f -- 971
				local sk = millSparks[i + 1] -- 973
				if f > 0.06 then -- 973
					local kk = 0.62 + 0.38 * (1 - f) -- 975
					sk.visible = true -- 976
					sk.opacity = 0.5 * f -- 977
					sk.size = Size(136 * kk, 136 * kk) -- 978
					sk.anchor = Vec2(0.5, 0.5) -- 979
					sk.position = Vec2(LANE_CX[i + 1], H - MILL_CY) -- 980
				else -- 980
					sk.visible = false -- 982
				end -- 982
				local ea = idle and 0.42 or 0.9 -- 984
				local ebase = i * 4 -- 985
				millEdges[ebase + 1].opacity = ea -- 986
				millEdges[ebase + 1 + 1].opacity = ea -- 987
				millEdges[ebase + 2 + 1].opacity = ea -- 988
				millEdges[ebase + 3 + 1].opacity = ea -- 989
				millKeys[i + 1].color = idle and Color(36, 73, 70, 77) or Color(36, 73, 70, 148) -- 990
				millMiss[i + 1].opacity = 0.62 * laneMiss[i + 1] -- 991
				i = i + 1 -- 961
			end -- 961
		end -- 961
		do -- 961
			local i = 0 -- 995
			while i < PART_N do -- 995
				do -- 995
					local sp = partSprites[i + 1] -- 996
					local fl = partFills[i + 1] -- 997
					local p = i < #particles and particles[i + 1] or nil -- 998
					if p == nil then -- 998
						sp.opacity = 0 -- 999
						fl.opacity = 0 -- 999
						goto __continue129 -- 999
					end -- 999
					local pa = math.min(1, p.life) -- 1000
					sp.size = Size(p.s + 1.2, p.s + 1.2) -- 1002
					sp.anchor = Vec2(0.5, 0.5) -- 1003
					sp.position = Vec2(p.x, H - p.y) -- 1004
					sp.angle = p.r * 57.29578 -- 1005
					sp.opacity = 0.5 * pa -- 1006
					fl.size = Size(p.s, p.s) -- 1007
					fl.anchor = Vec2(0.5, 0.5) -- 1008
					fl.position = Vec2(p.x, H - p.y) -- 1009
					fl.angle = p.r * 57.29578 -- 1010
					fl.opacity = pa -- 1011
				end -- 1011
				::__continue129:: -- 1011
				i = i + 1 -- 995
			end -- 995
		end -- 995
		guard.position = Vec2(1058 + suspicion * 0.34, H - (CT_B - 4 - 114)) -- 1016
		do -- 1016
			local i = 0 -- 1019
			while i < #SEGS do -- 1019
				local seg = SEGS[i + 1] -- 1020
				local share = (seg.to - seg.from) / TOTAL_BEATS -- 1021
				local w = (PB_W - PB_GAP * 3) * share -- 1022
				local t0 = seg.from * SPB -- 1023
				local t1 = seg.to * SPB -- 1023
				local tt = math.max(0, elapsed) -- 1024
				local p = math.max( -- 1025
					0, -- 1025
					math.min(1, (tt - t0) / (t1 - t0)) -- 1025
				) -- 1025
				local active = i == segIdx -- 1026
				pbFill[i + 1].size = Size( -- 1028
					math.max(1, (w - 3.2) * p), -- 1028
					PB_H - 3.2 -- 1028
				) -- 1028
				pbFill[i + 1].anchor = Vec2(0, 1) -- 1029
				pbFill[i + 1].color = active and C_VERM or Color(36, 73, 70, 158) -- 1030
				pbName[i + 1].color = active and Color(36, 73, 70, 242) or Color(36, 73, 70, 102) -- 1031
				local bi = i * 4 -- 1032
				local ea = active and 0.8 or 0.34 -- 1033
				pbEdge[bi + 1].opacity = ea -- 1034
				pbEdge[bi + 1 + 1].opacity = ea -- 1035
				pbEdge[bi + 2 + 1].opacity = ea -- 1036
				pbEdge[bi + 3 + 1].opacity = ea -- 1037
				pbTick[i + 1].visible = active -- 1038
				i = i + 1 -- 1019
			end -- 1019
		end -- 1019
		local sp2 = math.min(1, suspicion / 100) -- 1042
		local warn = sp2 > 0.75 -- 1043
		susFill.size = Size( -- 1044
			math.max(1, (SBW - 4) * sp2), -- 1044
			SH - 4 -- 1044
		) -- 1044
		susFill.anchor = Vec2(0, 1) -- 1045
		susFill.color = warn and C_VERM or Color(36, 73, 70, 178) -- 1046
		susTip.color = warn and C_VERM or Color(36, 73, 70, 97) -- 1047
		susTip.text = warn and "他起疑了" or ("难度 " .. tostring(diff + 1)) .. "/4" -- 1048
		local seg = SEGS[segIdx + 1] -- 1051
		if seg ~= nil then -- 1051
			local el = elapsed - segStart -- 1053
			if el >= 0 and el < 2.6 then -- 1053
				local a = math.min(1, el / 0.22) * math.min(1, (2.6 - el) / 0.6) -- 1055
				banner.root.visible = true -- 1056
				banner.root.opacity = a -- 1057
				banner:place(92) -- 1058
				banner.t1.position = Vec2(W / 2 + 8, H - (92 + 25) + 19) -- 1059
				banner.t1.text = seg.name -- 1060
				banner.t2.position = Vec2(W / 2 + 8, H - (92 + 43) + 11) -- 1061
				banner.t2.text = seg.tag -- 1062
				bannerTick.visible = true -- 1063
				bannerTick.position = Vec2((W - 300) / 2 + 12, H - (92 + 12)) -- 1064
				bannerSpark.opacity = 0.16 * a -- 1065
			else -- 1065
				banner.root.visible = false -- 1067
				bannerTick.visible = false -- 1068
				bannerSpark.opacity = 0 -- 1069
			end -- 1069
		else -- 1069
			banner.root.visible = false -- 1072
			bannerTick.visible = false -- 1073
			bannerSpark.opacity = 0 -- 1074
		end -- 1074
		if knockT > 0 then -- 1074
			local a = math.min(1, knockT / 0.4) -- 1079
			knock.root.visible = true -- 1080
			knock.root.opacity = a -- 1081
			knock:place(86) -- 1082
			knock.t1.position = Vec2(W / 2, H - (86 + 23) + 16) -- 1083
			knock.t2.position = Vec2(W / 2, H - (86 + 42) + 11) -- 1084
			local kx = (W - 404) / 2 -- 1085
			do -- 1085
				local i = 0 -- 1086
				while i < 3 do -- 1086
					local dy = (i - 1) * 12 -- 1087
					local l = knockTicks[i * 2 + 1] -- 1088
					local r = knockTicks[i * 2 + 1 + 1] -- 1088
					l.visible = true -- 1089
					l.position = Vec2(kx - 10 - 14, H - (86 + 26 + dy * 1.5)) -- 1090
					r.visible = true -- 1091
					r.position = Vec2(kx + 404 + 10, H - (86 + 26 + dy * 1.5)) -- 1092
					i = i + 1 -- 1086
				end -- 1086
			end -- 1086
		else -- 1086
			knock.root.visible = false -- 1095
			for ____, s in ipairs(knockTicks) do -- 1096
				s.visible = false -- 1096
			end -- 1096
		end -- 1096
		pauseRoot.visible = paused -- 1100
		setRoot.visible = showSet -- 1101
	end -- 906
	local introRoot = Node() -- 1107
	introRoot.size = Size(W, H) -- 1108
	introRoot.anchor = Vec2(0, 0) -- 1109
	introRoot.position = Vec2(0, 0) -- 1110
	introRoot:addTo(layer) -- 1111
	block( -- 1115
		introRoot, -- 1115
		0, -- 1115
		140, -- 1115
		W, -- 1115
		30, -- 1115
		C_BEAM -- 1115
	) -- 1115
	block( -- 1116
		introRoot, -- 1116
		0, -- 1116
		141, -- 1116
		W, -- 1116
		3, -- 1116
		C_PAPER, -- 1116
		0.42 -- 1116
	) -- 1116
	block( -- 1117
		introRoot, -- 1117
		0, -- 1117
		149, -- 1117
		W, -- 1117
		1.4, -- 1117
		C_INK, -- 1117
		0.16 -- 1117
	) -- 1117
	block( -- 1118
		introRoot, -- 1118
		0, -- 1118
		157, -- 1118
		W, -- 1118
		1.4, -- 1118
		C_INK, -- 1118
		0.16 -- 1118
	) -- 1118
	block( -- 1119
		introRoot, -- 1119
		0, -- 1119
		168.4, -- 1119
		W, -- 1119
		3.2, -- 1119
		C_INK, -- 1119
		0.95 -- 1119
	) -- 1119
	do -- 1119
		local i = 0 -- 1122
		while i < 10 do -- 1122
			local bw = 92 -- 1123
			local al = 0 -- 1124
			if i < 6 then -- 1124
				al = 0.97 - i * 0.0083 -- 1125
			else -- 1125
				al = 0.92 * (1 - (i - 5.8) / 4.2) -- 1125
			end -- 1125
			block( -- 1126
				introRoot, -- 1126
				i * bw, -- 1126
				CT_B, -- 1126
				bw + 0.5, -- 1126
				H - CT_B, -- 1126
				C_PAPER, -- 1126
				math.max(0, al) -- 1126
			) -- 1126
			i = i + 1 -- 1122
		end -- 1122
	end -- 1122
	local introBurst = img( -- 1131
		introRoot, -- 1131
		"Image/StartUI/lv2_burst.png", -- 1131
		250 - 340, -- 1131
		330 - 340, -- 1131
		680, -- 1131
		680 -- 1131
	) -- 1131
	introBurst.opacity = 0 -- 1132
	local introShadow = img( -- 1136
		introRoot, -- 1136
		"Image/StartUI/lv2_shadow.png", -- 1136
		1060 - 96, -- 1136
		712 - 13, -- 1136
		192, -- 1136
		26 -- 1136
	) -- 1136
	introShadow.opacity = 0 -- 1137
	local introWz = img( -- 1138
		introRoot, -- 1138
		"Image/StartUI/face_smile.png", -- 1138
		918, -- 1138
		316, -- 1138
		286, -- 1138
		384 -- 1138
	) -- 1138
	introWz.opacity = 0 -- 1139
	local introSeal = block( -- 1142
		introRoot, -- 1142
		112, -- 1142
		196, -- 1142
		38, -- 1142
		38, -- 1142
		C_VERM -- 1142
	) -- 1142
	introSeal.opacity = 0 -- 1143
	local introSealLb = label( -- 1144
		introRoot, -- 1144
		FONT_B, -- 1144
		21, -- 1144
		C_PAPER2, -- 1144
		131, -- 1144
		222, -- 1144
		0.5, -- 1144
		0 -- 1144
	) -- 1144
	introSealLb.text = "贰" -- 1145
	introSealLb.opacity = 0 -- 1146
	local introQian = label( -- 1147
		introRoot, -- 1147
		FONT_B, -- 1147
		14, -- 1147
		Color(36, 73, 70, 140), -- 1147
		162, -- 1147
		224, -- 1147
		0, -- 1147
		4 -- 1147
	) -- 1147
	introQian.text = "关 前" -- 1148
	introQian.opacity = 0 -- 1149
	local introTitle = img( -- 1153
		introRoot, -- 1153
		"Image/StartUI/lv2_title.png", -- 1153
		96, -- 1153
		342 - 105, -- 1153
		320, -- 1153
		130 -- 1153
	) -- 1153
	introTitle.opacity = 0 -- 1154
	local introRule = block( -- 1156
		introRoot, -- 1156
		112, -- 1156
		366, -- 1156
		1, -- 1156
		4, -- 1156
		C_VERM -- 1156
	) -- 1156
	local introL1 = label( -- 1158
		introRoot, -- 1158
		FONT_B, -- 1158
		22, -- 1158
		Color(36, 73, 70, 219), -- 1158
		112, -- 1158
		434, -- 1158
		0, -- 1158
		1.4 -- 1158
	) -- 1158
	introL1.text = "围城最怕的不是打，是饿。" -- 1159
	introL1.opacity = 0 -- 1160
	local introL2 = label( -- 1161
		introRoot, -- 1161
		FONT_B, -- 1161
		22, -- 1161
		Color(36, 73, 70, 219), -- 1161
		112, -- 1161
		474, -- 1161
		0, -- 1161
		1.4 -- 1161
	) -- 1161
	introL2.text = "粮吃完了，城自己就垮。" -- 1162
	introL2.opacity = 0 -- 1163
	local introSep = block( -- 1165
		introRoot, -- 1165
		112, -- 1165
		515, -- 1165
		1, -- 1165
		2, -- 1165
		C_INK, -- 1165
		0.32 -- 1165
	) -- 1165
	local introH1 = label( -- 1167
		introRoot, -- 1167
		FONT_B, -- 1167
		13.5, -- 1167
		Color(36, 73, 70, 158), -- 1167
		112, -- 1167
		558, -- 1167
		0, -- 1167
		1 -- 1167
	) -- 1167
	introH1.text = "1　2　3　或者点下面三台砻" -- 1168
	introH1.opacity = 0 -- 1169
	local introH2 = label( -- 1170
		introRoot, -- 1170
		FONT_R, -- 1170
		13.5, -- 1170
		Color(36, 73, 70, 158), -- 1170
		112, -- 1170
		586, -- 1170
		0, -- 1170
		0.6 -- 1170
	) -- 1170
	introH2.text = "糠落到砻口时敲。漏一下，城外就听见里面停了。" -- 1171
	introH2.opacity = 0 -- 1172
	local introBtnShadow = block( -- 1175
		introRoot, -- 1175
		120, -- 1175
		648, -- 1175
		240, -- 1175
		60, -- 1175
		C_INK, -- 1175
		0 -- 1175
	) -- 1175
	local introBtn = block( -- 1176
		introRoot, -- 1176
		112, -- 1176
		640, -- 1176
		240, -- 1176
		60, -- 1176
		C_PAPER2, -- 1176
		0 -- 1176
	) -- 1176
	local introBtnTint = block( -- 1177
		introRoot, -- 1177
		114, -- 1177
		642, -- 1177
		236, -- 1177
		56, -- 1177
		C_VERM, -- 1177
		0 -- 1177
	) -- 1177
	local introBtnEdge = {} -- 1178
	introBtnEdge[#introBtnEdge + 1] = block( -- 1179
		introRoot, -- 1179
		113.5, -- 1179
		641.5, -- 1179
		237, -- 1179
		3, -- 1179
		C_INK, -- 1179
		0 -- 1179
	) -- 1179
	introBtnEdge[#introBtnEdge + 1] = block( -- 1180
		introRoot, -- 1180
		113.5, -- 1180
		696.5, -- 1180
		237, -- 1180
		3, -- 1180
		C_INK, -- 1180
		0 -- 1180
	) -- 1180
	introBtnEdge[#introBtnEdge + 1] = block( -- 1181
		introRoot, -- 1181
		113.5, -- 1181
		641.5, -- 1181
		3, -- 1181
		57, -- 1181
		C_INK, -- 1181
		0 -- 1181
	) -- 1181
	introBtnEdge[#introBtnEdge + 1] = block( -- 1182
		introRoot, -- 1182
		349.5, -- 1182
		641.5, -- 1182
		3, -- 1182
		57, -- 1182
		C_INK, -- 1182
		0 -- 1182
	) -- 1182
	local introBtnLb = label( -- 1183
		introRoot, -- 1183
		FONT_B, -- 1183
		21, -- 1183
		C_INK, -- 1183
		232, -- 1183
		678, -- 1183
		0.5, -- 1183
		10 -- 1183
	) -- 1183
	introBtnLb.text = "开 始" -- 1184
	introBtnLb.opacity = 0 -- 1185
	local introTip = label( -- 1186
		introRoot, -- 1186
		FONT_R, -- 1186
		13, -- 1186
		Color(36, 73, 70, 133), -- 1186
		378, -- 1186
		677, -- 1186
		0, -- 1186
		1.6 -- 1186
	) -- 1186
	introTip.text = "点任意处 / 空格 / 123" -- 1187
	introTip.opacity = 0 -- 1188
	local introHorizon = block( -- 1190
		introRoot, -- 1190
		0, -- 1190
		BASE_T - 1.5, -- 1190
		W, -- 1190
		3, -- 1190
		C_INK, -- 1190
		0 -- 1190
	) -- 1190
	local introFoot = label( -- 1191
		introRoot, -- 1191
		FONT_R, -- 1191
		11, -- 1191
		Color(36, 73, 70, 102), -- 1191
		112, -- 1191
		764, -- 1191
		0, -- 1191
		1.2 -- 1191
	) -- 1191
	introFoot.text = "永昌堡 · 嘉靖四十年 · 五月" -- 1192
	introFoot.opacity = 0 -- 1193
	syncIntro = function(dt) -- 1195
		introT = introT + dt -- 1196
		local function ease(t0, dur) -- 1197
			local k = math.min( -- 1198
				1, -- 1198
				math.max(0, (introT - t0) / dur) -- 1198
			) -- 1198
			return 1 - (1 - k) ^ 3 -- 1199
		end -- 1197
		local aLines = ease(0.1, 0.75) -- 1204
		introBurst.opacity = aLines * 0.95 -- 1205
		introBurst.angle = math.sin(introT * 0.35) * 0.7 -- 1206
		local aWz = ease(0.16, 0.72) -- 1209
		local dx = (1 - aWz) * 48 -- 1210
		local bob = math.sin(introT * 1.45) * 2.2 -- 1211
		introWz.position = Vec2(918 + dx, H - (316 + bob)) -- 1212
		introWz.opacity = 0.98 * aWz -- 1213
		introShadow.position = Vec2(1060 - 96 + dx, H - 712) -- 1214
		introShadow.opacity = aWz -- 1215
		local aSeal = ease(0.34, 0.28) -- 1218
		local kSeal = 1 + 1.5 * (1 - aSeal) -- 1219
		introSeal.opacity = aSeal -- 1220
		introSeal.size = Size(38 * kSeal, 38 * kSeal) -- 1221
		introSeal.anchor = Vec2(0.5, 0.5) -- 1222
		introSeal.position = Vec2(131, H - 215) -- 1223
		introSealLb.opacity = aSeal -- 1224
		introQian.opacity = aSeal -- 1225
		local aTitle = ease(0.46, 0.55) -- 1228
		introTitle.opacity = aTitle -- 1229
		introTitle.position = Vec2(96 + (1 - aTitle) * 44, H - (342 - 105)) -- 1230
		local aRule = ease(0.74, 0.42) -- 1233
		introRule.size = Size( -- 1234
			math.max(1, 128 * aRule), -- 1234
			4 -- 1234
		) -- 1234
		introRule.anchor = Vec2(0, 1) -- 1235
		local function lineIn(t0, lb, y) -- 1238
			local a = ease(t0, 0.5) -- 1239
			lb.opacity = a -- 1240
			lb.position = Vec2(112, H - (y + (1 - a) * 12) + 22) -- 1241
		end -- 1238
		lineIn(0.88, introL1, 434) -- 1243
		lineIn(1.02, introL2, 474) -- 1244
		local aSep = ease(1.18, 0.42) -- 1247
		introSep.size = Size( -- 1248
			math.max(1, 448 * aSep), -- 1248
			2 -- 1248
		) -- 1248
		introSep.anchor = Vec2(0, 1) -- 1249
		local aHint = ease(1.34, 0.5) -- 1252
		introH1.opacity = aHint -- 1253
		introH2.opacity = aHint -- 1254
		local aBtn = ease(1.52, 0.5) -- 1257
		local pulse = 0.5 + 0.5 * math.sin(introT * 2.3) -- 1258
		local kBtn = 0.9 + 0.1 * aBtn -- 1259
		local bcx = 112 + 120 -- 1260
		local bcy = 640 + 30 -- 1260
		local inBtn = ptrX >= 112 and ptrX <= 352 and ptrY >= 640 and ptrY <= 700 -- 1264
		btnHov = approach(btnHov, inBtn and 1 or 0, dt * 8) -- 1265
		btnPrs = approach(btnPrs, inBtn and ptrDown and 1 or 0, dt * 14) -- 1266
		local be = btnHov * btnHov * (3 - 2 * btnHov) -- 1267
		local boff = 3 * be + 2 * btnPrs -- 1268
		local bdim = be * 0.55 + btnPrs * 0.35 -- 1269
		local list = { -- 1271
			introBtnShadow, -- 1271
			introBtn, -- 1271
			introBtnTint, -- 1271
			introBtnEdge[1], -- 1272
			introBtnEdge[2], -- 1272
			introBtnEdge[3], -- 1272
			introBtnEdge[4] -- 1272
		} -- 1272
		local sw = { -- 1273
			240, -- 1273
			240, -- 1273
			236, -- 1273
			237, -- 1273
			237, -- 1273
			3, -- 1273
			3 -- 1273
		} -- 1273
		local sh = { -- 1274
			60, -- 1274
			60, -- 1274
			56, -- 1274
			3, -- 1274
			3, -- 1274
			57, -- 1274
			57 -- 1274
		} -- 1274
		local ox = { -- 1275
			8, -- 1275
			0, -- 1275
			2, -- 1275
			1.5, -- 1275
			1.5, -- 1275
			1.5, -- 1275
			237.5 -- 1275
		} -- 1275
		local oy = { -- 1276
			8, -- 1276
			0, -- 1276
			2, -- 1276
			1.5, -- 1276
			56.5, -- 1276
			1.5, -- 1276
			1.5 -- 1276
		} -- 1276
		do -- 1276
			local i = 0 -- 1277
			while i < 7 do -- 1277
				local s = list[i + 1] -- 1278
				s.size = Size(sw[i + 1] * kBtn, sh[i + 1] * kBtn) -- 1279
				s.anchor = Vec2(0, 1) -- 1280
				local mv = i == 0 and 0 or boff -- 1282
				s.position = Vec2(bcx - 120 * kBtn + ox[i + 1] * kBtn + mv, H - (bcy - 30 * kBtn + oy[i + 1] * kBtn - mv)) -- 1283
				if i == 2 then -- 1283
					s.opacity = aBtn * (0.1 + 0.14 * pulse) -- 1288
				else -- 1288
					s.opacity = aBtn -- 1290
				end -- 1290
				i = i + 1 -- 1277
			end -- 1277
		end -- 1277
		introBtn.color = Color( -- 1295
			math.floor(243 - bdim * 37 + 0.5), -- 1296
			math.floor(234 - bdim * 31 + 0.5), -- 1296
			math.floor(211 - bdim * 27 + 0.5), -- 1296
			255 -- 1296
		) -- 1296
		introBtnLb.opacity = aBtn -- 1298
		introBtnLb.position = Vec2(bcx + boff, H - 678 + 21 - boff) -- 1299
		introTip.opacity = aBtn * 0.9 -- 1300
		local aFoot = ease(1.75, 0.6) -- 1302
		introHorizon.opacity = 0.55 * aFoot -- 1303
		introFoot.opacity = aFoot -- 1304
	end -- 1195
	endRoot = Node() -- 1313
	endRoot.size = Size(W, H) -- 1314
	endRoot.anchor = Vec2(0, 0) -- 1315
	endRoot.position = Vec2(0, 0) -- 1316
	endRoot.visible = false -- 1317
	endRoot:addTo(layer) -- 1318
	block( -- 1321
		endRoot, -- 1321
		0, -- 1321
		0, -- 1321
		W, -- 1321
		H, -- 1321
		Color(255, 248, 228, 255), -- 1321
		0.3 -- 1321
	) -- 1321
	img( -- 1323
		endRoot, -- 1323
		"Image/StartUI/lv2_dawn.png", -- 1323
		0, -- 1323
		0, -- 1323
		W, -- 1323
		H -- 1323
	) -- 1323
	block( -- 1327
		endRoot, -- 1327
		0, -- 1327
		BASE_T - 1.5, -- 1327
		W, -- 1327
		3, -- 1327
		C_INK, -- 1327
		0.55 -- 1327
	) -- 1327
	local endSeal = block( -- 1330
		endRoot, -- 1330
		112, -- 1330
		196, -- 1330
		38, -- 1330
		38, -- 1330
		C_VERM -- 1330
	) -- 1330
	local endSealLb = label( -- 1332
		endRoot, -- 1332
		FONT_B, -- 1332
		28, -- 1332
		C_PAPER2, -- 1332
		131, -- 1332
		215, -- 1332
		0.5, -- 1332
		0 -- 1332
	) -- 1332
	endSealLb.text = "胜" -- 1333
	local endTag = label( -- 1334
		endRoot, -- 1334
		FONT_B, -- 1334
		14, -- 1334
		Color(36, 73, 70, 140), -- 1334
		162, -- 1334
		224, -- 1334
		0, -- 1334
		4 -- 1334
	) -- 1334
	endTag.text = "关 后" -- 1335
	local GX = 538 -- 1338
	local GY = 190 -- 1338
	local GS = 44 -- 1338
	local GW = 2.6 -- 1338
	local endGradeEdges = { -- 1339
		block( -- 1340
			endRoot, -- 1340
			GX, -- 1340
			GY, -- 1340
			GS, -- 1340
			GW, -- 1340
			C_VERM -- 1340
		), -- 1340
		block( -- 1341
			endRoot, -- 1341
			GX, -- 1341
			GY + GS - GW, -- 1341
			GS, -- 1341
			GW, -- 1341
			C_VERM -- 1341
		), -- 1341
		block( -- 1342
			endRoot, -- 1342
			GX, -- 1342
			GY, -- 1342
			GW, -- 1342
			GS, -- 1342
			C_VERM -- 1342
		), -- 1342
		block( -- 1343
			endRoot, -- 1343
			GX + GS - GW, -- 1343
			GY, -- 1343
			GW, -- 1343
			GS, -- 1343
			C_VERM -- 1343
		) -- 1343
	} -- 1343
	local endGradeLb = label( -- 1345
		endRoot, -- 1345
		FONT_B, -- 1345
		26, -- 1345
		C_VERM, -- 1345
		GX + GS / 2, -- 1345
		GY + GS / 2 + 9, -- 1345
		0.5, -- 1345
		0 -- 1345
	) -- 1345
	endGradeLb.text = "甲" -- 1346
	local endGradeTip = label( -- 1347
		endRoot, -- 1347
		FONT_R, -- 1347
		10, -- 1347
		Color(36, 73, 70, 115), -- 1347
		GX + GS / 2, -- 1347
		GY + 56, -- 1347
		0.5, -- 1347
		2 -- 1347
	) -- 1347
	endGradeTip.text = "今夜评级" -- 1348
	local endTitle = img( -- 1351
		endRoot, -- 1351
		"Image/StartUI/lv2_title_end.png", -- 1351
		82, -- 1351
		322 - 78, -- 1351
		380, -- 1351
		100 -- 1351
	) -- 1351
	endTitle.opacity = 0 -- 1352
	local endRule = block( -- 1355
		endRoot, -- 1355
		112, -- 1355
		346, -- 1355
		1, -- 1355
		4, -- 1355
		C_VERM -- 1355
	) -- 1355
	local endL1 = label( -- 1356
		endRoot, -- 1356
		FONT_B, -- 1356
		22, -- 1356
		Color(36, 73, 70, 224), -- 1356
		112, -- 1356
		402, -- 1356
		0, -- 1356
		1.4 -- 1356
	) -- 1356
	endL1.text = "那一夜，砻就没停过。" -- 1357
	local endL2 = label( -- 1358
		endRoot, -- 1358
		FONT_B, -- 1358
		22, -- 1358
		Color(36, 73, 70, 224), -- 1358
		112, -- 1358
		440, -- 1358
		0, -- 1358
		1.4 -- 1358
	) -- 1358
	endL2.text = "停一下，外面就听出来了。" -- 1359
	local endSep = block( -- 1360
		endRoot, -- 1360
		112, -- 1360
		482, -- 1360
		1, -- 1360
		2, -- 1360
		C_INK, -- 1360
		0.32 -- 1360
	) -- 1360
	local STAT_K = {"命中", "漏击", "最大连击", "疑心峰值"} -- 1363
	local STAT_Y = {516, 541, 566, 591} -- 1364
	local endStatK = {} -- 1365
	local endStatV = {} -- 1366
	local endStatBg = {} -- 1367
	local endStatFill = {} -- 1368
	do -- 1368
		local i = 0 -- 1369
		while i < 4 do -- 1369
			local y = STAT_Y[i + 1] -- 1370
			local k = label( -- 1371
				endRoot, -- 1371
				FONT_R, -- 1371
				14, -- 1371
				Color(36, 73, 70, 153), -- 1371
				112, -- 1371
				y, -- 1371
				0, -- 1371
				1.2 -- 1371
			) -- 1371
			k.text = STAT_K[i + 1] -- 1372
			local v = label( -- 1373
				endRoot, -- 1373
				FONT_B, -- 1373
				15, -- 1373
				C_INK, -- 1373
				300, -- 1373
				y, -- 1373
				1, -- 1373
				0.8 -- 1373
			) -- 1373
			endStatK[#endStatK + 1] = k -- 1374
			endStatV[#endStatV + 1] = v -- 1375
			endStatBg[#endStatBg + 1] = block( -- 1376
				endRoot, -- 1376
				320, -- 1376
				y - 12, -- 1376
				180, -- 1376
				5, -- 1376
				C_INK, -- 1376
				0.1 -- 1376
			) -- 1376
			endStatFill[#endStatFill + 1] = block( -- 1377
				endRoot, -- 1377
				320, -- 1377
				y - 12, -- 1377
				1, -- 1377
				5, -- 1377
				C_INK, -- 1377
				0.62 -- 1377
			) -- 1377
			i = i + 1 -- 1369
		end -- 1369
	end -- 1369
	local endL3 = label( -- 1381
		endRoot, -- 1381
		FONT_B, -- 1381
		16, -- 1381
		Color(36, 73, 70, 204), -- 1381
		112, -- 1381
		630, -- 1381
		0, -- 1381
		1.2 -- 1381
	) -- 1381
	endL3.text = "可光靠耳朵骗不住人，城里得真有粮。" -- 1382
	local ebtns = {} -- 1390
	local EBTN = {{ -- 1391
		x = 112, -- 1392
		y = 660, -- 1392
		w = 240, -- 1392
		h = 60, -- 1392
		label = "好", -- 1392
		sub = "去看看他们的田" -- 1392
	}, { -- 1392
		x = 376, -- 1393
		y = 660, -- 1393
		w = 168, -- 1393
		h = 60, -- 1393
		label = "再来一次", -- 1393
		sub = "按 R" -- 1393
	}} -- 1393
	for ____, d in ipairs(EBTN) do -- 1395
		local sh = block( -- 1396
			endRoot, -- 1396
			d.x + 8, -- 1396
			d.y + 8, -- 1396
			d.w, -- 1396
			d.h, -- 1396
			C_INK, -- 1396
			0.88 -- 1396
		) -- 1396
		local pn = block( -- 1397
			endRoot, -- 1397
			d.x, -- 1397
			d.y, -- 1397
			d.w, -- 1397
			d.h, -- 1397
			Color(246, 240, 223, 255) -- 1397
		) -- 1397
		local ed = { -- 1398
			block( -- 1399
				endRoot, -- 1399
				d.x + 1.5, -- 1399
				d.y + 1.5, -- 1399
				d.w - 3, -- 1399
				3, -- 1399
				C_INK, -- 1399
				0.95 -- 1399
			), -- 1399
			block( -- 1400
				endRoot, -- 1400
				d.x + 1.5, -- 1400
				d.y + d.h - 4.5, -- 1400
				d.w - 3, -- 1400
				3, -- 1400
				C_INK, -- 1400
				0.95 -- 1400
			), -- 1400
			block( -- 1401
				endRoot, -- 1401
				d.x + 1.5, -- 1401
				d.y + 1.5, -- 1401
				3, -- 1401
				d.h - 3, -- 1401
				C_INK, -- 1401
				0.95 -- 1401
			), -- 1401
			block( -- 1402
				endRoot, -- 1402
				d.x + d.w - 4.5, -- 1402
				d.y + 1.5, -- 1402
				3, -- 1402
				d.h - 3, -- 1402
				C_INK, -- 1402
				0.95 -- 1402
			) -- 1402
		} -- 1402
		local lb = label( -- 1404
			endRoot, -- 1404
			FONT_B, -- 1404
			20, -- 1404
			C_INK, -- 1404
			d.x + d.w / 2, -- 1404
			d.y + 22, -- 1404
			0.5, -- 1404
			10 -- 1404
		) -- 1404
		lb.text = d.label -- 1405
		local sb = label( -- 1406
			endRoot, -- 1406
			FONT_R, -- 1406
			9, -- 1406
			Color(36, 73, 70, 128), -- 1406
			d.x + d.w / 2, -- 1406
			d.y + 46, -- 1406
			0.5, -- 1406
			0.6 -- 1406
		) -- 1406
		sb.text = d.sub -- 1407
		ebtns[#ebtns + 1] = { -- 1408
			x = d.x, -- 1408
			y = d.y, -- 1408
			w = d.w, -- 1408
			h = d.h, -- 1408
			sh = sh, -- 1408
			pn = pn, -- 1408
			ed = ed, -- 1408
			lb = lb, -- 1408
			sb = sb -- 1408
		} -- 1408
	end -- 1408
	local ebHov = {0, 0} -- 1410
	local ebPrs = {0, 0} -- 1411
	local endFoot = label( -- 1414
		endRoot, -- 1414
		FONT_R, -- 1414
		11, -- 1414
		Color(36, 73, 70, 102), -- 1414
		112, -- 1414
		764, -- 1414
		0, -- 1414
		1.2 -- 1414
	) -- 1414
	endFoot.text = "永昌堡 · 嘉靖四十年 · 五月 · 夜尽" -- 1415
	local function endBtnAt(mx, my) -- 1417
		do -- 1417
			local i = 0 -- 1418
			while i < #ebtns do -- 1418
				local b = ebtns[i + 1] -- 1419
				if mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h then -- 1419
					return i -- 1420
				end -- 1420
				i = i + 1 -- 1418
			end -- 1418
		end -- 1418
		return -1 -- 1422
	end -- 1417
	local function setEndStats() -- 1426
		local s = {hits, misses, maxCombo, suspPeak} -- 1427
		local texts = { -- 1428
			(tostring(hits) .. " / ") .. tostring(hits + misses), -- 1429
			tostring(misses) .. " 次", -- 1430
			tostring(maxCombo), -- 1431
			tostring(math.floor(suspPeak + 0.5)) .. "%" -- 1432
		} -- 1432
		local rates = { -- 1434
			hits / math.max(1, hits + misses), -- 1434
			misses / math.max(1, hits + misses), -- 1434
			0, -- 1434
			suspPeak / 100 -- 1434
		} -- 1434
		do -- 1434
			local i = 0 -- 1435
			while i < 4 do -- 1435
				endStatV[i + 1].text = texts[i + 1] -- 1436
				local w = rates[i + 1] > 0 and math.max(2, 180 * rates[i + 1]) or 1 -- 1437
				endStatFill[i + 1].size = Size(w, 5) -- 1438
				endStatFill[i + 1].anchor = Vec2(0, 1) -- 1439
				endStatFill[i + 1].color = i == 3 and C_VERM or C_INK -- 1440
				i = i + 1 -- 1435
			end -- 1435
		end -- 1435
		endStatFill[3].opacity = 0 -- 1442
	end -- 1426
	syncEnd = function() -- 1445
		setEndStats() -- 1446
		local sp = ease3(endT, 0.1, 0.26) -- 1449
		endSeal.opacity = sp -- 1450
		endSealLb.opacity = sp -- 1451
		endTag.opacity = sp -- 1452
		local ks = 1 + 1.4 * (1 - sp) -- 1453
		endSeal.size = Size(38 * ks, 38 * ks) -- 1454
		endSeal.anchor = Vec2(0.5, 0.5) -- 1455
		endSeal.position = Vec2(131, H - 215) -- 1456
		local gp = ease3(endT, 1.3, 0.26) -- 1459
		for ____, e in ipairs(endGradeEdges) do -- 1460
			e.opacity = gp -- 1460
		end -- 1460
		endGradeLb.opacity = gp -- 1461
		endGradeTip.opacity = gp * 0.9 -- 1462
		local gk = 1 + 1.4 * (1 - gp) -- 1463
		local gw2 = 44 * gk -- 1464
		local gcx = GX + GS / 2 -- 1465
		local gcy = GY + GS / 2 -- 1465
		endGradeEdges[1].size = Size(gw2, GW) -- 1466
		endGradeEdges[1].anchor = Vec2(0.5, 0.5) -- 1467
		endGradeEdges[1].position = Vec2(gcx, H - (gcy - gw2 / 2 + GW / 2)) -- 1468
		endGradeEdges[2].size = Size(gw2, GW) -- 1469
		endGradeEdges[2].anchor = Vec2(0.5, 0.5) -- 1470
		endGradeEdges[2].position = Vec2(gcx, H - (gcy + gw2 / 2 - GW / 2)) -- 1471
		endGradeEdges[3].size = Size(GW, gw2) -- 1472
		endGradeEdges[3].anchor = Vec2(0.5, 0.5) -- 1473
		endGradeEdges[3].position = Vec2(gcx - gw2 / 2 + GW / 2, H - gcy) -- 1474
		endGradeEdges[4].size = Size(GW, gw2) -- 1475
		endGradeEdges[4].anchor = Vec2(0.5, 0.5) -- 1476
		endGradeEdges[4].position = Vec2(gcx + gw2 / 2 - GW / 2, H - gcy) -- 1477
		local tp = ease3(endT, 0.3, 0.42) -- 1480
		endTitle.opacity = tp -- 1481
		endTitle.position = Vec2(82 + (1 - tp) * 30, H - (322 - 78)) -- 1482
		local rp = ease3(endT, 0.52, 0.42) -- 1485
		endRule.size = Size( -- 1486
			math.max(1, 128 * rp), -- 1486
			4 -- 1486
		) -- 1486
		endRule.anchor = Vec2(0, 1) -- 1487
		endRule.position = Vec2(112, H - 346) -- 1488
		local l1 = ease3(endT, 0.7, 0.5) -- 1491
		endL1.opacity = l1 -- 1492
		endL1.position = Vec2(112, H - 402 + (1 - l1) * 12) -- 1493
		local l2 = ease3(endT, 0.84, 0.5) -- 1494
		endL2.opacity = l2 -- 1495
		endL2.position = Vec2(112, H - 440 + (1 - l2) * 12) -- 1496
		local sep = ease3(endT, 1, 0.42) -- 1499
		endSep.size = Size( -- 1500
			math.max(1, 448 * sep), -- 1500
			2 -- 1500
		) -- 1500
		endSep.anchor = Vec2(0, 1) -- 1501
		endSep.position = Vec2(112, H - 482) -- 1502
		do -- 1502
			local i = 0 -- 1505
			while i < 4 do -- 1505
				local a = ease3(endT, 1 + i * 0.1, 0.42) -- 1506
				endStatK[i + 1].opacity = a -- 1507
				endStatV[i + 1].opacity = a -- 1508
				endStatBg[i + 1].opacity = 0.1 * a -- 1509
				if i ~= 2 then -- 1509
					endStatFill[i + 1].opacity = 0.62 * a -- 1510
				end -- 1510
				endStatK[i + 1].position = Vec2(112, H - STAT_Y[i + 1] + (1 - a) * 8) -- 1511
				endStatV[i + 1].position = Vec2(300, H - STAT_Y[i + 1] + (1 - a) * 8) -- 1512
				i = i + 1 -- 1505
			end -- 1505
		end -- 1505
		local l3 = ease3(endT, 1.3, 0.5) -- 1516
		endL3.opacity = l3 -- 1517
		local ap = ease3(endT, 1.5, 0.5) -- 1520
		local idx = endBtnAt(ptrX, ptrY) -- 1521
		do -- 1521
			local i = 0 -- 1522
			while i < #ebtns do -- 1522
				local b = ebtns[i + 1] -- 1523
				ebHov[i + 1] = approach(ebHov[i + 1], idx == i and 1 or 0, 0.1) -- 1524
				ebPrs[i + 1] = approach(ebPrs[i + 1], idx == i and ptrDown and 1 or 0, 0.16) -- 1525
				local e = ebHov[i + 1] * ebHov[i + 1] * (3 - 2 * ebHov[i + 1]) -- 1526
				local off = 3 * e + 2 * ebPrs[i + 1] -- 1527
				local dim = e * 0.55 + ebPrs[i + 1] * 0.35 -- 1528
				local k = 0.92 + 0.08 * ap -- 1529
				b.sh.opacity = ap -- 1530
				b.pn.opacity = ap -- 1531
				b.pn.color = Color(246 - dim * 40, 240 - dim * 34, 223 - dim * 28, 255) -- 1532
				local bx = b.x + off -- 1535
				local by = b.y + off -- 1535
				b.pn.size = Size(b.w, b.h) -- 1536
				b.pn.anchor = Vec2(0, 1) -- 1537
				b.pn.position = Vec2(bx, H - by) -- 1538
				b.ed[1].size = Size(b.w - 3, 3) -- 1539
				b.ed[1].anchor = Vec2(0, 1) -- 1540
				b.ed[1].position = Vec2(bx + 1.5, H - (by + 1.5)) -- 1541
				b.ed[2].size = Size(b.w - 3, 3) -- 1542
				b.ed[2].anchor = Vec2(0, 1) -- 1543
				b.ed[2].position = Vec2(bx + 1.5, H - (by + b.h - 4.5)) -- 1544
				b.ed[3].size = Size(3, b.h - 3) -- 1545
				b.ed[3].anchor = Vec2(0, 1) -- 1546
				b.ed[3].position = Vec2(bx + 1.5, H - (by + 1.5)) -- 1547
				b.ed[4].size = Size(3, b.h - 3) -- 1548
				b.ed[4].anchor = Vec2(0, 1) -- 1549
				b.ed[4].position = Vec2(bx + b.w - 4.5, H - (by + 1.5)) -- 1550
				do -- 1550
					local j = 0 -- 1551
					while j < 4 do -- 1551
						b.ed[j + 1].opacity = ap -- 1551
						j = j + 1 -- 1551
					end -- 1551
				end -- 1551
				b.lb.opacity = ap -- 1552
				b.lb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 22) - off) -- 1553
				b.sb.opacity = ap * 0.9 -- 1554
				b.sb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 46) - off) -- 1555
				i = i + 1 -- 1522
			end -- 1522
		end -- 1522
		endFoot.opacity = ease3(endT, 1.8, 0.6) -- 1559
	end -- 1445
	notes = buildChart() -- 1563
	startBeat = opts.startAt ~= nil and opts.startAt or 0 -- 1564
	elapsed = -PREROLL -- 1565
	state = 0 -- 1566
	if startBeat > 0 then -- 1566
		for ____, n in ipairs(notes) do -- 1569
			if n.t < startBeat * SPB then -- 1569
				n.judged = true -- 1570
				n.result = -1 -- 1570
			end -- 1570
		end -- 1570
	end -- 1570
	if opts.immediate == true then -- 1570
		state = 1 -- 1576
		introRoot.visible = false -- 1577
		playRoot.visible = true -- 1578
		elapsed = startBeat * SPB -- 1579
		if opts.debugView == "panel" then -- 1579
			showSet = true -- 1580
			setRoot.visible = true -- 1580
		end -- 1580
		if opts.debugView == "pause" then -- 1580
			paused = true -- 1581
			pauseRoot.visible = true -- 1581
		end -- 1581
	else -- 1581
		playRoot.visible = false -- 1584
		if opts.debugView == "btn" then -- 1584
			ptrX = 200 -- 1586
			ptrY = 660 -- 1586
			ptrDown = true -- 1586
		end -- 1586
		if opts.debugView == "hov" then -- 1586
			ptrX = 200 -- 1587
			ptrY = 660 -- 1587
			ptrDown = false -- 1587
		end -- 1587
	end -- 1587
	beginPlay = function() -- 1591
		if state ~= 0 then -- 1591
			return -- 1592
		end -- 1592
		state = 1 -- 1593
		introRoot.visible = false -- 1594
		playRoot.visible = true -- 1595
		elapsed = -PREROLL -- 1596
	end -- 1591
	local play = { -- 1599
		update = function(____, dt) -- 1600
			update(dt) -- 1601
			draw() -- 1602
		end, -- 1600
		destroy = function() -- 1604
			Audio:stopAll() -- 1605
			layer:removeFromParent() -- 1606
		end, -- 1604
		setPointer = function(____, x, y, down) -- 1608
			ptrX = x -- 1610
			ptrY = y -- 1610
			ptrDown = down -- 1610
		end, -- 1608
		hoverAt = function(____, x, y) -- 1612
			ptrX = x -- 1615
			ptrY = y -- 1615
		end, -- 1612
		tapAt = function(____, x, y) -- 1617
			if paused then -- 1617
				paused = false -- 1619
				pauseRoot.visible = false -- 1619
				Audio:setPauseAllCurrent(false) -- 1619
				return true -- 1619
			end -- 1619
			if state == 1 and x >= 1192 and x <= 1236 and y >= 14 and y <= 58 then -- 1619
				showSet = not showSet -- 1622
				setRoot.visible = showSet -- 1623
				return true -- 1624
			end -- 1624
			if showSet then -- 1624
				if y >= SET_Y + 36 and y <= SET_Y + 62 and x >= IX and x <= IX + IW then -- 1624
					audioBgm = math.min( -- 1629
						1, -- 1629
						math.max(0, (x - IX) / IW) -- 1629
					) -- 1629
					syncSet() -- 1630
					return true -- 1631
				end -- 1631
				if y >= SET_Y + 102 and y <= SET_Y + 128 and x >= IX and x <= IX + IW then -- 1631
					audioSfx = math.min( -- 1634
						1, -- 1634
						math.max(0, (x - IX) / IW) -- 1634
					) -- 1634
					syncSet() -- 1635
					return true -- 1636
				end -- 1636
				if y >= SET_Y + 152 and y <= SET_Y + 188 and x >= IX and x <= IX + IW then -- 1636
					if opts.onQuit ~= nil then -- 1636
						opts:onQuit() -- 1639
					end -- 1639
					return true -- 1640
				end -- 1640
				return true -- 1642
			end -- 1642
			if state == 0 then -- 1642
				beginPlay() -- 1644
				return true -- 1644
			end -- 1644
			if state == 2 then -- 1644
				local bi = endBtnAt(x, y) -- 1646
				if bi == 0 then -- 1646
					if opts.onNext ~= nil then -- 1646
						opts:onNext() -- 1647
					end -- 1647
					return true -- 1647
				end -- 1647
				if bi == 1 then -- 1647
					if opts.onRestart ~= nil then -- 1647
						opts:onRestart() -- 1648
					end -- 1648
					return true -- 1648
				end -- 1648
				return true -- 1651
			end -- 1651
			if state ~= 1 then -- 1651
				return false -- 1653
			end -- 1653
			if y < RM_T then -- 1653
				return false -- 1654
			end -- 1654
			local best = 0 -- 1655
			local bd = 1000000000 -- 1655
			do -- 1655
				local i = 0 -- 1656
				while i < 3 do -- 1656
					local d = math.abs(x - LANE_CX[i + 1]) -- 1657
					if d < bd then -- 1657
						bd = d -- 1658
						best = i -- 1658
					end -- 1658
					i = i + 1 -- 1656
				end -- 1656
			end -- 1656
			hit(best) -- 1660
			return true -- 1661
		end, -- 1617
		hit = function(____, lane) -- 1663
			hit(lane) -- 1663
		end, -- 1663
		skip = function() -- 1664
			if paused then -- 1664
				paused = false -- 1666
				pauseRoot.visible = false -- 1666
				Audio:setPauseAllCurrent(false) -- 1666
			end -- 1666
			if showSet then -- 1666
				showSet = false -- 1667
				setRoot.visible = false -- 1667
			end -- 1667
			if state == 0 then -- 1667
				beginPlay() -- 1668
				return -- 1668
			end -- 1668
			if state == 2 then -- 1668
				if opts.onNext ~= nil then -- 1668
					opts:onNext() -- 1672
				end -- 1672
				return -- 1673
			end -- 1673
			state = 2 -- 1675
			wangzi.visible = false -- 1676
			wangziLaugh.visible = true -- 1677
			wangziLaugh.size = Size(300, 400) -- 1679
			wangziLaugh.anchor = Vec2(0, 1) -- 1680
			wangziLaugh.position = Vec2(856, H - 350) -- 1681
			for ____, jl in ipairs(judgeLine) do -- 1682
				jl.visible = false -- 1682
			end -- 1682
			hudRoot.visible = false -- 1683
			plateRoot.visible = false -- 1684
			endRoot.visible = true -- 1685
			bannerTick.visible = false -- 1686
			for ____, s in ipairs(knockTicks) do -- 1687
				s.visible = false -- 1687
			end -- 1687
			endT = 0 -- 1688
			syncEnd() -- 1689
		end, -- 1664
		isFinished = function() return state == 2 end, -- 1691
		togglePause = function() -- 1692
			if state ~= 1 then -- 1692
				return -- 1693
			end -- 1693
			paused = not paused -- 1694
			pauseRoot.visible = paused -- 1695
			Audio:setPauseAllCurrent(paused) -- 1698
		end, -- 1692
		dragTo = function(____, x, y) -- 1700
			if not showSet then -- 1700
				return false -- 1701
			end -- 1701
			local function at(v) -- 1702
				return math.min( -- 1702
					1, -- 1702
					math.max(0, v) -- 1702
				) -- 1702
			end -- 1702
			if y >= SET_Y + 30 and y <= SET_Y + 70 then -- 1702
				audioBgm = at((x - IX) / IW) -- 1705
				syncSet() -- 1706
				return true -- 1707
			end -- 1707
			if y >= SET_Y + 96 and y <= SET_Y + 136 then -- 1707
				audioSfx = at((x - IX) / IW) -- 1710
				syncSet() -- 1711
				return true -- 1712
			end -- 1712
			return false -- 1714
		end, -- 1700
		isPaused = function() return paused end, -- 1716
		stats = function() return {hits, misses, maxCombo, suspPeak} end, -- 1717
		setPanelOpen = function() return showSet end -- 1718
	} -- 1718
	print("[Level2Play] 开始") -- 1721
	return play -- 1722
end -- 114
return ____exports -- 114