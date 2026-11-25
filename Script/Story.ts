// 台词数据。与 01-设计文档/台词本.md 一一对应，改文案只改这里。
// 编号：关前 01–06、补充 07–08、过场 09
// fx 是场景区的演示标注，由 Dialogue 按句点亮：ruler 量尺 / height 高度 / seal 印章
// ex 是这一句的配脸：smile 微笑 / laugh 大笑 / dot 小点嘴 / wave 招手 /
//                     curvy 波浪嘴 / shy 害羞 / shyact 撒娇 / dizzy 头晕

export type LineData = {
	text: string;
	fx?: string;
	ex?: string;
};

export type SlideData = {
	num: string;
	unit: string;
	title: string;
	body: string;
	src: string;
	say: string;
};

/* 场景图上的可点标点。x/y 是【页面坐标】（图内坐标 + 场景区偏移 120/104），
   cx/cy 是说明卡左上角。 */
export type SpotData = {
	x: number;
	y: number;
	t: string;
	n: string;
	d: string;
	cx: number;
	cy: number;
};

export const LEVEL1_SPOTS: SpotData[] = [
	{ x: 300, y: 214, t: '垛口', n: '905 个', d: '墙顶那排缺口。人躲在垛后，从缺口往外射。全城九百多个。', cx: 348, cy: 240 },
	{ x: 720, y: 226, t: '这一段没砌完', n: '待补', d: '你要补的就是这儿。一块压一块，抽掉一块，旁边那块也松。', cx: 548, cy: 246 },
	{ x: 920, y: 380, t: '条石斜垒', n: '花岗岩', d: '墙不是砖砌的。大块花岗岩斜着垒，中间填沙石、灌黄沙。', cx: 548, cy: 236 },
];

export const LEVEL1_INTRO: LineData[] = [
	{ text: '你好哇，我叫王梓，是永昌堡的讲解师。', ex: 'wave' },
	{ text: '这城我熟得很，闭着眼都能走一圈。跟我来。', ex: 'laugh' },
	{ text: '先看这堵墙——一圈两千六百八十八米，走完快半小时。', fx: 'ruler', ex: 'dot' },
	{ text: '高八米，底宽快四米。墙身不是砖，是大块花岗岩条石，一块块斜着垒的。', fx: 'height', ex: 'dot' },
	{ text: '修这城那几年，卫所已经不管用了。倭寇年年从海上来，官府顾不上。', ex: 'curvy' },
	{ text: '最特别的是，它不是官府修的。是王家自己卖田凑钱修的。', fx: 'seal', ex: 'smile' },
	{ text: '光听我讲太干巴了，来玩一把？', ex: 'wave' },
];

/* 补充科普的两页（PPT 式）。文案对应台词本 07 / 08 */
export const LEVEL1_SLIDES: SlideData[] = [
	{
		num: '0',
		unit: '个 洞',
		title: '一个洞都不行',
		body: '墙是一块压一块垒起来的，缺一块，旁边那块就没了依托。\n所以补墙不是补个窟窿——是把它重新压回去。',
		src: '出处 · 现行墙体做法的通例；永昌堡为条石斜垒、中填沙石',
		say: '城墙是一座城的命。有一个洞都不行——塌一块，旁边跟着塌。',
	},
	{
		num: '11',
		unit: '个 月',
		title: '十一个月，一座城',
		body: '嘉靖三十七年（1558）十一月动工，三十八年十一月建成。\n捐银七千余两——卖的是族田，不是官帑。',
		src: '出处 · 温州市文化广电旅游局 / 中央纪委国家监委网站',
		say: '为了盖它，王家花了十一个月，七千多两银子。',
	},
];

/* 两页之后的一句转场（台词本 09） */
export const LEVEL1_OUTRO: LineData[] = [
	{ text: '城墙是一座城的命。有一个洞都不行——塌一块，旁边跟着塌。', fx: 'gap', ex: 'dot' },
	{ text: '你补的这段，只是整圈里的一小截。一圈两千六百八十八米，走完快半小时。', fx: 'ruler', ex: 'curvy' },
	{ text: '高八米，底宽将近四米。', fx: 'height', ex: 'dot' },
	{ text: '墙顶那排缺口叫垛口，全城九百多个。人躲在垛后面，从缺口往外射。', fx: 'crown', ex: 'wave' },
	{ text: '为了盖它，王家花了十一个月，七千多两银子。', ex: 'smile' },
	{ text: '钱是卖族田凑的，不是官帑。王叔果、王叔杲兄弟为了这个，把科举往后推了。', ex: 'shy' },
	{ text: '官修的海防城，沿海有几十座。这一座不是——百姓自己出工，自家掏钱。', ex: 'shyact' },
	{ text: '走，进城里看看。', ex: 'wave' },
];

/* 玩法未接入时显示的占位文案 */
export const LEVEL1_PLACEHOLDER: string = '（第一关玩法：砌墙，尚未接入）';

/* ---------- 第二关 · 砻糠计 ---------- */
// 关前 10 句：围 → 饿 → 撑 → 粮尽 → 演 → 走
export const LEVEL2_INTRO: LineData[] = [
	{ text: '你看这个，它叫碾子——「龙」字下面加「石」。去掉稻壳，一转，闷闷响一声。', fx: 'mill', ex: 'dot' },
	{ text: '碾出来的米归仓，脱下来的壳就是糠。糠不值钱，平常堆着烧火。', ex: 'curvy' },
	{ text: '嘉靖四十年，倭寇来了。城攻不下来，他们就改成围，一圈一圈围着不走。', fx: 'siege', ex: 'dot' },
	{ text: '围城最怕的不是打，是饿。人不打了，饭还得吃。', ex: 'shy' },
	{ text: '好在这座城里有一百多亩水田，被围着也能种。就靠这个，撑了半年。', ex: 'smile' },
	{ text: '撑到后来，城里没粮了。王叔杲想了个办法。', fx: 'bin', ex: 'shyact' },
	{ text: '他做了三件事：糠撒在晒场上；船底压石头、船面盖糠，在河里来回划；再让人把碾子拉得震天响。', fx: 'bran', ex: 'dot' },
	{ text: '倭寇在高处往城里看：满场谷子，船在运粮，满城都在碾米。', ex: 'laugh' },
	{ text: '可城里人知道，最后连留种的谷也吃了——那是明年的种子。', ex: 'dot' },
	{ text: '围了半年，什么也没等到，走了。来试试你能不能撑住这一夜？', ex: 'wave' },
];

// 标点坐标 = 图内坐标 + 场景区偏移 (120, 104)
export const LEVEL2_SPOTS: SpotData[] = [
	{ x: 344, y: 356, t: '碾子', n: '龙字下面加石', d: '去稻壳的土制碾具。木框土盘，人力推拉，一转闷响一声。', cx: 388, cy: 206 },
	{ x: 676, y: 392, t: '谷糠', n: '撒在晒场上', d: '远看像满场谷子在晒。三件事里，这件骗的是眼睛。', cx: 470, cy: 300 },
	{ x: 1000, y: 354, t: '粮囤', n: '已经见底', d: '围到后来城里没粮了。这一关要演的，就是「其实没有」。', cx: 596, cy: 196 },
];
