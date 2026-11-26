// 第三关 · 关后页（结算 / 失败）
// 版式与文案来自 02-可玩原型/lv3-结算页.html 与 lv3-失败页.html（两页只差文案与按钮）。
//
// 这一页用的是**第二关的碾房**：城头 + 石灰墙 + 檐下横梁 + 一道斜射的晨光 + 台基。
// 「引水」是在城外的渠网上打的，收场回到屋里，天亮了——这是设计稿的意图。
//
// 引擎限制导致的三处偏差：
//   ① 没有线性渐变 → 纸色遮罩、晨光、侧向暗角都用竖/横条带逼近
//   ② 画不了斜向光带 → 只保留整片晨光，不加那两道斜光
//   ③ 画不了旋转 → 评级印章不转 -0.06 弧度
import {
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
import { createSceneFrame } from 'Script/SceneFrame';

const W = 1280, H = 800;

/* ── 版面 ── */
const CT_T = 72, CT_B = 170;                 // 城头
const RM_T = 170, FOOT_T = 678, FOOT_B = 702; // 碾房墙
const BASE_T = 702;                           // 台基
const LANE_X0 = 364, LANE_W = 168, LANE_GAP = 24;
const LANE_R = LANE_X0 + 3 * LANE_W + 2 * LANE_GAP;   // 916

/* ── 色板：和完整版一致 ── */
const C_PAPER = Color(237, 227, 200, 255);
const C_PAPER2 = Color(243, 234, 211, 255);
const C_SAND = Color(212, 203, 171, 255);
const C_SANDD = Color(197, 188, 156, 255);
const C_SEAM = Color(168, 159, 127, 255);
const C_TRAY = Color(186, 176, 144, 255);
const C_TEAL = Color(90, 121, 104, 255);
const C_INK = Color(36, 73, 70, 255);
const C_DEEP = Color(23, 51, 48, 255);
const C_VERM = Color(163, 59, 42, 255);

const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

function mixColor(a: Color.Type, b: Color.Type, t: number): Color.Type {
	return Color(
		Math.round(a.r + (b.r - a.r) * t),
		Math.round(a.g + (b.g - a.g) * t),
		Math.round(a.b + (b.b - a.b) * t),
		Math.round(a.a + (b.a - a.a) * t),
	);
}
function approach(v: number, target: number, step: number): number {
	if (v < target) { return Math.min(target, v + step); }
	if (v > target) { return Math.max(target, v - step); }
	return v;
}

export type Level3Result = {
	secs: number;    // 用时（秒）
	done: number;    // 灌熟的块数
	dead: number;    // 荒掉几块（0 = 通关）
};
export type Level3ResultOpts = {
	onNext: (this: void) => void;      // 「好」→ 下一站
	onRetry: (this: void) => void;     // 「再打一次」
	onAuto?: (this: void) => void;     // 失败页的「王梓来帮你」
};

export function startLevel3Result(res: Level3Result, opts: Level3ResultOpts): void {
	const failed = res.dead > 0;
	const frame = createSceneFrame();
	const root = frame.inner;

	/* ══════════ 小工具：一律「左上原点、Y 向下」 ══════════ */
	const block = (
		p: Node.Type, x: number, y: number, w: number, h: number, c: Color.Type, al = 1,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.size = Size(Math.abs(w), Math.abs(h));
		s.anchor = Vec2(0, 1);
		s.color = c;
		s.opacity = al;
		s.position = Vec2(x, H - y);
		s.addTo(p);
		return s;
	};
	const img = (p: Node.Type, f: string, x: number, y: number, w: number, h: number): Sprite.Type => {
		const s = Sprite(f)!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		s.position = Vec2(x, H - y);
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
		lb.addTo(p);
		return lb;
	};

	const layer = Node();
	layer.size = Size(W, H);
	layer.anchor = Vec2(0, 0);
	layer.position = Vec2(0, 0);
	layer.addTo(root);

	/* ══════════ 1) 纸底 ══════════ */
	img(layer, 'Image/StartUI/lv2_paper.png', 0, 0, W, H + 4);

	/* ══════════ 2) 城头（远墙） ══════════ */
	const wallFill = mixColor(C_SAND, C_PAPER, 0.34);
	block(layer, 0, CT_T, W, CT_B - CT_T, wallFill);
	block(layer, 0, CT_T, W, 32, mixColor(C_PAPER, C_TEAL, 0.21));

	// 垛口：每个齿 64 宽、间距 112
	const teeth: number[] = [];
	for (let x = -16; x < W + 80; x += 112) { teeth.push(x + 20); }
	for (const bx of teeth) { block(layer, bx, CT_T, 64, 32, wallFill); }

	// 齿的轮廓 + 砖缝
	const crenelDn = DrawNode()!;
	crenelDn.addTo(layer);
	for (const bx of teeth) {
		crenelDn.drawSegment(Vec2(bx, H - (CT_T + 32)), Vec2(bx, H - CT_T), 1.2, Color(36, 73, 70, 184));
		crenelDn.drawSegment(Vec2(bx, H - CT_T), Vec2(bx + 64, H - CT_T), 1.2, Color(36, 73, 70, 184));
		crenelDn.drawSegment(Vec2(bx + 64, H - CT_T), Vec2(bx + 64, H - (CT_T + 32)), 1.2, Color(36, 73, 70, 184));
	}
	const wtop = CT_T + 32;
	for (let y = wtop + 26; y < CT_B - 8; y += 26) {
		block(layer, 0, y - 0.7, W, 1.4, C_SEAM, 0.62);
	}

	// 两侧压暗：三档递减排出来（引擎没有渐变）
	const shade = (y0: number, y1: number, al: number): void => {
		const steps = [[0, 120, 1], [120, 220, 0.55], [220, 300, 0.22]];
		for (const st of steps) {
			block(layer, st[0] as number, y0, (st[1] as number) - (st[0] as number), y1 - y0, C_INK, al * (st[2] as number));
			block(layer, W - (st[1] as number), y0, (st[1] as number) - (st[0] as number), y1 - y0, C_INK, al * (st[2] as number));
		}
	};
	shade(wtop, CT_B, 0.12);

	/* ══════════ 3) 碾房墙 ══════════ */
	block(layer, 0, RM_T, W, FOOT_B - RM_T, C_SANDD);
	for (let y = RM_T + 96; y < FOOT_T; y += 116) { block(layer, 0, y, W, 1.8, C_SEAM, 0.22); }
	for (let x = 0; x < W; x += 96) { block(layer, x, RM_T, 58, FOOT_T - RM_T, C_SEAM, 0.035); }
	// 两根木柱
	for (const cx of [318, 944]) {
		block(layer, cx, RM_T, 18, FOOT_T - RM_T, mixColor(C_TRAY, C_INK, 0.18));
		block(layer, cx + 2, RM_T, 3, FOOT_T - RM_T, C_PAPER, 0.30);
		block(layer, cx, RM_T, 2.2, FOOT_T - RM_T, C_INK, 0.50);
		block(layer, cx + 15.8, RM_T, 2.2, FOOT_T - RM_T, C_INK, 0.50);
	}
	// 墙裙
	block(layer, 0, FOOT_T, W, FOOT_B - FOOT_T, mixColor(C_SANDD, C_INK, 0.14));
	block(layer, 0, FOOT_T + 2, W, 3, C_PAPER, 0.16);
	block(layer, 0, FOOT_T - 1.3, W, 2.6, C_INK, 0.78);
	shade(RM_T, FOOT_T, 0.16);

	/* ══════════ 4) 檐下横梁 ══════════ */
	block(layer, 0, 140, W, 30, mixColor(C_TRAY, C_INK, 0.74));
	block(layer, 0, 141, W, 3, C_PAPER, 0.42);
	block(layer, 0, 149, W, 1.4, C_INK, 0.16);
	block(layer, 0, 157, W, 1.4, C_INK, 0.16);
	block(layer, 0, 168.4, W, 3.2, C_INK, 0.95);
	// 梁影只落在两侧的墙上
	for (const seg of [[0, LANE_X0], [LANE_R, W - LANE_R]]) {
		block(layer, seg[0] as number, CT_B, (seg[1] as number) - (seg[0] as number), 20, C_INK, 0.20);
		block(layer, seg[0] as number, CT_B + 20, (seg[1] as number) - (seg[0] as number), 20, C_INK, 0.11);
		block(layer, seg[0] as number, CT_B + 40, (seg[1] as number) - (seg[0] as number), 18, C_INK, 0.05);
	}

	/* ══════════ 5) 晨光 ══════════
	   HTML 是从左下 (0,800) 打到右上 (960,0) 的线性渐变。
	   方块拼渐变会拼出棋盘格（试过 16×10，接缝全露），所以直接烘一张带 alpha 的贴图：
	   `Image/StartUI/lv3_dawn.png`（1280×630，ffmpeg 的 geq 按斜向投影算 alpha）。 */
	img(layer, 'Image/StartUI/lv3_dawn.png', 0, CT_B, W, H - CT_B);

	/* ══════════ 6) 台基 ══════════ */
	block(layer, 0, BASE_T, W, H - BASE_T, C_TRAY);
	block(layer, 0, BASE_T - 2, W, 4, C_INK, 0.95);
	for (let x = 26; x < W; x += 168) { block(layer, x, BASE_T + 12, 1.8, H - BASE_T - 12, C_INK, 0.09); }

	/* ══════════ 7) 王梓 ══════════ */
	const face = img(layer, failed ? 'Image/StartUI/face_dot.png' : 'Image/StartUI/face_laugh.png', 856, 350, 300, 400);
	block(layer, 914, 736, 192, 12, C_INK, 0.16);

	/* ══════════ 8) 集中线 + 纸色遮罩 ══════════ */
	const burstDn = DrawNode()!;
	burstDn.addTo(layer);
	for (let i = 0; i < 40; i++) {
		const ang = (i / 40) * Math.PI * 2 + 0.31;
		const j = ((i * 37) % 11) / 11;
		const r0 = 210 * (0.86 + 0.30 * j);
		const r1 = 340 * (0.72 + 0.46 * j);
		burstDn.drawSegment(
			Vec2(250 + Math.cos(ang) * r0, H - (330 + Math.sin(ang) * r0)),
			Vec2(250 + Math.cos(ang) * r1, H - (330 + Math.sin(ang) * r1)),
			0.8, Color(36, 73, 70, 28),
		);
	}

	// 左侧纸色遮罩：0.97 → 0.92(58%) → 0
	const WASH_N = 16, WASH_X1 = 1080, WASH_MID = WASH_X1 * 0.58;
	for (let i = 0; i < WASH_N; i++) {
		const x0 = WASH_X1 * i / WASH_N;
		const x1 = WASH_X1 * (i + 1) / WASH_N;
		const mid = (x0 + x1) / 2;
		const a = mid <= WASH_MID
			? 0.97 - 0.05 * (mid / WASH_MID)
			: 0.92 * (1 - (mid - WASH_MID) / (WASH_X1 - WASH_MID));
		block(layer, x0, CT_B, x1 - x0 + 1, H - CT_B, C_PAPER, a);
	}

	// 地平线：属于场景，必须压在文字之前，否则会横穿按钮
	block(layer, 0, BASE_T - 1.5, W, 3, C_INK, 0.55);

	/* ══════════ 9) 文案 ══════════ */
	const TITLE = failed ? '田 荒 了' : (res.done >= 8 ? '八块都收了' : ('收了 ' + res.done.toString() + ' 块'));
	const L1 = failed ? '水断了三天，那块田就干了。' : '水从水门进来，绕了八块田。';
	const L2 = failed ? '八块田，一块都不能断水。' : '最后一块熟的时候，天快亮了。';
	const FOOT = failed ? '田一荒，城里的米就断了。' : '城里有粮，围多久都撑得住。';
	const GRADE = failed ? '丙' : (res.secs <= 100 ? '甲' : (res.secs <= 150 ? '乙' : '丙'));

	const iSealBg = block(layer, 112, 196, 38, 38, C_VERM);
	const iSealTx = label(layer, FONT_B, 27, C_PAPER2, 131, 226, 0.5, 0);
	iSealTx.text = failed ? '败' : '胜';
	const iTag = label(layer, FONT_B, 18, Color(36, 73, 70, 140), 158, 226, 0, 4);
	iTag.text = '关 后';

	const iTitle = label(layer, FONT_B, 72, failed ? C_DEEP : C_INK, 106, 322, 0, 11);
	iTitle.text = TITLE;

	const iRule = block(layer, 112, 346, 128, 4, C_VERM);

	const iL1 = label(layer, FONT_B, 24, Color(36, 73, 70, 224), 112, 402, 0, 1.4);
	iL1.text = L1;
	const iL2 = label(layer, FONT_B, 24, Color(36, 73, 70, 224), 112, 440, 0, 1.4);
	iL2.text = L2;

	const iSep = block(layer, 112, 482, 448, 2, C_INK, 0.32);

	// 四行统计
	const stats: [string, string, number][] = [
		['用时', res.secs.toString() + ' 秒', Math.min(1, 90 / Math.max(30, res.secs))],
		['灌熟', res.done.toString() + ' / 8 块', res.done / 8],
		['最长水头', failed ? '4 格' : '6 格', failed ? 0.55 : 0.80],
		['荒田', res.dead.toString() + ' 块', res.dead > 0 ? 0.4 : 0],
	];
	const statKeys: Label.Type[] = [];
	const statVals: Label.Type[] = [];
	const statBars: Sprite.Type[] = [];
	const statBarBg: Sprite.Type[] = [];
	for (let i = 0; i < stats.length; i++) {
		const y = 516 + i * 25;
		statKeys.push(label(layer, FONT_R, 16, Color(36, 73, 70, 153), 112, y + 4, 0, 1.2));
		statKeys[i].text = stats[i][0];
		statVals.push(label(layer, FONT_B, 17, C_INK, 300, y + 4, 1, 0.8));
		statVals[i].text = stats[i][1];
		statBarBg.push(block(layer, 320, y - 9, 180, 5, C_INK, 0.10));
		statBars.push(block(layer, 320, y - 9, 180, 5, C_INK, 0.62));
	}

	const iFoot = label(layer, FONT_B, 18, Color(36, 73, 70, 204), 112, 630, 0, 1.2);
	iFoot.text = FOOT;

	// 评级印章（画不了旋转，正着盖）
	const gs = 44, gx = 560 - gs / 2, gy = 190;
	const gradeParts: Sprite.Type[] = [
		block(layer, gx, gy, gs, 2.6, C_VERM),
		block(layer, gx, gy + gs - 2.6, gs, 2.6, C_VERM),
		block(layer, gx, gy, 2.6, gs, C_VERM),
		block(layer, gx + gs - 2.6, gy, 2.6, gs, C_VERM),
	];
	const gradeTx = label(layer, FONT_B, 30, C_VERM, 560, gy + 34, 0.5, 0);
	gradeTx.text = GRADE;
	const gradeCap = label(layer, FONT_R, 13, Color(36, 73, 70, 115), 560, 264, 0.5, 2);
	gradeCap.text = '今夜评级';

	/* ══════════ 10) 两只按钮 ══════════ */
	type Btn = {
		x: number; y: number; w: number; h: number;
		parts: Sprite.Type[]; lb: Label.Type; sub: Label.Type;
		hov: number; prs: number;
	};
	const mkBtn = (x: number, y: number, w: number, h: number, main: string, sub: string): Btn => {
		const parts: Sprite.Type[] = [];
		parts.push(block(layer, x + 8, y + 8, w, h, C_INK, 0.88));          // 0 投影（不动）
		parts.push(block(layer, x, y, w, h, C_PAPER2));                      // 1 面板
		parts.push(block(layer, x, y, w, 3, C_INK, 0.95));                   // 2 上边框
		parts.push(block(layer, x, y + h - 3, w, 3, C_INK, 0.95));           // 3 下
		parts.push(block(layer, x, y, 3, h, C_INK, 0.95));                   // 4 左
		parts.push(block(layer, x + w - 3, y, 3, h, C_INK, 0.95));           // 5 右
		const lb = label(layer, FONT_B, 24, C_INK, x + w / 2, y + 38, 0.5, 10);
		lb.text = main;
		const sb = label(layer, FONT_R, 13, Color(36, 73, 70, 128), x + w / 2, y + 56, 0.5, 0.6);
		sb.text = sub;
		return { x: x, y: y, w: w, h: h, parts: parts, lb: lb, sub: sb, hov: 0, prs: 0 };
	};

	const btns: Btn[] = [
		failed
			? mkBtn(112, 660, 200, 60, '重 来', '按 R')
			: mkBtn(112, 660, 200, 60, '好', '去看守城的人'),
		failed
			? mkBtn(340, 660, 260, 60, '王梓来帮你', '自动演示一遍')
			: mkBtn(340, 660, 260, 60, '再打一次', '按 R'),
	];

	const iFootLine = label(layer, FONT_R, 13, Color(36, 73, 70, 102), 112, 764, 0, 1.2);
	iFootLine.text = '永昌堡 · 嘉靖四十年 · 五月 · 夜尽';

	/* ══════════ 入场 ══════════ */
	let T = 0;
	let ptrX = -999, ptrY = -999, ptrDown = false;

	const ease = (t0: number, dur: number): number => {
		const k = Math.min(1, Math.max(0, (T - t0) / dur));
		return 1 - Math.pow(1 - k, 3);
	};

	const sync = (dt: number): void => {
		// 王梓：从右滑入 + 呼吸
		const aWz = ease(0.16, 0.72);
		face.opacity = aWz;
		face.position = Vec2(856 + (1 - aWz) * 48, H - (350 + Math.sin(T * 1.45) * 2.2));

		burstDn.opacity = ease(0.10, 0.75);

		const aSeal = ease(0.34, 0.28);
		iSealBg.opacity = aSeal;
		iSealTx.opacity = aSeal;
		iTag.opacity = ease(0.42, 0.40);

		const aTitle = ease(0.46, 0.55);
		iTitle.opacity = aTitle;
		iTitle.position = Vec2(106 + (1 - aTitle) * 44, H - 322 + 72);

		iRule.scaleX = Math.max(0.01, ease(0.74, 0.42));
		iL1.opacity = ease(0.86, 0.50);
		iL2.opacity = ease(1.00, 0.50);
		iSep.scaleX = Math.max(0.01, ease(1.10, 0.42));

		for (let i = 0; i < stats.length; i++) {
			const a = ease(1.10 + i * 0.10, 0.42);
			statKeys[i].opacity = a;
			statVals[i].opacity = a;
			statBarBg[i].opacity = 0.10 * a;
			statBars[i].opacity = 0.62 * a;
			statBars[i].scaleX = Math.max(0.01, stats[i][2] * a);
		}

		iFoot.opacity = ease(1.30, 0.50);

		const aG = ease(1.46, 0.26);
		for (const gp of gradeParts) { gp.opacity = aG; }
		gradeTx.opacity = aG;
		gradeCap.opacity = ease(1.52, 0.40);

		const aBtn = ease(1.72, 0.50);
		for (const b of btns) {
			const inRect = ptrX >= b.x && ptrX <= b.x + b.w && ptrY >= b.y && ptrY <= b.y + b.h;
			b.hov = approach(b.hov, inRect ? 1 : 0, dt / 0.14);
			b.prs = approach(b.prs, (inRect && ptrDown) ? 1 : 0, dt / 0.08);
			const hv = b.hov * b.hov * (3 - 2 * b.hov);
			const off = 3 * hv + 2 * b.prs;
			// 逐件给绝对坐标：不能写「当前位置 + offset」，那样每帧都会累加
			b.parts[1].position = Vec2(b.x + off, H - (b.y + off));
			b.parts[2].position = Vec2(b.x + off, H - (b.y + off));
			b.parts[3].position = Vec2(b.x + off, H - (b.y + b.h - 3 + off));
			b.parts[4].position = Vec2(b.x + off, H - (b.y + off));
			b.parts[5].position = Vec2(b.x + b.w - 3 + off, H - (b.y + off));
			b.lb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 38 + off) + 24);
			b.sub.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 56 + off) + 13);
			b.parts[1].color = mixColor(C_PAPER2, Color(206, 206, 206, 255), hv * 0.55 + b.prs * 0.35);
			const a = aBtn;
			for (let k = 0; k < b.parts.length; k++) { b.parts[k].opacity = (k === 0 ? 0.88 : 1) * a; }
			b.lb.opacity = a;
			b.sub.opacity = a;
		}

		iFootLine.opacity = ease(1.95, 0.60);
	};

	/* ══════════ 输入 ══════════ */
	const hitBtn = (x: number, y: number): number => {
		for (let i = 0; i < btns.length; i++) {
			const b = btns[i];
			if (x >= b.x && x <= b.x + b.w && y >= b.y && y <= b.y + b.h) { return i; }
		}
		return -1;
	};

	/* 点下去不立刻切场景：这一页自己也要先销毁。
	   原来这里直接调回调，`frame` 从来没被销毁 —— 再开一关时旧页面还挂在 Director.ui 上，
	   继续 draw、继续吃输入，表现就是「按了再打一次，画面还停在结算页」。
	   和别的场景一样：置一个待办，下一帧销毁自己再交接。 */
	let pendingAct = -1;

	const activate = (i: number): void => {
		if (i < 0 || pendingAct >= 0) { return; }
		pendingAct = i;
	};

	const runPending = (): boolean => {
		if (pendingAct < 0) { return false; }
		const i = pendingAct;
		pendingAct = -1;
		const goNext = !failed && i === 0;
		const goAuto = failed && i === 1 && opts.onAuto !== undefined;
		frame.destroy();
		if (goNext) { opts.onNext(); }
		else if (goAuto && opts.onAuto !== undefined) { opts.onAuto(); }
		else { opts.onRetry(); }
		return true;              // 停掉本场景的 schedule
	};

	frame.input.onMouseMove((touch): void => {
		ptrX = touch.location.x;
		ptrY = 800 - touch.location.y;
	});
	frame.input.onTapBegan((touch): void => {
		ptrX = touch.location.x;
		ptrY = 800 - touch.location.y;
		ptrDown = true;
	});
	frame.input.onTapEnded((): void => { ptrDown = false; });
	frame.input.onTapped((touch): void => {
		const ty = 800 - touch.location.y;
		if (T < 1.0) { return; }      // 入场没走完不接点击，免得误触
		activate(hitBtn(touch.location.x, ty));
	});

	frame.root.onKeyDown((key: KeyName): void => {
		if (key === KeyName.R) { activate(1); return; }
		if (key === KeyName.Return || key === KeyName.Space) {
			if (T < 1.0) { return; }
			activate(0);
		}
	});

	frame.root.schedule((dt: number) => {
		if (runPending()) { return true; }
		frame.fit();
		T += dt;
		sync(dt);
		return false;
	});

	print('[Level3Result] ' + (failed ? '失败页' : '结算页') + ' 用时 ' + res.secs.toString() + 's');
}
