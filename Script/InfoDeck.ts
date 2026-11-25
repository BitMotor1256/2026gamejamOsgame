// PPT 式补充科普页：左侧大数字卡 + 右侧标题/正文/出处 + 王梓 + 对白条 + 页码
// 版式取自 03-界面与版式/科普-PPT示例.html（1280×800，画布高 804）
//
// 和对话页对齐过的几件事：
//   1. 字体超采样（字号 ×SS 建、scale 1/SS 缩回）——不这么做缩放后小字发虚
//   2. Sprite.color 的 alpha 不生效，半透明一律走 opacity
//   3. 底部流程条已删（关前页也删了，两页要一致）
//   4. 王梓用 face_* 表情，不再用旧的 wangzi.png
//   5. 换页有淡入 + 上浮
import {
	Color,
	Label,
	Node,
	Size,
	Sprite,
	Vec2,
} from 'Dora';
import { SlideData } from 'Script/Story';

const W = 1280;
const H = 804;
const REG = 'Font/SourceHanSerifSC-Regular.ttf';
const MED = 'Font/SourceHanSerifSC-Medium.ttf';
const BOLD = 'Font/SourceHanSerifSC-SemiBold.ttf';

const C_PAPER = Color(233, 223, 196, 255);
const C_CARD = Color(252, 247, 232, 255);
const C_INK = Color(36, 73, 70, 255);
const C_VERM = Color(163, 59, 42, 255);
const C_MUTE = Color(76, 99, 87, 255);
/* 墨色叠在纸色上的等价色：投影用它才够实，又不会死黑 */
const C_SHADOW = Color(58, 88, 83, 255);

/* 数字卡 */
const PANEL = { x: 56, y: 126, w: 444, h: 500 };
/* 右栏 */
const COL_X = 540;
const COL_W = 540;
/* 对白条 */
const SAY = { x: 540, y: 466, w: 378, h: 128 };

/* 王梓的八套表情（和对话页同源同尺寸） */
const FACE_LIST: string[] = ['smile', 'laugh', 'dot', 'wave', 'curvy', 'shy', 'shyact', 'dizzy'];
const FACE_W = 250;
const FACE_H = 344;
const WZ_X = W - 14 - FACE_W;
const WZ_Y = 34;

export function startDeck(
	root: Node.Type,
	header: string,
	slides: SlideData[],
	onFinish: () => void,
) {
	const layer = Node();
	layer.anchor = Vec2(0, 0);
	layer.size = Size(W, H);
	layer.position = Vec2(0, 0);
	layer.addTo(root);

	// 超采样倍数。大字号（>80）不超采样——字够大，且 300px 级的 SDF 字形容易被图集装不下。
	const SS = 2;

	/* 纯色块（white.png 染色），alpha 走 opacity */
	const block = (
		x: number, y: number, w: number, h: number, c: Color.Type, alpha = 1,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.anchor = Vec2(0.5, 0.5);
		s.size = Size(w, h);
		s.color = c;
		s.opacity = alpha;
		s.position = Vec2(x + w / 2, H - (y + h / 2));
		s.addTo(layer);
		return s;
	};

	/* 文字工厂：左上角定位，小字号自动超采样 */
	const text = (
		font: string, size: number, color: Color.Type,
		x: number, y: number, width: number, gap: number,
	): Label.Type => {
		const k = size < 80 ? SS : 1;
		const lb = Label(font + ';' + Math.round(size * k) + ';true')!;
		lb.color = color;
		if (width > 0) {
			lb.textWidth = width * k;
			lb.lineGap = gap * k;
		}
		lb.anchor = Vec2(0, 1);
		lb.scaleX = 1 / k;
		lb.scaleY = 1 / k;
		lb.position = Vec2(x, H - y);
		lb.addTo(layer);
		return lb;
	};

	/* ---------- 静态版式 ---------- */
	block(0, 0, W, H, C_PAPER);

	const grain = Sprite('Image/StartUI/paper_grain.png')!;
	grain.anchor = Vec2(0, 1);
	grain.size = Size(W, H);
	grain.position = Vec2(0, H);
	grain.addTo(layer);

	// 顶部横线 + 页眉
	block(56, 44, W - 112, 1.5, C_INK, 0.69);
	const hdL = text(REG, 17, C_MUTE, 56, 56, 700, 0);
	hdL.text = header;
	hdL.spacing = 2;

	const hdR = Label(REG + ';' + Math.round(15 * SS) + ';true')!;
	hdR.color = C_MUTE;
	hdR.anchor = Vec2(1, 1);
	hdR.scaleX = 1 / SS;
	hdR.scaleY = 1 / SS;
	hdR.position = Vec2(W - 56, H - 54);
	hdR.addTo(layer);

	// 页码菱形（两个，右上）
	const dotA = block(W - 76, 78, 7, 7, C_VERM);
	dotA.angle = 45;
	const dotB = block(W - 56, 78, 7, 7, C_INK, 0.35);
	dotB.angle = 45;

	// 数字卡：实心投影 → 描边 → 卡面
	block(PANEL.x + 9, PANEL.y + 9, PANEL.w, PANEL.h, C_SHADOW);
	block(PANEL.x - 3, PANEL.y - 3, PANEL.w + 6, PANEL.h + 6, C_INK);
	block(PANEL.x, PANEL.y, PANEL.w, PANEL.h, C_CARD);

	// 大数字（卡内水平居中，不超采样）
	// 172px 的 SDF 字形撑不住，会糊成一团红。这个字号关掉 sdf 走原生位图，
	// 按显示尺寸直接光栅化，反而锐利（而且不需要超采样）。
	const numLb = Label(BOLD + ';172;false')!;
	numLb.color = C_VERM;
	numLb.anchor = Vec2(0.5, 1);
	numLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 322);
	numLb.addTo(layer);

	// 单位
	const unitLb = Label(REG + ';' + Math.round(22 * SS) + ';true')!;
	unitLb.color = C_INK;
	unitLb.anchor = Vec2(0.5, 1);
	unitLb.scaleX = 1 / SS;
	unitLb.scaleY = 1 / SS;
	unitLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 500);
	unitLb.addTo(layer);

	// 标题 / 正文 / 出处
	const ttlLb = text(BOLD, 33, C_INK, COL_X, 134, COL_W, 14);
	const bodyLb = text(MED, 21, C_INK, COL_X, 232, COL_W, 18);
	const srcLb = text(REG, 14, C_MUTE, 56, 648, 444, 6);

	/* ---------- 王梓：八套表情叠在同一位置 ---------- */
	const faces: Sprite.Type[] = [];
	for (let i = 0; i < FACE_LIST.length; i++) {
		const sp = Sprite('Image/StartUI/face_' + FACE_LIST[i] + '.png')!;
		sp.anchor = Vec2(0.5, 0);
		sp.size = Size(FACE_W, FACE_H);
		sp.position = Vec2(WZ_X + FACE_W / 2, WZ_Y);
		sp.opacity = (i === 0) ? 1 : 0;
		sp.addTo(layer);
		faces.push(sp);
	}
	let faceCur = 0;
	let pageT = 0;

	// 对白条：实心投影 → 描边 → 卡面
	block(SAY.x + 6, SAY.y + 6, SAY.w, SAY.h, C_SHADOW);
	block(SAY.x - 2.5, SAY.y - 2.5, SAY.w + 5, SAY.h + 5, C_INK);
	block(SAY.x, SAY.y, SAY.w, SAY.h, C_CARD);

	const whoLb = text(MED, 14, C_MUTE, SAY.x + 22, SAY.y + 28, 200, 0);
	whoLb.text = '王 梓';
	whoLb.spacing = 6;

	// Dora 的汉字步进约 0.72em（HTML 是 1em），折行宽度按这个比例折算，
	// 否则同样的宽度能多塞四成字，台词会顶出对白条。
	const sayLb = text(MED, 23, C_INK, SAY.x + 22, SAY.y + 68, (SAY.w - 44) * 0.72, 13);

	const tipLb = Label(REG + ';' + Math.round(15 * SS) + ';true')!;
	tipLb.color = C_INK;
	tipLb.anchor = Vec2(1, 1);
	tipLb.scaleX = 1 / SS;
	tipLb.scaleY = 1 / SS;
	tipLb.position = Vec2(SAY.x + SAY.w - 18, H - (SAY.y + SAY.h - 16));
	tipLb.opacity = 0.6;
	tipLb.text = '点击继续';
	tipLb.addTo(layer);

	/* ---------- 换页 ---------- */
	let idx = -1;
	let fadeT = 0;
	let finished = false;

	const total = slides.length;

	// 换页时正文整体往上浮一点 + 淡入
	const pageNodes: Node.Type[] = [];
	const regPage = (n: Node.Type): void => { pageNodes.push(n); };
	regPage(numLb);
	regPage(unitLb);
	regPage(ttlLb);
	regPage(bodyLb);
	regPage(srcLb);
	regPage(sayLb);

	const setFace = (name?: string): void => {
		const k = name === undefined ? 0 : FACE_LIST.indexOf(name);
		faceCur = k >= 0 ? k : 0;
	};

	const show = (i: number): void => {
		const s = slides[i];
		numLb.text = s.num;
		unitLb.text = s.unit;
		ttlLb.text = s.title;
		bodyLb.text = s.body;
		srcLb.text = s.src;
		sayLb.text = s.say;
		hdR.text = (i + 1 < 10 ? '0' : '') + (i + 1) + ' / ' + (total < 10 ? '0' : '') + total;
		dotA.color = i === 0 ? C_VERM : C_INK;
		dotA.opacity = i === 0 ? 1 : 0.35;
		dotB.color = i === 1 ? C_VERM : C_INK;
		dotB.opacity = i === 1 ? 1 : 0.35;
		setFace(i === 0 ? 'dot' : 'smile');
		fadeT = 0;
	};

	// 测试用：跳过剩下所有页
	const skip = (): void => {
		if (finished) { return; }
		finished = true;
		onFinish();
	};

	const next = (): void => {
		if (finished) { return; }
		idx++;
		if (idx >= total) {
			finished = true;
			onFinish();
			return;
		}
		show(idx);
	};

	const update = (dt: number): void => {
		pageT += dt;

		// 换页淡入 + 上浮
		if (fadeT < 1) {
			fadeT = Math.min(1, fadeT + dt * 5);
			const e = 1 - Math.pow(1 - fadeT, 3);
			for (const n of pageNodes) { n.opacity = e; }
			const dy = -12 * (1 - e);
			numLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 322 + dy);
			unitLb.position = Vec2(PANEL.x + PANEL.w / 2, H - 500 + dy);
		}

		// 王梓：静立呼吸
		const bob = Math.sin(pageT * 1.57) * 2.4;
		for (let i = 0; i < faces.length; i++) {
			faces[i].position = Vec2(WZ_X + FACE_W / 2, WZ_Y + bob);
			const want = (i === faceCur) ? 1 : 0;
			const cur = faces[i].opacity;
			if (Math.abs(want - cur) > 0.01) {
				faces[i].opacity = cur + (want - cur) * Math.min(1, dt * 9);
			} else {
				faces[i].opacity = want;
			}
		}
	};

	const destroy = (): void => { layer.removeFromParent(); };

	next();

	return {
		next: (): void => { next(); },
		update: (dt: number): void => { update(dt); },
		destroy: (): void => { destroy(); },
		isFinished: (): boolean => finished,
		skip: (): void => { skip(); },
	};
}
