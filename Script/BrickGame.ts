// 第一关 · 砌墙（玩法）
// 版式来自 02-可玩原型/lv1-砌墙-完整版.html（1280×800），规则与之完全一致。
//
// Dora 没有 Canvas 2D，所以这里的分工是：
//   · 不动的、形状复杂的 → 预先渲染成 PNG（墙、垛口、远山、纸卡、集中线、印章、解说条）
//   · 会动但形状简单的 → Sprite 拼（缺口、手牌、HUD、按钮）
// 画布是 804 高，这里按 800 设计、整体上移 2px 居中。
import {
	Color,
	Label,
	Node,
	Size,
	Sprite,
	TextAlign,
	Vec2,
	View,
} from 'Dora';

const W = 1280;
const H = 800;
const PAD_Y = 2;                 // (804 - 800) / 2

const CELL = 56;
const ROWS = 6;
const GAPS_TO_WIN = 10;

const SKY_T = 72, SKY_B = 304;
const TOOTH_H = 36, CAP_H = 14;
const PAR_T = SKY_B;             // 304
const WALL_T = PAR_T + TOOTH_H + CAP_H;   // 352
const WALL_B = WALL_T + ROWS * CELL;      // 688
const FOOT_B = WALL_B + 12;               // 700

const SLOT_W = 144, SLOT_H = 84, SLOT_GAP = 12, SLOT_Y = 709;
const HAND_N = 5;
const CW = 30;
const HAND_TOTAL = HAND_N * SLOT_W + (HAND_N - 1) * SLOT_GAP;
const HAND_X = (W - HAND_TOTAL) / 2;

const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_M = 'Font/SourceHanSerifSC-Medium.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

const C_PAPER = Color(237, 227, 200, 255);
const C_SEAM = Color(168, 159, 127, 255);
const C_INK = Color(36, 73, 70, 255);
const C_DEEP = Color(23, 51, 48, 255);
const C_VERM = Color(163, 59, 42, 255);
const C_SAND = Color(227, 218, 186, 255);
const C_TRAY = Color(186, 176, 144, 255);
const C_TEAL = Color(90, 121, 104, 255);

/* 玩法数值：照抄 HTML 版 */
const V0 = 200, V_CAP = 320;
const ROT_LOCK = 0.10;
const SPAWN_DELAY = 0.8;
const MAX_GAPS = 2;
const EASY_GAPS = 4;

/* ── 形状 ── */
const SHAPES: { [k: string]: number[][] } = {
	I: [[1, 1, 1, 1]],
	O: [[1, 1], [1, 1]],
	T: [[1, 1, 1], [0, 1, 0]],
	S: [[0, 1, 1], [1, 1, 0]],
	Z: [[1, 1, 0], [0, 1, 1]],
	J: [[1, 0, 0], [1, 1, 1]],
	L: [[0, 0, 1], [1, 1, 1]],
};
const KEYS: string[] = ['I', 'O', 'T', 'S', 'Z', 'J', 'L'];

function rotCW(m: number[][]): number[][] {
	const h = m.length, w = m[0].length;
	const o: number[][] = [];
	for (let c = 0; c < w; c++) {
		const row: number[] = [];
		for (let r = h - 1; r >= 0; r--) { row.push(m[r][c]); }
		o.push(row);
	}
	return o;
}
function matKey(m: number[][]): string {
	let s = '';
	for (let r = 0; r < m.length; r++) { s += m[r].join('') + '/'; }
	return s;
}
function normCells(m: number[][]): number[][] {
	const out: number[][] = [];
	for (let r = 0; r < m.length; r++) {
		for (let c = 0; c < m[r].length; c++) {
			if (m[r][c] !== 0) { out.push([c, r]); }
		}
	}
	let mc = 99, mr = 99;
	for (const a of out) { if (a[0] < mc) mc = a[0]; if (a[1] < mr) mr = a[1]; }
	const res: number[][] = [];
	for (const a of out) { res.push([a[0] - mc, a[1] - mr]); }
	return res;
}
function ckOf(cells: number[][]): string {
	const parts: string[] = [];
	for (const a of cells) { parts.push(a[0] + ',' + a[1]); }
	parts.sort();
	return parts.join(';');
}

type Variant = { cells: number[][]; ck: string; w: number; h: number };
const VARIANTS: { [k: string]: Variant[] } = {};

for (let ki = 0; ki < KEYS.length; ki++) {
	const key = KEYS[ki];
	const list: Variant[] = [];
	const seen: { [k: string]: boolean } = {};
	let cur = SHAPES[key];
	for (let i = 0; i < 4; i++) {
		const mk = matKey(cur);
		if (!seen[mk]) {
			seen[mk] = true;
			const cells = normCells(cur);
			let w = 0, h = 0;
			for (const a of cells) { if (a[0] + 1 > w) w = a[0] + 1; if (a[1] + 1 > h) h = a[1] + 1; }
			list.push({ cells: cells, ck: ckOf(cells), w: w, h: h });
		}
		cur = rotCW(cur);
	}
	VARIANTS[key] = list;
}

/* ── 状态 ── */
type Gap = {
	shape: string; vi: number; ck: string; w: number; h: number;
	cells: number[][]; r0: number; x: number; age: number; id: number;
};
type Card = { shape: string; vi: number };

export function createBrickGame(
	root: Node.Type,
	onClear: () => void,
	onExit?: () => void,     // 设置面板的「返回主菜单」：不传就退化成重开
	startPhase?: string,     // 调试后门：直接进某个阶段
) {
	const layer = Node();
	layer.anchor = Vec2(0, 0);
	layer.size = Size(W, H);
	layer.position = Vec2(0, PAD_Y);
	layer.addTo(root);

	/* 左上角定位的色块 */
	const block = (
		parent: Node.Type, x: number, y: number, w: number, h: number, c: Color.Type,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.anchor = Vec2(0, 1);
		s.size = Size(Math.abs(w), Math.abs(h));
		s.color = c;
		s.position = Vec2(x, H - y);
		s.visible = false;
		s.addTo(parent);
		return s;
	};
	const show = (s: Sprite.Type, x: number, y: number, w: number, h: number): void => {
		s.visible = true;
		s.size = Size(w, h);
		// Dora 里改 size 会把 anchor 重置回中心 (0.5, 0.5)。
		// 不补这一行，所有用 show 摆位的东西都会整体偏左上半个尺寸——
		// 手牌偏左上、缺口描边错位、滑条跑偏，全是这一个原因。
		s.anchor = Vec2(0, 1);
		s.position = Vec2(x, H - y);
	};
	const hide = (s: Sprite.Type): void => { s.visible = false; };

	/* 文字 */
	// ax：0 = 左端对齐，0.5 = 居中，1 = 右端对齐。
	// 用锚点而不是 alignment —— 引擎里 alignment 的表现不可靠，
	// 而锚点这套写法在关前页已经验证过。
	//
	// 超采样：Label 是按字号把字形烘成一张小纹理，之后跟着 root.scale 一起被放大采样。
	// 字号 15 的字当 22px 显示，等于拿 15px 的位图去拉大——边缘发灰，看着就是「糊」。
	// （开始界面的「永昌守城记」是美术切图，不存在这一步，所以它一直很清楚。）
	//
	// 做法：按「屏幕实际缩放」烘字号，再 scale 缩回来，让纹理像素和屏幕像素 1:1。
	// SS 不写死，是因为写死 3 的话，窗口正好 1:1 时反而要 3 倍纹理缩到 1 倍，白糊一层。
	// 1.12 是留的余量，抵掉字号取整的误差。
	const VIEW_S = Math.min(View.size.width / W, View.size.height / (H + PAD_Y * 2));
	const SS = Math.min(3.5, Math.max(1, VIEW_S * 1.12));

	const label = (
		parent: Node.Type, font: string, size: number, color: Color.Type,
		x: number, y: number, ax: number, ls: number,
	): Label.Type => {
		const lb = Label(font + ';' + Math.round(size * SS) + ';true')!;
		lb.color = color;
		lb.anchor = Vec2(ax, 1);
		lb.scaleX = 1 / SS;
		lb.scaleY = 1 / SS;
		lb.position = Vec2(x, H - y + size);
		if (ls > 0) { lb.spacing = Math.round(ls * SS); }
		lb.addTo(parent);
		return lb;
	};


	/* ══════════ 静态底：纸 + 网点 + 远山 ══════════ */
	block(layer, 0, 0, W, H, C_PAPER).visible = true;

	const grain = Sprite('Image/StartUI/paper_grain.png')!;
	grain.anchor = Vec2(0, 1);
	grain.size = Size(W, H);
	grain.position = Vec2(0, H);
	grain.addTo(layer);

	const hills = Sprite('Image/StartUI/hills.png')!;
	hills.anchor = Vec2(0, 1);
	hills.size = Size(W, SKY_B - SKY_T);
	hills.position = Vec2(0, H - SKY_T);
	hills.addTo(layer);

	/* ══════════ 王梓 + 解说条 ══════════ */
	const WZ_X = 28, WZ_W = 266, WZ_H = 357, WZ_BOT = 438;
	const FACE_LIST: string[] = ['smile', 'laugh', 'dot', 'wave', 'curvy', 'shy', 'shyact', 'dizzy'];
	const faces: Sprite.Type[] = [];
	for (let i = 0; i < FACE_LIST.length; i++) {
		const s = Sprite('Image/StartUI/face_' + FACE_LIST[i] + '.png')!;
		s.anchor = Vec2(0, 1);
		s.size = Size(WZ_W, WZ_H);
		s.position = Vec2(WZ_X, H - (WZ_BOT - WZ_H));
		s.opacity = i === 0 ? 1 : 0;
		s.addTo(layer);
		faces.push(s);
	}
	let faceCur = 0;

	const dlgBox = Sprite('Image/StartUI/dialog_box.png')!;
	dlgBox.anchor = Vec2(0, 1);
	dlgBox.size = Size(462, 166);
	dlgBox.position = Vec2(340, H - 122);
	dlgBox.addTo(layer);

	const dlgBar = block(layer, 368, 152, 4, 15, C_TEAL);
	dlgBar.visible = true;
	const dlgName = label(layer, FONT_B, 16, C_TEAL, 382, 165, 0, 3);
	dlgName.text = '王梓';

	// 解说条四角准星：每角两条短线，共八条
	const dlgCorner: Sprite.Type[] = [];
	for (let i = 0; i < 8; i++) {
		const c = block(layer, 0, 0, 1, 1, C_VERM);
		c.visible = true;
		c.opacity = 0.55;
		dlgCorner.push(c);
	}
	const dlgCorners = (): void => {
		const x = 354, y = 136, w = 434, h = 138, len = 13, t = 1.8;
		show(dlgCorner[0], x, y, len, t);
		show(dlgCorner[1], x, y, t, len);
		show(dlgCorner[2], x + w - len, y, len, t);
		show(dlgCorner[3], x + w - t, y, t, len);
		show(dlgCorner[4], x, y + h - t, len, t);
		show(dlgCorner[5], x, y + h - len, t, len);
		show(dlgCorner[6], x + w - len, y + h - t, len, t);
		show(dlgCorner[7], x + w - t, y + h - len, t, len);
	};
	dlgCorners();
	label(layer, FONT_R, 26, Color(23, 51, 48, 255), 368, 210, 0, 1).text =
		'城墙最要紧的，是不能有洞。';
	label(layer, FONT_R, 26, Color(23, 51, 48, 255), 368, 252, 0, 1).text =
		'一块砖塌了，旁边的一起塌。';

	/* ══════════ 垛口：必须在王梓之后，否则她的下半身会盖在墙上 ══════════ */
	const parapet = Sprite('Image/StartUI/parapet.png')!;
	parapet.anchor = Vec2(0, 1);
	parapet.size = Size(W, TOOTH_H + CAP_H);
	parapet.position = Vec2(0, H - PAR_T);
	parapet.addTo(layer);

	/* ══════════ 墙：两张 2560 宽的贴图交替滚动 ══════════ */
	const STRIP_W = 2560;
	const wallA = Sprite('Image/StartUI/wall_strip.png')!;
	const wallB = Sprite('Image/StartUI/wall_strip.png')!;
	const walls: Sprite.Type[] = [wallA, wallB];
	for (const w of walls) {
		w.anchor = Vec2(0, 1);
		w.size = Size(STRIP_W, ROWS * CELL);
		w.position = Vec2(0, H - WALL_T);
		w.addTo(layer);
	}
	const footLine = block(layer, 0, WALL_B, W, 2, C_INK);
	footLine.visible = true;
	footLine.opacity = 0.78;
	const tray = block(layer, 0, FOOT_B, W, H - FOOT_B, C_TRAY);
	tray.visible = true;

	// 台面接缝：每 320px 一道，让台面像一整块木板而不是一块色
	for (let x = 240; x < W; x += 320) {
		const seam = block(layer, x, WALL_B + 8, 1, H - WALL_B - 8, C_SEAM);
		seam.visible = true;
		seam.opacity = 0.28;
	}

	/* ══════════ 缺口池 ══════════
	   一个洞不止是「一块深色」：描边、内壁受光、斜排线、准星、命中反馈都得画。
	   这里全部用细长的 Sprite 拼——OpenGL 的线宽在多数驱动上只支持 1px，
	   用 Line 节点画不出 3px 的墨边，拼 Sprite 反而稳。 */
	const GAP_POOL = MAX_GAPS * 6;
	const gapCells: Sprite.Type[] = [];
	for (let i = 0; i < GAP_POOL; i++) { gapCells.push(block(layer, 0, 0, CELL, CELL, C_DEEP)); }

	// 描边：只画朝向空气的那几条边，3px 墨色
	const EDGE_POOL = GAP_POOL * 4;
	const edgePool: Sprite.Type[] = [];
	for (let i = 0; i < EDGE_POOL; i++) {
		const e = block(layer, 0, 0, 1, 1, C_INK);
		e.visible = false;
		edgePool.push(e);
	}

	// 内壁受光：洞顶压一条纸色亮边，洞才有「凹进去」的体积
	const LIT_POOL = GAP_POOL;
	const litPool: Sprite.Type[] = [];
	for (let i = 0; i < LIT_POOL; i++) {
		const e = block(layer, 0, 0, 1, 1, C_PAPER);
		e.opacity = 0.26;
		e.visible = false;
		litPool.push(e);
	}

	// 斜排线：可填的洞里透进来的一点光。每格一张 45° 斜纹贴图，按格子对齐，不会溢出到墙上
	const HATCH_POOL = GAP_POOL;
	const hatchPool: Sprite.Type[] = [];
	for (let i = 0; i < HATCH_POOL; i++) {
		const h = Sprite('Image/StartUI/hatch.png')!;
		h.anchor = Vec2(0, 1);
		h.size = Size(CELL, CELL);
		h.visible = false;
		h.addTo(layer);
		hatchPool.push(h);
	}

	// 准星：0–3 可填、4–7 新洞、8–11 命中反馈，每处四条边
	const hintEdges: Sprite.Type[] = [];
	for (let i = 0; i < 12; i++) { hintEdges.push(block(layer, 0, 0, 1, 1, C_VERM)); }
	const flashEdges: Sprite.Type[] = [];
	for (let i = 0; i < 4; i++) { flashEdges.push(block(layer, 0, 0, 1, 1, C_TEAL)); }

	/* ══════════ 手牌 ══════════ */
	const slots: Sprite.Type[] = [];
	for (let i = 0; i < HAND_N; i++) {
		// 槽底用一张烘焙好的贴图：半透明填充 + 墨色细边框。
		// 牌永远贴在台面上，混合色可以直接烘死不透明，省掉 alpha 的麻烦。
		const s = Sprite('Image/StartUI/slot.png')!;
		s.anchor = Vec2(0, 1);
		s.size = Size(SLOT_W, SLOT_H);
		s.position = Vec2(HAND_X + i * (SLOT_W + SLOT_GAP), H - SLOT_Y);
		s.addTo(layer);
		slots.push(s);
	}

	// 持牌时给牌套一道青绿粗框——这是本画面唯一允许的强调色
	const handFrame: Sprite.Type[] = [];
	for (let i = 0; i < 4; i++) {
		const f = block(layer, 0, 0, 1, 1, C_TEAL);
		f.visible = false;
		handFrame.push(f);
	}

	// 旋转锁定：100ms 内不能再转，槽上方一道走完就消失的细条
	const rotBar = block(layer, 0, 0, 1, 2, C_TEAL);
	rotBar.visible = false;
	const chipPool: Sprite.Type[] = [];
	for (let i = 0; i < HAND_N * 4; i++) {
		const c = Sprite('Image/StartUI/chip.png')!;
		c.anchor = Vec2(0, 1);
		c.size = Size(CW, CW);
		c.visible = false;
		c.addTo(layer);
		chipPool.push(c);
	}

	/* ══════════ HUD ══════════ */
	const hudName = label(layer, FONT_B, 26, C_INK, 112, 48, 0, 3);
	hudName.text = '砌墙';
	const hudYi = Sprite('Image/StartUI/seal_yi.png')!;
	hudYi.anchor = Vec2(0, 1);
	hudYi.size = Size(36, 36);
	hudYi.position = Vec2(64, H - 24);
	hudYi.addTo(layer);

	const barBg = block(layer, 340, 33, 540, 7, C_SEAM);
	barBg.visible = true;
	barBg.opacity = 0.43;
	const barFill = block(layer, 340, 33, 0, 7, C_TEAL);
	barFill.visible = true;
	const barEnd = block(layer, 880, 28, 3, 17, C_VERM);
	barEnd.visible = true;
	const barTickL = block(layer, 340, 29, 1.5, 15, C_INK);
	barTickL.visible = true;
	barTickL.opacity = 0.35;

	const hudScore = label(layer, FONT_B, 36, C_INK, 1160, 52, 1, 1);
	const hudProg = label(layer, FONT_R, 15, C_INK, 1160, 78, 1, 0);
	hudProg.opacity = 0.5;

	/* ══════════ HUD 设置：齿轮 + 面板 ══════════
	   齿轮和面板都是预渲染图（圆角、齿轮齿这种形状用 Sprite 拼不划算），
	   里面的滑条和文字还是实时画的——数值要跟着拖动变。 */
	const SET_X = 1194, SET_Y = 14, SET_S = 44;
	const gearBtn = Sprite('Image/StartUI/gear.png')!;
	gearBtn.anchor = Vec2(0, 1);
	gearBtn.size = Size(SET_S, SET_S);
	gearBtn.position = Vec2(SET_X, H - SET_Y);
	gearBtn.addTo(layer);

	const PANEL_W = 248, PANEL_H = 204;
	const PX = SET_X + SET_S - PANEL_W;
	const PY = SET_Y + SET_S + 10;

	const panel = Sprite('Image/StartUI/panel.png')!;
	panel.anchor = Vec2(0, 1);
	panel.size = Size(256, 212);              // 比面板本体大 8px，右下留给硬阴影
	panel.position = Vec2(PX - 4, H - (PY - 4));
	panel.addTo(layer);

	const IX = PX + 22, IW = PANEL_W - 44;
	const setParts: Sprite.Type[] = [];
	const sliderBg: Sprite.Type[] = [];
	const sliderFill: Sprite.Type[] = [];
	const knobEdge: Sprite.Type[] = [];
	const knobFace: Sprite.Type[] = [];
	const setLabels: Label.Type[] = [];

	const mkSetLabel = (size: number, color: Color.Type, x: number, y: number,
		ax: number, txt: string): Label.Type => {
		const lb = label(layer, size >= 16 ? FONT_R : FONT_R, size, color, x, y, ax, 1);
		lb.text = txt;
		setLabels.push(lb);
		return lb;
	};

	const barLabelY = [PY + 30, PY + 96];
	const barY = [PY + 46, PY + 112];

	for (let i = 0; i < 2; i++) {
		mkSetLabel(15, C_INK, IX, barLabelY[i], 0, i === 0 ? '背景音乐' : '音效');
		mkSetLabel(14, C_TEAL, PX + PANEL_W - 22, barLabelY[i], 1, '70');

		const bg = block(layer, IX, barY[i], IW, 6, C_INK);
		bg.opacity = 0.14;
		sliderBg.push(bg);

		const fill = block(layer, IX, barY[i], IW, 6, C_TEAL);
		sliderFill.push(fill);

		const ke = block(layer, 0, 0, 12, 20, C_INK);
		knobEdge.push(ke);
		const kf = block(layer, 0, 0, 10, 18, C_PAPER);
		knobFace.push(kf);
	}

	const setSep = block(layer, IX, PY + 140, IW, 1, C_INK);
	setSep.opacity = 0.12;
	const backEdge = block(layer, IX, PY + 152, IW, 36, C_INK);
	backEdge.opacity = 0.7;
	const backFace = block(layer, IX + 1.6, PY + 153.6, IW - 3.2, 33, Color(252, 247, 232, 255));
	// 按钮 152..188，中心 170；label 的 y 是底边，所以给 177 才视觉居中
	const backLb = label(layer, FONT_R, 16, C_INK, IX + IW / 2, PY + 177, 0.5, 2);
	backLb.text = '返回主菜单';
	setLabels.push(backLb);

	// 面板开合时统一显隐
	const setToggle = (vis: boolean): void => {
		panel.visible = vis;
		setSep.visible = vis;
		backEdge.visible = vis;
		backFace.visible = vis;
		for (const x of setParts) { x.visible = vis; }
		for (const x of sliderBg) { x.visible = vis; }
		for (const x of sliderFill) { x.visible = vis; }
		for (const x of knobEdge) { x.visible = vis; }
		for (const x of knobFace) { x.visible = vis; }
		for (const x of setLabels) { x.visible = vis; }
	};
	setToggle(false);

	/* ══════════ 飘分 ══════════
	   +N 弹出来往上浮。描边直接用 SDF 的 outline——比再叠一层 Label 便宜，
	   而且边缘是矢量的，缩放不会糊。 */
	type Pop = { x: number; y: number; v: number; t: number; dur: number };
	let pops: Pop[] = [];
	const POP_POOL = 6;
	const popLabels: Label.Type[] = [];
	const popShadow: Label.Type[] = [];
	for (let i = 0; i < POP_POOL; i++) {
		const sh = label(layer, FONT_B, 30, C_INK, 0, 0, 0.5, 1);
		sh.opacity = 0;
		popShadow.push(sh);
		const lb = label(layer, FONT_B, 30, C_VERM, 0, 0, 0.5, 1);
		lb.outlineColor = C_PAPER;
		lb.outlineWidth = 0.16;
		lb.opacity = 0;
		popLabels.push(lb);
	}

	const syncPops = (): void => {
		for (let i = 0; i < POP_POOL; i++) {
			const p = i < pops.length ? pops[i] : undefined;
			if (p === undefined) {
				popLabels[i].opacity = 0;
				popShadow[i].opacity = 0;
				continue;
			}
			const a = Math.max(0, p.t / p.dur);
			const y = p.y - (1 - a) * 34;
			const al = Math.min(1, a * 1.6);
			popShadow[i].text = '+' + p.v.toString();
			popShadow[i].position = Vec2(p.x + 2, H - y + 30);
			popShadow[i].opacity = al * 0.6;
			popLabels[i].text = '+' + p.v.toString();
			popLabels[i].position = Vec2(p.x, H - y + 30);
			popLabels[i].opacity = al;
		}
	};

	/* ══════════ 键帽提示：R 转方向 / Esc 放回 ══════════
	   右下角挨着台面。从右往左量一遍：放回 30 + Esc 36 + 间隔 28 + 转方向 45 + 间隔 8 + R 30 = 185 */
	const HINT_RIGHT = 1246, HINT_CY = 751, CAPH = 24;
	const capEdge: Sprite.Type[] = [];
	const capBody: Sprite.Type[] = [];
	const mkCap = (x: number, w: number, txt: string): Label.Type => {
		const e = block(layer, x, HINT_CY - CAPH / 2, w, CAPH, C_INK);
		e.visible = true;
		e.opacity = 0.58;
		capEdge.push(e);
		const b = block(layer, x + 1.4, HINT_CY - CAPH / 2 + 1.4, w - 2.8, CAPH - 2.8, C_PAPER);
		b.visible = true;
		b.opacity = 0.72;
		capBody.push(b);
		const lb = label(layer, FONT_R, 12, C_INK, x + w / 2, HINT_CY + 6, 0.5, 0);
		lb.text = txt;
		return lb;
	};

	const X0 = HINT_RIGHT - 185;
	mkCap(X0, 30, 'R');
	const tRot = label(layer, FONT_R, 15, C_INK, X0 + 38, HINT_CY + 8, 0, 1);
	tRot.text = '转方向';
	tRot.opacity = 0.86;
	mkCap(X0 + 111, 36, 'Esc');
	const tBack = label(layer, FONT_R, 15, C_INK, X0 + 155, HINT_CY + 8, 0, 1);
	tBack.text = '放回';
	tBack.opacity = 0.86;

	const syncSet = (): void => {
		const vis = showSet && state === 'play';
		if (panel.visible !== vis) { setToggle(vis); }
		if (!vis) { return; }

		const vals = [audio.bgm, audio.sfx];
		for (let i = 0; i < 2; i++) {
			const k = vals[i];
			const w = Math.round(IW * k);
			show(sliderFill[i], IX, barY[i], Math.max(1, w), 6);
			const hx = IX + w - 5;
			show(knobEdge[i], hx, barY[i] - 7, 12, 20);
			show(knobFace[i], hx + 1, barY[i] - 6, 10, 18);
		}
		setLabels[1].text = Math.round(audio.bgm * 100).toString();
		setLabels[3].text = Math.round(audio.sfx * 100).toString();
	};

	/* ══════════ 遮罩 / 集中线 / 纸卡 / 印章 ══════════ */
	const veil = block(layer, 0, 0, W, H, Color(237, 227, 200, 255));
	const burst = Sprite('Image/StartUI/burst.png')!;
	burst.anchor = Vec2(0, 1);
	burst.size = Size(W, 800);
	burst.position = Vec2(0, H);
	burst.addTo(layer);

	/* ── 开始页的「左文右立绘」版式（对照 03-界面与版式/lv2-完整界面 的关前页） ──
	   城墙带 + 梁把画面切成「墙外 / 墙内」，标题和说明落在左栏，王梓站右栏。 */
	const stWall = Sprite('Image/StartUI/ready_wall.png')!;
	stWall.anchor = Vec2(0, 1);
	stWall.size = Size(W, 150);
	stWall.position = Vec2(0, H);
	stWall.addTo(layer);

	const stBeam = block(layer, 0, 150, W, 24, Color(28, 44, 40, 255));
	const stBeamTop = block(layer, 0, 151, W, 3, Color(237, 227, 200, 110));
	const stBeamLine = block(layer, 0, 174, W, 3, C_INK);

	const stWz = Sprite('Image/StartUI/face_smile.png')!;
	stWz.anchor = Vec2(0, 1);
	stWz.size = Size(286, 384);
	stWz.position = Vec2(918, H - 316);
	stWz.addTo(layer);

	const stFoot = label(layer, FONT_R, 11, Color(36, 73, 70, 105), 112, 752, 0, 1.2);
	stFoot.text = '永昌堡 · 嘉靖四十年 · 五月';

	const card = Sprite('Image/StartUI/card.png')!;
	card.anchor = Vec2(0, 1);
	card.size = Size(782, 484);
	card.position = Vec2(254, H - 160);
	card.addTo(layer);

	const sealHe = Sprite('Image/StartUI/seal_he.png')!;
	const sealPo = Sprite('Image/StartUI/seal_po.png')!;
	for (const sp of [sealHe, sealPo]) {
		sp.anchor = Vec2(0, 1);
		sp.size = Size(76, 76);
		sp.position = Vec2(910, H - 196);
		sp.visible = false;
		sp.addTo(layer);
	}

	/* 结束页文字 */
	const endTitle = label(layer, FONT_B, 60, C_INK, 640, 268, 0.5, 6);
	const endScore = label(layer, FONT_B, 76, C_INK, 640, 406, 0.5, 2);
	const endStat = label(layer, FONT_R, 18, Color(36, 73, 70, 150), 640, 448, 0.5, 1);
	const endTip = label(layer, FONT_R, 20, Color(36, 73, 70, 200), 640, 516, 0.5, 1);

	// 分数上面那行小标签，和中间一截朱红的分隔线——之前漏了，卡片看着空
	const endRule = block(layer, 580, 284, 120, 4, C_VERM);
	const endLabel = label(layer, FONT_R, 14, C_INK, 640, 326, 0.5, 7);
	endLabel.text = '得　分';
	endLabel.opacity = 0.58;
	const endSepLine = block(layer, 400, 472, 480, 1, C_INK);
	endSepLine.opacity = 0.16;
	const endSepRed = block(layer, 618, 471, 44, 3, C_VERM);

	/* 开始页文字 */
	const stTitle = label(layer, FONT_B, 82, C_INK, 106, 292, 0, 16);
	stTitle.text = '砌墙';
	const stYi = Sprite('Image/StartUI/seal_yi.png')!;
	stYi.anchor = Vec2(0, 1);
	stYi.size = Size(36, 36);
	stYi.position = Vec2(112, H - 210);
	stYi.addTo(layer);
	const stQian = label(layer, FONT_B, 14, Color(36, 73, 70, 140), 160, 220, 0, 4);
	stQian.text = '关 前';
	const stRule = block(layer, 112, 396, 128, 4, C_VERM);
	const stSub = label(layer, FONT_B, 23, Color(36, 73, 70, 225), 112, 430, 0, 1.4);
	stSub.text = '城墙六行，缺处待补';
	const stSep = block(layer, 112, 492, 448, 1, C_INK);
	stSep.opacity = 0.3;
	const stLine1 = label(layer, FONT_R, 16, Color(36, 73, 70, 190), 112, 524, 0, 0.8);
	stLine1.text = '墙在走。手上有五块石头，把对的形状转到对的朝向，嵌进去。';
	const stLine2 = label(layer, FONT_R, 16, Color(36, 73, 70, 190), 112, 556, 0, 0.6);
	stLine2.text = '补满 10 个洞，这段墙就合上了。漏掉一个，就守不住。';
	const stSpace = label(layer, FONT_R, 13, C_INK, 384, 642, 0, 1.6);
	stSpace.text = '点任意处 / 空格';
	stSpace.opacity = 0.5;

	/* ══════════ 按钮 ══════════ */
	type Btn = {
		shadow: Sprite.Type; body: Sprite.Type; text: Label.Type;
		x: number; y: number; w: number; h: number; kind: string;
	};
	const mkBtn = (): Btn => {
		const shadow = block(layer, 0, 0, 1, 1, Color(36, 73, 70, 235));
		const body = Sprite('Image/StartUI/btn.png')!;
		body.anchor = Vec2(0, 1);
		body.size = Size(1, 1);
		body.position = Vec2(0, H);
		body.visible = false;
		body.addTo(layer);
		const t = label(layer, FONT_B, 22, C_INK, 0, 0, 0.5, 6);
		return { shadow: shadow, body: body, text: t, x: 0, y: 0, w: 240, h: 58, kind: '' };
	};
	const btn = mkBtn();

	const placeBtn = (b: Btn, x: number, y: number, w: number, h: number, kind: string): void => {
		b.x = x; b.y = y; b.w = w; b.h = h; b.kind = kind;
		b.shadow.visible = true; b.body.visible = true; b.text.visible = true;
	};
	const hideBtn = (b: Btn): void => {
		b.shadow.visible = false; b.body.visible = false; b.text.visible = false;
		b.kind = '';
	};
	const syncBtn = (b: Btn, hover: boolean, press: boolean, dt: number): void => {
		if (!b.body.visible) { return; }
		// 目标位移 0 / 3 / 6，用插值逼近，才有「按下去」的过渡感
		const target = press ? 6 : (hover ? 3 : 0);
		btnOff += (target - btnOff) * Math.min(1, dt * 22);
		if (Math.abs(target - btnOff) < 0.08) { btnOff = target; }
		const off = btnOff;
		show(b.shadow, b.x + 6, b.y + 6, b.w, b.h);
		b.body.color = hover ? C_INK
			: (state === 'ready' ? Color(236, 190, 176, 255) : Color(255, 255, 255, 255));
		show(b.body, b.x + off, b.y + off, b.w, b.h);
		b.text.color = hover ? Color(252, 247, 232, 245) : C_INK;
		b.text.position = Vec2(b.x + off + b.w / 2, H - (b.y + off + b.h / 2 - 11));
	};

	/* ══════════ 开始页入场 ══════════
	   城墙落下 → 印章砸下 → 标题滑入 → 横线拉开 → 副题 → 分隔线 → 两句 → 按钮。
	   全是三次缓出，总长 1.8s；不重排节点，只推 opacity 和几处位移。 */
	let readyT = 0;

	const syncReady = (dt: number): void => {
		if (state !== 'ready') {
			if (readyT > 0) {
				readyT = 0;
				stWall.position = Vec2(0, H);
				stWz.position = Vec2(918, H - 316);
				stTitle.position = Vec2(106, H - 292);
				stTitle.opacity = 1;
				stYi.opacity = 1; stYi.scaleX = 1; stYi.scaleY = 1;
				stSub.opacity = 1; stLine1.opacity = 1; stLine2.opacity = 1;
				stSpace.opacity = 0.5; stQian.opacity = 1; stFoot.opacity = 1;
				stSep.opacity = 0.3;
				show(stRule, 112, 396, 128, 4);
			}
			return;
		}

		readyT += dt;
		const ease = (t0: number, dur: number): number => {
			const k = Math.min(1, Math.max(0, (readyT - t0) / dur));
			return 1 - Math.pow(1 - k, 3);
		};

		const aWall = ease(0.04, 0.48);
		stWall.position = Vec2(0, H - 26 * (1 - aWall));

		const aWz = ease(0.18, 0.58);
		stWz.position = Vec2(918 + 72 * (1 - aWz), H - 316);

		const aYi = ease(0.22, 0.24);
		stYi.opacity = aYi;
		const kYi = 1 + 1.3 * (1 - aYi);
		stYi.scaleX = kYi; stYi.scaleY = kYi;
		stQian.opacity = ease(0.30, 0.30);

		const aTitle = ease(0.42, 0.48);
		stTitle.opacity = aTitle;
		stTitle.position = Vec2(106 + 42 * (1 - aTitle), H - 292);

		const aRule = ease(0.68, 0.40);
		show(stRule, 112, 396, Math.max(1, 128 * aRule), 4);

		stSub.opacity = ease(0.84, 0.42);
		stSep.opacity = 0.3 * ease(0.98, 0.40);
		stLine1.opacity = ease(1.06, 0.42);
		stLine2.opacity = ease(1.16, 0.42);
		stSpace.opacity = 0.5 * ease(1.34, 0.42);
		stFoot.opacity = ease(1.44, 0.42);

		if (btn.body.visible) {
			const aBtn = ease(1.28, 0.42);
			btn.body.opacity = aBtn;
			btn.shadow.opacity = aBtn * 0.92;
			btn.text.opacity = aBtn;
		}
	};

	/* ══════════ 游戏状态 ══════════ */
	let state = 'ready';       // ready | play | win | over
	let shakeT = 0, shakeTarget = -1;          // 填错时那个洞抖一下
	let flashGap: { x: number; y: number; w: number; h: number; t: number; ok: boolean } | undefined = undefined;
	let hintOn = true;                          // 可填缺口高亮（正式功能）
	let showSet = false;                        // 设置面板
	const audio = { bgm: 0.7, sfx: 0.8 };
	let gaps: Gap[] = [];
	let hand: Card[] = [];
	let bag: string[] = [];
	let held: Card | undefined = undefined;
	let speedBase = V0;
	let score = 0, filled = 0, timeouts = 0, rotLockT = 0, rotCount = 0;
	let spawnTimer = 1.1;
	let scrollX = 0;
	let timeAll = 0, faceHold = 0;
	let debugHold = false;

	const rnd = (): number => Math.random();

	const nextFromBag = (): string => {
		if (bag.length === 0) {
			const b: string[] = [];
			for (let i = 0; i < KEYS.length; i++) { b.push(KEYS[i]); }
			for (let i = b.length - 1; i > 0; i--) {
				const j = Math.floor(rnd() * (i + 1));
				const t = b[i]; b[i] = b[j]; b[j] = t;
			}
			bag = b;
		}
		return bag.pop()!;
	};
	const randVi = (shape: string, easy: boolean): number => {
		const n = VARIANTS[shape].length;
		return easy ? 0 : Math.floor(rnd() * n);
	};
	const drawCard = (): Card => {
		const shape = nextFromBag();
		return { shape: shape, vi: randVi(shape, filled < EASY_GAPS) };
	};

	const curCol = (g: Gap, c: number): number => Math.round(g.x / CELL) + c;

	const occupied = (): { [k: string]: boolean } => {
		const s: { [k: string]: boolean } = {};
		for (const g of gaps) {
			for (const cell of g.cells) {
				s[curCol(g, cell[0]) + ',' + cell[1]] = true;
			}
		}
		return s;
	};

	const SEAM_SEP = 1;

	const spawnGap = (): boolean => {
		if (hand.length === 0) { return false; }
		const easy = filled < EASY_GAPS;

		const owned: string[] = [];
		for (const c of hand) {
			if (owned.indexOf(c.shape) < 0) { owned.push(c.shape); }
		}
		const lastShape = gaps.length > 0 ? gaps[gaps.length - 1].shape : '';
		let pool: string[] = [];
		for (const s of owned) { if (s !== lastShape) { pool.push(s); } }
		if (pool.length === 0) { pool = owned; }
		const shape = pool[Math.floor(rnd() * pool.length)];

		const vs = VARIANTS[shape];
		const vi = easy ? 0 : Math.floor(rnd() * vs.length);
		const v = vs[vi];

		const taken = occupied();
		const baseCol = -v.w;
		const rs: number[] = [];
		for (let r = 0; r <= ROWS - v.h; r++) { rs.push(r); }
		for (let i = rs.length - 1; i > 0; i--) {
			const j = Math.floor(rnd() * (i + 1));
			const t = rs[i]; rs[i] = rs[j]; rs[j] = t;
		}

		const colClash = (colBase: number): boolean => {
			for (const g of gaps) {
				const gc = Math.round(g.x / CELL);
				if (colBase < gc + g.w + SEAM_SEP && gc < colBase + v.w + SEAM_SEP) { return true; }
			}
			return false;
		};

		for (let dx = 0; dx >= -10; dx--) {
			for (const r0 of rs) {
				const colBase = baseCol + dx;
				if (colClash(colBase)) { continue; }
				const cells: number[][] = [];
				let bad = false;
				for (const cell of v.cells) {
					const c = cell[0], r = cell[1] + r0;
					if (taken[(colBase + c) + ',' + r]) { bad = true; break; }
					cells.push([c, r]);
				}
				if (bad) { continue; }
				gaps.push({
					shape: shape, vi: vi, ck: v.ck, w: v.w, h: v.h,
					cells: cells, r0: r0, x: colBase * CELL, age: 0, id: rnd(),
				});
				return true;
			}
		}
		return false;
	};

	const refillCard = (i: number): void => {
		hand[i] = drawCard();
		for (const g of gaps) {
			let has = false;
			for (const c of hand) { if (c.shape === g.shape) { has = true; break; } }
			if (!has) {
				hand[i] = { shape: g.shape, vi: randVi(g.shape, filled < EASY_GAPS) };
				break;
			}
		}
	};

	const reset = (): void => {
		gaps = []; hand = []; bag = []; held = undefined;
		speedBase = V0; score = 0; filled = 0; timeouts = 0;
		rotLockT = 0; rotCount = 0; spawnTimer = 1.1; timeAll = 0; faceHold = 0;
		faceCur = 0;
		pops = []; shakeT = 0; shakeTarget = -1; flashGap = undefined; showSet = false;
		for (let i = 0; i < HAND_N; i++) { hand.push(drawCard()); }
		state = 'play';
	};

	reset();
	state = startPhase !== undefined ? startPhase : 'ready';
	// 调试：'hold' 直接进入持牌状态，方便截可填高亮
	if (startPhase === 'hold') { state = 'play'; debugHold = true; }
	if (startPhase === 'settings') { state = 'play'; showSet = true; }
	if (startPhase === 'pops') {
		state = 'play';
		pops.push({ x: 640, y: 470, v: 186, t: 6, dur: 6 });
		pops.push({ x: 420, y: 520, v: 92, t: 6, dur: 6 });
	}

	/* ══════════ 每帧同步到场景图 ══════════ */
	const syncGaps = (): void => {
		// 填错时这个洞会抖：±6px，约 14Hz
		const shakeOf = (g: Gap): number =>
			(shakeT > 0 && shakeTarget === g.id) ? Math.sin(shakeT * 90) * 6 : 0;

		let k = 0, e = 0, l = 0;

		for (const g of gaps) {
			const sh = shakeOf(g);

			// Lua 没有原生 Set，判断「相邻格有没有洞」用哈希表
			const occ: { [key: string]: boolean } = {};
			for (const c of g.cells) { occ[c[0] + ',' + c[1]] = true; }

			for (const cell of g.cells) {
				if (k >= GAP_POOL) { break; }
				const cx = g.x + cell[0] * CELL + sh;
				const cy = WALL_T + cell[1] * CELL;
				const has = (dc: number, dr: number): boolean =>
					occ[(cell[0] + dc) + ',' + (cell[1] + dr)] === true;

				show(gapCells[k], cx, cy, CELL, CELL);
				k++;

				// 描边：3px，居中压在格线上（所以往洞外偏 1.5px）
				if (e < EDGE_POOL) {
					if (!has(0, -1)) { show(edgePool[e++], cx, cy - 1.5, CELL, 3); }
					if (!has(0, 1) && e < EDGE_POOL) { show(edgePool[e++], cx, cy + CELL - 1.5, CELL, 3); }
					if (!has(-1, 0) && e < EDGE_POOL) { show(edgePool[e++], cx - 1.5, cy, 3, CELL); }
					if (!has(1, 0) && e < EDGE_POOL) { show(edgePool[e++], cx + CELL - 1.5, cy, 3, CELL); }
				}

				// 内壁受光：洞顶一条 4px 纸色亮边，压在墨线下方 2px
				if (!has(0, -1) && l < LIT_POOL) {
					show(litPool[l++], cx, cy + 2, CELL, 4);
				}
			}
		}
		for (let i = k; i < GAP_POOL; i++) { hide(gapCells[i]); }
		for (let i = e; i < EDGE_POOL; i++) { hide(edgePool[i]); }
		for (let i = l; i < LIT_POOL; i++) { hide(litPool[i]); }

		// ── 可填高亮：手里这张牌能填的那个洞 ──
		let hit: Gap | undefined = undefined;
		if (hintOn && state === 'play' && held !== undefined) {
			const hv = VARIANTS[held.shape][held.vi];
			for (const g of gaps) { if (g.ck === hv.ck) { hit = g; break; } }
		}

		let hk = 0;
		if (hit !== undefined) {
			const breath = 0.78 + 0.22 * (0.5 + 0.5 * Math.sin(timeAll * 6));
			const sh = shakeOf(hit);

			// 洞底斜排线：逐格贴，贴着格子边界，不会糊到墙上
			for (const cell of hit.cells) {
				if (hk >= HATCH_POOL) { break; }
				const h = hatchPool[hk++];
				show(h, hit.x + cell[0] * CELL + sh, WALL_T + cell[1] * CELL, CELL, CELL);
				h.opacity = 0.20 * breath;
			}

			// 朱红四角准星
			const x0 = hit.x - 10 + sh;
			const y0 = WALL_T + hit.r0 * CELL - 10;
			const w0 = hit.w * CELL + 20;
			const h0 = hit.h * CELL + 20;
			const t = 3.2;
			for (let i = 0; i < 4; i++) { hintEdges[i].opacity = breath; }
			show(hintEdges[0], x0, y0, w0, t);
			show(hintEdges[1], x0, y0 + h0 - t, w0, t);
			show(hintEdges[2], x0, y0, t, h0);
			show(hintEdges[3], x0 + w0 - t, y0, t, h0);
		} else {
			for (let i = 0; i < 4; i++) { hide(hintEdges[i]); }
		}
		for (let i = hk; i < HATCH_POOL; i++) { hide(hatchPool[i]); }

		// ── 新洞口：0.9 秒朱红准星，替玩家指一下「这儿刚裂开」──
		// 已经能填的洞不再重复画，两圈准星套在同一处会很脏
		let ni = 4;
		for (const g of gaps) {
			if (g === hit || g.age >= 0.9) { continue; }
			if (ni + 3 >= hintEdges.length) { break; }
			const a = 1 - g.age / 0.9;
			const sh = shakeOf(g);
			const x0 = g.x - 7 + sh;
			const y0 = WALL_T + g.r0 * CELL - 7;
			const w0 = g.w * CELL + 14;
			const h0 = g.h * CELL + 14;
			for (let i = ni; i < ni + 4; i++) { hintEdges[i].opacity = 0.8 * a; }
			show(hintEdges[ni], x0, y0, w0, 2.4);
			show(hintEdges[ni + 1], x0, y0 + h0 - 2.4, w0, 2.4);
			show(hintEdges[ni + 2], x0, y0, 2.4, h0);
			show(hintEdges[ni + 3], x0 + w0 - 2.4, y0, 2.4, h0);
			ni += 4;
		}
		for (let i = ni; i < hintEdges.length; i++) { hide(hintEdges[i]); }

		// ── 命中 / 填错：0.3 秒边框反馈 ──
		if (flashGap !== undefined && flashGap.t > 0) {
			const a = flashGap.t / 0.3;
			const col = flashGap.ok ? C_TEAL : C_VERM;
			const x0 = flashGap.x - 4, y0 = flashGap.y - 4;
			const w0 = flashGap.w + 8, h0 = flashGap.h + 8;
			for (let i = 0; i < 4; i++) { flashEdges[i].color = col; flashEdges[i].opacity = a; }
			show(flashEdges[0], x0, y0, w0, 4);
			show(flashEdges[1], x0, y0 + h0 - 4, w0, 4);
			show(flashEdges[2], x0, y0, 4, h0);
			show(flashEdges[3], x0 + w0 - 4, y0, 4, h0);
		} else {
			for (const f of flashEdges) { hide(f); }
		}
	};

	const syncHand = (): void => {
		const hi = held === undefined ? -1 : hand.indexOf(held);
		const baseK = state === 'play' ? 1 : (state === 'ready' ? 0.22 : 0);
		let k = 0;

		for (let i = 0; i < hand.length; i++) {
			const card = hand[i];
			const v = VARIANTS[card.shape][card.vi];
			const sx = HAND_X + i * (SLOT_W + SLOT_GAP);
			// 居中按「格子的真实包围盒」算，不要用 v.w / v.h——
			// 那两个是归一化时算的，只要和 cells 的实际范围对不上，整张牌就会偏。
			let bx = 99, by = 99, ex = -99, ey = -99;
			for (const c of v.cells) {
				if (c[0] < bx) bx = c[0];
				if (c[0] > ex) ex = c[0];
				if (c[1] < by) by = c[1];
				if (c[1] > ey) ey = c[1];
			}
			const bw = ex - bx + 1, bh = ey - by + 1;
			const ox = sx + (SLOT_W - bw * CW) / 2;
			const oy = SLOT_Y + (SLOT_H - bh * CW) / 2;
			const lift = i === hi ? 14 : 0;
			const lit = i === hi;
			const dimK = baseK * ((hi >= 0 && !lit) ? 0.42 : 1);

			slots[i].opacity = baseK;

			for (let n = 0; n < 4; n++) {
				const s = chipPool[k];
				k++;
				if (n < v.cells.length) {
					const c = v.cells[n];
					show(s, ox + (c[0] - bx) * CW, oy + (c[1] - by) * CW - lift, CW, CW);
					s.color = lit ? Color(255, 250, 238, 255) : Color(255, 255, 255, 255);
					s.opacity = dimK;
				} else {
					hide(s);
				}
			}
		}
		for (let i = k; i < chipPool.length; i++) { hide(chipPool[i]); }

		// 持牌：包围盒一道青绿粗框（比沿形状描边更清楚「拿的是哪张」）
		if (hi >= 0 && hi < hand.length) {
			const v = VARIANTS[hand[hi].shape][hand[hi].vi];
			const sx = HAND_X + hi * (SLOT_W + SLOT_GAP);
			const ox = sx + (SLOT_W - v.w * CW) / 2;
			const oy = SLOT_Y + (SLOT_H - v.h * CW) / 2 - 14;
			const fw = v.w * CW, fh = v.h * CW, t = 4;
			for (const f of handFrame) { f.opacity = baseK; }
			show(handFrame[0], ox - t, oy - t, fw + t * 2, t);
			show(handFrame[1], ox - t, oy + fh, fw + t * 2, t);
			show(handFrame[2], ox - t, oy - t, t, fh + t * 2);
			show(handFrame[3], ox + fw, oy - t, t, fh + t * 2);
		} else {
			for (const f of handFrame) { hide(f); }
		}

		// 旋转锁定条
		if (held !== undefined && rotLockT > 0 && state === 'play' && hi >= 0) {
			const r = rotLockT / ROT_LOCK;
			show(rotBar, HAND_X + hi * (SLOT_W + SLOT_GAP), SLOT_Y - 3,
				Math.round(SLOT_W * r), 2);
			rotBar.opacity = 0.55 * r;
		} else {
			hide(rotBar);
		}
	};

	const syncHud = (): void => {
		hudScore.text = Math.round(score).toString();
		hudProg.text = '已补 ' + filled.toString() + ' / ' + GAPS_TO_WIN.toString() + ' 洞';
		const r = Math.min(1, filled / GAPS_TO_WIN);
		if (r > 0.001) { show(barFill, 340, 33, Math.round(Math.max(2, 540 * r)), 7); } else { hide(barFill); }
	};

	// 墙和缺口一起往右走：off 从 0 涨到 STRIP_W，左块从 -2560 推到 0，右块从 0 推到 2560
	const syncWall = (): void => {
		const off = scrollX - Math.floor(scrollX / STRIP_W) * STRIP_W;
		walls[0].position = Vec2(off - STRIP_W, H - WALL_T);
		walls[1].position = Vec2(off, H - WALL_T);
	};

	const setFace = (i: number, hold: number): void => { faceCur = i; faceHold = hold; };
	const faceIdx = (k: string): number => {
		const i = FACE_LIST.indexOf(k);
		return i < 0 ? 0 : i;
	};

	/* 三套画面：开始 / 玩法 / 结算 —— 用 visible 切换，不重建节点 */
	const syncScreens = (): void => {
		const startOn = state === 'ready';
		const endOn = state === 'win' || state === 'over';
		const playOn = state === 'play';

		veil.visible = startOn || endOn;
		veil.opacity = endOn ? 0.995 : (startOn ? 1 : 0.985);
		burst.visible = startOn || endOn;
		burst.opacity = startOn ? 0.13 : (state === 'win' ? 0.21 : 0.10);
		burst.position = Vec2(0, H - (startOn ? -36 : -30));

		card.visible = endOn;
		sealHe.visible = endOn && state === 'win';
		sealPo.visible = endOn && state === 'over';
		endTitle.visible = endOn;
		endScore.visible = endOn;
		endStat.visible = endOn;
		endTip.visible = endOn;
		endRule.visible = endOn;
		endLabel.visible = endOn;
		endSepLine.visible = endOn;
		endSepRed.visible = endOn;

		stTitle.visible = startOn;
		stYi.visible = startOn;
		stSub.visible = startOn;
		stRule.visible = startOn;
		stLine1.visible = startOn;
		stLine2.visible = startOn;
		stSpace.visible = startOn;
		stWall.visible = startOn;
		stBeam.visible = startOn;
		stBeamTop.visible = startOn;
		stBeamLine.visible = startOn;
		stWz.visible = startOn;
		stFoot.visible = startOn;
		stSep.visible = startOn;
		stQian.visible = startOn;

		// 玩法元素在结算时留着（被遮罩盖住），开始页也留着当背景
		for (const s of gapCells) { s.opacity = playOn ? 1 : (endOn ? 0 : 1); }

		for (const s of faces) { s.opacity = s === faces[faceCur] && !endOn ? 1 : 0; }
		dlgBox.visible = playOn;
		dlgName.visible = playOn;
		dlgBar.visible = playOn;
		for (const c of dlgCorner) { c.visible = playOn; }

		if (startOn) {
			placeBtn(btn, 112, 612, 240, 60, 'start');
			btn.text.text = '开　始';
		} else if (state === 'win') {
			placeBtn(btn, 520, 550, 240, 56, 'next');
			btn.text.text = '下一关';
		} else if (state === 'over') {
			placeBtn(btn, 520, 550, 240, 56, 'again');
			btn.text.text = '重　来';
		} else {
			hideBtn(btn);
		}

		if (endOn) {
			const win = state === 'win';
			endTitle.text = win ? '墙合上了' : '缺口滚过去了';
			endTitle.color = win ? C_INK : C_VERM;
			endScore.text = Math.round(score).toString();
			endStat.text = '填了 ' + filled.toString() + ' 个缺口 · 漏掉 ' + timeouts.toString()
				+ ' 次 · 转了 ' + rotCount.toString() + ' 次';
			endTip.text = win ? '这一段墙补完了，城还在。' : '漏掉一个缺口，墙就漏了。';

		}
	};

	/* ══════════ 输入 ══════════ */
	let hover = false, press = false, btnOff = 0;
	let hoverX = -1, hoverY = -1;

	const inBtn = (x: number, y: number): boolean => {
		if (!btn.body.visible) { return false; }
		return x >= btn.x && x <= btn.x + btn.w && y >= btn.y && y <= btn.y + btn.h;
	};

	const gapAt = (px: number, py: number): Gap | undefined => {
		let best: Gap | undefined = undefined;
		let bd = 1e9;
		for (const g of gaps) {
			const gw = g.w * CELL, gh = g.h * CELL;
			const r0 = WALL_T + g.r0 * CELL;
			const c = Math.floor((px - g.x) / CELL);
			const rr = Math.floor((py - WALL_T) / CELL);
			let inCell = false;
			for (const cell of g.cells) {
				if (cell[0] === c && cell[1] === rr) { inCell = true; break; }
			}
			const pad = 14;
			const inBox = px >= g.x - pad && px <= g.x + gw + pad
				&& py >= r0 - pad && py <= r0 + gh + pad;
			if (!inCell && !inBox) { continue; }
			const cx = g.x + gw / 2, cy = r0 + gh / 2;
			const d = (px - cx) * (px - cx) + (py - cy) * (py - cy) + (inCell ? -1e6 : 0);
			if (d < bd) { bd = d; best = g; }
		}
		return best;
	};

	const rotateHeld = (): void => {
		if (held === undefined || rotLockT > 0) { return; }
		const vs = VARIANTS[held.shape];
		if (vs.length <= 1) { return; }
		held.vi = (held.vi + 1) % vs.length;
		rotLockT = ROT_LOCK;
		rotCount++;
	};

	const toggleHold = (i: number, isRight: boolean): void => {
		if (isRight) {
			held = hand[i];
			const vs = VARIANTS[held.shape];
			if (vs.length > 1 && rotLockT <= 0) {
				held.vi = (held.vi + 1) % vs.length;
				rotLockT = ROT_LOCK; rotCount++;
			}
		} else {
			held = held === hand[i] ? undefined : hand[i];
		}
	};

	const tryPlace = (px: number, py: number): void => {
		const g = gapAt(px, py);
		if (g === undefined || held === undefined) { return; }
		const v = VARIANTS[held.shape][held.vi];
		if (v.ck === g.ck) {
			const f = Math.max(0, Math.min(1, 1 - g.x / W));
			const mult = 1 + 0.1 * Math.min(filled, 10);
			score += Math.round((20 + 180 * f) * mult * 10) / 10;
			filled += 1;
			speedBase = Math.min(V_CAP, V0 * Math.pow(1.12, Math.floor(filled / 3)));
			flashGap = {
				x: g.x, y: WALL_T + g.r0 * CELL,
				w: g.w * CELL, h: g.h * CELL, t: 0.32, ok: true,
			};
			const gain = Math.round((20 + 180 * f) * mult);
			if (pops.length < POP_POOL) {
				pops.push({
					x: g.x + g.w * CELL / 2,
					y: WALL_T + g.r0 * CELL - 12,
					v: gain, t: 0.7, dur: 0.7,
				});
			}
			gaps = gaps.filter((x) => x !== g);
			const i = hand.indexOf(held);
			if (i >= 0) { refillCard(i); }
			held = undefined;
			spawnTimer = SPAWN_DELAY;
			setFace(faceIdx('laugh'), 0.9);
			if (filled >= GAPS_TO_WIN) { state = 'win'; }
		} else {
			// 填错只弹回：抖一下、红框提示、牌卸下。不扣分，也不出局——
			// 出局的唯一条件是「缺口滚出右边界」（见 update 里的 dead 判定）
			shakeT = 0.28; shakeTarget = g.id;
			flashGap = {
				x: g.x, y: WALL_T + g.r0 * CELL,
				w: g.w * CELL, h: g.h * CELL, t: 0.28, ok: false,
			};
			held = undefined;
			setFace(faceIdx('dot'), 0.7);
		}
	};

	const handleTap = (x: number, y: number, isRight: boolean): void => {
		if (state !== 'play') { return; }

		// 设置面板优先吃掉点击，免得点滑条时顺手把牌放下去了
		if (showSet) {
			const inPanel = x >= PX && x <= PX + PANEL_W && y >= PY && y <= PY + PANEL_H;
			if (inPanel) {
				for (let i = 0; i < 2; i++) {
					if (y >= barY[i] - 12 && y <= barY[i] + 18) {
						const k = Math.max(0, Math.min(1, (x - IX) / IW));
						if (i === 0) { audio.bgm = k; } else { audio.sfx = k; }
						return;
					}
				}
				if (y >= PY + 152 && y <= PY + 190) {
					showSet = false;
					// 这里是「回主界面」，不是重开来一局。
					// 没接 onExit 的场景（比如单测）才退化成重开。
					if (onExit !== undefined) { onExit(); } else { reset(); }
					return;
				}
				return;
			}
			showSet = false;
			return;
		}

		// 齿轮
		if (x >= SET_X && x <= SET_X + SET_S && y >= SET_Y && y <= SET_Y + SET_S) {
			showSet = true;
			return;
		}
		if (y >= SLOT_Y - 30 && y <= SLOT_Y + SLOT_H + 30) {
			for (let i = 0; i < hand.length; i++) {
				const sx = HAND_X + i * (SLOT_W + SLOT_GAP);
				if (x >= sx && x <= sx + SLOT_W && y >= SLOT_Y - 20 && y <= SLOT_Y + SLOT_H + 20) {
					toggleHold(i, isRight);
					return;
				}
			}
			return;
		}
		if (y >= WALL_T - 40 && y <= WALL_B + 40) { tryPlace(x, y); }
	};

	// 键盘：和画面右下角的键帽提示一一对应
	layer.keyboardEnabled = true;
	layer.onKeyDown((key) => {
		if (key === 'Space') {
			if (state === 'ready' || state === 'win' || state === 'over') { reset(); }
			else if (state === 'play') { held = undefined; }
			return;
		}
		if (state !== 'play' || showSet) { return; }
		if (key === 'R') {
			rotateHeld();
		} else if (key === 'Escape') {
			held = undefined;
		}
	});

	layer.touchEnabled = true;

	layer.onTapBegan((t) => {
		const x = t.location.x;
		const y = H - t.location.y;
		if (inBtn(x, y)) { press = true; }
	});

	// 悬停要用 MouseMove（不用按键就触发）；onTapMoved 是按住拖动
	layer.onMouseMove((t) => {
		hoverX = t.location.x;
		hoverY = H - t.location.y;
		hover = inBtn(hoverX, hoverY);
	});

	layer.onTapEnded((t) => {
		const x = t.location.x;
		const y = H - t.location.y;
		if (press && inBtn(x, y)) {
			press = false;
			if (btn.kind === 'start' || btn.kind === 'again') {
				reset();
			} else if (btn.kind === 'next') {
				onClear();
			}
			return;
		}
		press = false;
		handleTap(x, y, false);
	});

	/* ══════════ 每帧 ══════════ */
	const update = (dt: number): void => {
		timeAll += dt;
		if (faceHold > 0) {
			faceHold -= dt;
			if (faceHold <= 0) { faceCur = 0; }
		}

		// 抖动和命中反馈要在任何状态下都推进，否则结算遮罩落下时它们会僵在半路
		if (pops.length > 0) {
			for (let i = pops.length - 1; i >= 0; i--) {
				pops[i].t -= dt;
				if (pops[i].t <= 0) { pops.splice(i, 1); }
			}
		}
		if (shakeT > 0) { shakeT = Math.max(0, shakeT - dt); }
		if (flashGap !== undefined) {
			flashGap.t -= dt;
			if (flashGap.t <= 0) { flashGap = undefined; }
		}

		if (state === 'play') {
			// 调试：自动持一张能填当前缺口的牌
			if (debugHold && held === undefined && gaps.length > 0) {
				for (const c of hand) {
					if (VARIANTS[c.shape][c.vi].ck === gaps[0].ck) { held = c; break; }
				}
			}
			rotLockT = Math.max(0, rotLockT - dt);
			const v = speedBase;
			scrollX += v * dt;
			for (const g of gaps) { g.x += v * dt; g.age += dt; }

			const dead: Gap[] = [];
			for (const g of gaps) { if (g.x > W) { dead.push(g); } }
			if (dead.length > 0) {
				for (const g of dead) { gaps = gaps.filter((x) => x !== g); }
				timeouts += dead.length;
				setFace(faceIdx('dot'), 1.0);
				state = 'over';
			}

			if (state === 'play' && gaps.length < MAX_GAPS) {
				spawnTimer -= dt;
				if (spawnTimer <= 0) {
					spawnTimer = spawnGap() ? SPAWN_DELAY : 0.25;
				}
			}
		}

		syncWall();
		syncGaps();
		syncHand();
		syncHud();
		syncScreens();
		syncSet();
		syncPops();
		syncBtn(btn, hover, press, dt);
		syncReady(dt);

		// 王梓呼吸
		for (let i = 0; i < faces.length; i++) {
			faces[i].opacity = (i === faceCur && !(state === 'win' || state === 'over')) ? 1 : 0;
		}
	};

	const destroy = (): void => { layer.removeFromParent(); };

	// 测试用：跳过本关。直接走通关回调，不再要求点「下一关」
	let cleared = false;
	const skip = (): void => {
		if (cleared) { return; }
		cleared = true;
		onClear();
	};

	return {
		update: (dt: number): void => { update(dt); },
		destroy: (): void => { destroy(); },
		isDone: (): boolean => state === 'win' || state === 'over',
		state: (): string => state,
		skip: (): void => { skip(); },
	};
}
