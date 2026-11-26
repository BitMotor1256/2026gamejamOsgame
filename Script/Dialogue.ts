// PPT 式对白页（关前 / 过场通用）
// 版式一比一移植自 03-界面与版式/第一关-关前页.html（1280×804）
//
// 这一版对齐了 HTML 原型的最新改动：
//   1. 去掉右上「① 科普」角标与底部流程条 —— 页眉只留标题一行
//   2. 王梓有 8 套表情，按句切换（双层叠图交叉淡入，构图同画幅所以不跳位）
//   3. 打字时王梓轻微点头；打完就停回静立呼吸
//   4. 点击反馈简化成「一圈细涟漪」（tap_ring.png 放大淡出）
//   5. 场景标注坐标修正：标注现在是【场景图内坐标】+SCENE 偏移算出来的。
//      之前用的是整页坐标，线直接画到图外、压在对白条上。
//   6. 标注文字加「米色纸条」：阴影 + 朱红边框 + 纸底，压在图上也能读
import {
	Color,
	Label,
	Node,
	Size,
	Sprite,
	TextAlign,
	Vec2,
} from 'Dora';
import { LEVEL1_SPOTS, LineData, SpotData } from 'Script/Story';

const W = 1280;
const H = 804;
const REG = 'Font/SourceHanSerifSC-Regular.ttf';
const BOLD = 'Font/SourceHanSerifSC-SemiBold.ttf';
const MED = 'Font/SourceHanSerifSC-SemiBold.ttf';

const C_PAPER = Color(233, 223, 196, 255);
const C_CARD = Color(252, 247, 232, 255);
const C_INK = Color(36, 73, 70, 255);
const C_MUTE = Color(76, 99, 87, 255);
const C_VERM = Color(163, 59, 42, 255);
const C_TAG = Color(142, 46, 31, 255);      // 纸条上的字（比 C_VERM 再深一档）
const C_TAG_EDGE = Color(163, 59, 42, 140);
const C_TAG_SHADOW = Color(36, 73, 70, 85);

/* 场景区（关卡画面） */
const SCENE = { x: 120, y: 104, w: 1040, h: 330 };
/* 大对白条 */
const SAY = { x: 120, y: 506, w: 744, h: 172 };
const PAD = 34;

/* 王梓的八套表情（Image/StartUI/face_*.png，655×900 同画幅） */
const FACE_LIST: string[] = [
	'smile', 'laugh', 'dot', 'wave', 'curvy', 'shy', 'shyact', 'dizzy',
];
/* 显示尺寸：HTML 里 .wz 是 250×344，right:14 / bottom:18 */
const FACE_W = 250;
const FACE_H = 344;
const WZ_X = W - 14 - FACE_W;   // 左边界（anchor 用 0,0 左下角对齐）
const WZ_Y = 18;                // 底边离画面底部 18px

/* 打字节奏 */
const CPS = 0.032;
const CH_BYTES = 3;     // UTF-8 汉字字节数（台词全中文全角，安全）
const FADE_IN_PAGE = 0.55;
const FADE_IN_LINE = 0.20;
const FADE_OUT_LINE = 0.14;
const FADE_OUT_ALL = 0.30;

export type DialogueOpts = {
	header: string;
	scene: string;
	speaker: string;
	lines: LineData[];
	onFinish: () => void;
	// 要建哪几组场景标注。关前：ruler / height / seal；关后：gap / ruler / height / crown
	fxGroups?: string[];
	// 纸条文案（关前关后同一组标注文案不同）
	tags?: { ruler?: string; height?: string; gap?: string; crown?: string };
	// 调试后门：直接从第 N 句起，截图核对标注时不用真的一句句点
	startAt?: number;
	// 三个可点标点 + 说明卡只在关前页有，关后页不出现
	spots?: boolean;
	// 自定义标点数据（不同关的场景图不一样）。不传就用第一关那三个。
	spotData?: SpotData[];
	// 场景图右下角的图注
	caption?: string;
	// 页眉做图。引擎的 SDF 图集会把某些复杂字拼错（这一关的「砻」被拼成了别的字，
	// 三支字重都一样），这种字只能交给浏览器渲染后当贴图用。
	headerImg?: string;
	// 用高版对白条（196 vs 172）。第二关有 48 字的长句要占三行，172 装不下。
	sayTall?: boolean;
};

export function createDialogue(root: Node.Type, opts: DialogueOpts) {
	const layer = Node();
	layer.anchor = Vec2(0, 0);
	layer.size = Size(W, H);
	layer.position = Vec2(0, 0);
	layer.opacity = 0;
	layer.addTo(root);

	/* 纯色块（white.png 染色） */
	const block = (
		parent: Node.Type, x: number, y: number, w: number, h: number,
		c: Color.Type, alpha = 1,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.anchor = Vec2(0.5, 0.5);
		s.size = Size(Math.abs(w), Math.abs(h));
		s.color = c;
		// Sprite.color 的 alpha 通道不生效，半透明一律走 opacity
		s.opacity = alpha;
		s.position = Vec2(x + w / 2, H - (y + h / 2));
		s.addTo(parent);
		return s;
	};

	// 超采样：Label 按字号烘成小纹理，之后被整层缩放放大就会发虚。
	// 按 SS 倍字号烘、再 scale 缩回，纹素密度就是显示尺寸的 SS 倍。
	// 这里拿不到外层卡片的缩放（层级在 inner 里），固定 2 倍足够覆盖常见窗口。
	const SS = 2;

	// Dora 里汉字的步进（advance）约 0.72em，而 HTML 的 fillText 是 1em。
	// 同一个 textWidth，Dora 能多塞四成字——结果就是「末行只剩一个句号」。
	// 折行宽度按这个比例折算，才能和 HTML 的每行字数对上。
	const CHAR_ADV = 0.72;

	/* 文字（左上角定位） */
	const text = (
		parent: Node.Type, font: string, size: number, color: Color.Type,
		x: number, y: number, width: number, gap: number, outline: number,
	): Label.Type => {
		const lb = Label(font + ';' + Math.round(size * SS) + ';true')!;
		lb.color = color;
		if (outline > 0) {
			lb.outlineColor = color;
			lb.outlineWidth = outline;
		}
		if (width > 0) {
			lb.textWidth = width * SS;
			lb.lineGap = gap * SS;
			lb.alignment = TextAlign.Left;
		}
		lb.anchor = Vec2(0, 1);
		lb.scaleX = 1 / SS;
		lb.scaleY = 1 / SS;
		lb.position = Vec2(x, H - y);
		lb.addTo(parent);
		return lb;
	};

	/* 文字（在 x..x+w 之间水平居中） */
	const textC = (
		parent: Node.Type, font: string, size: number, color: Color.Type,
		x: number, y: number, width: number,
	): Label.Type => {
		const lb = Label(font + ';' + Math.round(size * SS) + ';true')!;
		lb.color = color;
		lb.textWidth = width * SS;
		lb.alignment = TextAlign.Center;
		lb.anchor = Vec2(0, 1);
		lb.scaleX = 1 / SS;
		lb.scaleY = 1 / SS;
		lb.position = Vec2(x, H - y);
		lb.addTo(parent);
		return lb;
	};

	/* 图上小纸条：硬阴影 → 朱红细边 → 米色纸面 */
	const paperTag = (
		parent: Node.Type, x: number, y: number, w: number, h: number,
	): void => {
		block(parent, x + 3, y + 3, w, h, C_INK, 0.33);
		block(parent, x - 2, y - 2, w + 4, h + 4, C_VERM, 0.55);
		block(parent, x, y, w, h, C_CARD);
	};

	/* ---------- 纸色整屏 + 网点/横线肌理 ---------- */
	block(layer, 0, 0, W, H, C_PAPER);
	const grain = Sprite('Image/StartUI/paper_grain.png')!;
	grain.anchor = Vec2(0, 1);
	grain.size = Size(W, H);
	grain.position = Vec2(0, H);
	grain.addTo(layer);

	/* ---------- 入场分组 ----------
	   整层一起淡入太平，像一张图「亮」起来。这里拆成四组，各走各的节奏：
	   页眉落下 → 场景升起 → 王梓滑入 → 对白条抬起来。 */
	const headGroup = Node();
	headGroup.size = Size(W, H);
	headGroup.anchor = Vec2(0, 0);
	headGroup.position = Vec2(0, 0);
	headGroup.opacity = 0;
	headGroup.addTo(layer);

	// 顶部横线 + 页眉（右上角标已删）
	block(headGroup, 56, 44, W - 112, 1.5, C_INK, 0.59);
	if (opts.headerImg !== undefined) {
		const hd = Sprite(opts.headerImg)!;
		hd.anchor = Vec2(0, 1);
		hd.size = Size(200, 22);
		// 图里的字从 y=2 起，所以图顶边放在 50，字才落在 52（和 Label 版一致）
		hd.position = Vec2(56, H - 50);
		hd.addTo(headGroup);
	} else {
		const hdL = text(headGroup, REG, 18, C_MUTE, 56, 52, 700, 0, 0.04);
		hdL.text = opts.header;
		hdL.spacing = 2;
	}

	/* ---------- 场景区 ---------- */
	// 场景组：投影、图、墨框、角标、标签、标点、标注、图注全在里面，
	// 入场时整组升起，才不会有「图动了框没动」的错位。
	const sceneGroup = Node();
	sceneGroup.size = Size(W, H);
	sceneGroup.anchor = Vec2(0, 0);
	sceneGroup.position = Vec2(0, 0);
	sceneGroup.opacity = 0;
	sceneGroup.addTo(layer);

	// 漫画格的实心投影（不是虚化阴影），偏移 9px
	block(sceneGroup, SCENE.x + 9, SCENE.y + 9, SCENE.w, SCENE.h, C_INK, 0.9);
	const scene = Sprite(opts.scene)!;
	scene.anchor = Vec2(0, 1);
	scene.size = Size(SCENE.w, SCENE.h);
	scene.position = Vec2(SCENE.x, H - SCENE.y);
	scene.addTo(sceneGroup);

	// 3px 墨框（画在图片外沿）
	block(sceneGroup, SCENE.x - 3, SCENE.y - 3, SCENE.w + 6, 3, C_INK);
	block(sceneGroup, SCENE.x - 3, SCENE.y + SCENE.h, SCENE.w + 6, 3, C_INK);
	block(sceneGroup, SCENE.x - 3, SCENE.y - 3, 3, SCENE.h + 6, C_INK);
	block(sceneGroup, SCENE.x + SCENE.w, SCENE.y - 3, 3, SCENE.h + 6, C_INK);

	// 四角角标（先画，等下被图一标签压住一角）
	const CORNER = 16;
	block(sceneGroup, SCENE.x + 6, SCENE.y + 6, CORNER, 1.5, C_INK, 0.47);
	block(sceneGroup, SCENE.x + 6, SCENE.y + 6, 1.5, CORNER, C_INK, 0.47);
	block(sceneGroup, SCENE.x + SCENE.w - 6 - CORNER, SCENE.y + 6, CORNER, 1.5, C_INK, 0.47);
	block(sceneGroup, SCENE.x + SCENE.w - 7.5, SCENE.y + 6, 1.5, CORNER, C_INK, 0.47);
	block(sceneGroup, SCENE.x + 6, SCENE.y + SCENE.h - 7.5, CORNER, 1.5, C_INK, 0.47);
	block(sceneGroup, SCENE.x + 6, SCENE.y + SCENE.h - 6 - CORNER, 1.5, CORNER, C_INK, 0.47);
	block(sceneGroup, SCENE.x + SCENE.w - 6 - CORNER, SCENE.y + SCENE.h - 7.5, CORNER, 1.5, C_INK, 0.47);
	block(sceneGroup, SCENE.x + SCENE.w - 7.5, SCENE.y + SCENE.h - 6 - CORNER, 1.5, CORNER, C_INK, 0.47);

	// 图一：朱红不干胶标签，压在格子左上角
	// 这里用贴图而不是 Label —— 引擎渲染「一」这种单笔时会拉成一条长横加一个点，
	// 换字体、去字距都不管用，索性把两个字连同朱红底一起烘成图（70×32，2 倍图）。
	const TAGW = 70;
	const TAGH = 32;
	block(sceneGroup, SCENE.x - 3, SCENE.y - 3, TAGW + 2.5, TAGH + 2.5, C_INK);
	const tagImg = Sprite('Image/StartUI/tag_tu1.png')!;
	tagImg.anchor = Vec2(0, 1);
	tagImg.size = Size(TAGW, TAGH);
	tagImg.position = Vec2(SCENE.x - 3, H - (SCENE.y - 3));
	tagImg.addTo(sceneGroup);

	/* ---------- 可点标点 + 说明卡 ---------- */
	const cardNodes: Node.Type[] = [];
	const spotDots: Sprite.Type[] = [];
	let openIdx = -1;
	let cardAnim = 0;
	let toggleCard: (i: number) => void = (): void => {};

	const useSpots = opts.spots !== false;
	const spots = opts.spotData !== undefined ? opts.spotData : LEVEL1_SPOTS;
	if (useSpots) spots.forEach((sp, i) => {
		const bx = sp.x - 15;
		const by = sp.y - 15;
		block(sceneGroup, bx, by, 30, 1.5, C_VERM);
		block(sceneGroup, bx, by + 28.5, 30, 1.5, C_VERM);
		block(sceneGroup, bx, by, 1.5, 30, C_VERM);
		block(sceneGroup, bx + 28.5, by, 1.5, 30, C_VERM);
		const dot = block(sceneGroup, sp.x - 4.5, sp.y - 4.5, 9, 9, C_VERM);
		spotDots.push(dot);

		// 说明卡（默认隐藏）
		const card = Node();
		card.size = Size(W, H);
		card.anchor = Vec2(0, 0);
		card.position = Vec2(0, 0);
		// visible 必须在 addTo 之后设：Dora 里新建节点挂到父节点上会被重置成可见
		card.addTo(sceneGroup);
		card.visible = false;
		const cardBg = Sprite('Image/StartUI/card_info.png')!;
		cardBg.anchor = Vec2(0, 1);
		cardBg.size = Size(329, 159);
		cardBg.position = Vec2(sp.cx - 1.25, H - (sp.cy - 1.25));
		cardBg.addTo(card);
		const ct = text(card, BOLD, 22, C_INK, sp.cx + 22, sp.cy + 20, 280, 0, 0);
		ct.text = sp.t;
		const cn = text(card, BOLD, 20, C_VERM, sp.cx + 22, sp.cy + 54, 280, 0, 0);
		cn.text = sp.n;
		const cd = text(card, MED, 17, C_MUTE, sp.cx + 22, sp.cy + 84, 276 * CHAR_ADV, 9, 0);
		cd.text = sp.d;
		cardNodes.push(card);
	});

	toggleCard = (i: number): void => {
		openIdx = (openIdx === i) ? -1 : i;
		cardAnim = 0;
		cardNodes.forEach((c, k) => {
			c.visible = (k === openIdx);
			if (k === openIdx) {
				c.opacity = 0;
				c.position = Vec2(0, -10);
			}
		});
	};

	/* ---------- 点击涟漪（一圈细环，放大淡出） ---------- */
	type Ripple = { s: Sprite.Type; t: number; dur: number; d0: number; d1: number };
	const ripples: Ripple[] = [];

	const ripple = (x: number, y: number, strong: boolean): void => {
		const s = Sprite('Image/StartUI/tap_ring.png')!;
		s.anchor = Vec2(0.5, 0.5);
		s.size = Size(26, 26);
		s.position = Vec2(x, y);
		s.addTo(layer);
		ripples.push({
			s: s, t: 0,
			dur: strong ? 0.44 : 0.36,
			d0: 26, d1: strong ? 118 : 86,
		});
	};

	// 整屏 input 把点击的本地坐标（左下原点）传进来。
	// 返回 true 表示这次点击被标点/卡片吃掉了，不该推进台词。
	const tapAt = (x: number, y: number): boolean => {
		if (!useSpots) { return false; }
		for (let i = 0; i < spots.length; i++) {
			const sp = spots[i];
			if (Math.abs(x - sp.x) < 24 && Math.abs(y - (H - sp.y)) < 24) {
				ripple(x, y, true);
				toggleCard(i);
				return true;
			}
		}
		ripple(x, y, false);
		if (openIdx >= 0) {
			toggleCard(openIdx);
			return true;
		}
		return false;
	};

	/* ---------- 按句点亮的标注（坐标 = 场景图内坐标 + SCENE 偏移） ----------
	   场景图是重画的那张：天空 0–96 · 垛口 96–140 · 墙 140–296 · 墙脚 296–330。
	   坐标全部按这张图重算过——旧图是 0–115 / 115–155 / 155–330，直接沿用会整体偏下 20px。 */
	const fxNodes: { name: string; node: Node.Type }[] = [];
	const wantFx = opts.fxGroups !== undefined
		? opts.fxGroups
		: ['ruler', 'height', 'seal'];
	const hasFx = (k: string): boolean => wantFx.indexOf(k) >= 0;
	const tagOf = (k: string, d: string): string => {
		if (opts.tags === undefined) { return d; }
		const v = k === 'ruler' ? opts.tags.ruler
			: k === 'height' ? opts.tags.height
				: k === 'gap' ? opts.tags.gap
					: k === 'crown' ? opts.tags.crown : undefined;
		return v !== undefined ? v : d;
	};

	const fxLayer = (): Node.Type => {
		const n = Node();
		n.size = Size(W, H);
		n.anchor = Vec2(0, 0);
		n.position = Vec2(0, 0);
		n.opacity = 0;
		n.addTo(layer);
		n.visible = false;
		return n;
	};

	/* 朱红细框 + 纸色衬边，用来圈一块区域（关后的「缺口」「垛口」都用它） */
	const ring = (
		parent: Node.Type, x: number, y: number, w: number, h: number, t: number,
	): void => {
		block(parent, x - 3, y - 3, w + 6, h + 6, C_CARD, 0.5);
		block(parent, x, y, w, t, C_VERM);
		block(parent, x, y + h - t, w, t, C_VERM);
		block(parent, x, y, t, h, C_VERM);
		block(parent, x + w - t, y, t, h, C_VERM);
	};

	const mkTag = (
		parent: Node.Type, x: number, y: number, w: number, txt: string,
	): void => {
		paperTag(parent, x, y, w, 40);
		const lb = textC(parent, BOLD, 22, C_TAG, x, y + 7, w);
		lb.text = txt;
	};

	let rulerLine: Sprite.Type | undefined = undefined;
	let fxRuler: Node.Type | undefined = undefined;

	// 宽度：一圈 2688 米（横线从 60 长到 980，两端带 30px 刻度）
	if (hasFx('ruler')) {
		fxRuler = fxLayer();
		const RULER_Y = SCENE.y + 218;
		const RULER_X0 = SCENE.x + 60;
		const line = Sprite('Image/StartUI/white.png')!;
		line.anchor = Vec2(0, 0.5);
		line.color = C_VERM;
		line.size = Size(920, 3);
		line.position = Vec2(RULER_X0, H - RULER_Y);
		line.addTo(fxRuler);
		rulerLine = line;
		block(fxRuler, SCENE.x + 58, SCENE.y + 203, 3, 30, C_VERM);
		block(fxRuler, SCENE.x + 978, SCENE.y + 203, 3, 30, C_VERM);
		mkTag(fxRuler, SCENE.x + 340, SCENE.y + 228, 360,
			tagOf('ruler', '一圈 2688 米　走完约半小时'));
		fxNodes.push({ name: 'ruler', node: fxRuler });
	}

	// 高度：从垛口顶（图内 y=96）量到墙脚（图内 y=296）
	if (hasFx('height')) {
		const node = fxLayer();
		block(node, SCENE.x + 56, SCENE.y + 96, 3, 200, C_VERM);
		block(node, SCENE.x + 34, SCENE.y + 95, 44, 3, C_VERM);
		block(node, SCENE.x + 34, SCENE.y + 295, 44, 3, C_VERM);
		mkTag(node, SCENE.x + 86, SCENE.y + 190, 215,
			tagOf('height', '高 8 米'));
		fxNodes.push({ name: 'height', node });
	}

	// 印章：民修（右上角，压住一格墙）
	if (hasFx('seal')) {
		const node = fxLayer();
		const SEAL = { x: SCENE.x + 828, y: SCENE.y + 168 };
		block(node, SEAL.x, SEAL.y, 78, 78, C_VERM);
		block(node, SEAL.x + 4, SEAL.y + 4, 70, 70, C_CARD);
		const a = text(node, BOLD, 24, C_VERM, SEAL.x + 24, SEAL.y + 14, 0, 0, 0.05);
		a.text = '民';
		const b = text(node, BOLD, 24, C_VERM, SEAL.x + 24, SEAL.y + 42, 0, 0, 0.05);
		b.text = '修';
		fxNodes.push({ name: 'seal', node });
	}

	// 砻：圈住近景那台碾具
	if (hasFx('mill')) {
		const node = fxLayer();
		ring(node, SCENE.x + 104, SCENE.y + 178, 240, 148, 3);
		mkTag(node, SCENE.x + 356, SCENE.y + 212, 200, tagOf('mill', '碾子 · 龙字加石'));
		fxNodes.push({ name: 'mill', node });
	}

	// 围城：圈城头那两缕烟（城内视角看不到营帐，只能靠烟指）
	if (hasFx('siege')) {
		const node = fxLayer();
		ring(node, SCENE.x + 846, SCENE.y + 6, 150, 106, 3);
		mkTag(node, SCENE.x + 588, SCENE.y + 30, 210, tagOf('siege', '城外扎营　围了半年'));
		fxNodes.push({ name: 'siege', node });
	}

	// 粮囤：圈那两个已经见底的草囤
	if (hasFx('bin')) {
		const node = fxLayer();
		ring(node, SCENE.x + 788, SCENE.y + 198, 200, 118, 3);
		mkTag(node, SCENE.x + 700, SCENE.y + 164, 130, tagOf('bin', '粮囤见底'));
		fxNodes.push({ name: 'bin', node });
	}

	// 糠：圈晒场上摊开的那一层
	if (hasFx('bran')) {
		const node = fxLayer();
		ring(node, SCENE.x + 382, SCENE.y + 256, 344, 74, 3);
		mkTag(node, SCENE.x + 396, SCENE.y + 200, 165, tagOf('bran', '糠撒在晒场上'));
		fxNodes.push({ name: 'bran', node });
	}

	// 缺口：圈住那段没砌完的墙（图内 x 338–734、y 94–300）
	if (hasFx('gap')) {
		const node = fxLayer();
		ring(node, SCENE.x + 338, SCENE.y + 94, 396, 206, 3);
		mkTag(node, SCENE.x + 750, SCENE.y + 150, 168,
			tagOf('gap', '一个洞都不行'));
		fxNodes.push({ name: 'gap', node });
	}

	// 垛口：圈住墙顶那三个齿（图内 x 150–340、y 92–144）
	if (hasFx('crown')) {
		const node = fxLayer();
		ring(node, SCENE.x + 150, SCENE.y + 92, 190, 52, 3);
		mkTag(node, SCENE.x + 356, SCENE.y + 100, 150,
			tagOf('crown', '垛口 905 个'));
		fxNodes.push({ name: 'crown', node });
	}

	// 图注：永昌堡 · 东段城墙（示意）
	const capLb = text(sceneGroup, MED, 20, Color(76, 99, 87, 215), 302, 442, 230, 0, 0);
	capLb.alignment = TextAlign.Right;
	capLb.position = Vec2(W - 516, H - 442);
	capLb.text = opts.caption !== undefined ? opts.caption : '永昌堡 · 东段城墙（示意）';

	/* ---------- 王梓：八套表情叠在同一位置，交叉淡入 ---------- */
	// 八张同画幅的图直接叠在同一个左下角 —— 不用容器节点，
	// 免得 anchor 在空 Node 上不按预期生效（踩过：整体低了半个身位）。
	const faceGroup = Node();
	faceGroup.size = Size(W, H);
	faceGroup.anchor = Vec2(0, 0);
	faceGroup.position = Vec2(0, 0);
	faceGroup.opacity = 0;
	faceGroup.addTo(layer);

	const faceSprites: Sprite.Type[] = [];
	for (let i = 0; i < FACE_LIST.length; i++) {
		const sp = Sprite('Image/StartUI/face_' + FACE_LIST[i] + '.png')!;
		sp.anchor = Vec2(0.5, 0);        // 绕底部中心，点头时才能微摆
		sp.size = Size(FACE_W, FACE_H);
		sp.position = Vec2(WZ_X + FACE_W / 2, WZ_Y);
		sp.opacity = (i === 0) ? 1 : 0;
		sp.addTo(faceGroup);
		faceSprites.push(sp);
	}
	let faceCur = 0;
	let introT = 0;          // 入场计时（秒）

	const setFace = (name?: string): void => {
		if (name === undefined) { return; }
		const k = FACE_LIST.indexOf(name);
		if (k >= 0) { faceCur = k; }
	};

	/* ---------- 对白条（圆角卡切图） ---------- */
	const sayGroup = Node();
	sayGroup.size = Size(W, H);
	sayGroup.anchor = Vec2(0, 0);
	sayGroup.position = Vec2(0, 0);
	sayGroup.opacity = 0;
	sayGroup.addTo(layer);

	const SAY_H = opts.sayTall === true ? 196 : 172;
	const sayCard = Sprite(opts.sayTall === true
		? 'Image/StartUI/card_say_tall.png'
		: 'Image/StartUI/card_say.png')!;
	sayCard.anchor = Vec2(0, 1);
	sayCard.size = Size(754, SAY_H + 10);
	sayCard.position = Vec2(SAY.x - 1.25, H - (SAY.y - 1.25));
	sayCard.addTo(sayGroup);

	// 名字：朱红胶囊挂在卡片上沿（一半在外）
	const pill = Sprite('Image/StartUI/pill_name.png')!;
	pill.anchor = Vec2(0, 1);
	pill.size = Size(102, 40);
	pill.position = Vec2(SAY.x + 16, H - (SAY.y - 21));
	pill.addTo(sayGroup);

	// 三处小字（说话人 / 序号 / 点击继续）原来没做超采样：按 15~16px 直接烘，
	// 再被卡片整体缩到 0.84 左右，边缘就糊了。统一 2 倍烘、0.5 缩放。
	const whoLb = Label(MED + ';' + Math.round(15 * SS) + ';true')!;
	whoLb.color = C_CARD;
	whoLb.anchor = Vec2(0.5, 0.5);
	whoLb.scaleX = 1 / SS;
	whoLb.scaleY = 1 / SS;
	whoLb.position = Vec2(SAY.x + 74, H - (SAY.y + 1));
	whoLb.spacing = 7 * SS;
	whoLb.text = opts.speaker;
	whoLb.addTo(sayGroup);

	/* 正文：逐字一个常驻 Label（和第二关关后科普页同一套）。
	   原来是一整块 Label 每帧改 text —— Dora 每次赋值都重建纹理，
	   打字过程中字会抖、边缘发虚，这就是「前面的对话看着糊」的原因。
	   逐字之后纹理只建一次，只切 visible。
	   字体也用回 Regular，和科普页一致（SemiBold 在小字号下发闷）。 */
	const TX_SIZE = 32, TX_STEP = TX_SIZE * 0.78 + 1, TX_LINE = TX_SIZE + 14;
	const TX_COLS = Math.floor((SAY.w - PAD * 2) / TX_STEP);
	const TX_N = TX_COLS * 3;
	const txChars: Label.Type[] = [];
	for (let i = 0; i < TX_N; i++) {
		const lb = Label(REG + ';' + Math.round(TX_SIZE * SS) + ';true')!;
		lb.color = C_INK;
		lb.anchor = Vec2(0, 1);
		lb.scaleX = 1 / SS;
		lb.scaleY = 1 / SS;
		lb.visible = false;
		lb.addTo(sayGroup);
		txChars.push(lb);
	}
	let txCount = 0;

	// 按 UTF-8 首字节切字（TSTL 的 string 是字节串，直接 slice 会切在半个汉字上）
	const toChars = (str: string): string[] => {
		const out: string[] = [];
		let i = 0;
		while (i < str.length) {
			const c = str.charCodeAt(i);
			let n = 1;
			if (c >= 0xF0) { n = 4; }
			else if (c >= 0xE0) { n = 3; }
			else if (c >= 0xC0) { n = 2; }
			out.push(str.substr(i, n));
			i += n;
		}
		return out;
	};

	// 排一句：算换行、摆位置，然后全部藏起来等打字机
	const layoutLine = (str: string): void => {
		const chars = toChars(str);
		txCount = Math.min(TX_N, chars.length);
		for (let i = 0; i < TX_N; i++) {
			const lb = txChars[i];
			if (i >= txCount) { lb.visible = false; continue; }
			const col = i % TX_COLS;
			const row = Math.floor(i / TX_COLS);
			lb.text = chars[i];
			lb.position = Vec2(SAY.x + PAD + col * TX_STEP, H - (SAY.y + 56 + row * TX_LINE));
			lb.visible = false;
		}
	};

	const showChars = (n: number): void => {
		for (let i = 0; i < txCount; i++) { txChars[i].visible = (i < n); }
	};
	const setTxOpacity = (a: number): void => {
		for (let i = 0; i < txCount; i++) { txChars[i].opacity = a; }
	};

	const seqLb = Label(REG + ';' + Math.round(15 * SS) + ';true')!;
	seqLb.color = Color(76, 99, 87, 190);
	seqLb.outlineColor = Color(76, 99, 87, 190);
	seqLb.outlineWidth = 0.04;
	seqLb.anchor = Vec2(1, 1);
	seqLb.scaleX = 1 / SS;
	seqLb.scaleY = 1 / SS;
	seqLb.position = Vec2(SAY.x + SAY.w - 22, H - (SAY.y + 26));
	seqLb.addTo(sayGroup);

	const tipLb = Label(REG + ';' + Math.round(16 * SS) + ';true')!;
	tipLb.color = Color(36, 73, 70, 175);
	tipLb.outlineColor = Color(36, 73, 70, 175);
	tipLb.outlineWidth = 0.04;
	tipLb.anchor = Vec2(1, 1);
	tipLb.scaleX = 1 / SS;
	tipLb.scaleY = 1 / SS;
	tipLb.position = Vec2(SAY.x + SAY.w - 22, H - (SAY.y + SAY_H - 16));
	tipLb.text = '点击继续';
	tipLb.addTo(sayGroup);

	/* ---------- 状态机 ---------- */
	const S_IN = 0;
	const S_TYPE = 1;
	const S_HOLD = 2;
	const S_NEXT = 3;
	const S_OUT = 4;
	const S_DONE = 5;

	let st = S_IN;
	let t = 0;
	let idx = -1;
	let target = '';
	let shown = 0;
	let fxCur: Node.Type | undefined = undefined;
	let pageT = 0;

	const total = opts.lines.length;

	const setFx = (fx?: string): void => {
		fxCur = undefined;
		fxNodes.forEach((f) => {
			if (fx !== undefined && f.name === fx) {
				f.node.visible = true;
				f.node.opacity = 0;
				fxCur = f.node;
				if (rulerLine !== undefined && f.node === fxRuler) { rulerLine.size = Size(0, 3); }
			} else {
				f.node.visible = false;
				f.node.opacity = 0;
			}
		});
	};

	const seqText = (i: number): string => {
		const a = i + 1;
		return (a < 10 ? '0' : '') + a + ' / ' + (total < 10 ? '0' : '') + total;
	};

	const startLine = (i: number): void => {
		idx = i;
		const L = opts.lines[i];
		target = L.text;
		shown = 0;
		layoutLine(target);
		showChars(0);
		setTxOpacity(0);
		seqLb.text = seqText(i);
		setFx(L.fx);
		setFace(L.ex);
		t = 0;
		st = S_TYPE;
	};

	const advance = (): void => {
		// 有说明卡开着：先关卡片，不推进对话
		if (openIdx >= 0) {
			toggleCard(openIdx);
			return;
		}
		if (st === S_TYPE) {
			// 正在打字：一次显示完整句
			shown = txCount;
			showChars(txCount);
			setTxOpacity(1);
			st = S_HOLD;
			return;
		}
		if (st === S_HOLD) {
			if (idx + 1 >= total) {
				st = S_OUT;
				t = 0;
				return;
			}
			st = S_NEXT;
			t = 0;
		}
	};

	const update = (dt: number): void => {
		t += dt;
		pageT += dt;

		// 王梓：打字时点头，停笔就回到几乎不可见的呼吸
		// 说话时点头 + 微微左右摆（HTML 的 talk 动画是 translateY + rotate + scale）
		const talking = st === S_TYPE;
		const bob = talking
			? Math.sin(pageT * 9.5) * 3.2
			: Math.sin(pageT * 1.57) * 2.4;
		const ang = talking ? Math.sin(pageT * 6.7) * 0.55 : 0;
		const sck = talking ? 1 + Math.sin(pageT * 6.7) * 0.008 : 1;
		for (let i = 0; i < faceSprites.length; i++) {
			faceSprites[i].position = Vec2(WZ_X + FACE_W / 2, WZ_Y + bob);
			faceSprites[i].angle = ang;
			faceSprites[i].scaleX = sck;
			faceSprites[i].scaleY = sck;
		}

		// 表情交叉淡入（约 0.16s）
		for (let i = 0; i < faceSprites.length; i++) {
			const want = (i === faceCur) ? 1 : 0;
			const cur = faceSprites[i].opacity;
			if (Math.abs(want - cur) > 0.01) {
				faceSprites[i].opacity = cur + (want - cur) * Math.min(1, dt * 9);
			} else {
				faceSprites[i].opacity = want;
			}
		}

		// 说明卡：0.18s 淡入 + 从下往上浮 10px
		if (openIdx >= 0 && cardAnim < 1) {
			cardAnim = Math.min(1, cardAnim + dt * 7.5);
			const e = 1 - Math.pow(1 - cardAnim, 3);
			cardNodes[openIdx].opacity = e;
			cardNodes[openIdx].position = Vec2(0, -10 * (1 - e));
		}

		// 涟漪推进
		for (let i = ripples.length - 1; i >= 0; i--) {
			const r = ripples[i];
			r.t += dt;
			const p = Math.min(1, r.t / r.dur);
			const d = r.d0 + (r.d1 - r.d0) * p;
			r.s.size = Size(d, d);
			r.s.opacity = 1 - p;
			if (p >= 1) {
				r.s.removeFromParent();
				ripples.splice(i, 1);
			}
		}

		if (st === S_IN) {
			/* 分层入场：整体先亮，四组各自落位。
			   不用分组的 opacity——实测 Node 的 opacity 没有可靠地级联给子 Sprite，
			   而 position 一定级联，所以分层全靠位移做。 */
			introT += dt;
			layer.opacity = Math.min(1, introT / 0.26);

			const ease = (t0: number, dur: number): number => {
				const k = Math.min(1, Math.max(0, (introT - t0) / dur));
				return 1 - Math.pow(1 - k, 3);
			};

			// 透明 + 位移一起做：位移给「落下来」的劲，透明给「显影」的分寸
			const aH = ease(0.04, 0.42);
			headGroup.opacity = aH;
			headGroup.position = Vec2(0, 16 * (1 - aH));

			const aS = ease(0.14, 0.62);
			sceneGroup.opacity = aS;
			sceneGroup.position = Vec2(0, -22 * (1 - aS));

			const aW = ease(0.34, 0.58);
			faceGroup.opacity = aW;
			faceGroup.position = Vec2(72 * (1 - aW), 0);

			const aD = ease(0.56, 0.58);
			sayGroup.opacity = aD;
			sayGroup.position = Vec2(0, -52 * (1 - aD));

			if (introT >= 1.32) {
				headGroup.position = Vec2(0, 0);
				sceneGroup.position = Vec2(0, 0);
				faceGroup.position = Vec2(0, 0);
				sayGroup.position = Vec2(0, 0);
				headGroup.opacity = 1;
				sceneGroup.opacity = 1;
				faceGroup.opacity = 1;
				sayGroup.opacity = 1;
				startLine(opts.startAt !== undefined ? opts.startAt : 0);
			}

		} else if (st === S_TYPE) {
			layer.opacity = 1;
			setTxOpacity(Math.min(1, t / FADE_IN_LINE));
			// 一个字一个字地「点亮」：只切 visible，不重建纹理
			const n = Math.min(txCount, Math.max(0, Math.floor((t - 0.14) / CPS)));
			if (n > shown) {
				shown = n;
				showChars(n);
			}
			if (t > 0.14 && shown >= txCount) {
				showChars(txCount);
				st = S_HOLD;
			}

		} else if (st === S_HOLD) {
			layer.opacity = 1;
			setTxOpacity(1);

		} else if (st === S_NEXT) {
			setTxOpacity(Math.max(0, 1 - t / FADE_OUT_LINE));
			if (t >= FADE_OUT_LINE) { startLine(idx + 1); }

		} else if (st === S_OUT) {
			layer.opacity = Math.max(0, 1 - t / FADE_OUT_ALL);
			if (t >= FADE_OUT_ALL) {
				st = S_DONE;
				opts.onFinish();
			}
		}

		// 标注淡入（量尺同时从左往右生长）
		if (fxCur !== undefined && fxCur.opacity < 1) {
			fxCur.opacity = Math.min(1, fxCur.opacity + dt * 2.6);
			if (rulerLine !== undefined && fxCur === fxRuler) {
				rulerLine.size = Size(920 * fxCur.opacity, 3);
			}
		}

		// 标点呼吸（三个错开相位）
		for (let i = 0; i < spotDots.length; i++) {
			const k = 1 + Math.sin(pageT * 2.2 + i * 1.4) * 0.12;
			spotDots[i].scaleX = k;
			spotDots[i].scaleY = k;
		}
	};

	const destroy = (): void => { layer.removeFromParent(); };

	// 测试用：跳过整段对话，直接结束（下一段由 onFinish 接）
	const skip = (): void => {
		if (st === S_DONE) { return; }
		st = S_DONE;
		layer.opacity = 0;
		opts.onFinish();
	};

	return {
		next: (): void => { advance(); },
		tapAt: (x: number, y: number): boolean => tapAt(x, y),
		update: (dt: number): void => { update(dt); },
		destroy: (): void => { destroy(); },
		isFinished: (): boolean => st === S_DONE,
		skip: (): void => { skip(); },
	};
}
