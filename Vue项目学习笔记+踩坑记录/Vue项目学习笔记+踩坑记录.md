# 1. 文件解析：
1. 文件夹：
	- public：存放不需要构建处理的大文件资源，如图片、视频、第三方库等。
	- assets：用于存放需要构建工具（如 Vite/Webpack）处理的小型公共资源，比如图标、小图、字体、CSS/JS 模块
	- router：存放vue-router的路由配置文件
	- stores：存放 Pinia/Vuex 的状态管理模块
	- views：放页面文件的，通常与路由一一对应。
2. 文件：
	- vite.config.js：Vite 的项目配置文件，控制构建、插件、别名、服务器设置等。不局限于 Vue，也适用于 React、JSX、TypeScript 等多种项目类型。
	- package.json：放组件包信息的
	- main.js：项目的入口文件，主要负责创建 Vue 实例（或使用 createApp）、引入插件（如 Vue Router、Pinia）、挂载 App 根组件到 DOM 上。
	- App.vue：vue页面入口
	- index.js：Vue Router 的配置文件，用于导出路由表和创建 createRouter 实例。
	- index.html：项目的 HTML 模板，Vue 应用会挂载到其中的某个 DOM 元素（如`<div id="app"></div>`）。
![[Pasted image 20250709005504.png]]
# 2. 踩坑点：
## 1. Element-Plus自定义主题色显示不了
- 解决方法挺简单，注释掉原来的`import 'element-plus/dist/index.css'`就行
![[Pasted image 20250709011524.png]]
### 解决方案原理如下：
- **不手动引入 `element-plus/dist/index.css`**，Element Plus **仍然会有默认样式**，但这些样式是通过 SCSS 源码按需编译进来的。
- 也就是说：✅ **即使不加 index.css，Element Plus 的组件依然有默认样式。**
- 当使用 Element Plus 时，有两种方式加载样式：

| 方式 | 是否需要手动引入 | 是否支持主题定制 | 是否包含默认样式 |
|------|------------------|------------------|------------------|
| ✅ 引入 index.css | 是 | ❌ 不支持 | ✅ 有 |
| ✅ 使用 SCSS 变量注入（推荐） | 否 | ✅ 支持 | ✅ 有（默认 + 自定义） |

- 当你没有手动引入 index.css，但你在组件中使用了 Element Plus 的组件（如 `<el-button>`、`<el-icon>`），Vite 或 Webpack 等构建工具会自动从 Element Plus 的 SCSS 源码中加载所需的样式，并**在构建时进行编译**。所以你看到的按钮、图标等样式，其实是**由 SCSS 编译而来的默认样式**。
## 2. 出现循环调用scss文件的错误
- 错误挺脑残，我在main.js里不知道什么时候import了这个scss文件，又在vite.config.js中配置了注入项，导致循环调用了...
![[Pasted image 20250709011750.png]]
![[Pasted image 20250709011838.png]]
## 3. Element-Plus的图标大小没法改
- 在我当前的版本，必须同时设置el-icon和icon的宽高，不然要么只有el-icon这个div变大，要么没反应
- 一种写法是用class，还能复用： 
``` vue
<!-- template部分 -->
<el-icon class="big-icon">  
    <Plus />
</el-icon>

<!-- style部分 -->
.big-icon{  
    height: 5em;  
    width: 5em;  
}  
.big-icon > svg{  
    font-size: 5em;  
}
```
- 还有一种写法是直接内嵌在icon里：
``` vue
<el-icon :size="100">  
    <Plus style="font-size: 100px"/>  
</el-icon>
```
## 4. `$router`标红
- `$router`属于直接访问实例，这是Vue2的选项式API，Vue3中使用会因为TypeScript的类型检查过于严格而报错。
- 使用Vue3的组合式API完美解决问题

``` vue
<!-- 注意：以下写法专属于Vue3 -->
<!-- 代码解析：从 vue-router 模块中获取 useRouter 函数，调用 useRouter() 函数获取当前应用中注册的路由实例，并将其赋值给变量 router。-->。
<script setup>  
import { useRouter } from 'vue-router'  
const router = useRouter()  
</script>
```
## 5. 访问"/"目录时，只显示父组件，不显示子组件
- 单独访问父组件时，肯定不会加载子组件，访问子组件时，才会在父组件的基础上加载子组件。依赖关系没有理解清楚
- 在父组件上加个默认重定向就行
``` javascript
  {  
    path: '/',  
    component: Manager,  
    redirect: '/home',  <!--看这看这看这！！！！-->
    children: [  
      {  
        path: 'home',  
        component: Home,  
      },  
    ]  
  },
```
## 6. Element Plus侧边栏无法设置高亮
- **在 `<el-menu-item>` 中使用了 `<span>` 标签后，导致菜单文字的高亮样式被覆盖或失效**。
- 文字不能用`span`标签包裹，删掉span标签解决问题。
#### 原因如下：
Element Plus 的菜单组件（`<el-menu>` / `<el-menu-item>`）内部默认会为激活项（`.is-active`）应用一些内建样式，例如：

```css
.el-menu-item.is-active {
  background-color: #ecf5ff;
  color: #409EFF;
  font-weight: bold;
}
```
但是当你把文字包裹在 `<span>` 中时：
```vue
<el-menu-item index="1">
  <span>首页</span>
</el-menu-item>
```

由于Element Plus 默认样式只作用于 `.el-menu-item` 的**直接文本内容**或特定结构。而 `<span>` 是一个自定义标签，**不会自动继承这些样式规则**，尤其是当它设置了style或父级有其他 CSS 影响时。
## 7. Element Plus 无法设置el-sub-menu__title的样式：
- 在 Vue 的单文件组件中，使用 `<style scoped>` 会通过属性选择器（如 `data-v-xxxxxx`）为当前组件的 DOM 元素添加样式作用域限制。但 Element Plus 的组件是编译后的子组件，它们的 DOM 结构并不在你的 .vue 文件模板中，因此：当你写了
``` vue
<style scoped>
.el-menu {
  background-color: #3a456b;
}
</style>
```
- 由于 scoped 的作用域限制，这个样式不会生效，因为：
	- `<el-menu>` 是一个子组件。它内部的真实 DOM 并不在你当前 .vue 文件中。
	- 所以带有 scoped 的 CSS 无法穿透到子组件内部
- 推荐解决方案：
	- 使用**样式穿透语法**：`::v-deep`（旧版写法） 或 `:deep()`（新版写法，Vue 3 + Vite 支持）
``` vue
<style scoped>
:deep(.el-menu) {   /* 新版写法 */
  background-color: #3a456b;
  border: none;
}

::v-deep .el-menu { /* 旧版写法 */
  background-color: #3a456b;
  border: none;
}
</style>
```
- 还有一种解法是使用模块化css类名 + class绑定，手动为子组件赋予这个class，如果样式没有被覆盖，就在样式后添加`!important`
``` vue
<!-- 1. 创建一个模块化css类 -->
<style module>
.menuStyle {
  background-color: #3a456b;
  border: none;
}
</style>

<!-- 2. 绑定这个类到el-menu上 -->
<el-menu :class="$style.menuStyle">
```
## 8. 默认高亮无法根据当前页面移动
- 添加`router`属性和`:default-active="$router.currentRoute.value.path"`动态绑定属性就行
``` vue
<el-menu router :default-active="$router.currentRoute.value.path" style=" height: calc(100vh - 60px);">
```
## 9. el-menu按钮无法使用@click进行路由跳转
- 本来el-menu设计上就不是绑定@click事件进行跳转的，是使用其index属性进行跳转的。
- 代码如下：
``` vue
<!-- 跳转到/manager/admin -->
<el-menu-item index="/manager/admin">管理员信息</el-menu-item>
```
## 10. el-upload上传图片后如何让第二个上传框消失？
- 根据`list`长度动态调整样式就行
1. 为`el-upload`添加`:class="{ 'hide-picture-card': data.avatarList.length === 1 }"`
2. 设置CSS样式：
``` css
:deep(.hide-picture-card .el-upload--picture-card){  
    display: none;  
}
```
3. 搞定
原文链接：[https://blog.csdn.net/weixin_43951592/article/details/116887722]

## 备份
``` java
@PostMapping("/list/deleteAdmins")  
public Result<String> deleteAdmins(@RequestBody List<Admin> admins) {  
    String basePath = System.getProperty("user.dir") + FileSystems.getDefault().getSeparator() + "files";  
    if (admins == null || admins.isEmpty()) {  
        return Result.error("500", "请选择要删除的记录");  
    }  
    for (Admin admin : admins) {  
        System.out.println("\nAvatarURL: " + admin.getAvatar());  
        String avatarURL = admin.getAvatar();  
        avatarURL = avatarURL.replace("\\", "/");  
          
        if (StringUtils.isNotBlank(avatarURL)) {  
            try {  
                if (CustomUtils.isValidURL(avatarURL)) {  
                    System.out.println("URL1: " + avatarURL);  
                    // 方法一：使用 URL 解析（适用于完整 URL）  
                    URL url = new URL(avatarURL);  
                    filePath = url.getFile(); // 获取路径部分，如 /files/download/xxx.jpg                    filePath = filePath.substring(filePath.lastIndexOf('/') + 1); // 获取文件名，如 xxx.jpg                } else {  
                    // 方法二：使用 FileSystems 解析（适用于相对路径）  
                    System.out.println("URL2: " + avatarURL);  
                    filePath = avatarURL;  
                }  
  
                String realFilePath = Paths.get(basePath, filePath).toString();  
                System.out.println("RealFilePath: " + realFilePath + "\n");  
                if (FileUtil.exist(realFilePath)) {  
                    boolean result = FileUtil.del(realFilePath); // 删除文件  
                    if (!result) {  
                        return Result.error("500", "头像文件删除失败");  
                    }  
                } else {  
                    return Result.error("500", "头像文件不存在");  
                }  
            } catch (Exception e) {  
                e.printStackTrace();  
                // 可记录日志，但不中断主流程  
                return Result.error("500", "头像文件删除失败");  
            }  
        }  
    }  
    boolean result = adminService.deleteAdmins(admins);  
    if (result) {  
        return Result.ok("批量删除成功");  
    } else {  
        return Result.error("500", "批量删除失败");  
    }  
}
```

