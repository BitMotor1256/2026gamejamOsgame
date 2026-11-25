// 第一关 · 砌墙
// 关前 10 句 → 砌墙 → 关后 8 句 → 结束（补充科普页暂不接入）
import { KeyName, Touch } from 'Dora';
import { createBrickGame } from 'Script/BrickGame';
import { createDialogue } from 'Script/Dialogue';
import { startDeck } from 'Script/InfoDeck';
import { startLevel2 } from 'Script/Level2Scene';
import { backToTitle } from 'Script/Nav';
import { H, W, createSceneFrame } from 'Script/SceneFrame';
import { LEVEL1_INTRO, LEVEL1_OUTRO, LEVEL1_SLIDES } from 'Script/Story';

export function startLevel1(): void {
	const frame = createSceneFrame();
	const root = frame.root;
	const inner = frame.inner;
	const input = frame.input;

	/* ---------- 流程状态 ---------- */
	let phase = 0;   // 0 关前 / 1 占位 / 2 转场 / 3 结束 / 4 科普页
	let dlg: ReturnType<typeof createDialogue> | undefined = undefined;
	let goNext = false;   // 第一关讲完，下一帧切第二关
	let goTitle = false;  // 设置里点了「返回主菜单」，下一帧回标题页
	let deck: ReturnType<typeof startDeck> | undefined = undefined;
	let game: ReturnType<typeof createBrickGame> | undefined = undefined;

	const SCENE_IMG = 'Image/StartUI/scene_lv1.png';

	const startIntro = (): void => {
		phase = 0;
		dlg = createDialogue(inner, {
			header: '一 · 砌墙　关前',
			headerImg: 'Image/StartUI/h1.png',
			scene: SCENE_IMG,
			speaker: '王 梓',
			lines: LEVEL1_INTRO,
			fxGroups: ['ruler', 'height', 'seal'],
			onFinish: (): void => {
				if (dlg !== undefined) {
					dlg.destroy();
					dlg = undefined;
				}
				phase = 1;
				startBrick();
			},
		});
	};

	// 砌墙：玩法节点自己接管输入（layer 在 input 之上），
	// 通关后点「下一关」才回到台词流程
	const startBrick = (): void => {
		game = createBrickGame(inner, () => {
			if (game !== undefined) {
				game.destroy();
				game = undefined;
			}
			startOutro();
		}, () => {
			// 同样是「下一帧再做」：此刻还在游戏节点的点击回调里遍历子节点
			goTitle = true;
		});
	};

	// 补充科普页（InfoDeck）暂不接入流程：那两页的版式还要重做。
	// 函数与 InfoDeck.ts 都保留，定稿后在 startOutro 的 onFinish 里换回 startDeckFlow 即可。
	const startDeckFlow = (): void => {
		phase = 4;
		deck = startDeck(inner, '一 · 砌墙　补充科普', LEVEL1_SLIDES, () => {
			if (deck !== undefined) {
				deck.destroy();
				deck = undefined;
			}
			startEnd();
		});
	};

	// 关后：砌墙打完 → 讲城墙（洞口危害 / 周长 / 剖面 / 垛口）→ 谁修的 → 走
	const startOutro = (): void => {
		phase = 2;
		dlg = createDialogue(inner, {
			header: '一 · 砌墙　关后',
			scene: SCENE_IMG,
			speaker: '王 梓',
			lines: LEVEL1_OUTRO,
			fxGroups: ['gap', 'ruler', 'height', 'crown'],
			tags: { height: '高 8 米　底宽 3.9 米' },
			spots: false,
			onFinish: (): void => {
				if (dlg !== undefined) {
					dlg.destroy();
					dlg = undefined;
				}
				startEnd();
			},
		});
	};

	const startEnd = (): void => {
		phase = 3;
		goNext = true;
	};

	// 测试用：P 键跳过「当前这一段」——对话直接结束、砌墙直接通关、科普页直接翻完。
	// 只推进一步，不是跳到下一大关。
	const skipPhase = (): void => {
		if (phase === 0 || phase === 2) {
			if (dlg !== undefined) { dlg.skip(); }
		} else if (phase === 1) {
			if (game !== undefined) { game.skip(); }
		} else if (phase === 4) {
			if (deck !== undefined) { deck.skip(); }
		}
	};

	const advance = (): void => {
		if (phase === 1) { return; }   // 砌墙阶段由玩法自己吃点击
		if (phase === 4) {
			if (deck !== undefined) { deck.next(); }
			return;
		}
		if (dlg !== undefined) {
			dlg.next();
		}
	};

	// 点击先交给对话页判断是否点到场景图上的标点；没吃住才推进台词
	input.onTapped((touch: Touch.Type): void => {
		if (dlg !== undefined && dlg.tapAt(touch.location.x, touch.location.y)) {
			return;
		}
		advance();
	});
	root.onKeyDown((key: KeyName): void => {
		if (key === KeyName.P) {
			skipPhase();
			return;
		}
		if (key === KeyName.Return || key === KeyName.Space) {
			advance();
		}
	});

	/* ---------- 每帧 ---------- */
	root.schedule((dt: number) => {
		// 切关不在对话的 onFinish 里直接做：那时节点还在被遍历，
		// 当场摘掉容易出问题。留到下一帧，顺手停掉这个 schedule。
		if (goNext) {
			dlg = undefined;
			game = undefined;
			frame.destroy();
			print('[Level1] 关前流程走完，进第二关');
			startLevel2();
			return true;
		}

		if (goTitle) {
			dlg = undefined;
			game = undefined;
			deck = undefined;
			frame.destroy();
			print('[Level1] 返回主界面');
			backToTitle();
			return true;
		}

		frame.fit();

		if (dlg !== undefined) {
			dlg.update(dt);
		}
		if (deck !== undefined) {
			deck.update(dt);
		}
		if (game !== undefined) {
			game.update(dt);
		}

		return false;
	});

	startIntro();
	print('[Level1] 台词流程开始');
}
