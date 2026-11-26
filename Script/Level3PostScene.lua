-- [ts]: Level3PostScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstr = ____lualib.__TS__StringSubstr -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local Color = ____Dora.Color -- 11
local Director = ____Dora.Director -- 11
local Label = ____Dora.Label -- 11
local Size = ____Dora.Size -- 11
local Sprite = ____Dora.Sprite -- 11
local Vec2 = ____Dora.Vec2 -- 11
local ____SceneFrame = require("Script.SceneFrame") -- 12
local H = ____SceneFrame.H -- 12
local createSceneFrame = ____SceneFrame.createSceneFrame -- 12
local W = 1280 -- 14
local S = "Image/StartUI/" -- 15
local FONT_R = "Font/SourceHanSerifSC-Regular.ttf" -- 16
local FONT_B = "Font/SourceHanSerifSC-SemiBold.ttf" -- 17
local C_PAGE = Color(207, 196, 166, 255) -- 19
local C_CARD = Color(252, 247, 232, 255) -- 20
local C_INK = Color(36, 73, 70, 255) -- 21
local C_INK2 = Color(76, 99, 87, 255) -- 22
local C_VERM = Color(163, 59, 42, 255) -- 23
local C_TXT = Color(142, 46, 31, 255) -- 24
local LINES = { -- 29
	{t = "这座城是嘉靖三十八年修完的。修了十一个月，花了七千多两，钱是王家自己卖田凑的。", mark = "", face = "dot"}, -- 30
	{t = "刚才那道闸，上头是桥，人从桥上过。闸板藏在桥底下，平时看不见。", mark = "gate", face = "wave"}, -- 31
	{t = "水从城外进来，过水门，落进中间这条渠。", mark = "main", face = "dot"}, -- 32
	{t = "这条渠再往两边分，一条小渠管几块田，水就这么一路送到田口。", mark = "", face = "curvy"}, -- 33
	{t = "围城能撑住，靠的不是墙高，是有粮。", mark = "field", face = "dot"}, -- 34
	{t = "堡里留了一百多亩水田。真被围起来，外头的粮一粒也进不来，就靠这些田自己种、自己收。", mark = "field", face = "dot"}, -- 35
	{t = "最怕的不是敌人打进来，是还没打，自己先撑不住。", mark = "cut", face = "dot"}, -- 36
	{t = "倭寇也来过。有一回站在城外看了半晌，看见田是绿的、人还在忙，就退了。", mark = "wall", face = "curvy"}, -- 37
	{t = "田看完了，我接下来带你看看敌台。", mark = "", face = "wave"} -- 38
} -- 38
function ____exports.startLevel3Post(onDone, startAt) -- 41
	Director.clearColor = C_PAGE -- 42
	local frame = createSceneFrame(0.18) -- 43
	local root = frame.inner -- 44
	local function block(p, x, y, w, h, c, a) -- 47
		local s = Sprite("Image/StartUI/white.png") -- 51
		s.size = Size(w, h) -- 52
		s.anchor = Vec2(0, 1) -- 53
		s.color = c -- 54
		s.opacity = a -- 55
		s.position = Vec2(x, H - y) -- 56
		s:addTo(p) -- 57
		return s -- 58
	end -- 47
	local function img(p, f, x, y, w, h) -- 60
		local s = Sprite(f) -- 61
		s.size = Size(w, h) -- 62
		s.anchor = Vec2(0, 1) -- 63
		s.position = Vec2(x, H - y) -- 64
		s:addTo(p) -- 65
		return s -- 66
	end -- 60
	local function toChars(str) -- 69
		local out = {} -- 70
		local i = 0 -- 71
		while i < #str do -- 71
			local c = __TS__StringCharCodeAt(str, i) -- 73
			local n = 1 -- 74
			if c >= 240 then -- 74
				n = 4 -- 75
			elseif c >= 224 then -- 75
				n = 3 -- 76
			elseif c >= 192 then -- 76
				n = 2 -- 77
			end -- 77
			out[#out + 1] = __TS__StringSubstr(str, i, n) -- 78
			i = i + n -- 79
		end -- 79
		return out -- 81
	end -- 69
	local function label(p, font, size, c, x, y, ax, ls) -- 83
		local lb = Label(((font .. ";") .. tostring(math.floor(size * 2 + 0.5))) .. ";true") -- 87
		lb.color = c -- 88
		lb.anchor = Vec2(ax, 1) -- 89
		lb.scaleX = 0.5 -- 90
		lb.scaleY = 0.5 -- 91
		lb.position = Vec2(x, H - y + size) -- 92
		if ls > 0 then -- 92
			lb.spacing = math.floor(ls * 2 + 0.5) -- 93
		end -- 93
		lb:addTo(p) -- 94
		return lb -- 95
	end -- 83
	img( -- 99
		root, -- 99
		S .. "lv2_paper.png", -- 99
		0, -- 99
		0, -- 99
		W, -- 99
		H + 4 -- 99
	) -- 99
	block( -- 100
		root, -- 100
		56, -- 100
		44, -- 100
		W - 112, -- 100
		1.5, -- 100
		C_INK, -- 100
		0.55 -- 100
	) -- 100
	local hd = label( -- 101
		root, -- 101
		FONT_B, -- 101
		18, -- 101
		C_INK2, -- 101
		56, -- 101
		68, -- 101
		0, -- 101
		0.4 -- 101
	) -- 101
	hd.text = "三 · 引流　关后" -- 102
	local SC_X = 120 -- 105
	local SC_Y = 104 -- 105
	local SC_W = 1040 -- 105
	local SC_H = 330 -- 105
	block( -- 106
		root, -- 106
		SC_X + 9, -- 106
		SC_Y + 9, -- 106
		SC_W, -- 106
		SC_H, -- 106
		C_INK, -- 106
		0.9 -- 106
	) -- 106
	img( -- 107
		root, -- 107
		S .. "lv3_post_scene.png", -- 107
		SC_X, -- 107
		SC_Y, -- 107
		SC_W, -- 107
		SC_H -- 107
	) -- 107
	block( -- 108
		root, -- 108
		SC_X, -- 108
		SC_Y, -- 108
		SC_W, -- 108
		3, -- 108
		C_INK, -- 108
		1 -- 108
	) -- 108
	block( -- 109
		root, -- 109
		SC_X, -- 109
		SC_Y + SC_H - 3, -- 109
		SC_W, -- 109
		3, -- 109
		C_INK, -- 109
		1 -- 109
	) -- 109
	block( -- 110
		root, -- 110
		SC_X, -- 110
		SC_Y, -- 110
		3, -- 110
		SC_H, -- 110
		C_INK, -- 110
		1 -- 110
	) -- 110
	block( -- 111
		root, -- 111
		SC_X + SC_W - 3, -- 111
		SC_Y, -- 111
		3, -- 111
		SC_H, -- 111
		C_INK, -- 111
		1 -- 111
	) -- 111
	block( -- 112
		root, -- 112
		SC_X - 3, -- 112
		SC_Y - 3, -- 112
		74, -- 112
		30, -- 112
		C_VERM, -- 112
		1 -- 112
	) -- 112
	label( -- 113
		root, -- 113
		FONT_B, -- 113
		17, -- 113
		C_CARD, -- 113
		SC_X + 14, -- 113
		SC_Y + 24, -- 113
		0, -- 113
		1.6 -- 113
	).text = "图一" -- 113
	local markKeys = { -- 118
		"gate", -- 118
		"main", -- 118
		"field", -- 118
		"cut", -- 118
		"wall" -- 118
	} -- 118
	local marks = { -- 119
		gate = {}, -- 119
		main = {}, -- 119
		field = {}, -- 119
		cut = {}, -- 119
		wall = {} -- 119
	} -- 119
	local function mk(k, n) -- 120
		local ____marks_k_0 = marks[k] -- 120
		____marks_k_0[#____marks_k_0 + 1] = n -- 120
	end -- 120
	local function mBlock(k, x, y, w, h, c, al) -- 122
		local sp = block( -- 123
			root, -- 123
			SC_X + x, -- 123
			SC_Y + y, -- 123
			w, -- 123
			h, -- 123
			c, -- 123
			al -- 123
		) -- 123
		mk(k, sp) -- 124
		return sp -- 125
	end -- 122
	local function mFrame(k, x, y, w, h, al) -- 127
		mBlock( -- 128
			k, -- 128
			x, -- 128
			y, -- 128
			w, -- 128
			3, -- 128
			C_VERM, -- 128
			al -- 128
		) -- 128
		mBlock( -- 129
			k, -- 129
			x, -- 129
			y + h - 3, -- 129
			w, -- 129
			3, -- 129
			C_VERM, -- 129
			al -- 129
		) -- 129
		mBlock( -- 130
			k, -- 130
			x, -- 130
			y, -- 130
			3, -- 130
			h, -- 130
			C_VERM, -- 130
			al -- 130
		) -- 130
		mBlock( -- 131
			k, -- 131
			x + w - 3, -- 131
			y, -- 131
			3, -- 131
			h, -- 131
			C_VERM, -- 131
			al -- 131
		) -- 131
	end -- 127
	local function mTip(k, x, y, str, sub) -- 134
		local mainW = #toChars(str) * 23 -- 135
		local subW = #sub > 0 and #toChars(sub) * 16 + 12 or 0 -- 136
		local w = 18 + mainW + subW + 18 -- 137
		mBlock( -- 138
			k, -- 138
			x - 4, -- 138
			y - 4, -- 138
			w + 8, -- 138
			50, -- 138
			C_INK, -- 138
			0.88 -- 138
		) -- 138
		mBlock( -- 139
			k, -- 139
			x, -- 139
			y, -- 139
			w, -- 139
			42, -- 139
			C_CARD, -- 139
			0.99 -- 139
		) -- 139
		mFrame( -- 140
			k, -- 140
			x, -- 140
			y, -- 140
			w, -- 140
			42, -- 140
			1 -- 140
		) -- 140
		local lb = label( -- 141
			root, -- 141
			FONT_B, -- 141
			22, -- 141
			C_TXT, -- 141
			SC_X + x + 16, -- 141
			SC_Y + y + 32, -- 141
			0, -- 141
			0.4 -- 141
		) -- 141
		lb.text = str -- 142
		mk(k, lb) -- 143
		if #sub > 0 then -- 143
			local sb = label( -- 145
				root, -- 145
				FONT_R, -- 145
				15, -- 145
				Color(76, 99, 87, 230), -- 145
				SC_X + x + 16 + mainW + 12, -- 145
				SC_Y + y + 31, -- 145
				0, -- 145
				0.2 -- 145
			) -- 145
			sb.text = sub -- 146
			mk(k, sb) -- 147
		end -- 147
	end -- 134
	mFrame( -- 152
		"gate", -- 152
		544, -- 152
		36, -- 152
		160, -- 152
		100, -- 152
		1 -- 152
	) -- 152
	mBlock( -- 153
		"gate", -- 153
		566, -- 153
		96, -- 153
		112, -- 153
		7, -- 153
		C_VERM, -- 153
		1 -- 153
	) -- 153
	mTip( -- 154
		"gate", -- 154
		336, -- 154
		56, -- 154
		"桥在上，闸在下", -- 154
		"同一个门洞" -- 154
	) -- 154
	mFrame( -- 157
		"main", -- 157
		594, -- 157
		104, -- 157
		64, -- 157
		120, -- 157
		1 -- 157
	) -- 157
	mTip( -- 158
		"main", -- 158
		668, -- 158
		116, -- 158
		"水就落在这条渠里", -- 158
		"从水门直贯到底" -- 158
	) -- 158
	mFrame( -- 161
		"field", -- 161
		114, -- 161
		144, -- 161
		390, -- 161
		170, -- 161
		1 -- 161
	) -- 161
	mFrame( -- 162
		"field", -- 162
		514, -- 162
		144, -- 162
		398, -- 162
		170, -- 162
		1 -- 162
	) -- 162
	mTip( -- 163
		"field", -- 163
		138, -- 163
		112, -- 163
		"八块田，一百多亩", -- 163
		"一年两季" -- 163
	) -- 163
	mFrame( -- 166
		"cut", -- 166
		594, -- 166
		104, -- 166
		64, -- 166
		150, -- 166
		1 -- 166
	) -- 166
	mTip( -- 167
		"cut", -- 167
		676, -- 167
		190, -- 167
		"就这一条渠", -- 167
		"闸一落，水也断" -- 167
	) -- 167
	mFrame( -- 170
		"wall", -- 170
		96, -- 170
		70, -- 170
		300, -- 170
		44, -- 170
		1 -- 170
	) -- 170
	mTip( -- 171
		"wall", -- 171
		96, -- 171
		18, -- 171
		"站这儿往下看", -- 171
		"田是绿的，人还在忙" -- 171
	) -- 171
	for ____, k in ipairs(markKeys) do -- 173
		for ____, sp in ipairs(marks[k]) do -- 173
			sp.visible = false -- 173
		end -- 173
	end -- 173
	local SAY_X = 120 -- 176
	local SAY_Y = 530 -- 176
	local SAY_W = 744 -- 176
	local SAY_H = 172 -- 176
	block( -- 177
		root, -- 177
		SAY_X + 7, -- 177
		SAY_Y + 7, -- 177
		SAY_W, -- 177
		SAY_H, -- 177
		C_INK, -- 177
		0.94 -- 177
	) -- 177
	block( -- 178
		root, -- 178
		SAY_X, -- 178
		SAY_Y, -- 178
		SAY_W, -- 178
		SAY_H, -- 178
		C_CARD, -- 178
		1 -- 178
	) -- 178
	block( -- 179
		root, -- 179
		SAY_X, -- 179
		SAY_Y, -- 179
		SAY_W, -- 179
		2.5, -- 179
		C_INK, -- 179
		1 -- 179
	) -- 179
	block( -- 180
		root, -- 180
		SAY_X, -- 180
		SAY_Y + SAY_H - 2.5, -- 180
		SAY_W, -- 180
		2.5, -- 180
		C_INK, -- 180
		1 -- 180
	) -- 180
	block( -- 181
		root, -- 181
		SAY_X, -- 181
		SAY_Y, -- 181
		2.5, -- 181
		SAY_H, -- 181
		C_INK, -- 181
		1 -- 181
	) -- 181
	block( -- 182
		root, -- 182
		SAY_X + SAY_W - 2.5, -- 182
		SAY_Y, -- 182
		2.5, -- 182
		SAY_H, -- 182
		C_INK, -- 182
		1 -- 182
	) -- 182
	block( -- 184
		root, -- 184
		136, -- 184
		509, -- 184
		96, -- 184
		34, -- 184
		C_VERM, -- 184
		1 -- 184
	) -- 184
	label( -- 185
		root, -- 185
		FONT_B, -- 185
		17, -- 185
		C_CARD, -- 185
		184, -- 185
		535, -- 185
		0.5, -- 185
		4.2 -- 185
	).text = "王 梓" -- 185
	local TX_SIZE = 32 -- 190
	local TX_STEP = TX_SIZE * 0.78 + 1 -- 190
	local TX_LINE = TX_SIZE + 14 -- 190
	local TX_COLS = math.floor((SAY_W - 68) / TX_STEP) -- 191
	local TX_N = TX_COLS * 3 -- 192
	local txChars = {} -- 193
	do -- 193
		local i = 0 -- 194
		while i < TX_N do -- 194
			local lb = label( -- 195
				root, -- 195
				FONT_R, -- 195
				TX_SIZE, -- 195
				C_INK, -- 195
				156, -- 195
				610, -- 195
				0, -- 195
				0.4 -- 195
			) -- 195
			lb.visible = false -- 196
			txChars[#txChars + 1] = lb -- 197
			i = i + 1 -- 194
		end -- 194
	end -- 194
	local seqLb = label( -- 199
		root, -- 199
		FONT_R, -- 199
		15, -- 199
		Color(76, 99, 87, 190), -- 199
		842, -- 199
		548, -- 199
		1, -- 199
		0 -- 199
	) -- 199
	local tipLb = label( -- 200
		root, -- 200
		FONT_R, -- 200
		16, -- 200
		Color(36, 73, 70, 175), -- 200
		842, -- 200
		690, -- 200
		1, -- 200
		0 -- 200
	) -- 200
	tipLb.text = "点击继续　P 跳过" -- 201
	local cap = label( -- 203
		root, -- 203
		FONT_R, -- 203
		16, -- 203
		Color(76, 99, 87, 210), -- 203
		756, -- 203
		462, -- 203
		1, -- 203
		0.6 -- 203
	) -- 203
	cap.text = "永昌堡 · 城北水田（示意）" -- 204
	block( -- 206
		root, -- 206
		0, -- 206
		700, -- 206
		W, -- 206
		1.5, -- 206
		C_INK, -- 206
		0.5 -- 206
	) -- 206
	local foot = label( -- 207
		root, -- 207
		FONT_R, -- 207
		13, -- 207
		Color(36, 73, 70, 120), -- 207
		120, -- 207
		742, -- 207
		0, -- 207
		1.2 -- 207
	) -- 207
	foot.text = "永昌堡 · 嘉靖四十年 · 五月 · 夜尽" -- 208
	local WZ_X = 1030 -- 211
	local WZ_Y = 404 -- 211
	local WZ_W = 250 -- 211
	local WZ_H = 344 -- 211
	local faces = {} -- 212
	for ____, n in ipairs({ -- 213
		"smile", -- 213
		"laugh", -- 213
		"dot", -- 213
		"wave", -- 213
		"curvy" -- 213
	}) do -- 213
		local sp = img( -- 214
			root, -- 214
			((S .. "face_") .. n) .. ".png", -- 214
			WZ_X, -- 214
			WZ_Y, -- 214
			WZ_W, -- 214
			WZ_H -- 214
		) -- 214
		sp.visible = false -- 215
		faces[n] = sp -- 216
	end -- 216
	local idx = -1 -- 220
	local typed = 0 -- 221
	local textLen = 0 -- 222
	local typing = false -- 223
	local done = false -- 224
	local state = 0 -- 225
	local time = 0 -- 226
	local born = 0 -- 227
	local function showLine(i) -- 229
		idx = i -- 230
		typed = 0 -- 231
		typing = true -- 232
		local L = LINES[i + 1] -- 233
		local chars = toChars(L.t) -- 234
		textLen = math.min(TX_N, #chars) -- 235
		do -- 235
			local n = 0 -- 236
			while n < TX_N do -- 236
				local lb = txChars[n + 1] -- 237
				if n < textLen then -- 237
					local col = n % TX_COLS -- 239
					local row = math.floor(n / TX_COLS) -- 240
					lb.text = chars[n + 1] -- 241
					lb.position = Vec2(156 + col * TX_STEP, H - (610 + row * TX_LINE) + TX_SIZE) -- 242
					lb.visible = false -- 243
				else -- 243
					lb.visible = false -- 245
				end -- 245
				n = n + 1 -- 236
			end -- 236
		end -- 236
		local a = i + 1 -- 248
		seqLb.text = (((a < 10 and "0" or "") .. tostring(a)) .. " / ") .. tostring(#LINES) -- 249
		for ____, k in ipairs(markKeys) do -- 250
			local on = k == L.mark -- 251
			for ____, sp in ipairs(marks[k]) do -- 252
				sp.visible = on -- 252
			end -- 252
		end -- 252
		for k in pairs(faces) do -- 254
			faces[k].visible = k == L.face -- 254
		end -- 254
		tipLb.text = i == #LINES - 1 and "点击收尾　P 跳过" or "点击继续　P 跳过" -- 255
	end -- 229
	local function finishTyping() -- 258
		typing = false -- 259
		typed = textLen -- 260
		do -- 260
			local n = 0 -- 261
			while n < textLen do -- 261
				txChars[n + 1].visible = true -- 261
				n = n + 1 -- 261
			end -- 261
		end -- 261
	end -- 258
	local function endAll() -- 264
		if state >= 2 then -- 264
			return -- 265
		end -- 265
		state = 2 -- 266
		frame:destroy() -- 267
		onDone() -- 268
	end -- 264
	local function tap() -- 271
		if state ~= 0 then -- 271
			return -- 272
		end -- 272
		if idx < 0 then -- 272
			showLine(0) -- 273
			return -- 273
		end -- 273
		if typing then -- 273
			finishTyping() -- 274
			return -- 274
		end -- 274
		if idx + 1 < #LINES then -- 274
			showLine(idx + 1) -- 275
			return -- 275
		end -- 275
		if not done then -- 275
			done = true -- 276
			endAll() -- 276
		end -- 276
	end -- 271
	frame.input:onTapped(function() -- 279
		tap() -- 279
		return true -- 279
	end) -- 279
	showLine(startAt ~= nil and startAt or 0) -- 281
	state = 0 -- 282
	root:onKeyDown(function(key) -- 284
		if key == "P" then -- 284
			if born < 0.35 then -- 284
				return true -- 286
			end -- 286
			endAll() -- 287
			return true -- 288
		end -- 288
		if key == "Space" or key == "Return" then -- 288
			tap() -- 290
			return true -- 290
		end -- 290
		return false -- 291
	end) -- 284
	local function update(dt) -- 295
		time = time + dt -- 296
		born = born + dt -- 297
		local bob = math.sin(time * 1.5) * 2.4 -- 298
		local sway = typing and math.sin(time * 11) * 1.1 or 0 -- 299
		for k in pairs(faces) do -- 300
			do -- 300
				local sp = faces[k] -- 301
				if not sp.visible then -- 301
					goto __continue53 -- 302
				end -- 302
				sp.position = Vec2(WZ_X + sway, H - WZ_Y + bob) -- 303
			end -- 303
			::__continue53:: -- 303
		end -- 303
		if not typing or idx < 0 then -- 303
			return -- 305
		end -- 305
		typed = typed + dt * 31 -- 306
		if typed >= textLen then -- 306
			finishTyping() -- 307
			return -- 307
		end -- 307
		local n = math.floor(typed) -- 308
		do -- 308
			local k = 0 -- 309
			while k < n do -- 309
				txChars[k + 1].visible = true -- 309
				k = k + 1 -- 309
			end -- 309
		end -- 309
	end -- 295
	root:schedule(function(dt) -- 311
		update(dt) -- 311
		return false -- 311
	end) -- 311
	return { -- 313
		root = root, -- 314
		close = function() -- 315
			frame:destroy() -- 315
		end, -- 315
		isDone = function() return state == 2 end -- 316
	} -- 316
end -- 41
return ____exports -- 41