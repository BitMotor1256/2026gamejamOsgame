-- 开始场景状态机运行时验证（纯 Lua 入口，require TS 场景模块）
-- 注意：TS 对象字面量里的函数会被转译成 Lua 方法，调用需用冒号语法。
local Dora = require("Dora")
local Director = Dora.Director
local Node = Dora.Node
local Sprite = Dora.Sprite

local function say(s)
	print("[PROBE] " .. s)
end

local scene = nil
local okStart, startErr = pcall(function()
	scene = require("Script.TitleScene").startTitleScene()
end)
if not okStart then
	say("FAIL startTitleScene error=" .. tostring(startErr))
	return
end
say("ok   scene started")

local art = Sprite("Image/wangzi_smile.png")
say("info sprite texture height=" .. tostring(art and art.height))

local fails = 0
local function attempt(label, fn)
	local ok, err = pcall(fn)
	if ok then
		say("ok   " .. label)
	else
		fails = fails + 1
		say("FAIL " .. label .. " :: " .. tostring(err))
	end
end

local probe = Node()
probe:addTo(Director.entry)

local step = 0
local wait = 0
local fade1 = 0

probe:schedule(function()
	if wait > 0 then
		wait = wait - 1
		return false
	end
	if step == 0 then
		attempt("initial state idle(0)", function()
			assert(scene:getState() == 0, "got " .. tostring(scene:getState()))
		end)
		attempt("initial selection enter(0)", function()
			assert(scene:getSelection() == 0, "got " .. tostring(scene:getSelection()))
		end)
		attempt("select(1) sets selection 1", function()
			scene:select(1)
			assert(scene:getSelection() == 1, "got " .. tostring(scene:getSelection()))
		end)
		attempt("keyDown Down moves selection to 1", function()
			scene:select(0)
			scene:keyDown("Down")
			assert(scene:getSelection() == 1, "got " .. tostring(scene:getSelection()))
		end)
		attempt("keyDown Up moves selection to 0", function()
			scene:select(1)
			scene:keyDown("Up")
			assert(scene:getSelection() == 0, "got " .. tostring(scene:getSelection()))
		end)
		attempt("hover point on quit selects 1", function()
			scene:select(0)
			scene:setSelectionFromPoint(130, 580)
			assert(scene:getSelection() == 1, "got " .. tostring(scene:getSelection()))
		end)
		attempt("hover point on enter selects 0", function()
			scene:select(1)
			scene:setSelectionFromPoint(120, 520)
			assert(scene:getSelection() == 0, "got " .. tostring(scene:getSelection()))
		end)
		attempt("hover outside buttons keeps selection", function()
			scene:select(0)
			scene:setSelectionFromPoint(600, 300)
			assert(scene:getSelection() == 0, "got " .. tostring(scene:getSelection()))
		end)
		attempt("portrait texture height > 0", function()
			assert(scene:getPortraitHeight() > 0, "got " .. tostring(scene:getPortraitHeight()))
		end)
		attempt("Return on enter starts transition(1)", function()
			scene:select(0)
			scene:keyDown("Return")
			assert(scene:getState() == 1, "got " .. tostring(scene:getState()))
		end)
		step = 1
		wait = 30
		return false
	end
	if step == 1 then
		attempt("transition fade grows", function()
			fade1 = scene:getFade()
			assert(fade1 > 0.1, "got " .. tostring(fade1))
		end)
		attempt("portrait scaled once texture height known", function()
			assert(scene:isPortraitSized(), "not sized")
		end)
		step = 2
		wait = 30
		return false
	end
	if step == 2 then
		attempt("transition fade reaches full paper overlay", function()
			assert(scene:getFade() >= fade1, "prev " .. tostring(fade1) .. " now " .. tostring(scene:getFade()))
			assert(scene:getFade() > 0.9, "got " .. tostring(scene:getFade()))
		end)
		attempt("Escape returns to title(0)", function()
			scene:keyDown("Escape")
			assert(scene:getState() == 0, "got " .. tostring(scene:getState()))
		end)
		attempt("Return on quit opens confirm(2)", function()
			scene:select(1)
			scene:keyDown("Return")
			assert(scene:getState() == 2, "got " .. tostring(scene:getState()))
		end)
		step = 3
		wait = 5
		return false
	end
	attempt("Escape cancels confirm -> 0", function()
		scene:keyDown("Escape")
		assert(scene:getState() == 0, "got " .. tostring(scene:getState()))
	end)
	if fails == 0 then
		say("RESULT passed")
	else
		say("RESULT failed count=" .. tostring(fails))
	end
	return true
end)
