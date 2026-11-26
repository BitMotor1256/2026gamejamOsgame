-- [ts]: KeyGuard.ts
local ____exports = {} -- 1
local lockFrames = 0 -- 4
function ____exports.pBlocked() -- 6
	return lockFrames > 0 -- 7
end -- 6
function ____exports.pConsume() -- 10
	lockFrames = 14 -- 11
end -- 10
function ____exports.pTick() -- 14
	if lockFrames > 0 then -- 14
		lockFrames = lockFrames - 1 -- 15
	end -- 15
end -- 14
return ____exports -- 14