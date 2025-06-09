# 概述
## 简介：
- Java是Sun公司于1995年开发的一门面向对象编程语言
- JavaSE、JavaEE、JavaME
- **JDK（Java Development Kit)** 是Java开发工具包，包含编译器、运行环境、类库等组件，用于开发和运行Java程序。
- **Java运行环境（Java Runtime Environment，简称JRE）** 是一个软件。JRE可以让计算机系统运行Java应用程序（Java Application）。JRE的内部有一个Java虚拟机（Java Virtual Machine，JVM）以及一些标准的类别函数库（Class Library）。
- .java源文件->编译器->.class字节码->JVM->机器语言
- 通过字节码文件和JVM，Java实现了**一次编写，到处运行”** 的特性
___
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
___
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
___
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
___
## 数据类型：
### 基本数据类型：
- 整型：`byte(1字节)、short(2字节)、int(4字节)、long(8字节)`
- 浮点型：`float(4字节)、double(8字节)`
- 字符型：`char(2字节)`
- 布尔型：`boolean(1字节)`
### 引用数据类型：
- 类、接口、数组、枚举、注解（描述代码的结构或行为）、包装类（将基本数据类型转换为对象的类）、`String`字符串、哈希表......
___
## 常量的定义：
- 整型常量默认为`int`，超过`int`取值范围要在数字后面加`L`
- 二进制：`0b(0B)`开头
- 八进制：`0`开头
- 十六进制：`0x(0X)`开头
- **小数默认为`double`型，定义`float`类型时，需要在数据后加`f(F)`，否则会报错，提示`不兼容的类型`**
- 布尔类型：`true、false`
- 字符类型：使用单引号括起来的**1个**字符，数字英文中文鸟语都行，Java18之后默认使用UTF-8编码，17以前看操作系统。
- 字符串类型：双引号括起来的0~N个字符
___
## 变量的定义及数据类型转换：
- 定义变量：懒得写了 `变量定义后可以不赋值，但若需使用必须先赋值`
- 变量有**作用域限制**
- **同一作用域**内，变量不可重复定义
- **自动类型转换**：小范围转大范围。比如：`double d = 1000;`
- **强制类型转换**：随便。比如：`int i = (int)6.718` 
	- 注意：强制类型转换只能发生在可以被相互转换的数据类型之间，比如**存在继承关系的类、相互兼容的基本数据类型**等。（Tips：boolean是独立的数据类型，无法与任何数据类型直接相互转换！！！）
___
## 运算符：
### **1. 算术运算符**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`+`|加法|`int a = 5 + 3;`|8|加法运算|
|`-`|减法|`int b = 10 - 4;`|6|减法运算|
|`*`|乘法|`int c = 6 * 2;`|12|乘法运算|
|`/`|除法|`int d = 7 / 2;`|3|整数除法会截断小数|
|`%`|取模（余数）|`int e = 7 % 2;`|1|取余数|
|`++`|自增|`int f = 5; f++;`|6|后置自增（先用后加）|
|`--`|自减|`int g = 5; g--;`|4|后置自减（先用后减）|
### **2. 赋值运算符**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`=`|赋值|`int a = 10;`|a=10|基本赋值|
|`+=`|加后赋值|`int b = 5; b += 3;`|8|等价于 `b = b + 3`|
|`-=`|减后赋值|`int c = 5; c -= 2;`|3|等价于 `c = c - 2`|
|`*=`|乘后赋值|`int d = 5; d *= 2;`|10|等价于 `d = d * 2`|
|`/=`|除后赋值|`int e = 7; e /= 2;`|3|等价于 `e = e / 2`|
|`%=`|取模后赋值|`int f = 7; f %= 2;`|1|等价于 `f = f % 2`|
### **3. 比较运算符（关系运算符）**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`==`|等于|`boolean a = (5 == 5);`|true|判断值是否相等|
|`!=`|不等于|`boolean b = (5 != 3);`|true|判断值是否不相等|
|`>`|大于|`boolean c = (5 > 3);`|true|判断左边是否大于右边|
|`<`|小于|`boolean d = (5 < 3);`|false|判断左边是否小于右边|
|`>=`|大于等于|`boolean e = (5 >= 5);`|true|判断左边是否大于等于右边|
|`<=`|小于等于|`boolean f = (5 <= 3);`|false|判断左边是否小于等于右边|
### **4. 逻辑运算符**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`&&`|逻辑与（短路）|`boolean a = (5 > 3) && (2 < 4);`|true|左边为false时不再计算右边|
|`&`|逻辑与（非短路）|`boolean b = (5 > 3) & (2 < 4);`|true|无论左边结果如何，右边都会计算|
| \|\| |逻辑或（短路）|`boolean c = (5 > 3)` \|\| `(2 > 4);`|true|左边为true时不再计算右边|
| \| |逻辑或（非短路）|`boolean d = (5 > 3)`\|`(2 > 4);`|false|无论左边结果如何，右边都会计算|
|`!`|逻辑非|`boolean e = !(5 > 3);`|false|对布尔值取反|
|`^`|异或|`boolean f = true ^ false;`|true|两边结果不同时返回true|
### **5. 位运算符**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`&`|按位与|`int a = 5 & 3;`|1|二进制位全为1时结果为1|
|`^`|按位或|`int b = 5;`|3|二进制位有一个为1时结果都为1|
|`^`|按位异或|`int c = 5 ^ 3;`|6|二进制位不同时为1|
|`~`|按位取反|`int d = ~5;`|-6|对二进制位逐位取反（补码形式）|
|`<<`|左移|`int e = 5 << 1;`|10|左移1位相当于乘以2|
|`>>`|右移（带符号）|`int f = 5 >> 1;`|2|右移1位相当于除以2（舍弃小数）|
|`>>>`|右移（无符号）|`int g = -5 >>> 1;`|大正数|右移后高位补0（忽略符号位）|
### **6. 条件运算符（三元运算符）**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`? :`|条件判断|`int a = (5 > 3) ? 10 : 20;`|10|条件为true时返回第一个值，否则返回第二个值|
### **7. 其他运算符**
|运算符|运算规则|范例代码|结果|说明|
|---|---|---|---|---|
|`[]`|数组访问|`int[] arr = {1,2}; int b = arr[0];`|1|访问数组元素|
|`.`|成员访问|`String str = "Hello"; int len = str.length();`|5|访问对象属性或方法|
|`instanceof`|类型检查|`Object obj = "Hello"; boolean c = obj instanceof String;`|true|判断对象是否为指定类型|
### **补充说明**
1. **优先级**：`后缀自增\减 > 前缀自增\减 > 乘除模（*, /, %） > 加减（+, -）`
2. **字符串连接**：
    - `+` 运算符可用于字符串连接：
``` java 
		String str = "The result is: " + 42; // 结果为 "The result is: 42"
```
3. **类型转换**：
    - 如果操作数类型不同，Java 会自动提升为更高精度的类型（如 `int` 提升为 `double`）：
        ``` java
        double p = 5 + 3.14; // 5 是 int，3.14 是 double，结果为 double（8.14）
        ```
4. **复合赋值运算符**：
    - Java 提供 `+=`, `-=`, `*=`, `/=`, `%=` 等复合赋值运算符，简化代码：
        ``` java
        int q = 10;
        q += 5; // 等价于 q = q + 5; 结果 q = 15
        ```
### **Java 运算符优先级表**

|**优先级**|**运算符**|**类别**|**结合性**|**示例与说明**|
|---|---|---|---|---|
|**1**|`()`, `[]`, `.`|括号、数组访问、成员访问|从左到右|`obj.method()`<br>`arr[0]`<br>`new MyClass()`|
|**2**|`++`, `--`（后置）|后缀自增/自减|从左到右|`i++`<br>`j--`（先使用值，再自增/自减）|
|**3**|`++`, `--`（前置）<br>`+`（正）<br>`-`（负）<br>`~`<br>`!`<br>`(type)`<br>`new`|前缀自增/自减、一元运算符|从右到左|`++i`<br>`-5`<br>`~x`<br>`!flag`<br>`(int)3.14`<br>`new Object()`|
|**4**|`*`, `/`, `%`|乘除模|从左到右|`6 * 3 / 2` → `9`|
|**5**|`+`, `-`|加减|从左到右|`5 + 3 - 2` → `6`|
|**6**|`<<`, `>>`, `>>>`|位移运算|从左到右|`x << 2`（左移2位）<br>`y >> 1`（带符号右移1位）|
|**7**|`<`, `<=`, `>`, `>=`<br>`instanceof`|比较、类型检查|从左到右|`a > 5`<br>`str instanceof String`|
|**8**|`==`, `!=`|相等/不等|从左到右|`a == b`<br>`x != y`|
|**9**|`&`|按位与/逻辑与|从左到右|`a & b`（二进制逐位与）|
|**10**|`^`|按位异或/逻辑异或|从左到右|`a ^ b`（二进制逐位异或）|
|**11**|\||按位或/逻辑或|从左到右|`a `\|` b`（二进制逐位异或）|
|**12**|`&&`|短路与|从左到右|`flag && check()`（若 `flag` 为 `false`，不执行 `check()`）|
|**13**|\|\||短路或|从左到右|`flag `\|\|` check()`（若 `flag` 为 `true`，不执行 `check()`）|
|**14**|`? :`|条件（三元）运算符|从右到左|`a > b ? a : b`（返回较大值）|
|**15**|`=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `^=`, `|=`,` <<=`,` >>=`,` >>>=`|赋值运算符|从右到左|
|**16**|`,`|逗号运算符|从左到右|用于分隔语句或表达式（如方法参数列表）|

___
# 程序流程控制语句：
## 输入和输出：
### 输出：
``` java
// 不用导包
System.out.print(表达式);
System.out.println(表达式);
System.out.printf(占位符字串, 表达式1, 表达式2, ......); // (%c:字符型 %f：浮点型 %s：字符串型 %d：10进制整数)
```
### 输入：
``` java
// 1.导包
import java.util.Scanner;
// 2.创建Scanner对象
Scanner sc = new Scanner(System.in);
// 3.调用Scanner对象提供的方法读取数据
int i = sc.nextInt();
```
#### 常用Scanner方法：

| **构造方法**                      |                   |
| ----------------------------- | ----------------- |
| `Scanner(File source)`        | 从文件创建 Scanner     |
| `Scanner(InputStream source)` | 从输入流创建 Scanner    |
| `Scanner(String source)`      | 从字符串创建 Scanner    |
| **基本输入方法**                    |                   |
| `boolean hasNext()`           | 检查是否有下一个标记（以空格分隔） |
| `String next()`               | 读取下一个标记（字符串）      |
| `boolean hasNextLine()`       | 检查是否有下一行          |
| `String nextLine()`           | 读取下一行内容           |
| **类型检查方法**                    |                   |
| `boolean hasNextInt()`        | 检查下一个标记是否为整数      |
| `boolean hasNextDouble()`     | 检查下一个标记是否为双精度浮点数  |
| `boolean hasNextBoolean()`    | 检查下一个标记是否为布尔值     |
| **类型读取方法**                    |                   |
| `int nextInt()`               | 读取下一个整数           |
| `double nextDouble()`         | 读取下一个双精度浮点数       |
| `boolean nextBoolean()`       | 读取下一个布尔值          |
| `long nextLong()`             | 读取下一个长整数          |
| `float nextFloat()`           | 读取下一个单精度浮点数       |
| `short nextShort()`           | 读取下一个短整数          |
| `byte nextByte()`             | 读取下一个字节           |
| **其他方法**                      |                   |
| `void close()`                | 关闭扫描器             |
#### next()和nextLine()的区别：
**next():**
- 一定要读取到**有效字符**后才可以结束输入。
- 对输入有效字符之前遇到的空白，`next()` 方法会自动将其去掉。
- 只有输入有效字符后才将其后面输入的空白作为分隔符或者结束符。
- `next()` **不能得到带有空格的字符串**。
**nextLine()**：
- 以`Enter`为结束符,也就是说 `nextLine()`方法返回的是**输入回车之前的所有字符**。
- **可以获得带有空格的字符串**。
___
## if 语句：懒得写了，跟C/C++一样
___
## 循环语句：
### while循环：懒得写了，原因同上
### do...while循环：同上
### for循环：
#### 基础的懒得写了
#### 增强for循环（for-each循环）：
##### 特点：
- **语法简洁**：无需显式声明索引或迭代器对象，直接遍历集合或数组。
- **自动迭代**：自动处理元素的访问逻辑，无需手动调用`hasNext()`或`next()`方法。
- **限制性**：
    - **无法修改集合结构**：不能在遍历过程中添加或删除元素（否则会抛出`ConcurrentModificationException`）。
    - **无法获取索引**：不能直接访问当前元素的索引（需要配合传统`for`循环）。
    - **单向遍历**：只能从头到尾遍历，不能跳过部分元素或逆序遍历。
##### 语法：
``` java
// 遍历集合
List<String> list = new ArrayList<>();
list.add("A");
list.add("B");
for (String item : list) {
    System.out.println(item);
}

// 遍历数组
int[] numbers = {1, 2, 3};
for (int num : numbers) {
    System.out.println(num);
}
```
##### 适用场景：
- **简单遍历**：仅需读取集合中的元素，无需修改集合结构。
- **代码简洁性**：希望减少冗余代码，提高可读性。
- **固定顺序遍历**：集合的顺序不影响业务逻辑（如`ArrayList`）。
##### 注意事项：
- **不能修改集合**：如果尝试在循环中直接修改集合（如`list.add()`或`list.remove()`），会抛出`ConcurrentModificationException`异常。
	```java
    // 错误示例：增强for循环中修改集合
    for (String item : list) {
        if (item.equals("B")) {
            list.remove(item); // 抛出ConcurrentModificationException异常
        }
    }
    ```
#### 迭代器循环：
##### 特点：
- **灵活性**：支持在遍历过程中修改集合（如删除元素）。
- **手动控制**：需要显式调用`hasNext()`和`next()`方法控制迭代过程。
- **安全性**：通过迭代器的`remove()`方法修改集合，避免并发修改异常。
- **复杂性**：代码相对冗长，需要更多步骤。
##### 语法：
``` java
List<String> list = new ArrayList<>();
list.add("A");
list.add("B");
Iterator<String> iterator = list.iterator();

while (iterator.hasNext()) {
    String item = iterator.next();
    if (item.equals("B")) {
        iterator.remove(); // 安全删除元素
    }
    System.out.println(item);
}
```
##### 适用场景：
- **需要修改集合**：在遍历过程中需要删除或添加元素（需注意线程安全）。
- **复杂逻辑控制**：需要更精细的遍历控制（如条件跳过某些元素）。
- **兼容性要求**：需要兼容旧版Java代码（Java 1.5之前没有增强for循环）。
##### 注意事项：
- **只能单向遍历**：标准的`Iterator`只能向前遍历（`ListIterator`支持双向遍历）。
- **修改集合的正确方式**：必须使用迭代器的`remove()`方法，直接操作集合可能导致并发修改异常。
___
## 多路分支语句（switch-case）：原因同上。基础语法都差不多
___
## 跳转语句（break、continue）：
- 其他的懒得写了
- **注意：break只能跳转==循环和switch语句==**
___
# 数组
## 概念：
- 数组是固定数目的单一数据类型值的容器对象。数组中的每个数据被称为**元素**。
- **数组的创建格式**：`数据类型[] 数组名 = new 数据类型[元素个数或数组长度]`
``` java
// 举个栗子：
// 1.声明与构造分开：
int[] x;         // 声明
x = new int[100]; // 创建
// 2.声明与构造合并：
int[] x = new int[100];
```
- 数组的索引值从==0==开始，访问元素必须依赖索引
## 注意事项：
- 数组提供了`length`属性，可以通过`数组名.length`的方式获得数组长度，即**元素的个数**。
- 数组未被赋值时，系统会指派一个默认值。
	- ints数组：`0`
	- float数组：`0.0f`
	- String数组：`null`
	- boolean数组：`false`
- 数组可以创建时赋值（静态初始化或动态初始化），也可以在其他任何时候赋值。（静态初始化原理：创建一个新数组，让引用指向新数组）
``` java
	// 静态初始化(静态初始化时不能显式指定数组长度！！！长度根据所赋予的数据自动推算)
	int[] arr = new int[]{1,2,3,4};
	int[] arr = {1,2,3,4};      
	// 动态初始化
	int[] arr = new int[4]    
```
- **与数组有关的常见错误**：
	- **数组下标越界**：常见于遍历数组；
	- **数组也是引用数据类型**，数组名保存的是**地址**，不是变量值！！！
	- 静态初始化时不能定义数组长度！
## 多维数组就不在此介绍了
## Arrays类：
| 序号  | 方法和说明                                                                                                                                                                                                                                         |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **public static int binarySearch(Object[] a, Object key)**  <br>用**二分查找算法**在给定数组中搜索给定值的对象(Byte,Int,double等)。数组在调用前必须排序好。如果查找值包含在数组中，则返回搜索键的索引；否则返回 (-(_插入点_) - 1)。                                                                            |
| 2   | ==**public static boolean equals(long[] a, long[] a2)**== <br>如果两个指定的 long 型数组彼此**相等**，则返回 true。如果两个数组包含**相同数量的元素**，并且两个数组中的**所有相应元素对都是相等的**，则认为这两个数组是**相等的**。换句话说，如果两个数组**以相同顺序包含相同的元素**，则两个数组是**相等的**。同样的方法适用于所有的其他基本数据类型（Byte，short，Int等）。 |
| 3   | **public static void fill(int[] a, int val)**  <br>将指定的 int 值分配给指定 int 型数组指定范围中的每个元素。同样的方法适用于所有的其他基本数据类型（Byte，short，Int等）。                                                                                                                    |
| 4   | ==**public static void sort(Object[] a)**==<br>对指定对象数组根据其元素的自然顺序进行**升序排列**。同样的方法适用于所有的其他基本数据类型（Byte，short，Int等）。                                                                                                                              |
___
# 面向对象：
## 面向对象三大特性：封装、继承、多态
___
## 类：
- **类（class）** 是对具有相同**特征**和**行为**的对象的描述，它是创建对象（实例，instance）的一个**模板**
- 定义格式：
``` java
public class Car {  // [权限修饰符] class 类名
	// 类的属性（成员变量）
	String color; 
	int number;
	// 类的方法（成员方法）
	void run() { 
		System.out.println(color + ":" + number);
	}
}
```
### 一个类可以包含以下类型变量：
- **局部变量**：在**方法、构造方法或者语句块**中定义的变量被称为局部变量。变量声明和初始化都是在方法中，方法结束后，变量就会自动销毁。局部变量无初始值，需先赋值再使用，作用域仅在定义局部变量的语句块内。
- **成员变量**：成员变量是定义在**类中，方法体之外**的变量。这种变量在创建对象的时候被实例化。成员变量可以被类中方法、构造方法和特定类的语句块访问。成员变量有默认的初始化值，作用域在整个类的体内
- **类变量**：类变量也声明在**类中，方法体之外**，但必须声明为 `static` 类型。
### 静态变量、静态方法和静态常量：
- **静态变量**：用 `static` 修饰的**类变量**，属于类本身，所有对象**共享同一份副本**。
- 特点：
	- 类加载时初始化，存储在方法区，程序结束时销毁。
	- 所有对象共享，修改一个对象的静态变量会影响所有对象。
	- 可通过类名或对象访问（推荐用类名）（例：`Employer.salary`）。
- **静态方法**：用 `static` 修饰的**方法**，属于类本身，无需对象即可调用。
- 特点：
	- 在类加载时自动解析，存储在方法区，程序结束时销毁。
    - 直接通过类名调用（如 `ClassName.method()`）。
    - 只能访问静态变量和静态方法，不能直接访问实例成员。（==常见报错：在`main`方法中使用了非静态方法...==）
    - 不能使用 `this` 或 `super`。
    - 不可被重写（可被隐藏）。
- **静态常量**：用 `static final` 修饰的常量，属于类级别，值不可变。
- 特点：
    - 类加载时初始化，存储在**方法区**，程序结束时销毁。
    - 常见命名规范：全大写加下划线（如 `MAX_VALUE`）。
    - 通过类名直接访问。（例：`WeaponDamage.MAX_VALUE`）
___
## 对象：
- 对象是**类的实例化**，对象有状态和行为，创建对象使其具有类的相应属性和行为。
- 对象的创建和使用一般分三步：
	- 声明对象
	- 对象赋值
	- 调用属性
``` java
	public static void run(String[] args) { 
		Car c = new Car();   // 1. 对象
		c.color = "red";     // 2. 为成员方法赋值（直接赋值；使用get/set方法赋值）
		c.number = 114514;  
		c.run();             // 3. 执行成员方法
	}
```
___
## 包：
- 包（package）对应Java源文件的**目录结构**
### **包的作用**：
1. 把功能相似或相关的类或接口组织在同一个包中，形成模块或单元，**方便类的查找和使用**。	
2. 如同文件夹一样，包也采用了树形目录的存储方式。同一个包中的类名字是不同的，不同的包中的类的名字是可以相同的，当同时调用两个不同包中相同类名的类时，应该加上包名加以区别。因此，包可以**避免类的名字冲突**。
3. 包也限定了**访问权限**，拥有包访问权限的类才能访问某个包中的类。
### **包的格式**：
``` java
package net.javagroup.research.powerproject 
// 由小写字母组成，以圆点分隔，包名之前通常使用组织倒置的网络域名作为前缀
```
### **常见的包**：
``` java
java.lang // 虚拟机自动引入，提供Java语言的核心类，是JDK的基本包
java.util // 提供一些实用类，包括Scanner，集合框架、日期时间处理、随机数生成等
java.io   // 提供一些有关IO的类
```
### **如何导入包**：
- `import 包名.类名`  
- 如果要引用包内的所有类，类名可填写为`*`
___
## 封装：
### 概念：
- 在面向对象程式设计方法中，封装（英语：Encapsulation）是指一种将抽象性函式接口的实现细节部分包装、隐藏起来的方法。
- 封装可以被认为是一个保护屏障，防止该类的代码和数据被外部类定义的代码随机访问。
- 要访问该类的代码和数据，必须通过严格的接口控制。
- 封装最主要的功能在于我们能修改自己的实现代码，而不用修改那些调用我们代码的程序片段。
- 适当的封装可以让程式码更容易理解与维护，也加强了程式码的安全性。
### 封装的优点：
1. 良好的封装能够减少耦合。
2. 类内部的结构可以自由修改。
3. 可以对成员变量进行更精确的控制。
4. 隐藏信息，实现细节。
### 封装的步骤：
1. 修改属性的可见性来限制对属性的访问（一般限制为`private`）；
2. 对每个值属性提供对外的公共方法访问，也就是创建一对赋/取值方法（`getter/setter`方法），用于对私有属性的访问。
### 举个栗子：
``` java
public class Person{
    private String name;  // 1.修改属性的可见性来限制对属性的访问
    private int age;
​
    public int getAge(){  // 2. 创建私有属性的getter/setter方法
      return age;         
    }
​
    public String getName(){
      return name;
    }
​
    public void setAge(int age){
      this.age = age;     // 此处使用this是为了与形参区别开。
    }
​
    public void setName(String name){
      this.name = name;
    }
}
```
### 补充：访问控制修饰符
Java中，可以使用访问控制符来保护对类、变量、方法和构造方法的访问。Java 支持 4 种不同的访问权限。
- **default** (即默认，什么也不写）: 在**同一包内**可见，不使用任何修饰符。使用对象：类、接口、变量、方法。
- **private** : 在**同一类内**可见。使用对象：变量、方法。 **注意：不能修饰类（外部类）**
- **public** : 对**所有类**可见。使用对象：类、接口、变量、方法
- **protected** : 对**同一包内的类和所有子类**可见。使用对象：变量、方法。 **注意：不能修饰类（外部类）**

| 修饰符         | 当前类 | 同一包内 | 子孙类(同一包) | 子孙类(不同包) | 其他包 |
| ----------- | --- | ---- | -------- | -------- | --- |
| `public`    | Y   | Y    | Y        | Y        | Y   |
| `protected` | Y   | Y    | Y        | Y/N      | N   |
| `default`   | Y   | Y    | Y        | N        | N   |
| `private`   | Y   | N    | N        | N        | N   |
___
## 继承：
### 概念：
- 继承就是子类继承父类的特征和行为，使得子类对象（实例）具有父类的实例域和方法，或子类从父类继承方法，使得子类具有父类相同的行为。
- 也就是，在一个现有类的基础上去构建一个新的类
- 构建出来的新类被称为子类，现有类被称为父类。
- **一个子类只能有一个直接父类！！！**（单继承）
- 使用`super`关键字代表父类对象。
- 子类的特点：自动拥有父类所有 **非private** 修饰的属性和方法。
- **所有的类均继承自`java.lang.Object`祖先类！！！**
- **super 关键字**： 我们可以通过 super 关键字来实现对**父类成员**的访问，用来引用当前对象的父类。
- **this 关键字** ：指向**自己的引用**，引用当前对象，即它所在的方法或构造函数所属的对象**实例**。
### 语法：
``` java
class 父类 { 

} 
class 子类 extends 父类 { 

}
```
![[Pasted image 20250609174040.png]]
### 继承的特性：
- 子类拥有父类非 private 的属性、方法。
- 子类可以拥有自己的属性和方法，即子类可以对父类进行扩展。
- 子类可以用自己的方式实现父类的方法。
- Java 的继承是**单继承**（一对一），但是可以**多重继承**（一个接一个的继承），单继承就是一个子类只能继承一个父类，多重继承就是，例如 B 类继承 A 类，C 类继承 B 类，所以按照关系就是 B 类是 C 类的父类，A 类是 B 类的父类，这是 Java 继承区别于 C++ 继承的一个特性。
- 提高了类之间的耦合性（继承的*缺点*也在于此，耦合度高就会造成代码之间的联系越紧密，代码独立性越差）。
### 构造方法：
#### 概念：
- 对象创建时要执行的给对象属性进行初始化的方法。系统默认会给一个**无参**的构造方法（**注意：当自定义了有参构造方法后，无参构造方法不会被自动赋予，需要手动定义！！！**）
#### 语法：
``` java
class MyClass { 
	private int n; 
	// 无参数构造器 
	public SuperClass() { 
		System.out.println("SuperClass()");
	} 
	// 带参数构造器 
	public SuperClass(int n) { 
		System.out.println("SuperClass(int n)"); 
		this.n = n; 
	}
}
```
#### 继承中的构造方法（构造器）：
- 子类是**不继承父类的构造器（构造方法或者构造函数）的**，它只是**调用**（隐式或显式）。如果父类的构造器**带有参数**，则必须在子类的构造器中**显式**地通过`super`关键字调用父类的构造器并配以适当的参数列表。
- 如果父类构造器**没有参数**，则在子类的构造器中不需要使用`super`关键字调用父类构造器，系统会**自动调用**父类的无参构造器。
- ==`super` 构造方法**必须放在子类构造方法的第一行语句！！！！！！！！！**==
___
## 多态：
### 概念：
- 多态是同一个行为具有多个不同表现形式或形态的能力。也就是同一对象的特定行为在不同环境下展现的不同效果（即同一名字在不同环境中有不同含义）。
- **“同一名字”** 是多态的基础；
- **“不同环境”** 是多态的前提；
- 与“同名不同参”相关的多态，称为 **“重载（Override）”**，重载可实现一名多用，即同一方法名称具有不同的方法体。重载要求**方法名相同，方法形参不同**
- 与动态绑定相关的多态，称为 **“重写（Overload）”** ，重写的效果只应用于当前子对象，且**静态方法不可重写**。重写要求方法声明形式与父类完全相同 **（同名同参 ，同返回值）**，且方法存取权限大于等于（ $\ge$ ）父类
- 当使用多态方式调用方法时，首先检查父类中是否有该方法，如果没有，则编译错误；如果有，再去调用子类的同名方法。
### 多态的优点：
1. 消除类型之间的耦合关系
2. 可替换性
3. 可扩充性
4. 接口性
5. 灵活性
6. 简化性
### 多态存在的三个必要条件：
- 继承
- 重写
- 父类引用指向子类对象：`Parent p = new Child()`;
### 举个栗子：
``` java
class Shape {
    void draw() {}
}
  
class Circle extends Shape {         // Circle类继承自Shape类，重写了draw()方法
    void draw() {
        System.out.println("Circle.draw()");
    }
}
  
class Square extends Shape {         // Square类继承自Shape类，重写了draw()方法
    void draw() {
        System.out.println("Square.draw()");
    }
}
  
class Triangle extends Shape {       // Triangle类继承自Shape类，重写了draw()方法
    void draw() {
        System.out.println("Triangle.draw()");
    }
}
```
### 多态的类型转换：
- **从子到父**：**自动类型转换**，子类对象赋值给父类类型的变量指向。
- **从父到子**： 
	- 此时**必须进行强制类型转换**：`子类 对象变量 = (子类)父类类型的变量`。
	- **作用**：可以解决多态下的劣势，实现调用子类独有的功能。 
	- **注意**： 如果转型后的类型和对象真实类型**不是同一种类型**，那么在转换的时候就会出现ClassCastException异常
- 强烈建议强转前使用`instanceof`关键字判断当前对象的真实类型！！！
- `instanceof` 是 Java 的保留关键字。它的作用是测试它**左边**的对象是否是它**右边**的类的实例，返回 `boolean` 的数据类型。
``` java
import java.util.ArrayList; 
import java.util.Vector; 

public class Main { 
	public static void main(String[] args) { 
		Object testObject = new ArrayList(); 
		displayObjectClass(testObject); 
	} 
	public static void displayObjectClass(Object o) { 
		if (o instanceof Vector) 
			System.out.println("对象是 java.util.Vector 类的实例"); 
		else if (o instanceof ArrayList) 
			System.out.println("对象是 java.util.ArrayList 类的实例"); 
		else 
			System.out.println("对象是 " + o.getClass() + " 类的实例"); 
	}
}
// 执行结果：对象是 java.util.ArrayList 类的实例
```
___
## 重写（Override）与重载（Overload）:
### 重写(Override)：

- 重写（Override）是指子类定义了一个与其父类中具有相同名称、参数列表和返回类型的方法，并且子类方法的实现覆盖了父类方法的实现。 **即外壳不变，核心重写！**
- 重写的好处在于子类可以根据需要，定义特定于自己的行为。也就是说子类能够根据需要实现父类的方法。这样，在使用子类对象调用该方法时，将执行子类中的方法而不是父类中的方法。
- 重写方法 **不能抛出新的检查异常** 或者 **比被重写方法申明更加宽泛的异常** 。例如： 父类的一个方法申明了一个检查异常 IOException，但是在重写这个方法的时候不能抛出 Exception 异常，因为 Exception 是 IOException 的父类，抛出 IOException 异常或者 IOException 的子类异常。
- 在面向对象原则里，重写意味着可以**重写任何现有方法**。
- 实例如下：
``` java
class Animal{
   public void move(){
      System.out.println("动物可以移动");
   }
}
 
class Dog extends Animal{
   public void move(){
      System.out.println("狗可以跑和走");
   }
   public void bark() {
	   System.out.println("狗可以叫");
   }
}
 
public class TestDog{
   public static void main(String args[]){
      Animal a = new Animal(); // Animal 对象
      Animal b = new Dog(); // Dog 对象
 
      a.move();// 执行 Animal 类的方法
 
      b.move();//执行 Dog 类的方法
   }
}
// 执行结果如下：

// 动物可以移动
// 狗可以跑和走
```
- 在上面的例子中可以看到，尽管 b 属于 `Animal` 类型，但是它运行的是 Dog 类的 `move()` 方法。这是由于在编译阶段，只是检查参数的引用类型。然而在运行时，Java 虚拟机(JVM)指定对象的类型并且运行该对象的方法。因此在上面的例子中，之所以能编译成功，是因为**Animal 类中存在 move 方法，然而运行时，运行的是特定对象的方法**。
- 假如在main方法中添加 `b.bark();` 这一行代码，则会出现编译错误，因为**b的引用类型Animal中没有包含 `bark()` 方法**。
#### 方法的重写规则：
- 参数列表与被重写方法的参数列表必须完全相同。
- 返回类型与被重写方法的返回类型可以不相同，但是必须是父类返回值的派生类（java5 及更早版本返回类型要一样，java7 及更高版本可以不同）。
- 访问权限不能比父类中被重写的方法的访问权限更低。例如：如果父类的一个方法被声明为 public，那么在子类中重写该方法就不能声明为 protected。
- 父类的成员方法只能被它的子类重写。
- 声明为 final 的方法不能被重写。
- 声明为 static 的方法不能被重写，但是能够被再次声明。
- 子类和父类在同一个包中，那么子类可以重写父类所有方法，除了声明为 private 和 final 的方法。
- 子类和父类不在同一个包中，那么子类只能够重写父类的声明为 public 和 protected 的非 final 方法。
- 重写的方法能够抛出任何非强制异常，无论被重写的方法是否抛出异常。但是，重写的方法不能抛出新的强制性异常，或者比被重写方法声明的更广泛的强制性异常，反之则可以。
- 构造方法不能被重写。
- 如果不能继承一个类，则不能重写该类的方法。
### 重载(Overload)：
- 重载(overloading) 是在**一个类**里面，**方法名字相同，而参数不同。返回类型可以相同也可以不同**。
- 每个重载的方法（或者构造函数）都必须有一个独一无二的参数类型列表。
- 最常用的地方就是**构造器的重载**。
#### 重载规则：
- 被重载的方法必须改变参数列表(参数个数或类型不一样)；
- 被重载的方法可以改变返回类型；
- 被重载的方法可以改变访问修饰符；
- 被重载的方法可以声明新的或更广的检查异常；
- 方法能够在同一个类中或者在一个子类中被重载。
- 无法以返回值类型作为重载函数的区分标准。
#### 实例如下：
``` java
public class Overloading {
    public int test(){
        System.out.println("test1");
        return 1;
    }
 
    public void test(int a){
        System.out.println("test2");
    }   
 
    //以下两个参数类型顺序不同
    public String test(int a,String s){
        System.out.println("test3");
        return "returntest3";
    }   
 
    public String test(String s,int a){
        System.out.println("test4");
        return "returntest4";
    }   
 
    public static void main(String[] args){
        Overloading o = new Overloading();
        System.out.println(o.test());
        o.test(1);
        System.out.println(o.test(1,"test3"));
        System.out.println(o.test("test4",1));
    }
}
```
### 重写与重载之间的区别总结：

| 区别点  | 重载方法 | 重写方法                    |
| ---- | ---- | ----------------------- |
| 参数列表 | 必须修改 | 一定不能修改                  |
| 返回类型 | 可以修改 | 一定不能修改                  |
| 异常   | 可以修改 | 可以减少或删除，一定不能抛出新的或者更广的异常 |
| 访问   | 可以修改 | 一定不能做更严格的限制（可以降低限制）     |

方法的重写(Overriding)和重载(Overloading)是Java多态性的不同表现，重写是父类与子类之间多态性的一种表现，重载可以理解成多态的具体表现形式。
1. 方法重载是一个类中定义了多个**方法名相同**,而他们的**参数的数量不同**或**数量相同而类型和次序不同**,则称为方法的**重载(Overloading)**。
2. 方法重写是在子类存在方法与父类的方法的**名字相同**,而且**参数的个数与类型一样**,**返回值也一样**的方法,就称为**重写(Overriding)**。
3. 方法重载是**一个类**的多态性表现,而方法重写是**子类与父类**的一种多态性表现。
![[Pasted image 20250609195322.png]]
![[Pasted image 20250609195329.png]]
___
## 抽象类与接口：
### 概念：
- 在面向对象的概念中，所有的对象都是通过类来描绘的，但是反过来，并不是所有的类都是用来描绘对象的，如果**一个类中没有包含足够的信息来描绘一个具体的对象**，这样的类就是**抽象类**。
- 抽象类除了**不能被实例化**之外，类的其它功能依然存在，成员变量、成员方法和构造方法的访问方式和普通类一样。
- 由于抽象类不能实例化对象，所以抽象类**必须被继承**，才能被使用。也是因为这个原因，通常在设计阶段决定要不要设计抽象类。
### 语法：
- 使用`abstract`关键字声明该类为抽象类
- **抽象方法**：在抽象方法中使用`abstract`关键字修饰的方法，没有方法体，方法的具体实现由继承自该抽象类的实现类确定。
	- 如果一个类包含抽象方法，那么该类**必须是抽象类**。
	- 任何子类**必须重写**父类的抽象方法，或者**声明自身为抽象类**。
- 建议抽象类中的**模板方法**（通过**定义算法的骨架**（即流程的整体步骤），将某些步骤的实现**延迟到子类中**，从而实现代码复用和灵活扩展）使用`final`进行修饰，以免被子类重写。
``` java
public abstract class Shape {   // 抽象类
	private String name;        // 抽象类中仍然可以定义成员变量、成员方法和构造方法
	public abstract double area(); // 抽象方法
}

public class Rectangle extends Shape {
	private double W;
	private double H;
	public double area() {     // 子类必须重写父类的抽象方法
		return W * H;
	}
	// gettle/settle方法略
}
```
### 抽象类总结规定：
1. 抽象类**不能被实例化**（初学者很容易犯的错），如果被实例化，就会报错，编译无法通过。只有**抽象类的非抽象子类**（实现类）可以创建对象。
2. 抽象类中不一定包含抽象方法，但是**有抽象方法的类必定是抽象类**。
3. 抽象类中的抽象方法只是**声明**，不包含方法体，也就是不给出方法的具体实现也就是方法的具体功能。
4. **构造方法**，**类方法**（用 static 修饰的方法）不能声明为抽象方法。
5. 抽象类的**子类**必须给出抽象类中的抽象方法的**具体实现**，除非该子类也是抽象类。
___
## 接口：
### 概念：
- **接口（英文：Interface）**，在JAVA编程语言中是一个**抽象类型**，是**一组（已赋值）常量和抽象方法的集合**，接口通常以`interface`来声明。一个类通过**继承接口**的方式，从而来继承接口的抽象方法。
- **接口并不是类**，编写接口的方式和类很相似，但是它们属于不同的概念。类描述对象的属性和方法。接口则包含类要实现的方法。
- 除非实现接口的类是抽象类，否则该类要定义接口中的所有方法。
- 接口**无法被实例化**，但是**可以被实现**。一个实现接口的类，必须实现接口内所描述的**所有方法**，否则就必须声明为抽象类。另外，在 Java 中，接口类型可用来声明一个变量，他们可以成为一个空指针，或是被绑定在一个以此接口实现的对象。
### 语法：
``` java
// 接口声明：
[可见度] interface 接口名称 [extends 其他的接口名] {
	// 声明变量 
	// 抽象方法 
	// 默认方法（JDK 1.8添加）：
	default void print(){
		System.out.println("我是一辆车!"); 
	}
}

// 接口实现：
[可见度] class 实现类名 implements 接口名称[, 其他接口名称, 其他接口名称..., ...] {
	// 必须实现所声明接口内的所有抽象方法
	// 可添加实现类内自有的方法
}
```
### 举个栗子：
``` java
/* 文件名 : Animal.java */
interface Animal {
   public void eat();
   public void travel();
}

/* 文件名 : MammalInt.java */
public class MammalInt implements Animal{
 
   public void eat(){
      System.out.println("Mammal eats");
   }
 
   public void travel(){
      System.out.println("Mammal travels");
   } 
 
   public int noOfLegs(){
      return 0;
   }
 
   public static void main(String args[]){
      MammalInt m = new MammalInt();
      m.eat();
      m.travel();
   }
}

/* 执行结果： 
* Mammal eats
* Mammal travels
*/
```
### 特性：
- 接口**本身**是隐式抽象的，声明接口的时候不用使用`abstract`关键字
- 接口中**每一个方法**也是隐式抽象的,接口中的方法会被隐式的指定为 `public abstract`（只能是 `public abstract`，其他修饰符都会报错）。
- 接口中可以含有变量，但是接口中的变量会被隐式的指定为 `public static final` 变量（并且只能是 `public`，用 `private` 修饰会报编译错误）。
- 接口中的方法是不能在接口中实现的，只能由**实现接口的类**来实现接口中的方法。
### 接口与类相似点：
- 一个接口可以有多个方法。
- 接口文件保存在 **.java** 结尾的文件中，文件名使用接口名。
- 接口的字节码文件保存在 **.class** 结尾的文件中。
- 接口相应的字节码文件必须在与包名称相匹配的目录结构中。
### 接口与类的区别：
- 接口不能用于实例化对象。
- 接口没有构造方法。
- 接口中所有的方法必须是抽象方法，但在 Java 8 之后，接口中可以使用 `default` 关键字修饰的非抽象方法（**默认方法**）。接口的默认方法**必须使用接口实现类的对象来调用**
- 在 Java 8 之后，接口中还可以使用`static`修饰的非抽象方法（**静态方法**），其能被**直接使用接口名进行调用**
- 在 Java 9 之后，接口中还可以使用`private`修饰的非抽象方法（**私有方法**），其只能在本类中被其他的默认方法或者私有方法访问。
- 接口不能包含成员变量，除了 static 和 final 变量。
- 接口不是被类继承了，而是要被类**实现**。
- 接口支持**多继承**（一个实现类可继承多个接口，实现这些接口全部的抽象方法）。
### 默认方法、静态方法和私有方法的例子：
``` java
public class Java8Tester {
    public static void main(String args[]){
       Vehicle vehicle = new Car();
       vehicle.print();
    } 
}
 
interface Vehicle {
    default void print(){                // 默认方法
       System.out.println("我是一辆车!");
    }
    
    static void blowHorn(){              // 静态方法
       System.out.println("按喇叭!!!");
    }
}
 
interface FourWheeler {
	default void print(){                // 默认方法
	    System.out.println("我是一辆四轮车!");
	    printCar();
    }
	private void printCar(){             // 私有方法
		System.out.println("我是一辆四轮车hahahahaha!");
	}
}
 
class Car implements Vehicle, FourWheeler {
   public void print(){                 // 重写Vehicle和FourWheeler的print()方法
      Vehicle.super.print();            // 可通过super进行默认方法的指定调用
      FourWheeler.super.print();
      Vehicle.blowHorn();               // 静态方法需使用接口名进行调用
      System.out.println("我是一辆汽车!");
   }
}
// 输出结果为：
// 我是一辆车!
// 我是一辆四轮车!
// 我是一辆四轮车hahahahaha!
// 按喇叭!!!
// 我是一辆汽车!
```
___
## 枚举：
### 概念：
- Java 枚举是一个**特殊的类**，一般表示一组常量，比如一年的 4 个季节，一年的 12 个月份，一个星期的 7 天，方向有东南西北等。
- Java 枚举类使用 `enum` 关键字来定义，各个常量使用**逗号**`,`来分割。
- 枚举常被用于 **for循环** 和 **switch语句** 中。
### 语法：
- 例如：定义一个颜色的枚举类：
``` java
enum Color { 
    RED, GREEN, BLUE; 
}
```
### 特性：
- 每个枚举都是通过 Class 在内部实现的，且所有的枚举值都是 `public static final` 的。
- 比如，上面的枚举类可被同等转化为：
``` java
class Color {
     public static final Color RED = new Color();
     public static final Color BLUE = new Color();
     public static final Color GREEN = new Color();
}
```
- enum 定义的枚举类默认继承了 `java.lang.Enum` 类，并实现了 `java.lang.Serializable` 和 `java.lang.Comparable` 两个接口。也就意味着，enum类能被**序列化**和**比较**`（序列化在此不做讨论，简单来说就是将数据转化成一条连续的二进制串，便于传输，反序列化同理）`。
- enum类存在如下方法：
	- `values()` 返回枚举类中**所有的值**。
	- `ordinal()`方法可以找到每个枚举常量的**索引**，就像数组索引一样。
	- `valueOf()`方法返回**指定字符串值的枚举常量**。
- 枚举跟普通类一样可以用自己的变量、方法和构造函数，构造函数只能使用 `private` 访问修饰符，所以外部无法调用。枚举既可以包含**具体方法**，也可以包含**抽象方法**。 如果枚举类具有抽象方法，则枚举类的每个实例都必须实现它。
___
## 内部类：
### 概念：
- 在 Java 中，可以**将一个类定义在另一个类里面或者一个方法里面**，这样的类称为**内部类**。
- 广泛意义上的内部类一般来说包括这四种：**成员内部类、局部内部类、匿名内部类**和**静态内部类**。
### 成员内部类：
- 成员内部类是最普通的内部类，它的定义**位于另一个类的内部**，形如下面的形式：
``` java
class Circle {
    double radius = 0;
     
    public Circle(double radius) {
        this.radius = radius;
    }
     
    class Draw {     // 内部类
        public void drawSahpe() {
            System.out.println("drawshape");
        }
    }
}
```
- 此处`Draw`为内部类，`Circle`为外部类。成员内部类可以**无条件访问**外部类的所有成员属性和成员方法（包括private成员和静态成员）。
- 当成员内部类拥有和外部类同名的成员变量或者方法时，会发生**隐藏现象**，即默认情况下访问的是成员内部类的成员（**作用域的覆盖**）。如果要访问外部类的同名成员，需要以下面的形式进行访问：
``` java
外部类.this.成员变量
外部类.this.成员方法
```
- 在外部类中如果要访问成员内部类的成员，必须先创建一个成员内部类的对象，再通过指向这个对象的引用来访问：
``` java
class Circle {
    private double radius = 0;
 
    public Circle(double radius) {
        this.radius = radius;
        getDrawInstance().drawSahpe();   //必须先创建成员内部类的对象，再进行访问
    }
     
    private Draw getDrawInstance() {
        return new Draw();
    }
     
    class Draw {     //内部类
        public void drawSahpe() {
            System.out.println(radius);  //外部类的private成员
        }
    }
}
```
- 成员内部类是依附外部类而存在的，也就是说，如果要创建成员内部类的对象，前提是**必须存在一个外部类的对象**。创建成员内部类对象的一般方式如下：
``` java
public class Test {
    public static void main(String[] args)  {
        //第一种方式：
        Outter outter = new Outter();
        Outter.Inner inner = outter.new Inner();  //必须通过Outter对象来创建
        // 或:Outter.Inner inner = new Outter().new Inner();
         
        //第二种方式：
        Outter.Inner inner1 = outter.getInnerInstance(); 
        // 通过getInnerInstance()方法获取成员内部类对象,这种方法需要自定义创建逻辑
        // 此处使用了懒汉式单例模式的创建逻辑
    }
}
 
class Outter {
    private Inner inner = null;
    public Outter() { }
     
    public Inner getInnerInstance() {
        if(inner == null)
            inner = new Inner();
        return inner;
    }
      
    class Inner {          // 成员内部类
        public Inner() { }
    }
}
```
### 局部内部类：
- 局部内部类是定义在**一个方法**或者**一个作用域**里面的类，它和成员内部类的区别在于局部内部类的访问**仅限于方法内或者该作用域内**。
``` java
class People{
    public People() { }
}
 
class Man{
    public Man() { }
     
    public People getWoman(){
        class Woman extends People{   //局部内部类
            int age =0;
        }
        return new Woman();
    }
}
```
- **注意**: 局部内部类就像是方法里面的一个局部变量一样，是不能有 `public、protected、private`以及 `static` 修饰符的。
### 匿名内部类：
- Java中的**匿名内部类**是一种没有显式名称的内部类，通常用于简化代码，尤其是在需要实现接口或继承抽象类时。它允许在代码中直接定义并实例化一个类，适用于一次性使用的场景。
- 匿名内部类常见于**设置事件监听器**、**实现接口**等**一次性使用类**的情况。
``` java
// 下面是一个
import javax.swing.*;
import java.awt.event.*; 
public class GUIExample { 
	public static void main(String[] args) { 
		JFrame frame = new JFrame("Button Example"); 
		JButton button = new JButton("Click Me"); 
		
		// 匿名内部类实现事件监听器 
		button.addActionListener(new ActionListener() { 
			@Override 
			public void actionPerformed(ActionEvent e) { 
				System.out.println("Button clicked!"); 
			} 
		}); 
		
		frame.add(button); 
		frame.setSize(300, 200); 
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true); 
	}
}
```