// 关卡外壳：「一张纸卡贴在页面上」的那层框。
//
// 所有关卡共用同一个版式：屏幕里留一圈页边，中间一张 1280×804 的纸卡，
// 纸卡有墨框和右下实心投影，卡片外再盖一层页面色遮住溢出。
// 内容挂到 inner 上，坐标和 HTML 完全一致（1280×804），不要跟着窗口拉伸。
//
// 用法：
//   const frame = createSceneFrame();
//   frame.input.onTapped(...);
//   root.schedule((dt) => { frame.fit(); ...; return false; });
import { Color, Director, Node, Size, Sprite, Vec2, View } from 'Dora';

export const W = 1280;
export const H = 804;

const MARGIN = 22;                        // 框内到内容的页边
const BORDER = 4;                         // 墨框粗细
const SHADOW = 10;                        // 右下实心投影
const PAD_SCREEN = 22;                    // 屏幕上卡片之外留的页面边距
const CARD_W = W + (MARGIN + BORDER) * 2;
const CARD_H = H + (MARGIN + BORDER) * 2;
const OUT_W = CARD_W + SHADOW;
const OUT_H = CARD_H + SHADOW;
const EDGE = MARGIN + BORDER;

const C_PAPER = Color(237, 227, 200, 255);
const C_INK = Color(36, 73, 70, 255);
// 墨色叠页面色算出来的等价色。投影必须不透明——半透明的话，
// 内容层溢出到这块阴影上的东西会透出来。
const C_SHADOW = Color(59, 89, 84, 255);

export type SceneFrame = {
	root: Node.Type;
	inner: Node.Type;
	input: Node.Type;
	fit: () => void;
	destroy: () => void;
};

export function createSceneFrame(coverBias = 0): SceneFrame {
	// 框外比纸色暗一档，卡片才「浮」得起来
	Director.clearColor = Color(197, 190, 169, 255);

	const root = Node();
	root.anchor = Vec2(0.5, 0.5);
	root.size = Size(OUT_W, OUT_H);
	root.position = Vec2(0, 0);
	root.addTo(Director.ui);

	const cardBlock = (x: number, y: number, w: number, h: number, c: Color.Type): Sprite.Type => {
		const sp = Sprite('Image/StartUI/white.png')!;
		sp.anchor = Vec2(0, 1);
		sp.size = Size(w, h);
		sp.position = Vec2(x, OUT_H - y);
		sp.color = c;
		sp.addTo(root);
		return sp;
	};

	/* ---------- 卡片：纸面 → 内容 → 页边遮罩 → 墨框 → 投影 ---------- */
	cardBlock(0, 0, CARD_W, CARD_H, C_PAPER);

	/* ---------- 内容层：严格 1280×804 ---------- */
	const inner = Node();
	inner.anchor = Vec2(0, 1);
	inner.size = Size(W, H);
	inner.position = Vec2(MARGIN + BORDER, OUT_H - (MARGIN + BORDER));
	inner.addTo(root);

	/* ---------- 页边遮罩 ----------
	   Sprite 不会自动裁到父节点边界（墙贴图 2560 宽会一直画到卡片外），
	   所以内容层之上铺四条纸色把溢出盖掉；墨框最后画，才不会被盖。 */
	cardBlock(0, 0, CARD_W, EDGE, C_PAPER);
	cardBlock(0, CARD_H - EDGE, CARD_W, EDGE, C_PAPER);
	cardBlock(0, 0, EDGE, CARD_H, C_PAPER);
	cardBlock(CARD_W - EDGE, 0, EDGE, CARD_H, C_PAPER);

	/* ---------- 墨框 ---------- */
	cardBlock(0, 0, CARD_W, BORDER, C_INK);
	cardBlock(0, CARD_H - BORDER, CARD_W, BORDER, C_INK);
	cardBlock(0, 0, BORDER, CARD_H, C_INK);
	cardBlock(CARD_W - BORDER, 0, BORDER, CARD_H, C_INK);

	/* ---------- 右下投影 ---------- */
	cardBlock(CARD_W, SHADOW, SHADOW, CARD_H, C_SHADOW);
	cardBlock(SHADOW, CARD_H, CARD_W, SHADOW, C_SHADOW);

	/* ---------- 卡片外的遮罩 ----------
	   页边遮罩只盖得住卡片内那 26px；溢出更多时还是会跑到页面背景上。 */
	const outer = Node();
	outer.anchor = Vec2(0.5, 0.5);
	outer.size = Size(OUT_W, OUT_H);
	outer.addTo(Director.ui);

	const C_PAGE = Director.clearColor;
	const BIG = 2600;
	const outerBlock = (x: number, y: number, w: number, h: number): void => {
		const sp = Sprite('Image/StartUI/white.png')!;
		sp.anchor = Vec2(0, 1);
		sp.size = Size(w, h);
		sp.position = Vec2(x, OUT_H - y);
		sp.color = C_PAGE;
		sp.addTo(outer);
	};
	outerBlock(-BIG, -BIG, BIG, OUT_H + BIG * 2);
	outerBlock(OUT_W, -BIG, BIG, OUT_H + BIG * 2);
	outerBlock(-BIG, -BIG, OUT_W + BIG * 2, BIG);
	outerBlock(-BIG, OUT_H, OUT_W + BIG * 2, BIG);

	/* ---------- 输入区 ---------- */
	const input = Node();
	input.size = Size(W, H);
	input.anchor = Vec2(0, 0);
	input.position = Vec2(0, 0);
	input.addTo(inner);
	input.touchEnabled = true;

	/* ---------- 自适应 ----------
	   纯 contain：整幅画面完整可见，绝不裁切。16:9 的窗口比 16:10 宽，
	   所以上下贴边、左右各留一点纸色边——「上下对齐、左右可不对齐」。
	   先扣掉屏幕页边再算比例，等于让卡片在窗口里再缩一圈，四周才有暗边。 */
	const fit = (): void => {
		const vs = View.size;
		const availW = Math.max(120, vs.width - PAD_SCREEN * 2);
		const availH = Math.max(80, vs.height - PAD_SCREEN * 2);
		let s = Math.min(availW / OUT_W, availH / OUT_H);
		// coverBias > 0：如果按宽度铺满、上下裁掉的比例在容忍范围内，就按宽度铺满。
		// HTML 原型是 fill（拉伸填满），Dora 是 contain（保持比例）——窗口一扁，
		// contain 会留一大截白，看着比原型小一圈。允许裁一点上下，换回尺寸。
		if (coverBias > 0) {
			const sW = availW / OUT_W;
			const needH = OUT_H * sW;
			if (needH > availH && (needH - availH) / needH <= coverBias) { s = sW; }
		}
		root.scaleX = s;
		root.scaleY = s;
		outer.scaleX = s;
		outer.scaleY = s;
	};
	fit();   // 建完立刻摆一次，别指望调用方记得调

	// 切关时要把两棵节点树都摘掉：root 在 Director.ui 上，outer 也是独立挂的，
	// 只删 root 会留下一层页面色盖住下一关。
	const destroy = (): void => {
		root.removeFromParent();
		outer.removeFromParent();
	};

	// 返回的必须是箭头函数包装：直接传 fit/destroy 会报
	// 「Unable to convert function with no 'this' parameter」。
	return {
		root: root,
		inner: inner,
		input: input,
		fit: (): void => { fit(); },
		destroy: (): void => { destroy(); },
	};
}
