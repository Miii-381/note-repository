# 1. 正经教学
![[Pasted image 20250709223451.png]]
- src：存源代码的
	- main：存项目源代码的
		- common：存放通用工具类、常量类、公共方法等
		- controller：接收 HTTP 请求，调用 Service 层处理数据，并返回响应，是前后端交互的入口
		- service：处理后端数据，执行业务逻辑的具体代码，通常会调用mapper等。
		- mapper：定义 SQL 操作的方法，如增删改查，属于数据库与后端的一个映射层
		- entity：数据库表中的元组的实体形式，方便存储数据进行操作
		- exception：自定义异常类和全局异常处理器
	- test：存测试代码的
- target：存编译后文件的
- pom.xml：项目对象模型（Project Object Model），是Maven的核心配置文件。包含以下内容：
	- 项目基本信息（groupId, artifactId, version）
	- 依赖管理（dependencies）：引入 Spring Boot、MyBatis、Lombok 等依赖
	- 插件配置（plugins）：如编译插件、打包插件、测试插件
	- 构建配置（build）：指定资源过滤、输出路径等。
	- 多模块项目中还可能包含 `<modules>` 配置
# 2.踩坑实录
## 1. Spring Boot + MyBatis Plus + Lombok 数据操作流程（极简版）
```
HTTP 请求 → Controller → Service → Mapper → DB 查询 → 返回数据
                              ↓
                        或写入文件（如 CSV）
```
### ✅ 1. 获取数据流程
1. **Controller 接收请求**  
   ```java
   @RestController
   public class AdminController {
       @Resource
       private AdminService adminService;

       @GetMapping("/admins")
       public List<Admin> getAllAdmins() {
           return adminService.getAllAdmins(); // 调用 Service 方法
       }
   }
   ```
2. **Service 调用 Mapper 查询数据**  
   ```java
   @Service
   public class AdminService {

       @Autowired
       private AdminMapper adminMapper;

       public List<Admin> getAllAdmins() {
           return adminMapper.selectList(null); // 查询所有数据
       }
   }
   ```
3. **Mapper 定义数据库操作接口**  
   ```java
   public interface AdminMapper extends BaseMapper<Admin> {
   }
   ```
4. **Entity 映射数据库表字段**  
   ```java
   @Data  // Lombok 自动生成 getter/setter/toString/equals 等
   @TableName("admin")
   public class Admin {
       private Integer id;
       private String username;
       private String name;
   }
   ```

### ✅ 2. 操作文件流程（如导出为 CSV）
1. **Service 中添加写文件逻辑**
   ```java
   @Service
   public class AdminService {

       @Autowired
       private AdminMapper adminMapper;

       public void exportAdminsToCsv(String filePath) throws IOException {
           List<Admin> admins = adminMapper.selectList(null);

           try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
               writer.write("id,username,name\n");
               for (Admin admin : admins) {
                   writer.write(admin.getId() + "," + admin.getUsername() + "," + admin.getName() + "\n");
               }
           }
       }
   }
   ```
2. **Controller 添加导出接口**
   ```java
   @RestController
   public class AdminController {

       @Resource
       private AdminService adminService;

       @GetMapping("/export")
       public String exportAdmins() {
           try {
               adminService.exportAdminsToCsv("admins.csv");
               return "导出成功";
           } catch (IOException e) {
               return "导出失败: " + e.getMessage();
           }
       }
   }
   ```
### 小提示：
- `@Data`：Lombok 自动生成常用方法，简化实体类编写
- `BaseMapper`：MyBatis Plus 提供的通用数据库操作接口
- `selectList(null)`：查询所有记录
- 文件操作可直接在 Service 层实现
## 2. MybatisPlus需要写Service层的代码吗？
- **大多数情况下不需要手动写 SQL 或实现方法。**
#### ✅ 使用 MyBatis Plus 后：
- Mapper 接口只需要继承 `BaseMapper<T>`，就可以直接使用以下常见操作：
  - `selectById()`
  - `selectList(null)`（查询所有）
  - `insert()`
  - `updateById()`
  - `deleteById()`
  - 等等
例如：
```java
public interface AdminMapper extends BaseMapper<Admin> {
}
```
这个接口虽然没有任何方法定义，但已经可以完成大部分基本数据库操作。
______
### 📌 什么时候需要自己写？

#### 🔸 1. 自定义 SQL 查询（非通用逻辑）
- 比如你需要根据用户名模糊查询：
```java
List<Admin> selectByUserNameLike(String username);
```
你就需要在 XML 文件中添加 SQL 实现：
```xml
<!-- resources/mapper/AdminMapper.xml -->
<select id="selectByUserNameLike" resultType="org.miii.genzuo.entity.Admin">
    SELECT * FROM admin WHERE username LIKE CONCAT('%', #{username}, '%')
</select>
```
或者用注解方式：
```java
@Select("SELECT * FROM admin WHERE username LIKE CONCAT('%', #{username}, '%')")
List<Admin> selectByUserNameLike(String username);
```
#### 🔸 2. 复杂业务查询（多表关联、聚合函数等）
- 如果涉及多张表或复杂条件，就需要自己编写 SQL 方法。
______
### ✅ 总结流程图：
```
增删改查基本操作
  ↓
MyBatis Plus 可自动处理 → 不需要写代码！

多表联查、聚合统计等自定义复杂查询/功能：
  ↓
需要自己写 SQL（XML 或 注解）→ 需要写代码！
```
## 3. Mybatis Plus 如何实现分页？
- 添加分页插件：
``` java
package org.miii.genzuo.config;  
  
import com.baomidou.mybatisplus.annotation.DbType;  
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;  
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;  
import org.mybatis.spring.annotation.MapperScan;  
import org.springframework.context.annotation.Bean;  
import org.springframework.context.annotation.Configuration;  
  
@Configuration  
@MapperScan("org.miii.genzuo.mapper")  
public class MybatisPlusConfig {  
  
    /**  
     * 添加分页插件  
     */  
    @Bean  
    public MybatisPlusInterceptor mybatisPlusInterceptor() {  
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();  
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL)); // 如果配置多个插件, 切记分页最后添加  
        // 如果有多数据源可以不配具体类型, 否则都建议配上具体的 DbType        return interceptor;  
    }  
}
```
- 修改Service层，添加分页查询方法
``` java
// 接口：分页获取管理员列表  
Page<Admin> getAdminsByPage(Page<Admin> page);
// 实现类：
@Override  
public Page<Admin> getAdminsByPage(Page<Admin> page) {  
    return adminMapper.selectPage(page, null);  
}
// 这里没写QueryWrapper，只是简单的查询
```
- 修改Controller层，调用查询方法，返回到前端
``` java
@GetMapping("/getAdminsByPage")  
public Result getAdminsByPage(@RequestParam Integer pageNum,  
                              @RequestParam Integer pageSize) {  
    Page<Admin> page = new Page<>(pageNum, pageSize);  
    Page<Admin> adminPage = adminService.getAdminsByPage(page);  
    return Result.ok(adminPage);  
}
```
- 前端通过Axios等方法进行数据捕捉、处理与渲染
``` javascript
function fetchData() {  
    request.get('http://localhost:11451/admin/getAdminsByPage', {  
        params: {  
            pageNum: data.pageNum,  
            pageSize: data.pageSize,  
            }  
        }).then(  
        res => {  
            console.log(res)  
            data.tableData = res.data.data.records || [];  
            data.total = res.data.data.total || 0;  
            data.pageNum = res.data.data.current || 0;  
            data.pageSize = res.data.data.size || 0;  
            console.log(data)  
        }  
    ).catch(err => {  
        console.error("请求失败:", err);  
    });  
}  
  
fetchData();  
  
watch(() => [data.pageNum, data.pageSize], () => {  
    fetchData()  
});
```
## 4. 前端渲染不出来数据怎么办？
### 1. 检查一下后端是不是没写对，比如查询条件写没写，条件选择器写没写，分页器配没配置等等，或者是**查询条件的列名写错了**...
``` java
@Override  
public Page<Admin> getAdminsByNameWithPage(Page<Admin> page, Object name) {  
    LambdaQueryWrapper<Admin> adminLambdaQueryWrapper = new LambdaQueryWrapper<>();  
    return adminMapper.selectPage(page, adminLambdaQueryWrapper.like(Admin::getName, name));  // 之前就是name写成username了，查半天查不出来问题在哪...
}
```
### 2. 检查一下Controller层的路径是不是有问题
### 3. 检查一下前后端间的路径连接是不是有问题
``` java
@RequestMapping("/admin")
@GetMapping("/list/page")
// 上面这俩加起来的API访问路径是/admin/list/page
```
### 4. 数据从后端传出来了，前端没有接收到，考虑一下是不是没传参数或者参数衔接出了问题
```javascript
// 根据名称查询管理员  
function getAdminsByName() {  
    const params = {  
        name: data.name,  
        pageNum: data.pageNum,  
        pageSize: data.pageSize,  
    };  
    request.get('http://localhost:11451/admin/list/by-name', { params }).then(  
        res => {  
            const pageData = res.data.data;   
            data.tableData = pageData.records || [];   // 赋值的时候别写错变量了...
            data.total = pageData.total || 0;  
        }  
    ).catch(err => {  
        console.error("请求失败:", err);  
    });  
}
```
### 5. 前端接收到数据，但没渲染出来，考虑是不是数据绑定出现问题了，或者是el-table对应的数据名写错了...
## 5. 为什么添加了字段校验后提交不了表单...
- 检查一下你是不是把`rule`和`ref`位置绑定错了，需要绑定在`el-form`上...
## 6. 如何添加表单及表单验证？
1. 写个表单数据对象出来，顺便把表单规则一块写上：
``` javascript
const data = reactive({  
    formVisible: false,  
    form: {  
        username: null,  
        name: null,  
        password: null,  
        phone: null,  
        email: null,  
    },  
    rules: {  
        username: [   // trigger：触发时间，blur表示输入框失焦时进行验证
            { required: true, message: '用户名不能为空', trigger: 'blur' },  
            { min: 3, max: 255, message: '长度在 3 到 255 个字符', trigger: 'blur' }  
        ],  
        name: [  
            { required: true, message: '姓名不能为空', trigger: 'blur' },  
            { min: 2, max: 255, message: '长度在 2 到 255 个字符', trigger: 'blur' }  
        ],  
        email: [  
            { required: true, message: "邮箱不能为空", trigger: "blur" },  
            {  
                pattern: /^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,  
                message: "邮箱格式不正确",  
                trigger: "blur"  
            }  
        ],  
        phone: [  
            { required: true, message: "限中国大陆手机号，且手机号不能为空", trigger: "blur" },  
            {  
                pattern: /^1[3-9]\d{9}$/,  
                message: "手机号格式不正确",  
                trigger: "blur"  
            }  
        ],  
    }  
})
```
2. 绑定表单及规则：
	- 新建一个变量，将`<el-form>`表单实例的引用绑定到这个变量上，同时将规则绑定到`rules`上。
	- 将表单项的`prop`设置为对应的规则名，不然规则不起效。
	- 将表单数据对象的数据项绑定到输入框中，不然数据传不进来等于白瞎。（`v-model`绑定的数据项名必须与表单数据对象的数据项名一样，不然绑定不了）
``` javascript
const formRef = ref(null);
```
``` vue
<el-dialog v-model="data.formVisible" title="新增管理员信息" width="500">  
    <el-form :model="data.form" :rules="data.rules" ref="formRef" label-width="80px" style="padding: 20px 30px 20px 0">  <!-- 注意rules和ref别绑定错位置了 -->
        <el-form-item label="用户名" prop="username">  
            <el-input v-model="data.form.username"></el-input>  
        </el-form-item>
		<el-form-item label="姓名" prop="name">  
            <el-input v-model="data.form.name" autocomplete="off" />  
        </el-form-item>
		<el-form-item label="密码" prop="password">  
            <el-input v-model="data.form.password" autocomplete="off" />  
        </el-form-item>
		<el-form-item label="手机" prop="phone">  
            <el-input v-model="data.form.phone" autocomplete="off" />  
        </el-form-item> 
		<el-form-item label="邮箱" prop="email">  
            <el-input v-model="data.form.email" autocomplete="off" />  
        </el-form-item>
		</el-form>
	<template #footer>  
        <div class="dialog-footer">  
            <el-button @click="data.formVisible = false">取消</el-button>  
            <el-button type="primary" @click="commitForm()">提交</el-button>  
        </div>
    </template>
</el-dialog>
```
3. 书写提交代码，注意访问的是`表单.value`的`validate()`方法！
``` javascript
async function commitForm() {  
    ElMessageBox.confirm(  
        "是否提交数据？",   // 正文  
        '提交？',          // 标题  
        {  
            distinguishCancelAndClose: false,  
            confirmButtonText: '确定',  
            cancelButtonText: '取消',  
        })  
        .then(() => {  
            ElMessage.info("验证表单数据中");  
            // 表单校验  
            formRef.value.validate(valid => {   // 看这看这看这！！！
                if (valid) {  
                    // 执行提交操作  
                    request.post('/api/admin/list/insertAdmin', data.form)  
                        .then(res => {  
                            // 请求成功，并返回了响应  
                            if (res.data.code === '200') {  
                                ElMessage({ type: 'success', message: '成功提交！' });  
                                data.formVisible = false; // 关闭表单弹窗  
                                getAdmins();              // 刷新表格数据  
                            } else {  
                                ElMessage({ type: 'warning', message: res.data.msg || '提交异常！' });  
                            }  
                        }).catch(err => {  
                        ElMessage({ type: 'error', message: '提交失败！' + err})  
                    });  
                } else {  
                    ElMessage.error("请检查表单内容");  
                    return false;  
                }  
            }).catch(() => {  
                ElMessage.error("请检查表单内容");  
            });  
        }).catch((action) => {  
            ElMessage({  
                type: 'info',  
                message: action === '取消' ? '操作已取消！' : '未执行操作，检查表单数据是否有误！',  
            });  
        });  
}
```
4. 这样就愉快地结束了~
5. **注意**：
	- `el-form`必须有`:model="" :rules="" ref=""`这三个属性，`:model`为整个表单提供了一个“统一的数据源上下文”，`:rules`定义表单字段的校验规则，`ref`获取 `<el-form>` 实例，用于调用方法（如 `.validate()`）
6. **要点补充**：
	- `<el-form :model="data.form">`：告诉 Element Plus 这个表单的数据源是 `data.form`
	- `prop="username"`：告诉 Element Plus 这个表单项对应的是 `data.form.username`
	- `v-model="data.form.username"`：实现输入框与数据的双向绑定。
	- **三者缺一不可**：
		- 没有 `:model`，Element Plus 不知道你要校验哪个对象
		- 没有 `prop`，Element Plus 不知道这个字段对应什么规则
		- 没有 `v-model`，用户输入不会同步到数据模型中
``` vue
<el-form :model="data.form" :rules="data.rules" ref="formRef">
  <el-form-item label="用户名" prop="username">
    <el-input v-model="data.form.username" />
  </el-form-item>
</el-form>
```
## 7. 如何实现Excel批量导入导出

- 我这里实现得比较复杂，根据多选框进行选择项的导出，未选择就是全量导出。
### 导出：
- 先得往项目里导入hutools和poi-ooxml，去官网和mvnrepository看
- 后端代码及步骤如下：
``` java
// 管理员数据导出  
@GetMapping("/list/exportAdmins")  
public void exportAdminsData(@RequestParam(required = false) ArrayList<Integer> ids, HttpServletResponse response) throws Exception {  
    // 1. 拿到管理员数据  
    List<Admin> admins = null;  
    if (ids == null || ids.isEmpty()) {  
        admins = adminService.selectAdmins(null, null);  
    }  
    else {  
        admins = adminService.selectAdminsByID(ids);  
    }  
    // 2. 构建Writer对象  
    ExcelWriter writer = ExcelUtil.getWriter(true);  
    // 3. 设置中文表头  
    writer.addHeaderAlias("username", "用户名");  
    writer.addHeaderAlias("password", "密码");  
    writer.addHeaderAlias("name", "姓名");  
    writer.addHeaderAlias("phone", "手机号");  
    writer.addHeaderAlias("email", "邮箱");  
    // 4. 写入数据  
    writer.setOnlyAlias(true);  
    writer.write(admins, true);  
    // 5. 自动调整每列宽度  
    for (int i = 0; i < 5; i++) {  
        writer.getSheet().autoSizeColumn(i);  
    }  
    // 6. 设置输出文件名称及输出流的头信息（使用URLEncoder，确保网络传输时不会出现乱码）  
    String fileName = URLEncoder.encode("管理员数据", StandardCharsets.UTF_8);  
    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=utf-8");  
    response.setHeader("Content-Disposition", "attachmentw;filename=" + fileName + ".xlsx");  
    // 7. 输出文件（记得关闭输出流）  
    ServletOutputStream os = response.getOutputStream();  
    writer.flush(os);  
    os.close();  
    writer.close();  
}
```
- 前端调用如下：
``` javascript
function exportAdmins() {  
    ElMessageBox.confirm(  
        "确定要继续吗？",   // 正文  
        '批量导出？',              // 标题  
        {  
            distinguishCancelAndClose: false,  
            confirmButtonText: '确定',  
            cancelButtonText:  '取消',  
            type: 'warning',  
        })  
        .then(() => {  
            let url = `/api/admin/list/exportAdmins`;  
            // 根据多选框的选择进行导出，不选择默认进行全量导出
            if(data.rows && data.rows.length > 0) {  
                const ids = data.rows.map(row => encodeURIComponent(row.id)).join(',');  
                url += `?ids=${ids}`;  
            }  
            console.log(url);  
            ElMessage.info("正在导出...");  
            window.open(url);  
        })  
}
```
### 导入：

- 注意：导入时应该使用导出的模板Excel文件
- 后端代码：
``` java
// 批量导入  
@PostMapping("/list/importAdmins")  
public Result<String> importAdmins(MultipartFile file) throws Exception {  
    // 1. 拿到输入流，构建reader  
    file.getInputStream();  
    ExcelReader reader = ExcelUtil.getReader(file.getInputStream());  
    // 2. 通过Reader读取Excel表格中的值  
    reader.addHeaderAlias("用户名", "username");  
    reader.addHeaderAlias("密码", "password");  
    reader.addHeaderAlias("姓名", "name");  
    reader.addHeaderAlias("手机号", "phone");  
    reader.addHeaderAlias("邮箱", "email");  
  
    List<Admin> list = reader.readAll(Admin.class);  
  
    // 3. 将数据写入数据库  
    for(Admin admin : list) {  
        adminService.insertAdmin(admin);  
    }  
    return Result.ok("导入成功");  
}
```
- 前端代码
	- 使用el-upload包裹按钮，实现上传文件的前端封装
``` vue
<div class="card" style="margin-bottom: 5px">  
    <el-button type="primary" @click="handleAdd">新 增</el-button>  
    <el-button type="danger" @click="deleteAdmins">批量删除</el-button>  
    <el-upload        
	    style="display: inline-block; margin: 0 10px"  
        action="/api/admin/list/importAdmins"  // 后端位置
        :show-file-list="false"  
        :limit="1"  
        :on-success="handleUploadSuccess"  
    >  
        <el-button type="success">批量导入</el-button>  
    </el-upload>    <el-button type="info" @click="exportAdmins">批量导出</el-button>  
</div>
```

## 8. 为什么上传第一个文件能正常上传，但上传第二个文件及之后的文件无法上传？
在使用elementUI中的el-upload组件上传文件时，发现一个现象：

第一次上传文件时，可以正常上传（至少可以正常发送请求），第一次上传结束后不论成功或失败，第二次都无法上传（选择好文件后无法向服务端发送请求）。

借鉴其他人的解决方案后定位到原因：当 `ref="upload"` 设置为`upload`后，每一次上传会缓存上传的文件，上传结束后不清除该文件缓存的话就会导致下一次上传不发送请求。

解决办法：在每一次上传请求结束后清除缓存：
``` vue
<el-upload  
    ref="uploadRef"  
    style="display: inline-block; margin: 0 10px"  
    action="/api/admin/list/importAdmins"  
    :show-file-list="false"  
    :limit="1"  
    :on-success="handleUploadSuccess"  
>  
    <el-button type="success">批量导入</el-button>  
</el-upload>
```

``` javascript
const uploadRef = ref(null);

// 批量导入  
const handleUploadSuccess = (res) => {  
    ElMessage.info("正在导入，若数据量大需耐心等待...");  
    if (typeof res === 'string') {  
        ElMessage.error("服务器返回异常：" + res);  
        return;  
    }  
    if(res.code === '200') {  
        ElMessage.success("批量导入成功！");  
        getAdmins();  
    }  
    else {  
        ElMessage.error("批量导入失败：" + res.msg);  
    }  
    uploadRef.value.clearFiles();  // 看这看这看这！！！
}
```
