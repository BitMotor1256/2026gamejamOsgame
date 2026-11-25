// 第二关背景音乐生成（Dora 内置音乐生成器）
//
// 为什么用 exact score 而不是 procedural composition：
// 谱面要和音乐严丝合缝。自己写音符就知道每一击落在第几拍，谱面直接由同一份拍位表导出；
// 让引擎随机作曲的话，还得反过来去分析音频才排得出谱。
//
// 这一段写好之后跑一次就行，产物是 Audio/lv2_bgm.ogg。以后改曲子才需要再跑。
import { thread } from 'Dora';
import { defineMusic, generateMusicAsync } from 'Agent/Gen/Music';

const BPM = 88;
const BARS = 32;                 // 32 小节 × 4 拍 = 128 拍，和谱面总长一致
const BEATS = BARS * 4;

/* 五声音阶（D 宫）：陪衬用，不抢鼓点 */
const PENTA = [62, 64, 66, 69, 71];      // D4 E4 F#4 A4 B4

type N = { pitch: number | string; start: number; duration: number; velocity?: number };

const buildScore = () => {
	// 鼓：一段比一段密——戌时只三拍一记，卯时每拍都响
	const drums: N[] = [];
	for (let b = 0; b < BEATS; b++) {
		const seg = b < 24 ? 0 : b < 56 ? 1 : b < 88 ? 2 : 3;
		const step = seg === 0 ? 3 : seg === 1 ? 2 : 1;
		if (b % step === 0) { drums.push({ pitch: 'C2', start: b, duration: 0.4, velocity: 0.85 }); }
		// 后半拍加一记木鱼，越到后面越密
		if (seg >= 2 && b % 2 === 1) { drums.push({ pitch: 'D2', start: b + 0.5, duration: 0.25, velocity: 0.45 }); }
	}

	// 低音：每两拍一个根音，跟着段落换
	const bass: N[] = [];
	for (let b = 0; b < BEATS; b += 2) {
		const seg = b < 24 ? 0 : b < 56 ? 1 : b < 88 ? 2 : 3;
		const root = [38, 38, 36, 40][seg];       // D2 / D2 / C2 / E2
		bass.push({ pitch: root, start: b, duration: 1.8, velocity: 0.55 });
	}

	// 旋律：五声音阶，确定性伪随机，越到后面越活跃
	const lead: N[] = [];
	let seed = 20261122;
	const rnd = (): number => {
		seed = (seed * 1103515245 + 12345) & 0x7fffffff;
		return seed / 0x7fffffff;
	};
	for (let b = 0; b < BEATS; b++) {
		const seg = b < 24 ? 0 : b < 56 ? 1 : b < 88 ? 2 : 3;
		const density = [0.22, 0.35, 0.5, 0.62][seg];
		if (rnd() > density) { continue; }
		const idx = Math.floor(rnd() * PENTA.length);
		lead.push({ pitch: PENTA[idx], start: b, duration: 0.8, velocity: 0.35 + rnd() * 0.2 });
	}

	return { drums: drums, bass: bass, lead: lead };
};

export function generateLv2Music(projectDir: string): void {
	thread((): void => {
		const sc = buildScore();
		const def = defineMusic({
			output: 'Audio/lv2_bgm.ogg',
			synth: { sampleRate: 44100, polyphony: 32 },
			score: {
				bpm: BPM,
				beatsPerBar: 4,
				bars: BARS,
				tracks: [
					{ instrument: 'drums', drumKit: 'electronic', notes: sc.drums, volume: 0.9, role: 'drums' },
					{ instrument: 'sine', notes: sc.bass, volume: 0.7, role: 'bass' },
					{ instrument: 'pluck', notes: sc.lead, volume: 0.42, role: 'melody' },
				],
			},
			effects: { reverb: 0.18, lowPass: 0.7 },
			exports: { midi: true, stems: false },
		});

		const r = generateMusicAsync(projectDir, def, {
			onProgress: (p): void => { print('[Music] ' + p.stage + ' ' + Math.round(p.progress * 100) + '%'); },
		});
		if (r.success) {
			print('[Music] 生成完成 ' + r.path + '  ' + r.durationSeconds.toFixed(1) + 's');
		} else {
			print('[Music] 失败 ' + r.message);
		}
	});
}
