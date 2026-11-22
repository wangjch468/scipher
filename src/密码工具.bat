@echo off
chcp 65001 >nul
setlocal
set "SCRIPTFILE=%~f0"
set "BATARGS=%*"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f=$env:SCRIPTFILE; $mk='#'+'__PS_CODE_START__'+'#'; $t=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $i=$t.IndexOf($mk); if($i -lt 0){Write-Output 'engine marker missing';exit 1}; $code=$t.Substring($i+$mk.Length); $env:SCIPHER_ARGS=$env:BATARGS; Invoke-Expression $code"
exit /b
#__PS_CODE_START__#
# 密码工具 v2.2 / v2.4 —— Windows 批处理内嵌引擎（逻辑对齐 Python 版）
# 编码：UTF-8（无 BOM）。由外层 .bat 以 UTF8 读取并以 IEX 执行。
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
try { [Console]::InputEncoding  = [Text.Encoding]::UTF8 } catch {}

# ===== 常量 =====
$script:TONES = @('一声','二声','三声','四声')
$script:QUAN  = @([char]0xFF0C,[char]0x3002,[char]0x3001,[char]0xFF1B,[char]0xFF1A,[char]0xFF1F,[char]0xFF01,[char]0x201C,[char]0x2019,[char]0xFF08,[char]0xFF09,[char]0x300A,[char]0x300B,([string][char]0x2026+[string][char]0x2026))
$script:BAN   = @('.',',','?','!',';',':','''','"','(',')','-','_')
$script:LEGACY = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9') + $script:TONES + $script:QUAN + $script:BAN
$script:MARKS = @{ a='āáǎà'; o='ōóǒò'; e='ēéěè'; i='īíǐì'; u='ūúǔù'; v='ǖǘǚǜ' }
$script:CHUNK_B64 = 65536
# 缓存锚定 bat 自身目录：双击时 cwd 常为 C:\Windows\System32，相对 jm.tmp 会写入失败
try { $script:_base = Split-Path -Parent $env:SCRIPTFILE } catch { $script:_base = $null }
if (-not $script:_base) { try { $script:_base = (Get-Location).Path } catch { $script:_base = '.' } }
$script:CACHE = Join-Path $script:_base 'jm.tmp'
$script:VERSION = 'v2.4'

# ===== 拼音字典（占位符注入）=====
$script:dict = @{}
function Set-Dict([string]$chars, [string]$py) {
    $script:dict.Clear()
    $words = $py -split ' '
    for ($i = 0; $i -lt $chars.Length; $i++) {
        $c = [string]$chars[$i]
        $script:dict[$c] = if ($i -lt $words.Count) { $words[$i] } else { '' }
    }
}
Set-Dict '一丁七万丈三上下丌不与丐丑专且丕世丘丙业丛东丝丞丢两严丧丨个丫丬中丰串临丶丸丹为主丽举丿乃久乇么义之乌乍乎乏乐乒乓乔乖乘乙乜九乞也习乡书乩买乱乳乾了予争事二亍于亏云互亓五井亘亚些亟亠亡亢交亥亦产亨亩享京亭亮亲亳亵人亻亿什仁仂仃仄仅仆仇仉今介仍从仑仓仔仕他仗付仙仝仞仟仡代令以仨仪仫们仰仲仳仵件价任份仿企伉伊伍伎伏伐休众优伙会伛伞伟传伢伤伥伦伧伪伫伯估伲伴伶伸伺似伽佃但位低住佐佑体何佗佘余佚佛作佝佞佟你佣佤佥佧佩佬佯佰佳佴佶佻佼佾使侃侄侈侉例侍侏侑侔侗供依侠侣侥侦侧侨侩侪侬侮侯侵便促俄俅俊俎俏俐俑俗俘俚俜保俞俟信俣俦俨俩俪俭修俯俱俳俸俺俾倌倍倏倒倔倘候倚倜借倡倥倦倨倩倪倬倭倮债值倾偃假偈偌偎偏偕做停健偬偶偷偻偾偿傀傅傈傍傣傥傧储傩催傲傺傻像僖僚僦僧僬僭僮僳僵僻儆儇儋儒儡儿兀允元兄充兆先光克免兑兔兕兖党兜兢入全八公六兮兰共关兴兵其具典兹养兼兽冀冁冂内冈冉册再冒冕冖冗写军农冠冢冤冥冫冬冯冰冱冲决况冶冷冻冼冽净凄准凇凉凋凌减凑凛凝几凡凤凫凭凯凰凳凵凶凸凹出击凼函凿刀刁刂刃分切刈刊刍刎刑划刖列刘则刚创初删判刨利别刭刮到刳制刷券刹刺刻刽刿剀剁剂剃削剌前剐剑剔剖剜剞剡剥剧剩剪副割剽剿劁劂劈劐劓力劝办功加务劢劣动助努劫劬劭励劲劳劾势勃勇勉勋勐勒勖勘募勤勰勹勺勾勿匀包匆匈匍匏匐匕化北匙匚匝匠匡匣匦匪匮匹区医匾匿十千卅升午卉半华协卑卒卓单卖南博卜卞卟占卡卢卣卤卦卧卩卫卮卯印危即却卵卷卸卺卿厂厄厅历厉压厌厍厕厘厚厝原厢厣厥厦厨厩厮厶去县叁参又叉及友双反发叔取受变叙叛叟叠口古句另叨叩只叫召叭叮可台叱史右叵叶号司叹叻叼叽吁吃各吆合吉吊同名后吏吐向吒吓吕吖吗君吝吞吟吠吡吣否吧吨吩含听吭吮启吱吲吴吵吸吹吻吼吾呀呃呆呈告呋呐呒呓呔呕呖呗员呙呛呜呢呤呦周呱呲味呵呶呷呸呻呼命咀咂咄咆咋和咎咏咐咒咔咕咖咙咚咛咝咣咤咦咧咨咩咪咫咬咭咯咱咳咴咸咻咽咿哀品哂哄哆哇哈哉哌响哎哏哐哑哒哓哔哕哗哙哚哜哝哞哟哥哦哧哨哩哪哭哮哲哳哺哼哽哿唁唆唇唉唏唐唑唔唛唠唢唣唤唧唪唬售唯唰唱唳唷唼唾唿啁啃啄商啉啊啐啕啖啜啡啤啥啦啧啪啬啭啮啰啵啶啷啸啻啼啾喀喁喂喃善喇喈喉喊喋喏喑喔喘喙喜喝喟喧喱喳喵喷喹喻喽喾嗄嗅嗉嗌嗍嗑嗒嗓嗔嗖嗜嗝嗟嗡嗣嗤嗥嗦嗨嗪嗫嗬嗯嗲嗳嗵嗷嗽嗾嘀嘁嘈嘉嘌嘎嘏嘘嘛嘞嘟嘣嘤嘧嘬嘭嘱嘲嘴嘶嘹嘻嘿噌噍噎噔噗噘噙噜噢噤器噩噪噫噬噱噶噻噼嚅嚆嚎嚏嚓嚣嚯嚷嚼囊囔囗囚四囝回囟因囡团囤囫园困囱围囵囹固国图囿圃圄圆圈圉圊圜土圣在圩圪圬圭圮圯地圳圹场圻圾址坂均坊坌坍坎坏坐坑块坚坛坜坝坞坟坠坡坤坦坨坩坪坫坭坯坳坶坷坻坼垂垃垄垅垆型垌垒垓垛垠垡垢垣垤垦垧垩垫垭垮垲垴垸埂埃埋城埏埒埔埕埘埙埚埝域埠埤埭埯埴埸培基埽堀堂堆堇堋堍堑堕堙堞堠堡堤堪堰堵塄塌塍塑塔塘塞塥填塬塾墀墁境墅墉墒墓墙墚增墟墨墩墼壁壅壑壕壤士壬壮声壳壶壹夂处备复夏夔夕外夙多夜够夤夥大天太夫夭央夯失头夷夸夹夺夼奁奂奄奇奈奉奋奎奏契奔奕奖套奘奚奠奢奥女奴奶奸她好妁如妃妄妆妇妈妊妍妒妓妖妗妙妞妣妤妥妨妩妪妫妮妯妲妹妻妾姆姊始姐姑姒姓委姗姘姚姜姝姣姥姨姬姹姻姿威娃娄娅娆娇娈娉娌娑娓娘娜娟娠娣娥娩娱娲娴娶娼婀婆婉婊婕婚婢婧婪婴婵婶婷婺婿媒媚媛媪媲媳媵媸媾嫁嫂嫉嫌嫑嫒嫔嫖嫘嫜嫠嫡嫣嫦嫩嫫嫱嬉嬖嬗嬲嬴嬷孀子孑孓孔孕字存孙孚孛孜孝孟孢季孤孥学孩孪孬孰孱孳孵孺孽宀宁它宄宅宇守安宋完宏宓宕宗官宙定宛宜宝实宠审客宣室宥宦宪宫宰害宴宵家宸容宽宾宿寂寄寅密寇富寐寒寓寝寞察寡寤寥寨寮寰寸对寺寻导寿封射将尉尊小少尔尕尖尘尚尜尝尢尤尥尧尬就尴尸尹尺尻尼尽尾尿局屁层居屈屉届屋屎屏屐屑展屙属屠屡屣履屦屮屯山屹屺屿岁岂岈岌岍岐岑岔岖岗岘岙岚岛岜岢岣岩岫岬岭岱岳岵岷岸岽岿峁峄峋峒峙峡峤峥峦峨峪峭峰峻崂崃崆崇崎崔崖崛崞崤崦崧崩崭崮崴崽崾嵇嵊嵋嵌嵘嵛嵝嵩嵫嵬嵯嵴嶂嶙嶝嶷巅巍巛川州巡巢工左巧巨巩巫差巯己已巳巴巷巽巾币市布帅帆师希帏帐帑帔帕帖帘帙帚帛帜帝带帧席帮帱帷常帻帼帽幂幄幅幌幔幕幛幞幡幢干平年并幸幺幻幼幽广庀庄庆庇床庋序庐庑库应底庖店庙庚府庞废庠庥度座庭庳庵庶康庸庹庾廉廊廑廒廓廖廛廨廪廴延廷建廾廿开弁异弃弄弈弊弋式弑弓引弗弘弛弟张弥弦弧弩弪弭弯弱弹强弼彀彐归当录彖彗彘彝彡形彤彦彩彪彬彭彰影彳彷役彻彼往征徂径待徇很徉徊律後徐徒徕得徘徙徜御徨循徭微徵德徼徽心忄必忆忉忌忍忏忐忑忒忖志忘忙忝忠忡忤忧忪快忭忮忱念忸忻忽忾忿怀态怂怃怄怅怆怊怍怎怏怒怔怕怖怙怛怜思怠怡急怦性怨怩怪怫怯怵总怼怿恁恂恃恋恍恐恒恕恙恚恝恢恣恤恧恨恩恪恫恬恭息恰恳恶恸恹恺恻恼恽恿悃悄悉悌悍悒悔悖悚悛悝悟悠患悦您悫悬悭悯悱悲悴悸悻悼情惆惊惋惑惕惘惚惜惝惟惠惦惧惨惩惫惬惭惮惯惰想惴惶惹惺愀愁愆愈愉愍愎意愕愚感愠愣愤愦愧愫愿慈慊慌慎慑慕慝慢慧慨慰慵慷憋憎憔憝憧憨憩憬憷憾懂懈懊懋懑懒懔懦懵懿戆戈戊戋戌戍戎戏成我戒戕或戗战戚戛戟戡戢戤戥截戬戮戳戴户戽戾房所扁扃扇扈扉手扌才扎扑扒打扔托扛扣扦执扩扪扫扬扭扮扯扰扳扶批扼找承技抄抉把抑抒抓投抖抗折抚抛抟抠抡抢护报抨披抬抱抵抹抻押抽抿拂拄担拆拇拈拉拊拌拍拎拐拒拓拔拖拗拘拙拚招拜拟拢拣拥拦拧拨择括拭拮拯拱拳拴拶拷拼拽拾拿持挂指挈按挎挑挖挚挛挝挞挟挠挡挢挣挤挥挨挪挫振挲挹挺挽捂捃捅捆捉捋捌捍捎捏捐捕捞损捡换捣捧捩捭据捱捶捷捺捻掀掂掇授掉掊掌掎掏掐排掖掘掠探掣接控推掩措掬掭掮掰掳掴掷掸掺掼掾揄揆揉揍揎描提插揖揞揠握揣揩揪揭揲援揶揸揽揿搀搁搂搅搋搌搏搐搓搔搛搜搞搠搡搦搪搬搭搴携搽搿摁摄摅摆摇摈摊摒摔摘摞摧摩摭摸摹摺撂撄撅撇撑撒撕撖撙撞撤撩撬播撮撰撵撷撸撺撼擀擂擅操擎擐擒擗擘擞擢擤擦攀攉攒攘攥攫攮支攴攵收攸改攻放政故效敉敌敏救敕敖教敛敝敞敢散敦敫敬数敲整敷文斋斌斐斑斓斗料斛斜斟斡斤斥斧斩斫断斯新方於施旁旃旄旅旆旋旌旎族旒旖旗无既日旦旧旨早旬旭旮旯旰旱时旷旺昀昂昃昆昊昌明昏易昔昕昙昝星映春昧昨昭是昱昴昵昶昼显晁晃晋晌晏晒晓晔晕晖晗晚晟晡晤晦晨普景晰晴晶晷智晾暂暄暇暌暑暖暗暝暧暨暮暴暹暾曙曛曜曝曦曩曰曲曳更曷曹曼曾替最月有朊朋服朐朔朕朗望朝期朦木未末本札术朱朴朵机朽杀杂权杆杈杉杌李杏材村杓杖杜杞束杠条来杨杩杪杭杯杰杲杳杵杷杼松板极构枇枉枋析枕林枘枚果枝枞枢枣枥枧枨枪枫枭枯枰枳枵架枷枸柁柃柄柏某柑柒染柔柘柙柚柜柝柞柠柢查柩柬柯柰柱柳柴柽柿栀栅标栈栉栊栋栌栎栏树栓栖栗栝校栩株栲栳样核根格栽栾桀桁桂桃桄桅框案桉桊桌桎桐桑桓桔桕桠桡桢档桤桥桦桧桨桩桫桴桶桷梁梃梅梆梏梓梗梢梦梧梨梭梯械梳梵检棂棉棋棍棒棕棘棚棠棣森棰棱棵棹棺棼椁椅椋植椎椐椒椟椠椤椭椰椴椹椽椿楂楔楗楚楝楞楠楣楦楫楮楱楷楸楹楼榀概榄榆榇榈榉榍榔榕榘榛榜榧榨榫榭榱榴榷榻槁槊槌槎槐槔槛槟槠槭槲槽槿樊樗樘樟模樨横樯樱樵樽樾橄橇橐橘橙橛橡橥橱橹橼檀檄檎檐檑檗檠檩檫檬欠次欢欣欤欧欲欷欹欺款歃歆歇歉歌歙止正此步武歧歪歹死歼殁殂殃殄殆殇殉殊残殍殒殓殖殚殛殡殪殳殴段殷殿毁毂毅毋母每毒毓比毕毖毗毙毛毡毪毫毯毳毵毹毽氅氆氇氍氏氐民氓气氕氖氘氙氚氛氟氡氢氤氦氧氨氩氪氮氯氰氲水氵永氽汀汁求汆汇汉汊汐汔汕汗汛汜汝汞江池污汤汨汩汪汰汲汴汶汹汽汾沁沂沃沅沆沈沉沌沏沐沓沔沙沛沟没沣沤沥沦沧沩沪沫沭沮沱沲河沸油治沼沽沾沿泄泅泉泊泌泐泓泔法泖泗泛泞泠泡波泣泥注泪泫泮泯泰泱泳泵泶泷泸泺泻泼泽泾洁洄洇洋洌洎洒洗洙洚洛洞津洧洪洫洮洱洲洳洵洹活洼洽派流浃浅浆浇浈浊测浍济浏浑浒浓浔浙浚浜浞浠浣浦浩浪浮浯浴海浸浼涂涅消涉涌涎涑涓涔涕涛涝涞涟涠涡涣涤润涧涨涩涪涫涮涯液涵涸涿淀淄淅淆淇淋淌淑淖淘淙淝淞淠淡淤淦淫淬淮深淳混淹添淼清渊渌渍渎渐渑渔渖渗渚渝渠渡渣渤渥温渫渭港渲渴游渺湃湄湍湎湓湔湖湘湛湟湫湮湾湿溃溅溆溉溏源溘溜溟溢溥溧溪溯溱溲溴溶溷溺溻溽滁滂滇滋滏滑滓滔滕滗滚滞滟滠满滢滤滥滦滨滩滴滹漂漆漉漏漓演漕漠漤漩漪漫漭漯漱漳漶漾潆潇潋潍潘潜潞潢潦潭潮潲潴潸潺潼澄澈澉澌澍澎澜澡澧澳澶澹激濂濉濑濒濞濠濡濮濯瀑瀚瀛瀣瀵瀹灌灏灞火灬灭灯灰灵灶灸灼灾灿炀炅炉炊炎炒炔炕炖炙炜炝炫炬炭炮炯炱炳炷炸点炻炼炽烀烁烂烃烈烊烘烙烛烟烤烦烧烨烩烫烬热烯烷烹烽焉焊焐焓焕焖焘焙焚焦焯焰焱然煅煊煌煎煜煞煤煦照煨煮煲煳煸煺煽熄熊熏熔熘熙熟熠熨熬熳熵熹燃燎燔燕燠燥燧燮燹爆爝爨爪爬爰爱爵父爷爸爹爻爽爿片版牌牍牒牖牙牛牝牟牡牢牦牧物牮牯牲牵特牺牾牿犀犁犄犊犋犍犏犒犟犬犭犯犰犴状犷犸犹狁狂狃狄狈狍狎狐狒狗狙狞狠狡狨狩独狭狮狯狰狱狲狳狴狷狸狺狻狼猁猃猊猎猓猕猖猗猛猜猝猞猡猢猥猩猪猫猬献猱猴猷猸猹猾猿獍獐獒獗獠獬獭獯獾玄率玉王玎玑玖玛玟玢玩玫玮环现玲玳玷玺玻珀珂珈珉珊珍珏珐珑珙珞珠珥珧珩班珲球琅理琉琊琏琐琚琛琢琥琦琨琪琬琮琰琳琴琵琶琼瑁瑕瑗瑙瑚瑛瑜瑞瑟瑭瑰瑶瑷瑾璀璁璃璇璋璎璐璜璞璧璨璩璺瓒瓜瓞瓠瓢瓣瓤瓦瓮瓯瓴瓶瓷瓿甄甍甏甑甓甘甙甚甜生甥用甩甫甬甭甯田由甲申电男甸町画甾畀畅畈畋界畎畏畔留畚畛畜略畦番畲畴畸畹畿疃疆疋疏疑疒疔疖疗疙疚疝疟疠疡疣疤疥疫疬疮疯疰疱疲疳疴疵疸疹疼疽疾痂痃痄病症痈痉痊痍痒痔痕痖痘痛痞痢痣痤痦痧痨痪痫痰痱痴痹痼痿瘀瘁瘃瘅瘊瘌瘐瘕瘗瘘瘙瘛瘟瘠瘢瘤瘥瘦瘩瘪瘫瘭瘰瘳瘴瘵瘸瘼瘾瘿癀癃癌癍癔癖癜癞癣癫癯癸登白百皂的皆皇皈皋皎皑皓皖皙皤皮皱皲皴皿盂盅盆盈益盍盎盏盐监盒盔盖盗盘盛盟盥目盯盱盲直相盹盼盾省眄眇眈眉看眍眙眚真眠眢眦眨眩眭眯眵眶眷眸眺眼着睁睃睇睐睑睚睛睡睢督睥睦睨睫睬睹睽睾睿瞀瞄瞅瞌瞍瞎瞑瞒瞟瞠瞢瞥瞧瞩瞪瞬瞰瞳瞵瞻瞽瞿矍矗矛矜矢矣知矧矩矫矬短矮石矶矸矽矾矿砀码砂砉砌砍砑砒研砖砗砘砚砜砝砟砣砥砦砧砩砬砭砰破砷砸砹砺砻砼砾础硅硇硌硎硐硒硕硖硗硝硪硫硬硭确硷硼碇碉碌碍碎碑碓碗碘碚碛碜碟碡碣碥碧碰碱碲碳碴碹碾磁磅磉磊磋磐磔磕磙磨磬磲磴磷磺礁礅礓礞礤礴示礻礼社祀祁祆祈祉祓祖祗祚祛祜祝神祟祠祢祥祧票祭祯祷祸祺禀禁禄禅禊福禚禧禳禹禺离禽禾秀私秃秆秉秋种科秒秕秘租秣秤秦秧秩秫秭积称秸移秽稀稂稃稆程稍税稔稗稚稞稠稣稳稷稹稻稼稽稿穆穑穗穰穴究穷穸穹空穿窀突窃窄窆窈窍窑窒窕窖窗窘窜窝窟窠窥窦窨窬窭窳窿立竖站竞竟章竣童竦竭端竹竺竽竿笃笄笆笈笊笋笏笑笔笕笙笛笞笠笤笥符笨笪笫第笮笱笳笸笺笼笾筅筇等筋筌筏筐筑筒答策筘筚筛筝筠筢筮筱筲筵筷筹筻签简箅箍箐箔箕算箜箝管箢箦箧箨箩箪箫箬箭箱箴箸篁篆篇篌篑篓篙篚篝篡篥篦篪篮篱篷篼篾簇簋簌簏簖簟簦簧簪簸簿籀籁籍米籴类籼籽粉粑粒粕粗粘粜粝粞粟粢粤粥粪粮粱粲粳粹粼粽精糁糅糇糈糊糌糍糕糖糗糙糜糟糠糨糯糸系紊素索紧紫累絮絷綦綮縻繁繇纂纛纟纠纡红纣纤纥约级纨纩纪纫纬纭纯纰纱纲纳纵纶纷纸纹纺纽纾线绀绁绂练组绅细织终绉绊绋绌绍绎经绐绑绒结绔绕绗绘给绚绛络绝绞统绠绡绢绣绥绦继绨绩绪绫续绮绯绰绱绲绳维绵绶绷绸绺绻综绽绾绿缀缁缂缃缄缅缆缇缈缉缋缌缍缎缏缑缒缓缔缕编缗缘缙缚缛缜缝缟缠缡缢缣缤缥缦缧缨缩缪缫缬缭缮缯缰缱缲缳缴缵缶缸缺罂罄罅罐网罔罕罗罘罚罟罡罢罨罩罪置罱署罴罹罾羁羊羌美羔羚羝羞羟羡群羧羯羰羲羸羹羼羽羿翁翅翊翌翎翔翕翘翟翠翡翥翦翩翮翰翱翳翻翼耀老考耄者耆耋而耍耐耒耔耕耖耗耘耙耜耠耢耥耦耧耨耩耪耱耳耵耶耷耸耻耽耿聂聃聆聊聋职聍聒联聘聚聩聪聱聿肀肃肄肆肇肉肋肌肓肖肘肚肛肜肝肟肠股肢肤肥肩肪肫肭肮肯肱育肴肷肺肼肽肾肿胀胁胂胃胄胆背胍胎胖胗胙胚胛胜胝胞胡胤胥胧胨胩胪胫胬胭胯胰胱胲胳胴胶胸胺胼能脂脆脉脊脍脎脏脐脑脒脓脔脖脘脚脞脬脯脱脲脶脸脾腆腈腊腋腌腐腑腓腔腕腙腚腠腥腧腩腭腮腰腱腴腹腺腻腼腽腾腿膀膂膈膊膏膑膘膛膜膝膣膦膨膪膳膺膻臀臁臂臃臆臊臌臣臧自臬臭至致臻臼臾舀舁舂舄舅舆舌舍舐舒舔舛舜舞舟舡舢舣舨航舫般舭舯舰舱舳舴舵舶舷舸船舻舾艄艇艉艋艏艘艚艟艨艮良艰色艳艴艹艺艽艾艿节芄芈芊芋芍芎芏芑芒芗芘芙芜芝芟芡芤芥芦芨芩芪芫芬芭芮芯芰花芳芴芷芸芹芽芾苁苄苇苈苊苋苌苍苎苏苑苒苓苔苕苗苘苛苜苞苟苠苡苣苤若苦苫苯英苴苷苹苻茁茂范茄茅茆茇茈茉茌茎茏茑茔茕茗茚茛茜茧茨茫茬茭茯茱茳茴茵茶茸茹茺茼荀荃荆荇草荏荐荑荒荔荚荛荜荞荟荠荡荣荤荥荦荧荨荩荪荫荬荭荮药荷荸荻荼荽莅莆莉莎莒莓莘莛莜莞莠莨莩莪莫莰莱莲莳莴莶获莸莹莺莼莽菀菁菅菇菊菌菏菔菖菘菜菝菟菠菡菥菩菪菰菱菲菸菹菽萁萃萄萆萋萌萍萎萏萑萘萜萝萤营萦萧萨萱萸萼落葆葑著葙葚葛葜葡董葩葫葬葭葱葳葵葶葸葺蒂蒇蒈蒉蒋蒌蒎蒗蒙蒜蒡蒯蒲蒴蒸蒹蒺蒽蒿蓁蓄蓉蓊蓍蓐蓑蓓蓖蓝蓟蓠蓣蓥蓦蓬蓰蓼蓿蔌蔑蔓蔗蔚蔟蔡蔫蔬蔷蔸蔹蔺蔻蔼蔽蕃蕈蕉蕊蕖蕙蕞蕤蕨蕲蕴蕹蕺蕻蕾薄薅薇薏薛薜薤薨薪薮薯薰薷薹藁藉藏藐藓藕藜藤藩藻藿蘅蘑蘖蘧蘩蘸蘼虍虎虏虐虑虔虚虞虢虫虬虮虱虹虺虻虼虽虾虿蚀蚁蚂蚊蚋蚌蚍蚓蚕蚜蚝蚣蚤蚧蚨蚩蚪蚬蚯蚰蚱蚴蚵蚶蚺蛀蛄蛆蛇蛉蛊蛋蛎蛏蛐蛑蛔蛘蛙蛛蛞蛟蛤蛩蛭蛮蛰蛱蛲蛳蛴蛸蛹蛾蜀蜂蜃蜇蜈蜉蜊蜍蜒蜓蜕蜗蜘蜚蜜蜞蜡蜢蜣蜥蜩蜮蜱蜴蜷蜻蜾蜿蝇蝈蝉蝌蝎蝓蝗蝙蝠蝣蝤蝥蝮蝰蝴蝶蝻蝼蝽蝾螂螃螅螈螋融螓螗螟螨螫螬螭螯螳螵螺螽蟀蟆蟊蟋蟑蟒蟓蟛蟠蟥蟪蟮蟹蟾蠃蠊蠓蠕蠖蠛蠡蠢蠲蠹蠼血衄衅行衍衔街衙衡衢衣衤补表衩衫衬衮衰衲衷衽衾衿袁袂袄袅袈袋袍袒袖袜袢袤被袭袱袷袼裁裂装裆裉裎裒裔裕裘裙裟裢裣裤裥裨裰裱裳裴裸裹裼裾褂褊褐褒褓褙褚褛褡褥褪褫褰褴褶襁襄襞襟襦襻西要覃覆见观规觅视觇览觉觊觋觌觎觏觐觑角觖觚觜觞解觥触觫觯觳言訇訾詈詹誉誊誓謇謦警譬讠计订讣认讥讦讧讨让讪讫训议讯记讲讳讴讵讶讷许讹论讼讽设访诀证诂诃评诅识诈诉诊诋诌词诎诏译诒诓诔试诖诗诘诙诚诛诜话诞诟诠诡询诣诤该详诧诨诩诫诬语诮误诰诱诲诳说诵诶请诸诹诺读诼诽课诿谀谁谂调谄谅谆谇谈谊谋谌谍谎谏谐谑谒谓谔谕谖谗谘谙谚谛谜谝谟谠谡谢谣谤谥谦谧谨谩谪谫谬谭谮谯谰谱谲谳谴谵谶谷豁豆豇豉豌豕豚象豢豪豫豳豸豹豺貂貅貉貊貌貔貘贝贞负贡财责贤败账货质贩贪贫贬购贮贯贰贱贲贳贴贵贶贷贸费贺贻贼贽贾贿赀赁赂赃资赅赆赇赈赉赊赋赌赍赎赏赐赓赔赕赖赘赙赚赛赜赝赞赠赡赢赣赤赦赧赫赭走赳赴赵赶起趁趄超越趋趑趔趟趣趱足趴趵趸趺趼趾趿跃跄跆跋跌跎跏跑跖跗跚跛距跞跟跣跤跨跪跫跬路跳践跷跸跹跺跻跽踅踉踊踌踏踔踝踞踟踢踣踩踪踬踮踯踱踵踹踺踽蹀蹁蹂蹄蹇蹈蹉蹊蹋蹑蹒蹙蹦蹩蹬蹭蹯蹰蹲蹴蹶蹼蹿躁躅躇躏躐躔躜躞身躬躯躲躺軎车轧轨轩轫转轭轮软轰轱轲轳轴轵轶轷轸轹轺轻轼载轾轿辁辂较辄辅辆辇辈辉辊辋辍辎辏辐辑输辔辕辖辗辘辙辚辛辜辞辟辣辨辩辫辰辱辶边辽达迁迂迄迅过迈迎运近迓返迕还这进远违连迟迢迤迥迦迨迩迪迫迭迮述迳迷迸迹追退送适逃逄逅逆选逊逋逍透逐逑递途逖逗通逛逝逞速造逡逢逦逭逮逯逵逶逸逻逼逾遁遂遄遇遍遏遐遑遒道遗遘遛遢遣遥遨遭遮遴遵遽避邀邂邃邈邋邑邓邕邗邙邛邝邡邢那邦邪邬邮邯邰邱邳邴邵邶邸邹邺邻邾郁郄郅郇郊郎郏郐郑郓郗郛郜郝郡郢郦郧部郫郭郯郴郸都郾鄂鄄鄙鄞鄢鄣鄯鄱鄹酃酆酉酊酋酌配酎酏酐酒酗酚酝酞酡酢酣酤酥酩酪酬酮酯酰酱酲酴酵酶酷酸酹酽酾酿醅醇醉醋醌醍醐醑醒醚醛醢醣醪醭醮醯醴醵醺采釉释里重野量金釜鉴銎銮鋈錾鍪鎏鏊鏖鐾鑫钅钆钇针钉钊钋钌钍钎钏钐钒钓钔钕钗钙钚钛钜钝钞钟钠钡钢钣钤钥钦钧钨钩钪钫钬钭钮钯钰钱钲钳钴钵钶钷钸钹钺钻钼钽钾钿铀铁铂铃铄铅铆铈铉铊铋铌铍铎铐铑铒铕铖铗铘铙铛铜铝铞铟铠铡铢铣铤铥铧铨铩铪铫铬铭铮铯铰铱铲铳铴铵银铷铸铹铺铼铽链铿销锁锂锃锄锅锆锇锈锉锊锋锌锍锎锏锐锑锒锓锔锕锖锗锘错锚锛锝锞锟锡锢锣锤锥锦锨锩锪锫锬锭键锯锰锱锲锴锵锶锷锸锹锺锻锼锾锿镀镁镂镄镅镆镇镉镊镌镍镎镏镐镑镒镓镔镖镗镘镙镛镜镝镞镟镡镢镣镤镥镦镧镨镩镪镫镬镭镯镰镱镲镳镶长门闩闪闫闭问闯闰闱闲闳间闵闶闷闸闹闺闻闼闽闾阀阁阂阃阄阅阆阈阉阊阋阌阍阎阏阐阑阒阔阕阖阗阙阚阜阝队阡阢阪阮阱防阳阴阵阶阻阼阽阿陀陂附际陆陇陈陉陋陌降限陔陕陛陟陡院除陧陨险陪陬陲陴陵陶陷隅隆隈隋隍随隐隔隗隘隙障隧隰隳隶隹隼隽难雀雁雄雅集雇雉雌雍雎雏雒雕雠雨雩雪雯雳零雷雹雾需霁霄霆震霈霉霍霎霏霓霖霜霞霪霭霰露霸霹霾青靓靖静靛非靠靡面靥革靳靴靶靼鞅鞋鞍鞑鞒鞔鞘鞠鞣鞫鞭鞯鞲鞴韦韧韩韪韫韬韭音韵韶页顶顷顸项顺须顼顽顾顿颀颁颂颃预颅领颇颈颉颊颌颍颏颐频颓颔颖颗题颚颛颜额颞颟颠颡颢颤颥颦颧风飑飒飓飕飘飙飚飞食飧飨餍餐餮饔饕饣饥饧饨饩饪饫饬饭饮饯饰饱饲饴饵饶饷饺饼饽饿馀馁馄馅馆馇馈馊馋馍馏馐馑馒馓馔馕首馗馘香馥馨马驭驮驯驰驱驳驴驵驶驷驸驹驺驻驼驽驾驿骀骁骂骄骅骆骇骈骊骋验骏骐骑骒骓骖骗骘骚骛骜骝骞骟骠骡骢骣骤骥骧骨骰骱骶骷骸骺骼髀髁髂髅髋髌髑髓高髟髡髦髫髭髯髹髻鬃鬈鬏鬓鬟鬣鬯鬲鬻鬼魁魂魃魄魅魇魈魉魍魏魑魔鱼鱿鲁鲂鲅鲆鲇鲈鲋鲍鲎鲐鲑鲒鲔鲕鲚鲛鲜鲞鲟鲠鲡鲢鲣鲤鲥鲦鲧鲨鲩鲫鲭鲮鲰鲱鲲鲳鲴鲵鲶鲷鲸鲺鲻鲼鲽鳃鳄鳅鳆鳇鳊鳋鳌鳍鳎鳏鳐鳓鳔鳕鳖鳗鳘鳙鳜鳝鳞鳟鳢鸟鸠鸡鸢鸣鸥鸦鸨鸩鸪鸫鸬鸭鸯鸱鸲鸳鸵鸶鸷鸸鸹鸺鸽鸾鸿鹁鹂鹃鹄鹅鹆鹇鹈鹉鹊鹋鹌鹎鹏鹑鹕鹗鹘鹚鹛鹜鹞鹣鹤鹦鹧鹨鹩鹪鹫鹬鹭鹰鹱鹳鹾鹿麂麇麈麋麒麓麝麟麦麴麸麻麽麾黄黉黍黎黏黑黔默黛黜黝黟黠黢黥黧黩黪黯黹黻黼黾鼋鼍鼎鼐鼓鼗鼙鼠鼢鼬鼯鼷鼹鼻鼽鼾齄齐齑齿龀龃龄龅龆龇龈龉龊龋龌龙龚龛龟龠' 'yi1 ding1 qi1 wan4 zhang4 san1 shang4 xia4 ji1 bu4 yu3 gai4 chou3 zhuan1 qie3 pi1 shi4 qiu1 bing3 ye4 cong2 dong1 si1 cheng2 diu1 liang3 yan2 sang4 gun3 ge4 ya1 qiang2 zhong1 feng1 chuan4 lin2 zhu3 wan2 dan1 wei4 zhu3 li4 ju3 pie3 nai3 jiu3 tuo1 me yi4 zhi1 wu1 zha4 hu1 fa2 le4 ping1 pang1 qiao2 guai1 cheng2 yi3 mie1 jiu3 qi3 ye3 xi2 xiang1 shu1 ji1 mai3 luan4 ru3 qian2 le yu3 zheng1 shi4 er4 chu4 yu2 kui1 yun2 hu4 qi2 wu3 jing3 gen4 ya4 xie1 ji2 tou2 wang2 kang4 jiao1 hai4 yi4 chan3 heng1 mu3 xiang3 jing1 ting2 liang4 qin1 bo2 xie4 ren2 ren2 yi4 shen2 ren2 le4 ding1 ze4 jin3 pu1 chou2 zhang3 jin1 jie4 reng2 cong2 lun2 cang1 zai3 shi4 ta1 zhang4 fu4 xian1 tong2 ren4 qian1 ge1 dai4 ling4 yi3 sa1 yi2 mu4 men yang3 zhong4 pi3 wu3 jian4 jia4 ren4 fen4 fang3 qi3 kang4 yi1 wu3 ji4 fu2 fa2 xiu1 zhong4 you1 huo3 hui4 yu3 san3 wei3 chuan2 ya2 shang1 chang1 lun2 cang1 wei3 zhu4 bo2 gu1 ni4 ban4 ling2 shen1 ci4 shi4 ga1 dian4 dan4 wei4 di1 zhu4 zuo3 you4 ti3 he2 tuo2 she2 yu2 yi4 fu2 zuo4 gou1 ning4 tong2 ni3 yong1 wa3 qian1 ka3 pei4 lao3 yang2 bai3 jia1 er4 ji2 tiao1 jiao3 yi4 shi3 kan3 zhi2 chi3 kua3 li4 shi4 zhu1 you4 mou2 dong4 gong1 yi1 xia2 lv3 jiao3 zhen1 ce4 qiao2 kuai4 chai2 nong2 wu3 hou2 qin1 bian4 cu4 e2 qiu2 jun4 zu3 qiao4 li4 yong3 su2 fu2 li3 ping1 bao3 yu2 qi2 xin4 yu3 chou2 yan3 lia3 li4 jian3 xiu1 fu3 ju4 pai2 feng4 an3 bi3 guan1 bei4 shu1 dao4 jue2 tang3 hou4 yi3 ti4 jie4 chang4 kong1 juan4 ju4 qian4 ni2 zhuo1 wo1 luo3 zhai4 zhi2 qing1 yan3 jia3 ji4 ruo4 wei1 pian1 xie2 zuo4 ting2 jian4 zong3 ou3 tou1 lou2 fen4 chang2 gui1 fu4 li4 bang4 dai3 tang3 bin1 chu3 nuo2 cui1 ao4 chi4 sha3 xiang4 xi1 liao2 jiu4 seng1 jiao1 jian4 tong2 su4 jiang1 pi4 jing3 xuan1 dan1 ru2 lei3 er2 wu4 yun3 yuan2 xiong1 chong1 zhao4 xian1 guang1 ke4 mian3 dui4 tu4 si4 yan3 dang3 dou1 jing1 ru4 quan2 ba1 gong1 liu4 xi1 lan2 gong4 guan1 xing1 bing1 qi2 ju4 dian3 zi1 yang3 jian1 shou4 ji4 chan3 jiong1 nei4 gang1 ran3 ce4 zai4 mao4 mian3 mi4 rong3 xie3 jun1 nong2 guan1 zhong3 yuan1 ming2 bing1 dong1 feng2 bing1 hu4 chong1 jue2 kuang4 ye3 leng3 dong4 xian3 lie4 jing4 qi1 zhun3 song1 liang2 diao1 ling2 jian3 cou4 lin3 ning2 ji3 fan2 feng4 fu2 ping2 kai3 huang2 deng4 qian3 xiong1 tu1 ao1 chu1 ji1 dang4 han2 zao2 dao1 diao1 dao1 ren4 fen1 qie4 yi4 kan1 chu2 wen3 xing2 hua4 yue4 lie4 liu2 ze2 gang1 chuang4 chu1 shan1 pan4 pao2 li4 bie2 jing3 gua1 dao4 ku1 zhi4 shua1 quan4 sha1 ci4 ke4 gui4 gui4 kai3 duo4 ji4 ti4 xue1 la2 qian2 gua3 jian4 ti1 pou1 wan1 ji1 shan4 bo1 ju4 sheng4 jian3 fu4 ge1 piao1 jiao3 qiao1 jue2 pi1 huo1 yi4 li4 quan4 ban4 gong1 jia1 wu4 mai4 lie4 dong4 zhu4 nu3 jie2 qu2 shao4 li4 jin4 lao2 he2 shi4 bo2 yong3 mian3 xun1 meng3 lei1 xu4 kan1 mu4 qin2 xie2 bao1 shao2 gou1 wu4 yun2 bao1 cong1 xiong1 pu2 pao2 fu2 bi3 hua4 bei3 shi fang1 za1 jiang4 kuang1 xia2 gui3 fei3 kui4 pi3 qu1 yi1 bian3 ni4 shi2 qian1 sa4 sheng1 wu3 hui4 ban4 hua2 xie2 bei1 zu2 zhuo2 dan1 mai4 nan2 bo2 bo bian4 bu3 zhan4 ka3 lu2 you3 lu3 gua4 wo4 jie2 wei4 zhi1 mao3 yin4 wei1 ji2 que4 luan3 juan3 xie4 jin3 qing1 chang3 e4 ting1 li4 li4 ya1 yan4 she4 ce4 li2 hou4 cuo4 yuan2 xiang1 yan3 jue2 sha4 chu2 jiu4 si1 si1 qu4 xian4 san1 can1 you4 cha1 ji2 you3 shuang1 fan3 fa1 shu1 qu3 shou4 bian4 xu4 pan4 sou3 die2 kou3 gu3 ju4 ling4 dao1 kou4 zhi3 jiao4 zhao4 ba1 ding1 ke3 tai2 chi4 shi3 you4 po3 ye4 hao4 si1 tan4 le4 diao1 ji1 xu1 chi1 ge4 yao1 he2 ji2 diao4 tong2 ming2 hou4 li4 tu3 xiang4 zha1 xia4 lv3 ya1 ma jun1 lin4 tun1 yin2 fei4 bi3 qin4 fou3 ba dun1 fen1 han2 ting1 keng1 shun3 qi3 zhi1 yin3 wu2 chao3 xi1 chui1 wen3 hou3 wu2 ya e4 dai1 cheng2 gao4 fu1 na4 wu3 yi4 dai1 ou3 li4 bei yuan2 guo1 qiang1 wu1 ne ling4 you1 zhou1 gu1 ci1 wei4 he1 nao2 ga1 pei1 shen1 hu1 ming4 ju3 za1 duo1 pao2 za3 he2 jiu4 yong3 fu4 zhou4 ka1 gu1 ka1 long2 dong1 ning2 si1 guang1 zha4 yi2 lie3 zi1 mie1 mi1 zhi3 yao3 ji1 ge1 zan2 ke2 hui1 xian2 xiu1 yan4 yi1 ai1 pin3 shen3 hong3 duo1 wa ha1 zai1 pai4 xiang3 ai1 gen2 kuang1 ya3 da2 xiao1 bi4 hui4 hua1 kuai4 duo3 ji4 nong2 mou1 yo1 ge1 o2 chi1 shao4 li1 na3 ku1 xiao1 zhe2 zha1 bu3 heng1 geng3 ge3 yan4 suo1 chun2 ai1 xi1 tang2 zuo4 wu2 ma4 lao2 suo3 zao4 huan4 ji1 feng3 hu3 shou4 wei2 shua1 chang4 li4 yo1 sha4 tuo4 hu1 zhao1 ken3 zhuo2 shang1 lin2 a cui4 tao2 dan4 chuai4 fei1 pi2 sha2 la ze2 pa1 se4 zhuan4 nie4 luo1 bo1 ding4 lang1 xiao4 chi4 ti2 jiu1 ka1 yong2 wei4 nan2 shan4 la3 jie1 hou2 han3 die2 nuo4 yin1 o1 chuan3 hui4 xi3 he1 kui4 xuan1 li2 zha1 miao1 pen1 kui2 yu4 lou2 ku4 a2 xiu4 su4 ai4 suo1 ke1 da1 sang3 chen1 sou1 shi4 ge2 jie1 weng1 si4 chi1 hao2 suo hai1 qin2 nie4 he1 n2 die1 ai1 tong1 ao2 sou4 sou3 di2 qi1 cao2 jia1 piao4 ga1 gu3 xu1 ma lei du1 beng1 ying1 mi4 chuai4 peng1 zhu3 chao2 zui3 si1 liao2 xi1 hei1 ceng1 jiao4 ye1 deng1 pu1 jue1 qin2 lu1 o1 jin4 qi4 e4 zao4 yi1 shi4 jue2 ga2 sai1 pi1 ru2 hao1 hao2 ti4 ca1 xiao1 huo4 rang3 jue2 nang2 nang1 wei2 qiu2 si4 jian3 hui2 xin4 yin1 nan1 tuan2 dun4 hu2 yuan2 kun4 cong1 wei2 lun2 ling2 gu4 guo2 tu2 you4 pu3 yu3 yuan2 quan1 yu3 qing1 huan2 tu3 sheng4 zai4 wei2 ge1 wu1 gui1 pi3 yi2 di4 zhen4 kuang4 chang3 qi2 ji1 zhi3 ban3 jun1 fang1 ben4 tan1 kan3 huai4 zuo4 keng1 kuai4 jian1 tan2 li4 ba4 wu4 fen2 zhui4 po1 kun1 tan3 tuo2 gan1 ping2 dian4 ni2 pi1 ao4 mu3 ke3 chi2 che4 chui2 la1 long3 long3 lu2 xing2 dong4 lei3 gai1 duo3 yin2 fa2 gou4 yuan2 die2 ken3 shang3 e4 dian4 ya1 kua3 kai3 nao3 yuan4 geng3 ai1 mai2 cheng2 shan1 lie4 pu3 cheng2 shi2 xun1 guo1 nian4 yu4 bu4 pi2 dai4 an3 zhi2 yi4 pei2 ji1 sao4 ku1 tang2 dui1 jin3 peng2 tu4 qian4 duo4 yin1 die2 hou4 bao3 di1 kan1 yan4 du3 leng2 ta1 cheng2 su4 ta3 tang2 sai1 ge2 tian2 yuan2 shu2 chi2 man4 jing4 shu4 yong1 shang1 mu4 qiang2 liang2 zeng1 xu1 mo4 dun1 ji1 bi4 yong1 he4 hao2 rang3 shi4 ren2 zhuang4 sheng1 ke2 hu2 yi1 zhi3 chu4 bei4 fu4 xia4 kui2 xi1 wai4 su4 duo1 ye4 gou4 yin2 huo3 da4 tian1 tai4 fu1 yao1 yang1 hang1 shi1 tou2 yi2 kua1 jia1 duo2 kuang3 lian2 huan4 yan3 qi2 nai4 feng4 fen4 kui2 zou4 qi4 ben1 yi4 jiang3 tao4 zang4 xi1 dian4 she1 ao4 nv3 nu2 nai3 jian1 ta1 hao3 shuo4 ru2 fei1 wang4 zhuang1 fu4 ma1 ren4 yan2 du4 ji4 yao1 jin4 miao4 niu1 bi3 yu2 tuo3 fang2 wu3 yu4 gui1 ni1 zhou2 da2 mei4 qi1 qie4 mu3 zi3 shi3 jie3 gu1 si4 xing4 wei3 shan1 pin1 yao2 jiang1 shu1 jiao1 lao3 yi2 ji1 cha4 yin1 zi1 wei1 wa2 lou2 ya4 rao2 jiao1 luan2 ping1 li3 suo1 wei3 niang2 na4 juan1 shen1 di4 e2 mian3 yu2 wa1 xian2 qu3 chang1 e1 po2 wan3 biao3 jie2 hun1 bi4 jing4 lan2 ying1 chan2 shen3 ting2 wu4 xu4 mei2 mei4 yuan4 ao3 pi4 xi2 ying4 chi1 gou4 jia4 sao3 ji2 xian2 bao2 ai4 pin2 piao2 lei2 zhang1 li2 di2 yan1 chang2 nen4 mo2 qiang2 xi1 bi4 shan4 niao3 ying2 ma1 shuang1 zi jie2 jue2 kong3 yun4 zi4 cun2 sun1 fu2 bei4 zi1 xiao4 meng4 bao1 ji4 gu1 nu2 xue2 hai2 luan2 nao1 shu2 can4 zi1 fu1 ru2 nie4 mian2 ning2 ta1 gui3 zhai2 yu3 shou3 an1 song4 wan2 hong2 mi4 dang4 zong1 guan1 zhou4 ding4 wan3 yi2 bao3 shi2 chong3 shen3 ke4 xuan1 shi4 you4 huan4 xian4 gong1 zai3 hai4 yan4 xiao1 jia1 chen2 rong2 kuan1 bin1 su4 ji4 ji4 yin2 mi4 kou4 fu4 mei4 han2 yu4 qin3 mo4 cha2 gua3 wu4 liao2 zhai4 liao2 huan2 cun4 dui4 si4 xun2 dao3 shou4 feng1 she4 jiang1 wei4 zun1 xiao3 shao3 er3 ga3 jian1 chen2 shang4 ga2 chang2 you2 you2 liao4 yao2 ga4 jiu4 gan1 shi1 yin3 chi3 kao1 ni2 jin3 wei3 niao4 ju2 pi4 ceng2 ju1 qu1 ti4 jie4 wu1 shi3 ping2 ji1 xie4 zhan3 e1 shu3 tu2 lv3 xi3 lv3 ju4 che4 tun2 shan1 yi4 qi3 yu3 sui4 qi3 ya2 ji2 qian1 qi2 cen2 cha4 qu1 gang3 xian4 ao4 lan2 dao3 ba1 ke3 gou3 yan2 xiu4 jia3 ling3 dai4 yue4 hu4 min2 an4 dong1 kui1 mao3 yi4 xun2 dong4 zhi4 xia2 jiao4 zheng1 luan2 e2 yu4 qiao4 feng1 jun4 lao2 lai2 kong1 chong2 qi2 cui1 ya2 jue2 guo1 xiao2 yan1 song1 beng1 zhan3 gu4 wai3 zai3 yao3 ji1 sheng4 mei2 qian4 rong2 yu2 lou3 song1 zi1 wei2 cuo2 ji3 zhang4 lin2 deng4 yi2 dian1 wei1 chuan1 chuan1 zhou1 xun2 chao2 gong1 zuo3 qiao3 ju4 gong3 wu1 cha4 qiu2 ji3 yi3 si4 ba1 xiang4 xun4 jin1 bi4 shi4 bu4 shuai4 fan1 shi1 xi1 wei2 zhang4 tang3 pei4 pa4 tie1 lian2 zhi4 zhou3 bo2 zhi4 di4 dai4 zhen1 xi2 bang1 chou2 wei2 chang2 ze2 guo2 mao4 mi4 wo4 fu2 huang3 man4 mu4 zhang4 fu2 fan1 chuang2 gan4 ping2 nian2 bing4 xing4 yao1 huan4 you4 you1 guang3 pi3 zhuang1 qing4 bi4 chuang2 gui3 xu4 lu2 wu3 ku4 ying1 di3 pao2 dian4 miao4 geng1 fu3 pang2 fei4 xiang2 xiu1 du4 zuo4 ting2 bi4 an1 shu4 kang1 yong1 tuo3 yu3 lian2 lang2 jin3 ao2 kuo4 liao4 chan2 xie4 lin3 yin3 yan2 ting2 jian4 gong3 nian4 kai1 bian4 yi4 qi4 nong4 yi4 bi4 yi4 shi4 shi4 gong1 yin3 fu2 hong2 chi2 di4 zhang1 mi2 xian2 hu2 nu3 jing4 mi3 wan1 ruo4 dan4 qiang2 bi4 gou4 ji4 gui1 dang1 lu4 tuan4 hui4 zhi4 yi2 shan1 xing2 tong2 yan4 cai3 biao1 bin1 peng2 zhang1 ying3 chi4 pang2 yi4 che4 bi3 wang3 zheng1 cu2 jing4 dai4 xun4 hen3 yang2 huai2 lv4 hou4 xu2 tu2 lai2 de2 pai2 xi3 chang2 yu4 huang2 xun2 yao2 wei1 zheng1 de2 jiao3 hui1 xin1 xin bi4 yi4 dao1 ji4 ren3 chan4 tan3 te4 te4 cun3 zhi4 wang4 mang2 tian3 zhong1 chong1 wu3 you1 song1 kuai4 bian4 zhi4 chen2 nian4 niu3 xin1 hu1 kai4 fen4 huai2 tai4 song3 wu3 ou4 chang4 chuang4 chao1 zuo4 zen3 yang4 nu4 zheng1 pa4 bu4 hu4 da2 lian2 si1 dai4 yi2 ji2 peng1 xing4 yuan4 ni2 guai4 fu2 qie4 chu4 zong3 dui4 yi4 nen4 xun2 shi4 lian4 huang3 kong3 heng2 shu4 yang4 hui4 jia2 hui1 zi4 xu4 nv4 hen4 en1 ke4 dong4 tian2 gong1 xi1 qia4 ken3 e4 tong4 yan1 kai3 ce4 nao3 yun4 yong3 kun3 qiao1 xi1 ti4 han4 yi4 hui3 bei4 song3 quan1 kui1 wu4 you1 huan4 yue4 nin2 que4 xuan2 qian1 min3 fei3 bei1 cui4 ji4 xing4 dao4 qing2 chou2 jing1 wan3 huo4 ti4 wang3 hu1 xi1 chang3 wei2 hui4 dian4 ju4 can3 cheng2 bei4 qie4 can2 dan4 guan4 duo4 xiang3 zhui4 huang2 re3 xing1 qiao3 chou2 qian1 yu4 yu2 min3 bi4 yi4 e4 yu2 gan3 yun4 leng4 fen4 kui4 kui4 su4 yuan4 ci2 qian4 huang1 shen4 she4 mu4 te4 man4 hui4 kai3 wei4 yong1 kang1 bie1 zeng1 qiao2 dui4 chong1 han1 qi4 jing3 chu4 han4 dong3 xie4 ao4 mao4 men4 lan3 lin3 nuo4 meng3 yi4 gang4 ge1 wu4 jian1 xu1 shu4 rong2 xi4 cheng2 wo3 jie4 qiang1 huo4 qiang1 zhan4 qi1 jia2 ji3 kan1 ji2 gai4 deng3 jie2 jian3 lu4 chuo1 dai4 hu4 hu4 li4 fang2 suo3 bian3 jiong1 shan4 hu4 fei1 shou3 shou cai2 zha1 pu1 ba1 da3 reng1 tuo1 kang2 kou4 qian1 zhi2 kuo4 men2 sao3 yang2 niu3 ban4 che3 rao3 ban1 fu2 pi1 e4 zhao3 cheng2 ji4 chao1 jue2 ba3 yi4 shu1 zhua1 tou2 dou3 kang4 zhe2 fu3 pao1 tuan2 kou1 lun1 qiang3 hu4 bao4 peng1 pi1 tai2 bao4 di3 mo3 chen1 ya1 chou1 min3 fu2 zhu3 dan1 chai1 mu3 nian1 la1 fu3 ban4 pai1 lin1 guai3 ju4 tuo4 ba2 tuo1 ao3 ju1 zhuo1 pan4 zhao1 bai4 ni3 long3 jian3 yong1 lan2 ning2 bo1 ze2 kuo4 shi4 jie2 zheng3 gong3 quan2 shuan1 za1 kao3 pin1 zhuai1 shi2 na2 chi2 gua4 zhi3 qie4 an4 kua4 tiao1 wa1 zhi4 luan2 wo1 ta4 xie2 nao2 dang3 jiao3 zheng1 ji3 hui1 ai1 nuo2 cuo4 zhen4 sa1 yi4 ting3 wan3 wu3 jun4 tong3 kun3 zhuo1 lv3 ba1 han4 shao1 nie1 juan1 bu3 lao1 sun3 jian3 huan4 dao3 peng3 lie4 bai3 ju4 ai2 chui2 jie2 na4 nian3 xian1 dian1 duo1 shou4 diao4 pou2 zhang3 ji3 tao1 qia1 pai2 ye1 jue2 lve4 tan4 che4 jie1 kong4 tui1 yan3 cuo4 ju1 tian4 qian2 bai1 lu3 guai1 zhi4 dan3 can4 guan4 yuan4 yu2 kui2 rou2 zou4 xuan1 miao2 ti2 cha1 yi1 an3 ya4 wo4 chuai1 kai1 jiu1 jie1 die2 yuan2 ye2 zha1 lan3 qin4 chan1 ge1 lou3 jiao3 chuai1 zhan3 bo2 chu4 cuo1 sao1 jian1 sou1 gao3 shuo4 sang3 nuo4 tang2 ban1 da1 qian1 xie2 cha2 ge2 en4 she4 shu1 bai3 yao2 bin4 tan1 bing3 shuai1 zhai1 luo4 cui1 mo2 zhi2 mo1 mo2 zhe2 liao4 ying1 jue1 pie1 cheng1 sa1 si1 han4 zun3 zhuang4 che4 liao1 qiao4 bo1 cuo1 zhuan4 nian3 xie2 lu1 cuan1 han4 gan3 lei2 shan4 cao1 qing2 huan4 qin2 pi3 bai1 sou3 zhuo2 xing3 ca1 pan1 huo1 zan3 rang3 zuan4 jue2 nang3 zhi1 pu1 pu1 shou1 you1 gai3 gong1 fang4 zheng4 gu4 xiao4 mi3 di2 min3 jiu4 chi4 ao2 jiao4 lian3 bi4 chang3 gan3 san4 dun1 jiao3 jing4 shu4 qiao1 zheng3 fu1 wen2 zhai1 bin1 fei3 ban1 lan2 dou4 liao4 hu2 xie2 zhen1 wo4 jin1 chi4 fu3 zhan3 zhuo2 duan4 si1 xin1 fang1 yu2 shi1 pang2 zhan1 mao2 lv3 pei4 xuan2 jing1 ni3 zu2 liu2 yi3 qi2 wu2 ji4 ri4 dan4 jiu4 zhi3 zao3 xun2 xu4 ga1 la2 gan4 han4 shi2 kuang4 wang4 yun2 ang2 ze4 kun1 hao4 chang1 ming2 hun1 yi4 xi1 xin1 tan2 zan3 xing1 ying4 chun1 mei4 zuo2 zhao1 shi4 yu4 mao3 ni4 chang3 zhou4 xian3 chao2 huang3 jin4 shang3 yan4 shai4 xiao3 ye4 yun1 hui1 han2 wan3 cheng2 bu1 wu4 hui4 chen2 pu3 jing3 xi1 qing2 jing1 gui3 zhi4 liang4 zan4 xuan1 xia2 kui2 shu3 nuan3 an4 ming2 ai4 ji4 mu4 bao4 xian1 tun1 shu3 xun1 yao4 pu4 xi1 nang3 yue1 qu1 ye4 geng4 he2 cao2 man4 ceng2 ti4 zui4 yue4 you3 ruan3 peng2 fu2 qu2 shuo4 zhen4 lang3 wang4 chao2 qi1 meng2 mu4 wei4 mo4 ben3 zha2 shu4 zhu1 pu3 duo3 ji1 xiu3 sha1 za2 quan2 gan1 cha1 shan1 wu4 li3 xing4 cai2 cun1 biao1 zhang4 du4 qi3 shu4 gang1 tiao2 lai2 yang2 ma4 miao3 hang2 bei1 jie2 gao3 yao3 chu3 pa2 zhu4 song1 ban3 ji2 gou4 pi2 wang3 fang1 xi1 zhen3 lin2 rui4 mei2 guo3 zhi1 cong1 shu1 zao3 li4 jian3 cheng2 qiang1 feng1 xiao1 ku1 ping2 zhi3 xiao1 jia4 jia1 gou3 duo4 ling2 bing3 bai3 mou3 gan1 qi1 ran3 rou2 zhe4 xia2 you4 gui4 tuo4 zha4 ning2 di3 cha2 jiu4 jian3 ke1 nai4 zhu4 liu3 chai2 cheng1 shi4 zhi1 zha4 biao1 zhan4 zhi4 long2 dong4 lu2 li4 lan2 shu4 shuan1 qi1 li4 gua1 xiao4 xu3 zhu1 kao3 lao3 yang4 he2 gen1 ge2 zai1 luan2 jie2 heng2 gui4 tao2 guang1 wei2 kuang1 an4 an1 juan4 zhuo1 zhi4 tong2 sang1 huan2 ju2 jiu4 ya1 rao2 zhen1 dang4 qi1 qiao2 hua4 gui4 jiang3 zhuang1 suo1 fu2 tong3 jue2 liang2 ting3 mei2 bang1 gu4 zi3 geng3 shao1 meng4 wu2 li2 suo1 ti1 xie4 shu1 fan4 jian3 ling2 mian2 qi2 gun4 bang4 zong1 ji2 peng2 tang2 di4 sen1 chui2 leng2 ke1 zhao4 guan1 fen2 guo3 yi3 liang2 zhi2 chui2 ju1 jiao1 du2 qian4 luo2 tuo3 ye1 duan4 shen4 chuan2 chun1 zha1 xie1 jian4 chu3 lian4 leng2 nan2 mei2 xuan4 ji2 chu3 zou4 kai3 qiu1 ying2 lou2 pin3 gai4 lan3 yu2 chen4 lv2 ju3 xie4 lang2 rong2 ju3 zhen1 bang3 fei3 zha4 sun3 xie4 cui1 liu2 que4 ta4 gao3 shuo4 chui2 cha2 huai2 gao1 kan3 bin1 zhu1 qi1 hu2 cao2 jin3 fan2 chu1 tang2 zhang1 mo2 xi1 heng2 qiang2 ying1 qiao2 zun1 yue4 gan3 qiao1 tuo2 ju2 cheng2 jue2 xiang4 zhu1 chu2 lu3 yuan2 tan2 xi2 qin2 yan2 lei2 bo4 qing2 lin3 cha2 meng2 qian4 ci4 huan1 xin1 yu2 ou1 yu4 xi1 yi1 qi1 kuan3 sha4 xin1 xie1 qian4 ge1 she4 zhi3 zheng4 ci3 bu4 wu3 qi2 wai1 dai3 si3 jian1 mo4 cu2 yang1 tian3 dai4 shang1 xun4 shu1 can2 piao3 yun3 lian4 zhi2 dan1 ji2 bin4 yi4 shu1 ou1 duan4 yin1 dian4 hui3 gu3 yi4 wu2 mu3 mei3 du2 yu4 bi3 bi4 bi4 pi2 bi4 mao2 zhan1 mu2 hao2 tan3 cui4 san1 shu1 jian4 chang3 pu3 lu qu2 shi4 di1 min2 mang2 qi4 pie1 nai3 dao1 xian1 chuan1 fen1 fu2 dong1 qing1 yin1 hai4 yang3 an1 ya4 ke4 dan4 lv4 qing2 yun1 shui3 shui yong3 tun3 ting1 zhi1 qiu2 cuan1 hui4 han4 cha4 xi1 qi4 shan4 han4 xun4 si4 ru3 gong3 jiang1 chi2 wu1 tang1 mi4 gu3 wang1 tai4 ji2 bian4 wen4 xiong1 qi4 fen2 qin4 yi2 wo4 yuan2 hang4 shen3 chen2 dun4 qi1 mu4 da2 mian3 sha1 pei4 gou1 mei2 feng1 ou1 li4 lun2 cang1 wei2 hu4 mo4 shu4 ju3 tuo2 tuo2 he2 fei4 you2 zhi4 zhao3 gu1 zhan1 yan2 xie4 qiu2 quan2 po1 mi4 le4 hong2 gan1 fa3 mao3 si4 fan4 ning4 ling2 pao4 bo1 qi4 ni2 zhu4 lei4 xuan4 pan4 min3 tai4 yang1 yong3 beng4 xue2 long2 lu2 luo4 xie4 po1 ze2 jing1 jie2 hui2 yin1 yang2 lie4 ji4 sa3 xi3 zhu1 jiang4 luo4 dong4 jin1 wei3 hong2 xu4 tao2 er3 zhou1 ru4 xun2 huan2 huo2 wa1 qia4 pai4 liu2 jia1 qian3 jiang1 jiao1 zhen1 zhuo2 ce4 hui4 ji4 liu2 hun2 hu3 nong2 xun2 zhe4 jun4 bang1 zhuo2 xi1 huan4 pu3 hao4 lang4 fu2 wu2 yu4 hai3 jin4 mei3 tu2 nie4 xiao1 she4 yong3 xian2 su4 juan1 cen2 ti4 tao1 lao4 lai2 lian2 wei2 wo1 huan4 di2 run4 jian4 zhang3 se4 fu2 guan4 shuan4 ya2 ye4 han2 he2 zhuo1 dian4 zi1 xi1 xiao2 qi2 lin2 tang3 shu1 nao4 tao2 cong2 fei2 song1 pi4 dan4 yu1 gan4 yin2 cui4 huai2 shen1 chun2 hun4 yan1 tian1 miao3 qing1 yuan1 lu4 zi4 du2 jian4 mian3 yu2 shen3 shen4 zhu3 yu2 qu2 du4 zha1 bo2 wo4 wen1 xie4 wei4 gang3 xuan4 ke3 you2 miao3 pai4 mei2 tuan1 mian3 pen2 jian1 hu2 xiang1 zhan4 huang2 jiao3 yan1 wan1 shi1 kui4 jian4 xu4 gai4 tang2 yuan2 ke4 liu1 ming2 yi4 pu3 li4 xi1 su4 qin2 sou1 xiu4 rong2 hun4 ni4 ta1 ru4 chu2 pang1 dian1 zi1 fu3 hua2 zi3 tao1 teng2 bi4 gun3 zhi4 yan4 she4 man3 ying2 lv4 lan4 luan2 bin1 tan1 di1 hu1 piao1 qi1 lu4 lou4 li2 yan3 cao2 mo4 lan3 xuan2 yi1 man4 mang3 luo4 shu4 zhang1 huan4 yang4 ying2 xiao1 lian4 wei2 pan1 qian2 lu4 huang2 lao3 tan2 chao2 shao4 zhu1 shan1 chan2 tong2 cheng2 che4 gan3 si1 shu4 peng1 lan2 zao3 li3 ao4 chan2 dan4 ji1 lian2 sui1 lai4 bin1 bi4 hao2 ru2 pu2 zhuo2 pu4 han4 ying2 xie4 fen4 yue4 guan4 hao4 ba4 huo3 biao1 mie4 deng1 hui1 ling2 zao4 jiu3 zhuo2 zai1 can4 yang2 jiong3 lu2 chui1 yan2 chao3 gui4 kang4 dun4 zhi4 wei3 qiang4 xuan4 ju4 tan4 pao4 jiong3 tai2 bing3 zhu4 zha4 dian3 shi2 lian4 chi4 hu1 shuo4 lan4 ting1 lie4 yang2 hong1 lao4 zhu2 yan1 kao3 fan2 shao1 ye4 hui4 tang4 jin4 re4 xi1 wan2 peng1 feng1 yan1 han4 wu4 han2 huan4 men4 dao4 bei4 fen2 jiao1 chao1 yan4 yan4 ran2 duan4 xuan1 huang2 jian1 yu4 sha1 mei2 xu4 zhao4 wei1 zhu3 bao1 hu2 bian1 tui4 shan1 xi1 xiong2 xun1 rong2 liu1 xi1 shu2 yi4 yun4 ao2 man4 shang1 xi1 ran2 liao2 fan2 yan4 yu4 zao4 sui4 xie4 xian3 bao4 jue2 cuan4 zhao3 pa2 yuan2 ai4 jue2 fu4 ye2 ba4 die1 yao2 shuang3 pan2 pian4 ban3 pai2 du2 die2 you3 ya2 niu2 pin4 mou2 mu3 lao2 mao2 mu4 wu4 jian4 gu3 sheng1 qian1 te4 xi1 wu3 gu4 xi1 li2 ji1 du2 ju4 jian1 pian1 kao4 jiang4 quan3 quan3 fan4 qiu2 an4 zhuang4 guang3 ma4 you2 yun3 kuang2 niu3 di2 bei4 pao2 xia2 hu2 fei4 gou3 ju1 ning2 hen3 jiao3 rong2 shou4 du2 xia2 shi1 kuai4 zheng1 yu4 sun1 yu2 bi4 juan4 li2 yin2 suan1 lang2 li4 xian3 ni2 lie4 guo3 mi2 chang1 yi1 meng3 cai1 cu4 she1 luo2 hu2 wei3 xing1 zhu1 mao1 wei4 xian4 nao2 hou2 you2 mei2 cha2 hua2 yuan2 jing4 zhang1 ao2 jue2 liao2 xie4 ta3 xun1 huan1 xuan2 lv4 yu4 wang2 ding1 ji1 jiu3 ma3 wen2 bin1 wan2 mei2 wei3 huan2 xian4 ling2 dai4 dian4 xi3 bo1 po4 ke1 jia1 min2 shan1 zhen1 jue2 fa4 long2 gong3 luo4 zhu1 er3 yao2 hang2 ban1 hui1 qiu2 lang2 li3 liu2 ya2 lian3 suo3 ju1 chen1 zuo2 hu3 qi2 kun1 qi2 wan3 cong2 yan3 lin2 qin2 pi2 pa2 qiong2 mao4 xia2 yuan4 nao3 hu2 ying1 yu2 rui4 se4 tang2 gui1 yao2 ai4 jin3 cui3 cong1 li2 xuan2 zhang1 ying1 lu4 huang2 pu2 bi4 can4 qu2 wen4 zan4 gua1 die2 hu4 piao2 ban4 rang2 wa3 weng4 ou1 ling2 ping2 ci2 bu4 zhen1 meng2 beng4 zeng4 pi4 gan1 dai4 shen4 tian2 sheng1 sheng1 yong4 shuai3 fu3 yong3 beng2 ning2 tian2 you2 jia3 shen1 dian4 nan2 dian1 ting1 hua4 zai1 bi4 chang4 fan4 tian2 jie4 quan3 wei4 pan4 liu2 ben3 zhen3 chu4 lve4 qi2 fan1 she1 chou2 ji1 wan3 ji1 tuan3 jiang1 pi3 shu1 yi2 ne4 ding1 jie1 liao2 ge1 jiu4 shan4 nve4 li4 yang2 you2 ba1 jie4 yi4 li4 chuang1 feng1 zhu4 pao4 pi2 gan1 ke1 ci1 dan3 zhen3 teng2 ju1 ji2 jia1 xuan2 zha4 bing4 zheng4 yong1 jing4 quan2 yi2 yang3 zhi4 hen2 ya3 dou4 tong4 pi3 li4 zhi4 cuo2 wu4 sha1 lao2 huan4 xian2 tan2 fei4 chi1 bi4 gu4 wei3 yu1 cui4 zhu2 dan1 hou2 la4 yu3 jia3 yi4 lou4 sao4 chi4 wen1 ji2 ban1 liu2 chai4 shou4 da1 bie3 tan1 biao1 luo3 chou1 zhang4 zhai4 que2 mo4 yin3 ying3 huang2 long2 ai2 ban1 yi4 pi3 dian4 lai4 xuan3 dian1 qu2 gui3 deng1 bai2 bai3 zao4 de jie1 huang2 gui1 gao1 jiao3 ai2 hao4 wan3 xi1 po2 pi2 zhou4 jun1 cun1 min3 yu2 zhong1 pen2 ying2 yi4 he2 ang4 zhan3 yan2 jian1 he2 kui1 gai4 dao4 pan2 sheng4 meng2 guan4 mu4 ding1 xu1 mang2 zhi2 xiang1 dun3 pan4 dun4 sheng3 mian3 miao3 dan1 mei2 kan4 kou1 yi2 sheng3 zhen1 mian2 yuan1 zi4 zha3 xuan4 sui1 mi1 chi1 kuang4 juan4 mou2 tiao4 yan3 zhe zheng1 suo1 di4 lai4 jian3 ya2 jing1 shui4 sui1 du1 pi4 mu4 ni4 jie2 cai3 du3 kui2 gao1 rui4 mao4 miao2 chou3 ke1 sou3 xia1 ming2 man2 piao3 cheng1 meng2 pie1 qiao2 zhu3 deng4 shun4 kan4 tong2 lin2 zhan1 gu3 qu2 jue2 chu4 mao2 jin1 shi3 yi3 zhi1 shen3 ju3 jiao3 cuo2 duan3 ai3 shi2 ji1 gan1 xi4 fan2 kuang4 dang4 ma3 sha1 huo4 qi4 kan3 ya4 pi1 yan2 zhuan1 che1 dun4 yan4 feng1 fa2 zha3 tuo2 di3 zhai4 zhen1 fu2 la2 bian1 peng1 po4 shen1 za2 ai4 li4 long2 tong2 li4 chu3 gui1 nao2 ge4 xing2 dong4 xi1 shuo4 xia2 qiao1 xiao1 wo4 liu2 ying4 mang2 que4 jian3 peng2 ding4 diao1 lu4 ai4 sui4 bei1 dui4 wan3 dian3 bei4 qi4 chen3 die2 du2 jie2 bian3 bi4 peng4 jian3 di4 tan4 cha2 xuan4 nian3 ci2 bang4 sang3 lei3 cuo1 pan2 zhe2 ke1 gun3 mo2 qing4 qu2 deng4 lin2 huang2 jiao1 dun1 jiang1 meng2 ca3 bo2 shi4 shi4 li3 she4 si4 qi2 xian1 qi2 zhi3 fu2 zu3 zhi1 zuo4 qu1 hu4 zhu4 shen2 sui4 ci2 mi2 xiang2 tiao1 piao4 ji4 zhen1 dao3 huo4 qi2 bing3 jin4 lu4 chan2 xi4 fu2 zhuo2 xi3 rang2 yu3 yu2 li2 qin2 he2 xiu4 si1 tu1 gan3 bing3 qiu1 zhong3 ke1 miao3 bi3 mi4 zu1 mo4 cheng4 qin2 yang1 zhi4 shu2 zi3 ji1 cheng1 jie1 yi2 hui4 xi1 lang2 fu1 lv3 cheng2 shao1 shui4 ren3 bai4 zhi4 ke1 chou2 su1 wen3 ji4 zhen3 dao4 jia4 ji1 gao3 mu4 se4 sui4 rang2 xue2 jiu1 qiong2 xi1 qiong2 kong1 chuan1 zhun1 tu1 qie4 zhai3 bian3 yao3 qiao4 yao2 zhi4 tiao3 jiao4 chuang1 jiong3 cuan4 wo1 ku1 ke1 kui1 dou4 xun1 yu2 ju4 yu3 long2 li4 shu4 zhan4 jing4 jing4 zhang1 jun4 tong2 song3 jie2 duan1 zhu2 zhu2 yu2 gan1 du3 ji1 ba1 ji2 zhao4 sun3 hu4 xiao4 bi3 jian3 sheng1 di2 chi1 li4 tiao2 si4 fu2 ben4 da2 zi3 di4 ze2 gou3 jia1 po3 jian1 long2 bian1 xian3 qiong2 deng3 jin1 quan2 fa2 kuang1 zhu4 tong3 da2 ce4 kou4 bi4 shai1 zheng1 yun2 pa2 shi4 xiao3 shao1 yan2 kuai4 chou2 gang4 qian1 jian3 bi4 gu1 qing4 bo2 ji1 suan4 kong1 qian2 guan3 yuan1 ze2 qie4 tuo4 luo2 dan1 xiao1 ruo4 jian4 xiang1 zhen1 zhu4 huang2 zhuan4 pian1 hou2 kui4 lou3 gao1 fei3 gou1 cuan4 li4 bi4 chi2 lan2 li2 peng2 dou1 mie4 cu4 gui3 su4 lu4 duan4 dian4 deng1 huang2 zan1 bo3 bu4 zhou4 lai4 ji2 mi3 di2 lei4 xian1 zi3 fen3 ba1 li4 po4 cu1 zhan1 tiao4 li4 xi1 su4 zi1 yue4 zhou1 fen4 liang2 liang2 can4 jing1 cui4 lin2 zong4 jing1 san3 rou2 hou2 xu3 hu2 zan1 ci2 gao1 tang2 qiu3 cao1 mi2 zao1 kang1 jiang4 nuo4 mi4 xi4 wen3 su4 suo3 jin3 zi3 lei4 xu4 zhi2 qi2 qi3 mi2 fan2 yao2 zuan3 dao4 si1 jiu1 yu1 hong2 zhou4 xian1 ge1 yue1 ji2 wan2 kuang4 ji4 ren4 wei3 yun2 chun2 pi1 sha1 gang1 na4 zong4 lun2 fen1 zhi3 wen2 fang3 niu3 shu1 xian4 gan4 xie4 fu2 lian4 zu3 shen1 xi4 zhi1 zhong1 zhou4 ban4 fu2 chu4 shao4 yi4 jing1 dai4 bang3 rong2 jie2 ku4 rao4 hang2 hui4 gei3 xuan4 jiang4 luo4 jue2 jiao3 tong3 geng3 xiao1 juan4 xiu4 sui2 tao1 ji4 ti2 ji4 xu4 ling2 xu4 qi3 fei1 chuo4 shang4 gun3 sheng2 wei2 mian2 shou4 beng1 chou2 liu3 quan3 zong1 zhan4 wan3 lv4 zhui4 zi1 ke4 xiang1 jian1 mian3 lan3 ti2 miao3 ji1 hui4 si1 duo3 duan4 bian4 gou1 zhui4 huan3 di4 lv3 bian1 min2 yuan2 jin4 fu4 ru4 zhen3 feng4 gao3 chan2 li2 yi4 jian1 bin1 piao1 man4 lei2 ying1 suo1 mou2 sao1 xie2 liao2 shan4 zeng1 jiang1 qian3 qiao1 huan2 jiao3 zuan3 fou3 gang1 que1 ying1 qing4 xia4 guan4 wang3 wang3 han3 luo2 fu2 fa2 gu3 gang1 ba4 yan3 zhao4 zui4 zhi4 lan3 shu3 pi2 li2 zeng1 ji1 yang2 qiang1 mei3 gao1 ling2 di1 xiu1 qiang3 xian4 qun2 suo1 jie2 tang1 xi1 lei2 geng1 chan4 yu3 yi4 weng1 chi4 yi4 yi4 ling2 xiang2 xi1 qiao4 di2 cui4 fei3 zhu4 jian3 pian1 he2 han4 ao2 yi4 fan1 yi4 yao4 lao3 kao3 mao4 zhe3 qi2 die2 er2 shua3 nai4 lei3 zi3 geng1 chao4 hao4 yun2 ba4 si4 huo1 lao4 tang1 ou3 lou2 nou4 jiang3 pang3 mo4 er3 ding1 ye2 da1 song3 chi3 dan1 geng3 nie4 dan1 ling2 liao2 long2 zhi2 ning2 gua1 lian2 pin4 ju4 kui4 cong1 ao2 yu4 yu4 su4 yi4 si4 zhao4 rou4 le1 ji1 huang1 xiao4 zhou3 du4 gang1 rong2 gan1 wo4 chang2 gu3 zhi1 fu1 fei2 jian1 fang2 zhun1 na4 ang1 ken3 gong1 yu4 yao2 qian3 fei4 jing3 tai4 shen4 zhong3 zhang4 xie2 shen4 wei4 zhou4 dan3 bei4 gua1 tai1 pang4 zhen1 zuo4 pei1 jia3 sheng4 zhi1 bao1 hu2 yin4 xu1 long2 dong4 ka3 lu2 jing4 nu3 yan1 kua4 yi2 guang1 hai3 ge1 dong4 jiao1 xiong1 an4 pian2 neng2 zhi1 cui4 mai4 ji2 kuai4 sa4 zang4 qi2 nao3 mi3 nong2 luan2 bo2 wan3 jiao3 cuo3 pao1 pu2 tuo1 niao4 luo2 lian3 pi2 tian3 jing1 la4 ye4 yan1 fu3 fu3 fei2 qiang1 wan4 zong1 ding4 cou4 xing1 shu4 nan3 e4 sai1 yao1 jian4 yu2 fu4 xian4 ni4 mian3 wa4 teng2 tui3 bang3 lv3 ge2 bo2 gao1 bin4 biao1 tang2 mo2 xi1 zhi4 lin4 peng2 chuai4 shan4 ying1 shan1 tun2 lian2 bi4 yong1 yi4 sao1 gu3 chen2 zang1 zi4 nie4 chou4 zhi4 zhi4 zhen1 jiu4 yu2 yao3 yu2 chong1 xi4 jiu4 yu2 she2 she3 shi4 shu1 tian3 chuan3 shun4 wu3 zhou1 chuan2 shan1 yi3 ban3 hang2 fang3 ban1 bi3 zhong1 jian4 cang1 zhu2 ze2 duo4 bo2 xian2 ge3 chuan2 lu2 xi1 shao1 ting3 wei3 meng3 shou3 sou1 cao2 chong1 meng2 gen3 liang2 jian1 se4 yan4 fu2 cao3 yi4 jiao1 ai4 nai3 jie2 wan2 mi3 qian1 yu4 shao2 qiong1 du4 qi3 mang2 xiang1 pi2 fu2 wu2 zhi1 shan1 qian4 kou1 jie4 lu2 ji1 qin2 qi2 yan2 fen1 ba1 rui4 xin1 ji4 hua1 fang1 wu4 zhi3 yun2 qin2 ya2 fei4 cong1 bian4 wei3 li4 e4 xian4 chang2 cang1 zhu4 su1 yuan4 ran3 ling2 tai2 shao2 miao2 qing3 ke1 mu4 bao1 gou3 min2 yi3 ju4 pie3 ruo4 ku3 shan1 ben3 ying1 ju1 gan1 ping2 fu2 zhuo2 mao4 fan4 jia1 mao2 mao2 ba2 ci2 mo4 chi2 jing1 long2 niao3 ying2 qiong2 ming2 yin4 gen4 qian4 jian3 ci2 mang2 cha2 jiao1 fu2 zhu1 jiang1 hui2 yin1 cha2 rong1 ru2 chong1 tong2 xun2 quan2 jing1 xing4 cao3 ren3 jian4 ti2 huang1 li4 jia2 rao2 bi4 qiao2 hui4 ji4 dang4 rong2 hun1 xing2 luo4 ying2 xun2 jin4 sun1 yin1 mai3 hong2 zhou4 yao4 he2 bi2 di2 tu2 sui1 li4 pu2 li4 sha1 ju3 mei2 shen1 ting2 you2 guan3 you3 lang4 fu2 e2 mo4 kan3 lai2 lian2 shi2 wo1 xian1 huo4 you2 ying2 ying1 chun2 mang3 wan3 jing1 jian1 gu1 ju2 jun1 he2 fu2 chang1 song1 cai4 ba2 tu2 bo1 han4 xi1 pu2 dang4 gu1 ling2 fei1 yan1 ju1 shu1 qi2 cui4 tao2 bi4 qi1 meng2 ping2 wei1 dan4 huan2 nai4 tie1 luo2 ying2 ying2 ying2 xiao1 sa4 xuan1 yu2 e4 luo4 bao3 feng1 zhu4 xiang1 ren4 ge2 qia1 pu2 dong3 pa1 hu2 zang4 jia1 cong1 wei1 kui2 ting2 xi3 qi4 di4 chan3 kai3 kui4 jiang3 lou2 pai4 lang4 meng2 suan4 bang4 kuai3 pu2 shuo4 zheng1 jian1 ji2 en1 hao1 zhen1 xu4 rong2 weng3 shi1 ru4 suo1 bei4 bi4 lan2 ji4 li2 yu4 ying2 mo4 peng2 xi3 liao3 xu su4 mie4 man4 zhe4 wei4 cu4 cai4 nian1 shu1 qiang2 dou1 lian3 lin4 kou4 ai3 bi4 fan1 xun4 jiao1 rui3 qu2 hui4 zui4 rui2 jue2 qi2 yun4 weng4 ji2 hong2 lei3 bao2 hao1 wei1 yi4 xue1 bi4 xie4 hong1 xin1 sou3 shu3 xun1 ru2 tai2 gao3 ji2 cang2 miao3 xian3 ou3 li2 teng2 fan1 zao3 huo4 heng2 mo2 nie4 qu2 fan2 zhan4 mi2 hu1 hu3 lu3 nve4 lv4 qian2 xu1 yu2 guo2 chong2 qiu2 ji3 shi1 hong2 hui1 meng2 ge4 sui1 xia1 chai4 shi2 yi3 ma3 wen2 rui4 bang4 pi2 yin3 can2 ya2 hao2 gong1 zao3 jie4 fu2 chi1 dou3 xian3 qiu1 you2 zha4 you4 he2 han1 ran2 zhu4 gu1 qu1 she2 ling2 gu3 dan4 li4 cheng1 qu1 mou2 hui2 yang2 wa1 zhu1 kuo4 jiao1 ha2 qiong2 zhi4 man2 zhe2 jia2 nao2 si1 qi2 shao1 yong3 e2 shu3 feng1 shen4 zhe1 wu2 fu2 li2 chu2 yan2 ting2 tui4 wo1 zhi1 fei1 mi4 qi2 la4 meng3 qiang1 xi1 tiao2 yu4 pi2 yi4 quan2 qing1 guo3 wan1 ying2 guo1 chan2 ke1 xie1 yu2 huang2 bian1 fu2 you2 qiu2 mao2 fu4 kui2 hu2 die2 nan3 lou2 chun1 rong2 lang2 pang2 xi1 yuan2 sou1 rong2 qin2 tang2 ming2 man3 shi4 cao2 chi1 ao2 tang2 piao1 luo2 zhong1 shuai4 ma2 mao2 xi1 zhang1 mang3 xiang4 peng2 pan2 huang2 hui4 shan4 xie4 chan2 luo3 lian2 meng3 ru2 huo4 mie4 li2 chun3 juan1 du4 qu2 xue4 nv4 xin4 xing2 yan3 xian2 jie1 ya2 heng2 qu2 yi1 yi1 bu3 biao3 cha3 shan1 chen4 gun3 shuai1 na4 zhong1 ren4 qin1 jin1 yuan2 mei4 ao3 niao3 jia1 dai4 pao2 tan3 xiu4 wa4 pan4 mao4 bei4 xi2 fu2 jia2 ge1 cai2 lie4 zhuang1 dang1 ken4 cheng2 pou2 yi4 yu4 qiu2 qun2 sha1 lian2 lian3 ku4 jian3 bi4 duo1 biao3 shang pei2 luo3 guo3 ti4 ju1 gua4 bian3 he4 bao1 bao3 bei4 chu3 lv3 da1 ru4 tui4 chi3 qian1 lan2 zhe3 qiang3 xiang1 bi4 jin1 ru2 pan4 xi1 yao4 tan2 fu4 jian4 guan1 gui1 mi4 shi4 chan1 lan3 jue2 ji4 xi2 di2 yu2 gou4 jin4 qu4 jiao3 jue2 gu1 zi1 shang1 jie3 gong1 chu4 su4 zhi4 hu2 yan2 hong1 zi1 li4 zhan1 yu4 teng2 shi4 jian3 qing3 jing3 pi4 yan2 ji4 ding4 fu4 ren4 ji1 jie2 hong4 tao3 rang4 shan4 qi4 xun4 yi4 xun4 ji4 jiang3 hui4 ou1 ju4 ya4 ne4 xu3 e2 lun4 song4 feng3 she4 fang3 jue2 zheng4 gu3 he1 ping2 zu3 shi2 zha4 su4 zhen3 di3 zhou1 ci2 qu1 zhao4 yi4 yi2 kuang1 lei3 shi4 gua4 shi1 ji2 hui1 cheng2 zhu1 shen1 hua4 dan4 gou4 quan2 gui3 xun2 yi4 zheng4 gai1 xiang2 cha4 hun4 xu3 jie4 wu1 yu3 qiao4 wu4 gao4 you4 hui4 kuang2 shuo1 song4 ei2 qing3 zhu1 zou1 nuo4 du2 zhuo2 fei3 ke4 wei3 yu2 shui2 shen3 diao4 chan3 liang4 zhun1 sui4 tan2 yi4 mou2 chen2 die2 huang3 jian4 xie2 xue4 ye4 wei4 e4 yu4 xuan1 chan2 zi1 an1 yan4 di4 mi2 pian2 mo2 dang3 su4 xie4 yao2 bang4 shi4 qian1 mi4 jin3 man2 zhe2 jian3 miu4 tan2 zen4 qiao2 lan2 pu3 jue2 yan4 qian3 zhan1 chen4 gu3 huo1 dou4 jiang1 shi4 wan1 shi3 tun2 xiang4 huan4 hao2 yu4 bin1 zhi4 bao4 chai2 diao1 xiu1 hao2 mo4 mao4 pi2 mo4 bei4 zhen1 fu4 gong4 cai2 ze2 xian2 bai4 zhang4 huo4 zhi4 fan4 tan1 pin2 bian3 gou4 zhu4 guan4 er4 jian4 ben1 shi4 tie1 gui4 kuang4 dai4 mao4 fei4 he4 yi2 zei2 zhi4 jia3 hui4 zi1 lin4 lu4 zang1 zi1 gai1 jin4 qiu2 zhen4 lai4 she1 fu4 du3 ji1 shu2 shang3 ci4 geng1 pei2 dan3 lai4 zhui4 fu4 zhuan4 sai4 ze2 yan4 zan4 zeng4 shan4 ying2 gan4 chi4 she4 nan3 he4 zhe3 zou3 jiu1 fu4 zhao4 gan3 qi3 chen4 ju1 chao1 yue4 qu1 zi1 lie4 tang4 qu4 zan3 zu2 pa1 bao4 dun3 fu1 jian3 zhi3 ta1 yue4 qiang1 tai2 ba2 die1 tuo2 jia1 pao3 zhi2 fu1 shan1 bo3 ju4 li4 gen1 xian3 jiao1 kua4 gui4 qiong2 kui3 lu4 tiao4 jian4 qiao1 bi4 xian1 duo4 ji1 ji4 xue2 liang2 yong3 chou2 ta4 chuo1 huai2 ju4 chi2 ti1 bo2 cai3 zong1 zhi4 dian3 zhi2 duo2 zhong3 chuai4 jian4 ju3 die2 pian2 rou2 ti2 jian3 dao3 cuo1 qi1 ta4 nie4 pan2 cu4 beng4 bie2 deng1 ceng4 fan2 chu2 dun1 cu4 jue2 pu3 cuan1 zao4 zhu2 chu2 lin4 lie4 chan2 zuan1 xie4 shen1 gong1 qu1 duo3 tang3 wei4 che1 ya4 gui3 xuan1 ren4 zhuan3 e4 lun2 ruan3 hong1 gu1 ke1 lu2 zhou2 zhi3 yi4 hu1 zhen3 li4 yao2 qing1 shi4 zai4 zhi4 jiao4 quan2 lu4 jiao4 zhe2 fu3 liang4 nian3 bei4 hui1 gun3 wang3 chuo4 zi1 cou4 fu2 ji2 shu1 pei4 yuan2 xia2 nian3 lu4 zhe2 lin2 xin1 gu1 ci2 pi4 la4 bian4 bian4 bian4 chen2 ru3 chuo4 bian1 liao2 da2 qian1 yu1 qi4 xun4 guo4 mai4 ying2 yun4 jin4 ya4 fan3 wu4 hai2 zhe4 jin4 yuan3 wei2 lian2 chi2 tiao2 yi2 jiong3 jia1 dai4 er3 di2 po4 die2 ze2 shu4 jing4 mi2 beng4 ji4 zhui1 tui4 song4 shi4 tao2 pang2 hou4 ni4 xuan3 xun4 bu1 xiao1 tou4 zhu2 qiu2 di4 tu2 ti4 dou4 tong1 guang4 shi4 cheng3 su4 zao4 qun1 feng2 li3 huan4 dai3 lu4 kui2 wei1 yi4 luo2 bi1 yu2 dun4 sui4 chuan2 yu4 bian4 e4 xia2 huang2 qiu2 dao4 yi2 gou4 liu2 ta4 qian3 yao2 ao2 zao1 zhe1 lin2 zun1 ju4 bi4 yao1 xie4 sui4 miao3 la1 yi4 deng4 yong1 han2 mang2 qiong2 kuang4 fang1 xing2 na4 bang1 xie2 wu1 you2 han2 tai2 qiu1 pi1 bing3 shao4 bei4 di3 zou1 ye4 lin2 zhu1 yu4 qie4 zhi4 huan2 jiao1 lang2 jia2 kuai4 zheng4 yun4 xi1 fu2 gao4 hao3 jun4 ying3 li4 yun2 bu4 pi2 guo1 tan2 chen1 dan1 dou1 yan3 e4 juan4 bi3 yin2 yan1 zhang1 shan4 po2 zou1 ling2 feng1 you3 ding1 qiu2 zhuo2 pei4 zhou4 yi3 gan1 jiu3 xu4 fen1 yun4 tai4 tuo2 cu4 han1 gu1 su1 ming3 lao4 chou2 tong2 zhi3 xian1 jiang4 cheng2 tu2 jiao4 mei2 ku4 suan1 lei4 yan4 shai1 niang4 pei1 chun2 zui4 cu4 kun1 ti2 hu2 xu3 xing3 mi2 quan2 hai3 tang2 lao2 bu2 jiao4 xi1 li3 ju4 xun1 cai3 you4 shi4 li3 zhong4 ye3 liang4 jin1 fu3 jian4 qiong2 luan2 wu4 zan4 mou2 liu2 ao4 ao2 bei4 xin1 jin1 ga2 yi3 zhen1 ding1 zhao1 po1 liao3 tu3 qian1 chuan4 shan1 fan2 diao4 men2 nv3 chai1 gai4 bu4 tai4 ju4 dun4 chao1 zhong1 na4 bei4 gang1 ban3 qian2 yao4 qin1 jun1 wu1 gou1 kang4 fang1 huo3 tou3 niu3 ba3 yu4 qian2 zheng1 qian2 gu3 bo1 ke1 po3 bu1 bo2 yue4 zuan1 mu4 tan3 jia3 dian4 you2 tie3 bo2 ling2 shuo4 qian1 mao3 shi4 xuan4 ta1 bi4 ni2 pi1 duo2 kao4 lao3 er3 you3 cheng2 jia2 ye2 nao2 dang1 tong2 lv3 diao4 yin1 kai3 zha2 zhu1 xi3 ding4 diu1 hua2 quan2 sha1 ha1 diao4 ge4 ming2 zheng1 se4 jiao3 yi1 chan3 chong4 tang1 an3 yin2 ru2 zhu4 lao2 pu4 lai2 te4 lian4 keng1 xiao1 suo3 li3 zeng4 chu2 guo1 gao4 e2 xiu4 cuo4 lve4 feng1 xin1 liu3 kai1 jian3 rui4 ti1 lang2 qin3 ju1 a1 qiang1 zhe3 nuo4 cuo4 mao2 ben1 de2 ke4 kun1 xi1 gu4 luo2 chui2 zhui1 jin3 xian1 juan3 huo1 pei2 tan2 ding4 jian4 ju4 meng3 zi1 qie4 kai3 qiang1 si1 e4 cha1 qiao1 zhong1 duan4 sou1 huan2 ai1 du4 mei3 lou4 fei4 mei2 mo4 zhen4 ge2 nie4 juan1 nie4 na2 liu2 gao3 bang4 yi4 jia1 bin1 biao1 tang1 man4 luo2 yong1 jing4 di1 zu2 xuan4 chan2 jue2 liao4 pu2 lu3 dui4 lan2 pu3 cuan1 qiang1 deng4 huo4 lei2 zhuo2 lian2 yi4 cha3 biao1 xiang1 zhang3 men2 shuan1 shan3 yan2 bi4 wen4 chuang3 run4 wei2 xian2 hong2 jian1 min3 kang1 men4 zha2 nao4 gui1 wen2 ta4 min3 lv2 fa2 ge2 he2 kun3 jiu1 yue4 lang2 yu4 yan1 chang1 xi4 wen2 hun1 yan2 e4 chan3 lan2 qu4 kuo4 que4 he2 tian2 que1 han3 fu4 fu4 dui4 qian1 wu4 ban3 ruan3 jing3 fang2 yang2 yin1 zhen4 jie1 zu3 zuo4 dian4 a1 tuo2 bei1 fu4 ji4 lu4 long3 chen2 xing2 lou4 mo4 jiang4 xian4 gai1 shan3 bi4 zhi4 dou3 yuan4 chu2 nie4 yun3 xian3 pei2 zou1 chui2 pi2 ling2 tao2 xian4 yu2 long2 wei1 sui2 huang2 sui2 yin3 ge2 kui2 ai4 xi4 zhang4 sui4 xi2 hui1 li4 zhui1 sun3 juan4 nan2 que4 yan4 xiong2 ya3 ji2 gu4 zhi4 ci2 yong1 ju1 chu2 luo4 diao1 chou2 yu3 yu2 xue3 wen2 li4 ling2 lei2 bao2 wu4 xu1 ji4 xiao1 ting2 zhen4 pei4 mei2 huo4 sha4 fei1 ni2 lin2 shuang1 xia2 yin2 ai3 xian4 lu4 ba4 pi1 mai2 qing1 jing4 jing4 jing4 dian4 fei1 kao4 mi2 mian4 ye4 ge2 jin4 xue1 ba3 da2 yang1 xie2 an1 da2 qiao2 man2 qiao4 ju1 rou2 ju1 bian1 jian1 gou1 bei4 wei2 ren4 han2 wei3 yun4 tao1 jiu3 yin1 yun4 shao2 ye4 ding3 qing3 han1 xiang4 shun4 xu1 xu1 wan2 gu4 dun4 qi2 ban1 song4 hang2 yu4 lu2 ling3 po3 jing3 jie2 jia2 he2 ying3 ke1 yi2 pin2 tui2 han4 ying3 ke1 ti2 e4 zhuan1 yan2 e2 nie4 man1 dian1 sang3 hao4 chan4 ru2 pin2 quan2 feng1 biao1 sa4 ju4 sou1 piao1 biao1 biao1 fei1 shi2 sun1 xiang3 yan4 can1 tie4 yong1 tao1 shi2 ji1 tang2 tun2 xi4 ren4 yu4 chi4 fan4 yin3 jian4 shi4 bao3 si4 yi2 er3 rao2 xiang3 jiao3 bing3 bo1 e4 yu2 nei3 hun2 xian4 guan3 cha1 kui4 sou1 chan2 mo2 liu2 xiu1 jin3 man2 san3 zhuan4 nang2 shou3 kui2 guo2 xiang1 fu4 xin1 ma3 yu4 tuo2 xun4 chi2 qu1 bo2 lv2 zang3 shi3 si4 fu4 ju1 zou1 zhu4 tuo2 nu2 jia4 yi4 dai4 xiao1 ma4 jiao1 hua2 luo4 hai4 pian2 li2 cheng3 yan4 jun4 qi2 qi2 ke4 zhui1 can1 pian4 zhi4 sao1 wu4 ao4 liu2 qian1 shan4 biao1 luo2 cong1 chan3 zhou4 ji4 xiang1 gu3 tou2 jie4 di3 ku1 hai2 hou2 ge2 bi4 ke1 qia4 lou2 kuan1 bin4 du2 sui3 gao1 biao1 kun1 mao2 tiao2 zi1 ran2 xiu1 ji4 zong1 quan2 jiu1 bin4 huan2 lie4 chang4 ge2 yu4 gui3 kui2 hun2 ba2 po4 mei4 yan3 xiao1 liang3 wang3 wei4 chi1 mo2 yu2 you2 lu3 fang2 ba4 ping2 nian2 lu2 fu4 bao4 hou4 tai2 gui1 jie2 wei3 er2 ji4 jiao1 xian1 xiang3 xun2 geng3 li2 lian2 jian1 li3 shi2 tiao2 gun3 sha1 huan4 ji4 qing1 ling2 zou1 fei1 kun1 chang1 gu4 ni2 nian2 diao1 jing1 shi1 zi1 fen4 die2 sai1 e4 qiu1 fu4 huang2 bian1 sao1 ao2 qi2 ta3 guan1 yao2 le4 biao4 xue3 bie1 man2 min3 yong1 gui4 shan4 lin2 zun1 li3 niao3 jiu1 ji1 yuan1 ming2 ou1 ya1 bao3 zhen4 gu1 dong1 lu2 ya1 yang1 chi1 qu2 yuan1 tuo2 si1 zhi4 er2 gua1 xiu1 ge1 luan2 hong2 bo2 li2 juan1 gu3 e2 yu4 xian2 ti2 wu3 que4 miao2 an1 bei1 peng2 chun2 hu2 e4 gu3 ci2 mei2 wu4 yao4 jian1 he4 ying1 zhe4 liu4 liao2 jiao1 jiu4 yu4 lu4 ying1 hu4 guan4 cuo2 lu4 ji3 jun1 zhu3 mi2 qi2 lu4 she4 lin2 mai4 qu1 fu1 ma2 mo2 hui1 huang2 hong2 shu3 li2 nian2 hei1 qian2 mo4 dai4 chu4 you3 yi1 xia2 qu1 qing2 li2 du2 can3 an4 zhi3 fu2 fu3 min3 yuan2 tuo2 ding3 nai4 gu3 tao2 pi2 shu3 fen2 you4 wu2 xi1 yan3 bi2 qiu2 han1 zha1 qi2 ji1 chi3 chen4 ju3 ling2 bao1 tiao2 zi1 ken3 yu3 chuo4 qu3 wo4 long2 gong1 kan1 gui1 yue4'

# ===== 核心：shortlex / axn =====
function axn([int]$k) {
    $a = 1
    while (-not (((1 -shl $a) - 2) -le $k -and $k -le ((1 -shl ($a + 1)) - 3))) { $a++ }
    $n = $k - ((1 -shl $a) - 2)
    return @($a, $n)
}
function codeAt([int]$k) { $p = axn $k; return ("{0}x{1}" -f $p[0], $p[1]) }
function kOfChar([char]$c) {
    $o = [int][char]$c
    if ($o -ge 65 -and $o -le 90) { return ($o - 65) }
    if ($o -ge 48 -and $o -le 57) { return ($o - 48 + 26) }
    if ($o -ge 97 -and $o -le 122) { return ($o - 97 + 66) }
    if ($c -eq '+') { return 92 }; if ($c -eq '/') { return 93 }; if ($c -eq '=') { return 94 }
    return $null
}
function codeLegacy([string]$ch) {
    $k = -1
    if ($ch -match '^[A-Z]$') { $k = [int][char]$ch[0] - 65 }
    elseif ($ch -match '^[0-9]$') { $k = [int][char]$ch[0] - 48 + 26 }
    else {
        for ($i = 0; $i -lt $script:LEGACY.Count; $i++) {
            if ([string]$script:LEGACY[$i] -ceq $ch) { $k = $i; break }
        }
    }
    if ($k -ge 0) { return (codeAt $k) }
    return $null
}
function charOfCode([string]$cd) {
    $p = $cd -split 'x'
    if ($p.Count -ne 2) { return '' }
    $k = (1 -shl [int]$p[0]) - 2 + [int]$p[1]
    if ($k -ge 0 -and $k -le 25) { return [string][char](65 + $k) }
    if ($k -ge 26 -and $k -le 35) { return [string][char](48 + $k - 26) }
    if ($k -ge 36 -and $k -le 39) { return [string]$script:TONES[$k - 36] }
    if ($k -ge 40 -and $k -le 53) { return [string]$script:QUAN[$k - 40] }
    if ($k -ge 54 -and $k -le 65) { return [string]$script:BAN[$k - 54] }
    if ($k -ge 66 -and $k -le 91) { return [string][char](97 + $k - 66) }
    if ($k -eq 92) { return '+' }; if ($k -eq 93) { return '/' }; if ($k -eq 94) { return '=' }
    return ''
}

# ===== v1 =====
$script:CODEMAP = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([System.StringComparer]::Ordinal)
foreach ($ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz+/='.ToCharArray()) {
    $k = kOfChar $ch; if ($null -ne $k) { $script:CODEMAP[[string]$ch] = codeAt $k }
}
function buildV1Ascii([string]$s) {
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('['); $first = $true
    foreach ($ch in $s.ToCharArray()) {
        $cd = $script:CODEMAP[[string]$ch]
        if ($cd) { if (-not $first) { [void]$sb.Append('-') }; [void]$sb.Append($cd); $first = $false }
    }
    [void]$sb.Append(']'); return $sb.ToString()
}
$script:CODEINV = New-Object 'System.Collections.Generic.Dictionary[string,char]' ([System.StringComparer]::Ordinal)
foreach ($ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz+/='.ToCharArray()) {
    $k = kOfChar $ch; if ($null -ne $k) { $script:CODEINV[(codeAt $k)] = $ch }
}
function fromV1Ascii([string]$v1) {
    $inner = $v1.Substring(1, $v1.Length - 2)
    $sb = New-Object System.Text.StringBuilder
    foreach ($cd in $inner.Split([char]'-', [StringSplitOptions]::RemoveEmptyEntries)) {
        $c = [char]0; if ($script:CODEINV.TryGetValue($cd, [ref]$c)) { [void]$sb.Append($c) }
    }
    return $sb.ToString()
}
function tokenize([string]$text) {
    $out = New-Object System.Collections.Generic.List[string]; $i = 0
    while ($i -lt $text.Length) {
        $c = [string]$text[$i]
        if ($c -eq '…') { [void]$out.Add('……'); if ($i + 1 -lt $text.Length -and $text[$i+1] -eq '…') { $i++ }; $i++; continue }
        if ($c -eq [string][char]0x201D) { [void]$out.Add([string][char]0x201C); $i++; continue }
        if ($c -eq [string][char]0x2018) { [void]$out.Add([string][char]0x2019); $i++; continue }
        [void]$out.Add($c); $i++
    }
    return $out
}
function pinyinCodes([string]$py) {
    $out = New-Object System.Collections.Generic.List[string]
    $m = [regex]::Match($py, '^([a-z]+)([1-4])?$')
    if (-not $m.Success) { return $out }
    foreach ($c in $m.Groups[1].Value.ToUpper().ToCharArray()) { $cd = codeLegacy ([string]$c); if ($cd) { [void]$out.Add($cd) } }
    if ($m.Groups[2].Success) { [void]$out.Add((codeAt (36 + [int]$m.Groups[2].Value - 1))) }
    return $out
}
function buildV1([string]$plain) {
    $blocks = New-Object System.Collections.Generic.List[object]; $cur = $null
    foreach ($ch in (tokenize $plain)) {
        if ($script:dict.ContainsKey($ch)) {
            if ($null -eq $cur -or $cur.type -ne 'zh') { $cur = @{ type='zh'; segs=(New-Object System.Collections.Generic.List[object]) }; [void]$blocks.Add($cur) }
            [void]$cur.segs.Add((pinyinCodes $script:dict[$ch]))
        } elseif ([char]::IsWhiteSpace([char]$ch[0])) {
            if ($null -eq $cur -or $cur.type -ne 'en') { $cur = @{ type='en'; segs=(New-Object System.Collections.Generic.List[object]) }; [void]$cur.segs.Add((New-Object System.Collections.Generic.List[string])); [void]$blocks.Add($cur) }
            if ($cur.segs[$cur.segs.Count-1].Count -gt 0) { [void]$cur.segs.Add((New-Object System.Collections.Generic.List[string])) }
        } else {
            if ($null -eq $cur -or $cur.type -ne 'en') { $cur = @{ type='en'; segs=(New-Object System.Collections.Generic.List[object]) }; [void]$cur.segs.Add((New-Object System.Collections.Generic.List[string])); [void]$blocks.Add($cur) }
            $cd = codeLegacy $ch.ToUpper(); if ($cd) { [void]$cur.segs[$cur.segs.Count-1].Add($cd) }
        }
    }
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($b in $blocks) {
        $segs = @($b.segs | Where-Object { $_.Count -gt 0 })
        if ($segs.Count -gt 0) {
            $inner = ($segs | ForEach-Object { $_ -join '-' }) -join '+'
            [void]$parts.Add($(if ($b.type -eq 'zh') { 'P[' } else { '[' }) + $inner + ']')
        }
    }
    return ($parts -join '·')
}
function markTone([string]$py, [int]$t) {
    $py = $py.ToLower()
    if ($t -lt 1 -or $t -gt 4) { return $py.Replace('v', 'ü') }
    $pos = -1; $v = ''
    foreach ($c in @('a','o','e')) { $i = $py.IndexOf($c); if ($i -ge 0) { $pos = $i; $v = $c; break } }
    if ($pos -lt 0) { for ($i = $py.Length - 1; $i -ge 0; $i--) { if ('iuv'.Contains([string]$py[$i])) { $pos = $i; $v = [string]$py[$i]; break } } }
    if ($pos -lt 0) { return $py.Replace('v', 'ü') }
    $res = $py.Substring(0, $pos) + $script:MARKS[$v][$t-1] + $py.Substring($pos + 1)
    return $res.Replace('v', 'ü')
}
function fromV1([string]$v1) {
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($b in ($v1 -split '·')) {
        if (-not $b) { continue }
        $zh = $b.StartsWith('P[')
        $inner = if ($zh) { $b.Substring(2, $b.Length - 3) } else { $b.Substring(1, $b.Length - 2) }
        $rendered = New-Object System.Collections.Generic.List[string]
        foreach ($seg in ($inner -split '\+')) {
            if ($zh) {
                $letters = ''; $tone = 0
                foreach ($cd in ($seg -split '-')) {
                    if (-not $cd) { continue }
                    $ch = charOfCode $cd
                    $ti = [array]::IndexOf($script:TONES, $ch)
                    if ($ti -ge 0) { $tone = $ti + 1 } elseif ($ch) { $letters += $ch.ToLower() }
                }
                [void]$rendered.Add((markTone $letters $tone))
            } else {
                $s = ''; foreach ($cd in ($seg -split '-')) { if ($cd) { $s += (charOfCode $cd) } }
                [void]$rendered.Add($s)
            }
        }
        [void]$out.Add(($rendered -join ' '))
    }
    return ($out -join ' ')
}

# ===== v2 / v2.1 / v2.2 通用（按 · 分块）=====
function compressSeg([string]$seg) {
    $us = $seg.Split([char]'-', [StringSplitOptions]::RemoveEmptyEntries)
    $sb = New-Object System.Text.StringBuilder; $i = 0
    while ($i -lt $us.Length) {
        $u = $us[$i]; $xp = $u.IndexOf('x')
        if ($xp -lt 0) { if ($sb.Length -gt 0) { [void]$sb.Append('-') }; [void]$sb.Append($u); $i++; continue }
        $a = $u.Substring(0, $xp)
        if ($sb.Length -gt 0) { [void]$sb.Append('-') }
        [void]$sb.Append($a).Append('x').Append($u.Substring($xp + 1)); $i++
        while ($i -lt $us.Length) {
            $u2 = $us[$i]; $x2 = $u2.IndexOf('x')
            if ($x2 -lt 0 -or $u2.Substring(0, $x2) -cne $a) { break }
            [void]$sb.Append('/').Append($u2.Substring($x2 + 1)); $i++
        }
    }
    return $sb.ToString()
}
function expandSeg([string]$seg) {
    $sb = New-Object System.Text.StringBuilder; $firstOut = $true
    foreach ($u in $seg.Split([char]'-', [StringSplitOptions]::RemoveEmptyEntries)) {
        $slash = $u.IndexOf('/')
        if ($slash -lt 0) {
            if (-not $firstOut) { [void]$sb.Append('-') }
            [void]$sb.Append($u); $firstOut = $false; continue
        }
        $x = $u.IndexOf('x'); $a = $u.Substring(0, $x)
        $p = $u.Split([char]'/', [StringSplitOptions]::RemoveEmptyEntries)
        for ($j = 0; $j -lt $p.Length; $j++) {
            if (-not $firstOut) { [void]$sb.Append('-') }
            $one = $p[$j]
            if ($one.IndexOf('x') -ge 0) { [void]$sb.Append($one) } else { [void]$sb.Append($a).Append('x').Append($one) }
            $firstOut = $false
        }
    }
    return $sb.ToString()
}
function invertSeg([string]$inner) {
    $toks = New-Object System.Collections.Generic.List[string]
    $i = 0; $n = $inner.Length
    while ($i -lt $n) {
        $c = $inner[$i]
        if ($c -ge '0' -and $c -le '9') {
            $j = $i + 1
            while ($j -lt $n -and $inner[$j] -ge '0' -and $inner[$j] -le '9') { $j++ }
            [void]$toks.Add($inner.Substring($i, $j - $i)); $i = $j
        } else {
            if ($c -eq 'x' -or $c -eq '-' -or $c -eq '+' -or $c -eq '/') { [void]$toks.Add([string]$c) }
            $i++
        }
    }
    $sb = New-Object System.Text.StringBuilder
    for ($k = $toks.Count - 1; $k -ge 0; $k--) { [void]$sb.Append($toks[$k]) }
    return $sb.ToString()
}
function mapBlocks([string]$v, [scriptblock]$fn) {
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($b in ($v -split '·')) {
        if ($b.Length -eq 0) { [void]$parts.Add(''); continue }
        $zh = $b.StartsWith('P[')
        $inner = if ($zh) { $b.Substring(2, $b.Length - 3) } else { $b.Substring(1, $b.Length - 2) }
        [void]$parts.Add($(if ($zh) { 'P[' } else { '[' }) + (& $fn $inner) + ']')
    }
    return ($parts -join '·')
}
function segMap([string]$inner, [scriptblock]$fn) {
    $segs = @($inner -split '\+' | ForEach-Object { & $fn $_ })
    return ($segs -join '+')
}
function toV2([string]$v1) { mapBlocks $v1 { param($i) segMap $i { param($s) compressSeg $s } } }
function fromV2([string]$v2) { mapBlocks $v2 { param($i) segMap $i { param($s) expandSeg $s } } }
function toV21([string]$v2) { mapBlocks $v2 { param($i) invertSeg $i } }
function fenceEnc([string]$s) {
    $a = New-Object System.Text.StringBuilder; $b = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $s.Length; $i++) { if ($i % 2 -eq 0) { [void]$a.Append($s[$i]) } else { [void]$b.Append($s[$i]) } }
    return ($a.ToString() + $b.ToString())
}
function fenceDec([string]$s) {
    $h = [int][math]::Floor(($s.Length + 1) / 2); $odd = $s.Substring(0, $h); $even = $s.Substring($h)
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $h; $i++) { [void]$sb.Append($odd[$i]); if ($i -lt $even.Length) { [void]$sb.Append($even[$i]) } }
    return $sb.ToString()
}

# ===== 对外链路 =====
function encryptV23([string]$plain) {
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($plain))
    $v1 = buildV1Ascii $b64; $v2 = toV2 $v1; $v21 = toV21 $v2
    return @{ b64=$b64; v1=$v1; v2=$v2; v21=$v21; cipher=(fenceEnc $v21) }
}
function decryptV23([string]$cipher) {
    $c = [regex]::Replace($cipher, '\s+', '')
    $v21 = fenceDec $c; $v2 = toV21 $v21; $v1 = fromV2 $v2
    $b64 = fromV1Ascii $v1
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
}
function encText([string]$plain, [string]$ver) {
    if ($ver -eq 'v2.4') { return (encryptV23 $plain).cipher }
    $v1 = buildV1 $plain; $v2 = toV2 $v1; $v21 = toV21 $v2; return (fenceEnc $v21)
}
function decText([string]$cipher, [string]$ver) {
    $c = [regex]::Replace($cipher, '\s+', '')
    $v21 = fenceDec $c; $v2 = toV21 $v21; $v1 = fromV2 $v2
    if ($ver -eq 'v2.4') { return decryptV23 $cipher }
    return fromV1 $v1
}

# ===== 进度条 =====
function fmtEta($sec) { if ($null -eq $sec) { return '--:--' }; $s = [int]$s = [int]$sec; if ($s -lt 60) { return ('00:{0:D2}' -f $s) }; return ('{0:D2}:{1:D2}' -f [int][math]::Floor($s/60), ($s % 60)) }
function makeProgress([string]$label) {
    $sw = [Diagnostics.Stopwatch]::StartNew(); $start = [DateTime]::UtcNow; $dot = 0; $width = 50
    try { $width = [Console]::WindowWidth - 34; if ($width -lt 20) { $width = 20 } } catch { $width = 50 }
    return {
        param($done, $total)
        $dot = ($dot + 1) % 3; $dots = '.' * ($dot + 1)
        $pct = if ($total -gt 0) { [int][math]::Floor(100 * $done / $total) } else { 0 }
        $fill = [int][math]::Floor($width * $pct / 100); $bar = ('#' * $fill) + (' ' * ($width - $fill))
        $eta = '--:--'
        if ($done -gt 0 -and $total -gt 0) { $elapsed = ([DateTime]::UtcNow - $start).TotalSeconds; $eta = fmtEta ($elapsed * ($total - $done) / $done) }
        [Console]::Error.Write(("`r{0}{1} {2,3}%[{3}]  ETA {4}" -f $label, $dots, $pct, $bar, $eta))
    }.GetNewClosure()
}
function progDone() { [Console]::Error.WriteLine('') }

# ===== 文件密文编解码（分块 + jm.tmp）=====
function fileCipherEncodeToWriter([byte[]]$data, $writer, $prog) {
    $b64 = [Convert]::ToBase64String($data)
    $parts = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $b64.Length; $i += $script:CHUNK_B64) { [void]$parts.Add($b64.Substring($i, [math]::Min($script:CHUNK_B64, $b64.Length - $i))) }
    if ($parts.Count -eq 0) { [void]$parts.Add('') }
    & $prog 0 $parts.Count
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $c = (encryptV23 $parts[$i]).cipher
        if ($i -gt 0) { $writer.Write('|') }
        $writer.Write($c); $writer.Flush()
        & $prog ($i + 1) $parts.Count
    }
}
function fileCipherDecode([string]$fileCipher, $prog) {
    $parts = @($fileCipher -split '\|' | Where-Object { $_ -ne '' })
    & $prog 0 $parts.Count
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $parts.Count; $i++) { [void]$sb.Append((decryptV23 $parts[$i])); & $prog ($i + 1) $parts.Count }
    return $sb.ToString()
}
function finalizeCache([string]$out) {
    $out = $out.Trim().Trim('"').Trim("'")
    if (-not $out) { Write-Output '未指定输出文件'; return }
    if ([IO.Path]::GetFullPath($out) -eq [IO.Path]::GetFullPath($script:CACHE)) { return }
    try {
        if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
        Move-Item -LiteralPath $script:CACHE -Destination $out -Force
    } catch {
        Copy-Item -LiteralPath $script:CACHE -Destination $out -Force; Remove-Item -LiteralPath $script:CACHE -Force
    }
    if (Test-Path -LiteralPath $script:CACHE) { Remove-Item -LiteralPath $script:CACHE -Force -ErrorAction SilentlyContinue }
    Write-Output ("密文已写入 {0}（{1} 字节）" -f $out, (Get-Item -LiteralPath $out).Length)
}
function safeName([string]$name) {
    $n = [IO.Path]::GetFileName($name.Replace('\','/'))
    if (-not $n) { $n = 'restored.bin' }
    $out = $n
    if (Test-Path -LiteralPath $out) {
        $stem = [IO.Path]::GetFileNameWithoutExtension($n); $ext = [IO.Path]::GetExtension($n); $i = 1
        while (Test-Path -LiteralPath ("{0}_{1}{2}" -f $stem, $i, $ext)) { $i++ }
        $out = ("{0}_{1}{2}" -f $stem, $i, $ext)
    }
    return $out
}

# ===== 命令实现 =====
function cmdFileEnc([string]$path, [string]$out) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Write-Output ("文件不存在：{0}" -f $path); return }
    $out = $out.Trim().Trim('"').Trim("'")
    if (-not $out) { Write-Output '未指定输出文件'; return }
    $data = [IO.File]::ReadAllBytes($path); if ($data.Length -eq 0) { Write-Output '文件为空'; return }
    $name = [IO.Path]::GetFileName($path)
    $nameCipher = (encryptV23 $name).cipher
    $prog = makeProgress '加密中'
    $sw = New-Object IO.StreamWriter($script:CACHE, $false, (New-Object Text.UTF8Encoding($false)))
    try { $sw.Write($nameCipher + '@'); $sw.Flush(); fileCipherEncodeToWriter $data $sw $prog }
    finally { $sw.Dispose() }
    progDone; finalizeCache $out
}
function autoRestore([string]$cipher) {
    $at = $cipher.IndexOf('@')
    if ($at -lt 1 -or $at -ge $cipher.Length - 1) { Write-Output '解码失败'; return }
    try {
        $name = decryptV23 $cipher.Substring(0, $at)
        $b64 = (fileCipherDecode $cipher.Substring($at + 1) (makeProgress '解密中')) -replace '\s',''
        if (-not $name -or -not ($b64 -match '^[A-Za-z0-9+/]+={0,2}$') -or $b64.Length % 4 -ne 0) { Write-Output '解码失败'; return }
        $data = [Convert]::FromBase64String($b64)
    } catch { Write-Output '解码失败'; return }
    progDone
    $out = safeName $name
    [IO.File]::WriteAllBytes($out, $data)
    Write-Output ("已自动还原文件：{0}（{1} 字节）" -f $out, $data.Length)
}
function cmdFileDec([string]$cipher) { if ($cipher -like '*@*') { autoRestore $cipher } else { Write-Output '解码失败' } }

# ---- 段对象：[pscustomobject]@{kind='text'|'file'; val=...} ----
function MixEncFromSegs([object[]]$segs, [string]$out) {
    if ($null -eq $segs -or $segs.Count -eq 0) { Write-Output '输入为空'; return }
    $prog = makeProgress '加密中'; $total = 0
    foreach ($sg in $segs) {
        $p = ([string]$sg.val).Trim().Trim('"').Trim("'")
        if ($sg.kind -eq 'file' -and $p -and (Test-Path -LiteralPath $p -PathType Leaf)) {
            $sz = (Get-Item -LiteralPath $p).Length
            $bl = if ($sz -eq 0) { 1 } else { [math]::Max(1, [int][math]::Ceiling((((($sz + 2) / 3) * 4)) / $script:CHUNK_B64)) }
            $total += $bl
        } else { $total += 1 }
    }
    $done = [ref]0
    & $prog 0 $total
    $sw = New-Object IO.StreamWriter($script:CACHE, $false, (New-Object Text.UTF8Encoding($false)))
    try {
        for ($si = 0; $si -lt $segs.Count; $si++) {
            if ($si -gt 0) { $sw.Write('#') }
            $sg = $segs[$si]
            $s = ([string]$sg.val).Trim().Trim('"').Trim("'")
            if ($sg.kind -eq 'file' -and $s -and (Test-Path -LiteralPath $s -PathType Leaf)) {
                $data = [IO.File]::ReadAllBytes($s); $name = [IO.Path]::GetFileName($s)
                $sw.Write((encryptV23 $name).cipher + '@'); $sw.Flush()
                $b64 = [Convert]::ToBase64String($data)
                $parts = New-Object System.Collections.Generic.List[string]
                for ($i = 0; $i -lt $b64.Length; $i += $script:CHUNK_B64) { [void]$parts.Add($b64.Substring($i, [math]::Min($script:CHUNK_B64, $b64.Length - $i))) }
                if ($parts.Count -eq 0) { [void]$parts.Add('') }
                for ($pi = 0; $pi -lt $parts.Count; $pi++) {
                    if ($pi -gt 0) { $sw.Write('|') }
                    $sw.Write((encryptV23 $parts[$pi]).cipher); $sw.Flush()
                    $done.Value++; & $prog $done.Value $total
                }
            } else {
                $sw.Write((encryptV23 $s).cipher); $sw.Flush(); $done.Value++; & $prog $done.Value $total
            }
        }
    } finally { $sw.Dispose() }
    progDone; finalizeCache $out
}
function mixEncSegments([string[]]$segs, [string]$out) {
    $objs = @($segs | ForEach-Object {
        $p = ([string]$_).Trim().Trim('"').Trim("'")
        [pscustomobject]@{ kind = if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) { 'file' } else { 'text' }; val = $_ }
    })
    MixEncFromSegs $objs $out
}
function cmdMixEnc([string]$raw, [string]$out) {
    $segs = @($raw -split '#' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    if ($segs.Count -eq 0) { Write-Output '输入为空'; return }
    mixEncSegments $segs $out
}

# ---- 文本编辑器：与 Python run_editor 一致（F8 插入文件 / F5 完成 / Esc 取消）----
function ParseEditorSegments([string]$text) {
    $segs = New-Object 'System.Collections.Generic.List[object]'
    $pos = 0
    $re = [regex]'⟦文件:(.*?)⟧'
    foreach ($m in $re.Matches($text)) {
        $pre = $text.Substring($pos, $m.Index - $pos).Trim("`n")
        if ($pre.Trim()) { [void]$segs.Add([pscustomobject]@{ kind = 'text'; val = $pre }) }
        $p = $m.Groups[1].Value.Trim().Trim('"').Trim("'")
        if ($p) { [void]$segs.Add([pscustomobject]@{ kind = 'file'; val = $p }) }
        $pos = $m.Index + $m.Length
    }
    $tail = $text.Substring($pos).Trim("`n")
    if ($tail.Trim()) { [void]$segs.Add([pscustomobject]@{ kind = 'text'; val = $tail }) }
    return $segs.ToArray()
}
function ReadLineRaw() {
    $buf = ''
    while ($true) {
        $k = $null
        try { $k = [Console]::ReadKey($true) } catch { break }
        if ($null -eq $k) { break }
        if ($k.Key -eq 'Enter') { break }
        if ($k.Key -eq 'Backspace') { if ($buf.Length -gt 0) { $buf = $buf.Substring(0, $buf.Length - 1) }; continue }
        if ($k.Key -eq 'Escape') { $buf = ''; break }
        $c = [string]$k.KeyChar
        if ($c -and $c.Length -gt 0 -and [int][char]$c[0] -ge 32) { $buf += $c }
    }
    return $buf
}
# 编辑器逻辑（PowerShell 版）：与 Python _EditorState 对齐
# token = [pscustomobject]@{ k='t'|'f'; v=... }，每行 = List[object]
$script:MK_OPEN = '⟦文件:'
$script:MK_CLOSE = '⟧'

function NewEditorState([string]$initial) {
    $lines = New-Object 'System.Collections.Generic.List[object]'
    $src = if ($initial) { $initial -split "`n" } else { @('') }
    foreach ($s in $src) {
        $L = New-Object 'System.Collections.Generic.List[object]'
        [void]$L.Add([pscustomobject]@{ k = 't'; v = [string]$s })
        [void]$lines.Add($L)
    }
    return @{ lines = $lines; row = 0; ti = 0; ci = 0 }
}

function EdTokenText($t) {
    if ($t.k -eq 't') { return [string]$t.v }
    return ($script:MK_OPEN + $t.v + $script:MK_CLOSE)
}

function EdLineText($L) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($t in $L) { [void]$sb.Append((EdTokenText $t)) }
    return $sb.ToString()
}

function EdToText($st) {
    $arr = @()
    foreach ($L in $st.lines) { $arr += (EdLineText $L) }
    return ($arr -join "`n")
}

function EdFix($st) {
    if ($st.lines.Count -eq 0) {
        $L = New-Object 'System.Collections.Generic.List[object]'
        [void]$L.Add([pscustomobject]@{ k = 't'; v = '' })
        [void]$st.lines.Add($L)
    }
    $st.row = [math]::Max(0, [math]::Min($st.row, $st.lines.Count - 1))
    $L = $st.lines[$st.row]
    if ($L.Count -eq 0) { [void]$L.Add([pscustomobject]@{ k = 't'; v = '' }) }
    $st.ti = [math]::Max(0, [math]::Min($st.ti, $L.Count - 1))
    $t = $L[$st.ti]
    if ($t.k -eq 'f') { $st.ci = 0 }
    else { $st.ci = [math]::Max(0, [math]::Min($st.ci, ([string]$t.v).Length)) }
}

function EdCol($st) {
    $L = $st.lines[$st.row]
    $n = 0
    for ($j = 0; $j -lt $st.ti; $j++) { $n += (EdTokenText $L[$j]).Length }
    return $n + $st.ci + 1
}

function EdInsertChar($st, [string]$val) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    if ($t.k -eq 'f') {
        [void]$L.Insert($st.ti + 1, [pscustomobject]@{ k = 't'; v = $val })
        $st.ti += 1
        $st.ci = $val.Length
    } else {
        $s = [string]$t.v
        $t.v = $s.Substring(0, $st.ci) + $val + $s.Substring($st.ci)
        $st.ci += $val.Length
    }
    EdFix $st
}

function EdBackspace($st) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    if ($t.k -eq 'f') {
        $L.RemoveAt($st.ti); EdFix $st; return
    }
    $s = [string]$t.v
    if ($st.ci -gt 0) {
        $t.v = $s.Substring(0, $st.ci - 1) + $s.Substring($st.ci)
        $st.ci -= 1
        return
    }
    if ($st.ti -gt 0) {
        $prev = $L[$st.ti - 1]
        if ($prev.k -eq 'f') {
            $L.RemoveAt($st.ti - 1)
            $st.ti -= 1
            if ($st.ti -ge 0 -and $L[$st.ti].k -eq 't') { $st.ci = ([string]$L[$st.ti].v).Length } else { $st.ci = 0 }
        } else {
            $pv = [string]$prev.v
            $cv = [string]$t.v
            $prev.v = $pv + $cv
            $L.RemoveAt($st.ti)
            $st.ti -= 1
            $st.ci = $pv.Length
        }
        EdFix $st
        return
    }
    if ($st.row -gt 0) {
        $pl = $st.lines[$st.row - 1]
        $pti = $pl.Count - 1
        if ($pl[$pti].k -eq 't') { $st.ci = ([string]$pl[$pti].v).Length } else { $st.ci = 0 }
        foreach ($tk in $L) { [void]$pl.Add($tk) }
        $st.lines.RemoveAt($st.row)
        $st.row -= 1
        $st.ti = $pti
        EdFix $st
    }
}

function EdDelete($st) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    if ($t.k -eq 'f') {
        $L.RemoveAt($st.ti); EdFix $st; return
    }
    $s = [string]$t.v
    if ($st.ci -lt $s.Length) {
        $t.v = $s.Substring(0, $st.ci) + $s.Substring($st.ci + 1)
        return
    }
    if ($st.ti -lt $L.Count - 1) {
        $nxt = $L[$st.ti + 1]
        if ($nxt.k -eq 'f') {
            $L.RemoveAt($st.ti + 1)
        } else {
            $t.v = ([string]$t.v) + ([string]$nxt.v)
            $L.RemoveAt($st.ti + 1)
        }
        EdFix $st
        return
    }
    if ($st.row -lt $st.lines.Count - 1) {
        $nl = $st.lines[$st.row + 1]
        foreach ($tk in $nl) { [void]$L.Add($tk) }
        $st.lines.RemoveAt($st.row + 1)
    }
}

function EdMove($st, [string]$kind) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    switch ($kind) {
        'left' {
            if ($t.k -eq 't' -and $st.ci -gt 0) { $st.ci -= 1 }
            elseif ($st.ti -gt 0) {
                $st.ti -= 1; $p = $L[$st.ti]
                $st.ci = if ($p.k -eq 't') { ([string]$p.v).Length } else { 0 }
            } elseif ($st.row -gt 0) {
                $st.row -= 1; $L = $st.lines[$st.row]
                $st.ti = $L.Count - 1; $p = $L[$st.ti]
                $st.ci = if ($p.k -eq 't') { ([string]$p.v).Length } else { 0 }
            }
        }
        'right' {
            if ($t.k -eq 't' -and $st.ci -lt ([string]$t.v).Length) { $st.ci += 1 }
            elseif ($st.ti -lt $L.Count - 1) { $st.ti += 1; $st.ci = 0 }
            elseif ($st.row -lt $st.lines.Count - 1) { $st.row += 1; $st.ti = 0; $st.ci = 0 }
        }
        'up' {
            if ($st.row -gt 0) {
                $want = if ($t.k -eq 't') { $st.ci } else { 0 }
                $st.row -= 1; $L = $st.lines[$st.row]
                $st.ti = $L.Count - 1; $p = $L[$st.ti]
                $st.ci = if ($p.k -eq 't') { [math]::Min($want, ([string]$p.v).Length) } else { 0 }
            }
        }
        'down' {
            if ($st.row -lt $st.lines.Count - 1) {
                $want = if ($t.k -eq 't') { $st.ci } else { 0 }
                $st.row += 1; $L = $st.lines[$st.row]
                $st.ti = 0; $p = $L[$st.ti]
                $st.ci = if ($p.k -eq 't') { [math]::Min($want, ([string]$p.v).Length) } else { 0 }
            }
        }
        'home' { $st.ti = 0; $st.ci = 0 }
        'end' {
            $st.ti = $L.Count - 1; $p = $L[$st.ti]
            $st.ci = if ($p.k -eq 't') { ([string]$p.v).Length } else { 0 }
        }
    }
    EdFix $st
}

function EdEnter($st) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    $newL = New-Object 'System.Collections.Generic.List[object]'
    if ($t.k -eq 't') {
        $s = [string]$t.v
        $left = $s.Substring(0, $st.ci)
        $right = $s.Substring($st.ci)
        $keep = New-Object 'System.Collections.Generic.List[object]'
        for ($i = 0; $i -lt $st.ti; $i++) { [void]$keep.Add($L[$i]) }
        [void]$keep.Add([pscustomobject]@{ k = 't'; v = $left })
        [void]$newL.Add([pscustomobject]@{ k = 't'; v = $right })
        for ($i = $st.ti + 1; $i -lt $L.Count; $i++) { [void]$newL.Add($L[$i]) }
        $st.lines[$st.row] = $keep
    } else {
        $keep = New-Object 'System.Collections.Generic.List[object]'
        for ($i = 0; $i -le $st.ti; $i++) { [void]$keep.Add($L[$i]) }
        [void]$newL.Add([pscustomobject]@{ k = 't'; v = '' })
        for ($i = $st.ti + 1; $i -lt $L.Count; $i++) { [void]$newL.Add($L[$i]) }
        $st.lines[$st.row] = $keep
    }
    $st.lines.Insert($st.row + 1, $newL)
    $st.row += 1; $st.ti = 0; $st.ci = 0
    EdFix $st
}

function EdInsertFile($st, [string]$path) {
    $L = $st.lines[$st.row]
    $t = $L[$st.ti]
    $mark = [pscustomobject]@{ k = 'f'; v = $path }
    if ($t.k -eq 't') {
        $s = [string]$t.v
        $left = $s.Substring(0, $st.ci)
        $right = $s.Substring($st.ci)
        $seq = New-Object 'System.Collections.Generic.List[object]'
        $miOff = 0
        if ($left) { [void]$seq.Add([pscustomobject]@{ k = 't'; v = $left }); $miOff = 1 }
        [void]$seq.Add($mark)
        if ($right) { [void]$seq.Add([pscustomobject]@{ k = 't'; v = $right }) }
        $newL = New-Object 'System.Collections.Generic.List[object]'
        for ($i = 0; $i -lt $st.ti; $i++) { [void]$newL.Add($L[$i]) }
        foreach ($x in $seq) { [void]$newL.Add($x) }
        for ($i = $st.ti + 1; $i -lt $L.Count; $i++) { [void]$newL.Add($L[$i]) }
        $st.lines[$st.row] = $newL
        $mi = $st.ti + $miOff
        if ($mi + 1 -lt $newL.Count) { $st.ti = $mi + 1; $st.ci = 0 }
        else { [void]$newL.Add([pscustomobject]@{ k = 't'; v = '' }); $st.ti = $newL.Count - 1; $st.ci = 0 }
    } else {
        [void]$L.Insert($st.ti + 1, $mark)
        $st.ti += 1; $st.ci = 0
    }
    EdFix $st
}

function EdRender($st, $title, [bool]$allowFile) {
    try { [Console]::Clear() } catch {}
    Write-Host ('┌' + ('─' * 58) + '┐')
    Write-Host ('│ ' + $title)
    Write-Host ('├' + ('─' * 58) + '┤')
    Write-Host '│ 直接输入文字 · 方向键移动 · 回车换行 · 退格删除'
    if ($allowFile) { Write-Host '│ F8 插入文件（整块保护） · F5 完成 · Esc 取消' }
    else { Write-Host '│ F5 完成 · Esc 取消' }
    Write-Host ('└' + ('─' * 58) + '┘')
    for ($i = 0; $i -lt $st.lines.Count; $i++) {
        $pfx = if ($i -eq $st.row) { '> ' } else { '  ' }
        Write-Host -NoNewline $pfx
        $L = $st.lines[$i]
        for ($j = 0; $j -lt $L.Count; $j++) {
            $t = $L[$j]
            $s = EdTokenText $t
            if ($i -eq $st.row -and $j -eq $st.ti) {
                if ($t.k -eq 't') {
                    $c = [math]::Min($st.ci, $s.Length)
                    if ($c -gt 0) { Write-Host -NoNewline $s.Substring(0, $c) }
                    if ($c -lt $s.Length) {
                        Write-Host -NoNewline -BackgroundColor White -ForegroundColor Black ($s.Substring($c, 1))
                        if ($c + 1 -lt $s.Length) { Write-Host -NoNewline $s.Substring($c + 1) }
                    } else {
                        Write-Host -NoNewline -BackgroundColor White -ForegroundColor Black ' '
                    }
                } else {
                    Write-Host -NoNewline -BackgroundColor White -ForegroundColor Black $s
                }
            } else {
                Write-Host -NoNewline $s
            }
        }
        Write-Host ''
    }
    Write-Host ('─' * 58)
    Write-Host ("行{0} 列{1} | {2}" -f ($st.row + 1), (EdCol $st), $script:ED_STATUS)
}

function RunEditor([string]$title, [bool]$allowFile = $true) {
    $st = NewEditorState ''
    $script:ED_STATUS = '就绪'
    $ok = $false; $done = $false
    while (-not $done) {
        EdRender $st $title $allowFile
        $k = $null
        try { $k = [Console]::ReadKey($true) } catch { Write-Host '无法读取按键'; $done = $true; break }
        if ($null -eq $k) { $done = $true; break }
        $key = $k.Key.ToString()
        $ch = [string]$k.KeyChar
        switch ($key) {
            'F5' { $ok = $true; $done = $true }
            'Escape' { $ok = $false; $done = $true }
            'Enter' { EdEnter $st; $script:ED_STATUS = '换行' }
            'Backspace' { EdBackspace $st; $script:ED_STATUS = '删除' }
            'Delete' { EdDelete $st; $script:ED_STATUS = '删除' }
            'LeftArrow' { EdMove $st 'left'; $script:ED_STATUS = 'left' }
            'RightArrow' { EdMove $st 'right'; $script:ED_STATUS = 'right' }
            'UpArrow' { EdMove $st 'up'; $script:ED_STATUS = 'up' }
            'DownArrow' { EdMove $st 'down'; $script:ED_STATUS = 'down' }
            'Home' { EdMove $st 'home'; $script:ED_STATUS = 'home' }
            'End' { EdMove $st 'end'; $script:ED_STATUS = 'end' }
            'F8' {
                if (-not $allowFile) { $script:ED_STATUS = '此模式不可插入文件' }
                else {
                    Write-Host '文件路径：'
                    $p = (ReadLineRaw).Trim().Trim('"').Trim("'")
                    if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) {
                        EdInsertFile $st $p
                        $script:ED_STATUS = '已插入：' + [IO.Path]::GetFileName($p)
                    } elseif ($p) { $script:ED_STATUS = '文件不存在' } else { $script:ED_STATUS = '未输入路径' }
                }
            }
            default {
                if ($ch -and $ch.Length -gt 0 -and [int][char]$ch[0] -ge 32) {
                    EdInsertChar $st $ch
                    $script:ED_STATUS = '输入'
                }
            }
        }
    }
    return @{ text = (EdToText $st); ok = $ok }
}

function cmdMixDec([string]$cipher) {
    $cipher = $cipher.Trim(); if (-not $cipher) { Write-Output '解码失败'; return }
    $segs = @($cipher -split '#' | Where-Object { $_ -ne '' })
    $total = 0
    foreach ($seg in $segs) {
        if ($seg -like '*@*') { $fc = $seg.Substring($seg.IndexOf('@') + 1); $total += (@($fc -split '\|' | Where-Object { $_ -ne '' }).Count) }
        else { $total += 1 }
    }
    $prog = makeProgress '解密中'; & $prog 0 $total
    $items = New-Object System.Collections.Generic.List[object]; $used = @{}; $failed = 0; $done = 0
    foreach ($seg in $segs) {
        if ($seg -like '*@*') {
            $at = $seg.IndexOf('@'); $nc = $seg.Substring(0, $at); $fc = $seg.Substring($at + 1)
            $blocks = @($fc -split '\|' | Where-Object { $_ -ne '' }); if ($blocks.Count -eq 0) { $blocks = @('') }
            try { $name = (decryptV23 $nc) } catch { $name = 'restored.bin' }
            $b64sb = New-Object System.Text.StringBuilder; $bad = $false
            foreach ($p in $blocks) {
                try { [void]$b64sb.Append((decryptV23 $p)) } catch { $bad = $true }
                $done++; & $prog $done $total
            }
            if ($bad) { $failed++; continue }
            $b64 = $b64sb.ToString() -replace '\s',''
            try { $data = if ($b64) { [Convert]::FromBase64String($b64) } else { [byte[]]@() } } catch { $failed++; continue }
            $base = [IO.Path]::GetFileName($name.Replace('\','/')); if (-not $base) { $base = 'restored.bin' }
            $stem = [IO.Path]::GetFileNameWithoutExtension($base); $ext = [IO.Path]::GetExtension($base); $i = 1; $out = $base
            while ($used.ContainsKey($out) -or (Test-Path -LiteralPath $out)) { $out = ("{0}_{1}{2}" -f $stem, $i, $ext); $i++ }
            $used[$out] = $true
            try { [IO.File]::WriteAllBytes($out, $data) } catch { $failed++ }
            [void]$items.Add([pscustomobject]@{ kind='file'; name=$out; data=$data })
        } else {
            try { [void]$items.Add([pscustomobject]@{ kind='text'; text=(decryptV23 $seg) }) } catch { $failed++ }
            $done++; & $prog $done $total
        }
    }
    progDone
    $files = @($items | Where-Object { $_.kind -eq 'file' }); $texts = @($items | Where-Object { $_.kind -eq 'text' })
    if ($items.Count -eq 0 -and $failed -eq 0) { return }
    $suffix = if ($failed) { (" · 失败 {0} 段" -f $failed) } else { '' }
    Write-Output ("混合解密完成：文件 {0} 个 · 文本 {1} 段{2}" -f $files.Count, $texts.Count, $suffix)
    $buf = New-Object System.Text.StringBuilder
    foreach ($it in $items) { if ($it.kind -eq 'text') { [void]$buf.Append([string]$it.text) } else { [void]$buf.Append(("[文件：{0}（{1} 字节）]" -f $it.name, $it.data.Length)) } }
    Write-Output '  内容：'; Write-Output ('    ' + $buf.ToString())
    if ($files.Count -gt 0) {
        Write-Output ("  包含{0}个文件（解密时已自动下载到当前目录）：" -f $files.Count)
        for ($i = 0; $i -lt $files.Count; $i++) { Write-Output ("   {0}  {1}（{2} 字节）" -f ($i+1), $files[$i].name, $files[$i].data.Length) }
        if ([Environment]::UserInteractive -and -not $script:NONINTERACTIVE) {
            $again = 0
            while ($true) {
                Write-Host '  输入编号再次下载一份，输入q退出'
                $ans = ReadLineRaw
                $ans = ([string]$ans).Trim()
                if ($ans -eq '' -or $ans -match '^(q|quit|退出)$') { break }
                $idx = 0
                if (-not [int]::TryParse($ans, [ref]$idx) -or $idx -lt 1 -or $idx -gt $files.Count) { Write-Output '  无效编号'; continue }
                $f = $files[$idx - 1]; $stem = [IO.Path]::GetFileNameWithoutExtension($f.name); $ext = [IO.Path]::GetExtension($f.name)
                while ($true) { $again++; $save = ("{0}_下载{1}{2}" -f $stem, $again, $ext); if (-not (Test-Path -LiteralPath $save)) { break } }
                try { [IO.File]::WriteAllBytes($save, $f.data); Write-Output ("  再次下载完成：{0}（{1} 字节）" -f [IO.Path]::GetFullPath($save), $f.data.Length) }
                catch { Write-Output ("  再次下载失败：{0}" -f $_.Exception.Message) }
            }
        }
    }
    if ($failed -and $items.Count -eq 0) { Write-Output '解码失败' }
}

# ===== 命令行 / 菜单 =====
function shell() {
    Write-Output '命令式 CLI · 输入 help 查看命令，quit 返回菜单'
    while ($true) {
        Write-Host -NoNewline 'scipher> '
        $line = ReadLineRaw
        $line = ([string]$line).Trim(); if (-not $line) { continue }
        $parts = $line -split '\s+', 2; $cmd = $parts[0].ToLower(); $arg = if ($parts.Count -gt 1) { $parts[1].Trim() } else { '' }
        if ($cmd -in @('q','quit','exit')) { break }
        elseif ($cmd -in @('h','help','?')) { Write-Output '命令：enc/dec <文本>  file-enc <路径> <输出>  file-dec <密文|路径>  mix-enc <内容> <输出>  mix-dec <密文|路径>  ver [2.2|2.4]  quit' }
        elseif ($cmd -eq 'ver') { if ($arg) { $v = $arg.Trim('v'); if ($v -in @('2.2','2.4')) { $script:VERSION = 'v' + $v; Write-Output ("已切换到 " + $script:VERSION) } else { Write-Output '用法：ver 2.2 或 ver 2.4' } } else { Write-Output ("当前版本：" + $script:VERSION) } }
        elseif ($cmd -in @('enc','dec')) { if (-not $arg) { Write-Output ("用法：{0} <文本>" -f $cmd); continue }; if ($cmd -eq 'enc') { Write-Output (encText $arg $script:VERSION) } else { if ($arg -like '*@*' -and $script:VERSION -eq 'v2.4') { cmdFileDec $arg } else { try { Write-Output (decText $arg $script:VERSION) } catch { Write-Output '解码失败' } } } }
        elseif ($cmd -in @('file-enc','fenc')) { $fp = $arg -split '\s+', 2; if ($fp.Count -lt 2) { Write-Output '用法：file-enc <文件路径> <输出路径>'; continue }; cmdFileEnc $fp[0].Trim('"').Trim("'") $fp[1].Trim('"').Trim("'") }
        elseif ($cmd -in @('file-dec','fdec')) { if (-not $arg) { Write-Output '请提供密文或密文文件路径'; continue }; cmdFileDec (readCipherArg $arg) }
        elseif ($cmd -in @('mix-enc','menc')) { $fp = $arg -split '\s+', 2; if ($fp.Count -lt 2) { Write-Output '用法：mix-enc <用#分隔的内容> <输出路径>'; continue }; cmdMixEnc $fp[0] $fp[1] }
        elseif ($cmd -in @('mix-dec','mdec')) { if (-not $arg) { Write-Output '用法：mix-dec <密文或密文文件路径>'; continue }; cmdMixDec (readCipherArg $arg) }
        else { Write-Output ("未知命令：{0}（输入 help 查看命令）" -f $cmd) }
    }
}
function readCipherArg([string]$arg) {
    $arg = ([string]$arg).Trim().Trim('"').Trim("'")
    if ($arg -and (Test-Path -LiteralPath $arg -PathType Leaf)) {
        try { return ([IO.File]::ReadAllText($arg, [Text.Encoding]::ASCII)).Trim() } catch {}
    }
    return $arg
}
function readKey() {
    try { $k = [Console]::ReadKey($true); return [string]$k.KeyChar } catch { return [Console]::ReadLine() }
}
function interactive() {
    $first = $true
    while ($true) {
        if (-not $first) { Write-Output ''; Write-Output '按任意键返回菜单…'; try { [void][Console]::ReadKey($true) } catch {} }
        $first = $false
        try { [Console]::Clear() } catch {}
        Write-Output '密码加解密工具  v2.2 / v2.4（纯 Windows，离线）'
        Write-Output ("`n当前版本：" + $script:VERSION)
        Write-Output '  1) 混合加密(#)  2) 混合解密(#)'
        Write-Output '  v) 切换版本     c) 命令式CLI   q) 退出'
        Write-Output "`n按数字键直接选择："
        $op = (readKey).Trim()
        if ($op -match '^(q|quit|exit)$') { break }
        elseif ($op -eq 'v') { $script:VERSION = if ($script:VERSION -eq 'v2.4') { 'v2.2' } else { 'v2.4' }; Write-Output ("已切换到 " + $script:VERSION) }
        elseif ($op -eq 'c') { $script:NONINTERACTIVE = $false; shell }
        elseif ($op -eq '1') {
            $ed = RunEditor '混合加密 · 文本编辑器' $true
            if (-not $ed.ok) { Write-Output '已取消' }
            else {
                $segs = @(ParseEditorSegments ([string]$ed.text))
                if ($segs.Count -eq 0) { Write-Output '编辑器为空' }
                else {
                    Write-Host '输出文件路径：'
                    $o = (ReadLineRaw).Trim().Trim('"').Trim("'")
                    MixEncFromSegs $segs $o
                }
            }
        }
        elseif ($op -eq '2') { Write-Host '混合密文或密文文件路径：'; $t = (ReadLineRaw).Trim(); if (-not $t) { Write-Output '请提供密文或密文文件路径' } else { cmdMixDec (readCipherArg $t) } }
        else { Write-Output '无效选择' }
    }
}

# ===== 入口：外部参数（环境变量 SCIPHER_ARGS 传入）=====
$argv = @()
if ($env:SCIPHER_ARGS) { $argv = @($env:SCIPHER_ARGS -split '\s+' | Where-Object { $_ -ne '' }) }
if ($argv.Count -eq 0) { interactive; return }
$cmd = $argv[0].ToLower()
$ver = 'v2.4'
for ($i = 0; $i -lt $argv.Count - 1; $i++) { if ($argv[$i] -eq '-v') { $vv = $argv[$i+1].Trim('v'); $ver = if ($vv -eq '2.2') { 'v2.2' } else { 'v2.4' } } }
$rest = @()
for ($i = 0; $i -lt $argv.Count; $i++) { if ($argv[$i] -eq '-v') { $i++; continue }; if ($i -eq 0) { continue }; $rest += $argv[$i] }
$joined = $rest -join ' '
switch ($cmd) {
    'enc' { Write-Output (encText $joined $ver) }
    'dec' { if ($joined -like '*@*' -and $ver -eq 'v2.4') { cmdFileDec $joined } else { try { Write-Output (decText $joined $ver) } catch { Write-Output '解码失败' } } }
    'file-enc' { cmdFileEnc $rest[0] ($rest[1..($rest.Count-1)] -join ' ') }
    'file-dec' { cmdFileDec (readCipherArg $joined) }
    'mix-enc' { cmdMixEnc $rest[0] ($rest[1..($rest.Count-1)] -join ' ') }
    'mix-dec' { cmdMixDec (readCipherArg $joined) }
    default { Write-Output '未知命令' }
}
