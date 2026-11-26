// 第二关 · 砻糠计（音游玩法）
//
// 版式一比一照 02-可玩原型/lv2-砻糠计-完整版.html（1280×800）。数值一字未改：
// BPM 88 / 128 拍 / 四段 / 漏击疑心 +7 / 敲偏 +2 / 连击 6 减 2 / 满 100 降难度 / PREROLL 1.4。
//
// 三张静态大图是烘出来的（城头 lv2_crenel / 墙 lv2_wall / 光柱 lv2_shaft）：
// 引擎没有 clip、没有渐变、没有圆弧，而 HTML 的城头带一层暗角渐变 + 96 道砖缝，
// 逐块拼会到 300+ 节点、边缘还永远差半像素。烘图 2 倍导出，Dora 里 size 填逻辑尺寸 = 超采样。
// 曲线件（谷筐 / 糠袋 / 砻盘 / 齿轮 / 寇 / 糠块）同理，来自 _lv2_parts2.html。
//
// 层级严格照 HTML 的 draw() 调用顺序：
//   paper → crenel → guard → roomWall → beam → shafts → baskets → base → baseProps
//   → wangziWall → wangzi → notes → judge → mills → hitFx → HUD → banner → knock
// 注意 notes 在 mills 之前：砻要压住落进砻口的糠块。
import {
	Audio,
	Color,
	Label,
	Node,
	Size,
	Sprite,
	Vec2,
} from 'Dora';

const W = 1280;
const H = 800;

/* ══════════ 分区（HTML 第 79–95 行） ══════════ */
const HUD_H = 72;
const CT_T = 72, CT_B = 170;          // 城头（远）
const RM_T = 170, RM_B = 686;         // 碾房墙（中）
const FOOT_T = 678, FOOT_B = 702;     // 墙脚 24px
const BASE_T = 702;                   // 台基（近）
const JUDGE_Y = 702;                  // 判定线 = 台基顶边

const LANE_W = 168, LANE_GAP = 24, LANE_X0 = 364;
const LANE_CX = [
	LANE_X0 + LANE_W / 2,
	LANE_X0 + LANE_W + LANE_GAP + LANE_W / 2,
	LANE_X0 + (LANE_W + LANE_GAP) * 2 + LANE_W / 2,
];
const LANE_R = LANE_X0 + 3 * LANE_W + 2 * LANE_GAP;      // 916
const FALL_DIST = JUDGE_Y - RM_T;                        // 532

const WZ_X = 40, WZ_W = 266, WZ_H = 357, WZ_BOT = 708;

/* ══════════ 色（HTML 的 C 表） ══════════ */
const C_PAPER = Color(237, 227, 200, 255);
const C_PAPER2 = Color(243, 234, 211, 255);
const C_SANDD = Color(197, 188, 156, 255);
const C_SEAM = Color(168, 159, 127, 255);
const C_TRAY = Color(186, 176, 144, 255);
const C_TEAL = Color(90, 121, 104, 255);
const C_INK = Color(36, 73, 70, 255);
const C_DEEP = Color(23, 51, 48, 255);
const C_VERM = Color(163, 59, 42, 255);

/* 派生色：全是 HTML 里 mix(a, b, t) 的编译期结果，注释保留原式 */
const C_BEAM = Color(75, 100, 89, 255);        // mix(tray, ink, 0.74)
const C_FOOT = Color(174, 172, 144, 255);      // mix(sandD, ink, 0.14)
const C_MILLBASE = Color(207, 197, 168, 255);   // mix(tray, paper, 0.42)
const C_MULLION = Color(141, 145, 122, 255);    // mix(tray, ink, 0.30)

const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

/* ══════════ 节拍与谱面（HTML 第 263–281 行） ══════════ */
const BPM = 88, SPB = 60 / BPM, FALL_BEATS = 3, TOTAL_BEATS = 128, PREROLL = 1.4;
const PX_PER_SEC = FALL_DIST / (FALL_BEATS * SPB);

type Seg = { name: string; tag: string; from: number; to: number; lanes: number[] };
const SEGS: Seg[] = [
	{ name: '戌时', tag: '一更 · 只一台在响', from: 0, to: 24, lanes: [1] },
	{ name: '子时', tag: '三更 · 两台交替', from: 24, to: 56, lanes: [0, 1] },
	{ name: '寅时', tag: '五更 · 三台全开', from: 56, to: 88, lanes: [0, 1, 2] },
	{ name: '卯时', tag: '天将亮 · 加花', from: 88, to: 128, lanes: [0, 1, 2] },
];

const THUD = ['Audio/lv2_thud1.wav', 'Audio/lv2_thud2.wav', 'Audio/lv2_thud3.wav'];
const MISS_SFX = 'Audio/lv2_miss.wav';
const BGM = 'Audio/lv2_bgm.ogg';

const WIN_BASE = 0.14;
const WIN_MUL = [1.00, 0.92, 0.85, 0.79];

type Note = { t: number; lane: number; judged: boolean; result: number; fx: number };

export type Level2PlayOpts = {
	onFinish: () => void;
	onQuit?: () => void;    // 设置面板里「返回主菜单」
	onNext?: () => void;    // 关后页「好」→ 下一关
	onRestart?: () => void; // 关后页「再来一次」→ 重开本关
	startAt?: number;      // 调试：从第几拍开始
	immediate?: boolean;   // 调试：跳过标题卡，直接进对局（截图核对版式用）
	debugView?: string;    // 调试：'panel' 开设置面板 / 'pause' 开暂停页
};

export type Level2Play = {
	update(dt: number): void;
	destroy(): void;
	tapAt(x: number, y: number): boolean;
	hit(lane: number): void;
	skip(): void;
	isFinished(): boolean;
	togglePause(): void;
	dragTo(x: number, y: number): boolean;
	setPointer(x: number, y: number, down: boolean): void;
	hoverAt(x: number, y: number): void;
	isPaused(): boolean;
	stats(): number[];   // [命中, 漏击, 最大连击, 疑心峰值]
	setPanelOpen(): boolean;
};

export function createLevel2Play(parent: Node.Type, opts: Level2PlayOpts): Level2Play {
	/* ══════════ 工具 ══════════ */
	// block：y 是「顶边」。Dora 改 size 会把 anchor 重置回中心，所以顺序必须是
	// size → anchor → position，反了每个块都会偏左上半个尺寸。
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

	// img：y 也是「顶边」
	const img = (p: Node.Type, file: string, x: number, y: number, w: number, h: number): Sprite.Type => {
		const s = Sprite(file)!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		s.position = Vec2(x, H - y);
		s.visible = true;
		s.addTo(p);
		return s;
	};

	// label：y 是「文字底边」——和 block 的 y 语义相反。
	// HTML 的 txt() 用 alphabetic baseline，这里 +size 让底边对齐，误差约一个 descender
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

	// 线性逼近：悬停/按下这类过渡都用它，比起 Tween 更适合每帧算的小数值
	// 绝对时间轴的缓动：关后页按 endT 铺开各段
	const ease3 = (t: number, t0: number, dur: number): number => {
		const k = Math.min(1, Math.max(0, (t - t0) / dur));
		return 1 - Math.pow(1 - k, 3);
	};

	const approach = (v: number, target: number, step: number): number =>
		(v < target ? Math.min(target, v + step) : Math.max(target, v - step));

	const layer = Node();
	layer.size = Size(W, H);
	layer.anchor = Vec2(0, 0);
	layer.position = Vec2(0, 0);
	layer.addTo(parent);

	/* ══════════ drawPaper：纸底 ══════════
	   HTML 的 drawPaper 是「纸色 + 8px 半调网点 + 每 9px 一条的极淡横线」。
	   那层网点是「像纸」的关键，纯色块怎么调都不像 → 烘成整张图（不透明，2 倍超采样）。 */
	img(layer, 'Image/StartUI/lv2_paper.png', 0, 0, W, H);

	/* ══════════ drawCrenel：城头 72–170 ══════════ */
	img(layer, 'Image/StartUI/lv2_crenel.png', 0, CT_T, W, CT_B - CT_T);

	/* ══════════ drawGuard：寇（疑心越高越往左） ══════════ */
	const guard = img(layer, 'Image/StartUI/lv2_guard.png', 1058, CT_B - 4 - 114, 64, 114);

	/* ══════════ drawRoomWall：墙 + 木柱 + 墙裙 + 暗角 ══════════ */
	// 玩法层整体收进 playRoot：HTML 的 drawIntro 只画 crenel/guard/beam，
	// 剩下的墙、光柱、砻、谷筐在标题卡阶段压根不该出现（不然纸色洗不干净）。
	// 梁必须留在 playRoot 里——它在 HTML 里画在 roomWall 之后，得压住墙。
	const playRoot = Node();
	playRoot.size = Size(W, H);
	playRoot.anchor = Vec2(0, 0);
	playRoot.position = Vec2(0, 0);
	playRoot.addTo(layer);

	img(playRoot, 'Image/StartUI/lv2_wall.png', 0, RM_T, W, FOOT_B - RM_T);

	/* ══════════ drawBeam：檐下横梁 ══════════
	   y=140 h=30。城头是墙外的远墙、碾房墙是室内石灰墙，两种材质直接对接，
	   中间只压一条墨线会读成「两张纸拼在一起」——所以必须有这根梁。
	   梁影只落两侧的墙上（0–364 / 916–1280），光柱里不画影：
	   光里没有影，画了就把「一束光」变成「一根柱子」。 */
	block(playRoot, 0, 140, W, 30, C_BEAM);
	block(playRoot, 0, 141, W, 3, C_PAPER, 0.42);          // 上沿受光
	block(playRoot, 0, 149, W, 1.4, C_INK, 0.16);          // 两道木纹
	block(playRoot, 0, 157, W, 1.4, C_INK, 0.16);
	block(playRoot, 0, 168.4, W, 3.2, C_INK, 0.95);        // 下沿：整幅画的分界
	// 梁影：ink 0.24 → 0 的渐变，用 6 条横带近似
	for (let i = 0; i < 6; i++) {
		block(playRoot, 0, 170 + i * 9.67, LANE_X0, 9.67, C_INK, 0.24 * (1 - i / 6));
		block(playRoot, LANE_R, 170 + i * 9.67, W - LANE_R, 9.67, C_INK, 0.24 * (1 - i / 6));
	}

	/* ══════════ drawWallAndShafts：三道光柱 + 窗棂 ══════════
	   光柱是一整张烘好的图（168×538）：纸色实心 + 16 粒浮尘 + 两侧 2px 淡墨边。
	   HTML 的顶端不做渐变——梁把它截断了，渐入会读成「一根发光的柱子」。 */
	const SHAFT_H = JUDGE_Y + 6 - RM_T;                 // 538
	const shafts: Sprite.Type[] = [];
	const shaftDim: Sprite.Type[] = [];
	const idleTips: Label.Type[] = [];
	for (let i = 0; i < 3; i++) {
		const x = LANE_X0 + i * (LANE_W + LANE_GAP);
		shafts.push(img(playRoot, 'Image/StartUI/lv2_shaft.png', x, RM_T, LANE_W, SHAFT_H));
		// 闲置：压一层更淡的罩 + 两个字
		const dim = block(playRoot, x, RM_T, LANE_W, JUDGE_Y - RM_T, C_DEEP, 0.10);
		dim.visible = false;
		shaftDim.push(dim);
		const tip = label(playRoot, FONT_B, 12, Color(36, 73, 70, 87), LANE_CX[i] - 18, RM_T + 48 + 12, 0, 3);
		tip.text = '闲 置';
		tip.opacity = 0;
		idleTips.push(tip);
	}

	// 窗棂：缝里各立一根，三条光才读成三扇窗而不是一大片亮。
	// 第二道缝的中心 = 第二条轨的右边 + 半个缝（不是「轨距×2 + 半个缝」——
	// 那样算出 760，正好落进第三道光柱里 12px，跟光柱边线并成两条歪线）
	for (const cx of [LANE_X0 + LANE_W + LANE_GAP / 2, LANE_X0 + (LANE_W + LANE_GAP) * 2 - LANE_GAP / 2]) {
		block(playRoot, cx - 4, RM_T, 8, JUDGE_Y - RM_T + 4, C_MULLION);
		block(playRoot, cx - 4, RM_T, 1.6, JUDGE_Y - RM_T + 4, C_INK, 0.45);
		block(playRoot, cx + 3.2, RM_T, 1.6, JUDGE_Y - RM_T + 4, C_INK, 0.45);
	}

	/* ══════════ drawBaskets：右侧两只谷筐 ══════════
	   图 124×178，图内圆心在 (62,100)。 */
	img(playRoot, 'Image/StartUI/lv2_basket.png', 1050 - 62, 616 - 100, 124, 178);
	const BS = 46 / 58;
	img(playRoot, 'Image/StartUI/lv2_basket.png',
		1160 - 62 * BS, 628 - 100 * BS, 124 * BS, 178 * BS);

	/* ══════════ drawBase：台基 ══════════ */
	block(playRoot, 0, BASE_T, W, H - BASE_T, C_TRAY);
	block(playRoot, 0, BASE_T - 2, W, 4, C_INK, 0.95);      // 台沿：所有东西都落在这条线上
	for (let x = 26; x < W; x += 168) {
		block(playRoot, x, BASE_T + 12, 1.8, H - BASE_T - 12, C_INK, 0.09);
	}

	/* ══════════ drawBaseProps：台面糠袋 ══════════
	   图 112×102，图内 cx=56、baseY=88。 */
	const SACK_W = 112, SACK_H = 102, SACK_CX = 56, SACK_BY = 88;
	img(playRoot, 'Image/StartUI/lv2_sack.png', 118 - SACK_CX, 798 - SACK_BY, SACK_W, SACK_H);
	const SS = 82 / 104;
	img(playRoot, 'Image/StartUI/lv2_sack.png',
		248 - SACK_CX * SS, 798 - SACK_BY * SS, SACK_W * SS, SACK_H * SS);
	const SS2 = 96 / 104;
	img(playRoot, 'Image/StartUI/lv2_sack.png',
		1118 - SACK_CX * SS2, 798 - SACK_BY * SS2, SACK_W * SS2, SACK_H * SS2);

	/* ══════════ drawWangziWall + drawWangzi ══════════
	   她自带一圈纯白描边，压在暗墙上像一张发光贴纸。所以脚边那截墙刷白一档——
	   读作她站在刷过石灰的墙根前，白边就只剩一点。
	   右缘用渐变收掉，硬边方块会读成「贴了一张纸」。
	   16 段而不是 8 段：8 段时最外一段从 0.06 直接跳到 0，边界还是能看出一道竖线。 */
	for (let i = 0; i < 16; i++) {
		const bw = 21;
		// HTML 是一条三段渐变：0% → 0.50、74% → 0.44、100% → 0。
		// 拐点在 74%（249px），不是从头就开始掉——之前写成前 3 条恒定再线性归零，
		// 等于把 0.44 那个节点挪到了 63px，整条偏亮、右侧又衰得太快。
		const t = (i * bw + bw / 2) / 336;
		const al = t <= 0.74
			? 0.50 + (0.44 - 0.50) * (t / 0.74)
			: 0.44 * (1 - (t - 0.74) / 0.26);
		block(playRoot, i * bw, 316, bw + 0.5, FOOT_T - 316, C_PAPER2, Math.max(0, al));
	}
	block(playRoot, 0, 315, 292, 2.2, C_INK, 0.13);
	const wangzi = img(playRoot, 'Image/StartUI/face_smile.png', WZ_X, WZ_BOT - WZ_H, WZ_W, WZ_H);
	// 收束页换大笑：HTML 在收尾时把 faceCur 切成 'laugh'
	const wangziLaugh = img(playRoot, 'Image/StartUI/face_laugh.png', WZ_X, WZ_BOT - WZ_H, WZ_W, WZ_H);
	wangziLaugh.visible = false;

	/* ══════════ drawNotes：糠块（对象池） ══════════
	   图 168×30，块体 162×24 在左上角，右下 6px 是硬投影。 */
	const POOL = 18;
	// 三态：常态 sandD / 命中 mix(sandL,paper2,.6) / 漏击 mix(sandD,seam,.4)。
	// 每格三个 sprite 同位置叠着，按 result 只显示一个。
	const kangsN: Sprite.Type[] = [];
	const kangsH: Sprite.Type[] = [];
	const kangsM: Sprite.Type[] = [];
	for (let i = 0; i < POOL; i++) {
		const a = img(playRoot, 'Image/StartUI/lv2_kang.png', -400, -200, 168, 30); a.opacity = 0;
		const b = img(playRoot, 'Image/StartUI/lv2_kang_hit.png', -400, -200, 168, 30); b.opacity = 0;
		const c = img(playRoot, 'Image/StartUI/lv2_kang_miss.png', -400, -200, 168, 30); c.opacity = 0;
		kangsN.push(a); kangsH.push(b); kangsM.push(c);
	}

	/* ══════════ drawJudge：判定线 ══════════ */
	const judgeBand: Sprite.Type[] = [];
	const judgeLine: Sprite.Type[] = [];   // 收束页要一起藏掉
	for (let i = 0; i < 3; i++) {
		const x = LANE_X0 + i * (LANE_W + LANE_GAP);
		judgeLine.push(block(playRoot, x, JUDGE_Y - 5, LANE_W, 5, C_INK, 0.92));
		judgeLine.push(block(playRoot, x + LANE_W / 2 - 14, JUDGE_Y - 5, 28, 5, C_VERM));   // 砻口
		const band = block(playRoot, x, JUDGE_Y - 16, LANE_W, 12, C_VERM, 0);
		judgeBand.push(band);
	}

	/* ══════════ drawMills：三台砻 ══════════
	   方木框（触区）+ 硬投影 + 圆磨盘 + 砻眼 + 键帽。
	   圆盘两张图：常态 sandD、命中态 mix(sandD, paper, 0.78)。
	   Sprite.color 只能整体相乘（变暗），做不出「变亮」，所以命中必须换图。 */
	const MILL_Y = 706, MILL_H = 88, MILL_CY = MILL_Y + MILL_H / 2 - 1;
	const millFrames: Sprite.Type[] = [];
	const millKeys: Label.Type[] = [];
	const millDiscs: Sprite.Type[] = [];
	const millHis: Sprite.Type[] = [];
	const millIdles: Sprite.Type[] = [];
	const millHisIdle: Sprite.Type[] = [];
	const millEdges: Sprite.Type[] = [];
	const millMiss: Sprite.Type[] = [];   // 漏击时砻口的朱红条
	const millSparks: Sprite.Type[] = [];  // 命中时向外推的集中线
	for (let i = 0; i < 3; i++) {
		const x = LANE_X0 + i * (LANE_W + LANE_GAP);
		block(playRoot, x + 5, MILL_Y + 5, LANE_W, MILL_H, C_INK, 0.88);          // 硬投影 off=5
		millFrames.push(block(playRoot, x, MILL_Y, LANE_W, MILL_H, C_MILLBASE));
		// 墨框 2.6：HTML 是 strokeRect(x+1.3, y+1.3, w-2.6, h-2.6)，
		// 边框 alpha 跟着 idle 变（0.42 / 0.9）——框变淡是「这台没在响」的唯一提示
		millEdges.push(block(playRoot, x + 1.3, MILL_Y + 1.3, LANE_W - 2.6, 2.6, C_INK, 0.9));
		millEdges.push(block(playRoot, x + 1.3, MILL_Y + MILL_H - 3.9, LANE_W - 2.6, 2.6, C_INK, 0.9));
		millEdges.push(block(playRoot, x + 1.3, MILL_Y + 1.3, 2.6, MILL_H - 2.6, C_INK, 0.9));
		millEdges.push(block(playRoot, x + LANE_W - 3.9, MILL_Y + 1.3, 2.6, MILL_H - 2.6, C_INK, 0.9));
		// 四态：常态 / 闲置 / 命中（正常底）/ 命中（闲置底）。
		// HTML 的四个内圈参数都随 idle 变，单图 + color 相乘做不出来，只能拆图。
		const px36 = LANE_CX[i] - 36, py36 = MILL_CY - 36;
		const dn = img(playRoot, 'Image/StartUI/lv2_mill.png', px36, py36, 72, 72);
		const di = img(playRoot, 'Image/StartUI/lv2_mill_idle.png', px36, py36, 72, 72);
		const hn = img(playRoot, 'Image/StartUI/lv2_mill_hi.png', px36, py36, 72, 72);
		const hi2 = img(playRoot, 'Image/StartUI/lv2_mill_hi_idle.png', px36, py36, 72, 72);
		di.visible = false; hn.opacity = 0; hi2.opacity = 0;
		millDiscs.push(dn);
		millIdles.push(di);
		millHis.push(hn);
		millHisIdle.push(hi2);
		// 命中集中线：12 根 / 内 38 外 68，随 f 由内向外推
		// （HTML: speedLines(cx,cy,12,r+4,r+8+(1-f)*26, ink 0.5f, 2)）
		const sp12 = img(playRoot, 'Image/StartUI/lv2_spark12.png', px36 - 32, py36 - 32, 136, 136);
		sp12.opacity = 0;
		sp12.visible = false;
		millSparks.push(sp12);
		// 漏击：砻口压一道朱红（HTML: rect(x+4, baseY+baseH-9, LANE_W-8, 6) verm 0.62*miss）
		millMiss.push(block(playRoot, x + 4, MILL_Y + MILL_H - 9, LANE_W - 8, 6, C_VERM, 0));
		// HTML 是 11px / alpha 0.58，在 Dora 里小到完全看不见（染色测试确认是能画的），
		// 提一档到 14px / 0.72 保住可读性，位置仍贴框右下
		const kl = label(playRoot, FONT_B, 14, Color(36, 73, 70, 185), x + LANE_W - 18, MILL_Y + MILL_H - 12, 1, 1);
		kl.text = ['1', '2', '3'][i];
		millKeys.push(kl);
	}

	/* ══════════ drawHitFx：糠屑 ══════════
	   HTML 每次 6 粒、3~6px、带旋转、寿命 1 秒。 */
	const PART_N = 36;
	// 两层：外层墨边、内层纸色芯。HTML 是 fillRect + strokeRect(ink 0.5 / 1.2px)，
	// 只染色不描边的话，糠屑读起来像纸片而不是「带墨边的碎屑」
	const partSprites: Sprite.Type[] = [];
	const partFills: Sprite.Type[] = [];
	for (let i = 0; i < PART_N; i++) {
		const b = block(playRoot, 0, 0, 5.2, 5.2, C_INK);
		b.opacity = 0;
		partSprites.push(b);
		const f = block(playRoot, 0, 0, 4, 4, C_PAPER2);
		f.opacity = 0;
		partFills.push(f);
	}
	type Part = { x: number; y: number; vx: number; vy: number; s: number; r: number; life: number };
	const particles: Part[] = [];

	const spawnHitFx = (lane: number): void => {
		const cx = LANE_CX[lane], cy = JUDGE_Y - 8;
		for (let i = 0; i < 6; i++) {
			const a = -Math.PI / 2 + (i - 2.5) * 0.42 + (Math.random() - 0.5) * 0.3;
			particles.push({
				x: cx + (Math.random() - 0.5) * LANE_W * 0.6,
				y: cy,
				vx: Math.cos(a) * (60 + Math.random() * 90),
				vy: Math.sin(a) * (90 + Math.random() * 70),
				s: 3 + Math.random() * 3,
				r: Math.random() * Math.PI,
				life: 1,
			});
		}
		if (particles.length > PART_N) { particles.splice(0, particles.length - PART_N); }
	};

	/* ══════════ drawHUD ══════════ */
	const hudRoot = Node();
	hudRoot.size = Size(W, H);
	hudRoot.anchor = Vec2(0, 0);
	hudRoot.position = Vec2(0, 0);
	hudRoot.addTo(playRoot);

	block(hudRoot, 0, 0, W, HUD_H, C_PAPER);
	block(hudRoot, 0, 67.6, W, 3.4, C_INK, 0.95);        // inkLine(0, 69, ...) 3.4
	// 朱红印章 40,15,34
	block(hudRoot, 40, 15, 34, 34, C_VERM);
	block(hudRoot, 40.75, 15.75, 32.5, 1.5, C_INK, 0.55);
	block(hudRoot, 40.75, 47.75, 32.5, 1.5, C_INK, 0.55);
	block(hudRoot, 40.75, 15.75, 1.5, 32.5, C_INK, 0.55);
	block(hudRoot, 72.75, 15.75, 1.5, 32.5, C_INK, 0.55);
	const sealLb = label(hudRoot, FONT_B, 19, C_PAPER2, 57, 40, 0.5, 0);
	sealLb.text = '贰';
	const nameLb = label(hudRoot, FONT_B, 24, C_INK, 86, 42, 0, 4);
	nameLb.text = '砻糠计';
	const subLb = label(hudRoot, FONT_R, 11, Color(36, 73, 70, 133), 88, 61, 0, 0.8);
	subLb.text = '永昌堡 · 嘉靖四十年 · 五月';

	// 四时辰进度：段宽按拍数分，不按等分——玩家看的是「还有多久天亮」
	const PB_X = 372, PB_Y = 26, PB_W = 452, PB_H = 9, PB_GAP = 6;
	const pbFill: Sprite.Type[] = [];
	const pbName: Label.Type[] = [];
	const pbTick: Sprite.Type[] = [];
	const pbEdge: Sprite.Type[] = [];
	let px = PB_X;
	for (let i = 0; i < SEGS.length; i++) {
		const seg = SEGS[i];
		const share = (seg.to - seg.from) / TOTAL_BEATS;
		const w = (PB_W - PB_GAP * 3) * share;
		block(hudRoot, px, PB_Y, w, PB_H, C_PAPER2);
		// strokeRect(px+0.8, PB_Y+0.8, w-1.6, PB_H-1.6)，线宽 1.6
		pbEdge.push(block(hudRoot, px + 0.8, PB_Y + 0.8, w - 1.6, 1.6, C_INK, 0.34));
		pbEdge.push(block(hudRoot, px + 0.8, PB_Y + PB_H - 2.4, w - 1.6, 1.6, C_INK, 0.34));
		pbEdge.push(block(hudRoot, px + 0.8, PB_Y + 0.8, 1.6, PB_H - 1.6, C_INK, 0.34));
		pbEdge.push(block(hudRoot, px + w - 2.4, PB_Y + 0.8, 1.6, PB_H - 1.6, C_INK, 0.34));
		pbFill.push(block(hudRoot, px + 1.6, PB_Y + 1.6, 1, PB_H - 3.2, C_VERM));
		const nm = label(hudRoot, FONT_R, 11.5, Color(36, 73, 70, 102), px, PB_Y + 28, 0, 1.4);
		nm.text = seg.name;
		pbName.push(nm);
		// 当前段：字下面一道朱红短线
		const tk = block(hudRoot, px, PB_Y + 33, 26, 2, C_VERM);
		tk.visible = false;
		pbTick.push(tk);
		px += w + PB_GAP;
	}

	// 疑心：纸底 + 墨框 + 四档刻度
	const SX = 862, SY = 26, SW = 272, SH = 9;
	const susLabel = label(hudRoot, FONT_B, 11.5, Color(36, 73, 70, 140), SX, SY + 28, 0, 1.4);
	susLabel.text = '疑心';
	const SBOX = SX + 40, SBW = SW - 40;
	block(hudRoot, SBOX, SY, SBW, SH, C_PAPER2);
	block(hudRoot, SBOX + 0.9, SY + 0.9, SBW - 1.8, 1.8, C_INK, 0.8);
	block(hudRoot, SBOX + 0.9, SY + SH - 2.7, SBW - 1.8, 1.8, C_INK, 0.8);
	block(hudRoot, SBOX + 0.9, SY + 0.9, 1.8, SH - 1.8, C_INK, 0.8);
	block(hudRoot, SBOX + SBW - 2.7, SY + 0.9, 1.8, SH - 1.8, C_INK, 0.8);
	const susFill = block(hudRoot, SBOX + 2, SY + 2, 1, SH - 4, C_INK, 0.70);
	for (let k = 1; k < 4; k++) {
		block(hudRoot, SBOX + SBW * k / 4, SY - 2, 1.6, SH + 4, C_INK, 0.55);
	}
	const susTip = label(hudRoot, FONT_B, 11, Color(36, 73, 70, 97), SX + SW, SY + 28, 1, 0.8);
	susTip.text = '难度 1/4';

	// 齿轮设置钮 1192,14,44
	block(hudRoot, 1192, 14, 44, 44, C_INK, 0.04);
	block(hudRoot, 1192.5, 14.5, 43, 1.6, C_INK, 0.55);
	block(hudRoot, 1192.5, 56.5, 43, 1.6, C_INK, 0.55);
	block(hudRoot, 1192.5, 14.5, 1.6, 43, C_INK, 0.55);
	block(hudRoot, 1234.5, 14.5, 1.6, 43, C_INK, 0.55);
	img(hudRoot, 'Image/StartUI/lv2_gear.png', 1192, 14, 44, 44);

	/* ══════════ 段落牌 / 漏击牌 ══════════
	   HTML：banner 300×54 @ y=92（投影 7、朱红竖条、四角准星、字距 7）
	         knock  404×52 @ y=86（投影 6、朱红框、四角准星、两端朱红短线） */
	const plateRoot = Node();
	plateRoot.size = Size(W, H);
	plateRoot.anchor = Vec2(0, 0);
	plateRoot.position = Vec2(0, 0);
	plateRoot.addTo(playRoot);

	// 段落牌背后的集中线：只出现在牌弹出那一瞬，不常驻。
	// HTML: speedLines(W/2, y+27, 22, 186, 232, ink 0.16, 2)，中心在 (640, 119)
	const bannerSpark = img(plateRoot, 'Image/StartUI/lv2_spark22.png', 640 - 232, 119 - 232, 464, 464);
	bannerSpark.opacity = 0;

	/* ══════════ 暂停页 ══════════
	   HTML：deep 0.55 遮罩 + 300×132 纸牌（投影 9）+ 「暂 停」34px + 「按 P 继续」13px */
	const pauseRoot = Node();
	pauseRoot.size = Size(W, H);
	pauseRoot.anchor = Vec2(0, 0);
	pauseRoot.position = Vec2(0, 0);
	pauseRoot.visible = false;
	pauseRoot.addTo(layer);

	block(pauseRoot, 0, 0, W, H, C_DEEP, 0.55);
	block(pauseRoot, W / 2 - 150 + 9, H / 2 - 66 + 9, 300, 132, C_INK, 0.88);   // 硬投影 off=9
	block(pauseRoot, W / 2 - 150, H / 2 - 66, 300, 132, C_PAPER2);
	block(pauseRoot, W / 2 - 150, H / 2 - 66, 300, 3, C_INK, 0.95);
	block(pauseRoot, W / 2 - 150, H / 2 + 63, 300, 3, C_INK, 0.95);
	block(pauseRoot, W / 2 - 150, H / 2 - 66, 3, 132, C_INK, 0.95);
	block(pauseRoot, W / 2 + 147, H / 2 - 66, 3, 132, C_INK, 0.95);
	// 34px 在 Dora 里只有 ~22px 宽/字，按 1.35 补到接近 HTML 的视觉大小
	const pauseT = label(pauseRoot, FONT_B, 46, C_INK, W / 2, H / 2 + 4, 0.5, 8);
	pauseT.text = '暂 停';
	const pauseTip = label(pauseRoot, FONT_R, 13, Color(36, 73, 70, 140), W / 2, H / 2 + 34, 0.5, 2);
	pauseTip.text = '按 P 继续';

	/* ══════════ 设置面板 ══════════
	   HTML 的 SET_BTN {1192,14,44}、SET_PANEL {248,204,pad22}。
	   面板挂在齿轮正下方：px = 1192+44-248 = 988，py = 14+44+10 = 68。
	   设置压在所有东西上面，连暂停遮罩也盖住。 */
	const SET_X = 988, SET_Y = 68, SET_W = 248, SET_H = 204;
	const PAD = 22, IX = SET_X + PAD, IW = SET_W - PAD * 2;
	const setRoot = Node();
	setRoot.size = Size(W, H);
	setRoot.anchor = Vec2(0, 0);
	setRoot.position = Vec2(0, 0);
	setRoot.visible = false;
	setRoot.addTo(layer);

	// 面板的硬投影没做：HTML 是 rgba(deep,0.12) 的圆角块，这里只能画直角块，
	// 圆角处会露出四个方角，比不画更难看
	img(setRoot, 'Image/StartUI/lv2_panel.png', SET_X, SET_Y, SET_W, SET_H);

	let audioBgm = 0.7, audioSfx = 0.8;

	const setLb1 = label(setRoot, FONT_R, 15, Color(36, 73, 70, 230), IX, SET_Y + 30, 0, 0.8);
	setLb1.text = '背景音乐';
	const setVal1 = label(setRoot, FONT_R, 14, Color(90, 121, 104, 242), IX + IW, SET_Y + 30, 1, 0.6);
	const setLb2 = label(setRoot, FONT_R, 15, Color(36, 73, 70, 230), IX, SET_Y + 96, 0, 0.8);
	setLb2.text = '音效';
	const setVal2 = label(setRoot, FONT_R, 14, Color(90, 121, 104, 242), IX + IW, SET_Y + 96, 1, 0.6);

	// 滑杆：6px 槽 + 填充 + 10×18 手柄（带 ink 边框）
	const bar1 = block(setRoot, IX, SET_Y + 46, IW, 6, C_INK, 0.14);
	const fill1 = block(setRoot, IX, SET_Y + 46, IW * audioBgm, 6, C_TEAL);
	const knob1 = block(setRoot, IX + IW * audioBgm - 5, SET_Y + 40, 10, 18, C_PAPER2);
	const bar2 = block(setRoot, IX, SET_Y + 112, IW, 6, C_INK, 0.14);
	const fill2 = block(setRoot, IX, SET_Y + 112, IW * audioSfx, 6, C_TEAL);
	const knob2 = block(setRoot, IX + IW * audioSfx - 5, SET_Y + 106, 10, 18, C_PAPER2);
	const knobEdges: Sprite.Type[] = [];
	for (let i = 0; i < 2; i++) {
		const ky = i === 0 ? SET_Y + 40 : SET_Y + 106;
		knobEdges.push(block(setRoot, 0, ky, 10, 1.6, C_INK));
		knobEdges.push(block(setRoot, 0, ky + 16.4, 10, 1.6, C_INK));
		knobEdges.push(block(setRoot, 0, ky, 1.6, 18, C_INK));
		knobEdges.push(block(setRoot, 8.4, ky, 1.6, 18, C_INK));
	}

	block(setRoot, IX, SET_Y + 140, IW, 1, C_INK, 0.12);

	// 「返回主菜单」：strokeRect + 居中文字
	block(setRoot, IX + 0.8, SET_Y + 152.8, IW - 1.6, 1.6, C_INK, 0.7);
	block(setRoot, IX + 0.8, SET_Y + 186.4, IW - 1.6, 1.6, C_INK, 0.7);
	block(setRoot, IX + 0.8, SET_Y + 152.8, 1.6, 35.2, C_INK, 0.7);
	block(setRoot, IX + IW - 2.4, SET_Y + 152.8, 1.6, 35.2, C_INK, 0.7);
	const setQuit = label(setRoot, FONT_R, 16, Color(36, 73, 70, 224), IX + IW / 2, SET_Y + 178, 0.5, 2.4);
	setQuit.text = '返回主菜单';

	const syncSet = (): void => {
		fill1.size = Size(Math.max(1, IW * audioBgm), 6);
		fill1.anchor = Vec2(0, 1);
		knob1.position = Vec2(IX + IW * audioBgm - 5, H - (SET_Y + 40));
		fill2.size = Size(Math.max(1, IW * audioSfx), 6);
		fill2.anchor = Vec2(0, 1);
		knob2.position = Vec2(IX + IW * audioSfx - 5, H - (SET_Y + 106));
		for (let i = 0; i < 2; i++) {
			const kx = i === 0 ? IX + IW * audioBgm - 5 : IX + IW * audioSfx - 5;
			const ky = i === 0 ? SET_Y + 40 : SET_Y + 106;
			knobEdges[i * 4].position = Vec2(kx, H - ky);
			knobEdges[i * 4 + 1].position = Vec2(kx, H - (ky + 16.4));
			knobEdges[i * 4 + 2].position = Vec2(kx, H - ky);
			knobEdges[i * 4 + 3].position = Vec2(kx + 8.4, H - ky);
		}
		setVal1.text = Math.round(audioBgm * 100).toString();
		setVal2.text = Math.round(audioSfx * 100).toString();
		// 引擎只有 Audio.globalVolume 一个总音量，没有分轨：
		// 让「音效」滑杆驱动总音量（玩法里音效占大头），「背景音乐」暂时只存值
		Audio.globalVolume = audioSfx;
	};
	syncSet();

	type PPart = { s: Sprite.Type; rx: number; ry: number };
	type Plate = {
		root: Node.Type; place: (by: number) => void; t1: Label.Type; t2: Label.Type;
	};

	const mkPlate = (
		w: number, h: number, off: number, edge: Color.Type, edgeA: number,
		lw: number, cornerLen: number, cornerPad: number, cornerA: number,
		cornerColor: Color.Type,
		fs1: number, ls1: number, ls2: number,
	): Plate => {
		const root = Node();
		root.size = Size(W, H);
		root.anchor = Vec2(0, 0);
		root.position = Vec2(0, 0);
		root.opacity = 0;
		root.visible = false;
		root.addTo(plateRoot);

		const x = (W - w) / 2;
		const pp: PPart[] = [];
		const add = (s: Sprite.Type, rx: number, ry: number): void => {
			pp.push({ s: s, rx: rx, ry: ry });
		};

		add(block(root, 0, 0, w, h, C_INK, 0.88), off, off);          // 硬投影
		add(block(root, 0, 0, w, h, C_PAPER2), 0, 0);                 // 纸底
		// strokeRect(x+lw/2, y+lw/2, w-lw, h-lw)
		add(block(root, 0, 0, w - lw, lw, edge, edgeA), lw / 2, lw / 2);
		add(block(root, 0, 0, w - lw, lw, edge, edgeA), lw / 2, h - lw * 1.5);
		add(block(root, 0, 0, lw, h - lw, edge, edgeA), lw / 2, lw / 2);
		add(block(root, 0, 0, lw, h - lw, edge, edgeA), w - lw * 1.5, lw / 2);

		// 四角准星
		const cx0 = cornerPad, cy0 = cornerPad;
		const cw = w - cornerPad * 2, ch = h - cornerPad * 2;
		const cl = cornerLen, cw2 = lw;
		add(block(root, 0, 0, cl, cw2, cornerColor, cornerA), cx0, cy0);
		add(block(root, 0, 0, cw2, cl, cornerColor, cornerA), cx0, cy0);
		add(block(root, 0, 0, cl, cw2, cornerColor, cornerA), cx0 + cw - cl, cy0);
		add(block(root, 0, 0, cw2, cl, cornerColor, cornerA), cx0 + cw - cw2, cy0);
		add(block(root, 0, 0, cl, cw2, cornerColor, cornerA), cx0, cy0 + ch - cw2);
		add(block(root, 0, 0, cw2, cl, cornerColor, cornerA), cx0, cy0 + ch - cl);
		add(block(root, 0, 0, cl, cw2, cornerColor, cornerA), cx0 + cw - cl, cy0 + ch - cw2);
		add(block(root, 0, 0, cw2, cl, cornerColor, cornerA), cx0 + cw - cw2, cy0 + ch - cl);

		const t1 = label(root, FONT_B, fs1, C_INK, 0, 0, 0.5, ls1);
		const t2 = label(root, FONT_B, 11, C_VERM, 0, 0, 0.5, ls2);

		// TSTL 坑：对象字面量里直接 `place: place` 会被当成方法转换，报
		// "Unable to convert function with no 'this' parameter"——必须包一层箭头函数
		const placeAt = (by: number): void => {
			for (const p of pp) {
				p.s.position = Vec2(x + p.rx, H - (by + p.ry));
			}
		};
		return {
			root: root,
			place: (by: number): void => { placeAt(by); },
			t1: t1,
			t2: t2,
		};
	};

	const banner = mkPlate(300, 54, 7, C_INK, 0.95, 3, 10, 4, 0.5, C_INK, 19, 7, 2.4);
	const knock = mkPlate(404, 52, 6, C_VERM, 0.85, 3, 11, 5, 0.55, C_VERM, 16, 1, 0.8);
	banner.t1.color = C_INK;
	knock.t1.text = '墙外传来一声闷响。他在试。';
	knock.t2.text = '他盯得更紧了 —— 判定变窄';

	// 段落牌左侧朱红竖条（HTML: x+12, y+12, 4, h-24）
	const bannerTick = block(plateRoot, 0, 0, 4, 54 - 24, C_VERM);
	bannerTick.visible = false;
	// 漏击牌两端各点三下朱红短线
	const knockTicks: Sprite.Type[] = [];
	for (let i = 0; i < 6; i++) {
		const s = block(plateRoot, 0, 0, 14, 2.2, C_VERM, 0.30);
		s.visible = false;
		knockTicks.push(s);
	}

	/* ══════════ 状态 ══════════ */
	let elapsed = 0;
	let state = 0;            // 0 入场 / 1 对局 / 2 收束
	let suspicion = 0;
	let combo = 0, maxCombo = 0, diff = 0;
	let hits = 0, misses = 0, goods = 0;
	let suspPeak = 0;      // 关后页要展示的最高疑心
	const flash = [0, 0, 0];
	const laneMiss = [0, 0, 0];
	let segIdx = -1, segStart = -99, knockT = 0;
	let finished = false;
	let startBeat = 0;

	let seed = 20261122;
	const rnd = (): number => {
		seed = (seed * 1103515245 + 12345) & 0x7fffffff;
		return seed / 0x7fffffff;
	};
	const rndInt = (n: number): number => Math.floor(rnd() * n);

	const buildChart = (): Note[] => {
		seed = 20261122;
		const out: { b: number; lane: number }[] = [];

		// 谱面按 BGM 的鼓点重排过（原型的谱面和成品音乐前两段对不上：戌时 4/12、子时 16/32）。
		// 音乐的密度递进本身就是 8→16→32→50，正好对应「一更慢、五更快」，
		// 所以是谱面跟着音乐走，不是反过来。
		//
		// 戌时：音乐每 3 拍一个低音（0,3,6…21）。跳过 b=0——那声是起势，
		// 而且 t=0 的音符要求糠块在 -2.05 秒就出现，比 PREROLL(-1.4) 还早，会凭空悬在半空
		for (let b = 3; b < 24; b += 3) { out.push({ b: b, lane: 1 }); }

		// 子时：音乐每 2 拍、中/左交替（24 中、26 左、28 中…），52 是右、54 是左
		for (let b = 24; b < 52; b += 2) {
			out.push({ b: b, lane: ((b - 24) % 4 === 0) ? 1 : 0 });
		}
		out.push({ b: 52, lane: 1 });   // 原来写 lane 2，但子时 SEGS 只有 [0,1]，闲置轨不能出方块
		out.push({ b: 54, lane: 0 });

		let prev = 1, run = 0;
		for (let b = 56; b < 88; b++) {
			let lane = 1, gd = 0;
			do {
				const r = rnd();
				lane = r < 0.40 ? 1 : (r < 0.70 ? 0 : 2);
				gd++;
			} while (lane === prev && run >= 1 && gd < 12);
			run = (lane === prev) ? run + 1 : 0;
			prev = lane;
			out.push({ b: b, lane: lane });
		}

		prev = 1; run = 0;
		for (let b = 88; b < 128; b++) {
			let lane = 1, gd = 0;
			do {
				const r = rnd();
				lane = r < 0.36 ? 1 : (r < 0.68 ? 0 : 2);
				gd++;
			} while (lane === prev && run >= 1 && gd < 12);
			run = (lane === prev) ? run + 1 : 0;
			prev = lane;
			out.push({ b: b, lane: lane });

			// 音乐的小鼓加花落在 88.5 / 92.5 / 96.5…（每 4 拍的后半拍），
			// 原来是 91.5/95.5 那种错开 3 拍的位置
			if ((b - 88) % 4 === 0) {
				let l2 = 0;
				do { l2 = rndInt(3); } while (l2 === lane);
				out.push({ b: b + 0.5, lane: l2 });
			}
		}

		out.sort((a, b) => a.b - b.b);
		const ns: Note[] = [];
		for (const n of out) {
			ns.push({ t: n.b * SPB, lane: n.lane, judged: false, result: 0, fx: 0 });
		}
		return ns;
	};

	let notes: Note[] = [];

	const winNow = (): number => WIN_BASE * WIN_MUL[diff];

	const checkKnock = (): void => {
		if (suspicion < 100) { return; }
		suspicion = 55;
		diff = Math.min(3, diff + 1);
		knockT = 2.2;
	};

	const hit = (lane: number): void => {
		if (state === 0) { beginPlay(); return; }
		if (state !== 1) { return; }
		const t = elapsed;
		const win = winNow();

		let best: Note | undefined = undefined;
		let bd = 1e9;
		for (const n of notes) {
			if (n.judged || n.lane !== lane) { continue; }
			const dt = t - n.t;
			if (dt < -win || dt > win) { continue; }
			const ad = Math.abs(dt);
			if (ad < bd) { bd = ad; best = n; }
		}

		if (best === undefined) {
			flash[lane] = 0.6;     // 空响也闪一下：不然按了没判定，会以为键盘没反应
			Audio.play(THUD[lane]);
			return;
		}

		best.judged = true;
		best.fx = 1;
		flash[lane] = 1;
		Audio.play(THUD[lane]);
		spawnHitFx(lane);

		if (bd <= win * 0.5) {
			best.result = 1;
			hits++;
			combo++;
			if (combo > maxCombo) { maxCombo = combo; }
			if (combo % 6 === 0) { suspicion = Math.max(0, suspicion - 2); }
		} else {
			best.result = 2;
			goods++;
			combo = 0;
			suspicion = Math.min(100, suspicion + 2);
		}
		checkKnock();
	};

	/* ══════════ update ══════════ */
	let endT = 0;
	let bgmOn = false;
	let introT = 0;
	let paused = false;
	let showSet = false;
	// 指针位置与按下状态：标题卡按钮的悬停/按下动效要用
	let ptrX = -999, ptrY = -999, ptrDown = false;
	let btnHov = 0, btnPrs = 0;

	const update = (dt: number): void => {
		if (state === 0) { syncIntro(dt); return; }
		if (state === 2) {
			endT += dt;
			syncEnd();
			return;
		}
		if (paused) { return; }   // 暂停：时钟不动，谱面不会偷偷往前走
		elapsed += dt;

		// 音乐等到第 0 拍才起：前面 1.4 秒是准备时间
		if (!bgmOn && elapsed >= 0) {
			bgmOn = true;
			// Audio.play 只吃 WAV（文档原文：filename must be a WAV file），
			// BGM 是 .ogg，必须走 playStream，否则根本不出声
			Audio.playStream(BGM, true, 0);
		}

		for (let i = 0; i < 3; i++) {
			flash[i] = Math.max(0, flash[i] - dt * 7);
			laneMiss[i] = Math.max(0, laneMiss[i] - dt * 2.2);
		}
		knockT = Math.max(0, knockT - dt);

		for (let i = particles.length - 1; i >= 0; i--) {
			const p = particles[i];
			// 照 HTML：寿命 step 是 dt*1.6（≈0.63 秒），重力 620，还要自转
			p.life -= dt * 1.6;
			if (p.life <= 0) { particles.splice(i, 1); continue; }
			p.x += p.vx * dt;
			p.y += p.vy * dt;
			p.vy += 620 * dt;
			p.r += dt * 6;
		}
		// 糠块的淡出不分命中/漏击，统一 dt*5
		for (const n of notes) {
			if (n.fx <= 0) { continue; }
			n.fx = Math.max(0, n.fx - dt * 5);
		}

		if (state !== 1) { return; }

		// 漏判
		for (const n of notes) {
			if (n.judged) { continue; }
			if (elapsed - n.t > winNow()) {
				n.judged = true;
				n.result = 3;
				n.fx = 1;
				misses++;
				combo = 0;
				suspicion = Math.min(100, suspicion + 7);
				laneMiss[n.lane] = 1;
				Audio.play(MISS_SFX);
				checkKnock();
			}
		}

		// 段落
		// 拍号就是 elapsed 换算过来的，别再叠加 startBeat：
		// immediate 时 elapsed 已经等于 startBeat*SPB，再叠加会让第 48 拍落到第 96 拍，
		// 截图对帧时两边根本不在同一段
		// 疑心峰值：关后页要报「最高到多少」，随手在每帧记一下
		if (suspicion > suspPeak) { suspPeak = suspicion; }

		const b = elapsed / SPB;
		let idx = 0;
		for (let i = 0; i < SEGS.length; i++) { if (b >= SEGS[i].from) { idx = i; } }
		if (b >= 0 && idx !== segIdx) { segIdx = idx; segStart = elapsed; }

		if (b >= TOTAL_BEATS + 1.2) {
			state = 2;
			// 收束：立绘换大笑、判定线一起收掉（HTML 的 end 不画 notes/judge/HUD）
			wangzi.visible = false;
			wangziLaugh.visible = true;
			// 关后页立绘在右侧（和关前页同一位置），不挪的话会压在统计文字上
			wangziLaugh.size = Size(300, 400);
			wangziLaugh.anchor = Vec2(0, 1);
			wangziLaugh.position = Vec2(856, H - 350);
			for (const jl of judgeLine) { jl.visible = false; }
			hudRoot.visible = false;
			plateRoot.visible = false;
			endRoot.visible = true;
			elapsed = 0;
			endT = 0;
			syncEnd();
		}
	};

	/* ══════════ draw ══════════ */
	const draw = (): void => {
		if (state === 0) { return; }

		// 光柱：闲置段整张压暗 + 罩一层 deep。图是烘死的实色，只能靠 opacity 压
		const cur = segIdx >= 0 ? SEGS[segIdx] : undefined;
		for (let i = 0; i < 3; i++) {
			const idle = cur !== undefined && cur.lanes.indexOf(i) < 0;
			shafts[i].opacity = idle ? 0.45 : 1;
			shaftDim[i].visible = idle;
			idleTips[i].opacity = idle ? 1 : 0;
		}

		// 判定带：漏击时该轨压深
		for (let i = 0; i < 3; i++) {
			judgeBand[i].opacity = 0.30 * laneMiss[i];
		}

		// 糠块
		let k = 0;
		for (const n of notes) {
			if (k >= POOL) { break; }
			if (n.result === -1) { continue; }
			if (n.result === 3 && n.fx <= 0) { continue; }
			const y = JUDGE_Y - (n.t - elapsed) * PX_PER_SEC;
			if (y < RM_T - 34 || y > JUDGE_Y + 34) { continue; }

			const idx = k; k++;
			const x = LANE_X0 + n.lane * (LANE_W + LANE_GAP) + 3;
			let dy = 0, alpha = 1;
			const isHit = n.result === 1 || n.result === 2;
			const isMiss = n.result === 3;
			if (isHit) {
				alpha = n.fx;
			} else if (isMiss) {
				alpha = n.fx * 0.6;
				dy = (1 - n.fx) * 18;     // 漏掉的块往下沉一格，不是原地消失
			}
			// 三态只切图，位置/淡出一样：先把这一格的三个都隐掉，再点亮该用的那个
			const s = isHit ? kangsH[idx] : (isMiss ? kangsM[idx] : kangsN[idx]);
			kangsN[idx].opacity = 0;
			kangsH[idx].opacity = 0;
			kangsM[idx].opacity = 0;
			s.position = Vec2(x, H - (y - 12 + dy));
			s.opacity = alpha;
		}
		for (; k < POOL; k++) {
			kangsN[k].opacity = 0;
			kangsH[k].opacity = 0;
			kangsM[k].opacity = 0;
		}

		// 砻：命中时换高亮图（Sprite.color 只能变暗，做不出变亮），闲置时压暗。
		// 关键：闲置的轨道也必须闪——戌时只有中轨有音符，按 1/3 一定空响，
		// 要是高亮也被 idle 关掉，玩家会觉得「按了没反应」
		const curSeg = segIdx >= 0 ? SEGS[segIdx] : undefined;
		for (let i = 0; i < 3; i++) {
			const idle = curSeg !== undefined && curSeg.lanes.indexOf(i) < 0;
			const f = flash[i];
			const hit = f > 0.02;
			// 四态切图：闲置态的内圈/分界/砻眼本来就该更淡，不是整张压暗
			millDiscs[i].visible = !idle && !hit;
			millIdles[i].visible = idle && !hit;
			millHis[i].visible = !idle && hit;
			millHis[i].opacity = f;
			millHisIdle[i].visible = idle && hit;
			millHisIdle[i].opacity = f;
			// 集中线：外径从 42 推到 68（scale 0.62→1.0），亮度 0.5f
			const sk = millSparks[i];
			if (f > 0.06) {
				const kk = 0.62 + 0.38 * (1 - f);
				sk.visible = true;
				sk.opacity = 0.5 * f;
				sk.size = Size(136 * kk, 136 * kk);
				sk.anchor = Vec2(0.5, 0.5);
				sk.position = Vec2(LANE_CX[i], H - MILL_CY);
			} else {
				sk.visible = false;
			}
			const ea = idle ? 0.42 : 0.9;
			const ebase = i * 4;
			millEdges[ebase].opacity = ea;
			millEdges[ebase + 1].opacity = ea;
			millEdges[ebase + 2].opacity = ea;
			millEdges[ebase + 3].opacity = ea;
			millKeys[i].color = idle ? Color(36, 73, 70, 77) : Color(36, 73, 70, 148);
			millMiss[i].opacity = 0.62 * laneMiss[i];
		}

		// 糠屑
		for (let i = 0; i < PART_N; i++) {
			const sp = partSprites[i];
			const fl = partFills[i];
			const p = i < particles.length ? particles[i] : undefined;
			if (p === undefined) { sp.opacity = 0; fl.opacity = 0; continue; }
			const pa = Math.min(1, p.life);
			// 墨边比芯大 1.2px（strokeRect 两边各 0.6），两层同中心同角度
			sp.size = Size(p.s + 1.2, p.s + 1.2);
			sp.anchor = Vec2(0.5, 0.5);
			sp.position = Vec2(p.x, H - p.y);
			sp.angle = p.r * 57.29578;
			sp.opacity = 0.5 * pa;
			fl.size = Size(p.s, p.s);
			fl.anchor = Vec2(0.5, 0.5);
			fl.position = Vec2(p.x, H - p.y);
			fl.angle = p.r * 57.29578;
			fl.opacity = pa;
		}

		// 寇：疑心越高越往左靠。y 是「图顶边」，所以要把图高也减掉——
		// 之前只写了 H-(CT_B-4)，等于把底边当顶边，整个人被推到梁下面的墙里，直接看不见
		guard.position = Vec2(1058 + suspicion * 0.34, H - (CT_B - 4 - 114));

		// HUD：四时辰
		for (let i = 0; i < SEGS.length; i++) {
			const seg = SEGS[i];
			const share = (seg.to - seg.from) / TOTAL_BEATS;
			const w = (PB_W - PB_GAP * 3) * share;
			const t0 = seg.from * SPB, t1 = seg.to * SPB;
			const tt = Math.max(0, elapsed);
			const p = Math.max(0, Math.min(1, (tt - t0) / (t1 - t0)));
			const active = (i === segIdx);

			pbFill[i].size = Size(Math.max(1, (w - 3.2) * p), PB_H - 3.2);
			pbFill[i].anchor = Vec2(0, 1);
			pbFill[i].color = active ? C_VERM : Color(36, 73, 70, 158);
			pbName[i].color = active ? Color(36, 73, 70, 242) : Color(36, 73, 70, 102);
			const bi = i * 4;
			const ea = active ? 0.8 : 0.34;
			pbEdge[bi].opacity = ea;
			pbEdge[bi + 1].opacity = ea;
			pbEdge[bi + 2].opacity = ea;
			pbEdge[bi + 3].opacity = ea;
			pbTick[i].visible = active;
		}

		// HUD：疑心
		const sp2 = Math.min(1, suspicion / 100);
		const warn = sp2 > 0.75;
		susFill.size = Size(Math.max(1, (SBW - 4) * sp2), SH - 4);
		susFill.anchor = Vec2(0, 1);
		susFill.color = warn ? C_VERM : Color(36, 73, 70, 178);
		susTip.color = warn ? C_VERM : Color(36, 73, 70, 97);
		susTip.text = warn ? '他起疑了' : ('难度 ' + (diff + 1).toString() + '/4');

		// 段落牌
		const seg = SEGS[segIdx];
		if (seg !== undefined) {
			const el = elapsed - segStart;
			if (el >= 0 && el < 2.6) {
				const a = Math.min(1, el / 0.22) * Math.min(1, (2.6 - el) / 0.6);
				banner.root.visible = true;
				banner.root.opacity = a;
				banner.place(92);
				banner.t1.position = Vec2(W / 2 + 8, H - (92 + 25) + 19);
				banner.t1.text = seg.name;
				banner.t2.position = Vec2(W / 2 + 8, H - (92 + 43) + 11);
				banner.t2.text = seg.tag;
				bannerTick.visible = true;
				bannerTick.position = Vec2((W - 300) / 2 + 12, H - (92 + 12));
				bannerSpark.opacity = 0.16 * a;
			} else {
				banner.root.visible = false;
				bannerTick.visible = false;
				bannerSpark.opacity = 0;
			}
		} else {
			banner.root.visible = false;
			bannerTick.visible = false;
			bannerSpark.opacity = 0;
		}

		// 漏击牌：整块落在城头带里（86–138），压在梁以上
		if (knockT > 0) {
			const a = Math.min(1, knockT / 0.4);
			knock.root.visible = true;
			knock.root.opacity = a;
			knock.place(86);
			knock.t1.position = Vec2(W / 2, H - (86 + 23) + 16);
			knock.t2.position = Vec2(W / 2, H - (86 + 42) + 11);
			const kx = (W - 404) / 2;
			for (let i = 0; i < 3; i++) {
				const dy = (i - 1) * 12;
				const l = knockTicks[i * 2], r = knockTicks[i * 2 + 1];
				l.visible = true;
				l.position = Vec2(kx - 10 - 14, H - (86 + 26 + dy * 1.5));
				r.visible = true;
				r.position = Vec2(kx + 404 + 10, H - (86 + 26 + dy * 1.5));
			}
		} else {
			knock.root.visible = false;
			for (const s of knockTicks) { s.visible = false; }
		}

		// 两个浮层最后画：暂停遮罩在下、设置面板压在最上面（HTML 原话：「连暂停遮罩也盖住」）
		pauseRoot.visible = paused;
		setRoot.visible = showSet;
	};

	/* ══════════ 关前标题页 ══════════
	   HTML 的 drawIntro 是在整幅场景上再盖一层纸色渐变，不是另画一张图：
	   城头、寇、梁都还在，只是被 0.92~0.97 的纸色洗淡。 */
	const introRoot = Node();
	introRoot.size = Size(W, H);
	introRoot.anchor = Vec2(0, 0);
	introRoot.position = Vec2(0, 0);
	introRoot.addTo(layer);

	// 标题页也画梁：城头底下要有一条收边，否则那截墙像贴在纸上的纸条。
	// 但不要梁影——标题页梁下是纸，压一道影会像纸上沾了脏（HTML 的 drawBeam(false)）。
	block(introRoot, 0, 140, W, 30, C_BEAM);
	block(introRoot, 0, 141, W, 3, C_PAPER, 0.42);
	block(introRoot, 0, 149, W, 1.4, C_INK, 0.16);
	block(introRoot, 0, 157, W, 1.4, C_INK, 0.16);
	block(introRoot, 0, 168.4, W, 3.2, C_INK, 0.95);

	// 左侧纸色渐变：从 170 开始盖，盖到 72 会把垛口一起洗掉
	for (let i = 0; i < 10; i++) {
		const bw = 92;
		let al = 0;
		if (i < 6) { al = 0.97 - i * 0.0083; } else { al = 0.92 * (1 - (i - 5.8) / 4.2); }
		block(introRoot, i * bw, CT_B, bw + 0.5, H - CT_B, C_PAPER, Math.max(0, al));
	}

	// 集中线：40 根从标题左上方散开（HTML 的 speedLines(250,330,40,210,340)）。
	// 图是单独烘的 680×680，中心在图心，贴到 (250,330) 就是 x=-90 / y=-10
	const introBurst = img(introRoot, 'Image/StartUI/lv2_burst.png', 250 - 340, 330 - 340, 680, 680);
	introBurst.opacity = 0;

	// 立绘：从右侧滑进来站定，之后轻轻呼吸。
	// 脚下 ellipse(1060,712,96,13) 单独烘图——用横带拼会变成一道梯子
	const introShadow = img(introRoot, 'Image/StartUI/lv2_shadow.png', 1060 - 96, 712 - 13, 192, 26);
	introShadow.opacity = 0;
	const introWz = img(introRoot, 'Image/StartUI/face_smile.png', 918, 316, 286, 384);
	introWz.opacity = 0;

	// 印章「贰」112,196,38
	const introSeal = block(introRoot, 112, 196, 38, 38, C_VERM);
	introSeal.opacity = 0;
	const introSealLb = label(introRoot, FONT_B, 21, C_PAPER2, 131, 222, 0.5, 0);
	introSealLb.text = '贰';
	introSealLb.opacity = 0;
	const introQian = label(introRoot, FONT_B, 14, Color(36, 73, 70, 140), 162, 224, 0, 4);
	introQian.text = '关 前';
	introQian.opacity = 0;

	// 标题烘成图：Dora 的 Label 汉字只有 0.588em 宽，靠放字号补会把字形一起撑高；
	// canvas 的 82px 是精确值，字距也一并烘进去。图内基线在 y=105、字左起 x=10
	const introTitle = img(introRoot, 'Image/StartUI/lv2_title.png', 96, 342 - 105, 320, 130);
	introTitle.opacity = 0;

	const introRule = block(introRoot, 112, 366, 1, 4, C_VERM);

	const introL1 = label(introRoot, FONT_B, 22, Color(36, 73, 70, 219), 112, 434, 0, 1.4);
	introL1.text = '围城最怕的不是打，是饿。';
	introL1.opacity = 0;
	const introL2 = label(introRoot, FONT_B, 22, Color(36, 73, 70, 219), 112, 474, 0, 1.4);
	introL2.text = '粮吃完了，城自己就垮。';
	introL2.opacity = 0;

	const introSep = block(introRoot, 112, 515, 1, 2, C_INK, 0.32);

	const introH1 = label(introRoot, FONT_B, 13.5, Color(36, 73, 70, 158), 112, 558, 0, 1);
	introH1.text = '1　2　3　或者点下面三台砻';
	introH1.opacity = 0;
	const introH2 = label(introRoot, FONT_R, 13.5, Color(36, 73, 70, 158), 112, 586, 0, 0.6);
	introH2.text = '糠落到砻口时敲。漏一下，城外就听见里面停了。';
	introH2.opacity = 0;

	// 按钮 112,640,240×60：硬投影 + 纸底 + 朱红呼吸
	const introBtnShadow = block(introRoot, 120, 648, 240, 60, C_INK, 0);
	const introBtn = block(introRoot, 112, 640, 240, 60, C_PAPER2, 0);
	const introBtnTint = block(introRoot, 114, 642, 236, 56, C_VERM, 0);
	const introBtnEdge: Sprite.Type[] = [];
	introBtnEdge.push(block(introRoot, 113.5, 641.5, 237, 3, C_INK, 0));
	introBtnEdge.push(block(introRoot, 113.5, 696.5, 237, 3, C_INK, 0));
	introBtnEdge.push(block(introRoot, 113.5, 641.5, 3, 57, C_INK, 0));
	introBtnEdge.push(block(introRoot, 349.5, 641.5, 3, 57, C_INK, 0));
	const introBtnLb = label(introRoot, FONT_B, 21, C_INK, 232, 678, 0.5, 10);
	introBtnLb.text = '开 始';
	introBtnLb.opacity = 0;
	const introTip = label(introRoot, FONT_R, 13, Color(36, 73, 70, 133), 378, 677, 0, 1.6);
	introTip.text = '点任意处 / 空格 / 123';
	introTip.opacity = 0;

	const introHorizon = block(introRoot, 0, BASE_T - 1.5, W, 3, C_INK, 0);
	const introFoot = label(introRoot, FONT_R, 11, Color(36, 73, 70, 102), 112, 764, 0, 1.2);
	introFoot.text = '永昌堡 · 嘉靖四十年 · 五月';
	introFoot.opacity = 0;

	const syncIntro = (dt: number): void => {
		introT += dt;
		const ease = (t0: number, dur: number): number => {
			const k = Math.min(1, Math.max(0, (introT - t0) / dur));
			return 1 - Math.pow(1 - k, 3);
		};

		// 集中线：淡入后随呼吸极缓地转。0.06 而不是 HTML 的 0.11——
		// 烘出来的 burst 是方图，边缘那一圈线会齐刷刷断掉，压低才看不出接缝
		const aLines = ease(0.10, 0.75);
		introBurst.opacity = aLines * 0.95;
		introBurst.angle = Math.sin(introT * 0.35) * 0.7;

		// 立绘：从右侧滑进来站定，之后轻轻呼吸
		const aWz = ease(0.16, 0.72);
		const dx = (1 - aWz) * 48;
		const bob = Math.sin(introT * 1.45) * 2.2;
		introWz.position = Vec2(918 + dx, H - (316 + bob));
		introWz.opacity = 0.98 * aWz;
		introShadow.position = Vec2(1060 - 96 + dx, H - 712);
		introShadow.opacity = aWz;

		// 印章：从大到小砸下来
		const aSeal = ease(0.34, 0.28);
		const kSeal = 1 + 1.5 * (1 - aSeal);
		introSeal.opacity = aSeal;
		introSeal.size = Size(38 * kSeal, 38 * kSeal);
		introSeal.anchor = Vec2(0.5, 0.5);
		introSeal.position = Vec2(131, H - 215);
		introSealLb.opacity = aSeal;
		introQian.opacity = aSeal;

		// 标题：从右滑入
		const aTitle = ease(0.46, 0.55);
		introTitle.opacity = aTitle;
		introTitle.position = Vec2(96 + (1 - aTitle) * 44, H - (342 - 105));

		// 朱红横线：从左拉开
		const aRule = ease(0.74, 0.42);
		introRule.size = Size(Math.max(1, 128 * aRule), 4);
		introRule.anchor = Vec2(0, 1);

		// 两句：一行接一行往上浮
		const lineIn = (t0: number, lb: Label.Type, y: number): void => {
			const a = ease(t0, 0.5);
			lb.opacity = a;
			lb.position = Vec2(112, H - (y + (1 - a) * 12) + 22);
		};
		lineIn(0.88, introL1, 434);
		lineIn(1.02, introL2, 474);

		// 分隔线：从左长出来
		const aSep = ease(1.18, 0.42);
		introSep.size = Size(Math.max(1, 448 * aSep), 2);
		introSep.anchor = Vec2(0, 1);

		// 操作说明
		const aHint = ease(1.34, 0.5);
		introH1.opacity = aHint;
		introH2.opacity = aHint;

		// 按钮：弹进来，之后朱红底一直呼吸
		const aBtn = ease(1.52, 0.5);
		const pulse = 0.5 + 0.5 * Math.sin(introT * 2.3);
		const kBtn = 0.90 + 0.10 * aBtn;
		const bcx = 112 + 120, bcy = 640 + 30;
		// ── 按钮的悬停/按下：照主菜单的 mkButton 做法 ──
		// 投影固定不动，面板往右下推进，视觉上就是「阴影收窄 = 被按下去」。
		// 主菜单是 3*e 悬停 + 2*p 按下，这里照抄同样的手感。
		const inBtn = ptrX >= 112 && ptrX <= 352 && ptrY >= 640 && ptrY <= 700;
		btnHov = approach(btnHov, inBtn ? 1 : 0, dt * 8);
		btnPrs = approach(btnPrs, (inBtn && ptrDown) ? 1 : 0, dt * 14);
		const be = btnHov * btnHov * (3 - 2 * btnHov);
		const boff = 3 * be + 2 * btnPrs;
		const bdim = be * 0.55 + btnPrs * 0.35;

		const list = [introBtnShadow, introBtn, introBtnTint,
			introBtnEdge[0], introBtnEdge[1], introBtnEdge[2], introBtnEdge[3]];
		const sw = [240, 240, 236, 237, 237, 3, 3];
		const sh = [60, 60, 56, 3, 3, 57, 57];
		const ox = [8, 0, 2, 1.5, 1.5, 1.5, 237.5];
		const oy = [8, 0, 2, 1.5, 56.5, 1.5, 1.5];
		for (let i = 0; i < 7; i++) {
			const s = list[i];
			s.size = Size(sw[i] * kBtn, sh[i] * kBtn);
			s.anchor = Vec2(0, 1);
			// i===0 是投影，不跟着动
			const mv = i === 0 ? 0 : boff;
			s.position = Vec2(
				bcx - 120 * kBtn + ox[i] * kBtn + mv,
				H - (bcy - 30 * kBtn + oy[i] * kBtn - mv),
			);
			if (i === 2) {
				s.opacity = aBtn * (0.10 + 0.14 * pulse);
			} else {
				s.opacity = aBtn;
			}
		}
		// 纸底随悬停/按下压暗。主菜单是 mixColor(WHITE(255), C_DIM(206), 最多 0.9)，
		// 也就是只降 17%；这里按同样幅度往灰里拉，别压成灰褐
		introBtn.color = Color(
			Math.round(243 - bdim * 37), Math.round(234 - bdim * 31), Math.round(211 - bdim * 27), 255,
		);
		introBtnLb.opacity = aBtn;
		introBtnLb.position = Vec2(bcx + boff, H - 678 + 21 - boff);
		introTip.opacity = aBtn * 0.9;

		const aFoot = ease(1.75, 0.6);
		introHorizon.opacity = 0.55 * aFoot;
		introFoot.opacity = aFoot;
	};

	/* ══════════ 收束页 ══════════ */
	/* ══════════ 关后页 ══════════
	   版式对齐 02-可玩原型/lv2-关后页.html：
	   印章「胜」+ 关后 / 评级「甲」/ 标题 / 横线 / 台词 11 两行 / 分隔线 /
	   统计四行 / 台词 12 / 两个按钮 / 落款。
	   文案全部来自 01-设计文档/台词本.md 第二关 11–13，不要自己编。 */
	const endRoot = Node();
	endRoot.size = Size(W, H);
	endRoot.anchor = Vec2(0, 0);
	endRoot.position = Vec2(0, 0);
	endRoot.visible = false;
	endRoot.addTo(layer);

	// 天亮：整幅提亮，不是压暗。这一夜的结果是「骗成了」
	block(endRoot, 0, 0, W, H, Color(255, 248, 228, 255), 0.30);
	// 晨光：从左下斜着打进来（烘好的斜向 RGBA 渐变，ffmpeg geq 出的）
	img(endRoot, 'Image/StartUI/lv2_dawn.png', 0, 0, W, H);

	// 地平线属于场景，必须在按钮之前。放到后面画会横穿按钮
	// （按钮 660~720 正好压着 702 这条线），看着像按钮是半透明的
	block(endRoot, 0, BASE_T - 1.5, W, 3, C_INK, 0.55);

	// ── 印章「胜」+ 关后 ──
	const endSeal = block(endRoot, 112, 196, 38, 38, C_VERM);
	// 21px 在 Dora 里只有 ~13px，朱红底上几乎看不见；按「小字加 2~3px」的经验提到 28
	const endSealLb = label(endRoot, FONT_B, 28, C_PAPER2, 131, 215, 0.5, 0);
	endSealLb.text = '胜';
	const endTag = label(endRoot, FONT_B, 14, Color(36, 73, 70, 140), 162, 224, 0, 4);
	endTag.text = '关 后';

	// ── 评级「甲」：描边方印，和「关后」同一水平线 ──
	const GX = 538, GY = 190, GS = 44, GW = 2.6;
	const endGradeEdges: Sprite.Type[] = [
		block(endRoot, GX, GY, GS, GW, C_VERM),
		block(endRoot, GX, GY + GS - GW, GS, GW, C_VERM),
		block(endRoot, GX, GY, GW, GS, C_VERM),
		block(endRoot, GX + GS - GW, GY, GW, GS, C_VERM),
	];
	const endGradeLb = label(endRoot, FONT_B, 26, C_VERM, GX + GS / 2, GY + GS / 2 + 9, 0.5, 0);
	endGradeLb.text = '甲';
	const endGradeTip = label(endRoot, FONT_R, 10, Color(36, 73, 70, 115), GX + GS / 2, GY + 56, 0.5, 2);
	endGradeTip.text = '今夜评级';

	// ── 标题：烘图（380×100，图内基线 78、字左起 24）──
	const endTitle = img(endRoot, 'Image/StartUI/lv2_title_end.png', 82, 322 - 78, 380, 100);
	endTitle.opacity = 0;

	// ── 朱红横线 / 台词 11 两行 / 分隔线 ──
	const endRule = block(endRoot, 112, 346, 1, 4, C_VERM);
	const endL1 = label(endRoot, FONT_B, 22, Color(36, 73, 70, 224), 112, 402, 0, 1.4);
	endL1.text = '那一夜，砻就没停过。';
	const endL2 = label(endRoot, FONT_B, 22, Color(36, 73, 70, 224), 112, 440, 0, 1.4);
	endL2.text = '停一下，外面就听出来了。';
	const endSep = block(endRoot, 112, 482, 1, 2, C_INK, 0.32);

	// ── 统计四行：标签 + 数值 + 一条进度条 ──
	const STAT_K = ['命中', '漏击', '最大连击', '疑心峰值'];
	const STAT_Y = [516, 541, 566, 591];
	const endStatK: Label.Type[] = [];
	const endStatV: Label.Type[] = [];
	const endStatBg: Sprite.Type[] = [];
	const endStatFill: Sprite.Type[] = [];
	for (let i = 0; i < 4; i++) {
		const y = STAT_Y[i];
		const k = label(endRoot, FONT_R, 14, Color(36, 73, 70, 153), 112, y, 0, 1.2);
		k.text = STAT_K[i];
		const v = label(endRoot, FONT_B, 15, C_INK, 300, y, 1, 0.8);
		endStatK.push(k);
		endStatV.push(v);
		endStatBg.push(block(endRoot, 320, y - 12, 180, 5, C_INK, 0.10));
		endStatFill.push(block(endRoot, 320, y - 12, 1, 5, C_INK, 0.62));
	}

	// ── 台词 12 ──
	const endL3 = label(endRoot, FONT_B, 16, Color(36, 73, 70, 204), 112, 630, 0, 1.2);
	endL3.text = '可光靠耳朵骗不住人，城里得真有粮。';

	// ── 两个按钮：投影固定、面板推右下（照主菜单 mkButton）──
	type EBtn = {
		x: number; y: number; w: number; h: number;
		sh: Sprite.Type; pn: Sprite.Type; ed: Sprite.Type[];
		lb: Label.Type; sb: Label.Type;
	};
	const ebtns: EBtn[] = [];
	const EBTN = [
		{ x: 112, y: 660, w: 240, h: 60, label: '好', sub: '去看看他们的田' },
		{ x: 376, y: 660, w: 168, h: 60, label: '再来一次', sub: '按 R' },
	];
	for (const d of EBTN) {
		const sh = block(endRoot, d.x + 8, d.y + 8, d.w, d.h, C_INK, 0.88);
		const pn = block(endRoot, d.x, d.y, d.w, d.h, Color(246, 240, 223, 255));
		const ed: Sprite.Type[] = [
			block(endRoot, d.x + 1.5, d.y + 1.5, d.w - 3, 3, C_INK, 0.95),
			block(endRoot, d.x + 1.5, d.y + d.h - 4.5, d.w - 3, 3, C_INK, 0.95),
			block(endRoot, d.x + 1.5, d.y + 1.5, 3, d.h - 3, C_INK, 0.95),
			block(endRoot, d.x + d.w - 4.5, d.y + 1.5, 3, d.h - 3, C_INK, 0.95),
		];
		const lb = label(endRoot, FONT_B, 20, C_INK, d.x + d.w / 2, d.y + 22, 0.5, 10);
		lb.text = d.label;
		const sb = label(endRoot, FONT_R, 9, Color(36, 73, 70, 128), d.x + d.w / 2, d.y + 46, 0.5, 0.6);
		sb.text = d.sub;
		ebtns.push({ x: d.x, y: d.y, w: d.w, h: d.h, sh: sh, pn: pn, ed: ed, lb: lb, sb: sb });
	}
	const ebHov: number[] = [0, 0];
	const ebPrs: number[] = [0, 0];

	// ── 落款 ──
	const endFoot = label(endRoot, FONT_R, 11, Color(36, 73, 70, 102), 112, 764, 0, 1.2);
	endFoot.text = '永昌堡 · 嘉靖四十年 · 五月 · 夜尽';

	const endBtnAt = (mx: number, my: number): number => {
		for (let i = 0; i < ebtns.length; i++) {
			const b = ebtns[i];
			if (mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h) { return i; }
		}
		return -1;
	};

	// 统计值随一局结果变化，进入收束时刷一次就够
	const setEndStats = (): void => {
		const s = [hits, misses, maxCombo, suspPeak];
		const texts = [
			hits.toString() + ' / ' + (hits + misses).toString(),
			misses.toString() + ' 次',
			maxCombo.toString(),
			Math.round(suspPeak).toString() + '%',
		];
		const rates = [hits / Math.max(1, hits + misses), misses / Math.max(1, hits + misses), 0, suspPeak / 100];
		for (let i = 0; i < 4; i++) {
			endStatV[i].text = texts[i];
			const w = rates[i] > 0 ? Math.max(2, 180 * rates[i]) : 1;
			endStatFill[i].size = Size(w, 5);
			endStatFill[i].anchor = Vec2(0, 1);
			endStatFill[i].color = i === 3 ? C_VERM : C_INK;
		}
		endStatFill[2].opacity = 0;   // 最大连击不画条
	};

	const syncEnd = (): void => {
		setEndStats();

		// 印章：从大到小砸下
		const sp = ease3(endT, 0.10, 0.26);
		endSeal.opacity = sp;
		endSealLb.opacity = sp;
		endTag.opacity = sp;
		const ks = 1 + 1.4 * (1 - sp);
		endSeal.size = Size(38 * ks, 38 * ks);
		endSeal.anchor = Vec2(0.5, 0.5);
		endSeal.position = Vec2(131, H - 215);

		// 评级：比印章晚一点
		const gp = ease3(endT, 1.30, 0.26);
		for (const e of endGradeEdges) { e.opacity = gp; }
		endGradeLb.opacity = gp;
		endGradeTip.opacity = gp * 0.9;
		const gk = 1 + 1.4 * (1 - gp);
		const gw2 = 44 * gk;
		const gcx = GX + GS / 2, gcy = GY + GS / 2;
		endGradeEdges[0].size = Size(gw2, GW);
		endGradeEdges[0].anchor = Vec2(0.5, 0.5);
		endGradeEdges[0].position = Vec2(gcx, H - (gcy - gw2 / 2 + GW / 2));
		endGradeEdges[1].size = Size(gw2, GW);
		endGradeEdges[1].anchor = Vec2(0.5, 0.5);
		endGradeEdges[1].position = Vec2(gcx, H - (gcy + gw2 / 2 - GW / 2));
		endGradeEdges[2].size = Size(GW, gw2);
		endGradeEdges[2].anchor = Vec2(0.5, 0.5);
		endGradeEdges[2].position = Vec2(gcx - gw2 / 2 + GW / 2, H - gcy);
		endGradeEdges[3].size = Size(GW, gw2);
		endGradeEdges[3].anchor = Vec2(0.5, 0.5);
		endGradeEdges[3].position = Vec2(gcx + gw2 / 2 - GW / 2, H - gcy);

		// 标题
		const tp = ease3(endT, 0.30, 0.42);
		endTitle.opacity = tp;
		endTitle.position = Vec2(82 + (1 - tp) * 30, H - (322 - 78));

		// 横线拉开
		const rp = ease3(endT, 0.52, 0.42);
		endRule.size = Size(Math.max(1, 128 * rp), 4);
		endRule.anchor = Vec2(0, 1);
		endRule.position = Vec2(112, H - 346);

		// 两句
		const l1 = ease3(endT, 0.70, 0.5);
		endL1.opacity = l1;
		endL1.position = Vec2(112, H - 402 + (1 - l1) * 12);
		const l2 = ease3(endT, 0.84, 0.5);
		endL2.opacity = l2;
		endL2.position = Vec2(112, H - 440 + (1 - l2) * 12);

		// 分隔线
		const sep = ease3(endT, 1.00, 0.42);
		endSep.size = Size(Math.max(1, 448 * sep), 2);
		endSep.anchor = Vec2(0, 1);
		endSep.position = Vec2(112, H - 482);

		// 统计逐行浮现
		for (let i = 0; i < 4; i++) {
			const a = ease3(endT, 1.00 + i * 0.10, 0.42);
			endStatK[i].opacity = a;
			endStatV[i].opacity = a;
			endStatBg[i].opacity = 0.10 * a;
			if (i !== 2) { endStatFill[i].opacity = 0.62 * a; }
			endStatK[i].position = Vec2(112, H - STAT_Y[i] + (1 - a) * 8);
			endStatV[i].position = Vec2(300, H - STAT_Y[i] + (1 - a) * 8);
		}

		// 台词 12
		const l3 = ease3(endT, 1.30, 0.5);
		endL3.opacity = l3;

		// 按钮：弹入 + 悬停/按下
		const ap = ease3(endT, 1.50, 0.5);
		const idx = endBtnAt(ptrX, ptrY);
		for (let i = 0; i < ebtns.length; i++) {
			const b = ebtns[i];
			ebHov[i] = approach(ebHov[i], idx === i ? 1 : 0, 0.10);
			ebPrs[i] = approach(ebPrs[i], (idx === i && ptrDown) ? 1 : 0, 0.16);
			const e = ebHov[i] * ebHov[i] * (3 - 2 * ebHov[i]);
			const off = 3 * e + 2 * ebPrs[i];
			const dim = e * 0.55 + ebPrs[i] * 0.35;
			const k = 0.92 + 0.08 * ap;
			b.sh.opacity = ap;
			b.pn.opacity = ap;
			b.pn.color = Color(246 - dim * 40, 240 - dim * 34, 223 - dim * 28, 255);
			// 面板和四边一起平移 off，尺寸不变（原型里按钮不缩放，只有淡入 + 位移）。
			// 之前面板减 off、边框却各自乱算，结果面板比边框小一圈。
			const bx = b.x + off, by = b.y + off;
			b.pn.size = Size(b.w, b.h);
			b.pn.anchor = Vec2(0, 1);
			b.pn.position = Vec2(bx, H - by);
			b.ed[0].size = Size(b.w - 3, 3);
			b.ed[0].anchor = Vec2(0, 1);
			b.ed[0].position = Vec2(bx + 1.5, H - (by + 1.5));
			b.ed[1].size = Size(b.w - 3, 3);
			b.ed[1].anchor = Vec2(0, 1);
			b.ed[1].position = Vec2(bx + 1.5, H - (by + b.h - 4.5));
			b.ed[2].size = Size(3, b.h - 3);
			b.ed[2].anchor = Vec2(0, 1);
			b.ed[2].position = Vec2(bx + 1.5, H - (by + 1.5));
			b.ed[3].size = Size(3, b.h - 3);
			b.ed[3].anchor = Vec2(0, 1);
			b.ed[3].position = Vec2(bx + b.w - 4.5, H - (by + 1.5));
			for (let j = 0; j < 4; j++) { b.ed[j].opacity = ap; }
			b.lb.opacity = ap;
			b.lb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 22) - off);
			b.sb.opacity = ap * 0.9;
			b.sb.position = Vec2(b.x + b.w / 2 + off, H - (b.y + 46) - off);
		}

		// 落款
		endFoot.opacity = ease3(endT, 1.80, 0.6);
	};

	/* ══════════ 对外 ══════════ */
	notes = buildChart();
	startBeat = opts.startAt !== undefined ? opts.startAt : 0;
	elapsed = -PREROLL;
	state = 0;

	if (startBeat > 0) {
		for (const n of notes) {
			if (n.t < startBeat * SPB) { n.judged = true; n.result = -1; }
		}
	}

	// 调试后门：直接落到对局的第 startBeat 拍，省掉「点开始 / 跳对话」两下
	if (opts.immediate === true) {
		state = 1;
		introRoot.visible = false;
		playRoot.visible = true;
		elapsed = startBeat * SPB;
		if (opts.debugView === 'panel') { showSet = true; setRoot.visible = true; }
		if (opts.debugView === 'pause') { paused = true; pauseRoot.visible = true; }
	} else {
		// 标题卡阶段：HTML 的 drawIntro 只画 crenel/guard/beam，玩法层整层不该出现
		playRoot.visible = false;
		// 按钮按下态的截图档：把指针钉在「开始」按钮内并按住
		if (opts.debugView === 'btn') { ptrX = 200; ptrY = 660; ptrDown = true; }
		if (opts.debugView === 'hov') { ptrX = 200; ptrY = 660; ptrDown = false; }
	}

	// 点「开始」或按任意击打键才真正开打
	const beginPlay = (): void => {
		if (state !== 0) { return; }
		state = 1;
		introRoot.visible = false;
		playRoot.visible = true;
		elapsed = -PREROLL;
	};

	const play: Level2Play = {
		update: (dt: number): void => {
			update(dt);
			draw();
		},
		destroy: (): void => {
			Audio.stopAll();
			layer.removeFromParent();
		},
		setPointer: (x: number, y: number, down: boolean): void => {
			// 只有关前标题卡的「开始」按钮需要悬停/按下反馈
			ptrX = x; ptrY = y; ptrDown = down;
		},
		hoverAt: (x: number, y: number): void => {
			// 纯悬停：只挪位置，不碰按下态。
			// 鼠标「按下并拖动」会同时来 mouseMove 和 tapMoved，这里动 down 会互相打架
			ptrX = x; ptrY = y;
		},
		tapAt: (x: number, y: number): boolean => {
			// 暂停时点任意处继续（遮罩把 HUD 和齿轮都盖住了，点不到别的）
			if (paused) { paused = false; pauseRoot.visible = false; Audio.setPauseAllCurrent(false); return true; }
			// 齿轮钮：任何对局时刻都能开关设置面板，优先级最高
			if (state === 1 && x >= 1192 && x <= 1236 && y >= 14 && y <= 58) {
				showSet = !showSet;
				setRoot.visible = showSet;
				return true;
			}
			// 设置面板展开时，把面板上的点击全部吃掉，不漏到下面的击打判定
			if (showSet) {
				if (y >= SET_Y + 36 && y <= SET_Y + 62 && x >= IX && x <= IX + IW) {
					audioBgm = Math.min(1, Math.max(0, (x - IX) / IW));
					syncSet();
					return true;
				}
				if (y >= SET_Y + 102 && y <= SET_Y + 128 && x >= IX && x <= IX + IW) {
					audioSfx = Math.min(1, Math.max(0, (x - IX) / IW));
					syncSet();
					return true;
				}
				if (y >= SET_Y + 152 && y <= SET_Y + 188 && x >= IX && x <= IX + IW) {
					if (opts.onQuit !== undefined) { opts.onQuit(); }
					return true;
				}
				return true;
			}
			if (state === 0) { beginPlay(); return true; }
			if (state === 2) {
				const bi = endBtnAt(x, y);
				if (bi === 0) { if (opts.onNext !== undefined) { opts.onNext(); } return true; }
				if (bi === 1) { if (opts.onRestart !== undefined) { opts.onRestart(); } return true; }
				// 空白处不吃动作。原来这里 1.2s 后走 onFinish，而 onFinish 之后
				// 没有下一站——点偏一点就把整关打成空白页
				return true;
			}
			if (state !== 1) { return false; }
			if (y < RM_T) { return false; }
			let best = 0, bd = 1e9;
			for (let i = 0; i < 3; i++) {
				const d = Math.abs(x - LANE_CX[i]);
				if (d < bd) { bd = d; best = i; }
			}
			hit(best);
			return true;
		},
		hit: (lane: number): void => { hit(lane); },
		skip: (): void => {
			// 暂停 / 设置面板开着时按 P，先收掉它们，否则会盖在收束页上
			if (paused) { paused = false; pauseRoot.visible = false; Audio.setPauseAllCurrent(false); }
			if (showSet) { showSet = false; setRoot.visible = false; }
			if (state === 0) { beginPlay(); return; }
			if (state === 2) {
				// 收束页的「跳过」= 翻到下一页（科普），不是结束到一片空白。
				// 原来走的是 onFinish，而第二关场景收到 onFinish 后只 print 一行就没了
				if (opts.onNext !== undefined) { opts.onNext(); }
				return;
			}
			state = 2;
			wangzi.visible = false;
			wangziLaugh.visible = true;
			// 关后页立绘在右侧（和关前页同一位置），不挪的话会压在统计文字上
			wangziLaugh.size = Size(300, 400);
			wangziLaugh.anchor = Vec2(0, 1);
			wangziLaugh.position = Vec2(856, H - 350);
			for (const jl of judgeLine) { jl.visible = false; }
			hudRoot.visible = false;
			plateRoot.visible = false;
			endRoot.visible = true;
			bannerTick.visible = false;
			for (const s of knockTicks) { s.visible = false; }
			endT = 0;
			syncEnd();
		},
		isFinished: (): boolean => state === 2,
		togglePause: (): void => {
			if (state !== 1) { return; }
			paused = !paused;
			pauseRoot.visible = paused;
			// HTML 的 togglePause 会 ac.suspend() 挂起音频上下文，音乐跟着停；
			// 不暂停的话，玩家挂着暂停页，BGM 会一路播到收束，回来时对不上拍
			Audio.setPauseAllCurrent(paused);
		},
		dragTo: (x: number, y: number): boolean => {
			if (!showSet) { return false; }
			const at = (v: number): number => Math.min(1, Math.max(0, v));
			// 拖拽不必先精确按在滑块上：落在哪根滑杆的行高范围里就改哪根
			if (y >= SET_Y + 30 && y <= SET_Y + 70) {
				audioBgm = at((x - IX) / IW);
				syncSet();
				return true;
			}
			if (y >= SET_Y + 96 && y <= SET_Y + 136) {
				audioSfx = at((x - IX) / IW);
				syncSet();
				return true;
			}
			return false;
		},
		isPaused: (): boolean => paused,
		stats: (): number[] => [hits, misses, maxCombo, suspPeak],
		setPanelOpen: (): boolean => showSet,
	};

	print('[Level2Play] 开始');
	return play;
}
