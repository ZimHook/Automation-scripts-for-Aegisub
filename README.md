# Automation-scripts-for-Aegisub
## __目录__
  - [__0. 前言__](#0-前言)
  - [__1. C Font Resize__](#1-c-font-resize)
  - [__2. C Gradient__](#2-c-gradient)
  - [__3. C Translation__](#3-c-translation)
  - [__4. C Scaling Rotation Conflict Solution__](#4-c-scaling-rotation-conflict-solution)
  - [__INF. 更新日志__](#INF-更新日志)

## __0. 前言__
* __当前各脚本版本信息__
    | Name                            | Version |
    |---------------------------------|---------|
    | C Change SUB resolution to match video PATCH | v1.1 |
    | C Effect                        | v1.1    |
    | C Fast Tools                    | v1.1    |
    | C Font Resize (Mocha Deshaking) | v1.3    |
    | C Gradient                      | v2.1    |
    | C Merge Bilingual SUBS          | v1.1    |
    | C Jump                          | v1.0    |
    | C Picture Tracker               | v1.3    |
    | C Translation                   | v3.2    |
    | C Utilities                     | v1.7.2  |
    | C XML Analyzer                  | v1.2    |
    | * C Scaling Rotation Conflict Solution | v1.1 |
    > 在Automation Manager Description栏中查看脚本版本信息  
    > 若你的脚本在上述表格中且无版本信息 可能需要考虑更新脚本  
    > *表示“非主线”脚本，未列出的脚本为测试性或实验性的
* __使用方法__
    + 将LUA脚本复制到`C:\Program Files (x86)\Aegisub\automation\autoload`路径下，或你的Aegisub安装位置
    + 在 Aegisub Automation 项中可以发现添加的脚本
    + `C Effect & C Utilities`脚本部分功能依赖Yutils库，请先安装相关组件，传送门[https://github.com/Youka/Yutils](https://github.com/Youka/Yutils)，感谢原作者。
    + `C XML Analyzer`脚本依赖`xmlSimple`库，原作者[https://github.com/Cluain/Lua-Simple-XML-Parser](https://github.com/Cluain/Lua-Simple-XML-Parser)，本人作了一点修改，存放在lib文件夹下。
* __该仓库本人长期维护，欢迎star与fork。__  
* 2021.3.20 Mocha三件套`(Font Resize,Gradient,Translation)`已基本趋于稳定

-------------------------------------------
## __1. C Font Resize__
* __Feature__  
    Mocha 防抖  
* __Usage__  
    在Mocha Apply前使用  
    选中行(多行)运行即可
* __Example__  
    `1  {\fs80\fscx120\fsp1}exam{\fs95\t(\fscx150)}ple`  
    -> After running (assuming default scale_y=100) ->   
    `1  {\fscy1000\fs8\fscx1200\fsp0.100}exam{\fscx1266\fscy1055\fs9\t(\fscx1583)}ple`  
* __Warning__  
    不允许 `\t(fs)` 代码  

## __2. C Gradient__
* __Feature__  
    对逐行/逐帧字幕，自动填写中间行标签代码，以渐变模式填充  

    对Mocha无法正常追踪的片段，进行手动调整   
    便捷实现反复变色/闪烁效果的标签填充  
    便捷实现彩虹边框/阴影效果  
    More...
* __Usage__   
    选中多行字幕 运行LUA脚本    
    设置 setting,mode,rule,accel 选项     
    根据需求在下拉框中选中所需标签，并勾选相应勾选框   
    若标签被 `\t` 包裹，且需要程序生成 `\t` 起止时间等信息，请勾选 `\t` 勾选框(暂不可用)
* __GUI__
    + __setting:__   
    时间模式和行模式切换，勾选为时间模式，为渐变插值依据。如为相同时间轴字幕实现空间渐变效果，必须选择行模式；如为逐帧字幕实现空间渐变效果，建议选择时间模式。  
    + __accel (float number) arg: (0,+inf):__   
    加速度，参数范围 `(0,+∞)` ,当 `accel=1` 时为线性渐变，当 `accel>1` 时为先慢后快的渐变，当 `accel<1` 时为先快后慢的渐变，具体数学形式同 `y=x^a` 在定义域 `(0,1)` 中行为，accel为其中指数因子a。  
    + __mode (exact match/custom):__  
    exact match: 精确匹配模式，选中标签必须在选中字幕的每一行都出现，且位于相同位置(position)(后面会说明)  
    custom：定制模式，选中标签仅需出现在选中字幕的首位行，但仍需处于相同位置(position)  
    + __rule (string):__  
    mode 的规则，书写规则为 `%d%d[ht]?,%d%d[ht]?...` 两个数字和一个字母为一个规则块，以半角逗号分隔  
    每个规则块中首位数字为 tag block number, 第二位数字为 tag position number, 第三位字母为 head or tail, 可略去不写。  
    __tag block number:__   
    `{ tag block 1 } text block 1 { tag block 2 } text block 2 ...`  
    若干一个 text block 前有多个`{}`脚本将自动将其合并  
    行首若缺少 tag block 脚本将自动添加      
    __tag position number:__  
    你欲操作标签在一个 tag block 中所有该标签中的序数  
    `{\fs1(#1)\bord1\t(\shad1\fs2(#2))\fs9(#3)}` assuming the tag you want to manipulate is `\fs`  
    __head or tail:__  
    仅对 custom mode 有效，'h'=head，即添加标签至 tag block 首，'t'=tail，即添加标签至 tag block 尾，若略去不写，默认为 'h'。  
    + __\t__  
    待开发
* __Example__  
    `1 {\c&H0000FF&}example`  
    `2 example`   
    `3 {\c&H00FF00&}example`  
    -> After running (`custom, rule: 11t, accel=1`)  
    `1 {\c&H0000FF&}example`  
    `2 {\c&H008080&}example`   
    `3 {\c&H00FF00&}example`  
* __Warning__  
    一次只能运行对一种 tag 进行操作  
    
## __3. C Translation__
* __Feature__  
    Translation: 对逐行/逐帧字幕中的特定标签进行平移(即放大/缩小标签数值)  
    Smooth: 对逐行/逐帧字幕，保持首末行标签大小及大小变化导数不变，改变中间行特定标签大小，形成单峰( single peak )状偏移。

    对存在整体偏移的Mocha生成行，进行细微调整  
    对字幕进行整体平移，如向下平移一个黑边距离  
    > Tip: 勾选 `posy` 和 `clipy` 标签，将对应 `start` 和 `end` 都设为一个黑边距离，其他参数保持默认即可。

    制作3D特效，整体向右平移960pixel   
    More...
* __Usage__  
    选中多行字幕 运行LUA脚本    
    设置 setting 选项     
    根据需求勾选特效标签勾选框，而后设置对应 start, end, accel, index 等数值  
    > 一次可以勾选多个特效标签 这一点与 C Gradient 不同
* __GUI__  
    + __setting:__  
    同 `C Font Resize / GUI / setting`  
    + __start (float number): [Translation]__  
    选中行首行选中标签将增大数值
    + __end (float number): [Translation]__  
    选中行末行选中标签将增大数值  
    + __deviation (float number): [Smooth]__  
    选中行选中标签最大偏移数值   
    + __accel (float number) arg: (0,+inf): [Translation/Smooth]__  
    Translation: 同 `C Font Resize / GUI / accel`  
    Smooth: 该参数描述 peak 的宽度，accel 越大，peak 越尖 (sharp)  
    + __transverse (float number) arg: (0,+inf): [Smooth]__  
    该参数描述 peak 的横向偏移，即标签最大偏移行偏移选中行中心的距离，peak 随 transverse 的增大向右移动，当 `transverse=1` 时，横向偏移为零。  
    + __index (int number) arg: Z+: [Translation/Smooth]__  
    你欲操作标签在该行所有 tag block 中所有该标签中的序数  
    `{\fs1(#1)\bord1\t(\shad1\fs2(#2))} text block 1 {\fs9(#3)} text block 2` assuming the tag you want to manipulate is `\fs`   
    > 对 Smooth 运行的原理，编写了一个可视化可交互的程序：`./information/function smooth.cdf` 可使用 `Mathematica` 打开，以更好地了解各参数的功能。
* __Example__  
    `1 {\pos(500,500)}example`  
    `2 {\pos(500,500)}example`  
    `3 {\pos(500,500)}example`  
    -> After running (`posx: check, start: 100, end: 200, accel=1`)  
    `1 {\pos(600.000,500)}example`  
    `2 {\pos(650.000,500)}example`   
    `3 {\pos(700.000,500)}example`  
* __Warning__  
    不支持 `\t(\clip)` 标签  

<!-- ## __4. C Smooth__  
> 脚本的逻辑与 `C Translation/Smooth` 不同，   
> `C Translation/Smooth` 通过手动添置轨迹反向偏移，以实现平滑的目的  
> `C Smooth` 通过识别快速变化标签行，对其强制线性化，以实现滤去强烈抖动的标签，达到平滑效果，注意若反复使用该脚本，最终会导致选中行标签线性变化，而并不一定能与画面完美贴合。 -->
## __4. C Scaling Rotation Conflict Solution__
* __Feature__  
    解决拉伸代码 `\fscx \fscy` 与旋转代码 `\frx fry` 生成SUP时冲突的问题  
    将拉伸代码 `\fscx \fscy` 写入样式表中，并以后缀区分新增样式
* __Usage__  
    选中一行(多行)字幕，运行LUA脚本，设置 suffix 数值即可
* __GUI__  
    __suffix (int number):__  
    首行新样式名后缀
* __Example__  
    `1 Default {\fscx120\fscy130\frx1\fry2\frz5}example`  
    `2 Default {\fscx130\fscy140\frx2\fry3\frz5}example`  
    `3 Default {\fscx140\fscy150\frx3\fry4\frz5}example`  
    -> After running (`suffix=1`)  
    `1 Default_1 {\frx1\fry2\frz5}example`  
    `2 Default_2 {\frx2\fry3\frz5}example`   
    `3 Default_3 {\frx3\fry4\frz5}example`  
* __Warning__  
    选中每行字幕有且只能有一组拉伸代码
    > 程序会在样式表中产生大量样式，谨慎使用
--------------------------------------------
## __INF. 更新日志__
| Date | Script | Version | Detail |
|------|--------|---------|--------|
|2021.9.2|C Picture Tracker|1.3|支持clip追踪|
|2021.9.2|C XML Analyzer|1.2|优化过水，增加时间计算器工具|
|2021.8.24|C Picture Tracker|1.2|图片追踪神器|
|2021.8.24|C Utilities|1.7.2|增加批量裁剪AE图片功能|
|2021.8.24|C XML Analyzer|1.1|修复肉酱分割时存在的一些问题|
|2021.8.22|C XML Analyzer|1.0|原盘DIY辅助脚本上线，大幅优化过水、肉酱分割过程|
|2021.8.11|C Effect|1.1.1|bug修复|
|2021.8.8|C Utilities|1.7.1|优化中文匹配，AE导入支持非从1开始的序列|
|2021.8.7|Effect life game||一个小游戏|
|2021.8.7|C Effect|1.1|加快运行速度，简化无用参数|
|2021.8.4|C Change SUB resolution to match video PATCH|1.1|重大更新，完全重写了代码，无需经过自带的分辨率转换（精度低，有奇妙的bug），运行脚本后手动调整分辨率即可|
|2021.8.2|C Fast Tools|1.1|实现按enter加\N的正常逻辑|
|2021.8.2|C Jump|1.0|行间快速跳转工具|
|2021.7.28|C Utilities|1.7|Move!模块加了一个move2pos按钮，使用更方便，增加删除注释行和调色（实验性）功能，修正了少量bug，加快了运行速度|
|2021.7.27|C Smooth||放弃维护|
|2021.7.27|C Utilities|1.6|SDH,AE Importer更新，Multiline Importer增加从剪切板导入，删掉了Tag Copy功能|
|2021.7.13|C Utilities|1.5.1|摩卡可视化补上了对frz的支持|
|2021.7.10|C Utilities|1.5|加入一大堆新功能|
|2021.7.8|C Utilities|1.4|增添AE序列图导入功能|
|2021.7.8|C Utilities|1.3|增加进度条显示，进一步细分双语checker，改变部分逻辑，加快运行速度，修正了一些bug|
|2021.6.24|C Translation & Gradient| |将`math.power`替换为`^`，以兼容LUA 5.4|
|2021.6.24|C Translation|3.2|乘法for fscx fscy|
|2021.6.24|C Utilities|1.2|功能更新for buffer|
|2021.4.20|C Font Resize|1.3|增加对矢量图的支持|
|2021.4.20|C Effect|1.0|beta 内测版|
|2021.3.20|C Scaling Rotation Conflict Solution|1.1|Bug Fixed|
|2021.3.2|C Translation|3.1|解决字体中"W"导致错误|
|2021.3.1|C Gradient|2.1|解决字体中"W"导致错误，修复 `1vc` 中的 bug，新增对 `t1(\t第1个参数),t2(\t第2个参数),[i]clip` 的支持|
|2021.2.28|C Font Resize|1.2|解决字体中"W"导致错误，增添对样式表中设置fsp值的支持|