//
//  KidToysApp.swift
//  KidToys Watch App
//
//  Created by zzh on 2026/10/13.
//

import SwiftUI
import SwiftUtils

@main
struct KidToys_Watch_AppApp: App {
    init() {
        // 统一走 SwiftUtils 的 swift-log 封装，DEBUG 下默认 .debug 级别
        SU.log.i("KidToys 启动")
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
