// 《永昌守城记》开始场景 A 方案 · 暮色城门（环海门）
// 视觉：全部用 05-美术素材 切好的图（Image/StartUI/，两倍图）
// 交互：沿用上一版的输入区 / 命中 / 状态机；按钮阴影单独用纯色块画，
//       这样才能复现「悬停时按钮下沉、阴影收窄」的手感（阴影烘在切图里就锁死了）
//
// 切图坐标 1280×804、左上原点、Y 向下；Dora 子坐标相对父左上、Y 向上，换算在 toRoot 里做。
import {
	App,
	Color,
	Director,
	KeyName,
	Node,
	Size,
	Sprite,
	Vec2,
	View,
} from 'Dora';
import { startLevel1 } from 'Script/Level1Scene';
import { registerTitle } from 'Script/Nav';

const W = 1280;
const H = 804;
const SHEET = 'Image/StartUI/';
const SHADOW = 6;          // 按钮硬阴影的偏移量（原型的 box-shadow: 6px 6px 0）

type Pt = { x: number; y: number; w: number; h: number };

const C_WHITE = Color(255, 255, 255, 255);
const C_DIM = Color(206, 206, 206, 255);
const C_INK_SHADOW = Color(34, 53, 47, 235);

/* 画布坐标（左上原点，Y 向下）→ root 内坐标（左下原点，Y 向上） */
function toRoot(p: Pt): Vec2.Type {
	return Vec2(p.x + p.w / 2, H - (p.y + p.h / 2));
}

function approach(v: number, target: number, step: number): number {
	if (v < target) { return Math.min(target, v + step); }
	if (v > target) { return Math.max(target, v - step); }
	return v;
}

function mixColor(a: Color.Type, b: Color.Type, t: number): Color.Type {
	return Color(
		Math.round(a.r + (b.r - a.r) * t),
		Math.round(a.g + (b.g - a.g) * t),
		Math.round(a.b + (b.b - a.b) * t),
		Math.round(a.a + (b.a - a.a) * t),
	);
}

/* 三个按钮：坐标取切图包围盒（已去掉阴影） */
const ENTER_RECT: Pt = { x: 104, y: 492, w: 214, h: 68 };
const SELECT_RECT: Pt = { x: 104, y: 572, w: 77, h: 44 };
const QUIT_RECT: Pt = { x: 191, y: 572, w: 78, h: 44 };

export interface TitleSceneHandle {
	select(index: number): void;
	activate(): void;
	keyDown(key: KeyName): void;
	setSelectionFromPoint(cx: number, cy: number): void;
	getState(): number;
	getSelection(): number;
	getFade(): number;
	getPortraitHeight(): number;
	isPortraitSized(): boolean;
}

export function startTitleScene(): TitleSceneHandle {
	Director.clearColor = Color(233, 223, 196, 255);

	const root = Node();
	root.anchor = Vec2(0.5, 0.5);
	root.size = Size(W, H);
	root.position = Vec2(0, 0);
	root.addTo(Director.ui);

	/* ---------- 图元工厂 ---------- */
	const sprite = (file: string, p: Pt): Sprite.Type => {
		const s = Sprite(SHEET + file)!;
		s.anchor = Vec2(0.5, 0.5);
		s.size = Size(p.w, p.h);
		s.position = toRoot(p);
		s.addTo(root);
		return s;
	};

	/* ---------- 底图与可动层 ---------- */
	sprite('bg.png', { x: 0, y: 0, w: 1280, h: 804 });

	const clouds = sprite('clouds.png', { x: 150, y: 105, w: 806, h: 188 });
	const birds = sprite('birds.png', { x: 279, y: 200, w: 53, h: 17 });
	const glow = sprite('glow.png', { x: 627, y: 565, w: 26, h: 135 });

	const flagFrames: Sprite.Type[] = [
		sprite('flag_0.png', { x: 267, y: 303, w: 656, h: 102 }),
		sprite('flag_1.png', { x: 267, y: 303, w: 656, h: 102 }),
		sprite('flag_2.png', { x: 267, y: 303, w: 656, h: 102 }),
	];
	flagFrames.forEach((f, i) => { f.visible = (i === 0); });

	/* ---------- 文字层（全部是图，不用字体） ---------- */
	sprite('side.png', { x: 104, y: 29, w: 14, h: 255 });

	const titleChars: Sprite.Type[] = [
		sprite('title_0.png', { x: 141, y: 20, w: 58, h: 56 }),
		sprite('title_1.png', { x: 147, y: 89, w: 49, h: 55 }),
		sprite('title_2.png', { x: 142, y: 156, w: 57, h: 57 }),
		sprite('title_3.png', { x: 141, y: 225, w: 58, h: 55 }),
		sprite('title_4.png', { x: 141, y: 292, w: 58, h: 54 }),
	];

	/* ---------- 按钮：先阴影（纯色块）再面板 ---------- */
	const mkButton = (file: string, p: Pt) => {
		const sh = Sprite(SHEET + 'white.png')!;
		sh.anchor = Vec2(0.5, 0.5);
		sh.size = Size(p.w, p.h);
		sh.color = C_INK_SHADOW;
		// 阴影固定在面板的右下 SHADOW 像素处，不随悬停移动
		sh.position = Vec2(p.x + SHADOW + p.w / 2, H - (p.y + SHADOW + p.h / 2));
		sh.addTo(root);

		const panel = sprite(file, p);
		const base = Vec2(p.x + p.w / 2, H - (p.y + p.h / 2));
		return { panel: panel, base: base };
	};

	const bEnter = mkButton('btn_enter.png', ENTER_RECT);
	const bSelect = mkButton('btn_select.png', SELECT_RECT);
	const bQuit = mkButton('btn_quit.png', QUIT_RECT);
	const panels: Sprite.Type[] = [bEnter.panel, bSelect.panel, bQuit.panel];
	const bases: Vec2.Type[] = [bEnter.base, bSelect.base, bQuit.base];
	const hov: number[] = [0, 0, 0];   // 悬停进度 0..1
	const prs: number[] = [0, 0, 0];   // 按下进度 0..1

	sprite('hint.png', { x: 104, y: 633, w: 167, h: 12 });
	sprite('wangzi.png', { x: 869, y: 420, w: 377, h: 384 });

	/* ---------- 选关弹层（默认隐藏） ---------- */
	const modal = sprite('modal_select.png', { x: 393, y: 174, w: 504, h: 467 });
	modal.visible = false;

	/* ---------- 输入区 ---------- */
	const input = Node();
	input.size = Size(W, H);
	input.anchor = Vec2(0, 0);
	input.position = Vec2(0, 0);
	input.addTo(root);
	input.touchEnabled = true;

	let curScale = 1;
	let time = 0;
	let sel = -1;
	let pressIdx = -1;
	let pendingIdx = -1;
	let pendingT = 0;
	let state = 0;   // 0 待机 / 1 入城中 / 2 选关弹层 / 3 退出
	let fade = 0;
	let exitTimer = 0;
	let entered = false;
	let enterWait = 0;

	/* 云雁用增量推进（用绝对时间算位置会每帧重算，导致回绕时疯狂抖动） */
	const cloudY = clouds.position.y;
	const birdY = birds.position.y;
	const cloudHome = clouds.position.x;
	const birdHome = birds.position.x;
	let cloudX = cloudHome;
	let birdX = birdHome;

	const hitTest = (cx: number, cy: number): number => {
		if (state !== 0) { return -1; }
		const inRect = (r: Pt): boolean =>
			cx >= r.x && cx <= r.x + r.w && cy >= r.y && cy <= r.y + r.h;
		if (inRect(ENTER_RECT)) { return 0; }
		if (inRect(SELECT_RECT)) { return 1; }
		if (inRect(QUIT_RECT)) { return 2; }
		return -1;
	};

	const toCanvas = (lx: number, ly: number): Vec2.Type => Vec2(lx, H - ly);

	const activate = (): void => {
		if (state !== 0) { return; }
		const idx = sel < 0 ? 0 : sel;
		if (idx === 0) {
			state = 1;
			fade = 0;
		} else if (idx === 1) {
			state = 2;
			modal.visible = true;
		} else {
			state = 3;
			exitTimer = 0;
		}
	};

	const trigger = (): void => {
		if (pendingIdx >= 0 || state !== 0) { return; }
		const idx = sel < 0 ? 0 : sel;
		pressIdx = idx;
		pendingIdx = idx;
		pendingT = 0.10;
	};

	const onKey = (key: KeyName): void => {
		if (state === 2) {
			if (key === KeyName.Escape || key === KeyName.Return) {
				state = 0;
				modal.visible = false;
			}
			return;
		}
		if (state !== 0) {
			if (key === KeyName.Escape && state === 1) {
				state = 0;
				fade = 0;
				root.opacity = 1;
			}
			return;
		}
		if (key === KeyName.Up || key === KeyName.Left) {
			sel = sel <= 0 ? 0 : sel - 1;
		} else if (key === KeyName.Down || key === KeyName.Right) {
			sel = sel < 0 ? 0 : (sel + 1) % 3;
		} else if (key === KeyName.Return) {
			trigger();
		}
	};

	root.onKeyDown(onKey);

	input.onMouseMove((touch) => {
		if (state !== 0) { return; }
		const c = toCanvas(touch.location.x, touch.location.y);
		sel = hitTest(c.x, c.y);
	});

	input.onTapped((touch) => {
		const c = toCanvas(touch.location.x, touch.location.y);
		const hit = hitTest(c.x, c.y);
		if (hit >= 0) {
			sel = hit;
			trigger();
		}
	});

	input.onTapBegan((touch) => {
		const c = toCanvas(touch.location.x, touch.location.y);
		const hit = hitTest(c.x, c.y);
		if (hit >= 0) {
			sel = hit;
			pressIdx = hit;
		}
	});

	input.onTapEnded(() => { pressIdx = -1; });

	/* ---------- 每帧 ---------- */
	let flagIdx = 0;
	let flagAcc = 0;

	root.schedule((dt: number) => {
		time += dt;

		// 自适应：窗口比画面宽时用 cover（裁掉底部多余，左右不留纸色边）；
		// 只裁少量时这么做，裁太多（极宽屏）就退回 contain，否则会切掉标题
		const vs = View.size;
		const sContain = Math.min(vs.width / W, vs.height / H);
		const sCover = Math.max(vs.width / W, vs.height / H);
		let s = sContain;
		let offY = 0;
		if (vs.width / vs.height > W / H) {
			const cut = H * sCover - vs.height;
			if (cut / vs.height <= 0.15) {
				s = sCover;
				offY = -cut / 2;   // 顶部对齐，底部多裁
			}
		}
		curScale = s;
		root.scaleX = s;
		root.scaleY = s;
		root.position = Vec2(0, offY);

		// 旗三帧
		flagAcc += dt;
		if (flagAcc >= 0.13) {
			flagAcc = 0;
			flagFrames[flagIdx].visible = false;
			flagIdx = (flagIdx + 1) % 3;
			flagFrames[flagIdx].visible = true;
		}

		// 门缝光呼吸
		glow.opacity = 0.74 + 0.26 * Math.sin(time * 0.9);

		// 云、雁：增量推进 + 出界回绕
		cloudX += dt * 10;
		if (cloudX > cloudHome + W + 420) { cloudX = cloudHome - 900; }
		clouds.position = Vec2(cloudX, cloudY);

		birdX += dt * 16;
		if (birdX > birdHome + W + 60) { birdX = birdHome - 700; }
		birds.position = Vec2(birdX, birdY);

		// 标题逐字淡入
		if (time < 1.3) {
			for (let i = 0; i < titleChars.length; i++) {
				const k = Math.min(1, Math.max(0, (time - 0.05 - i * 0.10) / 0.24));
				titleChars[i].opacity = k;
			}
		}

		// 按钮：悬停 0.14s、按下 0.08s 缓动，smoothstep 曲线
		const hvStep = dt / 0.14;
		const prStep = dt / 0.08;
		for (let i = 0; i < panels.length; i++) {
			hov[i] = approach(hov[i], (state === 0 && sel === i) ? 1 : 0, hvStep);
			prs[i] = approach(prs[i], (state === 0 && pressIdx === i) ? 1 : 0, prStep);
			const h = hov[i];
			const e = h * h * (3 - 2 * h);
			const p = prs[i];
			// 面板向右下推进（阴影固定，于是「阴影收窄」= 按钮被按下去）
			const off = 3 * e + 2 * p;
			panels[i].position = Vec2(bases[i].x + off, bases[i].y - off);
			panels[i].color = mixColor(C_WHITE, C_DIM, e * 0.55 + p * 0.35);
		}

		// 按下后短暂延迟，让下沉看得见
		if (pendingIdx >= 0) {
			pendingT -= dt;
			if (pendingT <= 0) {
				pendingIdx = -1;
				pressIdx = -1;
				activate();
			}
		}

		// 入城：淡出后交给第一关，并停掉本场景的调度
		if (state === 1) {
			fade = Math.min(1, fade + dt * 1.2);
			root.opacity = 1 - fade;
			// 淡出到底后再留一口气（0.32 秒纸色空场），让下一屏的淡入不显得突兀
			if (fade >= 1 && !entered) {
				enterWait += dt;
				if (enterWait < 0.32) { return false; }
				entered = true;
				root.visible = false;
				startLevel1();
				return true;   // 停止本场景调度（schedule 返回 true = 停止）
			}
		}

		if (state === 3) {
			exitTimer += dt;
			if (exitTimer > 0.4) { App.shutdown(); }
		}

		return false;
	});

	const handle: TitleSceneHandle = {
		select: (index: number): void => { sel = index; },
		activate: (): void => { activate(); },
		keyDown: (key: KeyName): void => { onKey(key); },
		setSelectionFromPoint: (cx: number, cy: number): void => {
			sel = hitTest(cx, cy);
		},
		getState: (): number => state,
		getSelection: (): number => sel,
		getFade: (): number => fade,
		getPortraitHeight: (): number => 384,
		isPortraitSized: (): boolean => (View.size.height > View.size.width),
	};

	// 登记「重启自己」的方法：关卡里的「返回主菜单」靠它回来
	registerTitle(root, (): void => { startTitleScene(); });

	print('[TitleScene] 切图版启动');
	return handle;
}
