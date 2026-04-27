# 一、安装与配置
## 1. 安装：
- 先创建项目文件夹（`mkdir my-electron-app && cd my-electron-app`）；
- 在项目文件夹下执行`npm init`，构建npm项目;
- 执行 `npm install electron --save-dev`，安装 Electron 到该项目下；
- 修改`package.json`中的`main`项为`main.js`，并添加`author`和`description`项（可选，用于打包项目），同时在`scripts`项中添加启动命令键值对`"start": "electron ."`；
- 在根目录下创建`main.js`文件，添加如下内容：
``` javascript
// 引入依赖
const {app, BrowserWindow} = require('electron')

// 创建窗口
app.on('ready', () => {
    // new一个窗口，需要配置宽高（注意变量别写成window了，window是js的浏览器窗口对象）
    const win = new BrowserWindow({
        width: 800,
        height: 600,
        autoHideMenuBar: true, // 用于隐藏菜单栏
    })

    // 加载页面
    win.loadURL('https://www.baidu.com')
})
```
- 执行`npm start`，若有窗口出现，且窗口中出现百度搜索主页，代表项目创建成功！
# 二、项目总体结构分析：
```
my-electron-app/ 
├── main.js           # 主进程入口文件，负责创建窗口、管理应用生命周期 
├── preload.js        # 预加载脚本，在渲染进程和主进程之间安全通信的桥梁 
├── package.json      # 项目配置文件，定义依赖、启动脚本、应用元信息（如 name/version） 
├── README.md         # 项目说明文档 
├── .gitignore        # Git 忽略文件配置 
│ 
├── pages/            # 渲染进程页面资源目录（HTML/CSS/JS） 
│   ├── index.html    # 主窗口加载的 HTML 页面 
│   ├── render.js     # 渲染进程逻辑（运行在浏览器环境中） 
│   └── style.css     # 页面样式文件 
│
├── assets/           # 静态资源目录（图片、图标、字体等） 
│   └── icon.png      # 应用图标（可用于窗口或系统托盘） 
│ 
├── src/              # （可选）源代码目录（大型项目常用） 
│   ├── main/         # 主进程模块化代码 
│   └── renderer/     # 渲染进程模块化代码 
│ 
└── dist/             # （构建后生成）打包输出目录（由 electron-builder 等工具生成） 
    └── win-unpacked/ # Windows 平台解包后的可执行程序
```
# 三、`Preload.js`预加载脚本

> Electron 的**预加载脚本（Preload Script）** 是一个在渲染进程（Renderer Process）和主进程（Main Process）之间建立安全通信桥梁的关键机制。它在教学中常用于演示如何安全地暴露有限的 Node.js 或 Electron API 给前端页面，同时保持沙箱（sandbox）的安全性。

## 1. **作用与目的**
- **隔离与安全**：默认情况下，渲染进程运行在浏览器环境中，不能直接访问 Node.js 或 Electron 的 API（出于安全考虑）。预加载脚本能在这两者之间“有选择地”暴露能力。
- **上下文桥接**：通过 `contextBridge` 模块，可以将特定函数或属性安全地挂载到渲染进程的 `window` 对象上，供前端 JavaScript 调用。

## 2. **基本结构示例**

### 预加载脚本（`preload.js`）
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('myAPI', {
  sendMessage: (channel, data) => {
    ipcRenderer.send(channel, data);
  },
  onMessage: (channel, func) => {
    ipcRenderer.on(channel, (event, ...args) => func(...args));
  }
});
```
#### 渲染进程（HTML/前端 JS）
```html
<script>
  // window对象是全局对象，对其内部属性和方法的访问可以不用带window前缀
  window.myAPI.sendMessage('greet', 'Hello from renderer!');
  window.myAPI.onMessage('reply', (msg) => {
    console.log(msg); // 来自主进程的回复
  });
</script>
```
#### 主进程（`main.js`）
```javascript
const { app, BrowserWindow, ipcMain } = require('electron');

ipcMain.on('greet', (event, message) => {
  event.reply('reply', `Received: ${message}`);
});
```

---
### 3. **关键特性**
- **仅在加载时运行一次**：预加载脚本在每个渲染进程创建时执行一次。
- **可访问全部 Electron/Node API**：因为它运行在 Electron 的特殊上下文中（拥有 Node 集成但不直接暴露给页面）。
- **必须显式启用**：需在创建 `BrowserWindow` 时通过 `webPreferences.preload` 指定路径：
  ```javascript
  new BrowserWindow({
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      sandbox: true // 推荐开启沙箱
    }
  });
  ```

### 4. **重点强调**
- **不要直接暴露 ipcRenderer**：避免像 `exposeInMainWorld('ipc', ipcRenderer)` 这样做，会带来安全风险。
- **最小权限原则**：只暴露前端真正需要的功能。
- **与沙箱模式配合使用**：现代 Electron 应用推荐开启 `sandbox: true`，此时预加载脚本是唯一能与主进程通信的途径。