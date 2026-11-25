-- [ts]: Level2PostScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstr = ____lualib.__TS__StringSubstr -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Director = ____Dora.Director -- 10
local Label = ____Dora.Label -- 10
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
	{t = "那一夜，砻就没停过。停一下，外面就听出来了。", mark = "mill", face = "dot"}, -- 28
	{t = "三台砻，三个音。左边闷，中间沉，右边尖。", mark = "three", face = "curvy"}, -- 29
	{t = "换着碾，声音才不单调。外面听着，就是一城人都在忙。", mark = "three", face = "dot"}, -- 30
	{t = "糠从磨缝里出来。比米轻，风一吹就散。", mark = "flow", face = "dot"}, -- 31
	{t = "可光靠耳朵骗不住人，城里得真有粮。", mark = "grain", face = "curvy"}, -- 32
	{t = "走，去看看他们的田。", mark = "", face = "wave"} -- 33
} -- 33
function ____exports.startLevel2Post(onDone) -- 36
	local state -- 36
	Director.clearColor = C_PAGE -- 37
	local frame = createSceneFrame(0.18) -- 41
	local root = frame.inner -- 42
	local function place(n, x, y) -- 45
		n.position = Vec2(x, H - y) -- 46
	end -- 45
	local function block(p, x, y, w, h, c, a) -- 48
		local s = Sprite("Image/StartUI/white.png") -- 52
		s.size = Size(w, h) -- 53
		s.anchor = Vec2(0, 1) -- 54
		s.color = c -- 55
		s.opacity = a -- 56
		place(s, x, y) -- 57
		s:addTo(p) -- 58
		return s -- 59
	end -- 48
	local function img(p, f, x, y, w, h) -- 61
		local s = Sprite(f) -- 62
		s.size = Size(w, h) -- 63
		s.anchor = Vec2(0, 1) -- 64
		place(s, x, y) -- 65
		s:addTo(p) -- 66
		return s -- 67
	end -- 61
	local function toChars(str) -- 72
		local out = {} -- 73
		local i = 0 -- 74
		while i < #str do -- 74
			local c = __TS__StringCharCodeAt(str, i) -- 76
			local n = 1 -- 77
			if c >= 240 then -- 77
				n = 4 -- 78
			elseif c >= 224 then -- 78
				n = 3 -- 79
			elseif c >= 192 then -- 79
				n = 2 -- 80
			end -- 80
			out[#out + 1] = __TS__StringSubstr(str, i, n) -- 81
			i = i + n -- 82
		end -- 82
		return out -- 84
	end -- 72
	local function label(p, font, size, c, x, y, ax, ls) -- 87
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 91
		lb.color = c -- 92
		lb.anchor = Vec2(ax, 1) -- 93
		lb.scaleX = 0.5 -- 94
		lb.scaleY = 0.5 -- 95
		lb.position = Vec2(x, H - y + size) -- 96
		if ls > 0 then -- 96
			lb.spacing = math.floor(ls * 2 + 0.5) -- 97
		end -- 97
		lb:addTo(p) -- 98
		return lb -- 99
	end -- 87
	img( -- 103
		root, -- 103
		S .. "lv2_post_scene.png", -- 103
		0, -- 103
		0, -- 103
		1, -- 103
		1 -- 103
	).visible = false -- 103
	img( -- 105
		root, -- 105
		S .. "lv2_paper.png", -- 105
		0, -- 105
		0, -- 105
		W, -- 105
		H + 4 -- 105
	) -- 105
	block( -- 107
		root, -- 107
		56, -- 107
		44, -- 107
		W - 112, -- 107
		1.5, -- 107
		C_INK, -- 107
		0.55 -- 107
	) -- 107
	local hd = label( -- 108
		root, -- 108
		FONT_B, -- 108
		18, -- 108
		C_INK2, -- 108
		56, -- 108
		68, -- 108
		0, -- 108
		0.4 -- 108
	) -- 108
	hd.text = "二 · 砻糠计　关后" -- 109
	local SC_X = 120 -- 113
	local SC_Y = 104 -- 113
	local SC_W = 1040 -- 113
	local SC_H = 330 -- 113
	block( -- 114
		root, -- 114
		SC_X + 9, -- 114
		SC_Y + 9, -- 114
		SC_W, -- 114
		SC_H, -- 114
		C_INK, -- 114
		0.9 -- 114
	) -- 114
	img( -- 115
		root, -- 115
		S .. "lv2_post_scene.png", -- 115
		SC_X, -- 115
		SC_Y, -- 115
		SC_W, -- 115
		SC_H -- 115
	) -- 115
	block( -- 117
		root, -- 117
		SC_X, -- 117
		SC_Y, -- 117
		SC_W, -- 117
		3, -- 117
		C_INK, -- 117
		1 -- 117
	) -- 117
	block( -- 118
		root, -- 118
		SC_X, -- 118
		SC_Y + SC_H - 3, -- 118
		SC_W, -- 118
		3, -- 118
		C_INK, -- 118
		1 -- 118
	) -- 118
	block( -- 119
		root, -- 119
		SC_X, -- 119
		SC_Y, -- 119
		3, -- 119
		SC_H, -- 119
		C_INK, -- 119
		1 -- 119
	) -- 119
	block( -- 120
		root, -- 120
		SC_X + SC_W - 3, -- 120
		SC_Y, -- 120
		3, -- 120
		SC_H, -- 120
		C_INK, -- 120
		1 -- 120
	) -- 120
	block( -- 122
		root, -- 122
		SC_X - 3, -- 122
		SC_Y - 3, -- 122
		74, -- 122
		30, -- 122
		C_VERM, -- 122
		1 -- 122
	) -- 122
	local tag = label( -- 123
		root, -- 123
		FONT_B, -- 123
		18, -- 123
		C_INK2, -- 123
		SC_X + 12, -- 123
		SC_Y + 52, -- 123
		0, -- 123
		0.4 -- 123
	) -- 123
	tag.text = "图一" -- 124
	local marks = {mill = {}, three = {}, flow = {}, grain = {}} -- 131
	local markKeys = {"mill", "three", "flow", "grain"} -- 132
	local function mkMark(k, n) -- 133
		local ____marks_k_0 = marks[k] -- 133
		____marks_k_0[#____marks_k_0 + 1] = n -- 133
	end -- 133
	local function mBlock(k, x, y, w, h, c, al) -- 136
		local sp = block( -- 137
			root, -- 137
			SC_X + x, -- 137
			SC_Y + y, -- 137
			w, -- 137
			h, -- 137
			c, -- 137
			al -- 137
		) -- 137
		mkMark(k, sp) -- 138
		return sp -- 139
	end -- 136
	local function mFrame(k, x, y, w, h, al) -- 141
		mBlock( -- 142
			k, -- 142
			x, -- 142
			y, -- 142
			w, -- 142
			3, -- 142
			C_VERM, -- 142
			al -- 142
		) -- 142
		mBlock( -- 143
			k, -- 143
			x, -- 143
			y + h - 3, -- 143
			w, -- 143
			3, -- 143
			C_VERM, -- 143
			al -- 143
		) -- 143
		mBlock( -- 144
			k, -- 144
			x, -- 144
			y, -- 144
			3, -- 144
			h, -- 144
			C_VERM, -- 144
			al -- 144
		) -- 144
		mBlock( -- 145
			k, -- 145
			x + w - 3, -- 145
			y, -- 145
			3, -- 145
			h, -- 145
			C_VERM, -- 145
			al -- 145
		) -- 145
	end -- 141
	local function mTip(k, x, y, str) -- 147
		local w = #str * 24 + 34 -- 148
		mBlock( -- 149
			k, -- 149
			x - 4, -- 149
			y - 4, -- 149
			w + 8, -- 149
			48, -- 149
			C_INK, -- 149
			0.88 -- 149
		) -- 149
		mBlock( -- 150
			k, -- 150
			x, -- 150
			y, -- 150
			w, -- 150
			40, -- 150
			C_CARD, -- 150
			0.99 -- 150
		) -- 150
		mFrame( -- 151
			k, -- 151
			x, -- 151
			y, -- 151
			w, -- 151
			40, -- 151
			1 -- 151
		) -- 151
		local lb = label( -- 152
			root, -- 152
			FONT_B, -- 152
			22, -- 152
			Color(142, 46, 31, 255), -- 152
			SC_X + x + 18, -- 152
			SC_Y + y + 31, -- 152
			0, -- 152
			0.4 -- 152
		) -- 152
		lb.text = str -- 153
		mkMark(k, lb) -- 154
	end -- 147
	mFrame( -- 158
		"mill", -- 158
		106, -- 158
		168, -- 158
		234, -- 158
		156, -- 158
		1 -- 158
	) -- 158
	mFrame( -- 159
		"mill", -- 159
		100, -- 159
		162, -- 159
		246, -- 159
		168, -- 159
		0.4 -- 159
	) -- 159
	mTip("mill", 368, 196, "整夜没停") -- 160
	mBlock( -- 163
		"three", -- 163
		346, -- 163
		250, -- 163
		56, -- 163
		2, -- 163
		C_VERM, -- 163
		0.55 -- 163
	) -- 163
	local toneText = {"左 · 闷", "中 · 沉", "右 · 尖"} -- 164
	local toneDot = { -- 165
		C_VERM, -- 165
		Color(126, 142, 128, 255), -- 165
		Color(76, 99, 87, 255) -- 165
	} -- 165
	do -- 165
		local i = 0 -- 166
		while i < 3 do -- 166
			local ty = 194 + i * 36 -- 167
			mBlock( -- 168
				"three", -- 168
				401, -- 168
				ty - 4, -- 168
				152, -- 168
				48, -- 168
				C_INK, -- 168
				0.88 -- 168
			) -- 168
			mBlock( -- 169
				"three", -- 169
				404, -- 169
				ty, -- 169
				146, -- 169
				40, -- 169
				C_CARD, -- 169
				0.99 -- 169
			) -- 169
			mFrame( -- 170
				"three", -- 170
				404, -- 170
				ty, -- 170
				146, -- 170
				40, -- 170
				1 -- 170
			) -- 170
			mBlock( -- 171
				"three", -- 171
				416, -- 171
				ty + 15, -- 171
				10, -- 171
				10, -- 171
				toneDot[i + 1], -- 171
				1 -- 171
			) -- 171
			local tl = label( -- 172
				root, -- 172
				FONT_B, -- 172
				17, -- 172
				Color(142, 46, 31, 255), -- 172
				SC_X + 436, -- 172
				SC_Y + ty + 29, -- 172
				0, -- 172
				0.3 -- 172
			) -- 172
			tl.text = toneText[i + 1] -- 173
			mkMark("three", tl) -- 174
			i = i + 1 -- 166
		end -- 166
	end -- 166
	mFrame( -- 178
		"flow", -- 178
		106, -- 178
		168, -- 178
		234, -- 178
		156, -- 178
		0.5 -- 178
	) -- 178
	mBlock( -- 179
		"flow", -- 179
		342, -- 179
		300, -- 179
		36, -- 179
		2.5, -- 179
		C_VERM, -- 179
		0.75 -- 179
	) -- 179
	mBlock( -- 180
		"flow", -- 180
		376, -- 180
		274, -- 180
		2.5, -- 180
		28, -- 180
		C_VERM, -- 180
		0.75 -- 180
	) -- 180
	mBlock( -- 181
		"flow", -- 181
		372, -- 181
		274, -- 181
		2.5, -- 181
		13, -- 181
		C_VERM, -- 181
		0.9 -- 181
	) -- 181
	mBlock( -- 182
		"flow", -- 182
		378, -- 182
		281, -- 182
		13, -- 182
		2.5, -- 182
		C_VERM, -- 182
		0.9 -- 182
	) -- 182
	mTip("flow", 404, 128, "糠从磨缝里出来") -- 183
	mFrame( -- 186
		"grain", -- 186
		788, -- 186
		172, -- 186
		190, -- 186
		112, -- 186
		1 -- 186
	) -- 186
	mTip("grain", 752, 92, "城里得真有粮") -- 187
	for ____, k in ipairs(markKeys) do -- 190
		for ____, sp in ipairs(marks[k]) do -- 190
			sp.visible = false -- 190
		end -- 190
	end -- 190
	local SAY_X = 120 -- 193
	local SAY_Y = 530 -- 193
	local SAY_W = 744 -- 193
	local SAY_H = 172 -- 193
	block( -- 194
		root, -- 194
		SAY_X + 7, -- 194
		SAY_Y + 7, -- 194
		SAY_W, -- 194
		SAY_H, -- 194
		C_INK, -- 194
		0.94 -- 194
	) -- 194
	block( -- 195
		root, -- 195
		SAY_X, -- 195
		SAY_Y, -- 195
		SAY_W, -- 195
		SAY_H, -- 195
		C_CARD, -- 195
		1 -- 195
	) -- 195
	block( -- 197
		root, -- 197
		SAY_X, -- 197
		SAY_Y, -- 197
		SAY_W, -- 197
		2.5, -- 197
		C_INK, -- 197
		1 -- 197
	) -- 197
	block( -- 198
		root, -- 198
		SAY_X, -- 198
		SAY_Y + SAY_H - 2.5, -- 198
		SAY_W, -- 198
		2.5, -- 198
		C_INK, -- 198
		1 -- 198
	) -- 198
	block( -- 199
		root, -- 199
		SAY_X, -- 199
		SAY_Y, -- 199
		2.5, -- 199
		SAY_H, -- 199
		C_INK, -- 199
		1 -- 199
	) -- 199
	block( -- 200
		root, -- 200
		SAY_X + SAY_W - 2.5, -- 200
		SAY_Y, -- 200
		2.5, -- 200
		SAY_H, -- 200
		C_INK, -- 200
		1 -- 200
	) -- 200
	block( -- 203
		root, -- 203
		136, -- 203
		509, -- 203
		96, -- 203
		34, -- 203
		C_VERM, -- 203
		1 -- 203
	) -- 203
	local pill = label( -- 204
		root, -- 204
		FONT_B, -- 204
		15, -- 204
		C_CARD, -- 204
		184, -- 204
		534, -- 204
		0.5, -- 204
		4.2 -- 204
	) -- 204
	pill.text = "王 梓" -- 205
	local TX_N = 32 -- 210
	local TX_SIZE = 32 -- 211
	local txChars = {} -- 212
	do -- 212
		local i = 0 -- 213
		while i < TX_N do -- 213
			local lb = label( -- 214
				root, -- 214
				FONT_R, -- 214
				TX_SIZE, -- 214
				C_INK, -- 214
				156, -- 214
				610, -- 214
				0, -- 214
				0.4 -- 214
			) -- 214
			lb.visible = false -- 215
			txChars[#txChars + 1] = lb -- 216
			i = i + 1 -- 213
		end -- 213
	end -- 213
	local seqLb = label( -- 218
		root, -- 218
		FONT_R, -- 218
		15, -- 218
		Color(76, 99, 87, 190), -- 218
		842, -- 218
		548, -- 218
		1, -- 218
		0 -- 218
	) -- 218
	local tipLb = label( -- 219
		root, -- 219
		FONT_R, -- 219
		16, -- 219
		Color(36, 73, 70, 175), -- 219
		842, -- 219
		690, -- 219
		1, -- 219
		0 -- 219
	) -- 219
	tipLb.text = "点击继续　P 跳过" -- 220
	local cap = label( -- 223
		root, -- 223
		FONT_R, -- 223
		16, -- 223
		Color(76, 99, 87, 210), -- 223
		756, -- 223
		462, -- 223
		1, -- 223
		0.6 -- 223
	) -- 223
	cap.text = "永昌堡 · 碾房（示意）" -- 224
	block( -- 227
		root, -- 227
		0, -- 227
		700, -- 227
		W, -- 227
		1.5, -- 227
		C_INK, -- 227
		0.5 -- 227
	) -- 227
	local foot = label( -- 228
		root, -- 228
		FONT_R, -- 228
		13, -- 228
		Color(36, 73, 70, 120), -- 228
		120, -- 228
		742, -- 228
		0, -- 228
		1.2 -- 228
	) -- 228
	foot.text = "永昌堡 · 嘉靖四十年 · 五月 · 夜尽" -- 229
	local WZ_X = 1030 -- 232
	local WZ_Y = 404 -- 232
	local WZ_W = 250 -- 232
	local WZ_H = 344 -- 232
	local faces = {} -- 233
	for ____, n in ipairs({ -- 234
		"smile", -- 234
		"laugh", -- 234
		"dot", -- 234
		"wave", -- 234
		"curvy" -- 234
	}) do -- 234
		local sp = img( -- 235
			root, -- 235
			((S .. "face_") .. n) .. ".png", -- 235
			WZ_X, -- 235
			WZ_Y, -- 235
			WZ_W, -- 235
			WZ_H -- 235
		) -- 235
		sp.visible = false -- 236
		faces[n] = sp -- 237
	end -- 237
	local idx = -1 -- 241
	local typed = 0 -- 242
	local textLen = 0 -- 243
	local typing = false -- 244
	local done = false -- 245
	local function showLine(i) -- 247
		idx = i -- 248
		typed = 0 -- 249
		typing = true -- 250
		local L = LINES[i + 1] -- 251
		local chars = toChars(L.t) -- 253
		local cx = 156 -- 254
		do -- 254
			local n = 0 -- 255
			while n < TX_N do -- 255
				local lb = txChars[n + 1] -- 256
				if n < #chars then -- 256
					lb.text = chars[n + 1] -- 258
					lb.position = Vec2(cx, H - 610 + TX_SIZE) -- 259
					cx = cx + (TX_SIZE * 0.78 + 1) -- 260
					lb.visible = false -- 261
				else -- 261
					lb.visible = false -- 263
				end -- 263
				n = n + 1 -- 255
			end -- 255
		end -- 255
		textLen = math.min(TX_N, #chars) -- 266
		seqLb.text = (((i + 1 < 10 and "0" or "") .. tostring(i + 1 < 10 and i + 1 or i + 1)) .. " / ") .. tostring(#LINES) -- 267
		for ____, k in ipairs(markKeys) do -- 269
			local on = k == L.mark -- 270
			for ____, sp in ipairs(marks[k]) do -- 271
				sp.visible = on -- 271
			end -- 271
		end -- 271
		for k in pairs(faces) do -- 274
			faces[k].visible = k == L.face -- 274
		end -- 274
		tipLb.text = i == #LINES - 1 and "点击收尾　P 跳过" or "点击继续　P 跳过" -- 275
	end -- 247
	local function finishTyping() -- 278
		typing = false -- 279
		typed = textLen -- 280
		do -- 280
			local n = 0 -- 281
			while n < textLen do -- 281
				txChars[n + 1].visible = true -- 281
				n = n + 1 -- 281
			end -- 281
		end -- 281
	end -- 278
	local function endAll() -- 284
		if state >= 2 then -- 284
			return -- 285
		end -- 285
		state = 2 -- 286
		frame:destroy() -- 287
		onDone() -- 288
	end -- 284
	local function tap() -- 291
		if state ~= 0 then -- 291
			return -- 292
		end -- 292
		if idx < 0 then -- 292
			showLine(0) -- 294
			return -- 294
		end -- 294
		if typing then -- 294
			finishTyping() -- 295
			return -- 295
		end -- 295
		if idx + 1 < #LINES then -- 295
			showLine(idx + 1) -- 296
			return -- 296
		end -- 296
		if not done then -- 296
			done = true -- 298
			endAll() -- 298
		end -- 298
	end -- 291
	state = 0 -- 301
	frame.input:onTapped(function() -- 304
		tap() -- 304
		return true -- 304
	end) -- 304
	showLine(0) -- 307
	state = 0 -- 308
	root:onKeyDown(function(key) -- 314
		if key == "P" then -- 314
			endAll() -- 315
			return true -- 315
		end -- 315
		if key == "Space" or key == "Return" then -- 315
			tap() -- 316
			return true -- 316
		end -- 316
		return false -- 317
	end) -- 314
	local acc = 0 -- 321
	local time = 0 -- 322
	local function update(dt) -- 323
		time = time + dt -- 324
		local bob = math.sin(time * 1.5) * 2.4 -- 326
		local sway = typing and math.sin(time * 11) * 1.1 or 0 -- 328
		for k in pairs(faces) do -- 329
			do -- 329
				local sp = faces[k] -- 330
				if not sp.visible then -- 330
					goto __continue54 -- 331
				end -- 331
				sp.position = Vec2(WZ_X + sway, H - WZ_Y + bob) -- 332
			end -- 332
			::__continue54:: -- 332
		end -- 332
		if not typing or idx < 0 then -- 332
			return -- 334
		end -- 334
		typed = typed + dt * 31 -- 335
		if typed >= textLen then -- 335
			finishTyping() -- 336
			return -- 336
		end -- 336
		local n = math.floor(typed) -- 337
		do -- 337
			local k = 0 -- 339
			while k < n do -- 339
				txChars[k + 1].visible = true -- 339
				k = k + 1 -- 339
			end -- 339
		end -- 339
		acc = acc + dt -- 340
	end -- 323
	root:schedule(function(dt) -- 342
		update(dt) -- 342
		return false -- 342
	end) -- 342
	return { -- 344
		root = root, -- 345
		close = function() -- 346
			frame:destroy() -- 346
		end, -- 346
		isDone = function() return state == 2 end -- 347
	} -- 347
end -- 36
return ____exports -- 36