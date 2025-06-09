# 概述
## 简介：
- Java是Sun公司于1995年开发的一门面向对象编程语言
- JavaSE、JavaEE、JavaME
- **JDK（Java Development Kit)** 是Java开发工具包，包含编译器、运行环境、类库等组件，用于开发和运行Java程序。
- **Java运行环境（Java Runtime Environment，简称JRE）** 是一个软件。JRE可以让计算机系统运行Java应用程序（Java Application）。JRE的内部有一个Java虚拟机（Java Virtual Machine，JVM）以及一些标准的类别函数库（Class Library）。
- .java源文件->编译器->.class字节码->JVM->机器语言
- 通过字节码文件和JVM，Java实现了**一次编写，到处运行”** 的特性
## 程序结构：
``` java
package Test;                                 // package语句（0个或多个）
import java.util.*                            // import语句（0个或多个）
public class HelloWorld {                     // 类定义（public类名应与文件名保持一致）
    public static void main(String[] args) {  // main方法（程序入口点）
        System.out.println("Hello world!");   // 方法体（执行的东西）
    }  
}
```
- **编写并运行一个java程序**：编写源文件->生成字节码文件（java xxx.java）->使用解释器运行字节码文件（javac xxx）
## 注释书写：
``` java
// 单行注释

/* 
* 多行注释
* 多行注释
* 多行注释
/

/**
* 文档注释
* 文档注释
* 文档注释
* （会被JavaDoc文档识别并生成API文档，可添加类似@param等标签）
**/
```
## 关键字：
- 全部**小写！！！！！**
- **组成规则**：只能包含**英文大小写字符、数字字符、$和_**
	1. 不能以数字开头；
	2. 不可以使用预定义的关键字；
	3. 区分大小写，不限长度
- **编程规范**：
	1. 一行一条语句，以分号 “；” 结尾；
	2. 包名全部小写，使用 “.” 连接（比如：`com.tencent.crossfire`）
	3. 类名和接口名使用**大驼峰规则**（比如：`public class EnemyFactory` 或者 `interface EnemyEntities`）
	4. 变量名和方法名使用**小驼峰规则**（比如：`bubbleSort` 或 `setHeight`)
## 数据类型：
### 基本数据类型：
- 整型：`byte(1字节)、short(2字节)、int(4字节)、long(8字节)`
- 浮点型：`float(4字节)、double(8字节)`
- 字符型：`char(2字节)`
- 布尔型：`boolean(1字节)`
### 引用数据类型：
- 类、接口、数组、枚举、注解（描述代码的结构或行为）、包装类（将基本数据类型转换为对象的类）、`String`字符串、哈希表......
## 常量的定义：
- 整型常量默认为`int`，超过`int`取值范围要在数字后面加`L`
- 二进制：`0b(0B)`开头
- 八进制：`0`开头
- 十六进制：`0x(0X)`开头
- **小数默认为`double`型，定义`float`类型时，需要在数据后加`f(F)`，否则会报错，提示`不兼容的类型`**
- 布尔类型：`true、false`
- 字符类型：使用单引号括起来的**1个**字符，数字英文中文鸟语都行，Java18之后默认使用UTF-8编码，17以前看操作系统。
- 字符串类型：双引号括起来的0~N个字符
## 变量的定义及数据类型转换：
- 定义变量：懒得写了 `变量定义后可以不赋值，但若需使用必须先赋值`
- 变量有**作用域限制**
- **同一作用域**内，变量不可重复定义
- **自动类型转换**：小范围转大范围。比如：`double d = 1000;`
- **强制类型转换**：随便。比如：`int i = (int)6.718`  