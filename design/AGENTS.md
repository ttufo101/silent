# 项目协作规则

## UI 事实来源

- `DESIGN.md` 是颜色、字体、全局间距体系、圆角、阴影和视觉原则的事实来源。
- `DESIGN.dark.md` 是暗色主题视觉 Token 的事实来源。
- `components/ui` 是 shadcn/ui 组件 Props、Variant、Size、DOM、状态和可访问性行为的事实来源。
- `components.json` 是 shadcn/ui 项目配置的事实来源。
- PRD 定义产品功能和业务规则。
- 具体页面的 Figma 节点用于页面布局、内容关系和视觉验收。

## UI 实现规则

- 开发界面前读取 `DESIGN.md`；暗色任务同时读取 `DESIGN.dark.md`。
- 优先复用 `components/ui` 中已有组件，使用前检查其实际源码。
- 使用项目语义 CSS Variables，不添加已有 Token 可以表达的硬编码颜色或尺寸。
- 不静默修改 `components/ui` 的公共 Props、Variant 或默认行为。
- 设计规范与组件源码冲突时，先报告差异：全局视觉以 DESIGN.md 为目标，组件 API 和运行行为以源码为准。
- 项目缺少组件时优先组合已有 primitives；新增公共组件前说明复用范围和影响。
- 完成后检查 Light/Dark、响应式、键盘操作、焦点、Disabled、Loading、Empty 和 Error 状态。

