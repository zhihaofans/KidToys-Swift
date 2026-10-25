# 小小玩具箱 · 上架 / TestFlight 待办清单

> 生成于 2026-10-16。基于当前仓库逐项核对，不是通用模板。
> 「1. 工程侧」的每一条都是我在这个工程里实际查出来的，不是套话。

---

## 0. 当前状态速览

| 项目 | 状态 |
|---|---|
| Release 配置 + 真机架构（arm64 / arm64_32） | 已编译通过 |
| App 图标 1024×1024、无 alpha 通道 | 已接入 `Assets.xcassets` |
| Bundle ID | `me.zzhhoo.KidToys.watchkitapp` |
| 最低系统 | watchOS 26.0（对方手表必须 ≥ 此版本） |
| 版本号 | `0.0.2` (build `2`) |
| 隐私清单 `PrivacyInfo.xcprivacy` | **缺失** |
| 开发区域 `CFBundleDevelopmentRegion` | **`en`**（应改为 `zh-Hans`） |
| 加密合规 `ITSAppUsesNonExemptEncryption` | **未声明** |
| 依赖 | SwiftUtils 0.0.23 → Alamofire + swift-log |

---

## 1. 工程侧必须先补

### 1.1 加隐私清单（**P0，正式上架必拦**）

**问题**：`RandomNumberRollView` / `RandomNumberRangeSettingsView` 用了 `@AppStorage`，底层是 `NSUserDefaults`。我确认过编译产物里确实引用了它（2 处符号）。

`UserDefaults` 属于苹果的**「必需理由 API」**（Required Reason API）。不声明的话，上传 App Store Connect 通常会收到：

```
ITMS-91053: Missing API declaration
```

**严重程度要分清**（我第一版写得太绝对，这里修正）：上传时它多半表现为**警告邮件**，未必当场拦住上传；但苹果的官方措辞是「不合规的 App 将不被接受」，所以**正式上架一定拦，内部测试不一定**。既然只有 10 分钟的事，建议一开始就加上。

**做法**：在 `KidToys Watch App/` 下新建 `PrivacyInfo.xcprivacy`（这个目录是文件系统同步组，加了自动进 target，不用手动拖进 Xcode）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

`CA92.1` 的含义是「只读写本 App 自己的 user defaults」，正是我们的用法。

**我同时扫过其他三类必需理由 API，都是干净的**，不用声明：

| API 类别 | 结果 |
|---|---|
| System Boot Time（`systemUptime` 等） | 未引用 |
| File Timestamp（`stat` / `fstat` / `getattrlist` 等） | 未引用 |
| Disk Space（`statfs` / `statvfs` 等） | 未引用 |
| Active Keyboard（`activeInputModes`） | 未引用 |

另外 `identifierForVendor` 也没引用（SwiftUtils 里的 `DeviceUtil` 用到了，但没被链接进来），所以苹果的「设备 ID」类问题可以填"不使用"。

### 1.2 开发区域改成中文（**P0**）

**问题**：产物 Info.plist 里 `CFBundleDevelopmentRegion = en`，但整个 App 界面全是中文。这样 App Store 会把它当成英文 App，商店页默认语言、搜索归类都会不对。

**做法**：工程文件里把 `developmentRegion` 改成 `zh-Hans`，`knownRegions` 加上 `zh-Hans`。

### 1.3 声明加密合规（P1，省事）

**问题**：不声明的话，**每次上传** App Store Connect 都会问你「这个 App 用没用加密」，得手动答一遍。

本 App 不联网、不做任何自定义加密，可以直接在构建设置里加：

```
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO
```

（对应 Info.plist 的 `ITSAppUsesNonExemptEncryption`，Release 产物里确认目前没有这个键。）

### 1.4 版本号（P1）

- `MARKETING_VERSION` 现在是 `0.0.2`，格式 `a.b.c`，规则见仓库根目录 `AGENTS.md`：
  - **加新功能改中间的 `b`**（`0.0.2` → `0.1.0`）
  - 修 bug / 小调整改末位的 `c`（`0.1.0` → `0.1.1`）
  - `a` 只在大改版时动；正式上架建议整体改成 `1.0.0`（0.x 会显得是测试版）
- `CURRENT_PROJECT_VERSION` 现在是 `2`。**改版本号时必须同时 +1**（成对动：`0.0.1/1` → `0.0.2/2` → `0.1.0/3`），只增不复用；同一个 build 号传两次会被拒。

### 1.5 可选：瘦身（P1，但很值）

**我实测发现的问题**：App 里**打包了一整个用不到的 Alamofire**。

- Release `.app` = **7.0 MB**，其中可执行文件 6.72 MB
- 二进制里有 **933 个 URLSession 相关符号**、7818 个 Alamofire 相关符号 —— 说明它的 HTTP 实现真的被链接进去了，没被 dead-strip 掉
- 而我们对 SwiftUtils 的使用只有一句 `SU.log.i(...)`

**原因**：SwiftPM 是**整模块一个目标文件**编译的。只要用了 `SwiftUtils` 模块的任何东西，整个 `SwiftUtils.o` 都会被拉进来，而它里面的 `HttpUtil` 依赖 Alamofire，于是整条 HTTP 栈跟着进来了。

**三个选项**：

1. **完全不用 SwiftUtils**，日志改用系统的 `os.Logger` —— 可执行文件能从 6.72 MB 降到 ~0.2 MB 量级，依赖清零、隐私面最小
2. **让 SwiftUtils 拆分**：把 `HttpUtil` 拆成独立 target/product（比如 `SwiftUtilsHttp`），用不到网络的 App 就不会被拖累 —— 这个改动在 SwiftUtils 仓库那边
3. **就这样**：功能上没问题，Alamofire 自带隐私清单（我在包里确认了 `Alamofire_Alamofire.bundle/PrivacyInfo.xcprivacy`），不违反儿童类规则，只是体积大

一个只教数数认颜色的手表小玩具带 6.7 MB 网络库，我倾向于选项 1 或 2。

---

## 2. App Store Connect 要准备的素材

### 2.0 内部测试 / 外部测试 / 正式上架，各要什么

先分清「**机器校验**」和「**人类审核**」——内部测试松的是后者，不是前者。

| 项目 | 内部测试 | 外部测试 | 正式上架 |
|---|---|---|---|
| Beta App Review | 不需要 | **首个 build 需要** | — |
| App Review | — | — | **需要** |
| 截图 | 不需要 | 不需要 | 需要 |
| 描述 / 关键词 / 分类 | 不需要 | 基本信息 | 需要 |
| 年龄分级 | 不需要 | 需要 | 需要 |
| 隐私政策 URL | 不需要 | 需要 | **需要（儿童类强制）** |
| 隐私营养标签（App Privacy） | 不需要 | 需要 | 需要 |
| 隐私清单 `PrivacyInfo.xcprivacy` | 上传校验会查（见 1.1） | 同左 | 同左 |
| 唯一 build 号 | 需要 | 需要 | 需要 |
| 先建 App Store Connect 记录 | 需要 | 需要 | 需要 |

**但内部测试有个硬前提**：内部测试员必须是**你 App Store Connect 团队的用户**（上限 100 人），不能像外部测试那样凭邮箱邀请陌生人。如果你是**个人开发者账号**，很可能根本加不了用户——那样亲友就只能走外部测试。这一点请到 App Store Connect 的「用户和访问」里确认。

参考：[Add internal testers（官方文档）](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers)

**结论**：如果只是想自己和家人把 App 装到手表上跑，**最快的是 Xcode 直装**（注册手表 UDID，连你的 Mac 装一次，不用审核、不用建记录、隐私清单也不用管，代价是描述文件 1 年到期）。一旦要"发个链接给异地的亲友"，那就会落到外部测试或未上架商店，两者都按上架标准准备，所以这份清单不算白列。

### 2.1 应用信息

- [ ] **App 名称**（≤30 字符）：`小小玩具箱` **很可能已被占用**，商店名称必须全局唯一，得先想 2–3 个备选
- [ ] **副标题**（≤30 字符）：例如「3 岁宝宝的数数认色小游戏」
- [ ] **描述**：写给孩子家长看，说明适龄、无广告、无内购、不联网
- [ ] **关键词**（≤100 字符，逗号分隔）：`儿童,幼儿,数学,颜色,字母,手表,早教,3岁`
- [ ] **主语言**：简体中文
- [ ] **分类**：`儿童` → 年龄档选「5 岁及以下」；副分类可放 `教育`
- [ ] **年龄分级问卷**：全选「无」→ 结果应为 4+
- [ ] **版权**：你的名字或组织

### 2.2 隐私

- [ ] **隐私营养标签**：全部选「不收集数据」（本 App 不联网、不上报、无第三方分析 SDK）
- [ ] **隐私政策 URL（儿童类强制要求）**：需要你准备一个可公开访问的页面。最省事的做法是用 GitHub Pages 放一页静态 HTML，内容说明「不收集任何数据、无广告、无内购」
- [ ] **支持 URL**：可以直接用该 App 的 GitHub Issues 页

### 2.3 截图

- [ ] Apple Watch 截图 **1–2 张**。我在这边截的模拟器图是 `416×496`（Series 11 46mm），上传时 App Store Connect 会校验尺寸，不够我再按它要求的机型重截即可
- [ ] 建议截图内容：首页四宫格、随机数字页、加减法绿勾——最能说明是给小孩用的

### 2.4 构建与上传

- [ ] Xcode `Product > Archive`（**Generic WatchOS Device**）
- [ ] `Distribute App > App Store Connect > Upload`
- [ ] 上传后在 App Store Connect 里等构建处理完成

---

## 3. 儿童类（Kids Category）额外要求

苹果对儿童类有硬性规定，逐条对照当前实现：

| 要求 | 当前状态 |
|---|---|
| 不得含第三方广告 SDK | 满足（无） |
| 不得含第三方分析 SDK | 满足（无） |
| 不得收集儿童个人信息 | 满足（数据只存在本地 UserDefaults） |
| 外链必须设家长门 | 满足（App 内没有任何外链） |
| 不得使用 IDFA | 满足（未引用 `identifierForVendor`） |
| 必须有隐私政策 | **待补**（见 2.2） |

注意：`@AppStorage` 存的是本机设置，**不属于「收集数据」**，隐私标签照实填「不收集」即可。

---

## 4. 三条分发路径的操作要点

### 4.1 未上架（Unlisted）App Store —— 推荐给亲友长期用

1. App Store Connect 建 App 记录（Bundle ID 选 `me.zzhhoo.KidToys.watchkitapp`）
2. 正常提交审核，在审核备注里申请 **unlisted app distribution**
3. 通过后拿到直达链接，发链接给亲友即可安装
4. 无 90 天限制、无需注册设备、异地可装

> 若建记录时提示该 Bundle ID 不可用（`.watchkitapp` 后缀有时会被拦），改用不带后缀的 ID（如 `me.zzhhoo.KidToys`）重建即可。

### 4.2 TestFlight

1. 同样先建 App 记录
2. 上传 build → 外部测试
3. **首个 build 需要 Beta 审核**（一般 1–2 天）
4. 测试者在其**配对的 iPhone** 上装 TestFlight 接受邀请

**注意两个坑**：
- 每个 build 只活 **90 天**，过期要重新传、亲友重新更新
- **家人共享设置（Apple Watch For Your Kids）的手表，TestFlight 有已知问题**，可能装不上。孩子的手表如果是这种配置，直接走 4.1

### 4.3 Xcode 直装（开发 / Ad-hoc）

- 需要注册**手表自己的 UDID**（不是 iPhone 的），只能靠手表连到你的 Mac、在 Xcode 的 Devices 窗口里取
- 描述文件 **1 年到期**，到期后 App 直接打不开
- 人不在身边基本不现实，只适合当面调试

---

## 5. 我建议的推进顺序

1. **先补 1.1 + 1.2**（隐私清单、开发区域）—— 这两项不做，审核/上传这一关就过不去
2. 顺手做 1.3 + 1.4（加密声明、版本号）
3. 决定 1.5 要不要瘦身
4. 你去准备 2.2 的隐私政策页面 + 定 App 名称
5. 建 App Store Connect 记录 → Archive → 上传 → 走 **4.1**

## 6. 我可以直接动手做的

- 加 `PrivacyInfo.xcprivacy`
- 改开发区域为 `zh-Hans`
- 加 `ITSAppUsesNonExemptEncryption = NO`、版本号改 `1.0.0`
- 截一套符合 App Store 要求的截图
- 瘦身方案（去掉 SwiftUtils 依赖，日志改 `os.Logger`）

需要哪几项，说一声。
