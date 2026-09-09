# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## 当前工作区与业务范围

- `E:/sproj/silent` 是 VPN 客户端仓库，在 FlClash 基础上包含 Starland 登录、套餐展示和服务器配置同步。
- `E:/sproj/proto/starland` 是用户指定的后端 protobuf 契约目录；相对当前仓库为 `../proto/starland`，属于外部仓库，不是客户端生成代码目录。
- 客户端发送 HTTP JSON，Gateway 将请求转换为后端 protobuf 调用。接口契约、客户端适配和网关运行时行为分别核对，不能仅凭 proto 推断完整 HTTP 格式。
- 跨仓库接口入口及已知差异见 [backend-contract.md](backend-contract.md)；客户端目录职责与启动流程见 [architecture.md](architecture.md)。

## Version Notes

- Release CI pins Flutter 3.44.4. Local SDK may diverge, so trust the CI
  version as the source of truth for release builds.
- Dart SDK constraint: `>=3.8.0 <4.0.0`.

## Build Dependencies

Linux:

```bash
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev
```

Windows:

- GCC and Inno Setup.
- `ANDROID_NDK` env var for Android builds.

macOS:

```bash
npm install -g appdmg
```
