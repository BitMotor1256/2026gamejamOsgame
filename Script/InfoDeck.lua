-- [ts]: InfoDeck.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 11
local Label = ____Dora.Label -- 12
local Node = ____Dora.Node -- 13
local Size = ____Dora.Size -- 14
local Sprite = ____Dora.Sprite -- 15
local Vec2 = ____Dora.Vec2 -- 16
local W = 1280 -- 20
local H = 804 -- 21
local REG = "Font/SourceHanSerifSC-Regular.ttf" -- 22
local MED = "Font/SourceHanSerifSC-Medium.ttf" -- 23
local BOLD = "Font/SourceHanSerifSC-SemiBold.ttf" -- 24
local C_PAPER = Color(233, 223, 196, 255) -- 26
local C_CARD = Color(252, 247, 232, 255) -- 27
local C_INK = Color(36, 73, 70, 255) -- 28
local C_VERM = Color(163, 59, 42, 255) -- 29
local C_MUTE = Color(76, 99, 87, 255) -- 30
local C_SHADOW = Color(58, 88, 83, 255) -- 32
local PANEL = {x = 56, y = 126, w = 444, h = 500} -- 35
local COL_X = 540 -- 37
local COL_W = 540 -- 38
local SAY = {x = 540, y = 466, w = 378, h = 128} -- 40
local FACE_LIST = { -- 43
	"smile", -- 43
	"laugh", -- 43
	"dot", -- 43
	"wave", -- 43
	"curvy", -- 43
	"shy", -- 43
	"shyact", -- 43
	"dizzy" -- 43
} -- 43
local FACE_W = 250 -- 44
local FACE_H = 344 -- 45
local WZ_X = W - 14 - FACE_W -- 46
local WZ_Y = 34 -- 47
function ____exports.startDeck(root, header, slides, onFinish) -- 49
	local layer = Node() -- 55
	layer.anchor = Vec2(0, 0) -- 56
	layer.size = Size(W, H) -- 57
	layer.position = Vec2(0, 0) -- 58
	layer:addTo(root) -- 59
	local SS = 2 -- 62
	local function block(x, y, w, h, c, alpha) -- 65
		if alpha == nil then -- 65
			alpha = 1 -- 66
		end -- 66
		local s = Sprite("Image/StartUI/white.png") -- 68
		s.anchor = Vec2(0.5, 0.5) -- 69
		s.size = Size(w, h) -- 70
		s.color = c -- 71
		s.opacity = alpha -- 72
		s.position = Vec2(x + w / 2, H - (y + h / 2)) -- 73
		s:addTo(layer) -- 74
		return s -- 75
	end -- 65
	local function text(font, size, color, x, y, width, gap) -- 79
		local k = size < 80 and SS or 1 -- 83
		local lb = Label(((font .. ";") .. tostring(math.floor(size * k + 0.5))) .. ";true") -- 84
		lb.color = color -- 85
		if width > 0 then -- 85
			lb.textWidth = width * k -- 87
			lb.lineGap = gap * k -- 88
		end -- 88
		lb.anchor = Vec2(0, 1) -- 90
		lb.scaleX = 1 / k -- 91
		lb.scaleY = 1 / k -- 92
		lb.position = Vec2(x, H - y) -- 93
		lb:addTo(layer) -- 94
		return lb -- 95
	end -- 79
	block( -- 99
		0, -- 99
		0, -- 99
		W, -- 99
		H, -- 99
		C_PAPER -- 99
	) -- 99
	local grain = Sprite("Image/StartUI/paper_grain.png") -- 101
	grain.anchor = Vec2(0, 1) -- 102
	grain.size = Size(W, H) -- 103
	grain.position = Vec2(0, H) -- 104
	grain:addTo(layer) -- 105
	block( -- 108
		56, -- 108
		44, -- 108
		W - 112, -- 108
		1.5, -- 108
		C_INK, -- 108
		0.69 -- 108
	) -- 108
	local hdL = text( -- 109
		REG, -- 109
		17, -- 109
		C_MUTE, -- 109
		56, -- 109
		56, -- 109
		700, -- 109
		0 -- 109
	) -- 109
	hdL.text = header -- 110
	hdL.spacing = 2 -- 111
	local hdR = Label(((REG .. ";") .. tostring(math.floor(15 * SS + 0.5))) .. ";true") -- 113
	hdR.color = C_MUTE -- 114
	hdR.anchor = Vec2(1, 1) -- 115
	hdR.scaleX = 1 / SS -- 116
	hdR.scaleY = 1 / SS -- 117
	hdR.position = Vec2(W - 56, H - 54) -- 118
	hdR:addTo(layer) -- 119
	local dotA = block( -- 122
		W - 76, -- 122
		78, -- 122
		7, -- 122
		7, -- 122
		C_VERM -- 122
	) -- 122
	dotA.angle = 45 -- 123
	local dotB = block( -- 124
		W - 56, -- 124
		78, -- 124
		7, -- 124
		7, -- 124
		C_INK, -- 124
		0.35 -- 124
	) -- 124
	dotB.angle = 45 -- 125
	block( -- 128
		PANEL.x + 9, -- 128
		PANEL.y + 9, -- 128
		PANEL.w, -- 128
		PANEL.h, -- 128
		C_SHADOW -- 128
	) -- 128
	block( -- 129
		PANEL.x - 3, -- 129
		PANEL.y - 3, -- 129
		PANEL.w + 6, -- 129
		PANEL.h + 6, -- 129
		C_INK -- 129
	) -- 129
	block( -- 130
		PANEL.x, -- 130
		PANEL.y, -- 130
		PANEL.w, -- 130
		PANEL.h, -- 130
		C_CARD -- 130
	) -- 130
	local numLb = Label(BOLD .. ";172;false") -- 135
	numLb.color = C_VERM -- 136
	numLb.anchor = Vec2(0.5, 1) -- 137
	numLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 322) -- 138
	numLb:addTo(layer) -- 139
	local unitLb = Label(((REG .. ";") .. tostring(math.floor(22 * SS + 0.5))) .. ";true") -- 142
	unitLb.color = C_INK -- 143
	unitLb.anchor = Vec2(0.5, 1) -- 144
	unitLb.scaleX = 1 / SS -- 145
	unitLb.scaleY = 1 / SS -- 146
	unitLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 500) -- 147
	unitLb:addTo(layer) -- 148
	local ttlLb = text( -- 151
		BOLD, -- 151
		33, -- 151
		C_INK, -- 151
		COL_X, -- 151
		134, -- 151
		COL_W, -- 151
		14 -- 151
	) -- 151
	local bodyLb = text( -- 152
		MED, -- 152
		21, -- 152
		C_INK, -- 152
		COL_X, -- 152
		232, -- 152
		COL_W, -- 152
		18 -- 152
	) -- 152
	local srcLb = text( -- 153
		REG, -- 153
		14, -- 153
		C_MUTE, -- 153
		56, -- 153
		648, -- 153
		444, -- 153
		6 -- 153
	) -- 153
	local faces = {} -- 156
	do -- 156
		local i = 0 -- 157
		while i < #FACE_LIST do -- 157
			local sp = Sprite(("Image/StartUI/face_" .. FACE_LIST[i + 1]) .. ".png") -- 158
			sp.anchor = Vec2(0.5, 0) -- 159
			sp.size = Size(FACE_W, FACE_H) -- 160
			sp.position = Vec2(WZ_X + FACE_W / 2, WZ_Y) -- 161
			sp.opacity = i == 0 and 1 or 0 -- 162
			sp:addTo(layer) -- 163
			faces[#faces + 1] = sp -- 164
			i = i + 1 -- 157
		end -- 157
	end -- 157
	local faceCur = 0 -- 166
	local pageT = 0 -- 167
	block( -- 170
		SAY.x + 6, -- 170
		SAY.y + 6, -- 170
		SAY.w, -- 170
		SAY.h, -- 170
		C_SHADOW -- 170
	) -- 170
	block( -- 171
		SAY.x - 2.5, -- 171
		SAY.y - 2.5, -- 171
		SAY.w + 5, -- 171
		SAY.h + 5, -- 171
		C_INK -- 171
	) -- 171
	block( -- 172
		SAY.x, -- 172
		SAY.y, -- 172
		SAY.w, -- 172
		SAY.h, -- 172
		C_CARD -- 172
	) -- 172
	local whoLb = text( -- 174
		MED, -- 174
		14, -- 174
		C_MUTE, -- 174
		SAY.x + 22, -- 174
		SAY.y + 28, -- 174
		200, -- 174
		0 -- 174
	) -- 174
	whoLb.text = "王 梓" -- 175
	whoLb.spacing = 6 -- 176
	local sayLb = text( -- 180
		MED, -- 180
		23, -- 180
		C_INK, -- 180
		SAY.x + 22, -- 180
		SAY.y + 68, -- 180
		(SAY.w - 44) * 0.72, -- 180
		13 -- 180
	) -- 180
	local tipLb = Label(((REG .. ";") .. tostring(math.floor(15 * SS + 0.5))) .. ";true") -- 182
	tipLb.color = C_INK -- 183
	tipLb.anchor = Vec2(1, 1) -- 184
	tipLb.scaleX = 1 / SS -- 185
	tipLb.scaleY = 1 / SS -- 186
	tipLb.position = Vec2(SAY.x + SAY.w - 18, H - (SAY.y + SAY.h - 16)) -- 187
	tipLb.opacity = 0.6 -- 188
	tipLb.text = "点击继续" -- 189
	tipLb:addTo(layer) -- 190
	local idx = -1 -- 193
	local fadeT = 0 -- 194
	local finished = false -- 195
	local total = #slides -- 197
	local pageNodes = {} -- 200
	local function regPage(n) -- 201
		pageNodes[#pageNodes + 1] = n -- 201
	end -- 201
	regPage(numLb) -- 202
	regPage(unitLb) -- 203
	regPage(ttlLb) -- 204
	regPage(bodyLb) -- 205
	regPage(srcLb) -- 206
	regPage(sayLb) -- 207
	local function setFace(name) -- 209
		local k = name == nil and 0 or __TS__ArrayIndexOf(FACE_LIST, name) -- 210
		faceCur = k >= 0 and k or 0 -- 211
	end -- 209
	local function show(i) -- 214
		local s = slides[i + 1] -- 215
		numLb.text = s.num -- 216
		unitLb.text = s.unit -- 217
		ttlLb.text = s.title -- 218
		bodyLb.text = s.body -- 219
		srcLb.text = s.src -- 220
		sayLb.text = s.say -- 221
		hdR.text = ((((i + 1 < 10 and "0" or "") .. tostring(i + 1)) .. " / ") .. (total < 10 and "0" or "")) .. tostring(total) -- 222
		dotA.color = i == 0 and C_VERM or C_INK -- 223
		dotA.opacity = i == 0 and 1 or 0.35 -- 224
		dotB.color = i == 1 and C_VERM or C_INK -- 225
		dotB.opacity = i == 1 and 1 or 0.35 -- 226
		setFace(i == 0 and "dot" or "smile") -- 227
		fadeT = 0 -- 228
	end -- 214
	local function skip() -- 232
		if finished then -- 232
			return -- 233
		end -- 233
		finished = true -- 234
		onFinish() -- 235
	end -- 232
	local function next() -- 238
		if finished then -- 238
			return -- 239
		end -- 239
		idx = idx + 1 -- 240
		if idx >= total then -- 240
			finished = true -- 242
			onFinish() -- 243
			return -- 244
		end -- 244
		show(idx) -- 246
	end -- 238
	local function update(dt) -- 249
		pageT = pageT + dt -- 250
		if fadeT < 1 then -- 250
			fadeT = math.min(1, fadeT + dt * 5) -- 254
			local e = 1 - (1 - fadeT) ^ 3 -- 255
			for ____, n in ipairs(pageNodes) do -- 256
				n.opacity = e -- 256
			end -- 256
			local dy = -12 * (1 - e) -- 257
			numLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 322 + dy) -- 258
			unitLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 500 + dy) -- 259
		end -- 259
		local bob = math.sin(pageT * 1.57) * 2.4 -- 263
		do -- 263
			local i = 0 -- 264
			while i < #faces do -- 264
				faces[i + 1].position = Vec2(WZ_X + FACE_W / 2, WZ_Y + bob) -- 265
				local want = i == faceCur and 1 or 0 -- 266
				local cur = faces[i + 1].opacity -- 267
				if math.abs(want - cur) > 0.01 then -- 267
					faces[i + 1].opacity = cur + (want - cur) * math.min(1, dt * 9) -- 269
				else -- 269
					faces[i + 1].opacity = want -- 271
				end -- 271
				i = i + 1 -- 264
			end -- 264
		end -- 264
	end -- 249
	local function destroy() -- 276
		layer:removeFromParent() -- 276
	end -- 276
	next() -- 278
	return { -- 280
		next = function() -- 281
			next() -- 281
		end, -- 281
		update = function(dt) -- 282
			update(dt) -- 282
		end, -- 282
		destroy = function() -- 283
			destroy() -- 283
		end, -- 283
		isFinished = function() return finished end, -- 284
		skip = function() -- 285
			skip() -- 285
		end -- 285
	} -- 285
end -- 49
return ____exports -- 49