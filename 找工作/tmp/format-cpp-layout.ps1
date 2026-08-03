chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'UTF8'

$text = Get-Content -LiteralPath '编程语言C++整理.pangu.preview.md' -Raw -Encoding UTF8
$nl = "`n`n"
function Split-At([string]$old, [string]$new) {
  $script:text = $script:text.Replace($old, $new)
}

# 混合中文与英文的标题使用中文括号；代码调用中的括号保留 ASCII 形式。
Split-At '### 为什么不能把虚函数声明成 inline(内联）' '### 为什么不能把虚函数声明成 inline（内联）'
Split-At '### 重载(overload )和重写(override)的区别' '### 重载（overload）和重写（override）的区别'
Split-At '### deque(双端队列）' '### deque（双端队列）'
Split-At '### unique_ptr(不可也许，一般不会问，工作中一般用不到）' '### unique_ptr（不可也许，一般不会问，工作中一般用不到）'
Split-At '### auto_ptr(没必要说）' '### auto_ptr（没必要说）'
Split-At '### 段错误(coredump)' '### 段错误（coredump）'
Split-At 'Stack(栈）' 'Stack（栈）'
Split-At 'Queue(队列）' 'Queue（队列）'
Split-At '数组（数组名假设为 map)' '数组（数组名假设为 map）'
Split-At '元素 )重新' '元素）重新'
Split-At '（又称“开链法)' '（又称“开链法”）'

# 将 PDF 提取后粘连的逻辑分段恢复为独立段落。
Split-At '（只回答这一部分就好）并且类的继承有三种方式：' ('（只回答这一部分就好）' + $nl + '并且类的继承有三种方式：')
Split-At '（通过多重继承得到的对象可能拥有不同的地址）数据的冗余' ('（通过多重继承得到的对象可能拥有不同的地址）' + $nl + '数据的冗余')
Split-At '二义性的存在解决方法：' ('二义性的存在。' + $nl + '解决方法：')
Split-At '虚函数表需要进行强制类型转换' ('虚函数表。' + $nl + '需要进行强制类型转换')
Split-At '因此，虚基类只会构造一次 C++ 菱形继承' ('因此，虚基类只会构造一次。' + $nl + 'C++ 菱形继承')
Split-At '虚函数表即可）在虚函数表中' ('虚函数表即可）。' + $nl + '在虚函数表中')
Split-At '派生类新增的虚函数放在数组的最后不是虚函数' ('派生类新增的虚函数放在数组的最后。' + $nl + '不是虚函数')
Split-At '构造函数不能是虚函数使用：' ('构造函数不能是虚函数。' + $nl + '使用：')
Split-At '不能建立抽象类对象抽象类不能' ('不能建立抽象类对象。' + $nl + '抽象类不能')
Split-At '基类类型其实就是' ('基类类型。' + $nl + '其实就是')
Split-At 'Function 虚函数然后在主程序' ('Function 虚函数。' + $nl + '然后在主程序')
Split-At 'Base 版本的虚函数与预期不符' ('Base 版本的虚函数。' + $nl + '与预期不符')
Split-At '返回值类型重写和重载的区别：' ('返回值类型。' + $nl + '重写和重载的区别：')
Split-At '改变了。并且数据存放在堆里' ('改变了。' + $nl + '并且数据存放在堆里')
Split-At '重新获得迭代器；有人说' ('重新获得迭代器；' + $nl + '有人说')
Split-At '释放使用 shrink_to_fit 函数' ('释放。' + $nl + '使用 shrink_to_fit 函数')
Split-At '释放 emplace_back()和 push_back()' ('释放。' + $nl + 'emplace_back()和 push_back()')
Split-At '（先进后出）用队列实现栈的方法：' ('（先进后出）。' + $nl + '用队列实现栈的方法：')
Split-At '（重点看下对应的算法题）使用一个队列实现栈：' ('（重点看下对应的算法题）。' + $nl + '使用一个队列实现栈：')
Split-At '（先进先出）queue 也可以' ('（先进先出）。' + $nl + 'queue 也可以')
Split-At '没有迭代器用栈实现队列：' ('没有迭代器。' + $nl + '用栈实现队列：')
Split-At '增删效率 O(logn)使用 map 容器' ('增删效率 O(logn)。' + $nl + '使用 map 容器')
Split-At '增删效率 O(1)用“链地址法”' ('增删效率 O(1)。' + $nl + '用“链地址法”')
Split-At '哈希值（H）将 H 和' ('哈希值（H）。' + $nl + '将 H 和')
Split-At '不能使用。考虑类的情况：' ('不能使用。' + $nl + '考虑类的情况：')
Split-At '（宏是在预处理阶段进行替换的）还有就是' ('（宏是在预处理阶段进行替换的）。' + $nl + '还有就是')
Split-At '关键字所以，C++11 标准中' ('关键字。' + $nl + '所以，C++11 标准中')
Split-At '只使用 constexpr 的场合。 注意' ('只使用 constexpr 的场合。' + $nl + '注意')
Split-At '动态分配的资源每一个由 shared_ptr' ('动态分配的资源。' + $nl + '每一个由 shared_ptr')
Split-At '并发读写的现象。 shared_ptr' ('并发读写的现象。' + $nl + 'shared_ptr')
Split-At '线程安全不是；' ('线程安全？' + $nl + '不是。')
Split-At '右值）分类：' ('右值）。' + $nl + '分类：')
Split-At '属性不变方案：' ('属性不变。' + $nl + '方案：')
Split-At '仍是左值引用原理：' ('仍是左值引用。' + $nl + '原理：')
Split-At '保护一个变量步骤：' ('保护一个变量。' + $nl + '步骤：')
Split-At '如下图所示栈：' ('如下图所示。' + $nl + '栈：')
Split-At '容量有限堆：' ('容量有限。' + $nl + '堆：')
Split-At '自动回收自由存储区：' ('自动回收。' + $nl + '自由存储区：')
Split-At '命令：valgrind' ('命令：' + $nl + 'valgrind')
Split-At '指针。包括使用未经初始化' ('指针。' + $nl + '包括使用未经初始化')
Split-At '内存读写越界。包括' ('内存读写越界。' + $nl + '包括')
Split-At '变量 cpu 在执行任务' ('变量。' + $nl + 'CPU 在执行任务')

# 合并被提取器拆开的 GDB 列表项。
$text = $text.Replace("，`n`n函数的执行结果等）", '，函数的执行结果等）')

$text = [regex]::Replace($text, '\s+([，。；：！？）])', '$1')
$text = [regex]::Replace($text, '（\s+', '（')
$text = [regex]::Replace($text, '(?:\r?\n){3,}', "`n`n")
$text = $text.Trim() + "`n"
Set-Content -LiteralPath '编程语言C++整理.md' -Value $text -Encoding UTF8
Write-Output '已完成分段与排版整理。'
