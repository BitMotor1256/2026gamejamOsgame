-- [ts]: Level3PreScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstr = ____lualib.__TS__StringSubstr -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Director = ____Dora.Director -- 10
local Label = ____Dora.Label -- 10
local Node = ____Dora.Node -- 10
local Size = ____Dora.Size -- 10
local Sprite = ____Dora.Sprite -- 10
local Vec2 = ____Dora.Vec2 -- 10
local ____SceneFrame = require("Script.SceneFrame") -- 11
local H = ____SceneFrame.H -- 11
local createSceneFrame = ____SceneFrame.createSceneFrame -- 11
local W = 1280 -- 13
local S = "Image/StartUI/" -- 14
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 15
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 16
local C_PAGE = Color(207, 196, 166, 255) -- 18
local C_CARD = Color(252, 247, 232, 255) -- 19
local C_INK = Color(36, 73, 70, 255) -- 20
local C_INK2 = Color(76, 99, 87, 255) -- 21
local C_VERM = Color(163, 59, 42, 255) -- 22
local LINES = { -- 27
	{t = "这就是他们的田。堡里留了一百多亩。", mark = "field", face = "wave"}, -- 28
	{t = "水从城外河里来，过水门，进城里两条河，再流到田里。", mark = "flow", face = "curvy"}, -- 29
	{t = "门洞上头架着石桥，人从桥上过。闸板藏在桥底下。", mark = "bridge", face = "dot"}, -- 30
	{t = "闸一落，敌船进不来。可自家的水，也进不来了。", mark = "gate", face = "dot"}, -- 31
	{t = "平时闸开着。两条河的水进城，再分十条支渠，一块田一块田地淌过去。", mark = "eight", face = "curvy"}, -- 32
	{t = "这些田，一年能收两季。真围起来，全城就指着它。", mark = "field2", face = "dot"}, -- 33
	{t = "围城的时候，闸得一直关着。城里的水只出不进。", mark = "gate", face = "curvy"}, -- 34
	{t = "八块田都要灌，但怎么灌是个问题。", mark = "eight", face = "curvy"}, -- 35
	{t = "来试试。水头不听你的，它只会一直往前。", mark = "", face = "wave"} -- 36
} -- 36
function ____exports.startLevel3Pre(onDone) -- 39
	local state -- 39
	Director.clearColor = C_PAGE -- 40
	local frame = createSceneFrame(0.18) -- 44
	local root = frame.inner -- 45
	local function place(n, x, y) -- 48
		n.position = Vec2(x, H - y) -- 49
	end -- 48
	local function block(p, x, y, w, h, c, a) -- 51
		local s = Sprite("Image/StartUI/white.png") -- 55
		s.size = Size(w, h) -- 56
		s.anchor = Vec2(0, 1) -- 57
		s.color = c -- 58
		s.opacity = a -- 59
		place(s, x, y) -- 60
		s:addTo(p) -- 61
		return s -- 62
	end -- 51
	local function img(p, f, x, y, w, h) -- 64
		local s = Sprite(f) -- 65
		s.size = Size(w, h) -- 66
		s.anchor = Vec2(0, 1) -- 67
		place(s, x, y) -- 68
		s:addTo(p) -- 69
		return s -- 70
	end -- 64
	local function toChars(str) -- 75
		local out = {} -- 76
		local i = 0 -- 77
		while i < #str do -- 77
			local c = __TS__StringCharCodeAt(str, i) -- 79
			local n = 1 -- 80
			if c >= 240 then -- 80
				n = 4 -- 81
			elseif c >= 224 then -- 81
				n = 3 -- 82
			elseif c >= 192 then -- 82
				n = 2 -- 83
			end -- 83
			out[#out + 1] = __TS__StringSubstr(str, i, n) -- 84
			i = i + n -- 85
		end -- 85
		return out -- 87
	end -- 75
	local function label(p, font, size, c, x, y, ax, ls) -- 90
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 94
		lb.color = c -- 95
		lb.anchor = Vec2(ax, 1) -- 96
		lb.scaleX = 0.5 -- 97
		lb.scaleY = 0.5 -- 98
		lb.position = Vec2(x, H - y + size) -- 99
		if ls > 0 then -- 99
			lb.spacing = math.floor(ls * 2 + 0.5) -- 100
		end -- 100
		lb:addTo(p) -- 101
		return lb -- 102
	end -- 90
	img( -- 106
		root, -- 106
		S .. "lv3_post_scene.png", -- 106
		0, -- 106
		0, -- 106
		1, -- 106
		1 -- 106
	).visible = false -- 106
	img( -- 108
		root, -- 108
		S .. "lv2_paper.png", -- 108
		0, -- 108
		0, -- 108
		W, -- 108
		H + 4 -- 108
	) -- 108
	block( -- 110
		root, -- 110
		56, -- 110
		44, -- 110
		W - 112, -- 110
		1.5, -- 110
		C_INK, -- 110
		0.55 -- 110
	) -- 110
	local hd = label( -- 111
		root, -- 111
		FONT_B, -- 111
		18, -- 111
		C_INK2, -- 111
		56, -- 111
		68, -- 111
		0, -- 111
		0.4 -- 111
	) -- 111
	hd.text = "三 · 引流　关前" -- 112
	local SC_X = 120 -- 116
	local SC_Y = 104 -- 116
	local SC_W = 1040 -- 116
	local SC_H = 330 -- 116
	block( -- 117
		root, -- 117
		SC_X + 9, -- 117
		SC_Y + 9, -- 117
		SC_W, -- 117
		SC_H, -- 117
		C_INK, -- 117
		0.9 -- 117
	) -- 117
	img( -- 118
		root, -- 118
		S .. "lv3_post_scene.png", -- 118
		SC_X, -- 118
		SC_Y, -- 118
		SC_W, -- 118
		SC_H -- 118
	) -- 118
	block( -- 120
		root, -- 120
		SC_X, -- 120
		SC_Y, -- 120
		SC_W, -- 120
		3, -- 120
		C_INK, -- 120
		1 -- 120
	) -- 120
	block( -- 121
		root, -- 121
		SC_X, -- 121
		SC_Y + SC_H - 3, -- 121
		SC_W, -- 121
		3, -- 121
		C_INK, -- 121
		1 -- 121
	) -- 121
	block( -- 122
		root, -- 122
		SC_X, -- 122
		SC_Y, -- 122
		3, -- 122
		SC_H, -- 122
		C_INK, -- 122
		1 -- 122
	) -- 122
	block( -- 123
		root, -- 123
		SC_X + SC_W - 3, -- 123
		SC_Y, -- 123
		3, -- 123
		SC_H, -- 123
		C_INK, -- 123
		1 -- 123
	) -- 123
	block( -- 125
		root, -- 125
		SC_X - 3, -- 125
		SC_Y - 3, -- 125
		74, -- 125
		30, -- 125
		C_VERM, -- 125
		1 -- 125
	) -- 125
	local tag = label( -- 126
		root, -- 126
		FONT_B, -- 126
		17, -- 126
		C_CARD, -- 126
		SC_X + 14, -- 126
		SC_Y + 24, -- 126
		0, -- 126
		1.6 -- 126
	) -- 126
	tag.text = "图一" -- 127
	local marks = { -- 134
		field = {}, -- 134
		field2 = {}, -- 134
		flow = {}, -- 134
		bridge = {}, -- 134
		gate = {}, -- 134
		eight = {} -- 134
	} -- 134
	local markKeys = { -- 135
		"field", -- 135
		"field2", -- 135
		"flow", -- 135
		"bridge", -- 135
		"gate", -- 135
		"eight" -- 135
	} -- 135
	local function mkMark(k, n) -- 136
		local ____marks_k_0 = marks[k] -- 136
		____marks_k_0[#____marks_k_0 + 1] = n -- 136
	end -- 136
	local function mBlock(k, x, y, w, h, c, al) -- 139
		local sp = block( -- 140
			root, -- 140
			SC_X + x, -- 140
			SC_Y + y, -- 140
			w, -- 140
			h, -- 140
			c, -- 140
			al -- 140
		) -- 140
		mkMark(k, sp) -- 141
		return sp -- 142
	end -- 139
	local function mFrame(k, x, y, w, h, al) -- 144
		mBlock( -- 145
			k, -- 145
			x, -- 145
			y, -- 145
			w, -- 145
			3, -- 145
			C_VERM, -- 145
			al -- 145
		) -- 145
		mBlock( -- 146
			k, -- 146
			x, -- 146
			y + h - 3, -- 146
			w, -- 146
			3, -- 146
			C_VERM, -- 146
			al -- 146
		) -- 146
		mBlock( -- 147
			k, -- 147
			x, -- 147
			y, -- 147
			3, -- 147
			h, -- 147
			C_VERM, -- 147
			al -- 147
		) -- 147
		mBlock( -- 148
			k, -- 148
			x + w - 3, -- 148
			y, -- 148
			3, -- 148
			h, -- 148
			C_VERM, -- 148
			al -- 148
		) -- 148
	end -- 144
	local function mTip(k, x, y, str) -- 150
		local w = #toChars(str) * 24 + 34 -- 152
		mBlock( -- 153
			k, -- 153
			x - 4, -- 153
			y - 4, -- 153
			w + 8, -- 153
			48, -- 153
			C_INK, -- 153
			0.88 -- 153
		) -- 153
		mBlock( -- 154
			k, -- 154
			x, -- 154
			y, -- 154
			w, -- 154
			40, -- 154
			C_CARD, -- 154
			0.99 -- 154
		) -- 154
		mFrame( -- 155
			k, -- 155
			x, -- 155
			y, -- 155
			w, -- 155
			40, -- 155
			1 -- 155
		) -- 155
		local lb = label( -- 156
			root, -- 156
			FONT_B, -- 156
			22, -- 156
			Color(142, 46, 31, 255), -- 156
			SC_X + x + 18, -- 156
			SC_Y + y + 31, -- 156
			0, -- 156
			0.4 -- 156
		) -- 156
		lb.text = str -- 157
		mkMark(k, lb) -- 158
	end -- 150
	local function mNum(k, x, y, n) -- 162
		mBlock( -- 163
			k, -- 163
			x - 13, -- 163
			y - 13, -- 163
			26, -- 163
			26, -- 163
			C_VERM, -- 163
			1 -- 163
		) -- 163
		mBlock( -- 164
			k, -- 164
			x - 13, -- 164
			y - 13, -- 164
			26, -- 164
			2, -- 164
			C_INK, -- 164
			0.9 -- 164
		) -- 164
		local lb = label( -- 165
			root, -- 165
			FONT_B, -- 165
			15, -- 165
			C_CARD, -- 165
			SC_X + x, -- 165
			SC_Y + y + 7, -- 165
			0.5, -- 165
			0 -- 165
		) -- 165
		lb.text = tostring(n) -- 166
		mkMark(k, lb) -- 167
	end -- 162
	mFrame( -- 171
		"field", -- 171
		28, -- 171
		228, -- 171
		430, -- 171
		98, -- 171
		1 -- 171
	) -- 171
	mTip("field", 470, 250, "一百多亩") -- 172
	mFrame( -- 175
		"field2", -- 175
		28, -- 175
		228, -- 175
		430, -- 175
		98, -- 175
		1 -- 175
	) -- 175
	mTip("field2", 470, 250, "一年两收") -- 176
	do -- 176
		local i = 0 -- 180
		while i <= 12 do -- 180
			local t = i / 12 -- 181
			local mt = 1 - t -- 182
			local bx = mt * mt * 1014 + 2 * mt * t * 700 + t * t * 620 -- 183
			local by = mt * mt * 70 + 2 * mt * t * 94 + t * t * 146 -- 184
			mBlock( -- 185
				"flow", -- 185
				bx - 3, -- 185
				by - 3, -- 185
				6, -- 185
				6, -- 185
				C_VERM, -- 185
				0.85 -- 185
			) -- 185
			i = i + 1 -- 180
		end -- 180
	end -- 180
	mBlock( -- 187
		"flow", -- 187
		614, -- 187
		140, -- 187
		13, -- 187
		13, -- 187
		C_VERM, -- 187
		1 -- 187
	) -- 187
	mTip("flow", 52, 74, "水从城外河来") -- 188
	mFrame( -- 191
		"bridge", -- 191
		536, -- 191
		62, -- 191
		170, -- 191
		34, -- 191
		1 -- 191
	) -- 191
	mTip("bridge", 596, 172, "桥在上，闸在下") -- 192
	mFrame( -- 195
		"gate", -- 195
		566, -- 195
		80, -- 195
		108, -- 195
		46, -- 195
		1 -- 195
	) -- 195
	mTip("gate", 600, 128, "闸一落") -- 196
	mNum("eight", 300, 146, 1) -- 199
	mNum("eight", 736, 146, 2) -- 200
	mNum("eight", 250, 196, 3) -- 201
	mNum("eight", 786, 196, 4) -- 202
	mNum("eight", 186, 262, 5) -- 203
	mNum("eight", 850, 262, 6) -- 204
	mNum("eight", 126, 300, 7) -- 205
	mNum("eight", 910, 300, 8) -- 206
	mTip("eight", 404, 66, "八块田") -- 207
	for ____, k in ipairs(markKeys) do -- 210
		for ____, sp in ipairs(marks[k]) do -- 210
			sp.visible = false -- 210
		end -- 210
	end -- 210
	local SAY_X = 120 -- 213
	local SAY_Y = 530 -- 213
	local SAY_W = 744 -- 213
	local SAY_H = 172 -- 213
	block( -- 214
		root, -- 214
		SAY_X + 7, -- 214
		SAY_Y + 7, -- 214
		SAY_W, -- 214
		SAY_H, -- 214
		C_INK, -- 214
		0.94 -- 214
	) -- 214
	block( -- 215
		root, -- 215
		SAY_X, -- 215
		SAY_Y, -- 215
		SAY_W, -- 215
		SAY_H, -- 215
		C_CARD, -- 215
		1 -- 215
	) -- 215
	block( -- 217
		root, -- 217
		SAY_X, -- 217
		SAY_Y, -- 217
		SAY_W, -- 217
		2.5, -- 217
		C_INK, -- 217
		1 -- 217
	) -- 217
	block( -- 218
		root, -- 218
		SAY_X, -- 218
		SAY_Y + SAY_H - 2.5, -- 218
		SAY_W, -- 218
		2.5, -- 218
		C_INK, -- 218
		1 -- 218
	) -- 218
	block( -- 219
		root, -- 219
		SAY_X, -- 219
		SAY_Y, -- 219
		2.5, -- 219
		SAY_H, -- 219
		C_INK, -- 219
		1 -- 219
	) -- 219
	block( -- 220
		root, -- 220
		SAY_X + SAY_W - 2.5, -- 220
		SAY_Y, -- 220
		2.5, -- 220
		SAY_H, -- 220
		C_INK, -- 220
		1 -- 220
	) -- 220
	block( -- 223
		root, -- 223
		136, -- 223
		509, -- 223
		96, -- 223
		34, -- 223
		C_VERM, -- 223
		1 -- 223
	) -- 223
	local pill = label( -- 224
		root, -- 224
		FONT_B, -- 224
		15, -- 224
		C_CARD, -- 224
		184, -- 224
		534, -- 224
		0.5, -- 224
		4.2 -- 224
	) -- 224
	pill.text = "王 梓" -- 225
	local TX_N = 32 -- 230
	local TX_SIZE = 32 -- 231
	local txChars = {} -- 232
	do -- 232
		local i = 0 -- 233
		while i < TX_N do -- 233
			local lb = label( -- 234
				root, -- 234
				FONT_R, -- 234
				TX_SIZE, -- 234
				C_INK, -- 234
				156, -- 234
				610, -- 234
				0, -- 234
				0.4 -- 234
			) -- 234
			lb.visible = false -- 235
			txChars[#txChars + 1] = lb -- 236
			i = i + 1 -- 233
		end -- 233
	end -- 233
	local seqLb = label( -- 238
		root, -- 238
		FONT_R, -- 238
		15, -- 238
		Color(76, 99, 87, 190), -- 238
		842, -- 238
		548, -- 238
		1, -- 238
		0 -- 238
	) -- 238
	local tipLb = label( -- 239
		root, -- 239
		FONT_R, -- 239
		16, -- 239
		Color(36, 73, 70, 175), -- 239
		842, -- 239
		690, -- 239
		1, -- 239
		0 -- 239
	) -- 239
	tipLb.text = "点击继续　P 跳过" -- 240
	local cap = label( -- 243
		root, -- 243
		FONT_R, -- 243
		16, -- 243
		Color(76, 99, 87, 230), -- 243
		756, -- 243
		462, -- 243
		1, -- 243
		0.6 -- 243
	) -- 243
	cap.text = "永昌堡 · 堡内水田（示意）" -- 244
	block( -- 247
		root, -- 247
		0, -- 247
		700, -- 247
		W, -- 247
		1.5, -- 247
		C_INK, -- 247
		0.5 -- 247
	) -- 247
	local foot = label( -- 248
		root, -- 248
		FONT_R, -- 248
		13, -- 248
		Color(36, 73, 70, 120), -- 248
		120, -- 248
		742, -- 248
		0, -- 248
		1.2 -- 248
	) -- 248
	foot.text = "永昌堡 · 嘉靖四十年 · 五月 · 夜尽" -- 249
	local WZ_X = 1030 -- 252
	local WZ_Y = 404 -- 252
	local WZ_W = 250 -- 252
	local WZ_H = 344 -- 252
	local faces = {} -- 253
	for ____, n in ipairs({ -- 254
		"smile", -- 254
		"laugh", -- 254
		"dot", -- 254
		"wave", -- 254
		"curvy" -- 254
	}) do -- 254
		local sp = img( -- 255
			root, -- 255
			((S .. "face_") .. n) .. ".png", -- 255
			WZ_X, -- 255
			WZ_Y, -- 255
			WZ_W, -- 255
			WZ_H -- 255
		) -- 255
		sp.visible = false -- 256
		faces[n] = sp -- 257
	end -- 257
	local idx = -1 -- 261
	local typed = 0 -- 262
	local textLen = 0 -- 263
	local typing = false -- 264
	local done = false -- 265
	local function showLine(i) -- 267
		idx = i -- 268
		typed = 0 -- 269
		typing = true -- 270
		local L = LINES[i + 1] -- 271
		local chars = toChars(L.t) -- 273
		local cx = 156 -- 274
		do -- 274
			local n = 0 -- 275
			while n < TX_N do -- 275
				local lb = txChars[n + 1] -- 276
				if n < #chars then -- 276
					lb.text = chars[n + 1] -- 278
					lb.position = Vec2(cx, H - 610 + TX_SIZE) -- 279
					cx = cx + (TX_SIZE * 0.78 + 1) -- 280
					lb.visible = false -- 281
				else -- 281
					lb.visible = false -- 283
				end -- 283
				n = n + 1 -- 275
			end -- 275
		end -- 275
		textLen = math.min(TX_N, #chars) -- 286
		seqLb.text = (((i + 1 < 10 and "0" or "") .. tostring(i + 1 < 10 and i + 1 or i + 1)) .. " / ") .. tostring(#LINES) -- 287
		for ____, k in ipairs(markKeys) do -- 289
			local on = k == L.mark -- 290
			for ____, sp in ipairs(marks[k]) do -- 291
				sp.visible = on -- 291
			end -- 291
		end -- 291
		for k in pairs(faces) do -- 294
			faces[k].visible = k == L.face -- 294
		end -- 294
		tipLb.text = i == #LINES - 1 and "点击收尾　P 跳过" or "点击继续　P 跳过" -- 295
	end -- 267
	local function finishTyping() -- 298
		typing = false -- 299
		typed = textLen -- 300
		do -- 300
			local n = 0 -- 301
			while n < textLen do -- 301
				txChars[n + 1].visible = true -- 301
				n = n + 1 -- 301
			end -- 301
		end -- 301
	end -- 298
	local function endAll() -- 304
		if state >= 2 then -- 304
			return -- 305
		end -- 305
		state = 2 -- 306
		frame:destroy() -- 307
		onDone() -- 308
	end -- 304
	local function tap() -- 311
		if state ~= 0 then -- 311
			return -- 312
		end -- 312
		if idx < 0 then -- 312
			showLine(0) -- 314
			return -- 314
		end -- 314
		if typing then -- 314
			finishTyping() -- 315
			return -- 315
		end -- 315
		if idx + 1 < #LINES then -- 315
			showLine(idx + 1) -- 316
			return -- 316
		end -- 316
		if not done then -- 316
			done = true -- 318
			endAll() -- 318
		end -- 318
	end -- 311
	state = 0 -- 321
	local born = 0 -- 322
	frame.input:onTapped(function() -- 325
		tap() -- 325
		return true -- 325
	end) -- 325
	local _START = 5 -- 329
	showLine(_START - 1) -- 330
	state = 0 -- 331
	root:onKeyDown(function(key) -- 337
		if key == "P" then -- 337
			if born < 0.35 then -- 337
				return true -- 339
			end -- 339
			endAll() -- 340
			return true -- 341
		end -- 341
		if key == "Space" or key == "Return" then -- 341
			tap() -- 343
			return true -- 343
		end -- 343
		return false -- 344
	end) -- 337
	local acc = 0 -- 348
	local time = 0 -- 349
	local function update(dt) -- 350
		time = time + dt -- 351
		born = born + dt -- 352
		local bob = math.sin(time * 1.5) * 2.4 -- 354
		local sway = typing and math.sin(time * 11) * 1.1 or 0 -- 356
		for k in pairs(faces) do -- 357
			do -- 357
				local sp = faces[k] -- 358
				if not sp.visible then -- 358
					goto __continue56 -- 359
				end -- 359
				sp.position = Vec2(WZ_X + sway, H - WZ_Y + bob) -- 360
			end -- 360
			::__continue56:: -- 360
		end -- 360
		if not typing or idx < 0 then -- 360
			return -- 362
		end -- 362
		typed = typed + dt * 31 -- 363
		if typed >= textLen then -- 363
			finishTyping() -- 364
			return -- 364
		end -- 364
		local n = math.floor(typed) -- 365
		do -- 365
			local k = 0 -- 367
			while k < n do -- 367
				txChars[k + 1].visible = true -- 367
				k = k + 1 -- 367
			end -- 367
		end -- 367
		acc = acc + dt -- 368
	end -- 350
	root:schedule(function(dt) -- 370
		update(dt) -- 370
		return false -- 370
	end) -- 370
	return { -- 372
		root = root, -- 373
		close = function() -- 374
			frame:destroy() -- 374
		end, -- 374
		isDone = function() return state == 2 end -- 375
	} -- 375
end -- 39
function ____exports.showLevel3Placeholder(back, sub) -- 386
	if sub == nil then -- 386
		sub = "玩法开发中" -- 386
	end -- 386
	Director.clearColor = Color(23, 51, 48, 255) -- 387
	local r = Node() -- 390
	r.anchor = Vec2(0.5, 0.5) -- 391
	r.position = Vec2(0, 0) -- 392
	r:addTo(Director.ui) -- 393
	local function mk(size, color, text, y) -- 395
		local t = Label(("Font/SourceHanSerifSC-SemiBold.ttf;" .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 396
		t.text = text -- 397
		t.color = color -- 398
		t.anchor = Vec2(0.5, 0.5) -- 399
		t.position = Vec2(0, y) -- 400
		t:addTo(r) -- 401
	end -- 395
	mk( -- 403
		52, -- 403
		Color(233, 223, 196, 255), -- 403
		"三 · 引流", -- 403
		90 -- 403
	) -- 403
	mk( -- 404
		26, -- 404
		Color(163, 59, 42, 255), -- 404
		"玩法开发中", -- 404
		-10 -- 404
	) -- 404
	mk( -- 405
		20, -- 405
		Color(233, 223, 196, 150), -- 405
		"按 ESC 回主菜单", -- 405
		-110 -- 405
	) -- 405
	r:onKeyDown(function(key) -- 407
		if key == "Escape" then -- 407
			back() -- 408
			return true -- 408
		end -- 408
		return false -- 409
	end) -- 407
end -- 386
return ____exports -- 386