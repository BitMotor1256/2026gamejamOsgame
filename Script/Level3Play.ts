// 第三关 · 引流（渠网调度）
// 版式与数值来自 02-可玩原型/lv3-引流-完整版.html（1280×800）：
// 44×22 渠格、8 块田各三趟、10 个田口、水头 2–6 格、撞岸断尾 2 格。
//
// 渲染分工：
//   · 城墙带、渠网底（含田埂与秧痕）→ 预渲染两张图
//   · 田的档位、水头、水沟、水量格、田口指示 → DrawNode 每帧重绘
// 这一关几乎全是格子矩形，DrawNode 的 alpha 又生效，正合适。
import {
	Audio,
	Color,
	DrawNode,
	KeyName,
	Label,
	Node,
	Rect,
	Size,
	Sprite,
	Vec2,
} from 'Dora';
import { backToTitle } from 'Script/Nav';
import { startLevel3Result } from 'Script/Level3ResultScene';
import { startLevel3Post } from 'Script/Level3PostScene';
import { createSceneFrame } from 'Script/SceneFrame';

const W = 1280, H = 800;

/* ── 格网 ── */
const G = 24, COLS = 44, ROWS = 22;
const GW = COLS * G, GH = ROWS * G;      // 1056 × 528
const OX = (W - GW) / 2;                 // 112
const OY = 86;
const ST_T = OY + GH;                    // 614
const ST_Y = ST_T;                       // 底部提示带的顶边

/* ── 数值（详细设计 §8） ── */
const NEED = 3, TOTAL_POUR = 24;
const SPD_0 = 3.9, SPD_STEP = 0.15, SPD_MAX = 5.1;
const LEN_0 = 2, LEN_MAX = 6, CUT = 2;
const WIN_KEEP = 38, DRY_GRACE = 18, NEVER_GRACE = 60;
const NEED_LEN = [3, 4, 5, 0];
const RESET_LEN = [2, 3, 4, 0];
const START_DELAY = 0.9, STUN = 0.5;
const DITCH_MAX = 1, DITCH_T = 4;
const DITCH_ROWS = [6, 7, 14, 15];

/* ── 色 ── */
const C_PAPER = Color(237, 227, 200, 255);
const C_PAPER2 = Color(243, 234, 211, 255);
const C_SAND = Color(212, 203, 171, 255);
const C_SEAM = Color(168, 159, 127, 255);
const C_TEAL = Color(90, 121, 104, 255);
const C_INK = Color(36, 73, 70, 255);
const C_DEEP = Color(23, 51, 48, 255);
const C_VERM = Color(163, 59, 42, 255);
const C_GOLD = Color(176, 138, 66, 255);
const C_LV1 = Color(184, 198, 158, 255);
const C_LV2 = Color(150, 180, 128, 255);
const C_LV3 = Color(104, 150, 100, 255);
const C_EMPTY = Color(214, 206, 183, 255);
/* 缓动 / 混色：和 TitleScene 的按钮用同一套，手感才对得上 */
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

const C_WATER_HI = Color(126, 166, 156, 255);
const C_WATER_LO = Color(58, 92, 88, 255);

const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_M = 'Font/SourceHanSerifSC-Medium.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

const THUD = 'Audio/lv2_thud2.wav';
const SOUR = 'Audio/lv2_miss.wav';

type Cell = { c: number; r: number };
type Field = {
	cn: string; c0: number; r0: number; c1: number; r1: number;
	lv: number; timer: number; everWatered: boolean; refuseT: number;
};

const FIELD_DEF = [
	{ cn: '甲', c0: 1, r0: 1, c1: 12, r1: 5 },
	{ cn: '乙', c0: 16, r0: 1, c1: 32, r1: 5 },
	{ cn: '丙', c0: 36, r0: 1, c1: 42, r1: 5 },
	{ cn: '丁', c0: 1, r0: 8, c1: 7, r1: 13 },
	{ cn: '戊', c0: 11, r0: 8, c1: 27, r1: 13 },
	{ cn: '己', c0: 31, r0: 8, c1: 42, r1: 13 },
	{ cn: '庚', c0: 1, r0: 16, c1: 19, r1: 20 },
	{ cn: '辛', c0: 23, r0: 16, c1: 42, r1: 20 },
];

const GATES = [
	{ c: 13, r: 3, f: 0, side: 'w' },
	{ c: 15, r: 3, f: 1, side: 'e' },
	{ c: 33, r: 3, f: 1, side: 'w' },
	{ c: 35, r: 3, f: 2, side: 'e' },
	{ c: 8, r: 10, f: 3, side: 'w' },
	{ c: 10, r: 10, f: 4, side: 'e' },
	{ c: 28, r: 10, f: 4, side: 'w' },
	{ c: 30, r: 10, f: 5, side: 'e' },
	{ c: 20, r: 18, f: 6, side: 'w' },
	{ c: 22, r: 18, f: 7, side: 'e' },
];

const DIRV: Record<string, Cell> = {
	u: { c: 0, r: -1 }, d: { c: 0, r: 1 }, l: { c: -1, r: 0 }, r: { c: 1, r: 0 },
};
const OPP: Record<string, string> = { u: 'd', d: 'u', l: 'r', r: 'l' };

const inField = (c: number, r: number): number => {
	for (let i = 0; i < FIELD_DEF.length; i++) {
		const f = FIELD_DEF[i];
		if (c >= f.c0 && c <= f.c1 && r >= f.r0 && r <= f.r1) { return i; }
	}
	return -1;
};
const isCh = (c: number, r: number): boolean =>
	c >= 0 && r >= 0 && c < COLS && r < ROWS && inField(c, r) < 0;
const isOuter = (c: number, r: number): boolean =>
	r === 0 || r === ROWS - 1 || c === 0 || c === COLS - 1;

const gateAt = (c: number, r: number): typeof GATES[0] | undefined => {
	for (const g of GATES) { if (g.c === c && g.r === r) { return g; } }
	return undefined;
};

export type Level3PlayStats = { done: number; secs: number; dead: number };
export type Level3PlayOpts = {
	onFinish: (this: void, stats: Level3PlayStats) => void;
	auto?: boolean;    // 王梓代打：失败页的「王梓来帮你」
};
export type Level3Play = {
	update(dt: number): void;
	destroy(): void;
	press(dir: string): void;
	tapAt(x: number, y: number): boolean;
	pointerAt(x: number, y: number, down: boolean): void;
	togglePause(): void;
	restart(): void;
	skip(): void;
};

export function createLevel3Play(parent: Node.Type, opts: Level3PlayOpts): Level3Play {
	/* ══════════ 工具 ══════════ */
	const block = (
		p: Node.Type, x: number, y: number, w: number, h: number, c: Color.Type, al = 1,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.size = Size(Math.abs(w), Math.abs(h));
		s.anchor = Vec2(0, 1);
		s.color = c;
		s.opacity = al;
		s.position = Vec2(x, H - y);
		s.visible = true;
		s.addTo(p);
		return s;
	};

	const img = (p: Node.Type, file: string, x: number, y: number, w: number, h: number): Sprite.Type => {
		const s = Sprite(file)!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		s.position = Vec2(x, H - y);
		s.visible = true;
		s.addTo(p);
		return s;
	};

	const label = (
		p: Node.Type, font: string, size: number, c: Color.Type,
		x: number, y: number, ax: number, ls: number,
	): Label.Type => {
		const lb = Label(font + ';' + Math.round(size * 2) + ';true')!;
		lb.color = c;
		lb.anchor = Vec2(ax, 1);
		lb.scaleX = 0.5;
		lb.scaleY = 0.5;
		lb.position = Vec2(x, H - y + size);
		if (ls > 0) { lb.spacing = Math.round(ls * 2); }
		lb.visible = true;
		lb.addTo(p);
		return lb;
	};

	const layer = Node();
	layer.size = Size(W, H);
	layer.anchor = Vec2(0, 0);
	layer.position = Vec2(0, 0);
	layer.addTo(parent);

	/* ══════════ 静态底 ══════════ */
	block(layer, 0, 0, W, H, C_PAPER);
	img(layer, 'Image/StartUI/lv3_rampart.png', 0, 0, 1280, 86);
	img(layer, 'Image/StartUI/lv3_grid.png', OX, OY, GW, GH);

	/* ══════════ 动态层 ══════════ */
	const dn = DrawNode()!;
	dn.addTo(layer);

	/* ══════════ 底部操作提示带（HTML 的 ⑦） ══════════ */
	const ST_X0 = OX, ST_X1 = OX + GW;
	block(layer, ST_X0, ST_Y, ST_X1 - ST_X0, H - ST_Y, Color(228, 220, 195, 255));
	block(layer, ST_X0, ST_Y, ST_X1 - ST_X0, 1, C_SEAM, 0.5);

	// 四个方向键
	const ks = 30, kg = 4, kx = 128, ky = 660;
	// 键帽画成 WASD 的排布：W 在上、A S D 在下（真键盘的位置，不用想）
	const keyDef: [string, number, number][] = [
		['W', kx + ks + kg, ky],
		['A', kx, ky + ks + kg],
		['S', kx + ks + kg, ky + ks + kg],
		['D', kx + 2 * (ks + kg), ky + ks + kg],
	];
	// 键帽：纸面 + 墨边 + 右下 2px 硬投影，才读得出「这是一颗键」而不是一个空框
	const mkKey = (x: number, y: number, ch: string): void => {
		block(layer, x + 2, y + 2, ks, ks, C_DEEP, 0.14);
		block(layer, x, y, ks, ks, Color(252, 247, 232, 255));
		block(layer, x, y, ks, 1.4, C_INK, 0.62);
		block(layer, x, y + ks - 1.4, ks, 1.4, C_INK, 0.62);
		block(layer, x, y, 1.4, ks, C_INK, 0.62);
		block(layer, x + ks - 1.4, y, 1.4, ks, C_INK, 0.62);
		label(layer, FONT_B, 15, C_DEEP, x + ks / 2, y + 21, 0.5, 0).text = ch;
	};
	for (const kd of keyDef) { mkKey(kd[1], kd[2], kd[0]); }
	// R 单独一枚：和 ASD 同一行，中间留一格空隙，读起来是「另一组功能」
	const rkx = kx + 3 * (ks + kg) + 10;
	mkKey(rkx, ky + ks + kg, 'R');

	// 键位说明：一行说完三组键
	label(layer, FONT_B, 13, Color(36, 73, 70, 230), kx, ky + 2 * (ks + kg) + 28, 0, 0.8)
		.text = 'WASD 改道　R 重开';

	// 五条规则
	const rows: [string, string][] = [
		['改道', '水只往前，你能改的只有方向。'],
		['选边', '贴哪边过田口，哪边的田才涨水。'],
		['带水', '续命 2/3/4 格，升档 3/4/5 格；短了只续命，不会升。'],
		['撞岸', '水头断两格；见底了就卡住半秒。'],
		['旱退', '久了不灌就退档，退到干就荒了。'],
		['水沟', '踩上去多带一格，满六格就没了。'],
	];
	for (let i = 0; i < rows.length; i++) {
		const y = 656 + i * 21;
		block(layer, 290, y - 11, 4, 13, C_TEAL);
		label(layer, FONT_M, 13, C_DEEP, 303, y, 0, 1.5).text = rows[i][0];
		label(layer, FONT_R, 12.5, Color(36, 73, 70, 209), 346, y, 0, 0.3).text = rows[i][1];
	}

	// 分隔线
	block(layer, 768, ST_Y + 10, 1, H - 10 - (ST_Y + 10), C_SEAM, 0.42);

	/* ══════════ 王梓 + 提示框 ══════════ */
	const wzSmall = img(layer, 'Image/StartUI/face_wave.png', 1134, 800 - 134, 100, 134);

	// 提示框单独一组：关前页要藏起来（HTML 里 drawPanel 在 intro 直接 return），
	// 不然气泡和卡片抢注意力，而且卡片本身就在讲同一件事
	const panelRoot = Node();
	panelRoot.size = Size(W, H);
	panelRoot.anchor = Vec2(0, 0);
	panelRoot.position = Vec2(0, 0);
	panelRoot.addTo(layer);

	block(panelRoot, 792, 690, 332, 108, Color(252, 247, 232, 255));
	block(panelRoot, 792, 690, 332, 1, C_SEAM, 0.9);
	block(panelRoot, 792, 797, 332, 1, C_SEAM, 0.9);
	block(panelRoot, 792, 690, 1, 108, C_SEAM, 0.9);
	block(panelRoot, 1123, 690, 1, 108, C_SEAM, 0.9);
	label(panelRoot, FONT_R, 10.5, Color(36, 73, 70, 107), 806, 712, 0, 2).text = '王 梓';
	block(panelRoot, 806, 719, 42, 1, C_SEAM, 0.55);

	// HUD 刻字：底图不烘字了（原来烘在图里，和图外的 DrawNode 小格差 8~10px，
	// 读起来就是「小格飘在字上面」）。现在字和小格都由这里出，天然对齐
	// 字号按 Label 的实际墨迹上调了 ~1.3 倍：同一个数字，Label 的汉字墨迹比 canvas
	// 的小一圈（印章「叁」那次也是这样），照抄 canvas 的字号会偏小
	label(layer, FONT_B, 26, C_DEEP, 24, 48, 0, 2.5).text = '叁 · 引流';
	label(layer, FONT_R, 16, Color(36, 73, 70, 184), 150, 47, 0, 1).text = '八块田 · 每块三趟';
	label(layer, FONT_R, 14, Color(36, 73, 70, 117), 508, 47, 0, 0).text = '田';
	label(layer, FONT_R, 14, Color(36, 73, 70, 117), 1048, 47, 0, 0).text = '水量';

	const pourLb = label(layer, FONT_R, 16, Color(36, 73, 70, 178), 772, 47, 0, 0.4);

	// 田块上的读数：8 个「需 N」+ 最急那块的一个秒数
	const needLb: Label.Type[] = [];
	for (let i = 0; i < 8; i++) {
		needLb.push(label(layer, FONT_R, 16, C_TEAL, 0, 0, 1, 0.5));
	}
	const secLb = label(layer, FONT_B, 14, C_DEEP, 0, 0, 1, 0.3);

	/* ══════════ 自动条（王梓代打）══════════
	   单独一层。原来画在 dn 上，而 dn 在所有 Label 之下 —— 田里的「需 N」
	   会浮到面板上面，读起来像面板是半透明的。 */
	const ABT_X = 940, ABT_Y = 574, ABT_W = 250, ABT_H = 44;
	const ABT_BX = ABT_X + ABT_W - 92, ABT_BY = ABT_Y + 7, ABT_BW = 84, ABT_BH = 30;

	const autoRoot = Node();
	autoRoot.size = Size(W, H);
	autoRoot.anchor = Vec2(0, 0);
	autoRoot.position = Vec2(0, 0);
	autoRoot.visible = false;
	autoRoot.addTo(layer);

	block(autoRoot, ABT_X + 5, ABT_Y + 5, ABT_W, ABT_H, C_DEEP, 0.90);
	block(autoRoot, ABT_X, ABT_Y, ABT_W, ABT_H, C_PAPER2);
	block(autoRoot, ABT_X, ABT_Y, ABT_W, 1.2, C_DEEP);
	block(autoRoot, ABT_X, ABT_Y + ABT_H - 1.2, ABT_W, 1.2, C_DEEP);
	block(autoRoot, ABT_X, ABT_Y, 1.2, ABT_H, C_DEEP);
	block(autoRoot, ABT_X + ABT_W - 1.2, ABT_Y, 1.2, ABT_H, C_DEEP);
	block(autoRoot, ABT_X + 3, ABT_Y + 3, 6, ABT_H - 6, C_VERM);
	const abtFace = block(autoRoot, ABT_BX, ABT_BY, ABT_BW, ABT_BH, C_VERM);
	block(autoRoot, ABT_BX, ABT_BY, ABT_BW, 1.8, C_DEEP);
	block(autoRoot, ABT_BX, ABT_BY + ABT_BH - 1.8, ABT_BW, 1.8, C_DEEP);
	block(autoRoot, ABT_BX, ABT_BY, 1.8, ABT_BH, C_DEEP);
	block(autoRoot, ABT_BX + ABT_BW - 1.8, ABT_BY, 1.8, ABT_BH, C_DEEP);
	label(autoRoot, FONT_B, 22, C_DEEP, ABT_X + 22, ABT_Y + 30, 0, 2).text = '王梓在操作';
	label(autoRoot, FONT_B, 19, C_PAPER2, ABT_BX + ABT_BW / 2, ABT_BY + 22, 0.5, 2).text = '让我来';
	const hintLb = label(layer, FONT_R, 13, Color(36, 73, 70, 230), 810, 748, 0, 0.4);
	const clockLb = label(layer, FONT_B, 14, C_INK, 1108, 712, 1, 1);

	const pauseLb1 = label(layer, FONT_B, 44, C_DEEP, 640, 396, 0.5, 8);
	pauseLb1.text = '';
	const pauseLb2 = label(layer, FONT_R, 18, Color(36, 73, 70, 153), 640, 440, 0.5, 1);
	pauseLb2.text = '';

	/* ══════════ 状态 ══════════ */
	let fields: Field[] = [];
	let water: Cell[] = [];
	let dir = 'd';
	let pendingQ: string[] = [];    // 预输入队列：最多两步，连按不丢
	let len = LEN_0;
	let ditches: Cell[] = [];     // 场上最多一股水沟（DITCH_MAX）
	let ditchT = 0;
	let speed = SPD_0;
	let stuck = false;
	let stun = 0;
	let acc = 0;
	let startDelay = START_DELAY;
	let poured = 0;
	let done = 0;
	let t = 0;
	let hint = '';
	let hintT = 0;
	let flash = 0;
	let flashAt: Cell | undefined = undefined;
	let phase = 'intro';   // intro → play → win / lose
	let finished = false;
	let paused = false;
	let ptrX = -999, ptrY = -999;
	let rx = 0, ry = 0, rInit = false;   // 水头的渲染位置（追着格子走）
	let autoOn = opts.auto === true;   // 王梓代打，可被「让我来」关掉
	let wantBegin = false;    // 关前页按了开始：交给 update 执行，避开前向引用
	let wantRestart = false;  // 结算卡上按了重来
	let overT = 0;            // 结算计时（胜负之后）
	let deadIdx = -1;         // 荒掉的是哪块田
	let wantFinish = false;   // skip() 只置这个，真正回调留给 update ——
	                          // TSTL 对「把外部函数当值传递」的 this 推断有坑，绕开

	const reset = (): void => {
		fields = FIELD_DEF.map((f) => ({
			cn: f.cn, c0: f.c0, r0: f.r0, c1: f.c1, r1: f.r1,
			lv: 0, timer: NEVER_GRACE, everWatered: false, refuseT: 0,
		}));
		// 水从水门（第 14 列、第 0 行）往下
		water = [{ c: 14, r: 0 }];
		while (water.length < len) { water.push({ c: 14, r: -1 }); }
		ditches = [];
		ditchT = 0;
		rInit = false;
		dir = 'd';
		pendingQ = [];
		len = LEN_0;
		speed = SPD_0;
		stuck = false;
		stun = 0;
		acc = 0;
		startDelay = START_DELAY;
		poured = 0;
		done = 0;
		t = 0;
		hint = '把水引进田口。撞岸会断尾。';
		hintT = 3.2;
		flash = 0;
		flashAt = undefined;
		phase = 'play';
		paused = false;
		finished = false;
		spawnDitch();            // 开局场上就有一股，别让第一圈空跑
		overT = 0;
		deadIdx = -1;
	};

	const say = (s: string, dur: number): void => { hint = s; hintT = dur; };

	/* ══════════ 水沟 ══════════
	   长度只能靠捡水沟涨：开局 2 格，秧田要 5 格，光靠走是永远灌不进去的。
	   场上最多一股，被喝掉之后 4 秒补一股；满 6 格就不再刷。 */
	const spawnDitch = (): void => {
		if (len >= LEN_MAX) { return; }
		if (ditches.length >= DITCH_MAX) { return; }
		const pool: Cell[] = [];
		for (const r of DITCH_ROWS) {
			for (let c = 1; c < COLS - 1; c++) {
				if (!isCh(c, r)) { continue; }
				if (gateAt(c, r) !== undefined) { continue; }
				if (water.some((w) => w.c === c && w.r === r)) { continue; }
				if (ditches.some((d) => d.c === c && d.r === r)) { continue; }
				pool.push({ c: c, r: r });
			}
		}
		if (pool.length === 0) { return; }
		ditches.push(pool[Math.floor(Math.random() * pool.length)]);
	};

	const clearDitches = (): void => { ditches = []; ditchT = 0; };

	const ditchTick = (dt: number): void => {
		if (len >= LEN_MAX) { if (ditches.length > 0) { clearDitches(); } return; }
		if (ditches.length >= DITCH_MAX) { return; }
		// 场上没有就立刻补，别让玩家空等
		if (ditches.length === 0) { spawnDitch(); ditchT = 0; return; }
		ditchT += dt;
		while (ditchT >= DITCH_T) { ditchT -= DITCH_T; spawnDitch(); }
	};

	const eatDitch = (c: number, r: number): void => {
		let idx = -1;
		for (let i = 0; i < ditches.length; i++) {
			if (ditches[i].c === c && ditches[i].r === r) { idx = i; break; }
		}
		if (idx < 0) { return; }
		ditches.splice(idx, 1);
		ditchT = 0;                       // 喝掉这一股，才开始计下一股
		if (len < LEN_MAX) {
			len = Math.min(LEN_MAX, len + 1);
			say('捡到一股水，多带一格（' + len.toString() + ' / ' + LEN_MAX.toString() + '）', 2.0);
			if (len >= LEN_MAX) { clearDitches(); }
		}
	};

	const pourInto = (f: Field): void => {
		if (f.lv >= NEED) { return; }
		f.lv++;
		f.everWatered = true;
		poured++;
		Audio.play(THUD);
		if (f.lv >= NEED) {
			f.timer = Infinity;
			done++;
			speed = Math.min(SPD_MAX, SPD_0 + done * SPD_STEP);
			say(f.cn + ' 熟了。', 2.0);
			if (done >= FIELD_DEF.length) { phase = 'win'; overT = 0; }
		} else {
			f.timer = WIN_KEEP;
			say(f.cn + ' 吃到一趟（' + f.lv.toString() + ' / 3），下次要 '
				+ NEED_LEN[f.lv].toString() + ' 格', 1.8);
		}
	};

	const refuse = (f: Field): void => {
		if (f.refuseT > 0) { return; }
		f.refuseT = 0.9;
		Audio.play(SOUR);
		say('水不够。' + f.cn + ' 要 ' + NEED_LEN[f.lv].toString() + ' 格，你只有 ' + len.toString() + ' 格。', 2.2);
	};

	const breach = (h: Cell): void => {
		stuck = true;
		flash = 0.45;
		flashAt = h;
		Audio.play(SOUR);
		if (len <= 1) {
			stun = STUN;
			say('水见底了，卡住了半拍。', 2.2);
		} else {
			len = Math.max(1, len - CUT);
			while (water.length > len) { water.pop(); }
			say('水头撞岸了，断掉两格（' + len.toString() + ' / ' + LEN_MAX.toString() + '）', 2.2);
		}
	};

	/* 预输入：按键立刻入队，走到下一格才消化。
	   上限两步 —— 一格的窗口是 ~0.2s，人手快的时候会连按两下；
	   只存一步的话第二下会被覆盖，转两次弯就丢一次。
	   同向连按只算一次（否则队列会被同一个方向塞满，真该转的时候没有位置）。 */
	const enqueue = (d: string): void => {
		if (d === OPP[dir]) { return; }                       // 直接掉头非法
		const last = pendingQ.length > 0 ? pendingQ[pendingQ.length - 1] : dir;
		if (d === last) { return; }
		if (pendingQ.length >= 2) { pendingQ.shift(); }
		pendingQ.push(d);
	};

	const step = (): void => {
		if (autoOn) {
			const ad = autoDir();
			if (ad !== undefined) { enqueue(ad); }
		}
		// 预输入：每走一格消化一条。和当前方向反向的丢掉（不能掉头）
		if (pendingQ.length > 0) {
			const d = pendingQ.shift()!;
			if (d !== OPP[dir]) { dir = d; }
		}

		const h = water[0];
		const v = DIRV[dir];
		const nc = h.c + v.c, nr = h.r + v.r;

		if (!isCh(nc, nr)) { breach(h); return; }

		water.unshift({ c: nc, r: nr });
		while (water.length > len) { water.pop(); }
		eatDitch(nc, nr);

		// 田口：整条水压到的格都算，但同一块田一趟只算一次
		const hit: number[] = [];
		for (const s of water) {
			const g = gateAt(s.c, s.r);
			if (g === undefined || hit.indexOf(g.f) >= 0) { continue; }
			const f = fields[g.f];
			if (f === undefined || f.lv >= NEED) { continue; }
			hit.push(g.f);
			if (len < RESET_LEN[f.lv]) { refuse(f); continue; }
			if (len < NEED_LEN[f.lv]) {
				f.timer = WIN_KEEP;
				say(f.cn + ' 续了一趟（' + len.toString() + ' 格），升档要 '
					+ NEED_LEN[f.lv].toString() + ' 格', 1.8);
				continue;
			}
			pourInto(f);
			if (phase !== 'play') { return; }
		}
	};

	/* ══════════ 王梓代打（对照 HTML 的 autoDir） ══════════
	   BFS 一次算出「从水头到每格的第一步」，然后按优先级挑目标：
	   水够长的最紧急的田口 > 水沟（补长度） > 直行。
	   只在 auto 模式下每步调用一次。 */
	const autoDir = (): string | undefined => {
		const h = water[0];
		const key = (c: number, r: number): string => c.toString() + ',' + r.toString();
		const dist = new Map<string, number>();
		const first = new Map<string, string>();
		const qc: number[] = [h.c];
		const qr: number[] = [h.r];
		dist.set(key(h.c, h.r), 0);
		for (let qi = 0; qi < qc.length; qi++) {
			const c = qc[qi], r = qr[qi];
			const dirs = ['u', 'd', 'l', 'r'];
			for (const k of dirs) {
				if (c === h.c && r === h.r && k === OPP[dir]) { continue; }
				const v = DIRV[k];
				const nc = c + v.c, nr = r + v.r;
				if (!isCh(nc, nr)) { continue; }
				const kk = key(nc, nr);
				if (dist.has(kk)) { continue; }
				dist.set(kk, dist.get(key(c, r))! + 1);
				first.set(kk, dist.get(key(c, r)) === 0 ? k : first.get(key(c, r))!);
				qc.push(nc);
				qr.push(nr);
			}
		}

		// 第一优先：水够长、且最紧急的田口
		let best: string | undefined = undefined;
		let bestScore = -1e9;
		for (const f of fields) {
			if (f.lv >= NEED) { continue; }
			if (len < NEED_LEN[f.lv]) { continue; }
			for (const g of GATES) {
				if (g.f !== fields.indexOf(f)) { continue; }
				const kk = key(g.c, g.r);
				if (!dist.has(kk)) { continue; }
				const d = dist.get(kk)!;
				if (d === 0) { continue; }
				const tm = f.timer === Infinity ? NEVER_GRACE : f.timer;
				const score = (NEVER_GRACE - tm) - d * 1.6;
				if (score > bestScore) { bestScore = score; best = first.get(kk); }
			}
		}
		if (best !== undefined) { return best; }

		// 第二优先：缺水时先捡水沟
		if (len < LEN_MAX && ditches.length > 0) {
			let bd = 1e9;
			let bk: string | undefined = undefined;
			for (const d of ditches) {
				const kk = key(d.c, d.r);
				if (!dist.has(kk)) { continue; }
				const dd = dist.get(kk)!;
				if (dd < bd) { bd = dd; bk = first.get(kk); }
			}
			if (bk !== undefined && bd > 0) { return bk; }
		}

		// 第三：直行，撞墙就拐一个能走的
		const v = DIRV[dir];
		if (isCh(h.c + v.c, h.r + v.r)) { return dir; }
		for (const k of ['u', 'd', 'l', 'r']) {
			if (k === OPP[dir]) { continue; }
			const w = DIRV[k];
			if (isCh(h.c + w.c, h.r + w.r)) { return k; }
		}
		return undefined;
	};

	const press = (d: string): void => {
		if (phase === 'intro') { wantBegin = true; return; }   // 关前页按方向键也算开始
		if (phase !== 'play' || paused) { return; }
		if (stuck) {
			// 卡住时：眩晕期先存着，眩晕结束按对方向直接脱困
			if (stun > 0) { enqueue(d); return; }
			const h = water[0], v = DIRV[d];
			if (isCh(h.c + v.c, h.r + v.r) && d !== OPP[dir]) {
				dir = d; stuck = false; acc = 0; stun = 0; pendingQ = [];
			}
			return;
		}
		enqueue(d);
	};

	/* ══════════ 每帧 ══════════ */
	const tick = (dt: number): void => {
		if (phase === 'win' || phase === 'lose') { overT += dt; return; }
		if (phase !== 'play') { return; }
		t += dt;
		if (hintT > 0) { hintT -= dt; }
		if (flash > 0) { flash -= dt; }
		for (const f of fields) { if (f.refuseT > 0) { f.refuseT -= dt; } }

		if (startDelay > 0) { startDelay -= dt; return; }

		ditchTick(dt);

		if (stun > 0) {
			stun -= dt;
		} else {
			acc += dt;
			const per = 1 / speed;
			while (acc >= per) {
				acc -= per;
				step();
				if (phase !== 'play') { break; }
			}
		}

		// 田会干：熟田锁定，干田归零就输
		for (let i = 0; i < fields.length; i++) {
			const f = fields[i];
			if (f.lv >= NEED) { continue; }
			f.timer -= dt;
			if (f.timer <= 0) {
				if (f.lv === 0) { phase = 'lose'; overT = 0; deadIdx = i; return; }
				f.lv--;
				// 退档要把「灌溉 N / 24」一起退回去。poured 必须恒等于 Σlv，
				// 少这一步，八块各退一次之后进度会滚到 26 / 24
				poured = Math.max(0, poured - 1);
				f.timer = f.lv === 0 ? DRY_GRACE : WIN_KEEP;
			}
		}
	};

	/* ══════════ 绘制 ══════════ */
	const cw = (c: number): number => OX + c * G;
	const ch = (r: number): number => OY + r * G;

	/* 水头平滑：逻辑还是一格一格跳，渲染位置按 16/s 的速率追过去。
	   直接按格画太生硬 —— 一格 24px、速度 3.9 格/s，等于每秒硬跳 4 次。 */
	const smoothHead = (dt: number): void => {
		const h0 = water[0];
		if (h0 === undefined) { return; }
		const tx = OX + h0.c * G;
		const ty = OY + h0.r * G;
		// 首帧 / 传送（撞岸重置）时直接对齐，别让它横穿整张图
		if (!rInit || Math.abs(rx - tx) > G * 3 || Math.abs(ry - ty) > G * 3) {
			rx = tx; ry = ty; rInit = true;
			return;
		}
		const k = Math.min(1, dt * 16);
		rx += (tx - rx) * k;
		ry += (ty - ry) * k;
	};

	const draw = (): void => {
		dn.clear();

		// 田：整块铺档位色
		for (const f of fields) {
			if (f.lv <= 0) { continue; }
			const x = cw(f.c0), y = ch(f.r0);
			const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
			const col = f.lv >= NEED ? C_LV3 : (f.lv === 2 ? C_LV2 : C_LV1);
			dn.drawRect(Rect(x, H - y - h, w, h), col, 0);
		}

		/* ── 田里的纹理：纯色太「平」，不同档位给不同的耕作痕迹 ──
		   湿田＝三道浅沟 + 几处水印；苗田/熟田＝一行行短竖笔的秧行（熟田更密、偏金） */
		for (const f of fields) {
			if (f.lv <= 0) { continue; }
			const x = cw(f.c0), y = ch(f.r0);
			const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
			if (f.lv === 1) {
				for (let r = 1; r <= 3; r++) {
					const ly = y + h * r / 4;
					dn.drawSegment(Vec2(x + 6, H - ly), Vec2(x + w - 6, H - ly), 1.2, Color(58, 92, 88, 46));
				}
				for (let c = 1; c <= 4; c++) {
					const lx = x + w * c / 5;
					const ly = y + h * (c % 2 === 0 ? 0.34 : 0.66);
					dn.drawSegment(Vec2(lx, H - (ly + 5)), Vec2(lx - 9, H - (ly - 3)), 1.6, Color(58, 92, 88, 38));
				}
			} else {
				const rows = 4;
				const step = f.lv >= NEED ? 14 : 18;
				const col = f.lv >= NEED ? Color(126, 112, 56, 104) : Color(52, 86, 74, 92);
				const tall = f.lv >= NEED ? 5 : 4;
				for (let r = 0; r < rows; r++) {
					const ly = y + h * (r + 0.5) / rows;
					for (let lx = x + 8; lx < x + w - 8; lx += step) {
						dn.drawSegment(Vec2(lx, H - (ly + tall)), Vec2(lx, H - (ly - tall)), 1.5, col);
					}
				}
			}
		}

		/* ── 干边：1/2 档从四边往里干进去；0 档且曾灌过，整块发黄告警 ──
		   前 50% 由水位条报数，干边只负责最后一半的紧迫感（HTML 同款分界） */
		for (const f of fields) {
			if (f.lv >= NEED) { continue; }
			const x = cw(f.c0), y = ch(f.r0);
			const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
			const base = f.lv === 2 ? C_LV2 : C_LV1;
			if (f.lv > 0) {
				const remain = Math.min(1, Math.max(0, f.timer / WIN_KEEP));
				if (remain >= 0.5) { continue; }
				const t2 = Math.max(2, (0.5 - remain) / 0.5 * 9);
				const dry = mixColor(base, C_GOLD, 0.50);
				dn.drawRect(Rect(x, H - y - t2, w, t2), dry, 0);
				dn.drawRect(Rect(x, H - y - h, w, t2), dry, 0);
				dn.drawRect(Rect(x, H - y - h, t2, h), dry, 0);
				dn.drawRect(Rect(x + w - t2, H - y - h, t2, h), dry, 0);
				const t3 = t2 * 0.52;
				const deep2 = mixColor(mixColor(base, C_SAND, 0.70), C_GOLD, 0.30);
				dn.drawRect(Rect(x, H - y - t3, w, t3), deep2, 0);
				dn.drawRect(Rect(x, H - y - h, w, t3), deep2, 0);
				dn.drawRect(Rect(x, H - y - h, t3, h), deep2, 0);
				dn.drawRect(Rect(x + w - t3, H - y - h, t3, h), deep2, 0);
				if (remain < 0.32) {
					dn.drawRect(Rect(x + 2.5, H - y - h + 2.5, w - 5, h - 5), Color(0, 0, 0, 0), 1.6,
						Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 242));
				}
			} else if (f.everWatered) {
				const remain = Math.min(1, Math.max(0, f.timer / DRY_GRACE));
				const tint = mixColor(C_SAND, C_GOLD, 0.55);
				dn.drawRect(Rect(x, H - y - h, w, h), Color(tint.r, tint.g, tint.b, Math.round(255 * (0.10 + 0.26 * (1 - remain)))), 0);
				if (remain < 0.5) {
					dn.drawRect(Rect(x + 2.5, H - y - h + 2.5, w - 5, h - 5), Color(0, 0, 0, 0), 1.8,
						Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 242));
				}
			}
		}

		/* ── 田块读数（HTML 的 drawFieldClocks） ──
		   ① 顶部水位条：按「还剩多久退档」缩短，带刻度才读作计量条
		   ② 三格进度：实心几个＝灌了几趟（颜色在小尺寸下会认错，所以双编码）
		   ③ 需 N：这块田现在要几格水
		   ④ 秒数只给「全局最急的那块」——八块都报就没人读了 */
		let urgent = -1;
		secLb.text = '';
		for (let i = 0; i < fields.length; i++) {
			const f = fields[i];
			if (f.lv >= NEED) { continue; }
			if (urgent < 0 || f.timer < fields[urgent].timer) { urgent = i; }
		}
		for (let i = 0; i < fields.length; i++) {
			const f = fields[i];
			const x = cw(f.c0), y = ch(f.r0);
			const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
			if (f.lv >= NEED) { needLb[i].text = ''; continue; }

			const span = f.lv > 0 ? WIN_KEEP : (f.everWatered ? DRY_GRACE : NEVER_GRACE);
			const remain = Math.min(1, Math.max(0, f.timer / span));
			const dryBack = f.lv === 0 && f.everWatered;
			const never = f.lv === 0 && !f.everWatered;

			const bx = x + 10, by = y + 13, bw = w - 20, bh = 7;
			dn.drawRect(Rect(bx, H - by - bh, bw, bh), Color(23, 51, 48, never ? 61 : 112), 0);
			let col = never ? mixColor(C_PAPER, C_DEEP, 0.44)
				: dryBack ? mixColor(C_SAND, C_GOLD, 0.55)
					: mixColor(Color(243, 234, 211, 255), C_SAND, 0.28);
			if (remain < 0.30) { col = C_GOLD; }
			dn.drawRect(Rect(bx + 1, H - by - bh + 1, Math.max(0, (bw - 2) * remain), bh - 2), col, 0);
			for (let sx = bx + 22; sx < bx + bw - 1; sx += 22) {
				dn.drawRect(Rect(sx, H - by - bh + 1.5, 1, bh - 3), Color(23, 51, 48, 38), 0);
			}
			dn.drawRect(Rect(bx + 0.5, H - by - bh + 0.5, bw - 1, bh - 1), Color(0, 0, 0, 0), 1,
				Color(36, 73, 70, 87));

			// 秒数：只在最急的那块、且已经过半时出现
			if (i === urgent && remain < 0.55) {
				const tw = 34;
				const tx2 = Math.max(bx + (bw - 2) * remain + 4, bx + bw - tw);
				const blink = remain < 0.16 ? (0.40 + 0.60 * Math.abs(Math.sin(t * 5.5))) : 0.92;
				dn.drawRect(Rect(tx2, H - by - bh - 2 - 14, tw, 14), Color(243, 234, 211, 224), 0);
				secLb.text = Math.ceil(f.timer).toString() + 's';
				secLb.position = Vec2(tx2 + tw - 3, H - (by + bh + 2 + 13) + 14);
				secLb.color = Color(23, 51, 48, Math.round(255 * blink));
			}

			// 三格进度
			for (let k = 0; k < NEED; k++) {
				const px2 = x + 11 + k * 8, py2 = y + 24;
				if (k < f.lv) {
					dn.drawRect(Rect(px2, H - py2 - 6, 6, 6), C_GOLD, 1, Color(36, 73, 70, 56));
				} else {
					dn.drawRect(Rect(px2, H - py2 - 6, 6, 6), Color(0, 0, 0, 0), 1, Color(23, 51, 48, 87));
				}
			}

			// 需 N
			const n = NEED_LEN[f.lv];
			const ok = len >= n;
			needLb[i].text = '需 ' + n.toString();
			needLb[i].color = ok ? C_TEAL : Color(23, 51, 48, 140);
			needLb[i].position = Vec2(x + w - 12, H - (y + h - 10) + 16);
		}

		/* 田口：闸板 + 内侧引水沟。
		   引水沟一格就把「这门现在开不开」说完——
		   亮青＝水够能开　深灰＋一道横杠＝水不够　浅金＝已熟。挡回时只让横杠闪亮。 */
		for (const g of GATES) {
			const f = fields[g.f];
			if (f === undefined) { continue; }
			const x = cw(g.c), y = ch(g.r);
			const full = f.lv >= NEED;
			const west = g.side === 'w';

			// 闸板
			const bx = west ? x - 2 : x + G - 2;
			dn.drawRect(Rect(bx, H - y - G + 4, 4, G - 8), full ? C_GOLD : C_DEEP, 0);
			dn.drawRect(Rect(bx, H - y - G + 4, 1, G - 8), Color(36, 73, 70, 128), 0);
			dn.drawRect(Rect(bx - 1, H - y - G + 3, 6, 2), Color(23, 51, 48, 128), 0);
			dn.drawRect(Rect(bx - 1, H - y - 5, 6, 2), Color(23, 51, 48, 128), 0);

			// 引水沟
			const okLen = len >= NEED_LEN[f.lv];
			const fx = west ? x - 13 : x + G + 1;
			const fy = y + G / 2 - 8;
			const fc = full ? mixColor(C_GOLD, C_PAPER, 0.30)
				: okLen ? mixColor(C_TEAL, C_PAPER, 0.46)
					: Color(23, 51, 48, 148);
			dn.drawRect(Rect(fx, H - fy - 16, 13, 16), fc, 1, Color(36, 73, 70, 56));
			if (!full && !okLen) {
				const a = f.refuseT > 0 ? Math.min(1, Math.max(0, f.refuseT / 0.9)) : 0;
				dn.drawRect(Rect(fx + 2, H - fy - 9, 9, 2),
					Color(243, 234, 211, Math.round(255 * (a > 0 ? 0.45 + 0.55 * a : 0.42))), 0);
			}
		}

		// 水沟：捡到就能多带一格 —— 长度的唯一来源，画得显眼一点
		for (const d of ditches) {
			const x = cw(d.c) + 2, y = ch(d.r) + 8;
			const w = G - 4, h = 13;
			dn.drawRect(Rect(x, H - y - h, w, h), Color(23, 51, 48, 66), 0);
			dn.drawRect(Rect(x + 2, H - y - h + 2.5, w - 4, h - 5), Color(237, 227, 200, 77), 0);
			dn.drawRect(Rect(x + 5, H - y - h + 4.5, w - 12, 1.6), Color(237, 227, 200, 168), 0);
			dn.drawRect(Rect(x + 7, H - y - h + 7.5, w - 17, 1.4), Color(237, 227, 200, 140), 0);
			dn.drawRect(Rect(x, H - y - h, 2, h), Color(23, 51, 48, 92), 0);
			dn.drawRect(Rect(x + w - 2, H - y - h, 2, h), Color(23, 51, 48, 92), 0);
		}

		// 水身：连成一条带，宽度从 0.62G 收到 0.16G。
		// 原来逐格画方块，读起来像撒了一把豆子；连成折线才有「水流」的意思（HTML 同款画法）
		if (water.length >= 2) {
			for (let i = water.length - 1; i >= 1; i--) {
				const a0 = water[i], a1 = water[i - 1];
				if (a0.r < 0 || a1.r < 0) { continue; }
				const t2 = (water.length <= 2) ? 1 : (i - 1) / (water.length - 1);
				const w = G * (0.62 - 0.46 * t2);
				const al = Math.round(255 * (0.92 - 0.42 * t2));
				const fromX = i === 1 && rInit ? rx + G / 2 : cw(a1.c) + G / 2;
				const fromY = i === 1 && rInit ? ry + G / 2 : ch(a1.r) + G / 2;
				dn.drawSegment(
					Vec2(cw(a0.c) + G / 2, H - (ch(a0.r) + G / 2)),
					Vec2(fromX, H - fromY),
					Math.max(1.4, w / 2), Color(C_TEAL.r, C_TEAL.g, C_TEAL.b, al),
				);
			}
		}

		// 水头：墨核 + 纸色高光 + 深墨细环。
		// 引擎画不了圆，用「方核 + 内缩一圈的深色细环」近似，24px 的格子上看不出棱角
		const hd = water[0];
		if (hd !== undefined && hd.r >= 0) {
			const hx = (rInit ? rx : cw(hd.c)) + G / 2, hy = (rInit ? ry : ch(hd.r)) + G / 2;
			const R = G * 0.40;
			dn.drawRect(Rect(hx - R, H - hy - R, R * 2, R * 2), C_DEEP, 0);
			dn.drawRect(Rect(hx - R * 0.55, H - hy - R * 0.30 - 4, 4, 4), Color(252, 247, 232, 217), 0);

			// 见底：金环脉动，提示「再加一格水就断」
			if (len <= 1) {
				const ga = Math.round(255 * (0.35 + 0.45 * Math.abs(Math.sin(t * 6))));
				dn.drawRect(Rect(hx - R - 6, H - hy - R - 6, (R + 6) * 2, (R + 6) * 2),
					Color(0, 0, 0, 0), 2.4, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, ga));
			}
		}

		// 撞岸闪光
		if (flash > 0 && flashAt !== undefined) {
			const a = Math.round(200 * (flash / 0.45));
			dn.drawRect(
				Rect(cw(flashAt.c) - 2, H - ch(flashAt.r) - G - 2, G + 4, G + 4),
				Color(0, 0, 0, 0), 2.4, Color(163, 59, 42, a),
			);
		}

		// 水量格（墙上 6 格）
		const sx = 1088, sw = 20, sg = 28;
		for (let i = 0; i < LEN_MAX; i++) {
			const x = sx + i * sg, y = 30, hh = 15;
			const fill = i < len
				? (i < 2 ? Color(56, 96, 90, 255) : C_TEAL)
				: Color(36, 73, 70, 16);
			dn.drawRect(Rect(x, H - y - hh, sw, hh), fill, 1,
				Color(36, 73, 70, i < len ? 77 : 51));
		}
		dn.drawSegment(Vec2(sx + 2 * sg - 4, H - 14), Vec2(sx + 2 * sg - 4, H - 37), 0.7, C_GOLD);

		// 通关：八块田依次被金框钉住，一块错开 60ms
		if (phase === 'win') {
			for (let i = 0; i < fields.length; i++) {
				const k = Math.min(1, Math.max(0, (overT - i * 0.06) / 0.18));
				if (k <= 0) { continue; }
				const f = fields[i];
				const x = cw(f.c0), y = ch(f.r0);
				const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
				dn.drawRect(Rect(x, H - y - h, w, h),
					Color(252, 247, 232, Math.round(102 * (1 - k))), 0);
				dn.drawRect(Rect(x + 1.5, H - y - h + 1.5, w - 3, h - 3),
					Color(0, 0, 0, 0), 3, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, Math.round(235 * k)));
			}
		}

		// 失败：只标出荒掉的那一块 —— 八块都标等于没标
		if (phase === 'lose' && deadIdx >= 0) {
			const f = fields[deadIdx];
			const x = cw(f.c0), y = ch(f.r0);
			const w = (f.c1 - f.c0 + 1) * G, h = (f.r1 - f.r0 + 1) * G;
			const dry = mixColor(C_SEAM, C_GOLD, 0.45);
			dn.drawRect(Rect(x, H - y - h, w, h), Color(dry.r, dry.g, dry.b, 133), 0);
			dn.drawRect(Rect(x, H - y - h, w, h), Color(23, 51, 48, 26), 0);
			dn.drawRect(Rect(x + 1.5, H - y - h + 1.5, w - 3, h - 3),
				Color(0, 0, 0, 0), 3, Color(23, 51, 48, 179));
		}

		// 八块田的档位小格
		const px = 540;
		for (let i = 0; i < 8; i++) {
			const f = fields[i];
			const x = px + i * 26, y = 30, w = 19, hh = 15;
			const col = f.lv > 0 ? (f.lv >= NEED ? C_LV3 : (f.lv === 2 ? C_LV2 : C_LV1)) : C_EMPTY;
			dn.drawRect(Rect(x, H - y - hh, w, hh), col, 1,
				Color(36, 73, 70, f.lv >= 3 ? 117 : 61));
			// 快干的金点
			if (f.lv > 0 && f.lv < NEED && f.timer / WIN_KEEP < 0.34) {
				dn.drawRect(Rect(x + w - 5, H - y - hh, 4, 4), C_GOLD, 0);
			}
		}

		autoRoot.visible = autoOn && phase === 'play';
		if (autoOn) {
			const over = ptrX >= ABT_X && ptrX <= ABT_X + ABT_W && ptrY >= ABT_Y && ptrY <= ABT_Y + ABT_H;
			abtFace.color = over ? C_DEEP : C_VERM;
		}

		/* ── 暂停 ── */
		if (paused) {
			dn.drawRect(Rect(0, 0, W, H), Color(237, 227, 200, 140), 0);
			pauseLb1.text = '暂 停';
			pauseLb2.text = '按 Esc 继续';
		} else {
			pauseLb1.text = '';
			pauseLb2.text = '';
		}

		// 文字
		pourLb.text = '灌溉 ' + poured.toString() + ' / ' + TOTAL_POUR.toString();
		hintLb.text = (phase === 'play' && hintT > 0) ? hint : '';
		hintLb.color = Color(36, 73, 70, (phase === 'play' && hintT > 0) ? 255 : 0);
		// 设计纲要写明「这一关没有倒计时」，原来是按 28 秒倒着数、数到 0 什么都不发生。
		// 改成正计时的用时，只当参考
		clockLb.text = phase === 'play' ? '用时 ' + Math.round(t).toString() + ' s' : '';
	};

	/* ══════════ 关前页（对照 HTML drawIntro） ══════════
	   不盖整张卡：左侧铺一层纸色渐层，右下把渠网透出来。
	   第二关的关前页是整块纸底（那是室内），这一关在城外的渠网上，得留出地图。 */
	const introRoot = Node();
	introRoot.size = Size(W, H);
	introRoot.anchor = Vec2(0, 0);
	introRoot.position = Vec2(0, 0);
	introRoot.addTo(layer);

	// 纸色渐层：HTML 是 0.98 → 0.94(55%) → 0 的线性渐变，引擎没有渐变填充，
	// 用 16 条竖带逼近。带宽 59px，肉眼看不出接缝
	const WASH_N = 16, WASH_X1 = 940, WASH_MID = WASH_X1 * 0.55;
	for (let i = 0; i < WASH_N; i++) {
		const x0 = WASH_X1 * i / WASH_N;
		const x1 = WASH_X1 * (i + 1) / WASH_N;
		const mid = (x0 + x1) / 2;
		const a = mid <= WASH_MID
			? 0.98 - 0.04 * (mid / WASH_MID)
			: 0.94 * (1 - (mid - WASH_MID) / (WASH_X1 - WASH_MID));
		block(introRoot, x0, 0, x1 - x0 + 1, H, C_PAPER, a);
	}

	// 集中线：起势。画一次就够，静态的（HTML 里这一页也不转）
	const burstDn = DrawNode()!;
	burstDn.addTo(introRoot);
	for (let i = 0; i < 40; i++) {
		const ang = (i / 40) * Math.PI * 2 + 0.31;
		const j = ((i * 37) % 11) / 11;
		const r0 = 210 * (0.86 + 0.30 * j);
		const r1 = 360 * (0.72 + 0.46 * j);
		burstDn.drawSegment(
			Vec2(250 + Math.cos(ang) * r0, H - (330 + Math.sin(ang) * r0)),
			Vec2(250 + Math.cos(ang) * r1, H - (330 + Math.sin(ang) * r1)),
			0.8, Color(36, 73, 70, 26),
		);
	}

	// 立绘：右侧站定后轻轻呼吸
	const introWz = img(introRoot, 'Image/StartUI/face_wave.png', 918, 316, 286, 384);
	const introWzShadow = block(introRoot, 964, 704, 192, 10, C_INK, 0.10);

	// 印章「叁」
	const iSealBg = block(introRoot, 112, 196, 38, 38, C_VERM, 1);
	const iSealTx = label(introRoot, FONT_B, 27, Color(252, 247, 232, 255), 131, 226, 0.5, 0);
	iSealTx.text = '叁';
	const iQian = label(introRoot, FONT_B, 15, Color(36, 73, 70, 140), 158, 226, 0, 4);
	iQian.text = '关 前';

	// 标题
	const iTitle = label(introRoot, FONT_B, 82, C_INK, 106, 342, 0, 12);
	iTitle.text = '引 流';

	// 朱红横线 / 分隔线：用 scaleX 生长，改 size 会把 anchor 重置回中心
	const iRule = block(introRoot, 112, 366, 128, 4, C_VERM, 1);
	const iSep = block(introRoot, 112, 516, 448, 2, C_INK, 0.32);

	// 两句 + 说明
	const iL1 = label(introRoot, FONT_B, 22, Color(36, 73, 70, 220), 112, 434, 0, 1.4);
	iL1.text = '城墙三面临水，城里有两条渠。';
	const iL2 = label(introRoot, FONT_B, 22, Color(36, 73, 70, 220), 112, 474, 0, 1.4);
	iL2.text = '水从水门进来。船，也从这儿进来。';

	const iH1 = label(introRoot, FONT_B, 14, Color(36, 73, 70, 163), 112, 558, 0, 0.8);
	iH1.text = '八块田，每块三趟水。你是渠里那道水头。';
	const iH2 = label(introRoot, FONT_R, 14, Color(36, 73, 70, 163), 112, 586, 0, 0.5);
	iH2.text = '田越熟越挑水：干要三格，湿要四格，秧要五格。';

	// 按钮：硬投影 + 纸面 + 3px 墨框 + 朱红底呼吸
	// 按钮：悬停/按下时整块往右下推，**投影留在原地**——「投影收窄」就读作按下去。
	// 不用容器节点：试过把部件挂到 Node 上再整体位移，子元素的落点会跑偏
	// （投影留在原位、主体不知道飘哪去了），改成逐件改 position，代价是几行重复
	const iBtnShadow = block(introRoot, 120, 648, 240, 60, C_DEEP, 0.90);
	const iBtnBody = block(introRoot, 112, 640, 240, 60, Color(252, 247, 232, 255), 1);
	const iBtnT = block(introRoot, 112, 640, 240, 3, C_INK, 0.95);
	const iBtnB = block(introRoot, 112, 697, 240, 3, C_INK, 0.95);
	const iBtnL = block(introRoot, 112, 640, 3, 60, C_INK, 0.95);
	const iBtnR = block(introRoot, 349, 640, 3, 60, C_INK, 0.95);
	const iBtnFill = block(introRoot, 115, 643, 234, 54, C_VERM, 0.5);
	const iBtnTx = label(introRoot, FONT_B, 21, C_INK, 232, 678, 0.5, 10);
	iBtnTx.text = '开 始';
	const iBtnTip = label(introRoot, FONT_R, 13, Color(36, 73, 70, 133), 378, 677, 0, 1.6);
	iBtnTip.text = '点任意处 / 空格 / WASD';

	/* 悬停 / 按下：0.14s / 0.08s 线性逼近，悬停用 smoothstep 上色（同主界面） */
	const BTN_RECT = { x: 112, y: 640, w: 240, h: 60 };
	const inBtn = (x: number, y: number): boolean =>
		x >= BTN_RECT.x && x <= BTN_RECT.x + BTN_RECT.w &&
		y >= BTN_RECT.y && y <= BTN_RECT.y + BTN_RECT.h;

	let iHover = 0, iHoverT = 0;     // 悬停进度 / 目标
	let iPress = 0, iDown = false;   // 按下进度 / 是否按住
	let pressHold = 0;               // 松手后仍保持「按下」的余韵（0.12s，让下沉看得见）
	let beginWait = -1;              // 点按钮后延迟这么久再进玩法

	const iFoot = label(introRoot, FONT_R, 11, Color(36, 73, 70, 102), 112, 764, 0, 1.2);
	iFoot.text = '永昌堡 · 嘉靖四十年 · 五月';

	/* 入场：集中线 → 立绘 → 印章 → 标题 → 横线 → 两句 → 分隔 → 说明 → 按钮 → 落款 */
	let introT = 0;

	const syncIntro = (dt: number): void => {
		const ease = (t0: number, dur: number): number => {
			const k = Math.min(1, Math.max(0, (introT - t0) / dur));
			return 1 - Math.pow(1 - k, 3);
		};

		const aL = ease(0.10, 0.75);
		burstDn.opacity = aL * 0.95;

		const aWz = ease(0.16, 0.72);
		const wdx = (1 - aWz) * 48;
		const bob = Math.sin(introT * 1.45) * 2.2;
		introWz.opacity = 0.98 * aWz;
		introWz.position = Vec2(918 + wdx, H - (316 + bob));
		introWzShadow.opacity = 0.10 * aWz;
		introWzShadow.position = Vec2(964 + wdx, H - 704);

		const aSeal = ease(0.34, 0.28);
		iSealBg.opacity = aSeal;
		iSealTx.opacity = aSeal;
		iQian.opacity = aSeal;

		const aTitle = ease(0.46, 0.55);
		iTitle.opacity = aTitle;
		iTitle.position = Vec2(106 + 44 * (1 - aTitle), H - 342 + 82);

		iRule.scaleX = Math.max(0.01, ease(0.74, 0.42));
		iL1.opacity = ease(0.88, 0.50);
		iL2.opacity = ease(1.02, 0.50);
		iSep.scaleX = Math.max(0.01, ease(1.18, 0.42));
		iH1.opacity = ease(1.34, 0.50);
		iH2.opacity = ease(1.34, 0.50);

		const aBtn = ease(1.52, 0.50);
		const pulse = 0.5 + 0.5 * Math.sin(introT * 2.3);
		iBtnShadow.opacity = 0.90 * aBtn;
		iBtnBody.opacity = aBtn;
		iBtnT.opacity = 0.95 * aBtn;
		iBtnB.opacity = 0.95 * aBtn;
		iBtnL.opacity = 0.95 * aBtn;
		iBtnR.opacity = 0.95 * aBtn;
		iBtnTx.opacity = aBtn;
		iBtnTip.opacity = aBtn * 0.9;
		iFoot.opacity = ease(1.75, 0.60);

		// 悬停 / 按下：位移 3px + 2px，颜色压向墨绿。悬停的呼吸底一起淡入
		iHover = approach(iHover, iHoverT, dt / 0.14);
		iPress = approach(iPress, (iDown || pressHold > 0) ? 1 : 0, dt / 0.08);
		const hv = iHover * iHover * (3 - 2 * iHover);
		const off = 3 * hv + 2 * iPress;
		iBtnBody.position = Vec2(112 + off, H - (640 + off));
		iBtnT.position = Vec2(112 + off, H - (640 + off));
		iBtnB.position = Vec2(112 + off, H - (697 + off));
		iBtnL.position = Vec2(112 + off, H - (640 + off));
		iBtnR.position = Vec2(349 + off, H - (640 + off));
		iBtnFill.position = Vec2(115 + off, H - (643 + off));
		iBtnTx.position = Vec2(232 + off, H - (678 + off) + 21);
		iBtnFill.color = mixColor(C_VERM, C_DEEP, 0.24 * hv + 0.16 * iPress);
		iBtnFill.opacity = (0.40 + 0.26 * pulse + 0.22 * hv) * aBtn;
	};

	// 荒田上的名字：失败时只标这一块
	const deadLb = label(layer, FONT_B, 24, Color(23, 51, 48, 230), 0, 0, 0.5, 6);
	deadLb.visible = false;

	// 点「开始」：撤掉卡片，进玩法
	const begin = (): void => {
		if (phase !== 'intro') { return; }
		introRoot.visible = false;
		panelRoot.visible = true;
		wzSmall.visible = true;
		reset();
	};

	reset();
	phase = 'intro';          // 关前页先占一屏
	panelRoot.visible = false;
	wzSmall.visible = false;  // 关前页右侧已经是大幅立绘，右下角那个小人这时是多余的
	syncIntro(0);
	draw();

	/* ══════════ 对外 ══════════ */
	const play: Level3Play = {
		update: (dt: number): void => {
			if (phase === 'intro') {
				introT += dt;
				// 王梓代打：卡片停留一会儿就自己开打
				if (autoOn && introT > 1.8) { wantBegin = true; }
				if (beginWait > 0) {
					beginWait -= dt;
					if (beginWait <= 0) { wantBegin = true; }
				}
				if (pressHold > 0) { pressHold -= dt; }
				syncIntro(dt);
				draw();
			}

			if (wantBegin) { wantBegin = false; begin(); }
			if (phase === 'intro') { return; }

			if (wantRestart) { wantRestart = false; reset(); }

			if (paused) { draw(); return; }
			tick(dt);
			smoothHead(dt);
			draw();

			// 胜负之后不自动收场：先让玩家看清「哪块荒了 / 八块都黄了」，
			// 卡弹出来才有意义。空格重来，Esc 回主界面
			if (phase === 'lose' && deadIdx >= 0 && !deadLb.visible) {
				const f = fields[deadIdx];
				const cx = cw(f.c0) + ((f.c1 - f.c0 + 1) * G) / 2;
				const cy = ch(f.r0) + ((f.r1 - f.r0 + 1) * G) / 2 + 8;
				deadLb.text = f.cn + ' 荒了';
				deadLb.position = Vec2(cx, H - cy + 24);
				deadLb.visible = true;
			}
			// 先让金框/荒田自己站 1.2–1.3 秒，再看关后页
			if (!finished && overT > (phase === 'win' ? 1.2 : 1.3)) {
				finished = true;
				opts.onFinish({ done: done, secs: Math.round(t), dead: phase === 'lose' ? 1 : 0 });
			}
		},
		destroy: (): void => { layer.removeFromParent(); },
		press: (dir: string): void => { press(dir); },
		tapAt: (x: number, y: number): boolean => {
			ptrX = x;
			ptrY = y;
			if (paused) { paused = false; return true; }
			if (phase === 'play' && autoOn) {
				if (x >= ABT_BX && x <= ABT_BX + ABT_BW && y >= ABT_BY && y <= ABT_BY + ABT_BH) {
					autoOn = false;
					return true;
				}
				return false;      // 自动中，别的地方不接管方向盘
			}
			if (phase === 'intro') {
				// 点在按钮上：先让「下沉」走 0.12s 再进玩法，不然按下去等于没按
				if (inBtn(x, y)) { pressHold = 0.12; beginWait = 0.12; }
				else { wantBegin = true; }
				return true;
			}
			return false;
		},
		pointerAt: (x: number, y: number, down: boolean): void => {
			ptrX = x;
			ptrY = y;
			if (phase !== 'intro') { return; }
			iHoverT = inBtn(x, y) ? 1 : 0;
			iDown = down && iHoverT === 1;
		},
		togglePause: (): void => {
			if (phase !== 'play') { return; }
			paused = !paused;
		},
		restart: (): void => {
			// 关前页 = 开始；局内 = 就地重开。
			// 不在外面重建场景：在调度回调里 destroy + 新建，新场景的 schedule 会不跑
			// （画面停在新场景的第一帧）。就地 reset 既快又没有这个坑。
			if (phase === 'intro') { wantBegin = true; return; }
			if (phase === 'win' || phase === 'lose') { return; }   // 已交接给关后页
			deadLb.visible = false;
			reset();
		},
		skip: (): void => {
			// P = 跳过当前段，不是「退出整关」（退出是 Esc）
			if (phase === 'intro') { wantBegin = true; return; }
			if (phase === 'play') {
				// 对局中跳过：直接按「八块全熟、24 趟灌满」记账，好去看收场页。
				// 不这么记的话，卡上「八块都收了」和「灌溉 3 / 24」会自相矛盾
				for (const f of fields) { f.lv = NEED; f.timer = Infinity; }
				done = FIELD_DEF.length;
				poured = TOTAL_POUR;
				phase = 'win';
				overT = 0;
				return;
			}
			wantFinish = true;   // 结算卡上再按一次 P：离开本关
		},
	};

	print('[Level3Play] 渠网调度就绪');
	return play;
}

/* ══════════ 场景包装：外壳 + 输入 ══════════
   和第一、二关共用 SceneFrame；方向键转向，P 跳过。 */
export function startLevel3(auto = false): void {
	const frame = createSceneFrame();
	let play: Level3Play | undefined = undefined;

	// 收场：先销毁本关，再把战绩交给关后页（独立一页，和 HTML 的结算页/失败页对应）
	const leave = (stats: Level3PlayStats): void => {
		if (play !== undefined) { play.destroy(); play = undefined; }
		frame.destroy();
		startLevel3Result(stats, {
			// 「好」→ 关后科普页 →（第四关还没做）回主界面
			onNext: (): void => {
				startLevel3Post((): void => { backToTitle(); });
			},
			onRetry: (): void => { startLevel3(false); },  // 「再打一次」/「重来」
			onAuto: (): void => { startLevel3(true); },    // 「王梓来帮你」
		});
	};

	play = createLevel3Play(frame.inner, { onFinish: leave, auto: auto });

	frame.root.onKeyDown((key: KeyName): void => {
		// 主键 WASD；方向键留作别名，别让人猜
		if (key === KeyName.W || key === KeyName.Up) { play!.press('u'); return; }
		if (key === KeyName.S || key === KeyName.Down) { play!.press('d'); return; }
		if (key === KeyName.A || key === KeyName.Left) { play!.press('l'); return; }
		if (key === KeyName.D || key === KeyName.Right) { play!.press('r'); return; }
		// 空格：关前页＝开始；对局中不接管（HTML 也是这样）
		if (key === KeyName.Space) { play!.restart(); return; }
		// Esc：对局中＝暂停 / 继续（HTML 的行为）；结算页上由关后页自己处理
		if (key === KeyName.Escape) { play!.togglePause(); return; }
		// R：重开本局
		if (key === KeyName.R) { play!.restart(); return; }
		// P：跳过当前段（测试用）
		if (key === KeyName.P) { play!.skip(); }
	});

	/* 指针三件套：悬停（onMouseMove）→ 按下下沉（onTapBegan/Ended）→ 抬起激活（onTapped）。
	   input 在 inner 里、左下原点；交出去的一律换成左上原点的画布坐标 */
	frame.input.onMouseMove((touch): void => {
		if (play === undefined) { return; }
		play.pointerAt(touch.location.x, 800 - touch.location.y, false);
	});

	frame.input.onTapBegan((touch): void => {
		if (play === undefined) { return; }
		play.pointerAt(touch.location.x, 800 - touch.location.y, true);
	});

	frame.input.onTapEnded((): void => {
		if (play === undefined) { return; }
		play.pointerAt(-1, -1, false);
	});

	frame.input.onTapped((touch): void => {
		if (play === undefined) { return; }
		play.tapAt(touch.location.x, 800 - touch.location.y);
	});

	frame.root.schedule((dt: number) => {
		frame.fit();
		if (play !== undefined) { play.update(dt); }
		return false;
	});
}
