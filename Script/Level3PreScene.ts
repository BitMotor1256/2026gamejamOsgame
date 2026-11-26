// 第三关 · 关前页（田与水）
// 版式对齐 03-界面与版式/第二关-关后页.html：页眉 / 场景图(带「图一」角标) /
// 按句切换的朱红标注 / 对白条(打字机) / 右侧王梓表情。
//
// 两处和 HTML 不同，都是引擎限制：
//   ① 椭圆圈画不了 → 用方框（第一关的标注本来就多用方框，风格不违和）
//   ② 虚线弧箭头画不了 → 用时短折线 + 箭头两条斜线拼
//
// 坐标一律用 HTML 那套「左上原点、Y 向下」，换算集中在 place() 里，别散落。
import { Color, Director, KeyName, Label, Node, Size, Sprite, Vec2, View } from 'Dora';
import { H, createSceneFrame } from 'Script/SceneFrame';

const W = 1280;
const S = 'Image/StartUI/';
const FONT_R = 'Font/SourceHanSerifSC-Regular.ttf';
const FONT_B = 'Font/SourceHanSerifSC-SemiBold.ttf';

const C_PAGE = Color(207, 196, 166, 255);   // 舞台外的页面色
const C_CARD = Color(252, 247, 232, 255);
const C_INK = Color(36, 73, 70, 255);
const C_INK2 = Color(76, 99, 87, 255);
const C_VERM = Color(163, 59, 42, 255);

type PostLine = { t: string; mark: string; face: string };

/* 台词：11–13 是台词本原文；中间三段是为「演示」补的过渡，讲解面板里已标注 */
const LINES: PostLine[] = [
	{ t: '这就是他们的田。堡里留了一百多亩。', mark: 'field', face: 'wave' },
	{ t: '水从城外河里来，过水门，进城里两条河，再流到田里。', mark: 'flow', face: 'curvy' },
	{ t: '门洞上头架着石桥，人从桥上过。闸板藏在桥底下。', mark: 'bridge', face: 'dot' },
	{ t: '闸一落，敌船进不来。可自家的水，也进不来了。', mark: 'gate', face: 'dot' },
	{ t: '平时闸开着。两条河的水进城，再分十条支渠，一块田一块田地淌过去。', mark: 'eight', face: 'curvy' },
	{ t: '这些田，一年能收两季。真围起来，全城就指着它。', mark: 'field2', face: 'dot' },
	{ t: '围城的时候，闸得一直关着。城里的水只出不进。', mark: 'gate', face: 'curvy' },
	{ t: '八块田都要灌，但怎么灌是个问题。', mark: 'eight', face: 'curvy' },
	{ t: '来试试。水头不听你的，它只会一直往前。', mark: '', face: 'wave' },
];

export function startLevel3Pre(onDone: () => void): Level3PreScene {
	Director.clearColor = C_PAGE;
	// 保留页边和画框（和另外几关一致）：fit / 输入区 / 切场景清理都交给 SceneFrame
	// 允许上下裁 18%：这页没有 HUD，顶到页眉(44)底到落款(764)都还有余量，
	// 不裁的话窗口一扁，卡片就只有一半宽，跟原型差太远。
	const frame = createSceneFrame(0.18);
	const root = frame.inner;

	/* ── 小工具：一律「左上原点、Y 向下」 ── */
	const place = (n: Node.Type, x: number, y: number): void => {
		n.position = Vec2(x, H - y);
	};
	const block = (
		p: Node.Type, x: number, y: number, w: number, h: number,
		c: Color.Type, a: number,
	): Sprite.Type => {
		const s = Sprite('Image/StartUI/white.png')!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		s.color = c;
		s.opacity = a;
		place(s, x, y);
		s.addTo(p);
		return s;
	};
	const img = (p: Node.Type, f: string, x: number, y: number, w: number, h: number): Sprite.Type => {
		const s = Sprite(f)!;
		s.size = Size(w, h);
		s.anchor = Vec2(0, 1);
		place(s, x, y);
		s.addTo(p);
		return s;
	};
	// anchor.y = 1 时 y 是「底边」，所以 position 要 +size 让字顶落在 y-size
	// Dora 的 string 是 UTF-8 字节串："图一".length 是 6 不是 2。
	// 逐字拆分必须按首字节判断长度，否则拿到的是半个汉字，Label 渲染不出来。
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
	img(root, S + 'lv3_post_scene.png', 0, 0, 1, 1).visible = false;   // 预热，避免首帧空
	// 纸底用已经烘好的 1280×800 网点纸
	img(root, S + 'lv2_paper.png', 0, 0, W, H + 4);

	block(root, 56, 44, W - 112, 1.5, C_INK, 0.55);
	const hd = label(root, FONT_B, 18, C_INK2, 56, 68, 0, 0.4);
	hd.text = '三 · 引流　关前';


	/* ══════════ 场景图 ══════════ */
	const SC_X = 120, SC_Y = 104, SC_W = 1040, SC_H = 330;
	block(root, SC_X + 9, SC_Y + 9, SC_W, SC_H, C_INK, 0.9);          // 硬投影
	img(root, S + 'lv3_post_scene.png', SC_X, SC_Y, SC_W, SC_H);
	// 边框 3
	block(root, SC_X, SC_Y, SC_W, 3, C_INK, 1);
	block(root, SC_X, SC_Y + SC_H - 3, SC_W, 3, C_INK, 1);
	block(root, SC_X, SC_Y, 3, SC_H, C_INK, 1);
	block(root, SC_X + SC_W - 3, SC_Y, 3, SC_H, C_INK, 1);
	// 「图一」角标
	block(root, SC_X - 3, SC_Y - 3, 74, 30, C_VERM, 1);
	const tag = label(root, FONT_B, 17, C_CARD, SC_X + 14, SC_Y + 24, 0, 1.6);
	tag.text = '图一';


	/* ══════════ 标注：按句切换显隐 ══════════ */
	// 每个标注挂在 sceneNode 上，坐标就是 HTML 里那套（相对 120,104）
	// 每个标注是一组 sprite，直接挂在 root 上、用绝对坐标。
	// 之前用父容器包了一层，子节点坐标就变成「相对容器」的，而我还按绝对写，全跑出界了。
	const marks: Record<string, Node.Type[]> = { field: [], field2: [], flow: [], bridge: [], gate: [], eight: [] };
	const markKeys = ['field', 'field2', 'flow', 'bridge', 'gate', 'eight'];
	const mkMark = (k: string, n: Node.Type): void => { marks[k].push(n); };

	// 标注的零件：坐标按「场景图内」给，函数里自动加 SC_X / SC_Y
	const mBlock = (k: string, x: number, y: number, w: number, h: number, c: Color.Type, al: number): Sprite.Type => {
		const sp = block(root, SC_X + x, SC_Y + y, w, h, c, al);
		mkMark(k, sp);
		return sp;
	};
	const mFrame = (k: string, x: number, y: number, w: number, h: number, al: number): void => {
		mBlock(k, x, y, w, 3, C_VERM, al);
		mBlock(k, x, y + h - 3, w, 3, C_VERM, al);
		mBlock(k, x, y, 3, h, C_VERM, al);
		mBlock(k, x + w - 3, y, 3, h, C_VERM, al);
	};
	const mTip = (k: string, x: number, y: number, str: string): void => {
		// str.length 是字节数（一个汉字 3 字节），必须按字数算宽，否则框会宽一倍
		const w = toChars(str).length * 24 + 34;
		mBlock(k, x - 4, y - 4, w + 8, 48, C_INK, 0.88);
		mBlock(k, x, y, w, 40, C_CARD, 0.99);
		mFrame(k, x, y, w, 40, 1);
		const lb = label(root, FONT_B, 22, Color(142, 46, 31, 255), SC_X + x + 18, SC_Y + y + 31, 0, 0.4);
		lb.text = str;
		mkMark(k, lb);
	};

	// 八块田的编号：朱红方块 + 白字（label 的 y 是底边，要 -8 让字落在块里）
	const mNum = (k: string, x: number, y: number, n: number): void => {
		mBlock(k, x - 13, y - 13, 26, 26, C_VERM, 1);
		mBlock(k, x - 13, y - 13, 26, 2, C_INK, 0.9);
		const lb = label(root, FONT_B, 15, C_CARD, SC_X + x, SC_Y + y + 7, 0.5, 0);
		lb.text = n.toString();
		mkMark(k, lb);
	};

	// ① 田：一百多亩
	mFrame('field', 28, 228, 430, 98, 1);
	mTip('field', 470, 250, '一百多亩');

	// ② 同一片田，第 6 句讲「一年两收」时复用框、换文字
	mFrame('field2', 28, 228, 430, 98, 1);
	mTip('field2', 470, 250, '一年两收');

	// ③ 水系：从城外河到田，用点阵画虚线（Dora 没有 SVG，画不了曲线和箭头）
	//    二次贝塞尔 P0(1014,70) P1(700,94) P2(620,146)
	for (let i = 0; i <= 12; i++) {
		const t = i / 12;
		const mt = 1 - t;
		const bx = mt * mt * 1014 + 2 * mt * t * 700 + t * t * 620;
		const by = mt * mt * 70 + 2 * mt * t * 94 + t * t * 146;
		mBlock('flow', bx - 3, by - 3, 6, 6, C_VERM, 0.85);
	}
	mBlock('flow', 614, 140, 13, 13, C_VERM, 1);   // 箭头尖
	mTip('flow', 52, 74, '水从城外河来');

	// ④ 石桥（第 3 句）
	mFrame('bridge', 536, 62, 170, 34, 1);
	mTip('bridge', 596, 172, '桥在上，闸在下');

	// ⑤ 水门闸（第 4、7 句）
	mFrame('gate', 566, 80, 108, 46, 1);
	mTip('gate', 600, 128, '闸一落');

	// ⑥ 八块田（第 5、8 句）
	mNum('eight', 300, 146, 1);
	mNum('eight', 736, 146, 2);
	mNum('eight', 250, 196, 3);
	mNum('eight', 786, 196, 4);
	mNum('eight', 186, 262, 5);
	mNum('eight', 850, 262, 6);
	mNum('eight', 126, 300, 7);
	mNum('eight', 910, 300, 8);
	mTip('eight', 404, 66, '八块田');

	// 建完先全隐，等 showLine 按句点亮
	for (const k of markKeys) { for (const sp of marks[k]) { sp.visible = false; } }

	/* ══════════ 对白条 ══════════ */
	const SAY_X = 120, SAY_Y = 530, SAY_W = 744, SAY_H = 172;
	block(root, SAY_X + 7, SAY_Y + 7, SAY_W, SAY_H, C_INK, 0.94);
	block(root, SAY_X, SAY_Y, SAY_W, SAY_H, C_CARD, 1);
	// 圆角画不了，用 4 条细边做「硬框」
	block(root, SAY_X, SAY_Y, SAY_W, 2.5, C_INK, 1);
	block(root, SAY_X, SAY_Y + SAY_H - 2.5, SAY_W, 2.5, C_INK, 1);
	block(root, SAY_X, SAY_Y, 2.5, SAY_H, C_INK, 1);
	block(root, SAY_X + SAY_W - 2.5, SAY_Y, 2.5, SAY_H, C_INK, 1);

	// 姓名牌
	block(root, 136, 509, 96, 34, C_VERM, 1);
	const pill = label(root, FONT_B, 15, C_CARD, 184, 534, 0.5, 4.2);
	pill.text = '王 梓';

	// 打字机不用「每帧改一个 Label 的 text」——那样每秒重建 31 次纹理，肉眼会闪。
	// 改成 32 个常驻 Label 各装一个字，打字时只切 visible，纹理一次建成不再动。
	// 字号按 Dora 的汉字步进（约 0.72em）补到 40，才对得上 HTML 的 31px。
	const TX_N = 32;
	const TX_SIZE = 32;
	const txChars: Label.Type[] = [];
	for (let i = 0; i < TX_N; i++) {
		const lb = label(root, FONT_R, TX_SIZE, C_INK, 156, 610, 0, 0.4);
		lb.visible = false;
		txChars.push(lb);
	}
	const seqLb = label(root, FONT_R, 15, Color(76, 99, 87, 190), 842, 548, 1, 0);
	const tipLb = label(root, FONT_R, 16, Color(36, 73, 70, 175), 842, 690, 1, 0);
	tipLb.text = '点击继续　P 跳过';

	// 场景说明（对白条右上方）
	const cap = label(root, FONT_R, 16, Color(76, 99, 87, 230), 756, 462, 1, 0.6);
	cap.text = '永昌堡 · 堡内水田（示意）';

	// 落款：HTML 在 764，但 cover 模式会裁掉画面上下各一截，提到 742 才在安全区内
	block(root, 0, 700, W, 1.5, C_INK, 0.5);
	const foot = label(root, FONT_R, 13, Color(36, 73, 70, 120), 120, 742, 0, 1.2);
	foot.text = '永昌堡 · 嘉靖四十年 · 五月 · 夜尽';

	/* ══════════ 王梓：四种表情叠着切 ══════════ */
	const WZ_X = 1030, WZ_Y = 404, WZ_W = 250, WZ_H = 344;
	const faces: Record<string, Sprite.Type> = {};
	for (const n of ['smile', 'laugh', 'dot', 'wave', 'curvy']) {
		const sp = img(root, S + 'face_' + n + '.png', WZ_X, WZ_Y, WZ_W, WZ_H);
		sp.visible = false;
		faces[n] = sp;
	}

	/* ══════════ 台词推进 ══════════ */
	let idx = -1;
	let typed = 0;          // 已经打出来的字数（浮点，按 dt 累加）
	let textLen = 0;        // 当前这句有多少个字（上限 TX_N）
	let typing = false;
	let done = false;

	const showLine = (i: number): void => {
		idx = i;
		typed = 0;
		typing = true;
		const L = LINES[i];
		// 换句：拆字 + 按实际字宽排位（一次算完），然后全部先藏起来
		const chars = toChars(L.t);
		let cx = 156;
		for (let n = 0; n < TX_N; n++) {
			const lb = txChars[n];
			if (n < chars.length) {
				lb.text = chars[n];
				lb.position = Vec2(cx, H - 610 + TX_SIZE);
				cx += TX_SIZE * 0.78 + 1;   // 汉字步进约 0.72em，留一点字距
				lb.visible = false;
			} else {
				lb.visible = false;
			}
		}
		textLen = Math.min(TX_N, chars.length);
		seqLb.text = (i + 1 < 10 ? '0' : '') + (i + 1 < 10 ? (i + 1) : (i + 1)) + ' / ' + LINES.length;
		// 标注切换
		for (const k of markKeys) {
			const on = (k === L.mark);
			for (const sp of marks[k]) { sp.visible = on; }
		}
		// 表情切换
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
		// 开场：第一次点击才开始（免得一进来就被误触跳过）
		if (idx < 0) { showLine(0); return; }
		if (typing) { finishTyping(); return; }
		if (idx + 1 < LINES.length) { showLine(idx + 1); return; }
		// 最后一句：收尾
		if (!done) { done = true; endAll(); }
	};

	let state = 0;   // 0 进行中 / 1 入场 / 2 结束
	let born = 0;    // 出生后多久：吃掉「创建它的那一次按键」，否则会连跳

	/* 输入：整页都能点 */
	frame.input.onTapped((): boolean => { tap(); return true; });

	/* 开场先给第一句（和 HTML 一致，进去就在打字） */
	// 后门：?line 不起作用，用常量直接定位要看的句子
	const _START = 5;
	showLine(_START - 1);
	state = 0;

	/* ══════════ 键盘 ══════════
	   科普页之前完全没接键盘，按 P 是没反应的。
	   P = 跳过整页（和对话/玩法里 P 的语义一致：「跳过」不是「暂停」）；
	   空格 / 回车 = 逐句推进，和点击等价。 */
	root.onKeyDown((key: KeyName): boolean => {
		if (key === KeyName.P) {
			if (born < 0.35) { return true; }   // 同一次按键不能既「进本页」又「跳过本页」
			endAll();
			return true;
		}
		if (key === KeyName.Space || key === KeyName.Return) { tap(); return true; }
		return false;
	});

	/* ══════════ 每帧：打字机 ══════════ */
	let acc = 0;
	let time = 0;
	const update = (dt: number): void => {
		time += dt;
		born += dt;
		// 立绘呼吸：和 HTML 的 float 4.2s / 2.4px 对齐
		const bob = Math.sin(time * 1.5) * 2.4;
		// 打字时轻微点头（HTML 是 talk 动画，56% 左右各晃一点）
		const sway = typing ? Math.sin(time * 11) * 1.1 : 0;
		for (const k in faces) {
			const sp = faces[k];
			if (!sp.visible) { continue; }
			sp.position = Vec2(WZ_X + sway, H - WZ_Y + bob);
		}
		if (!typing || idx < 0) { return; }
		typed += dt * 31;                 // 每字约 31ms，和 HTML 的 CPS=32 对齐
		if (typed >= textLen) { finishTyping(); return; }
		const n = Math.floor(typed);
		// 只点亮，不重建纹理
		for (let k = 0; k < n; k++) { txChars[k].visible = true; }
		acc += dt;
	};
	root.schedule((dt: number): boolean => { update(dt); return false; });

	return {
		root: root,
		close: (): void => { frame.destroy(); },
		isDone: (): boolean => state === 2,
	};
}

export type Level3PreScene = {
	root: Node.Type;
	close: () => void;
	isDone: () => boolean;
};

/* 第三关玩法还没做，关前页看完不能直接黑屏——给一个明确的落点 */
export function showLevel3Placeholder(back: () => void, sub = '玩法开发中'): void {
	Director.clearColor = Color(23, 51, 48, 255);
	// Director.ui 的原点在屏幕中心：anchor(0.5) + position(0,0) 才是居中（TitleScene 就是这么写的）。
	// 子节点坐标都是「相对中心」的偏移，正数向上。
	const r = Node();
	r.anchor = Vec2(0.5, 0.5);
	r.position = Vec2(0, 0);
	r.addTo(Director.ui);

	const mk = (size: number, color: Color.Type, text: string, y: number): void => {
		const t = Label('Font/SourceHanSerifSC-SemiBold.ttf;' + Math.round(size * 2) + ';true')!;
		t.text = text;
		t.color = color;
		t.anchor = Vec2(0.5, 0.5);
		t.position = Vec2(0, y);
		t.addTo(r);
	};
	mk(52, Color(233, 223, 196, 255), '三 · 引流', 90);
	mk(26, Color(163, 59, 42, 255), '玩法开发中', -10);
	mk(20, Color(233, 223, 196, 150), '按 ESC 回主菜单', -110);

	r.onKeyDown((key: KeyName): boolean => {
		if (key === KeyName.Escape) { back(); return true; }
		return false;
	});
}
