-- [ts]: Nav.ts
local ____exports = {} -- 1
local titleRoot = nil -- 9
local boot = nil -- 10
function ____exports.registerTitle(root, restart) -- 13
	titleRoot = root -- 14
	boot = restart -- 15
end -- 13
function ____exports.backToTitle() -- 19
	if titleRoot ~= nil then -- 19
		titleRoot:removeFromParent() -- 21
		titleRoot = nil -- 22
	end -- 22
	if boot ~= nil then -- 22
		boot() -- 25
	else -- 25
		print("[Nav] 标题页还没登记过，回不去") -- 27
	end -- 27
end -- 19
return ____exports -- 19