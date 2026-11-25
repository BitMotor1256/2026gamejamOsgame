// 场景之间的「回标题」通道。
//
// 为什么不在 Level1Scene 里直接 import startTitleScene：
// TitleScene 已经 import 了 startLevel1，两者互相引用会形成循环依赖，
// TS → Lua 编译后容易有一边拿到半初始化的模块（表现为调用时报 nil）。
// 这里垫一个什么都不依赖的中间人，把环断开。
import { Node } from 'Dora';

let titleRoot: Node.Type | undefined = undefined;
let boot: (() => void) | undefined = undefined;

/* TitleScene 每次启动都把「自己的根节点 + 重启自己的方法」登记进来 */
export function registerTitle(root: Node.Type, restart: () => void): void {
	titleRoot = root;
	boot = restart;
}

/* 从关卡里回到标题页：先摘掉旧的标题层，再重新起一份 */
export function backToTitle(): void {
	if (titleRoot !== undefined) {
		titleRoot.removeFromParent();
		titleRoot = undefined;
	}
	if (boot !== undefined) {
		boot();
	} else {
		print('[Nav] 标题页还没登记过，回不去');
	}
}
