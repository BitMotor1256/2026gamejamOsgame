// 第二关 · 砻糠计
// 目前只有关前 10 句（音游玩法还没接）。
// 外壳、对白、输入、跳过键都和第一关共用：SceneFrame + Dialogue。
import { KeyName } from 'Dora';
import { createDialogue } from 'Script/Dialogue';
import { createSceneFrame } from 'Script/SceneFrame';
import { LEVEL2_INTRO, LEVEL2_SPOTS } from 'Script/Story';
import { createLevel2Play } from 'Script/Level2Play';
import { H } from 'Script/SceneFrame';
import { backToTitle } from 'Script/Nav';
import { startLevel2Post } from 'Script/Level2PostScene';

// startAt：调试后门，直接从第 N 句起（0 基），截图核对标注时不用一句句点
// mode：调试后门 'card' 跳过对话进标题卡 / 'play' 再跳过标题卡直接对局（此时 startAt 变成拍数）
export function startLevel2(startAt?: number, mode?: string): void {
	const frame = createSceneFrame();

	let dlg: ReturnType<typeof createDialogue> | undefined = undefined;
	let phase = 0;   // 0 关前 / 1 玩法 / 2 结束
	let play: ReturnType<typeof createLevel2Play> | undefined = undefined;

	const startIntro = (): void => {
		phase = 0;
		dlg = createDialogue(frame.inner, {
			header: '二 · 砻糠计　关前',
			headerImg: 'Image/StartUI/h2.png',
			scene: 'Image/StartUI/lv2_scene.png',
			speaker: '王 梓',
			lines: LEVEL2_INTRO,
			fxGroups: ['mill', 'siege', 'bin', 'bran'],
			spotData: LEVEL2_SPOTS,
			caption: '城内 · 碾房与晒场（示意）',
			startAt: startAt,
			sayTall: true,
			onFinish: (): void => {
				if (dlg !== undefined) {
					dlg.destroy();
					dlg = undefined;
				}
				startPlay();
			},
		});
	};

	// 音游：糠块从梁下落进砻口，敲漏了疑心就涨
	const startPlay = (): void => {
		phase = 1;
		play = createLevel2Play(frame.inner, {
			onFinish: (): void => {
				if (play !== undefined) {
					play.destroy();
					play = undefined;
				}
				startEnd();
			},
			onNext: (): void => {
				// 结算页「好」→ 关后科普页（打字讲解）→ 下一关
				if (play !== undefined) { play.destroy(); play = undefined; }
				frame.destroy();
				startLevel2Post((): void => {
					print('[Level2] 关后科普看完 → 第三关（引流）尚未接入');
				});
			},
			onRestart: (): void => {
				if (play !== undefined) { play.destroy(); play = undefined; }
				frame.destroy();
				startLevel2(undefined, 'play');
			},
			onQuit: (): void => {
				if (play !== undefined) { play.destroy(); play = undefined; }
				frame.destroy();
				backToTitle();
			},
			immediate: mode === 'play' || mode === 'panel' || mode === 'pause',
			debugView: mode === 'panel' ? 'panel' : (mode === 'pause' ? 'pause' : (mode === 'btn' ? 'btn' : (mode === 'hov' ? 'hov' : undefined))),
			// mode='play' 时 startAt 的语义从「第几句台词」变成「第几拍」，方便对帧截图
			startAt: mode === 'play' ? startAt : undefined,
		});
	};

	const startEnd = (): void => {
		phase = 2;
		print('[Level2] 一夜过去了');
	};

	// 测试用：P 跳过当前这一段
	// 测试用：P 跳过当前这一段
	//   对话 → 跳过整段；玩法 → 直接进收束；结算页 → 进科普（等于点「好」）
	const skipPhase = (): void => {
		if (phase === 0) {
			if (dlg !== undefined) { dlg.skip(); }
		} else if (phase === 1) {
			if (play !== undefined) { play.skip(); }
		} else if (phase === 2) {
			if (play !== undefined) { play.tapAt(232, 690); }
		}
	};

	const advance = (): void => {
		if (dlg !== undefined) { dlg.next(); }
	};

	// 点击先给对话页判断是不是点在标点上；没吃住才推进台词
	frame.input.onTapped((touch): void => {
		if (phase === 1 && play !== undefined) {
			// input 在 inner 里，坐标是左下原点；tapAt 要的是左上原点的画布坐标
			play.tapAt(touch.location.x, H - touch.location.y);
			return;
		}
		if (dlg !== undefined && dlg.tapAt(touch.location.x, touch.location.y)) {
			return;
		}
		advance();
	});

	// 桌面端鼠标悬停：只有移动、没有按下时走这里（onTapMoved 是拖动才触发）
	frame.input.onMouseMove((touch): void => {
		if (phase === 1 && play !== undefined) {
			play.hoverAt(touch.location.x, H - touch.location.y);
		}
	});

	// 按下/抬起/移动：标题卡按钮的悬停-按下动效、滑杆拖拽都要这两个事件
	frame.input.onTapBegan((touch): void => {
		if (phase === 1 && play !== undefined) {
			play.setPointer(touch.location.x, H - touch.location.y, true);
		}
	});
	frame.input.onTapEnded((touch): void => {
		if (phase === 1 && play !== undefined) {
			play.setPointer(touch.location.x, H - touch.location.y, false);
		}
	});

	// 滑杆拖拽：onTapped 只给「按下」，连续改音量要单独接 onTapMoved
	frame.input.onTapMoved((touch): void => {
		if (phase === 1 && play !== undefined) {
			const tx = touch.location.x, ty = H - touch.location.y;
			play.hoverAt(tx, ty);
			play.dragTo(tx, ty);
		}
	});

	frame.root.onKeyDown((key: KeyName): void => {
		// P：测试用跳过。跳过当前这一段，直接进下一阶段。
		// 这个键后面会删，所以不做成正式功能，也不再兼暂停。
		if (key === KeyName.P) {
			skipPhase();
			return;
		}
		// ESC：关设置面板（等于再点一次齿轮）
		if (key === KeyName.Escape && phase === 1 && play !== undefined && play.setPanelOpen()) {
			play.tapAt(1214, 36);
			return;
		}
		// R：再来一次。HTML 的收束页写着「按 R 再来一次」，但这边一直没接，
		// 那句提示等于骗人。重开走整关重建，跳过对话直进对局。
		if (key === KeyName.R && phase === 2) {
			frame.destroy();
			startLevel2(undefined, 'play');
			return;
		}
		// 1/2/3 在三个阶段都要有反应，否则「按了没响应」：
		//   对话页 → 推进台词（HTML 的 intro 里 123 也算开始）
		//   标题卡 → play.hit() 第一句就是 beginPlay()
		//   对局   → 击打左中右
		// J/K/L 和 D/F/G 是 HTML 里的别名，手放中间时不用挪
		const hit0 = key === KeyName.Num1 || key === KeyName.J || key === KeyName.D;
		const hit1 = key === KeyName.Num2 || key === KeyName.K || key === KeyName.F;
		const hit2 = key === KeyName.Num3 || key === KeyName.L || key === KeyName.G;
		if (hit0 || hit1 || hit2) {
			if (phase === 1 && play !== undefined) {
				if (hit0) { play.hit(0); }
				if (hit1) { play.hit(1); }
				if (hit2) { play.hit(2); }
				return;
			}
			if (phase === 0) { advance(); return; }
			return;
		}
		// 空格：玩法里当中轨击打键，其他阶段推进台词
		if (key === KeyName.Space) {
			if (phase === 1 && play !== undefined) { play.hit(1); return; }
			advance();
			return;
		}
		if (key === KeyName.Return) {
			advance();
		}
	});

	frame.root.schedule((dt: number) => {
		frame.fit();
		if (dlg !== undefined) {
			dlg.update(dt);
		}
		if (play !== undefined) {
			play.update(dt);
		}
		return false;
	});

	if (mode === 'card' || mode === 'play' || mode === 'panel' || mode === 'pause' || mode === 'btn' || mode === 'hov') {
		startPlay();
		print('[Level2] 跳过对话（调试后门）');
		return;
	}
	startIntro();
	print('[Level2] 关前台词开始');
}
