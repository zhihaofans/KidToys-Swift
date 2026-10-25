//
//  KidToysApp.swift
//  KidToys Watch App
//
//  Created by zzh on 2026/10/13.
//

import Foundation
import SwiftUI
import SwiftUtils
import CrashKit

@main
struct KidToys_Watch_AppApp: App {
    init() {
        // 崩溃留痕要在最早安装，越早越能覆盖启动期的崩溃。
        // CrashKit 0.1.2 起会在 watchOS 上自动跳过致命信号处理器
        //（watchOS 不允许 sigaction 到致命信号，0.1.1 之前会一启动就 SIGTRAP），
        // 所以这里恢复成默认调用。
        CrashRecorder.shared.install()
        // 统一走 SwiftUtils 的 swift-log 封装，DEBUG 下默认 .debug 级别
        SU.log.i("KidToys 启动")

        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-crashkit-test") {
            CrashRecorder.shared.crashForTesting()
        }
        if arguments.contains("-crashkit-exc-test") {
            // 手表上真正可用的自测入口：造一个 ObjC 异常，验证「落盘 → 下次启动读取」
            NSException(name: .internalInconsistencyException,
                        reason: "CrashKit watch test",
                        userInfo: nil).raise()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
