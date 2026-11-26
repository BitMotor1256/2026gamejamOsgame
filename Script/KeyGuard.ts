// 按键锁：同一次 P 只能推进一格
// 场景切换时，新场景的 onKeyDown 也会收到「切它进来的那一次按键」，
// 层层叠加就会一次跳完好几关。用一个全局消费标记挡住。
let lockFrames = 0;

export function pBlocked(): boolean {
	return lockFrames > 0;
}

export function pConsume(): void {
	lockFrames = 14;   // 约 230ms @60fps，足够跨过场景切换
}

export function pTick(): void {
	if (lockFrames > 0) lockFrames--;
}
