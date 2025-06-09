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
package Test;                                // package语句（0个或多个）
import java.util.*                           // import语句（0个或多个）
public class HelloWorld {                    // 类定义（public类名与文件名保持一致）
    public static void main(String[] args) {  
        System.out.println("Hello world!");  
    }  
}
```