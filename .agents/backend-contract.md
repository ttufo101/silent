# Starland 后端接口边界

## 事实来源与范围

- 客户端：`E:/sproj/silent`；本文客户端源码路径均相对此仓库。
- 协议：`E:/sproj/proto/starland`，相对路径 `../proto/starland`。此位置由用户指定，其他机器应定位对应协议仓库。
- 用户确认的架构：客户端 HTTP JSON → Gateway → 后端 protobuf 服务。
- 本文于 2026-09-07 对照客户端及上述 proto 整理。当前 `E:/sproj/sbackend` 目录未列出文件，未取得 Gateway 实现，
  因此以下 HTTP 响应描述是客户端要求，不是对线上实际输出的验证。

## 请求与响应入口

实现：`lib/auth/data/gateway_client.dart`。

- `GatewayClient.call()` 用 Dio 发出 `POST /startlandapi`；路径与 `gateway.proto` 的 HTTP annotation 一致，保留现有拼写。
- 当前默认地址硬编码在该构造函数；修改环境地址时从这里追踪，不把当前地址视为所有部署环境的固定契约。
- 请求体为 `com` 与 `req`。`com` 包含 `dev_id`、`dev_type`、`app_ver`、`os_ver`、`jwt_token`；
  `req` 包含 `module`、`method`、对象类型的 `params`。
- 设备 ID 通过 SharedPreferences 的 `authDeviceId` 保存；会话 Token 不存于此处。
- Token 当前位于 `com.jwt_token`，无 Token 时为空字符串；不能擅自改为仅使用 Authorization header。
- 客户端要求响应包含整数 `code`、字符串 `msg` 和 `data`；`code == 0` 时 `data` 必须为对象，
  非零业务码转换为 `GatewayException`。Dio 接受 200–599 状态进入响应处理，不能只按 HTTP 状态判断业务成功。
- 这里没有透明刷新 Token 或自动重放业务请求的拦截器。

## 协议与已接入方法

| 协议文件 | 客户端已接入 | 入口或边界 |
| --- | --- | --- |
| `gateway.proto` | `Gateway.Call` 对应的 HTTP 入口 | `lib/auth/data/gateway_client.dart` |
| `login.proto` | `Login`、`Register`、`RefreshToken`、`GetRestToken`、`ResetPassword` | `lib/auth/data/auth_api.dart`，module 为 `starland.login.com` |
| `vfcode.proto` | `SendEmailCode`，用于密码找回 | 同上，module 为 `starland.vfcode.com`；其他验证码 RPC 未在该适配层接入 |
| `starcore.proto` | `GetPlans`、`GetUserInfo`、`GetLinks`、`ChangePassword` | `lib/starcore/data/starcore_api.dart`，module 为 `starland.starcore.com` |
| `order.proto` | 当前业务适配层未发现调用 | 定义创建/查询订单、支付及回调，不代表客户端已完成购买闭环 |
| `uidflake.proto` | 当前业务适配层未发现调用 | ID 生成服务，不应仅因存在 proto 就增加客户端入口 |

`Starcore.GetDevices`、`RemoveDevice`、`ReportTraffic` 尚未在 `StarcoreApi` 接入。
协议注明 `GetPlanForPurchase`、`GrantSubscription`、`RevokeSubscription` 用于 order 服务或管理工具，
不能据此假设客户端可调用这些权益管理接口。实际网关开放与鉴权策略仍需检查服务端。
模块字符串以客户端已使用的值为证据，不能简单从 proto service 大小写推导路由名。

## 认证与字段适配

入口：`lib/auth/auth_controller.dart`、`lib/auth/models/auth_session.dart`、`lib/auth/data/auth_storage.dart`。

- `AuthController` 是 ChangeNotifier，由 `lib/auth/providers.dart` 的普通 Provider 提供并负责 dispose；不是生成的 Riverpod notifier。
- 认证与 Starcore API 共享同一个 `GatewayClient` 实例，Token 由认证控制器维护。
- 会话使用 FlutterSecureStorage 的 `authSession` 键保存。登录按 remember 决定持久化，注册当前始终持久化。
- 初始化要求 Refresh Token 未过期；Access Token 有效则直接恢复，否则尝试刷新。刷新失败清除会话。
- Access Token 有效期判断预留 30 秒。`ensureValidAccessToken()` 合并正在执行的刷新，刷新失败退出登录。
  `ServerProfileSync` 调用该方法；`plansProvider` 直接调用 `getPlans()`，不能宣称所有业务请求都保证先刷新。
- 注册当前发送空 `code`；不能据此推断后端无需注册验证码。
- 密码找回按 `SendEmailCode` → `GetRestToken` → `ResetPassword` 调用，验证码场景是 `pwd_recovery`。
  保留协议现有拼写 `GetRestToken`、`rest_token`，重置请求字段为 `new_password`。
- `AuthSession.fromGatewayJson()` 要求 snake_case 字段、非空 UID/Token；过期时间当前仅接受 Unix 秒数字字符串。
- `Plan.fromJson()` 接受 snake_case 与 camelCase 别名，数值字段支持整数、整数值 num 和可解析字符串；
  未知套餐类型映射为 unknown，缺少数值字段默认 0。此宽容性不能类推到登录模型。
- `GetUserInfo` 用于个人中心展示账号、当前套餐、剩余天数、剩余流量和设备数量；
  `bound_device_count` 是曾经绑定且尚未被剔除的设备数量，页面以它和 `current_plan.max_devices` 展示设备配额。
  用户信息模型兼容 Gateway 的 snake_case 与 camelCase 字段名，数值字段兼容整数和数字字符串。
- `ChangePassword` 使用当前登录密码与新密码；客户端在调用前保证 Access Token 有效，密码长度遵循协议的
  8 至 72 字节限制。
- `GetLinks.has_subscription` 是客户端判断当前用户是否拥有有效套餐权益的依据。无权益时允许 `content` 为空；
  有权益时 `content` 必须是非空、有效的 base64 配置原文。客户端同时兼容 Gateway 的 snake_case 与 camelCase 字段名。

## 待核实的网关差异

| 问题 | 已看到的证据 | 后续核实入口 |
| --- | --- | --- |
| 响应外层及加密 | `gateway.proto` 的 `Response.data` 是 string，另有 `EncryptedResponse`；客户端要求明文对象 `data` | Gateway HTTP handler、响应包装、中间件及脱敏响应样本 |
| 登录时间戳类型 | proto 的 int64 带 `json_name` 和 `jstype = JS_NUMBER`；客户端只接受字符串 | 实际序列化器配置和登录/刷新响应；不能仅凭标注断言线上是数字 |
| JSON 字段命名与默认值 | 登录严格读取 snake_case，套餐支持两种命名 | Gateway protobuf JSON 转换与默认值输出策略 |
| 注册验证码与访问权限 | 注册 code 为空；协议包含内部权益 RPC | 服务端校验与网关方法开放清单 |

这些差异不能通过在文档中选择某一侧作为已验证事实来消除；本次没有修改业务实现或外部协议。

## 修改时的阅读顺序

1. 先读取对应 proto 的请求、响应和语义，再定位客户端 API 与模型解析。
2. 涉及外层格式、字段命名、数值类型、鉴权或错误码时，补读 Gateway 实现；缺失时明确记录未知项。
3. 沿调用方追踪 Token、状态、存储和 UI 消费，避免只改接口字段而遗漏配置同步或会话恢复。
4. 新业务调用复用 Gateway 封装；保持远程 Starland API、本地 Core IPC 与 Windows Helper loopback HTTP 的边界。
5. 修改接口或流程后同步更新本文；不要手改生成文件，也不要把协议定义列表描述成已上线功能列表。
