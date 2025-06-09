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
- 组成规则：只能包含**英文大小写字符、数字字符、$和_**
	1. 不能以数字开头；
	2. 不可以使用预定义的关键字；
	3. 区分大小写，不限长度
- 编程规范：
	1. 一行一条语句，以分号 “；” 结尾；
	2. 包名全部小写，使用 “.” 连接（比如：com.tencent.crossfire）
	3. 类名和接口名使用**大驼峰规则**（比如：public class EnemyFactory  或者 ）
	4. 变量名和方法名使用**小驼峰规则**