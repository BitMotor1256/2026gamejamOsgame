-- [ts]: TitleScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 9
local Director = ____Dora.Director -- 10
local Node = ____Dora.Node -- 12
local Size = ____Dora.Size -- 13
local Sprite = ____Dora.Sprite -- 14
local Vec2 = ____Dora.Vec2 -- 15
local View = ____Dora.View -- 16
local ____Level1Scene = require("Script.Level1Scene") -- 18
local startLevel1 = ____Level1Scene.startLevel1 -- 18
local ____Nav = require("Script.Nav") -- 19
local registerTitle = ____Nav.registerTitle -- 19
local W = 1280 -- 21
local H = 804 -- 22
local SHEET = "Image/StartUI/" -- 23
local SHADOW = 6 -- 24
local C_WHITE = Color(255, 255, 255, 255) -- 28
local C_DIM = Color(206, 206, 206, 255) -- 29
local C_INK_SHADOW = Color(34, 53, 47, 235) -- 30
local function toRoot(p) -- 33
	return Vec2(p.x + p.w / 2, H - (p.y + p.h / 2)) -- 34
end -- 33
local function approach(v, target, step) -- 37
	if v < target then -- 37
		return math.min(target, v + step) -- 38
	end -- 38
	if v > target then -- 38
		return math.max(target, v - step) -- 39
	end -- 39
	return v -- 40
end -- 37
local function mixColor(a, b, t) -- 43
	return Color( -- 44
		math.floor(a.r + (b.r - a.r) * t + 0.5), -- 45
		math.floor(a.g + (b.g - a.g) * t + 0.5), -- 46
		math.floor(a.b + (b.b - a.b) * t + 0.5), -- 47
		math.floor(a.a + (b.a - a.a) * t + 0.5) -- 48
	) -- 48
end -- 43
local ENTER_RECT = {x = 104, y = 492, w = 214, h = 68} -- 53
local SELECT_RECT = {x = 104, y = 572, w = 77, h = 44} -- 54
local QUIT_RECT = {x = 191, y = 572, w = 78, h = 44} -- 55
function ____exports.startTitleScene() -- 69
	Director.clearColor = Color(233, 223, 196, 255) -- 70
	local root = Node() -- 72
	root.anchor = Vec2(0.5, 0.5) -- 73
	root.size = Size(W, H) -- 74
	root.position = Vec2(0, 0) -- 75
	root:addTo(Director.ui) -- 76
	local function sprite(file, p) -- 79
		local s = Sprite(SHEET .. file) -- 80
		s.anchor = Vec2(0.5, 0.5) -- 81
		s.size = Size(p.w, p.h) -- 82
		s.position = toRoot(p) -- 83
		s:addTo(root) -- 84
		return s -- 85
	end -- 79
	sprite("bg.png", {x = 0, y = 0, w = 1280, h = 804}) -- 89
	local clouds = sprite("clouds.png", {x = 150, y = 105, w = 806, h = 188}) -- 91
	local birds = sprite("birds.png", {x = 279, y = 200, w = 53, h = 17}) -- 92
	local glow = sprite("glow.png", {x = 627, y = 565, w = 26, h = 135}) -- 93
	local flagFrames = { -- 95
		sprite("flag_0.png", {x = 267, y = 303, w = 656, h = 102}), -- 96
		sprite("flag_1.png", {x = 267, y = 303, w = 656, h = 102}), -- 97
		sprite("flag_2.png", {x = 267, y = 303, w = 656, h = 102}) -- 98
	} -- 98
	__TS__ArrayForEach( -- 100
		flagFrames, -- 100
		function(____, f, i) -- 100
			f.visible = i == 0 -- 100
		end -- 100
	) -- 100
	sprite("side.png", {x = 104, y = 29, w = 14, h = 255}) -- 103
	local titleChars = { -- 105
		sprite("title_0.png", {x = 141, y = 20, w = 58, h = 56}), -- 106
		sprite("title_1.png", {x = 147, y = 89, w = 49, h = 55}), -- 107
		sprite("title_2.png", {x = 142, y = 156, w = 57, h = 57}), -- 108
		sprite("title_3.png", {x = 141, y = 225, w = 58, h = 55}), -- 109
		sprite("title_4.png", {x = 141, y = 292, w = 58, h = 54}) -- 110
	} -- 110
	local function mkButton(file, p) -- 114
		local sh = Sprite(SHEET .. "white.png") -- 115
		sh.anchor = Vec2(0.5, 0.5) -- 116
		sh.size = Size(p.w, p.h) -- 117
		sh.color = C_INK_SHADOW -- 118
		sh.position = Vec2(p.x + SHADOW + p.w / 2, H - (p.y + SHADOW + p.h / 2)) -- 120
		sh:addTo(root) -- 121
		local panel = sprite(file, p) -- 123
		local base = Vec2(p.x + p.w / 2, H - (p.y + p.h / 2)) -- 124
		return {panel = panel, base = base} -- 125
	end -- 114
	local bEnter = mkButton("btn_enter.png", ENTER_RECT) -- 128
	local bSelect = mkButton("btn_select.png", SELECT_RECT) -- 129
	local bQuit = mkButton("btn_quit.png", QUIT_RECT) -- 130
	local panels = {bEnter.panel, bSelect.panel, bQuit.panel} -- 131
	local bases = {bEnter.base, bSelect.base, bQuit.base} -- 132
	local hov = {0, 0, 0} -- 133
	local prs = {0, 0, 0} -- 134
	sprite("hint.png", {x = 104, y = 633, w = 167, h = 12}) -- 136
	sprite("wangzi.png", {x = 869, y = 420, w = 377, h = 384}) -- 137
	local modal = sprite("modal_select.png", {x = 393, y = 174, w = 504, h = 467}) -- 140
	modal.visible = false -- 141
	local input = Node() -- 144
	input.size = Size(W, H) -- 145
	input.anchor = Vec2(0, 0) -- 146
	input.position = Vec2(0, 0) -- 147
	input:addTo(root) -- 148
	input.touchEnabled = true -- 149
	local curScale = 1 -- 151
	local time = 0 -- 152
	local sel = -1 -- 153
	local pressIdx = -1 -- 154
	local pendingIdx = -1 -- 155
	local pendingT = 0 -- 156
	local state = 0 -- 157
	local fade = 0 -- 158
	local exitTimer = 0 -- 159
	local entered = false -- 160
	local enterWait = 0 -- 161
	local cloudY = clouds.position.y -- 164
	local birdY = birds.position.y -- 165
	local cloudHome = clouds.position.x -- 166
	local birdHome = birds.position.x -- 167
	local cloudX = cloudHome -- 168
	local birdX = birdHome -- 169
	local function hitTest(cx, cy) -- 171
		if state ~= 0 then -- 171
			return -1 -- 172
		end -- 172
		local function inRect(r) -- 173
			return cx >= r.x and cx <= r.x + r.w and cy >= r.y and cy <= r.y + r.h -- 174
		end -- 173
		if inRect(ENTER_RECT) then -- 173
			return 0 -- 175
		end -- 175
		if inRect(SELECT_RECT) then -- 175
			return 1 -- 176
		end -- 176
		if inRect(QUIT_RECT) then -- 176
			return 2 -- 177
		end -- 177
		return -1 -- 178
	end -- 171
	local function toCanvas(lx, ly) -- 181
		return Vec2(lx, H - ly) -- 181
	end -- 181
	local function activate() -- 183
		if state ~= 0 then -- 183
			return -- 184
		end -- 184
		local idx = sel < 0 and 0 or sel -- 185
		if idx == 0 then -- 185
			state = 1 -- 187
			fade = 0 -- 188
		elseif idx == 1 then -- 188
			state = 2 -- 190
			modal.visible = true -- 191
		else -- 191
			state = 3 -- 193
			exitTimer = 0 -- 194
		end -- 194
	end -- 183
	local function trigger() -- 198
		if pendingIdx >= 0 or state ~= 0 then -- 198
			return -- 199
		end -- 199
		local idx = sel < 0 and 0 or sel -- 200
		pressIdx = idx -- 201
		pendingIdx = idx -- 202
		pendingT = 0.1 -- 203
	end -- 198
	local function onKey(key) -- 206
		if state == 2 then -- 206
			if key == "Escape" or key == "Return" then -- 206
				state = 0 -- 209
				modal.visible = false -- 210
			end -- 210
			return -- 212
		end -- 212
		if state ~= 0 then -- 212
			if key == "Escape" and state == 1 then -- 212
				state = 0 -- 216
				fade = 0 -- 217
				root.opacity = 1 -- 218
			end -- 218
			return -- 220
		end -- 220
		if key == "Up" or key == "Left" then -- 220
			sel = sel <= 0 and 0 or sel - 1 -- 223
		elseif key == "Down" or key == "Right" then -- 223
			sel = sel < 0 and 0 or (sel + 1) % 3 -- 225
		elseif key == "Return" then -- 225
			trigger() -- 227
		end -- 227
	end -- 206
	root:onKeyDown(onKey) -- 231
	input:onMouseMove(function(touch) -- 233
		if state ~= 0 then -- 233
			return -- 234
		end -- 234
		local c = toCanvas(touch.location.x, touch.location.y) -- 235
		sel = hitTest(c.x, c.y) -- 236
	end) -- 233
	input:onTapped(function(touch) -- 239
		local c = toCanvas(touch.location.x, touch.location.y) -- 240
		local hit = hitTest(c.x, c.y) -- 241
		if hit >= 0 then -- 241
			sel = hit -- 243
			trigger() -- 244
		end -- 244
	end) -- 239
	input:onTapBegan(function(touch) -- 248
		local c = toCanvas(touch.location.x, touch.location.y) -- 249
		local hit = hitTest(c.x, c.y) -- 250
		if hit >= 0 then -- 250
			sel = hit -- 252
			pressIdx = hit -- 253
		end -- 253
	end) -- 248
	input:onTapEnded(function() -- 257
		pressIdx = -1 -- 257
	end) -- 257
	local flagIdx = 0 -- 260
	local flagAcc = 0 -- 261
	root:schedule(function(dt) -- 263
		time = time + dt -- 264
		local vs = View.size -- 268
		local sContain = math.min(vs.width / W, vs.height / H) -- 269
		local sCover = math.max(vs.width / W, vs.height / H) -- 270
		local s = sContain -- 271
		local offY = 0 -- 272
		if vs.width / vs.height > W / H then -- 272
			local cut = H * sCover - vs.height -- 274
			if cut / vs.height <= 0.15 then -- 274
				s = sCover -- 276
				offY = -cut / 2 -- 277
			end -- 277
		end -- 277
		curScale = s -- 280
		root.scaleX = s -- 281
		root.scaleY = s -- 282
		root.position = Vec2(0, offY) -- 283
		flagAcc = flagAcc + dt -- 286
		if flagAcc >= 0.13 then -- 286
			flagAcc = 0 -- 288
			flagFrames[flagIdx + 1].visible = false -- 289
			flagIdx = (flagIdx + 1) % 3 -- 290
			flagFrames[flagIdx + 1].visible = true -- 291
		end -- 291
		glow.opacity = 0.74 + 0.26 * math.sin(time * 0.9) -- 295
		cloudX = cloudX + dt * 10 -- 298
		if cloudX > cloudHome + W + 420 then -- 298
			cloudX = cloudHome - 900 -- 299
		end -- 299
		clouds.position = Vec2(cloudX, cloudY) -- 300
		birdX = birdX + dt * 16 -- 302
		if birdX > birdHome + W + 60 then -- 302
			birdX = birdHome - 700 -- 303
		end -- 303
		birds.position = Vec2(birdX, birdY) -- 304
		if time < 1.3 then -- 304
			do -- 304
				local i = 0 -- 308
				while i < #titleChars do -- 308
					local k = math.min( -- 309
						1, -- 309
						math.max(0, (time - 0.05 - i * 0.1) / 0.24) -- 309
					) -- 309
					titleChars[i + 1].opacity = k -- 310
					i = i + 1 -- 308
				end -- 308
			end -- 308
		end -- 308
		local hvStep = dt / 0.14 -- 315
		local prStep = dt / 0.08 -- 316
		do -- 316
			local i = 0 -- 317
			while i < #panels do -- 317
				hov[i + 1] = approach(hov[i + 1], state == 0 and sel == i and 1 or 0, hvStep) -- 318
				prs[i + 1] = approach(prs[i + 1], state == 0 and pressIdx == i and 1 or 0, prStep) -- 319
				local h = hov[i + 1] -- 320
				local e = h * h * (3 - 2 * h) -- 321
				local p = prs[i + 1] -- 322
				local off = 3 * e + 2 * p -- 324
				panels[i + 1].position = Vec2(bases[i + 1].x + off, bases[i + 1].y - off) -- 325
				panels[i + 1].color = mixColor(C_WHITE, C_DIM, e * 0.55 + p * 0.35) -- 326
				i = i + 1 -- 317
			end -- 317
		end -- 317
		if pendingIdx >= 0 then -- 317
			pendingT = pendingT - dt -- 331
			if pendingT <= 0 then -- 331
				pendingIdx = -1 -- 333
				pressIdx = -1 -- 334
				activate() -- 335
			end -- 335
		end -- 335
		if state == 1 then -- 335
			fade = math.min(1, fade + dt * 1.2) -- 341
			root.opacity = 1 - fade -- 342
			if fade >= 1 and not entered then -- 342
				enterWait = enterWait + dt -- 345
				if enterWait < 0.32 then -- 345
					return false -- 346
				end -- 346
				entered = true -- 347
				root.visible = false -- 348
				startLevel1() -- 349
				return true -- 350
			end -- 350
		end -- 350
		if state == 3 then -- 350
			exitTimer = exitTimer + dt -- 355
			if exitTimer > 0.4 then -- 355
				App:shutdown() -- 356
			end -- 356
		end -- 356
		return false -- 359
	end) -- 263
	local handle = { -- 362
		select = function(____, index) -- 363
			sel = index -- 363
		end, -- 363
		activate = function() -- 364
			activate() -- 364
		end, -- 364
		keyDown = function(____, key) -- 365
			onKey(key) -- 365
		end, -- 365
		setSelectionFromPoint = function(____, cx, cy) -- 366
			sel = hitTest(cx, cy) -- 367
		end, -- 366
		getState = function() return state end, -- 369
		getSelection = function() return sel end, -- 370
		getFade = function() return fade end, -- 371
		getPortraitHeight = function() return 384 end, -- 372
		isPortraitSized = function() return View.size.height > View.size.width end -- 373
	} -- 373
	registerTitle( -- 377
		root, -- 377
		function() -- 377
			____exports.startTitleScene() -- 377
		end -- 377
	) -- 377
	print("[TitleScene] 切图版启动") -- 379
	return handle -- 380
end -- 69
return ____exports -- 69