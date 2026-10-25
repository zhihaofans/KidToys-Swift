# KidToys 仓库约定

## 版本号规则

唯一真相源是 `KidToys.xcodeproj/project.pbxproj` 里的两处 `MARKETING_VERSION`（Debug / Release 各一处），
以及两处 `CURRENT_PROJECT_VERSION`。代码里不许出现版本常量，要显示就读：

```swift
Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
```

格式是 `a.b.c`，**怎么升**：

| 改动性质 | 改哪一位 | 例子 |
|---|---|---|
| 加新功能 | **中间的 `b`**，同时把 `c` 归零 | `0.0.2` → `0.1.0` |
| 修 bug、小调整 | 末位的 `c` | `0.1.0` → `0.1.1` |
| 大重写、不兼容改动 | 最前面的 `a` | `0.1.1` → `1.0.0` |

- 改的时候 Debug / Release 两处必须一起改，改完 `grep MARKETING_VERSION` 核对。
- **改版本号必须同时把 `CURRENT_PROJECT_VERSION` +1**，两个键永远成对动：
  `0.0.1 build 1` → `0.0.2 build 2` → `0.1.0 build 3`。
- 构建号只增不复用：同一个 build 号往 App Store Connect 传两次会被拒，所以宁可跳号，绝不回退。
- 本工程没开 `VERSIONING_SYSTEM`，`agvtool` 用不了，只能改 pbxproj 或 Xcode → target → General。
- 当前版本：`0.0.2`（build `2`）。

## 构建与验证

```bash
# 模拟器构建（需要完整磁盘权限，否则 SwiftPM 缓存写不进去）
xcodebuild -project KidToys.xcodeproj -scheme "KidToys Watch App" -configuration Debug \
  -destination 'platform=watchOS Simulator,id=<UDID>' \
  -derivedDataPath .tmp/ddb build
```

- `.tmp/` 是 gitignored 的临时区：截图、derivedData 都放这里，不要提交。
- 验证走「构建 → `simctl install/launch` → `simctl io screenshot` → 看图」，不要靠读代码判断布局。
