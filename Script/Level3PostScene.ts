// 第三关 · 关后科普页
// 版式对齐 03-界面与版式/第三关-科普页.html：页眉 / 场景图(带「图一」角标) /
// 按句切换的朱红标注 / 对白条(打字机) / 右侧王梓表情。
//
// 和第二关那页（Level2PostScene）是同一套骨架，三处不同：
//   ① 台词 9 句、最长 41 字 → 正文要换行，逐字 Label 按「行×列」排位
//   ② 标注 5 组（gate/main/field/cut/wall），每组带一句小字
//   ③ 场景图换成城北水田
//
// 引擎限制照旧：椭圆圈画不了用方框、虚线箭头用短折线拼。
import { Color, Director, KeyName, Label, Node, Size, Sprite, Vec2 } from 'Dora';
import { H, createSceneFrame } from 'Script/SceneFrame';

const W = 1280;
const S = 'Image/StartUI/';
const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

const C_PAGE = Color(207, 196, 166, 255);
const C_CARD = Color(252, 247, 232, 255);
const C_INK = Color(36, 73, 70, 255);
const C_INK2 = Color(76, 99, 87, 255);
const C_VERM = Color(163, 59, 42, 255);
const C_TXT = Color(142, 46, 31, 255);

type PostLine = { t: string; mark: string; face: string };

/* 台词：06/07/08 是台词本原文，其余是为「接上一局 / 补史实」扩写的，讲解面板里有归属 */
const LINES: PostLine[] = [
	{ t: '这座城是嘉靖三十八年修完的。修了十一个月，花了七千多两，钱是王家自己卖田凑的。', mark: '', face: 'dot' },
	{ t: '刚才那道闸，上头是桥，人从桥上过。闸板藏在桥底下，平时看不见。', mark: 'gate', face: 'wave' },
	{ t: '水从城外进来，过水门，落进中间这条渠。', mark: 'main', face: 'dot' },
	{ t: '这条渠再往两边分，一条小渠管几块田，水就这么一路送到田口。', mark: '', face: 'curvy' },
	{ t: '围城能撑住，靠的不是墙高，是有粮。', mark: 'field', face: 'dot' },
	{ t: '堡里留了一百多亩水田。真被围起来，外头的粮一粒也进不来，就靠这些田自己种、自己收。', mark: 'field', face: 'dot' },
	{ t: '最怕的不是敌人打进来，是还没打，自己先撑不住。', mark: 'cut', face: 'dot' },
	{ t: '倭寇也来过。有一回站在城外看了半晌，看见田是绿的、人还在忙，就退了。', mark: 'wall', face: 'curvy' },
	{ t: '田看完了，我接下来带你看看敌台。', mark: '', face: 'wave' },
];

export function startLevel3Post(onDone: () => void, startAt?: number): PostLineScene {
	Director.clearColor = C_PAGE;
	const frame = createSceneFrame(0.18);   // 这页没有 HUD，允许上下裁 18%
	const root = frame.inner;

	/* ── 小工具：一律「左上原点、Y 向下」 ── */
	const block = (
		p: Node.Type, x: number, y: number, w: number, h: number,
		c: Color.Type, a: number,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		s.color = c;
		s.opacity = a;
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
	// Dora 的 string 是 UTF-8 字节串：逐字拆必须按首字节判断长度
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

	/* ══════════ 纸底 + 页眉 ══════════ */
	img(root, S + 'lv2_paper.png', 0, 0, W, H + 4);   // 网点纸（和另外两关共用）
	block(root, 56, 44, W - 112, 1.5, C_INK, 0.55);
	const hd = label(root, FONT_B, 18, C_INK2, 56, 68, 0, 0.4);
	hd.text = '三 · 引流　关后';

	/* ══════════ 场景图 ══════════ */
	const SC_X = 120, SC_Y = 104, SC_W = 1040, SC_H = 330;
	block(root, SC_X + 9, SC_Y + 9, SC_W, SC_H, C_INK, 0.9);
	img(root, S + 'lv3_post_scene.png', SC_X, SC_Y, SC_W, SC_H);
	block(root, SC_X, SC_Y, SC_W, 3, C_INK, 1);
	block(root, SC_X, SC_Y + SC_H - 3, SC_W, 3, C_INK, 1);
	block(root, SC_X, SC_Y, 3, SC_H, C_INK, 1);
	block(root, SC_X + SC_W - 3, SC_Y, 3, SC_H, C_INK, 1);
	block(root, SC_X - 3, SC_Y - 3, 74, 30, C_VERM, 1);
	label(root, FONT_B, 17, C_CARD, SC_X + 14, SC_Y + 24, 0, 1.6).text = '图一';

	/* ══════════ 标注：按句切换 ══════════
	   坐标全部按「场景图内」给（和 HTML 一致），函数里统一加 SC_X / SC_Y。
	   不包父容器：之前用容器包过一层，子节点坐标变成相对容器，全跑出界。 */
	const markKeys = ['gate', 'main', 'field', 'cut', 'wall'];
	const marks: Record<string, Node.Type[]> = { gate: [], main: [], field: [], cut: [], wall: [] };
	const mk = (k: string, n: Node.Type): void => { marks[k].push(n); };

	const mBlock = (k: string, x: number, y: number, w: number, h: number, c: Color.Type, al: number): Sprite.Type => {
		const sp = block(root, SC_X + x, SC_Y + y, w, h, c, al);
		mk(k, sp);
		return sp;
	};
	const mFrame = (k: string, x: number, y: number, w: number, h: number, al: number): void => {
		mBlock(k, x, y, w, 3, C_VERM, al);
		mBlock(k, x, y + h - 3, w, 3, C_VERM, al);
		mBlock(k, x, y, 3, h, C_VERM, al);
		mBlock(k, x + w - 3, y, 3, h, C_VERM, al);
	};
	// 朱红标签：大字 + 一行小字，宽度按字数估（Dora 没有 measure）
	const mTip = (k: string, x: number, y: number, str: string, sub: string): void => {
		const mainW = toChars(str).length * 23;
		const subW = sub.length > 0 ? toChars(sub).length * 16 + 12 : 0;
		const w = 18 + mainW + subW + 18;
		mBlock(k, x - 4, y - 4, w + 8, 50, C_INK, 0.88);
		mBlock(k, x, y, w, 42, C_CARD, 0.99);
		mFrame(k, x, y, w, 42, 1);
		const lb = label(root, FONT_B, 22, C_TXT, SC_X + x + 16, SC_Y + y + 32, 0, 0.4);
		lb.text = str;
		mk(k, lb);
		if (sub.length > 0) {
			const sb = label(root, FONT_R, 15, Color(76, 99, 87, 230), SC_X + x + 16 + mainW + 12, SC_Y + y + 31, 0, 0.2);
			sb.text = sub;
			mk(k, sb);
		}
	};

	// ① 水门：桥在上，闸在下
	mFrame('gate', 544, 36, 160, 100, 1);
	mBlock('gate', 566, 96, 112, 7, C_VERM, 1);          // 闸板横杠
	mTip('gate', 336, 56, '桥在上，闸在下', '同一个门洞');

	// ② 中间这条渠
	mFrame('main', 594, 104, 64, 120, 1);
	mTip('main', 668, 116, '水就落在这条渠里', '从水门直贯到底');

	// ③ 八块田（左右各一大框，盖住整片田区）
	mFrame('field', 114, 144, 390, 170, 1);
	mFrame('field', 514, 144, 398, 170, 1);
	mTip('field', 138, 112, '八块田，一百多亩', '一年两季');

	// ④ 闸下那一条渠
	mFrame('cut', 594, 104, 64, 150, 1);
	mTip('cut', 676, 190, '就这一条渠', '闸一落，水也断');

	// ⑤ 城头：站这儿往下看
	mFrame('wall', 96, 70, 300, 44, 1);
	mTip('wall', 96, 18, '站这儿往下看', '田是绿的，人还在忙');

	for (const k of markKeys) { for (const sp of marks[k]) { sp.visible = false; } }

	/* ══════════ 对白条 ══════════ */
	const SAY_X = 120, SAY_Y = 530, SAY_W = 744, SAY_H = 172;
	block(root, SAY_X + 7, SAY_Y + 7, SAY_W, SAY_H, C_INK, 0.94);
	block(root, SAY_X, SAY_Y, SAY_W, SAY_H, C_CARD, 1);
	block(root, SAY_X, SAY_Y, SAY_W, 2.5, C_INK, 1);
	block(root, SAY_X, SAY_Y + SAY_H - 2.5, SAY_W, 2.5, C_INK, 1);
	block(root, SAY_X, SAY_Y, 2.5, SAY_H, C_INK, 1);
	block(root, SAY_X + SAY_W - 2.5, SAY_Y, 2.5, SAY_H, C_INK, 1);

	block(root, 136, 509, 96, 34, C_VERM, 1);
	label(root, FONT_B, 17, C_CARD, 184, 535, 0.5, 4.2).text = '王 梓';

	/* 正文：逐字常驻 Label + 手工换行。
	   最长一句 41 字，26 字/行 → 最多两行；按 26×3 备着，够用。
	   每帧改一整块 Label 的 text 会重建纹理，打字过程中字会抖（Dialogue.ts 踩过）。 */
	const TX_SIZE = 32, TX_STEP = TX_SIZE * 0.78 + 1, TX_LINE = TX_SIZE + 14;
	const TX_COLS = Math.floor((SAY_W - 68) / TX_STEP);
	const TX_N = TX_COLS * 3;
	const txChars: Label.Type[] = [];
	for (let i = 0; i < TX_N; i++) {
		const lb = label(root, FONT_R, TX_SIZE, C_INK, 156, 610, 0, 0.4);
		lb.visible = false;
		txChars.push(lb);
	}
	const seqLb = label(root, FONT_R, 15, Color(76, 99, 87, 190), 842, 548, 1, 0);
	const tipLb = label(root, FONT_R, 16, Color(36, 73, 70, 175), 842, 690, 1, 0);
	tipLb.text = '点击继续　P 跳过';

	const cap = label(root, FONT_R, 16, Color(76, 99, 87, 210), 756, 462, 1, 0.6);
	cap.text = '永昌堡 · 城北水田（示意）';

	block(root, 0, 700, W, 1.5, C_INK, 0.5);
	const foot = label(root, FONT_R, 13, Color(36, 73, 70, 120), 120, 742, 0, 1.2);
	foot.text = '永昌堡 · 嘉靖四十年 · 五月 · 夜尽';

	/* ══════════ 王梓：五种表情叠着切 ══════════ */
	const WZ_X = 1030, WZ_Y = 404, WZ_W = 250, WZ_H = 344;
	const faces: Record<string, Sprite.Type> = {};
	for (const n of ['smile', 'laugh', 'dot', 'wave', 'curvy']) {
		const sp = img(root, S + 'face_' + n + '.png', WZ_X, WZ_Y, WZ_W, WZ_H);
		sp.visible = false;
		faces[n] = sp;
	}

	/* ══════════ 台词推进 ══════════ */
	let idx = -1;
	let typed = 0;
	let textLen = 0;
	let typing = false;
	let done = false;
	let state = 0;
	let time = 0;
	let born = 0;

	const showLine = (i: number): void => {
		idx = i;
		typed = 0;
		typing = true;
		const L = LINES[i];
		const chars = toChars(L.t);
		textLen = Math.min(TX_N, chars.length);
		for (let n = 0; n < TX_N; n++) {
			const lb = txChars[n];
			if (n < textLen) {
				const col = n % TX_COLS;
				const row = Math.floor(n / TX_COLS);
				lb.text = chars[n];
				lb.position = Vec2(156 + col * TX_STEP, H - (610 + row * TX_LINE) + TX_SIZE);
				lb.visible = false;
			} else {
				lb.visible = false;
			}
		}
		const a = i + 1;
		seqLb.text = (a < 10 ? '0' : '') + a + ' / ' + LINES.length.toString();
		for (const k of markKeys) {
			const on = (k === L.mark);
			for (const sp of marks[k]) { sp.visible = on; }
		}
		for (const k in faces) { faces[k].visible = (k === L.face); }
		tipLb.text = (i === LINES.length - 1) ? '点击收尾　P 跳过' : '点击继续　P 跳过';
	};

	const finishTyping = (): void => {
		typing = false;
		typed = textLen;
		for (let n = 0; n < textLen; n++) { txChars[n].visible = true; }
	};

	const endAll = (): void => {
		if (state >= 2) { return; }
		state = 2;
		frame.destroy();
		onDone();
	};

	const tap = (): void => {
		if (state !== 0) { return; }
		if (idx < 0) { showLine(0); return; }
		if (typing) { finishTyping(); return; }
		if (idx + 1 < LINES.length) { showLine(idx + 1); return; }
		if (!done) { done = true; endAll(); }
	};

	frame.input.onTapped((): boolean => { tap(); return true; });

	showLine(startAt !== undefined ? startAt : 0);
	state = 0;

	root.onKeyDown((key: KeyName): boolean => {
		if (key === KeyName.P) {
			if (born < 0.35) { return true; }   // 吃掉「切进本页」的那一次按键
			endAll();
			return true;
		}
		if (key === KeyName.Space || key === KeyName.Return) { tap(); return true; }
		return false;
	});

	/* ══════════ 每帧 ══════════ */
	const update = (dt: number): void => {
		time += dt;
		born += dt;
		const bob = Math.sin(time * 1.5) * 2.4;
		const sway = typing ? Math.sin(time * 11) * 1.1 : 0;
		for (const k in faces) {
			const sp = faces[k];
			if (!sp.visible) { continue; }
			sp.position = Vec2(WZ_X + sway, H - WZ_Y + bob);
		}
		if (!typing || idx < 0) { return; }
		typed += dt * 31;                  // 每字约 31ms，对齐 HTML 的 CPS=32
		if (typed >= textLen) { finishTyping(); return; }
		const n = Math.floor(typed);
		for (let k = 0; k < n; k++) { txChars[k].visible = true; }
	};
	root.schedule((dt: number): boolean => { update(dt); return false; });

	return {
		root: root,
		close: (): void => { frame.destroy(); },
		isDone: (): boolean => state === 2,
	};
}

export type PostLineScene = {
	root: Node.Type;
	close: () => void;
	isDone: () => boolean;
};
