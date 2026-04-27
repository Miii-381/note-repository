
# 1.简介

- 基于windows图形编程，将复杂程序过程进行封装，通过函数调用使用windows底层api。

---------------
# 2.调用

**图形库：** 
* `graphics.h` 包含已经被淘汰的函数
* `easyx.h` 只包含最新的函数
**注意事项：** Easyx是C++库，源文件应为.cpp文件。

-------------
# 3.概念

1. **对颜色的介绍**：计算机一般使用RGB合成颜色
2. **坐标**：计算机坐标默认原点在窗口左上角，坐标轴正方形向右下延伸。
3. **设备**：简单来说就是绘图表面（在哪儿绘图）。
	- 在Easyx中，设备分两种，一种为**默认的绘图窗口**，一种为**IMAGE对象**。通过`SetWorkingImage()`函数可以设置当前用于绘图的设备，设置当前绘图设备后，所有的绘图函数都会绘制在该设备上。

-----------------
# 4.函数

## 1. **窗口操作：**
```C
    initgraph（int width, int height, int flag = NULL);
     /* 用于初始化绘图窗口（创建窗口）
    width 窗口宽度 height 窗口高度 flag 窗口样式（默认为NULL）*/
    
    closegraph();
    /*关闭绘图窗口*/
    
    cleargraph();
    /*清空绘图设备（清屏）*/

    setbkcolor(参数);
    /* 设置背景颜色 */
    /* 参数：1.预设参数（插查看定义可知，不多） 2.RGB属性（255*255*255种）*/
    /* 与cleargraph绑定，setbkgraph设置的是需要改变的背景颜色参数，需要清除现有窗口的背景颜色，设置的才能显现 */
```    
## 2. **图形绘制函数：**
- 分类：<u>无填充</u>，<u>有边框填充</u>，<u>无边框</u> 三种
- 以画圆为例：
```C
    circle();        /* 空心圆 */
    fillcircle();    /* 边框填充都有的的圆 */
    solidcircle();   /* 有填充，没边框的圆 */
```
* 常用绘图函数：
```C
    circle(int x, int y, int r);                  /* 圆 参数：圆心坐标，半径 */
    ellipse(int x1, int y1, int x2, int y2);      /* 椭圆 参数：椭圆外切矩形左上角坐标，右下角坐标*/
    pie(int x1, int y1, int x2, int y2);          /* 扇形 参数：扇形所在椭圆的外切矩形的左上角坐标和右下角坐标*/
    polygon(int* arr, int num);                   /* 多边形 参数：每个顶点依次的坐标（用二维数组存放），顶点个数*/
    rectangle(int x1, int y1, int x2, int y2);    /* 矩形 参数：左上坐标，右下坐标*/
    roundrect(int x1, int y1, int x2, int y2, int width, int height);    /* 圆角矩形 参数：原直角矩形的左上坐标，右下坐标，构成圆角的椭圆的宽和高*/
    line(int x0, int y0, int x, int y);           /* 线 参数：起始点坐标，终点坐标*/
    putpixel(int x, int y, color)                 /* 点 参数：坐标，颜色*/
```
* 设置颜色：
```C
    setfillcolor();  /* 填充颜色 */
    setlinecolor();  /* 边框线条颜色 */
    setlinestyle();  /*  设置线条颜色 */
    /*setbkcolor(0x66CCFF);*/ 
    setbkcolor(0xFFCC66);	// 正常谈论的十六进制颜色与EasyX中十六进制颜色表示规则不同，导致颜色数值不同，从而引发颜色不同问题
    setlinecolor(BLUE);		// 正常情况下：16 进制的颜色表示规则为：0xrrggbb(rr = 红， gg = 绿，bb = 蓝)		
                    		// EasyX比较骚气，它16 进制的颜色表示规则为：0xbbggrr(bb = 蓝，gg = 绿，rr = 红)
```
* 设置样式：
```C
    setlinestyle();  /* 设置图形边框颜色 参数：样式，大小*/
    setfillstyle();  /* 设置图形填充样式 参数：填充方式，样式*/
```

## 3. **贴图**：
* **原样贴图：**
    1. 写结构体变量IMAGE
    2. `loadimage(IMAGE* img, URL, int width, int height); /* 加载贴图 */`
	3. `putimage(int x, int y, IMAGE* img); /* 显示图像 */ `
 - **透明贴图：**
    - 利用**掩码图**和**背景图**进行对图像的颜色二进制运算达到去除背景图的效果（Easyx自己没法显示透明PNG图片......）
    - 掩码图得自己做.....。
    - (说白了背景图就是把想显示的东西抠出来，不想显示的东西搞成黑色，然后掩码图相反，把想显示的东西用黑色覆盖，不想显示的地方用白色覆盖，黑色加白色就透明了)
    1. 制作掩码图和背景图；
    2. 建立数组存放结构体IMAGE；
    3. `loadimage()`加载两张图片；
    4. `putimage()`输出图片：
            * 对背景图和窗口现有的图像进行与运算（SRCAND）；
            * 对掩码图和窗口现有的图像进行或运算（SRCPAINT）；
            * 原理：1.白底黑图的背景图与原有背景进行与运算，白色与原有背景叠加得到原来的背景颜色，黑色与原有背景叠加得到黑底；2.，现在窗口位置出现了所需图像的黑色遮罩，再把黑底彩图的掩码图与现有图像进行或运算，黑色与任何颜色做运算得到颜色本身，所需的彩色图片就被覆盖上去了。
    5. 搞定~
* **PNG贴图：** 麻烦得一匹，还得学计算机图像相关的知识，建议去CSDN上面抄个库文件下来。
    * 这里提供一个利用`Windows GDI`进行透明图像显示的代码：
``` cpp
inline void putimage_ex(IMAGE* img, Rect* rect_dst, Rect* rect_src = nullptr) {
    static BLENDFUNCTION blend_func = { AC_SRC_OVER, 0, 255, AC_SRC_ALPHA };
    AlphaBlend(GetImageHDC(GetWorkingImage()),
        rect_dst->x,
        rect_dst->y,
        rect_dst->w,
        rect_dst->h,

        GetImageHDC(img),
        rect_src ? rect_src->x : 0,
        rect_src ? rect_src->y : 0,
        rect_src ? rect_src->w : img->getwidth(),
        rect_src ? rect_src->h : img->getheight(),

        blend_func);
}
```


# 4. **按键交互：**
1. **阻塞的按键交互**：按了键才变化，不按键不变（比如打砖块里的那个板）
    * （c语言里基本都是阻塞交互）

> 阻塞操作会影响非阻塞操作，简单来说就是屏幕里自己动的东西不动了，也需要你按键才能动...

2.  **非阻塞的案件交互**：不按键也动（比如打砖块里的那个球）
	- 挺简单的，就是生成图像，移动的话在另一个区域生成另一个图像，然后清除之前的图像就行了。
	- **代码如下：**
```C
#include <stdio.h>
#include <graphics.h>
#include <conio.h> /* 阻塞按键输入：getch(),不需要回车就可输入字符，但是是在命令行里输入，不是在图形窗口输入 */
#include <time.h>
struct Ball {          /* 定义球的状态 */
    int x;
    int y;
    int r;
    int dx;
    int dy;
};
struct Ball ball = { 400,400,15,5,-4 };
struct Ball myball = { 500,500,15,5,5 };

void DrawBall(struct Ball ball)      /* 画球 */
{
	setfillcolor(RED);
	solidcircle(ball.x, ball.y, ball.r);
}
void MoveBall()                     /* 球的移动 */
{
	if (ball.x - ball.r <= 0 || ball.x + ball.r >= 800){
		ball.dx = -ball.dx;
	}
	if (ball.y - ball.r <= 0 || ball.y + ball.r >= 800){
		ball.dy = -ball.dy;
	}
	ball.x += ball.dx;
	ball.y += ball.dy;
}
void KeyDown()           /* 阻塞按键操控，检测输入按键 */
{
	int UserKey = _getch();
	switch (UserKey)
	{
	case 'w':
	case 'W':
	case 72:
		myball.y -= myball.dy;
		break;
	case 's':
	case 'S':
	case 80:
		myball.y += myball.dy;
		break;
	case 'a':
	case 'A':
	case 75:
		myball.x -= myball.dx;
		break;
	case 'd':
	case 'D':
	case 77:
		myball.x += myball.dx;
		break;
	}
}
void KeyDown2()   /* 异步运行，比阻塞按键操控快得多，流畅干净，但使用的函数仅限于Windows，包含在Windows.h,graphics.h和easyx.h内*/
{
	if (GetAsyncKeyState(VK_UP))
	{
		myball.y -= 5;
	}
	if (GetAsyncKeyState(VK_DOWN))
	{
	    myball.y += 5;
	}
	if (GetAsyncKeyState(VK_LEFT))
	{
	    myball.x -= 5;
	}
	if (GetAsyncKeyState(VK_RIGHT))
	{
	    myball.x += 5;
	}
}
int Timer(int duration, int id) //定时器：用于控制自动移动的元素
{
	static int startTime[10];
	int endTime = clock();
	if (endTime - startTime[id] > duration) {
		startTime[id] = endTime;
		return 1;
	}
    return 0;    /* 把这个加上！！！要不然默认返回值为1，下面的判断会一直成立 */
}

int main()
{
	initgraph(800, 800);
	while (1)
	{
		cleardevice();
		DrawBall(ball);
		DrawBall(myball);
		if (Timer(20, 0)) {
			MoveBall();
		}
		if (_kbhit()){         /* 异步输入，快得多，还能八向移动 */
			if (Timer(3, 1)){
				KeyDown2();
			}
	}
		/*if (_kbhit()) {     //阻塞输入，慢，卡...
			KeyDown();
		}*/
		//Sleep(20);  /* 别让球跑得太快 */
		/* Sleep()也是阻塞函数，一般做物体自动移动是用定时器做，不然程序会卡 */
		FlushBatchDraw();        /* 双缓冲渲染 */
	}
	losegraph();
	return 0;
}
```
3. **鼠标交互**：
    1. 定义一个`ExMessage`类型的结构体变量存储鼠标消息
    2. 获取鼠标消息 `peekmessage(&结构体变量)`
    3. 讨论鼠标消息：
        * (统一使用`msg`代表结构体变量)
        * `msg.message`:区分鼠标消息类型（按下、抬起等）
        * `msg.x` `msg.y`：鼠标的当前坐标
        **代码如下：**
```C
#include <stdio.h>
#include <graphics.h>
int main()
{
	initgraph(800, 800);
	ExMessage msg;    /* 定义存储鼠标消息的结构体变量 */

	while (1) {
		while (peekmessage(&msg)) {      /* 获取鼠标消息 */
			switch (msg.message)         /* 判断鼠标消息是什么 */
			{
				case WM_LBUTTONDOWN:
					circle(msg.x, msg.y, 10);
					break;
				case WM_RBUTTONDOWN:
					rectangle(msg.x - 10, msg.y - 10, msg.x + 10, msg.y + 10);
					break;
			}
		}
	}
}