# 一、第一个爬虫
``` python
from urllib.request import urlopen  
  
url = "http://www.baidu.com"  
  
res = urlopen(url)  
  
with open("baidu.html", "w" , encoding="utf-8") as f:  
    f.write(res.read().decode("utf-8"))
```

# 二、Requests库实战
## 1. 测试代码
``` python
import requests  
  
url = "http://www.baidu.com"  
res = requests.get(url)  
res.encoding = "utf-8"  
print(res)  
print(res.text)  
with open("baidu.html", "w", encoding="utf-8") as f:  
    f.write(res.text)
```
## 2. GET实战
``` python
import requests  
  
content = input("请输入你要检索的内容：")  
  
# 搜狗对反爬的力度不大，添加个UA防止设备检测就行了  
# f是python的格式化字符串，可以以{xxx}形式将参数动态插入到字符串中
url = f"https://www.sogou.com/web?query={content}"  
  
# 加个UA，防止安全拦截  
headers = {  
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0"  
}  
  
res = requests.get(url, headers=headers)  
res.encoding = "utf-8"  
with open("result.html", "w", encoding="utf-8") as f:  
    f.write(res.text)
```
## 3. POST实战
``` python
import json  
import requests  
  
url = f"https://fanyi.baidu.com/sug"   
content = input("请输入内容：")  
# 内容  
data = {  
    "kw": content  
}  
  
# 返回了一个标准字典对象  
res = requests.post(url, data=data)  
# 将字段对象转为json对象  
result = res.json()  
  
with open("post_result.json", "w", encoding="utf-8") as f:  
    json.dump(result, f, ensure_ascii=False, indent=2)
```

------

# 三、正则表达式
## 1. 概述：自己上网查
## 2. 常用匹配符：
### 基本匹配符
- `.` —— 匹配除换行符外的任意单个字符
- `^` —— 匹配字符串的开始位置
- `$` —— 匹配字符串的结束位置
- `\b` —— 匹配单词边界
- `\B` —— 匹配非单词边界
### 字符类
- `\[abc\]` —— 匹配方括号内的任意一个字符
- `\[^abc\]` —— 匹配除方括号内字符外的任意字符
- `\[a-z\]` —— 匹配指定范围内的任意字符
- `\d` —— 匹配数字字符，等价于 `\[0-9\]`
- `\D` —— 匹配非数字字符
- `\w` —— 匹配单词字符（字母、数字、下划线）
- `\W` —— 匹配非单词字符
- `\s`—— 匹配空白字符（空格、制表符、换行符等）
- `\S` —— 匹配非空白字符
### 量词
- `\*`—— 匹配前面的字符0次或多次
- `\+` —— 匹配前面的字符1次或多次
- `?` —— 匹配前面的字符0次或1次
- `{n}` —— 匹配前面的字符恰好n次
- `{n,}` —— 匹配前面的字符至少n次
- `{n,m}` —— 匹配前面的字符n到m次
### 特殊符号
- `|` —— 或操作符，匹配左边或右边的表达式
- `()` —— 分组，将多个元素组合为一个单元
- `(?:...)` —— 非捕获组，分组但不保存匹配结果
- `(?=...)` —— 正向先行断言
- `(?!...)` —— 负向先行断言
## 3. 贪婪匹配与惰性匹配

### 贪婪匹配 (Greedy Matching)
- **定义**：贪婪匹配是正则表达式的默认行为，它会尽可能多地匹配字符
- **特点**：匹配时会"贪心地"吃掉尽可能多的字符，直到无法继续匹配为止
- **量词**：`*`, `+`, `?`, `{n,m}` 等量词默认都是贪婪的
```python
import re

text = "abc123def456ghi"
# 贪婪匹配 - 匹配尽可能多的数字
greedy_pattern = r"\d+"
result = re.findall(greedy_pattern, text)
print(result)  # ['123', '456']

# 更明显的例子
html = "<div>Hello</div><span>World</span>"
greedy_html = r"<.*>"
result = re.findall(greedy_html, html)
print(result)  # ['<div>Hello</div><span>World</span>']
# 匹配了整个字符串，而不是单独的标签

# 再举个例子
str = "吃饭睡觉打豆豆打游戏\n打搅"
greedy_pattern = r"饭.*打" # 以'饭'开始，中间尽可能多地匹配非换行符字符，以换行符前的最后一个'打'结束。
print(re.findall(greedy_pattern, str)) # ['饭睡觉打豆豆打']
```
### 惰性匹配 (Lazy Matching)
- **定义**：也称为非贪婪匹配，会尽可能少地匹配字符
- **特点**：在找到第一个满足条件的匹配后就停止（或者理解为先进行贪婪匹配，再从后往前回溯，使得匹配内容最少）
- **表示方法**：在量词后面加上 `?` 来启用惰性匹配
```python
import re

text = "abc123def456ghi"
# 惰性匹配 - 匹配尽可能少的数字
lazy_pattern = r"\d+?"
result = re.findall(lazy_pattern, text)
print(result)  # ['1', '2', '3', '4', '5', '6']
# 每个数字都被单独匹配

html = "<div>Hello</div><span>World</span>"
lazy_html = r"<.*?>"
result = re.findall(lazy_html, html)
print(result)  # ['<div>', '</div>', '<span>', '</span>']
# 分别匹配每个标签

# 再举个例子
str = "吃饭睡觉打豆豆打游戏\n打搅"
greedy_pattern = r"饭.*?打" # 以'饭'开始，中间尽可能少地匹配非换行符字符，以第一个匹配的'打'结束。
print(re.findall(greedy_pattern, str)) # ['饭睡觉打']
```
### 常见量词对比

| 贪婪量词 | 惰性量词 | 含义 |
|---------|---------|------|
| `*` | `*?` | 0次或多次 |
| `+` | `+?` | 1次或多次 |
| `?` | `??` | 0次或1次 |
| `{n,m}` | `{n,m}?` | n到m次 |
### 实际应用场景
1. **HTML/XML解析**：使用惰性匹配提取单个标签
2. **文本提取**：从大段文本中提取特定模式的短内容
3. **数据清洗**：精确控制匹配范围避免过度匹配

________

# 四、RE模块
## 1. 介绍：
Python的`re`模块是正则表达式(Regular Expression)处理的核心模块，提供了强大的文本模式匹配和处理功能。
## 2. 主要功能： 
- **模式匹配**: 在字符串中查找符合特定模式的内容
- **文本替换**: 根据模式替换匹配的文本
- **字符串分割**: 使用模式作为分隔符来分割字符串
- **复杂文本处理**: 处理复杂的文本解析和验证任务
## 3. 常用函数：
1. `re.match(pattern, string)` - 从字符串开头匹配模式
2. `re.search(pattern, string)` - 在整个字符串中搜索模式
3. `re.findall(pattern, string)` - 查找所有匹配项并返回列表
4. `re.sub(pattern, repl, string)` - 替换匹配的文本
5. `re.split(pattern, string)` - 按模式分割字符串
6. `re.compile(pattern)` - 编译正则表达式对象以供重复使用
## 4. 代码示例：
```python
import re
# re.match(): 从字符串开头匹配模式
result = re.match(r'Hello', 'Hello World')
if result:
    print(result.group())  # Hello
    
# re.search(): 在整个字符串中搜索模式
result = re.search(r'\d+', 'abc123def')
if result:
    print(result.group())  # 123

# re.findall(): 查找所有匹配项
result = re.search(r'\d+', 'abc123def')
if result:
    print(result.group())  # 123

# re.sub(): 替换匹配的文本
text = re.sub(r'\d+', 'NUMBER', 'abc123def456')
print(text)                # abcNUMBERdefNUMBER

# re.split(): 按模式分割字符串
parts = re.split(r'[,\s]+', 'a,b  c,d') # 匹配一次或多次“逗号+空格符”字符串
print(parts)               # ['a', 'b', 'c', 'd']

# re.compile(): 编译正则表达式对象
# 使用 re.compile() 编译后的正则表达式对象可以重复使用，避免每次调用时都重新解析和编译相同的正则表达式模式。对于频繁使用的复杂模式，能显著提升执行效率
pattern = re.compile(r'\d+')
result = pattern.search('abc123')
print(result.group())      # 123
```

```python
import re  

str = """  
<div class='哈哈哈'><span id='10010'>中国移动</span></div>  
<div class='嘿嘿嘿'><span id='10086'>中国联通</span></div>  
"""  

obj = re.compile(r"<span id='\d+'>.*?</span>")  
obj2 = re.compile(r"<span id='(\d+)'>(.*?)</span>")  
# ?P<name>pattern 是 Python 正则表达式中的命名捕获组语法，用于给正则表达式中的捕获组指定一个名称，方便后续通过名称来引用匹配的内容
obj3 = re.compile(r"<span id='(?P<id>\d+)'>(?P<name>.*?)</span>")
  
print(obj.findall(str))  # ["<span id='10010'>中国移动</span>", "<span id='10086'>中国联通</span>"]
print(obj2.findall(str)) # [('10010', '中国移动'), ('10086', '中国联通')]

# finditer()返回的是个迭代器，包含对应的匹配对象，需要使用group(id)方法获取迭代器中对应表达式id的内容字符串
# 装成字典了，好看点
dict = {}  
for item in obj3.finditer(str):  
    dict['id'] = item.group('id')  
    dict['name'] = item.group('name')  
print(dict)              # {'id': '10086', 'name': '中国联通'}
```

------------
# 5. 实战：使用RE+Requests爬取豆瓣电影 Top 250 榜单
``` python
# 1. 拿到页面源代码  
# 2. 编写正则表达式，提取页面数据  
# 3. 保存数据  
  
import requests  
import re  
  
file = open("top250.csv", "w", encoding="utf-8")  
posi = 0  
url = f"https://movie.douban.com/top250"  
headers = {  
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0"  
}  
# 正则表达式  
# re.S 可以让.匹配换行符  
obj = re.compile(r"""<div class="item">.*?<span class="title">(?P<name>.*?)"""  
                 r"""</span>.*?<p>.*?导演: (?P<director>.*?)&nbsp;"""  
                 r""".*?<br>\s*(?P<year>.*?)&nbsp;.*?<span class="rating_num" property="v:average">"""  
                 r"""(?P<rating>.*?)</span>.*?<span>(?P<comment>.*?)人评价</span>""", re.S)  
  
  
# 正式开始处理数据  
while posi != 250:  
    if posi == 0:  
        res = requests.get(url, headers=headers)  
    else:  
        res = requests.get(url + f"?start={posi}&filter=", headers=headers)  
    source = res.text  
    result = obj.finditer(source)  
  
    print(f"正在爬取第{posi / 25 + 1}页...")  
  
    # 填充movieList  
    movieList = []  
    for item in result:  
        meta = {  
            "name": item.group("name"),  
            "director": item.group("director"),  
            "year": item.group("year"),  
            "rating": item.group("rating"),  
            "comment": item.group("comment")  
        }  
        movieList.append(meta)  
  
    for item in movieList:  
        file.write(item["name"] + "," + item["director"] + "," + item["year"] + "," + item["rating"] + "," + item[  
            "comment"] + "\n")  
  
    for item in movieList:  
        print(item)  
  
    posi += 25  
  
print("\n-------------------------------------------------------------\n爬取结束...")  
  
file.close()
```
## 执行结果节选如下：
``` python
正在爬取第1页...
{'name': '肖申克的救赎', 'director': '弗兰克·德拉邦特 Frank Darabont', 'year': '1994', 'rating': '9.7', 'comment': '3216561'}
{'name': '霸王别姬', 'director': '陈凯歌 Kaige Chen', 'year': '1993', 'rating': '9.6', 'comment': '2374244'}
{'name': '泰坦尼克号', 'director': '詹姆斯·卡梅隆 James Cameron', 'year': '1997', 'rating': '9.5', 'comment': '2442739'}
{'name': '阿甘正传', 'director': '罗伯特·泽米吉斯 Robert Zemeckis', 'year': '1994', 'rating': '9.5', 'comment': '2385281'}
{'name': '千与千寻', 'director': '宫崎骏 Hayao Miyazaki', 'year': '2001', 'rating': '9.4', 'comment': '2484094'}
{'name': '美丽人生', 'director': '罗伯托·贝尼尼 Roberto Benigni', 'year': '1997', 'rating': '9.5', 'comment': '1454085'}
{'name': '这个杀手不太冷', 'director': '吕克·贝松 Luc Besson', 'year': '1994', 'rating': '9.4', 'comment': '2509170'}
{'name': '星际穿越', 'director': '克里斯托弗·诺兰 Christopher Nolan', 'year': '2014', 'rating': '9.4', 'comment': '2121599'}
{'name': '盗梦空间', 'director': '克里斯托弗·诺兰 Christopher Nolan', 'year': '2010', 'rating': '9.4', 'comment': '2280031'}
{'name': '楚门的世界', 'director': '彼得·威尔 Peter Weir', 'year': '1998', 'rating': '9.4', 'comment': '1967520'}
{'name': '辛德勒的名单', 'director': '史蒂文·斯皮尔伯格 Steven Spielberg', 'year': '1993', 'rating': '9.5', 'comment': '1225957'}
{'name': '忠犬八公的故事', 'director': '莱塞·霍尔斯道姆 Lasse Hallström', 'year': '2009', 'rating': '9.4', 'comment': '1517200'}
{'name': '海上钢琴师', 'director': '朱塞佩·托纳多雷 Giuseppe Tornatore', 'year': '1998', 'rating': '9.3', 'comment': '1846231'}
{'name': '疯狂动物城', 'director': '拜伦·霍华德 Byron Howard / 瑞奇·摩尔 Rich Moore', 'year': '2016', 'rating': '9.2', 'comment': '2211929'}
{'name': '三傻大闹宝莱坞', 'director': '拉库马·希拉尼 Rajkumar Hirani', 'year': '2009', 'rating': '9.2', 'comment': '2039169'}
{'name': '放牛班的春天', 'director': '克里斯托夫·巴拉蒂 Christophe Barratier', 'year': '2004', 'rating': '9.3', 'comment': '1446107'}
{'name': '机器人总动员', 'director': '安德鲁·斯坦顿 Andrew Stanton', 'year': '2008', 'rating': '9.3', 'comment': '1457480'}
{'name': '无间道', 'director': '刘伟强 / 麦兆辉', 'year': '2002', 'rating': '9.3', 'comment': '1530686'}
{'name': '控方证人', 'director': '比利·怀尔德 Billy Wilder', 'year': '1957', 'rating': '9.6', 'comment': '685862'}
{'name': '大话西游之大圣娶亲', 'director': '刘镇伟 Jeffrey Lau', 'year': '1995', 'rating': '9.2', 'comment': '1679469'}
{'name': '熔炉', 'director': '黄东赫 Dong-hyuk Hwang', 'year': '2011', 'rating': '9.3', 'comment': '1019267'}
{'name': '触不可及', 'director': '奥利维·那卡什 Olivier Nakache / 艾力克·托兰达 Eric Toledano', 'year': '2011', 'rating': '9.3', 'comment': '1266065'}
{'name': '寻梦环游记', 'director': '李·昂克里奇 Lee Unkrich / 阿德里安·莫利纳 Adrian Molina', 'year': '2017', 'rating': '9.1', 'comment': '1927710'}
{'name': '教父', 'director': '弗朗西斯·福特·科波拉 Francis Ford Coppola', 'year': '1972', 'rating': '9.3', 'comment': '1081342'}
{'name': '当幸福来敲门', 'director': '加布里尔·穆奇诺 Gabriele Muccino', 'year': '2006', 'rating': '9.1', 'comment': '1658660'}
正在爬取第2页...
# -------------- #
# 剩余爬取内容省略  #
# -------------- #
{'name': '谍影重重', 'director': '道格·里曼 Doug Liman', 'year': '2002', 'rating': '8.6', 'comment': '480526'}

-------------------------------------------------------------
爬取结束...
```

# 6. 实战：使用RE+Requests爬取电影天堂2025必看热片（仅首页表格内的15条）
``` python
# 1. 提取到主页面表中的每个电影对应的详细信息url地址  
#   1. 提取“2025必看热片”的html代码  
#   2. 在<a>标签中提取每个电影对应的详细信息url地址  
# 2. 访问子页面，提取电影名称及下载链接  
import html  
import re  
import requests  
  
base_url = 'https://www.dytt8899.com/' 
print("开始爬取电影信息...")
res = requests.get(base_url, headers = {  
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0'  
})  
res.encoding = 'GBK'  
html_content = res.text  
  
pattern_html = re.compile(r'2025必看热片.*?<ul>\s*(?P<html>.*?)</ul>', re.S)  
pattern_url = re.compile(r"<a href='(.*?)' title")  
  
match = pattern_html.search(html_content).group('html')  
  
if match:  
    urls = pattern_url.findall(match)  
    print(f"爬取到{len(urls)}个电影信息...")  
  
    movies = []  
  
    # for循环第一个参数为索引，第二个参数为列表元素本身  
    for index, url in enumerate(urls):  
        res = requests.get(base_url + url, headers = {  
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0'  
        })  
        res.encoding = 'GBK'  
        html_content = res.text  
  
        print(f'开始爬取第{index + 1}条电影信息...')  
        pattern_title = re.compile(r'<br />◎片　　名　(.*?)<br />', re.S)  
        pattern_download = re.compile(r'<td style="WORD-WRAP: break-word" bgcolor="#fdfddf"><a href="(.*?)">', re.S)  
  
        movie_dict = {  
            'title': pattern_title.findall(html_content),  
            'download': pattern_download.findall(html_content),  
        }  
        movies.append(movie_dict)  
  
    print(f'爬取完毕，共爬取到{len(movies)}条电影信息...')  
    with open('movies.csv', 'w', encoding='utf-8') as f:  
        f.write('电影名称,磁力链接\n')  
        for movie in movies:  
            f.write(html.unescape(movie['title'][0]) + ',' + movie['download'][0] + '\n')
```
## 执行结果节选：
``` python
开始爬取电影信息...
爬取到15个电影信息...
开始爬取第1条电影信息...
开始爬取第2条电影信息...
开始爬取第3条电影信息...
开始爬取第4条电影信息...
开始爬取第5条电影信息...
开始爬取第6条电影信息...
开始爬取第7条电影信息...
开始爬取第8条电影信息...
开始爬取第9条电影信息...
开始爬取第10条电影信息...
开始爬取第11条电影信息...
开始爬取第12条电影信息...
开始爬取第13条电影信息...
开始爬取第14条电影信息...
开始爬取第15条电影信息...
爬取完毕，共爬取到15条电影信息...
```

------

# 7. BS4介绍
`BeautifulSoup` 是一个用于解析 HTML 和 XML 文档的 Python 库，它能够快速、灵活地从网页中提取所需的数据。
## 主要特点
- **强大的解析能力**：支持多种解析器（如 `html.parser`、`lxml` 等）
- **简单易用**：提供直观的 API 接口
- **容错性强**：能处理不规范的 HTML 代码
- **跨平台**：可在任何支持 Python 的环境中运行
## 安装方法
``` python
pip install beautifulsoup4
```
## 基本使用步骤
### 1. 导入库
```python
from bs4 import BeautifulSoup
```
### 2. 解析 HTML 内容
```python
html_content = "<html><body><h1>标题</h1></body></html>"

# 初始化BeautifulSoup对象
soup = BeautifulSoup(html_content, 'html.parser')
```
### 3. 提取数据
``` python
# 所有查找都需要通过BeautifulSoup对象进行

# 通过标签名查找：
title = soup.find('h1')
title = soup.find('h1', attrs={"属性", "值"}) # 还能通过attrs限制查找到的标签必须具有什么值

# 通过 CSS 选择器查找：
title = soup.select('h1')

# 通过属性查找：
link = soup.find('a', href='example.com')

# 获取文本内容
text = title.get_text() # 通过方法获取
text = title.text       # 直接获取


# 获取属性值
href = link['href']
```
## 实际应用示例
```python
import requests
from bs4 import BeautifulSoup

# 获取网页内容
response = requests.get('https://example.com')
soup = BeautifulSoup(response.text, 'html.parser')

# 提取所有链接
links = soup.find_all('a')
for link in links:
    print(link.get('href'))
```
## 补充：视频学习笔记
``` python
# 先安装bs4：pip install bs4  
  
from bs4 import BeautifulSoup  
  
html = """  
<ul>  
    <li><a href="zhangwuxi.com">张无忌</a></li>  
    <li id="abc"><a href="zhouxingchi.com">周星驰</a></li>  
    <li><a href="zhubajie.com">猪八戒</a></li>  
    <li><a href="wuzetian.com">武则天</a></li>  
</ul>  
"""  
  
# 1. 初始化BeautifulSoup对象  
soup = BeautifulSoup(html, "html.parser")  
  
# 2. 获取一个li标签  
li1 = soup.find("li") # 不带过滤器  
li2 = soup.find("li", id="abc") # 带过滤器（直接写）  
li3 = soup.find("li", attrs={"id": "abc"}) # 带过滤器（用attrs属性）  
print(li1)  
print(li2)  
print(li3)  
  
# 3. 获取所有a标签  
a1 = soup.find_all("a") # 不带过滤器  
a2 = soup.find_all("a", href="zhouxingchi.com") # 带过滤器（直接写）  
a3 = soup.find_all("a", attrs={"href": "zhouxingchi.com"}) # 带过滤器（用attrs属性）  
print(a1)  
print(a2)  
print(a3)  
  
# 4. 查找到的结果还能继续查找  
a4 = li1.find("a")  
print(a4)  
  
# 5. 获取标签的文本  
text1 = a4.text         # 直接获取  
text2 = a4.get_text()   # 通过方法获取  
print(text1)  
print(text2)  
  
# 6. 获取标签的属性  
href1 = a4["href"]      # 直接获取  
href2 = a4.get("href")  # 通过方法获取  
print(href1)  
print(href2)
```

# 8. BS4实战：爬取豆瓣TOP250
``` python
# 新发地市场的网站更新为响应式网站了，没法从源代码进行爬取，替换为豆瓣TOP250，原理相同  
import html  
  
# 1. 拿到页面源代码  
# 2. 使用BS4提取页面数据  
# 3. 保存数据  
  
# BS4负责提取页面数据，re负责处理提取出的字符串  
import requests  
import re  
from bs4 import BeautifulSoup  
  
file = open("top250_BS4.csv", "w", encoding="utf-8")  
posi = 0  
url = f"https://movie.douban.com/top250"  
headers = {  
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0"  
}  
  
# 正式开始处理数据  
while posi != 250:  
    if posi == 0:  
        res = requests.get(url, headers=headers)  
    else:  
        res = requests.get(url + f"?start={posi}&filter=", headers=headers)  
  
    print(f"正在爬取第{int(posi / 25) + 1}页...")  
  
    # 初始化BS4对象  
    soup = BeautifulSoup(res.text, "html.parser")  
    movie_divs = soup.find_all("div", attrs={"class": 'item'})  
  
    # 填充movieList  
    movieList = []  
    for movie_div in movie_divs:  
        print(f'正在爬取第{posi + 1}条数据')  
        # 提取电影名称  
        title_spans = movie_div.find_all("span", class_="title")[0].text  
        movie_name = title_spans[0].text if title_spans else "未知"
  
        # 提取导演信息  
        # 豆瓣真有点闹谭，导演那行后端发送的不是完整的导演信息，是将信息按照固定长度截断后的字符串，所以很难匹配完整...
        director = ""  
        director_p = movie_div.find("p")  
        director_text = director_p.get_text()  
        director_match = re.search(r"导演: (.+?)\s*主演:", director_text)  
        if director_match:  
		    director = director_match.group(1).strip()  
		else:  
		    director_match = re.search(r"导演: (.+?)\s*主", director_text)  
		    director = director_match.group(1).strip() if director_match else "未知" 
  
        # 提取年份  
        year_match = re.search(r"(\d{4})", director_text)  
        year = year_match.group(1) if year_match else "未知"  
  
        # 提取评分  
        rating_span = movie_div.find("span", class_="rating_num")  
        rating = rating_span.text if rating_span else "未知"  
  
        # 提取评价人数  
        comment_span = movie_div.find("span", string=re.compile(r'\d+人评价'))  
        comment_count = comment_span.text.replace("人评价", "") if comment_span else "未知"  
  
        # 将电影信息添加到列表  
        movie_dict = {  
            "name": movie_name,  
            "director": director,  
            "year": year,  
            "rating": rating,  
            "comment": comment_count,  
        }  
        movieList.append(movie_dict)  
        print(movie_dict)  
        posi += 1  
  
    for item in movieList:  
        file.write(item["name"] + "," + item["director"] + "," + item["year"] + "," + item["rating"] + "," + item["comment"] + "\n")  
  
print("\n-------------------------------------------------------------\n爬取结束...")  
  
file.close()
```
# 9. BS4实战：爬取图片

- 理论与上面的差不多，下载图片的时候把`.text`改成`.content`获取二进制内容，然后用python的文件处理功能新建图片文件写入（`mode='wb'`）就行，文件名和文件后缀通过url获取。
- 2021年的学习视频，里面的实战网页在2025.10变成了涩图网站（难蚌）
- `https://umei.net`

------

# 10. XPath简介

XPath (XML Path Language) 是一种在 XML 文档中查找信息的语言。它主要用于：
- 在 XML 文档中定位节点
- 从 XML 文档中提取数据
- 在各种编程语言和工具中进行 XML 处理

XPath 使用路径表达式来选取 XML 文档中的节点或者节点集。

## （1）XPath 基本语法

### a. 节点类型
- **元素节点**：XML 文档中的标签元素
- **属性节点**：元素的属性
- **文本节点**：元素内的文本内容
- **命名空间节点**：XML 命名空间声明
### b. 常用路径表达式

| 表达式        | 描述                          |
| ---------- | --------------------------- |
| `nodename` | 选取此节点的所有子节点                 |
| `/`        | 从根节点选取                      |
| `//`       | 从匹配选择的当前节点选择文档中的节点，不考虑它们的位置 |
| `.`        | 选取当前节点                      |
| `..`       | 选取当前节点的父节点                  |
| `@`        | 选取属性                        |

### c. 示例 XML 文档
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<bookstore>
  <book id="1">
    <title lang="en">Harry Potter</title>
    <price>29.99</price>
  </book>
  <book id="2">
    <title lang="zh">Learning XML</title>
    <price>39.95</price>
  </book>
</bookstore>
```
### d. 常用 XPath 表达式示例
1. `/bookstore/book[1]` - 选取第一个 book 元素
2. `//title[@lang='en']` - 选取所有 lang 属性值为 "en" 的 title 元素
3. `/bookstore/book/title` - 选取 bookstore 下所有 book 的 title 子元素
4. `//book[@id='2']/price` - 选取 id 为 "2" 的 book 元素下的 price 子元素
5. `//title/text()` - 选取所有 title 元素的文本内容

## (2) XPath 谓语（Predicates）

谓语用来查找某个特定的节点或者包含某个指定值的节点，总是嵌在方括号中。
示例：
- `/bookstore/book[1]` - 第一个 book 元素
- `/bookstore/book[last()]` - 最后一个 book 元素
- `/bookstore/book[position()<3]` - 前两个 book 元素
- `//title[@lang]` - 拥有 lang 属性的所有 title 元素

## (3) XPath 运算符

XPath 提供多种运算符用于构建复杂的表达式：

| 运算符     | 描述      | 示例                          |                           |
| ------- | ------- | --------------------------- | ------------------------- |
| \|      | 合并两个节点集 | //book \| //title           | 合并所有查询到的`book`和`title`节点集 |
| `+`     | 加法      | `6 + 4`                     | = 10                      |
| `-`     | 减法      | `6 - 4`                     | = 2                       |
| `*`     | 乘法      | `6 * 4`                     | = 24                      |
| `div`   | 除法      | `8 div 4`                   | = 2                       |
| `mod`   | 取模      | `5 mod 2`                   | = 1                       |
| `=`     | 等于      | `price=9.80`                | 当价格等于9.80时返回True          |
| `!=`    | 不等于     | `price!=9.80`               | 当价格不等于9.80时返回True         |
| `<`     | 小于      | `price<9.80`                | 当价格小于9.80时返回True          |
| `<=`    | 小于等于    | `price<=9.80`               | 当价格小于等于9.80时返回True        |
| `>`     | 大于      | `price>9.80`                | 当价格大于9.80时返回True          |
| `>=`    | 大于等于    | `price>=9.80`               | 当价格大于等于9.80时返回True        |
| `or`    | 或       | `price=9.80 or price=9.70`  | 当价格为9.80和9.70时返回True      |
| `and`   | 与       | `price>9.00 and price<9.90` | 当价格大于9.00，小于9.90时返回True   |
| `not()` | 非       | `not(price>9.80)`           | 价格不高于9.80时返回`True`        |

## (4) 实际应用场景

XPath 主要应用于以下场景：
1. **XML 解析**：在各种编程语言中解析 XML 数据
2. **网页抓取**：配合 HTML 解析器提取网页数据
3. **XSLT 转换**：在 XSLT 样式表中定位节点
4. **XML 数据库查询**：查询 XML 格式的数据库
5. **自动化测试**：在 UI 自动化测试中定位页面元素

XPath 是处理结构化文档的强大工具，掌握其基本语法能够有效提高数据提取和处理效率。

--------

# 11. Python中通过lxml模块使用XPath

`lxml` 是一个功能强大且高效的 Python 库，用于处理 XML 和 HTML 文档。它基于 C 语言的 `libxml2` 和 `libxslt` 库构建，提供了比标准库 `xml.etree.ElementTree` 更快的解析速度和更丰富的功能。
## （1）主要特性：
- **高性能**：利用底层 C 实现，解析速度快
- **功能丰富**：支持 XPath、XSLT、XML Schema 验证等
- **易于使用**：提供简洁的 API 接口
- **内存效率高**：支持流式解析大文件
## （2）安装方法：
```bash
pip install lxml
```
## （3）基本使用方法：

### a.  解析 XML 文档：
```python
from lxml import etree

# 解析字符串
xml_string = '<root><child>text</child></root>'
root = etree.fromstring(xml_string)
root = etree.XML(xml_string)
# etree.fromstring：更通用的名称，常用于从字符串解析 XML
# etree.XML：更直接地表示“XML 解析”，但实际是 fromstring 的别名
# 二者完全等价

# 解析文件
tree = etree.parse('example.xml')
root = tree.getroot()
```
### b. 使用 XPath 查询：
```python
# 查找所有 child 元素
children = root.xpath('//child')

# 根据属性查找
elements = root.xpath('//nick[@id="10086"]')

# 获取文本内容
texts = [elem.text for elem in root.xpath('//nick')]

# 使用 XPath 表达式
result = root.xpath('//author/nick[@class="joy"]/text()')
```
### c. 创建和修改 XML：
```python
# 创建新元素
new_element = etree.Element('new_tag')
new_element.text = 'new content'

# 添加到文档
root.append(new_element)

# 修改现有元素
for nick in root.xpath('//nick[@id="10086"]'):
    nick.text = '修改后的名字'
```
### d. 处理 HTML：
```python
from lxml import html

# 解析 HTML
response = requests.get('https://example.com')
tree = html.fromstring(response.content)
# etree.HTML 是 lxml.html 模块中的函数
# html.fromstring 是 lxml.html 模块中 HTML 函数的别名
# 二者完全等价

# 使用 XPath 提取数据
titles = tree.xpath('//title/text()')
links = tree.xpath('//a/@href')
```
## （3）实际应用示例
```python
from lxml import etree

# 示例：解析用户提供的 XML 数据
xml_data = """<book>
    <id>1</id>
    <name>野花遍地香</name>
    <price>1.23</price>
    <nick>臭豆腐</nick>
    <author>
        <nick id="10086">周大强</nick>
        <nick id="10010">周芷若</nick>
        <nick class="joy">周杰伦</nick>
        <nick class="jolin">蔡依林</nick>
        <div>
            <nick>惹了</nick>
        </div>
    </author>
    <partner>
        <nick id="ppc">胖胖陈</nick>
        <nick id="ppbc">胖胖不陈</nick>
    </partner>
</book>"""

# 解析 XML
root = etree.fromstring(xml_data)

# 使用 XPath 查询
authors = root.xpath('//author/nick[@class="joy"]')
print(f"周杰伦: {authors[0].text if authors else '未找到'}")

# 查询所有 nickname
nicks = root.xpath('//nick')
for nick in nicks:
    print(f"{nick.tag}: {nick.text}")
```

### 优势对比

| 特性   | `lxml`            | `xml.etree.ElementTree` |
| ---- | ----------------- | ----------------------- |
| 性能   | 高                 | 中                       |
| 功能   | 丰富（XPath, XSLT 等） | 基础                      |
| 内存使用 | 高效                | 一般                      |
| 易用性  | 简洁                | 简单                      |

`lxml` 适合需要高性能 XML/HTML 处理的场景，特别是在数据抓取、文档解析等任务中表现优异。

## 视频学习笔记：
``` python
from lxml import etree  
  
# 上述导入如果报错，可以像下面这么写  
# from lxml import html  
# etree = html.etree  
  
##############
### 处理xml内容  
##############
xml_content = """  
<book>  
    <id>1</id>    
	<name>野花遍地香</name>  
    <price>1.23</price>    
    <nick>臭豆腐</nick>  
    <author>        
	    <nick id="10086">周大强</nick>  
        <nick id="10010">周芷若</nick>  
        <nick class="joy">周杰伦</nick>  
        <nick class="jolin">蔡依林</nick>  
        <div>            
	        <nick>惹了</nick>  
        </div>    
    </author>    
    <partner>        
	    <nick id="ppc">胖胖陈</nick>  
        <nick id="ppbc">胖胖不陈</nick>  
    </partner>
</book>  
"""  
  
# 练习传入的是xml，只能使用XML的方法解析  
et = etree.XML(xml_content) # 或者etree.fromstring(xml)  
  
# '/'表示根节点  
result = et.xpath("/book")  
print(result) # [<Element book at 0x0000020E5EB0E0D0>] #内存地址瞎写的  
  
# 寻找根节点下层的直接子节点  
result = et.xpath("/book/name")  
print(result) # [<Element name at 0x0000020E5EB0E0F0>] #内存地址瞎写的  
  
# 使用text()提取文本，返回一个列表  
result = et.xpath("/book/name/text()")  
print(result) # ['野花遍地香']  
  
# 也可以直接对提取出的节点进行操作获取文本,注意返回的是列表，所以要取出元素进行处理  
result = et.xpath("/book/name")  
print(result[0].text) # ['野花遍地香']  
  
# 使用'//'表示book节点内的所有nick节点  
result = et.xpath("/book//nick")  
print(result)  
print([i.text for i in result]) # ['臭豆腐', '周大强', '周芷若', '周杰伦', '蔡依林', '惹了', '胖胖陈', '胖胖不陈']  
  
# 使用'*'表示book节点内的所有子节点,也就是寻找book节点下的某个子节点下的nick节点  
result = et.xpath("/book/*/nick")  
print(result)  
print([i.text for i in result]) # ['周大强', '周芷若', '周杰伦', '蔡依林', '胖胖陈', '胖胖不陈']  
  
# 使用'[@class='joy']'表示寻找id为'joy'的nick节点  
result = et.xpath("/book/author/nick[@class='joy']")  
print(result)  
print([i.text for i in result]) #  ['周杰伦']  
  
# 使用'/@xxx'表示取查找到的节点内的属性xxx  
result = et.xpath("/book/author/nick/@id")  
print(result)            # ['10086', '10010']  
result = et.xpath("/book/author/nick/@class")  
print(result)            # ['joy', 'jolin']  
  
###############  
### 处理HTML内容  
###############
html_content = """
<!DOCTYPE html>  
<html lang="en">  
<head>  
    <meta charset="UTF-8" />
	<title>Title</title></head>  
<body>  
    <ul>        
	    <li><a href="http://www.baidu.com">百度</a></li>  
        <li><a href="http://www.google.com">谷歌</a></li>  
        <li><a href="http://www.sogou.com">搜狗</a></li>  
    </ul>    
    <ol>        
	    <li><a href="feiji">飞机</a></li>  
        <li><a href="dapao">大炮</a></li>  
        <li><a href="huoche">火车</a></li>  
    </ol>    
    <div class="job">李嘉诚</div>  
    <div class="common">胡辣汤</div>  
</body>  
"""  
  
et2 = etree.HTML(html_content) # 或者html.fromstring(html)  
# 操作都差不多，在此不再赘述  
# 这里单独提一下，可以通过li[2]这种语法来选择性地获取第2个li节点  
result = et2.xpath("/html/body/ul/li[2]/a/text()")  
print(result)           # ['谷歌']  
  
# 获取最后一个li节点  
result = et2.xpath("/html/body/ol/li[last()]/a/text()")  
print(result) # ['火车']  
  
# 提取a标签的href属性和对应文本  
link_list = []  
li_list = et2.xpath("//li")  
for li in li_list:  
    href = li.xpath("./a/@href") # '.'表示当前节点  
    text = li.xpath("./a/text()")  
    link_list.append({"href": href[0], "text": text[0]}) # 老生常谈的列表问题  
print(link_list)
```
## 补充：
- 如果要提取某个标签的对应文本，不仅可以使用`.xpath("./text()")`，也可以使用 lxml 提供的`.text`属性，比如：`li.xpath("./a").text`
------
# 12. XPath实战案例：爬取猪八戒网的搜索结果（只爬取了第一页）

``` python
# 1. 拿到页面源代码  
# 2. 从页面源代码中提取需要的数据。{价格，业务名称，公司名称}  
  
import requests  
from lxml import etree  
  
# 拿到源代码  
url = "https://www.zbj.com/fw/?k=html"  
headers = {  
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0"  
}  
res = requests.get(url, headers=headers)  
res.encoding = "utf-8"  
print(res.text)  
  
# 提取数据  
et = etree.HTML(res.text)  
divs = et.xpath("//div[contains(@class, 'service-card-wrap')]") # 获取所有包含"serve-item"的div标签  

with open("猪八戒.csv", "w", encoding="utf-8") as f:  
    f.write("价格,业务名称,公司名称\n")  
    for index, div in enumerate(divs):  
        # print("------------------------------------------------------------")  
        # print(div.text)        # .text只会返回元素的直接文本内容，不包括嵌套标签的文本，所以这里返回None。  
        # 如果要返回整个标签内的内容的话，需要使用etree.tostring()方法进行字符串转换  
        # print(etree.tostring(div).decode("utf-8"))  
        # print("------------------------------------------------------------")  
        print(f"正在爬取第{index + 1}条数据...")  
        price = div.xpath(".//div[@class='price']/span/text()")[0].replace("¥", "")  
  
        # .text老问题，获取的文本内容不会包含内部标签，所以需要获取内部的全部标签的文本，再进行拼接  
        name_parts = div.xpath(".//div[@class='name-pic-box']//text()")  
        name = ''.join(name_parts).strip()  
  
        company = div.xpath(".//div[@class='shop-detail']/div[contains(@class, shop-info)]/text()")[0]  
        print({"价格": price, "业务名称": name, "公司名称": company})  
        f.write(f"{price},{name},{company}\n")  
  
print("\n-------------------------------------------------------------\n爬取结束...")
```

## 执行结果节选如下：
``` python
正在爬取第1条数据...
{'价格': '1058', '业务名称': 'html软件公司网站系统html微信公众号微官网定制开发', '公司名称': 'E网--国家高企18年开发经验'}

#################
### 以下输出结果省略
#################

-------------------------------------------------------------
爬取结束...
```

------

# 13. PyQuery初见
## （1）PyQuery 简介

`PyQuery` 是一个类似于 jQuery 的 Python 库，专门用于处理 HTML 和 XML 文档。它提供了简洁的语法来解析和操作文档结构。
## （2）主要特点

- **jQuery 风格**: 使用与 jQuery 相似的 API，便于前端开发者上手
- **链式调用**: 支持方法链式调用，使代码更加简洁
- **CSS 选择器**: 支持丰富的 CSS 选择器语法来定位元素
- **灵活的操作**: 可以轻松地遍历、修改和操作 DOM 元素

## （3）安装方法
```bash
pip install pyquery
```
## （4）基本使用方法

### a. 导入和初始化
```python
from pyquery import PyQuery as pq

# 从字符串创建
doc = pq("<html><body><h1>Hello World</h1></body></html>")

# 从URL加载
doc = pq(url='http://example.com')

# 从文件加载
doc = pq(filename='example.html')
```
### b. 元素选择
```python
# CSS 选择器
elements = doc('div.classname')
element = doc('#idname')

# 标签选择
titles = doc('h1, h2, h3')

# 属性选择
inputs = doc('input[type="text"]')
```
### c. 内容提取
```python
# 获取文本内容
text = doc('h1').text()

# 获取HTML内容
html = doc('div').html()

# 获取属性值
href = doc('a').attr('href')
# 或者
href = doc('a').attr.href
```
### d. 遍历操作
```python
# 遍历所有匹配元素
for element in doc('li').items():
    print(element.text())

# each 方法
def print_text(i, element):
    print(pq(element).text())

doc('li').each(print_text)
```
### e. DOM 操作
```python
# 添加类
doc('div').addClass('new-class')

# 设置属性
doc('img').attr('src', 'new-image.jpg')

# 设置CSS
doc('div').css('color', 'red')

# 添加内容
doc('div').append('<p>New paragraph</p>')
```
## （5）实际应用示例

### a. 网页内容抓取
```python
from pyquery import PyQuery as pq
import requests

# 获取网页内容
response = requests.get('https://example.com')
doc = pq(response.text)

# 提取标题
title = doc('title').text()

# 提取所有链接
links = []
for link in doc('a').items():
    links.append({
        'text': link.text(),
        'href': link.attr('href')
    })
```
### b. 数据处理
```python
# 处理表格数据
table_data = []
for row in doc('table tr').items():
    row_data = []
    for cell in row('td, th').items():
        row_data.append(cell.text())
    table_data.append(row_data)
```
## （6）使用场景】

- 网页内容抓取和解析
- HTML 文档处理和转换
- 数据清洗和提取
- 自动化测试中的页面元素操作

`PyQuery` 特别适合需要处理 HTML 文档的场景，尤其当开发者熟悉 jQuery 语法时，可以快速上手并高效完成文档处理任务。

## （7）PyQuery学习笔记
``` python
from pyquery import PyQuery  
  
html_content = """  
    <li><a href="http://www.baidu.com">百度</a></li>  
"""  
  
# 1. 加载html内容：创建PyQuery实例  
p = PyQuery(html_content)  
# 虽然能够直接从pyquery对象中打印值，但并其不是字符串  
print(p)        # <li><a href="http://www.baidu.com">百度</a></li>  
print(type(p))  # <class 'pyquery.pyquery.PyQuery'>  
  
# 2. 提取内容（直接使用css选择器进行提取）（这个例子里都是标签选择器）  
a = p('a')  
print(a)        # <a href="http://www.baidu.com">百度</a>  
# 提取的内容仍保存在pyquery对象中，可以进一步提取  
print(type(a))  # <class 'pyquery.pyquery.PyQuery'>  
  
# 链式调用  
a = p('li')('a')  
print(a)        # <a href="http://www.baidu.com">百度</a>  
  
# 其可以直接使用完整的css选择器书写方式进行提取  
a = p('li a')  
print(a)        # <a href="http://www.baidu.com">百度</a>  
print("\n")  
  
  
# 另一个示例  
html = """  
    <ul>        
	    <li class="aaa"><a href="http://www.google.com">谷歌</a></li>  
        <li class="aaa"><a href="http://www.baidu.com">百度</a></li> 
        <li class="bbb" id="qq"><a href="http://www.qq.com">腾讯</a></li>
        <li class="bbb"><a href="http://www.yuanlai.com">猿来</a></li>  
    </ul>
"""  
pq = PyQuery(html)  
  
# 1. 类选择器  
a = pq('.aaa')  
print(a)    # 提取出类名为aaa的li标签  
  
# 2. id选择器  
a = pq('#qq')  
print(a)    # <li class="bbb" id="qq"><a href="http://www.qq.com">腾讯</a></li>  
a = pq('#qq a')  
print(a)    # <a href="http://www.qq.com">腾讯</a>  
  
# 3. 获取属性  
a = pq('#qq a')  
print(a.attr('href'))       # http://www.qq.com  
print(a.attr.href)          # 两种书写方法等价  
  
# 4. 多个标签获取属性(.items,.each)  
print()  
a = pq('li a').items()      # 通过.items()方法将每个标签对应的对象放到生成器中，就可以进行迭代了  
for i in a:  
    print(i.attr('href'))  
print()  
# 用.each方法进行迭代也行  
# each()方法接收一个函数，函数第一个参数为索引，第二个参数为dom元素  
# 需要将dom元素通过PyQuery()方法转换为pyquery对象再进行操作  
pq('li a').each(lambda i, elem : print(PyQuery(elem).attr('href'))) # python的lambda函数只能有一行语句，隐式返回内部语句执行结果  
print()  
  
# 5. 获取文本  
a = pq('#qq a')  
print(a.text())     # 腾讯  
print()  
  
# 6. 获取html  
a = pq('#qq')  
print(a.html())     # <a href="http://www.qq.com">腾讯</a> # 获取标签内的完整html内容  
print(a.text())     # 腾讯                                 # 仅获取标签内的文本内容
```
## （8）PyQuery特有功能——操作DOM元素
### 代码示例：
``` python
from pyquery import PyQuery as pq  
  
html = """  
<HTML>  
    <div class="aaa">哒哒哒</div>  
    <div class="bbb">嘟嘟嘟</div>  
</HTML>  
"""  
doc = pq(html)  

# 插入HTML代码片段  
doc(".aaa").after("<div class='ccc'>妈呀</div>")  
print(doc, "\n")  

# 向HTML内层标签中插入HTML片段  
doc(".bbb").append("<span>我爱span</span>")       
print(doc, "\n")  

# 修改标签内的html代码  
doc(".aaa").html("<span>我是span</span>")         
print(doc, "\n")  

# 修改文本内容
doc(".ccc").text("美滋滋")                          
print(doc, "\n")  

# 添加属性
doc(".ccc").attr("cs", "测试")                     
print(doc, "\n")  

# 删除属性
doc(".ccc").remove_attr("cs")                      
print(doc)
```
### 执行结果：
``` html
<HTML>
    <div class="aaa">哒哒哒</div>
    <div class="ccc">妈呀</div><div class="bbb">嘟嘟嘟</div>
</HTML> 

<HTML>
    <div class="aaa">哒哒哒</div>
    <div class="ccc">妈呀</div><div class="bbb">嘟嘟嘟<span>我爱span</span></div>
</HTML> 

<HTML>
    <div class="aaa"><span>我是span</span></div>
    <div class="ccc">妈呀</div><div class="bbb">嘟嘟嘟<span>我爱span</span></div>
</HTML> 

<HTML>
    <div class="aaa"><span>我是span</span></div>
    <div class="ccc">美滋滋</div><div class="bbb">嘟嘟嘟<span>我爱span</span></div>
</HTML> 

<HTML>
    <div class="aaa"><span>我是span</span></div>
    <div class="ccc" cs="测试">美滋滋</div><div class="bbb">嘟嘟嘟<span>我爱span</span></div>
</HTML> 

<HTML>
    <div class="aaa"><span>我是span</span></div>
    <div class="ccc">美滋滋</div><div class="bbb">嘟嘟嘟<span>我爱span</span></div>
</HTML>
```

# 14. PyQuery 实战：爬取Bangumi番剧简介
## 代码如下：
``` python
# 1. 提取页面源代码  
# 2. 提取所需数据 {标题，原作者，Copyright，简介，标签，章节列表}  
  
import requests  
import json  
from pyquery import PyQuery as pq  
  
def main():  
    url = "https://bgm.tv/subject/524707#;"  # 提取内容为Bangumi内恋人不行的介绍  
    headers = {  
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0"  
    }  
  
    print("开始进行爬取...")  
    html_content = get_html_content(url, headers)  
  
    result = get_data(html_content)  
  
    with open("Bangumi.json", "w", encoding="utf-8") as f:  
        json.dump(result, f, ensure_ascii=False, indent=2)  
  
    print("爬取成功!")  
  
  
def get_html_content(url, headers):  
    res = requests.get(url, headers = headers)  
    res.encoding = "utf-8"  
    return res.text  
  
def get_data(html_content):  
    pq_content = pq(html_content)  
    # 标题  
    title = {"日文标题": pq_content('h1.nameSingle a').text(), "中文标题": pq_content('h1.nameSingle a').attr("title")}  
  
    # 表格太多，还没class注释，只能一行一行排除  
    bangumi_info = pq_content('div#bangumiInfo')  
    info_html = bangumi_info('ul#infobox li')  
    original_author =  ""  
    copyright_info = ""  
    official_website = ""  
    for info in info_html.items():  
        content = info.text()  
        # 原作者  
        if "原作" in content:  
            original_author = content.replace("原作: ", "")  
            continue  
        # Copyright 信息  
        if "Copyright" in content:  
            copyright_info = content.replace("Copyright: ", "")  
            continue  
        if "官方网站" in content:  
            official_website = content.replace("官方网站: ", "")  
            continue  
  
    # 存放章节列表  
    chapter_list = []  
    # 先提取整块的内容，再进行拆分  
    chapter_info = pq_content('div.subject_prg')  
  
    # a. 获取章节名  
    chapter_info('ul.prg_list li a').each(  
        lambda idx, e : chapter_list.append({'日文标题' : pq(e).attr('title')})  
    )  
    # b. 获取所有章节简介并合并数据  
    index = 0  
    for elem in chapter_info('div.prg_popup span.tip').items():  
        # 获取直接文本内容  
        direct_text = elem.clone().find('span.cmt').remove().end().find('hr').remove().end().text() # 链式调用会更改上下文，需要使用end()返回原来的上下文  
        parts = direct_text.split("\n")  
  
        # 解析简介内容  
        for part in parts:  
            if ": " in part:  # 确保包含分隔符  
                result = part.strip().split(": ")  
                if len(result) >= 2:  
                    chapter_list[index][result[0]] = result[1]  
  
        index += 1  
  
    # 简介  
    summary = pq_content('div#subject_summary').text()  
  
    # 标签  
    tags = []  
    pq_content('div.subject_tag_section')('a.meta').each(  
        lambda idx, e : tags.append(pq(e)('span').text())  
    )  
  
    return {  
        "标题": title,  
        "原作者": original_author,  
        "Copyright": copyright_info,  
        "简介": summary,  
        "标签": tags,  
        "章节列表": chapter_list,  
        "官网": official_website  
    }  
  
if __name__ == '__main__':  
    main()
```

## 执行结果：
``` json
{  
  "标题": {  
    "日文标题": "わたしが恋人になれるわけないじゃん、ムリムリ！（※ムリじゃなかった!?）",  
    "中文标题": "我们不可能成为恋人！绝对不行。 (※似乎可行？)"  
  },  
  "原作者": "みかみてれん（集英社ダッシュエックス文庫刊）",  
  "Copyright": "©みかみてれん・竹嶋えく／集英社・わたなれ製作委員会",  
  "简介": "「勝ち取るんだ最高の学園生活を！」\n\nぼっちな中学生時代から変わるため、高校デビューを果たした甘織れな子。しかし根が陰キャ気質のせいで、憧れの陽キャ生活に馴染めず窒息寸前に…。\n\n現役モデルの完璧美少女、王塚真唯\n優しくてふわふわ天使の、瀬名紫陽花\nいつもクールな黒髪美人、琴紗月\n賑やかなムードメーカー、小柳香穂\n\n憧れの人たちに近づくために、きょうもがんばる甘織れな子。\nだったはずが──。\n\n「君に恋をしてしまったんだ…」\n「待って！　友達どこいった！？」\n\n友達？　恋人？\n\n揺れ動く気持ちの間で、笑い、悩み、そして進め！　乙女たち。\nノンストップ・青春ガールズラブコメディ、ここに開幕！\n\n\n\n[中文简介]\n「我要赢得最棒的校园生活！」\n为了摆脱孤单的国中生活，甘织玲奈子在高中成功华丽出道。然而因为天生个性阴沉的关系，让她无法适应梦寐以求的阳角生活。\n\n现役模特儿的完美美少女－「王冢真唯」\n温柔得像软绵绵的天使－「濑名紫阳花」\n总是冷静沉着的黑发美女－「琴纱月」\n活泼开朗的开心果－「小柳香穗」\n\n为了靠近憧憬的人们，甘织玲奈子今天也努力不懈。\n──本该如此。\n\n「我已经喜欢上妳了……」\n「等一下！说好的朋友关系呢？」\n\n在摇摆不定的心情之间，时而欢笑、时而烦恼，然后向前迈进吧！少女们。\n节奏明快的青春校园百合喜剧，现在热闹开幕！",  
  "标签": [  
    "喜剧",  
    "百合",  
    "校园",  
    "后宫",  
    "TV",  
    "恋爱",  
    "日本",  
    "小说改"  
  ],  
  "章节列表": [  
    {  
      "日文标题": "ep.1 恋人とか、ぜったいにムリ！",  
      "中文标题": "恋人这种事，绝对不行！",  
      "首播": "2025-07-07",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.2 初めてのキスなんて、ムリ!",  
      "中文标题": "初吻这种事，绝对不行！",  
      "首播": "2025-07-14",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.3 ムリヤリなんて、だめムリ!",  
      "中文标题": "被强迫这种事，绝对不行！",  
      "首播": "2025-07-21",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.4 真唯なんて、やっぱりムリムリ!（※ムリじゃなかった!?）",  
      "中文标题": "真唯这种事，果然绝对不行！（※似乎可行？）",  
      "首播": "2025-07-28",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.5 恋人とか、ぜったいにムリ!その２",  
      "中文标题": "恋人这种事，绝对不行！其之二",  
      "首播": "2025-08-04",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.6 ふたりだけのヒミツが多すぎて、もうムリ!",  
      "中文标题": "两个人之间的秘密太多，已经不行了！",  
      "首播": "2025-08-11",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.7 修羅場とか、どうあがいてもムリ!",  
      "中文标题": "修罗场这种事，怎么挣扎都不行！",  
      "首播": "2025-08-18",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.8 完全勝利するなんて、ムリムリ！",  
      "中文标题": "完全胜利这种事，绝对不行！",  
      "首播": "2025-08-25",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.9 紫陽花さんのお宅訪問とか、ムリ!",  
      "中文标题": "去紫阳花家拜访这种事，不行！",  
      "首播": "2025-09-01",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.10 ふたりっきりの旅行なんて、ムリ!?",  
      "中文标题": "两个人单独旅行这种事，不行！？",  
      "首播": "2025-09-08",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.11 いつまでもこのままでいるのは、ムリ?",  
      "中文标题": "想要永远维持这样的关系，难道不行吗？",  
      "首播": "2025-09-15",  
      "时长": "00:23:40"  
    },  
    {  
      "日文标题": "ep.12 夏休みがもう終わる!　ムリ!",  
      "中文标题": "暑假快要结束了！不行！",  
      "首播": "2025-09-22",  
      "时长": "00:23:40"  
    }  
  ],  
  "官网": "watanare-anime.com/"  
}
```
## 补充：

- 对于某些大批量且不好轻松分辨的，或者结构不够规整的标签，可以使用PyQuery特有的DOM操作方法，为标签添加某些标注属性，或者添加某些html标签，将源代码规整化。

---

# 15. 用户状态存储——Cookie和Session

Session 和 Cookie 是 Web 应用中维持用户状态的两种重要机制：

- **Cookie**：存储在客户端浏览器中的小型数据片段，随每次 HTTP 请求自动发送到服务器，一般存在有效期。
- **Session**：存储在服务器端的用户会话数据，通过唯一的 Session ID 进行标识，每次会话都会新建会话。

## 工作流程

1. 用户首次访问服务器，服务器创建 session 并生成唯一的 `session_id`
2. 服务器通过 `Set-Cookie` 头部将 `session_id` 发送给客户端
3. 客户端浏览器存储该 `session_id` 到 Cookie 中
4. 后续请求中，浏览器自动将包含 `session_id` 的 Cookie 发送回服务器
5. 服务器根据 `session_id` 识别用户并获取对应的 session 数据

## 使用 requests 的代码示例

```python
import requests

# 创建一个 session 对象
session = requests.Session()

# 第一次请求：登录并获取 session
login_url = "https://example.com/login"
login_data = {
    "username": "user123",
    "password": "password123"
}

# 通过 session 对象发送登录请求，session 会自动处理 cookies
response = session.post(login_url, data=login_data)

# 查看服务器返回的 cookies
print("Cookies after login:", session.cookies)

# 后续通过同一个 session 对象发送的请求会自动携带 session cookies
profile_url = "https://example.com/profile"
profile_response = session.get(profile_url)

# 可以查看请求中发送的 cookies
print("Request cookies:", profile_response.request.headers.get('Cookie'))

# 手动添加额外的 cookies（如果需要）
session.cookies.set('custom_cookie', 'custom_value')

# 访问需要认证的页面
dashboard_url = "https://example.com/dashboard"
dashboard_response = session.get(dashboard_url)
```


## 关键要点

- `requests.Session()` 对象会自动管理 cookies，在整个会话期间保持状态
- 服务器设置的 cookies 会自动保存并在后续请求中发送
- 可以通过 `session.cookies` 属性手动操作 cookies
- 使用 session 比手动管理 cookies 更加方便和可靠

------

# 16. 防盗链机制

## 1.  **防盗链原理**
- **基于 `Referer` 头部**: 服务器检查请求来源是否为允许的域名
	- （`Referer` 头部用于标识当前请求的来源页面URL，告诉服务器用户是从哪个页面跳转过来的）
- **资源保护**: 防止其他网站直接链接本站资源（图片、视频、CSS等）
- **带宽节约**: 避免外部网站消耗本站流量

## 2.  **常见防盗链策略**
```python
# 服务器端防盗链检查示例
def check_referer(request):
    referer = request.headers.get('Referer')
    allowed_domains = ['example.com', 'sub.example.com']
    
    if referer:
        from urllib.parse import urlparse
        referer_domain = urlparse(referer).netloc
        if referer_domain in allowed_domains:
            return True
    return False
    
# 其实就是检查请求头内的referer是不是在服务器白名单内
```


## 3.  **爬虫应对防盗链的方法**

### 方法一：伪造 `Referer` 头部
```python
import requests

headers = {
    'Referer': 'https:// legitimate-domain.com/',  # 设置合法的来源
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}
response = requests.get(target_url, headers=headers)
```
### 方法二：使用会话保持一致性
```python
session = requests.Session()
session.headers.update({
    'Referer': 'https://example.com/',
    'User-Agent': 'Mozilla/5.0...'
})

# 先访问主页建立合法来源
session.get('https://example.com/')
# 再获取受保护资源
resource = session.get('https://example.com/protected-resource')
```
### 方法三：模拟完整浏览流程
```python
# 模拟用户真实访问路径
session = requests.Session()

# 1. 访问首页
session.get('https://example.com/')

# 2. 访问列表页（建立正确的 referer 链）
list_page = session.get('https://example.com/list', 
                       headers={'Referer': 'https://example.com/'})

# 3. 获取详情页资源
detail_page = session.get('https://example.com/detail/123',
                         headers={'Referer': 'https://example.com/list'})
```

## 4.  **高级防盗链技术**
- **Token验证**: URL中包含时效性token
- **Cookie验证**: 结合会话状态验证
- **JavaScript生成**: 动态生成验证参数
- **域名绑定**: 严格限制访问域名

## 5.  **最佳实践建议**
- 了解目标网站的防盗链策略
- 尽量模拟真实用户行为
- 遵守网站的 `robots.txt` 规则
- 控制请求频率避免被封禁
- 必要时使用代理IP轮换
## 补充：
- 有些网站会有改写资源url的反爬措施，比如请求得到的是`www.example.com/videos/1919810_114514.mp4`，但文件的真实路径为`www.example.com/videos/video_114514.mp4`，这时候需要根据对应的规律进行url替换

--- 

# 16. 代理（Proxy）介绍

## 1. **代理的基本概念**
- **定义**: 代理服务器是位于客户端和目标服务器之间的中间服务器
- **作用**: 代表客户端向目标服务器发送请求，并将响应返回给客户端
- **工作原理**: 客户端 → 代理服务器 → 目标服务器 → 代理服务器 → 客户端

## 2. **代理的类型**
- **正向代理**: 客户端明确知道通过代理访问目标服务器
- **反向代理**: 客户端不知道代理的存在，以为直接访问目标服务器
- **透明代理**: 不修改请求和响应的内容
- **匿名代理**: 隐藏客户端的真实IP地址

## 3. 爬虫中代理的应用

### a. **主要用途**
- **IP封禁规避**: 避免因频繁请求导致IP被封 **（大量爬取必备）**
- **地域限制绕过**: 访问基于地理位置限制的内容 **（VPN）**
- **负载均衡**: 分散请求压力
- **隐私保护**: 隐藏真实的访问身份

### b. **在 `requests` 中使用代理**
```python
import requests

# 设置代理
proxies = {
    'http': 'http://proxy-server:port',
    'https': 'https://proxy-server:port'
}

# 使用代理发送请求
response = requests.get('https://example.com', proxies=proxies)
```

### 3. **代理池管理**
```python
import requests
import random

class ProxyManager:
    def __init__(self, proxy_list):
        self.proxy_list = proxy_list
        self.current_proxy = None
    
    def get_random_proxy(self):
        """获取随机代理"""
        return random.choice(self.proxy_list)
    
    def make_request(self, url):
        """使用代理发起请求"""
        proxy = self.get_random_proxy()
        try:
            response = requests.get(url, proxies=proxy, timeout=10)
            return response
        except Exception as e:
            # 代理失效时尝试其他代理
            print(f"Proxy {proxy} failed: {e}")
            return None
```

### 4. **代理认证**
```python
# 带认证的代理
proxies = {
    'http': 'http://username:password@proxy-server:port',
    'https': 'https://username:password@proxy-server:port'
}
```

### 5. **最佳实践**
- **代理质量检测**: 定期测试代理的可用性和响应速度
- **失败重试机制**: 代理失效时自动切换到其他代理
- **请求频率控制**: 即使使用代理也要控制请求频率
- **多样化代理源**: 使用不同地区和类型的代理提高成功率

# 17. 综合训练：爬取网易云音乐歌曲评论
## 1. 简介：
- 网易云音乐的音乐评论是通过POST请求进行获取的，源代码里没有。
- 网页源代码进行了混淆，请求参数进行了加密，获取比较困难
## 2. 入手点：
1. 想办法获取POST请求的加密params的原始数据
2. 想办法将我们需要的请求加密回去   
3. 愉快地开始爬取
# 3. 心路历程：
1. 发现源代码里没评论，通过开发者工具查看HTTP请求，发现评论对应的请求为`https://music.163.com/weapi/comment/resource/comments/get?csrf_token=d2f4e9c9285f08a3d050400cc7216eb6`
2. 查看评论，发现有加密参数`params`，通过调用栈从顶向下推导，寻找到如下函数，可以确定如下函数为参数处理与加密的函数：
``` javascript
// 经判断可知，X7Q为传入的API路径，e7d为传入的requests请求对象
t7m.bc7V = function(X7Q, e7d) {
        var i7b = {}
          , e7d = NEJ.X({}, e7d)
          , mf9W = X7Q.indexOf("?");
        if (window.GEnc && /(^|\.com)\/api/.test(X7Q) && !(e7d.headers && e7d.headers[ex8p.BB2x] == ex8p.FW6Q) && !e7d.noEnc) {
            if (mf9W != -1) {
                i7b = j7c.gX8P(X7Q.substring(mf9W + 1));
                X7Q = X7Q.substring(0, mf9W)
            }
            if (e7d.query) {
                i7b = NEJ.X(i7b, j7c.fP8H(e7d.query) ? j7c.gX8P(e7d.query) : e7d.query)
            }
            if (e7d.data) {
                i7b = NEJ.X(i7b, j7c.fP8H(e7d.data) ? j7c.gX8P(e7d.data) : e7d.data)
            }
            i7b["csrf_token"] = t7m.gH8z("__csrf");
            X7Q = X7Q.replace("api", "weapi");
            e7d.method = "post";
            delete e7d.query;
            // 最主要的加密函数
            var bLa0x = window.asrsea(JSON.stringify(i7b), bvq8i(["流泪", "强"]), bvq8i(zK2x.md), bvq8i(["爱心", "女孩", "惊恐", "大笑"]));
            e7d.data = j7c.cr7k({
                params: bLa0x.encText,      // 加密后的参数
                encSecKey: bLa0x.encSecKey  // 加密后的密钥
            })
        }
```
3. 经分析可知，函数会通过判断`query`和`data`进行原始参数的截取与JSON化，赋值给`i7b`，之后通过`i7b["csrf_token"] = t7m.gH8z("__csrf");`这一行为参数内添加`csrf_token`项。在添加完后，会将`X7Q`，也就是传入的API路径中的`api`替换为`weapi`。最后，其会通过`window.asrsea`函数进行参数的加密，并将加密后的参数重新赋值给`e7d.data`。参数结构如下：
``` javascript
// 替换前和替换后的api路径  
origin_api = "https://music.163.com/api/comment/resource/comments/get"  
changed_api = "https://music.163.com/weapi/comment/resource/comments/get"  

// 原始参数：(字典化是使用的query，用完就销毁了，所以函数末尾的e7d没有query项)  
e7d = {  
    "cookie": true,    
    "type": "json",    
    "method": "GET",    
    "ClientLogDomainSwitch": true,    
    "data": "rid=R_SO_4_2097485069&threadId=R_SO_4_2097485069&pageNo=1&pageSize=20&cursor=-1&offset=0&orderType=1",    
    "query": "rid=R_SO_4_2097485069&threadId=R_SO_4_2097485069&pageNo=1&pageSize=20&cursor=-1&offset=0&orderType=1"}  
    
// 传入加密函数的参数：  
i7b = {  
    "rid": "R_SO_4_2097485069",   
    "threadId": "R_SO_4_2097485069",
    "pageNo": "1",    
    "pageSize": "20",    
    "cursor": "-1",    
    "offset": "0",    
    "orderType": "1",    
    "csrf_token": "d2f4e9c9285f08a3d050400cc7216eb6"
    }  
    
// 替换后的e7d  
e7d = {  
    "cookie": true,   
    "type": "json",   
    "method": "post",   
    "ClientLogDomainSwitch": true,  
    "data": "params=CfkGDU7tGjZn1XG4a2X5xmUoy4WOOSO3DJFDROnWkzhHXswP%2BxEjOrM6zs2%2FErLLaRkCN1VLmBIvGvnd0YOyGcVZGpskQ2HdrHQ7qFjBW1F%2FAcNk1HXj%2FyXCv4t1rZ48qtTPn5rWMnEGAenCeUJRjKz5rc4i7bNV69dmImbGH%2FQQ%2BBhos1InbqJqGoXK1tQL1UZ0eDM1u9o46gnFNazj19Wm6adF%2BA4SswU64E%2FN5DPe0%2BW9V9Jk8ARqBQVTaGo7rhG8bMfFD9PydlbQFogmVeKERx81Nde5nugwGhDlBYnT8%2BTtqromHkPcPifvnnI1lUZnh06o3SunqQn74dTxZcBj7X5kCSNcAU4muVpOi3E%3D&encSecKey=a4f9f9fa19bb9aa626b8af3573fc994687c991f6a8478574b290e63374cada87810558c2b35289718a28129d3cf5b5cda10e166153dd2a7bf6e2a7f216906b1deafaf93f8201f4463dc3ea2028a6a01a1dc67013e45d158d3d9fce6923bf15b8dfd114d592ec0fa8065c9a119d34f24f7bc8147880b08cfa06d718849044fccd"
    } 
```

4. 通过搜索`window.asrsea`，可以得到如下函数：
``` javascript
// 中间省略了一点无关函数
function a(a) {
    var d, e, b = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", c = "";
    for (d = 0; a > d; d += 1)         // 循环 d 次
        e = Math.random() * b.length,  // e = [0,1)的浮点数 * b的长度（62）
        e = Math.floor(e),             // e = e向下取整
        c += b.charAt(e);              // c += e位置的字符
    return c
}
function b(a, b) {
    var c = CryptoJS.enc.Utf8.parse(b)     // 密钥，将b字符串翻译为CryptoJS可以处理的格式
      , d = CryptoJS.enc.Utf8.parse("0102030405060708") // 加密的偏移量
      , e = CryptoJS.enc.Utf8.parse(a)                  // 同上，处理原始参数字符串
      , f = CryptoJS.AES.encrypt(e, c, {                // 正式加密，使用AES加密，模式使用CBC模式，加密偏移量为d，返回加密结果
        iv: d,
        mode: CryptoJS.mode.CBC
    });
    return f.toString()
}
function c(a, b, c) {
    var d, e;
    return setMaxDigits(131),
    d = new RSAKeyPair(b,"",c),
    e = encryptedString(d, a)
}
function d(d, e, f, g) {
    var h = {}
        , i = a(16);
    return h.encText = b(d, g),
    h.encText = b(h.encText, i),  // params
    h.encSecKey = c(i, e, f),     // encSecKey
    h // 这里是JavaScript的逗号表达式语法，整个函数会从左到右执行，并返回最后一个结果h
}
window.asrsea = d,
```
5. 我们主要看`d`函数，同时联系`window.asrsea`的具体调用：
``` javascript
function d(d, e, f, g) {
    var h = {}
        , i = a(16);
    return h.encText = b(d, g),
    h.encText = b(h.encText, i),
    h.encSecKey = c(i, e, f),
    h
}

window.asrsea(JSON.stringify(i7b), bvq8i(["流泪", "强"]), bvq8i(zK2x.md), bvq8i(["爱心", "女孩", "惊恐", "大笑"]));

// 扒了一下，zK2x.md是一个字符串列表，内容是这样的，感觉像是表情包介绍：
zK2x.md = ["色", "流感", "这边", "弱", "嘴唇", "亲", "开心", "呲牙", "憨笑", "猫", "皱眉", "幽灵", "蛋糕", "发怒", "大哭", "兔子", "星星", "钟情", "牵手", "公鸡", "爱意", "禁止", "狗", "亲亲", "叉", "礼物", "晕", "呆", "生病", "钻石", "拜", "怒", "示爱", "汗", "小鸡", "痛苦", "撇嘴", "惶恐", "口罩", "吐舌", "心碎", "生气", "可爱", "鬼脸", "跳舞", "男孩", "奸笑", "猪", "圈", "便便", "外星", "圣诞"];
```
6. 从上面我们可以看出，`d()`函数的参数`d`为待加密参数的json字符串，参数`e`、`f`、`g`使用固定字符串调用了`bvq8i()`这个函数，这里由于传入的都是写死的固定字符串，可以不用管它的加密过程，直接获取结果，分别对应字符串`'010001'`，`'00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7'`，`'0CoJUm6Qyw8W8jud'`
7. 继续分析函数体，`h`为一个空对象，`i`是一个随机的16位字符串。我们可以看出，`e`、`f`、`g`均为定值，`i`是通过函数`a(16)`生成的一个16位字符串，并没有经过后端验证，那么我们在爬取的时候就可以直接将`i`写作一个定值。同时，`encSecKey`这项是通过`c(i, e, f)`函数进行生成的，`c(i, e, f)`函数只有`i`是变量，通过固定`i`，`encSecKey`也能固定下来，通过固定的`i`就可以直接获取固定的`encSecKey`，方便爬虫使用。
8. 通过执行一遍函数，我们可以抓取到`i`为字符串`"pw8qXXCkXlIMR49Q"`，通过这个i所生成的`encSecKey`为`"022e1c20d918453b2598ca688e292d4abb5fa6374c6d99ee22d4b912892e68e18218af9fd954ece5a6b0f9bc4ca957ddc488f202cba4d92f4a1d0661f2cb0629745a2e20729fc7e333ac254327f75c06fb3f9b327e576564e5bb56d0395008cc3014ec062dfc263026b9e4d3e3bc859c02555cfd3ac83ba189d2c7a788f2a1bf"`
9. 继续分析另一个返回值`encText`：`encText`经过了两次加密：
	- 第一次是将原始参数与参数`g`丢给了函数`b(d, g)`，返回第一次加密的内容
	- 第二次是将第一次加密后的内容和参数`i`丢给`b(h.encText, i)`进行第二次加密，得到最终内容
	- 分析后可知，在第一次加密中，`d`是原始参数，`g`是密钥；第二次加密中，`h.encTect`是原始参数，`i`是密钥
	- 由于之前确定了`i`，也就是说这里除原始参数的所有值都是定值，这下值的变化只取决于原始参数。
10. OK，所有准备工作完成，是时候编写代码力！
``` python
# 1. 想办法获取POST请求的加密params的原始数据  
# 2. 想办法将我们需要的请求加密回去  
# 3. 愉快地开始爬取  
# 具体思路详见markdown  
import json  
import requests  
from Crypto.Cipher import AES  
from base64 import b64encode  
  
wyy_data = {  
    "rid": "R_SO_4_2097485069",  
    "threadId": "R_SO_4_2097485069",  
    "pageNo": "1",  
    "pageSize": "20",  
    "cursor": "-1",  
    "offset": "0",  
    "orderType": "1",  
    # "csrf_token": "d2f4e9c9285f08a3d050400cc7216eb6"  
    # csrf_token有没有都行  
}  
# d2f4e9c9285f08a3d050400cc7216eb6  # 这是url中的csrf_token的值
url = 'https://music.163.com/weapi/comment/resource/comments/get?csrf_token='  
e = '010001'  
f = "00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7"  
g = '0CoJUm6Qyw8W8jud'  
i = 'pw8qXXCkXlIMR49Q'  
encSecKey = "022e1c20d918453b2598ca688e292d4abb5fa6374c6d99ee22d4b912892e68e18218af9fd954ece5a6b0f9bc4ca957ddc488f202cba4d92f4a1d0661f2cb0629745a2e20729fc7e333ac254327f75c06fb3f9b327e576564e5bb56d0395008cc3014ec062dfc263026b9e4d3e3bc859c02555cfd3ac83ba189d2c7a788f2a1bf"  
  
# 获取params，data为字符串  
def get_params(data):  
    first = enc_params(data, g)  
    second = enc_params(first, i)  
    return second  
  
# 为data补长，使其达到16的倍数（AES加密必须要这么干）  
def to_16(data):  
    pad = 16 - len(data) % 16  
    data += pad * chr(pad)  
    return data  
  
# 加密过程  
def enc_params(data, key):  
    # AES.new() 方法要求 key 和 IV 参数必须是 bytes 类型， 所以需要使用.encode("utf-8")方法将utf-8字符串转换为bytes类型。  
    iv = '0102030405060708'  
    # 补长data  
    data = to_16(data)  
    # 创建AES对象  
    enc = AES.new(key = key.encode("utf-8"), IV=iv.encode("utf-8"), mode=AES.MODE_CBC)  
    # 返回加密后的base64值  
    result = enc.encrypt(data.encode("utf-8"))  
    # 将base64值转换为utf-8字符串并返回  
    return b64encode(result).decode("utf-8")  
  
# 发送请求  
res = requests.post(url, data={  
    "params": get_params(json.dumps(wyy_data)),  
    "encSecKey": encSecKey  
})  
  
print(res.text)
```

------

# 18. 多线程
``` python
from threading import Thread  
  
def func():  
    for i in range(100):  
        print("直接创建Thread对象-子线程：" + str(i))  
  
class MyThread(Thread):  
    def run(self):  
        for i in range(100):  
            print("继承Thread类重写run方法-子线程：" + str(i))  
  
if __name__ == '__main__':  
    t = Thread(target=func) # 创建线程对象  
    t.start()               # 只是设置线程状态为运行状态，线程实际开始运行的时刻由CPU进行决定  
  
    t2 = MyThread()  
    t2.start()              # 注意别写成.run()了，不然就是方法调用，成单线程了
      
    for i in range(100):  
        print("主线程：" + str(i))  
  
# python 多线程中，print的输出混乱，主要是因为这样：  
# python的print对字符串和end并不是同时操作的，而是先输出字符串value值，再输出end  
# print的操作并不总是具有原子性，可能会出现value值输出后，另一个print开始输出其value值，挤占了当前print的end参数的输出  
# 也即是说，print并不是线程安全的！

# 补充：多线程可以传参，但要求在新建线程对象的时候，使用args传入函数的参数，就像这样：
t = Thread(target=func, args=("哈哈哈",)) # args传入的参数由于是可变长度参数（关键字参数和位置参数都支持），其必须是一个元组，因此传入单个参数时后面必须加逗号，符合Python的单元素元组创建语法。
```

# 19. 多进程
``` python
# 逻辑与多线程一模一样
from multiprocessing import Process  
  
def func():  
    for i in range(100):  
        print("直接创建Process对象-子进程：" + str(i))  
  
class MyProcess(Process):  
    def run(self):  
        for i in range(100):  
            print("继承Process类-子进程：" + str(i))  
  
if __name__ == '__main__':  
    p = Process(target=func)  
    p.start()  
      
    p2 = MyProcess()  
    p2.start()  
      
    for i in range(100):  
        print("直接创建Process对象-父进程：" + str(i))
```

# 20. 线程池与进程池
``` python
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor  
  
def fn(name):  
    for i in range(10):  
        print(name + ":" + str(i))  
  
if __name__ == '__main__':  
    # 支持可变长度参数，可以不指定参数名  
    # 这里通过 with 关键字来实现线程的自动关闭
    with ThreadPoolExecutor(max_workers=5) as t:  
        thread_list = []  
        for i in range(10):  
            # 创建10个线程对象，并加入线程池，其在创建后会自动开始执行任务  
            thread = t.submit(fn, "线程" + str(i))  
            thread_list.append(thread)  
  
    print("线程任务执行完毕") # 线程池存在线程守护，只有线程池中的任务全部执行完毕，才会继续执行主线程  
  
    with ProcessPoolExecutor(max_workers=5) as p:  
        process_list = []  
        for i in range(10):  
            process = p.submit(fn, "进程" + str(i))  
            process_list.append(process)  
  
    print("进程任务执行完毕") # 进程池也一样
```

# 21. 线程池和进程池实战

- 东西都差不多，把单个页面的提取逻辑扔给线程池进行执行就行，外面放个参数进行翻页控制，暂时不写了，找不到合适的网页 
``` python
# 爬的新发地菜价
# 逻辑放这了，添个线程池就行，就不爬了，怕给人网站爬崩（）  
import json  
import requests  
  
url = "http://www.xinfadi.com.cn/getPriceData.html"  
current = 2  
# 第一页limit和current参数都为空
res = requests.post(url, params={  
    "limit": 20,  
    "current": {current},  
    "pubDateStartTime": "2023/01/01",  
    "pubDateEndTime": "",  
    "prodPcatid": "",  
    "prodCatid": "",  
    "prodName": "",  
})  
res.encoding = "utf-8"  
with open("xinfadi.json", "w", encoding="utf-8") as f:  
    json.dump(res.json(), f, ensure_ascii=False)
```

------

# 22. 协程
## 1. 介绍：
- [协程的概念，为什么要用协程，以及协程的使用-CSDN博客](https://blog.csdn.net/weixin_44575037/article/details/105513014)
- **个人理解**：I/O操作是独立于程序执行的，在程序执行I/O操作时，我们可以使用协程的思想让程序执行另外的任务，避免了I/O阻塞导致的性能浪费，从而提高了程序的运行效率。
## 2. 代码
``` python
import asyncio  
import time  
  
async def func1():  
    print("hahaha")  
    await asyncio.sleep(3) # 异步sleep，能够让其在sleep的时候切换到另一个任务  
    print("hehehe")  
    return "task1"  
  
async def func2():  
    print("123123123")  
    await asyncio.sleep(2)  
    print("345345345")  
    return "task2"  
  
async def func3():  
    print("dfgdfg")  
    await asyncio.sleep(4)  
    print("vbnvbn")  
    return "task3"  
  
async def main():  
    # 异步任务的创建必须要在异步函数内  
    # gather()方法可以创建多个任务，并等待所有任务完成，按照任务顺序返回所有任务的返回值列表  
    result_list = await asyncio.gather(func1(), func2(), func3())  
    return result_list  
    # 或者这么写:  
    # tasks = [asyncio.create_task(func1()), asyncio.create_task(func2()), asyncio.create_task(func3())]    
    # await asyncio.wait(tasks)    
    # return [task.result() for task in tasks]  

if __name__ == '__main__':  
    # g = func1()      # 函数是异步函数，此时g得到的是一个协程对象  
    # asyncio.run(g)  # 通过asyncio.run()方法启动协程  
    start_time = time.time()  
    result = asyncio.run(main())  
    end_time = time.time()  
    print("耗时：" + str(end_time - start_time))  
    print(result)
```
## 3. 代码结果：
``` python
多个任务协程操作：
hahaha
123123123
dfgdfg
345345345
hehehe
vbnvbn
耗时：4.014375448226929         # 在这个演示程序中，效率取决于最长的sleep
['task1', 'task2', 'task3']
```

------

# 23. aiohttp模块

- `aiohttp` 是一个基于 asyncio 的异步 HTTP 客户端/服务器库，适用于 Python 3.5+。它支持客户端和服务器端的异步编程，能够处理大量并发请求。

## 主要功能
- 异步 HTTP 客户端和服务器
- WebSocket 支持
- 中间件支持
- 基于 asyncio 的异步 I/O

## 安装
```bash
pip install aiohttp
```
## 基本用法
### 1. 发起 HTTP 请求
```python
import aiohttp
import asyncio

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        html = await fetch(session, 'http://httpbin.org/get')
        print(html)

# 运行异步函数
asyncio.run(main())
```
### 2. 发送 POST 请求
```python
import aiohttp
import asyncio

async def post_example():
    async with aiohttp.ClientSession() as session:
        async with session.post('http://httpbin.org/post',
                               data={'key': 'value'}) as response:
            print(await response.text())

asyncio.run(post_example())
```
### 3. 传递参数
```python
import aiohttp
import asyncio

async def param_example():
    params = {'key1': 'value1', 'key2': 'value2'}
    async with aiohttp.ClientSession() as session:
        async with session.get('http://httpbin.org/get',
                              params=params) as response:
            print(await response.text())

asyncio.run(param_example())
```
### 4. 设置请求头
```python
import aiohttp
import asyncio

async def headers_example():
    headers = {'Authorization': 'Bearer token'}
    async with aiohttp.ClientSession() as session:
        async with session.get('http://httpbin.org/headers',
                              headers=headers) as response:
            print(await response.json())

asyncio.run(headers_example())
```
### 5. 处理 JSON 响应
```python
import aiohttp
import asyncio

async def json_example():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://httpbin.org/json') as response:
            data = await response.json()
            print(data)

asyncio.run(json_example())
```
### 6. 文件上传
```python
import aiohttp
import asyncio

async def file_upload():
    async with aiohttp.ClientSession() as session:
        data = aiohttp.FormData()
        data.add_field('file',
                      open('filename.txt', 'rb'),
                      filename='filename.txt')
        async with session.post('http://httpbin.org/post',
                               data=data) as response:
            print(await response.text())

asyncio.run(file_upload())
```
### 7. 设置超时
```python
import aiohttp
import asyncio

async def timeout_example():
    timeout = aiohttp.ClientTimeout(total=60)
    async with aiohttp.ClientSession(timeout=timeout) as session:
        async with session.get('http://httpbin.org/delay/10') as response:
            print(await response.text())

asyncio.run(timeout_example())
```
## 创建简单的 HTTP 服务器
```python
from aiohttp import web

async def hello(request):
    return web.Response(text="Hello, world")

app = web.Application()
app.router.add_get('/', hello)

if __name__ == '__main__':
    web.run_app(app, port=8080)
```
## 主要特点
1. **异步性能**：利用 asyncio 实现高并发处理
2. **连接池**：自动管理 HTTP 连接复用
3. **Cookie 支持**：自动处理 Cookie
4. **SSL/TLS 支持**：支持 HTTPS 请求
5. **流式处理**：支持大文件流式传输
6. **WebSocket 支持**：支持 WebSocket 通信
## 注意事项
- 必须在异步环境中使用
- 使用 `ClientSession` 时应确保正确关闭
- 推荐使用 `async with` 语句管理资源
- 对于大量并发请求，可以调整连接池大小
## 视频代码示例：
``` python
import aiohttp  
import asyncio  
  
urls = [  
    '1','2','3'  # 懒得找网站了  
]  
  
async def aiodownload(url):  
    async with aiohttp.ClientSession() as session:  
        async with session.get(url) as response:  
            print(f'正在下载：{url}')  
            html_content = await response.text()  
            # 二进制: response.content.read()  
            # json: response.json()            
            print(f'下载完成：{url}')  
            return html_content  
  
  
async def main():  
    tasks = []  
    for url in urls:  
        tasks.append(asyncio.create_task(aiodownload(url)))  
    await asyncio.wait(tasks)  
    return [task.result() for task in tasks]  
  
  
if __name__ == '__main__':  
    result = asyncio.run(main())  
    print(result)
```

------

# 25. 异步爬虫实战——爬取小说
``` python
import os.path  
import random  
  
import aiohttp  
import asyncio  
import requests  
import re  
import cn2an  # 中文数字转阿拉伯数字的模块
from bs4 import BeautifulSoup  
  
# 限制并发数  
semaphore = asyncio.Semaphore(10)  # 限制最多10个并发  
  
# 获取所有章节  
base_url = "http://www.txt80.net"  
chapters_url = "http://www.txt80.net/txt/97884.html"  
chapters_list = []  
chapters_content = {}  
title_re = re.compile(r"(.*?)（")  
count_re = re.compile(r"（(?P<now>\d) / (?P<total>\d)")  
current_chapter_re = re.compile(r"第(.*?)章")  
  
def get_chapters(url):  
    print("开始获取章节列表...")  
    html = requests.get(url)  
    html.encoding = "utf-8"  
    soup = BeautifulSoup(html.text, "html.parser")  
    chapters = soup.find("ul", id="ul_all_chapters").find_all("a")  
    for chapter in chapters:  
        chapter_location = base_url + chapter.get("href")  
        # 章节是分段存储的，所以需要将章节链接进行分段，分段处理放在具体爬取函数中处理  
        chapters_list.append(chapter_location)  
    print("章节列表获取完成，开始爬取内容...\n")  
    # 删除已有文件，为爬取做准备  
    if os.path.exists("少侠，请留步.txt"):  
        os.remove("少侠，请留步.txt")  
  
async def get_chapter_content(url):  
    async with semaphore:  
        try:  
            current_url = url  
            while True:  
                # 每次循环都需要重新发起网络请求  
                async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=30)) as session:  
                    async with session.get(current_url) as response:  
                        print(f"正在爬取：{current_url}")  
                        if response.status != 200:  
                            print(f"请求失败，状态码：{response.status}，URL：{current_url}")  
                            return  
  
                        html = await response.text()  
                        soup = BeautifulSoup(html, "html.parser")  
                        original_title = soup.find("div", class_="text_title").text  
                        # 获取标题  
                        title = re.search(title_re, original_title).group(1)  
                        current_chapter = re.search(current_chapter_re, original_title).group(1)  
                        current_chapter = cn2an.cn2an(current_chapter, mode="normal")  
                        now = int(re.search(count_re, original_title).group("now"))  
                        total = int(re.search(count_re, original_title).group("total"))  
  
                        print(f"title:{title},chapter={current_chapter},now={now},total={total}")  
  
                        # 获取内容  
                        content_elements = soup.find("article", class_="content").find_all("p")  
                        content = "\n".join(["    " + p.text for p in content_elements])  
                        # 将格式化的章节内容插入列表  
                        if now == 1:  
                            chapters_content[current_chapter] = {  
                                "标题": title,  
                                "内容": content,  
                            }  
                        else:  
                            # 追加内容到已存在的章节  
                            if current_chapter in chapters_content:  
                                chapters_content[current_chapter]["内容"] += "\n" + content  
                            else:  
                                chapters_content[current_chapter] = {  
                                    "标题": title,  
                                    "内容": content,  
                                }  
  
                        if now < total and now < 10:  # 添加安全限制  
                            print(f"正在爬取下一分页... 当前页: {now}, 总页数: {total}")  
                            next_url = url.split(".html")[0] + f"_{now + 1}.html"  
                            print(f"下一页URL: {next_url}")  
                            current_url = next_url  
                            continue  
                        else:  
                            if now >= total:  
                                print(f"{title} 爬取完成！")  
                                sleep_time = random.uniform(1, 5)  
                                print(f"休眠{sleep_time}秒")  
                                await asyncio.sleep(sleep_time)  
                            break  
        except Exception as e:  
            print(f"处理URL {url} 时出错：{e}")  
  
  
async def main():  
    tasks = []  
    for chapter in chapters_list:  
        task = asyncio.create_task(get_chapter_content(chapter))  
        tasks.append(task)  
    await asyncio.wait(tasks)  
  
def output_file(file_name):  
    with open(file_name, "w", encoding="utf-8") as f:  
        for chapter_num in sorted(chapters_content.keys()):  
            f.write(f"\n    {chapters_content[chapter_num]['标题']}\n\n")  
            f.write(chapters_content[chapter_num]["内容"])  
            f.write(f"\n{'-' * 30}\n")  
  
if __name__ == '__main__':  
    get_chapters(chapters_url)  
    asyncio.run(main())  
    output_file("少侠，请留步.txt")
```

## 执行结果：
``` python
开始获取章节列表...
章节列表获取完成，开始爬取内容...

正在爬取：http://www.txt80.net/read/97884/58136270.html
title:第八章 少女顾堇,chapter=8,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136270_2.html
正在爬取：http://www.txt80.net/read/97884/58136264.html
title:第二章 大丫鬟轩然,chapter=2,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136264_2.html
正在爬取：http://www.txt80.net/read/97884/58136266.html
title:第四章 江湖偌大,chapter=4,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136266_2.html
正在爬取：http://www.txt80.net/read/97884/58136265.html
title:第三章 赏银,chapter=3,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136265_2.html
正在爬取：http://www.txt80.net/read/97884/58136269.html
title:第七章 我家夫人在哪,chapter=7,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136269_2.html
正在爬取：http://www.txt80.net/read/97884/58136267.html
title:第五章 武林厚重,chapter=5,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136267_2.html
正在爬取：http://www.txt80.net/read/97884/58136268.html
title:第六章 苏银瓶,chapter=6,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136268_2.html
正在爬取：http://www.txt80.net/read/97884/58136272.html
title:第十章 “诱拐少女”,chapter=10,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136272_2.html
正在爬取：http://www.txt80.net/read/97884/58136263.html
title:第一章 少侠秦琅,chapter=1,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136263_2.html
正在爬取：http://www.txt80.net/read/97884/58136271.html
title:第九章 青璃郡主,chapter=9,now=1,total=2
正在爬取下一分页... 当前页: 1, 总页数: 2
下一页URL: http://www.txt80.net/read/97884/58136271_2.html
正在爬取：http://www.txt80.net/read/97884/58136270_2.html
title:第八章 少女顾堇,chapter=8,now=2,total=2
第八章 少女顾堇 爬取完成！
休眠1.535839153512622秒

# 太多了，省略了
# 小说txt文件就不挂上来了~
```

------

# 26. 视频分段技术——M3U

## 1. M3U (MPEG URL)
- **定义**: M3U 是一种播放列表文件格式，用于指定媒体文件的位置
- **用途**: 主要用于音频和视频流媒体播放列表
- **特点**:
  - 纯文本格式
  - 支持相对路径和绝对路径
  - 可以包含多个媒体文件引用
  - 常用于 IPTV 和在线广播

## 2. M3U8
- **定义**: M3U8 是 M3U 的 Unicode 版本，使用 UTF-8 编码
- **与 M3U 的区别**:
  - 支持国际化字符集
  - 兼容性更好，支持各种语言的文件名
  - 是 HTTP Live Streaming (HLS) 的标准格式
- **应用场景**:
  - Apple HLS 流媒体传输
  - 视频点播和直播服务
  - 自适应码率流媒体
### 格式结构
```m3u
#EXTM3U
#EXTINF:123, Sample Title
/path/to/media/file.mp3
#EXTINF:234, Another Title
http://example.com/stream.mp4
```
### 主要应用
- **在线视频平台**: YouTube、Netflix 等使用类似技术
- **IPTV 服务**: 电视节目在线播放
- **移动流媒体**: 适应不同网络条件的自适应流
- **广播电台**: 在线音频流播放列表

这两种格式都是流媒体领域的重要标准，M3U8 作为 M3U 的升级版本，在现代网络流媒体中应用更广泛。
## 3. M3U8文件格式示例
``` m3u8
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:10        # 视频切片最大时长（min）
#EXT-X-MEDIA-SEQUENCE:0

#EXT-X-KEY:METHOD=AES-128,URI="https://example.com/key.key"   # 视频加密方式及密钥地址，加密视频需要解密后才能播放

#EXTINF:10.0,      # #EXTINF:duration,title 当前文件持续时长 当前文件的显示标题
segment0.ts        # 视频分段文件的具体地址（URL链接，为相对地址，需要拼接基地址）
#EXTINF:10.0,
segment1.ts
#EXTINF:10.0,
segment2.ts
#EXTINF:10.0,
segment3.ts

#EXT-X-ENDLIST

```

# 27：视频爬取实战：爬取某网站番剧
## 1. 代码
``` python
# 1. 获取m3u8文件  
# 2. 获取ts文件  
# 3. 合并ts文件  
import os.path  
import random  
import time  
from concurrent.futures import ThreadPoolExecutor  
import requests  
import re  
  
m3u8_url = "https://v.cdnlz22.com/20250923/23113_2c87b119/2000k/hls/mixed.m3u8"  
base_url = "https://v.cdnlz22.com/20250923/23113_2c87b119/2000k/hls/"  
re_str = re.compile(r"^(?!#).*?\.ts$", re.MULTILINE)  
# cloudflare反爬太严了，为了保险添加了这么多header项...但好像只添加ua和connection项就行
headers = {  
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0",  
    "Referer": "https://v.cdnlz22.com/",  
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",  
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",  
    "Accept-Encoding": "gzip, deflate, br",  
    "Connection": "keep-alive",  
    "Upgrade-Insecure-Requests": "1"  
}  
# 多线程爬取
thread_limit = 8  
thread_pool = []  
urls = []  
  
def download_m3u8():  
    global urls  
    print("开始处理m3u8文件...")  
    res = requests.get(m3u8_url, headers)  
    res.encoding = "utf-8"  
  
    m3u8_content = res.text  
    print(m3u8_content)  
    urls = re.findall(re_str, m3u8_content)  
    print("m3u8文件处理完成，开始下载ts文件...")  
  
  
def download_ts(ts_url):  
    """下载单个ts文件"""  
    print(f"开始下载: {ts_url}")  
    full_url = base_url + ts_url  
    res = requests.get(full_url, headers=headers)  
    # 确保目录存在  
    os.makedirs("./videos", exist_ok=True)  
  
    with open(f"./videos/{ts_url}", "wb") as f:  
        f.write(res.content)  
    # sleep_time = random.uniform(2, 5)  
    sleep_time = random.uniform(0.5, 1)  
  
    print(f"下载完成: {ts_url}, 休眠{sleep_time}秒")  
  
    time.sleep(sleep_time)  
  
# def download_with_threadpool():  
#     with ThreadPoolExecutor(max_workers=thread_limit) as executor:  
#         # 提交所有任务  
#         futures = [executor.submit(download_ts, ts_url) for ts_url in urls]  
#         # 等待所有任务完成  
#         for future in futures:  
#             future.result()  
  
if __name__ == '__main__':  
    download_m3u8()  
    # download_with_threadpool()  
    # 很烦，爬快了封ip，只能单线程爬...
    for ts_url in urls:  
        download_ts(ts_url)  
    print("下载完成！")
```
## 2. ffmpeg合并ts文件为mp4文件：
``` python
import os  
import subprocess  
  
def merge_ts_files(ts_file_list, output_file="output.mp4"):  
    print("开始合并ts文件...")  
    os.makedirs("./videos", exist_ok=True)  
  
    # 创建文件列表  
    with open('filelist.txt', 'w') as f:  
        for ts_file in ts_file_list:  
            if ts_file.endswith('.ts'):  
                f.write(f"file '../codes/videos/{ts_file}'\n")  
  
    command = [  
        "ffmpeg",  
        '-f', 'concat',  
        '-safe', '0',  
        "-i", 'filelist.txt',  
        "-c", "copy",  
        output_file,  
    ]  
    subprocess.run(command)  
  
if __name__ == '__main__':  
    ts_files = os.listdir("../codes/videos")  
    merge_ts_files(ts_files, "恋人不行_12.mp4")
```
## 4. ffmpeg常用参数：

### (1) 当前使用的参数
- `-f concat`: 指定输入格式为连接模式，用于合并多个文件
- `-safe 0`: 允许使用不安全的文件路径（如包含特殊字符的路径）
- `-i filelist.txt`: 指定输入文件列表
- `-c copy`: 直接复制视频/音频流，不进行重新编码
### (2) 常用 FFmpeg 参数
#### a. 基本参数
- `-i <input>`: 指定输入文件
- `-o <output>`: 指定输出文件
- `-y`: 覆盖输出文件而不询问
- `-n`: 不覆盖输出文件
#### b. 编码相关
- `-c:v`: 指定视频编码器
- `-c:a`: 指定音频编码器
- `-c copy`: 直接复制流（不重新编码）
- `-crf <value>`: 指定恒定速率因子（0-51，数值越小质量越高）
#### c. 视频处理
- `-vf <filter>`: 应用视频滤镜
- `-s <size>`: 设置输出视频尺寸
- `-r <fps>`: 设置帧率
- `-b:v <bitrate>`: 设置视频比特率
#### d. 音频处理
- `-b:a <bitrate>`: 设置音频比特率
- `-ar <rate>`: 设置音频采样率
- `-ac <channels>`: 设置音频通道数
#### e. 时间控制
- `-ss <time>`: 设置开始时间
- `-t <duration>`: 设置持续时间
- `-to <time>`: 设置结束时间
#### f. 其他常用参数
- `-threads <number>`: 设置处理线程数
- `-preset <preset>`: 设置编码预设（如 ultrafast, fast, medium, slow）
- `-hwaccel <api>`: 启用硬件加速

------

# 28. Selenium
## 1. Selenium 简介
- Selenium 是一个用于 Web 应用程序自动化测试的开源框架。它允许你编写程序来控制浏览器，模拟用户操作，如点击按钮、填写表单、导航页面等。Selenium 支持多种编程语言（如 Python、Java、C# 等）和多种浏览器（Chrome、Firefox、Safari 等）。

## 2. 常用函数和方法

### （1）浏览器操作相关
- `get(url)` - 打开指定 URL 页面
- `quit()` - 关闭整个浏览器
- `close()` - 关闭当前窗口
- `refresh()` - 刷新当前页面
- `back()` - 后退到上一页
- `forward()` - 前进到下一页
### （2）元素定位相关
- `find_element()` - 查询单个元素，返回一个对象（没找到会报错）
- `find_elements(...)` - 查询多个元素，返回一个列表（没找到返回空列表）

- `find_element(By.ID, "id")` - 通过 ID 查找单个元素
- `find_element(By.NAME, "name")]` - 通过 name 属性查找单个元素
- `find_element(By.CLASS_NAME, "class")` - 通过 class 属性查找单个元素（只能查找单个class值，多个class值一起查询会报错）
- `find_element(By.TAG_NAME, "tag")` - 通过标签名查找单个元素
- `find_element(By.XPATH, "xpath")` - 通过 XPath 查找单个元素
- `find_element(By.CSS_SELECTOR, "css")`- 通过 CSS 选择器查找单个元素
- `find_element(By.LINK_TEXT, "link")` - 通过`<a>`标签内的文本，查找`<a>`标签（**精准匹配**）
- `find_element(By.PARTIAL_LINK_TEXT, "link")` - 通过`<a>`标签内的文本，查找`<a>`标签（**模糊匹配**）

### （3）元素操作相关
- `click()` - 点击元素
- `send_keys(text)` - 向元素输入文本
- `clear()` - 清除元素中的文本
- `submit()` - 提交表单
- `get_attribute(name)` - 获取元素属性值
- `text` - 获取元素文本内容
### （4）等待机制
- `implicitly_wait(seconds)` - 设置隐式等待时间（`timeout`），在设置时间内找到元素就能立刻执行，否则报错
- 显式等待，配合 `WebDriverWait` 和 `expected_conditions` 使用
- `time.sleep()` - 程序级休眠，固定休眠
### （5）窗口和框架操作
- `switch_to.frame(frame_reference)` - 切换到指定框架
- `switch_to.window(window_handle)` - 切换到指定窗口
- `window_handles` - 获取所有窗口句柄
### （6）获取浏览器渲染后的页面 HTML 文档字符串
1. **包含信息**：
	- 完整的 HTML 结构（包括 `<html>`, `<head>`, `<body>` 等标签）
	- 所有 DOM 元素及其属性
	- JavaScript 动态生成的内容（如果有的话）
	- CSS 样式信息（内联样式或嵌入样式）
2. **使用方法**：
```python
html_content = driver.page_source
```

## 3. 视频代码复刻：
``` python
import time  
  
from selenium import webdriver # 操作浏览器  
from selenium.webdriver import ActionChains, Keys  
from selenium.webdriver.chrome.service import Service # 管理驱动  
from selenium.webdriver.chrome.options import Options # 管理设置  
  
def create_browser():  
    # 创建设置浏览器对象  
    opt = Options()  
    # 禁用沙盒模式（增强兼容性，防止打不开浏览器）  
    opt.add_argument('--no-sandbox')  
    # 保持浏览器打开状态（浏览器默认会在代码执行完毕后关闭）  
    opt.add_experimental_option("detach", True)  
  
    # 创建并启动浏览器（参数：浏览器驱动路径，）  
    b = webdriver.Chrome(service=Service("../.venv/Scripts/chromedriver.exe"), options=opt)  
    # Selenium 4 添加了自动下载并管理浏览器驱动的功能，但需要访问GitHub获取  
    # b = webdriver.Chrome(options=opt)  
  
    return b  
  
if __name__ == '__main__':  
    browser = create_browser()  
    
#################
# 打开网址  
#################
    # 打开指定网址  
    browser.get("https://www.baidu.com") # 必须添加协议，否则会报错  
    # 在当前标签页打开新网址  
    browser.get("https://www.bilibili.com")  
# 新标签页  
    # 在新标签页打开网址  
    # 1. 使用javascript脚本  
    browser.execute_script("window.open('https://www.bilibili.com')")  
    # 2. 使用按键新建标签页后，跳转到新标签页再打开网址  
    # 发送Ctrl+T快捷键打开新标签页  
    ActionChains(browser).key_down(Keys.CONTROL).send_keys('t').key_up(Keys.CONTROL).perform()   # 动作链，通过发送一系列指令模拟人工操作
    # 切换到新标签页  
    browser.switch_to.new_window('tab')  
    # 在新标签页中打开网址  
    browser.get("https://www.bilibili.com")  
    
#################
# 窗口控制  
#################
    # 浏览器最小化  
    browser.minimize_window()  
    time.sleep(1)  
    # 浏览器全屏  
    browser.fullscreen_window()  
    time.sleep(1)  
    # 浏览器最大化  
    browser.maximize_window()  
    time.sleep(1)  
    # 浏览器窗口化  
    # set_window_rect是set_window_size和set_window_position的合并版本  
    browser.set_window_rect(x=100, y=100, width=1200, height=800)  
    time.sleep(1)  
    browser.set_window_position(0, 0)  
    time.sleep(1)
      
#################
# 浏览器截图  
#################
    browser.save_screenshot("bilibili.png") # 截取当前标签页窗口图片，并保存在当前目录下  
    time.sleep(1) 
     
#################   
# 刷新当前标签页
################# 
    browser.refresh()  
    time.sleep(1)  
  
    # 关闭当前标签页  
    browser.close()  
    # 关闭浏览器并释放驱动  
    browser.quit()
```

``` python
import time  
  
from selenium import webdriver # 操作浏览器  
from selenium.webdriver import Keys # 按键模拟  
from selenium.webdriver.chrome.service import Service # 管理驱动  
from selenium.webdriver.chrome.options import Options # 管理设置  
from selenium.webdriver.common.by import By # 元素查找  
  
  
def create_browser():  
    # 创建设置浏览器对象  
    opt = Options()  
    # 禁用沙盒模式（增强兼容性，防止打不开浏览器）  
    opt.add_argument('--no-sandbox')  
    # 保持浏览器打开状态（浏览器默认会在代码执行完毕后关闭）  
    opt.add_experimental_option("detach", True)  
  
    # 创建并启动浏览器（参数：浏览器驱动路径，）  
    b = webdriver.Chrome(service=Service("../.venv/Scripts/chromedriver.exe"), options=opt)  
  
    return b  
  
if __name__ == '__main__':  
    browser = create_browser()  
    browser.implicitly_wait(10)  # 设置隐式等待时间为10s
    browser.get("https://www.bilibili.com")  
    browser.maximize_window()  
# 元素定位  
    # 定位一个元素，找不到会报错  
    elem1 = browser.find_element(By.CLASS_NAME, "nav-search-input")  
    print(elem1)  
  
    # 定位多个元素，找不到的话返回空列表  
    elem2 = browser.find_elements(By.CLASS_NAME, "nav-search-input")  
    print(elem2)  
  
# 元素操作  
    # 输入文本  
    elem1.send_keys("MyGO!!!!!")  
    time.sleep(2)  
    # 点击搜索按钮  
    browser.find_element(By.CLASS_NAME, "nav-search-btn").click()  
    # 等待新窗口并切换  
    time.sleep(3)  # 简单等待  
    # 在打开新窗口后，如果要定位新窗口的元素，必须切换到新窗口才能进行元素定位  
    browser.switch_to.window(browser.window_handles[-1])  
    # 重新定位元素  
    elem1 = browser.find_element(By.CLASS_NAME, "search-input-el")  
    print(elem1.get_attribute("outerHTML"))  
    # 不知道为什么，不能直接使用API清除，只能模拟按键输入进行清除  
    elem1.click()  
    elem1.send_keys(Keys.CONTROL + "a")  # 全选  
    elem1.send_keys(Keys.DELETE)  # 删除  
    time.sleep(1)  
    # 输入文本  
    elem1.send_keys("Ave Mujica")  
    time.sleep(0.5)  
    # 搜索  
    elem1.send_keys(Keys.ENTER)  
    time.sleep(5)  
    browser.quit()
```
## 4. 无头浏览器配置
- 创建浏览器前添加这两行配置就行
``` python
opt = Options()
opt.add_argument('--headless')      # 无头运行
opt.add_argument('--disable-gpu')   # 禁用GPU加速
```
# 5. 验证码处理
- 验证码处理分两类，一类是自己编写视觉处理逻辑，比如使用`opencv`，但极其麻烦；一类是使用已有的框架，这里的示例程序使用的是超级鹰验证码识别平台
``` python
import json  
import time  
  
from selenium import webdriver  
from selenium.webdriver.chrome.options import Options  
from selenium.webdriver.chrome.service import Service  
from selenium.webdriver.common.by import By  
from chaojiying import Chaojiying_Client  

# 为保护隐私，account和password需填写你自己的账号和密码
account = "123123123"  
password = "1231231231"  
  
def create_browser():  
    # 创建设置浏览器对象  
    opt = Options()  
    # 禁用沙盒模式（增强兼容性，防止打不开浏览器）  
    opt.add_argument('--no-sandbox')  
    # 保持浏览器打开状态（浏览器默认会在代码执行完毕后关闭）  
    opt.add_experimental_option("detach", True)  
    # 创建并启动浏览器（参数：浏览器驱动路径，）  
    b = webdriver.Chrome(service=Service("../.venv/Scripts/chromedriver.exe"), options=opt)  
  
    return b  
  
if __name__ == '__main__':  
    browser = create_browser()  
    browser.implicitly_wait(10)  
    browser.get("https://www.chaojiying.com/user/login/")  
    img_element = browser.find_element(By.XPATH, "/html/body/div[3]/div/div[3]/div[1]/form/div/img")  
    # 直接截屏获取验证码图片  
    img = img_element.screenshot('i.png')  
    time.sleep(1)  
    # 超级鹰处理验证码  
    chaojiying = Chaojiying_Client(account, password, '973730')  
    im = open('i.png', 'rb').read()  
    result = chaojiying.PostPic(im, 1004)  
    print(result)  
    print(result['pic_str'])  
    # 填充内容  
    browser.find_element(By.XPATH, "/html/body/div[3]/div/div[3]/div[1]/form/p[1]/input").send_keys(account)  
    browser.find_element(By.XPATH, "/html/body/div[3]/div/div[3]/div[1]/form/p[2]/input").send_keys(password)  
    browser.find_element(By.XPATH, "/html/body/div[3]/div/div[3]/div[1]/form/p[3]/input").send_keys(result['pic_str'])  
    time.sleep(2)  
    browser.find_element(By.XPATH, "/html/body/div[3]/div/div[3]/div[1]/form/p[4]/input").click()  
    time.sleep(2)
```

``` python
# chaojiying.py
from hashlib import md5  
  
import requests  
  
class Chaojiying_Client(object):  
  
    def __init__(self, username, password, soft_id):  
        self.username = username  
        password =  password.encode('utf8')  
        self.password = md5(password).hexdigest()  
        self.soft_id = soft_id  
        self.base_params = {  
            'user': self.username,  
            'pass2': self.password,  
            'softid': self.soft_id,  
        }  
        self.headers = {  
            'Connection': 'Keep-Alive',  
            'User-Agent': 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)',  
        }  
  
    def PostPic(self, im, codetype):  
        """  
        im: 图片字节  
        codetype: 题目类型 参考 http://www.chaojiying.com/price.html        """        params = {  
            'codetype': codetype,  
        }  
        params.update(self.base_params)  
        files = {'userfile': ('ccc.jpg', im)}  
        r = requests.post('http://upload.chaojiying.net/Upload/Processing.php', data=params, files=files, headers=self.headers)  
        return r.json()  
  
    def PostPic_base64(self, base64_str, codetype):  
        """  
        im: 图片字节  
        codetype: 题目类型 参考 http://www.chaojiying.com/price.html        """        params = {  
            'codetype': codetype,  
            'file_base64':base64_str  
        }  
        params.update(self.base_params)  
        r = requests.post('http://upload.chaojiying.net/Upload/Processing.php', data=params, headers=self.headers)  
        return r.json()  
  
    def ReportError(self, im_id):  
        """  
        im_id:报错题目的图片ID  
        """        params = {  
            'id': im_id,  
        }  
        params.update(self.base_params)  
        r = requests.post('http://upload.chaojiying.net/Upload/ReportError.php', data=params, headers=self.headers)  
        return r.json()
```

------

# 29. Scrapy 框架

 Scrapy 是一个用 Python 编写的开源网络爬虫框架，专门用于从网站上提取结构化数据。它提供了强大的功能来处理网页抓取、数据解析和存储等任务。
### 1. 主要特点：
- **异步处理**：基于 Twisted 框架，支持高并发请求
- **可扩展性**：支持自定义中间件、管道和扩展组件
- **内置功能丰富**：包括数据提取、链接跟踪、数据验证等功能
- **多格式输出**：支持 JSON、CSV、XML 等多种数据格式
## 2. Scrapy 的核心组件及架构

### 核心组件：

#### 1. `Engine`（引擎）
- **作用**：整个系统的中枢，负责处理所有模块的衔接，控制所有组件之间的数据流交互
- **功能**：
	1. 触发事务
	2. 协调 `Spider`、`Item Pipeline`、`Downloader`、`Scheduler` 之间的通信
#### 2. `Scheduler`（调度器）
- **作用**：接收引擎发来的请求，排序并入队
- **功能**：
	1. 管理待处理的 `Request` 队列
	2. 在引擎需要时提供下一个要抓取的 `Request`
#### 3. `Downloader`（下载器）
- **作用**：负责获取页面数据
- **功能**：
	1. 发送请求并获取响应
	2. 处理网络通信
#### 4. `Spider`（爬虫）
- **作用**：解析 `Response` 并提取需要的数据或新的 URL
- **功能**：
	1. 处理响应
	2. 提取 `Item`
	3. 生成新的请求
#### 5. `Item Pipeline`（管道）
- **作用**：处理由 `Spider` 提取出来的 `Item`
- **功能**：
	1. 清理 HTML 数据
	2. 验证提取的数据
	3. 查重并丢弃重复内容
	4. 持久化存储数据（文件、数据库、etc...）
### 中间件组件：

- **Downloader Middlewares**：位于 `Engine` 和 `Downloader` 之间
- **Spider Middlewares**：位于 `Engine` 和 `Spider` 之间

### 架构流程

#### a. 数据流顺序：
1. `Engine` 从 `Spider` 获取`Spider`内初始要抓取的URL，构建出初始 `Request`对象
2. `Engine` 将 `Request` 发送给 `Scheduler` 等待调度
3. `Scheduler` 将队列头的 `Request` 返回给 `Engine`
4. `Engine` 将 该`Request` 发送给 `Downloader` 执行下载
5. 一旦页面下载完成，`Downloader` 生成该` Request` 对应的 `Response` 对象，并发送给 `Engine`
6. `Engine` 接收 `Response` 并发送给 `Spider` 处理
7. `Spider` 处理 `Response` 并返回提取的 `Item` 和新的 `Request`（如果有的话）
8. `Engine` 将处理的 `Item` 发送给 `Item Pipeline`，供`Pipeline`进行数据的后处理，同时如果有新的`Reqeust`，将新的 `Request` 发送给 `Scheduler`
9. 重复步骤 3~8 直到完成所有请求
### 总结：
- **引擎**是核心协调者，控制数据流
- **调度器**管理待处理的请求队列
- **下载器**负责网络通信
- **中间件**提供可扩展的钩子机制
- **管道**负责数据后处理

这种架构设计使得 Scrapy 具有高度的可扩展性和灵活性，各组件职责明确，便于维护和定制。
## 3. 基本使用方法

### （1）安装 Scrapy
```bash
pip install scrapy
```
### （2）创建项目
```bash
scrapy startproject myproject
cd myproject
```
### （3）创建爬虫
```bash
scrapy genspider example example.com
```
### （4）编写爬虫代码示例
```python
import scrapy

class ExampleSpider(scrapy.Spider):
    name = 'example'
    start_urls = ['http://example.com']

    def parse(self, response):
        # 使用 CSS 选择器提取数据
        for item in response.css('div.item'):
            yield {
                'title': item.css('h2.title::text').get(),
                'price': item.css('span.price::text').get(),
            }
        
        # 跟踪下一页链接
        next_page = response.css('a.next::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)
```
### （5）运行爬虫
```bash
scrapy crawl example
```
## 4. 使用场景

### （1）数据采集和分析
- **电商价格监控**：定期抓取商品价格信息进行比价
- **新闻聚合**：从多个新闻源收集文章内容
- **社交媒体数据挖掘**：抓取公开的社交平台数据
### （2）SEO 监控
- 抓取网站排名信息
- 分析竞争对手的 SEO 策略
- 监控网站索引情况
### （3）内容迁移
- 将旧网站内容迁移到新平台
- 整合多个数据源的内容
### （4）市场研究
- 收集行业报告和市场数据
- 竞品分析数据获取
- 用户评论和反馈收集
### （5）学术研究
- 收集研究所需的大规模网络数据
- 社会网络分析数据获取
## 5. 高级特性

### （1）中间件支持
可以通过编写中间件来：
- 修改请求头（User-Agent、Cookie 等）
- 处理代理设置
- 实现请求重试机制
### （2）数据管道
- 可以配置多个管道来进行：
	- 数据去重
	- 数据清洗和转换
	- 存储到数据库（MySQL、MongoDB 等）
### （3）分布式部署
- 支持配合 Scrapyd 进行分布式部署，提高抓取效率
### （4）内置支持
- 自动处理 Cookies 和 Session
- 支持多种认证方式
- 内置常见的反爬虫对策
# 30. Scrapy初见
## 1. 创建项目：
``` shell
scrapy startproject game
cd game
```
## 2. 项目结构：
```
game/
├── game/
│   ├── __init__.py
│   ├── items.py
│   ├── middlewares.py
│   ├── pipelines.py
│   └── settings.py
└── scrapy.cfg
```
- `game/`：项目主目录，包含所有核心组件
- `__init__.py`：Python 包初始化文件，用于定义包的入口
- `items.py`：定义数据结构（`Item` 类），用于存储抓取的数据
- `middlewares.py`：定义中间件，处理请求和响应的钩子函数
- `pipelines.py`：定义数据管道`pipeline`，处理提取的数据（如清洗、存储等）
- `settings.py`：配置文件，包含爬虫的各种设置参数
- `scrapy.cfg`：项目配置文件，用于管理多个爬虫项目
对于非大型项目而言，只需关注五大组件中的`Spider`和`Pipeline`。
## 3. 创建爬虫
``` bash
scrapy genspider xiaoyouxi www.4399.com # 创建爬虫，参数为爬虫名和爬取网站
```
生成爬虫结构如下：
``` python
import scrapy  
  
  
class XiaoyouxiSpider(scrapy.Spider):   # 默认继承Spider类
    name = "xiaoyouxi"                  # 爬虫名
    allowed_domains = ["www.4399.com"]  # 限定爬取网页
    start_urls = ["https://www.4399.com"]  # 起始url
  
    def parse(self, response):          # 处理response对象
        pass
```
令`parse()`方法打印`response.text`，获取页面源代码。

执行爬虫：
``` bash
scrapy crawl xiaoyouxi
```
可以得到一大堆日志，中间夹了我们的输出结果。

``` shell
注：必须在项目目录下执行上述命令，才能启动scrapy项目！
```
## 4. 实战——爬取4399小游戏某页面的部分游戏名和链接
- 这里仅是单独执行爬虫，没有与其他组件进行联动
``` python
class XiaoyouxiSpider(scrapy.Spider):  
    name = "xiaoyouxi"  
    allowed_domains = ["www.4399.com"]  
    start_urls = ["https://www.4399.com/special/277.htm"]  
  
    def parse(self, response):  
        result = self.gain_names(response)  
        if not os.path.exists("../contents"):  
            os.mkdir("../contents")  
        with open("../contents/xiaoyouxi.json", "w", encoding="utf-8") as f:  
            f.write(json.dumps(result, ensure_ascii=False))  
  
    def gain_names(self, response):  
        contents = response.xpath('//ul[@id="classic"]/li/a')  
        result = [  
            {  
                "name": content.xpath("./text()").get(),  
                "url": content.xpath("./@href").get(),  
            }  
            for content in contents  
        ]  
        return result
```
爬取到的JSON文件这里就不放出来了

## 5. 修改代码，让其符合完整的Scrapy项目工作流程
### a. 爬虫`xiaoyouxi.py`
``` python
import scrapy  
  
from ..items import GameItem  
  
class XiaoyouxiSpider(scrapy.Spider):  
    name = "xiaoyouxi"  
    allowed_domains = ["www.4399.com"]  
    start_urls = ["https://www.4399.com/special/277.htm"]  
  
    def parse(self, response):  
        contents = response.xpath('//ul[@id="classic"]/li/a')  
        for content in contents:  
            item = GameItem()  
            item['name'] = content.xpath('./text()').get()  
            item['url'] = content.xpath('./@href').get()  
            yield item  # 通过 yield 将数据发送给管道
```
### b. 数据`items.py`
``` python
import scrapy  

class GameItem(scrapy.Item):  
    name = scrapy.Field()  
    url = scrapy.Field()
```
### c. 管道`pipelines.py`
``` python
import json  
import os  
  
class GamePipeline:  
    def open_spider(self, spider):  
        self.items = []  
  
    def close_spider(self, spider):  
        # 在爬虫结束时写入完整的 JSON 数组  
        if not os.path.exists('contents'):  
            os.mkdir('contents')  
        with open('contents/games.json', 'w', encoding='utf-8') as f:  
            json.dump(self.items, f, ensure_ascii=False, indent=2)  
  
    def process_item(self, item, spider):  
        # 将每个 item 添加到列表中  
        self.items.append(dict(item))  
        return item
```
### d. `settings.py`
``` python
# 添加如下行进行管道配置
ITEM_PIPELINES = {  
   "game.pipelines.GamePipeline": 300,   # 数字越小，优先级越高
}
```

------

# 32. Scrapy深入——Pipeline
## 1. 常用方法：

 1. `open_spider(spider)`
	- **调用时机**：Spider 启动时调用一次。
	- **用途**：用于执行初始化操作，如打开数据库连接、创建文件句柄、初始化计数器等。
- 示例：
``` python
def open_spider(self, spider):
    self.file = open('items.json', 'w')
    self.item_count = 0
    spider.logger.info('Pipeline opened')
```

2. `close_spider(spider)`
	- **调用时机**：Spider 关闭时调用一次。
	- **用途**：用于清理资源，如关闭数据库连接、关闭文件、输出统计信息等。
- **示例**：
```python
def close_spider(self, spider):
    self.file.close()
    spider.logger.info(f'Processed {self.item_count} items')
```
    
3. `process_item(item, spider)` (核心方法)
	- **调用时机**：每个 Item 被生成后都会调用此方法。
	- **用途**：这是 Pipeline 的核心逻辑，用于处理或保存 Item。
	- **必须返回值**：必须返回 `item` 对象，否则该 Item 会被丢弃。
	- **返回方式**：
	    - `return item`：继续传递给下一个 Pipeline。
	    - `raise DropItem()`：丢弃该 Item，不再传递。
- **示例**：
```python
from scrapy.exceptions import DropItem

def process_item(self, item, spider):
    if item.get('price'):
        if item['price'] <= 0:
            raise DropItem(f"Invalid price: {item['price']}")
        self.item_count += 1
        line = json.dumps(dict(item)) + "\n"
        self.file.write(line)
        return item  # 继续传递
    else:
        raise DropItem("Missing price field")
```

4. `from_crawler(cls, crawler)` (类方法)
	- **调用时机**：Scrapy 在创建 Pipeline 实例时调用。
	- **用途**：用于访问 `settings`、`crawler` 对象，实现更复杂的初始化，如读取配置参数。
- **示例**：
```python
@classmethod
def from_crawler(cls, crawler):
    return cls(
        mongo_uri=crawler.settings.get('MONGO_URI'),
        mongo_db=crawler.settings.get('MONGO_DATABASE', 'items')
    )
```

## 2.  **如何启用 Pipeline**
在 `settings.py` 中配置 `ITEM_PIPELINES`，数字表示执行顺序（越小越先执行）：
```python
ITEM_PIPELINES = {
   'myproject.pipelines.PriceValidationPipeline': 300,
   'myproject.pipelines.JsonWriterPipeline': 400,
   'myproject.pipelines.MongoDBPipeline': 500,
}
```

## 3. 如何为不同爬虫定义不同的管道

在 Scrapy 中，**爬虫（Spider）本身并不主动“选择”使用哪个管道（Pipeline）**。管道的选择和执行是由 Scrapy 的全局配置决定的，而不是由单个爬虫代码直接指定。但也不是没有办法完成这个功能。

虽然配置是全局的，但我们可以在 Pipeline 内部根据当前运行的 `spider` 参数来判断是否处理该 Item，从而实现“选择性”处理。

### 方法一：在 `process_item` 中判断 `spider` 名称

```python
# pipelines.py
class SaveToMongoDBPipeline:
    def process_item(self, item, spider):
        # 只有名为 'ecommerce_spider' 的爬虫才保存到 MongoDB
        if spider.name == 'ecommerce_spider':
            self.save_to_mongo(item)
        # 其他爬虫的 Item 直接放行（不处理）
        return item

class SaveToMySQLPipeline:
    def process_item(self, item, spider):
        # 只有名为 'news_spider' 的爬虫才保存到 MySQL
        if spider.name == 'news_spider':
            self.save_to_mysql(item)
        return item
```

> **优点**：简单直接，无需修改配置。  
> **缺点**：所有管道仍被加载，只是内部做了过滤。
### ✅ 方法二：动态设置 `ITEM_PIPELINES`（推荐）

在 Spider 类中通过 `custom_settings` 覆盖全局配置，实现**每个爬虫独立的管道配置**。

```python
# spiders/ecommerce_spider.py
import scrapy

class EcommerceSpider(scrapy.Spider):
    name = 'ecommerce_spider'
    
    # 自定义设置：只启用特定管道
    custom_settings = {
        'ITEM_PIPELINES': {
            'myproject.pipelines.ValidateItemPipeline': 100,
            'myproject.pipelines.SaveToMongoDBPipeline': 200,
        }
    }

    def start_requests(self):
        pass
```

```python
# spiders/news_spider.py
class NewsSpider(scrapy.Spider):
    name = 'news_spider'
    
    # 不同的管道配置
    custom_settings = {
        'ITEM_PIPELINES': {
            'myproject.pipelines.CleanItemPipeline': 100,
            'myproject.pipelines.SaveToMySQLPipeline': 200,
        }
    }
```

> **优点**：
> - 真正实现了“每个爬虫使用不同的管道”。
> - 未启用的管道不会被实例化，更高效。
> - 配置清晰，易于维护。
### ✅ 方法三：通过 `settings` 变量控制

也可以在 `settings.py` 中定义多个管道组，然后在 Spider 中通过 `crawler.settings` 动态读取。
```python
# settings.py
PIPELINES_FOR_SPIDER_A = {
    'myproject.pipelines.PipelineA': 100,
}

PIPELINES_FOR_SPIDER_B = {
    'myproject.pipelines.PipelineB': 100,
}
```

```python
# 在 Spider 中设置
class MySpider(scrapy.Spider):
    name = 'spider_a'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # 动态设置管道
        self.custom_settings = getattr(self, 'custom_settings', {})
        self.custom_settings['ITEM_PIPELINES'] = self.settings.get('PIPELINES_FOR_SPIDER_A')
```

> 这种方式更灵活，但不如 `custom_settings` 直观。
### **总结**

|方法|说明|推荐度|
|---|---|---|
|**`custom_settings` + `ITEM_PIPELINES`**|每个爬虫定义自己的管道，最清晰、最推荐|⭐⭐⭐⭐⭐|
|**在 `process_item` 中判断 `spider.name`**|全局管道统一，内部条件处理|⭐⭐⭐⭐|
|**动态设置 `ITEM_PIPELINES`**|通过代码动态控制，适合复杂场景|⭐⭐⭐|

------

# 33. Scrapy深入——`CrawlSpider`类

`CrawlSpider` 是 Scrapy 框架中一个非常强大的内置 Spider 类（`scrapy.spiders.CrawlSpider`），它是 `scrapy.Spider` 的子类，专门用于**自动跟踪网页链接、实现多层级爬取**，特别适合需要**从起始页开始，不断发现并跟进链接**的场景，比如网站镜像、全站数据抓取等。

---
## **1. 为什么需要 CrawlSpider？**

如果我们使用普通的 `Spider` 类：
- 我们需要手动在 `parse()` 方法中解析响应，提取链接，然后手动创建新的 `scrapy.Request`。
- 对于复杂的链接规则（如分页、分类、详情页等），代码会变得冗长且难以维护。

而 `CrawlSpider` 提供了 **规则系统（Rules）**，可以：
- 自动匹配符合特定条件的链接。
- 自动跟进这些链接并回调指定的处理函数。
- 极大简化了“发现链接 → 跟进 → 处理”的流程。

------
## **2. CrawlSpider 的核心组件**

#### **(1) `rules` 类属性**
这是 `CrawlSpider` 的核心，定义了一个或多个 `Rule` 对象，告诉爬虫：
- 哪些链接需要跟进？
- 跟进后调用哪个方法处理？
```python
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

class MyCrawlSpider(CrawlSpider):
    name = 'mycrawler'
    allowed_domains = ['example.com']
    start_urls = ['https://example.com']

    rules = (
        # Rule 1: 跟进分类页链接
        Rule(LinkExtractor(allow=r'/category/\d+'), callback='parse_category', follow=True),
        # Rule 2: 跟进详情页链接，不继续跟进（follow=False）
        Rule(LinkExtractor(allow=r'/product/\d+'), callback='parse_product', follow=False),
    )

    def parse_category(self, response):
        # 处理分类页面
        pass

    def parse_product(self, response):
        # 处理商品详情页
        pass
```
#### **(2) `LinkExtractor`（链接提取器）**

用于定义**如何从页面中提取链接**。常用参数：

|参数|说明|
|---|---|
|`allow`|正则表达式，只提取匹配的链接（如 `r'/page/\d+'`）|
|`deny`|正则表达式，排除匹配的链接|
|`allow_domains`|限制域名|
|`restrict_xpaths`|只从指定的 XPath 节点提取链接|
|`restrict_css`|只从指定的 CSS 选择器提取链接|
|`tags`|指定提取哪些标签的链接（默认 `['a', 'area']`）|
|`attrs`|指定提取哪个属性的链接（默认 `['href']`）|

**示例**：
```python
# 只提取 class="next" 的分页链接
LinkExtractor(restrict_css='a.next', allow=r'/page/\d+')

# 只从导航栏提取链接
LinkExtractor(restrict_xpaths='//div[@id="nav"]')
```
#### **(3) `Rule` 类**
定义一条爬取规则，构造函数：
```python
Rule(
    link_extractor,        # LinkExtractor 实例
    callback='xxx',        # 回调函数名（字符串），用于处理提取到的页面
    cb_kwargs={abc: yyy},  # 传递给 callback 的额外参数(一个字典)
    follow=True/False,     # 是否继续跟进该链接提取出的新链接？
    process_links='xyz',   # 提取链接后，预处理链接列表的函数
    process_request='ijk'  # 处理 Request 对象的函数（可修改 request）
)
```
- `callback`：当链接被请求并返回响应后，调用此方法处理页面。
- `follow`：
    - `True`：表示继续从该页面中提取符合规则的链接（用于分页、目录页）。
    - `False`：只处理当前页面，不再跟进新链接（用于详情页）。
- `process_links`：接收一个链接列表，可进行去重、过滤等操作。
- `process_request`：可修改 Request，如添加 meta、修改 headers。
``` python
# e.g.
Rule(
	LinkExtractor(restrict_css='div.pagination', allow=r'\?page=\d+'),
	follow=True
	callback='parse_data'
), # 最常用的就这三个参数
```

------
## **3. CrawlSpider 的执行流程**

1. 从 `start_urls` 开始请求。
2. 下载页面后，使用 `rules` 中的 `LinkExtractor` 提取所有匹配的链接。
3. 对每个提取的链接：
    - 如果 `follow=True`，则继续从该响应中提取链接（递归）。
    - 如果 `callback` 指定了方法，则将该页面交给 `callback` 方法处理。
4. 重复直到没有新链接或达到限制。

---
## **4. 一个完整示例：爬取新闻网站**

```python
import scrapy
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

class NewsSpider(CrawlSpider):
    name = 'news_crawler'
    allowed_domains = ['news.example.com']
    start_urls = ['https://news.example.com']

    rules = (
        # 规则1: 跟进分页链接，并继续跟进下一页
        Rule(LinkExtractor(
            restrict_css='div.pagination',
            allow=r'\?page=\d+'
        ), follow=True),
        
        # 规则2: 跟进新闻详情页，调用 parse_news 处理
        Rule(LinkExtractor(
            restrict_css='h2.title a',
            allow=r'/news/\d+\.html'
        ), callback='parse_news', follow=False),
    )

    def parse_news(self, response):
        yield {
            'title': response.css('h1::text').get(),
            'content': response.css('div.content::text').get(),
            'url': response.url,
        }
```

---
## **5. 注意事项与最佳实践**

- ✅ **不要重写 `parse()` 方法**：`CrawlSpider` 的 `parse` 已被用作默认回调。如果你想处理 `start_urls` 的响应，应使用 `parse_start_url` 方法。
- ✅ **合理使用 `follow`**：避免无限循环或爬取过多无关页面。
- ✅ **使用 `restrict_xpaths/css` 精确控制链接范围**，避免爬取登录、注册等无关链接。
- ✅ **设置 `ROBOTSTXT_OBEY = True`** 遵守爬虫协议。
- ✅ **使用 `CLOSESPIDER_PAGECOUNT` 等设置控制爬取深度和数量**。

---
## **6. 与普通 Spider 的对比**

|特性|`Spider`|`CrawlSpider`|
|---|---|---|
|适用场景|简单、结构固定的爬取|复杂、多层级、自动发现链接|
|链接提取|手动编写|使用 `LinkExtractor` 自动提取|
|代码复杂度|简单页面低，复杂页面高|复杂页面更简洁|
|灵活性|高（完全手动控制）|中（受规则限制）|

------
## 7. 如何创建`CrawlSpider`类爬虫
### (1) 输入命令创建爬虫
``` shell
scrapy genspider -t crawl 蜘蛛名称 域名
```
- 生成代码示例如下：
``` python
# spiders/mycrawler.py 
import scrapy from scrapy.spiders 
import CrawlSpider, Rule from scrapy.linkextractors 
import LinkExtractor 
class MycrawlerSpider(CrawlSpider): 
	name = 'mycrawler' 
	allowed_domains = ['example.com'] 
	start_urls = ['http://example.com/'] 
	rules = ( # 默认生成一条规则，可以修改或添加 
		Rule(LinkExtractor(allow=r''), callback='parse_item', follow=True), 
	) 
	
	# TODO: 解析页面内容，填充 item
	def parse_item(self, response): 
	item = {}
```
### (2) 修改`start_urls`和`rules`

```python
start_urls = ['https://example.com/news', 'https://example.com/blog']

rules = (
    # 规则1: 跟进分页链接，继续跟进下一页
    Rule(LinkExtractor(
        restrict_css='a.next-page',
        allow=r'\?page=\d+'
    ), follow=True),

    # 规则2: 跟进新闻详情页，调用 parse_news 处理
    Rule(LinkExtractor(
        restrict_css='h2.title a',
        allow=r'/article/\d+\.html'
    ), callback='parse_news', follow=False),
)
```

### **(3) 编写 `callback` 方法处理数据**
```python
def parse_news(self, response):
    yield {
        'title': response.css('h1::text').get(),
        'content': ''.join(response.css('div.content p::text').getall()),
        'url': response.url,
        'publish_date': response.css('span.date::text').get()
    }
```

> 💡 注意：不要重写 `parse()` 方法，除非你清楚自己在做什么。`CrawlSpider` 使用 `parse` 作为默认回调。
### (4) 运行你的 CrawlSpider

```bash
scrapy crawl mycrawler
```