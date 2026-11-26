-- [ts]: Dialogue.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstr = ____lualib.__TS__StringSubstr -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 13
local Label = ____Dora.Label -- 14
local Node = ____Dora.Node -- 15
local Size = ____Dora.Size -- 16
local Sprite = ____Dora.Sprite -- 17
local Vec2 = ____Dora.Vec2 -- 19
local ____Story = require("Script.Story") -- 21
local LEVEL1_SPOTS = ____Story.LEVEL1_SPOTS -- 21
local W = 1280 -- 23
local H = 804 -- 24
local REG = "Font/SourceHanSerifSC-Regular.ttf" -- 25
local BOLD = "Font/SourceHanSerifSC-SemiBold.ttf" -- 26
local MED = "Font/SourceHanSerifSC-SemiBold.ttf" -- 27
local C_PAPER = Color(233, 223, 196, 255) -- 29
local C_CARD = Color(252, 247, 232, 255) -- 30
local C_INK = Color(36, 73, 70, 255) -- 31
local C_MUTE = Color(76, 99, 87, 255) -- 32
local C_VERM = Color(163, 59, 42, 255) -- 33
local C_TAG = Color(142, 46, 31, 255) -- 34
local C_TAG_EDGE = Color(163, 59, 42, 140) -- 35
local C_TAG_SHADOW = Color(36, 73, 70, 85) -- 36
local SCENE = {x = 120, y = 104, w = 1040, h = 330} -- 39
local SAY = {x = 120, y = 506, w = 744, h = 172} -- 41
local PAD = 34 -- 42
local FACE_LIST = { -- 45
	"smile", -- 46
	"laugh", -- 46
	"dot", -- 46
	"wave", -- 46
	"curvy", -- 46
	"shy", -- 46
	"shyact", -- 46
	"dizzy" -- 46
} -- 46
local FACE_W = 250 -- 49
local FACE_H = 344 -- 50
local WZ_X = W - 14 - FACE_W -- 51
local WZ_Y = 18 -- 52
local CPS = 0.032 -- 55
local CH_BYTES = 3 -- 56
local FADE_IN_PAGE = 0.55 -- 57
local FADE_IN_LINE = 0.2 -- 58
local FADE_OUT_LINE = 0.14 -- 59
local FADE_OUT_ALL = 0.3 -- 60
function ____exports.createDialogue(root, opts) -- 87
	local layer = Node() -- 88
	layer.anchor = Vec2(0, 0) -- 89
	layer.size = Size(W, H) -- 90
	layer.position = Vec2(0, 0) -- 91
	layer.opacity = 0 -- 92
	layer:addTo(root) -- 93
	local function block(parent, x, y, w, h, c, alpha) -- 96
		if alpha == nil then -- 96
			alpha = 1 -- 98
		end -- 98
		local s = Sprite("Image/StartUI/white.png") -- 100
		s.anchor = Vec2(0.5, 0.5) -- 101
		s.size = Size( -- 102
			math.abs(w), -- 102
			math.abs(h) -- 102
		) -- 102
		s.color = c -- 103
		s.opacity = alpha -- 105
		s.position = Vec2(x + w / 2, H - (y + h / 2)) -- 106
		s:addTo(parent) -- 107
		return s -- 108
	end -- 96
	local SS = 2 -- 114
	local CHAR_ADV = 0.72 -- 119
	local function text(parent, font, size, color, x, y, width, gap, outline) -- 122
		local lb = Label(((font .. ";") .. tostring(math.floor(size * SS + 0.5))) .. ";true") -- 126
		lb.color = color -- 127
		if outline > 0 then -- 127
			lb.outlineColor = color -- 129
			lb.outlineWidth = outline -- 130
		end -- 130
		if width > 0 then -- 130
			lb.textWidth = width * SS -- 133
			lb.lineGap = gap * SS -- 134
			lb.alignment = "Left" -- 135
		end -- 135
		lb.anchor = Vec2(0, 1) -- 137
		lb.scaleX = 1 / SS -- 138
		lb.scaleY = 1 / SS -- 139
		lb.position = Vec2(x, H - y) -- 140
		lb:addTo(parent) -- 141
		return lb -- 142
	end -- 122
	local function textC(parent, font, size, color, x, y, width) -- 146
		local lb = Label(((font .. ";") .. tostring(math.floor(size * SS + 0.5))) .. ";true") -- 150
		lb.color = color -- 151
		lb.textWidth = width * SS -- 152
		lb.alignment = "Center" -- 153
		lb.anchor = Vec2(0, 1) -- 154
		lb.scaleX = 1 / SS -- 155
		lb.scaleY = 1 / SS -- 156
		lb.position = Vec2(x, H - y) -- 157
		lb:addTo(parent) -- 158
		return lb -- 159
	end -- 146
	local function paperTag(parent, x, y, w, h) -- 163
		block( -- 166
			parent, -- 166
			x + 3, -- 166
			y + 3, -- 166
			w, -- 166
			h, -- 166
			C_INK, -- 166
			0.33 -- 166
		) -- 166
		block( -- 167
			parent, -- 167
			x - 2, -- 167
			y - 2, -- 167
			w + 4, -- 167
			h + 4, -- 167
			C_VERM, -- 167
			0.55 -- 167
		) -- 167
		block( -- 168
			parent, -- 168
			x, -- 168
			y, -- 168
			w, -- 168
			h, -- 168
			C_CARD -- 168
		) -- 168
	end -- 163
	block( -- 172
		layer, -- 172
		0, -- 172
		0, -- 172
		W, -- 172
		H, -- 172
		C_PAPER -- 172
	) -- 172
	local grain = Sprite("Image/StartUI/paper_grain.png") -- 173
	grain.anchor = Vec2(0, 1) -- 174
	grain.size = Size(W, H) -- 175
	grain.position = Vec2(0, H) -- 176
	grain:addTo(layer) -- 177
	local headGroup = Node() -- 182
	headGroup.size = Size(W, H) -- 183
	headGroup.anchor = Vec2(0, 0) -- 184
	headGroup.position = Vec2(0, 0) -- 185
	headGroup.opacity = 0 -- 186
	headGroup:addTo(layer) -- 187
	block( -- 190
		headGroup, -- 190
		56, -- 190
		44, -- 190
		W - 112, -- 190
		1.5, -- 190
		C_INK, -- 190
		0.59 -- 190
	) -- 190
	if opts.headerImg ~= nil then -- 190
		local hd = Sprite(opts.headerImg) -- 192
		hd.anchor = Vec2(0, 1) -- 193
		hd.size = Size(200, 22) -- 194
		hd.position = Vec2(56, H - 50) -- 196
		hd:addTo(headGroup) -- 197
	else -- 197
		local hdL = text( -- 199
			headGroup, -- 199
			REG, -- 199
			18, -- 199
			C_MUTE, -- 199
			56, -- 199
			52, -- 199
			700, -- 199
			0, -- 199
			0.04 -- 199
		) -- 199
		hdL.text = opts.header -- 200
		hdL.spacing = 2 -- 201
	end -- 201
	local sceneGroup = Node() -- 207
	sceneGroup.size = Size(W, H) -- 208
	sceneGroup.anchor = Vec2(0, 0) -- 209
	sceneGroup.position = Vec2(0, 0) -- 210
	sceneGroup.opacity = 0 -- 211
	sceneGroup:addTo(layer) -- 212
	block( -- 215
		sceneGroup, -- 215
		SCENE.x + 9, -- 215
		SCENE.y + 9, -- 215
		SCENE.w, -- 215
		SCENE.h, -- 215
		C_INK, -- 215
		0.9 -- 215
	) -- 215
	local scene = Sprite(opts.scene) -- 216
	scene.anchor = Vec2(0, 1) -- 217
	scene.size = Size(SCENE.w, SCENE.h) -- 218
	scene.position = Vec2(SCENE.x, H - SCENE.y) -- 219
	scene:addTo(sceneGroup) -- 220
	block( -- 223
		sceneGroup, -- 223
		SCENE.x - 3, -- 223
		SCENE.y - 3, -- 223
		SCENE.w + 6, -- 223
		3, -- 223
		C_INK -- 223
	) -- 223
	block( -- 224
		sceneGroup, -- 224
		SCENE.x - 3, -- 224
		SCENE.y + SCENE.h, -- 224
		SCENE.w + 6, -- 224
		3, -- 224
		C_INK -- 224
	) -- 224
	block( -- 225
		sceneGroup, -- 225
		SCENE.x - 3, -- 225
		SCENE.y - 3, -- 225
		3, -- 225
		SCENE.h + 6, -- 225
		C_INK -- 225
	) -- 225
	block( -- 226
		sceneGroup, -- 226
		SCENE.x + SCENE.w, -- 226
		SCENE.y - 3, -- 226
		3, -- 226
		SCENE.h + 6, -- 226
		C_INK -- 226
	) -- 226
	local CORNER = 16 -- 229
	block( -- 230
		sceneGroup, -- 230
		SCENE.x + 6, -- 230
		SCENE.y + 6, -- 230
		CORNER, -- 230
		1.5, -- 230
		C_INK, -- 230
		0.47 -- 230
	) -- 230
	block( -- 231
		sceneGroup, -- 231
		SCENE.x + 6, -- 231
		SCENE.y + 6, -- 231
		1.5, -- 231
		CORNER, -- 231
		C_INK, -- 231
		0.47 -- 231
	) -- 231
	block( -- 232
		sceneGroup, -- 232
		SCENE.x + SCENE.w - 6 - CORNER, -- 232
		SCENE.y + 6, -- 232
		CORNER, -- 232
		1.5, -- 232
		C_INK, -- 232
		0.47 -- 232
	) -- 232
	block( -- 233
		sceneGroup, -- 233
		SCENE.x + SCENE.w - 7.5, -- 233
		SCENE.y + 6, -- 233
		1.5, -- 233
		CORNER, -- 233
		C_INK, -- 233
		0.47 -- 233
	) -- 233
	block( -- 234
		sceneGroup, -- 234
		SCENE.x + 6, -- 234
		SCENE.y + SCENE.h - 7.5, -- 234
		CORNER, -- 234
		1.5, -- 234
		C_INK, -- 234
		0.47 -- 234
	) -- 234
	block( -- 235
		sceneGroup, -- 235
		SCENE.x + 6, -- 235
		SCENE.y + SCENE.h - 6 - CORNER, -- 235
		1.5, -- 235
		CORNER, -- 235
		C_INK, -- 235
		0.47 -- 235
	) -- 235
	block( -- 236
		sceneGroup, -- 236
		SCENE.x + SCENE.w - 6 - CORNER, -- 236
		SCENE.y + SCENE.h - 7.5, -- 236
		CORNER, -- 236
		1.5, -- 236
		C_INK, -- 236
		0.47 -- 236
	) -- 236
	block( -- 237
		sceneGroup, -- 237
		SCENE.x + SCENE.w - 7.5, -- 237
		SCENE.y + SCENE.h - 6 - CORNER, -- 237
		1.5, -- 237
		CORNER, -- 237
		C_INK, -- 237
		0.47 -- 237
	) -- 237
	local TAGW = 70 -- 242
	local TAGH = 32 -- 243
	block( -- 244
		sceneGroup, -- 244
		SCENE.x - 3, -- 244
		SCENE.y - 3, -- 244
		TAGW + 2.5, -- 244
		TAGH + 2.5, -- 244
		C_INK -- 244
	) -- 244
	local tagImg = Sprite("Image/StartUI/tag_tu1.png") -- 245
	tagImg.anchor = Vec2(0, 1) -- 246
	tagImg.size = Size(TAGW, TAGH) -- 247
	tagImg.position = Vec2(SCENE.x - 3, H - (SCENE.y - 3)) -- 248
	tagImg:addTo(sceneGroup) -- 249
	local cardNodes = {} -- 252
	local spotDots = {} -- 253
	local openIdx = -1 -- 254
	local cardAnim = 0 -- 255
	local function toggleCard() -- 256
	end -- 256
	local useSpots = opts.spots ~= false -- 258
	local spots = opts.spotData ~= nil and opts.spotData or LEVEL1_SPOTS -- 259
	if useSpots then -- 259
		__TS__ArrayForEach( -- 260
			spots, -- 260
			function(____, sp, i) -- 260
				local bx = sp.x - 15 -- 261
				local by = sp.y - 15 -- 262
				block( -- 263
					sceneGroup, -- 263
					bx, -- 263
					by, -- 263
					30, -- 263
					1.5, -- 263
					C_VERM -- 263
				) -- 263
				block( -- 264
					sceneGroup, -- 264
					bx, -- 264
					by + 28.5, -- 264
					30, -- 264
					1.5, -- 264
					C_VERM -- 264
				) -- 264
				block( -- 265
					sceneGroup, -- 265
					bx, -- 265
					by, -- 265
					1.5, -- 265
					30, -- 265
					C_VERM -- 265
				) -- 265
				block( -- 266
					sceneGroup, -- 266
					bx + 28.5, -- 266
					by, -- 266
					1.5, -- 266
					30, -- 266
					C_VERM -- 266
				) -- 266
				local dot = block( -- 267
					sceneGroup, -- 267
					sp.x - 4.5, -- 267
					sp.y - 4.5, -- 267
					9, -- 267
					9, -- 267
					C_VERM -- 267
				) -- 267
				spotDots[#spotDots + 1] = dot -- 268
				local card = Node() -- 271
				card.size = Size(W, H) -- 272
				card.anchor = Vec2(0, 0) -- 273
				card.position = Vec2(0, 0) -- 274
				card:addTo(sceneGroup) -- 276
				card.visible = false -- 277
				local cardBg = Sprite("Image/StartUI/card_info.png") -- 278
				cardBg.anchor = Vec2(0, 1) -- 279
				cardBg.size = Size(329, 159) -- 280
				cardBg.position = Vec2(sp.cx - 1.25, H - (sp.cy - 1.25)) -- 281
				cardBg:addTo(card) -- 282
				local ct = text( -- 283
					card, -- 283
					BOLD, -- 283
					22, -- 283
					C_INK, -- 283
					sp.cx + 22, -- 283
					sp.cy + 20, -- 283
					280, -- 283
					0, -- 283
					0 -- 283
				) -- 283
				ct.text = sp.t -- 284
				local cn = text( -- 285
					card, -- 285
					BOLD, -- 285
					20, -- 285
					C_VERM, -- 285
					sp.cx + 22, -- 285
					sp.cy + 54, -- 285
					280, -- 285
					0, -- 285
					0 -- 285
				) -- 285
				cn.text = sp.n -- 286
				local cd = text( -- 287
					card, -- 287
					MED, -- 287
					17, -- 287
					C_MUTE, -- 287
					sp.cx + 22, -- 287
					sp.cy + 84, -- 287
					276 * CHAR_ADV, -- 287
					9, -- 287
					0 -- 287
				) -- 287
				cd.text = sp.d -- 288
				cardNodes[#cardNodes + 1] = card -- 289
			end -- 260
		) -- 260
	end -- 260
	toggleCard = function(i) -- 292
		openIdx = openIdx == i and -1 or i -- 293
		cardAnim = 0 -- 294
		__TS__ArrayForEach( -- 295
			cardNodes, -- 295
			function(____, c, k) -- 295
				c.visible = k == openIdx -- 296
				if k == openIdx then -- 296
					c.opacity = 0 -- 298
					c.position = Vec2(0, -10) -- 299
				end -- 299
			end -- 295
		) -- 295
	end -- 292
	local ripples = {} -- 306
	local function ripple(x, y, strong) -- 308
		local s = Sprite("Image/StartUI/tap_ring.png") -- 309
		s.anchor = Vec2(0.5, 0.5) -- 310
		s.size = Size(26, 26) -- 311
		s.position = Vec2(x, y) -- 312
		s:addTo(layer) -- 313
		ripples[#ripples + 1] = { -- 314
			s = s, -- 315
			t = 0, -- 315
			dur = strong and 0.44 or 0.36, -- 316
			d0 = 26, -- 317
			d1 = strong and 118 or 86 -- 317
		} -- 317
	end -- 308
	local function tapAt(x, y) -- 323
		if not useSpots then -- 323
			return false -- 324
		end -- 324
		do -- 324
			local i = 0 -- 325
			while i < #spots do -- 325
				local sp = spots[i + 1] -- 326
				if math.abs(x - sp.x) < 24 and math.abs(y - (H - sp.y)) < 24 then -- 326
					ripple(x, y, true) -- 328
					toggleCard(i) -- 329
					return true -- 330
				end -- 330
				i = i + 1 -- 325
			end -- 325
		end -- 325
		ripple(x, y, false) -- 333
		if openIdx >= 0 then -- 333
			toggleCard(openIdx) -- 335
			return true -- 336
		end -- 336
		return false -- 338
	end -- 323
	local fxNodes = {} -- 344
	local wantFx = opts.fxGroups ~= nil and opts.fxGroups or ({"ruler", "height", "seal"}) -- 345
	local function hasFx(k) -- 348
		return __TS__ArrayIndexOf(wantFx, k) >= 0 -- 348
	end -- 348
	local function tagOf(k, d) -- 349
		if opts.tags == nil then -- 349
			return d -- 350
		end -- 350
		local ____temp_3 -- 351
		if k == "ruler" then -- 351
			____temp_3 = opts.tags.ruler -- 351
		else -- 351
			local ____temp_2 -- 352
			if k == "height" then -- 352
				____temp_2 = opts.tags.height -- 352
			else -- 352
				local ____temp_1 -- 353
				if k == "gap" then -- 353
					____temp_1 = opts.tags.gap -- 353
				else -- 353
					local ____temp_0 -- 354
					if k == "crown" then -- 354
						____temp_0 = opts.tags.crown -- 354
					else -- 354
						____temp_0 = nil -- 354
					end -- 354
					____temp_1 = ____temp_0 -- 354
				end -- 354
				____temp_2 = ____temp_1 -- 353
			end -- 353
			____temp_3 = ____temp_2 -- 352
		end -- 352
		local v = ____temp_3 -- 351
		return v ~= nil and v or d -- 355
	end -- 349
	local function fxLayer() -- 358
		local n = Node() -- 359
		n.size = Size(W, H) -- 360
		n.anchor = Vec2(0, 0) -- 361
		n.position = Vec2(0, 0) -- 362
		n.opacity = 0 -- 363
		n:addTo(layer) -- 364
		n.visible = false -- 365
		return n -- 366
	end -- 358
	local function ring(parent, x, y, w, h, t) -- 370
		block( -- 373
			parent, -- 373
			x - 3, -- 373
			y - 3, -- 373
			w + 6, -- 373
			h + 6, -- 373
			C_CARD, -- 373
			0.5 -- 373
		) -- 373
		block( -- 374
			parent, -- 374
			x, -- 374
			y, -- 374
			w, -- 374
			t, -- 374
			C_VERM -- 374
		) -- 374
		block( -- 375
			parent, -- 375
			x, -- 375
			y + h - t, -- 375
			w, -- 375
			t, -- 375
			C_VERM -- 375
		) -- 375
		block( -- 376
			parent, -- 376
			x, -- 376
			y, -- 376
			t, -- 376
			h, -- 376
			C_VERM -- 376
		) -- 376
		block( -- 377
			parent, -- 377
			x + w - t, -- 377
			y, -- 377
			t, -- 377
			h, -- 377
			C_VERM -- 377
		) -- 377
	end -- 370
	local function mkTag(parent, x, y, w, txt) -- 380
		paperTag( -- 383
			parent, -- 383
			x, -- 383
			y, -- 383
			w, -- 383
			40 -- 383
		) -- 383
		local lb = textC( -- 384
			parent, -- 384
			BOLD, -- 384
			22, -- 384
			C_TAG, -- 384
			x, -- 384
			y + 7, -- 384
			w -- 384
		) -- 384
		lb.text = txt -- 385
	end -- 380
	local rulerLine = nil -- 388
	local fxRuler = nil -- 389
	if hasFx("ruler") then -- 389
		fxRuler = fxLayer() -- 393
		local RULER_Y = SCENE.y + 218 -- 394
		local RULER_X0 = SCENE.x + 60 -- 395
		local line = Sprite("Image/StartUI/white.png") -- 396
		line.anchor = Vec2(0, 0.5) -- 397
		line.color = C_VERM -- 398
		line.size = Size(920, 3) -- 399
		line.position = Vec2(RULER_X0, H - RULER_Y) -- 400
		line:addTo(fxRuler) -- 401
		rulerLine = line -- 402
		block( -- 403
			fxRuler, -- 403
			SCENE.x + 58, -- 403
			SCENE.y + 203, -- 403
			3, -- 403
			30, -- 403
			C_VERM -- 403
		) -- 403
		block( -- 404
			fxRuler, -- 404
			SCENE.x + 978, -- 404
			SCENE.y + 203, -- 404
			3, -- 404
			30, -- 404
			C_VERM -- 404
		) -- 404
		mkTag( -- 405
			fxRuler, -- 405
			SCENE.x + 340, -- 405
			SCENE.y + 228, -- 405
			360, -- 405
			tagOf("ruler", "一圈 2688 米　走完约半小时") -- 406
		) -- 406
		fxNodes[#fxNodes + 1] = {name = "ruler", node = fxRuler} -- 407
	end -- 407
	if hasFx("height") then -- 407
		local node = fxLayer() -- 412
		block( -- 413
			node, -- 413
			SCENE.x + 56, -- 413
			SCENE.y + 96, -- 413
			3, -- 413
			200, -- 413
			C_VERM -- 413
		) -- 413
		block( -- 414
			node, -- 414
			SCENE.x + 34, -- 414
			SCENE.y + 95, -- 414
			44, -- 414
			3, -- 414
			C_VERM -- 414
		) -- 414
		block( -- 415
			node, -- 415
			SCENE.x + 34, -- 415
			SCENE.y + 295, -- 415
			44, -- 415
			3, -- 415
			C_VERM -- 415
		) -- 415
		mkTag( -- 416
			node, -- 416
			SCENE.x + 86, -- 416
			SCENE.y + 190, -- 416
			215, -- 416
			tagOf("height", "高 8 米") -- 417
		) -- 417
		fxNodes[#fxNodes + 1] = {name = "height", node = node} -- 418
	end -- 418
	if hasFx("seal") then -- 418
		local node = fxLayer() -- 423
		local SEAL = {x = SCENE.x + 828, y = SCENE.y + 168} -- 424
		block( -- 425
			node, -- 425
			SEAL.x, -- 425
			SEAL.y, -- 425
			78, -- 425
			78, -- 425
			C_VERM -- 425
		) -- 425
		block( -- 426
			node, -- 426
			SEAL.x + 4, -- 426
			SEAL.y + 4, -- 426
			70, -- 426
			70, -- 426
			C_CARD -- 426
		) -- 426
		local a = text( -- 427
			node, -- 427
			BOLD, -- 427
			24, -- 427
			C_VERM, -- 427
			SEAL.x + 24, -- 427
			SEAL.y + 14, -- 427
			0, -- 427
			0, -- 427
			0.05 -- 427
		) -- 427
		a.text = "民" -- 428
		local b = text( -- 429
			node, -- 429
			BOLD, -- 429
			24, -- 429
			C_VERM, -- 429
			SEAL.x + 24, -- 429
			SEAL.y + 42, -- 429
			0, -- 429
			0, -- 429
			0.05 -- 429
		) -- 429
		b.text = "修" -- 430
		fxNodes[#fxNodes + 1] = {name = "seal", node = node} -- 431
	end -- 431
	if hasFx("mill") then -- 431
		local node = fxLayer() -- 436
		ring( -- 437
			node, -- 437
			SCENE.x + 104, -- 437
			SCENE.y + 178, -- 437
			240, -- 437
			148, -- 437
			3 -- 437
		) -- 437
		mkTag( -- 438
			node, -- 438
			SCENE.x + 356, -- 438
			SCENE.y + 212, -- 438
			200, -- 438
			tagOf("mill", "碾子 · 龙字加石") -- 438
		) -- 438
		fxNodes[#fxNodes + 1] = {name = "mill", node = node} -- 439
	end -- 439
	if hasFx("siege") then -- 439
		local node = fxLayer() -- 444
		ring( -- 445
			node, -- 445
			SCENE.x + 846, -- 445
			SCENE.y + 6, -- 445
			150, -- 445
			106, -- 445
			3 -- 445
		) -- 445
		mkTag( -- 446
			node, -- 446
			SCENE.x + 588, -- 446
			SCENE.y + 30, -- 446
			210, -- 446
			tagOf("siege", "城外扎营　围了半年") -- 446
		) -- 446
		fxNodes[#fxNodes + 1] = {name = "siege", node = node} -- 447
	end -- 447
	if hasFx("bin") then -- 447
		local node = fxLayer() -- 452
		ring( -- 453
			node, -- 453
			SCENE.x + 788, -- 453
			SCENE.y + 198, -- 453
			200, -- 453
			118, -- 453
			3 -- 453
		) -- 453
		mkTag( -- 454
			node, -- 454
			SCENE.x + 700, -- 454
			SCENE.y + 164, -- 454
			130, -- 454
			tagOf("bin", "粮囤见底") -- 454
		) -- 454
		fxNodes[#fxNodes + 1] = {name = "bin", node = node} -- 455
	end -- 455
	if hasFx("bran") then -- 455
		local node = fxLayer() -- 460
		ring( -- 461
			node, -- 461
			SCENE.x + 382, -- 461
			SCENE.y + 256, -- 461
			344, -- 461
			74, -- 461
			3 -- 461
		) -- 461
		mkTag( -- 462
			node, -- 462
			SCENE.x + 396, -- 462
			SCENE.y + 200, -- 462
			165, -- 462
			tagOf("bran", "糠撒在晒场上") -- 462
		) -- 462
		fxNodes[#fxNodes + 1] = {name = "bran", node = node} -- 463
	end -- 463
	if hasFx("gap") then -- 463
		local node = fxLayer() -- 468
		ring( -- 469
			node, -- 469
			SCENE.x + 338, -- 469
			SCENE.y + 94, -- 469
			396, -- 469
			206, -- 469
			3 -- 469
		) -- 469
		mkTag( -- 470
			node, -- 470
			SCENE.x + 750, -- 470
			SCENE.y + 150, -- 470
			168, -- 470
			tagOf("gap", "一个洞都不行") -- 471
		) -- 471
		fxNodes[#fxNodes + 1] = {name = "gap", node = node} -- 472
	end -- 472
	if hasFx("crown") then -- 472
		local node = fxLayer() -- 477
		ring( -- 478
			node, -- 478
			SCENE.x + 150, -- 478
			SCENE.y + 92, -- 478
			190, -- 478
			52, -- 478
			3 -- 478
		) -- 478
		mkTag( -- 479
			node, -- 479
			SCENE.x + 356, -- 479
			SCENE.y + 100, -- 479
			150, -- 479
			tagOf("crown", "垛口 905 个") -- 480
		) -- 480
		fxNodes[#fxNodes + 1] = {name = "crown", node = node} -- 481
	end -- 481
	local capLb = text( -- 485
		sceneGroup, -- 485
		MED, -- 485
		20, -- 485
		Color(76, 99, 87, 215), -- 485
		302, -- 485
		442, -- 485
		230, -- 485
		0, -- 485
		0 -- 485
	) -- 485
	capLb.alignment = "Right" -- 486
	capLb.position = Vec2(W - 516, H - 442) -- 487
	capLb.text = opts.caption ~= nil and opts.caption or "永昌堡 · 东段城墙（示意）" -- 488
	local faceGroup = Node() -- 493
	faceGroup.size = Size(W, H) -- 494
	faceGroup.anchor = Vec2(0, 0) -- 495
	faceGroup.position = Vec2(0, 0) -- 496
	faceGroup.opacity = 0 -- 497
	faceGroup:addTo(layer) -- 498
	local faceSprites = {} -- 500
	do -- 500
		local i = 0 -- 501
		while i < #FACE_LIST do -- 501
			local sp = Sprite(("Image/StartUI/face_" .. FACE_LIST[i + 1]) .. ".png") -- 502
			sp.anchor = Vec2(0.5, 0) -- 503
			sp.size = Size(FACE_W, FACE_H) -- 504
			sp.position = Vec2(WZ_X + FACE_W / 2, WZ_Y) -- 505
			sp.opacity = i == 0 and 1 or 0 -- 506
			sp:addTo(faceGroup) -- 507
			faceSprites[#faceSprites + 1] = sp -- 508
			i = i + 1 -- 501
		end -- 501
	end -- 501
	local faceCur = 0 -- 510
	local introT = 0 -- 511
	local function setFace(name) -- 513
		if name == nil then -- 513
			return -- 514
		end -- 514
		local k = __TS__ArrayIndexOf(FACE_LIST, name) -- 515
		if k >= 0 then -- 515
			faceCur = k -- 516
		end -- 516
	end -- 513
	local sayGroup = Node() -- 520
	sayGroup.size = Size(W, H) -- 521
	sayGroup.anchor = Vec2(0, 0) -- 522
	sayGroup.position = Vec2(0, 0) -- 523
	sayGroup.opacity = 0 -- 524
	sayGroup:addTo(layer) -- 525
	local SAY_H = opts.sayTall == true and 196 or 172 -- 527
	local sayCard = Sprite(opts.sayTall == true and "Image/StartUI/card_say_tall.png" or "Image/StartUI/card_say.png") -- 528
	sayCard.anchor = Vec2(0, 1) -- 531
	sayCard.size = Size(754, SAY_H + 10) -- 532
	sayCard.position = Vec2(SAY.x - 1.25, H - (SAY.y - 1.25)) -- 533
	sayCard:addTo(sayGroup) -- 534
	local pill = Sprite("Image/StartUI/pill_name.png") -- 537
	pill.anchor = Vec2(0, 1) -- 538
	pill.size = Size(102, 40) -- 539
	pill.position = Vec2(SAY.x + 16, H - (SAY.y - 21)) -- 540
	pill:addTo(sayGroup) -- 541
	local whoLb = Label(((MED .. ";") .. tostring(math.floor(15 * SS + 0.5))) .. ";true") -- 545
	whoLb.color = C_CARD -- 546
	whoLb.anchor = Vec2(0.5, 0.5) -- 547
	whoLb.scaleX = 1 / SS -- 548
	whoLb.scaleY = 1 / SS -- 549
	whoLb.position = Vec2(SAY.x + 74, H - (SAY.y + 1)) -- 550
	whoLb.spacing = 7 * SS -- 551
	whoLb.text = opts.speaker -- 552
	whoLb:addTo(sayGroup) -- 553
	local TX_SIZE = 32 -- 560
	local TX_STEP = TX_SIZE * 0.78 + 1 -- 560
	local TX_LINE = TX_SIZE + 14 -- 560
	local TX_COLS = math.floor((SAY.w - PAD * 2) / TX_STEP) -- 561
	local TX_N = TX_COLS * 3 -- 562
	local txChars = {} -- 563
	do -- 563
		local i = 0 -- 564
		while i < TX_N do -- 564
			local lb = Label(((REG .. ";") .. tostring(math.floor(TX_SIZE * SS + 0.5))) .. ";true") -- 565
			lb.color = C_INK -- 566
			lb.anchor = Vec2(0, 1) -- 567
			lb.scaleX = 1 / SS -- 568
			lb.scaleY = 1 / SS -- 569
			lb.visible = false -- 570
			lb:addTo(sayGroup) -- 571
			txChars[#txChars + 1] = lb -- 572
			i = i + 1 -- 564
		end -- 564
	end -- 564
	local txCount = 0 -- 574
	local function toChars(str) -- 577
		local out = {} -- 578
		local i = 0 -- 579
		while i < #str do -- 579
			local c = __TS__StringCharCodeAt(str, i) -- 581
			local n = 1 -- 582
			if c >= 240 then -- 582
				n = 4 -- 583
			elseif c >= 224 then -- 583
				n = 3 -- 584
			elseif c >= 192 then -- 584
				n = 2 -- 585
			end -- 585
			out[#out + 1] = __TS__StringSubstr(str, i, n) -- 586
			i = i + n -- 587
		end -- 587
		return out -- 589
	end -- 577
	local function layoutLine(str) -- 593
		local chars = toChars(str) -- 594
		txCount = math.min(TX_N, #chars) -- 595
		do -- 595
			local i = 0 -- 596
			while i < TX_N do -- 596
				do -- 596
					local lb = txChars[i + 1] -- 597
					if i >= txCount then -- 597
						lb.visible = false -- 598
						goto __continue53 -- 598
					end -- 598
					local col = i % TX_COLS -- 599
					local row = math.floor(i / TX_COLS) -- 600
					lb.text = chars[i + 1] -- 601
					lb.position = Vec2(SAY.x + PAD + col * TX_STEP, H - (SAY.y + 56 + row * TX_LINE)) -- 602
					lb.visible = false -- 603
				end -- 603
				::__continue53:: -- 603
				i = i + 1 -- 596
			end -- 596
		end -- 596
	end -- 593
	local function showChars(n) -- 607
		do -- 607
			local i = 0 -- 608
			while i < txCount do -- 608
				txChars[i + 1].visible = i < n -- 608
				i = i + 1 -- 608
			end -- 608
		end -- 608
	end -- 607
	local function setTxOpacity(a) -- 610
		do -- 610
			local i = 0 -- 611
			while i < txCount do -- 611
				txChars[i + 1].opacity = a -- 611
				i = i + 1 -- 611
			end -- 611
		end -- 611
	end -- 610
	local seqLb = Label(((REG .. ";") .. tostring(math.floor(15 * SS + 0.5))) .. ";true") -- 614
	seqLb.color = Color(76, 99, 87, 190) -- 615
	seqLb.outlineColor = Color(76, 99, 87, 190) -- 616
	seqLb.outlineWidth = 0.04 -- 617
	seqLb.anchor = Vec2(1, 1) -- 618
	seqLb.scaleX = 1 / SS -- 619
	seqLb.scaleY = 1 / SS -- 620
	seqLb.position = Vec2(SAY.x + SAY.w - 22, H - (SAY.y + 26)) -- 621
	seqLb:addTo(sayGroup) -- 622
	local tipLb = Label(((REG .. ";") .. tostring(math.floor(16 * SS + 0.5))) .. ";true") -- 624
	tipLb.color = Color(36, 73, 70, 175) -- 625
	tipLb.outlineColor = Color(36, 73, 70, 175) -- 626
	tipLb.outlineWidth = 0.04 -- 627
	tipLb.anchor = Vec2(1, 1) -- 628
	tipLb.scaleX = 1 / SS -- 629
	tipLb.scaleY = 1 / SS -- 630
	tipLb.position = Vec2(SAY.x + SAY.w - 22, H - (SAY.y + SAY_H - 16)) -- 631
	tipLb.text = "点击继续" -- 632
	tipLb:addTo(sayGroup) -- 633
	local S_IN = 0 -- 636
	local S_TYPE = 1 -- 637
	local S_HOLD = 2 -- 638
	local S_NEXT = 3 -- 639
	local S_OUT = 4 -- 640
	local S_DONE = 5 -- 641
	local st = S_IN -- 643
	local t = 0 -- 644
	local idx = -1 -- 645
	local target = "" -- 646
	local shown = 0 -- 647
	local fxCur = nil -- 648
	local pageT = 0 -- 649
	local total = #opts.lines -- 651
	local function setFx(fx) -- 653
		fxCur = nil -- 654
		__TS__ArrayForEach( -- 655
			fxNodes, -- 655
			function(____, f) -- 655
				if fx ~= nil and f.name == fx then -- 655
					f.node.visible = true -- 657
					f.node.opacity = 0 -- 658
					fxCur = f.node -- 659
					if rulerLine ~= nil and f.node == fxRuler then -- 659
						rulerLine.size = Size(0, 3) -- 660
					end -- 660
				else -- 660
					f.node.visible = false -- 662
					f.node.opacity = 0 -- 663
				end -- 663
			end -- 655
		) -- 655
	end -- 653
	local function seqText(i) -- 668
		local a = i + 1 -- 669
		return ((((a < 10 and "0" or "") .. tostring(a)) .. " / ") .. (total < 10 and "0" or "")) .. tostring(total) -- 670
	end -- 668
	local function startLine(i) -- 673
		idx = i -- 674
		local L = opts.lines[i + 1] -- 675
		target = L.text -- 676
		shown = 0 -- 677
		layoutLine(target) -- 678
		showChars(0) -- 679
		setTxOpacity(0) -- 680
		seqLb.text = seqText(i) -- 681
		setFx(L.fx) -- 682
		setFace(L.ex) -- 683
		t = 0 -- 684
		st = S_TYPE -- 685
	end -- 673
	local function advance() -- 688
		if openIdx >= 0 then -- 688
			toggleCard(openIdx) -- 691
			return -- 692
		end -- 692
		if st == S_TYPE then -- 692
			shown = txCount -- 696
			showChars(txCount) -- 697
			setTxOpacity(1) -- 698
			st = S_HOLD -- 699
			return -- 700
		end -- 700
		if st == S_HOLD then -- 700
			if idx + 1 >= total then -- 700
				st = S_OUT -- 704
				t = 0 -- 705
				return -- 706
			end -- 706
			st = S_NEXT -- 708
			t = 0 -- 709
		end -- 709
	end -- 688
	local function update(dt) -- 713
		t = t + dt -- 714
		pageT = pageT + dt -- 715
		local talking = st == S_TYPE -- 719
		local bob = talking and math.sin(pageT * 9.5) * 3.2 or math.sin(pageT * 1.57) * 2.4 -- 720
		local ang = talking and math.sin(pageT * 6.7) * 0.55 or 0 -- 723
		local sck = talking and 1 + math.sin(pageT * 6.7) * 0.008 or 1 -- 724
		do -- 724
			local i = 0 -- 725
			while i < #faceSprites do -- 725
				faceSprites[i + 1].position = Vec2(WZ_X + FACE_W / 2, WZ_Y + bob) -- 726
				faceSprites[i + 1].angle = ang -- 727
				faceSprites[i + 1].scaleX = sck -- 728
				faceSprites[i + 1].scaleY = sck -- 729
				i = i + 1 -- 725
			end -- 725
		end -- 725
		do -- 725
			local i = 0 -- 733
			while i < #faceSprites do -- 733
				local want = i == faceCur and 1 or 0 -- 734
				local cur = faceSprites[i + 1].opacity -- 735
				if math.abs(want - cur) > 0.01 then -- 735
					faceSprites[i + 1].opacity = cur + (want - cur) * math.min(1, dt * 9) -- 737
				else -- 737
					faceSprites[i + 1].opacity = want -- 739
				end -- 739
				i = i + 1 -- 733
			end -- 733
		end -- 733
		if openIdx >= 0 and cardAnim < 1 then -- 733
			cardAnim = math.min(1, cardAnim + dt * 7.5) -- 745
			local e = 1 - (1 - cardAnim) ^ 3 -- 746
			cardNodes[openIdx + 1].opacity = e -- 747
			cardNodes[openIdx + 1].position = Vec2(0, -10 * (1 - e)) -- 748
		end -- 748
		do -- 748
			local i = #ripples - 1 -- 752
			while i >= 0 do -- 752
				local r = ripples[i + 1] -- 753
				r.t = r.t + dt -- 754
				local p = math.min(1, r.t / r.dur) -- 755
				local d = r.d0 + (r.d1 - r.d0) * p -- 756
				r.s.size = Size(d, d) -- 757
				r.s.opacity = 1 - p -- 758
				if p >= 1 then -- 758
					r.s:removeFromParent() -- 760
					__TS__ArraySplice(ripples, i, 1) -- 761
				end -- 761
				i = i - 1 -- 752
			end -- 752
		end -- 752
		if st == S_IN then -- 752
			introT = introT + dt -- 769
			layer.opacity = math.min(1, introT / 0.26) -- 770
			local function ease(t0, dur) -- 772
				local k = math.min( -- 773
					1, -- 773
					math.max(0, (introT - t0) / dur) -- 773
				) -- 773
				return 1 - (1 - k) ^ 3 -- 774
			end -- 772
			local aH = ease(0.04, 0.42) -- 778
			headGroup.opacity = aH -- 779
			headGroup.position = Vec2(0, 16 * (1 - aH)) -- 780
			local aS = ease(0.14, 0.62) -- 782
			sceneGroup.opacity = aS -- 783
			sceneGroup.position = Vec2(0, -22 * (1 - aS)) -- 784
			local aW = ease(0.34, 0.58) -- 786
			faceGroup.opacity = aW -- 787
			faceGroup.position = Vec2(72 * (1 - aW), 0) -- 788
			local aD = ease(0.56, 0.58) -- 790
			sayGroup.opacity = aD -- 791
			sayGroup.position = Vec2(0, -52 * (1 - aD)) -- 792
			if introT >= 1.32 then -- 792
				headGroup.position = Vec2(0, 0) -- 795
				sceneGroup.position = Vec2(0, 0) -- 796
				faceGroup.position = Vec2(0, 0) -- 797
				sayGroup.position = Vec2(0, 0) -- 798
				headGroup.opacity = 1 -- 799
				sceneGroup.opacity = 1 -- 800
				faceGroup.opacity = 1 -- 801
				sayGroup.opacity = 1 -- 802
				startLine(opts.startAt ~= nil and opts.startAt or 0) -- 803
			end -- 803
		elseif st == S_TYPE then -- 803
			layer.opacity = 1 -- 807
			setTxOpacity(math.min(1, t / FADE_IN_LINE)) -- 808
			local n = math.min( -- 810
				txCount, -- 810
				math.max( -- 810
					0, -- 810
					math.floor((t - 0.14) / CPS) -- 810
				) -- 810
			) -- 810
			if n > shown then -- 810
				shown = n -- 812
				showChars(n) -- 813
			end -- 813
			if t > 0.14 and shown >= txCount then -- 813
				showChars(txCount) -- 816
				st = S_HOLD -- 817
			end -- 817
		elseif st == S_HOLD then -- 817
			layer.opacity = 1 -- 821
			setTxOpacity(1) -- 822
		elseif st == S_NEXT then -- 822
			setTxOpacity(math.max(0, 1 - t / FADE_OUT_LINE)) -- 825
			if t >= FADE_OUT_LINE then -- 825
				startLine(idx + 1) -- 826
			end -- 826
		elseif st == S_OUT then -- 826
			layer.opacity = math.max(0, 1 - t / FADE_OUT_ALL) -- 829
			if t >= FADE_OUT_ALL then -- 829
				st = S_DONE -- 831
				opts:onFinish() -- 832
			end -- 832
		end -- 832
		if fxCur ~= nil and fxCur.opacity < 1 then -- 832
			fxCur.opacity = math.min(1, fxCur.opacity + dt * 2.6) -- 838
			if rulerLine ~= nil and fxCur == fxRuler then -- 838
				rulerLine.size = Size(920 * fxCur.opacity, 3) -- 840
			end -- 840
		end -- 840
		do -- 840
			local i = 0 -- 845
			while i < #spotDots do -- 845
				local k = 1 + math.sin(pageT * 2.2 + i * 1.4) * 0.12 -- 846
				spotDots[i + 1].scaleX = k -- 847
				spotDots[i + 1].scaleY = k -- 848
				i = i + 1 -- 845
			end -- 845
		end -- 845
	end -- 713
	local function destroy() -- 852
		layer:removeFromParent() -- 852
	end -- 852
	local function skip() -- 855
		if st == S_DONE then -- 855
			return -- 856
		end -- 856
		st = S_DONE -- 857
		layer.opacity = 0 -- 858
		opts:onFinish() -- 859
	end -- 855
	return { -- 862
		next = function() -- 863
			advance() -- 863
		end, -- 863
		tapAt = function(x, y) return tapAt(x, y) end, -- 864
		update = function(dt) -- 865
			update(dt) -- 865
		end, -- 865
		destroy = function() -- 866
			destroy() -- 866
		end, -- 866
		isFinished = function() return st == S_DONE end, -- 867
		skip = function() -- 868
			skip() -- 868
		end -- 868
	} -- 868
end -- 87
return ____exports -- 87