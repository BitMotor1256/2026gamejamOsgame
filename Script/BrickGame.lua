-- [ts]: BrickGame.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 9
local Label = ____Dora.Label -- 10
local Node = ____Dora.Node -- 11
local Size = ____Dora.Size -- 12
local Sprite = ____Dora.Sprite -- 13
local Vec2 = ____Dora.Vec2 -- 15
local View = ____Dora.View -- 16
local W = 1280 -- 19
local H = 800 -- 20
local PAD_Y = 2 -- 21
local CELL = 56 -- 23
local ROWS = 6 -- 24
local GAPS_TO_WIN = 10 -- 25
local SKY_T = 72 -- 27
local SKY_B = 304 -- 27
local TOOTH_H = 36 -- 28
local CAP_H = 14 -- 28
local PAR_T = SKY_B -- 29
local WALL_T = PAR_T + TOOTH_H + CAP_H -- 30
local WALL_B = WALL_T + ROWS * CELL -- 31
local FOOT_B = WALL_B + 12 -- 32
local SLOT_W = 144 -- 34
local SLOT_H = 84 -- 34
local SLOT_GAP = 12 -- 34
local SLOT_Y = 709 -- 34
local HAND_N = 5 -- 35
local CW = 30 -- 36
local HAND_TOTAL = HAND_N * SLOT_W + (HAND_N - 1) * SLOT_GAP -- 37
local HAND_X = (W - HAND_TOTAL) / 2 -- 38
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 40
local FONT_M = "Font/SourceHanSerifSC-Medium.ttf" -- 41
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 42
local C_PAPER = Color(237, 227, 200, 255) -- 44
local C_SEAM = Color(168, 159, 127, 255) -- 45
local C_INK = Color(36, 73, 70, 255) -- 46
local C_DEEP = Color(23, 51, 48, 255) -- 47
local C_VERM = Color(163, 59, 42, 255) -- 48
local C_SAND = Color(227, 218, 186, 255) -- 49
local C_TRAY = Color(186, 176, 144, 255) -- 50
local C_TEAL = Color(90, 121, 104, 255) -- 51
local V0 = 200 -- 54
local V_CAP = 320 -- 54
local ROT_LOCK = 0.1 -- 55
local SPAWN_DELAY = 0.8 -- 56
local MAX_GAPS = 2 -- 57
local EASY_GAPS = 4 -- 58
local SHAPES = { -- 61
	I = {{1, 1, 1, 1}}, -- 62
	O = {{1, 1}, {1, 1}}, -- 63
	T = {{1, 1, 1}, {0, 1, 0}}, -- 64
	S = {{0, 1, 1}, {1, 1, 0}}, -- 65
	Z = {{1, 1, 0}, {0, 1, 1}}, -- 66
	J = {{1, 0, 0}, {1, 1, 1}}, -- 67
	L = {{0, 0, 1}, {1, 1, 1}} -- 68
} -- 68
local KEYS = { -- 70
	"I", -- 70
	"O", -- 70
	"T", -- 70
	"S", -- 70
	"Z", -- 70
	"J", -- 70
	"L" -- 70
} -- 70
local function rotCW(m) -- 72
	local h = #m -- 73
	local w = #m[1] -- 73
	local o = {} -- 74
	do -- 74
		local c = 0 -- 75
		while c < w do -- 75
			local row = {} -- 76
			do -- 76
				local r = h - 1 -- 77
				while r >= 0 do -- 77
					row[#row + 1] = m[r + 1][c + 1] -- 77
					r = r - 1 -- 77
				end -- 77
			end -- 77
			o[#o + 1] = row -- 78
			c = c + 1 -- 75
		end -- 75
	end -- 75
	return o -- 80
end -- 72
local function matKey(m) -- 82
	local s = "" -- 83
	do -- 83
		local r = 0 -- 84
		while r < #m do -- 84
			s = s .. table.concat(m[r + 1], "") .. "/" -- 84
			r = r + 1 -- 84
		end -- 84
	end -- 84
	return s -- 85
end -- 82
local function normCells(m) -- 87
	local out = {} -- 88
	do -- 88
		local r = 0 -- 89
		while r < #m do -- 89
			do -- 89
				local c = 0 -- 90
				while c < #m[r + 1] do -- 90
					if m[r + 1][c + 1] ~= 0 then -- 90
						out[#out + 1] = {c, r} -- 91
					end -- 91
					c = c + 1 -- 90
				end -- 90
			end -- 90
			r = r + 1 -- 89
		end -- 89
	end -- 89
	local mc = 99 -- 94
	local mr = 99 -- 94
	for ____, a in ipairs(out) do -- 95
		if a[1] < mc then -- 95
			mc = a[1] -- 95
		end -- 95
		if a[2] < mr then -- 95
			mr = a[2] -- 95
		end -- 95
	end -- 95
	local res = {} -- 96
	for ____, a in ipairs(out) do -- 97
		res[#res + 1] = {a[1] - mc, a[2] - mr} -- 97
	end -- 97
	return res -- 98
end -- 87
local function ckOf(cells) -- 100
	local parts = {} -- 101
	for ____, a in ipairs(cells) do -- 102
		parts[#parts + 1] = (tostring(a[1]) .. ",") .. tostring(a[2]) -- 102
	end -- 102
	__TS__ArraySort(parts) -- 103
	return table.concat(parts, ";") -- 104
end -- 100
local VARIANTS = {} -- 108
do -- 108
	local ki = 0 -- 110
	while ki < #KEYS do -- 110
		local key = KEYS[ki + 1] -- 111
		local list = {} -- 112
		local seen = {} -- 113
		local cur = SHAPES[key] -- 114
		do -- 114
			local i = 0 -- 115
			while i < 4 do -- 115
				local mk = matKey(cur) -- 116
				if not seen[mk] then -- 116
					seen[mk] = true -- 118
					local cells = normCells(cur) -- 119
					local w = 0 -- 120
					local h = 0 -- 120
					for ____, a in ipairs(cells) do -- 121
						if a[1] + 1 > w then -- 121
							w = a[1] + 1 -- 121
						end -- 121
						if a[2] + 1 > h then -- 121
							h = a[2] + 1 -- 121
						end -- 121
					end -- 121
					list[#list + 1] = { -- 122
						cells = cells, -- 122
						ck = ckOf(cells), -- 122
						w = w, -- 122
						h = h -- 122
					} -- 122
				end -- 122
				cur = rotCW(cur) -- 124
				i = i + 1 -- 115
			end -- 115
		end -- 115
		VARIANTS[key] = list -- 126
		ki = ki + 1 -- 110
	end -- 110
end -- 110
function ____exports.createBrickGame(root, onClear, onExit, startPhase) -- 136
	local state, showSet, audio, btnOff -- 136
	local layer = Node() -- 142
	layer.anchor = Vec2(0, 0) -- 143
	layer.size = Size(W, H) -- 144
	layer.position = Vec2(0, PAD_Y) -- 145
	layer:addTo(root) -- 146
	local function block(parent, x, y, w, h, c) -- 149
		local s = Sprite("Image/StartUI/white.png") -- 152
		s.anchor = Vec2(0, 1) -- 153
		s.size = Size( -- 154
			math.abs(w), -- 154
			math.abs(h) -- 154
		) -- 154
		s.color = c -- 155
		s.position = Vec2(x, H - y) -- 156
		s.visible = false -- 157
		s:addTo(parent) -- 158
		return s -- 159
	end -- 149
	local function show(s, x, y, w, h) -- 161
		s.visible = true -- 162
		s.size = Size(w, h) -- 163
		s.anchor = Vec2(0, 1) -- 167
		s.position = Vec2(x, H - y) -- 168
	end -- 161
	local function hide(s) -- 170
		s.visible = false -- 170
	end -- 170
	local VIEW_S = math.min(View.size.width / W, View.size.height / (H + PAD_Y * 2)) -- 184
	local SS = math.min( -- 185
		3.5, -- 185
		math.max(1, VIEW_S * 1.12) -- 185
	) -- 185
	local function label(parent, font, size, color, x, y, ax, ls) -- 187
		local lb = Label(((font .. ";") .. tostring(math.floor(size * SS + 0.5))) .. ";true") -- 191
		lb.color = color -- 192
		lb.anchor = Vec2(ax, 1) -- 193
		lb.scaleX = 1 / SS -- 194
		lb.scaleY = 1 / SS -- 195
		lb.position = Vec2(x, H - y + size) -- 196
		if ls > 0 then -- 196
			lb.spacing = math.floor(ls * SS + 0.5) -- 197
		end -- 197
		lb:addTo(parent) -- 198
		return lb -- 199
	end -- 187
	block( -- 204
		layer, -- 204
		0, -- 204
		0, -- 204
		W, -- 204
		H, -- 204
		C_PAPER -- 204
	).visible = true -- 204
	local grain = Sprite("Image/StartUI/paper_grain.png") -- 206
	grain.anchor = Vec2(0, 1) -- 207
	grain.size = Size(W, H) -- 208
	grain.position = Vec2(0, H) -- 209
	grain:addTo(layer) -- 210
	local hills = Sprite("Image/StartUI/hills.png") -- 212
	hills.anchor = Vec2(0, 1) -- 213
	hills.size = Size(W, SKY_B - SKY_T) -- 214
	hills.position = Vec2(0, H - SKY_T) -- 215
	hills:addTo(layer) -- 216
	local WZ_X = 28 -- 219
	local WZ_W = 266 -- 219
	local WZ_H = 357 -- 219
	local WZ_BOT = 438 -- 219
	local FACE_LIST = { -- 220
		"smile", -- 220
		"laugh", -- 220
		"dot", -- 220
		"wave", -- 220
		"curvy", -- 220
		"shy", -- 220
		"shyact", -- 220
		"dizzy" -- 220
	} -- 220
	local faces = {} -- 221
	do -- 221
		local i = 0 -- 222
		while i < #FACE_LIST do -- 222
			local s = Sprite(("Image/StartUI/face_" .. FACE_LIST[i + 1]) .. ".png") -- 223
			s.anchor = Vec2(0, 1) -- 224
			s.size = Size(WZ_W, WZ_H) -- 225
			s.position = Vec2(WZ_X, H - (WZ_BOT - WZ_H)) -- 226
			s.opacity = i == 0 and 1 or 0 -- 227
			s:addTo(layer) -- 228
			faces[#faces + 1] = s -- 229
			i = i + 1 -- 222
		end -- 222
	end -- 222
	local faceCur = 0 -- 231
	local dlgBox = Sprite("Image/StartUI/dialog_box.png") -- 233
	dlgBox.anchor = Vec2(0, 1) -- 234
	dlgBox.size = Size(462, 166) -- 235
	dlgBox.position = Vec2(340, H - 122) -- 236
	dlgBox:addTo(layer) -- 237
	local dlgBar = block( -- 239
		layer, -- 239
		368, -- 239
		152, -- 239
		4, -- 239
		15, -- 239
		C_TEAL -- 239
	) -- 239
	dlgBar.visible = true -- 240
	local dlgName = label( -- 241
		layer, -- 241
		FONT_B, -- 241
		16, -- 241
		C_TEAL, -- 241
		382, -- 241
		165, -- 241
		0, -- 241
		3 -- 241
	) -- 241
	dlgName.text = "王梓" -- 242
	local dlgCorner = {} -- 245
	do -- 245
		local i = 0 -- 246
		while i < 8 do -- 246
			local c = block( -- 247
				layer, -- 247
				0, -- 247
				0, -- 247
				1, -- 247
				1, -- 247
				C_VERM -- 247
			) -- 247
			c.visible = true -- 248
			c.opacity = 0.55 -- 249
			dlgCorner[#dlgCorner + 1] = c -- 250
			i = i + 1 -- 246
		end -- 246
	end -- 246
	local function dlgCorners() -- 252
		local x = 354 -- 253
		local y = 136 -- 253
		local w = 434 -- 253
		local h = 138 -- 253
		local len = 13 -- 253
		local t = 1.8 -- 253
		show( -- 254
			dlgCorner[1], -- 254
			x, -- 254
			y, -- 254
			len, -- 254
			t -- 254
		) -- 254
		show( -- 255
			dlgCorner[2], -- 255
			x, -- 255
			y, -- 255
			t, -- 255
			len -- 255
		) -- 255
		show( -- 256
			dlgCorner[3], -- 256
			x + w - len, -- 256
			y, -- 256
			len, -- 256
			t -- 256
		) -- 256
		show( -- 257
			dlgCorner[4], -- 257
			x + w - t, -- 257
			y, -- 257
			t, -- 257
			len -- 257
		) -- 257
		show( -- 258
			dlgCorner[5], -- 258
			x, -- 258
			y + h - t, -- 258
			len, -- 258
			t -- 258
		) -- 258
		show( -- 259
			dlgCorner[6], -- 259
			x, -- 259
			y + h - len, -- 259
			t, -- 259
			len -- 259
		) -- 259
		show( -- 260
			dlgCorner[7], -- 260
			x + w - len, -- 260
			y + h - t, -- 260
			len, -- 260
			t -- 260
		) -- 260
		show( -- 261
			dlgCorner[8], -- 261
			x + w - t, -- 261
			y + h - len, -- 261
			t, -- 261
			len -- 261
		) -- 261
	end -- 252
	dlgCorners() -- 263
	label( -- 264
		layer, -- 264
		FONT_R, -- 264
		26, -- 264
		Color(23, 51, 48, 255), -- 264
		368, -- 264
		210, -- 264
		0, -- 264
		1 -- 264
	).text = "城墙最要紧的，是不能有洞。" -- 264
	label( -- 266
		layer, -- 266
		FONT_R, -- 266
		26, -- 266
		Color(23, 51, 48, 255), -- 266
		368, -- 266
		252, -- 266
		0, -- 266
		1 -- 266
	).text = "一块砖塌了，旁边的一起塌。" -- 266
	local parapet = Sprite("Image/StartUI/parapet.png") -- 270
	parapet.anchor = Vec2(0, 1) -- 271
	parapet.size = Size(W, TOOTH_H + CAP_H) -- 272
	parapet.position = Vec2(0, H - PAR_T) -- 273
	parapet:addTo(layer) -- 274
	local STRIP_W = 2560 -- 277
	local wallA = Sprite("Image/StartUI/wall_strip.png") -- 278
	local wallB = Sprite("Image/StartUI/wall_strip.png") -- 279
	local walls = {wallA, wallB} -- 280
	for ____, w in ipairs(walls) do -- 281
		w.anchor = Vec2(0, 1) -- 282
		w.size = Size(STRIP_W, ROWS * CELL) -- 283
		w.position = Vec2(0, H - WALL_T) -- 284
		w:addTo(layer) -- 285
	end -- 285
	local footLine = block( -- 287
		layer, -- 287
		0, -- 287
		WALL_B, -- 287
		W, -- 287
		2, -- 287
		C_INK -- 287
	) -- 287
	footLine.visible = true -- 288
	footLine.opacity = 0.78 -- 289
	local tray = block( -- 290
		layer, -- 290
		0, -- 290
		FOOT_B, -- 290
		W, -- 290
		H - FOOT_B, -- 290
		C_TRAY -- 290
	) -- 290
	tray.visible = true -- 291
	do -- 291
		local x = 240 -- 294
		while x < W do -- 294
			local seam = block( -- 295
				layer, -- 295
				x, -- 295
				WALL_B + 8, -- 295
				1, -- 295
				H - WALL_B - 8, -- 295
				C_SEAM -- 295
			) -- 295
			seam.visible = true -- 296
			seam.opacity = 0.28 -- 297
			x = x + 320 -- 294
		end -- 294
	end -- 294
	local GAP_POOL = MAX_GAPS * 6 -- 304
	local gapCells = {} -- 305
	do -- 305
		local i = 0 -- 306
		while i < GAP_POOL do -- 306
			gapCells[#gapCells + 1] = block( -- 306
				layer, -- 306
				0, -- 306
				0, -- 306
				CELL, -- 306
				CELL, -- 306
				C_DEEP -- 306
			) -- 306
			i = i + 1 -- 306
		end -- 306
	end -- 306
	local EDGE_POOL = GAP_POOL * 4 -- 309
	local edgePool = {} -- 310
	do -- 310
		local i = 0 -- 311
		while i < EDGE_POOL do -- 311
			local e = block( -- 312
				layer, -- 312
				0, -- 312
				0, -- 312
				1, -- 312
				1, -- 312
				C_INK -- 312
			) -- 312
			e.visible = false -- 313
			edgePool[#edgePool + 1] = e -- 314
			i = i + 1 -- 311
		end -- 311
	end -- 311
	local LIT_POOL = GAP_POOL -- 318
	local litPool = {} -- 319
	do -- 319
		local i = 0 -- 320
		while i < LIT_POOL do -- 320
			local e = block( -- 321
				layer, -- 321
				0, -- 321
				0, -- 321
				1, -- 321
				1, -- 321
				C_PAPER -- 321
			) -- 321
			e.opacity = 0.26 -- 322
			e.visible = false -- 323
			litPool[#litPool + 1] = e -- 324
			i = i + 1 -- 320
		end -- 320
	end -- 320
	local HATCH_POOL = GAP_POOL -- 328
	local hatchPool = {} -- 329
	do -- 329
		local i = 0 -- 330
		while i < HATCH_POOL do -- 330
			local h = Sprite("Image/StartUI/hatch.png") -- 331
			h.anchor = Vec2(0, 1) -- 332
			h.size = Size(CELL, CELL) -- 333
			h.visible = false -- 334
			h:addTo(layer) -- 335
			hatchPool[#hatchPool + 1] = h -- 336
			i = i + 1 -- 330
		end -- 330
	end -- 330
	local hintEdges = {} -- 340
	do -- 340
		local i = 0 -- 341
		while i < 12 do -- 341
			hintEdges[#hintEdges + 1] = block( -- 341
				layer, -- 341
				0, -- 341
				0, -- 341
				1, -- 341
				1, -- 341
				C_VERM -- 341
			) -- 341
			i = i + 1 -- 341
		end -- 341
	end -- 341
	local flashEdges = {} -- 342
	do -- 342
		local i = 0 -- 343
		while i < 4 do -- 343
			flashEdges[#flashEdges + 1] = block( -- 343
				layer, -- 343
				0, -- 343
				0, -- 343
				1, -- 343
				1, -- 343
				C_TEAL -- 343
			) -- 343
			i = i + 1 -- 343
		end -- 343
	end -- 343
	local slots = {} -- 346
	do -- 346
		local i = 0 -- 347
		while i < HAND_N do -- 347
			local s = Sprite("Image/StartUI/slot.png") -- 350
			s.anchor = Vec2(0, 1) -- 351
			s.size = Size(SLOT_W, SLOT_H) -- 352
			s.position = Vec2(HAND_X + i * (SLOT_W + SLOT_GAP), H - SLOT_Y) -- 353
			s:addTo(layer) -- 354
			slots[#slots + 1] = s -- 355
			i = i + 1 -- 347
		end -- 347
	end -- 347
	local handFrame = {} -- 359
	do -- 359
		local i = 0 -- 360
		while i < 4 do -- 360
			local f = block( -- 361
				layer, -- 361
				0, -- 361
				0, -- 361
				1, -- 361
				1, -- 361
				C_TEAL -- 361
			) -- 361
			f.visible = false -- 362
			handFrame[#handFrame + 1] = f -- 363
			i = i + 1 -- 360
		end -- 360
	end -- 360
	local rotBar = block( -- 367
		layer, -- 367
		0, -- 367
		0, -- 367
		1, -- 367
		2, -- 367
		C_TEAL -- 367
	) -- 367
	rotBar.visible = false -- 368
	local chipPool = {} -- 369
	do -- 369
		local i = 0 -- 370
		while i < HAND_N * 4 do -- 370
			local c = Sprite("Image/StartUI/chip.png") -- 371
			c.anchor = Vec2(0, 1) -- 372
			c.size = Size(CW, CW) -- 373
			c.visible = false -- 374
			c:addTo(layer) -- 375
			chipPool[#chipPool + 1] = c -- 376
			i = i + 1 -- 370
		end -- 370
	end -- 370
	local hudName = label( -- 380
		layer, -- 380
		FONT_B, -- 380
		26, -- 380
		C_INK, -- 380
		112, -- 380
		48, -- 380
		0, -- 380
		3 -- 380
	) -- 380
	hudName.text = "砌墙" -- 381
	local hudYi = Sprite("Image/StartUI/seal_yi.png") -- 382
	hudYi.anchor = Vec2(0, 1) -- 383
	hudYi.size = Size(36, 36) -- 384
	hudYi.position = Vec2(64, H - 24) -- 385
	hudYi:addTo(layer) -- 386
	local barBg = block( -- 388
		layer, -- 388
		340, -- 388
		33, -- 388
		540, -- 388
		7, -- 388
		C_SEAM -- 388
	) -- 388
	barBg.visible = true -- 389
	barBg.opacity = 0.43 -- 390
	local barFill = block( -- 391
		layer, -- 391
		340, -- 391
		33, -- 391
		0, -- 391
		7, -- 391
		C_TEAL -- 391
	) -- 391
	barFill.visible = true -- 392
	local barEnd = block( -- 393
		layer, -- 393
		880, -- 393
		28, -- 393
		3, -- 393
		17, -- 393
		C_VERM -- 393
	) -- 393
	barEnd.visible = true -- 394
	local barTickL = block( -- 395
		layer, -- 395
		340, -- 395
		29, -- 395
		1.5, -- 395
		15, -- 395
		C_INK -- 395
	) -- 395
	barTickL.visible = true -- 396
	barTickL.opacity = 0.35 -- 397
	local hudScore = label( -- 399
		layer, -- 399
		FONT_B, -- 399
		36, -- 399
		C_INK, -- 399
		1160, -- 399
		52, -- 399
		1, -- 399
		1 -- 399
	) -- 399
	local hudProg = label( -- 400
		layer, -- 400
		FONT_R, -- 400
		15, -- 400
		C_INK, -- 400
		1160, -- 400
		78, -- 400
		1, -- 400
		0 -- 400
	) -- 400
	hudProg.opacity = 0.5 -- 401
	local SET_X = 1194 -- 406
	local SET_Y = 14 -- 406
	local SET_S = 44 -- 406
	local gearBtn = Sprite("Image/StartUI/gear.png") -- 407
	gearBtn.anchor = Vec2(0, 1) -- 408
	gearBtn.size = Size(SET_S, SET_S) -- 409
	gearBtn.position = Vec2(SET_X, H - SET_Y) -- 410
	gearBtn:addTo(layer) -- 411
	local PANEL_W = 248 -- 413
	local PANEL_H = 204 -- 413
	local PX = SET_X + SET_S - PANEL_W -- 414
	local PY = SET_Y + SET_S + 10 -- 415
	local panel = Sprite("Image/StartUI/panel.png") -- 417
	panel.anchor = Vec2(0, 1) -- 418
	panel.size = Size(256, 212) -- 419
	panel.position = Vec2(PX - 4, H - (PY - 4)) -- 420
	panel:addTo(layer) -- 421
	local IX = PX + 22 -- 423
	local IW = PANEL_W - 44 -- 423
	local setParts = {} -- 424
	local sliderBg = {} -- 425
	local sliderFill = {} -- 426
	local knobEdge = {} -- 427
	local knobFace = {} -- 428
	local setLabels = {} -- 429
	local function mkSetLabel(size, color, x, y, ax, txt) -- 431
		local lb = label( -- 433
			layer, -- 433
			size >= 16 and FONT_R or FONT_R, -- 433
			size, -- 433
			color, -- 433
			x, -- 433
			y, -- 433
			ax, -- 433
			1 -- 433
		) -- 433
		lb.text = txt -- 434
		setLabels[#setLabels + 1] = lb -- 435
		return lb -- 436
	end -- 431
	local barLabelY = {PY + 30, PY + 96} -- 439
	local barY = {PY + 46, PY + 112} -- 440
	do -- 440
		local i = 0 -- 442
		while i < 2 do -- 442
			mkSetLabel( -- 443
				15, -- 443
				C_INK, -- 443
				IX, -- 443
				barLabelY[i + 1], -- 443
				0, -- 443
				i == 0 and "背景音乐" or "音效" -- 443
			) -- 443
			mkSetLabel( -- 444
				14, -- 444
				C_TEAL, -- 444
				PX + PANEL_W - 22, -- 444
				barLabelY[i + 1], -- 444
				1, -- 444
				"70" -- 444
			) -- 444
			local bg = block( -- 446
				layer, -- 446
				IX, -- 446
				barY[i + 1], -- 446
				IW, -- 446
				6, -- 446
				C_INK -- 446
			) -- 446
			bg.opacity = 0.14 -- 447
			sliderBg[#sliderBg + 1] = bg -- 448
			local fill = block( -- 450
				layer, -- 450
				IX, -- 450
				barY[i + 1], -- 450
				IW, -- 450
				6, -- 450
				C_TEAL -- 450
			) -- 450
			sliderFill[#sliderFill + 1] = fill -- 451
			local ke = block( -- 453
				layer, -- 453
				0, -- 453
				0, -- 453
				12, -- 453
				20, -- 453
				C_INK -- 453
			) -- 453
			knobEdge[#knobEdge + 1] = ke -- 454
			local kf = block( -- 455
				layer, -- 455
				0, -- 455
				0, -- 455
				10, -- 455
				18, -- 455
				C_PAPER -- 455
			) -- 455
			knobFace[#knobFace + 1] = kf -- 456
			i = i + 1 -- 442
		end -- 442
	end -- 442
	local setSep = block( -- 459
		layer, -- 459
		IX, -- 459
		PY + 140, -- 459
		IW, -- 459
		1, -- 459
		C_INK -- 459
	) -- 459
	setSep.opacity = 0.12 -- 460
	local backEdge = block( -- 461
		layer, -- 461
		IX, -- 461
		PY + 152, -- 461
		IW, -- 461
		36, -- 461
		C_INK -- 461
	) -- 461
	backEdge.opacity = 0.7 -- 462
	local backFace = block( -- 463
		layer, -- 463
		IX + 1.6, -- 463
		PY + 153.6, -- 463
		IW - 3.2, -- 463
		33, -- 463
		Color(252, 247, 232, 255) -- 463
	) -- 463
	local backLb = label( -- 465
		layer, -- 465
		FONT_R, -- 465
		16, -- 465
		C_INK, -- 465
		IX + IW / 2, -- 465
		PY + 177, -- 465
		0.5, -- 465
		2 -- 465
	) -- 465
	backLb.text = "返回主菜单" -- 466
	setLabels[#setLabels + 1] = backLb -- 467
	local function setToggle(vis) -- 470
		panel.visible = vis -- 471
		setSep.visible = vis -- 472
		backEdge.visible = vis -- 473
		backFace.visible = vis -- 474
		for ____, x in ipairs(setParts) do -- 475
			x.visible = vis -- 475
		end -- 475
		for ____, x in ipairs(sliderBg) do -- 476
			x.visible = vis -- 476
		end -- 476
		for ____, x in ipairs(sliderFill) do -- 477
			x.visible = vis -- 477
		end -- 477
		for ____, x in ipairs(knobEdge) do -- 478
			x.visible = vis -- 478
		end -- 478
		for ____, x in ipairs(knobFace) do -- 479
			x.visible = vis -- 479
		end -- 479
		for ____, x in ipairs(setLabels) do -- 480
			x.visible = vis -- 480
		end -- 480
	end -- 470
	setToggle(false) -- 482
	local pops = {} -- 488
	local POP_POOL = 6 -- 489
	local popLabels = {} -- 490
	local popShadow = {} -- 491
	do -- 491
		local i = 0 -- 492
		while i < POP_POOL do -- 492
			local sh = label( -- 493
				layer, -- 493
				FONT_B, -- 493
				30, -- 493
				C_INK, -- 493
				0, -- 493
				0, -- 493
				0.5, -- 493
				1 -- 493
			) -- 493
			sh.opacity = 0 -- 494
			popShadow[#popShadow + 1] = sh -- 495
			local lb = label( -- 496
				layer, -- 496
				FONT_B, -- 496
				30, -- 496
				C_VERM, -- 496
				0, -- 496
				0, -- 496
				0.5, -- 496
				1 -- 496
			) -- 496
			lb.outlineColor = C_PAPER -- 497
			lb.outlineWidth = 0.16 -- 498
			lb.opacity = 0 -- 499
			popLabels[#popLabels + 1] = lb -- 500
			i = i + 1 -- 492
		end -- 492
	end -- 492
	local function syncPops() -- 503
		do -- 503
			local i = 0 -- 504
			while i < POP_POOL do -- 504
				do -- 504
					local p = i < #pops and pops[i + 1] or nil -- 505
					if p == nil then -- 505
						popLabels[i + 1].opacity = 0 -- 507
						popShadow[i + 1].opacity = 0 -- 508
						goto __continue87 -- 509
					end -- 509
					local a = math.max(0, p.t / p.dur) -- 511
					local y = p.y - (1 - a) * 34 -- 512
					local al = math.min(1, a * 1.6) -- 513
					popShadow[i + 1].text = "+" .. tostring(p.v) -- 514
					popShadow[i + 1].position = Vec2(p.x + 2, H - y + 30) -- 515
					popShadow[i + 1].opacity = al * 0.6 -- 516
					popLabels[i + 1].text = "+" .. tostring(p.v) -- 517
					popLabels[i + 1].position = Vec2(p.x, H - y + 30) -- 518
					popLabels[i + 1].opacity = al -- 519
				end -- 519
				::__continue87:: -- 519
				i = i + 1 -- 504
			end -- 504
		end -- 504
	end -- 503
	local HINT_RIGHT = 1246 -- 525
	local HINT_CY = 751 -- 525
	local CAPH = 24 -- 525
	local capEdge = {} -- 526
	local capBody = {} -- 527
	local function mkCap(x, w, txt) -- 528
		local e = block( -- 529
			layer, -- 529
			x, -- 529
			HINT_CY - CAPH / 2, -- 529
			w, -- 529
			CAPH, -- 529
			C_INK -- 529
		) -- 529
		e.visible = true -- 530
		e.opacity = 0.58 -- 531
		capEdge[#capEdge + 1] = e -- 532
		local b = block( -- 533
			layer, -- 533
			x + 1.4, -- 533
			HINT_CY - CAPH / 2 + 1.4, -- 533
			w - 2.8, -- 533
			CAPH - 2.8, -- 533
			C_PAPER -- 533
		) -- 533
		b.visible = true -- 534
		b.opacity = 0.72 -- 535
		capBody[#capBody + 1] = b -- 536
		local lb = label( -- 537
			layer, -- 537
			FONT_R, -- 537
			12, -- 537
			C_INK, -- 537
			x + w / 2, -- 537
			HINT_CY + 6, -- 537
			0.5, -- 537
			0 -- 537
		) -- 537
		lb.text = txt -- 538
		return lb -- 539
	end -- 528
	local X0 = HINT_RIGHT - 185 -- 542
	mkCap(X0, 30, "R") -- 543
	local tRot = label( -- 544
		layer, -- 544
		FONT_R, -- 544
		15, -- 544
		C_INK, -- 544
		X0 + 38, -- 544
		HINT_CY + 8, -- 544
		0, -- 544
		1 -- 544
	) -- 544
	tRot.text = "转方向" -- 545
	tRot.opacity = 0.86 -- 546
	mkCap(X0 + 111, 36, "Esc") -- 547
	local tBack = label( -- 548
		layer, -- 548
		FONT_R, -- 548
		15, -- 548
		C_INK, -- 548
		X0 + 155, -- 548
		HINT_CY + 8, -- 548
		0, -- 548
		1 -- 548
	) -- 548
	tBack.text = "放回" -- 549
	tBack.opacity = 0.86 -- 550
	local function syncSet() -- 552
		local vis = showSet and state == "play" -- 553
		if panel.visible ~= vis then -- 553
			setToggle(vis) -- 554
		end -- 554
		if not vis then -- 554
			return -- 555
		end -- 555
		local vals = {audio.bgm, audio.sfx} -- 557
		do -- 557
			local i = 0 -- 558
			while i < 2 do -- 558
				local k = vals[i + 1] -- 559
				local w = math.floor(IW * k + 0.5) -- 560
				show( -- 561
					sliderFill[i + 1], -- 561
					IX, -- 561
					barY[i + 1], -- 561
					math.max(1, w), -- 561
					6 -- 561
				) -- 561
				local hx = IX + w - 5 -- 562
				show( -- 563
					knobEdge[i + 1], -- 563
					hx, -- 563
					barY[i + 1] - 7, -- 563
					12, -- 563
					20 -- 563
				) -- 563
				show( -- 564
					knobFace[i + 1], -- 564
					hx + 1, -- 564
					barY[i + 1] - 6, -- 564
					10, -- 564
					18 -- 564
				) -- 564
				i = i + 1 -- 558
			end -- 558
		end -- 558
		setLabels[2].text = tostring(math.floor(audio.bgm * 100 + 0.5)) -- 566
		setLabels[4].text = tostring(math.floor(audio.sfx * 100 + 0.5)) -- 567
	end -- 552
	local veil = block( -- 571
		layer, -- 571
		0, -- 571
		0, -- 571
		W, -- 571
		H, -- 571
		Color(237, 227, 200, 255) -- 571
	) -- 571
	local burst = Sprite("Image/StartUI/burst.png") -- 572
	burst.anchor = Vec2(0, 1) -- 573
	burst.size = Size(W, 800) -- 574
	burst.position = Vec2(0, H) -- 575
	burst:addTo(layer) -- 576
	local stWall = Sprite("Image/StartUI/ready_wall.png") -- 580
	stWall.anchor = Vec2(0, 1) -- 581
	stWall.size = Size(W, 150) -- 582
	stWall.position = Vec2(0, H) -- 583
	stWall:addTo(layer) -- 584
	local stBeam = block( -- 586
		layer, -- 586
		0, -- 586
		150, -- 586
		W, -- 586
		24, -- 586
		Color(28, 44, 40, 255) -- 586
	) -- 586
	local stBeamTop = block( -- 587
		layer, -- 587
		0, -- 587
		151, -- 587
		W, -- 587
		3, -- 587
		Color(237, 227, 200, 110) -- 587
	) -- 587
	local stBeamLine = block( -- 588
		layer, -- 588
		0, -- 588
		174, -- 588
		W, -- 588
		3, -- 588
		C_INK -- 588
	) -- 588
	local stWz = Sprite("Image/StartUI/face_smile.png") -- 590
	stWz.anchor = Vec2(0, 1) -- 591
	stWz.size = Size(286, 384) -- 592
	stWz.position = Vec2(918, H - 316) -- 593
	stWz:addTo(layer) -- 594
	local stFoot = label( -- 596
		layer, -- 596
		FONT_R, -- 596
		11, -- 596
		Color(36, 73, 70, 105), -- 596
		112, -- 596
		752, -- 596
		0, -- 596
		1.2 -- 596
	) -- 596
	stFoot.text = "永昌堡 · 嘉靖四十年 · 五月" -- 597
	local card = Sprite("Image/StartUI/card.png") -- 599
	card.anchor = Vec2(0, 1) -- 600
	card.size = Size(782, 484) -- 601
	card.position = Vec2(254, H - 160) -- 602
	card:addTo(layer) -- 603
	local sealHe = Sprite("Image/StartUI/seal_he.png") -- 605
	local sealPo = Sprite("Image/StartUI/seal_po.png") -- 606
	for ____, sp in ipairs({sealHe, sealPo}) do -- 607
		sp.anchor = Vec2(0, 1) -- 608
		sp.size = Size(76, 76) -- 609
		sp.position = Vec2(910, H - 196) -- 610
		sp.visible = false -- 611
		sp:addTo(layer) -- 612
	end -- 612
	local endTitle = label( -- 616
		layer, -- 616
		FONT_B, -- 616
		60, -- 616
		C_INK, -- 616
		640, -- 616
		268, -- 616
		0.5, -- 616
		6 -- 616
	) -- 616
	local endScore = label( -- 617
		layer, -- 617
		FONT_B, -- 617
		76, -- 617
		C_INK, -- 617
		640, -- 617
		406, -- 617
		0.5, -- 617
		2 -- 617
	) -- 617
	local endStat = label( -- 618
		layer, -- 618
		FONT_R, -- 618
		18, -- 618
		Color(36, 73, 70, 150), -- 618
		640, -- 618
		448, -- 618
		0.5, -- 618
		1 -- 618
	) -- 618
	local endTip = label( -- 619
		layer, -- 619
		FONT_R, -- 619
		20, -- 619
		Color(36, 73, 70, 200), -- 619
		640, -- 619
		516, -- 619
		0.5, -- 619
		1 -- 619
	) -- 619
	local endRule = block( -- 622
		layer, -- 622
		580, -- 622
		284, -- 622
		120, -- 622
		4, -- 622
		C_VERM -- 622
	) -- 622
	local endLabel = label( -- 623
		layer, -- 623
		FONT_R, -- 623
		14, -- 623
		C_INK, -- 623
		640, -- 623
		326, -- 623
		0.5, -- 623
		7 -- 623
	) -- 623
	endLabel.text = "得　分" -- 624
	endLabel.opacity = 0.58 -- 625
	local endSepLine = block( -- 626
		layer, -- 626
		400, -- 626
		472, -- 626
		480, -- 626
		1, -- 626
		C_INK -- 626
	) -- 626
	endSepLine.opacity = 0.16 -- 627
	local endSepRed = block( -- 628
		layer, -- 628
		618, -- 628
		471, -- 628
		44, -- 628
		3, -- 628
		C_VERM -- 628
	) -- 628
	local stTitle = label( -- 631
		layer, -- 631
		FONT_B, -- 631
		82, -- 631
		C_INK, -- 631
		106, -- 631
		292, -- 631
		0, -- 631
		16 -- 631
	) -- 631
	stTitle.text = "砌墙" -- 632
	local stYi = Sprite("Image/StartUI/seal_yi.png") -- 633
	stYi.anchor = Vec2(0, 1) -- 634
	stYi.size = Size(36, 36) -- 635
	stYi.position = Vec2(112, H - 210) -- 636
	stYi:addTo(layer) -- 637
	local stQian = label( -- 638
		layer, -- 638
		FONT_B, -- 638
		14, -- 638
		Color(36, 73, 70, 140), -- 638
		160, -- 638
		220, -- 638
		0, -- 638
		4 -- 638
	) -- 638
	stQian.text = "关 前" -- 639
	local stRule = block( -- 640
		layer, -- 640
		112, -- 640
		396, -- 640
		128, -- 640
		4, -- 640
		C_VERM -- 640
	) -- 640
	local stSub = label( -- 641
		layer, -- 641
		FONT_B, -- 641
		23, -- 641
		Color(36, 73, 70, 225), -- 641
		112, -- 641
		430, -- 641
		0, -- 641
		1.4 -- 641
	) -- 641
	stSub.text = "城墙六行，缺处待补" -- 642
	local stSep = block( -- 643
		layer, -- 643
		112, -- 643
		492, -- 643
		448, -- 643
		1, -- 643
		C_INK -- 643
	) -- 643
	stSep.opacity = 0.3 -- 644
	local stLine1 = label( -- 645
		layer, -- 645
		FONT_R, -- 645
		16, -- 645
		Color(36, 73, 70, 190), -- 645
		112, -- 645
		524, -- 645
		0, -- 645
		0.8 -- 645
	) -- 645
	stLine1.text = "墙在走。手上有五块石头，把对的形状转到对的朝向，嵌进去。" -- 646
	local stLine2 = label( -- 647
		layer, -- 647
		FONT_R, -- 647
		16, -- 647
		Color(36, 73, 70, 190), -- 647
		112, -- 647
		556, -- 647
		0, -- 647
		0.6 -- 647
	) -- 647
	stLine2.text = "补满 10 个洞，这段墙就合上了。漏掉一个，就守不住。" -- 648
	local stSpace = label( -- 649
		layer, -- 649
		FONT_R, -- 649
		13, -- 649
		C_INK, -- 649
		384, -- 649
		642, -- 649
		0, -- 649
		1.6 -- 649
	) -- 649
	stSpace.text = "点任意处 / 空格" -- 650
	stSpace.opacity = 0.5 -- 651
	local function mkBtn() -- 658
		local shadow = block( -- 659
			layer, -- 659
			0, -- 659
			0, -- 659
			1, -- 659
			1, -- 659
			Color(36, 73, 70, 235) -- 659
		) -- 659
		local body = Sprite("Image/StartUI/btn.png") -- 660
		body.anchor = Vec2(0, 1) -- 661
		body.size = Size(1, 1) -- 662
		body.position = Vec2(0, H) -- 663
		body.visible = false -- 664
		body:addTo(layer) -- 665
		local t = label( -- 666
			layer, -- 666
			FONT_B, -- 666
			22, -- 666
			C_INK, -- 666
			0, -- 666
			0, -- 666
			0.5, -- 666
			6 -- 666
		) -- 666
		return { -- 667
			shadow = shadow, -- 667
			body = body, -- 667
			text = t, -- 667
			x = 0, -- 667
			y = 0, -- 667
			w = 240, -- 667
			h = 58, -- 667
			kind = "" -- 667
		} -- 667
	end -- 658
	local btn = mkBtn() -- 669
	local function placeBtn(b, x, y, w, h, kind) -- 671
		b.x = x -- 672
		b.y = y -- 672
		b.w = w -- 672
		b.h = h -- 672
		b.kind = kind -- 672
		b.shadow.visible = true -- 673
		b.body.visible = true -- 673
		b.text.visible = true -- 673
	end -- 671
	local function hideBtn(b) -- 675
		b.shadow.visible = false -- 676
		b.body.visible = false -- 676
		b.text.visible = false -- 676
		b.kind = "" -- 677
	end -- 675
	local function syncBtn(b, hover, press, dt) -- 679
		if not b.body.visible then -- 679
			return -- 680
		end -- 680
		local target = press and 6 or (hover and 3 or 0) -- 682
		btnOff = btnOff + (target - btnOff) * math.min(1, dt * 22) -- 683
		if math.abs(target - btnOff) < 0.08 then -- 683
			btnOff = target -- 684
		end -- 684
		local off = btnOff -- 685
		show( -- 686
			b.shadow, -- 686
			b.x + 6, -- 686
			b.y + 6, -- 686
			b.w, -- 686
			b.h -- 686
		) -- 686
		b.body.color = hover and C_INK or (state == "ready" and Color(236, 190, 176, 255) or Color(255, 255, 255, 255)) -- 687
		show( -- 689
			b.body, -- 689
			b.x + off, -- 689
			b.y + off, -- 689
			b.w, -- 689
			b.h -- 689
		) -- 689
		b.text.color = hover and Color(252, 247, 232, 245) or C_INK -- 690
		b.text.position = Vec2(b.x + off + b.w / 2, H - (b.y + off + b.h / 2 - 11)) -- 691
	end -- 679
	local readyT = 0 -- 697
	local function syncReady(dt) -- 699
		if state ~= "ready" then -- 699
			if readyT > 0 then -- 699
				readyT = 0 -- 702
				stWall.position = Vec2(0, H) -- 703
				stWz.position = Vec2(918, H - 316) -- 704
				stTitle.position = Vec2(106, H - 292) -- 705
				stTitle.opacity = 1 -- 706
				stYi.opacity = 1 -- 707
				stYi.scaleX = 1 -- 707
				stYi.scaleY = 1 -- 707
				stSub.opacity = 1 -- 708
				stLine1.opacity = 1 -- 708
				stLine2.opacity = 1 -- 708
				stSpace.opacity = 0.5 -- 709
				stQian.opacity = 1 -- 709
				stFoot.opacity = 1 -- 709
				stSep.opacity = 0.3 -- 710
				show( -- 711
					stRule, -- 711
					112, -- 711
					396, -- 711
					128, -- 711
					4 -- 711
				) -- 711
			end -- 711
			return -- 713
		end -- 713
		readyT = readyT + dt -- 716
		local function ease(t0, dur) -- 717
			local k = math.min( -- 718
				1, -- 718
				math.max(0, (readyT - t0) / dur) -- 718
			) -- 718
			return 1 - (1 - k) ^ 3 -- 719
		end -- 717
		local aWall = ease(0.04, 0.48) -- 722
		stWall.position = Vec2(0, H - 26 * (1 - aWall)) -- 723
		local aWz = ease(0.18, 0.58) -- 725
		stWz.position = Vec2(918 + 72 * (1 - aWz), H - 316) -- 726
		local aYi = ease(0.22, 0.24) -- 728
		stYi.opacity = aYi -- 729
		local kYi = 1 + 1.3 * (1 - aYi) -- 730
		stYi.scaleX = kYi -- 731
		stYi.scaleY = kYi -- 731
		stQian.opacity = ease(0.3, 0.3) -- 732
		local aTitle = ease(0.42, 0.48) -- 734
		stTitle.opacity = aTitle -- 735
		stTitle.position = Vec2(106 + 42 * (1 - aTitle), H - 292) -- 736
		local aRule = ease(0.68, 0.4) -- 738
		show( -- 739
			stRule, -- 739
			112, -- 739
			396, -- 739
			math.max(1, 128 * aRule), -- 739
			4 -- 739
		) -- 739
		stSub.opacity = ease(0.84, 0.42) -- 741
		stSep.opacity = 0.3 * ease(0.98, 0.4) -- 742
		stLine1.opacity = ease(1.06, 0.42) -- 743
		stLine2.opacity = ease(1.16, 0.42) -- 744
		stSpace.opacity = 0.5 * ease(1.34, 0.42) -- 745
		stFoot.opacity = ease(1.44, 0.42) -- 746
		if btn.body.visible then -- 746
			local aBtn = ease(1.28, 0.42) -- 749
			btn.body.opacity = aBtn -- 750
			btn.shadow.opacity = aBtn * 0.92 -- 751
			btn.text.opacity = aBtn -- 752
		end -- 752
	end -- 699
	state = "ready" -- 757
	local shakeT = 0 -- 758
	local shakeTarget = -1 -- 758
	local flashGap = nil -- 759
	local hintOn = true -- 760
	showSet = false -- 761
	audio = {bgm = 0.7, sfx = 0.8} -- 762
	local gaps = {} -- 763
	local hand = {} -- 764
	local bag = {} -- 765
	local held = nil -- 766
	local speedBase = V0 -- 767
	local score = 0 -- 768
	local filled = 0 -- 768
	local timeouts = 0 -- 768
	local rotLockT = 0 -- 768
	local rotCount = 0 -- 768
	local spawnTimer = 1.1 -- 769
	local scrollX = 0 -- 770
	local timeAll = 0 -- 771
	local faceHold = 0 -- 771
	local debugHold = false -- 772
	local function rnd() -- 774
		return math.random() -- 774
	end -- 774
	local function nextFromBag() -- 776
		if #bag == 0 then -- 776
			local b = {} -- 778
			do -- 778
				local i = 0 -- 779
				while i < #KEYS do -- 779
					b[#b + 1] = KEYS[i + 1] -- 779
					i = i + 1 -- 779
				end -- 779
			end -- 779
			do -- 779
				local i = #b - 1 -- 780
				while i > 0 do -- 780
					local j = math.floor(rnd() * (i + 1)) -- 781
					local t = b[i + 1] -- 782
					b[i + 1] = b[j + 1] -- 782
					b[j + 1] = t -- 782
					i = i - 1 -- 780
				end -- 780
			end -- 780
			bag = b -- 784
		end -- 784
		return table.remove(bag) -- 786
	end -- 776
	local function randVi(shape, easy) -- 788
		local n = #VARIANTS[shape] -- 789
		return easy and 0 or math.floor(rnd() * n) -- 790
	end -- 788
	local function drawCard() -- 792
		local shape = nextFromBag() -- 793
		return { -- 794
			shape = shape, -- 794
			vi = randVi(shape, filled < EASY_GAPS) -- 794
		} -- 794
	end -- 792
	local function curCol(g, c) -- 797
		return math.floor(g.x / CELL + 0.5) + c -- 797
	end -- 797
	local function occupied() -- 799
		local s = {} -- 800
		for ____, g in ipairs(gaps) do -- 801
			for ____, cell in ipairs(g.cells) do -- 802
				s[(tostring(curCol(g, cell[1])) .. ",") .. tostring(cell[2])] = true -- 803
			end -- 803
		end -- 803
		return s -- 806
	end -- 799
	local SEAM_SEP = 1 -- 809
	local function spawnGap() -- 811
		if #hand == 0 then -- 811
			return false -- 812
		end -- 812
		local easy = filled < EASY_GAPS -- 813
		local owned = {} -- 815
		for ____, c in ipairs(hand) do -- 816
			if __TS__ArrayIndexOf(owned, c.shape) < 0 then -- 816
				owned[#owned + 1] = c.shape -- 817
			end -- 817
		end -- 817
		local lastShape = #gaps > 0 and gaps[#gaps].shape or "" -- 819
		local pool = {} -- 820
		for ____, s in ipairs(owned) do -- 821
			if s ~= lastShape then -- 821
				pool[#pool + 1] = s -- 821
			end -- 821
		end -- 821
		if #pool == 0 then -- 821
			pool = owned -- 822
		end -- 822
		local shape = pool[math.floor(rnd() * #pool) + 1] -- 823
		local vs = VARIANTS[shape] -- 825
		local vi = easy and 0 or math.floor(rnd() * #vs) -- 826
		local v = vs[vi + 1] -- 827
		local taken = occupied() -- 829
		local baseCol = -v.w -- 830
		local rs = {} -- 831
		do -- 831
			local r = 0 -- 832
			while r <= ROWS - v.h do -- 832
				rs[#rs + 1] = r -- 832
				r = r + 1 -- 832
			end -- 832
		end -- 832
		do -- 832
			local i = #rs - 1 -- 833
			while i > 0 do -- 833
				local j = math.floor(rnd() * (i + 1)) -- 834
				local t = rs[i + 1] -- 835
				rs[i + 1] = rs[j + 1] -- 835
				rs[j + 1] = t -- 835
				i = i - 1 -- 833
			end -- 833
		end -- 833
		local function colClash(colBase) -- 838
			for ____, g in ipairs(gaps) do -- 839
				local gc = math.floor(g.x / CELL + 0.5) -- 840
				if colBase < gc + g.w + SEAM_SEP and gc < colBase + v.w + SEAM_SEP then -- 840
					return true -- 841
				end -- 841
			end -- 841
			return false -- 843
		end -- 838
		do -- 838
			local dx = 0 -- 846
			while dx >= -10 do -- 846
				for ____, r0 in ipairs(rs) do -- 847
					do -- 847
						local colBase = baseCol + dx -- 848
						if colClash(colBase) then -- 848
							goto __continue142 -- 849
						end -- 849
						local cells = {} -- 850
						local bad = false -- 851
						for ____, cell in ipairs(v.cells) do -- 852
							local c = cell[1] -- 853
							local r = cell[2] + r0 -- 853
							if taken[(tostring(colBase + c) .. ",") .. tostring(r)] then -- 853
								bad = true -- 854
								break -- 854
							end -- 854
							cells[#cells + 1] = {c, r} -- 855
						end -- 855
						if bad then -- 855
							goto __continue142 -- 857
						end -- 857
						gaps[#gaps + 1] = { -- 858
							shape = shape, -- 859
							vi = vi, -- 859
							ck = v.ck, -- 859
							w = v.w, -- 859
							h = v.h, -- 859
							cells = cells, -- 860
							r0 = r0, -- 860
							x = colBase * CELL, -- 860
							age = 0, -- 860
							id = rnd() -- 860
						} -- 860
						return true -- 862
					end -- 862
					::__continue142:: -- 862
				end -- 862
				dx = dx - 1 -- 846
			end -- 846
		end -- 846
		return false -- 865
	end -- 811
	local function refillCard(i) -- 868
		hand[i + 1] = drawCard() -- 869
		for ____, g in ipairs(gaps) do -- 870
			local has = false -- 871
			for ____, c in ipairs(hand) do -- 872
				if c.shape == g.shape then -- 872
					has = true -- 872
					break -- 872
				end -- 872
			end -- 872
			if not has then -- 872
				hand[i + 1] = { -- 874
					shape = g.shape, -- 874
					vi = randVi(g.shape, filled < EASY_GAPS) -- 874
				} -- 874
				break -- 875
			end -- 875
		end -- 875
	end -- 868
	local function reset() -- 880
		gaps = {} -- 881
		hand = {} -- 881
		bag = {} -- 881
		held = nil -- 881
		speedBase = V0 -- 882
		score = 0 -- 882
		filled = 0 -- 882
		timeouts = 0 -- 882
		rotLockT = 0 -- 883
		rotCount = 0 -- 883
		spawnTimer = 1.1 -- 883
		timeAll = 0 -- 883
		faceHold = 0 -- 883
		faceCur = 0 -- 884
		pops = {} -- 885
		shakeT = 0 -- 885
		shakeTarget = -1 -- 885
		flashGap = nil -- 885
		showSet = false -- 885
		do -- 885
			local i = 0 -- 886
			while i < HAND_N do -- 886
				hand[#hand + 1] = drawCard() -- 886
				i = i + 1 -- 886
			end -- 886
		end -- 886
		state = "play" -- 887
	end -- 880
	reset() -- 890
	state = startPhase ~= nil and startPhase or "ready" -- 891
	if startPhase == "hold" then -- 891
		state = "play" -- 893
		debugHold = true -- 893
	end -- 893
	if startPhase == "settings" then -- 893
		state = "play" -- 894
		showSet = true -- 894
	end -- 894
	if startPhase == "pops" then -- 894
		state = "play" -- 896
		pops[#pops + 1] = { -- 897
			x = 640, -- 897
			y = 470, -- 897
			v = 186, -- 897
			t = 6, -- 897
			dur = 6 -- 897
		} -- 897
		pops[#pops + 1] = { -- 898
			x = 420, -- 898
			y = 520, -- 898
			v = 92, -- 898
			t = 6, -- 898
			dur = 6 -- 898
		} -- 898
	end -- 898
	local function syncGaps() -- 902
		local function shakeOf(g) -- 904
			return shakeT > 0 and shakeTarget == g.id and math.sin(shakeT * 90) * 6 or 0 -- 905
		end -- 904
		local k = 0 -- 907
		local e = 0 -- 907
		local l = 0 -- 907
		for ____, g in ipairs(gaps) do -- 909
			local sh = shakeOf(g) -- 910
			local occ = {} -- 913
			for ____, c in ipairs(g.cells) do -- 914
				occ[(tostring(c[1]) .. ",") .. tostring(c[2])] = true -- 914
			end -- 914
			for ____, cell in ipairs(g.cells) do -- 916
				if k >= GAP_POOL then -- 916
					break -- 917
				end -- 917
				local cx = g.x + cell[1] * CELL + sh -- 918
				local cy = WALL_T + cell[2] * CELL -- 919
				local function has(dc, dr) -- 920
					return occ[(tostring(cell[1] + dc) .. ",") .. tostring(cell[2] + dr)] == true -- 921
				end -- 920
				show( -- 923
					gapCells[k + 1], -- 923
					cx, -- 923
					cy, -- 923
					CELL, -- 923
					CELL -- 923
				) -- 923
				k = k + 1 -- 924
				if e < EDGE_POOL then -- 924
					if not has(0, -1) then -- 924
						local ____e_0 = e -- 924
						e = ____e_0 + 1 -- 928
						show( -- 928
							edgePool[____e_0 + 1], -- 928
							cx, -- 928
							cy - 1.5, -- 928
							CELL, -- 928
							3 -- 928
						) -- 928
					end -- 928
					if not has(0, 1) and e < EDGE_POOL then -- 928
						local ____e_1 = e -- 928
						e = ____e_1 + 1 -- 929
						show( -- 929
							edgePool[____e_1 + 1], -- 929
							cx, -- 929
							cy + CELL - 1.5, -- 929
							CELL, -- 929
							3 -- 929
						) -- 929
					end -- 929
					if not has(-1, 0) and e < EDGE_POOL then -- 929
						local ____e_2 = e -- 929
						e = ____e_2 + 1 -- 930
						show( -- 930
							edgePool[____e_2 + 1], -- 930
							cx - 1.5, -- 930
							cy, -- 930
							3, -- 930
							CELL -- 930
						) -- 930
					end -- 930
					if not has(1, 0) and e < EDGE_POOL then -- 930
						local ____e_3 = e -- 930
						e = ____e_3 + 1 -- 931
						show( -- 931
							edgePool[____e_3 + 1], -- 931
							cx + CELL - 1.5, -- 931
							cy, -- 931
							3, -- 931
							CELL -- 931
						) -- 931
					end -- 931
				end -- 931
				if not has(0, -1) and l < LIT_POOL then -- 931
					local ____l_4 = l -- 931
					l = ____l_4 + 1 -- 936
					show( -- 936
						litPool[____l_4 + 1], -- 936
						cx, -- 936
						cy + 2, -- 936
						CELL, -- 936
						4 -- 936
					) -- 936
				end -- 936
			end -- 936
		end -- 936
		do -- 936
			local i = k -- 940
			while i < GAP_POOL do -- 940
				hide(gapCells[i + 1]) -- 940
				i = i + 1 -- 940
			end -- 940
		end -- 940
		do -- 940
			local i = e -- 941
			while i < EDGE_POOL do -- 941
				hide(edgePool[i + 1]) -- 941
				i = i + 1 -- 941
			end -- 941
		end -- 941
		do -- 941
			local i = l -- 942
			while i < LIT_POOL do -- 942
				hide(litPool[i + 1]) -- 942
				i = i + 1 -- 942
			end -- 942
		end -- 942
		local hit = nil -- 945
		if hintOn and state == "play" and held ~= nil then -- 945
			local hv = VARIANTS[held.shape][held.vi + 1] -- 947
			for ____, g in ipairs(gaps) do -- 948
				if g.ck == hv.ck then -- 948
					hit = g -- 948
					break -- 948
				end -- 948
			end -- 948
		end -- 948
		local hk = 0 -- 951
		if hit ~= nil then -- 951
			local breath = 0.78 + 0.22 * (0.5 + 0.5 * math.sin(timeAll * 6)) -- 953
			local sh = shakeOf(hit) -- 954
			for ____, cell in ipairs(hit.cells) do -- 957
				if hk >= HATCH_POOL then -- 957
					break -- 958
				end -- 958
				local ____hk_5 = hk -- 958
				hk = ____hk_5 + 1 -- 959
				local h = hatchPool[____hk_5 + 1] -- 959
				show( -- 960
					h, -- 960
					hit.x + cell[1] * CELL + sh, -- 960
					WALL_T + cell[2] * CELL, -- 960
					CELL, -- 960
					CELL -- 960
				) -- 960
				h.opacity = 0.2 * breath -- 961
			end -- 961
			local x0 = hit.x - 10 + sh -- 965
			local y0 = WALL_T + hit.r0 * CELL - 10 -- 966
			local w0 = hit.w * CELL + 20 -- 967
			local h0 = hit.h * CELL + 20 -- 968
			local t = 3.2 -- 969
			do -- 969
				local i = 0 -- 970
				while i < 4 do -- 970
					hintEdges[i + 1].opacity = breath -- 970
					i = i + 1 -- 970
				end -- 970
			end -- 970
			show( -- 971
				hintEdges[1], -- 971
				x0, -- 971
				y0, -- 971
				w0, -- 971
				t -- 971
			) -- 971
			show( -- 972
				hintEdges[2], -- 972
				x0, -- 972
				y0 + h0 - t, -- 972
				w0, -- 972
				t -- 972
			) -- 972
			show( -- 973
				hintEdges[3], -- 973
				x0, -- 973
				y0, -- 973
				t, -- 973
				h0 -- 973
			) -- 973
			show( -- 974
				hintEdges[4], -- 974
				x0 + w0 - t, -- 974
				y0, -- 974
				t, -- 974
				h0 -- 974
			) -- 974
		else -- 974
			do -- 974
				local i = 0 -- 976
				while i < 4 do -- 976
					hide(hintEdges[i + 1]) -- 976
					i = i + 1 -- 976
				end -- 976
			end -- 976
		end -- 976
		do -- 976
			local i = hk -- 978
			while i < HATCH_POOL do -- 978
				hide(hatchPool[i + 1]) -- 978
				i = i + 1 -- 978
			end -- 978
		end -- 978
		local ni = 4 -- 982
		for ____, g in ipairs(gaps) do -- 983
			do -- 983
				if g == hit or g.age >= 0.9 then -- 983
					goto __continue199 -- 984
				end -- 984
				if ni + 3 >= #hintEdges then -- 984
					break -- 985
				end -- 985
				local a = 1 - g.age / 0.9 -- 986
				local sh = shakeOf(g) -- 987
				local x0 = g.x - 7 + sh -- 988
				local y0 = WALL_T + g.r0 * CELL - 7 -- 989
				local w0 = g.w * CELL + 14 -- 990
				local h0 = g.h * CELL + 14 -- 991
				do -- 991
					local i = ni -- 992
					while i < ni + 4 do -- 992
						hintEdges[i + 1].opacity = 0.8 * a -- 992
						i = i + 1 -- 992
					end -- 992
				end -- 992
				show( -- 993
					hintEdges[ni + 1], -- 993
					x0, -- 993
					y0, -- 993
					w0, -- 993
					2.4 -- 993
				) -- 993
				show( -- 994
					hintEdges[ni + 1 + 1], -- 994
					x0, -- 994
					y0 + h0 - 2.4, -- 994
					w0, -- 994
					2.4 -- 994
				) -- 994
				show( -- 995
					hintEdges[ni + 2 + 1], -- 995
					x0, -- 995
					y0, -- 995
					2.4, -- 995
					h0 -- 995
				) -- 995
				show( -- 996
					hintEdges[ni + 3 + 1], -- 996
					x0 + w0 - 2.4, -- 996
					y0, -- 996
					2.4, -- 996
					h0 -- 996
				) -- 996
				ni = ni + 4 -- 997
			end -- 997
			::__continue199:: -- 997
		end -- 997
		do -- 997
			local i = ni -- 999
			while i < #hintEdges do -- 999
				hide(hintEdges[i + 1]) -- 999
				i = i + 1 -- 999
			end -- 999
		end -- 999
		if flashGap ~= nil and flashGap.t > 0 then -- 999
			local a = flashGap.t / 0.3 -- 1003
			local col = flashGap.ok and C_TEAL or C_VERM -- 1004
			local x0 = flashGap.x - 4 -- 1005
			local y0 = flashGap.y - 4 -- 1005
			local w0 = flashGap.w + 8 -- 1006
			local h0 = flashGap.h + 8 -- 1006
			do -- 1006
				local i = 0 -- 1007
				while i < 4 do -- 1007
					flashEdges[i + 1].color = col -- 1007
					flashEdges[i + 1].opacity = a -- 1007
					i = i + 1 -- 1007
				end -- 1007
			end -- 1007
			show( -- 1008
				flashEdges[1], -- 1008
				x0, -- 1008
				y0, -- 1008
				w0, -- 1008
				4 -- 1008
			) -- 1008
			show( -- 1009
				flashEdges[2], -- 1009
				x0, -- 1009
				y0 + h0 - 4, -- 1009
				w0, -- 1009
				4 -- 1009
			) -- 1009
			show( -- 1010
				flashEdges[3], -- 1010
				x0, -- 1010
				y0, -- 1010
				4, -- 1010
				h0 -- 1010
			) -- 1010
			show( -- 1011
				flashEdges[4], -- 1011
				x0 + w0 - 4, -- 1011
				y0, -- 1011
				4, -- 1011
				h0 -- 1011
			) -- 1011
		else -- 1011
			for ____, f in ipairs(flashEdges) do -- 1013
				hide(f) -- 1013
			end -- 1013
		end -- 1013
	end -- 902
	local function syncHand() -- 1017
		local hi = held == nil and -1 or __TS__ArrayIndexOf(hand, held) -- 1018
		local baseK = state == "play" and 1 or (state == "ready" and 0.22 or 0) -- 1019
		local k = 0 -- 1020
		do -- 1020
			local i = 0 -- 1022
			while i < #hand do -- 1022
				local card = hand[i + 1] -- 1023
				local v = VARIANTS[card.shape][card.vi + 1] -- 1024
				local sx = HAND_X + i * (SLOT_W + SLOT_GAP) -- 1025
				local bx = 99 -- 1028
				local by = 99 -- 1028
				local ex = -99 -- 1028
				local ey = -99 -- 1028
				for ____, c in ipairs(v.cells) do -- 1029
					if c[1] < bx then -- 1029
						bx = c[1] -- 1030
					end -- 1030
					if c[1] > ex then -- 1030
						ex = c[1] -- 1031
					end -- 1031
					if c[2] < by then -- 1031
						by = c[2] -- 1032
					end -- 1032
					if c[2] > ey then -- 1032
						ey = c[2] -- 1033
					end -- 1033
				end -- 1033
				local bw = ex - bx + 1 -- 1035
				local bh = ey - by + 1 -- 1035
				local ox = sx + (SLOT_W - bw * CW) / 2 -- 1036
				local oy = SLOT_Y + (SLOT_H - bh * CW) / 2 -- 1037
				local lift = i == hi and 14 or 0 -- 1038
				local lit = i == hi -- 1039
				local dimK = baseK * (hi >= 0 and not lit and 0.42 or 1) -- 1040
				slots[i + 1].opacity = baseK -- 1042
				do -- 1042
					local n = 0 -- 1044
					while n < 4 do -- 1044
						local s = chipPool[k + 1] -- 1045
						k = k + 1 -- 1046
						if n < #v.cells then -- 1046
							local c = v.cells[n + 1] -- 1048
							show( -- 1049
								s, -- 1049
								ox + (c[1] - bx) * CW, -- 1049
								oy + (c[2] - by) * CW - lift, -- 1049
								CW, -- 1049
								CW -- 1049
							) -- 1049
							s.color = lit and Color(255, 250, 238, 255) or Color(255, 255, 255, 255) -- 1050
							s.opacity = dimK -- 1051
						else -- 1051
							hide(s) -- 1053
						end -- 1053
						n = n + 1 -- 1044
					end -- 1044
				end -- 1044
				i = i + 1 -- 1022
			end -- 1022
		end -- 1022
		do -- 1022
			local i = k -- 1057
			while i < #chipPool do -- 1057
				hide(chipPool[i + 1]) -- 1057
				i = i + 1 -- 1057
			end -- 1057
		end -- 1057
		if hi >= 0 and hi < #hand then -- 1057
			local v = VARIANTS[hand[hi + 1].shape][hand[hi + 1].vi + 1] -- 1061
			local sx = HAND_X + hi * (SLOT_W + SLOT_GAP) -- 1062
			local ox = sx + (SLOT_W - v.w * CW) / 2 -- 1063
			local oy = SLOT_Y + (SLOT_H - v.h * CW) / 2 - 14 -- 1064
			local fw = v.w * CW -- 1065
			local fh = v.h * CW -- 1065
			local t = 4 -- 1065
			for ____, f in ipairs(handFrame) do -- 1066
				f.opacity = baseK -- 1066
			end -- 1066
			show( -- 1067
				handFrame[1], -- 1067
				ox - t, -- 1067
				oy - t, -- 1067
				fw + t * 2, -- 1067
				t -- 1067
			) -- 1067
			show( -- 1068
				handFrame[2], -- 1068
				ox - t, -- 1068
				oy + fh, -- 1068
				fw + t * 2, -- 1068
				t -- 1068
			) -- 1068
			show( -- 1069
				handFrame[3], -- 1069
				ox - t, -- 1069
				oy - t, -- 1069
				t, -- 1069
				fh + t * 2 -- 1069
			) -- 1069
			show( -- 1070
				handFrame[4], -- 1070
				ox + fw, -- 1070
				oy - t, -- 1070
				t, -- 1070
				fh + t * 2 -- 1070
			) -- 1070
		else -- 1070
			for ____, f in ipairs(handFrame) do -- 1072
				hide(f) -- 1072
			end -- 1072
		end -- 1072
		if held ~= nil and rotLockT > 0 and state == "play" and hi >= 0 then -- 1072
			local r = rotLockT / ROT_LOCK -- 1077
			show( -- 1078
				rotBar, -- 1078
				HAND_X + hi * (SLOT_W + SLOT_GAP), -- 1078
				SLOT_Y - 3, -- 1078
				math.floor(SLOT_W * r + 0.5), -- 1079
				2 -- 1079
			) -- 1079
			rotBar.opacity = 0.55 * r -- 1080
		else -- 1080
			hide(rotBar) -- 1082
		end -- 1082
	end -- 1017
	local function syncHud() -- 1086
		hudScore.text = tostring(math.floor(score + 0.5)) -- 1087
		hudProg.text = ((("已补 " .. tostring(filled)) .. " / ") .. tostring(GAPS_TO_WIN)) .. " 洞" -- 1088
		local r = math.min(1, filled / GAPS_TO_WIN) -- 1089
		if r > 0.001 then -- 1089
			show( -- 1090
				barFill, -- 1090
				340, -- 1090
				33, -- 1090
				math.floor(math.max(2, 540 * r) + 0.5), -- 1090
				7 -- 1090
			) -- 1090
		else -- 1090
			hide(barFill) -- 1090
		end -- 1090
	end -- 1086
	local function syncWall() -- 1094
		local off = scrollX - math.floor(scrollX / STRIP_W) * STRIP_W -- 1095
		walls[1].position = Vec2(off - STRIP_W, H - WALL_T) -- 1096
		walls[2].position = Vec2(off, H - WALL_T) -- 1097
	end -- 1094
	local function setFace(i, hold) -- 1100
		faceCur = i -- 1100
		faceHold = hold -- 1100
	end -- 1100
	local function faceIdx(k) -- 1101
		local i = __TS__ArrayIndexOf(FACE_LIST, k) -- 1102
		return i < 0 and 0 or i -- 1103
	end -- 1101
	local function syncScreens() -- 1107
		local startOn = state == "ready" -- 1108
		local endOn = state == "win" or state == "over" -- 1109
		local playOn = state == "play" -- 1110
		veil.visible = startOn or endOn -- 1112
		veil.opacity = endOn and 0.995 or (startOn and 1 or 0.985) -- 1113
		burst.visible = startOn or endOn -- 1114
		burst.opacity = startOn and 0.13 or (state == "win" and 0.21 or 0.1) -- 1115
		burst.position = Vec2(0, H - (startOn and -36 or -30)) -- 1116
		card.visible = endOn -- 1118
		sealHe.visible = endOn and state == "win" -- 1119
		sealPo.visible = endOn and state == "over" -- 1120
		endTitle.visible = endOn -- 1121
		endScore.visible = endOn -- 1122
		endStat.visible = endOn -- 1123
		endTip.visible = endOn -- 1124
		endRule.visible = endOn -- 1125
		endLabel.visible = endOn -- 1126
		endSepLine.visible = endOn -- 1127
		endSepRed.visible = endOn -- 1128
		stTitle.visible = startOn -- 1130
		stYi.visible = startOn -- 1131
		stSub.visible = startOn -- 1132
		stRule.visible = startOn -- 1133
		stLine1.visible = startOn -- 1134
		stLine2.visible = startOn -- 1135
		stSpace.visible = startOn -- 1136
		stWall.visible = startOn -- 1137
		stBeam.visible = startOn -- 1138
		stBeamTop.visible = startOn -- 1139
		stBeamLine.visible = startOn -- 1140
		stWz.visible = startOn -- 1141
		stFoot.visible = startOn -- 1142
		stSep.visible = startOn -- 1143
		stQian.visible = startOn -- 1144
		for ____, s in ipairs(gapCells) do -- 1147
			s.opacity = playOn and 1 or (endOn and 0 or 1) -- 1147
		end -- 1147
		for ____, s in ipairs(faces) do -- 1149
			s.opacity = s == faces[faceCur + 1] and not endOn and 1 or 0 -- 1149
		end -- 1149
		dlgBox.visible = playOn -- 1150
		dlgName.visible = playOn -- 1151
		dlgBar.visible = playOn -- 1152
		for ____, c in ipairs(dlgCorner) do -- 1153
			c.visible = playOn -- 1153
		end -- 1153
		if startOn then -- 1153
			placeBtn( -- 1156
				btn, -- 1156
				112, -- 1156
				612, -- 1156
				240, -- 1156
				60, -- 1156
				"start" -- 1156
			) -- 1156
			btn.text.text = "开　始" -- 1157
		elseif state == "win" then -- 1157
			placeBtn( -- 1159
				btn, -- 1159
				520, -- 1159
				550, -- 1159
				240, -- 1159
				56, -- 1159
				"next" -- 1159
			) -- 1159
			btn.text.text = "下一关" -- 1160
		elseif state == "over" then -- 1160
			placeBtn( -- 1162
				btn, -- 1162
				520, -- 1162
				550, -- 1162
				240, -- 1162
				56, -- 1162
				"again" -- 1162
			) -- 1162
			btn.text.text = "重　来" -- 1163
		else -- 1163
			hideBtn(btn) -- 1165
		end -- 1165
		if endOn then -- 1165
			local win = state == "win" -- 1169
			endTitle.text = win and "墙合上了" or "缺口滚过去了" -- 1170
			endTitle.color = win and C_INK or C_VERM -- 1171
			endScore.text = tostring(math.floor(score + 0.5)) -- 1172
			endStat.text = ((((("填了 " .. tostring(filled)) .. " 个缺口 · 漏掉 ") .. tostring(timeouts)) .. " 次 · 转了 ") .. tostring(rotCount)) .. " 次" -- 1173
			endTip.text = win and "这一段墙补完了，城还在。" or "漏掉一个缺口，墙就漏了。" -- 1175
		end -- 1175
	end -- 1107
	local hover = false -- 1181
	local press = false -- 1181
	btnOff = 0 -- 1181
	local hoverX = -1 -- 1182
	local hoverY = -1 -- 1182
	local function inBtn(x, y) -- 1184
		if not btn.body.visible then -- 1184
			return false -- 1185
		end -- 1185
		return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h -- 1186
	end -- 1184
	local function gapAt(px, py) -- 1189
		local best = nil -- 1190
		local bd = 1000000000 -- 1191
		for ____, g in ipairs(gaps) do -- 1192
			do -- 1192
				local gw = g.w * CELL -- 1193
				local gh = g.h * CELL -- 1193
				local r0 = WALL_T + g.r0 * CELL -- 1194
				local c = math.floor((px - g.x) / CELL) -- 1195
				local rr = math.floor((py - WALL_T) / CELL) -- 1196
				local inCell = false -- 1197
				for ____, cell in ipairs(g.cells) do -- 1198
					if cell[1] == c and cell[2] == rr then -- 1198
						inCell = true -- 1199
						break -- 1199
					end -- 1199
				end -- 1199
				local pad = 14 -- 1201
				local inBox = px >= g.x - pad and px <= g.x + gw + pad and py >= r0 - pad and py <= r0 + gh + pad -- 1202
				if not inCell and not inBox then -- 1202
					goto __continue257 -- 1204
				end -- 1204
				local cx = g.x + gw / 2 -- 1205
				local cy = r0 + gh / 2 -- 1205
				local d = (px - cx) * (px - cx) + (py - cy) * (py - cy) + (inCell and -1000000 or 0) -- 1206
				if d < bd then -- 1206
					bd = d -- 1207
					best = g -- 1207
				end -- 1207
			end -- 1207
			::__continue257:: -- 1207
		end -- 1207
		return best -- 1209
	end -- 1189
	local function rotateHeld() -- 1212
		if held == nil or rotLockT > 0 then -- 1212
			return -- 1213
		end -- 1213
		local vs = VARIANTS[held.shape] -- 1214
		if #vs <= 1 then -- 1214
			return -- 1215
		end -- 1215
		held.vi = (held.vi + 1) % #vs -- 1216
		rotLockT = ROT_LOCK -- 1217
		rotCount = rotCount + 1 -- 1218
	end -- 1212
	local function toggleHold(i, isRight) -- 1221
		if isRight then -- 1221
			held = hand[i + 1] -- 1223
			local vs = VARIANTS[held.shape] -- 1224
			if #vs > 1 and rotLockT <= 0 then -- 1224
				held.vi = (held.vi + 1) % #vs -- 1226
				rotLockT = ROT_LOCK -- 1227
				rotCount = rotCount + 1 -- 1227
			end -- 1227
		else -- 1227
			local ____temp_6 -- 1230
			if held == hand[i + 1] then -- 1230
				____temp_6 = nil -- 1230
			else -- 1230
				____temp_6 = hand[i + 1] -- 1230
			end -- 1230
			held = ____temp_6 -- 1230
		end -- 1230
	end -- 1221
	local function tryPlace(px, py) -- 1234
		local g = gapAt(px, py) -- 1235
		if g == nil or held == nil then -- 1235
			return -- 1236
		end -- 1236
		local v = VARIANTS[held.shape][held.vi + 1] -- 1237
		if v.ck == g.ck then -- 1237
			local f = math.max( -- 1239
				0, -- 1239
				math.min(1, 1 - g.x / W) -- 1239
			) -- 1239
			local mult = 1 + 0.1 * math.min(filled, 10) -- 1240
			score = score + math.floor((20 + 180 * f) * mult * 10 + 0.5) / 10 -- 1241
			filled = filled + 1 -- 1242
			speedBase = math.min( -- 1243
				V_CAP, -- 1243
				V0 * 1.12 ^ math.floor(filled / 3) -- 1243
			) -- 1243
			flashGap = { -- 1244
				x = g.x, -- 1245
				y = WALL_T + g.r0 * CELL, -- 1245
				w = g.w * CELL, -- 1246
				h = g.h * CELL, -- 1246
				t = 0.32, -- 1246
				ok = true -- 1246
			} -- 1246
			local gain = math.floor((20 + 180 * f) * mult + 0.5) -- 1248
			if #pops < POP_POOL then -- 1248
				pops[#pops + 1] = { -- 1250
					x = g.x + g.w * CELL / 2, -- 1251
					y = WALL_T + g.r0 * CELL - 12, -- 1252
					v = gain, -- 1253
					t = 0.7, -- 1253
					dur = 0.7 -- 1253
				} -- 1253
			end -- 1253
			gaps = __TS__ArrayFilter( -- 1256
				gaps, -- 1256
				function(____, x) return x ~= g end -- 1256
			) -- 1256
			local i = __TS__ArrayIndexOf(hand, held) -- 1257
			if i >= 0 then -- 1257
				refillCard(i) -- 1258
			end -- 1258
			held = nil -- 1259
			spawnTimer = SPAWN_DELAY -- 1260
			setFace( -- 1261
				faceIdx("laugh"), -- 1261
				0.9 -- 1261
			) -- 1261
			if filled >= GAPS_TO_WIN then -- 1261
				state = "win" -- 1262
			end -- 1262
		else -- 1262
			shakeT = 0.28 -- 1266
			shakeTarget = g.id -- 1266
			flashGap = { -- 1267
				x = g.x, -- 1268
				y = WALL_T + g.r0 * CELL, -- 1268
				w = g.w * CELL, -- 1269
				h = g.h * CELL, -- 1269
				t = 0.28, -- 1269
				ok = false -- 1269
			} -- 1269
			held = nil -- 1271
			setFace( -- 1272
				faceIdx("dot"), -- 1272
				0.7 -- 1272
			) -- 1272
		end -- 1272
	end -- 1234
	local function handleTap(x, y, isRight) -- 1276
		if state ~= "play" then -- 1276
			return -- 1277
		end -- 1277
		if showSet then -- 1277
			local inPanel = x >= PX and x <= PX + PANEL_W and y >= PY and y <= PY + PANEL_H -- 1281
			if inPanel then -- 1281
				do -- 1281
					local i = 0 -- 1283
					while i < 2 do -- 1283
						if y >= barY[i + 1] - 12 and y <= barY[i + 1] + 18 then -- 1283
							local k = math.max( -- 1285
								0, -- 1285
								math.min(1, (x - IX) / IW) -- 1285
							) -- 1285
							if i == 0 then -- 1285
								audio.bgm = k -- 1286
							else -- 1286
								audio.sfx = k -- 1286
							end -- 1286
							return -- 1287
						end -- 1287
						i = i + 1 -- 1283
					end -- 1283
				end -- 1283
				if y >= PY + 152 and y <= PY + 190 then -- 1283
					showSet = false -- 1291
					if onExit ~= nil then -- 1291
						onExit() -- 1294
					else -- 1294
						reset() -- 1294
					end -- 1294
					return -- 1295
				end -- 1295
				return -- 1297
			end -- 1297
			showSet = false -- 1299
			return -- 1300
		end -- 1300
		if x >= SET_X and x <= SET_X + SET_S and y >= SET_Y and y <= SET_Y + SET_S then -- 1300
			showSet = true -- 1305
			return -- 1306
		end -- 1306
		if y >= SLOT_Y - 30 and y <= SLOT_Y + SLOT_H + 30 then -- 1306
			do -- 1306
				local i = 0 -- 1309
				while i < #hand do -- 1309
					local sx = HAND_X + i * (SLOT_W + SLOT_GAP) -- 1310
					if x >= sx and x <= sx + SLOT_W and y >= SLOT_Y - 20 and y <= SLOT_Y + SLOT_H + 20 then -- 1310
						toggleHold(i, isRight) -- 1312
						return -- 1313
					end -- 1313
					i = i + 1 -- 1309
				end -- 1309
			end -- 1309
			return -- 1316
		end -- 1316
		if y >= WALL_T - 40 and y <= WALL_B + 40 then -- 1316
			tryPlace(x, y) -- 1318
		end -- 1318
	end -- 1276
	layer.keyboardEnabled = true -- 1322
	layer:onKeyDown(function(key) -- 1323
		if key == "Space" then -- 1323
			if state == "ready" or state == "win" or state == "over" then -- 1323
				reset() -- 1325
			elseif state == "play" then -- 1325
				held = nil -- 1326
			end -- 1326
			return -- 1327
		end -- 1327
		if state ~= "play" or showSet then -- 1327
			return -- 1329
		end -- 1329
		if key == "R" then -- 1329
			rotateHeld() -- 1331
		elseif key == "Escape" then -- 1331
			held = nil -- 1333
		end -- 1333
	end) -- 1323
	layer.touchEnabled = true -- 1337
	layer:onTapBegan(function(t) -- 1339
		local x = t.location.x -- 1340
		local y = H - t.location.y -- 1341
		if inBtn(x, y) then -- 1341
			press = true -- 1342
		end -- 1342
	end) -- 1339
	layer:onMouseMove(function(t) -- 1346
		hoverX = t.location.x -- 1347
		hoverY = H - t.location.y -- 1348
		hover = inBtn(hoverX, hoverY) -- 1349
	end) -- 1346
	layer:onTapEnded(function(t) -- 1352
		local x = t.location.x -- 1353
		local y = H - t.location.y -- 1354
		if press and inBtn(x, y) then -- 1354
			press = false -- 1356
			if btn.kind == "start" or btn.kind == "again" then -- 1356
				reset() -- 1358
			elseif btn.kind == "next" then -- 1358
				onClear() -- 1360
			end -- 1360
			return -- 1362
		end -- 1362
		press = false -- 1364
		handleTap(x, y, false) -- 1365
	end) -- 1352
	local function update(dt) -- 1369
		timeAll = timeAll + dt -- 1370
		if faceHold > 0 then -- 1370
			faceHold = faceHold - dt -- 1372
			if faceHold <= 0 then -- 1372
				faceCur = 0 -- 1373
			end -- 1373
		end -- 1373
		if #pops > 0 then -- 1373
			do -- 1373
				local i = #pops - 1 -- 1378
				while i >= 0 do -- 1378
					local ____pops_index_7, ____t_8 = pops[i + 1], "t" -- 1378
					____pops_index_7[____t_8] = ____pops_index_7[____t_8] - dt -- 1379
					if pops[i + 1].t <= 0 then -- 1379
						__TS__ArraySplice(pops, i, 1) -- 1380
					end -- 1380
					i = i - 1 -- 1378
				end -- 1378
			end -- 1378
		end -- 1378
		if shakeT > 0 then -- 1378
			shakeT = math.max(0, shakeT - dt) -- 1383
		end -- 1383
		if flashGap ~= nil then -- 1383
			flashGap.t = flashGap.t - dt -- 1385
			if flashGap.t <= 0 then -- 1385
				flashGap = nil -- 1386
			end -- 1386
		end -- 1386
		if state == "play" then -- 1386
			if debugHold and held == nil and #gaps > 0 then -- 1386
				for ____, c in ipairs(hand) do -- 1392
					if VARIANTS[c.shape][c.vi + 1].ck == gaps[1].ck then -- 1392
						held = c -- 1393
						break -- 1393
					end -- 1393
				end -- 1393
			end -- 1393
			rotLockT = math.max(0, rotLockT - dt) -- 1396
			local v = speedBase -- 1397
			scrollX = scrollX + v * dt -- 1398
			for ____, g in ipairs(gaps) do -- 1399
				g.x = g.x + v * dt -- 1399
				g.age = g.age + dt -- 1399
			end -- 1399
			local dead = {} -- 1401
			for ____, g in ipairs(gaps) do -- 1402
				if g.x > W then -- 1402
					dead[#dead + 1] = g -- 1402
				end -- 1402
			end -- 1402
			if #dead > 0 then -- 1402
				for ____, g in ipairs(dead) do -- 1404
					gaps = __TS__ArrayFilter( -- 1404
						gaps, -- 1404
						function(____, x) return x ~= g end -- 1404
					) -- 1404
				end -- 1404
				timeouts = timeouts + #dead -- 1405
				setFace( -- 1406
					faceIdx("dot"), -- 1406
					1 -- 1406
				) -- 1406
				state = "over" -- 1407
			end -- 1407
			if state == "play" and #gaps < MAX_GAPS then -- 1407
				spawnTimer = spawnTimer - dt -- 1411
				if spawnTimer <= 0 then -- 1411
					spawnTimer = spawnGap() and SPAWN_DELAY or 0.25 -- 1413
				end -- 1413
			end -- 1413
		end -- 1413
		syncWall() -- 1418
		syncGaps() -- 1419
		syncHand() -- 1420
		syncHud() -- 1421
		syncScreens() -- 1422
		syncSet() -- 1423
		syncPops() -- 1424
		syncBtn(btn, hover, press, dt) -- 1425
		syncReady(dt) -- 1426
		do -- 1426
			local i = 0 -- 1429
			while i < #faces do -- 1429
				faces[i + 1].opacity = i == faceCur and not (state == "win" or state == "over") and 1 or 0 -- 1430
				i = i + 1 -- 1429
			end -- 1429
		end -- 1429
	end -- 1369
	local function destroy() -- 1434
		layer:removeFromParent() -- 1434
	end -- 1434
	local cleared = false -- 1437
	local function skip() -- 1438
		if cleared then -- 1438
			return -- 1439
		end -- 1439
		cleared = true -- 1440
		onClear() -- 1441
	end -- 1438
	return { -- 1444
		update = function(dt) -- 1445
			update(dt) -- 1445
		end, -- 1445
		destroy = function() -- 1446
			destroy() -- 1446
		end, -- 1446
		isDone = function() return state == "win" or state == "over" end, -- 1447
		state = function() return state end, -- 1448
		skip = function() -- 1449
			skip() -- 1449
		end -- 1449
	} -- 1449
end -- 136
return ____exports -- 136