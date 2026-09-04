# C++ 模板元编程、多态与 STL 系统整理

> 适合读者：已经学完 C++ 基本语法，了解函数、类、继承、指针、引用和常用容器，但尚未系统学习模板的初学者。
>
> 建议标准：正文以 C++17 为基础，并单独标明 C++20 的 `concept` 等特性。

## 目录

- [1. 为什么要把模板、多态和 STL 放在一起学习](#1-为什么要把模板多态和-stl-放在一起学习)
- [2. 从普通函数走向函数模板](#2-从普通函数走向函数模板)
- [3. 类模板、非类型模板参数与模板实例化](#3-类模板非类型模板参数与模板实例化)
- [4. 模板特化：为特殊类型改变规则](#4-模板特化为特殊类型改变规则)
- [5. 什么是模板元编程](#5-什么是模板元编程)
- [6. 类型萃取：在编译期查询和变换类型](#6-类型萃取在编译期查询和变换类型)
- [7. 编译期选择：SFINAE、if constexpr 与 concept](#7-编译期选择sfinaeif-constexpr-与-concept)
- [8. C++ 中的多态](#8-c-中的多态)
- [9. 模板怎样实现静态多态](#9-模板怎样实现静态多态)
- [10. 动态多态、静态多态与类型擦除](#10-动态多态静态多态与类型擦除)
- [11. STL 为什么离不开模板元编程](#11-stl-为什么离不开模板元编程)
- [12. 从一次 STL 调用看完整协作过程](#12-从一次-stl-调用看完整协作过程)
- [13. 容易混淆的概念与常见错误](#13-容易混淆的概念与常见错误)
- [14. 学习路线与总结](#14-学习路线与总结)

---

## 1. 为什么要把模板、多态和 STL 放在一起学习

初学 C++ 时，这三个主题经常被分开讲：

- 模板被介绍成“少写几个重复函数”的语法；
- 多态被介绍成“基类指针调用派生类虚函数”；
- STL 被介绍成 `vector`、`map`、`sort` 等容器和算法的集合。

这些说法没有错，但不完整。三者实际围绕同一个问题展开：**如何写出能够适应多种类型、同时又保持类型安全和可复用性的代码。**

可以先建立下面这条主线：

```text
重复代码
   ↓
函数模板、类模板：让一份代码适用于多种类型
   ↓
静态多态：编译器针对具体类型生成不同实现
   ↓
模板元编程：在编译期计算、判断和选择实现
   ↓
STL：用模板把容器、迭代器、算法、函数对象组织成通用库
```

与此同时，传统面向对象中的虚函数提供了另一种多态：**动态多态**。它直到运行时才根据对象的实际类型决定调用哪个函数。

因此，理解本专题时应始终区分两个时间点：

| 问题 | 编译期 | 运行期 |
| --- | --- | --- |
| 主要机制 | 模板、重载、`constexpr`、类型萃取、`concept` | 虚函数、虚函数表、RTTI、类型擦除 |
| 常见名称 | 静态多态、编译期多态 | 动态多态、运行时多态 |
| 决定调用目标的时机 | 编译程序时 | 程序运行时 |
| 典型例子 | `std::sort` 接收不同迭代器和比较器 | `Shape&` 调用不同派生类的 `draw()` |

### 1.1 泛型编程与模板元编程不是同一个概念

这两个概念关系紧密，但不能画等号：

- **泛型编程（generic programming）**关注的是：用抽象的类型和操作编写通用代码。例如 `std::vector<T>` 可以保存不同类型，`std::sort` 可以排序多种序列。
- **模板元编程（template metaprogramming，TMP）**关注的是：利用模板实例化机制，在编译期间完成计算、类型判断、类型变换和代码选择。

函数模板 `max_value` 是泛型编程；使用 `std::is_integral_v<T>` 在编译期判断 `T` 是否为整数，则属于典型的模板元编程。一个程序往往同时使用二者。

---

## 2. 从普通函数走向函数模板

### 2.1 模板要解决什么问题

假设需要编写求较大值的函数：

```cpp
int max_value(int a, int b) {
    return a < b ? b : a;
}

double max_value(double a, double b) {
    return a < b ? b : a;
}
```

两个函数只有类型不同，算法完全相同。继续为 `long`、`float` 等类型复制函数，会产生大量重复代码。函数模板允许把类型写成参数：

```cpp
#include <iostream>

template <typename T>
T max_value(const T& a, const T& b) {
    std::cout << "[max_value] comparing two values\n";
    return a < b ? b : a;
}

int main() {
    std::cout << max_value(3, 7) << '\n';          // 推导 T 为 int
    std::cout << max_value(2.5, 1.8) << '\n';      // 推导 T 为 double
}
```

`template <typename T>` 的意思是：接下来的声明是一个模板，其中 `T` 是一个**类型模板参数**。`typename` 在这里也可以写成 `class`，二者含义相同：

```cpp
template <class T>
T max_value(const T& a, const T& b);
```

### 2.2 模板不是一个已经编译好的普通函数

模板更像是生成代码的规则。编译器看到下面的调用时：

```cpp
max_value(3, 7);
```

会进行大致如下的工作：

1. 根据实参推导出 `T` 是 `int`；
2. 用 `int` 替换模板中的 `T`；
3. 检查替换后的代码是否合法，例如 `int` 是否支持 `<`；
4. 生成并编译 `max_value<int>` 这个具体函数。

由模板和具体模板实参生成实际函数或类的过程，称为**模板实例化（template instantiation）**。生成的具体结果称为模板的一个**实例（specialization）**。这里的 specialization 是广义术语，不等同于程序员手写的“显式特化”。

### 2.3 模板实参推导

调用函数模板时，可以让编译器推导类型：

```cpp
max_value(3, 7);       // T = int
```

也可以显式指定模板实参：

```cpp
max_value<double>(3, 7.5); // T = double，3 会转换为 double
```

如果两个形参都使用同一个 `T`，但实参类型不同，推导可能失败：

```cpp
max_value(3, 7.5); // 错误：第一个实参要求 T=int，第二个要求 T=double
```

一种解决方法是显式指定类型；另一种方法是把模板设计成接收两个类型：

```cpp
#include <type_traits>

template <typename T, typename U>
std::common_type_t<T, U> max_value(T a, U b) {
    using Result = std::common_type_t<T, U>;
    return a < b ? static_cast<Result>(b) : static_cast<Result>(a);
}
```

`std::common_type_t<T, U>` 会在编译期寻找两个类型适合共同转换到的类型。这已经用到了类型萃取，也说明泛型代码经常依赖模板元编程。

### 2.4 模板对类型有隐含要求

`max_value` 没有要求 `T` 必须继承某个基类，但函数体使用了：

- `operator<` 比较两个 `T`；
- 从 `a` 或 `b` 复制构造返回值。

因此，能否使用这个模板，取决于具体类型是否支持这些操作。这种“只关心类型能做什么，不关心类型继承自谁”的风格，是泛型编程的重要特点，也常被称为**鸭子类型**：如果一个类型能够提供模板所需的操作，它就可以参与该模板。

在 C++20 之前，这些要求往往隐藏在模板函数体和复杂的编译错误中；C++20 可以使用 `concept` 显式表达要求，后文会详细说明。

### 2.5 为什么模板通常写在头文件中

编译器在实例化模板时，通常必须看到模板的完整定义。若只在头文件中声明模板，把定义放进普通 `.cpp` 文件，其他翻译单元调用模板时可能看不到定义，从而产生链接错误。

因此常见做法是：

- 将模板声明和定义都放在 `.h`、`.hpp` 等头文件中；
- 或把实现放入 `.tpp` 文件，再由头文件 `#include`；
- 若只支持有限的已知类型，可在 `.cpp` 中进行**显式实例化**。

```cpp
// 显式要求编译器生成 max_value<int>
template int max_value<int>(const int&, const int&);
```

---

## 3. 类模板、非类型模板参数与模板实例化

### 3.1 类模板

类模板把类型作为类定义的一部分：

```cpp
#include <cstddef>
#include <iostream>
#include <stdexcept>

template <typename T>
class FixedBuffer {
public:
    explicit FixedBuffer(std::size_t capacity)
        : data_(new T[capacity]), capacity_(capacity) {
        std::cout << "[FixedBuffer] allocated " << capacity_ << " elements\n";
    }

    ~FixedBuffer() {
        std::cout << "[FixedBuffer] releasing storage\n";
        delete[] data_;
    }

    FixedBuffer(const FixedBuffer&) = delete;
    FixedBuffer& operator=(const FixedBuffer&) = delete;

    T& at(std::size_t index) {
        if (index >= capacity_) {
            throw std::out_of_range("FixedBuffer index out of range");
        }
        return data_[index];
    }

private:
    T* data_;
    std::size_t capacity_;
};

int main() {
    FixedBuffer<int> numbers(10);
    FixedBuffer<double> measurements(5);
    numbers.at(0) = 42;
}
```

`FixedBuffer<int>` 与 `FixedBuffer<double>` 是两个不同的类型。它们可以有不同的成员函数代码和不同的静态数据成员。

实际项目中不应重新发明这个容器；这里仅用于观察类模板。动态数组应优先使用 `std::vector<T>`，固定长度数组应优先使用 `std::array<T, N>`。

### 3.2 非类型模板参数

模板参数不一定是类型，也可以是编译期值：

```cpp
#include <array>
#include <cstddef>

template <typename T, std::size_t N>
T sum(const std::array<T, N>& values) {
    T result{};
    for (const T& value : values) {
        result += value;
    }
    return result;
}
```

这里：

- `T` 是类型模板参数；
- `N` 是非类型模板参数，表示编译期已知的数组长度；
- `std::array<int, 3>` 和 `std::array<int, 4>` 是不同的类型。

非类型模板参数让编译器能把一个值当作类型的一部分。`std::array<T, N>` 正是 STL 使用模板表达“元素类型 + 固定长度”的典型例子。

### 3.3 模板模板参数

模板还可以接收另一个模板作为参数，称为**模板模板参数**：

```cpp
#include <deque>
#include <iostream>
#include <vector>

template <typename T, template <typename, typename> class Container>
class SimpleStack {
public:
    void push(const T& value) {
        data_.push_back(value);
        std::cout << "[SimpleStack] pushed one element\n";
    }

    void pop() {
        data_.pop_back();
        std::cout << "[SimpleStack] popped one element\n";
    }

    const T& top() const { return data_.back(); }

private:
    Container<T, std::allocator<T>> data_;
};

SimpleStack<int, std::vector> vector_stack;
SimpleStack<int, std::deque> deque_stack;
```

这是一个用于理解概念的简化示例。现实中的容器模板参数列表可能更加复杂，使用模板模板参数时还要考虑默认参数和参数匹配。

### 3.4 别名模板

`using` 可以为一族类型定义别名：

```cpp
#include <string>
#include <unordered_map>

template <typename Value>
using StringMap = std::unordered_map<std::string, Value>;

StringMap<int> word_count;
StringMap<double> scores;
```

别名模板本身不会创建新类型，只是给已有类型表达式提供更易读的名字。标准库中的 `_t` 名称，例如 `std::remove_reference_t<T>`，通常就是别名模板。

### 3.5 模板实例化的代价

模板把很多工作放到编译期，代价包括：

- 每种模板实参组合都可能生成一份代码，增加编译时间；
- 多个实例可能导致目标文件体积增大，称为**代码膨胀**；
- 错误可能发生在很深的实例化链中，诊断信息较长；
- 修改模板头文件会使包含它的许多源文件重新编译。

编译器和链接器能够合并一部分重复实例，但“模板完全没有成本”并不准确。模板的优势是运行时常能获得高度优化的专用代码，其主要代价则转移到了编译时间、二进制体积和代码复杂度上。

### 3.6 可变参数模板与参数包

有时模板需要接收数量不固定的类型或值。例如 `std::tuple<int, double, std::string>` 同时保存三个不同类型，`std::make_unique<T>(args...)` 需要把任意数量的构造参数传给 `T`。

可变参数模板使用省略号表示**参数包（parameter pack）**：

```cpp
#include <iostream>

template <typename... Types>
void print_type_count() {
    std::cout << "[type_count] " << sizeof...(Types) << " types\n";
}

int main() {
    print_type_count<>();
    print_type_count<int>();
    print_type_count<int, double, char>();
}
```

这里：

- `Types` 是类型参数包，可以包含零个或多个类型；
- `Types...` 表示声明或引用整个包；
- `sizeof...(Types)` 在编译期得到包中元素数量。

函数参数也可以形成包：

```cpp
template <typename... Args>
void log_values(const Args&... args) {
    std::cout << "[values] ";
    ((std::cout << args << ' '), ...);
    std::cout << '\n';
}
```

`args` 是函数参数包。把包展开为一组表达式的过程称为**参数包展开（pack expansion）**。`args...` 不是一个能够单独保存的运行时容器，而是由编译器展开为多个独立参数或类型。

### 3.7 折叠表达式

C++17 引入折叠表达式，用一个二元运算符归约整个参数包。求和可以写成：

```cpp
template <typename... Values>
constexpr auto sum(Values... values) {
    return (values + ...);
}

static_assert(sum(1, 2, 3, 4) == 10);
```

常见形式有四种：

```text
(pack op ...)          一元右折叠
(... op pack)          一元左折叠
(pack op ... op init)  带初值的二元右折叠
(init op ... op pack)  带初值的二元左折叠
```

是否使用左折叠会影响结合顺序。对于减法等不满足结合律的运算，这个区别非常重要。空参数包也需要特别考虑：部分一元折叠对空包没有有效结果，而带初值的折叠通常更容易定义空包语义：

```cpp
template <typename... Values>
constexpr auto safe_sum(Values... values) {
    return (0 + ... + values); // 空包时结果为 0
}
```

C++11/14 还没有折叠表达式，旧代码常用模板递归逐个处理参数。折叠表达式更短，也通常能产生更清晰的诊断。

### 3.8 完美转发为什么常与参数包一起出现

通用工厂或包装器常需要把收到的参数原样传给另一个构造函数：左值仍按左值传递，右值仍按右值传递，`const` 等性质也不应被意外破坏。这称为**完美转发（perfect forwarding）**。

```cpp
#include <iostream>
#include <memory>
#include <utility>

template <typename T, typename... Args>
std::unique_ptr<T> make_logged_unique(Args&&... args) {
    std::cout << "[factory] constructing object with "
              << sizeof...(Args) << " arguments\n";
    return std::make_unique<T>(std::forward<Args>(args)...);
}
```

在此处，`Args&&...` 中的每个 `Args&&` 都可能是**转发引用（forwarding reference）**。模板实参推导与引用折叠规则共同保留实参的左值 / 右值信息，`std::forward<Args>(args)` 再按照推导结果恢复原来的值类别。

不要无条件用 `std::move(args)...` 代替 `std::forward`：这样会把原本的左值也强制当作右值，可能意外移动调用者仍要使用的对象。

STL 中的 `emplace`、`make_shared`、`make_unique` 以及许多容器插入接口，都广泛使用可变参数模板和完美转发。

### 3.9 变量模板

变量也可以参数化：

```cpp
template <typename T>
constexpr bool is_pointer_v = false;

template <typename T>
constexpr bool is_pointer_v<T*> = true;

static_assert(is_pointer_v<int*>);
```

这叫变量模板。标准库中 `std::is_same_v<T, U>`、`std::is_integral_v<T>` 等 `_v` 名称就是变量模板，它们通常是相应 trait 的 `::value` 简写。

---

## 4. 模板特化：为特殊类型改变规则

### 4.1 主模板与显式全特化

主模板描述一般规则；显式全特化描述某个具体模板实参的特殊规则：

```cpp
#include <iostream>
#include <string>

template <typename T>
struct TypeName {
    static std::string get() {
        return "unknown";
    }
};

template <>
struct TypeName<int> {
    static std::string get() {
        return "int";
    }
};

int main() {
    std::cout << "[type] " << TypeName<double>::get() << '\n'; // unknown
    std::cout << "[type] " << TypeName<int>::get() << '\n';    // int
}
```

`template <>` 表示模板参数已经全部被指定。`TypeName<int>` 不再使用主模板的实现。

### 4.2 偏特化

偏特化为“一类模板实参”定义特殊规则：

```cpp
template <typename T>
struct IsPointer {
    static constexpr bool value = false;
};

template <typename T>
struct IsPointer<T*> {
    static constexpr bool value = true;
};

static_assert(!IsPointer<int>::value);
static_assert(IsPointer<int*>::value);
static_assert(IsPointer<double*>::value);
```

`IsPointer<T*>` 没有指定 `T` 到底是什么，但规定了整体必须是指针类型，因此是偏特化。

需要注意：

- 类模板可以偏特化；
- 变量模板可以偏特化；
- 函数模板不能偏特化，通常使用函数重载代替；
- 显式特化必须遵守声明位置等规则，给标准库模板添加特化也受到严格限制。

### 4.3 特化如何变成编译期模式匹配

在 `IsPointer<int*>` 中，编译器尝试把 `int*` 与偏特化模式 `T*` 匹配，于是得到 `T = int`。这很像对类型结构做模式匹配。

模板元编程中的许多类型变换都建立在这种机制之上。例如去掉指针，可以写成：

```cpp
template <typename T>
struct RemovePointer {
    using type = T;
};

template <typename T>
struct RemovePointer<T*> {
    using type = T;
};

using A = RemovePointer<int>::type;   // int
using B = RemovePointer<int*>::type;  // int
```

标准库已经提供 `std::remove_pointer_t<T>`，实际项目应优先使用标准实现。手写版本的意义在于理解类型萃取的原理。

---

## 5. 什么是模板元编程

### 5.1 基本定义

**模板元编程是利用模板实例化和编译期语言规则，让编译器在编译期间执行计算、生成类型或选择代码的技术。**

这里的“元”表示程序处理的对象不只是普通运行时数据，还可能是：

- 类型；
- 编译期常量；
- 一组模板参数；
- 某段代码是否应该参与重载；
- 针对不同类型应选择的实现。

元程序的输入通常是类型或编译期值，输出可以是：

- 一个 `value` 常量；
- 一个名为 `type` 的类型；
- 被选中的模板特化；
- 一段最终可执行的普通 C++ 代码。

### 5.2 经典示例：编译期阶乘

```cpp
template <unsigned N>
struct Factorial {
    static constexpr unsigned value = N * Factorial<N - 1>::value;
};

template <>
struct Factorial<0> {
    static constexpr unsigned value = 1;
};

static_assert(Factorial<5>::value == 120);
```

它包含三个关键部分：

1. `Factorial<N>` 表示递归规则：`N! = N × (N - 1)!`；
2. `Factorial<0>` 是全特化，表示递归终止条件：`0! = 1`；
3. `Factorial<5>::value` 是编译期结果，`static_assert` 可以在编译期验证它。

编译器会沿着 `Factorial<5>`、`Factorial<4>` 一直实例化到 `Factorial<0>`。这类似函数递归，但发生在模板实例化阶段。

经典 TMP 常具有以下特征：

- 用模板递归代替运行时循环；
- 用特化代替条件分支；
- 用嵌套的 `type` 表示类型计算结果；
- 用静态常量 `value` 表示数值计算结果。

### 5.3 `std::integral_constant`：把值包装进类型

标准库用 `std::integral_constant` 统一表示“携带编译期常量的类型”：

```cpp
#include <type_traits>

using Answer = std::integral_constant<int, 42>;

static_assert(Answer::value == 42);
static_assert(Answer{} == 42);
```

它的概念性简化实现如下：

```cpp
template <typename T, T V>
struct IntegralConstant {
    static constexpr T value = V;
    using value_type = T;
    using type = IntegralConstant;

    constexpr operator value_type() const noexcept {
        return value;
    }
};
```

标准库进一步定义了：

```cpp
using true_type = integral_constant<bool, true>;
using false_type = integral_constant<bool, false>;
```

因此许多类型萃取会继承 `std::true_type` 或 `std::false_type`。这样，编译期布尔值不仅是一个值，还对应一种类型，可以参与重载和模板匹配。

### 5.4 `constexpr` 与模板元编程的关系

现代 C++ 可以用 `constexpr` 更自然地完成数值计算：

```cpp
constexpr unsigned factorial(unsigned n) {
    unsigned result = 1;
    for (unsigned i = 2; i <= n; ++i) {
        result *= i;
    }
    return result;
}

static_assert(factorial(5) == 120);
```

与模板递归相比，`constexpr` 版本更接近普通代码，更容易阅读和调试。现代 C++ 的建议是：

- 编译期**数值计算**优先考虑 `constexpr` / `consteval`；
- 编译期**类型计算和类型选择**通常仍使用模板及类型萃取；
- 需要根据条件丢弃代码分支时，考虑 `if constexpr`；
- 需要约束模板接口时，C++20 优先考虑 `concept`。

`constexpr` 函数不保证每次都在编译期执行。如果传入运行时值，它也可以在运行时执行：

```cpp
unsigned n = 0;
std::cin >> n;
std::cout << factorial(n); // 此处通常在运行时计算
```

`consteval` 函数则称为**立即函数**，每次调用都必须产生编译期常量：

```cpp
consteval int square(int value) {
    return value * value;
}

constexpr int result = square(6); // 正确
```

`consteval` 是 C++20 特性。

### 5.5 TMP 的收益与风险

收益：

- 在编译期发现不合法用法，增强类型安全；
- 对每个具体类型生成专用代码，便于内联和优化；
- 把部分计算从运行期移到编译期；
- 可以构建通用而零额外运行时开销的库接口；
- 能够描述容器、算法和用户类型之间的能力关系。

风险：

- 增加编译时间和二进制体积；
- 复杂模板会显著降低可读性；
- 过深的实例化可能超过编译器深度限制；
- 旧式 SFINAE 错误信息晦涩；
- 把本可在运行时简单解决的问题强行放到编译期，可能得不偿失。

模板元编程是一种工具，而不是所有代码都应追求的风格。

---

## 6. 类型萃取：在编译期查询和变换类型

### 6.1 什么是类型萃取

类型萃取（type traits）是模板元编程最常用的形式。它把“关于类型的信息”包装成统一接口，用于回答两类问题：

1. **类型判断**：`T` 是整数吗？是指针吗？能复制构造吗？
2. **类型变换**：去掉引用后是什么类型？添加 `const` 后是什么类型？两个类型的公共类型是什么？

标准库的类型萃取位于 `<type_traits>`。

### 6.2 判断型萃取

```cpp
#include <iostream>
#include <type_traits>

template <typename T>
void print_type_facts() {
    std::cout << std::boolalpha;
    std::cout << "[trait] integral: " << std::is_integral<T>::value << '\n';
    std::cout << "[trait] pointer: " << std::is_pointer<T>::value << '\n';
    std::cout << "[trait] copy constructible: "
              << std::is_copy_constructible<T>::value << '\n';
}
```

C++17 为许多判断型萃取提供 `_v` 变量模板简写：

```cpp
static_assert(std::is_integral_v<int>);
static_assert(!std::is_integral_v<double>);
static_assert(std::is_pointer_v<const char*>);
```

`std::is_integral<T>` 是一种类型；`std::is_integral<T>::value` 是其中的布尔常量；`std::is_integral_v<T>` 是更简洁的写法。

### 6.3 变换型萃取

```cpp
#include <type_traits>

using A = std::remove_reference_t<int&>;       // int
using B = std::remove_const_t<const int>;      // int
using C = std::remove_pointer_t<double*>;      // double
using D = std::add_const_t<int>;               // const int
using E = std::decay_t<const int&>;            // int

static_assert(std::is_same_v<A, int>);
static_assert(std::is_same_v<B, int>);
```

旧式写法常带有 `::type`：

```cpp
typename std::remove_reference<T>::type
```

C++14 以后通常写成：

```cpp
std::remove_reference_t<T>
```

这里的 `typename` 用于告诉编译器：依赖于模板参数的名字 `std::remove_reference<T>::type` 是一个类型。对于初学者，先记住一条实用规则：在模板中写 `某个依赖于 T 的类型::内部类型` 时，通常需要在前面加 `typename`；使用 `_t` 别名可以减少这类语法负担。

### 6.4 `std::decay_t` 做了什么

按值传参时，C++ 会进行一组常见的类型调整，例如：

- 去掉引用；
- 去掉顶层 `const` / `volatile`；
- 数组退化为指针；
- 函数退化为函数指针。

`std::decay_t<T>` 大致模拟这种调整。它常用于需要“保存一份值”的泛型包装器。例如一个接收 `const int&` 的模板若要在对象中拥有自己的 `int`，通常不应该把成员类型保存为引用，而可以考虑使用 `std::decay_t<T>`。

不过，现代代码处理转发和返回类型时还常使用 `std::remove_cvref_t<T>`。它只去掉引用及顶层 `const` / `volatile`，不会让数组和函数退化；该工具从 C++20 开始提供。

### 6.5 类型萃取驱动代码选择

```cpp
#include <iostream>
#include <type_traits>

template <typename T>
void describe(const T&) {
    if constexpr (std::is_integral_v<T>) {
        std::cout << "[describe] integral value\n";
    } else if constexpr (std::is_floating_point_v<T>) {
        std::cout << "[describe] floating-point value\n";
    } else {
        std::cout << "[describe] other value\n";
    }
}
```

`if constexpr` 的条件在编译期确定。未选中的分支会被丢弃，因此只要其中的代码不违反某些必须立即检查的语法规则，它不需要对当前模板实参有效。这与普通 `if` 有本质区别：普通 `if` 的两个分支都必须能够被编译。

### 6.6 不要随意谎报用户类型的性质

标准允许用户为少数标准模板进行特化，但不能随意给 `std::is_integral` 等标准类型性质添加特化来“伪装”自己的类型。错误的类型性质会破坏标准库对对象模型的假设。

如果需要描述业务类型，应定义自己的 trait：

```cpp
template <typename T>
struct is_business_id : std::false_type {};

struct UserId {};

template <>
struct is_business_id<UserId> : std::true_type {};

template <typename T>
inline constexpr bool is_business_id_v = is_business_id<T>::value;
```

---

## 7. 编译期选择：SFINAE、`if constexpr` 与 `concept`

### 7.1 为什么需要约束模板

下面的模板只有在 `T` 支持 `size()` 时才有效：

```cpp
template <typename T>
void print_size(const T& value) {
    std::cout << value.size() << '\n';
}
```

若调用 `print_size(42)`，编译器会在实例化函数体时才发现 `int` 没有 `size()`。对于复杂模板，错误可能穿过多层标准库实现，难以阅读。

约束模板的目标是：

- 让不适合的类型尽早被排除；
- 在多个实现之间选择最匹配者；
- 更明确地向使用者表达模板所需的能力。

### 7.2 SFINAE 是什么

SFINAE 是 **Substitution Failure Is Not An Error**，即“替换失败不是错误”。

编译器为函数模板替换模板实参时，如果在某些允许的上下文中形成了无效类型或表达式，它不会立刻让整个程序报错，而是把这个候选模板从重载集合中移除，然后继续寻找其他重载。

关键点是：

- SFINAE 主要发生在模板参数替换和候选函数选择阶段；
- 并非模板函数体中的所有错误都属于 SFINAE；
- 若移除候选后没有可调用的重载，最终仍会编译失败；
- 它不是“忽略所有模板错误”的机制。

### 7.3 `std::enable_if`

`std::enable_if` 的概念性定义如下：

```cpp
template <bool Condition, typename T = void>
struct enable_if {}; // 条件为 false 时没有 type

template <typename T>
struct enable_if<true, T> {
    using type = T;
};
```

可以用它让某个函数只接受整数：

```cpp
#include <iostream>
#include <type_traits>

template <typename T,
          std::enable_if_t<std::is_integral_v<T>, int> = 0>
void process(T value) {
    std::cout << "[process] integer: " << value << '\n';
}
```

当 `T` 不是整数时，`std::enable_if_t<false, int>` 不存在，替换失败，于是该函数模板不再是可行候选。

`enable_if` 可以放在返回类型、模板参数或函数参数中。将它放进模板参数通常更易读，也避免一些重载签名问题。

### 7.4 `std::void_t` 与检测惯用法

如果想判断一个类型是否有 `size()` 成员函数，可以利用 `std::void_t`：

```cpp
#include <type_traits>
#include <utility>

template <typename T, typename = void>
struct has_size : std::false_type {};

template <typename T>
struct has_size<T, std::void_t<decltype(std::declval<const T&>().size())>>
    : std::true_type {};

template <typename T>
inline constexpr bool has_size_v = has_size<T>::value;
```

逐项理解：

- 主模板默认继承 `std::false_type`，表示没有检测到 `size()`；
- `std::declval<const T&>()` 只在不求值语境中“假想”得到一个 `const T&`，不需要真的构造对象；
- `decltype(...size())` 获取调用表达式的类型；
- 如果表达式合法，`std::void_t<...>` 得到 `void`，偏特化匹配成功，结果为 `true`；
- 如果表达式不合法，替换失败，编译器退回主模板，结果为 `false`。

```cpp
#include <string>
#include <vector>

static_assert(has_size_v<std::string>);
static_assert(has_size_v<std::vector<int>>);
static_assert(!has_size_v<int>);
```

这类写法称为**检测惯用法（detection idiom）**。理解它有助于阅读 C++17 库代码，但新项目若使用 C++20，通常更适合用 `requires`。

### 7.5 `if constexpr` 简化函数体内选择

若多个类型共享同一个接口入口，只是实现分支不同，`if constexpr` 往往比编写多个 `enable_if` 重载清楚：

```cpp
#include <iostream>
#include <type_traits>

template <typename T>
void serialize(const T& value) {
    if constexpr (std::is_integral_v<T>) {
        std::cout << "[serialize] integer=" << value << '\n';
    } else if constexpr (std::is_floating_point_v<T>) {
        std::cout << "[serialize] floating=" << value << '\n';
    } else {
        static_assert(std::is_same_v<T, void>,
                      "serialize does not support this type");
    }
}
```

最后的 `static_assert` 依赖 `T`，因此只会在该分支被实例化时失败。C++23 可以使用 `static_assert(false, ...)`，但在较老标准中，为了兼容通常使用依赖模板参数的恒假表达式。

### 7.6 C++20 `concept`：直接表达能力要求

`concept` 是对一组模板要求的命名：

```cpp
#include <concepts>
#include <iostream>

template <typename T>
concept Number = std::integral<T> || std::floating_point<T>;

template <Number T>
T square(T value) {
    std::cout << "[square] numeric input\n";
    return value * value;
}
```

也可以使用 `requires` 表达式检测具体操作：

```cpp
#include <concepts>
#include <cstddef>

template <typename T>
concept Sized = requires(const T& value) {
    { value.size() } -> std::convertible_to<std::size_t>;
};

template <Sized T>
void print_size(const T& value) {
    std::cout << "[print_size] size=" << value.size() << '\n';
}
```

`requires` 表达式不会真正运行 `value.size()`，它在编译期检查：

- 该表达式是否存在；
- 表达式结果是否满足 `std::convertible_to<std::size_t>`。

还可以把约束写在函数后面：

```cpp
template <typename T>
void print_size(const T& value)
    requires Sized<T>
{
    std::cout << value.size() << '\n';
}
```

### 7.7 三种工具如何选择

| 工具 | 适用标准 | 主要用途 | 初学者建议 |
| --- | --- | --- | --- |
| `std::enable_if` / SFINAE | C++11 起 | 让重载参与或退出候选集合 | 需要读懂旧代码，新增复杂接口时慎用 |
| `std::void_t` | C++17 起 | 检测类型、成员和表达式是否合法 | 用于理解 traits 和旧式检测惯用法 |
| `if constexpr` | C++17 起 | 在模板函数体内选择并丢弃分支 | C++17 代码优先考虑 |
| `concept` / `requires` | C++20 起 | 声明模板的能力要求并参与重载选择 | C++20 新代码优先考虑 |

这些工具不是完全互斥的。例如可以用 `concept` 约束接口，再在函数体内用 `if constexpr` 选择具体实现。

---

## 8. C++ 中的多态

### 8.1 多态的概念

**多态（polymorphism）**直译为“多种形态”。在程序设计中，它表示使用一个统一接口操作不同类型，而具体行为随类型或对象而变化。

初学阶段经常把多态等同于虚函数，这是因为虚函数是 C++ 面向对象运行时多态的核心。但从更广的角度看，C++ 至少存在：

- **重载多态**：同名函数根据参数类型选择不同重载；
- **参数多态**：模板把类型当作参数，同一份代码适用于多种类型；
- **子类型多态**：基类指针或引用操作派生类对象，虚函数在运行时分派；
- **类型擦除式多态**：把具体类型隐藏在统一包装器后，如 `std::function`。

工程中最常比较的是模板带来的**静态多态**与虚函数带来的**动态多态**。

### 8.2 动态多态的三个必要条件

典型的动态多态需要：

1. 基类声明虚函数；
2. 派生类重写虚函数；
3. 通过基类的指针或引用调用虚函数。

```cpp
#include <iostream>
#include <memory>
#include <vector>

class Shape {
public:
    virtual ~Shape() = default;
    virtual double area() const = 0;
    virtual void draw() const = 0;
};

class Circle final : public Shape {
public:
    explicit Circle(double radius) : radius_(radius) {}

    double area() const override {
        return 3.141592653589793 * radius_ * radius_;
    }

    void draw() const override {
        std::cout << "[Circle] draw, area=" << area() << '\n';
    }

private:
    double radius_;
};

class Rectangle final : public Shape {
public:
    Rectangle(double width, double height)
        : width_(width), height_(height) {}

    double area() const override {
        return width_ * height_;
    }

    void draw() const override {
        std::cout << "[Rectangle] draw, area=" << area() << '\n';
    }

private:
    double width_;
    double height_;
};

int main() {
    std::vector<std::unique_ptr<Shape>> shapes;
    shapes.push_back(std::make_unique<Circle>(2.0));
    shapes.push_back(std::make_unique<Rectangle>(3.0, 4.0));

    for (const auto& shape : shapes) {
        shape->draw(); // 运行时决定调用 Circle 还是 Rectangle
    }
}
```

`Shape` 是抽象基类，因为它含有纯虚函数。`Circle` 和 `Rectangle` 都遵守 `Shape` 接口，容器只保存 `Shape` 的智能指针，却可以容纳不同的派生类对象。

### 8.3 虚函数分派的概念模型

常见编译器通常使用虚函数表实现动态多态：

- 含虚函数的多态类通常有一张虚函数表；
- 对象中通常保存一个指向虚函数表的隐藏指针；
- 通过基类指针调用虚函数时，程序查表并跳转到实际对象对应的实现。

但 C++ 标准规定的是**可观察行为**，并没有强制所有实现必须采用某种固定的虚函数表内存布局。因此，“虚表一定放在哪里”“虚表指针一定是对象第一个成员”等说法只能当作常见 ABI 实现经验，不能当成标准保证。

### 8.4 为什么基类析构函数通常要是虚函数

如果对象可能通过基类指针被删除，基类析构函数必须是虚函数：

```cpp
class Base {
public:
    virtual ~Base() = default;
};
```

否则：

```cpp
Base* object = new Derived;
delete object;
```

会产生未定义行为，而不只是简单的“可能少释放一点内存”。通用设计准则是：作为多态基类时提供公共虚析构函数；如果不允许通过基类删除，则使用受保护的非虚析构函数等更明确的设计。

### 8.5 对象切片

若按值把派生类对象复制给基类对象，派生类特有部分会被丢弃：

```cpp
void draw_by_value(Shape shape); // 这里甚至无法使用抽象类 Shape
```

对于非抽象基类也会发生切片：

```cpp
Base base = Derived{}; // 只保留 Base 子对象
```

动态多态接口通常使用基类引用、指针或智能指针，而不是按值传递基类。

### 8.6 动态多态适合什么场景

- 具体对象类型只有运行时才知道；
- 需要在一个容器中保存不同派生类对象；
- 需要稳定的非模板接口或插件式扩展边界；
- 调用者应只依赖基类契约，而不接触具体实现；
- 允许少量间接调用开销，并愿意管理对象生命周期。

---

## 9. 模板怎样实现静态多态

### 9.1 编译期根据类型生成不同调用

```cpp
#include <iostream>

class Circle {
public:
    void draw() const {
        std::cout << "[Circle] draw\n";
    }
};

class Rectangle {
public:
    void draw() const {
        std::cout << "[Rectangle] draw\n";
    }
};

template <typename Shape>
void render(const Shape& shape) {
    shape.draw();
}

int main() {
    render(Circle{});       // 实例化 render<Circle>
    render(Rectangle{});    // 实例化 render<Rectangle>
}
```

`Circle` 和 `Rectangle` 不需要继承同一个基类，也不需要虚函数。只要它们都提供可调用的 `draw()`，模板就能使用它们。

这叫静态多态，因为在编译期 `Shape` 已经是确定类型，编译器知道应该调用哪个成员函数。它常能直接内联调用。

### 9.2 静态多态不是“完全没有接口”

它仍然存在接口，只是接口不一定由基类显式声明，而是由模板表达式隐式要求：

```cpp
shape.draw();
```

这句话就是对类型能力的要求。C++20 可以把隐式要求显式化：

```cpp
template <typename T>
concept Drawable = requires(const T& value) {
    value.draw();
};

template <Drawable T>
void render(const T& object) {
    object.draw();
}
```

动态多态中的基类是一种**名义接口**：类型必须声明继承关系。模板 / concept 更接近**结构化接口**：类型只要具备所需结构和操作即可。

### 9.3 CRTP：把派生类类型传给基类模板

CRTP 是 Curiously Recurring Template Pattern，中文常译为“奇异递归模板模式”：

```cpp
#include <iostream>

template <typename Derived>
class Drawable {
public:
    void draw() const {
        std::cout << "[Drawable] dispatch to derived implementation\n";
        static_cast<const Derived&>(*this).draw_impl();
    }
};

class Circle : public Drawable<Circle> {
public:
    void draw_impl() const {
        std::cout << "[Circle] draw implementation\n";
    }
};

class Rectangle : public Drawable<Rectangle> {
public:
    void draw_impl() const {
        std::cout << "[Rectangle] draw implementation\n";
    }
};
```

看起来像“派生类继承了以自己为参数的基类”，因此得名。关键过程是：

1. `Circle` 继承 `Drawable<Circle>`；
2. `Drawable<Circle>::draw()` 中，`Derived` 已知为 `Circle`；
3. 基类通过 `static_cast` 得到派生类引用；
4. 编译器静态绑定到 `Circle::draw_impl()`。

CRTP 的常见用途：

- 静态接口复用；
- mixin（混入）功能；
- 在不使用虚函数的情况下让基类调用派生类实现；
- 为每个派生类型维护独立静态状态；
- 运算符复用和表达式模板。

CRTP 不是动态多态的直接替代品。`Drawable<Circle>` 和 `Drawable<Rectangle>` 是不同的基类类型，不能像 `Shape*` 那样自然放进同一个同质容器。

### 9.4 编译期标签分派

在 `if constexpr` 出现之前，标准库风格代码经常使用**标签分派（tag dispatch）**：把编译期性质包装成一个空类型，再用重载选择实现。

```cpp
#include <iostream>
#include <type_traits>

template <typename T>
void destroy_impl(T*, std::true_type) {
    std::cout << "[destroy] trivial destructor, no action needed\n";
}

template <typename T>
void destroy_impl(T* object, std::false_type) {
    std::cout << "[destroy] invoking non-trivial destructor\n";
    object->~T();
}

template <typename T>
void destroy(T* object) {
    destroy_impl(object, std::is_trivially_destructible<T>{});
}
```

`std::is_trivially_destructible<T>{}` 的类型要么相当于 `std::true_type`，要么相当于 `std::false_type`，从而选择对应重载。现代代码通常可用 `if constexpr` 写得更直接，但阅读 STL 实现和旧代码时仍会遇到标签分派。

### 9.5 策略模板

模板可以把“变化的行为”作为策略类型注入：

```cpp
#include <iostream>
#include <string>

struct ConsoleLogger {
    void log(const std::string& message) const {
        std::cout << "[console] " << message << '\n';
    }
};

struct SilentLogger {
    void log(const std::string&) const {}
};

template <typename Logger>
class Service {
public:
    explicit Service(Logger logger = {}) : logger_(logger) {}

    void run() {
        logger_.log("service started");
        // 业务逻辑
        logger_.log("service finished");
    }

private:
    Logger logger_;
};
```

`Service<ConsoleLogger>` 与 `Service<SilentLogger>` 在编译期选择不同日志策略，没有虚函数分派。STL 的比较器、哈希器和分配器都是类似的策略参数。

---

## 10. 动态多态、静态多态与类型擦除

### 10.1 静态多态与动态多态对比

| 维度 | 静态多态（模板） | 动态多态（虚函数） |
| --- | --- | --- |
| 绑定时机 | 编译期 | 运行期 |
| 接口形式 | 操作要求、trait、concept、CRTP | 继承体系和虚函数 |
| 类型关系 | 不要求共同基类 | 通常要求共同基类 |
| 调用开销 | 常可内联，没有虚调用所需的间接分派 | 通常有一次间接调用，具体成本依实现和优化而定 |
| 代码体积 | 多种类型可能生成多份实例 | 多个对象共享各自类的函数实现 |
| 编译依赖 | 模板实现通常暴露在头文件中 | 接口与实现更容易分离 |
| 异构容器 | 不直接擅长 | 基类指针容器自然支持 |
| 扩展时机 | 新类型通常要参与重新编译 | 可适合运行时加载和插件边界 |
| 错误发现 | 编译期 | 部分关系由编译器检查，具体对象选择发生在运行时 |

不能简单断言“模板一定比虚函数快”。性能取决于调用频率、缓存局部性、编译器是否去虚拟化、代码体积和实际硬件。选择机制时应先根据建模需求，再用基准测试验证热点。

### 10.2 类型擦除是什么

类型擦除（type erasure）让调用者只看到统一的值类型接口，而把具体类型隐藏在包装器内部。`std::function` 是标准库中的典型例子：

```cpp
#include <functional>
#include <iostream>
#include <vector>

void free_function(int value) {
    std::cout << "[free_function] " << value << '\n';
}

int main() {
    std::vector<std::function<void(int)>> callbacks;

    callbacks.push_back(free_function);
    callbacks.push_back([](int value) {
        std::cout << "[lambda] " << value * 2 << '\n';
    });

    for (const auto& callback : callbacks) {
        callback(10);
    }
}
```

普通函数和 Lambda 的具体类型不同，但都可以放进 `std::function<void(int)>`。包装器保留“可以接收一个 `int`，返回 `void`”这一调用接口，擦除了内部可调用对象的具体类型。

类型擦除通常在内部结合模板和运行时间接分派：

- 模板负责接收任意符合要求的具体类型；
- 包装器隐藏该类型；
- 运行时通过内部函数指针或虚接口等机制完成调用。

所以静态多态与动态多态并非总是互斥，库实现可以把它们组合起来。

`std::function` 可能发生动态内存分配，也有间接调用成本；小型对象优化可能避免部分分配，但不是所有对象都保证如此。在性能敏感路径中应实测，而不是把它当作无成本的函数指针。

### 10.3 `std::variant`：封闭类型集合的另一种选择

如果所有可能类型在编译期已知，可以使用 `std::variant`：

```cpp
#include <iostream>
#include <variant>
#include <vector>

struct Circle {
    void draw() const { std::cout << "[Circle] draw\n"; }
};

struct Rectangle {
    void draw() const { std::cout << "[Rectangle] draw\n"; }
};

using Shape = std::variant<Circle, Rectangle>;

int main() {
    std::vector<Shape> shapes{Circle{}, Rectangle{}};

    for (const Shape& shape : shapes) {
        std::visit([](const auto& concrete_shape) {
            concrete_shape.draw();
        }, shape);
    }
}
```

这里：

- `variant` 能保存列出的任意一个类型；
- `std::visit` 使用泛型 Lambda 处理当前实际值；
- 类型集合是封闭的，增加新类型需要修改 `variant` 定义和可能的访问逻辑；
- 不需要为对象建立共同基类。

大致选择思路：

- 类型集合开放、运行时不断加入派生实现：考虑虚函数或类型擦除；
- 类型集合封闭、所有可能类型编译期已知：考虑 `std::variant`；
- 调用点本身是模板、类型编译期已知：优先考虑直接静态多态。

### 10.4 为什么成员函数模板不能是虚函数

C++ 不允许把成员函数模板声明为虚函数：

```cpp
class Processor {
public:
    template <typename T>
    // virtual void process(const T& value); // 错误：成员函数模板不能为 virtual
    void process(const T& value);
};
```

理解原因时，可以比较两种机制需要的信息：

- 虚函数要求类的运行时接口集合能够被确定，常见实现需要为每个虚函数安排稳定的虚表入口；
- 函数模板可以因任意新类型而产生新的实例，实例集合取决于整个程序中出现的调用；
- 如果允许虚函数模板，就难以在类的接口布局中预先确定究竟需要为哪些 `T` 准备可动态分派的入口。

因此，C++ 把“运行时接口”和“任意类型参数化”分开处理。常见替代设计包括：

1. 让虚函数使用一个固定的基类、`std::variant` 或已擦除类型作为参数；
2. 让非虚成员函数模板先把输入转换成统一表示，再调用受保护的虚函数；
3. 如果所有类型在编译期已知，直接使用静态多态而不是虚函数；
4. 使用 `std::any`、`std::function` 或自定义类型擦除，但明确其运行时检查和间接调用成本。

下面是“模板外壳 + 固定虚接口”的概念示例：

```cpp
#include <iostream>
#include <sstream>
#include <string>

class Logger {
public:
    virtual ~Logger() = default;

    template <typename T>
    void log(const T& value) {
        std::ostringstream stream;
        stream << value;
        log_text(stream.str());
    }

private:
    virtual void log_text(const std::string& text) = 0;
};

class ConsoleLogger final : public Logger {
private:
    void log_text(const std::string& text) override {
        std::cout << "[console] " << text << '\n';
    }
};
```

调用 `log<T>` 时先发生静态模板实例化，转换成 `std::string` 后，再通过固定签名的 `log_text` 发生动态分派。这个例子也说明两类多态可以分层组合。

---

## 11. STL 为什么离不开模板元编程

### 11.1 STL 不只是容器集合

STL（Standard Template Library）最核心的设计，是把数据存储与算法分离，再用迭代器建立连接。通常可从以下组件理解：

- **容器（container）**：保存元素，如 `vector`、`list`、`map`；
- **迭代器（iterator）**：描述如何遍历元素；
- **算法（algorithm）**：对迭代器范围执行操作，如 `sort`、`find`；
- **函数对象（function object）**：自定义比较、变换等策略；
- **适配器（adapter）**：转换已有接口，如 `stack`、反向迭代器；
- **分配器（allocator）**：抽象内存分配策略；
- **类型萃取（traits）**：向算法提供类型的编译期信息。

它们依靠模板组合，而不是要求所有容器继承一个共同基类。

### 11.2 容器是类模板

```cpp
std::vector<int> numbers;
std::vector<std::string> names;
std::map<std::string, int> scores;
```

`std::vector<int>` 与 `std::vector<std::string>` 是不同类型。模板使同一种存储逻辑适应不同元素类型，同时保持静态类型安全。

以概念化形式观察 `vector`：

```cpp
template <
    typename T,
    typename Allocator = std::allocator<T>
>
class vector;
```

`T` 是元素类型，`Allocator` 是内存分配策略。默认模板参数让常规使用保持简洁，但高级用户仍可替换策略。

关联容器也会把行为作为模板参数：

```cpp
template <
    typename Key,
    typename T,
    typename Compare = std::less<Key>,
    typename Allocator = /* ... */
>
class map;
```

`Compare` 决定键的严格弱序关系。它体现了策略模板和静态多态：容器不要求比较器继承某个基类，只要求它可以像函数一样被调用。

### 11.3 算法是函数模板

`std::find` 的概念性形式如下：

```cpp
template <typename InputIterator, typename T>
InputIterator find(InputIterator first, InputIterator last, const T& value);
```

算法不需要知道它处理的是 `vector` 还是 `list`，只依赖迭代器所提供的操作。这带来两个重要结果：

- 同一个算法可以复用于不同容器；
- 用户自定义数据结构只要提供符合要求的迭代器，也能使用标准算法。

这就是“针对能力编程”，而不是“针对具体类名编程”。

### 11.4 迭代器是容器与算法之间的协议

迭代器看起来像指针，常见操作包括：

```cpp
*iterator;   // 读取当前元素
++iterator;  // 移动到下一个元素
iterator != end;
```

不同算法需要不同能力。经典迭代器分类由弱到强大致包括：

| 类别 | 主要能力 | 典型来源 |
| --- | --- | --- |
| 输入迭代器 | 单向读取，适合一次遍历 | 输入流迭代器 |
| 输出迭代器 | 单向写入 | 输出流、插入迭代器 |
| 前向迭代器 | 可重复多次单向遍历 | `forward_list` |
| 双向迭代器 | 可执行 `++` 和 `--` | `list`、`set`、`map` |
| 随机访问迭代器 | 支持跳跃、下标和距离比较 | `vector`、`deque`、`array` |
| 连续迭代器（C++20） | 元素还保证在内存中连续 | `vector`、`array`、`string` |

能力存在层级关系：随机访问迭代器也具备双向和前向遍历能力，但反过来不成立。

因此：

```cpp
std::vector<int> values{4, 1, 3};
std::sort(values.begin(), values.end()); // 正确

std::list<int> values{4, 1, 3};
// std::sort(values.begin(), values.end()); // 错误：list 迭代器不能随机访问
values.sort();                            // 使用 list 自己的排序成员函数
```

`std::sort` 要求随机访问迭代器，因为其算法需要高效跳转位置。`list` 的节点不连续，只提供双向迭代器。

### 11.5 `iterator_traits`：统一普通指针与迭代器

算法经常需要知道迭代器指向的元素类型、距离类型和迭代器类别。标准库通过 `std::iterator_traits` 提取这些信息：

```cpp
#include <iterator>

template <typename Iterator>
void inspect_iterator(Iterator) {
    using Traits = std::iterator_traits<Iterator>;
    using Value = typename Traits::value_type;
    using Difference = typename Traits::difference_type;

    static_assert(sizeof(Value) > 0);
    static_assert(std::is_signed_v<Difference>);
}
```

为什么不直接写 `Iterator::value_type`？因为普通指针 `int*` 也可以充当迭代器，但指针不是类，没有嵌套成员 `value_type`。`iterator_traits` 可以为指针提供特化，把二者统一到同一个接口：

```cpp
template <typename T>
struct iterator_traits<T*> {
    using value_type = T;
    using difference_type = std::ptrdiff_t;
    // 其他信息省略
};
```

这正是模板特化和类型萃取在 STL 中的直接应用。

### 11.6 标签分派如何帮助 STL 选择算法

以 `std::advance(iterator, n)` 为例：

- 对随机访问迭代器，可以直接执行 `iterator += n`；
- 对双向迭代器，需要根据正负反复执行 `++` 或 `--`；
- 对仅能向前的迭代器，只能反复执行 `++`，而且 `n` 不能为负。

经典实现会读取 `iterator_traits<Iterator>::iterator_category`，再用标签类型选择不同重载。概念性代码如下：

```cpp
template <typename Iterator, typename Distance>
void advance_impl(Iterator& it, Distance n, std::random_access_iterator_tag) {
    it += n;
}

template <typename Iterator, typename Distance>
void advance_impl(Iterator& it, Distance n, std::bidirectional_iterator_tag) {
    if (n >= 0) {
        while (n-- > 0) {
            ++it;
        }
    } else {
        while (n++ < 0) {
            --it;
        }
    }
}

template <typename Iterator, typename Distance>
void my_advance(Iterator& it, Distance n) {
    using Category = typename std::iterator_traits<Iterator>::iterator_category;
    advance_impl(it, n, Category{});
}
```

这段代码展示了完整的编译期链路：

1. 模板接收任意迭代器类型；
2. trait 在编译期提取迭代器类别；
3. 类别由一个空的标签类型表示；
4. 函数重载在编译期选择最佳实现；
5. 最终程序中执行针对该迭代器优化后的普通代码。

C++20 Ranges 使用 concept 更直接地表达迭代器能力，但 traits 和标签仍是理解传统 STL 实现的基础。

### 11.7 函数对象和 Lambda 是算法策略

`std::sort` 可以接收比较器：

```cpp
#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

struct Person {
    std::string name;
    int age;
};

int main() {
    std::vector<Person> people{
        {"Alice", 30},
        {"Bob", 20},
        {"Carol", 25}
    };

    std::sort(people.begin(), people.end(),
              [](const Person& left, const Person& right) {
                  return left.age < right.age;
              });

    for (const Person& person : people) {
        std::cout << "[person] " << person.name
                  << ", age=" << person.age << '\n';
    }
}
```

Lambda 有一个由编译器生成、无法直接书写名称的闭包类型。`std::sort` 把比较器类型作为模板参数实例化，因此调用常可被内联。

比较器必须建立**严格弱序（strict weak ordering）**。直观要求包括：

- `comp(x, x)` 必须为 `false`；
- 如果 `comp(a, b)` 为 `true`，`comp(b, a)` 必须为 `false`；
- 顺序必须保持传递性；
- 被视为等价的元素关系也要保持一致。

错误比较器可能使排序算法行为不符合预期，甚至触发未定义行为。不能用 `left.age <= right.age` 代替 `<`。

### 11.8 `std::less<>` 展示透明比较器

```cpp
std::map<std::string, int, std::less<>> scores;
```

`std::less<>` 是透明比较器，可以在类型允许时直接比较不同但兼容的类型。这使关联容器能够进行异构查找，避免为了查找而临时构造完整的键对象。

它依赖模板化的调用运算符和编译期重载选择，是“策略对象 + 模板元编程”在日常 STL 使用中的一个精巧例子。

### 11.9 分配器是另一种策略

容器把内存分配器作为模板参数，使存储逻辑与分配策略分离：

```cpp
std::vector<int, MyAllocator<int>> values;
```

标准分配器模型涉及 `allocator_traits`、rebind、传播规则等较复杂概念。初学阶段应先知道：

- `std::allocator<T>` 是默认策略；
- 容器通过 `std::allocator_traits` 统一访问分配器能力；
- 自定义分配器适合内存池、共享内存、特殊硬件内存等明确场景；
- 不应仅为了练习而在业务代码里贸然替换分配器。

### 11.10 Ranges 与 concept

C++20 Ranges 把“迭代器对”进一步抽象成范围，并大量使用 concept 表达约束：

```cpp
#include <algorithm>
#include <iostream>
#include <ranges>
#include <vector>

int main() {
    std::vector<int> values{5, 2, 8, 1, 4};

    auto even_values = values | std::views::filter([](int value) {
        return value % 2 == 0;
    });

    for (int value : even_values) {
        std::cout << "[even] " << value << '\n';
    }

    std::ranges::sort(values);
}
```

`views::filter` 通常是惰性的：创建视图时并不立刻复制并筛选所有元素，遍历时才按需计算。其返回类型由多个模板适配器组合而成。Ranges 是现代模板、concept、静态多态和 STL 设计思想的集中体现。

---

## 12. 从一次 STL 调用看完整协作过程

观察下面的代码：

```cpp
std::vector<Person> people = /* ... */;

std::sort(people.begin(), people.end(),
          [](const Person& a, const Person& b) {
              return a.age < b.age;
          });
```

虽然只有几行代码，背后包含了本专题几乎所有核心思想。

### 12.1 容器层

`std::vector<Person>` 是类模板实例：

- `Person` 是元素类型；
- 默认分配器一般是 `std::allocator<Person>`；
- 该实例管理连续内存、元素构造与析构；
- 类型萃取会帮助容器判断元素的构造、移动、析构等性质。

### 12.2 迭代器层

`people.begin()` 与 `people.end()` 返回迭代器：

- 迭代器封装当前位置；
- 它支持随机访问所需操作；
- `iterator_traits` 可以提取它的元素类型、差值类型和类别。

### 12.3 算法层

`std::sort` 是函数模板：

- 根据迭代器类型实例化；
- 检查或假定迭代器具有随机访问能力；
- 对元素执行移动、交换和比较；
- 标准规定复杂度等行为要求，但不强制唯一的内部排序算法。

常见标准库实现采用 introsort 一类混合策略，但这属于实现细节，不能把某个具体实现当作标准保证。

### 12.4 策略层

Lambda 是比较策略：

- 编译器为它生成闭包类型；
- `std::sort` 将该类型作为模板参数；
- `operator()` 提供比较能力；
- 编译器常能内联这个很小的调用。

### 12.5 多态层

同一个 `std::sort` 接口能够处理：

- 不同元素类型；
- 不同随机访问迭代器类型；
- 不同比较器类型。

但没有虚函数参与。不同调用在编译期实例化成相应版本，因此这是静态多态。

### 12.6 元编程层

在标准库实现内部，可能使用：

- `iterator_traits` 获取迭代器属性；
- `is_*` traits 判断元素能力；
- 标签、重载、SFINAE 或 concept 选择合法路径；
- `constexpr` 计算小型编译期信息；
- 完美转发与引用萃取保持值类别。

最终，使用者看到的是简洁接口；复杂性被模板库封装起来。这正是优秀泛型库的价值。

---

## 13. 容易混淆的概念与常见错误

### 13.1 模板参数、模板实参与函数参数

```cpp
template <typename T, std::size_t N>
void print(const std::array<T, N>& values);
```

- `T`、`N` 是模板参数；
- 在 `print<int, 3>` 中，`int`、`3` 是模板实参；
- `values` 是函数参数；
- 调用时传入的具体数组对象是函数实参。

### 13.2 实例化不等于显式特化

- **实例化**：从模板和实参生成具体实体，可以由调用隐式触发，也可显式要求；
- **显式特化**：程序员为特定实参组合重新提供实现；
- **偏特化**：程序员为一类实参模式提供实现，只适用于类模板和变量模板等，不适用于函数模板。

### 13.3 重载、重写、隐藏与特化

| 概念 | 发生位置 | 核心含义 |
| --- | --- | --- |
| 重载 overload | 同一作用域的同名函数 | 根据参数列表选择函数 |
| 重写 override | 派生类与基类之间 | 派生类重写基类虚函数 |
| 隐藏 name hiding | 内外作用域或派生类与基类之间 | 内层同名声明遮蔽外层名字 |
| 特化 specialization | 模板体系中 | 为特定模板实参提供规则 |

它们解决的问题不同，不应混用术语。

### 13.4 普通 `if` 不能替代 `if constexpr`

```cpp
template <typename T>
void print_value(const T& value) {
    if (std::is_pointer_v<T>) {
        std::cout << *value; // 对非指针 T 仍需要编译，可能报错
    } else {
        std::cout << value;
    }
}
```

应改为：

```cpp
if constexpr (std::is_pointer_v<T>) {
    std::cout << *value;
} else {
    std::cout << value;
}
```

普通 `if` 只在运行时选择执行路径；`if constexpr` 才会在模板实例化时丢弃未选分支。

### 13.5 `typename` 的两种含义

第一种是在模板参数列表中引入类型参数：

```cpp
template <typename T>
```

第二种是在依赖名之前说明它是类型：

```cpp
using Value = typename std::iterator_traits<Iterator>::value_type;
```

这两个位置都写 `typename`，但承担的语法角色不同。

### 13.6 模板定义中的错误为什么可能很晚才出现

模板会进行与依赖名有关的延迟检查。例如：

```cpp
template <typename T>
void call_run(T& object) {
    object.run(); // 是否存在 run，取决于实例化时的 T
}
```

只定义模板但从未实例化时，编译器可能无法判断 `object.run()` 是否合法。等到用 `int` 实例化才报错。这个现象与模板的两阶段名字查找有关。

但不依赖模板参数的明显语法错误通常仍会在模板定义阶段被发现。不要误以为模板中的任何错误都会被推迟。

### 13.7 不要滥用运行时类型判断代替虚函数

下面的设计通常扩展性较差：

```cpp
if (typeid(*shape) == typeid(Circle)) {
    // 圆形逻辑
} else if (typeid(*shape) == typeid(Rectangle)) {
    // 矩形逻辑
}
```

增加新类型就要修改集中式分支。若行为天然属于对象，应优先考虑虚函数；若类型集合封闭且操作经常扩展，可以评估 `std::variant` 与访问者。`dynamic_cast` 适合确实需要安全向下转换的边界场景，不应成为日常多态分派的主要手段。

### 13.8 不要把所有东西都设计成模板

以下情况不一定适合模板：

- 类型只在运行时确定；
- 需要隐藏实现、减少头文件依赖或稳定 ABI；
- 类型种类很少，代码复用价值有限；
- 模板让接口和报错明显复杂化，却没有性能或安全收益；
- 需要把不同类型对象放入统一容器，而不想暴露类型集合。

普通函数、虚接口、`std::function`、`std::variant` 和模板都是工具，应根据约束选择。

### 13.9 `std::vector<std::unique_ptr<Base>>` 可以使用

一个常见误解是 `unique_ptr` 不能放入 STL 容器。事实上，现代标准容器支持移动语义：

```cpp
std::vector<std::unique_ptr<Shape>> shapes;
shapes.push_back(std::make_unique<Circle>(2.0));
```

`unique_ptr` 不能复制，但可以移动，因此可以放入 `vector`。只有要求复制元素的具体操作不可用于它。

### 13.10 调试模板错误的方法

面对很长的实例化错误，可按以下顺序缩小问题：

1. 找到错误信息中最先出现的自己代码位置；
2. 明确本次实例化的实际类型，例如 `T = std::string`；
3. 把模板内部要求列出来：需要 `<`、`size()`、复制还是移动？
4. 用 `static_assert` 和标准 traits 验证关键性质；
5. 把复杂表达式拆成 `using` 别名和小函数；
6. 使用 C++20 concept 给接口添加清晰约束；
7. 创建最小可复现示例，去掉与错误无关的嵌套模板。

---

## 14. 学习路线与总结

### 14.1 推荐学习顺序

第一阶段：掌握模板的基本使用。

- 函数模板与模板实参推导；
- 类模板、非类型模板参数；
- 模板定义为什么通常放在头文件；
- 显式实例化、全特化和偏特化的区别。

第二阶段：理解编译期编程。

- `constexpr`、`static_assert`；
- `std::integral_constant`；
- 常用 `<type_traits>`；
- `if constexpr`；
- SFINAE、`enable_if` 和 `void_t` 的阅读能力。

第三阶段：联系多态。

- 虚函数和动态分派；
- 模板的静态多态；
- CRTP；
- 类型擦除与 `std::function`；
- `std::variant` 和封闭类型集合。

第四阶段：回到 STL 验证理解。

- 容器为什么是类模板；
- 算法为什么接收迭代器；
- `iterator_traits` 和迭代器类别；
- 比较器、哈希器、分配器等策略；
- C++20 Ranges 和 concept。

### 14.2 建议动手练习

1. 编写 `is_pointer`、`remove_pointer`，再与标准 traits 对照；
2. 编写一个只能接收整数的 `safe_add`，分别用 `enable_if` 和 concept 实现；
3. 用 `if constexpr` 写一个能打印普通值和指针所指值的函数；
4. 分别用虚函数、模板和 `std::variant` 实现图形 `draw()`；
5. 编写接受迭代器范围的 `my_find`，让它同时支持 `vector` 和 `list`；
6. 给 `std::sort` 传入函数对象和 Lambda，观察两者的类型；
7. 尝试对 `list` 使用 `std::sort`，阅读编译错误并解释迭代器能力不足的原因。

### 14.3 一句话抓住每个核心概念

- **模板**：把类型或编译期值参数化，让编译器生成具体代码。
- **模板实例化**：用具体模板实参生成函数、类或变量实体。
- **泛型编程**：针对一组能力编写可复用算法，而不是绑定某个具体类型。
- **模板元编程**：在编译期计算、判断类型并选择实现。
- **类型萃取**：用统一模板接口查询或变换类型。
- **SFINAE**：模板替换失败时移除候选，而不是立即终止整个编译。
- **concept**：为模板的能力要求命名，并让编译器据此约束和选择模板。
- **静态多态**：编译期根据具体类型确定行为，模板是主要实现手段。
- **动态多态**：运行时根据对象实际类型分派虚函数。
- **类型擦除**：隐藏具体类型，只保留一组统一操作接口。
- **STL**：用模板把容器、迭代器、算法和策略解耦并重新组合。

### 14.4 最终知识主线

模板首先解决“同一逻辑如何适用于不同类型”的问题。模板实例化让编译器为具体类型生成代码，由此形成静态多态。模板特化、类型萃取、SFINAE、`if constexpr` 和 concept 又进一步让程序能够在编译期判断类型能力并选择实现，这构成现代模板元编程的核心。

虚函数走的是另一条路线：先用共同基类规定运行时接口，再根据对象的实际类型动态分派。它适合运行时异构对象、开放式扩展和稳定接口。静态多态更适合类型在编译期已知、追求组合能力和优化空间的场景。类型擦除和 `std::variant` 则填补了两者之间的不同需求。

STL 是这些思想的成熟实践：容器负责存储，算法负责处理，迭代器提供通用协议，traits 暴露编译期信息，函数对象和策略参数定制行为。理解模板元编程之后，STL 就不再只是需要背诵的容器清单，而是一套围绕抽象、能力和组合建立起来的泛型设计体系。
