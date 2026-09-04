# MySQL 入门语法笔记：从建库建表到查询、事务与索引

> **读者定位**：已经知道“数据库用来保存数据”，但对 SQL 语法还不熟，希望通过一套连续示例掌握 MySQL 的常用操作。  
> **阅读主线**：认识 SQL → 建库建表 → 增删改查 → 聚合与多表连接 → 子查询与窗口函数 → 事务 → 索引与权限。  
> **版本基线**：正文以 **MySQL 8.x、InnoDB、`utf8mb4`** 为主；CTE、窗口函数等 MySQL 8.0+ 语法会单独标注。  
> **练习方式**：先执行“演示数据库”一节，再按顺序运行后续查询。涉及修改或删除数据的示例，优先放进事务并使用 `ROLLBACK` 撤销。
> **覆盖边界**：本文所说的“逐项说明”，指正文出现以及入门阶段高频使用的 SQL 关键字、运算符和内置函数；MySQL 还包含复制、空间计算、全文检索、加密、性能模式等大量专用语法，不适合全部塞进入门笔记。
> **条目格式**：重要关键字和函数尽量同时给出“作用、基本写法、适用场景、返回结果或影响、常见陷阱”，避免只给一段代码却不解释为什么这样写。

---

## 先记住这张语法地图

SQL 语句通常分成五类：

| 分类  | 全称                                       | 作用         | 常见语句                                                |
| --- | ---------------------------------------- | ---------- | --------------------------------------------------- |
| DDL | Data Definition Language（**数据定义语言**）     | 定义数据库对象    | `CREATE`、`ALTER`、`DROP`、`TRUNCATE`                  |
| DML | Data Manipulation Language（**数据操作语言**）   | 写入、修改、删除数据 | `INSERT`、`UPDATE`、`DELETE`                          |
| DQL | Data Query Language（**数据查询语言**）          | 查询数据       | `SELECT`                                            |
| TCL | Transaction Control Language（**事务控制语言**） | 控制事务       | `START TRANSACTION`、`COMMIT`、`ROLLBACK`、`SAVEPOINT` |
| DCL | Data Control Language（**数据控制语言**）        | 管理用户和权限    | `CREATE USER`、`GRANT`、`REVOKE`                      |

初学阶段最重要的是掌握以下骨架：

```sql
SELECT 查询列
FROM 表
JOIN 另一张表 ON 连接条件
WHERE 行过滤条件
GROUP BY 分组列
HAVING 分组过滤条件
ORDER BY 排序列
LIMIT 返回行数;
```

可以把它记成：

> **从哪里查 → 怎样连表 → 先筛哪些行 → 怎样分组 → 再筛哪些组 → 怎样排序 → 最终取多少行。**

---

## 目录

1. [SQL 的基本书写规则](#1-sql-的基本书写规则)
2. [准备一套可执行的演示数据库](#2-准备一套可执行的演示数据库)
3. [数据库与表的基本管理](#3-数据库与表的基本管理)
4. [常用数据类型](#4-常用数据类型)
5. [约束与外键](#5-约束与外键)
6. [INSERT：插入数据](#6-insert插入数据)
7. [UPDATE：修改数据](#7-update修改数据)
8. [DELETE、TRUNCATE 与 DROP](#8-deletetruncate-与-drop)
9. [SELECT：基础查询](#9-select基础查询)
10. [WHERE：条件过滤](#10-where条件过滤)
11. [排序、去重与分页](#11-排序去重与分页)
12. [常用函数](#12-常用函数)
13. [聚合与分组](#13-聚合与分组)
14. [多表连接 JOIN](#14-多表连接-join)
15. [子查询、集合操作与 CTE](#15-子查询集合操作与-cte)
16. [窗口函数](#16-窗口函数)
17. [事务](#17-事务)
18. [索引与 EXPLAIN](#18-索引与-explain)
19. [视图与临时表](#19-视图与临时表)
20. [用户与权限](#20-用户与权限)
21. [高频易错点](#21-高频易错点)
22. [核心关键字逐项说明](#22-核心关键字逐项说明)
23. [常用语法速查](#23-常用语法速查)
24. [练习题与参考答案](#24-练习题与参考答案)

重点索引：

- [字符串函数逐项说明](#1211-字符串函数逐项说明)
- [数值函数逐项说明](#1221-数值函数逐项说明)
- [日期时间函数逐项说明](#1231-日期时间函数逐项说明)
- [条件与空值函数逐项说明](#1241-条件与空值函数逐项说明)
- [JSON 函数逐项说明](#1252-json-函数逐项说明)
- [聚合函数逐项说明](#131-常用聚合函数)
- [GROUP BY 聚合语义](#1321-核心语义先分组再让每个组输出一行)
- [窗口函数逐项说明](#161-窗口函数逐项说明)
- [查询与过滤关键字](#221-查询与过滤关键字)
- [DDL 关键字](#225-ddl数据库对象定义关键字)
- [DML 关键字](#227-dml数据写入关键字)
- [事务与锁关键字](#228-事务与锁关键字)

---

## 1. SQL 的基本书写规则

### 1.1 连接后先确认环境

命令行连接：

```bash
mysql -u root -p
```

进入 MySQL 后，可以先执行：

```sql
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS current_database;
SELECT CURRENT_USER() AS authenticated_account;
SELECT @@autocommit AS autocommit_enabled;
SELECT @@sql_mode AS sql_mode;
SELECT @@time_zone AS session_time_zone;
```

### 1.2 分号表示一条语句结束

```sql
SELECT 1 + 2 AS result;
```

SQL 关键字通常不区分大小写，但推荐将关键字大写、表名和列名小写：

```sql
SELECT username, email
FROM users
WHERE status = 1;
```

### 1.3 注释

MySQL 支持三种常见注释：

```sql
-- 双减号后必须至少有一个空白字符
# MySQL 风格的单行注释

/*
  多行注释
*/
```

### 1.4 字符串、标识符与别名

- 字符串使用单引号：`'张三'`；
- 表名、列名等标识符通常直接书写；
- 标识符与保留字冲突时可用反引号，但更推荐直接换名；
- 列别名可使用 `AS`，表别名通常省略 `AS`；
- 表名是否区分大小写受操作系统和服务器配置影响，不要依赖大小写差异设计对象。

```sql
SELECT
    u.username AS user_name,
    u.email AS email_address
FROM users u;
```

不要把字符串写成反引号：

```sql
-- 正确：字符串
SELECT * FROM users WHERE username = '张三';

-- 反引号表示标识符，下面会尝试寻找名为“张三”的列
SELECT * FROM users WHERE username = `张三`;
```

### 1.5 SQL 的书写顺序与大致执行顺序

`SELECT` 写在最前面，但数据库在逻辑上并不是先处理 `SELECT`。不要把“书写位置”和“执行先后”混在一起。

SQL 的书写顺序：

```text
SELECT [DISTINCT]
    -> FROM
    -> JOIN ... ON
    -> WHERE
    -> GROUP BY
    -> HAVING
    -> ORDER BY
    -> LIMIT
```

大致逻辑执行顺序：

```text
FROM
    -> JOIN / ON
    -> WHERE
    -> GROUP BY
    -> HAVING
    -> SELECT
    -> DISTINCT
    -> ORDER BY
    -> LIMIT
```

这里描述的是便于理解 SQL 语义的**逻辑顺序**，不是数据库内部固定不变的物理执行步骤。MySQL 优化器可能在保证结果等价的前提下调整连接顺序、过滤时机和访问方式；真实执行计划应使用 `EXPLAIN` 查看。

这解释了两个常见现象：

1. `WHERE` 一般不能直接使用同层 `SELECT` 中刚定义的别名；
2. `ORDER BY` 通常可以使用 `SELECT` 别名，因为排序发生得更晚。

```sql
SELECT price * stock AS inventory_value
FROM products
WHERE price * stock > 1000
ORDER BY inventory_value DESC;
```

---

## 2. 准备一套可执行的演示数据库

下面使用一个简化的商城模型：

```text
users 1 ─── n orders 1 ─── n order_items n ─── 1 products
用户             订单                订单明细             商品
```

> **安全提示**：只在本地学习环境执行。不要在公司、生产或包含真实数据的数据库中照搬建表和删除命令。

### 2.1 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS mysql_syntax_lab
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE mysql_syntax_lab;

SELECT DATABASE() AS current_database;
```

`utf8mb4` 能完整保存 Unicode 字符，包括常见中文和 Emoji。`utf8mb4_0900_ai_ci` 是 MySQL 8.x 常见排序规则，其中：

- `ai` 表示重音不敏感；
- `ci` 表示大小写不敏感；
- 排序规则会影响字符串比较、排序和唯一约束判断。

### 2.2 创建表

```sql
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    profile JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_username (username),
    UNIQUE KEY uk_users_email (email),
    CONSTRAINT chk_users_status CHECK (status IN (0, 1))
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE products (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    sku VARCHAR(32) NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    attributes JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_products_sku (sku),
    KEY idx_products_category_price (category, price),
    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_status CHECK (status IN (0, 1))
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_no VARCHAR(32) NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_orders_order_no (order_no),
    KEY idx_orders_user_created (user_id, created_at),
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users (id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT chk_orders_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_orders_status
        CHECK (status IN ('pending', 'paid', 'cancelled', 'completed'))
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE order_items (
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,
    PRIMARY KEY (order_id, product_id),
    KEY idx_order_items_product (product_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products (id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (unit_price >= 0)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
```

### 2.3 插入演示数据

以下数据只需执行一次：

```sql
START TRANSACTION;

INSERT INTO users
    (id, username, email, status, profile, created_at)
VALUES
    (1, '张三', 'zhangsan@example.com', 1,
     JSON_OBJECT('city', '北京', 'level', 'vip'),
     '2026-08-01 09:00:00'),
    (2, '李四', 'lisi@example.com', 1,
     JSON_OBJECT('city', '上海', 'level', 'normal'),
     '2026-08-02 10:00:00'),
    (3, '王五', 'wangwu@example.com', 0,
     NULL,
     '2026-08-03 11:00:00'),
    (4, '赵六', 'zhaoliu@example.com', 1,
     JSON_OBJECT('city', '深圳'),
     '2026-08-04 12:00:00');

INSERT INTO products
    (id, sku, name, category, price, stock, status, attributes)
VALUES
    (101, 'KB-001', '机械键盘', '数码', 399.00, 20, 1,
     JSON_OBJECT('switch', '红轴', 'color', '黑色')),
    (102, 'MS-001', '无线鼠标', '数码', 199.00, 50, 1,
     JSON_OBJECT('dpi', 1600, 'color', '白色')),
    (103, 'MN-001', '27 英寸显示器', '数码', 1599.00, 8, 1,
     JSON_OBJECT('resolution', '2K')),
    (104, 'CP-001', '陶瓷咖啡杯', '生活', 69.90, 100, 1,
     JSON_OBJECT('capacity_ml', 350)),
    (105, 'NB-001', '方格笔记本', '文具', 29.90, 0, 0,
     NULL);

INSERT INTO orders
    (id, order_no, user_id, total_amount, status, created_at)
VALUES
    (1001, 'ORD-20260801-001', 1, 598.00, 'paid',
     '2026-08-05 09:30:00'),
    (1002, 'ORD-20260802-001', 1, 1599.00, 'pending',
     '2026-08-06 14:20:00'),
    (1003, 'ORD-20260803-001', 2, 139.80, 'completed',
     '2026-08-07 16:10:00'),
    (1004, 'ORD-20260804-001', 3, 29.90, 'cancelled',
     '2026-08-08 18:00:00');

INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
VALUES
    (1001, 101, 1, 399.00),
    (1001, 102, 1, 199.00),
    (1002, 103, 1, 1599.00),
    (1003, 104, 2, 69.90),
    (1004, 105, 1, 29.90);

COMMIT;
```

### 2.4 验证初始化结果

```sql
SHOW TABLES;

SELECT
    (SELECT COUNT(*) FROM users) AS user_count,
    (SELECT COUNT(*) FROM products) AS product_count,
    (SELECT COUNT(*) FROM orders) AS order_count,
    (SELECT COUNT(*) FROM order_items) AS item_count;
```

预期数量分别为 `4`、`5`、`4`、`5`。

---

## 3. 数据库与表的基本管理

### 3.1 数据库操作

```sql
-- 查看数据库
SHOW DATABASES;

-- 创建数据库
CREATE DATABASE IF NOT EXISTS demo_db
    CHARACTER SET utf8mb4;

-- 切换数据库
USE demo_db;

-- 查看当前数据库
SELECT DATABASE();

-- 删除数据库：数据库内所有对象和数据都会被删除
DROP DATABASE IF EXISTS demo_db;

-- 切回演示数据库
USE mysql_syntax_lab;
```

### 3.2 查看表结构

```sql
SHOW TABLES;

DESCRIBE users;
DESC products;    -- DESCRIBE 的缩写，不是降序的 DESC（Descending）

SHOW CREATE TABLE orders;
SHOW TABLE STATUS LIKE 'orders';
```

`DESCRIBE` 适合快速看列，`SHOW CREATE TABLE` 更适合检查完整建表语句、索引、外键、字符集和存储引擎。

### 3.3 ALTER TABLE

为避免破坏演示主表，下面单独创建一张练习表：

```sql
CREATE TABLE ddl_demo (
    id INT NOT NULL PRIMARY KEY
);

-- 新增列
ALTER TABLE ddl_demo
    ADD COLUMN title VARCHAR(100) NOT NULL AFTER id;

-- 修改列类型或约束；MODIFY 不改列名
ALTER TABLE ddl_demo
    MODIFY COLUMN title VARCHAR(200) NULL;

-- 修改列名
ALTER TABLE ddl_demo
    RENAME COLUMN title TO name;

-- 删除列
ALTER TABLE ddl_demo
    DROP COLUMN name;

-- 修改表名
RENAME TABLE ddl_demo TO ddl_demo_renamed;

DROP TABLE IF EXISTS ddl_demo_renamed;
```

### 3.4 复制表结构或查询结果

LIKE 只复制结构、索引和部分表属性：

```sql
CREATE TABLE users_backup LIKE users;

INSERT INTO users_backup
SELECT * FROM users;

DROP TABLE users_backup;
```

AS SELECT 会根据查询结果创建新表，但结构是推导出的，与原表不一定等同：

```sql
CREATE TABLE paid_orders_snapshot AS
SELECT id, order_no, user_id, total_amount, created_at
FROM orders
WHERE status = 'paid';

DROP TABLE paid_orders_snapshot;
```

注意：`CREATE TABLE ... AS SELECT` 主要复制结果列与数据，**不会自动完整复制原表的主键、索引、外键和所有列属性**。需要完整结构时优先使用 `CREATE TABLE ... LIKE` + `INSERT INTO ... SELECT * FROM ...`。

---

## 4. 常用数据类型

选类型时，先问三个问题：

1. 数据是什么含义？
2. 合法范围有多大？
3. 是否需要精确计算、排序、索引或日期运算？

### 4.1 整数与精确小数

| 类型 | 常见用途 | 备注 |
|---|---|---|
| `TINYINT` | 状态、小范围数字 | `BOOLEAN` 是 `TINYINT(1)` 的同义写法，但不会自动限制为 0/1 |
| `INT` | 数量、普通整数 ID | 可使用 `UNSIGNED` 表示非负范围 |
| `BIGINT` | 大规模主键、计数 | 比 `INT` 占用更多空间 |
| `DECIMAL(p, s)` | 金额、财务数据 | 精确十进制；`p` 是总位数，`s` 是小数位数 |
| `FLOAT / DOUBLE` | 测量值、近似计算 | 二进制浮点数可能存在精度误差 |

金额推荐：

```sql
price DECIMAL(10, 2)
```

不要用 `FLOAT` 保存需要精确相等比较的金额。

### 4.2 字符串、二进制与 JSON

| 类型                   | 常见用途          | 选择要点                     |
| -------------------- | ------------- | ------------------------ |
| `CHAR(n)`            | 真正固定长度的短字符串   | 例如固定格式代码；会按固定长度存储        |
| `VARCHAR(n)`         | 用户名、标题、邮箱、URL | 最常见的变长字符串                |
| `TEXT`               | 文章正文、长文本      | 不适合随意加大范围索引              |
| `BINARY / VARBINARY` | 固定或变长二进制串     | 比较按字节进行                  |
| `BLOB`               | 图片、文件等二进制数据   | 大文件通常更适合对象存储，数据库保存元数据和地址 |
| `JSON`               | 结构会变化的扩展属性    | 可校验 JSON 格式并使用 JSON 函数查询 |

不要因为不想设计字段，就把所有数据都塞进 JSON。需要频繁过滤、连接、排序和约束的核心字段，通常应设计成普通列。

### 4.3 日期与时间

| 类型          | 常见用途      | 关键区别                |
| ----------- | --------- | ------------------- |
| `DATE`      | 生日、业务日期   | 只有日期                |
| `TIME`      | 时长或时间部分   | 只有时间                |
| `DATETIME`  | 创建时间、预约时间 | 保存字面日期时间，不按会话时区自动转换 |
| `TIMESTAMP` | 跨时区事件时间   | 存储与读取时会受会话时区转换影响    |
| `YEAR`      | 年份        | 只保存年份               |

常见定义：

```sql
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL
    DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
```

不要用 `VARCHAR` 保存需要日期计算的时间，否则排序、范围查询、合法性校验和时区处理都会变麻烦。

### 4.4 NULL 的含义

`NULL` 表示“未知、缺失或不适用”，不等于：

- 数字 `0`；
- 空字符串 `''`；
- 字符串 `'NULL'`；
- 布尔假。

字段确实必须有值时使用 `NOT NULL`，并在业务上提供合理默认值或强制调用方传入。

---

## 5. 约束与外键

约束的意义是：即使应用代码写错，数据库仍尽可能拒绝非法数据。

| 约束            | 作用           | 示例                                           |
| ------------- | ------------ | -------------------------------------------- |
| `PRIMARY KEY` | 唯一标识每一行，并且非空 | `PRIMARY KEY (id)`                           |
| `NOT NULL`    | 禁止空值         | `name VARCHAR(100) NOT NULL`                 |
| `UNIQUE`      | 禁止重复值        | `UNIQUE KEY uk_users_email (email)`          |
| `DEFAULT`     | 未传值时使用默认值    | `status TINYINT NOT NULL DEFAULT 1`          |
| `CHECK`       | 检查表达式是否成立    | `CHECK (price >= 0)`                         |
| `FOREIGN KEY` | 保证引用的父记录存在   | `FOREIGN KEY (user_id) REFERENCES users(id)` |

### 5.1 主键与 AUTO_INCREMENT

```sql
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
PRIMARY KEY (id)
```

注意：

- 自增值出现间隙是正常现象，回滚、失败插入、并发和重启都可能造成跳号；
- 不要把“必须连续”当成主键职责；
- 主键适合稳定、短小、不可变，不建议把邮箱等可修改业务字段直接当主键。

### 5.2 唯一约束

```sql
UNIQUE KEY uk_products_sku (sku)
```

唯一索引不仅加速查询，还负责拒绝重复值。是否允许多个 `NULL` 与数据库规则有关；如果字段业务上必须存在，应同时添加 `NOT NULL`。

### 5.3 外键动作

```sql
CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON UPDATE RESTRICT
    ON DELETE CASCADE
```

常见动作：

| 动作 | 含义 |
|---|---|
| `RESTRICT / NO ACTION` | 父记录仍被引用时拒绝修改或删除 |
| `CASCADE` | 父记录变化时级联到子记录 |
| `SET NULL` | 父记录删除或更新后将子表外键设为 `NULL` |

使用 `SET NULL` 时，子表外键列必须允许 `NULL`。使用 `CASCADE` 前必须确认级联删除符合业务含义，避免一次删除扩散到大量数据。

---

## 6. INSERT：插入数据

### 6.1 插入一行

```sql
INSERT INTO users (username, email, status)
VALUES ('孙七', 'sunqi@example.com', 1);

SELECT LAST_INSERT_ID() AS new_user_id;
```

推荐明确写列名，不要依赖表中列的物理顺序。

### 6.2 一次插入多行

```sql
INSERT INTO products (sku, name, category, price, stock)
VALUES
    ('PN-001', '黑色签字笔', '文具', 5.50, 200),
    ('PN-002', '蓝色签字笔', '文具', 5.50, 180);
```

多行插入通常比循环发送多条单行 `INSERT` 更高效，但单批也不要无限增大。

### 6.3 从查询结果插入

```sql
CREATE TABLE active_users LIKE users;

INSERT INTO active_users
SELECT *
FROM users
WHERE status = 1;

DROP TABLE active_users;
```

目标列与查询结果必须在数量、顺序和类型上兼容。更稳妥的写法是两边都明确列：

```sql
INSERT INTO target_users (username, email)
SELECT username, email
FROM users
WHERE status = 1;
```

### 6.4 遇到唯一键冲突时更新

```sql
INSERT INTO products (sku, name, category, price, stock)
VALUES ('KB-001', '机械键盘', '数码', 429.00, 10)
ON DUPLICATE KEY UPDATE
    price = 429.00,
    stock = products.stock + 10;
```

这类语句常被称为 **Upsert**。它依赖主键或唯一键判断冲突。不要用它掩盖数据模型错误，也要确认“冲突时累加库存”确实符合业务规则。

`INSERT IGNORE` 可以跳过部分错误或把错误降为警告，但也可能让数据问题被悄悄忽略，初学阶段不要滥用。

---

## 7. UPDATE：修改数据

基本语法：

```sql
UPDATE 表名
SET 列1 = 新值,
    列2 = 表达式
WHERE 条件;
```

### 7.1 修改指定记录

```sql
UPDATE users
SET email = 'new_zhangsan@example.com'
WHERE id = 1;
```

### 7.2 根据原值计算新值

下面放在事务中观察，最后撤销：

```sql
START TRANSACTION;

UPDATE products
SET price = ROUND(price * 0.90, 2)
WHERE category = '数码'
  AND status = 1;

SELECT id, name, price
FROM products
WHERE category = '数码';

ROLLBACK;
```

### 7.3 多表更新

MySQL 支持连接更新：

```sql
START TRANSACTION;

UPDATE orders o
JOIN users u ON u.id = o.user_id
SET o.status = 'cancelled'
WHERE u.status = 0
  AND o.status = 'pending';

SELECT ROW_COUNT() AS affected_rows;

ROLLBACK;
```

### 7.4 更新前的安全动作

1. 先把同一个 `WHERE` 放进 `SELECT`，确认命中范围；
2. 对重要修改先开事务；
3. 查看 `ROW_COUNT()`；
4. 确认结果后再 `COMMIT`；
5. 不要把事务长时间挂起。

```sql
SELECT id, name, stock
FROM products
WHERE category = '文具';

START TRANSACTION;

UPDATE products
SET stock = stock + 10
WHERE category = '文具';

SELECT ROW_COUNT() AS affected_rows;

ROLLBACK;
```

---

## 8. DELETE、TRUNCATE 与 DROP

### 8.1 DELETE

`DELETE` 删除满足条件的行：

```sql
START TRANSACTION;

DELETE FROM orders
WHERE status = 'cancelled'
  AND created_at < '2027-01-01';

SELECT ROW_COUNT() AS deleted_rows;

ROLLBACK;
```

多表删除语法：

```sql
DELETE oi
FROM order_items oi
JOIN orders o ON o.id = oi.order_id
WHERE o.status = 'cancelled';
```

### 8.2 三者区别

| 语句 | 删除什么 | 支持 `WHERE` | 事务与恢复 | 表结构 |
|---|---|---|---|---|
| `DELETE FROM t WHERE ...` | 指定行 | 支持 | InnoDB 中通常可随事务回滚 | 保留 |
| `TRUNCATE TABLE t` | 全部行 | 不支持 | 属于 DDL，会隐式提交，不能按普通 DML 回滚 | 保留，并通常重置自增计数 |
| `DROP TABLE t` | 表对象及全部数据 | 不支持 | 属于 DDL，会隐式提交 | 删除 |

> **危险提示**：`DELETE FROM table_name;` 没有 `WHERE` 时也会删除全部行。

---

## 9. SELECT：基础查询

### 9.1 查询常量和表达式

```sql
SELECT
    1 + 2 AS sum_result,
    10 / 4 AS division_result,
    CURRENT_DATE AS today,
    NOW() AS `current_time`;
```

### 9.2 查询指定列

```sql
SELECT id, username, email
FROM users;
```

开发代码中不建议长期使用 `SELECT *`：

- 表新增列后返回结构会变化；
- 可能读取不需要的大字段；
- 不利于看出查询真正依赖哪些列；
- 可能降低覆盖索引机会。

### 9.3 使用别名和计算列

```sql
SELECT
    id AS product_id,
    name AS product_name,
    price,
    stock,
    price * stock AS inventory_value
FROM products;
```

计算列只存在于本次查询结果中，不会自动修改表数据。

### 9.4 DISTINCT 去重

```sql
SELECT DISTINCT category
FROM products;
```

多个列一起出现时，对整组列组合去重：

```sql
SELECT DISTINCT category, status
FROM products;
```

---

## 10. WHERE：条件过滤

### 10.1 比较运算

```sql
SELECT id, name, price
FROM products
WHERE price >= 200;
```

常见运算符：

| 运算符               | 含义       |
| ----------------- | -------- |
| `=`               | 等于       |
| `<>` 或 `!=`       | 不等于      |
| `>`、`>=`、`<`、`<=` | 大小比较     |
| `BETWEEN a AND b` | 闭区间，包含两端 |
| `IN (...)`        | 属于给定集合   |
| `LIKE`            | 通配符匹配    |
| `REGEXP`          | 正则匹配     |
| `IS NULL`         | 判断空值     |

### 10.2 BETWEEN 与 IN

```sql
SELECT id, name, price
FROM products
WHERE price BETWEEN 100 AND 500;

SELECT id, order_no, status
FROM orders
WHERE status IN ('paid', 'completed');
```

`BETWEEN 100 AND 500` 等价于 `>= 100 AND <= 500`。

### 10.3 LIKE 与 REGEXP（正则表达式）

`LIKE` 中：

- `%` 匹配任意长度字符；
- `_` 匹配恰好一个字符。

```sql
SELECT id, name
FROM products
WHERE name LIKE '%键盘%';

SELECT id, sku
FROM products
WHERE sku LIKE 'M_-001';

SELECT id, name
FROM products
WHERE name REGEXP '键盘|鼠标|显示器';
```

`LIKE '%关键词'` 这类前导通配符通常难以有效利用普通 B-Tree 索引。

### 10.4 AND、OR 与 NOT

通常优先级是 `NOT` 高于 `AND`，`AND` 高于 `OR`。混合使用时应主动加括号：

```sql
SELECT id, name, category, price
FROM products
WHERE status = 1
  AND (category = '数码' OR price < 100);
```

### 10.5 NULL 判断

错误写法：

```sql
SELECT * FROM users WHERE profile = NULL;
SELECT * FROM users WHERE profile <> NULL;
```

正确写法：

```sql
SELECT * FROM users WHERE profile IS NULL;
SELECT * FROM users WHERE profile IS NOT NULL;
```

MySQL 还提供 NULL 安全等于运算符 `<=>`：

```sql
SELECT
    NULL = NULL AS normal_equal,
    NULL <=> NULL AS null_safe_equal;
```

结果中，普通等号得到 `NULL`，`<=>` 得到 `1`。

### 10.6 NOT IN 与 NULL 陷阱

如果子查询结果中出现 `NULL`，`NOT IN` 可能让所有比较都变成未知：

```sql
-- 容易受到 NULL 影响
SELECT *
FROM users
WHERE id NOT IN (
    SELECT user_id
    FROM orders
);
```

查询“不存在关联记录”时，`NOT EXISTS` 通常语义更稳：

```sql
SELECT u.id, u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
);
```

---

## 11. 排序、去重与分页

### 11.1 ORDER BY

```sql
SELECT id, name, price, stock
FROM products
ORDER BY price DESC, id ASC;
```

- `ASC`：升序，默认值；
- `DESC`：降序；
- 多列排序从左到右依次决定；
- 如果需要稳定分页，应在末尾补充唯一列，例如主键 `id`。

### 11.2 LIMIT

```sql
-- 取前 3 行
SELECT id, name, price
FROM products
ORDER BY price DESC, id ASC
LIMIT 3;

-- 跳过 10 行，再取 5 行
SELECT id, name
FROM products
ORDER BY id
LIMIT 5 OFFSET 10;

-- MySQL 也支持 LIMIT offset, row_count
SELECT id, name
FROM products
ORDER BY id
LIMIT 10, 5;
```

没有 `ORDER BY` 时，数据库不保证每次返回相同顺序。

大偏移量分页可能越来越慢。按主键向后翻页可写成：

```sql
SELECT id, name, price
FROM products
WHERE id > 102
ORDER BY id
LIMIT 2;
```

这类方式常称为游标分页或 Keyset Pagination。

---

## 12. 常用函数

函数可以先分为三类：

| 类型 | 输入与输出粒度 | 典型函数 | 主要用途 |
|---|---|---|---|
| 标量函数 | 每个输入行计算一次，通常每行仍输出一个值 | `CONCAT()`、`ROUND()`、`DATE_ADD()` | 转换、格式化、计算单行数据 |
| 聚合函数 | 多个输入行汇总成一个值 | `COUNT()`、`SUM()`、`AVG()` | 配合 `GROUP BY` 做统计 |
| 窗口函数 | 在相关行集合上计算，但保留每个明细行 | `ROW_NUMBER()`、`RANK()`、`LAG()` | 排名、累计值、同比环比 |

标量函数的一般写法是：

```sql
函数名(参数1, 参数2, ...)
```

函数既可以出现在 `SELECT` 中生成结果列，也可以出现在 `WHERE`、`JOIN ... ON`、`HAVING` 和 `ORDER BY` 中参与条件或排序。不过，对索引列包裹函数可能改变索引使用方式，例如 `DATE(created_at) = '2026-08-01'` 往往不如时间范围条件直接。

### 12.1 字符串函数

```sql
SELECT
    username,
    CONCAT(username, ' <', email, '>') AS contact,
    CONCAT_WS(' / ', username, email) AS contact_with_separator,
    CHAR_LENGTH(username) AS character_count,
    LENGTH(username) AS byte_count,
    SUBSTRING(username, 1, 1) AS first_character,
    UPPER(email) AS upper_email,
    REPLACE(email, 'example.com', 'example.org') AS replaced_email
FROM users;
```

`CHAR_LENGTH()` 返回字符数，`LENGTH()` 返回字节数。对 `utf8mb4` 中文，两者通常不同。

清理空白：

```sql
SELECT
    TRIM('  hello  ') AS both_sides,
    LTRIM('  hello') AS left_side,
    RTRIM('hello  ') AS right_side;
```

#### 12.1.1 字符串函数逐项说明

| 函数与基本写法 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `CONCAT(a, b, ...)` | 按顺序拼接参数 | 组合姓名、地址、展示文本 | 任意参数为 `NULL` 时整个结果为 `NULL` |
| `CONCAT_WS(sep, a, b, ...)` | 使用分隔符拼接 | 生成 `省/市/区`、CSV 风格文本 | 分隔符为 `NULL` 时结果为 `NULL`；后续参数中的 `NULL` 会被跳过 |
| `CHAR_LENGTH(str)` | 返回字符数量 | 校验昵称字符数 | 多字节中文通常也按一个字符计算 |
| `LENGTH(str)` | 返回字节数量 | 估算字节占用、检查协议长度 | 在 `utf8mb4` 下通常不等于字符数 |
| `LOWER(str)` / `LCASE(str)` | 转为小写 | 规范化邮箱或英文编码的展示值 | 比较是否区分大小写主要仍由排序规则决定 |
| `UPPER(str)` / `UCASE(str)` | 转为大写 | 展示英文缩写 | 不应把展示转换误当成唯一性约束 |
| `SUBSTRING(str, pos[, len])` | 从指定位置截取 | 截取前缀、后缀或中间片段 | 位置从 1 开始；负数位置表示从末尾计算 |
| `SUBSTR()` / `MID()` | `SUBSTRING()` 的同义写法 | 兼容已有 SQL | 团队内最好统一一种写法 |
| `LEFT(str, len)` | 取左侧指定字符数 | 获取编码前缀 | `len` 小于等于 0 时返回空串 |
| `RIGHT(str, len)` | 取右侧指定字符数 | 手机号后四位、文件扩展片段 | 只适合展示脱敏，不能代替真正的安全脱敏 |
| `TRIM(str)` | 默认去除首尾空格 | 清洗用户输入 | 不会删除字符串中间的空格 |
| `TRIM(BOTH remstr FROM str)` | 从两端移除指定片段 | 去除首尾特定符号 | 也可使用 `LEADING` 或 `TRAILING` |
| `LTRIM(str)` | 去除左侧空格 | 清理前导空白 | 默认处理空格，不等于通用正则清洗 |
| `RTRIM(str)` | 去除右侧空格 | 清理尾部空白 | `CHAR` 列还涉及尾随空格语义 |
| `REPLACE(str, from, to)` | 替换所有匹配子串 | 域名替换、简单文本清洗 | 是字符串替换，不是正则替换 |
| `INSTR(str, substr)` | 返回子串首次出现位置 | 判断是否包含、定位关键词 | 未找到返回 0；位置从 1 开始 |
| `LOCATE(substr, str[, pos])` | 定位子串，可指定起始位置 | 从指定位置继续查找 | 参数顺序与 `INSTR()` 不同 |
| `SUBSTRING_INDEX(str, delim, count)` | 按分隔符截取 | 提取域名、路径或版本片段 | 正数取左侧，负数取右侧 |
| `LPAD(str, len, padstr)` | 左侧填充到指定长度 | 编号补零 | 目标长度小于原字符串时会截断 |
| `RPAD(str, len, padstr)` | 右侧填充到指定长度 | 定宽展示文本 | 不要用它代替数据类型约束 |
| `REPEAT(str, count)` | 重复字符串 | 构造测试文本、简单掩码 | `count < 1` 时返回空串 |
| `REVERSE(str)` | 反转字符串 | 特殊解析或演示 | 对自然语言通常没有业务意义 |
| `FIND_IN_SET(str, strlist)` | 在逗号分隔字符串中找位置 | 兼容遗留的逗号列表字段 | 正常关系模型应拆成关联表，不建议用它设计新系统 |
| `FORMAT(number, decimals[, locale])` | 按千位分隔格式化数字 | 报表展示 | 返回字符串，不适合继续做数值运算 |
| `REGEXP_LIKE(str, pattern[, match_type])` | 判断是否匹配正则 | 复杂格式检查或搜索 | 返回 1/0；正则通常比等值或前缀查询更昂贵 |
| `REGEXP_REPLACE(str, pattern, repl)` | 正则替换 | 批量清理复杂文本 | 复杂规则应先在测试数据上验证 |
| `REGEXP_SUBSTR(str, pattern)` | 返回第一个匹配片段 | 提取编号或版本 | 无匹配通常返回 `NULL` |

#### 12.1.2 常见应用示例

```sql
SELECT
    CONCAT('订单：', order_no) AS order_label,
    CONCAT_WS(' / ', username,
        JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city'))) AS user_summary,
    CHAR_LENGTH('海豚') AS character_count,
    LENGTH('海豚') AS byte_count,
    SUBSTRING('ORD-20260801-001', 5, 8) AS date_part,
    LEFT('ORD-20260801-001', 3) AS prefix_part,
    RIGHT('13800138000', 4) AS phone_suffix,
    LPAD('42', 6, '0') AS padded_number,
    SUBSTRING_INDEX('api.example.com', '.', -2) AS root_domain;
```

处理可能为 `NULL` 的拼接值时，可以先使用 `COALESCE()`：

```sql
SELECT CONCAT(
    username,
    ' - ',
    COALESCE(JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city')), '城市未知')
) AS display_name
FROM users;
```

### 12.2 数值函数

```sql
SELECT
    ROUND(12.345, 2) AS rounded,
    CEIL(12.1) AS ceiling_value,
    FLOOR(12.9) AS floor_value,
    ABS(-8) AS absolute_value,
    MOD(10, 3) AS remainder;
```

#### 12.2.1 数值函数逐项说明

| 函数与基本写法 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `ABS(x)` | 返回绝对值 | 计算误差或差值大小 | 不保留原符号 |
| `CEIL(x)` / `CEILING(x)` | 向上取整 | 计算至少需要多少页、箱、批次 | `CEIL(-1.2) = -1` |
| `FLOOR(x)` | 向下取整 | 取不超过目标值的最大整数 | `FLOOR(-1.2) = -2` |
| `ROUND(x[, d])` | 四舍五入到 `d` 位 | 金额展示、评分结果 | `d` 可为负数，表示对整数部分取整 |
| `TRUNCATE(x, d)` | 直接截断到 `d` 位 | 不允许四舍五入的截断规则 | 与 `ROUND()` 的业务含义不同 |
| `MOD(n, m)` / `n % m` | 求余数 | 奇偶判断、分桶 | 除数为 0 时结果为 `NULL` |
| `POW(x, y)` / `POWER(x, y)` | 计算幂 | 指数模型、几何计算 | 结果通常是近似数 |
| `SQRT(x)` | 计算平方根 | 距离、统计公式 | 负数输入返回 `NULL` |
| `SIGN(x)` | 返回符号：-1、0 或 1 | 判断增长、下降、持平 | 比多次比较更适合生成方向标签 |
| `RAND([seed])` | 返回 0 到 1 之间的随机数 | 抽样、生成演示数据 | 不适合密码和令牌；`ORDER BY RAND()` 在大表上代价高 |
| `GREATEST(a, b, ...)` | 返回参数最大值 | 计算多个候选值中的下限保护结果 | 任意参数为 `NULL` 时通常得到 `NULL`，可先 `COALESCE()` |
| `LEAST(a, b, ...)` | 返回参数最小值 | 封顶金额、取多个时间中的最早值 | 参数类型转换会影响比较方式 |

```sql
SELECT
    ROUND(1599.456, 2) AS rounded_price,
    TRUNCATE(1599.456, 2) AS truncated_price,
    CEIL(101 / 20) AS required_pages,
    MOD(17, 2) AS is_odd,
    POW(2, 10) AS two_to_ten,
    SQRT(81) AS square_root,
    SIGN(-35) AS change_direction,
    GREATEST(0, -8) AS non_negative_value,
    LEAST(100, 135) AS capped_value;
```

分页数量的典型写法：

```sql
SELECT CEIL(COUNT(*) / 20.0) AS total_pages
FROM products;
```

这里使用 `20.0` 是为了明确进行非整数除法，再向上取整。

### 12.3 日期时间函数

```sql
SELECT
    NOW() AS current_datetime,
    CURDATE() AS current_date,
    CURTIME() AS current_time,
    DATE_ADD(NOW(), INTERVAL 7 DAY) AS seven_days_later,
    DATE_SUB(NOW(), INTERVAL 1 MONTH) AS one_month_ago,
    DATEDIFF('2026-08-18', '2026-08-01') AS day_difference,
    TIMESTAMPDIFF(HOUR, '2026-08-18 08:00:00',
                        '2026-08-18 12:30:00') AS hour_difference;
```

按月份统计时常用 `DATE_FORMAT`：

```sql
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS order_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m');
```

如果需要高效利用时间列索引，范围查询通常比对列调用函数更友好：

```sql
-- 更适合已有 created_at 索引
SELECT *
FROM orders
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01';
```

#### 12.3.1 日期时间函数逐项说明

| 函数与基本写法 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `NOW()` / `CURRENT_TIMESTAMP` | 返回当前会话日期时间 | 写入创建时间、计算截止时间 | 同一条语句内通常保持同一个当前时间值 |
| `CURDATE()` / `CURRENT_DATE` | 返回当前日期 | 查询今天的数据 | 不包含时分秒 |
| `CURTIME()` / `CURRENT_TIME` | 返回当前时间 | 展示当前时刻的时间部分 | 不包含日期 |
| `UTC_TIMESTAMP()` | 返回当前 UTC 日期时间 | 跨时区系统统一时间基准 | 展示给用户前通常需要时区转换 |
| `DATE(expr)` | 提取日期部分 | 从日期时间中取年月日 | 在索引列上直接使用可能影响范围查询效率 |
| `TIME(expr)` | 提取时间部分 | 从日期时间中取时分秒 | 返回值不包含日期 |
| `YEAR(date)` | 提取年份 | 年度报表 | 可读性高，但过滤时常优先使用范围 |
| `MONTH(date)` | 提取月份数字 | 月份统计 | 跨年统计时不能只按月份分组 |
| `DAY(date)` / `DAYOFMONTH(date)` | 提取月内日期 | 日维度展示 | 返回 1 到 31 |
| `EXTRACT(unit FROM date)` | 按单位提取时间部分 | 统一提取年、月、日、小时 | `unit` 是语法单位，不是字符串参数 |
| `DATE_ADD(date, INTERVAL n unit)` | 日期增加一个时间间隔 | 到期时间、七天后 | 月末加月需要注意不同月份天数 |
| `DATE_SUB(date, INTERVAL n unit)` | 日期减去一个时间间隔 | 最近 30 天、一个月前 | “最近一个月”与“最近 30 天”含义不同 |
| `DATEDIFF(a, b)` | 返回 `a - b` 的日期天数 | 计算相隔天数 | 忽略参数中的时分秒 |
| `TIMESTAMPDIFF(unit, a, b)` | 按指定单位返回 `b - a` | 计算年龄、耗时、完整月份数 | 只统计完整单位，参数方向与 `DATEDIFF()` 容易混淆 |
| `DATE_FORMAT(date, format)` | 把日期格式化成字符串 | 展示年月、报表标签 | 返回字符串；不要用展示格式替代原始时间列 |
| `STR_TO_DATE(str, format)` | 按格式把字符串解析为日期 | 导入文本日期 | 输入与格式不匹配可能得到 `NULL` 或错误 |
| `LAST_DAY(date)` | 返回所在月份最后一天 | 月结、账期截止日 | 返回日期值 |
| `UNIX_TIMESTAMP([date])` | 转为 Unix 时间戳秒数 | 与外部协议交换时间 | 受时区和可表示范围影响 |
| `FROM_UNIXTIME(seconds[, format])` | 时间戳转日期时间或格式化文本 | 读取外部时间戳 | 带格式参数时返回格式化字符串 |

#### 12.3.2 日期查询与格式化示例

```sql
SELECT
    NOW() AS local_now,
    UTC_TIMESTAMP() AS utc_now,
    DATE(NOW()) AS date_part,
    TIME(NOW()) AS time_part,
    EXTRACT(YEAR_MONTH FROM NOW()) AS year_month_number,
    LAST_DAY(NOW()) AS month_end,
    DATE_ADD(NOW(), INTERVAL 2 HOUR) AS two_hours_later,
    STR_TO_DATE('2026/09/02 18:30', '%Y/%m/%d %H:%i') AS parsed_time;
```

常用格式符：

| 格式符 | 含义 | 示例 |
|---|---|---|
| `%Y` | 四位年份 | `2026` |
| `%m` | 两位月份 | `09` |
| `%d` | 两位日期 | `02` |
| `%H` | 24 小时制小时 | `18` |
| `%i` | 分钟 | `30` |
| `%s` | 秒 | `45` |

注意分钟是 `%i`，不是容易误写的 `%m`；`%m` 表示月份。

查询某一天，推荐半开区间：

```sql
SELECT id, order_no, created_at
FROM orders
WHERE created_at >= '2026-08-05 00:00:00'
  AND created_at <  '2026-08-06 00:00:00';
```

半开区间不依赖字段是否保存微秒，也比写 `23:59:59` 更稳。

### 12.4 NULL 与条件函数

```sql
SELECT
    username,
    IFNULL(
        JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city')),
        '未知'
    ) AS city
FROM users;
```

常见函数：

| 函数 | 作用 |
|---|---|
| `IF(condition, a, b)` | 条件成立返回 `a`，否则返回 `b` |
| `IFNULL(value, fallback)` | `value` 为 `NULL` 时返回后备值 |
| `COALESCE(a, b, c)` | 返回第一个非 `NULL` 值 |
| `NULLIF(a, b)` | `a = b` 时返回 `NULL`，否则返回 `a` |

`CASE` 更通用：

```sql
SELECT
    order_no,
    status,
    CASE status
        WHEN 'pending' THEN '待支付'
        WHEN 'paid' THEN '已支付'
        WHEN 'completed' THEN '已完成'
        WHEN 'cancelled' THEN '已取消'
        ELSE '未知状态'
    END AS status_text
FROM orders;
```

范围判断使用搜索式 `CASE`：

```sql
SELECT
    name,
    price,
    CASE
        WHEN price >= 1000 THEN '高价'
        WHEN price >= 100 THEN '中价'
        ELSE '低价'
    END AS price_level
FROM products;
```

#### 12.4.1 条件与空值函数逐项说明

| 函数或表达式 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `IF(condition, true_value, false_value)` | 二选一 | 简单状态映射 | MySQL 专用函数；复杂分支优先 `CASE` |
| `IFNULL(value, fallback)` | `value` 为 `NULL` 时返回后备值 | 将空统计显示为 0 | 只能提供一个后备值 |
| `COALESCE(a, b, ...)` | 返回第一个非 `NULL` 参数 | 多级默认值 | 属于标准 SQL，参数可以有多个 |
| `NULLIF(a, b)` | 两值相等返回 `NULL`，否则返回 `a` | 避免除零、把特殊值转为空 | 可配合 `value / NULLIF(divisor, 0)` |
| `ISNULL(expr)` | 参数为 `NULL` 返回 1，否则返回 0 | 生成空值标记 | 不要和标准判断语法 `expr IS NULL` 混淆 |
| `CASE expr WHEN value THEN result ... END` | 按离散值分支 | 状态码映射 | 称为简单 `CASE` |
| `CASE WHEN condition THEN result ... END` | 按多个条件分支 | 分段、条件聚合 | 从上到下命中第一个成立分支 |

#### 12.4.2 使用场景

避免除零：

```sql
SELECT
    total_amount,
    quantity,
    total_amount / NULLIF(quantity, 0) AS average_amount
FROM (
    SELECT 100.00 AS total_amount, 0 AS quantity
) sample;
```

多级后备值：

```sql
SELECT
    username,
    COALESCE(
        JSON_UNQUOTE(JSON_EXTRACT(profile, '$.nickname')),
        username,
        '匿名用户'
    ) AS display_name
FROM users;
```

条件聚合：

```sql
SELECT
    user_id,
    SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_count,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count
FROM orders
GROUP BY user_id;
```

### 12.5 JSON 函数

```sql
SELECT
    username,
    JSON_EXTRACT(profile, '$.city') AS city_json,
    JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city')) AS city_text
FROM users;

SELECT
    name,
    JSON_UNQUOTE(JSON_EXTRACT(attributes, '$.color')) AS color
FROM products
WHERE JSON_EXTRACT(attributes, '$.color') IS NOT NULL;
```

生成修改后的 JSON，不更新原表：

```sql
SELECT JSON_SET(
    JSON_OBJECT('city', '北京'),
    '$.level',
    'vip'
) AS new_profile;
```

#### 12.5.1 JSON 路径基础

JSON 路径通常从 `$` 开始：

| 路径 | 含义 |
|---|---|
| `$` | 整个 JSON 文档 |
| `$.city` | 对象的 `city` 成员 |
| `$.address.province` | 嵌套对象成员 |
| `$[0]` | 数组第一个元素 |
| `$.tags[1]` | `tags` 数组第二个元素 |

#### 12.5.2 JSON 函数逐项说明

| 函数与基本写法 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `JSON_OBJECT(key, value, ...)` | 创建 JSON 对象 | 构造扩展属性或 API 结果 | 键名与值成对出现 |
| `JSON_ARRAY(value, ...)` | 创建 JSON 数组 | 聚合前构造数组、保存标签 | SQL `NULL` 会成为 JSON `null` |
| `JSON_EXTRACT(doc, path[, ...])` | 按路径读取 JSON 值 | 查询城市、规格等扩展字段 | 返回 JSON 值，字符串通常带 JSON 引号 |
| `doc -> path` | `JSON_EXTRACT()` 的简写 | 快速提取 JSON 值 | 路径写成字符串字面量 |
| `doc ->> path` | 提取并取消 JSON 引号 | 直接得到可展示字符串 | 等价于提取后再 `JSON_UNQUOTE()` |
| `JSON_UNQUOTE(value)` | 去掉 JSON 字符串引号与转义 | 把 `"北京"` 变为 `北京` | 非字符串 JSON 值按规则转换 |
| `JSON_SET(doc, path, value, ...)` | 新增不存在成员并覆盖已存在成员 | 通用 JSON 更新 | 同时具备插入和替换语义 |
| `JSON_INSERT(doc, path, value, ...)` | 只在路径不存在时插入 | 设置一次性的默认成员 | 已存在路径保持原值 |
| `JSON_REPLACE(doc, path, value, ...)` | 只替换已存在路径 | 只允许修改既有字段 | 路径不存在时不新增 |
| `JSON_REMOVE(doc, path, ...)` | 删除指定成员 | 删除废弃扩展属性 | 返回新 JSON；不会自动更新原列 |
| `JSON_CONTAINS(target, candidate[, path])` | 判断是否包含候选 JSON | 检查数组是否包含标签 | 候选参数必须是合法 JSON 值 |
| `JSON_CONTAINS_PATH(doc, one_or_all, path, ...)` | 判断路径是否存在 | 区分缺少成员与成员值为空 | `'one'` 表示任一路径存在，`'all'` 表示全部存在 |
| `JSON_LENGTH(doc[, path])` | 返回对象成员数或数组元素数 | 检查标签数量 | 标量值长度为 1 |
| `JSON_KEYS(doc[, path])` | 返回对象键名数组 | 检查动态字段 | 目标不是对象时可能返回 `NULL` |
| `JSON_TYPE(value)` | 返回 JSON 类型名称 | 数据质量检查 | 可能返回 `OBJECT`、`ARRAY`、`STRING` 等 |
| `JSON_VALID(str)` | 判断字符串是不是合法 JSON | 导入前校验文本 | 真返回 1，假返回 0 |
| `JSON_ARRAY_APPEND(doc, path, value, ...)` | 向数组尾部追加元素 | 追加标签或事件 | 若路径值不是数组，行为需要先验证 |
| `JSON_MERGE_PATCH(doc1, doc2, ...)` | 按合并补丁语义合并对象 | 合并部分更新请求 | 对象中的 JSON `null` 可能表示删除成员 |

#### 12.5.3 JSON 查询与修改示例

```sql
SELECT
    username,
    profile -> '$.city' AS city_json,
    profile ->> '$.city' AS city_text,
    JSON_TYPE(profile) AS profile_type,
    JSON_CONTAINS_PATH(profile, 'one', '$.city', '$.level') AS has_any_key
FROM users;
```

比较三种修改函数：

```sql
SET @profile = JSON_OBJECT('city', '北京');

SELECT
    JSON_SET(@profile, '$.city', '上海', '$.level', 'vip') AS set_result,
    JSON_INSERT(@profile, '$.city', '上海', '$.level', 'vip') AS insert_result,
    JSON_REPLACE(@profile, '$.city', '上海', '$.level', 'vip') AS replace_result;
```

真正更新列时必须写 `UPDATE`：

```sql
START TRANSACTION;

UPDATE users
SET profile = JSON_SET(
    COALESCE(profile, JSON_OBJECT()),
    '$.city',
    '广州'
)
WHERE id = 3;

SELECT id, username, profile
FROM users
WHERE id = 3;

ROLLBACK;
```

### 12.6 信息、连接与执行结果函数

| 函数 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `VERSION()` | 返回服务器版本字符串 | 排查版本兼容问题 | 客户端版本与服务器版本可能不同 |
| `DATABASE()` | 返回当前默认数据库 | 检查 `USE` 是否正确 | 未选择数据库时返回 `NULL` |
| `CURRENT_USER()` | 返回权限检查使用的认证账号 | 排查授权命中哪个账户 | 可能与客户端声明的登录账号不同 |
| `USER()` / `SESSION_USER()` | 返回客户端提供的用户和来源主机 | 排查连接来源 | 不等同于权限匹配后的 `CURRENT_USER()` |
| `CONNECTION_ID()` | 返回当前连接 ID | 定位会话、排查阻塞 | 每个连接不同 |
| `LAST_INSERT_ID()` | 返回当前连接最近生成的自增值 | 插入主表后创建子表记录 | 是连接级状态，应在同一连接中立即读取 |
| `ROW_COUNT()` | 返回上一条 DML 影响行数 | 判断更新库存是否成功 | 必须紧跟目标 DML；不要先执行其他语句 |
| `UUID()` | 生成 UUID 字符串 | 外部标识、幂等键 | 直接作为长字符串聚簇主键可能增加索引成本 |

```sql
SELECT
    VERSION() AS server_version,
    DATABASE() AS current_database,
    USER() AS client_user,
    CURRENT_USER() AS privilege_account,
    CONNECTION_ID() AS connection_id,
    UUID() AS generated_uuid;
```

`LAST_INSERT_ID()` 示例：

```sql
START TRANSACTION;

INSERT INTO users (username, email)
VALUES ('测试用户', 'test-user@example.com');

SET @new_user_id = LAST_INSERT_ID();

SELECT @new_user_id AS inserted_user_id;

ROLLBACK;
```

`ROW_COUNT()` 示例：

```sql
START TRANSACTION;

UPDATE products
SET stock = stock - 1
WHERE id = 101
  AND stock > 0;

SELECT ROW_COUNT() AS affected_rows;

ROLLBACK;
```

---

## 13. 聚合与分组

### 13.1 常用聚合函数

聚合函数读取一组输入行，并为这一组产生一个统计值。除 `COUNT(*)` 外，多数常用聚合函数都会忽略 `NULL`。

| 函数与基本写法 | 作用 | 典型应用 | 空值与边界 |
|---|---|---|---|
| `COUNT(*)` | 统计组内结果行数 | 订单数、用户数 | 统计行，不关心列是否为 `NULL` |
| `COUNT(expr)` | 统计 `expr` 非 `NULL` 的行数 | 已填写手机号人数、左连接匹配数 | `NULL` 不计数 |
| `COUNT(DISTINCT expr)` | 统计不同的非空值数量 | 下单用户数、商品类别数 | 先忽略 `NULL`，再去重计数 |
| `SUM(expr)` | 对非空数值求和 | 销售额、库存总数 | 没有非空输入时返回 `NULL` |
| `AVG(expr)` | 对非空数值求平均值 | 平均客单价、平均分 | 分母是非空值数量，不是 `COUNT(*)` |
| `MIN(expr)` | 返回最小非空值 | 最低价、最早时间 | 可用于数字、日期、字符串 |
| `MAX(expr)` | 返回最大非空值 | 最高价、最晚时间 | 可用于数字、日期、字符串 |
| `GROUP_CONCAT(expr)` | 把组内值连接为字符串 | 展示一个订单的商品名列表 | 默认逗号分隔，结果长度受 `group_concat_max_len` 限制 |
| `JSON_ARRAYAGG(expr)` | 把组内值聚合为 JSON 数组 | 构造 JSON 接口结果 | 元素顺序不能在没有明确保证时依赖 |
| `JSON_OBJECTAGG(key, value)` | 把组内键值聚合为 JSON 对象 | 构造属性映射 | 键不能为 `NULL`；重复键的保留结果应避免依赖 |
| `ANY_VALUE(expr)` | 告诉 MySQL 接受一个任意组内值 | 处理已确认无歧义但优化器无法证明的列 | 不会替你选择“第一行”或“最后一行”，不能滥用 |

```sql
SELECT
    COUNT(*) AS all_users,
    COUNT(profile) AS users_with_profile,
    COUNT(DISTINCT status) AS distinct_status_count
FROM users;
```

聚合函数的常见应用：

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    COUNT(DISTINCT status) AS status_kind_count,
    SUM(stock) AS total_stock,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    GROUP_CONCAT(
        name
        ORDER BY price DESC
        SEPARATOR '、'
    ) AS product_names
FROM products
GROUP BY category;
```

`COUNT(*)` 与 `COUNT(column)` 的差别在外连接中尤其重要：

```sql
SELECT
    u.id,
    u.username,
    COUNT(*) AS joined_row_count,
    COUNT(o.id) AS matched_order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.username;
```

没有订单的用户也会被 `LEFT JOIN` 保留一条右侧为 `NULL` 的占位行，因此：

- `COUNT(*)` 会把占位行算作 1；
- `COUNT(o.id)` 忽略 `NULL`，正确得到 0；
- 统计右表匹配记录时，最好选择右表一个保证非空的主键或唯一键。

### 13.2 GROUP BY

#### 13.2.1 核心语义：先分组，再让每个组输出一行

`GROUP BY` 不是简单的“删除重复行”，而是按照分组表达式构造若干组。可以把每个组理解成一个桶：

```text
输入明细行
  ├─ 分组键 = 数码 ──► 机械键盘、无线鼠标、显示器
  ├─ 分组键 = 生活 ──► 陶瓷咖啡杯
  └─ 分组键 = 文具 ──► 方格笔记本
```

执行：

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM products
GROUP BY category;
```

结果粒度从“一个商品一行”变成“一个类别一行”：

```text
数码组 ──► 数码 | 3 | 732.33...
生活组 ──► 生活 | 1 | 69.90
文具组 ──► 文具 | 1 | 29.90
```

所谓多行“坍缩”为一行，准确含义是：

> 分组列值相同的明细行属于同一组；查询结果不再描述每条明细，而是用一行描述整个组。

SQL 默认保留重复行的多重性。组内即使有完全相同的两行，`COUNT(*)` 仍会把它们算作两行；只有使用 `DISTINCT` 或 `COUNT(DISTINCT ...)` 时才显式去重。

#### 13.2.2 四种组合必须分清

| `GROUP BY` | 聚合函数 | 输出粒度 | 示例语义 |
|---|---|---|---|
| 无 | 无 | 通常一条输入行对应一条输出行 | 查询商品明细 |
| 无 | 有 | 所有输入行构成一个隐式大组，输出一行 | 统计全表商品数 |
| 有 | 无 | 每个不同分组键输出一行 | 只列出所有类别，效果常类似 `DISTINCT` |
| 有 | 有 | 每个分组输出一行，并携带组内统计值 | 统计每类商品数量与均价 |

```sql
-- 无 GROUP BY、无聚合：返回每个商品
SELECT id, category, name
FROM products;

-- 无 GROUP BY、有聚合：整个结果作为一个组
SELECT COUNT(*) AS all_product_count
FROM products;

-- 有 GROUP BY、无聚合：每个类别一行，组内行数信息被丢弃
SELECT category
FROM products
GROUP BY category;

-- 有 GROUP BY、有聚合：每个类别一行，并保留统计信息
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category;
```

只选择分组列时：

```sql
SELECT category
FROM products
GROUP BY category;
```

可见结果通常与下列语句相同：

```sql
SELECT DISTINCT category
FROM products;
```

但语义侧重点不同：

- `DISTINCT` 对最终选择出来的结果行去重；
- `GROUP BY` 先建立组，可以继续计算聚合值或使用 `HAVING`；
- 不带聚合函数的 `GROUP BY` 仍然创建组，只是没有读取组内统计信息。

#### 13.2.3 聚合的逻辑执行模型

可以用下面的伪代码理解：

```text
groups = 空映射

for 每一条经过 FROM、JOIN、WHERE 后的行 row:
    key = 计算 GROUP BY 分组键
    state = groups 中 key 对应的聚合状态

    state.count += 1
    state.sum += row.price
    state.min = min(state.min, row.price)
    state.max = max(state.max, row.price)

for 每一个 key:
    输出 key 和该组最终聚合值
```

`AVG(price)` 在概念上可以通过两个状态完成：

```text
sum   = 组内非 NULL price 之和
count = 组内非 NULL price 数量
avg   = sum / count
```

物理执行并不一定真的使用上述程序。MySQL 可能利用索引顺序聚合，也可能使用内部临时表或排序；优化器可以改变物理步骤，但必须保持相同的分组语义。真实方式使用 `EXPLAIN` 检查。

#### 13.2.4 逐步分析“每个学生参加每科考试次数”

```sql
SELECT
    s.student_id,
    s.student_name,
    sub.subject_name,
    COUNT(e.subject_name) AS attended_exams
FROM Students s
CROSS JOIN Subjects sub
LEFT JOIN Examinations e
    ON s.student_id = e.student_id
   AND sub.subject_name = e.subject_name
GROUP BY
    s.student_id,
    s.student_name,
    sub.subject_name
ORDER BY
    s.student_id,
    sub.subject_name;
```

假设：

```text
Students
1 | Alice
2 | Bob

Subjects
Math
Physics

Examinations
1 | Math
1 | Math
1 | Physics
2 | Math
```

第一步，`Students CROSS JOIN Subjects` 生成完整网格：

```text
1 | Alice | Math
1 | Alice | Physics
2 | Bob   | Math
2 | Bob   | Physics
```

第二步，`LEFT JOIN Examinations` 挂上考试明细。匹配几次就展开成几行；完全没匹配也保留一条右侧为 `NULL` 的占位行：

```text
1 | Alice | Math    | Math
1 | Alice | Math    | Math
1 | Alice | Physics | Physics
2 | Bob   | Math    | Math
2 | Bob   | Physics | NULL
```

第三步，`GROUP BY student_id, student_name, subject_name` 按“一个学生的一门科目”分桶：

```text
(1, Alice, Math)    ──► 2 行
(1, Alice, Physics) ──► 1 行
(2, Bob, Math)      ──► 1 行
(2, Bob, Physics)   ──► 1 条 NULL 占位行
```

第四步，`COUNT(e.subject_name)` 只统计组内非 `NULL` 值：

```text
1 | Alice | Math    | 2
1 | Alice | Physics | 1
2 | Bob   | Math    | 1
2 | Bob   | Physics | 0
```

这里不能改成 `COUNT(*)`。Bob + Physics 组虽然没有考试，但 `LEFT JOIN` 已补出一行，`COUNT(*)` 会得到 1；`COUNT(e.subject_name)` 因该列为 `NULL` 才得到 0。如果考试表有保证非空的 `exam_id`，写 `COUNT(e.exam_id)` 会更明确。

这条语句可以概括为：

> `CROSS JOIN` 建完整组合，`LEFT JOIN` 挂考试明细并保留零次组合，`GROUP BY` 收拢到“学生 × 科目”粒度，`COUNT` 计算每组真实匹配数。

#### 13.2.5 GROUP BY 对 NULL 的处理

在普通比较中，`NULL = NULL` 的结果是未知；但在分组语义中，多个 `NULL` 会被归入同一个组：

```sql
SELECT
    JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city')) AS city,
    COUNT(*) AS user_count
FROM users
GROUP BY JSON_UNQUOTE(JSON_EXTRACT(profile, '$.city'));
```

这不代表 `NULL` 彼此相等，只是 SQL 的分组规则把它们视为同一分组类别。

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    SUM(stock) AS total_stock
FROM products
WHERE status = 1
GROUP BY category
ORDER BY average_price DESC;
```

`WHERE` 在分组前过滤行，`HAVING` 在分组后过滤组：

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM products
WHERE status = 1
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY average_price DESC;
```

`WHERE` 与 `HAVING` 的职责：

| 子句 | 过滤对象 | 逻辑时机 | 能否直接使用聚合函数 |
|---|---|---|---|
| `WHERE` | 分组前的明细行 | `GROUP BY` 之前 | 不能 |
| `HAVING` | 已形成的分组 | `GROUP BY` 之后 | 可以 |

能在 `WHERE` 提前排除的数据，通常不要全部留给 `HAVING`，因为提前减少输入行往往更清晰，也更有利于执行。

### 13.3 条件聚合

条件聚合并不是新的函数，而是把 `CASE` 放进 `SUM()`、`COUNT()` 等聚合函数中，让不同条件的行贡献不同数值。

```sql
SELECT
    user_id,
    COUNT(*) AS all_order_count,
    SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_count,
    SUM(CASE
            WHEN status IN ('paid', 'completed')
            THEN total_amount
            ELSE 0
        END) AS effective_amount
FROM orders
GROUP BY user_id;
```

三种常见写法：

```sql
SELECT
    user_id,

    -- 满足条件贡献 1，否则贡献 0
    SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_count,

    -- 只有满足条件时产生非 NULL，COUNT 才会计数
    COUNT(CASE WHEN status = 'paid' THEN 1 END) AS paid_count_by_count,

    -- 满足条件才贡献金额
    SUM(CASE
            WHEN status IN ('paid', 'completed')
            THEN total_amount
            ELSE 0
        END) AS effective_amount
FROM orders
GROUP BY user_id;
```

必须考虑 `ELSE`：

- `ELSE 0` 适合计数或求和，让不满足条件的行贡献 0；
- 省略 `ELSE` 时默认返回 `NULL`；
- `COUNT(expr)` 忽略 `NULL`，因此省略 `ELSE` 可用于条件计数；
- `SUM()` 如果整组全是 `NULL`，结果也是 `NULL`，可能需要外层 `COALESCE(..., 0)`。

### 13.4 ONLY_FULL_GROUP_BY

MySQL 8.x 常见默认 SQL 模式包含 `ONLY_FULL_GROUP_BY`。启用后，查询列通常必须：

- 出现在 `GROUP BY` 中；
- 或被聚合函数包裹；
- 或能被数据库证明由分组列唯一决定。

错误或含义不明确的写法：

```sql
SELECT category, name, AVG(price)
FROM products
GROUP BY category;
```

一个类别有多个商品，数据库无法确定应该展示哪个 `name`。应改成聚合结果，或使用窗口函数明确选择规则。

---

## 14. 多表连接 JOIN

### 14.1 INNER JOIN

只保留两边都匹配的行：

```sql
SELECT
    o.order_no,
    u.username,
    o.total_amount,
    o.status
FROM orders o
INNER JOIN users u ON u.id = o.user_id
ORDER BY o.created_at;
```

`INNER` 可以省略：

```sql
SELECT o.order_no, u.username
FROM orders o
JOIN users u ON u.id = o.user_id;
```

### 14.2 LEFT JOIN

保留左表全部行，右表无匹配时补 `NULL`：

```sql
SELECT
    u.id,
    u.username,
    COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.username
ORDER BY u.id;
```

赵六没有订单，但仍会出现在结果中，`order_count` 为 `0`。

### 14.3 ON 与 WHERE 的位置很重要

查询所有用户，并只连接已支付订单：

```sql
SELECT
    u.username,
    o.order_no
FROM users u
LEFT JOIN orders o
    ON o.user_id = u.id
   AND o.status = 'paid';
```

如果把右表条件放到 `WHERE`：

```sql
SELECT
    u.username,
    o.order_no
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.status = 'paid';
```

没有已支付订单的用户会因为 `WHERE` 条件被过滤，效果接近内连接。

### 14.4 多表连接

```sql
SELECT
    o.order_no,
    u.username,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.subtotal
FROM orders o
JOIN users u ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
ORDER BY o.id, p.id;
```

### 14.5 自连接

同一张表使用不同别名进行连接。下面找出同类别的商品组合：

```sql
SELECT
    p1.category,
    p1.name AS product_a,
    p2.name AS product_b
FROM products p1
JOIN products p2
    ON p2.category = p1.category
   AND p2.id > p1.id
ORDER BY p1.category, p1.id, p2.id;
```

`p2.id > p1.id` 用来避免商品与自己连接，并去掉对称重复组合。

### 14.6 CROSS JOIN

返回笛卡尔积：

```sql
SELECT u.username, p.name
FROM users u
CROSS JOIN products p;
```

如果左表有 4 行、右表有 5 行，结果就是 20 行。遗漏连接条件也可能意外产生巨大笛卡尔积。

### 14.7 RIGHT JOIN 与 FULL OUTER JOIN

`RIGHT JOIN` 保留右表全部行，但一般可以交换表顺序改写成更易读的 `LEFT JOIN`。

MySQL 没有通用的 `FULL OUTER JOIN` 关键字。需要全外连接效果时，通常组合左连接与右侧未匹配行：

```sql
SELECT a.id, a.value, b.value
FROM table_a a
LEFT JOIN table_b b ON b.id = a.id

UNION ALL

SELECT b.id, a.value, b.value
FROM table_b b
LEFT JOIN table_a a ON a.id = b.id
WHERE a.id IS NULL;
```

---

## 15. 子查询、集合操作与 CTE

### 15.1 标量子查询

子查询只返回一个值：

```sql
SELECT id, name, price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);
```

如果标量子查询返回多行，会报错。

### 15.2 IN 子查询

```sql
SELECT id, username
FROM users
WHERE id IN (
    SELECT user_id
    FROM orders
    WHERE status IN ('paid', 'completed')
);
```

### 15.3 EXISTS 关联子查询

`EXISTS` 只关心子查询是否至少返回一行：

```sql
SELECT u.id, u.username
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
      AND o.status IN ('paid', 'completed')
);
```

其中子查询引用了外层的 `u.id`，因此属于关联子查询。

### 15.4 FROM 中的派生表

```sql
SELECT
    summary.user_id,
    summary.order_count,
    summary.total_spent
FROM (
    SELECT
        user_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE status IN ('paid', 'completed')
    GROUP BY user_id
) AS summary
WHERE summary.total_spent >= 100;
```

MySQL 中，`FROM` 后的子查询必须有别名。

### 15.5 UNION 与 UNION ALL

两个查询的列数必须相同，对应列类型应兼容：

```sql
SELECT username AS keyword
FROM users

UNION

SELECT category AS keyword
FROM products;
```

- `UNION` 会去重；
- `UNION ALL` 保留重复行，省去不必要去重时通常更直接；
- 最终排序写在整个集合操作末尾。

```sql
SELECT order_no, created_at, 'effective' AS source
FROM orders
WHERE status IN ('paid', 'completed')

UNION ALL

SELECT order_no, created_at, 'cancelled' AS source
FROM orders
WHERE status = 'cancelled'

ORDER BY created_at DESC;
```

### 15.6 CTE：公用表表达式

MySQL 8.0+ 支持 `WITH`。CTE 是只在当前语句中有效的命名结果集：

```sql
WITH user_spend AS (
    SELECT
        user_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE status IN ('paid', 'completed')
    GROUP BY user_id
)
SELECT
    u.username,
    COALESCE(s.order_count, 0) AS order_count,
    COALESCE(s.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN user_spend s ON s.user_id = u.id
ORDER BY total_spent DESC, u.id;
```

CTE 的主要价值：

- 把复杂查询拆成有名字的步骤；
- 同一个语句中可多次引用；
- 可递归处理树、层级或序列。

递归 CTE 示例：

```sql
WITH RECURSIVE sequence_numbers (n) AS (
    SELECT 1

    UNION ALL

    SELECT n + 1
    FROM sequence_numbers
    WHERE n < 5
)
SELECT n
FROM sequence_numbers;
```

---

## 16. 窗口函数

MySQL 8.0+ 支持窗口函数。与 `GROUP BY` 不同，窗口函数计算后不会把多行压缩成一行。

窗口函数的通用形式：

```sql
窗口函数(...) OVER (
    PARTITION BY 分区列
    ORDER BY 排序列
    ROWS 或 RANGE 窗口框架
)
```

各部分职责：

| 组成 | 作用 | 省略后的含义 |
|---|---|---|
| `OVER (...)` | 声明这是窗口计算，并定义相关行集合 | 窗口函数不能省略 `OVER` |
| `PARTITION BY` | 把结果行划分成彼此独立的窗口分区 | 全部结果行属于一个分区 |
| 窗口内 `ORDER BY` | 定义排名、前后行和累计计算的顺序 | 某些函数失去确定顺序或没有意义 |
| `ROWS / RANGE` | 定义当前行能看到分区中的哪些行 | 使用函数和排序对应的默认框架 |

窗口函数与 `GROUP BY` 的粒度差异：

```sql
-- GROUP BY：一个用户最终一行
SELECT user_id, SUM(total_amount) AS user_total
FROM orders
GROUP BY user_id;

-- 窗口函数：每个订单仍然一行，同时附带用户总额
SELECT
    id,
    user_id,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY user_id
    ) AS user_total
FROM orders;
```

### 16.1 窗口函数逐项说明

| 函数与基本写法 | 作用 | 典型应用 | 重要说明 |
|---|---|---|---|
| `ROW_NUMBER() OVER (...)` | 为分区内每行生成唯一连续编号 | 每组取前 N 条、去重保留一条 | 即使排序值并列，编号也不同；应增加唯一排序列保证稳定 |
| `RANK() OVER (...)` | 生成允许并列且会跳号的排名 | 比赛名次 | 可能出现 1、1、3 |
| `DENSE_RANK() OVER (...)` | 生成允许并列但不跳号的排名 | 价格档位、等级排名 | 可能出现 1、1、2 |
| `NTILE(n) OVER (...)` | 尽量平均分成 `n` 桶并编号 | 四分位、用户分层 | 行数不能整除时，前面的桶通常多一行 |
| `LAG(expr[, offset[, default]]) OVER (...)` | 读取当前行之前的值 | 环比、与上一订单比较 | 没有前一行时返回默认值或 `NULL` |
| `LEAD(expr[, offset[, default]]) OVER (...)` | 读取当前行之后的值 | 计算下一次事件时间 | 没有后一行时返回默认值或 `NULL` |
| `FIRST_VALUE(expr) OVER (...)` | 返回窗口框架第一行的值 | 与首笔订单比较 | 受窗口框架影响 |
| `LAST_VALUE(expr) OVER (...)` | 返回窗口框架最后一行的值 | 与最终状态或末笔值比较 | 默认框架经常只到当前行，通常要显式写完整框架 |
| `NTH_VALUE(expr, n) OVER (...)` | 返回窗口框架第 `n` 行的值 | 取第二高、第三次事件 | 框架内不足 `n` 行时返回 `NULL` |
| `PERCENT_RANK() OVER (...)` | 返回相对排名比例 | 百分位位置 | 第一行通常为 0 |
| `CUME_DIST() OVER (...)` | 返回累计分布比例 | 判断某值位于多少比例数据以内 | 取值范围大于 0 且小于等于 1 |
| `SUM(expr) OVER (...)` | 窗口求和 | 累计金额、组内总额 | 是否累计取决于排序和框架 |
| `AVG(expr) OVER (...)` | 窗口平均 | 移动平均、组内均值 | 保留每条明细 |
| `COUNT(expr) OVER (...)` | 窗口计数 | 给每行附加组内记录数 | `COUNT(expr)` 仍忽略 `NULL` |
| `MIN/MAX(expr) OVER (...)` | 窗口最值 | 截至当前的最高价、组内最早时间 | 可配合框架做滚动最值 |

### 16.2 分组排名

```sql
SELECT
    category,
    name,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY category
        ORDER BY price DESC, id
    ) AS row_number_in_category,
    RANK() OVER (
        PARTITION BY category
        ORDER BY price DESC
    ) AS price_rank,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY price DESC
    ) AS dense_price_rank
FROM products
ORDER BY category, price DESC, id;
```

区别：

- `ROW_NUMBER()`：每行编号一定不同；
- `RANK()`：并列后会跳号，例如 1、1、3；
- `DENSE_RANK()`：并列后不跳号，例如 1、1、2。

### 16.3 累计值

```sql
SELECT
    user_id,
    order_no,
    created_at,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders
ORDER BY user_id, created_at, id;
```

### 16.4 查看上一行

```sql
SELECT
    user_id,
    order_no,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
    ) AS previous_amount
FROM orders
ORDER BY user_id, created_at, id;
```

窗口函数不能直接放进同层 `WHERE`。需要先在 CTE 或派生表中计算，再由外层过滤：

```sql
WITH ranked_products AS (
    SELECT
        id,
        category,
        name,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price DESC, id
        ) AS row_num
    FROM products
)
SELECT id, category, name, price
FROM ranked_products
WHERE row_num = 1;
```

### 16.5 LAG 与 LEAD：计算前后差值

```sql
SELECT
    user_id,
    order_no,
    created_at,
    total_amount,
    LAG(total_amount, 1, 0) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
    ) AS previous_amount,
    LEAD(total_amount, 1, 0) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
    ) AS next_amount,
    total_amount
        - LAG(total_amount, 1, 0) OVER (
            PARTITION BY user_id
            ORDER BY created_at, id
        ) AS change_from_previous
FROM orders
ORDER BY user_id, created_at, id;
```

`LAG()` 与 `LEAD()` 依赖窗口内排序。如果只按可能重复的 `created_at` 排序，“上一行”可能不稳定，因此这里补充主键 `id`。

### 16.6 窗口框架：ROWS 与 RANGE

累计求和常用：

```sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

含义是：

```text
从分区第一行
到当前这一行
```

移动三行平均：

```sql
SELECT
    id,
    user_id,
    total_amount,
    AVG(total_amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average_3_rows
FROM orders;
```

常见边界关键字：

| 写法 | 含义 |
|---|---|
| `UNBOUNDED PRECEDING` | 分区第一行 |
| `n PRECEDING` | 当前行之前第 `n` 行 |
| `CURRENT ROW` | 当前行 |
| `n FOLLOWING` | 当前行之后第 `n` 行 |
| `UNBOUNDED FOLLOWING` | 分区最后一行 |

`ROWS` 按物理行位置定义框架；`RANGE` 按排序值的同值范围定义框架。初学者做“截至当前行累计”时，显式写 `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` 通常最容易理解。

### 16.7 LAST_VALUE 的默认框架陷阱

下面的 `LAST_VALUE()` 可能返回“当前行的值”，而不是整个分区最后一行，因为默认框架经常截止当前行：

```sql
SELECT
    user_id,
    total_amount,
    LAST_VALUE(total_amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
    ) AS possibly_current_value
FROM orders;
```

如果目标是整个分区最后一笔金额，应显式扩大框架：

```sql
SELECT
    user_id,
    order_no,
    total_amount,
    LAST_VALUE(total_amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at, id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS last_order_amount
FROM orders;
```

---

## 17. 事务

事务把多条操作组织成一个不可随意拆分的工作单元。

### 17.1 最基本语法

```sql
START TRANSACTION;

UPDATE products
SET stock = stock - 1
WHERE id = 101
  AND stock >= 1;

-- 确认影响行数；0 表示库存不足或商品不存在
SELECT ROW_COUNT() AS affected_rows;

COMMIT;
```

不希望保留修改时：

```sql
START TRANSACTION;

UPDATE products
SET stock = stock + 100
WHERE id = 101;

SELECT id, name, stock
FROM products
WHERE id = 101;

ROLLBACK;
```

### 17.2 一个下单事务骨架

下面展示语法和步骤，不要直接用于真实支付系统：

```sql
START TRANSACTION;

-- 锁定目标商品，防止并发事务同时修改
SELECT id, stock, price
FROM products
WHERE id = 101
FOR UPDATE;

UPDATE products
SET stock = stock - 1
WHERE id = 101
  AND stock >= 1;

SELECT ROW_COUNT() AS stock_updated;

INSERT INTO orders
    (order_no, user_id, total_amount, status)
VALUES
    (REPLACE(UUID(), '-', ''),
     1,
     399.00,
     'pending');

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
VALUES
    (@new_order_id, 101, 1, 399.00);

COMMIT;
```

真实程序必须在更新库存后检查影响行数：

- 等于 1：继续创建订单；
- 等于 0：库存不足，执行 `ROLLBACK`；
- 任意 SQL 报错：捕获异常并 `ROLLBACK`；
- 所有步骤成功：最后 `COMMIT`。

### 17.3 SAVEPOINT

```sql
START TRANSACTION;

UPDATE products
SET stock = stock + 10
WHERE id = 101;

SAVEPOINT after_first_update;

UPDATE products
SET stock = stock + 20
WHERE id = 102;

ROLLBACK TO SAVEPOINT after_first_update;
RELEASE SAVEPOINT after_first_update;

COMMIT;
```

回滚到保存点只撤销保存点之后的修改，事务仍然继续。

### 17.4 autocommit

```sql
SELECT @@autocommit;

SET autocommit = 0;
-- 后续事务需要显式 COMMIT 或 ROLLBACK

SET autocommit = 1;
```

MySQL 新连接通常默认开启自动提交。更推荐在需要多语句事务时显式使用 `START TRANSACTION`，而不是长时间关闭自动提交。

### 17.5 事务隔离级别语法

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION READ WRITE;
-- 事务操作
COMMIT;
```

常见隔离级别：

1. `READ UNCOMMITTED`；
2. `READ COMMITTED`；
3. `REPEATABLE READ`；
4. `SERIALIZABLE`。

InnoDB 常见默认级别是 `REPEATABLE READ`。隔离级别越高不等于业务一定越正确，也可能增加等待与冲突；应结合一致性要求选择。

### 17.6 DDL 的隐式提交

`CREATE TABLE`、`ALTER TABLE`、`DROP TABLE`、`TRUNCATE TABLE` 等 DDL 通常会造成隐式提交，不能把它们当成普通数据修改，期待随后 `ROLLBACK` 恢复。下面只应在独立学习库中执行：

```sql
CREATE TABLE ddl_transaction_demo (
    id INT NOT NULL PRIMARY KEY,
    value INT NOT NULL
);

INSERT INTO ddl_transaction_demo (id, value)
VALUES (1, 10);

START TRANSACTION;

UPDATE ddl_transaction_demo
SET value = 20
WHERE id = 1;

-- 某些 DDL 会让前面的事务被隐式提交
ALTER TABLE ddl_transaction_demo
    ADD COLUMN note VARCHAR(20);

ROLLBACK;

-- value 仍然是 20，note 列也仍然存在
SELECT * FROM ddl_transaction_demo;

DROP TABLE ddl_transaction_demo;
```

不要在真实库中执行上面的演示。迁移脚本应单独设计、备份并验证。

---

## 18. 索引与 EXPLAIN

索引类似书的目录：它增加额外存储和维护成本，换取特定查询更快定位数据。

### 18.1 查看索引

```sql
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
```

### 18.2 创建与删除索引

```sql
CREATE INDEX idx_products_name
ON products (name);

DROP INDEX idx_products_name
ON products;
```

唯一索引：

```sql
ALTER TABLE products
    ADD UNIQUE KEY uk_products_category_name (category, name);

ALTER TABLE products
    DROP INDEX uk_products_category_name;
```

这个示例创建后立即删除，只用于展示语法。真实项目添加唯一约束前，必须先确认现有数据没有重复，并确认该组合在业务上确实应当唯一。

### 18.3 联合索引与最左前缀

演示表中已有：

```sql
KEY idx_orders_user_created (user_id, created_at)
```

通常更容易支持：

```sql
-- 使用最左列 user_id
SELECT *
FROM orders
WHERE user_id = 1;

-- 使用 user_id，再对 created_at 做范围过滤
SELECT *
FROM orders
WHERE user_id = 1
  AND created_at >= '2026-08-01'
  AND created_at <  '2026-09-01';
```

只按 `created_at` 查询时，不能简单假设这个联合索引仍然高效。索引设计应跟随真实查询条件、排序和数据分布，而不是“看到列就加索引”。

### 18.4 EXPLAIN

```sql
EXPLAIN
SELECT id, order_no, total_amount
FROM orders
WHERE user_id = 1
  AND created_at >= '2026-08-01'
ORDER BY created_at;
```

入门阶段先关注：

| 字段 | 含义 |
|---|---|
| `type` | 访问方式，`ALL` 常表示全表扫描，但是否有问题要结合数据量 |
| `possible_keys` | 可能使用的索引 |
| `key` | 实际选择的索引 |
| `rows` | 预计检查的行数 |
| `Extra` | 额外信息，例如 `Using where`、`Using filesort` |

不要把“必须使用索引”当成目标。小表全表扫描可能比走索引更便宜，最终决定由优化器和成本估算完成。

### 18.5 常见索引失效或低效写法

以下写法需要特别检查：

```sql
-- 前导通配符
WHERE name LIKE '%键盘'

-- 对索引列做函数计算
WHERE DATE(created_at) = '2026-08-05'

-- 隐式类型转换，例如字符串列拿数字比较
WHERE order_no = 20260801001

-- 联合索引跳过最左列
WHERE created_at >= '2026-08-01'
```

“失效”不是绝对结论，应使用真实数据、`EXPLAIN` 和性能测量验证。

---

## 19. 视图与临时表

### 19.1 视图

视图保存的是查询定义，不是普通结果快照：

```sql
CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    o.id AS order_id,
    o.order_no,
    u.username,
    o.total_amount,
    o.status,
    o.created_at
FROM orders o
JOIN users u ON u.id = o.user_id;

SELECT *
FROM v_order_summary
WHERE status IN ('paid', 'completed');

DROP VIEW IF EXISTS v_order_summary;
```

视图适合封装稳定查询接口或限制暴露列，但复杂视图不一定提高性能，部分视图也不可直接更新。

### 19.2 临时表

```sql
CREATE TEMPORARY TABLE temp_effective_orders AS
SELECT *
FROM orders
WHERE status IN ('paid', 'completed');

SELECT * FROM temp_effective_orders;

DROP TEMPORARY TABLE temp_effective_orders;
```

临时表通常只在当前会话可见，连接结束后自动删除。它适合拆分复杂处理中间结果，不应被当成长期业务表。

---

## 20. 用户与权限

以下语句需要具备账号管理权限。

### 20.1 创建用户

```sql
CREATE USER 'app_user'@'localhost'
IDENTIFIED BY 'replace-with-a-strong-password';
```

`'app_user'@'localhost'` 中：

- 前半部分是用户名；
- 后半部分是允许连接的主机来源；
- `'app_user'@'localhost'` 与 `'app_user'@'%'` 是不同账号。

### 20.2 授予最小权限

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON mysql_syntax_lab.*
TO 'app_user'@'localhost';

SHOW GRANTS FOR 'app_user'@'localhost';
```

业务应用通常不应使用 `root`，也不应默认获得 `DROP`、`ALTER` 或全局权限。

### 20.3 回收权限与删除用户

```sql
REVOKE DELETE
ON mysql_syntax_lab.*
FROM 'app_user'@'localhost';

DROP USER 'app_user'@'localhost';
```

通过 `CREATE USER`、`GRANT`、`REVOKE` 修改权限后，不需要手动执行 `FLUSH PRIVILEGES`。只有直接修改授权表等特殊场景才涉及重新加载，而直接修改系统授权表本身也不推荐。

---

## 21. 高频易错点

### 21.1 UPDATE 或 DELETE 忘写 WHERE

错误：

```sql
UPDATE users SET status = 0;
DELETE FROM users;
```

正确习惯：

1. 先 `SELECT`；
2. 再 `START TRANSACTION`；
3. 执行修改；
4. 查看影响行数和结果；
5. 最后 `COMMIT` 或 `ROLLBACK`。

### 21.2 用等号判断 NULL

```sql
-- 错误
WHERE profile = NULL

-- 正确
WHERE profile IS NULL
```

### 21.3 把 WHERE 和 HAVING 混用

- `WHERE`：分组前过滤原始行；
- `HAVING`：分组后过滤聚合结果；
- 能在 `WHERE` 提前排除的行，通常不要拖到 `HAVING`。

### 21.4 LIMIT 没有稳定排序

```sql
-- 结果顺序不保证稳定
SELECT * FROM orders LIMIT 10;

-- 加唯一列作为最终排序条件
SELECT id, order_no
FROM orders
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

### 21.5 金额使用浮点类型

金额用 `DECIMAL`，不要因为 `FLOAT` 看起来更短就使用近似值。

### 21.6 依赖隐式类型转换

如果 `order_no` 是字符串，就用字符串比较：

```sql
WHERE order_no = 'ORD-20260801-001'
```

不要让 MySQL 猜测字符串与数字如何转换，这可能产生意外结果并影响索引使用。

### 21.7 GROUP BY 中选择不确定的列

```sql
-- 每个 category 有多个 name，含义不确定
SELECT category, name, COUNT(*)
FROM products
GROUP BY category;
```

应明确聚合、增加分组列，或用窗口函数按规则选一行。

### 21.8 LEFT JOIN 后在 WHERE 过滤右表

如果需要保留左表无匹配行，把右表过滤条件写进 `ON`；写进 `WHERE` 可能把外连接变成内连接效果。

### 21.9 把 DDL 当成普通可回滚语句

`ALTER`、`DROP`、`TRUNCATE` 等操作可能隐式提交。执行数据库迁移前应先备份、检查影响范围并在测试环境验证。

### 21.10 在应用代码中拼接 SQL

危险思路：

```text
"SELECT * FROM users WHERE username = '" + user_input + "'"
```

正确方向是使用数据库驱动的参数化查询：

```sql
SELECT id, username, email
FROM users
WHERE username = ?;
```

问号由驱动绑定参数，不是让程序自己给输入加引号。表名、列名等结构部分通常不能直接作为普通参数绑定，需要使用白名单。

---

## 22. 核心关键字逐项说明

关键字不是普通函数。函数通常以 `name(...)` 形式计算并返回值；关键字负责定义语句结构、数据来源、过滤规则、事务边界或对象属性。

本章定位是“正文语法词典”：先查作用，再回到前文章节看完整例子。

### 22.1 查询与过滤关键字

| 关键字或运算符 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `SELECT` | 指定查询要输出的列或表达式 | `SELECT col, expr AS alias` | 只写真正需要的列；`SELECT *` 适合临时查看，不适合长期接口 |
| `FROM` | 指定行数据来源 | `FROM table_name alias` | 可以来自表、视图、CTE、派生表或连接结果 |
| `AS` | 为列或对象定义别名 | `price * stock AS value` | 列别名常写 `AS`；表别名通常直接写 `FROM users u` |
| `DISTINCT` | 删除最终选择列组合的重复行 | `SELECT DISTINCT category FROM products` | 对整个选择列表去重，不只作用于紧随其后的单列 |
| `WHERE` | 在分组和聚合前过滤明细行 | `WHERE status = 1` | 不能直接使用聚合函数；条件应尽量和列类型一致 |
| `AND` | 所有条件都成立才为真 | `WHERE status = 1 AND stock > 0` | 优先级高于 `OR`，混用时建议加括号 |
| `OR` | 任一条件成立即为真 | `WHERE category = '数码' OR price < 100` | 大量不同列 `OR` 可能让索引选择复杂 |
| `NOT` | 对逻辑条件取反 | `WHERE NOT status = 0` | 通常写成更直观的 `status <> 0`；注意三值逻辑中的 `NULL` |
| `IN` | 判断值是否属于集合 | `status IN ('paid', 'completed')` | 也可接子查询；集合很大时要结合执行计划 |
| `NOT IN` | 判断值不属于集合 | `id NOT IN (1, 2)` | 子查询结果含 `NULL` 时容易导致意外的未知结果，常用 `NOT EXISTS` 替代 |
| `BETWEEN ... AND ...` | 判断是否位于闭区间 | `price BETWEEN 100 AND 500` | 包含两端；日期时间查询更常使用半开区间 |
| `LIKE` | 使用简单通配符匹配字符串 | `name LIKE '机械%'` | `%` 匹配任意长度，`_` 匹配一个字符；前导 `%` 常难利用普通索引 |
| `NOT LIKE` | 排除通配符匹配结果 | `name NOT LIKE '%测试%'` | `NULL` 不会直接变成真，应单独处理 |
| `REGEXP` / `RLIKE` | 使用正则表达式匹配 | `name REGEXP 'pattern'` | 模式可表达分支、重复与字符类；复杂正则代价较高 |
| `IS NULL` | 判断值是否为空 | `profile IS NULL` | 不能写成 `= NULL` |
| `IS NOT NULL` | 判断值是否非空 | `email IS NOT NULL` | 常用于统计或数据质量过滤 |
| `<=>` | MySQL 的 NULL 安全等于 | `a <=> b` | 两边都是 `NULL` 时返回 1；普通 `=` 会返回 `NULL` |
| `CASE` | 开始条件表达式 | `CASE WHEN ... THEN ... END` | 可用于状态映射、分段和条件聚合 |
| `WHEN` | 声明一个匹配值或判断条件 | `WHEN status = 'paid' THEN 1` | 从上到下匹配，命中首个成立分支 |
| `THEN` | 指定当前分支结果 | `THEN '已支付'` | 各分支结果会进行类型归并 |
| `ELSE` | 指定未命中时的默认结果 | `ELSE '未知'` | 省略时默认结果为 `NULL` |
| `END` | 结束 `CASE` 表达式 | `CASE ... END AS label` | `CASE` 是表达式，不是查询终止符 |
| `ORDER BY` | 对最终结果排序 | `ORDER BY price DESC, id ASC` | `GROUP BY` 不保证顺序；稳定分页应补唯一排序列 |
| `ASC` | 升序排序 | `ORDER BY id ASC` | 默认方向，可以省略 |
| `DESC` | 降序排序 | `ORDER BY created_at DESC` | 常用于最新记录优先 |
| `LIMIT` | 限制返回行数 | `LIMIT 10` | 没有 `ORDER BY` 时不能依赖返回的是固定十行 |
| `OFFSET` | 跳过指定行数 | `LIMIT 10 OFFSET 20` | 大偏移量可能扫描并丢弃很多行，可考虑游标分页 |

查询骨架：

```sql
SELECT DISTINCT
    p.category,
    p.name,
    p.price
FROM products AS p
WHERE p.status = 1
  AND p.price BETWEEN 100 AND 2000
ORDER BY p.price DESC, p.id ASC
LIMIT 10 OFFSET 0;
```

### 22.2 多表连接关键字

| 关键字 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `JOIN` | 连接两份行数据 | `a JOIN b ON condition` | 单独写 `JOIN` 通常等价于 `INNER JOIN` |
| `INNER JOIN` | 只保留两边都匹配的组合 | `orders o INNER JOIN users u ON ...` | 适合“必须存在关联记录”的查询 |
| `LEFT JOIN` | 保留左侧全部行，右侧无匹配补 `NULL` | `users u LEFT JOIN orders o ON ...` | 适合查零订单用户、可选关系 |
| `RIGHT JOIN` | 保留右侧全部行 | `a RIGHT JOIN b ON ...` | 通常交换表顺序改写成 `LEFT JOIN` 更易读 |
| `CROSS JOIN` | 生成笛卡尔积 | `Students CROSS JOIN Subjects` | 适合构造全部组合；行数等于两边行数乘积 |
| `ON` | 指定当前连接的匹配条件 | `ON o.user_id = u.id` | 外连接中，放在 `ON` 与放在 `WHERE` 可能改变语义 |
| `USING(column)` | 两表同名列的等值连接简写 | `a JOIN b USING (user_id)` | 只适合同名连接列；复杂条件仍用 `ON` |
| `NATURAL JOIN` | 自动使用所有同名列连接 | `a NATURAL JOIN b` | 表结构变化会悄悄改变连接条件，不建议业务代码使用 |

外连接条件位置：

```sql
-- 保留所有用户，只把已支付订单连接进来
SELECT u.id, u.username, o.order_no
FROM users u
LEFT JOIN orders o
    ON o.user_id = u.id
   AND o.status = 'paid';

-- 条件写到 WHERE 后，没有已支付订单的用户会被过滤
SELECT u.id, u.username, o.order_no
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.status = 'paid';
```

### 22.3 分组关键字

| 关键字 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `GROUP BY` | 按表达式把明细行划分为组 | `GROUP BY category` | 每个组最终输出一行；决定统计结果的粒度 |
| `HAVING` | 过滤已经形成的组 | `HAVING COUNT(*) >= 2` | 可以使用聚合函数；不应代替所有 `WHERE` |
| `WITH ROLLUP` | 在普通分组外增加小计和总计行 | `GROUP BY category WITH ROLLUP` | 汇总行的分组列可能为 `NULL`，应用端要能区分 |

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock) AS total_stock
FROM products
WHERE status = 1
GROUP BY category WITH ROLLUP
HAVING SUM(stock) > 0;
```

### 22.4 子查询、集合与 CTE 关键字

| 关键字 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `EXISTS` | 判断子查询是否至少返回一行 | `WHERE EXISTS (SELECT 1 FROM ...)` | 适合判断关联记录存在，选择列表通常写常量 1 |
| `NOT EXISTS` | 判断子查询没有返回行 | `WHERE NOT EXISTS (...)` | 查询“没有订单的用户”时比 `NOT IN` 更稳健 |
| `ANY` / `SOME` | 与子查询返回的任意一个值比较 | `price > ANY (subquery)` | `SOME` 是 `ANY` 的同义词 |
| `ALL` | 与子查询返回的所有值比较 | `price >= ALL (subquery)` | 可表达“不小于任何值”，空集语义需单独理解 |
| `UNION` | 合并结果并去重 | `query1 UNION query2` | 各查询列数相同，对应类型兼容 |
| `UNION ALL` | 合并结果并保留重复 | `query1 UNION ALL query2` | 不需要去重时通常更直接、更省操作 |
| `WITH` | 定义当前语句可用的 CTE | `WITH cte AS (...) SELECT ...` | 用于拆分复杂查询、复用中间结果 |
| `RECURSIVE` | 允许 CTE 引用自身 | `WITH RECURSIVE tree AS (...)` | 必须有终止条件，避免无穷递归 |

`EXISTS` 示例：

```sql
SELECT u.id, u.username
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
      AND o.status = 'paid'
);
```

递归 CTE 必须包含：

```text
锚点成员：生成初始行
UNION ALL
递归成员：引用 CTE 并生成下一层
终止条件：让递归最终停止
```

### 22.5 DDL：数据库对象定义关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `CREATE DATABASE` | 创建数据库 | `CREATE DATABASE db_name` | 通常同时指定字符集与排序规则 |
| `CREATE TABLE` | 创建表 | `CREATE TABLE t (...)` | 在括号内定义列、约束与索引 |
| `CREATE VIEW` | 保存查询定义为视图 | `CREATE VIEW v AS SELECT ...` | 不是普通数据快照 |
| `CREATE INDEX` | 创建索引 | `CREATE INDEX idx ON t(col)` | 会增加写入和存储成本 |
| `CREATE USER` | 创建数据库账号 | `CREATE USER 'u'@'host' ...` | 用户名和来源主机共同标识账号 |
| `OR REPLACE` | 存在时替换对象定义 | `CREATE OR REPLACE VIEW ...` | 并非所有 `CREATE` 对象都支持 |
| `IF NOT EXISTS` | 对象已存在时避免直接报错 | `CREATE TABLE IF NOT EXISTS t (...)` | 不会自动验证现有对象结构是否符合预期 |
| `ALTER TABLE` | 修改现有表结构 | `ALTER TABLE t action` | 大表操作可能耗时、锁表或触发重建 |
| `ADD COLUMN` | 新增列 | `ALTER TABLE t ADD COLUMN c INT` | 应考虑默认值、空值和历史数据回填 |
| `MODIFY COLUMN` | 修改列定义但不改列名 | `MODIFY COLUMN c BIGINT NOT NULL` | 需要写出完整的新列定义 |
| `CHANGE COLUMN` | 修改列名并重新声明定义 | `CHANGE COLUMN old new VARCHAR(100)` | 容易漏掉原有属性；MySQL 特有写法 |
| `RENAME COLUMN` | 只修改列名 | `RENAME COLUMN old TO new` | MySQL 8.0+ 使用更清晰 |
| `RENAME TABLE` | 修改表名 | `RENAME TABLE old TO new` | 应同步修改应用、视图和运维脚本引用 |
| `DROP DATABASE` | 删除数据库及其中对象 | `DROP DATABASE db_name` | 高危 DDL，通常隐式提交 |
| `DROP TABLE` | 删除表结构和数据 | `DROP TABLE table_name` | 与只删除数据的 `DELETE` 不同 |
| `DROP COLUMN` | 删除列 | `ALTER TABLE t DROP COLUMN c` | 删除前检查代码、索引和约束依赖 |
| `DROP INDEX` | 删除索引 | `DROP INDEX idx ON t` | 删除后相关查询可能退化 |
| `DROP VIEW` | 删除视图定义 | `DROP VIEW view_name` | 不删除基础表 |
| `DROP USER` | 删除数据库账号 | `DROP USER 'u'@'host'` | 删除前检查应用是否仍在使用 |
| `IF EXISTS` | 对象不存在时避免直接报错 | `DROP TABLE IF EXISTS t` | 适合清理脚本，但仍应记录是否真的删除 |
| `TRUNCATE TABLE` | 快速清空整张表 | `TRUNCATE TABLE t` | 不支持 `WHERE`，通常重置自增并隐式提交 |
| `USE` | 选择当前默认数据库 | `USE mysql_syntax_lab` | 连接后应确认当前库，避免在错误库执行 |
| `SHOW` | 查看元数据或服务器状态 | `SHOW TABLES`、`SHOW INDEX FROM t` | 是一组 MySQL 管理语句前缀 |
| `DESCRIBE` / `DESC` | 快速查看列定义 | `DESCRIBE users` | 完整结构仍应看 `SHOW CREATE TABLE` |
| `TEMPORARY` | 创建会话级临时表 | `CREATE TEMPORARY TABLE ...` | 通常只对当前连接可见，断开后删除 |

典型建表语句中的结构：

```sql
CREATE TABLE IF NOT EXISTS example_table (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_example_name (name)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
```

### 22.6 列属性、约束与表选项关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `NULL` | 表示未知、缺失或不适用 | `profile JSON NULL` | 不等于 0、空字符串或字符串 `'NULL'` |
| `NOT NULL` | 禁止列值为空 | `name VARCHAR(100) NOT NULL` | 核心必填字段应优先使用 |
| `DEFAULT` | 未提供值时使用默认表达式 | `status INT DEFAULT 1` | 默认值不是业务校验的替代品 |
| `PRIMARY KEY` | 唯一且非空地标识一行 | `PRIMARY KEY (id)` | 一张表只有一个主键，可由多列组成 |
| `UNIQUE` / `UNIQUE KEY` | 禁止索引列组合重复 | `UNIQUE KEY uk_email (email)` | 同时具有约束和索引作用 |
| `CHECK` | 要求表达式成立 | `CHECK (price >= 0)` | 用于数据库层数据质量保护；MySQL 8.0.16+ 才真正执行检查 |
| `CONSTRAINT` | 为约束指定名称 | `CONSTRAINT fk_order_user FOREIGN KEY ...` | 明确命名便于迁移和排错 |
| `FOREIGN KEY` | 声明子表引用关系 | `FOREIGN KEY (user_id) ...` | 列类型及有符号属性必须兼容 |
| `REFERENCES` | 指定外键引用的父表和列 | `REFERENCES users(id)` | 父列通常必须有合适索引 |
| `AUTO_INCREMENT` | 自动生成递增数值 | `id BIGINT AUTO_INCREMENT` | 可能跳号，不保证连续 |
| `UNSIGNED` | 使用无符号整数范围 | `BIGINT UNSIGNED` | 外键两侧应保持一致 |
| `ON DELETE` | 指定父记录删除时的外键动作 | `ON DELETE CASCADE` | 必须符合业务生命周期 |
| `ON UPDATE` | 指定父键更新时的外键动作 | `ON UPDATE RESTRICT` | 主键通常不应频繁修改 |
| `CASCADE` | 将父表变化级联到子表 | `ON DELETE CASCADE` | 可能一次影响大量子记录 |
| `RESTRICT` | 存在引用时拒绝父表操作 | `ON DELETE RESTRICT` | 适合必须显式处理子记录的业务 |
| `SET NULL` | 父记录变化后把外键设为 `NULL` | `ON DELETE SET NULL` | 子表外键列必须允许 `NULL` |
| `GENERATED ALWAYS AS` | 定义生成列计算表达式 | `subtotal AS (qty * price)` | 值由数据库计算，不能像普通列随意写入 |
| `VIRTUAL` | 查询时计算生成列 | `... AS (...) VIRTUAL` | 节省存储，但读取时需要计算 |
| `STORED` | 写入时计算并存储生成列 | `... AS (...) STORED` | 占用存储，可用于更多索引场景 |
| `ENGINE` | 指定存储引擎 | `ENGINE = InnoDB` | 入门事务表通常使用 InnoDB |
| `CHARACTER SET` | 指定字符到字节的编码规则 | `CHARACTER SET utf8mb4` | 决定能保存哪些字符 |
| `COLLATE` | 指定字符串比较和排序规则 | `COLLATE utf8mb4_0900_ai_ci` | 影响大小写、重音、排序和唯一判断 |
| `COMMENT` | 添加列或表说明 | `email VARCHAR(100) COMMENT '邮箱'` | 不能替代正式数据字典 |

### 22.7 DML：数据写入关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `INSERT INTO` | 向表插入新行 | `INSERT INTO t(cols) VALUES (...)` | 推荐显式列名，不依赖物理列顺序 |
| `VALUES` | 提供一行或多行字面值 | `VALUES (1, 'A'), (2, 'B')` | 列数、顺序和类型要与目标列兼容 |
| `DEFAULT` | 在插入或更新时使用列默认值 | `VALUES (DEFAULT, 'A')` | 目标列必须有可用默认规则 |
| `INSERT ... SELECT` | 把查询结果写入目标表 | `INSERT INTO t(cols) SELECT ...` | 两边列数和类型必须兼容 |
| `ON DUPLICATE KEY UPDATE` | 唯一键冲突时改为更新 | `INSERT ... ON DUPLICATE KEY UPDATE ...` | 是 Upsert；要确认冲突键和更新规则 |
| `IGNORE` | 将某些错误降为警告并继续 | `INSERT IGNORE INTO ...` | 可能掩盖数据问题，使用后检查 `SHOW WARNINGS` |
| `UPDATE` | 修改已有行 | `UPDATE t SET col = value WHERE ...` | 执行前先用相同 `WHERE` 查询命中范围 |
| `SET` | 指定列赋值或系统变量赋值 | `SET stock = stock - 1` | 在 `UPDATE` 中可引用原列值计算新值 |
| `DELETE FROM` | 删除满足条件的行 | `DELETE FROM t WHERE ...` | 没有 `WHERE` 会删除全部行 |
| `REPLACE` | 唯一键冲突时删除旧行再插入新行 | `REPLACE INTO t ...` | 可能触发删除语义、外键和自增变化，通常优先明确使用 Upsert |

安全修改模板：

```sql
-- 1. 先确认范围
SELECT id, name, stock
FROM products
WHERE category = '文具';

-- 2. 开启事务
START TRANSACTION;

-- 3. 执行修改
UPDATE products
SET stock = stock + 10
WHERE category = '文具';

-- 4. 记录影响行数并核对结果
SELECT ROW_COUNT() AS affected_rows;

SELECT id, name, stock
FROM products
WHERE category = '文具';

-- 5. 确认后 COMMIT；练习时撤销
ROLLBACK;
```

### 22.8 事务与锁关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `START TRANSACTION` | 显式开始多语句事务 | `START TRANSACTION` | 比单独写 `BEGIN` 更清楚 |
| `BEGIN` | 在普通 SQL 会话中可作为开始事务的同义写法 | `BEGIN` | 在存储程序中也可能表示复合语句块，应注意上下文 |
| `COMMIT` | 永久提交当前事务修改 | `COMMIT` | 提交后普通 `ROLLBACK` 无法撤销 |
| `ROLLBACK` | 撤销当前事务尚未提交的修改 | `ROLLBACK` | DDL 隐式提交后的变化不能按普通 DML 撤回 |
| `SAVEPOINT` | 在事务内创建保存点 | `SAVEPOINT step_one` | 适合部分回滚 |
| `ROLLBACK TO SAVEPOINT` | 回滚到指定保存点 | `ROLLBACK TO SAVEPOINT step_one` | 事务仍继续，不等于完整回滚 |
| `RELEASE SAVEPOINT` | 删除保存点名称 | `RELEASE SAVEPOINT step_one` | 不提交事务 |
| `SET autocommit` | 控制语句是否自动提交 | `SET autocommit = 0` | 长时间关闭容易遗忘事务，更推荐显式事务块 |
| `READ ONLY` | 声明只读事务 | `START TRANSACTION READ ONLY` | 有利于表达意图，但权限和具体限制仍需确认 |
| `READ WRITE` | 声明读写事务 | `START TRANSACTION READ WRITE` | 需要修改数据时使用 |
| `FOR UPDATE` | 对读取到的目标记录加排他性质的锁定读 | `SELECT ... FOR UPDATE` | 应放在显式事务中，并尽快提交或回滚 |
| `FOR SHARE` | 对读取记录进行共享锁定读 | `SELECT ... FOR SHARE` | 允许其他共享读，阻止冲突修改 |
| `NOWAIT` | 无法立刻获得锁时直接报错 | `FOR UPDATE NOWAIT` | 适合不愿等待的业务 |
| `SKIP LOCKED` | 跳过已经被锁定的行 | `FOR UPDATE SKIP LOCKED` | 适合任务队列；返回的是不完整视图，不适合一般一致性查询 |
| `SET TRANSACTION ISOLATION LEVEL` | 设置事务隔离级别 | `SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED` | 影响并发可见性、锁和一致性 |

四种隔离级别关键字：

| 隔离级别 | 基本含义 |
|---|---|
| `READ UNCOMMITTED` | 允许读取其他事务尚未提交的数据 |
| `READ COMMITTED` | 每次一致性读通常看到语句开始前已提交的数据 |
| `REPEATABLE READ` | 同一事务内一致性读通常保持可重复视图；InnoDB 常见默认值 |
| `SERIALIZABLE` | 最强隔离倾向，冲突和等待也可能最多 |

### 22.9 执行计划与元数据关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `EXPLAIN` | 查看优化器计划 | `EXPLAIN SELECT ...` | 关注访问类型、索引、估算行数和额外信息 |
| `EXPLAIN ANALYZE` | 执行并返回实际计划统计 | `EXPLAIN ANALYZE SELECT ...` | MySQL 8.0.18+；会实际执行查询，生产环境使用前评估代价 |
| `SHOW CREATE TABLE` | 查看完整建表定义 | `SHOW CREATE TABLE users` | 比 `DESC` 更完整 |
| `SHOW INDEX` | 查看表索引 | `SHOW INDEX FROM orders` | 用于确认联合索引列顺序和唯一性 |
| `SHOW WARNINGS` | 查看上一语句警告 | `SHOW WARNINGS` | 使用 `IGNORE` 或发生类型转换后尤其重要 |
| `ANALYZE TABLE` | 更新表统计信息等 | `ANALYZE TABLE products` | 可能影响优化器计划；不是查询语法分析命令 |

### 22.10 用户与权限关键字

| 关键字或组合 | 核心作用 | 基本写法 | 应用方式与注意事项 |
|---|---|---|---|
| `CREATE USER` | 创建账号 | `CREATE USER 'app'@'localhost' ...` | 用户名和来源主机共同构成账号 |
| `IDENTIFIED BY` | 设置认证密码 | `IDENTIFIED BY 'strong-password'` | 不要把真实密码提交到代码仓库 |
| `GRANT` | 授予权限 | `GRANT SELECT ON db.* TO account` | 遵循最小权限原则 |
| `ON` | 在授权语句中指定权限作用对象 | `ON mysql_syntax_lab.*` | 与连接条件中的 `ON` 是不同上下文 |
| `TO` | 指定授权接收账号 | `TO 'app'@'localhost'` | 账号必须准确包含主机部分 |
| `SHOW GRANTS` | 查看账号权限 | `SHOW GRANTS FOR account` | 排查权限问题的首选语句 |
| `REVOKE` | 回收权限 | `REVOKE DELETE ON db.* FROM account` | 回收后检查应用功能是否受影响 |
| `FROM` | 在 `REVOKE` 中指定被回收账号 | `FROM 'app'@'localhost'` | 与查询的数据来源 `FROM` 是不同上下文 |
| `DROP USER` | 删除账号 | `DROP USER 'app'@'localhost'` | 不会自动修改应用连接配置 |

### 22.11 同一关键字可能因上下文承担不同职责

SQL 关键字不能脱离完整语句机械翻译。例如：

| 关键字 | 查询上下文 | 其他上下文 |
|---|---|---|
| `FROM` | `SELECT ... FROM users`：指定数据来源 | `REVOKE ... FROM user`：指定被回收权限的账号 |
| `ON` | `JOIN ... ON condition`：连接条件 | `GRANT ... ON db.*`：权限作用对象 |
| `SET` | `UPDATE ... SET col = value`：修改列 | `SET autocommit = 0`：设置会话变量 |
| `ORDER BY` | 对最终查询结果排序 | 在窗口 `OVER(...)` 中只定义窗口计算顺序 |
| `AS` | 定义别名 | 生成列中 `AS (expression)` 定义计算表达式 |

因此学习关键字时必须同时记住：

> 它出现在哪类语句中、作用于什么对象、改变哪个阶段的语义。

---

## 23. 常用语法速查

### 23.1 建库建表

```sql
CREATE DATABASE database_name
    CHARACTER SET utf8mb4;

USE database_name;

CREATE TABLE table_name (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_table_name_name (name)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4;
```

### 23.2 增删改

```sql
INSERT INTO table_name (column_a, column_b)
VALUES (value_a, value_b);

UPDATE table_name
SET column_a = new_value
WHERE id = target_id;

DELETE FROM table_name
WHERE id = target_id;
```

### 23.3 单表查询

```sql
SELECT column_a, column_b
FROM table_name
WHERE condition
ORDER BY column_a DESC
LIMIT 10;
```

### 23.4 分组查询

```sql
SELECT
    group_column,
    COUNT(*) AS row_count,
    SUM(amount) AS total_amount
FROM table_name
WHERE row_condition
GROUP BY group_column
HAVING SUM(amount) > 100
ORDER BY total_amount DESC;
```

### 23.5 多表连接

```sql
SELECT
    a.id,
    a.name,
    b.detail
FROM table_a a
LEFT JOIN table_b b ON b.a_id = a.id
WHERE a.status = 1;
```

### 23.6 事务

```sql
START TRANSACTION;

-- 多条相关 DML

COMMIT;
-- 出错时改为 ROLLBACK;
```

### 23.7 排查查询

```sql
SHOW CREATE TABLE table_name;
SHOW INDEX FROM table_name;

EXPLAIN
SELECT *
FROM table_name
WHERE indexed_column = target_value;
```

---

## 24. 练习题与参考答案

先独立完成，再查看答案。

### 练习 1：查询在售商品

查询所有 `status = 1` 且库存大于 0 的商品，按价格从高到低排序；价格相同按 `id` 升序。

<details>
<summary>参考答案</summary>

```sql
SELECT id, sku, name, price, stock
FROM products
WHERE status = 1
  AND stock > 0
ORDER BY price DESC, id ASC;
```

</details>

### 练习 2：统计有效消费

按用户统计 `paid` 和 `completed` 订单的总金额，要求没有有效订单的用户也显示，金额为 0。

<details>
<summary>参考答案</summary>

```sql
SELECT
    u.id,
    u.username,
    COALESCE(
        SUM(
            CASE
                WHEN o.status IN ('paid', 'completed')
                THEN o.total_amount
                ELSE 0
            END
        ),
        0
    ) AS effective_amount
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.username
ORDER BY effective_amount DESC, u.id;
```

</details>

### 练习 3：查询没有订单的用户

使用 `NOT EXISTS` 完成。

<details>
<summary>参考答案</summary>

```sql
SELECT u.id, u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
);
```

</details>

### 练习 4：查询每个类别最贵的商品

如果并列最贵，要保留所有并列商品。

<details>
<summary>参考答案</summary>

```sql
WITH ranked_products AS (
    SELECT
        id,
        category,
        name,
        price,
        RANK() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS price_rank
    FROM products
)
SELECT id, category, name, price
FROM ranked_products
WHERE price_rank = 1
ORDER BY category, id;
```

</details>

### 练习 5：校验订单总额

比较 `orders.total_amount` 与订单明细的 `subtotal` 合计，找出不一致订单。

<details>
<summary>参考答案</summary>

```sql
SELECT
    o.id,
    o.order_no,
    o.total_amount AS recorded_amount,
    SUM(oi.subtotal) AS calculated_amount
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.order_no, o.total_amount
HAVING o.total_amount <> SUM(oi.subtotal);
```

</details>

### 练习 6：事务内修改后撤销

把所有文具库存增加 50，查询修改结果，然后撤销。

<details>
<summary>参考答案</summary>

```sql
START TRANSACTION;

UPDATE products
SET stock = stock + 50
WHERE category = '文具';

SELECT id, name, stock
FROM products
WHERE category = '文具';

ROLLBACK;
```

</details>

---

## 推荐学习顺序

第一轮只掌握：

1. `CREATE DATABASE`、`CREATE TABLE`；
2. `INSERT`、`UPDATE`、`DELETE`；
3. `SELECT ... FROM ... WHERE ... ORDER BY ... LIMIT`；
4. `COUNT / SUM / AVG + GROUP BY + HAVING`；
5. `INNER JOIN` 与 `LEFT JOIN`；
6. `START TRANSACTION / COMMIT / ROLLBACK`。

第二轮再学习：

1. 子查询与 `EXISTS`；
2. CTE；
3. 窗口函数；
4. 联合索引与 `EXPLAIN`；
5. 锁、隔离级别和并发问题。

真正掌握 SQL 的标准不是“背出所有关键字”，而是看到需求后能回答：

> 数据来自哪些表？表怎样连接？过滤发生在哪一步？是否需要分组？结果如何排序？修改是否需要事务？查询是否有合适索引？

---

## 官方参考

- [MySQL 8.4 Reference Manual：SQL Statements](https://dev.mysql.com/doc/refman/8.4/en/sql-statements.html)
- [MySQL 8.4 Reference Manual：SELECT Statement](https://dev.mysql.com/doc/refman/8.4/en/select.html)
- [MySQL 8.4 Reference Manual：CREATE TABLE Statement](https://dev.mysql.com/doc/refman/8.4/en/create-table.html)
- [MySQL 8.4 Reference Manual：Data Types](https://dev.mysql.com/doc/refman/8.4/en/data-types.html)
- [MySQL 8.4 Reference Manual：Functions and Operators](https://dev.mysql.com/doc/refman/8.4/en/functions.html)
- [MySQL 8.4 Reference Manual：String Functions and Operators](https://dev.mysql.com/doc/refman/8.4/en/string-functions.html)
- [MySQL 8.4 Reference Manual：Mathematical Functions](https://dev.mysql.com/doc/refman/8.4/en/mathematical-functions.html)
- [MySQL 8.4 Reference Manual：Date and Time Functions](https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html)
- [MySQL 8.4 Reference Manual：Flow Control Functions](https://dev.mysql.com/doc/refman/8.4/en/flow-control-functions.html)
- [MySQL 8.4 Reference Manual：Aggregate Functions](https://dev.mysql.com/doc/refman/8.4/en/aggregate-functions.html)
- [MySQL 8.4 Reference Manual：JSON Function Reference](https://dev.mysql.com/doc/refman/8.4/en/json-function-reference.html)
- [MySQL 8.4 Reference Manual：WITH Common Table Expressions](https://dev.mysql.com/doc/refman/8.4/en/with.html)
- [MySQL 8.4 Reference Manual：Window Functions](https://dev.mysql.com/doc/refman/8.4/en/window-functions.html)
- [MySQL 8.4 Reference Manual：Transactional and Locking Statements](https://dev.mysql.com/doc/refman/8.4/en/sql-transactional-statements.html)
- [MySQL 8.4 Reference Manual：Access Control and Account Management](https://dev.mysql.com/doc/refman/8.4/en/access-control.html)
