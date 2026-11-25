-- [ts]: GenLv2Music.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local thread = ____Dora.thread -- 8
local ____Music = require("Agent.Gen.Music") -- 9
local defineMusic = ____Music.defineMusic -- 9
local generateMusicAsync = ____Music.generateMusicAsync -- 9
local BPM = 88 -- 11
local BARS = 32 -- 12
local BEATS = BARS * 4 -- 13
local PENTA = { -- 16
	62, -- 16
	64, -- 16
	66, -- 16
	69, -- 16
	71 -- 16
} -- 16
local function buildScore() -- 20
	local drums = {} -- 22
	do -- 22
		local b = 0 -- 23
		while b < BEATS do -- 23
			local seg = b < 24 and 0 or (b < 56 and 1 or (b < 88 and 2 or 3)) -- 24
			local step = seg == 0 and 3 or (seg == 1 and 2 or 1) -- 25
			if b % step == 0 then -- 25
				drums[#drums + 1] = {pitch = "C2", start = b, duration = 0.4, velocity = 0.85} -- 26
			end -- 26
			if seg >= 2 and b % 2 == 1 then -- 26
				drums[#drums + 1] = {pitch = "D2", start = b + 0.5, duration = 0.25, velocity = 0.45} -- 28
			end -- 28
			b = b + 1 -- 23
		end -- 23
	end -- 23
	local bass = {} -- 32
	do -- 32
		local b = 0 -- 33
		while b < BEATS do -- 33
			local seg = b < 24 and 0 or (b < 56 and 1 or (b < 88 and 2 or 3)) -- 34
			local root = ({38, 38, 36, 40})[seg + 1] -- 35
			bass[#bass + 1] = {pitch = root, start = b, duration = 1.8, velocity = 0.55} -- 36
			b = b + 2 -- 33
		end -- 33
	end -- 33
	local lead = {} -- 40
	local seed = 20261122 -- 41
	local function rnd() -- 42
		seed = seed * 1103515245 + 12345 & 2147483647 -- 43
		return seed / 2147483647 -- 44
	end -- 42
	do -- 42
		local b = 0 -- 46
		while b < BEATS do -- 46
			do -- 46
				local seg = b < 24 and 0 or (b < 56 and 1 or (b < 88 and 2 or 3)) -- 47
				local density = ({0.22, 0.35, 0.5, 0.62})[seg + 1] -- 48
				if rnd() > density then -- 48
					goto __continue11 -- 49
				end -- 49
				local idx = math.floor(rnd() * #PENTA) -- 50
				lead[#lead + 1] = { -- 51
					pitch = PENTA[idx + 1], -- 51
					start = b, -- 51
					duration = 0.8, -- 51
					velocity = 0.35 + rnd() * 0.2 -- 51
				} -- 51
			end -- 51
			::__continue11:: -- 51
			b = b + 1 -- 46
		end -- 46
	end -- 46
	return {drums = drums, bass = bass, lead = lead} -- 54
end -- 20
function ____exports.generateLv2Music(projectDir) -- 57
	thread(function() -- 58
		local sc = buildScore() -- 59
		local def = defineMusic({ -- 60
			output = "Audio/lv2_bgm.ogg", -- 61
			synth = {sampleRate = 44100, polyphony = 32}, -- 62
			score = {bpm = BPM, beatsPerBar = 4, bars = BARS, tracks = {{ -- 63
				instrument = "drums", -- 68
				drumKit = "electronic", -- 68
				notes = sc.drums, -- 68
				volume = 0.9, -- 68
				role = "drums" -- 68
			}, {instrument = "sine", notes = sc.bass, volume = 0.7, role = "bass"}, {instrument = "pluck", notes = sc.lead, volume = 0.42, role = "melody"}}}, -- 68
			effects = {reverb = 0.18, lowPass = 0.7}, -- 73
			exports = {midi = true, stems = false} -- 74
		}) -- 74
		local r = generateMusicAsync( -- 77
			projectDir, -- 77
			def, -- 77
			{onProgress = function(p) -- 77
				print(((("[Music] " .. p.stage) .. " ") .. tostring(math.floor(p.progress * 100 + 0.5))) .. "%") -- 78
			end} -- 78
		) -- 78
		if r.success then -- 78
			print(((("[Music] 生成完成 " .. r.path) .. "  ") .. __TS__NumberToFixed(r.durationSeconds, 1)) .. "s") -- 81
		else -- 81
			print("[Music] 失败 " .. r.message) -- 83
		end -- 83
	end) -- 58
end -- 57
return ____exports -- 57