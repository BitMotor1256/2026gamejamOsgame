-- 第二关背景音乐生成（纯 Lua，绕过 TSTL）
--
-- 为什么不用 TypeScript 那版：
--   Audio.renderMusicAsync 在引擎侧要求「必须在协程里调用」，而 TSTL 把它当成同步函数
--   （.d.ts 里返回 string），既不会生成 coroutine.yield，包在 thread() 里也不被引擎认作协程上下文。
--   所以直接用 Lua 手写：thread() + 原生 renderMusicAsync，yield 才能正常工作。
--
-- 谱面用 exact score：自己写每个音的拍位，游戏里的谱面由同一份拍位表导出，天然对齐。
local Music = require('Lib.Agent.Gen.Music')

local BPM = 88
local BARS = 32
local BEATS = BARS * 4          -- 128 拍，和 Level2Play 的 TOTAL_BEATS 一致

-- 五声音阶（D 宫），陪衬用
local PENTA = { 62, 64, 66, 69, 71 }

local function segOf(b)
	if b < 24 then return 0 end
	if b < 56 then return 1 end
	if b < 88 then return 2 end
	return 3
end

-- 确定性伪随机（自己实现：不依赖 math.random 的种子行为）
local seed = 20261122
local function rnd()
	seed = (seed * 1103515245 + 12345) % 2147483648
	return seed / 2147483648
end

local drums, bass, lead = {}, {}, {}

-- 鼓：戌时三拍一记 → 子时两拍 → 寅时起每拍，后半拍加木鱼
for b = 0, BEATS - 1 do
	local seg = segOf(b)
	local step = (seg == 0 and 3) or (seg == 1 and 2) or 1
	if b % step == 0 then
		drums[#drums + 1] = { pitch = 'C2', start = b, duration = 0.4, velocity = 0.85 }
	end
	if seg >= 2 and b % 2 == 1 then
		drums[#drums + 1] = { pitch = 'D2', start = b + 0.5, duration = 0.25, velocity = 0.45 }
	end
end

-- 低音：每两拍一个根音
local ROOTS = { 38, 38, 36, 40 }
for b = 0, BEATS - 1, 2 do
	local seg = segOf(b)
	bass[#bass + 1] = { pitch = ROOTS[seg + 1], start = b, duration = 1.8, velocity = 0.55 }
end

-- 旋律：越到后面越密
local DENSITY = { 0.22, 0.35, 0.50, 0.62 }
for b = 0, BEATS - 1 do
	local seg = segOf(b)
	if rnd() <= DENSITY[seg + 1] then
		local idx = math.floor(rnd() * #PENTA) + 1
		lead[#lead + 1] = {
			pitch = PENTA[idx],
			start = b,
			duration = 0.8,
			velocity = 0.35 + rnd() * 0.2,
		}
	end
end

local definition = {
	output = 'Audio/lv2_bgm.ogg',
	synth = { sampleRate = 44100, polyphony = 24 },
	score = {
		bpm = BPM,
		beatsPerBar = 4,
		bars = BARS,
		tracks = {
			{ instrument = 'drums', drumKit = 'electronic', notes = drums, volume = 0.9, role = 'drums' },
			{ instrument = 'sine', notes = bass, volume = 0.70, role = 'bass' },
			{ instrument = 'pluck', notes = lead, volume = 0.42, role = 'melody' },
		},
	},
	effects = { reverb = 0.18, lowPass = 0.72 },
	exports = { midi = true, stems = false },
}

print('[Music] 定义就绪：' .. tostring(#drums) .. ' 鼓 / ' .. tostring(#bass) .. ' 低音 / ' .. tostring(#lead) .. ' 旋律')

thread(function()
	print('[Music] 开始生成')
	local result = Music.generateMusicAsync('.', definition, {
		onProgress = function(p)
			print('[Music] ' .. tostring(p.stage) .. ' ' .. tostring(math.floor((p.progress or 0) * 100)) .. '%')
		end,
	})
	if result and result.success then
		print('[Music] 完成 ' .. tostring(result.path) .. '  ' .. tostring(result.durationSeconds) .. ' 秒')
	else
		print('[Music] 失败 ' .. tostring(result and result.message))
	end
end)

return true
