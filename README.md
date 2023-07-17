# PosePerfect

PosePerfect 是一个基于 SwiftUI 编写的跳舞姿态识别及评估 app，它使用 Apple 的 Vision 框架进行姿态识别，为用户评估跳舞水平。

## 文件结构

下面是项目的主要文件和文件夹，以及它们的功能。

### PosePerfectApp.swift 和 ContentView.swift

这是 SwiftUI 应用的入口点。`PosePerfectApp.swift` 用于启动应用程序，而 `ContentView.swift` 是应用程序的主界面。

### Camera

这个文件夹包含用于显示和控制相机视图的所有代码。

- `CameraView.swift`: 为 SwiftUI 提供相机视图的视图层。
- `CameraViewWrapper.swift`: 连接 `CameraViewController` 和 `CameraView` 的桥接器。
- `CameraViewController.swift`: 控制实际的相机功能。

### Views

这个文件夹包含了应用程序的所有视图文件。

- `DanceMapping.swift`: 录入标准姿势的类。
- `DetectionView.swift`: 评估姿势的类。
- `StickFigureView.swift`: 在身体上划线的类。
- `DanceMenuView.swift`: 选择舞种的界面。
- `LoginView.swift`: 登录界面。

### Utils

这个文件夹包含了一些工具类，例如：

- `Color.swift`: 提供一些颜色和绘制线条的扩展。
- `DataCalculator.swift`: 提供计算角度及其他运算的方法。
- `PoseEstimator.swift`: 包含姿态识别框架和评估姿势的方法的核心类。
- `Constants.swift`: 存储一些常量和域名等。
- `Database.swift`: 用于操控数据库的类。
- `TransferData.swift`: 数据传输类。
- `Data.swift`: 姿态的实体类。
- `NetworkManager.swift`: 控制登录和其他 HTTP 连接的类。
- `WebSocketService.swift`: 实时 Websocket 传输类。

## 如何运行

你需要有一个运行 macOS 10.15 或更高版本的 Mac，并安装了 Xcode 11 或更高版本。首先，克隆这个仓库，然后在 Xcode 中打开它，选择一个目标设备运行即可。

## 许可证

这个项目是在 MIT 许可证下发布的。
